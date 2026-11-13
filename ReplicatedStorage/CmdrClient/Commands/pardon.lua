return {
	Name = "pardon",
	Aliases = {},
	Description = "Let a flagged player back into normal servers, keeping a pardon mark on their account.",
	Group = "Owner",
	Args = {
		{ Type = "playerId", Name = "player", Description = "Player name (or #userId)" },
		{
			Type = "pardonReason",
			Name = "reason",
			Description = "admitted / falsealarm / appeal / other"
		}
	}
}