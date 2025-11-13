local RewardService = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("RewardService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local ServerScriptService = game:GetService("ServerScriptService")

local BrainrotService = require(ServerScriptService.Modules.BrainrotService)
local IndexService = require(ServerScriptService.Modules.IndexService)
local GameNotificationService = require(ServerScriptService.Modules.GameNotificationService)

local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)

function RewardService:Init()
	RewardService:InitBridgeListener()
end

function RewardService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "GetGroupReward" then
			RewardService:GetGroupReward(player)
		end
	end
end

function RewardService:GetGroupReward(player: Player)
	local rewards = PlayerDataHandler:Get(player, "rewards")

	if rewards["GROUP_REWARD"] then
		GameNotificationService:SendErrorNotification(player, "Prize Already Claimed.")
		return
	end

	if not player:IsInGroup(396097746) then
		GameNotificationService:SendErrorNotification(player, "Complete all requirements.")
		return
	end

	PlayerDataHandler:Update(player, "rewards", function(current)
		current["GROUP_REWARD"] = true
		return current
	end)

	BrainrotService:SaveBrainrotInBackpack(player, "CappuccinoAssassino", "NORMAL")
	IndexService:Add(player, "CappuccinoAssassino", "NORMAL")
end

return RewardService
