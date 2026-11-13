--!native
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VoxelCore = require(ReplicatedStorage.Voxel.VoxelCore)
local Materials = require(ReplicatedStorage.Voxel.Materials)
local WorldConfig = require(ReplicatedStorage.Voxel.WorldConfig)

local VOXEL_SIZE = WorldConfig.VOXEL_SIZE
local Palette = Materials.Palette

local VehicleGrid = {
	EDIT = 3,
	key = function(p, p2: number, p3: number, p4: number)
		return p2 + p.sx * (p3 + p.sy * p4)
	end,
	unkey = function(p, p2: number)
		return p2 % p.sx, p2 // p.sx % p.sy, p2 // (p.sx * p.sy)
	end,
	cellCenter = function(p, p2: number, p3: number, p4: number)
		return p.origin + Vector3.new(p2 + 0.5, p3 + 0.5, p4 + 0.5) * VOXEL_SIZE
	end,
	copy = function(p)
		local buf = buffer.create(buffer.len(p.data))
		buffer.copy(buf, 0, p.data)
		return buf
	end,
	newWorld = function(data)
		local world = VoxelCore.newWorld(VOXEL_SIZE, data.origin, nil)
		local data2 = data.data

		for i = 0, data.sz - 1 do
			for j = 0, data.sy - 1 do
				for k = 0, data.sx - 1 do
					local v = buffer.readu8(data2, k + data.sx * (j + data.sy * i))

					if v ~= 0 then
						VoxelCore.set(world, k, j, i, v)
					end
				end
			end
		end

		table.clear(world.dirty)
		return world
	end,
	hullCount = function(p, p2: number)
		local count = 0

		for _, chunk in p.chunks do
			if not (chunk.count > 0) then
				continue
			end

			local data = chunk.data

			for i = 0, buffer.len(data) - 1 do
				local v = buffer.readu8(data, i)

				if v ~= 0 and v ~= p2 then
					count += 1
				end
			end
		end

		return count
	end,
	bufferHullCount = function(p, buf: buffer)
		local count = 0

		for i = 0, buffer.len(buf) - 1 do
			local v = buffer.readu8(buf, i)

			if v ~= 0 and v ~= p.frame then
				count += 1
			end
		end

		return count
	end,
	health = function(p: number, p2: number, p3: number)
		if p2 <= 0 then
			return 0
		end

		return (math.clamp((p / p2 - p3) / (1 - p3), 0, 1))
	end
}

function VehicleGrid.encodeEdits(list, list2)
	local count = #list
	local buf = buffer.create(count * VehicleGrid.EDIT)

	for i = 1, count do
		local v = (i - 1) * VehicleGrid.EDIT
		buffer.writeu16(buf, v, list[i])
		buffer.writeu8(buf, v + 2, list2[i])
	end

	return buf
end

function VehicleGrid.decodeEdits(buf: buffer, callback)
	for i = 0, buffer.len(buf) - VehicleGrid.EDIT, VehicleGrid.EDIT do
		callback(buffer.readu16(buf, i), (buffer.readu8(buf, i + 2)))
	end
end

function VehicleGrid.encodePieces(p, items)
	local total = 0

	for _, item in items do
		total += 14 + #item.cells // 4 * VehicleGrid.EDIT
	end

	local buf = buffer.create(total)
	local total2 = 0

	for _, item in items do
		local v = #item.cells // 4
		buffer.writeu16(buf, total2, v)
		buffer.writef32(buf, total2 + 2, item.velocity.X)
		buffer.writef32(buf, total2 + 6, item.velocity.Y)
		buffer.writef32(buf, total2 + 10, item.velocity.Z)
		total2 += 14

		for i = 0, v - 1 do
			local cell = item.cells[i * 4 + 1]
			local cell2 = item.cells[i * 4 + 2]
			local cell3 = item.cells[i * 4 + 3]
			local cell4 = item.cells[i * 4 + 4]
			buffer.writeu16(buf, total2, (VehicleGrid.key(p, cell, cell2, cell3)))
			buffer.writeu8(buf, total2 + 2, cell4)
			total2 += VehicleGrid.EDIT
		end
	end

	return buf
end

function VehicleGrid.decodePieces(p, buf: buffer, callback)
	local v = buffer.len(buf)
	local total = 0

	while total + 14 <= v do
		local v2 = buffer.readu16(buf, total)
		local vector3 = Vector3.new(
			buffer.readf32(buf, total + 2),
			buffer.readf32(buf, total + 6),
			(buffer.readf32(buf, total + 10))
		)
		total += 14
		local v3 = table.create(v2 * 4)

		for i = 0, v2 - 1 do
			local unkey, v4, v5 = VehicleGrid.unkey(p, (buffer.readu16(buf, total)))
			local v6 = i * 4 + 1
			local v7 = i * 4 + 2
			local v8 = i * 4 + 3
			local v9 = i * 4 + 4
			local v10 = buffer.readu8(buf, total + 2)
			v3[v6] = unkey
			v3[v7] = v4
			v3[v8] = v5
			v3[v9] = v10
			total += VehicleGrid.EDIT
		end

		callback(v3, vector3)
	end
end

function VehicleGrid.raycast(p, p2, cframe: CFrame, vector3: Vector3, vector3_2: Vector3, p3: number)
	local pointToObjectSpace = cframe:PointToObjectSpace(vector3)
	local vectorToObjectSpace = cframe:VectorToObjectSpace(vector3_2.Unit)
	local origin = p2.origin
	local v = p2.origin + p2.size
	local maxValue = 0

	for i = 1, 3 do
		local v2

		if i == 1 then
			v2 = pointToObjectSpace.X
		elseif i == 2 then
			v2 = pointToObjectSpace.Y
		else
			v2 = pointToObjectSpace.Z
		end

		local v3

		if i == 1 then
			v3 = vectorToObjectSpace.X
		elseif i == 2 then
			v3 = vectorToObjectSpace.Y
		else
			v3 = vectorToObjectSpace.Z
		end

		local v4

		if i == 1 then
			v4 = origin.X
		else
			v4 = if i == 2 then origin.Y else origin.Z
		end

		local v5

		if i == 1 then
			v5 = v.X
		else
			v5 = if i == 2 then v.Y else v.Z
		end

		if math.abs(v3) < 1e-9 then
			if v2 < v4 or v5 < v2 then
				return nil, nil, nil, 0, nil
			end
		else
			local v6 = (v4 - v2) / v3
			local v7 = (v5 - v2) / v3

			if v7 < v6 then
				v7, v6 = v6, v7
			end

			maxValue = math.max(maxValue, v6)
			p3 = math.min(p3, v7)

			if p3 < maxValue then
				return nil, nil, nil, 0, nil
			end
		end
	end

	local v2 = pointToObjectSpace + vectorToObjectSpace * math.max(maxValue - 0.001, 0)
	local raycast, v3, v4, v5 = VoxelCore.raycast(p, v2, vectorToObjectSpace, p3 - maxValue + 0.002)

	if not (raycast and v3) then
		return nil, nil, nil, 0, nil
	end

	local v6 = math.max(maxValue - 0.001, 0) + v5

	if not (v3.Magnitude > 0.5) then
		v3 = -vectorToObjectSpace
	end

	return v6, cframe:PointToWorldSpace(raycast), cframe:VectorToWorldSpace(v3), v4, raycast
end

local function cellMoments(data, buf: buffer)
	local x = data.origin.X
	local y = data.origin.Y
	local z = data.origin.Z
	local sx = data.sx
	local sy = data.sy
	local frame = data.frame
	local total = 0
	local total2 = 0
	local total3 = 0
	local total4 = 0
	local total5 = 0
	local total6 = 0
	local total7 = 0

	for i = 0, data.sz - 1 do
		local v = z + (i + 0.5) * VOXEL_SIZE

		for j = 0, sy - 1 do
			local v2 = y + (j + 0.5) * VOXEL_SIZE
			local v3 = sx * (j + sy * i)

			for k = 0, sx - 1 do
				local v4 = buffer.readu8(buf, k + v3)

				if v4 == 0 then
					continue
				end

				local v5 = v4 == frame and 8 or Palette[v4].type.density
				local v6 = x + (k + 0.5) * VOXEL_SIZE
				total += v5
				total2 += v6 * v5
				total3 += v2 * v5
				total4 += v * v5
				total5 += v6 * v6 * v5
				total6 += v2 * v2 * v5
				total7 += v * v * v5
			end
		end
	end

	return total, total2, total3, total4, total5, total6, total7
end

local function finishMass(p: number, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number)
	assert(p > 0, "[VehicleGrid] hull has no mass")
	local vector3 = Vector3.new(p2, p3, p4) / p

	local v = VOXEL_SIZE * VOXEL_SIZE / 6
	local v2 = p5 / p - vector3.X * vector3.X + v
	local v3 = p6 / p - vector3.Y * vector3.Y + v
	local v4 = p7 / p - vector3.Z * vector3.Z + v
	local v5 = p * (v3 + v4)
	local v6 = p * (v2 + v4)
	local v7 = p * (v2 + v3)
	return p, vector3, (Vector3.new(1 / v5, 1 / v6, 1 / v7))
end

function VehicleGrid.massProps(p, buf: buffer, options)
	local v, v2, v3, v4, v5, v6, v7 = cellMoments(p, buf)

	for _, v8 in options or {} do
		local pos = v8.pos
		local mass = v8.mass
		v += mass
		v2 += pos.X * mass
		v3 += pos.Y * mass
		v4 += pos.Z * mass
		v5 += pos.X * pos.X * mass
		v6 += pos.Y * pos.Y * mass
		v7 += pos.Z * pos.Z * mass
	end

	return finishMass(v, v2, v3, v4, v5, v6, v7)
end

function VehicleGrid.massPropsShare(p, buf: buffer, items, p2: number)
	local v, v2, v3, v4, v5, v6, v7 = cellMoments(p, buf)
	local v8 = v * p2

	for _, item in items do
		v += v8
		v2 += item.X * v8
		v3 += item.Y * v8
		v4 += item.Z * v8
		v5 += item.X * item.X * v8
		v6 += item.Y * item.Y * v8
		v7 += item.Z * item.Z * v8
	end

	return finishMass(v, v2, v3, v4, v5, v6, v7)
end

return VehicleGrid