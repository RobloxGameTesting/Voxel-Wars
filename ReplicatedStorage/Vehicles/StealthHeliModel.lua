local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WorldConfig = require(ReplicatedStorage.Voxel.WorldConfig)
local VehicleConfig = require(ReplicatedStorage.Vehicles.VehicleConfig)
local Materials = require(ReplicatedStorage.Voxel.Materials)

local VOXEL_SIZE = WorldConfig.VOXEL_SIZE
local unit = VehicleConfig.UNIT

local StealthHeliModel = {}

local function palOf(p: string) -- 5 equivalent calls inferred from this helper
	local id = Materials.Ids[p]
	assert(id, "[StealthHeliModel] palette " .. p .. " missing from Materials")
	return id
end

local tankTrack = palOf("TankTrack") -- inferred equivalent call
local tyre = palOf("Tyre") -- inferred equivalent call
local bunkerSteel = palOf("BunkerSteel") -- inferred equivalent call
local hullGlass = palOf("HullGlass") -- inferred equivalent call
local tailLamp = palOf("TailLamp") -- inferred equivalent call
StealthHeliModel.MAIN_HUB = Vector3.new(0, 3 * unit, 0)
StealthHeliModel.MAIN_RADIUS = 5.8 * unit
StealthHeliModel.TAIL_HUB = Vector3.new(0, 6.5, 22)
StealthHeliModel.TAIL_RADIUS = 1.95
StealthHeliModel.SENSOR_AT = Vector3.new(0, 2.25, -12.75)

StealthHeliModel.GUN_MUZZLES = { Vector3.new(-4.75, 2.75, -8.75), Vector3.new(4.75, 2.75, -8.75) }
StealthHeliModel.PODS = { Vector3.new(-7, 2.5, -5.25), Vector3.new(7, 2.5, -5.25) }

local v = {
	{ -13.5, 0.5, 0.25, 0.25, 3, 3.25, 3.5 },
	{ -9, 2.25, 1.25, 1, 2.25, 3.5, 5.25 },
	{ -5, 3, 1.75, 1.5, 1.75, 3.75, 7 },
	{ 3, 3.25, 1.75, 1.75, 1.75, 3.75, 7.25 },
	{ 8, 2.25, 1, 1, 3, 4.5, 7.25 },
	{ 20, 0.75, 0.25, 0.25, 5, 5.75, 6.5 }
}

local function lerp(p: number, p2: number, p3: number) -- 8 equivalent calls inferred from this helper
	return p + (p2 - p) * p3
end

local function hullAt(y: number, z: number)
	for i = 1, #v - 1 do
		local v2 = v[i]
		local v3 = v[i + 1]

		if v2[1] <= z and z <= v3[1] then
			local v4 = (z - v2[1]) / (v3[1] - v2[1])
			local v5 = lerp(v2[2], v3[2], v4) -- inferred equivalent call
			local v6 = lerp(v2[3], v3[3], v4) -- inferred equivalent call
			local v7 = lerp(v2[4], v3[4], v4) -- inferred equivalent call
			local v8 = lerp(v2[5], v3[5], v4) -- inferred equivalent call
			local v9 = lerp(v2[6], v3[6], v4) -- inferred equivalent call
			local v10 = lerp(v2[7], v3[7], v4) -- inferred equivalent call

			if y < v8 or v10 < y then
				return nil, v8, v9, v10
			end

			local v11

			if v9 <= y then
				v11 = lerp(v5, v6, (y - v9) / (v10 - v9)) -- inferred equivalent call
			else
				v11 = lerp(v5, v7, (v9 - y) / (v9 - v8)) -- inferred equivalent call
			end

			return v11, v8, v9, v10
		end
	end

	return nil, 0, 0, 0
end

local function wheels(x: number, y: number, z: number)
	if math.abs(x - 2.75) < 0.5 then
		local v2 = y - 0.9
		local v3 = z + 3
		local v4 = v2 * v2 + v3 * v3

		if v4 <= 0.81 then
			return if v4 < 0.12 then bunkerSteel else tyre
		end
	end

	if math.abs(x - 2.5) < 0.3 and math.abs(z + 3) < 0.3 and y >= 1.5 and y < 3 then
		return bunkerSteel
	end

	if x < 0.5 then
		local v2 = y - 0.7
		local v3 = z - 15

		if v2 * v2 + v3 * v3 <= 0.49 then
			return tyre
		end
	end

	if x < 0.3 and y >= 1.25 and y < 5 and math.abs(z - 15) < (y - 1.25) * 0.5 + 0.4 then
		return tankTrack
	end

	return nil
end

local function isPanel(vector3: Vector3): boolean -- 2 equivalent calls inferred from this helper
	return vector3.Z < -8.75 and vector3.Z > -10.5 and vector3.Y < 4 and math.abs(vector3.X) > 0.75
end

local function classify(vector3: Vector3)
	local x = math.abs(vector3.X)
	local y = vector3.Y
	local z = vector3.Z
	local v2 = wheels(x, y, z)

	if v2 then
		return v2
	end

	local v3, v4, v5, v6 = hullAt(y, z)

	if v3 and x <= v3 then
		if z > -12 and z < -3 and v4 + 0.5 < y and y < v6 - 0.5 and x < v3 - 0.5 then
			if
				z > -6.75 and z < -4.25 and x < 0.75 and y < 3.5
				or z >= -4.75 and z < -4.25 and x < 0.75 and y < 5.75
				or isPanel(vector3) -- inferred equivalent call
			then
				return tyre
			end

			return nil
		end

		if z > -12 and z < -8.25 and y < v4 + 1 then
			return hullGlass
		end

		if z > -12 and z < -3 and v5 + 0.25 < y then
			if z > -3.5 or math.abs(z + 9.75) < 0.25 then
				return tyre
			end

			return hullGlass
		end

		if math.abs(y - v5) < 0.25 then
			return tyre
		end

		if
			v3 - 0.6 < x
			and (math.abs(z + 2.75) < 0.25 or math.abs(z - 3.25) < 0.25 or math.abs(z - 8.25) < 0.25 or math.abs(z - 13.75) < 0.25)
		then
			return tyre
		end

		return tankTrack
	else
		if y >= 6.5 and y < 8.5 then
			local v7 = y - 6.5

			if v7 * 1.25 + -2.5 <= z and z <= 7.5 - v7 * 1 and x <= 1.75 - v7 * 0.4 then
				if y > 7 and y < 7.75 and x > 0.75 and z > 0 and z < 2.5 or 5.5 - v7 < z and x > 0.25 and y > 6.75 then
					return tyre
				end

				return tankTrack
			end
		end

		if x < 0.5 and math.abs(z) < 0.5 and y >= 8.5 and y < StealthHeliModel.MAIN_HUB.Y then
			return bunkerSteel
		end

		local TAIL_HUB = StealthHeliModel.TAIL_HUB
		local v7 = y - TAIL_HUB.Y
		local v8 = z - TAIL_HUB.Z
		local v9 = v7 * v7 + v8 * v8

		if x < 0.75 and v9 >= 4 and v9 <= 9 then
			return if v9 < 5.5 then tyre else tankTrack
		end

		if y >= 8.5 and y < 12.5 then
			local v10 = y - 8.5

			if math.abs(x - (v10 * 0.7 + 0.25)) <= 0.5 and v10 * 0.75 + 20 <= z and z <= v10 * 0.5 + 23.25 then
				return if y > 11.5 then bunkerSteel else tankTrack
			end
		end

		return nil
	end
end

local function mainRotor(vector3: Vector3)
	local x = vector3.X
	local y = vector3.Y
	local z = vector3.Z
	local v2 = x * x + z * z

	if y > -0.5 and y < 0.5 and v2 <= 2.25 then
		return tankTrack
	end

	if y >= 0.5 and y < 1 and v2 <= 0.64 then
		return bunkerSteel
	end

	if not (y > -0.5 and y < 0) then
		return nil
	end

	local MAIN_RADIUS = StealthHeliModel.MAIN_RADIUS

	for _, v3 in {
		{ x, z },
		{ -z, x },
		{ -x, -z },
		{ z, -x }
	} do
		local v4 = v3[1]
		local v5 = v3[2]

		if v4 >= 1.5 and v4 <= MAIN_RADIUS and math.abs(v5 + math.max(0, v4 - (MAIN_RADIUS - 2.5)) * 0.5) <= 0.5 then
			return if MAIN_RADIUS - 2.5 < v4 then bunkerSteel else tyre
		end
	end

	return nil
end

local function tailFan(vector3: Vector3)
	local y = math.abs(vector3.Y)
	local z = math.abs(vector3.Z)
	local v2 = y * y + z * z

	if v2 <= 0.3 then
		return bunkerSteel
	end

	if v2 <= StealthHeliModel.TAIL_RADIUS ^ 2 and (y < 0.25 or z < 0.25 or math.abs(y - z) < 0.25) then
		return tyre
	end

	return nil
end

local function sensor(vector: Vector3)
	if vector:Dot(vector) > 0.7 then
		return nil
	end

	if vector.Z < -0.25 and math.abs(vector.X) < 0.25 and math.abs(vector.Y) < 0.25 then
		return tailLamp
	end

	return tyre
end

local function arms(vector3: Vector3)
	local x = math.abs(vector3.X)
	local y = vector3.Y
	local z = vector3.Z

	if classify(vector3) then
		return nil
	end

	if x > 2.5 and x < 8.5 and y > 3.5 and y < 4.5 then
		local v2 = (x - 2.5) * 0.35 + -3.5

		if v2 <= z and z <= 1 - (x - 2.5) * 0.1 then
			if z < v2 + 0.5 then
				return if x > 8 then tailLamp else bunkerSteel
			end

			return tankTrack
		end
	end

	local v2 = math.abs(x - 4.75)
	local v3 = math.abs(y - 2.75)

	if v2 < 0.75 and v3 < 0.75 then
		if z >= -3 and z <= 1.5 then
			return if z > -2.5 and z < -2 then tyre else tankTrack
		elseif z >= -8.5 and z < -3 then
			if z > -5.75 and z < -5.25 or z > -8.25 and z < -7.75 then
				return bunkerSteel
			end

			if v2 < 0.25 and v3 < 0.25 then
				return tyre
			end

			if v2 < 0.25 or v3 < 0.25 then
				return bunkerSteel
			end
		end
	end

	local v4 = math.abs(x - 7)
	local v5 = math.abs(y - 2.5)

	if not (v4 < 1 and v5 < 1) then
		return nil
	end

	if z >= -3.5 and z <= 2 then
		return if z < -3 or z > 1.5 then tyre else tankTrack
	elseif v4 > 0.5 and v5 > 0.5 then
		if z >= -4.5 and z < -3.5 then
			return bunkerSteel
		end

		if z >= -5 and z < -4.5 then
			return tailLamp
		end
	end

	return nil
end

StealthHeliModel.PIECES = {
	body = {
		counts = Vector3.new(16, 25, 80),
		lo = Vector3.new(-4, 0, -14),
		shape = classify,
		at = Vector3.new(0, 0, 0)
	},
	mainRotor = {
		counts = Vector3.new(72, 4, 72),
		lo = Vector3.new(-18, -1, -18),
		shape = mainRotor,
		at = StealthHeliModel.MAIN_HUB
	},
	tailRotor = {
		counts = Vector3.new(2, 8, 8),
		lo = Vector3.new(-0.5, -2, -2),
		shape = tailFan,
		at = StealthHeliModel.TAIL_HUB
	},
	light = {
		counts = Vector3.new(3, 3, 3),
		lo = Vector3.new(-0.75, -0.75, -0.75),
		shape = sensor,
		at = StealthHeliModel.SENSOR_AT
	},
	arms = {
		counts = Vector3.new(34, 6, 23),
		lo = Vector3.new(-8.5, 1.5, -9),
		shape = arms,
		at = Vector3.new(0, 0, 0)
	}
}

local v2 = {}

local function inCockpit(vector3: Vector3): boolean -- 1 equivalent call inferred from this helper
	local x = math.abs(vector3.X)
	local y = vector3.Y
	local z = vector3.Z
	local v3, v4, _, v5 = hullAt(y, z)
	return v3 ~= nil and z > -12 and z < -3 and v4 + 0.5 < y and y < v5 - 0.5 and x < v3 - 0.5
end

function StealthHeliModel.boxesFor(p: string)
	local v3 = v2[p]

	if v3 then
		return v3
	end

	local VoxelCore = require(ReplicatedStorage.Voxel.VoxelCore)
	local v4 = StealthHeliModel.PIECES[p]
	assert(v4, "[StealthHeliModel] no piece " .. p)
	local x = v4.counts.X
	local y = v4.counts.Y
	local z = v4.counts.Z
	local total = 0
	local out = {}
	local inner = nil

	for i = 1, p == "body" and 2 or 1 do
		local buf = buffer.create(x * y * z)

		for j = 0, z - 1 do
			for k = 0, y - 1 do
				for i2 = 0, x - 1 do
					local v5 = v4.lo + Vector3.new(i2 + 0.5, k + 0.5, j + 0.5) * VOXEL_SIZE
					local shape = v4.shape(v5)

					if shape and p == "body" and (isPanel(v5) and inCockpit(v5)) ~= (i == 2) then -- inferred equivalent call
						shape = nil
					end

					if shape then
						buffer.writeu8(buf, i2 + x * (k + y * j), shape)
					end
				end
			end
		end

		local v5 = {}
		local greedy = VoxelCore.greedy(buf, x, y, z, buffer.create(x * y * z), v5)

		if i == 2 then
			inner = total
		end

		table.move(v5, 1, greedy * 7, total * 7 + 1, out)
		total += greedy
	end

	assert(total > 0, "[StealthHeliModel] piece " .. p .. " has no cells")
	local v5 = { n = total, out = out, inner = inner }
	v2[p] = v5
	return v5
end

local v3 = {}
function StealthHeliModel.cellsOf(p: string)
	local v4 = StealthHeliModel.PIECES[p]
	assert(v4, "[StealthHeliModel] no piece " .. p)
	local result = v3[p]

	if result then
		return result, v4.lo
	end

	result = {}

	for i = 0, v4.counts.Z - 1 do
		for j = 0, v4.counts.Y - 1 do
			for k = 0, v4.counts.X - 1 do
				local shape = v4.shape(v4.lo + Vector3.new(k + 0.5, j + 0.5, i + 0.5) * VOXEL_SIZE)

				if not shape then
					continue
				end

				table.insert(result, k)
				table.insert(result, j)
				table.insert(result, i)
				table.insert(result, shape)
			end
		end
	end

	v3[p] = result

	return result, v4.lo
end

local v4 = nil
function StealthHeliModel.farBoxes()
	if v4 then
		return v4
	end

	local VoxelCore = require(ReplicatedStorage.Voxel.VoxelCore)
	local body = StealthHeliModel.PIECES.body

	local v5 = math.ceil(body.counts.X / 2)
	local v6 = math.ceil(body.counts.Y / 2)
	local v7 = math.ceil(body.counts.Z / 2)
	local buf = buffer.create(v5 * v6 * v7)

	for i = 0, v7 - 1 do
		for j = 0, v6 - 1 do
			for k = 0, v5 - 1 do
				local count = 0
				local v8 = {}
				local v9 = 0
				local v10 = 0

				for i2 = 0, 1 do
					for i3 = 0, 1 do
						for i4 = 0, 1 do
							local vector3 = Vector3.new(k * 2 + i4 + 0.5, j * 2 + i3 + 0.5, i * 2 + i2 + 0.5)
							local shape = body.shape(body.lo + vector3 * VOXEL_SIZE)

							if not shape then
								continue
							end

							count += 1
							v8[shape] = (v8[shape] or 0) + 1

							if not (v9 < v8[shape]) then
								continue
							end

							v9 = v8[shape]
							v10 = shape
						end
					end
				end

				if count >= 2 then
					buffer.writeu8(buf, k + v5 * (j + v6 * i), v10)
				end
			end
		end
	end

	local v8 = {}
	local greedy = VoxelCore.greedy(buf, v5, v6, v7, buffer.create(v5 * v6 * v7), v8)
	assert(greedy > 0, "[StealthHeliModel] the far body has no cells")

	local v9 = 2 * VOXEL_SIZE
	local v10 = {}

	for i = 0, greedy - 1 do
		local v11 = i * 7
		local v12 = Vector3.new(v8[v11 + 4], v8[v11 + 5], v8[v11 + 6]) * v9
		local v13 = body.lo + Vector3.new(v8[v11 + 1], v8[v11 + 2], v8[v11 + 3]) * v9 + v12 * 0.5
		table.move({
			v13.X,
			v13.Y,
			v13.Z,
			v12.X,
			v12.Y,
			v12.Z,
			v8[v11 + 7]
		}, 1, 7, #v10 + 1, v10)
	end

	v4 = v10
	return v10
end

local HeliModel = require(ReplicatedStorage.Vehicles.HeliModel)
local clone = table.clone(HeliModel)
local clone2 = table.clone(HeliModel.seats[1])
clone2.gun = nil
clone2.root = Vector3.new(0, 4.4, -5.6)
clone.seats = { clone2 }
clone.DOOR_GUNS = {}
clone.noBots = true
clone.EYE = Vector3.new(0, 6, -5.6)
clone.GUN_MUZZLES = StealthHeliModel.GUN_MUZZLES
clone.GUN_MUZZLE = Vector3.new(0, 2.75, -8.75)
clone.PODS = StealthHeliModel.PODS
clone.cellsOf = StealthHeliModel.cellsOf
function clone.build()
	return HeliModel.build(StealthHeliModel)
end

clone.tuning = VehicleConfig.StealthHeli
clone.wear = 1.1
clone.quiet = 0.55

local body = StealthHeliModel.PIECES.body
local x = body.counts.X
local y = body.counts.Y
local z = body.counts.Z
local buf = buffer.create(x * y * z)

for i = 0, z - 1 do
	for j = 0, y - 1 do
		for k = 0, x - 1 do
			local v5 = classify(body.lo + Vector3.new(k + 0.5, j + 0.5, i + 0.5) * VOXEL_SIZE)

			if v5 and v5 ~= hullGlass then
				buffer.writeu8(buf, k + x * (j + y * i), tankTrack)
			end
		end
	end
end

clone.sx = x
clone.sy = y
clone.sz = z
clone.data = buf
clone.origin = body.lo
clone.size = body.counts * VOXEL_SIZE
clone.center = body.lo + body.counts * (VOXEL_SIZE / 2)

clone.feet = {
	Vector3.new(-2.75, 0, -3),
	Vector3.new(2.75, 0, -3),
	Vector3.new(-0.5, 0, 15),
	Vector3.new(0.5, 0, 15)
}
clone.spheres = {
	{ at = Vector3.new(0, 4.5, -7), r = 2.8 },
	{ at = Vector3.new(0, 4.6, 1), r = 2.8 },
	{ at = Vector3.new(6.5, 3.5, -1), r = 2 },
	{ at = Vector3.new(-6.5, 3.5, -1), r = 2 },
	{ at = Vector3.new(0, 6, 12), r = 1.4 },
	{ at = Vector3.new(0, 7, 22), r = 3 }
}

clone.boxes = {
	{ at = Vector3.new(0, 4.5, -2.5), size = Vector3.new(6, 5.5, 21) },
	{ at = Vector3.new(0, 6, 14), size = Vector3.new(2, 2.4, 13) },
	{ at = Vector3.new(0, 6.5, 22), size = Vector3.new(1.5, 6, 6) },
	{ at = Vector3.new(0, 3.5, -1), size = Vector3.new(17, 2.5, 5) }
}

StealthHeliModel.def = clone

return StealthHeliModel