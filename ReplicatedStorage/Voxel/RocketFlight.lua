--!native
local RocketFlight = {}
RocketFlight.EJECT_SPEED = 120
RocketFlight.IGNITE = 0.05
RocketFlight.ACCEL = 1500
RocketFlight.MAX_SPEED = 300
RocketFlight.GRAVITY = 9
RocketFlight.DROP_DELAY = 0.3
local EJECT_SPEED = RocketFlight.EJECT_SPEED
local ignite = RocketFlight.IGNITE
local accel = RocketFlight.ACCEL
local MAX_SPEED = RocketFlight.MAX_SPEED
local gravity = RocketFlight.GRAVITY
local v = (MAX_SPEED - EJECT_SPEED) / accel
local v2 = EJECT_SPEED * ignite
local v3 = v2 + EJECT_SPEED * v + 0.5 * accel * v * v

local function along(p: number) -- 1 equivalent call inferred from this helper
	if p <= ignite then
		return EJECT_SPEED * p, EJECT_SPEED
	end

	local v4 = p - ignite

	if v4 <= v then
		return v2 + EJECT_SPEED * v4 + 0.5 * accel * v4 * v4, EJECT_SPEED + accel * v4
	end

	return v3 + MAX_SPEED * (v4 - v), MAX_SPEED
end

function RocketFlight.at(vector3: Vector3, vector3_2: Vector3, p: number)
	local v4, v5 = along(p) -- inferred equivalent call
	local v6 = math.max(p - RocketFlight.DROP_DELAY, 0)
	return
		vector3 + vector3_2 * v4 - Vector3.new(0, 0.5 * gravity * v6 * v6, 0),
		vector3_2 * v5 - Vector3.new(0, gravity * v6, 0)
end

function RocketFlight.timeTo(p: number)
	if p <= v2 then
		return p / EJECT_SPEED
	end

	if p <= v3 then
		local v4 = v2 - p
		return ignite + (-EJECT_SPEED + math.sqrt(EJECT_SPEED * EJECT_SPEED - 2 * accel * v4)) / accel
	end

	return ignite + v + (p - v3) / MAX_SPEED
end

function RocketFlight.drop(p: number)
	local v4 = math.max(p - RocketFlight.DROP_DELAY, 0)
	return 0.5 * gravity * v4 * v4
end

return RocketFlight