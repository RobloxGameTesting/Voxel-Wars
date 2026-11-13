return {
	Name = "heli",
	Aliases = {},
	Description = "Show the helicopter beside you. Mode: parked (default), idle (rotors turning), hover, clear.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "heliMode",
			Name = "mode",
			Description = "parked | idle | hover | clear",
			Optional = true
		}
	}
}