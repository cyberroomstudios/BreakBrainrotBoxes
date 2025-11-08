local GameNotificationService = {}

-- Init Bridg Net
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("GameNotificationService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

function GameNotificationService:Init() end

function GameNotificationService:SendWarnNotification(player: Player, message: string)
	bridge:Fire(player, {
		[actionIdentifier] = "ShowWarnNotification",
		data = {
			Message = message,
		},
	})
end

function GameNotificationService:SendErrorNotification(player: Player, message: string)
	bridge:Fire(player, {
		[actionIdentifier] = "ShowErrorNotification",
		data = {
			Message = message,
		},
	})
end

function GameNotificationService:SendSuccessNotification(player: Player, message: string)
	bridge:Fire(player, {
		[actionIdentifier] = "ShowSuccessNotificaion",
		data = {
			Message = message,
		},
	})
end

function GameNotificationService:SendNewBrainrotNotification(player: Player, brainrotType: string)
	bridge:Fire(player, {
		[actionIdentifier] = "ShowNewBrainrotNotificaion",
		data = {
			BrainrotType = brainrotType,
		},
	})
end

function GameNotificationService:SendCrateStoreRestockedNotification()
	local players = Players:GetPlayers()

	for _, player in players do
		bridge:Fire(player, {
			[actionIdentifier] = "ShowCrateStoreRestocked",
		})
	end
end

return GameNotificationService
