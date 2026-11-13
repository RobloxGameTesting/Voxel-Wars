local QuestData = {}
QuestData.DAILY_COUNT = 8
QuestData.WEEKLY_COUNT = 16
QuestData.MISSIONS_ON = false
QuestData.BONUS_AT = 10
QuestData.SWAPS = { daily = 1, weekly = 2 }
QuestData.TRACK_MAX = 3
QuestData.STUDS_PER_M = 2.5
QuestData.GOALS_REV = 2
QuestData.GOAL_WAS = {
	d_aimed = 40,
	d_assists = 20,
	d_captures = 8,
	d_close = 30,
	d_closequarters = 40,
	d_damage = 6000,
	d_damageaim = 4000,
	d_damageclose = 3000,
	d_damagefar = 800,
	d_dmr = 25,
	d_dmrs = 40,
	d_domscore = 8000,
	d_domwins = 2,
	d_either = 80,
	d_explosive = 8,
	d_far = 25,
	d_finish = 6,
	d_headshots = 15,
	d_headx2 = 60,
	d_hipdamage = 2000,
	d_kills = 60,
	d_lifecaps = 2,
	d_lifehead = 3,
	d_lifekills = 8,
	d_lifescore = 1500,
	d_lmg = 35,
	d_lmgs = 4000,
	d_long = 10,
	d_melee = 6,
	d_neutralize = 8,
	d_pistol = 15,
	d_point = 25,
	d_rifle = 40,
	d_rifles = 60,
	d_rocket = 15,
	d_roundcaps = 4,
	d_rounddamage = 2500,
	d_roundkills = 20,
	d_rounds = 4,
	d_roundscore = 4000,
	d_score = 10000,
	d_shotgun = 20,
	d_shotguns = 25,
	d_siegekills = 50,
	d_siegewins = 2,
	d_smg = 35,
	d_smgs = 50,
	d_sniper = 20,
	d_snipers = 30,
	d_streak = 15,
	d_tdmkills = 50,
	d_tdmwins = 2,
	d_turrets = 4,
	d_vehicle = 25,
	d_vehicledamage = 1000,
	d_vehicles = 4,
	d_wins = 3,
	d_wreck = 80,
	w_lifecaps = 4,
	w_lifehead = 6,
	w_lifekills = 15,
	w_lifescore = 3000,
	w_roundcaps = 8,
	w_rounddamage = 5000,
	w_roundkills = 40,
	w_roundscore = 8000,
	w_vehicledamage = 8000,
	w_wreck = 600
}

QuestData.EVENT = {
	TAKEDOWN = "kills",
	SUPPORT = "assists",
	CAPTURED = "captures",
	NEUTRALIZED = "neutralize",
	VEHICLE_DOWN = "vehicles",
	VEHICLE_HIT = "vehicle_hit",
	TURRET_DOWN = "turrets",
	ROUND = "rounds",
	WIN = "wins",
	BREACH = "wreck",
	DEMOLITION = "wreck"
}

QuestData.GROUP = {}

for k, v in {
	rifle = { "AssaultRifle", "K433", "GX36", "SK556", "RN545", "MX65", "BT762" },
	smg = { "SMG", "HM45", "KP50", "PD46", "SP44", "TK17" },
	lmg = { "LMG", "MG60", "HX83", "BX110", "KT8", "NX68", "GR240" },
	dmr = { "DMR", "GV12", "FS16", "KR54", "QS9" },
	sniper = { "Sniper", "SC11", "RX10", "VX50" },
	shotgun = { "Shotgun" },
	pistol = { "Pistol", "HandCannon", "ZK10", "SV20", "DR27" },
	rocket = { "RocketLauncher", "AALauncher" },
	explosive = { "Grenade", "PipeBomb" },
	fire = { "Flamethrower", "Molotov" },
	melee = { "Hammer", "Shovel", "Fists" },
	vehicle = {
		"Tank",
		"TankCannon",
		"TankGun",
		"Bradley",
		"BradleyCannon",
		"Humvee",
		"Heli",
		"HeavyGun"
	},
	streak = {
		"Airstrike",
		"Minigun",
		"Hellfire",
		"Gunship",
		"GunshipHeavy",
		"GunshipCannon",
		"GunshipGun"
	}
} do
	for _, v2 in v do
		QuestData.GROUP[v2] = k
	end
end

local function commas(p: number)
	local v = tostring(p)

	repeat
		local v2
		v, v2 = string.gsub(v, "^(%d+)(%d%d%d)", "%1,%2")
	until v2 == 0

	return v
end

QuestData.CATS = {
	{ id = "bonus", title = "BONUS" },
	{ id = "combat", title = "COMBAT" },
	{ id = "weapons", title = "WEAPONS" },
	{ id = "points", title = "OBJECTIVES" },
	{ id = "vehicles", title = "VEHICLES" },
	{ id = "feats", title = "FEATS" }
}

local v = {
	kills = { "combat", "kills" },
	kill = { "combat", "kills" },
	headshots = { "combat", "headshot" },
	assists = { "combat", "assist" },
	score = { "combat", "score" },
	damage = { "combat", "damage" },
	captures = { "points", "capture" },
	neutralize = { "points", "neutralize" },
	rounds = { "points", "round" },
	wins = { "points", "win" },
	wreck = { "points", "wreck" },
	vehicles = { "vehicles", "vehicle" },
	turrets = { "vehicles", "turret" },
	vehicle_hit = { "vehicles", "vehicle" },
	kill_vehicle = { "vehicles", "vehicle" },
	kill_streak = { "vehicles", "streak" },
	kill_explosive = { "weapons", "explosive" },
	kill_fire = { "weapons", "fire" },
	kill_melee = { "weapons", "melee" }
}

local v2 = {
	close = "close",
	far = "long",
	long = "long",
	aimed = "aimed",
	hip = "hip",
	hipdamage = "hip",
	point = "capture",
	damagefar = "long",
	damageclose = "close",
	damageaim = "aimed",
	finish = "round"
}

local function look(p: string, p2: string, p3: string?, p4)
	local v3 = v[p2]
	local v4 = not v3 and "weapons" or v3[1]
	local v5 = v2[p] or not v3 and "kills" or v3[2]

	if p4.scope then
		return "feats", v5
	end

	if p3 or p4.only and p4.only.group and type(p4.only.group) == "string" or p == "closequarters" then
		return "weapons", v5
	end

	return p4.only and (p4.only.mode or p4.only.point) and "points" or v4, v5
end

local function entry(p: string, list)
	local v3 = list[8] or {}
	local cat, icon = look(list[1], list[2], list[7], v3)
	return {
		id = p .. list[1],
		event = list[2],
		name = string.format(list[3], commas(list[4])),
		goal = list[4],
		xp = list[5],
		scrap = list[6],
		tool = list[7],
		events = v3.events,
		only = v3.only,
		x2 = v3.x2,
		tag = v3.tag,
		scope = v3.scope,
		swappable = true,
		cat = cat,
		icon = icon
	}
end

local function pool(p: string, items)
	local result = {}

	for k, item in items do
		result[k] = entry(p, item)
	end

	return result
end

local group2 = { "rifle", "smg", "lmg", "dmr", "sniper", "shotgun", "pistol" }
local v3 = {
	{
		"either",
		"kills",
		"Get %s kills or assists",
		120,
		600,
		nil,
		{
			events = { "assists" }
		}
	},
	{
		"close",
		"kill",
		"Get %s kills under 15m",
		45,
		220,
		nil,
		{
			only = { near = 15 }
		}
	},
	{
		"far",
		"kill",
		"Get %s kills beyond 40m",
		40,
		180,
		nil,
		{
			only = { far = 40 }
		}
	},
	{
		"long",
		"kill",
		"Get %s kills beyond 75m",
		15,
		70,
		nil,
		{
			only = { far = 75 }
		}
	},
	{
		"aimed",
		"kill",
		"Get %s aimed kills",
		60,
		300,
		nil,
		{
			only = { aimed = true, group = group2 }
		}
	},
	{
		"hip",
		"kill",
		"Get %s hip-fire kills",
		20,
		150,
		nil,
		{
			only = { aimed = false, group = group2 }
		}
	},
	{
		"point",
		"kill",
		"Get %s kills on points",
		40,
		180,
		nil,
		{
			only = { point = true }
		}
	},
	{ "damage", "damage", "Deal %s damage", 9000, 45000 },
	{
		"damageclose",
		"damage",
		"Deal %s close damage",
		4500,
		22000,
		nil,
		{
			only = { near = 25 }
		}
	},
	{
		"damagefar",
		"damage",
		"Deal %s damage past 75m",
		1200,
		6000,
		nil,
		{
			only = { far = 75 }
		}
	},
	{
		"damageaim",
		"damage",
		"Deal %s aimed damage",
		6000,
		30000,
		nil,
		{
			only = { aimed = true, group = group2 }
		}
	},
	{ "vehicledamage", "vehicle_hit", "Deal %s vehicle damage", 1500, 12000 },
	{
		"rifles",
		"kill",
		"Get %s rifle takedowns",
		90,
		450,
		"AssaultRifle",
		{
			events = { "assists" },
			only = { group = "rifle" },
			x2 = { far = 25 },
			tag = "BEYOND 25M X2"
		}
	},
	{
		"smgs",
		"kill",
		"Get %s SMG takedowns",
		75,
		380,
		"SMG",
		{
			events = { "assists" },
			only = { group = "smg" },
			x2 = { aimed = false },
			tag = "HIP-FIRE X2"
		}
	},
	{
		"lmgs",
		"damage",
		"Deal %s LMG damage",
		6000,
		30000,
		"LMG",
		{
			only = { group = "lmg" },
			x2 = { near = 25 },
			tag = "UNDER 25M X2"
		}
	},
	{
		"dmrs",
		"kill",
		"Get %s marksman takedowns",
		60,
		300,
		"DMR",
		{
			events = { "assists" },
			only = { group = "dmr" },
			x2 = { head = true },
			tag = "HEADSHOTS X2"
		}
	},
	{
		"snipers",
		"kill",
		"Get %s sniper takedowns",
		45,
		220,
		"Sniper",
		{
			events = { "assists" },
			only = { group = "sniper" },
			x2 = { far = 75 },
			tag = "BEYOND 75M X2"
		}
	},
	{
		"shotguns",
		"kill",
		"Get %s kills under 15m",
		40,
		180,
		"Shotgun",
		{
			only = { group = "shotgun", near = 15 }
		}
	},
	{
		"closequarters",
		"kill",
		"Get %s SMG or shotgun kills",
		60,
		300,
		nil,
		{
			only = {
				group = { "smg", "shotgun" }
			}
		}
	},
	{
		"headx2",
		"kill",
		"Get %s kills",
		90,
		450,
		nil,
		{
			x2 = { head = true },
			tag = "HEADSHOTS X2"
		}
	},
	{
		"finish",
		"rounds",
		"Finish %s rounds",
		9,
		40,
		nil,
		{
			events = { "wins" },
			tag = "WINS X2"
		}
	},
	{
		"lifekills",
		"kills",
		"Get %s kills in a life",
		10,
		25,
		nil,
		{ scope = "life" }
	},
	{
		"lifescore",
		"score",
		"Earn %s score in a life",
		2000,
		5000,
		nil,
		{ scope = "life" }
	},
	{
		"lifecaps",
		"captures",
		"Capture %s points in a life",
		3,
		6,
		nil,
		{ scope = "life" }
	},
	{
		"lifehead",
		"headshots",
		"Get %s headshots in a life",
		4,
		10,
		nil,
		{ scope = "life" }
	},
	{
		"roundkills",
		"kills",
		"Get %s kills in a round",
		25,
		60,
		nil,
		{ scope = "round" }
	},
	{
		"roundscore",
		"score",
		"Earn %s score in a round",
		5000,
		12000,
		nil,
		{ scope = "round" }
	},
	{
		"roundcaps",
		"captures",
		"Capture %s points in a round",
		5,
		12,
		nil,
		{ scope = "round" }
	},
	{
		"rounddamage",
		"damage",
		"Deal %s damage in a round",
		3000,
		8000,
		nil,
		{ scope = "round" }
	},
	{
		"domwins",
		"wins",
		"Win %s Domination rounds",
		3,
		10,
		nil,
		{
			only = { mode = "domination" }
		}
	},
	{
		"tdmwins",
		"wins",
		"Win %s Deathmatch rounds",
		3,
		10,
		nil,
		{
			only = { mode = "tdm" }
		}
	},
	{
		"siegewins",
		"wins",
		"Win %s Siege rounds",
		3,
		10,
		nil,
		{
			only = { mode = "siege" }
		}
	},
	{
		"tdmkills",
		"kills",
		"Get %s Deathmatch kills",
		75,
		380,
		nil,
		{
			only = { mode = "tdm" }
		}
	},
	{
		"siegekills",
		"kills",
		"Get %s Siege kills",
		75,
		380,
		nil,
		{
			only = { mode = "siege" }
		}
	},
	{
		"domscore",
		"score",
		"Earn %s Domination score",
		12000,
		60000,
		nil,
		{
			only = { mode = "domination" }
		}
	}
}

local function variety(p: number, p2: number, p3: number)
	local result = {}

	for k, v4 in v3 do
		result[k] = { v4[1], v4[2], v4[3], v4[p], p2, p3, v4[6], v4[7] }
	end

	return result
end

QuestData.DAILY = pool("d_", {
	{ "kills", "kills", "Get %s kills", 90, 500, 100 },
	{ "headshots", "headshots", "Get %s headshots", 25, 500, 100 },
	{ "assists", "assists", "Get %s assists", 30, 400, 80 },
	{ "captures", "captures", "Capture %s points", 12, 500, 100 },
	{ "neutralize", "neutralize", "Neutralize %s points", 12, 400, 80 },
	{ "rounds", "rounds", "Finish %s rounds", 6, 400, 80 },
	{ "wins", "wins", "Win %s rounds", 5, 600, 120 },
	{ "score", "score", "Earn %s score", 15000, 500, 100 },
	{ "vehicles", "vehicles", "Wreck %s vehicles", 6, 600, 120 },
	{ "turrets", "turrets", "Destroy %s turrets", 6, 500, 100 },
	{ "wreck", "wreck", "Wreck %s pieces of cover", 120, 400, 80 },
	{ "rifle", "kill_rifle", "Get %s rifle kills", 60, 500, 100, "AssaultRifle" },
	{ "smg", "kill_smg", "Get %s SMG kills", 50, 500, 100, "SMG" },
	{ "lmg", "kill_lmg", "Get %s LMG kills", 50, 500, 100, "LMG" },
	{ "dmr", "kill_dmr", "Get %s marksman kills", 40, 500, 100, "DMR" },
	{ "sniper", "kill_sniper", "Get %s sniper kills", 30, 500, 100, "Sniper" },
	{ "shotgun", "kill_shotgun", "Get %s shotgun kills", 30, 500, 100, "Shotgun" },
	{ "pistol", "kill_pistol", "Get %s pistol kills", 25, 500, 100, "Pistol" },
	{ "rocket", "kill_rocket", "Get %s rocket kills", 25, 500, 100, "RocketLauncher" },
	{ "vehicle", "kill_vehicle", "Get %s vehicle kills", 40, 500, 100 },
	{ "explosive", "kill_explosive", "Get %s grenade kills", 12, 500, 100, "Grenade" },
	{ "melee", "kill_melee", "Get %s melee kills", 10, 500, 100, "Hammer" },
	{ "streak", "kill_streak", "Get %s scorestreak kills", 25, 500, 100 }
})

for _, v4 in variety(4, 500, 100) do
	local v5 = v4[1] == "hip" and {
		"hipdamage",
		"damage",
		"Deal %s hip-fire damage",
		3000,
		500,
		100,
		nil,
		{
			only = { aimed = false, group = group2 }
		}
	} or v4

	table.insert(QuestData.DAILY, entry("d_", v5))
end

QuestData.WEEKLY = pool("w_", {
	{ "kills", "kills", "Get %s kills", 500, 2500, 400 },
	{ "headshots", "headshots", "Get %s headshots", 120, 2500, 400 },
	{ "assists", "assists", "Get %s assists", 150, 2000, 300 },
	{ "captures", "captures", "Capture %s points", 60, 2500, 400 },
	{ "neutralize", "neutralize", "Neutralize %s points", 60, 2000, 300 },
	{ "rounds", "rounds", "Finish %s rounds", 25, 2000, 300 },
	{ "wins", "wins", "Win %s rounds", 15, 3000, 500 },
	{ "score", "score", "Earn %s score", 80000, 2500, 400 },
	{ "vehicles", "vehicles", "Wreck %s vehicles", 30, 3000, 500 },
	{ "turrets", "turrets", "Destroy %s turrets", 30, 2500, 400 },
	{ "wreck", "wreck", "Wreck %s pieces of cover", 1000, 2000, 300 },
	{ "rifle", "kill_rifle", "Get %s rifle kills", 300, 2500, 400, "AssaultRifle" },
	{ "smg", "kill_smg", "Get %s SMG kills", 250, 2500, 400, "SMG" },
	{ "lmg", "kill_lmg", "Get %s LMG kills", 250, 2500, 400, "LMG" },
	{ "dmr", "kill_dmr", "Get %s marksman kills", 200, 2500, 400, "DMR" },
	{ "sniper", "kill_sniper", "Get %s sniper kills", 150, 2500, 400, "Sniper" },
	{ "shotgun", "kill_shotgun", "Get %s shotgun kills", 150, 2500, 400, "Shotgun" },
	{ "pistol", "kill_pistol", "Get %s pistol kills", 100, 2500, 400, "Pistol" },
	{ "rocket", "kill_rocket", "Get %s rocket kills", 100, 2500, 400, "RocketLauncher" },
	{ "vehicle", "kill_vehicle", "Get %s vehicle kills", 200, 2500, 400 },
	{ "explosive", "kill_explosive", "Get %s grenade kills", 50, 2500, 400, "Grenade" },
	{ "fire", "kill_fire", "Get %s fire kills", 40, 2500, 400, "Flamethrower" },
	{ "melee", "kill_melee", "Get %s melee kills", 40, 2500, 400, "Hammer" },
	{ "streak", "kill_streak", "Get %s scorestreak kills", 100, 2500, 400 }
})

for _, v4 in variety(5, 2500, 400) do
	table.insert(QuestData.WEEKLY, entry("w_", v4))
end

QuestData.BONUS = pool("b_", {
	{ "kills", "kills", "Get %s kills", 1000, 8000, 1500 },
	{ "score", "score", "Earn %s score", 200000, 8000, 1500 },
	{ "wins", "wins", "Win %s rounds", 30, 8000, 1500 },
	{ "captures", "captures", "Capture %s points", 150, 8000, 1500 },
	{ "damage", "damage", "Deal %s damage", 100000, 8000, 1500 }
})

for _, v4 in QuestData.BONUS do
	v4.needs = QuestData.BONUS_AT
	v4.swappable = false
	v4.cat = "bonus"
end

local function track(p: string, event: string, name: string, items, tool: string?)
	local v4 = {
		{ 5000, 1000 },
		{ 20000, 4000 },
		{ 60000, 12000 },
		{ 150000, 30000 }
	}
	local v5 = { nil, 10, 25, 50 }
	local tiers = {}

	for k, item in items do
		tiers[k] = { goal = item, xp = v4[k][1], scrap = v4[k][2], level = v5[k] }
	end

	return {
		id = "m_" .. p,
		event = event,
		name = name,
		tool = tool,
		tiers = tiers
	}
end

QuestData.MISSIONS = {
	track("kills", "kills", "Get %s kills", { 1000, 5000, 20000, 50000 }),
	track("headshots", "headshots", "Get %s headshots", { 250, 1000, 4000, 10000 }),
	track("assists", "assists", "Get %s assists", { 500, 2000, 8000, 20000 }),
	track("captures", "captures", "Capture %s points", { 200, 1000, 4000, 10000 }),
	track("neutralize", "neutralize", "Neutralize %s points", { 200, 1000, 4000, 10000 }),
	track("rounds", "rounds", "Finish %s rounds", { 100, 500, 2000, 5000 }),
	track("wins", "wins", "Win %s rounds", { 50, 250, 1000, 2500 }),
	track("score", "score", "Earn %s score", { 250000, 1000000, 5000000, 15000000 }),
	track("vehicles", "vehicles", "Wreck %s vehicles", { 100, 500, 2000, 5000 }),
	track("turrets", "turrets", "Destroy %s turrets", { 100, 500, 2000, 5000 }),
	track("wreck", "wreck", "Wreck %s pieces of cover", { 2000, 10000, 40000, 100000 }),
	track("rifle", "kill_rifle", "Get %s rifle kills", { 500, 2500, 10000, 25000 }, "AssaultRifle"),
	track("smg", "kill_smg", "Get %s SMG kills", { 500, 2500, 10000, 25000 }, "SMG"),
	track("lmg", "kill_lmg", "Get %s LMG kills", { 500, 2500, 10000, 25000 }, "LMG"),
	track("dmr", "kill_dmr", "Get %s marksman kills", { 500, 2500, 10000, 25000 }, "DMR"),
	track("sniper", "kill_sniper", "Get %s sniper kills", { 500, 2500, 10000, 25000 }, "Sniper"),
	track("shotgun", "kill_shotgun", "Get %s shotgun kills", { 250, 1000, 5000, 12000 }, "Shotgun"),
	track("pistol", "kill_pistol", "Get %s pistol kills", { 250, 1000, 5000, 12000 }, "Pistol"),
	track("rocket", "kill_rocket", "Get %s rocket kills", { 250, 1000, 5000, 12000 }, "RocketLauncher"),
	track("vehicle", "kill_vehicle", "Get %s vehicle kills", { 500, 2500, 10000, 25000 }),
	track("melee", "kill_melee", "Get %s melee kills", { 100, 500, 2000, 5000 }, "Hammer"),
	track("streak", "kill_streak", "Get %s scorestreak kills", { 250, 1000, 5000, 12000 })
}

function QuestData.attr(p: string)
	return "Quest_" .. p
end

function QuestData.dayOf(p: number)
	return p // 86400
end

function QuestData.weekOf(p: number)
	return (p + 259200) // 604800
end

function QuestData.passes(data, data2): boolean
	if data.mode and data.mode ~= data2.mode then
		return false
	end

	if data.group then
		local group = data2.group

		if type(data.group) == "string" then
			if group ~= data.group then
				return false
			end
		elseif not table.find(data.group, group) then
			return false
		end
	end

	if
		data.near and not (data2.metres and data2.metres <= data.near)
		or data.far and not (data2.metres and data2.metres >= data.far)
	then
		return false
	end

	if data.aimed ~= nil and data.aimed ~= (data2.aimed == true) then
		return false
	end

	return not (data.head and not data2.head) and not (data.point and not data2.point)
end

function QuestData.outList(value)
	if type(value) == "string" and value ~= "" then
		return (string.split(value, ","))
	end

	return {}
end

local function draw(list, p: number, p2: number, list2)
	local random = Random.new(p2)
	local v4 = {}

	for i = 1, #list do
		v4[i] = i
	end

	for i = #v4, 2, -1 do
		local integer = random:NextInteger(1, i)
		local v5 = v4[integer]
		local v6 = v4[i]
		v4[i] = v5
		v4[integer] = v6
	end

	local v5 = {}

	for _, v6 in v4 do
		if #v5 == p then
			break
		end

		if not (list2 and table.find(list2, list[v6].id)) then
			table.insert(v5, v6)
		end
	end

	table.sort(v5)
	local result = {}

	for k, v6 in v5 do
		result[k] = list[v6]
	end

	return result
end

function QuestData.daily(p: number, p2)
	return draw(QuestData.DAILY, QuestData.DAILY_COUNT, p * 2 + 1, p2)
end

function QuestData.weekly(p: number, p2)
	return draw(QuestData.WEEKLY, QuestData.WEEKLY_COUNT, p * 2, p2)
end

function QuestData.bonus(p: number)
	return QuestData.BONUS[p % #QuestData.BONUS + 1]
end

function QuestData.tier(data, p: number)
	local v4 = #data.tiers

	for k, tier in data.tiers do
		if p < tier.goal then
			v4 = k
			break
		end
	end

	local tier = data.tiers[v4]
	return {
		id = data.id,
		event = data.event,
		name = string.format(data.name, commas(tier.goal)),
		goal = tier.goal,
		xp = tier.xp,
		scrap = tier.scrap,
		tool = data.tool,
		level = tier.level
	}, v4
end

function QuestData.resetIn(p, p2: number)
	if p.resets == "day" then
		return 86400 - p2 % 86400
	end

	if p.resets == "week" then
		return 604800 - (p2 + 259200) % 604800
	end

	return nil
end

function QuestData.sections(instance)
	local serverTimeNow = workspace:GetServerTimeNow()
	local v4 = instance:GetAttribute("QuestDay")
	local v5 = instance:GetAttribute("QuestWeek")
	local v6 = QuestData.outList(instance:GetAttribute("QuestOutDaily"))
	local v7 = QuestData.outList(instance:GetAttribute("QuestOutWeekly"))

	if type(v5) ~= "number" then
		v5 = QuestData.weekOf(serverTimeNow // 1)
	end

	local clone = table.clone(QuestData.weekly(v5, v7))
	table.insert(clone, 1, QuestData.bonus(v5))

	local daily = QuestData.daily

	if type(v4) ~= "number" then
		v4 = QuestData.dayOf(serverTimeNow // 1)
	end

	local v8 = {
		{ id = "daily", title = "DAILY", resets = "day", quests = daily(v4, v6) },
		{ id = "weekly", title = "WEEKLY", resets = "week", quests = clone }
	}

	if not QuestData.MISSIONS_ON then
		return v8
	end

	local quests = {}

	for k, v9 in QuestData.MISSIONS do
		local attribute = instance:GetAttribute(QuestData.attr(v9.id))
		quests[k] = QuestData.tier(v9, type(attribute) ~= "number" and 0 or attribute)
	end

	table.insert(v8, { id = "missions", title = "MISSIONS", quests = quests })

	return v8
end

return QuestData