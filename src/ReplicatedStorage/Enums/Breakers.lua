local Breakers = table.freeze({
	["Noob"] = {
		Name = "Noob",
		Price = 0,
		OnlyRobux = false,
		Boosts = {
			Speed = 0,
			Power = 0,
		},
	},

	["Baseball"] = {
		Name = "Baseball",
		Price = 10000,
		OnlyRobux = false,
		Boosts = {
			Speed = -1,
			Power = 2,
		},
	},

	["Ninja"] = {
		Name = "Ninja",
		Price = 100000,
		OnlyRobux = false,
		Boosts = {
			Speed = -2,
			Power = 5,
		},
	},

	["Sahur"] = {
		Name = "Sahur",
		OnlyRobux = true,
		Boosts = {
			Speed = -3,
			Power = 6,
		},
	},
	["Warrior"] = {
		Name = "Warrior",
		Price = 1000000,
		OnlyRobux = false,
		Boosts = {
			Speed = -4,
			Power = 12,
		},
	},

	["Soldier"] = {
		Name = "Soldier",
		Price = 10000000,
		OnlyRobux = false,
		Boosts = {
			Speed = -5,
			Power = 25,
		},
	},

	
})

return Breakers
