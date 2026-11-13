return {
	Name = "cheatcheck",
	Aliases = {},
	Description = "Look up a player: are they in the cheater pool, and were they ever pardoned?",
	Group = "Owner",
	Args = {
		{ Type = "playerId", Name = "player", Description = "Player name (or #userId)" }
	}
}