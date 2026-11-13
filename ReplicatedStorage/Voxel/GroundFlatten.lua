local RunService = game:GetService("RunService")

local Detail = require(script.Parent:WaitForChild("Detail"))

local Terrain = workspace.Terrain

local v = { "SolidOccupancy", "SolidMaterialIndex" }

local v2 = { [23] = 40, [37] = 41 }

local v3 = {
	[23] = 25,
	[24] = 25,
	[37] = 25,
	[40] = 25,
	[41] = 25
}

local v4 = {
	[23] = true,
	[24] = true,
	[37] = true,
	[40] = true,
	[41] = true,
	[43] = true,
	[25] = true,
	[26] = true,
	[28] = true,
	[34] = true,
	[39] = true
}
local v5 = {
	[23] = true,
	[24] = true,
	[37] = true,
	[40] = true,
	[41] = true
}

local MapSelect = require(script.Parent:WaitForChild("MapSelect"))
local function desert(name: string)
	local v6 = name == "sandline"

	for _, v7 in { 44, 30, 46, 49 } do
		v3[v7] = v6 and 45 or nil
	end

	for _, v7 in { 44, 45, 30, 46, 49 } do
		v4[v7] = v6 and true or nil
	end

	local v7 = name == "saltpan" or name == "drywell"

	for _, v8 in { 50, 52, 57 } do
		v3[v8] = v7 and 51 or v3[v8]
	end

	for _, v8 in { 50, 51, 52, 53, 57 } do
		v4[v8] = v7 and true or v4[v8]
	end

	if not v7 then
		for _, v8 in { 50, 51, 52, 53, 57 } do
			v3[v8] = nil
			v4[v8] = nil
		end
	end

	local v8 = name == "frostmill"

	for _, v9 in { 58, 59 } do
		v3[v9] = v8 and 63 or nil
	end

	v4[63] = v8 and true or nil

	v3[43] = name == "highcrag" and 25 or nil
end
desert(MapSelect.name)
MapSelect.onChange(desert, 10)

local v6 = {}

local set = {}
local count = 0
local v7 = {}
local v8 = {}
local floor = math.floor

local function key(p: number, p2: number) -- 2 equivalent calls inferred from this helper
	return (p + 65536) * 131072 + (p2 + 65536)
end

local set2 = {}
local count2 = 0
local v9 = {}
local v10 = {}

local function queueColumn(p: number, p2: number, y: number) -- 2 equivalent calls inferred from this helper
	local v11 = key(p, p2) -- inferred equivalent call

	if set[v11] then
		return
	end

	if count >= 32768 then
		table.clear(set)
		count = 0
	end

	set[v11] = true
	count += 1
	v8[v11] = floor(y / 4)
	table.insert(v7, v11)
end

local function press(p: number)
	local v11 = p // 131072 - 65536
	local v12 = p % 131072 - 65536
	local v13 = v8[p]
	v8[p] = nil

	if v13 == nil then
		return
	end

	local vector3 = Vector3.new(v11 * 4, (v13 - 1) * 4, v12 * 4)
	local region = Region3.new(vector3, vector3 + Vector3.new(4, 12, 4))
	local voxelChannels = Terrain:ReadVoxelChannels(region, 4, v)
	local v14 = voxelChannels.SolidMaterialIndex[1]
	local flag = false

	for i = 1, #v14 do
		local v15 = v2[v14[i][1]]

		if not v15 then
			continue
		end

		v14[i][1] = v15
		flag = true
	end

	if flag then
		Terrain:WriteVoxelChannels(region, 4, {
			SolidMaterialIndex = voxelChannels.SolidMaterialIndex
		})
	end
end

local function tear(p: number)
	local v11 = p // 131072 - 65536
	local v12 = p % 131072 - 65536
	local v13 = v10[p]
	v10[p] = nil

	if v13 == nil then
		return
	end

	local vector3 = Vector3.new(v11 * 4, (v13 - 1) * 4, v12 * 4)
	local region = Region3.new(vector3, vector3 + Vector3.new(4, 12, 4))
	local voxelChannels = Terrain:ReadVoxelChannels(region, 4, v)
	local v14 = voxelChannels.SolidMaterialIndex[1]
	local flag = false

	for i = 1, #v14 do
		local v15 = v3[v14[i][1]]

		if not v15 then
			continue
		end

		v14[i][1] = v15
		flag = true
	end

	if flag then
		Terrain:WriteVoxelChannels(region, 4, {
			SolidMaterialIndex = voxelChannels.SolidMaterialIndex
		})
	end
end

local function burn(data)
	local pos = data.pos
	local radius = data.radius
	local v11 = floor((pos.X - radius) / 4) * 4
	local v12 = floor((pos.Y - 12) / 4) * 4
	local v13 = (pos.Z - radius) / 4
	local vector3 = Vector3.new(v11, v12, floor(v13) * 4)
	local vector3_2 = Vector3.new(
		math.ceil((pos.X + radius) / 4) * 4,
		math.ceil((pos.Y + 8) / 4) * 4,
		math.ceil((pos.Z + radius) / 4) * 4
	)
	local region = Region3.new(vector3, vector3_2)
	local voxelChannels = Terrain:ReadVoxelChannels(region, 4, v)
	local solidMaterialIndex = voxelChannels.SolidMaterialIndex
	local solidOccupancy = voxelChannels.SolidOccupancy
	local flag = false

	for i = 1, #solidMaterialIndex do
		local v14 = solidMaterialIndex[i]
		local v15 = vector3.X + (i - 0.5) * 4

		for j = 1, #v14[1] do
			local v16 = vector3.Z + (j - 0.5) * 4
			local v17 = math.sqrt((v15 - pos.X) ^ 2 + (v16 - pos.Z) ^ 2) / radius
			local v18 = math.noise(v15 * 0.11, v16 * 0.11, data.seed) * 0.35
			local v19

			if v17 < 0.4 + v18 * 0.4 then
				v19 = "dirt"
			elseif v17 < 0.8 + v18 then
				v19 = "burnt"
			else
				v19 = if v17 < 1 + v18 * 0.6 then "singed" else nil
			end

			if not v19 then
				continue
			end

			for k = 1, #v14 do
				if not (solidOccupancy[i][k][j] > 0) then
					continue
				end

				local v20 = v14[k][j]
				local v21

				if v19 == "dirt" then
					v21 = v3[v20]
				elseif v19 == "burnt" then
					v21 = v4[v20] and 42 or nil
				else
					v21 = v5[v20] and 43 or nil
				end

				if not (v21 and v21 ~= v20) then
					continue
				end

				v14[k][j] = v21
				flag = true
			end
		end
	end

	if flag then
		Terrain:WriteVoxelChannels(region, 4, { SolidMaterialIndex = solidMaterialIndex })
	end
end

local GroundFlatten = {}
GroundFlatten.TO_DIRT = v3
local parent = script.Parent
local function off(): boolean -- 3 equivalent calls inferred from this helper
	return parent:GetAttribute("GroundPress") == false
end

function GroundFlatten.scorch(pos: Vector3, radius: number)
	if Detail.strain >= 1 then
		return
	end

	if Detail.low then
		local distance = Detail.distance(pos)

		if radius + 320 < distance then
			return
		end
	end

	if off() then -- inferred equivalent call
		return
	end

	table.insert(v6, {
		pos = pos,
		radius = radius,
		seed = math.random() * 100
	})
end

function GroundFlatten.dirt(vector3: Vector3, p: number)
	if Detail.strain >= 1 then
		return
	end

	if Detail.low then
		local distance = Detail.distance(vector3)

		if p + 320 < distance then
			return
		end
	end

	if off() then -- inferred equivalent call
		return
	end

	local v11 = floor(vector3.X / 4)
	local v12 = floor(vector3.Z / 4)
	local v13 = math.ceil(p / 4)

	for i = -v13, v13 do
		for j = -v13, v13 do
			local v14 = (v11 + j + 0.5) * 4
			local v15 = (v12 + i + 0.5) * 4

			if not (j == 0 and i == 0 or (v14 - vector3.X) ^ 2 + (v15 - vector3.Z) ^ 2 <= p * p) then
				continue
			end

			local v16 = key(v11 + j, v12 + i) -- inferred equivalent call

			if set2[v16] then
				continue
			end

			if count2 >= 32768 then
				table.clear(set2)
				count2 = 0
			end

			set2[v16] = true
			count2 += 1
			v10[v16] = floor(vector3.Y / 4)
			table.insert(v9, v16)
		end
	end
end

function GroundFlatten.at(vector3: Vector3, p: number)
	if off() or Detail.strain >= 1 then -- inferred equivalent call
		return
	end

	local v11 = floor(vector3.X / 4)
	local v12 = floor(vector3.Z / 4)
	queueColumn(v11, v12, vector3.Y) -- inferred equivalent call
	local v13 = math.ceil(p / 4)

	for i = -v13, v13 do
		for j = -v13, v13 do
			local v14 = (v11 + j + 0.5) * 4
			local v15 = (v12 + i + 0.5) * 4

			if (v14 - vector3.X) ^ 2 + (v15 - vector3.Z) ^ 2 <= p * p then
				queueColumn(v11 + j, v12 + i, vector3.Y) -- inferred equivalent call
			end
		end
	end
end

local v11 = 1
local v12 = 1
local v13 = 1
local v14 = {}
local total = 0

local MapSelect2 = require(script.Parent:WaitForChild("MapSelect"))
MapSelect2.onChange(function()
	for _, v15 in v14 do
		v8[v15] = nil
	end

	table.clear(v14)
end)
local function farOff(p: number, position: Vector3): boolean -- 2 equivalent calls inferred from this helper
	local v15 = p // 131072 - 65536
	local v16 = p % 131072 - 65536
	local v17 = (v15 + 0.5) * 4 - position.X
	local v18 = (v16 + 0.5) * 4 - position.Z
	return v17 * v17 + v18 * v18 > 102400
end

RunService.Heartbeat:Connect(function(dt: number)
	local v15 = 3

	if v11 <= #v6 then
		local v16 = v6[v11]
		v11 += 1

		if v11 > #v6 then
			table.clear(v6)
			v11 = 1
		end

		burn(v16)
		v15 -= 1
	end

	while v15 > 0 and v12 <= #v9 do
		local v16 = v9[v12]
		v12 += 1
		tear(v16)
		v15 -= 1
	end

	if v12 > #v9 then
		table.clear(v9)
		v12 = 1
	end

	local position

	if Detail.low then
		position = workspace.CurrentCamera.CFrame.Position
	end

	while v15 > 0 and v13 <= #v7 do
		local v16 = v7[v13]
		v13 += 1

		if position and farOff(v16, position) then -- inferred equivalent call
			table.insert(v14, v16)
			continue
		end

		press(v16)
		v15 -= 1
	end

	if v13 > #v7 then
		table.clear(v7)
		v13 = 1
	end

	total += dt

	if total >= 1 and #v14 > 0 then
		total = 0

		for i = #v14, 1, -1 do
			if position ~= nil and farOff(v14[i], position) then -- inferred equivalent call
				continue
			end

			table.insert(v7, v14[i])
			v14[i] = v14[#v14]
			v14[#v14] = nil
		end
	end
end)

return GroundFlatten