local TeleportController = {}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

function TeleportController:Init() end

function TeleportController:ToBase()
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
