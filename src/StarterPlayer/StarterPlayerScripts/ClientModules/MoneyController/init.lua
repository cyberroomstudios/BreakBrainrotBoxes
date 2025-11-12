local MoneyController = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("MoneyService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local Players = game:GetService("Players")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)
local SoundManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.SoundManager)

local player = Players.LocalPlayer

local moneyLabel
local historyMoney
local oldMoney = nil

local contentAutoCollect
local timeAutoCollect

function MoneyController:Init(data)
	MoneyController:CreateReferences()
	MoneyController:InitAttributeListener()
	MoneyController:StartMoney(data.money)
end

function MoneyController:CreateReferences()
	-- Botões referente as Tools
	moneyLabel = UIReferences:GetReference("MONEY")
	historyMoney = UIReferences:GetReference("HISTORY_MONEY")
	contentAutoCollect = UIReferences:GetReference("CONTENT_AUTO_COLLECT")
	timeAutoCollect = UIReferences:GetReference("TIME_AUTO_COLLECT")
end

function MoneyController:StartMoney(money: number)
	moneyLabel.Text = ClientUtil:FormatToUSD(money)
end

function MoneyController:InitAttributeListener()
	player:GetAttributeChangedSignal("MONEY"):Connect(function()
		local money = player:GetAttribute("MONEY")

		if oldMoney and oldMoney < money then
			local diference = money - oldMoney
			MoneyController:AddHistory(true, diference)
		end

		if oldMoney and oldMoney > money then
			local diference = oldMoney - money
			MoneyController:AddHistory(false, diference)
		end

		oldMoney = money
		moneyLabel.Text = ClientUtil:FormatToUSD(money)
	end)

	player:GetAttributeChangedSignal("TIME_TO_AUTO_COLLECT"):Connect(function()
		local timeToAutoCollect = player:GetAttribute("TIME_TO_AUTO_COLLECT")
		timeAutoCollect.Text = timeToAutoCollect
	end)
end

function MoneyController:AddHistory(positiveMoney, value)
	if positiveMoney then
		local positiveMoneyTextLabel = historyMoney.PositiveMoney:Clone()
		positiveMoneyTextLabel.Visible = true
		positiveMoneyTextLabel.Text = "+" .. ClientUtil:FormatToUSD(value)
		positiveMoneyTextLabel.Parent = historyMoney

		task.delay(1, function()
			positiveMoneyTextLabel.Visible = false
		end)
	else
		local negativeMoneyTextLabel = historyMoney.NegativeMoney:Clone()
		negativeMoneyTextLabel.Visible = true
		negativeMoneyTextLabel.Text = "-" .. ClientUtil:FormatToUSD(value)
		negativeMoneyTextLabel.Parent = historyMoney

		task.delay(1, function()
			negativeMoneyTextLabel.Visible = false
		end)
	end
end

function MoneyController:ToggleAutoCollect()
	contentAutoCollect.Visible = not contentAutoCollect.Visible
	timeAutoCollect.Visible = not timeAutoCollect.Visible

	local result = bridge:InvokeServerAsync({
		[actionIdentifier] = "ToggleAutoCollect",
	})
end

return MoneyController
