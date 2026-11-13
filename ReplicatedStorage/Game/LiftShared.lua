local LiftShared = {}
LiftShared.CLOSE = 0.9
LiftShared.OPEN = 0.9
LiftShared.SPEED = 16
LiftShared.RIDE_MIN = 2.5
LiftShared.RIDE_MAX = 6
LiftShared.CALL_DEPTH = 9
LiftShared.CALL_SIDE = 6
local v = {
	pos = "Pos",
	rise = "Rise",
	face = "Face",
	hu = "HU",
	hv = "HV",
	height = "Height",
	doorW = "DoorW",
	doorH = "DoorH",
	wall = "Wall"
}

function LiftShared.rideTime(p: number)
	return (math.clamp(p / LiftShared.SPEED, LiftShared.RIDE_MIN, LiftShared.RIDE_MAX))
end

function LiftShared.write(instance, p)
	for k, v2 in v do
		local v3 = p[k]
		assert(v3 ~= nil, "[Lifts] a lift row has no " .. k)
		instance:SetAttribute(v2, v3)
	end
end

function LiftShared.read(instance)
	local attributes = {}

	for k, attributeName in v do
		local attribute = instance:GetAttribute(attributeName)
		assert(attribute ~= nil, "[Lifts] " .. instance.Name .. " has no " .. attributeName)
		attributes[k] = attribute
	end

	return attributes
end

local function frame(data, p: number, vector3: Vector3) -- 2 equivalent calls inferred from this helper
	local v2 = vector3 - data.pos
	return v2.X * data.face.X + v2.Z * data.face.Z, v2.Z * data.face.X - v2.X * data.face.Z, v2.Y - p * data.rise
end

function LiftShared.inCar(data, p: number, vector3: Vector3, p2: number): boolean
	local v2, v3, v4 = frame(data, p, vector3) -- inferred equivalent call
	return -1 - p2 < v4 and v4 < data.height + p2 and math.abs(v2) <= data.hv + p2 and math.abs(v3) <= data.hu + p2
end

function LiftShared.zone(data, p: number, vector3: Vector3, p2: number): nil | string
	if LiftShared.inCar(data, p, vector3, p2) then
		return "car"
	end

	local v2 = 1 - p

	if LiftShared.inCar(data, v2, vector3, p2) then
		return "call"
	end

	local v3, v4, v5 = frame(data, v2, vector3) -- inferred equivalent call

	if
		-1 - p2 < v5
		and v5 < data.height + p2
		and data.hv < v3
		and v3 <= data.hv + data.wall + LiftShared.CALL_DEPTH + p2
		and math.abs(v4) <= LiftShared.CALL_SIDE + p2
	then
		return "call"
	end

	return nil
end

return LiftShared