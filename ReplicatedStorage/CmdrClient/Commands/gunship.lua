return {
	Name = "gunship",
	Aliases = {},
	Description = "Give the gunship's radio. Players (default you): name, a,b, . or *.",
	Group = "DefaultAdmin",
	Args = {
		{ Type = "players", Name = "players", Description = "Who (default: you)", Optional = true }
	}
}