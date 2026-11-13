local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local parent = script.Parent
local VoxelCore = require(parent:WaitForChild("VoxelCore"))
local FlameStream = require(parent:WaitForChild("FlameStream"))
local ClientWorld = require(parent:WaitForChild("ClientWorld"))
local VoxelSound = require(parent:WaitForChild("VoxelSound"))
local Quality = require(parent:WaitForChild("Quality"))
local Detail = require(parent:WaitForChild("Detail"))
local remotes = parent:WaitForChild("Remotes")
assert(RunService:IsClient(), "[FlameVisuals] client only")

local v = {
	{ 0, Color3.fromRGB(255, 244, 186) },
	{ 0.22, Color3.fromRGB(255, 190, 70) },
	{ 0.55, Color3.fromRGB(240, 108, 30) },
	{ 0.85, Color3.fromRGB(176, 52, 22) },
	{ 1, Color3.fromRGB(96, 34, 20) }
}

local color = Color3.fromRGB(42, 38, 36)
local color2 = Color3.fromRGB(255, 150, 66)

local v2 = Quality.mobile and 1 or 3
local v3 = Quality.mobile and 1 or 4

local color3 = Color3.fromRGB(255, 214, 180)

local voxelFlames = Instance.new("Folder")
voxelFlames.Name = "VoxelFlames"
voxelFlames.Parent = workspace

local cframe = CFrame.new(0, -10000, 0)
local function block(name: string) -- 1 equivalent call inferred from this helper
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	local smooth = Enum.SurfaceType.Smooth
	local smooth2 = Enum.SurfaceType.Smooth
	part.TopSurface = smooth
	part.BottomSurface = smooth2
	part.Transparency = 1
	part.CFrame = cframe
	part.Parent = voxelFlames
	return part
end

local function hot(p: number)
	for i = 2, #v do
		local v4 = v[i]

		if p <= v4[1] then
			local v5 = v[i - 1]
			return v5[2]:Lerp(v4[2], (p - v5[1]) / (v4[1] - v5[1]))
		end
	end

	return v[#v][2]
end

local v4 = {}
local v5 = { range = 12, brightness = 0.7, out = 6 }
local lightSpec = { range = 14, brightness = 1.1, out = 5 }

local v6 = { range = 14, brightness = 1.8 }
local v7 = { 0.7, 1.2 }
local v8 = { 0.3, 0.55 }
local FlameVisuals = {}

local v9 = { range = 10, brightness = 1.3 }

for i = 0, 16 do
	v4[i] = hot(i / 16)
end

local function shade(p: number) -- 4 equivalent calls inferred from this helper
	return (math.clamp(math.floor(p * 16 + 0.5), 0, 16))
end

local raycastParams = RaycastParams.new()
raycastParams.IgnoreWater = true
local v10 = nil
local function refreshParams()
	v10 = v10 or workspace:FindFirstChild("VehicleHulls")
	local includeInstances

	if v10 then
		includeInstances = { workspace.Terrain, v10 }
	else
		includeInstances = { workspace.Terrain }
	end

	raycastParams.IncludeInstances = includeInstances
end
refreshParams()

local function cast(origin: Vector3, vector3: Vector3, p: number)
	local world = ClientWorld.world
	assert(world, "[FlameVisuals] the client voxel world is not built")
	local raycast, v11, v12, v13 = VoxelCore.raycast(world, origin, vector3, p)
	local raycastResult = workspace:Raycast(origin, vector3 * p, raycastParams)

	if raycast and v11 and (not raycastResult or v13 <= raycastResult.Distance) then
		return raycast, v11, v13, v12
	end

	if raycastResult then
		return raycastResult.Position, raycastResult.Normal, raycastResult.Distance, raycastResult.Material
	end

	return nil, nil, 0, nil
end

local random = Random.new()
local v11 = {}

for k, v12 in { 0.65, 0.85, 1.05 } do
	v11[k] = FlameStream.dripSpeed(v12)
end

local v12 = {}

local v13 = {}

for _ = 1, 420 do
	table.insert(v12, block("Flame")) -- inferred equivalent call
end

local flameLights = Instance.new("Part")
flameLights.Name = "FlameLights"
flameLights.Anchored = true
flameLights.CanCollide = false
flameLights.CanQuery = false
flameLights.CanTouch = false
flameLights.CastShadow = false
flameLights.Transparency = 1
flameLights.Size = Vector3.new(0.2, 0.2, 0.2)
flameLights.Parent = voxelFlames

local v14 = {}
local function takeLamp(p)
	local selected = table.remove(v14)

	if not selected then
		local attachment = Instance.new("Attachment")
		attachment.Parent = flameLights
		local pointLight = Instance.new("PointLight")
		pointLight.Color = color2
		pointLight.Shadows = false
		pointLight.Parent = attachment
		selected = {
			at = attachment,
			light = pointLight,
			bright = -1,
			on = false,
			pos = nil
		}
	end

	local light = selected.light
	light.Range = p.range
	light.Brightness = p.brightness
	light.Enabled = true
	selected.bright = p.brightness
	selected.on = true
	return selected
end

local function giveLamp(p) -- 3 equivalent calls inferred from this helper
	if p then
		p.light.Enabled = false
		p.on = false
		table.insert(v14, p)
	end
end

local function lampBright(state, p: number) -- 3 equivalent calls inferred from this helper
	if state.bright ~= p then
		state.bright = p
		state.light.Brightness = p
	end
end
local function lampAt(state, vector3: Vector3) -- 3 equivalent calls inferred from this helper
	if state.pos ~= vector3 then
		state.pos = vector3
		state.at.WorldPosition = vector3
	end
end

local v15 = {}
local v16 = {}
local v17 = {}

for k in v11 do
	v15[k] = k
end

local v18 = { (math.ceil(#v11 / 2)) }

local function traceFalls(vector3: Vector3, vector3_2: Vector3, items)
	local result = {}

	for k, item in items do
		result[k] = FlameStream.trace(vector3, vector3_2, cast, v11[item])
	end

	return result
end

local function litRemote() -- 1 equivalent call inferred from this helper
	local count = 0

	for k, v19 in v16 do
		if k ~= "own" and v19.nozzle then
			count += 1
		end
	end

	return count
end

local function jetFor(p, origin: Vector3, dir: Vector3, rate: number, fallPicks)
	local v19 = v16[p]

	if v19 then
		return v19
	end

	refreshParams()
	local lightSpec2 = if p == "own" then v5 else lightSpec
	local v20 = not Quality.potato

	if v20 then
		if p == "own" then
			v20 = true
		else
			v20 = litRemote() < v2 -- inferred equivalent call
		end
	end

	v19 = {
		origin = origin,
		dir = dir,
		far = false,
		trace = FlameStream.trace(origin, dir, cast),
		tracedAt = os.clock(),
		falls = traceFalls(origin, dir, fallPicks),
		fallPicks = fallPicks,
		fellAt = os.clock(),
		last = os.clock(),
		owed = 1,
		rate = rate,
		lightSpec = lightSpec2,
		nozzle = 0,
		splash = 0
	}
	local nozzle

	if v20 then
		nozzle = takeLamp(lightSpec2)
	end

	v19.nozzle = nozzle
	local splash

	if v20 then
		splash = takeLamp(v6)
	end

	v19.splash = splash

	v16[p] = v19

	return v19
end

local function dropJet(p) -- 3 equivalent calls inferred from this helper
	local v19 = v16[p]

	if v19 then
		giveLamp(v19.nozzle) -- inferred equivalent call
		giveLamp(v19.splash) -- inferred equivalent call
		v16[p] = nil

		if p ~= "own" then
			VoxelSound.flamerAt(p, nil)
		end
	end
end

local function across(normal: Vector3) -- 2 equivalent calls inferred from this helper
	local vector = random:NextUnitVector()
	local v19 = vector - normal * vector:Dot(normal)

	if v19.Magnitude > 0.001 then
		return v19.Unit
	end

	return normal:Cross(Vector3.new(0, 1, 0)).Unit
end

local function emit(data, p: number, p2: number)
	local part = table.remove(v12)

	if not part then
		return
	end

	local fall = random:NextNumber() < 0.25
	local integer = random:NextInteger(1, #data.falls)
	local v19

	if fall then
		v19 = data.falls[integer]
	else
		v19 = data.trace
	end

	local normal = v19.normal
	local floor

	if normal == nil then
		floor = false
	else
		floor = normal.Y >= 0.55
	end

	local run = Vector3.new(0, 1, 0)

	if normal and floor then
		run = across(normal) -- inferred equivalent call
	elseif normal then
		local v20 = Vector3.new(0, -1, 0) + normal * normal.Y

		if v20.Magnitude > 0.2 then
			run = v20.Unit
		else
			run = across(normal) -- inferred equivalent call
		end
	end

	local v20 = {
		part = part,
		origin = data.origin,
		dir = data.dir,
		prof = 0,
		fall = 0,
		t0 = 0,
		tEnd = 0,
		hit = 0,
		normal = 0,
		jit = 0,
		run = 0,
		floor = 0,
		burn = 0,
		scale = 0,
		roll = 0,
		yaw = 0,
		smoke = false,
		lift = 0,
		q = -1,
		tq = -1,
		size = Vector3.new(0, 0, 0)
	}
	local prof

	if fall then
		prof = v11[data.fallPicks[integer]]
	else
		prof = FlameStream.SPRAY
	end

	v20.prof = prof
	v20.fall = fall
	v20.t0 = p - p2
	v20.tEnd = v19.tEnd
	v20.hit = v19.hit
	v20.normal = normal
	v20.jit = random:NextUnitVector()
	v20.run = run
	v20.floor = floor
	v20.burn = not floor and (normal and 0.6 or 0) or random:NextNumber(v7[1], v7[2])
	local scale

	if fall then
		scale = random:NextNumber(v8[1], v8[2])
	else
		scale = random:NextNumber(0.7, 1.25)
	end

	v20.scale = scale
	v20.roll = CFrame.Angles(random:NextNumber(0, 6.28), random:NextNumber(0, 6.28), random:NextNumber(0, 6.28))
	v20.yaw = random:NextNumber(0, 6.28)
	table.insert(v17, v20)

	if v13[part] then
		v13[part] = nil
		part.Material = Enum.Material.Neon
	end
end

function FlameVisuals.own(origin: Vector3, dir: Vector3, flag: boolean)
	if flag then
		local rate = Quality.mobile and 52.5 or 75
		local v19 = if Quality.mobile then v18 else v15
		local v20 = jetFor("own", origin, dir, rate, v19)
		local now = os.clock()
		v20.origin = origin
		v20.dir = dir
		v20.last = now

		if v20.last - v20.tracedAt >= (Quality.mobile and 0.08 or 0.05) then
			v20.trace = FlameStream.trace(origin, dir, cast)
			v20.tracedAt = v20.last
		end

		if v20.last - v20.fellAt >= 0.1 then
			v20.falls = traceFalls(origin, dir, v20.fallPicks)
			v20.fellAt = v20.last
		end
	else
		dropJet("own") -- inferred equivalent call
	end
end

local function nozzleOf(player, vector3: Vector3)
	local character = player.Character
	local flamethrower = character and character:FindFirstChild("Flamethrower")
	local handle = flamethrower and flamethrower:FindFirstChild("Handle")
	local muzzleAttachment = handle and handle:FindFirstChild("MuzzleAttachment")

	if
		muzzleAttachment
		and muzzleAttachment:IsA("Attachment")
		and (muzzleAttachment.WorldPosition - vector3).Magnitude < 6
	then
		return muzzleAttachment.WorldPosition
	end

	return vector3
end

local function onSpray(p, vector3: Vector3, dir: Vector3)
	if p == Players.LocalPlayer then
		return
	end

	local origin = nozzleOf(p, vector3)
	local detail = Quality.detail(origin)
	local v19 = v16[p]

	if detail <= 0 then
		if v19 and not v19.far then
			dropJet(p) -- inferred equivalent call
			v19 = nil
		end

		if not v19 then
			v16[p] = {
				origin = origin,
				dir = dir,
				far = true,
				trace = { hit = nil, normal = nil, tEnd = 0 },
				tracedAt = 0,
				falls = {},
				fallPicks = {},
				fellAt = 0,
				last = os.clock(),
				owed = 0,
				rate = 0,
				lightSpec = lightSpec,
				nozzle = nil,
				splash = nil
			}
			return
		end

		local now = os.clock()
		v19.origin = origin
		v19.dir = dir
		v19.last = now
	else
		if v19 and v19.far then
			v16[p] = nil
		end

		local fallPicks = if detail >= 0.75 then v15 else v18
		local v20 = jetFor(p, origin, dir, math.max(detail, 0.3) * 50, fallPicks)

		local now = os.clock()
		v20.origin = origin
		v20.dir = dir
		v20.last = now
		v20.rate = math.max(detail, 0.3) * 50
		v20.fallPicks = fallPicks
		v20.trace = FlameStream.trace(origin, dir, cast)
		v20.tracedAt = v20.last
		v20.falls = traceFalls(origin, dir, fallPicks)
		v20.fellAt = v20.last
	end
end
remotes:WaitForChild("FlameSprayU").OnClientEvent:Connect(onSpray)

Players.PlayerRemoving:Connect(dropJet)

local v19 = {}
local v20 = {}

local object = setmetatable({}, { __mode = "k" })

local function paint(state, p: number, color4: Color3?, p2: number, size: Vector3) -- 2 equivalent calls inferred from this helper
	if p ~= state.q then
		state.q = p
		state.part.Color = color4 or v4[p]
	end

	local tq = math.floor(p2 * 16 + 0.5)

	if tq ~= state.tq then
		state.tq = tq
		state.part.Transparency = tq / 16
	end

	if (size - state.size).Magnitude > 0.06 then
		state.size = size
		state.part.Size = size
	end
end

local function stepJets(now: number, dt: number)
	for k, v21 in v16 do
		if k ~= "own" then
			if now - v21.last > 0.3 then
				dropJet(k) -- inferred equivalent call
				continue
			elseif v21.far then
				VoxelSound.flamerAt(k, v21.origin)
				continue
			else
				v21.origin = nozzleOf(k, v21.origin)
			end
		end

		v21.owed += v21.rate * dt
		local owed = math.floor(v21.owed)
		v21.owed -= owed

		for i = 1, owed do
			emit(v21, now, dt * (i - 1) / owed)
		end

		local trace = v21.trace
		local nozzle = v21.nozzle
		local splash = v21.splash

		if nozzle and splash then
			local v22 = Detail.low and 1 or math.sin(now * 31) * 0.15 * math.sin(now * 17) + 0.85
			lampAt( -- inferred equivalent call
				nozzle,
				FlameStream.at(v21.origin, v21.dir, (math.min(v21.lightSpec.out / FlameStream.SPEED, trace.tEnd)))
			)
			lampBright(nozzle, v21.lightSpec.brightness * v22) -- inferred equivalent call
			local hit = trace.hit
			local normal = trace.normal
			local v23 = hit ~= nil

			if splash.on ~= v23 then
				splash.on = v23
				splash.light.Enabled = v23
			end

			if hit and normal then
				lampAt(splash, hit + normal * 1.5) -- inferred equivalent call
				lampBright(splash, v6.brightness * v22) -- inferred equivalent call
			end
		end

		if k ~= "own" then
			VoxelSound.flamerAt(k, v21.origin)
		end
	end

	local v21 = 1

	while v21 <= #v17 do
		local v22 = v17[v21]
		local v23 = now - v22.t0
		local life = v22.prof.life

		local v24 = nil
		local v25 = nil
		local v26

		if v23 < v22.tEnd then
			local radius = FlameStream.radius(v23, v22.prof)
			v26 = FlameStream.at(v22.origin, v22.dir, v23, v22.prof) + v22.jit * (radius * 0.55)

			if v22.fall then
				local size = Vector3.new(1, 1, 1) * v22.scale
				local v27 = shade(math.min(v23 / 0.6, 1) * 0.3 + 0.3) -- inferred equivalent call

				if v27 ~= v22.q then
					v22.q = v27
					v22.part.Color = v4[v27]
				end

				if v22.tq ~= 2 then
					v22.tq = 2
					v22.part.Transparency = 0.125
				end

				if (size - v22.size).Magnitude > 0.06 then
					v22.size = size
					v22.part.Size = size
				end
			else
				local size = Vector3.new(1, 1, 1) * ((0.28 + v23 * 1.42 / life) * v22.scale)
				paint(v22, shade(v23 / life), nil, 0.1 + v23 * 0.25 / life, size) -- inferred equivalent call
			end

			table.insert(v19, v22.part)
			table.insert(v20, v25 or CFrame.new(v26) * v22.roll)
			v21 += 1
		else
			local v27 = v23 - v22.tEnd

			if v22.burn + 0.55 < v27 then
				v22.part.Transparency = 1
				v22.part.CFrame = cframe
				table.insert(v12, v22.part)

				v17[v21] = v17[#v17]
				v17[#v17] = nil
			else
				local v28

				if v22.fall then
					v28 = v22.scale * 2.2
				else
					v28 = (0.28 + v22.tEnd * 1.42 / life) * v22.scale
				end

				local hit = v22.hit
				local normal = v22.normal
				local v29 = v27 < v22.burn
				local v30

				if v29 then
					v30 = v27 / math.max(v22.burn, 0.001)
				else
					v30 = (v27 - v22.burn) / 0.55
				end

				if hit and normal and v22.floor then
					local v31 = (1 - math.exp(v27 * -5)) * 2.2

					if not v29 then
						v22.lift += dt * 2.5
					end

					v26 = hit + normal * (v22.lift + 0.12) + v22.run * v31

					if v29 then
						local v32 = v28 * (v30 * 0.3 + 1.1)
						local v35 = v28 * (math.abs((math.sin(now * 13 + v22.yaw * 3))) * 0.25 + 0.3) * (1 - v30 * 0.5)
						v24 = Vector3.new(v32, v35, v32)
						v26 += normal * (v35 * 0.5)
						v25 = CFrame.new(v26) * CFrame.Angles(0, v22.yaw, 0)
					end
				elseif hit and normal then
					local v31 = math.min(v27, v22.burn) * 5

					if not v29 then
						v22.lift += dt * 2.5
					end

					v26 = hit + normal * (v22.lift + 0.3) + v22.run * v31 + v22.jit * 0.25
				else
					v22.lift += dt * 3
					v26 = FlameStream.at(v22.origin, v22.dir, v22.tEnd, v22.prof) + v22.jit * (v22.prof.r1 * 0.55) + Vector3.new(0, v22.lift, 0)
				end

				if v29 then
					if not v25 then
						v24 = Vector3.new(1, 1, 1) * (v28 * (1 - v30 * 0.3))
					end

					paint(v22, shade(v30 * 0.4 + 0.5), nil, v30 * 0.4 + 0.35, v24) -- inferred equivalent call
				else
					if not v22.smoke then
						v22.smoke = true
						v22.part.Material = Enum.Material.SmoothPlastic
						v13[v22.part] = true
						v22.q = -1
					end

					local size = Vector3.new(1, 1, 1) * (v28 * 0.8 + (v22.scale * 2.4 - v28 * 0.8) * v30)
					local v31 = v30 * 0.5 + 0.5

					if v22.q ~= 17 then
						v22.q = 17
						v22.part.Color = color or v4[17]
					end

					local tq = math.floor(v31 * 16 + 0.5)

					if tq ~= v22.tq then
						v22.tq = tq
						v22.part.Transparency = tq / 16
					end

					if (size - v22.size).Magnitude > 0.06 then
						v22.size = size
						v22.part.Size = size
					end
				end

				table.insert(v19, v22.part)
				table.insert(v20, v25 or CFrame.new(v26) * v22.roll)
				v21 += 1
			end
		end
	end
end

local v21 = {}
local tongues = {}

local function startBurn(k, humanoidRootPart)
	local tongues2 = {}
	local seeds = {}

	for i = 1, 7 do
		local bodyFlame = table.remove(tongues)

		if not bodyFlame then
			bodyFlame = Instance.new("Part")
			bodyFlame.Name = "BodyFlame"
			bodyFlame.Anchored = true
			bodyFlame.CanCollide = false
			bodyFlame.CanQuery = false
			bodyFlame.CanTouch = false
			bodyFlame.CastShadow = false
			bodyFlame.Material = Enum.Material.Neon
			local smooth = Enum.SurfaceType.Smooth
			local smooth2 = Enum.SurfaceType.Smooth
			bodyFlame.TopSurface = smooth
			bodyFlame.BottomSurface = smooth2
			bodyFlame.Transparency = 1
			bodyFlame.CFrame = cframe
			bodyFlame.Parent = voxelFlames
		end

		bodyFlame.Material = Enum.Material.Neon
		tongues2[i] = bodyFlame
		seeds[i] = random:NextNumber(0, 10)
	end

	local count = 0

	for _, v22 in v21 do
		if v22.lamp then
			count += 1
		end
	end

	local lamp

	if not (Quality.potato or not (count < v3)) then
		lamp = takeLamp(v9)
	end

	local v22 = {
		root = humanoidRootPart,
		tongues = tongues2,
		seeds = seeds,
		lamp = lamp,
		shown = true
	}
	v21[k] = v22
	return v22
end

local function endBurn(k) -- 2 equivalent calls inferred from this helper
	local v22 = v21[k]

	if not v22 then
		return
	end

	for _, tongue in v22.tongues do
		tongue.Transparency = 1
		tongue.CFrame = cframe
		object[tongue] = nil
		table.insert(tongues, tongue)
	end

	giveLamp(v22.lamp) -- inferred equivalent call
	v21[k] = nil
end

local burningTint = Instance.new("ColorCorrectionEffect")
burningTint.Name = "BurningTint"
burningTint.Enabled = false
burningTint.Parent = Lighting

local function burning(instance, serverTimeNow: number): boolean -- 1 equivalent call inferred from this helper
	local burning2 = instance:GetAttribute("Burning")
	return typeof(burning2) == "number" and serverTimeNow < burning2
end

local v22 = {}
local function watch(model)
	if not model:IsA("Model") then
		return
	end

	local function changed() -- 1 equivalent call inferred from this helper
		if typeof(model:GetAttribute("Burning")) == "number" then
			v22[model] = true
		end
	end
	model:GetAttributeChangedSignal("Burning"):Connect(changed)
	changed() -- inferred equivalent call
end
local function watchPlayer(player) -- 1 equivalent call inferred from this helper
	if player.Character then
		watch(player.Character)
	end

	player.CharacterAdded:Connect(watch)
end

local v23 = false

for _, v24 in Players:GetPlayers() do
	watchPlayer(v24) -- inferred equivalent call
end

Players.PlayerAdded:Connect(watchPlayer)
local v24 = { folder = nil }

local v25 = 0
local set = {}
local function scanBodies(now: number)
	if now < v25 then
		return
	end

	v25 = now + 0.2
	local botRigs = workspace:FindFirstChild("BotRigs")

	if botRigs ~= v24.folder then
		v24.folder = botRigs

		if botRigs then
			botRigs.ChildAdded:Connect(watch)

			for _, child in botRigs:GetChildren() do
				watch(child)
			end
		end
	end

	local serverTimeNow = workspace:GetServerTimeNow()
	table.clear(set)

	for k in v22 do
		if
			(botRigs ~= nil and k.Parent == botRigs or Players:GetPlayerFromCharacter(k) ~= nil)
			and burning(k, serverTimeNow) -- inferred equivalent call
		then
			local humanoidRootPart = k:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
				set[k] = true
				local v26 = v21[k]

				if v26 then
					v26.root = humanoidRootPart
				else
					startBurn(k, humanoidRootPart)
				end
			end

			continue
		end

		v22[k] = nil
	end

	for k in v21 do
		if not set[k] then
			endBurn(k) -- inferred equivalent call
		end
	end
end

local function stepBodies(now: number)
	local character = Players.LocalPlayer.Character
	local currentCamera = workspace.CurrentCamera
	local enabled = false

	for k, v26 in v21 do
		if v26.root:IsDescendantOf(workspace) then
			local position = v26.root.Position
			local lamp = v26.lamp

			if lamp then
				lampAt(lamp, position) -- inferred equivalent call
				lampBright(lamp, v9.brightness * (Detail.low and 0.9 or math.sin(now * 23) * 0.2 + 0.8)) -- inferred equivalent call
			end

			enabled = k == character or enabled

			if
				k == character and (currentCamera.CFrame.Position - position).Magnitude < 3
				or Quality.detail(position) <= 0
			then
				if v26.shown then
					v26.shown = false

					for _, tongue in v26.tongues do
						tongue.Transparency = 1
						object[tongue] = nil
					end
				end
			else
				v26.shown = true

				if Detail.onScreen(position, 4) then
					for k2, tongue in v26.tongues do
						local seed = v26.seeds[k2]

						local v27 = (now * 1.6 + seed) % 1
						local v28 = seed * 2.4 + now * 0.7
						local v29 = (1 - v27 * 0.5) * 0.7
						local v30 = position + Vector3.new(math.cos(v28) * v29, v27 * 4.2 + -1.8, math.sin(v28) * v29)
						local size = (0.9 - v27 * 0.6) * (math.sin(now * 29 + seed) * 0.15 + 0.85)

						local v31 = object[tongue]

						if not v31 then
							v31 = { q = -1, tq = -1, size = -1 }
							object[tongue] = v31
						end

						if math.abs(size - v31.size) * 1.4 > 0.06 then
							v31.size = size
							tongue.Size = Vector3.new(size, size * 1.4, size)
						end

						local v32 = shade(v27 * 0.75 + 0.15) -- inferred equivalent call

						if v32 ~= v31.q then
							v31.q = v32
							tongue.Color = v4[v32]
						end

						local tq = math.floor((v27 * 0.8 * v27 + 0.1) * 16 + 0.5)

						if tq ~= v31.tq then
							v31.tq = tq
							tongue.Transparency = tq / 16
						end

						table.insert(v19, tongue)
						table.insert(v20, CFrame.new(v30) * CFrame.Angles(0, v28, math.sin(now * 11 + seed) * 0.3))
					end
				end
			end
		else
			endBurn(k) -- inferred equivalent call
		end
	end

	if v23 ~= enabled then
		v23 = enabled
		burningTint.Enabled = enabled
	end

	if enabled then
		local v26 = math.sin(now * 9) * 0.5 + 0.5
		burningTint.TintColor = Color3.new(1, 1, 1):Lerp(color3, v26 * 0.4 + 0.6)
		burningTint.Contrast = v26 * 0.05 + 0.05
	end
end

RunService.RenderStepped:Connect(function(dt)
	local now = os.clock()
	table.clear(v19)
	table.clear(v20)

	if next(v16) ~= nil or #v17 > 0 then
		stepJets(now, dt)
	end

	scanBodies(now)

	if next(v21) ~= nil or v23 then
		stepBodies(now)
	end

	if #v19 > 0 then
		workspace:BulkMoveTo(v19, v20, Enum.BulkMoveMode.FireCFrameChanged)
	end
end)

return FlameVisuals