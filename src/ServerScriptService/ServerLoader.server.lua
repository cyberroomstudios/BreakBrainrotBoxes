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
		[1] = Color3.fromRGB(237, 178, 0),
		[2] = Color3.fromRGB(237, 194, 86),
		[3] = Color3.fromRGB(215, 111, 1),
		[4] = Color3.fromRGB(139, 74, 0),
		[5] = Color3.fromRGB(237, 194, 86), -- Lucky Block wings
		[6] = Color3.fromRGB(255, 251, 131), -- Lucky Block question mark
		[7] = Color3.fromRGB(255, 178, 0), -- Lucky Block main color
		[8] = Color3.fromRGB(215, 111, 1), -- Brainrot God Lucky Block main color
	},
}

local positionsAndOrietations = {
	[1] = {
		Position = Vector3.new(1522.683, 7.356, 148.578),
		Orientation = Vector3.new(0, 0, 0),
	},

	[2] = {
		Position = Vector3.new(1635.847, 7.356, 147.997),
		Orientation = Vector3.new(0, 0, 0),
	},

	[3] = {
		Position = Vector3.new(1747.223, 7.356, 147.997),
		Orientation = Vector3.new(0, 0, 0),
	},

	[4] = {
		Position = Vector3.new(1522.04, 7.356, -8.738),
		Orientation = Vector3.new(0, 180, 0),
	},

	[5] = {
		Position = Vector3.new(1635.847, 7.356, -8.738),
		Orientation = Vector3.new(0, 180, 0),
	},

	[6] = {
		Position = Vector3.new(1747.223, 7.356, -8.738),
		Orientation = Vector3.new(0, 180, 0),
	},
}

local function replicatePlots()
	local plo1 = workspace:WaitForChild("Map"):WaitForChild("Plots"):WaitForChild("1")

	local plotBase = plo1:Clone()
	plotBase.Parent = ReplicatedStorage.Model.Plot
	plotBase.Name = "PlotBase"

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
	end

	workspace:SetAttribute("CONFIGURED_PLOTS", true)
end

local function configureFolders()
	local brainrotsFolder = workspace:WaitForChild("Developer"):WaitForChild("Brainrots")
	brainrotsFolder.Parent = ReplicatedStorage

	local workersFolder = workspace:WaitForChild("Developer"):WaitForChild("Breakers")
	workersFolder.Parent = ReplicatedStorage

	local cratesFolder = workspace:WaitForChild("Developer"):WaitForChild("Crates")
	cratesFolder.Parent = ReplicatedStorage

	local cratesToolsFolder = workspace:WaitForChild("Developer"):WaitForChild("CratesTools")
	cratesToolsFolder.Parent = ReplicatedStorage
end

local function configureCrates()
	local cratesFolder = ReplicatedStorage.Crates:GetChildren()

	for _, value in cratesFolder do
		local hp = value.HP
		local billboard = ReplicatedStorage.Model.Billboards.CrateHP:Clone()
		billboard.Parent = hp
	end
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

	local function createCrate(viewPort, crate)
		local newViewPort = viewPort:Clone()
		newViewPort.Name = crate.Name
		newViewPort.Parent = ReplicatedStorage.GUI.ViewPortFrames.CRATES

		local newItem = crate:Clone()

		newItem:ScaleTo(1.35)

		-- Define a posição desejada
		local position = Vector3.new(0, 0, 0)
		local rotX, rotY, rotZ = -15, 130, 0
		local rotation = CFrame.Angles(math.rad(rotX), math.rad(rotY), math.rad(rotZ))

		-- Aplica a transformação
		newItem:PivotTo(CFrame.new(position) * rotation)
		newItem.Parent = newViewPort
	end

	--// Exemplo de uso

	local brainrotsFolder = ReplicatedStorage.Brainrots
	local cratesFolder = ReplicatedStorage.Crates
	local viewPort = ReplicatedStorage.GUI.ViewPortFrames.ViewPort

	for _, value in brainrotsFolder:GetChildren() do
		createNormal(viewPort, value)
		createGolden(viewPort, value)
		createDiamond(viewPort, value)
	end

	for _, value in cratesFolder:GetChildren() do
		createCrate(viewPort, value)
	end
end


configureFolders()

configureCrates()

replicatePlots()

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
