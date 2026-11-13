local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Airstrike = require(ReplicatedStorage.Game.Airstrike)

local ShopData = {}

local function percent(p: number)
	return string.format("+%d%%", (math.round((p - 1) * 100)))
end

local function rounds(p: number)
	return string.format("%d rds", p)
end

local function seconds(p: number) -- 1 equivalent call inferred from this helper
	return function(p2: number)
		return string.format("%.2f s", p * p2)
	end
end

local function ladder(p: number) -- 1 equivalent call inferred from this helper
	return { p, math.round(p * 2 / 10) * 10, math.round(p * 3.5 / 10) * 10 }
end

local function damageLadder(p: number)
	return ladder(math.round(p * 1.25 / 10) * 10) -- inferred equivalent call
end

local function damage(costs) -- 31 equivalent calls inferred from this helper
	return {
		id = "Damage",
		name = "DAMAGE",
		attr = "DamageScale",
		base = 1,
		step = 0.08,
		costs = costs,
		show = percent
	}
end

local function magazine(base: number, step: number, costs) -- 34 equivalent calls inferred from this helper
	return {
		id = "Magazine",
		name = "MAGAZINE",
		attr = "MagSize",
		base = base,
		step = step,
		costs = costs,
		show = rounds
	}
end

local function reload(p: number, costs) -- 35 equivalent calls inferred from this helper
	return {
		id = "Reload",
		name = "RELOAD",
		attr = "ReloadScale",
		base = 1,
		step = -0.1,
		costs = costs,
		show = seconds(p) -- inferred equivalent call
	}
end

ShopData.SHARED_LEVELS = 5
local v = reload(1.19, { 80, 160, 280 }) -- inferred equivalent call
local assaultRifle = {
	id = "AssaultRifle",
	price = 0,
	slot = "primary",
	tracks = { damage({ 100, 200, 350 }), magazine(30, 5, { 80, 160, 280 }), v } -- inferred equivalent call
}
local v2 = reload(1.19, { 90, 180, 320 }) -- inferred equivalent call

local items = {}
items.AssaultRifle = assaultRifle
items.K433 = {
	id = "K433",
	price = 100,
	level = 2,
	slot = "primary",
	tracks = { damage({ 110, 220, 390 }), magazine(30, 5, { 90, 180, 320 }), v2 } -- inferred equivalent call
}
local v3 = reload(1.13, { 100, 200, 350 }) -- inferred equivalent call
items.GX36 = {
	id = "GX36",
	price = 600,
	level = 7,
	slot = "primary",
	tracks = { damage({ 130, 260, 460 }), magazine(30, 5, { 100, 200, 350 }), v3 } -- inferred equivalent call
}
local v4 = reload(1.57, { 110, 220, 390 }) -- inferred equivalent call
items.SK556 = {
	id = "SK556",
	price = 850,
	level = 10,
	slot = "primary",
	tracks = { damage({ 140, 280, 490 }), magazine(30, 5, { 110, 220, 390 }), v4 } -- inferred equivalent call
}
local v5 = reload(1.84, { 100, 200, 350 }) -- inferred equivalent call
items.RN545 = {
	id = "RN545",
	price = 1000,
	level = 12,
	slot = "primary",
	tracks = { damage({ 130, 260, 460 }), magazine(30, 5, { 100, 200, 350 }), v5 } -- inferred equivalent call
}
local v6 = reload(1.94, { 100, 200, 350 }) -- inferred equivalent call
items.MX65 = {
	id = "MX65",
	price = 1200,
	level = 17,
	slot = "primary",
	tracks = { damage({ 130, 260, 460 }), magazine(20, 5, { 100, 200, 350 }), v6 } -- inferred equivalent call
}
local v7 = reload(2.16, { 100, 200, 350 }) -- inferred equivalent call
items.BT762 = {
	id = "BT762",
	price = 1400,
	level = 20,
	slot = "primary",
	tracks = { damage({ 130, 260, 460 }), magazine(20, 5, { 100, 200, 350 }), v7 } -- inferred equivalent call
}
local v8 = reload(1.01, { 90, 180, 320 }) -- inferred equivalent call
items.SMG = {
	id = "SMG",
	price = 0,
	slot = "primary",
	tracks = { damage({ 110, 220, 390 }), magazine(32, 4, { 90, 180, 320 }), v8 } -- inferred equivalent call
}
local v9 = reload(2.05, { 100, 200, 350 }) -- inferred equivalent call
items.KP50 = {
	id = "KP50",
	price = 450,
	level = 4,
	slot = "primary",
	tracks = { damage({ 130, 260, 460 }), magazine(50, 6, { 100, 200, 350 }), v9 } -- inferred equivalent call
}
local v10 = reload(1.62, { 100, 200, 350 }) -- inferred equivalent call
items.HM45 = {
	id = "HM45",
	price = 550,
	level = 6,
	slot = "primary",
	tracks = { damage({ 130, 260, 460 }), magazine(30, 4, { 100, 200, 350 }), v10 } -- inferred equivalent call
}
local v11 = reload(1.4, { 130, 260, 460 }) -- inferred equivalent call
items.PD46 = {
	id = "PD46",
	price = 1250,
	level = 18,
	slot = "primary",
	tracks = { damage({ 160, 320, 560 }), magazine(30, 4, { 130, 260, 460 }), v11 } -- inferred equivalent call
}
local v12 = reload(1.84, { 130, 260, 460 }) -- inferred equivalent call
items.SP44 = {
	id = "SP44",
	price = 1300,
	level = 19,
	slot = "primary",
	tracks = { damage({ 160, 320, 560 }), magazine(44, 6, { 130, 260, 460 }), v12 } -- inferred equivalent call
}
local v13 = reload(1.51, { 140, 280, 490 }) -- inferred equivalent call
items.TK17 = {
	id = "TK17",
	price = 1425,
	level = 21,
	slot = "primary",
	tracks = { damage({ 180, 360, 630 }), magazine(17, 3, { 140, 280, 490 }), v13 } -- inferred equivalent call
}
local v14 = reload(0.7, { 100, 200, 350 }) -- inferred equivalent call
items.Shotgun = {
	id = "Shotgun",
	price = 0,
	slot = "primary",
	tracks = { damage({ 130, 260, 460 }), magazine(8, 1, { 100, 200, 350 }), v14 } -- inferred equivalent call
}
local v15 = reload(1.6, { 120, 240, 420 }) -- inferred equivalent call
items.DMR = {
	id = "DMR",
	price = 0,
	slot = "primary",
	tracks = { damage({ 150, 300, 530 }), magazine(20, 2, { 120, 240, 420 }), v15 } -- inferred equivalent call
}
local v16 = reload(1.83, { 140, 280, 490 }) -- inferred equivalent call
items.GV12 = {
	id = "GV12",
	price = 1050,
	level = 14,
	slot = "primary",
	tracks = { damage({ 180, 360, 630 }), magazine(10, 1, { 140, 280, 490 }), v16 } -- inferred equivalent call
}
local v17 = reload(1.48, { 110, 220, 390 }) -- inferred equivalent call
items.FS16 = {
	id = "FS16",
	price = 650,
	level = 9,
	slot = "primary",
	tracks = { damage({ 140, 280, 490 }), magazine(15, 2, { 110, 220, 390 }), v17 } -- inferred equivalent call
}
local v18 = reload(1.6, { 150, 300, 530 }) -- inferred equivalent call
items.QS9 = {
	id = "QS9",
	price = 1475,
	level = 23,
	slot = "primary",
	tracks = { damage({ 190, 380, 670 }), magazine(20, 2, { 150, 300, 530 }), v18 } -- inferred equivalent call
}
local v19 = reload(1.62, { 160, 320, 560 }) -- inferred equivalent call
items.KR54 = {
	id = "KR54",
	price = 1525,
	level = 24,
	slot = "primary",
	tracks = { damage({ 200, 400, 700 }), magazine(10, 1, { 160, 320, 560 }), v19 } -- inferred equivalent call
}
local v20 = reload(2.01, { 140, 280, 490 }) -- inferred equivalent call
items.LMG = {
	id = "LMG",
	price = 0,
	slot = "primary",
	tracks = { damage({ 180, 360, 630 }), magazine(100, 20, { 140, 280, 490 }), v20 } -- inferred equivalent call
}
local v21 = reload(2.16, { 140, 280, 490 }) -- inferred equivalent call
items.BX110 = {
	id = "BX110",
	price = 950,
	level = 11,
	slot = "primary",
	tracks = { damage({ 180, 360, 630 }), magazine(100, 20, { 140, 280, 490 }), v21 } -- inferred equivalent call
}
local v22 = reload(2.27, { 140, 280, 490 }) -- inferred equivalent call
items.HX83 = {
	id = "HX83",
	price = 1000,
	level = 13,
	slot = "primary",
	tracks = { damage({ 180, 360, 630 }), magazine(100, 20, { 140, 280, 490 }), v22 } -- inferred equivalent call
}
local v23 = reload(2.48, { 150, 300, 530 }) -- inferred equivalent call
items.MG60 = {
	id = "MG60",
	price = 1150,
	level = 16,
	slot = "primary",
	tracks = { damage({ 190, 380, 670 }), magazine(100, 20, { 150, 300, 530 }), v23 } -- inferred equivalent call
}
local v24 = reload(1.84, { 170, 340, 600 }) -- inferred equivalent call
items.KT8 = {
	id = "KT8",
	price = 1650,
	level = 26,
	slot = "primary",
	tracks = { damage({ 210, 420, 740 }), magazine(60, 10, { 170, 340, 600 }), v24 } -- inferred equivalent call
}
local v25 = reload(2.21, { 170, 340, 600 }) -- inferred equivalent call
items.NX68 = {
	id = "NX68",
	price = 1700,
	level = 27,
	slot = "primary",
	tracks = { damage({ 210, 420, 740 }), magazine(50, 10, { 170, 340, 600 }), v25 } -- inferred equivalent call
}
local v26 = reload(2.59, { 180, 360, 630 }) -- inferred equivalent call
items.GR240 = {
	id = "GR240",
	price = 1750,
	level = 28,
	slot = "primary",
	tracks = { damage({ 230, 460, 810 }), magazine(50, 10, { 180, 360, 630 }), v26 } -- inferred equivalent call
}
local v27 = reload(1.6, { 160, 320, 560 }) -- inferred equivalent call
items.Sniper = {
	id = "Sniper",
	price = 0,
	slot = "primary",
	tracks = { magazine(10, 1, { 160, 320, 560 }), v27 } -- inferred equivalent call
}
local v28 = reload(1.46, { 170, 340, 600 }) -- inferred equivalent call
items.RX10 = {
	id = "RX10",
	price = 1450,
	level = 22,
	slot = "primary",
	tracks = { magazine(5, 1, { 170, 340, 600 }), v28 } -- inferred equivalent call
}
local v29 = reload(1.24, { 150, 300, 530 }) -- inferred equivalent call
items.SC11 = {
	id = "SC11",
	price = 1100,
	level = 15,
	slot = "primary",
	tracks = { magazine(10, 1, { 150, 300, 530 }), v29 } -- inferred equivalent call
}
local v30 = reload(2.72, { 180, 360, 630 }) -- inferred equivalent call
items.VX50 = {
	id = "VX50",
	price = 1600,
	level = 25,
	slot = "primary",
	tracks = { magazine(5, 1, { 180, 360, 630 }), v30 } -- inferred equivalent call
}
local v31 = reload(1.29, { 60, 120, 210 }) -- inferred equivalent call
items.Pistol = {
	id = "Pistol",
	price = 0,
	slot = "secondary",
	tracks = { damage({ 80, 160, 280 }), magazine(17, 3, { 60, 120, 210 }), v31 } -- inferred equivalent call
}
local v32 = reload(1.67, { 80, 160, 280 }) -- inferred equivalent call
items.HandCannon = {
	id = "HandCannon",
	price = 350,
	level = 2,
	slot = "secondary",
	tracks = { damage({ 100, 200, 350 }), magazine(7, 1, { 80, 160, 280 }), v32 } -- inferred equivalent call
}
local v67 = reload(1.34, { 70, 140, 250 }) -- inferred equivalent call
items.SV20 = {
	id = "SV20",
	price = 450,
	level = 4,
	slot = "secondary",
	tracks = { damage({ 90, 180, 320 }), magazine(20, 3, { 70, 140, 250 }), v67 } -- inferred equivalent call
}
local v69 = reload(1.5, { 90, 180, 320 }) -- inferred equivalent call
items.ZK10 = {
	id = "ZK10",
	price = 600,
	level = 8,
	slot = "secondary",
	tracks = { damage({ 110, 220, 390 }), magazine(20, 4, { 90, 180, 320 }), v69 } -- inferred equivalent call
}
local v71 = reload(1.3, { 120, 240, 420 }) -- inferred equivalent call
items.RocketLauncher = {
	id = "RocketLauncher",
	price = 0,
	slot = "utility",
	tracks = { damage({ 150, 300, 530 }), v71 } -- inferred equivalent call
}

items.Hammer = { id = "Hammer", price = 0, slot = "melee", tracks = {} }
items.Shovel = { id = "Shovel", price = 0, slot = "melee", tracks = {} }
items.Grenade = { id = "Grenade", price = 0, slot = "throwable", tracks = {} }
items.PipeBomb = {
	id = "PipeBomb",
	price = 250,
	slot = "throwable",
	tracks = {},
	retired = "Smoke"
}
items.Smoke = {
	id = "Smoke",
	price = 250,
	level = 2,
	slot = "throwable",
	tracks = {}
}
items.Molotov = {
	id = "Molotov",
	price = 300,
	level = 2,
	slot = "throwable",
	tracks = {}
}
items.Claymore = {
	id = "Claymore",
	price = 350,
	level = 3,
	slot = "throwable",
	tracks = {}
}
items.C4 = {
	id = "C4",
	price = 450,
	level = 5,
	slot = "throwable",
	tracks = {}
}
items.BuildHammer = { id = "BuildHammer", price = 0, slot = "utility", tracks = {} }
items.Flamethrower = {
	id = "Flamethrower",
	price = 500,
	level = 4,
	slot = "utility",
	tracks = {}
}
items.AALauncher = { id = "AALauncher", price = 0, slot = "utility", tracks = {} }

items.Airstrike = {
	id = "Airstrike",
	price = 0,
	slot = "streak",
	tracks = {},
	kills = Airstrike.KILLS
}
items.Minigun = {
	id = "Minigun",
	price = 900,
	slot = "streak",
	tracks = {},
	kills = 5
}
items.Hellfire = {
	id = "Hellfire",
	price = 1500,
	slot = "streak",
	tracks = {},
	kills = 5
}
items.Gunship = {
	id = "Gunship",
	price = 2500,
	slot = "streak",
	tracks = {},
	kills = 9
}
ShopData.ITEMS = items

ShopData.SLOTS = { "primary", "secondary", "utility", "melee", "throwable", "streak" }
ShopData.PICKS = {
	primary = { attr = "Primary", default = "AssaultRifle", label = "primary" },
	secondary = { attr = "SecondaryPick", default = "Pistol", label = "secondary" },
	utility = { attr = "UtilityPick", default = "RocketLauncher", label = "utility" },
	melee = { attr = "MeleePick", default = "Hammer", label = "melee" },
	throwable = { attr = "ThrowablePick", default = "Grenade", label = "throwable" }
}

ShopData.DEFAULT_PRIMARY = ShopData.PICKS.primary.default
ShopData.PRIMARY_ATTR = ShopData.PICKS.primary.attr
ShopData.DEFAULT_THROWABLE = ShopData.PICKS.throwable.default
ShopData.THROWABLE_ATTR = ShopData.PICKS.throwable.attr
ShopData.DEFAULT_STREAK = "Airstrike"
ShopData.STREAK_ATTR = "StreakPick"

for k, v72 in ShopData.ITEMS do
	assert(table.find(ShopData.SLOTS, v72.slot), "[Shop] " .. k .. " has no loadout slot")
	assert(
		(v72.slot == "streak") == (type(v72.kills) == "number"),
		"[Shop] " .. k .. ": streaks (and only streaks) need kills"
	)

	local v73 = v72.price > 0 and v72.slot ~= "streak" and not v72.retired
	assert(v73 == (v72.level ~= nil), "[Shop] " .. k .. ": a bought weapon (and only one) needs a level")
end

local v72 = {}

for k, v73 in ShopData.ITEMS do
	local level = v73.level

	if not (level and ShopData.SHARED_LEVELS < level and (v73.slot == "primary" or v73.slot == "secondary")) then
		continue
	end

	assert(not v72[level], "[Shop] " .. k .. " and " .. tostring(v72[level]) .. " both unlock at level " .. level)
	v72[level] = k
end

local v73 = ShopData.ITEMS[ShopData.DEFAULT_STREAK].slot == "streak"
	and ShopData.ITEMS[ShopData.DEFAULT_STREAK].price == 0
assert(v73, "[Shop] the default streak must be a free streak")

local v74 = {}

for k, v75 in ShopData.ITEMS do
	local retired = v75.retired

	if not retired then
		continue
	end

	local v76 = ShopData.ITEMS[retired]

	if v76 then
		if v76.slot == v75.slot then
			v76 = not v76.retired
		else
			v76 = false
		end
	end

	assert(v76, "[Shop] " .. k .. " is retired for an item it can't become")
	v74[retired] = v74[retired] or {}
	table.insert(v74[retired], k)
end

for k, v75 in ShopData.PICKS do
	local v76 = ShopData.ITEMS[v75.default]

	if v76 then
		if v76.slot == k then
			v76 = v76.price == 0
		else
			v76 = false
		end
	end

	assert(v76, "[Shop] the default " .. k .. " must be a free " .. k)
end

function ShopData.item(p: string)
	local v75 = ShopData.ITEMS[p]
	assert(v75, "[Shop] unknown item " .. tostring(p))
	return v75
end

function ShopData.track(p, p2: string)
	for _, track in p.tracks do
		if track.id == p2 then
			return track
		end
	end

	error("[Shop] " .. p.id .. " has no upgrade " .. tostring(p2))
end

function ShopData.value(p, p2: number)
	return p.base + p.step * p2
end

function ShopData.maxLevel(p)
	return #p.costs
end

function ShopData.ownsAttr(p: string)
	return "Owns_" .. p
end

function ShopData.levelAttr(p: string, p2: string)
	return "Up_" .. p .. "_" .. p2
end

function ShopData.owns(instance, p: string): boolean
	local item = ShopData.item(p)

	if item.retired then
		return false
	end

	if item.price == 0 or instance:GetAttribute(ShopData.ownsAttr(p)) == true then
		return true
	end

	for _, v75 in v74[p] or {} do
		if instance:GetAttribute(ShopData.ownsAttr(v75)) == true then
			return true
		end
	end

	return false
end

function ShopData.pick(instance, p: string)
	local v75 = ShopData.PICKS[p]
	assert(v75, "[Shop] " .. tostring(p) .. " is not a one-of slot")
	local v76 = instance:GetAttribute(v75.attr)

	if type(v76) ~= "string" then
		return v75.default
	end

	local v77 = ShopData.ITEMS[v76]

	if v77 and v77.retired then
		v76 = v77.retired
		v77 = ShopData.ITEMS[v76]
	end

	if v77 and v77.slot == p and ShopData.owns(instance, v76) then
		return v76
	end

	return v75.default
end

function ShopData.primary(p)
	return ShopData.pick(p, "primary")
end

function ShopData.throwable(p)
	return ShopData.pick(p, "throwable")
end

function ShopData.streak(instance)
	local attribute = instance:GetAttribute(ShopData.STREAK_ATTR)

	if type(attribute) == "string" then
		local v75 = ShopData.ITEMS[attribute]

		if v75 and v75.slot == "streak" and ShopData.owns(instance, attribute) then
			return attribute
		end
	end

	return ShopData.DEFAULT_STREAK
end

function ShopData.carries(p, p2: string): boolean
	if not ShopData.owns(p, p2) then
		return false
	end

	local slot = ShopData.item(p2).slot
	return not ShopData.PICKS[slot] or ShopData.pick(p, slot) == p2
end

function ShopData.slotRank(p: string)
	local v75 = ShopData.ITEMS[p]

	if v75 then
		return (table.find(ShopData.SLOTS, v75.slot))
	end

	return #ShopData.SLOTS + 1
end

function ShopData.unlockLevel(p: string)
	return ShopData.item(p).level or 1
end

function ShopData.unlocked(instance, p: string)
	local level = instance:GetAttribute("Level")
	return (type(level) ~= "number" and 1 or level) >= ShopData.unlockLevel(p)
		or (instance:GetAttribute("UnlockAll") == true or ShopData.owns(instance, p))
end

function ShopData.upgradeSpend(value: string, p: number)
	local v75, v76 = string.match(value, "^(.-)/(.+)$")
	local v77 = v75 and ShopData.ITEMS[v75]
	local total = 0

	for _, v78 in not v77 and {} or v77.tracks do
		if v78.id ~= v76 then
			continue
		end

		for i = 1, math.min(p, #v78.costs) do
			total += v78.costs[i]
		end
	end

	return total
end

function ShopData.level(_, _: string, _: string): number
	return 0
end

return ShopData