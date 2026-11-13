local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local ParticleSim = require(script:WaitForChild("ParticleSim"))
local Materials = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("Materials"))
local VoxelSound = require(ReplicatedStorage.Voxel:WaitForChild("VoxelSound"))
local WorldConfig = require(ReplicatedStorage.Voxel:WaitForChild("WorldConfig"))
local GroundMarks = require(ReplicatedStorage.Voxel:WaitForChild("GroundMarks"))
local GroundHit = require(ReplicatedStorage.Voxel:WaitForChild("GroundHit"))
local ImpactFX = require(ReplicatedStorage.Voxel:WaitForChild("ImpactFX"))
local GroundFlatten = require(ReplicatedStorage.Voxel:WaitForChild("GroundFlatten"))
local BattleFX = require(ReplicatedStorage.Voxel:WaitForChild("BattleFX"))
local Remotes = ReplicatedStorage.Voxel:WaitForChild("Remotes")
local Quality = require(ReplicatedStorage.Voxel:WaitForChild("Quality"))

local meter = ParticleSim.METER

local voxelChips = Instance.new("Folder")
voxelChips.Name = "VoxelChips"
voxelChips.Parent = workspace
ParticleSim.start(voxelChips)

local random = Random.new()
local function rnd(p: number, p2: number) -- 23 equivalent calls inferred from this helper
	return random:NextNumber(p, p2)
end

local function cube(p: number) -- 3 equivalent calls inferred from this helper
	return (Vector3.new(rnd(-p, p), rnd(-p, p), rnd(-p, p))) -- inferred equivalent call
end

local v = 1
local function scaled(p: number) -- 5 equivalent calls inferred from this helper
	return (math.max(1, (math.floor(p * 1 * v + 0.5))))
end

local function pickFromMix(list, total: number)
	local v2 = random:NextNumber() * total

	for i = 1, #list, 2 do
		v2 -= list[i + 1]

		if v2 <= 0 then
			return list[i]
		end
	end

	return list[#list - 1]
end

local function spawnChip(p, data, vector3: Vector3, vector3_2: Vector3, p2: number, p3: number, p4: number) -- 4 equivalent calls inferred from this helper
	ParticleSim.spawn(
		p,
		vector3,
		vector3_2,
		p2,
		data.color,
		p3,
		p3,
		-10,
		-10,
		p4,
		0,
		1,
		1,
		0,
		0,
		data.material,
		data.transparency,
		data.variant
	)
end

local curve = ParticleSim.curve
local constant = ParticleSim.CONSTANT
local linear = ParticleSim.LINEAR
local easein = ParticleSim.EASEIN
local easeout = ParticleSim.EASEOUT

local v2 = {
	radius = curve(constant, 0, 0.25),
	alpha = curve(constant),
	gravity = curve(constant),
	rotation = curve(constant),
	emissive = curve(constant),
	drag = 0,
	sticky = 0.1,
	collide = 1,
	material = Enum.Material.SmoothPlastic
}

local v3 = {
	radius = curve(constant, 0, 0.2),
	alpha = curve(constant),
	gravity = curve(constant),
	rotation = curve(easeout),
	emissive = curve(constant),
	drag = 0,
	sticky = 0.2,
	collide = 1,
	material = Enum.Material.SmoothPlastic
}

local Grid4x4 = Enum.ParticleFlipbookLayout.Grid4x4
local v4 = { id = "rbxassetid://15483343964", layout = Grid4x4 }
local v5 = { id = "rbxassetid://110017652984281", layout = Grid4x4 }
local v6 = { id = "rbxassetid://89598700477428", layout = Grid4x4 }
local v7 = { id = "rbxassetid://12131540394", layout = Enum.ParticleFlipbookLayout.Grid8x8 }
local v8 = { id = "rbxassetid://13145063652", layout = Grid4x4 }
local v9 = { id = "rbxassetid://11388840312", layout = Grid4x4 }
local v10 = { id = "rbxassetid://9841260273", layout = Enum.ParticleFlipbookLayout.None }
local v11 = { id = "rbxassetid://129466478349977", layout = Grid4x4 }

local function holderPart(name: string) -- 4 equivalent calls inferred from this helper
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 1
	part.Size = Vector3.new(0.2, 0.2, 0.2)
	part.Parent = voxelChips
	return part
end

local parent2 = holderPart("PointEmitters") -- inferred equivalent call
local attachment = Instance.new("Attachment")
attachment.Parent = parent2
local parent3 = holderPart("VolumeEmitters") -- inferred equivalent call

local function sheet(p, p2) -- 4 equivalent calls inferred from this helper
	p.Texture = p2.id
	p.FlipbookLayout = p2.layout
	p.FlipbookMode = Enum.ParticleFlipbookMode.OneShot
	p.FlipbookStartRandom = false
end

local function emitter(parent, p)
	local particleEmitter = Instance.new("ParticleEmitter")
	sheet(particleEmitter, p) -- inferred equivalent call
	particleEmitter.LightInfluence = 1
	particleEmitter.Rate = 0
	particleEmitter.LockedToPart = false
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.RotSpeed = NumberRange.new(-30, 30)
	particleEmitter.Parent = parent
	return particleEmitter
end

local v12 = emitter(parent3, v7)
v12.Shape = Enum.ParticleEmitterShape.Sphere
v12.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
v12.SpreadAngle = Vector2.new(180, 180)
v12.Drag = 1

v12.Size = NumberSequence.new(0.2 * meter, 0.6 * meter)
v12.Transparency = NumberSequence.new(0.6, 1)
v12.Lifetime = NumberRange.new(0.8, 1.4)
v12.Speed = NumberRange.new(0, 1.5 * meter)

local v13 = emitter(attachment, v4)
local v14 = emitter(attachment, v5)
v14.Speed = NumberRange.new(0)
v14.RotSpeed = NumberRange.new(0)
local v15 = emitter(attachment, v7)
local v16 = emitter(attachment, v8)
v16.LightEmission = 1
v16.LightInfluence = 0
v16.ZOffset = 1

v16.Rotation = NumberRange.new(-20, 20)
v16.RotSpeed = NumberRange.new(-15, 15)
local v17 = emitter(attachment, v9)
v17.LightEmission = 1
v17.LightInfluence = 0
v17.ZOffset = 1
v17.Speed = NumberRange.new(0)
v17.Transparency = NumberSequence.new(0)
v17.RotSpeed = NumberRange.new(-20, 20)
local v18 = emitter(attachment, v11)
v18.LightEmission = 0.6
v18.LightInfluence = 0
v18.Speed = NumberRange.new(0)
v18.RotSpeed = NumberRange.new(0)
v18.Transparency = NumberSequence.new(0.2, 1)

local v19 = emitter(attachment, v10)
v19.LightEmission = 1
v19.LightInfluence = 0
v19.ZOffset = 1
v19.Orientation = Enum.ParticleOrientation.VelocityParallel
v19.Rotation = NumberRange.new(90)
v19.RotSpeed = NumberRange.new(0)
v19.Brightness = 3
v19.Drag = 0.5

local v20 = emitter(attachment, v8)
v20.LightEmission = 1
v20.LightInfluence = 0
v20.Brightness = 10
v20.ZOffset = 3
v20.Speed = NumberRange.new(0)
v20.RotSpeed = NumberRange.new(-40, 40)
v20.Color = ColorSequence.new(Color3.new(1, 1, 0.95), Color3.new(1, 0.85, 0.55))

local v21 = emitter(attachment, v10)
v21.LightEmission = 1
v21.LightInfluence = 0
v21.ZOffset = 2
v21.Orientation = Enum.ParticleOrientation.VelocityParallel
v21.Rotation = NumberRange.new(90)
v21.RotSpeed = NumberRange.new(0)
v21.Brightness = 5
v21.Drag = 2.5
v21.Color = ColorSequence.new(Color3.new(1, 0.95, 0.8), Color3.new(1, 0.55, 0.2))
v21.Transparency = NumberSequence.new(0, 0.5)

local v22 = emitter(attachment, v10)
v22.LightEmission = 1
v22.LightInfluence = 0
v22.ZOffset = 1
v22.Orientation = Enum.ParticleOrientation.VelocityParallel
v22.Rotation = NumberRange.new(90)
v22.RotSpeed = NumberRange.new(0)
v22.Brightness = 2.5
v22.Drag = 1.2
v22.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.new(1, 0.8, 0.45)),
	ColorSequenceKeypoint.new(0.4, Color3.new(1, 0.4, 0.12)),
	ColorSequenceKeypoint.new(1, Color3.new(0.55, 0.1, 0.04))
})

v22.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(0.7, 0.2),
	NumberSequenceKeypoint.new(1, 1)
})

v22.Size = NumberSequence.new(0.35, 0.15)

local function moveTo(cframe: CFrame) -- 15 equivalent calls inferred from this helper
	parent2.CFrame = cframe
end

local function lighten(color: Color3) -- 2 equivalent calls inferred from this helper
	return Color3.new(color.R * 0.5 + 0.4, color.G * 0.5 + 0.425, color.B * 0.5 + 0.45)
end

local v23 = {}
local v24 = -1

local v25 = {
	dustTint = nil,
	dustFast = false,
	sparksAccel = nil,
	rocketFilterAt = -1e999,
	rocketFilterHeli = false
}
local vector3 = Vector3.new(0, -1.5 * meter, 0)
local vector3_2 = Vector3.new(0, -6 * meter, 0)
v12.Acceleration = vector3
local function holeDust(position: Vector3, color: Color3, p: number, p2: number)
	local v26 = math.max(p * 2, 0.4)

	if v26 ~= v24 then
		parent3.Size = Vector3.new(1, 1, 1) * v26
		v24 = v26
	end

	parent3.CFrame = CFrame.new(position)
	local v27 = v23[color]

	if not v27 then
		v27 = ColorSequence.new(lighten(color))
		v23[color] = v27
	end

	if v25.dustTint ~= v27 then
		v25.dustTint = v27
		v12.Color = v27
	end

	local v28 = (math.max)(1, p2 // 2)

	if v25.dustFast then
		v12:Emit(p2 - v28)
		v12.Acceleration = vector3
		v12:Emit(v28)
	else
		v12:Emit(v28)
		v12.Acceleration = vector3_2
		v12:Emit(p2 - v28)
	end

	v25.dustFast = not v25.dustFast
end

local function reflect(vector: Vector3, vector3_3: Vector3) -- 3 equivalent calls inferred from this helper
	return vector - vector3_3 * (2 * vector:Dot(vector3_3))
end

local function tangentJitter(vector3_3: Vector3, p: number) -- 5 equivalent calls inferred from this helper
	local vector = random:NextUnitVector() * (p * random:NextNumber())
	return vector - vector3_3 * vector:Dot(vector3_3)
end

local function scuffDust(vector3_3: Vector3, vector3_4: Vector3, vector: Vector3, color: Color3, p: number, p2: number)
	local v26 = lighten(color) -- inferred equivalent call
	local v27 = reflect(vector, vector3_4) -- inferred equivalent call

	if v27.Magnitude < 0.001 then
		v27 = vector3_4
	end

	local unit = v27.Unit
	v15.Color = ColorSequence.new(v26)
	v15.Size = NumberSequence.new(0.2 * meter, 0.6 * meter)
	v15.Transparency = NumberSequence.new(0.5, 1)
	v15.Lifetime = NumberRange.new(0.5, 1)
	v15.Speed = NumberRange.new(0, 1.5 * meter)
	v15.SpreadAngle = Vector2.new(35, 35)
	v15.Acceleration = Vector3.new(0, -2 * meter, 0)
	v15.Drag = 1
	v15.EmissionDirection = Enum.NormalId.Front

	for _ = 1, 4 do
		local v28 = vector3_3 + vector3_4 * (0.05 * meter) + tangentJitter(vector3_4, math.max(p, 0.1 * meter)) -- inferred equivalent call
		moveTo(CFrame.lookAt(v28, v28 + unit)) -- inferred equivalent call
		v15:Emit((math.max(1, p2 // 4)))
	end
end

local ShotStream = require(ReplicatedStorage.Voxel:WaitForChild("ShotStream"))
local StrikePredict = require(ReplicatedStorage.Voxel:WaitForChild("StrikePredict"))

local fn
local fn2

local v26 = false

local function brokenChips(vector3_3: Vector3, vector3_4: Vector3, data, p: number, p2: number)
	local v27 = p / meter

	for _ = 1, scaled((math.min)(p2, 12)) do -- inferred equivalent call
		spawnChip( -- inferred equivalent call
			v2,
			data,
			vector3_3 + vector3_4 * (0.05 * meter) + random:NextUnitVector() * (rnd(0, v27) * meter), -- inferred equivalent call
			(vector3_4 + random:NextUnitVector() * 0.8) * rnd(0.5, 2.5) * meter, -- inferred equivalent call
			rnd(0.6, 1.2), -- inferred equivalent call
			rnd(0.4, 0.8) * 0.05, -- inferred equivalent call
			rnd(-6, 6) -- inferred equivalent call
		)
	end

	holeDust(vector3_3, data.color, p, 1)
end

local v27 = 0.12 * meter

local v28 = {}
local random2 = Random.new()
ImpactFX.listen(function(pos: Vector3, vector3_3: Vector3, flag: boolean)
	if not flag then
		return
	end

	if not Quality.groundChips() then
		table.insert(v28, { pos = pos, at = os.clock() })
		return
	end

	local mixed = GroundHit.mix(pos - vector3_3 * 0.5, 0)
	local v29 = mixed and Materials.Palette[GroundHit.pick(mixed, random2)]

	if not v29 then
		return
	end

	v = math.max(Quality.detail(pos), 0.2)
	ParticleSim.wake(pos, v27 + 2)
	brokenChips(pos, vector3_3, v29, v27, 3)
	table.insert(v28, { pos = pos, at = os.clock() })
end)

local function drewOwnGround(vector3_3: Vector3): boolean
	local now = os.clock()

	for i = #v28, 1, -1 do
		local v29 = v28[i]

		if now - v29.at > 2 then
			table.remove(v28, i)
		elseif (v29.pos - vector3_3).Magnitude < 2 then
			table.remove(v28, i)
			return true
		end
	end

	return false
end

ShotStream.onImpact(function(vector3_3: Vector3, vector3_4: Vector3, vector: Vector3, p: number, p2: number, flag: boolean, p3, value: number?, flag2: boolean?, flag3: boolean?)
	local detail = Quality.detail(vector3_3)

	if p3 == Players.LocalPlayer then
		detail = math.max(detail, 0.2)
	end

	v = detail

	if v <= 0 then
		ParticleSim.wake(vector3_3, p2 + 2)

		if flag2 and not flag3 then
			GroundMarks.bullet(vector3_3, vector3_4)
		end
	else
		if flag3 then
			fn2(vector3_3, vector3_4, vector)
			return
		end

		if flag2 and p3 == Players.LocalPlayer and p2 < 0.3 * meter and drewOwnGround(vector3_3) then
			return
		end

		if flag2 and not Quality.groundChips() then
			ParticleSim.wake(vector3_3, p2 + 2)
			GroundMarks.bullet(vector3_3, vector3_4)
		else
			local v29 = Materials.Palette[p]

			if not v29 then
				return
			end

			local color = v29.color
			local v30 = p2 / meter
			ParticleSim.wake(vector3_3, p2 + 2)

			if v30 < 0.3 then
				if flag then
					brokenChips(vector3_3, vector3_4, v29, p2, value or 1)
				elseif not flag2 and v29.type.sound ~= "metal" then
					for _ = 1, math.max(1, (math.floor(v * 2 + 0.5))) do
						spawnChip( -- inferred equivalent call
							v2,
							v29,
							vector3_3 + vector3_4 * (0.05 * meter) + random:NextUnitVector() * (rnd(0, v30 * 0.5) * meter), -- inferred equivalent call
							(vector3_4 + random:NextUnitVector() * 0.8) * rnd(0.5, 2) * meter, -- inferred equivalent call
							rnd(0.5, 1), -- inferred equivalent call
							rnd(0.25, 0.45) * 0.05, -- inferred equivalent call
							rnd(-6, 6) -- inferred equivalent call
						)
					end

					holeDust(vector3_3, color, p2, 1)
				end

				if flag2 and p3 ~= Players.LocalPlayer then
					GroundMarks.bullet(vector3_3, vector3_4)
				end

				if p3 ~= Players.LocalPlayer and (not flag2 or v29.type.sparks) then
					local v31 = reflect(vector, vector3_4) -- inferred equivalent call

					if not v26 then
						v26 = true
						v19.Color = ColorSequence.new(Color3.new(1, 0.85, 0.55), Color3.new(1, 0.5, 0.2))
						v19.Size = NumberSequence.new(0.22, 0.04)
						v19.Transparency = NumberSequence.new(0, 0.3)
						v19.Lifetime = NumberRange.new(0.08, 0.2)
						v19.Speed = NumberRange.new(6 * meter, 12 * meter)
						v19.SpreadAngle = Vector2.new(30, 30)
						v19.EmissionDirection = Enum.NormalId.Front
					end

					local vector3_5 = Vector3.new(0, -10 * ParticleSim.gravityScale() * meter, 0)

					if v25.sparksAccel ~= vector3_5 then
						v25.sparksAccel = vector3_5
						v19.Acceleration = vector3_5
					end

					local v32 = vector3_3 + vector3_4 * (0.05 * meter)
					moveTo(CFrame.lookAt(v32, v32 + v31)) -- inferred equivalent call
					v19:Emit((math.max(1, (math.floor(v * 4 + 0.5)))))
				end
			else
				if p3 == Players.LocalPlayer then
					local match, v31 = StrikePredict.match(vector3_3)

					if match then
						if flag and not (v31 or flag2) then
							fn(vector3_3, vector3_4, vector, v29, p2, true, flag2, true)
						end

						return
					end
				end

				fn(vector3_3, vector3_4, vector, v29, p2, flag, flag2)
			end
		end
	end
end)

StrikePredict.struck:Connect(function(vector3_3: Vector3, vector3_4: Vector3, vector3_5: Vector3, p: number, p2: number, flag: boolean, flag2: boolean)
	local v29 = Materials.Palette[p]
	v = math.max(Quality.detail(vector3_3), 0.2)
	ParticleSim.wake(vector3_3, p2 + 2)
	fn(vector3_3, vector3_4, vector3_5, v29, p2, flag, flag2)
end)

local Tracers = require(ReplicatedStorage.Voxel:WaitForChild("Tracers"))
local SniperTrace = require(ReplicatedStorage.Voxel:WaitForChild("SniperTrace"))
local Ballistics = require(ReplicatedStorage.Voxel:WaitForChild("Ballistics"))
local SniperSpecs = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("SniperSpecs"))
local Players2 = game:GetService("Players")
local LocalPlayer = Players2.LocalPlayer

local v29 = {}
Players.PlayerRemoving:Connect(function(player)
	v29[player] = nil
end)
ShotStream.onShot(function(player, vector3_3: Vector3, vector3_4: Vector3, p: string?)
	if player ~= LocalPlayer then
		if p == "HeavyGun" then
			Tracers.fire(vector3_3, vector3_4, nil, nil, true)
			VoxelSound.shot(vector3_3, 1.6, vector3_4, "Sniper")
		elseif p == "Minigun" then
			local v30 = player or "?"
			local v31 = (v29[v30] or 0) + 1
			v29[v30] = v31

			if v31 % 2 == 0 then
				Tracers.fire(vector3_3, vector3_4, nil, nil, true)
			end

			VoxelSound.minigunShot(v30, vector3_3, vector3_4)
		else
			local tool = player and player.Character and player.Character:FindFirstChildOfClass("Tool")
			local gsQuiet = tool and tool:GetAttribute("GsQuiet")

			if type(gsQuiet) ~= "number" then
				gsQuiet = nil
			end

			if p == "Sniper" then
				local v30 = tool and SniperSpecs.of(tool.Name)
				local v31

				if v30 then
					v31 = v30.speed
				else
					v31 = Ballistics.RIFLE_SPEED
				end

				local v32

				if v30 then
					v32 = v30.arc
				else
					v32 = Ballistics.RIFLE_ARC
				end

				SniperTrace.fire(
					vector3_3,
					vector3_4,
					Ballistics.flightTime((vector3_4 - vector3_3).Magnitude, v31, v32),
					0.8 * (v30 and v30.tracer or 1),
					v32
				)
				VoxelSound.shot(vector3_3, 1.9, vector3_4, not v30 and "Sniper" or v30.id, gsQuiet)
			elseif p == "LMG" then
				Tracers.fire(vector3_3, vector3_4, nil, nil, true)
				VoxelSound.shot(vector3_3, 1.1, vector3_4, "LMG", gsQuiet)
			elseif p == "DMR" then
				Tracers.fire(vector3_3, vector3_4, Ballistics.DMR_SPEED, nil, true)
				VoxelSound.shot(vector3_3, 1.3, vector3_4, "DMR", gsQuiet)
			elseif p == "Shotgun" then
				Tracers.fire(vector3_3, vector3_4)
				VoxelSound.shot(vector3_3, 1.5, vector3_4, "Shotgun")
			elseif p == "ShotgunPellet" then
				Tracers.fire(vector3_3, vector3_4)
			elseif p == "HandCannon" then
				Tracers.fire(vector3_3, vector3_4, nil, nil, true)
				VoxelSound.shot(vector3_3, 1.25, vector3_4, "HandCannon")
			else
				Tracers.fire(vector3_3, vector3_4)

				if p == "Pistol" then
					VoxelSound.shot(vector3_3, 0.8, vector3_4, "Pistol")
				elseif p == "SMG" then
					local tool2 = player and player.Character and player.Character:FindFirstChildOfClass("Tool")
					local gsQuiet2 = tool2 and tool2:GetAttribute("GsQuiet")
					local shot = VoxelSound.shot
					local v30 = not (tool2 and VoxelSound.isSMGVoice(tool2.Name)) and "SMG" or tool2.Name

					if type(gsQuiet2) ~= "number" then
						gsQuiet2 = nil
					end

					shot(vector3_3, 0.85, vector3_4, v30, gsQuiet2)
				else
					local tool2 = player and player.Character and player.Character:FindFirstChildOfClass("Tool")
					local gsQuiet2 = tool2 and tool2:GetAttribute("GsQuiet")
					local shot = VoxelSound.shot
					local name

					if tool2 and VoxelSound.isRifleVoice(tool2.Name) then
						name = tool2.Name
					end

					if type(gsQuiet2) ~= "number" then
						gsQuiet2 = nil
					end

					shot(vector3_3, 1, vector3_4, name, gsQuiet2)
				end
			end
		end
	end
end)

local RocketFlight = require(ReplicatedStorage.Voxel:WaitForChild("RocketFlight"))
local RocketPredict = require(ReplicatedStorage.Voxel:WaitForChild("RocketPredict"))
local ClientWorld = require(ReplicatedStorage.Voxel:WaitForChild("ClientWorld"))
local VoxelCore = require(ReplicatedStorage.Voxel:WaitForChild("VoxelCore"))

local v30 = {}

local fn3

local v31 = {
	NEAR_M = 35,
	FULL_M = 70,
	SPAN = 0.022,
	DISCS = {
		{ 1, Color3.fromRGB(255, 176, 84), 0.16 },
		{ 0.66, Color3.fromRGB(255, 208, 128), 0.32 },
		{ 0.42, Color3.fromRGB(255, 240, 196), 0.7 },
		{ 0.24, Color3.fromRGB(255, 255, 248), 1 }
	},
	spare = {}
}

function v31.take()
	local v32 = table.remove(v31.spare)

	if v32 then
		return v32
	end

	local rocketMark = Instance.new("Attachment")
	rocketMark.Name = "RocketMark"
	rocketMark.Parent = workspace.Terrain
	local rocketMark2 = Instance.new("BillboardGui")
	rocketMark2.Name = "RocketMark"
	rocketMark2.Adornee = rocketMark
	rocketMark2.AlwaysOnTop = false
	rocketMark2.LightInfluence = 0
	rocketMark2.ResetOnSpawn = false
	rocketMark2.Enabled = false
	local function dot(p: number, backgroundColor: Color3, zIndex: number)
		local frame = Instance.new("Frame")
		frame.BorderSizePixel = 0
		frame.BackgroundColor3 = backgroundColor
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.fromScale(0.5, 0.5)
		frame.Size = UDim2.fromScale(p, p)
		frame.ZIndex = zIndex
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0.5, 0)
		uiCorner.Parent = frame
		frame.Parent = rocketMark2
		return frame
	end

	local discs = {}

	for k, v36 in v31.DISCS do
		discs[k] = dot(v36[1], v36[2], k)
	end

	rocketMark2.Parent = LocalPlayer:WaitForChild("PlayerGui")
	return { gui = rocketMark2, att = rocketMark, discs = discs, k = -1 }
end

function v31:give()
	self.gui.Enabled = false
	self.k = -1
	table.insert(v31.spare, self)
end

function v31:place(worldPosition: Vector3)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local v32 = math.clamp(
		((worldPosition - currentCamera.CFrame.Position).Magnitude / WorldConfig.METER - v31.NEAR_M) / (v31.FULL_M - v31.NEAR_M),
		0,
		1
	)
	local enabled = v32 > 0.01

	if self.gui.Enabled ~= enabled then
		self.gui.Enabled = enabled
	end

	if not enabled then
		return
	end

	self.att.WorldPosition = worldPosition

	local v36 = math.max(9, v31.SPAN * currentCamera.ViewportSize.Y) * (0.9 + 0.2 * math.random())
	self.gui.Size = UDim2.fromOffset(v36, v36)

	local v37 = math.floor(v32 * 20 + 0.5) / 20

	if v37 ~= self.k then
		self.k = v37

		for k, disc in self.discs do
			disc.BackgroundTransparency = 1 - v37 * v31.DISCS[k][3]
		end
	end
end

local function makeRocket()
	local part = Instance.new("Part")
	part.Size = Vector3.new(0.45, 0.45, 1.8)
	part.Color = Color3.fromRGB(70, 80, 56)
	part.Material = Enum.Material.Metal
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false

	local attachment2 = Instance.new("Attachment")
	attachment2.Position = Vector3.new(0, 0, 0.9)
	attachment2.Parent = part

	local flame = Instance.new("ParticleEmitter")
	sheet(flame, v8) -- inferred equivalent call
	flame.Rotation = NumberRange.new(-20, 20)
	flame.Color = ColorSequence.new(Color3.fromRGB(255, 200, 120), Color3.fromRGB(255, 90, 30))
	flame.LightEmission = 1
	flame.Size = NumberSequence.new(1.1, 0.15)
	flame.Brightness = 4
	flame.LightInfluence = 0
	flame.Lifetime = NumberRange.new(0.06, 0.12)
	flame.Rate = math.max(60, 160 * Quality.share())
	flame.Speed = NumberRange.new(1, 3)
	flame.EmissionDirection = Enum.NormalId.Back
	flame.Name = "Flame"
	flame.Enabled = false
	flame.Parent = attachment2

	local glow = Instance.new("PointLight")
	glow.Name = "Glow"
	glow.Color = Color3.fromRGB(255, 170, 90)
	glow.Range = 10
	glow.Brightness = 3
	glow.Shadows = false
	glow.Enabled = false
	glow.Parent = attachment2

	local exhaust = Instance.new("ParticleEmitter")
	exhaust.Name = "Exhaust"
	exhaust.Enabled = false
	sheet(exhaust, v6) -- inferred equivalent call
	exhaust.LightInfluence = 1
	exhaust.Rotation = NumberRange.new(0, 360)
	exhaust.RotSpeed = NumberRange.new(-30, 30)

	exhaust.Color = ColorSequence.new(Color3.fromRGB(240, 236, 230), Color3.fromRGB(190, 186, 182))
	exhaust.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.3, 1.3),
		NumberSequenceKeypoint.new(1, 2.4)
	})

	exhaust.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.06, 0.55),
		NumberSequenceKeypoint.new(0.5, 0.75),
		NumberSequenceKeypoint.new(1, 1)
	})

	exhaust.Lifetime = NumberRange.new(0.5, 0.9)
	exhaust.Rate = math.max(10, 22 * Quality.share())
	exhaust.Speed = NumberRange.new(0.2, 0.8)
	exhaust.SpreadAngle = Vector2.new(40, 40)
	exhaust.Acceleration = Vector3.new(0, 0.8, 0)
	exhaust.Drag = 1
	exhaust.RotSpeed = NumberRange.new(-12, 12)
	exhaust.Parent = attachment2

	return part
end

local function removeRocket(p: number)
	local v32 = v30[p]

	if not v32 then
		return
	end

	v30[p] = nil
	VoxelSound.rocketEnd(p)

	if v32.mark then
		v31.give(v32.mark)
		v32.mark = nil
	end

	local model = v32.model
	model.Transparency = 1

	for _, emitter2 in model:GetDescendants() do
		if emitter2:IsA("ParticleEmitter") then
			emitter2.Enabled = false
		end
	end

	Debris:AddItem(model, 1.5)
end

local parent = holderPart("RocketMuzzle") -- inferred equivalent call
local attachment2 = Instance.new("Attachment")
attachment2.Parent = parent
local particleEmitter = Instance.new("ParticleEmitter")
sheet(particleEmitter, v8) -- inferred equivalent call
particleEmitter.Rate = 0
particleEmitter.LightEmission = 1
particleEmitter.LightInfluence = 0
particleEmitter.Brightness = 3
particleEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 226, 150), Color3.fromRGB(255, 110, 40))
particleEmitter.Size = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1.2),
	NumberSequenceKeypoint.new(0.4, 2.6),
	NumberSequenceKeypoint.new(1, 1.6)
})

particleEmitter.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(0.6, 0.3),
	NumberSequenceKeypoint.new(1, 1)
})

particleEmitter.Lifetime = NumberRange.new(0.06, 0.11)
particleEmitter.Speed = NumberRange.new(10, 26)
particleEmitter.Drag = 8
particleEmitter.SpreadAngle = Vector2.new(25, 25)
particleEmitter.Rotation = NumberRange.new(0, 360)
particleEmitter.EmissionDirection = Enum.NormalId.Front
particleEmitter.Parent = attachment2
local color = Color3.fromRGB(214, 208, 198)
local raycastParams = RaycastParams.new()

local function backblast(vector3_3: Vector3, vector: Vector3)
	BattleFX.flash(vector3_3, 22, 0.1)
	parent.CFrame = CFrame.lookAt(vector3_3, vector3_3 + vector)
	particleEmitter:Emit(Quality.count(6, vector3_3, 2))
	local v32 = vector3_3 - vector * 4
	BattleFX.billow(v32, color, 6, false)
	BattleFX.billow(vector3_3 + vector * 1.5, color, 2.5, false)
	local voxelChips2 = workspace:FindFirstChild("VoxelChips")
	local excludeInstances

	if voxelChips2 then
		excludeInstances = { voxelChips, voxelChips2 }
	else
		excludeInstances = { voxelChips }
	end

	raycastParams.ExcludeInstances = excludeInstances
	local raycastResult = workspace:Raycast(v32, Vector3.new(0, -8, 0), raycastParams)

	if raycastResult then
		BattleFX.skirt(raycastResult.Position, raycastResult.Normal, Color3.fromRGB(150, 136, 112), 5)
	end

	BattleFX.shake(vector3_3, 0.45, 6, 30)
end

local function ignite(p, _: Vector3)
	p.lit = true

	for _, descendant in p.model:GetDescendants() do
		if descendant:IsA("ParticleEmitter") and (descendant.Name == "Flame" or descendant.Name == "Exhaust") then
			descendant.Enabled = true
		elseif descendant:IsA("PointLight") and descendant.Name == "Glow" then
			descendant.Enabled = true
			p.glowOn = true
		end
	end

	p.mark = v31.take()
end

local function spawnRocket(p: number, origin: Vector3, vector: Vector3, vector3_3: Vector3?, flag: boolean?)
	local offset = not vector3_3 and Vector3.new(0, 0, 0) or vector3_3 - origin
	local rocket = makeRocket()

	if flag then
		rocket.Color = Color3.fromRGB(24, 24, 28)
	end

	rocket.CFrame = CFrame.lookAt(origin + offset, origin + offset + vector)
	rocket.Parent = voxelChips
	local unit = vector:Cross(math.abs(vector.Y) < 0.95 and Vector3.new(0, 1, 0) or Vector3.new(1, 0, 0)).Unit
	local rocket2 = {
		model = rocket,
		glow = rocket:FindFirstChild("Glow", true),
		origin = origin,
		dir = vector,
		born = os.clock(),
		lit = false,
		spin = random:NextNumber(0, 6.283185307179586),
		side = unit,
		up = unit:Cross(vector).Unit,
		offset = offset
	}

	v30[p] = rocket2
	fn3()
	VoxelSound.launch(origin + offset, p)
	backblast(origin + offset, vector)
	return rocket2
end

local v32 = {}
local v36 = {}
local v37 = {}
local v38 = 0

RocketPredict.fired:Connect(function(last: Vector3, dir: Vector3, vector3_3: Vector3?, heli: boolean, flag: boolean)
	v38 -= 1
	local v39 = spawnRocket(v38, last, dir, vector3_3, flag)
	v39.mine = true
	v39.heli = heli
	v39.size = 1.2
	v39.last = last
	v39.traveled = 0
	table.insert(v32, { key = v38, t = os.clock(), origin = last })
end)

Remotes:WaitForChild("RocketSpawned").OnClientEvent:Connect(function(p: number, origin: Vector3, dir: Vector3, _: number?, vector3_3: Vector3?, p2, p3: number?, flag: boolean?)
	if p2 == LocalPlayer then
		local now = os.clock()

		while v32[1] and now - v32[1].t > 1.5 do
			table.remove(v32, 1)
		end

		for k, v39 in v32 do
			if (v39.origin - origin).Magnitude < 15 then
				table.remove(v32, k)
				v36[p] = v39.key
				local v40 = v30[v39.key]

				if v40 then
					v40.matched = true
					v40.size = p3 or v40.size
				end

				return
			end
		end
	end

	spawnRocket(p, origin, dir, vector3_3, flag)
end)

local raycastParams2 = RaycastParams.new()
raycastParams2.IgnoreWater = true

local function ownRocketTargets(heli: boolean?)
	local now = os.clock()

	if now - v25.rocketFilterAt < 0.5 and v25.rocketFilterHeli == (heli == true) then
		return
	end

	local rocketFilterHeli = heli == true
	v25.rocketFilterAt = now
	v25.rocketFilterHeli = rocketFilterHeli
	local includeInstances = { workspace.Terrain }

	for _, childName in { "VehicleHulls", "BotRigs", "Helicopters" } do
		local child = workspace:FindFirstChild(childName)

		if child and (not heli or childName ~= "Helicopters") then
			table.insert(includeInstances, child)
		end
	end

	for _, v41 in Players:GetPlayers() do
		if v41 ~= LocalPlayer and v41.Character then
			table.insert(includeInstances, v41.Character)
		end
	end

	raycastParams2.IncludeInstances = includeInstances
end

local fn4

local function ownRocketStrike(k: number, state, last: Vector3, vector3_3: Vector3): boolean
	local v39 = vector3_3 - last
	local magnitude = v39.Magnitude

	if magnitude < 0.001 then
		return false
	end

	local v40 = v39 / magnitude
	local world = ClientWorld.world
	assert(world, "[VoxelFX] the client voxel world is not built")
	ownRocketTargets(state.heli)
	local size = state.size or 1.2
	local raycast, v41, v42, v43 = VoxelCore.raycast(world, last, v40, magnitude)
	local raycastResult = workspace:Raycast(last, v39, raycastParams2)
	local at = nil
	local v45 = nil
	local v46 = nil

	if raycast and v41 and (not raycastResult or v43 <= raycastResult.Distance) then
		v45 = v41
		at = raycast
		v46 = { v42, 1 }
	elseif raycastResult then
		at = raycastResult.Position
		v45 = raycastResult.Normal

		if raycastResult.Instance == workspace.Terrain then
			v46 = GroundHit.mix(raycastResult.Position - raycastResult.Normal * 0.5, WorldConfig.blastRadius(size))
		end
	end

	local v47 = false

	if at then
		state.traveled = (state.traveled or 0) + (at - last).Magnitude
	else
		state.traveled = (state.traveled or 0) + magnitude

		if state.traveled < 450 then
			return false
		end

		at = vector3_3
		v47 = true
	end

	removeRocket(k)
	v37[k] = { at = at, t = os.clock() }
	fn4(at, size, v46 or {}, state.dir, v45, v47)
	return true
end

local renderSteppedConnection = nil
local function rocketStep(p: number)
	local now = os.clock()

	for k, v39 in v37 do
		if now - v39.t > 3 then
			v37[k] = nil
		end
	end

	for k, v39 in v30 do
		local v40 = now - v39.born

		if v40 > 6 then
			removeRocket(k)
		else
			local last2, v42 = RocketFlight.at(v39.origin, v39.dir, v40)

			if v39.mine then
				if not v39.matched and v40 > 1.5 then
					removeRocket(k)
					continue
				end

				local last = v39.last or v39.origin
				v39.last = last2

				if ownRocketStrike(k, v39, last, last2) then
					continue
				end
			end

			if not v39.lit and RocketFlight.IGNITE <= v40 then
				ignite(v39, last2)
			end

			local v43

			if v39.lit then
				v39.spin += 56.548667764616276 * p

				local v44 = math.clamp((v40 - RocketFlight.IGNITE) / 0.15, 0, 1) * 0.08
				v43 = (v39.side * math.cos(v39.spin) + v39.up * math.sin(v39.spin)) * v44
			else
				v43 = Vector3.new(0, 0, 0)
			end

			local v44 = last2 + v43
			local v45

			if v39.offset and v40 < 0.12 then
				local v46 = v40 / 0.12
				local v47 = 1 - v46 * v46 * (3 - 2 * v46)
				v44 += v39.offset * v47

				v45 = v42 - v39.offset * (6 * v46 * (1 - v46) / 0.12)
			else
				v45 = v42
			end

			v39.model.CFrame = CFrame.lookAt(v44, v44 + v45) * CFrame.Angles(0, 0, v39.spin)

			if v39.mark then
				v31.place(v39.mark, v44)
			end

			local glow = v39.glow

			if v39.lit and glow and (Quality.mobile or Quality.potato) then
				local v46 = Quality.metres(v44) < Quality.MOBILE_FULL_M

				if v39.glowOn ~= v46 then
					v39.glowOn = v46
					glow.Enabled = v46
				end
			end

			VoxelSound.rocketMove(k, v44, v42)
		end
	end

	if next(v30) == nil and next(v37) == nil and renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end
end
fn3 = function()
	if not renderSteppedConnection then
		renderSteppedConnection = RunService.RenderStepped:Connect(rocketStep)
	end
end

local raycastParams3 = RaycastParams.new()
raycastParams3.ExcludeInstances = { voxelChips }
local raycastParams4 = RaycastParams.new()
raycastParams4.IncludeInstances = { workspace.Terrain }
raycastParams4.IgnoreWater = true

local v39 = {
	{
		sparks = { 10, 2 },
		debris = { 25, 6 },
		fire = { life = 0.5, size = 0.2 },
		smoke = {
			life = 1,
			size = 0.5,
			vel = 1,
			gravity = 3,
			amount = 2
		},
		flash = 0.15,
		column = 0,
		grit = 6
	},
	{
		sparks = { 30, 3 },
		debris = { 50, 7 },
		fire = { life = 1, size = 0.5 },
		smoke = {
			life = 1.5,
			size = 0.7,
			vel = 1,
			gravity = 2,
			amount = 2
		},
		flash = 0.25,
		column = 8,
		grit = 10
	},
	{
		sparks = { 50, 5 },
		debris = { 100, 10 },
		fire = { life = 1.3, size = 0.8 },
		smoke = {
			life = 3,
			size = 1,
			vel = 8,
			gravity = -1,
			amount = 6
		},
		flash = 0.4,
		column = 25,
		grit = 16
	}
}

local function facing(vector3_3: Vector3, vector3_4: Vector3) -- 9 equivalent calls inferred from this helper
	local v40 = math.abs(vector3_4.Y) > 0.99 and Vector3.new(1, 0, 0) or Vector3.new(0, 1, 0)
	return CFrame.lookAt(vector3_3, vector3_3 + vector3_4, v40)
end

local parent4 = holderPart("HitEmitters") -- inferred equivalent call
local attachment3 = Instance.new("Attachment")
attachment3.Parent = parent4
local v41 = emitter(attachment3, v9)
v41.LightEmission = 1
v41.LightInfluence = 0
v41.ZOffset = 1
v41.Speed = NumberRange.new(0)
v41.RotSpeed = NumberRange.new(-20, 20)
v41.Transparency = NumberSequence.new(0, 0.5)
v41.Size = NumberSequence.new(2.4, 6)
v41.Lifetime = NumberRange.new(0.14, 0.2)
local v42 = emitter(attachment3, v4)
v42.EmissionDirection = Enum.NormalId.Front
v42.SpreadAngle = Vector2.new(30, 30)
v42.Speed = NumberRange.new(18, 34)
v42.Drag = 7
v42.Acceleration = Vector3.new(0, -1.5 * meter, 0)
v42.Lifetime = NumberRange.new(0.5, 0.75)
v42.Size = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1.2),
	NumberSequenceKeypoint.new(0.3, 5.5),
	NumberSequenceKeypoint.new(1, 8.5)
})

v42.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.9),
	NumberSequenceKeypoint.new(0.08, 0.25),
	NumberSequenceKeypoint.new(1, 1)
})

local v43 = emitter(attachment3, v9)
v43.LightEmission = 1
v43.LightInfluence = 0
v43.ZOffset = 1
v43.Speed = NumberRange.new(0)
v43.RotSpeed = NumberRange.new(-20, 20)
v43.Transparency = NumberSequence.new(0, 0.5)
v43.Size = NumberSequence.new(3.6, 9)
v43.Lifetime = NumberRange.new(0.16, 0.24)
local v44 = emitter(attachment3, v4)
v44.EmissionDirection = Enum.NormalId.Front
v44.SpreadAngle = Vector2.new(35, 35)
v44.Speed = NumberRange.new(26, 46)
v44.Drag = 7
v44.Acceleration = Vector3.new(0, -1.5 * meter, 0)
v44.Lifetime = NumberRange.new(0.55, 0.85)
v44.Size = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1.8),
	NumberSequenceKeypoint.new(0.3, 8.2),
	NumberSequenceKeypoint.new(1, 12.8)
})

v44.Transparency = v42.Transparency
local v45 = nil
local function shellHit(vector3_3: Vector3, vector3_4: Vector3, color2: Color3, flag: boolean, flag2: boolean)
	parent4.CFrame = facing(vector3_3 + vector3_4 * 0.5, vector3_4) -- inferred equivalent call

	if flag2 then
		v43:Emit(2)
	else
		v41:Emit(2)
	end

	if flag then
		if color2 ~= v45 then
			v45 = color2
			v42.Color = ColorSequence.new(color2)
			v44.Color = v42.Color
		end

		if flag2 then
			v44:Emit((math.max(1, (math.floor(v * 4 + 0.5)))))
		else
			v42:Emit((math.max(1, (math.floor(v * 3 + 0.5)))))
		end
	end
end

local function blastFire(position: Vector3, data)
	local v46 = data.size * meter

	v16.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1, 0.93, 0.75)),
		ColorSequenceKeypoint.new(0.2, Color3.new(1, 0.7, 0.35)),
		ColorSequenceKeypoint.new(0.65, Color3.new(1, 0.38, 0.12)),
		ColorSequenceKeypoint.new(1, Color3.new(0.6, 0.18, 0.08))
	})

	v16.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, v46 * 1.5),
		NumberSequenceKeypoint.new(0.35, v46 * 3),
		NumberSequenceKeypoint.new(1, v46 * 2.2)
	})

	v16.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.6, 0.2),
		NumberSequenceKeypoint.new(1, 1)
	})

	v16.Brightness = 3
	v16.Lifetime = NumberRange.new(data.life * 0.8, data.life * 1.5)
	v16.Speed = NumberRange.new(0, data.size * 3 * meter)
	v16.SpreadAngle = Vector2.new(180, 180)
	v16.Acceleration = Vector3.new(0, (1.5 + 2.5 * data.life) * meter, 0)
	v16.Drag = 4
	moveTo(CFrame.new(position)) -- inferred equivalent call
	v16:Emit(scaled(data.count or math.floor(8 + 10 * data.size))) -- inferred equivalent call

	if data.lean then
		return
	end

	v17.Size = NumberSequence.new(v46 * 3, v46 * 5)
	v17.Lifetime = NumberRange.new(0.35, 0.5)
	v17:Emit(2)
	v18.Size = NumberSequence.new(v46 * 2, v46 * 9)
	v18.Lifetime = NumberRange.new(0.3)
	v18:Emit(1)
end

local function rocketCore(vector3_3: Vector3, vector3_4: Vector3, p: number, flag: boolean?)
	moveTo(CFrame.new(vector3_3 + vector3_4 * (p * 0.15))) -- inferred equivalent call
	v20.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, p * 0.9),
		NumberSequenceKeypoint.new(0.4, p * 1.5),
		NumberSequenceKeypoint.new(1, p * 1.7)
	})

	v20.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.5, 0.1),
		NumberSequenceKeypoint.new(1, 1)
	})

	v20.Lifetime = NumberRange.new(0.1, 0.16)
	v20:Emit(4)

	if flag then
		return
	end

	moveTo(facing(vector3_3, vector3_4)) -- inferred equivalent call
	v21.Size = NumberSequence.new(1.6, 0.2)
	v21.Lifetime = NumberRange.new(0.12, 0.3)
	v21.Speed = NumberRange.new(28 * meter, 55 * meter)
	v21.SpreadAngle = Vector2.new(75, 75)
	v21.Acceleration = Vector3.new(0, -10 * ParticleSim.gravityScale() * meter, 0)
	v21.EmissionDirection = Enum.NormalId.Front
	v21:Emit((math.max(1, (math.floor(v * 18 + 0.5)))))

	v22.Lifetime = NumberRange.new(0.7, 1.8)
	v22.Speed = NumberRange.new(4 * meter, 16 * meter)
	v22.SpreadAngle = Vector2.new(65, 65)
	v22.Acceleration = Vector3.new(0, -10 * ParticleSim.gravityScale() * meter, 0)
	v22.EmissionDirection = Enum.NormalId.Front
	v22:Emit((math.max(1, (math.floor(v * 36 + 0.5)))))
end

local color2 = Color3.new(0.55, 0.53, 0.5)

local function dustColour(list)
	local total = 0
	local total2 = 0
	local total3 = 0
	local total4 = 0

	for i = 1, #list, 2 do
		local v46 = Materials.Palette[list[i]]

		if not (v46 and v46.transparency == 0) then
			continue
		end

		local item = list[i + 1]
		total += v46.color.R * item
		total2 += v46.color.G * item
		total3 += v46.color.B * item
		total4 += item
	end

	if total4 == 0 then
		return color2
	end

	return BattleFX.neutral(color2:Lerp(Color3.new(total / total4, total2 / total4, total3 / total4), 0.4))
end

local function smokeCloud(vector3_3: Vector3, vector3_4: Vector3, clone, list, flag: boolean?)
	local v46 = clone.size * meter
	local v47 = dustColour(list)
	local color3 = Color3.new(v47.R * 0.6, v47.G * 0.6, v47.B * 0.6)

	v14.Color = ColorSequence.new(v47)

	v14.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, v46 * 0.4),
		NumberSequenceKeypoint.new(0.3, v46 * 3.5),
		NumberSequenceKeypoint.new(1, v46 * 5)
	})

	v14.Transparency = NumberSequence.new(0.1, 1)
	v14.Lifetime = NumberRange.new(0.3, 0.4)
	moveTo(CFrame.new(vector3_3 + vector3_4 * (v46 * 0.2))) -- inferred equivalent call
	v14:Emit(2)

	v13.Color = ColorSequence.new(color3, v47)

	v13.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, v46 * 0.3),
		NumberSequenceKeypoint.new(0.25, v46 * 2.2),
		NumberSequenceKeypoint.new(1, v46 * 3.6)
	})

	v13.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.04, 0.15),
		NumberSequenceKeypoint.new(0.4, 0.35),
		NumberSequenceKeypoint.new(1, 1)
	})
	local v48 = flag and 0.35 or 1
	v13.Lifetime = NumberRange.new(clone.life * 0.6 * v48, clone.life * 1 * v48)
	v13.EmissionDirection = Enum.NormalId.Front
	v13.SpreadAngle = Vector2.new(35, 35)
	v13.Speed = NumberRange.new(20 * meter * (clone.speed or 1), (32 + clone.vel) * meter * (clone.speed or 1))

	v13.Drag = 9
	v13.Acceleration = Vector3.new(0, -1.5 * meter, 0)
	v13.RotSpeed = NumberRange.new(-10, 10)

	for _ = 1, scaled(clone.count or math.floor(6 + 10 * clone.size)) do -- inferred equivalent call
		local v49

		if flag then
			local vector3_5 = Vector3.new(random:NextNumber(-1, 1), random:NextNumber(-1, 1), random:NextNumber(-1, 1))

			if vector3_5.Magnitude > 0.001 then
				v49 = vector3_5.Unit
			else
				v49 = vector3_4
			end
		else
			v49 = vector3_4
		end

		moveTo(facing(vector3_3 + cube(clone.size * 0.05) * meter, v49)) -- inferred equivalent call
		v13:Emit(1)
	end
end

local v46 = 0.4 * meter

local color3 = Color3.new(0.62, 0.58, 0.5)
local color4 = Color3.new(0.86, 0.76, 0.56)

local v47 = {
	stone = {
		chips = {
			count = { 30, 16 },
			speed = { 2, 12 },
			size = { 0.7, 1.6 },
			held = { 0.4, 0.8 },
			life = 1.8
		},
		shake = 0.45
	},
	plastic = {
		chips = {
			count = { 20, 8 },
			speed = { 2, 10 },
			size = { 0.6, 1.3 },
			held = { 0.35, 0.6 },
			life = 1.5
		},
		shake = 0.3
	},
	wood = {
		chips = {
			count = { 20, 12 },
			speed = { 2, 10 },
			size = { 0.6, 1.5 },
			held = { 0.35, 0.6 },
			life = 1.7
		},
		shake = 0.4
	},
	metal = {
		chips = {
			count = { 16, 10 },
			speed = { 3, 12 },
			size = { 0.5, 1.2 },
			held = { 0.3, 0.5 },
			life = 1.5
		},
		shake = 0.35
	},
	dirt = {
		chips = {
			count = { 18, 18 },
			speed = { 2, 10 },
			size = { 0.5, 1.2 },
			held = { 0.5, 1.1 },
			life = 1.3
		},
		up = 0.6,
		shake = 0.35
	},
	glass = {
		chips = {
			count = { 22, 4 },
			speed = { 2, 10 },
			size = { 0.35, 0.9 },
			held = { 0.2, 0.35 },
			life = 1.4
		},
		glint = {
			count = { 14, 6 }
		},
		shake = 0.3
	},
	leaves = {
		leaves = {
			count = { 16, 10 }
		}
	},
	cloth = {
		puff = {
			alpha = 0.5,
			life = 0.7,
			speed = { 5, 9 },
			size = 0.6,
			count = { 2, 2 }
		},
		fall = {
			count = { 4, 4 }
		}
	}
}

local function hammerKind(p, flag: boolean?): string
	local kind = p.type

	if flag or kind.name == "soil" then
		return "dirt"
	end

	if kind.sound == "glass" then
		return "glass"
	end

	if kind.sound == "metal" then
		return "metal"
	end

	if kind.name == "foliage" then
		return "leaves"
	end

	if kind.sound == "wood" then
		return "wood"
	end

	return if kind.name == "plastic" then "plastic" else "stone"
end

local function seq(...)
	local v48 = { ... }
	local numberSequenceKeypoints = {}

	for i = 1, #v48, 2 do
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(v48[i], v48[i + 1]))
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

local function many(p: number) -- 9 equivalent calls inferred from this helper
	if p <= 0 then
		return 0
	end

	return scaled(p) -- inferred equivalent call
end

local function streak(p) -- 2 equivalent calls inferred from this helper
	local v48 = emitter(attachment, p)
	v48.Orientation = Enum.ParticleOrientation.VelocityParallel
	v48.Rotation = NumberRange.new(90)
	v48.RotSpeed = NumberRange.new(0)
	v48.EmissionDirection = Enum.NormalId.Front
	return v48
end

local v48 = {}
local function hammerSet(p: string)
	local v49 = v48[p]

	if v49 then
		return v49
	end

	local v50 = v47[p]
	local v51 = {}

	if v50.knot then
		local knot = emitter(attachment, v5)
		local v53 = v46 * v50.knot.size
		knot.Speed = NumberRange.new(0)
		knot.RotSpeed = NumberRange.new(0)
		knot.Size = seq(0, v53 * 0.35, 0.3, v53 * 2.4, 1, v53 * 3.2)
		knot.Transparency = seq(0, v50.knot.alpha, 1, 1)
		knot.Lifetime = NumberRange.new(0.18, 0.26)
		v51.knot = knot
	end

	if v50.puff then
		local puff = emitter(attachment, v4)
		local v53 = v46 * v50.puff.size
		local alpha = v50.puff.alpha
		puff.Size = seq(0, v53 * 0.3, 0.25, v53 * 1.7, 1, v53 * 2.8)
		puff.Transparency = seq(0, 1, 0.05, alpha, 0.45, alpha + (1 - alpha) * 0.3, 1, 1)
		puff.Lifetime = NumberRange.new(v50.puff.life * 0.6, v50.puff.life)
		puff.Speed = NumberRange.new(v50.puff.speed[1] * meter, v50.puff.speed[2] * meter)

		puff.Drag = 9
		puff.Acceleration = Vector3.new(0, -1 * meter, 0)
		puff.SpreadAngle = Vector2.new(40, 40)
		puff.EmissionDirection = Enum.NormalId.Front
		puff.RotSpeed = NumberRange.new(-15, 15)
		v51.puff = puff
	end

	if v50.fall then
		local fall = emitter(attachment, v7)
		fall.Size = seq(0, 0.1 * meter, 1, 0.4 * meter)
		fall.Transparency = seq(0, 0.55, 1, 1)
		fall.Lifetime = NumberRange.new(1, 1.8)
		fall.Speed = NumberRange.new(0.2 * meter, 1.2 * meter)
		fall.Drag = 1.5
		fall.Acceleration = Vector3.new(0, -2.5 * meter, 0)
		fall.SpreadAngle = Vector2.new(25, 25)
		fall.EmissionDirection = Enum.NormalId.Front
		v51.fall = fall
	end

	if v50.bits then
		local bits = streak(v10) -- inferred equivalent call
		local size = v50.bits.size
		bits.Size = seq(0, size, 0.7, size * 0.8, 1, 0)
		bits.Transparency = seq(0, 0, 0.8, 0, 1, 1)
		bits.Lifetime = NumberRange.new(v50.bits.life * 0.6, v50.bits.life * 1.3)
		bits.Speed = NumberRange.new(v50.bits.speed[1] * meter, v50.bits.speed[2] * meter)
		bits.Drag = 1
		bits.SpreadAngle = Vector2.new(40, 40)
		v51.bits = bits
	end

	if v50.core then
		local core = emitter(attachment, v8)
		core.LightEmission = 1
		core.LightInfluence = 0
		core.ZOffset = 2
		core.Brightness = 6
		core.Speed = NumberRange.new(0)
		core.RotSpeed = NumberRange.new(-40, 40)
		core.Color = ColorSequence.new(Color3.new(1, 1, 0.95), Color3.new(1, 0.8, 0.5))
		core.Size = seq(0, 0.25 * meter, 1, 0.5 * meter)
		core.Transparency = seq(0, 0, 1, 1)
		core.Lifetime = NumberRange.new(0.05, 0.08)
		v51.core = core
	end

	if v50.glint then
		local glint = streak(v10) -- inferred equivalent call
		glint.LightEmission = 0.8
		glint.LightInfluence = 0.4
		glint.ZOffset = 1
		glint.Brightness = 2
		glint.Color = ColorSequence.new(Color3.new(0.9, 0.97, 1))
		glint.Size = seq(0, 0.16, 1, 0.02)
		glint.Transparency = seq(0, 0.1, 0.25, 0.6, 0.5, 0.1, 1, 1)
		glint.Lifetime = NumberRange.new(0.15, 0.4)
		glint.Speed = NumberRange.new(2 * meter, 7 * meter)
		glint.Drag = 1.5
		glint.SpreadAngle = Vector2.new(50, 50)
		v51.glint = glint
	end

	if v50.ring then
		local ring = emitter(attachment, v11)
		ring.Speed = NumberRange.new(0)
		ring.RotSpeed = NumberRange.new(0)
		ring.Color = ColorSequence.new(Color3.new(0.9, 0.88, 0.84))
		ring.Size = seq(0, 0.2 * meter, 1, 1.2 * meter)
		ring.Transparency = seq(0, 0.35, 1, 1)
		ring.Lifetime = NumberRange.new(0.14)
		v51.ring = ring
	end

	v48[p] = v51
	return v51
end

local function outOf(vector: Vector3, vector3_3: Vector3) -- 4 equivalent calls inferred from this helper
	local dot = vector:Dot(vector3_3)

	if dot < 0.2 then
		vector += vector3_3 * (0.2 - dot)
	end

	return vector.Unit
end

local function faceDust(fall, vector3_3: Vector3, vector3_4: Vector3, p: number, p2: number)
	if p2 <= 0 then
		return
	end

	local v49

	if math.abs(vector3_4.Y) < 0.7 then
		v49 = ((Vector3.new(0, -1, 0) + vector3_4 * vector3_4.Y).Unit + vector3_4 * 0.35).Unit
	else
		v49 = vector3_4
	end

	local v50 = math.min(3, p2)

	for _ = 1, v50 do
		moveTo(facing(vector3_3 + tangentJitter(vector3_4, p), v49)) -- inferred equivalent call

		fall:Emit((math.max(1, p2 // v50)))
	end
end

fn = function(vector3_3: Vector3, vector3_4: Vector3, vector3_5: Vector3, data, p: number, flag: boolean, flag2: boolean?, flag3: boolean?)
	local kind = data.type
	local v49

	if flag2 or kind.name == "soil" then
		v49 = "dirt"
	elseif kind.sound == "glass" then
		v49 = "glass"
	elseif kind.sound == "metal" then
		v49 = "metal"
	elseif kind.name == "foliage" then
		v49 = "leaves"
	elseif kind.sound == "wood" then
		v49 = "wood"
	elseif kind.name == "plastic" then
		v49 = "plastic"
	else
		v49 = "stone"
	end

	local v50 = v47[v49]
	local v51 = hammerSet(v49)
	local color5 = data.color
	local v52 = math.clamp(p / v46, 0.15, 1)
	local v53 = flag and 1 or 2
	local v54 = -10 * ParticleSim.gravityScale()
	local v55

	if vector3_5.Magnitude > 0.001 then
		v55 = vector3_5.Unit
	else
		v55 = -vector3_4
	end

	local v56 = reflect(v55, vector3_4) -- inferred equivalent call
	local v57 = outOf(vector3_4 + v56 * 0.35 + Vector3.new(0, 1, 0) * (v50.up or 0.15), vector3_4) -- inferred equivalent call
	local v58 = vector3_3 + vector3_4 * (0.05 * meter)
	local v59

	if v49 == "metal" then
		v59 = color2
	elseif v49 == "dirt" then
		v59 = color5:Lerp(color2, 0.35)
	else
		v59 = lighten(color5) -- inferred equivalent call
	end

	local function chips()
		local chips2 = v50.chips

		if chips2 then
			local v60 = if flag then chips2.size else chips2.held
			local v61 = (flag or flag2) and 1 or 0.6
			local v62

			if flag2 then
				if v46 * 1.2 < p then
					v62 = 60
				else
					v62 = chips2.count[v53] * v52
				end
			else
				v62 = chips2.count[v53] * v52
			end

			for _ = 1, many(v62) do -- inferred equivalent call
				local number = random:NextNumber()
				local v63 = number * number * number
				local v64 = outOf(v57 + random:NextUnitVector() * 0.75, vector3_4) -- inferred equivalent call
				spawnChip( -- inferred equivalent call
					v2,
					data,
					v58 + tangentJitter(vector3_4, p * (flag and 0.7 or 0.3)), -- inferred equivalent call
					v64 * ((chips2.speed[1] + (chips2.speed[2] - chips2.speed[1]) * v63) * v61),
					rnd(chips2.life * 0.7, chips2.life * 1.2) + v63, -- inferred equivalent call
					rnd(v60[1], v60[2]) * 0.05, -- inferred equivalent call
					rnd(-12, 12) -- inferred equivalent call
				)
			end
		end
	end

	if flag3 then
		chips()

		if v50.shake then
			BattleFX.shake(vector3_3, v50.shake, 5, 12)
		end
	else
		if v51.knot and v50.knot.count[v53] > 0 then
			v51.knot.Color = ColorSequence.new(v59)
			moveTo(CFrame.new(vector3_3 + vector3_4 * (0.08 * meter))) -- inferred equivalent call
			v51.knot:Emit(v50.knot.count[v53])
		end

		if v51.puff then
			v51.puff.Color = ColorSequence.new(Color3.new(v59.R * 0.7, v59.G * 0.7, v59.B * 0.7), v59)

			for _ = 1, many(v50.puff.count[v53] * v52) do -- inferred equivalent call
				moveTo(facing( -- inferred equivalent call
					v58 + tangentJitter(vector3_4, p * 0.5), -- inferred equivalent call
					outOf(vector3_4 + v56 * 0.2 + Vector3.new(0, 1, 0) * (v50.up or 0) * 0.5, vector3_4) -- inferred equivalent call
				))
				v51.puff:Emit(1)
			end
		end

		if v51.fall then
			v51.fall.Color = ColorSequence.new(v59)
			faceDust(v51.fall, v58, vector3_4, p * 0.6, many(v50.fall.count[v53] * v52)) -- inferred equivalent call
		end

		chips()

		if v50.leaves then
			for _ = 1, many(v50.leaves.count[v53] * v52) do -- inferred equivalent call
				local v61 = outOf(v57 + random:NextUnitVector() * 0.9, vector3_4) -- inferred equivalent call
				local v62 = rnd(0.4, 0.8) * 0.05 -- inferred equivalent call
				ParticleSim.spawn(
					v2,
					v58 + tangentJitter(vector3_4, p * 0.8), -- inferred equivalent call
					v61 * rnd(0.8, 3), -- inferred equivalent call
					rnd(1.2, 2.2), -- inferred equivalent call
					color5,
					v62,
					v62,
					-2.5,
					-2.5,
					rnd(-4, 4), -- inferred equivalent call
					0,
					1,
					1,
					0,
					0,
					data.material,
					data.transparency,
					data.variant
				)
			end
		end

		if v51.bits then
			local v60

			if v49 == "wood" then
				v60 = color5:Lerp(color4, 0.4)
			else
				v60 = Color3.new(color5.R * 0.65, color5.G * 0.65, color5.B * 0.65)
			end

			v51.bits.Color = ColorSequence.new(v60)
			v51.bits.Acceleration = Vector3.new(0, v54 * meter, 0)
			moveTo(facing(v58, v57)) -- inferred equivalent call
			v51.bits:Emit(many(v50.bits.count[v53] * v52)) -- inferred equivalent call
		end

		if v51.core then
			moveTo(CFrame.new(vector3_3 + vector3_4 * (0.1 * meter))) -- inferred equivalent call
			v51.core:Emit(2)
			BattleFX.flash(vector3_3 + vector3_4 * (0.3 * meter), 4 * meter, 0.08, 2)
		end

		if v51.glint then
			v51.glint.Acceleration = Vector3.new(0, v54 * meter, 0)
			moveTo(facing(v58, v57)) -- inferred equivalent call
			v51.glint:Emit(many(v50.glint.count[v53] * v52)) -- inferred equivalent call
		end

		if flag2 then
			GroundMarks.bullet(vector3_3, vector3_4)
		end

		if v50.shake and (flag or flag2) then
			BattleFX.shake(vector3_3, v50.shake, 5, 12)
		end
	end
end

fn2 = function(vector3_3: Vector3, vector3_4: Vector3, vector: Vector3)
	local cloth = v47.cloth
	local v49 = hammerSet("cloth")
	local v50

	if vector.Magnitude > 0.001 then
		v50 = vector.Unit
	else
		v50 = -vector3_4
	end

	v49.puff.Color = ColorSequence.new(color3:Lerp(Color3.new(0, 0, 0), 0.25), color3)

	for i = 1, many(cloth.puff.count[1]) do -- inferred equivalent call
		local v52

		if i == 1 then
			v52 = (v50 + Vector3.new(0, 0.3, 0)).Unit
		else
			v52 = (vector3_4 + Vector3.new(0, 0.4, 0)).Unit
		end

		moveTo(facing(vector3_3, v52)) -- inferred equivalent call
		v49.puff:Emit(1)
	end

	v49.fall.Color = ColorSequence.new(color3)
	faceDust(v49.fall, vector3_3, vector3_4, 0.15 * meter, many(cloth.fall.count[1])) -- inferred equivalent call
end

local UserInputService = game:GetService("UserInputService")
local v49 = UserInputService.TouchEnabled

if v49 then
	local UserInputService2 = game:GetService("UserInputService")
	v49 = not UserInputService2.KeyboardEnabled
end

local function feel(vector3_3: Vector3, p: number, p2, color5: Color3, data)
	local currentCamera = workspace.CurrentCamera
	local v50 = (vector3_3 - currentCamera.CFrame.Position).Magnitude / meter

	if data then
		BattleFX.shake(vector3_3, (p * 0.9 + 0.6) * data.shake, data.jolt, data.rumble)
		BattleFX.kick(vector3_3, data.kick * math.min(p / data.refSize, 1.4), data.kickReach)

		local v51 = vector3_3 - currentCamera.CFrame.Position
		local v52 = math.clamp(
			((not (v51.Magnitude > 0.01) and 1 or currentCamera.CFrame.LookVector:Dot(v51.Unit)) - 0.2) / 0.6,
			0,
			1
		)
		local v53 = v52 * 0.75 + 0.25
		local v54 = math.clamp(1 - v50 / data.glare, 0, 1)
		local v55 = math.clamp(1 - v50 / data.exposure, 0, 1)
		BattleFX.glare(v54 * v54 * v53 * data.glareGain, v55 * (v52 * 0.7 + 0.3) * data.glareGain)
	else
		BattleFX.shake(vector3_3, p * 0.9 + 0.6, 40, 160)
	end

	local v51 = math.clamp(1 - v50 / p2.grit, 0, 1)

	if v51 > 0 then
		BattleFX.grit(v51, color5)
		VoxelSound.concussion(v51)
	end
end

local units = {}
local v50 = v49 and 16 or 24
local count2 = v49 and 9 or 14
local v52 = {
	rise = 2.4,
	burst = v49 and 3 or 6,
	radius = 0.7,
	duration = 35,
	puffSize = 1.25,
	puffLife = 1.6,
	puffSpeed = 1.6,
	skirt = 1.7,
	mark = 1.5,
	burn = 26
}
local count = 0
local v53 = {
	shake = 1,
	jolt = 28,
	rumble = 110,
	kick = 2.1,
	kickReach = 28,
	refSize = 0.55,
	glare = 24,
	exposure = 70,
	glareGain = 0.85
}

local v54 = {
	shake = 1.1,
	jolt = 90,
	rumble = 320,
	kick = 3.2,
	kickReach = 70,
	refSize = 2.2,
	glare = 80,
	exposure = 220,
	glareGain = 1
}
local v55 = {
	shake = 1.35,
	jolt = 50,
	rumble = 160,
	kick = 2.6,
	kickReach = 35,
	refSize = 1.2,
	glare = 40,
	exposure = 110,
	glareGain = 1
}

for i = -1, 1 do
	for j = -1, 1 do
		for k = -1, 1 do
			local v56 = math.abs(i) + math.abs(j) + math.abs(k)

			if v56 == 1 or v56 == 2 then
				table.insert(units, Vector3.new(i, j, k).Unit)
			end
		end
	end
end

local raycastParams5 = RaycastParams.new()
raycastParams5.IgnoreWater = true
local function grenadeSurface(origin: Vector3)
	local world = ClientWorld.world
	assert(world, "[VoxelFX] the client voxel world is not built")
	local vehicleHulls = workspace:FindFirstChild("VehicleHulls")
	local includeInstances

	if vehicleHulls then
		includeInstances = { workspace.Terrain, vehicleHulls }
	else
		includeInstances = { workspace.Terrain }
	end

	raycastParams5.IncludeInstances = includeInstances
	local total = Vector3.new(0, 0, 0)
	local v57 = 1e999
	local v58 = nil
	local v59 = nil

	for _, v60 in units do
		local v61 = nil
		local v62 = nil
		local v63 = 1e999
		local raycast, v64, _, v65 = VoxelCore.raycast(world, origin, v60, 1.4)

		if raycast and v64 then
			v62 = v64
			v61 = raycast
			v63 = v65
		end

		local raycastResult = workspace:Raycast(origin, v60 * 1.4, raycastParams5)

		if raycastResult and raycastResult.Distance < v63 then
			v61 = raycastResult.Position
			v62 = raycastResult.Normal
			v63 = raycastResult.Distance
		end

		if not (v61 and v62) then
			continue
		end

		local v66 = 1 - v63 / 1.4
		total += v62 * (v66 * v66 + 0.05)

		if not (v63 < v57) then
			continue
		end

		v59 = v62
		v58 = v61
		v57 = v63
	end

	if total.Magnitude < 0.001 then
		return nil, nil, nil
	end

	return total.Unit, v58, v59
end

local function blast(vector3_3: Vector3, p: number, list, vector3_4: Vector3?, flag: boolean, vector3_5: Vector3?, p2: string?, flag2: boolean?, p3: string)
	local v56

	if vector3_4 and not vector3_5 then
		v56 = -vector3_4
		local raycastResult = workspace:Raycast(
			vector3_3 - vector3_4 * (2 * meter),
			vector3_4 * (4 * meter),
			raycastParams3
		)

		if raycastResult then
			v56 = raycastResult.Normal
		end
	else
		v56 = vector3_5 or Vector3.new(0, 1, 0)
	end

	local v57 = p2 == "Grenade"
	local v58 = false
	local v59 = nil
	local v60 = nil

	if v57 then
		local v61, v62
		v56, v61, v62 = grenadeSurface(vector3_3)

		if v56 then
			v60 = v62
			v59 = v61
		else
			v58 = true
			v56 = Vector3.new(0, 1, 0)
		end
	end

	local v61 = v58 and 180 or 80
	local v62 = p2 == "AutoCannon"
	local v63 = p2 == "HeavyGun" or v62
	local v64

	if v57 then
		v64 = 1
	elseif v63 then
		v64 = math.max(p, 0.65) * (v62 and 1.5 or 1)
	else
		v64 = p
	end

	local v65 = v39[v64 >= 2 and 3 or v64 >= 1 and 2 or 1]

	local v66 = WorldConfig.blastRadius(v64) / (2.52 * meter) * (p2 == "Airstrike" and 1.35 or 1)
	local v67 = p2 == "Airstrike"
	local v68 = flag or v67

	local v69 = {
		life = v65.fire.life,
		size = v65.fire.size * v66 * (v67 and 2.4 or v68 and 2 or 1),
		count = 0,
		lean = false
	}
	local count3

	if v67 then
		count3 = v50
	end

	v69.count = count3
	local clone = table.clone(v65.smoke)
	clone.size *= v66
	local v71 = v66 * v66
	local v72 = math.sqrt(v66)
	local v73 = v65.column

	if v67 then
		v71 = math.min(v71, 1)
		clone.count = count2
		clone.size *= v52.puffSize
		clone.life *= v52.puffLife
		clone.speed = v52.puffSpeed
		count += 1
		v73 = count % (v49 and 3 or 2) ~= 1 and 0 or v73

		if v49 and p3 ~= "matter" then
			local now = os.clock()

			if now - (v25.strikeCoreAt or -1e999) < 0.15 then
				v69.lean = true
			else
				v25.strikeCoreAt = now
			end
		end
	end

	local detail = Quality.detail(vector3_3)
	v = math.max(detail, 0.1)

	if p3 ~= "matter" then
		local Detail = require(ReplicatedStorage.Voxel.Detail)
		Detail.mark(v67 and "bomb" or "blast", vector3_3)
	end

	if p3 ~= "flash" then
		ParticleSim.push(vector3_3, p)
	end

	if p3 ~= "matter" then
		local blastRadius = WorldConfig.blastRadius(p)
		local blastRadius2 = WorldConfig.blastRadius(v64)

		local v74 = nil
		local function later()
			v = math.max(detail, 0.1)
			debug.profilebegin("VFX.blast.ground")
			local raycastResult

			if not flag2 then
				raycastResult = workspace:Raycast(
						vector3_3 + v56 * 1,
						-v56 * (1 + blastRadius * 0.6),
						raycastParams4
					)
					or workspace:Raycast(
						vector3_3 + Vector3.new(0, 1, 0),
						Vector3.new(0, 1, 0) * -(1 + blastRadius * 0.6),
						raycastParams4
					)
			end

			if raycastResult then
				local scorch = GroundMarks.scorch
				local position = raycastResult.Position
				local normal = raycastResult.Normal
				local v75

				if v67 then
					v75 = blastRadius * v52.mark
				else
					v75 = blastRadius
				end

				scorch(position, normal, v75)

				if raycastResult.Instance == workspace.Terrain then
					if v67 then
						GroundFlatten.scorch(raycastResult.Position, v52.burn)
					else
						GroundFlatten.dirt(raycastResult.Position, (math.max(blastRadius * 0.75, 3)))
					end
				end
			end

			debug.profileend()
			debug.profilebegin("VFX.blast.smoke")

			if v63 then
				shellHit(vector3_3, v56, v74, not flag2, v62)
			elseif flag2 then
				smokeCloud(vector3_3, v56, clone, list, true)
			else
				smokeCloud(vector3_3, v56, clone, list)

				local v75 = blastRadius2 * (not v67 and 1.2 or v52.skirt)

				if v59 and v60 then
					BattleFX.skirt(v59, v60, v74, v75)
				elseif raycastResult then
					BattleFX.skirt(raycastResult.Position, raycastResult.Normal, v74, v75)
				end

				if v73 > 0 then
					local lerped = Color3.new(0.16, 0.15, 0.14):Lerp(v74, 0.25)

					if v67 then
						BattleFX.column(
							vector3_3 + Vector3.new(0, blastRadius2 * 0.3, 0),
							lerped,
							blastRadius2 * v52.radius,
							v52.duration,
							v52.rise,
							v52.burst
						)
					else
						BattleFX.column(
							vector3_3 + Vector3.new(0, blastRadius2 * 0.3, 0),
							lerped,
							blastRadius2 * 0.45,
							v73
						)
					end
				end
			end

			debug.profileend()
		end

		RunService.Heartbeat:Once(function()
			RunService.Heartbeat:Once(later)
		end)

		debug.profilebegin("VFX.blast.now")
		VoxelSound.explosion(p, vector3_3, v62 and "HeavyGun" or p2)
		v74 = dustColour(list)

		if v62 then
			BattleFX.shake(vector3_3, 0.38, 14, 60)
		elseif v63 then
			BattleFX.shake(vector3_3, 0.25, 10, 45)
		else
			local v75 = v74
			local v76

			if v57 then
				v76 = v53
			elseif v67 then
				v76 = v54
			elseif v68 then
				v76 = v55
			end

			feel(vector3_3, p, v65, v75, v76)
		end

		if v68 then
			local v75

			if v67 then
				v75 = blastRadius * 1.35
			else
				v75 = blastRadius
			end

			BattleFX.flash(vector3_3 + v56 * 2, v75 * 6, v65.flash * 2, 14)
			rocketCore(vector3_3, v56, v75, detail <= 0)
		else
			BattleFX.flash(vector3_3 + v56 * 2, blastRadius2 * 4, v65.flash)
		end

		if not v63 then
			blastFire(vector3_3, v69)
		end

		local v75 = math.ceil(v65.sparks[1] * v71)
		local v76 = v65.sparks[2] * v72
		v26 = false
		v19.Color = ColorSequence.new(Color3.new(1, 0.8, 0.5), Color3.new(1, 0.3, 0.12))
		v19.Size = NumberSequence.new(0.6, 0.05)
		v19.Transparency = NumberSequence.new(0, 0.4)
		v19.Lifetime = NumberRange.new(0.3, 1.4)
		v19.Speed = NumberRange.new(v76 * 1.5 * meter, v76 * 4 * meter)
		local vector2

		if flag2 then
			vector2 = Vector2.new(180, 180)
		elseif v57 then
			vector2 = Vector2.new(math.min(v61, 75), (math.min(v61, 75)))
		else
			vector2 = Vector2.new(70, 70)
		end

		v19.SpreadAngle = vector2
		v19.Acceleration = Vector3.new(0, -10 * ParticleSim.gravityScale() * meter, 0)
		v25.sparksAccel = Vector3.new(0, -10 * ParticleSim.gravityScale() * meter, 0)
		v19.EmissionDirection = Enum.NormalId.Front
		moveTo(facing(vector3_3, v56)) -- inferred equivalent call
		v19:Emit(not (detail > 0) and 0 or scaled(v75)) -- inferred equivalent call
		debug.profileend()
	end

	if p3 ~= "flash" then
		debug.profilebegin("VFX.blast.debris")
		local total = 0

		for i = 2, #list, 2 do
			total += list[i]
		end

		local v74 = math.ceil(v65.debris[1] * v71)
		local v75 = v65.debris[2] * v72

		if flag2 or detail <= 0 then
			v74 = 0
		elseif v67 and v49 then
			v74 = math.ceil(v74 * 0.5)
		end

		for _ = 1, many(v74) do -- inferred equivalent call
			local number = random:NextNumber()
			local v76 = number * number * number
			local v77 = 0.5 + v76 * 3
			local v78 = (0.4 + 0.6 * v76) * v75
			local v79

			if v57 and not v58 then
				v79 = (cube(1) + v56 * 0.7) * v78 -- inferred equivalent call
			else
				v79 = cube(1) * v78 + Vector3.new(0, v78 * 0.5, 0) -- inferred equivalent call
			end

			local v80 = rnd(-20, 20) -- inferred equivalent call
			local v81

			if total > 0 then
				v81 = Materials.Palette[pickFromMix(list, total)]
			end

			if v81 then
				spawnChip(v3, v81, vector3_3, v79, v77, rnd(0.6, 1) * 0.05, v80) -- inferred equivalent call
			else
				local v82 = rnd(0.03, 0.05) -- inferred equivalent call
				local v83 = rnd(0.2, 0.5) -- inferred equivalent call
				ParticleSim.spawn(
					v3,
					vector3_3,
					v79,
					v77,
					Color3.new(v83, v83, v83),
					v82,
					v82,
					-10,
					-10,
					v80,
					0,
					1,
					1,
					0,
					0
				)
			end
		end

		debug.profileend()
	end
end

fn4 = function(vector3_3: Vector3, size: number, p, dir: Vector3, vector3_4: Vector3?, flag: boolean)
	blast(vector3_3, size, p, dir, true, vector3_4, nil, flag, "flash")
end

function BattleFX.ownShell(p: number, at: Vector3, vector3_3: Vector3, p2: number, p3: string?)
	local shells = v25.shells

	if not shells then
		shells = {}
		v25.shells = shells
	end

	local now = os.clock()

	for k, v57 in shells do
		if now - v57.t > 3 then
			shells[k] = nil
		end
	end

	local world = ClientWorld.world
	assert(world, "[VoxelFX] the client voxel world is not built")
	local raycast, _, v57 = VoxelCore.raycast(world, at - vector3_3 * 2, vector3_3, 5)
	local v58 = raycast and { v57, 1 } or GroundHit.mix(at, WorldConfig.blastRadius(p2))
	shells[p] = { at = at, t = now }
	blast(at, p2, v58 or {}, vector3_3, false, nil, p3, false, "flash")
end

Remotes:WaitForChild("Explosion").OnClientEvent:Connect(function(vector3_3: Vector3, p: number, p2, p3: number?, vector3_4: Vector3?, p4: string?, _: number?, flag: boolean?, p5: number?, p6: number?)
	local shells = v25.shells

	if p6 and shells and p5 == LocalPlayer.UserId then
		local shell = shells[p6]
		shells[p6] = nil

		if shell and (shell.at - vector3_3).Magnitude < 12 then
			blast(vector3_3, p, p2, nil, false, vector3_4, p4, flag, "matter")
			return
		end
	end

	local v56

	if p3 then
		v56 = v36[p3] or p3
	end

	if p3 then
		v36[p3] = nil
	end

	local v57 = v56 and v37[v56]

	if v56 and v57 then
		v37[v56] = nil

		if (v57.at - vector3_3).Magnitude < 12 then
			blast(vector3_3, p, p2, nil, true, vector3_4, p4, flag, "matter")
			return
		end
	end

	local v58 = v56 and v30[v56]

	if v56 then
		removeRocket(v56)
	end

	local v59

	if v58 then
		v59 = v58.dir
	end

	blast(vector3_3, p, p2, v59, p3 ~= nil, vector3_4, p4, flag, "all")
end)

task.spawn(function()
	local localPlayer = Players.LocalPlayer

	while localPlayer:GetAttribute("JoinCovered") == true do
		localPlayer:GetAttributeChangedSignal("JoinCovered"):Wait()
	end

	local voxelAtmosphere = workspace:WaitForChild("VoxelAtmosphere", 10)
	assert(voxelAtmosphere, "[VoxelFX] workspace.VoxelAtmosphere (BattleFX) is missing")
	local ContentProvider = game:GetService("ContentProvider")
	ContentProvider:PreloadAsync({ voxelChips, voxelAtmosphere })
end)