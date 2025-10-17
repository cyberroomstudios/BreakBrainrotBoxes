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
			Price = 150,
			Rarity = "COMMON",
			XPToOpen = 150,
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

		["Pallet"] = {
			Name = "Pallet",
			Price = 250,
			Rarity = "COMMON",
			XPToOpen = 200,
			Odd = 0.7,
			GUI = {
				Name = "Pallet",
				Order = 2,
			},
			Stock = {
				Min = 1,
				Max = 5,
			},
		},

		["Rustic"] = {
			Name = "Rustic",
			Price = 260,
			Rarity = "UNCOMMON",
			XPToOpen = 300,
			Odd = 1,
			GUI = {
				Name = "Rustic",
				Order = 3,
			},
			Stock = {
				Min = 1,
				Max = 5,
			},
		},

		["Metal"] = {
			Name = "Metal",
			Price = 300,
			Rarity = "UNCOMMON",
			XPToOpen = 400,
			Odd = 0.5,
			GUI = {
				Name = "Metal",
				Order = 4,
			},
			Stock = {
				Min = 1,
				Max = 5,
			},
		},

		["Ice"] = {
			Name = "Ice",
			Price = 400,
			Rarity = "RARE",
			XPToOpen = 500,
			Odd = 1,
			GUI = {
				Name = "Metal",
				Order = 5,
			},
			Stock = {
				Min = 1,
				Max = 5,
			},
		},

		["Volcanic"] = {
			Name = "Volcanic",
			Price = 500,
			Rarity = "RARE",
			XPToOpen = 600,
			Odd = 0.1,
			GUI = {
				Name = "Volcanic",
				Order = 6,
			},
			Stock = {
				Min = 1,
				Max = 5,
			},
		},
	},
})

return Crate
