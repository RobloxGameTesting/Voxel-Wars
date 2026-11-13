return {
	Name = "giveall",
	Aliases = { "givall", "unlockall" },
	Description = "Unlock every weapon, attachment, utility, melee, throwable, streak and outfit for this session (not saved), put these players in the match and start it now. Players: name, a,b, . (you, default) or * (all).",
	Group = "DefaultAdmin",
	Args = {
		{ Type = "players", Name = "players", Description = "Who (default: you)", Optional = true }
	}
}