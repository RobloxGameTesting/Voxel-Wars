local RunService = game:GetService("RunService")

local Quality = require(script.Parent:WaitForChild("Quality"))
local Detail = require(script.Parent:WaitForChild("Detail"))
local Ballistics = require(script.Parent:WaitForChild("Ballistics"))

local cap = Quality.cap(96)

local color = Color3.fromRGB(255, 240, 235)

local color2 = Color3.fromRGB(230, 100, 120)

local v = {
	coreWorld = 0.11,
	coreMin = 3.2,
	coreMax = 19,
	rimWorld = 0.8,
	rimMin = 8,
	rimMax = 26,
	rimColor = Color3.fromRGB(245, 120, 85),
	streak = 46
}

local v2 = {
	coreWorld = 0.1,
	coreMin = 3.2,
	coreMax = 18,
	rimWorld = 0.75,
	rimMin = 9,
	rimMax = 26,
	rimColor = Color3.fromRGB(240, 90, 110),
	streak = 60
}

local colorSequence = ColorSequence.new(color2)
local colorSequence2 = ColorSequence.new(v.rimColor)
local colorSequence3 = ColorSequence.new(v2.rimColor)

local Terrain = workspace.Terrain

local function fade(p: number, p2: number)
	return NumberSequence.new({
		NumberSequenceKeypoint.new(0, ((math.min)(1, p + p2))),
		NumberSequenceKeypoint.new(0.15, p),
		NumberSequenceKeypoint.new(1, p)
	})
end

local transparency2 = fade(0, 0.15)
local transparency3 = fade(0.3, 0.15)
local v3 = fade(0, 0.15)

local function beam(tracerTail, tracerHead, color3: Color3, transparency, brightness: number, zOffset: number, texture: string?) -- 1 equivalent call inferred from this helper
	local beam2 = Instance.new("Beam")
	beam2.Attachment0 = tracerTail
	beam2.Attachment1 = tracerHead
	beam2.FaceCamera = true
	beam2.Segments = 1
	beam2.LightEmission = 1
	beam2.LightInfluence = 0
	beam2.Brightness = brightness
	beam2.ZOffset = zOffset
	beam2.Color = ColorSequence.new(color3)
	beam2.Transparency = transparency

	if texture then
		beam2.Texture = texture
		beam2.TextureMode = Enum.TextureMode.Stretch
		beam2.TextureLength = 1
		beam2.TextureSpeed = 0
	end

	beam2.Enabled = false
	beam2.Parent = tracerTail
	return beam2
end

local style2 = {
	coreWorld = 0.07,
	coreMin = 2.2,
	coreMax = 14,
	rimWorld = 0.5,
	rimMin = 6,
	rimMax = 20,
	rimColor = color2,
	streak = 32
}

local v4 = {}
local v5 = {}

for i = 1, cap do
	local tracerTail = Instance.new("Attachment")
	tracerTail.Name = "TracerTail"
	tracerTail.Parent = Terrain
	local tracerHead = Instance.new("Attachment")
	tracerHead.Name = "TracerHead"
	tracerHead.Parent = Terrain
	v4[i] = {
		tail = tracerTail,
		head = tracerHead,
		core = beam(tracerTail, tracerHead, color, transparency2, 3, 0.01), -- inferred equivalent call
		rim = beam(tracerTail, tracerHead, color2, transparency3, 2, 0, "rbxassetid://138156480753804"),
		from = Vector3.new(0, 0, 0),
		to = Vector3.new(0, 0, 1),
		dir = Vector3.new(0, 0, 1),
		length = 0,
		t0 = 0,
		own = false,
		aimed = false,
		free = false,
		base = Vector3.new(0, 0, 0),
		eye0 = Vector3.new(0, 0, 0),
		flight = 0,
		aimLook = false,
		speed = 1000,
		glow = true,
		style = style2,
		streak = 32,
		linger = 0,
		faded = false,
		rimT0 = -1,
		rimT1 = -1,
		coreB = 3,
		thin = false,
		round = nil,
		launch = Vector3.new(0, 0, 1),
		from0 = Vector3.new(0, 0, 0),
		dir0 = Vector3.new(0, 0, 1),
		cw0 = -1,
		cw1 = -1,
		rw0 = -1,
		rw1 = -1,
		rimShown = false
	}
end

local function setCoreBrightness(state, p: number) -- 2 equivalent calls inferred from this helper
	if state.coreB ~= p then
		state.coreB = p
		state.core.Brightness = p
	end
end

local function setAimLook(state, aimLook: boolean) -- 1 equivalent call inferred from this helper
	if state.aimLook == aimLook then
		return
	end

	state.aimLook = aimLook
	local core = state.core
	local transparency = if aimLook then v3 else transparency2
	core.Transparency = transparency
end

local function release(state) -- 1 equivalent call inferred from this helper
	state.core.Enabled = false
	state.rim.Enabled = false
	state.rimShown = false
	table.insert(v4, state)
end

local v6 = nil
local Tracers = {
	["SPEED"] = nil,
	SPEED = 1000,
	setOwnMuzzle = function(callback)
		assert(callback == nil or type(callback) == "function", "Tracers.setOwnMuzzle: expected a function or nil")
		v6 = callback
	end
}

local function liveMuzzle() -- 1 equivalent call inferred from this helper
	local v7 = v6()
	assert(typeof(v7) == "Vector3", "Tracers: own muzzle getter must return a Vector3")
	return v7
end

local view = {
	camera = workspace.CurrentCamera,
	eye = Vector3.new(0, 0, 0),
	perPx = 0,
	pxScale = 0,
	aim = 0
}
local function readView(currentCamera) -- 3 equivalent calls inferred from this helper
	local y = currentCamera.ViewportSize.Y
	assert(y > 0, "Tracers: camera viewport has no height")
	local fieldOfView = currentCamera.FieldOfView
	view.camera = currentCamera
	view.eye = currentCamera.CFrame.Position
	view.perPx = math.tan(math.rad(fieldOfView) * 0.5) * 2 / y
	view.pxScale = y / 1080
	view.aim = math.clamp((76 - fieldOfView) / 6, 0, 1)
	return view
end

local function isOwn(vector3: Vector3): boolean -- 2 equivalent calls inferred from this helper
	return v6 ~= nil and (vector3 - liveMuzzle()).Magnitude <= 2 -- inferred equivalent call
end

local function aimedFlight(magnitude: number, p: number) -- 2 equivalent calls inferred from this helper
	if p == 1000 then
		return (math.clamp(magnitude / 1000, 0.08, 0.14))
	end

	return (math.clamp(magnitude / p, 0.08, 0.18))
end

function Tracers.travelTime(vector3: Vector3, vector3_2: Vector3, value: number?)
	local v7 = value or 1000
	local magnitude = (vector3_2 - vector3).Magnitude

	if isOwn(vector3) and readView(workspace.CurrentCamera).aim >= 1 then -- inferred equivalent call
		return aimedFlight(magnitude, v7) -- inferred equivalent call
	end

	return magnitude / v7
end

local function width(magnitude: number, perPx: number, value: number, p: number, p2: number) -- 4 equivalent calls inferred from this helper
	local v7 = magnitude * perPx
	return (math.clamp(value, p * v7, p2 * v7))
end

local function bow(data, p: number, round: number) -- 2 equivalent calls inferred from this helper
	return Ballistics.position(data.from0, data.launch, Ballistics.flightTime(p, round), round) - (data.from0 + data.dir0 * p)
end

local function place(state, p: number, data): boolean
	if state.own and v6 then
		local from

		if state.free then
			from = state.base + (data.eye - state.eye0)
		else
			from = v6()
			assert(typeof(from) == "Vector3", "Tracers: own muzzle getter must return a Vector3")
		end

		local v7 = state.to - from
		local magnitude = v7.Magnitude

		if magnitude >= 1 then
			local dir = v7 / magnitude
			state.from = from
			state.dir = dir
			state.length = magnitude
		end
	end

	local v7 = state.aimed and 1 or not state.own and 0 or data.aim
	local v8, v9

	if state.aimed then
		local v10 = math.max((state.from - data.eye):Dot(state.dir), 0.3)
		local v11 = state.length / (v10 + state.length)
		local v12 = v11 * p / state.flight
		local v13 = v11 * math.min(0.4, 0.05600000000000001 / state.flight)

		if v11 <= v12 - v13 then
			return false
		end

		local v14 = math.min(v12, v11)
		local v15 = math.clamp(v12 - v13, 0, v11)
		v8 = math.min(v10 * v14 / (1 - v14), state.length)
		v9 = math.min(v10 * v15 / (1 - v15), state.length)
	elseif state.round then
		local round = state.round
		local v10 = p - state.flight

		if state.linger <= v10 then
			return false
		end

		if v10 > 0 then
			local v11 = v10 / state.linger
			state.faded = true
			state.aimLook = false
			state.rimT0 = -1
			state.core.Transparency = fade(v11 * 1 + 0, 0.15)
			state.rim.Transparency = fade(v11 * 0.7 + 0.3, 0.15)
		end

		v8 = math.min(Ballistics.travelled(p, round), state.length)
		v9 = math.max(0, v8 - math.max(state.streak, Ballistics.speedAt(v8, round) * 3 / 60))
	else
		local v10 = state.speed * p

		if state.length + state.speed / 60 <= v10 then
			return false
		end

		v8 = math.min(v10, state.length)
		v9 = math.max(0, v8 - state.streak)
	end

	if v9 > 0 and not state.free then
		state.free = true
		local from = state.from
		local eye = data.eye
		state.base = from
		state.eye0 = eye
	end

	setAimLook(state, v7 >= 0.5) -- inferred equivalent call
	local position = state.from + state.dir * v8
	local position2 = state.from + state.dir * v9

	if state.round then
		position += bow(state, v8, state.round) -- inferred equivalent call
		position2 += bow(state, v9, state.round) -- inferred equivalent call
	end

	state.head.Position = position
	state.tail.Position = position2
	local magnitude = (position2 - data.eye).Magnitude
	local magnitude2 = (position - data.eye).Magnitude
	local style = state.style
	local v10 = math.max(style.coreMin, v7 * 0.7999999999999998 + 2.2)
	local v11 = math.max(style.rimMin, v7 * 0 + 6)
	local v12 = state.thin and 0.5 or 1
	local v13 = width(magnitude, data.perPx, style.coreWorld, v10, style.coreMax) * v12 -- inferred equivalent call
	local v14 = width(magnitude2, data.perPx, style.coreWorld, v10, style.coreMax) * v12 -- inferred equivalent call

	if v13 ~= state.cw0 then
		state.cw0 = v13
		state.core.Width0 = v13
	end

	if v14 ~= state.cw1 then
		state.cw1 = v14
		state.core.Width1 = v14
	end

	local glow = state.glow

	if state.rimShown ~= glow then
		state.rimShown = glow
		state.rim.Enabled = glow
	end

	if glow then
		local v15 = width(magnitude, data.perPx, style.rimWorld, v11, style.rimMax) * v12 -- inferred equivalent call
		local v16 = width(magnitude2, data.perPx, style.rimWorld, v11, style.rimMax) * v12 -- inferred equivalent call

		if v15 ~= state.rw0 then
			state.rw0 = v15
			state.rim.Width0 = v15
		end

		if v16 ~= state.rw1 then
			state.rw1 = v16
			state.rim.Width1 = v16
		end

		local _ = v7 >= 0.5
		local rimT = 0.15

		if rimT ~= state.rimT0 and not state.faded then
			state.rimT0 = rimT
			state.rim.Transparency = fade(0.3, rimT)
		end
	end

	if state.own then
		setCoreBrightness(state, v7 * 1.5 + 3) -- inferred equivalent call
	end

	return true
end

local v7 = {}

local function nthOfStream(at: Vector3, now: number): boolean
	local v8 = nil

	for i = #v7, 1, -1 do
		local v9 = v7[i]

		if now - v9.t > 0.35 then
			table.remove(v7, i)
		elseif not v8 and (v9.at - at).Magnitude <= 4 then
			v8 = v9
		end
	end

	if not v8 then
		table.insert(v7, { at = at, t = now, n = 0 })
		return true
	end

	local v9 = v8.n + 1
	v8.at = at
	v8.t = now
	v8.n = v9
	return v8.n % 3 == 0
end

local function finite(vector3: Vector3): boolean -- 2 equivalent calls inferred from this helper
	return vector3.X == vector3.X
		and vector3.Y == vector3.Y
		and vector3.Z == vector3.Z
		and math.abs(vector3.X) < 1e999
		and math.abs(vector3.Y) < 1e999
		and math.abs(vector3.Z) < 1e999
end

function Tracers.fire(from: Vector3, to: Vector3, value: number?, flag: boolean?, flag2: boolean?, round: number?, flag3: boolean?)
	local v8 = typeof(from) == "Vector3" and typeof(to) == "Vector3"
	assert(v8, "Tracers.fire: from/to must be Vector3")
	local v9

	if value == nil then
		v9 = true
	elseif type(value) == "number" then
		v9 = value > 0
	else
		v9 = false
	end

	assert(v9, "Tracers.fire: speed must be a positive number")
	local v10 = finite(from) and finite(to) -- inferred equivalent call
	assert(v10, "Tracers.fire: non-finite position")
	local v11 = to - from
	local magnitude = v11.Magnitude

	if magnitude < 1 then
		return
	end

	local own = isOwn(from) -- inferred equivalent call

	if not (own or flag3 or nthOfStream(from, os.clock())) then
		return
	end

	local thin = false

	if not own and not flag3 and (Quality.mobile or Quality.potato or Detail.low) then
		local currentCamera = workspace.CurrentCamera
		local v12

		if currentCamera then
			v12 = currentCamera.CFrame.Position
		else
			v12 = from
		end

		local v13 = from + v11 * math.clamp((v12 - from):Dot(v11) / (magnitude * magnitude), 0, 1)

		if Quality.mobile or Quality.potato then
			local v14 = Quality.detail(v13) / Quality.share() * Quality.strainShare()

			if v14 <= 0 or v14 < 1 and v14 < math.random() then
				return
			end
		end

		if Detail.low then
			local tier = Detail.tier(v13, 4)

			if tier >= 3 then
				return
			end

			thin = tier == 2
		end
	end

	local v12 = table.remove(v4) or table.remove(v5, 1)

	local view2 = readView(workspace.CurrentCamera) -- inferred equivalent call
	local dir = v11 / magnitude
	local now = os.clock()
	v12.from = from
	v12.to = to
	v12.dir = dir
	v12.length = magnitude
	v12.t0 = now
	v12.own = own
	v12.thin = thin
	v12.free = false
	local aimed = v12.own

	if aimed then
		if view2.aim >= 1 then
			aimed = not round
		else
			aimed = false
		end
	end

	v12.aimed = aimed
	v12.speed = value or 1000
	v12.flight = aimedFlight(magnitude, v12.speed) -- inferred equivalent call
	v12.round = round

	if round then
		v12.flight = Ballistics.flightTime(magnitude, round)
		v12.speed = magnitude / math.max(v12.flight, 0.001)
		local launch = Ballistics.launch(from, to, round)
		local dir2 = v11 / magnitude
		v12.launch = launch
		v12.from0 = from
		v12.dir0 = dir2
	end

	local v13 = round ~= nil
	local style

	if flag2 then
		style = v
	else
		style = if v13 then v2 else style2
	end

	if v12.style ~= style then
		v12.style = style
		local rim = v12.rim
		local color3

		if flag2 then
			color3 = colorSequence2
		else
			color3 = if v13 then colorSequence3 else colorSequence
		end

		rim.Color = color3
	end

	v12.streak = style.streak
	v12.linger = v13 and 0.3 or 0

	if v12.faded then
		v12.faded = false
		v12.aimLook = false
		v12.rimT0 = -1
		v12.core.Transparency = transparency2
	end

	setCoreBrightness(v12, 3) -- inferred equivalent call
	v12.glow = flag ~= false

	place(v12, 1 / 60, view2)
	v12.core.Enabled = true
	table.insert(v5, v12)
end

RunService:BindToRenderStep("VoxelTracers", Enum.RenderPriority.Camera.Value + 5, function()
	if #v5 == 0 then
		return
	end

	local now = os.clock()
	readView(workspace.CurrentCamera) -- inferred equivalent call

	for i = #v5, 1, -1 do
		local v8 = v5[i]

		if place(v8, now - v8.t0, view) then
			continue
		end

		table.remove(v5, i)
		release(v8) -- inferred equivalent call
	end
end)

return Tracers