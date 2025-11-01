local WorkerService = {}

-- Init Bridg Net
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local CrateService = require(ServerScriptService.Modules.CrateService)
local ToolService = require(ServerScriptService.Modules.ToolService)
local Crate = require(ReplicatedStorage.Enums.Crate)
local PlotService = require(ServerScriptService.Modules.PlotService)
local IndexService = require(ServerScriptService.Modules.IndexService)
local BaseService = require(ServerScriptService.Modules.BaseService)
local Breakers = require(ReplicatedStorage.Enums.Breakers)
local bridge = BridgeNet2.ReferenceBridge("WorkerService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local animations = {}

function WorkerService:Init()
	WorkerService:InitBridgeListener()
end

function WorkerService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "PlaceAll" then
			WorkerService:SetAllCrateBackpack(player)
		end
	end
end

function WorkerService:SetAllCrateBackpack(player: Player)
	local crates = PlayerDataHandler:Get(player, "cratesBackpack")
	local putBox = false
	for crateName, amount in crates do
		for i = 1, amount do
			local worker = WorkerService:GetNextWorkerAvailable(player)
			if worker then
				print(worker.Name)
				CrateService:Consume(player, crateName)
				ToolService:Consume(player, "CRATE", crateName)
				worker:SetAttribute("BUSY", true)
				WorkerService:SetCrate(player, crateName, worker.Name, nil)
				continue
			end
			print("Sem Espaço")
		end
	end
end

function WorkerService:GetNextWorkerAvailable(player: Player)
	local plots = workspace:WaitForChild("Map"):WaitForChild("Plots")
	local plot = plots:WaitForChild(player:GetAttribute("BASE"))
	local workersFolder =
		plot:WaitForChild("Main"):WaitForChild("BreakersArea"):WaitForChild("Containers"):WaitForChild("Bases")
	local workers = workersFolder:GetChildren()

	table.sort(workers, function(a, b)
		return tonumber(a.Name) < tonumber(b.Name)
	end)

	for _, value in workers do
		if value:GetAttribute("UNLOCK") and not value:GetAttribute("BUSY") then
			return value
		end
	end
end

function WorkerService:UpdateCrateBillboardGui(crate: Model)
	if crate.Parent then
		local center = crate.Center
		local billboardGui = center.BillboardGui
		local textLabel = billboardGui.Frame.TextLabel

		local currentXp = crate:GetAttribute("CURRENT_XP")
		local maxXp = crate:GetAttribute("MAX_XP")

		textLabel.Text = currentXp .. "/" .. maxXp
	end
end

function WorkerService:SetCrate(player: Player, crateName: string, workerNumber: number, currentXp: number)
	local plots = workspace:WaitForChild("Map"):WaitForChild("Plots")
	local plot = plots:WaitForChild(player:GetAttribute("BASE"))
	local basesFolder =
		plot:WaitForChild("Main"):WaitForChild("BreakersArea"):WaitForChild("Containers"):WaitForChild("Bases")
	local breakerMain = basesFolder:FindFirstChild(workerNumber)
	local breaker = breakerMain:FindFirstChild("Breaker"):FindFirstChild("Breaker")
	local crateEnum = Crate.CRATES[crateName]

	if breaker then
		local crate = ReplicatedStorage.Model.Crates:FindFirstChild(crateName):Clone()

		if crate then
			crate.Parent = workspace.Runtime[player.UserId].Crates

			-- Atributos
			crate:SetAttribute("MAX_XP", crateEnum.XPToOpen)
			crate:SetAttribute("CURRENT_XP", currentXp and currentXp or crateEnum.XPToOpen)
			crate:SetAttribute("CRATE_TYPE", crateName)

			crate:SetPrimaryPartCFrame(CFrame.new(breakerMain.CrateRef.WorldPosition))

			task.spawn(function()
				local currentXP = crate:GetAttribute("CURRENT_XP")

				while player.Parent and crate.Parent and tonumber(crate:GetAttribute("CURRENT_XP")) > 0 do
					if player:GetAttribute("CHANGE_BREAKER") then
						player:SetAttribute("CHANGE_BREAKER", false)
						breakerMain = basesFolder:FindFirstChild(workerNumber)
						breaker = breakerMain:FindFirstChild("Breaker"):FindFirstChild("Breaker")
					end

					if not animations[breaker] then
						local humanoid = breaker:WaitForChild("Humanoid")
						local animation = ReplicatedStorage.Animations.Worker.Attack
						local track = humanoid:LoadAnimation(animation)

						animations[breaker] = track
					end

					animations[breaker]:Play()
					local workerPower = player:GetAttribute("Power")
					local workerSpeed = player:GetAttribute("Speed")

					-- Obtem o XP atual da caixa
					local currentXp = crate:GetAttribute("CURRENT_XP")
					local newCurrent = currentXp - workerPower
					crate:SetAttribute("CURRENT_XP", newCurrent)

					local baseWait = 0.5
					local reductionPerLevel = 0.05
					local waitTime = math.max(0.1, baseWait - (workerSpeed - 1) * reductionPerLevel)
					task.wait(waitTime)

					WorkerService:UpdateCrateBillboardGui(crate)
				end

				crate:Destroy()

				if (not player.Parent) or player:GetAttribute("EXIT") then
					return
				end

				if (not breakerMain) or not breakerMain.Parent or (not breakerMain:FindFirstChild("CrateRef")) then
					breakerMain = basesFolder:FindFirstChild(workerNumber)
					breaker = breakerMain:FindFirstChild("Breaker"):FindFirstChild("Breaker")
				end

				WorkerService:CreateBrainrot(player, crate:GetAttribute("CRATE_TYPE"), breakerMain.CrateRef)
				breakerMain:SetAttribute("BUSY", false)
			end)
		end
	end
end

function WorkerService:CreateBrainrot(player: Player, crateType: string, ref: Attachment)
	--  Função para alterar a escala do modelo
	local function setModelScale(model)
		model:ScaleTo(0.01)
		task.wait(0.005)
		model:ScaleTo(0.2)
		task.wait(0.005)
		model:ScaleTo(0.4)
		task.wait(0.005)
		model:ScaleTo(0.5)
	end

	-- Escolhe um brainrot com base no tipo da caixa
	local brainrotType, mutationType = CrateService:DrawBrainrotFromCrate(crateType)

	-- Obtem o Brainrot do modelo
	local brainrotModel = ReplicatedStorage.Brainrots:FindFirstChild(brainrotType)

	if brainrotModel then
		-- Clona o modelo
		local newBrainrot = brainrotModel:Clone()

		-- Seta na pasta do jogador
		newBrainrot.Parent = workspace.Runtime[player.UserId].BrainrotsFromCrate

		-- Coloca o Brainrot na posição da caixa
		newBrainrot:SetPrimaryPartCFrame(ref.WorldCFrame)

		-- Cria a animação de crescer
		setModelScale(newBrainrot)

		IndexService:Add(player, brainrotType, mutationType)
		-- Destroy o Brainrot
		task.wait(1)
		newBrainrot:Destroy()

		-- Coloca no slot
		PlotService:Set(player, brainrotType, mutationType)
	end
end

function WorkerService:ClearAllCrates(player: Player)
	local plots = workspace:WaitForChild("Map"):WaitForChild("Plots")
	local plot = plots:WaitForChild(player:GetAttribute("BASE"))
	local desks =
		plot:WaitForChild("Main"):WaitForChild("BreakersArea"):WaitForChild("Containers"):WaitForChild("Bases")

	local crate = workspace.Runtime[player.UserId].Crates

	for _, value in crate:GetChildren() do
		value:Destroy()
	end

	for _, value in desks:GetChildren() do
		value:SetAttribute("BUSY", false)
	end
end

function WorkerService:EnableWorker(player: Player, workerNumber: number)
	local base = BaseService:GetBase(player)
	local main = base:FindFirstChild("Main")
	local breakersAreaFolder = main:FindFirstChild("BreakersArea")
	local containersFolder = breakersAreaFolder:FindFirstChild("Containers")
	local refFolder = containersFolder:FindFirstChild("Refs")
	local attachment = refFolder:FindFirstChild(workerNumber)
	local currentBreaker = PlayerDataHandler:Get(player, "crateBreaker").Equiped

	if attachment then
		-- Cria o Suporte
		local newContainer = ReplicatedStorage.Model.Breakers.Container:Clone()
		newContainer.Name = workerNumber
		newContainer.Parent = containersFolder.Bases
		newContainer:SetPrimaryPartCFrame(attachment.WorldCFrame)

		-- Obtem o tipo do quebrador
		local breaker = ReplicatedStorage.Breakers:FindFirstChild(currentBreaker)

		if breaker then
			-- Cria o Quebrador
			local newBreaker = breaker:Clone()
			newBreaker.Parent = newContainer.Breaker
			newBreaker:SetPrimaryPartCFrame(newContainer.Breaker.Attachment.WorldCFrame)
			newBreaker.Name = "Breaker"

			-- Tirando nome
			local humanoid = newBreaker:FindFirstChildOfClass("Humanoid")
			humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

			local animation = ReplicatedStorage.Animations.Worker.Iddle
			local track = humanoid:LoadAnimation(animation)
			track:Play()
		end
	end
end

function WorkerService:DeleteAllBreakers(player: Player)
	local base = BaseService:GetBase(player)
	local main = base:FindFirstChild("Main")
	local breakersAreaFolder = main:FindFirstChild("BreakersArea")
	local containersFolder = breakersAreaFolder:FindFirstChild("Containers")
	local bases = containersFolder:FindFirstChild("Bases")

	for _, value in bases:GetChildren() do
		value:Destroy()
	end
end

function WorkerService:SaveOfflineCrate(player: Player)
	local allCrates = workspace.Runtime[player.UserId].Crates

	for _, crate in allCrates:GetChildren() do
		if crate.Parent and crate:GetAttribute("CURRENT_XP") > 0 then
			local id = PlayerDataHandler:Get(player, "crateOfflineId")
			local data = {
				Id = id,
				CrateName = crate.Name,
				CurrentXp = crate:GetAttribute("CURRENT_XP"),
			}

			PlayerDataHandler:Update(player, "cratesOffline", function(current)
				table.insert(current, data)
				return current
			end)

			PlayerDataHandler:Set(player, "crateOfflineId", id + 1)
		end
	end
end

function WorkerService:GetXPOfflineCrate(player: Player, currentXP: number)
	local timeLeftGame = PlayerDataHandler:Get(player, "timeLeftGame")
	local workerData = PlayerDataHandler:Get(player, "crateBreaker")

	if not workerData then
		return currentXP
	end

	local breakerPowerBost = Breakers[workerData.Equiped].Boosts.Power
	local breakerSpeedBost = Breakers[workerData.Equiped].Boosts.Speed

	local workerSpeed = workerData.Speed + breakerSpeedBost
	local workerPower = (workerData.Power * 10) + breakerPowerBost

	if timeLeftGame and timeLeftGame > 0 then
		local now = os.time()
		local secondsPassed = now - timeLeftGame
		if secondsPassed <= 0 then
			return currentXP
		end

		-- mesmo cálculo do seu código base
		local baseWait = 0.5
		local reductionPerLevel = 0.05
		local waitTime = math.max(0.1, baseWait - (workerSpeed - 1) * reductionPerLevel)

		-- quantas vezes ele teria causado dano
		local amountDamage = math.floor(secondsPassed / waitTime)

		-- aplicar dano total de uma vez (sem loop)
		local totalDamage = amountDamage * workerPower

		local newXp = math.max(0, currentXP - totalDamage)

		return newXp
	end

	return currentXP
end

function WorkerService:StartCratesFromOffline(player: Player)
	-- Pega todas as caixas que ficam armazenadas ao sair do jogo
	local offlineCrates = PlayerDataHandler:Get(player, "cratesOffline")
	PlayerDataHandler:Set(player, "cratesOffline", {})
	for _, crate in offlineCrates do
		local crateName = crate.CrateName
		local currentXp = crate.CurrentXp
		local worker = WorkerService:GetNextWorkerAvailable(player)
		if worker then
			worker:SetAttribute("BUSY", true)
			-- Atualiza o tempo que quebrou offline
			currentXp = WorkerService:GetXPOfflineCrate(player, currentXp)
			WorkerService:SetCrate(player, crateName, worker.Name, currentXp)
			continue
		end
	end
end

return WorkerService
