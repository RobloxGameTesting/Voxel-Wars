--!native
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local Quality = require(Voxel:WaitForChild("Quality"))
local Detail = require(Voxel:WaitForChild("Detail"))
local VoxelCore = require(Voxel:WaitForChild("VoxelCore"))
local WorldConfig = require(Voxel:WaitForChild("WorldConfig"))
local GroundFireShared = require(Voxel:WaitForChild("GroundFireShared"))

local VOXEL_SIZE = WorldConfig.VOXEL_SIZE
local v = WorldConfig.ORIGIN
WorldConfig.onOrigin(function(vector3: Vector3)
	v = vector3
end)
local chunk = VoxelCore.CHUNK

local v2 = { 10, 6, 3 }
local v3 = { 6, 8.5 }

local v4 = { 2.2, 9 }
local color = Color3.fromRGB(48, 46, 44)
local color2 = Color3.fromRGB(128, 126, 122)
local drift = GroundFireShared.WIND * 1.6

local v5 = 34 + (drift.Magnitude + 0.71) * v3[2] * 1.3 + v4[2] * 1.3 + 4

local function nearFade(vector3: Vector3, p: number) -- 1 equivalent call inferred from this helper
	if Detail.low then
		return math.floor(math.clamp((Detail.pixels(vector3, p) / Detail.screenY - 0.45) / 0.14999999999999997, 0, 1) * 4 + 0.5) / 4
	end

	return 0
end

local v6 = {}

local v7 = {}
local function bucketKey(p: number, p2: number) -- 2 equivalent calls inferred from this helper
	return (p + 32768) * 65536 + (p2 + 32768)
end

local v8 = {}
local v9 = {}
local v10 = {}
local flag = false
local parent = nil
local heartbeatConnection = nil
local total = 1e999
local random = Random.new()

local v11 = {}
local v12 = {}

local function acquire()
	local v13 = table.remove(v10)

	if v13 then
		return v13
	end

	if not parent then
		local damageSmokeFX = Instance.new("Folder")
		damageSmokeFX.Name = "DamageSmokeFX"
		damageSmokeFX.Parent = workspace
		parent = damageSmokeFX
	end

	local buildingSmoke = Instance.new("Part")
	buildingSmoke.Name = "BuildingSmoke"
	buildingSmoke.Anchored = true
	buildingSmoke.CanCollide = false
	buildingSmoke.CanQuery = false
	buildingSmoke.CanTouch = false
	buildingSmoke.CastShadow = false
	buildingSmoke.Size = Vector3.new(1, 1, 1)
	buildingSmoke.Material = Enum.Material.SmoothPlastic
	buildingSmoke.Color = color
	buildingSmoke.Transparency = 1
	buildingSmoke.TopSurface = Enum.SurfaceType.Smooth
	buildingSmoke.BottomSurface = Enum.SurfaceType.Smooth

	buildingSmoke.CFrame = CFrame.new(0, -10000, 0)
	buildingSmoke.Parent = parent
	return {
		part = buildingSmoke,
		phase = 0,
		period = 1,
		drift = drift,
		spin = 0,
		shown = -1,
		alpha = 1,
		size = 0,
		near = 0
	}
end

local function release(p) -- 2 equivalent calls inferred from this helper
	p.part.Transparency = 1
	p.alpha = 1
	p.shown = -1
	table.insert(v10, p)
end

local function fit(p, want: number)
	p.want = want

	if #p.puffs == want then
		return
	end

	while want < #p.puffs do
		release(table.remove(p.puffs)) -- inferred equivalent call
	end

	while #p.puffs < want do
		local v13 = acquire()
		v13.period = random:NextNumber(v3[1], v3[2])
		v13.drift = drift + Vector3.new(random:NextNumber(-0.5, 0.5), 0, random:NextNumber(-0.5, 0.5))
		v13.spin = random:NextNumber(-0.4, 0.4)
		table.insert(p.puffs, v13)
	end

	for k, puff in p.puffs do
		puff.phase = (k - 1) / want
		puff.shown = -1
	end
end

local function ease(p, want: number)
	if #p.puffs == 0 then
		fit(p, want)
		return
	end

	p.want = want

	while #p.puffs < want do
		local v13 = acquire()
		v13.period = random:NextNumber(v3[1], v3[2])
		v13.drift = drift + Vector3.new(random:NextNumber(-0.5, 0.5), 0, random:NextNumber(-0.5, 0.5))
		v13.spin = random:NextNumber(-0.4, 0.4)
		v13.phase = 0
		v13.shown = -1
		table.insert(p.puffs, v13)
	end
end

local function dropAll() -- 1 equivalent call inferred from this helper
	for _, v13 in v9 do
		fit(v13, 0)
	end

	table.clear(v9)
end

local function holePos(data) -- 1 equivalent call inferred from this helper
	return v + Vector3.new(data.sx / data.n + 0.5, data.top + 1, data.sz / data.n + 0.5) * VOXEL_SIZE
end

local function refresh()
	flag = false
	local v13 = {}

	for _, v14 in v6 do
		local v15 = v14.removed / v14.baseline

		if v15 < 0.05 or v14.removed < 1200 or #v14.holes == 0 then
			continue
		end

		local clone = table.clone(v14.holes)
		table.sort(clone, function(a, b): boolean
			return a.n > b.n
		end)

		local v16 = math.clamp(math.floor((v15 - 0.05) / 0.05) + 1, 1, 3)
		local thick = math.clamp(v15 / 0.15000000000000002, 0.55, 1)

		for i = 1, math.min(v16, #clone) do
			local v17 = clone[i]

			if i > 1 and v17.n < 150 then
				break
			end

			local v18 = v8[v17] or {
				pos = Vector3.new(0, 0, 0),
				thick = 0,
				puffs = {},
				lod = 0,
				want = 0
			}
			v18.pos = holePos(v17) -- inferred equivalent call
			v18.thick = thick
			v13[v17] = v18
		end
	end

	for k, v14 in v8 do
		if not v13[k] then
			fit(v14, 0)
		end
	end

	v8 = v13
end

local function select(position: Vector3)
	local v13 = not (Quality.mobile or Quality.potato) and 1000
		or math.min(1000, Quality.MOBILE_CUT_M * WorldConfig.METER)
	local magnitudes = {}
	local v14 = {}

	for _, v15 in v8 do
		local magnitude = (v15.pos - position).Magnitude

		if not (magnitude < v13) then
			continue
		end

		magnitudes[v15] = magnitude
		table.insert(v14, v15)
	end

	table.sort(v14, function(a, b): boolean
		return magnitudes[a] < magnitudes[b]
	end)

	local v15 = Quality.mobile and 0 or math.min(Quality.cap(10), not Quality.potato and 10 or Quality.SMOKE_DRAWN)
	local share = Quality.share()
	local set = {}

	for i = 1, math.min(#v14, v15) do
		set[v14[i]] = true
	end

	for _, v16 in v9 do
		if not set[v16] then
			fit(v16, 0)
		end
	end

	table.clear(v9)

	for i = 1, math.min(#v14, v15) do
		local v16 = v14[i]
		local v17 = magnitudes[v16]
		v16.lod = v17 < 160 and 1 or v17 < 420 and 2 or 3
		local v18

		if share < 1 then
			v18 = math.max(2, (math.floor(v2[v16.lod] * share + 0.5)))
		else
			v18 = v2[v16.lod]
		end

		if Detail.low then
			ease(v16, math.floor(v18 * Detail.scale(v16.pos, 12) + 0.5))
		else
			fit(v16, v18)
		end

		table.insert(v9, v16)
	end
end

local function step(p: number)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	total += p

	if total >= 0.5 then
		total = 0

		if flag then
			refresh()
		end

		select(currentCamera.CFrame.Position)
	end

	local cframe = currentCamera.CFrame
	local position = cframe.Position
	local lookVector = cframe.LookVector
	local viewportSize = currentCamera.ViewportSize
	local v13 = viewportSize.X / math.max(viewportSize.Y, 1)
	local v14 = math.cos((math.min(
		math.atan(math.tan(math.rad((math.max(currentCamera.FieldOfView, 80))) * 0.5) * math.sqrt(1 + v13 * v13)) + 0.5235987755982988,
		3.141592653589793
	)))
	local count = 0

	for _, v15 in v9 do
		local v16 = v15.lod == 3 and 1.3 or 1

		local vector = v15.pos - position
		local magnitude = vector.Magnitude
		local v17

		if magnitude <= v5 then
			v17 = true
		else
			local v18 = vector:Dot(lookVector) + v5
			v17 = magnitude * v14 <= v18
		end

		for i = #v15.puffs, 1, -1 do
			local puff = v15.puffs[i]
			local phase = puff.phase + p / puff.period

			if phase >= 1 then
				if #v15.puffs > v15.want then
					release(table.remove(v15.puffs, i)) -- inferred equivalent call
					continue
				end

				phase -= math.floor(phase)
				puff.period = random:NextNumber(v3[1], v3[2])
				puff.drift = drift + Vector3.new(random:NextNumber(-0.5, 0.5), 0, random:NextNumber(-0.5, 0.5))
				puff.spin = random:NextNumber(-0.4, 0.4)
			end

			puff.phase = phase

			if not v17 then
				continue
			end

			local v18 = phase * puff.period
			local size = (v4[1] + (v4[2] - v4[1]) * phase ^ 0.7) * v16 * (v15.thick * 0.3 + 0.7)

			local v19 = v15.thick * 34 * (1 - (1 - phase) ^ 1.6)
			local vector3 = v15.pos + Vector3.new(0, v19, 0) + puff.drift * v18 * (phase + 0.3)
			count += 1
			v11[count] = puff.part
			v12[count] = CFrame.new(vector3) * CFrame.Angles(0, puff.spin * v18, puff.spin * 0.5 * v18)

			if math.abs(size - puff.size) > puff.size * 0.03 then
				puff.size = size
				puff.part.Size = Vector3.new(size, size * 0.85, size)
			end

			local shown = math.floor(phase * 12)
			local near = nearFade(vector3, size) -- inferred equivalent call

			if not (shown ~= puff.shown or near ~= puff.near) then
				continue
			end

			puff.shown = shown
			puff.near = near
			local v20 = shown / 12
			puff.part.Color = color:Lerp(color2, v20)
			local v21

			if v20 < 0.1 then
				v21 = 1 - v20 * 6
			else
				v21 = v20 ^ 1.5 * 0.6 + 0.4
			end

			local v22 = 1 - (1 - math.clamp(v21, 0, 1)) * (v15.thick * 0.4 + 0.55) * (1 - near)
			puff.part.Transparency = v22
			puff.alpha = v22
		end
	end

	if count > 0 then
		for i = count + 1, #v11 do
			v11[i] = nil
			v12[i] = nil
		end

		workspace:BulkMoveTo(v11, v12, Enum.BulkMoveMode.FireCFrameChanged)
	end

	if next(v8) == nil and not flag and heartbeatConnection then
		dropAll() -- inferred equivalent call
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

local function wake() -- 1 equivalent call inferred from this helper
	if heartbeatConnection == nil then
		total = 1e999
		heartbeatConnection = RunService.Heartbeat:Connect(step)
	end
end

local DamageSmoke = {}

function DamageSmoke.reset(p, items)
	for _, v13 in v8 do
		fit(v13, 0)
	end

	table.clear(v8)
	table.clear(v9)
	table.clear(v6)
	flag = false

	for _, item in items do
		local total2 = 0

		for i = item.min.Z // chunk, item.max.Z // chunk do
			for j = item.min.Y // chunk, item.max.Y // chunk do
				for k = item.min.X // chunk, item.max.X // chunk do
					local chunk2 = p.chunks[VoxelCore.chunkKey(k, j, i)]
					local v13 = k * chunk + chunk * 0.5
					local v14 = j * chunk + chunk * 0.5
					local v15 = i * chunk + chunk * 0.5

					if not (chunk2 and item.min.X <= v13 and v13 <= item.max.X + 1 and item.min.Y <= v14) then
						continue
					end

					if not (v14 <= item.max.Y + 1 and item.min.Z <= v15 and v15 <= item.max.Z + 1) then
						continue
					end

					total2 += chunk2.count
				end
			end
		end

		if total2 > 0 then
			table.insert(v6, {
				min = item.min,
				max = item.max,
				baseline = total2,
				removed = 0,
				holes = {},
				last = nil
			})
		end
	end

	table.clear(v7)

	for _, v13 in v6 do
		for i = v13.min.X // 32, v13.max.X // 32 do
			for j = v13.min.Z // 32, v13.max.Z // 32 do
				local v14 = bucketKey(i, j) -- inferred equivalent call
				local v15 = v7[v14]

				if v15 then
					table.insert(v15, v13)
				else
					v7[v14] = { v13 }
				end
			end
		end
	end
end

function DamageSmoke.removed(sx: number, p: number, sz: number)
	local v13 = v7[bucketKey(sx // 32, sz // 32)] -- inferred equivalent call

	if v13 == nil then
		return
	end

	for _, v14 in v13 do
		local min = v14.min
		local max = v14.max

		if not (sx < min.X or max.X < sx or p < min.Y or max.Y < p or sz < min.Z or max.Z < sz) then
			v14.removed += 1

			local last2 = nil
			local v15 = 1e999
			local last = v14.last

			if last then
				local v16 = last.sx / last.n - sx
				local v17 = last.sy / last.n - p
				local v18 = last.sz / last.n - sz
				local v19 = v16 * v16 + v17 * v17 + v18 * v18

				if v19 <= 576 then
					v15 = v19
					last2 = last
				end
			end

			if last2 == nil then
				for _, hole in v14.holes do
					local v16 = hole.sx / hole.n - sx
					local v17 = hole.sy / hole.n - p
					local v18 = hole.sz / hole.n - sz
					local v19 = v16 * v16 + v17 * v17 + v18 * v18

					if not (v19 < v15) then
						continue
					end

					last2 = hole
					v15 = v19
				end
			end

			if last2 and (v15 <= 576 or #v14.holes >= 24) then
				last2.sx += sx
				last2.sy += p
				last2.sz += sz
				last2.n += 1
				last2.top = math.max(last2.top, p)
				v14.last = last2
			else
				local last3 = {
					sx = sx,
					sy = p,
					sz = sz,
					n = 1,
					top = p
				}
				table.insert(v14.holes, last3)
				v14.last = last3
			end

			if v14.removed >= 1200 and v14.removed >= v14.baseline * 0.05 then
				flag = true
				wake() -- inferred equivalent call
			end

			break
		end
	end
end

return DamageSmoke