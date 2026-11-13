local WorldConfig = require(script.Parent:WaitForChild("WorldConfig"))
local GroundMarks = require(script.Parent:WaitForChild("GroundMarks"))
local Quality = require(script.Parent:WaitForChild("Quality"))

local meter = WorldConfig.METER

local v = {}
local v2 = nil
local particleEmitter = nil
local particleEmitter2 = nil

local function build()
	local voxelImpactFX = Instance.new("Folder")
	voxelImpactFX.Name = "VoxelImpactFX"
	voxelImpactFX.Parent = workspace
	local emitters = Instance.new("Part")
	emitters.Name = "Emitters"
	emitters.Anchored = true
	emitters.CanCollide = false
	emitters.CanQuery = false
	emitters.CanTouch = false
	emitters.Transparency = 1
	emitters.Size = Vector3.new(0.2, 0.2, 0.2)
	emitters.Parent = voxelImpactFX
	local attachment = Instance.new("Attachment")
	attachment.Parent = emitters

	particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = "rbxassetid://113220068578316"
	particleEmitter.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid2x2
	particleEmitter.FlipbookMode = Enum.ParticleFlipbookMode.OneShot
	particleEmitter.LightEmission = 0.2
	particleEmitter.LightInfluence = 0
	particleEmitter.Brightness = 1.3
	particleEmitter.ZOffset = 0.5
	particleEmitter.Size = NumberSequence.new(0.6000000000000001, 0.75)
	particleEmitter.Lifetime = NumberRange.new(0.09)
	particleEmitter.Speed = NumberRange.new(0)
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.Rate = 0
	particleEmitter.Parent = attachment

	particleEmitter2 = Instance.new("ParticleEmitter")
	particleEmitter2.Texture = "rbxassetid://9841260273"
	particleEmitter2.LightEmission = 1
	particleEmitter2.LightInfluence = 0
	particleEmitter2.Brightness = 3
	particleEmitter2.ZOffset = 0.5
	particleEmitter2.Orientation = Enum.ParticleOrientation.VelocityParallel
	particleEmitter2.Rotation = NumberRange.new(90)
	particleEmitter2.Color = ColorSequence.new(Color3.new(1, 0.85, 0.55), Color3.new(1, 0.5, 0.2))
	particleEmitter2.Size = NumberSequence.new(0.22, 0.04)
	particleEmitter2.Lifetime = NumberRange.new(0.08, 0.2)
	particleEmitter2.Speed = NumberRange.new(6 * meter, 12 * meter)
	particleEmitter2.SpreadAngle = Vector2.new(30, 30)
	particleEmitter2.Acceleration = Vector3.new(0, -10 * meter, 0)
	particleEmitter2.Drag = 2
	particleEmitter2.EmissionDirection = Enum.NormalId.Front
	particleEmitter2.Rate = 0
	particleEmitter2.Parent = attachment
	return emitters
end

local ImpactFX = {}

function ImpactFX.listen(callback)
	table.insert(v, callback)
end

function ImpactFX.bullet(vector3: Vector3, vector3_2: Vector3, vector: Vector3, flag: boolean)
	local v3 = v2 or build()
	v2 = v3
	local v4 = vector - vector3_2 * (2 * vector:Dot(vector3_2))
	local v5 = vector3 + vector3_2 * 0.08
	v3.CFrame = CFrame.lookAt(v5, v5 + (v4 + vector3_2).Unit)
	particleEmitter:Emit(1)

	particleEmitter2:Emit((math.max(1, Quality.count(math.random(3, 5), vector3, 1))))

	if flag then
		GroundMarks.bullet(vector3, vector3_2)
	end

	for _, v6 in v do
		v6(vector3, vector3_2, flag)
	end
end

return ImpactFX