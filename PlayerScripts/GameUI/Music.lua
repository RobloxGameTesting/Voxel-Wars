local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local AudioGraph = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("AudioGraph"))
local MusicTracks = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("MusicTracks"))

local Music = {}

local flat = AudioGraph.flat("Music", false, nil, true)
AudioGraph.route(flat, "music")
local player = flat.player
player.Looping = false

local v = nil
local flag = false
local v2 = -1
local v3 = 1
local v4 = -1
local flag2 = false

local heartbeatConnection = nil
local onHeartbeat
local fn
local v5 = false

local function load(p: string) -- 2 equivalent calls inferred from this helper
	local v6 = MusicTracks.byId[p]
	assert(v6, "[Music] unknown track " .. tostring(p))

	if v ~= v6 then
		v = v6
		player.Asset = v6.asset
	end

	return v6
end

function Music.prepare(p: string)
	if p ~= MusicTracks.OFF and not flag then
		load(p) -- inferred equivalent call
	end
end

function Music.play(p: string, value: number?)
	if p == MusicTracks.OFF then
		Music.stop()
		return
	end

	local v6 = load(p) -- inferred equivalent call
	player:Stop()
	player.Volume = v6.gain
	player.TimePosition = v6.start + math.max(0, value or 0)
	player:Play()
	flag = true
	flag2 = false
	v2 = -1
	v4 = -1

	if not heartbeatConnection then
		heartbeatConnection = RunService.Heartbeat:Connect(onHeartbeat)
	end
end

function Music.fadeOut(p: number)
	if flag and v2 < 0 then
		local now = os.clock()
		local v6 = math.max(p, 0.05)
		v2 = now
		v3 = v6
	end
end

function Music.stop()
	player:Stop()
	flag = false
	flag2 = false
	v2 = -1
	v4 = -1
	fn()
end

function Music.preview(p: string)
	if p == MusicTracks.OFF then
		Music.stop()
		return
	end

	Music.play(p, (math.max(0, MusicTracks.byId[p].hit - 7)))
	flag2 = true
	v4 = os.clock() + 10
end

function Music.endPreview()
	if flag2 then
		Music.fadeOut(0.4)
	end
end

function Music.isPlaying()
	return flag
end

onHeartbeat = function()
	if flag then
		local now = os.clock()

		if v4 > 0 and v4 <= now then
			v4 = -1
			Music.fadeOut(1.5)
		end

		if v2 > 0 then
			local v6 = (now - v2) / v3

			if v6 >= 1 then
				Music.stop()
			else
				player.Volume = v.gain * (1 - v6)
			end
		elseif not player.IsPlaying and player.TimePosition > 0 and v and player.TimePosition >= v.length - 0.05 then
			flag = false
			fn()
		end
	elseif heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

local menu = MusicTracks.MENU
local players = {}

for i = 1, 2 do
	local flat2 = AudioGraph.flat("MenuBed" .. i, false, nil, true)
	AudioGraph.route(flat2, "music")
	flat2.player.Looping = false
	flat2.player.Asset = menu.asset
	flat2.player.Volume = 0
	players[i] = flat2.player
end

local v6 = false
local LocalPlayer = Players.LocalPlayer
local function inMatch(): boolean -- 1 equivalent call inferred from this helper
	return LocalPlayer.Team ~= nil and not LocalPlayer.Neutral
end

local v7 = false

local v8 = 0
local v9 = 1
local v10 = 0
local v11 = -1

function Music.menu(flag3: boolean)
	v6 = flag3
	fn()
end

function Music.roundBed(flag3: boolean)
	v7 = flag3
	fn()
end

local v12 = -1
local v13 = 8
local v14 = false
function Music.tail(p: number, p2: number)
	v12 = os.clock() + math.max(p, 0)
	v13 = math.max(p2, 0.1)
	fn()
end

local heartbeatConnection2 = nil
local function bedStep(p: number)
	local now = os.clock()
	local v15

	if v12 > 0 then
		v15 = now < v12
	else
		v15 = false
	end

	if v12 > 0 and not v15 then
		v12 = -1
		v14 = true
	end

	local v16 = v6 and not (flag or v5) and not inMatch() -- inferred equivalent call

	if v7 or v16 or v15 then
		if v7 or v16 then
			v14 = false
		end

		v8 = math.min(1, v8 + p / (v7 and 1.5 or v16 and 1.2 or 2))
	else
		v8 = math.max(0, v8 - p / (not v14 and 0.6 or v13))
	end

	local v17

	if v7 then
		v17 = MusicTracks.ROUND_END_BED
	else
		v17 = v16 and 1 or MusicTracks.DEPLOY_BED
	end

	if v8 <= 0 then
		v9 = v17
		v14 = false
	else
		v9 += math.clamp(v17 - v9, -p / 0.5, p / 0.5)
	end

	if v8 <= 0 then
		if v10 ~= 0 then
			for _, v18 in players do
				v18:Stop()
			end

			v10 = 0
			v11 = -1
		end

		if not v7 and not v16 and not v15 and heartbeatConnection2 then
			heartbeatConnection2:Disconnect()
			heartbeatConnection2 = nil
		end
	else
		if v10 == 0 then
			v10 = 1
			players[1].TimePosition = 0
			players[1]:Play()
		elseif players[v10].TimePosition >= menu.loopAt then
			v10 = 3 - v10
			local v18 = players[v10]
			v18:Stop()
			v18.TimePosition = 0
			v18:Play()
			v11 = now
		end

		local v18 = players[3 - v10]
		local v19

		if v11 > 0 then
			v19 = math.clamp((now - v11) / 0.4, 0, 1)

			if v19 >= 1 then
				v18:Stop()
				v11 = -1
			end
		else
			v19 = 1
		end

		local v20 = menu.gain * v8 * v9
		players[v10].Volume = v20 * math.sqrt(v19)
		v18.Volume = not (v11 > 0) and 0 or v20 * math.sqrt(1 - v19)
	end
end
fn = function()
	if not heartbeatConnection2 then
		heartbeatConnection2 = RunService.Heartbeat:Connect(bedStep)
	end
end
fn()

LocalPlayer:GetPropertyChangedSignal("Team"):Connect(fn)
LocalPlayer:GetPropertyChangedSignal("Neutral"):Connect(fn)

local players2 = {}

for k, v15 in MusicTracks.CUES do
	local flat2 = AudioGraph.flat("Cue_" .. k, false, nil, true)
	AudioGraph.route(flat2, "music")
	flat2.player.Looping = false
	flat2.player.Asset = v15.asset
	flat2.player.Volume = 0
	players2[k] = flat2.player
end

local v15 = nil
local v16 = 0
local v17 = 0
local v18 = -1
local v19 = 2.5
local heartbeatConnection3 = nil

local function cueEnd() -- 2 equivalent calls inferred from this helper
	if v15 then
		players2[v15]:Stop()
	end

	v15 = nil
	v5 = false

	if heartbeatConnection3 then
		heartbeatConnection3:Disconnect()
		heartbeatConnection3 = nil
	end

	fn()
end

local function cueStep()
	local v20 = v15
	local now = os.clock()

	if v18 < 0 and v17 <= now then
		v18 = now
		v19 = 2.5
	end

	local v21 = v18 < 0 and 1 or 1 - (now - v18) / v19

	if not (v21 <= 0) then
		players2[v20].Volume = MusicTracks.CUES[v20].gain * math.min((now - v16) / 0.4, 1) * v21
		return
	end

	cueEnd() -- inferred equivalent call
end

function Music.cue(p: string, value: number?)
	local v20 = MusicTracks.CUES[p]
	assert(v20, "[Music] unknown cue " .. tostring(p))
	cueEnd() -- inferred equivalent call
	local v21 = players2[p]
	v21.Volume = 0
	v21.TimePosition = v20.start + (value or 0)
	v21:Play()
	v15 = p
	v5 = true
	local now = os.clock()
	local v22 = os.clock() + v20.stop - (value or 0)
	v16 = now
	v17 = v22
	v18 = -1
	heartbeatConnection3 = RunService.Heartbeat:Connect(cueStep)
end

function Music.cueHit(p: string)
	local v20 = MusicTracks.CUES[p]
	assert(v20, "[Music] unknown cue " .. tostring(p))
	local v21 = players2[p]
	v21.Volume = v20.gain
	v21.TimePosition = v20.start
	v21:Play()
end

function Music.cueOut(p: number)
	if v15 and v18 < 0 then
		local now = os.clock()
		local v20 = math.max(p, 0.05)
		v18 = now
		v19 = v20
	end
end

function Music.cuePlaying()
	return v5
end

return Music