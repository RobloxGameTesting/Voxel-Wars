--!native
local Gravity = workspace.Gravity
workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
	Gravity = workspace.Gravity
end)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VoxelCore = require(ReplicatedStorage.Voxel.VoxelCore)
local Materials = require(ReplicatedStorage.Voxel.Materials)
local WorldConfig = require(ReplicatedStorage.Voxel.WorldConfig)
local VoxelSound = require(ReplicatedStorage.Voxel.VoxelSound)
local Quality = require(ReplicatedStorage.Voxel.Quality)
local Detail = require(ReplicatedStorage.Voxel.Detail)

local WorldRay = require(ReplicatedStorage.Voxel:WaitForChild("WorldRay"))

local cframe = CFrame.new(0, -100000, 0)

local Palette = Materials.Palette
local VOXEL_SIZE = WorldConfig.VOXEL_SIZE
local v = WorldConfig.ORIGIN
WorldConfig.onOrigin(function(vector3: Vector3)
	v = vector3
end)

local LooseChunks = {}
LooseChunks.spent = 0
local voxelLoose = Instance.new("Folder")
voxelLoose.Name = "VoxelLoose"
voxelLoose.Parent = workspace

local v2 = {}
local v3 = {}

local v4 = {}

local raycastParams = RaycastParams.new()
raycastParams.IgnoreWater = true
local flag = false

local function refreshFilter()
	flag = false
	local excludeInstances = { voxelLoose }

	for _, childName in { "VoxelChips", "VoxelFalling" } do
		local child = workspace:FindFirstChild(childName)

		if child then
			table.insert(excludeInstances, child)
		end
	end

	for _, v5 in Players:GetPlayers() do
		if v5.Character then
			table.insert(excludeInstances, v5.Character)
		end
	end

	raycastParams.ExcludeInstances = excludeInstances
end

local function acquire()
	local v5 = table.remove(v2)

	if v5 then
		return v5
	end

	local part = Instance.new("Part")
	part.Anchored = true
	part.CanTouch = false
	part.CanCollide = false
	part.CanQuery = false
	part.CastShadow = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.CFrame = cframe
	part.Parent = voxelLoose
	return part
end

function LooseChunks.build(list, small: boolean, parent)
	local voxels = #list // 4
	local minValue = 1e999
	local minValue2 = 1e999
	local minValue3 = 1e999
	local maxValue = -1e999
	local maxValue2 = -1e999
	local maxValue3 = -1e999

	for i = 1, #list, 4 do
		local item = list[i]
		local item2 = list[i + 1]
		local item3 = list[i + 2]
		minValue = math.min(minValue, item)
		minValue2 = math.min(minValue2, item2)
		minValue3 = math.min(minValue3, item3)
		maxValue = math.max(maxValue, item)
		maxValue2 = math.max(maxValue2, item2)
		maxValue3 = math.max(maxValue3, item3)
	end

	local v5 = maxValue - minValue + 1
	local v6 = maxValue2 - minValue2 + 1
	local v7 = maxValue3 - minValue3 + 1
	local buf = buffer.create(v5 * v6 * v7)
	local v8 = {}

	for i = 1, #list, 4 do
		buffer.writeu8(
			buf,
			list[i] - minValue + v5 * (list[i + 1] - minValue2 + v6 * (list[i + 2] - minValue3)),
			list[i + 3]
		)
		v8[list[i + 3]] = (v8[list[i + 3]] or 0) + 1
	end

	local v9 = 0
	local pal = 0

	for k, v10 in v8 do
		if not (v9 < v10) then
			continue
		end

		pal = k
		v9 = v10
	end

	local v10 = {}
	local greedy = VoxelCore.greedy(buf, v5, v6, v7, buffer.create(v5 * v6 * v7), v10)

	if small then
		if voxels <= 50 then
			small = math.max(v5, v6, v7) <= 7
		else
			small = false
		end
	end

	local center = v + Vector3.new(minValue + v5 * 0.5, minValue2 + v6 * 0.5, minValue3 + v7 * 0.5) * VOXEL_SIZE

	local shadow = not small and Detail.castsShadowPart(Vector3.new(v5, v6, v7) * VOXEL_SIZE, Detail.distance(center))
	local parts = table.create(greedy)
	local cframes = table.create(greedy)
	local v11 = table.create(greedy)

	for i = 0, greedy - 1 do
		local v12 = i * 7
		local v13 = minValue + v10[v12 + 1]
		local v14 = minValue2 + v10[v12 + 2]
		local v15 = minValue3 + v10[v12 + 3]
		local v16 = v10[v12 + 4]
		local v17 = v10[v12 + 5]
		local v18 = v10[v12 + 6]
		local v19 = Palette[v10[v12 + 7]]
		local v20 = acquire()

		local v21 = v4[v20]

		if v21 == nil then
			v21 = { size = Vector3.new(0, 0, 0), transparency = -1, parent = voxelLoose }
			v4[v20] = v21
		end

		assert(v21)
		local vector3 = Vector3.new(v16 * VOXEL_SIZE, v17 * VOXEL_SIZE, v18 * VOXEL_SIZE)

		if v21.size ~= vector3 then
			v21.size = vector3
			v20.Size = vector3
		end

		if v21.color ~= v19.color then
			v21.color = v19.color
			v20.Color = v19.color
		end

		if v21.material ~= v19.material then
			v21.material = v19.material
			v20.Material = v19.material
		end

		if v21.variant ~= v19.variant then
			v21.variant = v19.variant
			v20.MaterialVariant = v19.variant
		end

		if v21.transparency ~= v19.transparency then
			v21.transparency = v19.transparency
			v20.Transparency = v19.transparency
		end

		local v22 = shadow and v19.transparency == 0

		if v21.cast ~= v22 then
			v21.cast = v22
			v20.CastShadow = v22
		end

		local cframe2 = CFrame.new(v + Vector3.new(v13 + v16 * 0.5, v14 + v17 * 0.5, v15 + v18 * 0.5) * VOXEL_SIZE - center)
		parts[i + 1] = v20
		cframes[i + 1] = cframe2
		v11[i + 1] = CFrame.new(center) * cframe2

		if not (parent and v21.parent ~= parent) then
			continue
		end

		v21.parent = parent
		v20.Parent = parent
	end

	workspace:BulkMoveTo(parts, v11, Enum.BulkMoveMode.FireCFrameChanged)
	return {
		parts = parts,
		offsets = cframes,
		center = center,
		half = Vector3.new(v5, v6, v7) * (VOXEL_SIZE * 0.5),
		pal = pal,
		voxels = voxels,
		small = small,
		solid = false,
		shadow = shadow
	}
end

local function setSolid(piece, flag2: boolean) -- 2 equivalent calls inferred from this helper
	if piece.small or piece.solid == flag2 then
		return
	end

	piece.solid = flag2

	for _, part in piece.parts do
		part.CanCollide = flag2
		part.CanQuery = flag2
	end

	WorldRay.setQuery(piece.parts, flag2)
end

function LooseChunks:free()
	if self.solid then
		WorldRay.setQuery(self.parts, false)
	end

	local v5 = table.create(#self.parts, cframe)
	workspace:BulkMoveTo(self.parts, v5, Enum.BulkMoveMode.FireCFrameChanged)
	local cap = Quality.cap(2048)
	local solid = self.solid

	for _, part in self.parts do
		local v6 = v4[part]

		if #v2 < cap then
			if solid then
				part.CanCollide = false
				part.CanQuery = false
			end

			if v6.cast ~= false then
				v6.cast = false
				part.CastShadow = false
			end

			if v6.parent ~= voxelLoose then
				v6.parent = voxelLoose
				part.Parent = voxelLoose
			end

			table.insert(v2, part)
		else
			v4[part] = nil
			part:Destroy()
		end
	end

	table.clear(self.parts)
	self.solid = false
end

local function retire(p: number) -- 3 equivalent calls inferred from this helper
	local v5 = v3[p]
	v3[p] = v3[#v3]
	v3[#v3] = nil
	LooseChunks.free(v5.piece)
end

local function oldest()
	local v5 = false
	local v6 = 1e999
	local v7 = 1

	for k, v8 in v3 do
		local flag2 = not v8.awake

		if not (flag2 and not v5 or flag2 == v5 and v8.born < v6) then
			continue
		end

		v6 = v8.born
		v7 = k
		v5 = flag2
	end

	return v7
end

local function chunkCap() -- 2 equivalent calls inferred from this helper
	local cap = Quality.cap(120)

	if Quality.potato or Quality.mobile then
		return (math.min(cap, Quality.LOOSE_CHUNKS))
	end

	return cap
end

local function skipSmall(list)
	if #list // 4 > 50 then
		return false
	end

	local minValue = 1e999
	local minValue2 = 1e999
	local minValue3 = 1e999
	local maxValue = -1e999
	local maxValue2 = -1e999
	local maxValue3 = -1e999

	for i = 1, #list, 4 do
		local item = list[i]
		local item2 = list[i + 1]
		local item3 = list[i + 2]
		minValue = math.min(minValue, item)
		minValue2 = math.min(minValue2, item2)
		minValue3 = math.min(minValue3, item3)
		maxValue = math.max(maxValue, item)
		maxValue2 = math.max(maxValue2, item2)
		maxValue3 = math.max(maxValue3, item3)
	end

	if math.max(maxValue - minValue, maxValue2 - minValue2, maxValue3 - minValue3) + 1 > 7 then
		return false
	end

	local v5 = v + Vector3.new(minValue + maxValue + 1, minValue2 + maxValue2 + 1, minValue3 + maxValue3 + 1) * (VOXEL_SIZE * 0.5)
	return Quality.detail(v5) <= 0 or Quality.mobile and math.random() > 0.5
end

local v5 = {}
local v6 = 1
local v7 = 0
local v8 = 0

local function partBudget() -- 1 equivalent call inferred from this helper
	return (math.max(16, Quality.cap(100)))
end

local function make(data, p: number)
	local lastTime = os.clock()
	flag = true
	local piece = LooseChunks.build(data.cells, true)
	local rot = CFrame.identity
	local cf = data.cf
	local corner = data.corner

	if cf and corner then
		rot = cf.Rotation
		piece.center = cf:PointToWorldSpace(piece.center - v + corner)
	end

	local v9 = data.v
	local w = data.w

	if p > 0 then
		p = math.min(p, 0.3)
		local vector3 = Vector3.new(0, -Gravity, 0)
		piece.center += v9 * p + vector3 * (p * 0.5 * p)
		v9 += vector3 * p
		local magnitude = w.Magnitude

		if magnitude > 0.001 then
			rot = CFrame.fromAxisAngle(w / magnitude, magnitude * p) * rot
		end
	end

	if cf or p > 0 then
		local v10 = table.create(#piece.parts)
		local v11 = CFrame.new(piece.center) * rot

		for k, offset in piece.offsets do
			v10[k] = v11 * offset
		end

		workspace:BulkMoveTo(piece.parts, v10, Enum.BulkMoveMode.FireCFrameChanged)
	end

	v7 -= #piece.parts
	local half = piece.half
	local now = os.clock()
	local v10 = {
		piece = piece,
		rot = rot,
		v = v9,
		w = w,
		radius = math.max(math.min(half.X, half.Y, half.Z), VOXEL_SIZE * 0.5),
		awake = true,
		lastSound = now,
		expires = now + (piece.small and 6 or 45),
		quiet = data.quiet == true and piece.small,
		pose = nil,
		drawnAt = piece.center,
		drawn = nil,
		born = now,
		still = 0,
		wokeAt = now,
		contactAt = -1e999
	}
	table.insert(v3, v10)

	if not data.quiet then
		VoxelSound.breakApart(piece.pal, piece.voxels, piece.center, 1)
	end

	local v11 = chunkCap() -- inferred equivalent call

	while v11 < #v3 do
		retire(oldest()) -- inferred equivalent call
	end

	v8 -= os.clock() - lastTime
end

local function request(p) -- 2 equivalent calls inferred from this helper
	if v6 > #v5 and v7 > 0 and v8 > 0 then
		make(p, 0)
	else
		table.insert(v5, p)
	end
end

function LooseChunks.spawn(cells, vector3: Vector3, vector3_2: Vector3, quiet: boolean?)
	if #cells < 4 or skipSmall(cells) then
		return
	end

	request({ -- inferred equivalent call
		cells = cells,
		v = vector3,
		w = vector3_2,
		quiet = quiet,
		t0 = os.clock()
	})
end

function LooseChunks.spawnAt(cells, cf: CFrame, corner: Vector3, vector3: Vector3, vector3_2: Vector3, quiet: boolean?)
	if #cells < 4 then
		return
	end

	request({ -- inferred equivalent call
		cells = cells,
		cf = cf,
		corner = corner,
		v = vector3,
		w = vector3_2,
		quiet = quiet,
		t0 = os.clock()
	})
end

function LooseChunks.cap()
	return chunkCap() -- inferred equivalent call
end

function LooseChunks.push(vector3: Vector3, p: number)
	for _, v9 in v3 do
		local blastVelocity = WorldConfig.blastVelocity(vector3, p, v9.piece.center)

		if not (blastVelocity.Magnitude > 0) then
			continue
		end

		v9.v += blastVelocity

		if not v9.awake then
			local now = os.clock()
			v9.awake = true
			v9.still = 0
			v9.wokeAt = now
		end

		local piece = v9.piece

		if piece.small or piece.solid == false then
			continue
		end

		piece.solid = false

		for _, part in piece.parts do
			part.CanCollide = false
			part.CanQuery = false
		end

		WorldRay.setQuery(piece.parts, false)
	end
end

function LooseChunks.kick(vector3: Vector3, vector3_2: Vector3, flag2: boolean?)
	local HAMMER_SWING_SPEED

	if flag2 then
		HAMMER_SWING_SPEED = WorldConfig.HAMMER_SWING_SPEED
	end

	local HAMMER_SWING_BOX

	if flag2 then
		HAMMER_SWING_BOX = WorldConfig.HAMMER_SWING_BOX
	end

	local v9

	if flag2 then
		v9 = WorldConfig.HAMMER_SWING_SPIN
	else
		v9 = WorldConfig.HAMMER_KICK_SPIN
	end

	for _, v10 in v3 do
		local hammerKick, v11 = WorldConfig.hammerKick(
			vector3,
			vector3_2,
			v10.piece.center,
			v10.piece.half * 2,
			v10.v,
			HAMMER_SWING_SPEED,
			HAMMER_SWING_BOX
		)

		if not (hammerKick.Magnitude > 0) then
			continue
		end

		local v12 = v10.w + v11

		if v9 < v12.Magnitude then
			v12 = v12.Unit * v9
		end

		v10.v += hammerKick
		v10.w = v12

		if not v10.awake then
			local now = os.clock()
			v10.awake = true
			v10.still = 0
			v10.wokeAt = now
		end

		local piece = v10.piece

		if piece.small or piece.solid == false then
			continue
		end

		piece.solid = false

		for _, part in piece.parts do
			part.CanCollide = false
			part.CanQuery = false
		end

		WorldRay.setQuery(piece.parts, false)
	end
end

function LooseChunks.count()
	return #v3
end

function LooseChunks.clear()
	table.clear(v5)
	v6 = 1

	for i = #v3, 1, -1 do
		retire(i) -- inferred equivalent call
	end
end

local function squared(rot: CFrame)
	local function snap(vector3: Vector3)
		local x = math.abs(vector3.X)
		local y = math.abs(vector3.Y)
		local z = math.abs(vector3.Z)

		if y <= x and z <= x then
			return (Vector3.new(math.sign(vector3.X), 0, 0))
		end

		if z <= y then
			return (Vector3.new(0, math.sign(vector3.Y), 0))
		end

		return (Vector3.new(0, 0, (math.sign(vector3.Z))))
	end

	local vector = snap(rot.XVector)
	local v9 = snap(rot.YVector)

	if math.abs((vector:Dot(v9))) > 0.5 then
		v9 = snap(rot.YVector - vector * rot.YVector:Dot(vector))
	end

	return CFrame.fromMatrix(Vector3.new(0, 0, 0), vector, v9)
end

local v9 = {}
local v10 = {}

RunService.Heartbeat:Connect(Detail.timed("loose", function(p)
	local now = os.clock()
	v7 = partBudget() -- inferred equivalent call
	v8 = math.max((Detail.low and 0.0025 or 0.004) - LooseChunks.spent, 0.0005)
	LooseChunks.spent = 0
	debug.profilebegin("LC.spawn")

	while v6 <= #v5 and v7 > 0 and v8 > 0 do
		local v11 = v5[v6]
		v5[v6] = nil
		v6 += 1
		make(v11, now - v11.t0)
	end

	v7 = 0
	v8 = 0
	debug.profileend()

	if v6 > #v5 then
		table.clear(v5)
		v6 = 1
		local cap = Quality.cap(320)

		for _ = 1, 12 do
			if cap <= #v2 then
				break
			end

			local part = Instance.new("Part")
			part.Anchored = true
			part.CanTouch = false
			part.CanCollide = false
			part.CanQuery = false
			part.CastShadow = false
			part.TopSurface = Enum.SurfaceType.Smooth
			part.BottomSurface = Enum.SurfaceType.Smooth
			part.CFrame = cframe
			part.Parent = voxelLoose
			table.insert(v2, part)
		end
	end

	local v11 = 1

	while v11 <= #v3 do
		local v12 = v3[v11]

		if v12.expires < now or v12.awake and now - v12.wokeAt > 5 and now - v12.contactAt > 0.5 then
			retire(v11) -- inferred equivalent call
		else
			v11 += 1
		end
	end

	if #v3 == 0 then
		return
	end

	if flag then
		refreshFilter()
	end

	local v12 = math.min(p, 1 / 30)
	local vector3 = Vector3.new(0, -Gravity * v12, 0)

	local v13 = 2 * Gravity * v12
	local v14 = 1 / (WorldConfig.METER * WorldConfig.speedScale())

	debug.profilebegin("LC.sim")
	local count = 0

	for _, v15 in v3 do
		if not v15.awake then
			continue
		end

		local piece = v15.piece
		local slideN = v15.slideN

		if slideN and now < v15.slideUntil then
			v15.v += vector3
			local v16 = -v15.v:Dot(slideN)

			if v16 > 0 then
				v15.v = (v15.v + slideN * v16) * 0.55
				v15.w *= 0.6
			end

			piece.center += v15.v * v12
			v15.contactAt = now
			v15.still = 0

			if v15.v.Magnitude < 1.2 or now - v15.wokeAt > 5 then
				v15.slideN = nil
			end
		else
			v15.slideN = nil
			v15.v += vector3
			local v16 = v15.v * v12
			local magnitude = v16.Magnitude
			local v17, slideN2

			if magnitude > 0.0001 then
				v17, slideN2 = WorldRay.cast(
					piece.center,
					v16 * ((magnitude + v15.radius) / magnitude),
					raycastParams,
					false
				)
			end

			if v17 and slideN2 then
				v15.contactAt = now

				local v18 = -v15.v:Dot(slideN2)
				piece.center = v17 + slideN2 * v15.radius

				if v18 > 0 then
					v15.v = (v15.v + slideN2 * v18) * 0.55 + slideN2 * (not (v13 < v18) and 0 or v18 * 0.25)
					v15.w *= 0.6
					local v19 = v18 * v14

					if v19 > 1 and now - v15.lastSound > 0.12 and not v15.quiet then
						v15.lastSound = now
						VoxelSound.hit(piece.pal, piece.voxels, piece.center, (math.clamp((v19 - 1) / 6, 0.05, 1)))
					end
				end

				if slideN2.Y > 0.7 and v15.v.Magnitude < 1.2 then
					v15.rot = squared(v15.rot)
					local vectorToObjectSpace = v15.rot:VectorToObjectSpace(Vector3.new(0, 1, 0))
					local half = piece.half
					local v19 = math.abs(vectorToObjectSpace.X) * half.X + math.abs(vectorToObjectSpace.Y) * half.Y + math.abs(vectorToObjectSpace.Z) * half.Z
					piece.center = Vector3.new(piece.center.X, v17.Y + v19, piece.center.Z)
					v15.v = Vector3.new(0, 0, 0)
					v15.w = Vector3.new(0, 0, 0)
					v15.awake = false
					setSolid(piece, true) -- inferred equivalent call
				else
					v15.still = not (v15.v.Magnitude < 1.2) and 0 or v15.still + v12

					if v15.still >= 0.4 or now - v15.wokeAt > 5 then
						v15.v = Vector3.new(0, 0, 0)
						v15.w = Vector3.new(0, 0, 0)
						v15.awake = false
						setSolid(piece, true) -- inferred equivalent call
					elseif slideN2.Y > 0.7 then
						local magnitude2 = v15.v.Magnitude
						local v19 = (magnitude2 + Gravity * 0.15) * 0.15 + v15.radius

						if
							magnitude2 > 0.001
							and not WorldRay.cast(piece.center, v15.v * (v19 / magnitude2), raycastParams, false)
						then
							local slideUntil = now + 0.15
							v15.slideN = slideN2
							v15.slideUntil = slideUntil
						end
					end
				end
			else
				v15.still = 0
				piece.center += v16
			end
		end

		local magnitude = v15.w.Magnitude

		if magnitude > 0.001 then
			v15.rot = CFrame.fromAxisAngle(v15.w / magnitude, magnitude * v12) * v15.rot
		end

		local v16 = CFrame.new(piece.center) * v15.rot

		if v15.awake and not piece.shadow then
			v15.pose = v16
		else
			v15.pose = nil

			if not v15.awake or v16 ~= v15.drawn then
				v15.drawnAt = piece.center
				v15.drawn = v16

				for k, part in piece.parts do
					count += 1
					v9[count] = part
					v10[count] = v16 * piece.offsets[k]
				end
			end
		end
	end

	debug.profileend()

	if count > 0 then
		for i = count + 1, #v9 do
			v9[i] = nil
			v10[i] = nil
		end

		workspace:BulkMoveTo(v9, v10, Enum.BulkMoveMode.FireCFrameChanged)
	end
end))

local v11 = {}
local v12 = {}

local v13 = Vector3.new(0, 0, 0)
local v14 = Vector3.new(0, 0, 1)
local v15 = -1

local function outside(vector3: Vector3, p: number): boolean -- 2 equivalent calls inferred from this helper
	local vector = vector3 - v13
	local magnitude = vector.Magnitude
	return p < magnitude and vector:Dot(v14) + p < magnitude * v15
end

RunService:BindToRenderStep("VoxelLoose", Enum.RenderPriority.Last.Value, Detail.timed("loose", function()
	local flag2 = false

	for _, v16 in v3 do
		if v16.pose then
			flag2 = true
			break
		end
	end

	if flag2 then
		local currentCamera = workspace.CurrentCamera
		local cframe2 = currentCamera.CFrame
		local position = cframe2.Position
		local lookVector = cframe2.LookVector
		v13 = position
		v14 = lookVector
		local viewportSize = currentCamera.ViewportSize
		local v16 = viewportSize.X / math.max(viewportSize.Y, 1)
		v15 = math.cos((math.min(
			math.atan(math.tan(math.rad((math.max(currentCamera.FieldOfView, 80))) * 0.5) * math.sqrt(1 + v16 * v16)) + 0.5235987755982988,
			3.141592653589793
		)))
		local count = 0

		for _, v17 in v3 do
			local pose = v17.pose

			if not pose then
				continue
			end

			v17.pose = nil

			if pose == v17.drawn then
				continue
			end

			local piece = v17.piece
			local v18 = piece.half.Magnitude + 0.5

			if outside(piece.center, v18) and outside(v17.drawnAt, v18) then -- inferred equivalent call
				continue
			end

			v17.drawnAt = piece.center
			v17.drawn = pose

			for k, part in piece.parts do
				count += 1
				v11[count] = part
				v12[count] = pose * piece.offsets[k]
			end
		end

		for i = count + 1, #v11 do
			v11[i] = nil
			v12[i] = nil
		end

		if count > 0 then
			workspace:BulkMoveTo(v11, v12, Enum.BulkMoveMode.FireCFrameChanged)
		end
	elseif v11[1] then
		table.clear(v11)
		table.clear(v12)
	end
end))

return LooseChunks