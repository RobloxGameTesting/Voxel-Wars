return {
	Name = "botdifficulty",
	Aliases = { "botskill" },
	Description = "Set bot difficulty: easy, normal or hard.",
	Group = "DefaultAdmin",
	Args = {
		{ Type = "botDifficulty", Name = "level", Description = "easy, normal or hard" }
	}
}