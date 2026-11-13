local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WorldConfig = require(ReplicatedStorage.Voxel.WorldConfig)
local VehicleConfig = require(ReplicatedStorage.Vehicles.VehicleConfig)
local Materials = require(ReplicatedStorage.Voxel.Materials)
local HeliModel = require(ReplicatedStorage.Vehicles.HeliModel)

local VOXEL_SIZE = WorldConfig.VOXEL_SIZE

local BomberModel = {}

local function palOf(p: string) -- 6 equivalent calls inferred from this helper
	local id = Materials.Ids[p]
	assert(id, "[BomberModel] palette " .. p .. " missing from Materials")
	return id
end

local asphalt = palOf("Asphalt") -- inferred equivalent call
local bunkerJoint = palOf("BunkerJoint") -- inferred equivalent call
local turretPlate = palOf("TurretPlate") -- inferred equivalent call
local tyre = palOf("Tyre") -- inferred equivalent call
local hullGlass = palOf("HullGlass") -- inferred equivalent call
local steel = palOf("Steel") -- inferred equivalent call
local v = {
	{ 0, 20.8 },
	{ 5.9, 10.2 },
	{ 11.7, 15 },
	{ 27, 2.8 },
	{ 47.6, 21.8 },
	{ 55, 16.5 }
}

BomberModel.EYE = Vector3.new(0, 11.4, -12.5)
BomberModel.NOZZLES = { Vector3.new(-8.8, 9.2, 11), Vector3.new(8.8, 9.2, 11) }
BomberModel.BAYS = { Vector3.new(-2.65, 3.2, -1), Vector3.new(2.65, 3.2, -1) }

local function smooth(value: number) -- 3 equivalent calls inferred from this helper
	local v2 = math.clamp(value, 0, 1)
	return v2 * v2 * (3 - v2 * 2)
end

local function leAt(p: number) -- 2 equivalent calls inferred from this helper
	return p * 0.7 + -22
end

local function teAt(p: number)
	for i = 1, #v - 1 do
		local v2 = v[i]
		local v3 = v[i + 1]

		if p <= v3[1] then
			return v2[2] + (v3[2] - v2[2]) * (p - v2[1]) / (v3[1] - v2[1])
		end
	end

	return v[#v][2]
end

local function foil(p: number) -- 1 equivalent call inferred from this helper
	if p < 0.25 then
		return (math.sin(p / 0.25 * 3.141592653589793 / 2))
	end

	local v2 = (p - 0.25) / 0.75
	return 1 - v2 * v2
end

local function centreTop(p: number, p2: number) -- 1 equivalent call inferred from this helper
	if p < 0.28 then
		return (p2 - 7.6) * math.sin(p / 0.28 * 3.141592653589793 / 2) + 7.6
	end

	if p < 0.45 then
		return p2
	end

	return p2 - (p2 - 7.6) * ((p - 0.45) / 0.55) ^ 1.3
end

local function centreBottom(p: number) -- 1 equivalent call inferred from this helper
	if p < 0.15 then
		return 7 - math.sin(p / 0.15 * 3.141592653589793 / 2) * 3.4
	end

	if p < 0.7 then
		return 3.6
	end

	local v2 = (p - 0.7) / 0.3
	return v2 * 3.6 * v2 + 3.6
end

local function hump(p: number, p2: number) -- 2 equivalent calls inferred from this helper
	local v2 = 1 - ((p - 8.8) / 4.2) ^ 2

	if v2 <= 0 or p2 < -10 or p2 > 11 then
		return 0
	end

	local v3

	if p2 < -5 then
		v3 = smooth((p2 + 10) / 5) -- inferred equivalent call
	else
		v3 = 1 - ((p2 + 5) / 16) ^ 2
	end

	return math.sqrt(v2) * 1.1 * v3
end

local function section(p: number, p2: number)
	if p > 55 then
		return nil, 0
	end

	local v2 = leAt(p) -- inferred equivalent call
	local v3 = teAt(p)

	if p2 < v2 or v3 < p2 then
		return nil, 0
	end

	local v4 = (p2 - v2) / (v3 - v2)
	local v5 = 2.6 - math.clamp((p - 14) / 41, 0, 1) * 1.7
	local v6 = foil(v4) -- inferred equivalent call
	local v7 = v5 * 0.62 * v6 + 7.2
	local v8 = 7.2 - v5 * 0.38 * v6
	local v9 = smooth((5.5 - p) / 3) -- inferred equivalent call
	local v10 = smooth((22 - p) / 10) -- inferred equivalent call
	local v11 = centreTop(v4, v9 * 1.3 + 9.6) + hump(p, p2) -- inferred equivalent call
	local v12 = centreBottom(v4) -- inferred equivalent call
	return v7 + (v11 - v7) * v10, v8 + (v12 - v8) * v10
end

local function inWindscreen(p: number, p2: number): boolean -- 2 equivalent calls inferred from this helper
	return p < 3.4 and p2 > -15.2 and p2 < -11.2
end

local function airframe(vector3: Vector3)
	local x = math.abs(vector3.X)
	local y = vector3.Y
	local z = vector3.Z
	local v2, v3 = section(x, z)

	if not v2 or y < v3 or v2 < y then
		return nil
	end

	local v4 = leAt(x) -- inferred equivalent call
	local v5 = teAt(x)
	local v6 = v2 - 0.6 < y

	if v6 and inWindscreen(x, z) then -- inferred equivalent call
		if x < 0.3 or math.abs(x - 1.65) < 0.25 or z > -11.6 or z < -14.8 then
			return tyre
		end

		return hullGlass
	end

	if math.abs(x - 8.8) < 2.8 and z > -6.8 and z < -4.2 and v2 - 1.2 < y and hump(x, z) > 0.4 then -- inferred equivalent call
		return tyre
	end

	if v6 and x > 5.5 and x < 12.5 and z > 8 and z < v5 - 0.5 then
		return tyre
	end

	if z < v4 + 0.9 or v5 - 0.7 < z then
		return bunkerJoint
	end

	if v6 and x > 14 and math.abs(z - (v4 + 5)) < 0.25 then
		return turretPlate
	end

	if
		y < v3 + 0.6
		and x < 5.4
		and z > -7
		and z < 6.5
		and (x < 0.3 or x > 5 or z < -6.6 or z > 6.1 or math.abs(x - 2.65) < 0.25)
	then
		return turretPlate
	end

	return asphalt
end

local function wheel(p: number, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number, p8: number)
	local v2 = math.abs(p - p4)

	if v2 < p7 or p8 < v2 then
		return nil
	end

	local v3 = p2 - p6
	local v4 = p3 - p5
	local v5 = v3 * v3 + v4 * v4

	if p6 * p6 < v5 then
		return nil
	end

	return if v5 < (p6 * 0.4) ^ 2 then steel else tyre
end

local function noseGear(vector3: Vector3)
	local x = math.abs(vector3.X)
	local y = vector3.Y
	local z = vector3.Z
	local v2 = math.abs(x - 0)
	local v3

	if not (v2 < 0.3 or v2 > 1.1) then
		local v4 = y - 1.1
		local v5 = z - -15
		local v6 = v4 * v4 + v5 * v5

		if not (v6 > 1.2100000000000002) then
			v3 = if v6 < 0.19360000000000005 then steel else tyre
		end
	end

	if v3 then
		return v3
	end

	if x < 0.3 and math.abs(z + 15) < 0.3 and y >= 0.8 and y < 4.4 then
		return steel
	end

	return nil
end

local function mainGear(vector3: Vector3)
	local x = math.abs(vector3.X)
	local y = vector3.Y
	local z = vector3.Z
	local v2 = math.abs(x - 12.3)
	local v3

	if not (v2 < 0.35 or v2 > 1.1) then
		local v4 = y - 1.2
		local v5 = z - -1.3
		local v6 = v4 * v4 + v5 * v5

		if not (v6 > 1.44) then
			v3 = if v6 < 0.2304 then steel else tyre
		end
	end

	if not v3 then
		local v4 = math.abs(x - 12.3)

		if v4 < 0.35 or v4 > 1.1 then
			v3 = nil
		else
			local v5 = y - 1.2
			local v6 = z - 1.3
			local v7 = v5 * v5 + v6 * v6

			if v7 > 1.44 then
				v3 = nil
			else
				v3 = if v7 < 0.2304 then steel else tyre
			end
		end
	end

	if v3 then
		return v3
	end

	if math.abs(x - 12.3) < 0.35 then
		if math.abs(z) < 1.8 and y >= 1 and y < 1.5 or math.abs(z) < 0.35 and y >= 1.5 and y < 4.2 then
			return steel
		end
	end

	return nil
end

local function classify(vector3: Vector3)
	return noseGear(vector3) or mainGear(vector3) or airframe(vector3)
end

local function glassOnly(vector3: Vector3)
	local v2 = airframe(vector3)
	return if v2 == hullGlass then v2 else nil
end

local function skinOnly(vector3: Vector3)
	local v2 = airframe(vector3)
	return if v2 ~= hullGlass then v2 else nil
end

local function speck(_: Vector3)
	return tyre
end

BomberModel.PIECES = {
	body = {
		counts = Vector3.new(222, 24, 88),
		lo = Vector3.new(-55.5, 0, -22.5),
		shape = skinOnly,
		at = Vector3.new(0, 0, 0)
	},
	canopy = {
		counts = Vector3.new(14, 24, 10),
		lo = Vector3.new(-3.5, 0, -15.5),
		shape = glassOnly,
		at = Vector3.new(0, 0, 0)
	},
	gearNose = {
		counts = Vector3.new(5, 9, 6),
		lo = Vector3.new(-1.25, 0, -16.5),
		shape = noseGear,
		at = Vector3.new(0, 0, 0)
	},
	gearRight = {
		counts = Vector3.new(6, 9, 10),
		lo = Vector3.new(10.8, 0, -2.5),
		shape = mainGear,
		at = Vector3.new(0, 0, 0)
	},
	gearLeft = {
		counts = Vector3.new(6, 9, 10),
		lo = Vector3.new(-13.8, 0, -2.5),
		shape = mainGear,
		at = Vector3.new(0, 0, 0)
	},
	mainRotor = {
		counts = Vector3.new(1, 1, 1),
		lo = Vector3.new(-0.25, -0.25, -0.25),
		shape = speck,
		at = BomberModel.NOZZLES[1]
	},
	tailRotor = {
		counts = Vector3.new(1, 1, 1),
		lo = Vector3.new(-0.25, -0.25, -0.25),
		shape = speck,
		at = BomberModel.NOZZLES[2]
	},
	light = {
		counts = Vector3.new(1, 1, 1),
		lo = Vector3.new(-0.25, -0.25, -0.25),
		shape = speck,
		at = Vector3.new(0, 3.2, -14)
	}
}

BomberModel.GEAR = {
	gearNose = { hinge = Vector3.new(0, 4.2, -15), fold = CFrame.Angles(-1.5, 0, 0) },
	gearRight = { hinge = Vector3.new(12.3, 4, 0), fold = CFrame.Angles(1.5, 0, 0) },
	gearLeft = { hinge = Vector3.new(-12.3, 4, 0), fold = CFrame.Angles(1.5, 0, 0) }
}

BomberModel.MESH_PARTS = {
	body = "Body",
	canopy = "Canopy",
	gearNose = "gearNose",
	gearRight = "gearRight",
	gearLeft = "gearLeft"
}

local v2 = {}
function BomberModel.boxesFor(p: string)
	local v3 = v2[p]

	if v3 then
		return v3
	end

	local VoxelCore = require(ReplicatedStorage.Voxel.VoxelCore)
	local v4 = BomberModel.PIECES[p]
	assert(v4, "[BomberModel] no piece " .. p)
	local x = v4.counts.X
	local y = v4.counts.Y
	local z = v4.counts.Z
	local buf = buffer.create(x * y * z)

	for i = 0, z - 1 do
		for j = 0, y - 1 do
			for k = 0, x - 1 do
				local shape = v4.shape(v4.lo + Vector3.new(k + 0.5, j + 0.5, i + 0.5) * VOXEL_SIZE)

				if shape then
					buffer.writeu8(buf, k + x * (j + y * i), shape)
				end
			end
		end
	end

	local out = {}
	local greedy = VoxelCore.greedy(buf, x, y, z, buffer.create(x * y * z), out)
	assert(greedy > 0, "[BomberModel] piece " .. p .. " has no cells")
	local v5 = { n = greedy, out = out }
	v2[p] = v5
	return v5
end

local v3 = {}
function BomberModel.cellsOf(p: string)
	local v4 = BomberModel.PIECES[p]
	assert(v4, "[BomberModel] no piece " .. p)
	local v5 = if p == "body" then classify else v4.shape
	local v6 = v3[p]

	if v6 then
		return v6, v4.lo
	end

	v6 = {}

	for i = 0, v4.counts.Z - 1 do
		for j = 0, v4.counts.Y - 1 do
			for k = 0, v4.counts.X - 1 do
				local v7 = v5(v4.lo + Vector3.new(k + 0.5, j + 0.5, i + 0.5) * VOXEL_SIZE)

				if v7 then
					table.move({ k, j, i, v7 }, 1, 4, #v6 + 1, v6)
				end
			end
		end
	end

	v3[p] = v6

	return v6, v4.lo
end

BomberModel.noFarRotor = true

function BomberModel.bake()
	local bomberMesh = Instance.new("Model")
	bomberMesh.Name = "BomberMesh"

	for k, name in BomberModel.MESH_PARTS do
		local v4 = BomberModel.PIECES[k]
		local boxesFor = BomberModel.boxesFor(k)
		local v5 = {}

		for i = 0, boxesFor.n - 1 do
			local v6 = i * 7
			local size = Vector3.new(boxesFor.out[v6 + 4], boxesFor.out[v6 + 5], boxesFor.out[v6 + 6]) * VOXEL_SIZE
			local v7 = v4.lo + Vector3.new(boxesFor.out[v6 + 1], boxesFor.out[v6 + 2], boxesFor.out[v6 + 3]) * VOXEL_SIZE + size * 0.5
			local part = Instance.new("Part")
			part.Anchored = true
			part.Material = Enum.Material.SmoothPlastic
			local smooth2 = Enum.SurfaceType.Smooth
			local smooth3 = Enum.SurfaceType.Smooth
			part.TopSurface = smooth2
			part.BottomSurface = smooth3
			part.Size = size
			part.CFrame = CFrame.new(v7)
			part.Color = Materials.Palette[boxesFor.out[v6 + 7]].color
			table.insert(v5, part)
		end

		local function unite(list)
			if #list == 1 then
				return list[1]
			end

			local v6 = table.remove(list, 1)
			v6.Parent = workspace

			for _, item in list do
				item.Parent = workspace
			end

			local unionAsync = v6:UnionAsync(list, Enum.CollisionFidelity.Box, Enum.RenderFidelity.Precise)
			v6:Destroy()

			for _, item in list do
				item:Destroy()
			end

			return unionAsync
		end

		local v6 = {}

		for i = 1, #v5, 300 do
			table.insert(v6, unite(table.move(v5, i, math.min(i + 300 - 1, #v5), 1, {})))
			task.wait()
		end

		local v7 = unite(v6)
		v7.Name = name
		v7.UsePartColor = false
		v7.Anchored = true
		v7.CanCollide = false
		v7.CanQuery = false
		v7.CanTouch = false
		v7:SetAttribute("At", CFrame.new(v7.CFrame.Position))
		v7.Parent = bomberMesh
	end

	return bomberMesh
end

local clone = table.clone(HeliModel)
clone.jet = true
clone.bomber = true
clone.noBots = true
clone.noFlames = true
clone.tuning = VehicleConfig.Bomber
clone.wear = 1.1
clone.seats = {
	{ root = Vector3.new(0, 9, -11), exit = Vector3.new(0, 3, -28), drive = true }
}
clone.DOOR_GUNS = {}

clone.sfx = {
	core = { id = 9113201103, loop = NumberRange.new(20, 24), gain = 4.2 },
	body = { id = 9119414082, loop = NumberRange.new(4, 30), gain = 1 },
	burn = { id = 9113044263, loop = NumberRange.new(1.5, 8), gain = 0.6 },
	cabin = { id = 9112812234, loop = NumberRange.new(2, 34), gain = 0.5 }
}

clone.GUN_MUZZLE = Vector3.new(0, 7.4, -22)
clone.PODS = BomberModel.BAYS
clone.EYE = BomberModel.EYE
clone.NOZZLES = BomberModel.NOZZLES
clone.cellsOf = BomberModel.cellsOf

function clone.build()
	local clone2 = ReplicatedStorage.Vehicles.BomberMesh:Clone()
	local parts = {}
	local v4 = {}
	local ats = {}
	local v5 = {}
	local v6 = nil

	for _, part in clone2:GetChildren() do
		assert(part:IsA("BasePart"), "[BomberModel] BomberMesh holds only parts")
		table.insert(parts, part)
		table.insert(v4, (part:GetAttribute("At")))
		table.insert(ats, (part:GetAttribute("At")))

		if part.Name == "Canopy" then
			v6 = part
		end

		local v7 = BomberModel.GEAR[part.Name]

		if not v7 then
			continue
		end

		local axisAngle, angle = v7.fold:ToAxisAngle()
		table.insert(v5, {
			part = part,
			at = #parts,
			hinge = v7.hinge,
			axis = axisAngle,
			angle = angle
		})
	end

	assert(v6, "[BomberModel] BomberMesh has no Canopy")
	assert(#v5 == 3, "[BomberModel] BomberMesh has no gear legs")
	local v7 = table.create(#parts, CFrame.identity)
	local v8 = CFrame.identity
	local v9 = { model = clone2, parts = parts }
	function v9.pose(cframe: CFrame)
		v8 = cframe

		for k, v10 in v4 do
			v7[k] = cframe * v10
		end

		workspace:BulkMoveTo(parts, v7, Enum.BulkMoveMode.FireCFrameChanged)
	end

	function v9.gear(p: number)
		for _, v10 in v5 do
			local cframe = CFrame.fromAxisAngle(v10.axis, v10.angle * p)
			v4[v10.at] = CFrame.new(v10.hinge) * cframe * CFrame.new(-v10.hinge) * ats[v10.at]
			v10.part.Transparency = p >= 1 and 1 or 0
		end

		v9.pose(v8)
	end
	function v9.tint(color: Color3?)
		for _, v10 in parts do
			if v10 == v6 then
				continue
			end

			v10.UsePartColor = color ~= nil

			if color then
				v10.Color = color
			end
		end
	end
	function v9.hide(_: string) end
	function v9.clearGlass(flag: boolean)
		v6.LocalTransparencyModifier = flag and 1 or 0
	end
	function v9.frameOf(_: string)
		return v8
	end

	function v9.shade(p: number)
		for _, v10 in parts do
			v10.CastShadow = p <= 1 and v10 ~= v6
		end
	end

	function v9.reset()
		v9.tint(nil)
		v9.clearGlass(false)
		v9.shade(0)
		local RigidParts = require(ReplicatedStorage.Vehicles.RigidParts)
		v8 = RigidParts.PARK
		v9.gear(0)
	end
	return v9
end

local body = BomberModel.PIECES.body
local x = body.counts.X
local y = body.counts.Y
local z = body.counts.Z
local buf = buffer.create(x * y * z)

for i = 0, z - 1 do
	local v4 = body.lo.Z + (i + 0.5) * VOXEL_SIZE

	for j = 0, x - 1 do
		local v5 = body.lo.X + (j + 0.5) * VOXEL_SIZE
		local v6 = math.abs(v5)
		local v7, v8 = section(v6, v4)

		if not v7 then
			continue
		end

		local v9 = inWindscreen(v6, v4) -- inferred equivalent call

		for k = math.max(math.floor(v8 / VOXEL_SIZE), 0), math.min(math.ceil(v7 / VOXEL_SIZE), y - 1) do
			local v10 = body.lo.Y + (k + 0.5) * VOXEL_SIZE

			if not (v8 <= v10 and v10 <= v7 and (not v9 or airframe(Vector3.new(v5, v10, v4)) ~= hullGlass)) then
				continue
			end

			buffer.writeu8(buf, j + x * (k + y * i), asphalt)
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
	Vector3.new(-12.3, 0, 0),
	Vector3.new(12.3, 0, 0),
	Vector3.new(-0.3, 0, -15),
	Vector3.new(0.3, 0, -15)
}

clone.spheres = {
	{ at = Vector3.new(0, 7.2, -14), r = 3 },
	{ at = Vector3.new(0, 7, -4), r = 3.4 },
	{ at = Vector3.new(0, 7, 6), r = 3.2 },
	{ at = Vector3.new(0, 7.4, 15), r = 1.6 }
}

for _, v4 in {
	{ 9, -2, 3.2 },
	{ 16, 0, 2.2 },
	{ 25, 0.5, 1.6 },
	{ 35, 6.5, 1.2 },
	{ 45, 14, 1 },
	{ 52.5, 16.6, 0.8 }
} do
	table.insert(clone.spheres, { at = Vector3.new(v4[1], 7.2, v4[2]), r = v4[3] })
	table.insert(clone.spheres, {
		at = Vector3.new(-v4[1], 7.2, v4[2]),
		r = v4[3]
	})
end

clone.boxes = {
	{ at = Vector3.new(0, 7, 0), size = Vector3.new(26, 7, 40) },
	{ at = Vector3.new(27, 7.2, 4), size = Vector3.new(28, 2.4, 22) },
	{ at = Vector3.new(-27, 7.2, 4), size = Vector3.new(28, 2.4, 22) },
	{ at = Vector3.new(47, 7.2, 15), size = Vector3.new(16, 1.6, 10) },
	{ at = Vector3.new(-47, 7.2, 15), size = Vector3.new(16, 1.6, 10) }
}

BomberModel.def = clone

return BomberModel