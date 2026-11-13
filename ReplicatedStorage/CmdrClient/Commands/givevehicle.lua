return {
	Name = "givevehicle",
	Aliases = { "grantvehicle" },
	Description = "Give players a Vehicle Bay vehicle for good (take: remove it). Saved. Players: name, a,b, . (you) or * (all).",
	Group = "DefaultAdmin",
	Args = {
		{ Type = "players", Name = "players", Description = "Who" },
		{
			Type = "bayVehicle",
			Name = "vehicle",
			Description = "Which vehicle (Game.VehicleBayData)"
		},
		{
			Type = "grantAction",
			Name = "action",
			Description = "give (default) or take",
			Optional = true
		}
	}
}