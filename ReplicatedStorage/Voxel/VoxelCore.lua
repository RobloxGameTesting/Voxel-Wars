--!native
local readu8 = buffer.readu8
local writeu8 = buffer.writeu8
local readu32 = buffer.readu32
local writeu32 = buffer.writeu32
local floor = math.floor

local VoxelCore = {}
VoxelCore.CHUNK = 16

local function chunkKey(p: number, p2: number, p3: number) -- 8 equivalent calls inferred from this helper
	return p + 1024 + (p2 + 1024) * 2048 + (p3 + 1024) * 4194304
end

VoxelCore.chunkKey = chunkKey

function VoxelCore.newWorld(voxelSize: number, origin: Vector3, groundRow)
	return {
		groundRow = groundRow,
		voxelSize = voxelSize,
		origin = origin,
		chunks = {},
		dirty = {},
		minX = 1e999,
		minY = 1e999,
		minZ = 1e999,
		maxX = -1e999,
		maxY = -1e999,
		maxZ = -1e999,
		gen = 0,
		stack = {},
		visited = {},
		spare = {}
	}
end

local function newChunk(state, cx: number, cy: number, cz: number)
	local v = table.remove(state.spare)

	if not v then
		return {
			cx = cx,
			cy = cy,
			cz = cz,
			data = buffer.create(4096),
			count = 0,
			revision = 0
		}
	end

	v.cx = cx
	v.cy = cy
	v.cz = cz
	return v
end

local function get(p, p2: number, p3: number, p4: number) -- 2 equivalent calls inferred from this helper
	local v = p2 // 16
	local v2 = p3 // 16
	local v3 = p4 // 16
	local chunk = p.chunks[chunkKey(v, v2, v3)] -- inferred equivalent call

	if chunk == nil then
		return 0
	end

	return (readu8(chunk.data, p2 - v * 16 + (p3 - v2 * 16) * 16 + (p4 - v3 * 16) * 256))
end

VoxelCore.get = get

local function set(state, p: number, p2: number, p3: number, value: number): boolean
	local cx = p // 16
	local cy = p2 // 16
	local cz = p3 // 16
	local v = chunkKey(cx, cy, cz) -- inferred equivalent call
	local v2 = state.chunks[v]

	if v2 == nil then
		if value == 0 then
			return false
		end

		v2 = newChunk(state, cx, cy, cz)
		state.chunks[v] = v2
	end

	assert(v2)
	local v3 = p - cx * 16 + (p2 - cy * 16) * 16 + (p3 - cz * 16) * 256
	local v4 = readu8(v2.data, v3)

	if v4 == value then
		return false
	end

	writeu8(v2.data, v3, value)

	if v4 == 0 then
		v2.count += 1
	elseif value == 0 then
		v2.count -= 1
	end

	v2.revision += 1
	state.dirty[v] = v2
	local log = state.log

	if log then
		local count = #log
		local v5 = count + 1
		local v6 = count + 2
		local v7 = count + 3
		local v8 = count + 4
		log[v5] = p
		log[v6] = p2
		log[v7] = p3
		log[v8] = value
	end

	if value == 0 then
		return true
	end

	if p < state.minX then
		state.minX = p
	end

	if p2 < state.minY then
		state.minY = p2
	end

	if p3 < state.minZ then
		state.minZ = p3
	end

	if state.maxX < p then
		state.maxX = p
	end

	if state.maxY < p2 then
		state.maxY = p2
	end

	if state.maxZ < p3 then
		state.maxZ = p3
	end

	return true
end

VoxelCore.set = set

function VoxelCore:fill(p: number, p2: number, p3: number, p4: number, p5: number, p6: number, value: number)
	assert(self.log == nil, "Core.fill is for building; edits must go through Core.set")

	if p4 < p then
		p4, p = p, p4
	end

	if p5 < p2 then
		p5, p2 = p2, p5
	end

	if p6 < p3 then
		p6, p3 = p3, p6
	end

	local chunks = self.chunks

	for i = p3 // 16, p6 // 16 do
		local v = math.max(p3, i * 16) - i * 16
		local v2 = math.min(p6, i * 16 + 16 - 1) - i * 16

		for j = p2 // 16, p5 // 16 do
			local v3 = math.max(p2, j * 16) - j * 16
			local v4 = math.min(p5, j * 16 + 16 - 1) - j * 16

			for k = p // 16, p4 // 16 do
				local v5 = math.max(p, k * 16) - k * 16
				local v6 = math.min(p4, k * 16 + 16 - 1) - k * 16
				local v7 = chunkKey(k, j, i) -- inferred equivalent call
				local v8 = chunks[v7]

				if v8 == nil then
					if value == 0 then
						continue
					end

					v8 = newChunk(self, k, j, i)
					chunks[v7] = v8
				end

				assert(v8)
				local data = v8.data
				local v9 = v6 - v5 + 1
				local total = 0

				for i2 = v, v2 do
					for i3 = v3, v4 do
						local v10 = v5 + i3 * 16 + i2 * 256
						local count = 0

						for i4 = v10, v10 + v9 - 1 do
							if readu8(data, i4) ~= 0 then
								count += 1
							end
						end

						buffer.fill(data, v10, value, v9)
						total += (value == 0 and 0 or v9) - count
					end
				end

				v8.count += total
				v8.revision += 1
				self.dirty[v7] = v8

				if v8.count == 0 then
					chunks[v7] = nil
				end
			end
		end
	end

	if value ~= 0 then
		local minX = math.min(self.minX, p)
		local minY = math.min(self.minY, p2)
		local minZ = math.min(self.minZ, p3)
		self.minX = minX
		self.minY = minY
		self.minZ = minZ
		local maxX = math.max(self.maxX, p4)
		local maxY = math.max(self.maxY, p5)
		local maxZ = math.max(self.maxZ, p6)
		self.maxX = maxX
		self.maxY = maxY
		self.maxZ = maxZ
	end
end

function VoxelCore:clear()
	table.clear(self.dirty)
	local spare = self.spare

	for _, chunk in self.chunks do
		buffer.fill(chunk.data, 0, 0)
		chunk.count = 0
		table.insert(spare, chunk)
	end

	table.clear(self.chunks)
	self.minX = 1e999
	self.minY = 1e999
	self.minZ = 1e999
	self.maxX = -1e999
	self.maxY = -1e999
	self.maxZ = -1e999
end

function VoxelCore.snapshot(data)
	local chunks = {}

	for k, chunk in data.chunks do
		local buf = buffer.create(4096)
		buffer.copy(buf, 0, chunk.data)
		table.insert(chunks, {
			key = k,
			cx = chunk.cx,
			cy = chunk.cy,
			cz = chunk.cz,
			data = buf,
			count = chunk.count
		})
	end

	return {
		chunks = chunks,
		bounds = { data.minX, data.minY, data.minZ, data.maxX, data.maxY, data.maxZ }
	}
end

function VoxelCore:restore(p)
	assert(self.log == nil, "Core.restore is for building; edits must go through Core.set")
	assert(next(self.chunks) == nil, "Core.restore needs an empty world (Core.clear)")
	local chunks = self.chunks

	for _, chunk in p.chunks do
		local v = newChunk(self, chunk.cx, chunk.cy, chunk.cz)
		buffer.copy(v.data, 0, chunk.data)
		v.count = chunk.count
		v.revision += 1
		chunks[chunk.key] = v
	end

	local bounds = p.bounds
	local bound = bounds[1]
	local bound2 = bounds[2]
	local bound3 = bounds[3]
	local bound4 = bounds[4]
	local bound5 = bounds[5]
	local bound6 = bounds[6]
	self.minX = bound
	self.minY = bound2
	self.minZ = bound3
	self.maxX = bound4
	self.maxY = bound5
	self.maxZ = bound6
end

function VoxelCore.greedy(buf: buffer, p: number, p2: number, p3: number, buf2: buffer, p4)
	local v = p * p2
	buffer.fill(buf2, 0, 0, v * p3)
	local total = 0

	for i = 0, p3 - 1 do
		for j = 0, p2 - 1 do
			local v2 = p * j + v * i

			for k = 0, p - 1 do
				local v3 = v2 + k
				local v4 = readu8(buf, v3)

				if not (v4 ~= 0 and readu8(buf2, v3) == 0) then
					continue
				end

				local v5 = 1

				while k + v5 < p do
					local v6 = v3 + v5

					if readu8(buf, v6) ~= v4 or readu8(buf2, v6) ~= 0 then
						break
					end

					v5 += 1
				end

				local v6 = 1

				while j + v6 < p2 do
					local v7 = v3 + v6 * p
					local v8 = true

					for i2 = 0, v5 - 1 do
						local v9 = v7 + i2

						if readu8(buf, v9) ~= v4 or readu8(buf2, v9) ~= 0 then
							v8 = false
							break
						end
					end

					if not v8 then
						break
					end

					v6 += 1
				end

				local v7 = 1

				while i + v7 < p3 do
					local v8 = v3 + v7 * v
					local v9 = true

					for i2 = 0, v6 - 1 do
						local v10 = v8 + i2 * p

						for i3 = 0, v5 - 1 do
							local v11 = v10 + i3

							if readu8(buf, v11) ~= v4 or readu8(buf2, v11) ~= 0 then
								v9 = false
								break
							end
						end

						if not v9 then
							break
						end
					end

					if not v9 then
						break
					end

					v7 += 1
				end

				for i2 = 0, v7 - 1 do
					for i3 = 0, v6 - 1 do
						local v8 = v3 + i2 * v + i3 * p

						for i4 = 0, v5 - 1 do
							writeu8(buf2, v8 + i4, 1)
						end
					end
				end

				p4[total + 1] = k
				p4[total + 2] = j
				p4[total + 3] = i
				p4[total + 4] = v5
				p4[total + 5] = v6
				p4[total + 6] = v7
				p4[total + 7] = v4
				total += 7
			end
		end
	end

	return total // 7
end

local buf = buffer.create(4096)
function VoxelCore.greedyChunk(p, p2)
	return VoxelCore.greedy(p.data, 16, 16, 16, buf, p2)
end

local result = {}
local result2 = table.create(256, 0)
local v = table.create(256, 0)
function VoxelCore.carveSphere(p, vector3: Vector3, list)
	local voxelSize = p.voxelSize
	local vector3_2 = (vector3 - p.origin) / voxelSize
	local x = vector3_2.X
	local y = vector3_2.Y
	local z = vector3_2.Z
	local v2 = 0

	for i = 1, 255 do
		local v3 = (list[i] or 0) / voxelSize
		v[i] = v3 * v3

		if v2 < v3 then
			v2 = v3
		end

		result2[i] = 0
	end

	local v3 = v2 * v2
	local count = 0

	for i = floor(z - v2), floor(z + v2) do
		local v4 = i + 0.5 - z

		for j = floor(y - v2), floor(y + v2) do
			local v5 = j + 0.5 - y
			local v6 = v5 * v5 + v4 * v4

			if not (v6 <= v3) then
				continue
			end

			for k = floor(x - v2), floor(x + v2) do
				local v7 = k + 0.5 - x
				local v8 = v7 * v7 + v6

				if not (v8 <= v3) then
					continue
				end

				local v9 = get(p, k, j, i) -- inferred equivalent call

				if not (v9 ~= 0 and v8 <= v[v9]) then
					continue
				end

				set(p, k, j, i, 0)
				result[count * 3 + 1] = k
				result[count * 3 + 2] = j
				result[count * 3 + 3] = i
				count += 1
				result2[v9] += 1
			end
		end
	end

	local v4 = 0
	local v5 = 0

	for i = 1, 255 do
		if not (v4 < result2[i]) then
			continue
		end

		v4 = result2[i]
		v5 = i
	end

	return count, v5, result, result2
end

local v2 = {}
local v3 = {}
local v4 = {}

function VoxelCore.carveHole(data, vector3: Vector3, data2, p, object)
	local voxelSize = data.voxelSize
	local vector3_2 = (vector3 - data.origin) / voxelSize
	local x = vector3_2.X
	local y = vector3_2.Y
	local z = vector3_2.Z
	local v5 = math.max(data2.soft, 0)
	local v6 = math.max(data2.medium, 0)
	local v7 = math.max(data2.hard, 0)
	local roughness = data2.roughness
	local gate = data2.gate

	for i = 1, 255 do
		result2[i] = 0
	end

	local v8 = v5 / voxelSize

	local v9 = x - v8
	local v10 = math.max(floor(v9), data.minX)
	local v11 = x + v8
	local v12 = math.min(floor(v11), data.maxX)
	local v13 = y - v8
	local v14 = math.max(floor(v13), data.minY)
	local v15 = y + v8
	local v16 = math.min(floor(v15), data.maxY)
	local v17 = z - v8
	local v18 = math.max(floor(v17), data.minZ)
	local v19 = z + v8
	local v20 = math.min(floor(v19), data.maxZ)
	local chunks = data.chunks
	local total = 0
	local v21 = 0
	local v22 = 0
	local v23 = 0
	local flag = false
	local flag2 = false
	local flag3 = false

	for i = v18, v20 do
		local v24 = i + 0.5 - z
		local v25 = i // 16

		for j = v14, v16 do
			local v26 = j + 0.5 - y
			local v27 = j // 16
			local v28 = (j - v27 * 16) * 16 + (i - v25 * 16) * 256
			local v29 = v10

			while v29 <= v12 do
				local v30 = v29 // 16
				local v31 = math.min(v12, v30 * 16 + 16 - 1)
				local chunk = chunks[chunkKey(v30, v27, v25)] -- inferred equivalent call

				if chunk ~= nil then
					local data3 = chunk.data
					local v32 = v28 - v30 * 16

					for k = v29, v31 do
						local v34 = readu8(data3, k + v32)

						if v34 == 0 then
							continue
						end

						local v35 = k + 0.5 - x
						local v36 = math.sqrt(v35 * v35 + v26 * v26 + v24 * v24)
						local v37 = v36 * voxelSize

						if not (v37 <= v5) then
							continue
						end

						if v36 > 0 then
							local v38 = v35 / v36
							local v39 = v26 / v36
							local v40 = v24 / v36
							local v41 = math.sin(v38 * 9) * math.cos(v39 * 4) * math.sin(v40 * 7)
							local v42

							if v41 < 0 then
								v42 = -math.sqrt(-v41)
							else
								v42 = math.sqrt(v41)
							end

							local v43 = math.sqrt(math.sin(v35 * 0.65 + v26 * 0.81 + v24 * 1.49) * 0.49 + 0.5)
							local v44 = math.sin(v38 * 3) * math.cos(v39 * 4) * math.sin(v40 * 2.5)
							v37 = math.max((v37 - v43 * roughness) / (v42 * 0.1 + v44 * 0.1 + 0.75), 0)
						end

						local v38 = v37 < v7 and 2 or v37 < v6 and 1 or 0
						local v39 = p[v34] or 3

						if not (v37 < v5 and v39 <= v38) then
							continue
						end

						local v40

						if v39 == 0 then
							v40 = v5
						else
							v40 = if v39 == 1 then v6 else v7
						end

						local v41 = v37 / v40

						if gate == nil or gate(k, j, i, v34, v41) then
							result2[v34] += 1
							local v43 = total + 1
							local v44 = total + 2
							local v45 = total + 3
							local v46 = total + 4
							v4[v43] = k
							v4[v44] = j
							v4[v45] = i
							v4[v46] = v37
							total += 4

							if v39 == 0 then
								if v23 < v41 then
									v23 = v41
								end
							elseif v39 == 1 then
								if v22 < v41 then
									v22 = v41
								end
							elseif v21 < v41 then
								v21 = v41
							end
						elseif v39 == 0 then
							flag = true
						elseif v39 == 1 then
							flag2 = true
						else
							flag3 = true
						end
					end
				end

				v29 = v31 + 1
			end
		end
	end

	if flag then
		v5 *= v23
	end

	if flag2 then
		v6 *= v22
	end

	if flag3 then
		v7 *= v21
	end

	local v24 = math.max(v5 - data2.shell, 0)
	local v25 = math.max(v6 - data2.shell, 0)
	local v26 = math.max(v7 - data2.shell, 0)
	local count = 0
	local count2 = 0

	for i = 1, total, 4 do
		local v27 = v4[i]
		local v28 = v4[i + 1]
		local v29 = v4[i + 2]
		local v30 = v4[i + 3]
		local v31

		if v24 < v30 or v25 < v30 and v30 <= v6 then
			v31 = true
		elseif v26 < v30 then
			v31 = v30 <= v7
		else
			v31 = false
		end

		if v31 then
			set(data, v27, v28, v29, 0)
			local v32 = count * 3 + 1
			local v33 = count * 3 + 2
			local v34 = count * 3 + 3
			result[v32] = v27
			result[v33] = v28
			result[v34] = v29
			count += 1
		else
			local v32 = count2 * 3 + 1
			local v33 = count2 * 3 + 2
			local v34 = count2 * 3 + 3
			v2[v32] = v27
			v2[v33] = v28
			v2[v34] = v29
			count2 += 1
		end
	end

	if count2 > 0 and data2.planes > 0 then
		for i = 0, data2.planes - 1 do
			local vector3_3 = Vector3.new(object:NextNumber(-1, 1), object:NextNumber(-1, 1), object:NextNumber(-1, 1))
			local vector = not (vector3_3.Magnitude > 0.0001) and Vector3.new(0, 1, 0) or vector3_3.Unit
			local vector3_4 = Vector3.new(object:NextNumber(-1, 1), object:NextNumber(-1, 1), object:NextNumber(-1, 1))
			local v27 = vector3_2 + (not (vector3_4.Magnitude > 0.0001) and Vector3.new(0, 0, 0) or vector3_4.Unit) * (object:NextNumber() * v5 * 0.5 / voxelSize)
			local v28 = i * 4 + 1
			local v29 = i * 4 + 2
			local v30 = i * 4 + 3
			local x2 = vector.X
			local y2 = vector.Y
			local z2 = vector.Z
			v3[v28] = x2
			v3[v29] = y2
			v3[v30] = z2
			v3[i * 4 + 4] = -vector:Dot(v27)
		end

		local v27 = data2.slab / voxelSize

		for i = 0, count2 - 1 do
			local v28 = v2[i * 3 + 1]
			local v29 = v2[i * 3 + 2]
			local v30 = v2[i * 3 + 3]
			local v31 = v28 + 0.5
			local v32 = v29 + 0.5
			local v33 = v30 + 0.5

			for j = 0, data2.planes - 1 do
				local v34 = j * 4

				if math.abs(v31 * v3[v34 + 1] + v32 * v3[v34 + 2] + v33 * v3[v34 + 3] + v3[v34 + 4]) < v27 then
					set(data, v28, v29, v30, 0)
					local v35 = count * 3 + 1
					local v36 = count * 3 + 2
					local v37 = count * 3 + 3
					result[v35] = v28
					result[v36] = v29
					result[v37] = v30
					count += 1
					break
				end
			end
		end
	end

	local v27 = 0
	local v28 = 0

	for i = 1, 255 do
		if not (v27 < result2[i]) then
			continue
		end

		v27 = result2[i]
		v28 = i
	end

	return count, v28, result, result2, count2
end

function VoxelCore.raycast(data, vector3: Vector3, vector3_2: Vector3, p: number)
	if vector3_2.Magnitude < 1e-9 or data.maxX < data.minX then
		return nil, nil, 0, 0
	end

	local voxelSize = data.voxelSize
	local unit = vector3_2.Unit
	local vector3_3 = (vector3 - data.origin) / voxelSize
	local x = unit.X
	local y = unit.Y
	local z = unit.Z
	local v5 = floor(vector3_3.X)
	local v6 = floor(vector3_3.Y)
	local v7 = floor(vector3_3.Z)
	local v8 = x > 0 and 1 or -1
	local v9 = y > 0 and 1 or -1
	local v10 = z > 0 and 1 or -1
	local v11 = math.abs(x)
	local v12 = math.abs(y)
	local v13 = math.abs(z)

	local v14 = not (v11 > 0) and 1e999 or 1 / v11
	local v15 = not (v12 > 0) and 1e999 or 1 / v12
	local v16 = not (v13 > 0) and 1e999 or 1 / v13
	local v17

	if v11 > 0 then
		local v18

		if v8 > 0 then
			v18 = v5 + 1 - vector3_3.X
		else
			v18 = vector3_3.X - v5
		end

		v17 = v18 * v14
	else
		v17 = 1e999
	end

	local v18

	if v12 > 0 then
		local v19

		if v9 > 0 then
			v19 = v6 + 1 - vector3_3.Y
		else
			v19 = vector3_3.Y - v6
		end

		v18 = v19 * v15
	else
		v18 = 1e999
	end

	local v19

	if v13 > 0 then
		local v20

		if v10 > 0 then
			v20 = v7 + 1 - vector3_3.Z
		else
			v20 = vector3_3.Z - v7
		end

		v19 = v20 * v16
	else
		v19 = 1e999
	end

	local v20 = p / voxelSize
	local minX = data.minX
	local minY = data.minY
	local minZ = data.minZ
	local maxX = data.maxX
	local maxY = data.maxY
	local maxZ = data.maxZ

	local chunks = data.chunks
	local v21 = 0
	local v22 = -1
	local data2 = nil
	local v23 = 0
	local v24 = 0
	local v25 = 0

	while
		v21 <= v20
		and not (v5 < minX and v8 < 0)
		and not (maxX < v5 and v8 > 0 or v6 < minY and v9 < 0 or maxY < v6 and v9 > 0 or v7 < minZ and v10 < 0 or maxZ < v7 and v10 > 0)
	do
		local v26 = v5 // 16
		local v27 = v6 // 16
		local v28 = v7 // 16
		local v29 = chunkKey(v26, v27, v28) -- inferred equivalent call

		if v29 ~= v22 then
			local chunk = chunks[v29]

			if chunk then
				data2 = chunk.data
				v22 = v29
			else
				v22 = v29
				data2 = nil
			end
		end

		if data2 then
			local v30 = readu8(data2, v5 - v26 * 16 + (v6 - v27 * 16) * 16 + (v7 - v28 * 16) * 256)

			if v30 ~= 0 then
				return vector3 + unit * (v21 * voxelSize), Vector3.new(v23, v24, v25), v30, v21 * voxelSize
			end
		end

		local v30

		if v17 < v18 and v17 < v19 then
			v5 += v8

			local v31 = v17 + v14
			v23 = -v8
			v30 = v18
			v21 = v17
			v17 = v31
			v24 = 0
			v25 = 0
		elseif v18 < v19 then
			v6 += v9

			v30 = v18 + v15
			v24 = -v9
			v21 = v18
			v23 = 0
			v25 = 0
		else
			v7 += v10

			local v31 = v19 + v16
			v25 = -v10
			v30 = v18
			v21 = v19
			v19 = v31
			v23 = 0
			v24 = 0
		end

		v18 = v30
	end

	return nil, nil, 0, 0
end

local v5 = {
	0,
	1,
	0,
	1,
	0,
	0,
	-1,
	0,
	0,
	0,
	0,
	1,
	0,
	0,
	-1,
	0,
	-1,
	0
}

local function solidMark(chunks, p: number, p2: number, p3: number)
	local v6 = p // 16
	local v7 = p2 // 16
	local v8 = p3 // 16
	local v9 = chunks[chunkKey(v6, v7, v8)] -- inferred equivalent call

	if v9 == nil then
		return nil, 0
	end

	local v10 = p - v6 * 16 + (p2 - v7 * 16) * 16 + (p3 - v8 * 16) * 256

	if readu8(v9.data, v10) == 0 then
		return nil, 0
	end

	local mark = v9.mark

	if mark == nil then
		mark = buffer.create(16384)
		v9.mark = mark
	end

	return mark, v10 * 4
end

function VoxelCore:findDetached(p, p2: number, p3: number?)
	local minX = self.minX
	local minY = self.minY
	local minZ = self.minZ
	local maxX = self.maxX
	local maxY = self.maxY
	local maxZ = self.maxZ
	local result3 = {}
	local result4 = p3 and {} or nil

	if p2 == 0 or maxX < minX then
		return result3, result4
	end

	local v6 = not p3 and 1e999 or p3 * 3

	self.gen += 1
	local v7 = self.gen * 4
	local v8 = self.gen * 4 + 1
	local v9 = self.gen * 4 + 2
	local v10 = self.gen * 4 + 3
	local v11 = self.gen * 4

	local stack = self.stack
	local visited = self.visited
	local chunks = self.chunks
	local groundRow = self.groundRow

	for i = 0, p2 - 1 do
		local v12 = p[i * 3 + 1]
		local v13 = p[i * 3 + 2]
		local v14 = p[i * 3 + 3]

		for j = 1, 18, 3 do
			local v15 = v12 + v5[j]
			local v16 = v13 + v5[j + 1]
			local v17 = v14 + v5[j + 2]

			if not (minX <= v15 and v15 <= maxX and minY <= v16 and v16 <= maxY) then
				continue
			end

			if not (minZ <= v17 and v17 <= maxZ) then
				continue
			end

			local buf2, v18 = solidMark(chunks, v15, v16, v17)

			if not (buf2 and readu32(buf2, v18) < v11) then
				continue
			end

			writeu32(buf2, v18, v8)
			stack[1] = v15
			stack[2] = v16
			stack[3] = v17
			local v19 = 3
			local total = 0
			local v20 = false
			local flag = false

			while v19 > 0 do
				local v21 = stack[v19 - 2]
				local v22 = stack[v19 - 1]
				local v23 = stack[v19]
				v19 -= 3
				local v24 = total + 1
				local v25 = total + 2
				local v26 = total + 3
				visited[v24] = v21
				visited[v25] = v22
				visited[v26] = v23
				total += 3
				local v27

				if groundRow then
					v27 = v22 <= groundRow(v21, v23)
				else
					v27 = v22 == minY
				end

				if v27 then
					flag = true
					break
				end

				for k = 1, 18, 3 do
					local v28 = v21 + v5[k]
					local v29 = v22 + v5[k + 1]
					local v30 = v23 + v5[k + 2]

					if not (minX <= v28 and v28 <= maxX and minY <= v29 and v29 <= maxY) then
						continue
					end

					if not (minZ <= v30 and v30 <= maxZ) then
						continue
					end

					local buf3, v31 = solidMark(chunks, v28, v29, v30)
					local v32

					if buf3 then
						v32 = readu32(buf3, v31)
					else
						v32 = v11
					end

					if v32 == v9 then
						flag = true
						break
					end

					if v32 == v7 and buf3 and p3 then
						v20 = true
						break
					end

					if not (v32 < v11 and buf3) then
						continue
					end

					writeu32(buf3, v31, v8)
					local v33 = v19 + 1
					local v34 = v19 + 2
					local v35 = v19 + 3
					stack[v33] = v28
					stack[v34] = v29
					stack[v35] = v30
					v19 += 3
				end

				if flag or v20 then
					break
				end

				if v6 <= total then
					v20 = true
					break
				end
			end

			if v20 and result4 then
				for k = 1, total, 3 do
					local buf3, v21 = solidMark(chunks, visited[k], visited[k + 1], visited[k + 2])
					writeu32(buf3, v21, v7)
				end

				for k = 1, v19, 3 do
					local buf3, v21 = solidMark(chunks, stack[k], stack[k + 1], stack[k + 2])
					writeu32(buf3, v21, v7)
				end

				local count = #result4
				local v21 = count + 1
				local v22 = count + 2
				local v23 = count + 3
				result4[v21] = v15
				result4[v22] = v16
				result4[v23] = v17
			else
				local v21 = if flag then v9 else v10

				for k = 1, total, 3 do
					local buf3, v22 = solidMark(chunks, visited[k], visited[k + 1], visited[k + 2])
					writeu32(buf3, v22, v21)
				end

				for k = 1, v19, 3 do
					local buf3, v22 = solidMark(chunks, stack[k], stack[k + 1], stack[k + 2])
					writeu32(buf3, v22, v21)
				end

				if not flag then
					local v22 = table.create(total // 3 * 4)

					for k = 1, total, 3 do
						local v23 = visited[k]
						local v24 = visited[k + 1]
						local v25 = visited[k + 2]
						local count = #v22
						local v26 = count + 1
						local v27 = count + 2
						local v28 = count + 3
						local v29 = count + 4
						local v30 = get(self, v23, v24, v25) -- inferred equivalent call
						v22[v26] = v23
						v22[v27] = v24
						v22[v28] = v25
						v22[v29] = v30
					end

					result3[#result3 + 1] = v22
				end
			end
		end
	end

	return result3, result4
end

function VoxelCore.newSupportJob(seeds)
	return {
		seeds = seeds,
		si = 0,
		marks = {},
		stack = {},
		top = 0,
		visited = {},
		vn = 0,
		searching = false,
		supported = false,
		resolveAt = 0,
		comp = nil
	}
end

local function jobMarkAt(marks, p: number, p2: number, p3: number)
	local v6 = p // 16
	local v7 = p2 // 16
	local v8 = p3 // 16
	local v9 = chunkKey(v6, v7, v8) -- inferred equivalent call
	local v10 = marks[v9]

	if v10 == nil then
		v10 = buffer.create(4096)
		marks[v9] = v10
	end

	return v10, p - v6 * 16 + (p2 - v7 * 16) * 16 + (p3 - v8 * 16) * 256
end

local function isSolid(chunks, p: number, p2: number, p3: number): boolean -- 2 equivalent calls inferred from this helper
	local v6 = p // 16
	local v7 = p2 // 16
	local v8 = p3 // 16
	local v9 = chunks[chunkKey(v6, v7, v8)] -- inferred equivalent call

	return v9 ~= nil and readu8(v9.data, p - v6 * 16 + (p2 - v7 * 16) * 16 + (p3 - v8 * 16) * 256) ~= 0
end

function VoxelCore.stepSupportJob(data, state, p: number, callback, callback2)
	local minX = data.minX
	local minY = data.minY
	local minZ = data.minZ
	local maxX = data.maxX
	local maxY = data.maxY
	local maxZ = data.maxZ
	local chunks = data.chunks
	local groundRow = data.groundRow
	local marks = state.marks
	local stack = state.stack
	local visited = state.visited
	local seeds = state.seeds
	local count = 0

	while true do
		if state.resolveAt > 0 then
			local v6 = state.supported and 2 or 3
			local comp = state.comp
			local resolveAt = state.resolveAt
			local vn = state.vn

			while resolveAt <= vn do
				local v7 = visited[resolveAt]
				local v8 = visited[resolveAt + 1]
				local v9 = visited[resolveAt + 2]
				local buf2, v10 = jobMarkAt(marks, v7, v8, v9)
				writeu8(buf2, v10, v6)

				if comp then
					local v11 = callback(v7, v8, v9)

					if v11 ~= 0 then
						local count2 = #comp
						local v12 = count2 + 1
						local v13 = count2 + 2
						local v14 = count2 + 3
						local v15 = count2 + 4
						comp[v12] = v7
						comp[v13] = v8
						comp[v14] = v9
						comp[v15] = v11
					end
				end

				resolveAt += 3
				count += 1

				if count % 256 == 0 and p < os.clock() then
					state.resolveAt = resolveAt
					return false
				end
			end

			for i = 1, state.top, 3 do
				local buf2, v7 = jobMarkAt(marks, stack[i], stack[i + 1], stack[i + 2])
				writeu8(buf2, v7, v6)
			end

			state.top = 0
			state.vn = 0
			state.resolveAt = 0
			state.comp = nil

			if comp and #comp > 0 then
				callback2(comp)
			end
		elseif state.searching then
			local top = state.top
			local vn = state.vn
			local flag = false

			while top > 0 do
				local v6 = stack[top - 2]
				local v7 = stack[top - 1]
				local v8 = stack[top]
				top -= 3
				local v9 = vn + 1
				local v10 = vn + 2
				local v11 = vn + 3
				visited[v9] = v6
				visited[v10] = v7
				visited[v11] = v8
				vn += 3
				local v12

				if groundRow then
					v12 = v7 <= groundRow(v6, v8)
				else
					v12 = v7 == minY
				end

				if v12 then
					flag = true
					break
				end

				for i = 1, 18, 3 do
					local v13 = v6 + v5[i]
					local v14 = v7 + v5[i + 1]
					local v15 = v8 + v5[i + 2]

					if not (minX <= v13 and v13 <= maxX and minY <= v14 and v14 <= maxY) then
						continue
					end

					if not (minZ <= v15 and v15 <= maxZ and isSolid(chunks, v13, v14, v15)) then -- inferred equivalent call
						continue
					end

					local buf2, v16 = jobMarkAt(marks, v13, v14, v15)
					local v17 = readu8(buf2, v16)

					if v17 == 2 then
						flag = true
						break
					end

					if v17 ~= 0 then
						continue
					end

					writeu8(buf2, v16, 1)
					local v18 = top + 1
					local v19 = top + 2
					local v20 = top + 3
					stack[v18] = v13
					stack[v19] = v14
					stack[v20] = v15
					top += 3
				end

				if flag then
					break
				end

				count += 1

				if count % 256 == 0 and p < os.clock() then
					state.top = top
					state.vn = vn
					return false
				end
			end

			state.top = top
			state.vn = vn
			state.searching = false
			state.supported = flag
			state.resolveAt = 1
			local comp

			if not flag then
				comp = table.create(vn // 3 * 4)
			end

			state.comp = comp
		else
			if state.si * 3 >= #seeds then
				return true
			end

			local seed = seeds[state.si * 3 + 1]
			local seed2 = seeds[state.si * 3 + 2]
			local seed3 = seeds[state.si * 3 + 3]
			state.si += 1

			if isSolid(chunks, seed, seed2, seed3) then -- inferred equivalent call
				local buf2, v6 = jobMarkAt(marks, seed, seed2, seed3)

				if readu8(buf2, v6) == 0 then
					writeu8(buf2, v6, 1)
					stack[1] = seed
					stack[2] = seed2
					stack[3] = seed3
					state.top = 3
					state.vn = 0
					state.searching = true
				end
			end
		end
	end
end

function VoxelCore.extractComponent(p, list)
	local v6 = 1e999
	local v7 = 1e999
	local v8 = 1e999
	local v9 = -1e999
	local v10 = -1e999
	local v11 = -1e999

	for i = 1, #list, 4 do
		local item = list[i]
		local item2 = list[i + 1]
		local item3 = list[i + 2]

		if item < v6 then
			v6 = item
		end

		if item2 < v7 then
			v7 = item2
		end

		if item3 < v8 then
			v8 = item3
		end

		if v9 < item then
			v9 = item
		end

		if v10 < item2 then
			v10 = item2
		end

		if v11 < item3 then
			v11 = item3
		end
	end

	local v12 = v9 - v6 + 1
	local v13 = v10 - v7 + 1
	local v14 = v11 - v8 + 1
	local buf2 = buffer.create(v12 * v13 * v14)

	for i = 1, #list, 4 do
		local item = list[i]
		local item2 = list[i + 1]
		local item3 = list[i + 2]
		writeu8(buf2, item - v6 + v12 * (item2 - v7 + v13 * (item3 - v8)), list[i + 3])
		set(p, item, item2, item3, 0)
	end

	local v15 = {}
	return v6, v7, v8, v15, (VoxelCore.greedy(buf2, v12, v13, v14, buffer.create(v12 * v13 * v14), v15))
end

return VoxelCore