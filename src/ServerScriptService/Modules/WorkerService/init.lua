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
				WorkerService:SetCrate(player, crateName, worker.Name)
				continue
			end
			print("Sem Espaço")
		end
	end
end

function WorkerService:GetNextWorkerAvailable(player: Player)
	local plots = workspace:WaitForChild("Map"):WaitForChild("Plots")
	local plot = plots:WaitForChild(player:GetAttribute("BASE"))
	local workersFolder = plot:WaitForChild("Main"):WaitForChild("WorkerArea"):WaitForChild("Workers")
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
	local center = crate.Center
	local billboardGui = center.BillboardGui
	local textLabel = billboardGui.Frame.TextLabel

	local currentXp = crate:GetAttribute("CURRENT_XP")
	local maxXp = crate:GetAttribute("MAX_XP")

	textLabel.Text = currentXp .. "/" .. maxXp
end

function WorkerService:SetCrate(player: Player, crateName: string, workerNumber: number)
	local plots = workspace:WaitForChild("Map"):WaitForChild("Plots")
	local plot = plots:WaitForChild(player:GetAttribute("BASE"))
	local workersFolder = plot:WaitForChild("Main"):WaitForChild("WorkerArea"):WaitForChild("Workers")
	local worker = workersFolder:FindFirstChild(workerNumber)
	local crateEnum = Crate.CRATES[crateName]

	if worker then
		local crate = ReplicatedStorage.Model.Crates:FindFirstChild(crateName):Clone()

		if crate then
			crate.Parent = workspace.Runtime[player.UserId].Crates

			-- Atributos
			crate:SetAttribute("MAX_XP", crateEnum.XPToOpen)
			crate:SetAttribute("CURRENT_XP", crateEnum.XPToOpen)
			crate:SetAttribute("CRATE_TYPE", crateName)

			crate:SetPrimaryPartCFrame(CFrame.new(worker.CrateRef.WorldPosition))

			task.spawn(function()
				if not animations[worker] then
					local humanoid = worker:WaitForChild("Humanoid")
					local animation = ReplicatedStorage.Animations.Worker.Attack
					local track = humanoid:LoadAnimation(animation)

					animations[worker] = track
				end

				local currentXP = crate:GetAttribute("CURRENT_XP")

				while crate.Parent and tonumber(crate:GetAttribute("CURRENT_XP")) > 0 do
					animations[worker]:Play()
					local workerPower = player:GetAttribute("Power")
					local workerSpeed = player:GetAttribute("Speed")

					-- Obtem o XP atual da caixa
					local currentXp = crate:GetAttribute("CURRENT_XP")
					local newCurrent = currentXp - (workerPower * 10)
					crate:SetAttribute("CURRENT_XP", newCurrent)

					local baseWait = 0.5
					local reductionPerLevel = 0.05
					local waitTime = math.max(0.1, baseWait - (workerSpeed - 1) * reductionPerLevel)
					task.wait(waitTime)

					WorkerService:UpdateCrateBillboardGui(crate)
				end

				crate:Destroy()

				WorkerService:CreateBrainrot(player, crate:GetAttribute("CRATE_TYPE"), worker.CrateRef)
				worker:SetAttribute("BUSY", false)
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
	local desks = plot:WaitForChild("Main"):WaitForChild("WorkerArea"):WaitForChild("Workers")

	local crate = workspace.Runtime[player.UserId].Crates

	for _, value in crate:GetChildren() do
		value:Destroy()
	end

	for _, value in desks:GetChildren() do
		value:SetAttribute("BUSY", false)
	end
end

function WorkerService:EnableWorker(player: Player, workerNumber: number)
	local function safe(fn)
		local ok, err = pcall(fn)
		if not ok then
			warn(err)
		end
	end

	local plots = workspace:WaitForChild("Map"):WaitForChild("Plots")
	local plot = plots:WaitForChild(player:GetAttribute("BASE"))
	local desks = plot:WaitForChild("Main"):WaitForChild("WorkerArea"):WaitForChild("Workers")

	local worker = desks:FindFirstChild(workerNumber)

	if worker then
		worker:SetAttribute("UNLOCK", true)

		-- Ativar Visualmente

		for _, v in ipairs(worker:GetDescendants()) do
			if v:IsA("BasePart") then
				safe(function()
					v.Transparency = 0
					v.CanCollide = true
					v.CanTouch = true
					v.CanQuery = true
					if v.CastShadow ~= nil then
						v.CastShadow = true
					end
				end)
			elseif v:IsA("Decal") or v:IsA("Texture") then
				safe(function()
					v.Transparency = 0
				end)
			elseif v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
				safe(function()
					v.Enabled = true
				end)
			elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
				safe(function()
					v.Enabled = true
				end)
			elseif v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
				safe(function()
					v.Enabled = true
				end)
			elseif v:IsA("ProximityPrompt") then
				safe(function()
					v.Enabled = true
				end)
			elseif v:IsA("ClickDetector") then
				safe(function()
					v.MaxActivationDistance = 32
				end) -- distância padrão
			elseif v:IsA("Sound") then
				safe(function()
					v.Volume = 1
				end)
			end
		end
	end
end

return WorkerService
