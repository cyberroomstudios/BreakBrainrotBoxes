local FTUEService = {}

-- Init Bridg Net
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local bridge = BridgeNet2.ReferenceBridge("FTUEService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

function FTUEService:Init()
	FTUEService:InitBridgeListener()
end

function FTUEService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "InsertFTUEStep" then
			local step = data.data.Step
			PlayerDataHandler:Update(player, "ftueSteps", function(current)
				for _, value in current do
					if value.Name == step then
						value.Done = true
					end
				end
				return current
			end)
		end
	end
end
return FTUEService
