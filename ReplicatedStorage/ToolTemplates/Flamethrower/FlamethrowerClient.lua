local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local parent = script.Parent
local muzzleAttachment = parent:WaitForChild("Handle"):WaitForChild("MuzzleAttachment")
local LocalPlayer = Players.LocalPlayer
local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local Viewmodel = require(Voxel:WaitForChild("Viewmodel"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local VR = require(ReplicatedStorage2:WaitForChild("Voxel"):WaitForChild("VR"))
local VoxelSound = require(Voxel:WaitForChild("VoxelSound"))
local FlameStream = require(Voxel:WaitForChild("FlameStream"))
local FlameVisuals = require(Voxel:WaitForChild("FlameVisuals"))
local TouchControls = require(Voxel:WaitForChild("TouchControls"))
local fireFlame = Voxel:WaitForChild("Remotes"):WaitForChild("FireFlame")

local random = Random.new()

local v = 0
local v2 = 0
local total = 1e999
local cframe = nil

local function shakeUndo()
	if cframe then
		workspace.CurrentCamera.CFrame *= cframe:Inverse()
		cframe = nil
	end
end
local function shake(p: number)
	total += p

	if total >= 0.035 then
		return
	end

	local v3 = 1 - total / 0.035
	cframe = CFrame.Angles(math.rad(v * v3), math.rad(v2 * v3), 0)
	local currentCamera = workspace.CurrentCamera

	if VR.on() then
		cframe = nil
	else
		currentCamera.CFrame *= cframe
	end
end

local HttpService = game:GetService("HttpService")
local guid = HttpService:GenerateGUID(false)
local v3 = "FlamerShakeUndo" .. guid
local v4 = "FlamerShake" .. guid
local v5 = false
local count = 0
local function bindShake()
	count += 1

	if v5 or not parent:IsDescendantOf(game) then
		return
	end

	v5 = true
	RunService:BindToRenderStep(v3, Enum.RenderPriority.Camera.Value - 3, shakeUndo)
	RunService:BindToRenderStep(v4, Enum.RenderPriority.Camera.Value + 3, shake)
end
parent.Equipped:Connect(bindShake)
parent.Unequipped:Connect(function()
	count += 1
	local v6 = count
	task.delay(1, function()
		if v6 == count and v5 and parent.Parent ~= LocalPlayer.Character then
			v5 = false
			RunService:UnbindFromRenderStep(v3)
			RunService:UnbindFromRenderStep(v4)

			if cframe then
				workspace.CurrentCamera.CFrame *= cframe:Inverse()
				cframe = nil
			end
		end
	end)
end)

if parent.Parent == LocalPlayer.Character then
	bindShake()
end

parent.Destroying:Connect(function()
	RunService:UnbindFromRenderStep(v3)
	RunService:UnbindFromRenderStep(v4)

	if cframe then
		workspace.CurrentCamera.CFrame *= cframe:Inverse()
		cframe = nil
	end

	FlameVisuals.own(Vector3.new(0, 0, 0), Vector3.new(0, 0, 1), false)
	VoxelSound.flamerOwn(false, false)
end)

local v6 = Viewmodel.new(parent, {
	name = "FLAMETHROWER",
	weight = 1.3,
	hold = CFrame.new(0.66, -0.9, -1.8) * CFrame.Angles(0.03490658503988659, 0.05235987755982989, 0.017453292519943295),
	rightHand = Vector3.new(0, -0.36, 0.22),
	leftHand = Vector3.new(0, -0.6, -0.52),
	armThickness = 0.7,
	muzzle = muzzleAttachment.Position,
	aimPoint = Vector3.new(0, 0.35, 0),
	aimDistance = 0.9,
	aimFov = 70,
	aimMove = 1,
	reach = 3.6,
	sprintHold = CFrame.new(-0.2, -1.35, -1.95) * CFrame.Angles(
		-0.5113814708343386,
		1.08035880698449,
		0.46600291028248597
	),
	hipKick = Vector3.new(0.01, 0.008, 0.05),
	hipKickRot = Vector3.new(0.35, 0.3, 0.4),
	aimKick = Vector3.new(0.01, 0.008, 0.05),
	aimKickRot = Vector3.new(0.35, 0.3, 0.4),
	recoilTime = 0.12,
	punch = 0.15,
	flash = false
})

v6.aimBlocked = true

local v7 = parent:GetAttribute("Fuel") or 0
local function showFuel() -- 4 equivalent calls inferred from this helper
	v6:setAmmo((math.floor(v7 + 0.5)))
end

showFuel() -- inferred equivalent call
local v8 = 0
parent:GetAttributeChangedSignal("Fuel"):Connect(function()
	local fuel = parent:GetAttribute("Fuel") or 0

	if not (os.clock() - v8 > 0.5) then
		fuel = math.min(v7, fuel)
	end

	v7 = fuel
	showFuel() -- inferred equivalent call
end)

parent.Equipped:Connect(function()
	v7 = parent:GetAttribute("Fuel") or 0
	showFuel() -- inferred equivalent call
end)

local firing = false
local v9 = 0

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local v10 = {}
local v11 = -1e999
local function excludes()
	local now = os.clock()

	if now - v11 < 1 then
		return v10
	end

	v11 = now
	local excludeInstances = { workspace.CurrentCamera }

	if LocalPlayer.Character then
		table.insert(excludeInstances, LocalPlayer.Character)
	end

	for _, childName in { "VoxelChips", "VoxelLoose", "VoxelTracers", "VoxelFlames" } do
		local child = workspace:FindFirstChild(childName)

		if child then
			table.insert(excludeInstances, child)
		end
	end

	local v12 = #excludeInstances == #v10

	for k, v13 in excludeInstances do
		v12 = v12 and v10[k] == v13
	end

	if not v12 then
		v10 = excludeInstances
		raycastParams.ExcludeInstances = excludeInstances
	end

	return v10
end

local function aim(p)
	local currentCamera = workspace.CurrentCamera
	local v12 = currentCamera.ViewportSize * 0.5
	local ray = VR.ray(currentCamera, v12.X, v12.Y)
	local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 40, raycastParams)
	local v13

	if raycastResult then
		v13 = raycastResult.Position
	else
		v13 = ray.Origin + ray.Direction * 40
	end

	local muzzle = v6:muzzle(p)
	local v14 = v13 - muzzle

	if (v13 - ray.Origin).Magnitude < 6 or v14.Magnitude < 0.5 then
		return muzzle, ray.Direction
	end

	local timeTo = FlameStream.timeTo((math.min(v14.Magnitude, 32)))
	return muzzle, (v14 + Vector3.new(0, 0.5 * FlameStream.GRAVITY * timeTo * timeTo, 0)).Unit
end

local total2 = 0
local function step(p: number)
	local v12 = firing and v6.active

	if v12 then
		if v7 >= 0.55 then
			v12 = v6:ready()
		else
			v12 = false
		end
	end

	v6.firing = firing
	v6.pinVisible = v7 > 0 or parent:GetAttribute("Infinite") == true
	total2 += p
	v6.pinDelta = CFrame.new(0, math.sin(total2 * 37) * 0.012 + math.sin(total2 * 23) * 0.008, 0) * CFrame.Angles(math.sin(total2 * 29) * 0.15, 0, 0)
	VoxelSound.flamerOwn(v12, firing and v6.active and not v12 and v7 < 1.1)

	if not v12 then
		FlameVisuals.own(Vector3.new(0, 0, 0), Vector3.new(0, 0, 1), false)
		return
	end

	local v13, v14 = aim(excludes())
	FlameVisuals.own(v6.muzzleWorld, v14, true)

	if total >= 0.035 then
		v = 0.07 * (random:NextNumber() * 2 - 1)
		v2 = 0.07 * (random:NextNumber() * 2 - 1)
		total = 0
	end

	local now = os.clock()

	if v9 < now - FlameStream.PUFF then
		v9 = now
	end

	if v9 <= now then
		v9 += FlameStream.PUFF
		v8 = now
		fireFlame:FireServer(v13, v14)

		if parent:GetAttribute("Infinite") ~= true then
			v7 = math.max(0, v7 - 1.1)
			showFuel() -- inferred equivalent call
		end

		v6:fired()
	end
end

local renderSteppedConnection = nil
local count2 = 0
local function startStep() -- 1 equivalent call inferred from this helper
	count2 += 1
	v6.pinVisible = v7 > 0 or parent:GetAttribute("Infinite") == true

	if not renderSteppedConnection then
		renderSteppedConnection = RunService.RenderStepped:Connect(step)
	end
end
parent.Equipped:Connect(startStep)
parent.Unequipped:Connect(function()
	count2 += 1
	local v12 = count2
	task.delay(0.5, function()
		if v12 == count2 and renderSteppedConnection and parent.Parent ~= LocalPlayer.Character then
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		end
	end)
end)

if parent.Parent ~= nil and parent.Parent == LocalPlayer.Character then
	startStep() -- inferred equivalent call
end

local function startFire()
	firing = true
end
local function stopFire()
	firing = false
end

parent.Activated:Connect(startFire)
parent.Deactivated:Connect(stopFire)
parent.Unequipped:Connect(function()
	firing = false
end)

TouchControls.register(parent, {
	label = "FIRE",
	autoFire = true,
	assist = true,
	range = 42,
	startFire = startFire,
	stopFire = stopFire
})