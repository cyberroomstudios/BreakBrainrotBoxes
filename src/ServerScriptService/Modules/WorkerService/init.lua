local WorkerService = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("WorkerService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local Crate = require(ReplicatedStorage.Enums.Crate)

local animations = {}

function WorkerService:Init()
	WorkerService:InitBridgeListener()
end

function WorkerService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "PlaceAll" then
			print("PlaceAll")
			WorkerService:SetCrate(player, "Cardboard", 1)
			WorkerService:SetCrate(player, "Concrete", 2)
			WorkerService:StartAttack(player)
		end

		if data[actionIdentifier] == "PlaceThis" then
			print("PlaceThis")
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
	if not animations[dummy] then
		local humanoid = dummy:WaitForChild("Humanoid")
		local animation = ReplicatedStorage.Animations.Attack
		local track = humanoid:LoadAnimation(animation)

		animations[dummy] = track
	end

	while WorkerService:HasCrate(player) do
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
			local crate = ReplicatedStorage.Model.Crates:FindFirstChild(crateType)
			crate.Name = deskNumber
			crate.Parent = workspace.Runtime[player.UserId].Crates

			crate:SetAttribute("MAX_XP", crateEnum.XPToOpen)
			crate:SetAttribute("CURRENT_XP", crateEnum.XPToOpen)

			crate:SetPrimaryPartCFrame(CFrame.new(value:FindFirstChild("Ref").WorldPosition))

			updateCrateBillboardGui(crate)
			value:SetAttribute("BUSY", true)
			return
		end
	end
end

return WorkerService
