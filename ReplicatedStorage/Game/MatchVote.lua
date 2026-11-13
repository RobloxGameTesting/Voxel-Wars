local TeamDeathmatch = require(script.Parent.TeamDeathmatch)
local SpawnRaid = require(script.Parent.SpawnRaid)

local MatchVote = {
	VOTE_TIME = 30,
	START_TIME = 10,
	BALLOT_MAPS = { "saltpan", "ironfield", "frostmill", "pinewold", "drywell", "highcrag" },
	BALLOT_SIZE = 3,
	TDM_WEIGHT = 0.6,
	REPEAT_WEIGHT = 0.35
}

MatchVote.OPTIONS = {
	{
		mode = "domination",
		map = "ironfield",
		name = "KING OF THE HILL",
		mapName = "IRONFIELD",
		blurb = "HOLD THE COMMAND POST",
		weight = 1
	},
	{
		mode = "tdm",
		map = "ironfield",
		name = "TEAM DEATHMATCH",
		mapName = "IRONFIELD",
		blurb = "FIRST TO " .. TeamDeathmatch.TARGET .. " KILLS",
		weight = MatchVote.TDM_WEIGHT
	},
	{
		mode = "siege",
		map = "ironfield",
		name = SpawnRaid.SETTINGS.siege.name,
		mapName = "IRONFIELD",
		blurb = "DESTROY ALL " .. SpawnRaid.SIEGE_PER_TEAM .. " ENEMY SPAWNS",
		weight = 1
	},
	{
		mode = "domination",
		map = "saltpan",
		name = "DOMINATION",
		mapName = "SALTPAN",
		blurb = "HOLD A, B AND C",
		weight = 1
	},
	{
		mode = "domination",
		onePoint = true,
		map = "saltpan",
		name = "KING OF THE HILL",
		mapName = "SALTPAN",
		blurb = "HOLD THE PUMPING PLANT",
		weight = 1
	},
	{
		mode = "tdm",
		map = "saltpan",
		name = "TEAM DEATHMATCH",
		mapName = "SALTPAN",
		blurb = "FIRST TO " .. TeamDeathmatch.TARGET .. " KILLS",
		weight = MatchVote.TDM_WEIGHT
	},
	{
		mode = "domination",
		map = "frostmill",
		name = "DOMINATION",
		mapName = "FROSTMILL",
		blurb = "HOLD A, B AND C",
		weight = 1
	},
	{
		mode = "domination",
		onePoint = true,
		map = "frostmill",
		name = "KING OF THE HILL",
		mapName = "FROSTMILL",
		blurb = "HOLD THE DAM",
		weight = 1
	},
	{
		mode = "tdm",
		map = "frostmill",
		name = "TEAM DEATHMATCH",
		mapName = "FROSTMILL",
		blurb = "FIRST TO " .. TeamDeathmatch.TARGET .. " KILLS",
		weight = MatchVote.TDM_WEIGHT
	},
	{
		mode = "domination",
		map = "pinewold",
		name = "DOMINATION",
		mapName = "PINEWOLD",
		blurb = "HOLD A, B AND C",
		weight = 1
	},
	{
		mode = "domination",
		onePoint = true,
		map = "pinewold",
		name = "KING OF THE HILL",
		mapName = "PINEWOLD",
		blurb = "HOLD THE DEPOT",
		weight = 1
	},
	{
		mode = "tdm",
		map = "pinewold",
		name = "TEAM DEATHMATCH",
		mapName = "PINEWOLD",
		blurb = "FIRST TO " .. TeamDeathmatch.TARGET .. " KILLS",
		weight = MatchVote.TDM_WEIGHT
	},
	{
		mode = "domination",
		map = "drywell",
		name = "DOMINATION",
		mapName = "DRYWELL",
		blurb = "HOLD A, B AND C",
		weight = 1
	},
	{
		mode = "domination",
		onePoint = true,
		map = "drywell",
		name = "KING OF THE HILL",
		mapName = "DRYWELL",
		blurb = "HOLD THE PUMP HALL",
		weight = 1
	},
	{
		mode = "tdm",
		map = "drywell",
		name = "TEAM DEATHMATCH",
		mapName = "DRYWELL",
		blurb = "FIRST TO " .. TeamDeathmatch.TARGET .. " KILLS",
		weight = MatchVote.TDM_WEIGHT
	},
	{
		mode = "domination",
		map = "highcrag",
		name = "DOMINATION",
		mapName = "HIGHCRAG",
		blurb = "HOLD A, B AND C",
		weight = 1
	},
	{
		mode = "domination",
		onePoint = true,
		map = "highcrag",
		name = "KING OF THE HILL",
		mapName = "HIGHCRAG",
		blurb = "HOLD THE CROWN",
		weight = 1
	}
}

MatchVote.MAP_IMAGES = {
	ironfield = "rbxassetid://76314475238783",
	sandline = "",
	saltpan = "rbxassetid://117819175696426",
	frostmill = "rbxassetid://70611999386884",
	pinewold = "rbxassetid://138985057031248",
	drywell = "rbxassetid://101257576452334",
	highcrag = "rbxassetid://114465245782656"
}

return MatchVote