local GiftToPlayerService = {}

-- Init Bridg Net
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local GameNotificationService = require(ServerScriptService.Modules.GameNotificationService)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local ToolService = require(ServerScriptService.Modules.ToolService)
local CrateService = require(ServerScriptService.Modules.CrateService)
local BrainrotService = require(ServerScriptService.Modules.BrainrotService)
local bridge = BridgeNet2.ReferenceBridge("GiftToPlayerService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local cacheGift = {}

function GiftToPlayerService:Init()
	GiftToPlayerService:InitBridgeListener()
end

function GiftToPlayerService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "Accept" then
			local fromPlayer = data.data.FromPlayer
			local toPlayer = data.data.ToPlayer
			GiftToPlayerService:Accpet(fromPlayer, toPlayer)
		end

		if data[actionIdentifier] == "Refuse" then
			local fromPlayer = data.data.FromPlayer
			local toPlayer = data.data.ToPlayer
			GiftToPlayerService:Refuse(fromPlayer, toPlayer)
		end
	end
end

function GiftToPlayerService:Accpet(fromPlayer: Player, toPlayer: Player)
	-- Verifica se existe uma caixa do tipo no inventário do jogador
	local function hasCrate(crateName: string)
		local cratesBackpack = PlayerDataHandler:Get(fromPlayer, "cratesBackpack")

		for name, amount in cratesBackpack do
			if name == crateName and amount and amount > 0 then
				return true
			end
		end

		return false
	end

	local function hasBrainrot(brainrotName: string, mutationType: string)
		local brainrotsBackpack = PlayerDataHandler:Get(fromPlayer, "brainrotsBackpack")

		for _, brainrot in brainrotsBackpack do
			if brainrot.BrainrotName == brainrotName and brainrot.MutationType == mutationType then
				return true
			end
		end

		return false
	end

	-- Processa o presente se for Crate
	local function processCrate(crateName: string)
		if not fromPlayer.Parent then
			GameNotificationService:SendErrorNotification(toPlayer, "Gift Unavailable")
			return
		end
		-- Verifica e tira a caixa do jogador
		if hasCrate(crateName) then
			PlayerDataHandler:Update(fromPlayer, "cratesBackpack", function(current)
				current[crateName] = current[crateName] - 1

				return current
			end)

			ToolService:Consume(fromPlayer, "CRATE", crateName)

			-- Da a caixa de presente pro jogador
			CrateService:Give(toPlayer, crateName)

			return
		end

		GameNotificationService:SendErrorNotification(toPlayer, "Gift Unavailable")
	end

	local function processBrainrot(brainrotName: string, mutationType: string)
		if not fromPlayer.Parent then
			GameNotificationService:SendErrorNotification(toPlayer, "Gift Unavailable")
			return
		end

		if hasBrainrot(brainrotName, mutationType) then
			PlayerDataHandler:Update(fromPlayer, "brainrotsBackpack", function(current)
				for i, brainrot in ipairs(current) do
					if brainrot.BrainrotName == brainrotName and brainrot.MutationType == mutationType then
						table.remove(current, i) -- remove a primeira ocorrência
						break -- PARA após remover só a primeira
					end
				end

				return current
			end)

			ToolService:ConsumeBrainrotTool(fromPlayer, brainrotName)

			-- Da o brainrot de presente pro jogador
			BrainrotService:SaveBrainrotInBackpack(toPlayer, brainrotName, mutationType)

			return
		end

		GameNotificationService:SendErrorNotification(toPlayer, "Gift Unavailable")
	end

	for i = #cacheGift, 1, -1 do
		local gift = cacheGift[i]

		if gift.FromPlayer == fromPlayer and gift.ToPlayer == toPlayer then
			if gift.Type == "CRATE" then
				processCrate(gift.Name)
				return
			elseif string.find(gift.Type, "BRAINROT") then
				processBrainrot(gift.Name, gift.MutationType)
			end

			-- Remove da lista após processar
			table.remove(cacheGift, i)
		end
	end

	GameNotificationService:SendSuccessNotification(fromPlayer, toPlayer.Name .. " accepet your gift")
end

function GiftToPlayerService:Refuse(fromPlayer: Player, toPlayer: Player)
	GameNotificationService:SendErrorNotification(fromPlayer, toPlayer.Name .. " declined your gift")
end

function GiftToPlayerService:getItemInHand(player: Player)
	local character = player.Character
	if not character then
		return nil
	end

	for _, obj in ipairs(character:GetChildren()) do
		if obj:IsA("Tool") then
			return obj
		end
	end

	return nil
end
function GiftToPlayerService:AddProximity(player: Player)
	task.spawn(function()
		local character = player.Character or player.CharacterAdded:Wait()
		local hrp = character:WaitForChild("HumanoidRootPart")

		-- Evita duplicar
		if hrp:FindFirstChild("GiftProximity") then
			return hrp.GiftProximity
		end

		-- Criar attachment
		local attachment = Instance.new("Attachment")
		attachment.Name = "GiftProximity"
		attachment.Parent = hrp

		-- Criar ProximityPrompt
		local prompt = Instance.new("ProximityPrompt")
		prompt.Name = "GiveGiftPrompt"
		prompt.ActionText = "Gift"
		prompt.ObjectText = player.Name
		prompt.HoldDuration = 0.2
		prompt.RequiresLineOfSight = false
		prompt.MaxActivationDistance = 10
		prompt.Parent = attachment

		prompt.Triggered:Connect(function(fromPlayer)
			local toolFromHand = GiftToPlayerService:getItemInHand(fromPlayer)

			-- Verifica se o jogador está segurando alguma coisa na mão
			if not toolFromHand then
				GameNotificationService:SendErrorNotification(fromPlayer, "You’re not holding any item.")
				return
			end

			local canAcceptGift = PlayerDataHandler:Get(player, "gameSettings").acceptGift

			if not canAcceptGift then
				GameNotificationService:SendErrorNotification(fromPlayer, "The player has disabled gift receiving.")
				return
			end
			
			fromPlayer:SetAttribute("GIFT_ID", (fromPlayer:GetAttribute("GIFT_ID") or 0) + 1)
			local data = {
				FromPlayer = fromPlayer,
				ToPlayer = player,
				GiftId = fromPlayer:GetAttribute("GIFT_ID"),
				ToolId = toolFromHand:GetAttribute("ID"),
				Type = toolFromHand:GetAttribute("TOOL_TYPE"),
				Name = toolFromHand:GetAttribute("ORIGINAL_NAME"),
				MutationType = toolFromHand:GetAttribute("MUTATION_TYPE") or "",
			}

			table.insert(cacheGift, data)

			bridge:Fire(player, {
				[actionIdentifier] = "ShowGiftInvite",
				data = {
					FromPlayer = fromPlayer,
				},
			})
		end)
	end)
end

return GiftToPlayerService
