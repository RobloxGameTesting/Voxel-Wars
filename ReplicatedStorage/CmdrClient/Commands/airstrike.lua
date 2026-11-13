return {
	Name = "airstrike",
	Aliases = {},
	Description = "Give airstrikes, ready to call. Players (default you): name, a,b, . or *. n default 1.",
	Group = "DefaultAdmin",
	Args = {
		{ Type = "players", Name = "players", Description = "Who (default: you)", Optional = true },
		{ Type = "integer", Name = "n", Description = "How many (default 1)", Optional = true }
	}
}