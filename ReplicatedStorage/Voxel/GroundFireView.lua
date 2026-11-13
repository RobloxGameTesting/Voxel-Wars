--!native
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local Quality = require(Voxel:WaitForChild("Quality"))
local Detail = require(Voxel:WaitForChild("Detail"))
local GroundFireShared = require(Voxel:WaitForChild("GroundFireShared"))
local VoxelSound = require(Voxel:WaitForChild("VoxelSound"))
local Remotes = Voxel:WaitForChild("Remotes")

local GroundFireView = {}

local v = { 8, 4, 2 }
local v2 = { 3, 2, 2 }

local function scaled(p: number) -- 3 equivalent calls inferred from this helper
	local share = Quality.share()

	if share < 1 then
		return (math.max(1, (math.floor(p * share + 0.5))))
	end

	return p
end

local v3 = { 0.35, 0.6 }

local v4 = { 12, 6, 3 }

local v5 = { Color3.fromRGB(34, 31, 28), Color3.fromRGB(70, 66, 62) }

local color = Color3.fromRGB(255, 214, 112)
local color2 = Color3.fromRGB(255, 128, 40)
local color3 = Color3.fromRGB(196, 54, 24)

local v6 = { Color3.fromRGB(96, 92, 86), Color3.fromRGB(156, 152, 146) }
local v7 = { 1.2, 3.4 }
local v8 = { 2.4, 3.4 }
local v9 = { Color3.fromRGB(128, 124, 118), Color3.fromRGB(178, 175, 170) }
local v10 = { 0.6, 2.4 }
local v11 = { 3.5, 5 }
local color4 = Color3.fromRGB(255, 96, 30)
local color5 = Color3.fromRGB(150, 34, 12)
local v12 = { 0.22, 0.38 }

local color6 = Color3.fromRGB(255, 142, 62)

local function nearFade(vector3: Vector3, p: number) -- 1 equivalent call inferred from this helper
	if Detail.low then
		return math.floor(math.clamp((Detail.pixels(vector3, p) / Detail.screenY - 0.45) / 0.14999999999999997, 0, 1) * 4 + 0.5) / 4
	end

	return 0
end

local v13 = {
	[23] = true,
	[24] = true,
	[37] = true,
	[40] = true,
	[41] = true
}

local v14 = {}
local v15 = 0
local rigs = {}
local states = {}
local v16 = {}

local parent = nil
local v17 = {}
local v18 = {}
local v19 = {}
local v20 = {}

local v21 = {}
local v22 = {}
local random = Random.new()
local heartbeatConnection = nil
local total = 1e999
local total2 = 0

local v23 = {}
local v24 = 1
local count = 0
local v25 = {}

local v26 = {}
local v27 = {}

local raycastParams = RaycastParams.new()
raycastParams.IncludeInstances = { workspace.Terrain }
raycastParams.IgnoreWater = true

local function newPart(name: string, material, color7: Color3)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Size = Vector3.new(1, 1, 1)
	part.Material = material
	part.Color = color7
	part.Transparency = 1
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.CFrame = CFrame.new(0, -10000, 0)
	part.Parent = parent
	return part
end

local function newTongue()
	return {
		part = newPart("GrassFlame", Enum.Material.Neon, color),
		phase = 0,
		period = 1,
		base = Vector3.new(0, 0, 0),
		inside = false,
		shown = -1,
		alpha = 1,
		seed = random:NextNumber(0, 100),
		stale = true,
		w = -1,
		h = -1
	}
end

local function newRig()
	local rig = {
		fire = nil,
		tongues = {},
		puffs = {},
		embers = {},
		lod = 1,
		light = 0,
		glow = 1,
		seed = random:NextNumber(0, 100),
		scale = 1
	}

	for i = 1, math.max(v[1], v4[1]) do
		rig.tongues[i] = newTongue()
		rig.tongues[i].stale = false
	end

	for i = 1, v2[1] do
		local part = newPart("GrassSmoke", Enum.Material.SmoothPlastic, v6[1])
		rig.puffs[i] = {
			part = part,
			phase = 0,
			period = 1,
			base = Vector3.new(0, 0, 0),
			drift = Vector3.new(0, 0, 0),
			spin = 0,
			shown = -1,
			alpha = 1,
			on = true,
			near = 0,
			w = -1,
			h = -1
		}
	end

	for i = 1, 6 do
		local part = newPart("Ember", Enum.Material.Neon, color4)
		local number = random:NextNumber(v12[1], v12[2])
		part.Size = Vector3.new(number, number * 0.6, number)
		rig.embers[i] = {
			part = part,
			base = Vector3.new(0, 0, 0),
			until_ = 0,
			rate = random:NextNumber(2, 5),
			seed = random:NextNumber(0, 100),
			alpha = 1
		}
	end

	table.insert(rigs, rig)
	return rig
end

local function hide(part, p) -- 7 equivalent calls inferred from this helper
	if p.alpha < 1 then
		part.Transparency = 1
		p.alpha = 1
	end
end

local function releaseRig(state)
	local fire = state.fire

	if fire then
		fire.rig = nil
	end

	state.fire = nil

	for _, tongue in state.tongues do
		hide(tongue.part, tongue) -- inferred equivalent call
	end

	for _, puff in state.puffs do
		hide(puff.part, puff) -- inferred equivalent call
	end

	for _, ember in state.embers do
		hide(ember.part, ember) -- inferred equivalent call
	end

	table.insert(states, state)
end

local v28 = nil
local function groundPoint(data, p: number, p2: number)
	local v29 = data.pos + Vector3.new(math.cos(p) * p2, 0, math.sin(p) * p2)

	if data.pool then
		if data.radius <= 7 then
			return v29
		end

		local v30 = v28

		if not v30 then
			v30 = RaycastParams.new()
			v30.FilterType = Enum.RaycastFilterType.Exclude
			v30.FilterDescendantsInstances = { parent }
			v30.IgnoreWater = true
			v30.RespectCanCollide = true
			v28 = v30
		end

		local raycastResult = workspace:Raycast(v29 + Vector3.new(0, 6, 0), Vector3.new(0, -14, 0), v30)
		return if raycastResult then raycastResult.Position else v29
	else
		local raycastResult = workspace:Raycast(v29 + Vector3.new(0, 4, 0), Vector3.new(0, -9, 0), raycastParams)
		return if raycastResult then raycastResult.Position else v29
	end
end

local v29 = {}
local v30 = false

local function colKey(gx: number, gz: number) -- 1 equivalent call inferred from this helper
	return (gx + 65536) * 131072 + (gz + 65536)
end

local function queueRing(state, p: number, p2: number, slot: number)
	local v31 = math.ceil(p2 / 4) + 1
	local v32 = math.floor(state.pos.X / 4)
	local v34 = math.floor(state.pos.Z / 4)

	for i = -v31, v31 do
		for j = -v31, v31 do
			local v35 = (v32 + j + 0.5) * 4
			local v36 = (v34 + i + 0.5) * 4
			local v37 = math.sqrt((v35 - state.pos.X) ^ 2 + (v36 - state.pos.Z) ^ 2)

			if not (p < v37 and v37 <= p2) then
				continue
			end

			count += 1
			v23[count] = {
				gx = v32 + j,
				gz = v34 + i,
				y = state.pos.Y,
				slot = slot
			}
		end
	end
end

local v31 = { "SolidOccupancy", "SolidMaterialIndex" }
local function writeColumn(data)
	local v32 = colKey(data.gx, data.gz) -- inferred equivalent call
	local v34 = v25[v32]
	local row

	if v34 then
		row = v34.row
	else
		row = math.floor(data.y / 4)
	end

	local vector3 = Vector3.new(data.gx * 4, (row - 1) * 4, data.gz * 4)
	local region = Region3.new(vector3, vector3 + Vector3.new(4, 12, 4))
	local voxelChannels = workspace.Terrain:ReadVoxelChannels(region, 4, v31)
	local v36 = voxelChannels.SolidMaterialIndex[1]

	local slots = table.create(#v36, 0)
	local flag = false

	for i = 1, #v36 do
		local v38 = v36[i][1]
		slots[i] = v38

		if not (v13[v38] or data.slot == 42 and v38 == 43) then
			continue
		end

		v36[i][1] = data.slot
		flag = true
	end

	if flag then
		if not v34 then
			v25[v32] = { row = row, slots = slots }
		end

		workspace.Terrain:WriteVoxelChannels(region, 4, {
			SolidMaterialIndex = voxelChannels.SolidMaterialIndex
		})
	end
end

local function restoreGround()
	table.clear(v23)
	v24 = 1
	count = 0
	table.clear(v29)
	local v32 = v25
	v25 = {}
	task.spawn(function()
		local count2 = 0

		for k, v34 in v32 do
			local v35 = k // 131072 - 65536
			local v36 = k % 131072 - 65536
			local vector3 = Vector3.new(v35 * 4, (v34.row - 1) * 4, v36 * 4)
			local region = Region3.new(vector3, vector3 + Vector3.new(4, 12, 4))
			local voxelChannels = workspace.Terrain:ReadVoxelChannels(region, 4, v31)
			local v37 = voxelChannels.SolidMaterialIndex[1]

			for i = 1, math.min(#v37, #v34.slots) do
				v37[i][1] = v34.slots[i]
			end

			workspace.Terrain:WriteVoxelChannels(region, 4, {
				SolidMaterialIndex = voxelChannels.SolidMaterialIndex
			})
			count2 += 1

			if count2 % 8 == 0 then
				task.wait()
			end
		end
	end)
end

local function burnGround(state, p: number)
	local v32

	if state.flame <= p then
		v32 = state.radius
	else
		v32 = GroundFireShared.front(state, p)
	end

	local singeR = v32 + 3

	if singeR - state.singeR >= 2 or state.flame <= p and state.singeR < singeR then
		queueRing(state, state.singeR, singeR, 43)
		state.singeR = singeR
	end

	local scorchR = v32 * 0.9

	if scorchR - state.scorchR >= 2 or state.flame <= p and state.scorchR < scorchR then
		queueRing(state, not (state.scorchR > 0) and -1 or state.scorchR, scorchR, 42)
		state.scorchR = scorchR
	end

	if state.flame <= p then
		state.done = true
	end
end

local function select(position: Vector3, serverTimeNow: number)
	local mobile = Quality.mobile or Quality.potato
	local v32 = not mobile and 650 or math.min(650, Quality.MOBILE_CUT_M * 2.5, Quality.mobile and 320 or 650)

	local v34 = math.max(Quality.MIN_FIRE_RIGS, (math.min(Quality.mobile and 4 or 20, Quality.cap(20))))
	local magnitudes = {}
	local v35 = {}
	local v36 = mobile and 98 or 140
	local v37 = mobile and 224 or 320

	for _, v38 in v14 do
		if GroundFireShared.phase(v38, serverTimeNow - v38.t0) == "out" then
			continue
		end

		local magnitude = (v38.pos - position).Magnitude

		if not (magnitude < v32) then
			continue
		end

		magnitudes[v38] = magnitude
		table.insert(v35, v38)
	end

	table.sort(v35, function(a, b): boolean
		return magnitudes[a] < magnitudes[b]
	end)

	local set = {}

	for i = 1, math.min(#v35, v34) do
		set[v35[i]] = true
	end

	for i = #v16, 1, -1 do
		local v38 = v16[i]

		if not (v38.fire and set[v38.fire]) then
			releaseRig(v38)
		end
	end

	table.clear(v16)

	for i = 1, math.min(#v35, v34) do
		local fire = v35[i]
		local rig = fire.rig

		if not rig then
			rig = table.remove(states) or newRig()
			assert(rig)
			rig.fire = fire
			fire.rig = rig

			for _, tongue in rig.tongues do
				tongue.phase = random:NextNumber()
				tongue.period = random:NextNumber(v3[1], v3[2])
				tongue.base = fire.pos
				tongue.stale = false
			end

			for _, puff in rig.puffs do
				puff.phase = random:NextNumber()
				puff.period = 0
			end

			for _, ember in rig.embers do
				ember.until_ = 0
			end
		end

		local v40 = magnitudes[fire]
		rig.lod = v40 < v36 and 1 or v40 < v37 and 2 or 3
		rig.scale = not Detail.low and 1 or Detail.scale(fire.pos, 12)
		table.insert(v16, rig)
	end

	for _, v38 in v16 do
		local fire = v38.fire
		local count2 = 0

		for _, v39 in v16 do
			local fire2 = v39.fire

			if not (v39 ~= v38 and (fire2.pos - fire.pos).Magnitude < 16 + fire2.radius and GroundFireShared.intensity(fire2, serverTimeNow - fire2.t0) > 0) then
				continue
			end

			count2 += 1
		end

		v38.glow = 0.6 / math.sqrt(count2 + 1) + 0.4
	end

	local count2 = 0
	local v38

	if Quality.potato then
		v38 = Quality.FIRE_LIGHTS
	else
		v38 = Quality.mobile and 0 or 3
	end

	local v39 = nil
	local v40 = {}

	for _, v41 in v16 do
		v41.light = 0
		local fire = v41.fire
		local v42 = serverTimeNow - fire.t0
		local intensity = GroundFireShared.intensity(fire, v42)

		if fire.pool and intensity > 0 and v39 == nil then
			v39 = fire
		end

		if intensity > 0 and v41.lod == 1 and count2 < v38 then
			count2 += 1
			v41.light = count2
		end

		if not (#v40 < VoxelSound.FIRE_SLOTS) then
			continue
		end

		if intensity > 0 then
			local v43 = { pos = fire.pos, volume = 0 }
			local volume

			if fire.pool then
				volume = 1 * (0.5 + 0.5 * intensity)
			else
				volume = 0.25 + 0.55 * intensity * (0.5 + 0.5 * fire.fuel)
			end

			v43.volume = volume
			table.insert(v40, v43)
		elseif v42 < fire.flame + fire.smoulder * 0.25 then
			table.insert(v40, { pos = fire.pos, volume = 0.12 })
		end
	end

	local enabled = count2 >= 1

	if v22[1] ~= enabled then
		v22[1] = enabled
		v17[1].Enabled = enabled
	end

	local enabled2 = count2 >= 2

	if v22[2] ~= enabled2 then
		v22[2] = enabled2
		v17[2].Enabled = enabled2
	end

	local enabled3 = count2 >= 3

	if v22[3] ~= enabled3 then
		v22[3] = enabled3
		v17[3].Enabled = enabled3
	end

	VoxelSound.fireSources("grass", v40)

	if v39 then
		VoxelSound.fuelFire(v39.pos, 0.4 + 0.6 * GroundFireShared.intensity(v39, serverTimeNow - v39.t0))
	else
		VoxelSound.fuelFire(nil, 0)
	end
end

local function flameColor(p: number) -- 1 equivalent call inferred from this helper
	if p < 0.4 then
		return (color:Lerp(color2, p / 0.4))
	end

	return (color2:Lerp(color3, (p - 0.4) / 0.6))
end

local function drawFlames(data, fire, p: number, p2: number, count2: number, flag: boolean, p3: number)
	local intensity = GroundFireShared.intensity(fire, p)
	local v32

	if intensity > 0 then
		local v34 = if fire.pool then v4 else v
		v32 = v34[data.lod]
		v32 = scaled(v32) -- inferred equivalent call
	else
		v32 = 0
	end

	if fire.pool and fire.radius < 3 and v32 > 0 then
		v32 = math.max(2, (math.ceil(v32 * 0.5)))
	elseif fire.pool and fire.radius > 7 and v32 > 0 then
		v32 = math.ceil(v32 * math.min(fire.radius / 7, 4))

		for i = #data.tongues + 1, v32 do
			data.tongues[i] = newTongue()
		end
	end

	local v34 = data.lod == 3 and 1.8 or 1
	local front = GroundFireShared.front(fire, p)

	for k, tongue in data.tongues do
		if v32 < k then
			hide(tongue.part, tongue) -- inferred equivalent call
		else
			local phase = tongue.phase + p2 / tongue.period

			if phase >= 1 then
				phase -= math.floor(phase)
				tongue.period = random:NextNumber(v3[1], v3[2])
				tongue.stale = true
			end

			tongue.phase = phase

			if flag then
				if tongue.stale then
					tongue.stale = false
					tongue.inside = random:NextNumber() < (fire.pool and 0.6 or 0.25)
					local v36

					if tongue.inside then
						v36 = front * random:NextNumber(0.2, 0.7)
					else
						v36 = front * random:NextNumber(0.92, 1.04)
					end

					tongue.base = groundPoint(fire, random:NextNumber() * 3.141592653589793 * 2, v36)
				end

				local v36 = intensity * (0.6 + 0.8 * fire.fuel) * v34 * (tongue.inside and 0.55 or 1)
				local v37 = 1.3 * v36 * (math.sin(3.141592653589793 * phase) * 0.5 + 0.5) * (fire.pool and 2.3 or 1)
				local v38 = 0.75 * v36 * (1 - phase * 0.5) * (fire.pool and 0.85 or 1) + 0.15
				local v39 = GroundFireShared.WIND * (phase * 0.12)
				local v40 = math.sin(total2 * 8 + tongue.seed) * 0.12
				local v41 = tongue.base + Vector3.new(v40, v37 * 0.5 + phase * 0.35, v40 * 0.6) + v39
				count2 += 1
				v26[count2] = tongue.part
				v27[count2] = CFrame.Angles(v40 * 0.5, tongue.seed + phase * 1.4, v40 * 0.4) + v41

				if p3 < math.abs(v38 - tongue.w) or p3 < math.abs(v37 - tongue.h) then
					tongue.w = v38
					tongue.h = v37
					tongue.part.Size = Vector3.new(v38, v37, v38)
				end

				local shown = math.floor(phase * 8)

				if shown ~= tongue.shown then
					tongue.shown = shown
					local v43 = shown / 8
					local part = tongue.part
					part.Color = flameColor(v43) -- inferred equivalent call
					local v44 = 1 - (1 - math.min(v43 < 0.5 and 0.1 or (v43 - 0.5) * 1.4 + 0.1, 1)) * 0.85 * data.glow

					local v45 = Quality.mobile and (data.glow > 0.3 and 0 or 1) or v44

					tongue.part.Transparency = v45
					tongue.alpha = v45
				end
			end
		end
	end

	return count2
end

local function drawSmoke(data, fire, p: number, p2: number, count2: number, flag: boolean, p3: number)
	local phase = GroundFireShared.phase(fire, p)
	local intensity = GroundFireShared.intensity(fire, p)
	local v32 = phase == "smoulder"
	local v34 = not v32 and 0 or (p - fire.flame) / fire.smoulder
	local v35

	if Quality.mobile then
		v35 = 0
	else
		v35 = v2[data.lod]
		v35 = scaled(v35) -- inferred equivalent call
	end

	local low = Detail.low

	if low then
		v35 = math.floor(v35 * data.scale + 0.5)
	end

	local v36 = math.clamp(fire.radius / 5, 0.7, 1.6)

	for k, puff in data.puffs do
		local on = k <= v35

		if not low then
			puff.on = on
		end

		if puff.on or low and on then
			local phase2 = puff.phase + (not (puff.period > 0) and 1 or p2 / puff.period)

			if phase2 >= 1 then
				if low then
					puff.on = on
				end

				phase2 -= math.floor(phase2)
				local v39 = if v32 then v11 else v8
				puff.period = random:NextNumber(v39[1], v39[2])
				local v40

				if v32 then
					v40 = fire.radius * random:NextNumber(0, 0.8)
				else
					v40 = GroundFireShared.front(fire, p) * random:NextNumber(0.3, 1)
				end

				puff.base = groundPoint(fire, random:NextNumber() * 3.141592653589793 * 2, v40)
				puff.drift = GroundFireShared.WIND + Vector3.new(
					random:NextNumber(-0.4, 0.4),
					0,
					random:NextNumber(-0.4, 0.4)
				)
				puff.spin = random:NextNumber(-0.6, 0.6)
			end

			puff.phase = phase2

			if puff.on then
				if flag then
					local v39 = if v32 then v10 else v7
					local v40 = (v39[1] + (v39[2] - v39[1]) * phase2) * v36
					local v41 = phase2 * puff.period

					local vector3 = puff.base + Vector3.new(0, phase2 * (v32 and 6 or 9) * v36 + 0.6, 0) + puff.drift * v41
					count2 += 1
					v26[count2] = puff.part
					v27[count2] = CFrame.Angles(0, puff.spin * v41, puff.spin * 0.5 * v41) + vector3
					local v42 = v40 * (v32 and 1.4 or 1)

					if p3 < math.abs(v40 - puff.w) or p3 < math.abs(v42 - puff.h) then
						puff.w = v40
						puff.h = v42
						puff.part.Size = Vector3.new(v40, v42, v40)
					end

					local shown = math.floor(phase2 * 12)
					local near = nearFade(vector3, v40) -- inferred equivalent call

					if shown ~= puff.shown or near ~= puff.near then
						puff.shown = shown
						puff.near = near
						local v45 = shown / 12
						local v46

						if v32 then
							v46 = v9
						else
							v46 = if fire.pool then v5 else v6
						end

						puff.part.Color = v46[1]:Lerp(v46[2], v45)
						local v47

						if v45 < 0.1 then
							v47 = 1 - v45 * 6
						else
							v47 = v45 ^ 1.5 * 0.6 + 0.4
						end

						local v48

						if v32 then
							v48 = 0.45 * (1 - v34)
						else
							v48 = 0.35 + 0.65 * intensity
						end

						local v49 = 1 - (1 - math.clamp(v47, 0, 1)) * v48 * (1 - near)
						puff.part.Transparency = v49
						puff.alpha = v49
					end
				end
			else
				hide(puff.part, puff) -- inferred equivalent call
			end
		else
			hide(puff.part, puff) -- inferred equivalent call
		end
	end

	return count2
end

local function drawEmbers(p, fire, p2: number, serverTimeNow: number)
	local phase = GroundFireShared.phase(fire, p2)
	local v32 = 0

	if p.lod == 1 then
		if phase == "flame" then
			v32 = GroundFireShared.RISE < p2 and 3 or 0
		elseif phase == "smoulder" then
			if Quality.mobile then
				v32 = 0
			else
				v32 = math.ceil(scaled(6) * math.max(0, 1 - (p2 - fire.flame) / (fire.smoulder * 0.6))) -- inferred equivalent call
			end
		end
	end

	local v34

	if phase == "flame" then
		v34 = GroundFireShared.front(fire, p2) * 0.8
	else
		v34 = fire.radius * 0.85
	end

	for k, ember in p.embers do
		if v32 < k then
			hide(ember.part, ember) -- inferred equivalent call
		else
			if ember.until_ <= serverTimeNow then
				ember.until_ = serverTimeNow + random:NextNumber(1.5, 3)
				ember.base = groundPoint(
					fire,
					random:NextNumber() * 3.141592653589793 * 2,
					v34 * math.sqrt((random:NextNumber()))
				)
				ember.part.CFrame = CFrame.new(ember.base + Vector3.new(0, 0.08, 0)) * CFrame.Angles(0, random:NextNumber(0, 3), 0)
			end

			local v35 = math.sin(total2 * ember.rate + ember.seed) * 0.5 + 0.5
			local v36 = (1 - v35) * 0.55 + 0.2

			if math.abs(v36 - ember.alpha) > 0.06 then
				ember.part.Transparency = v36
				ember.part.Color = color5:Lerp(color4, v35)
				ember.alpha = v36
			end
		end
	end
end

local function isHeld(p, position: Vector3): boolean -- 2 equivalent calls inferred from this helper
	local v32 = (p.gx + 0.5) * 4 - position.X
	local v34 = (p.gz + 0.5) * 4 - position.Z
	return v32 * v32 + v34 * v34 > 102400
end

local onHeartbeat

local function watchHeld()
	while #v29 > 0 do
		task.wait(1)
		local currentCamera = workspace.CurrentCamera

		if not currentCamera then
			continue
		end

		local position = currentCamera.CFrame.Position
		local count2 = #v29
		local count3 = 0

		for i = 1, count2 do
			local v32 = v29[i]

			if Detail.low and isHeld(v32, position) then -- inferred equivalent call
				count3 += 1
				v29[count3] = v32
				continue
			end

			count += 1
			v23[count] = v32
		end

		for i = count3 + 1, count2 do
			v29[i] = nil
		end

		if v23[v24] ~= nil and heartbeatConnection == nil then
			heartbeatConnection = RunService.Heartbeat:Connect(onHeartbeat)
		end
	end

	v30 = false
end

onHeartbeat = function(p: number)
	total2 += p
	local serverTimeNow = workspace:GetServerTimeNow()

	for _, v32 in v14 do
		if not v32.done then
			burnGround(v32, serverTimeNow - v32.t0)
		end
	end

	local count2 = 0
	local position

	if Detail.low and workspace.CurrentCamera then
		position = workspace.CurrentCamera.CFrame.Position
	end

	while count2 < 4 do
		local v32 = v23[v24]

		if v32 == nil then
			break
		end

		v23[v24] = nil
		v24 += 1

		if position then
			if isHeld(v32, position) then -- inferred equivalent call
				table.insert(v29, v32)

				if not v30 then
					v30 = true
					task.spawn(watchHeld)
				end
			else
				writeColumn(v32)
				count2 += 1
			end
		else
			writeColumn(v32)
			count2 += 1
		end
	end

	if count < v24 and v24 > 1 then
		table.clear(v23)
		v24 = 1
		count = 0
	end

	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	total += p

	if total >= 0.4 then
		total = 0
		select(currentCamera.CFrame.Position, serverTimeNow)

		for k, v32 in v14 do
			if not v32.done or GroundFireShared.phase(v32, serverTimeNow - v32.t0) ~= "out" or v32.rig then
				continue
			end

			v14[k] = nil
			v15 -= 1
		end
	end

	local v32 = 0

	for _, v34 in v16 do
		local fire = v34.fire

		if not fire then
			continue
		end

		local v35 = serverTimeNow - fire.t0

		local v36 = Detail.onScreen(
			fire.pos + Vector3.new(0, 9, 0),
			fire.radius + 18 + Detail.distance(fire.pos) * 0.35
		)
		local v37 = 0.4 / math.max(Detail.pixels(fire.pos, 1), 0.01)
		v32 = drawSmoke(v34, fire, v35, p, drawFlames(v34, fire, v35, p, v32, v36, v37), v36, v37)

		if v36 then
			drawEmbers(v34, fire, v35, serverTimeNow)
		end

		if not (v34.light > 0) then
			continue
		end

		local intensity = GroundFireShared.intensity(fire, v35)
		local v39 = v17[v34.light]

		local v40 = Detail.low and 0
			or math.sin(total2 * 13 + v34.seed) * 0.2 + math.sin(total2 * 7.3 + v34.seed * 2) * 0.15
		local brightness = (1 + 0.6 * intensity + v40) * intensity * 0.85 * v34.glow

		if math.abs(brightness - (v20[v34.light] or -1)) >= 0.04 then
			v20[v34.light] = brightness
			v39.Brightness = brightness
		end

		local range = 8 + fire.radius

		if v19[v34.light] ~= range then
			v19[v34.light] = range
			v39.Range = range
		end

		local worldPosition = fire.pos + Vector3.new(0, 1.5, 0)

		if v21[v34.light] == worldPosition then
			continue
		end

		v21[v34.light] = worldPosition
		v18[v34.light].WorldPosition = worldPosition
	end

	if v32 > 0 then
		for i = v32 + 1, #v26 do
			v26[i] = nil
			v27[i] = nil
		end

		workspace:BulkMoveTo(v26, v27, Enum.BulkMoveMode.FireCFrameChanged)
	end

	if v15 == 0 and v23[v24] == nil and heartbeatConnection then
		for _, v34 in table.clone(v16) do
			releaseRig(v34)
		end

		table.clear(v16)

		for k, v34 in v17 do
			v22[k] = false
			v34.Enabled = false
		end

		VoxelSound.fireSources("grass", {})
		VoxelSound.fuelFire(nil, 0)
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

local function wake() -- 2 equivalent calls inferred from this helper
	total = 1e999

	if heartbeatConnection == nil then
		heartbeatConnection = RunService.Heartbeat:Connect(onHeartbeat)
	end
end

local function add(decoded)
	for _, item in decoded do
		if v14[item.id] then
			continue
		end

		item.rig = nil
		item.scorchR = 0
		item.singeR = 0
		item.done = false
		v14[item.id] = item
		v15 += 1
	end

	if #decoded > 0 then
		wake() -- inferred equivalent call
	end
end

local function clearAll()
	for _, v32 in table.clone(v16) do
		releaseRig(v32)
	end

	table.clear(v16)
	table.clear(v14)
	v15 = 0
	restoreGround()
	wake() -- inferred equivalent call
end

function GroundFireView.start()
	assert(parent == nil, "[GroundFireView] started twice")
	local groundFireFX = Instance.new("Folder")
	groundFireFX.Name = "GroundFireFX"
	groundFireFX.Parent = workspace
	parent = groundFireFX
	local groundFireLights = Instance.new("Part")
	groundFireLights.Name = "GroundFireLights"
	groundFireLights.Anchored = true
	groundFireLights.CanCollide = false
	groundFireLights.CanQuery = false
	groundFireLights.CanTouch = false
	groundFireLights.Transparency = 1
	groundFireLights.Size = Vector3.new(0.2, 0.2, 0.2)
	groundFireLights.Parent = groundFireFX

	for i = 1, 3 do
		local attachment = Instance.new("Attachment")
		attachment.Name = "Light" .. i
		attachment.Parent = groundFireLights
		local pointLight = Instance.new("PointLight")
		pointLight.Color = color6
		pointLight.Shadows = false
		pointLight.Enabled = false
		pointLight.Parent = attachment
		v18[i] = attachment
		v17[i] = pointLight
	end

	local flag = false
	local v32 = {}
	Remotes:WaitForChild("GroundFire").OnClientEvent:Connect(function(buf: buffer)
		if flag then
			add(GroundFireShared.decode(buf))
		else
			table.insert(v32, buf)
		end
	end)
	Remotes:WaitForChild("WorldReset").OnClientEvent:Connect(function()
		table.clear(v32)
		clearAll()
	end)
	task.spawn(function()
		local v34 = Remotes:WaitForChild("GroundFireSnapshot"):InvokeServer()
		assert(typeof(v34) == "buffer", "[GroundFireView] bad snapshot")
		add(GroundFireShared.decode(v34))
		flag = true

		for _, v35 in v32 do
			add(GroundFireShared.decode(v35))
		end

		table.clear(v32)
	end)
end

return GroundFireView