local DeveloperProducts = {}

export type DeveloperProduct = {
	Name: string,
	Id: number,
}

DeveloperProducts.ENUM = {

	-- Crates
	WOODEN_CRATE = {
		Name = "WOODEN_CRATE",
		Id = 3449898710,
	},
	TECH_CRATE = {
		Name = "TECH_CRATE",
		Id = 3449898709,
	},
	STORM_CRATE = {
		Name = "STORM_CRATE",
		Id = 3449898702,
	},
	STONE_CRATE = {
		Name = "STONE_CRATE",
		Id = 3449898703,
	},
	LAVA_CRATE = {
		Name = "LAVA_CRATE",
		Id = 3449898700,
	},
	ICE_CRATE = {
		Name = "ICE_CRATE",
		Id = 3449898699,
	},
	GRASS_CRATE = {
		Name = "GRASS_CRATE",
		Id = 3449898705,
	},
	GOLDEN_CRATE = {
		Name = "GOLDEN_CRATE",
		Id = 3449898701,
	},
	DIAMOND_CRATE = {
		Name = "DIAMOND_CRATE",
		Id = 3449898704,
	},
	BRONZE_CRATE = {
		Name = "BRONZE_CRATE",
		Id = 3449898696,
	},

	-- Loja
	RESTOCK_ALL = {
		Name = "RESTOCK_ALL",
		Id = 3449933802,
	},

	RESTOCK_THIS = {
		Name = "RESTOCK_THIS",
		Id = 3450633878,
	},

	-- Quebradores
	NOOB_BREAKER = {
		Name = "NOOB_BREAKER",
		Id = 3450657835,
	},
	BASEBALL_BREAKER = {
		Name = "BASEBALL_BREAKER",
		Id = 3450657831,
	},
	NINJA_BREAKER = {
		Name = "NINJA_BREAKER",
		Id = 3450657834,
	},
	WARRIOR_BREAKER = {
		Name = "WARRIOR_BREAKER",
		Id = 3450657833,
	},
	SOLDIER_BREAKER = {
		Name = "SOLDIER_BREAKER",
		Id = 3450657830,
	},

	-- Promoções

	SAHUR_BREAKER = {
		Name = "SAHUR_BREAKER",
		Id = 3455868462,
	},

	OP_CRATE = {
		Name = "OP_CRATE",
		Id = 3455930719,
	},

	OP_CRATE_STORM = {
		Name = "OP_CRATE",
		Id = 3477076441,
	},

	-- SERVER LUCKS
	SERVER_LUCK_2X = {
		Name = "SERVER_LUCK_2X",
		Id = 3460252055,
	},
	SERVER_LUCK_4X = {
		Name = "SERVER_LUCK_4X",
		Id = 3460252052,
	},
	SERVER_LUCK_8X = {
		Name = "SERVER_LUCK_8X",
		Id = 3460252042,
	},
	SERVER_LUCK = {
		Name = "SERVER_LUCK",
		Id = 3460252536,
	},

	-- MONEY
	MONEY_PACK_I = {
		Name = "MONEY_PACK_I",
		Id = 3460984213,
	},
	MONEY_PACK_II = {
		Name = "MONEY_PACK_II",
		Id = 3460984210,
	},
	MONEY_PACK_III = {
		Name = "MONEY_PACK_III",
		Id = 3460984212,
	},
	MONEY_PACK_IV = {
		Name = "MONEY_PACK_IV",
		Id = 3460984211,
	},
	MONEY_PACK_V = {
		Name = "MONEY_PACK_V",
		Id = 3460984205,
	},
	MONEY_PACK_VI = {
		Name = "MONEY_PACK_VI",
		Id = 3460984206,
	},

	-- Exclusive Brainrot
	EXCLUSIVE_BRAINROT_PACK_1X = {
		Name = "EXCLUSIVE_BRAINROT_PACK_1X",
		Id = 3478340933,
	},

	EXCLUSIVE_BRAINROT_PACK_5X = {
		Name = "EXCLUSIVE_BRAINROT_PACK_5X",
		Id = 3478340931,
	},

	EXCLUSIVE_BRAINROT_PACK_10X = {
		Name = "EXCLUSIVE_BRAINROT_PACK_10X",
		Id = 3478340932,
	},

	GIT_EXCLUSIVE_BRAINROT_PACK_1X = {
		Name = "GIT_EXCLUSIVE_BRAINROT_PACK_1X",
		Id = 3478355580,
	},

	GIT_EXCLUSIVE_BRAINROT_PACK_5X = {
		Name = "GIT_EXCLUSIVE_BRAINROT_PACK_5X",
		Id = 3478355581,
	},

	GIT_EXCLUSIVE_BRAINROT_PACK_10X = {
		Name = "GIT_EXCLUSIVE_BRAINROT_PACK_10X",
		Id = 3478355577,
	},

	-- Lucky Chests
	LUCKY_CHESTS_MYTHICAL = {
		Name = "LUCKY_CHESTS_MYTHICAL",
		Id = 3482197759,
	},

	LUCKY_CHESTS_GODLY = {
		Name = "LUCKY_CHESTS_GODLY",
		Id = 3482197756,
	},

	LUCKY_CHESTS_SECRET = {
		Name = "LUCKY_CHESTS_SECRET",
		Id = 3482197758,
	},

	GIFT_LUCKY_CHESTS_MYTHICAL = {
		Name = "GIFT_LUCKY_CHESTS_MYTHICAL",
		Id = 3482197757,
	},

	GIFT_LUCKY_CHESTS_GODLY = {
		Name = "GIFT_LUCKY_CHESTS_GODLY",
		Id = 3482197760,
	},

	GIFT_LUCKY_CHESTS_SECRET = {
		Name = "GIFT_LUCKY_CHESTS_SECRET",
		Id = 3482197753,
	},
}

function DeveloperProducts:GetEnum(name: string): DeveloperProduct
	return self.ENUM[name]
end

return DeveloperProducts
