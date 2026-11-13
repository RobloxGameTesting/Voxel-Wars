local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local parent = script.Parent
local VoxelCore = require(parent:WaitForChild("VoxelCore"))
local ClientWorld = require(parent:WaitForChild("ClientWorld"))
local Detail = require(parent:WaitForChild("Detail"))

local CaseDrop = {}

local cframe = CFrame.new(0, -20000, 0)

CaseDrop.ownLanded = nil

local v = nil
local v2 = {}
local v3 = 0

local function ensureFolder() -- 2 equivalent calls inferred from this helper
	local currentCamera = workspace.CurrentCamera
	local spentCases = v

	if not (spentCases and spentCases.Parent) then
		spentCases = Instance.new("Folder")
		spentCases.Name = "SpentCases"
		v = spentCases
	end

	assert(spentCases)

	if spentCases.Parent ~= currentCamera then
		spentCases.Parent = currentCamera
	end

	return spentCases
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = false

local v4 = -1e999
local function refreshParams()
	local now = os.clock()

	if now - v4 < 0.5 then
		return
	end

	v4 = now
	local filterDescendantsInstances = {}
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		table.insert(filterDescendantsInstances, currentCamera)
	end

	for _, v5 in Players:GetPlayers() do
		if v5.Character then
			table.insert(filterDescendantsInstances, v5.Character)
		end
	end

	for _, childName in { "BotRigs", "VoxelWorld" } do
		local child = workspace:FindFirstChild(childName)

		if child then
			table.insert(filterDescendantsInstances, child)
		end
	end

	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
end

local function cast(origin: Vector3, vector3: Vector3, p: number)
	local world = ClientWorld.world
	local v5 = nil
	local v6 = nil
	local v7 = nil
	local v8 = 1e999

	if world then
		local raycast, v9, v10, v11 = VoxelCore.raycast(world, origin, vector3, p)

		if raycast and v9 and v10 ~= 0 and v11 > 0 then
			v7 = v10
			v6 = v9
			v5 = raycast
			v8 = v11
		end
	end

	local raycastResult = workspace:Raycast(origin, vector3 * p, raycastParams)

	if raycastResult and raycastResult.Distance < v8 then
		return raycastResult.Position, raycastResult.Normal, raycastResult.Material
	end

	return v5, v6, v7
end

local function park(p) -- 3 equivalent calls inferred from this helper
	p.state = 0
	p.part.CFrame = cframe
	p.part.Transparency = 1
end

local function lieDown(state, vector3: Vector3, vector: Vector3)
	local v5 = state.rot.LookVector - vector * state.rot.LookVector:Dot(vector)

	if v5.Magnitude < 0.001 then
		v5 = vector:Cross(Vector3.new(1, 0, 0))

		if v5.Magnitude < 0.001 then
			v5 = vector:Cross(Vector3.new(0, 0, 1))
		end
	end

	local unit = v5.Unit
	state.rot = CFrame.lookAlong(Vector3.new(0, 0, 0), unit, vector)
	state.pos = vector3 + vector * state.radius
	state.part.CFrame = CFrame.new(state.pos) * state.rot
	state.state = 2
	state.restAt = os.clock()
end

local v5 = {}
local v6 = {}
local function step(p: number)
	if v3 == 0 then
		return
	end

	debug.profilebegin("CaseDrop")
	local now = os.clock()
	local count = 0
	local count2 = 0

	for _, v7 in v2 do
		local state = v7.state

		if state == 1 then
			if now - v7.t0 > 4 then
				park(v7) -- inferred equivalent call
			else
				v7.vel -= Vector3.new(0, p * 40, 0)
				local v8 = v7.vel * p
				local magnitude = v8.Magnitude

				if magnitude > 0.00001 then
					local v9 = v8 / magnitude
					local v10, v11, v12 = cast(v7.pos, v9, magnitude + v7.radius)

					if v10 and v11 then
						if v12 == Enum.Material.Water then
							park(v7) -- inferred equivalent call
							continue
						else
							local dot = v7.vel:Dot(v11)
							local v13 = math.max(-dot, 0)

							if not v7.landed then
								v7.landed = true
								local onLand = v7.onLand

								if onLand then
									onLand(v10, v12, v13)
								end
							end

							local v14

							if typeof(v12) == "EnumItem" then
								v14 = v12 == Enum.Material.Grass
									or v12 == Enum.Material.LeafyGrass
									or v12 == Enum.Material.Ground
									or v12 == Enum.Material.Mud
									or v12 == Enum.Material.Sand
									or v12 == Enum.Material.Snow
							else
								v14 = false
							end

							if not (v13 > 2.5) then
								lieDown(v7, v10, v11)
								continue
							end

							local v15 = v11 * dot
							v7.vel = (v7.vel - v15) * (v14 and 0.3 or 0.55) - v15 * (v14 and 0.15 or 0.38)
							v7.spin *= 0.6
							v7.pos = v10 + v11 * v7.radius
						end
					else
						v7.pos += v8
					end
				end

				v7.rot *= CFrame.fromOrientation(v7.spin.X * p, v7.spin.Y * p, v7.spin.Z * p)
				count2 += 1
				local part = v7.part
				local v9 = CFrame.new(v7.pos) * v7.rot
				v5[count2] = part
				v6[count2] = v9
				count += 1
			end
		elseif state == 2 then
			if now - v7.restAt >= 5 then
				v7.state = 3
				count += 1
			end
		elseif state == 3 then
			local transparency = (now - v7.restAt - 5) / 0.6

			if transparency >= 1 then
				park(v7) -- inferred equivalent call
			else
				v7.part.Transparency = transparency
				count += 1
			end
		end
	end

	for i = count2 + 1, #v5 do
		v5[i] = nil
		v6[i] = nil
	end

	if count2 > 0 then
		workspace:BulkMoveTo(v5, v6, Enum.BulkMoveMode.FireCFrameChanged)
	end

	v3 = count
	debug.profileend()
end
RunService.PreRender:Connect(step)

task.spawn(function()
	while true do
		task.wait(1)

		if v3 ~= 0 then
			continue
		end

		local now = os.clock()

		for _, v7 in v2 do
			if v7.state == 2 and now - v7.restAt >= 5 then
				v3 = 1
				break
			end
		end
	end
end)

local function take()
	local v7 = nil

	for _, v8 in v2 do
		if v8.state == 0 then
			return v8
		end

		if not v7 or v8.t0 < v7.t0 then
			v7 = v8
		end
	end

	if not (#v2 < 48) then
		assert(v7)
		return v7
	end

	local case = Instance.new("Part")
	case.Name = "Case"
	case.Anchored = true
	case.CanCollide = false
	case.CanQuery = false
	case.CanTouch = false
	case.CastShadow = false
	case.Material = Enum.Material.Metal
	case.CFrame = cframe
	case.Transparency = 1
	case.Parent = ensureFolder() -- inferred equivalent call
	local v8 = {
		part = case,
		state = 0,
		pos = Vector3.new(0, 0, 0),
		vel = Vector3.new(0, 0, 0),
		rot = CFrame.identity,
		spin = Vector3.new(0, 0, 0),
		t0 = 0,
		restAt = 0,
		radius = 0.05,
		onLand = nil,
		landed = false
	}
	table.insert(v2, v8)
	return v8
end

function CaseDrop.throw(pos: Vector3, vel: Vector3, cframe2: CFrame, vector3: Vector3, color: Color3, onLand, vector3_2: Vector3?)
	if not CaseDrop.on() then
		return
	end

	ensureFolder() -- inferred equivalent call
	refreshParams()
	local size = vector3 * 0.75

	if vector3_2 then
		local v7 = pos - vector3_2
		local magnitude = v7.Magnitude

		if magnitude > 0.001 then
			local v8, v9 = cast(vector3_2, v7 / magnitude, magnitude)

			if v8 and v9 then
				pos = v8 + v9 * 0.1
			end
		end
	end

	local v7 = take()
	local part = v7.part

	if part.Size ~= size then
		part.Size = size
	end

	if part.Color ~= color then
		part.Color = color
	end

	part.Transparency = 0
	local rotation = cframe2.Rotation
	local now = os.clock()
	v7.state = 1
	v7.pos = pos
	v7.vel = vel
	v7.rot = rotation
	v7.t0 = now
	v7.landed = false
	v7.onLand = onLand
	v7.radius = math.min(size.X, size.Y) / 2
	v7.spin = Vector3.new(math.random(-20, 20), math.random(10, 30), math.random(-10, 10))
	part.CFrame = CFrame.new(pos) * v7.rot
	v3 += 1
end

function CaseDrop.on(): boolean
	return not Detail.mobile and Detail.strain < 1
end

function CaseDrop.ground(vector3: Vector3)
	refreshParams()
	local v7, _, v8 = cast(vector3, Vector3.new(0, -1, 0), 12)
	return v7, v8
end

local function ownLand(_: Vector3, p, _: number)
	local ownLanded = CaseDrop.ownLanded

	if ownLanded then
		ownLanded(p)
	end
end
function CaseDrop.throwOwn(vector3: Vector3, vector3_2: Vector3, cframe2: CFrame, vector3_3: Vector3, color: Color3, vector3_4: Vector3?)
	CaseDrop.throw(vector3, vector3_2, cframe2, vector3_3, color, ownLand, vector3_4)
end

return CaseDrop