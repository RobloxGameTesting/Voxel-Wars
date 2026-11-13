return {
	Name = "goldchallenge",
	Aliases = {},
	Description = "Set the held gun's GOLD camo challenge: done, almost (one short) or reset. Saved. Gold also needs weapon level 18.",
	Group = "DefaultAdmin",
	Args = {
		{ Type = "goldStep", Name = "step", Description = "done, almost or reset" },
		{
			Type = "masteryGun",
			Name = "gun",
			Description = "The gun (default: the one you're holding)",
			Optional = true
		},
		{ Type = "player", Name = "player", Description = "Who (default: you)", Optional = true }
	}
}