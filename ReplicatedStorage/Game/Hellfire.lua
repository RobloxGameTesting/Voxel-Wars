local MapBuilder = require(script.Parent.Parent:WaitForChild("Voxel"):WaitForChild("MapBuilder"))

local Hellfire = {
	TOOL = "Hellfire",
	WEAPON = "Hellfire",
	START_HEIGHT = 1100,
	FOV = 55,
	CUT_IN = 0.6,
	HANG = 0.5,
	HANG_SPEED = 6,
	RAMP = 1,
	CRUISE = 100,
	CRUISE_ACCEL = 8,
	BOOST_SPEED = 220,
	STEER_PER_HEIGHT = 1,
	STEER_MIN = 20,
	STEER_RESPONSE = 12,
	MAX_TIME = 22,
	MAX_SPREAD = 700,
	BLAST_SIZE = 2.6,
	BLAST_DAMAGE = 900,
	BLAST_REACH = 1.45,
	RING = 40,
	HOLD = 0.8,
	CUT_OUT = 0.35,
	POSE_RATE = 20,
	QUIET = 1.2,
	SLACK = 1.35,
	SLACK_STUDS = 10
}

function Hellfire.fallSpeed(p: number, p2: number?)
	if p2 and p2 <= p then
		return Hellfire.BOOST_SPEED
	end

	if p < Hellfire.HANG then
		return Hellfire.HANG_SPEED
	end

	local v = (p - Hellfire.HANG) / Hellfire.RAMP

	if v < 1 then
		local v2 = v * v * (3 - 2 * v)
		return Hellfire.HANG_SPEED + (Hellfire.CRUISE - Hellfire.HANG_SPEED) * v2
	end

	return Hellfire.CRUISE + Hellfire.CRUISE_ACCEL * (p - Hellfire.HANG - Hellfire.RAMP)
end

function Hellfire.steerSpeed(p: number)
	return (math.max(Hellfire.STEER_MIN, Hellfire.STEER_PER_HEIGHT * p))
end

function Hellfire.limits(p: number, flag: boolean, p2: number)
	local v

	if flag then
		v = Hellfire.BOOST_SPEED
	else
		v = Hellfire.fallSpeed(p, nil)
	end

	return Hellfire.steerSpeed((math.max(p2, 0))), (math.max(v, Hellfire.fallSpeed(p, nil)))
end

function Hellfire.startAt(vector3: Vector3, _: Vector3)
	local MAP_BOUNDS = MapBuilder.MAP_BOUNDS
	local midpoint = (MAP_BOUNDS.min + MAP_BOUNDS.max) / 2
	return (Vector3.new(midpoint.X, vector3.Y + Hellfire.START_HEIGHT, midpoint.Z))
end

function Hellfire.heading(vector3: Vector3)
	local vector3_2 = Vector3.new(vector3.X, 0, vector3.Z)

	if vector3_2.Magnitude < 0.001 then
		return nil
	end

	if math.abs(vector3_2.X) > math.abs(vector3_2.Z) then
		return Vector3.new(1, 0, 0) * math.sign(vector3_2.X)
	end

	return Vector3.new(0, 0, 1) * math.sign(vector3_2.Z)
end

return Hellfire