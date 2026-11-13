local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local VoxelSound = require(Voxel:WaitForChild("VoxelSound"))
local Movement = require(Voxel:WaitForChild("Movement"))
local GroundHit = require(Voxel:WaitForChild("GroundHit"))
local WorldConfig = require(Voxel:WaitForChild("WorldConfig"))
local Materials = require(Voxel:WaitForChild("Materials"))
local VoxelCore = require(Voxel:WaitForChild("VoxelCore"))
local ClientWorld = require(Voxel:WaitForChild("ClientWorld"))
local remotes = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Remotes")

local meter = WorldConfig.METER

local v = (40 * WorldConfig.METER) ^ 2

local LocalPlayer = Players.LocalPlayer

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.IgnoreWater = true
local v2 = -1e999
local v3 = nil
local function refresh()
	local now = os.clock()

	if now - v2 < 2 then
		return
	end

	v2 = now
	local voxelWorlds = { workspace.Terrain }
	local voxelWorld = workspace:FindFirstChild("VoxelWorld")
	v3 = voxelWorld

	if voxelWorld then
		table.insert(voxelWorlds, voxelWorld)
	end

	raycastParams.FilterDescendantsInstances = voxelWorlds
end

local v4 = {
	[0] = "dirt",
	[1] = "grass",
	[2] = "gravel",
	[3] = "sand",
	[4] = "concrete"
}
local v5 = {
	[Enum.Material.Grass] = "grass",
	[Enum.Material.LeafyGrass] = "grass",
	[Enum.Material.Ground] = "dirt",
	[Enum.Material.Mud] = "dirt",
	[Enum.Material.Sand] = "sand",
	[Enum.Material.Rock] = "gravel",
	[Enum.Material.Slate] = "gravel",
	[Enum.Material.Pebble] = "gravel",
	[Enum.Material.Wood] = "wood",
	[Enum.Material.WoodPlanks] = "wood",
	[Enum.Material.Metal] = "metal",
	[Enum.Material.DiamondPlate] = "metal",
	[Enum.Material.CorrodedMetal] = "metal"
}

local v6 = { wood = "wood", metal = "metal", soil = "dirt" }

local function surfaceUnder(p)
	refresh()
	local raycastResult = workspace:Raycast(p.Position, Vector3.new(0, -7, 0), raycastParams)

	if not raycastResult then
		return nil, nil
	end

	if raycastResult.Instance == workspace.Terrain then
		local soil = GroundHit.soil(raycastResult.Position - raycastResult.Normal * 0.5)

		if soil ~= nil then
			local v7 = v4[soil]

			if not v7 then
				error("[BodyAudio] unknown soil class " .. tostring(soil))
			end

			return v7, raycastResult.Position
		end
	end

	local world = ClientWorld.world
	local v7 = v3

	if world and v7 and raycastResult.Instance:IsDescendantOf(v7) then
		local v8 = (raycastResult.Position - raycastResult.Normal * (WorldConfig.VOXEL_SIZE * 0.5) - WorldConfig.ORIGIN) / WorldConfig.VOXEL_SIZE
		local v9 = VoxelCore.get(world, math.floor(v8.X), math.floor(v8.Y), (math.floor(v8.Z)))

		if v9 ~= 0 then
			local v10 = Materials.Palette[v9]

			if not v10 then
				error("[BodyAudio] unknown palette id " .. v9)
			end

			return v6[v10.type.sound] or "concrete", raycastResult.Position
		end
	end

	return v5[raycastResult.Material] or "concrete", raycastResult.Position
end

local v7 = {
	travelled = 0,
	lastPos = nil,
	fall = 0,
	humanoid = nil,
	root = nil
}

local function ownStep(p: string, p2: number?) -- 3 equivalent calls inferred from this helper
	local root = v7.root

	if not root then
		return
	end

	local v8, v9 = surfaceUnder(root)

	if not v8 then
		return
	end

	VoxelSound.step(v9, v8, p, true, p2)
end

local function bindCharacter(instance)
	local humanoid = instance:WaitForChild("Humanoid")
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
	v7.humanoid = humanoid
	v7.root = humanoidRootPart
	v7.travelled = 0
	v7.lastPos = nil
	v7.fall = 0
	humanoid.StateChanged:Connect(function(_, p)
		if p == Enum.HumanoidStateType.Jumping then
			ownStep("jump") -- inferred equivalent call
		elseif p == Enum.HumanoidStateType.Landed then
			local fall = v7.fall
			v7.fall = 0

			if fall >= 22 then
				ownStep("land", (fall - 22) / 58) -- inferred equivalent call
			end

			v7.travelled = 0
		end
	end)
end

if LocalPlayer.Character then
	task.spawn(bindCharacter, LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(bindCharacter)

local function ownUpdate()
	local humanoid = v7.humanoid
	local root = v7.root

	if not humanoid or not root or not root.Parent or humanoid.Health <= 0 then
		v7.lastPos = nil
		return
	end

	local position = root.Position
	local lastPos = v7.lastPos
	v7.lastPos = position
	local assemblyLinearVelocity = root.AssemblyLinearVelocity
	local y = assemblyLinearVelocity.Y

	if humanoid.FloorMaterial == Enum.Material.Air then
		v7.fall = math.max(v7.fall, -y)
		return
	end

	if not lastPos or Movement.state.sliding then
		return
	end

	local magnitude = Vector3.new(position.X - lastPos.X, 0, position.Z - lastPos.Z).Magnitude
	local magnitude2 = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude

	if magnitude2 < 3 then
		v7.travelled = math.min(v7.travelled, 2.5)
		return
	end

	v7.travelled += magnitude
	local v8 = 5 + 0.14 * magnitude2

	if v8 <= v7.travelled then
		v7.travelled -= v8
		v7.travelled = math.min(v7.travelled, v8)
		ownStep(Movement.state.sprinting and "sprint" or "walk") -- inferred equivalent call
	end
end

local v8 = {}

local function otherUpdate(p, position: Vector3, now: number)
	local position2 = p.Position
	local v9 = v8[p]
	local v10 = position2 - position

	if v < v10.X * v10.X + v10.Y * v10.Y + v10.Z * v10.Z then
		v8[p] = nil
		return
	end

	if not v9 then
		v8[p] = { pos = position2, t = now, travelled = 0, airborne = false }
		return
	end

	local v11 = now - v9.t

	if v11 <= 0 then
		return
	end

	local magnitude = Vector3.new(position2.X - v9.pos.X, 0, position2.Z - v9.pos.Z).Magnitude
	local v12 = position2.Y - v9.pos.Y
	v9.pos = position2
	v9.t = now
	local v13 = magnitude / v11
	local v14 = v12 / v11

	if v14 < -22 then
		v9.airborne = true
	elseif v9.airborne and v14 > -4 then
		v9.airborne = false
		local v15, v16 = surfaceUnder(p)

		if v15 then
			VoxelSound.step(v16, v15, "land", false, 0.5)
		end

		v9.travelled = 0
	else
		if v13 < 3 then
			v9.travelled = math.min(v9.travelled, 2.5)
			return
		end

		v9.travelled += magnitude
		local v15 = 5 + 0.14 * v13

		if v15 <= v9.travelled then
			v9.travelled = math.min(v9.travelled - v15, v15)
			local v16, v17 = surfaceUnder(p)

			if v16 then
				VoxelSound.step(v17, v16, v13 > 20 and "sprint" or "walk", false)
			end
		end
	end
end

local object = setmetatable({}, { __mode = "k" })
local object2 = setmetatable({}, { __mode = "k" })
local function rootIn(instance)
	local v9 = object[instance]

	if v9 and v9.Parent == instance then
		return v9
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	object[instance] = humanoidRootPart
	return humanoidRootPart
end

local function humanoidIn(instance)
	local v9 = object2[instance]

	if v9 and v9.Parent == instance then
		return v9
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	object2[instance] = humanoid
	return humanoid
end

local v9 = { folder = nil, list = {}, conns = {} }
local function rigList()
	local botRigs = workspace:FindFirstChild("BotRigs")

	if botRigs == v9.folder then
		return v9.list
	end

	for _, conn in v9.conns do
		conn:Disconnect()
	end

	table.clear(v9.conns)
	v9.folder = botRigs
	v9.list = not botRigs and {} or botRigs:GetChildren()

	if botRigs then
		table.insert(v9.conns, botRigs.ChildAdded:Connect(function(child)
			if not table.find(v9.list, child) then
				table.insert(v9.list, child)
			end
		end))
		table.insert(v9.conns, botRigs.ChildRemoved:Connect(function(child)
			local list = v9.list
			local index = table.find(list, child)

			if index then
				list[index] = list[#list]
				list[#list] = nil
			end
		end))
	end

	return v9.list
end

local v10 = {}
local set = {}

for _, v11 in Players:GetPlayers() do
	if v11 ~= LocalPlayer then
		table.insert(v10, v11)
	end
end

Players.PlayerAdded:Connect(function(player)
	if player ~= LocalPlayer and not table.find(v10, player) then
		table.insert(v10, player)
	end
end)
Players.PlayerRemoving:Connect(function(player)
	local index = table.find(v10, player)

	if index then
		v10[index] = v10[#v10]
		v10[#v10] = nil
	end
end)

local v11 = 0
local function othersUpdate()
	local now = os.clock()

	if now - v11 < 0.05 then
		return
	end

	v11 = now
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local position = currentCamera.CFrame.Position
	table.clear(set)

	for _, v12 in v10 do
		local character = v12.Character

		if not (v12 ~= LocalPlayer and character) then
			continue
		end

		local v13 = object[character]

		if not v13 or v13.Parent ~= character then
			v13 = character:FindFirstChild("HumanoidRootPart")
			object[character] = v13
		end

		local v14 = object2[character]

		if not v14 or v14.Parent ~= character then
			v14 = character:FindFirstChildOfClass("Humanoid")
			object2[character] = v14
		end

		if not (v13 and v14 and v14.Health > 0) then
			continue
		end

		set[v13] = true
		otherUpdate(v13, position, now)
	end

	for _, v12 in rigList() do
		local v13 = object[v12]

		if not v13 or v13.Parent ~= v12 then
			v13 = v12:FindFirstChild("HumanoidRootPart")
			object[v12] = v13
		end

		local v14 = not v13 and Vector3.new(0, 0, 0) or v13.Position - position

		if not (v13 and v14.X * v14.X + v14.Y * v14.Y + v14.Z * v14.Z <= v and v12:GetAttribute("Alive") ~= false) then
			continue
		end

		set[v13] = true
		otherUpdate(v13, position, now)
	end

	for k in v8 do
		if not set[k] then
			v8[k] = nil
		end
	end
end

RunService.Heartbeat:Connect(function()
	ownUpdate()
	othersUpdate()
end)

local HitPredict = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("HitPredict"))
HitPredict.predicted:Connect(function(vector3: Vector3)
	VoxelSound.bodyHit(vector3, 0.8)
end)
HitPredict.confirmed:Connect(function(vector3: Vector3, _: number, flag: boolean, p: string, _: string?, flag2: boolean)
	if p ~= "blast" and typeof(vector3) == "Vector3" and (flag or not flag2) then
		VoxelSound.bodyHit(vector3, flag and 1 or 0.8)
	end
end)

remotes:WaitForChild("Damaged").OnClientEvent:Connect(function(_: Vector3?, p: number, p2: string?)
	if p2 ~= "blast" then
		VoxelSound.hurt((math.clamp(p / 40, 0, 1)))
	end
end)