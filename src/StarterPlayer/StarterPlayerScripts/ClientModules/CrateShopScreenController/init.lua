local CrateShopScreenController = {}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("StockService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local Crate = require(ReplicatedStorage.Enums.Crate)

--GUI
local screen -- Tela
local restockTime -- Inidcador do tempo para restock
local crateScrollingFrame -- Scrolling Frame dos Itens

-- Variaveis
local selectedItem = nil

function CrateShopScreenController:Init()
	CrateShopScreenController:CreateReferences()
	CrateShopScreenController:ConfigureProximityPrompt()
	CrateShopScreenController:InitAttributeListener()
	CrateShopScreenController:CreateButtonListner()
end

function CrateShopScreenController:CreateReferences()
	screen = UIReferences:GetReference("CRATE_SHOP_SCREEN")
	restockTime = UIReferences:GetReference("CRATE_SHOP_RESTOCK_TIME")
	crateScrollingFrame = UIReferences:GetReference("CRATES_SHOP_SCROLLING_FRAME")
end

function CrateShopScreenController:ConfigureProximityPrompt()
	local proximityPart = ClientUtil:WaitForDescendants(workspace, "Map", "Booths", "Shop", "ProximityPromptPart")

	local proximityPrompt = proximityPart.ProximityPrompt

	proximityPrompt.PromptShown:Connect(function()
		screen.Visible = true
		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "GetStock",
		})

		CrateShopScreenController:BuildScreen(result)
	end)

	proximityPrompt.PromptHidden:Connect(function()
		screen.Visible = false
	end)
end

function CrateShopScreenController:InitAttributeListener()
	Workspace:GetAttributeChangedSignal("CURRENT_TIME_STOCK"):Connect(function()
		local currentTimeStock = workspace:GetAttribute("CURRENT_TIME_STOCK")
		restockTime.Text = "Restock In: " .. ClientUtil:FormatSecondsToMinutes(currentTimeStock)
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

	buyRobuxButton.MouseButton1Click:Connect(function() end)

	restockThisButton.MouseButton1Click:Connect(function() end)
end
function CrateShopScreenController:BuildScreen(stockItems)
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
		if value:IsA("Frame") and value.Name ~= "Item" and value.Name ~= "Buttons" then
			value:Destroy()
		end
	end

	for name, value in Crate.CRATES do
		local newItem = crateScrollingFrame.Item:Clone()
		newItem.Name = name
		newItem.Visible = true
		-- Definindo a ordem
		newItem.LayoutOrder = value.GUI.Order

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
			selectedItem = name
			crateScrollingFrame.Buttons.Visible = true
			updateLayoutOrder(newItem.LayoutOrder)
			crateScrollingFrame.Buttons.LayoutOrder = newItem.LayoutOrder + 1
		end)
		newItem.Parent = crateScrollingFrame
	end
end
return CrateShopScreenController
