local Breakers = table.freeze({
	["Noob"] = {
		Name = "Noob",
		Price = 10000,
		OnlyRobux = false,
		Boosts = {
			Speed = 0,
			Power = 5,
		},
	},

	["Baseball"] = {
		Name = "Baseball",
		Price = 200000,
		OnlyRobux = false,
		Boosts = {
			Speed = -1,
			Power = 10,
		},
	},

	["Ninja"] = {
		Name = "Ninja",
		Price = 32000,
		OnlyRobux = false,
		Boosts = {
			Speed = -2,
			Power = 20,
		},
	},

	["Warrior"] = {
		Name = "Warrior",
		Price = 400000,
		OnlyRobux = false,
		Boosts = {
			Speed = -3,
			Power = 10,
		},
	},

	["Soldier"] = {
		Name = "Soldier",
		Price = 100000,
		OnlyRobux = false,
		Boosts = {
			Speed = -4,
			Power = 10,
		},
	},

	["Sahur"] = {
		Name = "Sahur",
		OnlyRobux = true,
		Boosts = {
			Speed = -5,
			Power = 10,
		},
	},
})

return Breakers
