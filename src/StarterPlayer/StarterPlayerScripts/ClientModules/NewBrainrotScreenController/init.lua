local NewBrainrotScreenController = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local ConfettiController = require(Players.LocalPlayer.PlayerScripts.ClientModules.ConfettiController)

local screen

function NewBrainrotScreenController:Init()
	NewBrainrotScreenController:CreateReferences()
end

function NewBrainrotScreenController:CreateReferences()
	screen = UIReferences:GetReference("NEW_GAME")
end

function NewBrainrotScreenController:Open(data)
	local brainrotType = data.BrainrotType

	screen.Visible = true
	NewBrainrotScreenController:PlayTween(brainrotType)

	task.delay(3, function()
		local UIStateManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.UIStateManager)
		UIStateManager:Close("NEW_GAME")
	end)
end

function NewBrainrotScreenController:Close()
	screen.Visible = false
end

function NewBrainrotScreenController:GetScreen()
	return screen
end

function NewBrainrotScreenController:PlayTween(brainrotType: string)
	local frame = screen
	frame.Content.Visible = false

	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.Size = UDim2.new(0.1, 0, 0.2, 0) -- só altura definida

	-- Configurações do tween
	local tweenInfo = TweenInfo.new(
		0.3, -- duração em segundos
		Enum.EasingStyle.Quad, -- estilo da animação
		Enum.EasingDirection.Out, -- direção da animação
		0, -- quantas vezes repetir
		false, -- reverso?
		0 -- delay
	)

	-- Tamanho final: largura cheia no eixo X
	local goal = { Size = UDim2.new(1, 0, 0.2, 0) }

	task.spawn(function()
		--	ConfettiController:CreateConfetti()
	end)

	-- Criar e tocar o tween
	local tween = TweenService:Create(frame, tweenInfo, goal)

	tween:Play()
	task.wait(0.3)
	frame.Content.Visible = true
end

return NewBrainrotScreenController
