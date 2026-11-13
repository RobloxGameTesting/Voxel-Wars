local function rgb(p, p2, p3) -- 24 equivalent calls inferred from this helper
	return Color3.fromRGB(p, p2, p3)
end

local StoreData = {}

StoreData.Themes = {
	ember = {
		wall = rgb(92, 26, 18), -- inferred equivalent call
		glow = rgb(255, 92, 40), -- inferred equivalent call
		hot = rgb(255, 176, 66), -- inferred equivalent call
		deep = rgb(30, 12, 10) -- inferred equivalent call
	},
	brass = {
		wall = rgb(112, 80, 30), -- inferred equivalent call
		glow = rgb(232, 170, 62), -- inferred equivalent call
		hot = rgb(255, 222, 130), -- inferred equivalent call
		deep = rgb(30, 23, 12) -- inferred equivalent call
	},
	glacier = {
		wall = rgb(28, 70, 92), -- inferred equivalent call
		glow = rgb(84, 186, 226), -- inferred equivalent call
		hot = rgb(204, 240, 250), -- inferred equivalent call
		deep = rgb(11, 24, 32) -- inferred equivalent call
	},
	viper = {
		wall = rgb(24, 84, 66), -- inferred equivalent call
		glow = rgb(70, 214, 150), -- inferred equivalent call
		hot = rgb(196, 250, 170), -- inferred equivalent call
		deep = rgb(9, 28, 22) -- inferred equivalent call
	},
	dusk = {
		wall = rgb(92, 26, 62), -- inferred equivalent call
		glow = rgb(240, 58, 110), -- inferred equivalent call
		hot = rgb(255, 150, 70), -- inferred equivalent call
		deep = rgb(30, 11, 24) -- inferred equivalent call
	},
	steel = {
		wall = rgb(52, 58, 66), -- inferred equivalent call
		glow = rgb(150, 164, 180), -- inferred equivalent call
		hot = rgb(226, 232, 238), -- inferred equivalent call
		deep = rgb(18, 20, 24) -- inferred equivalent call
	}
}

local function soldier(name, skin, about) -- 14 equivalent calls inferred from this helper
	return {
		kind = "soldier",
		name = name,
		label = "OUTFIT",
		skin = skin,
		about = about
	}
end

local function gun(name, tool, about, parts, reactive) -- 22 equivalent calls inferred from this helper
	return {
		kind = "gun",
		name = name,
		label = "GUN SKIN",
		tool = tool,
		about = about,
		parts = parts,
		reactive = reactive
	}
end

local function melee(name, tool, about) -- 1 equivalent call inferred from this helper
	return {
		kind = "melee",
		name = name,
		label = "MELEE SKIN",
		tool = tool,
		about = about
	}
end

local function charm(name, about) -- 14 equivalent calls inferred from this helper
	return { kind = "charm", name = name, label = "GUN CHARM", about = about }
end

local function vehicle(name, about) -- 4 equivalent calls inferred from this helper
	return { kind = "vehicle", name = name, label = "TANK SKIN", about = about }
end

StoreData.Bundles = {
	{
		id = "ironpsalm",
		title = "IRON PSALM",
		tags = "OUTFITS  |  GUN",
		new = true,
		price = 299,
		theme = "dusk",
		blurb = "Two veterans and the rifle they never gave up.",
		hero = {
			skins = { "Scarred", "Drifter" }
		},
		items = {
			soldier("LAST HYMN", "Scarred", "Worn into every fight since the first."), -- inferred equivalent call
			soldier("PILGRIM", "Drifter", "Walks in alone. Walks out alone."), -- inferred equivalent call
			gun("VESPERS", "K433", "Black enamel with brass lines.", { "STOCK", "UNDERBARREL" }), -- inferred equivalent call
			charm("IRON BELL", "Rings when you run.") -- inferred equivalent call
		}
	},
	{
		id = "coldharbor",
		title = "COLD HARBOR",
		tags = "OUTFIT  |  GUN  |  TANK",
		price = 399,
		theme = "glacier",
		blurb = "Winter gear for holding the piers when the ice comes in.",
		hero = {
			skins = { "Whiteout" },
			tools = { "SV20" }
		},
		items = {
			soldier("NORTH WATCH", "Whiteout", "Cut for the cold."), -- inferred equivalent call
			gun("PACK ICE", "SV20", "Frost white with a blue bolt.", { "STOCK", "MUZZLE" }), -- inferred equivalent call
			vehicle("FLOE", "White over grey, broken in blocks."), -- inferred equivalent call
			charm("LITTLE ANCHOR", "Heavy for its size.") -- inferred equivalent call
		}
	},
	{
		id = "brasshornet",
		title = "BRASS HORNET",
		tags = "OUTFIT  |  2 GUNS",
		new = true,
		price = 499,
		elite = true,
		theme = "brass",
		blurb = "Polished so everyone on the line looks at you.",
		hero = {
			skins = { "Sapper" },
			tools = { "HandCannon" }
		},
		items = {
			soldier("QUEEN'S GUARD", "Sapper", "Brass buckles on a burnt uniform."), -- inferred equivalent call
			gun("STINGER", "HandCannon", "Engraved brass over dark steel.", { "GRIP" }), -- inferred equivalent call
			gun("SWARM", "GX36", "Its panels glow as you get kills.", { "STOCK", "UNDERBARREL", "OPTIC" }, true), -- inferred equivalent call
			charm("LITTLE KING", "A brass hornet on a chain.") -- inferred equivalent call
		}
	},
	{
		id = "redmeridian",
		title = "RED MERIDIAN",
		tags = "2 OUTFITS  |  GUN  |  TANK",
		price = 799,
		elite = true,
		theme = "ember",
		blurb = "A full squad look in one pack.",
		hero = {
			skins = { "NightRaider", "Specter" }
		},
		items = {
			soldier("MIDNIGHT", "NightRaider", "Black over red, no markings."), -- inferred equivalent call
			soldier("THE WALL", "Specter", "Takes the hits so others don't."), -- inferred equivalent call
			gun( -- inferred equivalent call
				"LONGITUDE",
				"MG60",
				"Red glass panels that wake with every kill.",
				{ "STOCK", "UNDERBARREL", "MUZZLE" },
				true
			),
			vehicle("HOT IRON", "Glowing seams across the hull.") -- inferred equivalent call
		}
	},
	{
		id = "switchblade",
		title = "SWITCHBLADE",
		tags = "2 GUNS",
		new = true,
		price = 299,
		elite = true,
		theme = "steel",
		blurb = "Two guns and a hard edge.",
		hero = {
			tools = { "AssaultRifle", "Shotgun" }
		},
		items = {
			gun("FOLDED STEEL", "AssaultRifle", "Layered grey with a bright edge.", { "STOCK", "UNDERBARREL" }), -- inferred equivalent call
			gun("OPEN LATE", "Shotgun", "Same steel, wider spread of opinion.", { "STOCK" }), -- inferred equivalent call
			charm("PIVOT PIN", "Spins when you run.") -- inferred equivalent call
		}
	},
	{
		id = "fieldmedic",
		title = "FIELD DRESSING",
		tags = "OUTFIT  |  GUN",
		price = 249,
		theme = "viper",
		blurb = "Green cross, black hood.",
		hero = {
			skins = { "Fighter" }
		},
		items = {
			soldier("TRIAGE", "Fighter", "Marked so they know who to shout for."), -- inferred equivalent call
			gun("SUTURE", "LMG", "Dark honeycomb, green stitching.", { "UNDERBARREL" }), -- inferred equivalent call
			charm("BOOTLACE", "A bronze boot on a cord.") -- inferred equivalent call
		}
	},
	{
		id = "lineholder",
		title = "LINE HOLDER",
		tags = "OUTFIT",
		price = 99,
		theme = "steel",
		blurb = "Plain, clean, cheap.",
		hero = {
			skins = { "Standard" }
		},
		items = {
			soldier("STANDFAST", "Standard", "Issue kit, worn properly."), -- inferred equivalent call
			charm("DOG WHISTLE", "Silent. Probably.") -- inferred equivalent call
		}
	},
	{
		id = "gasworks",
		title = "GASWORKS",
		tags = "OUTFIT  |  GUN",
		price = 249,
		theme = "ember",
		blurb = "Rubber, canvas and a bad smell.",
		hero = {
			skins = { "Hazmat" }
		},
		items = {
			soldier("PILOT LIGHT", "Hazmat", "Sealed to the neck."), -- inferred equivalent call
			gun("BACKDRAFT", "HM45", "Scorched to the grip.", { "GRIP" }), -- inferred equivalent call
			charm("MAIN VALVE", "Stamped brass.") -- inferred equivalent call
		}
	},
	{
		id = "nomad",
		title = "NOMAD ROAD",
		tags = "2 OUTFITS",
		price = 199,
		theme = "brass",
		blurb = "Sun-bleached and travelling light.",
		hero = {
			skins = { "Savanna", "Recon" }
		},
		items = {
			soldier("HIRED GUN", "Savanna", "Paid by the week."), -- inferred equivalent call
			soldier("FAR POST", "Recon", "Three days from anywhere."), -- inferred equivalent call
			charm("COMPASS", "Mostly points north.") -- inferred equivalent call
		}
	},
	{
		id = "blackrivet",
		title = "BLACK RIVET",
		tags = "OUTFIT  |  TANK",
		price = 349,
		theme = "glacier",
		blurb = "Dark steel blues for the night shift.",
		hero = {
			skins = { "NightRaider" }
		},
		items = {
			soldier("LOW LIGHT", "NightRaider", "Nothing that shines."), -- inferred equivalent call
			vehicle("MONOLITH BLACK", "Black and blue, no shine."), -- inferred equivalent call
			charm("PIN OUT", "A small blue grenade.") -- inferred equivalent call
		}
	},
	{
		id = "wildhive",
		title = "WILD HIVE",
		tags = "3 GUNS",
		price = 299,
		theme = "brass",
		blurb = "Field-repaired and proud of it.",
		hero = {
			tools = { "SV20", "LMG", "Pistol" }
		},
		items = {
			gun("THICKET", "SV20", "Scrim and leaves tied on.", { "STOCK", "MUZZLE" }), -- inferred equivalent call
			gun("NEST", "LMG", "Brown over tan.", { "UNDERBARREL" }), -- inferred equivalent call
			gun("LITTLE STING", "Pistol", "Tan frame.", { "GRIP" }) -- inferred equivalent call
		}
	},
	{
		id = "jadethunder",
		title = "JADE THUNDER",
		tags = "3 GUNS  |  TANK",
		new = true,
		price = 599,
		elite = true,
		theme = "viper",
		blurb = "Painted over a survey map, every gun a different sheet.",
		hero = {
			tools = { "GX36", "SMG" }
		},
		items = {
			gun( -- inferred equivalent call
				"CONTOUR",
				"GX36",
				"Its map lines light up as you get kills.",
				{ "STOCK", "UNDERBARREL", "OPTIC" },
				true
			),
			gun("SURVEY", "SMG", "Bound with green tape.", { "STOCK", "UNDERBARREL" }), -- inferred equivalent call
			gun("BENCHMARK", "Pistol", "Rust and jade.", { "GRIP" }), -- inferred equivalent call
			vehicle("DELTA", "River-green blocks.") -- inferred equivalent call
		}
	},
	{
		id = "jadeaxe",
		title = "JADE AXE",
		tags = "GUN  |  LAUNCHER",
		price = 349,
		elite = true,
		theme = "viper",
		blurb = "The heavy half.",
		hero = {
			tools = { "GX36" }
		},
		items = {
			gun("CONTOUR", "GX36", "Map lines under green paint.", { "STOCK", "UNDERBARREL" }), -- inferred equivalent call
			gun("CLEARCUT", "RocketLauncher", "Bound with green tape.", { "OPTIC" }), -- inferred equivalent call
			charm("TIMBER", "A tiny axe.") -- inferred equivalent call
		}
	},
	{
		id = "jaderush",
		title = "JADE RUSH",
		tags = "2 GUNS",
		price = 249,
		elite = true,
		theme = "viper",
		blurb = "The light half.",
		hero = {
			tools = { "SMG" }
		},
		items = {
			gun("SURVEY", "SMG", "Bound with green tape.", { "STOCK" }), -- inferred equivalent call
			gun("BENCHMARK", "Pistol", "Rust and jade.", { "GRIP" }), -- inferred equivalent call
			charm("TAPE ROLL", "Never run out.") -- inferred equivalent call
		}
	},
	{
		id = "frostbite",
		title = "FROSTBITE",
		tags = "GUN  |  MELEE",
		price = 149,
		theme = "glacier",
		blurb = "Chipped ice and a sharp spade.",
		hero = {
			tools = { "DMR", "Shovel" }
		},
		items = {
			gun("RIME", "DMR", "Pale blue, chipped.", { "STOCK", "MUZZLE" }), -- inferred equivalent call
			melee("PERMAFROST", "Shovel", "Blued blade."), -- inferred equivalent call
			charm("ICICLE", "Never melts.") -- inferred equivalent call
		}
	},
	{
		id = "recruit",
		title = "RECRUIT PACK",
		tags = "ONE PER PLAYER",
		new = true,
		price = 49,
		theme = "brass",
		blurb = "The cheap way in.",
		hero = {
			tools = { "Pistol" }
		},
		items = {
			gun("PARADE", "Pistol", "Clean and oiled.", { "GRIP" }), -- inferred equivalent call
			charm("LUCKY HELMET", "Tiny and dented."), -- inferred equivalent call
			soldier("FIRST DAY", "Fighter", "Still creased from the box.") -- inferred equivalent call
		}
	},
	{
		id = "veteran",
		title = "VETERAN PACK",
		tags = "ONE PER PLAYER",
		price = 199,
		theme = "viper",
		blurb = "A bigger drop with a sniper's outfit in it.",
		hero = {
			skins = { "Wraith" }
		},
		items = {
			soldier("BRUSHLINE", "Wraith", "Breaks up your shape."), -- inferred equivalent call
			gun("UNDERGROWTH", "K433", "Greens and browns.", { "STOCK", "UNDERBARREL" }), -- inferred equivalent call
			charm("GLOW STICKS", "Glows green at night.") -- inferred equivalent call
		}
	}
}

StoreData.Sections = {
	{
		id = "bundles",
		title = "BUNDLES",
		free = true,
		rows = {
			{ "switchblade" },
			{ "fieldmedic" },
			{ "lineholder" },
			{ "redmeridian" },
			{ "wildhive" },
			{ "jadethunder" },
			{ "jadeaxe", "jaderush" },
			{ "recruit" },
			{ "veteran" }
		}
	},
	{
		id = "spotlight",
		title = "SPOTLIGHT",
		spotlight = { "ironpsalm", "coldharbor", "brasshornet", "redmeridian" }
	},
	{ id = "boosts", title = "BOOSTS", products = "boosts" },
	{ id = "unlocks", title = "UNLOCKS", products = "unlocks" },
	{ id = "scrap", title = "SCRAP", products = "scrap" }
}

StoreData.byId = {}

for _, bundle in StoreData.Bundles do
	StoreData.byId[bundle.id] = bundle
end

return StoreData