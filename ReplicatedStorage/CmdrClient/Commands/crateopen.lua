return {
	Name = "crateopen",
	Aliases = {},
	Description = "Play the crate opening at once (nothing is won or saved). Count 1-5 (default 1); rarity random (default), rare, epic, legendary or mythic; new (default), owned or mixed: play prizes as skins already owned; crate: rifle (default), smg, lmg, sniper, dmr, shotgun or pistol.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "crateCount",
			Name = "count",
			Description = "how many crates open side by side, 1-5 (default 1)",
			Optional = true
		},
		{
			Type = "crateRarity",
			Name = "rarity",
			Description = "random (default), rare, epic, legendary or mythic",
			Optional = true
		},
		{
			Type = "crateOwned",
			Name = "owned",
			Description = "new (default): new skins; owned: every prize already owned; mixed: every other one",
			Optional = true
		},
		{
			Type = "crateKind",
			Name = "crate",
			Description = "which weapon class's crate: rifle (default), smg, lmg, sniper, dmr, shotgun, pistol",
			Optional = true
		}
	}
}