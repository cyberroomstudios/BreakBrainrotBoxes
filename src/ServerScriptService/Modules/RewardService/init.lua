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
local UpgradeService = require(ServerScriptService.Modules.UpgradeService)

local sahurRewardTime = {}
local TIME_LIMIT = 15 * 60 -- 15 minutos em segundos
local TIME_LIMIT = 30

function RewardService:Init()
	RewardService:InitBridgeListener()
end

function RewardService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "GetGroupReward" then
			RewardService:GetGroupReward(player)
		end

		if data[actionIdentifier] == "GetSahurReward" then
			return RewardService:GetSahurReward(player)
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

function RewardService:GetSahurReward(player)
	local hasGetSahur = PlayerDataHandler:Get(player, "rewards")

	if hasGetSahur["SAHUR"] then
		return
	end

	local elapsed = tick() - sahurRewardTime[player]
	local hasPlayerTime = elapsed >= TIME_LIMIT

	if hasPlayerTime then
		PlayerDataHandler:Update(player, "rewards", function(current)
			current["SAHUR"] = true
			return current
		end)

		UpgradeService:BuyBreaker(player, "Sahur", false)
		return true
	end

	GameNotificationService:SendErrorNotification(player, "You need to play for at least 15 minutes.")
	return false
end

function RewardService:SetSahurRewardTime(player: Player)
	local hasGetSahur = PlayerDataHandler:Get(player, "rewards")

	if hasGetSahur["SAHUR"] then
		return
	end

	sahurRewardTime[player] = tick()
end

return RewardService
