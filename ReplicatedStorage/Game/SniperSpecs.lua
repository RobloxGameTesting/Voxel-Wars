local SniperSpecs = {}

local newVector3 = Vector3.new
local cframe = CFrame.Angles(0.03490658503988659, 0.03490658503988659, 0.017453292519943295)
local sprintHold = CFrame.new(-0.15, -1.35, -2) * CFrame.Angles(
	-0.5113814708343386,
	1.08035880698449,
	0.46600291028248597
)

SniperSpecs.SNIPER_CURVE = {
	{ 36, 160 },
	{ 54, 200 },
	{ 75, 200 },
	{ 100, 124 }
}

SniperSpecs.LIST = {
	RX10 = {
		id = "RX10",
		name = "RX-10",
		interval = 1.3,
		bolt = 1.515,
		boltDelay = 0.25,
		boltOpenHold = 0.117,
		boltEndHold = 0,
		mag = 5,
		reload = { tactical = 2.33, empty = 2.15, chamber = 0.934 },
		pace = { tactical = 1.617, empty = 1.5 },
		damage = {
			body = 160,
			curve = {
				{ 54, 160 },
				{ 75, 200 },
				{ 100, 200 },
				{ 133, 124 }
			}
		},
		speed = 1750,
		arc = { gravity = 49, drag = 0.0014 },
		spread = { hip = 3.352, moving = 0.838, jump = 2.514 },
		sound = 1.05,
		scopedBolt = true,
		view = {
			weight = 0.9,
			hold = CFrame.new(0.62, -0.86, -1.75) * cframe,
			rightHand = Vector3.new(0, -0.31, 0.3),
			leftHand = Vector3.new(-0.03, -0.2, -0.95),
			ironLeftHand = Vector3.new(-0.03, -0.42, -1.5),
			aimPoint = Vector3.new(0, 0.27, 0.5),
			aimDistance = 1.335,
			aimFov = 9.5,
			aimTime = 0.34,
			aimMove = 0.4,
			reach = 4.75,
			sprintHold = sprintHold,
			hipKick = Vector3.new(0.04, 0.06, 0.5),
			hipKickRot = Vector3.new(8, 2, 4),
			aimKick = Vector3.new(0.004, 0.012, 0.12),
			aimKickRot = Vector3.new(1.2, 0.4, 1),
			recoilTime = 0.45,
			punch = 1.9,
			flashScale = 1.4,
			eject = Vector3.new(0.09, 0.03, -0.02),
			knobGrab = Vector3.new(0.25, -0.15, 0.43),
			boltTravel = 0.2,
			magGrab = Vector3.new(-0.02, -0.41, -0.1),
			scope = { at = 0.85, time = 0.145, eyeFov = 78, easeOut = true },
			postScale = 1
		}
	},
	SC11 = {
		id = "SC11",
		name = "SC-11",
		interval = 1.2,
		bolt = 1.212,
		boltDelay = 0.25,
		boltOpenHold = 0.14,
		boltEndHold = 0.084,
		mag = 10,
		reload = { tactical = 1.68, empty = 2.15, chamber = 0.9 },
		pace = { tactical = 1.167, empty = 1.5 },
		damage = {
			body = 124,
			curve = {
				{ 21, 124 },
				{ 75, 116 }
			}
		},
		speed = 1750,
		arc = { gravity = 49, drag = 0.0014 },
		spread = { hip = 2.432, moving = 0.608, jump = 1.824 },
		sound = 0.85,
		scopedBolt = true,
		view = {
			weight = 0.9,
			hold = CFrame.new(0.62, -0.84, -1.65) * cframe,
			rightHand = Vector3.new(0, -0.31, 0.3),
			leftHand = Vector3.new(-0.03, -0.17, -0.8),
			ironLeftHand = Vector3.new(-0.03, -0.4, -1.25),
			aimPoint = Vector3.new(0, 0.27, 0.44),
			aimDistance = 0.858,
			aimFov = 14,
			aimTime = 0.26,
			aimMove = 0.65,
			reach = 4,
			sprintHold = sprintHold,
			hipKick = Vector3.new(0.03, 0.04, 0.32),
			hipKickRot = Vector3.new(5, 1.4, 3),
			aimKick = Vector3.new(0.002, 0.006, 0.07),
			aimKickRot = Vector3.new(0.6, 0.2, 0.5),
			recoilTime = 0.32,
			punch = 1.2,
			flashScale = 1.05,
			eject = Vector3.new(0.08, 0.03, -0.02),
			knobGrab = Vector3.new(0.25, -0.15, 0.43),
			boltTravel = 0.16,
			magGrab = Vector3.new(-0.02, -0.43, -0.08),
			scope = { at = 0.85, time = 0.135, eyeFov = 78, easeOut = true },
			postScale = 0.5
		}
	},
	VX50 = {
		id = "VX50",
		name = "VX-50",
		interval = 1.8,
		bolt = 1.667,
		boltDelay = 0.3,
		boltOpenHold = 0.28,
		boltEndHold = 0.2,
		mag = 5,
		reload = { tactical = 2.52, empty = 2.75, chamber = 1.04 },
		pace = { tactical = 1.75, empty = 1.91 },
		damage = {
			body = 160,
			curve = {
				{ 45, 160 },
				{ 60, 200 },
				{ 130, 200 },
				{ 165, 124 }
			}
		},
		speed = 1000,
		arc = { gravity = 49, drag = 0.0008 },
		tracer = 2.2,
		spread = { hip = 4.848, moving = 1.212, jump = 3.636 },
		sound = 1.15,
		scopedBolt = true,
		view = {
			weight = 0.9,
			hold = CFrame.new(0.62, -0.86, -1.75) * cframe,
			rightHand = Vector3.new(0, -0.31, 0.3),
			leftHand = Vector3.new(-0.03, -0.25, -0.6),
			ironLeftHand = Vector3.new(-0.03, -0.47, -1.1),
			aimPoint = Vector3.new(0, 0.27, 0.5),
			aimDistance = 1.493,
			aimFov = 8.5,
			aimTime = 0.44,
			aimMove = 0.35,
			reach = 4.75,
			sprintHold = sprintHold,
			hipKick = Vector3.new(0.05, 0.07, 0.6),
			hipKickRot = Vector3.new(10, 2.4, 5),
			aimKick = Vector3.new(0.005, 0.014, 0.15),
			aimKickRot = Vector3.new(1.5, 0.5, 1.2),
			recoilTime = 0.55,
			punch = 2.4,
			flashScale = 1.8,
			eject = Vector3.new(0.09, 0.03, 0.76),
			knobGrab = Vector3.new(0.25, -0.15, 0.43),
			boltTravel = 0.2,
			magGrab = Vector3.new(-0.02, -0.5, 0.66),
			scope = { at = 0.85, time = 0.16, eyeFov = 78, easeOut = true },
			postScale = 1
		}
	}
}

function SniperSpecs.damageAt(list, p: number)
	if p <= list[1][1] then
		return list[1][2]
	end

	for i = 2, #list do
		local item = list[i - 1]
		local item2 = list[i]

		if p <= item2[1] then
			return item[2] + (item2[2] - item[2]) * (p - item[1]) / (item2[1] - item[1])
		end
	end

	return list[#list][2]
end

function SniperSpecs.of(p: string)
	return SniperSpecs.LIST[p]
end

return SniperSpecs