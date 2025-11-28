local TeleportController = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("FunnelService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

function TeleportController:Init() end

function TeleportController:SendFunnelEvent(eventName: string)
	task.spawn(function()
		if player:GetAttribute("FUNNEL_" .. eventName) then
			return
		end

		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "AddEvent",
			data = { Name = eventName },
		})
	end)
end

function TeleportController:ToBase(shouldLogFunnelEvent: boolean)
	local spawnCFrame = player:GetAttribute("BASE_CFRAME")
	local lookPosition = player:GetAttribute("BASE_LOOK_POSITION")

	local character = player.Character

	if spawnCFrame and character and character:FindFirstChild("HumanoidRootPart") then
		local hrp = character.HumanoidRootPart

		-- Posição de onde ele deve aparecer
		local spawnPos = spawnCFrame.Position

		-- Faz ele olhar para o lockPart
		local lookCFrame = CFrame.lookAt(spawnPos, lookPosition)

		hrp.CFrame = lookCFrame

		local camera = workspace.CurrentCamera
		camera.CameraType = Enum.CameraType.Custom
		camera.CFrame = lookCFrame

		if shouldLogFunnelEvent then
			TeleportController:SendFunnelEvent("TO_BASE")
		end
		
	end
end

function TeleportController:ToCrateStore()
	local spawnCFrame = player:GetAttribute("CRATE_SHOP_CFRAME")
	local lookPosition = player:GetAttribute("CRATE_SHOP_LOOK_POSITION")

	local character = player.Character

	if spawnCFrame and character and character:FindFirstChild("HumanoidRootPart") then
		local hrp = character.HumanoidRootPart

		-- Posição de onde ele deve aparecer
		local spawnPos = spawnCFrame.Position

		-- Faz ele olhar para o lockPart
		local lookCFrame = CFrame.lookAt(spawnPos, lookPosition)

		hrp.CFrame = lookCFrame

		local camera = workspace.CurrentCamera
		camera.CameraType = Enum.CameraType.Custom
		camera.CFrame = lookCFrame

		TeleportController:SendFunnelEvent("TO_CRATE")
	end
end

function TeleportController:ToUpgradeShop()
	local spawnCFrame = player:GetAttribute("UPGRADE_SHOP_CFRAME")

	local character = player.Character

	if spawnCFrame and character and character:FindFirstChild("HumanoidRootPart") then
		character.HumanoidRootPart.CFrame = spawnCFrame
		TeleportController:SendFunnelEvent("TO_UPGRADE")
	else
		warn("Não Conseguiu ir para o Upgrade Area")
	end
end

return TeleportController
