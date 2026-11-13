local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToolTemplates = ReplicatedStorage:WaitForChild("ToolTemplates")

local parent = script.Parent
local VoxelCore = require(parent:WaitForChild("VoxelCore"))
local GrenadeFlight = require(parent:WaitForChild("GrenadeFlight"))
local SmokeCloud = require(parent:WaitForChild("SmokeCloud"))
local ClientWorld = require(parent:WaitForChild("ClientWorld"))
local VoxelSound = require(parent:WaitForChild("VoxelSound"))
local Quality = require(parent:WaitForChild("Quality"))
local remotes = parent:WaitForChild("Remotes")
assert(RunService:IsClient(), "[SmokeVisuals] client only")

local SmokeVisuals = {}

local v = SmokeCloud.FUSE + GrenadeFlight.LATE + 1.5

local v2 = Quality.mobile and 12 or 20
local v3 = Quality.mobile and 3 or 4

local numberRange = NumberRange.new(4, 5.5)

local v4 = Quality.mobile and 16 or 28
local v5 = Quality.mobile and 10 or 18
local color = Color3.fromRGB(204, 206, 208)

local voxelSmoke = Instance.new("Folder")
voxelSmoke.Name = "VoxelSmoke"
voxelSmoke.Parent = workspace

local Smoke = ToolTemplates:WaitForChild("Smoke", 10)
assert(Smoke, "[SmokeVisuals] ToolTemplates.Smoke is missing")
local Handle = Smoke:WaitForChild("Handle")
local v6 = {
	Body = true,
	Band = true,
	Shoulder = true,
	Base = true,
	Fuse = true,
	Collar = true
}
local v7 = { Spoon = true, SpoonTop = true }

local function build(p)
	local clones = {}
	local offsets = {}

	for _, part in Smoke:GetChildren() do
		if not (part:IsA("BasePart") and p[part.Name]) then
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
		clone.Parent = voxelSmoke
		table.insert(clones, clone)
		table.insert(offsets, Handle.CFrame:ToObjectSpace(part.CFrame))
	end

	assert(#clones > 0, "[SmokeVisuals] the Smoke tool has none of the thrown parts")
	return {
		parts = clones,
		offsets = offsets,
		cfs = table.create(#clones)
	}
end

local function place(body, cframe: CFrame) -- 4 equivalent calls inferred from this helper
	local cfs = body.cfs

	for k, offset in body.offsets do
		cfs[k] = cframe * offset
	end

	workspace:BulkMoveTo(body.parts, cfs, Enum.BulkMoveMode.FireCFrameChanged)
end

local function destroy(body) -- 2 equivalent calls inferred from this helper
	for _, part in body.parts do
		part:Destroy()
	end
end

local raycastParams = RaycastParams.new()
raycastParams.IgnoreWater = true
local v8 = nil
local function refreshParams()
	v8 = v8 or workspace:FindFirstChild("VehicleHulls")
	local includeInstances

	if v8 then
		includeInstances = { workspace.Terrain, v8 }
	else
		includeInstances = { workspace.Terrain }
	end

	raycastParams.IncludeInstances = includeInstances
end
refreshParams()

local function cast(origin: Vector3, vector3: Vector3, p: number)
	local world = ClientWorld.world
	assert(world, "[SmokeVisuals] the client voxel world is not built")
	local raycast, v9, v10, v11 = VoxelCore.raycast(world, origin, vector3, p)
	local raycastResult = workspace:Raycast(origin, vector3 * p, raycastParams)

	if raycast and v9 and (not raycastResult or v11 <= raycastResult.Distance) then
		return raycast, v9, v11, v10
	end

	if not raycastResult then
		return nil, nil, 0, nil
	end

	local v12 = raycastResult.Material

	if v8 and raycastResult.Instance:IsDescendantOf(v8) then
		v12 = Enum.Material.Metal
	end

	return raycastResult.Position, raycastResult.Normal, raycastResult.Distance, v12
end

local function onBounce(vector3: Vector3, _: Vector3, p: number, p2)
	VoxelSound.grenadeBounce(vector3, p, p2)
end

local function grey(object) -- 1 equivalent call inferred from this helper
	local number = object:NextNumber(0.56, 0.74)
	return ColorSequence.new(Color3.new(number, number, number * 1.015))
end

local function fadeSeq(p: number)
	return NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.1, p),
		NumberSequenceKeypoint.new(0.7, p),
		NumberSequenceKeypoint.new(1, 1)
	})
end

local function emitterAt(worldPosition: Vector3, object)
	local smoke = Instance.new("Attachment")
	smoke.Name = "Smoke"
	smoke.WorldPosition = worldPosition
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
	particleEmitter.Color = grey(object) -- inferred equivalent call
	particleEmitter.LightInfluence = 0.5
	particleEmitter.LightEmission = 0
	particleEmitter.Orientation = Enum.ParticleOrientation.FacingCamera
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.LockedToPart = false
	particleEmitter.Rate = 0
	particleEmitter.Parent = smoke
	smoke.Parent = workspace.Terrain
	return smoke, particleEmitter
end

local function billowEmitter(worldPosition: Vector3, rng, p: number, p2: number)
	local parent2, v9 = emitterAt(worldPosition, rng)
	local v10 = p * 9
	v9.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, v10 * 0.55, v10 * 0.1),
		NumberSequenceKeypoint.new(0.35, v10, v10 * 0.1),
		NumberSequenceKeypoint.new(1, v10 * 1.35, v10 * 0.15)
	})

	v9.Transparency = fadeSeq(p2)
	v9.Lifetime = numberRange
	v9.Speed = NumberRange.new(0.3, 1.4)
	v9.SpreadAngle = Vector2.new(180, 180)
	v9.Drag = 0.8
	v9.Acceleration = Vector3.new(0, 0.35, 0)
	v9.RotSpeed = NumberRange.new(-14, 14)
	return parent2, v9
end

local function gushEmitter(worldPosition: Vector3, rng)
	local parent2, v9 = emitterAt(worldPosition, rng)
	v9.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1.5, 0.4),
		NumberSequenceKeypoint.new(0.4, 5.5, 1),
		NumberSequenceKeypoint.new(1, 8, 1.5)
	})

	v9.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.15),
		NumberSequenceKeypoint.new(0.6, 0.35),
		NumberSequenceKeypoint.new(1, 1)
	})

	v9.Lifetime = NumberRange.new(1.6, 2.8)
	v9.Speed = NumberRange.new(9, 17)
	v9.SpreadAngle = Vector2.new(75, 75)
	v9.Drag = 3.5
	v9.Acceleration = Vector3.new(0, 0.5, 0)
	v9.RotSpeed = NumberRange.new(-40, 40)
	return parent2, v9
end

local function streamEmitter(worldPosition: Vector3, rng)
	local parent2, v9 = emitterAt(worldPosition, rng)
	v9.Color = ColorSequence.new(Color3.new(0.82, 0.82, 0.83))
	v9.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5, 0.1), NumberSequenceKeypoint.new(1, 3.8, 0.6) })

	v9.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.5, 0.55),
		NumberSequenceKeypoint.new(1, 1)
	})

	v9.Lifetime = NumberRange.new(1.1, 1.7)
	v9.Speed = NumberRange.new(4, 6.5)
	v9.SpreadAngle = Vector2.new(12, 12)
	v9.Drag = 1.6
	v9.Acceleration = Vector3.new(0, 1, 0)
	v9.RotSpeed = NumberRange.new(-60, 60)
	return parent2, v9
end

local v9 = {}

local function newLive(vector3: Vector3, vector3_2: Vector3, mine: boolean, id: number?)
	return {
		id = id,
		mine = mine,
		state = GrenadeFlight.new(vector3, vector3_2, SmokeCloud.FUSE),
		t0 = os.clock(),
		body = build(v6),
		rot = CFrame.Angles(math.random() * 6.28, math.random() * 6.28, 0),
		spin = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit * 8,
		born = nil,
		at = nil,
		billows = {},
		gush = nil,
		stream = nil,
		streamE = nil,
		streamSent = nil,
		probe = nil,
		rng = Random.new()
	}
end

local function add(vector3: Vector3, vector3_2: Vector3, p: number, mine: boolean, id: number?) -- 1 equivalent call inferred from this helper
	refreshParams()
	local v10 = newLive(vector3, vector3_2, mine, id)
	v10.t0 = os.clock() - p

	if p > 0 then
		GrenadeFlight.advance(v10.state, p, cast)
	end

	place(v10.body, CFrame.new(v10.state.pos) * v10.rot) -- inferred equivalent call
	table.insert(v9, v10)
end

local function easeOut(p: number) -- 1 equivalent call inferred from this helper
	return 1 - (1 - p) ^ 3
end

local function home(state, vector3: Vector3, p: number) -- 1 equivalent call inferred from this helper
	local shape = SmokeCloud.shape(p)
	return SmokeCloud.centre(state.probe, shape) + vector3 * SmokeCloud.radii(shape)
end

local function fill(state, p: number)
	local rng = state.rng
	local pos = state.state.pos

	for i = 1, v2 do
		local v10, v11

		if i > 1 then
			local vector3 = Vector3.new(rng:NextNumber(-1, 1), rng:NextNumber(-1, 1), rng:NextNumber(-1, 1))
			local v12 = not (vector3.Magnitude > 0.001) and Vector3.new(1, 0, 0) or vector3.Unit
			v10 = rng:NextNumber(0.2, 1) ^ 0.6 * 0.8
			local v13 = v12 * v10
			v11 = Vector3.new(v13.X, math.clamp(v13.Y, -0.45, 0.6), v13.Z)
		else
			v10 = 0
			v11 = Vector3.new(0, 0, 0)
		end

		local shown = v10 * 0.25 + 0.05
		local v12 = rng:NextNumber(0.8, 1.2) * (v10 * 0.3 + 0.9)
		local delay = SmokeCloud.GROW * 0.8 * v10 + rng:NextNumber(0, 0.2)
		local v13 = delay + 0.8 < p
		local pos2

		if v13 then
			pos2 = home(state, v11, p) -- inferred equivalent call
		else
			pos2 = pos
		end

		local at, v14 = billowEmitter(pos2, rng, v12, shown)
		table.insert(state.billows, {
			at = at,
			e = v14,
			u = v11,
			delay = delay,
			t = shown,
			shown = shown,
			pos = pos2,
			rate = 0
		})

		if v13 then
			v14:Emit((math.ceil(v3 * numberRange.Max * 0.8)))
		end
	end

	if p < 0.5 then
		local gush, v10 = gushEmitter(pos + Vector3.new(0, 0.3, 0), rng)
		v10:Emit(v4)
		state.gush = gush
	end

	local stream, streamE = streamEmitter(pos + Vector3.new(0, 0.3, 0), rng)
	local streamSent = {
		pos = pos + Vector3.new(0, 0.3, 0),
		rate = 0
	}
	state.stream = stream
	state.streamE = streamE
	state.streamSent = streamSent
end

local function clearCloud(state)
	for _, billow in state.billows do
		billow.at:Destroy()
	end

	table.clear(state.billows)

	if state.gush then
		state.gush:Destroy()
		state.gush = nil
	end

	if state.stream then
		state.stream:Destroy()
		state.stream = nil
		state.streamE = nil
		state.streamSent = nil
	end
end

local function remove(i: number) -- 2 equivalent calls inferred from this helper
	local v10 = v9[i]

	if v10.body then
		destroy(v10.body) -- inferred equivalent call
	end

	clearCloud(v10)

	if v10.id then
		VoxelSound.smokeHiss(v10.id, nil)
	end

	table.remove(v9, i)
end

local function pop(state, at: Vector3, born: number)
	state.born = born
	state.at = at
	state.probe = { id = 0, pos = at, born = 0 }
	SmokeCloud.add(state.id, at, born)
	local v10 = workspace:GetServerTimeNow() - born
	fill(state, v10)

	if v10 < 0.5 then
		VoxelSound.smokePop(at, state.mine)
	end
end

local v10 = {}
function SmokeVisuals.spoon(cframe: CFrame, vector3: Vector3)
	local v11 = 1.5 * GrenadeFlight.scale()
	table.insert(v10, {
		body = build(v7),
		pos = cframe.Position,
		vel = vector3 + cframe.RightVector * v11 + cframe.UpVector * v11 * 1.2,
		rot = cframe.Rotation,
		t0 = os.clock()
	})
end

function SmokeVisuals.predict(vector3: Vector3, vector3_2: Vector3)
	add(vector3, vector3_2, 0, true) -- inferred equivalent call
end

remotes:WaitForChild("SmokeThrown").OnClientEvent:Connect(function(id: number, p, vector3: Vector3, vector3_2: Vector3, p2: number)
	if p == Players.LocalPlayer then
		for _, v11 in v9 do
			if v11.mine and v11.id == nil then
				v11.id = id
				return
			end
		end
	end

	add(vector3, vector3_2, math.max(workspace:GetServerTimeNow() - p2, 0), false, id)
end)

local smokePopped = remotes:WaitForChild("SmokePopped")
smokePopped.OnClientEvent:Connect(function(id: number, pos: Vector3, born: number)
	for _, v11 in v9 do
		if v11.id == id then
			if not v11.born then
				v11.state.pos = pos
				v11.state.vel = Vector3.new(0, 0, 0)
				pop(v11, pos, born)
			end

			return
		end
	end

	local v11 = newLive(pos, Vector3.new(0, 0, 0), false, id)
	v11.state.touched = v11.state.t
	place(v11.body, CFrame.new(pos) * v11.rot) -- inferred equivalent call
	table.insert(v9, v11)
	pop(v11, pos, born)
end)
smokePopped:FireServer()

remotes:WaitForChild("WorldReset").OnClientEvent:Connect(function()
	for i = #v9, 1, -1 do
		remove(i) -- inferred equivalent call
	end

	SmokeCloud.clear()
end)

local smokeVeil = Instance.new("ScreenGui")
smokeVeil.Name = "SmokeVeil"
smokeVeil.IgnoreGuiInset = true
smokeVeil.ResetOnSpawn = false
smokeVeil.DisplayOrder = -5
smokeVeil.Enabled = false
local frame = Instance.new("Frame")
frame.Size = UDim2.fromScale(1, 1)
frame.BorderSizePixel = 0
frame.BackgroundColor3 = color
frame.Parent = smokeVeil
smokeVeil.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local v11 = -1

local function setEmitter(state, p, p2, vector3: Vector3, rate: number) -- 3 equivalent calls inferred from this helper
	if (state.pos - vector3).Magnitude > 0.1 then
		state.pos = vector3
		p.WorldPosition = vector3
	end

	if state.rate ~= rate then
		state.rate = rate
		p2.Rate = rate
	end
end

local function stepCloud(data, serverTimeNow: number)
	local v12 = serverTimeNow - data.born
	local shape, v13 = SmokeCloud.shape(v12)
	local pos = data.state.pos
	local v14 = v12 < SmokeCloud.GROW + 0.8

	local centre = SmokeCloud.centre(data.probe, shape)
	local radii = SmokeCloud.radii(shape)
	local rate = not (v13 > 0.02) and 0 or v3 * (v14 and 2.6 or 1)

	for _, billow in data.billows do
		local v15 = v12 - billow.delay

		if v15 <= 0 then
			setEmitter(billow, billow.at, billow.e, pos, 0) -- inferred equivalent call
		else
			local v16 = centre + billow.u * radii
			local at = billow.at
			local e = billow.e

			if v15 < 0.8 then
				v16 = pos:Lerp(v16, easeOut(v15 / 0.8)) -- inferred equivalent call
			end

			setEmitter(billow, at, e, v16, rate) -- inferred equivalent call
			local shown = 1 - (1 - billow.t) * math.min(v13 * 1.1, 1)

			if math.abs(shown - billow.shown) > 0.02 then
				billow.shown = shown
				billow.e.Transparency = fadeSeq(shown)
			end
		end
	end

	local streamE = data.streamE

	if streamE then
		setEmitter( -- inferred equivalent call
			data.streamSent,
			data.stream,
			streamE,
			pos + Vector3.new(0, 0.3, 0),
			not (v12 < SmokeCloud.HOLD) and 0 or v5
		)
	end
end

RunService.RenderStepped:Connect(function(dt)
	local now = os.clock()
	local serverTimeNow = workspace:GetServerTimeNow()

	for i = #v9, 1, -1 do
		local v12 = v9[i]
		local v13 = now - v12.t0

		if
			v12.id == nil and v13 > 1.5
			or v12.born == nil and v < v13
			or v12.born and serverTimeNow - v12.born >= SmokeCloud.LIFE
		then
			remove(i) -- inferred equivalent call
		else
			local state = v12.state
			local v14

			if v12.born == nil then
				v14 = false
			else
				v14 = GrenadeFlight.onSurface(state) and state.vel.Magnitude <= 0.05
			end

			if v14 then
				if v13 - state.t >= 0.5 then
					state.t = v13 - GrenadeFlight.STEP
					GrenadeFlight.advance(state, v13, cast, nil)
				end
			elseif v12.born == nil or GrenadeFlight.onSurface(state) or state.vel.Magnitude > 0.05 then
				local advance = GrenadeFlight.advance
				local v15

				if not v12.born then
					v15 = onBounce
				end

				advance(state, v13, cast, v15)
			end

			local body = v12.body

			if body and not v14 then
				local v15 = v12.spin
				local v16 = v12.spin.Magnitude

				if GrenadeFlight.onSurface(state) then
					local cross = state.normal:Cross(state.vel)
					v16 = state.vel.Magnitude / GrenadeFlight.RADIUS
					v15 = not (cross.Magnitude > 0.0001) and Vector3.new(0, 1, 0) or cross

					if state.vel.Magnitude < 0.05 then
						v16 = 0
					end
				end

				if v16 > 0 then
					v12.rot = CFrame.fromAxisAngle(v15.Unit, v16 * dt) * v12.rot
				end

				place(body, CFrame.new(state.pos) * v12.rot) -- inferred equivalent call
			end

			if v12.born then
				stepCloud(v12, serverTimeNow)
				local smokeHiss = VoxelSound.smokeHiss
				local id = v12.id
				local v15

				if serverTimeNow - v12.born < SmokeCloud.HOLD then
					v15 = state.pos
				end

				smokeHiss(id, v15)
			end
		end
	end

	local v12 = not (#v10 > 0) and Vector3.new(0, 0, 0) or Vector3.new(0, -workspace.Gravity, 0)

	for i = #v10, 1, -1 do
		local v13 = v10[i]

		if now - v13.t0 > 0.9 then
			destroy(v13.body) -- inferred equivalent call
			table.remove(v10, i)
		else
			v13.vel += v12 * dt
			v13.pos += v13.vel * dt
			v13.rot = CFrame.Angles(30 * dt, 18 * dt, 0) * v13.rot
			place(v13.body, CFrame.new(v13.pos) * v13.rot) -- inferred equivalent call
		end
	end

	local currentCamera = workspace.CurrentCamera
	local v13 = not currentCamera and 0 or SmokeCloud.depthAt(currentCamera.CFrame.Position, serverTimeNow)
	local enabled = v13 > 0.01

	if smokeVeil.Enabled ~= enabled then
		smokeVeil.Enabled = enabled
	end

	if enabled then
		local backgroundTransparency = 1 - 0.94 * v13 ^ 0.7

		if backgroundTransparency ~= v11 then
			v11 = backgroundTransparency
			frame.BackgroundTransparency = backgroundTransparency
		end
	end
end)

return SmokeVisuals