local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local parent = script.Parent
local muzzleAttachment = parent:WaitForChild("Handle"):WaitForChild("MuzzleAttachment")
local LocalPlayer = Players.LocalPlayer
local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local Viewmodel = require(Voxel:WaitForChild("Viewmodel"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local VR = require(ReplicatedStorage2:WaitForChild("Voxel"):WaitForChild("VR"))
local VoxelSound = require(Voxel:WaitForChild("VoxelSound"))
local Tracers = require(Voxel:WaitForChild("Tracers"))
local Keyframes = require(Voxel:WaitForChild("Keyframes"))
local ImpactFX = require(Voxel:WaitForChild("ImpactFX"))
local HitPredict = require(Voxel:WaitForChild("HitPredict"))
local TouchControls = require(Voxel:WaitForChild("TouchControls"))
local Remotes = Voxel:WaitForChild("Remotes")
local FireHandCannon = Remotes:WaitForChild("FireHandCannon")
local ReloadHandCannon = Remotes:WaitForChild("ReloadHandCannon")

local function magSize() -- 7 equivalent calls inferred from this helper
	local magSize2 = parent:GetAttribute("MagSize")
	return if type(magSize2) == "number" then magSize2 else 7
end

local function reloadScale() -- 1 equivalent call inferred from this helper
	local reloadScale2 = parent:GetAttribute("ReloadScale")
	return if type(reloadScale2) == "number" then reloadScale2 else 1
end

local random = Random.new()

local GunRecoil = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("GunRecoil"))
local v = GunRecoil.new(parent.Name)
local cframe = nil

local HttpService = game:GetService("HttpService")
local guid = HttpService:GenerateGUID(false)
local v2 = "HandCannonRecoilUndo" .. guid
local v3 = "HandCannonRecoil" .. guid
local function recoilGone(): boolean -- 1 equivalent call inferred from this helper
	if parent:IsDescendantOf(game) then
		return false
	end

	RunService:UnbindFromRenderStep(v2)
	RunService:UnbindFromRenderStep(v3)
	return true
end

local function step1()
	local currentCamera = workspace.CurrentCamera

	if cframe then
		currentCamera.CFrame *= cframe:Inverse()
		cframe = nil
	end

	if recoilGone() then -- inferred equivalent call
	end
end

local function step2(p)
	if not parent:IsDescendantOf(game) then
		return
	end

	local currentCamera = workspace.CurrentCamera
	local v4, v5, v6 = v:step(p)

	if v4 == 0 and v5 == 0 and v6 == 0 then
		return
	end

	cframe = CFrame.Angles(math.rad(v4), math.rad(v5), 0) * CFrame.Angles(0, 0, (math.rad(v6)))

	if VR.on() then
		cframe = nil
	else
		currentCamera.CFrame *= cframe
	end
end

local v4 = false
local count = 0
local function bindSteps()
	count += 1

	if v4 or not parent:IsDescendantOf(game) then
		return
	end

	v4 = true
	RunService:BindToRenderStep(v2, Enum.RenderPriority.Camera.Value - 3, step1)
	RunService:BindToRenderStep(v3, Enum.RenderPriority.Camera.Value + 3, step2)
end
local function unbindSteps()
	v4 = false

	for _, v5 in { v2, v3 } do
		RunService:UnbindFromRenderStep(v5)
	end

	if cframe then
		workspace.CurrentCamera.CFrame *= cframe:Inverse()
		cframe = nil
	end
end
parent.Equipped:Connect(bindSteps)
parent.Unequipped:Connect(function()
	count += 1
	local v5 = count
	task.delay(1, function()
		if v5 == count and v4 and parent.Parent ~= LocalPlayer.Character then
			unbindSteps()
		end
	end)
end)

if parent.Parent == LocalPlayer.Character then
	bindSteps()
end

local function aimDirection(currentCamera) -- 1 equivalent call inferred from this helper
	local frame = VR.frame(currentCamera)

	if cframe then
		frame *= cframe:Inverse()
	end

	return (frame * CFrame.Angles(math.rad(v.pitch), math.rad(v.yaw), 0)).LookVector
end

local function kickView(aimAlpha: number) -- 1 equivalent call inferred from this helper
	v:shot(aimAlpha)
end

local v5 = Viewmodel.new(parent, {
	name = "HandCannon",
	weight = 0.7,
	hold = CFrame.new(0.47, -0.76, -1.55) * CFrame.Angles(
		0.026179938779914945,
		0.05235987755982989,
		-0.05235987755982989
	),
	rightHand = Vector3.new(0.014, -0.25, 0.58),
	leftHand = Vector3.new(-0.098, -0.27, 0.56),
	leftHip = Vector3.new(-1, -2.8, -0.6),
	armThickness = 0.5,
	muzzle = muzzleAttachment.Position,
	aimPoint = Vector3.new(0, 0.255, 0.371),
	aimDistance = 0.938,
	aimFov = 45.22,
	aimMove = 0.7,
	aimOutTime = 0.2,
	zoomIn = 0.25,
	zoomOut = 0.2,
	reach = 1.95,
	sprintHold = CFrame.new(0.28, -0.95, -1.15) * CFrame.Angles(
		-0.8726646259971648,
		0.4886921905584123,
		0.3141592653589793
	),
	hipKick = Vector3.new(0.03, 0.07, 0.24),
	hipKickRot = Vector3.new(26, 3, 8),
	aimKick = Vector3.new(0.01, 0.035, 0.16),
	aimKickRot = Vector3.new(9, 1.2, 4),
	recoilTime = 0.32,
	punch = 1,
	flash = true,
	flashScale = 1.15,
	eject = Vector3.new(0.049, 0.168, 0.133),
	caseSize = Vector3.new(0.055, 0.055, 0.1),
	ejectVel = Vector3.new(4, 5.5, 1.2),
	slide = { travel = 0.2, time = 0.1 }
})

local Gunsmith = ReplicatedStorage:FindFirstChild("Gunsmith")

if Gunsmith then
	local Gunsmith2 = require(Gunsmith:WaitForChild("Gunsmith"))
	Gunsmith2.applySpec(parent, v5.spec)
end

local function liveMuzzle()
	return v5.muzzleWorld
end

local v6 = parent:GetAttribute("Ammo") or magSize() -- inferred equivalent call

local function showAmmo() -- 6 equivalent calls inferred from this helper
	v5:setAmmo(v6)
end

showAmmo() -- inferred equivalent call
parent:GetAttributeChangedSignal("Ammo"):Connect(function()
	local ammo = parent:GetAttribute("Ammo") or 0
	local v7

	if magSize() <= ammo then -- inferred equivalent call
		v7 = magSize() -- inferred equivalent call
	else
		v7 = math.min(v6, ammo)
	end

	v6 = v7
	showAmmo() -- inferred equivalent call
end)

local newVector3 = Vector3.new

local v7 = {
	{ 0, Vector3.new(0, 0, 0) },
	{ 0.06, Vector3.new(0, 0.03, 0) },
	{ 0.2, Vector3.new(-0.102, 0.238, 0.2125) },
	{ 0.3, Vector3.new(-0.12, 0.28, 0.25) },
	{ 0.36, Vector3.new(-0.12, 0.32, 0.25) },
	{ 0.5, Vector3.new(-0.12, 0.28, 0.25) },
	{ 0.66, (Vector3.new(-0.16, 0.22, 0.25)):Lerp(Vector3.new(-0.12, 0.28, 0.25), 0.4) },
	{ 0.8, Vector3.new(-0.16, 0.22, 0.25) },
	{ 1.08, Vector3.new(-0.16, 0.2, 0.25) },
	{ 1.15, Vector3.new(-0.16, 0.24, 0.25), true },
	{ 1.2, Vector3.new(-0.16, 0.19, 0.25) },
	{ 1.26, Vector3.new(-0.16, 0.22, 0.25) }
}

local v8 = {
	{ 0, Vector3.new(0, 0, 0) },
	{ 0.06, Vector3.new(5, 0, 0) },
	{ 0.2, Vector3.new(15.3, 8.5, -32.3) },
	{ 0.3, Vector3.new(18, 10, -38) },
	{ 0.36, Vector3.new(24, 10, -42) },
	{ 0.5, Vector3.new(18, 10, -38) },
	{ 0.66, (Vector3.new(22, 14, -44)):Lerp(Vector3.new(18, 10, -38), 0.4) },
	{ 0.8, Vector3.new(22, 14, -44) },
	{ 1.08, Vector3.new(19, 14, -44) },
	{ 1.15, Vector3.new(18, 14, -42), true },
	{ 1.2, Vector3.new(26, 12, -47) },
	{ 1.26, Vector3.new(22, 14, -44) }
}

local function join(p, items)
	local clone = table.clone(p)

	for _, item in items do
		table.insert(clone, item)
	end

	return clone
end

local clone = table.clone(v7)

local v9 = {
	length = 1.62,
	commit = 1.15,
	pos = 0,
	rot = 0,
	leftWeight = 0,
	leftOnAmmo = 0,
	charger = nil,
	cues = 0
}
local leftOnAmmo = {
	{ 0, 0 },
	{ 0.56, 0, true },
	{ 0.64, 1, true },
	{ 1.16, 1, true },
	{ 1.24, 0, true }
}
local v10 = { 0.5, 0.6 }
local v11 = false

for _, v12 in {
	{ 1.4, Vector3.new(-0.048, 0.066, 0.075) },
	{ 1.52, Vector3.new(0, -0.02, 0) },
	{ 1.62, Vector3.new(0, 0, 0), true }
} do
	table.insert(clone, v12)
end

v9.pos = clone
local clone2 = table.clone(v8)

for _, v12 in {
	{ 1.4, Vector3.new(5.5, 3.5, -11) },
	{ 1.52, Vector3.new(-3, 0, 2) },
	{ 1.62, Vector3.new(0, 0, 0), true }
} do
	table.insert(clone2, v12)
end

v9.rot = clone2

v9.leftWeight = {
	{ 0, 0 },
	{ 0.1, 0.3 },
	{ 0.3, 1, true },
	{ 1.2, 1, true },
	{ 1.42, 0, true }
}
v9.leftOnAmmo = leftOnAmmo

v9.cues = { 0.24, 1.15 }
local clone3 = table.clone(v7)

local v12 = {
	length = 2.12,
	commit = 1.7,
	pos = 0,
	rot = 0,
	leftWeight = 0,
	leftOnAmmo = 0,
	charger = 0,
	cues = 0
}

for _, v13 in {
	{ 1.38, Vector3.new(-0.1, 0.17, 0.2) },
	{ 1.5, Vector3.new(-0.1, 0.2, 0.2), true },
	{ 1.6, Vector3.new(-0.06, 0.18, 0.12), true },
	{ 1.7, Vector3.new(-0.06, 0.19000001, 0.089999996) },
	{ 1.8, Vector3.new(0, 0.04, 0) },
	{ 1.95, Vector3.new(0, -0.02, 0) },
	{ 2.12, Vector3.new(0, 0, 0), true }
} do
	table.insert(clone3, v13)
end

v12.pos = clone3
local clone4 = table.clone(v8)

for _, v13 in {
	{ 1.38, Vector3.new(12, 34, -18) },
	{ 1.5, Vector3.new(8, 30, -12), true },
	{ 1.6, Vector3.new(4, 34, -10), true },
	{ 1.7, Vector3.new(0, 34, -10) },
	{ 1.8, Vector3.new(8, -3, 4) },
	{ 1.95, Vector3.new(-3, 0, 2) },
	{ 2.12, Vector3.new(0, 0, 0), true }
} do
	table.insert(clone4, v13)
end

v12.rot = clone4

v12.leftWeight = {
	{ 0, 0 },
	{ 0.1, 0.3 },
	{ 0.3, 1, true },
	{ 1.2, 1, true },
	{ 1.34, 0.3 },
	{ 1.46, 0, true },
	{ 1.66, 0, true },
	{ 1.76, 1, true },
	{ 2, 1, true },
	{ 2.1, 0, true }
}

v12.leftOnAmmo = leftOnAmmo
v12.charger = { 1.2, 1.74 }
v12.cues = { 0.24, 1.15, 1.5, 1.7 }

local v13 = {
	{ 0, Vector3.new(0, 0, 0) },
	{ 0.24, Vector3.new(0, 0, 0), true },
	{ 0.3, Vector3.new(0, -0.15976799, 0.051911995) },
	{ 0.36, Vector3.new(0, -0.48204795, 0.13843198) },
	{ 0.5, Vector3.new(0.07, -1.63884, 0.39955997) },
	{ 0.6, Vector3.new(-0.35, -1.54, 0.42) },
	{ 0.8, Vector3.new(-0.11, -0.87569994, 0.28629997) },
	{ 1, Vector3.new(0, -0.239652, 0.077868) },
	{ 1.08, Vector3.new(0, -0.07988399, 0.025955997) },
	{ 1.15, Vector3.new(0, 0, 0), true }
}

local v14 = {
	{ 0, Vector3.new(0, 0, 0) },
	{ 0.24, Vector3.new(0, 0, 0), true },
	{ 0.36, Vector3.new(-10, 0, 6) },
	{ 0.5, Vector3.new(-35, 10, 25) },
	{ 0.6, Vector3.new(-20, 0, 20) },
	{ 0.8, Vector3.new(-8, 0, 6) },
	{ 1, Vector3.new(-2, 0, 0) },
	{ 1.15, Vector3.new(0, 0, 0), true }
}

local function sample(data, p: number, p2: number)
	v5.pose = CFrame.identity:Lerp(Keyframes.pose(Keyframes.sample(data.pos, p), Keyframes.sample(data.rot, p)), p2)
	v5.leftWeight = Keyframes.sample(data.leftWeight, p) * p2
	v5.leftOnAmmo = Keyframes.sample(data.leftOnAmmo, p)
	v5.leftTarget = Vector3.new(-1, -2.8, -0.6)
	local charger = data.charger
	v5.leftGun = charger and charger[1] < p and p < charger[2] and Vector3.new(-0.17, 0.1, 0.42) or nil
	v5.ammoGrab = Vector3.new(-0.028, -0.56, 0.504)
	v5.ammoDelta = Keyframes.pose(Keyframes.sample(v13, p), Keyframes.sample(v14, p))
	v5.ammoVisible = not (v10[1] < p and p < v10[2])
	local reloadProgress

	if p < data.commit then
		reloadProgress = p / data.commit
	end

	v5.reloadProgress = reloadProgress
end

local v15 = false
local v16 = false
local now = nil
local renderSteppedConnection = nil
local flag = false
local v17 = 0

local function endReload() -- 3 equivalent calls inferred from this helper
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	v11 = false
	flag = false
	v17 = 0
	v5.aimBlocked = false
	v5.pose = CFrame.identity
	v5.leftWeight = 0
	v5.leftOnAmmo = 0
	v5.leftGun = nil
	v5.ammoDelta = CFrame.identity
	v5.ammoVisible = true
	v5.reloadProgress = nil
	v5.slideLocked = v6 <= 0
end

local function startReload()
	if not flag and v5.active then
		local v18 = v6

		if not (magSize() <= v18) then -- inferred equivalent call
			local v19

			if v6 <= 0 then
				v19 = v12
			else
				v19 = v9
			end

			v11 = true
			flag = true
			v17 = 1
			now = nil
			v5.aimBlocked = true
			ReloadHandCannon:FireServer()
			local now2 = os.clock()
			local v20 = 1
			local v21 = nil
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				local now3 = os.clock()
				local v22 = (now3 - now2) / (reloadScale() * 1.45) -- inferred equivalent call

				if v11 and v19.commit <= v22 then
					v11 = false
					v5.aimBlocked = false
					v6 = magSize() -- inferred equivalent call
					showAmmo() -- inferred equivalent call
				end

				if not v11 and not v21 and (v15 or v5.aiming) then
					v21 = now3
				end

				v17 = not v21 and 1 or 1 - (now3 - v21) / 0.1
				local cue = v19.cues[v20]

				if cue and cue <= v22 and not v21 then
					local _position = workspace.CurrentCamera.CFrame.Position

					if cue == 0.24 then
						VoxelSound.reload("magnum", "magOut", 0.45)
					elseif cue == 1.15 then
						VoxelSound.reload("magnum", "magIn", 0.85)
						v5:bump(0.35)
					elseif cue == 1.7 then
						v5.slideLocked = false
						VoxelSound.reload("magnum", "slideRelease", 0.85)
						v5:bump(0.3)
					else
						VoxelSound.reload("magnum", "slideBack", 0.6)
					end

					v20 += 1
				end

				if not (v17 <= 0 or v19.length <= v22) then
					sample(v19, math.min(v22, v19.length), v17)
					return
				end

				endReload() -- inferred equivalent call
			end)
		end
	end
end

parent.Equipped:Connect(function()
	Tracers.setOwnMuzzle(liveMuzzle)
	v6 = math.min(v6, parent:GetAttribute("Ammo") or 0)
	local ammo = parent:GetAttribute("Ammo") or 0

	if magSize() <= ammo then -- inferred equivalent call
		v6 = magSize() -- inferred equivalent call
	end

	v5.slideLocked = v6 <= 0
	showAmmo() -- inferred equivalent call
end)
parent.Unequipped:Connect(function()
	v15 = false
	v16 = false
	now = nil

	if flag then
		endReload() -- inferred equivalent call
	end
end)

parent:GetAttributeChangedSignal("GsRefit"):Connect(function()
	v15 = false
	v16 = false
	now = nil

	if flag then
		endReload() -- inferred equivalent call
	end

	v5:rebuild()
	v6 = math.min(v6, parent:GetAttribute("Ammo") or 0)
	v5.slideLocked = v6 <= 0
	showAmmo() -- inferred equivalent call
end)

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
local v18 = 0
local v19 = 0

local function spreadDir(vector3: Vector3, p: number)
	local v20 = math.rad(p) * math.sqrt((random:NextNumber()))
	return (CFrame.lookAt(Vector3.new(0, 0, 0), vector3) * CFrame.Angles(
		0,
		0,
		random:NextNumber() * 3.141592653589793 * 2
	) * CFrame.Angles(v20, 0, 0)).LookVector
end

local function shoot()
	local character = LocalPlayer.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local children = { character, workspace.CurrentCamera }

	for _, childName in { "VoxelChips", "VoxelLoose", "VoxelTracers" } do
		local child = workspace:FindFirstChild(childName)

		if child then
			table.insert(children, child)
		end
	end

	Viewmodel.setFilter(raycastParams, children)
	local currentCamera = workspace.CurrentCamera
	local v20 = currentCamera.ViewportSize * 0.5
	local ray = VR.ray(currentCamera, v20.X, v20.Y)
	local aimAlpha = v5.aimAlpha
	local v21 = ((((humanoid and humanoid.MoveDirection.Magnitude > 0.1 and true or false) and 1.2 or 0) + 1.8) * (1 - aimAlpha) + 0.15 * aimAlpha + v19 * (1 - 0.7 * aimAlpha)) * Viewmodel.hipSpread(aimAlpha)
	local v22 = aimDirection(currentCamera) -- inferred equivalent call
	local v23 = spreadDir(v22, v21)
	local raycastResult = workspace:Raycast(ray.Origin, v23 * 450, raycastParams)
	local v24

	if raycastResult then
		v24 = raycastResult.Position
	else
		v24 = ray.Origin + v23 * 450
	end

	local muzzle = v5:muzzle(children)

	if raycastResult then
		local v25

		if raycastResult.Instance == workspace.Terrain then
			v25 = raycastResult.Material ~= Enum.Material.Water
		else
			v25 = false
		end

		local travelTime = Tracers.travelTime(v5.muzzleWorld, v24)
		task.delay(travelTime, ImpactFX.bullet, raycastResult.Position, raycastResult.Normal, v23, v25)
		HitPredict.shot(raycastResult, travelTime)
	end

	local v25 = v24 - muzzle

	if not (v25.Magnitude < 0.1) then
		v23 = v25
	end

	FireHandCannon:FireServer(muzzle, v23.Unit, workspace:GetServerTimeNow(), v22, v21)
	Tracers.fire(v5.muzzleWorld, v24, nil, nil, true)
	VoxelSound.ownHandCannon(1)
	v5:fired()
	kickView(aimAlpha) -- inferred equivalent call
	v19 = math.min(v19 + 1.1, 2.6)
	v6 -= 1

	if v6 <= 0 then
		v5.slideLocked = true
	end

	showAmmo() -- inferred equivalent call
end

local function heldStep(fn)
	local renderSteppedConnection2 = nil
	local lastTime = 0
	local function start()
		if renderSteppedConnection2 then
			return
		end

		local v20 = not (lastTime > 0) and 0 or os.clock() - lastTime
		renderSteppedConnection2 = RunService.RenderStepped:Connect(function(dt)
			if v20 > 0 then
				dt = math.max(dt, v20)
				v20 = 0
			end

			fn(dt)
		end)
	end
	parent.Equipped:Connect(start)
	parent.Unequipped:Connect(function()
		if renderSteppedConnection2 then
			renderSteppedConnection2:Disconnect()
			renderSteppedConnection2 = nil
			lastTime = os.clock()
		end
	end)

	if parent.Parent ~= nil and parent.Parent == LocalPlayer.Character and not renderSteppedConnection2 then
		local v20 = not (lastTime > 0) and 0 or os.clock() - lastTime
		renderSteppedConnection2 = RunService.RenderStepped:Connect(function(dt)
			if v20 > 0 then
				dt = math.max(dt, v20)
				v20 = 0
			end

			fn(dt)
		end)
	end
end

heldStep(function(p)
	v19 = v:cool(v19, 3, p)
	v5.firing = v15 and not v11

	if v11 or not v5.active then
		return
	end

	local now2 = os.clock()

	if now and now2 - now > 0.15 then
		now = nil
	end

	if not (now or v16 and v15) then
		return
	end

	if v6 <= 0 then
		now = nil
		startReload()
	else
		if not v5:ready() or v17 > 0.3 or now2 < v18 then
			return
		end

		v18 = now2 + (v16 and v15 and 0.55 or 0.42)
		now = nil
		shoot()

		if v6 <= 0 then
			task.delay(0.2, startReload)
		end
	end
end)

local function press(flag2: boolean) -- 2 equivalent calls inferred from this helper
	v15 = true
	v16 = flag2
	now = os.clock()
end
local function release()
	v15 = false
	v16 = false
end
local function setAim(aiming: boolean) -- 2 equivalent calls inferred from this helper
	if aiming and not v5.active then
		return
	end

	v5.aiming = aiming
end

parent.Activated:Connect(function()
	press(false) -- inferred equivalent call
end)
parent.Deactivated:Connect(release)

local function heldInput(onInputBegan, onInputEnded)
	local connections = {}
	local function start() -- 1 equivalent call inferred from this helper
		if #connections > 0 then
			return
		end

		table.insert(connections, UserInputService.InputBegan:Connect(onInputBegan))
		table.insert(connections, UserInputService.InputEnded:Connect(onInputEnded))
	end
	parent.Equipped:Connect(start)
	parent.Unequipped:Connect(function()
		for _, connection in connections do
			connection:Disconnect()
		end

		table.clear(connections)
	end)

	if parent.Parent ~= nil and parent.Parent == LocalPlayer.Character then
		start() -- inferred equivalent call
	end
end

heldInput(function(p, p2)
	if not v5.active then
		return
	end

	local ReplicatedStorage3 = game:GetService("ReplicatedStorage")

	if require(ReplicatedStorage3:WaitForChild("Voxel"):WaitForChild("AimKey")).began(p, p2) then
		setAim(true) -- inferred equivalent call
	elseif p.KeyCode == Enum.KeyCode.R and not p2 then
		startReload()
	end
end, function(p)
	local ReplicatedStorage3 = game:GetService("ReplicatedStorage")

	if require(ReplicatedStorage3:WaitForChild("Voxel"):WaitForChild("AimKey")).ended(p) then
		setAim(false) -- inferred equivalent call
	end
end)

TouchControls.register(parent, {
	label = "FIRE",
	autoFire = true,
	range = 450,
	assist = true,
	startFire = function()
		press(true) -- inferred equivalent call
	end,
	stopFire = release,
	setAim = setAim,
	isAiming = function()
		return v5.aiming
	end,
	reload = startReload
})