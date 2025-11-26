local AnimationController = {}

local Players = game:GetService("Players")

local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)

function AnimationController:Init()
	AnimationController:StartRigSellShopAnimation()
	AnimationController:StartRigCrateShopAnimation()
	AnimationController:StartChairSellShopAnimation()
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

function AnimationController:StartRigSellShopAnimation()
	local rig = ClientUtil:WaitForDescendants(workspace, "Map", "Booths", "CrateAndSell", "SellShop", "Rig")
	local humanoid = rig:FindFirstChildWhichIsA("Humanoid")

	local Animation = Instance.new("Animation")
	Animation.AnimationId = "rbxassetid://118865039033792"

	-- 3) Cria o AnimationTrack
	local track = humanoid:LoadAnimation(Animation)

	-- 4) Roda a animação
	track:Play()
	print("Rodando animçaõ")
end

function AnimationController:StartChairSellShopAnimation()
	local function playAnimation(chair)
		local animationController = chair:WaitForChild("AnimationController")
		local animator = animationController:WaitForChild("Animator")
		local animation = animationController.Animation

		local animationTrack = animator:LoadAnimation(animation)
		animationTrack:Play()
	end

	local chair = ClientUtil:WaitForDescendants(workspace, "Map", "Booths", "CrateAndSell", "SellShop", "Chair")
	playAnimation(chair)
end

return AnimationController
