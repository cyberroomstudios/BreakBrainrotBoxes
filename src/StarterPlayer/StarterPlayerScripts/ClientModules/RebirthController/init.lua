local RebirthController = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("RebirthService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local Rebirths = require(ReplicatedStorage.Enums.Rebirths)
local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)
local Brainrots = require(ReplicatedStorage.Enums.Brainrots)
local ConfettiController = require(Players.LocalPlayer.PlayerScripts.ClientModules.ConfettiController)

local screen

local rebirthMoney
local rebirthBrainrots
local rebirthAwards
local getRebirthButton

function RebirthController:Init()
	RebirthController:CreateReferences()
	RebirthController:InitButtonListerns()
end

function RebirthController:CreateReferences()
	screen = UIReferences:GetReference("REBIRTH")
	rebirthMoney = UIReferences:GetReference("REBIRTH_MONEY")
	rebirthBrainrots = UIReferences:GetReference("REBIRTH_BRAINROTS")
	rebirthAwards = UIReferences:GetReference("REBIRTH_AWARDS")
	getRebirthButton = UIReferences:GetReference("GET_REBIRTH")
end

function RebirthController:Open(data)
	screen.Visible = true
	RebirthController:BuildScreen()
end

function RebirthController:Close()
	screen.Visible = false
end

function RebirthController:GetScreen()
	return screen
end

function RebirthController:InitButtonListerns()
	local UIStateManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.UIStateManager)

	getRebirthButton.MouseButton1Click:Connect(function()
		UIStateManager:Close("REBIRTH")
		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "GetRebirth",
			data = {},
		})

		if result then
			ConfettiController:CreateConfetti()
		end
	end)
end
function RebirthController:BuildScreen()
	local function cleanScreen()
		for _, value in rebirthBrainrots:GetDescendants() do
			if value:GetAttribute("TEMP") then
				value:Destroy()
			end
		end

		for _, value in rebirthAwards:GetDescendants() do
			if value:GetAttribute("TEMP") then
				value:Destroy()
			end
		end
	end
	local function buildRequirement(requirements)
		local currentBrainrotIndex = 1
		local viewPortFolder = ReplicatedStorage.GUI.ViewPortFrames:FindFirstChild("NORMAL")

		for _, requirement in requirements do
			if requirement.Type == "MONEY" then
				rebirthMoney.Text = ClientUtil:FormatToUSD(requirement.Amount)
				continue
			end
			local brainrotFrame = rebirthBrainrots:FindFirstChild(currentBrainrotIndex)

			if brainrotFrame then
				-- Pegando as informações do item
				local brainrotName = requirement.Name
				local brainrotEnum = Brainrots[brainrotName]

				-- Pegando a viewPort
				local viewPortTemplate = viewPortFolder:FindFirstChild(brainrotName):Clone()
				viewPortTemplate.Parent = brainrotFrame
				viewPortTemplate:SetAttribute("TEMP", true)

				-- Criando o Container com as informações
				local brainrotContaner = ReplicatedStorage.GUI.Rebirth.Requirements.InfoBrainrotRebirth:Clone()
				brainrotContaner.ItemName.Text = brainrotEnum.GUI.Label
				brainrotContaner:SetAttribute("TEMP", true)

				-- Raridade
				brainrotContaner.Rarity.Text = brainrotEnum.Rarity
				brainrotContaner.Rarity.TextColor3 = ReplicatedStorage.GUI.RarityColors[brainrotEnum.Rarity].Value
				brainrotContaner.Parent = brainrotFrame

				brainrotFrame.Visible = true
			end

			currentBrainrotIndex = currentBrainrotIndex + 1
		end
	end

	local function buildAwards(awards)
		local currentAwardsIndex = 1

		for _, award in awards do
			local awardFrame = rebirthAwards:FindFirstChild(currentAwardsIndex)
			if award.Type == "PLOT" then
				local plotFrame = ReplicatedStorage.GUI.Rebirth.Awards.UnlockPlot:Clone()
				plotFrame:SetAttribute("TEMP", true)
				plotFrame.Parent = awardFrame
			end

			if award.Type == "MONEY" then
				local moneyFrame = ReplicatedStorage.GUI.Rebirth.Awards.Money:Clone()
				moneyFrame:SetAttribute("TEMP", true)

				moneyFrame.TextLabel.Text = ClientUtil:FormatToUSD(award.Amount)
				moneyFrame.Parent = awardFrame
			end

			if award.Type == "CASH_MULTIPLIER" then
				local moneyFrame = ReplicatedStorage.GUI.Rebirth.Awards.CashMultiplier:Clone()
				moneyFrame:SetAttribute("TEMP", true)
				moneyFrame.CashMultiplier.Text = tostring(award.Amount) .. "x"
				moneyFrame.Parent = awardFrame
			end

			awardFrame.Visible = true
			currentAwardsIndex = currentAwardsIndex + 1
		end
	end
	local result = bridge:InvokeServerAsync({
		[actionIdentifier] = "GetInfoRebirth",
		data = {},
	})

	if not result then
		return
	end

	local requirements = result.Requirements
	local awards = result.Awards

	cleanScreen()
	buildRequirement(requirements)
	buildAwards(awards)
end

return RebirthController
