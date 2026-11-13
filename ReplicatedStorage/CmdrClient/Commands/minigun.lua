return {
	Name = "minigun",
	Aliases = {},
	Description = "Give the minigun killstreak with a full belt. Players (default you): name, a,b, . or *.",
	Group = "DefaultAdmin",
	Args = {
		{ Type = "players", Name = "players", Description = "Who (default: you)", Optional = true }
	}
}