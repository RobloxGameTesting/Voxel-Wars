return {
	Name = "musiccue",
	Aliases = { "cue" },
	Description = "Jump the match to a music cue's moment: swing, final, clock, overtime, lastspawn or finalkills. Side us (default) or them: which side it favours.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "musicCue",
			Name = "moment",
			Description = "swing, final, clock, overtime, lastspawn or finalkills"
		},
		{
			Type = "cueSide",
			Name = "side",
			Description = "us (default): your side is on top; them: you are behind",
			Optional = true
		}
	}
}