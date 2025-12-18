local RobuxShopController = {}

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local DeveloperProductController = require(Players.LocalPlayer.PlayerScripts.ClientModules.DeveloperProductController)

local screen
local currentServerLuck
local nextServerLuck

-- Exclusive Mutation
local exclusiveMutationBuy10XButton
local exclusiveMutationBuy5XButton
local exclusiveMutationBuy1XButton

local exclusiveMutationGift10XButton
local exclusiveMutationGift5XButton
local exclusiveMutationGift1XButton

local exclusiveMutationText10X
local exclusiveMutationText5X
local exclusiveMutationText1X

-- Lucky Chests

local buyMythicalLuckyChestsButton
local buyGoldyLuckyChestsButton
local buySecretLuckyChestsButton

local giftMythicalLuckyChestsButton
local giftGoldyLuckyChestsButton
local giftSecretLuckyChestsButton

local buyMythicalLuckyChestsText
local buyGoldyLuckyChestsText
local buySecretLuckyChestsText

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

	exclusiveMutationBuy10XButton = UIReferences:GetReference("EXCLUSIVE_MUTATION_BUY_10X")
	exclusiveMutationBuy5XButton = UIReferences:GetReference("EXCLUSIVE_MUTATION_BUY_5X")
	exclusiveMutationBuy1XButton = UIReferences:GetReference("EXCLUSIVE_MUTATION_BUY_1X")

	exclusiveMutationGift10XButton = UIReferences:GetReference("EXCLUSIVE_MUTATION_GIFT_10X")
	exclusiveMutationGift5XButton = UIReferences:GetReference("EXCLUSIVE_MUTATION_GIFT_5X")
	exclusiveMutationGift1XButton = UIReferences:GetReference("EXCLUSIVE_MUTATION_GIFT_1X")

	exclusiveMutationText10X = UIReferences:GetReference("EXCLUSIVE_MUTATION_TEXT_10X")
	exclusiveMutationText5X = UIReferences:GetReference("EXCLUSIVE_MUTATION_TEXT_5X")
	exclusiveMutationText1X = UIReferences:GetReference("EXCLUSIVE_MUTATION_TEXT_1X")

	buyMythicalLuckyChestsButton = UIReferences:GetReference("BUY_MYTHICAL_LUCKY_CHEST")
	buyGoldyLuckyChestsButton = UIReferences:GetReference("BUY_GODLY_LUCKY_CHEST")
	buySecretLuckyChestsButton = UIReferences:GetReference("BUY_SECRET_LUCKY_CHEST")

	giftMythicalLuckyChestsButton = UIReferences:GetReference("GIFT_MYTHICAL_LUCKY_CHEST")
	giftGoldyLuckyChestsButton = UIReferences:GetReference("GIFT_GODLY_LUCKY_CHEST")
	giftSecretLuckyChestsButton = UIReferences:GetReference("GIFT_SECRET_LUCKY_CHEST")

	buyMythicalLuckyChestsText = UIReferences:GetReference("MYTHICAL_LUCKY_CHEST_TEXT")
	buyGoldyLuckyChestsText = UIReferences:GetReference("GODLY_LUCKY_CHEST_TEXT")
	buySecretLuckyChestsText = UIReferences:GetReference("SECRET_LUCKY_CHEST_TEXT")

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

	exclusiveMutationBuy10XButton.MouseButton1Click:Connect(function()
		DeveloperProductController:OpenPaymentRequestScreen("EXCLUSIVE_BRAINROT_PACK_10X")
	end)

	exclusiveMutationBuy5XButton.MouseButton1Click:Connect(function()
		DeveloperProductController:OpenPaymentRequestScreen("EXCLUSIVE_BRAINROT_PACK_5X")
	end)

	exclusiveMutationBuy1XButton.MouseButton1Click:Connect(function()
		DeveloperProductController:OpenPaymentRequestScreen("EXCLUSIVE_BRAINROT_PACK_1X")
	end)

	-- Cheests
	buyMythicalLuckyChestsButton.MouseButton1Click:Connect(function()
		DeveloperProductController:OpenPaymentRequestScreen("LUCKY_CHESTS_MYTHICAL")
	end)

	buyGoldyLuckyChestsButton.MouseButton1Click:Connect(function()
		DeveloperProductController:OpenPaymentRequestScreen("LUCKY_CHESTS_GODLY")
	end)

	buySecretLuckyChestsButton.MouseButton1Click:Connect(function()
		DeveloperProductController:OpenPaymentRequestScreen("LUCKY_CHESTS_SECRET")
	end)

	-- Gift Cheests
	giftMythicalLuckyChestsButton.MouseButton1Click:Connect(function()
		local UIStateManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.UIStateManager)
		player:SetAttribute("GIFT", "LUCKY_CHESTS_MYTHICAL")

		UIStateManager:Open("GIFT_ROBUX")
	end)

	giftGoldyLuckyChestsButton.MouseButton1Click:Connect(function()
		local UIStateManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.UIStateManager)
		player:SetAttribute("GIFT", "LUCKY_CHESTS_GODLY")

		UIStateManager:Open("GIFT_ROBUX")
	end)

	giftSecretLuckyChestsButton.MouseButton1Click:Connect(function()
		local UIStateManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.UIStateManager)
		player:SetAttribute("GIFT", "LUCKY_CHESTS_SECRET")

		UIStateManager:Open("GIFT_ROBUX")
	end)

	exclusiveMutationGift10XButton.MouseButton1Click:Connect(function()
		local UIStateManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.UIStateManager)
		player:SetAttribute("GIFT", "GIT_EXCLUSIVE_BRAINROT_PACK_10X")
		UIStateManager:Open("GIFT_ROBUX")
	end)

	exclusiveMutationGift5XButton.MouseButton1Click:Connect(function()
		local UIStateManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.UIStateManager)
		player:SetAttribute("GIFT", "GIT_EXCLUSIVE_BRAINROT_PACK_5X")

		UIStateManager:Open("GIFT_ROBUX")
	end)

	exclusiveMutationGift1XButton.MouseButton1Click:Connect(function()
		local UIStateManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.UIStateManager)
		player:SetAttribute("GIFT", "GIT_EXCLUSIVE_BRAINROT_PACK_1X")
		UIStateManager:Open("GIFT_ROBUX")
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
	task.spawn(function()
		local CURRENCY_ICON = utf8.char(0xE002)

		local function setPrice(textLabel, devProduct)
			local price = DeveloperProductController:GetProductPrice(devProduct)
			textLabel.Text = CURRENCY_ICON .. price
		end

		local function bindButton(button, devProduct)
			if not button then
				return
			end

			button.MouseButton1Click:Connect(function()
				DeveloperProductController:OpenPaymentRequestScreen(devProduct)
			end)
		end

		-- Money Packs
		local moneyPacks = {
			{ button = buyMoneyPackI, text = textBuyMoneyPackI, product = "MONEY_PACK_I" },
			{ button = buyMoneyPackII, text = textBuyMoneyPackII, product = "MONEY_PACK_II" },
			{ button = buyMoneyPackIII, text = textBuyMoneyPackIII, product = "MONEY_PACK_III" },
			{ button = buyMoneyPackIV, text = textBuyMoneyPackIV, product = "MONEY_PACK_IV" },
			{ button = buyMoneyPackV, text = textBuyMoneyPackV, product = "MONEY_PACK_V" },
			{ button = buyMoneyPackVI, text = textBuyMoneyPackVI, product = "MONEY_PACK_VI" },
		}

		for _, pack in ipairs(moneyPacks) do
			bindButton(pack.button, pack.product)
			setPrice(pack.text, pack.product)
		end

		-- Exclusive Brainrot Packs
		local exclusivePacks = {
			{ text = exclusiveMutationText10X, product = "EXCLUSIVE_BRAINROT_PACK_10X" },
			{ text = exclusiveMutationText5X, product = "EXCLUSIVE_BRAINROT_PACK_5X" },
			{ text = exclusiveMutationText1X, product = "EXCLUSIVE_BRAINROT_PACK_1X" },
		}

		for _, pack in ipairs(exclusivePacks) do
			setPrice(pack.text, pack.product)
		end

		-- Lucky Chests
		local luckyChests = {
			{ text = buyMythicalLuckyChestsText, product = "LUCKY_CHESTS_MYTHICAL" },
			{ text = buyGoldyLuckyChestsText, product = "LUCKY_CHESTS_GODLY" },
			{ text = buySecretLuckyChestsText, product = "LUCKY_CHESTS_SECRET" },
		}

		for _, chest in ipairs(luckyChests) do
			setPrice(chest.text, chest.product)
		end
	end)
end

function RobuxShopController:InitServerLuck()
	local serverLuck = workspace:GetAttribute("SERVER_LUCK") or 2

	currentServerLuck.Text = serverLuck .. "x"
	nextServerLuck.Text = (serverLuck * 2) .. "x"
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
