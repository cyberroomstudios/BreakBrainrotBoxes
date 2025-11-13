local UIStateManager = {}

local CollectionService = game:GetService("CollectionService")
local HapticService = game:GetService("HapticService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)
local MobileVibrationController = require(Players.LocalPlayer.PlayerScripts.ClientModules.MobileVibrationController)
local SoundManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.SoundManager)

local screens = {}
local originalSizeScreen = {}
local loadedModules = false
local camera = workspace.CurrentCamera

local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = camera

local currentScreen = ""
local backpackButtons

function UIStateManager:Init()
	UIStateManager:ConfigureCloseButton()
end

function UIStateManager:LoadModules()
	if not loadedModules then
		loadedModules = true
		local clientModules = Players.LocalPlayer.PlayerScripts.ClientModules
		local CrateShopScreenController = require(clientModules.CrateShopScreenController)
		local SellBrainrotController = require(clientModules.SellBrainrotController)
		local UpgradeController = require(clientModules.UpgradeController)
		local IndexController = require(clientModules.IndexController)
		local NewBrinrotScreenController = require(clientModules.NewBrainrotScreenController)
		local SellBrainrotController = require(clientModules.SellBrainrotController)
		local RebirthController = require(clientModules.RebirthController)
		local SettingsController = require(Players.LocalPlayer.PlayerScripts.ClientModules.SettingsController)
		local RobuxShopController = require(Players.LocalPlayer.PlayerScripts.ClientModules.RobuxShopController)

		screens = {
			["CRATES"] = CrateShopScreenController,
			["SELL"] = SellBrainrotController,
			["UPGRADES"] = UpgradeController,
			["INDEX"] = IndexController,
			["NEW_GAME"] = NewBrinrotScreenController,
			["SETTINGS"] = SettingsController,
			["REBIRTH"] = RebirthController,
			["ROBUX_SHOP"] = RobuxShopController,
		}

		for screenName, screen in screens do
			originalSizeScreen[screenName] = screen:GetScreen().Size
		end
	end
end

function UIStateManager:Open(screenName: string, data)
	UIStateManager:LoadModules()
	for _, screen in screens do
		screen:Close()
	end

	if screenName == currentScreen then
		UIStateManager:Close(screenName)
		currentScreen = ""
		return
	end

	UIStateManager:AddBluer()
	task.spawn(function()
		MobileVibrationController:Start()
		SoundManager:Play("UI_OPEN_SCREEN")
		screens[screenName]:Open(data)
	end)

	UIStateManager:ApplyTween(screenName, screens[screenName]:GetScreen())
	currentScreen = screenName
end

function UIStateManager:Close(screenName: string)
	UIStateManager:RemoveBluer()
	currentScreen = ""
	if screenName and screens[screenName] then
		screens[screenName]:Close()
	end
end

function UIStateManager:ApplyTween(screenName: string, screen: Frame)
	if screenName == "NEW_GAME" then
		return
	end

	local originalSize = originalSizeScreen[screenName]

	local tweenInfo = TweenInfo.new(
		0.3, -- duração
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)

	if screen.Name == "Expand" then
		local tweenInfo = TweenInfo.new(
			0.1, -- duração
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		)
		-- Apenas cresce no eixo Y
		local startSize = UDim2.new(originalSize.X.Scale, 0, originalSize.Y.Scale * 0.3, 0)
		local endSize = UDim2.new(originalSize.X.Scale, 0, originalSize.Y.Scale * 1.1, 0)

		screen.Size = startSize

		local growTween = TweenService:Create(screen, tweenInfo, { Size = endSize })
		local normalTween = TweenService:Create(screen, tweenInfo, { Size = originalSize })

		growTween:Play()
		growTween.Completed:Connect(function()
			normalTween:Play()
		end)

		return -- importante: para não executar o tween padrão
	end

	-- Tween padrão para outras telas
	local smallSize = UDim2.new(originalSize.X.Scale * 0.3, 0, originalSize.Y.Scale * 0.3, 0)
	local bigSize = UDim2.new(originalSize.X.Scale * 1.1, 0, originalSize.Y.Scale * 1.1, 0)

	screen.Size = smallSize

	local growTween = TweenService:Create(screen, tweenInfo, { Size = bigSize })
	local normalTween = TweenService:Create(screen, tweenInfo, { Size = originalSize })

	growTween:Play()
	growTween.Completed:Connect(function()
		normalTween:Play()
	end)
end

function UIStateManager:AddBluer()
	blur.Size = 24
end

function UIStateManager:RemoveBluer()
	blur.Size = 0
end

function UIStateManager:ConfigureCloseButton()
	local taggedObjects = CollectionService:GetTagged("CLOSE_BUTTON")

	for _, button in taggedObjects do
		print(button:GetAttribute("SCREEN"))
		button.MouseButton1Click:Connect(function()
			print("Clicou")
			UIStateManager:Close(button:GetAttribute("SCREEN"))
		end)
	end
end

return UIStateManager
