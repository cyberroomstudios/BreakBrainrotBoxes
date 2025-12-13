local GiftToPlayerController = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("GiftToPlayerService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net
local Players = game:GetService("Players")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)

local player = Players.LocalPlayer

local GiftInviteContainer

function GiftToPlayerController:Init()
	GiftToPlayerController:CreateReferences()
	GiftToPlayerController:InitBridgeListener()
end

function GiftToPlayerController:CreateReferences()
	GiftInviteContainer = UIReferences:GetReference("GIFT_INVITE_CONTAINER")
end

function GiftToPlayerController:InitBridgeListener()
	bridge:Connect(function(response)
		if response[actionIdentifier] == "ShowGiftInvite" then
			local fromPlayer = response.data.FromPlayer
			GiftToPlayerController:ShowGiftInvite(fromPlayer)
		end
	end)
end

function GiftToPlayerController:RemoveProximity()
	pcall(function()
		local character = player.Character or player.CharacterAdded:Wait()
		local hrp = character:WaitForChild("HumanoidRootPart")
		if hrp:FindFirstChild("GiftProximity") then
			local giftProximity = hrp:FindFirstChild("GiftProximity")
			giftProximity:Destroy()
		end
	end)
end

function GiftToPlayerController:ShowGiftInvite(fromPlayer: Player)
	local newInvite = GiftInviteContainer.Template:Clone()
	local main = newInvite:WaitForChild("Main"):WaitForChild("Main")
	local textInvite = main:WaitForChild("TextInvite")
	local buttons = main:WaitForChild("Buttons")
	local acceptButton = buttons:WaitForChild("Accept"):WaitForChild("TextButton")
	local refuseButton = buttons:WaitForChild("Refuse"):WaitForChild("TextButton")

	textInvite.Text = fromPlayer.Name .. " Wants To Give You a Gift"

	acceptButton.MouseButton1Click:Connect(function()
		newInvite:Destroy()
		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "Accept",
			data = {
				FromPlayer = fromPlayer,
				ToPlayer = player,
			},
		})
	end)

	refuseButton.MouseButton1Click:Connect(function()
		newInvite:Destroy()
		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "Refuse",
			data = {
				FromPlayer = fromPlayer,
				ToPlayer = player,
			},
		})
	end)

	newInvite.Visible = true
	newInvite.Parent = GiftInviteContainer
end

return GiftToPlayerController
