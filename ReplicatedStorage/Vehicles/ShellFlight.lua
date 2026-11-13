local ShellFlight = {}
ShellFlight.GRAVITY = 24.525

local function along(p: number, p2) -- 1 equivalent call inferred from this helper
	return math.log(1 + p2.drag * p2.speed * p) / p2.drag
end

local function fall(p: number, p2) -- 2 equivalent calls inferred from this helper
	local v = p2.drag * p2.speed
	return ShellFlight.GRAVITY * (p * p / 4 + (v * p - math.log(1 + v * p)) / (2 * v * v))
end

function ShellFlight.flightTime(p: number, p2)
	return (math.exp(p2.drag * p) - 1) / (p2.drag * p2.speed)
end

function ShellFlight.drop(p: number, p2)
	return fall(ShellFlight.flightTime(p, p2), p2) -- inferred equivalent call
end

function ShellFlight.position(vector3: Vector3, vector3_2: Vector3, p: number, p2)
	return vector3 + vector3_2 * along(p, p2) - Vector3.new(0, fall(p, p2), 0) -- inferred equivalent call
end

function ShellFlight.trace(vector3: Vector3, vector3_2: Vector3, callback, p, p2: number)
	local v = vector3
	local v2 = 0

	while v2 < p.maxFlight do
		local v3 = math.min(v2 + p2, p.maxFlight)
		local position = ShellFlight.position(vector3, vector3_2, v3, p)
		local v4 = position - v
		local v5 = callback(v, v4)

		if v5 then
			return v5, v2 + (v3 - v2) * math.clamp((v5 - v).Magnitude / v4.Magnitude, 0, 1), true
		end

		v = position
		v2 = v3
	end

	return v, v2, false
end

return ShellFlight