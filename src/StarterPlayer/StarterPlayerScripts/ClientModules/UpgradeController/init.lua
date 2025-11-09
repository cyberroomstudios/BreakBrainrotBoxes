local UpgradesController = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("UpgradeService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local Players = game:GetService("Players")

local Upgrades = require(ReplicatedStorage.Enums.Upgrades)
local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)
local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local UIStateManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.UIStateManager)
local Breakers = require(ReplicatedStorage.Enums.Breakers)
local DeveloperProductController = require(Players.LocalPlayer.PlayerScripts.ClientModules.DeveloperProductController)

local screen
local buyPowerButton
local buySpeedButton
local buyCapacityButton

-- Power
local currentPower
local nextPower
local maximumReachedPower
local numberInformationPower
local buyPowerFrame

-- Speed
local currentSpeed
local nextSpeed
local maximumReachedSpeed
local numberInformationSpeed
local buySpeedFrame

-- Capacity
local currentCapacity
local nextCapacity
local maximumReachedCapacity
local numberInformationCapacity
local buyCapacityFrame

local upgradeFrame
local breakersFrame
local openUpgradesButton
local openBreakersButton

local selectBreakerItem

local devProductBreakersPrice = {
	["Noob"] = 0,
	["Baseball"] = 0,
	["Ninja"] = 0,
	["Warrior"] = 0,
	["Soldier"] = 0,
}

local devProductsBreakers = {
	["Noob"] = "NOOB_BREAKER",
	["Baseball"] = "BASEBALL_BREAKER",
	["Ninja"] = "NINJA_BREAKER",
	["Warrior"] = "WARRIOR_BREAKER",
	["Soldier"] = "SOLDIER_BREAKER",
}

function UpgradesController:Init(data)
	UpgradesController:CreateReferences()
	UpgradesController:InitButtonListerns()
	UpgradesController:FillScreen(data)
	UpgradesController:CreateBreakerViewPort()
	UpgradesController:InitDevProductsPrices()
	UpgradesController:InitAttributeListener()
end

function UpgradesController:FillScreen(data)
	local crateBreaker = data.crateBreaker
	UpgradesController:UpdatePowerText(crateBreaker.Power)
	UpgradesController:UpdateSpeedText(crateBreaker.Speed)
	UpgradesController:UpdateCapacityText(crateBreaker.Capacity)
end

function UpgradesController:InitDevProductsPrices()
	task.spawn(function()
		for key, value in pairs(devProductsBreakers) do
			pcall(function()
				devProductBreakersPrice[key] = DeveloperProductController:GetProductPrice(value)
			end)
		end
	end)
end

function UpgradesController:CreateReferences()
	screen = UIReferences:GetReference("UPGRADES_SCREEN")

	upgradeFrame = UIReferences:GetReference("UPGRADES_FRAME")
	breakersFrame = UIReferences:GetReference("BREAKERS_FRAME")

	openUpgradesButton = UIReferences:GetReference("OPEN_UPGRADES_BUTTON")
	openBreakersButton = UIReferences:GetReference("OPEN_BREAKERS_BUTTON")

	buyPowerButton = UIReferences:GetReference("BUY_POWER")
	buySpeedButton = UIReferences:GetReference("BUY_SPEED")
	buyCapacityButton = UIReferences:GetReference("BUY_CAPACITY")

	currentPower = UIReferences:GetReference("CURRENT_POWER")
	nextPower = UIReferences:GetReference("NEXT_POWER")
	maximumReachedPower = UIReferences:GetReference("MAXIMUM_REACHED_POWER")
	numberInformationPower = UIReferences:GetReference("NUMBER_INFORMATION_POWER")
	buyPowerFrame = UIReferences:GetReference("BUY_POWER_FRAME")

	currentSpeed = UIReferences:GetReference("CURRENT_SPEED")
	nextSpeed = UIReferences:GetReference("NEXT_SPEED")
	maximumReachedSpeed = UIReferences:GetReference("MAXIMUM_REACHED_SPEED")
	numberInformationSpeed = UIReferences:GetReference("NUMBER_INFORMATION_SPEED")
	buySpeedFrame = UIReferences:GetReference("BUY_SPEED_FRAME")

	currentCapacity = UIReferences:GetReference("CURRENT_CAPACITY")
	nextCapacity = UIReferences:GetReference("NEXT_CAPACITY")
	maximumReachedCapacity = UIReferences:GetReference("MAXIMUM_REACHED_CAPACITY")
	numberInformationCapacity = UIReferences:GetReference("NUMBER_INFORMATION_CAPACITY")
	buyCapacityFrame = UIReferences:GetReference("BUY_CAPACITY_FRAME")
end

function UpgradesController:InitAttributeListener()
	Players.LocalPlayer:GetAttributeChangedSignal("BUY_BREAKER_WITH_ROBUX_UPDATE_INDEX"):Connect(function()
		UpgradesController:UpdateBreakers()
	end)
end

function UpgradesController:UpdateBreakers()
	local result = bridge:InvokeServerAsync({
		[actionIdentifier] = "GetBreakers",
	})

	local models = {
		"Baseball",
		"Ninja",
		"Noob",
		"Soldier",
		"Warrior",
	}

	for _, modelName in models do
		local item = breakersFrame:WaitForChild("Items"):WaitForChild(modelName)
		local display = item:WaitForChild("Display")
		local priceAndStatus = display:WaitForChild("PriceAndStatus")

		priceAndStatus.Equiped.Visible = false
		priceAndStatus.Purchased.Visible = false
		priceAndStatus.Price.Visible = false

		if result.Purchaseds[modelName] then
			if result.Equiped == modelName then
				item:SetAttribute("HAS_ITEM", true)
				item:SetAttribute("EQUIPED", true)
				priceAndStatus.Equiped.Visible = true
				continue
			end
			item:SetAttribute("HAS_ITEM", true)
			item:SetAttribute("EQUIPED", false)

			priceAndStatus.Purchased.Visible = true
			continue
		end

		item:SetAttribute("EQUIPED", false)
		priceAndStatus.Price.Visible = true
	end
end

function UpgradesController:UpdateInfoButtons(breakerName: string)
	pcall(function()
		local buttonsFrame = breakersFrame:WaitForChild("Items"):WaitForChild("Buttons")
		local display = buttonsFrame:WaitForChild("Display")
		local textLabel = display:WaitForChild("Buy"):WaitForChild("TextLabel")
		local buyWithRobuxTextLabel = display:WaitForChild("BuyWithRobux"):WaitForChild("TextLabel")

		local breakersEnum = Breakers[breakerName]
		textLabel.Text = "$" .. ClientUtil:FormatNumberToSuffixes(breakersEnum.Price)

		buyWithRobuxTextLabel.Text = utf8.char(0xE002) .. devProductBreakersPrice[breakerName]
	end)
end

function UpgradesController:InitBreakersButtons()
	local function updateLayoutOrder(layoutOrderBase: number)
		for _, value in breakersFrame:WaitForChild("Items"):GetChildren() do
			if value:IsA("Frame") and value.LayoutOrder > layoutOrderBase then
				value.LayoutOrder = value.LayoutOrder + 1
			end
		end
	end

	local breakersName = {
		"Baseball",
		"Ninja",
		"Noob",
		"Soldier",
		"Warrior",
	}

	for _, value in breakersName do
		local item = breakersFrame:WaitForChild("Items"):WaitForChild(value)
		item.MouseButton1Click:Connect(function()
			if item:GetAttribute("EQUIPED") then
				return
			end

			selectBreakerItem = value

			if item:GetAttribute("HAS_ITEM") then
				breakersFrame:WaitForChild("Items").Buttons.Display.Equip.Visible = true
				breakersFrame:WaitForChild("Items").Buttons.Display.Buy.Visible = false
				breakersFrame:WaitForChild("Items").Buttons.Display.BuyWithRobux.Visible = false
			else
				breakersFrame:WaitForChild("Items").Buttons.Display.Equip.Visible = false
				breakersFrame:WaitForChild("Items").Buttons.Display.Buy.Visible = true
				breakersFrame:WaitForChild("Items").Buttons.Display.BuyWithRobux.Visible = true
			end

			-- Atualizando as informações de preço dos botões
			UpgradesController:UpdateInfoButtons(value)
			breakersFrame:WaitForChild("Items").Buttons.Visible = true
			updateLayoutOrder(item.LayoutOrder)
			breakersFrame:WaitForChild("Items").Buttons.LayoutOrder = item.LayoutOrder + 1
		end)
	end

	local buttonsFrame = breakersFrame:WaitForChild("Items"):WaitForChild("Buttons")

	if buttonsFrame then
		local buyButton = buttonsFrame:WaitForChild("Display"):WaitForChild("Buy")
		local buyWithRobux = buttonsFrame:WaitForChild("Display"):WaitForChild("BuyWithRobux")

		local equipButton = buttonsFrame:WaitForChild("Display"):WaitForChild("Equip")

		buyWithRobux.Button.MouseButton1Click:Connect(function()
			DeveloperProductController:OpenPaymentRequestScreen(devProductsBreakers[selectBreakerItem])
			breakersFrame:WaitForChild("Items").Buttons.Visible = false
			selectBreakerItem = nil
		end)

		buyButton.Button.MouseButton1Click:Connect(function()
			local result = bridge:InvokeServerAsync({
				[actionIdentifier] = "BuyBreaker",
				data = {
					BreakerName = selectBreakerItem,
				},
			})

			if result then
				breakersFrame:WaitForChild("Items").Buttons.Visible = false
				UpgradesController:UpdateBreakers()
			end
		end)

		equipButton.Button.MouseButton1Click:Connect(function()
			local result = bridge:InvokeServerAsync({
				[actionIdentifier] = "EquipBreaker",
				data = {
					BreakerName = selectBreakerItem,
				},
			})

			if result then
				breakersFrame:WaitForChild("Items").Buttons.Visible = false
				UpgradesController:UpdateBreakers()
			end
		end)
	end
end

function UpgradesController:InitButtonListerns()
	UpgradesController:InitBreakersButtons()

	buyPowerButton.MouseButton1Click:Connect(function()
		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "BuyPower",
		})

		UpgradesController:UpdatePowerText(result)
	end)

	buySpeedButton.MouseButton1Click:Connect(function()
		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "BuySpeed",
		})

		UpgradesController:UpdateSpeedText(result)
	end)

	buyCapacityButton.MouseButton1Click:Connect(function()
		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "BuyCapacity",
		})

		UpgradesController:UpdateCapacityText(result)
	end)

	openUpgradesButton.MouseButton1Click:Connect(function()
		upgradeFrame.Visible = true
		breakersFrame.Visible = false
	end)

	openBreakersButton.MouseButton1Click:Connect(function()
		upgradeFrame.Visible = false
		breakersFrame.Visible = true
	end)
end

function UpgradesController:UpdatePowerText(value: number)
	local item = Upgrades["Power"][value + 1]

	if not item then
		maximumReachedPower.Visible = true
		numberInformationPower.Visible = false
		buyPowerFrame.Visible = false
		return
	end
	currentPower.Text = value
	nextPower.Text = value + 1
	buyPowerFrame.Deco.TextLabel.Text = ClientUtil:FormatToUSD(item)
end

function UpgradesController:UpdateSpeedText(value: number)
	local item = Upgrades["Speed"][value + 1]

	if not item then
		maximumReachedSpeed.Visible = true
		numberInformationSpeed.Visible = false
		buySpeedFrame.Visible = false
		return
	end

	currentSpeed.Text = value
	nextSpeed.Text = value + 1
	buySpeedFrame.Deco.TextLabel.Text = ClientUtil:FormatToUSD(item)
end

function UpgradesController:UpdateCapacityText(value: number)
	local item = Upgrades["Capacity"][value + 1]

	if not item then
		maximumReachedCapacity.Visible = true
		numberInformationCapacity.Visible = false
		buyCapacityFrame.Visible = false
		return
	end
	currentCapacity.Text = value
	nextCapacity.Text = value + 1
	buyCapacityFrame.Deco.TextLabel.Text = ClientUtil:FormatToUSD(item)
end

function UpgradesController:ConfigureProximityPrompt()
	local proximityPart = ClientUtil:WaitForDescendants(workspace, "Map", "Upgrade", "ProximityPromptPart")

	local proximityPrompt = proximityPart.ProximityPrompt

	proximityPrompt.PromptShown:Connect(function()
		UIStateManager:Open("UPGRADES")
	end)

	proximityPrompt.PromptHidden:Connect(function()
		UIStateManager:Close("UPGRADES")
	end)
end

function UpgradesController:CreateBreakerViewPort()
	local function centralizeModel(viewPort: ViewportFrame, model: Model)
		if not model:IsA("Model") then
			warn("O objeto passado não é um Model válido.")
			return
		end

		-- Garante que só o conteúdo do Model será considerado
		local parts = {}
		for _, obj in ipairs(model:GetDescendants()) do
			if obj:IsA("BasePart") then
				table.insert(parts, obj)
			end
		end

		if #parts == 0 then
			warn("O modelo não possui partes físicas (BasePart) para calcular o enquadramento.")
			return
		end

		-- Define PrimaryPart se ainda não existir
		if not model.PrimaryPart then
			model.PrimaryPart = parts[1]
		end

		-- Cria e configura a câmera
		local camera = Instance.new("Camera")
		camera.Parent = viewPort
		viewPort.CurrentCamera = camera

		-- Calcula o centro e tamanho do modelo
		local cf, size = model:GetBoundingBox()
		local maxAxis = math.max(size.X, size.Y, size.Z)

		-- Calcula a distância ideal da câmera com base no FOV
		local fov = math.rad(camera.FieldOfView)
		local distancia = (maxAxis / 2) / math.tan(fov / 2)

		-- Posiciona a câmera olhando para o centro
		local cameraPosition = cf.Position + Vector3.new(0, size.Y * 0.4, distancia * 1.2)
		camera.CFrame = CFrame.lookAt(cameraPosition, cf.Position)
	end

	local models = {
		"Baseball",
		"Ninja",
		"Noob",
		"Soldier",
		"Warrior",
	}

	for _, modelName in models do
		local model = ClientUtil:WaitForDescendants(ReplicatedStorage, "Breakers", modelName)

		if model then
			local newItem = model:Clone()

			local item = breakersFrame:WaitForChild("Items"):WaitForChild(modelName)

			-- Atualizando as Informações
			-- Boosts
			local breakersEnum = Breakers[modelName]

			if not breakersEnum then
				return
			end

			item.Display.InfoItem.Frame.Power.Text = "+" .. breakersEnum.Boosts.Power
			item.Display.InfoItem.Frame.Speed.Text = "+" .. breakersEnum.Boosts.Speed
			item.Display.PriceAndStatus.Price.Text = ClientUtil:FormatToUSD(breakersEnum.Price)

			local viewPort = item:WaitForChild("Display"):WaitForChild("Breaker")
			newItem.Parent = viewPort.WorldModel

			local humanoid = newItem:WaitForChild("Humanoid")
			--	local animation = ReplicatedStorage.Animations.Worker.Iddle

			--	local track = humanoid:LoadAnimation(animation)
			--	track:Play()

			local rotation = CFrame.Angles(0, math.rad(-180), 0)
			newItem:ScaleTo(0.9)
			newItem:SetPrimaryPartCFrame(CFrame.new(Vector3.new(0, -3, 0)))
			newItem:SetPrimaryPartCFrame(newItem.PrimaryPart.CFrame * rotation)

			centralizeModel(viewPort, newItem)
		end
	end
end

function UpgradesController:Open()
	screen.Visible = true
	upgradeFrame.Visible = true
	breakersFrame.Visible = false

	UpgradesController:UpdateBreakers()
end

function UpgradesController:Close()
	screen.Visible = false
end

function UpgradesController:GetScreen()
	return screen
end

return UpgradesController
