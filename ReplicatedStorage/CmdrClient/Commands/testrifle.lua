return {
	Name = "testrifle",
	Aliases = { "rifle", "testsmg", "testlmg", "testdmr", "testsniper", "testpistol", "testgun" },
	Description = "Carry a new rifle, SMG, LMG, DMR or sniper as your primary, or a new pistol as your secondary, for this session (not saved). Players: name, a,b, . (you) or * (everyone). saved: back to the saved kit.",
	Group = "DefaultAdmin",
	Args = {
		{ Type = "players", Name = "players", Description = "Who" },
		{ Type = "testRifle", Name = "gun", Description = "Which gun (or saved)" }
	}
}