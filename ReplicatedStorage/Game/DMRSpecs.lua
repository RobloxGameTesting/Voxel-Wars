local DMRSpecs = {}

local newVector3 = Vector3.new
local sprintHold = CFrame.new(-0.2, -1.3, -1.9) * CFrame.Angles(
	-0.5113814708343386,
	1.08035880698449,
	0.46600291028248597
)
local function hold(p: number, p2: number, p3: number) -- 4 equivalent calls inferred from this helper
	return CFrame.new(p, p2, p3) * CFrame.Angles(0.03490658503988659, 0.03490658503988659, 0.017453292519943295)
end

DMRSpecs.LIST = {
	GV12 = {
		id = "GV12",
		name = "GV-12",
		interval = 0.4,
		holdRepeat = 0.5,
		mag = 10,
		reload = { tactical = 1.75, empty = 2.8 },
		pace = { tactical = 1.144, empty = 1.2 },
		damage = {
			body = {
				{ 0, 134 },
				{ 10, 120 },
				{ 21, 110 },
				{ 60, 101 }
			},
			head = {
				{ 0, 205 },
				{ 10, 201 },
				{ 12, 186 },
				{ 25, 170 },
				{ 60, 152 }
			}
		},
		speed = 0.9,
		spread = {
			hip = 2,
			aim = 0.05,
			moving = 1,
			bloom = 0.6,
			bloomMax = 1.8,
			bloomDecay = 2
		},
		sound = 1.15,
		view = {
			weight = 1.2,
			hold = hold(0.66, -0.86, -1.82), -- inferred equivalent call
			rightHand = Vector3.new(0, -0.33, 0.27),
			leftHand = Vector3.new(-0.03, -0.4, -0.85),
			armThickness = 0.5,
			aimPoint = Vector3.new(0, 0.305, 0.02),
			aimDistance = 1.422,
			aimFov = 14.8,
			aimMove = 0.55,
			reach = 4.1,
			sprintHold = sprintHold,
			hipKick = Vector3.new(0.03, 0.035, 0.32),
			hipKickRot = Vector3.new(3, 1.1, 1.8),
			aimKick = Vector3.new(0.003, 0.006, 0.06),
			aimKickRot = Vector3.new(0.5, 0.3, 0.7),
			recoilTime = 0.26,
			punch = 0.75,
			flashScale = 1.4,
			eject = Vector3.new(0.095, 0.02, -0.04),
			caseSize = Vector3.new(0.05, 0.05, 0.16),
			charger = Vector3.new(0.13, 0.07, -0.21),
			magGrab = Vector3.new(0, -0.46, -0.16)
		}
	},
	FS16 = {
		id = "FS16",
		name = "FS-16",
		interval = 0.167,
		holdRepeat = 0.24,
		mag = 15,
		reload = { tactical = 1.4, empty = 2.1 },
		pace = { tactical = 0.925, empty = 0.908 },
		damage = {
			body = {
				{ 0, 72 },
				{ 35, 68 },
				{ 80, 60 }
			},
			head = {
				{ 0, 104 },
				{ 35, 100 },
				{ 80, 92 }
			}
		},
		speed = 1,
		spread = {
			hip = 1.3,
			aim = 0.05,
			moving = 0.7,
			bloom = 0.25,
			bloomMax = 1.2,
			bloomDecay = 3
		},
		sound = 0.9,
		view = {
			weight = 1.05,
			hold = hold(0.63, -0.82, -1.7), -- inferred equivalent call
			rightHand = Vector3.new(0, -0.33, 0.27),
			leftHand = Vector3.new(-0.03, -0.4, -0.75),
			armThickness = 0.5,
			aimPoint = Vector3.new(0, 0.305, -0.02),
			aimDistance = 0.908,
			aimFov = 29.2,
			aimMove = 0.75,
			reach = 3.6,
			sprintHold = sprintHold,
			hipKick = Vector3.new(0.015, 0.018, 0.17),
			hipKickRot = Vector3.new(1.5, 0.6, 1),
			aimKick = Vector3.new(0.0015, 0.003, 0.035),
			aimKickRot = Vector3.new(0.25, 0.15, 0.4),
			recoilTime = 0.15,
			punch = 0.4,
			flashScale = 0.9,
			eject = Vector3.new(0.085, 0.02, -0.03),
			caseSize = Vector3.new(0.04, 0.04, 0.12),
			charger = Vector3.new(-0.107, -0.02, -0.18),
			magGrab = Vector3.new(0, -0.48, -0.17)
		}
	},
	KR54 = {
		id = "KR54",
		name = "KR-54",
		interval = 0.2,
		holdRepeat = 0.3,
		mag = 10,
		reload = { tactical = 1.5, empty = 2.81 },
		pace = { tactical = 0.988, empty = 1.204 },
		damage = {
			body = {
				{ 0, 75 },
				{ 110, 75 }
			},
			head = {
				{ 0, 110 },
				{ 110, 110 }
			}
		},
		speed = 1,
		spread = {
			hip = 1.6,
			aim = 0.05,
			moving = 0.8,
			bloom = 0.35,
			bloomMax = 1.4,
			bloomDecay = 2.5
		},
		sound = 1.05,
		view = {
			weight = 1.12,
			hold = hold(0.66, -0.86, -1.86), -- inferred equivalent call
			rightHand = Vector3.new(0, -0.33, 0.27),
			leftHand = Vector3.new(-0.03, -0.4, -0.78),
			armThickness = 0.5,
			aimPoint = Vector3.new(0, 0.305, 0.03),
			aimDistance = 1.54,
			aimFov = 9.9,
			aimMove = 0.6,
			reach = 4.2,
			sprintHold = sprintHold,
			hipKick = Vector3.new(0.022, 0.026, 0.24),
			hipKickRot = Vector3.new(2.2, 0.8, 1.4),
			aimKick = Vector3.new(0.002, 0.004, 0.045),
			aimKickRot = Vector3.new(0.35, 0.2, 0.5),
			recoilTime = 0.2,
			punch = 0.55,
			flashScale = 1.1,
			eject = Vector3.new(0.085, 0.03, -0.04),
			caseSize = Vector3.new(0.045, 0.045, 0.15),
			charger = Vector3.new(0.115, 0.03, -0.12),
			magGrab = Vector3.new(0, -0.44, -0.16)
		}
	},
	QS9 = {
		id = "QS9",
		name = "QS-9",
		interval = 2 / 15,
		holdRepeat = 0.2,
		mag = 20,
		reload = { tactical = 1.48, empty = 2.92 },
		pace = { tactical = 0.975, empty = 1.25 },
		damage = {
			body = {
				{ 0, 60 },
				{ 20, 60 },
				{ 50, 50 },
				{ 90, 40 }
			},
			head = {
				{ 0, 105 },
				{ 20, 105 },
				{ 50, 90 },
				{ 90, 72 }
			}
		},
		speed = 321 / 760,
		spread = {
			hip = 0.86,
			aim = 0.05,
			moving = 0.43,
			bloom = 0.28,
			bloomMax = 1.1,
			bloomDecay = 3.3
		},
		sound = 1,
		view = {
			weight = 0.95,
			hold = hold(0.62, -0.82, -1.64), -- inferred equivalent call
			rightHand = Vector3.new(0, -0.33, 0.27),
			leftHand = Vector3.new(-0.03, -0.39, -0.42),
			armThickness = 0.5,
			aimPoint = Vector3.new(0, 0.305, 0.03),
			aimDistance = 0.528,
			aimFov = 38.3,
			aimMove = 0.75,
			reach = 3.4,
			sprintHold = sprintHold,
			hipKick = Vector3.new(0.012, 0.015, 0.13),
			hipKickRot = Vector3.new(1.2, 0.5, 0.8),
			aimKick = Vector3.new(0.0012, 0.0025, 0.028),
			aimKickRot = Vector3.new(0.2, 0.12, 0.3),
			recoilTime = 0.13,
			punch = 0.3,
			flashScale = 0.3,
			eject = Vector3.new(0.08, 0.03, -0.03),
			caseSize = Vector3.new(0.04, 0.04, 0.11),
			charger = Vector3.new(0.105, 0.03, -0.1),
			magGrab = Vector3.new(0, -0.46, -0.16)
		}
	}
}

function DMRSpecs.of(p: string)
	return DMRSpecs.LIST[p]
end

return DMRSpecs