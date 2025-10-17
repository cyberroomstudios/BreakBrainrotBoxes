local Crate = table.freeze({
	["RARITIES"] = {
		["COMMON"] = {
			Odd = 1,
		},
		["UNCOMMON"] = {
			Odd = 0.7,
		},
		["RARE"] = {
			Odd = 0.3,
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
			Rarity = "COMMON",
			XPToOpen = 150,
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
			Rarity = "COMMON",
			XPToOpen = 200,
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
			Rarity = "COMMON",
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
			Rarity = "COMMON",
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
			Rarity = "COMMON",
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
			Rarity = "COMMON",
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
