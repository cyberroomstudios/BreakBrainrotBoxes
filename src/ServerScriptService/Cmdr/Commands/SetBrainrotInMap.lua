return {
	Name = script.Name,
	Aliases = { "SetBrainrotInMap" },
	Description = "Set A Brainrot In Map",
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
