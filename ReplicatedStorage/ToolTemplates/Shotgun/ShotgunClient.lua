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
local FireShotgun = Remotes:WaitForChild("FireShotgun")
local ReloadShotgun = Remotes:WaitForChild("ReloadShotgun")

local function magSize() -- 10 equivalent calls inferred from this helper
	local magSize2 = parent:GetAttribute("MagSize")
	return if type(magSize2) == "number" then magSize2 else 8
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
local v2 = "ShotgunRecoilUndo" .. guid
local v3 = "ShotgunRecoil" .. guid
local function recoilGone(): boolean -- 1 equivalent call inferred from this helper
	if parent:IsDescendantOf(game) then
		return false
	end

	RunService:UnbindFromRenderStep(v2)
	RunService:UnbindFromRenderStep(v3)
	return true
end

local function step1()
	if cframe then
		workspace.CurrentCamera.CFrame *= cframe:Inverse()
		cframe = nil
	end

	recoilGone() -- inferred equivalent call
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

local newVector3 = Vector3.new

local v5 = Viewmodel.new(parent, {
	name = "Shotgun",
	weight = 1.05,
	hold = CFrame.new(0.62, -0.82, -1.7) * CFrame.Angles(0.03490658503988659, 0.03490658503988659, 0.017453292519943295),
	rightHand = Vector3.new(0, -0.27, 0.45),
	leftHand = Vector3.new(0, -0.6, -0.8),
	armThickness = 0.5,
	muzzle = muzzleAttachment.Position,
	aimPoint = Vector3.new(0, 0.29, -0.06),
	aimDistance = 0.832,
	aimFov = 55,
	aimMove = 0.75,
	reach = 4,
	sprintHold = CFrame.new(-0.2, -1.3, -1.9) * CFrame.Angles(
		-0.5113814708343386,
		1.08035880698449,
		0.46600291028248597
	),
	hipKick = Vector3.new(0.04, 0.05, 0.45),
	hipKickRot = Vector3.new(7, 1.5, 3),
	aimKick = Vector3.new(0.006, 0.02, 0.16),
	aimKickRot = Vector3.new(2.2, 0.5, 1.4),
	recoilTime = 0.28,
	punch = 1.6,
	flash = true,
	flashScale = 1.5,
	eject = Vector3.new(0.1, 0.035, -0.03),
	caseSize = Vector3.new(0.054, 0.054, 0.15),
	caseColor = Color3.fromRGB(150, 34, 30),
	ejectVel = Vector3.new(3.2, 2.6, 0.8),
	slide = { travel = 0.22, time = 0.1 },
	boltEject = true
})

local function liveMuzzle()
	return v5.muzzleWorld
end

Tracers.setOwnMuzzle(liveMuzzle)

local v6 = parent:GetAttribute("Ammo") or magSize() -- inferred equivalent call
local v7 = v6 > 0

local function showAmmo() -- 5 equivalent calls inferred from this helper
	v5:setAmmo(v6)
end

showAmmo() -- inferred equivalent call
parent:GetAttributeChangedSignal("Ammo"):Connect(function()
	local ammo = parent:GetAttribute("Ammo") or 0
	local v8

	if magSize() <= ammo then -- inferred equivalent call
		v8 = magSize() -- inferred equivalent call
	else
		v8 = math.min(v6, ammo)
	end

	v6 = v8
	showAmmo() -- inferred equivalent call
end)

local v8 = {
	length = 0.46,
	open = {
		{ 0, 0 },
		{ 0.06, 0.15 },
		{ 0.19, 1, true },
		{ 0.23, 1, true },
		{ 0.36, 0, true }
	},
	pos = {
		{ 0, Vector3.new(0, 0, 0) },
		{ 0.14, Vector3.new(0, -0.025, 0.035) },
		{ 0.23, Vector3.new(0, -0.03, 0.045) },
		{ 0.36, Vector3.new(0, 0.008, -0.012) },
		{ 0.46, Vector3.new(0, 0, 0), true }
	},
	rot = {
		{ 0, Vector3.new(0, 0, 0) },
		{ 0.16, Vector3.new(-4, 0, 4) },
		{ 0.25, Vector3.new(-3, 0, 3) },
		{ 0.36, Vector3.new(2, 0, -1.5) },
		{ 0.46, Vector3.new(0, 0, 0), true }
	}
}

local v9 = {
	{ 0.2, Vector3.new(-0.22, -0.55, 0.18) },
	{ 0.4, Vector3.new(-0.02, -0.1, 0.04) },
	{ 0.48, Vector3.new(0, -0.05, 0.02), true },
	{ 0.6, Vector3.new(0, 0.03, -0.14), true }
}
local v10 = {
	{ 0.2, Vector3.new(-30, 10, 20) },
	{ 0.4, Vector3.new(-8, 0, 4) },
	{ 0.48, Vector3.new(0, 0, 0), true },
	{ 0.6, Vector3.new(0, 0, 0), true }
}

local v11 = {
	{ 0, 0 },
	{ 0.12, 0 },
	{ 0.22, 1, true },
	{ 0.6, 1, true },
	{ 0.8, 0 },
	{ 1, 0 }
}
local v12 = { 0.2, 0.6 }
local v13 = {
	{ 0, Vector3.new(0, 0, 0) },
	{ 0.5, Vector3.new(0, 0, 0) },
	{ 0.6, Vector3.new(0, 0.015, -0.01) },
	{ 0.8, Vector3.new(0, 0, 0) },
	{ 1, Vector3.new(0, 0, 0) }
}

local v14 = false
local v15 = false
local now = nil
local v16 = false
local renderSteppedConnection = nil
local v17 = nil
local v18 = 0

local function clearPose() -- 3 equivalent calls inferred from this helper
	v18 = 0
	v5.pose = CFrame.identity
	v5.leftWeight = 0
	v5.leftOnAmmo = 0
	v5.leftGun = nil
	v5.slideHold = nil
	v5.ammoDelta = CFrame.identity
	v5.ammoVisible = false
	v5.reloadProgress = nil
end

clearPose() -- inferred equivalent call

local function endAnim() -- 3 equivalent calls inferred from this helper
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	v17 = nil
	clearPose() -- inferred equivalent call
end

local function fn()
	if v17 or not v5.active then
		return
	end

	v17 = "pump"
	v18 = 1
	local lastTime = os.clock()
	local v19 = 1
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local v20 = os.clock() - lastTime

		if v19 == 1 and v20 >= 0.09 then
			VoxelSound.shotgunPump("back")
			v19 = 2
		elseif v19 == 2 and v20 >= 0.19 then
			v5:eject()
			v19 = 3
		elseif v19 == 3 and v20 >= 0.33 then
			VoxelSound.shotgunPump("forward")
			v19 = 4
		elseif v19 == 4 and v20 >= 0.36 then
			v7 = v6 > 0
			v5:bump(0.2)
			v19 = 5
		end

		if v8.length <= v20 then
			endAnim() -- inferred equivalent call
		else
			v5.pose = Keyframes.pose(Keyframes.sample(v8.pos, v20), Keyframes.sample(v8.rot, v20))
			local sample = Keyframes.sample(v8.open, v20)
			v5.slideHold = sample
			local v21 = 0.22 * sample
			v5.leftGun = Vector3.new(0, -0.6, -0.8) + newVector3(0, 0, v21)
		end
	end)
end

local function startReload()
	if not v17 and v5.active then
		local v19 = v6

		if not (magSize() <= v19) then -- inferred equivalent call
			v17 = "reload"
			v18 = 1
			v5.aimBlocked = true
			v16 = false
			ReloadShotgun:FireServer(true)
			local v20 = reloadScale() -- inferred equivalent call
			local lastTime = os.clock()
			local v21 = v6
			local count2 = 0
			local v22 = false
			local v23 = nil
			local v24 = -1
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				local v25 = (os.clock() - lastTime) / v20
				local v26 = v6
				local v27 = magSize() <= v26 -- inferred equivalent call

				if (v16 or now) and not v22 then
					v22 = true
				end

				local v28 = math.max(v25 - 0.68, 0)
				local v29 = math.floor(v28 / 0.7)
				local v30 = v28 % 0.7 / 0.7

				if not v23 then
					if v25 >= 0.68 and v24 < v29 and v30 >= 0.6 then
						v24 = v29
						count2 += 1
						local v31 = v6 + 1
						v6 = math.min(v31, magSize()) -- inferred equivalent call
						showAmmo() -- inferred equivalent call
						VoxelSound.shotgunShell()
						v5:bump(0.12)
						local v32 = v6
						v27 = magSize() <= v32 -- inferred equivalent call
					end

					local v31 = v25 < 0.68 or v30 < 0.18 or v29 <= v24

					if v27 and (v29 <= v24 and v30 >= 0.8 or v25 < 0.68) or v22 and v31 then
						v23 = v25
						ReloadShotgun:FireServer(false)
					end
				end

				local v31

				if v23 then
					v31 = 1 - math.clamp((v25 - v23) / 0.3, 0, 1)
				else
					v31 = math.clamp(v25 / 0.68, 0, 1)
				end

				local leftWeight = v31 * v31 * (3 - 2 * v31)

				if v23 and v25 - v23 >= 0.3 then
					endAnim() -- inferred equivalent call
					v5.aimBlocked = false

					if not v7 and v6 > 0 and v5.active then
						fn()
					end
				else
					local v32 = (not (v25 >= 0.68) or v23) and Vector3.new(0, 0, 0) or Keyframes.sample(v13, v30)
					v5.pose = Keyframes.pose(
						Vector3.new(-0.07, 0.16, 0.04) * leftWeight + v32,
						Vector3.new(10, 6, -30) * leftWeight
					)
					v5.leftWeight = leftWeight
					v5.leftTarget = Vector3.new(-0.75, -2.3, -0.9)
					local v34

					if v25 >= 0.68 then
						v34 = not v23 and v24 < v29
					else
						v34 = false
					end

					v5.leftOnAmmo = not v34 and 0 or Keyframes.sample(v11, v30)
					v5.ammoGrab = Vector3.new(0, -0.2, 0.02)
					local ammoVisible

					if v34 then
						if v12[1] <= v30 then
							ammoVisible = v30 < v12[2]
						else
							ammoVisible = false
						end
					else
						ammoVisible = v34
					end

					v5.ammoVisible = ammoVisible

					if ammoVisible then
						v5.ammoDelta = Keyframes.pose(Keyframes.sample(v9, v30), Keyframes.sample(v10, v30))
					end

					local v36 = math.max(magSize() - v21, 1) -- inferred equivalent call
					v5.reloadProgress = math.clamp((count2 + (not v34 and 0 or v30)) / v36, 0, 1)
				end
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

	v7 = v7 and v6 > 0

	if v6 > 0 and not v7 then
		v7 = true
	end

	clearPose() -- inferred equivalent call
	showAmmo() -- inferred equivalent call
end)
parent.Unequipped:Connect(function()
	v14 = false
	v15 = false
	now = nil
	v16 = false

	if v17 == "reload" then
		ReloadShotgun:FireServer(false)
	end

	if v17 then
		endAnim() -- inferred equivalent call
		v5.aimBlocked = false
	end
end)

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local function spreadDir(vector3: Vector3, p: number)
	local v19 = math.rad(p) * math.sqrt((random:NextNumber()))
	return (CFrame.lookAt(Vector3.new(0, 0, 0), vector3) * CFrame.Angles(
		0,
		0,
		random:NextNumber() * 3.141592653589793 * 2
	) * CFrame.Angles(v19, 0, 0)).LookVector
end

local function pattern(vector3: Vector3, p: number)
	local cframe2 = CFrame.lookAt(Vector3.new(0, 0, 0), vector3)
	local v19 = random:NextNumber() * 3.141592653589793 * 2
	local lookVectors = table.create(8)

	for i = 1, 8 do
		local v20, v21

		if i == 1 then
			v20 = 0.18 * random:NextNumber()
			v21 = random:NextNumber() * 3.141592653589793 * 2
		else
			v20 = 0.78 + 0.22 * (random:NextNumber() * 2 - 1)
			v21 = v19 + (i - 2) / 7 * 3.141592653589793 * 2 + (random:NextNumber() * 2 - 1) * 0.3
		end

		lookVectors[i] = (cframe2 * CFrame.Angles(0, 0, v21) * CFrame.Angles(math.rad(p * v20), 0, 0)).LookVector
	end

	return lookVectors
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
	local v19 = currentCamera.ViewportSize * 0.5
	local ray = VR.ray(currentCamera, v19.X, v19.Y)
	local aimAlpha = v5.aimAlpha
	local v20 = humanoid and humanoid.MoveDirection.Magnitude > 0.1 and true or false
	local hipSpread = Viewmodel.hipSpread(aimAlpha)
	local v21 = (((v20 and 0.6 or 0) + 3.2) * (1 - aimAlpha) + 2.2 * aimAlpha) * hipSpread
	local lookVector = spreadDir(aimDirection(currentCamera), 0.8 * (1 - aimAlpha) * hipSpread) -- inferred equivalent call
	local muzzle = v5:muzzle(children)
	local units = {}

	for k, unit in pattern(lookVector, v21) do
		local raycastResult = workspace:Raycast(ray.Origin, unit * 150, raycastParams)
		local v22

		if raycastResult then
			v22 = raycastResult.Position
		else
			v22 = ray.Origin + unit * 150
		end

		if raycastResult then
			local v23

			if raycastResult.Instance == workspace.Terrain then
				v23 = raycastResult.Material ~= Enum.Material.Water
			else
				v23 = false
			end

			local travelTime = Tracers.travelTime(v5.muzzleWorld, v22)
			task.delay(travelTime, ImpactFX.bullet, raycastResult.Position, raycastResult.Normal, unit, v23)
			HitPredict.shot(raycastResult, travelTime)
		end

		local v23 = v22 - muzzle

		if not (v23.Magnitude < 0.1) then
			unit = v23.Unit
		end

		units[k] = unit

		if k % 2 == 1 then
			Tracers.fire(v5.muzzleWorld, v22)
		end
	end

	FireShotgun:FireServer(muzzle, table.unpack(units))
	VoxelSound.ownShotgun(1)
	v5:fired()
	kickView(aimAlpha) -- inferred equivalent call
	v6 -= 1
	v7 = false
	showAmmo() -- inferred equivalent call
end

local function heldStep(fn2)
	local renderSteppedConnection2 = nil
	local lastTime = 0
	local function start()
		if renderSteppedConnection2 then
			return
		end

		local v19 = not (lastTime > 0) and 0 or os.clock() - lastTime
		renderSteppedConnection2 = RunService.RenderStepped:Connect(function(dt)
			if v19 > 0 then
				dt = math.max(dt, v19)
				v19 = 0
			end

			fn2(dt)
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
		local v19 = not (lastTime > 0) and 0 or os.clock() - lastTime
		renderSteppedConnection2 = RunService.RenderStepped:Connect(function(dt)
			if v19 > 0 then
				dt = math.max(dt, v19)
				v19 = 0
			end

			fn2(dt)
		end)
	end
end

heldStep(function()
	v5.firing = v14 and v17 ~= "reload"

	if not v5.active then
		return
	end

	local now2 = os.clock()

	if now and now2 - now > 0.2 then
		now = nil
	end

	if v17 == "reload" or not (now or v16 or v15 and v14) or (v17 == "pump" or v18 > 0.3) then
		return
	end

	if v6 <= 0 then
		now = nil
		v16 = false
		startReload()
	else
		if not v7 then
			fn()
			return
		end

		if not v5:ready() then
			return
		end

		now = nil
		v16 = false
		shoot()
		task.delay(0.17, function()
			if v5.active and parent.Parent == LocalPlayer.Character then
				fn()

				if v6 <= 0 then
					task.delay(v8.length + 0.1, startReload)
				end
			end
		end)
	end
end)

local function press(flag: boolean) -- 2 equivalent calls inferred from this helper
	v14 = true
	v15 = flag
	now = os.clock()

	if v17 == "reload" then
		v16 = true
	end
end
local function release()
	v14 = false
	v15 = false
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
	range = 150,
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