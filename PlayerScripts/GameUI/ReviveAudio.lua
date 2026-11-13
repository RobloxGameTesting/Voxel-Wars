local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local AudioGraph = require(Voxel:WaitForChild("AudioGraph"))
local VoxelSound = require(Voxel:WaitForChild("VoxelSound"))
local WorldConfig = require(Voxel:WaitForChild("WorldConfig"))

local v = {
	cloth = {
		id = 9119079222,
		from = 0.15,
		to = 0.42,
		gain = 0.5,
		fade = 0.03,
		lowpass = 6000,
		speed = 1
	},
	grab = {
		id = 9114725093,
		from = 0.45,
		to = 0.54,
		gain = 0.8,
		fade = 0.03,
		lowpass = 5000,
		speed = 0.9
	},
	knock = {
		id = 9118608146,
		from = 0,
		to = 0.3,
		gain = 0.55,
		fade = 0.08,
		lowpass = 3000,
		speed = 0.55
	},
	snap = {
		id = 9120409020,
		from = 0.09,
		to = 0.15,
		gain = 0.5,
		fade = 0.02,
		lowpass = 5000,
		speed = 0.9
	},
	hiss = {
		id = 9113052419,
		from = 0,
		to = 0.413,
		gain = 0.5,
		fade = 0.12,
		lowpass = 5000,
		speed = 1
	},
	latch = {
		id = 9116724840,
		from = 0.14,
		to = 0.26,
		gain = 0.6,
		fade = 0.05,
		lowpass = 6000,
		speed = 1
	},
	tick = {
		id = 9116605830,
		from = 0.3,
		to = 0.37,
		gain = 0.3,
		fade = 0.02,
		lowpass = 5000,
		speed = 1
	},
	timp = {
		id = 1842312794,
		from = 0.04,
		to = 1.7,
		gain = 0.32,
		fade = 0.9,
		lowpass = 6000,
		speed = 0.7113856589147287
	},
	ring = {
		id = 9113132724,
		from = 0.03,
		to = 0.8,
		gain = 0.26,
		fade = 0.5,
		lowpass = 6000,
		speed = 0.4871709456008536
	},
	beep = {
		id = 9120458059,
		from = 0.62,
		to = 1.08,
		gain = 0.72,
		fade = 0.06,
		lowpass = 4000,
		speed = 0.596869918699187
	},
	groan = {
		id = 9116457539,
		from = 0.42,
		to = 0.7,
		gain = 0.9,
		fade = 0.08,
		lowpass = 3500,
		speed = 1
	}
}

local v2 = {
	kit = {
		{ "cloth", 1 },
		{ "grab", 0.9 }
	},
	pump = {
		{ "knock", 1 },
		{ "cloth", 0.25 }
	},
	ready = {
		{ "snap", 1 }
	},
	inject = {
		{ "latch", 0.8 },
		{ "hiss", 1 }
	},
	letgo = {
		{ "cloth", 0.6 }
	},
	done = {
		{ "timp", 1 },
		{ "ring", 1 },
		{ "latch", 0.7 }
	},
	up = {
		{ "timp", 0.8 },
		{ "ring", 0.7 },
		{ "cloth", 1 }
	},
	request = {
		{ "knock", 1 },
		{ "beep", 0.45 }
	},
	called = {
		{ "tick", 0.7 },
		{ "beep", 1 },
		{ "timp", 0.3 }
	},
	groan = {
		{ "groan", 1 }
	},
	cancel = {
		{ "snap", 0.8 }
	},
	coming = {
		{ "tick", 1 }
	},
	beat = {
		{ "knock", 0.8 }
	}
}

local v3 = {}

local function slot(p: string)
	local v4 = v3[p]

	if v4 then
		return v4
	end

	local cut = assert(v[p], "[ReviveAudio] unknown cut " .. p)
	local players = {}

	for i = 1, 2 do
		local flat = AudioGraph.flat("Revive" .. p .. "_" .. i)
		AudioGraph.route(flat, "ui")
		AudioGraph.lowpass(flat, cut.lowpass)
		flat.player.Looping = false
		flat.player.Asset = "rbxassetid://" .. cut.id
		players[i] = flat.player
	end

	local v5 = { cut = cut, voices = players, next = 1 }
	v3[p] = v5
	return v5
end

local function fire(p: string, p2: number)
	local v4 = slot(p)
	local voice = v4.voices[v4.next]
	v4.next = v4.next % #v4.voices + 1
	local cut = v4.cut
	voice:Stop()
	voice.PlaybackRegion = NumberRange.new(cut.from, cut.to)
	voice.PlaybackSpeed = cut.speed
	voice.Volume = cut.gain * p2
	voice.TimePosition = cut.from
	voice:Play()
	local v5 = math.max((cut.to - cut.from) / cut.speed - cut.fade, 0)
	TweenService:Create(
		voice,
		TweenInfo.new(cut.fade, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, v5),
		{ Volume = 0 }
	):Play()
end

local ReviveAudio = {}
ReviveAudio.CUES = {
	{ 0, "kit" },
	{ 0.45, "pump" },
	{ 0.8, "pump" },
	{ 1.15, "pump" },
	{ 1.5, "pump" },
	{ 1.88, "kit" },
	{ 2.08, "ready" },
	{ 2.2, "inject" }
}

function ReviveAudio.own(p: string)
	for _, v4 in assert(v2[p], "[ReviveAudio] unknown cue " .. p) do
		fire(v4[1], v4[2])
	end
end

function ReviveAudio.world(p: string, vector3: Vector3)
	local v4 = (vector3 - workspace.CurrentCamera.CFrame.Position).Magnitude / WorldConfig.METER

	if v4 > 40 then
		return
	end

	local v5 = math.min(8 / math.max(v4, 1), 1) * (1 - v4 / 40)

	for _, v6 in assert(v2[p], "[ReviveAudio] unknown cue " .. p) do
		local v7 = v[v6[1]]
		VoxelSound.oneShotAt(v7.id, v7.from, v7.to - v7.from, vector3, v7.gain * v6[2] * v5, v7.speed)
	end
end

function ReviveAudio.call(p: number)
	for _, v4 in v2.called do
		fire(v4[1], v4[2] * p)
	end
end

function ReviveAudio.prepare()
	VoxelSound.addSamples({
		v.cloth.id,
		v.grab.id,
		v.knock.id,
		v.snap.id,
		v.hiss.id,
		v.latch.id,
		v.groan.id
	}, 2)

	for _, v4 in v2.called do
		slot(v4[1])
	end
end

return ReviveAudio