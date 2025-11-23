local Crate = table.freeze({
	["RARITIES"] = {
		["COMMON"] = {
			Odd = 1,
			CratesCategoryOdds = {
				["COMMON"] = 0.9,
				["UNCOMMON"] = 0.1,
				["RARE"] = 0,
				["LEGENDARY"] = 0,
				["EPIC"] = 0,
				["MYTHICAL"] = 0,
				["GODLY"] = 0,
			},
		},
		["UNCOMMON"] = {
			Odd = 0.8,
			CratesCategoryOdds = {
				["COMMON"] = 0.2,
				["UNCOMMON"] = 0.7,
				["RARE"] = 0.1,
				["LEGENDARY"] = 0,
				["EPIC"] = 0,
				["MYTHICAL"] = 0,
				["GODLY"] = 0,
			},
		},
		["RARE"] = {
			Odd = 0.5,
			CratesCategoryOdds = {
				["COMMON"] = 0,
				["UNCOMMON"] = 0.2,
				["RARE"] = 0.7,
				["LEGENDARY"] = 0.1,
				["EPIC"] = 0,
				["MYTHICAL"] = 0,
				["GODLY"] = 0,
			},
		},

		["LEGENDARY"] = {
			Odd = 0.4,
			CratesCategoryOdds = {
				["COMMON"] = 0,
				["UNCOMMON"] = 0,
				["RARE"] = 0.2,
				["LEGENDARY"] = 0.7,
				["EPIC"] = 0.05,
				["MYTHICAL"] = 0.05,
				["GODLY"] = 0,
			},
		},

		["EPIC"] = {
			Odd = 0.3,
			CratesCategoryOdds = {
				["COMMON"] = 0,
				["UNCOMMON"] = 0,
				["RARE"] = 0,
				["LEGENDARY"] = 0,
				["EPIC"] = 0.7,
				["MYTHICAL"] = 0.2,
				["GODLY"] = 0.1,
			},
		},

		["MYTHICAL"] = {
			Odd = 0.2,
			CratesCategoryOdds = {
				["COMMON"] = 0,
				["UNCOMMON"] = 0,
				["RARE"] = 0,
				["LEGENDARY"] = 0,
				["EPIC"] = 0.1,
				["MYTHICAL"] = 0.7,
				["GODLY"] = 0.2,
			},
		},

		["GODLY"] = {
			Odd = 0.1,
			CratesCategoryOdds = {
				["COMMON"] = 0,
				["UNCOMMON"] = 0,
				["RARE"] = 0,
				["LEGENDARY"] = 0,
				["EPIC"] = 0,
				["MYTHICAL"] = 0.3,
				["GODLY"] = 0.7,
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
			Rarity = "EPIC",
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
