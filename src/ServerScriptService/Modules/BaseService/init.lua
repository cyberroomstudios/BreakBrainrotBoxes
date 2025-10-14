local BaseService = {}

local ServerScriptService = game:GetService("ServerScriptService")

local UtilService = require(ServerScriptService.Modules.UtilService)

local positionYFloor = 26

local allocating = false

function BaseService:Init() end

function BaseService:Allocate(player: Player)
	if allocating then
		return false
	end
	allocating = true

	-- Obtem todas as places
	local places = workspace.Map.Plots:GetChildren()

	-- Embaralha a tabela
	for i = #places, 2, -1 do
		local j = math.random(i)
		places[i], places[j] = places[j], places[i]
	end

	-- Procura uma base não ocupada
	for _, place in ipairs(places) do
		if not place:GetAttribute("BUSY") then
			-- Inicializa os atributos da base
			place:SetAttribute("BUSY", true)
			place:SetAttribute("OWNER", player.UserId)

			player:SetAttribute("BASE", place.Name)
			player:SetAttribute("BASE_CFRAME", place.Spawn.CFrame)
			BaseService:CreateCrateShopCFrameAttribute(player)
			BaseService:MoveToBase(player, place.Spawn)

			break
		end
	end

	allocating = false

	return true
end

-- Leva o Jogador para o Spawn da Base
function BaseService:MoveToBase(player, baseSpawn)
	local character = player.Character
	if character and character:FindFirstChild("HumanoidRootPart") then
		character.HumanoidRootPart.CFrame = baseSpawn.CFrame
	end
end

function BaseService:GetBase(player: Player)
	local places = workspace.Map.BaseMaps:GetChildren()

	for _, value in places do
		if value.Name == player:GetAttribute("BASE") then
			return value
		end
	end
end

function BaseService:CreateCrateShopCFrameAttribute(player: Player)
	local crateShop = UtilService:WaitForDescendants(workspace, "Map", "Booths", "Shop")

	if crateShop then
		player:SetAttribute("CRATE_SHOP_CFRAME", crateShop.Spawn.CFrame)
	end
end

return BaseService
