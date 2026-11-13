return {
	Name = "fly",
	Aliases = {},
	Description = "Fly and pass through things: look and WASD to move, Space or E up, Ctrl or Q down, Shift for speed. Again to stop.",
	Group = "Owner",
	Args = {
		{
			Type = "number",
			Name = "speed",
			Description = "Studs a second (default 150)",
			Optional = true
		}
	}
}