local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToolTemplates = ReplicatedStorage:WaitForChild("ToolTemplates")

local parent = script.Parent
local VoxelCore = require(parent:WaitForChild("VoxelCore"))
local PipeBombFlight = require(parent:WaitForChild("PipeBombFlight"))
local ClientWorld = require(parent:WaitForChild("ClientWorld"))
local WorldConfig = require(parent:WaitForChild("WorldConfig"))
local Quality = require(parent:WaitForChild("Quality"))
local remotes = parent:WaitForChild("Remotes")
assert(RunService:IsClient(), "[PipeBombVisuals] client only")

local PipeBombVisuals = {}

local meter = WorldConfig.METER

local v = PipeBombFlight.FUSE + 1.5

local color = Color3.fromRGB(90, 20, 16)
local color2 = Color3.fromRGB(255, 90, 50)

local VoxelBombs = workspace:WaitForChild("VoxelBombs")

local PipeBomb = ToolTemplates:WaitForChild("PipeBomb", 10)
assert(PipeBomb, "[PipeBombVisuals] ToolTemplates.PipeBomb is missing")
local Handle = PipeBomb:WaitForChild("Handle")

local function build()
	local clones = {}
	local offsets = {}
	local v2 = nil

	for _, part in PipeBomb:GetDescendants() do
		if not part:IsA("BasePart") then
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
		clone.Parent = VoxelBombs
		table.insert(clones, clone)
		table.insert(offsets, Handle.CFrame:ToObjectSpace(part.CFrame))

		if part.Name == "FuseTip" then
			v2 = clone
		end
	end

	assert(v2, "[PipeBombVisuals] the PipeBomb tool has no FuseTip")
	v2.CastShadow = false
	local attachment = Instance.new("Attachment")
	attachment.Position = Vector3.new(0.03, 0, 0)
	attachment.Parent = v2
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = "rbxassetid://9841260273"
	particleEmitter.LightEmission = 1
	particleEmitter.LightInfluence = 0
	particleEmitter.Orientation = Enum.ParticleOrientation.VelocityParallel
	particleEmitter.Rotation = NumberRange.new(90)
	particleEmitter.RotSpeed = NumberRange.new(0)
	particleEmitter.Brightness = 3
	particleEmitter.Color = ColorSequence.new(Color3.new(1, 0.9, 0.6), Color3.new(1, 0.4, 0.15))
	particleEmitter.Size = NumberSequence.new(0.5, 0.05)
	particleEmitter.Lifetime = NumberRange.new(0.1, 0.25)
	particleEmitter.Speed = NumberRange.new(1 * meter, 3 * meter)
	particleEmitter.SpreadAngle = Vector2.new(60, 60)
	particleEmitter.EmissionDirection = Enum.NormalId.Right
	particleEmitter.Acceleration = Vector3.new(0, -4 * meter, 0)
	particleEmitter.Rate = 40
	particleEmitter.Parent = attachment
	return { parts = clones, offsets = offsets, tip = v2, sparks = particleEmitter }
end

local function place(body, cframe: CFrame) -- 2 equivalent calls inferred from this helper
	local v2 = table.create(#body.parts)

	for k, offset in body.offsets do
		v2[k] = cframe * offset
	end

	workspace:BulkMoveTo(body.parts, v2, Enum.BulkMoveMode.FireCFrameChanged)
end

local function destroy(body) -- 1 equivalent call inferred from this helper
	for _, part in body.parts do
		part:Destroy()
	end
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.IgnoreWater = true
local v2 = nil
local function refreshParams()
	v2 = v2 or workspace:FindFirstChild("VehicleHulls")
	local filterDescendantsInstances

	if v2 then
		filterDescendantsInstances = { workspace.Terrain, v2 }
	else
		filterDescendantsInstances = { workspace.Terrain }
	end

	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
end
refreshParams()

local function cast(origin: Vector3, vector3: Vector3, p: number)
	local world = ClientWorld.world
	assert(world, "[PipeBombVisuals] the client voxel world is not built")
	local raycast, v3, v4, v5 = VoxelCore.raycast(world, origin, vector3, p)
	local raycastResult = workspace:Raycast(origin, vector3 * p, raycastParams)

	if raycast and v3 and (not raycastResult or v5 <= raycastResult.Distance) then
		return raycast, v3, v5, v4
	end

	if raycastResult then
		return raycastResult.Position, raycastResult.Normal, raycastResult.Distance, raycastResult.Material
	end

	return nil, nil, 0, nil
end

local v3 = {}

local function add(vector3: Vector3, vector3_2: Vector3, p: number, mine: boolean, id: number?)
	refreshParams()
	local state = PipeBombFlight.new(vector3, vector3_2)
	local v4 = {
		id = id,
		mine = mine,
		state = state,
		t0 = os.clock() - p,
		body = build(),
		rot = CFrame.lookAt(
			Vector3.new(0, 0, 0),
			not (vector3_2.Magnitude > 0.001) and Vector3.new(0, 0, 1) or vector3_2.Unit
		),
		spin = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 2 * 10,
		bounced = false,
		lit = false
	}

	if p > 0 then
		PipeBombFlight.advance(state, math.min(p, PipeBombFlight.FUSE), cast)
	end

	place(v4.body, CFrame.new(state.pos) * v4.rot) -- inferred equivalent call
	table.insert(v3, v4)
end

function PipeBombVisuals.predict(vector3: Vector3, vector3_2: Vector3)
	add(vector3, PipeBombFlight.launch(vector3_2.Unit), 0, true, nil)
end

local function remove(i: number) -- 2 equivalent calls inferred from this helper
	destroy(v3[i].body) -- inferred equivalent call
	table.remove(v3, i)
end

remotes:WaitForChild("PipeBombThrown").OnClientEvent:Connect(function(id: number, p, vector3: Vector3, vector3_2: Vector3, p2: number)
	if p == Players.LocalPlayer then
		for _, v4 in v3 do
			if v4.mine and v4.id == nil then
				v4.id = id
				return
			end
		end
	end

	add(vector3, vector3_2, math.max(workspace:GetServerTimeNow() - p2, 0), false, id)
end)

remotes:WaitForChild("Explosion").OnClientEvent:Connect(function(_, _, _, _, _, p: string?, p2: number?)
	if p ~= "PipeBomb" or p2 == nil then
		return
	end

	for i = #v3, 1, -1 do
		if v3[i].id == p2 then
			remove(i) -- inferred equivalent call
		end
	end
end)

RunService.RenderStepped:Connect(function(dt)
	local now = os.clock()

	for i = #v3, 1, -1 do
		local v4 = v3[i]
		local v5 = now - v4.t0

		if v4.id == nil and v5 > 1.5 or v < v5 then
			remove(i) -- inferred equivalent call
		else
			local state = v4.state
			v4.bounced = false

			PipeBombFlight.advance(state, math.min(v5, PipeBombFlight.FUSE), cast, function()
				v4.bounced = true
			end)

			if v4.bounced then
				v4.spin *= 0.6
			elseif state.normal then
				v4.spin *= math.exp(-6 * dt)
			end

			local magnitude = v4.spin.Magnitude

			if magnitude > 0.05 then
				v4.rot = CFrame.fromAxisAngle(v4.spin / magnitude, magnitude * dt) * v4.rot
			end

			place(v4.body, CFrame.new(state.pos) * v4.rot) -- inferred equivalent call

			local detail = Quality.detail(state.pos)
			local rate = detail <= 0 and 0 or math.max(8, (math.floor(40 * detail + 0.5)))

			if v4.body.sparks.Rate ~= rate then
				v4.body.sparks.Rate = rate
			end

			local lit = math.sin((PipeBombFlight.FUSE - v5) * 16) > 0

			if lit ~= v4.lit then
				v4.lit = lit
				local tip = v4.body.tip
				local color3 = if lit then color2 else color
				tip.Color = color3
			end
		end
	end
end)

return PipeBombVisuals