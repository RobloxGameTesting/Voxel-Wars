local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToolTemplates = ReplicatedStorage:WaitForChild("ToolTemplates")

local parent = script.Parent
local VoxelCore = require(parent:WaitForChild("VoxelCore"))
local ClientWorld = require(parent:WaitForChild("ClientWorld"))
local C4Shared = require(parent:WaitForChild("C4Shared"))
local VoxelSound = require(parent:WaitForChild("VoxelSound"))
local remotes = parent:WaitForChild("Remotes")
assert(RunService:IsClient(), "[C4Visuals] client only")

local C4Visuals = {}

local color = Color3.fromRGB(255, 45, 40)
local color2 = Color3.fromRGB(60, 190, 255)
local v = {
	Brick = true,
	Wrap = true,
	Receiver = true,
	Led = true,
	Antenna = true
}

local LocalPlayer = Players.LocalPlayer

local voxelC4 = Instance.new("Folder")
voxelC4.Name = "VoxelC4"
voxelC4.Parent = workspace

local child = ToolTemplates:WaitForChild(C4Shared.NAME, 10)
assert(child, "[C4Visuals] ToolTemplates.C4 is missing")
local handle = child:WaitForChild("Handle")

local cframe = CFrame.new(0, -10000, 0)

local function build()
	local clones = {}
	local offsets = {}
	local led = nil

	for _, part in child:GetChildren() do
		if not (part:IsA("BasePart") and part ~= handle and v[part.Name]) then
			continue
		end

		local clone = part:Clone()

		for _, child2 in clone:GetChildren() do
			child2:Destroy()
		end

		clone.Anchored = true
		clone.CanCollide = false
		clone.CanQuery = false
		clone.CanTouch = false
		clone.CastShadow = false
		clone.Transparency = 0
		clone.CFrame = cframe
		clone.Parent = voxelC4
		table.insert(clones, clone)
		table.insert(offsets, handle.CFrame:ToObjectSpace(part.CFrame))

		if part.Name == "Led" then
			led = clone
		end
	end

	assert(led, "[C4Visuals] the C4 tool needs a Led part")
	return { parts = clones, offsets = offsets, led = led }
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.IgnoreWater = true
local function aimParams()
	local children = { workspace.Terrain }

	for _, childName in { "VehicleHulls", "Helicopters" } do
		local child2 = workspace:FindFirstChild(childName)

		if child2 then
			table.insert(children, child2)
		end
	end

	raycastParams.FilterDescendantsInstances = children
end

local function cast(origin: Vector3, vector3: Vector3, p: number)
	local world = ClientWorld.world
	local v2 = nil
	local v3 = nil
	local v4 = 1e999

	if world then
		local raycast, v5, _, v6 = VoxelCore.raycast(world, origin, vector3, p)

		if raycast and v5 then
			v3 = v5
			v2 = raycast
			v4 = v6
		end
	end

	local raycastResult = workspace:Raycast(origin, vector3 * p, raycastParams)

	if raycastResult and raycastResult.Distance < v4 then
		v2 = raycastResult.Position
		v3 = raycastResult.Normal
		v4 = raycastResult.Distance
	end

	if v2 then
		return v2, v3, v4
	end

	return v2, v3, 0
end

local v2 = {}
local bodies = {}
local v3 = {}

local function friendly(team: string): boolean -- 1 equivalent call inferred from this helper
	local team2 = LocalPlayer.Team
	return team2 ~= nil and team2.Name == team
end

local function paint(p) -- 3 equivalent calls inferred from this helper
	local led = p.body.led
	local v4 = friendly(p.team) -- inferred equivalent call
	local color3 = if v4 then color2 else color
	led.Color = color3
end

local function light(state, lit: boolean) -- 1 equivalent call inferred from this helper
	if state.lit ~= lit then
		state.lit = lit
		local led = state.body.led
		local material

		if lit then
			material = Enum.Material.Neon
		else
			material = Enum.Material.SmoothPlastic
		end

		led.Material = material
	end
end

local function hullFrame(state)
	local model2 = state.model

	if not model2 or model2.Parent == nil then
		local v4 = "V" .. tostring(state.veh)
		model2 = nil

		for _, childName in { "VehicleHulls", "Helicopters" } do
			local child2 = workspace:FindFirstChild(childName)
			local model = child2 and child2:FindFirstChild(v4)

			if model and model:IsA("Model") then
				model2 = model
				break
			end
		end

		state.model = model2
	end

	local primaryPart = model2 and model2.PrimaryPart

	if not (model2 and primaryPart) then
		return nil
	end

	local hullOffset = model2:GetAttribute("HullOffset")

	if typeof(hullOffset) == "CFrame" then
		return primaryPart.CFrame * hullOffset:Inverse()
	end

	return primaryPart.CFrame
end

local function put(p, cframe2: CFrame)
	local body = p.body
	local v4 = C4Shared.handle(cframe2)
	table.clear(v3)

	for k, offset in body.offsets do
		v3[k] = v4 * offset
	end

	workspace:BulkMoveTo(body.parts, v3, Enum.BulkMoveMode.FireCFrameChanged)
end

local function hide(p) -- 2 equivalent calls inferred from this helper
	table.clear(v3)

	for k in p.body.parts do
		v3[k] = cframe
	end

	workspace:BulkMoveTo(p.body.parts, v3, Enum.BulkMoveMode.FireCFrameChanged)
end

local function add(team: string, p: number, mine: boolean, id: number?)
	local body = table.remove(bodies) or build()
	local v4 = {
		id = id,
		mine = mine,
		team = team,
		t0 = os.clock() - p,
		body = body,
		state = nil,
		veh = nil,
		model = nil,
		cf = nil,
		lit = true,
		phase = math.random() * 1.1
	}
	paint(v4) -- inferred equivalent call

	if v4.lit ~= false then
		v4.lit = false
		v4.body.led.Material = Enum.Material.SmoothPlastic
	end

	table.insert(v2, v4)
	return v4
end

local function remove(i: number) -- 3 equivalent calls inferred from this helper
	local v4 = table.remove(v2, i)
	hide(v4) -- inferred equivalent call
	table.insert(bodies, v4.body)
end

local function stuck(state, veh: number, cf: CFrame, flag: boolean) -- 1 equivalent call inferred from this helper
	state.state = nil

	if veh == 0 then
		veh = nil
	end

	state.veh = veh
	state.model = nil
	state.cf = cf

	if not state.veh then
		put(state, cf)
	end

	if flag then
		if state.veh then
			cf = (hullFrame(state) or CFrame.identity) * cf
		end

		if state.veh == nil or hullFrame(state) then
			VoxelSound.punchHit(cf.Position, false, false)
		end

		if state.mine then
			VoxelSound.designator("lock")
		end
	end
end

function C4Visuals.predict(vector3: Vector3, vector3_2: Vector3)
	local team = LocalPlayer.Team
	local add_2 = add(not team and "" or team.Name, 0, true, nil)
	add_2.state = C4Shared.new(vector3, vector3_2)
end

function C4Visuals.mine()
	local count = 0

	for _, v4 in v2 do
		if v4.mine then
			count += 1
		end
	end

	return count
end

remotes:WaitForChild("C4Thrown").OnClientEvent:Connect(function(id: number, p, vector3: Vector3, vector3_2: Vector3, p2: number, team: string)
	if p == LocalPlayer then
		for _, v4 in v2 do
			if v4.mine and v4.id == nil then
				v4.id = id
				v4.team = team
				paint(v4) -- inferred equivalent call
				return
			end
		end
	end

	local add_2 = add(team, math.max(workspace:GetServerTimeNow() - p2, 0), p == LocalPlayer, id)
	add_2.state = C4Shared.new(vector3, vector3_2)
end)

local c4Stuck = remotes:WaitForChild("C4Stuck")
c4Stuck.OnClientEvent:Connect(function(id: number, p: number, team: string, veh: number, cf: CFrame)
	for _, v4 in v2 do
		if v4.id == id then
			stuck(v4, veh, cf, v4.state ~= nil)
			return
		end
	end

	stuck(add(team, 0, p == LocalPlayer.UserId, id), veh, cf) -- inferred equivalent call
end)
c4Stuck:FireServer()

remotes:WaitForChild("C4Gone").OnClientEvent:Connect(function(p: number, _: boolean)
	for i = #v2, 1, -1 do
		if p == 0 or v2[i].id == p then
			remove(i) -- inferred equivalent call
		end
	end
end)

remotes:WaitForChild("WorldReset").OnClientEvent:Connect(function()
	for i = #v2, 1, -1 do
		remove(i) -- inferred equivalent call
	end
end)

LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function()
	for _, v4 in v2 do
		paint(v4) -- inferred equivalent call
	end
end)

RunService:BindToRenderStep("C4Visuals", Enum.RenderPriority.Camera.Value + 5, function()
	if #v2 == 0 then
		return
	end

	local now = os.clock()

	for i = #v2, 1, -1 do
		local v4 = v2[i]
		local v5 = now - v4.t0

		if v4.id == nil and v5 > 1.5 then
			remove(i) -- inferred equivalent call
		else
			local state = v4.state

			if state then
				if not state.done then
					aimParams()
					C4Shared.advance(state, v5, cast)

					if state.done and not state.stuck then
						hide(v4) -- inferred equivalent call
					elseif state.stuck then
						put(v4, C4Shared.frame(state.pos, state.normal, state.vel))
					else
						put(v4, CFrame.new(state.pos) * CFrame.Angles(state.t * 9, state.t * 9 * 0.6, 0))
					end
				end
			else
				local v6 = v4.veh and v4.cf and hullFrame(v4)

				if v6 then
					put(v4, v6 * v4.cf)
				end

				light(v4, (now + v4.phase) % 1.1 < 0.16) -- inferred equivalent call
			end
		end
	end
end)

return C4Visuals