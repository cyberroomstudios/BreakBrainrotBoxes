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
local FunnelService = require(ServerScriptService.Modules.FunnelService)
local bridge = BridgeNet2.ReferenceBridge("WorkerService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local MAX_BREAKER_SCALE = 5

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
			local crateRef = WorkerService:GetNextAvailableCrateReF(player)
			if crateRef then
				CrateService:Consume(player, crateName)
				ToolService:Consume(player, "CRATE", crateName)
				crateRef:SetAttribute("BUSY", true)
				WorkerService:SetCrate(player, crateName, crateRef.Name, nil)
				FunnelService:AddEvent(player, "PLACE_CRATE")
				continue
			end
		end
	end
end

function WorkerService:GetNextAvailableCrateReF(player: Player)
	local plots = workspace:WaitForChild("Map"):WaitForChild("Plots")
	local plot = plots:WaitForChild(player:GetAttribute("BASE"))
	local crateRef = plot:WaitForChild("Main")
		:WaitForChild("BreakersArea")
		:WaitForChild("Containers")
		:WaitForChild("Container")
		:WaitForChild("CrateRef")

	local refs = crateRef:GetChildren()

	table.sort(refs, function(a, b)
		return tonumber(a.Name) < tonumber(b.Name)
	end)

	for _, value in refs do
		if value:GetAttribute("UNLOCK") and not value:GetAttribute("BUSY") then
			return value
		end
	end
end

function WorkerService:UpdateCrateBillboardGui(crate: Model)
	if crate.Parent then
		local hp = crate.HP
		local billboardGui = hp.BillboardGui
		local textLabel = billboardGui.Frame.TextLabel

		local currentXp = crate:GetAttribute("CURRENT_XP")
		local maxXp = crate:GetAttribute("MAX_XP")

		textLabel.Text = currentXp .. "/" .. maxXp
	end
end

function WorkerService:SetCrate(player: Player, crateName: string, positionRef: number, currentXp: number)
	local function updateCrateBillboardGui(crate: Model)
		local hp = crate.HP
		local billboardGui = hp.CrateHP
		local textLabel = billboardGui.Frame.TextLabel

		local currentXp = crate:GetAttribute("CURRENT_XP")
		local maxXp = crate:GetAttribute("MAX_XP")

		textLabel.Text = currentXp .. "/" .. maxXp
	end

	local plots = workspace:WaitForChild("Map"):WaitForChild("Plots")
	local plot = plots:WaitForChild(player:GetAttribute("BASE"))

	local crateRefFolder = plot:WaitForChild("Main")
		:WaitForChild("BreakersArea")
		:WaitForChild("Containers")
		:WaitForChild("Container")
		:WaitForChild("CrateRef")

	local crateRef = crateRefFolder:FindFirstChild(positionRef)

	if not crateRef then
		return
	end

	local crateEnum = Crate.CRATES[crateName]

	local crate = ReplicatedStorage.Crates:FindFirstChild(crateName):Clone()

	crate:SetAttribute("MAX_XP", crateEnum.XPToOpen)
	crate:SetAttribute("CURRENT_XP", currentXp and currentXp or crateEnum.XPToOpen)
	crate:SetAttribute("CRATE_TYPE", crateName)
	crate:SetAttribute("POSITION_NUMBER", positionRef)
	updateCrateBillboardGui(crate)

	--// Pega CFrame e tamanho da bounding box
	local cf, size = crate:GetBoundingBox()

	--// Calcula o ponto mais baixo (centro da base)
	local basePosition = cf.Position - Vector3.new(0, size.Y / 2, 0)

	--// Calcula o deslocamento entre base e attachment
	local offset = crateRef.WorldPosition - basePosition

	--// Move o modelo mantendo sua rotação original
	crate:PivotTo(cf + offset)

	crate.Parent = workspace.Runtime[player.UserId].Crates
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
	local brainrotType, mutationType = CrateService:DrawBrainrotFromCrate(player, crateType)

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
	local base = BaseService:GetBase(player)
	local main = base:FindFirstChild("Main")
	local breakersAreaFolder = main:FindFirstChild("BreakersArea")
	local containersFolder = breakersAreaFolder:FindFirstChild("Containers")
	local containersModel = containersFolder:WaitForChild("Container")
	local crateRefFolder = containersModel:WaitForChild("CrateRef")

	for _, value in crateRefFolder:GetChildren() do
		value:SetAttribute("BUSY", false)
	end

	for _, value in workspace.Runtime[player.UserId].Crates:GetChildren() do
		value:Destroy()
	end
end

function WorkerService:ScaleBreaker(player: Player, scaleValue: number)
	local function applyScaleKeepingOnGround(model)
		local base = BaseService:GetBase(player)
		local main = base:FindFirstChild("Main")
		local breakersAreaFolder = main:WaitForChild("BreakersArea")
		local containersFolder = breakersAreaFolder:WaitForChild("Containers")
		local containersModel = containersFolder:WaitForChild("Container")
		local breakerFolder = containersModel:WaitForChild("Breaker")
		local breakerCapacity = PlayerDataHandler:Get(player, "crateBreaker").Capacity
		local attachment = breakerFolder[breakerCapacity]
		model:ScaleTo(scaleValue)
		--// Pega CFrame e tamanho da bounding box
		local cf, size = model:GetBoundingBox()

		--// Calcula o ponto mais baixo (centro da base)
		local basePosition = cf.Position - Vector3.new(0, size.Y / 2, 0)

		--// Calcula o deslocamento entre base e attachment
		local offset = attachment.WorldPosition - basePosition

		local baseNumber = player:GetAttribute("BASE")

		--// Move o modelo mantendo sua rotação original
		model:PivotTo(cf + offset)
	end

	local base = BaseService:GetBase(player)
	local main = base:FindFirstChild("Main")
	local breakersAreaFolder = main:WaitForChild("BreakersArea")
	local containersFolder = breakersAreaFolder:WaitForChild("Containers")
	local containersModel = containersFolder:WaitForChild("Container")
	local breakerFolder = containersModel:WaitForChild("Breaker")
	local breakerModel = breakerFolder:FindFirstChild("Breaker")

	if not breakerModel then
		warn("Breaker não encontrado.")
		return
	end

	applyScaleKeepingOnGround(breakerModel)
end
function WorkerService:EnableCrate(player: Player, crateRefNumber: number)
	local base = BaseService:GetBase(player)
	local main = base:FindFirstChild("Main")
	local breakersAreaFolder = main:FindFirstChild("BreakersArea")
	local containersFolder = breakersAreaFolder:FindFirstChild("Containers")
	local containersModel = containersFolder:WaitForChild("Container")
	local crateRefFolder = containersModel:WaitForChild("CrateRef")
	local attachment = crateRefFolder:WaitForChild(crateRefNumber)

	if attachment then
		attachment:SetAttribute("UNLOCK", true)
	end
end

function WorkerService:EnableWorker(player: Player)
	local base = BaseService:GetBase(player)
	local main = base:FindFirstChild("Main")
	local breakersAreaFolder = main:WaitForChild("BreakersArea")
	local containersFolder = breakersAreaFolder:WaitForChild("Containers")
	local containersModel = containersFolder:WaitForChild("Container")
	local breakerFolder = containersModel:WaitForChild("Breaker")
	local currentBreaker = PlayerDataHandler:Get(player, "crateBreaker").Equiped
	local breakerCapacity = PlayerDataHandler:Get(player, "crateBreaker").Capacity

	-- Obtem o tipo do quebrador
	local breaker = ReplicatedStorage.Breakers:FindFirstChild(currentBreaker)

	if breaker then
		-- Cria o Quebrador
		local newBreaker = breaker:Clone()
		newBreaker.Parent = breakerFolder
		newBreaker:SetPrimaryPartCFrame(breakerFolder[breakerCapacity].WorldCFrame)
		newBreaker.Name = "Breaker"

		-- Tirando nome
		local humanoid = newBreaker:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			local animation = ReplicatedStorage.Animations.Breakers[currentBreaker].Idle
			local track = humanoid:LoadAnimation(animation)
			track.Priority = Enum.AnimationPriority.Idle
			track:Play()
		else
			local animationController = newBreaker:WaitForChild("AnimationController")
			local animator = animationController:WaitForChild("Animator")
			local animation = ReplicatedStorage.Animations.Breakers[currentBreaker].Idle

			local animationTrack = animator:LoadAnimation(animation)
			animationTrack.Priority = Enum.AnimationPriority.Idle

			animationTrack:Play()
		end
	end
end

function WorkerService:ChangeWorker(player: Player)
	local function getScale()
		local base = BaseService:GetBase(player)
		local main = base:FindFirstChild("Main")
		local breakersAreaFolder = main:WaitForChild("BreakersArea")
		local containersFolder = breakersAreaFolder:WaitForChild("Containers")
		local containersModel = containersFolder:WaitForChild("Container")
		local breakerFolder = containersModel:WaitForChild("Breaker")
		local breakerCapacity = PlayerDataHandler:Get(player, "crateBreaker").Capacity
		local scale = breakerFolder[breakerCapacity]:GetAttribute("SCALE")

		return scale
	end

	local base = BaseService:GetBase(player)
	local main = base:FindFirstChild("Main")
	local breakersAreaFolder = main:WaitForChild("BreakersArea")
	local containersFolder = breakersAreaFolder:WaitForChild("Containers")
	local containersModel = containersFolder:WaitForChild("Container")
	local breakerFolder = containersModel:WaitForChild("Breaker")
	local breakerModel = breakerFolder:FindFirstChild("Breaker")

	local parent
	if breakerModel then
		parent = breakerModel.Parent
		breakerModel:Destroy()
	end

	local crateBreaker = PlayerDataHandler:Get(player, "crateBreaker")
	local currentBreaker = crateBreaker.Equiped

	local breaker = ReplicatedStorage.Breakers:FindFirstChild(currentBreaker)

	if breaker then
		-- Cria o Quebrador
		local newBreaker = breaker:Clone()
		newBreaker.Parent = parent
		--	newBreaker:SetPrimaryPartCFrame(worker.Breaker.Attachment.WorldCFrame)
		newBreaker.Name = "Breaker"
		newBreaker:SetAttribute("BREAKER_NAME", currentBreaker)

		-- Tirando nome
		local humanoid = newBreaker:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			local animation = ReplicatedStorage.Animations.Breakers[currentBreaker].Idle
			local track = humanoid:LoadAnimation(animation)
			track.Priority = Enum.AnimationPriority.Idle
			track:Play()
		else
			local animationController = newBreaker:WaitForChild("AnimationController")
			local animator = animationController:WaitForChild("Animator")
			local animation = ReplicatedStorage.Animations.Breakers[currentBreaker].Idle

			local animationTrack = animator:LoadAnimation(animation)
			animationTrack.Priority = Enum.AnimationPriority.Idle
			animationTrack:Play()
		end
	end

	WorkerService:ScaleBreaker(player, getScale())
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
	local workerPower = workerData.Power + breakerPowerBost

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

		-- aplicar dano total de uma vez
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
		local crateRef = WorkerService:GetNextAvailableCrateReF(player)
		if crateRef then
			crateRef:SetAttribute("BUSY", true)
			-- Atualiza o tempo que quebrou offline
			currentXp = WorkerService:GetXPOfflineCrate(player, currentXp)
			WorkerService:SetCrate(player, crateName, crateRef.Name, currentXp)
			continue
		end
	end
end

return WorkerService
