return {
	Name = "spawnvehicle",
	Aliases = { "vehicle", "sv" },
	Description = "Spawn a vehicle (Humvee, Tank, Heli, StealthHeli, Jet, Bomber) in front of you. clearvehicles removes them.",
	Group = "DefaultAdmin",
	Args = {
		{ Type = "vehicleModel", Name = "vehicle", Description = "which vehicle" },
		{
			Type = "integer",
			Name = "count",
			Description = "how many (1-5, default 1)",
			Optional = true
		}
	}
}