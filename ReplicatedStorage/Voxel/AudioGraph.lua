local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
assert(RunService:IsClient(), "[AudioGraph] client only")

assert(RunService:IsRunning(), "[AudioGraph] runs only in a running game, not in Edit")

local AudioGraph = {}

local Detail = require(script.Parent:WaitForChild("Detail"))

local voxelAudio = Instance.new("Folder")
voxelAudio.Name = "VoxelAudio"
voxelAudio.Parent = SoundService

local function make(className: string, name: string, parent, items) -- 21 equivalent calls inferred from this helper
	local instance = Instance.new(className)
	instance.Name = name

	if items then
		for k, item in items do
			instance[k] = item
		end
	end

	instance.Parent = parent
	return instance
end

local function wire(p, targetInstance) -- 19 equivalent calls inferred from this helper
	local wire2 = Instance.new("Wire")
	wire2.Name = "To" .. targetInstance.Name
	wire2.SourceInstance = p
	wire2.TargetInstance = targetInstance
	wire2.Parent = p
	return wire2
end

local targetInstance2 = make("AudioDeviceOutput", "Output", voxelAudio) -- inferred equivalent call
local v = make("AudioCompressor", "Limiter", voxelAudio, { -- inferred equivalent call
	Threshold = -3,
	Ratio = 10,
	Attack = 0.002,
	Release = 0.12,
	MakeupGain = 0
})
wire(v, targetInstance2) -- inferred equivalent call
local v2 = make("AudioFader", "SfxLevel", voxelAudio, { Volume = 1 }) -- inferred equivalent call
wire(v2, v) -- inferred equivalent call
local v3 = make("AudioFader", "MusicLevel", voxelAudio, { Volume = 1 }) -- inferred equivalent call
wire(v3, v) -- inferred equivalent call
local v4 = make("AudioEqualizer", "Concussion", voxelAudio, { -- inferred equivalent call
	LowGain = 0,
	MidGain = 0,
	HighGain = 0,
	Bypass = true
})
wire(v4, v2) -- inferred equivalent call
local v5 = make("AudioReverb", "Room", voxelAudio, { -- inferred equivalent call
	DecayTime = 0.25,
	WetLevel = -24,
	DryLevel = 0,
	Density = 1,
	Diffusion = 1
})
wire(v5, v4) -- inferred equivalent call
local v6 = make("AudioFader", "MenuDuck", voxelAudio, { Volume = 1 }) -- inferred equivalent call
wire(v6, v5) -- inferred equivalent call
local v7 = make("AudioFilter", "MenuMuffle", voxelAudio, { -- inferred equivalent call
	FilterType = Enum.AudioFilterType.Lowpass12dB,
	Frequency = 20000,
	Q = 0.707,
	Bypass = true
})
wire(v7, v6) -- inferred equivalent call
local v8 = make("AudioFader", "WorldLevel", voxelAudio, { Volume = 1 }) -- inferred equivalent call
wire(v8, v7) -- inferred equivalent call
local v9 = make("AudioFader", "ShowDuck", voxelAudio, { Volume = 1 }) -- inferred equivalent call
wire(v9, v8) -- inferred equivalent call
local v10 = make("AudioFader", "Master", voxelAudio, { Volume = 1 }) -- inferred equivalent call
wire(v10, v9) -- inferred equivalent call
local buses = {}
local v11 = {}

local function eq(name: string, lowGain: number, midGain: number, highGain: number)
	return make("AudioEqualizer", name, voxelAudio, { -- inferred equivalent call
		LowGain = lowGain,
		MidGain = midGain,
		HighGain = highGain
	})
end

local function reverb(name: string, decayTime: number, wetLevel: number, dryLevel: number) -- 5 equivalent calls inferred from this helper
	return make("AudioReverb", name, voxelAudio, { -- inferred equivalent call
		DecayTime = decayTime,
		WetLevel = wetLevel,
		DryLevel = dryLevel,
		Density = 1,
		Diffusion = 1
	})
end

local function addBus(name: string, fx, targetInstance, flag: boolean, value: number?)
	local input = make("AudioFader", name .. "In", voxelAudio, { Volume = 1 }) -- inferred equivalent call
	local v12 = input

	for _, item in fx do
		wire(v12, item) -- inferred equivalent call
		v12 = item
	end

	wire(v12, targetInstance) -- inferred equivalent call
	local audioListener

	if flag then
		local name2 = name .. "Ears"
		local v13 = {
			AudioInteractionGroup = "Vx" .. name
		}
		audioListener = Instance.new("AudioListener")
		audioListener.Name = name2

		if v13 then
			for k, v14 in v13 do
				audioListener[k] = v14
			end
		end

		audioListener.Parent = voxelAudio
		wire(audioListener, input) -- inferred equivalent call
	end

	local v13 = {
		name = name,
		group = "Vx" .. name,
		input = input,
		listener = audioListener,
		fx = fx,
		decay = value or 0,
		idle = false,
		quietAt = 0
	}
	buses[name] = v13

	if #fx > 0 then
		table.insert(v11, v13)
	end
end

addBus("dry", {}, v10, true)
local v12 = { nil }
local v13 = { LowGain = -8, MidGain = -1, HighGain = -12 }
local audioEqualizer = Instance.new("AudioEqualizer")
audioEqualizer.Name = "ReflectEq"
local v14

if v13 then
	v14 = addBus

	for k, v15 in v13 do
		audioEqualizer[k] = v15
	end
else
	v14 = addBus
end

audioEqualizer.Parent = voxelAudio
v12[1] = audioEqualizer

v14("reflect", v12, v10, true, 0)
local v15 = { nil, nil }
local v16 = { LowGain = -2, MidGain = 0, HighGain = -9 }
local audioEqualizer2 = Instance.new("AudioEqualizer")
audioEqualizer2.Name = "OpenEq"
local v17

if v16 then
	v17 = addBus

	for k, v18 in v16 do
		audioEqualizer2[k] = v18
	end
else
	v17 = addBus
end

audioEqualizer2.Parent = voxelAudio
local v18 = reverb("OpenVerb", 2.2, -12, 0) -- inferred equivalent call
v15[1], v15[2] = audioEqualizer2, v18

v17("open", v15, v10, true, 2.2)
local v19 = { nil, nil }
local v20 = { LowGain = -3, MidGain = 0, HighGain = -4 }
local audioEqualizer3 = Instance.new("AudioEqualizer")
audioEqualizer3.Name = "StreetEq"
local v21

if v20 then
	v21 = addBus

	for k, v22 in v20 do
		audioEqualizer3[k] = v22
	end
else
	v21 = addBus
end

audioEqualizer3.Parent = voxelAudio
local v22 = reverb("StreetVerb", 0.9, -8, 0) -- inferred equivalent call
v19[1], v19[2] = audioEqualizer3, v22

v21("street", v19, v10, true, 0.9)
local v23 = { nil, nil }
local v24 = { LowGain = 0, MidGain = 0, HighGain = -3 }
local audioEqualizer4 = Instance.new("AudioEqualizer")
audioEqualizer4.Name = "RoomEq"
local v25

if v24 then
	v25 = addBus

	for k, v26 in v24 do
		audioEqualizer4[k] = v26
	end
else
	v25 = addBus
end

audioEqualizer4.Parent = voxelAudio
local v26 = reverb("RoomVerb", 1.4, -2, -3) -- inferred equivalent call
v23[1], v23[2] = audioEqualizer4, v26

v25("room", v23, v10, true, 1.4)

local v27 = { nil, nil }
local v28 = { LowGain = 0, MidGain = -1, HighGain = -10 }
local audioEqualizer5 = Instance.new("AudioEqualizer")
audioEqualizer5.Name = "VastEq"
local v29

if v28 then
	v29 = addBus

	for k, v30 in v28 do
		audioEqualizer5[k] = v30
	end
else
	v29 = addBus
end

audioEqualizer5.Parent = voxelAudio
local v30 = reverb("VastVerb", 3.2, -8, 0) -- inferred equivalent call
v27[1], v27[2] = audioEqualizer5, v30

v29("vast", v27, v10, true, 3.2)
addBus("amb", {}, v10, false)
addBus("ui", {}, v2, false)

local v31 = { nil, nil }
local v32 = { LowGain = -8, MidGain = 0, HighGain = -4 }
local audioEqualizer6 = Instance.new("AudioEqualizer")
audioEqualizer6.Name = "UiRoomEq"
local v41

if v32 then
	v41 = addBus

	for k, v42 in v32 do
		audioEqualizer6[k] = v42
	end
else
	v41 = addBus
end

audioEqualizer6.Parent = voxelAudio
local v42 = reverb("UiRoomVerb", 1.1, -11, 0) -- inferred equivalent call
v31[1], v31[2] = audioEqualizer6, v42

v41("uiroom", v31, v2, false, 1.1)
addBus("music", {}, v3, false)
AudioGraph.buses = buses

local function placeEars() -- 2 equivalent calls inferred from this helper
	local currentCamera = workspace.CurrentCamera
	assert(currentCamera, "[AudioGraph] no camera")

	for _, v43 in buses do
		if v43.listener then
			v43.listener.Parent = currentCamera
		end
	end
end

while not workspace.CurrentCamera do
	workspace:GetPropertyChangedSignal("CurrentCamera"):Wait()
end

placeEars() -- inferred equivalent call
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	if workspace.CurrentCamera then
		placeEars() -- inferred equivalent call
	end
end)

local v43 = { [0] = 1, [100000] = 1 }
local parent2 = make("Folder", "Flat", voxelAudio) -- inferred equivalent call

function AudioGraph.monoFold(p: string)
	local split = make("AudioChannelSplitter", p .. "Split", parent2, { -- inferred equivalent call
		Layout = Enum.AudioChannelLayout.Stereo
	})
	local v46 = make("AudioChannelMixer", p .. "Mix", parent2, { -- inferred equivalent call
		Layout = Enum.AudioChannelLayout.Stereo
	})
	local v47 = make("AudioFader", p .. "Half", parent2, { Volume = 0.5 }) -- inferred equivalent call

	for _, sourceName in { "Left", "Right" } do
		for _, targetName in { "Left", "Right" } do
			local wire2 = wire(split, v46) -- inferred equivalent call
			wire2.Name = sourceName .. "To" .. targetName
			wire2.SourceName = sourceName
			wire2.TargetName = targetName
		end
	end

	wire(v46, v47) -- inferred equivalent call
	wire(v47, buses.dry.input) -- inferred equivalent call
	return { split = split }
end

local function newVoice(name: string, attachment, flag: boolean, flag2: boolean?, fold, flag3: boolean?)
	assert(not (flag3 and flag2), "[AudioGraph] a plain voice needs its own player (samplers wire into the filter)")
	local audioFilter

	if not flag3 then
		local name2 = name .. "Filter"
		local v46 = {
			FilterType = Enum.AudioFilterType.Lowpass12dB,
			Frequency = 20000,
			Q = 0.707,
			Bypass = true
		}
		audioFilter = Instance.new("AudioFilter")
		audioFilter.Name = name2

		if v46 then
			for k, v47 in v46 do
				audioFilter[k] = v47
			end
		end

		audioFilter.Parent = attachment
	end

	local audioPlayer

	if not flag2 then
		local v45 = { AutoLoad = true }
		audioPlayer = Instance.new("AudioPlayer")
		audioPlayer.Name = name

		if v45 then
			for k, v46 in v45 do
				audioPlayer[k] = v46
			end
		end

		audioPlayer.Parent = attachment

		if audioFilter then
			wire(audioPlayer, audioFilter) -- inferred equivalent call
		end
	end

	local v45 = audioFilter or audioPlayer
	local voice = {
		player = audioPlayer,
		filter = audioFilter,
		bus = "dry",
		cutoff = 20000,
		highpass = false,
		bypass = true
	}

	if flag then
		local emitter = make("AudioEmitter", name .. "Emitter", attachment, { -- inferred equivalent call
			AudioInteractionGroup = buses.dry.group
		})
		emitter.AcousticSimulationEnabled = false
		emitter:SetDistanceAttenuation(v43)
		wire(v45, emitter) -- inferred equivalent call
		voice.emitter = emitter

		if not attachment:IsA("Attachment") then
			attachment = nil
		end

		voice.attachment = attachment
		return voice
	else
		voice.fold = fold
		local v46 = if fold then fold.split else buses.dry.input
		voice.out = wire(v45, v46) -- inferred equivalent call

		return voice
	end
end

function AudioGraph.positional(name: string, parent, flag: boolean?, flag2: boolean?)
	local attachment = Instance.new("Attachment")
	attachment.Name = name
	attachment.Parent = parent
	return newVoice(name, attachment, true, flag, nil, flag2)
end

function AudioGraph.flat(name: string, flag: boolean?, fold, flag2: boolean?)
	return newVoice(name, parent2, false, flag, fold, flag2)
end

local parent = make("Folder", "Samples", voxelAudio) -- inferred equivalent call

function AudioGraph.sampler(asset: string, p: number)
	local v46 = asset:match("%d+") or asset
	local result = {}

	for i = 1, p do
		local v47 = make("AudioPlayer", v46 .. "_" .. i, parent, { AutoLoad = true, Asset = asset }) -- inferred equivalent call
		local out = Instance.new("Wire")
		out.Name = "Out"
		out.SourceInstance = v47
		out.Parent = v47
		result[i] = { player = v47, wire = out, target = nil }
	end

	return result
end

function AudioGraph:connect(p)
	local filter

	if p then
		filter = p.filter
	end

	assert(filter or not p, "[AudioGraph] samplers play only through bare voices")

	if self.target ~= filter then
		self.target = filter
		self.wire.TargetInstance = filter
	end
end

function AudioGraph:route(bus: string, value: number?)
	local v46 = buses[bus]

	if not v46 then
		error("[AudioGraph] no bus " .. bus)
	end

	if #v46.fx > 0 then
		local quietAt = (value or 1e999) + v46.decay + 1

		if v46.quietAt < quietAt then
			v46.quietAt = quietAt
		end

		if v46.idle then
			v46.idle = false

			for _, v48 in v46.fx do
				v48.Bypass = false
			end
		end
	end

	if self.bus == bus then
		return
	end

	local bus2 = self.bus
	self.bus = bus

	if self.emitter then
		if not v46.listener then
			error("[AudioGraph] bus " .. bus .. " has no listener: positional voices can't play on it")
		end

		local emitter = self.emitter
		emitter.AudioInteractionGroup = v46.group

		if bus2 == "parked" then
			emitter.Parent = assert(self.attachment, "[AudioGraph] parked emitter without its attachment")
		end
	elseif self.fold then
		assert(bus == "dry", "[AudioGraph] mono voices play on the dry bus only")
		self.out.TargetInstance = self.fold.split
	else
		self.out.TargetInstance = v46.input
	end
end

function AudioGraph:park()
	if self.bus == "parked" then
		return
	end

	self.bus = "parked"

	if self.emitter then
		self.emitter.Parent = nil
	else
		self.out.TargetInstance = nil
	end
end

function AudioGraph.awake(p): boolean
	return p.bus ~= "parked"
end

local v46 = 0
local v47 = false

function AudioGraph.step(p: number)
	local bypass = Detail.low

	if bypass then
		if Detail.strain >= 1 then
			bypass = v46 < 0.02
		else
			bypass = false
		end
	end

	if bypass ~= v47 then
		v47 = bypass
		v5.Bypass = bypass
	end

	for _, v49 in v11 do
		if v49.idle or not (v49.quietAt <= p) then
			continue
		end

		v49.idle = true

		for _, v50 in v49.fx do
			v50.Bypass = true
		end
	end
end

function AudioGraph:lowpass(p: number)
	local filter = self.filter
	assert(filter, "[AudioGraph] a plain voice has no filter")

	if self.highpass then
		self.highpass = false
		filter.FilterType = Enum.AudioFilterType.Lowpass12dB
	end

	if p >= 19000 then
		if not self.bypass then
			self.bypass = true
			filter.Bypass = true
		end

		self.cutoff = 20000
	else
		local v48 = math.max(p, 40)

		if self.bypass then
			self.bypass = false
			filter.Bypass = false
		end

		if math.abs(v48 - self.cutoff) > 1 then
			filter.Frequency = v48
			self.cutoff = v48
		end
	end
end

function AudioGraph:highpass(cutoff: number)
	local filter = self.filter
	assert(filter, "[AudioGraph] a plain voice has no filter")

	if not self.highpass then
		self.highpass = true
		filter.FilterType = Enum.AudioFilterType.Highpass12dB
	end

	if self.bypass then
		self.bypass = false
		filter.Bypass = false
	end

	local frequency = math.clamp(cutoff, 20, 20000)

	if self.cutoff ~= cutoff or filter.Frequency ~= frequency then
		filter.Frequency = frequency
	end

	self.cutoff = cutoff
end

function AudioGraph.setEnclosure(p: number)
	v46 = p
	v5.WetLevel = p * 17 + -24
	v5.DecayTime = p * 0.8500000000000001 + 0.25
end

function AudioGraph.setDuck(value: number)
	v10.Volume = math.clamp(value, 0, 1)
end

local v48 = false

function AudioGraph.setMuffle(highGain: number, midGain: number, value: number?)
	local lowGain = value or 0
	v4.HighGain = highGain
	v4.MidGain = midGain
	v4.LowGain = lowGain
	local v50 = highGain ~= 0 or midGain ~= 0 or lowGain ~= 0

	if v50 ~= v48 then
		v48 = v50
		v4.Bypass = not v50
	end
end

local v49 = 0
local v50 = 0
local function applyMenu() -- 2 equivalent calls inferred from this helper
	v6.Volume = math.min(1 - v49 * 0.30000000000000004, 1 - v50 * 0.5)

	if v49 <= 0 and v50 <= 0 then
		v7.Bypass = true
		return
	end

	v7.Bypass = false
	v7.Frequency = math.min(0.15 ^ v49 * 20000, 0.035 ^ v50 * 20000)
end
function AudioGraph.setMenu(value: number)
	v49 = math.clamp(value, 0, 1)
	applyMenu() -- inferred equivalent call
end
function AudioGraph.setBounds(value: number)
	v50 = math.clamp(value, 0, 1)
	applyMenu() -- inferred equivalent call
end

function AudioGraph.setWorld(value: number)
	v8.Volume = math.clamp(value, 0, 1)
end

function AudioGraph.setShow(value: number)
	local v51 = math.clamp(value, 0, 1)
	v9.Volume = 1 - v51 * 0.75
	buses.music.input.Volume = 1 - v51
end

function AudioGraph.setLevels(value: number, value2: number)
	v2.Volume = math.clamp(value, 0, 1)
	v3.Volume = math.clamp(value2, 0, 1)
end

return AudioGraph