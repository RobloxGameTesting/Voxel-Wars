--!native
local GroundFireShared = {
	START = 0.3,
	FRONT_BY = 0.75,
	RISE = 1.5,
	FADE = 0.3,
	["WIND"] = Vector3.new(1.1, 0, 0.45),
	POOL_START = 0.55,
	POOL_SPREAD = 0.8,
	POOL_RISE = 0.12,
	POOL_FADE = 0.3
}

local function smooth(value: number) -- 2 equivalent calls inferred from this helper
	local v = math.clamp(value, 0, 1)
	return v * v * (3 - v * 2)
end

function GroundFireShared.front(data, p: number)
	if data.pool then
		local v = smooth(p / GroundFireShared.POOL_SPREAD) -- inferred equivalent call
		return data.radius * (GroundFireShared.POOL_START + (1 - GroundFireShared.POOL_START) * v)
	else
		local v = smooth(p / (GroundFireShared.FRONT_BY * data.flame)) -- inferred equivalent call
		return data.radius * (GroundFireShared.START + (1 - GroundFireShared.START) * v)
	end
end

function GroundFireShared.intensity(p, p2: number)
	if p2 < 0 or p.flame <= p2 then
		return 0
	end

	local v

	if p.pool then
		v = GroundFireShared.POOL_RISE
	else
		v = GroundFireShared.RISE
	end

	local v2 = math.clamp(p2 / v, 0, 1)
	local v3 = p.flame - p2
	local v4

	if p.pool then
		v4 = GroundFireShared.POOL_FADE
	else
		v4 = GroundFireShared.FADE
	end

	return v2 * math.sqrt((math.clamp(v3 / (v4 * p.flame), 0, 1)))
end

function GroundFireShared.phase(p, p2: number): string
	if p2 < p.flame then
		return "flame"
	end

	return if p2 < p.flame + p.smoulder then "smoulder" else "out"
end

GroundFireShared.BYTES = 34

function GroundFireShared.encode(list)
	local buf = buffer.create(#list * 34)

	for k, item in list do
		local v = (k - 1) * 34
		buffer.writeu16(buf, v, item.id)
		buffer.writef32(buf, v + 2, item.pos.X)
		buffer.writef32(buf, v + 6, item.pos.Y)
		buffer.writef32(buf, v + 10, item.pos.Z)
		local unit = item.normal.Unit
		buffer.writei8(buf, v + 14, (math.round(unit.X * 127)))
		buffer.writei8(buf, v + 15, (math.round(unit.Y * 127)))
		buffer.writei8(buf, v + 16, (math.round(unit.Z * 127)))
		buffer.writeu8(buf, v + 17, (math.clamp(math.round(item.radius * 8), 1, 255)))
		buffer.writeu8(buf, v + 18, (math.clamp(math.round(item.fuel * 255), 0, 255)))
		buffer.writef64(buf, v + 19, item.t0)
		buffer.writeu16(buf, v + 27, (math.clamp(math.round(item.flame * 100), 1, 65535)))
		buffer.writeu16(buf, v + 29, (math.clamp(math.round(item.smoulder * 100), 1, 65535)))
		buffer.writeu16(buf, v + 31, item.seed)
		buffer.writeu8(buf, v + 33, item.pool and 1 or 0)
	end

	return buf
end

function GroundFireShared.decode(buf: buffer)
	local v = buffer.len(buf)
	assert(v % 34 == 0, "[GroundFire] bad record buffer of " .. v .. " bytes")
	local result = {}

	for i = 0, v - 34, 34 do
		local vector3 = Vector3.new(
			buffer.readi8(buf, i + 14),
			buffer.readi8(buf, i + 15),
			(buffer.readi8(buf, i + 16))
		)
		table.insert(result, {
			id = buffer.readu16(buf, i),
			pos = Vector3.new(buffer.readf32(buf, i + 2), buffer.readf32(buf, i + 6), (buffer.readf32(buf, i + 10))),
			normal = not (vector3.Magnitude > 0) and Vector3.new(0, 1, 0) or vector3.Unit,
			radius = buffer.readu8(buf, i + 17) / 8,
			fuel = buffer.readu8(buf, i + 18) / 255,
			t0 = buffer.readf64(buf, i + 19),
			flame = buffer.readu16(buf, i + 27) / 100,
			smoulder = buffer.readu16(buf, i + 29) / 100,
			seed = buffer.readu16(buf, i + 31),
			pool = buffer.readu8(buf, i + 33) == 1
		})
	end

	return result
end

return GroundFireShared