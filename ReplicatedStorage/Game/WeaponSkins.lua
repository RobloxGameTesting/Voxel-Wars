local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Mastery = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("Mastery"))

local WeaponSkins = {}
WeaponSkins.SLOT = "Skin"
WeaponSkins.DEFAULT = "FACTORY"
WeaponSkins.VIEW = "View"

local function rgb(p: number, p2: number, p3: number) -- 33 equivalent calls inferred from this helper
	return Color3.fromRGB(p, p2, p3)
end

WeaponSkins.LIST = {
	{ id = "FACTORY", name = "FACTORY", level = 1, about = "The gun as it comes from the factory." },
	{
		id = "CRIMSON",
		name = "CRIMSON",
		level = 2,
		tag = "FINISH",
		about = "Deep red candy paint with a fine flake.",
		variant = "WeaponSkinCrimson",
		plastic = rgb(22, 20, 20), -- inferred equivalent call
		image = "rbxassetid://125954485239925"
	},
	{
		id = "CARBON",
		name = "CARBON",
		level = 3,
		tag = "FINISH",
		about = "Black chopped carbon fibre.",
		variant = "WeaponSkinCarbon",
		plastic = rgb(58, 60, 64), -- inferred equivalent call
		image = "rbxassetid://77711026771211"
	},
	{
		id = "OLIVE",
		name = "OLIVE DRAB",
		level = 4,
		tag = "PAINT",
		about = "Olive green paint with tan grips.",
		metal = rgb(96, 106, 66), -- inferred equivalent call
		plastic = rgb(156, 131, 92) -- inferred equivalent call
	},
	{
		id = "TEMPERED",
		name = "TEMPERED",
		level = 5,
		tag = "FINISH",
		about = "Steel heat-tinted straw, bronze and blue.",
		variant = "WeaponSkinTempered",
		material = Enum.Material.Metal,
		plastic = rgb(26, 26, 28), -- inferred equivalent call
		image = "rbxassetid://72077972275046"
	},
	{
		id = "MALACHITE",
		name = "MALACHITE",
		level = 6,
		tag = "STONE",
		about = "Banded green stone.",
		variant = "WeaponSkinMalachite",
		plastic = rgb(28, 31, 28), -- inferred equivalent call
		image = "rbxassetid://114535080925745"
	},
	{
		id = "PEARL",
		name = "PEARL",
		level = 7,
		tag = "FINISH",
		about = "White mother of pearl with a rainbow sheen.",
		variant = "WeaponSkinPearl",
		plastic = rgb(32, 30, 30), -- inferred equivalent call
		image = "rbxassetid://129749957367385"
	},
	{
		id = "WOODLAND",
		name = "WOODLAND",
		level = 8,
		tag = "CAMO",
		about = "Green pixel camo for fields and forest.",
		variant = "WeaponSkinWoodland",
		plastic = rgb(58, 64, 48), -- inferred equivalent call
		image = "rbxassetid://134255162023418"
	},
	{
		id = "OIL_SLICK",
		name = "OIL SLICK",
		level = 9,
		tag = "FINISH",
		about = "Black metal under a rainbow oil film.",
		variant = "WeaponSkinOilSlick",
		plastic = rgb(20, 20, 22), -- inferred equivalent call
		image = "rbxassetid://133686238673697"
	},
	{
		id = "SERPENT",
		name = "SERPENT",
		level = 11,
		was = 10,
		tag = "HIDE",
		about = "Green viper scales with black saddles.",
		variant = "WeaponSkinSerpent",
		plastic = rgb(20, 22, 20), -- inferred equivalent call
		image = "rbxassetid://133893913338074"
	},
	{
		id = "GEODE",
		name = "GEODE",
		level = 12,
		was = 11,
		tag = "STONE",
		about = "A bed of violet amethyst crystals.",
		variant = "WeaponSkinGeode",
		plastic = rgb(36, 30, 42), -- inferred equivalent call
		image = "rbxassetid://114177005366008"
	},
	{
		id = "DESERT",
		name = "DESERT",
		level = 14,
		was = 12,
		tag = "CAMO",
		about = "Sand pixel camo for dry ground.",
		variant = "WeaponSkinDesert",
		plastic = rgb(110, 86, 64), -- inferred equivalent call
		image = "rbxassetid://109021307128196"
	},
	{
		id = "STORMGLASS",
		name = "STORMGLASS",
		level = 15,
		tag = "GLASS",
		about = "Black glass with lightning caught inside.",
		variant = "WeaponSkinStormglass",
		plastic = rgb(18, 20, 24), -- inferred equivalent call
		image = "rbxassetid://81735027653667"
	},
	{
		id = "TIGER",
		name = "ARCTIC TIGER",
		level = 17,
		was = 16,
		tag = "CAMO",
		about = "Grey and black tiger stripes.",
		variant = "WeaponSkinTiger",
		plastic = rgb(60, 67, 76), -- inferred equivalent call
		image = "rbxassetid://71350142224938"
	},
	{
		id = "DEEP_FIELD",
		name = "DEEP FIELD",
		level = 18,
		was = 17,
		tag = "COSMIC",
		about = "Deep space: nebula clouds and stars.",
		variant = "WeaponSkinDeepField",
		plastic = rgb(14, 14, 18), -- inferred equivalent call
		image = "rbxassetid://124996792853461"
	},
	{
		id = "MOLTEN",
		name = "MOLTEN",
		level = 20,
		was = 18,
		tag = "MASTERY",
		about = "Black rock split by glowing cracks.",
		variant = "WeaponSkinMolten",
		plastic = rgb(28, 26, 25), -- inferred equivalent call
		image = "rbxassetid://94265884715873"
	},
	{
		id = "GOLD",
		name = "GOLD",
		level = 20,
		was = 18,
		challenge = true,
		tag = "CHALLENGE",
		about = "Solid gold. Earn every other camo on this gun, then beat its challenge.",
		metal = rgb(232, 186, 72), -- inferred equivalent call
		material = Enum.Material.Metal,
		variant = "WeaponSkinGold",
		whole = true,
		image = "rbxassetid://139171073043739"
	},
	{
		id = "DIAMOND",
		name = "DIAMOND",
		level = 20,
		challenge = true,
		class = true,
		tag = "CLASS",
		about = "Cut diamond. Earn GOLD on every gun of this class.",
		variant = "WeaponSkinDiamond",
		whole = true,
		image = "rbxassetid://112311846032421"
	},
	{
		id = "ARCTIC",
		name = "ARCTIC",
		level = 99,
		crate = "rare",
		tag = "CRATE",
		about = "Cracked glacier ice.",
		variant = "WeaponSkinArctic",
		plastic = rgb(46, 54, 64), -- inferred equivalent call
		image = "rbxassetid://95474521859238"
	},
	{
		id = "CANDY",
		name = "CANDY",
		level = 99,
		crate = "rare",
		tag = "CRATE",
		about = "A swirl of hard candy.",
		variant = "WeaponSkinCandy",
		plastic = rgb(20, 18, 22), -- inferred equivalent call
		image = "rbxassetid://122164506149622"
	},
	{
		id = "TERRAZZO",
		name = "TERRAZZO",
		level = 99,
		crate = "rare",
		tag = "CRATE",
		about = "Polished stone packed with chips.",
		variant = "WeaponSkinTerrazzo",
		plastic = rgb(42, 43, 47), -- inferred equivalent call
		image = "rbxassetid://135155359974077"
	},
	{
		id = "PATINA",
		name = "PATINA",
		level = 99,
		crate = "rare",
		tag = "CRATE",
		about = "Bright copper under green patina.",
		variant = "WeaponSkinPatina",
		material = Enum.Material.Metal,
		plastic = rgb(59, 42, 30), -- inferred equivalent call
		image = "rbxassetid://135126946491233"
	},
	{
		id = "COBALT",
		name = "COBALT",
		level = 99,
		crate = "rare",
		tag = "CRATE",
		about = "Hammered electric-blue metal.",
		variant = "WeaponSkinCobalt",
		material = Enum.Material.Metal,
		plastic = rgb(58, 63, 71), -- inferred equivalent call
		image = "rbxassetid://110843786267588"
	},
	{
		id = "CIRCUIT",
		name = "CIRCUIT",
		level = 99,
		crate = "epic",
		tag = "CRATE",
		about = "A circuit board with glowing traces.",
		variant = "WeaponSkinCircuit",
		plastic = rgb(14, 15, 16), -- inferred equivalent call
		image = "rbxassetid://99362975950550"
	},
	{
		id = "TOXIC",
		name = "TOXIC",
		level = 99,
		crate = "epic",
		tag = "CRATE",
		about = "Glowing radioactive slime.",
		variant = "WeaponSkinToxic",
		plastic = rgb(21, 24, 13), -- inferred equivalent call
		image = "rbxassetid://131093629606730"
	},
	{
		id = "PLASMA",
		name = "PLASMA",
		level = 99,
		crate = "epic",
		tag = "CRATE",
		about = "Swirling plasma under dark glass.",
		variant = "WeaponSkinPlasma",
		plastic = rgb(18, 12, 26), -- inferred equivalent call
		image = "rbxassetid://101109994035130"
	},
	{
		id = "HEXGRID",
		name = "HEXGRID",
		level = 99,
		crate = "epic",
		tag = "CRATE",
		about = "Armour plates with glowing seams.",
		variant = "WeaponSkinHexgrid",
		material = Enum.Material.Metal,
		plastic = rgb(32, 35, 40), -- inferred equivalent call
		image = "rbxassetid://122164039471450"
	},
	{
		id = "FROSTBITE",
		name = "FROSTBITE",
		level = 99,
		crate = "legendary",
		tag = "CRATE",
		about = "Glowing glacial crystal.",
		variant = "WeaponSkinFrostbite",
		plastic = rgb(14, 26, 46), -- inferred equivalent call
		image = "rbxassetid://117566075180030"
	},
	{
		id = "HOLO",
		name = "HOLO",
		level = 99,
		crate = "legendary",
		tag = "CRATE",
		about = "Holographic foil that shifts colour.",
		variant = "WeaponSkinHolo",
		material = Enum.Material.Metal,
		plastic = rgb(22, 24, 29), -- inferred equivalent call
		image = "rbxassetid://93561931870017"
	},
	{
		id = "DRAGONSCALE",
		name = "DRAGONSCALE",
		level = 99,
		crate = "mythic",
		tag = "CRATE",
		about = "Fire dragon hide with ember light.",
		variant = "WeaponSkinDragonscale",
		material = Enum.Material.Metal,
		whole = true,
		image = "rbxassetid://83015519303974"
	},
	{
		id = "AFTERBURN",
		name = "AFTERBURN",
		level = 99,
		bundle = "SkyRaider",
		tag = "BUNDLE",
		about = "Jet panels with glowing exhaust seams.",
		variant = "WeaponSkinAfterburn",
		plastic = rgb(20, 22, 28), -- inferred equivalent call
		image = "rbxassetid://80997499195537"
	},
	{
		id = "FANG",
		name = "FANG",
		level = 99,
		bundle = "Venom",
		tag = "BUNDLE",
		about = "Black scales under a glowing green net.",
		variant = "WeaponSkinFang",
		plastic = rgb(12, 16, 12), -- inferred equivalent call
		image = "rbxassetid://92818366169559"
	},
	{
		id = "CINDER",
		name = "CINDER",
		level = 99,
		bundle = "Inferno",
		tag = "BUNDLE",
		about = "Black rock split by glowing magma.",
		variant = "WeaponSkinCinder",
		plastic = rgb(22, 12, 10), -- inferred equivalent call
		image = "rbxassetid://129071892319490"
	},
	{
		id = "PHANTOM",
		name = "PHANTOM",
		level = 99,
		bundle = "Revenant",
		tag = "BUNDLE",
		about = "Bone plates over a violet glow.",
		variant = "WeaponSkinPhantom",
		plastic = rgb(22, 19, 28), -- inferred equivalent call
		image = "rbxassetid://90913835991336"
	},
	{
		id = "SALVAGE",
		name = "SALVAGE",
		level = 99,
		streak = true,
		tag = "STREAK",
		about = "Scrap plates welded together.",
		variant = "WeaponSkinSalvage",
		plastic = rgb(24, 24, 26), -- inferred equivalent call
		image = "rbxassetid://102248172570470"
	}
}

WeaponSkins.CRATE_RARITY = {
	{ id = "rare", name = "RARE", color = Color3.fromRGB(40, 200, 255), share = 0.6 },
	{ id = "epic", name = "EPIC", color = Color3.fromRGB(170, 90, 255), share = 0.28 },
	{ id = "legendary", name = "LEGENDARY", color = Color3.fromRGB(255, 190, 30), share = 0.1 },
	{ id = "mythic", name = "MYTHIC", color = Color3.fromRGB(255, 50, 50), share = 0.02 }
}

WeaponSkins.CRATE_PREFIX = "skin:"

WeaponSkins.CRATE = {}

for _, v in WeaponSkins.LIST do
	if v.crate then
		table.insert(WeaponSkins.CRATE, v)
	end
end

WeaponSkins.BUNDLE = {}

for _, v in WeaponSkins.LIST do
	if not v.bundle then
		continue
	end

	assert(not (v.crate or v.challenge), "WeaponSkins: bundle skin " .. v.id .. " is also a crate or challenge skin")
	table.insert(WeaponSkins.BUNDLE, v)
end

WeaponSkins.BUNDLE_RARITY = {
	id = "premium",
	name = "PREMIUM",
	color = Color3.fromRGB(70, 225, 100)
}
WeaponSkins.BUNDLE_NEED = "COMES WITH AN OUTFIT BUNDLE"

function WeaponSkins.bundleFor(p: string)
	for _, v in WeaponSkins.BUNDLE do
		if v.bundle == p then
			return v
		end
	end

	return nil
end

WeaponSkins.STREAK = {}

for _, v in WeaponSkins.LIST do
	if not v.streak then
		continue
	end

	assert(
		not (v.crate or v.bundle or v.challenge),
		"WeaponSkins: streak skin " .. v.id .. " is also a crate, bundle or challenge skin"
	)
	table.insert(WeaponSkins.STREAK, v)
end

WeaponSkins.STREAK_COLOR = Color3.fromRGB(255, 200, 60)
WeaponSkins.STREAK_NEED = "DAY 7 OF THE DAILY SUPPLY"

function WeaponSkins.rarity(p: string)
	for _, v in WeaponSkins.CRATE_RARITY do
		if v.id == p then
			return v
		end
	end

	error("WeaponSkins: no crate rarity " .. tostring(p))
end

WeaponSkins.CRATE_CLASSES = { "rifle", "smg", "lmg", "sniper", "dmr", "shotgun", "pistol" }

function WeaponSkins.crateAttr(p: string, p2: string?)
	if p2 then
		return "Cs_" .. p .. "_" .. p2
	end

	return "Cs_" .. p
end

function WeaponSkins.ownsCrate(instance, p: string, p2: string?): boolean
	if instance:GetAttribute(WeaponSkins.crateAttr(p)) == true then
		return true
	end

	return p2 ~= nil and instance:GetAttribute(WeaponSkins.crateAttr(p, p2)) == true
end

function WeaponSkins.crateCount(p, p2: string)
	assert(table.find(WeaponSkins.CRATE_CLASSES, p2), "WeaponSkins: no crate for class " .. tostring(p2))
	local count = 0

	for _, v in WeaponSkins.CRATE do
		if WeaponSkins.ownsCrate(p, v.id, p2) then
			count += 1
		end
	end

	return count, #WeaponSkins.CRATE
end

function WeaponSkins.crateAll(p): boolean
	for _, CRATE_CLASS in WeaponSkins.CRATE_CLASSES do
		local crateCount, v = WeaponSkins.crateCount(p, CRATE_CLASS)

		if crateCount < v then
			return false
		end
	end

	return true
end

local v = {}

for _, v2 in WeaponSkins.LIST do
	assert(not v[v2.id], "WeaponSkins: two skins " .. v2.id)
	v[v2.id] = v2
end

WeaponSkins.SLOT_INFO = {
	id = WeaponSkins.SLOT,
	label = "CAMO",
	default = WeaponSkins.DEFAULT,
	options = WeaponSkins.LIST
}

function WeaponSkins.find(p: string?)
	if p then
		return v[p]
	end

	return nil
end

function WeaponSkins.has(p: string)
	return Mastery.isGun(p)
end

function WeaponSkins.attr(p: string)
	return "Gs_" .. p .. "_" .. WeaponSkins.SLOT
end

WeaponSkins.CHALLENGES = {
	rifle = { kind = "head", goal = 200, name = "HEADSHOT KILLS" },
	pistol = { kind = "head", goal = 150, name = "HEADSHOT KILLS" },
	smg = { kind = "multi", goal = 60, name = "DOUBLE KILLS" },
	lmg = { kind = "multi", goal = 75, name = "DOUBLE KILLS" },
	shotgun = { kind = "multi", goal = 50, name = "DOUBLE KILLS" },
	dmr = { kind = "long", goal = 100, name = "LONG SHOTS" },
	sniper = { kind = "long", goal = 75, name = "LONG SHOTS" }
}

local gold = v.GOLD

WeaponSkins.CLASS_NAMES = {
	rifle = "RIFLE",
	smg = "SMG",
	lmg = "LMG",
	dmr = "DMR",
	sniper = "SNIPER",
	pistol = "PISTOL",
	shotgun = "SHOTGUN"
}

for _, CRATE_CLASS in WeaponSkins.CRATE_CLASSES do
	assert(WeaponSkins.CLASS_NAMES[CRATE_CLASS], "WeaponSkins: crate class " .. CRATE_CLASS .. " has no name")
end

function WeaponSkins.classOf(p: string)
	local QuestData = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("QuestData"))
	return QuestData.GROUP[p]
end

local v2 = {}

function WeaponSkins.classGuns(p: string)
	local QuestData = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("QuestData"))
	local v3 = QuestData.GROUP[p]
	assert(v3, "WeaponSkins: no class for " .. p)
	local result = v2[v3]

	if result then
		return result
	end

	result = {}

	for k, v4 in QuestData.GROUP do
		if v4 == v3 and Mastery.isGun(k) then
			table.insert(result, k)
		end
	end

	table.sort(result)
	v2[v3] = result

	return result
end

function WeaponSkins.className(p: string)
	local QuestData = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("QuestData"))
	local v3 = WeaponSkins.CLASS_NAMES[QuestData.GROUP[p]]
	assert(v3, "WeaponSkins: no class name for " .. p)
	return v3
end

function WeaponSkins.challenge(p: string)
	local QuestData = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("QuestData"))
	local v3 = QuestData.GROUP[p]
	local selected = v3 and WeaponSkins.CHALLENGES[v3]
	assert(selected, "WeaponSkins: no gold challenge for " .. p .. " (class " .. tostring(v3) .. ")")
	return selected
end

function WeaponSkins.goldStat(p: string)
	return "Gold_" .. p
end

function WeaponSkins.goldCount(instance, p: string)
	local attribute = instance:GetAttribute(WeaponSkins.goldStat(p))
	return if type(attribute) == "number" then attribute else 0
end

function WeaponSkins.counts(p: string, flag: boolean, flag2: boolean, flag3: boolean)
	local kind = WeaponSkins.challenge(p).kind

	if kind == "head" and flag then
		flag3 = flag
	elseif kind == "multi" and flag2 then
		flag3 = flag2
	elseif kind ~= "long" then
		flag3 = false
	end

	return flag3
end

WeaponSkins.KEEP_PREFIX = "Ck_"

function WeaponSkins.keepStat(p: string)
	return WeaponSkins.KEEP_PREFIX .. p
end

function WeaponSkins.keepLevel(instance, p: string)
	local attribute = instance:GetAttribute(WeaponSkins.keepStat(p))
	return if type(attribute) == "number" then attribute else 0
end

function WeaponSkins.levelMet(p, p2: string, p3): boolean
	if Mastery.level(p, p2) >= p3.level then
		return true
	elseif p3.was == nil then
		return false
	else
		return WeaponSkins.keepLevel(p, p2) >= p3.was
	end
end

function WeaponSkins.unlocked(instance, p: string, data)
	if instance:GetAttribute("UnlockAll") == true then
		return true
	end

	if data.crate then
		return WeaponSkins.ownsCrate(instance, data.id, WeaponSkins.classOf(p))
	end

	if data.bundle or data.streak then
		return WeaponSkins.ownsCrate(instance, data.id)
	end

	if data.class then
		local classGolds, v3 = WeaponSkins.classGolds(instance, p)
		return v3 <= classGolds
	end

	if WeaponSkins.levelMet(instance, p, data) then
		return not data.challenge or WeaponSkins.goldCount(instance, p) >= WeaponSkins.challenge(p).goal
	end

	return false
end

function WeaponSkins.classGolds(p, p2: string)
	local classGuns = WeaponSkins.classGuns(p2)
	local count = 0

	for _, classGun in classGuns do
		if WeaponSkins.unlocked(p, classGun, gold) then
			count += 1
		end
	end

	return count, #classGuns
end

function WeaponSkins.needs(p, p2: string, data)
	if data.crate then
		return {
			{
				text = WeaponSkins.rarity(data.crate).name .. " SKIN FROM " .. WeaponSkins.className(p2) .. " CRATES",
				done = false
			}
		}
	end

	if data.bundle then
		return {
			{ text = WeaponSkins.BUNDLE_NEED, done = false }
		}
	end

	if data.streak then
		return {
			{ text = WeaponSkins.STREAK_NEED, done = false }
		}
	end

	local level = Mastery.level(p, p2)

	if data.class then
		local classGolds, v3 = WeaponSkins.classGolds(p, p2)
		return {
			{
				text = "GOLD ON THIS GUN",
				done = WeaponSkins.unlocked(p, p2, gold)
			},
			{
				text = string.format("GOLD ON EVERY %s  %d / %d", WeaponSkins.className(p2), classGolds, v3),
				done = v3 <= classGolds
			}
		}
	end

	if not data.challenge then
		return {
			{
				text = string.format("WEAPON LEVEL %d  /  NOW: %d", data.level, level),
				done = data.level <= level
			}
		}
	end

	local challenge = WeaponSkins.challenge(p2)
	local v3 = math.min(WeaponSkins.goldCount(p, p2), challenge.goal)
	return {
		{
			text = string.format("EVERY OTHER CAMO  /  WEAPON LEVEL %d", data.level),
			done = WeaponSkins.levelMet(p, p2, data)
		},
		{
			text = string.format("%s  %d / %d", challenge.name, v3, challenge.goal),
			done = challenge.goal <= v3
		}
	}
end

function WeaponSkins.lockTag(p, p2: string, data)
	if data.crate then
		return "CRATE"
	end

	if data.bundle then
		return "BUNDLE"
	end

	if data.streak then
		return "DAY 7"
	end

	if not data.challenge then
		return string.format("LV %d", data.level)
	end

	if data.class then
		local classGolds, v3 = WeaponSkins.classGolds(p, p2)
		return string.format("%d/%d", classGolds, v3)
	end

	local challenge = WeaponSkins.challenge(p2)
	return string.format("%d/%d", math.min(WeaponSkins.goldCount(p, p2), challenge.goal), challenge.goal)
end

WeaponSkins.GOLD = gold.id
WeaponSkins.DIAMOND = v.DIAMOND.id

function WeaponSkins.wearsGold(folder): boolean
	for _, descendant in folder:GetDescendants() do
		if
			descendant:IsA("BasePart") and descendant.MaterialVariant == gold.variant
			or descendant:IsA("SurfaceAppearance") and descendant.Name == gold.id
		then
			return true
		end
	end

	return false
end

function WeaponSkins:goldLight()
	self.Ambient = Color3.fromRGB(70, 66, 62)
	self.LightColor = Color3.new(1.9, 1.75, 1.55)
end

function WeaponSkins.pick(instance, p: string)
	local attribute = instance:GetAttribute(WeaponSkins.attr(p))
	local v3

	if type(attribute) == "string" then
		v3 = v[attribute]
	end

	if v3 and WeaponSkins.unlocked(instance, p, v3) then
		return v3.id
	end

	return WeaponSkins.DEFAULT
end

function WeaponSkins.opened(p: number, p2: number)
	local result = {}

	for _, v3 in WeaponSkins.LIST do
		if v3.challenge or v3.crate or v3.bundle or v3.streak then
			continue
		end

		if not (p < v3.level and v3.level <= p2) then
			continue
		end

		table.insert(result, v3)
	end

	return result
end

local v3 = {
	"Glass",
	"Lens",
	"Reticle",
	"Dot",
	"Chevron",
	"Tick",
	"Post",
	"Mark",
	"Eyecup",
	"Inner",
	"Bore",
	"Rag",
	"Tape",
	"Wrap",
	"Flame",
	"Round",
	"Fuse",
	"Fuel",
	"Strap"
}
local set = {
	[Enum.Material.Neon] = true,
	[Enum.Material.Glass] = true,
	[Enum.Material.ForceField] = true,
	[Enum.Material.Fabric] = true
}

local function body(part): (boolean, boolean)
	if not part:IsA("BasePart") then
		return false, false
	end

	local name = part.Name

	if string.sub(name, 1, 10) == "BakedMetal" then
		return true, true
	end

	if string.sub(name, 1, 18) == "BakedSmoothPlastic" then
		return true, false
	end

	if string.sub(name, 1, 5) == "Baked" then
		return false, false
	end

	local wsMaterial = part:GetAttribute("WsMaterial")
	local v4

	if type(wsMaterial) == "string" then
		v4 = Enum.Material[wsMaterial]
	else
		v4 = part.Material
	end

	if part.Transparency > 0 or set[v4] then
		return false, false
	end

	for _, v5 in v3 do
		if string.find(name, v5, 1, true) then
			return false, false
		end
	end

	return true, v4 == Enum.Material.Metal
end

local function paintMesh(part, p)
	local bodyMesh = part:GetAttribute("BodyMesh")
	local child = ReplicatedStorage:WaitForChild("Gunsmith"):WaitForChild("SkinLooks"):FindFirstChild(bodyMesh)
	local surfaceAppearance = child and child:FindFirstChild(p.id)
	assert(
		surfaceAppearance and surfaceAppearance:IsA("SurfaceAppearance"),
		"WeaponSkins: no " .. p.id .. " look for the " .. bodyMesh .. " body mesh"
	)
	local surfaceAppearance2 = part:FindFirstChildOfClass("SurfaceAppearance")

	if surfaceAppearance2 and surfaceAppearance2.Name == p.id then
		return
	end

	if surfaceAppearance2 then
		surfaceAppearance2:Destroy()
	end

	local clone = surfaceAppearance:Clone()
	clone.Parent = part
end

local function roles(folder)
	local parts = {}
	local v4 = {}
	local v5 = false
	local result = {}

	for _, part in folder:GetDescendants() do
		if not (not part:IsA("MeshPart") or part:GetAttribute("BodyMesh") == nil) then
			continue
		end

		local v6, v7 = body(part)

		if not v6 then
			continue
		end

		table.insert(parts, part)
		v4[part] = v7
		v5 = v5 or part:GetAttribute("Furn") == true or part:GetAttribute("Steel") == true
	end

	local total = 0
	local total2 = 0
	local v6 = 0
	local v7 = nil

	for _, v8 in parts do
		local gsSlot = v8:GetAttribute("GsSlot")

		if v8:GetAttribute("Steel") == true or gsSlot == "Muzzle" then
			result[v8] = "steel"
		elseif v8:GetAttribute("Furn") == true or gsSlot == "Optic" then
			result[v8] = "furn"
		elseif v5 then
			result[v8] = "body"
		else
			local size = v8.Size
			local v9 = size.X * size.Y * size.Z
			total += v9

			if v4[v8] then
				total2 += v9
				result[v8] = "body"
			else
				result[v8] = "furn"

				if v6 < v9 then
					v7 = v8
					v6 = v9
				end
			end
		end
	end

	if v7 and total2 < total * 0.35 then
		result[v7] = "body"
	end

	return result
end

function WeaponSkins.paint(folder, p: string?)
	local v4 = v[p or WeaponSkins.DEFAULT] or v[WeaponSkins.DEFAULT]

	for _, part in folder:GetDescendants() do
		if part:IsA("MeshPart") and part:GetAttribute("BodyMesh") ~= nil then
			paintMesh(part, v4)
		end
	end

	for part, v5 in roles(folder) do
		local v6 = v5 == "steel" and not v4.whole and "factory" or v5 == "furn" and not v4.plastic and "body" or v5

		local v7 = v4.id == WeaponSkins.DEFAULT and "factory" or v6

		if part:GetAttribute("WsColor") == nil then
			if v7 == "factory" then
				continue
			end

			part:SetAttribute("WsColor", part.Color)
			part:SetAttribute("WsMaterial", part.Material.Name)
			part:SetAttribute("WsVariant", part.MaterialVariant)
			part:SetAttribute("WsOwn", not part:IsA("UnionOperation") or part.UsePartColor)
		end

		if v7 == "factory" then
			part.Color = part:GetAttribute("WsColor")
			part.Material = Enum.Material[part:GetAttribute("WsMaterial")]
			part.MaterialVariant = part:GetAttribute("WsVariant")

			if part:IsA("UnionOperation") then
				part.UsePartColor = part:GetAttribute("WsOwn") == true
			end
		else
			if v7 == "furn" then
				part.Material = Enum.Material.SmoothPlastic
				part.MaterialVariant = ""
				part.Color = v4.plastic
			elseif v4.variant then
				part.Material = v4.material or Enum.Material.SmoothPlastic
				part.MaterialVariant = v4.variant
				part.Color = Color3.new(1, 1, 1)
			else
				part.Material = v4.material or Enum.Material.SmoothPlastic
				part.MaterialVariant = ""
				part.Color = v4.metal
			end

			if part:IsA("UnionOperation") then
				part.UsePartColor = true
			end
		end
	end

	if folder:IsA("Tool") then
		folder:SetAttribute("GsSkin", v4.id)
	end
end

return WeaponSkins