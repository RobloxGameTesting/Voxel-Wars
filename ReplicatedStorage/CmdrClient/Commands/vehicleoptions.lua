return {
	Name = "vehicleoptions",
	Aliases = {},
	Description = "Test vehicle customization: all unlocks every vehicle option, reset takes your unlocks and picks back.",
	Group = "DefaultAdmin",
	Args = {
		{ Type = "vehicleOptionTest", Name = "action", Description = "all or reset" }
	}
}