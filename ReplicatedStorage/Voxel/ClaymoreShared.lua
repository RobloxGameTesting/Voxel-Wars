local ClaymoreShared = {
	NAME = "Claymore",
	ATTR = "Claymores",
	MAX = 2,
	RECHARGE = 25,
	LIVE_MAX = 2,
	COOLDOWN = 0.6,
	PLACE_AHEAD = 3.5,
	PLACE_REACH = 9,
	PLACE_UP = 1.5,
	PLACE_DROP = 3,
	PLACE_SEARCH = 8,
	PLACE_CLEAR = 0.8,
	FLOOR = 0.6,
	ARM = 1.2,
	REACH = 6,
	HALF_ANGLE = 0.4886921905584123,
	NEAR = 0.4,
	BODY = 1,
	ABOVE = 6.5,
	BELOW = 2,
	SIZE = 0.55,
	DAMAGE = 240,
	BLAST_AHEAD = 2,
	BLAST_UP = 1.2,
	CHAIN = 0.12,
	FEET = 0.37,
	EMITTER = Vector3.new(0.555, 0.47, 0.1)
}

local v = math.tan(ClaymoreShared.HALF_ANGLE)

function ClaymoreShared.trips(cframe: CFrame, vector3: Vector3): boolean
	local pointToObjectSpace = cframe:PointToObjectSpace(vector3)
	local v2 = -pointToObjectSpace.Z

	if
		v2 < ClaymoreShared.NEAR
		or ClaymoreShared.REACH + ClaymoreShared.BODY < v2
		or (pointToObjectSpace.Y < -ClaymoreShared.BELOW or pointToObjectSpace.Y > ClaymoreShared.ABOVE)
	then
		return false
	end

	return math.abs(pointToObjectSpace.X) <= math.min(v2, ClaymoreShared.REACH) * v + ClaymoreShared.EMITTER.X + ClaymoreShared.BODY
end

function ClaymoreShared.frame(vector3: Vector3, vector3_2: Vector3, vector: Vector3)
	local v2 = vector - vector3_2 * vector:Dot(vector3_2)

	if v2.Magnitude < 0.05 then
		return nil
	end

	return CFrame.lookAlong(vector3, v2.Unit, vector3_2)
end

function ClaymoreShared.handle(cframe: CFrame)
	return cframe * CFrame.new(0, ClaymoreShared.FEET, 0) * CFrame.Angles(0, 3.141592653589793, 0)
end

function ClaymoreShared.laser(cframe: CFrame, p: number)
	local emitter = ClaymoreShared.EMITTER
	return
		ClaymoreShared.handle(cframe) * Vector3.new(emitter.X * -p, emitter.Y, emitter.Z),
		(cframe * CFrame.Angles(0, -p * ClaymoreShared.HALF_ANGLE, 0)).LookVector
end

ClaymoreShared.LASER_LENGTH = ClaymoreShared.REACH / math.cos(ClaymoreShared.HALF_ANGLE)

return ClaymoreShared