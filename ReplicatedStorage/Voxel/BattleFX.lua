local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local WorldConfig = require(script.Parent:WaitForChild("WorldConfig"))
local Quality = require(script.Parent:WaitForChild("Quality"))
local Detail = require(script.Parent:WaitForChild("Detail"))
local VR = require(script.Parent:WaitForChild("VR"))

local meter = WorldConfig.METER
local Grid4x4 = Enum.ParticleFlipbookLayout.Grid4x4

local BattleFX = {}

local voxelAtmosphere = Instance.new("Folder")
voxelAtmosphere.Name = "VoxelAtmosphere"
voxelAtmosphere.Parent = workspace

local random = Random.new()

local function holder(name: string) -- 3 equivalent calls inferred from this helper
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 1
	part.Size = Vector3.new(0.2, 0.2, 0.2)
	part.Parent = voxelAtmosphere
	local attachment = Instance.new("Attachment")
	attachment.Parent = part
	return part, attachment
end

local function emitter(parent, texture: string)
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = texture
	particleEmitter.FlipbookLayout = Grid4x4
	particleEmitter.FlipbookMode = Enum.ParticleFlipbookMode.OneShot
	particleEmitter.FlipbookStartRandom = false
	particleEmitter.LightInfluence = 1
	particleEmitter.Rate = 0
	particleEmitter.LockedToPart = false
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.RotSpeed = NumberRange.new(-15, 15)
	particleEmitter.Parent = parent
	return particleEmitter
end

local function seq(items)
	local numberSequenceKeypoints = {}

	for _, item in items do
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(item[1], item[2]))
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

local function tangentBasis(vector: Vector3) -- 1 equivalent call inferred from this helper
	local unit = vector:Cross(math.abs(vector.Y) < 0.9 and Vector3.new(0, 1, 0) or Vector3.new(1, 0, 0)).Unit
	return unit, vector:Cross(unit).Unit
end

local v = 4

local function low() -- 9 equivalent calls inferred from this helper
	return Quality.mobile or Quality.potato
end

local function tooNear(vector3: Vector3, p: number) -- 4 equivalent calls inferred from this helper
	return Detail.low and Detail.pixels(vector3, p) / Detail.screenY > 0.6
end

local function detail(vector3: Vector3, p: number)
	if v <= 0 then
		return 0
	end

	local currentCamera = workspace.CurrentCamera
	local v2 = not currentCamera and 0 or (vector3 - currentCamera.CFrame.Position).Magnitude / meter

	if v2 >= 220 then
		return 0
	end

	local v3 = v2 <= 60 and 1 or 1 - 0.7 * (v2 - 60) / 160

	if low() then -- inferred equivalent call
		v3 = math.min(v3 * Quality.share(), Quality.detail(vector3))

		if v3 <= 0 then
			return 0
		end
	end

	if Detail.low then
		v3 *= Detail.scale(vector3, p)

		if v3 <= 0 then
			return 0
		end
	end

	v -= 1
	return v3
end

local function floorOf(p: number)
	if low() then -- inferred equivalent call
		return (math.max(2, (math.floor(p * 0.6))))
	end

	return p
end

local parent, parent2 = holder("DustShots") -- inferred equivalent call
local v2 = emitter(parent2, "rbxassetid://15483343964")
v2.EmissionDirection = Enum.NormalId.Front

local function newRings(p: string, texture: string, p2: number)
	local rings = {}

	for i = 1, p2 do
		local name = p .. i
		local part = Instance.new("Part")
		part.Name = name
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.Transparency = 1
		part.Size = Vector3.new(0.2, 0.2, 0.2)
		part.Parent = voxelAtmosphere
		local attachment_2 = Instance.new("Attachment")
		attachment_2.Parent = part

		local v3 = {
			part = part,
			atts = {},
			emitters = {},
			counts = {},
			last = {}
		}

		for j = 1, 12 do
			local attachment = Instance.new("Attachment")
			attachment.Parent = part
			local v4 = emitter(attachment, texture)
			v4.EmissionDirection = Enum.NormalId.Front
			v3.atts[j] = attachment
			v3.emitters[j] = v4
			v3.counts[j] = 0
		end

		rings[i] = v3
	end

	return rings
end

local v3 = newRings("DustSkirt", "rbxassetid://89598700477428", 6)
local v4 = newRings("DustGround", "rbxassetid://15483343964", 4)
local v5 = {}

local function ring(list, vector3: Vector3, vector: Vector3, p: number, p2: number, p3: number, p4: number, p5: number, fn)
	local v6 = (v5[list] or 0) % #list + 1
	v5[list] = v6
	local item = list[v6]
	local unit = tangentBasis(vector) -- inferred equivalent call
	item.part.CFrame = CFrame.fromMatrix(vector3, unit, vector) * CFrame.Angles(
		0,
		random:NextNumber() * 3.141592653589793 * 2,
		0
	)

	for i = 1, 12 do
		local v7 = (i + random:NextNumber() * 0.6) / 12 * 3.141592653589793 * 2
		local vector3_2 = Vector3.new(math.cos(v7), 0, (math.sin(v7)))
		local v8 = vector3_2 * p2 + Vector3.new(0, 1, 0) * p3
		item.atts[i].CFrame = CFrame.lookAt(v8, v8 + vector3_2 + Vector3.new(0, 1, 0) * p4)
		item.counts[i] = 0
	end

	fn(item)

	for i = 0, p - 1 do
		local v7 = math.floor(i * 12 / p) + 1
		item.counts[v7] += 1
	end

	for i = 1, 12 do
		if not (item.counts[i] > 0) or tooNear(item.atts[i].WorldPosition, p5) then -- inferred equivalent call
			continue
		end

		item.emitters[i]:Emit(item.counts[i])
	end
end

local function aim(vector3: Vector3, vector3_2: Vector3) -- 1 equivalent call inferred from this helper
	parent.CFrame = CFrame.lookAt(vector3, vector3 + vector3_2)
end

local transparency = seq({
	{ 0, 1 },
	{ 0.05, 0.2 },
	{ 0.5, 0.45 },
	{ 1, 1 }
})
local transparency2 = seq({
	{ 0, 1 },
	{ 0.06, 0.25 },
	{ 0.6, 0.5 },
	{ 1, 1 }
})
local transparency3 = seq({
	{ 0, 1 },
	{ 0.08, 0.3 },
	{ 0.6, 0.6 },
	{ 1, 1 }
})

for _, v6 in v3 do
	for _, emitter2 in v6.emitters do
		emitter2.Transparency = transparency
		emitter2.Lifetime = NumberRange.new(2.5, 4.5)
		emitter2.SpreadAngle = Vector2.new(12, 4)
		emitter2.Drag = 1.6
		emitter2.RotSpeed = NumberRange.new(-10, 10)
	end
end

for _, v6 in v4 do
	for _, emitter2 in v6.emitters do
		emitter2.Transparency = transparency2
		emitter2.Lifetime = NumberRange.new(2.5, 5)
		emitter2.Drag = 1.2
		emitter2.RotSpeed = NumberRange.new(-8, 8)
		emitter2.SpreadAngle = Vector2.new(15, 6)
		emitter2.Acceleration = Vector3.new(0, 0.25 * meter, 0)
	end
end

v2.Transparency = transparency2
v2.Lifetime = NumberRange.new(2.5, 5)
v2.Drag = 1.2
v2.RotSpeed = NumberRange.new(-8, 8)
v2.SpreadAngle = Vector2.new(180, 180)
v2.Acceleration = Vector3.new(0, -0.4 * meter, 0)
local v6 = {}

local function restyle(p, colorSequence, size, numberRange: NumberRange, vector3: Vector3?)
	local last = p.last
	local v7 = last.color ~= colorSequence
	local v8 = last.size ~= size
	local v9 = last.speed ~= numberRange
	local v10

	if vector3 == nil then
		v10 = false
	else
		v10 = last.accel ~= vector3
	end

	if not (v7 or v8 or v9 or v10) then
		return
	end

	last.color = colorSequence
	last.size = size
	last.speed = numberRange

	if vector3 then
		last.accel = vector3
	end

	for _, emitter2 in p.emitters do
		if v7 then
			emitter2.Color = colorSequence
		end

		if v8 then
			emitter2.Size = size
		end

		if v9 then
			emitter2.Speed = numberRange
		end

		if v10 then
			emitter2.Acceleration = vector3
		end
	end
end

function BattleFX.neutral(color: Color3)
	if color.G > color.B * 1.1 and color.G >= color.R * 0.95 then
		local v7 = 0.3 * color.R + 0.59 * color.G + 0.11 * color.B
		return Color3.new(math.min(v7 * 1.04, 1), v7, v7 * 0.9)
	end

	return color
end

function BattleFX.skirt(vector3: Vector3, vector3_2: Vector3, color: Color3, p: number)
	if low() then -- inferred equivalent call
		return
	end

	local neutral = BattleFX.neutral(color)
	local v7 = detail(vector3, p * 2)

	if v7 <= 0 then
		return
	end

	local v8 = math.max(low() and 2 or 4, (math.floor(math.clamp(p * 0.8 + 8, 8, 24) * v7))) -- inferred equivalent call
	local colorSequence = ColorSequence.new(neutral, neutral:Lerp(Color3.new(0.6, 0.58, 0.55), 0.3))
	local size = seq({
		{ 0, p * 0.35 },
		{ 0.3, p * 0.9 },
		{ 1, p * 1.4 }
	})
	local numberRange = NumberRange.new(p * 1.2, p * 2.6)
	local v9 = vector3_2 * (0.4 * meter)
	ring(v3, vector3, vector3_2, v8, p * 0.25, p * 0.12, 0.08, p * 0.9, function(p2)
		restyle(p2, colorSequence, size, numberRange, v9)
	end)
end

function BattleFX.billow(vector3: Vector3, color: Color3, value: number, flag: boolean)
	local neutral = BattleFX.neutral(color)
	local v7 = detail(vector3, math.clamp(value, 2, 30) * 2)

	if v7 <= 0 then
		return
	end

	local v8 = math.clamp(value, 2, 30)
	local v9 = math.max(low() and 2 or 3, (math.floor(math.clamp(v8 * 0.9 + 4, 4, 24) * v7))) -- inferred equivalent call
	local colorSequence = ColorSequence.new(neutral)
	local size = seq({
		{ 0, v8 * 0.3 },
		{ 0.3, v8 * 0.75 },
		{ 1, v8 * 1.05 }
	})

	if flag then
		local numberRange = NumberRange.new(v8 * 0.6, v8 * 1.6)
		ring(v4, vector3, Vector3.new(0, 1, 0), v9, v8 * 0.3, 0, 0.1, v8 * 0.75, function(p)
			restyle(p, colorSequence, size, numberRange)
		end)
	else
		local numberRange = NumberRange.new(v8 * 0.2, v8 * 0.8)
		local v10 = v6

		if v10.color ~= colorSequence then
			v10.color = colorSequence
			v2.Color = colorSequence
		end

		if v10.size ~= size then
			v10.size = size
			v2.Size = size
		end

		if v10.speed ~= numberRange then
			v10.speed = numberRange
			v2.Speed = numberRange
		end

		for _ = 1, v9 do
			local v11 = vector3 + random:NextUnitVector() * (v8 * 0.35 * random:NextNumber())

			if tooNear(v11, v8 * 0.75) then -- inferred equivalent call
				continue
			end

			aim(v11, random:NextUnitVector()) -- inferred equivalent call
			v2:Emit(1)
		end
	end
end

local v7 = (Vector3.new(1, 0, 0.4)).Unit * 0.5

local v8 = {}

for i = 1, 6 do
	local part, parent3 = holder("SmokeColumn" .. i) -- inferred equivalent call
	local smoke = emitter(parent3, "rbxassetid://89598700477428")
	smoke.EmissionDirection = Enum.NormalId.Top
	smoke.Enabled = false
	v8[i] = {
		part = part,
		smoke = smoke,
		token = 0,
		started = -1e999,
		rate = 0,
		size = 1
	}
end

local function columnRate(data) -- 2 equivalent calls inferred from this helper
	if not Detail.low then
		return data.rate
	end

	local position = data.part.Position

	if tooNear(position, data.size * 0.6) then -- inferred equivalent call
		return 0
	end

	return data.rate * Detail.scale(position, data.size)
end

local total = 0

RunService.Heartbeat:Connect(function(dt)
	v = 4
	total += dt

	if total < 0.25 then
		return
	end

	total = 0

	for _, v9 in v8 do
		if not v9.smoke.Enabled then
			continue
		end

		local rate = columnRate(v9) -- inferred equivalent call

		if math.abs(v9.smoke.Rate - rate) > v9.rate * 0.05 then
			v9.smoke.Rate = rate
		end
	end
end)

function BattleFX.column(position: Vector3, color: Color3, value: number, duration: number, value2: number?, p: number?)
	if low() then -- inferred equivalent call
		return
	end

	local neutral = BattleFX.neutral(color)
	local v9, v10

	if low() then -- inferred equivalent call
		v9 = Quality.detail(position)

		if v9 <= 0 then
			return
		end

		v10 = math.min(6, Quality.cap(6))
	else
		v10 = 6
		v9 = 1
	end

	local v11 = v8[1]

	for i = 1, v10 do
		local v12 = v8[i]

		if v12.smoke.Enabled then
			if v12.started < v11.started then
				v11 = v12
			end
		else
			v11 = v12
			break
		end
	end

	v11.token += 1
	v11.started = os.clock()
	local token = v11.token
	local globalWind = workspace.GlobalWind
	local v12

	if globalWind.Magnitude > 0.5 then
		v12 = globalWind * 0.15
	else
		v12 = v7 * meter
	end

	local smoke = v11.smoke
	local v13 = value2 or 1
	local v14 = math.clamp(value, 1, math.sqrt(v13) * 12)
	local v15 = 0.6 + 0.4 * v13
	smoke.Color = ColorSequence.new(neutral, neutral:Lerp(Color3.new(0.45, 0.45, 0.45), 0.5))
	smoke.Size = seq({
		{ 0, v14 * 0.8 },
		{ 0.4, v14 * 2.2 },
		{ 1, v14 * 3.6 }
	})
	smoke.Transparency = transparency3
	smoke.Lifetime = NumberRange.new(6 * v15, 9 * v15)
	smoke.Speed = NumberRange.new(1.2 * meter * v13, 2.4 * meter * v13)
	smoke.SpreadAngle = Vector2.new(14, 14)
	smoke.Acceleration = Vector3.new(0, 0.35 * meter * v13, 0) + v12
	smoke.Drag = 0.25
	v11.rate = math.clamp(v14 * 0.3 + 1.5, 1.5, 4) * math.max(v9, 0.4)
	v11.size = v14 * 3.6
	v11.part.CFrame = CFrame.new(position)
	smoke.Rate = columnRate(v11) -- inferred equivalent call

	if p and p > 0 then
		if Detail.low then
			v9 = tooNear(position, v14 * 2.2) and 0 or v9 * Detail.scale(position, v11.size) -- inferred equivalent call
		end

		if v9 > 0 then
			if v9 < 1 then
				p = math.max(1, (math.floor(p * v9 + 0.5)))
			end

			smoke:Emit(p)
		end
	end

	smoke.Enabled = true
	task.delay(duration, function()
		if v11.token == token then
			smoke.Enabled = false
		end
	end)
end

local v9 = {}

for i = 1, 4 do
	local _, parent3 = holder("Flash" .. i) -- inferred equivalent call
	local pointLight = Instance.new("PointLight")
	pointLight.Color = Color3.fromRGB(255, 170, 90)
	pointLight.Brightness = 0
	pointLight.Shadows = false
	pointLight.Enabled = false
	pointLight.Parent = parent3
	v9[i] = pointLight
end

local v10 = 1

if Quality.mobile then
	v9[3].Enabled = false
	v9[4].Enabled = false
end

local v11 = {}
local v12 = {}

function BattleFX.flash(position: Vector3, value: number, duration: number, value2: number?)
	if Quality.lowEnd() then
		return
	end

	local v13

	if low() then -- inferred equivalent call
		if Quality.metres(position) > 40 then
			return
		end

		v13 = 2
		v10 = math.min(v10, v13)
	else
		v13 = 4
	end

	local v14 = v9[v10]
	v10 = v10 % v13 + 1
	(v14.Parent and v14.Parent.Parent).CFrame = CFrame.new(position)
	v14.Range = math.clamp(value, 8, 60)
	local v15 = v11[v14]

	if v15 then
		v11[v14] = nil
		v15:Cancel()
	end

	local v16 = (v12[v14] or 0) + 1
	v12[v14] = v16

	if low() then -- inferred equivalent call
		v14.Brightness = (value2 or 8) * 0.6
		v14.Enabled = true
		task.delay(duration * 0.45, function()
			if v12[v14] == v16 then
				v14.Enabled = false
			end
		end)
	else
		v14.Brightness = value2 or 8
		v14.Enabled = true
		local tween = TweenService:Create(
			v14,
			TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Brightness = 0 }
		)
		v11[v14] = tween

		tween.Completed:Connect(function(p)
			if p == Enum.PlaybackState.Completed then
				v14.Enabled = false
			end
		end)
		tween:Play()
	end
end

local blastGrit = Instance.new("ScreenGui")
blastGrit.Name = "BlastGrit"
blastGrit.IgnoreGuiInset = true
blastGrit.ScreenInsets = Enum.ScreenInsets.None
blastGrit.ResetOnSpawn = false
blastGrit.DisplayOrder = -1
blastGrit.Enabled = false
local v13 = 0
local function showGrit(p: number) -- 2 equivalent calls inferred from this helper
	local v14 = os.clock() + p

	if v14 <= v13 then
		return
	end

	v13 = v14
	blastGrit.Enabled = true
	task.delay(p + 0.05, function()
		local now = os.clock()

		if v13 <= now then
			blastGrit.Enabled = false
		end
	end)
end
local frame = Instance.new("Frame")
frame.Size = UDim2.fromScale(1, 1)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 1
frame.Parent = blastGrit
local v14 = {}

for i = 1, 36 do
	local frame2 = Instance.new("Frame")
	frame2.BorderSizePixel = 0
	frame2.AnchorPoint = Vector2.new(0.5, 0.5)
	frame2.BackgroundTransparency = 1
	frame2.Parent = blastGrit
	v14[i] = frame2
end

local frame2 = Instance.new("Frame")
frame2.Size = UDim2.fromScale(1, 1)
frame2.BorderSizePixel = 0
frame2.BackgroundColor3 = Color3.fromRGB(255, 236, 205)
frame2.BackgroundTransparency = 1
frame2.ZIndex = 2
frame2.Parent = blastGrit
task.spawn(function()
	blastGrit.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end)

local blastExposure = Instance.new("ColorCorrectionEffect")
blastExposure.Name = "BlastExposure"
blastExposure.Parent = game:GetService("Lighting")

function BattleFX.glare(value: number, value2: number)
	local v15 = math.clamp(value, 0, 1)

	if v15 > 0.03 then
		frame2.BackgroundTransparency = 1 - v15 * 0.92
		showGrit(v15 * 0.2 + 0.06) -- inferred equivalent call

		TweenService:Create(frame2, TweenInfo.new(v15 * 0.2 + 0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			BackgroundTransparency = 1
		}):Play()
	end

	local v16 = math.clamp(value2, 0, 1)

	if v16 > 0.02 and v16 * 0.35 > blastExposure.Brightness then
		blastExposure.Brightness = v16 * 0.35
		blastExposure.Contrast = v16 * 0.15
		blastExposure.TintColor = Color3.new(1, 1 - v16 * 0.08, 1 - v16 * 0.2)
		TweenService:Create(
			blastExposure,
			TweenInfo.new(v16 * 0.35 + 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Brightness = 0, Contrast = 0, TintColor = Color3.new(1, 1, 1) }
		):Play()
	end
end

function BattleFX.grit(value: number, color: Color3)
	local v15 = math.clamp(value, 0, 1)

	if v15 <= 0.05 then
		return
	end

	local v16 = v15 * 2.5 + 1.5
	showGrit(v16) -- inferred equivalent call
	frame.BackgroundColor3 = color:Lerp(Color3.new(0.25, 0.2, 0.15), 0.35)
	frame.BackgroundTransparency = 1 - v15 * 0.5
	TweenService:Create(frame, TweenInfo.new(v16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		BackgroundTransparency = 1
	}):Play()

	for i = 1, math.floor(v15 * 36 * Quality.share()) do
		local v17 = v14[i]
		local integer = random:NextInteger(3, 14)
		local number = random:NextNumber(0.03, 0.97)
		local number2 = random:NextNumber(0.03, 0.97)
		v17.Size = UDim2.fromOffset(integer, integer)
		v17.Position = UDim2.fromScale(number, number2)
		v17.Rotation = random:NextNumber(0, 90)
		local number3 = random:NextNumber(0.15, 0.45)
		v17.BackgroundColor3 = color:Lerp(Color3.new(number3 * 0.8, number3 * 0.65, number3 * 0.5), 0.6)
		v17.BackgroundTransparency = random:NextNumber(0, 0.25)
		local v18 = v16 * random:NextNumber(0.4, 1)
		TweenService:Create(v17, TweenInfo.new(v18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(number, number2 + random:NextNumber(0.02, 0.08))
		}):Play()
	end
end

local v15 = 0
local v16 = 0
local cframe = nil

local total2 = Vector3.new(0, 0, 0)
local v17 = Vector3.new(0, 0, 0)

local flag = false

local function undoStep()
	if cframe then
		workspace.CurrentCamera.CFrame *= cframe:Inverse()
		cframe = nil
	end
end

local function shakeStep(p: number)
	local v18 = total2.Magnitude > 0.0001 or v17.Magnitude > 0.001

	if v18 then
		local v19 = math.min(p, 1 / 30)
		v17 += (total2 * -256 - v17 * 16) * v19
		total2 += v17 * v19
	else
		total2 = Vector3.new(0, 0, 0)
		v17 = Vector3.new(0, 0, 0)
	end

	if v15 < 0.01 and v16 < 0.01 and not v18 then
		v15 = 0
		v16 = 0
		flag = false
		RunService:UnbindFromRenderStep("VoxelShakeUndo")
		RunService:UnbindFromRenderStep("VoxelShake")
	else
		local now = os.clock()
		local v19 = now * 28
		local v20 = now * 6
		local v21 = Vector3.new(math.noise(v19, 1.7), math.noise(v19, 9.1), math.noise(v19, 4.3)) * v15 + Vector3.new(
			math.noise(v20, 2.1),
			math.noise(v20, 6.4),
			math.noise(v20, 8.8)
		) * v16
		local cframe2 = CFrame.Angles(
			math.noise(v19, 3.3) * v15 * 0.04 + math.noise(v20, 1.1) * v16 * 0.03,
			math.noise(v19, 7.7) * v15 * 0.04 + math.noise(v20, 5.2) * v16 * 0.02,
			math.noise(v19, 5.5) * v15 * 0.06 + math.noise(v20, 3.9) * v16 * 0.04
		)

		local currentCamera = workspace.CurrentCamera
		local v22 = math.clamp(math.tan(math.rad(currentCamera.FieldOfView) * 0.5) / 0.7002075382097097, 0.05, 1)

		if v22 < 1 then
			local orientation, v23, v24 = cframe2:ToOrientation()
			cframe2 = CFrame.fromOrientation(orientation * v22, v23 * v22, v24 * v22)
			v21 *= v22
		end

		local v23 = total2 * v22

		if VR.on() then
			cframe = nil
		else
			cframe = CFrame.new(v21) * cframe2 * CFrame.Angles(v23.X, v23.Y, v23.Z)
			currentCamera.CFrame *= cframe
		end

		v15 *= math.exp(p * -7)
		v16 *= math.exp(p * -1.6)
	end
end

local function wake() -- 3 equivalent calls inferred from this helper
	if flag then
		return
	end

	flag = true
	RunService:BindToRenderStep("VoxelShakeUndo", Enum.RenderPriority.Camera.Value - 2, undoStep)
	RunService:BindToRenderStep("VoxelShake", Enum.RenderPriority.Camera.Value + 2, shakeStep)
end

local function inLobby(): boolean -- 3 equivalent calls inferred from this helper
	local localPlayer = Players.LocalPlayer
	return localPlayer ~= nil and localPlayer.Team == nil
end

function BattleFX.shake(vector3: Vector3, p: number, p2: number, p3: number)
	local currentCamera = workspace.CurrentCamera

	if currentCamera and not inLobby() then -- inferred equivalent call
		local v18 = (vector3 - currentCamera.CFrame.Position).Magnitude / meter
		local v19 = math.clamp(1 - v18 / p2, 0, 1)
		local v20 = math.clamp(1 - v18 / p3, 0, 1)
		v15 = math.max(v15, p * v19 * v19)
		v16 = math.max(v16, p * 0.35 * v20 * v20)
		wake() -- inferred equivalent call
	end
end

function BattleFX.jolt(p: number)
	if workspace.CurrentCamera and not inLobby() then -- inferred equivalent call
		v15 = math.max(v15, p)
		wake() -- inferred equivalent call
	end
end

function BattleFX.kick(vector3: Vector3, p: number, p2: number)
	local currentCamera = workspace.CurrentCamera

	if currentCamera and not inLobby() then -- inferred equivalent call
		local cframe2 = currentCamera.CFrame
		local v18 = vector3 - cframe2.Position
		local v19 = math.clamp(1 - v18.Magnitude / meter / p2, 0, 1)

		if v19 <= 0 then
			return
		end

		local v20 = not (v18.Magnitude > 0.01) and 0 or cframe2.RightVector:Dot(v18.Unit)
		local v21 = not (v18.Magnitude > 0.01) and 0 or cframe2.LookVector:Dot(v18.Unit)
		local v22 = p * v19 * v19
		local number = random:NextNumber(0.8, 1.2)
		local v23 = v17
		local v24 = v22 * (math.max(v21, 0) * 0.4 + 0.6) * number
		local v25 = v22 * 0.45 * v20 * number
		local v26 = v22 * 0.7

		if not (math.abs(v20) > 0.15) then
			v20 = random:NextNumber(-1, 1)
		end

		v17 = v23 + Vector3.new(v24, v25, v26 * v20)
		wake() -- inferred equivalent call
	end
end

return BattleFX