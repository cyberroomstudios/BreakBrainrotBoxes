local FunnelService = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("FunnelService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local ServerScriptService = game:GetService("ServerScriptService")
local AnalyticsService = game:GetService("AnalyticsService")
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)

local steps = {
	["ON_GAME"] = {
		Id = 1,
		Name = "Entered The Game",
	},

	["LOADING_ALL_GAME"] = {
		Id = 2,
		Name = "The Entire Game Has Been Loaded.",
	},

	["TO_CRATE"] = {
		Id = 3,
		Name = "Went to The Shop Area",
	},

	["OPEN_CRATE_SHOP_UI"] = {
		Id = 4,
		Name = "Opened The Shop Crate UI",
	},

	["BUY_CRATE"] = {
		Id = 5,
		Name = "Bought a Crate",
	},

	["TO_BASE"] = {
		Id = 6,
		Name = "Went To Base",
	},

	["PLACE_CRATE"] = {
		Id = 7,
		Name = "Placed The Crate",
	},

	["OPEN_CRATE"] = {
		Id = 8,
		Name = "Waited For The Crate to be broken",
	},

	["COLLECT_MONEY"] = {
		Id = 9,
		Name = "Collected Money",
	},

	["TO_UPGRADE"] = {
		Id = 10,
		Name = "Went To Upgrade Area",
	},

	["BUY_CAPACITY_UPGRADE"] = {
		Id = 11,
		Name = "Purchased the capacity upgrade",
	},
}
function FunnelService:Init()
	FunnelService:InitBridgeListener()
end

function FunnelService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "AddEvent" then
			local eventName = data.data.Name

			FunnelService:AddEvent(player, eventName)
		end
	end
end

function FunnelService:AddEvent(player: Player, eventName: string)
	if not steps[eventName] then
		return
	end

	if player:GetAttribute("FUNNEL_" .. eventName) then
		return
	end

	local allFunelEventsFromData = PlayerDataHandler:Get(player, "funnelEvents")
	if allFunelEventsFromData and allFunelEventsFromData["FUNNEL_" .. eventName] then
		return
	end

	FunnelService:UpgradeData(player, eventName)
	print("Event: " .. eventName)
	AnalyticsService:LogOnboardingFunnelStepEvent(player, steps[eventName].Id, steps[eventName].Name)
end

function FunnelService:UpgradeData(player: Player, eventName: string)
	player:SetAttribute("FUNNEL_" .. eventName)

	PlayerDataHandler:Update(player, "funnelEvents", function(current)
		current["FUNNEL_" .. eventName] = true
		return current
	end)
end

return FunnelService
