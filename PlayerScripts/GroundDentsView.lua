local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local GroundHeight = require(Voxel:WaitForChild("GroundHeight"))
local GroundMarks = require(Voxel:WaitForChild("GroundMarks"))
local GroundFlatten = require(Voxel:WaitForChild("GroundFlatten"))
local TO_DIRT = GroundFlatten.TO_DIRT
local Remotes = Voxel:WaitForChild("Remotes")
local GroundDent = Remotes:WaitForChild("GroundDent")
local GroundDentSnapshot = Remotes:WaitForChild("GroundDentSnapshot")
local WorldReset = Remotes:WaitForChild("WorldReset")

local v = -1
local v2 = {}

local v3 = {}

local raycastParams = RaycastParams.new()
raycastParams.IncludeInstances = { workspace.Terrain }
raycastParams.IgnoreWater = true

assert(GroundHeight.COL == 4, "GroundDentsView: GroundHeight columns must match the 4-stud terrain voxels")

local function cut(list)
	if #list == 0 then
		return
	end

	local minValue = 1e999
	local maxValue = -1e999
	local minValue2 = 1e999
	local maxValue2 = -1e999
	local maxValue3 = -1e999
	local minValue3 = 1e999

	for _, item in list do
		minValue = math.min(minValue, item[1])
		maxValue = math.max(maxValue, item[1])
		minValue2 = math.min(minValue2, item[2])
		maxValue2 = math.max(maxValue2, item[2])
		maxValue3 = math.max(maxValue3, item[3])
		minValue3 = math.min(minValue3, item[4])
	end

	local columnCenter, v4 = GroundHeight.columnCenter(minValue, minValue2)
	local columnCenter2, v5 = GroundHeight.columnCenter(maxValue, maxValue2)

	local vector3 = Vector3.new(columnCenter - 2, math.floor((minValue3 - 2 - 8) / 4) * 4, v4 - 2)
	local vector3_2 = Vector3.new(columnCenter2 + 2, math.ceil((maxValue3 + 8) / 4) * 4, v5 + 2)
	local region = Region3.new(vector3, vector3_2)
	local voxelChannels = workspace.Terrain:ReadVoxelChannels(region, 4, { "SolidOccupancy", "SolidMaterialIndex" })
	local solidOccupancy = voxelChannels.SolidOccupancy
	local solidMaterialIndex = voxelChannels.SolidMaterialIndex
	local flag = false

	for _, item in list do
		local v6 = solidOccupancy[item[1] - minValue + 1]
		local v7 = solidMaterialIndex[item[1] - minValue + 1]
		local v8 = item[2] - minValue2 + 1
		local v9 = false

		for i = #v6, 1, -1 do
			local v10 = v6[i][v8]
			local v11 = math.clamp((item[4] - 2 - (vector3.Y + (i - 1) * 4)) / 4, 0, 1)
			local v12 = math.min(v10, v11)

			if v12 ~= v10 then
				v6[i][v8] = v12
				flag = true
			end

			if v12 > 0 and not v9 then
				v9 = true
				local v13 = TO_DIRT[v7[i][v8]]

				if v13 then
					v7[i][v8] = v13
					flag = true
				end

				if i > 1 then
					local v14 = TO_DIRT[v7[i - 1][v8]]

					if v14 then
						v7[i - 1][v8] = v14
						flag = true
					end
				end
			end

			if v9 and v11 >= 1 then
				break
			end
		end
	end

	if flag then
		workspace.Terrain:WriteVoxelChannels(region, 4, {
			SolidOccupancy = solidOccupancy,
			SolidMaterialIndex = solidMaterialIndex
		})
	end
end

local function apply(buf: buffer, flag: boolean?)
	local v4 = {}
	local v5 = -1e999
	local v6 = -1
	local v7 = -1
	local v8 = 0

	for i = 0, buffer.len(buf) // 8 - 1 do
		local v9 = buffer.readu16(buf, i * 8)
		local v10 = buffer.readu16(buf, i * 8 + 2)
		local v11 = buffer.readf32(buf, i * 8 + 4)
		local columnHeight = GroundHeight.columnHeight(v9, v10)
		local v12 = columnHeight - v11
		GroundHeight.lower(v9, v10, v11)

		if flag and v12 > 0 then
			table.insert(v4, { v9, v10, columnHeight, v11 })
		end

		if not (v5 < v12) then
			continue
		end

		v8 = v11
		v7 = v10
		v6 = v9
		v5 = v12
	end

	if flag then
		cut(v4)
	end

	return v6, v7, v8
end

local function dent(buf: buffer, center: Vector3, radius: number)
	local v4, v5, v6 = apply(buf, true)

	if v4 >= 0 then
		local columnCenter, v7 = GroundHeight.columnCenter(v4, v5)
		table.insert(v3, {
			x = columnCenter,
			z = v7,
			h = v6,
			center = center,
			radius = radius,
			giveUp = os.clock() + 1.5,
			nextAt = 0
		})
	end
end

GroundDent.OnClientEvent:Connect(function(p: number, buf: buffer, center: Vector3, radius: number)
	if v < 0 then
		table.insert(v2, { p, buf, center, radius })
	elseif p == v then
		dent(buf, center, radius)
	end
end)

WorldReset.OnClientEvent:Connect(function(p: number, _: Vector3, flag: boolean)
	if not flag then
		GroundHeight.restore()
	end

	table.clear(v3)
	v = p
end)

task.spawn(function()
	local v4, v5 = GroundDentSnapshot:InvokeServer()

	if type(v4) ~= "number" or typeof(v5) ~= "buffer" then
		error("GroundDentsView: bad GroundDentSnapshot reply")
	end

	if v >= 0 and v4 < v then
		return
	end

	v = v4
	apply(v5)

	for _, v6 in v2 do
		if v6[1] == v4 then
			dent(v6[2], v6[3], v6[4])
		end
	end

	table.clear(v2)
end)

RunService.Heartbeat:Connect(function()
	if #v3 == 0 then
		return
	end

	local now = os.clock()

	for i = #v3, 1, -1 do
		local v4 = v3[i]

		if now < v4.giveUp and now < v4.nextAt then
			continue
		end

		v4.nextAt = now + 0.1
		local raycastResult

		if now < v4.giveUp then
			raycastResult = workspace:Raycast(Vector3.new(v4.x, v4.h + 8, v4.z), Vector3.new(0, -14, 0), raycastParams)
		end

		if not (v4.giveUp <= now or raycastResult and raycastResult.Position.Y < v4.h + 0.6) then
			continue
		end

		table.remove(v3, i)
		GroundMarks.redrape(v4.center, v4.radius)
	end
end)