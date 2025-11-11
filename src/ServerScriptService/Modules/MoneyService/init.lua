local MoneyService = {}

local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)

function MoneyService:GiveMoney(player: Player, amount: number)
	PlayerDataHandler:Update(player, "money", function(current)
		local newMoney = current + amount

		player:SetAttribute("MONEY", newMoney)

		return newMoney
	end)
end

function MoneyService:ConsumeMoney(player: Player, amount: number)
	PlayerDataHandler:Update(player, "money", function(current)
		local newMoney = current - amount

		player:SetAttribute("MONEY", newMoney)

		return newMoney
	end)
end

function MoneyService:ConsumeAllMoney(player: Player)
	PlayerDataHandler:Set(player, "money", 0)
	player:SetAttribute("MONEY", 0)
end

function MoneyService:HasMoney(player: Player, amount: number)
	local currentMoney = PlayerDataHandler:Get(player, "money")

	return amount <= currentMoney
end

function MoneyService:GiveInitialMoney(player: Player)
	if PlayerDataHandler:Get(player, "totalPlaytime") == 0 then
		MoneyService:GiveMoney(player, 1000)
	end
end

function MoneyService:GiveCashMultiplier(player: Player, incrementValue: number)
	PlayerDataHandler:Update(player, "cashMultiplier", function(current)
		return current + incrementValue
	end)

	player:SetAttribute("CASH_MULTIPLIER", PlayerDataHandler:Get(player, "cashMultiplier"))
end

function MoneyService:GiveBrainrotCashMultiplier(player: Player)
	PlayerDataHandler:Update(player, "hasBrainrotCashMultiplier", function(current)
		player:SetAttribute("HAS_BRAINROT_CASH_MULTIPLIER", true)
		return true
	end)
end

return MoneyService
