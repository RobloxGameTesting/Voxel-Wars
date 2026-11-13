return {
	Name = "questready",
	Aliases = {},
	Description = "Finish your next daily, weekly or bonus quest so it can be claimed in the QUESTS tab.",
	Group = "DefaultAdmin",
	Args = {
		{ Type = "questList", Name = "list", Description = "daily, weekly or bonus" }
	}
}