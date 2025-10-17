return {
	Name = script.Name,
	Aliases = { "GiveMoney" },
	Description = "Give Money to Player",
	Group = "Admin",
	Args = {
		{
			Type = "player",
			Name = "from",
			Description = "The player",
		},

		{
			Type = "string",
			Name = "brainrot",
			Description = "The Brainrot",
		},

		{
			Type = "string",
			Name = "plot",
			Description = "The Plot",
		},
	},
}
