return {
	Name = "hellfiresim",
	Aliases = {},
	Description = "Simulate someone else's Hellfire missile diving onto a spot near you (it follows you). distance: studs off you it lands (default 60; 0 = on you). side: enemy (default) or friendly.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "number",
			Name = "distance",
			Description = "Studs from you it lands (default 60, 0 = on you)",
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