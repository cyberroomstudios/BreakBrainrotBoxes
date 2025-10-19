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

local cooldowns = {}

function PlotController:Init() end



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
