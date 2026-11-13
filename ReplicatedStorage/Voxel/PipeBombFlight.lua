--!native
local WorldConfig = require(script.Parent:WaitForChild("WorldConfig"))

local PipeBombFlight = {}

local meter = WorldConfig.METER
PipeBombFlight.STEP = 1 / 60
PipeBombFlight.FUSE = 1.5
PipeBombFlight.RADIUS = 0.35

PipeBombFlight.THROW_SPEED = 20
PipeBombFlight.THROW_LIFT = 4

function PipeBombFlight.scale()
	return meter * WorldConfig.speedScale()
end

function PipeBombFlight.launch(vector3: Vector3)
	local vector3_2 = Vector3.new(0, 1, 0) - vector3 * vector3.Y
	local v = not (vector3_2.Magnitude > 0.001) and Vector3.new(0, 0, 1) or vector3_2.Unit
	return (vector3 * PipeBombFlight.THROW_SPEED + v * PipeBombFlight.THROW_LIFT) * PipeBombFlight.scale()
end

function PipeBombFlight.new(pos: Vector3, vel: Vector3)
	return { pos = pos, vel = vel, t = 0, normal = nil }
end

local function step(state, callback, callback2)
	local step2 = PipeBombFlight.STEP
	local gravity = workspace.Gravity
	state.t += step2
	state.vel += Vector3.new(0, -gravity * step2, 0)
	state.normal = nil
	local v = state.vel * step2
	local magnitude = v.Magnitude

	if magnitude < 1e-6 then
		return
	end

	local v2 = v / magnitude
	local v3, normal, _, v4 = callback(state.pos, v2, magnitude + PipeBombFlight.RADIUS)

	if not (v3 and normal) then
		state.pos += v
		return
	end

	state.pos = v3 + normal * PipeBombFlight.RADIUS
	state.normal = normal
	local dot = state.vel:Dot(normal)
	local v5 = normal * dot
	local v6 = state.vel - v5

	if -dot > 1.5 * PipeBombFlight.scale() then
		state.vel = v6 * 0.5 - v5 * 0.15

		if callback2 then
			callback2(state.pos, normal, -dot / PipeBombFlight.scale(), v4)
		end
	else
		local v7 = 0.5 * gravity * math.max(normal.Y, 0.2) * step2
		local magnitude2 = v6.Magnitude
		state.vel = not (v7 < magnitude2) and Vector3.new(0, 0, 0) or v6 * ((magnitude2 - v7) / magnitude2)
	end
end

function PipeBombFlight.advance(p, p2: number, callback, callback2)
	while p.t + PipeBombFlight.STEP <= p2 + 1e-9 do
		step(p, callback, callback2)
	end
end

return PipeBombFlight