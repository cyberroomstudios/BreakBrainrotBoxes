local OfflineMoneyService = {}

local ServerScriptService = game:GetService("ServerScriptService")

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("OfflineService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local MoneyService = require(ServerScriptService.Modules.MoneyService)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local Brainrots = require(ReplicatedStorage.Enums.Brainrots)

function OfflineMoneyService:Init()
	OfflineMoneyService:InitBridgeListener()
end

function OfflineMoneyService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "GetOfflineMoney" then
			local money = player:GetAttribute("OFFLINE_MONEY")

			if money then
				player:SetAttribute("OFFLINE_MONEY", 0)
				MoneyService:GiveMoney(player, money, false)
			end
		end
	end
end

function OfflineMoneyService:StartOfflineMoney(player: Player)
	local timeLeftGame = PlayerDataHandler:Get(player, "timeLeftGame")
	if timeLeftGame and timeLeftGame > 0 then
		local now = os.time()
		local secondsPassed = now - timeLeftGame
		local totalMoney = 0
		local brainrotsMap = PlayerDataHandler:Get(player, "brainrotsMap")
		local hasBrainrotCashMultiplier = PlayerDataHandler:Get(player, "hasBrainrotCashMultiplier")
		local cashMultiplier = PlayerDataHandler:Get(player, "cashMultiplier")

		for _, value in brainrotsMap do
			local brainrotName = value.BrainrotName
			local moneyPerSecond = Brainrots[brainrotName].MoneyPerSecond
			moneyPerSecond = (hasBrainrotCashMultiplier and moneyPerSecond * 2) or moneyPerSecond

			local totalMoneyBrainrot = moneyPerSecond * secondsPassed
			totalMoney = totalMoney + (totalMoneyBrainrot * cashMultiplier)
		end

		player:SetAttribute("OFFLINE_MONEY", totalMoney)
	end
end

return OfflineMoneyService
