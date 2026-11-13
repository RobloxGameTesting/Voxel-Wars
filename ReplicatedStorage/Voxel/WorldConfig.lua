--!native
local WorldConfig = {}
WorldConfig.VOXEL_SIZE = 0.5
WorldConfig.METER = 2.5
WorldConfig.ORIGIN = Vector3.new(0, -8, 0)
local origin = WorldConfig.ORIGIN
local v = {}
function WorldConfig.onOrigin(callback)
	table.insert(v, callback)
end
function WorldConfig.setOrigin(origin2: Vector3)
	local v2 = origin2.Y == origin.Y and origin2.X % 16 == 0 and origin2.Z % 16 == 0
	assert(v2, "[WorldConfig] setOrigin: x and z must be multiples of 16 studs, y unchanged, got " .. tostring(origin2))

	if origin2 == WorldConfig.ORIGIN then
		return
	end

	WorldConfig.ORIGIN = origin2
	local RunService = game:GetService("RunService")

	if RunService:IsServer() then
		local parent = script.Parent
		local v3

		if origin2 ~= origin then
			v3 = origin2
		end

		parent:SetAttribute("VoxelOrigin", v3)
	end

	for _, v3 in v do
		v3(origin2)
	end
end

local voxelOrigin = script.Parent:GetAttribute("VoxelOrigin")

if typeof(voxelOrigin) == "Vector3" then
	local RunService = game:GetService("RunService")

	if RunService:IsClient() then
		WorldConfig.ORIGIN = voxelOrigin
	end
end

WorldConfig.EDIT_STRIDE = 5

function WorldConfig.packKey(p: number, p2: number, p3: number)
	return p + 1024 + (p2 + 512 + (p3 + 1024) * 1024) * 2048
end

function WorldConfig.inKeyRange(p: number, p2: number, p3: number): boolean
	return p >= -1024 and p < 1024 and p2 >= -512 and p2 < 512 and p3 >= -1024 and p3 < 1024
end

function WorldConfig.unpackKey(p: number)
	local v2 = p % 2048
	local v3 = p // 2048 % 1024
	local v4 = p // 2097152
	return v2 - 1024, v3 - 512, v4 - 1024
end

function WorldConfig.encodeChunk(list, vector3: Vector3, vector3_2: Vector3, value: number, flag: boolean?)
	local v2 = #list // 4
	local buf = buffer.create(32 + v2 * WorldConfig.EDIT_STRIDE)
	local v3

	if flag then
		v3 = v2 + 2147483648
	else
		v3 = v2
	end

	buffer.writeu32(buf, 0, v3)
	buffer.writeu32(buf, 28, value)
	buffer.writef32(buf, 4, vector3.X)
	buffer.writef32(buf, 8, vector3.Y)
	buffer.writef32(buf, 12, vector3.Z)
	buffer.writef32(buf, 16, vector3_2.X)
	buffer.writef32(buf, 20, vector3_2.Y)
	buffer.writef32(buf, 24, vector3_2.Z)

	for i = 0, v2 - 1 do
		local v4 = 32 + i * WorldConfig.EDIT_STRIDE
		buffer.writeu32(buf, v4, (WorldConfig.packKey(list[i * 4 + 1], list[i * 4 + 2], list[i * 4 + 3])))
		buffer.writeu8(buf, v4 + 4, list[i * 4 + 4])
	end

	return buf
end

function WorldConfig.joinBuffers(items)
	local total = 0

	for _, buf in items do
		total += buffer.len(buf)
	end

	local buf = buffer.create(total)
	local total2 = 0

	for _, item in items do
		buffer.copy(buf, total2, item)
		total2 += buffer.len(item)
	end

	return buf
end

function WorldConfig.decodeChunks(buf: buffer, callback)
	local v2 = buffer.len(buf)
	local total = 0

	while total + 32 <= v2 do
		local v3 = buffer.readu32(buf, total)
		local v4 = v3 >= 2147483648

		if v4 then
			v3 -= 2147483648
		end

		local vector3 = Vector3.new(
			buffer.readf32(buf, total + 4),
			buffer.readf32(buf, total + 8),
			(buffer.readf32(buf, total + 12))
		)
		local vector3_2 = Vector3.new(
			buffer.readf32(buf, total + 16),
			buffer.readf32(buf, total + 20),
			(buffer.readf32(buf, total + 24))
		)
		local v5 = table.create(v3 * 4)

		for i = 0, v3 - 1 do
			local v6 = total + 32 + i * WorldConfig.EDIT_STRIDE
			local unpackKey, v7, v8 = WorldConfig.unpackKey((buffer.readu32(buf, v6)))
			local v9 = i * 4 + 1
			local v10 = i * 4 + 2
			local v11 = i * 4 + 3
			local v12 = i * 4 + 4
			local v13 = buffer.readu8(buf, v6 + 4)
			v5[v9] = unpackKey
			v5[v10] = v7
			v5[v11] = v8
			v5[v12] = v13
		end

		callback(v5, vector3, vector3_2, buffer.readu32(buf, total + 28), v4)
		total += 32 + v3 * WorldConfig.EDIT_STRIDE
	end
end

function WorldConfig.speedScale()
	return (math.sqrt(workspace.Gravity / (10 * WorldConfig.METER)))
end

WorldConfig.HAMMER_DEPTH = 0.75
WorldConfig.HAMMER_KICK_BOX = 3.5
WorldConfig.HAMMER_KICK_SPEED = 9
WorldConfig.HAMMER_KICK_SPIN = 20

WorldConfig.HAMMER_SWING_SPEED = 20
WorldConfig.HAMMER_SWING_BOX = 5.5
WorldConfig.HAMMER_SWING_SPIN = 30

WorldConfig.BLAST_SCALE = 1.6

function WorldConfig.blastRadius(p: number)
	return math.max(0.4, p * 2.1) * WorldConfig.METER * WorldConfig.BLAST_SCALE
end

function WorldConfig.profileDamage(data, p: number, p2: number)
	if data.shockRadius < p then
		return 0
	end

	if p <= data.radius then
		local v2 = data.curve and data.curve[1]
		local v3 = data.curve and data.curve[2]

		if v2 then
			local v4 = math.clamp((p / data.radius - v2[1]) / (v3[1] - v2[1]), 0, 1)
			p2 *= v2[2] + (v3[2] - v2[2]) * v4
		elseif not (p < data.inner) then
			p2 += (data.low - p2) * (p - data.inner) / (data.radius - data.inner)
		end
	else
		p2 = 0
	end

	return (math.max(p2, data.shock))
end

function WorldConfig.blastVelocity(vector3: Vector3, p: number, vector3_2: Vector3)
	local meter = WorldConfig.METER
	local blastRadius = WorldConfig.blastRadius(p)
	local vector3_3 = vector3_2 - vector3
	local magnitude = vector3_3.Magnitude

	if magnitude <= 0 or blastRadius * 6 <= magnitude then
		return Vector3.new(0, 0, 0)
	end

	local v2 = 1 - math.clamp(magnitude / (math.max(p * 7, 0.01) * meter * WorldConfig.BLAST_SCALE), 0, 1)
	return vector3_3.Unit * (v2 * v2 * (p * 2 + 2) * meter * WorldConfig.speedScale())
end

function WorldConfig.hammerKick(vector3: Vector3, vector3_2: Vector3, vector3_3: Vector3, vector: Vector3, vector2: Vector3, p: number?, p2: number?)
	local v2 = p2 or WorldConfig.HAMMER_KICK_BOX
	local vector3_4 = vector3_3 - vector3

	if v2 <= math.abs(vector3_4.X) or v2 <= math.abs(vector3_4.Y) or v2 <= math.abs(vector3_4.Z) then
		return Vector3.new(0, 0, 0), Vector3.new(0, 0, 0)
	end

	local v3 = (p or WorldConfig.HAMMER_KICK_SPEED) * WorldConfig.METER * WorldConfig.speedScale()
	local v4 = math.clamp(v3 - vector2:Dot(vector3_2), 0, v3)
	local vector4 = vector3 - vector3_3
	local v5 = math.max(vector4:Dot(vector4) + vector:Dot(vector) / 12, 0.05)
	return vector3_2 * v4, vector4:Cross(vector3_2) * (v4 / v5)
end

local EncodingService = game:GetService("EncodingService")
local Zstd = Enum.CompressionAlgorithm.Zstd

function WorldConfig.compressSnapshot(buf: buffer)
	return EncodingService:CompressBuffer(buf, Zstd, 3)
end

function WorldConfig.packSnapshot(buf: buffer)
	local EDIT_STRIDE = WorldConfig.EDIT_STRIDE
	local v2 = buffer.len(buf) // EDIT_STRIDE
	local buf2 = buffer.create(4 + v2 * EDIT_STRIDE)
	buffer.writeu32(buf2, 0, v2)
	local v3 = 0

	for i = 0, v2 - 1 do
		local v4 = buffer.readu32(buf, i * EDIT_STRIDE)
		assert(v3 <= v4, "[WorldConfig] packSnapshot: edits are not sorted")
		buffer.writeu32(buf2, i * 4 + 4, v4 - v3)
		buffer.writeu8(buf2, 4 + v2 * 4 + i, (buffer.readu8(buf, i * EDIT_STRIDE + 4)))
		v3 = v4
	end

	return WorldConfig.compressSnapshot(buf2)
end

function WorldConfig.unpackSnapshot(buf: buffer)
	local decompressBuffer = EncodingService:DecompressBuffer(buf, Zstd)
	local EDIT_STRIDE = WorldConfig.EDIT_STRIDE
	local v2 = buffer.readu32(decompressBuffer, 0)
	assert(buffer.len(decompressBuffer) == 4 + v2 * EDIT_STRIDE, "[WorldConfig] unpackSnapshot: bad length")
	local buf2 = buffer.create(v2 * EDIT_STRIDE)
	local total = 0

	for i = 0, v2 - 1 do
		total += buffer.readu32(decompressBuffer, i * 4 + 4)
		buffer.writeu32(buf2, i * EDIT_STRIDE, total)
		buffer.writeu8(buf2, i * EDIT_STRIDE + 4, (buffer.readu8(decompressBuffer, v2 * 4 + 4 + i)))
	end

	return buf2
end

function WorldConfig.zip(buf: buffer)
	return EncodingService:CompressBuffer(buf, Zstd, 6)
end

function WorldConfig.unzip(buf: buffer)
	return EncodingService:DecompressBuffer(buf, Zstd)
end

local function flagged(buf: buffer, size: number)
	if size >= 96 then
		local buf2 = buffer.create(size)
		buffer.copy(buf2, 0, buf, 1, size)
		local compressBuffer = EncodingService:CompressBuffer(buf2, Zstd, 3)
		local v2 = buffer.len(compressBuffer)

		if v2 < size then
			local buf3 = buffer.create(v2 + 1)
			buffer.writeu8(buf3, 0, 1)
			buffer.copy(buf3, 1, compressBuffer)
			return buf3
		end
	end

	local buf2 = buffer.create(size + 1)
	buffer.copy(buf2, 1, buf, 1, size)
	return buf2
end

local function unflagged(buf: buffer)
	local v2 = buffer.len(buf) - 1
	local buf2 = buffer.create(v2)
	buffer.copy(buf2, 0, buf, 1, v2)

	if buffer.readu8(buf, 0) == 1 then
		return (EncodingService:DecompressBuffer(buf2, Zstd))
	end

	return buf2
end

local function writeVar(buf: buffer, count: number, value: number) -- 1 equivalent call inferred from this helper
	while value >= 128 do
		buffer.writeu8(buf, count, value % 128 + 128)
		count += 1
		value //= 128
	end

	buffer.writeu8(buf, count, value)
	return count + 1
end

local function readVar(buf: buffer, count: number)
	local v2 = 1
	local total = 0

	while true do
		local v3 = buffer.readu8(buf, count)
		count += 1

		if v3 < 128 then
			return total + v3 * v2, count
		end

		total += (v3 - 128) * v2
		v2 *= 128
	end
end

function WorldConfig.packEdits(buf: buffer)
	local EDIT_STRIDE = WorldConfig.EDIT_STRIDE
	local v2 = buffer.len(buf) // EDIT_STRIDE

	if v2 == 0 then
		return buf
	end

	local v3 = table.create(v2)

	for i = 1, v2 do
		v3[i] = (i - 1) * EDIT_STRIDE
	end

	table.sort(v3, function(a: number, b: number): boolean
		return buffer.readu32(buf, a) < buffer.readu32(buf, b)
	end)

	local buf2 = buffer.create(v2 * 11 + 6)
	local v4 = writeVar(buf2, 1, v2) -- inferred equivalent call
	local v5 = 0

	for i = 1, v2 do
		local v6 = buffer.readu32(buf, v3[i])
		local v7 = v6 - v5

		while v7 >= 128 do
			buffer.writeu8(buf2, v4, v7 % 128 + 128)
			v4 += 1
			v7 //= 128
		end

		buffer.writeu8(buf2, v4, v7)
		v4 += 1
		v5 = v6
	end

	local v6 = 1

	while v6 <= v2 do
		local v7 = buffer.readu8(buf, v3[v6] + 4)
		local v8 = v6

		while v8 < v2 and buffer.readu8(buf, v3[v8 + 1] + 4) == v7 do
			v8 += 1
		end

		local v9 = v8 - v6 + 1

		while v9 >= 128 do
			buffer.writeu8(buf2, v4, v9 % 128 + 128)
			v4 += 1
			v9 //= 128
		end

		buffer.writeu8(buf2, v4, v9)
		local v10 = v4 + 1

		buffer.writeu8(buf2, v10, v7)
		v4 = v10 + 1
		v6 = v8 + 1
	end

	return flagged(buf2, v4 - 1)
end

function WorldConfig.unpackEdits(buf: buffer)
	if buffer.len(buf) == 0 then
		return buf
	end

	local EDIT_STRIDE = WorldConfig.EDIT_STRIDE
	local buf2 = unflagged(buf)
	local v2, v3 = readVar(buf2, 0)
	local buf3 = buffer.create(v2 * EDIT_STRIDE)
	local total = 0

	for i = 0, v2 - 1 do
		local v4
		v4, v3 = readVar(buf2, v3)
		total += v4
		buffer.writeu32(buf3, i * EDIT_STRIDE, total)
	end

	local total2 = 0

	while total2 < v2 do
		local v4, v5 = readVar(buf2, v3)
		local v6 = buffer.readu8(buf2, v5)
		v3 = v5 + 1

		for i = total2, total2 + v4 - 1 do
			buffer.writeu8(buf3, i * EDIT_STRIDE + 4, v6)
		end

		total2 += v4
	end

	return buf3
end

function WorldConfig.packBlob(buf: buffer)
	local v2 = buffer.len(buf)

	if v2 == 0 then
		return buf
	end

	local buf2 = buffer.create(v2 + 1)
	buffer.copy(buf2, 1, buf)
	return flagged(buf2, v2)
end

function WorldConfig.unpackBlob(buf: buffer)
	if buffer.len(buf) == 0 then
		return buf
	end

	return unflagged(buf)
end

return WorldConfig