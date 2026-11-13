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
local PistolSpecs = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("PistolSpecs"))
local Remotes = Voxel:WaitForChild("Remotes")
local FirePistol = Remotes:WaitForChild("FirePistol")
local ReloadPistol = Remotes:WaitForChild("ReloadPistol")

local v = PistolSpecs.of(parent.Name)
assert(v, "[Voxel] PistolFamilyClient: no PistolSpecs entry for " .. parent.Name)
local view = v.view

local interval = v.interval

local holdRepeat = v.holdRepeat
local mag = v.mag

local function magSize() -- 5 equivalent calls inferred from this helper
	local magSize2 = parent:GetAttribute("MagSize")
	return if type(magSize2) == "number" then magSize2 else mag
end

local function reloadScale() -- 1 equivalent call inferred from this helper
	local reloadScale2 = parent:GetAttribute("ReloadScale")
	return if type(reloadScale2) == "number" then reloadScale2 else 1
end

local random = Random.new()
local hip = v.spread.hip
local aim = v.spread.aim
local moving = v.spread.moving
local bloom = v.spread.bloom
local bloomMax = v.spread.bloomMax
local bloomDecay = v.spread.bloomDecay

local GunRecoil = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("GunRecoil"))
local v2 = GunRecoil.new(parent.Name)
local cframe = nil

local HttpService = game:GetService("HttpService")
local guid = HttpService:GenerateGUID(false)
local v3 = "PistolRecoilUndo" .. guid
local v4 = "PistolRecoil" .. guid
local function recoilGone(): boolean -- 1 equivalent call inferred from this helper
	if parent:IsDescendantOf(game) then
		return false
	end

	RunService:UnbindFromRenderStep(v3)
	RunService:UnbindFromRenderStep(v4)
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
	local v5, v6, v7 = v2:step(p)

	if v5 == 0 and v6 == 0 and v7 == 0 then
		return
	end

	cframe = CFrame.Angles(math.rad(v5), math.rad(v6), 0) * CFrame.Angles(0, 0, (math.rad(v7)))

	if VR.on() then
		cframe = nil
	else
		currentCamera.CFrame *= cframe
	end
end

local v5 = false
local count = 0
local function bindSteps()
	count += 1

	if v5 or not parent:IsDescendantOf(game) then
		return
	end

	v5 = true
	RunService:BindToRenderStep(v3, Enum.RenderPriority.Camera.Value - 3, step1)
	RunService:BindToRenderStep(v4, Enum.RenderPriority.Camera.Value + 3, step2)
end
local function unbindSteps()
	v5 = false

	for _, v6 in { v3, v4 } do
		RunService:UnbindFromRenderStep(v6)
	end

	if cframe then
		workspace.CurrentCamera.CFrame *= cframe:Inverse()
		cframe = nil
	end
end
parent.Equipped:Connect(bindSteps)
parent.Unequipped:Connect(function()
	count += 1
	local v6 = count
	task.delay(1, function()
		if v6 == count and v5 and parent.Parent ~= LocalPlayer.Character then
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

	return (frame * CFrame.Angles(math.rad(v2.pitch), math.rad(v2.yaw), 0)).LookVector
end

local function kickView(aimAlpha: number) -- 1 equivalent call inferred from this helper
	v2:shot(aimAlpha)
end

local v6 = Viewmodel.new(parent, {
	name = v.name,
	weight = view.weight,
	hold = view.hold,
	rightHand = view.rightHand,
	leftHand = view.leftHand,
	leftHip = view.leftHip,
	armThickness = 0.5,
	muzzle = muzzleAttachment.Position,
	aimPoint = view.aimPoint,
	aimDistance = view.aimDistance,
	aimFov = view.aimFov,
	aimMove = view.aimMove,
	aimOutTime = view.aimOutTime,
	zoomIn = view.zoomIn,
	zoomOut = view.zoomOut,
	reach = view.reach,
	sprintHold = view.sprintHold,
	hipKick = view.hipKick,
	hipKickRot = view.hipKickRot,
	aimKick = view.aimKick,
	aimKickRot = view.aimKickRot,
	recoilTime = view.recoilTime,
	punch = view.punch,
	flash = true,
	flashScale = view.flashScale,
	eject = view.eject,
	caseSize = view.caseSize,
	ejectVel = view.ejectVel,
	slide = view.slide
})

local Gunsmith = ReplicatedStorage:FindFirstChild("Gunsmith")

if Gunsmith then
	local Gunsmith2 = require(Gunsmith:WaitForChild("Gunsmith"))
	Gunsmith2.applySpec(parent, v6.spec)
end

local function liveMuzzle()
	return v6.muzzleWorld
end

local v7 = parent:GetAttribute("Ammo")

if not v7 then
	v7 = parent:GetAttribute("MagSize")

	if type(v7) ~= "number" then
		v7 = mag
	end
end

local function showAmmo() -- 6 equivalent calls inferred from this helper
	v6:setAmmo(v7)
end

showAmmo() -- inferred equivalent call
parent:GetAttributeChangedSignal("Ammo"):Connect(function()
	local ammo = parent:GetAttribute("Ammo") or 0
	local v8 = magSize() -- inferred equivalent call
	local v9

	if v8 <= ammo then
		v9 = parent:GetAttribute("MagSize")

		if type(v9) ~= "number" then
			v9 = mag
		end
	else
		v9 = math.min(v7, ammo)
	end

	v7 = v9
	showAmmo() -- inferred equivalent call
end)

local pace = v.pace

local slideGrip = view.slideGrip
local magGrab = view.magGrab

local newVector3 = Vector3.new

local v8 = {
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

local v9 = {
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

local clone = table.clone(v8)

local v10 = {
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
local v11 = { 0.5, 0.6 }
local v12 = false

for _, v13 in {
	{ 1.4, Vector3.new(-0.048, 0.066, 0.075) },
	{ 1.52, Vector3.new(0, -0.02, 0) },
	{ 1.62, Vector3.new(0, 0, 0), true }
} do
	table.insert(clone, v13)
end

v10.pos = clone
local clone2 = table.clone(v9)

for _, v13 in {
	{ 1.4, Vector3.new(5.5, 3.5, -11) },
	{ 1.52, Vector3.new(-3, 0, 2) },
	{ 1.62, Vector3.new(0, 0, 0), true }
} do
	table.insert(clone2, v13)
end

v10.rot = clone2

v10.leftWeight = {
	{ 0, 0 },
	{ 0.1, 0.3 },
	{ 0.3, 1, true },
	{ 1.2, 1, true },
	{ 1.42, 0, true }
}
v10.leftOnAmmo = leftOnAmmo

v10.cues = { 0.24, 1.15 }
local clone3 = table.clone(v8)

local v13 = {
	length = 2.12,
	commit = 1.7,
	pos = 0,
	rot = 0,
	leftWeight = 0,
	leftOnAmmo = 0,
	charger = 0,
	cues = 0
}

for _, v14 in {
	{ 1.38, Vector3.new(-0.1, 0.17, 0.2) },
	{ 1.5, Vector3.new(-0.1, 0.2, 0.2), true },
	{ 1.6, Vector3.new(-0.06, 0.18, 0.12), true },
	{ 1.7, Vector3.new(-0.06, 0.19000001, 0.089999996) },
	{ 1.8, Vector3.new(0, 0.04, 0) },
	{ 1.95, Vector3.new(0, -0.02, 0) },
	{ 2.12, Vector3.new(0, 0, 0), true }
} do
	table.insert(clone3, v14)
end

v13.pos = clone3
local clone4 = table.clone(v9)

for _, v14 in {
	{ 1.38, Vector3.new(12, 34, -18) },
	{ 1.5, Vector3.new(8, 30, -12), true },
	{ 1.6, Vector3.new(4, 34, -10), true },
	{ 1.7, Vector3.new(0, 34, -10) },
	{ 1.8, Vector3.new(8, -3, 4) },
	{ 1.95, Vector3.new(-3, 0, 2) },
	{ 2.12, Vector3.new(0, 0, 0), true }
} do
	table.insert(clone4, v14)
end

v13.rot = clone4

v13.leftWeight = {
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

v13.leftOnAmmo = leftOnAmmo
v13.charger = { 1.2, 1.74 }
v13.cues = { 0.24, 1.15, 1.5, 1.7 }

local magOut = view.magOut
local v14 = {
	{ 0, Vector3.new(0, 0, 0) },
	{ 0.24, Vector3.new(0, 0, 0), true },
	{ 0.3, magOut * 0.12 },
	{ 0.36, magOut * 0.32 + Vector3.new(0, -0.056, 0) },
	{ 0.5, magOut * 0.6 + Vector3.new(0.07, -0.84, 0.14) },
	{ 0.6, Vector3.new(-0.35, -1.54, 0.42) },
	{ 0.8, magOut * 0.5 + Vector3.new(-0.11, -0.21, 0.07) },
	{ 1, magOut * 0.18 },
	{ 1.08, magOut * 0.06 },
	{ 1.15, Vector3.new(0, 0, 0), true }
}

local v15 = {
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
	v6.pose = CFrame.identity:Lerp(Keyframes.pose(Keyframes.sample(data.pos, p), Keyframes.sample(data.rot, p)), p2)
	v6.leftWeight = Keyframes.sample(data.leftWeight, p) * p2
	v6.leftOnAmmo = Keyframes.sample(data.leftOnAmmo, p)
	v6.leftTarget = Vector3.new(-1, -2.8, -0.6)
	local charger = data.charger
	local leftGun

	if charger and charger[1] < p and p < charger[2] then
		leftGun = slideGrip
	end

	v6.leftGun = leftGun
	v6.ammoGrab = magGrab
	v6.ammoDelta = Keyframes.pose(Keyframes.sample(v14, p), Keyframes.sample(v15, p))
	v6.ammoVisible = not (v11[1] < p and p < v11[2])
	local reloadProgress

	if p < data.commit then
		reloadProgress = p / data.commit
	end

	v6.reloadProgress = reloadProgress
end

local v16 = false
local v17 = false
local now = nil
local renderSteppedConnection = nil
local flag = false
local v18 = 0

local function endReload() -- 3 equivalent calls inferred from this helper
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	v12 = false
	flag = false
	v18 = 0
	v6.aimBlocked = false
	v6.pose = CFrame.identity
	v6.leftWeight = 0
	v6.leftOnAmmo = 0
	v6.leftGun = nil
	v6.ammoDelta = CFrame.identity
	v6.ammoVisible = true
	v6.reloadProgress = nil
	v6.slideLocked = v7 <= 0
end

local function startReload()
	if not flag and v6.active then
		local v19 = v7

		if not (magSize() <= v19) then -- inferred equivalent call
			local v20

			if v7 <= 0 then
				v20 = v13
			else
				v20 = v10
			end

			v12 = true
			flag = true
			v18 = 1
			now = nil
			v6.aimBlocked = true
			ReloadPistol:FireServer()
			local now2 = os.clock()
			local v21 = 1
			local v22 = nil
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				local now3 = os.clock()
				local v23 = (now3 - now2) / (pace * reloadScale()) -- inferred equivalent call

				if v12 and v20.commit <= v23 then
					v12 = false
					v6.aimBlocked = false
					v7 = magSize() -- inferred equivalent call
					showAmmo() -- inferred equivalent call
				end

				if not v12 and not v22 and (v16 or v6.aiming) then
					v22 = now3
				end

				v18 = not v22 and 1 or 1 - (now3 - v22) / 0.1
				local cue = v20.cues[v21]

				if cue and cue <= v23 and not v22 then
					local _position = workspace.CurrentCamera.CFrame.Position

					if cue == 0.24 then
						VoxelSound.reload("pistol", "magOut", 0.45)
					elseif cue == 1.15 then
						VoxelSound.reload("pistol", "magIn", 0.85)
						v6:bump(0.35)
					elseif cue == 1.7 then
						v6.slideLocked = false
						VoxelSound.reload("pistol", "slideRelease", 0.85)
						v6:bump(0.3)
					else
						VoxelSound.reload("pistol", "slideBack", 0.6)
					end

					v21 += 1
				end

				if not (v18 <= 0 or v20.length <= v23) then
					sample(v20, math.min(v23, v20.length), v18)
					return
				end

				endReload() -- inferred equivalent call
			end)
		end
	end
end

parent.Equipped:Connect(function()
	Tracers.setOwnMuzzle(liveMuzzle)
	v7 = math.min(v7, parent:GetAttribute("Ammo") or 0)
	local ammo = parent:GetAttribute("Ammo") or 0

	if magSize() <= ammo then -- inferred equivalent call
		v7 = magSize() -- inferred equivalent call
	end

	v6.slideLocked = v7 <= 0
	showAmmo() -- inferred equivalent call
end)
parent.Unequipped:Connect(function()
	v16 = false
	v17 = false
	now = nil

	if flag then
		endReload() -- inferred equivalent call
	end
end)

parent:GetAttributeChangedSignal("GsRefit"):Connect(function()
	v16 = false
	v17 = false
	now = nil

	if flag then
		endReload() -- inferred equivalent call
	end

	v6:rebuild()
	v7 = math.min(v7, parent:GetAttribute("Ammo") or 0)
	v6.slideLocked = v7 <= 0
	showAmmo() -- inferred equivalent call
end)

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
local v19 = 0
local v20 = 0

local function spreadDir(vector3: Vector3, p: number)
	local v21 = math.rad(p) * math.sqrt((random:NextNumber()))
	return (CFrame.lookAt(Vector3.new(0, 0, 0), vector3) * CFrame.Angles(
		0,
		0,
		random:NextNumber() * 3.141592653589793 * 2
	) * CFrame.Angles(v21, 0, 0)).LookVector
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
	local v21 = currentCamera.ViewportSize * 0.5
	local ray = VR.ray(currentCamera, v21.X, v21.Y)
	local aimAlpha = v6.aimAlpha
	local v22 = ((hip + (not (humanoid and humanoid.MoveDirection.Magnitude > 0.1 and true or false) and 0 or moving)) * (1 - aimAlpha) + aim * aimAlpha + v20 * (1 - 0.7 * aimAlpha)) * Viewmodel.hipSpread(aimAlpha)
	local v23 = aimDirection(currentCamera) -- inferred equivalent call
	local v24 = spreadDir(v23, v22)
	local raycastResult = workspace:Raycast(ray.Origin, v24 * 400, raycastParams)
	local v25

	if raycastResult then
		v25 = raycastResult.Position
	else
		v25 = ray.Origin + v24 * 400
	end

	local muzzle = v6:muzzle(children)

	if raycastResult then
		local v26

		if raycastResult.Instance == workspace.Terrain then
			v26 = raycastResult.Material ~= Enum.Material.Water
		else
			v26 = false
		end

		local travelTime = Tracers.travelTime(v6.muzzleWorld, v25)
		task.delay(travelTime, ImpactFX.bullet, raycastResult.Position, raycastResult.Normal, v24, v26)
		HitPredict.shot(raycastResult, travelTime)
	end

	local v26 = v25 - muzzle

	if not (v26.Magnitude < 0.1) then
		v24 = v26
	end

	FirePistol:FireServer(muzzle, v24.Unit, workspace:GetServerTimeNow(), v23, v22)
	Tracers.fire(v6.muzzleWorld, v25)
	VoxelSound.ownPistol(v.sound)
	v6:fired()
	kickView(aimAlpha) -- inferred equivalent call
	v20 = math.min(v20 + bloom, bloomMax)
	v7 -= 1

	if v7 <= 0 then
		v6.slideLocked = true
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

		local v21 = not (lastTime > 0) and 0 or os.clock() - lastTime
		renderSteppedConnection2 = RunService.RenderStepped:Connect(function(dt)
			if v21 > 0 then
				dt = math.max(dt, v21)
				v21 = 0
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
		local v21 = not (lastTime > 0) and 0 or os.clock() - lastTime
		renderSteppedConnection2 = RunService.RenderStepped:Connect(function(dt)
			if v21 > 0 then
				dt = math.max(dt, v21)
				v21 = 0
			end

			fn(dt)
		end)
	end
end

heldStep(function(p)
	v20 = v2:cool(v20, bloomDecay, p)
	v6.firing = v16 and not v12

	if v12 or not v6.active then
		return
	end

	local now2 = os.clock()

	if now and now2 - now > 0.1 then
		now = nil
	end

	if not (now or v17 and v16) then
		return
	end

	if v7 <= 0 then
		now = nil
		startReload()
	else
		if not v6:ready() or v18 > 0.3 or now2 < v19 then
			return
		end

		local v21

		if v17 and v16 and not v.auto then
			v21 = holdRepeat
		else
			v21 = interval
		end

		local v22

		if v.auto and now2 - v19 < interval then
			v22 = v19 + v21
		else
			v22 = now2 + v21
		end

		v19 = v22
		now = nil
		shoot()

		if v7 <= 0 then
			task.delay(0.2, startReload)
		end
	end
end)

local function press(flag2: boolean) -- 2 equivalent calls inferred from this helper
	v16 = true
	v17 = flag2 or v.auto
	now = os.clock()
end
local function release()
	v16 = false
	v17 = false
end
local function setAim(aiming: boolean) -- 2 equivalent calls inferred from this helper
	if aiming and not v6.active then
		return
	end

	v6.aiming = aiming
end

parent.Activated:Connect(function()
	press() -- inferred equivalent call
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
	if not v6.active then
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
	range = 400,
	assist = true,
	startFire = function()
		press(true) -- inferred equivalent call
	end,
	stopFire = release,
	setAim = setAim,
	isAiming = function()
		return v6.aiming
	end,
	reload = startReload
})