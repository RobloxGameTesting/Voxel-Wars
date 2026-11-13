local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local VoxelSound = require(Voxel:WaitForChild("VoxelSound"))
local AudioGraph = require(Voxel:WaitForChild("AudioGraph"))
local WorldConfig = require(Voxel:WaitForChild("WorldConfig"))
local Detail = require(Voxel:WaitForChild("Detail"))
local ClientWorld = require(Voxel:WaitForChild("ClientWorld"))

local meter = WorldConfig.METER

local v = { wind = true, gusts = true, room = true }

local v2 = {}

for k, spec in {
	wind = { id = 9114057128, gain = 2.2, speed = 1 },
	gusts = { id = 9114057104, gain = 1.6, speed = 0.94 },
	howl = { id = 9113286969, gain = 1.4, speed = 1 },
	birds = { id = 9118752742, gain = 0.9, speed = 1 },
	birdsFar = { id = 9112832297, gain = 0.8, speed = 1 },
	insects = { id = 9112762614, gain = 0.12, speed = 1 },
	presence = { id = 9112777807, gain = 1.6, speed = 1 },
	room = { id = 9114828616, gain = 1.5, speed = 1 }
} do
	assert(spec.speed <= 1, "[BattleAmbience] beds are never pitched up")
	local flat = AudioGraph.flat("Bed" .. k, false, nil, not v[k])
	AudioGraph.park(flat)
	local player = flat.player
	player.Asset = "rbxassetid://" .. spec.id
	player.Looping = true
	player.PlaybackSpeed = spec.speed
	player.Volume = 0
	v2[k] = { v = flat, spec = spec, level = 0, sent = 0 }
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.IgnoreWater = true

local v3 = {
	nearO = Vector3.new(0, 0, 0),
	nearDirty = true,
	nearVer = -1,
	farO = Vector3.new(0, 0, 0),
	farAt = -1e999,
	farDirty = true,
	settleUntil = 0
}
local function worldEdited()
	v3.nearDirty = true
	v3.settleUntil = math.max(v3.settleUntil, os.clock() + 3)
end
local function worldRebuilt() -- 1 equivalent call inferred from this helper
	v3.nearDirty = true
	v3.farDirty = true
	v3.settleUntil = math.max(v3.settleUntil, os.clock() + 12)
end
task.spawn(function()
	local remotes = Voxel:WaitForChild("Remotes")
	remotes:WaitForChild("VoxelEdits").OnClientEvent:Connect(worldEdited)
	remotes:WaitForChild("WorldReset").OnClientEvent:Connect(worldRebuilt)
end)

local v4 = { set = false, world = nil }
local function refreshFilter()
	local voxelWorld = workspace:FindFirstChild("VoxelWorld")

	if v4.set and voxelWorld == v4.world then
		return
	end

	v4.set = true
	v4.world = voxelWorld
	worldRebuilt() -- inferred equivalent call
	local voxelWorlds = { workspace.Terrain }

	if voxelWorld then
		table.insert(voxelWorlds, voxelWorld)
	end

	raycastParams.FilterDescendantsInstances = voxelWorlds
end

local vector3s = {}
local v5 = {
	gusts = 1,
	howl = 1,
	birdsFar = 1,
	presence = 1,
	insects = 2
}

for i = 0, 7 do
	local v6 = i / 8 * 3.141592653589793 * 2
	table.insert(vector3s, (Vector3.new(math.cos(v6), 0, (math.sin(v6)))))
end

local v6 = table.create(#vector3s, false)
local v7 = table.create(#vector3s, false)
local v8 = false
local v9 = 0
local v10 = 0
local v11 = 0
local v12 = 0.5
local v13 = 0

local function big(vector3: Vector3, vector3_2: Vector3, p: number, p2: number, raycastResult: RaycastResult): boolean
	local raycastResult2 = workspace:Raycast(vector3 + Vector3.new(0, p2, 0), vector3_2 * p, raycastParams)
	return raycastResult2 ~= nil
		and math.abs(raycastResult2.Distance - raycastResult.Distance) <= math.max(0.3 * raycastResult.Distance, 4)
end

local function publish(o: Vector3)
	local v14 = {}

	if not v8 then
		local v15 = 1e999
		local pos = nil
		local v16 = 0

		for k, v17 in v6 do
			if not v17 then
				continue
			end

			local magnitude = (v17 - o).Magnitude

			if not (magnitude < v15) then
				continue
			end

			v16 = k
			pos = v17
			v15 = magnitude
		end

		if pos then
			table.insert(v14, { pos = pos, kind = "near" })
			local v17 = 1e999
			local pos2 = nil

			for k, v18 in v6 do
				if not (v18 and vector3s[k]:Dot(vector3s[v16]) < -0.5) then
					continue
				end

				local magnitude = (v18 - o).Magnitude

				if not (magnitude < v17) then
					continue
				end

				pos2 = v18
				v17 = magnitude
			end

			if pos2 then
				table.insert(v14, { pos = pos2, kind = "near" })
			end
		end
	end

	local v15 = 1e999
	local pos = nil

	for _, v16 in v7 do
		if not v16 then
			continue
		end

		local magnitude = (v16 - o).Magnitude

		if not (magnitude < v15) then
			continue
		end

		pos = v16
		v15 = magnitude
	end

	if pos then
		table.insert(v14, { pos = pos, kind = "far" })
	end

	VoxelSound.setSurroundings(v8, v9, v14)
end

local v14 = 0
local v15 = {
	on = false,
	near = false,
	o = Vector3.new(0, 0, 0),
	i = 0,
	roof = false,
	height = 0,
	walls = 0,
	empty = 0
}
local function probe()
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local position = currentCamera.CFrame.Position
	v14 = 1 - v14
	local near = v14 == 1

	if near then
		refreshFilter()
		local boxVersion = ClientWorld.boxVersion

		if
			not v3.nearDirty
			and boxVersion == v3.nearVer
			and os.clock() >= v3.settleUntil
			and (position - v3.nearO).Magnitude < 2
		then
			return
		end

		v3.nearO = position
		v3.nearDirty = false
		v3.nearVer = boxVersion
	else
		local now = os.clock()

		if not v3.farDirty and (position - v3.farO).Magnitude < 12 and now - v3.farAt < 3 then
			return
		end

		v3.farO = position
		v3.farAt = now
		v3.farDirty = false
	end

	v15.on = true
	v15.near = near
	v15.o = position
	v15.i = 0

	if not v15.near then
		v15.empty = 0

		return
	end

	v15.roof = workspace:Raycast(position, Vector3.new(0, 40, 0), raycastParams) ~= nil
	local raycastResult = workspace:Raycast(position, Vector3.new(0, -250, 0), raycastParams)
	v15.height = (not raycastResult and 250 or raycastResult.Distance) / meter
	v15.walls = 0
end

local function probeStep()
	local o = v15.o

	for _ = 1, Detail.low and not v15.near and 1 or 2 do
		v15.i += 1
		local i = v15.i
		local v16 = vector3s[i]

		if v15.near then
			local raycastResult = workspace:Raycast(o, v16 * 24, raycastParams)
			v6[i] = false

			if raycastResult then
				v15.walls += 1

				if raycastResult.Distance >= 7.5 then
					local raycastResult2 = workspace:Raycast(o + Vector3.new(0, 7.5, 0), v16 * 24, raycastParams)
					local v17

					if raycastResult2 == nil then
						v17 = false
					else
						v17 = math.abs(raycastResult2.Distance - raycastResult.Distance) <= math.max(0.3 * raycastResult.Distance, 4)
					end

					if v17 then
						v6[i] = raycastResult.Position
					end
				end
			end
		else
			local raycastResult = workspace:Raycast(o, v16 * 400, raycastParams)
			v7[i] = false

			if raycastResult then
				if raycastResult.Distance > 24 then
					local raycastResult2 = workspace:Raycast(o + Vector3.new(0, 15, 0), v16 * 400, raycastParams)
					local v17

					if raycastResult2 == nil then
						v17 = false
					else
						v17 = math.abs(raycastResult2.Distance - raycastResult.Distance) <= math.max(0.3 * raycastResult.Distance, 4)
					end

					if v17 then
						v7[i] = raycastResult.Position
					end
				end
			else
				v15.empty += 1
			end
		end

		if i == #vector3s then
			v15.on = false

			if v15.near then
				local roof = v15.roof
				local height = v15.height
				local walls = v15.walls
				v8 = roof
				v13 = height
				v9 = walls
				v10 = (v8 and 1 or 0) * (v9 * 0.65 / #vector3s + 0.35)
			else
				v12 = v15.empty / #vector3s
			end

			publish(o)
			break
		end
	end
end

local v16 = 1
local function setBed(p: string, p2: number, p3: number)
	local v17 = v2[p]
	local v18 = v5[p]
	local v19 = v18 and Detail.low and v18 <= Detail.strain and 0 or p2

	local v20 = 1 - math.exp(p3 * -0.6)
	v17.level += (v19 - v17.level) * v20
	local player = v17.v.player

	if player.IsPlaying then
		if v17.level < 0.003 then
			player:Stop()
			AudioGraph.park(v17.v)
		else
			local v21 = v17.level * v17.spec.gain

			if math.abs(v21 - v17.sent) > v17.sent * 0.01 then
				v17.sent = v21
				player.Volume = v21
			end
		end
	elseif v17.level > 0.006 then
		AudioGraph.route(v17.v, "amb")
		v17.sent = v17.level * v17.spec.gain
		player.Volume = v17.sent
		player.TimePosition = math.random() * 20
		player:Play()
	end
end

local function bedsStep(p: number)
	local now = os.clock()
	local v17 = (1 - v11) * 0.88 + 0.12
	local v18 = 1 - v9 / #vector3s
	local v19 = math.clamp(v12 * 0.45 + math.min(v13 / 20, 1) * 0.55, 0, 1)

	local v20 = math.clamp(0.5 + 0.9 * math.noise(now * 0.07, 3.1), 0, 1)
	local v21 = math.clamp(0.5 + 0.9 * math.noise(now * 0.05, 11.7), 0, 1)
	setBed("wind", (v18 * 0.35 + 0.45) * (v20 * 0.6 + 0.6) * v17, p)
	setBed("gusts", (v19 * 0.5 + 0.2) * v21 * v17, p)
	setBed("howl", v19 * v19 * (v20 * 0.5 + 0.5) * v17, p)
	AudioGraph.lowpass(v2.wind.v, v20 * 4300 * (v18 * 0.5 + 0.5) + 700)
	AudioGraph.lowpass(v2.gusts.v, v21 * 4300 + 700)

	local combat = VoxelSound.combat()
	local v22 = (1 - combat) ^ 2

	if v22 < v16 then
		v16 = v22
	else
		v16 = math.min(v22, v16 + p * 0.08)
	end

	setBed("birds", v16 * (1 - v19 * 0.5) * v17, p)
	setBed("birdsFar", (v16 * 0.7 + 0.3) * 0.6 * v17, p)
	setBed("insects", (1 - 0.7 * combat) * (1 - v19 * 0.6) * v17, p)
	setBed("presence", v17, p)
	setBed("room", v11, p)
	AudioGraph.lowpass(v2.room.v, 6000)
end

local total = 0

local v17 = 0

local total2 = 0
RunService.Heartbeat:Connect(function(dt)
	total += dt

	if total >= 0.25 and not v15.on then
		total = 0
		probe()
	end

	if v15.on then
		probeStep()
	end

	local v18 = 1 - math.exp(-2.5 * dt)
	local v19 = v11 + (v10 - v11) * v18

	if math.abs(v19 - v11) > 0.002 then
		v11 = v19

		if math.abs(v11 - v17) >= 0.02 then
			v17 = v11
			VoxelSound.setEnclosure(v11)
		end
	elseif v11 ~= v17 then
		v17 = v11
		VoxelSound.setEnclosure(v11)
	end

	total2 += dt

	if total2 >= 1 / 15 then
		bedsStep(math.min(total2, 0.5))
		total2 = 0
	end
end)