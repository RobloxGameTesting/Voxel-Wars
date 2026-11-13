local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local AudioGraph = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("AudioGraph"))

local v = {
	swell = {
		id = 9046338511,
		from = 1.25,
		to = 1.6,
		gain = 0.32,
		fade = 0.02,
		lowpass = 8000,
		speed = 1
	},
	boom = {
		id = 9038129641,
		from = 0,
		to = 2.6,
		gain = 0.16,
		fade = 0.7,
		lowpass = 6000,
		speed = 1
	},
	clank = {
		id = 9117375064,
		from = 0,
		to = 0.9,
		gain = 0.5,
		fade = 0.4,
		lowpass = 4500,
		speed = 0.65
	},
	thump = {
		id = 1842312348,
		from = 0,
		to = 0.35,
		gain = 0.22,
		fade = 0.15,
		lowpass = 1500,
		speed = 1
	},
	chime = {
		id = 9117375071,
		from = 0,
		to = 1.4,
		gain = 0.42,
		fade = 0.55,
		lowpass = 4500,
		speed = 0.69
	},
	tink = {
		id = 9117375071,
		from = 0,
		to = 0.15,
		gain = 0.3,
		fade = 0.12,
		lowpass = 4500,
		speed = 0.69
	},
	pay = {
		id = 9117375064,
		from = 0,
		to = 0.35,
		gain = 0.3,
		fade = 0.2,
		lowpass = 4000,
		speed = 0.65
	},
	nut = {
		id = 9125419091,
		from = 0,
		to = 0.04,
		gain = 0.32,
		fade = 0.01,
		lowpass = 3500,
		speed = 1
	},
	brass = {
		id = 1840091929,
		from = 0.04,
		to = 2.8,
		gain = 0.55,
		fade = 0.9,
		lowpass = 9000,
		speed = 1
	},
	hull = {
		id = 9116892160,
		from = 0.69,
		to = 2.6,
		gain = 0.45,
		fade = 1,
		lowpass = 5000,
		speed = 1
	},
	sub = {
		id = 9119661508,
		from = 0.13,
		to = 1.6,
		gain = 0.5,
		fade = 0.6,
		lowpass = 2000,
		speed = 1
	},
	plate = {
		id = 9116658377,
		from = 0,
		to = 0.25,
		gain = 0.55,
		fade = 0.12,
		lowpass = 6000,
		speed = 1
	},
	rack = {
		id = 9116357621,
		from = 0.08,
		to = 0.32,
		gain = 0.55,
		fade = 0.08,
		lowpass = 8000,
		speed = 1
	},
	tick = {
		id = 9113147007,
		from = 0,
		to = 0.03,
		gain = 0.5,
		fade = 0.01,
		lowpass = 2500,
		speed = 1
	},
	unlock = {
		id = 127087932061391,
		from = 0.02,
		to = 4.2,
		gain = 0.33,
		fade = 0.8,
		lowpass = 9000,
		speed = 1
	},
	latch = {
		id = 9116729158,
		from = 0,
		to = 0.45,
		gain = 1.4,
		fade = 0.15,
		lowpass = 7000,
		speed = 1
	},
	done = {
		id = 9117060347,
		from = 0,
		to = 0.24,
		gain = 0.6,
		fade = 0.1,
		lowpass = 8000,
		speed = 0.96
	},
	prizeSwell = {
		id = 9046338511,
		from = 1.25,
		to = 1.6,
		gain = 0.6,
		fade = 0.02,
		lowpass = 8000,
		speed = 1
	},
	roll = {
		id = 1842312794,
		from = 0.04,
		to = 0.3,
		gain = 0.2,
		fade = 0.2,
		lowpass = 20000,
		speed = 1
	},
	timp = {
		id = 1842312794,
		from = 0.04,
		to = 1.7,
		gain = 0.42,
		fade = 0.9,
		lowpass = 20000,
		speed = 1,
		room = true
	},
	ring = {
		id = 9113132724,
		from = 0.03,
		to = 0.8,
		gain = 0.3,
		fade = 0.5,
		lowpass = 6000,
		speed = 1,
		room = true
	},
	ringLong = {
		id = 9113132724,
		from = 0.03,
		to = 2.25,
		gain = 0.5,
		fade = 1.3,
		lowpass = 6000,
		speed = 1,
		room = true
	},
	buzz = {
		id = 1843084213,
		from = 0.02,
		to = 2,
		gain = 0.55,
		fade = 1,
		lowpass = 6000,
		speed = 1,
		room = true
	},
	lock = {
		id = 9116729158,
		from = 0,
		to = 0.45,
		gain = 1.2,
		fade = 0.15,
		lowpass = 7000,
		speed = 1,
		room = true
	},
	latchTick = {
		id = 9116605830,
		from = 0.3,
		to = 0.37,
		gain = 0.3,
		fade = 0.02,
		lowpass = 5000,
		speed = 1
	}
}

local function ringSpeed(p: number) -- 2 equivalent calls inferred from this helper
	return 2 ^ ((p - 0.45) / 12)
end

local v2 = {
	nut = 4,
	tick = 4,
	roll = 4,
	timp = 4,
	ring = 4,
	latchTick = 4,
	plate = 4
}

local v3 = {}
local v4 = {}
local ClaimAudio = {}

local v5 = { -12, -10, -9, -7, -5 }

for k, cut in v do
	local players = {}
	local flats = {}

	for i = 1, v2[k] or 2 do
		local flat = AudioGraph.flat("Claim_" .. k .. "_" .. i)
		AudioGraph.route(flat, "ui")
		AudioGraph.lowpass(flat, cut.lowpass)
		flat.player.Looping = false
		flat.player.Asset = "rbxassetid://" .. cut.id
		players[i] = flat.player
		flats[i] = flat
	end

	v3[k] = { cut = cut, voices = players, full = flats, next = 1 }
end

task.delay(20, function()
	for k, v6 in v3 do
		for _, voice in v6.voices do
			if not voice.IsReady then
				warn("[ClaimAudio] cue " .. k .. " (" .. voice.Asset .. ") has not loaded")
				break
			end
		end
	end
end)

local heartbeatConnection = nil
local function step()
	local now = os.clock()

	for i = #v4, 1, -1 do
		local v6 = v4[i]
		local v7 = v6.endAt - now

		if v7 <= 0 then
			v6.player:Stop()
			table.remove(v4, i)
		elseif v7 < v6.fade then
			v6.player.Volume = v6.gain * v7 / v6.fade
		end
	end

	if #v4 == 0 and heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

local function fire(p: string, value: number?, p2: number?, p3: number?)
	local v6 = v3[p]
	assert(v6, "[ClaimAudio] unknown cue " .. p)
	local cut = v6.cut
	local nextNode = v6.next
	local voice = v6.voices[nextNode]
	v6.next = v6.next % #v6.voices + 1

	for i = #v4, 1, -1 do
		if v4[i].player == voice then
			table.remove(v4, i)
		end
	end

	local playbackSpeed = math.min(p2 or cut.speed, 1)
	local v7 = cut.gain * (value or 1)
	local timePosition = math.clamp(p3 or cut.from, cut.from, cut.to)

	if cut.room then
		AudioGraph.route(v6.full[nextNode], "uiroom", os.clock() + (cut.to - timePosition) / playbackSpeed)
	end

	voice:Stop()
	voice.PlaybackRegion = NumberRange.new(cut.from, cut.to)
	voice.PlaybackSpeed = playbackSpeed
	voice.Volume = v7
	voice.TimePosition = timePosition
	voice:Play()
	table.insert(v4, {
		player = voice,
		gain = v7,
		endAt = os.clock() + (cut.to - timePosition) / playbackSpeed,
		fade = cut.fade
	})

	if not heartbeatConnection then
		heartbeatConnection = RunService.Heartbeat:Connect(step)
	end
end

function ClaimAudio.badgeIn(p: number)
	local swell = v.swell
	task.delay(math.max(0, p - (swell.to - swell.from)), fire, "swell")
end

function ClaimAudio.badgeSlam()
	fire("plate")
	fire("sub")
	fire("hull")
	fire("brass")
end

function ClaimAudio.press()
	fire("rack")
end

function ClaimAudio.badgeHome()
	fire("tink")
end

function ClaimAudio.awardIn(p: number)
	local swell = v.swell
	task.delay(math.max(0, p - (swell.to - swell.from)), fire, "swell", 0.8)
end

function ClaimAudio.awardSlam()
	fire("boom", 0.6)
	fire("clank", 0.85)
	fire("thump")
	task.delay(0.12, fire, "chime", 0.85)
end

function ClaimAudio.awardTick()
	fire("tink", 0.8)
end

function ClaimAudio.rewardIn(p: number)
	ClaimAudio.badgeIn(p)
end

function ClaimAudio.rewardHit()
	ClaimAudio.badgeSlam()
end

function ClaimAudio.purchaseIn(p: number)
	local swell = v.swell
	local v6 = swell.to - swell.from

	if v6 <= p then
		task.delay(p - v6, fire, "swell", 0.8)
	else
		fire("swell", 0.8, nil, swell.to - p)
	end
end

local v6 = 0
function ClaimAudio.hush(p: number)
	if p ~= v6 then
		v6 = p
		AudioGraph.setShow(p)
	end
end

function ClaimAudio.purchaseLand()
	fire("latch")
end

function ClaimAudio.purchaseHit()
	fire("unlock")
	fire("plate", 0.4)
end

function ClaimAudio.countTick(value: number)
	fire("tick", 1, math.clamp(value, 0, 1) * 0.15 + 0.85)
end

function ClaimAudio.countDone()
	fire("done")
	fire("tink", 0.8)
end

function ClaimAudio.prizeIn(p: number)
	local prizeSwell = v.prizeSwell
	local v7 = prizeSwell.to - prizeSwell.from

	if v7 <= p then
		task.delay(p - v7, fire, "prizeSwell")
	else
		fire("prizeSwell", 1, nil, prizeSwell.to - p)
	end

	for k, v8 in { 0.24, 0.17, 0.11, 0.06 } do
		if v8 <= p then
			task.delay(p - v8, fire, "roll", 0.2 + 0.2 * k, 0.7113856589147287)
		end
	end
end

function ClaimAudio.prizeHit()
	fire("lock")
	fire("timp", 1.2, 0.7113856589147287)
	fire("buzz")
	fire("plate", 0.73)
	fire("sub", 0.24)
end

function ClaimAudio.prizeTick(value: number)
	local v7 = math.clamp(math.ceil(value * #v5), 1, #v5)
	fire("latchTick")
	fire("ring", math.clamp(value, 0, 1) * 0.15 + 0.6, ringSpeed(v5[v7])) -- inferred equivalent call
end

function ClaimAudio.prizeDone()
	fire("ringLong", 0.8, 0.9743418912017071)
	fire("timp", 0.8, 0.7113856589147287)
	fire("lock", 0.6)
end

function ClaimAudio.giftIn()
	fire("ring", 0.5, 0.4871709456008536)
	fire("timp", 0.5, 0.7113856589147287)
	fire("latchTick")
end

function ClaimAudio.giftOpen()
	fire("lock", 0.9)
	fire("plate", 0.6)
	fire("timp", 0.9, 0.7113856589147287)
end

function ClaimAudio.crateDrop()
	fire("thump", 1.6)
	fire("pay", 0.8)
	fire("sub", 0.3)
end

function ClaimAudio.crateLatch(p: number)
	fire("latch", p >= 2 and 0.85 or 0.65)
	fire("latchTick")
end

function ClaimAudio.crateRoll(value: number)
	fire("roll", math.clamp(value, 0, 1) * 2.2 + 1, 0.7113856589147287)
end

function ClaimAudio.crateBurst(p: number, value: number?)
	local v7 = value or 1
	fire("lock", 0.9 * v7)
	fire("plate", (p * 0.1 + 0.5) * v7)
	fire("timp", (p * 0.15 + 0.8) * v7, 0.7113856589147287)
	fire("sub", (p * 0.15 + 0.2) * v7)

	if p >= 2 then
		fire("buzz", ((p - 2) * 0.15 + 0.6) * v7)
	end

	if p >= 3 then
		fire("hull", 0.7 * v7)
		fire("ringLong", 0.7 * v7, 0.9743418912017071)
	end

	if p >= 4 then
		task.delay(0.2, fire, "timp", 1.3 * v7, 0.35569282945736436)
	end
end

local v7 = { -12, -9, -5, 0 }
function ClaimAudio.crateShow(value: number)
	fire("ring", 0.8, ringSpeed(v7[math.clamp(value, 1, #v7)])) -- inferred equivalent call
	fire("latchTick")
end

function ClaimAudio.crateVictory(p: number, flag: boolean, value: number?)
	local v8 = value or 1

	if flag then
		fire("unlock", 1.15)
	end

	fire("plate", 0.8 * v8)
	fire("timp", (p * 0.1 + 1) * v8, 0.7113856589147287)
	fire("sub", (p * 0.12 + 0.4) * v8)
	fire("ring", 0.9 * v8, 0.4871709456008536)
	task.delay(0.11, fire, "ring", 1 * v8, 0.7299316754424637)
	task.delay(0.22, fire, "ringLong", 1 * v8, 0.9743418912017071)

	if p >= 2 then
		fire("buzz", ((p - 2) * 0.12 + 0.7) * v8)
	end

	if p >= 3 then
		fire("hull", 0.8 * v8)
		task.delay(0.22, fire, "timp", 1.2 * v8, 0.35569282945736436)
	end

	if p >= 4 then
		task.delay(0.72, fire, "timp", 0.9500000000000001 * v8, 0.7113856589147287)
		task.delay(0.94, fire, "timp", 1.1 * v8, 0.7113856589147287)
		task.delay(1.1600000000000001, fire, "timp", 1.25 * v8, 0.7113856589147287)

		task.delay(1.16, fire, "plate", 0.7 * v8)
	end
end

function ClaimAudio.crateSalute(value: number?)
	local v8 = value or 1
	fire("roll", 1.5 * v8, 0.7113856589147287)
	fire("plate", 0.28 * v8)
end

function ClaimAudio.pay()
	fire("pay")
end

function ClaimAudio.nut(value: number)
	fire("nut", 1, math.clamp(value, 0, 1) * 0.1 + 0.9)
end

return ClaimAudio