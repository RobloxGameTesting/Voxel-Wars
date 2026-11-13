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
local Ballistics = require(Voxel:WaitForChild("Ballistics"))
local ImpactFX = require(Voxel:WaitForChild("ImpactFX"))
local TouchControls = require(Voxel:WaitForChild("TouchControls"))
local DMRSpecs = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("DMRSpecs"))
local Remotes = Voxel:WaitForChild("Remotes")
local FireDMR = Remotes:WaitForChild("FireDMR")
local ReloadDMR = Remotes:WaitForChild("ReloadDMR")

local v = DMRSpecs.of(parent.Name)
assert(v, "[DMRFamilyClient] no DMRSpecs entry for " .. parent.Name)
local view = v.view

local v2 = Ballistics.DMR_SPEED * v.speed
local bulletSpeed = v2 * (not Gunsmith2 and 1 or Gunsmith2.velocity(parent))
local v3 = 700 / bulletSpeed

if Gunsmith2 then
	parent:GetAttributeChangedSignal("GsVelocity"):Connect(function()
		bulletSpeed = v2 * Gunsmith2.velocity(parent)
		v3 = 700 / bulletSpeed
	end)
end

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
local spread = v.spread
local hip = spread.hip
local aim = spread.aim
local moving = spread.moving

local bloom = spread.bloom
local bloomMax = spread.bloomMax
local bloomDecay = spread.bloomDecay

local GunRecoil = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("GunRecoil"))
local v4 = GunRecoil.new(parent.Name)
local cframe = nil

local HttpService = game:GetService("HttpService")
local guid = HttpService:GenerateGUID(false)
local v5 = "DMRFamRecoilUndo" .. guid
local v6 = "DMRFamRecoil" .. guid
local function recoilGone(): boolean -- 1 equivalent call inferred from this helper
	if parent:IsDescendantOf(game) then
		return false
	end

	RunService:UnbindFromRenderStep(v5)
	RunService:UnbindFromRenderStep(v6)
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
	local v7, v8, v9 = v4:step(p)

	if v7 == 0 and v8 == 0 and v9 == 0 then
		return
	end

	cframe = CFrame.Angles(math.rad(v7), math.rad(v8), 0) * CFrame.Angles(0, 0, (math.rad(v9)))

	if VR.on() then
		cframe = nil
	else
		currentCamera.CFrame *= cframe
	end
end

local v7 = false
local count = 0
local function bindSteps()
	count += 1

	if v7 or not parent:IsDescendantOf(game) then
		return
	end

	v7 = true
	RunService:BindToRenderStep(v5, Enum.RenderPriority.Camera.Value - 3, step1)
	RunService:BindToRenderStep(v6, Enum.RenderPriority.Camera.Value + 3, step2)
end
local function unbindSteps()
	v7 = false

	for _, v8 in { v5, v6 } do
		RunService:UnbindFromRenderStep(v8)
	end

	if cframe then
		workspace.CurrentCamera.CFrame *= cframe:Inverse()
		cframe = nil
	end
end
parent.Equipped:Connect(bindSteps)
parent.Unequipped:Connect(function()
	count += 1
	local v8 = count
	task.delay(1, function()
		if v8 == count and v7 and parent.Parent ~= LocalPlayer.Character then
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

	return (frame * CFrame.Angles(math.rad(v4.pitch), math.rad(v4.yaw), 0)).LookVector
end

local function kickView(aimAlpha: number) -- 1 equivalent call inferred from this helper
	local v8, v9

	if Gunsmith2 then
		v8, v9 = Gunsmith2.kick(parent)
	else
		v8 = 1
		v9 = 1
	end

	v4:shot(aimAlpha, v8, v9)
end

local v8 = Viewmodel.new(parent, {
	name = v.name,
	weight = view.weight,
	hold = view.hold,
	rightHand = view.rightHand,
	leftHand = view.leftHand,
	armThickness = view.armThickness,
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
	eject = view.eject,
	caseSize = view.caseSize
})

if Gunsmith2 then
	Gunsmith2.applySpec(parent, v8.spec)
end

local v9 = { 0.45, 0.85 }
local v10 = nil
local parts = {}
local v11 = -1

local function heldStep(fn)
	local renderSteppedConnection = nil
	local lastTime = 0
	local function start()
		if renderSteppedConnection then
			return
		end

		local v12 = not (lastTime > 0) and 0 or os.clock() - lastTime
		renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
			if v12 > 0 then
				dt = math.max(dt, v12)
				v12 = 0
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
		local v12 = not (lastTime > 0) and 0 or os.clock() - lastTime
		renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
			if v12 > 0 then
				dt = math.max(dt, v12)
				v12 = 0
			end

			fn(dt)
		end)
	end
end

heldStep(function()
	local model = v8.model

	if model ~= v10 then
		v10 = model
		v11 = -1
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

	local localTransparencyModifier = math.floor(math.clamp((v8.aimAlpha - v9[1]) / (v9[2] - v9[1]), 0, 1) * 20 + 0.5) / 20

	if localTransparencyModifier ~= v11 then
		v11 = localTransparencyModifier

		for _, v12 in parts do
			v12.LocalTransparencyModifier = localTransparencyModifier
		end
	end
end)

local function liveMuzzle()
	return v8.muzzleWorld
end

Tracers.setOwnMuzzle(liveMuzzle)

local v12 = parent:GetAttribute("Ammo")

if not v12 then
	v12 = parent:GetAttribute("MagSize")

	if type(v12) ~= "number" then
		v12 = mag
	end
end

local function showAmmo() -- 6 equivalent calls inferred from this helper
	v8:setAmmo(v12)
end

showAmmo() -- inferred equivalent call
parent:GetAttributeChangedSignal("Ammo"):Connect(function()
	local ammo = parent:GetAttribute("Ammo") or 0
	local v13 = magSize() -- inferred equivalent call
	local v14

	if v13 <= ammo then
		v14 = parent:GetAttribute("MagSize")

		if type(v14) ~= "number" then
			v14 = mag
		end
	else
		v14 = math.min(v12, ammo)
	end

	v12 = v14
	showAmmo() -- inferred equivalent call
end)

local v13 = {
	{ 0, 0 },
	{ 0.42, 0.4 },
	{ 0.64, 0.46 },
	{ 1.34, 0.74 },
	{ 1.6, 1.06 }
}

local charger = view.charger
local magGrab = view.magGrab

local newVector3 = Vector3.new

local v14 = {
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

local v15 = {
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

local clone = table.clone(v13)

local v16 = {
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
local v17 = false

for _, v18 in {
	{ 2.25, 1.62 }
} do
	table.insert(clone, v18)
end

v16.timing = clone
local clone2 = table.clone(v14)

for _, v18 in {
	{ 1.3, Vector3.new(-0.055999998, 0.084, 0) },
	{ 1.48, Vector3.new(0, -0.02, 0) },
	{ 1.62, Vector3.new(0, 0, 0), true }
} do
	table.insert(clone2, v18)
end

v16.pos = clone2
local clone3 = table.clone(v15)

for _, v18 in {
	{ 1.3, Vector3.new(3, 4.8, -10.200001) },
	{ 1.48, Vector3.new(-3, 0, 3) },
	{ 1.62, Vector3.new(0, 0, 0), true }
} do
	table.insert(clone3, v18)
end

v16.rot = clone3

v16.leftWeight = {
	{ 0, 0 },
	{ 0.1, 0.1 },
	{ 0.24, 1, true },
	{ 1.1, 1, true },
	{ 1.36, 0, true }
}
v16.leftOnAmmo = {
	{ 0, 0 },
	{ 0.22, 0, true },
	{ 0.36, 1, true }
}

v16.cues = { 0.44, 1.06 }
local clone4 = table.clone(v13)

local v18 = {
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

for _, v19 in {
	{ 2.4, 1.66 },
	{ 2.9, 2.16 }
} do
	table.insert(clone4, v19)
end

v18.timing = clone4
local clone5 = table.clone(v14)

for _, v19 in {
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
	table.insert(clone5, v19)
end

v18.pos = clone5
local clone6 = table.clone(v15)

for _, v19 in {
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
	table.insert(clone6, v19)
end

v18.rot = clone6

v18.leftWeight = {
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

v18.leftOnAmmo = {
	{ 0, 0 },
	{ 0.22, 0, true },
	{ 0.36, 1, true },
	{ 1.4, 1, true },
	{ 1.5, 0, true }
}
v18.charger = { 1.1, 1.7 }
v18.cues = { 0.44, 1.06, 1.46, 1.66 }

local v19 = {
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

local v20 = {
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
	v8.pose = CFrame.identity:Lerp(Keyframes.pose(Keyframes.sample(data.pos, p), Keyframes.sample(data.rot, p)), p2)
	v8.leftWeight = Keyframes.sample(data.leftWeight, p) * p2
	v8.leftOnAmmo = Keyframes.sample(data.leftOnAmmo, p)
	v8.leftTarget = Vector3.new(-1.4, -3.2, -1.2)
	local charger2 = data.charger
	local leftGun

	if charger2 and charger2[1] < p and p < charger2[2] then
		leftGun = charger
	end

	v8.leftGun = leftGun
	v8.ammoGrab = magGrab
	v8.ammoDelta = Keyframes.pose(Keyframes.sample(v19, p), Keyframes.sample(v20, p))
	local reloadProgress

	if p < data.commit then
		reloadProgress = p / data.commit
	end

	v8.reloadProgress = reloadProgress
end

local v21 = false
local v22 = false
local now = nil
local renderSteppedConnection = nil
local flag = false
local v23 = 0

local function endReload() -- 3 equivalent calls inferred from this helper
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	v17 = false
	flag = false
	v23 = 0
	v8.aimBlocked = false
	v8.pose = CFrame.identity
	v8.leftWeight = 0
	v8.leftOnAmmo = 0
	v8.leftGun = nil
	v8.ammoDelta = CFrame.identity
	v8.reloadProgress = nil
end

local function startReload()
	if not flag and v8.active then
		local v24 = v12

		if not (magSize() <= v24) then -- inferred equivalent call
			local v25

			if v12 <= 0 then
				v25 = v18
			else
				v25 = v16
			end

			local v26

			if v25 == v18 then
				v26 = v.pace.empty
			else
				v26 = v.pace.tactical
			end

			v17 = true
			flag = true
			v23 = 1
			v8.aimBlocked = true
			ReloadDMR:FireServer()
			local now2 = os.clock()
			local v27 = 1
			local v28 = nil
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				local now3 = os.clock()
				local v29 = beatsAt(v25.timing, (now3 - now2) / (reloadScale() * v26)) -- inferred equivalent call

				if v17 and v25.commit <= v29 then
					v17 = false
					v8.aimBlocked = false
					v12 = magSize() -- inferred equivalent call
					showAmmo() -- inferred equivalent call
				end

				if not v17 and not v28 and (now or v21 or v8.aiming) then
					v28 = now3
				end

				v23 = not v28 and 1 or 1 - (now3 - v28) / 0.12
				local cue = v25.cues[v27]

				if cue and cue <= v29 and not v28 then
					local _position = workspace.CurrentCamera.CFrame.Position

					if cue == 0.44 then
						VoxelSound.reload("dmr", "magOut", 0.5)
					elseif cue == 1.06 then
						VoxelSound.reload("dmr", "magIn", 0.85)
						v8:bump(0.55)
					elseif cue == 1.66 then
						VoxelSound.reload("dmr", "boltRelease", 0.75)
						v8:bump(0.35)
					else
						VoxelSound.reload("dmr", "chargeBack", 0.65)
					end

					v27 += 1
				end

				if not (v23 <= 0 or v25.length <= v29) then
					sample(v25, math.min(v29, v25.length), v23)
					return
				end

				endReload() -- inferred equivalent call
			end)
		end
	end
end

parent.Equipped:Connect(function()
	Tracers.setOwnMuzzle(liveMuzzle)
	v12 = math.min(v12, parent:GetAttribute("Ammo") or 0)
	local ammo = parent:GetAttribute("Ammo") or 0

	if magSize() <= ammo then -- inferred equivalent call
		v12 = magSize() -- inferred equivalent call
	end

	showAmmo() -- inferred equivalent call
end)
parent.Unequipped:Connect(function()
	v21 = false
	v22 = false
	now = nil

	if flag then
		endReload() -- inferred equivalent call
	end
end)
parent:GetAttributeChangedSignal("GsRefit"):Connect(function()
	v21 = false
	v22 = false
	now = nil

	if flag then
		endReload() -- inferred equivalent call
	end

	v8:rebuild()
	v12 = math.min(v12, parent:GetAttribute("Ammo") or 0)
	showAmmo() -- inferred equivalent call
end)

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
local v24 = 0
local v25 = 0

local function spreadDir(vector3: Vector3, p: number)
	local v26 = math.rad(p) * math.sqrt((random:NextNumber()))
	return (CFrame.lookAt(Vector3.new(0, 0, 0), vector3) * CFrame.Angles(
		0,
		0,
		random:NextNumber() * 3.141592653589793 * 2
	) * CFrame.Angles(v26, 0, 0)).LookVector
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
	local v26 = currentCamera.ViewportSize * 0.5
	local ray = VR.ray(currentCamera, v26.X, v26.Y)
	local aimAlpha = v8.aimAlpha
	local v27 = humanoid and humanoid.MoveDirection.Magnitude > 0.1 and true or false
	local v28 = not Gunsmith2 and 1 or Gunsmith2.hip(parent)
	local v29 = not Gunsmith2 and 1 or Gunsmith2.bloomAt(parent, aimAlpha)
	local v30 = ((hip + (not v27 and 0 or moving)) * (1 - aimAlpha) * v28 + (aim + (not v27 and 0 or 0.27 + (not Gunsmith2 and 0 or Gunsmith2.moveSpread(parent)))) * aimAlpha + v25 * v29 * (1 - 0.8 * aimAlpha)) * Viewmodel.hipSpread(aimAlpha)
	local lookVector = spreadDir(aimDirection(currentCamera), v30) -- inferred equivalent call
	local v31, v32

	if aimAlpha > 0.5 then
		v31 = ray.Origin
		v32 = lookVector
	else
		local raycastResult = workspace:Raycast(ray.Origin, lookVector * 700, raycastParams)
		local v35

		if raycastResult then
			v35 = raycastResult.Position
		else
			v35 = ray.Origin + lookVector * 700
		end

		v31 = v8:muzzle(children)
		v32 = Ballistics.launch(v31, v35, bulletSpeed)

		if (v35 - v31).Magnitude < 0.5 then
			v32 = lookVector
		end
	end

	local v35 = nil
	local v36, v37 = Ballistics.trace(v31, v32, function(origin: Vector3, direction: Vector3)
		local raycastResult = workspace:Raycast(origin, direction, raycastParams)

		if not raycastResult then
			return nil
		end

		v35 = raycastResult
		return raycastResult.Position
	end, bulletSpeed, v3)

	if v35 then
		local v38 = v35
		local v39 = v38.Instance == workspace.Terrain and v38.Material ~= Enum.Material.Water
		task.delay(v37, ImpactFX.bullet, v38.Position, v38.Normal, v32, v39)
	end

	FireDMR:FireServer(v31, v32)

	if aimAlpha > 0.5 and currentCamera.FieldOfView < 25 then
		if (v36 - v31).Magnitude > 9 then
			Tracers.fire(v31 + v32 * 8, v36, bulletSpeed, false, true)
		end
	else
		Tracers.fire(v8.muzzleWorld, v36, bulletSpeed, nil, true)
	end

	VoxelSound.ownDMR(v.sound, parent:GetAttribute("GsQuiet"))
	v8:fired()
	kickView(aimAlpha) -- inferred equivalent call
	v25 = math.min(v25 + bloom, bloomMax)
	v12 -= 1
	showAmmo() -- inferred equivalent call
end

heldStep(function(p)
	v25 = v4:cool(v25, bloomDecay, p)
	v8.firing = v21 and not v17

	if v17 or not v8.active then
		return
	end

	local now2 = os.clock()

	if now and now2 - now > 0.12 then
		now = nil
	end

	if not (now or v22 and v21) then
		return
	end

	if v12 <= 0 then
		now = nil
		startReload()
	else
		if not v8:ready() or v23 > 0.3 or now2 < v24 then
			return
		end

		local v26 = if v22 and v21 then holdRepeat else interval
		v24 = now2 + v26
		now = nil
		shoot()

		if v12 <= 0 then
			task.delay(0.2, startReload)
		end
	end
end)

local function press(flag2: boolean) -- 2 equivalent calls inferred from this helper
	v21 = true
	v22 = flag2
	now = os.clock()
end
local function release()
	v21 = false
	v22 = false
end
local function setAim(aiming: boolean) -- 2 equivalent calls inferred from this helper
	if aiming and not v8.active then
		return
	end

	v8.aiming = aiming
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
	if not v8.active then
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
	range = 700,
	assist = true,
	bulletSpeed = bulletSpeed,
	startFire = function()
		press(true) -- inferred equivalent call
	end,
	stopFire = release,
	setAim = setAim,
	isAiming = function()
		return v8.aiming
	end,
	reload = startReload
})