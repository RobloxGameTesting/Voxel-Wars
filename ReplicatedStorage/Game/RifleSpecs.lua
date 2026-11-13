local RifleSpecs = {}

local newVector3 = Vector3.new
local sprintHold = CFrame.new(-0.2, -1.3, -1.9) * CFrame.Angles(
	-0.5113814708343386,
	1.08035880698449,
	0.46600291028248597
)
local function hold(p: number, p2: number, p3: number) -- 6 equivalent calls inferred from this helper
	return CFrame.new(p, p2, p3) * CFrame.Angles(0.03490658503988659, 0.03490658503988659, 0.017453292519943295)
end

RifleSpecs.LIST = {
	K433 = {
		id = "K433",
		name = "K-433",
		interval = 0.08,
		mag = 30,
		reload = { tactical = 1.1, empty = 1.9 },
		pace = { tactical = 1.06, empty = 1.16 },
		damage = {
			{ 0, 41.2 },
			{ 21.5, 34.3 },
			{ 75, 29.4 }
		},
		spread = {
			hip = 1.6,
			aim = 0.08,
			moving = 0.9,
			bloom = 0.1,
			bloomMax = 1.4,
			bloomDecay = 5,
			aimBloom = 0.9,
			aimMoving = 0.2,
			hipJump = 1.6,
			aimJump = 0.9
		},
		sound = 0.95,
		view = {
			weight = 1,
			hold = hold(0.7, -0.8, -1.8), -- inferred equivalent call
			rightHand = Vector3.new(0, -0.33, 0.15),
			leftHand = Vector3.new(-0.05, -0.27, -0.8),
			aimPoint = Vector3.new(0, 0.27, 0),
			aimDistance = 1.105,
			aimFov = 38.3,
			aimMove = 0.75,
			reach = 3.45,
			sprintHold = sprintHold,
			hipKick = Vector3.new(0.018, 0.012, 0.2),
			hipKickRot = Vector3.new(0.9, 0.8, 1.3),
			aimKick = Vector3.new(0.006, 0.005, 0.05),
			aimKickRot = Vector3.new(0.3, 0.4, 1.1),
			recoilTime = 0.09,
			punch = 0.55,
			flashScale = 0.95,
			eject = Vector3.new(0.11, 0.035, -0.06),
			charger = Vector3.new(-0.16, 0.045, -0.36),
			magGrab = Vector3.new(0, -0.5, -0.3)
		}
	},
	GX36 = {
		id = "GX36",
		name = "GX-36",
		interval = 0.083,
		mag = 30,
		reload = { tactical = 1.05, empty = 1.7 },
		pace = { tactical = 1.01, empty = 1.04 },
		damage = {
			{ 0, 41.2 },
			{ 21.5, 34.3 },
			{ 75, 29.4 }
		},
		spread = {
			hip = 1.6,
			aim = 0.06,
			moving = 1,
			bloom = 0.09,
			bloomMax = 1.3,
			bloomDecay = 5,
			aimBloom = 0.9,
			aimMoving = 0.2,
			hipJump = 1.6,
			aimJump = 0.9
		},
		sound = 1,
		view = {
			weight = 0.95,
			hold = hold(0.7, -0.86, -1.8), -- inferred equivalent call
			rightHand = Vector3.new(0, -0.33, 0.15),
			leftHand = Vector3.new(-0.05, -0.27, -0.82),
			aimPoint = Vector3.new(0, 0.42, 0.02),
			aimDistance = 0.919,
			aimFov = 33.1,
			aimMove = 0.7,
			reach = 3.55,
			sprintHold = sprintHold,
			hipKick = Vector3.new(0.02, 0.01, 0.24),
			hipKickRot = Vector3.new(1, 0.6, 1.2),
			aimKick = Vector3.new(0.007, 0.005, 0.055),
			aimKickRot = Vector3.new(0.3, 0.3, 1),
			recoilTime = 0.11,
			punch = 0.6,
			flashScale = 1,
			eject = Vector3.new(0.1, 0.02, -0.08),
			charger = Vector3.new(0, 0.15, -0.24),
			magGrab = Vector3.new(0, -0.5, -0.33)
		}
	},
	SK556 = {
		id = "SK556",
		name = "SK-556",
		interval = 0.106,
		mag = 30,
		reload = { tactical = 1.45, empty = 2 },
		pace = { tactical = 1.39, empty = 1.22 },
		damage = {
			{ 0, 41.2 },
			{ 21.5, 34.3 },
			{ 75, 29.4 }
		},
		spread = {
			hip = 1.6,
			aim = 0.05,
			moving = 1,
			bloom = 0.07,
			bloomMax = 0.7,
			bloomDecay = 4.5,
			aimBloom = 0.9,
			aimMoving = 0.2,
			hipJump = 1.6,
			aimJump = 0.9
		},
		sound = 1.05,
		view = {
			weight = 1.05,
			hold = hold(0.68, -0.82, -1.82), -- inferred equivalent call
			rightHand = Vector3.new(0, -0.33, 0.15),
			leftHand = Vector3.new(-0.05, -0.29, -0.74),
			aimPoint = Vector3.new(0, 0.3, 0.04),
			aimDistance = 1.299,
			aimFov = 19.7,
			aimMove = 0.62,
			reach = 3.6,
			sprintHold = sprintHold,
			hipKick = Vector3.new(0.025, 0.015, 0.3),
			hipKickRot = Vector3.new(1.3, 0.5, 1),
			aimKick = Vector3.new(0.008, 0.004, 0.07),
			aimKickRot = Vector3.new(0.45, 0.2, 0.8),
			recoilTime = 0.14,
			punch = 0.75,
			flashScale = 1.15,
			eject = Vector3.new(0.1, 0, -0.06),
			charger = Vector3.new(-0.11, -0.15, -0.12),
			magGrab = Vector3.new(0, -0.48, -0.3)
		}
	},
	RN545 = {
		id = "RN545",
		name = "RN-545",
		interval = 0.075,
		mag = 30,
		reload = { tactical = 1.7, empty = 2.2 },
		pace = { tactical = 1.615, empty = 1.337 },
		damage = {
			{ 0, 41.2 },
			{ 21.5, 34.3 },
			{ 75, 29.4 }
		},
		spread = {
			hip = 1.46,
			aim = 0.05,
			moving = 0.365,
			bloom = 0.168,
			bloomMax = 4.17,
			bloomDecay = 0,
			aimBloom = 1,
			aimMoving = 0.16,
			hipJump = 2.19,
			aimJump = 0.65,
			exact = {
				hip = {
					add = 0.3024,
					top = 4.2,
					fire = { 1.076, 2.5, 2.916 },
					fireFor = 0.075,
					rest = 7.776,
					idleAfter = 0.6,
					idle = 15
				},
				aim = {
					add = 0.168,
					top = 4.2,
					fire = { 2.582, 2.5, 1.62 },
					fireFor = 0.075,
					rest = 4.32,
					idleAfter = 0.4,
					idle = 4.5
				}
			}
		},
		sound = 0.95,
		view = {
			weight = 0.95,
			hold = hold(0.7, -0.8, -1.8), -- inferred equivalent call
			rightHand = Vector3.new(0, -0.33, 0.15),
			leftHand = Vector3.new(-0.05, -0.33, -0.5),
			aimPoint = Vector3.new(0, 0.25, 0.1),
			aimDistance = 1.15,
			aimFov = 44,
			aimMove = 0.75,
			reach = 3.45,
			sprintHold = sprintHold,
			hipKick = Vector3.new(0.016, 0.01, 0.18),
			hipKickRot = Vector3.new(0.8, 0.7, 1.2),
			aimKick = Vector3.new(0.005, 0.004, 0.045),
			aimKickRot = Vector3.new(0.25, 0.3, 1),
			recoilTime = 0.08,
			punch = 0.5,
			flashScale = 0.9,
			eject = Vector3.new(0.11, 0.03, -0.06),
			charger = Vector3.new(0.11, 0, -0.1),
			magGrab = Vector3.new(0, -0.5, -0.3)
		}
	},
	MX65 = {
		id = "MX65",
		name = "MX-65",
		interval = 0.09444446193415962,
		mag = 20,
		reload = { tactical = 1.8, empty = 2.2 },
		pace = { tactical = 1.714, empty = 1.337 },
		damage = {
			{ 0, 41.2 },
			{ 21.5, 34.3 },
			{ 75, 29.4 }
		},
		spread = {
			hip = 1.46,
			aim = 0.05,
			moving = 0.365,
			bloom = 0.2454,
			bloomMax = 4.17,
			bloomDecay = 0,
			aimBloom = 1,
			aimMoving = 0.16,
			hipJump = 2.19,
			aimJump = 0.65,
			exact = {
				hip = {
					add = 0.4416,
					top = 4.2,
					fire = { 1.076, 2.5, 2.916 },
					fireFor = 0.09444446193415962,
					rest = 7.776,
					idleAfter = 0.6,
					idle = 15
				},
				aim = {
					add = 0.2454,
					top = 4.2,
					fire = { 2.582, 2.5, 1.62 },
					fireFor = 0.09444446193415962,
					rest = 4.32,
					idleAfter = 0.4,
					idle = 4.5
				}
			}
		},
		sound = 1,
		view = {
			weight = 1.05,
			hold = hold(0.7, -0.82, -1.85), -- inferred equivalent call
			rightHand = Vector3.new(0, -0.33, 0.15),
			leftHand = Vector3.new(-0.05, -0.3, -0.6),
			aimPoint = Vector3.new(0, 0.28, 0.08),
			aimDistance = 0.93,
			aimFov = 29.4,
			aimMove = 0.68,
			reach = 3.6,
			sprintHold = sprintHold,
			hipKick = Vector3.new(0.022, 0.012, 0.26),
			hipKickRot = Vector3.new(1.1, 0.6, 1.1),
			aimKick = Vector3.new(0.007, 0.005, 0.06),
			aimKickRot = Vector3.new(0.35, 0.3, 0.9),
			recoilTime = 0.12,
			punch = 0.65,
			flashScale = 1.05,
			eject = Vector3.new(0.1, 0.02, -0.08),
			charger = Vector3.new(0, 0.08, 0.42),
			magGrab = Vector3.new(0, -0.45, -0.28)
		}
	},
	BT762 = {
		id = "BT762",
		name = "BT-762",
		interval = 1 / 12,
		mag = 20,
		reload = { tactical = 2, empty = 2.8 },
		pace = { tactical = 1.906, empty = 1.697 },
		damage = {
			{ 0, 41.2 },
			{ 21.5, 34.3 },
			{ 75, 29.4 }
		},
		spread = {
			hip = 1.46,
			aim = 0.05,
			moving = 0.365,
			bloom = 0.3138,
			bloomMax = 4.17,
			bloomDecay = 0,
			aimBloom = 1,
			aimMoving = 0.16,
			hipJump = 2.19,
			aimJump = 0.65,
			exact = {
				hip = {
					add = 0.5646,
					top = 4.2,
					fire = { 1.076, 2.5, 2.916 },
					fireFor = 1 / 12,
					rest = 7.776,
					idleAfter = 0.6,
					idle = 15
				},
				aim = {
					add = 0.3138,
					top = 4.2,
					fire = { 2.582, 2.5, 1.62 },
					fireFor = 1 / 12,
					rest = 4.32,
					idleAfter = 0.4,
					idle = 4.5
				}
			}
		},
		sound = 1.05,
		view = {
			weight = 0.9,
			hold = hold(0.7, -0.8, -1.55), -- inferred equivalent call
			rightHand = Vector3.new(0, -0.33, 0.15),
			leftHand = Vector3.new(-0.05, -0.24, -0.6),
			aimPoint = Vector3.new(0, 0.31, -0.14),
			aimDistance = 1.15,
			aimFov = 44,
			aimMove = 0.72,
			reach = 3.3,
			sprintHold = sprintHold,
			hipKick = Vector3.new(0.028, 0.015, 0.32),
			hipKickRot = Vector3.new(1.4, 0.7, 1.3),
			aimKick = Vector3.new(0.009, 0.006, 0.075),
			aimKickRot = Vector3.new(0.5, 0.4, 1.1),
			recoilTime = 0.13,
			punch = 0.8,
			flashScale = 1.15,
			eject = Vector3.new(0.1, 0.02, 0.2),
			charger = Vector3.new(-0.13, 0.05, -0.38),
			magGrab = Vector3.new(0, -0.44, 0.56)
		}
	}
}

function RifleSpecs.of(p: string)
	return RifleSpecs.LIST[p]
end

return RifleSpecs