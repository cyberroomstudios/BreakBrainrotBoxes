local GiftRobuxService = {}

-- Init Bridg Net
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local CrateService = require(ServerScriptService.Modules.CrateService)
local bridge = BridgeNet2.ReferenceBridge("GiftRobuxService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local giftIntetions = {}

function GiftRobuxService:Init()
	GiftRobuxService:InitBridgeListener()
end

function GiftRobuxService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "AddIntention" then
			local fromPlayer = data.data.FromPlayer
			local toPlayer = data.data.ToPlayer

			GiftRobuxService:AddIntention(fromPlayer, toPlayer)
		end
	end
end
function GiftRobuxService:AddIntention(fromPlayer: Player, toPlayer: Player)
	local data = {
		FromPlayer = fromPlayer,
		ToPlayer = toPlayer,
	}

	table.insert(giftIntetions, data)
end

function GiftRobuxService:GiveGift(fromPlayer: Player, giftType: string)
	local toPlayer = nil
	local hasIntention = false
	for i = #giftIntetions, 1, -1 do
		local giftIntention = giftIntetions[i]

		if giftIntention.FromPlayer == fromPlayer then
			hasIntention = true
			toPlayer = giftIntention.ToPlayer
			table.remove(giftIntetions, i)
			break
		end
	end

	if hasIntention then
		if toPlayer.Parent then
			print(toPlayer.Name .. "Ganhou um presente: " .. giftType)
			GiftRobuxService:Give(toPlayer, giftType)
		elseif fromPlayer.Parent then
			GiftRobuxService:Give(fromPlayer, giftType)
		end
	end
end

function GiftRobuxService:Give(player: Player, giftType: string)
	if giftType == "GIT_EXCLUSIVE_BRAINROT_PACK_1X" then
		CrateService:Give(player, "CandyCane")
		return
	end

	if giftType == "GIT_EXCLUSIVE_BRAINROT_PACK_5X" then
		for i = 1, 5, 1 do
			CrateService:Give(player, "CandyCane")
		end
		return
	end

	if giftType == "GIT_EXCLUSIVE_BRAINROT_PACK_10X" then
		for i = 1, 10, 1 do
			CrateService:Give(player, "CandyCane")
		end
		return
	end

	if giftType == "GIFT_LUCKY_CHESTS_MYTHICAL" then
		CrateService:Give(player, "LuckyChestsMythical")
	end

	if giftType == "GIFT_LUCKY_CHESTS_GODLY" then
		CrateService:Give(player, "LuckyChestsGodly")
	end

	if giftType == "GIFT_LUCKY_CHESTS_SECRET" then
		CrateService:Give(player, "LuckyChestsSecret")
	end
end

return GiftRobuxService
