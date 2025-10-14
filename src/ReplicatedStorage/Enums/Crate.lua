local Crate = table.freeze({
	["RARITYS"] = {
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
			Odd = 1,
			GUI = {
				Name = "Cardboard Crate",
				Order = 1,
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
			Odd = 0.7,
			GUI = {
				Name = "Pallet Crate",
				Order = 2,
			},
			Stock = {
				Min = 1,
				Max = 5,
			},
		},

		["Rustic"] = {
			Name = "Rustic",
			Price = 100,
			Rarity = "UNCOMMON",
			Odd = 1,
			GUI = {
				Name = "Rustic Crate",
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
			Rarity = "UNCOMMON",
			Odd = 0.5,
			GUI = {
				Name = "Metal Crate",
				Order = 4,
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
			Odd = 1,
			GUI = {
				Name = "Metal Crate",
				Order = 5,
			},
			Stock = {
				Min = 1,
				Max = 5,
			},
		},

		["Volcanic"] = {
			Name = "Volcanic",
			Price = 100,
			Rarity = "RARE",
			Odd = 0.1,
			GUI = {
				Name = "Volcanic Crate",
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
