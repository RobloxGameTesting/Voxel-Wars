return {
	Name = "endround",
	Aliases = {},
	Description = "End the round now, like a real end (screens, then the lobby vote). Winner: Reds or Blues (match also: draw). Default: the leading team.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "roundWinner",
			Name = "winner",
			Description = "Reds, Blues or draw",
			Optional = true
		}
	}
}