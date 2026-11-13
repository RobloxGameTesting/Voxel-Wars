return {
	Name = "grantadmin",
	Aliases = {},
	Description = "Let a player use the admin commands until they leave (no kick / ban / unban / gotoPlace).",
	Group = "Owner",
	Args = {
		{ Type = "player", Name = "player", Description = "Who to grant" }
	}
}