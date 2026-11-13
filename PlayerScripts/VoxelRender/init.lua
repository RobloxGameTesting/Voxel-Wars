--!native
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local VoxelCore = require(Voxel:WaitForChild("VoxelCore"))
local MapBuilder = require(Voxel:WaitForChild("MapBuilder"))
local WorldConfig = require(Voxel:WaitForChild("WorldConfig"))
local VoxelSound = require(Voxel:WaitForChild("VoxelSound"))
local ImpactFX = require(Voxel:WaitForChild("ImpactFX"))
local StrikePredict = require(Voxel:WaitForChild("StrikePredict"))
local GroundHit = require(Voxel:WaitForChild("GroundHit"))
local GroundHeight = require(Voxel:WaitForChild("GroundHeight"))
local CollisionBoxes = require(script:WaitForChild("CollisionBoxes"))
local LooseChunks = require(script:WaitForChild("LooseChunks"))
local FallingPieces = require(script:WaitForChild("FallingPieces"))
local DamageSmoke = require(script:WaitForChild("DamageSmoke"))
local Detail = require(Voxel:WaitForChild("Detail"))
local Remotes = Voxel:WaitForChild("Remotes")

local chunk = VoxelCore.CHUNK
local VOXEL_SIZE = WorldConfig.VOXEL_SIZE

local UserInputService = game:GetService("UserInputService")
local v = UserInputService.TouchEnabled and 0.02 or 0.08

local LocalPlayer = Players.LocalPlayer

local function nearRing(): number -- 3 equivalent calls inferred from this helper
	if LocalPlayer.Team == nil then
		return 120
	end

	return if Detail.low then 300 else 450
end

local v2 = {}

for _, attributeName in { "JoinCovered", "JoinSynced", "JoinBuilt" } do
	v2[attributeName] = LocalPlayer:GetAttribute(attributeName)
	LocalPlayer:GetAttributeChangedSignal(attributeName):Connect(function()
		v2[attributeName] = LocalPlayer:GetAttribute(attributeName)
	end)
end

local function stamp(attributeName: string) -- 8 equivalent calls inferred from this helper
	if LocalPlayer:GetAttribute(attributeName) == nil then
		local now = os.clock()
		LocalPlayer:SetAttribute(attributeName, now)

		if v2[attributeName] == nil then
			v2[attributeName] = now
		end
	end
end

local v3 = 0
local v4 = false

local v5 = nil
local v6 = { look = Vector3.new(0, 0, 1), angle = 0, wideK = 0 }

local v7 = 0

local v8 = { lastEditMs = 0, buildMs = 0, meshMs = 0, resetMs = 0 }

local v9 = false

local VoxelWorld = workspace:WaitForChild("VoxelWorld")
local world = VoxelCore.newWorld(VOXEL_SIZE, WorldConfig.ORIGIN, GroundHeight.row)

local folder = Instance.new("Folder")
folder.Name = "Boxes"
folder.Parent = VoxelWorld
local v10 = CollisionBoxes.new(world, folder)

local v11 = Voxel:GetAttribute("ShadowBatch") ~= false
Voxel:GetAttributeChangedSignal("ShadowBatch"):Connect(function()
	v11 = Voxel:GetAttribute("ShadowBatch") ~= false
end)

local v12 = {}
local function byDistDesc(p: number, p2: number): boolean
	return v12[p] > v12[p2]
end

local function sortFarFirst(list, vector3: Vector3)
	table.clear(v12)

	for _, item in list do
		v12[item] = v10.distance(item, vector3)
	end

	table.sort(list, byDistDesc)
end

local MeshWorker = script:WaitForChild("MeshWorker")
local v13 = {}
local v14 = {}

for i = 1, 4 do
	local actor = Instance.new("Actor")
	actor.Name = "MeshWorker" .. i
	local job = Instance.new("BindableEvent")
	job.Name = "Job"
	job.Parent = actor
	local done = Instance.new("BindableEvent")
	done.Name = "Done"
	done.Parent = actor
	local clone = MeshWorker:Clone()
	clone.Enabled = true
	clone.Parent = actor
	actor.Parent = script.Parent
	v13[i] = job
	v14[i] = done
end

local ClientWorld = require(Voxel:WaitForChild("ClientWorld"))
ClientWorld.world = world
local ClientWorld2 = require(Voxel:WaitForChild("ClientWorld"))
function ClientWorld2.boxCount()
	return v10.count()
end

local v15 = {}
local v16 = {}
local lastTime = 0
local v17 = 0
local v18 = Vector3.new(0, 0, 0)
local v19 = 0

local function viewPoint() -- 4 equivalent calls inferred from this helper
	local character = LocalPlayer.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if humanoidRootPart then
		return humanoidRootPart.Position
	end

	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		return currentCamera.Focus.Position
	end

	return Vector3.new(0, 0, 0)
end

local v20 = Vector3.new(0, 0, 1)
local v21 = 0
local function sortQueue(vector3: Vector3)
	v18 = vector3
	local currentCamera = workspace.CurrentCamera
	local v22

	if currentCamera then
		v22 = currentCamera.CFrame.Position
	else
		v22 = vector3
	end

	local v23 = not currentCamera and Vector3.new(0, 0, 1) or currentCamera.CFrame.LookVector
	v20 = v23
	local v24 = nearRing() + 60 -- inferred equivalent call

	local v25 = {}

	for _, v26 in v15 do
		local v27 = v10.distance(v26, vector3)

		if v24 < v27 then
			local vector = v10.centre(v26) - v22
			local magnitude = vector.Magnitude

			if magnitude > 1 and vector:Dot(v23) / magnitude >= 0.6427876096865394 then
				v27 = v24 + (v27 - v24) * 0.35
			end
		end

		v25[v26] = v27
	end

	table.sort(v15, function(a, b): boolean
		return v25[a] > v25[b]
	end)
end

local v22 = nil
local bindableEvent = Instance.new("BindableEvent")
task.spawn(function()
	stamp("JoinAsked") -- inferred equivalent call
	v22 = table.pack(Remotes:WaitForChild("VoxelSnapshot"):InvokeServer())
	bindableEvent:Fire()
end)

local function buildWorld()
	local lastTime2 = os.clock()
	MapBuilder.build(function(p, p2, p3, p4)
		VoxelCore.set(world, p, p2, p3, p4)
	end, function(p, p2, p3, p4, p5, p6, p7)
		VoxelCore.fill(world, p, p2, p3, p4, p5, p6, p7)
	end)
	v8.buildMs = (os.clock() - lastTime2) * 1000
	DamageSmoke.reset(world, MapBuilder.STRUCTURES)

	for _, v23 in world.dirty do
		v10.touch(v23.cx, v23.cy, v23.cz)
	end

	table.clear(world.dirty)
	table.clear(v15)
	table.clear(v16)

	for _, v23 in v10.queued() do
		table.insert(v15, v23)
		v16[v23] = true
	end

	sortQueue(viewPoint()) -- inferred equivalent call
	lastTime = os.clock()
	v17 = #v15
end

buildWorld()
stamp("JoinBuilt") -- inferred equivalent call

for _, v23 in v14 do
	local parent = v23.Parent

	while parent:GetAttribute("Ready") == nil do
		parent:GetAttributeChangedSignal("Ready"):Wait()
	end
end

v10.useWorkers(v13, v14)

local VoxelFire = require(Voxel:WaitForChild("VoxelFire"))

VoxelFire.onCell = v10.setBurning
VoxelFire.onClear = v10.clearBurning
VoxelFire.eachCell(function(p, p2, p3)
	v10.setBurning(p, p2, p3, 1)
end)

FallingPieces.init(world)

local v23 = {}
local v24 = {}
local v25 = Vector3.new(0, 0, 0)

local v26 = 0

local v27 = 80
local set = {}

local v28 = 1e999
local v29 = {}
local v30 = Vector3.new(0, 0, 0)
local v31 = {}

local v32 = 0

RunService.Heartbeat:Connect(Detail.timed("vr", function()
	local now = os.clock()
	local currentCamera = workspace.CurrentCamera
	local v33 = now - v3 > 0.2
	local v34

	if currentCamera == nil then
		v34 = false
	else
		v34 = currentCamera.FieldOfView < 50
	end

	if currentCamera and (v33 or v4 or v34) then
		local viewportSize = currentCamera.ViewportSize
		local v35 = currentCamera.FieldOfView

		if v35 < 50 then
			if v7 <= 0 then
				v7 = v35
			else
				local v36 = math.abs(v35 - v7)

				if v7 * 0.12 < v36 then
					v7 = v35
				end
			end

			v35 = v7
		else
			v7 = 0
		end

		local v36 = math.rad(v35) * 3 / math.max(viewportSize.Y, 1)
		local v37 = nil

		if currentCamera.FieldOfView >= 50 or v5 == nil then
			v5 = v36
		else
			local v38 = viewportSize.X / math.max(viewportSize.Y, 1)

			local angle = math.atan(math.tan(math.rad(v35) / 2) * math.sqrt(1 + v38 * v38)) + 0.05235987755982989
			local lookVector = currentCamera.CFrame.LookVector
			local wideK = v5
			v6.look = lookVector
			v6.angle = angle
			v6.wideK = wideK
			v37 = v6
		end

		debug.profilebegin("VR.cull")
		v4 = v10.cull(currentCamera.CFrame.Position, v36, v33, v37)
		debug.profileend()

		if v33 then
			v3 = now
			debug.profilebegin("VR.lod")
			v10.lod(currentCamera.CFrame.Position, Voxel:GetAttribute("FarLOD") ~= false)
			debug.profileend()

			if next(v23) ~= nil then
				local position = currentCamera.CFrame.Position

				for k in v23 do
					if not (not Detail.low or v10.distance(k, position) <= 325) then
						continue
					end

					v23[k] = nil

					if v29[k] then
						continue
					end

					v29[k] = true
					table.insert(v24, k)
				end

				sortFarFirst(v24, position)
			end
		end
	end

	local joinCovered = v2.JoinCovered == true
	local v35 = joinCovered and 48 or 12
	local v36 = joinCovered and 1e999 or 4
	local finished = v10.finished()

	if finished > 0 then
		local v37 = not joinCovered

		if v37 then
			v37 = v26 <= now and v11
		end

		if v32 == 0 then
			v32 = now
		end

		if
			not v37
			or v10.applying()
			or now - v32 >= 0.3
			or now - v32 >= 0.12 and v10.busy() == finished and #v24 == 0 and not v10.lodWaiting()
		then
			debug.profilebegin("VR.applyReady")
			local applyReady = v10.applyReady
			local v38

			if joinCovered then
				v38 = v
			elseif v37 then
				v38 = #v15 > 0 and not Detail.low and 0.016 or Detail.strain >= 2 and 0.004 or 0.008
			else
				v38 = Detail.low and 0.002 or 0.004
			end

			local v39 = applyReady(v38, v37)

			debug.profileend()
			v32 = not (v39 > 0) and 0 or now
		end
	else
		v32 = 0
	end

	v10.warm(joinCovered and 64 or 8)

	if #v24 > 0 and v10.busy() < v35 then
		debug.profilebegin("VR.unpark")
		local lastTime2 = os.clock()
		local v37 = if Detail.low then 0.002 else 0.004

		repeat
			local v38 = table.remove(v24)
			v29[v38] = nil
			v10.request(v38)
			v36 -= 1
		until #v24 == 0 or v35 <= v10.busy() or v36 <= 0 or v37 < os.clock() - lastTime2

		debug.profileend()
	end

	local v37 = v2.JoinSynced ~= nil

	local joinBuilt = v2.JoinBuilt
	local v38

	if v37 then
		v38 = v37
	elseif type(joinBuilt) == "number" then
		v38 = LocalPlayer.Team == nil or os.clock() - joinBuilt > 2
	else
		v38 = false
	end

	if #v15 == 0 then
		debug.profilebegin("VR.lodStep")
		local busy = v10.busy()
		v10.lodStep(0.002, (math.min(v35, busy + v36)))
		v36 -= math.max(v10.busy() - busy, 0)
		debug.profileend()

		if v38 and v10.busy() == 0 then
			stamp("JoinNear") -- inferred equivalent call

			if v37 then
				stamp("JoinMeshed") -- inferred equivalent call
			end
		end
	end

	if #v15 > 0 then
		local vector3 = viewPoint() -- inferred equivalent call

		if now - v19 > 0.25 then
			v19 = now

			if (vector3 - v18).Magnitude > 60 then
				sortQueue(vector3)
				v21 = now
			elseif
				currentCamera
				and now - v21 > 1
				and currentCamera.CFrame.LookVector:Dot(v20) < 0.8191520442889918
			then
				v21 = now
				sortQueue(v18)
			end
		end

		local lastTime2 = os.clock()
		local v39

		if joinCovered then
			v39 = v
		else
			v39 = v10.distance(v15[#v15], v18) < 120 and 0.03 or LocalPlayer.Team == nil and 0.012 or 0.006
		end

		local v40

		if LocalPlayer:GetAttribute("JoinNear") == nil then
			v40 = nearRing() + 60 -- inferred equivalent call
		else
			v40 = 120
		end

		repeat
			local v41 = v15[#v15]

			if v10.distance(v41, v18) < v40 then
				table.remove(v15)
				v16[v41] = nil
				v10.rebuildBlock(v41)
			else
				if not (v10.busy() < v35 and v36 > 0) then
					break
				end

				table.remove(v15)
				v16[v41] = nil
				v10.request(v41)
				v36 -= 1
			end
		until #v15 == 0 or v39 < os.clock() - lastTime2

		if LocalPlayer:GetAttribute("JoinMeshed") == nil then
			local v41 = math.floor((1 - #v15 / math.max(v17, 1)) * 50) / 50

			if LocalPlayer:GetAttribute("JoinProgress") ~= v41 then
				LocalPlayer:SetAttribute("JoinProgress", v41)
			end
		end

		if #v15 == 0 then
			v8.meshMs = (os.clock() - lastTime) * 1000

			if v38 then
				stamp("JoinNear") -- inferred equivalent call

				if v37 and v10.busy() == 0 then
					stamp("JoinMeshed") -- inferred equivalent call
				end
			end
		elseif
			v38
			and LocalPlayer.Character
			and (vector3 - v18).Magnitude <= 60
			and v10.distance(v15[#v15], v18) > nearRing() + 60 -- inferred equivalent call
		then
			stamp("JoinNear") -- inferred equivalent call
		end
	end

	local v39 = #v15 > 0

	if v39 ~= v9 then
		v9 = v39
		LocalPlayer:SetAttribute("WorldMeshing", v39 and true or nil)
	end
end))

local function spawnChunk(p, vector3: Vector3, vector3_2: Vector3, p2: number, flag: boolean)
	if p2 == 0 then
		LooseChunks.spawn(p, vector3, vector3_2, flag)
	else
		FallingPieces.spawn(p, vector3, p2, flag)
	end
end

local flag = false
local v33 = {}

local function inBox(vector3: Vector3, centre: Vector3, p: number): boolean -- 2 equivalent calls inferred from this helper
	local vector3_2 = vector3 - centre
	return math.abs(vector3_2.X) <= p and math.abs(vector3_2.Y) <= p and math.abs(vector3_2.Z) <= p
end

local function holdsView(p: number) -- 1 equivalent call inferred from this helper
	local centre = v10.centre(p)
	local v34 = v10.half() + 3
	return inBox(v25, centre, v34) or inBox(v30, centre, v34) -- inferred equivalent call
end

local function parkOrLater(p: number): boolean
	local distance = v10.distance(p, v25)

	if Detail.low and distance > 350 then
		if not v29[p] then
			v23[p] = true
		end

		return true
	else
		local distance2 = v10.distance(p, v30)
		local v34 = set[p] and 60 or v27
		local now = os.clock()
		local v35

		if v28 < now then
			v35 = not holdsView(p) and (Detail.low or not set[p]) -- inferred equivalent call
		else
			v35 = false
		end

		if not (v35 or v34 < distance and v34 < distance2) then
			return false
		end

		if v35 or distance <= 80 or distance2 <= 80 then
			v26 = os.clock() + 0.5
		end

		if not v29[p] then
			v29[p] = true
			table.insert(v24, p)
		end

		return true
	end
end

local function nearRank(p: number)
	return (math.min(v10.distance(p, v25), v10.distance(p, v30)))
end

local function flushNow()
	flag = false

	v25 = workspace.CurrentCamera.CFrame.Position
	v27 = Detail.low and 30 or 80
	v28 = os.clock() + (Detail.low and 0.0025 or 0.004)
	v30 = viewPoint() -- inferred equivalent call
	local v34 = #v24
	v10.flush(v16, parkOrLater, v31, nearRank)
	table.clear(v31)
	table.clear(set)

	if v34 < #v24 then
		sortFarFirst(v24, v25)
	end
end
RunService.PreSimulation:Connect(Detail.timed("vr", function()
	local lastTime2 = os.clock()

	if flag then
		debug.profilebegin("VR.flush")
		local lastTime3 = os.clock()
		flushNow()
		debug.profileend()
		v8.lastEditMs = (os.clock() - lastTime3) * 1000
	end

	if #v33 > 0 then
		local v34 = v33
		v33 = {}

		for _, v35 in v34 do
			v35()
		end
	end

	LooseChunks.spent = os.clock() - lastTime2
end))

local function commit(flag2: boolean)
	for k, v34 in world.dirty do
		v10.touch(v34.cx, v34.cy, v34.cz)

		if flag2 then
			set[v10.blockOf(v34.cx, v34.cy, v34.cz)] = true
		end

		if v34.count == 0 and world.chunks[k] == v34 then
			world.chunks[k] = nil
		end
	end

	table.clear(world.dirty)
	flag = true
end

local function applyEdits(buf: buffer)
	local EDIT_STRIDE = WorldConfig.EDIT_STRIDE

	for i = 0, buffer.len(buf) // EDIT_STRIDE - 1 do
		local unpackKey, v34, v35 = WorldConfig.unpackKey((buffer.readu32(buf, i * EDIT_STRIDE)))
		local v36 = buffer.readu8(buf, i * EDIT_STRIDE + 4)

		if v36 == 0 and VoxelCore.get(world, unpackKey, v34, v35) ~= 0 then
			DamageSmoke.removed(unpackKey, v34, v35)
		end

		VoxelCore.set(world, unpackKey, v34, v35, v36)
		v10.setStage(unpackKey, v34, v35, 0)
	end
end

local function applyStages(buf: buffer)
	for i = 0, buffer.len(buf) // 5 - 1 do
		local unpackKey, v34, v35 = WorldConfig.unpackKey((buffer.readu32(buf, i * 5)))
		local v36 = buffer.readu8(buf, i * 5 + 4)
		local v37 = VoxelCore.get(world, unpackKey, v34, v35) ~= 0
		v10.setStage(unpackKey, v34, v35, not v37 and 0 or v36)
	end

	flag = true
end

local function clearChunkCells(buf: buffer)
	local EDIT_STRIDE = WorldConfig.EDIT_STRIDE
	local v34 = buffer.len(buf)
	local total = 0

	while total < v34 do
		assert(total + 32 <= v34, "[VoxelRender] truncated chunk record")
		local v35 = buffer.readu32(buf, total)

		if v35 >= 2147483648 then
			v35 -= 2147483648
		end

		for i = 0, v35 - 1 do
			local unpackKey, v36, v37 = WorldConfig.unpackKey((buffer.readu32(buf, total + 32 + i * EDIT_STRIDE)))

			if VoxelCore.get(world, unpackKey, v36, v37) ~= 0 then
				DamageSmoke.removed(unpackKey, v36, v37)
			end

			VoxelCore.set(world, unpackKey, v36, v37, 0)
			v10.setStage(unpackKey, v36, v37, 0)
		end

		total += 32 + v35 * EDIT_STRIDE
	end
end

local function applyStream(buf: buffer, buf2: buffer?, buf3: buffer?)
	debug.profilebegin("VR.stream")
	local lastTime2 = os.clock()

	if buf2 then
		clearChunkCells(buf2)
	end

	applyEdits(buf)

	debug.profilebegin("VR.stream.commit")
	local v34

	if buf2 == nil then
		v34 = false
	else
		v34 = buffer.len(buf2) > 0
	end

	local v35

	if buf3 == nil then
		v35 = false
	else
		v35 = buffer.len(buf3) > 0
	end

	commit(v34 or v35)

	if v34 or v35 then
		table.insert(v33, function()
			if v35 then
				debug.profilebegin("VR.stream.land")
				FallingPieces.land(buf3)
				debug.profileend()
			end

			if v34 then
				debug.profilebegin("VR.stream.spawn")
				WorldConfig.decodeChunks(buf2, spawnChunk)
				debug.profileend()
			end
		end)
	end

	debug.profileend()
	v8.lastEditMs = (os.clock() - lastTime2) * 1000
	debug.profileend()
end

local MapSelect = require(Voxel:WaitForChild("MapSelect"))
local name = MapSelect.name

local v34 = {
	resetAt = -1e999,
	sent = 0,
	MAX = 12,
	small = 0,
	SMALL_MAX = 3
}
function v34.send(kind: string, amount: number, after: number, vector3: Vector3, options)
	if (kind == "box" or kind == "terrain") and amount < 2.5 then
		if v34.small >= v34.SMALL_MAX then
			return
		end

		v34.small += 1
	else
		if v34.sent >= v34.MAX then
			return
		end

		v34.sent += 1
	end

	local stuck = options or {}
	stuck.kind = kind
	stuck.amount = amount
	stuck.after = after
	local x = vector3.X
	local y = vector3.Y
	local z = vector3.Z
	stuck.x = x
	stuck.y = y
	stuck.z = z
	stuck.reset = math.min(os.clock() - v34.resetAt, 9999)
	stuck.map = MapSelect.name
	Remotes:WaitForChild("ReportClient"):FireServer({ stuck = stuck })
end

local count = 0
local function dropFrozen(p)
	for _, child in VoxelWorld:GetChildren() do
		if child ~= p and string.find(child.Name, "^FrozenSector") then
			child:Destroy()
		end
	end
end

local function swapBoxes(origin: Vector3, flag2: boolean)
	v10.freeze()

	if flag2 then
		count += 1
		folder.Name = "FrozenSector" .. count
		dropFrozen(folder)
	else
		folder:Destroy()
		dropFrozen(nil)
	end

	WorldConfig.setOrigin(origin)
	world.origin = origin
	folder = Instance.new("Folder")
	folder.Name = "Boxes"
	folder.Parent = VoxelWorld
	v10 = CollisionBoxes.new(world, folder)
	v10.useWorkers(v13, v14)
	local setBurning = v10.setBurning
	local clearBurning = v10.clearBurning
	VoxelFire.onCell = setBurning
	VoxelFire.onClear = clearBurning
end
local function resetWorld(origin: Vector3, flag2: boolean)
	local lastTime2 = os.clock()

	MapSelect.sync()
	LooseChunks.clear()
	table.clear(v23)
	table.clear(v24)
	table.clear(v29)
	table.clear(v33)
	table.clear(set)
	v10.cancel()
	local v35 = MapSelect.name ~= name
	name = MapSelect.name

	if not flag2 then
		dropFrozen(nil)
	end

	if origin == world.origin then
		if v35 then
			v10.clearBoxes()
		end
	else
		swapBoxes(origin, flag2 and not v35)
	end

	VoxelCore.clear(world)
	v10.clearStages()
	buildWorld()
	FallingPieces.clear()
	v10.prune()
	v8.resetMs = (os.clock() - lastTime2) * 1000
	v34.resetAt = os.clock()
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { VoxelWorld, workspace.Terrain }

local function floorMissing(x: number, p: number, z: number)
	local origin = world.origin
	local v35 = math.floor((x - origin.X) / VOXEL_SIZE)
	local v36 = math.floor((z - origin.Z) / VOXEL_SIZE)
	local v37 = false

	for i = math.floor((p - 1.5 - origin.Y) / VOXEL_SIZE), math.floor((p - origin.Y) / VOXEL_SIZE) do
		if VoxelCore.get(world, v35, i, v36) ~= 0 then
			v37 = true
			break
		end
	end

	if v37 and VoxelCore.get(world, v35, math.floor((p + 1 - origin.Y) / VOXEL_SIZE), v36) ~= 0 then
		return false
	end

	return v37 and workspace:Raycast(Vector3.new(x, p + 1, z), Vector3.new(0, -1.75, 0), raycastParams) == nil
end

local function groundMissing(x: number, p: number, z: number): boolean -- 2 equivalent calls inferred from this helper
	return math.abs(p - GroundHeight.at(x, z)) <= 10
		and workspace:Raycast(Vector3.new(x, p + 2, z), Vector3.new(0, -14, 0), raycastParams) == nil
end

local function spotMissing(position: Vector3, p: number): boolean
	if groundMissing(position.X, p, position.Z) then -- inferred equivalent call
		return true
	end

	for _, v35 in {
		Vector3.new(0, 0, 0),
		Vector3.new(1, 0, 0),
		-Vector3.new(1, 0, 0),
		Vector3.new(0, 0, 1),
		-Vector3.new(0, 0, 1)
	} do
		local v36 = position + v35 * 12

		if floorMissing(v36.X, p, v36.Z) then
			return true
		end
	end

	return false
end

local function holdFloor(instance)
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart", 10)
	local humanoid = instance:WaitForChild("Humanoid", 10)

	if not humanoidRootPart or not humanoid or LocalPlayer.Character ~= instance then
		return
	end

	local position = humanoidRootPart.Position
	local v35 = position.Y - humanoidRootPart.Size.Y * 0.5 - humanoid.HipHeight

	if not spotMissing(position, v35) then
		return
	end

	local spawnFloorHold = Instance.new("Part")
	spawnFloorHold.Name = "SpawnFloorHold"
	spawnFloorHold.Size = Vector3.new(30, 1, 30)
	spawnFloorHold.Anchored = true
	spawnFloorHold.CanQuery = false
	spawnFloorHold.CanTouch = false
	spawnFloorHold.CastShadow = false
	spawnFloorHold.Transparency = 1
	spawnFloorHold.CFrame = CFrame.new(position.X, v35 - 0.55, position.Z)
	spawnFloorHold.Parent = workspace
	sortQueue(position)
	local lastTime2 = os.clock()
	local flag2 = false
	local v36 = groundMissing(position.X, v35, position.Z) -- inferred equivalent call

	while LocalPlayer.Character == instance and humanoid.Health > 0 and spotMissing(position, v35) do
		local v37 = os.clock() - lastTime2

		if v37 > 20 and not flag2 then
			warn(string.format(
				"[VoxelRender] no floor at the spawn after %d s: %.0f, %.0f, %.0f",
				20,
				position.X,
				v35,
				position.Z
			))

			v34.send(v36 and "ground_late" or "floor_late", v37, 0, Vector3.new(position.X, v35, position.Z), nil)
			flag2 = true
		end

		if v37 > 120 then
			break
		end

		local position2 = humanoidRootPart.Position

		if math.abs(position2.X - position.X) > 15 or math.abs(position2.Z - position.Z) > 15 then
			break
		end

		task.wait(flag2 and 0.25 or 0.1)
	end

	spawnFloorHold:Destroy()

	if flag2 then
		v34.send("floor_freed", os.clock() - lastTime2, 0, Vector3.new(position.X, v35, position.Z), nil)
	else
		v34.send(
			v36 and "ground_wait" or "floor_wait",
			os.clock() - lastTime2,
			0,
			Vector3.new(position.X, v35, position.Z),
			nil
		)
	end
end
LocalPlayer.CharacterAdded:Connect(holdFloor)

if LocalPlayer.Character then
	task.spawn(holdFloor, LocalPlayer.Character)
end

local raycastParams2 = RaycastParams.new()
raycastParams2.FilterType = Enum.RaycastFilterType.Include
raycastParams2.FilterDescendantsInstances = { VoxelWorld, workspace.Terrain }
raycastParams2.IgnoreWater = true
raycastParams2.RespectCanCollide = true
local raycastParams3 = RaycastParams.new()
raycastParams3.FilterType = Enum.RaycastFilterType.Include
raycastParams3.FilterDescendantsInstances = { workspace.Terrain }
raycastParams3.IgnoreWater = true
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = { VoxelWorld }
overlapParams.RespectCanCollide = true

local function inTerrain(vector3: Vector3): boolean
	local vector3_2 = Vector3.new(
		math.floor(vector3.X / 4) * 4,
		math.floor(vector3.Y / 4) * 4,
		math.floor(vector3.Z / 4) * 4
	)
	local voxels, v35 = workspace.Terrain:ReadVoxels(Region3.new(vector3_2, vector3_2 + Vector3.new(4, 4, 4)), 4)
	local v36 = voxels[1][1][1]
	return v36 ~= Enum.Material.Air and v36 ~= Enum.Material.Water and v35[1][1][1] > 0.5
end

local function clearFrom(x: number, p: number, z: number)
	local v35 = p

	for _ = 1, 16 do
		local v36 = false

		for _, v37 in workspace:GetPartBoundsInBox(CFrame.new(x, p + 2.7, z), Vector3.new(1.2, 5, 1.2), overlapParams) do
			local v38 = v37.Position.Y + v37.ExtentsSize.Y * 0.5

			if not (p < v38) then
				continue
			end

			p = v38
			v36 = true
		end

		local raycastResult = workspace:Raycast(Vector3.new(x, p + 5.2, z), Vector3.new(0, -5.2, 0), raycastParams3)
		local raycastResult2

		if raycastResult then
			local y = raycastResult.Position.Y

			if p + 0.05 < y then
				p = raycastResult.Position.Y
				v36 = true
			elseif inTerrain(Vector3.new(x, p + 3, z)) then
				raycastResult2 = workspace:Raycast(
					Vector3.new(x, v35 + 40, z),
					Vector3.new(0, p - v35 - 40, 0),
					raycastParams3
				)

				if not raycastResult2 then
					return nil
				end

				p = raycastResult2.Position.Y
				v36 = true
			end

			if p - v35 > 40 then
				return nil
			end

			if not v36 then
				return p
			end
		else
			if inTerrain(Vector3.new(x, p + 3, z)) then
				raycastResult2 = workspace:Raycast(
					Vector3.new(x, v35 + 40, z),
					Vector3.new(0, p - v35 - 40, 0),
					raycastParams3
				)

				if not raycastResult2 then
					return nil
				end

				p = raycastResult2.Position.Y
				v36 = true
			end

			if p - v35 > 40 then
				return nil
			end

			if not v36 then
				return p
			end
		end
	end

	return nil
end

local function sideFree(cframe: CFrame, vector3: Vector3): boolean
	for _, v35 in {
		Vector3.new(1, 0, 0),
		-Vector3.new(1, 0, 0),
		Vector3.new(0, 0, 1),
		-Vector3.new(0, 0, 1)
	} do
		if #workspace:GetPartBoundsInBox(cframe + v35 * 1.5, vector3, overlapParams) == 0 then
			return true
		end
	end

	return false
end

local function stuck(humanoidRootPart, humanoid)
	local position = humanoidRootPart.Position
	local v35 = position.Y - humanoidRootPart.Size.Y * 0.5 - humanoid.HipHeight
	local v36 = position.Y + humanoidRootPart.Size.Y * 0.5 + 0.5
	local v37 = nil

	local raycastResult = workspace:Raycast(
		Vector3.new(position.X, v36, position.Z),
		Vector3.new(0, v35 - v36, 0),
		raycastParams2
	)
	local v38, v39, v40, MAP_BOUNDS

	-- [DEDUP] synthesized from 2 duplicated terminal regions
	local function deduplicatedTail2()
		if
			v35 < v40 - 6
			and position.X > MAP_BOUNDS.min.X
			and position.X < MAP_BOUNDS.max.X
			and position.Z > MAP_BOUNDS.min.Z
			and position.Z < MAP_BOUNDS.max.Z
			and not workspace:Raycast(position, Vector3.new(0, -300, 0), raycastParams2)
		then
			return "under_map", v40
		end

		return nil, nil
	end

	-- [DEDUP] synthesized from 2 duplicated terminal regions
	local function deduplicatedTail()
		if not v39 or v39 - v35 <= 1 then
			return nil, nil
		end

		if
			v37 == "box"
			and v39 - v35 > 6
			and sideFree(CFrame.new(position.X, (v35 + 1 + v36) * 0.5, position.Z), Vector3.new(1, v36 - v35 - 1, 1))
		then
			return nil, nil
		end

		return v37, v39
	end

	if raycastResult then
		local y = raycastResult.Position.Y

		if v35 + 1 < y then
			v37 = raycastResult.Instance == workspace.Terrain and "terrain" or "box"
			v38 = raycastResult.Position.Y

			if v37 then
				v39 = clearFrom(position.X, v38, position.Z)
				return deduplicatedTail()
			end

			v40 = GroundHeight.at(position.X, position.Z)
			MAP_BOUNDS = MapBuilder.MAP_BOUNDS
			return deduplicatedTail2()
		end
	end

	if #workspace:GetPartBoundsInBox(
		CFrame.new(position.X, (v35 + 1 + v36) * 0.5, position.Z),
		Vector3.new(1, v36 - v35 - 1, 1),
		overlapParams
	) > 0 then
		if sideFree(CFrame.new(position.X, (v35 + 1 + v36) * 0.5, position.Z), Vector3.new(1, v36 - v35 - 1, 1)) then
			return nil, nil
		end

		v38 = v35
		v37 = "in_box"
	elseif
		inTerrain(Vector3.new(position.X, v36, position.Z))
		and inTerrain(Vector3.new(position.X, v35 + 2, position.Z))
	then
		v38 = v35
		v37 = "in_terrain"
	else
		v38 = v35
	end

	if v37 then
		v39 = clearFrom(position.X, v38, position.Z)
		return deduplicatedTail()
	end

	v40 = GroundHeight.at(position.X, position.Z)
	MAP_BOUNDS = MapBuilder.MAP_BOUNDS
	return deduplicatedTail2()
end

local function watch(instance)
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart", 10)
	local humanoid = instance:WaitForChild("Humanoid", 10)

	if not humanoidRootPart or not humanoid or LocalPlayer.Character ~= instance then
		return
	end

	local lastTime2 = os.clock()
	local anchored = humanoidRootPart.Anchored
	local v35 = false

	while
		LocalPlayer.Character == instance
		and instance.Parent
		and humanoid.Health > 0
		and os.clock() - lastTime2 < 30
	do
		if not (humanoidRootPart.Anchored or humanoid.SeatPart or LocalPlayer:GetAttribute("Flying")) then
			local v36, v37 = stuck(humanoidRootPart, humanoid)

			if v36 and v37 then
				local v38 = humanoidRootPart.Position.Y - humanoidRootPart.Size.Y * 0.5 - humanoid.HipHeight
				local v39 = v37 - v38 + 0.1
				instance:PivotTo(instance:GetPivot() + Vector3.new(0, v39, 0))
				humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

				if v36 == "under_map" then
					task.spawn(holdFloor, instance)
				end

				if not v35 then
					local position = humanoidRootPart.Position
					warn(string.format(
						"[VoxelRender] stuck at the spawn (%s): lifted %.1f at %.0f, %.0f, %.0f",
						v36,
						v39,
						position.X,
						v38,
						position.Z
					))
					v34.send(v36, v39, os.clock() - lastTime2, Vector3.new(position.X, v38, position.Z), {
						ground = v37 - GroundHeight.at(position.X, position.Z),
						held = anchored
					})
					v35 = true
				end
			end
		end

		task.wait(0.15)
	end
end
LocalPlayer.CharacterAdded:Connect(watch)

if LocalPlayer.Character then
	task.spawn(watch, LocalPlayer.Character)
end

local v35 = -1
local flag2 = false
local v36 = {}

local function onEdits(buf: buffer, buf2: buffer, buf3: buffer, p: number) -- 2 equivalent calls inferred from this helper
	if p == v35 then
		applyStream(WorldConfig.unpackEdits(buf), WorldConfig.unpackBlob(buf2), buf3)
	end
end

local function onReset(p: number, origin: Vector3, flag3: boolean) -- 2 equivalent calls inferred from this helper
	local v37 = typeof(origin) == "Vector3" and type(flag3) == "boolean"
	assert(v37, "[VoxelRender] WorldReset without origin / shift")

	if v35 < p then
		v35 = p
		resetWorld(origin, flag3)
	end
end

local function onStages(buf: buffer, p: number) -- 2 equivalent calls inferred from this helper
	if p == v35 then
		applyStages(WorldConfig.unpackEdits(buf))
	end
end

Remotes:WaitForChild("VoxelEdits").OnClientEvent:Connect(function(buf: buffer, buf2: buffer, buf3: buffer, p: number)
	if flag2 then
		onEdits(buf, buf2, buf3, p) -- inferred equivalent call
	else
		table.insert(v36, function()
			onEdits(buf, buf2, buf3, p) -- inferred equivalent call
		end)
	end
end)
Remotes:WaitForChild("VoxelDamage").OnClientEvent:Connect(function(buf: buffer, p: number)
	if flag2 then
		onStages(buf, p) -- inferred equivalent call
	else
		table.insert(v36, function()
			onStages(buf, p) -- inferred equivalent call
		end)
	end
end)
Remotes:WaitForChild("WorldReset").OnClientEvent:Connect(function(p: number, origin: Vector3, flag3: boolean)
	if flag2 then
		onReset(p, origin, flag3) -- inferred equivalent call
	else
		table.insert(v36, function()
			onReset(p, origin, flag3) -- inferred equivalent call
		end)
	end
end)
task.spawn(function()
	if v22 == nil then
		bindableEvent.Event:Wait()
	end

	local v37 = v22
	local v38 = v37[1]
	local v39 = v37[2]
	local v40 = v37[3]
	local origin = v37[4]
	local v42 = typeof(v38) == "buffer" and typeof(v39) == "number" and typeof(v40) == "buffer"
	assert(v42, "[VoxelRender] bad world snapshot")
	assert(typeof(origin) == "Vector3", "[VoxelRender] world snapshot without origin")

	if origin ~= world.origin then
		resetWorld(origin, false)
	end

	local unpackSnapshot = WorldConfig.unpackSnapshot(v38)
	local unzip = WorldConfig.unzip(v40)
	v35 = v39
	applyEdits(unpackSnapshot)
	applyStages(unzip)

	for _, v43 in world.dirty do
		v10.touch(v43.cx, v43.cy, v43.cz)
	end

	table.clear(world.dirty)
	local count2 = 0

	for _, v43 in v10.queued() do
		if v16[v43] then
			continue
		end

		table.insert(v15, v43)
		v16[v43] = true
		count2 += 1
	end

	sortQueue(viewPoint()) -- inferred equivalent call
	v17 += count2
	flag = false
	LocalPlayer:SetAttribute("JoinSnapKB", (math.floor((buffer.len(v38) + buffer.len(v40)) / 1024 + 0.5)))
	LocalPlayer:SetAttribute(
		"JoinSnapRawKB",
		(math.floor((buffer.len(unpackSnapshot) + buffer.len(unzip)) / 1024 + 0.5))
	)
	stamp("JoinSynced") -- inferred equivalent call
	flag2 = true

	for _, v43 in v36 do
		v43()
	end

	table.clear(v36)
end)

local function pieceSize(vector3: Vector3)
	local v37 = (vector3 - world.origin) / VOXEL_SIZE
	local v38 = math.floor(v37.X) // chunk
	local v39 = math.floor(v37.Y) // chunk
	local v40 = math.floor(v37.Z) // chunk
	local chunk2 = world.chunks[VoxelCore.chunkKey(v38, v39, v40)]
	return if chunk2 then chunk2.count else 0
end

local ShotStream = require(ReplicatedStorage.Voxel:WaitForChild("ShotStream"))
Remotes:WaitForChild("Explosion").OnClientEvent:Connect(function(vector3: Vector3, p: number)
	local function blast() -- 1 equivalent call inferred from this helper
		LooseChunks.push(vector3, p)
		FallingPieces.blast(vector3, p)
	end

	if #v33 > 0 then
		table.insert(v33, blast)
		return
	end

	blast() -- inferred equivalent call
end)
ShotStream.onImpact(function(vector3: Vector3, vector3_2: Vector3, vector3_3: Vector3, p: number, p2: number, flag3: boolean, p3, _: number?, flag4: boolean?, flag5: boolean?)
	if flag5 then
		if math.abs(p2 - 0.4 * WorldConfig.METER) < 0.05 * WorldConfig.METER then
			VoxelSound.hammerBody(vector3, false, p3 == Players.LocalPlayer)
		end
	else
		local v37 = p2 < WorldConfig.METER * 0.3
		local kick = LooseChunks.kick
		local v38 = vector3 - vector3_2 * WorldConfig.HAMMER_DEPTH

		if v37 then
			vector3_3 *= 0.3
		end

		kick(v38, vector3_3, not v37)

		if v37 then
			if p3 ~= Players.LocalPlayer then
				VoxelSound.bulletHit(p, vector3, 0.8)
			end
		else
			local v39, v40

			if p3 == Players.LocalPlayer then
				v39, v40 = StrikePredict.match(vector3)
			else
				v39 = false
				v40 = false
			end

			if v39 then
				if flag3 and not (v40 or flag4) then
					VoxelSound.hammerBreak(p, vector3)
				end
			else
				VoxelSound.hammerStrike(p, vector3, flag3, flag4 == true)
			end
		end
	end
end)

StrikePredict.struck:Connect(function(vector3: Vector3, _: Vector3, _: Vector3, p: number, _: number, flag3: boolean, flag4: boolean)
	VoxelSound.hammerStrike(p, vector3, flag3, flag4)
end)

local random = Random.new()
ImpactFX.listen(function(vector3: Vector3, vector3_2: Vector3, flag3: boolean)
	if flag3 then
		local mixed = GroundHit.mix(vector3 - vector3_2 * 0.5, 0)

		if mixed then
			VoxelSound.bulletHit(GroundHit.pick(mixed, random), vector3, 1)
		end
	else
		local v37 = (vector3 - vector3_2 * (VOXEL_SIZE * 0.5) - world.origin) / VOXEL_SIZE
		local v38 = VoxelCore.get(world, math.floor(v37.X), math.floor(v37.Y), (math.floor(v37.Z)))

		if v38 ~= 0 then
			VoxelSound.bulletHit(v38, vector3, 1)
		end
	end
end)

local voxelRenderHud = Instance.new("ScreenGui")
voxelRenderHud.Name = "VoxelRenderHud"
voxelRenderHud.ResetOnSpawn = false
voxelRenderHud.Enabled = false
local textLabel = Instance.new("TextLabel")
textLabel.BackgroundTransparency = 0.4
textLabel.BackgroundColor3 = Color3.new(0, 0, 0)
textLabel.TextColor3 = Color3.new(1, 1, 1)
textLabel.Font = Enum.Font.Code
textLabel.TextSize = 14
textLabel.TextXAlignment = Enum.TextXAlignment.Left
textLabel.AutomaticSize = Enum.AutomaticSize.XY
textLabel.Position = UDim2.fromOffset(8, 8)
textLabel.Parent = voxelRenderHud
voxelRenderHud.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

task.spawn(function()
	while true do
		local count2 = v10.count()
		local count3 = LooseChunks.count()
		local count4 = FallingPieces.count()
		local lastEditMs = v8.lastEditMs
		local buildMs = v8.buildMs
		local v38

		if #v15 > 0 then
			v38 = string.format("%d left", #v15)
		else
			v38 = string.format("%.0f ms", v8.meshMs)
		end

		textLabel.Text = string.format(
			" world boxes %d  loose chunks %d  falling %d  last edit %.2f ms  build %.0f ms  mesh %s ",
			count2,
			count3,
			count4,
			lastEditMs,
			buildMs,
			v38
		)

		task.wait(0.5)
	end
end)