local WorldConfig = require(script.Parent:WaitForChild("WorldConfig"))

local C4Shared = {
	NAME = "C4",
	ATTR = "C4s",
	LIVE_ATTR = "C4Live",
	MAX = 2,
	RECHARGE = 30,
	LIVE_MAX = 3,
	COOLDOWN = 0.45,
	DETONATE_COOLDOWN = 0.3,
	STEP = 1 / 60,
	THROW_SPEED = 8.5,
	THROW_LIFT = 2.5,
	GRAVITY = 0.9,
	CARRY = 0.6,
	RADIUS = 0.15,
	MAX_FLIGHT = 5,
	MAX_ORIGIN_OFFSET = 10,
	SPEED_SLACK = 1.15,
	SIZE = 1,
	REACH = 0.55,
	DAMAGE = 250,
	BLAST_OUT = 0.5,
	CHAIN = 0.12,
	STAGGER = 0.09,
	DROP = 80,
	BACK = 0.15,
	scale = function()
		return WorldConfig.METER * WorldConfig.speedScale()
	end
}

function C4Shared.launch(vector3: Vector3, vector3_2: Vector3)
	local v = Vector3.new(0, 1, 0) - vector3 * vector3.Y
	local v2 = not (v.Magnitude > 0.001) and Vector3.new(0, 0, 1) or v.Unit
	return (vector3 * C4Shared.THROW_SPEED + v2 * C4Shared.THROW_LIFT) * C4Shared.scale() + vector3_2 * C4Shared.CARRY
end

function C4Shared.maxLaunch()
	return math.sqrt(C4Shared.THROW_SPEED ^ 2 + C4Shared.THROW_LIFT ^ 2) * C4Shared.scale()
end

function C4Shared.new(pos: Vector3, vel: Vector3)
	return {
		pos = pos,
		vel = vel,
		t = 0,
		normal = Vector3.new(0, 1, 0),
		stuck = false,
		done = false
	}
end

function C4Shared:advance(p: number, callback): boolean
	if self.done then
		return true
	end

	local step = C4Shared.STEP
	local v = workspace.Gravity * C4Shared.GRAVITY

	while self.t + step <= p + 1e-9 do
		self.t += step
		self.vel += Vector3.new(0, -v * step, 0)
		local v2 = self.vel * step
		local magnitude = v2.Magnitude

		if magnitude > 1e-6 then
			local v3 = v2 / magnitude
			local pos, normal = callback(self.pos, v3, magnitude + C4Shared.RADIUS)

			if pos and normal then
				self.pos = pos
				self.normal = normal
				self.stuck = true
				self.done = true
				return true
			end

			self.pos += v2
		end

		if self.t >= C4Shared.MAX_FLIGHT then
			self.done = true
			return true
		end
	end

	return false
end

function C4Shared.frame(vector3: Vector3, vector3_2: Vector3, vector: Vector3)
	local v = vector - vector3_2 * vector:Dot(vector3_2)

	if v.Magnitude < 0.05 then
		local vector2 = math.abs(vector3_2.Y) < 0.9 and Vector3.new(0, 1, 0) or Vector3.new(1, 0, 0)
		v = vector2 - vector3_2 * vector2:Dot(vector3_2)
	end

	return CFrame.lookAlong(vector3, v.Unit, vector3_2)
end

function C4Shared.handle(cframe: CFrame)
	return cframe * CFrame.new(0, C4Shared.BACK, 0)
end

return C4Shared