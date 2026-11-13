return {
	Name = "setlevel",
	Aliases = {},
	Description = "Set a player's level (default: you). Saved; the shop's level unlocks follow it.",
	Group = "DefaultAdmin",
	Args = {
		{ Type = "playerLevel", Name = "level", Description = "The level" },
		{ Type = "player", Name = "player", Description = "Who (default: you)", Optional = true }
	}
}