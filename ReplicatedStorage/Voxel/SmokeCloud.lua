--!native
local SmokeCloud = {}
SmokeCloud.FUSE = 1.6
SmokeCloud.MAX = 2
SmokeCloud.RECHARGE = 25
SmokeCloud.RADIUS = 13
SmokeCloud.HEIGHT = 8
SmokeCloud.SINK = 0.3
SmokeCloud.GROW = 2.6
SmokeCloud.THICK = 1.3
SmokeCloud.HOLD = 16
SmokeCloud.FADE = 4
SmokeCloud.SPREAD = 0.15
SmokeCloud.BLOCK_DEPTH = 5
SmokeCloud.LIMIT = 12
local list = {}
SmokeCloud.list = list

local life = SmokeCloud.HOLD + SmokeCloud.FADE
SmokeCloud.LIFE = life

function SmokeCloud.shape(p: number)
	if p < 0 or life <= p then
		return 0, 0
	end

	local v = (1 - (1 - math.min(p / SmokeCloud.GROW, 1)) ^ 3) * 0.8 + 0.2
	local v2 = math.min(p / SmokeCloud.THICK, 1)

	if SmokeCloud.HOLD < p then
		local v3 = (p - SmokeCloud.HOLD) / SmokeCloud.FADE
		v += SmokeCloud.SPREAD * v3
		v2 *= (1 - v3) ^ 1.5
	end

	return v, v2
end

function SmokeCloud.radii(p: number)
	return (Vector3.new(SmokeCloud.RADIUS * p, SmokeCloud.HEIGHT * p, SmokeCloud.RADIUS * p))
end

function SmokeCloud.centre(p, p2: number)
	return p.pos + Vector3.new(0, SmokeCloud.HEIGHT * p2 * (1 - SmokeCloud.SINK), 0)
end

function SmokeCloud.add(id: number, pos: Vector3, born: number)
	for _, v in list do
		if v.id == id then
			return
		end
	end

	if #list >= SmokeCloud.LIMIT then
		table.remove(list, 1)
	end

	table.insert(list, { id = id, pos = pos, born = born })
end

function SmokeCloud.clear()
	table.clear(list)
end

local function prune(p: number)
	for i = #list, 1, -1 do
		if life <= p - list[i].born then
			table.remove(list, i)
		end
	end
end

local function chord(vector3: Vector3, vector3_2: Vector3, vector3_3: Vector3, vector3_4: Vector3)
	local vector = (vector3 - vector3_3) / vector3_4
	local vector2 = (vector3_2 - vector3) / vector3_4
	local dot = vector2:Dot(vector2)

	if dot < 1e-9 then
		return 0
	end

	local dot2 = vector:Dot(vector2)
	local v = vector:Dot(vector) - 1
	local v2 = dot2 * dot2 - dot * v

	if v2 <= 0 then
		return 0
	end

	local v3 = math.sqrt(v2)
	local v4 = math.max((-dot2 - v3) / dot, 0)
	local v5 = math.min((-dot2 + v3) / dot, 1)

	if v5 <= v4 then
		return 0
	end

	return (v5 - v4) * (vector3_2 - vector3).Magnitude
end

function SmokeCloud.opacity(vector3: Vector3, vector3_2: Vector3, p: number?)
	if #list == 0 then
		return 0
	end

	local v = p or workspace:GetServerTimeNow()
	prune(v)
	local total = 0

	for _, v2 in list do
		local shape, v3 = SmokeCloud.shape(v - v2.born)

		if v3 > 0.01 then
			total += chord(vector3, vector3_2, SmokeCloud.centre(v2, shape), SmokeCloud.radii(shape)) * v3 / SmokeCloud.BLOCK_DEPTH
		end
	end

	return total
end

function SmokeCloud.blocks(vector3: Vector3, vector3_2: Vector3): boolean
	return #list > 0 and SmokeCloud.opacity(vector3, vector3_2) >= 1
end

function SmokeCloud.depthAt(vector3: Vector3, p: number?)
	if #list == 0 then
		return 0
	end

	local v = p or workspace:GetServerTimeNow()
	local maxValue = 0

	for _, v2 in list do
		local shape, v3 = SmokeCloud.shape(v - v2.born)

		if v3 > 0.01 then
			maxValue = math.max(
				maxValue,
				v3 * math.clamp(
					(1 - ((vector3 - SmokeCloud.centre(v2, shape)) / SmokeCloud.radii(shape)).Magnitude) / 0.4,
					0,
					1
				)
			)
		end
	end

	return maxValue
end

return SmokeCloud