local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToolTemplates = ReplicatedStorage:WaitForChild("ToolTemplates")

local parent = script.Parent
local VoxelCore = require(parent:WaitForChild("VoxelCore"))
local MolotovFlight = require(parent:WaitForChild("MolotovFlight"))
local ClientWorld = require(parent:WaitForChild("ClientWorld"))
local VoxelSound = require(parent:WaitForChild("VoxelSound"))
local Quality = require(parent:WaitForChild("Quality"))
local Detail = require(parent:WaitForChild("Detail"))
local remotes = parent:WaitForChild("Remotes")
assert(RunService:IsClient(), "[MolotovVisuals] client only")

local MolotovVisuals = {}

local v = MolotovFlight.MAX_FLIGHT + 1.5

local _ = { range = 9, brightness = 1.4 }
local color = Color3.fromRGB(255, 142, 62)

local v2 = { 0.08, 0.22 }
local v3 = { 6, 16 }
local v4 = { 0.5, 0.9 }
local v5 = { Color3.fromRGB(58, 110, 54), Color3.fromRGB(96, 150, 88), Color3.fromRGB(150, 196, 140) }

local _ = { range = 45, brightness = 4 }
local color2 = Color3.fromRGB(255, 214, 112)
local color3 = Color3.fromRGB(230, 90, 30)
local v6 = Quality.mobile and 0 or 3
local v7 = Quality.mobile and 1 or 3

local voxelMolotovs = Instance.new("Folder")
voxelMolotovs.Name = "VoxelMolotovs"
voxelMolotovs.Parent = workspace

local Molotov = ToolTemplates:WaitForChild("Molotov", 10)
assert(Molotov, "[MolotovVisuals] ToolTemplates.Molotov is missing")
local Handle = Molotov:WaitForChild("Handle")

local function build()
	local clones = {}
	local offsets = {}
	local transparencies = {}
	local flames = {}

	for _, part in Molotov:GetChildren() do
		if not (part:IsA("BasePart") and part ~= Handle) then
			continue
		end

		local clone = part:Clone()

		for _, child in clone:GetChildren() do
			child:Destroy()
		end

		clone.Anchored = true
		clone.CanCollide = false
		clone.CanQuery = false
		clone.CanTouch = false
		clone.CastShadow = false
		clone.Parent = voxelMolotovs
		table.insert(clones, clone)
		table.insert(offsets, Handle.CFrame:ToObjectSpace(part.CFrame))
		table.insert(transparencies, part.Transparency)

		if part.Name == "Flame" then
			table.insert(flames, #clones)
		end
	end

	assert(#flames > 0, "[MolotovVisuals] the Molotov tool has no Flame parts")
	local pointLight = Instance.new("PointLight")
	pointLight.Color = color
	pointLight.Range = 9
	pointLight.Brightness = 1.4
	pointLight.Shadows = false
	pointLight.Parent = clones[flames[1]]
	return {
		parts = clones,
		offsets = offsets,
		flames = flames,
		alphas = transparencies,
		light = pointLight
	}
end

local v8 = {}
local function place(body, cframe: CFrame, now: number)
	table.clear(v8)

	for k, offset in body.offsets do
		v8[k] = cframe * offset
	end

	for k, flame in body.flames do
		local v9 = math.sin(now * (k * 4 + 21) + k * 1.7)
		v8[flame] = CFrame.new(v8[flame].Position + Vector3.new(0, v9 * 0.06 + 0.05, 0)) * CFrame.Angles(v9 * 0.3, now * 4 + k, 0)
	end

	workspace:BulkMoveTo(body.parts, v8, Enum.BulkMoveMode.FireCFrameChanged)

	if body.light.Enabled and not Detail.low then
		body.light.Brightness = 1.4 * (math.sin(now * 17) * 0.15 + 0.85)
	end
end

local function hideBody(p) -- 3 equivalent calls inferred from this helper
	for _, part in p.parts do
		part.Transparency = 1
	end

	p.light.Enabled = false
end

local cframe = CFrame.new(0, -10000, 0)

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.IgnoreWater = true
local v9 = nil
local function refreshParams()
	v9 = v9 or workspace:FindFirstChild("VehicleHulls")
	local filterDescendantsInstances

	if v9 then
		filterDescendantsInstances = { workspace.Terrain, v9 }
	else
		filterDescendantsInstances = { workspace.Terrain }
	end

	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
end
refreshParams()

local function cast(origin: Vector3, vector3: Vector3, p: number)
	local world = ClientWorld.world
	assert(world, "[MolotovVisuals] the client voxel world is not built")
	local raycast, v10, v11, v12 = VoxelCore.raycast(world, origin, vector3, p)
	local raycastResult = workspace:Raycast(origin, vector3 * p, raycastParams)

	if raycast and v10 and (not raycastResult or v12 <= raycastResult.Distance) then
		return raycast, v10, v12, v11
	end

	if not raycastResult then
		return nil, nil, 0, nil
	end

	local v13 = raycastResult.Material

	if v9 and raycastResult.Instance:IsDescendantOf(v9) then
		v13 = Enum.Material.Metal
	end

	return raycastResult.Position, raycastResult.Normal, raycastResult.Distance, v13
end

local v10 = {}

local v11 = {}
local function litBottles() -- 1 equivalent call inferred from this helper
	local count = 0

	for _, v12 in v10 do
		if v12.mine or not v12.body.light.Enabled then
			continue
		end

		count += 1
	end

	return count
end

local function takeBody(flag: boolean)
	local v12 = table.remove(v11) or build()

	for k, part in v12.parts do
		part.Transparency = v12.alphas[k]
	end

	local light = v12.light
	local enabled = not Quality.potato

	if enabled then
		if flag then
			enabled = flag
		else
			enabled = litBottles() < v6 -- inferred equivalent call
		end
	end

	light.Enabled = enabled
	return v12
end

local function giveBody(body) -- 1 equivalent call inferred from this helper
	hideBody(body) -- inferred equivalent call

	for _, part in body.parts do
		part.CFrame = cframe
	end

	table.insert(v11, body)
end

local function add(vector3: Vector3, vector3_2: Vector3, p: number, mine: boolean, id: number?)
	refreshParams()
	local state = MolotovFlight.new(vector3, vector3_2)
	local v12 = {
		id = id,
		mine = mine,
		state = state,
		t0 = os.clock() - p,
		body = takeBody(mine),
		rot = CFrame.Angles(math.random() * 6.28, math.random() * 6.28, 0),
		spin = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit * 8,
		hidden = false
	}

	if p > 0 and MolotovFlight.advance(state, p, cast) then
		v12.hidden = true
		hideBody(v12.body) -- inferred equivalent call
	else
		place(v12.body, CFrame.new(state.pos) * v12.rot, os.clock())
	end

	table.insert(v10, v12)
end

function MolotovVisuals.predict(vector3: Vector3, vector3_2: Vector3)
	add(vector3, vector3_2, 0, true, nil)
end

local function remove(i: number) -- 2 equivalent calls inferred from this helper
	giveBody(v10[i].body) -- inferred equivalent call
	table.remove(v10, i)
end

local v12 = {}
local v13 = {}

for _ = 1, 48 do
	local glass = Instance.new("Part")
	glass.Name = "Glass"
	glass.Anchored = true
	glass.CanCollide = false
	glass.CanQuery = false
	glass.CanTouch = false
	glass.CastShadow = false
	glass.Material = Enum.Material.Glass
	glass.Transparency = 1
	glass.CFrame = CFrame.new(0, -10000, 0)
	glass.Parent = voxelMolotovs
	table.insert(v12, glass)
end

local v14 = {}
local molotovLights = Instance.new("Part")
molotovLights.Name = "MolotovLights"
molotovLights.Anchored = true
molotovLights.CanCollide = false
molotovLights.CanQuery = false
molotovLights.CanTouch = false
molotovLights.Transparency = 1
molotovLights.Size = Vector3.new(0.2, 0.2, 0.2)
molotovLights.Parent = voxelMolotovs

local random = Random.new()

local parts = {}
local function takeTongue()
	local v15 = table.remove(parts)

	if v15 then
		return v15
	end

	local fuelFlash = Instance.new("Part")
	fuelFlash.Name = "FuelFlash"
	fuelFlash.Anchored = true
	fuelFlash.CanCollide = false
	fuelFlash.CanQuery = false
	fuelFlash.CanTouch = false
	fuelFlash.CastShadow = false
	fuelFlash.Material = Enum.Material.Neon
	fuelFlash.Color = color2
	fuelFlash.Transparency = 1
	fuelFlash.CFrame = cframe
	fuelFlash.Parent = voxelMolotovs
	return fuelFlash
end

local lamps = {}
local function takeLamp()
	local selected = table.remove(lamps)

	if not selected then
		local attachment = Instance.new("Attachment")
		attachment.Parent = molotovLights
		local pointLight = Instance.new("PointLight")
		pointLight.Color = color
		pointLight.Range = 45
		pointLight.Shadows = false
		pointLight.Parent = attachment
		selected = { at = attachment, light = pointLight }
	end

	selected.light.Enabled = true
	return selected
end

local parts2 = {}
local v15 = {}

local function spray(vector3: Vector3) -- 1 equivalent call inferred from this helper
	local vector = random:NextUnitVector()

	if vector:Dot(vector3) < 0 then
		vector = -vector
	end

	return (vector + vector3 * 0.6).Unit
end

local function burst(vector3: Vector3, vector3_2: Vector3, vector3_3: Vector3?, flag: boolean?)
	local now = os.clock()
	local y = (vector3_3 or vector3).Y

	for _ = 1, 14 do
		local part = table.remove(v12)

		if not part then
			break
		end

		local number = random:NextNumber(v2[1], v2[2])
		part.Size = Vector3.new(number, number * random:NextNumber(0.2, 0.5), number * random:NextNumber(0.5, 1.2))
		part.Color = v5[random:NextInteger(1, #v5)]
		part.Transparency = 0.25
		local v16 = {
			part = part,
			pos = vector3 + vector3_2 * 0.3,
			vel = spray(vector3_2) * random:NextNumber(v3[1], v3[2]), -- inferred equivalent call
			rot = CFrame.Angles(random:NextNumber(0, 6.28), random:NextNumber(0, 6.28), 0),
			axis = random:NextUnitVector(),
			rate = random:NextNumber(10, 25),
			t0 = now,
			life = random:NextNumber(v4[1], v4[2]),
			floor = math.min(y, vector3.Y) - 0.1
		}
		table.insert(v13, v16)
	end

	local tongues = {}
	local at = vector3_3 or vector3

	for i = 1, 22 do
		local fuelFlash = table.remove(parts)

		if not fuelFlash then
			fuelFlash = Instance.new("Part")
			fuelFlash.Name = "FuelFlash"
			fuelFlash.Anchored = true
			fuelFlash.CanCollide = false
			fuelFlash.CanQuery = false
			fuelFlash.CanTouch = false
			fuelFlash.CastShadow = false
			fuelFlash.Material = Enum.Material.Neon
			fuelFlash.Color = color2
			fuelFlash.Transparency = 1
			fuelFlash.CFrame = cframe
			fuelFlash.Parent = voxelMolotovs
		end

		local v16 = (i / 22 + random:NextNumber(-0.05, 0.05)) * 3.141592653589793 * 2
		local v17 = i == 1 and 0 or random:NextNumber(0.35, 1)
		tongues[i] = {
			part = fuelFlash,
			base = Vector3.new(math.cos(v16) * v17, 0, math.sin(v16) * v17),
			seed = random:NextNumber(0, 10),
			q = -1
		}
	end

	local count = 0

	for _, v16 in v14 do
		if v16.lamp then
			count += 1
		end
	end

	local lamp

	if not (Quality.potato or not (count < v7)) then
		lamp = takeLamp()
		lamp.at.WorldPosition = at + Vector3.new(0, 1.5, 0)
		lamp.light.Brightness = 4
	end

	table.insert(v14, { tongues = tongues, lamp = lamp, t0 = now, at = at })
	VoxelSound.molotovSmash(vector3, vector3_2, flag)
end

local function stepBurst(now: number, dt: number)
	local vector3 = Vector3.new(0, -workspace.Gravity, 0)
	table.clear(parts2)
	table.clear(v15)

	for i = #v13, 1, -1 do
		local v16 = v13[i]
		local v17 = now - v16.t0

		if v16.life < v17 then
			v16.part.Transparency = 1
			v16.part.CFrame = CFrame.new(0, -10000, 0)
			table.insert(v12, v16.part)
			table.remove(v13, i)
		else
			v16.vel += vector3 * dt
			v16.pos += v16.vel * dt

			if v16.pos.Y < v16.floor and v16.vel.Y < 0 then
				v16.pos = Vector3.new(v16.pos.X, v16.floor, v16.pos.Z)
				v16.vel = Vector3.new(v16.vel.X * 0.4, 0, v16.vel.Z * 0.4)
				v16.rate *= 0.3
			end

			v16.rot = CFrame.fromAxisAngle(v16.axis, v16.rate * dt) * v16.rot
			table.insert(parts2, v16.part)
			table.insert(v15, CFrame.new(v16.pos) * v16.rot)

			if v16.life * 0.7 < v17 then
				v16.part.Transparency = (v17 - v16.life * 0.7) * 0.75 / (v16.life * 0.3) + 0.25
			end
		end
	end

	for i = #v14, 1, -1 do
		local v16 = v14[i]
		local v17 = (now - v16.t0) / 0.8

		if v17 >= 1 then
			for _, tongue in v16.tongues do
				tongue.part.Transparency = 1
				tongue.part.CFrame = cframe
				table.insert(parts, tongue.part)
			end

			local lamp = v16.lamp

			if lamp then
				lamp.light.Enabled = false
				table.insert(lamps, lamp)
			end

			table.remove(v14, i)
		else
			local v18 = (1 - (1 - math.min(v17 * 2.5, 1)) ^ 2) * 26
			local v19 = math.sin(3.141592653589793 * math.min(v17 * 1.5, 1)) * 5 + 0.3

			for _, tongue in v16.tongues do
				local v20 = v19 * (math.sin(now * 19 + tongue.seed) * 0.3 + 0.7)
				local v21 = (1 - v17) * 1.4 + 0.9
				tongue.part.Size = Vector3.new(v21, v20, v21)
				table.insert(parts2, tongue.part)
				table.insert(
					v15,
					CFrame.new(v16.at + tongue.base * v18 + Vector3.new(0, v20 * 0.5, 0)) * CFrame.Angles(0, tongue.seed + v17 * 2, 0)
				)

				local v22 = math.floor(v17 * 12)

				if v22 == tongue.q then
					continue
				end

				tongue.q = v22
				tongue.part.Color = color2:Lerp(color3, v22 / 12)
				tongue.part.Transparency = (v22 / 12) ^ 2 * 0.85 + 0.15
			end

			local lamp = v16.lamp

			if lamp then
				lamp.light.Brightness = 4 * (1 - v17)
			end
		end
	end

	if #parts2 > 0 then
		workspace:BulkMoveTo(parts2, v15, Enum.BulkMoveMode.FireCFrameChanged)
	end
end

remotes:WaitForChild("MolotovThrown").OnClientEvent:Connect(function(id: number, p, vector3: Vector3, vector3_2: Vector3, p2: number)
	if p == Players.LocalPlayer then
		for _, v16 in v10 do
			if v16.mine and v16.id == nil then
				v16.id = id
				return
			end
		end
	end

	add(vector3, vector3_2, math.max(workspace:GetServerTimeNow() - p2, 0), false, id)
end)

remotes:WaitForChild("MolotovBurst").OnClientEvent:Connect(function(p: number, vector3: Vector3, vector3_2: Vector3, vector3_3: Vector3?)
	local v16 = false

	for i = #v10, 1, -1 do
		if v10[i].id ~= p then
			continue
		end

		v16 = v16 or v10[i].mine == true
		remove(i) -- inferred equivalent call
	end

	burst(vector3, vector3_2, vector3_3, v16)
end)

RunService.RenderStepped:Connect(function(dt)
	local now = os.clock()

	for i = #v10, 1, -1 do
		local v16 = v10[i]
		local v17 = now - v16.t0

		if v16.id == nil and v17 > 1.5 or v < v17 then
			remove(i) -- inferred equivalent call
		elseif not v16.hidden then
			local state = v16.state

			if MolotovFlight.advance(state, v17, cast) then
				v16.hidden = true
				hideBody(v16.body) -- inferred equivalent call
			else
				v16.rot = CFrame.fromAxisAngle(v16.spin.Unit, v16.spin.Magnitude * dt) * v16.rot
				place(v16.body, CFrame.new(state.pos) * v16.rot, now)
			end
		end
	end

	if #v13 > 0 or #v14 > 0 then
		stepBurst(now, dt)
	end
end)

return MolotovVisuals