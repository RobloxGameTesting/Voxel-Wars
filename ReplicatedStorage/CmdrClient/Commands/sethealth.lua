return {
	Name = "sethealth",
	Aliases = { "hp" },
	Description = "Set a player's health (0 takes them down).",
	Group = "DefaultAdmin",
	Args = {
		{ Type = "player", Name = "player", Description = "Who" },
		{ Type = "number", Name = "health", Description = "New health" }
	}
}