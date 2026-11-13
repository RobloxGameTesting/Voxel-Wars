return {
	Name = "givexp",
	Aliases = {},
	Description = "Give a player XP now (negative takes it away). Shows the level panel.",
	Group = "DefaultAdmin",
	Args = {
		{ Type = "player", Name = "player", Description = "Who" },
		{ Type = "integer", Name = "n", Description = "XP" }
	}
}