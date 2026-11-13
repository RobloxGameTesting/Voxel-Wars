local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToolTemplates = ReplicatedStorage:WaitForChild("ToolTemplates")

local parent = script.Parent
local VoxelCore = require(parent:WaitForChild("VoxelCore"))
local ClientWorld = require(parent:WaitForChild("ClientWorld"))
local ClaymoreShared = require(parent:WaitForChild("ClaymoreShared"))
local VoxelSound = require(parent:WaitForChild("VoxelSound"))
local remotes = parent:WaitForChild("Remotes")
assert(RunService:IsClient(), "[ClaymoreVisuals] client only")

local ClaymoreVisuals = {}

local color = Color3.fromRGB(255, 45, 40)
local color2 = Color3.fromRGB(60, 190, 255)

local v = {
	Body = true,
	Face = true,
	Emitter = true,
	Laser = true,
	Leg = true
}

local LocalPlayer = Players.LocalPlayer

local voxelClaymores = Instance.new("Folder")
voxelClaymores.Name = "VoxelClaymores"
voxelClaymores.Parent = workspace

local child = ToolTemplates:WaitForChild(ClaymoreShared.NAME, 10)
assert(child, "[ClaymoreVisuals] ToolTemplates.Claymore is missing")
local handle = child:WaitForChild("Handle")

local cframe = CFrame.new(0, -10000, 0)

local function neon(name: string) -- 2 equivalent calls inferred from this helper
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Size = Vector3.new(0.1, 0.1, 0.1)
	part.CFrame = cframe
	part.Parent = voxelClaymores
	return part
end

local function build()
	local clones = {}
	local offsets = {}
	local transparencies = {}
	local lens = {}

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
		clone.CFrame = cframe
		clone.Parent = voxelClaymores
		table.insert(clones, clone)
		table.insert(offsets, handle.CFrame:ToObjectSpace(part.CFrame))
		table.insert(transparencies, part.Transparency)

		if part.Name == "Laser" then
			table.insert(lens, #clones)
		end
	end

	assert(#lens == 2, "[ClaymoreVisuals] the Claymore tool needs two Laser parts")
	local v2 = {
		parts = clones,
		offsets = offsets,
		alphas = transparencies,
		lens = lens,
		cores = {}
	}

	local cores = v2.cores
	cores[1] = neon("Laser") -- inferred equivalent call
	local cores2 = v2.cores
	cores2[2] = neon("Laser") -- inferred equivalent call

	return v2
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Terrain }
raycastParams.IgnoreWater = true

local function cast(origin: Vector3, vector3: Vector3, p: number)
	local world = ClientWorld.world
	local selected, selected2, v2

	if world then
		local _
		selected, selected2, _, v2 = VoxelCore.raycast(world, origin, vector3, p)
	else
		v2 = 0
	end

	local raycastResult = workspace:Raycast(origin, vector3 * p, raycastParams)

	if selected and selected2 and (not raycastResult or v2 <= raycastResult.Distance) then
		return selected, selected2, v2
	end

	if raycastResult then
		return raycastResult.Position, raycastResult.Normal, raycastResult.Distance
	end

	return nil, nil, 0
end

local v2 = {}
local bodies = {}

local function friendly(team: string): boolean -- 1 equivalent call inferred from this helper
	local team2 = LocalPlayer.Team
	return team2 ~= nil and team2.Name == team
end

local function paint(p) -- 4 equivalent calls inferred from this helper
	local v3 = friendly(p.team) -- inferred equivalent call
	local color3 = if v3 then color2 else color
	local body = p.body

	body.cores[1].Color = color3
	body.parts[body.lens[1]].Color = color3
	body.cores[2].Color = color3
	body.parts[body.lens[2]].Color = color3
end

local function light(state, lit: boolean) -- 4 equivalent calls inferred from this helper
	if state.lit == lit then
		return
	end

	state.lit = lit
	local body = state.body

	body.cores[1].Transparency = lit and 0 or 1
	body.cores[2].Transparency = lit and 0 or 1
end

local v3 = {}
local v4 = {}
local function aim(p)
	local body = p.body
	table.clear(v3)
	table.clear(v4)

	for i = 1, 2 do
		local laser, v5 = ClaymoreShared.laser(p.cf, i == 1 and -1 or 1)
		local v6 = ClaymoreShared.LASER_LENGTH
		local v7, _, v8 = cast(laser, v5, v6)

		if v7 then
			v6 = math.max(v8, 0.3)
		end

		local cframe2 = CFrame.lookAlong(laser + v5 * (v6 / 2), v5)
		body.cores[i].Size = Vector3.new(0.1, 0.1, v6)
		table.insert(v3, body.cores[i])
		table.insert(v4, cframe2)
	end

	workspace:BulkMoveTo(v3, v4, Enum.BulkMoveMode.FireCFrameChanged)
end

local function stand(p)
	local body = p.body
	local v5 = ClaymoreShared.handle(p.cf)
	table.clear(v4)

	for k, offset in body.offsets do
		v4[k] = v5 * offset
	end

	workspace:BulkMoveTo(body.parts, v4, Enum.BulkMoveMode.FireCFrameChanged)
	aim(p)
end

local function add(cf: CFrame, team: string, p: number, mine: boolean, id: number?)
	local body = table.remove(bodies) or build()

	for k, part in body.parts do
		part.Transparency = body.alphas[k]
	end

	local now = os.clock()
	local v5 = {
		id = id,
		mine = mine,
		cf = cf,
		team = team,
		t0 = now - p,
		body = body,
		armed = ClaymoreShared.ARM <= p,
		lit = false,
		clipAt = now + 0.6 * (0.5 + math.random())
	}
	paint(v5) -- inferred equivalent call
	stand(v5)
	light(v5, true) -- inferred equivalent call
	table.insert(v2, v5)
	return v5
end

local function remove(i: number)
	local v5 = table.remove(v2, i)
	local body = v5.body
	light(v5, false) -- inferred equivalent call

	for _, part in body.parts do
		part.Transparency = 1
		part.CFrame = cframe
	end

	body.cores[1].CFrame = cframe
	body.cores[2].CFrame = cframe

	table.insert(bodies, body)
end

local v5 = nil
function ClaymoreVisuals.ghost(cf: CFrame?)
	local v6 = v5

	if cf then
		if v6 then
			if (v6.cf.Position - cf.Position).Magnitude < 0.03 and v6.cf.LookVector:Dot(cf.LookVector) > 0.9995 then
				return
			end

			v6.cf = cf
			stand(v6)
		else
			local body = table.remove(bodies) or build()

			for _, part in body.parts do
				part.Transparency = 0.55
			end

			local team = LocalPlayer.Team
			local v7 = {
				id = nil,
				mine = true,
				cf = cf,
				team = not team and "" or team.Name,
				t0 = os.clock(),
				body = body,
				armed = false,
				lit = false,
				clipAt = 0
			}
			v5 = v7
			paint(v7) -- inferred equivalent call
			body.cores[1].Transparency = 0.35
			body.cores[2].Transparency = 0.35

			stand(v7)
		end
	elseif v6 then
		v5 = nil
		local body = v6.body

		for _, part in body.parts do
			part.Transparency = 1
			part.CFrame = cframe
		end

		body.cores[1].Transparency = 1
		body.cores[1].CFrame = cframe
		body.cores[2].Transparency = 1
		body.cores[2].CFrame = cframe

		table.insert(bodies, body)
	end
end

function ClaymoreVisuals.spot(p, vector3: Vector3)
	local vector3_2 = Vector3.new(vector3.X, 0, vector3.Z)

	if vector3_2.Magnitude < 0.05 then
		return nil, nil
	end

	local unit = vector3_2.Unit
	local position = p.Position
	local v6 = ClaymoreShared.PLACE_AHEAD
	local v7, _, v8 = cast(position, unit, v6 + ClaymoreShared.PLACE_CLEAR)

	if v7 then
		v6 = math.max(v8 - ClaymoreShared.PLACE_CLEAR, 0.5)
	end

	local v9, v10 = cast(position + unit * v6, Vector3.new(0, -1, 0), ClaymoreShared.PLACE_SEARCH)

	if v9 and v10 and not (v10.Y < ClaymoreShared.FLOOR) then
		return v9, v10
	end

	return nil, nil
end

function ClaymoreVisuals.predict(cf: CFrame)
	local team = LocalPlayer.Team
	add(cf, not team and "" or team.Name, 0, true, nil)
end

local claymorePlaced = remotes:WaitForChild("ClaymorePlaced")
claymorePlaced.OnClientEvent:Connect(function(id: number, p: number, team: string, cf: CFrame, p2: number)
	for _, v6 in v2 do
		if v6.id == id then
			return
		end
	end

	if p == LocalPlayer.UserId then
		for _, v6 in v2 do
			if v6.mine and v6.id == nil then
				v6.id = id
				v6.team = team
				v6.cf = cf
				paint(v6) -- inferred equivalent call
				stand(v6)
				return
			end
		end
	end

	add(cf, team, math.max(workspace:GetServerTimeNow() - p2, 0), false, id)
end)
claymorePlaced:FireServer()

remotes:WaitForChild("ClaymoreGone").OnClientEvent:Connect(function(p: number, _: boolean)
	for i = #v2, 1, -1 do
		if p == 0 or v2[i].id == p then
			remove(i)
		end
	end
end)

remotes:WaitForChild("WorldReset").OnClientEvent:Connect(function()
	for i = #v2, 1, -1 do
		remove(i)
	end
end)

LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function()
	for _, v6 in v2 do
		paint(v6) -- inferred equivalent call
	end
end)

RunService.Heartbeat:Connect(function()
	if #v2 == 0 then
		return
	end

	local now = os.clock()

	for i = #v2, 1, -1 do
		local v6 = v2[i]
		local v7 = now - v6.t0

		if v6.id == nil and v7 > 1.5 then
			remove(i)
		else
			if not v6.armed then
				if ClaymoreShared.ARM <= v7 then
					v6.armed = true
					light(v6, true) -- inferred equivalent call

					if v6.mine then
						VoxelSound.designator("lock")
					end
				else
					light(v6, math.floor(v7 / 0.11) % 2 == 0) -- inferred equivalent call
				end
			end

			if v6.clipAt <= now then
				v6.clipAt = now + 0.6
				aim(v6)
			end
		end
	end
end)

return ClaymoreVisuals