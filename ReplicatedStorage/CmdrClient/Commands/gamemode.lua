return {
	Name = "gamemode",
	Aliases = { "mode" },
	Description = "Switch game now: koth (King of the Hill, default), tdm (team deathmatch), siege (spawn siege), saltpan or saltpantdm (Saltpan desert), frostmill or frostmilltdm (Frostmill winter), pinewold or pinewoldtdm (Pinewold forest), drywell or drywelltdm (Drywell desert), highcrag or highcraghill (Highcrag mountain); add hill (saltpanhill, frostmillhill, pinewoldhill, drywellhill) for King of the Hill there. The match starts over.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "gameMode",
			Name = "mode",
			Description = "koth, tdm, siege, saltpan, saltpantdm, saltpanhill, frostmill, frostmilltdm, frostmillhill, pinewold, pinewoldtdm, pinewoldhill, drywell, drywelltdm, drywellhill, highcrag or highcraghill"
		}
	}
}