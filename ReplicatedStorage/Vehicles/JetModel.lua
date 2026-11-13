local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WorldConfig = require(ReplicatedStorage.Voxel.WorldConfig)
local VehicleConfig = require(ReplicatedStorage.Vehicles.VehicleConfig)
local Materials = require(ReplicatedStorage.Voxel.Materials)
local HeliModel = require(ReplicatedStorage.Vehicles.HeliModel)

local VOXEL_SIZE = WorldConfig.VOXEL_SIZE

local JetModel = {}

local function palOf(p: string)
	local id = Materials.Ids[p]
	assert(id, "[JetModel] palette " .. p .. " missing from Materials")
	return id
end

local BunkerRoof = Materials.Ids.BunkerRoof
assert(BunkerRoof, "[JetModel] palette BunkerRoof missing from Materials")
local Tyre = Materials.Ids.Tyre
assert(Tyre, "[JetModel] palette Tyre missing from Materials")
local BunkerSteel = Materials.Ids.BunkerSteel
assert(BunkerSteel, "[JetModel] palette BunkerSteel missing from Materials")
local HullGlass = Materials.Ids.HullGlass
assert(HullGlass, "[JetModel] palette HullGlass missing from Materials")
local TailLamp = Materials.Ids.TailLamp
assert(TailLamp, "[JetModel] palette TailLamp missing from Materials")
assert(Materials.Ids.Concrete, "[JetModel] palette Concrete missing from Materials")

JetModel.EYE = Vector3.new(0, 7, -8.4)
JetModel.NOZZLES = { Vector3.new(-1.3, 4.6, 20), Vector3.new(1.3, 4.6, 20) }
JetModel.CANNON = Vector3.new(1.5, 5.6, -14.5)
JetModel.BELLY = { Vector3.new(-1.75, 2.2, 1), Vector3.new(1.75, 2.2, 1) }

local v = {
	{ -20.5, 0.25, 4.4, 4.9 },
	{ -14, 1.25, 3.6, 5.8 },
	{ -8, 2, 3.2, 6.4 },
	{ 0, 2.6, 3, 6.4 },
	{ 10, 2.6, 3.2, 6.2 },
	{ 19, 2, 3.6, 5.8 }
}

local function lerp(p: number, p2: number, p3: number) -- 3 equivalent calls inferred from this helper
	return p + (p2 - p) * p3
end

local function fuselage(x: number, y: number, z: number)
	for i = 1, #v - 1 do
		local v2 = v[i]
		local v3 = v[i + 1]

		if v2[1] <= z and z <= v3[1] then
			local v4 = (z - v2[1]) / (v3[1] - v2[1])
			local v5 = lerp(v2[2], v3[2], v4) -- inferred equivalent call
			local v6 = lerp(v2[3], v3[3], v4) -- inferred equivalent call
			local v7 = lerp(v2[4], v3[4], v4) -- inferred equivalent call

			if y < v6 or v7 < y then
				return false, v6, v7
			end

			local midpoint = (v6 + v7) / 2
			local v8 = (v7 - v6) / 2
			local v9 = (y - midpoint) / v8
			return x <= v5 * (1 - v9 * 0.35 * v9), v6, v7
		end
	end

	return false, 0, 0
end

local function wheel(x: number, y: number, z: number, p: number, p2: number) -- 2 equivalent calls inferred from this helper
	if not (math.abs(x - p) < 0.4) then
		return nil
	end

	local v2 = y - 0.9
	local v3 = z - p2
	local v4 = v2 * v2 + v3 * v3

	if v4 <= 0.81 then
		return if v4 < 0.12 then BunkerSteel else Tyre
	elseif math.abs(v3) < 0.3 and y >= 1.5 and y < 4 then
		return BunkerSteel
	end

	return nil
end

local function noseGear(vector3: Vector3) -- 1 equivalent call inferred from this helper
	return wheel(math.abs(vector3.X), vector3.Y, vector3.Z, 0, -13) -- inferred equivalent call
end

local function mainGear(vector3: Vector3) -- 1 equivalent call inferred from this helper
	return wheel(math.abs(vector3.X), vector3.Y, vector3.Z, 3.25, 2) -- inferred equivalent call
end

local function airframe(vector3: Vector3)
	local x = math.abs(vector3.X)
	local y = vector3.Y
	local z = vector3.Z
	local v2, v3, v4 = fuselage(x, y, z)

	if z > -13.5 and z < -5.5 and v4 - 0.25 < y and y < v4 + 1.75 then
		local v5 = (z + 9.5) / 4
		local v6 = v4 + 1.5 - v5 * 1.75 * v5

		if y < v6 and x < 1.35 - (y - v4) * 0.3 then
			if 0.9 - (y - v4) * 0.3 < x or v6 - 0.5 < y then
				if math.abs(z + 11) < 0.25 or math.abs(z + 7.25) < 0.25 then
					return Tyre
				end

				return HullGlass
			end

			return nil
		end
	end

	if v2 then
		if z > -13 and z < -5.5 and v3 + 1 < y and x < 1.2 then
			if z < -11.5 and y < v4 - 0.75 or z > -7.5 and y < v4 - 0.25 then
				return Tyre
			end

			return nil
		end

		if z < -18.5 then
			return BunkerSteel
		end

		if math.abs(y - (v3 + v4) / 2 + 0.75) < 0.2 and x > 1.2 then
			return Tyre
		end

		if math.abs(z - 3.25) < 0.2 or math.abs(z - 12.25) < 0.2 then
			return Tyre
		end

		return BunkerRoof
	elseif x >= 2 and x < 3.5 and y >= 3.25 and y < 5.25 and z >= -8 and z < 8 then
		return if z < -7.5 and x > 2.25 then Tyre else BunkerRoof
	else
		if x >= 2 and x < 15 and y >= 4 and y < 4.75 then
			local v5 = (x - 2) * 0.85 + -3
			local v6 = 10.5 - (x - 2) * 0.1

			if v5 <= z and z <= v6 then
				if z < v5 + 0.6 then
					return BunkerSteel
				end

				if v6 - 0.5 < z then
					return Tyre
				end

				return if x > 14 then TailLamp else BunkerRoof
			end
		end

		if
			x >= 1.5
			and x < 6
			and y >= 5
			and y < 5.5
			and (x - 1.5) * 0.7 + -12.5 <= z
			and z <= (x - 1.5) * 0.25 + -9.5
		then
			return BunkerRoof
		end

		if x >= 2 and x < 8 and y >= 4.25 and y < 4.75 and (x - 2) * 0.7 + 12 <= z and z <= 18.5 then
			return BunkerRoof
		end

		if y >= 6 and y < 12.5 then
			local v5 = y - 6

			if math.abs(x - (v5 * 0.3 + 2.25)) <= 0.3 and v5 * 0.9 + 10.5 <= z and z <= v5 * 0.4 + 17 then
				return if y > 11.75 then BunkerSteel else BunkerRoof
			end
		end

		if z >= 18 and z < 20.5 then
			local v5 = x - 1.3
			local v6 = y - 4.6
			local v7 = v5 * v5 + v6 * v6

			if v7 <= 1.44 then
				if v7 < 0.8 and z > 19 then
					return nil
				end

				return Tyre
			end
		end

		return nil
	end
end

local function classify(vector3: Vector3) -- 1 equivalent call inferred from this helper
	return noseGear(vector3) or mainGear(vector3) or airframe(vector3) -- inferred equivalent call
end

local TankWhite = Materials.Ids.TankWhite
assert(TankWhite, "[JetModel] palette TankWhite missing from Materials")

local v2 = { at = Vector3.new(0, 0, -1.75), size = Vector3.new(2, 1, 0.5), pal = TankWhite }
local tankWhite = Materials.Ids.TankWhite
assert(tankWhite, "[JetModel] palette TankWhite missing from Materials")

local v3 = { at = Vector3.new(0, 0, -1.75), size = Vector3.new(1, 2, 0.5), pal = tankWhite }
local HardSteel = Materials.Ids.HardSteel
assert(HardSteel, "[JetModel] palette HardSteel missing from Materials")

local v4 = { at = Vector3.new(0, 0, 0.75), size = Vector3.new(2, 1, 4.5), pal = HardSteel }
local hardSteel = Materials.Ids.HardSteel
assert(hardSteel, "[JetModel] palette HardSteel missing from Materials")

local v5 = { at = Vector3.new(0, 0, 0.75), size = Vector3.new(1, 2, 4.5), pal = hardSteel }
local v6 = {
	{ at = Vector3.new(0, 0, -3.75), size = Vector3.new(0.5, 0.5, 0.5), pal = Tyre },
	{ at = Vector3.new(0, 0, -3.25), size = Vector3.new(1, 1, 0.5), pal = Tyre },
	{ at = Vector3.new(0, 0, -2.5), size = Vector3.new(1.5, 1.5, 1), pal = Tyre },
	v2,
	v3,
	v4,
	v5,
	{ at = Vector3.new(0, 0, 3.25), size = Vector3.new(1.5, 1.5, 0.5), pal = Tyre },
	{ at = Vector3.new(0, 0, 3.75), size = Vector3.new(1, 1, 0.5), pal = Tyre },
	{ at = Vector3.new(0, 0, 2.75), size = Vector3.new(3, 0.5, 1.5), pal = Tyre },
	{ at = Vector3.new(0, 0, 2.75), size = Vector3.new(0.5, 3, 1.5), pal = Tyre }
}

JetModel.BOMB_BOXES = v6

local function arms(vector3: Vector3)
	local v7 = Vector3.new(math.abs(vector3.X), vector3.Y, vector3.Z) - JetModel.BELLY[2]

	for _, v8 in v6 do
		local v9 = v7 - v8.at

		if math.abs(v9.X) <= v8.size.X / 2 and math.abs(v9.Y) <= v8.size.Y / 2 and math.abs(v9.Z) <= v8.size.Z / 2 then
			return v8.pal
		end
	end

	return nil
end

local function speck(_: Vector3)
	return BunkerSteel
end

JetModel.PIECES = {
	body = {
		counts = Vector3.new(62, 30, 84),
		lo = Vector3.new(-15.5, 0, -21),
		shape = airframe,
		at = Vector3.new(0, 0, 0)
	},
	gearNose = {
		counts = Vector3.new(2, 8, 4),
		lo = Vector3.new(-0.5, 0, -14),
		shape = noseGear,
		at = Vector3.new(0, 0, 0)
	},
	gearRight = {
		counts = Vector3.new(2, 8, 4),
		lo = Vector3.new(2.75, 0, 1),
		shape = mainGear,
		at = Vector3.new(0, 0, 0)
	},
	gearLeft = {
		counts = Vector3.new(2, 8, 4),
		lo = Vector3.new(-3.75, 0, 1),
		shape = mainGear,
		at = Vector3.new(0, 0, 0)
	},
	mainRotor = {
		counts = Vector3.new(1, 1, 1),
		lo = Vector3.new(-0.25, -0.25, -0.25),
		shape = speck,
		at = JetModel.NOZZLES[1] - Vector3.new(0, 0, 1)
	},
	tailRotor = {
		counts = Vector3.new(1, 1, 1),
		lo = Vector3.new(-0.25, -0.25, -0.25),
		shape = speck,
		at = JetModel.NOZZLES[2] - Vector3.new(0, 0, 1)
	},
	light = {
		counts = Vector3.new(1, 1, 1),
		lo = Vector3.new(-0.25, -0.25, -0.25),
		shape = speck,
		at = Vector3.new(0, 3.5, -12)
	},
	arms = {
		counts = Vector3.new(46, 7, 36),
		lo = Vector3.new(-11.5, 0.5, -6),
		shape = arms,
		at = Vector3.new(0, 0, 0)
	}
}

JetModel.noFarRotor = true

JetModel.GEAR = {
	gearNose = { hinge = Vector3.new(0, 4.4, -13), fold = CFrame.Angles(-1.5, 0, 0) },
	gearRight = { hinge = Vector3.new(3.25, 4.6, 2), fold = CFrame.Angles(0, 0, -1.45) },
	gearLeft = { hinge = Vector3.new(-3.25, 4.6, 2), fold = CFrame.Angles(0, 0, 1.45) }
}

local v7 = {}
function JetModel.boxesFor(p: string)
	local v8 = v7[p]

	if v8 then
		return v8
	end

	local VoxelCore = require(ReplicatedStorage.Voxel.VoxelCore)
	local v9 = JetModel.PIECES[p]
	assert(v9, "[JetModel] no piece " .. p)
	local x = v9.counts.X
	local y = v9.counts.Y
	local z = v9.counts.Z
	local buf = buffer.create(x * y * z)

	for i = 0, z - 1 do
		for j = 0, y - 1 do
			for k = 0, x - 1 do
				local shape = v9.shape(v9.lo + Vector3.new(k + 0.5, j + 0.5, i + 0.5) * VOXEL_SIZE)

				if shape then
					buffer.writeu8(buf, k + x * (j + y * i), shape)
				end
			end
		end
	end

	local out = {}
	local greedy = VoxelCore.greedy(buf, x, y, z, buffer.create(x * y * z), out)
	assert(greedy > 0, "[JetModel] piece " .. p .. " has no cells")
	local v10 = { n = greedy, out = out }
	v7[p] = v10
	return v10
end

local v8 = {}
function JetModel.cellsOf(p: string)
	local v9 = JetModel.PIECES[p]
	assert(v9, "[JetModel] no piece " .. p)
	local v10 = v8[p]

	if v10 then
		return v10, v9.lo
	end

	v10 = {}

	for i = 0, v9.counts.Z - 1 do
		for j = 0, v9.counts.Y - 1 do
			for k = 0, v9.counts.X - 1 do
				local shape = v9.shape(v9.lo + Vector3.new(k + 0.5, j + 0.5, i + 0.5) * VOXEL_SIZE)

				if shape then
					table.move({ k, j, i, shape }, 1, 4, #v10 + 1, v10)
				end
			end
		end
	end

	v8[p] = v10

	return v10, v9.lo
end

local v9 = nil
function JetModel.farBoxes()
	if v9 then
		return v9
	end

	local VoxelCore = require(ReplicatedStorage.Voxel.VoxelCore)
	local body = JetModel.PIECES.body

	local v10 = math.ceil(body.counts.X / 2)
	local v11 = math.ceil(body.counts.Y / 2)
	local v12 = math.ceil(body.counts.Z / 2)
	local buf = buffer.create(v10 * v11 * v12)

	for i = 0, v12 - 1 do
		for j = 0, v11 - 1 do
			for k = 0, v10 - 1 do
				local count = 0
				local v13 = {}
				local v14 = 0
				local v15 = 0

				for i2 = 0, 1 do
					for i3 = 0, 1 do
						for i4 = 0, 1 do
							local shape = body.shape(body.lo + Vector3.new(
								k * 2 + i4 + 0.5,
								j * 2 + i3 + 0.5,
								i * 2 + i2 + 0.5
							) * VOXEL_SIZE)

							if not shape then
								continue
							end

							count += 1
							v13[shape] = (v13[shape] or 0) + 1

							if not (v14 < v13[shape]) then
								continue
							end

							v14 = v13[shape]
							v15 = shape
						end
					end
				end

				if count >= 2 then
					buffer.writeu8(buf, k + v10 * (j + v11 * i), v15)
				end
			end
		end
	end

	local v13 = {}
	local greedy = VoxelCore.greedy(buf, v10, v11, v12, buffer.create(v10 * v11 * v12), v13)

	local v14 = 2 * VOXEL_SIZE
	local v15 = {}

	for i = 0, greedy - 1 do
		local v16 = i * 7
		local v17 = Vector3.new(v13[v16 + 4], v13[v16 + 5], v13[v16 + 6]) * v14
		local v18 = body.lo + Vector3.new(v13[v16 + 1], v13[v16 + 2], v13[v16 + 3]) * v14 + v17 * 0.5
		table.move({
			v18.X,
			v18.Y,
			v18.Z,
			v17.X,
			v17.Y,
			v17.Z,
			v13[v16 + 7]
		}, 1, 7, #v15 + 1, v15)
	end

	v9 = v15
	return v15
end

local clone = table.clone(HeliModel)
clone.jet = true
clone.noBots = true
clone.tuning = VehicleConfig.Jet
clone.wear = 1.8
clone.seats = {
	{ root = Vector3.new(0, 5.2, -8.6), exit = Vector3.new(8, 3, -8), drive = true }
}
clone.DOOR_GUNS = {}

clone.sfx = {
	core = { id = 9113201103, loop = NumberRange.new(20, 24), gain = 4.7 },
	body = { id = 9119414082, loop = NumberRange.new(4, 30), gain = 0.8 },
	burn = { id = 9113044263, loop = NumberRange.new(1.5, 8), gain = 1 },
	cabin = { id = 9112812234, loop = NumberRange.new(2, 34), gain = 0.5 }
}

clone.GUN_MUZZLE = JetModel.CANNON
clone.PODS = JetModel.BELLY
clone.EYE = JetModel.EYE
clone.NOZZLES = JetModel.NOZZLES
clone.cellsOf = JetModel.cellsOf

function clone.build()
	local clone2 = ReplicatedStorage.Vehicles.JetMesh:Clone()
	local parts = {}
	local v10 = {}
	local ats = {}
	local v11 = {}
	local v12 = nil

	for _, part in clone2:GetChildren() do
		assert(part:IsA("BasePart"), "[JetModel] JetMesh holds only parts")
		table.insert(parts, part)
		table.insert(v10, (part:GetAttribute("At")))
		table.insert(ats, (part:GetAttribute("At")))

		if part.Name == "Canopy" then
			v12 = part
		end

		local v13 = JetModel.GEAR[part.Name]

		if not v13 then
			continue
		end

		local axisAngle, angle = v13.fold:ToAxisAngle()
		table.insert(v11, {
			part = part,
			at = #parts,
			hinge = v13.hinge,
			axis = axisAngle,
			angle = angle
		})
	end

	assert(v12, "[JetModel] JetMesh has no Canopy")
	assert(#v11 == 3, "[JetModel] JetMesh has no gear legs")
	local v13 = table.create(#parts, CFrame.identity)
	local v14 = CFrame.identity
	local v15 = { model = clone2, parts = parts }
	function v15.pose(cframe: CFrame)
		v14 = cframe

		for k, v16 in v10 do
			v13[k] = cframe * v16
		end

		workspace:BulkMoveTo(parts, v13, Enum.BulkMoveMode.FireCFrameChanged)
	end

	function v15.gear(p: number)
		for _, v16 in v11 do
			local cframe = CFrame.fromAxisAngle(v16.axis, v16.angle * p)
			v10[v16.at] = CFrame.new(v16.hinge) * cframe * CFrame.new(-v16.hinge) * ats[v16.at]
			v16.part.Transparency = p >= 1 and 1 or 0
		end

		v15.pose(v14)
	end
	function v15.tint(color: Color3?)
		for _, v16 in parts do
			if v16 == v12 then
				continue
			end

			v16.UsePartColor = color ~= nil

			if color then
				v16.Color = color
			end
		end
	end
	function v15.hide(_: string) end
	function v15.clearGlass(flag: boolean)
		v12.LocalTransparencyModifier = flag and 1 or 0
	end
	function v15.frameOf(_: string)
		return v14
	end

	function v15.shade(p: number)
		for _, v16 in parts do
			v16.CastShadow = p <= 1 and v16 ~= v12
		end
	end

	function v15.reset()
		v15.tint(nil)
		v15.clearGlass(false)
		v15.shade(0)
		local RigidParts = require(ReplicatedStorage.Vehicles.RigidParts)
		v14 = RigidParts.PARK
		v15.gear(0)
	end
	return v15
end

local body = JetModel.PIECES.body
local x = body.counts.X
local y = body.counts.Y
local z = body.counts.Z
local buf = buffer.create(x * y * z)

for i = 0, z - 1 do
	for j = 0, y - 1 do
		for k = 0, x - 1 do
			local v10 = classify(body.lo + Vector3.new(k + 0.5, j + 0.5, i + 0.5) * VOXEL_SIZE) -- inferred equivalent call

			if v10 and v10 ~= HullGlass then
				buffer.writeu8(buf, k + x * (j + y * i), BunkerRoof)
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
	Vector3.new(-3.25, 0, 2),
	Vector3.new(3.25, 0, 2),
	Vector3.new(-0.2, 0, -13),
	Vector3.new(0.2, 0, -13)
}
clone.spheres = {
	{ at = Vector3.new(0, 4.7, -14), r = 1.5 },
	{ at = Vector3.new(0, 4.7, -6), r = 2.2 },
	{ at = Vector3.new(0, 4.7, 4), r = 2.6 },
	{ at = Vector3.new(0, 5, 15), r = 2.4 },
	{ at = Vector3.new(11, 4.4, 8), r = 1.5 },
	{ at = Vector3.new(-11, 4.4, 8), r = 1.5 }
}

clone.boxes = {
	{ at = Vector3.new(0, 4.7, -1), size = Vector3.new(6, 3.6, 36) },
	{ at = Vector3.new(0, 4.4, 6), size = Vector3.new(28, 0.8, 9) },
	{ at = Vector3.new(0, 9, 16), size = Vector3.new(7, 6, 7) }
}

JetModel.def = clone

return JetModel