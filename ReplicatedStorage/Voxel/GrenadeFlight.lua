--!native
local WorldConfig = require(script.Parent:WaitForChild("WorldConfig"))
local Materials = require(script.Parent:WaitForChild("Materials"))

local GrenadeFlight = {}

local meter = WorldConfig.METER
GrenadeFlight.STEP = 1 / 60
GrenadeFlight.FUSE = 2.7
GrenadeFlight.LATE = 3
GrenadeFlight.RADIUS = 0.3

GrenadeFlight.GRAVITY = 0.6

GrenadeFlight.THROW_SPEED = 17
GrenadeFlight.THROW_LIFT = 4.5
GrenadeFlight.LOB_SPEED = 9
GrenadeFlight.LOB_LIFT = 3
GrenadeFlight.CARRY = 0.6

local set = {
	[Enum.Material.Grass] = true,
	[Enum.Material.LeafyGrass] = true,
	[Enum.Material.Ground] = true,
	[Enum.Material.Mud] = true,
	[Enum.Material.Sand] = true,
	[Enum.Material.Snow] = true
}

function GrenadeFlight.scale()
	return meter * WorldConfig.speedScale()
end

function GrenadeFlight.launch(vector3: Vector3, flag: boolean, vector3_2: Vector3)
	local vector3_3 = Vector3.new(0, 1, 0) - vector3 * vector3.Y
	local v = not (vector3_3.Magnitude > 0.001) and Vector3.new(0, 0, 1) or vector3_3.Unit
	local v2

	if flag then
		v2 = GrenadeFlight.LOB_SPEED
	else
		v2 = GrenadeFlight.THROW_SPEED
	end

	local v3

	if flag then
		v3 = GrenadeFlight.LOB_LIFT
	else
		v3 = GrenadeFlight.THROW_LIFT
	end

	return (vector3 * v2 + v * v3) * GrenadeFlight.scale() + vector3_2 * GrenadeFlight.CARRY
end

function GrenadeFlight.maxLaunch()
	return math.sqrt(GrenadeFlight.THROW_SPEED ^ 2 + GrenadeFlight.THROW_LIFT ^ 2) * GrenadeFlight.scale()
end

function GrenadeFlight.new(pos: Vector3, vel: Vector3, p: number?)
	return {
		pos = pos,
		vel = vel,
		t = 0,
		touched = -1e999,
		rolling = false,
		normal = Vector3.new(0, 1, 0),
		fuse = math.clamp(p or GrenadeFlight.FUSE, 0, GrenadeFlight.FUSE)
	}
end

function GrenadeFlight.onSurface(p): boolean
	return p.t - p.touched <= 0.1
end

local function soft(value): boolean
	if type(value) == "number" then
		local v = Materials.Palette[value]
		return v ~= nil and v.type.name == "soil"
	end

	return typeof(value) == "EnumItem" and set[value] == true
end

local function step(state, callback, callback2)
	local step2 = GrenadeFlight.STEP
	local v = workspace.Gravity * GrenadeFlight.GRAVITY
	state.t += step2
	state.vel += Vector3.new(0, -v * step2, 0)
	local v2 = state.vel * step2
	local magnitude = v2.Magnitude

	if magnitude < 1e-6 then
		return
	end

	local v3 = v2 / magnitude
	local v4, normal, _, v5 = callback(state.pos, v3, magnitude + GrenadeFlight.RADIUS)
	local v6

	if type(v5) == "number" then
		local v7 = Materials.Palette[v5]

		if v7 == nil then
			v6 = false
		else
			v6 = v7.type.name == "soil"
		end
	elseif typeof(v5) == "EnumItem" then
		v6 = set[v5] == true
	else
		v6 = false
	end

	if v4 and normal then
		state.pos = v4 + normal * GrenadeFlight.RADIUS
		state.touched = state.t
		state.normal = normal
		local dot = state.vel:Dot(normal)
		local v7 = normal * dot
		local v8 = state.vel - v7

		if -dot > 2 * GrenadeFlight.scale() then
			state.vel = v8 * (v6 and 0.45 or 0.62) - v7 * (v6 and 0.25 or 0.45)
			state.rolling = false

			if callback2 then
				callback2(state.pos, normal, -dot / GrenadeFlight.scale(), v5)
			end
		else
			local v9 = (v6 and 1.6 or 0.9) * v * math.max(normal.Y, 0.2) * step2
			local magnitude2 = v8.Magnitude
			state.vel = not (v9 < magnitude2) and Vector3.new(0, 0, 0) or v8 * ((magnitude2 - v9) / magnitude2)
			state.rolling = true
		end
	else
		state.pos += v2
		state.rolling = false
	end
end

function GrenadeFlight.advance(p, p2: number, callback, callback2)
	while p.t + GrenadeFlight.STEP <= p2 + 1e-9 do
		step(p, callback, callback2)
	end
end

function GrenadeFlight.due(p)
	return p.t >= p.fuse and (GrenadeFlight.onSurface(p) or p.t >= p.fuse + GrenadeFlight.LATE)
end

return GrenadeFlight