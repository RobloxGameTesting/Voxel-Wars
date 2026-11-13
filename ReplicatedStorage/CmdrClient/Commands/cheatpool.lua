return {
	Name = "cheatpool",
	Aliases = {},
	Description = "Move a player to the cheater-only servers for good (online now or not). Undo with uncheatpool.",
	Group = "Owner",
	Args = {
		{ Type = "playerId", Name = "player", Description = "Player name (or #userId)" }
	}
}