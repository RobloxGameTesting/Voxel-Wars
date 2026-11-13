do
	local Players = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer

	while LocalPlayer:GetAttribute("JoinCovered") == true do
		LocalPlayer:GetAttributeChangedSignal("JoinCovered"):Wait()
	end
end

task.wait(0.6)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")

local localPlayer = Players.LocalPlayer

local object = setmetatable({}, { __mode = "k" })

do
	local function attr(instance, p: string) -- 30 equivalent calls inferred from this helper
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
end

local Vehicles = ReplicatedStorage:WaitForChild("Vehicles")
local Remotes = Vehicles:WaitForChild("Remotes")
local parent2 = Vehicles:WaitForChild("Live")

local VehicleConfig = require(Vehicles:WaitForChild("VehicleConfig"))
local PoseTiming = require(Vehicles:WaitForChild("PoseTiming"))
local VehicleGrid = require(Vehicles:WaitForChild("VehicleGrid"))
local HeliModel = require(Vehicles:WaitForChild("HeliModel"))
local RigidParts = require(Vehicles:WaitForChild("RigidParts"))
local SeatedBots = require(Vehicles:WaitForChild("SeatedBots"))
local Detail = require(ReplicatedStorage.Voxel:WaitForChild("Detail"))
local AudioGraph = require(ReplicatedStorage.Voxel:WaitForChild("AudioGraph"))

local object2 = setmetatable({}, { __mode = "k" })
local object3 = setmetatable({}, { __mode = "k" })
local random = Random.new()

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
		local loopRegion = player.LoopRegion
		player.TimePosition = random:NextNumber(loopRegion.Min, (math.max(loopRegion.Min, loopRegion.Max - 0.5)))
		player:Play()
	end
end
local VoxelSound = require(ReplicatedStorage.Voxel:WaitForChild("VoxelSound"))
local BattleFX = require(ReplicatedStorage.Voxel:WaitForChild("BattleFX"))
local Quality = require(ReplicatedStorage.Voxel:WaitForChild("Quality"))
local TouchControls = require(ReplicatedStorage.Voxel:WaitForChild("TouchControls"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local LookSettings = require(ReplicatedStorage2:WaitForChild("Voxel"):WaitForChild("LookSettings"))
local MenuLock = require(ReplicatedStorage.Voxel:WaitForChild("MenuLock"))
local EnterButton = require(ReplicatedStorage.Voxel:WaitForChild("EnterButton"))
local Glyph = require(script.Parent:WaitForChild("GameUI"):WaitForChild("Glyph"))
local Tracers = require(ReplicatedStorage.Voxel:WaitForChild("Tracers"))
local ImpactFX = require(ReplicatedStorage.Voxel:WaitForChild("ImpactFX"))
local LooseChunks = require(script.Parent:WaitForChild("VoxelRender"):WaitForChild("LooseChunks"))

local v = VehicleConfig.Heli
local flying = VehicleConfig.FLYING
local step = VehicleConfig.STEP
local gravity = VehicleConfig.GRAVITY
local unit = VehicleConfig.UNIT
local cframe = CFrame.new(0, -100000, 0)

local v2 = {
	rotor = { id = 9113417561, loop = NumberRange.new(4, 14.5), gain = 1 },
	load = { id = 9113417552, loop = NumberRange.new(1.5, 6.5), gain = 0.55 },
	start = { id = 9125390323, at = 0, length = 4.2, gain = 0.8 },
	cabin = { gain = 0.75, lowpass = 450, player = nil }
}

local v3 = {
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

Color3.fromRGB(78, 76, 72)
local color = Color3.fromRGB(30, 28, 26)
local color2 = Color3.fromRGB(150, 140, 122)
local color3 = Color3.fromRGB(86, 82, 76)

local v4 = v.gun
local v5 = v.rockets

local v6 = v.doorGun
local v7 = {
	model = Vehicles:WaitForChild("DoorGun"),
	barrelTurn = 30,
	follow = 14,
	aimSend = 1 / 15,
	flash = Color3.fromRGB(255, 196, 110),
	jolt = 0.03,
	hum = 0.01,
	metal = Color3.fromRGB(52, 54, 58),
	glow = Color3.fromRGB(255, 112, 40),
	neonAt = 0.75,
	bloomEvery = 0.1,
	scopeFov = 40,
	scopeTime = 0.16
}

local color4 = Color3.fromRGB(24, 25, 28)
local color5 = Color3.fromRGB(242, 238, 228)
local color6 = Color3.fromRGB(255, 198, 32)
local color7 = Color3.fromRGB(214, 72, 52)
local rbxassetfontsfamiliesOswaldjson = Font.new("rbxasset://fonts/families/Oswald.json", Enum.FontWeight.Bold)

local helicopters = Instance.new("Folder")
helicopters.Name = "Helicopters"
helicopters.Parent = workspace

local random2 = Random.new()

do
	local function wrap(p: number) -- 4 equivalent calls inferred from this helper
		return (p + 3.141592653589793) % 6.283185307179586 - 3.141592653589793
	end
end

do
	local function yawOf(vector3: Vector3) -- 3 equivalent calls inferred from this helper
		return (math.atan2(-vector3.X, -vector3.Z))
	end
end

do
	local function ease(p: number, p2: number) -- 2 equivalent calls inferred from this helper
		return 1 - math.exp(-p * p2)
	end
end

local list = {}

do
	local AirDefense = require(ReplicatedStorage:WaitForChild("Vehicles"):WaitForChild("AirDefense"))
	AirDefense.list = list
end

local v8 = { "VoxelLoose", "VoxelChips", "VoxelFalling", "BotRigs", "VoxelBombs", "HeliPreview" }
local function refreshParams(p)
	local excludeInstances = { p.model }

	for _, childName in v8 do
		local child = workspace:FindFirstChild(childName)

		if child then
			table.insert(excludeInstances, child)
		end
	end

	for _, v9 in Players:GetPlayers() do
		if v9.Character then
			table.insert(excludeInstances, v9.Character)
		end
	end

	if workspace.CurrentCamera then
		table.insert(excludeInstances, workspace.CurrentCamera)
	end

	p.params.ExcludeInstances = excludeInstances
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Terrain }
raycastParams.IgnoreWater = false

do
	local function gainAt(vector3: Vector3) -- 2 equivalent calls inferred from this helper
		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			return math.clamp(1 - (currentCamera.CFrame.Position - vector3).Magnitude / 700, 0, 1) ^ 1.3
		end

		return 0
	end
end

do
	local function oneShot(p: number, p2: number, p3: number, vector3: Vector3, p4: number, number: number?, p5: number?) -- 2 equivalent calls inferred from this helper
		if not p5 then
			p5 = gainAt(vector3) -- inferred equivalent call
		end

		local v9 = p5 * p4

		if v9 < 0.01 then
			return
		end

		VoxelSound.oneShotAt(p, p2, p3, vector3, v9, number)
	end
end

local v9 = { v2.start.id }
local v10 = { other = {} }

local v11 = {
	"S" .. 1,
	"S" .. 2,
	"S" .. 3,
	"S" .. 4,
	"S" .. 5,
	"S" .. 6,
	"S" .. 7,
	"S" .. 8
}

for _, v12 in v3 do
	for _, v13 in v12 do
		table.insert(v9, v13[1])
	end
end

VoxelSound.addSamples(v9)

do
	local function hitSound(p: string, vector3: Vector3, p2: number) -- 6 equivalent calls inferred from this helper
		local v12 = v3[p]
		local v13 = v12[random2:NextInteger(1, #v12)]
		local v14 = v13[1]
		local v15 = v13[2]
		local v16 = v13[3]
		local number, v17 = random2:NextNumber(0.88, 1)
		oneShot(v14, v15, v16, vector3, p2, number, v17) -- inferred equivalent call
	end
end

local function crashSound(vector3: Vector3, p: number, flag: boolean?) -- 1 equivalent call inferred from this helper
	if flag then
		hitSound("scrape", vector3, 1) -- inferred equivalent call
		hitSound("heavy", vector3, 0.6) -- inferred equivalent call
	elseif p < 36 then
		hitSound("heavy", vector3, math.clamp(p / 60 + 0.5, 0.5, 1)) -- inferred equivalent call
	else
		hitSound("crash", vector3, 1) -- inferred equivalent call
		hitSound("heavy", vector3, 0.8) -- inferred equivalent call
	end

	if p > 22 then
		BattleFX.billow(vector3, color2, math.clamp(p / 40, 0.4, 1.4), true)
	end
end

local function loopVoice(state, p: string)
	local v12 = (state.def.sfx or v2)[p]
	local positional = AudioGraph.positional("Heli" .. p, state.holder, false, true)
	local player = positional.player
	player.Asset = "rbxassetid://" .. v12.id
	player.Looping = true
	player.LoopRegion = v12.loop

	player.TimePosition = random2:NextNumber(v12.loop.Min, v12.loop.Max - 0.5)
	player.Volume = 0
	player:Play()
	return positional
end

@native local function updateSound(state, p: number)
	if state.def.jet then
		local JetPilot = require(script.JetPilot)
		JetPilot.sound(state, p)
	else
		local v12 = gainAt(state.cf.Position) -- inferred equivalent call

		if v12 <= 0 or state.spin < 0.005 then
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
				state.voices = {
					rotor = loopVoice(state, "rotor"),
					load = loopVoice(state, "load")
				}
			end

			local spin = state.spin
			local v13 = math.clamp(state.vel.Y / 20, 0, 1)
			local v14 = math.clamp(Vector3.new(state.vel.X, 0, state.vel.Z).Magnitude / v.topSpeed, 0, 1)
			local v15

			if state.sim then
				v15 = not state.sim.ground
			else
				v15 = state.vel.Magnitude > 2
			end

			local v16 = math.clamp((v15 and 1 or 0) * 0.25 + v13 * 0.45 + v14 * 0.4, 0, 1)
			state.work += (v16 - state.work) * (1 - math.exp(p * -3))
			local rotor = state.voices.rotor
			local load = state.voices.load
			local sfx = state.def.sfx or v2
			tune(rotor, sfx.rotor.gain * spin ^ 1.4 * v12 * (state.def.quiet or 1), 0.55 + 0.45 * spin)
			tune(load, sfx.load.gain * spin ^ 2 * state.work * v12 * (state.def.quiet or 1), 0.8 + 0.2 * spin)
		end
	end
end

local function effects(state, p: number, vector3: Vector3)
	local position = state.cf.Position
	local v12 = attr(state.folder, "Health") -- inferred equivalent call

	local v13 = math.min(p - state.fxLast, 0.1)
	state.fxLast = p
	state.damage.update(
		state.cf,
		Vector3.new(0, 7.2, 4.5),
		typeof(v12) ~= "number" and 1 or v12,
		state.wrecked,
		v13,
		vector3,
		state.culled == true
	)

	if state.wrecked and not state.tailOff and state.rig and p - state.wreckedAt >= v.tailOffAt then
		state.tailOff = true
		local cells, v14 = state.def.cellsOf("tailRotor")
		local frame = state.rig.frameOf("tailRotor")
		state.rig.hide("tailRotor")
		local v15 = state.cf.RightVector * (random2:NextNumber() < 0.5 and -1 or 1) * random2:NextNumber(10, 18) + Vector3.new(0, 1, 0) * random2:NextNumber(4, 10)
		LooseChunks.spawnAt(
			cells,
			frame,
			v14,
			state.vel + v15,
			Vector3.new(random2:NextNumber(-20, 20), random2:NextNumber(-4, 4), random2:NextNumber(-4, 4)),
			false
		)
		BattleFX.billow(frame.Position, color, 1.4, false)
	end

	if (position - vector3).Magnitude > 500 then
		return
	end

	if state.wrecked then
		if not state.asleep and state.vel.Magnitude > 3 then
			if p - state.fxAt > (Quality.mobile and 0.16 or 0.08) then
				state.fxAt = p
				BattleFX.billow(state.cf:PointToWorldSpace(Vector3.new(0, 7.2, 4.5)), color, 3, false)
			end
		elseif not state.smoked then
			state.smoked = true
			local v14 = math.max(VehicleConfig.RESPAWN_DELAY - (p - state.wreckedAt), 2)
			local pointToWorldSpace = state.cf:PointToWorldSpace(Vector3.new(0, 5, -1))
			BattleFX.column(pointToWorldSpace, color, 3, v14, 1.6, 4)
			BattleFX.flash(pointToWorldSpace, 45, 2.5, 6)
		end
	end

	if state.spin > 0.7 and not state.wrecked and p - state.washAt > 0.7 then
		state.washAt = p
		local raycastResult = workspace:Raycast(position + Vector3.new(0, 2, 0), Vector3.new(0, -34, 0), raycastParams)

		if raycastResult and raycastResult.Material ~= Enum.Material.Water then
			local v14 = 1 - (position.Y - raycastResult.Position.Y) / 32
			BattleFX.skirt(raycastResult.Position, raycastResult.Normal, color2, math.clamp(v14, 0, 1) * 10 + 12)
		end
	end
end

local v12 = {}

local function burst(data)
	local def = data.def

	debug.profilebegin("HC.burst.pieces")
	local burstGroups = def.burstGroups

	if burstGroups == nil then
		local Materials = require(ReplicatedStorage.Voxel.Materials)
		local tankTrack = Materials.Ids.TankTrack
		assert(tankTrack, "[HeliClient] no TankTrack palette entry for charred pieces")
		local v13 = {}
		burstGroups = {}

		for i = 0, def.sz - 1 do
			for j = 0, def.sy - 1 do
				for k = 0, def.sx - 1 do
					local v14 = buffer.readu8(def.data, (VehicleGrid.key(def, k, j, i)))

					if v14 == 0 then
						continue
					end

					local v15 = k // 12 + 1 + j // 12 * 2 + i // 12 * 4
					local v16 = v13[v15]

					if not v16 then
						v16 = { plain = {}, charred = {} }
						v13[v15] = v16
						table.insert(burstGroups, v16)
					end

					local plain = v16.plain
					local charred = v16.charred
					local count = #plain
					local v17 = count + 1
					local v18 = count + 2
					local v19 = count + 3
					local v20 = count + 4
					plain[v17] = k
					plain[v18] = j
					plain[v19] = i
					plain[v20] = v14
					local v21 = count + 1
					local v22 = count + 2
					local v23 = count + 3
					local v24 = count + 4
					charred[v21] = k
					charred[v22] = j
					charred[v23] = i
					charred[v24] = tankTrack
				end
			end
		end

		def.burstGroups = burstGroups
	end

	local v13 = data.vel * 0.3

	for k, v14 in burstGroups do
		if k % Quality.burstKeep() ~= 0 then
			continue
		end

		local v15

		if random2:NextNumber() < 0.6 then
			v15 = v14.charred
		else
			v15 = v14.plain
		end

		local unit2 = Vector3.new(random2:NextNumber(-1, 1), random2:NextNumber(0.5, 1.2), random2:NextNumber(-1, 1)).Unit
		local vector3 = Vector3.new(random2:NextNumber(-1, 1), random2:NextNumber(-1, 1), random2:NextNumber(-1, 1)) * 6
		LooseChunks.spawnAt(v15, data.cf, def.origin, v13 + unit2 * random2:NextNumber(8, 24), vector3, k % 6 ~= 1)
	end

	local rig = data.rig

	if rig then
		local WorldConfig = require(ReplicatedStorage.Voxel.WorldConfig)
		local VOXEL_SIZE = WorldConfig.VOXEL_SIZE

		local cells, v14 = data.def.cellsOf("mainRotor")

		local v15 = {}
		local v16 = { {}, {}, {}, {} }

		for i = 1, #cells, 4 do
			local v17 = v14.X + (cells[i] + 0.5) * VOXEL_SIZE
			local v18 = v14.Z + (cells[i + 2] + 0.5) * VOXEL_SIZE
			local v19

			if v17 * v17 + v18 * v18 <= 1 then
				v19 = v15
			elseif math.abs(v17) > math.abs(v18) then
				v19 = v16[v17 > 0 and 1 or 2]
			else
				v19 = v16[v18 > 0 and 3 or 4]
			end

			table.move(cells, i, i + 3, #v19 + 1, v19)
		end

		local cframe2 = rig.frameOf("mainRotor")
		local v17 = {
			Vector3.new(1, 0, 0),
			-Vector3.new(1, 0, 0),
			Vector3.new(0, 0, 1),
			-Vector3.new(0, 0, 1)
		}

		for k, v18 in v16 do
			local vectorToWorldSpace = cframe2:VectorToWorldSpace(v17[k])
			local vector3 = Vector3.new(vectorToWorldSpace.X, 0, vectorToWorldSpace.Z)
			local v19 = (not (vector3.Magnitude > 0.001) and Vector3.new(1, 0, 0) or vector3.Unit) * random2:NextNumber(45, 75) + Vector3.new(0, 1, 0) * random2:NextNumber(15, 30)
			local vector3_2 = Vector3.new(
				random2:NextNumber(-2, 2),
				(random2:NextNumber() < 0.5 and -1 or 1) * random2:NextNumber(10, 14),
				random2:NextNumber(-2, 2)
			)
			LooseChunks.spawnAt(v18, cframe2, v14, v13 + v19, vector3_2, k ~= 1)
		end

		LooseChunks.spawnAt(
			v15,
			cframe2,
			v14,
			v13 + Vector3.new(0, 1, 0) * random2:NextNumber(8, 14),
			Vector3.new(random2:NextNumber(-4, 4), random2:NextNumber(-4, 4), random2:NextNumber(-4, 4)),
			true
		)

		if not data.tailOff then
			local cells2, v18 = data.def.cellsOf("tailRotor")
			local frame = rig.frameOf("tailRotor")
			LooseChunks.spawnAt(
				cells2,
				frame,
				v18,
				v13 + data.cf.RightVector * random2:NextNumber(-20, 20) + Vector3.new(0, 1, 0) * random2:NextNumber(10, 20),
				Vector3.new(random2:NextNumber(-16, 16), 0, 0),
				true
			)
		end
	end

	debug.profileend()
	debug.profilebegin("HC.burst.fx")
	local pointToWorldSpace = data.cf:PointToWorldSpace(Vector3.new(0, 4.5, -1))
	BattleFX.flash(pointToWorldSpace + Vector3.new(0, 4, 0), 140, 1.2, 16)
	BattleFX.billow(pointToWorldSpace + Vector3.new(0, 3, 0), color, 10, false)
	BattleFX.billow(pointToWorldSpace, color2, 8, true)
	BattleFX.column(pointToWorldSpace + Vector3.new(0, 2, 0), color, 4, 6, 1.8, 6)
	local raycastResult = workspace:Raycast(
		pointToWorldSpace + Vector3.new(0, 4, 0),
		-Vector3.new(0, 24, 0),
		raycastParams
	)

	if raycastResult then
		BattleFX.skirt(raycastResult.Position, raycastResult.Normal, color2, 34)

		local DamageFX = require(Vehicles:WaitForChild("DamageFX"))

		for _ = 1, Quality.mobile and 1 or 3 do
			local v14 = Vector3.new(random2:NextNumber(-1, 1), 0, random2:NextNumber(-1, 1)) * random2:NextNumber(2, 10)
			local raycastResult2 = workspace:Raycast(
				raycastResult.Position + v14 + Vector3.new(0, 6, 0),
				-Vector3.new(0, 12, 0),
				raycastParams
			)
			local v15

			if raycastResult2 then
				v15 = raycastResult2.Position
			else
				v15 = raycastResult.Position + v14
			end

			table.insert(v12, {
				rig = DamageFX.new(random2:NextNumber(1, 1.6)),
				cf = CFrame.new(v15),
				untilT = os.clock() + random2:NextNumber(6, 10)
			})
		end
	end

	BattleFX.shake(pointToWorldSpace, 2.2, 60, 260)
	BattleFX.kick(pointToWorldSpace, 3, 50)
	local v14 = (pointToWorldSpace - workspace.CurrentCamera.CFrame.Position).Magnitude / unit

	if v14 < 40 then
		BattleFX.grit(1 - v14 / 40, color2)
	end

	hitSound("crash", pointToWorldSpace, 1) -- inferred equivalent call
	debug.profileend()
end

local function newSim(data)
	local eulerAnglesYXZ, yaw, v13 = data.cf:ToEulerAnglesYXZ()
	return {
		pos = data.cf.Position,
		vel = data.vel,
		yaw = yaw,
		pitch = eulerAnglesYXZ,
		roll = v13,
		yawRate = 0,
		spin = data.spin,
		accum = 0,
		cf = data.cf,
		prevCf = data.cf,
		ground = true,
		groundPitch = eulerAnglesYXZ,
		groundRoll = v13,
		asleep = data.asleep,
		still = 0,
		strike = 0,
		lastSupport = 0,
		input = { fwd = 0, side = 0, lift = 0, yaw = nil }
	}
end

local function crash(state, p: number, vector3: Vector3, vector3_2: Vector3, flag: boolean?)
	local v13

	if not state.wrecked and (attr(state.folder, "Health") or 1) <= v.disabledAt then -- inferred equivalent call
		v13 = math.min(v.downCrash, VehicleConfig.CRASH_SOUND)
	else
		v13 = VehicleConfig.CRASH_SOUND
	end

	if p < v13 then
		return
	end

	local now = os.clock()

	if now - state.lastCrash < VehicleConfig.CRASH_COOLDOWN then
		return
	end

	state.lastCrash = now
	crashSound(vector3, p, flag)
	Remotes.VehicleCrash:FireServer(state.id, p, vector3, vector3_2)
end

local function supported(state, sim): boolean
	local rotation = sim.cf.Rotation

	for _, foot in state.def.feet do
		local v13 = sim.pos + rotation:VectorToWorldSpace(foot)

		if workspace:Raycast(v13 + Vector3.new(0, 1, 0), Vector3.new(0, -1.8, 0), state.params) then
			return true
		end
	end

	return false
end

@native local function stepSim(data, sim, step2: number)
	local def = data.def

	if def.jet then
		local JetPilot = require(script.JetPilot)
		JetPilot.step(data, sim, step2, crash)
	else
		local input = sim.input
		local v13 = attr(data.folder, "Health") or 1 -- inferred equivalent call
		local wrecked = data.wrecked
		local v14 = data.running and not wrecked

		local v15 = v14 and v13 <= v.disabledAt

		if v15 then
			sim.spin += (v.disabledSpin - sim.spin) * math.min(1, step2 * 0.5)
		elseif v14 then
			sim.spin = math.min(1, sim.spin + v.spinUp * step2)
		else
			local spin = sim.spin
			local v16

			if wrecked then
				v16 = v.wreckSpinDown
			else
				v16 = v.spinDown
			end

			sim.spin = math.max(0, spin - v16 * step2)
		end

		local v16 = v15 and 1 or sim.spin * sim.spin
		local v17 = input.lift

		if v17 < 0 and v14 and not v15 and sim.vel.Y < -v.cushionSpeed then
			local raycastResult = workspace:Raycast(sim.pos, Vector3.new(0, -v.cushionHeight, 0), data.params)

			if raycastResult then
				local v18 = math.max(v.cushionSpeed, raycastResult.Distance * v.cushionRate)
				local v19 = -sim.vel.Y - v18

				if v19 > 0 then
					v17 = math.min(1, v19 / 8)
				end
			end
		end

		local v18

		if v17 > 0 then
			v18 = v17 * v.climb
		else
			v18 = v17 * v.sink
		end

		local v19 = v16 * (1 + v18) * (1 - v.liftHealth * (1 - v13))

		if wrecked then
			v19 = 0
		elseif v15 then
			local v20 = 1 - math.clamp(v13 / v.disabledAt, 0, 1)
			v19 = math.min(
				v19,
				1 - (v.disabledSink + (v.disabledSinkMax - v.disabledSink) * v20) * unit * v.vertDamp / gravity
			)
		end

		local v20 = sim.pos.Y - (v.ceiling - 40)

		if v20 > 0 and v19 > 1 then
			v19 = 1 + (v19 - 1) * math.clamp(1 - v20 / 40, 0, 1)
		end

		local v21 = not sim.ground or v19 > 1.001

		local cframe2 = CFrame.fromEulerAnglesYXZ(0, sim.yaw, 0)
		local lookVector = cframe2.LookVector
		local rightVector = cframe2.RightVector
		local dot = sim.vel:Dot(lookVector)
		local dot2 = sim.vel:Dot(rightVector)
		local v22, v23

		if wrecked and not sim.ground then
			v22 = v.wreckPitch
			v23 = data.spinDir * v.wreckRoll
		elseif v21 then
			if input.fwd == 0 then
				v22 = math.clamp(dot / v.brakeSpeed, -1, 1) * v.tilt * v.brakeTilt
			else
				v22 = -input.fwd * v.tilt
			end

			local v24

			if input.side == 0 then
				v24 = math.clamp(dot2 / v.brakeSpeed, -1, 1) * v.roll * v.brakeTilt
			else
				v24 = -input.side * v.roll
			end

			v23 = math.clamp(v24 + sim.yawRate * v.bank * math.clamp(math.abs(dot) / 30, 0, 1), -v.roll, v.roll)
		else
			v22 = sim.groundPitch
			v23 = sim.groundRoll
		end

		if wrecked and not sim.ground then
			local v24 = v.wreckPitchRate * step2
			local v25 = v.wreckRollRate * step2
			sim.pitch += math.clamp(v22 - sim.pitch, -v24, v24)
			sim.roll += math.clamp(v23 - sim.roll, -v25, v25)
		else
			local v24 = ease(v.tiltRate, step2) -- inferred equivalent call
			sim.pitch += (v22 - sim.pitch) * v24
			sim.roll += (v23 - sim.roll) * v24
		end

		local v24 = 0

		if wrecked then
			v24 = sim.ground and 0 or data.spinDir * math.max(v.wreckYaw, (math.abs(sim.yawRate)))
		elseif v15 and v21 then
			v24 = data.spinDir * v.disabledYaw
		elseif input.yaw and v21 then
			v24 = math.clamp(wrap(input.yaw - sim.yaw) * 2.5, -v.yawRate, v.yawRate) -- inferred equivalent call
		end

		local v25 = v.yawAccel * step2
		sim.yawRate += math.clamp(v24 - sim.yawRate, -v25, v25)

		if sim.ground and not v21 then
			sim.yawRate = 0
		end

		sim.yaw = wrap(sim.yaw + sim.yawRate * step2) -- inferred equivalent call
		local cframe3 = CFrame.fromEulerAnglesYXZ(sim.pitch, sim.yaw, sim.roll)

		local upVector = cframe3.UpVector
		local vector3

		if wrecked and not sim.ground then
			vector3 = Vector3.new(0, -gravity * v.wreckGravity, 0)
		else
			vector3 = Vector3.new(0, gravity * (v19 - 1) - sim.vel.Y * v.vertDamp * v16, 0)
		end

		if v21 then
			vector3 += Vector3.new(upVector.X, 0, upVector.Z) * (gravity * v19 / math.max(upVector.Y, 0.6))
		end

		local vector3_2 = Vector3.new(sim.vel.X, 0, sim.vel.Z)
		local vector3_3 = vector3 - vector3_2 * (v.drag + v.dragQuad * vector3_2.Magnitude) - Vector3.new(
			0,
			sim.vel.Y * math.abs(sim.vel.Y) * v.dragQuad,
			0
		)
		local vector = sim.vel + vector3_3 * step2

		if sim.ground and not v21 then
			local v26 = math.exp(-v.groundFriction * step2)
			vector = Vector3.new(vector.X * v26, vector.Y, vector.Z * v26)
		end

		local params = data.params
		local v26 = vector * step2

		if v26.Magnitude > 0.0001 then
			for _, sphere in def.spheres do
				local v27 = sim.pos + cframe3:VectorToWorldSpace(sphere.at)
				local spherecast = workspace:Spherecast(v27, sphere.r, v26, params)

				if not spherecast then
					continue
				end

				local normal = spherecast.Normal
				local v28 = -vector:Dot(normal)

				if v28 > 0 then
					vector += normal * v28 * (1 + v.bounce)
					crash(data, v28, spherecast.Position, normal)
				end

				if v26.Magnitude > 1e-6 then
					v26 = v26.Unit * math.max(spherecast.Distance - 0.05, 0)
				else
					v26 = Vector3.new(0, 0, 0)
				end
			end
		end

		sim.pos += v26

		if sim.spin > 0.4 then
			local v27 = sim.pos + cframe3:VectorToWorldSpace(HeliModel.MAIN_HUB)

			for i = 0, 1 do
				sim.strike = sim.strike % 8 + 1
				local v28 = (sim.strike + i * 4) / 8 * 6.283185307179586
				local vectorToWorldSpace = cframe3:VectorToWorldSpace((Vector3.new(math.cos(v28), 0, (math.sin(v28)))))
				local raycastResult = workspace:Raycast(v27, vectorToWorldSpace * HeliModel.MAIN_RADIUS, params)

				if not raycastResult then
					continue
				end

				local v29 = math.max(vector:Dot(vectorToWorldSpace), 0)
				vector -= vectorToWorldSpace * (v29 + 6)
				crash(
					data,
					math.max(v29, v.strikeSpeed * sim.spin),
					v27 + vectorToWorldSpace * math.min(raycastResult.Distance, 12),
					-vectorToWorldSpace,
					true
				)
			end
		end

		local count = 0
		local total = Vector3.new(0, 0, 0)
		local maxValue = -1e999

		for _, foot in def.feet do
			local v27 = sim.pos + cframe3:VectorToWorldSpace(foot)
			local raycastResult = workspace:Raycast(v27 + Vector3.new(0, 3, 0), Vector3.new(0, -3.6, 0), params)

			if not raycastResult then
				continue
			end

			local v28 = raycastResult.Position.Y - v27.Y

			if v28 > -0.15 then
				count += 1
				total += raycastResult.Normal
			end

			maxValue = math.max(maxValue, v28)
		end

		sim.ground = count > 0

		if maxValue > 0 then
			sim.pos += Vector3.new(0, maxValue, 0)
		end

		if sim.ground then
			if vector.Y < 0 then
				local v27 = -vector.Y
				local v28

				if data.wrecked then
					v28 = VehicleConfig.CRASH_SOUND
				elseif v13 <= v.disabledAt then
					v28 = v.downCrash
				else
					v28 = v.landCrash
				end

				if v28 < v27 then
					crash(data, -vector.Y, sim.pos, Vector3.new(0, 1, 0))
				end

				vector = Vector3.new(vector.X, 0, vector.Z)
			end

			local unit2 = total.Unit
			sim.groundPitch = -math.asin((math.clamp(unit2:Dot(lookVector), -1, 1)))
			sim.groundRoll = -math.asin((math.clamp(unit2:Dot(rightVector), -1, 1)))
		else
			sim.groundPitch = 0
			sim.groundRoll = 0
		end

		if sim.pos.Y < v.floor and vector.Y < 0 and not data.wrecked then
			vector = Vector3.new(vector.X, 0, vector.Z)
		end

		sim.vel = vector

		local v27 = sim.ground

		if v27 then
			if sim.spin < 0.01 and vector.Magnitude < 0.3 then
				v27 = not v14
			else
				v27 = false
			end
		end

		sim.still = not v27 and 0 or sim.still + step2

		if sim.still > VehicleConfig.SLEEP_TIME then
			sim.asleep = true
			sim.vel = Vector3.new(0, 0, 0)
		end

		sim.cf = CFrame.new(sim.pos) * cframe3
	end
end

do
	local function packExtra(sim) -- 1 equivalent call inferred from this helper
		local buf = buffer.create(2)
		buffer.writeu8(buf, 0, sim.asleep and 1 or 0)
		buffer.writeu8(buf, 1, (math.clamp(math.floor(sim.spin * 255 + 0.5), 0, 255)))
		return buf
	end
end

do
	local function readExtra(buf: buffer) -- 1 equivalent call inferred from this helper
		if buffer.len(buf) < 2 then
			return false, 0
		end

		return bit32.btest(buffer.readu8(buf, 0), 1), buffer.readu8(buf, 1) / 255
	end
end

@native local function interpolate(state, flag: boolean?)
	local poses = state.poses
	local count = #poses

	if count == 0 then
		return
	end

	local pos = poses[count]

	local v13 = PoseTiming.drawTime(state.timing, pos.t, not pos.asleep and pos.vel.Magnitude > 1)

	if pos.t <= v13 then
		local v14 = pos.asleep and 0 or PoseTiming.lead(v13 - pos.t)
		state.cf = pos.cf + pos.vel * v14
		local vel = pos.vel
		local spin = pos.spin
		local asleep = pos.asleep
		state.vel = vel
		state.spin = spin
		state.asleep = asleep
	else
		local v14 = false

		for i = count - 1, 1, -1 do
			local pos2 = poses[i]

			if pos2.t <= v13 then
				local pos3 = poses[i + 1]
				local v15 = math.max(pos3.t - pos2.t, 0.001)
				local v16 = math.clamp((v13 - pos2.t) / v15, 0, 1)
				local hermite = PoseTiming.hermite(pos2.cf.Position, pos2.vel, pos3.cf.Position, pos3.vel, v15, v16)
				state.cf = CFrame.new(hermite) * pos2.cf.Rotation:Lerp(pos3.cf.Rotation, v16)
				state.vel = pos2.vel:Lerp(pos3.vel, v16)
				state.spin = pos2.spin + (pos3.spin - pos2.spin) * v16
				state.asleep = false
				v14 = true
				break
			end
		end

		if not v14 then
			local pos2 = poses[1]
			local cf = pos2.cf
			local vel = pos2.vel
			local spin = pos2.spin
			state.cf = cf
			state.vel = vel
			state.spin = spin
		end
	end

	if not flag then
		state.cf = PoseTiming.apply(state.timing, state.cf)
	end
end

do
	local function addHeli(configuration)
		if not configuration:IsA("Configuration") then
			return
		end

		local id = configuration:GetAttribute("Id")
		local model = configuration:GetAttribute("Model")
		local v13 = typeof(id) == "number" and typeof(model) == "string"
		assert(v13, "[HeliClient] vehicle without Id/Model: " .. configuration.Name)

		if not flying[model] then
			return
		end

		assert(model == "Heli", "[HeliClient] no model for flying vehicle " .. model)
		local skin = configuration:GetAttribute("Skin")
		local def

		if skin == "StealthHeli" then
			local StealthHeliModel = require(Vehicles:WaitForChild("StealthHeliModel"))
			def = StealthHeliModel.def
		elseif skin == "Jet" then
			local JetModel = require(Vehicles:WaitForChild("JetModel"))
			def = JetModel.def
		elseif skin == "Bomber" then
			local BomberModel = require(Vehicles:WaitForChild("BomberModel"))
			def = BomberModel.def
		else
			def = HeliModel
		end

		if skin == "Jet" or skin == "Bomber" then
			v10.jet = v10.jet or {}
			v10.bomber = v10.bomber or {}
			require(script:WaitForChild("JetPilot"))
		end

		local model2 = Instance.new("Model")
		model2.Name = configuration.Name
		model2.Parent = helicopters
		local sound = Instance.new("Part")
		sound.Name = "Sound"
		sound.Anchored = true
		sound.CanCollide = false
		sound.CanQuery = false
		sound.CanTouch = false
		sound.CastShadow = false
		sound.Transparency = 1
		sound.Size = Vector3.new(0.2, 0.2, 0.2)
		sound.CFrame = cframe
		sound.Parent = model2

		local moveParts = {}
		local cframes = {}

		for _, box in def.boxes do
			local box2 = Instance.new("Part")
			box2.Name = "Box"
			box2.Anchored = true
			box2.CanCollide = true
			box2.CanQuery = true
			box2.CanTouch = false
			box2.CastShadow = false
			box2.Transparency = 1
			box2.Size = box.size
			box2.CollisionGroup = "VehicleBody"
			box2.CFrame = cframe
			box2.Parent = model2
			table.insert(moveParts, box2)
			table.insert(cframes, CFrame.new(box.at))
		end

		model2.PrimaryPart = moveParts[1]
		model2:SetAttribute("HullOffset", cframes[1])
		table.insert(moveParts, sound)
		table.insert(cframes, CFrame.new(HeliModel.MAIN_HUB * 0.6))

		local roots = {}
		local guns = {}

		for i = 1, #def.DOOR_GUNS do
			local clone = v7.model:Clone()
			local v14 = {
				parts = {},
				offsets = {},
				kinds = {},
				roots = {},
				yaw = 0,
				pitch = 0,
				spin = 0,
				angle = 0,
				firing = false,
				flashOn = false,
				flash = nil,
				light = nil,
				barrels = {},
				heat = 0,
				glow = 0,
				bloomAt = 0
			}

			for k, v15 in { "Mount", "Gun", "Barrels" } do
				local root = RigidParts.root(clone, v15 .. "Root")
				v14.roots[k] = root

				for _, part in clone[v15]:GetChildren() do
					if not part:IsA("BasePart") then
						continue
					end

					local cframe2 = part.CFrame
					table.insert(v14.parts, part)
					table.insert(v14.offsets, cframe2)
					table.insert(v14.kinds, k)

					if part.Name == "Barrel" then
						table.insert(v14.barrels, part)
					end

					RigidParts.weld(root, part, cframe2)
				end
			end

			local flash = Instance.new("Part")
			flash.Name = "Flash"
			flash.Size = Vector3.new(0.8, 0.8, 1)
			flash.Material = Enum.Material.Neon
			flash.Color = v7.flash
			flash.Anchored = true
			flash.CanCollide = false
			flash.CanQuery = false
			flash.CanTouch = false
			flash.CastShadow = false
			flash.Transparency = 1
			flash.Parent = clone
			local pointLight = Instance.new("PointLight")
			pointLight.Color = v7.flash
			pointLight.Range = 10
			pointLight.Brightness = 0
			pointLight.Enabled = false
			pointLight.Parent = flash
			table.insert(v14.parts, flash)
			table.insert(v14.offsets, CFrame.new(def.DOOR_MUZZLE + Vector3.new(0, 0, -0.35)))
			table.insert(v14.kinds, 3)
			RigidParts.weld(v14.roots[3], flash, v14.offsets[#v14.offsets])
			v14.flash = flash
			v14.light = pointLight

			for _, root in v14.roots do
				table.insert(roots, root)
			end

			clone.Parent = model2
			v14.attrName = "Gun" .. i
			guns[i] = v14
		end

		local cf = configuration:GetAttribute("Pose")

		if typeof(cf) ~= "CFrame" then
			cf = CFrame.identity
		end

		local raycastParams2 = RaycastParams.new()
		raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams2.IgnoreWater = true
		local v14 = {
			id = id,
			folder = configuration,
			def = def,
			rig = nil,
			model = model2,
			holder = sound,
			moveParts = moveParts,
			offsets = cframes,
			moveFrames = table.create(#moveParts),
			poses = {},
			timing = PoseTiming.new(),
			cf = cf,
			vel = Vector3.new(0, 0, 0),
			spin = 0,
			asleep = true,
			sim = nil,
			params = raycastParams2,
			lastSend = 0,
			sentAsleep = false,
			lastCrash = 0,
			running = configuration:GetAttribute("Running") == true,
			wrecked = configuration:GetAttribute("Wrecked") == true,
			wreckedAt = os.clock(),
			smoked = false,
			fxAt = 0,
			washAt = 0,
			voices = nil,
			silent = false,
			work = 0,
			drawnCf = nil,
			guns = guns,
			gunParts = roots,
			gunFrames = table.create(#roots),
			gunsBusy = true
		}

		local DamageFX = require(Vehicles:WaitForChild("DamageFX"))
		v14.damage = DamageFX.new(1.7)
		v14.fxLast = os.clock()
		v14.spinDir = id % 2 == 0 and 1 or -1
		v14.tailOff = false

		refreshParams(v14)
		list[id] = v14

		task.spawn(function()
			debug.profilebegin("HC.rig")
			local v15

			if v14.def == HeliModel then
				v15 = v10
			elseif v14.def.bomber then
				v15 = v10.bomber
			else
				v15 = if v14.def.jet then v10.jet else v10.other
			end

			local rig = table.remove(v15) or v14.def.build()
			debug.profileend()

			if list[id] ~= v14 then
				rig.model:Destroy()
				return
			end

			v14.rig = rig
			rig.model.Parent = model2

			if v14.wrecked then
				rig.tint(color3)
			end

			v14.drawnCf = nil
		end)

		task.spawn(function()
			local _, cf2, v15 = Remotes.VehicleSnapshot:InvokeServer(id)

			if list[id] == v14 and #v14.poses == 0 and not v14.sim and typeof(cf2) == "CFrame" then
				local vel = typeof(v15) ~= "Vector3" and Vector3.new(0, 0, 0) or v15
				v14.cf = cf2
				v14.vel = vel
				v14.drawnCf = nil
			end
		end)
	end

	local function removeHeli(p: number, p2)
		local v13 = list[p]

		if not v13 then
			return
		end

		list[p] = nil

		if p2 then
			Detail.mark("heli", v13.drawnCf and v13.drawnCf.Position or v13.cf.Position)
			burst(v13)
		end

		debug.profilebegin("HC.remove")
		v13.damage.destroy()

		local rig = v13.rig
		local rigs

		if v13.def == HeliModel then
			rigs = v10
		elseif v13.def.bomber then
			rigs = v10.bomber
		else
			rigs = if v13.def.jet then v10.jet else v10.other
		end

		if rig and #rigs < 3 then
			rig.reset()
			rig.model.Parent = helicopters
			table.insert(rigs, rig)
		end

		v13.model:Destroy()
		debug.profileend()
	end

	for _, child in parent2:GetChildren() do
		task.spawn(addHeli, child)
	end

	parent2.ChildAdded:Connect(addHeli)

	TouchControls.addVehicles(function(callback)
		for _, v13 in list do
			if v13.wrecked then
				continue
			end

			local box = v13.def.boxes[1]
			callback(v13.model, v13.folder, v13.cf, box.at, box.size)
		end
	end)
	parent2.ChildRemoved:Connect(function(child)
		local id = child:GetAttribute("Id")

		if typeof(id) == "number" and list[id] and list[id].folder == child then
			task.delay(0.5, function()
				if list[id] and list[id].folder == child then
					removeHeli(id, false)
				end
			end)
		end
	end)
	Remotes.VehicleRemoved.OnClientEvent:Connect(function(p: number, p2)
		removeHeli(p, p2)
	end)
end

do
	local PosePack = require(Vehicles:WaitForChild("PosePack"))
	PosePack.listen(
		Remotes.VehiclePoses,
		function(p: number, cf2: CFrame, vel: Vector3, _: Vector3, buf: buffer, p2: number)
			local v13 = list[p]

			if not v13 or v13.sim then
				return
			end

			local poses = v13.poses

			if #poses > 0 and p2 <= poses[#poses].t then
				return
			end

			local asleep, spin = readExtra(buf) -- inferred equivalent call
			PoseTiming.observe(v13.timing, p2, vel)
			local cf

			if #poses > 0 then
				interpolate(v13, true)
				cf = v13.cf
			end

			table.insert(poses, {
				t = p2,
				cf = cf2,
				vel = vel,
				spin = spin,
				asleep = asleep
			})

			while #poses > 24 do
				table.remove(poses, 1)
			end

			if cf then
				interpolate(v13, true)
				PoseTiming.correct(v13.timing, cf, v13.cf)
			end
		end
	)
end

Remotes.VehicleImpulse.OnClientEvent:Connect(function(p: number, vector3: Vector3)
	local v13 = list[p]

	if v13 and v13.sim then
		v13.sim.vel += vector3
		v13.sim.asleep = false
		v13.sim.still = 0
	end
end)

Remotes.VehicleCrash.OnClientEvent:Connect(function(p: number, p2: number, vector3: Vector3)
	if list[p] then
		crashSound(vector3, p2, false) -- inferred equivalent call
	end
end)

local v13 = nil
local v14 = 0
local visible2 = false
local v15 = false
local v16 = 0
local v17 = 0
local v18 = 0.24434609527920614
local lookVector = nil
local v19 = Vector2.zero
local v20 = 0

local v21 = false
local v22 = false
local v23 = false
local heat = 0
local v24 = 0
local v25 = 0
local flag = false
local v26 = 0
local rockets2 = v5.count
local v27 = nil
local v28 = 0
local v29 = 1
local v30 = true

local v31 = {
	gun = 0,
	yaw = 0,
	pitch = 0,
	spin = 0,
	firing = false,
	heat = 0,
	heatAt = 0,
	last = 0,
	locked = false,
	nextAt = 0,
	shots = 0,
	aimSentAt = 0,
	shake = CFrame.identity,
	zoom = 0,
	autoFire = false
}

do
	local function myCharacter() -- 3 equivalent calls inferred from this helper
		local character = localPlayer.Character
		return
			character,
			character and character:FindFirstChildOfClass("Humanoid"),
			character and character:FindFirstChild("HumanoidRootPart")
	end
end

local v32 = nil
local descendants = {}
local flag2 = true
local function markShownDirty()
	flag2 = true
end

local v38 = nil

do
	local function setGlassCleared(p) -- 3 equivalent calls inferred from this helper
		if p == v38 then
			return
		end

		if v38 then
			v38.clearGlass(false)
		end

		v38 = p

		if p then
			p.clearGlass(true)
		end
	end
end

local function setCharacterShown(flag3: boolean)
	local character = localPlayer.Character

	if not character then
		return
	end

	if character ~= v32 then
		v32 = character
		flag2 = true
		character.DescendantAdded:Connect(markShownDirty)
		character.DescendantRemoving:Connect(markShownDirty)
	end

	if flag2 then
		flag2 = false
		table.clear(descendants)

		for _, descendant in character:GetDescendants() do
			if descendant:IsA("BasePart") or descendant:IsA("Decal") then
				table.insert(descendants, descendant)
			end
		end
	end

	local localTransparencyModifier = flag3 and 0 or 1

	for _, v40 in descendants do
		if v40.LocalTransparencyModifier ~= localTransparencyModifier then
			v40.LocalTransparencyModifier = localTransparencyModifier
		end
	end
end

local function sinkAction(_: string, _, _)
	return Enum.ContextActionResult.Sink
end

local function startRiding(riding, p: number)
	v13 = riding
	v14 = p
	localPlayer:SetAttribute("InVehicle", "air")
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

	local tuning = riding.def.tuning or VehicleConfig.Heli
	local gun = tuning.gun
	local rockets = tuning.rockets
	v = tuning
	v4 = gun
	v5 = rockets
	visible2 = riding.def.seats[p].drive

	local LoadoutAir = require(ReplicatedStorage.Vehicles.LoadoutAir)
	v4, v5, v6 = LoadoutAir.board(localPlayer, tuning, visible2 == true)

	local AirDefense = require(ReplicatedStorage.Vehicles.AirDefense)
	local piloting = visible2
	AirDefense.riding = riding
	AirDefense.piloting = piloting

	if riding.def.jet then
		local JetPilot = require(script.JetPilot)
		JetPilot.board()
	end

	v31.gun = riding.def.seats[p].gun or 0

	if visible2 or v31.gun > 0 then
		v31.yaw = 0
		v31.pitch = 0
		v31.spin = 0
		v31.firing = false
		v31.nextAt = 0
		v31.zoom = 0
		v23 = false

		if humanoid then
			humanoid:UnequipTools()
		end

		ContextActionService:BindActionAtPriority(
			"HeliKeys",
			sinkAction,
			false,
			Enum.ContextActionPriority.High.Value,
			Enum.KeyCode.Space,
			Enum.KeyCode.LeftShift,
			Enum.KeyCode.LeftControl,
			Enum.KeyCode.RightControl,
			Enum.KeyCode.ButtonA,
			Enum.KeyCode.F,
			Enum.KeyCode.One,
			Enum.KeyCode.Two,
			Enum.KeyCode.Three,
			Enum.KeyCode.ButtonR1,
			Enum.KeyCode.ButtonL1,
			Enum.KeyCode.ButtonB
		)
		v17 = yawOf(riding.cf.LookVector) -- inferred equivalent call
		v18 = 0.24434609527920614
		v27 = nil
		v26 = 0
		v28 = 0
		v15 = visible2 and UserInputService.KeyboardEnabled and not Glyph.gamepad()
		lookVector = nil
		workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
		v20 = os.clock() + 9

		if
			visible2
			and not riding.def.jet
			and (not UserInputService.TouchEnabled or Glyph.gamepad() or not TouchControls.active())
			and workspace:Raycast(riding.cf.Position, Vector3.new(0, -14, 0), riding.params)
		then
			local TakeoffPrompt = require(script.TakeoffPrompt)
			TakeoffPrompt.show(function()
				return v13 ~= riding or (not visible2 or riding.wrecked or riding.vel.Y > 3)
			end)
		end
	end

	if v31.gun > 0 then
		TouchControls.setGunAim({
			aim = function()
				return v31.zoom
			end,
			fire = function(autoFire: boolean)
				v31.autoFire = autoFire
			end
		})
	end
end

local function stopRiding()
	local v39 = visible2 or v31.gun > 0
	local v40 = not (v13 == nil) and v13.def.jet
	local v41 = v31.gun > 0
	v13 = nil
	v14 = 0
	visible2 = false

	if localPlayer:GetAttribute("InVehicle") == "air" then
		localPlayer:SetAttribute("InVehicle", nil)
	end

	if v40 then
		local JetPilot = require(script.JetPilot)
		JetPilot.hideHud()
	end

	if v41 then
		VoxelSound.minigunOwn(0, false)
	end

	local AirDefense = require(ReplicatedStorage.Vehicles.AirDefense)
	AirDefense.riding = nil
	AirDefense.piloting = false

	v31.gun = 0
	v31.firing = false
	v31.autoFire = false
	TouchControls.setGunAim(nil)
	v16 = 0
	v21 = false
	v22 = false
	v23 = false
	v31.zoom = 0
	ContextActionService:UnbindAction("HeliKeys")
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

	if v39 then
		local currentCamera = workspace.CurrentCamera
		currentCamera.CameraType = Enum.CameraType.Custom

		if humanoid then
			currentCamera.CameraSubject = humanoid
		end

		setCharacterShown(true)
	end

	if v38 == nil then
		return
	end

	if v38 then
		v38.clearGlass(false)
	end

	v38 = nil
end

do
	local function seatOf(p, userId: number) -- 1 equivalent call inferred from this helper
		for i = 1, #p.def.seats do
			if attr(p.folder, v11[i]) == userId then -- inferred equivalent call
				return i
			end
		end

		return 0
	end
end

local function nearest()
	local _, _, v39 = myCharacter() -- inferred equivalent call

	if not v39 then
		return nil
	end

	local v40 = VehicleConfig.ENTER_RANGE
	local position = v39.Position
	local v41 = nil

	for _, v42 in list do
		if v42.wrecked or (attr(v42.folder, "BayUser") or localPlayer.UserId) ~= localPlayer.UserId then -- inferred equivalent call
			continue
		end

		local origin = v42.def.origin
		local v43 = v42.def.origin + v42.def.size

		local boxReach = v42.boxReach

		if not boxReach then
			boxReach = Vector3.new(
				math.max(math.abs(origin.X), (math.abs(v43.X))),
				math.max(math.abs(origin.Y), (math.abs(v43.Y))),
				(math.max(math.abs(origin.Z), (math.abs(v43.Z))))
			).Magnitude
			v42.boxReach = boxReach
		end

		local magnitude = (v42.cf.Position - position).Magnitude

		if boxReach + v40 <= magnitude then
			continue
		end

		local pointToObjectSpace = v42.cf:PointToObjectSpace(position)
		local magnitude2 = Vector3.new(
			math.max(origin.X - pointToObjectSpace.X, 0, pointToObjectSpace.X - v43.X),
			math.max(origin.Y - pointToObjectSpace.Y, 0, pointToObjectSpace.Y - v43.Y),
			(math.max(origin.Z - pointToObjectSpace.Z, 0, pointToObjectSpace.Z - v43.Z))
		).Magnitude

		if not (magnitude2 < v40) then
			continue
		end

		v41 = v42
		v40 = magnitude2
	end

	return v41
end

local v39 = 0
local v40 = 0

Remotes.VehicleSeat.OnClientEvent:Connect(function(p: number)
	local now = os.clock()
	v39 = p
	v40 = now

	if v13 and v13.id == p then
		stopRiding()
	end
end)

do
	local function wheelNeed(instance)
		local v41 = VehicleConfig.DRIVE_LEVEL[attr(instance, "Model")] -- inferred equivalent call
		local level = localPlayer:GetAttribute("Level")

		if v41 and (typeof(level) ~= "number" and 1 or level) < v41 then
			return v41
		end

		return nil
	end
end

do
	local function otherSeatFree(folder, p: number): boolean -- 3 equivalent calls inferred from this helper
		for i = 2, p do
			if (attr(folder, "S" .. i) or 0) == 0 then -- inferred equivalent call
				return true
			end
		end

		return false
	end
end

local function swapSeat()
	local v41 = v13

	if not v41 then
		return
	end

	if v14 ~= 1 and (attr(v41.folder, v11[1]) or 0) == 0 then -- inferred equivalent call
		local folder = v41.folder
		local v42 = VehicleConfig.DRIVE_LEVEL[attr(folder, "Model")] -- inferred equivalent call
		local level = localPlayer:GetAttribute("Level")

		if v42 then
			if not ((typeof(level) ~= "number" and 1 or level) < v42) then
				v42 = nil
			end
		else
			v42 = nil
		end

		if not v42 then
			Remotes.VehicleSeat:FireServer(v41.id, 1)
			return
		end
	end

	local count = #v41.def.seats

	for i = 1, count - 1 do
		local v42 = (v14 - 1 + i) % count + 1

		if (attr(v41.folder, v11[v42]) or 0) == 0 then -- inferred equivalent call
			if v42 == 1 then
				local folder = v41.folder
				local v43 = VehicleConfig.DRIVE_LEVEL[attr(folder, "Model")] -- inferred equivalent call
				local level = localPlayer:GetAttribute("Level")

				if v43 then
					if not ((typeof(level) ~= "number" and 1 or level) < v43) then
						v43 = nil
					end
				else
					v43 = nil
				end

				if v43 then
					continue
				end
			end

			Remotes.VehicleSeat:FireServer(v41.id, v42)
			break
		end
	end
end

local function toggleSeat()
	if v13 then
		Remotes.VehicleSeat:FireServer(v13.id, 0)
		return
	end

	if localPlayer:GetAttribute("InVehicle") or os.clock() - v40 < 0.6 then
		return
	end

	local v41 = nearest()

	if v41 then
		local folder = v41.folder
		local v42 = VehicleConfig.DRIVE_LEVEL[attr(folder, "Model")] -- inferred equivalent call
		local level = localPlayer:GetAttribute("Level")

		if v42 then
			if not ((typeof(level) ~= "number" and 1 or level) < v42) then
				v42 = nil
			end
		else
			v42 = nil
		end

		if v42 and not otherSeatFree(v41.folder, #v41.def.seats) then -- inferred equivalent call
			VoxelSound.designator("bad")
			return
		end

		v39 = 0
		Remotes.VehicleSeat:FireServer(v41.id, -1)
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or MenuLock.held and input.UserInputType == Enum.UserInputType.Gamepad1 then
		return
	end

	if input.KeyCode == Enum.KeyCode.E or input.KeyCode == Enum.KeyCode.ButtonY then
		if
			not MenuLock.open
			and (v13 or nearest())
			and (input.KeyCode ~= Enum.KeyCode.E or Players.LocalPlayer:GetAttribute("ReviveFocus") ~= true)
		then
			toggleSeat()
		end
	elseif (input.KeyCode == Enum.KeyCode.V or input.KeyCode == Enum.KeyCode.ButtonR3) and visible2 then
		v15 = not v15
	elseif (input.KeyCode == Enum.KeyCode.X or input.KeyCode == Enum.KeyCode.DPadUp) and v13 then
		swapSeat()
	end
end)

do
	local inputChangedConnection = nil
	local function hookStick()
		if UserInputService.GamepadEnabled and not inputChangedConnection then
			inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
				if input.KeyCode == Enum.KeyCode.Thumbstick2 then
					local position = input.Position
					local v41

					if MenuLock.held then
						v41 = Vector2.zero
					else
						v41 = Vector2.new(
							not (math.abs(position.X) > 0.15) and 0 or position.X,
							not (math.abs(position.Y) > 0.15) and 0 or position.Y
						)
					end

					v19 = v41
				end
			end)
		elseif not UserInputService.GamepadEnabled and inputChangedConnection then
			inputChangedConnection:Disconnect()
			inputChangedConnection = nil
		end
	end
	hookStick()
	UserInputService:GetPropertyChangedSignal("GamepadEnabled"):Connect(hookStick)
end

MenuLock.onChange(function(flag3: boolean)
	if flag3 then
		v19 = Vector2.zero
	end
end)

local function key(...): number
	for _, v41 in { ... } do
		if UserInputService:IsKeyDown(v41) then
			return 1
		end
	end

	return 0
end

local v41 = {
	[Enum.KeyCode.Space] = 1,
	[Enum.KeyCode.LeftControl] = -1,
	[Enum.KeyCode.RightControl] = -1
}

local v42 = {}
UserInputService.InputBegan:Connect(function(input)
	if v41[input.KeyCode] then
		v42[input.KeyCode] = os.clock()
	end
end)
UserInputService.InputEnded:Connect(function(input)
	v42[input.KeyCode] = nil
end)
UserInputService.WindowFocusReleased:Connect(function()
	table.clear(v42)
end)
local function liftKeys()
	local v43 = -1
	local v44 = 0

	for k, v45 in v42 do
		if UserInputService:IsKeyDown(k) then
			if v43 < v45 then
				v44 = v41[k]
				v43 = v45
			end
		else
			v42[k] = nil
		end
	end

	return v44
end

local function readInput()
	local v43, v44, v45

	if UserInputService:GetFocusedTextBox() ~= nil then
		v43 = 0
		v44 = 0
		v45 = 0
	else
		v45 = key(Enum.KeyCode.W, Enum.KeyCode.Up) - key(Enum.KeyCode.S, Enum.KeyCode.Down)
		v44 = key(Enum.KeyCode.D, Enum.KeyCode.Right) - key(Enum.KeyCode.A, Enum.KeyCode.Left)
		v43 = liftKeys()
	end

	if UserInputService.GamepadEnabled and not MenuLock.held then
		for _, v46 in UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1) do
			if v46.KeyCode == Enum.KeyCode.ButtonR2 then
				v43 += v46.Position.Z
			elseif v46.KeyCode == Enum.KeyCode.ButtonL2 then
				v43 -= v46.Position.Z
			elseif v46.KeyCode == Enum.KeyCode.Thumbstick1 then
				local position = v46.Position

				if math.abs(position.X) > 0.15 then
					v44 += position.X
				end

				if math.abs(position.Y) > 0.15 then
					v45 += position.Y
				end
			end
		end
	end

	if UserInputService.TouchEnabled then
		if v45 == 0 and v44 == 0 and v13 and v13.def.jet then
			local JetPilot = require(script.JetPilot)
			v44, v45 = JetPilot.touchStick()
		elseif v45 == 0 and v44 == 0 then
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if character then
				character:FindFirstChild("HumanoidRootPart")
			end

			local moveDirection = humanoid and humanoid.MoveDirection or Vector3.new(0, 0, 0)

			if moveDirection.Magnitude > 0.1 then
				local vectorToObjectSpace = workspace.CurrentCamera.CFrame:VectorToObjectSpace(moveDirection)
				v44 = vectorToObjectSpace.X
				v45 = -vectorToObjectSpace.Z
			end
		end

		v43 += v16
	end

	return math.clamp(v45, -1, 1), math.clamp(v44, -1, 1), (math.clamp(v43, -1, 1))
end

do
	local function freeLook(): boolean -- 2 equivalent calls inferred from this helper
		return UserInputService:GetFocusedTextBox() == nil and key(Enum.KeyCode.LeftAlt) == 1
	end
end

local heliHud = Instance.new("ScreenGui")
heliHud.Name = "HeliHud"
heliHud.ResetOnSpawn = false
heliHud.IgnoreGuiInset = true
heliHud.DisplayOrder = 7
heliHud.Parent = localPlayer:WaitForChild("PlayerGui")

local function plate(heliHud2, size: UDim2, position: UDim2, anchorPoint: Vector2)
	local frame = Instance.new("Frame")
	frame.Size = size
	frame.Position = position
	frame.AnchorPoint = anchorPoint
	frame.BackgroundColor3 = color4
	frame.BackgroundTransparency = 0.12
	frame.BorderSizePixel = 0
	frame.Parent = heliHud2
	local tab = Instance.new("Frame")
	tab.Name = "Tab"
	tab.Size = UDim2.new(0, 22, 0, 4)
	tab.BackgroundColor3 = color6
	tab.BorderSizePixel = 0
	tab.Parent = frame
	return frame
end

local function label(parent, text: string, textSize: number, position: UDim2, anchorPoint: Vector2, textXAlignment) -- 1 equivalent call inferred from this helper
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.FontFace = rbxassetfontsfamiliesOswaldjson
	textLabel.TextColor3 = color5
	textLabel.TextSize = textSize
	textLabel.Text = text
	textLabel.AutomaticSize = Enum.AutomaticSize.XY
	textLabel.Position = position
	textLabel.AnchorPoint = anchorPoint
	textLabel.TextXAlignment = textXAlignment
	textLabel.Parent = parent
	return textLabel
end

local parent = plate(heliHud, UDim2.fromOffset(236, 64), UDim2.new(0.5, 0, 1, -18), Vector2.new(0.5, 1))
parent.Visible = false
local v44 = label(parent, "0", 34, UDim2.fromOffset(14, 30), Vector2.new(0, 0.5), Enum.TextXAlignment.Left)
label(parent, "KM/H", 13, UDim2.fromOffset(72, 38), Vector2.new(0, 0.5), Enum.TextXAlignment.Left)
local v45 = label(parent, "0", 26, UDim2.new(1, -34, 0, 30), Vector2.new(1, 0.5), Enum.TextXAlignment.Right)
label(parent, "M", 13, UDim2.new(1, -14, 0, 36), Vector2.new(1, 0.5), Enum.TextXAlignment.Right)
parent2 = Instance.new("Frame")
parent2.Size = UDim2.new(1, -28, 0, 5)
parent2.Position = UDim2.new(0, 14, 1, -10)
parent2.BackgroundColor3 = Color3.fromRGB(60, 60, 62)
parent2.BorderSizePixel = 0
parent2.Parent = parent
local frame = Instance.new("Frame")
frame.Size = UDim2.fromScale(1, 1)
frame.BackgroundColor3 = color5
frame.BorderSizePixel = 0
frame.Parent = parent2

local v46 = label(heliHud, "", 16, UDim2.new(0.5, 0, 1, -90), Vector2.new(0.5, 1), Enum.TextXAlignment.Center)
v46.Visible = false

local parent3 = label(heliHud, "", 15, UDim2.new(0.5, 0, 1, -114), Vector2.new(0.5, 1), Enum.TextXAlignment.Center)
parent3.TextTransparency = 0.1
parent3.Visible = false
parent2 = Instance.new("UIStroke")
parent2.Transparency = 0.5
parent2.Parent = parent3

local v48 = (function()
	local color8 = Color3.fromRGB(150, 146, 136)
	local function cap(frame2, text: string, layoutOrder: number, flag3: boolean)
		local frame3 = Instance.new("Frame")
		frame3.LayoutOrder = layoutOrder
		frame3.Size = UDim2.fromOffset(math.max(22, #text * 8 + 12), 22)
		frame3.BackgroundColor3 = color5
		frame3.BorderSizePixel = 0
		frame3.Parent = frame2
		local uiCorner = Instance.new("UICorner")
		local cornerRadius

		if flag3 then
			cornerRadius = UDim.new(1, 0)
		else
			cornerRadius = UDim.new(0, 4)
		end

		uiCorner.CornerRadius = cornerRadius
		uiCorner.Parent = frame3

		if not flag3 then
			local frame4 = Instance.new("Frame")
			frame4.Size = UDim2.new(1, -4, 0, 3)
			frame4.Position = UDim2.new(0, 2, 1, -3)
			frame4.BackgroundColor3 = color8
			frame4.BorderSizePixel = 0
			frame4.Parent = frame3
		end

		local textLabel = Instance.new("TextLabel")
		textLabel.BackgroundTransparency = 1
		textLabel.Size = UDim2.new(1, 0, 1, -2)
		textLabel.FontFace = rbxassetfontsfamiliesOswaldjson
		textLabel.TextSize = 13
		textLabel.TextColor3 = color4
		textLabel.Text = text
		textLabel.Parent = frame3
	end
	local function build(items, flag3: boolean)
		local canvasGroup = Instance.new("CanvasGroup")
		canvasGroup.AutomaticSize = Enum.AutomaticSize.XY
		canvasGroup.Size = UDim2.fromOffset(0, 0)
		canvasGroup.Position = UDim2.new(0, 18, 0.535, 12)
		canvasGroup.AnchorPoint = Vector2.new(0, 0)
		canvasGroup.BackgroundColor3 = color4
		canvasGroup.BackgroundTransparency = 0.25
		canvasGroup.BorderSizePixel = 0
		canvasGroup.Visible = false
		canvasGroup.Parent = heliHud

		local frame2 = Instance.new("Frame")
		frame2.Size = UDim2.new(0, 22, 0, 4)
		frame2.Position = UDim2.fromOffset(-10, 0)
		frame2.BackgroundColor3 = color6
		frame2.BorderSizePixel = 0
		frame2.Parent = canvasGroup
		local uiPadding = Instance.new("UIPadding")
		local udim = UDim.new(0, 0)
		local udim2 = UDim.new(0, 10)
		uiPadding.PaddingTop = udim
		uiPadding.PaddingBottom = udim2
		local udim3 = UDim.new(0, 10)
		local udim4 = UDim.new(0, 12)
		uiPadding.PaddingLeft = udim3
		uiPadding.PaddingRight = udim4
		uiPadding.Parent = canvasGroup
		local uiListLayout = Instance.new("UIListLayout")
		uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uiListLayout.Padding = UDim.new(0, 6)
		uiListLayout.Parent = canvasGroup

		for k, item in items do
			local frame3 = Instance.new("Frame")
			frame3.LayoutOrder = k
			frame3.BackgroundTransparency = 1
			frame3.AutomaticSize = Enum.AutomaticSize.XY
			frame3.Size = UDim2.fromOffset(0, 22)
			frame3.Parent = canvasGroup
			local uiListLayout2 = Instance.new("UIListLayout")
			uiListLayout2.FillDirection = Enum.FillDirection.Horizontal
			uiListLayout2.VerticalAlignment = Enum.VerticalAlignment.Center
			uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
			uiListLayout2.Padding = UDim.new(0, 4)
			uiListLayout2.Parent = frame3
			local v49 = item[1]

			for k2, v50 in v49 do
				if typeof(v50) == "EnumItem" then
					local padCap = Glyph.padCap(frame3, v50, 22)
					padCap.LayoutOrder = k2
				else
					cap(frame3, v50, k2, flag3)
				end
			end

			local textLabel = Instance.new("TextLabel")
			textLabel.LayoutOrder = #v49 + 1
			textLabel.BackgroundTransparency = 1
			textLabel.AutomaticSize = Enum.AutomaticSize.X
			textLabel.Size = UDim2.fromOffset(0, 22)
			textLabel.FontFace = rbxassetfontsfamiliesOswaldjson
			textLabel.TextSize = 14
			textLabel.TextColor3 = color5
			textLabel.Text = item[2]
			textLabel.Parent = frame3
			local uiPadding2 = Instance.new("UIPadding")
			uiPadding2.PaddingLeft = UDim.new(0, 6)
			uiPadding2.Parent = textLabel
		end

		return canvasGroup
	end

	return {
		pilotKeys = build({
			{
				{ "SPACE" },
				"CLIMB"
			},
			{
				{ "CTRL" },
				"DESCEND"
			},
			{
				{ "E" },
				"GET OUT"
			}
		}, false),
		pilotPad = build({
			{
				{ "RT" },
				"CLIMB"
			},
			{
				{ "LT" },
				"DESCEND"
			},
			{
				{ "Y" },
				"GET OUT"
			}
		}, true),
		jetKeys = build({
			{
				{ "SPACE" },
				"AFTERBURNER"
			},
			{
				{ "CTRL" },
				"BRAKE"
			},
			{
				{ "E" },
				"GET OUT"
			}
		}, false),
		jetPad = build({
			{
				{ Enum.KeyCode.ButtonR2 },
				"AFTERBURNER"
			},
			{
				{ Enum.KeyCode.ButtonL2 },
				"BRAKE"
			},
			{
				{ Enum.KeyCode.ButtonY },
				"GET OUT"
			}
		}, true),
		gunnerKeys = build({
			{
				{ "X" },
				"SWAP"
			},
			{
				{ "E" },
				"GET OUT"
			}
		}, false),
		gunnerPad = build({
			{
				{ "UP" },
				"SWAP"
			},
			{
				{ "Y" },
				"GET OUT"
			}
		}, true)
	}
end)()

local v49 = (function()
	local viewKeys = Instance.new("Frame")
	viewKeys.Name = "ViewKeys"
	viewKeys.BackgroundTransparency = 1
	viewKeys.AutomaticSize = Enum.AutomaticSize.XY
	viewKeys.Size = UDim2.fromOffset(0, 0)
	viewKeys.Position = UDim2.new(0.5, 130, 1, -18)
	viewKeys.AnchorPoint = Vector2.new(0, 1)
	viewKeys.Visible = false
	viewKeys.Parent = heliHud
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0, 6)
	uiListLayout.Parent = viewKeys
	local function key2(layoutOrder: number, p: string?, p2, text: string)
		local frame2 = Instance.new("Frame")
		frame2.Name = "Key" .. layoutOrder
		frame2.LayoutOrder = layoutOrder
		frame2.AutomaticSize = Enum.AutomaticSize.XY
		frame2.Size = UDim2.fromOffset(0, 0)
		frame2.BackgroundColor3 = color4
		frame2.BackgroundTransparency = 0.12
		frame2.BorderSizePixel = 0
		frame2.Parent = viewKeys
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0, 4)
		uiCorner.Parent = frame2
		local uiPadding = Instance.new("UIPadding")
		local udim = UDim.new(0, 5)
		local udim2 = UDim.new(0, 5)
		uiPadding.PaddingTop = udim
		uiPadding.PaddingBottom = udim2
		local udim3 = UDim.new(0, 6)
		local udim4 = UDim.new(0, 12)
		uiPadding.PaddingLeft = udim3
		uiPadding.PaddingRight = udim4
		uiPadding.Parent = frame2
		local uiListLayout2 = Instance.new("UIListLayout")
		uiListLayout2.FillDirection = Enum.FillDirection.Horizontal
		uiListLayout2.VerticalAlignment = Enum.VerticalAlignment.Center
		uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
		uiListLayout2.Padding = UDim.new(0, 8)
		uiListLayout2.Parent = frame2
		local cap = Glyph.cap(frame2, p, p2, 24)
		cap.LayoutOrder = 1
		local textLabel = label(frame2, text, 18, UDim2.new(), Vector2.zero, Enum.TextXAlignment.Left) -- inferred equivalent call
		textLabel.LayoutOrder = 2
		return frame2
	end

	key2(1, "V", Enum.KeyCode.ButtonR3, "VIEW")

	return {
		bar = viewKeys,
		look = key2(2, "ALT", nil, "FREE LOOK"),
		sent = nil,
		idle = false,
		touchIdle = false
	}
end)()

do
	local function showLegend(p: string?, p2: number) -- 5 equivalent calls inferred from this helper
		for k, v50 in v48 do
			v50.Visible = k == p

			if k == p then
				v50.GroupTransparency = p2 < v20 and 0 or 0.45
			end
		end
	end
end

local parent4 = plate(heliHud, UDim2.fromOffset(124, 64), UDim2.new(0.5, 126, 1, -18), Vector2.new(0, 1))
parent4.Visible = false
label(parent4, "GUN", 13, UDim2.fromOffset(12, 20), Vector2.new(0, 0.5), Enum.TextXAlignment.Left)
parent2 = Instance.new("Frame")
parent2.Size = UDim2.new(1, -56, 0, 6)
parent2.Position = UDim2.new(0, 44, 0, 20)
parent2.AnchorPoint = Vector2.new(0, 0.5)
parent2.BackgroundColor3 = Color3.fromRGB(60, 60, 62)
parent2.BorderSizePixel = 0
parent2.Parent = parent4
local frame2 = Instance.new("Frame")
frame2.Size = UDim2.fromScale(0, 1)
frame2.BackgroundColor3 = color5
frame2.BorderSizePixel = 0
frame2.Parent = parent2
local v51 = label(parent4, "RKT", 13, UDim2.fromOffset(12, 44), Vector2.new(0, 0.5), Enum.TextXAlignment.Left)
local v52 = label(parent4, "", 20, UDim2.new(1, -12, 0, 44), Vector2.new(1, 0.5), Enum.TextXAlignment.Right)

local frame3 = Instance.new("Frame")
frame3.Size = UDim2.fromOffset(34, 34)
frame3.Position = UDim2.fromScale(0.5, 0.5)
frame3.AnchorPoint = Vector2.new(0.5, 0.5)
frame3.BackgroundTransparency = 1
frame3.Visible = false
frame3.Parent = heliHud
local v53 = {}

for _, v54 in {
	{ 0.5, 0, 3, 9 },
	{ 0.5, 1, 3, 9 },
	{ 0, 0.5, 9, 3 },
	{ 1, 0.5, 9, 3 },
	{ 0.5, 0.5, 4, 4 }
} do
	local frame4 = Instance.new("Frame")
	frame4.Size = UDim2.fromOffset(v54[3], v54[4])
	frame4.Position = UDim2.fromScale(v54[1], v54[2])
	frame4.AnchorPoint = Vector2.new(v54[1], v54[2])
	frame4.BackgroundColor3 = color5
	frame4.BorderSizePixel = 0
	frame4.Parent = frame3
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = color4
	uiStroke.Transparency = 0.4
	uiStroke.Parent = frame4
	table.insert(v53, frame4)
end

local parent5 = plate(heliHud, UDim2.fromOffset(0, 34), UDim2.new(0.5, 0, 1, -120), Vector2.new(0.5, 1))
parent5.AutomaticSize = Enum.AutomaticSize.X
parent5.Visible = false
parent2 = Instance.new("UIPadding")
parent2.PaddingLeft = UDim.new(0, 12)
parent2.PaddingRight = UDim.new(0, 12)
parent2.Parent = parent5
local v55 = label(parent5, "", 18, UDim2.new(0, 0, 0.5, 0), Vector2.new(0, 0.5), Enum.TextXAlignment.Left)

local cap = Glyph.cap(parent5, nil, nil, 24)
cap.AnchorPoint = Vector2.new(0, 0.5)
cap.Position = UDim2.fromScale(0, 0.5)
local function promptKey(flag3: boolean): string -- 1 equivalent call inferred from this helper
	local v56 = flag3 and Glyph.gamepad()
	local setCap = Glyph.setCap
	local v58

	if v56 then
		v58 = Enum.KeyCode.ButtonY
	end

	setCap(cap, nil, v58)
	v55.Position = UDim2.new(0, v56 and 32 or 0, 0.5, 0)
	return if flag3 and not v56 then "E   " else ""
end

local v56 = {}

if UserInputService.TouchEnabled then
	local function button(p: string, p2: string, udim: UDim2)
		local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
		local v57 = require(ReplicatedStorage3:WaitForChild("Voxel"):WaitForChild("SeatButton")).make(
			heliHud,
			p,
			p2,
			udim,
			p == "Seat"
		)
		v56[p] = v57
		return v57
	end

	button("Seat", "GET OUT", UDim2.new(1, -16, 0.5, -60)).Activated:Connect(toggleSeat)
	button("View", "VIEW", UDim2.new(1, -114, 0.5, -60)).Activated:Connect(function()
		v15 = not v15
	end)

	button("Swap", "SWAP", UDim2.new(1, -212, 0.5, -60)).Activated:Connect(swapSeat)
end

local v57 = false
local v58 = false

do
	local function setLift() -- 2 equivalent calls inferred from this helper
		v16 = (v57 and 1 or 0) - (v58 and 1 or 0)
	end
end

local v59 = {
	{
		name = "Climb",
		slot = "jump",
		glyph = "up",
		hold = function(flag3: boolean)
			v57 = flag3
			setLift() -- inferred equivalent call
		end
	},
	{
		name = "Sink",
		slot = "slide",
		glyph = "down",
		hold = function(flag3: boolean)
			v58 = flag3
			setLift() -- inferred equivalent call
		end
	},
	{
		name = "Gun",
		slot = "fire",
		glyph = "FIRE",
		look = true,
		hold = function(flag3: boolean)
			v21 = flag3
		end
	},
	{
		name = "Rockets",
		slot = "aim",
		glyph = "rocket",
		hold = function(flag3: boolean)
			v22 = flag3
		end
	}
}

v49.jetDiscs = {
	{ name = "Climb", slot = "jump", glyph = "faster", hold = v59[1].hold },
	{ name = "Sink", slot = "slide", glyph = "slower", hold = v59[2].hold },
	{ name = "Gun", slot = "fire", glyph = "FIRE", hold = v59[3].hold },
	{ name = "Rockets", slot = "aim", glyph = "rocket", hold = v59[4].hold }
}

v49.bomberDiscs = {
	v49.jetDiscs[1],
	v49.jetDiscs[2],
	{ name = "Rockets", slot = "fire", glyph = "rocket", hold = v59[4].hold }
}

local v60 = {
	{
		name = "Gun",
		slot = "fire",
		glyph = "FIRE",
		look = true,
		hold = function(flag3: boolean)
			v21 = flag3
		end
	},
	{
		name = "Scope",
		slot = "aim",
		glyph = "aim",
		tap = function()
			v23 = not v23
		end,
		lit = function()
			return v23
		end
	}
}

local CockpitHud = require(script:WaitForChild("CockpitHud"))
local v61 = CockpitHud.new(heliHud, {
	white = color5,
	hazard = color6,
	danger = color7,
	panel = color4,
	font = rbxassetfontsfamiliesOswaldjson
})

do
	local function kmh(magnitude: number) -- 3 equivalent calls inferred from this helper
		return magnitude / unit * 3.6
	end
end

local v62 = 0
local alt = 0
local v64 = false

local v65 = { word = "", what = "HELICOPTER", locked = false, press = toggleSeat }
local function updateHud(now: number)
	local v66

	if v13 == nil then
		v66 = false
	else
		v66 = visible2 or v31.gun > 0
	end

	local playerHud = v66 ~= v64 and localPlayer.PlayerGui:FindFirstChild("PlayerHud")

	if playerHud then
		v64 = v66
		playerHud.Enabled = not v66
	end

	local gamepad = Glyph.gamepad()
	local touchEnabled = UserInputService.TouchEnabled

	local visible3 = touchEnabled and not gamepad and TouchControls.active()
	local v68 = v13
	Glyph.claim("heliRide", v68 ~= nil)

	if v49.cockpitUp and not (v68 and visible2 and v15) then
		v49.cockpitUp = false
		v61.hide()
		local HeliCockpit = require(script.HeliCockpit)
		HeliCockpit.hide()
	end

	local v69 = nil

	if v68 and visible2 then
		v49.idle = false
		parent5.Visible = false
		parent.Visible = not v15
		local magnitude = Vector3.new(v68.vel.X, 0, v68.vel.Z).Magnitude
		v44.Text = tostring((math.floor(kmh(magnitude) + 0.5))) -- inferred equivalent call

		if now - v62 > 0.1 then
			v62 = now
			local raycastResult = workspace:Raycast(v68.cf.Position, Vector3.new(0, -2000, 0), v68.params)
			alt = not raycastResult and 999 or (v68.cf.Position.Y - raycastResult.Position.Y) / unit
		end

		v45.Text = tostring((math.floor(alt + 0.5)))
		local health = attr(v68.folder, "Health") or 1 -- inferred equivalent call
		frame.Size = UDim2.fromScale(math.clamp(health, 0, 1), 1)
		local backgroundColor

		if health < 0.35 then
			backgroundColor = color7
		else
			backgroundColor = if health < 0.7 then color6 else color5
		end

		frame.BackgroundColor3 = backgroundColor

		if v68.wrecked then
			v46.Text = "GOING DOWN"
			v46.TextColor3 = color7
			v46.Visible = true
		elseif v68.spin < 0.97 and v68.running and not v68.def.jet then
			v46.Text = "ROTOR " .. math.floor(v68.spin * 100 + 0.5) .. "%"
			v46.TextColor3 = color6
			v46.Visible = true
		elseif health < 0.35 then
			v46.Text = "HULL FAILING"
			v46.TextColor3 = color7
			v46.Visible = true
		else
			v46.Visible = false
		end

		if touchEnabled and not gamepad and TouchControls.active() then
			showLegend(nil, now) -- inferred equivalent call

			if v68.def.jet then
				local JetPilot = require(script.JetPilot)
				local touchHint = JetPilot.touchHint(v68, now)
				parent3.Visible = touchHint ~= nil
				parent3.Text = touchHint or ""
			else
				parent3.Visible = now < v20
				parent3.Text = "STICK  MOVE     ARROWS  CLIMB / SINK     DRAG  TURN\nBIG BUTTON  GUN     ROCKET  ROCKETS"
			end

			v49.bar.Visible = false
		else
			parent3.Visible = false
			showLegend( -- inferred equivalent call
				v68.def.jet and (gamepad and "jetPad" or "jetKeys") or gamepad and "pilotPad" or "pilotKeys",
				now
			)
			v49.bar.Visible = true
			v49.look.Visible = not gamepad
		end

		if v15 and not v68.def.jet then
			v49.cockpitUp = true
			v61.update({
				cam = workspace.CurrentCamera,
				body = v68.cf,
				vel = v68.vel,
				nose = v68.cf:PointToWorldSpace(v68.def.GUN_MUZZLE) + v68.cf.LookVector * 500,
				speed = kmh(magnitude), -- inferred equivalent call
				alt = alt,
				climb = v68.vel.Y / unit,
				health = health,
				heat = heat,
				locked = flag,
				rockets = rockets2,
				wrecked = v68.wrecked
			})

			local HeliCockpit = require(script.HeliCockpit)
			HeliCockpit.update(v68, kmh(magnitude), alt, health, heat, flag, rockets2, now) -- inferred equivalent call
		end

		parent4.Visible = not v15 and visible3
		parent4.Size = UDim2.fromOffset(124, 64)
		local udim = UDim2.new(0.5, 126, 1, -18)
		local vector2 = Vector2.new(0, 1)
		parent4.Position = udim
		parent4.AnchorPoint = vector2
		v51.Visible = true
		v52.Visible = true
		frame2.Size = UDim2.fromScale(math.clamp(heat, 0, 1), 1)
		local backgroundColor2

		if flag then
			backgroundColor2 = color7
		else
			backgroundColor2 = if heat > 0.7 then color6 else color5
		end

		frame2.BackgroundColor3 = backgroundColor2
		v51.Text = v68.def.jet and "BOMB" or "RKT"
		v52.Text = not (rockets2 > 0) and "RELOAD" or tostring(rockets2)
		local textColor = if rockets2 > 0 then color5 else color6
		v52.TextColor3 = textColor
		local visible = not v68.wrecked

		if visible then
			visible = not (v68.def.jet and v15)
		end

		frame3.Visible = visible
		local backgroundColor3 = if flag then color7 else color5

		for _, v76 in v53 do
			v76.BackgroundColor3 = backgroundColor3
			v76.BackgroundTransparency = v30 and 0 or 0.6
		end
	elseif v68 and v31.gun > 0 then
		v49.idle = false

		parent5.Visible = false
		parent.Visible = false
		v49.bar.Visible = false

		if v68.wrecked then
			v46.Text = "GOING DOWN"
			v46.TextColor3 = color7
			v46.Visible = true
		elseif v31.locked then
			v46.Text = "GUN HOT"
			v46.TextColor3 = color7
			v46.Visible = true
		else
			v46.Visible = false
		end

		if touchEnabled and not gamepad and TouchControls.active() then
			showLegend(nil, now) -- inferred equivalent call
			parent3.Visible = now < v20
			parent3.Text = "DRAG  AIM     BIG BUTTON  HOLD TO FIRE     SIGHT BUTTON  SCOPE     SWAP  MOVE SEAT"
		else
			parent3.Visible = false
			showLegend(gamepad and "gunnerPad" or "gunnerKeys", now) -- inferred equivalent call
		end

		parent4.Visible = visible3
		parent4.Size = UDim2.fromOffset(124, 38)
		local udim = UDim2.new(0.5, 0, 1, -18)
		local vector2 = Vector2.new(0.5, 1)
		parent4.Position = udim
		parent4.AnchorPoint = vector2
		v51.Visible = false
		v52.Visible = false
		frame2.Size = UDim2.fromScale(math.clamp(v31.heat, 0, 1), 1)
		local backgroundColor

		if v31.locked then
			backgroundColor = color7
		elseif v31.heat > 0.7 then
			backgroundColor = color6
		else
			backgroundColor = color5
		end

		frame2.BackgroundColor3 = backgroundColor

		frame3.Visible = not v68.wrecked and v31.zoom < 0.35
		local backgroundColor2

		if v31.locked then
			backgroundColor2 = color7
		else
			backgroundColor2 = color5
		end

		for _, v72 in v53 do
			v72.BackgroundColor3 = backgroundColor2
			v72.BackgroundTransparency = 0
		end
	else
		if not v49.idle then
			v49.idle = true
			parent.Visible = false
			v46.Visible = false
			parent3.Visible = false
			showLegend(nil, now) -- inferred equivalent call
			v49.bar.Visible = false
			parent4.Visible = false
			frame3.Visible = false
		end

		if not (v68 or localPlayer:GetAttribute("InVehicle")) then
			v69 = nearest()
		end

		Glyph.claim("heli", v69 ~= nil)

		if v69 and not touchEnabled then
			local v70 = attr(v69.folder, "S1") == 0 -- inferred equivalent call
			local folder = v69.folder
			local v71 = VehicleConfig.DRIVE_LEVEL[attr(folder, "Model")] -- inferred equivalent call
			local level = localPlayer:GetAttribute("Level")

			if v71 then
				if not ((typeof(level) ~= "number" and 1 or level) < v71) then
					v71 = nil
				end
			else
				v71 = nil
			end

			if v71 and v70 then
				local v72 = otherSeatFree(v69.folder, #v69.def.seats) -- inferred equivalent call
				local v73

				if v72 then
					v73 = promptKey(true) .. "RIDE   ·   "
				else
					Glyph.setCap(cap, nil, nil)
					v55.Position = UDim2.new(0, 0, 0.5, 0)
					v73 = ""
				end

				v55.Text = v73 .. "FLYING REQUIRES LEVEL " .. v71
				v55.TextColor3 = color6
			else
				v55.Text = promptKey(true) .. (v70 and "FLY" or "GET IN") -- inferred equivalent call
				v55.TextColor3 = color5
			end

			parent5.Visible = true
		else
			parent5.Visible = false
		end
	end

	local sent

	if v68 and visible2 then
		sent = v68.def.bomber and "BomberPilot" or v68.def.jet and "JetPilot" or "HeliPilot"
	else
		sent = v68 and v31.gun > 0 and "HeliDoor" or nil
	end

	if sent ~= v49.sent then
		v49.sent = sent
		localPlayer:SetAttribute("VehicleWeapon", sent)
	end

	if sent then
		local v71 = if visible2 then heat else v31.heat
		local v72 = math.floor(math.clamp(v71, 0, 1) * 50 + 0.5) / 50

		if localPlayer:GetAttribute("VehicleHeat") ~= v72 then
			localPlayer:SetAttribute("VehicleHeat", v72)
		end

		local v73 = if visible2 then flag else v31.locked

		if localPlayer:GetAttribute("VehicleHot") ~= v73 then
			localPlayer:SetAttribute("VehicleHot", v73)
		end

		local v74

		if visible2 then
			v74 = rockets2
		end

		if localPlayer:GetAttribute("VehicleAmmo") ~= v74 then
			localPlayer:SetAttribute("VehicleAmmo", v74)
		end
	end

	if touchEnabled then
		local seat = v56.Seat

		if v68 or not v49.touchIdle then
			v49.touchIdle = v68 == nil
			seat.Visible = v68 ~= nil
			seat.Text = "GET OUT"
			v56.View.Visible = visible2
		end

		local swap = v56.Swap
		local v71

		if v68 == nil then
			v71 = false
		else
			v71 = not visible2
		end

		local v72

		if v71 then
			if v14 == 1 then
				v72 = false
			else
				v72 = false

				if (attr(v68.folder, v11[1]) or 0) == 0 then -- inferred equivalent call
					local folder = v68.folder
					local v73 = VehicleConfig.DRIVE_LEVEL[attr(folder, "Model")] -- inferred equivalent call
					local level = localPlayer:GetAttribute("Level")

					if v73 then
						if not ((typeof(level) ~= "number" and 1 or level) < v73) then
							v73 = nil
						end
					else
						v73 = nil
					end

					v72 = not v73
				end
			end
		else
			v72 = v71
		end

		if v49.swapWord == nil then
			local visible = swap.Visible
			local text = swap.Text
			v49.swapShown = visible
			v49.swapWord = text
		end

		if v49.swapShown ~= v71 then
			v49.swapShown = v71
			swap.Visible = v71
		end

		local v73 = v72 and "FLY" or "SWAP"

		if v49.swapWord ~= v73 then
			v49.swapWord = v73
			swap.Text = v73
			local textColor = if v72 then color6 else color5
			swap.TextColor3 = textColor
		end

		if v69 then
			local folder = v69.folder
			local v74 = VehicleConfig.DRIVE_LEVEL[attr(folder, "Model")] -- inferred equivalent call
			local level = localPlayer:GetAttribute("Level")

			if v74 then
				if not ((typeof(level) ~= "number" and 1 or level) < v74) then
					v74 = nil
				end
			else
				v74 = nil
			end

			local v75 = attr(v69.folder, "S1") == 0 -- inferred equivalent call
			local locked

			if v74 == nil then
				locked = false
			else
				locked = not otherSeatFree(v69.folder, #v69.def.seats) -- inferred equivalent call
			end

			v65.word = not locked and (v75 and not v74 and "FLY" or "GET IN") or "LEVEL " .. v74
			v65.locked = locked
			EnterButton.set("heli", v65)
		else
			EnterButton.set("heli", nil)
		end

		local touchDiscs

		if v68 and visible2 then
			if v68.def.bomber then
				touchDiscs = v49.bomberDiscs
			else
				touchDiscs = if v68.def.jet then v49.jetDiscs else v59
			end
		elseif v68 and v31.gun > 0 then
			touchDiscs = v60
		end

		if touchDiscs ~= v49.touchDiscs then
			v49.touchDiscs = touchDiscs
			TouchControls.setVehicle(touchDiscs)
		end
	end
end

local function checkSeat()
	local v66 = nil
	local v67 = 0

	for _, v69 in list do
		local v70 = seatOf(v69, localPlayer.UserId) -- inferred equivalent call

		if v69.id == v39 and v70 == 0 then
			v39 = 0
		end

		if v70 > 0 and (v69.id ~= v39 or not (os.clock() - v40 < 3)) then
			v67 = v70
			v66 = v69
			break
		end
	end

	if v66 ~= v13 or v67 ~= v14 then
		if v13 then
			stopRiding()
		end

		if v66 then
			startRiding(v66, v67)
		end
	end
end

local v66 = 0
@native local function fly(state, p: number, p2: number, flag3: boolean)
	local v67 = attr(state.folder, "Owner") == localPlayer.UserId -- inferred equivalent call

	if v67 and not state.sim then
		state.sim = newSim(state)
		state.sentAsleep = false
		refreshParams(state)
	elseif not v67 and state.sim then
		local sim = state.sim
		state.sim = nil
		state.poses = {
			{
				t = workspace:GetServerTimeNow(),
				cf = sim.cf,
				vel = sim.vel,
				spin = sim.spin,
				asleep = sim.asleep
			}
		}
	end

	local sim = state.sim

	if not sim then
		interpolate(state)
		return
	end

	if flag3 then
		refreshParams(state)
	end

	local v68 = v13 == state and visible2
	local input = sim.input

	if v68 then
		if state.def.jet then
			local JetPilot = require(script.JetPilot)
			local shape, side, lift = JetPilot.shape(readInput())
			input.fwd = shape
			input.side = side
			input.lift = lift
		else
			local fwd, side, lift = readInput()
			input.fwd = fwd
			input.side = side
			input.lift = lift
		end

		local v69 = freeLook() -- inferred equivalent call
		local yaw

		if not v69 then
			yaw = v17
		end

		input.yaw = yaw
	else
		input.fwd = 0
		input.side = 0
		input.lift = 0
		input.yaw = nil
	end

	if sim.asleep then
		local v69 = state.running or state.wrecked or v68

		if not v69 and p2 - sim.lastSupport > 0.5 then
			sim.lastSupport = p2
			v69 = not supported(state, sim)
		end

		if v69 then
			sim.asleep = false
			sim.still = 0
		end
	end

	if sim.asleep then
		state.cf = sim.cf
	else
		sim.accum += VehicleConfig.simTime(p)

		debug.profilebegin("HC.sim")

		while step <= sim.accum do
			sim.prevCf = sim.cf
			stepSim(state, sim, step)
			sim.accum -= step
		end

		debug.profileend()
		local cf

		if sim.asleep then
			cf = sim.cf
		else
			cf = sim.prevCf:Lerp(sim.cf, (math.clamp(sim.accum / step, 0, 1)))
		end

		state.cf = cf
	end

	local vel = sim.vel
	local spin = sim.spin
	local asleep = sim.asleep
	state.vel = vel
	state.spin = spin
	state.asleep = asleep

	if
		(sim.asleep or not (p2 - state.lastSend >= 1 / VehicleConfig.POSE_RATE))
		and (not sim.asleep or state.sentAsleep)
	then
		if not sim.asleep then
			state.sentAsleep = false
		end
	else
		state.lastSend = p2
		state.sentAsleep = sim.asleep
		Remotes.VehicleDrive:FireServer(
			state.id,
			sim.cf,
			sim.vel,
			Vector3.new(0, sim.yawRate, 0),
			packExtra(sim), -- inferred equivalent call
			workspace:GetServerTimeNow()
		)
	end
end

@native local function updateGuns(state, p: number)
	local v67 = ease(v7.follow, p) -- inferred equivalent call
	local gunsBusy = false

	for k, gun in state.guns do
		if v13 == state and v31.gun == k then
			local yaw = v31.yaw
			local pitch = v31.pitch
			local spin = v31.spin
			local firing = v31.firing
			gun.yaw = yaw
			gun.pitch = pitch
			gun.spin = spin
			gun.firing = firing
		else
			local v69 = (attr(state.folder, v11[state.def.DOOR_GUNS[k].seat]) or 0) ~= 0 -- inferred equivalent call
			local v70 = attr(state.folder, gun.attrName) -- inferred equivalent call
			local v71, v72, firing, v74

			if v69 and typeof(v70) == "Vector3" then
				v71 = v70.X
				v72 = v70.Y
				firing = v70.Z >= 2

				if firing then
					v74 = v70.Z - 2
				else
					v74 = v70.Z
				end
			else
				v71 = 0
				v72 = 0
				v74 = 0
				firing = false
			end

			gun.yaw += (v71 - gun.yaw) * v67
			gun.pitch += (v72 - gun.pitch) * v67
			local spin

			if gun.spin < v74 then
				spin = math.min(v74, gun.spin + p / v6.spinUp)
			else
				spin = math.max(v74, gun.spin - p / v6.spinDown)
			end

			gun.spin = spin
			gun.firing = firing
		end

		gun.angle = (gun.angle + gun.spin * v7.barrelTurn * p) % 6.283185307179586

		if v13 == state and v31.gun == k then
			gun.heat = v31.heat
		elseif gun.firing then
			gun.heat = math.min(1, gun.heat + v6.heat * v6.rate * p)
		else
			gun.heat = math.max(0, gun.heat - v6.cool * p)
		end

		local glow = math.clamp((gun.heat - 0.3) / 0.7, 0, 1)

		if math.abs(glow - gun.glow) > 0.03 or glow == 0 and gun.glow ~= 0 then
			gun.glow = glow
			local lerped = v7.metal:Lerp(v7.glow, glow)
			local material

			if v7.neonAt <= glow then
				material = Enum.Material.Neon
			else
				material = Enum.Material.Metal
			end

			for _, barrel in gun.barrels do
				barrel.Color = lerped
				barrel.Material = material
			end
		end

		if gun.firing and not state.wrecked then
			local now = os.clock()
			local v70 = now - gun.bloomAt >= v7.bloomEvery

			if v70 then
				gun.bloomAt = now
			end

			local v71

			if v70 then
				v71 = random2:NextNumber(1.4, 1.7)
			else
				v71 = random2:NextNumber(0.8, 1.05)
			end

			gun.flash.Transparency = v70 and 0.05 or random2:NextNumber(0.2, 0.4)
			gun.flash.Size = Vector3.new(0.8 * v71, 0.8 * v71, random2:NextNumber(0.7, 1.2) * v71)

			local enabled = not (Detail.low or Quality.potato)

			if gun.light.Enabled ~= enabled then
				gun.light.Enabled = enabled
			end

			if enabled then
				local v72 = v70 and 5 or 3

				if gun.lightB ~= v72 then
					gun.lightB = v72
					gun.light.Brightness = v72
				end
			end

			gun.flashOn = true
		elseif gun.flashOn then
			gun.flash.Transparency = 1
			gun.lightB = 0
			gun.light.Brightness = 0
			gun.light.Enabled = false
			gun.flashOn = false
		end

		gunsBusy = gunsBusy or gun.spin > 0.001 or math.abs(gun.yaw) + math.abs(gun.pitch) > 0.001
	end

	state.gunsBusy = gunsBusy
end

@native local function poseGuns(data)
	local def = data.def
	local gunFrames = data.gunFrames
	local total = 0

	for k, gun in data.guns do
		local v67 = def.DOOR_GUNS[k]
		local v68 = data.cf * CFrame.new(v67.pivot) * CFrame.fromEulerAnglesYXZ(0, v67.out + gun.yaw, 0)
		local v69 = v68 * CFrame.fromEulerAnglesYXZ(gun.pitch, 0, 0)
		local v70 = v69 * CFrame.fromEulerAnglesYXZ(0, 0, gun.angle)
		local v71 = total + 1
		local v72 = total + 2
		local v73 = total + 3
		gunFrames[v71] = v68
		gunFrames[v72] = v69
		gunFrames[v73] = v70
		total += 3
	end

	workspace:BulkMoveTo(data.gunParts, gunFrames, Enum.BulkMoveMode.FireCFrameChanged)
end

local WorldConfig = require(ReplicatedStorage.Voxel.WorldConfig)
local v67 = WorldConfig.VOXEL_SIZE ^ 3
local v68 = math.max(HeliModel.size.Magnitude * 0.5, HeliModel.MAIN_RADIUS) + 20
local Lighting = game:GetService("Lighting")

local v69 = {
	eye = Vector3.new(0, 0, 0),
	look = Vector3.new(0, 0, 1),
	cone = 3.141592653589793,
	sun = Vector3.new(0, 1, 0),
	stale = true,
	seatHold = nil
}

do
	local function updateView()
		v69.stale = false
		local currentCamera = workspace.CurrentCamera
		local cframe2 = currentCamera.CFrame
		local viewportSize = currentCamera.ViewportSize
		local v70 = viewportSize.X / math.max(viewportSize.Y, 1)
		local v71 = math.rad((math.max(currentCamera.FieldOfView, 80))) * 0.5
		local position = cframe2.Position
		local lookVector2 = cframe2.LookVector
		v69.eye = position
		v69.look = lookVector2
		v69.cone = math.atan(math.tan(v71) * math.sqrt(1 + v70 * v70)) + 0.5235987755982988
		local sun = Lighting:GetSunDirection()

		if not (sun.Y > 0) then
			sun = Lighting:GetMoonDirection()
		end

		v69.sun = sun

		v69.shadows = Lighting.GlobalShadows
	end
	local function offView(position: Vector3)
		if v69.stale then
			updateView()
		end

		local v70 = v68
		local sun = v69.sun
		local eye = v69.eye
		local look = v69.look
		local cone = v69.cone
		local v71 = not (v69.shadows and sun.Y > 0) and 0 or math.clamp((position.Y - -50) / sun.Y, 0, 1200)
		local v72 = 0

		while true do
			local v73 = position - sun * v72 - eye
			local magnitude = v73.Magnitude

			if magnitude <= v70 then
				return false
			end

			if math.acos((math.clamp(look:Dot(v73) / magnitude, -1, 1))) - math.asin(v70 / magnitude) <= cone then
				return false
			end

			if v71 <= v72 then
				return true
			end

			v72 = math.min(v72 + v70, v71)
		end
	end

	@native local function draw(state, rigAt: number, vector3: Vector3)
		local v70 = state.drawnCf ~= state.cf

		local drawnCf = state.drawnCf

		if
			v70
			and drawnCf
			and v13 ~= state
			and not state.sim
			and (drawnCf.Position - state.cf.Position).Magnitude < 0.001
			and (drawnCf.LookVector - state.cf.LookVector).Magnitude < 0.00001
			and (drawnCf.UpVector - state.cf.UpVector).Magnitude < 0.00001
		then
			state.cf = drawnCf
			v70 = false
		end

		if v70 then
			state.drawnCf = state.cf
			local moveFrames = state.moveFrames

			for k, offset in state.offsets do
				moveFrames[k] = state.cf * offset
			end

			workspace:BulkMoveTo(state.moveParts, moveFrames, Enum.BulkMoveMode.FireCFrameChanged)
		end

		local culled

		if v13 == state or state.rigCf == nil then
			culled = false
		else
			culled = Quality.mobile
				and (state.cf.Position - vector3).Magnitude > 330 + HeliModel.size.Magnitude * 0.5
				and true
				or offView(state.cf.Position)
		end

		if culled ~= (state.culled == true) then
			state.model:SetAttribute("Culled", culled)
		end

		state.culled = culled

		if culled then
			state.gunsStale = true
			return
		end

		local v72 = v13 == state and 0 or (state.cf.Position - vector3).Magnitude
		local rigFar = v72 > 160
		local rig = state.rig

		if rig then
			local shadowBand = Detail.shadowBand(v72, state.shadowBand)

			if shadowBand ~= state.shadowBand or state.shadowVer ~= Detail.shadowVersion then
				local shadowVersion = Detail.shadowVersion
				state.shadowBand = shadowBand
				state.shadowVer = shadowVersion
				rig.shade(shadowBand)

				local v74 = shadowBand == 0 and 0 or Detail.bandCells(shadowBand)

				for _, gun in state.guns do
					for _, part in gun.parts do
						local size = part.Size
						local castShadow

						if part.Transparency == 0 then
							castShadow = v74 == 0 or v74 <= size.X * size.Y * size.Z / v67
						else
							castShadow = false
						end

						if part.CastShadow ~= castShadow then
							part.CastShadow = castShadow
						end
					end
				end
			end

			if state.rigCf ~= state.cf or state.spin >= 0.001 or state.rigFar ~= rigFar then
				state.rigCf = state.cf
				state.rigFar = rigFar
				state.rigAt = rigAt
				rig.pose(state.cf, rigAt, state.spin, nil, rigFar)
			end
		end

		if state.def.jet then
			local JetPilot = require(script.JetPilot)
			JetPilot.draw(state)
		end

		if rigFar then
			if not state.gunsParked then
				state.gunsParked = true
				workspace:BulkMoveTo(
					state.gunParts,
					table.create(#state.gunParts, RigidParts.PARK),
					Enum.BulkMoveMode.FireCFrameChanged
				)
			end
		elseif v70 or state.gunsBusy or state.gunsParked or state.gunsStale then
			state.gunsParked = false
			state.gunsStale = false
			poseGuns(state)
		end
	end

	local function readState(state, wreckedAt: number)
		local running = attr(state.folder, "Running") == true -- inferred equivalent call

		if running and not (state.running or state.wrecked) then
			local start = v2.start
			local currentCamera = workspace.CurrentCamera
			local v71 = math.clamp(
				(220 - (not currentCamera and 1e999 or (currentCamera.CFrame.Position - state.cf.Position).Magnitude)) / 190,
				0,
				1
			)
			oneShot(start.id, start.at, start.length, state.cf.Position, start.gain, nil, v71 * v71) -- inferred equivalent call
		end

		state.running = running

		if attr(state.folder, "Wrecked") == true and not state.wrecked then -- inferred equivalent call
			state.wrecked = true
			state.wreckedAt = wreckedAt

			if state.rig then
				state.rig.tint(color3)
			end
		end
	end

	local raycastParams2 = RaycastParams.new()
	raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams2.IgnoreWater = true
	local raycastParams3 = RaycastParams.new()
	raycastParams3.FilterType = Enum.RaycastFilterType.Exclude
	local v70 = 0

	local function refreshCamParams(p: number)
		if p - v70 <= 0.5 then
			return
		end

		v70 = p
		local excludeInstances = { helicopters }

		for _, v72 in Players:GetPlayers() do
			if v72.Character then
				table.insert(excludeInstances, v72.Character)
			end
		end

		for _, childName in v8 do
			local child = workspace:FindFirstChild(childName)

			if child then
				table.insert(excludeInstances, child)
			end
		end

		raycastParams2.ExcludeInstances = excludeInstances

		local v73 = if v13 then v13.model else helicopters
		local excludeInstances2 = { v73 }

		if localPlayer.Character then
			table.insert(excludeInstances2, localPlayer.Character)
		end

		for _, childName in {
			"VoxelTracers",
			"VoxelLoose",
			"VoxelChips",
			"VoxelFalling",
			"VoxelBombs",
			"HeliPreview"
		} do
			local child = workspace:FindFirstChild(childName)

			if child then
				table.insert(excludeInstances2, child)
			end
		end

		if workspace.CurrentCamera then
			table.insert(excludeInstances2, workspace.CurrentCamera)
		end

		raycastParams3.ExcludeInstances = excludeInstances2
	end
	local v71 = nil
	local v72 = v.chase.distance
	local fieldOfView = nil
	local flag3 = false
	local total = 0

	@native local function camera(p: number)
		local v74 = v13

		if v74 and (visible2 or v31.gun > 0) then
			local currentCamera = workspace.CurrentCamera

			if currentCamera.CameraType ~= Enum.CameraType.Scriptable then
				currentCamera.CameraType = Enum.CameraType.Scriptable
			end

			if not GuiService.MenuIsOpen and UserInputService.MouseEnabled then
				UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
				UserInputService.MouseIconEnabled = false
				flag3 = true
			end

			local v75 = 0
			local v76 = 0

			local v77 = not (v31.gun > 0 and fieldOfView) and 1
				or math.tan(math.rad(currentCamera.FieldOfView) / 2) / math.tan(math.rad(fieldOfView) / 2)
			local v78

			if TouchControls.active() then
				v78 = Vector2.zero
			else
				v78 = UserInputService:GetMouseDelta()
			end

			if v78.Magnitude > 0 then
				v75 -= v78.X * 0.0035 * v77
				v76 += v78.Y * 0.0035 * v77
			end

			if v19.Magnitude > 0 then
				v75 -= v19.X * 3.2 * v77 * LookSettings.look * p
				v76 -= v19.Y * 3.2 * v77 * LookSettings.look * p
			end

			if lookVector and (not v74.def.jet or TouchControls.active()) then
				local vector3 = lookVector
				local lookVector2 = currentCamera.CFrame.LookVector
				local v79 = wrap(yawOf(lookVector2) - yawOf(vector3)) -- inferred equivalent call

				local v80 = math.asin((math.clamp(vector3.Y, -1, 1))) - math.asin((math.clamp(lookVector2.Y, -1, 1)))

				if math.abs(v79) > 0.0001 or math.abs(v80) > 0.0001 then
					v75 += v79
					v76 += v80
				end
			end

			local v79 = v75 * LookSettings.vehicle
			local v80 = v76 * LookSettings.vehicle
			v17 = wrap(v17 + v79) -- inferred equivalent call
			v18 = math.clamp(v18 + v80, -0.6981317007977318, 1.3089969389957472)

			if v31.gun > 0 then
				v31.yaw = math.clamp(v31.yaw + v79, -v6.yaw, v6.yaw)
				v31.pitch = math.clamp(v31.pitch - v80, -v6.pitchDown, v6.pitchUp)
				fieldOfView = fieldOfView or currentCamera.FieldOfView

				local v81 = v31.zoom * v31.zoom * (3 - 2 * v31.zoom)
				currentCamera.FieldOfView = fieldOfView + (v7.scopeFov - fieldOfView) * v81
				local lerped = HeliModel.DOOR_EYE:Lerp(HeliModel.DOOR_SCOPE_EYE, v81)
				local v82 = v74.cf * HeliModel.doorGunFrame(v31.gun, v31.yaw, v31.pitch) * CFrame.new(lerped) * v31.shake
				setCharacterShown(false)
				setGlassCleared(v74.rig) -- inferred equivalent call
				currentCamera.CFrame = v82
				currentCamera.Focus = v82
				lookVector = v82.LookVector
			else
				local magnitude = v74.vel.Magnitude
				fieldOfView = fieldOfView or currentCamera.FieldOfView
				currentCamera.FieldOfView = fieldOfView + math.clamp(magnitude / v.topSpeed, 0, 1) * 12
				local cframe3

				if v74.def.jet then
					local JetPilot = require(script.JetPilot)
					local camera2 = JetPilot.camera
					cframe3 = camera2(v74, p, v79, v80, v15, freeLook()) -- inferred equivalent call
					total = 0
					setCharacterShown(false)
					local v83

					if v15 then
						v83 = v74.rig
					end

					setGlassCleared(v83) -- inferred equivalent call
				elseif v15 then
					local pointToWorldSpace = v74.cf:PointToWorldSpace(v74.def.EYE or Vector3.new(0, 6.1, -5.8))
					local v82 = CFrame.new(pointToWorldSpace) * CFrame.fromEulerAnglesYXZ(
						-(v18 - 0.24434609527920614),
						v17,
						0
					)

					local upVector = v74.cf.UpVector
					local v83 = math.atan2(v82.RightVector:Dot(upVector), (v82.UpVector:Dot(upVector)))
					total += (-v83 * 0.7 - total) * (1 - math.exp(p * -8))
					cframe3 = v82 * CFrame.Angles(0, 0, total)
					setCharacterShown(false)
					setGlassCleared(v74.rig) -- inferred equivalent call
				else
					local cframe2 = CFrame.fromEulerAnglesYXZ(-v18, v17, 0)
					local v82 = v74.cf:PointToWorldSpace(Vector3.new(0, 4.5, 2)) + Vector3.new(0, v.chase.height, 0)
					local v83

					if v71 then
						v83 = v71 + (v82.Y - v71) * (1 - math.exp(p * -5))
					else
						v83 = v82.Y
					end

					v71 = v83
					local vector3 = Vector3.new(v82.X, v83, v82.Z)
					refreshCamParams(os.clock())
					local v84 = -cframe2.LookVector
					local spherecast = workspace:Spherecast(vector3, 1, v84 * v.chase.distance, raycastParams2)
					local v85

					if spherecast then
						v85 = math.max(spherecast.Distance, 2)
					else
						v85 = v.chase.distance
					end

					if v85 < v72 then
						v72 = v85
					else
						v72 += (v85 - v72) * (1 - math.exp(p * -3))
					end

					cframe3 = CFrame.new(vector3 + v84 * v72) * cframe2
					total = 0
					setCharacterShown(true)

					if v38 ~= nil then
						if v38 then
							v38.clearGlass(false)
						end

						v38 = nil
					end
				end

				currentCamera.CFrame = cframe3
				currentCamera.Focus = CFrame.new(v74.cf.Position)
				lookVector = cframe3.LookVector
			end
		else
			if flag3 then
				UserInputService.MouseIconEnabled = true
				flag3 = false
			end

			if fieldOfView then
				workspace.CurrentCamera.FieldOfView = fieldOfView
				fieldOfView = nil
			end

			v71 = nil
		end
	end

	local v74 = nil

	local function spreadDir(vector3: Vector3, spread: number)
		local v75 = math.rad(spread) * math.sqrt((random2:NextNumber()))
		return (CFrame.lookAt(Vector3.new(0, 0, 0), vector3) * CFrame.Angles(
			0,
			0,
			random2:NextNumber() * 6.283185307179586
		) * CFrame.Angles(v75, 0, 0)).LookVector
	end

	local function inCone(vector: Vector3, lookVector2: Vector3, cone: number)
		if math.acos((math.clamp(vector:Dot(lookVector2), -1, 1))) <= cone then
			return vector
		end

		local cross = lookVector2:Cross(vector)

		if cross.Magnitude < 1e-6 then
			return lookVector2
		end

		return CFrame.fromAxisAngle(cross.Unit, cone):VectorToWorldSpace(lookVector2)
	end

	local function triggers()
		if UserInputService:GetFocusedTextBox() ~= nil or GuiService.MenuIsOpen then
			return false, false
		end

		local v75 = v21
		local v76 = v22

		if UserInputService.MouseEnabled then
			v75 = v75 or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
			v76 = v76 or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
		end

		if UserInputService.GamepadEnabled and not MenuLock.held then
			v75 = v75 or UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonR1)
			v76 = v76 or UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonL1)
		end

		return v75, v76
	end

	local function coolGun(gunSpinAt: number) -- 1 equivalent call inferred from this helper
		local v75 = math.max(v24, v25 + v4.coolDelay)

		if v75 < gunSpinAt then
			heat = math.max(0, heat - v4.cool * (gunSpinAt - v75))
		end

		v24 = gunSpinAt

		if flag and heat <= v4.unlock then
			flag = false
		end
	end

	local function shootGun(state, vector3: Vector3, gunSpinAt: number)
		local GUN_MUZZLES = state.def.GUN_MUZZLES
		state.gunSide = state.gunSide == 1 and 2 or 1
		local cf = state.cf
		local v75

		if GUN_MUZZLES then
			v75 = GUN_MUZZLES[state.gunSide]
		else
			v75 = state.def.GUN_MUZZLE
		end

		local pointToWorldSpace = cf:PointToWorldSpace(v75)
		local v76 = vector3 - pointToWorldSpace

		if v76.Magnitude < 1 then
			return
		end

		local vector3_2 = inCone(spreadDir(v76.Unit, v4.spread), state.cf.LookVector, v4.cone)
		local raycastResult = workspace:Raycast(pointToWorldSpace, vector3_2 * 500, raycastParams3)
		local v77

		if raycastResult then
			v77 = raycastResult.Position
		else
			v77 = pointToWorldSpace + vector3_2 * 500
		end

		Remotes.HeliFire:FireServer(state.id, "gun", v77)

		Tracers.fire(pointToWorldSpace, v77, nil, nil, true, nil, true)

		if raycastResult then
			local v78 = raycastResult.Instance == workspace.Terrain and raycastResult.Material ~= Enum.Material.Water
			task.delay(
				Tracers.travelTime(pointToWorldSpace, v77),
				ImpactFX.bullet,
				raycastResult.Position,
				raycastResult.Normal,
				vector3_2,
				v78
			)
		end

		if not (v4.spinUp or state.def.jet) then
			VoxelSound.ownLMG(0.9)
		end

		v25 = gunSpinAt
		heat += v4.heat

		if heat >= 1 then
			flag = true
		end
	end

	local function shootRocket(data, vector3: Vector3)
		local v75 = v29
		v29 = 3 - v29
		local pointToWorldSpace = data.cf:PointToWorldSpace(data.def.PODS[v75])
		local v76 = vector3 - pointToWorldSpace
		local lookVector2 = data.cf.LookVector
		local v77 = if v76.Magnitude > 1 then v76.Unit else lookVector2
		local vector3_2 = inCone(v77, lookVector2, v5.cone)
		local RocketPredict = require(ReplicatedStorage.Voxel:WaitForChild("RocketPredict"))
		RocketPredict.fire(pointToWorldSpace, vector3_2, pointToWorldSpace, true, v5.heavy ~= nil)
		Remotes.HeliFire:FireServer(
			data.id,
			"rocket",
			pointToWorldSpace + vector3_2 * math.max(v76.Magnitude, 60),
			v75,
			pointToWorldSpace
		)
		rockets2 -= 1
	end

	local function weapons(gunSpinAt: number)
		local v75 = v13

		if not (v75 and visible2) then
			return
		end

		if v74 ~= v75 then
			v74 = v75
			v70 = 0
		end

		refreshCamParams(gunSpinAt)
		local v76 = attr(v75.folder, "Rockets") -- inferred equivalent call

		if typeof(v76) ~= "number" then
			v76 = v5.count
		end

		if v76 ~= v27 then
			local v77 = v27
			local v78

			if v77 == nil then
				v78 = v76
			elseif v77 < v76 then
				v78 = math.min(rockets2 + v76 - v77, v5.count)
			else
				v78 = math.min(rockets2, v76)
			end

			rockets2 = v78

			v27 = v76
		end

		if gunSpinAt - v28 > 1 then
			rockets2 = v76
		end

		coolGun(gunSpinAt) -- inferred equivalent call
		local currentCamera = workspace.CurrentCamera
		local viewportSize = currentCamera.ViewportSize
		local v77

		if v75.def.jet then
			local JetPilot = require(script.JetPilot)
			v77 = JetPilot.aimRay() or currentCamera:ViewportPointToRay(viewportSize.X * 0.5, viewportSize.Y * 0.5)
		else
			v77 = currentCamera:ViewportPointToRay(viewportSize.X * 0.5, viewportSize.Y * 0.5)
		end

		local raycastResult = workspace:Raycast(v77.Origin, v77.Direction * 500, raycastParams3)
		local v78

		if raycastResult then
			v78 = raycastResult.Position
		else
			v78 = v77.Origin + v77.Direction * 500
		end

		local v79 = v78 - v75.cf:PointToWorldSpace(v75.def.GUN_MUZZLE)
		v30 = v79.Magnitude < 1 or math.acos((math.clamp(v79.Unit:Dot(v75.cf.LookVector), -1, 1))) <= v4.cone

		if v75.wrecked then
			return
		end

		local flag4, v80 = triggers()

		if v4.spinUp then
			local v81 = flag4 and not flag
			local v82 = (gunSpinAt - (v75.gunSpinAt or gunSpinAt)) / v4.spinUp
			local gunSpin = v75.gunSpin or 0

			if not v81 then
				v82 = -0.5 * v82
			end

			v75.gunSpin = math.clamp(gunSpin + v82, 0, 1)
			v75.gunSpinAt = gunSpinAt
			VoxelSound.minigunOwn(v75.gunSpin, v81 and v75.gunSpin >= 1)
		elseif v75.def.jet and not v75.def.bomber then
			local cannonOn = flag4 and not flag

			if cannonOn or v75.cannonOn then
				VoxelSound.minigunOwn(cannonOn and 1 or 0, cannonOn, true)
			end

			v75.cannonOn = cannonOn
		end

		if flag4 and not v75.def.bomber and not flag and v26 <= gunSpinAt and (not v4.spinUp or v75.gunSpin >= 1) then
			local v81

			if gunSpinAt - v26 > 0.1 then
				v81 = gunSpinAt + 1 / v4.rate
			else
				v81 = v26 + 1 / v4.rate
			end

			v26 = v81
			shootGun(v75, v78, gunSpinAt)
		end

		if v75.def.jet then
			local JetPilot = require(script.JetPilot)
			JetPilot.fire(v75, v80 or flag4 and v75.def.bomber == true, v78, gunSpinAt)
			JetPilot.hud(v75, heliHud, rbxassetfontsfamiliesOswaldjson, gunSpinAt)
		elseif v80 and rockets2 > 0 and v28 <= gunSpinAt then
			v28 = gunSpinAt + v5.spacing
			shootRocket(v75, v78)
		end
	end

	local function gunnerTriggers()
		if UserInputService:GetFocusedTextBox() ~= nil or GuiService.MenuIsOpen then
			return false, false
		end

		local v75 = v21 or v31.autoFire
		local v76

		if UserInputService.MouseEnabled then
			v75 = v75 or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
			v76 = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
		else
			v76 = false
		end

		if UserInputService.GamepadEnabled and not MenuLock.held then
			v75 = v75
				or UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonR2)
				or UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonR1)
			v76 = v76 or UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonL2)
		end

		return v75, v76
	end

	local function doorGunner(p: number, p2: number)
		local v75 = v13

		if v75 and v31.gun ~= 0 then
			if v74 ~= v75 then
				v74 = v75
				v70 = 0
			end

			refreshCamParams(p)
			local v76 = math.max(v31.heatAt, v31.last + v6.coolDelay)

			if v76 < p then
				v31.heat = math.max(0, v31.heat - v6.cool * (p - v76))
			end

			v31.heatAt = p

			if v31.locked and v31.heat <= v6.unlock then
				v31.locked = false
			end

			local v77, v78 = gunnerTriggers()

			if v75.wrecked then
				v78 = false
				v77 = false
			end

			local v79 = p2 / v7.scopeTime
			local zoom

			if (v78 or v23) and not v75.wrecked then
				zoom = math.min(1, v31.zoom + v79)
			else
				zoom = math.max(0, v31.zoom - v79)
			end

			v31.zoom = zoom

			if (v77 or v78) and not v31.locked then
				v31.spin = math.min(1, v31.spin + p2 / v6.spinUp)
			else
				v31.spin = math.max(0, v31.spin - p2 / v6.spinDown)
			end

			v31.firing = v77 and not v31.locked and v31.spin >= v6.fireAt

			if not (v6.belt or v6.heavy) then
				VoxelSound.minigunOwn(v31.spin, v31.firing)
			end

			if v31.firing then
				local currentCamera = workspace.CurrentCamera
				local viewportSize = currentCamera.ViewportSize
				local viewportPointToRay = currentCamera:ViewportPointToRay(viewportSize.X * 0.5, viewportSize.Y * 0.5)
				local raycastResult = workspace:Raycast(
					viewportPointToRay.Origin,
					viewportPointToRay.Direction * 500,
					raycastParams3
				)
				local v81

				if raycastResult then
					v81 = raycastResult.Position
				else
					v81 = viewportPointToRay.Origin + viewportPointToRay.Direction * 500
				end

				local cframe2 = v75.cf * HeliModel.doorGunFrame(v31.gun, v31.yaw, v31.pitch)
				local pointToWorldSpace = cframe2:PointToWorldSpace(HeliModel.DOOR_MUZZLE)
				local v82 = v81 - pointToWorldSpace
				local v83

				if v82.Magnitude > 1 then
					v83 = v82.Unit
				else
					v83 = cframe2.LookVector
				end

				if p - v31.nextAt > 0.1 then
					v31.nextAt = p
				end

				local v84 = {}

				while v31.nextAt <= p and #v84 < 8 and not v31.locked do
					v31.nextAt += 1 / v6.rate
					local lookVector2 = spreadDir(v83, v6.spread)
					v31.shots += 1

					if v31.shots % v6.tracerEvery == 0 then
						local raycastResult2 = workspace:Raycast(pointToWorldSpace, lookVector2 * 500, raycastParams3)
						local v87

						if raycastResult2 then
							v87 = raycastResult2.Position
						else
							v87 = pointToWorldSpace + lookVector2 * 500
						end

						Tracers.fire(pointToWorldSpace, v87, nil, nil, true, nil, true)

						if raycastResult2 then
							local v88 = raycastResult2.Instance == workspace.Terrain
								and raycastResult2.Material ~= Enum.Material.Water
							task.delay(
								Tracers.travelTime(pointToWorldSpace, v87),
								ImpactFX.bullet,
								raycastResult2.Position,
								raycastResult2.Normal,
								lookVector2,
								v88
							)
						end
					end

					table.insert(v84, lookVector2)

					if v6.belt or v6.heavy then
						VoxelSound.ownLMG(0.9)
					end

					v31.heat += v6.heat

					if v31.heat >= 1 then
						v31.locked = true
					end
				end

				v31.last = p

				if #v84 > 0 then
					Remotes.HeliDoorFire:FireServer(v75.id, table.unpack(v84))
				end

				v31.shake = CFrame.Angles(
					math.rad(v7.jolt * (random2:NextNumber() * 2 - 1)),
					math.rad(v7.jolt * (random2:NextNumber() * 2 - 1)),
					0
				)
			elseif v31.spin > 0.3 then
				local v81 = v7.hum * v31.spin
				v31.shake = CFrame.Angles(
					math.rad(v81 * (random2:NextNumber() * 2 - 1)),
					math.rad(v81 * (random2:NextNumber() * 2 - 1)),
					0
				)
			else
				v31.shake = CFrame.identity
			end

			if p - v31.aimSentAt >= v7.aimSend then
				v31.aimSentAt = p
				Remotes.HeliGunAim:FireServer(v75.id, v31.yaw, v31.pitch, v31.spin + (v31.firing and 2 or 0))
			end
		else
			v31.shake = CFrame.identity
			v31.zoom = 0
		end
	end

	local function seatFrame(p, p2: number) -- 2 equivalent calls inferred from this helper
		local seat = p.def.seats[p2]
		return p.cf * CFrame.new(seat.root) * CFrame.Angles(0, seat.yaw or 0, 0)
	end

	local function seatRoot(p, p2, p3: number) -- 3 equivalent calls inferred from this helper
		p.CFrame = seatFrame(p2, p3) -- inferred equivalent call
		p.AssemblyLinearVelocity = p2.vel
		p.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
	end

	function v69.frame(p: number, p2: number)
		debug.profilebegin("HC.seat")
		checkSeat()
		debug.profileend()

		if v13 and not v69.seatHold then
			v69.seatHold = RunService.PreSimulation:Connect(function()
				local v75 = v13

				if v75 then
					local _, _, v76 = myCharacter() -- inferred equivalent call

					if v76 then
						seatRoot(v76, v75, v14) -- inferred equivalent call
					end
				end
			end)
		elseif not v13 and v69.seatHold then
			v69.seatHold:Disconnect()
			v69.seatHold = nil
		end

		local v75 = p2 - v66 > 0.5

		if v75 then
			v66 = p2
		end

		local currentCamera = workspace.CurrentCamera
		local v76 = not currentCamera and Vector3.new(0, 0, 0) or currentCamera.CFrame.Position
		v69.stale = true

		for _, v77 in list do
			readState(v77, p2)

			if
				v77.idleUntil
				and p2 < v77.idleUntil
				and not v77.running
				and not v77.wrecked
				and v13 ~= v77
				and attr(v77.folder, "Health") == v77.idleHealth -- inferred equivalent call
			then
				local v78 = false

				for i = 1, #v77.def.seats do
					local v79 = attr(v77.folder, v11[i]) -- inferred equivalent call

					if typeof(v79) == "number" and v79 ~= 0 then
						v78 = true
						break
					end
				end

				if not v78 then
					continue
				end
			end

			v77.idleUntil = nil
			debug.profilebegin("HC.f.fly")
			fly(v77, p, p2, v75)
			debug.profileend()
			debug.profilebegin("HC.f.draw")
			updateGuns(v77, p)
			draw(v77, p2, v76)
			debug.profileend()
			debug.profilebegin("HC.f.seats")

			local v78 = (v77.botDt or 0) + p
			local v79 = not v77.culled or (v77.botFrame or 0) % 3 == 0
			v77.botFrame = (v77.botFrame or 0) + 1
			v77.botDt = v79 and 0 or v78
			local v80 = false

			for i = 1, #v77.def.seats do
				local v81 = attr(v77.folder, v11[i]) -- inferred equivalent call
				v80 = typeof(v81) == "number" and v81 ~= 0 or v80

				if typeof(v81) == "number" and v81 < 0 then
					if v79 then
						SeatedBots.place(-v81, seatFrame(v77, i), i, v77.def, v77.vel, v78) -- inferred equivalent call
					end
				elseif typeof(v81) == "number" and v81 > 0 and v81 ~= localPlayer.UserId then
					local playerByUserId = Players:GetPlayerByUserId(v81)
					local humanoidRootPart = playerByUserId
						and playerByUserId.Character
						and playerByUserId.Character:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart then
						seatRoot(humanoidRootPart, v77, i) -- inferred equivalent call
					end
				end
			end

			debug.profileend()
			debug.profilebegin("HC.f.sound")
			updateSound(v77, p)
			debug.profileend()
			debug.profilebegin("HC.f.fx")
			effects(v77, p2, v76)
			debug.profileend()

			local idleHealth = attr(v77.folder, "Health") -- inferred equivalent call

			if not (v77.asleep and v77.spin < 0.005) then
				continue
			end

			if v77.gunsBusy or v77.running or v77.wrecked or v13 == v77 then
				continue
			end

			if v80 or v77.drawnCf ~= v77.cf or not (typeof(idleHealth) ~= "number" or idleHealth > 0.6) then
				continue
			end

			v77.idleUntil = p2 + 0.25
			v77.idleHealth = idleHealth
		end

		local cabin = v2.cabin
		local v77 = (not v13 or not visible2 or v13.def.jet or not v15 or v13.wrecked) and 0 or v13.spin

		if not cabin.player and v77 > 0 then
			local flat = AudioGraph.flat("HeliCabin")
			AudioGraph.lowpass(flat, cabin.lowpass)
			flat.player.Asset = "rbxassetid://" .. v2.rotor.id
			flat.player.Looping = true
			flat.player.LoopRegion = v2.rotor.loop
			flat.player.Volume = 0
			cabin.player = flat.player
			cabin.voice = flat
		end

		if cabin.player then
			tune(cabin.voice, cabin.gain * v77 ^ 1.4, 0.55 + 0.45 * v77)
		end

		local v78 = v13

		if v78 then
			local v79

			if v78.wrecked then
				v79 = not v78.asleep and v78.vel.Magnitude > 3
			else
				v79 = (attr(v78.folder, "Health") or 1) <= (v78.def.tuning or v).disabledAt -- inferred equivalent call
			end

			if v79 then
				if (v78.alarmAt or 0) <= p2 then
					v78.alarmAt = p2 + 0.32
					v78.alarmHigh = not v78.alarmHigh
					VoxelSound.fireAlarm(v78.alarmHigh == true, 0.6)
				end
			else
				v78.alarmAt = nil
			end
		end

		for i = #v12, 1, -1 do
			local v79 = v12[i]

			if v79.untilT <= p2 then
				v79.rig.destroy()
				table.remove(v12, i)
			else
				v79.rig.update(v79.cf, Vector3.new(0, 0, 0), 0, true, p, v76)
			end
		end

		local v79 = v13

		if v79 then
			local character, v81, v82 = myCharacter() -- inferred equivalent call

			if v82 then
				local position = v82.Position
				seatRoot(v82, v79, v14) -- inferred equivalent call
				local currentCamera2 = workspace.CurrentCamera
				local v83 = v82.Position - position

				if
					currentCamera2
					and currentCamera2.CameraType == Enum.CameraType.Custom
					and v83.Magnitude > 0.0001
				then
					currentCamera2.CFrame += v83
				end
			end

			if (visible2 or v31.gun > 0) and character and v81 and character:FindFirstChildOfClass("Tool") then
				v81:UnequipTools()
			end
		end

		debug.profilebegin("HC.camera")
		camera(p)
		debug.profileend()
		debug.profilebegin("HC.weapons")
		weapons(p2)
		doorGunner(p2, p)
		debug.profileend()

		if v13 and v31.gun > 0 then
			local gun = v13.guns[v31.gun]
			local yaw = v31.yaw
			local pitch = v31.pitch
			local spin = v31.spin
			local firing = v31.firing
			gun.yaw = yaw
			gun.pitch = pitch
			gun.spin = spin
			gun.firing = firing
			poseGuns(v13)
		end
	end
end

RunService:BindToRenderStep("Helicopters", Enum.RenderPriority.Camera.Value + 1, Detail.timed("heli", function(p)
	local now = os.clock()
	local success, result = xpcall(v69.frame, debug.traceback, p, now)
	debug.profilebegin("HC.hud")
	updateHud(now)
	debug.profileend()

	if not success then
		error(result, 0)
	end
end))

localPlayer.CharacterRemoving:Connect(function()
	if v13 then
		stopRiding()
	end
end)

function v69.watchDeath(instance)
	local humanoid = instance:WaitForChild("Humanoid", 10)

	if humanoid and humanoid:IsA("Humanoid") then
		humanoid.Died:Connect(function()
			if v13 and localPlayer.Character == instance then
				local id = v13.id
				local now = os.clock()
				v39 = id
				v40 = now
				stopRiding()
			end
		end)
	end
end
localPlayer.CharacterAdded:Connect(v69.watchDeath)

if localPlayer.Character then
	task.spawn(v69.watchDeath, localPlayer.Character)
end