local RotateOffersController = {}
local RunService = game:GetService("RunService")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)

local startBurst
local rotateOfferSahur
local rotateOfferSahurContent

function RotateOffersController:Init()
	RotateOffersController:CreateReferences()
	RotateOffersController:ConfigureSahurAnimation()
	RotateOffersController:ConfigureStartBurst()
end

function RotateOffersController:CreateReferences()
	startBurst = UIReferences:GetReference("START_BURST")
	rotateOfferSahur = UIReferences:GetReference("ROTATE_OFFER_SAHUR")
	rotateOfferSahurContent = UIReferences:GetReference("ROTATE_OFFER_SAHUR_CONTENT")
end

function RotateOffersController:ConfigureStartBurst()
	local rotationSpeed = 30 -- Graus por segundo
	RunService.RenderStepped:Connect(function(deltaTime)
		startBurst.Rotation = startBurst.Rotation + rotationSpeed * deltaTime
		if startBurst.Rotation >= 360 then
			startBurst.Rotation = startBurst.Rotation - 360
		end
	end)
end

function RotateOffersController:ConfigureSahurAnimation()
	local ui = rotateOfferSahurContent -- sua ImageLabel ou Frame
	local minScale = 0.9 -- menor tamanho
	local maxScale = 1.1 -- maior tamanho
	local speed = 0.2 -- velocidade da animação

	local direction = 1 -- 1 = crescendo, -1 = diminuindo

	-- garante que existe UIScale
	local scale = ui:FindFirstChild("UIScale")
	if not scale then
		scale = Instance.new("UIScale")
		scale.Scale = 1
		scale.Parent = ui
	end

	RunService.RenderStepped:Connect(function(dt)
		scale.Scale += direction * speed * dt

		if scale.Scale >= maxScale then
			scale.Scale = maxScale
			direction = -1
		elseif scale.Scale <= minScale then
			scale.Scale = minScale
			direction = 1
		end
	end)

	local sahur = ClientUtil:WaitForDescendants(rotateOfferSahur, "Breaker", "WorldModel", "Sahur")
	local animationController = sahur:WaitForChild("AnimationController")
	local animator = animationController:WaitForChild("Animator")
	local animation = ReplicatedStorage.Animations.Breakers.Sahur.Idle

	local animationTrack = animator:LoadAnimation(animation)
	animationTrack:Play()
end

return RotateOffersController
