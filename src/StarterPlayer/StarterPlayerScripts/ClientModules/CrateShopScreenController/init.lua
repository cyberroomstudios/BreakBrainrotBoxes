local CrateShopScreenController = {}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("StockService")
local bridgeFunnelService = BridgeNet2.ReferenceBridge("FunnelService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local Crate = require(ReplicatedStorage.Enums.Crate)
local UIStateManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.UIStateManager)
local DeveloperProductController = require(Players.LocalPlayer.PlayerScripts.ClientModules.DeveloperProductController)

--GUI
local screen -- Tela
local restockTime -- Inidcador do tempo para restock
local crateScrollingFrame -- Scrolling Frame dos Itens
local restockAllCrate

-- Variaveis
local selectedItem = nil

local devProductsPrices = {
	["Wooden"] = 0,
	["Tech"] = 0,
	["Storm"] = 0,
	["Stone"] = 0,
	["Lava"] = 0,
	["Ice"] = 0,
	["Grass"] = 0,
	["Golden"] = 0,
	["Diamond"] = 0,
	["Bronze"] = 0,
}
local devProducts = {
	["Wooden"] = "WOODEN_CRATE",
	["Tech"] = "TECH_CRATE",
	["Storm"] = "STORM_CRATE",
	["Stone"] = "STONE_CRATE",
	["Lava"] = "LAVA_CRATE",
	["Ice"] = "ICE_CRATE",
	["Grass"] = "GRASS_CRATE",
	["Golden"] = "GOLDEN_CRATE",
	["Diamond"] = "DIAMOND_CRATE",
	["Bronze"] = "BRONZE_CRATE",
}

function CrateShopScreenController:Init()
	CrateShopScreenController:CreateReferences()
	CrateShopScreenController:ConfigureProximityPrompt()
	CrateShopScreenController:InitAttributeListener()
	CrateShopScreenController:CreateButtonListner()
	CrateShopScreenController:InitDevProductsPrices()
end

function CrateShopScreenController:SendFunnelEvent(eventName: string)
	task.spawn(function()
		if player:GetAttribute("FUNNEL_" .. eventName) then
			return
		end

		local result = bridgeFunnelService:InvokeServerAsync({
			[actionIdentifier] = "AddEvent",
			data = { Name = eventName },
		})
	end)
end

function CrateShopScreenController:CreateReferences()
	screen = UIReferences:GetReference("CRATE_SHOP_SCREEN")
	restockTime = UIReferences:GetReference("CRATE_SHOP_RESTOCK_TIME")
	crateScrollingFrame = UIReferences:GetReference("CRATES_SHOP_SCROLLING_FRAME")
	restockAllCrate = UIReferences:GetReference("RESTOCK_ALL_CRATE")
end

function CrateShopScreenController:InitDevProductsPrices()
	task.spawn(function()
		for key, value in pairs(devProducts) do
			pcall(function()
				devProductsPrices[key] = DeveloperProductController:GetProductPrice(value)
			end)
		end
	end)
end

function CrateShopScreenController:ConfigureProximityPrompt()
	local proximityPart =
		ClientUtil:WaitForDescendants(workspace, "Map", "Booths", "CrateAndSell", "CrateShop", "ProximityPromptPart")

	local proximityPrompt = proximityPart.ProximityPrompt

	proximityPrompt.PromptShown:Connect(function()
		CrateShopScreenController:SendFunnelEvent("OPEN_CRATE_SHOP_UI")

		UIStateManager:Open("CRATES")
	end)

	proximityPrompt.PromptHidden:Connect(function()
		UIStateManager:Close("CRATES")
	end)
end

function CrateShopScreenController:Open()
	screen.Visible = true
	local result = bridge:InvokeServerAsync({
		[actionIdentifier] = "GetStock",
	})

	CrateShopScreenController:BuildScreen(result)
end

function CrateShopScreenController:Close()
	screen.Visible = false
end

function CrateShopScreenController:GetScreen()
	return screen
end

function CrateShopScreenController:InitAttributeListener()
	Workspace:GetAttributeChangedSignal("CURRENT_TIME_STOCK"):Connect(function()
		local currentTimeStock = workspace:GetAttribute("CURRENT_TIME_STOCK")
		restockTime.Text = "Restock In: " .. ClientUtil:FormatSecondsToMinutes(currentTimeStock)
	end)

	Workspace:GetAttributeChangedSignal("STOCK_UPDATE_INDEX"):Connect(function()
		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "GetStock",
		})

		CrateShopScreenController:BuildScreen(result)
	end)

	Players.LocalPlayer:GetAttributeChangedSignal("RESTOCK_UPDATE_INDEX"):Connect(function()
		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "GetStock",
		})

		CrateShopScreenController:BuildScreen(result)
	end)
end

function CrateShopScreenController:CreateButtonListner()
	local buyButton = crateScrollingFrame.Buttons.Display.Buy.Button
	local buyRobuxButton = crateScrollingFrame.Buttons.Display.BuyRobux.Button
	local restockThisButton = crateScrollingFrame.Buttons.Display.RestockThis.Button

	buyButton.MouseButton1Click:Connect(function()
		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "BuyItem",
			data = {
				ItemName = selectedItem,
			},
		})

		if result then
			local uiItem = crateScrollingFrame:FindFirstChild(selectedItem)

			if uiItem then
				uiItem.Display.InfoItem.ItemStock.Text = "Stock: x" .. result
			end
		end
	end)

	buyRobuxButton.MouseButton1Click:Connect(function()
		DeveloperProductController:OpenPaymentRequestScreen(devProducts[selectedItem])
	end)

	restockThisButton.MouseButton1Click:Connect(function()
		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "AddRestockItention",
			data = {
				ItemName = selectedItem,
			},
		})

		DeveloperProductController:OpenPaymentRequestScreen("RESTOCK_THIS")
	end)

	restockAllCrate.MouseButton1Click:Connect(function()
		DeveloperProductController:OpenPaymentRequestScreen("RESTOCK_ALL")
	end)
end
function CrateShopScreenController:BuildScreen(stockItems)
	local viewPortFolder = ReplicatedStorage.GUI.ViewPortFrames.CRATES

	-- Atualiza a ordem dos itens, quando algum item é expandido
	local function updateLayoutOrder(layoutOrderBase: number)
		for _, value in crateScrollingFrame:GetChildren() do
			if value:IsA("Frame") and value.LayoutOrder > layoutOrderBase then
				value.LayoutOrder = value.LayoutOrder + 1
			end
		end
	end

	-- Limpa tudo
	for _, value in crateScrollingFrame:GetChildren() do
		if value:IsA("TextButton") and value.Name ~= "Item" and value.Name ~= "Buttons" then
			value:Destroy()
		end
	end

	for name, value in Crate.CRATES do
		local newItem = crateScrollingFrame.Item:Clone()
		newItem.Name = name
		newItem.Visible = true
		-- Definindo a ordem
		newItem.LayoutOrder = value.GUI.Order

		-- Definindo o ViewPort
		local viewPortTemplate = viewPortFolder:FindFirstChild(name)

		local viewPort = viewPortTemplate:Clone()
		viewPort.Parent = newItem.Display.Image

		local shadow = viewPort:Clone()
		shadow.ZIndex = 0
		shadow[name]:ScaleTo(shadow[name]:GetScale() + 0.2)

		shadow.Ambient = Color3.new(0, 0, 0)
		shadow.LightColor = Color3.new(0, 0, 0)
		shadow.Parent = viewPort.Parent

		-- Definindo o nome
		newItem.Display.InfoItem.ItemName.Text = value.GUI.Name

		-- Definindo o Preço
		newItem.Display.RarityAndPrice.Price.Text = ClientUtil:FormatToUSD(value.Price)

		-- Definindo o Stock
		if stockItems[name] and stockItems[name] > 0 then
			newItem.Display.InfoItem.ItemStock.Text = "Stock: x" .. stockItems[name]
		else
			newItem.Display.InfoItem.NoStock.Visible = true
			newItem.Display.InfoItem.ItemStock.Visible = false
		end

		newItem.MouseButton1Click:Connect(function()
			-- Atualizando Preço

			pcall(function()
				local buy = crateScrollingFrame.Buttons.Display.Buy
				local buyRobux = crateScrollingFrame.Buttons.Display.BuyRobux

				buy.TextLabel.Text = ClientUtil:FormatNumberToSuffixes(value.Price)
				buyRobux.TextLabel.Text = utf8.char(0xE002) .. devProductsPrices[name]
			end)

			selectedItem = name
			crateScrollingFrame.Buttons.Visible = true
			updateLayoutOrder(newItem.LayoutOrder)
			crateScrollingFrame.Buttons.LayoutOrder = newItem.LayoutOrder + 1
		end)
		newItem.Parent = crateScrollingFrame
	end
end
return CrateShopScreenController
