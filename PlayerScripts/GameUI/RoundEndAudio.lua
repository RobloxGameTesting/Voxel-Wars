local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local AudioGraph = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("AudioGraph"))
local MusicTracks = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("MusicTracks"))
local Music = require(script.Parent:WaitForChild("Music"))

local v = {
	banner = {
		id = 9125484367,
		from = 0,
		to = 4.4,
		gain = 0.45,
		fade = 0.5,
		speed = 1
	},
	board = {
		id = 1837830050,
		from = 0,
		to = 4.3,
		gain = 0.3,
		fade = 0.5,
		speed = 1
	},
	cardSub = {
		id = 1837830050,
		from = 0,
		to = 2.2,
		gain = 0.14,
		fade = 0.6,
		speed = 1
	},
	whoosh = {
		id = 1837831054,
		from = 0,
		to = 4.5,
		gain = 0.3,
		fade = 0.5,
		speed = 1
	},
	tick = {
		id = 9116605830,
		from = 0.3,
		to = 0.37,
		gain = 0.26,
		fade = 0.02,
		lowpass = 5000
	},
	part = {
		id = 9116724840,
		from = 0.14,
		to = 0.26,
		gain = 0.7,
		fade = 0.05,
		lowpass = 6000,
		room = true
	},
	latch = {
		id = 9116724840,
		from = 0.14,
		to = 0.5,
		gain = 0.6,
		fade = 0.2,
		lowpass = 6000,
		room = true
	},
	thump = {
		id = 1842312348,
		from = 0,
		to = 0.35,
		gain = 0.25,
		fade = 0.15,
		lowpass = 1500
	},
	timp = {
		id = 1842312794,
		from = 0.04,
		to = 1.7,
		gain = 0.42,
		fade = 0.9,
		room = true
	},
	ring = {
		id = 9113132724,
		from = 0.03,
		to = 0.8,
		gain = 0.3,
		fade = 0.5,
		lowpass = 6000,
		room = true
	},
	ringLong = {
		id = 9113132724,
		from = 0.03,
		to = 2.25,
		gain = 0.5,
		fade = 1.3,
		lowpass = 6000,
		room = true
	},
	lock = {
		id = 9116729158,
		from = 0,
		to = 0.45,
		gain = 1.2,
		fade = 0.15,
		lowpass = 7000,
		room = true
	},
	doneSub = {
		id = 9113487449,
		from = 0.042,
		to = 0.12,
		gain = 0.6,
		fade = 0.03
	},
	thud = {
		id = 9116605231,
		from = 0.56,
		to = 0.8,
		gain = 0.6,
		fade = 0.1,
		lowpass = 5000,
		room = true
	},
	plate = {
		id = 9116658377,
		from = 0,
		to = 0.25,
		gain = 0.3,
		fade = 0.12,
		lowpass = 6000,
		room = true
	},
	sweep = {
		id = 9046338511,
		from = 0.8,
		to = 1.6,
		gain = 0.5,
		fade = 0.02,
		lowpass = 8000,
		speed = 1
	},
	levelBoom = {
		id = 9038129641,
		from = 0,
		to = 4.35,
		gain = 0.28,
		fade = 0.6,
		speed = 1
	},
	brass = {
		id = 1843084213,
		from = 0.02,
		to = 2.3,
		gain = 0.85,
		fade = 1.3,
		lowpass = 6000,
		speed = 1,
		room = true
	},
	riser = {
		id = 101937236820642,
		from = 1.3,
		to = 2.1,
		gain = 0.25,
		fade = 0.03,
		speed = 1
	},
	glitch = {
		id = 9118040516,
		from = 0.2,
		to = 0.6,
		gain = 0.3,
		fade = 0.12,
		lowpass = 4500,
		speed = 1
	},
	clank = {
		id = 9116751108,
		from = 0,
		to = 0.39,
		gain = 0.6,
		fade = 0.15,
		speed = 0.93,
		room = true
	},
	crackle = {
		id = 9118763011,
		from = 0.95,
		to = 1.55,
		gain = 0.3,
		fade = 0.3,
		lowpass = 5000,
		room = true
	},
	pulse = {
		id = 9043367506,
		from = 0.05,
		to = 0.3,
		gain = 0.15,
		fade = 0.12,
		lowpass = 400
	},
	blip = {
		id = 9118040516,
		from = 0.2,
		to = 0.34,
		gain = 0.3,
		fade = 0.06,
		lowpass = 4500,
		speed = 1
	},
	rise = {
		id = 9046338511,
		from = 1.25,
		to = 1.6,
		gain = 0.32,
		fade = 0.02,
		lowpass = 8000,
		speed = 1
	},
	sting = {
		id = 1841824473,
		from = 0,
		to = 5.1,
		gain = 0.22,
		fade = 1.4,
		lowpass = 9000,
		speed = 1
	},
	finale = {
		id = 1841824596,
		from = 0,
		to = 6.4,
		gain = 0.2,
		fade = 1.8,
		lowpass = 9000,
		speed = 1
	}
}

local function timpSpeed(p: number) -- 7 equivalent calls inferred from this helper
	return p / 206.4
end

local function ringSpeed(p: number) -- 2 equivalent calls inferred from this helper
	return 2 ^ ((p - 0.45) / 12)
end

local function asset(p: number)
	return "rbxassetid://" .. p
end

local v2 = {
	tick = 4,
	part = 3,
	latch = 3,
	timp = 4,
	ring = 4,
	pulse = 3,
	blip = 3,
	lock = 3,
	plate = 3
}

local v3 = {}
local v4 = {}
local RoundEndAudio = {}
RoundEndAudio.WHOOSH_LEAD = 0.75
RoundEndAudio.SWEEP_LEAD = 0.8
local v5 = {
	{ 146.83, -12 },
	{ 174.61, -9 },
	{ 196, -7 },
	{ 196, -5 }
}
local v6 = {
	{ 146.83, -12 },
	{ 174.61, -9 },
	{ 196, -5 },
	{ 146.83, 0 }
}

for k, cut in v do
	local players = {}
	local flats = {}

	for i = 1, v2[k] or 2 do
		local flat = AudioGraph.flat("RoundEnd_" .. k .. "_" .. i)
		AudioGraph.route(flat, "ui")

		if cut.lowpass then
			AudioGraph.lowpass(flat, cut.lowpass)
		end

		flat.player.Looping = false
		flat.player.Asset = "rbxassetid://" .. cut.id
		players[i] = flat.player
		flats[i] = flat
	end

	v3[k] = { cut = cut, voices = players, full = flats, next = 1 }
end

local flat = AudioGraph.flat("RoundEnd_roll")
AudioGraph.route(flat, "ui")
flat.player.Looping = false
flat.player.Asset = "rbxassetid://" .. 1840207712
flat.player.Volume = 0
local flat2 = AudioGraph.flat("RoundEnd_drive")
AudioGraph.route(flat2, "ui")
AudioGraph.lowpass(flat2, 1800)
flat2.player.Looping = false
flat2.player.Asset = "rbxassetid://" .. 9114583250
flat2.player.Volume = 0

local v7 = {}

for k, track in { win = MusicTracks.WIN, loss = MusicTracks.LOSS } do
	assert(track and track.asset, "[RoundEndAudio] MusicTracks has no " .. k .. " stinger")
	local flat3 = AudioGraph.flat("RoundEndStinger_" .. k, false, nil, true)
	AudioGraph.route(flat3, "music")
	flat3.player.Looping = false
	flat3.player.Asset = track.asset
	flat3.player.Volume = 0
	v7[k] = { track = track, player = flat3.player }
end

task.delay(20, function()
	for k, v8 in v3 do
		for _, voice in v8.voices do
			if not voice.IsReady then
				warn("[RoundEndAudio] cue " .. k .. " (" .. voice.Asset .. ") has not loaded")
				break
			end
		end
	end

	for k, v8 in v7 do
		if not v8.player.IsReady then
			warn("[RoundEndAudio] " .. k .. " stinger (" .. v8.player.Asset .. ") has not loaded")
		end
	end
end)

local fn

local function fire(p: string, value: number?, p2: number?)
	local v8 = v3[p]
	assert(v8, "[RoundEndAudio] unknown cue " .. p)
	local cut = v8.cut
	local nextNode = v8.next
	local voice = v8.voices[nextNode]
	v8.next = nextNode % #v8.voices + 1

	for i = #v4, 1, -1 do
		if v4[i].player == voice then
			table.remove(v4, i)
		end
	end

	local playbackSpeed = math.min(p2 or cut.speed or 0.95 + 0.05 * math.random(), 1)
	local v9 = cut.gain * (value or 1)

	if cut.room then
		AudioGraph.route(v8.full[nextNode], "uiroom", os.clock() + (cut.to - cut.from) / playbackSpeed)
	end

	voice:Stop()
	voice.PlaybackRegion = NumberRange.new(cut.from, cut.to)
	voice.PlaybackSpeed = playbackSpeed
	voice.Volume = v9
	voice.TimePosition = cut.from
	voice:Play()
	table.insert(v4, {
		player = voice,
		gain = v9,
		endAt = os.clock() + (cut.to - cut.from) / playbackSpeed,
		fade = cut.fade
	})
	fn()
end

local v8 = nil
local v9 = -1
local v10 = 1
local count = 0
local v11 = 1

local flag = false
local v12 = 0
local function stopFill() -- 3 equivalent calls inferred from this helper
	flag = false
	v12 = 0
	flat.player.Volume = 0
	flat2.player.Volume = 0
	flat.player:Stop()
	flat2.player:Stop()
end

local heartbeatConnection = nil
local function step(p: number)
	local now = os.clock()

	if flag or v12 > 0 then
		local v13

		if flag then
			v13 = math.min(1, v12 + p / 0.06)
		else
			v13 = math.max(0, v12 - p / 0.2)
		end

		v12 = v13

		if v12 <= 0 then
			stopFill() -- inferred equivalent call
		else
			flat.player.Volume = v12 * 0.6
			flat2.player.Volume = v12 * 0.08
		end
	end

	for i = #v4, 1, -1 do
		local v13 = v4[i]
		local v14 = v13.endAt - now

		if v14 <= 0 then
			v13.player:Stop()
			table.remove(v4, i)
		elseif v14 < v13.fade then
			v13.player.Volume = v13.gain * v14 / v13.fade
		end
	end

	local v13 = v8

	if v13 and v9 > 0 then
		local v14 = (now - v9) / 1.5

		if v14 >= 1 then
			v13.player:Stop()
			v8 = nil
			v9 = -1
		else
			v13.player.Volume = v13.track.gain * (1 - v14)
		end
	end

	if v10 ~= v11 then
		local v14 = p * 0.95 / (v11 < v10 and 0.3 or 1)
		local v15

		if v11 < v10 then
			v15 = math.max(v11, v10 - v14)
		else
			v15 = math.min(v11, v10 + v14)
		end

		v10 = v15
		AudioGraph.setWorld(v10)
	end

	if #v4 == 0 and not (v8 and v9 > 0) and v10 == v11 and not flag and v12 == 0 and heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end
fn = function()
	if not heartbeatConnection then
		heartbeatConnection = RunService.Heartbeat:Connect(step)
	end
end

function RoundEndAudio.start(flag2: boolean, p: number)
	v11 = 0.05
	fn()

	if v8 then
		v8.player:Stop()
		v8 = nil
	end

	v9 = -1

	if p < 12.7 then
		local v13 = v7[flag2 and "win" or "loss"]
		local player = v13.player
		player:Stop()
		player.PlaybackSpeed = 1
		player.Volume = v13.track.gain
		player.TimePosition = v13.track.start + math.max(0, p)
		player:Play()
		v8 = v13
		count += 1
		local v14 = count
		task.delay(math.max(0, v13.track.bedAt - p), function()
			if v14 == count then
				Music.roundBed(true)
			end
		end)
	end

	if p < 0.3 then
		fire("banner")
	end
end

function RoundEndAudio.toLevel()
	if v8 and v9 < 0 then
		v9 = os.clock()
		fn()
	end

	Music.roundBed(true)
end

function RoundEndAudio.fadeOut()
	stopFill() -- inferred equivalent call
	count += 1
	Music.roundBed(false)
end

function RoundEndAudio.stop()
	stopFill() -- inferred equivalent call

	if v8 then
		v8.player:Stop()
		v8 = nil
	end

	v9 = -1
	count += 1
	Music.roundBed(false)
	v11 = 1
	fn()
end

function RoundEndAudio.boardIn()
	fire("board")
end

function RoundEndAudio.rowTick()
	fire("tick")
end

function RoundEndAudio.whoosh()
	fire("whoosh")
end

function RoundEndAudio.fill(flag2: boolean, p: number)
	if flag2 and not flag then
		flag = true
		flat.player:Stop()
		flat.player.PlaybackRegion = NumberRange.new(1.5, 4.5)
		flat.player.TimePosition = 1.5
		flat.player:Play()
		flat2.player:Stop()
		flat2.player.PlaybackRegion = NumberRange.new(1, 15)
		flat2.player.TimePosition = 1
		flat2.player:Play()
		fn()
	elseif not flag2 and flag then
		flag = false
	end

	if flag2 then
		flat2.player.PlaybackSpeed = p * 0.25 + 0.75
	end
end

function RoundEndAudio.pop(p: number, p2: number)
	local v13 = v5[math.min(p + math.max(0, #v5 - p2), #v5)]
	fire("latch")
	fire("timp", 1, timpSpeed(v13[1])) -- inferred equivalent call
	fire("ring", 1, ringSpeed(v13[2])) -- inferred equivalent call
	fire("thump")
end

function RoundEndAudio.part(p: number)
	fire("part", 1, p * 0.15 + 0.85)
end

function RoundEndAudio.groupEnd()
	fire("latch", 0.8)
end

function RoundEndAudio.done()
	fire("ringLong", 1, 0.9743418912017071)
	fire("timp", 1.2, timpSpeed(146.83)) -- inferred equivalent call
	fire("lock")
	fire("doneSub")
end

function RoundEndAudio.tileLand()
	fire("thud")
	fire("timp", 0.3, timpSpeed(146.83)) -- inferred equivalent call
end

function RoundEndAudio.card(p: number, flag2: boolean)
	if flag2 then
		fire("lock", 0.45)
		fire("timp", 0.3, timpSpeed(146.83)) -- inferred equivalent call
	else
		local v13 = v6[math.min(p, #v6)]
		fire("plate")
		fire("lock", 0.55)
		fire("timp", 0.7, timpSpeed(v13[1])) -- inferred equivalent call
		fire("ring", 1, ringSpeed(v13[2])) -- inferred equivalent call
		fire("cardSub")
	end
end

function RoundEndAudio.sweep()
	fire("sweep")
	fire("riser")
end

function RoundEndAudio.glitch()
	fire("glitch")
end

local v13 = {
	{ 0.28, 1 },
	{ 0.56, 0.7 },
	{ 0.84, 0.45 }
}

function RoundEndAudio.levelUp(flag2: boolean?)
	fire("levelBoom")
	fire("brass", flag2 and 0.5 or 1)
	fire("timp", flag2 and 0.75 or 1.5, timpSpeed(146.83)) -- inferred equivalent call
	fire("clank")
	fire("crackle")
	task.delay(0.06, fire, "ringLong", 0.8, 0.9743418912017071)

	for _, v14 in v13 do
		task.delay(v14[1], fire, "pulse", v14[2])
	end
end

function RoundEndAudio.weaponDecode()
	fire("glitch", 0.325)
end

function RoundEndAudio.weaponLand()
	fire("part", 0.39)
	fire("timp", 0.1625, timpSpeed(146.83)) -- inferred equivalent call
	fire("whoosh", 0.45499999999999996)
end

function RoundEndAudio.weaponFill(value: number)
	fire("tick", 0.45499999999999996, math.clamp(value, 0, 1) * 0.2 + 0.8)
end

function RoundEndAudio.weaponRise(p: number)
	local rise = v.rise
	task.delay(math.max(0, p - (rise.to - rise.from)), fire, "rise", 0.39)
end

function RoundEndAudio.weaponLevel(flag2: boolean)
	fire(flag2 and "finale" or "sting")
	fire("lock", 0.52)
	fire("plate", 0.78)
	fire("clank", 0.325)
	fire("crackle", 0.52)
	task.delay(0.04, fire, "ringLong", 0.39, 0.9743418912017071)

	if flag2 then
		fire("brass", 0.325)
	end
end

function RoundEndAudio.weaponTileDecode()
	fire("blip", 0.195)
end

function RoundEndAudio.weaponTile()
	fire("thump", 0.35750000000000004)
end

function RoundEndAudio.tick(p: number?, value: number?)
	fire("tick", p, 0.8 + 0.2 * (value or 1))
end

return RoundEndAudio