return {
	Name = "setvehiclelevel",
	Aliases = {},
	Description = "Set a vehicle's level (default: you). Saved; its option unlocks on the VEHICLES screen follow it.",
	Group = "DefaultAdmin",
	Args = {
		{ Type = "weaponLevel", Name = "level", Description = "The vehicle level" },
		{ Type = "masteryVehicle", Name = "vehicle", Description = "The vehicle" },
		{ Type = "player", Name = "player", Description = "Who (default: you)", Optional = true }
	}
}