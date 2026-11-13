--!native
local Ballistics = {}
Ballistics.SPEED = 1700
Ballistics.SNIPER_MIN = 1600
Ballistics.RIFLE_SPEED = 1600
Ballistics.RIFLE_ARC = { gravity = 49, drag = 0.0014 }
Ballistics.STRAIGHT_MIN = 2000
Ballistics.GRAVITY = 24.525
Ballistics.DRAG = 0.0014
Ballistics.BOT_ARC = { gravity = Ballistics.GRAVITY, drag = Ballistics.DRAG }
Ballistics.ZERO = 250
Ballistics.MAX_TIME = 3
Ballistics.STEP = 1 / 60

Ballistics.DMR_SPEED = 1500

local function sniperRound(p: number?, p2): boolean -- 7 equivalent calls inferred from this helper
	if p2 then
		return true
	end

	local v = p or Ballistics.SPEED
	return Ballistics.SNIPER_MIN <= v and v < Ballistics.STRAIGHT_MIN
end

local function along(p: number, p2: number, p3) -- 2 equivalent calls inferred from this helper
	local drag = if p3 then p3.drag else Ballistics.DRAG
	return math.log(1 + drag * p2 * p) / drag
end

local function fall(p: number, p2: number, p3) -- 3 equivalent calls inferred from this helper
	local v = if p3 then p3.drag else Ballistics.DRAG
	local v2 = v * p2
	local v3 = if p3 then p3.gravity else Ballistics.GRAVITY
	return v3 * (p * p / 4 + (v2 * p - math.log(1 + v2 * p)) / (2 * v2 * v2))
end

function Ballistics.flightTime(p: number, p2: number?, p3)
	local v = p2 or Ballistics.SPEED

	if not sniperRound(p2, p3) then -- inferred equivalent call
		return p / v
	end

	local drag = if p3 then p3.drag else Ballistics.DRAG
	return (math.exp(drag * p) - 1) / (drag * v)
end

function Ballistics.travelled(p: number, p2: number?, p3)
	local v = p2 or Ballistics.SPEED

	if not sniperRound(p2, p3) then -- inferred equivalent call
		return v * p
	end

	return along(p, v, p3) -- inferred equivalent call
end

function Ballistics.speedAt(p: number, p2: number?, p3)
	local v = p2 or Ballistics.SPEED

	if not sniperRound(p2, p3) then -- inferred equivalent call
		return v
	end

	local v2 = if p3 then p3.drag else Ballistics.DRAG
	return v * math.exp(-v2 * p)
end

function Ballistics.position(vector3: Vector3, vector3_2: Vector3, p: number, p2: number?, p3)
	local v = p2 or Ballistics.SPEED

	if not sniperRound(p2, p3) then -- inferred equivalent call
		return vector3 + vector3_2 * (v * p)
	end

	return vector3 + vector3_2 * along(p, v, p3) - Vector3.new(0, fall(p, v, p3), 0) -- inferred equivalent call
end

function Ballistics.launch(vector3: Vector3, vector3_2: Vector3, p: number?, p2)
	local vector3_3 = vector3_2 - vector3

	if not sniperRound(p, p2) then -- inferred equivalent call
		return vector3_3.Unit
	end

	local flightTime = Ballistics.flightTime(vector3_3.Magnitude, p, p2)
	return (vector3_3 + Vector3.new(0, fall(flightTime, p or Ballistics.SPEED, p2), 0)).Unit -- inferred equivalent call
end

function Ballistics.zeroed(vector3: Vector3, vector3_2: Vector3, p: number?, p2)
	return Ballistics.launch(vector3, vector3 + vector3_2 * Ballistics.ZERO, p, p2)
end

function Ballistics.holdover(p: number, p2: number?, p3)
	if not sniperRound(p2, p3) then -- inferred equivalent call
		return 0
	end

	local v = p2 or Ballistics.SPEED
	local function angle(p4: number) -- 2 equivalent calls inferred from this helper
		return fall(Ballistics.flightTime(p4, p2, p3), v, p3) / p4 -- inferred equivalent call
	end

	return angle(math.max(p, 1)) - angle(Ballistics.ZERO) -- inferred equivalent call
end

function Ballistics.trace(vector3: Vector3, vector3_2: Vector3, callback, p: number?, p2: number?, p3)
	local v = 0
	local v2 = p2 or Ballistics.MAX_TIME

	if sniperRound(p, p3) then -- inferred equivalent call
		local v3 = vector3

		while v < v2 do
			local v4 = v + Ballistics.STEP
			local position = Ballistics.position(vector3, vector3_2, v4, p, p3)
			local v5 = position - v3
			local v6 = callback(v3, v5)

			if v6 then
				return v6, v + Ballistics.STEP * math.clamp((v6 - v3).Magnitude / v5.Magnitude, 0, 1)
			end

			v3 = position
			v = v4
		end

		return v3, v
	else
		local v3 = vector3_2 * ((p or Ballistics.SPEED) * v2)
		local v4 = callback(vector3, v3)

		if v4 then
			return v4, v2 * math.clamp((v4 - vector3).Magnitude / v3.Magnitude, 0, 1)
		end

		return vector3 + v3, v2
	end
end

return Ballistics