return {
	Name = "killstreak",
	Aliases = { "ks", "givestreak" },
	Description = "Give a killstreak, ready to use. Players: name, a,b, . (you) or * (everyone). n: how many airstrikes (default 1).",
	Group = "DefaultAdmin",
	Args = {
		{ Type = "players", Name = "players", Description = "Who" },
		{ Type = "killstreak", Name = "streak", Description = "Which killstreak" },
		{
			Type = "integer",
			Name = "n",
			Description = "How many (airstrikes; default 1)",
			Optional = true
		}
	}
}