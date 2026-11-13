return {
	Name = "pardoned",
	Aliases = {},
	Description = "List pardoned players, newest first, with the reason and what they were flagged for.",
	Group = "Owner",
	Args = {
		{
			Type = "integer",
			Name = "count",
			Description = "How many to list (default 20, up to 50)",
			Optional = true
		}
	}
}