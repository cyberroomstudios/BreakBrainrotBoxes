local AnimationController = {}

local Players = game:GetService("Players")

local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)

function AnimationController:Init()
	AnimationController:StartRigCrateShopAnimation()
end

function AnimationController:StartRigCrateShopAnimation()
	local rig = ClientUtil:WaitForDescendants(workspace, "Map", "Booths", "CrateAndSell", "CrateShop", "Rig")
	local humanoid = rig:FindFirstChildWhichIsA("Humanoid")

	local Animation = Instance.new("Animation")
	Animation.AnimationId = "rbxassetid://91218327763759"

	-- 3) Cria o AnimationTrack
	local track = humanoid:LoadAnimation(Animation)

	-- 4) Roda a animação
	track:Play()
end

return AnimationController
