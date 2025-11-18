local FTUEController = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("FTUEService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)

local PADDING = 5 -- aumenta 10 pixels em cada lado

local myBaseButton
local crateShopButton
local upgradeShopButton
local frameBuyCrateFTUE
local ftueFocus
local ftueFinger
local buyCrateButton
local crateCloseButton
local placeAllButton
local ftueStep
local ftueStepText

local orderedSteps = {
	"INIT",
	"GO_TO_CRATE_SHOP_UI",
	"OPEN_SHOP_UI",
	"CLICK_SHOW_BUTTON_CRATES",
	"CLICK_BUY_BUTTON",
	"GO_TO_BASE",
	"PLACE_CRATE",
	"WAITING_FOR_BREAK_CRATE",
}

local steps = {}
local currentIndex = 0
local currentStepKey = nil

function FTUEController:Init(data)
	FTUEController:CreateReferences()
	FTUEController:InitListeners()
	FTUEController:StartFTUE(data)
end

function FTUEController:InitListeners()
	crateShopButton.MouseButton1Click:Connect(function()
		FTUEController:TryExecuteFTUE("GO_TO_CRATE_SHOP_UI")
	end)

	buyCrateButton.MouseButton1Click:Connect(function()
		FTUEController:TryExecuteFTUE("CLICK_BUY_BUTTON")
	end)

	crateCloseButton.MouseButton1Click:Connect(function()
		FTUEController:TryExecuteFTUE("GO_TO_BASE")
	end)

	myBaseButton.MouseButton1Click:Connect(function()
		FTUEController:TryExecuteFTUE("PLACE_CRATE")
	end)

	placeAllButton.MouseButton1Click:Connect(function()
		FTUEController:TryExecuteFTUE("WAITING_FOR_BREAK_CRATE")
	end)

	local proximityPart =
		ClientUtil:WaitForDescendants(workspace, "Map", "Booths", "CrateAndSell", "CrateShop", "ProximityPromptPart")

	local proximityPrompt = proximityPart.ProximityPrompt

	proximityPrompt.PromptShown:Connect(function()
		FTUEController:TryExecuteFTUE("OPEN_SHOP_UI")
	end)
end

function FTUEController:ShowFTUEStep(text: string)
	ftueStepText.Text = text
	ftueStep.Visible = true
end

function FTUEController:HideFTUEStep()
	ftueStep.Visible = false
end
-- Avança obrigatoriamente na ordem
function FTUEController:RunNextStep()
	currentIndex += 1

	currentStepKey = orderedSteps[currentIndex]
	if not currentStepKey then
		print("FTUE concluído")
		return
	end

	local fn = steps[currentStepKey]
	if fn then
		fn()
	end
end

-- Só executa se estiver na vez certa
function FTUEController:TryExecuteFTUE(stepName)
	if not orderedSteps[currentIndex + 1] then
		return
	end

	if stepName ~= orderedSteps[currentIndex + 1] then
		-- Clicou fora de ordem → ignora totalmente
		return
	end

	-- Step confirmado → vai para o próximo da lista
	FTUEController:RunNextStep()
end

function FTUEController:StartFTUE(data)
	-- STEPS DE VERDADE -----------

	ClientUtil:WaitForDescendants(workspace, "Map", "Booths", "CrateAndSell", "CrateShop", "BasePart")

	steps["INIT"] = function()
		FTUEController:ShowFTUEStep("Go To Crate Shop")
		FTUEController:FocusOnTarget(ftueFocus, crateShopButton)

		FTUEController:AttachFingerToTarget(ftueFinger, crateShopButton, Vector2.new(0.2, 0.9))

		FTUEController:CreateBeamToModel(
			ClientUtil:WaitForDescendants(workspace, "Map", "Booths", "CrateAndSell", "CrateShop")
		)
	end

	steps["GO_TO_CRATE_SHOP_UI"] = function()
		FTUEController:ShowFTUEStep("Open Shop")
		FTUEController:CloseFocus(ftueFocus)
		FTUEController:StopFingerAnimations(ftueFinger)
	end

	steps["OPEN_SHOP_UI"] = function()
		FTUEController:HideFTUEStep()
		while not player:GetAttribute("CRATE_SHOP_SCREEN_LOADED") do
			print("Aguardando")
			task.wait()
		end
		FTUEController:CloseBeam()
		FTUEController:AttachFingerToTarget(ftueFinger, frameBuyCrateFTUE, Vector2.new(0.2, 0))
	end

	steps["CLICK_SHOW_BUTTON_CRATES"] = function()
		FTUEController:HideFTUEStep()
		FTUEController:TweenToTarget(ftueFinger, buyCrateButton, 0.5)
	end

	steps["CLICK_BUY_BUTTON"] = function()
		FTUEController:HideFTUEStep()
		FTUEController:TweenToTarget(ftueFinger, crateCloseButton, 0.5)
	end

	steps["GO_TO_BASE"] = function()
		FTUEController:ShowFTUEStep("Go To Your Base")
		FTUEController:FocusOnTarget(ftueFocus, myBaseButton)
		FTUEController:AttachFingerToTarget(ftueFinger, myBaseButton, Vector2.new(0.2, 0.9))
	end

	steps["PLACE_CRATE"] = function()
		FTUEController:ShowFTUEStep("Place A Crate")
		local baseNumber = player:GetAttribute("BASE")
		local base = ClientUtil:WaitForDescendants(workspace, "Map", "Plots", baseNumber)
		local proximityPart = ClientUtil:WaitForDescendants(base, "Main", "BreakersArea", "ProximityPart")

		FTUEController:CloseFocus(ftueFocus)
		FTUEController:StopFingerAnimations(ftueFinger)

		FTUEController:CreateBeamToPart(proximityPart)
		FTUEController:AttachFingerToTarget(ftueFinger, placeAllButton, Vector2.new(0.2, 0.9))
	end

	steps["WAITING_FOR_BREAK_CRATE"] = function()
		FTUEController:ShowFTUEStep("Waiting for break Crate")
		FTUEController:StopFingerAnimations(ftueFinger)
		FTUEController:CloseBeam()
	end

	FTUEController:RunNextStep()
end

function FTUEController:CreateReferences()
	ftueFocus = UIReferences:GetReference("FTUE_FOCUS")
	myBaseButton = UIReferences:GetReference("MY_BASE_BUTTON")
	crateShopButton = UIReferences:GetReference("CRATE_SHOP_BUTTON")
	upgradeShopButton = UIReferences:GetReference("UPGRADES_SHOP_BUTTON")
	ftueFinger = UIReferences:GetReference("FTUE_FINGER")
	frameBuyCrateFTUE = UIReferences:GetReference("FRAME_BUY_CRATE_FTUE")
	buyCrateButton = UIReferences:GetReference("BUY_CRATE_BUTTON")
	crateCloseButton = UIReferences:GetReference("CRATE_CLOSE_BUTTON")
	placeAllButton = UIReferences:GetReference("PLACE_ALL_BUTTON")
	ftueStep = UIReferences:GetReference("FTUE_STEP")
	ftueStepText = UIReferences:GetReference("FTUE_STEP_TEXT")
end

-----------------------------------------------------
-- MÉTODOS UTILITARIOS
-----------------------------------------------------
function FTUEController:FocusOnTarget(focusFrame: Frame, targetUI: GuiObject)
	if not focusFrame or not targetUI then
		return
	end

	local absSize = targetUI.AbsoluteSize
	local newSize = UDim2.fromOffset(absSize.X + (PADDING * 4), absSize.Y + (PADDING * 4))

	focusFrame.Parent = targetUI
	focusFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	focusFrame.Position = UDim2.fromScale(0.5, 0.5)
	focusFrame.Size = newSize
	focusFrame.Visible = true
end

function FTUEController:CloseFocus(focusFrame: Frame)
	focusFrame.Visible = false
end
function FTUEController:TweenToTarget(focusFrame: Frame, newTarget: GuiObject, duration: number)
	if not focusFrame or not newTarget then
		return
	end

	-- salva posi��o/tamanho atuais
	local oldAbsPos = focusFrame.AbsolutePosition
	local oldAbsSize = focusFrame.AbsoluteSize

	-- reparenta sem mexer visualmente
	local newParent = newTarget
	local newParentAbsPos = newParent.AbsolutePosition

	focusFrame.Parent = newParent
	focusFrame.Position = UDim2.fromOffset(oldAbsPos.X - newParentAbsPos.X, oldAbsPos.Y - newParentAbsPos.Y)
	focusFrame.Size = UDim2.fromOffset(oldAbsSize.X, oldAbsSize.Y)

	-- calcula destino com padding fixo
	local newAbsPos = newTarget.AbsolutePosition
	local newAbsSize = newTarget.AbsoluteSize

	local targetPos = UDim2.fromOffset(
		(newAbsPos.X - newParentAbsPos.X) + newAbsSize.X / 2,
		(newAbsPos.Y - newParentAbsPos.Y) + newAbsSize.Y / 2
	)
	local targetSize = UDim2.fromOffset(newAbsSize.X + (PADDING * 2), newAbsSize.Y + (PADDING * 2))

	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(focusFrame, tweenInfo, {
		Position = targetPos,
		Size = targetSize,
	})

	tween:Play()

	tween.Completed:Connect(function()
		focusFrame.Position = UDim2.fromScale(0.5, 0.5)
		focusFrame.Size = targetSize
	end)
end

function FTUEController:CreateBeamToPart(targetPart: BasePart)
	if not player or not targetPart then
		warn("FTUEController.CreateBeamToPart: parâmetros inválidos.")
		return
	end

	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	-- 1) Pega o attachment do jogador (UpperTorso > Torso > HumanoidRootPart)
	local character = player.Character or player.CharacterAdded:Wait()
	local torso = character:FindFirstChild("UpperTorso")
		or character:FindFirstChild("Torso")
		or character:WaitForChild("HumanoidRootPart")

	local sourceAttachment = torso:FindFirstChild("FTUE_BeamSource")
	if not sourceAttachment then
		sourceAttachment = Instance.new("Attachment")
		sourceAttachment.Name = "FTUE_BeamSource"
		sourceAttachment.Parent = torso
	end

	-- 2) Cria (ou reutiliza) o attachment de destino dentro da Part
	local targetAttachment = targetPart:FindFirstChild("FTUE_BeamTarget")
	if not targetAttachment then
		targetAttachment = Instance.new("Attachment")
		targetAttachment.Name = "FTUE_BeamTarget"
		targetAttachment.Parent = targetPart
	end

	-- 3) Ajusta a posição do attachment destino
	-- Aqui fica exatamente no centro da Part.
	-- Pode trocar para qualquer offset com: targetAttachment.Position = Vector3.new(...)
	targetAttachment.Position = Vector3.new(0, 0, 0)

	-- 4) Pega BeamTemplate e conecta
	local beamTemplate = ReplicatedStorage:WaitForChild("BeamTemplate")
	local beam = beamTemplate:Clone()
	beam.Name = "FTUE_Beam"
	beam.Attachment0 = sourceAttachment
	beam.Attachment1 = targetAttachment
	beam.Parent = torso

	return beam, sourceAttachment, targetAttachment
end

function FTUEController:CreateBeamToModel(targetModel: Model)
	if not player or not targetModel then
		warn("FTUEFocus.CreateBeamToModel: par�metros inv�lidos.")
		return
	end

	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	-- 1) Pega o attachment do jogador (UpperTorso > Torso > HumanoidRootPart)
	local character = player.Character or player.CharacterAdded:Wait()
	local torso = character:FindFirstChild("UpperTorso")
		or character:FindFirstChild("Torso")
		or character:WaitForChild("HumanoidRootPart")

	local sourceAttachment = torso:FindFirstChild("FTUE_BeamSource")
	if not sourceAttachment then
		sourceAttachment = Instance.new("Attachment")
		sourceAttachment.Name = "FTUE_BeamSource"
		sourceAttachment.Parent = torso
	end

	-- 2) Centro do model via BoundingBox
	local bboxCFrame, _bboxSize = targetModel:GetBoundingBox()

	-- 3) Escolhe um part base para ancorar o attachment (PrimaryPart > qualquer BasePart)
	local basePart = targetModel.PrimaryPart or targetModel:FindFirstChild("BasePart", true)
	if not basePart then
		warn("FTUEFocus.CreateBeamToModel: targetModel n�o tem BasePart.")
		return
	end

	-- 4) Converte o centro do model para o espa�o do part
	local relative = basePart.CFrame:ToObjectSpace(bboxCFrame)

	-- 5) Cria (ou reutiliza) o attachment de destino exatamente no centro do model
	local targetAttachment = basePart:FindFirstChild("FTUE_BeamTarget")
	if not targetAttachment then
		targetAttachment = Instance.new("Attachment")
		targetAttachment.Name = "FTUE_BeamTarget"
		targetAttachment.Parent = basePart
	end
	targetAttachment.CFrame = relative

	-- 6) Pega a BeamTemplate do ReplicatedStorage e liga as pontas
	local beamTemplate = ReplicatedStorage:WaitForChild("BeamTemplate")
	local beam = beamTemplate:Clone()
	beam.Name = "FTUE_Beam"
	beam.Attachment0 = sourceAttachment
	beam.Attachment1 = targetAttachment
	beam.Parent = torso

	return beam, sourceAttachment, targetAttachment
end

function FTUEController:CloseBeam()
	local character = player.Character or player.CharacterAdded:Wait()
	local torso = character:FindFirstChild("UpperTorso")
		or character:FindFirstChild("Torso")
		or character:WaitForChild("HumanoidRootPart")

	local ftueBeam = torso:FindFirstChild("FTUE_Beam")

	if ftueBeam then
		ftueBeam:Destroy()
	end
end

-- Helper: cria tween loop
local function CreateLoopTween(instance, time, goal)
	local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true)
	local tween = TweenService:Create(instance, tweenInfo, goal)
	tween:Play()
	return tween
end

-- Coloca o dedo no target e centraliza pela ponta, animando o pulsar
function FTUEController:AttachFingerToTarget(fingerFrame: Frame, targetUI: GuiObject, offset: Vector2?)
	if not fingerFrame or not targetUI then
		warn("FTUEFocus.AttachFingerToTarget: par�metros inv�lidos.")
		return
	end

	-- Offset padr�o (sem ajuste)
	offset = offset or Vector2.new(0, 0)

	fingerFrame.Parent = targetUI
	fingerFrame.AnchorPoint = fingerFrame.AnchorPoint or Vector2.new(0.5, 0.5)

	-- Centraliza com o offset (permite alinhar a ponta)
	fingerFrame.Position = UDim2.fromScale(0.5 + offset.X, 0.5 + offset.Y)
	fingerFrame.Visible = true

	-- Anima��o de pulsar
	CreateLoopTween(fingerFrame, 0.6, {
		Size = fingerFrame.Size + UDim2.fromScale(0.1, 0.1),
	})
end

-- Anima��o 2: dedo apontando (movimento vertical)
function FTUEController:AnimateFingerBounce(fingerFrame: Frame)
	if not fingerFrame then
		return
	end
	return CreateLoopTween(fingerFrame, 0.5, {
		Position = fingerFrame.Position + UDim2.fromScale(0, 0.05),
	})
end

-- Para anima��es do dedo
function FTUEController:StopFingerAnimations(fingerFrame: Frame)
	if not fingerFrame then
		return
	end
	for _, tween in pairs(fingerFrame:GetDescendants()) do
		if tween:IsA("Tween") then
			tween:Cancel()
		end
	end
	fingerFrame.Visible = false
end

return FTUEController
