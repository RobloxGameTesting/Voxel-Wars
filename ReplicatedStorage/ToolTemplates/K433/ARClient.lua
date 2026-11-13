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
local RifleSpecs = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("RifleSpecs"))
local Remotes = Voxel:WaitForChild("Remotes")
local FireRifle = Remotes:WaitForChild("FireRifle")
local ReloadRifle = Remotes:WaitForChild("ReloadRifle")

local v = RifleSpecs.of(parent.Name)
assert(v, "[ARClient] no RifleSpecs entry for " .. parent.Name)
local view = v.view

local interval = v.interval
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
local spread = v.spread

local GunRecoil = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("GunRecoil"))
local v2 = GunRecoil.new(parent.Name)
local cframe = nil

local HttpService = game:GetService("HttpService")
local guid = HttpService:GenerateGUID(false)
local v3 = "ARRecoilUndo" .. guid
local v4 = "ARRecoil" .. guid
local function recoilGone(): boolean -- 1 equivalent call inferred from this helper
	if parent:IsDescendantOf(game) then
		return false
	end

	RunService:UnbindFromRenderStep(v3)
	RunService:UnbindFromRenderStep(v4)
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

local Gunsmith = ReplicatedStorage:FindFirstChild("Gunsmith")
local Gunsmith2

if Gunsmith then
	Gunsmith2 = require(Gunsmith:WaitForChild("Gunsmith"))
else
	Gunsmith2 = nil
end

local function aimDirection(currentCamera) -- 1 equivalent call inferred from this helper
	local frame = VR.frame(currentCamera)

	if cframe then
		frame *= cframe:Inverse()
	end

	return (frame * CFrame.Angles(math.rad(v2.pitch), math.rad(v2.yaw), 0)).LookVector
end

local function kickView(aimAlpha: number) -- 1 equivalent call inferred from this helper
	local v6, v7

	if Gunsmith2 then
		v6, v7 = Gunsmith2.kick(parent)
	else
		v6 = 1
		v7 = 1
	end

	v2:shot(aimAlpha, v6, v7)
end

local v6 = Viewmodel.new(parent, {
	name = v.name,
	weight = view.weight,
	hold = view.hold,
	rightHand = view.rightHand,
	leftHand = view.leftHand,
	armThickness = 0.5,
	muzzle = muzzleAttachment.Position,
	aimPoint = view.aimPoint,
	aimDistance = view.aimDistance,
	aimFov = view.aimFov,
	aimMove = view.aimMove,
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
	eject = view.eject
})

if Gunsmith2 then
	Gunsmith2.applySpec(parent, v6.spec)
end

local v7 = { 0.45, 0.85 }
local v8 = nil
local parts = {}
local v9 = -1

local function heldStep(fn)
	local renderSteppedConnection = nil
	local lastTime = 0
	local function start()
		if renderSteppedConnection then
			return
		end

		local v10 = not (lastTime > 0) and 0 or os.clock() - lastTime
		renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
			if v10 > 0 then
				dt = math.max(dt, v10)
				v10 = 0
			end

			fn(dt)
		end)
	end
	parent.Equipped:Connect(start)
	parent.Unequipped:Connect(function()
		if renderSteppedConnection then
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
			lastTime = os.clock()
		end
	end)

	if parent.Parent ~= nil and parent.Parent == LocalPlayer.Character and not renderSteppedConnection then
		local v10 = not (lastTime > 0) and 0 or os.clock() - lastTime
		renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
			if v10 > 0 then
				dt = math.max(dt, v10)
				v10 = 0
			end

			fn(dt)
		end)
	end
end

heldStep(function()
	local model = v6.model

	if model ~= v8 then
		v8 = model
		v9 = -1
		table.clear(parts)

		if model then
			for _, part in model:GetChildren() do
				if part:IsA("BasePart") and part:GetAttribute("ScopeTube") then
					table.insert(parts, part)
				end
			end
		end
	end

	if #parts == 0 then
		return
	end

	local localTransparencyModifier = math.floor(math.clamp((v6.aimAlpha - v7[1]) / (v7[2] - v7[1]), 0, 1) * 20 + 0.5) / 20

	if localTransparencyModifier ~= v9 then
		v9 = localTransparencyModifier

		for _, v10 in parts do
			v10.LocalTransparencyModifier = localTransparencyModifier
		end
	end
end)

local function liveMuzzle()
	return v6.muzzleWorld
end

Tracers.setOwnMuzzle(liveMuzzle)

local v10 = parent:GetAttribute("Ammo")

if not v10 then
	v10 = parent:GetAttribute("MagSize")

	if type(v10) ~= "number" then
		v10 = mag
	end
end

local function showAmmo() -- 6 equivalent calls inferred from this helper
	v6:setAmmo(v10)
end

showAmmo() -- inferred equivalent call
parent:GetAttributeChangedSignal("Ammo"):Connect(function()
	local ammo = parent:GetAttribute("Ammo") or 0
	local v11 = magSize() -- inferred equivalent call
	local v12

	if v11 <= ammo then
		v12 = parent:GetAttribute("MagSize")

		if type(v12) ~= "number" then
			v12 = mag
		end
	else
		v12 = math.min(v10, ammo)
	end

	v10 = v12
	showAmmo() -- inferred equivalent call
end)

local pace = v.pace

local charger = view.charger
local magGrab = view.magGrab

local newVector3 = Vector3.new

local v11 = {
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

local v12 = {
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

local clone = table.clone(v11)

local v13 = {
	length = 1.62,
	commit = 1.06,
	pos = 0,
	rot = 0,
	leftWeight = 0,
	leftOnAmmo = 0,
	charger = nil,
	cues = 0
}
local v14 = false

for _, v15 in {
	{ 1.3, Vector3.new(-0.055999998, 0.084, 0) },
	{ 1.48, Vector3.new(0, -0.02, 0) },
	{ 1.62, Vector3.new(0, 0, 0), true }
} do
	table.insert(clone, v15)
end

v13.pos = clone
local clone2 = table.clone(v12)

for _, v15 in {
	{ 1.3, Vector3.new(3, 4.8, -10.200001) },
	{ 1.48, Vector3.new(-3, 0, 3) },
	{ 1.62, Vector3.new(0, 0, 0), true }
} do
	table.insert(clone2, v15)
end

v13.rot = clone2
v13.leftWeight = {
	{ 0, 0 },
	{ 0.1, 0.1 },
	{ 0.24, 1, true },
	{ 1.1, 1, true },
	{ 1.36, 0, true }
}
v13.leftOnAmmo = {
	{ 0, 0 },
	{ 0.22, 0, true },
	{ 0.36, 1, true }
}

v13.cues = { 0.44, 1.06 }
local clone3 = table.clone(v11)

local v15 = {
	length = 2.16,
	commit = 1.66,
	pos = 0,
	rot = 0,
	leftWeight = 0,
	leftOnAmmo = 0,
	charger = 0,
	cues = 0
}

for _, v16 in {
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
	table.insert(clone3, v16)
end

v15.pos = clone3
local clone4 = table.clone(v12)

for _, v16 in {
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
	table.insert(clone4, v16)
end

v15.rot = clone4

v15.leftWeight = {
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

v15.leftOnAmmo = {
	{ 0, 0 },
	{ 0.22, 0, true },
	{ 0.36, 1, true },
	{ 1.4, 1, true },
	{ 1.5, 0, true }
}
v15.charger = { 1.1, 1.7 }
v15.cues = { 0.44, 1.06, 1.46, 1.66 }

local v16 = {
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

local v17 = {
	{ 0, Vector3.new(0, 0, 0) },
	{ 0.44, Vector3.new(0, 0, 0), true },
	{ 0.5, Vector3.new(-12, 0, 10) },
	{ 0.64, Vector3.new(-20, 0, 18) },
	{ 0.74, Vector3.new(-8, 0, 4) },
	{ 1, Vector3.new(-3, 0, 0) },
	{ 1.06, Vector3.new(0, 0, 0), true }
}

local function sample(data, p: number, p2: number)
	v6.pose = CFrame.identity:Lerp(Keyframes.pose(Keyframes.sample(data.pos, p), Keyframes.sample(data.rot, p)), p2)
	v6.leftWeight = Keyframes.sample(data.leftWeight, p) * p2
	v6.leftOnAmmo = Keyframes.sample(data.leftOnAmmo, p)
	v6.leftTarget = Vector3.new(-1.4, -3.2, -1.2)
	local charger2 = data.charger
	local leftGun

	if charger2 and charger2[1] < p and p < charger2[2] then
		leftGun = charger
	end

	v6.leftGun = leftGun
	v6.ammoGrab = magGrab
	v6.ammoDelta = Keyframes.pose(Keyframes.sample(v16, p), Keyframes.sample(v17, p))
	local reloadProgress

	if p < data.commit then
		reloadProgress = p / data.commit
	end

	v6.reloadProgress = reloadProgress
end

local v18 = false
local renderSteppedConnection = nil
local flag = false
local v19 = 0

local function endReload() -- 3 equivalent calls inferred from this helper
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	v14 = false
	flag = false
	v19 = 0
	v6.aimBlocked = false
	v6.pose = CFrame.identity
	v6.leftWeight = 0
	v6.leftOnAmmo = 0
	v6.leftGun = nil
	v6.ammoDelta = CFrame.identity
	v6.reloadProgress = nil
end

local function startReload()
	if not flag and v6.active then
		local v20 = v10

		if not (magSize() <= v20) then -- inferred equivalent call
			local v21

			if v10 <= 0 then
				v21 = v15
			else
				v21 = v13
			end

			local v22

			if v21 == v15 then
				v22 = pace.empty
			else
				v22 = pace.tactical
			end

			v14 = true
			flag = true
			v19 = 1
			v6.aimBlocked = true
			ReloadRifle:FireServer()
			local now = os.clock()
			local v23 = 1
			local v24 = nil
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				local now2 = os.clock()
				local v25 = (now2 - now) / (v22 * reloadScale()) -- inferred equivalent call

				if v14 and v21.commit <= v25 then
					v14 = false
					v6.aimBlocked = false
					v10 = magSize() -- inferred equivalent call
					showAmmo() -- inferred equivalent call
				end

				if not v14 and not v24 and (v18 or v6.aiming) then
					v24 = now2
				end

				v19 = not v24 and 1 or 1 - (now2 - v24) / 0.12
				local cue = v21.cues[v23]

				if cue and cue <= v25 and not v24 then
					local _position = workspace.CurrentCamera.CFrame.Position

					if cue == 0.44 then
						VoxelSound.reload("rifle", "magOut", 0.5)
					elseif cue == 1.06 then
						VoxelSound.reload("rifle", "magIn", 0.9)
						v6:bump(0.5)
					elseif cue == 1.66 then
						VoxelSound.reload("rifle", "boltRelease", 0.8)
						v6:bump(0.3)
					else
						VoxelSound.reload("rifle", "chargeBack", 0.7)
					end

					v23 += 1
				end

				if not (v19 <= 0 or v21.length <= v25) then
					sample(v21, math.min(v25, v21.length), v19)
					return
				end

				endReload() -- inferred equivalent call
			end)
		end
	end
end

parent.Equipped:Connect(function()
	Tracers.setOwnMuzzle(liveMuzzle)
	v10 = math.min(v10, parent:GetAttribute("Ammo") or 0)
	local ammo = parent:GetAttribute("Ammo") or 0

	if magSize() <= ammo then -- inferred equivalent call
		v10 = magSize() -- inferred equivalent call
	end

	showAmmo() -- inferred equivalent call
end)
parent.Unequipped:Connect(function()
	v18 = false

	if flag then
		endReload() -- inferred equivalent call
	end
end)
parent:GetAttributeChangedSignal("GsRefit"):Connect(function()
	v18 = false

	if flag then
		endReload() -- inferred equivalent call
	end

	v6:rebuild()
	v10 = math.min(v10, parent:GetAttribute("Ammo") or 0)
	showAmmo() -- inferred equivalent call
end)

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
local v20 = 0
local v21 = 0

local function spreadDir(vector3: Vector3, p: number)
	local v22 = math.rad(p) * math.sqrt((random:NextNumber()))
	return (CFrame.lookAt(Vector3.new(0, 0, 0), vector3) * CFrame.Angles(
		0,
		0,
		random:NextNumber() * 3.141592653589793 * 2
	) * CFrame.Angles(v22, 0, 0)).LookVector
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
	local v22 = currentCamera.ViewportSize * 0.5
	local ray = VR.ray(currentCamera, v22.X, v22.Y)
	local aimAlpha = v6.aimAlpha
	local v23 = humanoid and humanoid.MoveDirection.Magnitude > 0.1 and true or false
	local v24

	if humanoid == nil then
		v24 = false
	else
		v24 = humanoid.FloorMaterial == Enum.Material.Air
	end

	local hip = spread.hip
	local v25

	if v24 then
		v25 = spread.hipJump
	else
		v25 = not v23 and 0 or spread.moving
	end

	local v26 = hip + v25
	local aim = spread.aim
	local v27

	if v24 then
		v27 = spread.aimJump
	else
		v27 = not v23 and 0 or spread.aimMoving + (not Gunsmith2 and 0 or Gunsmith2.moveSpread(parent))
	end

	local v28 = aim + v27
	local v29 = not Gunsmith2 and 1 or Gunsmith2.hip(parent)
	local v30 = not Gunsmith2 and 1 or Gunsmith2.bloomAt(parent, aimAlpha)
	local v31 = (v26 * (1 - aimAlpha) * v29 + v28 * aimAlpha + v21 * v30 * (1 + (spread.aimBloom - 1) * aimAlpha) * Viewmodel.hipBloom(aimAlpha)) * Viewmodel.hipSpread(aimAlpha)
	local v32 = aimDirection(currentCamera) -- inferred equivalent call
	local lookVector = spreadDir(v32, v31)
	local raycastResult = workspace:Raycast(ray.Origin, lookVector * 500, raycastParams)
	local v34

	if raycastResult then
		v34 = raycastResult.Position
	else
		v34 = ray.Origin + lookVector * 500
	end

	local muzzle = v6:muzzle(children)

	if raycastResult then
		local v35

		if raycastResult.Instance == workspace.Terrain then
			v35 = raycastResult.Material ~= Enum.Material.Water
		else
			v35 = false
		end

		local travelTime = Tracers.travelTime(v6.muzzleWorld, v34)
		task.delay(travelTime, ImpactFX.bullet, raycastResult.Position, raycastResult.Normal, lookVector, v35)
		HitPredict.shot(raycastResult, travelTime)
	end

	local v35 = v34 - muzzle

	if v35.Magnitude < 0.1 then
		v35 = lookVector
	end

	FireRifle:FireServer(muzzle, v35.Unit, workspace:GetServerTimeNow(), v32, v31)
	Tracers.fire(v6.muzzleWorld, v34)
	VoxelSound.ownShot(v.sound, v.id, parent:GetAttribute("GsQuiet"))
	v6:fired()
	kickView(aimAlpha) -- inferred equivalent call

	if spread.exact then
		local v36

		if aimAlpha >= 0.5 then
			v36 = spread.exact.aim
		else
			v36 = spread.exact.hip
		end

		local v37 = v21 + v36.add
		local top = v36.top
		local v38 = if aimAlpha >= 0.5 then spread.aim else spread.hip
		v21 = math.min(v37, top - v38)
	else
		v21 = math.min(v21 + spread.bloom, spread.bloomMax)
	end

	v10 -= 1
	showAmmo() -- inferred equivalent call
end

heldStep(function(p)
	if spread.exact then
		local v22 = v21
		local v23

		if v6.aimAlpha >= 0.5 then
			v23 = spread.exact.aim
		else
			v23 = spread.exact.hip
		end

		v21 = v2:coolExact(v22, v23, p)
	else
		v21 = v2:cool(v21, spread.bloomDecay, p)
	end

	v6.firing = v18 and not v14

	if not v18 or v14 or not v6.active then
		return
	end

	if v10 <= 0 then
		startReload()
		return
	end

	if not v6:ready() or v19 > 0.3 then
		return
	end

	local now = os.clock()

	if now < v20 then
		return
	end

	v20 = math.max(v20 + interval, now - interval * 0.5)
	shoot()

	if v10 <= 0 then
		task.delay(0.15, startReload)
	end
end)

local function startFire()
	v18 = true
end
local function stopFire()
	v18 = false
end
local function setAim(aiming: boolean) -- 2 equivalent calls inferred from this helper
	if aiming and not v6.active then
		return
	end

	v6.aiming = aiming
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
	range = 500,
	assist = true,
	startFire = startFire,
	stopFire = stopFire,
	setAim = setAim,
	isAiming = function()
		return v6.aiming
	end,
	reload = startReload
})