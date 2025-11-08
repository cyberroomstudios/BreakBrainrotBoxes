local ProductFunctions = {}

local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local DeveloperProducts = require(ReplicatedStorage.Enums.DeveloperProducts)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local CrateService = require(ServerScriptService.Modules.CrateService)
local StockService = require(ServerScriptService.Modules.StockService)

ProductFunctions[DeveloperProducts:GetEnum("WOODEN_CRATE").Id] = function(receipt, player)
	CrateService:Give(player, "Wooden")
	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("WOODEN_CRATE").Id)
	return true
end

ProductFunctions[DeveloperProducts:GetEnum("TECH_CRATE").Id] = function(receipt, player)
	CrateService:Give(player, "Tech")
	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("TECH_CRATE").Id)
	return true
end

ProductFunctions[DeveloperProducts:GetEnum("STORM_CRATE").Id] = function(receipt, player)
	CrateService:Give(player, "Storm")
	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("STORM_CRATE").Id)
	return true
end

ProductFunctions[DeveloperProducts:GetEnum("STONE_CRATE").Id] = function(receipt, player)
	CrateService:Give(player, "Stone")
	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("STONE_CRATE").Id)
	return true
end

ProductFunctions[DeveloperProducts:GetEnum("LAVA_CRATE").Id] = function(receipt, player)
	CrateService:Give(player, "Lava")
	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("LAVA_CRATE").Id)
	return true
end

ProductFunctions[DeveloperProducts:GetEnum("ICE_CRATE").Id] = function(receipt, player)
	CrateService:Give(player, "Ice")
	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("ICE_CRATE").Id)
	return true
end

ProductFunctions[DeveloperProducts:GetEnum("GRASS_CRATE").Id] = function(receipt, player)
	CrateService:Give(player, "Grass")
	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("GRASS_CRATE").Id)
	return true
end

ProductFunctions[DeveloperProducts:GetEnum("GOLDEN_CRATE").Id] = function(receipt, player)
	CrateService:Give(player, "Golden")
	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("GOLDEN_CRATE").Id)
	return true
end

ProductFunctions[DeveloperProducts:GetEnum("DIAMOND_CRATE").Id] = function(receipt, player)
	CrateService:Give(player, "Diamond")
	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("DIAMOND_CRATE").Id)
	return true
end

ProductFunctions[DeveloperProducts:GetEnum("BRONZE_CRATE").Id] = function(receipt, player)
	CrateService:Give(player, "Bronze")
	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("BRONZE_CRATE").Id)
	return true
end

ProductFunctions[DeveloperProducts:GetEnum("RESTOCK_ALL").Id] = function(receipt, player)
	StockService:BuyRestockAll()
	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("RESTOCK_ALL").Id)
	return true
end

ProductFunctions[DeveloperProducts:GetEnum("RESTOCK_THIS").Id] = function(receipt, player)
	local result = StockService:RestockThis(player)

	if not result then
		return false
	end

	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("RESTOCK_THIS").Id)
	return true
end

function ProductFunctions:AddRobuxSpent(player: Player, productId: number)
	local info = MarketplaceService:GetProductInfo(productId, Enum.InfoType.Product)
	if info then
		local priceInRobux = info.PriceInRobux

		PlayerDataHandler:Update(player, "robuxSpent", function(current)
			return current + priceInRobux
		end)
	end
end

return ProductFunctions
