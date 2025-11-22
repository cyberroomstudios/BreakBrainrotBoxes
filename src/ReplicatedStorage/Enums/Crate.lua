local Crate = table.freeze({
	["RARITIES"] = {
		["COMMON"] = {
			Odd = 1,
			CratesCategoryOdds = {
				["COMMON"] = 0.9,
				["UNCOMMON"] = 0.1,
				["RARE"] = 0.04,
				["LEGENDARY"] = 0.007,
				["EPIC"] = 0.002,
				["MYTHICAL"] = 0.0009,
				["GODLY"] = 0.0001,
			},
		},
		["UNCOMMON"] = {
			Odd = 0.1,
			CratesCategoryOdds = {
				["COMMON"] = 0.65,
				["UNCOMMON"] = 0.40,
				["RARE"] = 0.10,
				["LEGENDARY"] = 0.03,
				["EPIC"] = 0.015,
				["MYTHICAL"] = 0.004,
				["GODLY"] = 0.001,
			},
		},
		["RARE"] = {
			Odd = 0.05,
			CratesCategoryOdds = {
				["COMMON"] = 0.40,
				["UNCOMMON"] = 0.30,
				["RARE"] = 0.2,
				["LEGENDARY"] = 0.06,
				["EPIC"] = 0.025,
				["MYTHICAL"] = 0.01,
				["GODLY"] = 0.005,
			},
		},

		["LEGENDARY"] = {
			Odd = 0.03,
			CratesCategoryOdds = {
				["COMMON"] = 0.10,
				["UNCOMMON"] = 0.15,
				["RARE"] = 0.25,
				["LEGENDARY"] = 0.25,
				["EPIC"] = 0.15,
				["MYTHICAL"] = 0.07,
				["GODLY"] = 0.03,
			},
		},

		["EPIC"] = {
			Odd = 1,
			CratesCategoryOdds = {
				["COMMON"] = 0.2,
				["UNCOMMON"] = 0.25,
				["RARE"] = 0.30,
				["LEGENDARY"] = 0.15,
				["EPIC"] = 0.07,
				["MYTHICAL"] = 0.02,
				["GODLY"] = 0.01,
			},
		},

		["MYTHICAL"] = {
			Odd = 1,
			CratesCategoryOdds = {
				["COMMON"] = 0.05,
				["UNCOMMON"] = 0.10,
				["RARE"] = 0.15,
				["LEGENDARY"] = 0.20,
				["EPIC"] = 0.25,
				["MYTHICAL"] = 0.20,
				["GODLY"] = 0.05,
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
				["COMMON"] = 0.01,
				["UNCOMMON"] = 0.03,
				["RARE"] = 0.10,
				["LEGENDARY"] = 0.20,
				["EPIC"] = 0.25,
				["MYTHICAL"] = 0.25,
				["GODLY"] = 0.16,
			},
		},
	},

	["CRATES"] = {
		["Wooden"] = {
			Name = "Wooden",
			Price = 50,
			Rarity = "COMMON",
			XPToOpen = 1,
			Odd = 1,
			GUI = {
				Name = "Wooden Crate",
				Order = 1,
			},
			Stock = {
				Min = 5,
				Max = 12,
			},
		},

		["Bronze"] = {
			Name = "Bronze",
			Price = 200,
			Rarity = "COMMON",
			XPToOpen = 2,
			Odd = 1,
			GUI = {
				Name = "Bronze Crate",
				Order = 2,
			},
			Stock = {
				Min = 5,
				Max = 12,
			},
		},

		["Grass"] = {
			Name = "Grass",
			Price = 1500,
			Rarity = "UNCOMMON",
			XPToOpen = 5,
			Odd = 1,
			GUI = {
				Name = "Grass Crate",
				Order = 3,
			},
			Stock = {
				Min = 4,
				Max = 10,
			},
		},

		["Stone"] = {
			Name = "Stone",
			Price = 5000,
			Rarity = "UNCOMMON",
			XPToOpen = 10,
			Odd = 0.8,
			GUI = {
				Name = "Stone Crate",
				Order = 4,
			},
			Stock = {
				Min = 4,
				Max = 10,
			},
		},

		["Lava"] = {
			Name = "Lava",
			Price = 15000,
			Rarity = "RARE",
			XPToOpen = 18,
			Odd = 0.5,
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
			Price = 40000,
			Rarity = "RARE",
			XPToOpen = 37,
			Odd = 0.5,
			GUI = {
				Name = "Ice Crate",
				Order = 6,
			},
			Stock = {
				Min = 1,
				Max = 5,
			},
		},

		["Tech"] = {
			Name = "Tech",
			Price = 120000,
			Rarity = "LEGENDARY",
			XPToOpen = 75,
			Odd = 0.4,
			GUI = {
				Name = "Tech Crate",
				Order = 7,
			},
			Stock = {
				Min = 1,
				Max = 3,
			},
		},

		["Storm"] = {
			Name = "Storm",
			Price = 300000,
			Rarity = "LEGENDARY",
			XPToOpen = 150,
			Odd = 0.4,
			GUI = {
				Name = "Storm Crate",
				Order = 8,
			},
			Stock = {
				Min = 1,
				Max = 3,
			},
		},

		["Golden"] = {
			Name = "Golden",
			Price = 1000000,
			Rarity = "MYTHICAL",
			XPToOpen = 400,
			Odd = 0.2,
			GUI = {
				Name = "Golden Crate",
				Order = 9,
			},
			Stock = {
				Min = 1,
				Max = 2,
			},
		},

		["Diamond"] = {
			Name = "Diamond",
			Price = 10000000,
			Rarity = "GODLY",
			XPToOpen = 350,
			Odd = 0.1,
			GUI = {
				Name = "Diamond Crate",
				Order = 10,
			},
			Stock = {
				Min = 1,
				Max = 1,
			},
		},
	},
})

return Crate
