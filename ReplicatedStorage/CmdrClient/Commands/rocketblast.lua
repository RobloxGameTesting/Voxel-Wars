return {
	Name = "rocketblast",
	Aliases = { "blast" },
	Description = "Set the rocket blast level: 3 (default) to 5 (max). Explosion size 1.2 .. 1.8.",
	Group = "DefaultAdmin",
	Args = {
		{ Type = "integer", Name = "level", Description = "Blast level, 3 to 5" }
	}
}