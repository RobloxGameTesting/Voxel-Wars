local MapBuilder = require(script.Parent.Parent:WaitForChild("Voxel"):WaitForChild("MapBuilder"))

local Gunship = {
	["TOOL"] = nil,
	["TOOL"] = nil,
	["TOOL"] = nil,
	TOOL = "Gunship",
	CUT_IN = 1,
	DURATION = 28,
	CUT_OUT = 0.4,
	HEIGHT = 560,
	RADIUS = 520,
	PERIOD = 100,
	AIM_CONE = 34,
	AIM_SLACK = 4,
	SHELL_SPEED = 2600,
	SHOT_SLACK = 0.04,
	VIEW_RANGE = 250,
	GUNS = {
		{
			key = "heavy",
			name = "HEAVY",
			weapon = "GunshipHeavy",
			fov = 38,
			rounds = 1,
			interval = 0,
			reload = 9,
			size = 1.9,
			damage = 900,
			reach = 1.5,
			kind = "Airstrike",
			shake = 1
		},
		{
			key = "cannon",
			name = "CANNON",
			weapon = "GunshipCannon",
			fov = 27,
			rounds = 4,
			interval = 0.4,
			reload = 3.75,
			size = 1.15,
			damage = 160,
			reach = 1.25,
			kind = nil,
			shake = 0.35
		},
		{
			key = "auto",
			name = "AUTOGUN",
			weapon = "GunshipGun",
			fov = 16,
			rounds = 30,
			interval = 0.1,
			reload = 1.8,
			size = 0.55,
			damage = 38,
			reach = 1.1,
			kind = nil,
			shake = 0.08
		}
	},
	WEAPONS = {}
}

for _, v in Gunship.GUNS do
	Gunship.WEAPONS[v.weapon] = true
end

function Gunship.centre(p: number)
	local MAP_BOUNDS = MapBuilder.MAP_BOUNDS
	local midpoint = (MAP_BOUNDS.min + MAP_BOUNDS.max) / 2
	return (Vector3.new(midpoint.X, p, midpoint.Z))
end

function Gunship.phaseFor(vector3: Vector3, vector3_2: Vector3)
	local vector3_3 = Vector3.new(vector3_2.X - vector3.X, 0, vector3_2.Z - vector3.Z)

	if vector3_3.Magnitude > 1 then
		return (math.atan2(vector3_3.Z, vector3_3.X))
	end

	return 0
end

function Gunship.planeAt(vector3: Vector3, p: number, p2: number)
	local v = 6.283185307179586 / Gunship.PERIOD
	local v2 = p + v * p2
	local v3 = math.cos(v2)
	local v4 = math.sin(v2)
	return
		vector3 + Vector3.new(v3 * Gunship.RADIUS, Gunship.HEIGHT, v4 * Gunship.RADIUS),
		Vector3.new(-v4, 0, v3) * (Gunship.RADIUS * v)
end

function Gunship.inCone(vector3: Vector3, vector3_2: Vector3, vector3_3: Vector3, p: number): boolean
	return (vector3 - vector3_2).Unit:Dot(vector3_3.Unit) >= math.cos((math.rad(Gunship.AIM_CONE + p)))
end

return Gunship