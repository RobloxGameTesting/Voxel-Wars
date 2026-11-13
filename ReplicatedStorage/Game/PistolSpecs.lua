local newVector3 = Vector3.new
local function hold(p: number, p2: number, p3: number) -- 2 equivalent calls inferred from this helper
	return CFrame.new(p, p2, p3) * CFrame.Angles(0.026179938779914945, 0.05235987755982989, -0.05235987755982989)
end

local sprintHold = CFrame.new(0.28, -0.95, -1.15) * CFrame.Angles(
	-0.8726646259971648,
	0.4886921905584123,
	0.3141592653589793
)

local PistolSpecs = {}

PistolSpecs.LIST = {
	SV20 = {
		id = "SV20",
		name = "SV-20",
		interval = 0.147,
		holdRepeat = 0.24,
		auto = false,
		mag = 20,
		reload = { tactical = 1.2, empty = 1.84 },
		pace = 1.165,
		damage = {
			{ 0, 40 },
			{ 15, 34 },
			{ 35, 29 },
			{ 55, 26 }
		},
		spread = {
			hip = 1,
			aim = 0.1,
			moving = 0.7,
			bloom = 0.3,
			bloomMax = 1.2,
			bloomDecay = 3.2
		},
		sound = 0.85,
		view = {
			weight = 0.6,
			hold = hold(0.45, -0.72, -1.5), -- inferred equivalent call
			rightHand = Vector3.new(0.014, -0.25, 0.59),
			leftHand = Vector3.new(-0.098, -0.27, 0.57),
			leftHip = Vector3.new(-1, -2.8, -0.6),
			aimPoint = Vector3.new(0, 0.276, 0.371),
			aimDistance = 0.75,
			aimFov = 55,
			aimMove = 0.82,
			aimOutTime = 0.1667,
			zoomIn = 0.2,
			zoomOut = 0.1667,
			reach = 1.95,
			sprintHold = sprintHold,
			hipKick = Vector3.new(0.013, 0.026, 0.1),
			hipKickRot = Vector3.new(7, 1.2, 2.5),
			aimKick = Vector3.new(0.004, 0.004, 0.045),
			aimKickRot = Vector3.new(0.35, 0.25, 0.8),
			recoilTime = 0.15,
			punch = 0.38,
			flashScale = 0.5,
			eject = Vector3.new(0.049, 0.172, 0.12),
			caseSize = Vector3.new(0.036, 0.036, 0.075),
			ejectVel = Vector3.new(3.4, 4, 1),
			slide = { travel = 0.15, time = 0.07 },
			slideGrip = Vector3.new(-0.17, 0.1, 0.42),
			magGrab = Vector3.new(-0.028, -0.586, 0.511),
			magOut = Vector3.new(0, -1.3313999, 0.43259996)
		}
	},
	ZK10 = {
		id = "ZK10",
		name = "ZK-10",
		interval = 0.0733,
		holdRepeat = 0.0733,
		auto = true,
		mag = 20,
		reload = { tactical = 1.36, empty = 2.07 },
		pace = 1.3,
		damage = {
			{ 0, 26 },
			{ 8, 24 },
			{ 15, 20 },
			{ 25, 17 },
			{ 40, 14 }
		},
		spread = {
			hip = 1.9,
			aim = 0.2,
			moving = 0.9,
			bloom = 0.32,
			bloomMax = 2,
			bloomDecay = 2.5
		},
		sound = 0.7,
		view = {
			weight = 0.6,
			hold = hold(0.45, -0.72, -1.5), -- inferred equivalent call
			rightHand = Vector3.new(0.014, -0.25, 0.58),
			leftHand = Vector3.new(-0.098, -0.27, 0.56),
			leftHip = Vector3.new(-1, -2.8, -0.6),
			aimPoint = Vector3.new(0, 0.24, 0.371),
			aimDistance = 1.278,
			aimFov = 38.28,
			aimMove = 0.8,
			aimOutTime = 0.1667,
			zoomIn = 0.2,
			zoomOut = 0.1667,
			reach = 1.95,
			sprintHold = sprintHold,
			hipKick = Vector3.new(0.01, 0.012, 0.07),
			hipKickRot = Vector3.new(3.5, 1, 1.5),
			aimKick = Vector3.new(0.003, 0.004, 0.035),
			aimKickRot = Vector3.new(0.35, 0.3, 0.6),
			recoilTime = 0.07,
			punch = 0.3,
			flashScale = 0.55,
			eject = Vector3.new(0.03, 0.17, 0.12),
			caseSize = Vector3.new(0.036, 0.036, 0.06),
			ejectVel = Vector3.new(1.4, 4.6, 0.6),
			slide = { travel = 0.09, time = 0.045 },
			slideGrip = Vector3.new(-0.15, 0.1, 0.24),
			magGrab = Vector3.new(-0.028, -0.51, -0.19),
			magOut = Vector3.new(0, -1.386, -0.1946)
		}
	}
}

function PistolSpecs.of(p: string)
	return PistolSpecs.LIST[p]
end

return PistolSpecs