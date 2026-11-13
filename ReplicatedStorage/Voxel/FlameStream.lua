--!native
local FlameStream = {}

FlameStream.SPRAY = {
	speed = 55,
	drag = 0,
	gravity = 16,
	life = 0.8,
	r0 = 0.35,
	r1 = 3.8
}
FlameStream.DRIP = {
	speed = 60,
	drag = 1.2,
	gravity = 28,
	life = 1.2,
	r0 = 0.2,
	r1 = 0.6
}
FlameStream.DRIP_SPREAD = { 0.6, 1.1 }

FlameStream.SPEED = FlameStream.SPRAY.speed
FlameStream.GRAVITY = FlameStream.SPRAY.gravity
FlameStream.LIFE = FlameStream.SPRAY.life
FlameStream.R0 = FlameStream.SPRAY.r0
FlameStream.R1 = FlameStream.SPRAY.r1
FlameStream.STEP = 0.04
FlameStream.PUFF = 0.1

function FlameStream.dripSpeed(p: number)
	local drip = FlameStream.DRIP
	return {
		speed = drip.speed * p,
		drag = drip.drag,
		gravity = drip.gravity,
		life = drip.life,
		r0 = drip.r0,
		r1 = drip.r1
	}
end

local function along(p, p2: number) -- 1 equivalent call inferred from this helper
	local drag = p.drag

	if drag > 0 then
		return p.speed * (1 - math.exp(-drag * p2)) / drag
	end

	return p.speed * p2
end

function FlameStream.at(vector3: Vector3, vector3_2: Vector3, p: number, p2)
	local v = p2 or FlameStream.SPRAY
	return vector3 + vector3_2 * along(v, p) - Vector3.new(0, 1, 0) * (0.5 * v.gravity * p * p) -- inferred equivalent call
end

function FlameStream.timeTo(p: number, p2)
	local v = p2 or FlameStream.SPRAY
	local drag = v.drag

	if drag <= 0 then
		return p / v.speed
	end

	local v2 = 1 - p * drag / v.speed

	if v2 > 0 then
		return -math.log(v2) / drag
	end

	return 1e999
end

function FlameStream.radius(p: number, p2)
	local v = p2 or FlameStream.SPRAY
	return v.r0 + (v.r1 - v.r0) * math.clamp(p / v.life, 0, 1)
end

function FlameStream.trace(vector3: Vector3, vector3_2: Vector3, callback, p)
	local v = p or FlameStream.SPRAY
	local life = v.life
	local v2 = vector3
	local v3 = 0
	local points = { vector3 }

	while v3 < life - 1e-6 do
		local v4 = math.min(v3 + FlameStream.STEP, life)
		local vector3_3 = FlameStream.at(vector3, vector3_2, v4, v)
		local v5 = vector3_3 - v2
		local magnitude = v5.Magnitude

		if magnitude > 0.0001 then
			local hit, normal, v6, surface = callback(v2, v5 / magnitude, magnitude)

			if hit and normal then
				local tEnd = v3 + (v4 - v3) * math.clamp(v6 / magnitude, 0, 1)
				table.insert(points, hit)
				return {
					points = points,
					tEnd = tEnd,
					hit = hit,
					normal = normal,
					surface = surface
				}
			end
		end

		table.insert(points, vector3_3)
		v2 = vector3_3
		v3 = v4
	end

	return {
		points = points,
		tEnd = life,
		hit = nil,
		normal = nil,
		surface = nil
	}
end

function FlameStream.closest(p, vector3: Vector3)
	local points = p.points
	local count = #points
	local v = 1e999
	local v2 = 0

	for i = 1, count - 1 do
		local point = points[i]
		local vector = points[i + 1] - point
		local dot = vector:Dot(vector)
		local v3 = not (dot > 1e-8) and 0 or math.clamp((vector3 - point):Dot(vector) / dot, 0, 1)
		local magnitude = (point + vector * v3 - vector3).Magnitude

		if not (magnitude < v) then
			continue
		end

		local v4 = (i - 1) * FlameStream.STEP
		local v5

		if i == count - 1 then
			v5 = p.tEnd
		else
			v5 = i * FlameStream.STEP
		end

		v2 = v4 + (v5 - v4) * v3
		v = magnitude
	end

	return v, v2
end

return FlameStream