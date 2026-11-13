return {
	Name = "setbeacons",
	Aliases = {},
	Description = "Destroy beacons of a team until n remain (lowering only; endround resets the world).",
	Group = "DefaultAdmin",
	Args = {
		{ Type = "team", Name = "team", Description = "Reds or Blues" },
		{ Type = "integer", Name = "n", Description = "Beacons to leave standing" }
	}
}