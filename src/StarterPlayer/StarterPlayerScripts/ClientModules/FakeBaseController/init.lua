local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)

local FakeBaseController = {}

function FakeBaseController:Init(data)
	if data.totalPlaytime < 60 then
		FakeBaseController:Configure()
	end
end

function FakeBaseController:Configure()
	local realBase = ClientUtil:WaitForDescendants(workspace, "Map", "Plots", "2")

	local fakeBase = ReplicatedStorage.Model.FakeBase["2"]
	fakeBase.Parent = realBase.Parent

	realBase:Destroy()

	local breaker =
		ClientUtil:WaitForDescendants(fakeBase, "Main", "BreakersArea", "Containers", "Container", "Breaker", "Breaker")
	local animationsFolder = ReplicatedStorage.Animations.Breakers["Ninja"]

	-- Definir a animação com base na existência do Humanoid
	local humanoid = breaker:FindFirstChild("Humanoid")
	local animationController
	local animator
	local animation

	if humanoid then
		animator = humanoid
		animation = animationsFolder.Idle
		local track = animator:LoadAnimation(animation)
		track.Looped = true
		track.Priority = Enum.AnimationPriority.Idle
		track:Play()
	end

	task.spawn(function()
		while true do
			animator = humanoid
			animation = animationsFolder.Attack
			local track = animator:LoadAnimation(animation)
			track.Looped = false
			track.Priority = Enum.AnimationPriority.Action
			track:Play()
			task.wait(5)
		end
	end)
end
return FakeBaseController
