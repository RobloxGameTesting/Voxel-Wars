local VehicleConfig = {}
VehicleConfig.UNIT = 3
VehicleConfig.STEP = 1 / 60
VehicleConfig.MAX_STEPS = 4
VehicleConfig.HITCH = 0.2
VehicleConfig.CATCH_UP = 0.5

function VehicleConfig.simTime(p: number)
	if VehicleConfig.HITCH < p then
		return (math.min(p, VehicleConfig.CATCH_UP))
	end

	return (math.min(p, VehicleConfig.STEP * VehicleConfig.MAX_STEPS))
end

VehicleConfig.GRAVITY = 9.81 * VehicleConfig.UNIT * 1.25

function VehicleConfig.timeScale()
	return (math.sqrt(VehicleConfig.GRAVITY / (9.81 * VehicleConfig.UNIT)))
end

VehicleConfig.STEER_SPEED = 0.036
VehicleConfig.STEER_BACK = 0.05
VehicleConfig.STEER_RESPONSE = 0.12
VehicleConfig.PEDAL_RESPONSE = 0.12
VehicleConfig.STARTUP_DECAY = 1.2

VehicleConfig.SWITCH_BRAKE = 15
VehicleConfig.SWITCH_SHIFT = 1.5
VehicleConfig.SHIFT_TIME = 0.2

VehicleConfig.UPSHIFT = 0.96
VehicleConfig.DOWNSHIFT = 0.72
VehicleConfig.UPSHIFT_TIME = 0.18
VehicleConfig.HOLD_SPEED = 2

VehicleConfig.BROKEN = 0.5

VehicleConfig.CRASH_SOUND = 12
VehicleConfig.CRASH_DAMAGE = 24
VehicleConfig.CRASH_COOLDOWN = 0.25

function VehicleConfig.crashHole(p: number)
	return math.clamp((p - 18) * 0.11, 0, 5), (math.clamp((p - 27) * 0.09, 0, 4))
end

VehicleConfig.PUSH_EVERY = 0.3
VehicleConfig.PUSH_THROTTLE = 0.3
VehicleConfig.PUSH = {
	Humvee = {
		soft = 3.2,
		medium = 2.6,
		hard = 0,
		spread = 3,
		weapon = "HumveeRam"
	},
	Tank = {
		soft = 4.5,
		medium = 4,
		hard = 3.2,
		spread = 3.5,
		weapon = "TankRam",
		brick = 17
	},
	Bradley = {
		soft = 4,
		medium = 3.5,
		hard = 2.6,
		spread = 3,
		weapon = "BradleyRam",
		brick = 20
	}
}

VehicleConfig.RAM_FROM = 12
VehicleConfig.RAM_BRICK = 20
VehicleConfig.RAM_REF = 10
VehicleConfig.RAM_POWER_MAX = 8
function VehicleConfig.ramPower(p: number)
	return (math.clamp((p / VehicleConfig.RAM_REF) ^ 2, 0.5, VehicleConfig.RAM_POWER_MAX))
end

function VehicleConfig.crashDent(p: number)
	return (math.clamp((p - 24) * 0.035, 0, 1.6))
end

VehicleConfig.ROADKILL_SPEED = 18
VehicleConfig.ROADKILL_DAMAGE = 3.5
VehicleConfig.ROADKILL_COOLDOWN = 0.6

VehicleConfig.BLAST_HOLE = 0.7
VehicleConfig.BLAST_PUSH = 0.35

VehicleConfig.BLAST_PUSH_BY = { Tank = 0.3, Bradley = 0.4 }

VehicleConfig.BLAST_WRECK = 0.28

VehicleConfig.BLAST_WEAR = { BradleyCannon = 0.5, Flak = 0.2, C4 = 1.82 }

VehicleConfig.BLAST_WEAR_ON = {
	TankCannon = { Bradley = 1.3 }
}

VehicleConfig.AIR_ROCKET_WEAR = { Tank = 0.6, Bradley = 0.6 }

VehicleConfig.AIR_BOUNDS = {
	time = 10,
	check = 0.25,
	below = 40,
	reach = 4000,
	attr = "OobUntil",
	linger = 0.5
}
VehicleConfig.WRECK_BLAST = 1.4
VehicleConfig.WRECK_DAMAGE = 90

VehicleConfig.BLAST_PIECE_KICK = 16

VehicleConfig.COOKOFF_MODELS = { Tank = 1, Bradley = 0.85, Humvee = 0.6 }
VehicleConfig.COOKOFF = {
	Tank = {
		pops = 4,
		popSize = NumberRange.new(0.55, 0.85),
		popDamage = 35,
		popFrom = 0.35,
		popTo = 1.7,
		spread = 4,
		delay = 2,
		final = 2.4,
		finalDamage = 110,
		bomb = true
	},
	Bradley = {
		pops = 4,
		popSize = NumberRange.new(0.45, 0.7),
		popDamage = 30,
		popFrom = 0.3,
		popTo = 1.5,
		spread = 3.5,
		delay = 1.8,
		final = 2,
		finalDamage = 95,
		bomb = true
	},
	Humvee = {
		pops = 2,
		popSize = NumberRange.new(0.4, 0.6),
		popDamage = 22,
		popFrom = 0.3,
		popTo = 1,
		spread = 3,
		delay = 1.3,
		final = 1.5,
		finalDamage = 70,
		bomb = false
	}
}

VehicleConfig.ENTER_RANGE = 5

VehicleConfig.DRIVE_LEVEL = {}
VehicleConfig.DRIVE_NAMES = { Tank = "TANK", Bradley = "IFV", Heli = "HELICOPTER" }
VehicleConfig.SEAT_LIFT = 1.5
VehicleConfig.RESPAWN_DELAY = 20

VehicleConfig.RESPAWN_BY_MODEL = { Tank = 45, Bradley = 35, Heli = 60 }
function VehicleConfig.respawnDelay(p: string?)
	return p and VehicleConfig.RESPAWN_BY_MODEL[p] or VehicleConfig.RESPAWN_DELAY
end

VehicleConfig.ABANDON_TIME = 45
VehicleConfig.DAMAGED_HEALTH = 0.35
VehicleConfig.DAMAGED_TIME = 25
VehicleConfig.SLEEP_TIME = 1
VehicleConfig.POSE_RATE = 20
VehicleConfig.INTERP_DELAY = 0.12

VehicleConfig.STREAK_ROUND_WEAR = { Humvee = 0.0035, Bradley = 0.0018, Tank = 0.0012 }

VehicleConfig.Humvee = {
	topSpeed = 58,
	reverseSpeed = 20,
	launch = 0.6,
	power = 750,
	gears = { 0.22, 0.42, 0.66, 1 },
	brakeForce = 0.9,
	engineBrake = 0.2,
	rollResist = 0.03,
	spring = 0.5,
	damping = 1,
	friction = 1.45,
	antispin = 0,
	antiroll = 0.65,
	difflock = 0.5,
	maxSteer = 0.8028514559173916,
	outerSteer = 0.82,
	highSpeedSteer = 0.32,
	airDrag = 0.00025,
	steerGrip = 0.8,
	slideGrip = 0.95,
	yawHold = 3
}

VehicleConfig.Tank = {
	topSpeed = 21,
	reverseSpeed = 11,
	launch = 0.45,
	power = 600,
	hill = 0.8,
	gears = { 0.3, 0.6, 1 },
	brakeForce = 1.1,
	engineBrake = 0.35,
	rollResist = 0.06,
	spring = 0.3,
	damping = 0.6,
	friction = 2.2,
	antispin = 1,
	antiroll = 0.5,
	difflock = 0,
	maxSteer = 0.5759586531581288,
	outerSteer = 0.9,
	highSpeedSteer = 0.45,
	airDrag = 0.0004,
	pivot = 0.8,
	inertia = 1.8,
	tiltDamp = 3,
	lift = 2.5,
	liftFree = 3,
	tiltKick = 5,
	lowPush = 4
}

VehicleConfig.Bradley = {
	topSpeed = 33,
	reverseSpeed = 14,
	launch = 0.5,
	power = 700,
	hill = 0.8,
	gears = { 0.3, 0.6, 1 },
	brakeForce = 1.1,
	engineBrake = 0.3,
	rollResist = 0.05,
	spring = 0.32,
	damping = 0.6,
	friction = 2.1,
	antispin = 1,
	antiroll = 0.45,
	difflock = 0,
	maxSteer = 0.6283185307179586,
	outerSteer = 0.9,
	highSpeedSteer = 0.4,
	airDrag = 0.0004,
	pivot = 1,
	inertia = 1.8,
	tiltDamp = 3,
	lift = 2.5,
	liftFree = 3,
	tiltKick = 5,
	lowPush = 4
}

VehicleConfig.MountedGun = {
	Humvee = {
		heavy = true,
		rate = 5.5,
		botRate = 4,
		burst = 3,
		spread = 0.5,
		botSpread = 1.6,
		spinUp = 0.01,
		spinDown = 0.01,
		fireAt = 0,
		yaw = 3.141592653589793,
		pitchUp = 0.6108652381980153,
		pitchDown = 0.24434609527920614,
		heat = 1 / 60,
		cool = 0.22,
		coolDelay = 0.4,
		unlock = 0.4,
		tracerEvery = 1,
		blastSize = 0.3,
		blastDamage = 130,
		blastReach = 0.8,
		bot = { blastSize = 0.2, blastDamage = 160, blastReach = 0.5 },
		kick = 1.1,
		climb = 0.2
	}
}

VehicleConfig.TankGun = {
	belt = true,
	model = "TankGun",
	rate = 10,
	spread = 0.5,
	spinUp = 0.01,
	spinDown = 0.01,
	fireAt = 0,
	yaw = 3.141592653589793,
	pitchUp = 1.0471975511965976,
	pitchDown = 0.6981317007977318,
	heat = 1 / 90,
	cool = 0.2,
	coolDelay = 0.3,
	unlock = 0.5,
	tracerEvery = 2,
	turn = 5
}

VehicleConfig.FLYING = { Heli = true }

VehicleConfig.Heli = {
	topSpeed = 85,
	tilt = 0.3839724354387525,
	roll = 0.4188790204786391,
	tiltRate = 2.6,
	brakeTilt = 0.7,
	brakeSpeed = 45,
	bank = 0.22,
	yawRate = 1.5,
	yawAccel = 4,
	climb = 0.55,
	sink = 1.3,
	cushionHeight = 60,
	cushionRate = 0.9,
	cushionSpeed = 14,
	botSink = 0.55,
	vertDamp = 1,
	drag = 0.06,
	dragQuad = 0.0015,
	spinUp = 0.3,
	spinDown = 0.12,
	disabledAt = 0.3,
	disabledYaw = 1.3,
	disabledSink = 6,
	disabledSinkMax = 8.5,
	disabledSpin = 0.7,
	burnRate = 0.02,
	wreckSpinDown = 0.25,
	wreckGravity = 2,
	wreckPitch = -0.6981317007977318,
	wreckPitchRate = 0.3839724354387525,
	wreckRoll = 0.3490658503988659,
	wreckRollRate = 0.2617993877991494,
	wreckYaw = 1.6,
	wreckYawAccel = 2.5,
	tailOffAt = 1,
	lowBreakup = 8,
	impactPops = 2,
	impactPopSize = 1.1,
	impactPopDamage = 30,
	liftHealth = 0.18,
	floor = -1500,
	ceiling = 240,
	landCrash = 26,
	downCrash = 9,
	groundFriction = 5,
	bounce = 0.25,
	strikeSpeed = 30,
	crashWear = 0.02,
	roundWear = {
		default = 0.008,
		AssaultRifle = 0.008,
		SMG = 0.006,
		KP50 = 0.005,
		HM45 = 0.007,
		PD46 = 0.006,
		SP44 = 0.006,
		TK17 = 0.005,
		Pistol = 0.005,
		SV20 = 0.005,
		ZK10 = 0.004,
		HandCannon = 0.015,
		LMG = 0.009,
		GR240 = 0.012,
		Sniper = 0.04,
		VX50 = 0.09,
		DMR = 0.02,
		GV12 = 0.035,
		FS16 = 0.014,
		KR54 = 0.02,
		QS9 = 0.012,
		Shotgun = 0.004,
		Hammer = 0.02,
		Turret = 0.012,
		Minigun = 0.01,
		HeavyGun = 0.035
	},
	pilotRoundShare = 0.5,
	impactBlast = 2.4,
	impactDamage = 80,
	chase = { distance = 44, height = 7 },
	gun = {
		rate = 12,
		spread = 1,
		cone = 0.8726646259971648,
		heat = 1 / 72,
		cool = 0.4,
		coolDelay = 0.4,
		unlock = 0.35
	},
	rockets = {
		count = 8,
		spacing = 0.3,
		cone = 0.3839724354387525,
		reload = 1.2,
		reloadDelay = 2.5
	},
	doorGun = {
		rate = 30,
		spread = 2.2,
		spinUp = 0.12,
		spinDown = 0.6,
		fireAt = 0.9,
		yaw = 1.3089969389957472,
		pitchUp = 0.4363323129985824,
		pitchDown = 1.3089969389957472,
		heat = 1 / 300,
		cool = 0.16,
		coolDelay = 0.3,
		unlock = 0.5,
		tracerEvery = 3
	}
}

local clone = table.clone(VehicleConfig.Heli)
clone.topSpeed = 125
clone.tilt = 0.4886921905584123
clone.roll = 0.5235987755982988
clone.tiltRate = 3.6
clone.brakeSpeed = 60
clone.yawRate = 2.1
clone.yawAccel = 6
clone.climb = 0.8
clone.dragQuad = 0.00085
clone.spinUp = 0.45
clone.disabledAt = 0.25
clone.pilotRoundShare = 0.35
clone.roundWear = table.clone(clone.roundWear)

for k, v in clone.roundWear do
	clone.roundWear[k] = v * 0.8
end

clone.gun = {
	rate = 30,
	spread = 0.6,
	cone = 1.0471975511965976,
	heat = 1 / 210,
	cool = 0.3,
	coolDelay = 0.4,
	unlock = 0.4,
	spinUp = 0.4,
	round = "stealth"
}
clone.rockets = {
	count = 8,
	spacing = 0.16,
	cone = 0.3839724354387525,
	reload = 0.9,
	reloadDelay = 3,
	heavy = 1.9
}

VehicleConfig.StealthHeli = clone

local clone2 = table.clone(VehicleConfig.Heli)
clone2.topSpeed = 260
clone2.cruise = 170
clone2.afterburner = 240
clone2.stall = 60
clone2.accel = 42
clone2.brake = 60
clone2.pitchRate = 1.5
clone2.rollRate = 2.8
clone2.bank = 1.1344640137963142
clone2.turnRate = 1.6
clone2.taxiYaw = 0.7
clone2.grip = 6
clone2.ceiling = 600
clone2.boundary = 30000
clone2.landCrash = 32
clone2.crashWear = 0.008
clone2.rotate = 95
clone2.liftTime = 2.5
clone2.chase = { distance = 36, height = 8 }
clone2.gun = {
	rate = 20,
	spread = 0.4,
	cone = 0.06981317007977318,
	heat = 1 / 120,
	cool = 0.25,
	coolDelay = 0.4,
	unlock = 0.4,
	round = "jet"
}
clone2.rockets = {
	count = 4,
	spacing = 0.4,
	cone = 3.141592653589793,
	reload = 8,
	reloadDelay = 6
}
clone2.bomb = { size = 3, damage = 320 }
clone2.flares = { cooldown = 10, last = 2.5 }
VehicleConfig.Jet = clone2

local clone3 = table.clone(VehicleConfig.Jet)
clone3.topSpeed = 200
clone3.cruise = 130
clone3.afterburner = 170
clone3.stall = 55
clone3.accel = 22
clone3.brake = 35
clone3.pitchRate = 0.7
clone3.rollRate = 1.4
clone3.bank = 0.6981317007977318
clone3.turnRate = 0.65
clone3.taxiYaw = 0.4
clone3.grip = 3.5
clone3.ceiling = 700
clone3.landCrash = 26
clone3.crashWear = 0.006
clone3.rotate = 80
clone3.liftTime = 3.5
clone3.chase = { distance = 95, height = 24 }
clone3.rockets = {
	count = 12,
	spacing = 0.25,
	cone = 3.141592653589793,
	reload = 2.5,
	reloadDelay = 8
}
clone3.bomb = { size = 3, damage = 300, cut = "BomberBomb" }
VehicleConfig.Bomber = clone3

VehicleConfig.TankCannon = {
	weapon = "TankCannon",
	shells = 1,
	spacing = 1.1,
	refill = 3.5,
	size = 1.5,
	damage = 240,
	blast = {
		inner = 8,
		radius = 25,
		low = 60,
		shock = 2,
		shockRadius = 37.5
	},
	range = 900,
	speed = 1400,
	drag = 0.0016,
	maxFlight = 2,
	recoil = 1.5
}

VehicleConfig.BradleyCannon = {
	weapon = "BradleyCannon",
	kind = "AutoCannon",
	shells = 12,
	spacing = 0.3,
	refill = 2.4,
	topUp = 5,
	magazine = true,
	auto = true,
	fx = 0.35,
	size = 0.4,
	damage = 60,
	blast = {
		radius = 16,
		curve = {
			{ 0.25, 1 },
			{ 0.9, 0.2 }
		},
		shock = 2,
		shockRadius = 24
	},
	range = 900,
	speed = 625,
	drag = 0.0008,
	maxFlight = 2,
	recoil = 0.25
}

VehicleConfig.BradleyLauncher = { count = 2, spacing = 1.2, refill = 8 }

function VehicleConfig.cannonOf(p)
	local v = VehicleConfig[p.cannon or "TankCannon"]
	local v2 = type(v) == "table" and v.shells
	assert(v2, "[VehicleConfig] no cannon " .. tostring(p.cannon))
	return v
end

return VehicleConfig