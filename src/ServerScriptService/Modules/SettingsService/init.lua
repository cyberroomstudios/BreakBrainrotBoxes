local SettingsService = {}

-- Init Bridg Net
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local bridge = BridgeNet2.ReferenceBridge("SettingsService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

function SettingsService:Init()
	SettingsService:InitBridgeListener()
end

function SettingsService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "ToggleBackgroundMusic" then
			SettingsService:ToggleBackgroundMusic(player)
		end

		if data[actionIdentifier] == "ToggleSoundEffect" then
			SettingsService:ToggleSoundEffect(player)
		end

		if data[actionIdentifier] == "ToggleAcceptGift" then
			SettingsService:ToggleAcceptGift(player)
		end
	end
end

function SettingsService:ToggleBackgroundMusic(player: Player)
	PlayerDataHandler:Update(player, "gameSettings", function(current)
		local oldValue = current.backgroundMusic
		local newValue = not oldValue
		current.backgroundMusic = newValue
		player:SetAttribute("SETTINGS_BACKGROUND_MUSIC", newValue)
		return current
	end)
end

function SettingsService:ToggleSoundEffect(player: Player)
	PlayerDataHandler:Update(player, "gameSettings", function(current)
		local oldValue = current.soundEffect
		local newValue = not oldValue
		current.soundEffect = newValue

		player:SetAttribute("SETTINGS_SOUND_EFFECT", newValue)
		return current
	end)
end

function SettingsService:ToggleAcceptGift(player: Player)
	PlayerDataHandler:Update(player, "gameSettings", function(current)
		local oldValue = current.acceptGift
		local newValue = not oldValue
		current.acceptGift = newValue

		player:SetAttribute("SETTINGS_ACCEPT_GIFT", newValue)
		return current
	end)
end

return SettingsService
