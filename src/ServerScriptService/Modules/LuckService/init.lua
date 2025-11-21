local LuckService = {}

local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)

local serverLuck = 1

local countdownTask = nil
local cancelFlag = nil
local TIME = 20
local serverLuck = 1
local timerId = 0

function LuckService:Init() end

function LuckService:GetLuckFromPlayer(player: Player)
	local luck = PlayerDataHandler:Get(player, "luck")
	return luck
end

function LuckService:AddPlayerLuck(player: Player, newLuck: number)
	PlayerDataHandler:Update(player, "luck", function(current)
		return current + newLuck
	end)
end

function LuckService:UpServerLuck(nextServerLuck)
	if not nextServerLuck then
		nextServerLuck = serverLuck * 2
	end

	if (serverLuck * 2) ~= nextServerLuck then
		return false
	end

	serverLuck = nextServerLuck
	print("Novo luck do servidor:", nextServerLuck)
	workspace:SetAttribute("SERVER_LUCK", nextServerLuck)

	-- Novo token
	timerId += 1
	local myId = timerId

	task.spawn(function()
		local remaining = TIME

		while remaining > 0 do
			-- Timer antigo? MORRE na hora
			if myId ~= timerId then
				return
			end

			workspace:SetAttribute("TIME_SERVER_LUCK", remaining)
			task.wait(1)
			remaining -= 1
		end

		-- Garantir que só o timer atual roda o final
		if myId ~= timerId then
			return
		end

		serverLuck = 1
		workspace:SetAttribute("SERVER_LUCK", serverLuck)
	end)
end

return LuckService
