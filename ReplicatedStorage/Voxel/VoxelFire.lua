--!native
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local Quality = require(Voxel:WaitForChild("Quality"))
local Detail = require(Voxel:WaitForChild("Detail"))
local WorldConfig = require(Voxel:WaitForChild("WorldConfig"))
local VoxelSound = require(Voxel:WaitForChild("VoxelSound"))
local Remotes = Voxel:WaitForChild("Remotes")

local VOXEL_SIZE = WorldConfig.VOXEL_SIZE
local v = WorldConfig.ORIGIN
WorldConfig.onOrigin(function(p)
	v = p
end)
local unpackKey = WorldConfig.unpackKey

local VoxelFire = {}
VoxelFire.onCell = nil
VoxelFire.onClear = nil
local color = Color3.fromRGB(255, 214, 112)
local color2 = Color3.fromRGB(255, 128, 40)
local color3 = Color3.fromRGB(196, 54, 24)

local color4 = Color3.fromRGB(46, 44, 42)
local color5 = Color3.fromRGB(104, 101, 97)

local color6 = Color3.fromRGB(255, 142, 62)

local function nearFade(vector3: Vector3, p: number) -- 1 equivalent call inferred from this helper
	if Detail.low then
		return math.floor(math.clamp((Detail.pixels(vector3, p) / Detail.screenY - 0.45) / 0.14999999999999997, 0, 1) * 4 + 0.5) / 4
	end

	return 0
end

local v2 = {}
local v3 = {}
local bins = 0

local rigs = {}
local v4 = {}
local v5 = {}

local parent = nil
local v6 = nil
local v7 = {}
local v8 = {}
local v9 = {}
local v10 = {}

local v11 = {}
local v12 = {}

local random = Random.new()
local heartbeatConnection = nil
local total = 1e999
local total2 = 0

local v13 = {
	cells = 0,
	bins = 0,
	rigs = 0,
	parts = 0,
	lights = 0,
	frameMs = 0,
	messages = 0
}

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
	v13.parts += 1
	return part
end

local function newRig()
	assert(#rigs < 16, "[VoxelFire] rig pool overflow")
	local rig = {
		bin = nil,
		tongues = {},
		puffs = {},
		light = 0,
		lod = 0,
		dist = 0,
		seed = random:NextNumber(0, 100),
		glow = 1,
		smoke = 0
	}

	for i = 1, 3 do
		local part = newPart("Flame", Enum.Material.Neon, color)
		rig.tongues[i] = {
			part = part,
			phase = 0,
			period = 1,
			base = Vector3.new(0, 0, 0),
			yaw = 0,
			seed = random:NextNumber(0, 100),
			shown = -1,
			alpha = 1,
			w = -1,
			h = -1
		}
	end

	for i = 1, 3 do
		local part = newPart("Smoke", Enum.Material.SmoothPlastic, color4)
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
			w = -1
		}
	end

	table.insert(rigs, rig)
	return rig
end

local function hideRig(p)
	for _, tongue in p.tongues do
		if not (tongue.alpha < 1) then
			continue
		end

		tongue.part.Transparency = 1
		tongue.alpha = 1
	end

	for _, puff in p.puffs do
		if not (puff.alpha < 1) then
			continue
		end

		puff.part.Transparency = 1
		puff.alpha = 1
	end
end

local function releaseRig(p) -- 3 equivalent calls inferred from this helper
	local bin = p.bin

	if bin then
		bin.rig = nil
	end

	p.bin = nil
	hideRig(p)
	table.insert(v4, p)
end

local function cellPos(p: number) -- 4 equivalent calls inferred from this helper
	local v14, v15, v16 = unpackKey(p)
	return v + Vector3.new(v14 + 0.5, v15 + 0.5, v16 + 0.5) * VOXEL_SIZE
end

local function centroid(data) -- 6 equivalent calls inferred from this helper
	return v + (Vector3.new(data.sx, data.sy, data.sz) / data.n + Vector3.new(0.5, 0.5, 0.5)) * VOXEL_SIZE
end

local onHeartbeat

local function addCell(p: number)
	if v2[p] then
		return
	end

	local v14, v15, v16 = unpackKey(p)
	local packKey = WorldConfig.packKey(v14 // 8, v15 // 8, v16 // 8)
	local v17 = v3[packKey]

	if not v17 then
		v17 = {
			key = packKey,
			list = {},
			at = {},
			n = 0,
			sx = 0,
			sy = 0,
			sz = 0,
			rig = nil
		}
		v3[packKey] = v17
		bins += 1
	end

	assert(v17)
	v17.n += 1
	v17.list[v17.n] = p
	v17.at[p] = v17.n
	v17.sx += v14
	v17.sy += v15
	v17.sz += v16
	v2[p] = v17
	v13.cells += 1

	if VoxelFire.onCell then
		VoxelFire.onCell(v14, v15, v16, 1)
	end

	if heartbeatConnection == nil then
		total = 1e999
		heartbeatConnection = RunService.Heartbeat:Connect(onHeartbeat)
	end
end

local function removeCell(p: number)
	local v14 = v2[p]

	if not v14 then
		return
	end

	v2[p] = nil
	v13.cells -= 1
	local v15 = v14.at[p]
	local item = v14.list[v14.n]
	v14.list[v15] = item
	v14.at[item] = v15
	v14.list[v14.n] = nil
	v14.at[p] = nil
	v14.n -= 1
	local v16, v17, v18 = unpackKey(p)
	v14.sx -= v16
	v14.sy -= v17
	v14.sz -= v18

	if VoxelFire.onCell then
		VoxelFire.onCell(v16, v17, v18, -1)
	end

	if v14.n == 0 then
		v3[v14.key] = nil
		bins -= 1
		local rig = v14.rig

		if rig then
			releaseRig(rig) -- inferred equivalent call
			local index = table.find(v5, rig)

			if index then
				table.remove(v5, index)
			end
		end
	end
end

local function clearAll()
	for _, v14 in v5 do
		releaseRig(v14) -- inferred equivalent call
	end

	table.clear(v5)
	table.clear(v2)
	table.clear(v3)
	bins = 0
	v13.cells = 0

	if VoxelFire.onClear then
		VoxelFire.onClear()
	end
end

local function smokeCount(p)
	local v14 = p.lod == 1 and 3 or 2

	if Quality.mobile or Quality.potato then
		v14 -= 1
	end

	if Detail.low and p.bin then
		local scale = Detail.scale
		return (math.floor(v14 * scale(centroid(p.bin), 12) + 0.5)) -- inferred equivalent call
	end

	return v14
end

local function select(position: Vector3)
	local mobile = Quality.mobile or Quality.potato
	local v14 = not mobile and 650
		or math.min(650, Quality.MOBILE_CUT_M * WorldConfig.METER, Quality.mobile and 220 or 650)

	local v15 = math.max(Quality.MIN_FIRE_RIGS, (math.min(Quality.mobile and 4 or 16, Quality.cap(16))))
	local magnitudes = {}
	local v16 = {}
	local v17 = mobile and 98 or 140
	local v18 = mobile and 224 or 320

	for _, v19 in v3 do
		local magnitude = (centroid(v19) - position).Magnitude -- inferred equivalent call

		if not (magnitude < v14) then
			continue
		end

		magnitudes[v19] = magnitude
		table.insert(v16, v19)
	end

	table.sort(v16, function(a, b): boolean
		return magnitudes[a] < magnitudes[b]
	end)

	local set = {}

	for i = 1, math.min(#v16, v15) do
		set[v16[i]] = true
	end

	for i = #v5, 1, -1 do
		local v19 = v5[i]
		local bin = v19.bin

		if bin and set[bin] then
			continue
		end

		releaseRig(v19) -- inferred equivalent call
		table.remove(v5, i)
	end

	table.clear(v5)

	for i = 1, math.min(#v16, v15) do
		local bin = v16[i]
		local rig = bin.rig
		local v19 = not rig

		if not rig then
			rig = table.remove(v4) or newRig()
			assert(rig)
			rig.bin = bin
			bin.rig = rig

			for _, tongue in rig.tongues do
				tongue.phase = random:NextNumber()
				tongue.period = random:NextNumber(0.45, 0.75)
				tongue.base = cellPos(bin.list[random:NextInteger(1, bin.n)]) -- inferred equivalent call
				tongue.yaw = random:NextNumber(0, 3.141592653589793)
			end

			for _, puff in rig.puffs do
				puff.phase = random:NextNumber()
				puff.period = random:NextNumber(2.6, 3.6)
				puff.base = cellPos(bin.list[random:NextInteger(1, bin.n)]) -- inferred equivalent call
				puff.drift = Vector3.new(1.1, 0, 0.45) + Vector3.new(
					random:NextNumber(-0.4, 0.4),
					0,
					random:NextNumber(-0.4, 0.4)
				)
				puff.spin = random:NextNumber(-0.6, 0.6)
			end
		end

		rig.dist = magnitudes[bin]
		rig.lod = magnitudes[bin] < v17 and 1 or magnitudes[bin] < v18 and 2 or 3
		local smoke

		if Quality.mobile then
			smoke = 0
		else
			smoke = rig.lod == 1 and 3 or 2

			if Quality.mobile or Quality.potato then
				smoke -= 1
			end

			if Detail.low and rig.bin then
				local scale = Detail.scale
				smoke = math.floor(smoke * scale(centroid(rig.bin), 12) + 0.5) -- inferred equivalent call
			end
		end

		rig.smoke = smoke

		if v19 then
			for k, puff in rig.puffs do
				puff.on = k <= rig.smoke
			end
		end

		table.insert(v5, rig)
	end

	local v19 = table.create(#v5)

	for k, v20 in v5 do
		v19[k] = centroid(v20.bin) -- inferred equivalent call
	end

	for k, v20 in v5 do
		local v21 = v19[k]
		local count = 0

		for i = 1, #v5 do
			if i == k then
				continue
			end

			local vector = v19[i] - v21

			if vector:Dot(vector) < 196 then
				count += 1
			end
		end

		v20.glow = 0.6 / math.sqrt(count + 1) + 0.4
	end

	local count = 0
	local v20

	if Quality.potato then
		v20 = Quality.FIRE_LIGHTS
	else
		v20 = Quality.mobile and 0 or 6
	end

	for _, v21 in v5 do
		v21.light = 0

		if not (v21.lod == 1 and count < v20) then
			continue
		end

		count += 1
		v21.light = count
	end

	for i = 1, 6 do
		local enabled = i <= count

		if v12[i] == enabled then
			continue
		end

		v12[i] = enabled
		v7[i].Enabled = enabled
	end

	v13.lights = count

	local v21 = {}

	for i = 1, VoxelSound.FIRE_SLOTS do
		local v22 = v5[i]
		local bin = v22 and v22.bin

		if bin then
			table.insert(v21, {
				pos = centroid(bin), -- inferred equivalent call
				volume = math.clamp(0.3 + bin.n / 30, 0.3, 1)
			})
		end
	end

	VoxelSound.fireSources("wood", v21)
	v13.rigs = #v5
	v13.bins = bins
end

local v14 = {}
local v15 = {}

local function lerpColor(color7: Color3, color8: Color3, value: number) -- 3 equivalent calls inferred from this helper
	return color7:Lerp(color8, (math.clamp(value, 0, 1)))
end

onHeartbeat = function(p: number)
	local lastTime = os.clock()

	if bins == 0 then
		VoxelSound.fireSources("wood", {})

		for k, v16 in v7 do
			v12[k] = false
			v16.Enabled = false
		end

		clearAll()

		if heartbeatConnection then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end

		v13.rigs = 0
		v13.bins = 0
		v13.lights = 0
	else
		total2 += p
		local currentCamera = workspace.CurrentCamera

		if not currentCamera then
			return
		end

		total += p

		if total >= 0.4 then
			total = 0
			select(currentCamera.CFrame.Position)
		end

		local low = Detail.low
		local count = 0

		for _, v16 in v5 do
			local bin = v16.bin

			if not bin then
				continue
			end

			local v17 = math.clamp(math.sqrt(bin.n) / 3.5, 0.55, 1.7)
			local lod = v16.lod
			local vector3 = centroid(bin) -- inferred equivalent call
			local v18 = Detail.onScreen(vector3 + Vector3.new(0, 12, 0), 26 + Detail.distance(vector3) * 0.35)
			local v19 = 0.4 / math.max(Detail.pixels(vector3, 1), 0.01)
			local v20 = lod == 1 and 3 or lod == 2 and 2 or 1
			local smoke = v16.smoke
			local v21 = lod == 3 and 1.6 or 1

			for k, tongue in v16.tongues do
				if v20 < k then
					if tongue.alpha < 1 then
						tongue.part.Transparency = 1
						tongue.alpha = 1
					end
				else
					local phase = tongue.phase + p / tongue.period

					if phase >= 1 then
						phase -= math.floor(phase)
						tongue.period = random:NextNumber(0.45, 0.75)
						tongue.base = cellPos(bin.list[random:NextInteger(1, bin.n)]) -- inferred equivalent call
						tongue.yaw = random:NextNumber(0, 3.141592653589793)
					end

					tongue.phase = phase

					if v18 then
						local v22 = v17 * 1.9 * v21 * (math.sin(3.141592653589793 * phase) * 0.45 + 0.55)
						local v23 = v17 * 1 * v21 * (1 - phase * 0.55)
						local v24 = math.sin(total2 * 7 + tongue.seed) * 0.15 * v17
						local vector3_2 = tongue.base + Vector3.new(
							v24,
							VOXEL_SIZE * 0.5 + phase * 1.9 * v17 * 0.6 + v22 * 0.5,
							v24 * 0.6
						)
						count += 1
						v14[count] = tongue.part
						v15[count] = CFrame.Angles(v24 * 0.4, tongue.yaw + phase * 1.2, v24 * 0.3) + vector3_2

						if v19 < math.abs(v23 - tongue.w) or v19 < math.abs(v22 - tongue.h) then
							tongue.w = v23
							tongue.h = v22
							tongue.part.Size = Vector3.new(v23, v22, v23)
						end

						local shown = math.floor(phase * 8)

						if shown ~= tongue.shown then
							tongue.shown = shown
							local v25 = shown / 8
							local part = tongue.part
							local color7

							if v25 < 0.4 then
								color7 = lerpColor(color, color2, v25 / 0.4) -- inferred equivalent call
							else
								color7 = lerpColor(color2, color3, (v25 - 0.4) / 0.6) -- inferred equivalent call
							end

							part.Color = color7
							local v26 = 1 - (1 - math.min(v25 < 0.5 and 0.08 or (v25 - 0.5) * 1.4 + 0.08, 1)) * 0.85 * v16.glow

							local v27 = Quality.mobile and (v16.glow > 0.3 and 0 or 1) or v26

							tongue.part.Transparency = v27
							tongue.alpha = v27
						end
					end
				end
			end

			for k, puff in v16.puffs do
				local on = k <= smoke

				if not low then
					puff.on = on
				end

				if puff.on or low and on then
					local phase = puff.phase + p / puff.period

					if phase >= 1 then
						phase -= math.floor(phase)
						puff.period = random:NextNumber(2.6, 3.6)
						puff.base = cellPos(bin.list[random:NextInteger(1, bin.n)]) -- inferred equivalent call
						puff.drift = Vector3.new(1.1, 0, 0.45) + Vector3.new(
							random:NextNumber(-0.4, 0.4),
							0,
							random:NextNumber(-0.4, 0.4)
						)
						puff.spin = random:NextNumber(-0.6, 0.6)

						if low then
							puff.on = on
						end
					end

					puff.phase = phase

					if puff.on then
						if v18 then
							local v22 = (phase * 2.6999999999999997 + 1.1) * v17
							local v23 = phase * puff.period
							local vector3_2 = puff.base + Vector3.new(0, phase * 11 * v17 + 1.2, 0) + puff.drift * v23
							count += 1
							v14[count] = puff.part
							v15[count] = CFrame.Angles(0, puff.spin * v23, puff.spin * 0.5 * v23) + vector3_2

							if v19 < math.abs(v22 - puff.w) then
								puff.w = v22
								puff.part.Size = Vector3.new(v22, v22, v22)
							end

							local shown = math.floor(phase * 12)
							local near = nearFade(vector3_2, v22) -- inferred equivalent call

							if shown ~= puff.shown or near ~= puff.near then
								puff.shown = shown
								puff.near = near
								local v24 = shown / 12
								puff.part.Color = lerpColor(color4, color5, v24) -- inferred equivalent call
								local v25

								if v24 < 0.1 then
									v25 = 1 - v24 * 6
								else
									v25 = v24 ^ 1.5 * 0.6 + 0.4
								end

								local v26 = 1 - (1 - math.clamp(v25, 0, 1)) * (1 - near)
								puff.part.Transparency = v26
								puff.alpha = v26
							end
						end
					elseif puff.alpha < 1 then
						puff.part.Transparency = 1
						puff.alpha = 1
					end
				elseif puff.alpha < 1 then
					puff.part.Transparency = 1
					puff.alpha = 1
				end
			end

			local light = v16.light

			if not (light > 0) then
				continue
			end

			local v22 = v7[light]

			local v23 = Detail.low and 0
				or math.sin(total2 * 13 + v16.seed) * 0.25 + math.sin(total2 * 7.3 + v16.seed * 2) * 0.2 + math.sin(total2 * 23 + v16.seed) * 0.1
			local brightness = (v17 * 0.5 + 1.3 + v23) * 0.85 * v16.glow

			if math.abs(brightness - (v10[light] or -1)) >= 0.04 then
				v10[light] = brightness
				v22.Brightness = brightness
			end

			local range = v17 * 6 + 8

			if Detail.low then
				range = math.round(range * 2) / 2
			end

			if v9[light] ~= range then
				v9[light] = range
				v22.Range = range
			end

			local worldPosition = vector3 + Vector3.new(0, 1.5, 0)

			if Detail.low then
				worldPosition = Vector3.new(
					math.round(worldPosition.X),
					math.round(worldPosition.Y),
					(math.round(worldPosition.Z))
				)
			end

			if v11[light] == worldPosition then
				continue
			end

			v11[light] = worldPosition
			v8[light].WorldPosition = worldPosition
		end

		if count > 0 then
			for i = count + 1, #v14 do
				v14[i] = nil
				v15[i] = nil
			end

			workspace:BulkMoveTo(v14, v15, Enum.BulkMoveMode.FireCFrameChanged)
		end

		v13.frameMs = (os.clock() - lastTime) * 1000
	end
end

local v16 = -1
local v17 = false
local v18 = {}

local function applyDelta(buf: buffer, buf2: buffer)
	for i = 0, buffer.len(buf2) // 4 - 1 do
		removeCell(buffer.readu32(buf2, i * 4))
	end

	for i = 0, buffer.len(buf) // 4 - 1 do
		addCell(buffer.readu32(buf, i * 4))
	end
end

function VoxelFire.start()
	assert(parent == nil, "[VoxelFire] started twice")
	local voxelFireFX = Instance.new("Folder")
	voxelFireFX.Name = "VoxelFireFX"
	voxelFireFX.Parent = workspace
	parent = voxelFireFX
	local fireLights = Instance.new("Part")
	fireLights.Name = "FireLights"
	fireLights.Anchored = true
	fireLights.CanCollide = false
	fireLights.CanQuery = false
	fireLights.CanTouch = false
	fireLights.Transparency = 1
	fireLights.Size = Vector3.new(0.2, 0.2, 0.2)
	fireLights.CFrame = CFrame.new()
	fireLights.Parent = voxelFireFX
	v6 = fireLights

	for i = 1, 6 do
		local attachment = Instance.new("Attachment")
		attachment.Name = "Light" .. i
		attachment.Parent = fireLights
		local pointLight = Instance.new("PointLight")
		pointLight.Color = color6
		pointLight.Shadows = false
		pointLight.Enabled = false
		pointLight.Parent = attachment
		v8[i] = attachment
		v7[i] = pointLight
	end

	Remotes:WaitForChild("VoxelFire").OnClientEvent:Connect(function(buf: buffer, buf2: buffer, p: number, p2: number)
		v13.messages += 1

		if not v17 then
			table.insert(v18, { buf, buf2, p, p2 })
		elseif p2 == v16 then
			applyDelta(buf, buf2)
		end
	end)
	Remotes:WaitForChild("WorldReset").OnClientEvent:Connect(function(p: number)
		if v17 and v16 < p then
			v16 = p
			clearAll()
		end
	end)
	task.spawn(function()
		local v19, v20, v21 = Remotes:WaitForChild("VoxelFireSnapshot"):InvokeServer()
		local v22 = typeof(v19) == "buffer" and typeof(v20) == "number" and typeof(v21) == "number"
		assert(v22, "[VoxelFire] bad fire snapshot")
		v16 = v21

		for i = 0, buffer.len(v19) // 4 - 1 do
			addCell(buffer.readu32(v19, i * 4))
		end

		for _, v23 in v18 do
			if v23[4] == v16 and v20 < v23[3] then
				applyDelta(v23[1], v23[2])
			end
		end

		table.clear(v18)
		v17 = true
	end)
end

function VoxelFire.eachCell(callback)
	for k in v2 do
		callback(unpackKey(k))
	end
end

function VoxelFire.stats()
	return table.clone(v13)
end

return VoxelFire