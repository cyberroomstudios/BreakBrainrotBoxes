return {
	Name = script.Name,
	Aliases = { "GiveCashMultiplier" },
	Description = "Give Cash Multiplier to Player",
	Group = "Admin",
	Args = {
		{
			Type = "player",
			Name = "from",
			Description = "The player",
		},

		{
			Type = "number",
			Name = "amount",
			Description = "The Amount",
		},
	},
}
