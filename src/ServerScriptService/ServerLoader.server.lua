local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

-- Server Modules
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BridgeNet2 = require(ReplicatedStorage.Utility.BridgeNet2)

PlayerDataHandler:Init()

local positionsAndOrietations = {
	[1] = {
		Position = Vector3.new(1522.683, 6.381, 148.578),
		Orientation = Vector3.new(0, 0, 0),
	},

	[2] = {
		Position = Vector3.new(1635.847, 6.381, 147.997),
		Orientation = Vector3.new(0, 0, 0),
	},

	[3] = {
		Position = Vector3.new(1747.223, 6.381, 147.997),
		Orientation = Vector3.new(0, 0, 0),
	},

	[4] = {
		Position = Vector3.new(1522.04, 6.381, -8.738),
		Orientation = Vector3.new(0, 180, 0),
	},

	[5] = {
		Position = Vector3.new(1635.847, 6.381, -8.738),
		Orientation = Vector3.new(0, 180, 0),
	},

	[6] = {
		Position = Vector3.new(1747.223, 6.381, -8.738),
		Orientation = Vector3.new(0, 180, 0),
	},
}

local function ReplicatePlots()
	local plo1 = workspace:WaitForChild("Map"):WaitForChild("Plots"):WaitForChild("1")

	task.spawn(function()
--		local dummy = plo1:WaitForChild("Main"):WaitForChild("Worker"):WaitForChild("Dummy")
--		local humanoid = dummy:WaitForChild("Humanoid")

--		local animation = ReplicatedStorage.Animations.Iddle
--		local track = humanoid:LoadAnimation(animation)
--		track:Play()
	end)

	for i = 2, 6 do
		local newPlot = plo1:Clone()
		newPlot.Name = i

		local posData = positionsAndOrietations[i]
		local cf = CFrame.new(posData.Position)
			* CFrame.Angles(
				math.rad(posData.Orientation.X),
				math.rad(posData.Orientation.Y),
				math.rad(posData.Orientation.Z)
			)

		newPlot.Parent = workspace:WaitForChild("Map"):WaitForChild("Plots")
		newPlot:SetPrimaryPartCFrame(cf)

		-- Carregando Animação de Iddle
		task.spawn(function()
	--		local dummy = newPlot:WaitForChild("Main"):WaitForChild("Worker"):WaitForChild("Dummy")
	--		local humanoid = dummy:WaitForChild("Humanoid")

	--		local animation = ReplicatedStorage.Animations.Iddle
	--		local track = humanoid:LoadAnimation(animation)
	--		track:Play()
		end)

		-- Alterando o Conveyor

		task.spawn(function()
			--		local conveyor = newPlot:WaitForChild("Main"):WaitForChild("Conveyor")
			--		if i == 2 or i == 3 then
			--			conveyor.AssemblyLinearVelocity = Vector3.new(25, 0, 0)
			--		else
			--			conveyor.AssemblyLinearVelocity = Vector3.new(-25, 0, 0)
			--		end
		end)
	end

	workspace:SetAttribute("CONFIGURED_PLOTS", true)
end

local function configureFolders()
	local brainrotsFolder = workspace:WaitForChild("Developer"):WaitForChild("Brainrots")
	brainrotsFolder.Parent = ReplicatedStorage
end
configureFolders()

ReplicatePlots()

local function initializerBridge()
	local bridge = BridgeNet2.ReferenceBridge("Level")
end

initializerBridge()

local folder = ServerScriptService.Modules

for _, module in folder:GetChildren() do
	if module.Name == "Player" then
		continue
	end

	local file = require(module)

	-- If the module has an Init function, call it
	if file.Init then
		file:Init()
	end
end
