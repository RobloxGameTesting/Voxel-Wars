require(script.Parent:WaitForChild("RifleSpecs"))

local LMGSpecs = {}

local newVector3 = Vector3.new
local sprintHold = CFrame.new(-0.2, -1.35, -1.95) * CFrame.Angles(
	-0.5113814708343386,
	1.08035880698449,
	0.46600291028248597
)
local function hold(p: number, p2: number, p3: number)
	return CFrame.new(p, p2, p3) * CFrame.Angles(0.03490658503988659, 0.03490658503988659, 0.017453292519943295)
end

local function heavy(p: number, p2: number, p3: number) -- 6 equivalent calls inferred from this helper
	return CFrame.new(p, p2, p3) * CFrame.Angles(0.05235987755982989, 0.12217304763960307, 0.03490658503988659)
end

LMGSpecs.LIST = {
	BX110 = {
		id = "BX110",
		name = "BX-110",
		interval = 0.1,
		mag = 100,
		reload = { tactical = 2, empty = 3.1 },
		pace = { tactical = 1.91, empty = 1.885 },
		damage = {
			{ 0, 41.2 },
			{ 21.5, 34.3 },
			{ 75, 29.4 }
		},
		spread = {
			hip = 2.4,
			aim = 0.05,
			moving = 1.4,
			bloom = 0.14,
			bloomMax = 1.6,
			bloomDecay = 4
		},
		sound = 0.95,
		view = {
			weight = 1.33,
			hold = heavy(0.52, -0.8, -1.12), -- inferred equivalent call
			rightHand = Vector3.new(0, -0.41, 0.24),
			leftHand = Vector3.new(-0.05, -0.3, -0.62),
			armThickness = 0.7,
			aimPoint = Vector3.new(0, 0.33, 0),
			aimDistance = 1.008,
			aimFov = 45.2,
			aimMove = 0.55,
			reach = 3.8,
			sprintHold = sprintHold,
			hipKick = Vector3.new(0.03, 0.015, 0.28),
			hipKickRot = Vector3.new(1.3, 0.8, 1.6),
			aimKick = Vector3.new(0.01, 0.008, 0.065),
			aimKickRot = Vector3.new(0.4, 0.4, 1.2),
			recoilTime = 0.12,
			punch = 0.75,
			flashScale = 1.3,
			eject = Vector3.new(0.16, 0.02, -0.06),
			charger = Vector3.new(0.18, -0.02, -0.3),
			magGrab = Vector3.new(-0.1, -0.56, -0.22)
		}
	},
	HX83 = {
		id = "HX83",
		name = "HX-83",
		interval = 0.088,
		mag = 100,
		reload = { tactical = 2.1, empty = 3.2 },
		pace = { tactical = 2, empty = 1.95 },
		damage = {
			{ 0, 41.2 },
			{ 21.5, 29.4 },
			{ 75, 22.9 }
		},
		spread = {
			hip = 2.3,
			aim = 0.05,
			moving = 1.4,
			bloom = 0.13,
			bloomMax = 1.7,
			bloomDecay = 4.5
		},
		sound = 0.92,
		view = {
			weight = 1.33,
			hold = heavy(0.52, -0.8, -1.12), -- inferred equivalent call
			rightHand = Vector3.new(0, -0.41, 0.24),
			leftHand = Vector3.new(-0.05, -0.3, -0.62),
			armThickness = 0.7,
			aimPoint = Vector3.new(0, 0.3, 0),
			aimDistance = 1.008,
			aimFov = 45.2,
			aimMove = 0.55,
			reach = 3.8,
			sprintHold = sprintHold,
			hipKick = Vector3.new(0.03, 0.014, 0.26),
			hipKickRot = Vector3.new(1.2, 0.9, 1.5),
			aimKick = Vector3.new(0.01, 0.008, 0.06),
			aimKickRot = Vector3.new(0.4, 0.45, 1.1),
			recoilTime = 0.11,
			punch = 0.7,
			flashScale = 1.25,
			eject = Vector3.new(0.16, 0.03, -0.05),
			charger = Vector3.new(0.19, 0, -0.32),
			magGrab = Vector3.new(-0.1, -0.62, -0.22)
		}
	},
	MG60 = {
		id = "MG60",
		name = "MG-60",
		interval = 0.117,
		mag = 100,
		reload = { tactical = 2.3, empty = 3.4 },
		pace = { tactical = 2.19, empty = 2.07 },
		damage = {
			{ 0, 51.5 },
			{ 21.5, 34.3 },
			{ 75, 29.4 }
		},
		spread = {
			hip = 2.2,
			aim = 0.05,
			moving = 1.5,
			bloom = 0.2,
			bloomMax = 2.2,
			bloomDecay = 4
		},
		sound = 1.05,
		view = {
			weight = 1.4,
			hold = heavy(0.5, -0.78, -1.1), -- inferred equivalent call
			rightHand = Vector3.new(0, -0.41, 0.24),
			leftHand = Vector3.new(0, -0.32, -0.74),
			armThickness = 0.7,
			aimPoint = Vector3.new(0, 0.29, 0),
			aimDistance = 1.008,
			aimFov = 45.2,
			aimMove = 0.45,
			reach = 3.9,
			sprintHold = sprintHold,
			hipKick = Vector3.new(0.035, 0.018, 0.34),
			hipKickRot = Vector3.new(1.6, 0.9, 2.2),
			aimKick = Vector3.new(0.012, 0.01, 0.08),
			aimKickRot = Vector3.new(0.5, 0.45, 1.8),
			recoilTime = 0.15,
			punch = 0.9,
			flashScale = 1.45,
			eject = Vector3.new(0.17, 0, -0.1),
			charger = Vector3.new(0.19, -0.02, -0.25),
			magGrab = Vector3.new(-0.1, -0.6, -0.22)
		}
	},
	KT8 = {
		id = "KT8",
		name = "KT-8",
		interval = 0.109,
		mag = 60,
		reload = { tactical = 1.7, empty = 2.6 },
		pace = { tactical = 1.627, empty = 1.584 },
		damage = {
			{ 0, 41.2 },
			{ 37, 34.3 },
			{ 75, 29.4 }
		},
		spread = {
			hip = 1.9,
			aim = 0.05,
			moving = 1.2,
			bloom = 0.11,
			bloomMax = 1.3,
			bloomDecay = 4.5
		},
		sound = 0.88,
		view = {
			weight = 1.15,
			hold = heavy(0.52, -0.8, -1.12), -- inferred equivalent call
			rightHand = Vector3.new(0, -0.41, 0.24),
			leftHand = Vector3.new(0, -0.3, -0.62),
			armThickness = 0.7,
			aimPoint = Vector3.new(0, 0.3, 0),
			aimDistance = 1.008,
			aimFov = 45.2,
			aimMove = 0.7,
			reach = 3.8,
			sprintHold = sprintHold,
			hipKick = Vector3.new(0.025, 0.012, 0.22),
			hipKickRot = Vector3.new(1, 0.6, 1.2),
			aimKick = Vector3.new(0.008, 0.006, 0.05),
			aimKickRot = Vector3.new(0.3, 0.3, 0.9),
			recoilTime = 0.11,
			punch = 0.6,
			flashScale = 1.15,
			eject = Vector3.new(0.15, 0.03, -0.05),
			charger = Vector3.new(0.165, 0, -0.3),
			magGrab = Vector3.new(0, -0.66, -0.19)
		}
	},
	NX68 = {
		id = "NX68",
		name = "NX-68",
		interval = 0.092,
		mag = 50,
		reload = { tactical = 2.05, empty = 3.15 },
		pace = { tactical = 1.958, empty = 1.916 },
		damage = {
			{ 0, 41.2 },
			{ 60, 34.3 }
		},
		spread = {
			hip = 2.3,
			aim = 0.05,
			moving = 1.4,
			bloom = 0.16,
			bloomMax = 1.8,
			bloomDecay = 4
		},
		sound = 0.97,
		view = {
			weight = 1.28,
			hold = heavy(0.52, -0.8, -1.12), -- inferred equivalent call
			rightHand = Vector3.new(0, -0.41, 0.24),
			leftHand = Vector3.new(-0.05, -0.3, -0.62),
			armThickness = 0.7,
			aimPoint = Vector3.new(0, 0.3, 0),
			aimDistance = 1.008,
			aimFov = 45.2,
			aimMove = 0.58,
			reach = 3.8,
			sprintHold = sprintHold,
			hipKick = Vector3.new(0.03, 0.015, 0.28),
			hipKickRot = Vector3.new(1.3, 0.9, 1.6),
			aimKick = Vector3.new(0.01, 0.008, 0.065),
			aimKickRot = Vector3.new(0.4, 0.45, 1.2),
			recoilTime = 0.12,
			punch = 0.78,
			flashScale = 1.3,
			eject = Vector3.new(0.16, 0.02, -0.06),
			charger = Vector3.new(0.18, -0.02, -0.3),
			magGrab = Vector3.new(-0.1, -0.54, -0.22)
		}
	},
	GR240 = {
		id = "GR240",
		name = "GR-240",
		interval = 0.11,
		mag = 50,
		reload = { tactical = 2.4, empty = 3.5 },
		pace = { tactical = 2.288, empty = 2.127 },
		damage = {
			{ 0, 51.5 },
			{ 30, 41.2 },
			{ 75, 34.3 }
		},
		spread = {
			hip = 2.4,
			aim = 0.05,
			moving = 1.6,
			bloom = 0.2,
			bloomMax = 2.3,
			bloomDecay = 4
		},
		sound = 1.08,
		view = {
			weight = 1.42,
			hold = heavy(0.5, -0.78, -1.1), -- inferred equivalent call
			rightHand = Vector3.new(0, -0.41, 0.24),
			leftHand = Vector3.new(-0.05, -0.3, -0.67),
			armThickness = 0.7,
			aimPoint = Vector3.new(0, 0.31, 0),
			aimDistance = 1.008,
			aimFov = 45.2,
			aimMove = 0.42,
			reach = 3.9,
			sprintHold = sprintHold,
			hipKick = Vector3.new(0.036, 0.018, 0.35),
			hipKickRot = Vector3.new(1.7, 0.9, 2.3),
			aimKick = Vector3.new(0.012, 0.01, 0.085),
			aimKickRot = Vector3.new(0.5, 0.45, 1.9),
			recoilTime = 0.15,
			punch = 0.95,
			flashScale = 1.5,
			eject = Vector3.new(0.17, 0, -0.1),
			charger = Vector3.new(0.195, -0.02, -0.25),
			magGrab = Vector3.new(-0.1, -0.62, -0.24)
		}
	}
}

function LMGSpecs.of(p: string)
	return LMGSpecs.LIST[p]
end

return LMGSpecs