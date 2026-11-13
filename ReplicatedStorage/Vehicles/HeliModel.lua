local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local WorldConfig = require(ReplicatedStorage.Voxel.WorldConfig)
local VehicleConfig = require(ReplicatedStorage.Vehicles.VehicleConfig)

local VOXEL_SIZE = WorldConfig.VOXEL_SIZE
local unit = VehicleConfig.UNIT

local HeliModel = {}

local color = Color3.fromRGB(86, 94, 62)
local color2 = Color3.fromRGB(64, 70, 46)
local color3 = Color3.fromRGB(58, 62, 44)
local color4 = Color3.fromRGB(38, 50, 60)
local color5 = Color3.fromRGB(44, 45, 46)
local color6 = Color3.fromRGB(24, 24, 24)
local color7 = Color3.fromRGB(52, 54, 56)
local color8 = Color3.fromRGB(214, 186, 70)
local color9 = Color3.fromRGB(236, 232, 210)

HeliModel.LENGTH = 11.7 * unit
HeliModel.MAIN_HUB = Vector3.new(0, 3 * unit, 0)
HeliModel.MAIN_RADIUS = 5.8 * unit
HeliModel.TAIL_HUB = Vector3.new(-1.25, 2.35 * unit, 22.75)
HeliModel.TAIL_RADIUS = 1.25 * unit
HeliModel.LIGHT_AT = Vector3.new(0, 1.25, -2.5)

HeliModel.MAIN_RPS = 5.7
HeliModel.TAIL_RPS = 24

HeliModel.GUN_MUZZLE = Vector3.new(0, 1.5, -8.25)
HeliModel.PODS = { Vector3.new(-5, 2.5, -5.25), Vector3.new(5, 2.5, -5.25) }

local function cabin(z: number)
	if z < -11 or z > 6 then
		return nil, 0, 0
	end

	if z < -6 then
		local v = (z + 11) / 5
		local v2 = math.sqrt(v)
		return v2 * 1.5 + 1, (1 - v) ^ 2 * 1.6 + 2, v2 * 2.4 + 4.6
	else
		if z < 3 then
			return 2.5, 2, 7
		end

		local v = (z - 3) / 3
		return 2.5 - v * 1.2, v * 2.6 + 2, 7 - v * 0.6
	end
end

local function rounded(x: number, y: number, p: number, p2: number, p3: number, p4: number): boolean -- 3 equivalent calls inferred from this helper
	if p < x or y < p2 or p3 < y then
		return false
	end

	local v = math.max(0, x - (p - p4))
	local v2 = math.max(0, y - (p3 - p4), p2 + p4 - y)
	return v * v + v2 * v2 <= p4 * p4
end

local function isSkid(vector3: Vector3): boolean
	local x = math.abs(vector3.X)
	local y = vector3.Y
	local z = vector3.Z

	if not (x > 3 and x < 3.5) then
		return (math.abs(z + 4.25) < 0.25 or math.abs(z - 2.25) < 0.25)
			and y >= 0.5
			and y < 2.5
			and math.abs(x - (3.25 - (y - 0.5) * 0.4)) < 0.3
	end

	if
		y < 0.5 and z > -7.5 and z < 5.5
		or (y >= 0.5 and y < 1 and z > -8.5 and z <= -7.5 or y >= 1 and y < 1.5 and z > -9 and z <= -8.5)
	then
		return true
	end

	return (math.abs(z + 4.25) < 0.25 or math.abs(z - 2.25) < 0.25)
		and y >= 0.5
		and y < 2.5
		and math.abs(x - (3.25 - (y - 0.5) * 0.4)) < 0.3
end

local function isPanel(vector3: Vector3): boolean -- 1 equivalent call inferred from this helper
	return vector3.Z < -8.25 and vector3.Y < 4.5 and math.abs(vector3.X) > 0.75
end

local function classify(vector3: Vector3)
	local x = math.abs(vector3.X)
	local y = vector3.Y
	local z = vector3.Z

	if isSkid(vector3) then
		return color5
	end

	local v, v2, v3 = cabin(z)

	if v and rounded(x, y, v, v2, v3, 1) then -- inferred equivalent call
		if z > -10 and z < 4.5 and rounded(x, y, v - 0.5, v2 + 0.5, v3 - 0.5, 0.5) then -- inferred equivalent call
			if z > -6.5 and z < -4.75 and x < 0.75 and y < 3 or z >= -4.75 and z < -4.25 and x < 0.75 and y < 5.5 then
				return color5
			end

			if isPanel(vector3) then -- inferred equivalent call
				return color6
			end

			if z > 0.5 and z < 2.5 and x > 0.5 and x < 1.75 and y < 3 or z > 3.5 and y < 3.5 then
				return color5
			end

			return nil
		end

		if v - 0.6 < x and y > 2.6 and y < 6.4 and z > -0.5 and z < 3.5 then
			return nil
		end

		if z < -8.5 and y > 3.5 and y < 4 then
			return color2
		end

		if
			z < -5 and y > 3.6
			or z < -8.5
			or v - 0.6 < x and y > 4.4 and y < 6.4 and (z > -4.5 and z < -0.5 or z > 0.5 and z < 3.5)
		then
			return color4
		end

		if v - 0.6 < x and (math.abs(z + 4.75) < 0.25 or math.abs(z - 0.25) < 0.25) and y > 2.6 then
			return color2
		end

		return if y < v2 + 0.6 then color3 else color
	end

	if z > -3.5 and z < 5.5 and y >= 6.5 and (x / 1.6) ^ 2 + ((y - 6.5) / 1.5) ^ 2 <= 1 then
		return if z < -2.5 and y > 7 then color6 else color2
	end

	if z >= 5.5 and z < 6.5 and x > 0.5 and x < 1.2 and y > 6.8 and y < 7.6 then
		return color6
	end

	if x < 0.5 and z > -0.5 and z < 0.5 and y >= 7.5 and y < HeliModel.MAIN_HUB.Y - 0.5 then
		return color5
	end

	if z >= 6 and z <= 21.5 then
		local v4 = (z - 6) / 15.5
		local v5 = 1.4 - v4 * 0.7
		local v6 = v4 * 0.8 + 5.6

		if x * x + (y - v6) ^ 2 <= v5 * v5 then
			return if z > 12 and z < 13 then color6 else color
		end
	end

	if y > 5.5 and y < 6 and x <= 3 and x * 0.3 + 15.5 <= z and z <= 17.5 then
		return color
	end

	if x < 0.5 and z <= 24 then
		if y >= 6 and y <= 10 and (y - 6) * 0.6 + 19.5 <= z then
			return if y > 9.4 then color6 else color
		elseif y >= 3.6 and y < 6 and z >= 21 then
			return color
		end
	end

	if vector3.X > -1 and vector3.X < -0.5 and y > 6.5 and y < 7.5 and z > 22 and z < 23.5 then
		return color5
	end

	return nil
end

local function mainRotor(vector3: Vector3)
	local x = vector3.X
	local y = vector3.Y
	local z = vector3.Z
	local v = x * x + z * z

	if y > -0.5 and y < 0.5 and v <= 1 or y >= 0.5 and y < 1 and v <= 0.36 then
		return color5
	end

	if not (y > -0.5 and y < 0) then
		return nil
	end

	local v2

	if math.abs(z) < 0.5 then
		v2 = math.abs(x)
	elseif math.abs(x) < 0.5 then
		v2 = math.abs(z)
	end

	if v2 and v2 >= 1 and v2 <= HeliModel.MAIN_RADIUS then
		return if HeliModel.MAIN_RADIUS - 1 < v2 then color8 else color7
	end

	return nil
end

local function tailRotor(vector3: Vector3)
	local y = vector3.Y
	local z = vector3.Z

	if y * y + z * z <= 0.36 then
		return color5
	end

	if vector3.X > -0.25 and math.abs(z) < 0.25 and math.abs(y) <= HeliModel.TAIL_RADIUS then
		if math.abs(y) > HeliModel.TAIL_RADIUS - 0.75 then
			return color8
		end

		return color7
	end

	return nil
end

local function searchlight(vector3: Vector3)
	local x = math.abs(vector3.X)
	local y = math.abs(vector3.Y)
	local z = vector3.Z

	if x < 0.75 and y < 0.75 then
		return if z < -0.25 then color9 else color5
	end

	return nil
end

local function arms(vector3: Vector3)
	local x = math.abs(vector3.X)
	local y = vector3.Y
	local z = vector3.Z

	if x > 2.25 and x < 5.5 and y > 3.5 and y < 4 and z > -3.25 and z < -0.75 then
		return color2
	end

	local v = x - 5
	local v2 = y - 2.5
	local v3 = v * v + v2 * v2

	if v3 <= 0.81 and z >= -4.75 and z <= 0.25 then
		if z < -4.25 then
			return if v3 < 0.3 then color6 else color5
		else
			return if z > -0.25 then color5 else color
		end
	else
		local v4 = y - 1.5
		local v5 = z + 5.5

		if y < 2 and x * x + v4 * v4 + v5 * v5 <= 0.81 then
			return color5
		end

		if x < 0.5 and y > 1 and y < 2 and z > -8 and z <= -5.75 then
			if z < -7.5 or z > -6.75 and z < -6.25 then
				return color5
			end

			return color6
		end

		return nil
	end
end

local function body(vector3: Vector3)
	local v = classify(vector3)
	return if v ~= color4 then v else nil
end

local function glazing(vector3: Vector3)
	return if classify(vector3) == color4 then color4 else nil
end

HeliModel.PIECES = {
	body = {
		counts = Vector3.new(16, 21, 72),
		lo = Vector3.new(-4, 0, -11.5),
		shape = body,
		at = Vector3.new(0, 0, 0)
	},
	glass = {
		counts = Vector3.new(16, 21, 72),
		lo = Vector3.new(-4, 0, -11.5),
		shape = glazing,
		at = Vector3.new(0, 0, 0)
	},
	mainRotor = {
		counts = Vector3.new(72, 4, 72),
		lo = Vector3.new(-18, -1, -18),
		shape = mainRotor,
		at = HeliModel.MAIN_HUB
	},
	tailRotor = {
		counts = Vector3.new(2, 17, 17),
		lo = Vector3.new(-0.75, -4.25, -4.25),
		shape = tailRotor,
		at = HeliModel.TAIL_HUB
	},
	light = {
		counts = Vector3.new(3, 3, 3),
		lo = Vector3.new(-0.75, -0.75, -0.75),
		shape = searchlight,
		at = HeliModel.LIGHT_AT
	},
	arms = {
		counts = Vector3.new(24, 8, 28),
		lo = Vector3.new(-6, 0.5, -13),
		shape = arms,
		at = Vector3.new(0, 0, 0)
	}
}

local Materials = require(ReplicatedStorage.Voxel.Materials)
local function palOf(p: string) -- 9 equivalent calls inferred from this helper
	local id = Materials.Ids[p]
	assert(id, "[HeliModel] palette " .. p .. " missing from Materials")
	return id
end

local v = {}
local hex = color:ToHex()
v[hex] = palOf("HullOlive") -- inferred equivalent call
local hex2 = color2:ToHex()
v[hex2] = palOf("TankHull") -- inferred equivalent call
local hex3 = color3:ToHex()
v[hex3] = palOf("TankTrack") -- inferred equivalent call
local hex4 = color4:ToHex()
v[hex4] = palOf("HullGlass") -- inferred equivalent call
local hex5 = color5:ToHex()
v[hex5] = palOf("TankTrack") -- inferred equivalent call
local hex6 = color6:ToHex()
v[hex6] = palOf("Tyre") -- inferred equivalent call
local hex7 = color7:ToHex()
v[hex7] = palOf("TankTrack") -- inferred equivalent call
local hex8 = color8:ToHex()
v[hex8] = palOf("HeadLamp") -- inferred equivalent call
local hex9 = color9:ToHex()
v[hex9] = palOf("HeadLamp") -- inferred equivalent call

local v2 = {
	body = {
		counts = Vector3.new(16, 21, 72),
		lo = Vector3.new(-4, 0, -11.5),
		shape = classify,
		at = Vector3.new(0, 0, 0)
	},
	mainRotor = HeliModel.PIECES.mainRotor,
	tailRotor = HeliModel.PIECES.tailRotor,
	light = HeliModel.PIECES.light,
	arms = HeliModel.PIECES.arms
}

local v3 = { "body", "mainRotor", "tailRotor", "light", "arms" }
local v4 = { body = true, arms = true }

local v5 = {}
local function boxesFor(p: string)
	local v6 = v5[p]

	if v6 then
		return v6
	end

	local VoxelCore = require(ReplicatedStorage.Voxel.VoxelCore)
	local v7 = v2[p]
	local x = v7.counts.X
	local y = v7.counts.Y
	local z = v7.counts.Z
	local total = 0
	local out = {}
	local inner = nil

	for i = 1, p == "body" and 2 or 1 do
		local buf = buffer.create(x * y * z)

		for j = 0, z - 1 do
			for k = 0, y - 1 do
				for i2 = 0, x - 1 do
					local v8 = v7.lo + Vector3.new(i2 + 0.5, k + 0.5, j + 0.5) * VOXEL_SIZE
					local shape = v7.shape(v8)

					if shape and p == "body" then
						local v9

						if shape == color6 and v8.Z < -8.25 and v8.Y < 4.5 then
							v9 = math.abs(v8.X) > 0.75
						else
							v9 = false
						end

						if v9 ~= (i == 2) then
							shape = nil
						end
					end

					if not shape then
						continue
					end

					local v9 = v[shape:ToHex()]
					assert(v9, "[HeliModel] no palette entry for colour #" .. shape:ToHex())
					buffer.writeu8(buf, i2 + x * (k + y * j), v9)
				end
			end
		end

		local v8 = {}
		local greedy = VoxelCore.greedy(buf, x, y, z, buffer.create(x * y * z), v8)

		if i == 2 then
			inner = total
		end

		table.move(v8, 1, greedy * 7, total * 7 + 1, out)
		total += greedy
	end

	assert(total > 0, "[HeliModel] piece " .. p .. " has no cells")
	local v8 = { n = total, out = out, inner = inner }
	v5[p] = v8
	return v8
end

local v6 = {}
function HeliModel.cellsOf(p: string)
	local v7 = v2[p]
	assert(v7, "[HeliModel] no piece " .. p)
	local result = v6[p]

	if result then
		return result, v7.lo
	end

	result = {}

	for i = 0, v7.counts.Z - 1 do
		for j = 0, v7.counts.Y - 1 do
			for k = 0, v7.counts.X - 1 do
				local shape = v7.shape(v7.lo + Vector3.new(k + 0.5, j + 0.5, i + 0.5) * VOXEL_SIZE)

				if not shape then
					continue
				end

				local v8 = v[shape:ToHex()]
				assert(v8, "[HeliModel] no palette entry for colour #" .. shape:ToHex())
				table.insert(result, k)
				table.insert(result, j)
				table.insert(result, i)
				table.insert(result, v8)
			end
		end
	end

	v6[p] = result

	return result, v7.lo
end

local function farShape(vector3: Vector3)
	local v7 = classify(vector3)

	if v7 ~= nil then
		return v7
	end

	local x = math.abs(vector3.X)
	local y = vector3.Y
	local z = vector3.Z
	local v8, v9, v10 = cabin(z)

	if not v8 then
		return v7
	end

	if rounded(x, y, v8, v9, v10, 1) and v8 - 0.6 < x and y > 2.6 and y < 6.4 and z > -0.5 and z < 3.5 then -- inferred equivalent call
		return color2
	end

	return v7
end

local v7 = nil
local function farBoxesFor()
	if v7 then
		return v7
	end

	local VoxelCore = require(ReplicatedStorage.Voxel.VoxelCore)

	local v8 = {}
	local function add(vector3: Vector3, vector3_2: Vector3, p: number)
		table.insert(v8, vector3.X + vector3_2.X * 0.5)
		table.insert(v8, vector3.Y + vector3_2.Y * 0.5)
		table.insert(v8, vector3.Z + vector3_2.Z * 0.5)
		table.insert(v8, vector3_2.X)
		table.insert(v8, vector3_2.Y)
		table.insert(v8, vector3_2.Z)
		table.insert(v8, p)
	end

	local buf = buffer.create(24192)

	for i = 0, 71 do
		for j = 0, 20 do
			for k = 0, 15 do
				if not isSkid(Vector3.new(-4, 0, -11.5) + Vector3.new(k + 0.5, j + 0.5, i + 0.5) * VOXEL_SIZE) then
					continue
				end

				buffer.writeu8(buf, k + (j + i * 21) * 16, v[color5:ToHex()])
			end
		end
	end

	local v9 = {}

	for i = 0, VoxelCore.greedy(buf, 16, 21, 72, buffer.create(24192), v9) - 1 do
		local v10 = i * 7
		add(
			Vector3.new(-4, 0, -11.5) + Vector3.new(v9[v10 + 1], v9[v10 + 2], v9[v10 + 3]) * VOXEL_SIZE,
			Vector3.new(v9[v10 + 4], v9[v10 + 5], v9[v10 + 6]) * VOXEL_SIZE,
			v9[v10 + 7]
		)
	end

	local buf2 = buffer.create(3168)
	local v10 = {}

	for i = 0, 35 do
		for j = 0, 10 do
			for k = 0, 7 do
				table.clear(v10)
				local count = 0
				local count2 = 0

				for i2 = i * 2, math.min(72, (i + 1) * 2) - 1 do
					for i3 = j * 2, math.min(21, (j + 1) * 2) - 1 do
						for i4 = k * 2, math.min(16, (k + 1) * 2) - 1 do
							count += 1
							local v11 = Vector3.new(-4, 0, -11.5) + Vector3.new(i4 + 0.5, i3 + 0.5, i2 + 0.5) * VOXEL_SIZE
							local v12

							if not isSkid(v11) then
								v12 = farShape(v11)
							end

							if not v12 then
								continue
							end

							count2 += 1
							local v13 = v[v12:ToHex()]
							v10[v13] = (v10[v13] or 0) + 1
						end
					end
				end

				if not (count2 > 0 and count * 0.25 <= count2) then
					continue
				end

				local v11 = 0
				local v12 = 0

				for k2, v13 in v10 do
					if not (v11 < v13 or v13 == v11 and k2 < v12) then
						continue
					end

					v12 = k2
					v11 = v13
				end

				buffer.writeu8(buf2, k + (j + i * 11) * 8, v12)
			end
		end
	end

	table.clear(v9)
	local greedy = VoxelCore.greedy(buf2, 8, 11, 36, buffer.create(3168), v9)
	assert(greedy > 0, "[HeliModel] the far body has no cells")

	local v11 = 2 * VOXEL_SIZE
	local v12 = Vector3.new(-4, 0, -11.5) + Vector3.new(16, 21, 72) * VOXEL_SIZE

	for i = 0, greedy - 1 do
		local v13 = i * 7
		local v14 = Vector3.new(-4, 0, -11.5) + Vector3.new(v9[v13 + 1], v9[v13 + 2], v9[v13 + 3]) * v11
		add(v14, (v14 + Vector3.new(v9[v13 + 4], v9[v13 + 5], v9[v13 + 6]) * v11):Min(v12) - v14, v9[v13 + 7])
	end

	v7 = v8
	return v8
end

function HeliModel.build(data)
	assert(RunService:IsClient(), "[HeliModel] build() draws on clients only")
	local RigidParts = require(ReplicatedStorage.Vehicles.RigidParts)
	local Detail = require(ReplicatedStorage.Voxel.Detail)
	local palette = Materials.Palette
	local park = RigidParts.PARK
	local helicopter = Instance.new("Model")
	helicopter.Name = "Helicopter"
	local function newPart(name: string, size: Vector3, p: number, flag: boolean)
		local v8 = palette[p]
		local part = Instance.new("Part")
		part.Name = name
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		local smooth = Enum.SurfaceType.Smooth
		local smooth2 = Enum.SurfaceType.Smooth
		part.TopSurface = smooth
		part.BottomSurface = smooth2
		part.Size = size
		part.Color = v8.color
		part.Material = v8.material
		part.MaterialVariant = v8.variant
		part.Transparency = v8.transparency
		part.CastShadow = flag and v8.transparency == 0
		part.Parent = helicopter
		return part
	end

	local v8 = {}

	for k, v9 in v3 do
		v8[k] = RigidParts.root(helicopter, v9 .. "Root")
	end

	local parts2 = {}

	local v9 = {}
	local v10 = {}
	local v11 = {}
	local colors = {}

	local v12 = {}
	local v13 = {}

	for k, v14 in v3 do
		local v15

		if data then
			v15 = data.PIECES[v14]
		else
			v15 = v2[v14]
		end

		local v16

		if data then
			v16 = data.boxesFor(v14)
		else
			v16 = boxesFor(v14)
		end

		local out = v16.out

		for i = 0, v16.n - 1 do
			local v17 = i * 7
			local v18 = out[v17 + 1]
			local v19 = out[v17 + 2]
			local v20 = out[v17 + 3]
			local v21 = out[v17 + 4]
			local v22 = out[v17 + 5]
			local v23 = out[v17 + 6]
			local v24 = out[v17 + 7]
			local v25

			if v14 == "body" then
				v25 = v21 * v22 * v23 >= 8
			else
				v25 = false
			end

			local v26 = newPart(v14, Vector3.new(v21, v22, v23) * VOXEL_SIZE, v24, v25)
			RigidParts.weld(
				v8[k],
				v26,
				CFrame.new(v15.lo + Vector3.new(v18 + v21 * 0.5, v19 + v22 * 0.5, v20 + v23 * 0.5) * VOXEL_SIZE)
			)
			table.insert(parts2, v26)
			local v27 = palette[v24]

			if v25 and v27.transparency == 0 then
				table.insert(v12, v26)
				table.insert(v13, v21 * v22 * v23)
			end

			if v4[v14] and v27.transparency == 0 then
				table.insert(v11, v26)
				table.insert(colors, v27.color)
			end

			if v14 == "body" and v27.transparency > 0 then
				table.insert(v10, v26)
			end

			if v14 == "body" and v16.inner and v16.inner <= i then
				table.insert(v9, v26)
			end
		end
	end

	local v14 = table.create(#v8, CFrame.identity)
	local v15 = { v8[2], v8[3] }
	local v16 = table.create(2, CFrame.identity)

	local v17 = { RigidParts.root(helicopter, "farRoot"), RigidParts.root(helicopter, "farRotorRoot"), v8[3] }
	local v18 = v[color7:ToHex()]
	local v19

	if data then
		v19 = data.farBoxes()
	else
		v19 = farBoxesFor()
	end

	for i = 0, #v19 // 7 - 1 do
		local v20 = i * 7
		local v21 = v19[v20 + 7]
		local v22 = newPart("far", Vector3.new(v19[v20 + 4], v19[v20 + 5], v19[v20 + 6]), v21, false)
		RigidParts.weld(v17[1], v22, CFrame.new(v19[v20 + 1], v19[v20 + 2], v19[v20 + 3]))
		local v23 = palette[v21]

		if v23.transparency ~= 0 then
			continue
		end

		table.insert(v11, v22)
		table.insert(colors, v23.color)
	end

	local v20 = HeliModel.MAIN_RADIUS * 2

	for _, v21 in data and data.noFarRotor and {} or {
		Vector3.new(v20, VOXEL_SIZE, 2 * VOXEL_SIZE),
		(Vector3.new(2 * VOXEL_SIZE, VOXEL_SIZE, v20))
	} do
		RigidParts.weld(v17[2], newPart("farRotor", v21, v18, false), CFrame.new(0, -VOXEL_SIZE * 0.5, 0))
	end

	local v21 = table.create(3, CFrame.identity)

	local v22 = table.create(#v3, CFrame.identity)
	local set = {}
	local v23 = 0
	local v24 = 0
	local v25 = nil
	local v26 = nil
	local v27 = nil
	local pieces

	if data then
		pieces = data.PIECES
	else
		pieces = HeliModel.PIECES
	end

	local function park2(parts) -- 3 equivalent calls inferred from this helper
		workspace:BulkMoveTo(parts, table.create(#parts, park), Enum.BulkMoveMode.FireCFrameChanged)
	end

	local function tint(color10: Color3?) -- 1 equivalent call inferred from this helper
		for k, v28 in v11 do
			v28.Color = color10 or colors[k]
		end
	end
	local function indexOf(p: string) -- 2 equivalent calls inferred from this helper
		local index = table.find(v3, p)
		assert(index, "[HeliModel] no drawn piece " .. p)
		return index
	end

	return {
		model = helicopter,
		parts = parts2,
		pose = function(cframe: CFrame, p: number, p2: number, vector3: Vector3?, flag: boolean?)
			local v28 = not v25 and 0 or math.clamp(p - v25, 0, 0.1)
			v25 = p
			v23 = (v23 + v28 * p2 * HeliModel.MAIN_RPS * 3.141592653589793 * 2) % 6.283185307179586
			v24 = (v24 + v28 * p2 * HeliModel.TAIL_RPS * 3.141592653589793 * 2) % 6.283185307179586
			local v29 = flag == true

			if v27 ~= v29 then
				local v30 = if v29 then v8 else v17
				park2(v30) -- inferred equivalent call
				v27 = v29
				v26 = nil
			end

			local v30 = cframe * CFrame.new(pieces.mainRotor.at) * CFrame.Angles(0, v23, 0)
			v22[1] = cframe
			v22[2] = v30
			v22[3] = cframe * CFrame.new(pieces.tailRotor.at) * CFrame.Angles(v24, 0, 0)
			local v31 = cframe * CFrame.new(pieces.light.at)

			if vector3 then
				v31 = CFrame.lookAt(v31.Position, vector3)
			end

			v22[4] = v31
			v22[5] = cframe

			if v29 then
				local v32 = if set[3] then park else v22[3]
				v21[1] = cframe
				v21[2] = v30
				v21[3] = v32
				workspace:BulkMoveTo(v17, v21, Enum.BulkMoveMode.FireCFrameChanged)
			elseif v26 == cframe and not vector3 then
				local v32 = if set[2] then park else v22[2]
				v16[1] = v32
				local v34 = if set[3] then park else v22[3]
				v16[2] = v34
				workspace:BulkMoveTo(v15, v16, Enum.BulkMoveMode.FireCFrameChanged)
			else
				v26 = cframe

				for k in v8 do
					local v32

					if set[k] then
						v32 = park
					else
						v32 = v22[k]
					end

					v14[k] = v32
				end

				workspace:BulkMoveTo(v8, v14, Enum.BulkMoveMode.FireCFrameChanged)
			end
		end,
		tint = tint,
		hide = function(p: string)
			local index = indexOf(p) -- inferred equivalent call
			set[index] = true
			v26 = nil
		end,
		clearGlass = function(flag: boolean)
			local localTransparencyModifier = flag and 1 or 0

			for _, v28 in v10 do
				v28.LocalTransparencyModifier = localTransparencyModifier
			end
		end,
		clearInner = function(flag: boolean)
			local localTransparencyModifier = flag and 1 or 0

			for _, v28 in v9 do
				v28.LocalTransparencyModifier = localTransparencyModifier
			end
		end,
		frameOf = function(p: string)
			return v22[indexOf(p)] -- inferred equivalent call
		end,
		shade = function(p: number)
			local v28 = p == 0 and 0 or Detail.bandCells(p)

			for k, v29 in v12 do
				local castShadow = v28 <= v13[k]

				if v29.CastShadow ~= castShadow then
					v29.CastShadow = castShadow
				end
			end
		end,
		reset = function()
			tint() -- inferred equivalent call

			for _, v28 in v10 do
				v28.LocalTransparencyModifier = 0
			end

			for _, v28 in v9 do
				v28.LocalTransparencyModifier = 0
			end

			for k, v28 in v12 do
				local castShadow = v13[k] >= 0

				if v28.CastShadow ~= castShadow then
					v28.CastShadow = castShadow
				end
			end

			table.clear(set)
			park2(v8) -- inferred equivalent call
			park2(v17) -- inferred equivalent call
			v26 = nil
			v27 = nil
			v25 = nil
			v23 = 0
			v24 = 0
		end
	}
end

local Materials2 = require(ReplicatedStorage.Voxel.Materials)
local HullOlive = Materials2.Ids.HullOlive
local HullFrame = Materials2.Ids.HullFrame
assert(HullOlive and HullFrame, "[HeliModel] vehicle palettes missing from Materials")

local buf = buffer.create(24192)

for i = 0, 71 do
	for j = 0, 20 do
		for k = 0, 15 do
			local v8 = classify(Vector3.new(-4, 0, -11.5) + Vector3.new(k + 0.5, j + 0.5, i + 0.5) * VOXEL_SIZE)

			if v8 and v8 ~= color4 then
				buffer.writeu8(buf, k + (j + i * 21) * 16, HullOlive)
			end
		end
	end
end

HeliModel.name = "Heli"

HeliModel.EYE = Vector3.new(0, 6.1, -5.8)
HeliModel.flies = true
HeliModel.sx = 16
HeliModel.sy = 21
HeliModel.sz = 72
HeliModel.data = buf
HeliModel.origin = Vector3.new(-4, 0, -11.5)
HeliModel.size = Vector3.new(16, 21, 72) * VOXEL_SIZE
HeliModel.center = Vector3.new(-4, 0, -11.5) + Vector3.new(16, 21, 72) * (VOXEL_SIZE / 2)
HeliModel.frame = HullFrame
HeliModel.wear = 1.6

HeliModel.DOOR_GUNS = {
	{ pivot = Vector3.new(-2.55, 4.7, 1.5), out = 1.5707963267948966, seat = 2 },
	{ pivot = Vector3.new(2.55, 4.7, 1.5), out = -1.5707963267948966, seat = 3 }
}

HeliModel.DOOR_MUZZLE = Vector3.new(0, 0, -2.1)
HeliModel.DOOR_EYE = Vector3.new(0, 0.48, 1.6)
HeliModel.DOOR_SCOPE_EYE = Vector3.new(0, 0.48, 0.95)

function HeliModel.doorGunFrame(p: number, p2: number, p3: number)
	local v8 = HeliModel.DOOR_GUNS[p]
	return CFrame.new(v8.pivot) * CFrame.fromEulerAnglesYXZ(p3, v8.out + p2, 0)
end

HeliModel.seats = {
	{ root = Vector3.new(0, 4.4, -5.6), exit = Vector3.new(6, 3, -5.6), drive = true },
	{
		root = Vector3.new(-1.3, 4.4, 1.5),
		exit = Vector3.new(-6, 3, 1.5),
		drive = false,
		yaw = 1.5707963267948966,
		gun = 1
	},
	{
		root = Vector3.new(1.3, 4.4, 1.5),
		exit = Vector3.new(6, 3, 1.5),
		drive = false,
		yaw = -1.5707963267948966,
		gun = 2
	},
	{ root = Vector3.new(0, 4.9, 4), exit = Vector3.new(-6, 3, 3), drive = false }
}

HeliModel.feet = {
	Vector3.new(-3.25, 0, -6.5),
	Vector3.new(3.25, 0, -6.5),
	Vector3.new(-3.25, 0, 4.5),
	Vector3.new(3.25, 0, 4.5)
}

HeliModel.spheres = {
	{ at = Vector3.new(0, 4.5, -6), r = 2.6 },
	{ at = Vector3.new(0, 4.6, 0), r = 2.6 },
	{ at = Vector3.new(0, 6, 12), r = 1.4 },
	{ at = Vector3.new(0, 7.5, 21.5), r = 1.8 }
}

HeliModel.boxes = {
	{ at = Vector3.new(0, 4.5, -2.5), size = Vector3.new(5, 5, 17) },
	{ at = Vector3.new(0, 6, 13.75), size = Vector3.new(2.4, 2.4, 15.5) },
	{ at = Vector3.new(0, 7.5, 22), size = Vector3.new(0.8, 6, 4) },
	{ at = Vector3.new(-3.25, 0.25, -1), size = Vector3.new(0.5, 0.5, 13) },
	{ at = Vector3.new(3.25, 0.25, -1), size = Vector3.new(0.5, 0.5, 13) }
}

return HeliModel