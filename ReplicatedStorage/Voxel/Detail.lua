--!native
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")
local VRService = game:GetService("VRService")

local parent = script.Parent
local isClient = RunService:IsClient()

local Detail = {}

local v = {
	[0] = 45,
	38,
	28
}
local v2 = { 55, 48, 38 }

local v3 = { 64, 20, 6 }

Detail.mobile = isClient
	and UserInputService.TouchEnabled
	and not (UserInputService.KeyboardEnabled or VRService.VREnabled)
Detail.low = false
Detail.potato = false
Detail.budget = 1
Detail.strain = 0
Detail.renderTime = 0
Detail.eye = Vector3.new(0, 0, 0)
Detail.look = Vector3.new(0, 0, -1)
Detail.pxK = 600
Detail.screenY = 720
Detail.frame = 0

Detail.shadowVersion = 0

local v4 = 0.5
local v5 = true
local v6 = 4
local v7 = 400

local function readTier()
	local low = Detail.mobile and parent:GetAttribute("MobileDetail") ~= false and true
		or parent:GetAttribute("MobileDetailOnPC") == true
	v5 = parent:GetAttribute("DetailAdaptive") ~= false
	local v8

	if low then
		v8 = parent:GetAttribute("MobileShadowDistance")
	else
		v8 = parent:GetAttribute("ShadowDistance")
	end

	local v9 = low and (Detail.strain >= 1 and 32 or 8) or 4

	local v10 = type(v8) ~= "number" and (low and 150 or 400) or v8
	assert(v10 > 0, "[Detail] shadow distance must be above 0")

	if low ~= Detail.low or v9 ~= v6 or v10 ~= v7 then
		Detail.shadowVersion += 1
	end

	if low and not Detail.low then
		Detail.budget = math.min(Detail.budget, 0.7)
	end

	Detail.low = low
	v6 = v9
	v7 = v10

	if not v5 then
		Detail.budget = 1
	end
end

function Detail.distance(vector3: Vector3)
	return (vector3 - Detail.eye).Magnitude
end

function Detail.pixels(vector3: Vector3, p: number)
	return p * Detail.pxK / math.max((vector3 - Detail.eye).Magnitude, 0.5)
end

function Detail.reach()
	return Detail.budget
end

function Detail.scale(vector3: Vector3, p: number)
	if not isClient then
		return 1
	end

	local v8 = Detail.pixels(vector3, p) * Detail.budget
	local v9 = Detail.low and 140 or 96
	local v10 = Detail.low and 8 or 4

	if v9 <= v8 then
		return 1
	end

	if v8 <= v10 then
		return 0
	end

	return math.log(v8 / v10) / math.log(v9 / v10)
end

local function tierOf(p: number): number -- 3 equivalent calls inferred from this helper
	local v8 = Detail.low and 1.5 or 1

	if v3[1] * v8 <= p then
		return 0
	end

	if v3[2] * v8 <= p then
		return 1
	end

	return if v3[3] * v8 <= p then 2 else 3
end

function Detail.tier(vector3: Vector3, p: number, p2: number?)
	if not isClient then
		return 0
	end

	local v8 = Detail.pixels(vector3, p) * Detail.budget

	if p2 == nil then
		return tierOf(v8) -- inferred equivalent call
	else
		local v9 = tierOf(v8 * 1.18) -- inferred equivalent call

		if p2 < v9 then
			return v9
		end

		local v10 = tierOf(v8 / 1.18) -- inferred equivalent call
		return if v10 < p2 then v10 else p2
	end
end

function Detail.onScreen(vector3: Vector3, p: number): boolean
	local vector = vector3 - Detail.eye
	local magnitude = vector.Magnitude

	if magnitude <= p then
		return true
	end

	local v8 = (vector:Dot(Detail.look) + p) / magnitude
	return v4 <= v8
end

function Detail.maxDistance(p: number)
	if Detail.low then
		return p * 0.6
	end

	return p
end

function Detail.shadowBand(p: number, p2: number?)
	local v8 = p * 4 / v7
	local v9 = math.clamp(math.floor(v8), 0, 12)

	if p2 == nil or v9 == p2 or not (p2 - 0.3 < v8 and v8 < p2 + 1 + 0.3) then
		return v9
	end

	return p2
end

function Detail.bandCells(p: number)
	if p >= 12 then
		return 1e999
	end

	return v6 * 2 ^ p
end

function Detail.castsShadow(p: number, p2: number, flag: boolean?): boolean
	if not isClient then
		return p >= 4
	end

	if flag == true then
		p2 *= 0.87
	elseif flag == false then
		p2 *= 1.15
	end

	return v6 * 2 ^ (p2 * 4 / v7) <= p
end

function Detail.castsShadowPart(vector3: Vector3, p: number, flag: boolean?)
	return Detail.castsShadow(vector3.X * vector3.Y * vector3.Z / 0.125, p, flag)
end

local v8 = {}
local v9 = {}

local function newTrim(p: string, classes)
	v8[p] = { f = 1, target = 1, knobs = {}, classes = classes }
end

v8.rays = {
	f = 1,
	target = 1,
	knobs = {},
	classes = {
		SunRaysEffect = { "+Intensity", "Enabled" }
	}
}
v8.bloom = {
	f = 1,
	target = 1,
	knobs = {},
	classes = {
		BloomEffect = { "+Intensity", "Enabled" }
	}
}
v8.clouds = {
	f = 1,
	target = 1,
	knobs = {},
	classes = {
		Clouds = { "+Cover", "Enabled" }
	}
}
v8.shadows = {
	f = 1,
	target = 1,
	knobs = {},
	classes = {
		Lighting = { "GlobalShadows" }
	}
}
v8.specular = {
	f = 1,
	target = 1,
	knobs = {},
	classes = {
		Lighting = { "+EnvironmentSpecularScale" }
	}
}
v8.blur = {
	f = 1,
	target = 1,
	knobs = {},
	classes = {
		DepthOfFieldEffect = { "Enabled" },
		BlurEffect = { "Enabled" }
	}
}

local function same(value, value2): boolean -- 7 equivalent calls inferred from this helper
	if type(value) == "number" and type(value2) == "number" then
		return math.abs(value - value2) < 0.0001
	end

	return value == value2
end

local function applyKnob(state, f: number) -- 3 equivalent calls inferred from this helper
	local inst = state.inst
	local v10

	if state.kind == "number" then
		v10 = state.base * f
	else
		v10 = state.base and f > 0
	end

	if not same(inst[state.prop], v10) then -- inferred equivalent call
		inst[state.prop] = v10
	end

	state.written = inst[state.prop]
end

local function bind(p, instance, propertyName: string, kind: string)
	for _, knob in p.knobs do
		if knob.inst == instance and knob.prop == propertyName then
			return
		end
	end

	local v10 = {
		inst = instance,
		prop = propertyName,
		kind = kind,
		base = instance[propertyName],
		written = nil
	}
	table.insert(p.knobs, v10)
	instance:GetPropertyChangedSignal(propertyName):Connect(function()
		local v11 = instance[propertyName]

		if not same(v11, v10.written) then -- inferred equivalent call
			v10.base = v11

			if p.f < 1 then
				applyKnob(v10, p.f) -- inferred equivalent call
			else
				v10.written = v11
			end
		end
	end)

	if p.f < 1 then
		applyKnob(v10, p.f) -- inferred equivalent call
	end
end

local function bindInstance(instance)
	for _, v10 in v8 do
		for k, class in v10.classes do
			if instance.ClassName ~= k then
				continue
			end

			for _, v11 in class do
				if string.sub(v11, 1, 1) == "+" then
					bind(v10, instance, string.sub(v11, 2), "number")
				else
					bind(v10, instance, v11, "bool")
				end
			end
		end
	end
end

local function setTrims()
	local potato = Detail.potato
	local low = Detail.low
	local strain = low and parent:GetAttribute("StrainShadows") ~= false and Detail.strain or 0
	local v10 = {
		rays = potato or low,
		bloom = potato or low,
		shadows = potato or low and parent:GetAttribute("MobileShadows") == false and true or strain >= 2,
		specular = potato or strain >= 2,
		blur = potato or strain >= 1,
		clouds = potato or strain >= 1 or low and (v8.clouds.target == 0 and Detail.budget < 0.6 or Detail.budget < 0.45)
	}

	for k, v11 in v8 do
		local target = v10[k] and 0 or 1

		if v11.target == target then
			continue
		end

		v11.target = target
		v9[v11] = true
	end
end

local function stepTrims(p: number)
	for k in v9 do
		local v10 = p / 1.5

		if k.f < k.target then
			k.f = math.min(k.target, k.f + v10)
		else
			k.f = math.max(k.target, k.f - v10)
		end

		for i = #k.knobs, 1, -1 do
			local knob = k.knobs[i]

			if knob.inst.Parent == nil and knob.inst ~= Lighting then
				table.remove(k.knobs, i)
			else
				applyKnob(knob, k.f) -- inferred equivalent call
			end
		end

		if k.f == k.target then
			v9[k] = nil
		end
	end
end

function Detail.setPotato(potato: boolean)
	assert(isClient, "[Detail] potato mode is client-side")
	Detail.potato = potato
	setTrims()
end

local v10 = {}
local v11 = {}
local v12 = {}
local v13 = 0

local function worldPos(inst) -- 2 equivalent calls inferred from this helper
	local parent2 = inst.Parent

	if parent2 == nil then
		return nil
	end

	if parent2:IsA("Attachment") then
		return parent2.WorldPosition
	end

	return if parent2:IsA("BasePart") then parent2.Position else nil
end

local function sizeOf(instance, p: number) -- 3 equivalent calls inferred from this helper
	local detailSize = instance:GetAttribute("DetailSize")
	return if type(detailSize) == "number" then detailSize else p
end

local function applyLight(state)
	local inst = state.inst
	local brightness = state.base * state.k * (not state.twin and 1 or state.s)

	if not same(inst.Brightness, brightness) then -- inferred equivalent call
		inst.Brightness = brightness
	end

	state.written = inst.Brightness
	local enabled = state.baseOn and brightness > 0.001

	if inst.Enabled ~= enabled then
		inst.Enabled = enabled
	end

	local twin = state.twin

	if twin then
		local brightness2 = state.base * state.k * (1 - state.s)

		if not same(twin.Brightness, brightness2) then -- inferred equivalent call
			twin.Brightness = brightness2
		end

		local enabled2 = state.baseOn and brightness2 > 0.001

		if twin.Enabled ~= enabled2 then
			twin.Enabled = enabled2
		end
	end
end

local function add(instance, kind: string)
	if v11[instance] then
		return
	end

	local v14 = {
		inst = instance,
		kind = kind,
		size = 4,
		base = 0,
		written = nil,
		baseOn = true,
		tier = nil,
		twin = nil,
		shadowed = false,
		s = 0,
		sTarget = 0,
		k = 1,
		kTarget = 1
	}

	if kind == "light" then
		assert(instance:IsA("Light"), "[Detail] DetailLight on a " .. instance.ClassName)

		v14.base = instance.Brightness
		v14.baseOn = instance.Enabled
		v14.shadowed = instance.Shadows

		if instance.Shadows then
			local detailTwin = instance:Clone()

			for _, tag in detailTwin:GetTags() do
				detailTwin:RemoveTag(tag)
			end

			detailTwin.Name = "DetailTwin"
			detailTwin.Shadows = false
			detailTwin.Parent = instance.Parent
			v14.twin = detailTwin
			v14.s = 0
		end

		instance:GetPropertyChangedSignal("Brightness"):Connect(function()
			if not same(instance.Brightness, v14.written) then -- inferred equivalent call
				v14.base = instance.Brightness
				applyLight(v14)
			end
		end)
		applyLight(v14)
	elseif kind == "emitter" then
		assert(instance:IsA("ParticleEmitter"), "[Detail] DetailEmitter on a " .. instance.ClassName)
		v14.base = instance.Rate
		v14.size = sizeOf(instance, 4) -- inferred equivalent call
	elseif kind == "ribbon" then
		assert(instance:IsA("Beam") or instance:IsA("Trail"), "[Detail] DetailRibbon on a " .. instance.ClassName)
		v14.baseOn = instance.Enabled
		v14.size = sizeOf(instance, 4) -- inferred equivalent call
	elseif kind == "fade" then
		assert(instance:IsA("BasePart"), "[Detail] DetailFade on a " .. instance.ClassName)
		v14.size = sizeOf(instance, math.max(instance.Size.X, instance.Size.Y, instance.Size.Z)) -- inferred equivalent call
	end

	v11[instance] = v14
	table.insert(v10, v14)
end

local function remove(p)
	local v14 = v11[p]

	if not v14 then
		return
	end

	v11[p] = nil
	v12[v14] = nil

	if v14.twin then
		v14.twin:Destroy()
	end

	local index = table.find(v10, v14)

	if index then
		v10[index] = v10[#v10]
		v10[#v10] = nil
	end
end

local v14 = {}
local magnitudes = {}
local function pickShadows()
	table.clear(v14)
	local v15 = v7 * 0.4

	for _, v16 in v10 do
		if not v16.twin then
			continue
		end

		local vector3 = worldPos(v16.inst) -- inferred equivalent call

		if not vector3 then
			continue
		end

		local magnitude = (vector3 - Detail.eye).Magnitude

		if v16.sTarget == 1 then
			magnitude *= 0.8
		end

		magnitudes[v16] = magnitude
		table.insert(v14, v16)
	end

	table.sort(v14, function(a, b): boolean
		return magnitudes[a] < magnitudes[b]
	end)

	local v16 = Detail.low and 0 or 2
	local v17 = Detail.potato and 0 or v16

	for k, v18 in v14 do
		local sTarget = k <= v17 and magnitudes[v18] < v15 and 1 or 0

		if v18.sTarget == sTarget then
			continue
		end

		v18.sTarget = sTarget
		v12[v18] = true
	end

	table.clear(magnitudes)
end

local function visit(state)
	local inst = state.inst
	local v15

	if state.kind == "fade" then
		v15 = inst.Position
	else
		v15 = worldPos(inst) -- inferred equivalent call
	end

	if not v15 then
		return
	end

	if state.kind == "light" then
		local range = inst.Range or 16
		local v16 = Detail.pixels(v15, range * 2) * Detail.budget
		local v17 = Detail.low and 150 or 40
		local v18 = Detail.low and 50 or 10
		local kTarget = math.clamp((v16 - v18) / (v17 - v18), 0, 1)

		if Detail.low then
			kTarget = math.floor(kTarget * 4 + 0.5) / 4
		end

		if math.abs(kTarget - state.kTarget) > 0.01 then
			state.kTarget = kTarget
			v12[state] = true
		end
	elseif state.kind == "emitter" then
		if not same(inst.Rate, state.written) and state.written ~= nil then -- inferred equivalent call
			state.base = inst.Rate
		end

		local rate = state.base * math.floor(Detail.scale(v15, state.size) * 8 + 0.5) / 8

		if not same(inst.Rate, rate) then -- inferred equivalent call
			inst.Rate = rate
		end

		state.written = inst.Rate
	elseif state.kind == "ribbon" then
		local tier = Detail.tier(v15, state.size, state.tier)
		state.tier = tier
		local enabled = state.baseOn and tier < 3

		if inst.Enabled ~= enabled then
			inst.Enabled = enabled
		end
	elseif state.kind == "fade" then
		local localTransparencyModifier = 1 - math.floor(Detail.scale(v15, state.size) * 4 + 0.5) / 4

		if inst.LocalTransparencyModifier ~= localTransparencyModifier then
			inst.LocalTransparencyModifier = localTransparencyModifier
		end
	end
end

local function stepFading(p: number)
	for k in v12 do
		if k.inst.Parent == nil then
			v12[k] = nil
		else
			local v15 = p / 0.8
			local v16

			if k.s < k.sTarget then
				v16 = math.min(k.sTarget, k.s + v15)
			else
				v16 = math.max(k.sTarget, k.s - v15)
			end

			k.s = v16
			local v17 = Detail.low and 1 or p / 0.4
			local v18

			if k.k < k.kTarget then
				v18 = math.min(k.kTarget, k.k + v17)
			else
				v18 = math.max(k.kTarget, k.k - v17)
			end

			k.k = v18
			applyLight(k)

			if k.s == k.sTarget and k.k == k.kTarget then
				v12[k] = nil
			end
		end
	end
end

Detail.spent = {}

function Detail.timed(p: string, callback)
	Detail.spent[p] = 0
	return function(...)
		local lastTime = os.clock()
		callback(...)
		Detail.spent[p] += os.clock() - lastTime
	end
end

Detail.takes = { frame = {}, used = {} }
function Detail.take(p: string, p2: number): boolean
	local takes = Detail.takes

	if takes.frame[p] ~= Detail.frame then
		takes.frame[p] = Detail.frame
		takes.used[p] = 0
	end

	local v15 = takes.used[p]

	if p2 <= v15 then
		return false
	end

	takes.used[p] = v15 + 1
	return true
end

Detail.onMark = nil
function Detail.mark(p: string, vector3: Vector3?)
	local onMark = Detail.onMark

	if onMark then
		onMark(p, vector3)
	end
end

local v15 = {}
local v16 = {}
local v17 = {}
local v18 = 0
local v19 = 0
local v20 = 0
local count = 0
local v21 = 0
local v22 = false
local v23 = true

local function setStrain(strain: number)
	if strain == Detail.strain then
		return
	end

	Detail.strain = strain
	v22 = false
	print("[Detail] strain", strain)
	readTier()
	setTrims()

	for _, callback in v15 do
		task.spawn(callback, strain)
	end

	for _, callback in v16 do
		task.spawn(callback, strain)
	end
end

function Detail.onStrain(callback)
	table.insert(v15, callback)
end

function Detail.onStrainSave(callback)
	table.insert(v16, callback)
end

function Detail.seedStrain(value: number)
	if parent:GetAttribute("StrainLadder") ~= false then
		setStrain(math.clamp(value, 0, 3))
	end
end

local function strainPause() -- 4 equivalent calls inferred from this helper
	v20 = 0
	count = 0
	v21 = os.clock() + 6
end

local function stepStrain(p: number, now: number)
	if now - v19 > 2 then
		strainPause() -- inferred equivalent call
	end

	v19 = now
	table.insert(v17, p)

	if now - v18 < 1 then
		return
	end

	v18 = now
	table.sort(v17)
	local v24 = v17[(#v17 + 1) // 2]
	table.clear(v17)

	if parent:GetAttribute("StrainLadder") == false then
		setStrain(0)
		return
	end

	local localPlayer = Players.LocalPlayer

	if
		localPlayer.Team == nil
		or localPlayer:GetAttribute("SettingsLoaded") ~= true
		or localPlayer:GetAttribute("JoinMeshed") == nil
		or localPlayer:GetAttribute("JoinCovered") == true
		or localPlayer:GetAttribute("WorldMeshing") == true
	then
		strainPause() -- inferred equivalent call
	elseif v23 and not (now < v21) then
		local v25 = 1 / math.max(v24, 0.001)

		if v25 < (v[Detail.strain] or 0) then
			count = 0
			v20 += 1

			if Detail.strain < 3 then
				local v26 = v20

				if (v25 < 15 and 4 or 8) <= v26 then
					setStrain(Detail.strain + 1)
					v20 = 0
					v21 = now + 3
				end
			end
		elseif Detail.strain > 0 and v2[Detail.strain] <= v25 then
			v20 = 0
			count += 1

			if count >= 300 and not v22 then
				v22 = true

				for _, callback in v16 do
					task.spawn(callback, Detail.strain - 1)
				end
			end
		else
			v20 = math.max(0, v20 - 1)
			count = 0
		end
	else
		v20 = 0
		count = 0
	end
end

local v24 = 0
local total = 0
local v25 = 0
local total2 = 0

local function govern(now: number)
	if now - v25 < 0.5 then
		return
	end

	local v26 = now - v25
	v25 = now

	if not v5 then
		return
	end

	local _low = Detail.low
	local v27 = 1 / 60
	local v28 = Detail.low and 0.35 or 0.6
	local renderTime = Detail.renderTime

	if v27 * 1.15 < renderTime then
		total2 = 0
		Detail.budget = math.max(v28, Detail.budget - 0.06)
	elseif renderTime < v27 * 0.8 then
		total2 += v26

		if total2 >= 3 then
			Detail.budget = math.min(1, Detail.budget + 0.02)
		end
	else
		total2 = 0
	end

	setTrims()
end

local function step(p: number)
	Detail.frame += 1
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		local cframe = currentCamera.CFrame
		Detail.eye = cframe.Position
		Detail.look = cframe.LookVector
		local viewportSize = currentCamera.ViewportSize
		local v26 = math.tan(math.rad(currentCamera.FieldOfView) * 0.5)
		Detail.screenY = math.max(viewportSize.Y, 1)
		Detail.pxK = Detail.screenY / (v26 * 2)
		local v27 = viewportSize.X / Detail.screenY
		v4 = math.cos((math.atan(v26 * math.sqrt(1 + v27 * v27))))
	end

	total += p

	if Detail.frame % 4 == 0 then
		local v26 = math.max(Stats.RenderGPUFrameTime, Stats.RenderCPUFrameTime)
		Detail.renderTime += (v26 - Detail.renderTime) * math.min(1, total / 1)
		total = 0
	end

	local now = os.clock()
	govern(now)
	stepStrain(p, now)

	if next(v9) then
		debug.profilebegin("Detail.trims")
		stepTrims(p)
		debug.profileend()
	end

	if now - v24 >= 0.25 then
		v24 = now
		debug.profilebegin("Detail.pass")
		pickShadows()
		local count2 = #v10

		for _ = 1, math.min(count2, 96) do
			v13 = v13 % count2 + 1
			visit(v10[v13])
		end

		debug.profileend()
	end

	if next(v12) then
		debug.profilebegin("Detail.fade")
		stepFading(p)
		debug.profileend()
	end
end

local flag = false
function Detail.start()
	assert(isClient and RunService:IsRunning(), "[Detail] runs on a running client")

	if flag then
		return
	end

	flag = true
	readTier()
	parent.AttributeChanged:Connect(function(p: string)
		if
			p == "MobileDetail"
			or p == "MobileDetailOnPC"
			or p == "DetailAdaptive"
			or p == "ShadowDistance"
			or p == "MobileShadowDistance"
		then
			readTier()
			setTrims()
		elseif p == "MobileShadows" then
			setTrims()
		end
	end)
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		Detail.eye = currentCamera.CFrame.Position
	end

	bindInstance(Lighting)

	for _, child in Lighting:GetChildren() do
		bindInstance(child)
	end

	Lighting.ChildAdded:Connect(bindInstance)

	for _, child in workspace.Terrain:GetChildren() do
		bindInstance(child)
	end

	workspace.Terrain.ChildAdded:Connect(bindInstance)
	setTrims()

	for tag, v26 in {
		DetailLight = "light",
		DetailEmitter = "emitter",
		DetailRibbon = "ribbon",
		DetailFade = "fade"
	} do
		for _, v27 in CollectionService:GetTagged(tag) do
			add(v27, v26)
		end

		CollectionService:GetInstanceAddedSignal(tag):Connect(function(inst)
			add(inst, v26)
		end)
		CollectionService:GetInstanceRemovedSignal(tag):Connect(remove)
	end

	UserInputService.WindowFocusReleased:Connect(function()
		v23 = false
		strainPause() -- inferred equivalent call
	end)
	UserInputService.WindowFocused:Connect(function()
		v23 = true
		strainPause() -- inferred equivalent call
	end)
	Players.LocalPlayer.CharacterAdded:Connect(strainPause)

	RunService:BindToRenderStep("Detail", Enum.RenderPriority.Camera.Value + 1, step)
end

if isClient and RunService:IsRunning() then
	Detail.start()
end

return Detail