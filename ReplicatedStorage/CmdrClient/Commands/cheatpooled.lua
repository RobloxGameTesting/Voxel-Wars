return {
	Name = "cheatpooled",
	Aliases = {},
	Description = "List the players in the cheater pool, newest first, with why and by whom.",
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