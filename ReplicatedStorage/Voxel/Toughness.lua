local Materials = require(script.Parent.Materials)

local RifleSpecs = require(script.Parent.Parent:WaitForChild("Game"):WaitForChild("RifleSpecs"))
local Toughness = {}

Toughness.Weapons = {
	AssaultRifle = { peak = 20, core = 0.25, rim = 0.5 },
	Pistol = { peak = 16, core = 0.25, rim = 0.5 },
	HandCannon = { peak = 30, core = 0.28, rim = 0.5 },
	LMG = { peak = 24, core = 0.25, rim = 0.5 },
	SMG = { peak = 18, core = 0.25, rim = 0.5 },
	Minigun = { peak = 18, core = 0.25, rim = 0.5 },
	Sniper = { peak = 45, core = 0.3, rim = 0.5 },
	DMR = { peak = 32, core = 0.28, rim = 0.5 },
	Shotgun = { peak = 14, core = 0.25, rim = 0.5 },
	Hammer = { peak = 400, core = 0.35, rim = 0.4 },
	RocketLauncher = { peak = 400, core = 0.5, rim = 0.15 },
	AALauncher = { peak = 400, core = 0.5, rim = 0.15 },
	PipeBomb = { peak = 300, core = 0.5, rim = 0.15 },
	Grenade = { peak = 220, core = 0.5, rim = 0.15 },
	Claymore = { peak = 220, core = 0.5, rim = 0.15 },
	C4 = { peak = 450, core = 0.5, rim = 0.15, self = 0.5 },
	Airstrike = { peak = 700, core = 0.65, rim = 0.25, hole = 0.7 },
	Hellfire = { peak = 900, core = 0.65, rim = 0.25 },
	BomberBomb = {
		peak = 700,
		core = 0.65,
		rim = 0.25,
		hole = 0.55,
		crater = 0.75
	},
	GunshipHeavy = { peak = 700, core = 0.65, rim = 0.25, hole = 0.7 },
	GunshipCannon = { peak = 260, core = 0.5, rim = 0.15, hole = 0.75 },
	GunshipGun = { peak = 40, core = 0.3, rim = 0.4, hole = 0.85 },
	HeavyGun = { peak = 110, core = 0.35, rim = 0.3 },
	Shrapnel = { peak = 18, core = 0.25, rim = 0.5 },
	Turret = { peak = 16, core = 0.25, rim = 0.5 },
	TurretWreck = { peak = 220, core = 0.5, rim = 0.15 },
	VehicleWreck = { peak = 220, core = 0.5, rim = 0.15 },
	TankCannon = { peak = 500, core = 0.5, rim = 0.15 },
	BradleyCannon = { peak = 130, core = 0.4, rim = 0.2 },
	TankGun = { peak = 24, core = 0.25, rim = 0.5 },
	MountedGun = { peak = 24, core = 0.25, rim = 0.5 },
	HumveeRam = { peak = 45, core = 0.4, rim = 0.5 },
	TankRam = { peak = 140, core = 0.5, rim = 0.5 },
	BradleyRam = { peak = 100, core = 0.5, rim = 0.5 }
}

for k in RifleSpecs.LIST do
	Toughness.Weapons[k] = Toughness.Weapons.AssaultRifle
end

local LMGSpecs = require(script.Parent.Parent:WaitForChild("Game"):WaitForChild("LMGSpecs"))

for k in LMGSpecs.LIST do
	Toughness.Weapons[k] = Toughness.Weapons.LMG
end

local SMGSpecs = require(script.Parent.Parent:WaitForChild("Game"):WaitForChild("SMGSpecs"))

for k in SMGSpecs.LIST do
	Toughness.Weapons[k] = Toughness.Weapons.SMG
end

local DMRSpecs = require(script.Parent.Parent:WaitForChild("Game"):WaitForChild("DMRSpecs"))

for k in DMRSpecs.LIST do
	Toughness.Weapons[k] = Toughness.Weapons.DMR
end

local SniperSpecs = require(script.Parent.Parent:WaitForChild("Game"):WaitForChild("SniperSpecs"))

for k in SniperSpecs.LIST do
	Toughness.Weapons[k] = Toughness.Weapons.Sniper
end

local PistolSpecs = require(script.Parent.Parent:WaitForChild("Game"):WaitForChild("PistolSpecs"))

for k in PistolSpecs.LIST do
	Toughness.Weapons[k] = Toughness.Weapons.Pistol
end

Toughness.RIFLE_HARD = 0.6
Toughness.PISTOL_HARD = 0.45
Toughness.HAND_CANNON_HARD = 0.65
Toughness.LMG_HARD = 0.65
Toughness.SMG_HARD = 0.5
Toughness.MINIGUN_HARD = 0.5
Toughness.SNIPER_HARD = 0.8
Toughness.DMR_HARD = 0.7
Toughness.SHOTGUN_HARD = 0.35
Toughness.HAMMER_HARD = 2.6

Toughness.STAGES = 3

function Toughness.stage(p: number, p2: number)
	if p <= 0 or p2 <= 0 then
		return 0
	end

	return (math.clamp(math.ceil(p / p2 * Toughness.STAGES), 1, Toughness.STAGES))
end

function Toughness.dealt(data, p: number, p2: number)
	local v = p <= data.core and 1 or 1 - (1 - data.rim) * (p - data.core) / (1 - data.core)
	return data.peak * v - p2
end

function Toughness.hitsToBreak(p: string, p2: string, p3: number, p4: number)
	local kind = Materials.Types[p]
	local weapon = Toughness.Weapons[p2]
	assert(kind, "[Toughness] unknown material type " .. p)
	assert(weapon, "[Toughness] unknown weapon " .. p2)
	local v = kind.hp * p4

	if v <= 0 then
		return 1
	end

	local dealt = Toughness.dealt(weapon, p3, kind.armor)

	if dealt > 0 then
		return (math.ceil(v / dealt - 1e-9))
	end

	return 1e999
end

Toughness.SHADE = { 0.9, 0.78, 0.64 }
Toughness.DUST = { 0.06, 0.12, 0.2 }
Toughness.DUST_COLOR = Color3.fromRGB(120, 116, 108)
Toughness.CRACK_INSET = 0.03

return Toughness