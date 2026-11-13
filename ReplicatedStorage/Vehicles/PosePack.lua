--!native
local Players = game:GetService("Players")

local PosePack = {}

local function i16(p: number) -- 9 equivalent calls inferred from this helper
	return (math.clamp(math.round(p), -32767, 32767))
end

local v = {}
local bufs = {}

local function newScratch() -- 1 equivalent call inferred from this helper
	return table.remove(bufs) or buffer.create(1150)
end

local function seal(state) -- 2 equivalent calls inferred from this helper
	local buf = buffer.create(state.n)
	buffer.copy(buf, 0, state.buf, 0, state.n)
	table.insert(state.full, buf)
	state.n = 0
end

local buf = buffer.create(292)
function PosePack.queueAll(p, value: number, cframe: CFrame, vector3: Vector3, vector3_2: Vector3, buf2: buffer?, base: number)
	local v2 = value >= 0 and value <= 255 and value % 1 == 0
	assert(v2, "[PosePack] vehicle id must be 0..255")
	local v3 = not buf2 and 0 or buffer.len(buf2)
	assert(v3 <= 255, "[PosePack] extra over 255 bytes")
	local v4 = buf
	local components, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15 = cframe:GetComponents()

	local v16 = v7 + v11 + v15
	local v17, v18, v19, v20

	if v16 > 0 then
		local v21 = math.sqrt(v16 + 1) * 2
		v17 = v21 * 0.25
		v18 = (v14 - v12) / v21
		v19 = (v9 - v13) / v21
		v20 = (v10 - v8) / v21
	elseif v11 < v7 and v15 < v7 then
		local v21 = math.sqrt(1 + v7 - v11 - v15) * 2
		v17 = (v14 - v12) / v21
		v18 = v21 * 0.25
		v19 = (v8 + v10) / v21
		v20 = (v9 + v13) / v21
	elseif v15 < v11 then
		local v21 = math.sqrt(1 + v11 - v7 - v15) * 2
		v17 = (v9 - v13) / v21
		v18 = (v8 + v10) / v21
		v19 = v21 * 0.25
		v20 = (v12 + v14) / v21
	else
		local v21 = math.sqrt(1 + v15 - v7 - v11) * 2
		v17 = (v10 - v8) / v21
		v18 = (v9 + v13) / v21
		v19 = (v12 + v14) / v21
		v20 = v21 * 0.25
	end

	local v21 = math.sqrt(v18 * v18 + v19 * v19 + v20 * v20 + v17 * v17)
	local v22 = v18 / v21
	local v23 = v19 / v21
	local v24 = v20 / v21
	local v25 = v17 / v21
	local v26 = math.abs(v22)
	local v27 = math.abs(v23)
	local v28 = math.abs(v24)
	local v29 = math.abs(v25)
	local v30

	if v27 <= v26 and v28 <= v26 and v29 <= v26 then
		local v31 = v24
		v24 = v25
		v25 = v22
		v22 = v23
		v23 = v31
		v30 = 0
	elseif v28 <= v27 and v29 <= v27 then
		local v31 = v24
		v24 = v25
		v25 = v23
		v23 = v31
		v30 = 1
	elseif v29 <= v28 then
		v24, v25 = v25, v24
		v30 = 2
	else
		v30 = 3
	end

	if v25 < 0 then
		v22 = -v22
		v23 = -v23
		v24 = -v24
	end

	buffer.writeu8(v4, 0, value)
	buffer.writef32(v4, 1, components)
	buffer.writef32(v4, 5, v5)
	buffer.writef32(v4, 9, v6)
	buffer.writeu8(v4, 13, v30)
	buffer.writei16(v4, 14, i16(v22 * 46339.53579827921)) -- inferred equivalent call
	buffer.writei16(v4, 16, i16(v23 * 46339.53579827921)) -- inferred equivalent call
	buffer.writei16(v4, 18, i16(v24 * 46339.53579827921)) -- inferred equivalent call
	buffer.writei16(v4, 20, i16(vector3.X * 16)) -- inferred equivalent call
	buffer.writei16(v4, 22, i16(vector3.Y * 16)) -- inferred equivalent call
	buffer.writei16(v4, 24, i16(vector3.Z * 16)) -- inferred equivalent call
	buffer.writei16(v4, 26, i16(vector3_2.X * 1024)) -- inferred equivalent call
	buffer.writei16(v4, 28, i16(vector3_2.Y * 1024)) -- inferred equivalent call
	buffer.writei16(v4, 30, i16(vector3_2.Z * 1024)) -- inferred equivalent call
	buffer.writeu8(v4, 36, v3)

	if buf2 and v3 > 0 then
		buffer.copy(v4, 37, buf2, 0, v3)
	end

	local v31 = 37 + v3

	for _, v32 in Players:GetPlayers() do
		if v32 == p then
			continue
		end

		local v34 = v[v32]

		if not v34 then
			v34 = { buf = newScratch(), n = 0, base = base, full = {} } -- inferred equivalent call
			v[v32] = v34
		end

		if v34.n > 0 and v34.n + v31 > 850 then
			seal(v34) -- inferred equivalent call
		end

		if v34.n == 0 then
			v34.base = base
			buffer.writef64(v34.buf, 0, base)
			v34.n = 8
		end

		buffer.copy(v34.buf, v34.n, buf, 0, v31)
		buffer.writef32(v34.buf, v34.n + 32, base - v34.base)
		v34.n += v31
	end
end

function PosePack.flush(callback)
	for k, v2 in v do
		if v2.n > 8 then
			seal(v2) -- inferred equivalent call
		end

		table.insert(bufs, v2.buf)
		v[k] = nil

		if not k.Parent then
			continue
		end

		for _, v3 in v2.full do
			callback(k, v3)
		end
	end
end

function PosePack.each(buf2: buffer, callback)
	local v2 = buffer.len(buf2)
	local v3 = buffer.readf64(buf2, 0)
	local total = 8

	while total < v2 do
		local v4 = buffer.readu8(buf2, total)
		local v5 = buffer.readf32(buf2, total + 1)
		local v6 = buffer.readf32(buf2, total + 5)
		local v7 = buffer.readf32(buf2, total + 9)
		local v8 = buffer.readu8(buf2, total + 13)
		local v9 = buffer.readi16(buf2, total + 14) / 46339.53579827921
		local v10 = buffer.readi16(buf2, total + 16) / 46339.53579827921
		local v11 = buffer.readi16(buf2, total + 18) / 46339.53579827921
		local v12 = math.sqrt((math.max(0, 1 - v9 * v9 - v10 * v10 - v11 * v11)))

		if v8 == 0 then
			local v13 = v12
			v12 = v11
			v11 = v10
			v10 = v9
			v9 = v13
		elseif v8 == 1 then
			local v13 = v12
			v12 = v11
			v11 = v10
			v10 = v13
		elseif v8 == 2 then
			v12, v11 = v11, v12
		end

		local cframe = CFrame.new(v5, v6, v7, v9, v10, v11, v12)
		local vector3 = Vector3.new(
			buffer.readi16(buf2, total + 20),
			buffer.readi16(buf2, total + 22),
			(buffer.readi16(buf2, total + 24))
		) / 16
		local vector3_2 = Vector3.new(
			buffer.readi16(buf2, total + 26),
			buffer.readi16(buf2, total + 28),
			(buffer.readi16(buf2, total + 30))
		) / 1024
		local v13 = v3 + buffer.readf32(buf2, total + 32)
		local v14 = buffer.readu8(buf2, total + 36)
		local buf3 = buffer.create(v14)
		buffer.copy(buf3, 0, buf2, total + 37, v14)
		total += v14 + 37
		callback(v4, cframe, vector3, vector3_2, buf3, v13)
	end
end

local v2 = {}
local v3 = nil
local function dispatch(p: number, cframe: CFrame, vector3: Vector3, vector3_2: Vector3, buf2: buffer, p2: number)
	for _, v4 in v2 do
		v4(p, cframe, vector3, vector3_2, buf2, p2)
	end
end
function PosePack.listen(p, callback)
	assert(v3 == nil or v3 == p, "[PosePack] listeners on two different remotes")
	table.insert(v2, callback)

	if v3 == nil then
		v3 = p

		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("NetStats")).listen(p, function(buf2: buffer)
			PosePack.each(buf2, dispatch)
		end)
	end
end

return PosePack