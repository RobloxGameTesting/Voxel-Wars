return {
	Name = "givescrap",
	Aliases = {},
	Description = "Give players Scrap (negative takes it away). Players: name, a,b, . (you) or * (all).",
	Group = "DefaultAdmin",
	Args = {
		{ Type = "players", Name = "players", Description = "Who" },
		{ Type = "integer", Name = "n", Description = "Scrap" }
	}
}