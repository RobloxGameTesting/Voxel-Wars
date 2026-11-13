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
local SniperSpecs = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("SniperSpecs"))
local v = SniperSpecs.of(parent.Name)
assert(v, "[SniperFamilyClient] no SniperSpecs entry for " .. parent.Name)
local view = v.view
local speed = v.speed
local arc = v.arc
local bulletSpeed = speed * (not Gunsmith2 and 1 or Gunsmith2.velocity(parent))
local v2 = bulletSpeed
local v3 = Ballistics.MAX_TIME * Ballistics.SPEED / bulletSpeed

if Gunsmith2 then
	parent:GetAttributeChangedSignal("GsVelocity"):Connect(function()
		bulletSpeed = speed * Gunsmith2.velocity(parent)
		v2 = bulletSpeed
		v3 = Ballistics.MAX_TIME * Ballistics.SPEED / bulletSpeed
	end)
end

local mag = v.mag

local function magSize() -- 5 equivalent calls inferred from this helper
	local magSize2 = parent:GetAttribute("MagSize")
	return if type(magSize2) == "number" then magSize2 else mag
end

local function reloadScale() -- 1 equivalent call inferred from this helper
	local reloadScale2 = parent:GetAttribute("ReloadScale")
	return if type(reloadScale2) == "number" then reloadScale2 else 1
end

local boltDelay = v.boltDelay

local random = Random.new()
local hip = v.spread.hip
local moving = v.spread.moving
local jump = v.spread.jump

local aimPoint = view.aimPoint

local GunRecoil = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("GunRecoil"))
local v4 = GunRecoil.new(parent.Name)
local cframe = nil

local HttpService = game:GetService("HttpService")
local guid = HttpService:GenerateGUID(false)
local v5 = "SniperViewUndo" .. guid
local v6 = "SniperView" .. guid
local v7 = "SniperScope" .. guid
local fn
local function gone(): boolean -- 3 equivalent calls inferred from this helper
	if parent:IsDescendantOf(game) then
		return false
	end

	fn()
	return true
end

local function kickView(p: number) -- 1 equivalent call inferred from this helper
	local v8, v9

	if Gunsmith2 then
		v8, v9 = Gunsmith2.kick(parent)
	else
		v8 = 1
		v9 = 1
	end

	v4:shot(p, v8 * 1, v9 * 1)
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
	local v8, v9, v10 = v4:step(p)

	if v8 == 0 and v9 == 0 and v10 == 0 then
		return
	end

	cframe = CFrame.Angles(math.rad(v8), math.rad(v9), 0) * CFrame.Angles(0, 0, (math.rad(v10)))

	if VR.on() then
		cframe = nil
	else
		currentCamera.CFrame *= cframe
	end
end

local v8 = Viewmodel.new(parent, {
	name = v.name,
	weight = view.weight,
	aimTime = view.aimTime,
	aimEaseOut = true,
	hold = view.hold,
	rightHand = view.rightHand,
	leftHand = view.leftHand,
	armThickness = 0.5,
	muzzle = muzzleAttachment.Position,
	aimPoint = aimPoint,
	aimDistance = view.aimDistance,
	aimFov = view.aimFov,
	aimSensitivity = 0.85,
	aimMove = view.aimMove,
	reach = view.reach,
	sprintHold = view.sprintHold,
	hipKick = view.hipKick,
	hipKickRot = view.hipKickRot,
	aimKick = view.aimKick,
	aimKickRot = view.aimKickRot,
	recoilTime = view.recoilTime,
	recoilKeys = Viewmodel.SNAP_RECOIL,
	punch = view.punch,
	flash = true,
	flashScale = view.flashScale,
	eject = view.eject,
	caseSize = Vector3.new(0.05, 0.05, 0.18),
	ejectVel = Vector3.new(3.5, 3.2, 0.6),
	slide = { travel = 0.2, time = 0.1 },
	boltEject = true,
	scope = SniperSight.scope(view.scope)
})

if Gunsmith2 then
	Gunsmith2.applySpec(parent, v8.spec)
end

local scope = v8.spec.scope
local function ironSights(): boolean -- 4 equivalent calls inferred from this helper
	return parent:GetAttribute("GsOptic") == "IRON"
end

local function fitScope() -- 2 equivalent calls inferred from this helper
	local spec = v8.spec
	local scope2

	if not ironSights() then -- inferred equivalent call
		scope2 = scope
	end

	spec.scope = scope2

	local spec2 = v8.spec
	local leftHand

	if ironSights() then -- inferred equivalent call
		leftHand = view.ironLeftHand
	else
		leftHand = view.leftHand
	end

	spec2.leftHand = leftHand
end

fitScope() -- inferred equivalent call

local function liveMuzzle()
	return v8.muzzleWorld
end

local v9 = parent:GetAttribute("Ammo")

if not v9 then
	v9 = parent:GetAttribute("MagSize")

	if type(v9) ~= "number" then
		v9 = mag
	end
end

local v10 = v9 > 0

local function showAmmo() -- 6 equivalent calls inferred from this helper
	v8:setAmmo(v9)
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
		v12 = math.min(v9, ammo)
	end

	v9 = v12
	showAmmo() -- inferred equivalent call
end)

local newVector3 = Vector3.new
local knobGrab = view.knobGrab
local boltTravel = view.boltTravel
local v11 = {
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

local v12 = {
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
			v8:eject()
			VoxelSound.casing("large", 0.35)
		end
	},
	{
		0.46,
		function(vector3: Vector3)
			VoxelSound.click(vector3, 0.85, 0.85)
			v8:bump(0.25)
		end
	},
	{
		0.5,
		function(vector3: Vector3)
			VoxelSound.click(vector3, 0.5, 0.6)
		end
	}
}
local v13 = false

for _, v14 in { v11.pos, v11.rot, v11.hand, v11.open } do
	for _, v15 in v14 do
		v15[1] *= v.bolt
	end
end

v11.length *= v.bolt
v11.scopeBack *= v.bolt
v11.closed *= v.bolt

for _, v14 in v12 do
	v14[1] *= v.bolt
end

local v14 = 0.41 * v.bolt - 1e-6
local function later(p: number) -- 5 equivalent calls inferred from this helper
	if v14 <= p then
		return p + v.boltOpenHold
	end

	return p
end

for _, v15 in { v11.pos, v11.rot, v11.hand, v11.open } do
	for _, v16 in v15 do
		v16[1] = later(v16[1]) -- inferred equivalent call
	end
end

for _, v15 in v12 do
	v15[1] = later(v15[1]) -- inferred equivalent call
end

v11.scopeBack = later(v11.scopeBack) -- inferred equivalent call
v11.closed = later(v11.closed) -- inferred equivalent call
v11.length = later(v11.length) + v.boltEndHold -- inferred equivalent call

local magGrab = view.magGrab

local v15 = {
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

local v16 = false
local now = nil
local renderSteppedConnection = nil
local v17 = nil
local v18 = 0
local v19 = false

local function setScoped(flag: boolean) -- 1 equivalent call inferred from this helper
	if flag ~= v19 then
		v19 = flag
		SniperScope:FireServer(flag)
	end
end

local function clearPose() -- 1 equivalent call inferred from this helper
	v18 = 0
	v8.pose = CFrame.identity
	v8.leftWeight = 0
	v8.leftOnAmmo = 0
	v8.leftGun = nil
	v8.rightGun = nil
	v8.rightWeight = 0
	v8.slideHold = nil
	v8.ammoDelta = CFrame.identity
	v8.ammoVisible = true
	v8.reloadProgress = nil
end

local fn2

local function endAnim()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	local v20 = v17
	v17 = nil
	v13 = false
	v8.aimBlocked = false
	clearPose() -- inferred equivalent call

	if v20 == "bolt" then
		v10 = v9 > 0
	elseif v20 == "reload" and not v10 and v9 > 0 and v8.active and parent.Parent == LocalPlayer.Character then
		fn2(v11.length / v.reload.chamber)
	end
end

fn2 = function(value: number?)
	if v17 or not v8.active then
		return
	end

	v17 = "bolt"
	v18 = 1
	local lastTime = os.clock()
	local v20 = 1
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local v21 = (os.clock() - lastTime) * (value or 1)
		local v22 = v12[v20]

		if v22 and v22[1] <= v21 then
			v22[2](workspace.CurrentCamera.CFrame.Position)
			v20 += 1
		end

		if v11.closed <= v21 then
			v10 = v9 > 0
		end

		v8.aimBlocked = ironSights() and v21 < v11.scopeBack -- inferred equivalent call

		if v11.length <= v21 then
			endAnim()
			return
		end

		local pose = Keyframes.pose(Keyframes.sample(v11.pos, v21), Keyframes.sample(v11.rot, v21))
		v8.pose = CFrame.identity:Lerp(pose, 1 - 0.85 * v8.zoomAlpha)
		local sample = Keyframes.sample(v11.open, v21)
		v8.slideHold = sample
		v8.rightWeight = Keyframes.sample(v11.hand, v21)
		v8.rightGun = knobGrab + newVector3(0, 0, boltTravel * sample)
	end)
end

local function startReload()
	if not v17 and v8.active then
		local v20 = v9

		if not (magSize() <= v20) then -- inferred equivalent call
			v17 = "reload"
			v13 = true
			v18 = 1
			now = nil
			v8.aimBlocked = true
			ReloadSniper:FireServer()
			local v21

			if v9 <= 0 then
				v21 = v.pace.empty
			else
				v21 = v.pace.tactical
			end

			local now2 = os.clock()
			local v22 = false
			local v23 = nil
			local v24 = false
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				local now3 = os.clock()
				local v25 = (now3 - now2) / (v21 * reloadScale()) -- inferred equivalent call

				if not v24 and v25 >= 0.4 then
					v24 = true
					VoxelSound.reload("sniper", "magOut", 0.45)
				end

				if not v22 and v25 >= 1.45 then
					v22 = true
					v13 = false
					v8.aimBlocked = false
					v9 = magSize() -- inferred equivalent call
					showAmmo() -- inferred equivalent call
					VoxelSound.reload("sniper", "magIn", 0.85)
					v8:bump(0.35)
				end

				if v22 and not v23 and v10 and (v16 or v8.aiming) then
					v23 = now3
				end

				v18 = not v23 and 1 or 1 - (now3 - v23) / 0.12

				if v18 <= 0 or v15.length <= v25 then
					endAnim()
					return
				end

				local v26 = v18
				v8.pose = CFrame.identity:Lerp(
					Keyframes.pose(Keyframes.sample(v15.pos, v25), Keyframes.sample(v15.rot, v25)),
					v26
				)
				v8.leftWeight = Keyframes.sample(v15.left, v25) * v26
				v8.leftOnAmmo = Keyframes.sample(v15.onMag, v25)
				v8.leftTarget = Vector3.new(-1, -2.8, -0.6)
				v8.ammoGrab = magGrab
				v8.ammoDelta = Keyframes.pose(Keyframes.sample(v15.magPos, v25), Keyframes.sample(v15.magRot, v25))
				v8.ammoVisible = not (v15.hidden[1] < v25 and v25 < v15.hidden[2])
				local reloadProgress

				if v25 < 1.45 then
					reloadProgress = v25 / 1.45
				end

				v8.reloadProgress = reloadProgress
			end)
		end
	end
end

local v20 = SniperSight.new(v8, { posts = view.postScale })
local cframe2 = nil

local function step3(p)
	if gone() then -- inferred equivalent call
		return
	end

	cframe2 = workspace.CurrentCamera.CFrame
	local v21 = not v8.active and 0 or v8.aimAlpha
	local v22 = v8.active

	if v22 then
		if v21 >= 0.6 then
			v22 = not VR.on() and not ironSights() -- inferred equivalent call
		else
			v22 = false
		end
	end

	setScoped(v22) -- inferred equivalent call
	v20:step(p)
end

local v21 = false
local count = 0
local function bindSteps()
	count += 1

	if v21 or not parent:IsDescendantOf(game) then
		return
	end

	v21 = true
	RunService:BindToRenderStep(v5, Enum.RenderPriority.Camera.Value - 3, step1)
	RunService:BindToRenderStep(v6, Enum.RenderPriority.Camera.Value + 3, step2)
	RunService:BindToRenderStep(v7, Enum.RenderPriority.Camera.Value + 6, step3)
end
local function unbindSteps()
	v21 = false

	for _, v22 in { v5, v6, v7 } do
		RunService:UnbindFromRenderStep(v22)
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
	local v22 = count
	task.delay(1, function()
		if v22 == count and v21 and parent.Parent ~= LocalPlayer.Character then
			unbindSteps()
		end
	end)
end)

if parent.Parent == LocalPlayer.Character then
	bindSteps()
end

parent.Equipped:Connect(function()
	Tracers.setOwnMuzzle(liveMuzzle)
	v9 = math.min(v9, parent:GetAttribute("Ammo") or 0)
	local ammo = parent:GetAttribute("Ammo") or 0

	if magSize() <= ammo then -- inferred equivalent call
		v9 = magSize() -- inferred equivalent call
	end

	showAmmo() -- inferred equivalent call

	if not v10 and v9 > 0 then
		task.defer(fn2)
	end
end)
parent.Unequipped:Connect(function()
	v16 = false
	now = nil

	if v17 then
		endAnim()
	end

	v8.aimBlocked = false

	if v19 ~= false then
		v19 = false
		SniperScope:FireServer(false)
	end
end)
parent:GetAttributeChangedSignal("GsRefit"):Connect(function()
	v16 = false
	now = nil

	if v17 then
		endAnim()
	end

	if v19 ~= false then
		v19 = false
		SniperScope:FireServer(false)
	end

	fitScope() -- inferred equivalent call
	v8:rebuild()
	v9 = math.min(v9, parent:GetAttribute("Ammo") or 0)
	showAmmo() -- inferred equivalent call
end)

fn = function()
	for _, v22 in { v5, v6, v7 } do
		RunService:UnbindFromRenderStep(v22)
	end

	v20:destroy()
end
parent.AncestryChanged:Connect(function()
	if not parent:IsDescendantOf(game) then
		fn()
	end
end)

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local function spreadDir(direction: Vector3, p: number)
	local v22 = math.rad(p) * math.sqrt((random:NextNumber()))
	return (CFrame.lookAt(Vector3.new(0, 0, 0), direction) * CFrame.Angles(
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

	local children = { character, workspace.CurrentCamera }

	for _, childName in { "VoxelChips", "VoxelLoose", "VoxelTracers" } do
		local child = workspace:FindFirstChild(childName)

		if child then
			table.insert(children, child)
		end
	end

	Viewmodel.setFilter(raycastParams, children)
	local v22

	if VR.on() then
		v22 = VR.frame(workspace.CurrentCamera)
	else
		v22 = cframe2 or workspace.CurrentCamera.CFrame
	end

	local ray = Ray.new(v22.Position, v22.LookVector)
	local aimAlpha = v8.aimAlpha

	local v23 = v8.zoomAlpha > 0 or aimAlpha >= 0.6
	local v24 = v23 and 1 or aimAlpha
	local moving2 = isMoving() -- inferred equivalent call
	local airborne = isAirborne() -- inferred equivalent call
	local v25

	if airborne then
		v25 = jump
	else
		v25 = not moving2 and 0 or moving
	end

	local v26 = hip + v25
	local v27

	if airborne then
		v27 = 0.4
	elseif not moving2 then
		v27 = 0
	else
		v27 = math.max(0, 0 + (not Gunsmith2 and 0 or Gunsmith2.moveSpread(parent)))
	end

	local v28 = not Gunsmith2 and 1 or Gunsmith2.hip(parent)
	local v29 = (v26 * (1 - v24) * v28 + v27 * v24) * Viewmodel.hipSpread(v24)
	local lookVector = spreadDir(ray.Direction, v29)
	local v30, v31

	if v23 then
		v30 = ray.Origin
		v31 = Ballistics.zeroed(ray.Origin, lookVector, bulletSpeed, arc)
	else
		v30 = v8:muzzle(children)
		v31 = Ballistics.launch(v30, ray.Origin + lookVector * Ballistics.ZERO, bulletSpeed, arc)
	end

	local v32 = nil
	local v35, v36 = Ballistics.trace(v30, v31, function(origin: Vector3, direction: Vector3)
		local raycastResult = workspace:Raycast(origin, direction, raycastParams)

		if not raycastResult then
			return nil
		end

		v32 = raycastResult
		return raycastResult.Position
	end, bulletSpeed, v3, arc)

	local v37 = v32

	if v37 then
		local v38 = v37.Instance == workspace.Terrain and v37.Material ~= Enum.Material.Water
		task.delay(v36, ImpactFX.bullet, v37.Position, v37.Normal, v31, v38)
	end

	FireSniper:FireServer(v30, v31)

	local fire = SniperTrace.fire
	local v38

	if v23 and not VR.on() then
		v38 = SniperTrace.scopedStart(v22)
	else
		v38 = v8.muzzleWorld
	end

	fire(v38, v35, v36, v.tracer, arc)
	VoxelSound.ownSniper(v.sound, v.id, parent:GetAttribute("GsQuiet"))
	v8:fired()
	kickView(v24) -- inferred equivalent call

	if v23 then
		v20:fired(1.4)
	end

	v9 -= 1
	v10 = false
	showAmmo() -- inferred equivalent call
	local v39

	if v9 > 0 then
		v39 = boltDelay
	else
		v39 = math.max(boltDelay, 0.35)
	end

	task.delay(v39, function()
		if v9 > 0 then
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

		local v22 = not (lastTime > 0) and 0 or os.clock() - lastTime
		renderSteppedConnection2 = RunService.RenderStepped:Connect(function(dt)
			if v22 > 0 then
				dt = math.max(dt, v22)
				v22 = 0
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
		local v22 = not (lastTime > 0) and 0 or os.clock() - lastTime
		renderSteppedConnection2 = RunService.RenderStepped:Connect(function(dt)
			if v22 > 0 then
				dt = math.max(dt, v22)
				v22 = 0
			end

			fn3(dt)
		end)
	end
end

heldStep(function()
	v8.firing = v16 and not v13

	if not v8.active or v17 then
		return
	end

	local now2 = os.clock()

	if now and now2 - now > 0.15 then
		now = nil
	end

	if not now then
		return
	end

	if v9 <= 0 then
		now = nil
		startReload()
	elseif v10 and v8:ready() then
		now = nil
		shoot()
	end
end)

local function press()
	v16 = true
	now = os.clock()
end
local function release()
	v16 = false
end
local function setAim(aiming: boolean) -- 2 equivalent calls inferred from this helper
	if aiming and not v8.active then
		return
	end

	v8.aiming = aiming
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
	autoFire = false,
	hipAutoFire = 180,
	assist = true,
	assistRange = { reach = 650, full = 350 },
	hipAssist = { reach = 260, full = 120, strength = 1.1 },
	bulletSpeed = bulletSpeed,
	bulletArc = arc,
	startFire = press,
	stopFire = release,
	setAim = setAim,
	isAiming = function()
		return v8.aiming
	end,
	reload = startReload
})