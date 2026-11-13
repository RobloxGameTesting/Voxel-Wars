return {
	Name = "gunshipsim",
	Aliases = {},
	Description = "Simulate someone else's gunship firing round a spot near you (it follows you). distance: studs off you it aims (default 50; 0 = at you). side: enemy (default) or friendly.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "number",
			Name = "distance",
			Description = "Studs from you it aims (default 50, 0 = at you)",
			Optional = true
		},
		{
			Type = "streakSide",
			Name = "side",
			Description = "enemy (default) or friendly",
			Optional = true
		}
	}
}