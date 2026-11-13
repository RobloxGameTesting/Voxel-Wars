do
	local Players = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer

	while LocalPlayer:GetAttribute("JoinCovered") == true do
		LocalPlayer:GetAttributeChangedSignal("JoinCovered"):Wait()
	end
end

task.wait(0.2)

local Players = game:GetService("Players")
local parent2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")

local localPlayer = Players.LocalPlayer

local object = setmetatable({}, { __mode = "k" })
local function attr(instance, p: string) -- 53 equivalent calls inferred from this helper
	local attributesByAttributeName = object[instance]

	if attributesByAttributeName == nil then
		attributesByAttributeName = instance:GetAttributes()

		object[instance] = attributesByAttributeName
		instance.AttributeChanged:Connect(function(attributeName)
			attributesByAttributeName[attributeName] = instance:GetAttribute(attributeName)
		end)
	end

	return attributesByAttributeName[p]
end

local vehicles = parent2:WaitForChild("Vehicles")
local remotes = vehicles:WaitForChild("Remotes")
local live = vehicles:WaitForChild("Live")

local VehicleConfig = require(vehicles:WaitForChild("VehicleConfig"))
local ShellFlight = require(vehicles:WaitForChild("ShellFlight"))
local PoseTiming = require(vehicles:WaitForChild("PoseTiming"))
local VehicleGrid = require(vehicles:WaitForChild("VehicleGrid"))
local VehicleSim = require(vehicles:WaitForChild("VehicleSim"))
local SeatedBots = require(vehicles:WaitForChild("SeatedBots"))
local VoxelCore = require(parent2.Voxel:WaitForChild("VoxelCore"))
local Materials = require(parent2.Voxel:WaitForChild("Materials"))
local WorldConfig = require(parent2.Voxel:WaitForChild("WorldConfig"))
local AudioGraph = require(parent2.Voxel:WaitForChild("AudioGraph"))
local VoxelSound = require(parent2.Voxel:WaitForChild("VoxelSound"))
local BattleFX = require(parent2.Voxel:WaitForChild("BattleFX"))
local Quality = require(parent2.Voxel:WaitForChild("Quality"))
local LooseChunks = require(script.Parent:WaitForChild("VoxelRender"):WaitForChild("LooseChunks"))
local TouchControls = require(parent2.Voxel:WaitForChild("TouchControls"))
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LookSettings = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("LookSettings"))
local MenuLock = require(parent2.Voxel:WaitForChild("MenuLock"))
local EnterButton = require(parent2.Voxel:WaitForChild("EnterButton"))
local Glyph = require(script.Parent:WaitForChild("GameUI"):WaitForChild("Glyph"))

local MountedGun = require(script:WaitForChild("MountedGun"))
local RigidParts = require(vehicles:WaitForChild("RigidParts"))
local Detail = require(parent2.Voxel:WaitForChild("Detail"))

local object2 = setmetatable({}, { __mode = "k" })
local object3 = setmetatable({}, { __mode = "k" })

local function tune(p, volume: number, playbackSpeed: number)
	local player = p.player
	local v = object2[player]

	if v == nil or math.abs(volume - v) >= 0.002 or volume == 0 and v ~= 0 then
		object2[player] = volume
		player.Volume = volume
	end

	local v2 = object3[player]

	if v2 == nil or math.abs(playbackSpeed - v2) >= 0.002 then
		object3[player] = playbackSpeed
		player.PlaybackSpeed = playbackSpeed
	end

	local v3 = not Detail.low and 0 or Detail.strain
	local v4

	if v3 <= 0 then
		v4 = 0.001
	elseif v3 == 1 then
		v4 = 0.015
	else
		v4 = if v3 == 2 then 0.025 else 0.04
	end

	if volume < v4 then
		if AudioGraph.awake(p) then
			player:Stop()
			AudioGraph.park(p)
		end
	elseif not player.IsPlaying and (v3 <= 0 or v4 * 1.5 <= volume) then
		AudioGraph.route(p, "dry")
		player.TimePosition = player.LoopRegion.Min
		player:Play()
	end
end

local modules = {
	Humvee = require(vehicles:WaitForChild("HumveeModel")),
	Tank = require(vehicles:WaitForChild("TankModel")),
	Bradley = require(vehicles:WaitForChild("BradleyModel"))
}

local TankCannon = VehicleConfig.TankCannon

local Palette = Materials.Palette
local VOXEL_SIZE = WorldConfig.VOXEL_SIZE

local v = {
	idle = { id = 9112971190, loop = NumberRange.new(45, 75), gain = 1 },
	low = { id = 9112735582, loop = NumberRange.new(2, 31), gain = 0.9 },
	high = { id = 9112735637, loop = NumberRange.new(6, 22), gain = 0.8 },
	roll = { id = 9112886781, loop = NumberRange.new(0.5, 26.5), gain = 0.39 },
	skid = { id = 9126157079, loop = NumberRange.new(3, 14), gain = 0.5 },
	start = { id = 9112970955, at = 0, length = 2.5, gain = 0.9 },
	stop = {
		id = 9112971190,
		at = 118,
		length = 3,
		fade = 1,
		gain = 0.8
	},
	gear = { id = 9112973735, at = 0, length = 1, gain = 0.5 },
	tracks = { id = 9112890083, loop = NumberRange.new(2, 29), gain = 0.6 },
	cannon = {
		id = 9114361763,
		at = 0,
		length = 3.5,
		gain = 1.6,
		range = 900
	},
	autocannon = {
		id = 9114361755,
		cuts = { 0, 1.54 },
		length = 0.9,
		gain = 1.1,
		range = 700,
		lo = 0.8,
		hi = 0.9
	},
	load = {
		id = 2721754456,
		at = 0,
		length = 2.6,
		gain = 1.8,
		delay = 0.45,
		range = 70
	},
	lock = {
		id = 74591582062201,
		at = 0,
		length = 1.17,
		gain = 0.8,
		lead = 0.2,
		range = 90
	}
}

local v2 = {
	terrain = {
		{ 9113806564, 0.14, 0.88 },
		{ 9113806896, 0.24, 1.44 },
		{ 9113805800, 0.32, 0.89 },
		{ 9113805612, 0.64, 1.14 }
	},
	light = {
		{ 9116700611, 0.42, 0.68 },
		{ 9116700296, 0.4, 0.63 },
		{ 9116700477, 0.73, 0.88 },
		{ 9116684884, 0.22, 0.71 }
	},
	heavy = {
		{ 9114203990, 0.14, 0.94 },
		{ 9114204589, 0.72, 1.48 },
		{ 9114204396, 0.58, 0.86 }
	},
	crash = {
		{ 9116546326, 0.24, 1.04 }
	},
	scrape = {
		{ 9126155918, 0.1, 1.8 },
		{ 9126155941, 0.67, 1.93 },
		{ 9126155942, 0.36, 1.7 },
		{ 9126155907, 0, 1.58 }
	}
}

local color = Color3.fromRGB(24, 25, 28)
local color2 = Color3.fromRGB(242, 238, 228)
local color3 = Color3.fromRGB(255, 198, 32)
local color4 = Color3.fromRGB(214, 72, 52)
local rbxassetfontsfamiliesOswaldjson = Font.new("rbxasset://fonts/families/Oswald.json", Enum.FontWeight.Bold)

local vehicleHulls = Instance.new("Folder")
vehicleHulls.Name = "VehicleHulls"
vehicleHulls.Parent = workspace

local random = Random.new()

local ground = {}

do
	local AirDefense = require(vehicles:WaitForChild("AirDefense"))
	AirDefense.ground = ground
end

local v3 = {
	"S" .. 1,
	"S" .. 2,
	"S" .. 3,
	"S" .. 4,
	"S" .. 5,
	"S" .. 6,
	"S" .. 7,
	"S" .. 8,
	"S" .. 9,
	"S" .. 10,
	"S" .. 11,
	"S" .. 12,
	"S" .. 13,
	"S" .. 14,
	"S" .. 15,
	"S" .. 16
}

local function refreshParams(p)
	local excludeInstances = { p.model }

	for _, childName in { "VoxelLoose", "VoxelChips", "VoxelFalling", "BotRigs", "VoxelBombs" } do
		local child = workspace:FindFirstChild(childName)

		if child then
			table.insert(excludeInstances, child)
		end
	end

	for _, v4 in Players:GetPlayers() do
		if v4.Character then
			table.insert(excludeInstances, v4.Character)
		end
	end

	if workspace.CurrentCamera then
		table.insert(excludeInstances, workspace.CurrentCamera)
	end

	p.params.ExcludeInstances = excludeInstances
end

do
	local function seatCount(p) -- 2 equivalent calls inferred from this helper
		return #p.def.seats
	end
end

local function seatOf(p, userId: number)
	for i = 1, seatCount(p) do -- inferred equivalent call
		if attr(p.folder, v3[i]) == userId then -- inferred equivalent call
			return i
		end
	end

	return 0
end

do
	local function newPart(model, flag: boolean) -- 4 equivalent calls inferred from this helper
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanTouch = false
		part.CanCollide = flag
		part.CanQuery = flag
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		part.CollisionGroup = "VehicleBody"
		part.CFrame = RigidParts.PARK
		part.Parent = model
		return part
	end
end

local v4 = {}

do
	local function scratch(p: number, size: number) -- 4 equivalent calls inferred from this helper
		local v5 = v4[p]

		if v5 == nil or buffer.len(v5) < size then
			v5 = buffer.create(size)
			v4[p] = v5
		end

		return v5
	end
end

do
	local function look(p, p2: number) -- 2 equivalent calls inferred from this helper
		local v5 = Palette[p2]
		p.Color = v5.color
		p.Material = v5.material
		p.MaterialVariant = v5.variant
		p.Transparency = v5.transparency
		p.CastShadow = v5.transparency == 0
	end
end

local color5 = Color3.fromRGB(46, 36, 30)
local function charHull(state)
	local char = state.char or 0
	local lamps = state.def.lamps

	for k, hullPart in state.hullParts do
		local hullPal = state.hullPals[k]
		local v5 = Palette[hullPal]

		if v5.transparency == 0 and hullPal ~= lamps.head and hullPal ~= lamps.tail then
			hullPart.Color = v5.color:Lerp(color5, char)
		end
	end

	local colors = state.pieceBase

	if not colors then
		colors = {}
		state.pieceBase = colors
	end

	for _, v5 in { state.turretParts, state.gunParts } do
		for _, v6 in v5 do
			if colors[v6] == nil then
				colors[v6] = v6.Color
			end

			v6.Color = colors[v6]:Lerp(color5, char)
		end
	end
end

local v5 = {}

@native local function rebuildSolid(data)
	local def = data.def
	local sx = def.sx
	local sy = def.sy
	local sz = def.sz

	local v6 = math.ceil(sx / 3)
	local v7 = math.ceil(sy / 3)
	local v8 = math.ceil(sz / 3)
	local buf = scratch(1, v6 * v7 * v8) -- inferred equivalent call
	buffer.fill(buf, 0, 0, v6 * v7 * v8)
	local data2 = data.data

	for i = 0, v8 - 1 do
		for j = 0, v7 - 1 do
			for k = 0, v6 - 1 do
				local count = 0
				local count2 = 0

				for i2 = i * 3, math.min(sz, (i + 1) * 3) - 1 do
					for i3 = j * 3, math.min(sy, (j + 1) * 3) - 1 do
						for i4 = k * 3, math.min(sx, (k + 1) * 3) - 1 do
							count += 1

							if buffer.readu8(data2, i4 + sx * (i3 + sy * i2)) ~= 0 then
								count2 += 1
							end
						end
					end
				end

				if count2 > 0 and count * 0.25 <= count2 then
					buffer.writeu8(buf, k + v6 * (j + v7 * i), 1)
				end
			end
		end
	end

	local v9 = VoxelCore.greedy(buf, v6, v7, v8, scratch(2, v6 * v7 * v8), v5) -- inferred equivalent call
	local v10 = 3 * VOXEL_SIZE

	local v11 = Vector3.new(sx, sy, sz) * VOXEL_SIZE

	for i = 0, v9 - 1 do
		local v12 = i * 7
		local v13 = Vector3.new(v5[v12 + 1], v5[v12 + 2], v5[v12 + 3]) * v10
		local min = (v13 + Vector3.new(v5[v12 + 4], v5[v12 + 5], v5[v12 + 6]) * v10):Min(v11)
		local solid = data.solidParts[i + 1]

		if solid and not solid.CanCollide then
			solid.CanCollide = true
			solid.CanQuery = true
		end

		if not solid then
			solid = Instance.new("Part")
			solid.Name = "Solid"
			solid.Anchored = true
			solid.CanCollide = true
			solid.CanQuery = true
			solid.CanTouch = false
			solid.CastShadow = false
			solid.Transparency = 1
			solid.CollisionGroup = "VehicleBody"
			solid.Parent = data.model
			data.solidParts[i + 1] = solid
		end

		local size = min - v13

		if data.solidSizes[i + 1] ~= size then
			solid.Size = size
			data.solidSizes[i + 1] = size
		end

		local cframe = CFrame.new(def.origin + (v13 + min) * 0.5)
		local solidWeld = data.solidWelds[i + 1]

		if solidWeld then
			if data.solidOffsets[i + 1] ~= cframe then
				solidWeld.C0 = cframe
			end
		else
			data.solidWelds[i + 1] = RigidParts.weld(data.solidRoot, solid, cframe)
		end

		data.solidOffsets[i + 1] = cframe
	end

	for i = v9 + 1, #data.solidParts do
		local solidPart = data.solidParts[i]

		if not solidPart.CanCollide then
			continue
		end

		solidPart.CanCollide = false
		solidPart.CanQuery = false
	end
end

local v6 = {}

do
	local function boxKey(p: number) -- 1 equivalent call inferred from this helper
		return (((((v6[p + 1] * 64 + v6[p + 2]) * 64 + v6[p + 3]) * 64 + v6[p + 4]) * 64 + v6[p + 5]) * 64 + v6[p + 6]) * 256 + v6[p + 7]
	end
end

local v7 = {}
local function rebuildHull(state, flag: boolean?, p: number?, flag2: boolean?)
	local def = state.def

	if not flag2 then
		if state.hullQueue then
			rebuildHull(state, true, nil, true)
		end

		local v8 = def.sx <= 64 and def.sy <= 64 and def.sz <= 64
		assert(v8, "[VehicleClient] hull grid too big for boxKey")
		debug.profilebegin("VC.hull.greedy")
		local v9 = VoxelCore.greedy(state.data, def.sx, def.sy, def.sz, scratch(2, def.sx * def.sy * def.sz), v6) -- inferred equivalent call
		debug.profileend()

		local hullParts = state.hullParts
		local hullWelds = state.hullWelds
		local hullOffsets = state.hullOffsets
		local hullPals = state.hullPals
		local hullSizes = state.hullSizes
		table.clear(v7)

		for k, v10 in state.hullKeys or {} do
			v7[v10] = k
		end

		local hullParts2 = table.create(v9)
		local hullWelds2 = table.create(v9)
		local hullOffsets2 = table.create(v9)
		local hullPals2 = table.create(v9)
		local hullSizes2 = table.create(v9)
		local hullKeys = table.create(v9)
		local v10 = table.create(#hullParts, false)
		local v11 = table.create(v9, false)

		for i = 1, v9 do
			local v12 = boxKey((i - 1) * 7) -- inferred equivalent call
			hullKeys[i] = v12
			local v13 = v7[v12]

			if not v13 then
				continue
			end

			v10[v13] = true
			v11[i] = true
			local hullPart = hullParts[v13]
			local hullWeld = hullWelds[v13]
			local hullOffset = hullOffsets[v13]
			local hullPal = hullPals[v13]
			local hullSiz = hullSizes[v13]
			hullParts2[i] = hullPart
			hullWelds2[i] = hullWeld
			hullOffsets2[i] = hullOffset
			hullPals2[i] = hullPal
			hullSizes2[i] = hullSiz
		end

		local hiddenParts = state.hiddenParts or {}
		local hiddenWelds = state.hiddenWelds or {}
		state.hiddenParts = hiddenParts
		state.hiddenWelds = hiddenWelds
		local v12 = 1
		local hullQueue = {}

		for i = 1, v9 do
			if v11[i] then
				continue
			end

			while v12 <= #hullParts and v10[v12] do
				v12 += 1
			end

			local v13 = (i - 1) * 7
			local v14 = v6[v13 + 1]
			local v15 = v6[v13 + 2]
			local v16 = v6[v13 + 3]
			local v17 = v6[v13 + 4]
			local v18 = v6[v13 + 5]
			local v19 = v6[v13 + 6]
			local v20 = v6[v13 + 7]
			local v21 = nil
			local vector3 = nil
			local v22 = nil
			local cframe = nil
			local v23 = false
			local v24

			if v12 <= #hullParts then
				v10[v12] = true
				v24 = hullParts[v12]
				v21 = hullWelds[v12]
				vector3 = hullSizes[v12]
				v22 = hullPals[v12]
				cframe = hullOffsets[v12]
			elseif #hiddenParts > 0 then
				v24 = table.remove(hiddenParts)
				v21 = table.remove(hiddenWelds)
			else
				v24 = Instance.new("Part")
				v24.Anchored = true
				v24.CanTouch = false
				v24.CanCollide = false
				v24.CanQuery = false
				v24.TopSurface = Enum.SurfaceType.Smooth
				v24.BottomSurface = Enum.SurfaceType.Smooth
				v24.CollisionGroup = "VehicleBody"
				v24.CFrame = RigidParts.PARK
				v24.Parent = nil
				v23 = true
			end

			local v25 = Vector3.new(v17, v18, v19) * VOXEL_SIZE
			local cframe2 = CFrame.new(def.origin + Vector3.new(v14 + v17 * 0.5, v15 + v18 * 0.5, v16 + v19 * 0.5) * VOXEL_SIZE)
			table.insert(hullQueue, {
				v24,
				i,
				v21 or false,
				vector3 ~= v25,
				v22 or false,
				cframe ~= cframe2,
				v23
			})
			hullParts2[i] = v24
			hullWelds2[i] = v21
			hullOffsets2[i] = cframe2
			hullPals2[i] = v20
			hullSizes2[i] = v25
		end

		for k, hullPart in hullParts do
			if v10[k] then
				continue
			end

			table.insert(hullQueue, { hullPart, 0 })
			table.insert(hiddenParts, hullPart)
			table.insert(hiddenWelds, hullWelds[k])
		end

		if #hiddenParts < 24 then
			state.spareWant = 24
		end

		state.hullParts = hullParts2
		state.hullWelds = hullWelds2
		state.hullOffsets = hullOffsets2
		state.hullPals = hullPals2
		state.hullSizes = hullSizes2
		state.hullKeys = hullKeys

		if #hullQueue > 0 then
			local char = state.char or 0
			state.hullQueue = hullQueue
			state.hullQueueAt = 1
			state.hullQueueChar = char
		end

		if flag then
			state.solidDirty = true
		else
			rebuildSolid(state)
		end

		state.drawnCf = nil
		state.solidCf = nil
		state.lampState = -1
	end

	local hullQueue = state.hullQueue

	if not hullQueue then
		return
	end

	local lastTime = os.clock()
	local hullParts = state.hullParts
	local hullWelds = state.hullWelds
	local hullOffsets = state.hullOffsets
	local hullPals = state.hullPals
	local hullSizes = state.hullSizes

	local char = state.char or 0
	local hullQueueChar = state.hullQueueChar
	local lamps = def.lamps

	local shadowBand = state.shadowBand
	local v8

	if shadowBand == nil or shadowBand == 0 then
		v8 = not Detail.low and 0 or Detail.bandCells(0)
	else
		v8 = Detail.bandCells(shadowBand)
	end

	local hullQueueAt = state.hullQueueAt

	while hullQueueAt <= #hullQueue do
		local v9 = hullQueue[hullQueueAt]
		hullQueueAt += 1
		local v10 = v9[1]
		local v11 = v9[2]

		if v11 == 0 then
			v10.Transparency = 1
			v10.CastShadow = false
		elseif hullParts[v11] == v10 then
			local v12 = v9[3] or nil
			local v13 = v9[5] or nil
			local v14 = v9[7]
			debug.profilebegin(v14 and "VC.hull.fresh" or v12 and "VC.hull.reuse" or "VC.hull.weld")
			local hullSiz = hullSizes[v11]

			if v9[4] then
				v10.Size = hullSiz
			end

			local hullPal = hullPals[v11]
			local v15 = Palette[hullPal]
			local color6

			if char > 0 and v15.transparency == 0 and hullPal ~= lamps.head and hullPal ~= lamps.tail then
				color6 = v15.color:Lerp(color5, char)
			else
				color6 = v15.color
			end

			local v16

			if v13 and char == hullQueueChar then
				local v17 = Palette[v13]
				local v18

				if char > 0 and v17.transparency == 0 and v13 ~= lamps.head and v13 ~= lamps.tail then
					v18 = v17.color:Lerp(color5, char)
				else
					v18 = v17.color
				end

				v16 = v18 ~= color6
			else
				v16 = true
			end

			if v16 then
				v10.Color = color6
			end

			if v13 ~= hullPal then
				if v10.Material ~= v15.material then
					v10.Material = v15.material
				end

				if v10.MaterialVariant ~= v15.variant then
					v10.MaterialVariant = v15.variant
				end

				if v10.Transparency ~= v15.transparency then
					v10.Transparency = v15.transparency
				end
			end

			local castShadow

			if v15.transparency == 0 then
				if v8 == 0 then
					castShadow = true
				else
					local v17 = hullSiz.X * hullSiz.Y * hullSiz.Z / (VOXEL_SIZE * VOXEL_SIZE * VOXEL_SIZE)
					castShadow = v8 - 0.01 <= v17
				end
			else
				castShadow = false
			end

			if v10.CastShadow ~= castShadow then
				v10.CastShadow = castShadow
			end

			if v12 then
				if v9[6] then
					v12.C0 = hullOffsets[v11]
				end
			else
				hullWelds[v11] = RigidParts.weld(state.hullRoot, v10, hullOffsets[v11])
			end

			if v14 then
				v10.Parent = state.model
			end

			debug.profileend()
		end

		if p and p <= os.clock() - lastTime then
			break
		end
	end

	if not (#hullQueue < hullQueueAt) then
		state.hullQueueAt = hullQueueAt

		return
	end

	state.hullQueue = nil
	state.hullQueueAt = nil
	state.hullQueueChar = nil
	state.lampState = -1
end

local function buildWheels(data, pace)
	local def = data.def
	local wheelGrid = def.wheelGrid
	local x = wheelGrid.X
	local y = wheelGrid.Y
	local z = wheelGrid.Z
	local buf = buffer.create(x * y * z)
	local wheelCells = def.wheelCells

	for i = 1, #wheelCells, 4 do
		buffer.writeu8(buf, wheelCells[i] + x * (wheelCells[i + 1] + y * wheelCells[i + 2]), wheelCells[i + 3])
	end

	local v8 = {}
	local greedy = VoxelCore.greedy(buf, x, y, z, buffer.create(x * y * z), v8)
	local v9 = Vector3.new(x, y, z) * (VOXEL_SIZE * 0.5)

	for i = 0, greedy - 1 do
		local v10 = i * 7
		local v11 = v8[v10 + 1]
		local v12 = v8[v10 + 2]
		local v13 = v8[v10 + 3]
		local v14 = v8[v10 + 4]
		local v15 = v8[v10 + 5]
		local v16 = v8[v10 + 6]
		data.wheelOffsets[i + 1] = CFrame.new(Vector3.new(v11 + v14 * 0.5, v12 + v15 * 0.5, v13 + v16 * 0.5) * VOXEL_SIZE - v9)
	end

	for i = 1, #def.wheels do
		local root = RigidParts.root(data.model, "Wheel")
		local v10 = {}

		for j = 0, greedy - 1 do
			if pace and pace() then
				return
			end

			local v11 = j * 7
			local part = newPart(data.model, false) -- inferred equivalent call
			part.Size = Vector3.new(v8[v11 + 4], v8[v11 + 5], v8[v11 + 6]) * VOXEL_SIZE
			look(part, v8[v11 + 7]) -- inferred equivalent call
			RigidParts.weld(root, part, data.wheelOffsets[j + 1])
			table.insert(v10, part)
		end

		data.wheelParts[i] = v10
		data.wheelRoots[i] = root
	end
end

local function buildPiece(p, data, pace)
	local grid = data.grid
	local x = grid.X
	local y = grid.Y
	local z = grid.Z
	local buf = buffer.create(x * y * z)
	local cells = data.cells

	for i = 1, #cells, 4 do
		buffer.writeu8(buf, cells[i] + x * (cells[i + 1] + y * cells[i + 2]), cells[i + 3])
	end

	local v8 = {}
	local greedy = VoxelCore.greedy(buf, x, y, z, buffer.create(x * y * z), v8)

	local root = RigidParts.root(p.model, "Piece")
	local result = {}
	local cframes = {}

	for i = 0, greedy - 1 do
		if pace and pace() then
			break
		end

		local v9 = i * 7
		local v10 = v8[v9 + 1]
		local v11 = v8[v9 + 2]
		local v12 = v8[v9 + 3]
		local v13 = v8[v9 + 4]
		local v14 = v8[v9 + 5]
		local v15 = v8[v9 + 6]
		local part = newPart(p.model, false) -- inferred equivalent call
		part.Size = Vector3.new(v13, v14, v15) * VOXEL_SIZE
		look(part, v8[v9 + 7]) -- inferred equivalent call
		result[i + 1] = part
		cframes[i + 1] = CFrame.new(data.origin + Vector3.new(v10 + v13 * 0.5, v11 + v14 * 0.5, v12 + v15 * 0.5) * VOXEL_SIZE)
		RigidParts.weld(root, part, cframes[i + 1])
	end

	return result, cframes, root
end

do
	local function writeQ(buf: buffer, offset: number, p: number, p2: number) -- 3 equivalent calls inferred from this helper
		buffer.writei16(buf, offset, (math.clamp(math.round(p * p2), -32768, 32767)))
	end
end

local function packExtra(data, sim)
	local buf = buffer.create((data.def.turret and 4 or 0) + 3)

	if data.def.turret then
		writeQ(buf, 3, data.yaw, 10000) -- inferred equivalent call
		writeQ(buf, 5, data.pitch, 10000) -- inferred equivalent call
	end

	buffer.writeu8(
		buf,
		0,
		(sim.asleep and 1 or 0) + ((sim.braking or sim.input.handbrake and sim.input.driver) and 2 or 0) + (sim.dir == 2 and 4 or 0) + math.clamp(sim.gear, 0, 7) * 8
	)
	local v8

	if sim.throttle == 0 then
		v8 = sim.pivot * math.abs(sim.steer)
	else
		v8 = sim.throttle
	end

	writeQ(buf, 1, v8, 32767) -- inferred equivalent call
	return buf
end

local function readExtra(state, buf: buffer, cframe: CFrame?, vector3: Vector3?, vector3_2: Vector3?)
	local v8 = buffer.len(buf)

	if v8 < 3 then
		return
	end

	local v9 = buffer.readu8(buf, 0)
	state.asleep = bit32.band(v9, 1) ~= 0
	state.braking = bit32.band(v9, 2) ~= 0
	state.gear = bit32.band(v9, 4) ~= 0 and -1 or math.max(bit32.rshift(v9, 3), 1)
	state.throttle = buffer.readi16(buf, 1) / 32767

	if state.def.turret and v8 >= 7 then
		state.netYaw = buffer.readi16(buf, 3) / 10000
		state.netPitch = buffer.readi16(buf, 5) / 10000
	end

	if cframe and vector3 and vector3_2 then
		local now = os.clock()
		local v10 = math.clamp(now - (state.guessAt or now), 0, 0.25)
		state.guessAt = now
		local v11 = state.def.size.Magnitude * 0.5

		if
			(not Detail.low or (cframe.Position - Detail.eye).Magnitude < 330 + v11)
			and Detail.onScreen(cframe.Position, v11)
		then
			if now - (state.paramsAt or -1e999) > 2 then
				state.paramsAt = now
				refreshParams(state)
			end

			local wheelGuess = state.wheelGuess

			if not wheelGuess then
				wheelGuess = require((vehicles:WaitForChild("WheelGuess")))
				state.wheelGuess = wheelGuess
			end

			wheelGuess.fill(state, cframe, vector3, vector3_2, not (v10 > 0) and 0.05 or v10)
		end
	end
end

@native local function interpolate(state, flag: boolean?)
	local poses = state.poses

	if #poses == 0 then
		return
	end

	local pos = poses[#poses]

	local timing = state.timing

	if flag or state.restAt ~= pos or state.cf ~= state.restCf then
		state.restAt = nil

		local v8 = PoseTiming.drawTime(timing, pos.t, not state.asleep and pos.vel.Magnitude > 1)

		state.stalled = false

		if pos.t <= v8 or #poses == 1 then
			local v9 = state.asleep and 0 or PoseTiming.lead(v8 - pos.t)
			state.stalled = not state.asleep and v8 - pos.t >= 0.4
			state.cf = pos.cf + pos.vel * v9
			local vel = pos.vel
			local ang = pos.ang
			state.vel = vel
			state.ang = ang
		else
			local v9 = false

			for i = #poses - 1, 1, -1 do
				local pos2 = poses[i]

				if pos2.t <= v8 then
					local pos3 = poses[i + 1]
					local v10 = math.max(pos3.t - pos2.t, 0.001)
					local v11 = math.clamp((v8 - pos2.t) / v10, 0, 1)
					local hermite = PoseTiming.hermite(pos2.cf.Position, pos2.vel, pos3.cf.Position, pos3.vel, v10, v11)
					state.cf = CFrame.new(hermite) * pos2.cf.Rotation:Lerp(pos3.cf.Rotation, v11)
					state.vel = pos2.vel:Lerp(pos3.vel, v11)
					state.ang = pos3.ang
					v9 = true
					break
				end
			end

			if not v9 then
				state.cf = poses[1].cf
			end
		end

		if not flag then
			state.cf = PoseTiming.apply(timing, state.cf)

			if
				state.asleep
				and (pos.t <= v8 or #poses == 1)
				and timing.offPos.Magnitude < 0.001
				and timing.offRot == CFrame.identity
			then
				local cf = state.cf
				state.restAt = pos
				state.restCf = cf
			end
		end
	else
		PoseTiming.delay(timing)
		timing.offClock = os.clock()
	end
end

do
	local function loopVoice(state, p: string) -- 6 equivalent calls inferred from this helper
		local v8 = v[p]

		local positional = AudioGraph.positional("Vehicle" .. p, state.holder, false, true)
		local player = positional.player
		player.Asset = "rbxassetid://" .. v8.id
		player.Looping = true
		player.LoopRegion = v8.loop
		player.TimePosition = v8.loop.Min
		player.Volume = 0
		player:Play()
		return positional
	end
end

do
	local function gainAt(vector3: Vector3) -- 2 equivalent calls inferred from this helper
		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			return math.clamp(1 - (currentCamera.CFrame.Position - vector3).Magnitude / 240, 0, 1) ^ 1.6
		end

		return 0
	end
end

do
	local function oneShot(p: number, p2: number, p3: number, vector3: Vector3, p4: number, p5: number?) -- 3 equivalent calls inferred from this helper
		local v8 = gainAt(vector3) * p4 -- inferred equivalent call

		if v8 < 0.01 then
			return
		end

		VoxelSound.oneShotAt(p, p2, p3, vector3, v8, p5)
	end
end

do
	local v8 = { v.start.id, v.stop.id, v.gear.id, v.cannon.id, v.load.id, v.lock.id }

	for _, v9 in v2 do
		for _, v10 in v9 do
			table.insert(v8, v10[1])
		end
	end

	VoxelSound.addSamples(v8)
end

VoxelSound.addSamples({ v.autocannon.id }, 4)

do
	local function pick(list) -- 1 equivalent call inferred from this helper
		return list[random:NextInteger(1, #list)]
	end
end

do
	local function hitSound(p: string, vector3: Vector3, p2: number) -- 6 equivalent calls inferred from this helper
		local v8 = pick(v2[p]) -- inferred equivalent call
		oneShot(v8[1], v8[2], v8[3], vector3, p2, random:NextNumber(0.88, 1)) -- inferred equivalent call
	end
end

local function crashSound(vector3: Vector3, p: number)
	local v8 = math.clamp((p - VehicleConfig.CRASH_SOUND) / 40, 0, 1)

	if p < 22 then
		hitSound("light", vector3, v8 * 0.5 + 0.5) -- inferred equivalent call
	elseif p < 36 then
		hitSound("heavy", vector3, v8 * 0.3 + 0.7) -- inferred equivalent call
	else
		hitSound("crash", vector3, 1) -- inferred equivalent call
		hitSound("heavy", vector3, 0.8) -- inferred equivalent call
	end

	if p > 22 then
		BattleFX.billow(vector3, Color3.fromRGB(150, 140, 122), math.clamp(p / 40, 0.4, 1.4), true)
	end
end

do
	local function onceVoice(state, p: string) -- 1 equivalent call inferred from this helper
		local v8 = v[p]
		local positional = AudioGraph.positional("Vehicle" .. p, state.holder, false, true)
		local player = positional.player
		player.Asset = "rbxassetid://" .. v8.id
		player.Looping = false
		player.Volume = 0
		AudioGraph.park(positional)
		return positional
	end
end

@native local function updateSound(state, p: number)
	local v8 = gainAt(state.cf:PointToWorldSpace(state.def.center)) -- inferred equivalent call

	if v8 <= 0 then
		if state.voices and not state.silent then
			for _, voice in state.voices do
				voice.player.Volume = 0
				voice.player:Stop()
				object2[voice.player] = nil
				AudioGraph.park(voice)
			end

			state.silent = true
		end
	else
		state.silent = false

		if not state.voices then
			local v9 = state.voicesMade

			if not v9 then
				v9 = {}
				state.voicesMade = v9
			end

			if v9.idle then
				if v9.low then
					if v9.high then
						if v9.roll then
							if v9.skid then
								if v9.stop then
									if state.def.tracks and not v9.tracks then
										v9.tracks = loopVoice(state, "tracks") -- inferred equivalent call
									end
								else
									v9.stop = onceVoice(state, "stop") -- inferred equivalent call
								end
							else
								v9.skid = loopVoice(state, "skid") -- inferred equivalent call
							end
						else
							v9.roll = loopVoice(state, "roll") -- inferred equivalent call
						end
					else
						v9.high = loopVoice(state, "high") -- inferred equivalent call
					end
				else
					v9.low = loopVoice(state, "low") -- inferred equivalent call
				end
			else
				v9.idle = loopVoice(state, "idle") -- inferred equivalent call
			end

			if v9.stop and (v9.tracks or not state.def.tracks) then
				state.voices = v9
				state.voicesMade = nil
			else
				return
			end
		end

		local voices = state.voices

		local stopT0 = state.stopT0

		if stopT0 then
			local v9 = os.clock() - stopT0
			local player = voices.stop.player

			if v.stop.length <= v9 then
				state.stopT0 = nil
				player.Volume = 0
				player:Stop()
				AudioGraph.park(voices.stop)
			else
				if not player.IsPlaying then
					AudioGraph.route(voices.stop, "dry")
					player.TimePosition = v.stop.at + v9
					player:Play()
				end

				player.Volume = v.stop.gain * math.clamp((v.stop.length - v9) / v.stop.fade, 0, 1) * v8
			end
		end

		local v9 = math.abs((state.vel:Dot(state.cf.LookVector)))
		local topSpeed = state.tuning.topSpeed

		local gears = state.tuning.gears
		local v10

		if state.sim then
			v10 = state.sim.dir == 2 and -1 or state.sim.gear
		else
			v10 = state.gear
		end

		local v11

		if v10 < 1 then
			v11 = v9 / state.tuning.reverseSpeed
		else
			local v12 = gears[math.min(v10, #gears)] * topSpeed
			local v13 = not (v10 > 1) and 0 or gears[v10 - 1] * topSpeed * 0.6
			v11 = (v9 - v13) / math.max(v12 - v13, 1)
		end

		local v12 = math.clamp(math.clamp(v11, 0, 1) * 0.7 + 0.15 + math.abs(state.throttle) * 0.2, 0, 1)
		state.rpm += (v12 - state.rpm) * math.min(p * 4, 1)
		local rpm = state.rpm
		local v13 = state.running and 1 or 0
		local engineSound = state.def.engineSound or 1
		tune(voices.idle, v.idle.gain * v13 * (1 - rpm) ^ 1.5 * v8, (math.min(rpm * 3, 1) * 0.1 + 0.9) * engineSound)
		tune(
			voices.low,
			v.low.gain * v13 * math.clamp(1 - math.abs(rpm - 0.4) * 2.2, 0, 1) * v8,
			(rpm * 0.25 + 0.75) * engineSound
		)
		tune(voices.high, v.high.gain * v13 * rpm ^ 1.6 * v8, (rpm * 0.3 + 0.7) * engineSound)
		local v14 = 0
		local v15 = 0

		for _, wheel in state.wheels do
			if wheel.contact then
				v14 += 1
			end
		end

		local sim = state.sim

		if sim then
			for _, wheel in sim.wheels do
				if wheel.contact then
					v15 = math.max(v15, wheel.slip, wheel.spinning and 10 or 0)
				end
			end
		elseif not state.asleep then
			v14 = #state.wheels
			v15 = math.abs((state.vel:Dot(state.cf.RightVector)))
		end

		local v16 = v14 / #state.wheels
		tune(
			voices.roll,
			v.roll.gain * math.clamp(v9 / 35, 0, 1) * v16 * v8,
			math.clamp(v9 / topSpeed, 0, 1) * 0.3 + 0.7
		)
		tune(voices.skid, v.skid.gain * math.clamp((v15 - 4) / 10, 0, 1) * v16 * v8, 0.9)
		local tracks = voices.tracks

		if tracks then
			local v17 = math.clamp(v9 / 18, 0, 1)
			tune(tracks, v.tracks.gain * v17 * (v16 * 0.6 + 0.4) * v8, math.clamp(v9 / topSpeed, 0, 1) * 0.4 + 0.6)
		end
	end
end

local function startSim(state)
	local sim = VehicleSim.new(state.def, state.tuning, state.cf, state.data, state.params)
	local vel = state.vel
	local ang = state.ang
	sim.vel = vel
	sim.ang = ang
	sim.health = attr(state.folder, "Health") or 1 -- inferred equivalent call
	sim.running = attr(state.folder, "Running") == true -- inferred equivalent call

	for k, wheel in sim.wheels do
		wheel.shown = state.wheels[k].shown
		wheel.angle = state.wheels[k].angle
	end

	state.sim = sim
	state.prevCf = state.cf
	state.sentAsleep = false
	refreshParams(state)
end

local function stopSim(p)
	local sim = p.sim
	p.sim = nil

	if sim then
		p.poses = {
			{
				t = workspace:GetServerTimeNow(),
				cf = sim.cf,
				vel = sim.vel,
				ang = sim.ang,
				extra = packExtra(p, sim)
			}
		}
		p.asleep = sim.asleep
	end
end

local function addVehicle(configuration)
	if not configuration:IsA("Configuration") then
		return
	end

	local id = configuration:GetAttribute("Id")
	local model = configuration:GetAttribute("Model")
	local v8 = typeof(id) == "number" and typeof(model) == "string"
	assert(v8, "[VehicleClient] vehicle without Id/Model: " .. configuration.Name)

	if VehicleConfig.FLYING[model] then
		return
	end

	local def = modules[model]
	local tuning = VehicleConfig[model]
	assert(def and tuning, "[VehicleClient] unknown vehicle model " .. model)

	local pooled = def.pooled
	def.pooled = nil
	local v9

	if pooled then
		v9 = pooled.model
	else
		v9 = Instance.new("Model")
	end

	v9.Name = configuration.Name
	local sound = Instance.new("Part")
	sound.Name = "Sound"
	sound.Anchored = true
	sound.CanCollide = false
	sound.CanQuery = false
	sound.CanTouch = false
	sound.CastShadow = false
	sound.Transparency = 1
	sound.Size = Vector3.new(0.2, 0.2, 0.2)
	sound.Parent = v9
	local v10 = configuration:GetAttribute("Pose")

	if typeof(v10) ~= "CFrame" then
		v10 = CFrame.identity
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = true
	local wheels = {}

	for _, wheel in def.wheels do
		table.insert(wheels, {
			shown = wheel.travel * 0.5,
			steer = 0,
			angle = 0,
			speed = 0,
			contact = true
		})
	end

	local v11 = {
		id = id,
		folder = configuration,
		def = def,
		tuning = tuning,
		data = VehicleGrid.copy(def),
		model = v9,
		hullParts = {},
		solidParts = {},
		solidOffsets = {},
		solidSizes = {},
		drawnKey = 0,
		hullOffsets = {},
		hullPals = {},
		wheelParts = {},
		wheelOffsets = {},
		holder = sound,
		poses = {},
		timing = PoseTiming.new(),
		cf = v10,
		vel = Vector3.new(0, 0, 0),
		ang = Vector3.new(0, 0, 0),
		asleep = true,
		braking = false,
		throttle = 0,
		wheels = wheels,
		sim = nil,
		prevCf = v10,
		params = raycastParams,
		lastSend = 0,
		sentAsleep = false,
		lastSupportCheck = 0,
		lastCrash = 0,
		lastLand = 0,
		running = false,
		stopT0 = nil,
		wrecked = false,
		smoked = false,
		voices = nil,
		rpm = 0,
		gear = 1,
		drawnCf = nil,
		solidCf = nil,
		culled = false,
		lampState = -1,
		hullSizes = {},
		silent = false,
		turretParts = {},
		turretOffsets = {},
		gunParts = {},
		gunOffsets = {}
	}
	local hullRoot

	if pooled then
		hullRoot = pooled.hullRoot
	else
		hullRoot = RigidParts.root(v9, "HullRoot")
	end

	v11.hullRoot = hullRoot
	v11.hullWelds = {}
	local solidRoot

	if pooled then
		solidRoot = pooled.solidRoot
	else
		solidRoot = RigidParts.root(v9, "SolidRoot")
	end

	v11.solidRoot = solidRoot
	v11.solidWelds = {}
	v11.wheelRoots = {}
	v11.turretRoot = nil
	v11.gunRoot = nil
	v11.shadowBand = nil
	v11.shadowVer = -1
	v11.yaw = 0
	v11.pitch = 0
	v11.netYaw = 0
	v11.netPitch = 0

	v9.PrimaryPart = v11.solidRoot

	local DamageFX = require(vehicles:WaitForChild("DamageFX"))
	local v12 = DamageFX.ENGINE[model]
	assert(v12, "[VehicleClient] no engine spot for " .. model .. " in DamageFX.ENGINE")
	v11.damage = DamageFX.new(v12.scale, v12.fire, v12.spots)
	v11.engine = v12.at
	v11.char = 0

	if pooled then
		for _, v13 in {
			"hullParts",
			"hullWelds",
			"hullOffsets",
			"hullPals",
			"hullSizes",
			"hullKeys",
			"hullQueue",
			"hullQueueAt",
			"hullQueueChar",
			"hiddenParts",
			"hiddenWelds",
			"solidParts",
			"solidWelds",
			"solidOffsets",
			"solidSizes",
			"wheelParts",
			"wheelOffsets",
			"wheelRoots",
			"turretParts",
			"turretOffsets",
			"turretRoot",
			"gunParts",
			"gunOffsets",
			"gunRoot",
			"pieceBase"
		} do
			v11[v13] = pooled[v13]
		end

		v9:SetAttribute("Culled", false)

		debug.profilebegin("VC.addVehicle(pooled)")
		rebuildHull(v11)
		charHull(v11)
		MountedGun.build(v11)
		debug.profileend()
	else
		local function gone(): boolean -- 5 equivalent calls inferred from this helper
			if configuration.Parent ~= nil then
				return false
			end

			v11.damage.destroy()
			v9:Destroy()
			return true
		end

		debug.profilebegin("VC.prebuild")
		local intactBoxes = VoxelCore.greedy(v11.data, def.sx, def.sy, def.sz, scratch(2, def.sx * def.sy * def.sz), v6) -- inferred equivalent call
		def.intactBoxes = intactBoxes
		local v13 = intactBoxes + 40
		local hiddenParts = table.create(v13)
		local hiddenWelds = table.create(v13)
		v11.hiddenParts = hiddenParts
		v11.hiddenWelds = hiddenWelds

		for i = 1, v13 do
			while not Detail.take("vcSpares", 40) do
				debug.profileend()
				task.wait()

				if gone() then -- inferred equivalent call
					return
				end

				debug.profilebegin("VC.prebuild")
			end

			local part = newPart(nil, false) -- inferred equivalent call
			part.Transparency = 1
			part.CastShadow = false
			hiddenWelds[i] = RigidParts.weld(v11.hullRoot, part, CFrame.identity)
			part.Parent = v9
			hiddenParts[i] = part
		end

		debug.profileend()
		debug.profilebegin("VC.addVehicle")
		rebuildHull(v11)
		debug.profileend()
		task.wait()

		if gone() then -- inferred equivalent call
			return
		end

		debug.profilebegin("VC.addVehicle")

		local flag = false
		local function pace(): boolean
			while not Detail.take("vcSpares", 40) do
				debug.profileend()
				task.wait()

				if gone() then -- inferred equivalent call
					flag = true
					return true
				end

				debug.profilebegin("VC.addVehicle")
			end

			return false
		end

		buildWheels(v11, pace)

		if flag then
			return
		end

		if def.turret then
			local piece, turretOffsets, turretRoot = buildPiece(v11, def.turret, pace)
			v11.turretParts = piece
			v11.turretOffsets = turretOffsets
			v11.turretRoot = turretRoot

			if flag then
				return
			end

			local piece2, gunOffsets, gunRoot = buildPiece(v11, def.gun, pace)
			v11.gunParts = piece2
			v11.gunOffsets = gunOffsets
			v11.gunRoot = gunRoot

			if flag then
				return
			end
		end

		debug.profileend()
		task.wait()

		if gone() then -- inferred equivalent call
			return
		end

		debug.profilebegin("VC.addVehicle")
		MountedGun.build(v11)
		debug.profileend()
		task.wait()

		if gone() then -- inferred equivalent call
			return
		end

		debug.profilebegin("VC.addVehicle")
		v9.Parent = vehicleHulls
		debug.profileend()
	end

	refreshParams(v11)
	ground[id] = v11

	task.spawn(function()
		local v13, cf, vel, ang = remotes.VehicleSnapshot:InvokeServer(id)

		if ground[id] ~= v11 or typeof(v13) ~= "buffer" then
			return
		end

		VehicleGrid.decodeEdits(v13, function(offset, value)
			buffer.writeu8(v11.data, offset, value)
		end)
		debug.profilebegin("VC.rebuildHull(snapshot)")
		rebuildHull(v11)
		debug.profileend()

		if v11.sim then
			VehicleSim.setHull(v11.sim, v11.data)
		elseif #v11.poses == 0 and typeof(cf) == "CFrame" then
			v11.cf = cf
			v11.vel = vel
			v11.ang = ang
		end
	end)
end

local numberRange = NumberRange.new(5, 7)
local numberRange2 = NumberRange.new(28, 55)

local numberRange3 = NumberRange.new(75, 95)
local numberRange4 = NumberRange.new(45, 65)

local color6 = Color3.fromRGB(30, 28, 26)
local color7 = Color3.fromRGB(96, 88, 76)

do
	@native local function burst(data, flag: boolean)
		local def = data.def
		local v8 = VehicleConfig.COOKOFF_MODELS[attr(data.folder, "Model")] or 1 -- inferred equivalent call
		local v9 = {}
		local burstKeep = Quality.burstKeep()
		local v10 = 0
		local v11 = 0
		local v12 = 0
		local v13, v14, v15

		if flag then
			local v16 = math.max(3, (math.round(numberRange.Min * v8)))
			local v17 = math.max(4, (math.round(numberRange.Max * v8)))
			v13 = random:NextInteger(v16, v17)
			v14 = random:NextInteger(v16, v17)
			v15 = random:NextInteger(v16, v17)

			local v18 = math.max(8, (math.floor(LooseChunks.cap() * 0.6)))

			for _ = 1, 3 do
				v10 = random:NextInteger(0, v13 - 1)
				v11 = random:NextInteger(0, v14 - 1)
				v12 = random:NextInteger(0, v15 - 1)
				local set = {}
				local count = 0

				for i = 0, def.sz - 1 do
					for j = 0, def.sy - 1 do
						for k = 0, def.sx - 1 do
							local v19 = buffer.readu8(data.data, (VehicleGrid.key(def, k, j, i)))

							if not (v19 ~= 0 and v19 ~= def.frame) then
								continue
							end

							local v20 = (k + v10) // v13 + ((j + v11) // v14 + (i + v12) // v15 * 16) * 16

							if set[v20] then
								continue
							end

							set[v20] = true
							count += 1
						end
					end
				end

				if count <= v18 then
					break
				end

				local v19 = (count / v18) ^ (1 / 3) * 1.05
				v13 = math.ceil(v13 * v19)
				v14 = math.ceil(v14 * v19)
				v15 = math.ceil(v15 * v19)
				v10 = random:NextInteger(0, v13 - 1)
				v11 = random:NextInteger(0, v14 - 1)
				v12 = random:NextInteger(0, v15 - 1)
			end
		else
			v13 = 8
			v14 = 8
			v15 = 8
		end

		for i = 0, def.sz - 1 do
			for j = 0, def.sy - 1 do
				for k = 0, def.sx - 1 do
					local v16 = buffer.readu8(data.data, (VehicleGrid.key(def, k, j, i)))

					if v16 == 0 then
						continue
					end

					local v17

					if v16 == def.frame then
						v17 = 0
					elseif flag then
						v17 = (k + v10) // v13 + 1 + ((j + v11) // v14 + (i + v12) // v15 * 16) * 16
					else
						v17 = k // 8 + 1 + i // 8 * 2 + (j > 7 and 1 or 0) * 8
					end

					if flag and burstKeep > 1 then
						local v18

						if v17 == 0 then
							v18 = Detail.strain >= 2
						else
							v18 = v17 * 40503 // 64 % burstKeep ~= 0
						end

						if v18 then
							continue
						end
					end

					local v18 = v9[v17]

					if not v18 then
						v18 = {}
						v9[v17] = v18
					end

					table.insert(v18, k)
					table.insert(v18, j)
					table.insert(v18, i)
					table.insert(v18, v16)
				end
			end
		end

		if Quality.mobile then
			v9[0] = nil
			local v16 = 6

			for k in v9 do
				if v16 <= 0 then
					v9[k] = nil
				end

				v16 -= 1
			end
		end

		local pointToWorldSpace = data.cf:PointToWorldSpace(def.center)
		local count = 0
		local count2 = 0

		for _ in v9 do
			count += 1
		end

		local v16 = math.max(1, (math.ceil(count / 5)))

		for k, v17 in v9 do
			local v18 = nil
			local v19, v20

			if flag then
				local total = 0
				local total2 = 0
				local total3 = 0

				for i = 1, #v17, 4 do
					total += v17[i]
					total2 += v17[i + 1]
					total3 += v17[i + 2]
				end

				local v21 = #v17 // 4
				local v22 = data.cf:PointToWorldSpace(def.origin + (Vector3.new(total, total2, total3) / v21 + Vector3.new(0.5, 0.5, 0.5)) * VOXEL_SIZE) - pointToWorldSpace
				local unit = ((not (v22.Magnitude > 0.001) and Vector3.new(0, 1, 0) or v22.Unit) + Vector3.new(
					random:NextNumber(-0.3, 0.3),
					0.7,
					random:NextNumber(-0.3, 0.3)
				)).Unit
				local v23

				if k == 0 then
					v23 = random:NextNumber(8, 12) * v8
				else
					v23 = random:NextNumber(numberRange2.Min, numberRange2.Max) * v8
				end

				v19 = data.vel + unit * v23
				v20 = Vector3.new(random:NextNumber(-1, 1), random:NextNumber(-1, 1), random:NextNumber(-1, 1)) * (k == 0 and 1 or 9)
				count2 += 1
				v18 = count2 % v16 ~= 1 % v16
			else
				local unit = Vector3.new(random:NextNumber(-1, 1), random:NextNumber(0.4, 1), random:NextNumber(-1, 1)).Unit
				v19 = data.vel + unit * (k == 0 and 2 or random:NextNumber(6, 14))
				v20 = Vector3.new(random:NextNumber(-1, 1), random:NextNumber(-1, 1), random:NextNumber(-1, 1)) * 2
			end

			LooseChunks.spawnAt(v17, data.cf, def.origin, v19, v20, v18)
		end

		if def.turret and flag then
			local aim, v17 = def.aim(data.cf, data.yaw, data.pitch)
			local unit = Vector3.new(random:NextNumber(-0.3, 0.3), 1, random:NextNumber(-0.3, 0.3)).Unit
			local unit2 = (data.cf.RightVector * (random:NextNumber() < 0.5 and -1 or 1) + Vector3.new(0, 1.2, 0)).Unit
			LooseChunks.spawnAt(
				def.turret.cells,
				aim,
				def.turret.origin,
				data.vel + unit * random:NextNumber(numberRange3.Min, numberRange3.Max),
				(Vector3.new(random:NextNumber(-3, 3), random:NextNumber(-6, 6), random:NextNumber(-3, 3)))
			)
			LooseChunks.spawnAt(
				def.gun.cells,
				v17,
				def.gun.origin,
				data.vel + unit2 * random:NextNumber(numberRange4.Min, numberRange4.Max),
				(Vector3.new(random:NextNumber(-6, 6), random:NextNumber(-3, 3), random:NextNumber(-6, 6)))
			)
		elseif def.turret then
			local aim, v17 = def.aim(data.cf, data.yaw, data.pitch)
			local unit = Vector3.new(random:NextNumber(-0.4, 0.4), 1, random:NextNumber(-0.4, 0.4)).Unit
			LooseChunks.spawnAt(
				def.turret.cells,
				aim,
				def.turret.origin,
				data.vel + unit * random:NextNumber(14, 22),
				(Vector3.new(random:NextNumber(-1, 1), random:NextNumber(-2, 2), random:NextNumber(-1, 1)))
			)
			LooseChunks.spawnAt(
				def.gun.cells,
				v17,
				def.gun.origin,
				data.vel + unit * random:NextNumber(8, 14),
				(Vector3.new(random:NextNumber(-2, 2), random:NextNumber(-1, 1), random:NextNumber(-1, 1)))
			)
		end

		if flag then
			local v17 = (pointToWorldSpace - workspace.CurrentCamera.CFrame.Position).Magnitude / WorldConfig.METER
			BattleFX.flash(pointToWorldSpace + Vector3.new(0, 4, 0), 110 * v8, 1.4 * v8, 16 * v8)
			BattleFX.billow(pointToWorldSpace + Vector3.new(0, 3, 0), color6, 9 * v8, false)
			BattleFX.billow(pointToWorldSpace, color7, 8 * v8, true)
			BattleFX.column(
				pointToWorldSpace + Vector3.new(0, 2, 0),
				color6,
				4 * v8,
				VehicleConfig.RESPAWN_DELAY,
				1.8,
				6
			)
			local raycastResult = workspace:Raycast(
				pointToWorldSpace + Vector3.new(0, 4, 0),
				-Vector3.new(0, 16, 0),
				data.params
			)

			if raycastResult then
				BattleFX.skirt(raycastResult.Position, raycastResult.Normal, color7, 34 * v8)
			end

			BattleFX.shake(pointToWorldSpace, 2.6 * v8, 70 * v8, 300 * v8)
			BattleFX.kick(pointToWorldSpace, 4 * v8, 60 * v8)

			if v17 < 45 * v8 then
				BattleFX.grit(1 - v17 / (45 * v8), color7)
			end
		else
			BattleFX.billow(pointToWorldSpace, Color3.fromRGB(70, 66, 60), 1.6, true)
		end

		hitSound("crash", pointToWorldSpace, 1) -- inferred equivalent call
	end

	local function removeVehicle(p: number, p2)
		local pooled = ground[p]

		if not pooled then
			return
		end

		ground[p] = nil

		if p2 then
			debug.profilebegin("VC.burst")
			burst(pooled, p2 == "cookoff")
			debug.profileend()
		end

		debug.profilebegin("VC.remove")
		pooled.damage.destroy()
		MountedGun.destroy(pooled)
		local def = pooled.def
		local mobile = Quality.mobile or Quality.potato

		if def.pooled == nil or mobile then
			local v8 = { pooled.hullRoot, pooled.solidRoot }

			for _, wheelRoot in pooled.wheelRoots do
				table.insert(v8, wheelRoot)
			end

			if pooled.turretRoot then
				table.insert(v8, pooled.turretRoot)
			end

			if pooled.gunRoot then
				table.insert(v8, pooled.gunRoot)
			end

			for _, v9 in v8 do
				v9.CFrame = RigidParts.PARK
			end

			pooled.holder:Destroy()
		end

		if def.pooled == nil then
			for _, model in pooled.model:GetChildren() do
				if model:IsA("Model") then
					model:Destroy()
				end
			end

			def.pooled = pooled

			local intactBoxes = def.intactBoxes

			if intactBoxes then
				task.spawn(function()
					local pooled2 = pooled
					local v8 = intactBoxes + 40
					local hiddenParts = pooled2.hiddenParts or {}
					local v9 = pooled2.hiddenWelds or {}

					while def.pooled == pooled and v8 < #pooled.hullParts + #hiddenParts do
						debug.profilebegin("VC.trim")

						for _ = 1, 20 do
							local count = #pooled.hullParts

							if count + #hiddenParts <= v8 then
								break
							end

							if #hiddenParts > 0 then
								table.remove(v9)
								table.remove(hiddenParts):Destroy()
							else
								pooled.hullParts[count]:Destroy()
								local hullParts = pooled.hullParts
								local hullWelds = pooled.hullWelds
								local hullOffsets = pooled.hullOffsets
								local hullPals = pooled.hullPals
								local hullSizes = pooled.hullSizes
								hullParts[count] = nil
								hullWelds[count] = nil
								hullOffsets[count] = nil
								hullPals[count] = nil
								hullSizes[count] = nil

								if pooled2.hullKeys then
									pooled2.hullKeys[count] = nil
								end
							end
						end

						debug.profileend()
						task.wait()
					end
				end)
			end
		elseif mobile then
			task.spawn(function()
				local descendants = pooled.model:GetDescendants()
				debug.profilebegin("VC.shed")
				local lastTime = os.clock()

				for i = #descendants, 1, -1 do
					descendants[i]:Destroy()

					if not (i % 120 == 0 or os.clock() - lastTime > 0.001) then
						continue
					end

					debug.profileend()
					task.wait()
					debug.profilebegin("VC.shed")
					lastTime = os.clock()
				end

				pooled.model:Destroy()
				debug.profileend()
			end)
		else
			pooled.model:Destroy()
		end

		debug.profileend()
	end

	for _, child in live:GetChildren() do
		task.spawn(addVehicle, child)
	end

	live.ChildAdded:Connect(addVehicle)

	TouchControls.addVehicles(function(callback)
		for _, v8 in ground do
			if not v8.wrecked then
				callback(v8.model, v8.folder, v8.cf, v8.def.origin + v8.def.size * 0.5, v8.def.size)
			end
		end
	end)
	live.ChildRemoved:Connect(function(child)
		local id = child:GetAttribute("Id")

		if typeof(id) == "number" and ground[id] and ground[id].folder == child then
			task.delay(0.5, function()
				if ground[id] and ground[id].folder == child then
					removeVehicle(id, false)
				end
			end)
		end
	end)
	remotes.VehicleRemoved.OnClientEvent:Connect(function(p: number, p2)
		removeVehicle(p, p2)
	end)
end

do
	local PosePack = require(vehicles:WaitForChild("PosePack"))
	PosePack.listen(
		remotes.VehiclePoses,
		function(p: number, cf2: CFrame, vel: Vector3, ang: Vector3, extra: buffer, p2: number)
			local v8 = ground[p]

			if not v8 or v8.sim then
				return
			end

			local poses = v8.poses

			if #poses > 0 and p2 <= poses[#poses].t then
				return
			end

			PoseTiming.observe(v8.timing, p2, vel)
			local cf

			if #poses > 0 then
				interpolate(v8, true)
				cf = v8.cf
			end

			table.insert(poses, {
				t = p2,
				cf = cf2,
				vel = vel,
				ang = ang,
				extra = extra
			})

			while #poses > 24 do
				table.remove(poses, 1)
			end

			if cf then
				interpolate(v8, true)
				PoseTiming.correct(v8.timing, cf, v8.cf)
			end

			readExtra(v8, extra, cf2, vel, ang)
		end
	)
end

remotes.VehicleEdits.OnClientEvent:Connect(function(p: number, buf: buffer, buf2: buffer, health: number)
	local v8 = ground[p]

	if not v8 then
		return
	end

	VehicleGrid.decodeEdits(buf, function(offset, value)
		buffer.writeu8(v8.data, offset, value)
	end)

	v8.hullDirty = true

	if v8.sim then
		VehicleSim.setHull(v8.sim, v8.data)
		v8.sim.health = health
		VehicleSim.wake(v8.sim)
	end

	VehicleGrid.decodePieces(v8.def, buf2, function(p2, p3)
		local vector3 = Vector3.new(random:NextNumber(-1, 1), random:NextNumber(-1, 1), random:NextNumber(-1, 1)) * 3
		LooseChunks.spawnAt(p2, v8.cf, v8.def.origin, p3, vector3)
	end)
end)

remotes.VehicleImpulse.OnClientEvent:Connect(function(p: number, vector3: Vector3, vector3_2: Vector3)
	local v8 = ground[p]

	if v8 and v8.sim then
		VehicleSim.kick(v8.sim, vector3, vector3_2)
	end
end)

remotes.VehicleCrash.OnClientEvent:Connect(function(p: number, p2: number, vector3: Vector3)
	if ground[p] then
		crashSound(vector3, p2)
	end
end)

local v8 = nil
local mine = 0
local periscope = false
local v9 = false
local v10 = false
local v11 = 0
local v12 = 0.20943951023931956
local v13 = 0
local vector3 = nil
local v14 = 0

local v15 = {
	weapon = 1,
	touchHeld = false,
	range = 500,
	loadout = require(vehicles:WaitForChild("LoadoutGround"))
}

function v15.cardNames(p)
	local v16, v17

	if p then
		v16 = v15.loadout.shownName(p.def, p.folder, "shell")
		v17 = v15.loadout.shownName(p.def, p.folder, p.def.launcher and "launcher" or "roof")
	end

	if localPlayer:GetAttribute("VehicleWeaponName1") ~= v16 then
		localPlayer:SetAttribute("VehicleWeaponName1", v16)
	end

	if localPlayer:GetAttribute("VehicleWeaponName2") ~= v17 then
		localPlayer:SetAttribute("VehicleWeaponName2", v17)
	end
end

v15.zoom = 3
v15.zoomToggle = false

v15.chaseZoom = 1

v15.wheelConn = nil
function v15.wheelWatch()
	if UserInputService.MouseEnabled and v15.wheelConn == nil then
		v15.wheelConn = UserInputService.InputChanged:Connect(function(input, gameProcessed: boolean)
			if gameProcessed or input.UserInputType ~= Enum.UserInputType.MouseWheel or GuiService.MenuIsOpen then
				return
			end

			if v8 and not periscope then
				v15.chaseZoom = math.clamp(v15.chaseZoom * (1 - math.sign(input.Position.Z) * 0.12), 0.55, 2.2)
			end
		end)
	elseif not UserInputService.MouseEnabled and v15.wheelConn ~= nil then
		v15.wheelConn:Disconnect()
		v15.wheelConn = nil
	end
end
UserInputService:GetPropertyChangedSignal("MouseEnabled"):Connect(v15.wheelWatch)
v15.wheelWatch()
local v16 = 0
local lookVector = nil
local v17 = Vector2.zero

local function myCharacter() -- 5 equivalent calls inferred from this helper
	local character = localPlayer.Character
	return
		character,
		character and character:FindFirstChildOfClass("Humanoid"),
		character and character:FindFirstChild("HumanoidRootPart")
end

do
	local function yawOf(vector3_2: Vector3) -- 6 equivalent calls inferred from this helper
		return (math.atan2(-vector3_2.X, -vector3_2.Z))
	end
end

local v18 = nil
local descendants = {}
local flag = true
local function markShownDirty()
	flag = true
end

local function setCharacterShown(flag2: boolean)
	local character = localPlayer.Character

	if not character then
		return
	end

	if character ~= v18 then
		v18 = character
		flag = true
		character.DescendantAdded:Connect(markShownDirty)
		character.DescendantRemoving:Connect(markShownDirty)
	end

	if flag then
		flag = false
		table.clear(descendants)

		for _, descendant in character:GetDescendants() do
			if descendant:IsA("BasePart") or descendant:IsA("Decal") then
				table.insert(descendants, descendant)
			end
		end
	end

	local localTransparencyModifier = flag2 and 0 or 1

	for _, v19 in descendants do
		if v19.LocalTransparencyModifier ~= localTransparencyModifier then
			v19.LocalTransparencyModifier = localTransparencyModifier
		end
	end
end

MountedGun.init({
	attr = attr,
	myCharacter = myCharacter,
	setCharacterShown = setCharacterShown,
	stick = function()
		return v17
	end
})

local v19 = false

function v15.rider()
	local v20

	if v8 == nil then
		return false
	end

	v20 = not v19

	if v20 then
		if v8.def.seats[mine] == nil then
			return false
		end

		return v8.def.seats[mine].view ~= nil
	end

	return v20
end

local function sinkAction(_: string, p)
	v9 = p == Enum.UserInputState.Begin or p == Enum.UserInputState.Change
	return Enum.ContextActionResult.Sink
end

local vehicleFX = Instance.new("Folder")
vehicleFX.Name = "VehicleFX"
vehicleFX.Parent = workspace

do
	local function fxPart(size: Vector3, color8: Color3) -- 3 equivalent calls inferred from this helper
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.Material = Enum.Material.Neon
		part.Color = color8
		part.Size = size
		part.Parent = vehicleFX
		return part
	end
end

parent2 = {
	across = 0.06981317007977318,
	along = 0.04537856055185257,
	back = 0.9,
	start = 0.65,
	speed = 10,
	w = 8.5,
	zeta = 0.4
}

local function knockHull(state, vector3_2: Vector3, fx: number?)
	local vectorToObjectSpace = state.cf:VectorToObjectSpace(vector3_2)
	local vector3_3 = Vector3.new(vectorToObjectSpace.X, 0, vectorToObjectSpace.Z)

	if vector3_3.Magnitude < 0.05 then
		return
	end

	local unit = vector3_3.Unit
	local size = state.def.size
	local reach = math.abs(unit.X) * size.X * 0.5 + math.abs(unit.Z) * size.Z * 0.5
	local v20 = fx or 1
	local knock = state.knock
	state.knock = {
		dir = unit,
		reach = reach,
		x = math.min(0.65 * v20 + (not (knock and knock.dir:Dot(unit) > 0.7) and 0 or math.max(knock.x, 0)), 0.65),
		speed = 10 * v20
	}
end

local function knockPose(state, p: number)
	local knock = state.knock

	if not knock then
		return nil
	end

	local v20 = math.min(p, 0.1)

	while v20 > 1e-6 do
		local v21 = math.min(v20, 1 / 120)
		knock.speed += (-72.25 * knock.x - 6.800000000000001 * knock.speed) * v21
		knock.x += knock.speed * v21
		v20 -= v21
	end

	if math.abs(knock.x) < 0.004 and math.abs(knock.speed) < 0.05 then
		state.knock = nil
		return nil
	end

	local dir = knock.dir
	local v21 = state.def.center - Vector3.new(0, 1, 0) * (state.def.size.Y * 0.5) - dir * knock.reach
	local v22 = (0.04537856055185257 + 0.024434609527920613 * math.abs(dir.X)) * knock.x
	return CFrame.new(v21 - dir * (0.9 * knock.x)) * CFrame.fromAxisAngle(dir:Cross(Vector3.new(0, 1, 0)), v22) * CFrame.new(-v21)
end

local v20 = {
	pitch = 0.019198621771937627,
	roll = 0.006981317007977318,
	start = 0.6,
	speed = 40,
	w = 26,
	zeta = 0.75
}

local v21 = { x = 0, speed = 0, roll = 0 }

do
	local function knockView(value: number?)
		local v22 = value or 1
		local v23 = 0.6 * v22
		local speed = 40 * v22
		v21.x = v23
		v21.speed = speed
		v21.roll = random:NextNumber(-1, 1)
		BattleFX.jolt(0.45 * v22)
	end
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = true
raycastParams.ExcludeInstances = { vehicleHulls, vehicleFX }
local color8 = Color3.fromRGB(196, 192, 184)

do
	local function dustOf(raycastResult: RaycastResult) -- 2 equivalent calls inferred from this helper
		local instance = raycastResult.Instance
		local v22

		if instance == workspace.Terrain then
			v22 = workspace.Terrain:GetMaterialColor(raycastResult.Material)
		elseif instance:IsA("BasePart") then
			v22 = instance.Color
		else
			v22 = color7
		end

		return v22:Lerp(color7, 0.45)
	end
end

local function cannonBlast(vector3_2: Vector3, vector3_3: Vector3, p, p2, flag2: boolean?)
	local fx = p2.fx or 1

	if fx < 1 then
		if flag2 then
			VoxelSound.ownSniper(0.6, "RX10")
		else
			VoxelSound.shot(vector3_2, 1.3, nil, "RX10")
		end

		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			local autocannon = v.autocannon
			local v22 = math.clamp(1 - (currentCamera.CFrame.Position - vector3_2).Magnitude / autocannon.range, 0, 1) ^ 1.4 * autocannon.gain

			if v22 > 0.01 then
				VoxelSound.oneShotAt(
					autocannon.id,
					autocannon.cuts[random:NextInteger(1, #autocannon.cuts)],
					autocannon.length,
					vector3_2,
					v22,
					random:NextNumber(autocannon.lo, autocannon.hi)
				)
			end
		end
	else
		VoxelSound.launch(vector3_2)
		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			local magnitude = (currentCamera.CFrame.Position - vector3_2).Magnitude
			local cannon = v.cannon
			local v22 = math.clamp(1 - magnitude / cannon.range, 0, 1) ^ 1.4 * cannon.gain

			if v22 > 0.01 then
				VoxelSound.oneShotAt(cannon.id, cannon.at, cannon.length, vector3_2, v22, random:NextNumber(0.9, 1))
			end
		end
	end

	local part = fxPart(Vector3.new(2.6, 2.6, 3.4) * fx, Color3.fromRGB(255, 236, 190)) -- inferred equivalent call
	part.CFrame = CFrame.lookAt(vector3_2 + vector3_3 * 1.6 * fx, vector3_2 + vector3_3 * 3)
	local part2 = fxPart(Vector3.new(4.6, 4.6, 2.4) * fx, Color3.fromRGB(255, 150, 70)) -- inferred equivalent call
	part2.Transparency = 0.25
	part2.CFrame = CFrame.lookAt(vector3_2 + vector3_3 * 3.2 * fx, vector3_2 + vector3_3 * 5) * CFrame.Angles(0, 0, (math.rad((random:NextNumber(0, 90)))))
	local part3 = fxPart(Vector3.new(1.3, 1.3, 6) * fx, Color3.fromRGB(255, 200, 120)) -- inferred equivalent call
	part3.CFrame = CFrame.lookAt(vector3_2 + vector3_3 * 5.5 * fx, vector3_2 + vector3_3 * 8)
	task.delay(0.05, part3.Destroy, part3)
	task.delay(0.07, part.Destroy, part)
	task.delay(0.09, part2.Destroy, part2)
	BattleFX.flash(vector3_2 + vector3_3 * 2 * fx, 60 * fx, math.sqrt(fx) * 0.22, math.sqrt(fx) * 6)
	BattleFX.billow(vector3_2 + vector3_3 * 3 * fx, color8, 6 * fx, false)

	if fx >= 1 then
		BattleFX.billow(vector3_2 + vector3_3 * 8, color8, 4, false)
	end

	local vector3_4 = Vector3.new(vector3_3.X, 0, vector3_3.Z)
	local v22 = not (vector3_4.Magnitude > 0.05) and Vector3.new(0, 0, 0) or vector3_4.Unit * 3
	local raycastResult = workspace:Raycast(
		vector3_2 + v22 + Vector3.new(0, 2, 0),
		-Vector3.new(0, 18, 0),
		raycastParams
	)

	if raycastResult then
		BattleFX.skirt(raycastResult.Position, raycastResult.Normal, dustOf(raycastResult), 11 * fx) -- inferred equivalent call
	end

	if p and fx >= 1 then
		local pointToWorldSpace = p.cf:PointToWorldSpace(p.def.center)
		local raycastResult2 = workspace:Raycast(
			pointToWorldSpace,
			Vector3.new(0, 1, 0) * -(p.def.size.Y + 8),
			raycastParams
		)

		if raycastResult2 then
			local color9 = dustOf(raycastResult2) -- inferred equivalent call
			BattleFX.skirt(raycastResult2.Position, raycastResult2.Normal, color9, 14)
			BattleFX.billow(raycastResult2.Position, color9, 9, true)
		end
	end

	BattleFX.shake(vector3_2, 0.5 * fx, 14 * fx, 60 * fx)
end

local function reloadSound(data, lock)
	local currentCamera = workspace.CurrentCamera

	if data.wrecked or not (data.model.Parent and currentCamera) then
		return
	end

	local pointToWorldSpace = data.cf:PointToWorldSpace(data.def.turret.pivot)
	local v22 = math.clamp(1 - (currentCamera.CFrame.Position - pointToWorldSpace).Magnitude / lock.range, 0, 1) ^ 1.5 * lock.gain

	if v22 > 0.01 then
		VoxelSound.oneShotAt(lock.id, lock.at, lock.length, pointToWorldSpace, v22, random:NextNumber(0.95, 1))
	end
end

local v22 = nil
local v23 = false

local function shellStreak(p, vector3_2: Vector3, vector3_3: Vector3, data, p2: number?)
	local v24, v25, v26 = ShellFlight.trace(vector3_2, vector3_3, function(origin: Vector3, direction: Vector3)
		local magnitude = direction.Magnitude
		local v24

		if p then
			v24 = v15.boreDistance(p, origin, direction / magnitude, magnitude)
		else
			v24 = magnitude
		end

		if not p then
			local raycastResult = workspace:Raycast(origin, direction, raycastParams)

			if raycastResult then
				v24 = raycastResult.Distance
			else
				v24 = magnitude
			end
		end

		if v24 < magnitude then
			return origin + direction / magnitude * v24
		end

		return nil
	end, data, 0.05)

	local function land()
		if not (p2 and v26) then
			return
		end

		local ownShell = BattleFX.ownShell
		assert(ownShell, "[VehicleClient] BattleFX.ownShell is not set (VoxelFX sets it)")
		local v27 = math.max(v25, 0.02)
		ownShell(
			p2,
			v24,
			(ShellFlight.position(vector3_2, vector3_3, v27, data) - ShellFlight.position(vector3_2, vector3_3, v27 - 0.01, data)).Unit,
			data.size,
			data.kind
		)
	end

	if v25 < 0.02 then
		land()
		return
	end

	local v27 = (data.fx or 1) < 1
	local v28 = v27 and 24 or 26
	local v29 = v27 and 0.5 or 0.35
	local vector3_4 = Vector3.new(v29, v29, v28)
	local color9 = Color3.fromRGB(255, 220, 160)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Color = color9
	part.Size = vector3_4
	part.Parent = vehicleFX
	local part2

	if v27 then
		local color10 = Color3.fromRGB(255, 240, 205)
		part2 = Instance.new("Part")
		part2.Anchored = true
		part2.CanCollide = false
		part2.CanQuery = false
		part2.CanTouch = false
		part2.CastShadow = false
		part2.Material = Enum.Material.Neon
		part2.Color = color10
		part2.Size = Vector3.new(0.9, 0.9, 3.4)
		part2.Parent = vehicleFX
	else
		part2 = nil
	end

	if not (v27 or Quality.mobile or Quality.potato) then
		local pointLight = Instance.new("PointLight")
		pointLight.Color = Color3.fromRGB(255, 190, 120)
		pointLight.Range = 12
		pointLight.Brightness = 3
		pointLight.Parent = part
	end

	local lastTime = os.clock()
	local renderSteppedConnection = nil
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local v30 = os.clock() - lastTime

		if v25 <= v30 then
			renderSteppedConnection:Disconnect()
			part:Destroy()

			if part2 then
				part2:Destroy()
			end

			land()
		else
			local position = ShellFlight.position(vector3_2, vector3_3, v30, data)
			local unit = (ShellFlight.position(vector3_2, vector3_3, v30 + 0.01, data) - position).Unit

			local v31 = math.min(v28, (position - vector3_2).Magnitude)

			if v31 > 0.1 then
				part.Size = Vector3.new(v29, v29, v31)
				part.CFrame = CFrame.lookAt(position - unit * v31 * 0.5, position)

				if part2 then
					part2.CFrame = CFrame.lookAt(position - unit * 1.7, position)
				end
			end
		end
	end)
end

function v15.launch(data)
	local launcher = data.def.launcher
	local launcher2 = v15.loadout.launcher(data.def, data.folder)
	local now = os.clock()
	local v24 = attr(data.folder, "Missiles") -- inferred equivalent call

	if typeof(v24) ~= "number" or v24 < 1 or now - (v15.launchedAt or 0) < launcher2.spacing then
		return
	end

	v15.launchedAt = now
	remotes.TankFire:FireServer(data.id, data.yaw, data.pitch, 2)
	local cframe, v25 = data.def.aim(data.cf, data.yaw, data.pitch)
	local pointToWorldSpace = cframe:PointToWorldSpace(launcher.mouth)
	VoxelSound.launch(pointToWorldSpace)
	BattleFX.billow(pointToWorldSpace + v25.LookVector * 1.5, color8, 3, false)
	BattleFX.billow(pointToWorldSpace - v25.LookVector * 7, color8, 4, false)
	local v26 = v20.start * 0.35
	local speed = v20.speed * 0.35
	v21.x = v26
	v21.speed = speed
	v21.roll = random:NextNumber(-1, 1)
	BattleFX.jolt(0.1575)
end

function v15.boreDistance(p, origin: Vector3, vector3_2: Vector3, p2: number)
	local raycastResult = workspace:Raycast(origin, vector3_2 * p2, p.params)

	if raycastResult then
		p2 = raycastResult.Distance
	end

	local filterDescendantsInstances = {}
	local botRigs = workspace:FindFirstChild("BotRigs")

	if botRigs then
		table.insert(filterDescendantsInstances, botRigs)
	end

	for _, v24 in Players:GetPlayers() do
		if v24 ~= localPlayer and v24.Character then
			table.insert(filterDescendantsInstances, v24.Character)
		end
	end

	local raycastParams2 = RaycastParams.new()
	raycastParams2.FilterType = Enum.RaycastFilterType.Include
	raycastParams2.FilterDescendantsInstances = filterDescendantsInstances
	local raycastResult2 = workspace:Raycast(origin, vector3_2 * p2, raycastParams2)
	return if raycastResult2 then raycastResult2.Distance else p2
end

local function tryFire()
	local v24 = v8

	if not v24 or not v19 or not v24.def.gun or v24.wrecked then
		return
	end

	if v15.weapon == 2 and v24.def.launcher then
		v15.launch(v24)
		return
	end

	if v15.weapon ~= 1 then
		return
	end

	local cannon = v15.loadout.cannon(v24.def, v24.folder)
	local now = os.clock()
	local v25 = attr(v24.folder, "Shells") -- inferred equivalent call

	if typeof(v25) ~= "number" or v25 < 1 or now - v14 < cannon.spacing then
		return
	end

	v14 = now

	v15.shot = ((v15.shot or 0) + 1) % 16777216
	remotes.TankFire:FireServer(v24.id, v24.yaw, v24.pitch, 1, v15.shot)
	local _, cframe = v24.def.aim(v24.cf, v24.yaw, v24.pitch)
	local pointToWorldSpace = cframe:PointToWorldSpace(v24.def.gun.muzzle)
	cannonBlast(pointToWorldSpace, cframe.LookVector, v24, cannon, true)

	shellStreak(v24, pointToWorldSpace, cframe.LookVector, cannon, v15.shot)
	knockHull(v24, cframe.LookVector, cannon.fx)
	local fx = cannon.fx or 1
	local v26 = v20.start * fx
	local speed = v20.speed * fx
	v21.x = v26
	v21.speed = speed
	v21.roll = random:NextNumber(-1, 1)
	BattleFX.jolt(0.45 * fx)

	if not cannon.magazine then
		task.delay(v.load.delay, reloadSound, v24, v.load)
		v22 = v24
		v23 = false
	end

	if v24.sim then
		VehicleSim.kick(v24.sim, -cframe.LookVector * cannon.recoil, pointToWorldSpace)
	end
end

local function fireAction(_: string, p)
	if p == Enum.UserInputState.Begin then
		tryFire()
	end

	return Enum.ContextActionResult.Sink
end

do
	local v24 = { "TankCannon", "TankMinigun" }
	function v15.names(p)
		return p.def.weapons or v24
	end
end

function v15.pick(weapon: number)
	local v24 = v8

	if
		not (v24 and v19 and (v24.def.DRIVER_GUN or v24.def.launcher))
		or weapon ~= 1 and weapon ~= 2
		or weapon == v15.weapon
	then
		return
	end

	if weapon == 2 and v24.def.DRIVER_GUN and MountedGun.yielded(v24) then
		return
	end

	v15.weapon = weapon
	localPlayer:SetAttribute("VehicleWeapon", v15.names(v24)[weapon])
end

function v15.action(_: string, p, p2)
	if p ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Sink
	end

	if p2.KeyCode == Enum.KeyCode.One then
		v15.pick(1)
	elseif p2.KeyCode == Enum.KeyCode.Two then
		v15.pick(2)
	elseif p2.KeyCode == Enum.KeyCode.ButtonL1 then
		v15.pick(3 - v15.weapon)
	end

	return Enum.ContextActionResult.Sink
end

localPlayer:GetAttributeChangedSignal("VehicleWeaponPick"):Connect(function()
	local vehicleWeaponPick = localPlayer:GetAttribute("VehicleWeaponPick")

	if typeof(vehicleWeaponPick) == "number" then
		localPlayer:SetAttribute("VehicleWeaponPick", nil)
		v15.pick(vehicleWeaponPick)
	end
end)

function v15.padArmed()
	local v24 = v19

	if v24 then
		if v8 == nil then
			return false
		end

		return v8.def.gun ~= nil
	end

	return v24
end

function v15.trigger()
	if UserInputService:GetFocusedTextBox() ~= nil or GuiService.MenuIsOpen then
		return false
	end

	if
		v15.touchHeld
		or UserInputService.MouseEnabled
		and not TouchControls.active()
		and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
	then
		return true
	end

	return UserInputService.GamepadEnabled
		and not MenuLock.held
		and UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonR1)
end

remotes.TankShot.OnClientEvent:Connect(function(p: number, vector3_2: Vector3, vector3_3: Vector3)
	local v24 = ground[p]
	local v25

	if v24 then
		v25 = v15.loadout.cannon(v24.def, v24.folder)
	else
		v25 = TankCannon
	end

	local v26

	if v24 == nil or v8 ~= v24 then
		v26 = false
	else
		v26 = v19 and os.clock() - v14 < 1.5
	end

	if not v26 then
		cannonBlast(vector3_2, vector3_3, v24, v25)

		if v24 then
			knockHull(v24, vector3_3, v25.fx)

			if not v25.magazine then
				task.delay(v.load.delay, reloadSound, v24, v.load)
				task.delay(math.max(v25.refill - v.lock.lead, 0), reloadSound, v24, v.lock)
			end
		end

		shellStreak(v24, vector3_2, vector3_3, v25)
	end
end)

local function startRiding(p, p2: number)
	v8 = p
	mine = p2
	localPlayer:SetAttribute("InVehicle", "ground")
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if character then
		character:FindFirstChild("HumanoidRootPart")
	end

	if humanoid then
		humanoid.Sit = true
		humanoid.AutoRotate = false
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	end

	ContextActionService:BindActionAtPriority(
		"VehicleHandbrake",
		sinkAction,
		false,
		Enum.ContextActionPriority.High.Value,
		Enum.KeyCode.Space,
		Enum.KeyCode.ButtonA
	)
	v19 = p.def.seats[p2].drive

	if MountedGun.start(p, p2) and humanoid then
		humanoid:UnequipTools()
	end

	if v19 and p.def.gun then
		ContextActionService:BindActionAtPriority(
			"VehicleFire",
			fireAction,
			false,
			Enum.ContextActionPriority.High.Value,
			Enum.UserInputType.MouseButton1,
			Enum.KeyCode.ButtonR1
		)

		v15.weapon = 1
		localPlayer:SetAttribute("VehicleWeapon", v15.names(p)[1])

		if MountedGun.drive(p) or p.def.launcher then
			ContextActionService:BindActionAtPriority(
				"VehicleWeaponPick",
				v15.action,
				false,
				Enum.ContextActionPriority.High.Value,
				Enum.KeyCode.One,
				Enum.KeyCode.Two,
				Enum.KeyCode.ButtonL1
			)
		end
	end

	if (v19 or p.def.seats[p2].inside) and humanoid then
		humanoid:UnequipTools()
	end

	if v19 or v15.rider() then
		local currentCamera = workspace.CurrentCamera
		v13 = yawOf(p.cf.LookVector) -- inferred equivalent call
		v11 = 0
		v12 = 0.20943951023931956
		periscope = false
		lookVector = nil
		currentCamera.CameraType = Enum.CameraType.Scriptable
	end
end

local function fn() end

local function stopRiding()
	local v24 = v19 or v15.rider()
	v8 = nil
	mine = 0
	v19 = false
	v15.zoomToggle = false
	v9 = false
	v10 = false

	if localPlayer:GetAttribute("InVehicle") == "ground" then
		localPlayer:SetAttribute("InVehicle", nil)
	end

	localPlayer:SetAttribute("VehicleWeapon", nil)
	v15.cardNames(nil)
	localPlayer:SetAttribute("VehicleLoad", nil)
	v22 = nil
	ContextActionService:UnbindAction("VehicleHandbrake")
	ContextActionService:UnbindAction("VehicleFire")
	ContextActionService:UnbindAction("VehicleWeaponPick")
	v15.weapon = 1
	v15.touchHeld = false
	vector3 = nil
	fn()
	MountedGun.stop()
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if character then
		character:FindFirstChild("HumanoidRootPart")
	end

	if humanoid then
		humanoid.Sit = false
		humanoid.AutoRotate = true
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	end

	if v24 then
		local currentCamera = workspace.CurrentCamera
		currentCamera.CameraType = Enum.CameraType.Custom

		if humanoid then
			currentCamera.CameraSubject = humanoid
		end

		setCharacterShown(true)
	end
end

do
	local function nearest()
		local _, _, v24 = myCharacter() -- inferred equivalent call

		if not v24 then
			return nil, 1e999
		end

		local v25 = nil
		local v26 = VehicleConfig.ENTER_RANGE
		local name

		if localPlayer.Team then
			name = localPlayer.Team.Name
		end

		for _, v27 in ground do
			if v27.wrecked then
				continue
			end

			local v28 = attr(v27.folder, "BayUser") -- inferred equivalent call

			if not (not v28 or v28 == localPlayer.UserId) then
				continue
			end

			local v29 = attr(v27.folder, "Crew") -- inferred equivalent call

			if not (type(v29) ~= "string" or v29 == "" or v29 == name) then
				continue
			end

			local pointToObjectSpace = v27.cf:PointToObjectSpace(v24.Position)
			local origin = v27.def.origin
			local v30 = v27.def.origin + v27.def.size
			local magnitude = Vector3.new(
				math.max(origin.X - pointToObjectSpace.X, 0, pointToObjectSpace.X - v30.X),
				math.max(origin.Y - pointToObjectSpace.Y, 0, pointToObjectSpace.Y - v30.Y),
				(math.max(origin.Z - pointToObjectSpace.Z, 0, pointToObjectSpace.Z - v30.Z))
			).Magnitude

			if not (magnitude < v26) then
				continue
			end

			v25 = v27
			v26 = magnitude
		end

		return v25, v26
	end

	local function exitWhy(...)
		warn("[VehicleExit] client:", ...)
	end

	local v24 = 0
	local v25 = 0

	remotes.VehicleSeat.OnClientEvent:Connect(function(p: number, cframe: CFrame, assemblyLinearVelocity: Vector3)
		exitWhy("server placed me", p, cframe and cframe.Position, "riding", v8 and v8.id, "seat", mine)
		local now = os.clock()
		v24 = p
		v25 = now

		if v8 then
			stopRiding()
		end

		local character, v26, v27 = myCharacter() -- inferred equivalent call

		if not (character and v26 and v27) then
			exitWhy("no character to move", character, v26, v27)

			return
		end

		v26.Sit = false
		character:PivotTo(cframe)
		v27.AssemblyLinearVelocity = assemblyLinearVelocity
		v27.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
		v26:ChangeState(Enum.HumanoidStateType.GettingUp)
		task.delay(0.5, function()
			exitWhy(
				"0.5 s later: at",
				v27.Position,
				"sit",
				v26.Sit,
				"state",
				v26:GetState().Name,
				"riding",
				v8 and v8.id
			)
		end)
	end)

	local function wheelNeed(instance)
		local v26 = VehicleConfig.DRIVE_LEVEL[attr(instance, "Model")] -- inferred equivalent call
		local v27 = attr(localPlayer, "Level") -- inferred equivalent call

		if v26 and (typeof(v27) ~= "number" and 1 or v27) < v26 then
			return v26
		end

		return nil
	end

	local function otherSeatFree(folder, p: number): boolean -- 2 equivalent calls inferred from this helper
		for i = 2, p do
			if (attr(folder, v3[i]) or 0) == 0 then -- inferred equivalent call
				return true
			end
		end

		return false
	end

	local function toggleSeat()
		if v8 then
			exitWhy("asking out of", v8.id, "seat", mine)
			remotes.VehicleSeat:FireServer(v8.id, 0)
		else
			if localPlayer:GetAttribute("InVehicle") or os.clock() - v25 < 0.6 then
				return
			end

			local v26 = nearest()

			if v26 then
				local folder = v26.folder
				local v27 = VehicleConfig.DRIVE_LEVEL[attr(folder, "Model")] -- inferred equivalent call
				local v28 = attr(localPlayer, "Level") -- inferred equivalent call

				if v27 then
					if not ((typeof(v28) ~= "number" and 1 or v28) < v27) then
						v27 = nil
					end
				else
					v27 = nil
				end

				if v27 and not otherSeatFree(v26.folder, #v26.def.seats) then -- inferred equivalent call
					VoxelSound.designator("bad")
					return
				end

				v24 = 0
				remotes.VehicleSeat:FireServer(v26.id, -1)
			end
		end
	end

	v15.swapSeat = (function()
		local lastTime = 0
		return function()
			local v26 = v8

			if not v26 or v26.wrecked or os.clock() - lastTime < 0.4 then
				return
			end

			local count = #v26.def.seats

			for i = 1, count - 1 do
				local v27 = (mine - 1 + i) % count + 1

				if (attr(v26.folder, v3[v27]) or 0) == 0 then -- inferred equivalent call
					if v27 == 1 then
						local folder = v26.folder
						local v28 = VehicleConfig.DRIVE_LEVEL[attr(folder, "Model")] -- inferred equivalent call
						local v29 = attr(localPlayer, "Level") -- inferred equivalent call

						if v28 then
							if not ((typeof(v29) ~= "number" and 1 or v29) < v28) then
								v28 = nil
							end
						else
							v28 = nil
						end

						if v28 then
							continue
						end
					end

					lastTime = os.clock()
					remotes.VehicleSeat:FireServer(v26.id, v27)
					return
				end
			end

			VoxelSound.designator("bad")
		end
	end)()

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or MenuLock.held and input.UserInputType == Enum.UserInputType.Gamepad1 then
			return
		end

		if input.KeyCode == Enum.KeyCode.E or input.KeyCode == Enum.KeyCode.ButtonY then
			if
				not MenuLock.open
				and (input.KeyCode ~= Enum.KeyCode.E or Players.LocalPlayer:GetAttribute("ReviveFocus") ~= true)
			then
				toggleSeat()
			end
		elseif (input.KeyCode == Enum.KeyCode.V or input.KeyCode == Enum.KeyCode.ButtonR3) and (v19 or v15.rider()) then
			periscope = not periscope
		elseif input.KeyCode == Enum.KeyCode.ButtonL3 and v19 and v8 and v8.def.turret then
			v15.zoomToggle = not v15.zoomToggle
		elseif
			(input.KeyCode == Enum.KeyCode.X or input.KeyCode == Enum.KeyCode.DPadUp)
			and v8
			and not MenuLock.open
		then
			v15.swapSeat()
		end
	end)

	local inputChangedConnection = nil
	local function watchPad()
		local gamepadEnabled = UserInputService.GamepadEnabled

		if gamepadEnabled and not inputChangedConnection then
			inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
				if input.KeyCode == Enum.KeyCode.Thumbstick2 then
					local position = input.Position
					local v26

					if MenuLock.held then
						v26 = Vector2.zero
					else
						v26 = Vector2.new(
							not (math.abs(position.X) > 0.15) and 0 or position.X,
							not (math.abs(position.Y) > 0.15) and 0 or position.Y
						)
					end

					v17 = v26
				end
			end)
		elseif not gamepadEnabled and inputChangedConnection then
			inputChangedConnection:Disconnect()
			inputChangedConnection = nil
			v17 = Vector2.zero
		end
	end
	watchPad()
	UserInputService.GamepadConnected:Connect(watchPad)
	UserInputService.GamepadDisconnected:Connect(watchPad)
	UserInputService:GetPropertyChangedSignal("GamepadEnabled"):Connect(watchPad)

	MenuLock.onChange(function(flag2: boolean)
		if flag2 then
			v17 = Vector2.zero
		end
	end)

	local function key(p, p2): number -- 4 equivalent calls inferred from this helper
		if UserInputService:IsKeyDown(p) or UserInputService:IsKeyDown(p2) then
			return 1
		end

		return 0
	end

	local function readInput()
		local v26, v27

		if UserInputService:GetFocusedTextBox() ~= nil then
			v26 = 0
			v27 = 0
		else
			v27 = key(Enum.KeyCode.D, Enum.KeyCode.Right) - key(Enum.KeyCode.A, Enum.KeyCode.Left) -- inferred equivalent call
			v26 = key(Enum.KeyCode.W, Enum.KeyCode.Up) - key(Enum.KeyCode.S, Enum.KeyCode.Down) -- inferred equivalent call
		end

		if UserInputService.GamepadEnabled and not MenuLock.held then
			for _, v28 in UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1) do
				if v28.KeyCode == Enum.KeyCode.ButtonR2 then
					v26 += v28.Position.Z
				elseif v28.KeyCode == Enum.KeyCode.ButtonL2 then
					v26 -= v28.Position.Z
				elseif v28.KeyCode == Enum.KeyCode.Thumbstick1 then
					local position = v28.Position

					if math.abs(position.X) > 0.15 then
						v27 += position.X
					end

					if math.abs(position.Y) > 0.15 then
						v26 += position.Y
					end
				end
			end
		end

		if UserInputService.TouchEnabled and v27 == 0 and v26 == 0 then
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if character then
				character:FindFirstChild("HumanoidRootPart")
			end

			local moveDirection = humanoid and humanoid.MoveDirection or Vector3.new(0, 0, 0)

			if moveDirection.Magnitude > 0.1 then
				local vectorToObjectSpace = workspace.CurrentCamera.CFrame:VectorToObjectSpace(moveDirection)
				v27 = vectorToObjectSpace.X
				v26 = -vectorToObjectSpace.Z
			end
		end

		return math.clamp(v27, -1, 1), math.clamp(v26, -1, 1), v9 or v10
	end

	local vehicleHud = Instance.new("ScreenGui")
	vehicleHud.Name = "VehicleHud"
	vehicleHud.ResetOnSpawn = false
	vehicleHud.IgnoreGuiInset = true
	vehicleHud.DisplayOrder = 7
	vehicleHud.Parent = localPlayer:WaitForChild("PlayerGui")

	local function plate(vehicleHud2, size: UDim2, position: UDim2, anchorPoint: Vector2)
		local frame = Instance.new("Frame")
		frame.Size = size
		frame.Position = position
		frame.AnchorPoint = anchorPoint
		frame.BackgroundColor3 = color
		frame.BackgroundTransparency = 0.12
		frame.BorderSizePixel = 0
		frame.Parent = vehicleHud2
		local tab = Instance.new("Frame")
		tab.Name = "Tab"
		tab.Size = UDim2.new(0, 22, 0, 4)
		tab.BackgroundColor3 = color3
		tab.BorderSizePixel = 0
		tab.Parent = frame
		return frame
	end

	local function label(parent, text: string, textSize: number, position: UDim2, anchorPoint: Vector2, textXAlignment)
		local textLabel = Instance.new("TextLabel")
		textLabel.BackgroundTransparency = 1
		textLabel.FontFace = rbxassetfontsfamiliesOswaldjson
		textLabel.TextColor3 = color2
		textLabel.TextSize = textSize
		textLabel.Text = text
		textLabel.AutomaticSize = Enum.AutomaticSize.XY
		textLabel.Position = position
		textLabel.AnchorPoint = anchorPoint
		textLabel.TextXAlignment = textXAlignment
		textLabel.Parent = parent
		return textLabel
	end

	local parent3 = plate(vehicleHud, UDim2.fromOffset(196, 64), UDim2.new(0.5, 0, 1, -18), Vector2.new(0.5, 1))
	parent3.Visible = false

	local ControlsHint = require(script:WaitForChild("ControlsHint"))
	v15.hint = ControlsHint.new(vehicleHud, {
		white = color2,
		hazard = color3,
		panel = color,
		font = rbxassetfontsfamiliesOswaldjson
	})
	local v26 = label(parent3, "0", 34, UDim2.fromOffset(14, 32), Vector2.new(0, 0.5), Enum.TextXAlignment.Left)
	label(parent3, "KM/H", 13, UDim2.fromOffset(70, 40), Vector2.new(0, 0.5), Enum.TextXAlignment.Left)
	local v27 = label(parent3, "D", 26, UDim2.new(1, -14, 0, 24), Vector2.new(1, 0.5), Enum.TextXAlignment.Right)
	parent2 = Instance.new("Frame")
	parent2.Size = UDim2.new(1, -28, 0, 5)
	parent2.Position = UDim2.new(0, 14, 1, -10)
	parent2.BackgroundColor3 = Color3.fromRGB(60, 60, 62)
	parent2.BorderSizePixel = 0
	parent2.Parent = parent3
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = color2
	frame.BorderSizePixel = 0
	frame.Parent = parent2

	local parent4 = plate(vehicleHud, UDim2.fromOffset(196, 34), UDim2.new(0.5, 0, 1, -88), Vector2.new(0.5, 1))
	parent4.Visible = false
	label(parent4, "CANNON", 15, UDim2.fromOffset(14, 17), Vector2.new(0, 0.5), Enum.TextXAlignment.Left)
	local v28 = label(parent4, "READY", 13, UDim2.new(1, -14, 0, 17), Vector2.new(1, 0.5), Enum.TextXAlignment.Right)
	local v29 = {}

	for i = 1, TankCannon.shells do
		local frame2 = Instance.new("Frame")
		frame2.Size = UDim2.fromOffset(16, 8)
		frame2.Position = UDim2.fromOffset(78 + (i - 1) * 20, 13)
		frame2.BorderSizePixel = 0
		frame2.Parent = parent4
		v29[i] = frame2
	end

	parent2 = Instance.new("Frame")
	parent2.Size = UDim2.new(1, -28, 0, 3)
	parent2.Position = UDim2.new(0, 14, 1, -6)
	parent2.BackgroundColor3 = Color3.fromRGB(60, 60, 62)
	parent2.BorderSizePixel = 0
	parent2.Parent = parent4
	local frame2 = Instance.new("Frame")
	frame2.Size = UDim2.fromScale(0, 1)
	frame2.BackgroundColor3 = color3
	frame2.BorderSizePixel = 0
	frame2.Parent = parent2

	local function tick(frame3, size: UDim2, position: UDim2)
		local frame4 = Instance.new("Frame")
		frame4.Size = size
		frame4.Position = position
		frame4.AnchorPoint = Vector2.new(0.5, 0.5)
		frame4.BackgroundColor3 = color2
		frame4.BorderSizePixel = 0
		frame4.Parent = frame3
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Color = Color3.new(0, 0, 0)
		uiStroke.Transparency = 0.55
		uiStroke.Parent = frame4
		return frame4
	end

	local frame3 = Instance.new("Frame")
	frame3.Size = UDim2.fromOffset(0, 0)
	frame3.Position = UDim2.fromScale(0.5, 0.5)
	frame3.BackgroundTransparency = 1
	frame3.Visible = false
	frame3.Parent = vehicleHud
	local v30 = {}

	for _, v31 in { Vector2.new(0, -8), Vector2.new(0, 8), Vector2.new(-8, 0), Vector2.new(8, 0) } do
		local v32

		if v31.X == 0 then
			v32 = UDim2.fromOffset(2, 7)
		else
			v32 = UDim2.fromOffset(7, 2)
		end

		table.insert(v30, tick(frame3, v32, UDim2.fromOffset(v31.X, v31.Y)))
	end

	local v31 = nil
	local function crossReady(flag2: boolean) -- 1 equivalent call inferred from this helper
		if flag2 == v31 then
			return
		end

		v31 = flag2

		for _, v32 in v30 do
			v32.BackgroundTransparency = flag2 and 0 or 0.45
			local backgroundColor = if flag2 then color2 else color4
			v32.BackgroundColor3 = backgroundColor
		end
	end

	local TankSight = require(script:WaitForChild("TankSight"))
	local v32 = TankSight.new(vehicleHud, {
		white = color2,
		hazard = color3,
		danger = color4,
		panel = color,
		font = rbxassetfontsfamiliesOswaldjson
	})

	local parent5 = plate(vehicleHud, UDim2.fromOffset(0, 34), UDim2.new(0.5, 0, 1, -120), Vector2.new(0.5, 1))
	parent5.AutomaticSize = Enum.AutomaticSize.X
	parent5.Visible = false
	parent2 = Instance.new("UIPadding")
	parent2.PaddingLeft = UDim.new(0, 12)
	parent2.PaddingRight = UDim.new(0, 12)
	parent2.Parent = parent5
	local v43 = label(parent5, "", 18, UDim2.new(0, 0, 0.5, 0), Vector2.new(0, 0.5), Enum.TextXAlignment.Left)

	local cap = Glyph.cap(parent5, nil, nil, 24)
	cap.AnchorPoint = Vector2.new(0, 0.5)
	cap.Position = UDim2.fromScale(0, 0.5)
	local function promptKey(flag2: boolean): string -- 1 equivalent call inferred from this helper
		local v44 = flag2 and Glyph.gamepad()
		local setCap = Glyph.setCap
		local v46

		if v44 then
			v46 = Enum.KeyCode.ButtonY
		end

		setCap(cap, nil, v46)
		v43.Position = UDim2.new(0, v44 and 32 or 0, 0.5, 0)
		return if flag2 and not v44 then "E   " else ""
	end

	local v44 = {}

	if UserInputService.TouchEnabled then
		local function button(p: string, p2: string, udim: UDim2)
			local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
			local v45 = require(ReplicatedStorage2:WaitForChild("Voxel"):WaitForChild("SeatButton")).make(
				vehicleHud,
				p,
				p2,
				udim,
				p == "Seat"
			)
			v44[p] = v45
			return v45
		end

		button("Seat", "GET OUT", UDim2.new(1, -16, 0.5, -10)).Activated:Connect(toggleSeat)

		button("Swap", "SWAP", UDim2.new(1, -16, 0.5, -74)).Activated:Connect(function()
			v15.swapSeat()
		end)
		local v45 = button("Brake", "BRAKE", UDim2.new(1, -16, 0.5, 54))
		v45.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then
				v10 = true
			end
		end)
		v45.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then
				v10 = false
			end
		end)
		button("View", "VIEW", UDim2.new(1, -114, 0.5, 54)).Activated:Connect(function()
			periscope = not periscope
		end)
		v45 = button("Fire", "FIRE", UDim2.new(1, -114, 0.5, -10))
		v45.Activated:Connect(tryFire)

		v45.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then
				v15.touchHeld = true
			end
		end)
		v45.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then
				v15.touchHeld = false
			end
		end)

		v15.discs = {
			{
				name = "TankFire",
				slot = "fire",
				glyph = "FIRE",
				look = true,
				hold = function(touchHeld: boolean)
					v15.touchHeld = touchHeld

					if touchHeld then
						tryFire()
					end
				end
			},
			{
				name = "TankView",
				slot = "aim",
				glyph = "view",
				tap = function()
					periscope = not periscope
				end,
				lit = function()
					return periscope
				end
			}
		}
	end

	local function kmh(p: number) -- 3 equivalent calls inferred from this helper
		return p / VehicleConfig.UNIT * 3.6
	end

	local function gearOf(data)
		local sim = data.sim
		local v45

		if sim then
			if sim.dir == 2 then
				v45 = -1
			elseif sim.dir == 3 then
				v45 = -2
			else
				v45 = if sim.dir == 0 then 0 else sim.gear
			end
		else
			v45 = data.gear
		end

		if data.wrecked then
			return "X"
		end

		if not data.running then
			return "-"
		end

		if v45 == -1 then
			return "R"
		elseif v45 == -2 then
			return "B"
		elseif v45 == 0 then
			return "N"
		end

		return (tostring(v45))
	end

	local v45 = false
	local function hideVitals(flag2: boolean) -- 1 equivalent call inferred from this helper
		local playerHud = flag2 ~= v45 and localPlayer.PlayerGui:FindFirstChild("PlayerHud")

		if playerHud then
			v45 = flag2
			playerHud.Enabled = not flag2
		end
	end

	local v46 = { word = "", what = "", locked = false, press = toggleSeat }

	local v47 = {
		ride = nil,
		speed = nil,
		gear = nil,
		health = nil,
		prompt = nil,
		on = true,
		seatFree = nil,
		hint = {
			turret = false,
			cockpit = false,
			armed = false,
			swap = false,
			seat = false,
			passenger = false
		}
	}
	local function updateHud()
		local v48 = v47
		debug.profilebegin("VC.hud.hint")
		local v49 = v15.rider()

		local v50 = false

		if v8 and not v8.wrecked then
			for i = 1, #v8.def.seats do
				if not (i ~= mine and (attr(v8.folder, v3[i]) or 0) == 0) then -- inferred equivalent call
					continue
				end

				if i ~= 1 then
					v50 = true
					break
				end

				local folder = v8.folder
				local v51 = VehicleConfig.DRIVE_LEVEL[attr(folder, "Model")] -- inferred equivalent call
				local v52 = attr(localPlayer, "Level") -- inferred equivalent call

				if v51 then
					if not ((typeof(v52) ~= "number" and 1 or v52) < v51) then
						v51 = nil
					end
				else
					v51 = nil
				end

				if not v51 then
					v50 = true
					break
				end
			end
		end

		if v8 and not v8.wrecked and (v19 or v49 or v50) then
			local hint = v48.hint
			local turret = v19 and v8.def.turret ~= nil
			local cockpit = periscope
			hint.turret = turret
			hint.cockpit = cockpit
			hint.armed = v19 and v8.def.gun ~= nil
			local swap = v19

			if swap then
				if v8.def.gun == nil then
					swap = false
				else
					swap = v8.def.DRIVER_GUN ~= nil or v8.def.launcher ~= nil
				end
			end

			hint.swap = swap
			hint.rider = v49
			hint.seat = v50
			hint.passenger = not (v19 or v49)
			v15.hint.update(hint)
		else
			v15.hint.update(nil)
		end

		debug.profileend()
		local touchEnabled = UserInputService.TouchEnabled
		local v51 = nil
		local v52 = false
		debug.profilebegin("VC.hud.vitals")
		local v53

		if v8 == nil then
			v53 = false
		elseif v19 or v49 then
			v53 = v8.def.turret ~= nil
		else
			v53 = v49
		end

		hideVitals(v53) -- inferred equivalent call
		debug.profileend()
		debug.profilebegin("VC.hud.panel")

		if v8 then
			Glyph.claim("vehicle", true)
			local v54 = v8

			local v55 = v19 and v54.def.turret ~= nil
			local visible = v19

			if visible then
				if v54.def.gun == nil then
					visible = false
				else
					visible = not v55
				end
			end

			local v57 = v19 and v54.def.gun ~= nil

			local v58 = v55 or v49 and v54.def.turret ~= nil
			local ride = (v19 and 1 or 0) + (v55 and 2 or 0) + (visible and 4 or 0) + (v57 and 8 or 0) + (v49 and 16 or 0)

			if v48.ride ~= ride then
				v48.ride = ride
				parent3.Visible = not v58
				parent4.Visible = visible
				frame3.Visible = v19 and not v55

				if touchEnabled then
					v44.Seat.Visible = true
					v44.Seat.Text = "GET OUT"
					v44.Brake.Visible = v19 and not v55
					local view = v44.View
					v49 = v19 and not v55 or v49
					view.Visible = v49
					v44.Fire.Visible = v57 and not v55
					debug.profilebegin("VC.hud.touch")
					local setVehicle = TouchControls.setVehicle
					local v60

					if v55 then
						v60 = v15.discs
					end

					setVehicle(v60)
					debug.profileend()
				end
			end

			if touchEnabled and v48.seatFree ~= v50 then
				v48.seatFree = v50
				v44.Swap.Visible = v50
			end

			if v48.prompt ~= nil then
				v48.prompt = nil
				parent5.Visible = false
			end

			if not v58 then
				local speed = math.floor(kmh(math.abs((v54.vel:Dot(v54.cf.LookVector)))) + 0.5) -- inferred equivalent call

				if speed ~= v48.speed then
					v48.speed = speed
					v26.Text = tostring(speed)
				end

				local v61 = gearOf(v54)

				if v61 ~= v48.gear then
					v48.gear = v61
					v27.Text = v61
				end

				local health = attr(v54.folder, "Health") or 1 -- inferred equivalent call

				if health ~= v48.health then
					v48.health = health
					frame.Size = UDim2.fromScale(math.clamp(health, 0, 1), 1)
					local backgroundColor

					if health < 0.35 then
						backgroundColor = color4
					elseif health < 0.7 then
						backgroundColor = color3
					else
						backgroundColor = color2
					end

					frame.BackgroundColor3 = backgroundColor
				end
			end

			if visible then
				local v60 = attr(v54.folder, "Shells") -- inferred equivalent call
				local v61 = typeof(v60) ~= "number" and 0 or v60

				for k, v62 in v29 do
					local backgroundColor

					if k <= v61 then
						backgroundColor = color2
					else
						backgroundColor = Color3.fromRGB(60, 60, 62)
					end

					v62.BackgroundColor3 = backgroundColor
				end

				local v62 = attr(v54.folder, "RefillAt") -- inferred equivalent call
				local v63 = (typeof(v62) ~= "number" or not (v62 > 0)) and 0 or v62 - workspace:GetServerTimeNow()
				frame2.Size = UDim2.fromScale(
					not (v63 > 0) and 1 or math.clamp(1 - v63 / v15.loadout.cannon(v54.def, v54.folder).refill, 0, 1),
					1
				)
				local v64 = os.clock() - v14 < v15.loadout.cannon(v54.def, v54.folder).spacing
				v28.Text = v61 < 1 and "LOADING" or v64 and "..." or "READY"
				local textColor

				if v61 < 1 then
					textColor = color4
				else
					textColor = if v64 then color3 else color2
				end

				v28.TextColor3 = textColor
			end
		else
			if v48.ride ~= false then
				v48.ride = false
				parent3.Visible = false
				parent4.Visible = false
				frame3.Visible = false

				if touchEnabled then
					v44.Seat.Visible = false
					v44.Swap.Visible = false
					v48.seatFree = false
					v44.Brake.Visible = false
					v44.View.Visible = false
					v44.Fire.Visible = false
					debug.profilebegin("VC.hud.touch")
					TouchControls.setVehicle(nil)
					debug.profileend()
				end
			end

			if not attr(localPlayer, "InVehicle") then -- inferred equivalent call
				v51 = nearest()
			end

			Glyph.claim("vehicle", v51 ~= nil)

			if v51 and not touchEnabled then
				local v54 = attr(v51.folder, v3[1]) == 0 -- inferred equivalent call
				local folder = v51.folder
				local v55 = VehicleConfig.DRIVE_LEVEL[attr(folder, "Model")] -- inferred equivalent call
				local v56 = attr(localPlayer, "Level") -- inferred equivalent call

				if v55 then
					if not ((typeof(v56) ~= "number" and 1 or v56) < v55) then
						v55 = nil
					end
				else
					v55 = nil
				end

				local v57

				if v55 == nil then
					v57 = false
				elseif v54 then
					local folder2 = v51.folder
					local flag2 = true

					for i = 2, #v51.def.seats do
						if (attr(folder2, v3[i]) or 0) == 0 then -- inferred equivalent call
							v57 = true
							flag2 = false
							break
						end
					end

					if flag2 then
						v57 = false
					end
				else
					v57 = v54
				end

				local prompt2 = (v55 or 0) * 8 + (v54 and 1 or 0) + (v57 and 2 or 0) + (Glyph.gamepad() and 4 or 0)

				if v48.prompt ~= prompt2 then
					local prompt = v48.prompt
					v48.prompt = prompt2

					if v55 and v54 then
						local v59

						if v57 then
							v59 = promptKey(true) .. "RIDE   ·   "
						else
							Glyph.setCap(cap, nil, nil)
							v43.Position = UDim2.new(0, 0, 0.5, 0)
							v59 = ""
						end

						v43.Text = v59 .. "DRIVING REQUIRES LEVEL " .. v55
						v43.TextColor3 = color3
					else
						v43.Text = promptKey(true) .. (v54 and "DRIVE" or "GET IN") -- inferred equivalent call
						v43.TextColor3 = color2
					end

					if prompt == nil then
						parent5.Visible = true
					end
				end

				v52 = true
			elseif v48.prompt ~= nil then
				v48.prompt = nil
				parent5.Visible = false
			end
		end

		debug.profileend()
		debug.profilebegin("VC.hud.enter")

		if touchEnabled then
			if v51 then
				local folder = v51.folder
				local v54 = VehicleConfig.DRIVE_LEVEL[attr(folder, "Model")] -- inferred equivalent call
				local v55 = attr(localPlayer, "Level") -- inferred equivalent call

				if v54 then
					if not ((typeof(v55) ~= "number" and 1 or v55) < v54) then
						v54 = nil
					end
				else
					v54 = nil
				end

				local v56 = attr(v51.folder, v3[1]) == 0 -- inferred equivalent call
				local locked

				if v54 == nil then
					locked = false
				else
					locked = not otherSeatFree(v51.folder, #v51.def.seats) -- inferred equivalent call
				end

				local v58 = attr(v51.folder, "Model") -- inferred equivalent call
				v46.word = not locked and (v56 and not v54 and "DRIVE" or "GET IN") or "LEVEL " .. v54
				v46.what = v58 == "Humvee" and "HUMVEE" or VehicleConfig.DRIVE_NAMES[v58] or ""
				v46.locked = locked
				EnterButton.set("vehicle", v46)
			else
				EnterButton.set("vehicle", nil)
			end
		end

		debug.profileend()
		local v54 = v8 ~= nil or v52

		if v54 ~= v48.on then
			v48.on = v54
			vehicleHud.Enabled = v54
		end
	end

	local function drawSolid(data, list, p)
		local cf = data.cf
		local count = #list
		list[count + 1] = data.solidRoot
		p[count + 1] = cf
		list[count + 2] = data.holder
		p[count + 2] = cf + cf:VectorToWorldSpace(data.def.center)
	end

	@native local function drawVehicle(data, list, p, flag2: boolean)
		local drawnCf = data.drawnCf
		local count = #list

		if flag2 then
			count += 1
			list[count] = data.hullRoot
			p[count] = drawnCf
		end

		local wheelRoots = data.wheelRoots

		for k, wheel in data.def.wheels do
			local wheel2 = data.wheels[k]
			count += 1
			list[count] = wheelRoots[k]
			p[count] = VehicleSim.wheelCFrame(drawnCf, wheel, wheel2.shown, wheel2.steer, wheel2.angle)
		end

		if data.def.turret then
			local aim, v48 = data.def.aim(drawnCf, data.yaw, data.pitch)
			list[count + 1] = data.turretRoot
			p[count + 1] = aim
			list[count + 2] = data.gunRoot
			p[count + 2] = v48
		end
	end

	local function shiftPx(drawnCf: CFrame, cf: CFrame, p: number, magnitude: number) -- 1 equivalent call inferred from this helper
		local v48 = (drawnCf.LookVector - cf.LookVector).Magnitude + (drawnCf.UpVector - cf.UpVector).Magnitude
		return ((drawnCf.Position - cf.Position).Magnitude + v48 * p) * Detail.pxK / math.max(magnitude, 1)
	end

	local v48 = VOXEL_SIZE * VOXEL_SIZE * VOXEL_SIZE
	local function shadeList(items, p: number)
		for _, item in items do
			local size = item.Size
			local castShadow

			if item.Transparency == 0 then
				castShadow = p == 0 or p <= size.X * size.Y * size.Z / v48
			else
				castShadow = false
			end

			if item.CastShadow ~= castShadow then
				item.CastShadow = castShadow
			end
		end
	end
	local function shade(state, shadowBand: number)
		local shadowVersion = Detail.shadowVersion
		state.shadowBand = shadowBand
		state.shadowVer = shadowVersion
		local v49

		if shadowBand == 0 then
			v49 = not Detail.low and 0 or Detail.bandCells(0)
		else
			v49 = Detail.bandCells(shadowBand)
		end

		shadeList(state.hullParts, v49)

		for _, wheelPart in state.wheelParts do
			shadeList(wheelPart, v49)
		end

		shadeList(state.turretParts, v49)
		shadeList(state.gunParts, v49)

		for _, v50 in state.guns or {} do
			shadeList(v50.parts, v49)
		end
	end

	local count = 0

	local function samePose(cframe: CFrame, cf: CFrame): boolean -- 2 equivalent calls inferred from this helper
		return (cframe.Position - cf.Position).Magnitude < 0.001
			and (cframe.LookVector - cf.LookVector).Magnitude < 0.00001
			and (cframe.UpVector - cf.UpVector).Magnitude < 0.00001
	end

	local Lighting = game:GetService("Lighting")

	local function offView(pointToWorldSpace: Vector3, p: number, vector3_2: Vector3, p2: number, position: Vector3, lookVector2: Vector3, p3: number)
		local v49 = 0

		while true do
			local vector3_3 = pointToWorldSpace - vector3_2 * v49 - position
			local magnitude = vector3_3.Magnitude

			if magnitude <= p then
				return false
			end

			if math.acos((math.clamp(lookVector2:Dot(vector3_3) / magnitude, -1, 1))) - math.asin(p / magnitude) <= p3 then
				return false
			end

			if p2 <= v49 then
				return true
			end

			v49 = math.min(v49 + p, p2)
		end
	end

	local function drawKey(data, p: number)
		local v49 = math.round(data.yaw * 1000) * 7 + math.round(data.pitch * 1000) * 13
		local wheels = data.def.wheels

		for k, wheel in data.wheels do
			local v50 = wheels[k].radius * p
			v49 += (math.round(wheel.shown * p) * 3 + math.round(wheel.steer * v50) * 5 + math.round(wheel.angle * v50) * 11) * k
		end

		return v49
	end

	local function updateLamps(state, flag2: boolean, braking: boolean)
		local lampState = (flag2 and 2 or 0) + (braking and 1 or 0)

		if lampState == state.lampState then
			return
		end

		state.lampState = lampState
		local head = state.def.lamps.head
		local tail = state.def.lamps.tail

		for k, hullPart in state.hullParts do
			local hullPal = state.hullPals[k]

			if hullPal == head then
				local material

				if flag2 then
					material = Enum.Material.Neon
				else
					material = Palette[hullPal].material
				end

				hullPart.Material = material
			elseif hullPal == tail then
				local material

				if braking then
					material = Enum.Material.Neon
				else
					material = Palette[hullPal].material
				end

				hullPart.Material = material
			end
		end
	end

	local v49 = 0
	local nowsById = {}

	@native local function simulate(p: number)
		local now = os.clock()
		local v50 = now - v49 > 0.5

		if v50 then
			v49 = now
		end

		for _, v51 in ground do
			local v52 = attr(v51.folder, "Owner") == localPlayer.UserId -- inferred equivalent call

			if v52 and not v51.sim then
				startSim(v51)
			elseif not v52 and v51.sim then
				stopSim(v51)
			end

			local sim = v51.sim

			if not sim then
				continue
			end

			if v50 then
				refreshParams(v51)
			end

			local driver = false

			if attr(v51.folder, "S1") == localPlayer.UserId then -- inferred equivalent call
				driver = v8 == v51 and v19
			end

			local input = sim.input
			input.driver = driver

			if driver then
				local steer, throttle, handbrake = readInput()
				input.steer = steer
				input.throttle = throttle
				input.handbrake = handbrake

				if sim.asleep then
					VehicleSim.wake(sim)
				end
			else
				input.steer = 0
				input.throttle = 0
				input.handbrake = true
			end

			local v54 = attr(v51.folder, "Running") == true -- inferred equivalent call

			if v54 ~= sim.running then
				VehicleSim.setRunning(sim, v54)
			end

			sim.health = attr(v51.folder, "Health") or sim.health -- inferred equivalent call

			if sim.asleep and now - v51.lastSupportCheck > 0.5 then
				v51.lastSupportCheck = now

				if not VehicleSim.supported(sim) then
					VehicleSim.wake(sim)
				end
			end

			local dir = sim.dir
			local gear = sim.gear
			VehicleSim.step(sim, p)

			if sim.dir ~= dir and (sim.dir == 1 or sim.dir == 2) and dir ~= 0 or sim.dir == 1 and gear < sim.gear then
				local gear2 = v.gear
				oneShot(gear2.id, gear2.at, gear2.length, sim.cf.Position, gear2.gain) -- inferred equivalent call
			end

			local vel = sim.vel
			local ang = sim.ang
			v51.vel = vel
			v51.ang = ang
			local asleep = sim.asleep
			local braking = sim.braking or input.handbrake and driver
			local throttle

			if sim.throttle == 0 then
				throttle = sim.pivot * math.abs(sim.steer)
			else
				throttle = sim.throttle
			end

			v51.asleep = asleep
			v51.braking = braking
			v51.throttle = throttle

			for k, wheel in sim.wheels do
				local wheel2 = v51.wheels[k]
				local shown = wheel.shown
				local steer = wheel.steer
				local angle = wheel.angle
				local speed = wheel.speed
				local contact = wheel.contact
				wheel2.shown = shown
				wheel2.steer = steer
				wheel2.angle = angle
				wheel2.speed = speed
				wheel2.contact = contact

				if not (wheel.landing > 14 and now - v51.lastLand > 0.3) then
					continue
				end

				v51.lastLand = now
				hitSound("terrain", wheel.point, math.clamp(wheel.landing / 40, 0.3, 1)) -- inferred equivalent call
			end

			local v56 = VehicleSim.takeCrash(sim)

			if v56 and now - v51.lastCrash > VehicleConfig.CRASH_COOLDOWN then
				v51.lastCrash = now
				crashSound(v56.point, v56.speed)
				remotes.VehicleCrash:FireServer(v51.id, v56.speed, v56.point, v56.normal)
			end

			local v57 = VehicleConfig.PUSH[v51.def.name]
			local v58

			if v57 and v57.every then
				v58 = v57.every
			else
				v58 = VehicleConfig.PUSH_EVERY
			end

			if
				driver
				and sim.wallVoxel
				and sim.wallAt
				and now - sim.wallAt < 0.15
				and math.abs(input.throttle) >= VehicleConfig.PUSH_THROTTLE
				and v58 <= now - (nowsById[v51.id] or 0)
				and -sim.wallNormal:Dot(sim.cf.LookVector) * math.sign(input.throttle) > 0.5
			then
				nowsById[v51.id] = now
				remotes.VehicleRam:FireServer(v51.id, sim.wallPoint, sim.wallNormal)
			end

			if
				(sim.asleep or not (now - v51.lastSend >= 1 / VehicleConfig.POSE_RATE))
				and (not sim.asleep or v51.sentAsleep)
			then
				if not sim.asleep then
					v51.sentAsleep = false
				end
			else
				v51.lastSend = now
				v51.sentAsleep = sim.asleep
				remotes.VehicleDrive:FireServer(
					v51.id,
					sim.cf,
					sim.vel,
					sim.ang,
					packExtra(v51, sim),
					workspace:GetServerTimeNow()
				)
			end
		end
	end

	local v50 = {}
	local v51 = {}

	local v52 = { v = nil, cf = CFrame.identity }

	local function followCamera(vector3_2: Vector3) -- 2 equivalent calls inferred from this helper
		local currentCamera = workspace.CurrentCamera

		if currentCamera and currentCamera.CameraType == Enum.CameraType.Custom and vector3_2.Magnitude > 0.0001 then
			currentCamera.CFrame += vector3_2
		end
	end

	local function holdRider(p, data, p2: number) -- 3 equivalent calls inferred from this helper
		p.CFrame = data.cf * (MountedGun.seatFrame(data, p2) or CFrame.new(data.def.seats[p2].root))
		p.AssemblyLinearVelocity = data.vel
		p.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
	end

	local function checkSeat()
		local v53 = nil
		local v54 = 0

		for _, v56 in ground do
			local v57 = seatOf(v56, localPlayer.UserId)

			if v56.id == v24 and v57 == 0 then
				v24 = 0
			end

			if v57 > 0 and (v56.id ~= v24 or not (os.clock() - v25 < 3)) then
				v54 = v57
				v53 = v56
				break
			end
		end

		if v53 ~= v8 or v54 ~= mine then
			if v8 then
				exitWhy("seat attribute changed: was", v8.id, mine, "now", v53 and v53.id, v54)
				stopRiding()
			end

			if v53 then
				exitWhy("seat attribute puts us in", v53.id, "seat", v54, "as UserId", localPlayer.UserId)
				startRiding(v53, v54)
			end
		end
	end

	@native local function aimTurret(state, p: number)
		local turret = state.def.turret
		local gun = state.def.gun
		local v53 = state.netYaw
		local v54 = state.netPitch
		local v55 = v8 == state and v19
		local vector3_2 = vector3

		if v55 and vector3_2 then
			local cframe = state.cf * CFrame.new(turret.pivot)
			local pointToObjectSpace = cframe:PointToObjectSpace(vector3_2)
			v53 = math.atan2(-pointToObjectSpace.X, -pointToObjectSpace.Z)

			local pointToObjectSpace2 = (cframe * CFrame.Angles(0, v53, 0) * CFrame.new(gun.trunnion)):PointToObjectSpace(vector3_2)
			v54 = math.atan2(pointToObjectSpace2.Y, -pointToObjectSpace2.Z)
		end

		local v56 = math.clamp(v54, gun.pitchMin, gun.pitchMax)
		local v57 = (v53 - state.yaw + 3.141592653589793) % 6.283185307179586 - 3.141592653589793
		local v58 = turret.traverse * p
		local v59 = (state.yaw + math.clamp(v57, -v58, v58) + 3.141592653589793) % 6.283185307179586 - 3.141592653589793
		local v60 = gun.elevate * p
		local v61 = state.pitch + math.clamp(v56 - state.pitch, -v60, v60)

		if v59 ~= state.yaw or v61 ~= state.pitch then
			state.yaw = v59
			state.pitch = v61
			state.drawnKey = 1e999
		end

		if v55 then
			state.netYaw = v59
			state.netPitch = v61
		end
	end

	v47.PARK_RECHECK = 0.25

	function v47.quiet(data, p: number): boolean
		if
			data.hullDirty
			or data.solidDirty
			or data.spareWant
			or data.knock ~= nil
			or data.knocked ~= nil
			or data.voicesMade ~= nil
		then
			return false
		end

		local stopT0 = data.stopT0

		if stopT0 and p - stopT0 < v.stop.length then
			return false
		end

		local voices = data.voices

		if voices then
			for _, voice in voices do
				if (object2[voice.player] or 0) >= 0.001 then
					return false
				end
			end
		end

		local def = data.def

		if
			def.turret
			and (math.abs((data.netYaw - data.yaw + 3.141592653589793) % 6.283185307179586 - 3.141592653589793) > 1e-6 or math.abs(math.clamp(
				data.netPitch,
				def.gun.pitchMin,
				def.gun.pitchMax
			) - data.pitch) > 1e-6)
		then
			return false
		end

		local guns = data.guns

		if guns then
			for _, gun in guns do
				if
					gun.yaw ~= 0
					or gun.pitch ~= 0
					or gun.spin ~= 0
					or gun.heat ~= 0
					or gun.kick ~= 0
					or gun.glow ~= 0
					or gun.flashOn
				then
					return false
				end
			end
		end

		return true
	end

	function v47:parked(p: number, vector3_2: Vector3)
		if self.idleUntil <= p then
			return false
		end

		local sim = self.sim
		local v53

		if self == v8 then
			v53 = false
		else
			v53 = not (self.hullDirty or self.solidDirty or self.spareWant)

			if v53 then
				if self.knock == nil and self.cf == self.idleCf and sim == self.idleSim then
					if sim then
						v53 = sim.asleep
					else
						v53 = self.poses[#self.poses] == self.idleNewest
					end

					if v53 then
						v53 = false

						if attr(self.folder, "Running") ~= true then -- inferred equivalent call
							v53 = false

							if attr(self.folder, "Wrecked") ~= true then -- inferred equivalent call
								v53 = false

								if attr(self.folder, "Health") == self.idleHealth then -- inferred equivalent call
									if self.shadowVer == Detail.shadowVersion then
										v53 = Detail.shadowBand(
											(self.idleCenter - vector3_2).Magnitude,
											self.shadowBand
										) == self.shadowBand
									else
										v53 = false
									end
								end
							end
						end
					end
				else
					v53 = false
				end
			end
		end

		if v53 then
			for i = 1, #self.def.seats do
				local v54 = attr(self.folder, v3[i]) -- inferred equivalent call

				if typeof(v54) == "number" and v54 ~= 0 then
					v53 = false
					break
				end
			end
		end

		if not v53 then
			self.idleSync = nil
		end

		return v53
	end

	@native local function frame4(p: number)
		count += 1
		local now = os.clock()
		table.clear(v50)
		table.clear(v51)
		local currentCamera = workspace.CurrentCamera
		local cframe = currentCamera.CFrame
		local position = cframe.Position
		local lookVector2 = cframe.LookVector
		local viewportSize = currentCamera.ViewportSize
		local v53 = viewportSize.X / math.max(viewportSize.Y, 1)
		local v54 = math.atan(math.tan(math.rad((math.max(currentCamera.FieldOfView, 80))) * 0.5) * math.sqrt(1 + v53 * v53)) + 0.5235987755982988
		local v55 = Lighting:GetSunDirection()

		if v55.Y <= 0 then
			v55 = Lighting:GetMoonDirection()
		end

		local globalShadows = Lighting.GlobalShadows

		for _, v56 in ground do
			local sim = v56.sim

			if v56.idleUntil then
				if v47.parked(v56, now, position) then
					if not sim and v56.idleNewest then
						PoseTiming.delay(v56.timing)
						v56.timing.offClock = now
					end

					continue
				end

				v56.idleUntil = nil
			end

			if v56.hullQueue and v47.hullFrame ~= count then
				v47.hullFrame = count
				debug.profilebegin("VC.hull.step")
				rebuildHull(v56, true, 0.003, true)
				debug.profileend()
			elseif
				v56.hullDirty
				and not v56.hullQueue
				and v47.hullFrame ~= count
				and (not (Detail.low or Detail.strain >= 1) or now - (v56.hullAt or 0) >= 0.2)
			then
				v47.hullFrame = count
				v56.hullAt = now
				v56.hullDirty = nil
				debug.profilebegin("VC.rebuildHull(hit)")
				rebuildHull(v56, true, 0.003)
				debug.profileend()
			elseif v56.solidDirty and v47.hullFrame ~= count then
				v47.hullFrame = count
				v56.solidDirty = nil
				debug.profilebegin("VC.rebuildSolid(hit)")
				rebuildSolid(v56)
				v56.solidCf = nil
				debug.profileend()
			elseif v56.spareWant and v47.hullFrame ~= count then
				v47.hullFrame = count

				debug.profilebegin("VC.spares")
				local hiddenParts = v56.hiddenParts
				local hiddenWelds = v56.hiddenWelds

				for _ = 1, 4 do
					if #hiddenParts >= v56.spareWant then
						break
					end

					local part = newPart(nil, false) -- inferred equivalent call
					part.Transparency = 1
					part.CastShadow = false
					table.insert(hiddenWelds, RigidParts.weld(v56.hullRoot, part, CFrame.identity))
					part.Parent = v56.model
					table.insert(hiddenParts, part)
				end

				if #hiddenParts >= v56.spareWant then
					v56.spareWant = nil
				end

				debug.profileend()
			end

			debug.profilebegin("VC.f.pose")

			local knocked = v56.knocked

			if knocked then
				v56.cf *= knocked:Inverse()
				v56.knocked = nil
				v56.restAt = nil
			end

			if sim then
				local v57 = math.clamp(sim.accum / VehicleConfig.STEP, 0, 1)
				local cf

				if sim.asleep then
					cf = sim.cf
				else
					cf = sim.prevCf:Lerp(sim.cf, v57)
				end

				v56.cf = cf
			else
				interpolate(v56)

				for _, wheel in v56.wheels do
					if not (v56.asleep or v56.stalled) then
						wheel.angle = (wheel.angle + wheel.speed / v56.def.wheels[1].radius * p) % 6.283185307179586
					end
				end
			end

			local knocked2 = knockPose(v56, p)
			local unknocked

			if knocked2 then
				unknocked = v56.cf
			end

			v56.unknocked = unknocked

			if knocked2 then
				v56.cf *= knocked2
				v56.knocked = knocked2
			end

			local running = attr(v56.folder, "Running") == true -- inferred equivalent call
			local wrecked = attr(v56.folder, "Wrecked") == true -- inferred equivalent call

			if running ~= v56.running then
				v56.running = running

				if running then
					v56.stopT0 = nil
					local pointToWorldSpace = v56.cf:PointToWorldSpace(v56.def.center)
					oneShot(v.start.id, v.start.at, v.start.length, pointToWorldSpace, v.start.gain) -- inferred equivalent call
				else
					v56.stopT0 = os.clock()
					local voices = v56.voices

					if voices then
						voices.stop.player:Stop()
						AudioGraph.park(voices.stop)
					end
				end
			end

			updateLamps(v56, running, v56.braking)

			if v56.def.turret then
				aimTurret(v56, p)
			end

			if wrecked and not v56.smoked then
				v56.smoked = true

				local v61 = attr(v56.folder, "Model") -- inferred equivalent call
				local v62 = VehicleConfig.COOKOFF_MODELS[v61]

				if v62 then
					BattleFX.flash(
						v56.cf:PointToWorldSpace(v56.def.center + Vector3.new(0, 3, 0)),
						45 * v62,
						VehicleConfig.COOKOFF[v61].delay,
						6 * v62
					)
				end
			end

			v56.wrecked = wrecked
			debug.profileend()
			debug.profilebegin("VC.f.cull")
			local pointToWorldSpace = v56.cf:PointToWorldSpace(v56.def.center)
			local magnitude = (pointToWorldSpace - position).Magnitude
			local shadowBand = Detail.shadowBand(magnitude, v56.shadowBand)

			if shadowBand ~= v56.shadowBand or v56.shadowVer ~= Detail.shadowVersion then
				shade(v56, shadowBand)
			end

			local culled, v62

			if v56 == v8 or v56.drawnCf == nil then
				culled = false
				v62 = false
			else
				local size = v56.def.size
				v62 = Quality.mobile and 330 + size.Magnitude * 0.5 < magnitude

				if v62 then
					culled = v62
				else
					local v63 = not (globalShadows and v55.Y > 0) and 0 or math.min(size.Magnitude / v55.Y, 200)
					culled = offView(pointToWorldSpace, size.Magnitude * 0.5 + 20, v55, v63, position, lookVector2, v54)
				end
			end

			if culled ~= v56.culled then
				v56.model:SetAttribute("Culled", culled)
			end

			v56.culled = culled

			local solidCf = v56.solidCf
			local v63, v64, cf, v65

			if solidCf == nil then
				if
					not culled
					or magnitude <= 60
					or (count + v56.id) % 3 == 0
					or v62
					and not offView(
						pointToWorldSpace,
						v56.def.size.Magnitude * 0.5 + 20,
						v55,
						0,
						position,
						lookVector2,
						v54
					)
				then
					v56.solidCf = v56.cf
					v63 = v50
					v64 = v51
					cf = v56.cf
					v65 = #v63
					v63[v65 + 1] = v56.solidRoot
					v64[v65 + 1] = cf
					v63[v65 + 2] = v56.holder
					v64[v65 + 2] = cf + cf:VectorToWorldSpace(v56.def.center)
				end
			elseif
				not samePose(solidCf, v56.cf) -- inferred equivalent call
				and (not culled or magnitude <= 60 or (count + v56.id) % 3 == 0 or v62 and not offView(
					pointToWorldSpace,
					v56.def.size.Magnitude * 0.5 + 20,
					v55,
					0,
					position,
					lookVector2,
					v54
				))
			then
				v56.solidCf = v56.cf
				v63 = v50
				v64 = v51
				cf = v56.cf
				v65 = #v63
				v63[v65 + 1] = v56.solidRoot
				v64[v65 + 1] = cf
				v63[v65 + 2] = v56.holder
				v64[v65 + 2] = cf + cf:VectorToWorldSpace(v56.def.center)
			end

			debug.profileend()
			debug.profilebegin("VC.f.draw")

			if not culled then
				local drawnKey = drawKey(
					v56,
					v56 == v8 and 1024 or 2 ^ math.clamp(
						math.ceil((math.log(2 * Detail.pxK / math.max(magnitude, 1), 2))),
						-4,
						10
					)
				)
				local drawnCf = v56.drawnCf
				local v68

				if drawnCf == nil or drawnCf == v56.cf then
					v68 = false
				elseif v56 == v8 then
					v68 = not samePose(drawnCf, v56.cf) -- inferred equivalent call
				else
					v68 = shiftPx(drawnCf, v56.cf, v56.def.size.Magnitude * 0.5, magnitude) >= 0.5 -- inferred equivalent call
				end

				if drawnCf == nil or v68 then
					v56.drawnCf = v56.cf
					v56.drawnKey = drawnKey
					drawVehicle(v56, v50, v51, true)
				elseif v56.drawnKey ~= drawnKey then
					v56.drawnKey = drawnKey
					drawVehicle(v56, v50, v51, false)
				end
			end

			debug.profileend()

			debug.profilebegin("VC.f.sound")
			local soundDt = (v56.soundDt or 0) + p

			if magnitude <= 60 or (count + v56.id) % 3 == 0 or v56.idleSync then
				v56.soundDt = 0
				updateSound(v56, soundDt)
			else
				v56.soundDt = soundDt
			end

			debug.profileend()
			debug.profilebegin("VC.f.gun")
			MountedGun.update(v56, p, v50, v51)
			debug.profileend()
			debug.profilebegin("VC.f.damage")
			local idleHealth = attr(v56.folder, "Health") -- inferred equivalent call
			local char

			if wrecked then
				char = 1
			elseif typeof(idleHealth) ~= "number" then
				char = 0
			else
				char = math.clamp((1 - idleHealth) * 0.9, 0, 0.7)
			end

			if math.abs(char - v56.char) > 0.02 then
				v56.char = char
				charHull(v56)
			end

			v56.damage.update(
				v56.cf,
				v56.engine,
				typeof(idleHealth) ~= "number" and 1 or idleHealth,
				wrecked,
				p,
				position,
				culled
			)
			debug.profileend()
			debug.profilebegin("VC.f.seats")

			local v69 = (v56.botDt or 0) + p
			local v70 = not culled or (v56.botFrame or 0) % 3 == 0
			v56.botFrame = (v56.botFrame or 0) + 1
			v56.botDt = v70 and 0 or v69
			local v71

			if culled or v56 == v8 then
				v71 = v56.cf
			else
				v71 = v56.drawnCf or v56.cf
			end

			local v72 = false

			for i = 1, seatCount(v56) do -- inferred equivalent call
				local v73 = attr(v56.folder, v3[i]) -- inferred equivalent call
				v72 = typeof(v73) == "number" and v73 ~= 0 or v72

				if typeof(v73) == "number" and v73 < 0 then
					if v70 then
						SeatedBots.place(
							-v73,
							v71 * (MountedGun.seatFrame(v56, i) or CFrame.new(v56.def.seats[i].root)),
							i,
							v56.def,
							v56.vel,
							v69
						)
					end
				elseif v70 and typeof(v73) == "number" and v73 ~= 0 and v73 ~= localPlayer.UserId then
					local playerByUserId = Players:GetPlayerByUserId(v73)
					local humanoidRootPart = playerByUserId
						and playerByUserId.Character
						and playerByUserId.Character:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart then
						holdRider(humanoidRootPart, v56, i) -- inferred equivalent call
					end
				end
			end

			debug.profileend()

			local v73 = false

			if
				not running
				and not wrecked
				and not v72
				and v56 ~= v8
				and v56.asleep
				and (typeof(idleHealth) ~= "number" or idleHealth > 0.6)
			then
				local v74

				if sim then
					v74 = sim.asleep
				elseif #v56.poses == 0 then
					v74 = true
				elseif v56.restAt == v56.poses[#v56.poses] then
					v74 = v56.cf == v56.restCf
				else
					v74 = false
				end

				if v74 and v47.quiet(v56, now) then
					if v56.idleSync or v56.idleDrawn == count - 1 then
						v56.idleUntil = now + v47.PARK_RECHECK
						v56.idleSync = true
						local cf2 = v56.cf
						local pos = v56.poses[#v56.poses]
						v56.idleCf = cf2
						v56.idleSim = sim
						v56.idleNewest = pos
						v56.idleHealth = idleHealth
						v56.idleCenter = pointToWorldSpace
						v73 = true
					else
						v56.idleDrawn = count
						v56.drawnCf = nil
					end
				end
			end

			if not v73 then
				v56.idleSync = nil
			end
		end

		debug.profilebegin("VC.f.move")

		if #v50 > 0 then
			workspace:BulkMoveTo(v50, v51, Enum.BulkMoveMode.FireCFrameChanged)
		end

		debug.profileend()
		debug.profilebegin("VC.f.ride")

		local v56 = v52.v

		if v56 and not v8 then
			local _, v57, v58 = myCharacter() -- inferred equivalent call

			if v58 and v57 and v57.Health > 0 and not v57.Sit then
				local cf = v56.cf

				if cf ~= v52.cf and (cf.Position - v52.cf.Position).Magnitude < 10 then
					local position2 = v58.Position
					local pointToWorldSpace = (cf * v52.cf:Inverse()):PointToWorldSpace(position2)
					local v59 = yawOf(cf.LookVector) - yawOf(v52.cf.LookVector) -- inferred equivalent call
					v58.CFrame = CFrame.new(pointToWorldSpace) * CFrame.Angles(0, v59, 0) * v58.CFrame.Rotation
					followCamera(pointToWorldSpace - position2) -- inferred equivalent call
				end

				v52.cf = cf
			end
		end

		local v57 = v8

		if v57 then
			local _, v58, v59 = myCharacter() -- inferred equivalent call

			if v59 and v58 then
				local position2 = v59.Position
				holdRider(v59, v57, mine) -- inferred equivalent call
				followCamera(v59.Position - position2) -- inferred equivalent call

				if not v58.Sit then
					v58.Sit = true
				end

				if (v19 or v57.def.seats[mine].inside) and v58.Parent and v58.Parent:FindFirstChildOfClass("Tool") then
					v58:UnequipTools()
				end
			end
		end

		debug.profileend()
		debug.profilebegin("VC.f.hud")
		updateHud()
		debug.profileend()
	end

	local raycastParams2 = RaycastParams.new()
	raycastParams2.FilterType = Enum.RaycastFilterType.Include
	raycastParams2.FilterDescendantsInstances = { vehicleHulls }

	RunService.PreSimulation:Connect(function()
		local _, v53, v54 = myCharacter() -- inferred equivalent call
		local v55 = v8

		if v55 and v54 then
			holdRider(v54, v55, mine) -- inferred equivalent call
		end

		local v56 = v52.v

		if v8 or not v54 or not v53 or v53.Health <= 0 or v53.Sit then
			v52.v = nil
			return
		end

		local position = v54.Position
		local v57 = nil

		for _, v59 in ground do
			if (v59.cf.Position - position).Magnitude < v59.def.size.Magnitude * 0.5 + 12 then
				local raycastResult = workspace:Raycast(position, Vector3.new(0, -12, 0), raycastParams2)

				if not raycastResult then
					break
				end

				local parent = raycastResult.Instance.Parent

				for _, v61 in ground do
					if v61.model == parent then
						if
							v53.HipHeight + v54.Size.Y * 0.5 + 1 > raycastResult.Distance
							or v61 == v56 and v53.FloorMaterial == Enum.Material.Air
						then
							v57 = v61
						end

						break
					end
				end

				break
			end
		end

		if v57 ~= v56 then
			v52.v = v57

			if v57 then
				v52.cf = v57.cf
			end
		end
	end)

	local raycastParams3 = RaycastParams.new()
	raycastParams3.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams3.IgnoreWater = true
	local v53 = 0
	local vector3_2 = nil
	local v54 = 20
	local fieldOfView = nil

	local function ease(p: number, p2: number)
		return 1 - math.exp(-p * p2)
	end

	local flag2 = false
	fn = function()
		frame3.Visible = false
		parent4.Visible = false
		parent3.Visible = false
		v47.ride = nil
		v32.hide()
		local playerHud = v45 ~= false and localPlayer.PlayerGui:FindFirstChild("PlayerHud")

		if playerHud then
			v45 = false
			playerHud.Enabled = true
		end

		if flag2 then
			UserInputService.MouseIconEnabled = true
			flag2 = false
		end
	end

	local v56 = { chars = {}, eye = Vector3.new(-3.25, 3.1, -3.8) }
	function v56.apply(p)
		if p == nil and next(v56.chars) == nil then
			return
		end

		local characterSet = {}

		if p then
			for i = 1, #p.def.seats do
				local v57 = attr(p.folder, v3[i]) -- inferred equivalent call
				local playerByUserId

				if not (i == mine or typeof(v57) ~= "number" or not (v57 > 0)) then
					playerByUserId = Players:GetPlayerByUserId(v57)
				end

				if playerByUserId and playerByUserId.Character then
					characterSet[playerByUserId.Character] = true
				end
			end
		end

		local now = os.clock()

		if now < (v56.nextWalk or 0) then
			local flag3 = true

			for k in characterSet do
				if not v56.chars[k] then
					flag3 = false
					break
				end
			end

			if flag3 then
				for k in v56.chars do
					if not characterSet[k] then
						flag3 = false
						break
					end
				end
			end

			if flag3 then
				return
			end
		end

		v56.nextWalk = now + 0.5

		for folder, _ in v56.chars do
			if characterSet[folder] then
				continue
			end

			for _, descendant in folder:GetDescendants() do
				if descendant:IsA("BasePart") or descendant:IsA("Decal") then
					descendant.LocalTransparencyModifier = 0
				end
			end
		end

		for folder, _ in characterSet do
			for _, descendant in folder:GetDescendants() do
				if not ((descendant:IsA("BasePart") or descendant:IsA("Decal")) and descendant.LocalTransparencyModifier ~= 1) then
					continue
				end

				descendant.LocalTransparencyModifier = 1
			end
		end

		v56.chars = characterSet
	end

	@native local function camera(p: number)
		local v57 = v8
		local v58

		if v57 == nil then
			v58 = false
		else
			v58 = v19

			if v58 then
				if v57.def.turret == nil then
					v58 = false
				else
					v58 = not (v57.wrecked or MountedGun.active())
						and (v15.zoomToggle or UserInputService.MouseEnabled and not TouchControls.active() and not GuiService.MenuIsOpen and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2))
				end
			end
		end

		local apply = v56.apply
		local v59

		if v57 and v19 and (periscope or v58) and v57.def.turret and not MountedGun.active() then
			v59 = v57
		end

		apply(v59)
		local v60

		if v57 == nil then
			v60 = false
		else
			v60 = v15.rider()
		end

		if v57 and MountedGun.active() then
			MountedGun.camera(p)
			MountedGun.step(os.clock(), p)
		else
			if not (v57 and (v19 or v60) and v57.def.turret) then
				v32.hide()
			end

			if v57 and (v19 or v60) then
				local currentCamera = workspace.CurrentCamera

				if currentCamera.CameraType ~= Enum.CameraType.Scriptable then
					currentCamera.CameraType = Enum.CameraType.Scriptable
				end

				if not GuiService.MenuIsOpen and UserInputService.MouseEnabled then
					UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

					UserInputService.MouseIconEnabled = false
					flag2 = true
				end

				local now = os.clock()
				local v61 = 0
				local v62 = 0
				local v63

				if TouchControls.active() then
					v63 = Vector2.zero
				else
					v63 = UserInputService:GetMouseDelta()
				end

				if v63.Magnitude > 0 then
					v61 -= v63.X * 0.0035
					v62 += v63.Y * 0.0035
				end

				if v17.Magnitude > 0 then
					v61 -= v17.X * 3.2 * LookSettings.look * p
					v62 -= v17.Y * 3.2 * LookSettings.look * p
				end

				if lookVector then
					local lookVector2 = currentCamera.CFrame.LookVector
					local vector3_3 = lookVector
					local v64 = (yawOf(lookVector2) - yawOf(vector3_3) + 3.141592653589793) % 6.283185307179586 - 3.141592653589793 -- inferred equivalent call
					local v65 = math.asin((math.clamp(vector3_3.Y, -1, 1))) - math.asin((math.clamp(lookVector2.Y, -1, 1)))

					if math.abs(v64) > 0.0001 or math.abs(v65) > 0.0001 then
						v61 += v64
						v62 += v65
					end
				end

				local v64 = v61 * LookSettings.vehicle
				local v65 = v62 * LookSettings.vehicle

				if v58 then
					v64 /= v15.zoom
					v65 /= v15.zoom
				end

				if math.abs(v64) + math.abs(v65) > 0.00001 then
					v16 = now
				end

				v11 = (v11 + v64 + 3.141592653589793) % 6.283185307179586 - 3.141592653589793

				local v66 = not v57.def.gun and -0.4363323129985824
					or math.min(-0.4363323129985824, -v57.def.gun.pitchMax)
				v12 = math.clamp(v12 + v65, v66, 1.0471975511965976)

				local v67 = v19 and v57.def.turret ~= nil
				local v68 = math.abs((v57.vel:Dot(v57.cf.LookVector)))

				if not v67 then
					local v69 = (yawOf(v57.cf.LookVector) - v13 + 3.141592653589793) % 6.283185307179586 - 3.141592653589793 -- inferred equivalent call
					v13 += v69 * math.min(p * 7, 1)
				end

				if not v67 and now - v16 > 1.2 and v68 > 6 and not (periscope or TouchControls.active()) then
					local v69 = math.min(p * 2.5, 1)
					v11 += (0 - v11) * v69
					v12 += (0.20943951023931956 - v12) * v69
				end

				fieldOfView = fieldOfView or currentCamera.FieldOfView
				local fieldOfView2

				if v58 then
					fieldOfView2 = math.deg((math.atan(math.tan(math.rad(fieldOfView) / 2) / v15.zoom))) * 2
				else
					fieldOfView2 = fieldOfView + math.clamp(v68 / v57.tuning.topSpeed, 0, 1) * 10
				end

				currentCamera.FieldOfView = fieldOfView2

				local chase = v57.def.chase
				local v70 = (not chase and 20 or chase.distance) * v15.chaseZoom
				local v71

				if periscope or v58 then
					local seat = v57.def.seats[mine]
					local cf = v57.cf
					local v72

					if v60 then
						v72 = seat.view
					else
						v72 = seat.root + Vector3.new(0, 1.9, 0.1)
					end

					local pointToWorldSpace = cf:PointToWorldSpace(v72)

					if v67 then
						local pointToWorldSpace2 = v57.def.aim(v57.cf, v57.yaw, v57.pitch):PointToWorldSpace(v56.eye)
						v71 = CFrame.new(pointToWorldSpace2) * CFrame.fromEulerAnglesYXZ(-v12, v13 + v11, 0)
					else
						v71 = CFrame.new(pointToWorldSpace) * v57.cf.Rotation * CFrame.fromEulerAnglesYXZ(
							-v12 + 0.20943951023931956,
							v11,
							0
						)
					end

					setCharacterShown(false)
				else
					local cframe = CFrame.fromEulerAnglesYXZ(-v12, v13 + v11, 0)

					local v72 = (v57.unknocked or v57.cf):PointToWorldSpace(v57.def.center) + Vector3.new(0, not chase and 3 or chase.height, 0)
					local v73

					if vector3_2 then
						v73 = vector3_2.Y + (v72.Y - vector3_2.Y) * (1 - math.exp(p * -9))
					else
						v73 = v72.Y
					end

					local vector3_3 = Vector3.new(v72.X, v73, v72.Z)
					vector3_2 = vector3_3

					if now - v53 > 0.5 then
						v53 = now
						local excludeInstances = { vehicleHulls }

						for _, v75 in Players:GetPlayers() do
							if v75.Character then
								table.insert(excludeInstances, v75.Character)
							end
						end

						for _, childName in {
							"VoxelLoose",
							"VoxelChips",
							"VoxelFalling",
							"BotRigs"
						} do
							local child = workspace:FindFirstChild(childName)

							if child then
								table.insert(excludeInstances, child)
							end
						end

						raycastParams3.ExcludeInstances = excludeInstances
					end

					local orbit

					if chase then
						orbit = chase.orbit
					end

					local v74

					if orbit and v12 < -orbit then
						v74 = -CFrame.fromEulerAnglesYXZ(orbit, v13 + v11, 0).LookVector
					else
						v74 = -cframe.LookVector
					end

					local spherecast = workspace:Spherecast(vector3_3, 1, v74 * v70, raycastParams3)

					if spherecast then
						v70 = math.max(spherecast.Distance, 2)
					end

					if v70 < v54 then
						v54 = v70
					else
						v54 += (v70 - v54) * (1 - math.exp(p * -3))
					end

					v71 = CFrame.new(vector3_3 + v74 * v54) * cframe
					setCharacterShown(true)
				end

				local cframe2

				if v21.x == 0 and v21.speed == 0 then
					cframe2 = v71
				else
					local v73 = math.min(p, 0.1)
					cframe2 = v71

					while v73 > 1e-6 do
						local v74 = math.min(v73, 1 / 240)
						v21.speed += (-676 * v21.x - 39 * v21.speed) * v74
						v21.x += v21.speed * v74
						v73 -= v74
					end

					if math.abs(v21.x) < 0.003 and math.abs(v21.speed) < 0.05 then
						v21.x = 0
						v21.speed = 0
					else
						local x = v21.x
						cframe2 = v71 * CFrame.Angles(0.019198621771937627 * x, 0, 0.006981317007977318 * v21.roll * x)
					end
				end

				currentCamera.CFrame = cframe2
				currentCamera.Focus = CFrame.new(v57.cf:PointToWorldSpace(v57.def.center))
				lookVector = cframe2.LookVector

				if v67 then
					local cannon = v15.loadout.cannon(v57.def, v57.folder)
					local lookVector2 = v71.LookVector
					local raycastResult = workspace:Raycast(v71.Position, lookVector2 * cannon.range, v57.params)
					local v73

					if raycastResult then
						v73 = raycastResult.Position
					else
						v73 = v71.Position + lookVector2 * cannon.range
					end

					vector3 = v73

					if cannon.auto and v15.weapon == 1 and v15.trigger() then
						tryFire()
					end

					if v15.weapon == 2 and v57.def.DRIVER_GUN and MountedGun.yielded(v57) then
						v15.pick(1)
					end

					local minigun = v15.weapon == 2
					local driveStep, mgHot, v76, v77 = MountedGun.driveStep(now, p, vector3, minigun and v15.trigger())
					local gunAtMg

					if minigun and v76 and v77 then
						local raycastResult2 = workspace:Raycast(v76, v77 * v15.range, v57.params)

						if raycastResult2 then
							gunAtMg = raycastResult2.Position
						else
							gunAtMg = v76 + v77 * v15.range
						end
					end

					local v79 = attr(v57.folder, "Shells") -- inferred equivalent call
					local shells = typeof(v79) ~= "number" and 0 or v79
					crossReady(shells >= 1 and os.clock() - v14 >= cannon.spacing) -- inferred equivalent call
					local v82 = attr(v57.folder, "RefillAt") -- inferred equivalent call
					local v83 = (typeof(v82) ~= "number" or not (v82 > 0)) and 0 or v82 - workspace:GetServerTimeNow()

					if v22 == v57 then
						if v83 > 0 then
							v23 = true
						end

						if v23 and v83 <= v.lock.lead then
							reloadSound(v57, v.lock)
							v22 = nil
						end
					end

					local launcher

					if v15.weapon == 2 then
						launcher = v57.def.launcher
					end

					local refill = cannon.refill
					local maxShells = cannon.shells
					local spacing = cannon.spacing
					local v85 = v14

					if launcher then
						local launcher2 = v15.loadout.launcher(v57.def, v57.folder)
						local v86 = attr(v57.folder, "Missiles") -- inferred equivalent call
						shells = typeof(v86) ~= "number" and 0 or v86
						local v87 = attr(v57.folder, "MissileRefillAt") -- inferred equivalent call
						v83 = (typeof(v87) ~= "number" or not (v87 > 0)) and 0 or v87 - workspace:GetServerTimeNow()
						refill = launcher2.refill
						maxShells = launcher2.count
						spacing = launcher2.spacing
						v85 = v15.launchedAt or 0
					end

					local v86 = attr(v57.folder, "RefillAt") -- inferred equivalent call
					local numberRange5

					if typeof(v86) == "number" and v86 > 0 then
						numberRange5 = NumberRange.new(v86 - cannon.refill, v86)
					end

					if localPlayer:GetAttribute("VehicleLoad") ~= numberRange5 then
						localPlayer:SetAttribute("VehicleLoad", numberRange5)
					end

					v15.cardNames(v57)

					local sightState = v15.sightState

					if not sightState then
						sightState = { seats = {} }
						v15.sightState = sightState
					end

					local seats = sightState.seats
					table.clear(seats)

					for i = 1, #v57.def.seats do
						local v88 = attr(v57.folder, v3[i]) -- inferred equivalent call
						seats[i] = typeof(v88) == "number" and v88 ~= 0
					end

					local _, cframe = v57.def.aim(v57.cf, v57.yaw, v57.pitch)
					local pointToWorldSpace = cframe:PointToWorldSpace(v57.def.gun.muzzle)
					local gunAt, _, v89 = ShellFlight.trace(
						pointToWorldSpace,
						cframe.LookVector,
						function(origin: Vector3, direction: Vector3)
							local raycastResult2 = workspace:Raycast(origin, direction, v57.params)

							if raycastResult2 then
								return raycastResult2.Position
							end

							return nil
						end,
						cannon,
						0.2
					)

					sightState.cam = currentCamera
					sightState.body = v57.cf
					sightState.def = v57.def
					sightState.yaw = v57.yaw
					sightState.pitch = v57.pitch
					sightState.gunAt = gunAt
					local range

					if v89 then
						range = (gunAt - pointToWorldSpace).Magnitude / VehicleConfig.UNIT
					end

					sightState.range = range
					sightState.speed = kmh(v68) -- inferred equivalent call
					sightState.gear = gearOf(v57)
					sightState.health = attr(v57.folder, "Health") or 1 -- inferred equivalent call
					sightState.shells = shells
					sightState.maxShells = maxShells
					sightState.load = not (v83 > 0) and 1 or 1 - v83 / refill
					sightState.loadLeft = math.max(v83, 0)
					sightState.cooling = os.clock() - v85 < spacing
					sightState.magazine = launcher == nil and cannon.magazine == true
					sightState.gunName = launcher and "LAUNCHER" or cannon.magazine and "AUTOCANNON" or nil
					sightState.ammoName = launcher and "MISSILES" or cannon.magazine and "ROUNDS" or nil
					sightState.mine = mine
					sightState.periscope = periscope or v58
					local zoom

					if v58 then
						zoom = v15.zoom
					elseif periscope then
						zoom = -v15.zoom
					end

					sightState.zoom = zoom
					sightState.wrecked = v57.wrecked
					sightState.minigun = minigun
					sightState.gunAtMg = gunAtMg
					sightState.mgHeat = driveStep
					sightState.mgHot = mgHot
					sightState.rider = false
					v32.update(sightState)
				elseif v60 and v57.def.turret then
					if v31 ~= true then
						v31 = true

						for _, v73 in v30 do
							v73.BackgroundTransparency = 0
							v73.BackgroundColor3 = color2
						end
					end

					local riderState = v15.riderState

					if not riderState then
						riderState = {
							seats = {},
							shells = 0,
							maxShells = 0,
							load = 1,
							loadLeft = 0,
							cooling = false,
							mgHeat = 0,
							mgHot = false,
							minigun = false,
							rider = true
						}
						v15.riderState = riderState
					end

					riderState.cam = currentCamera
					riderState.body = v57.cf
					riderState.def = v57.def
					riderState.yaw = v57.yaw
					riderState.pitch = v57.pitch
					riderState.gunAt = v71.Position + v71.LookVector * 100
					riderState.range = nil
					riderState.speed = kmh(v68) -- inferred equivalent call
					riderState.gear = gearOf(v57)
					riderState.health = attr(v57.folder, "Health") or 1 -- inferred equivalent call
					riderState.mine = mine
					riderState.periscope = periscope
					riderState.zoom = nil
					riderState.wrecked = v57.wrecked
					v32.update(riderState)
				else
					if v31 == true then
						return
					end

					v31 = true

					for _, v73 in v30 do
						v73.BackgroundTransparency = 0
						v73.BackgroundColor3 = color2
					end
				end
			else
				if flag2 then
					UserInputService.MouseIconEnabled = true
					flag2 = false
				end

				if v31 ~= true then
					v31 = true

					for _, v61 in v30 do
						v61.BackgroundTransparency = 0
						v61.BackgroundColor3 = color2
					end
				end

				if fieldOfView then
					workspace.CurrentCamera.FieldOfView = fieldOfView
					fieldOfView = nil
				end

				vector3_2 = nil
			end
		end
	end

	RunService:BindToRenderStep("Vehicles", Enum.RenderPriority.Camera.Value + 1, Detail.timed("vc", function(p)
		debug.profilebegin("VC.checkSeat")
		checkSeat()
		debug.profileend()
		debug.profilebegin("VC.simulate")
		simulate(p)
		debug.profileend()
		debug.profilebegin("VC.frame")
		frame4(p)
		debug.profileend()
		debug.profilebegin("VC.camera")
		camera(p)
		debug.profileend()
	end))
end

localPlayer.CharacterRemoving:Connect(function()
	if v8 then
		stopRiding()
	end
end)