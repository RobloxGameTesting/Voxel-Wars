return {
	Name = "botteam",
	Description = "Show the bot teams' strategy: fronts per lane, squad plans, recent changes, lane stats.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "teamName",
			Name = "team",
			Description = "Reds or Blues (both when left out)",
			Optional = true
		}
	}
}