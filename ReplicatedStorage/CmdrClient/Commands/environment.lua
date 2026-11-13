return {
	Name = "environment",
	Aliases = { "env" },
	Description = "Apply an environment preset to everyone. normal = the game's everyday lighting.",
	Group = "DefaultAdmin",
	Args = {
		{ Type = "environmentPreset", Name = "preset", Description = "Which lighting preset" }
	}
}