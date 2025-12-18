local GiftRobuxController = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("GiftRobuxService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local Players = game:GetService("Players")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local DeveloperProductController = require(Players.LocalPlayer.PlayerScripts.ClientModules.DeveloperProductController)

local screen
local onlinePlayersScrollingFrame

function GiftRobuxController:Init()
	GiftRobuxController:CreateReferences()
end

function GiftRobuxController:CreateReferences()
	screen = UIReferences:GetReference("ONLINE_PLAYERS")
	onlinePlayersScrollingFrame = UIReferences:GetReference("ONLINE_PLAYERS_SCROLLING_FRAME")
end

function GiftRobuxController:Open(data)
	screen.Visible = true
	GiftRobuxController:BuildScreen()
end

function GiftRobuxController:Close()
	screen.Visible = false
end

function GiftRobuxController:GetScreen()
	return screen
end

function GiftRobuxController:BuildScreen()
	-- Limpa a tela

	for _, value in onlinePlayersScrollingFrame:GetChildren() do
		if value:GetAttribute("DELETE-ME") then
			value:Destroy()
		end
	end

	for _, player in Players:GetPlayers() do
		pcall(function()
			local template = onlinePlayersScrollingFrame.Template:Clone()

			template.Content.ItemNameFrame.ItemName.Text = player.Name

			local content, isReady = Players:GetUserThumbnailAsync(
				player.UserId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size420x420
			)

			template.Content.GIFT.Button.MouseButton1Click:Connect(function()
				print(player.UserId)

				local result = bridge:InvokeServerAsync({
					[actionIdentifier] = "AddIntention",
					data = {
						FromPlayer = Players.LocalPlayer,
						ToPlayer = player,
					},
				})
				DeveloperProductController:OpenPaymentRequestScreen(player:GetAttribute("GIFT"))
			end)

			template.Content.ImageLabel.Image = content

			template.Visible = true
			template:SetAttribute("DELETE-ME", true)
			template.Parent = onlinePlayersScrollingFrame
		end)
	end
end
return GiftRobuxController
