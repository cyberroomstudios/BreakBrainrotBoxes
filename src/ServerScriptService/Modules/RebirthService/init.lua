local RebirthService = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local Rebirths = require(ReplicatedStorage.Enums.Rebirths)

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local MoneyService = require(ServerScriptService.Modules.MoneyService)
local PlotService = require(ServerScriptService.Modules.PlotService)
local GameNotificationService = require(ServerScriptService.Modules.GameNotificationService)
local bridge = BridgeNet2.ReferenceBridge("RebirthService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

function RebirthService:Init()
	RebirthService:InitBridgeListener()
end

function RebirthService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "GetRebirth" then
			return RebirthService:GetRebirth(player)
		end
	end
end

function RebirthService:HasAllRequeriments(player: Player, rebirth)
	for _, requirement in rebirth.Requirements do
		if requirement.Type == "MONEY" then
			local currentMoney = PlayerDataHandler:Get(player, "money")
			if currentMoney < requirement.Amount then
				return false
			end
		end

		if requirement.Type == "BRAINROT" then
			local index = PlayerDataHandler:Get(player, "index")
			if not index[requirement.Name] then
				return false
			end
		end
	end

	return true
end

function RebirthService:GiveAllAwards(player: Player, rebirth)
	for _, award in rebirth.Awards do
		if award.Type == "PLOT" then
			--BaseService:CreateMoreFloor(player)
		end

		if award.Type == "MONEY" then
			MoneyService:GiveMoney(player, award.Amount)
		end
	end
end

function RebirthService:ClearAllItems(player: Players)
	PlotService:RemoveAll(player)
	MoneyService:ConsumeAllMoney(player)
end

function RebirthService:UpdateRebirth(player: Player)
	PlayerDataHandler:Update(player, "rebirth", function(current)
		return current + 1
	end)
end

function RebirthService:GetRebirth(player: Player)
	local currentRebirthNumber = PlayerDataHandler:Get(player, "rebirth")

	local nextRebirth = Rebirths[currentRebirthNumber + 1]

	if nextRebirth then
		local hasAllRequeriments = RebirthService:HasAllRequeriments(player, nextRebirth)

		if hasAllRequeriments then
			-- Atualiza o Indicador de Rebirth do jogador
			RebirthService:UpdateRebirth(player)

			-- Limpa todos os dados do rebirth
			RebirthService:ClearAllItems(player)

			-- Da todos os premios pro jogador
			RebirthService:GiveAllAwards(player, nextRebirth)

			-- Atualiza o Indicador de Rebirth do jogador
			PlayerDataHandler:Set(player, "rebirth", nextRebirth)
			player:SetAttribute("CURRENT_REBIRTH", nextRebirth)
			GameNotificationService:SendSuccessNotification(player, "Congratulations. You've achieved a Rebirth.")

			return
		end

		GameNotificationService:SendErrorNotification(player, "You do not have all the necessary requirements")
	end
end

function RebirthService:InitRebirth(player: Player)
	player:SetAttribute("CURRENT_REBIRTH", PlayerDataHandler:Get(player, "rebirth"))
	PlotService:InitRebirth(player)
end
return RebirthService
