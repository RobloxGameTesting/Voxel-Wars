local ContentProvider = game:GetService("ContentProvider")
local v = game:GetService("RunService")

local AudioGraph = require(script.Parent:WaitForChild("AudioGraph"))
local Materials = require(script.Parent:WaitForChild("Materials"))
local WorldConfig = require(script.Parent:WaitForChild("WorldConfig"))

local meter = WorldConfig.METER

local VoxelSound = {}

do
	local v2 = {}
	local function slice(p: number, from: number, to: number) -- 8 equivalent calls inferred from this helper
		local id = "rbxassetid://" .. p
		v2[id] = (v2[id] or 0) + 1
		return { id = id, from = from, to = to, range = NumberRange.new(from, to) }
	end

	local function gslice(p: number, from: number, to: number, gain: number, peak: number?) -- 8 equivalent calls inferred from this helper
		local v3 = slice(p, from, to) -- inferred equivalent call
		v3.gain = gain
		v3.peak = peak
		return v3
	end

	local function bagOf(items)
		assert(#items > 0, "[VoxelSound] empty bag")
		local order = {}

		for i = 1, #items do
			order[i] = i
		end

		return {
			items = items,
			order = order,
			i = #items + 1
		}
	end

	local function draw(state)
		local count = #state.order

		if count < state.i then
			local v3 = state.order[count]

			for i = count, 2, -1 do
				local v4 = math.random(i)
				local order = state.order
				local order2 = state.order
				local v5 = state.order[v4]
				local v6 = state.order[i]
				order[i] = v5
				order2[v4] = v6
			end

			if count > 1 and state.order[1] == v3 then
				local order = state.order
				local order2 = state.order
				local v4 = state.order[2]
				local v5 = state.order[1]
				order[1] = v4
				order2[2] = v5
			end

			state.i = 1
		end

		local item = state.items[state.order[state.i]]
		state.i += 1
		return item
	end

	local function jitter() -- 42 equivalent calls inferred from this helper
		return 10 ^ ((math.random() * 2 - 1) * 2 / 20)
	end

	local function pitch(p: number, p2: number) -- 52 equivalent calls inferred from this helper
		return (math.min(p + (p2 - p) * math.random(), 1))
	end

	local function smoothstep(p: number, p2: number, p3: number) -- 11 equivalent calls inferred from this helper
		local v3 = math.clamp((p3 - p) / (p2 - p), 0, 1)
		return v3 * v3 * (3 - v3 * 2)
	end

	local function camPos() -- 51 equivalent calls inferred from this helper
		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			return currentCamera.CFrame.Position
		end

		return Vector3.new(0, 0, 0)
	end

	do
		local function airCutoff(p: number) -- 33 equivalent calls inferred from this helper
			return (math.clamp(math.sqrt(2000000000 / math.max(p, 1)), 700, 20000))
		end
	end

	local Quality = require(script.Parent:WaitForChild("Quality"))
	local pool = Quality.mobile and 64 or 112

	VoxelSound.lean = { level = 0, pool = pool, hdr = 36, tailGap = 0 }

	do
		local RunService = game:GetService("RunService")
		assert(RunService:IsRunning(), "[VoxelSound] runs only in a running game, not in Edit")
	end

	local voxelSoundVoices = Instance.new("Part")
	voxelSoundVoices.Name = "VoxelSoundVoices"
	voxelSoundVoices.Anchored = true
	voxelSoundVoices.CanCollide = false
	voxelSoundVoices.CanQuery = false
	voxelSoundVoices.CanTouch = false
	voxelSoundVoices.Transparency = 1
	voxelSoundVoices.Size = Vector3.new(0.2, 0.2, 0.2)
	voxelSoundVoices.CFrame = CFrame.new()
	voxelSoundVoices.Parent = workspace

	local function newPoolVoice(p) -- 3 equivalent calls inferred from this helper
		return {
			v = p,
			prio = 0,
			started = 0,
			life = 0,
			stopAt = 1e999,
			fade = 0,
			volume = 0,
			serial = 0,
			busyUntil = 0,
			listed = false
		}
	end

	local v3 = {}

	local v4 = {}

	for i = 1, pool do
		local poolVoice = newPoolVoice(AudioGraph.positional("Voice" .. i, voxelSoundVoices, true)) -- inferred equivalent call
		AudioGraph.park(poolVoice.v)
		table.insert(v3, poolVoice)
	end

	local function ring(p: string, p2: number, flag: boolean?)
		local voices = {}
		local v5

		if flag then
			v5 = AudioGraph.monoFold(p)
		end

		for i = 1, p2 do
			voices[i] = newPoolVoice(AudioGraph.flat(p .. i, true, v5)) -- inferred equivalent call
			AudioGraph.park(voices[i].v)
		end

		return { voices = voices, next = 1 }
	end

	local v5 = {
		started = 0,
		dropped = 0,
		culled = 0,
		cellMiss = 0,
		occlusionMiss = 0,
		playerSteals = 0,
		notReady = 0
	}
	local count = 0

	local v6 = {}
	local v7 = false

	do
		local function release(p) -- 3 equivalent calls inferred from this helper
			local sp = p.sp

			if sp then
				p.sp = nil

				if sp.player.IsPlaying then
					sp.player:Stop()
				end

				AudioGraph.connect(sp, nil)
			end
		end
	end

	local function takePlayer(id: string, state)
		local v8 = v6[id]

		if not v8 then
			error("[VoxelSound] no sampler for " .. id)
		end

		local now = os.clock()
		local v9 = 1e999
		local v10 = 1

		for k, player in v8.players do
			local owner = v8.owners[k]

			if owner == nil or owner.sp ~= player or owner.busyUntil <= now then
				v10 = k
				break
			elseif owner.started < v9 then
				v9 = owner.started
				v10 = k
			end
		end

		local player = v8.players[v10]
		local owner = v8.owners[v10]

		if owner and owner ~= state and owner.sp == player then
			if now < owner.busyUntil then
				v5.playerSteals += 1
			end

			owner.sp = nil
			owner.stopAt = 1e999
			owner.busyUntil = 0
		end

		v8.owners[v10] = state
		return player
	end

	local function startVoice(state, data, p: number, p2: number, p3: string, p4: number, p5: number, fade: number, prio: number, p6: number?)
		debug.profilebegin("VS.start")
		local volume = p * (data.gain or 1)
		local playbackSpeed = (math.min)(p2, 1)
		release(state) -- inferred equivalent call
		local sp = takePlayer(data.id, state)
		local player = sp.player

		if player.IsPlaying then
			player:Stop()
		end

		if not player.IsReady then
			v5.notReady += 1

			if not v7 then
				v7 = true
				warn("[VoxelSound] played before its asset was ready (late or silent): " .. data.id)
			end
		end

		state.sp = sp
		AudioGraph.connect(sp, state.v)
		player.PlaybackRegion = data.range
		player.PlaybackSpeed = playbackSpeed
		player.Volume = volume
		player.TimePosition = data.from

		AudioGraph.route(state.v, p3, os.clock() + math.min((data.to - data.from) / playbackSpeed, p5 + fade) + 0.02)

		if p6 then
			AudioGraph.highpass(state.v, p6)
		else
			AudioGraph.lowpass(state.v, p4)
		end

		player:Play()
		local now = os.clock()
		count += 1
		state.serial = count
		state.prio = prio
		state.started = now
		state.volume = volume
		state.fade = fade
		state.stopAt = not (p5 < 1e999) and 1e999 or now + p5
		state.life = math.min((data.to - data.from) / playbackSpeed, p5 + fade)
		state.busyUntil = now + state.life + 0.02

		if not state.listed then
			state.listed = true
			table.insert(v4, state)
		end

		v5.started += 1
		debug.profileend()
	end

	local function claim(p: number, p2: string)
		local now = os.clock()
		local v8 = nil
		local v9 = 1e999
		local v10 = nil

		for i = 1, VoxelSound.lean.pool do
			local v11 = v3[i]

			if v11.busyUntil <= now then
				if v11.v.bus == p2 then
					return v11
				end

				if not v8 or not AudioGraph.awake(v8.v) and AudioGraph.awake(v11.v) then
					v8 = v11
				end
			elseif not v8 then
				local v12 = v11.prio * math.clamp(1 - (now - v11.started) / math.max(v11.life, 0.05), 0.05, 1)

				if v11.stopAt <= now then
					v12 *= 0.2
				end

				if v12 < v9 then
					v10 = v11
					v9 = v12
				end
			end
		end

		if v8 then
			return v8
		end

		if v10 and 1.5 * v9 < p then
			release(v10) -- inferred equivalent call
			return v10
		end

		v5.dropped += 1
		return nil
	end

	local v8 = -120

	do
		local function hdrPass(p: number): boolean -- 1 equivalent call inferred from this helper
			local v9 = math.log10((math.max(p, 0.00001))) * 20

			if v8 < v9 then
				v8 = v9
			end

			if v9 < v8 - VoxelSound.lean.hdr then
				v5.culled += 1
				return false
			end

			return true
		end
	end

	local function emitAt(p, worldPosition: Vector3, p2: number, p3: number, p4: string, p5: number, p6: number, fade: number, prio: number, p7: number?)
		if p2 < 0.01 then
			return nil
		end

		if not hdrPass(p2) then -- inferred equivalent call
			return nil
		end

		local v9 = claim(prio, p4)

		if not v9 then
			return nil
		end

		v9.v.attachment.WorldPosition = worldPosition
		startVoice(v9, p, p2, p3, p4, p5, p6, fade, prio, p7)
		return v9
	end

	do
		local function ringFire(state, p, p2: number, p3: number, p4: string, p5: number, fade: number, value: number?, p6: number?) -- 97 equivalent calls inferred from this helper
			local voice = state.voices[state.next]
			state.next = state.next % #state.voices + 1
			startVoice(voice, p, p2, p3, p4, value or 20000, p5, fade, 10, p6)
			return voice
		end
	end

	do
		local function cutShort(voice, serial: number, value: number?) -- 14 equivalent calls inferred from this helper
			local now = os.clock()

			if voice and voice.serial == serial and now < voice.busyUntil and now < voice.stopAt then
				voice.stopAt = now
				voice.fade = value or 0.06
				voice.busyUntil = math.min(voice.busyUntil, now + voice.fade + 0.02)
			end
		end
	end

	local v9 = {}
	local v10 = {}
	local function later(p: number, fn, p2, p3, p4, p5, p6)
		if p <= 0.008 then
			fn(p2, p3, p4, p5, p6)
			return
		end

		local v11 = table.remove(v10)

		if v11 then
			v11.at = os.clock() + p
			v11.fn = fn
			v11.a = p2
			v11.b = p3
			v11.c = p4
			v11.d = p5
			v11.e = p6
		else
			v11 = {
				at = os.clock() + p,
				fn = fn,
				a = p2,
				b = p3,
				c = p4,
				d = p5,
				e = p6
			}
		end

		table.insert(v9, v11)
	end

	local v11 = {}

	do
		local Detail = require(script.Parent:WaitForChild("Detail"))
		local lean = VoxelSound.lean
		local v12 = { 48, 40, 32 }
		local v13 = { 33, 30, 27 }
		local v14 = { 0.2, 0.3, 0.4 }
		table.insert(v11, function()
			local level = not Detail.low and 0 or Detail.strain

			if level == lean.level then
				return
			end

			lean.level = level

			if level == 0 then
				lean.pool = pool
				lean.hdr = 36
				lean.tailGap = 0
			else
				lean.pool = math.min(pool, assert(v12[level], "[VoxelSound] no lean values for strain " .. level))
				local hdr = v13[level]
				local tailGap = v14[level]
				lean.hdr = hdr
				lean.tailGap = tailGap
			end
		end)
	end

	local v12 = { roof = false, walls = 0, reflectors = {} }

	function VoxelSound.setSurroundings(roof: boolean, walls: number, reflectors)
		v12.roof = roof
		v12.walls = walls
		v12.reflectors = reflectors
	end

	local v13 = 0
	function VoxelSound.setEnclosure(value: number)
		v13 = math.clamp(value, 0, 1)
		AudioGraph.setEnclosure(v13)
	end
	function VoxelSound.enclosure()
		return v13
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.IgnoreWater = true
	local v14 = -1e999
	local function refreshParams()
		local now = os.clock()

		if now - v14 < 2 then
			return
		end

		v14 = now
		local voxelWorlds = { workspace.Terrain }
		local voxelWorld = workspace:FindFirstChild("VoxelWorld")

		if voxelWorld then
			table.insert(voxelWorlds, voxelWorld)
		end

		raycastParams.FilterDescendantsInstances = voxelWorlds
	end

	do
		local function cellKey(vector3: Vector3) -- 2 equivalent calls inferred from this helper
			return ((math.floor(vector3.X / 16) + 30000) * 60000 + (math.floor(vector3.Z / 16) + 30000)) * 512 + (math.floor(vector3.Y / 16) + 256)
		end
	end

	local v15 = {}
	local v16 = 0
	local v17 = 2
	local v18 = 8
	local v19 = {
		Vector3.new(1, 0, 0),
		-Vector3.new(1, 0, 0),
		Vector3.new(0, 0, 1),
		-Vector3.new(0, 0, 1)
	}

	local function shooterCell(origin: Vector3)
		local v20 = cellKey(origin) -- inferred equivalent call
		local v21 = v15[v20]
		local now = os.clock()

		if v21 and now - v21.t < 8 then
			return v21
		end

		if v17 <= 0 then
			v5.cellMiss += 1
			return v21
		else
			v17 -= 1
			refreshParams()
			local roof = workspace:Raycast(origin, Vector3.new(0, 40, 0), raycastParams) ~= nil
			local count2 = 0

			for _, v22 in v19 do
				if workspace:Raycast(origin, v22 * 24, raycastParams) then
					count2 += 1
				end
			end

			if v21 then
				v21.t = now
				v21.roof = roof
				v21.walls = count2

				return v21
			else
				v16 += 1

				if v16 > 2048 then
					table.clear(v15)
					v16 = 1
				end

				local v22 = { t = now, roof = roof, walls = count2 }
				v15[v20] = v22
				return v22
			end
		end
	end

	local v20 = {}
	local v21 = 0

	local SightRay = require(script.Parent:WaitForChild("SightRay"))
	local function occluded(vector3: Vector3, vector3_2: Vector3, p: number)
		if p < 6 * meter then
			return false
		end

		local v22 = cellKey(vector3) -- inferred equivalent call
		local v23 = v20[v22]
		local now = os.clock()

		if v23 and now - v23.t < 0.3 then
			return v23.v
		end

		if v18 <= 0 then
			v5.occlusionMiss += 1
			return v23 ~= nil and v23.v
		else
			v18 -= 1
			local blocked = SightRay.blocked(
				workspace:FindFirstChild("VoxelWorld"),
				vector3_2,
				(vector3 - vector3_2).Unit * (p - 3)
			)

			if v23 then
				v23.t = now
				v23.v = blocked
			else
				v21 += 1

				if v21 > 2048 then
					table.clear(v20)
					v21 = 1
				end

				v20[v22] = { t = now, v = blocked }
			end

			return blocked
		end
	end

	do
		local function pathTo(vector3: Vector3, vector3_2: Vector3, p: number, p2: number, value: number?)
			local v22 = occluded(vector3, vector3_2, p)
			local v23 = value or 1
			local v24 = 1
			local v25 = airCutoff(p2 / v23) -- inferred equivalent call

			if v22 then
				v24 *= 0.55
				v25 = math.min(v25, math.sqrt(v23) * 900)
			end

			if v13 > 0 and p2 > 15 then
				v24 *= 1 - v13 * 0.45
				v25 = math.max(v25 * (1 - v13 * 0.6), 700)
			end

			return v24, v25, v22
		end

		local v22 = 0
		local function heardFight(p: number) -- 19 equivalent calls inferred from this helper
			v22 = math.min(v22 + p * 0.35, 1.5)
		end
		function VoxelSound.combat()
			return (math.clamp(v22, 0, 1))
		end

		local function bank(items, gain: number, interval: number, nominal: number, value: number?)
			local slices = {}

			for _, item in items do
				table.insert(slices, slice(item, 0, 4)) -- inferred equivalent call
			end

			return {
				slices = slices,
				gain = gain,
				interval = interval,
				nominal = nominal,
				pitch = value or 1,
				last = -1e999,
				lastIndex = 0,
				lastVolume = 0,
				length = 4,
				fade = 0
			}
		end

		do
			local function cutBank(slices, gain: number, interval: number, nominal: number, value: number?)
				return {
					slices = slices,
					gain = gain,
					interval = interval,
					nominal = nominal,
					pitch = value or 1,
					last = -1e999,
					lastIndex = 0,
					lastVolume = 0,
					length = 4,
					fade = 0
				}
			end
		end

		local function cut(p, length: number, fade: number) -- 14 equivalent calls inferred from this helper
			p.length = length
			p.fade = fade
			return p
		end

		local function sized(p, p2, p3) -- 12 equivalent calls inferred from this helper
			return { s = p, m = p2, l = p3 }
		end

		do
			local fn

			function VoxelSound.play(p, vector3: Vector3, p2: number, p3: number?, p4)
				local delay = p4 and p4.delay

				if delay and delay > 0.02 then
					later(delay, fn, p, vector3, p2, p3, {
						bus = p4 and p4.bus
					})
				else
					fn(p, vector3, p2, p3, p4)
				end
			end

			fn = function(state, vector3: Vector3, p: number, value: number?, p2)
				local v23 = camPos() -- inferred equivalent call
				local magnitude = (vector3 - v23).Magnitude
				local v24 = magnitude / meter
				local v25 = math.clamp(state.nominal * math.sqrt((math.max(p, 1))) / (v24 + 0.1), 0, 1)
				local lastVolume = v25 * v25 * p

				if lastVolume <= 0.01 then
					return
				end

				local now = os.clock()

				if now - state.last < state.interval and lastVolume <= state.lastVolume * 2 then
					return
				end

				local count2 = #state.slices
				local lastIndex = math.random(count2)

				if count2 > 1 and lastIndex == state.lastIndex then
					lastIndex = lastIndex % count2 + 1
				end

				state.last = now
				state.lastIndex = lastIndex
				state.lastVolume = lastVolume
				local v26 = occluded(vector3, v23, magnitude)

				local v27 = 1
				local v28 = airCutoff(v24 / 1) -- inferred equivalent call

				if v26 then
					v27 *= 0.55
					v28 = math.min(v28, 900)
				end

				if v13 > 0 and v24 > 15 then
					v27 *= 1 - v13 * 0.45
					v28 = math.max(v28 * (1 - v13 * 0.6), 700)
				end

				local v29 = math.min(p, 1) * state.gain * v25 * v27
				local v30 = (value or 1) * state.pitch * (0.9 + 0.1 * math.random())
				emitAt(
					state.slices[lastIndex],
					vector3,
					v29,
					v30,
					p2 and p2.bus or "dry",
					v28,
					state.length,
					state.fade,
					v29
				)
			end
		end

		local v23 = { 9113225735, 9113225734, 9113225979, 9113225986, 9113225985 }

		local v24 = { 9118608146, 9125869159 }
		local v25 = { 9118587716, 9118587698, 9118587701, 9118587973 }
		local v26 = { 9116616748, 9116617140, 9116616884, 9116618898 }
		local v27 = { 9114750915 }
		local v28 = { 9114592102, 9114592245 }
		local near = { 9117563161, 9117458008 }
		local v29 = {
			wood = sized( -- inferred equivalent call
				bank({ 9120888980, 9120888847 }, 0.8, 0.03, 10),
				bank(v23, 0.8, 0.03, 10),
				bank(v23, 0.9, 0.03, 10)
			),
			masonry = sized(bank(v24, 0.8, 0.03, 10), bank(v25, 0.8, 0.03, 10), bank(v25, 0.9, 0.03, 10)), -- inferred equivalent call
			metal = sized(bank(v26, 0.6, 0.03, 10), bank(v26, 0.6, 0.03, 10), bank(v26, 0.7, 0.03, 10)), -- inferred equivalent call
			glass = sized(bank(v27, 0.7, 0.03, 10), bank(v27, 0.7, 0.03, 10), bank(v27, 0.8, 0.03, 10)), -- inferred equivalent call
			plastic = sized(bank(near, 0.7, 0.03, 10), bank(near, 0.7, 0.03, 10), bank(near, 0.8, 0.03, 10)), -- inferred equivalent call
			soil = sized(bank(v24, 0.7, 0.03, 10, 0.7), bank(v25, 0.7, 0.03, 10, 0.7), bank(v25, 0.8, 0.03, 10, 0.6)) -- inferred equivalent call
		}

		local v30 = {
			wood = sized( -- inferred equivalent call
				bank({ 9120826936 }, 0.8, 0.05, 10),
				bank({ 9120965604, 9120965080 }, 0.9, 0.05, 10),
				bank({ 9120957493, 9120957469 }, 1, 0.08, 10)
			),
			masonry = sized( -- inferred equivalent call
				bank({ 9118587716, 9118587698 }, 0.8, 0.05, 10),
				bank({ 9118587701, 9118587973 }, 0.9, 0.05, 10),
				bank({ 9118614717, 9125869159 }, 1, 0.08, 10)
			),
			metal = sized(bank(v26, 0.6, 0.05, 10, 0.9), bank(v26, 0.7, 0.05, 10, 0.8), bank(v26, 0.8, 0.08, 10, 0.7)), -- inferred equivalent call
			glass = sized(bank(v28, 0.7, 0.05, 10, 1), bank(v28, 0.8, 0.05, 10), bank(v28, 0.9, 0.08, 10, 0.9)), -- inferred equivalent call
			plastic = sized(bank(near, 0.6, 0.05, 10), bank(near, 0.7, 0.05, 10), bank(near, 0.8, 0.08, 10)), -- inferred equivalent call
			soil = sized( -- inferred equivalent call
				bank({ 9118693444 }, 0.6, 0.05, 10, 0.8),
				bank({ 9118693444 }, 0.7, 0.05, 10, 0.7),
				bank({ 9118614717 }, 0.8, 0.08, 10, 0.7)
			)
		}

		for _, v31 in v29 do
			local v32 = cut(v31.s, 0.45, 0.25) -- inferred equivalent call
			v32 = v31.m
			cut(v32, 0.8, 0.4) -- inferred equivalent call
			v32 = v31.l
			cut(v32, 1.2, 0.6) -- inferred equivalent call
		end

		for _, v31 in v30 do
			local v32 = cut(v31.s, 0.9, 0.5) -- inferred equivalent call
			v32 = v31.m
			cut(v32, 1.5, 0.8) -- inferred equivalent call
			v32 = v31.l
			cut(v32, 2.4, 1.2) -- inferred equivalent call
		end

		v29.soil.s.length = 0.35

		v26 = { 9118598279, 9118598240, 9118597103, 9118597467 }
		local v31 = {
			masonry = 0,
			soil = 0,
			wood = 0,
			metal = 0,
			glass = 0,
			plastic = 0
		}
		v26 = "rbxassetid://" .. 9113632073
		v2[v26] = (v2[v26] or 0) + 1

		do
			local v32 = { id = v26, from = 0.027, to = 0.28, range = NumberRange.new(0.027, 0.28) }

			v32.gain = 0.9
			v32.peak = nil
			v26 = "rbxassetid://" .. 9113632067
			v2[v26] = (v2[v26] or 0) + 1
			local v38 = {
				id = v26,
				from = 0.172,
				to = 0.285,
				range = NumberRange.new(0.172, 0.285)
			}

			v38.gain = 0.9
			v38.peak = nil
			v26 = "rbxassetid://" .. 9113632114
			v2[v26] = (v2[v26] or 0) + 1
			local v39 = { id = v26, from = 0.042, to = 0.33, range = NumberRange.new(0.042, 0.33) }

			v39.gain = 0.9
			v39.peak = nil
			v26 = "rbxassetid://" .. 9113632248
			v2[v26] = (v2[v26] or 0) + 1
			local v40 = {
				id = v26,
				from = 0.032,
				to = 0.205,
				range = NumberRange.new(0.032, 0.205)
			}

			v40.gain = 0.9
			v40.peak = nil
			v26 = "rbxassetid://" .. 9113632381
			v2[v26] = (v2[v26] or 0) + 1
			local v41 = {
				id = v26,
				from = 0.062,
				to = 0.175,
				range = NumberRange.new(0.062, 0.175)
			}

			v41.gain = 0.9
			v41.peak = nil
			v26 = "rbxassetid://" .. 9113632382
			v2[v26] = (v2[v26] or 0) + 1
			local v42 = { id = v26, from = 0.037, to = 0.2, range = NumberRange.new(0.037, 0.2) }

			v42.gain = 0.9
			v42.peak = nil

			v31.masonry = {
				slices = { v32, v38, v39, v40, v41, v42 },
				gain = 1,
				interval = 0.03,
				nominal = 30,
				pitch = 1,
				last = -1e999,
				lastIndex = 0,
				lastVolume = 0,
				length = 4,
				fade = 0
			}
		end

		v26 = "rbxassetid://" .. 9118598279
		v2[v26] = (v2[v26] or 0) + 1

		do
			local v32 = { id = v26, from = 0, to = 0.4, range = NumberRange.new(0, 0.4) }
			v26 = "rbxassetid://" .. 9118598240
			v2[v26] = (v2[v26] or 0) + 1
			local v44 = { id = v26, from = 0, to = 0.4, range = NumberRange.new(0, 0.4) }
			v26 = "rbxassetid://" .. 9118597103
			v2[v26] = (v2[v26] or 0) + 1
			local v45 = { id = v26, from = 0, to = 0.6, range = NumberRange.new(0, 0.6) }
			v26 = "rbxassetid://" .. 9118597467
			v2[v26] = (v2[v26] or 0) + 1
			local v46 = { id = v26, from = 0, to = 0.6, range = NumberRange.new(0, 0.6) }
			v26 = "rbxassetid://" .. 9114087172
			v2[v26] = (v2[v26] or 0) + 1
			local v47 = { id = v26, from = 0.017, to = 0.2, range = NumberRange.new(0.017, 0.2) }

			v47.gain = 0.6
			v47.peak = nil

			v31.soil = {
				slices = { v32, v44, v45, v46, v47 },
				gain = 1,
				interval = 0.03,
				nominal = 30,
				pitch = 1,
				last = -1e999,
				lastIndex = 0,
				lastVolume = 0,
				length = 4,
				fade = 0
			}
		end

		v26 = "rbxassetid://" .. 9120962232
		v2[v26] = (v2[v26] or 0) + 1

		do
			local v32 = { id = v26, from = 0.012, to = 0.14, range = NumberRange.new(0.012, 0.14) }

			v32.gain = 0.6
			v32.peak = nil
			v26 = "rbxassetid://" .. 9120962354
			v2[v26] = (v2[v26] or 0) + 1
			local v49 = { id = v26, from = 0.037, to = 0.15, range = NumberRange.new(0.037, 0.15) }

			v49.gain = 0.55
			v49.peak = nil
			v26 = "rbxassetid://" .. 9120962354
			v2[v26] = (v2[v26] or 0) + 1
			local v50 = { id = v26, from = 0.472, to = 0.6, range = NumberRange.new(0.472, 0.6) }

			v50.gain = 0.55
			v50.peak = nil
			v26 = "rbxassetid://" .. 9120962532
			v2[v26] = (v2[v26] or 0) + 1
			local v51 = {
				id = v26,
				from = 0.017,
				to = 0.145,
				range = NumberRange.new(0.017, 0.145)
			}

			v51.gain = 0.55
			v51.peak = nil
			v26 = "rbxassetid://" .. 9120962532
			v2[v26] = (v2[v26] or 0) + 1
			local v52 = { id = v26, from = 0.292, to = 0.41, range = NumberRange.new(0.292, 0.41) }

			v52.gain = 0.6
			v52.peak = nil
			v26 = "rbxassetid://" .. 9120962638
			v2[v26] = (v2[v26] or 0) + 1
			local v53 = { id = v26, from = 0.042, to = 0.17, range = NumberRange.new(0.042, 0.17) }

			v53.gain = 0.6
			v53.peak = nil

			v31.wood = {
				slices = { v32, v49, v50, v51, v52, v53 },
				gain = 0.9,
				interval = 0.03,
				nominal = 30,
				pitch = 0.85,
				last = -1e999,
				lastIndex = 0,
				lastVolume = 0,
				length = 4,
				fade = 0
			}
		end

		v26 = "rbxassetid://" .. 9113632396
		v2[v26] = (v2[v26] or 0) + 1

		do
			local v32 = { id = v26, from = 0.162, to = 0.4, range = NumberRange.new(0.162, 0.4) }

			v32.gain = 0.5
			v32.peak = nil
			v26 = "rbxassetid://" .. 9113633916
			v2[v26] = (v2[v26] or 0) + 1
			local v55 = { id = v26, from = 0.137, to = 0.4, range = NumberRange.new(0.137, 0.4) }

			v55.gain = 0.45
			v55.peak = nil
			v26 = "rbxassetid://" .. 9113634061
			v2[v26] = (v2[v26] or 0) + 1
			local v56 = { id = v26, from = 0.137, to = 0.4, range = NumberRange.new(0.137, 0.4) }

			v56.gain = 0.45
			v56.peak = nil
			v26 = "rbxassetid://" .. 9113634070
			v2[v26] = (v2[v26] or 0) + 1
			local v57 = { id = v26, from = 0.142, to = 0.4, range = NumberRange.new(0.142, 0.4) }

			v57.gain = 0.45
			v57.peak = nil

			v31.metal = {
				slices = { v32, v55, v56, v57 },
				gain = 0.8,
				interval = 0.03,
				nominal = 30,
				pitch = 0.85,
				last = -1e999,
				lastIndex = 0,
				lastVolume = 0,
				length = 4,
				fade = 0
			}
		end

		v26 = bank(v27, 0.9, 0.03, 30)
		v31.glass = cut(v26, 0.3, 0.1) -- inferred equivalent call
		v26 = bank(near, 0.8, 0.03, 30, 0.85)
		v31.plastic = cut(v26, 0.15, 0.05) -- inferred equivalent call

		do
			local v32 = {
				masonry = 0.3,
				soil = 0.35,
				wood = 0.2,
				metal = 0.25,
				glass = 0.3,
				plastic = 0.15
			}

			for k, v59 in v31 do
				cut(v59, v32[k], 0.2) -- inferred equivalent call
			end
		end

		v26 = "rbxassetid://" .. 9113570506
		v2[v26] = (v2[v26] or 0) + 1
		local v32 = { id = v26, from = 0.037, to = 0.18, range = NumberRange.new(0.037, 0.18) }

		v32.gain = 0.7
		v32.peak = nil
		v26 = "rbxassetid://" .. 9116486472
		v2[v26] = (v2[v26] or 0) + 1
		local v60 = { id = v26, from = 0.012, to = 0.125, range = NumberRange.new(0.012, 0.125) }

		v60.gain = 1.4
		v60.peak = nil

		local v61 = bagOf({ v32, v60 })
		v26 = "rbxassetid://" .. 9113487449
		v2[v26] = (v2[v26] or 0) + 1
		local v62 = { id = v26, from = 0.042, to = 0.12, range = NumberRange.new(0.042, 0.12) }

		v62.gain = 1
		v62.peak = nil
		v26 = "rbxassetid://" .. 9113487470
		v2[v26] = (v2[v26] or 0) + 1
		local v63 = { id = v26, from = 0.032, to = 0.15, range = NumberRange.new(0.032, 0.15) }

		v63.gain = 2.2
		v63.peak = nil
		v26 = "rbxassetid://" .. 9113487341
		v2[v26] = (v2[v26] or 0) + 1
		local v64 = { id = v26, from = 0.042, to = 0.15, range = NumberRange.new(0.042, 0.15) }

		v64.gain = 3.1
		v64.peak = nil
		v26 = "rbxassetid://" .. 9113487543
		v2[v26] = (v2[v26] or 0) + 1
		local v65 = { id = v26, from = 0.052, to = 0.13, range = NumberRange.new(0.052, 0.13) }

		v65.gain = 2.8
		v65.peak = nil

		local v66 = bagOf({ v62, v63, v64, v65 })

		local v67 = cut(bank({ 9120972444, 9120972457, 9120972323, 9120972321, 9120972724 }, 0.5, 0.1, 5), 1, 0.3) -- inferred equivalent call

		local v68 = cut(bank(near, 0.6, 0.05, 5, 0.7), 0.3, 0.1) -- inferred equivalent call

		local v69 = cut(bank({ 9118693443, 9113805612, 9118589474 }, 0.7, 0.15, 12), 1.5, 0.8) -- inferred equivalent call
		v26 = bank({ 9118693444 }, 0.8, 0.05, 10)
		cut(v26, 2.8, 1.2) -- inferred equivalent call
		v27 = bank({ 9118614717 }, 1, 0.05, 10)
		cut(v27, 3.4, 1.5) -- inferred equivalent call
		local v70 = { false, v26, v27 }

		do
			local function sizeClass(p: number)
				if p < 100 then
					return "s", p / 100
				end

				if p < 400 then
					return "m", (p - 100) / 300
				end

				return "l", (math.min((p - 400) / 1600, 1))
			end
		end

		do
			local function materialPlay(p, p2: number, p3: number, vector3: Vector3, p4: number)
				local v71 = Materials.Palette[p2]

				if not v71 then
					return nil, nil
				end

				local v72, v73

				if p3 < 100 then
					v72 = p3 / 100
					v73 = "s"
				elseif p3 < 400 then
					v72 = (p3 - 100) / 300
					v73 = "m"
				else
					v72 = math.min((p3 - 400) / 1600, 1)
					v73 = "l"
				end

				local v74 = 1 + -0.19999999999999996 * v72
				VoxelSound.play(p[v71.type.sound][v73], vector3, p4, v74)
				return v71.type.sound, v73
			end
		end

		function VoxelSound.hit(p: number, p2: number, vector3: Vector3, p3: number)
			local v71 = Materials.Palette[p]

			if not v71 then
				return
			end

			local v72, v73

			if p2 < 100 then
				v72 = p2 / 100
				v73 = "s"
			elseif p2 < 400 then
				v72 = (p2 - 100) / 300
				v73 = "m"
			else
				v72 = math.min((p2 - 400) / 1600, 1)
				v73 = "l"
			end

			local v74 = 1 + -0.19999999999999996 * v72
			VoxelSound.play(v29[v71.type.sound][v73], vector3, p3, v74)
			local _sound = v71.type.sound
		end

		function VoxelSound.bulletHit(p: number, vector3: Vector3, p2: number)
			local v71 = Materials.Palette[p]

			if not v71 then
				return
			end

			local v72 = v31[v71.type.sound]

			if not ((vector3 - camPos()).Magnitude / meter > 15) then -- inferred equivalent call
				VoxelSound.play(v72, vector3, p2)

				return
			end

			local length = v72.length
			v72.length = math.min(length, 0.18)
			VoxelSound.play(v72, vector3, p2, 0.92)
			v72.length = length
		end

		function VoxelSound.bodyHit(vector3: Vector3, p: number)
			local v71 = camPos() -- inferred equivalent call
			local magnitude = (vector3 - v71).Magnitude
			local v72 = math.max(magnitude / meter, 1)
			local v73 = occluded(vector3, v71, magnitude)

			local v74 = 1
			local v75 = airCutoff(v72 / 1) -- inferred equivalent call

			if v73 then
				v74 *= 0.55
				v75 = math.min(v75, 900)
			end

			if v13 > 0 and v72 > 15 then
				v74 *= 1 - v13 * 0.45
				v75 = math.max(v75 * (1 - v13 * 0.6), 700)
			end

			local v76 = p * 0.7 * math.min(1, 12 / v72) * v74 * jitter() -- inferred equivalent call
			later(v72 / 343, function()
				emitAt(
					draw(v61),
					vector3,
					v76,
					math.min(0.85 + 0.09999999999999998 * math.random(), 1),
					"dry",
					v75,
					0.15,
					0.05,
					v76 + 0.3
				)
				emitAt(
					draw(v66),
					vector3,
					v76 * 0.8,
					math.min(0.8 + 0.09999999999999998 * math.random(), 1),
					"dry",
					v75,
					0.12,
					0.04,
					v76 + 0.3
				)
			end)
		end

		local v71 = nil
		function VoxelSound.hurt(value: number)
			local v72 = math.clamp(value, 0.2, 1)
			ringFire( -- inferred equivalent call
				v71,
				draw(v66),
				v72 * 0.9,
				math.min(0.7 + 0.10000000000000009 * math.random(), 1),
				"dry",
				0.15,
				0.05
			)
			ringFire( -- inferred equivalent call
				v71,
				draw(v61),
				v72 * 0.35,
				math.min(0.8 + 0.09999999999999998 * math.random(), 1),
				"dry",
				0.12,
				0.04,
				2500
			)
		end

		do
			local v72 = { wood = 0, metal = 0, masonry = 0 }
			v26 = "rbxassetid://" .. 9126282474
			v2[v26] = (v2[v26] or 0) + 1

			do
				local v73 = { id = v26, from = 0.39, to = 2.5, range = NumberRange.new(0.39, 2.5) }

				v73.gain = 0.25
				v73.peak = nil
				v26 = "rbxassetid://" .. 9126282061
				v2[v26] = (v2[v26] or 0) + 1
				local v74 = {
					id = v26,
					from = 0.44,
					to = 2.55,
					range = NumberRange.new(0.44, 2.55)
				}

				v74.gain = 0.25
				v74.peak = nil

				v72.wood = bagOf({ v73, v74 })
			end

			v26 = "rbxassetid://" .. 9116552386
			v2[v26] = (v2[v26] or 0) + 1

			do
				local v75 = { id = v26, from = 2.6, to = 5.1, range = NumberRange.new(2.6, 5.1) }

				v75.gain = 0.25
				v75.peak = nil
				v26 = "rbxassetid://" .. 9125667610
				v2[v26] = (v2[v26] or 0) + 1
				local v76 = {
					id = v26,
					from = 1.35,
					to = 3.65,
					range = NumberRange.new(1.35, 3.65)
				}

				v76.gain = 0.2
				v76.peak = nil
				v26 = "rbxassetid://" .. 9125667610
				v2[v26] = (v2[v26] or 0) + 1
				local v77 = { id = v26, from = 6.2, to = 8.7, range = NumberRange.new(6.2, 8.7) }

				v77.gain = 0.2
				v77.peak = nil

				v72.metal = bagOf({ v75, v76, v77 })
			end

			v26 = "rbxassetid://" .. 9114034724
			v2[v26] = (v2[v26] or 0) + 1

			do
				local v78 = {
					id = v26,
					from = 3.97,
					to = 4.89,
					range = NumberRange.new(3.97, 4.89)
				}

				v78.gain = 0.35
				v78.peak = nil
				v26 = "rbxassetid://" .. 9114034724
				v2[v26] = (v2[v26] or 0) + 1
				local v79 = {
					id = v26,
					from = 9.96,
					to = 10.41,
					range = NumberRange.new(9.96, 10.41)
				}

				v79.gain = 0.35
				v79.peak = nil
				v26 = "rbxassetid://" .. 9114658416
				v2[v26] = (v2[v26] or 0) + 1
				local v80 = { id = v26, from = 1, to = 1.6, range = NumberRange.new(1, 1.6) }

				v80.gain = 0.35
				v80.peak = nil

				v72.masonry = bagOf({ v78, v79, v80 })
			end

			v72.soil = v72.masonry
			local v81 = 0
			local function settle(p: string, vector3: Vector3, p2: number)
				local v82 = v72[p]

				if not v82 then
					return
				end

				local v83 = camPos() -- inferred equivalent call
				local magnitude = (vector3 - v83).Magnitude
				local v84 = math.max(magnitude / meter, 1)

				if v84 > 60 then
					return
				end

				local v85 = occluded(vector3, v83, magnitude)

				local v86 = 1
				local v87 = airCutoff(v84 / 1) -- inferred equivalent call

				if v85 then
					v86 *= 0.55
					v87 = math.min(v87, 900)
				end

				if v13 > 0 and v84 > 15 then
					v86 *= 1 - v13 * 0.45
					v87 = math.max(v87 * (1 - v13 * 0.6), 700)
				end

				local v88 = p2 * 0.35 * math.min(1, 8 / v84) * v86
				emitAt(
					draw(v82),
					vector3,
					v88,
					math.min(0.8 + 0.1499999999999999 * math.random(), 1),
					"dry",
					v87,
					2.4,
					0.8,
					v88 * 0.5
				)
			end

			function VoxelSound.breakApart(p: number, p2: number, vector3: Vector3, p3: number)
				local v82 = Materials.Palette[p]
				local v83, sound

				if v82 then
					local v84

					if p2 < 100 then
						v84 = p2 / 100
						v83 = "s"
					elseif p2 < 400 then
						v84 = (p2 - 100) / 300
						v83 = "m"
					else
						v84 = math.min((p2 - 400) / 1600, 1)
						v83 = "l"
					end

					local v85 = 1 + -0.19999999999999996 * v84
					VoxelSound.play(v30[v82.type.sound][v83], vector3, p3, v85)
					sound = v82.type.sound
				end

				if sound and v83 == "l" then
					local now = os.clock()

					if v81 <= now then
						v81 = now + 1.5

						for i = 1, p2 > 1200 and 3 or 2 do
							later(0.8 + i * (1.2 + 1.6 * math.random()), settle, sound, vector3, 1 / i)
						end
					end
				end
			end
		end

		function VoxelSound.swing(vector3: Vector3)
			VoxelSound.play(v67, vector3, 1)
		end

		do
			local v82 = {
				thud = 0,
				crunch = 0,
				dirt = 0,
				clunk = 0,
				body = 0
			}
			v26 = "rbxassetid://" .. 9113437465
			v2[v26] = (v2[v26] or 0) + 1

			do
				local v83 = {
					id = v26,
					from = 0.081,
					to = 0.3,
					range = NumberRange.new(0.081, 0.3)
				}

				v83.gain = 2.8
				v83.peak = nil
				v26 = "rbxassetid://" .. 9113437538
				v2[v26] = (v2[v26] or 0) + 1
				local v84 = {
					id = v26,
					from = 0.089,
					to = 0.32,
					range = NumberRange.new(0.089, 0.32)
				}

				v84.gain = 2.5
				v84.peak = nil
				v26 = "rbxassetid://" .. 9113437973
				v2[v26] = (v2[v26] or 0) + 1
				local v85 = {
					id = v26,
					from = 0.116,
					to = 0.23,
					range = NumberRange.new(0.116, 0.23)
				}

				v85.gain = 2.9
				v85.peak = nil
				v26 = "rbxassetid://" .. 9113438062
				v2[v26] = (v2[v26] or 0) + 1
				local v86 = {
					id = v26,
					from = 0.234,
					to = 0.48,
					range = NumberRange.new(0.234, 0.48)
				}

				v86.gain = 3.5
				v86.peak = nil
				v26 = "rbxassetid://" .. 9113437833
				v2[v26] = (v2[v26] or 0) + 1
				local v87 = {
					id = v26,
					from = 1.089,
					to = 1.32,
					range = NumberRange.new(1.089, 1.32)
				}

				v87.gain = 2.5
				v87.peak = nil

				v82.thud = {
					slices = { v83, v84, v85, v86, v87 },
					gain = 0.9,
					interval = 0.04,
					nominal = 18,
					pitch = 1,
					last = -1e999,
					lastIndex = 0,
					lastVolume = 0,
					length = 0.3,
					fade = 0.12
				}
			end

			v26 = "rbxassetid://" .. 9118613196
			v2[v26] = (v2[v26] or 0) + 1

			do
				local v88 = {
					id = v26,
					from = 0.119,
					to = 0.45,
					range = NumberRange.new(0.119, 0.45)
				}

				v88.gain = 0.85
				v88.peak = nil
				v26 = "rbxassetid://" .. 9118614058
				v2[v26] = (v2[v26] or 0) + 1
				local v89 = {
					id = v26,
					from = 0.096,
					to = 0.47,
					range = NumberRange.new(0.096, 0.47)
				}

				v89.gain = 0.9
				v89.peak = nil
				v26 = "rbxassetid://" .. 9118613444
				v2[v26] = (v2[v26] or 0) + 1
				local v90 = {
					id = v26,
					from = 0.099,
					to = 0.25,
					range = NumberRange.new(0.099, 0.25)
				}

				v90.gain = 0.95
				v90.peak = nil
				v26 = "rbxassetid://" .. 9118613864
				v2[v26] = (v2[v26] or 0) + 1
				local v91 = {
					id = v26,
					from = 0.132,
					to = 0.36,
					range = NumberRange.new(0.132, 0.36)
				}

				v91.gain = 0.95
				v91.peak = nil
				v26 = "rbxassetid://" .. 9118613457
				v2[v26] = (v2[v26] or 0) + 1
				local v92 = {
					id = v26,
					from = 0.104,
					to = 0.31,
					range = NumberRange.new(0.104, 0.31)
				}

				v92.gain = 0.95
				v92.peak = nil
				v26 = "rbxassetid://" .. 9118613208
				v2[v26] = (v2[v26] or 0) + 1
				local v93 = {
					id = v26,
					from = 0.099,
					to = 0.29,
					range = NumberRange.new(0.099, 0.29)
				}

				v93.gain = 0.95
				v93.peak = nil

				v82.crunch = {
					slices = { v88, v89, v90, v91, v92, v93 },
					gain = 1,
					interval = 0.04,
					nominal = 18,
					pitch = 1,
					last = -1e999,
					lastIndex = 0,
					lastVolume = 0,
					length = 0.45,
					fade = 0.2
				}
			end

			v26 = "rbxassetid://" .. 9113805428
			v2[v26] = (v2[v26] or 0) + 1

			do
				local v94 = {
					id = v26,
					from = 0.322,
					to = 0.6,
					range = NumberRange.new(0.322, 0.6)
				}

				v94.gain = 1.5
				v94.peak = nil
				v26 = "rbxassetid://" .. 9113805426
				v2[v26] = (v2[v26] or 0) + 1
				local v95 = {
					id = v26,
					from = 0.327,
					to = 0.56,
					range = NumberRange.new(0.327, 0.56)
				}

				v95.gain = 1.45
				v95.peak = nil
				v26 = "rbxassetid://" .. 9113806542
				v2[v26] = (v2[v26] or 0) + 1
				local v96 = {
					id = v26,
					from = 0.169,
					to = 0.45,
					range = NumberRange.new(0.169, 0.45)
				}

				v96.gain = 1.6
				v96.peak = nil

				v82.dirt = {
					slices = { v94, v95, v96 },
					gain = 1,
					interval = 0.04,
					nominal = 18,
					pitch = 1,
					last = -1e999,
					lastIndex = 0,
					lastVolume = 0,
					length = 0.35,
					fade = 0.15
				}
			end

			v26 = "rbxassetid://" .. 9116673678
			v2[v26] = (v2[v26] or 0) + 1

			do
				local v97 = {
					id = v26,
					from = 0.027,
					to = 0.5,
					range = NumberRange.new(0.027, 0.5)
				}

				v97.gain = 0.85
				v97.peak = nil
				v26 = "rbxassetid://" .. 9116673944
				v2[v26] = (v2[v26] or 0) + 1
				local v98 = {
					id = v26,
					from = 0.027,
					to = 0.17,
					range = NumberRange.new(0.027, 0.17)
				}

				v98.gain = 1
				v98.peak = nil
				v26 = "rbxassetid://" .. 9116673771
				v2[v26] = (v2[v26] or 0) + 1
				local v99 = {
					id = v26,
					from = 0.291,
					to = 0.55,
					range = NumberRange.new(0.291, 0.55)
				}

				v99.gain = 0.9
				v99.peak = nil

				v82.clunk = {
					slices = { v97, v98, v99 },
					gain = 0.8,
					interval = 0.04,
					nominal = 18,
					pitch = 0.9,
					last = -1e999,
					lastIndex = 0,
					lastVolume = 0,
					length = 0.4,
					fade = 0.2
				}
			end

			v26 = "rbxassetid://" .. 9117969584
			v2[v26] = (v2[v26] or 0) + 1

			do
				local v100 = { id = v26, from = 0, to = 0.32, range = NumberRange.new(0, 0.32) }

				v100.gain = 0.95
				v100.peak = nil
				v26 = "rbxassetid://" .. 9117969687
				v2[v26] = (v2[v26] or 0) + 1
				local v101 = { id = v26, from = 0, to = 0.32, range = NumberRange.new(0, 0.32) }

				v101.gain = 0.85
				v101.peak = nil
				v26 = "rbxassetid://" .. 9117969990
				v2[v26] = (v2[v26] or 0) + 1
				local v102 = { id = v26, from = 0, to = 0.32, range = NumberRange.new(0, 0.32) }

				v102.gain = 0.75
				v102.peak = nil
				v26 = "rbxassetid://" .. 9113798371
				v2[v26] = (v2[v26] or 0) + 1
				local v103 = { id = v26, from = 0, to = 0.32, range = NumberRange.new(0, 0.32) }

				v103.gain = 1.05
				v103.peak = nil

				v82.body = {
					slices = { v100, v101, v102, v103 },
					gain = 1,
					interval = 0.04,
					nominal = 18,
					pitch = 1,
					last = -1e999,
					lastIndex = 0,
					lastVolume = 0,
					length = 0.32,
					fade = 0.12
				}
			end

			do
				local v104 = -1e999
				function VoxelSound.hammerBody(vector3: Vector3, flag: boolean?, flag2: boolean?)
					local now = os.clock()

					if flag2 and now - v104 < 0.6 then
						return
					end

					if flag then
						v104 = now
					end

					VoxelSound.play(v82.thud, vector3, 0.9, (math.min(0.8 + 0.09999999999999998 * math.random(), 1)))
					VoxelSound.play(v82.body, vector3, 1, (math.min(0.86 + 0.09999999999999998 * math.random(), 1)))
					heardFight(0.3) -- inferred equivalent call
				end
			end

			function VoxelSound.hammerStrike(p: number, vector3: Vector3, flag: boolean, flag2: boolean)
				local v105 = Materials.Palette[p]

				if not v105 then
					return
				end

				local v106 = flag2 and "soil" or v105.type.sound
				local v107 = (flag or flag2) and 1 or 0.7
				VoxelSound.play(v82.thud, vector3, v107, (math.min(0.85 + 0.15000000000000002 * math.random(), 1)))

				if v106 == "masonry" then
					VoxelSound.play(v82.crunch, vector3, v107, (math.min(0.88 + 0.12 * math.random(), 1)))
				elseif v106 == "soil" then
					VoxelSound.play(v82.dirt, vector3, v107, (math.min(0.9 + 0.09999999999999998 * math.random(), 1)))
					VoxelSound.play(v31.soil, vector3, v107 * 0.6)
				elseif v106 == "metal" then
					VoxelSound.play(v82.clunk, vector3, v107, (math.min(0.85 + 0.09999999999999998 * math.random(), 1)))
				else
					local v108 = v29[v106]

					if v108 then
						VoxelSound.play(v108.l, vector3, v107)
					end

					local v109 = v30[v106]

					if flag and v109 then
						VoxelSound.play(v109.m, vector3, 0.8)
					end
				end

				heardFight(v107 * 0.3) -- inferred equivalent call
			end
		end

		function VoxelSound.hammerBreak(p: number, vector3: Vector3)
			local v105 = Materials.Palette[p]

			if not v105 then
				return
			end

			local v106 = v30[v105.type.sound]

			if v106 and v105.type.sound ~= "masonry" and v105.type.sound ~= "metal" then
				VoxelSound.play(v106.m, vector3, 0.8)
			end
		end

		function VoxelSound.jab(vector3: Vector3, value: number?)
			VoxelSound.play(v67, vector3, value or 0.35, 1)
		end

		function VoxelSound.punchHit(vector3: Vector3, flag: boolean, flag2: boolean)
			local v105 = airCutoff(math.max((vector3 - camPos()).Magnitude / meter, 0.5)) -- inferred equivalent call
			local v106 = (flag2 and 1.1 or 0.85) * jitter() -- inferred equivalent call

			if flag then
				emitAt(
					draw(v61),
					vector3,
					v106,
					math.min(0.86 + 0.09999999999999998 * math.random(), 1),
					"dry",
					v105,
					0.15,
					0.05,
					v106 + 0.5
				)
				emitAt(
					draw(v66),
					vector3,
					(flag2 and 1 or 0.75) * v106,
					math.min(0.72 + 0.09999999999999998 * math.random(), 1),
					"dry",
					v105,
					0.15,
					0.06,
					v106 + 0.5
				)
			else
				emitAt(
					draw(v66),
					vector3,
					v106 * 0.9,
					math.min(0.66 + 0.09999999999999998 * math.random(), 1),
					"dry",
					v105,
					0.14,
					0.05,
					v106 + 0.5
				)
				VoxelSound.click(vector3, 0.7, 0.8)
			end

			heardFight(v106 * 0.1) -- inferred equivalent call
		end

		v26 = { 9112780193, 9112780438, 9112780212 }
		local v105 = { 1, 0.92, 0.85 }

		local v106 = {}

		for k, v107 in v26 do
			assert(v105[k] <= 1, "[VoxelSound] fire loops are never pitched up")
			local positional = AudioGraph.positional("Fire" .. k, voxelSoundVoices)
			positional.player.Asset = "rbxassetid://" .. v107
			positional.player.Looping = true
			positional.player.PlaybackSpeed = v105[k]
			AudioGraph.park(positional)
			v106[k] = { v = positional, pos = nil, volume = 0, sent = -1 }
		end

		VoxelSound.FIRE_SLOTS = #v26

		function VoxelSound.fire(p: number, vector3: Vector3?, value: number)
			local v107 = v106[p]
			assert(v107, "[VoxelSound] no fire slot " .. tostring(p))
			local player = v107.v.player

			if vector3 == nil or value <= 0 then
				v107.pos = nil

				if player.IsPlaying then
					player:Stop()
				end

				AudioGraph.park(v107.v)
			else
				local volume = math.clamp(value, 0, 1)
				v107.pos = vector3
				v107.volume = volume
				v107.v.attachment.WorldPosition = vector3
			end
		end

		do
			local v107 = {}
			function VoxelSound.fireSources(p: string, p2)
				v107[p] = p2
				local v108 = camPos() -- inferred equivalent call
				local v109 = {}

				for _, v110 in v107 do
					for _, v111 in v110 do
						table.insert(v109, v111)
					end
				end

				table.sort(v109, function(a, b): boolean
					return (a.pos - v108).Magnitude < (b.pos - v108).Magnitude
				end)

				for i = 1, #v106 do
					local v110 = v109[i]

					if v110 then
						VoxelSound.fire(i, v110.pos, v110.volume)
					else
						VoxelSound.fire(i, nil, 0)
					end
				end
			end
		end

		local function fireStep()
			local v108 = camPos() -- inferred equivalent call

			for _, v109 in v106 do
				local pos = v109.pos

				if not pos then
					continue
				end

				local magnitude = (pos - v108).Magnitude
				local v110 = math.max(magnitude / meter, 0.5)
				local v111 = occluded(pos, v108, magnitude)

				local v112 = 1
				local v113 = airCutoff(v110 / 1) -- inferred equivalent call

				if v111 then
					v112 *= 0.55
					v113 = math.min(v113, 900)
				end

				if v13 > 0 and v110 > 15 then
					v112 *= 1 - v13 * 0.45
					v113 = math.max(v113 * (1 - v13 * 0.6), 700)
				end

				local v114 = v109.volume * 0.7 * math.min(1, 5 / v110) * v112
				local player = v109.v.player

				if v114 < 0.003 then
					if AudioGraph.awake(v109.v) then
						if player.IsPlaying then
							player:Stop()
						end

						AudioGraph.park(v109.v)
					end
				else
					AudioGraph.route(v109.v, "dry")

					if not player.IsPlaying then
						player.TimePosition = math.random() * 20
						player:Play()
					end

					local v115 = math.abs(v114 - v109.sent)

					if v114 * 0.01 < v115 then
						v109.sent = v114
						player.Volume = v114
					end

					AudioGraph.lowpass(v109.v, v113)
				end
			end
		end

		local v108 = 0
		local v109 = 0
		function VoxelSound.concussion(value: number)
			if v108 < value then
				v108 = math.clamp(value, 0, 1)
				v109 = v108 * 0.5
			end
		end

		VoxelSound.lifeMuffle = { high = 0, mid = 0, low = 0, live = false }
		local function concussionStep(p: number)
			local lifeMuffle = VoxelSound.lifeMuffle

			if v108 <= 0 and not lifeMuffle.live then
				return
			end

			if v108 > 0 then
				if v109 > 0 then
					v109 -= p
				else
					v108 *= math.exp(p * -0.8)

					if v108 < 0.01 then
						v108 = 0
					end
				end
			end

			AudioGraph.setMuffle(
				math.min(v108 * -40, lifeMuffle.high),
				math.min(v108 * -14, lifeMuffle.mid),
				lifeMuffle.low
			)
		end

		do
			local function gunLevel(p: number) -- 3 equivalent calls inferred from this helper
				local v110 = 10 ^ (math.max(p - 100, 0) * -1.5 / 100 / 20)
				return math.min(1, 20 / p) ^ 0.75 * v110
			end
		end

		do
			local function tailLevel(p: number) -- 1 equivalent call inferred from this helper
				return math.min(1, 45 / p) ^ 0.75
			end
		end

		local v110 = {
			0,
			0.09,
			0.173,
			0.25,
			0.331,
			0.412,
			0.489,
			0.567,
			0.646,
			0.723,
			0.8,
			0.881,
			0.958,
			1.035,
			1.109,
			1.184,
			1.263,
			1.335,
			1.412,
			1.485,
			1.555,
			1.634,
			1.709,
			1.783
		}
		local items3 = {}
		local v112 = { near = 0.3, far = 0.3 }
		local v113 = { 25, 60 }
		local v114 = { 110, 180 }
		local v115 = { 260, 380 }

		for i = 1, #v110 - 1 do
			table.insert(items3, slice(9113190384, math.max(v110[i] - 0.003, 0), v110[i + 1] - 0.004)) -- inferred equivalent call
		end

		for _, v116 in { 9113184840, 9113184771, 9113184835, 9113184937, 9113179557 } do
			table.insert(items3, slice(v116, 0, 0.06)) -- inferred equivalent call
		end

		local items4 = {}

		for k, v117 in {
			[9116362114] = { 0.01, 0.07, 0.158, 0.246 },
			[9116362246] = { 0.01, 0.09, 0.176, 0.35, 0.434, 0.514, 0.678, 0.758 },
			[9116362247] = {
				0.01,
				0.082,
				0.158,
				0.242,
				0.324,
				0.404,
				0.564,
				0.642,
				0.72,
				0.798,
				0.874,
				0.95,
				1.026,
				1.102,
				1.178
			}
		} do
			for k2, v118 in v117 do
				local v119 = v118 + 0.075

				if v117[k2 + 1] then
					v119 = math.min(v119, v117[k2 + 1] - 0.004)
				end

				table.insert(items4, slice(k, v118 - 0.004, v119)) -- inferred equivalent call
			end
		end

		v26 = "rbxassetid://" .. 9114725314
		v2[v26] = (v2[v26] or 0) + 1
		local v117 = { id = v26, from = 1.3, to = 2.4, range = NumberRange.new(1.3, 2.4) }

		v117.gain = 0.83
		v117.peak = nil
		v26 = "rbxassetid://" .. 9114725318
		v2[v26] = (v2[v26] or 0) + 1
		local v118 = { id = v26, from = 0.9, to = 1.6, range = NumberRange.new(0.9, 1.6) }

		v118.gain = 0.78
		v118.peak = nil

		local items5 = {}

		for i = 1, 10 do
			local id = items3[i]
			local from = id.from
			local to = id.from + 0.03
			id = "rbxassetid://" .. 9113190384
			v2[id] = (v2[id] or 0) + 1
			table.insert(items5, {
				id = id,
				from = from,
				to = to,
				range = NumberRange.new(from, to)
			})
		end

		v26 = "rbxassetid://" .. 9113184840
		v2[v26] = (v2[v26] or 0) + 1

		do
			local v121 = { id = v26, from = 0.7, to = 3.44, range = NumberRange.new(0.7, 3.44) }
			v26 = "rbxassetid://" .. 9113184771
			v2[v26] = (v2[v26] or 0) + 1
			local v122 = { id = v26, from = 0.62, to = 3.36, range = NumberRange.new(0.62, 3.36) }
			v26 = "rbxassetid://" .. 9113184835
			v2[v26] = (v2[v26] or 0) + 1
			local v123 = { id = v26, from = 0.79, to = 3.52, range = NumberRange.new(0.79, 3.52) }
			v26 = "rbxassetid://" .. 9113184937
			v2[v26] = (v2[v26] or 0) + 1
			v27 = {
				v121,
				v122,
				v123,
				{ id = v26, from = 0.81, to = 3.56, range = NumberRange.new(0.81, 3.56) }
			}
		end

		v26 = "rbxassetid://" .. 113879008765178
		v2[v26] = (v2[v26] or 0) + 1
		local v124 = { id = v26, from = 0, to = 0.466, range = NumberRange.new(0, 0.466) }
		v26 = "rbxassetid://" .. 9116616748
		v2[v26] = (v2[v26] or 0) + 1
		local v125 = { id = v26, from = 0, to = 0.06, range = NumberRange.new(0, 0.06) }
		v26 = "rbxassetid://" .. 9116617140
		v2[v26] = (v2[v26] or 0) + 1
		local v126 = { id = v26, from = 0, to = 0.06, range = NumberRange.new(0, 0.06) }
		v26 = "rbxassetid://" .. 9116616884
		v2[v26] = (v2[v26] or 0) + 1
		local v127 = { id = v26, from = 0.028, to = 0.088, range = NumberRange.new(0.028, 0.088) }
		v26 = "rbxassetid://" .. 9116618898
		v2[v26] = (v2[v26] or 0) + 1
		local items6 = {
			v125,
			v126,
			v127,
			{ id = v26, from = 0, to = 0.06, range = NumberRange.new(0, 0.06) }
		}

		local items7 = {}

		for _, v130 in {
			{ 9114708939, 0.016, 0.741 },
			{ 9114709050, 0.006, 0.841 },
			{ 9114710945, 0.004, 1.189 },
			{ 9114713664, 0.01, 1.603 },
			{ 9114715741, 0.004, 1.148 },
			{ 9114720229, 0.014, 1.585 },
			{ 9114720374, 0.018, 1.641 },
			{ 9114720601, 1.058, 1.585 },
			{ 9114722912, 0.008, 1.23 },
			{ 9114722912, 0.246, 1.135 }
		} do
			local v131 = math.max(v130[2] - 0.004, 0)
			table.insert(items7, gslice(v130[1], v131, v130[2] + 0.07, v130[3])) -- inferred equivalent call
		end

		local v130 = bagOf(items7)
		local v131 = bagOf(items7)

		local items8 = {}

		for _, v133 in { 9113184840, 9113184771, 9113184835, 9113184937, 9113179557 } do
			table.insert(items8, slice(v133, 0, 0.065)) -- inferred equivalent call
		end

		local v133 = { Sniper = 0, RX10 = 0, SC11 = 0 }

		do
			local sniper = {
				punch = bagOf(items8),
				near = bagOf(items8),
				punchK = 0.6,
				low = 0.8,
				high = 0.86,
				punchLen = 1e999,
				punchFade = 0,
				doubleK = 0.38,
				doubleLow = 0.72,
				doubleHigh = 0.76,
				boom = 0,
				boomK = 0.55,
				boomLow = 0.88,
				boomHigh = 0.93,
				boomCut = 250,
				boomLen = 0.45,
				boomFade = 0.25,
				bloomK = 0.5,
				sendK = 0.25,
				vast = true,
				underLow = 1,
				underHigh = 1,
				bodyK = 0.6,
				bodyLow = 0.52,
				bodyHigh = 0.56,
				tailK = 2,
				tailPitch = 0.92,
				tailLen = 1.5,
				tailFade = 1.4,
				reflect = 1.15,
				fight = 0.7
			}
			v26 = "rbxassetid://" .. 9118173739
			v2[v26] = (v2[v26] or 0) + 1

			do
				local v135 = {
					id = v26,
					from = 0.017,
					to = 0.467,
					range = NumberRange.new(0.017, 0.467)
				}

				v135.gain = 2.78
				v135.peak = nil
				v26 = "rbxassetid://" .. 9118173988
				v2[v26] = (v2[v26] or 0) + 1
				local v136 = {
					id = v26,
					from = 0.01,
					to = 0.46,
					range = NumberRange.new(0.01, 0.46)
				}

				v136.gain = 2.51
				v136.peak = nil
				v26 = "rbxassetid://" .. 9118173999
				v2[v26] = (v2[v26] or 0) + 1
				local v137 = {
					id = v26,
					from = 0.022,
					to = 0.472,
					range = NumberRange.new(0.022, 0.472)
				}

				v137.gain = 2.69
				v137.peak = nil
				v26 = "rbxassetid://" .. 9118174270
				v2[v26] = (v2[v26] or 0) + 1
				local v138 = {
					id = v26,
					from = 0.013,
					to = 0.463,
					range = NumberRange.new(0.013, 0.463)
				}

				v138.gain = 2.62
				v138.peak = nil
				v26 = "rbxassetid://" .. 9118173992
				v2[v26] = (v2[v26] or 0) + 1
				local v139 = {
					id = v26,
					from = 0.013,
					to = 0.463,
					range = NumberRange.new(0.013, 0.463)
				}

				v139.gain = 2.21
				v139.peak = nil

				sniper.boom = bagOf({ v135, v136, v137, v138, v139 })
			end

			v133.Sniper = sniper
		end

		v26 = "rbxassetid://" .. 9116349615
		v2[v26] = (v2[v26] or 0) + 1

		do
			local v141 = {
				id = v26,
				from = 0.193,
				to = 0.343,
				range = NumberRange.new(0.193, 0.343)
			}

			v141.gain = 0.99
			v141.peak = nil
			v26 = "rbxassetid://" .. 9116349615
			v2[v26] = (v2[v26] or 0) + 1
			local v142 = {
				id = v26,
				from = 0.555,
				to = 0.705,
				range = NumberRange.new(0.555, 0.705)
			}

			v142.gain = 1
			v142.peak = nil
			v26 = "rbxassetid://" .. 9116349615
			v2[v26] = (v2[v26] or 0) + 1
			local v143 = {
				id = v26,
				from = 0.891,
				to = 1.041,
				range = NumberRange.new(0.891, 1.041)
			}

			v143.gain = 0.99
			v143.peak = nil
			v26 = "rbxassetid://" .. 9116349618
			v2[v26] = (v2[v26] or 0) + 1
			local v144 = {
				id = v26,
				from = 0.343,
				to = 0.493,
				range = NumberRange.new(0.343, 0.493)
			}

			v144.gain = 1.4
			v144.peak = nil

			local rx = {
				punch = bagOf({ v141, v142, v143, v144 }),
				near = nil,
				punchK = 0.66,
				low = 0.92,
				high = 0.98,
				punchLen = 0.12,
				punchFade = 0.03,
				doubleLow = 1,
				doubleHigh = 1,
				boom = 0,
				boomK = 0.4,
				boomLow = 0.92,
				boomHigh = 0.97,
				boomCut = 600,
				underLow = 1,
				underHigh = 1,
				bodyK = 0.6,
				bodyLow = 0.54,
				bodyHigh = 0.58,
				tailK = 0.85,
				tailPitch = 0.9,
				tailLen = 0.85,
				reflect = 1,
				fight = 0.75
			}
			v26 = "rbxassetid://" .. 9118173739
			v2[v26] = (v2[v26] or 0) + 1

			do
				local v145 = {
					id = v26,
					from = 0.017,
					to = 0.2,
					range = NumberRange.new(0.017, 0.2)
				}

				v145.gain = 2.78
				v145.peak = nil
				v26 = "rbxassetid://" .. 9118173988
				v2[v26] = (v2[v26] or 0) + 1
				local v146 = { id = v26, from = 0.01, to = 0.2, range = NumberRange.new(0.01, 0.2) }

				v146.gain = 2.51
				v146.peak = nil
				v26 = "rbxassetid://" .. 9118173999
				v2[v26] = (v2[v26] or 0) + 1
				local v147 = {
					id = v26,
					from = 0.022,
					to = 0.2,
					range = NumberRange.new(0.022, 0.2)
				}

				v147.gain = 2.69
				v147.peak = nil
				v26 = "rbxassetid://" .. 9118174270
				v2[v26] = (v2[v26] or 0) + 1
				local v148 = {
					id = v26,
					from = 0.013,
					to = 0.2,
					range = NumberRange.new(0.013, 0.2)
				}

				v148.gain = 2.62
				v148.peak = nil
				v26 = "rbxassetid://" .. 9118173992
				v2[v26] = (v2[v26] or 0) + 1
				local v149 = {
					id = v26,
					from = 0.013,
					to = 0.2,
					range = NumberRange.new(0.013, 0.2)
				}

				v149.gain = 2.21
				v149.peak = nil

				rx.boom = bagOf({ v145, v146, v147, v148, v149 })
			end

			v133.RX10 = rx
		end

		v26 = "rbxassetid://" .. 9116335036
		v2[v26] = (v2[v26] or 0) + 1

		do
			local v151 = { id = v26, from = 0.01, to = 0.11, range = NumberRange.new(0.01, 0.11) }

			v151.gain = 1.22
			v151.peak = nil
			v26 = "rbxassetid://" .. 9116335315
			v2[v26] = (v2[v26] or 0) + 1
			local v152 = { id = v26, from = 0.01, to = 0.11, range = NumberRange.new(0.01, 0.11) }

			v152.gain = 1.22
			v152.peak = nil
			v26 = "rbxassetid://" .. 9113177786
			v2[v26] = (v2[v26] or 0) + 1
			local v153 = { id = v26, from = 0.01, to = 0.11, range = NumberRange.new(0.01, 0.11) }

			v153.gain = 1.48
			v153.peak = nil
			v26 = "rbxassetid://" .. 9113177810
			v2[v26] = (v2[v26] or 0) + 1
			local v154 = { id = v26, from = 0.01, to = 0.11, range = NumberRange.new(0.01, 0.11) }

			v154.gain = 1.5
			v154.peak = nil

			v133.SC11 = {
				punch = bagOf({ v151, v152, v153, v154 }),
				near = bagOf(items8),
				punchK = 0.62,
				low = 0.9,
				high = 0.96,
				punchLen = 0.08,
				punchFade = 0.025,
				doubleLow = 1,
				doubleHigh = 1,
				boomK = 0,
				boomLow = 1,
				boomHigh = 1,
				boomCut = 20000,
				underK = 0.3,
				underLow = 0.84,
				underHigh = 0.88,
				bodyK = 0.27,
				bodyLow = 0.6,
				bodyHigh = 0.64,
				tailK = 0.6,
				tailPitch = 0.96,
				tailLen = 0.7,
				reflect = 0.75,
				fight = 0.55
			}
		end

		v133.RX10.near = bagOf(v133.RX10.punch.items)
		v26 = "rbxassetid://" .. 9118173739
		v2[v26] = (v2[v26] or 0) + 1

		do
			local v156 = {
				id = v26,
				from = 0.017,
				to = 0.217,
				range = NumberRange.new(0.017, 0.217)
			}

			v156.gain = 2.78
			v156.peak = nil
			v26 = "rbxassetid://" .. 9118173988
			v2[v26] = (v2[v26] or 0) + 1
			local v157 = { id = v26, from = 0.01, to = 0.21, range = NumberRange.new(0.01, 0.21) }

			v157.gain = 2.51
			v157.peak = nil
			v26 = "rbxassetid://" .. 9118173999
			v2[v26] = (v2[v26] or 0) + 1
			local v158 = {
				id = v26,
				from = 0.022,
				to = 0.222,
				range = NumberRange.new(0.022, 0.222)
			}

			v158.gain = 2.69
			v158.peak = nil
			v26 = "rbxassetid://" .. 9118174270
			v2[v26] = (v2[v26] or 0) + 1
			local v159 = {
				id = v26,
				from = 0.013,
				to = 0.213,
				range = NumberRange.new(0.013, 0.213)
			}

			v159.gain = 2.62
			v159.peak = nil
			v26 = "rbxassetid://" .. 9118173992
			v2[v26] = (v2[v26] or 0) + 1
			local v160 = {
				id = v26,
				from = 0.013,
				to = 0.213,
				range = NumberRange.new(0.013, 0.213)
			}

			v160.gain = 2.21
			v160.peak = nil

			v133.VX50 = {
				punch = bagOf({ v156, v157, v158, v159, v160 }),
				near = nil,
				punchK = 0.7,
				low = 0.96,
				high = 1,
				punchLen = 0.2,
				punchFade = 0.06,
				doubleLow = 1,
				doubleHigh = 1,
				boom = v133.Sniper.boom,
				boomK = 0.6,
				boomLow = 0.84,
				boomHigh = 0.9,
				boomCut = 220,
				boomLen = 0.5,
				boomFade = 0.3,
				bloomK = 0.6,
				sendK = 0.3,
				vast = true,
				underLow = 1,
				underHigh = 1,
				bodyK = 0.7,
				bodyLow = 0.48,
				bodyHigh = 0.52,
				tailK = 2.2,
				tailPitch = 0.86,
				tailLen = 1.6,
				tailFade = 1.5,
				reflect = 1.25,
				fight = 0.8
			}
		end

		v133.VX50.near = bagOf(v133.VX50.punch.items)

		local function sniperNear(data, vector3: Vector3, p: number, p2: number)
			local v161 = p / 0.72

			if data.underK then
				emitAt(
					draw(data.punch),
					vector3,
					data.punchK * v161,
					pitch(data.low, data.high), -- inferred equivalent call
					"dry",
					p2,
					1e999,
					0,
					p + 0.1
				)
				emitAt(
					draw(data.near),
					vector3,
					data.underK * v161,
					pitch(data.underLow, data.underHigh), -- inferred equivalent call
					"dry",
					p2,
					1e999,
					0,
					p + 0.05
				)
			else
				emitAt(
					draw(data.near),
					vector3,
					data.punchK * v161,
					pitch(data.low, data.high), -- inferred equivalent call
					"dry",
					math.min(p2, data.punchCut or 20000),
					1e999,
					0,
					p + 0.1
				)
			end

			if data.boom then
				emitAt(
					draw(data.boom),
					vector3,
					data.boomK * v161,
					pitch(data.boomLow, data.boomHigh), -- inferred equivalent call
					"dry",
					math.min(p2, data.boomCut),
					data.boomLen or 0.15,
					data.boomFade or 0.05,
					p + 0.05
				)
			end
		end

		local v161 = {
			cut = 0.088,
			low = 0.95,
			high = 1,
			thump = 0,
			boom = 0,
			boomAt = 0.035,
			boomCut = 500,
			crack = 1.65,
			bassGain = 1.3,
			whump = 0.25,
			boomGain = 1.65,
			remote = 1,
			lowRing = 0
		}
		v26 = "rbxassetid://" .. 9114659666
		v2[v26] = (v2[v26] or 0) + 1

		do
			local thump = { id = v26, from = 0.004, to = 0.2, range = NumberRange.new(0.004, 0.2) }

			thump.gain = 0.9
			thump.peak = nil

			v161.thump = thump
		end

		v26 = "rbxassetid://" .. 9116973611
		v2[v26] = (v2[v26] or 0) + 1
		v161.boom = { id = v26, from = 0.084, to = 0.25, range = NumberRange.new(0.084, 0.25) }

		v161.lowRing = ring("OwnLMGLow", 12)

		do
			local function cutsOf(p: number, items, p2: number, p3)
				local result = {}

				for k, item in items do
					local v163 = math.min(item + v161.cut, (items[k + 1] or p2) - 0.004)
					table.insert(result, gslice(p, math.max(item - 0.003, 0), v163, not p3 and 1 or p3[k])) -- inferred equivalent call
				end

				return result
			end

			do
				local items = {}

				for _, v164 in {
					cutsOf(9119029618, {
						0.004,
						0.098,
						0.194,
						0.288,
						0.386,
						0.488,
						0.588,
						0.684,
						0.776,
						0.87,
						0.962,
						1.058,
						1.154
					}, 1.25),
					cutsOf(9119029950, { 0.004, 0.102, 0.198, 0.294 }, 0.392),
					cutsOf(9119029950, { 0.702, 0.8, 0.904 }, 1.006),
					cutsOf(9119029800, { 0.004, 0.092 }, 0.186)
				} do
					for _, v165 in v164 do
						table.insert(items, v165)
					end
				end

				v26 = bagOf(items)
				near = bagOf(items)
			end

			v161.own = v26
			v161.near = near

			v161.bass = bagOf(cutsOf(9114729452, { 0.072, 0.186, 0.288, 0.392, 0.492 }, 0.594, {
				0.75,
				1,
				1,
				1,
				1
			}))
		end

		v26 = "rbxassetid://" .. 9119029803
		v2[v26] = (v2[v26] or 0) + 1

		do
			local v164 = { id = v26, from = 1.13, to = 2.31, range = NumberRange.new(1.13, 2.31) }
			v26 = "rbxassetid://" .. 9119029950
			v2[v26] = (v2[v26] or 0) + 1
			local v165 = { id = v26, from = 1.07, to = 2.34, range = NumberRange.new(1.07, 2.34) }
			v26 = "rbxassetid://" .. 9119029618
			v2[v26] = (v2[v26] or 0) + 1
			v161.tails = bagOf({
				v164,
				v165,
				{ id = v26, from = 1.31, to = 3.13, range = NumberRange.new(1.31, 3.13) }
			})
		end

		local v166 = { hp = 280, crack = 1.5, remote = 2.6, tailRing = ring("OwnSMGTail", 3) }

		do
			local items = {}

			for _, v168 in {
				{ 9114725778, 0.033, 0.073, 0.75 },
				{ 9114725778, 0.165, 0.208, 0.84 },
				{ 9114725778, 0.253, 0.323, 0.84, true },
				{ 9114725672, 0.12, 0.162, 0.81 },
				{ 9114725672, 0.206, 0.276, 0.83, true },
				{ 9114725666, 0.023, 0.07, 0.76 },
				{ 9114725666, 0.112, 0.163, 0.78 },
				{ 9114725666, 0.206, 0.276, 0.84, true },
				{ 9114725775, 0.017, 0.064, 0.81 },
				{ 9114725775, 0.114, 0.155, 0.78 },
				{ 9114725775, 0.2, 0.27, 0.85, true },
				{ 9114725780, 0.065, 0.118, 0.72 },
				{ 9114725780, 0.166, 0.205, 0.88 },
				{ 9114725780, 0.206, 0.276, 0.82, true },
				{ 9114725964, 0.065, 0.135, 0.74, true },
				{ 9114695926, 0.05, 0.092, 0.72 },
				{ 9114695926, 0.132, 0.176, 0.99 },
				{ 9114695926, 0.268, 0.338, 0.79, true }
			} do
				local v169 = v168[1]

				do
					local from = v168[2]
					local to = v168[3]
					local gain = v168[4]
					v169 = slice(v169, from, to) -- inferred equivalent call

					v169.gain = gain
				end

				v169.peak = nil

				table.insert(items, v169)

				if v168[5] then
					table.insert(items, v169)
				end
			end

			v26 = bagOf(items)
			near = bagOf(items)
		end

		v166.own = v26
		v166.near = near
		v26 = "rbxassetid://" .. 9114725672
		v2[v26] = (v2[v26] or 0) + 1

		do
			local v168 = { id = v26, from = 0.276, to = 0.8, range = NumberRange.new(0.276, 0.8) }

			v168.gain = 0.83
			v168.peak = nil
			v26 = "rbxassetid://" .. 9114725780
			v2[v26] = (v2[v26] or 0) + 1
			local v169 = { id = v26, from = 0.276, to = 0.85, range = NumberRange.new(0.276, 0.85) }

			v169.gain = 0.82
			v169.peak = nil
			v26 = "rbxassetid://" .. 9114725775
			v2[v26] = (v2[v26] or 0) + 1
			local v170 = { id = v26, from = 0.27, to = 0.78, range = NumberRange.new(0.27, 0.78) }

			v170.gain = 0.85
			v170.peak = nil
			v26 = "rbxassetid://" .. 9114695926
			v2[v26] = (v2[v26] or 0) + 1
			local v171 = { id = v26, from = 0.355, to = 0.74, range = NumberRange.new(0.355, 0.74) }

			v171.gain = 0.79
			v171.peak = nil

			v166.tails = bagOf({ v168, v169, v170, v171 })
		end

		v166.base = {
			own = v166.own,
			near = v166.near,
			tails = v166.tails,
			crack = v166.crack,
			remote = v166.remote,
			hp = v166.hp,
			low = 0.95,
			high = 1,
			bodyK = 0.18,
			bodyLow = 0.66,
			bodyHigh = 0.7,
			tailK = 1,
			tailPitch = 1
		}

		v166.voices = {}

		do
			local function voice(items, items2, p)
				local items9 = {}

				for _, item in items do
					table.insert(items9, gslice(item[1], item[2], item[3], item[4])) -- inferred equivalent call
				end

				local own = bagOf(items9)
				local near2 = bagOf(items9)
				p.own = own
				p.near = near2

				if items2 then
					local items10 = {}

					for _, item in items2 do
						table.insert(items10, gslice(item[1], item[2], item[3], item[4])) -- inferred equivalent call
					end

					p.tails = bagOf(items10)
				else
					p.tails = v166.tails
				end

				p.remote = v166.remote * p.crack / v166.crack
				return p
			end

			v166.voices.KP50 = voice({
				{ 9116336471, 0, 0.069, 0.69 },
				{ 9116336471, 0.086, 0.155, 0.69 },
				{ 9116336471, 0.164, 0.23, 0.71 },
				{ 9116336471, 0.232, 0.307, 0.72 },
				{ 9116336471, 0.311, 0.386, 0.72 },
				{ 9116336471, 0.393, 0.467, 0.74 },
				{ 9116336471, 0.469, 0.544, 0.72 },
				{ 9116336471, 0.549, 0.624, 0.7 },
				{ 9116336471, 0.628, 0.703, 0.73 },
				{ 9116336471, 0.706, 0.78, 0.74 },
				{ 9116336471, 0.782, 0.857, 0.77 },
				{ 9116336471, 0.863, 0.934, 0.75 },
				{ 9116336471, 0.936, 1.011, 0.77 },
				{ 9116336471, 1.017, 1.089, 0.74 },
				{ 9116336471, 1.091, 1.165, 0.75 },
				{ 9116336471, 1.167, 1.241, 0.77 },
				{ 9116336471, 1.243, 1.316, 0.74 },
				{ 9116336471, 1.319, 1.391, 0.77 },
				{ 9116336471, 1.393, 1.465, 0.79 },
				{ 9116336471, 1.467, 1.536, 0.76 },
				{ 9116336471, 1.538, 1.613, 0.75 },
				{ 9116336471, 1.616, 1.688, 0.74 },
				{ 9116336471, 1.69, 1.764, 0.76 },
				{ 9116336471, 1.766, 1.841, 0.73 }
			}, {
				{ 9116336471, 1.841, 2.16, 0.73 }
			}, {
				crack = 0.54,
				hp = 200,
				low = 0.97,
				high = 1,
				crackK = 0.3,
				crackHp = 2500,
				bodyK = 0.14,
				bodyLow = 0.7,
				bodyHigh = 0.74,
				tailK = 0.9,
				tailPitch = 1,
				players = 10
			})

			v166.voices.SP44 = voice({
				{ 9116336936, 0, 0.061, 0.84 },
				{ 9116336936, 0.064, 0.146, 0.85 },
				{ 9116336936, 0.148, 0.227, 0.84 },
				{ 9116336936, 0.23, 0.302, 0.87 },
				{ 9116336936, 0.305, 0.388, 0.81 },
				{ 9116336936, 0.393, 0.472, 0.84 },
				{ 9116336936, 0.476, 0.552, 0.79 },
				{ 9116336936, 0.554, 0.627, 0.79 },
				{ 9116336936, 0.629, 0.712, 0.83 },
				{ 9116336936, 0.723, 0.789, 0.86 },
				{ 9116336936, 0.791, 0.859, 0.76 },
				{ 9116345720, 0, 0.066, 0.68 },
				{ 9116345720, 0.075, 0.141, 0.72 },
				{ 9116345720, 0.144, 0.203, 0.68 },
				{ 9116345720, 0.205, 0.262, 0.71 },
				{ 9116345720, 0.319, 0.392, 0.7 },
				{ 9116345720, 0.394, 0.465, 0.72 },
				{ 9116345720, 0.467, 0.54, 0.68 },
				{ 9116345720, 0.542, 0.61, 0.69 },
				{ 9116345720, 0.612, 0.666, 0.71 },
				{ 9116345720, 0.723, 0.794, 0.66 }
			}, nil, {
				crack = 0.56,
				hp = 150,
				low = 0.9,
				high = 0.94,
				bodyK = 0.24,
				bodyLow = 0.58,
				bodyHigh = 0.62,
				tailK = 1,
				tailPitch = 0.92,
				players = 8
			})

			v166.voices.HM45 = voice({
				{ 9114711210, 0, 0.092, 0.98 },
				{ 9114711210, 0.228, 0.321, 0.98 },
				{ 9114711310, 0, 0.092, 1.01 },
				{ 9114715019, 0, 0.092, 1.01 },
				{ 9114715209, 0, 0.092, 1.04 },
				{ 9114715403, 0, 0.092, 1.04 },
				{ 9114715851, 0, 0.092, 0.98 },
				{ 9114717754, 0, 0.092, 1.03 },
				{ 9114708939, 0.002, 0.095, 0.73 },
				{ 9114709050, 0, 0.092, 0.79 },
				{ 9114709440, 0, 0.092, 0.85 },
				{ 9114709440, 0.223, 0.316, 0.85 },
				{ 9114709616, 0, 0.092, 0.74 },
				{ 9114709616, 0.228, 0.321, 0.74 },
				{ 9114710079, 0, 0.092, 0.77 },
				{ 9114710079, 0.216, 0.309, 0.73 },
				{ 9114710079, 0.424, 0.517, 0.73 },
				{ 9114710079, 0.628, 0.721, 0.76 },
				{ 9114718571, 0, 0.092, 0.85 },
				{ 9114718822, 0, 0.092, 0.97 },
				{ 9114719216, 0, 0.092, 0.85 }
			}, {
				{ 9114715019, 0.092, 0.75, 1.01 },
				{ 9114715403, 0.092, 0.75, 1.04 },
				{ 9114717754, 0.092, 0.75, 1.03 }
			}, {
				crack = 1.14,
				hp = 100,
				low = 0.88,
				high = 0.92,
				bodyK = 0.3,
				bodyLow = 0.52,
				bodyHigh = 0.56,
				tailK = 0.9,
				tailPitch = 0.9
			})

			v166.voices.PD46 = voice({
				{ 9116357921, 0.268, 0.337, 2.7 },
				{ 9116357921, 0.96, 1.029, 2.51 },
				{ 9116357921, 1.604, 1.673, 2.42 },
				{ 9116357921, 2.243, 2.312, 2.51 },
				{ 9116357921, 2.705, 2.759, 1.5 },
				{ 9116357921, 2.761, 2.83, 2.49 },
				{ 9116357921, 3.36, 3.429, 2.51 },
				{ 9116357921, 3.794, 3.863, 2.47 },
				{ 9116357921, 4.256, 4.325, 2.6 },
				{ 9116357921, 4.684, 4.753, 2.55 },
				{ 9116357921, 5.182, 5.251, 2.63 },
				{ 9116357921, 6.095, 6.164, 2.5 },
				{ 9116357921, 6.681, 6.732, 1.68 },
				{ 9116357921, 6.734, 6.803, 2.72 },
				{ 9116357921, 7.595, 7.664, 2.52 },
				{ 9116357921, 8.262, 8.331, 2.52 },
				{ 9116357921, 8.919, 8.988, 3.12 },
				{ 9116357921, 9.488, 9.538, 1.67 },
				{ 9116357921, 9.54, 9.609, 2.85 },
				{ 9116357921, 10.13, 10.185, 1.69 },
				{ 9116357921, 10.187, 10.256, 3.14 },
				{ 9116357921, 10.864, 10.933, 2.69 },
				{ 9116357907, 0.261, 0.311, 2.64 },
				{ 9116357907, 0.354, 0.423, 2.7 },
				{ 9116357907, 0.95, 1, 2.9 },
				{ 9116357907, 1.224, 1.293, 2.74 },
				{ 9116357907, 1.622, 1.674, 2.96 },
				{ 9116357907, 1.987, 2.042, 2.71 }
			}, nil, {
				crack = 0.41,
				hp = 400,
				low = 0.97,
				high = 1,
				bodyK = 0.12,
				bodyLow = 0.74,
				bodyHigh = 0.78,
				tailK = 0.75,
				tailPitch = 1,
				players = 8
			})

			v166.voices.TK17 = voice({
				{ 9117926001, 0.312, 0.364, 2.84 },
				{ 9117926001, 0.407, 0.47, 3.44 },
				{ 9117925041, 0.31, 0.363, 3.12 },
				{ 9117925041, 0.365, 0.428, 3.08 },
				{ 9117926086, 0.258, 0.31, 2.33 },
				{ 9117926086, 0.372, 0.435, 3.07 },
				{ 9117924566, 0.562, 0.625, 2.97 },
				{ 9117925159, 0.184, 0.237, 2.79 },
				{ 9117925159, 0.316, 0.379, 2.47 },
				{ 9117926568, 0.379, 0.442, 3.61 },
				{ 9117926755, 0.296, 0.359, 4.01 },
				{ 9117928066, 0, 0.054, 3.24 },
				{ 9117928066, 0.248, 0.301, 2.61 },
				{ 9117928066, 0.352, 0.404, 2.68 },
				{ 9117928066, 0.406, 0.458, 2.83 },
				{ 9117928066, 0.46, 0.523, 2.75 },
				{ 9117924243, 0.561, 0.624, 4.97 },
				{ 9117926875, 0, 0.062, 4.31 },
				{ 9117926875, 0.138, 0.201, 4.32 },
				{ 9117926881, 0.043, 0.106, 4.78 },
				{ 9117926881, 0.205, 0.268, 4.96 },
				{ 9117927024, 0.04, 0.103, 3.45 },
				{ 9117927024, 0.114, 0.166, 4.5 },
				{ 9117927024, 0.255, 0.307, 3.57 },
				{ 9117927677, 0.487, 0.55, 4.3 },
				{ 9117927685, 0.085, 0.139, 4.85 },
				{ 9117927685, 0.488, 0.551, 4.64 },
				{ 9117928140, 0, 0.052, 3.65 },
				{ 9117928140, 0.201, 0.258, 5.05 },
				{ 9117928140, 0.266, 0.329, 3.79 },
				{ 9117928144, 0, 0.053, 4.75 },
				{ 9117928144, 0.192, 0.245, 4.03 },
				{ 9117928144, 0.46, 0.523, 4.23 },
				{ 9117928530, 0.179, 0.233, 3.74 }
			}, nil, {
				crack = 0.49,
				hp = 300,
				low = 0.97,
				high = 1,
				bodyK = 0.14,
				bodyLow = 0.68,
				bodyHigh = 0.72,
				tailK = 0.8,
				tailPitch = 1
			})
		end

		v166.suppressed = { hp = 250, autoK = 0.77, singleK = 0.82 }

		do
			local function bag(items)
				local items2 = {}

				for _, item in items do
					table.insert(items2, gslice(item[1], item[2], item[3], item[4])) -- inferred equivalent call
				end

				return bagOf(items2)
			end

			v166.suppressed.auto = bag({
				{ 9119134226, 0.001, 0.071, 0.84 },
				{ 9119134538, 0, 0.07, 0.77 },
				{ 9119134560, 0, 0.07, 1.01 },
				{ 9119134567, 0.001, 0.071, 0.73 },
				{ 9119134956, 0.001, 0.071, 0.8 },
				{ 9119134977, 0.001, 0.071, 0.79 },
				{ 9119134978, 0, 0.07, 0.83 },
				{ 9119135215, 0.001, 0.071, 1.21 },
				{ 9119135485, 0.001, 0.071, 0.73 },
				{ 9119135495, 0.001, 0.071, 0.8 },
				{ 9119135779, 0.001, 0.071, 0.84 }
			})

			v166.suppressed.single = bag({
				{ 9119135198, 0.001, 0.301, 0.84 },
				{ 9119135215, 0.001, 0.301, 0.92 },
				{ 9119135228, 0, 0.3, 0.83 },
				{ 9119135481, 0, 0.3, 0.97 },
				{ 9119135485, 0.001, 0.301, 0.73 },
				{ 9119135495, 0.001, 0.301, 0.8 },
				{ 9119135779, 0.001, 0.301, 0.84 },
				{ 9119134230, 0, 0.3, 0.97 },
				{ 9119135785, 0, 0.3, 0.92 },
				{ 9119135796, 0.001, 0.301, 0.84 }
			})
		end

		function VoxelSound.isSMGVoice(p: string): boolean
			return v166.voices[p] ~= nil
		end

		function v161.boomAt_(vector3: Vector3, p: number, p2: number)
			emitAt(
				v161.boom,
				vector3,
				p,
				math.min(0.95 + 0.050000000000000044 * math.random(), 1),
				"dry",
				math.min(p2, v161.boomCut),
				0.17,
				0.06,
				p
			)
		end
		function v161.remoteLow(vector3: Vector3, p: number, p2: number)
			local v172 = p * v161.remote / v161.crack
			emitAt(
				draw(v161.bass),
				vector3,
				v172 * v161.bassGain,
				math.min(0.95 + 0.050000000000000044 * math.random(), 1),
				"dry",
				p2,
				1e999,
				0,
				p
			)
			emitAt(
				v161.thump,
				vector3,
				v172 * v161.whump / 0.9,
				math.min(0.95 + 0.050000000000000044 * math.random(), 1),
				"dry",
				p2,
				0.2,
				0.08,
				p
			)
			later(v161.boomAt, v161.boomAt_, vector3, v172 * v161.boomGain, p2)
		end

		local v172 = bagOf(items3)
		local v173 = bagOf(items3)
		v26 = bagOf(items3)
		local v174 = bagOf(items4)
		local v175 = bagOf(items4)
		local v176 = bagOf({ v117, v118 })
		local v177 = bagOf(items5)
		local v178 = bagOf(v27)
		local v179 = bagOf(v27)
		local v180 = bagOf(items6)

		local v181 = {
			open = {
				bus = "open",
				lo = 0.86,
				hi = 0.94,
				gain = 0.6,
				length = 2.4,
				fade = 1
			},
			street = {
				bus = "street",
				lo = 0.92,
				hi = 1,
				gain = 0.5,
				length = 1.1,
				fade = 0.5
			},
			room = {
				bus = "room",
				lo = 0.9,
				hi = 0.98,
				gain = 0.45,
				length = 0.9,
				fade = 0.4
			}
		}

		do
			local function tailClassFor(p, p2: number): string
				if p and p.roof and p.walls >= 3 or p2 < 15 and v13 > 0.55 then
					return "room"
				end

				if p and p.walls >= 2 or p2 < 40 and v12.walls >= 4 then
					return "street"
				end

				return "open"
			end
		end

		local v182 = { bag = v26, lo = 0.9, hi = 0.96, length = 1e999 }
		local function reflectPlay(vector3: Vector3, p: number, p2: number, data)
			emitAt(
				draw(data.bag),
				vector3,
				p,
				pitch(data.lo, data.hi), -- inferred equivalent call
				"reflect",
				airCutoff(p2), -- inferred equivalent call
				data.length,
				0.4,
				p * 0.5
			)
		end

		local function reflections(vector3: Vector3, vector3_2: Vector3, p: number, p2: number, p3)
			local level = VoxelSound.lean.level

			if level > 0 and p > 0 then
				return
			end

			local v183 = level >= 2
			local v184 = 0
			local pos = nil
			local v185 = 0
			local v186 = 0

			for _, reflector in v12.reflectors do
				local magnitude = (vector3 - reflector.pos).Magnitude
				local magnitude2 = (reflector.pos - vector3_2).Magnitude
				local v187 = (magnitude + magnitude2 - p) / meter / 343

				if not (v187 > 0.012) then
					continue
				end

				local v188 = (magnitude + magnitude2) / meter
				local v190 = (v112[reflector.kind] or 0.3) * gunLevel(v188) * p2 -- inferred equivalent call

				if not (v190 >= 0.01) then
					continue
				end

				if v183 then
					if v184 < v190 then
						pos = reflector.pos
						v186 = v188
						v185 = v187
						v184 = v190
					end
				else
					later(v187, reflectPlay, reflector.pos, v190, v188, p3 or v182)
				end
			end

			if pos then
				later(v185, reflectPlay, pos, v184, v186, p3 or v182)
			end
		end

		local v183 = {}

		local function remoteTail(pos: Vector3, p: number, data, p2: number, p3: number)
			local now = os.clock()
			local v184 = nil
			local v185 = nil

			for _, v187 in v183 do
				if (v187.pos - pos).Magnitude < 12 and now - v187.t < 3 then
					v185 = v187
					break
				elseif not v184 or v187.t < v184.t then
					v184 = v187
				end
			end

			if v185 then
				local tailGap = VoxelSound.lean.tailGap
				local voice = v185.voice

				if
					tailGap > 0
					and now - v185.t < tailGap
					and voice
					and voice.serial == v185.serial
					and now < voice.busyUntil
				then
					return
				end

				cutShort(v185.voice, v185.serial, 0.3) -- inferred equivalent call
			elseif #v183 < 24 then
				v185 = { pos = pos, voice = nil, serial = 0, t = now }
				table.insert(v183, v185)
			else
				cutShort(v184.voice, v184.serial, 0.3) -- inferred equivalent call
				v185 = v184
			end

			v185.pos = pos
			v185.t = now
			local voice = emitAt(draw(v178), pos, p, pitch(data.lo, data.hi), data.bus, p2, data.length, data.fade, p3) -- inferred equivalent call
			v185.voice = voice
			v185.serial = not voice and 0 or voice.serial
		end

		local v184 = {}

		do
			local function voice(items, p)
				local items2 = {}

				for _, item in items do
					table.insert(items2, gslice(item[1], item[2], item[3], item[4])) -- inferred equivalent call
				end

				local own = bagOf(items2)
				local near2 = bagOf(items2)
				p.own = own
				p.near = near2
				p.crackHp = p.crackHp or 20000
				return p
			end

			v184.K433 = voice({
				{ 9116353340, 0.115, 0.194, 3.5 },
				{ 9116353340, 0.201, 0.28, 3.66 },
				{ 9116353340, 0.287, 0.366, 3.66 },
				{ 9116353340, 0.377, 0.456, 3.65 },
				{ 9116353340, 0.464, 0.543, 3.53 },
				{ 9116353340, 0.551, 0.63, 3.56 },
				{ 9116353340, 0.636, 0.715, 3.61 },
				{ 9116353340, 0.727, 0.806, 3.56 },
				{ 9116353340, 0.812, 0.891, 3.58 },
				{ 9116353340, 0.897, 0.976, 3.6 },
				{ 9116353340, 0.988, 1.067, 3.58 },
				{ 9116353340, 1.161, 1.24, 3.62 },
				{ 9116353340, 1.246, 1.325, 3.61 },
				{ 9116353340, 1.337, 1.416, 3.62 },
				{ 9116353340, 1.42, 1.499, 3.6 },
				{ 9116353340, 1.517, 1.596, 3.67 },
				{ 9116353340, 1.603, 1.682, 3.59 },
				{ 9116353340, 1.769, 1.848, 3.62 },
				{ 9116353340, 1.866, 1.945, 3.65 },
				{ 9116353340, 1.952, 2.031, 3.63 },
				{ 9116353340, 2.042, 2.121, 3.65 },
				{ 9116353340, 2.31, 2.389, 3.68 },
				{ 9116353340, 2.396, 2.475, 3.59 },
				{ 9116353340, 2.659, 2.738, 3.64 }
			}, {
				punchK = 0.47,
				low = 0.96,
				high = 1,
				bodyK = 0.22,
				bodyLow = 0.64,
				bodyHigh = 0.68,
				tailK = 0.75,
				tailPitch = 1,
				tailLen = 0.85,
				players = 12
			})

			v184.GX36 = voice({
				{ 9114550430, 0.048, 0.131, 0.76 },
				{ 9114550430, 0.151, 0.234, 0.75 },
				{ 9114550430, 0.235, 0.318, 0.81 },
				{ 9114550430, 0.327, 0.402, 0.77 },
				{ 9114550432, 0.061, 0.144, 0.77 },
				{ 9114550432, 0.167, 0.25, 0.79 },
				{ 9114550432, 0.252, 0.335, 0.77 },
				{ 9114550432, 0.344, 0.426, 0.78 },
				{ 9114550432, 0.427, 0.51, 0.7 },
				{ 9114550437, 0.004, 0.087, 0.72 },
				{ 9114550437, 0.088, 0.171, 0.81 },
				{ 9114550437, 0.177, 0.26, 0.83 },
				{ 9114550437, 0.265, 0.348, 0.79 },
				{ 9114550437, 0.361, 0.444, 0.82 },
				{ 9114550437, 0.617, 0.7, 0.87 },
				{ 9114549650, 0.093, 0.176, 0.88 },
				{ 9114549650, 0.187, 0.265, 0.87 },
				{ 9114549650, 0.266, 0.33, 0.88 },
				{ 9114549732, 0.1, 0.16, 0.84 },
				{ 9114549732, 0.161, 0.244, 0.82 },
				{ 9114549732, 0.307, 0.39, 0.91 },
				{ 9114550311, 0.004, 0.087, 0.67 },
				{ 9114550313, 0.004, 0.064, 0.68 },
				{ 9114550313, 0.065, 0.148, 0.68 },
				{ 9114550313, 0.184, 0.265, 0.74 },
				{ 9114550313, 0.266, 0.349, 0.67 }
			}, {
				punchK = 0.55,
				low = 0.94,
				high = 1,
				bodyK = 0.36,
				bodyLow = 0.56,
				bodyHigh = 0.6,
				tailK = 0.9,
				tailPitch = 0.97,
				tailLen = 1,
				players = 6
			})

			v184.SK556 = voice({
				{ 9114729496, 0.069, 0.172, 0.91 },
				{ 9114729496, 0.178, 0.275, 1.44 },
				{ 9114729496, 0.276, 0.374, 1.44 },
				{ 9114729496, 0.375, 0.472, 1.41 },
				{ 9114729496, 0.473, 0.57, 1.46 },
				{ 9114729496, 0.571, 0.666, 1.33 },
				{ 9114729496, 0.667, 0.767, 1.46 },
				{ 9114729496, 0.768, 0.863, 1.49 },
				{ 9114729496, 0.864, 0.957, 1.6 },
				{ 9114729496, 0.958, 1.061, 1.52 },
				{ 9114729399, 0.056, 0.159, 0.9 },
				{ 9114729399, 0.169, 0.272, 1.4 },
				{ 9114729399, 0.275, 0.378, 1.44 },
				{ 9114729399, 0.389, 0.492, 1.45 }
			}, {
				punchK = 0.47,
				low = 0.93,
				high = 0.98,
				crackK = 0.56,
				crackHp = 600,
				bodyK = 0.4,
				bodyLow = 0.5,
				bodyHigh = 0.54,
				tailK = 1,
				tailPitch = 0.92,
				tailLen = 1.15,
				players = 10
			})

			v184.RN545 = voice({
				{ 9113198548, 0, 0.074, 1.32 },
				{ 9113198548, 0.081, 0.155, 1.31 },
				{ 9113198548, 0.169, 0.237, 1.3 },
				{ 9113198548, 0.239, 0.313, 1.7 },
				{ 9113198548, 1.69, 1.764, 1.33 },
				{ 9113198548, 1.769, 1.843, 1.32 },
				{ 9113198548, 1.857, 1.927, 1.29 },
				{ 9113198548, 1.929, 2.003, 1.62 },
				{ 9113198548, 3.387, 3.461, 1.32 },
				{ 9113198548, 3.465, 3.535, 1.31 },
				{ 9113198548, 3.537, 3.611, 1.67 },
				{ 9113198548, 4.957, 5.031, 1.32 },
				{ 9113198548, 5.034, 5.108, 1.32 },
				{ 9113198548, 5.118, 5.188, 1.33 },
				{ 9113198548, 5.19, 5.264, 1.73 },
				{ 9113198548, 6.639, 6.713, 1.33 },
				{ 9113198548, 6.716, 6.784, 1.31 }
			}, {
				punchK = 0.31,
				low = 0.96,
				high = 1,
				crackK = 0.43,
				crackHp = 2500,
				bodyK = 0.12,
				bodyLow = 0.7,
				bodyHigh = 0.74,
				tailK = 0.7,
				tailPitch = 1,
				tailLen = 0.8,
				players = 14
			})

			v184.MX65 = voice({
				{ 9113188135, 0, 0.068, 0.59 },
				{ 9113188135, 0.07, 0.153, 0.66 },
				{ 9113188135, 0.155, 0.225, 0.72 },
				{ 9113188135, 0.227, 0.315, 0.71 },
				{ 9113188135, 0.317, 0.41, 0.65 },
				{ 9113188135, 0.412, 0.505, 0.86 },
				{ 9113184937, 0, 0.071, 0.86 },
				{ 9113184937, 0.073, 0.151, 0.94 },
				{ 9113184937, 0.154, 0.221, 0.87 },
				{ 9113184937, 0.223, 0.292, 0.89 },
				{ 9113184937, 0.294, 0.362, 0.94 },
				{ 9113184937, 0.364, 0.434, 0.83 },
				{ 9113184937, 0.436, 0.51, 0.89 },
				{ 9113184937, 0.512, 0.583, 0.88 },
				{ 9113184937, 0.585, 0.655, 0.86 },
				{ 9113184937, 0.657, 0.75, 0.85 }
			}, {
				punchK = 0.66,
				low = 0.94,
				high = 0.99,
				bodyK = 0.4,
				bodyLow = 0.52,
				bodyHigh = 0.56,
				tailK = 1,
				tailPitch = 0.95,
				tailLen = 1.1,
				players = 6
			})

			v184.BT762 = voice({
				{ 9113191613, 0, 0.069, 1.6 },
				{ 9113191613, 0.071, 0.153, 1.69 },
				{ 9113191613, 1.134, 1.203, 1.62 },
				{ 9113191613, 1.205, 1.287, 1.72 },
				{ 9113191613, 2.133, 2.203, 1.64 },
				{ 9113191613, 2.205, 2.287, 1.75 },
				{ 9113191613, 2.294, 2.376, 1.75 },
				{ 9113191613, 3.16, 3.229, 1.63 },
				{ 9113191613, 3.231, 3.313, 1.76 },
				{ 9113191613, 4.118, 4.186, 1.63 },
				{ 9113191613, 4.188, 4.27, 1.75 },
				{ 9113191613, 4.278, 4.36, 1.69 },
				{ 9113191613, 5.11, 5.18, 1.63 },
				{ 9113191613, 5.182, 5.264, 1.77 },
				{ 9113191613, 5.271, 5.353, 1.73 },
				{ 9113191613, 6.336, 6.404, 1.65 },
				{ 9113191613, 6.406, 6.488, 1.75 },
				{ 9113191613, 6.495, 6.577, 1.74 },
				{ 9113191613, 7.444, 7.514, 1.61 },
				{ 9113191613, 7.516, 7.598, 1.73 }
			}, {
				punchK = 0.63,
				low = 0.95,
				high = 1,
				crackK = 0.5,
				crackHp = 1000,
				bodyK = 0.36,
				bodyLow = 0.54,
				bodyHigh = 0.58,
				tailK = 0.9,
				tailPitch = 0.96,
				tailLen = 1,
				players = 12
			})
		end

		function VoxelSound.isRifleVoice(p: string): boolean
			return v184[p] ~= nil
		end

		VoxelSound.QUIET_CUTOFF = 2000

		do
			local function arrive(vector3: Vector3, p: number, p2: string?, value: number?)
				local v185 = p * (value or 1)
				local v186 = p2 == "Pistol"
				local v187

				if p2 then
					v187 = v133[p2]
				end

				local v188 = p2 == "LMG"
				local v189

				if p2 == "SMG" then
					v189 = v166.base
				elseif p2 then
					v189 = v166.voices[p2]
				end

				local v190 = p2 == "DMR"
				local v191 = p2 == "Shotgun"
				local v192 = p2 == "HandCannon"
				local v193

				if p2 then
					v193 = v184[p2]
				end

				local v194 = camPos() -- inferred equivalent call
				local magnitude = (vector3 - v194).Magnitude
				local v195 = math.max(magnitude / meter, 1)
				local v196 = jitter() -- inferred equivalent call
				local v197 = occluded(vector3, v194, magnitude)

				local v198 = 1
				local v199 = airCutoff(v195 / 1) -- inferred equivalent call

				if v197 then
					v198 *= 0.55
					v199 = math.min(v199, 900)
				end

				if v13 > 0 and v195 > 15 then
					v198 *= 1 - v13 * 0.45
					v199 = math.max(v199 * (1 - v13 * 0.6), 700)
				end

				local v200

				if value then
					v200 = math.min(v199, VoxelSound.QUIET_CUTOFF)
				else
					v200 = v199
				end

				local v201 = gunLevel(v195) * v185 * v196 * v198 -- inferred equivalent call

				local v202 = smoothstep(v113[1], v113[2], v195) -- inferred equivalent call
				local v203 = smoothstep(v114[1], v114[2], v195) -- inferred equivalent call
				local v204 = smoothstep(v115[1], v115[2], v195) -- inferred equivalent call
				local v205 = math.cos(v202 * 1.5707963267948966)
				local v206 = math.sin(v202 * 1.5707963267948966) * math.cos(v203 * 1.5707963267948966)
				local v207 = math.sin(v203 * 1.5707963267948966) * math.cos(v204 * 1.5707963267948966)
				local v208 = math.sin(v204 * 1.5707963267948966)

				if v205 > 0.01 then
					local v209 = v201 * 0.6 * v205

					if value then
						local suppressed = v166.suppressed
						local v210 = v190 or v187 ~= nil or v192 or v191 or v186
						local v211

						if v210 then
							v211 = suppressed.single
						else
							v211 = suppressed.auto
						end

						local v212 = draw(v211)
						local v213

						if v210 then
							v213 = suppressed.singleK
						else
							v213 = suppressed.autoK
						end

						local v214 = v209 * v213 / 0.5 * value ^ (-0.34)
						local v215

						if v210 then
							v215 = math.min(0.86 + 0.06000000000000005 * math.random(), 1)
						else
							v215 = math.min(0.93 + 0.04999999999999993 * math.random(), 1)
						end

						emitAt(v212, vector3, v214, v215, "dry", v199, 1e999, 0, v209 + 0.1, suppressed.hp)
					elseif v190 then
						VoxelSound.dmrNear(vector3, v209, v200)
					elseif v191 then
						VoxelSound.shotgunNear(vector3, v209, v200)
					elseif v192 then
						VoxelSound.handCannonNear(vector3, v209, v200)
					elseif v187 then
						sniperNear(v187, vector3, v209, v200)
					elseif v193 then
						local v210 = draw(v193.near)
						local v211 = pitch(v193.low, v193.high) -- inferred equivalent call
						emitAt(v210, vector3, v209 * v193.punchK / 0.5, v211, "dry", v200, 1e999, 0, v209 + 0.1)

						if v193.crackK and v200 >= 6000 then
							emitAt(
								v210,
								vector3,
								v209 * v193.crackK / 0.5,
								v211,
								"dry",
								v200,
								1e999,
								0,
								v209 + 0.05,
								v193.crackHp
							)
						end
					elseif v189 then
						local v210 = draw(v189.near)
						local v211 = pitch(v189.low, v189.high) -- inferred equivalent call
						emitAt(v210, vector3, v209 * v189.remote, v211, "dry", v200, 1e999, 0, v209 + 0.1, v189.hp)

						if v189.crackK and v200 >= 6000 then
							emitAt(
								v210,
								vector3,
								v209 * v189.remote * v189.crackK / v189.crack,
								v211,
								"dry",
								v200,
								1e999,
								0,
								v209 + 0.05,
								v189.crackHp
							)
						end
					else
						local v210

						if v186 then
							v210 = v131
						elseif v188 then
							v210 = v161.near
						else
							v210 = v173
						end

						local v211 = draw(v210)
						local v212

						if v188 then
							v212 = v209 * v161.remote
						else
							v212 = v209
						end

						local v213

						if v188 then
							v213 = pitch(v161.low, v161.high) -- inferred equivalent call
						else
							v213 = math.min(0.94 + 0.06000000000000005 * math.random(), 1)
						end

						emitAt(v211, vector3, v212, v213, "dry", v200, 1e999, 0, v209 + 0.1)
					end

					if v188 then
						v161.remoteLow(vector3, v209, v200)
					end
				end

				if v206 > 0.01 then
					local v209 = v201 * 0.6 * v206

					if v190 then
						VoxelSound.dmrMid(vector3, v209, v200)
					elseif v191 then
						VoxelSound.shotgunMid(vector3, v209, v200)
					else
						emitAt(
							draw(v174),
							vector3,
							v209,
							math.min(0.94 + 0.06000000000000005 * math.random(), 1),
							"dry",
							v200,
							1e999,
							0,
							v209 + 0.1
						)
					end
				end

				if v207 > 0.01 and not value then
					local v209 = v201 * 0.65 * v207
					emitAt(
						draw(v175),
						vector3,
						v209,
						math.min(0.86 + 0.07000000000000006 * math.random(), 1),
						"dry",
						math.min(v200, 3200),
						1e999,
						0,
						v209 + 0.1
					)
				end

				if v208 > 0.01 and not value then
					local v209 = v201 * 0.7 * v208
					emitAt(
						draw(v176),
						vector3,
						v209,
						math.min(0.9 + 0.09999999999999998 * math.random(), 1),
						"dry",
						math.min(v200, 1300),
						0.6,
						0.4,
						v209 + 0.1
					)
				end

				if v195 < 40 then
					local v209

					if v186 then
						v209 = 0.18
					elseif v189 then
						v209 = 0.16 * v189.bodyK / 0.18
					elseif v187 then
						v209 = 0.4
					elseif v188 or v191 or v192 then
						v209 = 0.36
					elseif not v193 then
						v209 = 0.28
					else
						v209 = 0.28 * v193.bodyK / 0.3
					end

					local v210 = v209 * v201
					local v211

					if v187 or v188 or v192 then
						v211 = math.min(0.52 + 0.040000000000000036 * math.random(), 1)
					elseif v189 then
						v211 = pitch(v189.bodyLow, v189.bodyHigh) -- inferred equivalent call
					elseif v193 then
						v211 = pitch(v193.bodyLow, v193.bodyHigh) -- inferred equivalent call
					else
						v211 = math.min(0.6 + 0.040000000000000036 * math.random(), 1)
					end

					emitAt(v124, vector3, v210, v211, "dry", v200, v187 and 0.45 or 0.35, 0.15, v210)
				end

				local v209 = shooterCell(vector3)
				local v210

				if v209 and v209.roof and v209.walls >= 3 or v195 < 15 and v13 > 0.55 then
					v210 = "room"
				elseif v209 and v209.walls >= 2 then
					v210 = "street"
				elseif v195 < 40 and v12.walls >= 4 then
					v210 = "street"
				else
					v210 = "open"
				end

				local v211 = v181[v210]
				local v212 = v210 == "room" and 1 or 1 - v13 * 0.5
				local v213 = v211.gain * tailLevel(v195) * v185 * v212 * (v197 and 0.8 or 1) -- inferred equivalent call

				remoteTail(vector3, v213, v211, math.max(airCutoff(v195 * 0.7), v197 and 1600 or 0), v213 * 0.8) -- inferred equivalent call

				if v195 < 120 then
					reflections(vector3, v194, magnitude, v185 * v196 * v198)
				end

				heardFight(v201) -- inferred equivalent call
			end

			local v185 = { 0.68, 0.76 }

			local v186 = { 0.78, 0.86 }
			v26 = { gain = 2.4, within = 28 }
			v26 = "rbxassetid://" .. 9113634361
			v2[v26] = (v2[v26] or 0) + 1
			local v187 = { id = v26, from = 0.02, to = 0.33, range = NumberRange.new(0.02, 0.33) }

			v187.gain = 2.5
			v187.peak = nil
			v26 = "rbxassetid://" .. 9113634444
			v2[v26] = (v2[v26] or 0) + 1
			local v188 = { id = v26, from = 0.12, to = 0.5, range = NumberRange.new(0.12, 0.5) }

			v188.gain = 1
			v188.peak = 0.153

			local function whizBy(vector3: Vector3, p: number, p2: number, flag: boolean?, value: number?)
				local v189 = p2 * 0.5 * (0.35 + 0.65 * (1 - p / (flag and 16 or value or 5))) * jitter() -- inferred equivalent call

				if value and not flag then
					local v190 = v189 * 1.5
					emitAt(
						v188,
						vector3,
						0.8 * v190,
						math.min(0.8 + 0.09999999999999998 * math.random(), 1),
						"dry",
						20000,
						1e999,
						0,
						v190 + 0.4
					)
				else
					if not flag then
						emitAt(
							v188,
							vector3,
							0.8 * v189,
							math.min(0.85 + 0.15000000000000002 * math.random(), 1),
							"dry",
							20000,
							1e999,
							0,
							v189 + 0.4
						)

						return
					end

					local v190 = v189 * 2
					emitAt(v188, vector3, 0.8 * v190, pitch(v185[1], v185[2]), "dry", 20000, 1e999, 0, v190 + 0.4) -- inferred equivalent call
				end
			end
			local function whizSnap(vector3: Vector3, p: number, p2: number, p3: number, flag: boolean?)
				local v189 = p3 * 0.5 * ((1 - p / p2) * 0.5 + 0.5) * jitter() -- inferred equivalent call

				if not flag then
					emitAt(
						v187,
						vector3,
						v189,
						math.min(0.88 + 0.12 * math.random(), 1),
						"dry",
						20000,
						0.3,
						0.1,
						v189 + 0.5
					)

					return
				end

				emitAt(v187, vector3, v189, pitch(v186[1], v186[2]), "dry", 20000, 0.36, 0.12, v189 + 0.5) -- inferred equivalent call
			end
			local function crack(worldPosition: Vector3, p: number, value: number?, value2: number?)
				local v189 = 1 - p / (value2 or 15)
				local v190 = 0.45 * (value or 1) * v189 * v189 * jitter() -- inferred equivalent call
				emitAt(
					draw(v177),
					worldPosition,
					v190,
					math.min(0.9 + 0.09999999999999998 * math.random(), 1),
					"dry",
					20000,
					0.03,
					0.01,
					v190 + 0.5,
					2000
				)
			end
			local function bulletPass(vector3: Vector3, vector3_2: Vector3, vector3_3: Vector3, p: string?)
				local v189

				if p == nil then
					v189 = false
				else
					v189 = v133[p] ~= nil
				end

				local v190 = vector3_2 - vector3
				local magnitude = v190.Magnitude

				if magnitude < 1 then
					return
				end

				local v191 = v190 / magnitude
				local dot = (vector3_3 - vector3):Dot(v191)

				if dot < 6 * meter or magnitude + 28 * meter < dot then
					return
				end

				local v192 = vector3 + v191 * math.min(dot, magnitude)
				local v193 = (vector3_3 - v192).Magnitude / meter
				local v194 = math.min(dot, magnitude) / meter / 850
				local v195 = smoothstep(25, 80, (vector3 - vector3_3).Magnitude / meter) -- inferred equivalent call
				local v196 = p == "DMR"

				if (v189 or v196) and dot <= magnitude and VoxelSound.passed then
					local v197 = v189 and 16 or 8

					if v193 < v197 then
						later(v194, VoxelSound.passed, vector3, v192, v193 / v197, v189)
					end
				end

				if v196 then
					if dot <= magnitude and v193 < 8 then
						later(math.max(v194 - v188.peak / 0.8, 0), whizBy, v192, v193, math.max(v195, 0.8), false, 8)

						if v193 < 3 then
							later(v194, whizSnap, v192, v193, 3, 1)
						end
					end

					if dot <= magnitude and v193 < 18 then
						later(v194, crack, v192, v193, 1.4, 18)
					end
				elseif v189 then
					if dot <= magnitude and v193 < 16 then
						local v197 = v188.peak / v185[1]
						later(math.max(v194 - v197, 0), whizBy, v192, v193, math.max(v195, 0.55), true)

						if v193 < 5 then
							later(v194, whizSnap, v192, v193, 5, 1, true)
						end
					end

					if dot <= magnitude and v193 < 28 then
						later(v194, crack, v192, v193, 2.4, 28)
					end
				else
					if dot <= magnitude and v193 < 5 then
						later(math.max(v194 - v188.peak, 0), whizBy, v192, v193, (math.max(v195, 0.55)))
						local v197 = v195 * 1 + 1

						if v193 < v197 then
							later(v194, whizSnap, v192, v193, v197, v195 * 0.5 + 0.5)
						end
					end

					if dot <= magnitude and v193 < 15 and (vector3 - vector3_3).Magnitude / meter > 30 then
						later(v194, crack, v192, v193)
					end
				end
			end

			function VoxelSound.shot(vector3: Vector3, p: number, vector3_2: Vector3?, p2: string?, p3: number?)
				local v189 = camPos() -- inferred equivalent call
				later((vector3 - v189).Magnitude / meter / 343, arrive, vector3, p, p2, p3)

				if vector3_2 then
					bulletPass(vector3, vector3_2, v189, p2)
				end

				VoxelSound.otherCasing(vector3, p2)
			end
			VoxelSound.farShot = VoxelSound.shot

			do
				local v189 = ring("OwnPunch", 4)
				local v190 = ring("OwnBody", 4)
				local v191 = ring("OwnMech", 3)
				local v192 = ring("OwnTail", 5)

				v71 = ring("Hurt", 2)

				do
					local function ownTailClass(): string -- 8 equivalent calls inferred from this helper
						if v13 > 0.55 then
							return "room"
						end

						if v12.walls >= 4 then
							return "street"
						end

						return "open"
					end
				end

				function v166.ownQuiet(p: number, p2: number, flag: boolean, p3: number, p4: number)
					local suppressed = v166.suppressed
					local v193

					if flag then
						v193 = suppressed.single
					else
						v193 = suppressed.auto
					end

					local v194 = draw(v193)
					local v195

					if flag then
						v195 = suppressed.singleK
					else
						v195 = suppressed.autoK
					end

					ringFire( -- inferred equivalent call
						v189,
						v194,
						v195 * p * p2 ^ (-0.34) * jitter(), -- inferred equivalent call
						pitch(p3, p4), -- inferred equivalent call
						"dry",
						1e999,
						0,
						nil,
						suppressed.hp
					)
				end

				function VoxelSound.ownShot(p: number, p2: string?, value: number?)
					VoxelSound.casing("small")
					local v193

					if p2 then
						v193 = v184[p2]
					end

					if p2 ~= nil and v193 == nil then
						error("[VoxelSound] no rifle voice for " .. tostring(p2))
					end

					v8 = math.max(v8, 0)
					local v194 = p * (value or 1)

					if v193 then
						local v195 = draw(v193.own)
						local v196 = pitch(v193.low, v193.high) -- inferred equivalent call
						local v197 = jitter() -- inferred equivalent call

						if value then
							v166.ownQuiet(v194, value, false, 0.92 * v193.high, v193.high)
						else
							ringFire(v189, v195, v193.punchK * v194 * v197, v196, "dry", 1e999, 0) -- inferred equivalent call
						end

						if v193.crackK and not value then
							ringFire(v189, v195, v193.crackK * v194 * v197, v196, "dry", 1e999, 0, nil, v193.crackHp) -- inferred equivalent call
						end

						ringFire( -- inferred equivalent call
							v190,
							v124,
							v193.bodyK * v194 * (0.9 + 0.1 * math.random()),
							pitch(v193.bodyLow, v193.bodyHigh), -- inferred equivalent call
							"dry",
							0.4,
							0.15
						)
					else
						if value then
							v166.ownQuiet(v194, value, false, 0.92, 0.96)
						else
							ringFire( -- inferred equivalent call
								v189,
								draw(v172),
								v194 * 0.5 * jitter(), -- inferred equivalent call
								math.min(0.94 + 0.06000000000000005 * math.random(), 1),
								"dry",
								1e999,
								0
							)
						end

						ringFire( -- inferred equivalent call
							v190,
							v124,
							v194 * 0.3 * (0.9 + 0.1 * math.random()),
							math.min(0.6 + 0.040000000000000036 * math.random(), 1),
							"dry",
							0.4,
							0.15
						)
					end

					ringFire( -- inferred equivalent call
						v191,
						draw(v180),
						v194 * 0.06 / (value or 1),
						math.min(0.78 + 0.05999999999999994 * math.random(), 1),
						"dry",
						0.06,
						0.02
					)

					for _, voice in v192.voices do
						cutShort(voice, voice.serial, 0.2) -- inferred equivalent call
					end

					local v195 = v181[ownTailClass()] -- inferred equivalent call

					local v196 = not v193 and 1 or v193.tailK
					local v197 = not v193 and 1 or v193.tailPitch
					local v198 = not v193 and 1 or v193.tailLen
					ringFire( -- inferred equivalent call
						v192,
						draw(v179),
						v195.gain * 0.8 * v194 * v196,
						pitch(v195.lo * v197, v195.hi * v197), -- inferred equivalent call
						v195.bus,
						v195.length * v198,
						v195.fade
					)
					local v199 = camPos() -- inferred equivalent call
					reflections(v199, v199, 0, v194 * 0.8)
					heardFight(v194 * 0.5) -- inferred equivalent call
				end

				function v161.ownBoom(p: number)
					ringFire( -- inferred equivalent call
						v161.lowRing,
						v161.boom,
						v161.boomGain * p * (0.9 + 0.1 * math.random()),
						math.min(0.95 + 0.050000000000000044 * math.random(), 1),
						"dry",
						0.17,
						0.06,
						v161.boomCut
					)
				end
				function VoxelSound.ownLMG(p: number, value: number?)
					VoxelSound.casing("small")
					v8 = math.max(v8, 0)
					local v193 = p * (value or 1)

					if value then
						v166.ownQuiet(v193, value, false, 0.88, 0.92)
					else
						ringFire( -- inferred equivalent call
							v189,
							draw(v161.own),
							v161.crack * v193 * jitter(), -- inferred equivalent call
							pitch(v161.low, v161.high), -- inferred equivalent call
							"dry",
							1e999,
							0
						)
					end

					ringFire( -- inferred equivalent call
						v161.lowRing,
						draw(v161.bass),
						v161.bassGain * v193 * (0.9 + 0.1 * math.random()),
						math.min(0.95 + 0.050000000000000044 * math.random(), 1),
						"dry",
						1e999,
						0
					)
					ringFire( -- inferred equivalent call
						v161.lowRing,
						v161.thump,
						v161.whump / 0.9 * v193 * (0.9 + 0.1 * math.random()),
						math.min(0.95 + 0.050000000000000044 * math.random(), 1),
						"dry",
						0.2,
						0.08
					)
					later(v161.boomAt + 0.004 * math.random(), v161.ownBoom, v193)
					ringFire( -- inferred equivalent call
						v190,
						v124,
						v193 * 0.15 * (0.9 + 0.1 * math.random()),
						math.min(0.7 + 0.050000000000000044 * math.random(), 1),
						"dry",
						0.4,
						0.15
					)
					ringFire( -- inferred equivalent call
						v191,
						draw(v180),
						v193 * 0.05,
						math.min(0.85 + 0.050000000000000044 * math.random(), 1),
						"dry",
						0.07,
						0.02
					)

					for _, voice in v192.voices do
						cutShort(voice, voice.serial, 0.2) -- inferred equivalent call
					end

					local v194 = v181[ownTailClass()] -- inferred equivalent call
					local v195

					if v194.bus == "open" then
						v195 = draw(v161.tails)
					else
						v195 = draw(v179)
					end

					ringFire( -- inferred equivalent call
						v192,
						v195,
						v194.gain * 0.95 * v193,
						pitch(v194.lo * 0.94, v194.hi * 0.94), -- inferred equivalent call
						v194.bus,
						v194.length * 1.15,
						v194.fade
					)
					local v196 = camPos() -- inferred equivalent call
					reflections(v196, v196, 0, v193 * 0.9)
					heardFight(v193 * 0.6) -- inferred equivalent call
				end

				function VoxelSound.ownSMG(p: number, value: number?, p2: string?)
					VoxelSound.casing("small")
					local v193

					if p2 then
						v193 = v166.voices[p2]
					else
						v193 = v166.base
					end

					if v193 == nil then
						error("[VoxelSound] no SMG voice for " .. tostring(p2))
					end

					v8 = math.max(v8, 0)
					local v194 = p * (value or 1)
					local v195 = draw(v193.own)
					local v196 = pitch(v193.low, v193.high) -- inferred equivalent call
					local v197 = jitter() -- inferred equivalent call

					if value then
						v166.ownQuiet(v194, value, false, 0.95 * v193.high, v193.high)
					else
						ringFire(v189, v195, v193.crack * v194 * v197, v196, "dry", 1e999, 0, nil, v193.hp) -- inferred equivalent call
					end

					if v193.crackK and not value then
						ringFire(v189, v195, v193.crackK * v194 * v197, v196, "dry", 1e999, 0, nil, v193.crackHp) -- inferred equivalent call
					end

					ringFire( -- inferred equivalent call
						v190,
						v124,
						v193.bodyK * v194 * (0.9 + 0.1 * math.random()),
						pitch(v193.bodyLow, v193.bodyHigh), -- inferred equivalent call
						"dry",
						0.25,
						0.12
					)
					ringFire( -- inferred equivalent call
						v191,
						draw(v180),
						v194 * 0.05,
						math.min(0.86 + 0.06000000000000005 * math.random(), 1),
						"dry",
						0.05,
						0.02
					)

					for _, voice in v192.voices do
						cutShort(voice, voice.serial, 0.2) -- inferred equivalent call
					end

					for _, voice in v166.tailRing.voices do
						cutShort(voice, voice.serial, 0.05) -- inferred equivalent call
					end

					local v198 = v181[ownTailClass()] -- inferred equivalent call

					ringFire( -- inferred equivalent call
						v192,
						draw(v179),
						v198.gain * 0.6 * v194,
						pitch(v198.lo, v198.hi), -- inferred equivalent call
						v198.bus,
						v198.length * 0.85,
						v198.fade
					)

					if v198.bus == "open" and not value then
						ringFire( -- inferred equivalent call
							v166.tailRing,
							draw(v193.tails),
							v194 * 1.1 * v193.tailK,
							pitch(0.95 * v193.tailPitch, v193.tailPitch), -- inferred equivalent call
							"dry",
							1e999,
							0.05,
							nil,
							v193.hp
						)
					end

					local v199 = camPos() -- inferred equivalent call
					reflections(v199, v199, 0, v194 * 0.6)
					heardFight(v194 * 0.45) -- inferred equivalent call
				end

				do
					local v193 = {
						own = bagOf({
							gslice(9114550847, 0.004, 0.18, 0.8),
							gslice(9114550686, 0.004, 0.18, 0.84),
							gslice(9114550690, 0.005, 0.18, 0.78),
							gslice(9114551334, 0.004, 0.18, 0.95),
							gslice(9114551386, 0.005, 0.18, 0.86)
						}),
						thump = gslice(9114550858, 0.004, 0.18, 0.61),
						bolt = bagOf({ gslice(9116357621, 0.105, 0.205, 1.11), gslice(9116357355, 0.102, 0.202, 1.23) }),
						tails = bagOf({
							gslice(9114550847, 0.18, 1.22, 0.8),
							gslice(9114551786, 0.18, 3, 0.36),
							gslice(9114725315, 0.2, 3, 1.06)
						}),
						mid = bagOf({
							gslice(9114551786, 0.004, 0.18, 0.76),
							gslice(9114551603, 0.004, 0.18, 0.79),
							gslice(9114551713, 0.004, 0.18, 0.7),
							gslice(9114551929, 0.004, 0.18, 0.76)
						}),
						lowRing = ring("OwnDMRLow", 2),
						tailRing = ring("OwnDMRTail", 2),
						crack = 0.62,
						thumpK = 0.35,
						boltK = 0.25,
						tailK = 1.15,
						low = 0.88,
						high = 0.95,
						remoteHp = 120
					}

					function v193.ownBolt(p: number, p2: number)
						ringFire(v191, draw(v193.bolt), v193.crack * v193.boltK * p, p2, "dry", 0.1, 0.03, 8000) -- inferred equivalent call
					end
					function VoxelSound.ownDMR(p: number, value: number?)
						VoxelSound.casing("large")
						v8 = math.max(v8, 0)
						local v194 = p * (value or 1)
						local v195 = pitch(v193.low, v193.high) -- inferred equivalent call
						local v196 = v193.crack * v194 * jitter() -- inferred equivalent call

						if value then
							v166.ownQuiet(v194, value, true, 0.86, 0.9)
						else
							ringFire(v189, draw(v193.own), v196, v195, "dry", 1e999, 0.012) -- inferred equivalent call
						end

						local lowRing = v193.lowRing
						local thump = v193.thump
						local v197 = v196 * v193.thumpK
						local voice = lowRing.voices[lowRing.next]
						lowRing.next = lowRing.next % #lowRing.voices + 1
						startVoice(voice, thump, v197, v195, "dry", 450, 1e999, 0.03, 10, 100)
						ringFire( -- inferred equivalent call
							v190,
							v124,
							v194 * 0.28 * (0.9 + 0.1 * math.random()),
							math.min(0.6 + 0.040000000000000036 * math.random(), 1),
							"dry",
							0.4,
							0.15
						)
						later(0.038 + 0.008 * math.random(), v193.ownBolt, v194, v195)

						for _, voice2 in v192.voices do
							cutShort(voice2, voice2.serial, 0.2) -- inferred equivalent call
						end

						for _, voice2 in v193.tailRing.voices do
							cutShort(voice2, voice2.serial, 0.2) -- inferred equivalent call
						end

						local v198 = v181[ownTailClass()] -- inferred equivalent call

						ringFire( -- inferred equivalent call
							v192,
							draw(v179),
							v198.gain * 0.85 * v194,
							pitch(v198.lo * 0.94, v198.hi * 0.94), -- inferred equivalent call
							v198.bus,
							v198.length * 1.1,
							v198.fade
						)

						if v198.bus == "open" and not value then
							local tailRing = v193.tailRing
							local v199 = draw(v193.tails)
							local v200 = v196 * v193.tailK
							local voice2 = tailRing.voices[tailRing.next]
							tailRing.next = tailRing.next % #tailRing.voices + 1
							startVoice(voice2, v199, v200, v195, "dry", 10000, 1e999, 0.1, 10, nil)
						end

						local v199 = camPos() -- inferred equivalent call
						reflections(v199, v199, 0, v194 * 0.95)
						heardFight(v194 * 0.6) -- inferred equivalent call
					end

					function VoxelSound.dmrNear(worldPosition: Vector3, p: number, p2: number)
						emitAt(
							draw(v193.own),
							worldPosition,
							p * v193.crack / 0.5,
							pitch(v193.low, v193.high), -- inferred equivalent call
							"dry",
							p2,
							1e999,
							0,
							p + 0.1,
							v193.remoteHp
						)
					end
					function VoxelSound.dmrMid(vector3: Vector3, p: number, p2: number)
						emitAt(draw(v193.mid), vector3, p, pitch(v193.low, v193.high), "dry", p2, 1e999, 0, p + 0.1) -- inferred equivalent call
					end

					do
						local v194 = {
							own = bagOf({
								gslice(9114716379, 1.133, 1.333, 1.71),
								gslice(9114723684, 1.388, 1.588, 1.82),
								gslice(9114723704, 1.933, 2.133, 1.84),
								gslice(9114713093, 1.693, 1.893, 1.82),
								gslice(9114707015, 1.339, 1.539, 1.75),
								gslice(9114712952, 0, 0.2, 1.9)
							}),
							bright = gslice(9114711866, 1.778, 1.978, 1.21),
							tails = bagOf({
								gslice(9114716379, 1.333, 2.25, 1.71),
								gslice(9114723684, 1.588, 2.5, 1.82),
								gslice(9114713093, 1.893, 2.8, 1.82),
								gslice(9114707015, 1.539, 2.45, 1.75),
								gslice(9114712952, 0.2, 1.1, 1.9),
								gslice(9114723704, 2.133, 3.05, 1.84)
							}),
							mid = bagOf({
								gslice(9112909382, 2.105, 2.265, 1.56),
								gslice(9112909610, 1.663, 1.823, 1.54),
								gslice(9112909820, 2.868, 3.028, 1.56),
								gslice(9112909833, 2.288, 2.448, 1.55),
								gslice(9112910050, 2.054, 2.214, 1.55),
								gslice(9112910281, 1.804, 1.964, 1.57)
							}),
							back = bagOf({
								gslice(9112913564, 0, 0.107, 2.3),
								gslice(9112913483, 0, 0.103, 2.59),
								gslice(9112911998, 0, 0.127, 3.4)
							}),
							forward = bagOf({
								gslice(9112913564, 0.153, 0.32, 2.01),
								gslice(9112913483, 0.155, 0.316, 2.16),
								gslice(9112911998, 0.427, 0.584, 2.47)
							}),
							shell = bagOf({
								gslice(9114721953, 0, 0.125, 10),
								gslice(9114721953, 0.055, 0.125, 10),
								gslice(9113104509, 0.781, 0.87, 4.77)
							}),
							latch = gslice(9113104517, 0.227, 0.29, 1),
							punch = ring("OwnShotgun", 3, true),
							layer = ring("OwnShotgunBright", 2, true),
							tailRing = ring("OwnShotgunTail", 2, true),
							mech = ring("OwnShotgunMech", 3, true),
							crack = 0.7,
							brightK = 0.5,
							tailK = 1,
							pumpK = 0.55,
							shellK = 0.6,
							low = 0.92,
							high = 0.97,
							remoteHp = 120
						}

						function VoxelSound.ownShotgun(p: number)
							v8 = math.max(v8, 0)
							local v195 = pitch(v194.low, v194.high) -- inferred equivalent call
							local v196 = v194.crack * p * jitter() -- inferred equivalent call
							ringFire(v194.punch, draw(v194.own), v196, v195, "dry", 1e999, 0.018) -- inferred equivalent call
							ringFire(v194.layer, v194.bright, v196 * v194.brightK, v195, "dry", 1e999, 0.018) -- inferred equivalent call
							ringFire( -- inferred equivalent call
								v190,
								v124,
								p * 0.34 * (0.9 + 0.1 * math.random()),
								math.min(0.52 + 0.040000000000000036 * math.random(), 1),
								"dry",
								0.45,
								0.2
							)

							for _, voice in v192.voices do
								cutShort(voice, voice.serial, 0.2) -- inferred equivalent call
							end

							for _, voice in v194.tailRing.voices do
								cutShort(voice, voice.serial, 0.2) -- inferred equivalent call
							end

							local v197 = v181[ownTailClass()] -- inferred equivalent call

							ringFire( -- inferred equivalent call
								v192,
								draw(v179),
								v197.gain * 0.95 * p,
								pitch(v197.lo * 0.92, v197.hi * 0.92), -- inferred equivalent call
								v197.bus,
								v197.length * 1.15,
								v197.fade
							)

							if v197.bus == "open" then
								ringFire(v194.tailRing, draw(v194.tails), v196 * v194.tailK, v195, "dry", 1e999, 0.1) -- inferred equivalent call
							end

							local v198 = camPos() -- inferred equivalent call
							reflections(v198, v198, 0, p * 1.05)
							heardFight(p * 0.65) -- inferred equivalent call
						end

						function VoxelSound.shotgunPump(p: string)
							local v195

							if p == "back" then
								v195 = v194.back
							elseif p == "forward" then
								v195 = v194.forward
							end

							assert(v195, "[VoxelSound] shotgunPump: unknown stroke " .. tostring(p))
							ringFire( -- inferred equivalent call
								v194.mech,
								draw(v195),
								v194.pumpK * (0.9 + 0.1 * math.random()),
								math.min(0.95 + 0.050000000000000044 * math.random(), 1),
								"dry",
								1e999,
								0.02,
								nil,
								150
							)

							if p == "back" then
								VoxelSound.casing("shotgun", 0.35)
							end
						end

						function VoxelSound.shotgunShell()
							ringFire( -- inferred equivalent call
								v194.mech,
								draw(v194.shell),
								v194.shellK * (0.9 + 0.1 * math.random()),
								math.min(0.95 + 0.050000000000000044 * math.random(), 1),
								"dry",
								1e999,
								0.02,
								9000
							)
							ringFire( -- inferred equivalent call
								v191,
								v194.latch,
								0.3 * v194.shellK,
								math.min(0.95 + 0.050000000000000044 * math.random(), 1),
								"dry",
								1e999,
								0.02,
								8000
							)
						end

						function VoxelSound.shotgunNear(worldPosition: Vector3, p: number, p2: number)
							emitAt(
								draw(v194.own),
								worldPosition,
								p * v194.crack / 0.5,
								pitch(v194.low, v194.high), -- inferred equivalent call
								"dry",
								p2,
								1e999,
								0,
								p + 0.1,
								v194.remoteHp
							)
						end
						function VoxelSound.shotgunMid(vector3: Vector3, p: number, p2: number)
							emitAt(draw(v194.mid), vector3, p, pitch(v194.low, v194.high), "dry", p2, 1e999, 0, p + 0.1) -- inferred equivalent call
						end
					end

					do
						local function slideClack(p: number)
							ringFire( -- inferred equivalent call
								v191,
								draw(v180),
								p * 0.16,
								math.min(0.86 + 0.06000000000000005 * math.random(), 1),
								"dry",
								0.06,
								0.02
							)
						end
						function VoxelSound.ownPistol(p: number)
							VoxelSound.casing("pistol")
							v8 = math.max(v8, 0)
							ringFire( -- inferred equivalent call
								v189,
								draw(v130),
								p * 0.55 * jitter(), -- inferred equivalent call
								math.min(0.95 + 0.050000000000000044 * math.random(), 1),
								"dry",
								0.07400000000000001,
								0.02
							)
							ringFire( -- inferred equivalent call
								v190,
								v124,
								p * 0.2 * (0.9 + 0.1 * math.random()),
								math.min(0.66 + 0.039999999999999925 * math.random(), 1),
								"dry",
								0.25,
								0.12
							)
							later(0.036 + 0.008 * math.random(), slideClack, p)

							for _, voice in v192.voices do
								cutShort(voice, voice.serial, 0.2) -- inferred equivalent call
							end

							local v195 = v181[ownTailClass()] -- inferred equivalent call

							ringFire( -- inferred equivalent call
								v192,
								draw(v179),
								v195.gain * 0.6 * p,
								pitch(v195.lo, v195.hi), -- inferred equivalent call
								v195.bus,
								v195.length,
								v195.fade
							)
							local v196 = camPos() -- inferred equivalent call
							reflections(v196, v196, 0, p * 0.6)
							heardFight(p * 0.4) -- inferred equivalent call
						end
					end

					v26 = {
						crack = 0.75,
						thumpK = 0.6,
						low = 0.74,
						high = 0.8,
						tailK = 0.8
					}
					local function cannonClack(p: number)
						ringFire( -- inferred equivalent call
							v191,
							draw(v180),
							p * 0.22,
							math.min(0.7 + 0.06000000000000005 * math.random(), 1),
							"dry",
							0.08,
							0.03
						)
					end
					function VoxelSound.ownHandCannon(p: number)
						VoxelSound.casing("pistol")
						v8 = math.max(v8, 0)
						local v195 = math.min(0.74 + 0.06000000000000005 * math.random(), 1)
						local v196 = 0.75 * p * jitter() -- inferred equivalent call
						ringFire(v189, draw(v130), v196, v195, "dry", 1e999, 0.03) -- inferred equivalent call
						local lowRing = v193.lowRing
						local thump = v193.thump
						local v197 = v196 * 0.6
						local voice = lowRing.voices[lowRing.next]
						lowRing.next = lowRing.next % #lowRing.voices + 1
						startVoice(voice, thump, v197, 0.85, "dry", 450, 1e999, 0.03, 10, 100)
						ringFire( -- inferred equivalent call
							v190,
							v124,
							p * 0.45 * (0.9 + 0.1 * math.random()),
							math.min(0.54 + 0.039999999999999925 * math.random(), 1),
							"dry",
							0.45,
							0.2
						)
						later(0.045 + 0.01 * math.random(), cannonClack, p)

						for _, voice2 in v192.voices do
							cutShort(voice2, voice2.serial, 0.2) -- inferred equivalent call
						end

						for _, voice2 in v193.tailRing.voices do
							cutShort(voice2, voice2.serial, 0.2) -- inferred equivalent call
						end

						local v198 = v181[ownTailClass()] -- inferred equivalent call

						ringFire( -- inferred equivalent call
							v192,
							draw(v179),
							v198.gain * 1 * p,
							pitch(v198.lo * 0.92, v198.hi * 0.92), -- inferred equivalent call
							v198.bus,
							v198.length * 1.2,
							v198.fade
						)

						if v198.bus == "open" then
							local tailRing = v193.tailRing
							local v199 = draw(v193.tails)
							local v200 = v196 * 0.8
							local voice2 = tailRing.voices[tailRing.next]
							tailRing.next = tailRing.next % #tailRing.voices + 1
							startVoice(voice2, v199, v200, v195, "dry", 9000, 1e999, 0.1, 10, nil)
						end

						local v199 = camPos() -- inferred equivalent call
						reflections(v199, v199, 0, p * 1.05)
						heardFight(p * 0.65) -- inferred equivalent call
					end
				end

				function VoxelSound.handCannonNear(vector3: Vector3, p: number, p2: number)
					emitAt(
						draw(v131),
						vector3,
						p * 1.4,
						math.min(0.74 + 0.06000000000000005 * math.random(), 1),
						"dry",
						p2,
						1e999,
						0,
						p + 0.1
					)
				end

				local v195 = ring("OwnSniperLow", 4)
				local function sniperDouble(p: number, data)
					ringFire( -- inferred equivalent call
						v189,
						draw(data.punch),
						data.doubleK * p * jitter(), -- inferred equivalent call
						pitch(data.doubleLow, data.doubleHigh), -- inferred equivalent call
						"dry",
						1e999,
						0,
						data.punchCut
					)
				end

				local function sniperBloom(p: number, data, p2: string)
					ringFire( -- inferred equivalent call
						v195,
						draw(data.boom),
						data.boomK * data.bloomK * p,
						math.min(0.85 + 0.050000000000000044 * math.random(), 1),
						p2,
						0.6,
						0.4,
						200
					)
				end
				function VoxelSound.ownSniper(p: number, value: string?, value2: number?)
					v8 = math.max(v8, 0)
					local v196 = p * (value2 or 1)
					local v197 = v133[value or "Sniper"]
					assert(v197, "[VoxelSound] no sniper voice for " .. tostring(value))

					if value2 then
						v166.ownQuiet(v196, value2, true, 0.84, 0.88)
					else
						ringFire( -- inferred equivalent call
							v189,
							draw(v197.punch),
							v197.punchK * v196 * jitter(), -- inferred equivalent call
							pitch(v197.low, v197.high), -- inferred equivalent call
							"dry",
							v197.punchLen,
							v197.punchFade,
							v197.punchCut
						)
					end

					if v197.underK and not value2 then
						ringFire( -- inferred equivalent call
							v189,
							draw(v197.near),
							v197.underK * v196 * jitter(), -- inferred equivalent call
							pitch(v197.underLow, v197.underHigh), -- inferred equivalent call
							"dry",
							1e999,
							0
						)
					end

					local v198 = v181[ownTailClass()] -- inferred equivalent call

					local v199 = v197.vast and v198.bus == "open" and "vast" or v198.bus

					if v197.boom and not value2 then
						ringFire( -- inferred equivalent call
							v195,
							draw(v197.boom),
							v197.boomK * v196 * (0.9 + 0.1 * math.random()),
							pitch(v197.boomLow, v197.boomHigh), -- inferred equivalent call
							"dry",
							v197.boomLen or 0.15,
							v197.boomFade or 0.05,
							v197.boomCut
						)

						if v197.bloomK then
							later(0.12 + 0.06 * math.random(), sniperBloom, v196, v197, v199)
						end
					end

					if v197.doubleK and not value2 then
						later(0.004 + 0.003 * math.random(), sniperDouble, v196, v197)
					end

					ringFire( -- inferred equivalent call
						v190,
						v124,
						v197.bodyK * v196 * (0.9 + 0.1 * math.random()),
						pitch(v197.bodyLow, v197.bodyHigh), -- inferred equivalent call
						"dry",
						0.466,
						0.2
					)

					for _, voice in v192.voices do
						cutShort(voice, voice.serial, 0.2) -- inferred equivalent call
					end

					ringFire( -- inferred equivalent call
						v192,
						draw(v179),
						v198.gain * v197.tailK * v196,
						pitch(v198.lo * v197.tailPitch, v198.hi * v197.tailPitch), -- inferred equivalent call
						v199,
						v198.length * v197.tailLen,
						v197.tailFade or v198.fade
					)

					if v197.sendK and not value2 then
						ringFire(v192, draw(v197.punch), v197.sendK * v196, pitch(v197.low, v197.high), v199, 0.5, 0.2) -- inferred equivalent call
					end

					local v200 = camPos() -- inferred equivalent call
					reflections(v200, v200, 0, v197.reflect * v196)
					heardFight(v197.fight * v196) -- inferred equivalent call
				end
			end

			v26 = {
				gslice(9125698566, 0.297, 2.3, 2.75),
				gslice(9125698572, 0.62, 2.6, 1.82),
				gslice(9125698551, 0.982, 2.5, 1.97)
			}

			local items = { gslice(9116973611, 0.178, 0.9, 1.9), gslice(9114363252, 0.04, 1.2, 1.27) }

			local items2 = {
				gslice(9114659666, 0.035, 0.23, 0.93),
				gslice(9116973611, 0.025, 0.6, 1.41),
				gslice(9116973611, 0.178, 0.9, 1.9)
			}

			near = {
				gslice(9114086455, 0.03, 1.4, 1.2),
				gslice(9114086583, 0.025, 1.4, 1.19),
				gslice(9114086657, 0, 1.1, 2.5),
				gslice(9114361755, 0.035, 1.2, 1.27),
				gslice(9114361755, 1.57, 3.5, 0.45),
				gslice(9114361763, 0.03, 1.2, 1.26),
				gslice(9114361763, 1.385, 3, 0.5)
			}

			local items9 = {
				gslice(9114363252, 0.04, 3.5, 1.82),
				gslice(9116973611, 0.025, 0.6, 1.41),
				gslice(9116973611, 0.178, 0.9, 1.9)
			}

			local items10 = {
				gslice(9113169432, 0.355, 0.9, 4),
				gslice(9113169432, 0.905, 1.32, 4),
				gslice(9113169432, 1.32, 1.9, 4),
				gslice(9113169429, 0.675, 1.09, 0.85),
				gslice(9113169429, 1.095, 1.28, 0.91),
				gslice(9113169429, 1.275, 2.09, 0.72),
				gslice(9113169429, 2.095, 2.36, 0.93),
				gslice(9113169429, 2.365, 3.2, 0.71)
			}

			local items11 = { gslice(9114363252, 0.04, 3.5, 1.82) }
			local items12 = { gslice(9113169432, 1.9, 6.8, 4), gslice(9113169429, 2.4, 7.7, 0.85) }
			local items13 = { gslice(9118029227, 2.1, 4.5, 4), gslice(9118029220, 0.16, 3, 3) }
			local items14 = {
				gslice(9126009936, 0, 1.8, 3.7, 0.57),
				gslice(9126009937, 0, 1.5, 2.7, 0.75),
				gslice(9126009951, 0, 1.5, 3.5, 0.43),
				gslice(9126010351, 0, 1.4, 5, 0.44)
			}

			local v204 = gslice(9118591417, 0.56, 4.1, 1.93)
			local numberRange = NumberRange.new(1.6, 4)

			local items15 = {
				gslice(9116347432, 0.522, 0.7, 1.57),
				gslice(9116347641, 1.692, 1.83, 3),
				gslice(9116347811, 0.63, 0.8, 1.66),
				gslice(9116348209, 1.073, 1.25, 0.68),
				gslice(9116348211, 0.453, 0.62, 0.76)
			}

			local items16 = {
				gslice(9116347432, 0.733, 0.95, 0.77),
				gslice(9116347612, 0.277, 0.45, 0.58),
				gslice(9116347641, 1.827, 2, 0.99),
				gslice(9116347811, 0.8, 0.98, 0.92),
				gslice(9116348209, 1.528, 1.7, 0.5),
				gslice(9116348211, 0.622, 0.8, 0.48),
				gslice(9116348217, 1.093, 1.25, 0.92),
				gslice(9117889191, 1.785, 1.95, 3.47)
			}

			local v207 = bagOf(v26)
			local v208 = bagOf(v26)
			local v209 = bagOf(near)
			local farBag = bagOf(items10)
			local v211 = bagOf(items13)
			local v212 = bagOf(items14)
			local v213 = bagOf(items15)
			local v214 = bagOf(items16)

			local v215 = { bag = bagOf(items), lo = 0.8, hi = 0.92, length = 1 }
			local bag = bagOf(items9)

			local v217 = { bag = bagOf(v26), lo = 0.8, hi = 0.9, length = 1.2 }
			local v218 = { bag = bagOf(items2), lo = 0.6, hi = 0.7, length = 1.4 }
			local v219 = { bag = bagOf(near), lo = 0.78, hi = 0.88, length = 1.4 }

			local function layer(data, vector3: Vector3, p: number, p2: number, value: number?) -- 1 equivalent call inferred from this helper
				emitAt(
					draw(data.bag),
					vector3,
					p,
					pitch(data.lo, data.hi), -- inferred equivalent call
					"dry",
					p2,
					data.length,
					0.5,
					p + 1 + (value or 0)
				)
			end

			local function placeTail(vector3: Vector3, p: number, p2: number, p3: number, p4: number)
				local v220 = shooterCell(vector3)
				local v221

				if v220 and v220.roof and v220.walls >= 3 or p2 < 15 and v13 > 0.55 then
					v221 = "room"
				elseif v220 and v220.walls >= 2 then
					v221 = "street"
				elseif p2 < 40 and v12.walls >= 4 then
					v221 = "street"
				else
					v221 = "open"
				end

				local v222 = v181[v221]
				local v223 = v221 == "room" and 1 or 1 - v13 * 0.5
				local v224 = p * v222.gain * v223
				emitAt(
					draw(v178),
					vector3,
					v224,
					pitch(v222.lo, v222.hi) * p3, -- inferred equivalent call
					v222.bus,
					airCutoff(p2 * 0.25), -- inferred equivalent call
					v222.length * p4,
					v222.fade * p4,
					v224 + 0.5
				)
			end

			local v220 = ring("OwnLaunchCrack", 2)
			local v221 = ring("OwnLaunchBoom", 2)
			local function ownBoom(p, p2: number, p3: number)
				ringFire(v221, p, p2, p3, "dry", v215.length, 0.5) -- inferred equivalent call
			end

			local function ownLaunch(vector3: Vector3, vector3_2: Vector3, magnitude: number, p: number)
				v8 = math.max(v8, 0)
				local v222 = jitter() -- inferred equivalent call
				ringFire( -- inferred equivalent call
					v220,
					draw(v207),
					v222 * 0.6,
					math.min(0.84 + 0.08000000000000007 * math.random(), 1),
					"dry",
					2.2,
					0.6
				)
				later(
					0.01 + 0.019999999999999997 * math.random(),
					ownBoom,
					draw(v215.bag),
					v222 * 1.5,
					pitch(v215.lo, v215.hi) -- inferred equivalent call
				)
				placeTail(vector3, math.min(1, 67.5 / p) * 1, p, 0.8, 1.4)
				reflections(vector3, vector3_2, magnitude, v222 * 0.6, v217)
				heardFight(1) -- inferred equivalent call
			end

			local function launchArrive(vector3: Vector3)
				local v222 = camPos() -- inferred equivalent call
				local magnitude = (vector3 - v222).Magnitude
				local v223 = math.max(magnitude / meter, 1)

				if magnitude / meter < 4 then
					ownLaunch(vector3, v222, magnitude, v223)
					return
				end

				local v224 = jitter() -- inferred equivalent call
				local v225 = smoothstep(30, 110, v223) -- inferred equivalent call
				local v226 = occluded(vector3, v222, magnitude)

				local v227 = 1
				local v228 = airCutoff(v223 / 3) -- inferred equivalent call

				if v226 then
					v227 *= 0.55
					v228 = math.min(v228, 1558.8457268119894)
				end

				if v13 > 0 and v223 > 15 then
					v227 *= 1 - v13 * 0.45
					v228 = math.max(v228 * (1 - v13 * 0.6), 700)
				end

				if v225 < 1 then
					local v229 = math.min(1, 25 / v223) * 0.32 * v224 * (1 - v225) * v227
					emitAt(
						draw(v207),
						vector3,
						v229,
						math.min(0.84 + 0.08000000000000007 * math.random(), 1),
						"dry",
						v228,
						2.2,
						0.6,
						v229 + 1 + 3
					)
				end

				if v223 < 60 then
					local v229 = math.min(1, 25 / v223) * 1.1 * v224 * v227
					later(0.01 + 0.019999999999999997 * math.random(), layer, v215, vector3, v229, v228, 3)
				end

				if v225 > 0 then
					local v229 = math.min(1, 120 / v223) * 0.8 * v224 * v225 * math.sqrt(v227)
					local v230 = math.min(v228, 4800)
					emitAt(
						draw(v208),
						vector3,
						v229,
						math.min(0.78 + 0.07999999999999996 * math.random(), 1),
						"dry",
						v230,
						2.5,
						0.8,
						v229 + 0.5 + 3
					)
					emitAt(
						draw(farBag),
						vector3,
						v229 * 0.6,
						math.min(0.9 + 0.09999999999999998 * math.random(), 1),
						"dry",
						v230,
						1.2,
						0.5,
						v229 + 0.5
					)
				end

				placeTail(vector3, math.min(1, 67.5 / v223) * 1, v223, 0.8, 1.4)

				if v223 < 180 then
					reflections(vector3, v222, magnitude, v224 * 0.6 * v227, v217)
				end

				heardFight(math.min(1, 25 / v223)) -- inferred equivalent call
			end

			local v222 = {}
			local v223 = {}
			local v224 = { 1, 1.4, 2 }
			local v225 = { 1, 0.92, 0.82 }

			local v226 = {
				{ bag = bag, lo = 0.84, hi = 0.96, length = 2.5 },
				{ bag = bag, lo = 0.76, hi = 0.88, length = 3 },
				{ bag = bag, lo = 0.66, hi = 0.78, length = 3.5 }
			}

			for i = 1, 6 do
				do
					local positional = AudioGraph.positional("Motor" .. i, voxelSoundVoices)
					positional.player.Looping = true
					v222[i] = {
						id = 0,
						active = false,
						started = false,
						own = false,
						flew = false,
						base = 1,
						used = 0,
						hearAt = 0,
						endAt = 0,
						endVolume = 0,
						fly = items14[1],
						motor = positional,
						flyby = AudioGraph.positional("Flyby" .. i, voxelSoundVoices),
						flybyUntil = 0,
						motorOn = false,
						flybyEnd = 0
					}

					AudioGraph.park(positional)
				end

				AudioGraph.park(v222[i].flyby)
			end

			do
				local function rocketStart(id: number, worldPosition: Vector3)
					local v227 = v222[1]

					for _, v229 in v222 do
						if v229.active or v229.motor.player.IsPlaying then
							if v229.used < v227.used then
								v227 = v229
							end
						else
							v227 = v229
							break
						end
					end

					if v227.active then
						v223[v227.id] = nil
					end

					v227.motor.player:Stop()
					v227.flyby.player:Stop()
					v227.motorOn = false
					AudioGraph.park(v227.motor)
					AudioGraph.park(v227.flyby)
					local now = os.clock()
					local v229 = (worldPosition - camPos()).Magnitude / meter -- inferred equivalent call
					v227.id = id
					v227.active = true
					v227.started = false
					v227.used = now
					v227.own = v229 < 4
					v227.flew = false
					v227.hearAt = now + v229 / 343
					v227.fly = draw(v212)
					v227.base = math.min(0.6 + 0.08000000000000007 * math.random(), 1)
					v227.motor.attachment.WorldPosition = worldPosition
					v227.flyby.attachment.WorldPosition = worldPosition
					v223[id] = v227
				end

				do
					local function startMotor(state) -- 1 equivalent call inferred from this helper
						local player = state.motor.player
						player.Asset = v204.id
						player.PlaybackRegion = v204.range
						player.LoopRegion = numberRange
						player.PlaybackSpeed = state.base
						player.Volume = 0
						local timePosition

						if state.own then
							timePosition = numberRange.Min
						else
							timePosition = v204.from
						end

						player.TimePosition = timePosition
						AudioGraph.route(state.motor, "dry")
						player:Play()
						state.motorOn = true
					end
				end

				function VoxelSound.launch(worldPosition: Vector3, id: number?)
					later((worldPosition - camPos()).Magnitude / meter / 343, launchArrive, worldPosition) -- inferred equivalent call

					if id then
						rocketStart(id, worldPosition)
					end
				end
			end

			function VoxelSound.rocketMove(p: number, worldPosition: Vector3, vector: Vector3)
				local v227 = v223[p]

				if not v227 then
					return
				end

				v227.motor.attachment.WorldPosition = worldPosition
				v227.flyby.attachment.WorldPosition = worldPosition

				if not v227.started then
					if os.clock() < v227.hearAt then
						return
					end

					v227.started = true
					startMotor(v227) -- inferred equivalent call
				end

				local v228 = camPos() -- inferred equivalent call
				local vector2 = worldPosition - v228
				local magnitude = vector2.Magnitude
				local v229 = math.max(magnitude / meter, 1)
				local v230 = occluded(worldPosition, v228, magnitude)

				local v231 = 1
				local v232 = airCutoff(v229 / 3) -- inferred equivalent call

				if v230 then
					v231 *= 0.55
					v232 = math.min(v232, 1558.8457268119894)
				end

				if v13 > 0 and v229 > 15 then
					v231 *= 1 - v13 * 0.45
					v232 = math.max(v232 * (1 - v13 * 0.6), 700)
				end

				local player = v227.motor.player
				player.Volume = v204.gain * 0.7 * math.min(1, 20 / v229) * v231 * (v227.own and 0.35 or 1)
				AudioGraph.lowpass(v227.motor, (math.min(v232, 2200)))
				local v233 = (343 / math.max(
					343 + (not (magnitude > 0.01) and 0 or vector:Dot(vector2) / magnitude / meter),
					60
				)) ^ 0.5
				player.PlaybackSpeed = math.min(v227.base * v233, 1)
				local now = os.clock()

				if now < v227.flybyUntil then
					AudioGraph.lowpass(v227.flyby, v232)
				elseif not (v227.flew or v227.own) then
					local dot = vector:Dot(vector)

					if dot > 1 then
						local v234 = -vector2:Dot(vector) / dot
						local v235 = (vector2 + vector * v234).Magnitude / meter
						local fly = v227.fly
						local peak = fly.peak or 0.5

						if v235 < 10 and v234 >= 0 and v234 <= peak then
							v227.flew = true
							local v236 = 0.9 * (1 - 0.7 * v235 / 10) * v231
							local player2 = v227.flyby.player
							player2.Asset = fly.id
							player2.PlaybackRegion = fly.range
							local playbackSpeed = math.min(0.9 + 0.09999999999999998 * math.random(), 1)

							player2.PlaybackSpeed = playbackSpeed
							player2.Volume = v236 * (fly.gain or 1)
							player2.TimePosition = fly.from + (peak - v234)
							AudioGraph.lowpass(v227.flyby, v232)
							AudioGraph.route(v227.flyby, "dry")
							player2:Play()
							v227.flybyUntil = now + (fly.to - fly.from)
							v227.flybyEnd = now + (fly.to - fly.from - (peak - v234)) / playbackSpeed
						end
					end
				end
			end

			function VoxelSound.rocketEnd(p: number)
				local v227 = v223[p]

				if not v227 then
					return
				end

				v223[p] = nil
				v227.active = false
				v227.endAt = os.clock()
				v227.endVolume = v227.motor.player.Volume
			end

			local function rocketStep(now: number)
				for _, v227 in v222 do
					if not v227.active and v227.motorOn then
						local player = v227.motor.player
						local v228 = 1 - (now - v227.endAt) / 0.12

						if v228 <= 0 then
							player:Stop()
							v227.motorOn = false
							AudioGraph.park(v227.motor)
						else
							player.Volume = v227.endVolume * v228
						end
					end

					if v227.flybyEnd + 0.5 <= now and AudioGraph.awake(v227.flyby) then
						AudioGraph.park(v227.flyby)
					end
				end
			end

			local v227 = gslice(9113201103, 20, 24, 8.5)
			local v228 = bagOf({
				gslice(9113066850, 0.6, 8.4, 3.7, 2.84),
				gslice(9113066731, 2.5, 9.5, 2.91, 2.86),
				gslice(9113066854, 0.4, 7.2, 2.57, 3.46),
				gslice(9113067229, 0.2, 7.2, 4.18, 4.7)
			})

			local v229 = gslice(9113064746, 1.85, 3.6, 3.74, 0.82)

			local v230 = {}

			do
				local v231 = {}

				for i = 1, 2 do
					do
						local positional = AudioGraph.positional("JetRoar" .. i, voxelSoundVoices)
						positional.player.Looping = true
						v230[i] = {
							id = 0,
							active = false,
							used = 0,
							last = 0,
							level = 0,
							duck = 1,
							passed = false,
							ripped = false,
							passUntil = 0,
							cut = v228.items[1],
							endAt = 0,
							endVolume = 0,
							roar = positional,
							pass = AudioGraph.positional("JetPass" .. i, voxelSoundVoices),
							rip = AudioGraph.positional("JetRip" .. i, voxelSoundVoices),
							roarOn = false,
							passEnd = 0,
							ripEnd = 0
						}

						AudioGraph.park(positional)
					end

					AudioGraph.park(v230[i].pass)
					AudioGraph.park(v230[i].rip)
				end

				do
					local function jetStart(id: number)
						local v232 = v230[1]

						for _, v234 in v230 do
							if v234.active or v234.roar.player.IsPlaying then
								if v234.used < v232.used then
									v232 = v234
								end
							else
								v232 = v234
								break
							end
						end

						if v232.active then
							v231[v232.id] = nil
						end

						v232.pass.player:Stop()
						v232.rip.player:Stop()
						AudioGraph.park(v232.pass)
						AudioGraph.park(v232.rip)
						local now = os.clock()
						v232.id = id
						v232.active = true
						v232.used = now
						v232.last = now
						v232.level = 0
						v232.duck = 1
						v232.passed = false
						v232.ripped = false
						v232.passUntil = 0
						v232.cut = draw(v228)
						local player = v232.roar.player
						player:Stop()
						player.Asset = v227.id
						player.PlaybackRegion = v227.range
						player.LoopRegion = v227.range
						player.PlaybackSpeed = 0.95
						player.Volume = 0
						player.TimePosition = v227.from + math.random() * (v227.to - v227.from)
						AudioGraph.route(v232.roar, "dry")
						player:Play()
						v232.roarOn = true
						v231[id] = v232
						return v232
					end

					local function oneShot(p, data, p2: number, p3: number, playbackSpeed: number, p4: number)
						local player = p.player
						player.Asset = data.id
						player.PlaybackRegion = data.range
						player.PlaybackSpeed = playbackSpeed
						player.Volume = p3 * (data.gain or 1)
						player.TimePosition = data.from + math.max(p2, 0)
						AudioGraph.lowpass(p, p4)
						AudioGraph.route(p, "dry")
						player:Play()
						return os.clock() + (data.to - data.from - math.max(p2, 0)) / playbackSpeed
					end

					function VoxelSound.jet(id: number, worldPosition: Vector3, vector: Vector3)
						local v232 = v231[id] or jetStart(id)
						local now = os.clock()
						local v233 = math.min(now - v232.last, 0.1)
						v232.last = now
						v232.roar.attachment.WorldPosition = worldPosition
						v232.pass.attachment.WorldPosition = worldPosition
						v232.rip.attachment.WorldPosition = worldPosition
						local v234 = camPos() -- inferred equivalent call
						local vector2 = worldPosition - v234
						local magnitude = vector2.Magnitude
						local v235 = math.max(magnitude / meter, 1)
						local v236 = occluded(worldPosition, v234, magnitude)

						local v237 = 1
						local v238 = airCutoff(v235 / 1) -- inferred equivalent call

						if v236 then
							v237 *= 0.55
							v238 = math.min(v238, 900)
						end

						if v13 > 0 and v235 > 15 then
							v237 *= 1 - v13 * 0.45
							v238 = math.max(v238 * (1 - v13 * 0.6), 700)
						end

						local v239 = math.min(v238, 7000)

						local dot = vector:Dot(vector)

						if dot > 1 and not (v232.passed and v232.ripped) then
							local v240 = -vector2:Dot(vector) / dot
							local v241 = math.max((vector2 + vector * math.max(v240, 0)).Magnitude / meter, 1)
							local v242 = v240 + (v241 - v235) / 343
							local cut2 = v232.cut
							local peak = cut2.peak or 2

							if not v232.passed and v241 < 700 and v242 <= peak and v242 > -0.5 then
								v232.passed = true
								v232.passEnd = oneShot(
									v232.pass,
									cut2,
									peak - v242,
									math.min(1, 70 / v241) * 0.9 * v237,
									math.min(0.95 + 0.050000000000000044 * math.random(), 1),
									v239
								)
								v232.passUntil = now + (cut2.to - cut2.from) - (peak - v242)
							end

							local peak2 = v229.peak or 0.8
							local v243 = v242 - 0.1

							if not v232.ripped and v241 < 160 and v243 <= peak2 and v243 > -0.3 then
								v232.ripped = true
								v232.ripEnd = oneShot(
									v232.rip,
									v229,
									peak2 - v243,
									math.min(1, 70 / v241) * 0.7 * v237,
									math.min(0.92 + 0.07999999999999996 * math.random(), 1),
									v239
								)
							end
						end

						if v232.pass.player.IsPlaying then
							AudioGraph.lowpass(v232.pass, v239)
						end

						v232.level = math.min(1, v232.level + v233 / 1.2)
						local v240 = now < v232.passUntil - 1.5 and 0.2 or 1
						v232.duck += (v240 - v232.duck) * math.min(1, v233 * 2.5)
						local player = v232.roar.player

						player.Volume = v227.gain * 0.55 * math.min(1, (120 / v235) ^ 0.7) * v237 * v232.level * v232.duck
						AudioGraph.lowpass(v232.roar, v239)
						player.PlaybackSpeed = math.min(
							(343 / math.max(
								343 + (not (magnitude > 0.01) and 0 or vector:Dot(vector2) / magnitude / meter),
								60
							)) ^ 0.25 * 0.95,
							1
						)
					end
				end

				function VoxelSound.jetEnd(p: number)
					local v232 = v231[p]

					if not v232 then
						return
					end

					v231[p] = nil
					v232.active = false
					v232.endAt = os.clock()
					v232.endVolume = v232.roar.player.Volume
				end
			end

			local function jetStep(now: number)
				for _, v232 in v230 do
					if not v232.active and v232.roarOn then
						local player = v232.roar.player
						local v233 = 1 - (now - v232.endAt) / 1.5

						if v233 <= 0 then
							player:Stop()
							v232.roarOn = false
							AudioGraph.park(v232.roar)
						else
							player.Volume = v232.endVolume * v233
						end
					end

					if v232.passEnd + 0.5 <= now and AudioGraph.awake(v232.pass) then
						AudioGraph.park(v232.pass)
					end

					if v232.ripEnd + 0.5 <= now and AudioGraph.awake(v232.rip) then
						AudioGraph.park(v232.rip)
					end
				end
			end

			do
				local function mgCut(p: number, from: number, to: number, gain: number)
					return {
						id = "rbxassetid://" .. p,
						from = from,
						to = to,
						range = NumberRange.new(from, to),
						gain = gain
					}
				end

				local v232 = mgCut(9116924175, 0, 4.259, 1)
				local numberRange2 = NumberRange.new(2.0041, 4.259)
				local v233 = mgCut(9116238916, 1.5, 5, 1)
				local v234 = mgCut(9116238923, 0.62, 1.15, 0.8)
				local v235 = mgCut(9116985195, 1, 2, 0.56)

				local v236 = { 0.45, 1 }

				local function loopVoice(p, p2, loopRegion: NumberRange)
					local player = p.player
					player.Asset = p2.id
					player.Looping = true
					player.PlaybackRegion = p2.range
					player.LoopRegion = loopRegion
					player.Volume = 0
					AudioGraph.park(p)
					return p
				end

				local function shotVoice(p, p2)
					local player = p.player
					player.Asset = p2.id
					player.PlaybackRegion = p2.range
					player.Volume = 0
					AudioGraph.park(p)
					return p
				end

				do
					local function startLoop(p, timePosition: number, p2: number) -- 2 equivalent calls inferred from this helper
						local player = p.player
						player:Stop()
						player.PlaybackSpeed = math.min(p2, 1)
						player.TimePosition = timePosition
						AudioGraph.route(p, "dry")
						player:Play()
					end
				end

				do
					local function stopLoop(p) -- 10 equivalent calls inferred from this helper
						p.player:Stop()
						AudioGraph.park(p)
					end
				end

				local function fire1(p, data, p2: number)
					local player = p.player
					player:Stop()
					player.PlaybackSpeed = 1
					player.Volume = p2 * data.gain
					player.TimePosition = data.from
					AudioGraph.route(p, "dry")
					player:Play()
					return os.clock() + (data.to - data.from)
				end

				local function humSet(p, spin: number, p2: number)
					local player = p.player

					if spin > 0.01 and p2 > 0.001 then
						if not player.IsPlaying then
							startLoop(p, v233.from + math.random() * (v233.to - v233.from - 0.2), v236[1]) -- inferred equivalent call
						end

						player.PlaybackSpeed = math.min(v236[1] + (v236[2] - v236[1]) * spin, 1)
						player.Volume = p2 * spin * spin
					elseif AudioGraph.awake(p) then
						stopLoop(p) -- inferred equivalent call
					end
				end

				local v237 = loopVoice(AudioGraph.flat("MgBuzz"), v232, numberRange2)
				local v238 = loopVoice(AudioGraph.flat("MgGrowl"), v232, numberRange2)
				AudioGraph.lowpass(v238, 450)

				local v239 = loopVoice(AudioGraph.flat("MgHum", false, nil, true), v233, v233.range)
				local v240 = shotVoice(AudioGraph.flat("MgUp", false, nil, true), v234)
				local v241 = shotVoice(AudioGraph.flat("MgDown", false, nil, true), v235)
				local v242 = {
					last = 0,
					spin = 0,
					firing = false,
					fade = 0,
					upArmed = true,
					downArmed = false,
					upEnd = 0,
					downEnd = 0,
					heavy = false
				}

				function VoxelSound.minigunOwn(spin: number, firing: boolean, flag: boolean?)
					local now = os.clock()
					local v243 = math.min(now - v242.last, 0.1)
					v242.last = now

					if spin > 0 or firing then
						v242.heavy = flag == true
					end

					local heavy = v242.heavy
					humSet(v239, spin, (heavy and 0.12 or 0.45) * v233.gain)

					if v242.spin < spin and v242.spin < 0.1 and v242.upArmed then
						v242.upArmed = false

						if not heavy then
							v242.upEnd = fire1(v240, v234, 0.7)
						end
					elseif spin <= 0.02 then
						v242.upArmed = true
					end

					if spin < v242.spin and v242.spin > 0.7 and v242.downArmed then
						v242.downArmed = false
						stopLoop(v240) -- inferred equivalent call
						v242.downEnd = fire1(v241, v235, 0.8)
					elseif spin >= 0.9 then
						v242.downArmed = true
					end

					v242.spin = spin

					if firing then
						if not v242.firing then
							local v244 = v237
							local from = v232.from
							local player = v244.player
							player:Stop()
							player.PlaybackSpeed = math.min(heavy and 0.75 or 0.78, 1)
							player.TimePosition = from
							AudioGraph.route(v244, "dry")
							player:Play()

							local v245 = v238
							local min = numberRange2.Min
							local player2 = v245.player
							player2:Stop()
							player2.PlaybackSpeed = math.min(heavy and 0.44 or 0.5, 1)
							player2.TimePosition = min
							AudioGraph.route(v245, "dry")
							player2:Play()
						end

						v242.fade = 1
						v8 = math.max(v8, 0)
					elseif v242.fade > 0 then
						v242.fade = math.max(0, v242.fade - v243 / 0.05)

						if v242.fade <= 0 then
							stopLoop(v237) -- inferred equivalent call
							stopLoop(v238) -- inferred equivalent call
						end
					end

					v242.firing = firing

					if v242.fade > 0 then
						v237.player.Volume = (heavy and 1.2 or 1.3) * v232.gain * v242.fade
						v238.player.Volume = (heavy and 2.4 or 1.6) * v232.gain * v242.fade
					end
				end

				local v243 = {}
				local v244 = {}

				for i = 1, 3 do
					v243[i] = {
						key = nil,
						active = false,
						used = 0,
						startAt = 0,
						untilAt = 0,
						playing = false,
						fade = 0,
						level = 0,
						pos = Vector3.new(0, 0, 0),
						lastWhiz = 0,
						lastFight = 0,
						downEnd = 0,
						buzz = loopVoice(AudioGraph.positional("MgBuzz" .. i, voxelSoundVoices), v232, numberRange2),
						growl = loopVoice(AudioGraph.positional("MgGrowl" .. i, voxelSoundVoices), v232, numberRange2),
						hum = loopVoice(AudioGraph.positional("MgHum" .. i, voxelSoundVoices), v233, v233.range),
						down = shotVoice(AudioGraph.positional("MgDown" .. i, voxelSoundVoices), v235)
					}
				end

				do
					local function stopGun(state) -- 2 equivalent calls inferred from this helper
						stopLoop(state.buzz) -- inferred equivalent call
						stopLoop(state.growl) -- inferred equivalent call
						stopLoop(state.hum) -- inferred equivalent call
						state.playing = false
						state.fade = 0
					end
				end

				function VoxelSound.minigunShot(p, pos: Vector3, vector3: Vector3)
					local now = os.clock()
					local v245 = camPos() -- inferred equivalent call
					local v246 = math.max((pos - v245).Magnitude / meter, 1) / 343
					local v247 = v244[p]

					if not v247 then
						v247 = v243[1]

						for _, v249 in v243 do
							if v249.active or v249.playing then
								if v249.used < v247.used then
									v247 = v249
								end
							else
								v247 = v249
								break
							end
						end

						if v247.active then
							v244[v247.key] = nil
						end

						stopGun(v247) -- inferred equivalent call
						v247.key = p
						v247.active = true
						v247.used = now
						v247.startAt = now + v246
						v247.lastWhiz = 0
						v247.lastFight = 0
						v244[p] = v247
					end

					v247.pos = pos
					v247.untilAt = now + v246 + 0.15

					if now - v247.lastWhiz >= 0.09 then
						v247.lastWhiz = now
						bulletPass(pos, vector3, v245, "LMG")
					end
				end

				function VoxelSound.minigunStep(lastFight: number, value: number?)
					if lastFight - v242.last > 0.2 and (v242.fade > 0 or v242.spin > 0 or AudioGraph.awake(v239)) then
						VoxelSound.minigunOwn(0, false)
						v242.last = lastFight - 0.25

						if v242.fade > 0 then
							v242.fade = 0
							stopLoop(v237) -- inferred equivalent call
							stopLoop(v238) -- inferred equivalent call
						end

						stopLoop(v239) -- inferred equivalent call
						v242.spin = 0
					end

					if v242.upEnd + 0.5 <= lastFight and AudioGraph.awake(v240) then
						AudioGraph.park(v240)
					end

					if v242.downEnd + 0.5 <= lastFight and AudioGraph.awake(v241) then
						AudioGraph.park(v241)
					end

					local v245 = camPos() -- inferred equivalent call

					for _, v246 in v243 do
						if v246.downEnd + 0.5 <= lastFight and AudioGraph.awake(v246.down) then
							AudioGraph.park(v246.down)
						end

						if not (v246.active or v246.playing) then
							continue
						end

						v246.buzz.attachment.WorldPosition = v246.pos
						v246.growl.attachment.WorldPosition = v246.pos
						v246.hum.attachment.WorldPosition = v246.pos
						v246.down.attachment.WorldPosition = v246.pos
						local magnitude = (v246.pos - v245).Magnitude
						local v247 = math.max(magnitude / meter, 1)
						local v248 = occluded(v246.pos, v245, magnitude)
						local v249 = 1
						local v250 = airCutoff(v247 / 1) -- inferred equivalent call

						if v248 then
							v249 *= 0.55
							v250 = math.min(v250, 900)
						end

						if v13 > 0 and v247 > 15 then
							v249 *= 1 - v13 * 0.45
							v250 = math.max(v250 * (1 - v13 * 0.6), 700)
						end

						local level = gunLevel(v247) * v249 -- inferred equivalent call

						v246.level = level

						if v246.active and v246.untilAt <= lastFight then
							v246.active = false
							v244[v246.key] = nil

							if v246.playing then
								v246.fade = 1
								v246.downEnd = fire1(v246.down, v235, level * 0.8)
								AudioGraph.lowpass(v246.down, (math.min(v250, 12000)))
							end
						end

						if v246.active and not v246.playing and v246.startAt <= lastFight then
							v246.playing = true
							v246.fade = 1
							local buzz = v246.buzz
							local from = v232.from
							local player = buzz.player
							player:Stop()
							player.PlaybackSpeed = 0.78
							player.TimePosition = from
							AudioGraph.route(buzz, "dry")
							player:Play()

							local growl = v246.growl
							local min = numberRange2.Min
							local player2 = growl.player
							player2:Stop()
							player2.PlaybackSpeed = 0.5
							player2.TimePosition = min
							AudioGraph.route(growl, "dry")
							player2:Play()

							startLoop(v246.hum, v233.from + math.random() * 3, v236[2]) -- inferred equivalent call
						end

						if not v246.playing then
							continue
						end

						if not v246.active then
							v246.fade -= (value or 1 / 60) / 0.05

							if v246.fade <= 0 then
								stopGun(v246) -- inferred equivalent call
							end
						end

						if not v246.playing then
							continue
						end

						v246.buzz.player.Volume = v232.gain * 1.3 * level * v246.fade
						v246.growl.player.Volume = v232.gain * 1.6 * level * v246.fade
						v246.hum.player.Volume = v233.gain * 0.35 * level * v246.fade
						AudioGraph.lowpass(v246.buzz, (math.min(v250, 12000)))
						AudioGraph.lowpass(v246.growl, (math.min(v250, 450)))
						AudioGraph.lowpass(v246.hum, (math.min(v250, 12000)))

						if not (v246.active and lastFight - v246.lastFight >= 0.25) then
							continue
						end

						v246.lastFight = lastFight
						heardFight(level) -- inferred equivalent call
					end
				end
			end

			do
				local v245 = {
					bag = bagOf(items11),
					lo = 0.57,
					hi = 0.67,
					length = 3.5,
					fade = 1.5,
					share = 0.5,
					cap = 700
				}
				local v246 = {
					bag = bagOf(items12),
					lo = 0.88,
					hi = 0.96,
					length = 4,
					fade = 1.5,
					share = 0.8,
					cap = 20000
				}
				local v247 = {
					bag = bagOf(items11),
					lo = 0.54,
					hi = 0.56,
					length = 3,
					fade = 1.2,
					share = 0.35,
					cap = 500
				}
				local function farLayer(data, vector3: Vector3, p: number, p2: number, p3: number)
					emitAt(
						draw(data.bag),
						vector3,
						p,
						p3 * pitch(data.lo, data.hi), -- inferred equivalent call
						"dry",
						math.min(p2 * data.share, data.cap),
						data.length,
						data.fade,
						p + 1
					)
				end

				local function debris(vector3: Vector3, p: number, p2: number)
					emitAt(
						draw(v211),
						vector3,
						p,
						math.min(0.85 + 0.15000000000000002 * math.random(), 1),
						"dry",
						p2,
						2,
						0.8,
						p
					)
				end

				local v248 = bagOf({
					gslice(9125739054, 0.8, 3.6, 1),
					gslice(9125739353, 0.95, 3.9, 2.5),
					gslice(9125739383, 1.8, 4.8, 1.8)
				})

				local v249 = 0
				local function birdsScatter(vector3: Vector3)
					local now = os.clock()

					if now < v249 then
						return
					end

					v249 = now + 25 + 20 * math.random()

					local v250 = math.random() * 3.141592653589793 * 2
					local v251 = vector3 + Vector3.new(math.cos(v250), 0, (math.sin(v250))) * (30 + 30 * math.random()) * meter + Vector3.new(0, 8 * meter, 0)

					local v252 = math.max((v251 - camPos()).Magnitude / meter, 1) -- inferred equivalent call
					local v253 = math.min(1, 25 / v252) * 0.12
					emitAt(
						draw(v248),
						v251,
						v253,
						math.min(0.9 + 0.09999999999999998 * math.random(), 1),
						"dry",
						airCutoff(v252), -- inferred equivalent call
						3,
						1,
						0.05
					)
				end

				local function blastArrive(vector3: Vector3, p: number)
					local v250 = p >= 2 and 3 or p >= 1 and 2 or 1
					local v251 = v224[v250]
					local v252 = v225[v250]
					local v253 = camPos() -- inferred equivalent call
					local magnitude = (vector3 - v253).Magnitude
					local v254 = math.max(magnitude / meter, 1)
					local v255 = jitter() -- inferred equivalent call
					local v256 = smoothstep(40, 160, v254) -- inferred equivalent call
					local v257 = occluded(vector3, v253, magnitude)

					local v258 = 1
					local v259 = airCutoff(v254 / 3) -- inferred equivalent call

					if v257 then
						v258 *= 0.55
						v259 = math.min(v259, 1558.8457268119894)
					end

					if v13 > 0 and v254 > 15 then
						v258 *= 1 - v13 * 0.45
						v259 = math.max(v259 * (1 - v13 * 0.6), 700)
					end

					local v260 = v251 * math.min(1, 30 / v254) * v255 * v258

					if v256 < 1 then
						local v261 = v260 * (1 - v256)
						emitAt(
							draw(v209),
							vector3,
							v261,
							v252 * math.min(0.9 + 0.09999999999999998 * math.random(), 1),
							"dry",
							v259,
							2.5,
							0.8,
							v261 + 2
						)
					end

					if v254 < 90 then
						later(0.03 + 0.04000000000000001 * math.random(), layer, v226[v250], vector3, 0.9 * v260, v259)
					end

					if v250 >= 2 and v254 < 35 then
						layer(v218, vector3, 0.9 * v260 * (1 - v254 / 35), v259) -- inferred equivalent call
					end

					local v261 = 0.75 * v251 * math.min(1, 200 / v254) * v255 * math.max(v256, 0.2) * math.sqrt(v258)
					local v262

					if v254 > 160 then
						v262 = math.min(v259, 160 / v254 * 3000 + 1300)
					else
						v262 = v259
					end

					local v263 = v252 * math.min(0.9 + 0.09999999999999998 * math.random(), 1)

					emitAt(draw(farBag), vector3, v261 * 0.25, v263, "dry", v262, 2, 0.3, v261 + 1)
					later(0.02 + 0.04 * math.random(), farLayer, v245, vector3, v261 * 0.6, v262, v252)
					later(0.12 + 0.13 * math.random(), farLayer, v246, vector3, v261 * 1, v262, v252)

					if v254 > 80 then
						for i = 1, v254 > 160 and 2 or 1 do
							later(
								0.15 + 0.35 * math.random() + (i - 1) * 0.4,
								farLayer,
								v247,
								vector3,
								v261 * 0.6 * 0.7 * 0.7 ^ (i - 1),
								v262,
								v252
							)
						end
					end

					placeTail(vector3, 0.9 * v251 * math.min(1, 90 / v254), v254, 0.7 * v252, 1.8)

					if v254 < 50 then
						local v264 = v70[v250]

						if v264 then
							VoxelSound.play(v264, vector3, v251 * 0.5)
						end

						if v250 >= 2 then
							VoxelSound.play(v69, vector3, v251 * 0.4, nil, {
								delay = 0.35 + 0.4 * math.random()
							})
							later(
								0.3 + 0.4 * math.random(),
								debris,
								vector3,
								0.35 * v251 * math.min(1, 15 / v254) * v258,
								v259
							)
						end
					end

					if v254 < 180 then
						reflections(vector3, v253, magnitude, 2 * v251 * v255 * v258, v219)
					end

					if v250 >= 2 and v254 < 150 then
						birdsScatter(vector3)
					end

					heardFight(v260) -- inferred equivalent call
				end

				local v250 = { bag = bag, lo = 0.92, hi = 1, length = 0.2 }

				local function fragArrive(vector3: Vector3)
					local v251 = camPos() -- inferred equivalent call
					local magnitude = (vector3 - v251).Magnitude
					local v252 = math.max(magnitude / meter, 1)
					local v253 = jitter() -- inferred equivalent call
					local v254 = smoothstep(40, 160, v252) -- inferred equivalent call
					local v255 = occluded(vector3, v251, magnitude)

					local v256 = 1
					local v257 = airCutoff(v252 / 3) -- inferred equivalent call

					if v255 then
						v256 *= 0.55
						v257 = math.min(v257, 1558.8457268119894)
					end

					if v13 > 0 and v252 > 15 then
						v256 *= 1 - v13 * 0.45
						v257 = math.max(v257 * (1 - v13 * 0.6), 700)
					end

					local v258 = math.min(1, 30 / v252) * 1.25 * v253 * v256

					if v254 < 1 then
						local v259 = v258 * (1 - v254)
						emitAt(
							draw(v209),
							vector3,
							v259,
							math.min(0.94 + 0.06000000000000005 * math.random(), 1),
							"dry",
							v257,
							1.4,
							0.5,
							v259 + 2
						)
					end

					if v252 < 90 then
						later(0.03 + 0.020000000000000004 * math.random(), layer, v250, vector3, v258 * 0.7, v257)
					end

					local v259 = math.min(1, 200 / v252) * 0.44999999999999996 * v253 * math.max(v254, 0.2) * math.sqrt(v256)
					local v260

					if v252 > 160 then
						v260 = math.min(v257, 160 / v252 * 3000 + 1300)
					else
						v260 = v257
					end

					emitAt(
						draw(farBag),
						vector3,
						v259 * 0.25,
						math.min(0.95 + 0.050000000000000044 * math.random(), 1),
						"dry",
						v260,
						1.5,
						0.3,
						v259 + 1
					)
					later(0.1 + 0.1 * math.random(), farLayer, v246, vector3, v259 * 1 * 0.7, v260, 1)

					if v252 > 80 then
						later(0.15 + 0.35 * math.random(), farLayer, v247, vector3, v259 * 0.6 * 0.7 * 0.6, v260, 1)
					end

					placeTail(vector3, math.min(1, 90 / v252) * 0.54, v252, 0.85, 1)

					if v252 < 30 then
						later(0.25 + 0.3 * math.random(), debris, vector3, math.min(1, 10 / v252) * 0.25 * v256, v257)
					end

					if v252 < 180 then
						reflections(vector3, v251, magnitude, v253 * 1.4 * v256, v219)
					end

					if v252 < 80 then
						birdsScatter(vector3)
					end

					heardFight(v258) -- inferred equivalent call
				end

				local v251 = bagOf({ gslice(9113169259, 0.85, 9, 0.85), gslice(9113169264, 0.5, 6.3, 0.94) })

				local v252 = { fullGap = 0.12, boomGap = 0.18, full = -1e999, boom = -1e999 }
				local function airArrive(vector3: Vector3, p: number)
					local now = os.clock()
					local v253 = camPos() -- inferred equivalent call
					local magnitude = (vector3 - v253).Magnitude
					local v254 = math.max(magnitude / meter, 1)
					local v255 = occluded(vector3, v253, magnitude)

					local v256 = 1
					local v257 = airCutoff(v254 / 3) -- inferred equivalent call

					if v255 then
						v256 *= 0.55
						v257 = math.min(v257, 1558.8457268119894)
					end

					if v13 > 0 and v254 > 15 then
						v256 *= 1 - v13 * 0.45
						v257 = math.max(v257 * (1 - v13 * 0.6), 700)
					end

					if now - v252.full >= v252.fullGap then
						v252.full = now
						blastArrive(vector3, p)
					else
						local v258 = math.min(1, 30 / v254) * 2 * jitter() * v256 -- inferred equivalent call
						emitAt(
							draw(v209),
							vector3,
							v258,
							math.min(0.9 + 0.09999999999999998 * math.random(), 1) * 0.82,
							"dry",
							v257,
							2,
							0.6,
							v258 + 1
						)
					end

					if now - v252.boom < v252.boomGap then
						return
					end

					v252.boom = now
					local v258 = math.min(1, 70 / v254) * 1.6 * math.max(v256, 0.5) * jitter() -- inferred equivalent call
					emitAt(
						draw(v251),
						vector3,
						v258,
						math.min(0.86 + 0.09999999999999998 * math.random(), 1),
						"dry",
						v257,
						8,
						2,
						v258 + 2
					)
				end

				local LightHit = require(script.LightHit)
				local v253 = LightHit.make({
					bagOf = bagOf,
					gslice = gslice,
					camPos = camPos,
					METER = meter,
					jitter = jitter,
					smoothstep = smoothstep,
					farFrom = 40,
					farTo = 160,
					pathTo = pathTo,
					emitAt = emitAt,
					draw = draw,
					pitch = pitch,
					later = later,
					layer = layer,
					farBag = farBag,
					placeTail = placeTail,
					heardFight = heardFight
				})

				function VoxelSound.explosion(p: number, vector3: Vector3, p2: string?)
					local v254 = (vector3 - camPos()).Magnitude / meter -- inferred equivalent call

					if p2 == "Grenade" then
						later(v254 / 343, fragArrive, vector3)
					elseif p2 == "Airstrike" then
						later(v254 / 343, airArrive, vector3, p)
					elseif p2 == "HeavyGun" then
						later(v254 / 343, v253, vector3)
					else
						later(v254 / 343, blastArrive, vector3, p)
					end
				end
			end

			do
				local v254 = {
					STRIKE = bagOf({ gslice(9120930142, 4.626, 4.95, 1.61), gslice(9120930385, 8.56, 8.9, 1.63) }),
					FLARE = bagOf({ gslice(9121005779, 0.038, 0.64, 1.93) }),
					SHATTER = bagOf({
						gslice(9113552215, 0.339, 1.603, 0.95),
						gslice(9113553645, 0.26, 1.671, 0.53),
						gslice(9113552246, 0.372, 1.747, 0.62),
						gslice(9113552830, 0.695, 1.227, 0.57)
					}),
					SMASH = bagOf({
						gslice(9113553822, 0.428, 1, 0.74),
						gslice(9113552487, 1.447, 2.225, 0.99),
						gslice(9113552626, 0.721, 1.07, 0.57)
					}),
					POOF = bagOf({ gslice(9125616715, 0.009, 1.019, 0.81), gslice(9125616655, 0, 0.754, 1.1) }),
					WHOOSH = bagOf({ gslice(9114444008, 0.57, 0.963, 0.55), gslice(9114446852, 0.049, 0.619, 1.24) }),
					ECHO = {
						bag = bagOf({ gslice(9113553822, 0.428, 1, 0.74) }),
						lo = 0.8,
						hi = 0.9,
						length = 0.6
					},
					ring = ring("MolotovLight", 2),
					STRIKE_GAIN = 0.4,
					FLARE_GAIN = 0.27,
					FLARE_LAG = 0.05,
					SMASH_GAIN = 1.6,
					SHATTER_GAIN = 1.5,
					BODY_SHARE = 0.55,
					SHATTER_TOP = 12000,
					SMASH_REACH = 25,
					POOF_GAIN = 1.4,
					WHOOSH_GAIN = 1,
					IGNITE_REACH = 30,
					IGNITE_LAG = { 0.14, 0.22 },
					WITHIN = 170,
					OWN_FLOOR = 0.55,
					PRIO = 4,
					TAIL = 0.25,
					ECHO_GAIN = 0.35,
					ROAR_ID = 9112780561,
					ROAR_REGION = NumberRange.new(26.35, 32.45),
					ROAR_GAIN = 0.4,
					ROAR_NOMINAL = 14,
					roar = { pos = nil, volume = 0 }
				}

				local positional = AudioGraph.positional("FuelRoar", voxelSoundVoices)
				positional.player.Asset = "rbxassetid://" .. v254.ROAR_ID
				positional.player.Looping = true
				positional.player.PlaybackSpeed = 1
				positional.player.PlaybackRegion = v254.ROAR_REGION
				positional.player.LoopRegion = v254.ROAR_REGION
				AudioGraph.park(positional)

				function VoxelSound.molotovLight()
					ringFire( -- inferred equivalent call
						v254.ring,
						draw(v254.STRIKE),
						v254.STRIKE_GAIN * jitter(), -- inferred equivalent call
						math.min(0.94 + 0.06000000000000005 * math.random(), 1),
						"dry",
						1e999,
						0
					)
					later(v254.FLARE_LAG, function()
						ringFire( -- inferred equivalent call
							v254.ring,
							draw(v254.FLARE),
							v254.FLARE_GAIN * jitter(), -- inferred equivalent call
							math.min(0.92 + 0.07999999999999996 * math.random(), 1),
							"dry",
							1e999,
							0
						)
					end)
				end

				do
					local function reach(p: number, p2: number) -- 2 equivalent calls inferred from this helper
						local v255 = 10 ^ (math.max(p2 - 100, 0) * -1.5 / 100 / 20)
						return math.min(1, p / p2) ^ 0.75 * v255
					end
				end

				do
					local function smashArrive(vector3: Vector3, flag: boolean?)
						local v255 = camPos() -- inferred equivalent call
						local magnitude = (vector3 - v255).Magnitude
						local v256 = math.max(magnitude / meter, 1)
						local v257 = jitter() -- inferred equivalent call
						local v258 = occluded(vector3, v255, magnitude)

						local v259 = 1
						local v260 = airCutoff(v256 / 1.5) -- inferred equivalent call

						if v258 then
							v259 *= 0.55
							v260 = math.min(v260, 1102.27038425243)
						end

						if v13 > 0 and v256 > 15 then
							v259 *= 1 - v13 * 0.45
							v260 = math.max(v260 * (1 - v13 * 0.6), 700)
						end

						local v261 = reach(v254.SMASH_REACH, v256) * v257 * v259 -- inferred equivalent call
						local v262 = reach(v254.IGNITE_REACH, v256) * v257 * v259 -- inferred equivalent call

						if flag then
							v261 = math.max(v261, v254.OWN_FLOOR)
							v262 = math.max(v262, v254.OWN_FLOOR)
							v260 = math.max(v260, 6000)
							v8 = math.max(v8, 0)
						end

						local v263 = v254.SMASH_GAIN * v261

						local v264 = draw(v254.SHATTER)
						local v265 = v254.SHATTER_GAIN * v261
						local v266 = math.min(0.93 + 0.06999999999999995 * math.random(), 1)

						local SHATTER_TOP = v254.SHATTER_TOP
						emitAt(
							v264,
							vector3,
							v265,
							v266,
							"dry",
							math.min(v260, SHATTER_TOP),
							1.8,
							0.3,
							v263 + v254.PRIO + 1
						)
						emitAt(
							draw(v254.SMASH),
							vector3,
							v263 * v254.BODY_SHARE,
							math.min(0.9 + 0.09999999999999998 * math.random(), 1),
							"dry",
							v260,
							1,
							0.15,
							v263 + v254.PRIO
						)
						later(v254.IGNITE_LAG[1] + (v254.IGNITE_LAG[2] - v254.IGNITE_LAG[1]) * math.random(), function()
							emitAt(
								draw(v254.POOF),
								vector3,
								v254.POOF_GAIN * v262,
								math.min(0.9 + 0.09999999999999998 * math.random(), 1),
								"dry",
								v260,
								1.2,
								0.3,
								v262 + v254.PRIO
							)
							emitAt(
								draw(v254.WHOOSH),
								vector3,
								v254.WHOOSH_GAIN * v262,
								math.min(0.88 + 0.12 * math.random(), 1),
								"dry",
								v260,
								0.8,
								0.2,
								v262 + v254.PRIO - 0.5
							)
						end)
						placeTail(vector3, 0.9 * v254.TAIL * math.min(1, 45 / v256), v256, 0.9, 0.7)

						if v256 < 120 then
							reflections(vector3, v255, magnitude, v254.ECHO_GAIN * v257 * v259, v254.ECHO)
						end

						heardFight(v263) -- inferred equivalent call
					end

					function VoxelSound.molotovSmash(vector3: Vector3, _: Vector3, flag: boolean?)
						local v255 = (vector3 - camPos()).Magnitude / meter -- inferred equivalent call

						if v254.WITHIN < v255 then
							return
						end

						later(v255 / 343, smashArrive, vector3, flag)
					end
				end

				function VoxelSound.fuelFire(vector3: Vector3?, value: number)
					local roar = v254.roar
					local roar2 = v254.roar
					local volume = math.clamp(value, 0, 1)
					roar.pos = vector3
					roar2.volume = volume

					if vector3 then
						positional.attachment.WorldPosition = vector3
					elseif AudioGraph.awake(positional) then
						positional.player:Stop()
						AudioGraph.park(positional)
					end
				end

				table.insert(v11, function()
					local pos = v254.roar.pos

					if not pos then
						return
					end

					local v255 = camPos() -- inferred equivalent call
					local magnitude = (pos - v255).Magnitude
					local v256 = math.max(magnitude / meter, 0.5)
					local v257 = occluded(pos, v255, magnitude)

					local v258 = 1
					local v259 = airCutoff(v256 / 1) -- inferred equivalent call

					if v257 then
						v258 *= 0.55
						v259 = math.min(v259, 900)
					end

					if v13 > 0 and v256 > 15 then
						v258 *= 1 - v13 * 0.45
						v259 = math.max(v259 * (1 - v13 * 0.6), 700)
					end

					local volume = v254.roar.volume * v254.ROAR_GAIN * math.min(1, v254.ROAR_NOMINAL / v256) ^ 0.75 * v258
					local player = positional.player

					if volume < 0.003 then
						if AudioGraph.awake(positional) then
							player:Stop()
							AudioGraph.park(positional)
						end
					else
						AudioGraph.route(positional, "dry")

						if not player.IsPlaying then
							player.TimePosition = v254.ROAR_REGION.Min + math.random() * (v254.ROAR_REGION.Max - v254.ROAR_REGION.Min)
							player:Play()
						end

						player.Volume = volume
						AudioGraph.lowpass(positional, v259)
					end
				end)
			end

			do
				local function loopCut(p: number, p2: number, p3: number, gain: number)
					return {
						id = "rbxassetid://" .. p,
						range = NumberRange.new(p2, p3),
						gain = gain
					}
				end

				local v255 = {
					IGNITE = bagOf({
						gslice(9114446802, 0.184, 0.856, 1.24),
						gslice(9114446277, 0.196, 0.66, 0.98),
						gslice(9114445526, 0.362, 1.16, 1.89)
					}),
					STOP = bagOf({
						gslice(9120193891, 5.319, 5.871, 0.52),
						gslice(9120193895, 2.138, 2.376, 0.51),
						gslice(9117988143, 0.196, 0.692, 0.81)
					}),
					VALVE = bagOf({ gslice(9120192992, 21.45, 21.723, 1.1) }),
					EMPTY = bagOf({ gslice(9116545827, 1.181, 1.287, 3.18), gslice(9116345318, 0.955, 1.096, 3.19) }),
					BODY = loopCut(9120193024, 7.25, 13.25, 6.36),
					HISS = loopCut(9120192280, 2.6, 8.7, 5.11),
					ring = ring("FlamerOwn", 3),
					IGNITE_GAIN = 0.75,
					STOP_GAIN = 0.6,
					VALVE_GAIN = 0.36,
					EMPTY_GAIN = 0.4,
					OWN_BODY = 0.5,
					OWN_HISS = 0.4,
					REMOTE_BODY = 0.5,
					REMOTE_HISS = 0.32,
					FADE_IN = 0.07,
					FADE_OUT = 0.1,
					REACH = 8,
					WITHIN = 90,
					CUTOFF = 12000,
					SLOTS = 3,
					FIGHT_GAP = 0.3
				}

				local function loopVoice(p, p2)
					local player = p.player
					player.Asset = p2.id
					player.Looping = true
					player.PlaybackRegion = p2.range
					player.LoopRegion = p2.range
					player.PlaybackSpeed = 1
					player.Volume = 0
					AudioGraph.park(p)
					return p
				end

				local function startAt(p, p2)
					local player = p.player
					player:Stop()
					player.TimePosition = p2.range.Min + math.random() * (p2.range.Max - p2.range.Min - 0.3)
					AudioGraph.route(p, "dry")
					player:Play()
				end

				local v256 = loopVoice(AudioGraph.flat("FlamerBody", false, nil, true), v255.BODY)
				local v257 = loopVoice(AudioGraph.flat("FlamerHiss", false, nil, true), v255.HISS)
				local v258 = { last = 0, on = false, level = 0, empty = false }

				function VoxelSound.flamerOwn(on: boolean, empty: boolean)
					local now = os.clock()
					local v259 = math.min(now - v258.last, 0.1)
					v258.last = now

					if on and not v258.on then
						ringFire( -- inferred equivalent call
							v255.ring,
							draw(v255.IGNITE),
							v255.IGNITE_GAIN * jitter(), -- inferred equivalent call
							math.min(0.92 + 0.07999999999999996 * math.random(), 1),
							"dry",
							1e999,
							0
						)

						if v258.level <= 0 then
							startAt(v256, v255.BODY)
							startAt(v257, v255.HISS)
						end
					elseif v258.on and not on then
						ringFire( -- inferred equivalent call
							v255.ring,
							draw(v255.STOP),
							v255.STOP_GAIN * jitter(), -- inferred equivalent call
							math.min(0.9 + 0.09999999999999998 * math.random(), 1),
							"dry",
							1e999,
							0
						)
						ringFire( -- inferred equivalent call
							v255.ring,
							draw(v255.VALVE),
							v255.VALVE_GAIN * jitter(), -- inferred equivalent call
							math.min(0.94 + 0.06000000000000005 * math.random(), 1),
							"dry",
							1e999,
							0
						)
					end

					if empty and not v258.empty then
						ringFire( -- inferred equivalent call
							v255.ring,
							draw(v255.EMPTY),
							v255.EMPTY_GAIN * jitter(), -- inferred equivalent call
							math.min(0.94 + 0.06000000000000005 * math.random(), 1),
							"dry",
							1e999,
							0
						)
					end

					v258.on = on
					v258.empty = empty

					if on then
						v258.level = math.min(1, v258.level + v259 / v255.FADE_IN)
						v8 = math.max(v8, 0)
					elseif v258.level > 0 then
						v258.level = math.max(0, v258.level - v259 / v255.FADE_OUT)

						if v258.level <= 0 then
							v256.player:Stop()
							v257.player:Stop()
							AudioGraph.park(v256)
							AudioGraph.park(v257)
						end
					end

					if v258.level > 0 then
						v256.player.Volume = v255.OWN_BODY * v255.BODY.gain * v258.level
						v257.player.Volume = v255.OWN_HISS * v255.HISS.gain * v258.level
					end
				end

				local v259 = {}

				do
					local v260 = {}

					for i = 1, v255.SLOTS do
						v259[i] = {
							key = nil,
							active = false,
							used = 0,
							pos = Vector3.new(0, 0, 0),
							level = 0,
							lastFight = 0,
							body = loopVoice(AudioGraph.positional("FlamerBody" .. i, voxelSoundVoices), v255.BODY),
							hiss = loopVoice(AudioGraph.positional("FlamerHiss" .. i, voxelSoundVoices), v255.HISS)
						}
					end

					do
						local function reach2(pos: Vector3) -- 3 equivalent calls inferred from this helper
							local v261 = camPos() -- inferred equivalent call
							local magnitude = (pos - v261).Magnitude
							local v262 = math.max(magnitude / meter, 1)
							local v263 = occluded(pos, v261, magnitude)

							local v264 = 1
							local v265 = airCutoff(v262 / 1) -- inferred equivalent call

							if v263 then
								v264 *= 0.55
								v265 = math.min(v265, 900)
							end

							if v13 > 0 and v262 > 15 then
								v264 *= 1 - v13 * 0.45
								v265 = math.max(v265 * (1 - v13 * 0.6), 700)
							end

							return math.min(1, v255.REACH / v262) * v264, math.min(v265, v255.CUTOFF), v262
						end
					end

					function VoxelSound.flamerAt(p, pos: Vector3?)
						local v261 = v260[p]

						if pos then
							if not v261 then
								local v262, v263, v264 = reach2(pos) -- inferred equivalent call

								if v255.WITHIN < v264 then
									return
								end

								v261 = v259[1]

								for _, v266 in v259 do
									if v266.active or not (v266.level <= 0) then
										if v266.used < v261.used then
											v261 = v266
										end
									else
										v261 = v266
										break
									end
								end

								if v261.active then
									v260[v261.key] = nil
								end

								local now = os.clock()
								v261.key = p
								v261.active = true
								v261.used = now
								v261.lastFight = 0

								if v261.level <= 0 then
									startAt(v261.body, v255.BODY)
									startAt(v261.hiss, v255.HISS)
								end

								v260[p] = v261
								emitAt(
									draw(v255.IGNITE),
									pos,
									v255.IGNITE_GAIN * v262,
									math.min(0.92 + 0.07999999999999996 * math.random(), 1),
									"dry",
									v263,
									1e999,
									0,
									v262 + 0.5
								)
							end

							v261.pos = pos
						elseif v261 then
							v261.active = false
							v260[p] = nil
							local v262, v263, v264 = reach2(v261.pos) -- inferred equivalent call

							if v264 <= v255.WITHIN then
								emitAt(
									draw(v255.STOP),
									v261.pos,
									v255.STOP_GAIN * v262,
									math.min(0.9 + 0.09999999999999998 * math.random(), 1),
									"dry",
									v263,
									1e999,
									0,
									v262 + 0.5
								)
							end
						end
					end
				end

				local v261 = os.clock()
				table.insert(v11, function()
					local now = os.clock()
					local v262 = math.min(now - v261, 0.1)
					v261 = now

					if now - v258.last > 0.2 and (v258.on or v258.level > 0) then
						VoxelSound.flamerOwn(false, false)
					end

					for _, v263 in v259 do
						if not (v263.active or not (v263.level <= 0)) then
							continue
						end

						if v263.active then
							v263.level = math.min(1, v263.level + v262 / v255.FADE_IN)
						else
							v263.level = math.max(0, v263.level - v262 / v255.FADE_OUT)

							if v263.level <= 0 then
								v263.body.player:Stop()
								v263.hiss.player:Stop()
								AudioGraph.park(v263.body)
								AudioGraph.park(v263.hiss)
								continue
							end
						end

						v263.body.attachment.WorldPosition = v263.pos
						v263.hiss.attachment.WorldPosition = v263.pos
						local v264, v265 = reach2(v263.pos) -- inferred equivalent call
						v263.body.player.Volume = v255.REMOTE_BODY * v255.BODY.gain * v264 * v263.level
						v263.hiss.player.Volume = v255.REMOTE_HISS * v255.HISS.gain * v264 * v263.level
						AudioGraph.lowpass(v263.body, v265)
						AudioGraph.lowpass(v263.hiss, v265)

						if not (v263.active and now - v263.lastFight >= v255.FIGHT_GAP) then
							continue
						end

						v263.lastFight = now
						heardFight(v264) -- inferred equivalent call
					end
				end)
			end

			do
				local v262 = bagOf({
					gslice(9114659833, 0, 0.261, 1.82),
					gslice(9114659662, 0.783, 1.121, 1.1199999999999999)
				})

				local v263 = bagOf({
					gslice(9121006025, 0, 0.076, 4.95),
					gslice(9121005785, 0, 0.09, 6.32),
					gslice(9120093008, 0, 0.091, 1.75),
					gslice(9116545827, 1.382, 1.57, 1.32)
				})

				local v264 = bagOf({
					gslice(9114659492, 0.025, 0.198, 0.52),
					gslice(9114659492, 0.316, 0.565, 0.54),
					gslice(9114659519, 0.492, 0.658, 0.52)
				})

				local v265 = bagOf({
					gslice(9116615325, 0.523, 0.821, 0.88),
					gslice(9116614920, 0.563, 0.992, 0.85),
					gslice(9116615028, 0.444, 0.882, 0.84),
					gslice(9116615340, 0.314, 0.775, 0.88)
				})

				local v266 = bagOf({
					gslice(9118616114, 0.063, 0.205, 0.73),
					gslice(9118683165, 0.005, 0.285, 0.9),
					gslice(9118683158, 0.005, 0.293, 0.89),
					gslice(9118680950, 0.008, 0.297, 0.9),
					gslice(9114751802, 0.433, 0.678, 0.91),
					gslice(9114751802, 1.246, 1.485, 2.71)
				})

				local v267 = bagOf({ gslice(9116751108, 0, 0.202, 0.56), gslice(9116750726, 0.136, 0.35, 0.54) })

				local set = {
					[Enum.Material.Grass] = true,
					[Enum.Material.LeafyGrass] = true,
					[Enum.Material.Ground] = true,
					[Enum.Material.Sand] = true,
					[Enum.Material.Mud] = true,
					[Enum.Material.Snow] = true
				}

				local set2 = {
					[Enum.Material.Metal] = true,
					[Enum.Material.CorrodedMetal] = true,
					[Enum.Material.DiamondPlate] = true,
					[Enum.Material.Foil] = true
				}

				local set3 = { [Enum.Material.Wood] = true, [Enum.Material.WoodPlanks] = true }

				do
					local v268 = ring("GrenadePin", 1)
					local v269 = ring("GrenadeSpoon", 2)

					do
						local function bounceKind(p) -- 1 equivalent call inferred from this helper
							if typeof(p) == "EnumItem" then
								if set[p] then
									return "soft"
								end

								if set2[p] then
									return "metal"
								end

								if set3[p] then
									return "wood"
								end

								return "hard"
							else
								local v270 = Materials.Palette[p]
								assert(v270, "[VoxelSound] grenade bounce on an unknown palette id: " .. tostring(p))
								local sound = v270.type.sound

								if sound == "soil" then
									return "soft"
								end

								if sound == "metal" or sound == "wood" then
									return sound
								end

								return "hard"
							end
						end
					end

					do
						local function bounceLayer(p, vector3: Vector3, p2: number, p3: number, p4: number) -- 6 equivalent calls inferred from this helper
							emitAt(p, vector3, p2, p3, "dry", p4, (p.to - p.from) / p3 - 0.02, 0.02, p2 + 0.5)
						end
					end

					function VoxelSound.grenadePin()
						ringFire( -- inferred equivalent call
							v268,
							draw(v262),
							jitter() * 0.45, -- inferred equivalent call
							math.min(0.94 + 0.06000000000000005 * math.random(), 1),
							"dry",
							1e999,
							0
						)
					end

					function VoxelSound.grenadeSpoon()
						ringFire( -- inferred equivalent call
							v269,
							draw(v263),
							jitter() * 0.5, -- inferred equivalent call
							math.min(0.92 + 0.07999999999999996 * math.random(), 1),
							"dry",
							1e999,
							0
						)
					end
				end

				function VoxelSound.grenadeBounce(vector3: Vector3, p: number, p2)
					local v270 = camPos() -- inferred equivalent call
					local magnitude = (vector3 - v270).Magnitude
					local v271 = math.max(magnitude / meter, 1)

					if v271 > 45 then
						return
					end

					local v272 = smoothstep(1.2, 10, p) -- inferred equivalent call
					local v273 = occluded(vector3, v270, magnitude)

					local v274 = 1
					local v275 = airCutoff(v271 / 1) -- inferred equivalent call

					if v273 then
						v274 *= 0.55
						v275 = math.min(v275, 900)
					end

					if v13 > 0 and v271 > 15 then
						v274 *= 1 - v13 * 0.45
						v275 = math.max(v275 * (1 - v13 * 0.6), 700)
					end

					local v276 = (v272 * 0.75 + 0.25) * 0.9 * math.min(1, 6 / v271) * jitter() * v274 -- inferred equivalent call
					local v277 = math.min(0.9 + 0.09999999999999998 * math.random(), 1)
					local v278 = bounceKind(p2) -- inferred equivalent call

					if v278 == "soft" then
						bounceLayer(draw(v266), vector3, v276, v277, v275) -- inferred equivalent call
					elseif v278 == "metal" then
						bounceLayer(draw(v267), vector3, v276, v277, v275) -- inferred equivalent call
						bounceLayer( -- inferred equivalent call
							draw(v265),
							vector3,
							v276 * 0.4 * 0.6,
							math.min(0.9 + 0.09999999999999998 * math.random(), 1),
							v275
						)
					elseif v278 == "wood" then
						bounceLayer(draw(v264), vector3, v276, v277 * 0.95, math.min(v275, 4000)) -- inferred equivalent call
					else
						bounceLayer(draw(v264), vector3, v276, v277, v275) -- inferred equivalent call
						bounceLayer( -- inferred equivalent call
							draw(v265),
							vector3,
							v276 * 0.4 * (v272 * 0.5 + 0.5),
							math.min(0.9 + 0.09999999999999998 * math.random(), 1),
							v275
						)
					end
				end
			end

			function VoxelSound.farBlast(vector3: Vector3, p: number)
				local v270 = math.max((vector3 - camPos()).Magnitude / meter, 1) -- inferred equivalent call
				later(v270 / 343, function()
					local v271 = p * math.min(1, 200 / v270)
					emitAt(
						draw(farBag),
						vector3,
						v271,
						math.min(0.9 + 0.09999999999999998 * math.random(), 1),
						"dry",
						math.min(airCutoff(v270), 2300), -- inferred equivalent call
						2,
						0.8,
						v271
					)
				end)
			end

			function VoxelSound.click(vector3: Vector3, p: number, value: number)
				local v270 = math.clamp(value, 0, 1)
				local v271 = math.max((vector3 - camPos()).Magnitude / meter, 0.5) -- inferred equivalent call
				local v272 = p * 0.5 * jitter() * math.min(1, 3 / v271) -- inferred equivalent call
				local v273 = math.min(0.95 + 0.050000000000000044 * math.random(), 1) * (1 - v270 * 0.15)

				if v270 >= 0.6 then
					emitAt(draw(v214), vector3, v272, v273, "dry", airCutoff(v271), 0.16, 0.05, v272 + 1) -- inferred equivalent call
					VoxelSound.play(v68, vector3, p * 0.5, 1 - v270 * 0.3)
				else
					emitAt(draw(v213), vector3, v272 * 0.8, v273, "dry", airCutoff(v271), 0.12, 0.04, v272 + 1) -- inferred equivalent call
				end
			end

			do
				local v270 = { walk = 0.22, sprint = 0.36, land = 0.5, jump = 0.18 }

				local v271 = { walk = 25, sprint = 40, land = 40, jump = 20 }

				local items17 = {
					gslice(9119380958, 0.042, 0.345, 0.89),
					gslice(9119380958, 0.527, 0.87, 1),
					gslice(9119380958, 2.052, 2.385, 0.89),
					gslice(9119380958, 2.927, 3.185, 1),
					gslice(9119380958, 3.922, 4.19, 0.71),
					gslice(9119380970, 0.017, 0.425, 1.12),
					gslice(9119380970, 1.307, 1.625, 1),
					gslice(9119380970, 3.412, 3.555, 1),
					gslice(9119380970, 4.992, 5.285, 0.79),
					gslice(9119380974, 0.007, 0.175, 0.79),
					gslice(9119380974, 0.307, 0.59, 0.63),
					gslice(9119380974, 1.442, 1.76, 1),
					gslice(9119380974, 2.697, 2.895, 0.89),
					gslice(9119380974, 3.547, 3.745, 0.89)
				}

				local items18 = {
					gslice(9114523161, 0.007, 0.065, 1.12),
					gslice(9114523636, 0.007, 0.055, 0.71),
					gslice(9114523612, 0.007, 0.07, 0.71)
				}

				local items19 = {
					gslice(9125892505, 4.777, 4.98, 0.56),
					gslice(9125892505, 5.197, 5.4, 0.63),
					gslice(9125892587, 2.612, 2.81, 0.63),
					gslice(9125892587, 4.232, 4.43, 0.63),
					gslice(9125892587, 4.812, 5.01, 0.71),
					gslice(9125892600, 4.227, 4.43, 0.79),
					gslice(9125892600, 4.657, 4.86, 1)
				}

				local items20 = {
					gslice(9114657970, 0.052, 0.185, 1.78),
					gslice(9114657970, 0.187, 0.34, 0.89),
					gslice(9114657970, 0.342, 0.54, 1),
					gslice(9114658160, 0.077, 0.205, 1.12),
					gslice(9114658159, 0.062, 0.135, 1.41),
					gslice(9114657456, 0.087, 0.325, 1.78)
				}

				local items21 = { gslice(9120062559, 0.007, 0.205, 2), gslice(9120063929, 0.832, 1.125, 2.5) }

				local items22 = { gslice(9118768193, 0.377, 0.525, 1.6) }
				local items23 = {
					gslice(9118683165, 0.007, 0.035, 0.28),
					gslice(9118686417, 0.007, 0.08, 0.9),
					gslice(9118685996, 0.007, 0.1, 1.6)
				}

				local items24 = {
					gslice(9120836780, 1.002, 1.15, 5),
					gslice(9120836780, 1.152, 1.565, 4.5),
					gslice(9120836780, 1.947, 2.145, 2.5)
				}

				local items25 = {
					gslice(9113524166, 0.007, 0.28, 0.5),
					gslice(9113524237, 0.017, 0.1, 0.5),
					gslice(9113524242, 0.202, 0.42, 0.4),
					gslice(9113524242, 0.787, 1.005, 0.4)
				}

				local items26 = {
					gslice(9114884726, 0.147, 0.23, 2.2),
					gslice(9114884726, 0.307, 0.445, 3.2),
					gslice(9114884734, 0.707, 1.09, 0.7)
				}

				v26 = bagOf(items17)
				local v282 = bagOf(items18)
				local v283 = {
					dirt = {
						boot = v26,
						bootPitch = { 0.9, 1 },
						surface = nil,
						surfacePitch = { 1, 1 },
						surfaceGain = 0
					},
					grass = {
						boot = v26,
						bootPitch = { 0.9, 1 },
						surface = bagOf(items21),
						surfacePitch = { 0.85, 1 },
						surfaceGain = 0.6
					},
					sand = {
						boot = v26,
						bootPitch = { 0.85, 0.95 },
						surface = bagOf(items22),
						surfacePitch = { 0.8, 1 },
						surfaceGain = 0.7
					},
					gravel = {
						boot = v26,
						bootPitch = { 0.9, 1 },
						surface = bagOf(items20),
						surfacePitch = { 0.85, 1 },
						surfaceGain = 0.8
					},
					concrete = {
						boot = v282,
						bootPitch = { 0.92, 1 },
						surface = bagOf(items23),
						surfacePitch = { 0.85, 1 },
						surfaceGain = 0.45
					},
					wood = {
						boot = v282,
						bootPitch = { 0.8, 0.88 },
						surface = bagOf(items24),
						surfacePitch = { 0.85, 1 },
						surfaceGain = 0.35
					},
					metal = {
						boot = bagOf(items19),
						bootPitch = { 0.9, 1 },
						surface = v282,
						surfacePitch = { 0.85, 0.95 },
						surfaceGain = 0.5
					}
				}

				local v284 = bagOf(items25)
				local v285 = bagOf(items26)
				local v286 = ring("OwnStep", 6)

				function VoxelSound.step(vector3: Vector3, p: string, p2: string, flag: boolean, value: number?)
					local v287 = v283[p]

					if not v287 then
						error("[VoxelSound] unknown step surface " .. tostring(p))
					end

					local v288 = v270[p2]

					if not v288 then
						error("[VoxelSound] unknown step kind " .. tostring(p2))
					end

					local v289 = math.clamp(value or 1, 0, 1)
					local v290 = v288 * (p2 ~= "land" and 1 or v289 * 0.6 + 0.4) * jitter() -- inferred equivalent call
					local function layerStep(p3, p4: number, p5: number, p6: number, p7: number, value2: number?)
						if flag then
							local v291 = draw(p3)

							if value2 and value2 > 0 then
								later(value2, function()
									ringFire(v286, v291, p4, pitch(p5, p6), "dry", p7, 0.05) -- inferred equivalent call
								end)
								return
							end

							ringFire(v286, v291, p4, pitch(p5, p6), "dry", p7, 0.05) -- inferred equivalent call
						else
							local v291 = camPos() -- inferred equivalent call
							local magnitude = (vector3 - v291).Magnitude
							local v292 = math.max(magnitude / meter, 0.5)

							if v271[p2] < v292 then
								return
							end

							local v293 = occluded(vector3, v291, magnitude)

							local v294 = 1
							local v295 = airCutoff(v292 / 1) -- inferred equivalent call

							if v293 then
								v294 *= 0.55
								v295 = math.min(v295, 900)
							end

							if v13 > 0 and v292 > 15 then
								v294 *= 1 - v13 * 0.45
								v295 = math.max(v295 * (1 - v13 * 0.6), 700)
							end

							local v296 = p4 * 1.3 * math.min(1, 3 / v292) ^ 0.85 * v294
							later((value2 or 0) + v292 / 343, function()
								emitAt(draw(p3), vector3, v296, pitch(p5, p6), "dry", v295, p7, 0.05, v296) -- inferred equivalent call
							end)
						end
					end

					if p2 == "jump" then
						layerStep(v285, v290, 0.85, 1, 0.3)
						return
					end

					local v291 = p2 == "sprint"
					layerStep(v287.boot, v290, v287.bootPitch[1], v287.bootPitch[2] * (v291 and 1 or 0.97), 0.35)

					if v287.surface and v287.surfaceGain > 0 then
						layerStep(
							v287.surface,
							v290 * 0.55 * v287.surfaceGain * (v291 and 1.2 or 1),
							v287.surfacePitch[1],
							v287.surfacePitch[2],
							0.3,
							0.01
						)
					end

					if p2 == "land" then
						layerStep(v284, v290 * (v289 * 0.6 + 0.6), 0.8, 0.95, 0.3)
					end
				end
			end

			local v287 = bagOf({
				gslice(9114064280, 0.017, 0.145, 1),
				gslice(9114064280, 0.197, 0.325, 1.6),
				gslice(9114064280, 0.447, 0.59, 1),
				gslice(9114064280, 0.592, 0.685, 1.8),
				gslice(9114064280, 0.722, 0.845, 1.8),
				gslice(9114071134, 0.132, 0.21, 0.8)
			})

			local v288 = bagOf({
				gslice(9116164654, 0.262, 0.435, 0.6),
				gslice(9116164654, 0.967, 1.205, 0.25),
				gslice(9116164654, 2.622, 2.735, 0.14),
				gslice(9116164654, 3.282, 3.63, 0.3),
				gslice(9116164654, 4.217, 4.42, 0.17)
			})

			VoxelSound.HIT_SOUNDS = {
				pick = "k",
				a = { slice = gslice(3748776946, 0, 0.4, 1), gain = 1, length = 0.3 },
				b = { slice = gslice(3748777642, 0, 0.4, 1), gain = 1, length = 0.3 },
				c = { slice = gslice(3748780065, 0, 0.4, 1), gain = 1, length = 0.3 },
				d = {
					slice = gslice(138148057831879, 0, 0.4, 1),
					gain = 1,
					length = 0.3
				},
				e = {
					slice = gslice(80933041515579, 0, 0.4, 1),
					gain = 1,
					length = 0.3
				},
				f = {
					slice = gslice(125235091454234, 0, 0.4, 1),
					gain = 1,
					length = 0.3
				},
				g = { slice = gslice(9120619991, 0, 0.4, 1), gain = 1, length = 0.3 },
				h = { slice = gslice(1455817260, 0, 0.4, 1), gain = 1, length = 0.3 },
				i = { slice = gslice(17724151829, 0, 0.4, 1), gain = 1, length = 0.3 },
				j = {
					slice = gslice(137166459647708, 0, 0.4, 1),
					gain = 1,
					length = 0.3
				},
				k = { slice = gslice(5952120301, 0, 0.4, 1), gain = 1, length = 0.3 }
			}

			local v289 = gslice(9116654750, 0.942, 1.075, 0.45)
			gslice(9113487449, 0.042, 0.12, 0.9)
			local v290 = gslice(9116973611, 0.025, 0.6, 1.41)

			local v291 = gslice(9119991958, 0.62, 1.4, 1.1)

			VoxelSound.KILL_RINGS = {
				pick = "b",
				a = {
					slice = gslice(9114618921, 0.15, 1.3, 1),
					hp = 1500,
					hold = 0.45,
					fade = 0.35,
					gain = 6
				},
				b = {
					slice = gslice(9116682514, 0.34, 1.6, 1),
					hp = 2000,
					hold = 0.45,
					fade = 0.35,
					gain = 5.6
				},
				c = {
					slice = gslice(9125741212, 0.18, 1.1, 1),
					hp = 1500,
					hold = 0.4,
					fade = 0.3,
					gain = 2.65
				}
			}

			local v292 = gslice(9113815718, 0.25, 0.8, 2)

			VoxelSound.HEADSHOT = (function()
				local v293 = {
					pick = "new",
					gain = 0.8,
					block = {
						id = "rbxassetid://9119991958",
						from = 0.5,
						to = 1.5,
						speed = 0.72,
						volume = 2.375,
						hp = 1500,
						ceil = 11600,
						dipF = 4500,
						dipQ = 0.8,
						dipGain = -12,
						hold = 0.7,
						sweep = 0.3,
						sweepTo = 3500,
						fade = 0.6
					},
					pings = {},
					chain = nil
				}

				for _, v294 in {
					{ 9125740659, 0.15, 0.6, 0.78, 0.95, 0.12, 0.1, 0.06 },
					{ 9125740659, 0.15, 0.6, 0.65, 0.95, 0.29, 0.14, 0.1 },
					{ 9120288183, 0.075, 0.6, 0.045, 0.98, 0.38, 0.18, 0.1 },
					{ 9125741778, 0.15, 0.5, 0.29, 0.92, 0.41, 0.12, 0.08 },
					{ 9114059172, 0.44, 0.9, 0.46, 1, 0.46, 0.12, 0.08 },
					{ 9125741778, 0.15, 0.5, 1.44, 0.985, 0.67, 0.14, 0.08 },
					{ 9116164654, 3.24, 3.6, 0.065, 0.96, 0.72, 0.1, 0.06 },
					{ 9120288183, 0.075, 0.6, 0.045, 0.86, 0.76, 0.16, 0.12 },
					{ 9125740659, 0.15, 0.6, 0.61, 0.97, 0.77, 0.1, 0.08 }
				} do
					local v295 = v294[4] * 5.14
					local v296 = math.ceil(v295 / 3)
					local slices = {}

					for i = 1, v296 do
						slices[i] = gslice(v294[1], v294[2], v294[3], v295 / v296) -- inferred equivalent call
					end

					table.insert(v293.pings, {
						slices = slices,
						speed = v294[5],
						at = v294[6],
						length = v294[7],
						fade = v294[8]
					})
				end

				return v293
			end)()
			local v293 = bagOf({
				gslice(9119918673, 2.212, 2.36, 0.5),
				gslice(9119918673, 0.987, 1.16, 0.55),
				gslice(9119918673, 1.512, 1.66, 0.6),
				gslice(9119919230, 0.737, 0.88, 0.7)
			})

			local v294 = ring("Ui", 8)
			local v295 = ring("Kill", 10)
			local v296 = -1
			local v297 = -1
			local v298 = -10

			do
				local v299 = {
					hit = true,
					headshot = true,
					kill = true,
					headshotkill = true,
					points = true,
					multikill = true
				}

				do
					local function uiPlay(p, p2: number, p3: number, p4: number, p5: number, p6: number?, p7, p8: number?)
						local v300 = p7 or v294
						local v301

						if p7 then
							v301 = p2 * 0.85
						else
							v301 = p2 * 0.55
						end

						if p6 and p6 > 0 then
							later(p6, function()
								ringFire(v300, p, v301, pitch(p3, p4), "ui", p5, 0.04, nil, p8) -- inferred equivalent call
							end)
							return
						end

						ringFire(v300, p, v301, pitch(p3, p4), "ui", p5, 0.04, nil, p8) -- inferred equivalent call
					end
					local function killPlay(p, p2: number, p3: number, p4: number, p5: number, p6: number?, p7: number?)
						uiPlay(p, p2, p3, p4, p5, p6, v295, p7)
					end
				end

				do
					local function killSpray(p: number, p2: number, p3: number, p4: number, value: number?)
						local v300 = v291
						local v301 = 0.85 * (1 - (value or 0))
						local function burst()
							ringFire(v295, v300, p * 0.85, v301, "ui", p3, 0.12, nil, 400) -- inferred equivalent call

							if p4 > 0 then
								ringFire(v295, v300, p4 * 0.85, v301, "ui", 0.38, 0.1, nil, 1000) -- inferred equivalent call
							end
						end
						later(p2, burst)
					end
				end

				local function headSpray()
					local v300 = v291
					ringFire(v295, v300, 0.51, 1, "ui", 0.06, 0.12, nil, 400) -- inferred equivalent call
					ringFire(v295, v300, 0.255, 1, "ui", 0.52, 0.03, nil, 1000) -- inferred equivalent call
					ringFire(v295, v292, 1.275, 1, "ui", 0.48000000000000004, 0.04, nil, 2500) -- inferred equivalent call
				end

				function VoxelSound.HEADSHOT.play()
					local headshot = VoxelSound.HEADSHOT
					local block = headshot.block
					local chain = headshot.chain

					if not chain then
						local flat = AudioGraph.flat("HeadBlock", true)
						AudioGraph.route(flat, "ui")
						AudioGraph.highpass(flat, block.hp)
						local parent = flat.filter.Parent
						local headBlockPlayer = Instance.new("AudioPlayer")
						headBlockPlayer.Name = "HeadBlockPlayer"
						headBlockPlayer.AutoLoad = true
						headBlockPlayer.Asset = block.id
						headBlockPlayer.Parent = parent
						local headBlockCeiling = Instance.new("AudioFilter")
						headBlockCeiling.Name = "HeadBlockCeiling"
						headBlockCeiling.FilterType = Enum.AudioFilterType.Lowpass48dB
						headBlockCeiling.Frequency = block.ceil
						headBlockCeiling.Q = 0.707
						headBlockCeiling.Parent = parent
						local headBlockTilt = Instance.new("AudioFilter")
						headBlockTilt.Name = "HeadBlockTilt"
						headBlockTilt.FilterType = Enum.AudioFilterType.Peak
						headBlockTilt.Frequency = block.dipF
						headBlockTilt.Q = block.dipQ
						headBlockTilt.Gain = block.dipGain
						headBlockTilt.Parent = parent

						for _, v301 in {
							{ headBlockPlayer, headBlockCeiling },
							{ headBlockCeiling, headBlockTilt },
							{ headBlockTilt, flat.filter }
						} do
							local wire = Instance.new("Wire")
							wire.SourceInstance = v301[1]
							wire.TargetInstance = v301[2]
							wire.Parent = v301[1]
						end

						chain = {
							player = headBlockPlayer,
							lp = headBlockCeiling,
							t0 = -1,
							v = flat
						}
						headshot.chain = chain
						table.insert(v11, function()
							if chain.t0 < 0 then
								return
							end

							local v301 = os.clock() - chain.t0
							local v302 = math.clamp((v301 - block.hold) / block.sweep, 0, 1)
							chain.lp.Frequency = block.ceil * (block.sweepTo / block.ceil) ^ v302
							local v303 = math.clamp(1 - (v301 - block.hold) / block.fade, 0, 1)
							chain.player.Volume = 0.85 * headshot.gain * block.volume * v303

							if v303 <= 0 then
								chain.player:Stop()
								chain.t0 = -1
								AudioGraph.park(chain.v)
							end
						end)
					end

					local player = chain.player

					if player.IsPlaying then
						player:Stop()
					end

					player.PlaybackRegion = NumberRange.new(block.from, block.to)
					player.PlaybackSpeed = block.speed
					player.TimePosition = block.from
					player.Volume = 0.85 * headshot.gain * block.volume
					chain.lp.Frequency = block.ceil
					AudioGraph.route(chain.v, "ui")
					player:Play()
					chain.t0 = os.clock()

					for _, ping in headshot.pings do
						later(ping.at, function()
							for _, slice2 in ping.slices do
								local v301 = v295
								local v302 = 0.85 * headshot.gain
								local speed = ping.speed
								local length = ping.length
								local fade = ping.fade
								local voice = v301.voices[v301.next]
								v301.next = v301.next % #v301.voices + 1
								startVoice(voice, slice2, v302, speed, "ui", 10000, length, fade, 10, nil)
							end
						end)
					end
				end

				function VoxelSound.ui(p: string, value: number?)
					assert(v299[p], "[VoxelSound] unknown ui sound " .. tostring(p))
					local now = os.clock()

					if p == "hit" or p == "headshot" then
						if now - v296 < 0.045 then
							return
						end

						v296 = now
						local v300 = VoxelSound.HIT_SOUNDS[VoxelSound.HIT_SOUNDS.pick]

						if type(v300) == "table" then
							local slice2 = v300.slice
							local gain = v300.gain
							local length = v300.length
							ringFire( -- inferred equivalent call
								v294,
								slice2,
								gain * 0.55,
								math.min(0.97 + 0.030000000000000027 * math.random(), 1),
								"ui",
								length,
								0.04
							)
						else
							ringFire( -- inferred equivalent call
								v294,
								draw(v287),
								0.33,
								math.min(0.94 + 0.06000000000000005 * math.random(), 1),
								"ui",
								0.12,
								0.04
							)
						end

						if p == "headshot" then
							ringFire( -- inferred equivalent call
								v294,
								draw(v288),
								0.275,
								math.min(0.92 + 0.07999999999999996 * math.random(), 1),
								"ui",
								0.22,
								0.04
							)
						end
					elseif p == "kill" or p == "headshotkill" then
						v296 = now
						local v300 = p == "headshotkill"
						v298 = now
						local v301 = v291

						local v302 = 1
						local v303 = 0.85
						local v304 = 0.06
						local v305 = 0.7
						local function burst()
							ringFire(v295, v301, v302 * 0.85, v303, "ui", v304, 0.12, nil, 400) -- inferred equivalent call

							if v305 > 0 then
								ringFire(v295, v301, v305 * 0.85, v303, "ui", 0.38, 0.1, nil, 1000) -- inferred equivalent call
							end
						end

						ringFire(v295, v301, 0.85, 0.85, "ui", 0.06, 0.12, nil, 400) -- inferred equivalent call
						ringFire(v295, v301, 0.595, 0.85, "ui", 0.38, 0.1, nil, 1000) -- inferred equivalent call
						local v306 = VoxelSound.KILL_RINGS[VoxelSound.KILL_RINGS.pick]

						if v306 then
							local v307 = math.ceil(v306.gain / 3)

							for _ = 1, v307 do
								later(0.03, function()
									ringFire( -- inferred equivalent call
										v295,
										v306.slice,
										0.85 * v306.gain / v307,
										1,
										"ui",
										v306.hold,
										v306.fade,
										nil,
										v306.hp
									)
								end)
							end
						end

						if v300 then
							if VoxelSound.HEADSHOT.pick == "new" then
								VoxelSound.HEADSHOT.play()
							else
								headSpray()
							end
						end

						local v307 = draw(v287)
						local v308 = v300 and 0.8 or 0.7
						local v309 = v295
						local v311

						if v309 then
							v311 = v308 * 0.85
						else
							v311 = v308 * 0.55
						end

						ringFire( -- inferred equivalent call
							v309 or v294,
							v307,
							v311,
							math.min(0.94 + 0.06000000000000005 * math.random(), 1),
							"ui",
							0.12,
							0.04
						)

						local v312 = v289
						local v314 = v295 or v294
						local v315 = v295 and 0.68 or 0.44000000000000006
						local v316 = 0.8
						local v317 = 0.85
						local v318 = 0.2
						local v319 = nil
						later(0.01, function()
							ringFire(v314, v312, v315, pitch(v316, v317), "ui", v318, 0.04, nil, v319) -- inferred equivalent call
						end)

						local v320 = v290
						local v322 = v295 or v294
						local v323 = v295 and 0.2975 or 0.1925
						local v324 = 0.7
						local v325 = 0.75
						local v326 = 0.4
						local v327 = nil
						later(0.015, function()
							ringFire(v322, v320, v323, pitch(v324, v325), "ui", v326, 0.04, nil, v327) -- inferred equivalent call
						end)
					elseif p == "multikill" then
						v298 = now
						local v300 = v291

						local v301 = 0.8
						local v302 = 0.7989999999999999
						local v303 = 0.05
						local v304 = 0.5
						local function burst()
							ringFire(v295, v300, v301 * 0.85, v302, "ui", v303, 0.12, nil, 400) -- inferred equivalent call

							if v304 > 0 then
								ringFire(v295, v300, v304 * 0.85, v302, "ui", 0.38, 0.1, nil, 1000) -- inferred equivalent call
							end
						end
						later(0.08, burst)

						local v305 = v289
						local v307 = v295 or v294
						local v308 = v295 and 0.68 or 0.44000000000000006
						local v309 = 0.72
						local v310 = 0.76
						local v311 = 0.2
						local v312 = nil
						later(0.08, function()
							ringFire(v307, v305, v308, pitch(v309, v310), "ui", v311, 0.04, nil, v312) -- inferred equivalent call
						end)
					elseif p == "points" then
						if now - v297 < 0.12 then
							return
						end

						v297 = now
						local v300 = math.clamp((value or 10) / 100, 0, 1)
						ringFire( -- inferred equivalent call
							v294,
							draw(v293),
							(v300 * 0.3 + 0.45) * 0.55,
							math.min(0.9 + 0.09999999999999998 * math.random(), 1),
							"ui",
							0.16,
							0.04
						)
					end
				end
			end

			do
				local v300 = {
					tick = gslice(9113880475, 0, 0.125, 4),
					tone = gslice(9117060347, 0, 0.32, 3.2),
					fallSpeed = 0.58,
					fallGain = 1.3,
					fallReach = 35,
					fallWithin = 140
				}

				function VoxelSound.designator(p: string)
					if p == "tick" then
						ringFire( -- inferred equivalent call
							v294,
							v300.tick,
							0.24750000000000003,
							math.min(0.84 + 0.020000000000000018 * math.random(), 1),
							"ui",
							0.125,
							0.02
						)
					elseif p == "lock" then
						ringFire(v294, v300.tick, 0.33, 1, "ui", 0.125, 0.02) -- inferred equivalent call
					elseif p == "bad" then
						ringFire(v294, v300.tick, 0.165, 0.62, "ui", 0.125, 0.02) -- inferred equivalent call
					else
						if p ~= "call" then
							error("[VoxelSound] unknown designator sound " .. tostring(p))

							return
						end

						ringFire(v294, v300.tone, 0.22000000000000003, 0.8, "ui", 0.14, 0.03) -- inferred equivalent call
						later(0.19, function()
							ringFire(v294, v300.tone, 0.22000000000000003, 0.8, "ui", 0.14, 0.03) -- inferred equivalent call
						end)
					end
				end
				function VoxelSound.bombFall(vector3: Vector3, p: number)
					if (vector3 - camPos()).Magnitude / meter > v300.fallWithin then -- inferred equivalent call
						return
					end

					local v301 = draw(v212)
					local v302 = (v301.peak or 0.5) / v300.fallSpeed
					local function start()
						local v303 = camPos() -- inferred equivalent call
						local magnitude = (vector3 - v303).Magnitude
						local v304 = math.max(magnitude / meter, 1)
						local v305 = occluded(vector3, v303, magnitude)

						local v306 = 1
						local v307 = airCutoff(v304 / 1) -- inferred equivalent call

						if v305 then
							v306 *= 0.55
							v307 = math.min(v307, 900)
						end

						if v13 > 0 and v304 > 15 then
							v306 *= 1 - v13 * 0.45
							v307 = math.max(v307 * (1 - v13 * 0.6), 700)
						end

						local v308 = v300.fallGain * math.min(1, v300.fallReach / v304) * v306
						emitAt(
							v301,
							vector3,
							v308,
							v300.fallSpeed * math.min(0.95 + 0.050000000000000044 * math.random(), 1),
							"dry",
							v307,
							v302 + 0.15,
							0.1,
							v308
						)
					end
					later(math.max(p - v302, 0), start)
				end
			end

			do
				local v301 = {
					tone = gslice(9117060347, 0, 0.32, 3.2),
					enemyGain = 0.55,
					friendGain = 0.35,
					bed = {
						id = "rbxassetid://9112795295",
						from = 2,
						to = 60,
						volume = { 0.5, 1.4 },
						speed = { 0.8, 0.95 },
						lp = 900
					},
					roar = {
						id = "rbxassetid://9113201103",
						from = 20,
						to = 24,
						volume = { 0, 2.2 },
						speed = { 0.5, 0.62 },
						lp = 2500
					},
					fadeIn = 1.5,
					fadeOut = 0.25,
					glide = 3,
					gain = 1
				}

				local function loopVoice(p: string, spec)
					local flat = AudioGraph.flat(p, true)
					AudioGraph.route(flat, "dry")
					AudioGraph.lowpass(flat, spec.lp)
					local audioPlayer = Instance.new("AudioPlayer")
					audioPlayer.Name = p .. "Player"
					audioPlayer.AutoLoad = true
					audioPlayer.Asset = spec.id
					audioPlayer.Looping = true
					audioPlayer.PlaybackRegion = NumberRange.new(spec.from, spec.to)
					audioPlayer.LoopRegion = NumberRange.new(spec.from, spec.to)
					audioPlayer.Volume = 0
					audioPlayer.Parent = flat.filter.Parent
					local wire = Instance.new("Wire")
					wire.SourceInstance = audioPlayer
					wire.TargetInstance = flat.filter
					wire.Parent = audioPlayer
					AudioGraph.park(flat)
					return { player = audioPlayer, spec = spec, v = flat }
				end

				local v302 = { loopVoice("HellfireRumbleBed", v301.bed), loopVoice("HellfireRumbleRoar", v301.roar) }
				local v303 = {
					on = false,
					k = 0,
					shown = 0,
					level = 0,
					last = 0
				}

				function VoxelSound.hellfireAlert(flag: boolean)
					if flag then
						for i = 0, 5 do
							later(i * 0.15, function()
								ringFire( -- inferred equivalent call
									v294,
									v301.tone,
									0.55 * v301.enemyGain,
									i % 2 == 0 and 0.6 or 0.5,
									"ui",
									0.11,
									0.02
								)
							end)
						end
					else
						ringFire(v294, v301.tone, 0.55 * v301.friendGain, 0.6, "ui", 0.14, 0.03) -- inferred equivalent call
						later(0.26, function()
							ringFire(v294, v301.tone, 0.55 * v301.friendGain, 0.5, "ui", 0.14, 0.03) -- inferred equivalent call
						end)
					end
				end

				function VoxelSound.aaBeep(p: number, p2: number)
					ringFire(v294, v301.tone, p2 * 0.55, math.min(p, 1), "ui", 0.09, 0.015) -- inferred equivalent call
				end

				function VoxelSound.fireAlarm(flag: boolean, p: number)
					local v304 = v294
					local tone = v301.tone
					local v305 = p * 0.55
					local voice = v304.voices[v304.next]
					v304.next = v304.next % #v304.voices + 1
					startVoice(voice, tone, v305, flag and 0.44 or 0.35, "ui", 20000, 0.27, 0.04, 10, nil)
				end

				do
					local v304 = nil
					function VoxelSound.aaTone(flag: boolean)
						if flag and not v304 then
							v304 = loopVoice("AALockTone", {
								id = "rbxassetid://9117060347",
								from = 0.04,
								to = 0.2,
								lp = 4000
							})
							v304.player.PlaybackSpeed = 0.7
							v304.player.Volume = 0.5
						end

						if v304 then
							if flag then
								AudioGraph.route(v304.v, "ui")

								if not v304.player.IsPlaying then
									v304.player:Play()
								end
							else
								v304.player:Stop()
								AudioGraph.park(v304.v)
							end
						end
					end
				end

				function VoxelSound.hellfireRumble(shown: number?)
					if not shown then
						v303.on = false

						return
					end

					if not v303.on then
						v303.on = true
						v303.shown = shown

						for _, v305 in v302 do
							local player = v305.player
							AudioGraph.route(v305.v, "dry")

							if player.IsPlaying then
								continue
							end

							player.TimePosition = v305.spec.from + math.random() * (v305.spec.to - v305.spec.from)
							player:Play()
						end
					end

					v303.k = math.clamp(shown, 0, 1)
				end

				table.insert(v11, function(p)
					if not v303.on and v303.level <= 0 then
						return
					end

					if v303.on then
						v303.level = math.min(1, v303.level + p / v301.fadeIn)
					else
						v303.level = math.max(0, v303.level - p / v301.fadeOut)
					end

					v303.shown += (v303.k - v303.shown) * math.min(1, p * v301.glide)
					local shown = v303.shown

					for k, v306 in v302 do
						local spec = v306.spec
						local v307

						if k == 1 then
							v307 = shown
						else
							v307 = shown * shown
						end

						v306.player.Volume = v301.gain * v303.level * (spec.volume[1] + (spec.volume[2] - spec.volume[1]) * v307)
						v306.player.PlaybackSpeed = math.min(spec.speed[1] + (spec.speed[2] - spec.speed[1]) * shown, 1)

						if not (v303.level <= 0) then
							continue
						end

						v306.player:Stop()
						AudioGraph.park(v306.v)
					end
				end)
			end

			function VoxelSound.gunStats()
				return table.clone(v5)
			end

			v26 = v.Heartbeat
			v = require
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			v26:Connect(v(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("Detail")).timed("sound", function(p)
				local now = os.clock()
				v17 = 2
				v18 = 8
				v8 = math.max(v8 - 20 * p, -120)
				v22 = math.max(v22 - v22 * 0.04 * p - 0.002 * p, 0)
				debug.profilebegin("VS.jobs")
				local v305 = 1

				while v305 <= #v9 do
					local v306 = v9[v305]

					if v306.at <= now then
						v9[v305] = v9[#v9]
						v9[#v9] = nil
						table.insert(v10, v306)
						v306.fn(v306.a, v306.b, v306.c, v306.d, v306.e)
					else
						v305 += 1
					end
				end

				debug.profileend()
				debug.profilebegin("VS.faders")

				for i = #v4, 1, -1 do
					local v306 = v4[i]

					if v306.stopAt <= now then
						local v307 = not (v306.fade > 0) and 0 or 1 - (now - v306.stopAt) / v306.fade

						if v307 <= 0 or v306.busyUntil <= now then
							release(v306) -- inferred equivalent call
							v306.stopAt = 1e999
							v306.busyUntil = now
						elseif v306.sp then
							v306.sp.player.Volume = v306.volume * v307
						end
					elseif v306.busyUntil + 0.5 <= now then
						AudioGraph.park(v306.v)

						if v306.stopAt == 1e999 then
							v306.listed = false
							v4[i] = v4[#v4]
							v4[#v4] = nil
						end
					end
				end

				debug.profileend()
				AudioGraph.step(now)
				fireStep()
				rocketStep(now)
				jetStep(now)
				VoxelSound.minigunStep(now, p)
				concussionStep(p)
				local v306 = now - v298 - 0.1

				if v306 < 0.55 then
					local setDuck = AudioGraph.setDuck
					local v307

					if v306 < 0 then
						v307 = 0.45
					else
						v307 = smoothstep(0, 0.45, v306) * 0.55 + 0.45 -- inferred equivalent call
					end

					setDuck(v307)
				end

				for _, v307 in v11 do
					v307(p)
				end
			end))
		end

		do
			local function build()
				local Players = game:GetService("Players")
				local localPlayer = Players.LocalPlayer

				local function cuts(items)
					local items2 = {}

					for k, item in items do
						local v306 = gslice(item[1], item[2], item[3], item[4]) -- inferred equivalent call
						v306.speed = item[5]
						items2[k] = v306
					end

					return bagOf(items2)
				end

				local function reach3(reach4: number, p: number) -- 1 equivalent call inferred from this helper
					local v305 = 10 ^ (math.max(p - 100, 0) * -1.5 / 100 / 20)
					return math.min(1, reach4 / p) ^ 0.75 * v305
				end

				local v305 = {
					magOut = cuts({
						{ 9116342102, 0.001, 0.028, 12.46, 1 },
						{ 9116342621, 0, 0.031, 13.65, 1 },
						{ 9116341918, 0.279, 0.312, 11.11, 1 }
					}),
					magIn = cuts({
						{ 9116341721, 0, 0.077, 6.41, 1 },
						{ 9116342124, 1.729, 1.786, 5.75, 1 },
						{ 9116342222, 3.103, 3.143, 7.71, 1 },
						{ 9116342634, 0, 0.051, 8.59, 1 }
					}),
					boltRelease = cuts({
						{ 9116342002, 1.076, 1.189, 5.89, 1 },
						{ 9116342790, 2.68, 2.734, 4.73, 1 },
						{ 9116341934, 1.127, 1.199, 5.34, 1 }
					}),
					chargeBack = cuts({
						{ 9116342102, 0.149, 0.23, 24.11, 1 },
						{ 9116342124, 1.064, 1.142, 12.28, 1 },
						{ 9116341726, 1.154, 1.238, 16.83, 1 },
						{ 9116342790, 1.693, 1.761, 13.65, 1 }
					})
				}

				local pistol = {
					magOut = cuts({
						{ 9113104509, 0.828, 0.852, 6, 1 },
						{ 9117399357, 0.229, 0.248, 12.26, 1 },
						{ 9117399110, 2.096, 2.116, 4.56, 1 }
					}),
					magIn = cuts({
						{ 9113104208, 0.012, 0.046, 1.61, 1 },
						{ 9113104337, 0.007, 0.044, 1.36, 1 },
						{ 9117396164, 0.867, 0.946, 5.13, 1 }
					}),
					slideRelease = cuts({
						{ 9117396777, 0, 0.069, 6.98, 1 },
						{ 9117396968, 0.003, 0.065, 6.31, 1 },
						{ 9117396716, 0.724, 0.797, 12.62, 1 }
					}),
					slideBack = cuts({
						{ 9117396530, 0.013, 0.081, 6.62, 1 },
						{ 9117396716, 0.006, 0.049, 6.24, 1 },
						{ 9117396820, 0.141, 0.203, 16.8, 1 }
					})
				}

				local v307 = {
					rifle = v305,
					smg = {
						magOut = cuts({
							{ 9114702116, 0.063, 0.091, 1.61, 1 },
							{ 9114702952, 0.694, 0.739, 1.91, 1 },
							{ 9114702107, 0.002, 0.045, 1.13, 1 }
						}),
						magIn = cuts({
							{ 9113104358, 0.79, 0.823, 2.62, 1 },
							{ 9113104517, 0.228, 0.26, 1.2, 1 },
							{ 9114704066, 1.006, 1.062, 1.43, 1 },
							{ 9114704242, 1.237, 1.298, 1.54, 1 }
						}),
						boltRelease = cuts({
							{ 9116344648, 0.281, 0.313, 7.84, 1 },
							{ 9116344663, 0.041, 0.077, 8.92, 1 },
							{ 9116344869, 0.421, 0.454, 7.04, 1 },
							{ 9116345181, 1.348, 1.427, 7.13, 1 },
							{ 9116345318, 0.957, 1.026, 7.22, 1 }
						}),
						chargeBack = cuts({
							{ 9116344648, 0, 0.069, 16.28, 1 },
							{ 9116344869, 0.023, 0.064, 17.53, 1 }
						})
					},
					dmr = {
						magOut = cuts({
							{ 9117889370, 0.44, 0.475, 10.02, 0.9 },
							{ 9117889466, 0.963, 1.008, 19.55, 0.9 },
							{ 9117888960, 4.338, 4.366, 16.57, 0.9 },
							{ 9117888652, 0, 0.05, 13.3, 0.9 }
						}),
						magIn = cuts({
							{ 9117889701, 1.245, 1.345, 6.74, 0.9 },
							{ 9117889819, 1.025, 1.12, 6.49, 0.9 },
							{ 9117889843, 1.045, 1.11, 7.66, 0.9 },
							{ 9117888960, 3.463, 3.502, 4.78, 0.9 }
						}),
						boltRelease = cuts({
							{ 9117889138, 2.675, 2.734, 5.04, 0.9 },
							{ 9117888652, 0.052, 0.106, 7.42, 0.9 },
							{ 9117888960, 2.163, 2.209, 15.11, 0.9 }
						}),
						chargeBack = cuts({
							{ 9117889701, 2.505, 2.579, 27.28, 0.9 },
							{ 9117889597, 1.985, 2.03, 33.53, 0.9 },
							{ 9117889370, 1.938, 1.988, 31.7, 0.9 }
						})
					},
					lmg = {
						boxDrop = true,
						magOut = cuts({
							{ 9116344380, 2.253, 2.408, 3.74, 1 },
							{ 9116344380, 2.908, 3.023, 3.76, 1 },
							{ 9116344222, 1.135, 1.198, 4.75, 1 },
							{ 9116343842, 1.731, 1.814, 5.07, 1 }
						}),
						magIn = cuts({
							{ 9116339375, 2.598, 2.658, 5.83, 0.9 },
							{ 9116339557, 1.916, 2.029, 5.32, 0.9 },
							{ 9116340490, 0.257, 0.322, 6, 0.9 },
							{ 9116339145, 5.351, 5.402, 5.78, 0.9 },
							{ 9116340489, 4.691, 4.798, 5.51, 0.9 }
						}),
						chargeBack = cuts({
							{ 9116357621, 0.018, 0.061, 4.98, 1 },
							{ 9116357348, 0.249, 0.292, 5.04, 1 },
							{ 9116357383, 0.232, 0.306, 3.46, 1 },
							{ 9116357348, 0.122, 0.162, 9.22, 1 },
							{ 9116357383, 0.195, 0.227, 4, 1 }
						}),
						boltRelease = cuts({
							{ 9116357355, 0.092, 0.188, 1.69, 0.9 },
							{ 9116357621, 0.095, 0.14, 1.33, 0.9 },
							{ 9116357383, 0.46, 0.498, 10.63, 0.9 }
						}),
						boxDropTakes = cuts({
							{ 9125584819, 0.028, 0.115, 0.92, 1 },
							{ 9113589156, 0.039, 0.098, 1.29, 1 },
							{ 9113589156, 0.664, 0.733, 2.2, 1 },
							{ 9113589166, 0.143, 0.186, 1.73, 1 }
						})
					},
					pistol = pistol,
					magnum = {
						magOut = pistol.magOut,
						magIn = pistol.magIn,
						slideRelease = pistol.slideRelease,
						slideBack = pistol.slideBack,
						speedMul = 0.9
					},
					sniper = {
						magOut = cuts({
							{ 9116331838, 2.19, 2.217, 14.19, 1 },
							{ 9116331491, 0, 0.044, 13.32, 1 },
							{ 9113177277, 6.43, 6.46, 21.64, 1 }
						}),
						magIn = cuts({
							{ 9116331500, 0.724, 0.765, 3.73, 1 },
							{ 9116331362, 0.682, 0.713, 7.55, 1 },
							{ 9116331540, 0.848, 0.891, 9.51, 1 },
							{ 9113177277, 8.173, 8.224, 12.61, 1 }
						}),
						click = { stage = "magIn", from = v305, after = 0.03, level = 0.45 }
					}
				}

				local v308 = ring("Reload", 4)

				local v309 = { 0.9, 1.1 }

				local function reloadPlay(p, p2: string, p3: number, speedMul: number)
					local v310 = p[p2]

					if not v310 then
						error("[VoxelSound] reload: no " .. p2 .. " takes for this family")
					end

					local v311 = draw(v310)
					ringFire( -- inferred equivalent call
						v308,
						v311,
						p3 * 0.5 * jitter(), -- inferred equivalent call
						(v311.speed or 1) * speedMul * math.min(0.97 + 0.030000000000000027 * math.random(), 1),
						"dry",
						1e999,
						0.02,
						9000
					)
				end

				function VoxelSound.reload(p: string, p2: string, p3: number)
					local v310 = v307[p]

					if not v310 then
						error("[VoxelSound] reload: unknown family " .. tostring(p))
					end

					reloadPlay(v310, p2, p3, v310.speedMul or 1)

					if p2 == "magOut" and v310.boxDrop then
						later(
							v309[1] + math.random() * (v309[2] - v309[1]),
							reloadPlay,
							v310,
							"boxDropTakes",
							p3 * 0.55,
							1
						)
					end

					local click = v310.click

					if click and click.stage == p2 then
						later(click.after, reloadPlay, click.from, p2, p3 * click.level, 1)
					end
				end

				local v310 = {
					small = {
						bag = cuts({
							{ 9113631432, 0.312, 0.552, 13.33, 0.85 },
							{ 9113631587, 0, 0.35, 10.25, 0.85 },
							{ 9113631202, 0, 0.3, 10.69, 0.85 },
							{ 9113631584, 0, 0.45, 11.31, 0.85 },
							{ 9113631067, 0.32, 0.62, 31.67, 0.85 },
							{ 9113631069, 0.24, 0.52, 26.53, 0.85 },
							{ 9113631210, 0.15, 0.52, 24.09, 0.85 }
						}),
						cutoff = 7000,
						level = 1
					},
					pistol = {
						bag = cuts({
							{ 9113631063, 0, 0.36, 16.4, 0.85 },
							{ 9113631210, 0.15, 0.52, 24.09, 0.85 },
							{ 9113631587, 0, 0.35, 10.25, 0.85 },
							{ 9113631202, 0, 0.3, 10.69, 0.85 }
						}),
						cutoff = 7000,
						level = 0.9
					},
					large = {
						bag = cuts({
							{ 9113111356, 0.308, 1.02, 6.39, 0.9 },
							{ 9113633086, 0.408, 0.55, 8.61, 0.9 }
						}),
						cutoff = 7000,
						level = 1.15
					},
					shotgun = {
						bag = cuts({
							{ 9119116825, 0.227, 0.283, 13.16, 1 },
							{ 9119116825, 0.06, 0.095, 12.46, 1 },
							{ 9119116825, 0.396, 0.448, 15.11, 1 },
							{ 9119116310, 0.48, 0.592, 21.6, 1 }
						}),
						cutoff = 6000,
						level = 1.1
					}
				}

				local set = {
					[Enum.Material.Grass] = true,
					[Enum.Material.LeafyGrass] = true,
					[Enum.Material.Ground] = true,
					[Enum.Material.Mud] = true,
					[Enum.Material.Sand] = true,
					[Enum.Material.Snow] = true,
					[Enum.Material.Salt] = true,
					[Enum.Material.Fabric] = true
				}

				local v311 = { Sniper = true, RX10 = true, SC11 = true, VX50 = true }

				local v312 = {
					small = {
						size = Vector3.new(0.11, 0.11, 0.32),
						color = Color3.fromRGB(196, 158, 84)
					},
					pistol = {
						size = Vector3.new(0.1, 0.1, 0.22),
						color = Color3.fromRGB(196, 158, 84)
					},
					large = {
						size = Vector3.new(0.14, 0.14, 0.5),
						color = Color3.fromRGB(196, 158, 84)
					},
					shotgun = {
						size = Vector3.new(0.18, 0.18, 0.42),
						color = Color3.fromRGB(170, 40, 34)
					}
				}

				local CaseDrop = require(script.Parent:WaitForChild("CaseDrop"))
				local v313 = ring("Casing", 10)
				local v314 = 0
				local v315 = 0

				local v316 = {}

				local function surfaceOf(value): nil | string
					if type(value) == "number" then
						local v317 = Materials.Palette[value]

						if v317 == nil or v317.type.name ~= "soil" then
							return "hard"
						end

						return "soft"
					end

					if value == Enum.Material.Water then
						return nil
					end

					return if set[value] then "soft" else "hard"
				end

				local function ownLand(kind: string, value)
					local v317

					if type(value) == "number" then
						local v318 = Materials.Palette[value]
						v317 = (v318 == nil or v318.type.name ~= "soil") and "hard" or "soft"
					else
						v317 = value ~= Enum.Material.Water and (set[value] and "soft" or "hard") or nil
					end

					if not v317 then
						return
					end

					local v318 = v310[kind]
					local v319 = draw(v318.bag)
					local v320 = 0.05 * v318.level * jitter() -- inferred equivalent call
					local v321 = (v319.speed or 1) * math.min(0.96 + 0.040000000000000036 * math.random(), 1)
					local v322 = (v319.to - v319.from) / v321 - 0.06
					local v323

					if v317 == "soft" then
						v323 = math.min(v318.cutoff, 5500)
					else
						v323 = v318.cutoff
					end

					ringFire(v313, v319, v320, v321, "dry", v322, 0.06, v323) -- inferred equivalent call
				end

				local function ownFallback(state)
					if state.done then
						return
					end

					state.done = true
					local humanoid = localPlayer
						and localPlayer.Character
						and localPlayer.Character:FindFirstChildOfClass("Humanoid")
					local v317

					if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
						v317 = humanoid.FloorMaterial
					else
						v317 = Enum.Material.Concrete
					end

					ownLand(state.kind, v317)
				end

				function CaseDrop.ownLanded(p)
					local now = os.clock()

					while v316[1] and (v316[1].done or now - v316[1].at > 2.5) do
						table.remove(v316, 1)
					end

					local v317 = table.remove(v316, 1)

					if v317 then
						v317.done = true
						ownLand(v317.kind, p)
					end
				end

				function VoxelSound.casing(kind: string, value: number?)
					assert(v310[kind], "[VoxelSound] casing: unknown kind " .. tostring(kind))
					local now = os.clock()

					if now - v314 < 0.075 then
						return
					end

					local humanoid = localPlayer
						and localPlayer.Character
						and localPlayer.Character:FindFirstChildOfClass("Humanoid")

					if not humanoid or humanoid.SeatPart then
						return
					end

					v314 = now
					local v317 = { kind = kind, at = now, done = false }
					table.insert(v316, v317)

					if #v316 > 24 then
						table.remove(v316, 1)
					end

					later((value or 0) + 1.1, ownFallback, v317)
				end

				local function otherLand(vector3: Vector3, value, p: string)
					local v317

					if type(value) == "number" then
						local v318 = Materials.Palette[value]
						v317 = (v318 == nil or v318.type.name ~= "soil") and "hard" or "soft"
					else
						v317 = value ~= Enum.Material.Water and (set[value] and "soft" or "hard") or nil
					end

					if not v317 then
						return
					end

					local v318 = camPos() -- inferred equivalent call
					local magnitude = (vector3 - v318).Magnitude
					local v319 = math.max(magnitude / meter, 0.5)
					local v320 = occluded(vector3, v318, magnitude)

					local v321 = 1
					local v322 = airCutoff(v319 / 1) -- inferred equivalent call

					if v320 then
						v321 *= 0.55
						v322 = math.min(v322, 900)
					end

					if v13 > 0 and v319 > 15 then
						v321 *= 1 - v13 * 0.45
						v322 = math.max(v322 * (1 - v13 * 0.6), 700)
					end

					local v323 = v310[p]
					local v324 = draw(v323.bag)
					local v325 = 0.05 * v323.level * math.min(1, 2 / v319) * v321 * jitter() -- inferred equivalent call
					local v326 = (v324.speed or 1) * math.min(0.96 + 0.040000000000000036 * math.random(), 1)
					local v328

					if v317 == "soft" then
						v328 = math.min(v323.cutoff, 5500)
					else
						v328 = v323.cutoff
					end

					emitAt(
						v324,
						vector3,
						v325,
						v326,
						"dry",
						math.min(v322, v328),
						(v324.to - v324.from) / v326 - 0.06,
						0.06,
						v325
					)
				end

				local function otherThrow(vector3: Vector3, p: string)
					if CaseDrop.on() then
						local v317 = v312[p]
						local v318 = math.random() * 2 * 3.141592653589793
						local vector3_2 = Vector3.new(math.cos(v318) * 4, 3 + math.random() * 2, math.sin(v318) * 4)
						CaseDrop.throw(
							vector3,
							vector3_2,
							CFrame.Angles(math.random() * 6.28, math.random() * 6.28, 0),
							v317.size,
							v317.color,
							function(vector3_3: Vector3, p2)
								later((vector3_3 - camPos()).Magnitude / meter / 343, otherLand, vector3_3, p2, p) -- inferred equivalent call
							end
						)
					else
						local ground, v317 = CaseDrop.ground(vector3)

						if ground then
							later(0.5 + (ground - camPos()).Magnitude / meter / 343, otherLand, ground, v317, p) -- inferred equivalent call
						end
					end
				end

				function VoxelSound.otherCasing(vector3: Vector3, p: string?)
					if (vector3 - camPos()).Magnitude / meter > 10 then -- inferred equivalent call
						return
					end

					local now = os.clock()

					if now - v315 < 0.075 then
						return
					end

					v315 = now
					local v317 = "small"
					local v318 = 0

					if p and v311[p] then
						v318 = 0.85 + 0.1 * math.random()
						v317 = "large"
					elseif p == "DMR" then
						v317 = "large"
					elseif p == "Shotgun" then
						v318 = 0.3
						v317 = "shotgun"
					elseif p == "Pistol" or p == "HandCannon" then
						v317 = "pistol"
					end

					later(v318, otherThrow, vector3, v317)
				end

				local v317 = {
					POPS = cuts({
						{ 9116971425, 6.85, 7.24, 3.86, 1 }
					}),
					POP = cuts({
						{ 9116971724, 6.47, 6.64, 3.92, 1 }
					}),
					WHUMP = cuts({
						{ 9117983322, 0.27, 0.8, 0.63, 1 }
					}),
					FIZZ = cuts({
						{ 9118591176, 0.55, 1.45, 3.17, 1 }
					}),
					GAIN = 0.55,
					REACH = 30,
					WITHIN = 450
				}

				local function flaresArrive(vector3: Vector3)
					local v318 = camPos() -- inferred equivalent call
					local magnitude = (vector3 - v318).Magnitude
					local v319 = math.max(magnitude / meter, 1)
					local v320 = occluded(vector3, v318, magnitude)

					local v321 = 1
					local v322 = airCutoff(v319 / 1.5) -- inferred equivalent call

					if v320 then
						v321 *= 0.55
						v322 = math.min(v322, 1102.27038425243)
					end

					if v13 > 0 and v319 > 15 then
						v321 *= 1 - v13 * 0.45
						v322 = math.max(v322 * (1 - v13 * 0.6), 700)
					end

					local v323 = v317.GAIN * reach3(v317.REACH, v319) * v321 * jitter() -- inferred equivalent call
					emitAt(
						draw(v317.POPS),
						vector3,
						v323,
						math.min(0.94 + 0.06000000000000005 * math.random(), 1),
						"dry",
						v322,
						1e999,
						0,
						v323 + 2
					)
					emitAt(
						draw(v317.WHUMP),
						vector3,
						0.6 * v323,
						math.min(0.9 + 0.05999999999999994 * math.random(), 1),
						"dry",
						math.min(v322, 2500),
						1e999,
						0,
						v323 + 1
					)
					later(0.42 + 0.05 * math.random(), function()
						emitAt(
							draw(v317.POP),
							vector3,
							0.7 * v323,
							math.min(0.94 + 0.06000000000000005 * math.random(), 1),
							"dry",
							v322,
							0.13,
							0.04,
							v323 + 1
						)
					end)
					later(0.18, function()
						emitAt(
							draw(v317.FIZZ),
							vector3,
							0.45 * v323,
							math.min(0.92 + 0.07999999999999996 * math.random(), 1),
							"dry",
							math.min(v322, 7000),
							1e999,
							0,
							v323
						)
					end)
				end
				function VoxelSound.flares(vector3: Vector3)
					local v318 = (vector3 - camPos()).Magnitude / meter -- inferred equivalent call

					if v317.WITHIN < v318 then
						return
					end

					later(v318 / 343, flaresArrive, vector3)
				end

				local v318 = cuts({
					{ 9116329922, 0.08, 1.45, 1.19, 1 }
				})
				local voices = {}

				voices[1] = newPoolVoice(AudioGraph.flat("DownSting" .. 1, true, nil)) -- inferred equivalent call
				AudioGraph.park(voices[1].v)

				local v320 = { voices = voices, next = 1 }

				local _ = { high = -30, mid = -20, low = -10 }
				local v321 = { high = -24, mid = -13, low = -6 }
				local v322 = { high = -18, mid = -8, low = -3 }

				local now = nil
				local v323 = nil
				local v324 = 0

				local function watch(instance)
					local lifeMuffle = VoxelSound.lifeMuffle

					if now then
						now = nil
						v323 = {
							high = lifeMuffle.high,
							mid = lifeMuffle.mid,
							low = lifeMuffle.low
						}
						v324 = os.clock()
					end

					local humanoid = instance:WaitForChild("Humanoid", 10)

					if humanoid and humanoid:IsA("Humanoid") then
						humanoid.Died:Connect(function()
							if instance ~= localPlayer.Character then
								return
							end

							now = os.clock()
							v323 = nil
							ringFire(v320, draw(v318), jitter() * 0.6, 1, "ui", 1e999, 0.15, 6000) -- inferred equivalent call
						end)
					end
				end

				if localPlayer then
					localPlayer.CharacterAdded:Connect(watch)

					if localPlayer.Character then
						task.spawn(watch, localPlayer.Character)
					end
				end

				table.insert(v11, function()
					local lifeMuffle = VoxelSound.lifeMuffle
					local now2 = os.clock()
					local high = 0
					local mid = 0
					local low = 0

					if now then
						local v328 = now2 - now
						local v329

						if localPlayer:GetAttribute("DownUntil") == nil then
							v329 = v322
						else
							v329 = v321
						end

						if v328 < 0.6 then
							local v330 = smoothstep(0, 0.6, v328) -- inferred equivalent call
							high = -30 * v330
							mid = -20 * v330
							low = -10 * v330
						else
							local v330 = smoothstep(2, 3.5, v328) -- inferred equivalent call
							high = -30 + (v329.high - -30) * v330
							mid = -20 + (v329.mid - -20) * v330
							low = -10 + (v329.low - -10) * v330
						end
					elseif v323 then
						local v328 = 1 - math.clamp((now2 - v324) / 0.1, 0, 1)
						high = v323.high * v328
						mid = v323.mid * v328
						low = v323.low * v328

						if v328 <= 0 then
							v323 = nil
						end
					end

					lifeMuffle.live = high ~= 0
						or mid ~= 0
						or low ~= 0
						or lifeMuffle.high ~= 0
						or lifeMuffle.mid ~= 0
						or lifeMuffle.low ~= 0
					lifeMuffle.high = high
					lifeMuffle.mid = mid
					lifeMuffle.low = low
				end)
			end
			build()
		end

		local v305 = { [items3[1].id] = 16 }

		v305[v161.thump.id] = 5
		v305[v161.boom.id] = 5
		v305[v161.bass.items[1].id] = 5

		do
			local LightHit = require(script.LightHit)

			for k, count2 in LightHit.counts do
				v305[k] = count2
			end
		end

		for _, v306 in v184 do
			for _, item in v306.own.items do
				v305[item.id] = v306.players
			end
		end

		for _, v306 in v27 do
			v305[v306.id] = 8
		end

		for _, voice in v166.voices do
			if not voice.players then
				continue
			end

			for _, item in voice.own.items do
				v305[item.id] = voice.players
			end
		end

		local function addSampler(p: string)
			local sampler = AudioGraph.sampler(p, v305[p] or math.clamp(v2[p], 2, 6))
			v6[p] = { players = sampler, owners = {} }
			local players = {}

			for _, v306 in sampler do
				table.insert(players, v306.player)
			end

			return players
		end

		local v306 = {}
		local v307 = {}

		for _, v308 in { VoxelSound.HIT_SOUNDS, VoxelSound.KILL_RINGS } do
			for k, v309 in v308 do
				if type(v309) == "table" and k ~= v308.pick then
					v306[v309.slice.id] = (v306[v309.slice.id] or 0) + 1
				end
			end

			local v309 = v308.pick
			v308.pick = nil
			setmetatable(v308, {
				__index = function(_, p)
					return if p == "pick" then v309 else nil
				end,
				__newindex = function(p, p2, p3)
					if p2 ~= "pick" then
						rawset(p, p2, p3)
						return
					end

					v309 = p3
					local v310 = rawget(p, p3)

					if type(v310) == "table" and not v6[v310.slice.id] then
						local v311 = addSampler(v310.slice.id)
						task.spawn(function()
							ContentProvider:PreloadAsync(v311)
						end)
					end
				end
			})
		end

		for k, v308 in v2 do
			if v306[k] == v308 then
				continue
			end

			for _, v309 in addSampler(k) do
				table.insert(v307, v309)
			end
		end

		task.spawn(function()
			local Players = game:GetService("Players")
			local localPlayer = Players.LocalPlayer

			while localPlayer and localPlayer:GetAttribute("JoinCovered") == true do
				localPlayer:GetAttributeChangedSignal("JoinCovered"):Wait()
			end

			local players = {}

			for _, v308 in v106 do
				table.insert(players, v308.v.player)
			end

			ContentProvider:PreloadAsync(players)
			ContentProvider:PreloadAsync(v307)
			task.wait(10)
			local assets = {}

			for _, v308 in v307 do
				if not v308.IsReady then
					table.insert(assets, v308.Asset)
				end
			end

			if #assets > 0 then
				warn(("[VoxelSound] %d of %d sample players not ready after loading: %s"):format(
					#assets,
					#v307,
					table.concat(assets, ", ", 1, (math.min(#assets, 8)))
				))
			end
		end)
	end

	function VoxelSound.addSamples(items, value: number?)
		local players = {}

		for _, item in items do
			local v22 = "rbxassetid://" .. item

			if v6[v22] then
				continue
			end

			local sampler = AudioGraph.sampler(v22, value or 3)
			v6[v22] = { players = sampler, owners = {} }

			for _, v23 in sampler do
				table.insert(players, v23.player)
			end
		end

		if #players > 0 then
			task.spawn(function()
				local Players = game:GetService("Players")
				local localPlayer = Players.LocalPlayer

				while localPlayer and localPlayer:GetAttribute("JoinCovered") == true do
					localPlayer:GetAttributeChangedSignal("JoinCovered"):Wait()
				end

				ContentProvider:PreloadAsync(players)
			end)
		end
	end

	do
		local v22 = {
			POP = bagOf({
				gslice(9113052419, 0, 0.413, 0.57),
				gslice(9113052104, 0, 0.414, 0.53),
				gslice(9116727645, 0.095, 1.296, 0.81)
			}),
			DIE = bagOf({ gslice(9120066422, 5.1, 5.74, 2.23), gslice(9120066581, 5.2, 5.78, 3.9) }),
			HISS_ID = "rbxassetid://9125353894",
			HISS_RANGE = NumberRange.new(12.85, 17.9),
			HISS_RAW = 25.32,
			POP_GAIN = 1,
			HISS_GAIN = 0.35,
			DIE_GAIN = 0.7,
			POP_REACH = 20,
			HISS_REACH = 10,
			WITHIN = 120,
			HISS_WITHIN = 60,
			OWN_FLOOR = 0.5,
			CUTOFF = 12500,
			FADE_IN = 0.15,
			FADE_OUT = 0.25,
			SLOTS = 4
		}

		VoxelSound.addSamples({ 9113052419, 9113052104, 9116727645, 9120066422, 9120066581 }, 2)

		do
			local function reach3(p: number, p2: number) -- 3 equivalent calls inferred from this helper
				local v23 = 10 ^ (math.max(p2 - 100, 0) * -1.5 / 100 / 20)
				return math.min(1, p / p2) ^ 0.75 * v23
			end
		end

		do
			local function popArrive(vector3: Vector3, flag: boolean?)
				local v23 = camPos() -- inferred equivalent call
				local magnitude = (vector3 - v23).Magnitude
				local v24 = math.max(magnitude / meter, 1)
				local v25 = occluded(vector3, v23, magnitude)

				local v26 = 1
				local v27 = airCutoff(v24 / 1.5) -- inferred equivalent call

				if v25 then
					v26 *= 0.55
					v27 = math.min(v27, 1102.27038425243)
				end

				if v13 > 0 and v24 > 15 then
					v26 *= 1 - v13 * 0.45
					v27 = math.max(v27 * (1 - v13 * 0.6), 700)
				end

				local v28 = reach3(v22.POP_REACH, v24) * jitter() * v26 -- inferred equivalent call

				if flag then
					v28 = math.max(v28, v22.OWN_FLOOR)
					v27 = math.max(v27, 6000)
					v8 = math.max(v8, 0)
				end

				local v29 = v22.POP_GAIN * v28
				emitAt(
					draw(v22.POP),
					vector3,
					v29,
					math.min(0.9 + 0.09999999999999998 * math.random(), 1),
					"dry",
					v27,
					1.4,
					0.02,
					v29 + 3
				)
			end

			function VoxelSound.smokePop(vector3: Vector3, flag: boolean?)
				local v23 = (vector3 - camPos()).Magnitude / meter -- inferred equivalent call

				if v22.WITHIN < v23 then
					return
				end

				later(v23 / 343, popArrive, vector3, flag)
			end
		end

		local v23 = {}

		do
			local v24 = {}

			for i = 1, v22.SLOTS do
				local positional = AudioGraph.positional("SmokeHiss" .. i, voxelSoundVoices)

				do
					local player = positional.player
					player.Asset = v22.HISS_ID
					player.Looping = true
					player.PlaybackRegion = v22.HISS_RANGE
					player.LoopRegion = v22.HISS_RANGE
					player.PlaybackSpeed = 1
					player.Volume = 0
				end

				AudioGraph.park(positional)
				v23[i] = {
					id = nil,
					pos = Vector3.new(0, 0, 0),
					level = 0,
					on = false,
					used = 0,
					voice = positional
				}
			end

			function VoxelSound.smokeHiss(id: number, pos: Vector3?)
				local v25 = v24[id]

				if pos then
					if not v25 then
						if (pos - camPos()).Magnitude / meter > v22.HISS_WITHIN then -- inferred equivalent call
							return
						end

						v25 = v23[1]

						for _, v26 in v23 do
							if v26.on or not (v26.level <= 0) then
								if v26.used < v25.used then
									v25 = v26
								end
							else
								v25 = v26
								break
							end
						end

						if v25.on and v25.id then
							v24[v25.id] = nil
						end

						local now = os.clock()
						v25.id = id
						v25.on = true
						v25.used = now

						if v25.level <= 0 then
							local player = v25.voice.player
							player:Stop()
							player.TimePosition = v22.HISS_RANGE.Min + math.random() * (v22.HISS_RANGE.Max - v22.HISS_RANGE.Min - 0.3)
							AudioGraph.route(v25.voice, "dry")
							player:Play()
						end

						v24[id] = v25
					end

					v25.pos = pos
				elseif v25 then
					v24[id] = nil
					v25.on = false
					local v26 = camPos() -- inferred equivalent call
					local magnitude = (v25.pos - v26).Magnitude
					local v27 = math.max(magnitude / meter, 1)

					if v27 <= v22.HISS_WITHIN then
						local v28 = occluded(v25.pos, v26, magnitude)
						local v29 = 1
						local v30 = airCutoff(v27 / 1) -- inferred equivalent call

						if v28 then
							v29 *= 0.55
							v30 = math.min(v30, 900)
						end

						if v13 > 0 and v27 > 15 then
							v29 *= 1 - v13 * 0.45
							v30 = math.max(v30 * (1 - v13 * 0.6), 700)
						end

						local v31 = v22.DIE_GAIN * reach3(v22.HISS_REACH, v27) * v29 -- inferred equivalent call
						emitAt(
							draw(v22.DIE),
							v25.pos,
							v31,
							math.min(0.92 + 0.07999999999999996 * math.random(), 1),
							"dry",
							math.min(v30, v22.CUTOFF),
							1e999,
							0,
							v31 + 0.5
						)
					end
				end
			end
		end

		local v24 = os.clock()
		table.insert(v11, function()
			local now = os.clock()
			local v25 = math.min(now - v24, 0.1)
			v24 = now
			local v26 = camPos() -- inferred equivalent call

			for _, v27 in v23 do
				if v27.on then
					v27.level = math.min(1, v27.level + v25 / v22.FADE_IN)
				elseif v27.level > 0 then
					v27.level = math.max(0, v27.level - v25 / v22.FADE_OUT)
				end

				local player = v27.voice.player

				if v27.level <= 0 then
					if AudioGraph.awake(v27.voice) then
						player:Stop()
						AudioGraph.park(v27.voice)
					end
				else
					v27.voice.attachment.WorldPosition = v27.pos
					local magnitude = (v27.pos - v26).Magnitude
					local v28 = math.max(magnitude / meter, 1)
					local v29 = occluded(v27.pos, v26, magnitude)
					local v30 = 1
					local v31 = airCutoff(v28 / 1) -- inferred equivalent call

					if v29 then
						v30 *= 0.55
						v31 = math.min(v31, 900)
					end

					if v13 > 0 and v28 > 15 then
						v30 *= 1 - v13 * 0.45
						v31 = math.max(v31 * (1 - v13 * 0.6), 700)
					end

					local v32 = v22.HISS_GAIN * v22.HISS_RAW
					player.Volume = math.min(v32 * reach3(v22.HISS_REACH, v28) * v30 * v27.level, 10) -- inferred equivalent call
					AudioGraph.lowpass(v27.voice, (math.min(v31, v22.CUTOFF)))
				end
			end
		end)
	end

	local v22 = {}

	function VoxelSound.oneShotAt(p: number, from: number, p2: number, vector3: Vector3, p3: number, value: number?)
		local v23 = v22[p]

		if not v23 then
			v23 = {}
			v22[p] = v23
		end

		local v24 = v23[from]

		if not v24 then
			v24 = {}
			v23[from] = v24
		end

		local v25 = v24[p2]

		if not v25 then
			v25 = slice(p, from, from + p2) -- inferred equivalent call
			v24[p2] = v25
		end

		local v26 = camPos() -- inferred equivalent call
		local magnitude = (vector3 - v26).Magnitude
		local v27 = math.max(magnitude / meter, 1)
		local v28 = occluded(vector3, v26, magnitude)

		local v29 = 1
		local v30 = airCutoff(v27 / 1) -- inferred equivalent call

		if v28 then
			v29 *= 0.55
			v30 = math.min(v30, 900)
		end

		if v13 > 0 and v27 > 15 then
			v29 *= 1 - v13 * 0.45
			v30 = math.max(v30 * (1 - v13 * 0.6), 700)
		end

		local v31 = p3 * v29
		emitAt(v25, vector3, v31, math.min(value or 1, 1), "dry", v30, 1e999, 0, v31 + 0.5)
	end
end

return VoxelSound