--!native
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local parent = script.Parent
local VoxelCore = require(parent:WaitForChild("VoxelCore"))
local ClientWorld = require(parent:WaitForChild("ClientWorld"))
local GroundHeight = require(parent:WaitForChild("GroundHeight"))

local WorldRay = {}

local v = { BotRigs = true, VehicleHulls = true, Helicopters = true }

local v2 = {
	VoxelWorld = true,
	VoxelChips = true,
	VoxelFalling = true,
	DamageSmokeFX = true,
	VoxelFireFX = true,
	GroundFireFX = true,
	GroundMarks = true,
	VoxelImpactFX = true,
	VoxelAtmosphere = true,
	StrikeZones = true,
	LobbyGuide = true,
	SpawnRings = true,
	Airstrikes = true,
	Gunships = true,
	VoxelSoundVoices = true,
	BotGuns = true,
	VoxelLoose = true
}

local raycastParams = RaycastParams.new()
raycastParams.IncludeInstances = { workspace.Terrain }
raycastParams.IgnoreWater = true

local v3 = {}
local v4 = {}
local zes = {}
local v5 = {}
local v6 = {}
local count = 0
local v7 = {}
local v8 = {}
local count2 = 0
local v9 = {}
local v10 = {}
local v11 = {}
local v12 = {}
local v13 = {}

local function cellKey(p: number, p2: number, p3: number) -- 2 equivalent calls inferred from this helper
	return p + 4096 + (p3 + 4096) * 8192 + (p2 + 4096) * 67108864
end

local function insert(p, p2: number, p3: number, p4: number, p5: number, p6: number, list)
	local v14 = p6 + 6

	for i = (p3 - v14) // 16, (p3 + v14) // 16 do
		for j = (p4 - v14) // 16, (p4 + v14) // 16 do
			for k = (p5 - v14) // 16, (p5 + v14) // 16 do
				local v15 = cellKey(i, j, k) -- inferred equivalent call
				local v16 = p[v15]

				if v16 == nil then
					p[v15] = { p2 }

					if list then
						table.insert(list, v15)
					end
				else
					if list and v16[1] == nil then
						table.insert(list, v15)
					end

					table.insert(v16, p2)
				end
			end
		end
	end
end

local object = setmetatable({}, { __mode = "k" })

local v14 = 0

local function addModel(instance, now: number, flag: boolean)
	local x, y, z, v15

	if instance:IsA("Model") then
		local v16 = object[instance]
		local pivot = instance:GetPivot()

		if v16 == nil or now - v16.at > 1 then
			local boundingBox, v17 = instance:GetBoundingBox()

			if v16 == nil then
				v14 = (v14 + 1) % 8
				now -= v14 * 1 / 8
			end

			v16 = {
				offset = pivot:PointToObjectSpace(boundingBox.Position),
				radius = v17.Magnitude * 0.5,
				at = now
			}
			object[instance] = v16
		end

		assert(v16)
		local pointToWorldSpace = pivot:PointToWorldSpace(v16.offset)
		x = pointToWorldSpace.X
		y = pointToWorldSpace.Y
		z = pointToWorldSpace.Z
		v15 = v16.radius
	else
		if not instance:IsA("BasePart") then
			return
		end

		local position = instance.Position
		x = position.X
		y = position.Y
		z = position.Z
		v15 = instance.Size.Magnitude * 0.5
	end

	if v15 ~= v15 or v15 > 10000 then
		return
	end

	count += 1
	local v16 = count
	local v17 = count
	local v18 = count
	local v19 = count
	v3[count] = x
	v4[v16] = y
	zes[v17] = z
	v5[v18] = v15
	v6[v19] = flag
	insert(v7, count, x, y, z, v15, v8)
end

local count3 = 0
local v15 = -1
local function buildDynamic()
	debug.profilebegin("WR.dyn")
	v15 = count3

	count2 += 1

	if count2 % 1800 == 0 then
		table.clear(v7)
	else
		for _, v16 in v8 do
			table.clear(v7[v16])
		end
	end

	table.clear(v8)
	count = 0
	local now = os.clock()
	local localPlayer = Players.LocalPlayer

	for _, v16 in Players:GetPlayers() do
		local character = v16.Character

		if character and v16 ~= localPlayer then
			addModel(character, now, true)
		end
	end

	for childName in v do
		local child = workspace:FindFirstChild(childName)

		if not child then
			continue
		end

		for _, child2 in child:GetChildren() do
			addModel(child2, now, false)
		end
	end

	debug.profileend()
end

local v16 = {}
local v17 = {}
local v18 = {}
local v19 = 0
local function enlist(p) -- 3 equivalent calls inferred from this helper
	if v17[p] == nil then
		table.insert(v16, p)
		v17[p] = #v16
	end
end
local function delist(p) -- 3 equivalent calls inferred from this helper
	local v20 = v17[p]

	if v20 then
		local v21 = v16[#v16]
		v16[v20] = v21
		v17[v21] = v20
		v16[#v16] = nil
		v17[p] = nil
	end
end
local function track(part)
	if part:IsA("BasePart") and v18[part] == nil then
		v18[part] = part:GetPropertyChangedSignal("CanQuery"):Connect(function()
			if part.CanQuery then
				enlist(part) -- inferred equivalent call
			else
				delist(part) -- inferred equivalent call
			end
		end)
		v19 += 1

		if part.CanQuery then
			enlist(part) -- inferred equivalent call
		end
	end
end
local function untrack(p) -- 2 equivalent calls inferred from this helper
	local connection = v18[p]

	if connection then
		connection:Disconnect()
		v18[p] = nil
		v19 -= 1
		delist(p) -- inferred equivalent call
	end
end

function WorldRay.setQuery(items, flag: boolean)
	for _, item in items do
		if flag then
			if v17[item] == nil then
				enlist(item) -- inferred equivalent call
				v19 += 1
			end
		elseif v17[item] ~= nil then
			delist(item) -- inferred equivalent call
			v19 -= 1
		end
	end
end
local function isCharacter(model) -- 1 equivalent call inferred from this helper
	return model:IsA("Model") and Players:GetPlayerFromCharacter(model) ~= nil
end

local function watchRoot(folder)
	if
		folder == workspace.Terrain
		or folder == workspace.CurrentCamera
		or v2[folder.Name]
		or v[folder.Name]
		or isCharacter(folder) -- inferred equivalent call
	then
		return
	end

	track(folder)

	for _, descendant in folder:GetDescendants() do
		track(descendant)
	end

	folder.DescendantAdded:Connect(track)
	folder.DescendantRemoving:Connect(untrack)
end

for _, child in workspace:GetChildren() do
	watchRoot(child)
end

workspace.ChildAdded:Connect(function(child)
	task.defer(function()
		if child.Parent == workspace then
			watchRoot(child)
		end
	end)
end)
workspace.ChildRemoved:Connect(function(folder)
	untrack(folder) -- inferred equivalent call

	for _, descendant in folder:GetDescendants() do
		untrack(descendant) -- inferred equivalent call
	end
end)

local v20 = 1
local count4 = 0
local count5 = 0
local lastTime = -1e999
local v21 = false
local v22 = {}
local v23 = {}
local v24 = {}
local v25 = {}
local v26 = 0
local function scanStep()
	local count6 = #v16

	local v27 = math.max(1, (math.ceil(v19 / 400)))
	count4 += 1
	local v28 = v27 <= count4

	if not v28 then
		count6 = math.min(v20 + math.ceil(count6 / v27) - 1, count6)
	end

	for i = v20, count6 do
		local v29 = v16[i]
		local position = v29.Position

		if not (position.Y > -10000) then
			continue
		end

		count5 += 1
		local v30 = v22
		local v31 = count5
		local v32 = v23
		local v33 = count5
		local v34 = v24
		local v35 = count5
		local v36 = v25
		local v37 = count5
		local x = position.X
		local y = position.Y
		local z = position.Z
		local v38 = v29.Size.Magnitude * 0.5
		v30[v31] = x
		v32[v33] = y
		v34[v35] = z
		v36[v37] = v38
	end

	v20 = count6 + 1

	if v28 then
		v9, v22 = v22, v9
		v10, v23 = v23, v10
		v11, v24 = v24, v11
		v12, v25 = v25, v12
		local v29 = count5 == v26

		if v29 then
			for i = 1, count5 do
				if v9[i] ~= v22[i] or v10[i] ~= v23[i] or v11[i] ~= v24[i] or v12[i] ~= v25[i] then
					v29 = false
					break
				end
			end
		end

		if not v29 then
			table.clear(v13)

			for i = 1, count5 do
				insert(v13, i, v9[i], v10[i], v11[i], v12[i])
			end
		end

		for i = count5 + 1, #v9 do
			local v30 = v10
			local v31 = v11
			local v32 = v12
			v9[i] = nil
			v30[i] = nil
			v31[i] = nil
			v32[i] = nil
		end

		v26 = count5
		count5 = 0
		v20 = 1
		count4 = 0
		v21 = true
	end
end

RunService.PreSimulation:Connect(function()
	count3 += 1

	if os.clock() - lastTime <= 2 then
		debug.profilebegin("WR.scan")
		scanStep()
		debug.profileend()
	elseif v21 or v20 > 1 or count4 > 0 then
		v21 = false
		count5 = 0
		v20 = 1
		count4 = 0
	end
end)

local function near(p, p2, p3, p4, p5, p6, flag: boolean, origin: Vector3, magnitude: number): boolean
	local x = origin.X
	local y = origin.Y
	local z = origin.Z
	local v27 = p[cellKey(x // 16, y // 16, z // 16)] -- inferred equivalent call

	if v27 == nil then
		return false
	end

	for _, v28 in v27 do
		if not (p6 == nil or flag or not p6[v28]) then
			continue
		end

		local v29 = p2[v28] - x
		local v30 = p3[v28] - y
		local v31 = p4[v28] - z
		local v32 = p5[v28] + magnitude + 0.5

		if v29 * v29 + v30 * v30 + v31 * v31 < v32 * v32 then
			return true
		end
	end

	return false
end

local v27 = -1
local count6 = 0
function WorldRay.cast(origin: Vector3, direction: Vector3, raycastParams2, flag: boolean)
	local magnitude = direction.Magnitude
	local world = ClientWorld.world
	lastTime = os.clock()

	if v27 ~= count3 then
		v27 = count3
		count6 = 0
	end

	count6 += 1

	local v28 = world == nil or magnitude > 6 or (not v21 or count6 <= 16)

	if not v28 then
		if v15 ~= count3 then
			buildDynamic()
		end

		v28 = near(v7, v3, v4, zes, v5, v6, flag, origin, magnitude)
			or near(v13, v9, v10, v11, v12, nil, flag, origin, magnitude)
	end

	if v28 then
		local raycastResult = workspace:Raycast(origin, direction, raycastParams2)

		if raycastResult then
			return raycastResult.Position, raycastResult.Normal
		end

		return nil, nil
	else
		local v29 = nil
		local v30 = nil
		local v31 = 1e999
		local raycast, v32, v33, v34 = VoxelCore.raycast(world, origin, direction, magnitude)

		if raycast and v33 ~= 0 and v34 > 0 then
			v30 = v32
			v31 = v34
			v29 = raycast
		end

		local vector3 = origin + direction

		if math.min(origin.Y, vector3.Y) < math.min(
			GroundHeight.at(origin.X, origin.Z),
			GroundHeight.at(vector3.X, vector3.Z)
		) + 10 then
			local workspace = workspace

			if v29 then
				direction *= v31 / magnitude
			end

			local raycastResult = workspace:Raycast(origin, direction, raycastParams)

			if raycastResult and raycastResult.Distance < v31 then
				return raycastResult.Position, raycastResult.Normal
			end
		end

		return v29, v30
	end
end

return WorldRay