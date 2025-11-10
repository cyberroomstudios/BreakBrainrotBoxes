local PlotController = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("PlotService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)
local GamepassController = require(Players.LocalPlayer.PlayerScripts.ClientModules.GamepassController)

local cooldowns = {}

function PlotController:Init()
	PlotController:InitBridgeListener()
end

function PlotController:InitBridgeListener()
	bridge:Connect(function(response)
		if response[actionIdentifier] == "CreateProximityPrompt" then
			PlotController:CreateProximityPrompt(response.data.Name, response.data.Plot)
		end
	end)
end

function PlotController:DeleteGamepassesFolder()
	local baseNumber = player:GetAttribute("BASE")
	local bases = ClientUtil:WaitForDescendants(workspace, "Map", "Plots"):GetChildren()

	for _, value in bases do
		if value.Name ~= baseNumber then
			local gamepassesFolder = ClientUtil:WaitForDescendants(value, "Main", "Gamepasses")

			gamepassesFolder:Destroy()
		end
	end
end

function PlotController:ConfigureGamepassesTouched()
	local passes = {
		["UltraLuck"] = "ULTRA_LUCK",
		["MegaLuck"] = "MEGA_LUCK",
		["SuperLuck"] = "SUPER_LUCK",
		["BaseLuck"] = "BASE_LUCK",
	}
	local baseNumber = player:GetAttribute("BASE")
	local bases = ClientUtil:WaitForDescendants(workspace, "Map", "Plots"):GetChildren()

	for _, value in bases do
		if value.Name == baseNumber then
			local lucksFolder = ClientUtil:WaitForDescendants(value, "Main", "Gamepasses", "Lucks")

			for _, gamepassModel in lucksFolder:GetChildren() do
				local standingPart = gamepassModel:WaitForChild("StandingPart")
				local debounce = false
				standingPart.Touched:Connect(function(hit)
					if debounce then
						return
					end
					debounce = true

					GamepassController:OpenPaymentRequestScreen(passes[gamepassModel.Name])

					task.wait(5)
					debounce = false
				end)
			end
		end
	end
end
function PlotController:ConfigureGamepasses()
	task.spawn(function()
		PlotController:DeleteGamepassesFolder()
		PlotController:ConfigureGamepassesTouched()
	end)
end

function PlotController:ConfigureInsertItemProximityPrompt()
	local baseNumber = player:GetAttribute("BASE")
	local base = ClientUtil:WaitForDescendants(workspace, "Map", "Plots", baseNumber)
	local main = ClientUtil:WaitForDescendants(base, "Main")
	local brainrotsPlots = ClientUtil:WaitForDescendants(main, "BrainrotPlots")

	for _, value in brainrotsPlots:GetChildren() do
		local touchPart = ClientUtil:WaitForDescendants(value, "TouchPart")
		if touchPart then
			touchPart.InsertItemProximityPart.Triggered:Connect(function(player)
				local result = bridge:InvokeServerAsync({
					[actionIdentifier] = "InsertBrainrot",
					data = {
						PlotName = value.Name,
					},
				})

				if result then
					touchPart.InsertItemProximityPart.Enabled = false
				end
			end)
		end
	end

	local result = bridge:InvokeServerAsync({
		[actionIdentifier] = "GetItemsToActivateInsertItemProximityPrompt",
	})

	if result then
		for _, value in result do
			local plot = brainrotsPlots:FindFirstChild(value)

			if plot then
				local touchPart = ClientUtil:WaitForDescendants(plot, "TouchPart")
				if touchPart then
					touchPart.InsertItemProximityPart.Enabled = true
				end
			end
		end
	end
end

function PlotController:EnableInsertItemProximityPrompt(plotNumber: number)
	local baseNumber = player:GetAttribute("BASE")
	local base = ClientUtil:WaitForDescendants(workspace, "Map", "Plots", baseNumber)
	local main = ClientUtil:WaitForDescendants(base, "Main")
	local brainrotsPlots = ClientUtil:WaitForDescendants(main, "BrainrotPlots")

	local plot = brainrotsPlots:FindFirstChild(plotNumber)

	if plot then
		local touchPart = ClientUtil:WaitForDescendants(plot, "TouchPart")
		if touchPart then
			touchPart.InsertItemProximityPart.Enabled = true
		end
	end
end

function PlotController:DisableInsertItemProximityPrompt(plotNumber: number)
	local baseNumber = player:GetAttribute("BASE")
	local base = ClientUtil:WaitForDescendants(workspace, "Map", "Plots", baseNumber)
	local main = ClientUtil:WaitForDescendants(base, "Main")
	local brainrotsPlots = ClientUtil:WaitForDescendants(main, "BrainrotPlots")

	local plot = brainrotsPlots:FindFirstChild(plotNumber)

	if plot then
		local touchPart = ClientUtil:WaitForDescendants(plot, "TouchPart")
		if touchPart then
			touchPart.InsertItemProximityPart.Enabled = false
		end
	end
end

function PlotController:CreateProximityPrompt(name: string, plotNumber: number)
	local found = false
	while not found do
		local runtimeFolder = workspace.Runtime
		local playerFolder = runtimeFolder[player.UserId]
		local brainrotsFolder = playerFolder.Brainrots

		for _, value in brainrotsFolder:GetChildren() do
			if value.Name == name and value:GetAttribute("SLOT_NUMBER") == plotNumber then
				found = true
				PlotController:DisableInsertItemProximityPrompt(plotNumber)
				local humanoidRootPart = value:WaitForChild("HumanoidRootPart")

				local proximityPrompt = humanoidRootPart.ProximityPrompt
				proximityPrompt.Triggered:Connect(function()
					local result = bridge:InvokeServerAsync({
						[actionIdentifier] = "RemoveBrainrot",
						data = {
							Name = name,
							PlotNumber = plotNumber,
						},
					})

					if result then
						PlotController:EnableInsertItemProximityPrompt(plotNumber)
					end
				end)
			end
		end
		task.wait(1)
	end
end

function PlotController:StartTouchGetMoney()
	local baseNumber = player:GetAttribute("BASE")
	local base = ClientUtil:WaitForDescendants(workspace, "Map", "Plots", baseNumber)
	local main = ClientUtil:WaitForDescendants(base, "Main")
	local brainrotsPlots = ClientUtil:WaitForDescendants(main, "BrainrotPlots")

	for _, value in brainrotsPlots:GetChildren() do
		local emitter = value.ParticlePart.ParticleEmitter
		value.TouchPart.Touched:Connect(function(hit)
			local character = hit:FindFirstAncestorOfClass("Model")
			local touchPlayer = character and Players:GetPlayerFromCharacter(character)
			if not touchPlayer then
				return
			end

			if touchPlayer ~= player then
				return
			end

			if cooldowns[value.TouchPart] then
				-- ainda está em cooldown, ignora
				return
			end

			cooldowns[value.TouchPart] = true

			local result = bridge:InvokeServerAsync({
				[actionIdentifier] = "GetMoney",
				data = {
					PlotNumber = value.Name,
				},
			})

			if result and result > 0 then
				emitter:Emit(20)
			end

			task.delay(2, function()
				cooldowns[value.TouchPart] = false
			end)
		end)
	end
end
return PlotController
