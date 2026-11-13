return {
	Name = "jointeam",
	Aliases = {},
	Description = "Join (or switch to) a team now, past the team-size rule and auto-balance, and deploy at its spawn.",
	Group = "Owner",
	Args = {
		{ Type = "team", Name = "team", Description = "Reds or Blues" }
	}
}