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
			Odd = 1,
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
			Odd = 1,
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
			Odd = 1,
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
		["Cardboard"] = {
			Name = "Cardboard",
			Price = 100,
			Rarity = "COMMON",
			XPToOpen = 100,
			Odd = 1,
			GUI = {
				Name = "Cardboard",
				Order = 1,
			},
			Stock = {
				Min = 1,
				Max = 5,
			},
		},
		["Concrete"] = {
			Name = "Concrete",
			Price = 100,
			Rarity = "UNCOMMON",
			XPToOpen = 3000,
			Odd = 1,
			GUI = {
				Name = "Concrete",
				Order = 2,
			},
			Stock = {
				Min = 1,
				Max = 5,
			},
		},

		["Ice"] = {
			Name = "Ice",
			Price = 100,
			Rarity = "RARE",
			XPToOpen = 20000,
			Odd = 1,
			GUI = {
				Name = "Ice",
				Order = 3,
			},
			Stock = {
				Min = 1,
				Max = 5,
			},
		},

		["Metal"] = {
			Name = "Metal",
			Price = 100,
			Rarity = "LEGENDARY",
			XPToOpen = 200,
			Odd = 1,
			GUI = {
				Name = "Metal",
				Order = 4,
			},
			Stock = {
				Min = 1,
				Max = 5,
			},
		},

		["Pallet"] = {
			Name = "Pallet",
			Price = 100,
			Rarity = "EPIC",
			XPToOpen = 250,
			Odd = 1,
			GUI = {
				Name = "Pallet",
				Order = 5,
			},
			Stock = {
				Min = 1,
				Max = 5,
			},
		},

		["Rustic"] = {
			Name = "Rustic",
			Price = 100,
			Rarity = "MYTHICAL",
			XPToOpen = 300,
			Odd = 1,
			GUI = {
				Name = "Rustic",
				Order = 6,
			},
			Stock = {
				Min = 1,
				Max = 5,
			},
		},

		["Volcanic"] = {
			Name = "Volcanic",
			Price = 100,
			Rarity = "GODLY",
			XPToOpen = 350,
			Odd = 1,
			GUI = {
				Name = "Volcanic",
				Order = 7,
			},
			Stock = {
				Min = 1,
				Max = 5,
			},
		},
	},
})

return Crate
