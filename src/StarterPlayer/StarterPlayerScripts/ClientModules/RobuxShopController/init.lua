local Players = game:GetService("Players")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local DeveloperProductController = require(Players.LocalPlayer.PlayerScripts.ClientModules.DeveloperProductController)

local RobuxShopController = {}

local screen
local currentServerLuck
local nextServerLuck

-- ServerLuck
local buyServerLuck
local textBuyServerLuck
local currentDevProductServerLuck

-- Moneys
local buyMoneyPackI
local buyMoneyPackII
local buyMoneyPackIII
local buyMoneyPackIV
local buyMoneyPackV
local buyMoneyPackVI

local textBuyMoneyPackI
local textBuyMoneyPackII
local textBuyMoneyPackIII
local textBuyMoneyPackIV
local textBuyMoneyPackV
local textBuyMoneyPackVI

local devProductsServerLuck = {
	[2] = "SERVER_LUCK_2X",
	[4] = "SERVER_LUCK_4X",
	[8] = "SERVER_LUCK_8X",
	[9] = "SERVER_LUCK",
}

function RobuxShopController:Init()
	RobuxShopController:CreateReferences()
	RobuxShopController:InitAttributeListener()
	RobuxShopController:InitServerLuck()
	RobuxShopController:UpdateBuyServerLuckButton()
	RobuxShopController:InitButtonListerns()
	RobuxShopController:ConfigureBuyMoneyButtoms()
end

function RobuxShopController:CreateReferences()
	screen = UIReferences:GetReference("ROBUX_SHOP")
	currentServerLuck = UIReferences:GetReference("CURRENT_SERVER_LUCK")
	nextServerLuck = UIReferences:GetReference("NEXT_SERVER_LUCK")
	buyServerLuck = UIReferences:GetReference("NEXT_SERVER_LUCK")
	textBuyServerLuck = UIReferences:GetReference("TEXT_BUY_SERVER_LUCK")
	buyServerLuck = UIReferences:GetReference("BUY_SERVER_LUCK")

	buyMoneyPackI = UIReferences:GetReference("BUY_MONEY_PACK_I")
	buyMoneyPackII = UIReferences:GetReference("BUY_MONEY_PACK_II")
	buyMoneyPackIII = UIReferences:GetReference("BUY_MONEY_PACK_III")
	buyMoneyPackIV = UIReferences:GetReference("BUY_MONEY_PACK_IV")
	buyMoneyPackV = UIReferences:GetReference("BUY_MONEY_PACK_V")
	buyMoneyPackVI = UIReferences:GetReference("BUY_MONEY_PACK_VI")

	textBuyMoneyPackI = UIReferences:GetReference("TEXT_BUY_MONEY_PACK_I")
	textBuyMoneyPackII = UIReferences:GetReference("TEXT_BUY_MONEY_PACK_II")
	textBuyMoneyPackIII = UIReferences:GetReference("TEXT_BUY_MONEY_PACK_III")
	textBuyMoneyPackIV = UIReferences:GetReference("TEXT_BUY_MONEY_PACK_IV")
	textBuyMoneyPackV = UIReferences:GetReference("TEXT_BUY_MONEY_PACK_V")
	textBuyMoneyPackVI = UIReferences:GetReference("TEXT_BUY_MONEY_PACK_VI")
end

function RobuxShopController:InitButtonListerns()
	buyServerLuck.MouseButton1Click:Connect(function()
		DeveloperProductController:OpenPaymentRequestScreen(currentDevProductServerLuck)
	end)
end

function RobuxShopController:Open(data)
	screen.Visible = true
end

function RobuxShopController:Close()
	screen.Visible = false
end

function RobuxShopController:GetScreen()
	return screen
end

function RobuxShopController:ConfigureServerLuck()
	local serverLuck = workspace:GetAttribute("SERVER_LUCK") or 1

	currentServerLuck.Text = serverLuck .. "x"
	nextServerLuck.Text = (serverLuck * 2) .. "x"
	RobuxShopController:UpdateBuyServerLuckButton()
end

function RobuxShopController:UpdateBuyServerLuckButton()
	task.spawn(function()
		local currentServerLuck = workspace:GetAttribute("SERVER_LUCK") or 1
		local nextServerLuck = currentServerLuck * 2

		local devProduct = devProductsServerLuck[nextServerLuck] or devProductsServerLuck[9]
		currentDevProductServerLuck = devProduct
		local price = DeveloperProductController:GetProductPrice(devProduct)
		textBuyServerLuck.Text = utf8.char(0xE002) .. price
	end)
end

function RobuxShopController:ConfigureBuyMoneyButtoms()
	local buyMoneyPackButtons = {
		{
			Button = buyMoneyPackI,
			Text = textBuyMoneyPackI,
			DevProduct = "MONEY_PACK_I",
		},

		{
			Button = buyMoneyPackII,
			Text = textBuyMoneyPackII,
			DevProduct = "MONEY_PACK_II",
		},

		{
			Button = buyMoneyPackIII,
			Text = textBuyMoneyPackIII,
			DevProduct = "MONEY_PACK_III",
		},

		{
			Button = buyMoneyPackIV,
			Text = textBuyMoneyPackIV,
			DevProduct = "MONEY_PACK_IV",
		},

		{
			Button = buyMoneyPackV,
			Text = textBuyMoneyPackV,
			DevProduct = "MONEY_PACK_V",
		},

		{
			Button = buyMoneyPackVI,
			Text = textBuyMoneyPackVI,
			DevProduct = "MONEY_PACK_VI",
		},
	}

	for _, value in buyMoneyPackButtons do
		value.Button.MouseButton1Click:Connect(function()
			DeveloperProductController:OpenPaymentRequestScreen(value.DevProduct)
		end)
		task.spawn(function()
			local price = DeveloperProductController:GetProductPrice(value.DevProduct)
			value.Text.Text = utf8.char(0xE002) .. price
		end)
	end
end

function RobuxShopController:InitServerLuck()
	local serverLuck = workspace:GetAttribute("SERVER_LUCK") or 2

	currentServerLuck.Text = serverLuck
	nextServerLuck.Text = serverLuck * 2
end

function RobuxShopController:InitAttributeListener()
	workspace:GetAttributeChangedSignal("SERVER_LUCK"):Connect(function()
		local serverLuck = workspace:GetAttribute("SERVER_LUCK") or 1

		currentServerLuck.Text = serverLuck .. "x"
		nextServerLuck.Text = (serverLuck * 2) .. "x"
		RobuxShopController:UpdateBuyServerLuckButton()
	end)
end

return RobuxShopController
