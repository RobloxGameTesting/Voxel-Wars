return {
	Name = "crates",
	Aliases = {},
	Description = "Test supply crates: stock5, allskins, noskins or allbutmythic.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "crateTest",
			Name = "action",
			Description = "stock5, allskins, noskins or allbutmythic"
		}
	}
}