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
local Remotes = Voxel:WaitForChild("Remotes")
local FireDMR = Remotes:WaitForChild("FireDMR")
local ReloadDMR = Remotes:WaitForChild("ReloadDMR")

local DMR_SPEED = Ballistics.DMR_SPEED
local bulletSpeed = DMR_SPEED * (not Gunsmith2 and 1 or Gunsmith2.velocity(parent))
local v = 700 / bulletSpeed

if Gunsmith2 then
	parent:GetAttributeChangedSignal("GsVelocity"):Connect(function()
		bulletSpeed = DMR_SPEED * Gunsmith2.velocity(parent)
		v = 700 / bulletSpeed
	end)
end

local function magSize() -- 7 equivalent calls inferred from this helper
	local magSize2 = parent:GetAttribute("MagSize")
	return if type(magSize2) == "number" then magSize2 else 20
end

local function reloadScale() -- 1 equivalent call inferred from this helper
	local reloadScale2 = parent:GetAttribute("ReloadScale")
	return if type(reloadScale2) == "number" then reloadScale2 else 1
end

local random = Random.new()

local GunRecoil = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("GunRecoil"))
local v2 = GunRecoil.new(parent.Name)
local cframe = nil

local HttpService = game:GetService("HttpService")
local guid = HttpService:GenerateGUID(false)
local v3 = "DMRRecoilUndo" .. guid
local v4 = "DMRRecoil" .. guid
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
	name = "DMR",
	weight = 1.1,
	hold = CFrame.new(0.65, -0.84, -1.78) * CFrame.Angles(
		0.03490658503988659,
		0.03490658503988659,
		0.017453292519943295
	),
	rightHand = Vector3.new(0, -0.33, 0.27),
	leftHand = Vector3.new(-0.03, -0.4, -0.85),
	armThickness = 0.5,
	muzzle = muzzleAttachment.Position,
	aimPoint = Vector3.new(0, 0.305, -0.08),
	aimDistance = 0.923,
	aimFov = 19.7,
	aimMove = 0.65,
	reach = 4,
	sprintHold = CFrame.new(-0.2, -1.3, -1.9) * CFrame.Angles(
		-0.5113814708343386,
		1.08035880698449,
		0.46600291028248597
	),
	hipKick = Vector3.new(0.022, 0.025, 0.24),
	hipKickRot = Vector3.new(2.2, 0.8, 1.4),
	aimKick = Vector3.new(0.002, 0.004, 0.045),
	aimKickRot = Vector3.new(0.35, 0.2, 0.5),
	recoilTime = 0.2,
	punch = 0.55,
	flash = true,
	flashScale = 1.1,
	eject = Vector3.new(0.09, 0.03, -0.12),
	caseSize = Vector3.new(0.045, 0.045, 0.14)
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

local v10 = parent:GetAttribute("Ammo") or magSize() -- inferred equivalent call

local function showAmmo() -- 6 equivalent calls inferred from this helper
	v6:setAmmo(v10)
end

showAmmo() -- inferred equivalent call
parent:GetAttributeChangedSignal("Ammo"):Connect(function()
	local ammo = parent:GetAttribute("Ammo") or 0
	local v11

	if magSize() <= ammo then -- inferred equivalent call
		v11 = magSize() -- inferred equivalent call
	else
		v11 = math.min(v10, ammo)
	end

	v10 = v11
	showAmmo() -- inferred equivalent call
end)

local v11 = {
	{ 0, 0 },
	{ 0.42, 0.4 },
	{ 0.64, 0.46 },
	{ 1.34, 0.74 },
	{ 1.6, 1.06 }
}

local newVector3 = Vector3.new

local v12 = {
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

local v13 = {
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

local v14 = {
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
local v15 = false

for _, v16 in {
	{ 2.25, 1.62 }
} do
	table.insert(clone, v16)
end

v14.timing = clone
local clone2 = table.clone(v12)

for _, v16 in {
	{ 1.3, Vector3.new(-0.055999998, 0.084, 0) },
	{ 1.48, Vector3.new(0, -0.02, 0) },
	{ 1.62, Vector3.new(0, 0, 0), true }
} do
	table.insert(clone2, v16)
end

v14.pos = clone2
local clone3 = table.clone(v13)

for _, v16 in {
	{ 1.3, Vector3.new(3, 4.8, -10.200001) },
	{ 1.48, Vector3.new(-3, 0, 3) },
	{ 1.62, Vector3.new(0, 0, 0), true }
} do
	table.insert(clone3, v16)
end

v14.rot = clone3

v14.leftWeight = {
	{ 0, 0 },
	{ 0.1, 0.1 },
	{ 0.24, 1, true },
	{ 1.1, 1, true },
	{ 1.36, 0, true }
}
v14.leftOnAmmo = {
	{ 0, 0 },
	{ 0.22, 0, true },
	{ 0.36, 1, true }
}

v14.cues = { 0.44, 1.06 }
local clone4 = table.clone(v11)

local v16 = {
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

for _, v17 in {
	{ 2.4, 1.66 },
	{ 2.9, 2.16 }
} do
	table.insert(clone4, v17)
end

v16.timing = clone4
local clone5 = table.clone(v12)

for _, v17 in {
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
	table.insert(clone5, v17)
end

v16.pos = clone5
local clone6 = table.clone(v13)

for _, v17 in {
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
	table.insert(clone6, v17)
end

v16.rot = clone6

v16.leftWeight = {
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

v16.leftOnAmmo = {
	{ 0, 0 },
	{ 0.22, 0, true },
	{ 0.36, 1, true },
	{ 1.4, 1, true },
	{ 1.5, 0, true }
}
v16.charger = { 1.1, 1.7 }
v16.cues = { 0.44, 1.06, 1.46, 1.66 }

local v17 = {
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

local v18 = {
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
	v6.pose = CFrame.identity:Lerp(Keyframes.pose(Keyframes.sample(data.pos, p), Keyframes.sample(data.rot, p)), p2)
	v6.leftWeight = Keyframes.sample(data.leftWeight, p) * p2
	v6.leftOnAmmo = Keyframes.sample(data.leftOnAmmo, p)
	v6.leftTarget = Vector3.new(-1.4, -3.2, -1.2)
	local charger = data.charger
	v6.leftGun = charger and charger[1] < p and p < charger[2] and Vector3.new(-0.11, -0.02, -0.18) or nil
	v6.ammoGrab = Vector3.new(0, -0.5, -0.17)
	v6.ammoDelta = Keyframes.pose(Keyframes.sample(v17, p), Keyframes.sample(v18, p))
	local reloadProgress

	if p < data.commit then
		reloadProgress = p / data.commit
	end

	v6.reloadProgress = reloadProgress
end

local v19 = false
local v20 = false
local now = nil
local renderSteppedConnection = nil
local flag = false
local v21 = 0

local function endReload() -- 3 equivalent calls inferred from this helper
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	v15 = false
	flag = false
	v21 = 0
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
		local v22 = v10

		if not (magSize() <= v22) then -- inferred equivalent call
			local v23

			if v10 <= 0 then
				v23 = v16
			else
				v23 = v14
			end

			v15 = true
			flag = true
			v21 = 1
			v6.aimBlocked = true
			ReloadDMR:FireServer()
			local now2 = os.clock()
			local v24 = 1
			local v25 = nil
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				local now3 = os.clock()
				local v26 = beatsAt(v23.timing, (now3 - now2) / reloadScale()) -- inferred equivalent call

				if v15 and v23.commit <= v26 then
					v15 = false
					v6.aimBlocked = false
					v10 = magSize() -- inferred equivalent call
					showAmmo() -- inferred equivalent call
				end

				if not v15 and not v25 and (now or v19 or v6.aiming) then
					v25 = now3
				end

				v21 = not v25 and 1 or 1 - (now3 - v25) / 0.12
				local cue = v23.cues[v24]

				if cue and cue <= v26 and not v25 then
					local _position = workspace.CurrentCamera.CFrame.Position

					if cue == 0.44 then
						VoxelSound.reload("dmr", "magOut", 0.5)
					elseif cue == 1.06 then
						VoxelSound.reload("dmr", "magIn", 0.85)
						v6:bump(0.55)
					elseif cue == 1.66 then
						VoxelSound.reload("dmr", "boltRelease", 0.75)
						v6:bump(0.35)
					else
						VoxelSound.reload("dmr", "chargeBack", 0.65)
					end

					v24 += 1
				end

				if not (v21 <= 0 or v23.length <= v26) then
					sample(v23, math.min(v26, v23.length), v21)
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
	v19 = false
	v20 = false
	now = nil

	if flag then
		endReload() -- inferred equivalent call
	end
end)
parent:GetAttributeChangedSignal("GsRefit"):Connect(function()
	v19 = false
	v20 = false
	now = nil

	if flag then
		endReload() -- inferred equivalent call
	end

	v6:rebuild()
	v10 = math.min(v10, parent:GetAttribute("Ammo") or 0)
	showAmmo() -- inferred equivalent call
end)

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
local v22 = 0
local v23 = 0

local function spreadDir(vector3: Vector3, p: number)
	local v24 = math.rad(p) * math.sqrt((random:NextNumber()))
	return (CFrame.lookAt(Vector3.new(0, 0, 0), vector3) * CFrame.Angles(
		0,
		0,
		random:NextNumber() * 3.141592653589793 * 2
	) * CFrame.Angles(v24, 0, 0)).LookVector
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
	local v24 = currentCamera.ViewportSize * 0.5
	local ray = VR.ray(currentCamera, v24.X, v24.Y)
	local aimAlpha = v6.aimAlpha
	local v25 = humanoid and humanoid.MoveDirection.Magnitude > 0.1 and true or false
	local v26 = not Gunsmith2 and 1 or Gunsmith2.hip(parent)
	local v27 = not Gunsmith2 and 1 or Gunsmith2.bloomAt(parent, aimAlpha)
	local v28 = (((v25 and 0.8 or 0) + 1.6) * (1 - aimAlpha) * v26 + (0.05 + (not v25 and 0 or 0.27 + (not Gunsmith2 and 0 or Gunsmith2.moveSpread(parent)))) * aimAlpha + v23 * v27 * (1 - 0.8 * aimAlpha)) * Viewmodel.hipSpread(aimAlpha)
	local lookVector = spreadDir(aimDirection(currentCamera), v28) -- inferred equivalent call
	local v29, v30

	if aimAlpha > 0.5 then
		v29 = ray.Origin
		v30 = lookVector
	else
		local raycastResult = workspace:Raycast(ray.Origin, lookVector * 700, raycastParams)
		local v31

		if raycastResult then
			v31 = raycastResult.Position
		else
			v31 = ray.Origin + lookVector * 700
		end

		v29 = v6:muzzle(children)
		v30 = Ballistics.launch(v29, v31, bulletSpeed)

		if (v31 - v29).Magnitude < 0.5 then
			v30 = lookVector
		end
	end

	local v31 = nil
	local v32, v35 = Ballistics.trace(v29, v30, function(origin: Vector3, direction: Vector3)
		local raycastResult = workspace:Raycast(origin, direction, raycastParams)

		if not raycastResult then
			return nil
		end

		v31 = raycastResult
		return raycastResult.Position
	end, bulletSpeed, v)

	if v31 then
		local v36 = v31
		local v37 = v36.Instance == workspace.Terrain and v36.Material ~= Enum.Material.Water
		task.delay(v35, ImpactFX.bullet, v36.Position, v36.Normal, v30, v37)
	end

	FireDMR:FireServer(v29, v30)

	if aimAlpha > 0.5 and currentCamera.FieldOfView < 25 then
		if (v32 - v29).Magnitude > 9 then
			Tracers.fire(v29 + v30 * 8, v32, bulletSpeed, false, true)
		end
	else
		Tracers.fire(v6.muzzleWorld, v32, bulletSpeed, nil, true)
	end

	VoxelSound.ownDMR(1, parent:GetAttribute("GsQuiet"))
	v6:fired()
	kickView(aimAlpha) -- inferred equivalent call
	v23 = math.min(v23 + 0.35, 1.4)
	v10 -= 1
	showAmmo() -- inferred equivalent call
end

heldStep(function(p)
	v23 = v2:cool(v23, 2.5, p)
	v6.firing = v19 and not v15

	if v15 or not v6.active then
		return
	end

	local now2 = os.clock()

	if now and now2 - now > 0.12 then
		now = nil
	end

	if not (now or v20 and v19) then
		return
	end

	if v10 <= 0 then
		now = nil
		startReload()
	else
		if not v6:ready() or v21 > 0.3 or now2 < v22 then
			return
		end

		v22 = now2 + (v20 and v19 and 0.3 or 0.2)
		now = nil
		shoot()

		if v10 <= 0 then
			task.delay(0.2, startReload)
		end
	end
end)

local function press(flag2: boolean) -- 2 equivalent calls inferred from this helper
	v19 = true
	v20 = flag2
	now = os.clock()
end
local function release()
	v19 = false
	v20 = false
end
local function setAim(aiming: boolean) -- 2 equivalent calls inferred from this helper
	if aiming and not v6.active then
		return
	end

	v6.aiming = aiming
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
	range = 700,
	assist = true,
	bulletSpeed = bulletSpeed,
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