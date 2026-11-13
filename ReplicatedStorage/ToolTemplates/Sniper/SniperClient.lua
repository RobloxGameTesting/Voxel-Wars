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
local TouchControls = require(Voxel:WaitForChild("TouchControls"))
local Ballistics = require(Voxel:WaitForChild("Ballistics"))

local SniperSight = require(Voxel:WaitForChild("SniperSight"))
local SniperTrace = require(Voxel:WaitForChild("SniperTrace"))
local Remotes = Voxel:WaitForChild("Remotes")
local FireSniper = Remotes:WaitForChild("FireSniper")
local ReloadSniper = Remotes:WaitForChild("ReloadSniper")
local SniperScope = Remotes:WaitForChild("SniperScope")

local function magSize() -- 7 equivalent calls inferred from this helper
	local magSize2 = parent:GetAttribute("MagSize")
	return if type(magSize2) == "number" then magSize2 else 10
end

local function reloadScale() -- 1 equivalent call inferred from this helper
	local reloadScale2 = parent:GetAttribute("ReloadScale")
	return if type(reloadScale2) == "number" then reloadScale2 else 1
end

local RIFLE_SPEED = Ballistics.RIFLE_SPEED
local RIFLE_ARC = Ballistics.RIFLE_ARC
local bulletSpeed = RIFLE_SPEED * (not Gunsmith2 and 1 or Gunsmith2.velocity(parent))
local v = Ballistics.MAX_TIME * Ballistics.SPEED / bulletSpeed

if Gunsmith2 then
	parent:GetAttributeChangedSignal("GsVelocity"):Connect(function()
		bulletSpeed = RIFLE_SPEED * Gunsmith2.velocity(parent)
		v = Ballistics.MAX_TIME * Ballistics.SPEED / bulletSpeed
	end)
end

local random = Random.new()

local GunRecoil = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("GunRecoil"))
local v2 = GunRecoil.new(parent.Name)
local cframe = nil

local HttpService = game:GetService("HttpService")
local guid = HttpService:GenerateGUID(false)
local v3 = "SniperViewUndo" .. guid
local v4 = "SniperView" .. guid
local v5 = "SniperScope" .. guid
local fn
local function gone(): boolean -- 3 equivalent calls inferred from this helper
	if parent:IsDescendantOf(game) then
		return false
	end

	fn()
	return true
end

local function kickView(p: number) -- 1 equivalent call inferred from this helper
	local v6, v7

	if Gunsmith2 then
		v6, v7 = Gunsmith2.kick(parent)
	else
		v6 = 1
		v7 = 1
	end

	v2:shot(p, v6 * 1, v7 * 1)
end

local function isMoving(): boolean -- 1 equivalent call inferred from this helper
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	return humanoid ~= nil and humanoid.MoveDirection.Magnitude > 0.1
end

local function isAirborne(): boolean -- 1 equivalent call inferred from this helper
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	return humanoid ~= nil and humanoid.FloorMaterial == Enum.Material.Air
end

local function step1()
	if gone() then -- inferred equivalent call
		return
	end

	if cframe then
		workspace.CurrentCamera.CFrame *= cframe:Inverse()
		cframe = nil
	end
end

local function step2(p)
	if gone() then -- inferred equivalent call
		return
	end

	local currentCamera = workspace.CurrentCamera
	local v6, v7, v8 = v2:step(p)

	if v6 == 0 and v7 == 0 and v8 == 0 then
		return
	end

	cframe = CFrame.Angles(math.rad(v6), math.rad(v7), 0) * CFrame.Angles(0, 0, (math.rad(v8)))

	if VR.on() then
		cframe = nil
	else
		currentCamera.CFrame *= cframe
	end
end

local v6 = Viewmodel.new(parent, {
	name = "Sniper Rifle",
	weight = 0.9,
	aimTime = 0.3,
	aimEaseOut = true,
	hold = CFrame.new(0.62, -0.86, -1.75) * CFrame.Angles(
		0.03490658503988659,
		0.03490658503988659,
		0.017453292519943295
	),
	rightHand = Vector3.new(0, -0.31, 0.3),
	leftHand = Vector3.new(-0.03, -0.2, -0.9),
	armThickness = 0.5,
	muzzle = muzzleAttachment.Position,
	aimPoint = Vector3.new(0, 0.27, 0.5),
	aimDistance = 1.08,
	aimFov = 11,
	aimSensitivity = 0.85,
	aimMove = 0.55,
	reach = 4.5,
	sprintHold = CFrame.new(-0.15, -1.35, -2) * CFrame.Angles(
		-0.5113814708343386,
		1.08035880698449,
		0.46600291028248597
	),
	hipKick = Vector3.new(0.04, 0.06, 0.5),
	hipKickRot = Vector3.new(8, 2, 4),
	aimKick = Vector3.new(0.004, 0.012, 0.12),
	aimKickRot = Vector3.new(1.2, 0.4, 1),
	recoilTime = 0.4,
	recoilKeys = Viewmodel.SNAP_RECOIL,
	punch = 1.8,
	flash = true,
	flashScale = 1.3,
	eject = Vector3.new(0.09, 0.03, -0.02),
	caseSize = Vector3.new(0.05, 0.05, 0.18),
	ejectVel = Vector3.new(3.5, 3.2, 0.6),
	slide = { travel = 0.2, time = 0.1 },
	boltEject = true,
	scope = SniperSight.scope({ at = 0.85, time = 0.15, eyeFov = 78, easeOut = true })
})

if Gunsmith2 then
	Gunsmith2.applySpec(parent, v6.spec)
end

local scope = v6.spec.scope
local function ironSights(): boolean -- 4 equivalent calls inferred from this helper
	return parent:GetAttribute("GsOptic") == "IRON"
end

local function fitScope() -- 2 equivalent calls inferred from this helper
	local spec = v6.spec
	local scope2

	if not ironSights() then -- inferred equivalent call
		scope2 = scope
	end

	spec.scope = scope2

	v6.spec.leftHand = ironSights() and Vector3.new(-0.03, -0.42, -1.45) or Vector3.new(-0.03, -0.2, -0.9) -- inferred equivalent call
end

fitScope() -- inferred equivalent call

local function liveMuzzle()
	return v6.muzzleWorld
end

local v7 = parent:GetAttribute("Ammo") or magSize() -- inferred equivalent call
local v8 = v7 > 0

local function showAmmo() -- 6 equivalent calls inferred from this helper
	v6:setAmmo(v7)
end

showAmmo() -- inferred equivalent call
parent:GetAttributeChangedSignal("Ammo"):Connect(function()
	local ammo = parent:GetAttribute("Ammo") or 0
	local v9

	if magSize() <= ammo then -- inferred equivalent call
		v9 = magSize() -- inferred equivalent call
	else
		v9 = math.min(v7, ammo)
	end

	v7 = v9
	showAmmo() -- inferred equivalent call
end)

local newVector3 = Vector3.new

local v9 = {
	length = 0.66,
	pos = {
		{ 0, Vector3.new(0, 0, 0) },
		{ 0.08, Vector3.new(-0.04, 0.05, 0.04), true },
		{ 0.25, Vector3.new(-0.04, 0.05, 0.05), true },
		{ 0.3, Vector3.new(-0.05, 0.06, 0.08), true },
		{ 0.41, Vector3.new(-0.05, 0.06, 0.07), true },
		{ 0.46, Vector3.new(-0.04, 0.05, 0.02), true },
		{ 0.5, Vector3.new(-0.04, 0.05, 0.03), true },
		{ 0.58, Vector3.new(0, 0, 0), true },
		{ 0.66, Vector3.new(0, 0, 0), true }
	},
	rot = {
		{ 0, Vector3.new(0, 0, 0) },
		{ 0.08, Vector3.new(4, 6, 10), true },
		{ 0.25, Vector3.new(4, 6, 11), true },
		{ 0.3, Vector3.new(6, 8, 14), true },
		{ 0.41, Vector3.new(6, 8, 14), true },
		{ 0.46, Vector3.new(2, 6, 9), true },
		{ 0.5, Vector3.new(3, 6, 10), true },
		{ 0.58, Vector3.new(0, 0, 0), true },
		{ 0.66, Vector3.new(0, 0, 0), true }
	},
	hand = {
		{ 0, 0 },
		{ 0.03, 0, true },
		{ 0.1, 1, true },
		{ 0.52, 1, true },
		{ 0.58, 0, true }
	},
	open = {
		{ 0, 0 },
		{ 0.12, 0, true },
		{ 0.16, 0.12, true },
		{ 0.25, 0.12, true },
		{ 0.3, 1, true },
		{ 0.41, 1, true },
		{ 0.46, 0.12, true },
		{ 0.5, 0, true }
	},
	scopeBack = 0.5775,
	closed = 0.46
}

local v10 = {
	{
		0.16,
		function(vector3: Vector3)
			VoxelSound.click(vector3, 0.45, 0.3)
		end
	},
	{
		0.3,
		function(vector3: Vector3)
			VoxelSound.click(vector3, 0.6, 0.55)
			v6:eject()
			VoxelSound.casing("large", 0.35)
		end
	},
	{
		0.46,
		function(vector3: Vector3)
			VoxelSound.click(vector3, 0.85, 0.85)
			v6:bump(0.25)
		end
	},
	{
		0.5,
		function(vector3: Vector3)
			VoxelSound.click(vector3, 0.5, 0.6)
		end
	}
}

local v11 = 0.9 / v9.length
local v12 = false

for _, v13 in { v9.pos, v9.rot, v9.hand, v9.open } do
	for _, v14 in v13 do
		v14[1] *= v11
	end
end

v9.length *= v11
v9.scopeBack *= v11
v9.closed *= v11

for _, v13 in v10 do
	v13[1] *= v11
end

local v13 = 0.41 * v11 - 1e-6
local function later(p: number) -- 5 equivalent calls inferred from this helper
	if v13 <= p then
		return p + 0.2
	end

	return p
end

for _, v14 in { v9.pos, v9.rot, v9.hand, v9.open } do
	for _, v15 in v14 do
		v15[1] = later(v15[1]) -- inferred equivalent call
	end
end

for _, v14 in v10 do
	v14[1] = later(v14[1]) -- inferred equivalent call
end

v9.scopeBack = later(v9.scopeBack) -- inferred equivalent call
v9.closed = later(v9.closed) -- inferred equivalent call
v9.length = later(v9.length) + 0.17 -- inferred equivalent call

local v14 = {
	length = 2,
	pos = {
		{ 0, Vector3.new(0, 0, 0) },
		{ 0.15, Vector3.new(-0.1, 0.2, 0.2), true },
		{ 0.4, Vector3.new(-0.1, 0.2, 0.2), true },
		{ 0.46, Vector3.new(-0.1, 0.23, 0.2), true },
		{ 0.55, Vector3.new(-0.1, 0.2, 0.2), true },
		{ 1.36, Vector3.new(-0.1, 0.2, 0.2), true },
		{ 1.45, Vector3.new(-0.1, 0.23, 0.2), true },
		{ 1.5, Vector3.new(-0.1, 0.18, 0.2), true },
		{ 1.62, Vector3.new(-0.020000001, 0.040000003, 0.040000003) },
		{ 1.75, Vector3.new(0, 0, 0), true },
		{ 2, Vector3.new(0, 0, 0), true }
	},
	rot = {
		{ 0, Vector3.new(0, 0, 0) },
		{ 0.15, Vector3.new(12, 8, -22), true },
		{ 0.4, Vector3.new(12, 8, -22), true },
		{ 0.46, Vector3.new(9, 8, -20), true },
		{ 0.55, Vector3.new(12, 8, -22), true },
		{ 1.36, Vector3.new(12, 8, -22), true },
		{ 1.45, Vector3.new(8, 8, -20), true },
		{ 1.5, Vector3.new(15, 8, -24), true },
		{ 1.62, Vector3.new(2.4, 1.6, -4.4) },
		{ 1.75, Vector3.new(0, 0, 0), true },
		{ 2, Vector3.new(0, 0, 0), true }
	},
	left = {
		{ 0, 0 },
		{ 0.08, 0.3 },
		{ 0.2, 1, true },
		{ 1.5, 1, true },
		{ 1.62, 0, true }
	},
	onMag = {
		{ 0, 1 },
		{ 2, 1 }
	},
	magPos = {
		{ 0, Vector3.new(0, 0, 0) },
		{ 0.4, Vector3.new(0, 0, 0), true },
		{ 0.46, Vector3.new(0, -0.25, 0.03) },
		{ 0.6, Vector3.new(-0.3, -1.5, 0.3) },
		{ 0.95, Vector3.new(-0.3, -1.2, 0.3) },
		{ 1.12, Vector3.new(0, -0.25, 0) },
		{ 1.36, Vector3.new(0, -0.12, 0), true },
		{ 1.45, Vector3.new(0, 0, 0), true }
	},
	magRot = {
		{ 0, Vector3.new(0, 0, 0) },
		{ 0.4, Vector3.new(0, 0, 0), true },
		{ 0.6, Vector3.new(-25, 0, 20) },
		{ 0.95, Vector3.new(-20, 0, 15) },
		{ 1.12, Vector3.new(-4, 0, 0) },
		{ 1.36, Vector3.new(-2, 0, 0), true },
		{ 1.45, Vector3.new(0, 0, 0), true }
	},
	hidden = { 0.62, 0.95 }
}

local v15 = false
local now = nil
local renderSteppedConnection = nil
local v16 = nil
local v17 = 0
local v18 = false

local function setScoped(flag: boolean) -- 1 equivalent call inferred from this helper
	if flag ~= v18 then
		v18 = flag
		SniperScope:FireServer(flag)
	end
end

local function clearPose() -- 1 equivalent call inferred from this helper
	v17 = 0
	v6.pose = CFrame.identity
	v6.leftWeight = 0
	v6.leftOnAmmo = 0
	v6.leftGun = nil
	v6.rightGun = nil
	v6.rightWeight = 0
	v6.slideHold = nil
	v6.ammoDelta = CFrame.identity
	v6.ammoVisible = true
	v6.reloadProgress = nil
end

local fn2

local function endAnim()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	local v19 = v16
	v16 = nil
	v12 = false
	v6.aimBlocked = false
	clearPose() -- inferred equivalent call

	if v19 == "bolt" then
		v8 = v7 > 0
	elseif v19 == "reload" and not v8 and v7 > 0 and v6.active and parent.Parent == LocalPlayer.Character then
		fn2(v9.length / 0.987)
	end
end

fn2 = function(value: number?)
	if v16 or not v6.active then
		return
	end

	v16 = "bolt"
	v17 = 1
	local lastTime = os.clock()
	local v19 = 1
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local v20 = (os.clock() - lastTime) * (value or 1)
		local v21 = v10[v19]

		if v21 and v21[1] <= v20 then
			v21[2](workspace.CurrentCamera.CFrame.Position)
			v19 += 1
		end

		if v9.closed <= v20 then
			v8 = v7 > 0
		end

		v6.aimBlocked = ironSights() and v20 < v9.scopeBack -- inferred equivalent call

		if v9.length <= v20 then
			endAnim()
			return
		end

		local pose = Keyframes.pose(Keyframes.sample(v9.pos, v20), Keyframes.sample(v9.rot, v20))
		v6.pose = CFrame.identity:Lerp(pose, 1 - 0.85 * v6.zoomAlpha)
		local sample = Keyframes.sample(v9.open, v20)
		v6.slideHold = sample
		v6.rightWeight = Keyframes.sample(v9.hand, v20)
		local v22 = 0.2 * sample
		v6.rightGun = Vector3.new(0.25, -0.15, 0.43) + newVector3(0, 0, v22)
	end)
end

local function startReload()
	if not v16 and v6.active then
		local v19 = v7

		if not (magSize() <= v19) then -- inferred equivalent call
			v16 = "reload"
			v12 = true
			v17 = 1
			now = nil
			v6.aimBlocked = true
			ReloadSniper:FireServer()
			local now2 = os.clock()
			local v20 = false
			local v21 = nil
			local v22 = false
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				local now3 = os.clock()
				local v23 = (now3 - now2) / (reloadScale() * 1.49) -- inferred equivalent call

				if not v22 and v23 >= 0.4 then
					v22 = true
					VoxelSound.reload("sniper", "magOut", 0.45)
				end

				if not v20 and v23 >= 1.45 then
					v20 = true
					v12 = false
					v6.aimBlocked = false
					v7 = magSize() -- inferred equivalent call
					showAmmo() -- inferred equivalent call
					VoxelSound.reload("sniper", "magIn", 0.85)
					v6:bump(0.35)
				end

				if v20 and not v21 and v8 and (v15 or v6.aiming) then
					v21 = now3
				end

				v17 = not v21 and 1 or 1 - (now3 - v21) / 0.12

				if v17 <= 0 or v14.length <= v23 then
					endAnim()
					return
				end

				local v24 = v17
				v6.pose = CFrame.identity:Lerp(
					Keyframes.pose(Keyframes.sample(v14.pos, v23), Keyframes.sample(v14.rot, v23)),
					v24
				)
				v6.leftWeight = Keyframes.sample(v14.left, v23) * v24
				v6.leftOnAmmo = Keyframes.sample(v14.onMag, v23)
				v6.leftTarget = Vector3.new(-1, -2.8, -0.6)
				v6.ammoGrab = Vector3.new(-0.02, -0.46, -0.1)
				v6.ammoDelta = Keyframes.pose(Keyframes.sample(v14.magPos, v23), Keyframes.sample(v14.magRot, v23))
				v6.ammoVisible = not (v14.hidden[1] < v23 and v23 < v14.hidden[2])
				local reloadProgress

				if v23 < 1.45 then
					reloadProgress = v23 / 1.45
				end

				v6.reloadProgress = reloadProgress
			end)
		end
	end
end

local v19 = SniperSight.new(v6)
local cframe2 = nil

local function step3(p)
	if gone() then -- inferred equivalent call
		return
	end

	cframe2 = workspace.CurrentCamera.CFrame
	local v20 = not v6.active and 0 or v6.aimAlpha
	local v21 = v6.active

	if v21 then
		if v20 >= 0.6 then
			v21 = not VR.on() and not ironSights() -- inferred equivalent call
		else
			v21 = false
		end
	end

	setScoped(v21) -- inferred equivalent call
	v19:step(p)
end

local v20 = false
local count = 0
local function bindSteps()
	count += 1

	if v20 or not parent:IsDescendantOf(game) then
		return
	end

	v20 = true
	RunService:BindToRenderStep(v3, Enum.RenderPriority.Camera.Value - 3, step1)
	RunService:BindToRenderStep(v4, Enum.RenderPriority.Camera.Value + 3, step2)
	RunService:BindToRenderStep(v5, Enum.RenderPriority.Camera.Value + 6, step3)
end
local function unbindSteps()
	v20 = false

	for _, v21 in { v3, v4, v5 } do
		RunService:UnbindFromRenderStep(v21)
	end

	if cframe then
		workspace.CurrentCamera.CFrame *= cframe:Inverse()
		cframe = nil
	end

	cframe2 = nil
end
parent.Equipped:Connect(bindSteps)
parent.Unequipped:Connect(function()
	count += 1
	local v21 = count
	task.delay(1, function()
		if v21 == count and v20 and parent.Parent ~= LocalPlayer.Character then
			unbindSteps()
		end
	end)
end)

if parent.Parent == LocalPlayer.Character then
	bindSteps()
end

parent.Equipped:Connect(function()
	Tracers.setOwnMuzzle(liveMuzzle)
	v7 = math.min(v7, parent:GetAttribute("Ammo") or 0)
	local ammo = parent:GetAttribute("Ammo") or 0

	if magSize() <= ammo then -- inferred equivalent call
		v7 = magSize() -- inferred equivalent call
	end

	showAmmo() -- inferred equivalent call

	if not v8 and v7 > 0 then
		task.defer(fn2)
	end
end)
parent.Unequipped:Connect(function()
	v15 = false
	now = nil

	if v16 then
		endAnim()
	end

	v6.aimBlocked = false

	if v18 ~= false then
		v18 = false
		SniperScope:FireServer(false)
	end
end)
parent:GetAttributeChangedSignal("GsRefit"):Connect(function()
	v15 = false
	now = nil

	if v16 then
		endAnim()
	end

	if v18 ~= false then
		v18 = false
		SniperScope:FireServer(false)
	end

	fitScope() -- inferred equivalent call
	v6:rebuild()
	v7 = math.min(v7, parent:GetAttribute("Ammo") or 0)
	showAmmo() -- inferred equivalent call
end)

fn = function()
	for _, v21 in { v3, v4, v5 } do
		RunService:UnbindFromRenderStep(v21)
	end

	v19:destroy()
end
parent.AncestryChanged:Connect(function()
	if not parent:IsDescendantOf(game) then
		fn()
	end
end)

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local function spreadDir(direction: Vector3, p: number)
	local v21 = math.rad(p) * math.sqrt((random:NextNumber()))
	return (CFrame.lookAt(Vector3.new(0, 0, 0), direction) * CFrame.Angles(
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

	local children = { character, workspace.CurrentCamera }

	for _, childName in { "VoxelChips", "VoxelLoose", "VoxelTracers" } do
		local child = workspace:FindFirstChild(childName)

		if child then
			table.insert(children, child)
		end
	end

	Viewmodel.setFilter(raycastParams, children)
	local v21

	if VR.on() then
		v21 = VR.frame(workspace.CurrentCamera)
	else
		v21 = cframe2 or workspace.CurrentCamera.CFrame
	end

	local ray = Ray.new(v21.Position, v21.LookVector)
	local aimAlpha = v6.aimAlpha

	local v22 = v6.zoomAlpha > 0 or aimAlpha >= 0.6
	local v23 = v22 and 1 or aimAlpha
	local moving = isMoving() -- inferred equivalent call
	local airborne = isAirborne() -- inferred equivalent call
	local v24 = (airborne and 2.514 or moving and 0.838 or 0) + 3.352
	local v25

	if airborne then
		v25 = 0.4
	elseif not moving then
		v25 = 0
	else
		v25 = math.max(0, 0 + (not Gunsmith2 and 0 or Gunsmith2.moveSpread(parent)))
	end

	local v26 = not Gunsmith2 and 1 or Gunsmith2.hip(parent)
	local v27 = (v24 * (1 - v23) * v26 + v25 * v23) * Viewmodel.hipSpread(v23)
	local lookVector = spreadDir(ray.Direction, v27)
	local v28, v29

	if v22 then
		v28 = ray.Origin
		v29 = Ballistics.zeroed(ray.Origin, lookVector, bulletSpeed, RIFLE_ARC)
	else
		v28 = v6:muzzle(children)
		v29 = Ballistics.launch(v28, ray.Origin + lookVector * Ballistics.ZERO, bulletSpeed, RIFLE_ARC)
	end

	local v30 = nil
	local v31, v32 = Ballistics.trace(v28, v29, function(origin: Vector3, direction: Vector3)
		local raycastResult = workspace:Raycast(origin, direction, raycastParams)

		if not raycastResult then
			return nil
		end

		v30 = raycastResult
		return raycastResult.Position
	end, bulletSpeed, v, RIFLE_ARC)

	local v35 = v30

	if v35 then
		local v36 = v35.Instance == workspace.Terrain and v35.Material ~= Enum.Material.Water
		task.delay(v32, ImpactFX.bullet, v35.Position, v35.Normal, v29, v36)
	end

	FireSniper:FireServer(v28, v29)

	local fire = SniperTrace.fire
	local v36

	if v22 and not VR.on() then
		v36 = SniperTrace.scopedStart(v21)
	else
		v36 = v6.muzzleWorld
	end

	fire(v36, v31, v32)
	VoxelSound.ownSniper(1, nil, parent:GetAttribute("GsQuiet"))
	v6:fired()
	kickView(v23) -- inferred equivalent call

	if v22 then
		v19:fired(1.4)
	end

	v7 -= 1
	v8 = false
	showAmmo() -- inferred equivalent call
	task.delay(v7 > 0 and 0.3 or 0.35, function()
		if v7 > 0 then
			fn2()
		else
			startReload()
		end
	end)
end

local function heldStep(fn3)
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

			fn3(dt)
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

			fn3(dt)
		end)
	end
end

heldStep(function()
	v6.firing = v15 and not v12

	if not v6.active or v16 then
		return
	end

	local now2 = os.clock()

	if now and now2 - now > 0.15 then
		now = nil
	end

	if not now then
		return
	end

	if v7 <= 0 then
		now = nil
		startReload()
	elseif v8 and v6:ready() then
		now = nil
		shoot()
	end
end)

local function press()
	v15 = true
	now = os.clock()
end
local function release()
	v15 = false
end
local function setAim(aiming: boolean) -- 2 equivalent calls inferred from this helper
	if aiming and not v6.active then
		return
	end

	v6.aiming = aiming
end

parent.Activated:Connect(press)
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
	autoFire = false,
	hipAutoFire = 180,
	assist = true,
	assistRange = { reach = 650, full = 350 },
	hipAssist = { reach = 260, full = 120, strength = 1.1 },
	bulletSpeed = bulletSpeed,
	bulletArc = RIFLE_ARC,
	startFire = press,
	stopFire = release,
	setAim = setAim,
	isAiming = function()
		return v6.aiming
	end,
	reload = startReload
})