--!native
local Materials = require(script.Parent:WaitForChild("Materials"))

local Terrain = workspace.Terrain

local Ids = Materials.Ids
local v = { Ids.GrassA, 1, Ids.GrassB, 1, Ids.DirtA, 3, Ids.DirtB, 2 }
local v2 = { Ids.DirtA, 2, Ids.DirtB, 1 }
local v3 = { Ids.Rim, 2, Ids.DirtB, 1 }
local v4 = { Ids.Rim, 2, Ids.Bedrock, 1 }
local v5 = { Ids.Sand, 1 }
local v6 = { Ids.Asphalt, 3, Ids.Rim, 1 }
local v7 = { Ids.Concrete, 1 }
local v8 = { Ids.Charred, 2, Ids.DirtB, 1 }

local v9 = { Ids.Sand, 3, Ids.DirtA, 1 }
local v10 = { Ids.Sand, 2, Ids.Rim, 1 }
local v11 = { Ids.Rim, 2, Ids.DirtA, 1 }

local v12 = { Ids.Snow, 1 }

local v13 = {}
local v14 = {}

for k, v15 in {
	[23] = { v, 1 },
	[24] = { v, 1 },
	[25] = { v2, 0 },
	[26] = { v2, 0 },
	[27] = { v3, 2 },
	[28] = { v2, 0 },
	[29] = { v4, 2 },
	[30] = { v5, 3 },
	[31] = { v6, 4 },
	[34] = { v2, 0 },
	[37] = { v, 1 },
	[38] = { v7, 4 },
	[39] = { v2, 0 },
	[40] = { v, 1 },
	[41] = { v, 1 },
	[42] = { v8, 0 },
	[43] = { v, 1 },
	[44] = { v9, 3 },
	[45] = { v2, 0 },
	[46] = { v10, 0 },
	[47] = { v3, 2 },
	[48] = { v11, 2 },
	[49] = { v2, 0 },
	[50] = { v9, 3 },
	[51] = { v9, 3 },
	[52] = { v10, 0 },
	[53] = { v3, 2 },
	[54] = { v3, 2 },
	[55] = { v11, 2 },
	[56] = { v4, 2 },
	[57] = { v2, 0 },
	[58] = { v12, 3 },
	[59] = { v12, 3 },
	[60] = {
		{ Ids.Snow, 2, Ids.Rim, 1 },
		2
	},
	[61] = { v4, 2 },
	[62] = {
		{ Ids.Snow, 1, Ids.DirtB, 2 },
		0
	},
	[63] = { v2, 0 },
	[32] = { v2, 0 },
	[33] = { v3, 2 },
	[35] = { v2, 0 },
	[36] = { v3, 2 }
} do
	local v16 = v15[1]
	local v17 = v15[2]
	v13[k] = v16
	v14[k] = v17
end

for k, v15 in v13 do
	for i = 1, #v15, 2 do
		assert(v15[i], "GroundHit: slot " .. k .. " names a palette entry that does not exist")
	end
end

local function snap(p: number) -- 12 equivalent calls inferred from this helper
	return math.floor(p / 4) * 4
end

local GroundHit = {
	["mix"] = nil,
	mix = function(vector3: Vector3, value: number)
		local v15 = math.clamp(value, 2, 12)
		local vector3_2 = Vector3.new(snap(vector3.X - v15), snap(vector3.Y - v15), snap(vector3.Z - v15)) -- inferred equivalent call
		local vector3_3 = Vector3.new(snap(vector3.X + v15) + 4, snap(vector3.Y + v15) + 4, snap(vector3.Z + v15) + 4) -- inferred equivalent call
		local voxelChannels = Terrain:ReadVoxelChannels(Region3.new(vector3_2, vector3_3), 4, {
			"SolidMaterialIndex",
			"SolidOccupancy"
		})
		local solidMaterialIndex = voxelChannels.SolidMaterialIndex
		local solidOccupancy = voxelChannels.SolidOccupancy
		local v16 = {}
		local total = 0

		for k, v17 in solidMaterialIndex do
			for k2, v18 in v17 do
				for k3, v19 in v18 do
					local v20 = solidOccupancy[k][k2][k3]

					if not (v19 ~= 0 and v20 > 0) then
						continue
					end

					v16[v19] = (v16[v19] or 0) + v20
					total += v20
				end
			end
		end

		if total < 0.25 then
			return nil
		end

		local v17 = {}

		for k, v18 in v16 do
			local v19 = v13[k]

			if not v19 then
				error(string.format("GroundHit: terrain material slot %d has no hit materials", k))
			end

			local total2 = 0

			for i = 2, #v19, 2 do
				total2 += v19[i]
			end

			for i = 1, #v19, 2 do
				v17[v19[i]] = (v17[v19[i]] or 0) + v18 * v19[i + 1] / total2
			end
		end

		local result = {}

		for k, v18 in v17 do
			table.insert(result, k)
			table.insert(result, (math.max(1, (math.round(v18 * 4)))))
		end

		return result
	end,
	soil = function(vector3: Vector3)
		local vector3_2 = Vector3.new(snap(vector3.X - 2), snap(vector3.Y - 2), snap(vector3.Z - 2)) -- inferred equivalent call
		local voxelChannels = Terrain:ReadVoxelChannels(Region3.new(vector3_2, vector3_2 + Vector3.new(8, 8, 8)), 4, {
			"SolidMaterialIndex",
			"SolidOccupancy"
		})
		local v15 = 0.1
		local v16 = 0

		for k, v17 in voxelChannels.SolidMaterialIndex do
			for k2, v18 in v17 do
				for k3, v19 in v18 do
					local v20 = voxelChannels.SolidOccupancy[k][k2][k3]

					if not (v19 ~= 0 and v15 < v20) then
						continue
					end

					v16 = v19
					v15 = v20
				end
			end
		end

		if v16 == 0 then
			return nil
		end

		local v17 = v14[v16]

		if v17 == nil then
			error(string.format("GroundHit: terrain material slot %d has no soil class", v16))
		end

		return v17
	end
}

local v15 = {
	[23] = 0.75,
	[24] = 0.45,
	[37] = 1,
	[40] = 0.6,
	[41] = 0.8
}

function GroundHit.fuel(vector3: Vector3)
	local vector3_2 = Vector3.new(snap(vector3.X - 2), snap(vector3.Y - 2), snap(vector3.Z - 2)) -- inferred equivalent call
	local voxelChannels = Terrain:ReadVoxelChannels(Region3.new(vector3_2, vector3_2 + Vector3.new(8, 8, 8)), 4, {
		"SolidMaterialIndex",
		"SolidOccupancy"
	})
	local v16 = 0.1
	local v17 = 0

	for k, v18 in voxelChannels.SolidMaterialIndex do
		for k2, v19 in v18 do
			for k3, v20 in v19 do
				local v21 = voxelChannels.SolidOccupancy[k][k2][k3]

				if not (v20 ~= 0 and v16 < v21) then
					continue
				end

				v17 = v20
				v16 = v21
			end
		end
	end

	return v15[v17] or 0
end

function GroundHit.pick(list, object)
	local total = 0

	for i = 2, #list, 2 do
		total += list[i]
	end

	local v16 = object:NextNumber() * total

	for i = 1, #list, 2 do
		v16 -= list[i + 1]

		if v16 <= 0 then
			return list[i]
		end
	end

	return list[#list - 1]
end

return GroundHit