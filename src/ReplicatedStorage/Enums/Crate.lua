local Crate = table.freeze({
	["RARITIES"] = {
		["COMMON"] = {
			Odd = 1,
			CratesCategoryOdds = {
				["COMMON"] = 0.8,
				["UNCOMMON"] = 0.2,
				["RARE"] = 0,
				["LEGENDARY"] = 0,
				["EPIC"] = 0,
				["MYTHICAL"] = 0,
				["GODLY"] = 0,
			},
		},
		["UNCOMMON"] = {
			Odd = 0.1,
			CratesCategoryOdds = {
				["COMMON"] = 0.3,
				["UNCOMMON"] = 0.7,
				["RARE"] = 0.1,
				["LEGENDARY"] = 0,
				["EPIC"] = 0,
				["MYTHICAL"] = 0,
				["GODLY"] = 0,
			},
		},
		["RARE"] = {
			Odd = 0.05,
			CratesCategoryOdds = {
				["COMMON"] = 0,
				["UNCOMMON"] = 0.3,
				["RARE"] = 0.6,
				["LEGENDARY"] = 0.1,
				["EPIC"] = 0,
				["MYTHICAL"] = 0,
				["GODLY"] = 0,
			},
		},

		["LEGENDARY"] = {
			Odd = 0.03,
			CratesCategoryOdds = {
				["COMMON"] = 0,
				["UNCOMMON"] = 0,
				["RARE"] = 0,
				["LEGENDARY"] = 0.8,
				["EPIC"] = 0.15,
				["MYTHICAL"] = 0.05,
				["GODLY"] = 0,
			},
		},

		["EPIC"] = {
			Odd = 1,
			CratesCategoryOdds = {
				["COMMON"] = 0,
				["UNCOMMON"] = 0,
				["RARE"] = 0,
				["LEGENDARY"] = 0.2,
				["EPIC"] = 0.7,
				["MYTHICAL"] = 0.05,
				["GODLY"] = 0.05,
			},
		},

		["MYTHICAL"] = {
			Odd = 1,
			CratesCategoryOdds = {
				["COMMON"] = 0.8,
				["UNCOMMON"] = 0.2,
				["RARE"] = 0,
				["LEGENDARY"] = 0,
				["EPIC"] = 0.4,
				["MYTHICAL"] = 0.5,
				["GODLY"] = 0.1,
			},
			MutationOdds = {
				NORMAL = 0.7,
				GOLD = 0.2,
				DIAMOND = 0.1,
			},
		},

		["GODLY"] = {
			Odd = 1,
			CratesCategoryOdds = {
				["COMMON"] = 0.8,
				["UNCOMMON"] = 0.2,
				["RARE"] = 0,
				["LEGENDARY"] = 0,
				["EPIC"] = 0,
				["MYTHICAL"] = 0.1,
				["GODLY"] = 0.9,
			},
		},
	},

	["CRATES"] = {
		["Wooden"] = {
			Name = "Wooden",
			Price = 123,
			Rarity = "COMMON",
			XPToOpen = 40,
			Odd = 1,
			GUI = {
				Name = "Wooden Crate",
				Order = 1,
			},
			Stock = {
				Min = 1,
				Max = 5,
			},
		},
		["Tech"] = {
			Name = "Tech",
			Price = 444,
			Rarity = "UNCOMMON",
			XPToOpen = 3000,
			Odd = 1,
			GUI = {
				Name = "Tech Crate",
				Order = 2,
			},
			Stock = {
				Min = 1,
				Max = 5,
			},
		},

		["Storm"] = {
			Name = "Storm",
			Price = 7800,
			Rarity = "RARE",
			XPToOpen = 20000,
			Odd = 1,
			GUI = {
				Name = "Storm Crate",
				Order = 3,
			},
			Stock = {
				Min = 1,
				Max = 5,
			},
		},

		["Stone"] = {
			Name = "Stone",
			Price = 4500,
			Rarity = "LEGENDARY",
			XPToOpen = 200,
			Odd = 1,
			GUI = {
				Name = "Stone Crate",
				Order = 4,
			},
			Stock = {
				Min = 1,
				Max = 5,
			},
		},

		["Lava"] = {
			Name = "Lava",
			Price = 2000,
			Rarity = "EPIC",
			XPToOpen = 250,
			Odd = 1,
			GUI = {
				Name = "Lava Crate",
				Order = 5,
			},
			Stock = {
				Min = 1,
				Max = 5,
			},
		},

		["Ice"] = {
			Name = "Ice",
			Price = 7000,
			Rarity = "MYTHICAL",
			XPToOpen = 300,
			Odd = 1,
			GUI = {
				Name = "Ice Crate",
				Order = 6,
			},
			Stock = {
				Min = 1,
				Max = 5,
			},
		},

		["Grass"] = {
			Name = "Grass",
			Price = 4000,
			Rarity = "GODLY",
			XPToOpen = 350,
			Odd = 1,
			GUI = {
				Name = "Grass Crate",
				Order = 7,
			},
			Stock = {
				Min = 1,
				Max = 5,
			},
		},

		["Golden"] = {
			Name = "Golden",
			Price = 20,
			Rarity = "GODLY",
			XPToOpen = 350,
			Odd = 1,
			GUI = {
				Name = "Golden Crate",
				Order = 8,
			},
			Stock = {
				Min = 1,
				Max = 5,
			},
		},

		["Diamond"] = {
			Name = "Diamond",
			Price = 4000,
			Rarity = "GODLY",
			XPToOpen = 350,
			Odd = 1,
			GUI = {
				Name = "Diamond Crate",
				Order = 9,
			},
			Stock = {
				Min = 1,
				Max = 5,
			},
		},

		["Bronze"] = {
			Name = "Bronze",
			Price = 4722,
			Rarity = "GODLY",
			XPToOpen = 350,
			Odd = 1,
			GUI = {
				Name = "Bronze Crate",
				Order = 10,
			},
			Stock = {
				Min = 1,
				Max = 5,
			},
		},
	},
})

return Crate
