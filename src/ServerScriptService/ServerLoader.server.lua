local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

-- Server Modules
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BridgeNet2 = require(ReplicatedStorage.Utility.BridgeNet2)

PlayerDataHandler:Init()

local mutationColors = {
	["GOLDEN"] = {
		[1] = Color3.fromRGB(237, 178, 0),
		[2] = Color3.fromRGB(237, 194, 86),
		[3] = Color3.fromRGB(215, 111, 1),
		[4] = Color3.fromRGB(139, 74, 0),
		[5] = Color3.fromRGB(255, 164, 164),
		[6] = Color3.fromRGB(255, 244, 190),
	},

	["DIAMOND"] = {
		[1] = Color3.fromRGB(37, 196, 254),
		[2] = Color3.fromRGB(116, 212, 254),
		[3] = Color3.fromRGB(28, 137, 254),
		[4] = Color3.fromRGB(21, 64, 254),
		[5] = Color3.fromRGB(160, 162, 254),
		[6] = Color3.fromRGB(176, 255, 252),
	},
}

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

local function configureViewPorts()
	local function EnquadrarModel(viewPort: ViewportFrame, model: Model)
		if not model.PrimaryPart then
			model.PrimaryPart = model:FindFirstChildWhichIsA("BasePart")
		end

		if not model.PrimaryPart then
			warn("O modelo não possui nenhuma BasePart para calcular o enquadramento.")
			return
		end

		local camera = Instance.new("Camera")
		viewPort.CurrentCamera = camera

		-- Centro e tamanho total do modelo
		local cf, size = model:GetBoundingBox()
		local maxAxis = math.max(size.X, size.Y, size.Z)

		-- Campo de visão da câmera (em radianos)
		local fov = math.rad(camera.FieldOfView)

		-- Calcula a distância da câmera baseada no tamanho vertical e FOV
		local distancia = (maxAxis / 2) / math.tan(fov / 2)

		-- Posiciona a câmera olhando para o centro
		local cameraPosition = cf.Position + Vector3.new(0, size.Y * 0.4, distancia * 1.2)
		camera.CFrame = CFrame.lookAt(cameraPosition, cf.Position)

		camera.Parent = viewPort
	end

	local function createNormal(viewPort, brainrot)
		local newViewPort = viewPort:Clone()
		newViewPort.Name = brainrot.Name
		newViewPort.Parent = ReplicatedStorage.GUI.ViewPortFrames.NORMAL

		local newItem = brainrot:Clone()
		local rotation = CFrame.Angles(0, math.rad(130), 0)

		newItem:SetPrimaryPartCFrame(CFrame.new(Vector3.new(0, -3, 0)))
		newItem:SetPrimaryPartCFrame(newItem.PrimaryPart.CFrame * rotation)

		newItem.Parent = newViewPort

		EnquadrarModel(newViewPort, newItem)
	end

	local function createGolden(viewPort, brainrot)
		local newViewPort = viewPort:Clone()
		newViewPort.Name = brainrot.Name
		newViewPort.Parent = ReplicatedStorage.GUI.ViewPortFrames.GOLDEN

		local newItem = brainrot:Clone()
		local rotation = CFrame.Angles(0, math.rad(130), 0)

		newItem:SetPrimaryPartCFrame(CFrame.new(Vector3.new(0, -3, 0)))
		newItem:SetPrimaryPartCFrame(newItem.PrimaryPart.CFrame * rotation)

		newItem.Parent = newViewPort

		for _, value in newItem:GetDescendants() do
			if value:GetAttribute("Color") then
				value.Color = mutationColors["GOLDEN"][value:GetAttribute("Color")]
			end
		end

		EnquadrarModel(newViewPort, newItem)
	end

	local function createDiamond(viewPort, brainrot)
		local newViewPort = viewPort:Clone()
		newViewPort.Name = brainrot.Name
		newViewPort.Parent = ReplicatedStorage.GUI.ViewPortFrames.DIAMOND

		local newItem = brainrot:Clone()
		local rotation = CFrame.Angles(0, math.rad(130), 0)

		newItem:SetPrimaryPartCFrame(CFrame.new(Vector3.new(0, -3, 0)))
		newItem:SetPrimaryPartCFrame(newItem.PrimaryPart.CFrame * rotation)

		newItem.Parent = newViewPort

		for _, value in newItem:GetDescendants() do
			if value:GetAttribute("Color") then
				value.Color = mutationColors["DIAMOND"][value:GetAttribute("Color")]
			end
		end

		EnquadrarModel(newViewPort, newItem)
	end

	--// Exemplo de uso

	local brainrotsFolder = ReplicatedStorage.Brainrots
	local viewPort = ReplicatedStorage.GUI.ViewPortFrames.ViewPort

	for _, value in brainrotsFolder:GetChildren() do
		createNormal(viewPort, value)
		createGolden(viewPort, value)
		createDiamond(viewPort, value)
	end
end
configureFolders()

ReplicatePlots()

task.spawn(function()
	configureViewPorts()
end)

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
