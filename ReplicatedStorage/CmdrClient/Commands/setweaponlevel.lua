return {
	Name = "setweaponlevel",
	Aliases = {},
	Description = "Set the held gun's weapon level (or a named gun; default: you). Saved; its attachment unlocks follow it.",
	Group = "DefaultAdmin",
	Args = {
		{ Type = "weaponLevel", Name = "level", Description = "The weapon level" },
		{
			Type = "masteryGun",
			Name = "gun",
			Description = "The gun (default: the one you're holding)",
			Optional = true
		},
		{ Type = "player", Name = "player", Description = "Who (default: you)", Optional = true }
	}
}