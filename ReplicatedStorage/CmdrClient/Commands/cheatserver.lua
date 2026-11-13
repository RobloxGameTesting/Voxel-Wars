return {
	Name = "cheatserver",
	Aliases = {},
	Description = "Visit cheater-only servers: next / prev cycle through them, fullest, flyer / aim = fullest of that kind, back = a public server.",
	Group = "Owner",
	Args = {
		{
			Type = "cheatServerPick",
			Name = "which",
			Description = "flyer = the fly servers, aim = everything else; next / prev / fullest / back (default: fullest from outside, next inside one)",
			Optional = true
		}
	}
}