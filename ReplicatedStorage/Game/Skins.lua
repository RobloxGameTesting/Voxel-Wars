local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Uniforms = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("Uniforms"))
local Gear = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("Gear"))

local Skins = {}
Skins.ATTR = "SkinPick"
Skins.DEFAULT = "Recruit"
Skins.PACK_ATTR = "StarterPack"
Skins.PAID_ON = true
Skins.PAID_PREFIX = "outfit:"
Skins.RARITY = {
	{ id = "common", name = "COMMON", color = Color3.fromRGB(168, 174, 184) },
	{ id = "rare", name = "RARE", color = Color3.fromRGB(40, 200, 255) },
	{ id = "epic", name = "EPIC", color = Color3.fromRGB(170, 90, 255) },
	{ id = "legendary", name = "LEGENDARY", color = Color3.fromRGB(255, 190, 30) },
	{ id = "mythic", name = "MYTHIC", color = Color3.fromRGB(255, 50, 50) },
	{ id = "premium", name = "PREMIUM", color = Color3.fromRGB(70, 225, 100) }
}

local v = {}

for _, v2 in Skins.RARITY do
	v[v2.id] = v2
end

function Skins.ownsAttr(p: string)
	return "Owns_Outfit_" .. p
end

local function img(p: number)
	return "rbxassetid://" .. p
end
Skins.LIST = {
	{
		id = "Recruit",
		rarity = "common",
		name = "Recruit",
		kind = "STANDARD",
		level = 1,
		gear = "Recruit",
		hair = true,
		description = "Team camo, web belt and suspenders."
	},
	{
		id = "Standard",
		rarity = "common",
		name = "Standard Issue",
		kind = "STANDARD",
		level = 2,
		gear = "Standard",
		description = "Helmet with night vision, plate carrier, team camo."
	},
	{
		id = "Recon",
		rarity = "common",
		name = "Boonie Recon",
		kind = "RECON",
		level = 3,
		gear = "Recon",
		shirt = "rbxassetid://" .. 112618014032003,
		pants = "rbxassetid://" .. 112618014032003,
		description = "Boonie hat with a net veil, light chest rig."
	},
	{
		id = "Gunner",
		rarity = "rare",
		name = "Gunner",
		kind = "SUPPORT",
		level = 6,
		gear = "Gunner",
		hair = true,
		shirt = "rbxassetid://" .. 90434918699338,
		pants = "rbxassetid://" .. 128415376403993,
		description = "Headband, ammo belt across the chest."
	},
	{
		id = "Drifter",
		rarity = "rare",
		name = "Drifter",
		kind = "RECON",
		level = 9,
		gear = "Drifter",
		shirt = "rbxassetid://" .. 97445707530642,
		pants = "rbxassetid://" .. 113713083485024,
		description = "Hooded scout, slim rig, dump pouch."
	},
	{
		id = "Savanna",
		rarity = "rare",
		name = "Savanna",
		kind = "ASSAULT",
		level = 12,
		gear = "Savanna",
		shirt = "rbxassetid://" .. 131930207046269,
		pants = "rbxassetid://" .. 138961285795191,
		description = "Rust desert camo, covered helmet, gaiter."
	},
	{
		id = "Viper",
		rarity = "rare",
		name = "Viper",
		kind = "ASSAULT",
		level = 14,
		gear = "Viper",
		shirt = "rbxassetid://" .. 116901839157705,
		pants = "rbxassetid://" .. 139789106096124,
		description = "Tiger-stripe jungle raider."
	},
	{
		id = "Sapper",
		rarity = "epic",
		name = "Sapper",
		kind = "ENGINEER",
		level = 16,
		gear = "Sapper",
		shirt = "rbxassetid://" .. 113036903431003,
		pants = "rbxassetid://" .. 123581259524439,
		description = "Hard hat, tool harness, hazard straps."
	},
	{
		id = "Fighter",
		rarity = "epic",
		name = "Frontline",
		kind = "ASSAULT",
		level = 20,
		gear = "Fighter",
		shirt = "rbxassetid://" .. 123556320732943,
		pants = "rbxassetid://" .. 105730976727709,
		description = "Digital camo, goggles, full face mask."
	},
	{
		id = "Whiteout",
		rarity = "epic",
		name = "Whiteout",
		kind = "RECON",
		level = 25,
		gear = "Whiteout",
		shirt = "rbxassetid://" .. 103923904332661,
		pants = "rbxassetid://" .. 116941055433554,
		description = "Snow camo, white helmet, face cover."
	},
	{
		id = "Scarred",
		rarity = "epic",
		name = "Battle-Scarred",
		kind = "SUPPORT",
		level = 30,
		gear = "Scarred",
		hair = true,
		shirt = "rbxassetid://" .. 138678085033120,
		pants = "rbxassetid://" .. 71933232991998,
		description = "Bandana, medic rig, fingerless gloves."
	},
	{
		id = "Specter",
		rarity = "legendary",
		name = "Specter",
		kind = "ASSAULT",
		level = 40,
		gear = "Specter",
		shirt = "rbxassetid://" .. 75692381051002,
		pants = "rbxassetid://" .. 75692381051002,
		description = "Black ballistic helmet and mask."
	},
	{
		id = "Riptide",
		rarity = "legendary",
		name = "Riptide",
		kind = "RECON",
		level = 45,
		gear = "Riptide",
		shirt = "rbxassetid://" .. 98410719783747,
		pants = "rbxassetid://" .. 133878207997120,
		description = "Combat diver with rebreather and dive mask."
	},
	{
		id = "Hazmat",
		rarity = "legendary",
		name = "Hazmat",
		kind = "ENGINEER",
		level = 50,
		gear = "Hazmat",
		shirt = "rbxassetid://" .. 101275643762949,
		pants = "rbxassetid://" .. 126469498581084,
		description = "Gas mask, sealed suit, glowing chem lights."
	},
	{
		id = "NightRaider",
		rarity = "legendary",
		name = "Night Raider",
		kind = "RECON",
		level = 65,
		gear = "NightRaider",
		shirt = "rbxassetid://" .. 76392337366838,
		pants = "rbxassetid://" .. 79202214789436,
		description = "Four-tube night vision, scarf, loaded carrier."
	},
	{
		id = "Juggernaut",
		rarity = "mythic",
		name = "Juggernaut",
		kind = "ASSAULT",
		level = 72,
		gear = "Juggernaut",
		shirt = "rbxassetid://" .. 138196721726444,
		pants = "rbxassetid://" .. 132629717469405,
		description = "Heavy armour, steel visor, built to take hits."
	},
	{
		id = "Wraith",
		rarity = "mythic",
		name = "Wraith",
		kind = "RECON",
		level = 80,
		gear = "Wraith",
		shirt = "rbxassetid://" .. 73782204711299,
		pants = "rbxassetid://" .. 112154422364705,
		description = "Black leaf ghillie, face hidden."
	},
	{
		id = "SkyRaider",
		rarity = "premium",
		name = "Sky Raider",
		kind = "SUPPORT",
		level = 999,
		paid = true,
		gear = "SkyRaider",
		shirt = "rbxassetid://" .. 118398068106974,
		pants = "rbxassetid://" .. 130253432671045,
		description = "Flight helmet, mask and harness."
	},
	{
		id = "Inferno",
		rarity = "premium",
		name = "Inferno",
		kind = "ENGINEER",
		level = 999,
		paid = true,
		gear = "Inferno",
		shirt = "rbxassetid://" .. 119762693422732,
		pants = "rbxassetid://" .. 131239088106812,
		description = "Fire-proof armour, respirator and fuel tanks."
	},
	{
		id = "Venom",
		rarity = "premium",
		name = "Venom",
		kind = "ASSAULT",
		level = 999,
		paid = true,
		gear = "Venom",
		shirt = "rbxassetid://" .. 95413095776721,
		pants = "rbxassetid://" .. 99980976094213,
		description = "Gas mask with glowing lenses, night vision, toxic green camo."
	},
	{
		id = "Revenant",
		rarity = "premium",
		name = "Revenant",
		kind = "RECON",
		level = 999,
		paid = true,
		gear = "Revenant",
		shirt = "rbxassetid://" .. 72975438748961,
		pants = "rbxassetid://" .. 136433473350599,
		description = "Grey hood and cloak over black gear, slung breaching hammer."
	}
}

local v2 = {}
local v3 = {}

for k, v4 in Skins.LIST do
	local v5 = type(v4.id) == "string" and not v2[v4.id]
	assert(v5, "[Skins] outfit id missing or repeated: " .. tostring(v4.id))
	local v6 = type(v4.name) == "string" and type(v4.kind) == "string" and type(v4.description) == "string"
	assert(v6, "[Skins] " .. v4.id .. " needs a name, kind and description")
	local v7 = type(v4.level) == "number" and v4.level >= 1
	assert(v7, "[Skins] " .. v4.id .. " needs a level")
	assert(
		k == 1 or v4.level >= Skins.LIST[k - 1].level,
		"[Skins] outfits must be listed in level order (" .. v4.id .. ")"
	)
	assert(Gear.has(v4.gear), "[Skins] " .. v4.id .. ": unknown gear kit " .. tostring(v4.gear))
	assert(v[v4.rarity], "[Skins] " .. v4.id .. ": rarity must be one of Skins.RARITY")
	assert(
		(v4.rarity == "premium") == (v4.paid == true),
		"[Skins] " .. v4.id .. ": PREMIUM is the Robux outfits' tier, and only theirs"
	)
	assert(
		not (v4.paid or v4.pack) or v4.level == 999,
		"[Skins] " .. v4.id .. ": a paid or pack outfit must sit at PACK_LEVEL"
	)
	assert(
		(v4.shirt == nil) == (v4.pants == nil),
		"[Skins] " .. v4.id .. ": set both shirt and pants, or neither (team camo)"
	)
	v2[v4.id] = v4

	if v4.hair then
		table.insert(v3, v4)
	end
end

assert(
	v2[Skins.DEFAULT] and v2[Skins.DEFAULT].level <= 1,
	"[Skins] the default outfit must exist and be unlocked from level 1"
)
assert(#v3 > 0, "[Skins] bacon bots need at least one outfit with hair = true")

function Skins.rarityOf(p)
	local v4 = v[p.rarity]
	assert(v4, "[Skins] " .. p.id .. ": unknown rarity " .. tostring(p.rarity))
	return v4
end

function Skins.find(p: string)
	return v2[p]
end

function Skins.get(p: string)
	local v4 = v2[p]
	assert(v4, "[Skins] unknown outfit " .. tostring(p))
	return v4
end

function Skins.levelOf(instance)
	local level = instance:GetAttribute("Level")
	return if type(level) == "number" then level else 1
end

function Skins.unlocked(instance, p: string): boolean
	local v4 = v2[p]

	if v4 == nil then
		return false
	elseif
		Skins.levelOf(instance) >= v4.level
		or instance:GetAttribute("UnlockAll") == true
		or v4.pack == true and instance:GetAttribute(Skins.PACK_ATTR) == true
	then
		return true
	elseif v4.paid == true then
		return instance:GetAttribute(Skins.ownsAttr(p)) == true
	else
		return false
	end
end

function Skins.lockText(data, formatString: string)
	if data.pack then
		return "STARTER PACK"
	end

	if not data.paid then
		return (string.format(formatString, data.level))
	end

	return if Skins.PAID_ON then "ROBUX OUTFIT" else "COMING SOON"
end

function Skins.pick(instance)
	local attribute = instance:GetAttribute(Skins.ATTR)

	if type(attribute) == "string" and Skins.unlocked(instance, attribute) then
		return attribute
	end

	return Skins.DEFAULT
end

function Skins.forBot(p: number, flag: boolean?)
	local v4 = if flag then v3 else Skins.LIST
	return v4[math.abs((math.floor(p))) % #v4 + 1]
end

function Skins.look(data, p: string?, p2: number)
	if data.shirt and data.pants then
		return { shirt = data.shirt, pants = data.pants, cut = data.name, gear = data.gear }
	end

	local cutFor = Uniforms.cutFor(p2)
	local templates, pants = Uniforms.templates(p, cutFor.shirt, cutFor.pants)
	return { shirt = templates, pants = pants, cut = cutFor.name, gear = data.gear }
end

return Skins