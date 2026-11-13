local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Players = game:GetService("Players")
local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local Viewmodel = require(Voxel:WaitForChild("Viewmodel"))
local Movement = require(Voxel:WaitForChild("Movement"))
local TouchControls = require(Voxel:WaitForChild("TouchControls"))
local Keyframes = require(Voxel:WaitForChild("Keyframes"))
local VR = require(Voxel:WaitForChild("VR"))
local GameConfig = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("GameConfig"))
local Style = require(script.Parent.Style)

local newVector3 = Vector3.new

local cframe = CFrame.new(0, -5000, 0)

local v = {
	{ 0, Vector3.new(-0.8, -1.2, -2), true },
	{ 0.28, Vector3.new(-0.12, -0.72, -2.1), true },
	{ 0.45, Vector3.new(-0.12, -1.02, -2.15), true },
	{ 0.62, Vector3.new(-0.12, -0.72, -2.1) },
	{ 0.8, Vector3.new(-0.12, -1.02, -2.15), true },
	{ 0.97, Vector3.new(-0.12, -0.72, -2.1) },
	{ 1.15, Vector3.new(-0.12, -1.02, -2.15), true },
	{ 1.32, Vector3.new(-0.12, -0.72, -2.1) },
	{ 1.5, Vector3.new(-0.12, -1.02, -2.15), true },
	{ 1.85, Vector3.new(-0.5, -0.9, -2.2), true },
	{ 3, Vector3.new(-0.5, -0.9, -2.2), true }
}

local v2 = {
	{ 0, Vector3.new(1.1, -1.2, -1.9), true },
	{ 0.28, Vector3.new(0.14, -0.66, -2.05), true },
	{ 0.45, Vector3.new(0.14, -0.96, -2.1), true },
	{ 0.62, Vector3.new(0.14, -0.66, -2.05) },
	{ 0.8, Vector3.new(0.14, -0.96, -2.1), true },
	{ 0.97, Vector3.new(0.14, -0.66, -2.05) },
	{ 1.15, Vector3.new(0.14, -0.96, -2.1), true },
	{ 1.32, Vector3.new(0.14, -0.66, -2.05) },
	{ 1.5, Vector3.new(0.14, -0.96, -2.1), true },
	{ 1.88, Vector3.new(1.25, -1.55, -1.7), true },
	{ 2.08, Vector3.new(0.55, -0.32, -2.2), true },
	{ 2.2, Vector3.new(0.12, -0.95, -2.3), true },
	{ 2.6, Vector3.new(0.12, -0.98, -2.3), true },
	{ 2.85, Vector3.new(0.85, -0.68, -2.05), true },
	{ 3, Vector3.new(0.85, -0.68, -2.05), true }
}

local v3 = {
	{ 0, Vector3.new(-30, 8, 0), true },
	{ 1.88, Vector3.new(-30, 8, 0), true },
	{ 2.08, Vector3.new(-15, 15, 0), true },
	{ 2.2, Vector3.new(-68, 15, 0), true },
	{ 2.6, Vector3.new(-68, 15, 0), true },
	{ 2.85, Vector3.new(-30, 8, 0), true },
	{ 3, Vector3.new(-30, 8, 0), true }
}

local v4 = {
	{ 0, 0, true },
	{ 0.28, 0, true },
	{ 0.45, 0.12, true },
	{ 0.62, 0 },
	{ 0.8, 0.12, true },
	{ 0.97, 0 },
	{ 1.15, 0.12, true },
	{ 1.32, 0 },
	{ 1.5, 0.12, true },
	{ 1.7, 0, true },
	{ 3, 0, true }
}

local v5 = {
	{ 0, 0, true },
	{ 2.22, 0, true },
	{ 2.55, 1, true },
	{ 3, 1, true }
}

local v6 = {
	{ 0, 0 },
	{ 2.2, 0 },
	{ 2.6, 1, true },
	{ 3, 1, true }
}
local color = Color3.fromRGB(38, 70, 50)

local color2 = Color3.fromRGB(150, 158, 165)
local v7 = {
	{
		Vector3.new(0.34, 0.34, 0.95),
		Vector3.new(0, 0.22, -0.3),
		Color3.fromRGB(40, 44, 50),
		Enum.Material.SmoothPlastic
	},
	{ Vector3.new(0.38, 0.38, 0.22), Vector3.new(0, 0.22, -0.55), color, Enum.Material.Neon },
	{ Vector3.new(0.2, 0.2, 0.26), Vector3.new(0, 0.22, 0.28), color2, Enum.Material.SmoothPlastic },
	{
		Vector3.new(0.14, 0.14, 0.3),
		Vector3.new(0, 0.22, -0.92),
		color2,
		Enum.Material.SmoothPlastic
	}
}

local flag = false
local v8 = false
local lastTime = 0
local v9 = 0
local total = 0
local hands = { stow = 0, weight = 0, right = Vector3.new(0, 0, 0), left = Vector3.new(0, 0, 0) }
local v10 = CFrame.identity
local v11 = 0
local v12 = 0
local v13 = false
local v14 = -1
local v15 = 0
local v16 = {}
local v17 = {}

local function build()
	local VIEW_SCALE = Viewmodel.VIEW_SCALE

	if #v16 == 0 then
		for k, v18 in v7 do
			local reviveInjector = Instance.new("Part")
			reviveInjector.Name = "ReviveInjector"
			reviveInjector.Anchored = true
			reviveInjector.CanCollide = false
			reviveInjector.CanQuery = false
			reviveInjector.CanTouch = false
			reviveInjector.CastShadow = false
			reviveInjector.Color = v18[3]
			reviveInjector.Material = v18[4]
			reviveInjector.CFrame = cframe
			v16[k] = reviveInjector
			v17[k] = cframe
		end
	end

	if v15 ~= VIEW_SCALE then
		v15 = VIEW_SCALE

		for k, v18 in v7 do
			v16[k].Size = v18[1] * VIEW_SCALE
		end
	end
end

local function show(flag2: boolean)
	local currentCamera

	if flag2 then
		currentCamera = workspace.CurrentCamera
	end

	for _, v18 in v16 do
		if v18.Parent ~= currentCamera then
			v18.Parent = currentCamera
		end
	end
end

local function finish() -- 1 equivalent call inferred from this helper
	RunService:UnbindFromRenderStep("ReviveHandsPose")
	RunService:UnbindFromRenderStep("ReviveHandsProp")
	v8 = false
	Viewmodel.hands = nil
	Movement.eyeDrop = 0
	Movement.jobScale = 1
	total = 0

	for _, v18 in v16 do
		if v18.Parent ~= nil then
			v18.Parent = nil
		end
	end
end

local function stepPose(p: number)
	local v18 = math.min(p, 0.1)
	local v19 = v9
	local v20

	if flag then
		v20 = v18
	else
		v20 = -v18
	end

	v9 = math.clamp(v19 + v20 / 0.2, 0, 1)

	if flag or not (v9 <= 0) then
		local v21 = math.min((os.clock() - lastTime) * 3 / GameConfig.REVIVE.HOLD, 3)
		local v22 = v9 * v9 * (3 - v9 * 2)
		local sample = Keyframes.sample(v2, v21)
		local sample2 = Keyframes.sample(v, v21)

		local character = Players.LocalPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local v23 = not humanoidRootPart and Vector3.new(0, 0, 0) or humanoidRootPart.AssemblyLinearVelocity
		local v24 = not flag and 0 or math.clamp(Vector2.new(v23.X, v23.Z).Magnitude / 5, 0, 1)
		total += (v24 - total) * (1 - math.exp(v18 * -8))
		Movement.jobScale = not flag and 1 or GameConfig.REVIVE.DRAG_WALK
		local v25 = total * math.clamp((1.7 - v21) / 0.2, 0, 1)

		if v25 > 0.001 then
			local vector3 = newVector3(0, 0, math.sin(os.clock() * 1.6 * 2 * 3.141592653589793) * 0.07)
			sample = sample:Lerp(Vector3.new(0.42, -1.08, -1.7) + vector3, v25)
			sample2 = sample2:Lerp(Vector3.new(-0.42, -1.12, -1.75) + vector3, v25)
		end

		hands.stow = v22
		hands.weight = v22
		hands.right = sample
		hands.left = sample2
		v10 = Keyframes.pose(sample + newVector3(0, (1 - v22) * -2.2, 0), Keyframes.sample(v3, v21))
		v11 = Keyframes.sample(v6, v21)
		v12 = Keyframes.sample(v5, v21)
		v13 = v21 >= 1.88
		Movement.eyeDrop = ((1 - total * 0.45) * 1.7 + Keyframes.sample(v4, v21) * (1 - v25)) * v22
		Viewmodel.hands = hands
	else
		finish() -- inferred equivalent call
	end
end

local function stepProp()
	if not v8 then
		return
	end

	if Viewmodel.current == nil or not v13 then
		for _, v18 in v16 do
			if v18.Parent ~= nil then
				v18.Parent = nil
			end
		end
	else
		build()
		local currentCamera = workspace.CurrentCamera

		for _, v18 in v16 do
			if v18.Parent ~= currentCamera then
				v18.Parent = currentCamera
			end
		end

		local VIEW_SCALE = Viewmodel.VIEW_SCALE
		local v18 = workspace.CurrentCamera.CFrame * CFrame.new(v10.Position * VIEW_SCALE) * v10.Rotation

		for k, v19 in v7 do
			local v20

			if k == 3 then
				v20 = v19[2] + newVector3(0, 0, v12 * -0.16)
			else
				v20 = v19[2]
			end

			v17[k] = v18 * CFrame.new(v20 * VIEW_SCALE)
		end

		workspace:BulkMoveTo(v16, v17, Enum.BulkMoveMode.FireCFrameChanged)
		local v19 = math.round(v11 * 10) / 10

		if v19 ~= v14 then
			v14 = v19
			v16[2].Color = color:Lerp(Style.GOOD, v19)
		end
	end
end

local ReviveHands = {}

function ReviveHands.start()
	TouchControls.noAutoFire = true

	if VR.on() then
		return
	end

	flag = true
	lastTime = os.clock()

	if not v8 then
		v8 = true
		RunService:BindToRenderStep("ReviveHandsPose", Enum.RenderPriority.Camera.Value + 3, stepPose)
		RunService:BindToRenderStep("ReviveHandsProp", Enum.RenderPriority.Camera.Value + 5, stepProp)
	end
end

function ReviveHands.stop()
	TouchControls.noAutoFire = false
	flag = false
end

function ReviveHands.wantsWeapon(): boolean
	local current = Viewmodel.current
	return current ~= nil and current.firing == true
end

return ReviveHands