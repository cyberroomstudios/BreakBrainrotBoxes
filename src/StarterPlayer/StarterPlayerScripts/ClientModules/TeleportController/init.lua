local TeleportController = {}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

function TeleportController:Init() end

function TeleportController:ToBase()
	local spawnCFrame = player:GetAttribute("BASE_CFRAME")

	local character = player.Character

	if spawnCFrame and character and character:FindFirstChild("HumanoidRootPart") then
		character.HumanoidRootPart.CFrame = spawnCFrame
	end
end

function TeleportController:ToCrateStore()
	local spawnCFrame = player:GetAttribute("CRATE_SHOP_CFRAME")

	local character = player.Character

	if spawnCFrame and character and character:FindFirstChild("HumanoidRootPart") then
		character.HumanoidRootPart.CFrame = spawnCFrame
	end
end

function TeleportController:ToUpgradeShop()
	local spawnCFrame = player:GetAttribute("UPGRADE_SHOP_CFRAME")

	local character = player.Character

	if spawnCFrame and character and character:FindFirstChild("HumanoidRootPart") then
		character.HumanoidRootPart.CFrame = spawnCFrame
	end
end

return TeleportController
