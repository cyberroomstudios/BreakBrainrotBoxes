local RotateOffersController = {}
local RunService = game:GetService("RunService")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)
local DeveloperProductController = require(Players.LocalPlayer.PlayerScripts.ClientModules.DeveloperProductController)

local rotateContent
local startBurst
local rotateOfferSahur
local rotateOfferCrate

local rotateOfferSahurContent
local rotateOfferCrateContent

function RotateOffersController:Init()
	RotateOffersController:CreateReferences()
	RotateOffersController:ConfigurePosition()
	RotateOffersController:ConfigureSahurAnimation()
	RotateOffersController:ConfigureStartBurst()
	RotateOffersController:InitButtonListerns()
	RotateOffersController:ConfigurePulseAnimation()
end

function RotateOffersController:ConfigurePosition()
	local isMobile = UserInputService.TouchEnabled
		and not UserInputService.KeyboardEnabled
		and not UserInputService.MouseEnabled

	if isMobile then
		rotateContent.Position = UDim2.fromScale(0.785, 0.211)
	else
		rotateContent.Position = UDim2.fromScale(-0.025, 0.05)
	end
end

function RotateOffersController:InitButtonListerns()
	rotateOfferSahurContent.MouseButton1Click:Connect(function()
		DeveloperProductController:OpenPaymentRequestScreen("SAHUR_BREAKER")
	end)

	rotateOfferCrateContent.MouseButton1Click:Connect(function()
		DeveloperProductController:OpenPaymentRequestScreen("OP_CRATE")
	end)
end

function RotateOffersController:CreateReferences()
	rotateContent = UIReferences:GetReference("ROTATE_CONTENT")
	startBurst = UIReferences:GetReference("START_BURST")
	rotateOfferSahur = UIReferences:GetReference("ROTATE_OFFER_SAHUR")
	rotateOfferCrate = UIReferences:GetReference("ROTATE_OFFER_CRATE")

	rotateOfferSahurContent = UIReferences:GetReference("ROTATE_OFFER_SAHUR_CONTENT")
	rotateOfferCrateContent = UIReferences:GetReference("ROTATE_OFFER_CRATE_CONTENT")
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

function RotateOffersController:ConfigurePulseAnimation()
	task.spawn(function()
		local uiList = {
			rotateOfferSahurContent,
			rotateOfferCrateContent,
		}
		local minScale = 0.9
		local maxScale = 1.1
		local speed = 0.2
		local pulseTime = 10 -- segundos que cada UI pulsa

		-- Deixa TODAS invisíveis antes de começar
		for _, ui in ipairs(uiList) do
			ui.Visible = false

			local scale = ui:FindFirstChild("UIScale")
			if not scale then
				scale = Instance.new("UIScale")
				scale.Scale = 0
				scale.Parent = ui
			else
				scale.Scale = 0
			end
		end

		while true do
			for _, ui in ipairs(uiList) do
				------------------------------------------
				-- Ativar UI atual
				------------------------------------------
				ui.Visible = true
				local scale = ui.UIScale
				scale.Scale = 0

				------------------------------------------
				-- ANIMAÇÃO: crescer de 0 até 1 (aparecer)
				------------------------------------------
				local appearTween = TweenService:Create(
					scale,
					TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ Scale = 1 }
				)
				appearTween:Play()
				appearTween.Completed:Wait()

				------------------------------------------
				-- INICIAR PULSAÇÃO
				------------------------------------------
				local direction = 1
				local timePassed = 0

				local pulseConn
				pulseConn = RunService.RenderStepped:Connect(function(dt)
					timePassed += dt

					scale.Scale += direction * speed * dt

					if scale.Scale >= maxScale then
						scale.Scale = maxScale
						direction = -1
					elseif scale.Scale <= minScale then
						scale.Scale = minScale
						direction = 1
					end

					if timePassed >= pulseTime then
						pulseConn:Disconnect()
					end
				end)

				-- espera a pulsação terminar
				task.wait(pulseTime)

				------------------------------------------
				-- ANIMAÇÃO: diminuir até 0 (sumir)
				------------------------------------------
				local hideTween = TweenService:Create(
					scale,
					TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{ Scale = 0 }
				)
				hideTween:Play()
				hideTween.Completed:Wait()

				ui.Visible = false -- some após encolher
			end
		end
	end)
end

function RotateOffersController:ConfigureSahurAnimation()
	local function playAnimation(sahur)
		local animationController = sahur:WaitForChild("AnimationController")
		local animator = animationController:WaitForChild("Animator")
		local animation = ReplicatedStorage.Animations.Breakers.Sahur.Idle

		local animationTrack = animator:LoadAnimation(animation)
		animationTrack:Play()
	end

	playAnimation(ClientUtil:WaitForDescendants(rotateOfferSahur, "Breaker", "WorldModel", "Sahur"))
	playAnimation(ClientUtil:WaitForDescendants(rotateOfferSahur, "Shadow", "WorldModel", "Sahur"))
end

return RotateOffersController
