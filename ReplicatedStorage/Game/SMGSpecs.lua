require(script.Parent:WaitForChild("RifleSpecs"))

local SMGSpecs = {}

local newVector3 = Vector3.new
local sprintHold = CFrame.new(-0.2, -1.2, -1.6) * CFrame.Angles(
	-0.5113814708343386,
	1.08035880698449,
	0.46600291028248597
)
local function hold(p: number, p2: number, p3: number) -- 5 equivalent calls inferred from this helper
	return CFrame.new(p, p2, p3) * CFrame.Angles(0.03490658503988659, 0.03490658503988659, 0.017453292519943295)
end

SMGSpecs.LIST = {
	KP50 = {
		id = "KP50",
		name = "KP-50",
		interval = 0.075,
		mag = 50,
		reload = { tactical = 1.9, empty = 2.6 },
		pace = { tactical = 1.84, empty = 1.596 },
		damage = {
			{ 0, 34.3 },
			{ 21.5, 25.8 },
			{ 37, 22.9 },
			{ 75, 17.2 }
		},
		spread = {
			hip = 1.1,
			aim = 0.05,
			moving = 0.45,
			bloom = 0.08,
			bloomMax = 1.2,
			bloomDecay = 6
		},
		sound = 1,
		view = {
			weight = 0.75,
			hold = hold(0.62, -0.74, -1.5), -- inferred equivalent call
			rightHand = Vector3.new(0, -0.3, 0.17),
			leftHand = Vector3.new(0, -0.35, -0.44),
			armThickness = 0.5,
			aimPoint = Vector3.new(0, 0.295, 0),
			aimDistance = 0.961,
			aimFov = 45.2,
			aimMove = 0.87,
			reach = 2.4,
			sprintHold = sprintHold,
			hipKick = Vector3.new(0.014, 0.008, 0.13),
			hipKickRot = Vector3.new(0.6, 0.5, 1),
			aimKick = Vector3.new(0.005, 0.003, 0.035),
			aimKickRot = Vector3.new(0.2, 0.25, 0.7),
			recoilTime = 0.065,
			punch = 0.32,
			flashScale = 0.75,
			eject = Vector3.new(0, -0.17, 0.42),
			charger = Vector3.new(-0.1, -0.04, -0.4),
			magGrab = Vector3.new(0, 0.16, 0.2),
			magOut = Vector3.new(0, 0.5, 1)
		}
	},
	HM45 = {
		id = "HM45",
		name = "HM-45",
		interval = 0.0945,
		mag = 30,
		reload = { tactical = 1.5, empty = 2.2 },
		pace = { tactical = 1.462, empty = 1.355 },
		damage = {
			{ 0, 51.5 },
			{ 9.5, 41.2 },
			{ 21.5, 29.4 },
			{ 37, 25.8 },
			{ 75, 20.6 }
		},
		spread = {
			hip = 1.5,
			aim = 0.05,
			moving = 0.6,
			bloom = 0.18,
			bloomMax = 1.8,
			bloomDecay = 5
		},
		sound = 1.1,
		view = {
			weight = 0.7,
			hold = hold(0.62, -0.74, -1.6), -- inferred equivalent call
			rightHand = Vector3.new(0, -0.3, 0.17),
			leftHand = Vector3.new(0, -0.41, -0.55),
			armThickness = 0.5,
			aimPoint = Vector3.new(0, 0.25, 0),
			aimDistance = 0.961,
			aimFov = 45.2,
			aimMove = 0.82,
			reach = 2.6,
			sprintHold = sprintHold,
			hipKick = Vector3.new(0.024, 0.013, 0.2),
			hipKickRot = Vector3.new(1.1, 0.8, 1.6),
			aimKick = Vector3.new(0.008, 0.006, 0.05),
			aimKickRot = Vector3.new(0.35, 0.35, 1.1),
			recoilTime = 0.09,
			punch = 0.5,
			flashScale = 1,
			eject = Vector3.new(0.09, 0.02, -0.02),
			charger = Vector3.new(-0.115, 0.04, -0.42),
			magGrab = Vector3.new(0, -0.66, -0.24)
		}
	},
	TK17 = {
		id = "TK17",
		name = "TK-17",
		interval = 0.0625,
		mag = 17,
		reload = { tactical = 1.4, empty = 2.1 },
		pace = { tactical = 1.368, empty = 1.295 },
		damage = {
			{ 0, 34.3 },
			{ 9.5, 29.4 },
			{ 21.5, 22.9 },
			{ 37, 18.4 },
			{ 75, 15 }
		},
		spread = {
			hip = 1.3,
			aim = 0.05,
			moving = 0.55,
			bloom = 0.14,
			bloomMax = 1.8,
			bloomDecay = 6
		},
		sound = 1,
		view = {
			weight = 0.65,
			hold = hold(0.62, -0.74, -1.5), -- inferred equivalent call
			rightHand = Vector3.new(0, -0.3, 0.17),
			leftHand = Vector3.new(0, -0.33, -0.47),
			armThickness = 0.5,
			aimPoint = Vector3.new(0, 0.23, 0),
			aimDistance = 0.961,
			aimFov = 45.2,
			aimMove = 0.88,
			reach = 2.4,
			sprintHold = sprintHold,
			hipKick = Vector3.new(0.016, 0.01, 0.14),
			hipKickRot = Vector3.new(0.7, 0.9, 1.2),
			aimKick = Vector3.new(0.006, 0.004, 0.04),
			aimKickRot = Vector3.new(0.25, 0.35, 0.8),
			recoilTime = 0.055,
			punch = 0.3,
			flashScale = 0.8,
			eject = Vector3.new(0.09, 0.04, -0.08),
			charger = Vector3.new(-0.1, 0.06, -0.2),
			magGrab = Vector3.new(0, -0.53, -0.2)
		}
	},
	PD46 = {
		id = "PD46",
		name = "PD-46",
		interval = 0.069,
		mag = 30,
		reload = { tactical = 1.3, empty = 2.2 },
		pace = { tactical = 1.274, empty = 1.355 },
		damage = {
			{ 0, 29.4 },
			{ 37, 25.8 },
			{ 75, 20.6 }
		},
		spread = {
			hip = 1.2,
			aim = 0.05,
			moving = 0.45,
			bloom = 0.07,
			bloomMax = 1.1,
			bloomDecay = 6
		},
		sound = 1,
		view = {
			weight = 0.62,
			hold = hold(0.62, -0.72, -1.45), -- inferred equivalent call
			rightHand = Vector3.new(0, -0.3, 0.17),
			leftHand = Vector3.new(0, -0.3, -0.36),
			armThickness = 0.5,
			aimPoint = Vector3.new(0, 0.225, 0),
			aimDistance = 0.961,
			aimFov = 45.2,
			aimMove = 0.9,
			reach = 2.3,
			sprintHold = sprintHold,
			hipKick = Vector3.new(0.012, 0.007, 0.11),
			hipKickRot = Vector3.new(0.5, 0.4, 0.9),
			aimKick = Vector3.new(0.004, 0.003, 0.03),
			aimKickRot = Vector3.new(0.18, 0.2, 0.6),
			recoilTime = 0.06,
			punch = 0.28,
			flashScale = 0.7,
			eject = Vector3.new(0.075, 0.05, -0.1),
			charger = Vector3.new(0, 0.09, 0.17),
			magGrab = Vector3.new(0, -0.62, 0.25),
			magOut = Vector3.new(0, -0.97, 0.24)
		}
	},
	SP44 = {
		id = "SP44",
		name = "SP-44",
		interval = 0.0833,
		mag = 44,
		reload = { tactical = 1.7, empty = 2.5 },
		pace = { tactical = 1.651, empty = 1.536 },
		damage = {
			{ 0, 41.2 },
			{ 9.5, 34.3 },
			{ 30, 29.4 },
			{ 50, 22.9 }
		},
		spread = {
			hip = 1.2,
			aim = 0.05,
			moving = 0.5,
			bloom = 0.1,
			bloomMax = 1.4,
			bloomDecay = 5
		},
		sound = 1,
		view = {
			weight = 0.78,
			hold = hold(0.62, -0.74, -1.55), -- inferred equivalent call
			rightHand = Vector3.new(0, -0.3, 0.17),
			leftHand = Vector3.new(0, -0.29, -0.45),
			armThickness = 0.5,
			aimPoint = Vector3.new(0, 0.26, 0),
			aimDistance = 0.961,
			aimFov = 45.2,
			aimMove = 0.84,
			reach = 2.5,
			sprintHold = sprintHold,
			hipKick = Vector3.new(0.015, 0.009, 0.14),
			hipKickRot = Vector3.new(0.6, 0.5, 1),
			aimKick = Vector3.new(0.005, 0.004, 0.035),
			aimKickRot = Vector3.new(0.22, 0.25, 0.75),
			recoilTime = 0.075,
			punch = 0.36,
			flashScale = 0.9,
			eject = Vector3.new(0.075, 0.04, -0.05),
			charger = Vector3.new(-0.08, 0.04, -0.25),
			magGrab = Vector3.new(0, -0.26, -0.42),
			magOut = Vector3.new(0, -0.8, -0.6)
		}
	}
}

function SMGSpecs.of(p: string)
	return SMGSpecs.LIST[p]
end

return SMGSpecs