--!native
local VoxelCore = require(script.Parent.VoxelCore)
local Materials = require(script.Parent.Materials)
local WorldConfig = require(script.Parent.WorldConfig)

local readu8 = buffer.readu8
local writeu8 = buffer.writeu8
local readi16 = buffer.readi16
local writei16 = buffer.writei16
local floor = math.floor
local sqrt = math.sqrt
local max = math.max
local abs = math.abs

local chunk = VoxelCore.CHUNK
local v = chunk * chunk

local v2 = { -1, 1, 0, 0, 0, 0 }
local v3 = { 0, 0, -1, 1, 0, 0 }
local v4 = { 0, 0, 0, 0, -1, 1 }

local v5 = nil
local v6 = false
local function v7() end
local function v8() end
local hit = nil
local v9 = 0
local groundRow = nil
local v10 = 1
local v11 = 1
local v12 = 8
local v13 = {}
local v14 = {}
local count = 0
local v15 = 0
local v16 = { breaks = 0, landed = 0, stepMs = 0 }

local v17 = table.create(256, 0)
local v18 = table.create(256, 0)
local v19 = 1
local flag = false
local function derivePalette()
	for k, v20 in Materials.Palette do
		v17[k] = v20.type.strength
		v18[k] = v20.type.density * 500 * v19
	end

	v17[255] = 0
end

local v20 = {}
local v21 = {}
local v22 = {}
local v23 = {}
local v24 = {}
local v25 = {}
local v26 = {}
local v27 = {}
local v28 = {}
local v29 = {}
local v30 = {}
local v31 = {}
local buf = buffer.create(4096)
local Collapse = {}

function Collapse.init(data, data2)
	v5 = data
	v6 = data2.carve ~= nil

	if data2.carve then
		v7 = data2.carve
	end

	if data2.landed then
		v8 = data2.landed
	end

	hit = data2.hit
	v9 = data.minY
	groundRow = data.groundRow
	v10 = data.voxelSize
	v11 = WorldConfig.METER * WorldConfig.BLAST_SCALE
	v12 = max(1, (floor(v11 * 1 / v10 + 0.5)))
	v19 = (v10 / v11) ^ 3

	if flag then
		derivePalette()
		return
	end

	flag = true
	Materials.derive(derivePalette)
end

local function speedUnit() -- 1 equivalent call inferred from this helper
	return v11 * sqrt(workspace.Gravity / (v11 * 10))
end

function Collapse.accepts(p: number): boolean
	return p >= 64 and #v13 < 96
end

function Collapse.add(list, vector3: Vector3, id: number?)
	local cellCount = #list // 4
	local v32 = 1e999
	local v34 = 1e999
	local v35 = 1e999
	local v36 = -1e999
	local v37 = -1e999
	local v38 = -1e999
	local total = 0

	for i = 1, #list, 4 do
		local item = list[i]
		local item2 = list[i + 1]
		local item3 = list[i + 2]

		if item < v32 then
			v32 = item
		end

		if item2 < v34 then
			v34 = item2
		end

		if item3 < v35 then
			v35 = item3
		end

		if v36 < item then
			v36 = item
		end

		if v37 < item2 then
			v37 = item2
		end

		if v38 < item3 then
			v38 = item3
		end

		total += v18[list[i + 3]]
	end

	local sx = v36 - v32 + 1
	local sy = v37 - v34 + 1
	local sz = v38 - v35 + 1
	local v42 = sx * sy
	local v43 = v42 * sz

	if buffer.len(buf) < v43 then
		buf = buffer.create(v43)
	else
		buffer.fill(buf, 0, 0, v43)
	end

	local buf2

	if v6 then
		buf2 = buffer.create(cellCount * 8)
	end

	for i = 1, #list, 4 do
		local v44 = list[i] - v32
		local v45 = list[i + 1] - v34
		local v46 = list[i + 2] - v35
		writeu8(buf, v44 + sx * v45 + v42 * v46, list[i + 3])

		if not buf2 then
			continue
		end

		local v49 = (i - 1) // 4 * 8
		writei16(buf2, v49, v44)
		writei16(buf2, v49 + 2, v45)
		writei16(buf2, v49 + 4, v46)
		local item = list[i + 3]
		writeu8(buf2, v49 + 6, item)
	end

	local bufs = table.create(6)
	local faceCount = { 0, 0, 0, 0, 0, 0 }

	for i = 1, 2 do
		if i == 2 then
			for j = 1, 6 do
				bufs[j] = buffer.create(faceCount[j] * 8)
				faceCount[j] = 0
			end
		end

		for j = 1, #list, 4 do
			local v45 = list[j] - v32
			local v46 = list[j + 1] - v34
			local v47 = list[j + 2] - v35

			for k = 1, 6 do
				local v48 = v45 + v2[k]
				local v49 = v46 + v3[k]
				local v50 = v47 + v4[k]
				local v51

				if v48 >= 0 and v48 < sx and v49 >= 0 and v49 < sy and v50 >= 0 and v50 < sz then
					v51 = readu8(buf, v48 + sx * v49 + v42 * v50) ~= 0
				else
					v51 = false
				end

				if v51 then
					continue
				end

				local v52 = faceCount[k]

				if i == 2 then
					local buf3 = bufs[k]
					local v53 = v52 * 8
					writei16(buf3, v53, v45)
					writei16(buf3, v53 + 2, v46)
					writei16(buf3, v53 + 4, v47)
					writeu8(buf3, v53 + 6, list[j + 3])
				end

				faceCount[k] = v52 + 1
			end
		end
	end

	if id == nil then
		count += 1
		id = count
	end

	local v45 = {
		id = id,
		x = v32,
		y = v34,
		z = v35,
		ax = 0,
		ay = 0,
		az = 0,
		vx = vector3.X,
		vy = vector3.Y,
		vz = vector3.Z,
		sx = sx,
		sy = sy,
		sz = sz,
		faces = bufs,
		faceCount = faceCount,
		cells = buf2,
		cellCount = cellCount,
		mass = total,
		age = 0,
		rest = 0
	}

	table.insert(v13, v45)
	v14[id] = v45
	return id
end

Collapse.MAX_FALL_TIME = 15

function Collapse.get(p: number)
	return v14[p]
end

local function removeAt(p: number) -- 2 equivalent calls inferred from this helper
	local v32 = v13[p]
	v13[p] = v13[#v13]
	v13[#v13] = nil
	v14[v32.id] = nil
end

function Collapse.remove(p: number)
	local v32 = v14[p]

	if v32 then
		removeAt(table.find(v13, v32)) -- inferred equivalent call
	end
end

function Collapse.clear()
	table.clear(v13)
	table.clear(v14)
	v9 = v5.minY
end

local function gather(data, p: number, flag2: boolean)
	local face = data.faces[p]
	local v32 = data.faceCount[p]
	local v33 = data.x + v2[p]
	local v34 = data.y + v3[p]
	local v35 = data.z + v4[p]
	local chunks = v5.chunks
	local v36 = -1
	local count2 = 0
	local data2 = nil

	for i = 0, v32 - 1 do
		local v37 = i * 8
		local v38 = v33 + readi16(face, v37)
		local v40 = v34 + readi16(face, v37 + 2)
		local v42 = v35 + readi16(face, v37 + 4)
		local v43 = 0
		local v44

		if groundRow then
			v44 = v40 < groundRow(v38, v42)
		else
			v44 = v40 < v9
		end

		if v44 then
			v43 = 255
		else
			local v45 = v38 // chunk
			local v46 = v40 // chunk
			local v47 = v42 // chunk
			local v48 = v45 + 1024 + (v46 + 1024) * 2048 + (v47 + 1024) * 4194304

			if v48 ~= v36 then
				local chunk2 = chunks[v48]

				if chunk2 then
					data2 = chunk2.data
					v36 = v48
				else
					v36 = v48
					data2 = nil
				end
			end

			if data2 then
				v43 = readu8(data2, v38 - v45 * chunk + chunk * (v40 - v46 * chunk) + v * (v42 - v47 * chunk))
			end
		end

		if v43 == 0 then
			continue
		end

		count2 += 1
		local v46 = readu8(face, v37 + 6)
		v20[count2] = v38
		v21[count2] = v40
		v22[count2] = v42
		v23[count2] = v43
		v24[count2] = v46

		if not flag2 then
			return count2
		end
	end

	return count2
end

local function impact(state, p: number, p2: number, p3: number)
	local v32 = abs(p2) / p3

	if hit and v32 > 1 and not state.held then
		hit(state.id, v32)
	end

	if v32 <= 6 then
		return 0
	end

	if v6 and v15 <= 0 then
		return p2
	end

	local v33 = gather(state, p, true)

	if v33 == 0 then
		return p2
	end

	local v34 = v12
	local count2 = 0

	for i = 1, v33 do
		local v35 = v20[i] // v34 + 2048 + (v21[i] // v34 + 2048) * 4096 + (v22[i] // v34 + 2048) * 16777216
		local v36 = v25[v35]

		if v36 == nil then
			count2 += 1

			v25[v35] = count2
			local v37 = v23[i]
			local v38 = v24[i]
			v26[count2] = 0
			v27[count2] = 0
			v28[count2] = 0
			v29[count2] = 0
			v30[count2] = v37
			v31[count2] = v38
			v36 = count2
		end

		v26[v36] += 1
		v27[v36] += v20[i]
		v28[v36] += v21[i]
		v29[v36] += v22[i]

		local v41 = v23[i]

		if v17[v41] > 0 and (v17[v30[v36]] == 0 or v17[v41] < v17[v30[v36]]) then
			v30[v36] = v41
		end
	end

	table.clear(v25)

	local v35 = state.mass * v32

	local v36 = v2[p] * 0.5
	local v37 = v3[p] * 0.5
	local v38 = v4[p] * 0.5
	local origin = v5.origin
	local total = 0
	local v39 = false

	for i = 1, count2 do
		local v40 = v35 * v26[i] / v33
		local v41 = v17[v30[i]] * 1200
		local v42 = v17[v31[i]] * 1200

		if v41 > 0 and v41 < v40 then
			v40 = v41
		end

		if v42 > 0 and v42 < v40 then
			v40 = v42
		end

		total += v40

		if not (v41 > 0 and v40 / v41 > 0.05) then
			continue
		end

		if not v6 then
			state.held = true
			return p2
		end

		if not (v15 > 0) then
			continue
		end

		local v43 = v40 / v41
		v15 -= 1

		v16.breaks += 1
		local v45 = 1 / v26[i]

		local v46 = origin + Vector3.new(v27[i] * v45 + 0.5 - v36, v28[i] * v45 + 0.5 - v37, v29[i] * v45 + 0.5 - v38) * v10
		v7(v46, 1.2 * v43 * v11, 0.8 * v43 * v11, 0)
		v39 = true
	end

	if not v39 then
		return 0
	end

	local v41 = max(0, v32 - total / state.mass)

	if p2 < 0 then
		return -v41 * p3
	end

	return v41 * p3
end

local function moveAxis(state, p: number, p2: number, p3: number, p4: number)
	local v32

	if p == 1 then
		v32 = state.ax
	else
		v32 = if p == 2 then state.ay else state.az
	end

	local v33 = v32 + p2
	local v34 = false

	while v33 >= 1 or v33 <= -1 do
		local v35 = v33 > 0 and 1 or -1
		local v36 = p * 2 - (v35 < 0 and 1 or 0)

		if gather(state, v36, false) > 0 then
			p3 = impact(state, v36, p3, p4)
			v33 = 0
			v34 = true
			break
		end

		if p == 1 then
			state.x += v35
		elseif p == 2 then
			state.y += v35
		else
			state.z += v35
		end

		state.held = nil
		v33 -= v35
	end

	if p == 1 then
		state.ax = v33
	elseif p == 2 then
		state.ay = v33
	else
		state.az = v33
	end

	return p3, v34
end

local function land(p: number, p2: number): boolean
	local v32 = v13[p]
	local cells = v32.cells
	local x = v32.x
	local y = v32.y
	local z = v32.z
	local cellCount = v32.cellCount
	local landing = v32.landing or 0

	while landing < cellCount do
		local v33 = landing * 8
		local v34 = x + readi16(cells, v33)
		local v36 = y + readi16(cells, v33 + 2)
		local v38 = z + readi16(cells, v33 + 4)

		if VoxelCore.get(v5, v34, v36, v38) == 0 then
			local set = VoxelCore.set
			set(v5, v34, v36, v38, (readu8(cells, v33 + 6)))
		end

		landing += 1

		if landing % 512 == 0 and landing < cellCount and p2 < os.clock() then
			v32.landing = landing
			return false
		end
	end

	removeAt(p) -- inferred equivalent call
	v16.landed += 1
	v8(v32.id)
	return true
end

function Collapse.blast(vector3: Vector3, p: number)
	local origin = v5.origin

	for _, v32 in v13 do
		local v33 = origin + Vector3.new(v32.x + v32.sx * 0.5, v32.y + v32.sy * 0.5, v32.z + v32.sz * 0.5) * v10
		local blastVelocity = WorldConfig.blastVelocity(vector3, p, v33)
		v32.vx += blastVelocity.X
		v32.vy += blastVelocity.Y
		v32.vz += blastVelocity.Z
	end
end

function Collapse.step(p: number)
	if #v13 == 0 then
		v16.stepMs = 0
		return
	end

	local lastTime = os.clock()
	local v32 = lastTime + 0.004
	v15 = 6
	local gravity = workspace.Gravity
	local v33 = speedUnit() -- inferred equivalent call
	local v34 = v33 * 0.3
	local v35 = 0.6 * gravity * p
	local v36 = 1

	while v36 <= #v13 do
		local v37 = v13[v36]

		if v37.landing then
			if not land(v36, v32) then
				v36 += 1
			end
		else
			v37.age += p
			v37.vy -= gravity * p

			local v38 = v37.vy * p / v10
			local v39

			if v37.vy < 0 and v37.ay + v38 > -1 and gather(v37, 3, false) > 0 then
				v37.vy = 0
				v37.ay = 0
				v39 = true
			else
				local vy, v41 = moveAxis(v37, 2, v38, v37.vy, v33)
				v37.vy = vy
				v39 = v41 and v37.vy <= 0
			end

			if v39 then
				local v41 = sqrt(v37.vx * v37.vx + v37.vz * v37.vz)
				local v42 = not (v35 < v41) and 0 or (v41 - v35) / v41
				v37.vx *= v42
				v37.vz *= v42
			end

			if v37.vx ~= 0 then
				v37.vx = moveAxis(v37, 1, v37.vx * p / v10, v37.vx, v33)
			end

			if v37.vz ~= 0 then
				v37.vz = moveAxis(v37, 3, v37.vz * p / v10, v37.vz, v33)
			end

			if v39 then
				if abs(v37.vx) < v34 then
					if abs(v37.vz) < v34 then
						v37.rest += p
					else
						v37.rest = 0
					end
				else
					v37.rest = 0
				end
			else
				v37.rest = 0
			end

			if v6 and (v37.rest > 0.25 or v37.age > 15) then
				if not land(v36, v32) then
					v36 += 1
				end
			else
				v36 += 1
			end
		end
	end

	v16.stepMs = (os.clock() - lastTime) * 1000
end

function Collapse.stats()
	return #v13, v16.landed, v16.breaks, v16.stepMs
end

return Collapse