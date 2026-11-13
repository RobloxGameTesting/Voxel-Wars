local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Airstrike = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("Airstrike"))
local ClientWorld = require(script.Parent:WaitForChild("ClientWorld"))
local VoxelCore = require(script.Parent:WaitForChild("VoxelCore"))
local Detail = require(script.Parent:WaitForChild("Detail"))

local StrikeZone = {}
StrikeZone.__index = StrikeZone

local v = { -75, -25, 25, 75 }

local cframe = CFrame.new(0, workspace.FallenPartsDestroyHeight + 60, 0)

local ZONE_COLOR = Airstrike.ZONE_COLOR
local color = Color3.fromRGB(150, 146, 140)

local v2 = { aim = 0.8, bad = 0.88, locked = 0.74 }
local v3 = { aim = 0.1, bad = 0.45, locked = 0.05 }

local v4 = nil
local function zonesFolder() -- 1 equivalent call inferred from this helper
	if v4 and v4.Parent then
		return v4
	end

	local strikeZones = Instance.new("Folder")
	strikeZones.Name = "StrikeZones"
	strikeZones.Parent = workspace
	v4 = strikeZones

	return v4
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.IgnoreWater = true

local v5 = nil
local v6 = false
local function refreshFilter()
	local vehicleHulls = workspace:FindFirstChild("VehicleHulls")

	if not v6 or vehicleHulls ~= v5 then
		v6 = true
		v5 = vehicleHulls
		local filterDescendantsInstances

		if vehicleHulls then
			filterDescendantsInstances = { workspace.Terrain, vehicleHulls }
		else
			filterDescendantsInstances = { workspace.Terrain }
		end

		raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	end
end

local function below(vector3: Vector3, p: number)
	local vector3_2 = Vector3.new(vector3.X, p, vector3.Z)
	local v7 = nil
	local v8 = nil
	local world = ClientWorld.world

	if world and world.maxX >= world.minX then
		local voxelSize = world.voxelSize
		local v9 = math.floor((vector3.X - world.origin.X) / voxelSize)
		local v10 = math.floor((vector3.Z - world.origin.Z) / voxelSize)

		if world.minX <= v9 and v9 <= world.maxX and world.minZ <= v10 and v10 <= world.maxZ then
			local v11 = math.min(p, world.origin.Y + (world.maxY + 1) * voxelSize + 0.05)
			local v12 = v11 - (p - 320)

			if v12 > 0 then
				local raycast, v13 = VoxelCore.raycast(
					world,
					Vector3.new(vector3.X, v11, vector3.Z),
					-Vector3.new(0, 1, 0),
					v12
				)

				if raycast then
					v8 = v13
					v7 = raycast
				end
			end
		end
	end

	local raycastResult = workspace:Raycast(vector3_2, Vector3.new(0, -320, 0), raycastParams)

	if raycastResult and (v7 == nil or raycastResult.Position.Y > v7.Y) then
		v7 = raycastResult.Position
		v8 = raycastResult.Normal
	end

	return v7, v8
end

local function newPart(name: string, strikeZone) -- 5 equivalent calls inferred from this helper
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Color = ZONE_COLOR
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.CFrame = cframe
	part.Parent = strikeZone
	return part
end

local function flat(vector3: Vector3, vector3_2: Vector3, vector: Vector3) -- 1 equivalent call inferred from this helper
	local v7 = vector - vector3_2 * vector:Dot(vector3_2)

	if v7.Magnitude > 0.001 then
		vector = v7.Unit
	end

	local unit = vector:Cross(vector3_2).Unit
	return CFrame.fromMatrix(vector3 + vector3_2 * 0.18, unit, vector3_2)
end

local v7 = {}
local v8 = {}

local function build()
	local strikeZone = Instance.new("Model")
	strikeZone.Name = "StrikeZone"
	local ZONE_LENGTH = Airstrike.ZONE_LENGTH
	local ZONE_WIDTH = Airstrike.ZONE_WIDTH
	local v9 = ZONE_WIDTH / 6
	local v10 = ZONE_LENGTH / 14
	local pieces = {}

	for i = 1, 6 do
		for j = 1, 14 do
			local part = newPart("Fill", strikeZone) -- inferred equivalent call
			part.Size = Vector3.new(v9 * 1.04, 0.1, v10 * 1.04)
			table.insert(pieces, {
				part = part,
				x = (i - 0.5) * v9 - ZONE_WIDTH / 2,
				z = (j - 0.5) * v10 - ZONE_LENGTH / 2,
				edge = false
			})
		end
	end

	for i = 1, 14 do
		for _, v11 in { -1, 1 } do
			local part = newPart("Rim", strikeZone) -- inferred equivalent call
			part.Size = Vector3.new(0.7, 0.16, v10 * 1.08)
			table.insert(pieces, {
				part = part,
				x = v11 * (ZONE_WIDTH / 2 - 0.35),
				z = (i - 0.5) * v10 - ZONE_LENGTH / 2,
				edge = true
			})
		end
	end

	for i = 1, 6 do
		for _, v11 in { -1, 1 } do
			local part = newPart("Rim", strikeZone) -- inferred equivalent call
			part.Size = Vector3.new(v9 * 1.08, 0.16, 0.7)
			table.insert(pieces, {
				part = part,
				x = (i - 0.5) * v9 - ZONE_WIDTH / 2,
				z = v11 * (ZONE_LENGTH / 2 - 0.35),
				edge = true
			})
		end
	end

	local chevrons = {}

	for _, v11 in v do
		for _, v12 in { -1, 1 } do
			local part = newPart("Chevron", strikeZone) -- inferred equivalent call
			part.Size = Vector3.new(1.1, 0.16, 11)

			local yaw = v12 * 0.6283185307179586

			table.insert(chevrons, {
				part = part,
				x = v12 * 0.5877852522924731 * 5.5,
				z = v11 + 4 - 4.449593469062211,
				yaw = yaw
			})
		end
	end

	local v11 = newPart("Beacon", strikeZone) -- inferred equivalent call
	v11.Shape = Enum.PartType.Cylinder
	v11.Size = Vector3.new(90, 1.2, 1.2)

	local items = {
		{
			part = v11,
			x = 0,
			z = 0,
			kind = "beacon",
			yaw = 0
		}
	}

	for _, v12 in chevrons do
		table.insert(items, {
			part = v12.part,
			x = v12.x,
			z = v12.z,
			kind = "chevron",
			yaw = v12.yaw
		})
	end

	local count = #pieces
	assert(count % 37 ~= 0, "[StrikeZone] ORDER_STRIDE must not divide the piece count")
	local v12 = 0
	local set = {}

	for _ = 1, count do
		v12 = (v12 + 37 - 1) % count + 1

		while set[v12] do
			v12 = v12 % count + 1
		end

		set[v12] = true
		local v13 = pieces[v12]
		table.insert(items, {
			part = v13.part,
			x = v13.x,
			z = v13.z,
			kind = "piece",
			yaw = 0
		})
	end

	local parts = {}
	local cframes = {}

	for _, v13 in items do
		table.insert(parts, v13.part)
		table.insert(cframes, cframe)
	end

	strikeZone.Parent = zonesFolder() -- inferred equivalent call
	return (setmetatable({
		model = strikeZone,
		pieces = pieces,
		chevrons = chevrons,
		beacon = v11,
		items = items,
		allParts = parts,
		parked = cframes,
		state = nil,
		lastCenter = nil,
		lastDir = nil,
		cursor = 1,
		remaining = 0,
		shown = false,
		glow = -1,
		owner = nil
	}, StrikeZone))
end

function StrikeZone.prewarm(p: number)
	while #v7 < p do
		table.insert(v7, build())
		task.wait()
	end
end

function StrikeZone.take(flag: boolean?, owner)
	local v9 = table.remove(v7) or build()
	v9.beacon.Transparency = flag and 0.45 or 1
	v9.state = nil
	v9.glow = -1
	v9.owner = owner

	if owner then
		v8[v9] = true
	end

	return v9
end

function StrikeZone.heldBy(p, p2): boolean
	return p.owner == p2 and not table.find(v7, p)
end

function StrikeZone.sweep()
	for k in v8 do
		local owner = k.owner

		if not (owner and owner:IsDescendantOf(game)) then
			k:release()
		end
	end
end

function StrikeZone:setState(state: string)
	if self.state == state then
		return
	end

	self.state = state
	local color2 = if state == "bad" then color else ZONE_COLOR

	for _, piece in self.pieces do
		piece.part.Color = color2
		local part = piece.part
		local transparency

		if piece.edge then
			transparency = v3[state]
		else
			transparency = v2[state]
		end

		part.Transparency = transparency
	end

	for _, chevron in self.chevrons do
		chevron.part.Color = color2
		chevron.part.Transparency = v3[state]
	end

	self.beacon.Color = color2
	self.glow = -1
end

function StrikeZone:work()
	if self.remaining <= 0 or not self.shown then
		return
	end

	local lastCenter = self.lastCenter
	local lastDir = self.lastDir
	refreshFilter()
	local unit = lastDir:Cross(Vector3.new(0, 1, 0)).Unit
	local v9 = lastCenter.Y + 140
	local items = self.items
	local v10 = #items
	local v11 = math.min(Detail.low and 20 or 40, self.remaining)
	local parts = table.create(v11)
	local v12 = table.create(v11)

	for i = 1, v11 do
		local item = items[self.cursor]
		self.cursor = self.cursor % v10 + 1
		local v13 = lastCenter + unit * item.x + lastDir * item.z
		local v14, v15 = below(v13, v9)
		local v16

		if item.kind == "beacon" then
			v16 = CFrame.new((v14 or lastCenter) + Vector3.new(0, 45, 0)) * CFrame.Angles(0, 0, 1.5707963267948966)
		elseif item.kind == "chevron" then
			local v17 = v15 or Vector3.new(0, 1, 0)
			v16 = flat( -- inferred equivalent call
				(v14 or Vector3.new(v13.X, lastCenter.Y, v13.Z)) + v17 * 0.05,
				v17,
				CFrame.fromAxisAngle(Vector3.new(0, 1, 0), item.yaw) * lastDir
			)
		elseif v14 and v15 then
			local v17 = lastDir - v15 * lastDir:Dot(v15)
			local vector

			if v17.Magnitude > 0.001 then
				vector = v17.Unit
			else
				vector = lastDir
			end

			local unit2 = vector:Cross(v15).Unit
			v16 = CFrame.fromMatrix(v14 + v15 * 0.18, unit2, v15)
		else
			local vector3 = Vector3.new(v13.X, lastCenter.Y, v13.Z)
			local v17 = lastDir - Vector3.new(0, 1, 0) * lastDir:Dot(Vector3.new(0, 1, 0))
			local vector

			if v17.Magnitude > 0.001 then
				vector = v17.Unit
			else
				vector = lastDir
			end

			local unit2 = vector:Cross(Vector3.new(0, 1, 0)).Unit
			v16 = CFrame.fromMatrix(vector3 + Vector3.new(0, 0.18, 0), unit2, Vector3.new(0, 1, 0))
		end

		parts[i] = item.part
		v12[i] = v16
	end

	self.remaining -= v11
	workspace:BulkMoveTo(parts, v12, Enum.BulkMoveMode.FireCFrameChanged)
end

function StrikeZone:place(lastCenter: Vector3, lastDir: Vector3, p: string)
	self:setState(p)
	local v9 = not self.shown
		or self.lastCenter == nil
		or (lastCenter - self.lastCenter).Magnitude > 0.3
		or self.lastDir:Dot(lastDir) < 0.99996
	self.shown = true

	if v9 then
		self.lastCenter = lastCenter
		self.lastDir = lastDir
		self.remaining = #self.items
	end

	self:work()
end

function StrikeZone:pulse(p: number)
	self:work()

	if self.state ~= "locked" then
		return
	end

	local glow = math.floor((math.sin(p * 7) * 0.5 + 0.5) * 4 + 0.5)

	if glow == self.glow then
		return
	end

	self.glow = glow
	local transparency = glow * 0.45 / 4

	for _, piece in self.pieces do
		if piece.edge then
			piece.part.Transparency = transparency
		end
	end

	for _, chevron in self.chevrons do
		chevron.part.Transparency = transparency
	end
end

function StrikeZone:hide()
	if self.shown then
		self.shown = false
		self.lastCenter = nil
		self.remaining = 0
		workspace:BulkMoveTo(self.allParts, self.parked, Enum.BulkMoveMode.FireCFrameChanged)
	end
end

function StrikeZone:release()
	self:hide()
	assert(not table.find(v7, self), "[StrikeZone] zone released twice")
	v8[self] = nil
	self.owner = nil
	table.insert(v7, self)
end

return StrikeZone