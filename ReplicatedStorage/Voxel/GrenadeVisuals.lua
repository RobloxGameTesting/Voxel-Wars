local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToolTemplates = ReplicatedStorage:WaitForChild("ToolTemplates")

local parent = script.Parent
local VoxelCore = require(parent:WaitForChild("VoxelCore"))
local GrenadeFlight = require(parent:WaitForChild("GrenadeFlight"))
local ClientWorld = require(parent:WaitForChild("ClientWorld"))
local VoxelSound = require(parent:WaitForChild("VoxelSound"))
local remotes = parent:WaitForChild("Remotes")
assert(RunService:IsClient(), "[GrenadeVisuals] client only")

local GrenadeVisuals = {}

local v = GrenadeFlight.FUSE + GrenadeFlight.LATE + 1.5

local voxelGrenades = Instance.new("Folder")
voxelGrenades.Name = "VoxelGrenades"
voxelGrenades.Parent = workspace

local Grenade = ToolTemplates:WaitForChild("Grenade", 10)
assert(Grenade, "[GrenadeVisuals] ToolTemplates.Grenade is missing")
local Handle = Grenade:WaitForChild("Handle")
local v2 = {
	Body = true,
	Band = true,
	Shoulder = true,
	Base = true,
	Fuse = true,
	Collar = true
}
local v3 = { Spoon = true, SpoonTop = true }

local function build(p)
	local clones = {}
	local offsets = {}

	for _, part in Grenade:GetChildren() do
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
		clone.Parent = voxelGrenades
		table.insert(clones, clone)
		table.insert(offsets, Handle.CFrame:ToObjectSpace(part.CFrame))
	end

	assert(#clones > 0, "[GrenadeVisuals] the Grenade tool has none of the thrown parts")
	return { parts = clones, offsets = offsets }
end

local function place(body, cframe: CFrame) -- 3 equivalent calls inferred from this helper
	local v4 = table.create(#body.parts)

	for k, offset in body.offsets do
		v4[k] = cframe * offset
	end

	workspace:BulkMoveTo(body.parts, v4, Enum.BulkMoveMode.FireCFrameChanged)
end

local function destroy(body) -- 2 equivalent calls inferred from this helper
	for _, part in body.parts do
		part:Destroy()
	end
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.IgnoreWater = true
local v4 = nil
local function refreshParams()
	v4 = v4 or workspace:FindFirstChild("VehicleHulls")
	local filterDescendantsInstances

	if v4 then
		filterDescendantsInstances = { workspace.Terrain, v4 }
	else
		filterDescendantsInstances = { workspace.Terrain }
	end

	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
end
refreshParams()

local function cast(origin: Vector3, vector3: Vector3, p: number)
	local world = ClientWorld.world
	assert(world, "[GrenadeVisuals] the client voxel world is not built")
	local raycast, v5, v6, v7 = VoxelCore.raycast(world, origin, vector3, p)
	local raycastResult = workspace:Raycast(origin, vector3 * p, raycastParams)

	if raycast and v5 and (not raycastResult or v7 <= raycastResult.Distance) then
		return raycast, v5, v7, v6
	end

	if not raycastResult then
		return nil, nil, 0, nil
	end

	local v8 = raycastResult.Material

	if v4 and raycastResult.Instance:IsDescendantOf(v4) then
		v8 = Enum.Material.Metal
	end

	return raycastResult.Position, raycastResult.Normal, raycastResult.Distance, v8
end

local function onBounce(vector3: Vector3, _: Vector3, p: number, p2)
	VoxelSound.grenadeBounce(vector3, p, p2)
end

local v5 = {}

local function add(vector3: Vector3, vector3_2: Vector3, p: number, mine: boolean, id: number?)
	refreshParams()
	local state = GrenadeFlight.new(vector3, vector3_2)
	local v6 = {
		id = id,
		mine = mine,
		state = state,
		t0 = os.clock() - p,
		body = build(v2),
		rot = CFrame.Angles(math.random() * 6.28, math.random() * 6.28, 0),
		spin = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit * 9
	}

	if p > 0 then
		GrenadeFlight.advance(state, p, cast)
	end

	place(v6.body, CFrame.new(state.pos) * v6.rot) -- inferred equivalent call
	table.insert(v5, v6)
end

local v6 = {}
function GrenadeVisuals.spoon(cframe: CFrame, vector3: Vector3)
	local v7 = 1.5 * GrenadeFlight.scale()
	local body = build(v3)
	table.insert(v6, {
		body = body,
		pos = cframe.Position,
		vel = vector3 + cframe.RightVector * v7 + cframe.UpVector * v7 * 1.2,
		rot = cframe.Rotation,
		t0 = os.clock()
	})
end

function GrenadeVisuals.predict(vector3: Vector3, vector3_2: Vector3)
	add(vector3, vector3_2, 0, true, nil)
end

local function remove(i: number) -- 2 equivalent calls inferred from this helper
	destroy(v5[i].body) -- inferred equivalent call
	table.remove(v5, i)
end

remotes:WaitForChild("GrenadeThrown").OnClientEvent:Connect(function(id: number, p, vector3: Vector3, vector3_2: Vector3, p2: number)
	if p == Players.LocalPlayer then
		for _, v7 in v5 do
			if v7.mine and v7.id == nil then
				v7.id = id
				return
			end
		end
	end

	add(vector3, vector3_2, math.max(workspace:GetServerTimeNow() - p2, 0), false, id)
end)

remotes:WaitForChild("Explosion").OnClientEvent:Connect(function(_, _, _, _, _, p: string?, p2: number?)
	if p ~= "Grenade" or p2 == nil then
		return
	end

	for i = #v5, 1, -1 do
		if v5[i].id == p2 then
			remove(i) -- inferred equivalent call
		end
	end
end)

RunService.RenderStepped:Connect(function(dt)
	local now = os.clock()

	for i = #v5, 1, -1 do
		local v7 = v5[i]
		local v8 = now - v7.t0

		if v7.id == nil and v8 > 1.5 or v < v8 then
			remove(i) -- inferred equivalent call
		else
			local state = v7.state
			GrenadeFlight.advance(state, v8, cast, onBounce)

			local v9 = v7.spin
			local v10 = v7.spin.Magnitude

			if GrenadeFlight.onSurface(state) then
				local cross = state.normal:Cross(state.vel)
				v10 = state.vel.Magnitude / GrenadeFlight.RADIUS
				v9 = not (cross.Magnitude > 0.0001) and Vector3.new(0, 1, 0) or cross

				if state.vel.Magnitude < 0.05 then
					v10 = 0
				end
			end

			if v10 > 0 then
				v7.rot = CFrame.fromAxisAngle(v9.Unit, v10 * dt) * v7.rot
			end

			place(v7.body, CFrame.new(state.pos) * v7.rot) -- inferred equivalent call
		end
	end

	local vector3 = Vector3.new(0, -workspace.Gravity, 0)

	for i = #v6, 1, -1 do
		local v7 = v6[i]

		if now - v7.t0 > 0.9 then
			destroy(v7.body) -- inferred equivalent call
			table.remove(v6, i)
		else
			v7.vel += vector3 * dt
			v7.pos += v7.vel * dt
			v7.rot = CFrame.Angles(30 * dt, 18 * dt, 0) * v7.rot
			place(v7.body, CFrame.new(v7.pos) * v7.rot) -- inferred equivalent call
		end
	end
end)

return GrenadeVisuals