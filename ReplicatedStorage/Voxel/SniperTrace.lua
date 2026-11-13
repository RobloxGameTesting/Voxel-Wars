local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local Quality = require(Voxel:WaitForChild("Quality"))
local Ballistics = require(Voxel:WaitForChild("Ballistics"))

local v = { world = 0.3, minPx = 3.5, maxPx = 16, long = 2.6 }
local color = Color3.fromRGB(255, 244, 200)

local v2 = {
	{
		world = 0.16,
		minPx = 2.5,
		maxPx = 16,
		color = Color3.fromRGB(255, 253, 240),
		bright = 6,
		alpha = 0,
		z = 0.03,
		glow = false
	},
	{
		world = 0.42,
		minPx = 5,
		maxPx = 34,
		color = Color3.fromRGB(255, 222, 110),
		bright = 3,
		alpha = 0.15,
		z = 0.02,
		glow = true
	},
	{
		world = 1.1,
		minPx = 11,
		maxPx = 72,
		color = Color3.fromRGB(255, 140, 40),
		bright = 1.6,
		alpha = 0.45,
		z = 0.01,
		glow = true
	}
}

local Terrain = workspace:WaitForChild("Terrain")

local function beam(p, attachment, color2: Color3, brightness: number, z: number, texture: string?)
	local beam2 = Instance.new("Beam")
	beam2.Attachment0 = p
	beam2.Attachment1 = attachment
	beam2.FaceCamera = false
	beam2.Segments = 1
	beam2.LightEmission = 1
	beam2.LightInfluence = 0
	beam2.Brightness = brightness
	beam2.ZOffset = z
	beam2.Color = ColorSequence.new(color2)

	if texture then
		beam2.Texture = texture
		beam2.TextureMode = Enum.TextureMode.Stretch
		beam2.TextureLength = 1
		beam2.TextureSpeed = 0
	end

	beam2.Enabled = false
	beam2.Parent = p
	return beam2
end

local function attachment(name: string) -- 2 equivalent calls inferred from this helper
	local attachment2 = Instance.new("Attachment")
	attachment2.Name = name
	attachment2.Parent = Terrain
	return attachment2
end

local sniperRounds = Instance.new("Folder")
sniperRounds.Name = "SniperRounds"
sniperRounds.Parent = workspace

local function slugPart()
	local sniperRound = Instance.new("Part")
	sniperRound.Name = "SniperRound"
	sniperRound.Shape = Enum.PartType.Cylinder
	sniperRound.Material = Enum.Material.Neon
	sniperRound.Color = color
	sniperRound.Anchored = true
	sniperRound.CanCollide = false
	sniperRound.CanQuery = false
	sniperRound.CanTouch = false
	sniperRound.CastShadow = false
	sniperRound.Size = Vector3.new(v.world * v.long, v.world, v.world)
	sniperRound.Transparency = 1
	sniperRound.Parent = sniperRounds
	return sniperRound
end

local v3 = {}
local v4 = {}

for i = 1, Quality.cap(12) do
	local tails = {}
	local heads = {}
	local beams = {}

	for j = 1, 2 do
		local attachment2 = attachment("SniperStreakTail") -- inferred equivalent call
		local attachment3 = attachment("SniperStreakHead") -- inferred equivalent call
		tails[j] = attachment2
		heads[j] = attachment3
		beams[j] = {}

		for k, v5 in v2 do
			beams[j][k] = beam(
				tails[j],
				heads[j],
				v5.color,
				v5.bright * 0.8,
				v5.z,
				v5.glow and "rbxassetid://138156480753804" or nil
			)
		end
	end

	v3[i] = {
		tails = tails,
		heads = heads,
		beams = beams,
		slug = slugPart(),
		slugOn = false,
		from = Vector3.new(0, 0, 0),
		to = Vector3.new(0, 0, 0),
		flight = 0,
		age = 0,
		strength = 1,
		speed = 0,
		arc = nil,
		sag = 0,
		turns = { CFrame.identity, CFrame.identity }
	}
end

local function hide(state)
	for _, beam2 in state.beams do
		for _, v5 in beam2 do
			if v5.Enabled then
				v5.Enabled = false
			end
		end
	end

	if state.slugOn then
		state.slugOn = false
		state.slug.Transparency = 1
	end
end

local function release(p) -- 1 equivalent call inferred from this helper
	hide(p)
	table.insert(v3, p)
end

local function point(data, value: number)
	local arc = data.arc

	if not arc or value <= 0 or value >= 1 then
		return data.from + (data.to - data.from) * math.clamp(value, 0, 1)
	end

	local v5 = value * data.flight
	local v6 = data.to - data.from
	local v7 = Ballistics.travelled(v5, data.speed, arc) / v6.Magnitude

	local v8 = -Ballistics.position(Vector3.new(0, 0, 0), Vector3.new(1, 0, 0), v5, data.speed, arc).Y
	return data.from + v6 * v7 + Vector3.new(0, data.sag * v7 - v8, 0)
end

local function seq(alpha: number)
	return NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.55, (math.min(1, alpha + (1 - alpha) * 0.45))),
		NumberSequenceKeypoint.new(1, alpha)
	})
end

local v5 = {}

for k, v6 in v2 do
	v5[k] = seq(v6.alpha)
end

local function width(value: number, p, magnitude: number, p2: number, p3: number) -- 3 equivalent calls inferred from this helper
	local v6 = p2 * magnitude
	return (math.clamp(value, p.minPx * p3 * v6, p.maxPx * p3 * v6))
end

local cframe = CFrame.Angles(0, 1.5707963267948966, 0)

local function place(state, currentCamera): boolean
	local age = state.age
	local v6 = math.max(state.flight, 0.06)
	local v7 = age - v6
	local v8 = math.min(v6 * 0.45, 0.06)

	if v8 <= v7 then
		return false
	end

	local position = currentCamera.CFrame.Position
	local v9 = math.max(currentCamera.ViewportSize.Y, 1)
	local v10 = math.tan(math.rad(currentCamera.FieldOfView) / 2) * 2 / v9
	local v11 = v9 / 1080
	local v12 = point(state, age / v6)
	local v13 = point(state, (age - v8) / v6)

	if (v12 - v13).Magnitude > 0.5 then
		local magnitude = (v13 - position).Magnitude
		local magnitude2 = (v12 - position).Magnitude

		for i = 1, 2 do
			local turn = state.turns[i]
			state.tails[i].WorldCFrame = turn + v13
			state.heads[i].WorldCFrame = turn + v12

			for k, v14 in v2 do
				local v15 = state.beams[i][k]
				v15.Width0 = width(v14.world * 0.35, v14, magnitude, v10, v11) * state.strength -- inferred equivalent call
				v15.Width1 = width(v14.world, v14, magnitude2, v10, v11) * state.strength -- inferred equivalent call

				if v15.Enabled then
					continue
				end

				v15.Transparency = v5[k]
				v15.Enabled = true
			end
		end

		if v7 < 0 then
			local v14 = width(v.world, v, magnitude2, v10, v11) * state.strength -- inferred equivalent call
			state.slug.Size = Vector3.new(v14 * v.long, v14, v14)
			state.slug.CFrame = CFrame.lookAt(v12, v12 + (v12 - v13)) * cframe

			if not state.slugOn then
				state.slugOn = true
				state.slug.Transparency = 0
			end
		elseif state.slugOn then
			state.slugOn = false
			state.slug.Transparency = 1
		end
	else
		hide(state)
	end

	return true
end

local v6 = false
local function step(p: number)
	local currentCamera = workspace.CurrentCamera
	local v7 = math.min(p, 0.025)

	for i = #v4, 1, -1 do
		local v8 = v4[i]
		v8.age += v7

		if place(v8, currentCamera) then
			continue
		end

		table.remove(v4, i)
		release(v8) -- inferred equivalent call
	end

	if #v4 == 0 and v6 then
		v6 = false
		RunService:UnbindFromRenderStep("SniperTrace")
	end
end

local SniperTrace = {}

function SniperTrace.scopedStart(cframe2: CFrame)
	return cframe2 * Vector3.new(0, -0.03, -4)
end

function SniperTrace.fire(from: Vector3, to: Vector3, flight: number, value: number?, p)
	local v7 = typeof(from) == "Vector3" and typeof(to) == "Vector3"
	assert(v7, "SniperTrace.fire: from/to must be Vector3")
	local v8 = type(flight) == "number" and flight >= 0
	assert(v8, "SniperTrace.fire: flight must be a number >= 0")
	local v9 = to - from
	local magnitude = v9.Magnitude

	if magnitude < 1 then
		return
	end

	local v10 = table.remove(v3) or table.remove(v4, 1)
	assert(v10, "SniperTrace: empty pool")
	hide(v10)
	v10.from = from
	v10.to = to
	v10.flight = flight
	v10.strength = value or 1
	local arc

	if not (p == false or flight <= 0) then
		arc = p or Ballistics.RIFLE_ARC
	end

	v10.arc = arc

	if arc then
		v10.speed = (math.exp(arc.drag * magnitude) - 1) / (arc.drag * flight)
		v10.sag = -Ballistics.position(Vector3.new(0, 0, 0), Vector3.new(1, 0, 0), flight, v10.speed, arc).Y
	end

	local unit = v9.Unit
	local cross = unit:Cross(Vector3.new(0, 1, 0))
	local vector = cross.Magnitude < 0.001 and Vector3.new(1, 0, 0) or cross.Unit
	local cross2 = vector:Cross(unit)
	v10.turns[1] = CFrame.fromMatrix(Vector3.new(0, 0, 0), unit, (cross2 + vector).Unit)
	v10.turns[2] = CFrame.fromMatrix(Vector3.new(0, 0, 0), unit, (cross2 - vector).Unit)
	table.insert(v4, v10)

	v10.age = 1 / 60
	place(v10, workspace.CurrentCamera)
	v10.age = 0

	if not v6 then
		v6 = true

		RunService:BindToRenderStep("SniperTrace", Enum.RenderPriority.Camera.Value + 5, step)
	end
end

return SniperTrace