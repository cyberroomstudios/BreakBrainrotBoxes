local WorkerService = {}

-- Init Bridg Net
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("WorkerService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local Crate = require(ReplicatedStorage.Enums.Crate)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local ToolService = require(ServerScriptService.Modules.ToolService)
local CrateService = require(ServerScriptService.Modules.CrateService)
local BrainrotService = require(ServerScriptService.Modules.BrainrotService)
local PlotService = require(ServerScriptService.Modules.PlotService)

local animations = {}

function WorkerService:Init()
	WorkerService:InitBridgeListener()
end

function WorkerService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "PlaceAll" then
			print("PlaceAll")
			WorkerService:SetAllCrateBackpack(player)
		end

		if data[actionIdentifier] == "PlaceThis" then
			WorkerService:SetCrateFromHand(player)
		end
	end
end

function WorkerService:SetCrateFromHand(player: Player)
	local function getEquippedTool(player)
		local character = player.Character
		if not character then
			return nil
		end
		return character:FindFirstChildWhichIsA("Tool")
	end

	local tool = getEquippedTool(player)
	if tool then
		local deskNumber = WorkerService:GetNextDeskNumberAvailable(player)
		if deskNumber then
			CrateService:Consume(player, tool.Name)
			ToolService:Consume(player, "CRATE", tool.Name)
			WorkerService:SetCrate(player, tool.Name, deskNumber)
			WorkerService:StartAttack(player)
		end
	end
end

function WorkerService:SetAllCrateBackpack(player: Player)
	local crates = PlayerDataHandler:Get(player, "cratesBackpack")
	local putBox = false
	for crateName, amount in crates do
		for i = 1, amount do
			local deskNumber = WorkerService:GetNextDeskNumberAvailable(player)
			if deskNumber then
				CrateService:Consume(player, crateName)
				ToolService:Consume(player, "CRATE", crateName)
				WorkerService:SetCrate(player, crateName, deskNumber)
				putBox = true
			end
		end
	end

	if putBox then
		WorkerService:StartAttack(player)
	end
end

function WorkerService:GetNextDeskNumberAvailable(player: Player)
	local plots = workspace:WaitForChild("Map"):WaitForChild("Plots")
	local plot = plots:WaitForChild(player:GetAttribute("BASE"))
	local dummy = plot:WaitForChild("Main"):WaitForChild("Worker"):WaitForChild("Dummy")
	local desks = plot:WaitForChild("Main"):WaitForChild("Worker"):WaitForChild("Desks")

	for _, value in desks:GetChildren() do
		if not value:GetAttribute("BUSY") then
			return tonumber(value.Name)
		end
	end
end
function WorkerService:StartAttack(player: Player)
	local function lookCrate(root, attachmentRef)
		local targetPos = attachmentRef.WorldPosition
		local currentPos = root.Position

		-- Mantém a mesma altura Y, se quiser que ele só gire horizontalmente
		targetPos = Vector3.new(targetPos.X, currentPos.Y, targetPos.Z)

		root.CFrame = CFrame.lookAt(currentPos, targetPos)
	end

	local function updateCrateBillboardGui(crate: Model)
		local center = crate.Center
		local billboardGui = center.BillboardGui
		local textLabel = billboardGui.Frame.TextLabel

		local currentXp = crate:GetAttribute("CURRENT_XP")
		local maxXp = crate:GetAttribute("MAX_XP")

		textLabel.Text = currentXp .. "/" .. maxXp
	end

	local function attackCreate(attackValue: number, desk: Model)
		local crate = workspace.Runtime[player.UserId].Crates:FindFirstChild(desk.Name)

		if crate then
			local current = crate:GetAttribute("CURRENT_XP")
			local newCurrent = current - attackValue

			if newCurrent <= 0 then
				crate:Destroy()

				WorkerService:CreateBrainrot(player, crate:GetAttribute("CRATE_TYPE"), desk.Ref)
				desk:SetAttribute("BUSY", false)
				return
			end
			crate:SetAttribute("CURRENT_XP", newCurrent)

			updateCrateBillboardGui(crate)
		end
	end

	local plots = workspace:WaitForChild("Map"):WaitForChild("Plots")
	local plot = plots:WaitForChild(player:GetAttribute("BASE"))
	local dummy = plot:WaitForChild("Main"):WaitForChild("Worker"):WaitForChild("Dummy")
	local desks = plot:WaitForChild("Main"):WaitForChild("Worker"):WaitForChild("Desks")
	local root = dummy:FindFirstChild("HumanoidRootPart")

	if dummy:GetAttribute("ANIMATION_ON") then
		return
	end

	if not animations[dummy] then
		local humanoid = dummy:WaitForChild("Humanoid")
		local animation = ReplicatedStorage.Animations.Attack
		local track = humanoid:LoadAnimation(animation)

		animations[dummy] = track
	end

	while WorkerService:HasCrate(player) do
		dummy:SetAttribute("ANIMATION_ON", true)

		for _, value in desks:GetChildren() do
			if value:GetAttribute("BUSY") then
				local attachmentRef = value:FindFirstChild("Ref")
				lookCrate(root, attachmentRef)

				animations[dummy]:Play()
				animations[dummy].Stopped:Wait()
				attackCreate(10, value)

				task.wait(0.5)
			end
		end
	end

	dummy:SetAttribute("ANIMATION_ON", false)
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
	local brainrotType = CrateService:DrawBrainrotFromCrate(crateType)

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

		-- Destroy o Brainrot
		task.wait(1)
		newBrainrot:Destroy()
		-- Coloca no slot
		PlotService:Set(player, brainrotType)
	end
end

function WorkerService:HasCrate(player: Player)
	local plots = workspace:WaitForChild("Map"):WaitForChild("Plots")
	local plot = plots:WaitForChild(player:GetAttribute("BASE"))
	local dummy = plot:WaitForChild("Main"):WaitForChild("Worker"):WaitForChild("Dummy")
	local desks = plot:WaitForChild("Main"):WaitForChild("Worker"):WaitForChild("Desks")

	for _, value in desks:GetChildren() do
		if value:GetAttribute("BUSY") then
			return true
		end
	end

	return false
end

function WorkerService:SetCrate(player: Player, crateType: string, deskNumber: string)
	local function updateCrateBillboardGui(crate: Model)
		local center = crate.Center
		local billboardGui = center.BillboardGui
		local textLabel = billboardGui.Frame.TextLabel

		local currentXp = crate:GetAttribute("CURRENT_XP")
		local maxXp = crate:GetAttribute("MAX_XP")

		textLabel.Text = currentXp .. "/" .. maxXp
	end

	local crateEnum = Crate.CRATES[crateType]
	local plots = workspace:WaitForChild("Map"):WaitForChild("Plots")
	local plot = plots:WaitForChild(player:GetAttribute("BASE"))
	local dummy = plot:WaitForChild("Main"):WaitForChild("Worker"):WaitForChild("Dummy")
	local desks = plot:WaitForChild("Main"):WaitForChild("Worker"):WaitForChild("Desks")

	for _, value in desks:GetChildren() do
		if not value:GetAttribute("BUSY") then
			local crate = ReplicatedStorage.Model.Crates:FindFirstChild(crateType):Clone()
			crate.Name = deskNumber
			crate.Parent = workspace.Runtime[player.UserId].Crates

			crate:SetAttribute("MAX_XP", crateEnum.XPToOpen)
			crate:SetAttribute("CURRENT_XP", crateEnum.XPToOpen)
			crate:SetAttribute("CRATE_TYPE", crateType)

			crate:SetPrimaryPartCFrame(CFrame.new(value:FindFirstChild("Ref").WorldPosition))

			updateCrateBillboardGui(crate)
			value:SetAttribute("BUSY", true)
			return
		end
	end
end

return WorkerService
