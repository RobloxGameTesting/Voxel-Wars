local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local parent = script.Parent

local Gunsmith = ReplicatedStorage:FindFirstChild("Gunsmith")
local Gunsmith2

if Gunsmith then
	Gunsmith2 = require(Gunsmith:WaitForChild("Gunsmith"))
else
	Gunsmith2 = nil
end

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
local FireSMG = Remotes:WaitForChild("FireSMG")
local ReloadSMG = Remotes:WaitForChild("ReloadSMG")

local function magSize() -- 7 equivalent calls inferred from this helper
	local magSize2 = parent:GetAttribute("MagSize")
	return if type(magSize2) == "number" then magSize2 else 32
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
local v2 = "SMGRecoilUndo" .. guid
local v3 = "SMGRecoil" .. guid
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
	local v5, v6

	if Gunsmith2 then
		v5, v6 = Gunsmith2.kick(parent)
	else
		v5 = 1
		v6 = 1
	end

	v:shot(aimAlpha, v5, v6)
end

local v5 = Viewmodel.new(parent, {
	name = "SMG",
	weight = 0.7,
	hold = CFrame.new(0.62, -0.74, -1.58) * CFrame.Angles(
		0.03490658503988659,
		0.03490658503988659,
		0.017453292519943295
	),
	rightHand = Vector3.new(0, -0.3, 0.17),
	leftHand = Vector3.new(0, -0.4, -0.55),
	armThickness = 0.5,
	muzzle = muzzleAttachment.Position,
	aimPoint = Vector3.new(0, 0.26, 0),
	aimDistance = 0.961,
	aimFov = 45.2,
	aimMove = 0.85,
	reach = 2.5,
	sprintHold = CFrame.new(-0.2, -1.2, -1.6) * CFrame.Angles(
		-0.5113814708343386,
		1.08035880698449,
		0.46600291028248597
	),
	hipKick = Vector3.new(0.018, 0.01, 0.16),
	hipKickRot = Vector3.new(0.8, 0.7, 1.3),
	aimKick = Vector3.new(0.006, 0.004, 0.04),
	aimKickRot = Vector3.new(0.25, 0.3, 0.9),
	recoilTime = 0.075,
	punch = 0.4,
	flash = true,
	flashScale = 0.85,
	eject = Vector3.new(0.09, 0.02, -0.02)
})

if Gunsmith2 then
	Gunsmith2.applySpec(parent, v5.spec)
end

local function liveMuzzle()
	return v5.muzzleWorld
end

Tracers.setOwnMuzzle(liveMuzzle)

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

local v7 = {
	{ 0, 0 },
	{ 0.4, 0.4 },
	{ 0.6, 0.46 },
	{ 1.25, 0.74 },
	{ 1.5, 1.06 }
}

local newVector3 = Vector3.new

local v8 = {
	{ 0, Vector3.new(0, 0, 0) },
	{ 0.08, Vector3.new(0, 0.02, 0) },
	{ 0.24, Vector3.new(-0.080000006, 0.24000001, 0.048) },
	{ 0.4, Vector3.new(-0.1, 0.3, 0.06) },
	{ 0.46, Vector3.new(-0.1, 0.25, 0.06) },
	{ 0.56, (Vector3.new(-0.16, 0.24, 0)):Lerp(Vector3.new(-0.1, 0.3, 0.06), 0.3) },
	{ 0.64, Vector3.new(-0.16, 0.19999999, 0) },
	{ 0.74, Vector3.new(-0.16, 0.24, 0) },
	{ 1.02, Vector3.new(-0.14, 0.29999998, 0) },
	{ 1.06, Vector3.new(-0.14, 0.29999998, 0), true },
	{ 1.1, Vector3.new(-0.14999999, 0.24, 0) },
	{ 1.16, Vector3.new(-0.14999999, 0.26999998, 0) }
}

local v9 = {
	{ 0, Vector3.new(0, 0, 0) },
	{ 0.08, Vector3.new(4, 0, 0) },
	{ 0.24, Vector3.new(12.8, 6.4, -20.800001) },
	{ 0.4, Vector3.new(16, 8, -26) },
	{ 0.46, Vector3.new(12, 8, -21) },
	{ 0.56, (Vector3.new(10, 16, -34)):Lerp(Vector3.new(16, 8, -26), 0.3) },
	{ 0.64, Vector3.new(3, 20, -34) },
	{ 0.74, Vector3.new(10, 16, -34) },
	{ 1.02, Vector3.new(15, 12, -34) },
	{ 1.06, Vector3.new(15, 12, -34), true },
	{ 1.1, Vector3.new(7, 16, -37) },
	{ 1.16, Vector3.new(14, 10, -40) }
}

local function join(p, items)
	local clone = table.clone(p)

	for _, item in items do
		table.insert(clone, item)
	end

	return clone
end

local clone = table.clone(v7)

local v10 = {
	length = 1.62,
	commit = 1.06,
	timing = 0,
	pos = 0,
	rot = 0,
	leftWeight = 0,
	leftOnAmmo = 0,
	charger = nil,
	cues = 0
}
local v11 = false

for _, v12 in {
	{ 2.15, 1.62 }
} do
	table.insert(clone, v12)
end

v10.timing = clone
local clone2 = table.clone(v8)

for _, v12 in {
	{ 1.3, Vector3.new(-0.055999998, 0.084, 0) },
	{ 1.48, Vector3.new(0, -0.02, 0) },
	{ 1.62, Vector3.new(0, 0, 0), true }
} do
	table.insert(clone2, v12)
end

v10.pos = clone2
local clone3 = table.clone(v9)

for _, v12 in {
	{ 1.3, Vector3.new(3, 4.8, -10.200001) },
	{ 1.48, Vector3.new(-3, 0, 3) },
	{ 1.62, Vector3.new(0, 0, 0), true }
} do
	table.insert(clone3, v12)
end

v10.rot = clone3

v10.leftWeight = {
	{ 0, 0 },
	{ 0.1, 0.1 },
	{ 0.24, 1, true },
	{ 1.1, 1, true },
	{ 1.36, 0, true }
}
v10.leftOnAmmo = {
	{ 0, 0 },
	{ 0.22, 0, true },
	{ 0.36, 1, true }
}

v10.cues = { 0.44, 1.06 }
local clone4 = table.clone(v7)

local v12 = {
	length = 2.16,
	commit = 1.66,
	timing = 0,
	pos = 0,
	rot = 0,
	leftWeight = 0,
	leftOnAmmo = 0,
	charger = 0,
	cues = 0
}

for _, v13 in {
	{ 2.2, 1.66 },
	{ 2.7, 2.16 }
} do
	table.insert(clone4, v13)
end

v12.timing = clone4
local clone5 = table.clone(v8)

for _, v13 in {
	{ 1.36, Vector3.new(-0.06, 0.120000005, 0.06) },
	{ 1.46, Vector3.new(-0.06, 0.15, 0.06), true },
	{ 1.52, Vector3.new(-0.03, 0.15, 0.24), true },
	{ 1.6, Vector3.new(-0.04, 0.15, 0.22999999), true },
	{ 1.66, Vector3.new(-0.03, 0.16000001, 0.24) },
	{ 1.72, Vector3.new(0, 0.14, -0.03) },
	{ 1.8, Vector3.new(0, 0.12, -0.03) },
	{ 1.92, Vector3.new(0, 0.08, -0.03) },
	{ 2.06, Vector3.new(0, -0.015, 0) },
	{ 2.16, Vector3.new(0, 0, 0), true }
} do
	table.insert(clone5, v13)
end

v12.pos = clone5
local clone6 = table.clone(v9)

for _, v13 in {
	{ 1.36, Vector3.new(10, 26, -16) },
	{ 1.46, Vector3.new(6, 22, -10), true },
	{ 1.52, Vector3.new(2, 26, -8), true },
	{ 1.6, Vector3.new(3, 22, -8), true },
	{ 1.66, Vector3.new(1, 28, -8) },
	{ 1.72, Vector3.new(20, -4, 8) },
	{ 1.8, Vector3.new(14, -6, 8) },
	{ 1.92, Vector3.new(0, -2, 4) },
	{ 2.06, Vector3.new(-3, 0, 4) },
	{ 2.16, Vector3.new(0, 0, 0), true }
} do
	table.insert(clone6, v13)
end

v12.rot = clone6

v12.leftWeight = {
	{ 0, 0 },
	{ 0.1, 0.1 },
	{ 0.24, 1, true },
	{ 1.1, 1, true },
	{ 1.28, 0.3 },
	{ 1.42, 0, true },
	{ 1.64, 0, true },
	{ 1.7, 1, true },
	{ 1.96, 1, true },
	{ 2.06, 0, true }
}

v12.leftOnAmmo = {
	{ 0, 0 },
	{ 0.22, 0, true },
	{ 0.36, 1, true },
	{ 1.4, 1, true },
	{ 1.5, 0, true }
}
v12.charger = { 1.1, 1.7 }
v12.cues = { 0.44, 1.06, 1.46, 1.66 }

local v13 = {
	{ 0, Vector3.new(0, 0, 0) },
	{ 0.44, Vector3.new(0, 0, 0), true },
	{ 0.5, Vector3.new(-0.04, -0.45, 0.08) },
	{ 0.56, Vector3.new(-0.06, -0.56, 0.09) },
	{ 0.64, Vector3.new(-0.08, -0.7, 0.11) },
	{ 0.74, Vector3.new(-0.02, -0.45, 0.04) },
	{ 0.98, Vector3.new(0, -0.22, 0.015) },
	{ 1.03, Vector3.new(0, -0.09, 0) },
	{ 1.06, Vector3.new(0, 0, 0), true }
}

local v14 = {
	{ 0, Vector3.new(0, 0, 0) },
	{ 0.44, Vector3.new(0, 0, 0), true },
	{ 0.5, Vector3.new(-12, 0, 10) },
	{ 0.64, Vector3.new(-20, 0, 18) },
	{ 0.74, Vector3.new(-8, 0, 4) },
	{ 1, Vector3.new(-3, 0, 0) },
	{ 1.06, Vector3.new(0, 0, 0), true }
}

local function beatsAt(timing, p: number)
	for i = 2, #timing do
		local item = timing[i - 1]
		local item2 = timing[i]

		if p <= item2[1] then
			return item[2] + (item2[2] - item[2]) * (p - item[1]) / (item2[1] - item[1])
		end
	end

	local item = timing[#timing]
	return item[2] + (p - item[1])
end

local function sample(data, p: number, p2: number)
	v5.pose = CFrame.identity:Lerp(Keyframes.pose(Keyframes.sample(data.pos, p), Keyframes.sample(data.rot, p)), p2)
	v5.leftWeight = Keyframes.sample(data.leftWeight, p) * p2
	v5.leftOnAmmo = Keyframes.sample(data.leftOnAmmo, p)
	v5.leftTarget = Vector3.new(-1.4, -3.2, -1.2)
	local charger = data.charger
	v5.leftGun = charger and charger[1] < p and p < charger[2] and Vector3.new(-0.11, 0.04, -0.3) or nil
	v5.ammoGrab = Vector3.new(0, -0.47, -0.21)
	v5.ammoDelta = Keyframes.pose(Keyframes.sample(v13, p), Keyframes.sample(v14, p))
	local reloadProgress

	if p < data.commit then
		reloadProgress = p / data.commit
	end

	v5.reloadProgress = reloadProgress
end

local v15 = false
local renderSteppedConnection = nil
local flag = false
local v16 = 0

local function endReload() -- 3 equivalent calls inferred from this helper
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	v11 = false
	flag = false
	v16 = 0
	v5.aimBlocked = false
	v5.pose = CFrame.identity
	v5.leftWeight = 0
	v5.leftOnAmmo = 0
	v5.leftGun = nil
	v5.ammoDelta = CFrame.identity
	v5.reloadProgress = nil
end

local function startReload()
	if not flag and v5.active then
		local v17 = v6

		if not (magSize() <= v17) then -- inferred equivalent call
			local v18

			if v6 <= 0 then
				v18 = v12
			else
				v18 = v10
			end

			v11 = true
			flag = true
			v16 = 1
			v5.aimBlocked = true
			ReloadSMG:FireServer()
			local now = os.clock()
			local v19 = 1
			local v20 = nil
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				local now2 = os.clock()
				local v21 = beatsAt(v18.timing, (now2 - now) / reloadScale()) -- inferred equivalent call

				if v11 and v18.commit <= v21 then
					v11 = false
					v5.aimBlocked = false
					v6 = magSize() -- inferred equivalent call
					showAmmo() -- inferred equivalent call
				end

				if not v11 and not v20 and (v15 or v5.aiming) then
					v20 = now2
				end

				v16 = not v20 and 1 or 1 - (now2 - v20) / 0.12
				local cue = v18.cues[v19]

				if cue and cue <= v21 and not v20 then
					local _position = workspace.CurrentCamera.CFrame.Position

					if cue == 0.44 then
						VoxelSound.reload("smg", "magOut", 0.5)
					elseif cue == 1.06 then
						VoxelSound.reload("smg", "magIn", 0.9)
						v5:bump(0.5)
					elseif cue == 1.66 then
						VoxelSound.reload("smg", "boltRelease", 0.8)
						v5:bump(0.3)
					else
						VoxelSound.reload("smg", "chargeBack", 0.7)
					end

					v19 += 1
				end

				if not (v16 <= 0 or v18.length <= v21) then
					sample(v18, math.min(v21, v18.length), v16)
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

	showAmmo() -- inferred equivalent call
end)
parent.Unequipped:Connect(function()
	if flag then
		endReload() -- inferred equivalent call
	end
end)
parent:GetAttributeChangedSignal("GsRefit"):Connect(function()
	if flag then
		endReload() -- inferred equivalent call
	end

	v5:rebuild()
	v6 = math.min(v6, parent:GetAttribute("Ammo") or 0)
	showAmmo() -- inferred equivalent call
end)

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
local v17 = 0
local v18 = 0

local function spreadDir(vector3: Vector3, p: number)
	local v19 = math.rad(p) * math.sqrt((random:NextNumber()))
	return (CFrame.lookAt(Vector3.new(0, 0, 0), vector3) * CFrame.Angles(
		0,
		0,
		random:NextNumber() * 3.141592653589793 * 2
	) * CFrame.Angles(v19, 0, 0)).LookVector
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
	local v21 = not Gunsmith2 and 1 or Gunsmith2.hip(parent)
	local v22 = not Gunsmith2 and 1 or Gunsmith2.bloomAt(parent, aimAlpha)
	local v23 = (((v20 and 0.5 or 0) + 1.3) * (1 - aimAlpha) * v21 + (0.05 + (not v20 and 0 or 0.27 + (not Gunsmith2 and 0 or Gunsmith2.moveSpread(parent)))) * aimAlpha + v18 * v22 * (1 - 0.7 * aimAlpha) * Viewmodel.hipBloom(aimAlpha)) * Viewmodel.hipSpread(aimAlpha)
	local v24 = aimDirection(currentCamera) -- inferred equivalent call
	local lookVector = spreadDir(v24, v23)
	local raycastResult = workspace:Raycast(ray.Origin, lookVector * 500, raycastParams)
	local v25

	if raycastResult then
		v25 = raycastResult.Position
	else
		v25 = ray.Origin + lookVector * 500
	end

	local muzzle = v5:muzzle(children)

	if raycastResult then
		local v26

		if raycastResult.Instance == workspace.Terrain then
			v26 = raycastResult.Material ~= Enum.Material.Water
		else
			v26 = false
		end

		local travelTime = Tracers.travelTime(v5.muzzleWorld, v25)
		task.delay(travelTime, ImpactFX.bullet, raycastResult.Position, raycastResult.Normal, lookVector, v26)
		HitPredict.shot(raycastResult, travelTime)
	end

	local v26 = v25 - muzzle

	if v26.Magnitude < 0.1 then
		v26 = lookVector
	end

	FireSMG:FireServer(muzzle, v26.Unit, workspace:GetServerTimeNow(), v24, v23)
	Tracers.fire(v5.muzzleWorld, v25)
	VoxelSound.ownSMG(1, parent:GetAttribute("GsQuiet"))
	v5:fired()
	kickView(aimAlpha) -- inferred equivalent call
	v18 = math.min(v18 + 0.12, 1.5)
	v6 -= 1
	showAmmo() -- inferred equivalent call
end

local function heldStep(fn)
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
		local v19 = not (lastTime > 0) and 0 or os.clock() - lastTime
		renderSteppedConnection2 = RunService.RenderStepped:Connect(function(dt)
			if v19 > 0 then
				dt = math.max(dt, v19)
				v19 = 0
			end

			fn(dt)
		end)
	end
end

heldStep(function(p)
	v18 = v:cool(v18, 6, p)
	v5.firing = v15 and not v11

	if not v15 or v11 or not v5.active then
		return
	end

	if v6 <= 0 then
		startReload()
		return
	end

	if not v5:ready() or v16 > 0.3 then
		return
	end

	local now = os.clock()

	if now < v17 then
		return
	end

	v17 = math.max(v17 + 0.072, now - 0.036)
	shoot()

	if v6 <= 0 then
		task.delay(0.15, startReload)
	end
end)

local function startFire()
	v15 = true
end
local function stopFire()
	v15 = false
end
local function setAim(aiming: boolean) -- 2 equivalent calls inferred from this helper
	if aiming and not v5.active then
		return
	end

	v5.aiming = aiming
end

parent.Activated:Connect(startFire)
parent.Deactivated:Connect(stopFire)

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
	range = 500,
	assist = true,
	startFire = startFire,
	stopFire = stopFire,
	setAim = setAim,
	isAiming = function()
		return v5.aiming
	end,
	reload = startReload
})