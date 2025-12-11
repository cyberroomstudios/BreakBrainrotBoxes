local RebirthService = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local Rebirths = require(ReplicatedStorage.Enums.Rebirths)

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("RebirthService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local MoneyService = require(ServerScriptService.Modules.MoneyService)
local PlotService = require(ServerScriptService.Modules.PlotService)
local GameNotificationService = require(ServerScriptService.Modules.GameNotificationService)
local BrainrotService = require(ServerScriptService.Modules.BrainrotService)
local CrateService = require(ServerScriptService.Modules.CrateService)
local WorkerService = require(ServerScriptService.Modules.WorkerService)

function RebirthService:Init()
	RebirthService:InitBridgeListener()
end

function RebirthService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "GetRebirth" then
			return RebirthService:GetRebirth(player)
		end

		if data[actionIdentifier] == "GetInfoRebirth" then
			return RebirthService:GetInfoRebirth(player)
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
			if not RebirthService:HasBrainrot(player, requirement.Name) then
				return false
			end
		end
	end

	return true
end

function RebirthService:GiveAllAwards(player: Player, rebirth)
	for _, award in rebirth.Awards do
		if award.Type == "PLOT" then
			RebirthService:GiveRebirthPlot(player)
		end

		if award.Type == "MONEY" then
			MoneyService:GiveMoney(player, award.Amount, true)
		end

		if award.Type == "CASH_MULTIPLIER" then
			MoneyService:GiveCashMultiplier(player, award.Amount)
		end
	end
end

function RebirthService:GetInfoRebirth(player)
	local currentRebirth = PlayerDataHandler:Get(player, "rebirth")
	local nextRebirth = currentRebirth + 1

	if not Rebirths[nextRebirth] then
		return false
	end

	return {
		Requirements = Rebirths[nextRebirth].Requirements,
		Awards = Rebirths[nextRebirth].Awards,
		Ready = RebirthService:GetReadyInfoRebirth(player, Rebirths[nextRebirth].Requirements),
	}
end

function RebirthService:GetReadyInfoRebirth(player, requirements)
	local readyList = {}

	for _, requirement in requirements do
		if requirement.Type == "MONEY" then
			readyList["MONEY"] = MoneyService:HasMoney(player, requirement.Amount)
		end

		if requirement.Type == "BRAINROT" then
			readyList[requirement.Name] = RebirthService:HasBrainrot(player, requirement.Name)
		end
	end

	return readyList
end
function RebirthService:GiveRebirthPlot(player: Player)
	local currentRebirth = PlayerDataHandler:Get(player, "rebirth")
	local releaseSlotIndex = PlayerDataHandler:Get(player, "releaseSlotIndex")

	-- Libera o Plot
	PlotService:RelesePlot(player, releaseSlotIndex + 1)

	-- Atualiza a base do jogador
	PlayerDataHandler:Set(player, "rebirth", currentRebirth + 1)
	PlayerDataHandler:Set(player, "releaseSlotIndex", releaseSlotIndex + 1)
end

function RebirthService:ClearAllItems(player: Players)
	MoneyService:ConsumeAllMoney(player)
	BrainrotService:ConsumeAllInHand(player)

	WorkerService:ClearAllCrates(player)
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
			PlayerDataHandler:Set(player, "rebirth", currentRebirthNumber + 1)
			player:SetAttribute("CURRENT_REBIRTH", currentRebirthNumber + 1)
			GameNotificationService:SendSuccessNotification(player, "Congratulations. You've achieved a Rebirth.")

			return true
		end

		GameNotificationService:SendErrorNotification(player, "You do not have all the necessary requirements")
	end
end

function RebirthService:InitRebirth(player: Player)
	player:SetAttribute("CURRENT_REBIRTH", PlayerDataHandler:Get(player, "rebirth"))
	PlotService:InitRebirth(player)
end

function RebirthService:HasBrainrot(player: Player, brainrotName)
	local brainrotsMap = PlayerDataHandler:Get(player, "brainrotsMap")
	local brainrotsBackpack = PlayerDataHandler:Get(player, "brainrotsBackpack")

	for _, value in brainrotsMap do
		if value.BrainrotName == brainrotName then
			return true
		end
	end

	for _, value in brainrotsBackpack do
		if value.BrainrotName == brainrotName then
			return true
		end
	end

	return false
end

return RebirthService
