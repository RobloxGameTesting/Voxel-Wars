return {
	Name = "reports",
	Aliases = {},
	Description = "List the most reported players (any reason, kept for good), with reasons and their real cheat catches.",
	Group = "Owner",
	Args = {
		{
			Type = "integer",
			Name = "count",
			Description = "How many to list (default 15, up to 50)",
			Optional = true
		}
	}
}