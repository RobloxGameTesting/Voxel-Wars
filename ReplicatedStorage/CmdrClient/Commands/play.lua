return {
	Name = "play",
	Aliases = { "playmap" },
	Description = "Play a map in a game mode now: map ironfield, sandline, saltpan, frostmill, pinewold, drywell or highcrag; mode domination, tdm or siege (Ironfield only). The match starts over.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "gameMap",
			Name = "map",
			Description = "ironfield, sandline, saltpan, frostmill, pinewold, drywell or highcrag"
		},
		{
			Type = "matchMode",
			Name = "mode",
			Description = "domination, hill (Saltpan, Frostmill, Pinewold, Drywell), tdm or siege (Ironfield only)"
		}
	}
}