local CareerData = {}

CareerData.NUMERALS = {
	"I",
	"II",
	"III",
	"IV",
	"V",
	"VI",
	"VII",
	"VIII",
	"IX",
	"X"
}

CareerData.TRACKS = {
	{
		id = "takedowns",
		name = "KILLS",
		stat = "TAKEDOWN",
		what = "Kill %s enemies",
		goals = {
			5,
			10,
			25,
			50,
			100,
			250,
			500,
			1000,
			2500,
			5000
		},
		scrap = {
			50,
			100,
			150,
			250,
			400,
			600,
			900,
			1300,
			2000,
			3000
		}
	},
	{
		id = "headshots",
		name = "HEADSHOTS",
		stat = "HEADSHOT",
		what = "Finish %s enemies with a headshot",
		goals = { 5, 25, 100, 250, 500, 1000 },
		scrap = { 100, 200, 400, 700, 1100, 1800 }
	},
	{
		id = "support",
		name = "SUPPORT",
		stat = "SUPPORT",
		what = "Help with %s kills",
		goals = { 10, 50, 200, 500, 1500 },
		scrap = { 50, 150, 350, 700, 1400 }
	},
	{
		id = "wrecker",
		name = "WRECKER",
		stat = "VEHICLE_DOWN",
		what = "Wreck %s enemy vehicles",
		goals = { 1, 5, 25, 100, 250 },
		scrap = { 100, 250, 600, 1200, 2500 }
	},
	{
		id = "captures",
		name = "CAPTURES",
		stat = "CAPTURED",
		what = "Capture %s points",
		goals = { 1, 10, 50, 150, 400 },
		scrap = { 50, 200, 500, 1000, 2000 }
	},
	{
		id = "wins",
		name = "VICTORIES",
		stat = "WIN",
		what = "Win %s rounds",
		goals = { 1, 5, 25, 100, 250 },
		scrap = { 100, 300, 800, 1600, 3000 }
	}
}

function CareerData.badgeId(p, p2: number)
	return p.id .. ":" .. p2
end

function CareerData.find(value: string)
	local v, v2 = string.match(value, "^(.-):(%d+)$")

	for _, v3 in CareerData.TRACKS do
		if v3.id ~= v then
			continue
		end

		local v4 = tonumber(v2)

		if v4 and v3.goals[v4] then
			return v3, v4
		end
	end

	return nil, nil
end

CareerData.DAILY = { 100, 150, 200, 250, 300, 400, 750 }

CareerData.DAILY_SKIN = "SALVAGE"

CareerData.DAILY_SKIN_SAID = "GUN SKIN UNLOCKED"

function CareerData.dailyDay(p: number)
	if p < 1 then
		return 0
	end

	return (p - 1) % #CareerData.DAILY + 1
end

CareerData.DUTY = { every = 900, scrap = 200, hold = 4 }

CareerData.FREE = { every = 600, scrap = 100 }
CareerData.FREE_ATTR = "FreeScrapAt"

function CareerData.day(p: number)
	return p // 86400
end

CareerData.STORE = {
	boosts = {
		{
			id = "xp30",
			image = "rbxassetid://113897983287754",
			kind = "boost",
			name = "PLAYER XP BOOST",
			blurb = "Double XP for 30 minutes of play.",
			productId = 3723122673,
			seconds = 1800,
			robux = 39,
			big = "1 BOOST",
			line2 = "2X PLAYER XP FOR 30 MIN"
		},
		{
			id = "xp120",
			image = "rbxassetid://88628227580441",
			kind = "boost",
			name = "4 PLAYER XP BOOSTS",
			blurb = "Double XP for 2 hours of play.",
			productId = 3723122703,
			seconds = 7200,
			robux = 159,
			big = "4 BOOSTS",
			line2 = "2X PLAYER XP FOR 120 MIN"
		},
		{
			id = "xp240",
			image = "rbxassetid://138629400398799",
			kind = "boost",
			name = "8 PLAYER XP BOOSTS",
			blurb = "Double XP for 4 hours of play.",
			productId = 3727108639,
			seconds = 14400,
			robux = 199,
			big = "8 BOOSTS",
			line2 = "2X PLAYER XP FOR 240 MIN",
			tag = { "SAVE", "36%" }
		}
	},
	gunBoosts = {
		{
			id = "gunxp30",
			image = "rbxassetid://76838437712740",
			kind = "gunBoost",
			name = "WEAPON XP BOOST",
			blurb = "Double weapon XP for 30 minutes of play.",
			productId = 3727108647,
			seconds = 1800,
			robux = 29,
			big = "1 BOOST",
			line2 = "2X WEAPON XP FOR 30 MIN"
		},
		{
			id = "gunxp120",
			image = "rbxassetid://98497100129755",
			kind = "gunBoost",
			name = "4 WEAPON XP BOOSTS",
			blurb = "Double weapon XP for 2 hours of play.",
			productId = 3727108656,
			seconds = 7200,
			robux = 119,
			big = "4 BOOSTS",
			line2 = "2X WEAPON XP FOR 120 MIN"
		},
		{
			id = "gunxp240",
			image = "rbxassetid://101637583483521",
			kind = "gunBoost",
			name = "8 WEAPON XP BOOSTS",
			blurb = "Double weapon XP for 4 hours of play.",
			productId = 3727108661,
			seconds = 14400,
			robux = 149,
			big = "8 BOOSTS",
			line2 = "2X WEAPON XP FOR 240 MIN",
			tag = { "SAVE", "36%" }
		}
	},
	scrap = {
		{
			id = "scrapS",
			image = "rbxassetid://85171327224367",
			kind = "scrap",
			name = "200 SCRAP",
			blurb = "A crate of Scrap for the scrapyard shop.",
			productId = 3723122711,
			scrap = 200,
			robux = 49,
			big = "200 SCRAP"
		},
		{
			id = "scrapM",
			image = "rbxassetid://78488632167480",
			kind = "scrap",
			name = "1,000 SCRAP",
			blurb = "A pallet of Scrap for the scrapyard shop.",
			productId = 3723122724,
			scrap = 1000,
			robux = 249,
			big = "1,000 SCRAP"
		},
		{
			id = "scrapL",
			image = "rbxassetid://138566429024079",
			kind = "scrap",
			name = "1,800 SCRAP",
			blurb = "A truckload of Scrap: 1,200 plus 600 bonus.",
			productId = 3723122735,
			scrap = 1800,
			bonus = 600,
			robux = 299,
			big = "1,800 SCRAP",
			line2 = "+600 BONUS",
			tag = { "+50%", "BONUS" }
		}
	},
	unlocks = {
		{
			id = "unlockPipeBomb",
			robux = 49,
			image = "rbxassetid://114469023162909",
			kind = "unlock",
			name = "SMOKE GRENADE",
			blurb = "Unlock it right now.",
			productId = 3723122796,
			item = "Smoke"
		},
		{
			id = "unlockMinigun",
			robux = 149,
			image = "rbxassetid://126817070350377",
			kind = "unlock",
			name = "MINIGUN STREAK",
			blurb = "Unlocked and equipped as your scorestreak.",
			productId = 3723122803,
			item = "Minigun"
		},
		{
			id = "unlockHellfire",
			robux = 249,
			image = "rbxassetid://91435321328830",
			kind = "unlock",
			name = "HELLFIRE STREAK",
			blurb = "Unlocked and equipped as your scorestreak.",
			productId = 3723122812,
			item = "Hellfire"
		},
		{
			id = "unlockGunship",
			robux = 349,
			image = "rbxassetid://121705299775315",
			kind = "unlock",
			name = "GUNSHIP STREAK",
			blurb = "Unlocked and equipped as your scorestreak.",
			productId = 3723122821,
			item = "Gunship"
		}
	},
	retired = {
		{
			id = "unlockSMG",
			image = "rbxassetid://117850628708110",
			kind = "unlock",
			name = "PX-9",
			blurb = "Unlock it right now.",
			productId = 3723122744,
			item = "SMG"
		},
		{
			id = "unlockShotgun",
			image = "rbxassetid://138420198322678",
			kind = "unlock",
			name = "PA-12",
			blurb = "Unlock it right now.",
			productId = 3723122754,
			item = "Shotgun"
		},
		{
			id = "unlockSniper",
			image = "rbxassetid://117262619744595",
			kind = "unlock",
			name = "LR-7",
			blurb = "Unlock it right now.",
			productId = 3723122762,
			item = "Sniper"
		},
		{
			id = "unlockDMR",
			image = "rbxassetid://75691504313015",
			kind = "unlock",
			name = "MR-14",
			blurb = "Unlock it right now.",
			productId = 3723122776,
			item = "DMR"
		},
		{
			id = "unlockLMG",
			image = "rbxassetid://116004803761022",
			kind = "unlock",
			name = "HB-100",
			blurb = "Unlock it right now.",
			productId = 3723122787,
			item = "LMG"
		},
		{
			id = "starterOld",
			kind = "starter",
			name = "STEALTH PACK",
			blurb = "Stealth chopper and three XP boosts.",
			productId = 3727056042,
			seconds = 5400,
			item = "StealthHeli",
			scrap = 8000
		},
		{
			id = "crate5",
			kind = "crate",
			name = "5 SUPPLY CRATES",
			blurb = "Five crate-only skins. Each fits every gun.",
			productId = 3729605545,
			n = 5
		}
	}
}

CareerData.STEALTH_PACK_ID = 3727056060

local VehicleBayData = require(script.Parent.VehicleBayData)
local vehicles = {}

for _, v in VehicleBayData.LIST do
	if not (v.own ~= 0 or v.call ~= 0) then
		continue
	end

	if v.own ~= CareerData.STEALTH_PACK_ID then
		table.insert(vehicles, {
			id = "own" .. v.id,
			kind = "vehicle",
			name = v.name,
			blurb = v.blurb,
			productId = v.own,
			scrap = v.scrap,
			item = v.id
		})
	end

	table.insert(vehicles, {
		id = "call" .. v.id,
		kind = "vehicleCall",
		name = v.name,
		blurb = v.blurb,
		productId = v.call,
		item = v.id
	})
end

CareerData.STORE.vehicles = vehicles

CareerData.STORE.instant = {
	{
		id = "instantK433",
		kind = "unlock",
		name = "K-433",
		blurb = "Unlock it right now.",
		productId = 3727055506,
		robux = 79,
		item = "K433"
	},
	{
		id = "instantGX36",
		kind = "unlock",
		name = "GX-36",
		blurb = "Unlock it right now.",
		productId = 3727055571,
		robux = 169,
		item = "GX36"
	},
	{
		id = "instantSK556",
		kind = "unlock",
		name = "SK-556",
		blurb = "Unlock it right now.",
		productId = 3727055592,
		robux = 199,
		item = "SK556"
	},
	{
		id = "instantRN545",
		kind = "unlock",
		name = "RN-545",
		blurb = "Unlock it right now.",
		productId = 3727055613,
		robux = 269,
		item = "RN545"
	},
	{
		id = "instantMX65",
		kind = "unlock",
		name = "MX-65",
		blurb = "Unlock it right now.",
		productId = 3727055646,
		robux = 329,
		item = "MX65"
	},
	{
		id = "instantBT762",
		kind = "unlock",
		name = "BT-762",
		blurb = "Unlock it right now.",
		productId = 3727055679,
		robux = 399,
		item = "BT762"
	},
	{
		id = "instantKP50",
		kind = "unlock",
		name = "KP-50",
		blurb = "Unlock it right now.",
		productId = 3727055714,
		robux = 99,
		item = "KP50"
	},
	{
		id = "instantHM45",
		kind = "unlock",
		name = "HM-45",
		blurb = "Unlock it right now.",
		productId = 3727055731,
		robux = 129,
		item = "HM45"
	},
	{
		id = "instantGV12",
		kind = "unlock",
		name = "GV-12",
		blurb = "Unlock it right now.",
		productId = 3727055759,
		robux = 199,
		item = "GV12"
	},
	{
		id = "instantFS16",
		kind = "unlock",
		name = "FS-16",
		blurb = "Unlock it right now.",
		productId = 3727055776,
		robux = 129,
		item = "FS16"
	},
	{
		id = "instantQS9",
		kind = "unlock",
		name = "QS-9",
		blurb = "Unlock it right now.",
		productId = 3729602477,
		robux = 299,
		item = "QS9"
	},
	{
		id = "instantKR54",
		kind = "unlock",
		name = "KR-54",
		blurb = "Unlock it right now.",
		productId = 3729602484,
		robux = 349,
		item = "KR54"
	},
	{
		id = "instantBX110",
		kind = "unlock",
		name = "BX-110",
		blurb = "Unlock it right now.",
		productId = 3727055790,
		robux = 199,
		item = "BX110"
	},
	{
		id = "instantHX83",
		kind = "unlock",
		name = "HX-83",
		blurb = "Unlock it right now.",
		productId = 3727055815,
		robux = 199,
		item = "HX83"
	},
	{
		id = "instantMG60",
		kind = "unlock",
		name = "MG-60",
		blurb = "Unlock it right now.",
		productId = 3727055832,
		robux = 249,
		item = "MG60"
	},
	{
		id = "instantKT8",
		kind = "unlock",
		name = "KT-8",
		blurb = "Unlock it right now.",
		productId = 3730559071,
		robux = 349,
		item = "KT8"
	},
	{
		id = "instantNX68",
		kind = "unlock",
		name = "NX-68",
		blurb = "Unlock it right now.",
		productId = 3730559089,
		robux = 379,
		item = "NX68"
	},
	{
		id = "instantGR240",
		kind = "unlock",
		name = "GR-240",
		blurb = "Unlock it right now.",
		productId = 3730559148,
		robux = 399,
		item = "GR240"
	},
	{
		id = "instantRX10",
		kind = "unlock",
		name = "RX-10",
		blurb = "Unlock it right now.",
		productId = 3727055860,
		robux = 449,
		item = "RX10"
	},
	{
		id = "instantSC11",
		kind = "unlock",
		name = "SC-11",
		blurb = "Unlock it right now.",
		productId = 3727055884,
		robux = 249,
		item = "SC11"
	},
	{
		id = "instantVX50",
		kind = "unlock",
		name = "VX-50",
		blurb = "Unlock it right now.",
		productId = 3730381404,
		robux = 499,
		item = "VX50"
	},
	{
		id = "instantHandCannon",
		kind = "unlock",
		name = "HAND CANNON",
		blurb = "Unlock it right now.",
		productId = 3727055902,
		robux = 59,
		item = "HandCannon"
	},
	{
		id = "instantSV20",
		kind = "unlock",
		name = "SV-20",
		blurb = "Unlock it right now.",
		productId = 3727055929,
		robux = 99,
		item = "SV20"
	},
	{
		id = "instantZK10",
		kind = "unlock",
		name = "ZK-10",
		blurb = "Unlock it right now.",
		productId = 3727055945,
		robux = 129,
		item = "ZK10"
	},
	{
		id = "instantMolotov",
		kind = "unlock",
		name = "MOLOTOV",
		blurb = "Unlock it right now.",
		productId = 3727055981,
		robux = 59,
		item = "Molotov"
	},
	{
		id = "instantFlamethrower",
		kind = "unlock",
		name = "FLAMETHROWER",
		blurb = "Unlock it right now.",
		productId = 3727056009,
		robux = 99,
		item = "Flamethrower"
	},
	{
		id = "instantClaymore",
		kind = "unlock",
		name = "CLAYMORE",
		blurb = "Unlock it right now.",
		productId = 3730617932,
		robux = 79,
		item = "Claymore"
	},
	{
		id = "instantC4",
		kind = "unlock",
		name = "C4",
		blurb = "Unlock it right now.",
		productId = 3730617956,
		robux = 119,
		item = "C4"
	},
	{
		id = "instantPD46",
		kind = "unlock",
		name = "PD-46",
		blurb = "Unlock it right now.",
		productId = 3729602489,
		robux = 279,
		item = "PD46"
	},
	{
		id = "instantSP44",
		kind = "unlock",
		name = "SP-44",
		blurb = "Unlock it right now.",
		productId = 3729602495,
		robux = 279,
		item = "SP44"
	},
	{
		id = "instantTK17",
		kind = "unlock",
		name = "TK-17",
		blurb = "Unlock it right now.",
		productId = 3729602500,
		robux = 299,
		item = "TK17"
	}
}

CareerData.REFUND_PER_ROBUX = 5

local ShopData = require(script.Parent.ShopData)

local items = {}

for k, v in ShopData.ITEMS do
	if not ((v.price or 0) > 0 and (v.slot == "primary" or v.slot == "secondary" or k == "Molotov" or k == "Flamethrower")) then
		continue
	end

	table.insert(items, k)
end

table.sort(items, function(a, b): boolean
	return ShopData.unlockLevel(a) < ShopData.unlockLevel(b)
end)

CareerData.STORE.weaponPacks = {
	{
		id = "packAll",
		kind = "weaponPack",
		name = "EVERY GUN",
		blurb = "Every gun now, and every new gun.",
		productId = 3729602596,
		robux = 3499,
		tier = "gold",
		all = true,
		items = items,
		show = { "BT762", "MG60", "RX10" },
		lines = { #items .. " WEAPONS", "ALL RIFLES", "ALL SNIPERS" }
	},
	{
		id = "packRifles",
		kind = "weaponPack",
		name = "RIFLE PACK",
		blurb = "All six rifles.",
		productId = 3729602602,
		robux = 999,
		tier = "purple",
		items = { "K433", "GX36", "SK556", "RN545", "MX65", "BT762" },
		show = { "MX65", "RN545", "BT762" },
		lines = { "6 RIFLES" }
	},
	{
		id = "packSnipers",
		kind = "weaponPack",
		name = "SNIPER PACK",
		blurb = "Every sniper: the SC-11, RX-10 and VX-50 (the LR-7 is free).",
		productId = 3729602610,
		robux = 499,
		tier = "purple",
		items = { "SC11", "RX10", "VX50" },
		show = { "VX50", "RX10", "SC11" },
		lines = { "ALL SNIPERS", "RX-10", "VX-50" }
	},
	{
		id = "packSMGs",
		kind = "weaponPack",
		name = "SMG PACK",
		blurb = "Five SMGs.",
		productId = 3729602622,
		robux = 749,
		tier = "blue",
		items = { "KP50", "HM45", "PD46", "SP44", "TK17" },
		show = { "TK17", "SP44", "PD46" },
		lines = { "5 SMGS" }
	},
	{
		id = "packHeavy",
		kind = "weaponPack",
		name = "HEAVY PACK",
		blurb = "Three LMGs and the Flamethrower.",
		productId = 3729602628,
		robux = 499,
		tier = "blue",
		items = { "BX110", "HX83", "MG60", "Flamethrower" },
		show = { "MG60", "Flamethrower", "BX110" },
		lines = { "3 LMGS", "FLAMETHROWER" }
	},
	{
		id = "packStreaks",
		kind = "weaponPack",
		name = "STREAK PACK",
		blurb = "Three scorestreaks and the smoke grenade.",
		productId = 3729602638,
		robux = 499,
		tier = "blue",
		items = { "Minigun", "Hellfire", "Gunship", "Smoke" },
		show = { "Gunship", "Hellfire", "Minigun" },
		lines = { "MINIGUN", "HELLFIRE", "GUNSHIP", "SMOKE" }
	}
}

CareerData.STORE.outfits = {
	{
		id = "outfitSkyRaider",
		kind = "outfit",
		name = "SKY RAIDER",
		blurb = "Flight helmet, mask and harness.",
		productId = 3729941394,
		robux = 199,
		skin = "SkyRaider",
		image = "rbxassetid://74887299672601"
	},
	{
		id = "outfitInferno",
		kind = "outfit",
		name = "INFERNO",
		blurb = "Fire-proof armour, respirator and fuel tanks.",
		productId = 3729941408,
		robux = 249,
		skin = "Inferno",
		image = "rbxassetid://86235383486350"
	},
	{
		id = "outfitVenom",
		kind = "outfit",
		name = "VENOM",
		blurb = "Gas mask with glowing lenses, night vision, toxic green camo.",
		productId = 3729953715,
		robux = 299,
		skin = "Venom",
		image = "rbxassetid://96467653881398"
	},
	{
		id = "outfitRevenant",
		kind = "outfit",
		name = "REVENANT",
		blurb = "Grey hood and cloak over black gear, slung breaching hammer.",
		productId = 3729955818,
		robux = 299,
		skin = "Revenant",
		image = "rbxassetid://97308475025498"
	}
}

CareerData.STORE.outfitPacks = {
	{
		id = "packOutfits",
		kind = "outfitPack",
		name = "ELITE OUTFIT PACK",
		blurb = "All four elite outfits and their gun skins.",
		productId = 3730188691,
		robux = 1999,
		skins = { "SkyRaider", "Venom", "Inferno", "Revenant" },
		image = "rbxassetid://112293258975362"
	}
}

CareerData.STORE.outfitBundles = {
	{
		id = "bundleSkyRaider",
		kind = "outfitBundle",
		name = "SKY RAIDER",
		blurb = "The outfit and its gun skin.",
		productId = 3730188517,
		robux = 699,
		was = 999,
		skin = "SkyRaider",
		camo = "AFTERBURN",
		image = "rbxassetid://84161702168034"
	},
	{
		id = "bundleVenom",
		kind = "outfitBundle",
		name = "VENOM",
		blurb = "The outfit and its gun skin.",
		productId = 3730188529,
		robux = 699,
		was = 999,
		skin = "Venom",
		camo = "FANG",
		image = "rbxassetid://95733862769221"
	},
	{
		id = "bundleInferno",
		kind = "outfitBundle",
		name = "INFERNO",
		blurb = "The outfit and its gun skin.",
		productId = 3730188659,
		robux = 699,
		was = 999,
		skin = "Inferno",
		camo = "CINDER",
		image = "rbxassetid://135477016460828"
	},
	{
		id = "bundleRevenant",
		kind = "outfitBundle",
		name = "REVENANT",
		blurb = "The outfit and its gun skin.",
		productId = 3730188672,
		robux = 699,
		was = 999,
		skin = "Revenant",
		camo = "PHANTOM",
		image = "rbxassetid://74551179947423"
	}
}

function CareerData.outfitOf(p: string)
	for _, outfit in CareerData.STORE.outfits do
		if outfit.skin == p then
			return outfit
		end
	end

	return nil
end

function CareerData.unlockOf(p: string)
	for _, v in { CareerData.STORE.instant, CareerData.STORE.unlocks } do
		for _, v2 in v do
			if v2.item == p and v2.productId ~= 0 then
				return v2
			end
		end
	end

	return nil
end

CareerData.STORE.starter = {
	{
		id = "starter",
		kind = "starter",
		name = "STEALTH PACK",
		blurb = "Stealth chopper and three XP boosts.",
		productId = CareerData.STEALTH_PACK_ID,
		robux = 1499,
		worth = 1616,
		seconds = 5400,
		item = "StealthHeli",
		scrap = 8000
	}
}

CareerData.STORE.crates = {
	{
		id = "crate1",
		image = "rbxassetid://129856786202198",
		kind = "crate",
		name = "SUPPLY CRATE",
		blurb = "One crate-only skin for every gun of the crate's kind.",
		productId = 3729605513,
		robux = 100,
		n = 1,
		big = "1 CRATE",
		line2 = "1 CRATE SKIN"
	},
	{
		id = "crate3",
		image = "rbxassetid://77612429755866",
		kind = "crate",
		name = "3 SUPPLY CRATES",
		blurb = "Three crate-only skins for every gun of the crate's kind.",
		productId = 3730555532,
		robux = 300,
		n = 3,
		big = "3 CRATES",
		line2 = "3 CRATE SKINS"
	},
	{
		id = "crate8",
		image = "rbxassetid://132226450670008",
		kind = "crate",
		name = "8 SUPPLY CRATES",
		blurb = "Eight crate-only skins for every gun of the crate's kind.",
		productId = 3730555558,
		robux = 800,
		n = 8,
		big = "8 CRATES",
		line2 = "8 CRATE SKINS"
	}
}

CareerData.STORE.revive = {
	{
		id = "revive",
		image = "rbxassetid://129411186407189",
		kind = "revive",
		name = "INSTANT REVIVE",
		blurb = "Get up where you fell, at full health.",
		productId = 3729605552,
		robux = 5
	}
}

CareerData.SCRAP2X_ATTR = "Scrap2X"
CareerData.STORE.scrapBoost = {
	{
		id = "scrap2x",
		kind = "scrapBoost",
		name = "2X SCRAP FOREVER",
		blurb = "Double Scrap from every match, for good.",
		productId = 3730205933,
		robux = 1000,
		big = "2X SCRAP",
		line2 = "FOREVER",
		image = "rbxassetid://77692676184223",
		scrap = 5000
	}
}

CareerData.STORE_TABS = {
	{ id = "boosts", label = "BOOSTS" },
	{ id = "unlocks", label = "UNLOCKS" },
	{ id = "scrap", label = "SCRAP" }
}

function CareerData.product(p: number)
	if p == 0 then
		return nil
	end

	for _, v in CareerData.STORE do
		for _, v2 in v do
			if v2.productId == p then
				return v2
			end
		end
	end

	return nil
end

CareerData.GIFTS = {
	scrapS = 3728745561,
	scrapM = 3728745649,
	scrapL = 3728745654,
	xp30 = 3728745667,
	xp120 = 3728745691,
	xp240 = 3728745701,
	gunxp30 = 3728745715,
	gunxp120 = 3728745725,
	gunxp240 = 3728745741,
	starter = 3728745753,
	unlockPipeBomb = 3728745782,
	unlockMinigun = 3728745799,
	unlockHellfire = 3728745813,
	unlockGunship = 3728745829,
	instantK433 = 3728745896,
	instantGX36 = 3728751191,
	instantSK556 = 3728746152,
	instantRN545 = 3728746192,
	instantMX65 = 3728746204,
	instantBT762 = 3728751218,
	instantKP50 = 3728746232,
	instantHM45 = 3728746258,
	instantGV12 = 3728751243,
	instantFS16 = 3728751268,
	instantQS9 = 3729602837,
	instantKR54 = 3729602848,
	instantBX110 = 3728751296,
	instantHX83 = 3728751322,
	instantMG60 = 3728751344,
	instantRX10 = 3728751362,
	instantSC11 = 3728751370,
	instantHandCannon = 3728751390,
	instantSV20 = 3728751420,
	instantZK10 = 3728751441,
	instantMolotov = 3728751465,
	instantFlamethrower = 3728751488,
	instantClaymore = 3730617943,
	instantC4 = 3730617965,
	instantPD46 = 3729602853,
	instantSP44 = 3729602860,
	instantTK17 = 3729602866,
	instantVX50 = 3730381377,
	instantKT8 = 3730559102,
	instantNX68 = 3730559108,
	instantGR240 = 3730559114,
	crate1 = 3730570226,
	crate3 = 3730570236,
	crate8 = 3730570244
}

CareerData.GIFT_REMOTE = "Gift"

function CareerData.byId(p: string)
	for _, v in CareerData.STORE do
		for _, v2 in v do
			if v2.id == p then
				return v2
			end
		end
	end

	return nil
end

function CareerData.giftOf(p: string)
	local v = CareerData.GIFTS[p]
	return if v and v ~= 0 then v else nil
end

function CareerData.giftProduct(p: number)
	if p == 0 then
		return nil
	end

	for k, v in CareerData.GIFTS do
		if v == p then
			return CareerData.byId(k)
		end
	end

	return nil
end

CareerData.BOOST_ATTR = "XPBoostUntil"

CareerData.GUN_BOOST_ATTR = "GunBoostUntil"

CareerData.BOOST_SECONDS = 1800
CareerData.STOCK_ATTR = {
	boost = "XPBoostStock",
	gunBoost = "GunBoostStock",
	crate = "CrateStock",
	revive = "ReviveStock"
}

return CareerData