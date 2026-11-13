return {
	Name = "revokeadmin",
	Aliases = {},
	Description = "Take back the admin commands granted to a player this session.",
	Group = "Owner",
	Args = {
		{ Type = "player", Name = "player", Description = "Who to revoke" }
	}
}