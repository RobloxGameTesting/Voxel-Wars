game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AudioGraph = require(ReplicatedStorage.Voxel:WaitForChild("AudioGraph"))
local WorldConfig = require(ReplicatedStorage.Voxel:WaitForChild("WorldConfig"))

local v = 343 * WorldConfig.METER

local function cut(p: number, from: number, to: number, gain: number, peak: number) -- 5 equivalent calls inferred from this helper
	return {
		id = "rbxassetid://" .. p,
		from = from,
		to = to,
		gain = gain,
		peak = peak,
		range = NumberRange.new(from, to)
	}
end

local v2 = {
	cut(9113066850, 0.6, 8.4, 3.7, 2.84), -- inferred equivalent call
	cut(9113066731, 2.5, 9.5, 2.91, 2.86), -- inferred equivalent call
	cut(9113066854, 0.4, 7.2, 2.57, 3.46), -- inferred equivalent call
	cut(9113067229, 0.2, 7.2, 4.18, 4.7) -- inferred equivalent call
}
local v3 = cut(9113064746, 1.85, 3.6, 3.74, 0.82) -- inferred equivalent call
local JetSound = {}

local function lerp(p: number, p2: number, p3: number)
	return p + (p2 - p) * p3
end

local function set(state, p: number, p2: number)
	local player = state.player

	if p < 0.003 then
		if state.on then
			state.on = false
			state.vol = nil
			player.Volume = 0
			player:Stop()
			AudioGraph.park(state)
		end
	else
		if not state.on then
			state.on = true
			AudioGraph.route(state, "dry")
			player:Play()
		end

		if math.abs(p - (state.vol or -1)) >= 0.004 then
			state.vol = p
			player.Volume = p
		end

		if math.abs(p2 - (state.speed or -1)) >= 0.002 then
			state.speed = p2
			player.PlaybackSpeed = p2
		end
	end
end

local function loop(p: string, jetSound, p2)
	local positional = AudioGraph.positional(p, jetSound)
	local player = positional.player
	player.Asset = "rbxassetid://" .. p2.id
	player.Looping = true
	player.PlaybackRegion = p2.loop
	player.LoopRegion = p2.loop
	player.TimePosition = p2.loop.Min + math.random() * (p2.loop.Max - p2.loop.Min - 0.5)
	player.Volume = 0
	AudioGraph.park(positional)
	return positional
end

local function build(data)
	local jetSound = Instance.new("Part")
	jetSound.Name = "JetSound"
	jetSound.Anchored = true
	jetSound.CanCollide = false
	jetSound.CanQuery = false
	jetSound.CanTouch = false
	jetSound.CastShadow = false
	jetSound.Transparency = 1
	jetSound.Size = Vector3.new(0.2, 0.2, 0.2)
	jetSound.CFrame = data.cf
	jetSound.Parent = data.model
	local sfx = data.def.sfx
	local v4 = {
		part = jetSound,
		core = loop("JetCore", jetSound, sfx.core),
		body = loop("JetBody", jetSound, sfx.body),
		burn = loop("JetBurn", jetSound, sfx.burn),
		pass = AudioGraph.positional("JetPass", jetSound),
		rip = AudioGraph.positional("JetRipCut", jetSound),
		gear = AudioGraph.positional("JetGear", jetSound),
		trail = {},
		head = 0,
		sampleAt = 0,
		passEnd = 0,
		ripEnd = 0,
		gearEnd = 0,
		passed = false,
		ripped = false,
		cut = v2[math.random(#v2)],
		duck = 1,
		camPos = nil,
		camVel = Vector3.new(0, 0, 0),
		nose = nil,
		turn = 0,
		skim = false,
		skimAt = 0,
		pilotRipAt = 0,
		wasSkim = false,
		wasTurning = false,
		wasBurning = false,
		swapCut = false
	}

	v4.pass.player.Asset = v4.cut.id
	v4.rip.player.Asset = v3.id
	v4.gear.player.Asset = "rbxassetid://9125610263"
	AudioGraph.park(v4.pass)
	AudioGraph.park(v4.rip)
	AudioGraph.park(v4.gear)
	return v4
end

local function back(p, now: number, p2: number, vector3: Vector3, vector3_2: Vector3)
	local v4 = now - p2
	local v5 = nil

	for i = 0, 79 do
		local v6 = p.trail[(p.head - i - 1) % 80 + 1]

		if not v6 then
			break
		end

		if v6.t <= v4 then
			if not v5 then
				return v6.pos, v6.vel
			end

			local v7 = (v4 - v6.t) / math.max(v5.t - v6.t, 0.001)
			return v6.pos:Lerp(v5.pos, v7), v6.vel:Lerp(v5.vel, v7)
		end

		v5 = v6
	end

	if v5 then
		return v5.pos, v5.vel
	end

	return vector3, vector3_2
end

local function oneShot(p, data, p2: number, p3: number, playbackSpeed: number, p4: number, value: string?)
	local player = p.player
	player.Asset = data.id
	player.PlaybackRegion = data.range
	player.PlaybackSpeed = playbackSpeed
	player.Volume = p3 * data.gain
	player.TimePosition = data.from + (math.max)(p2, 0)
	AudioGraph.lowpass(p, p4)
	local v4 = os.clock() + (data.to - data.from - (math.max)(p2, 0)) / playbackSpeed
	AudioGraph.route(p, value or "open", v4)
	player:Play()
	return v4
end

local function pilotRips(state, state2, p: number, now: number, flag: boolean, p2: number, spin: number)
	local lookVector = state.cf.LookVector

	if state2.nose and p > 0 then
		state2.turn += ((lookVector - state2.nose).Magnitude / p - state2.turn) * math.min(1, p * 10)
	end

	state2.nose = lookVector

	if p2 > 0.5 and state2.skimAt <= now then
		state2.skimAt = now + 0.1
		local position = state.cf.Position
		local v4 = state.cf.RightVector * 70
		state2.skim = workspace:Raycast(position, Vector3.new(0, -70, 0), state.params) ~= nil
			or workspace:Raycast(position, v4, state.params) ~= nil
			or workspace:Raycast(position, -v4, state.params) ~= nil
	elseif p2 <= 0.5 then
		state2.skim = false
	end

	local wasTurning = state2.turn > 0.7
	local wasBurning = spin > 0.88
	local v4, v5

	if flag then
		v4 = 0.8
		v5 = 5000
	else
		v4 = 1
		v5 = 14000
	end

	if p2 > 0.5 and state2.pilotRipAt <= now then
		if state2.skim and not state2.wasSkim then
			state2.pilotRipAt = now + 2.5
			local cut2 = state2.cut
			state2.passEnd = oneShot(state2.pass, cut2, math.max(cut2.peak - 0.5, 0), v4 * 0.5, 0.95, v5, "dry")
			state2.swapCut = true
		elseif wasTurning and not state2.wasTurning or wasBurning and not state2.wasBurning then
			state2.pilotRipAt = now + 2.5
			state2.ripEnd = oneShot(state2.rip, v3, 0, v4 * 0.55, 0.92, v5, "dry")
		end
	end

	state2.wasSkim = state2.skim
	state2.wasTurning = wasTurning
	state2.wasBurning = wasBurning

	if state2.swapCut and state2.passEnd < now then
		state2.swapCut = false
		state2.cut = v2[math.random(#v2)]
		state2.pass.player.Asset = state2.cut.id
	end
end

local v4 = nil
local function cabinBed(sfx)
	if v4 then
		return v4
	end

	v4 = AudioGraph.flat("JetCabin")
	local player = v4.player
	player.Asset = "rbxassetid://" .. sfx.cabin.id
	player.Looping = true
	player.PlaybackRegion = sfx.cabin.loop
	player.LoopRegion = sfx.cabin.loop
	player.TimePosition = sfx.cabin.loop.Min
	player.Volume = 0
	AudioGraph.lowpass(v4, 1900)
	AudioGraph.park(v4)

	return v4
end

function JetSound.leaveCabin()
	if v4 then
		local v5 = v4
		local player = v5.player

		if v5.on then
			v5.on = false
			v5.vol = nil
			player.Volume = 0
			player:Stop()
			AudioGraph.park(v5)
		end
	end
end

function JetSound.gear(p, flag: boolean)
	local sound = p.sound
	local currentCamera = workspace.CurrentCamera

	if not (sound and currentCamera) then
		return
	end

	local v5 = math.min(1, 120 / math.max((currentCamera.CFrame.Position - p.cf.Position).Magnitude, 1)) ^ 2 * 0.8
	local volume = flag and 0.4 or v5

	if volume > 0.01 then
		local player = sound.gear.player
		player.PlaybackSpeed = 0.85
		player.Volume = volume
		player.TimePosition = 0
		AudioGraph.lowpass(sound.gear, flag and 1900 or 14000)
		sound.gearEnd = os.clock() + 5
		AudioGraph.route(sound.gear, "dry", sound.gearEnd)
		player:Play()
	end
end

function JetSound:step(p: number, flag: boolean, flag2: boolean)
	local sound = self.sound

	if not sound then
		sound = build(self)
		self.sound = sound
	end

	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local now = os.clock()
	local position = currentCamera.CFrame.Position

	if sound.camPos and p > 0 then
		sound.camVel = sound.camVel:Lerp((position - sound.camPos) / p, 1 - math.exp(p * -8))
	end

	sound.camPos = position

	if sound.sampleAt <= now then
		sound.sampleAt = now + 0.05
		sound.head = sound.head % 80 + 1
		sound.trail[sound.head] = { t = now, pos = self.cf.Position, vel = self.vel }
	end

	local v5 = self.cf.Position
	local vector = self.vel

	if not flag then
		local v6, v7 = back(sound, now, (position - v5).Magnitude / v, v5, vector)
		v5, vector = back(sound, now, (position - v6).Magnitude / v, v6, v7)
	end

	sound.part.CFrame = CFrame.new(v5)
	local vector2 = v5 - position
	local v6 = math.max(vector2.Magnitude, 1)
	local spin = self.spin

	if v6 >= 3200 or spin < 0.005 then
		local core = sound.core
		local player = core.player

		if core.on then
			core.on = false
			core.vol = nil
			player.Volume = 0
			player:Stop()
			AudioGraph.park(core)
		end

		local body = sound.body
		local player2 = body.player

		if body.on then
			body.on = false
			body.vol = nil
			player2.Volume = 0
			player2:Stop()
			AudioGraph.park(body)
		end

		local burn = sound.burn
		local player3 = burn.player

		if burn.on then
			burn.on = false
			burn.vol = nil
			player3.Volume = 0
			player3:Stop()
			AudioGraph.park(burn)
		end
	else
		local v7 = vector2 / v6
		local v8 = math.clamp(vector.Magnitude / 170, 0, 1)
		local midpoint = (1 + self.cf.LookVector:Dot(v7)) / 2
		local v9 = flag and 1 or midpoint
		local v10 = (v9 ^ 0.7 * 0.7 + 0.3 - 1) * v8 + 1
		local v11 = 0.1 ^ math.clamp((v6 - 100) / 1700, 0, 1) * 14000

		if not flag then
			v11 *= v9 * v8 * -0.53 + 1
		end

		local v12 = 0.62 + 0.28 * spin
		local v13

		if flag then
			v13 = 1
		else
			local dot = (vector - sound.camVel):Dot(v7)
			v13 = (v / math.max(v + dot, 100)) ^ 0.35
		end

		local v14 = math.min(v12 * v13, 1)

		if not flag and v8 > 0.5 then
			local dot = vector:Dot(vector)
			local v15 = -vector2:Dot(vector) / dot
			local v16 = math.max((vector2 + vector * math.max(v15, 0)).Magnitude, 1)
			local v17 = v15 + (v16 - v6) / v
			local v18 = 0.5 + 0.5 * spin
			local cut2 = sound.cut

			if not sound.passed and v16 < 700 and v17 <= cut2.peak and v17 > -0.5 then
				sound.passed = true
				sound.passEnd = oneShot(
					sound.pass,
					cut2,
					cut2.peak - v17,
					math.min(1, 175 / v16) * 0.9 * v18,
					0.95,
					v11
				)
			end

			local v19 = v17 - 0.1

			if not sound.ripped and v16 < 300 and v19 <= v3.peak and v19 > -0.3 then
				sound.ripped = true
				sound.ripEnd = oneShot(sound.rip, v3, v3.peak - v19, math.min(1, 175 / v16) * 0.7 * v18, 0.92, v11)
			end

			if v15 < -3 and sound.passEnd < now then
				sound.passed = false
				sound.ripped = false
				sound.cut = v2[math.random(#v2)]
				sound.pass.player.Asset = sound.cut.id
			end
		end

		if flag then
			pilotRips(self, sound, p, now, flag2, v8, spin)
		elseif sound.pass.player.IsPlaying then
			AudioGraph.lowpass(sound.pass, v11)
		end

		for _, v15 in { "pass", "rip", "gear" } do
			local v16 = sound[v15]

			if sound[v15 .. "Parked"] or not (sound[v15 .. "End"] + 0.5 < now) then
				if now <= sound[v15 .. "End"] then
					sound[v15 .. "Parked"] = false
				end
			else
				sound[v15 .. "Parked"] = true
				AudioGraph.park(v16)
			end
		end

		local v15 = (flag or sound.passEnd - 1.5 <= now) and 1 or 0.25
		sound.duck += (v15 - sound.duck) * math.min(1, p * 2.5)

		local sfx = self.def.sfx
		local v16 = math.clamp(1 - v6 / 3200, 0, 1) ^ 0.5
		local v17 = math.clamp((spin - 0.8) / 0.2, 0, 1)
		local v18 = sfx.core.gain * (0.3 + 0.7 * spin ^ 1.3) * math.min(1, (300 / v6) ^ 0.7)
		local v19 = sfx.body.gain * spin ^ 1.4 * math.min(1, (120 / v6) ^ 1.2)
		local v20 = sfx.burn.gain * v17 * math.min(1, (200 / v6) ^ 0.9) * (v9 * 0.75 + 0.25)
		local v21, v22

		if flag and flag2 then
			v18 *= 0.85
			v19 *= 0.8
			v20 *= 0.95
			v21 = v8 * 3400 + 2600
			v22 = v8 * 3100 + 2400
			v11 = v21
		else
			v22 = v11
			v21 = v22
		end

		set(sound.core, v18 * v10 * v16 * sound.duck, v14)
		set(sound.body, v19 * v10 * v16 * sound.duck, v14)
		set(sound.burn, v20 * v16 * sound.duck, math.min(v13 * 0.2 + 0.8, 1))
		AudioGraph.lowpass(sound.core, v11)
		AudioGraph.lowpass(sound.body, v21)
		AudioGraph.lowpass(sound.burn, v22)

		if flag and flag2 then
			set(cabinBed(sfx), sfx.cabin.gain * (v8 * 0.65 + 0.35), v8 * 0.2 + 0.8)
		elseif flag then
			JetSound.leaveCabin()
		end
	end
end

return JetSound