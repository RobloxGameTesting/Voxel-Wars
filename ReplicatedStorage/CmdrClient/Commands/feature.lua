return {
	Name = "feature",
	Description = "Turn a feature on or off for this server: craters, grasspress or mobileshadows.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "featureName",
			Name = "feature",
			Description = "craters, grasspress or mobileshadows"
		},
		{ Type = "onOff", Name = "state", Description = "on or off" }
	}
}