local LuckController = {}

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)

local serverLuckLabel

function LuckController:Init()
	LuckController:CreateReferences()
	LuckController:ConfigurePosition()
	LuckController:ConfigureViewLuck()
	LuckController:InitAttributeListener()
end

function LuckController:CreateReferences()
	serverLuckLabel = UIReferences:GetReference("SERVER_LUCK_LABEL")
end

function LuckController:ConfigureViewLuck()
	local serverLuck = workspace:GetAttribute("SERVER_LUCK")

	if serverLuck and serverLuck > 1 then
		serverLuckLabel.Visible = true
	else
		serverLuckLabel.Visible = false
	end
end
function LuckController:ConfigurePosition()
	local isMobile = UserInputService.TouchEnabled
		and not UserInputService.KeyboardEnabled
		and not UserInputService.MouseEnabled

	if isMobile then
		serverLuckLabel.Position = UDim2.fromScale(0.891, 0.05)
	else
		serverLuckLabel.Position = UDim2.fromScale(0.891, 0.883)
	end
end

function LuckController:InitAttributeListener()
	local function formatTime(seconds)
		local minutes = math.floor(seconds / 60)
		local secs = seconds % 60
		return string.format("%02d:%02d", minutes, secs)
	end

	local cancelToken = 0
	local activeTimer = nil

	workspace:GetAttributeChangedSignal("SERVER_LUCK"):Connect(function()
		local serverLuck = workspace:GetAttribute("SERVER_LUCK")

		-- Cancela timers anteriores
		cancelToken += 1
		local myToken = cancelToken

		if serverLuck and serverLuck > 1 then
			-- Registrar como timer ativo
			activeTimer = myToken

			serverLuckLabel.Visible = true
			serverLuckLabel.ServerLuck.Text = serverLuck .. "X"

			task.spawn(function()
				local timeServerLuck = workspace:GetAttribute("TIME_SERVER_LUCK") or (60 * 15)

				while timeServerLuck > 0 do
					-- ⛔ Morre se não for o timer atual
					if myToken ~= cancelToken or activeTimer ~= myToken then
						return
					end

					serverLuckLabel.Time.Text = formatTime(timeServerLuck)

					timeServerLuck -= 1
					task.wait(1)
				end

				-- ⛔ Só esse timer pode esconder o label
				if activeTimer == myToken then
					serverLuckLabel.Visible = false
					activeTimer = nil
				end
			end)
		else
			-- Luck voltou ao normal → cancelar completamente
			activeTimer = nil
			serverLuckLabel.Visible = false
		end
	end)
end

return LuckController
