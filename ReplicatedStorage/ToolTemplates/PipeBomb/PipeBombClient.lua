local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local parent = script.Parent
local LocalPlayer = Players.LocalPlayer
local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local Viewmodel = require(Voxel:WaitForChild("Viewmodel"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local VR = require(ReplicatedStorage2:WaitForChild("Voxel"):WaitForChild("VR"))
local Keyframes = require(Voxel:WaitForChild("Keyframes"))
local VoxelSound = require(Voxel:WaitForChild("VoxelSound"))
local TouchControls = require(Voxel:WaitForChild("TouchControls"))
local PipeBombVisuals = require(Voxel:WaitForChild("PipeBombVisuals"))
local throwBomb = Voxel:WaitForChild("Remotes"):WaitForChild("ThrowBomb")

local newVector3 = Vector3.new

local v = Viewmodel.new(parent, {
	name = "DEMO CHARGE",
	hold = CFrame.new(0.95, -1.05, -2.05) * CFrame.Angles(
		0.10471975511965978,
		-0.24434609527920614,
		-0.10471975511965978
	) * CFrame.Angles(0, 0, 1.3089969389957472),
	rightHand = Vector3.new(-0.12, -0.05, 0.16),
	leftHand = Vector3.new(0.62, 0, 0),
	muzzle = Vector3.new(0, 0, 0),
	aimPoint = Vector3.new(0, 0, 0),
	aimDistance = 2,
	aimFov = 70,
	aimMove = 1,
	reach = 3,
	sprintHold = CFrame.new(0.85, -1.6, -1.7) * CFrame.Angles(
		-0.17453292519943295,
		0.4363323129985824,
		0.2617993877991494
	) * CFrame.Angles(0, 0, 1.3089969389957472),
	hipKick = Vector3.new(0, 0, 0),
	hipKickRot = Vector3.new(0, 0, 0),
	aimKick = Vector3.new(0, 0, 0),
	aimKickRot = Vector3.new(0, 0, 0),
	recoilTime = 0.3,
	punch = 0
})

v.aimBlocked = true

local v2 = {
	{ 0, Vector3.new(0, 0, 0) },
	{ 0.05, Vector3.new(0.05, 0.04, 0) },
	{ 0.1, Vector3.new(-0.3, 0.15, 0.1), true }
}
local v3 = {
	{ 0, 0 },
	{ 0.1, 0, true },
	{ 0.22, 1, true }
}

local v4 = {
	{ 0, Vector3.new(0, 0, 0) },
	{ 0.07, Vector3.new(-0.05, 0.02, 0) },
	{ 0.24, Vector3.new(0.3, 0.75, 0.6), true }
}
local v5 = {
	{ 0, Vector3.new(0, 0, 0) },
	{ 0.07, Vector3.new(0, -6, -8) },
	{ 0.24, Vector3.new(-25, -10, 18), true }
}

local v6 = {
	release = 0.11,
	length = 0.4,
	pos = {
		{ 0.06, Vector3.new(0.45, 1, 0.8) },
		{ 0.13, Vector3.new(-0.55, 0.45, -1.1) },
		{ 0.22, Vector3.new(-0.45, -0.6, -0.8) },
		{ 0.4, Vector3.new(-0.2, -1.6, -0.2), true }
	},
	rot = {
		{ 0.06, Vector3.new(-35, -12, 22) },
		{ 0.13, Vector3.new(40, 8, -10) },
		{ 0.22, Vector3.new(70, 10, -20) },
		{ 0.4, Vector3.new(80, 10, -20), true }
	}
}

local v7 = {
	{ 0, Vector3.new(0.1, -1.4, 0.3) },
	{ 0.35, Vector3.new(0, 0, 0), true }
}
local v8 = {
	{ 0, Vector3.new(-40, 15, 20) },
	{ 0.35, Vector3.new(0, 0, 0), true }
}
local v9 = {
	{ 0, 1 },
	{ 0.15, 1, true },
	{ 0.35, 0, true }
}

local v10 = "idle"
local lastTime = 0
local flag = false
local v11 = false
local v12 = 0
local renderSteppedConnection = nil

local function count() -- 2 equivalent calls inferred from this helper
	local charges = parent:GetAttribute("Charges")
	return if typeof(charges) == "number" then charges else 0
end

local function showCount(p: number) -- 3 equivalent calls inferred from this helper
	v12 = p
	v:setAmmo(math.min(p, 1), (math.max(p - 1, 0)))
end

local function setPose(sample: Vector3, sample2: Vector3) -- 5 equivalent calls inferred from this helper
	v.pose = Keyframes.pose(sample, sample2)
end

local function rest() -- 3 equivalent calls inferred from this helper
	v.ammoVisible = true
	v.leftGun = nil
	v.leftWeight = 0
	v.pose = CFrame.identity
end

local function enter(p: string) -- 7 equivalent calls inferred from this helper
	v10 = p
	lastTime = os.clock()
end

local function empty() -- 2 equivalent calls inferred from this helper
	v10 = "empty"
	v.ammoVisible = false
	v.leftGun = nil
	v.leftWeight = 1
	v.leftTarget = Vector3.new(-1.4, -2.8, -1.6)
	setPose(Vector3.new(0.1, -1.6, 0.3), Vector3.new(-40, 15, 20)) -- inferred equivalent call
end

parent:GetAttributeChangedSignal("Charges"):Connect(function()
	showCount(count()) -- inferred equivalent call

	if v.active and v10 == "empty" and v12 > 0 then
		v.ammoVisible = true
		enter("next") -- inferred equivalent call
	end
end)

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local function throw()
	local character = LocalPlayer.Character

	if not (character and character:FindFirstChild("HumanoidRootPart")) then
		return
	end

	local currentCamera = workspace.CurrentCamera
	local children = { character }

	for _, childName in { "VoxelChips", "VoxelLoose", "VoxelGrenades", "VoxelBombs" } do
		local child = workspace:FindFirstChild(childName)

		if child then
			table.insert(children, child)
		end
	end

	local muzzle = v:muzzle(children)

	local lookVector = VR.frame(currentCamera).LookVector
	local position = VR.frame(currentCamera).Position
	local v13 = raycastParams
	Viewmodel.setFilter(v13, children)
	local raycastResult = workspace:Raycast(position, lookVector * 150, v13)
	local unit = (position + lookVector * math.max(not raycastResult and 150 or raycastResult.Distance, 8) - muzzle).Unit

	PipeBombVisuals.predict(muzzle, unit)
	throwBomb:FireServer(muzzle, unit)
	v.ammoVisible = false
	showCount(math.max(v12 - 1, 0)) -- inferred equivalent call
end

local function step()
	local v13 = os.clock() - lastTime

	if v10 == "draw" then
		v.leftGun = Vector3.new(0.62, 0, 0) + Keyframes.sample(v2, v13)
		v.leftWeight = Keyframes.sample(v3, v13)
		v.leftTarget = Vector3.new(-1.4, -2.8, -1.6)
		setPose(Keyframes.sample(v4, v13), Keyframes.sample(v5, v13)) -- inferred equivalent call

		if v13 >= 0.24 then
			enter("held") -- inferred equivalent call
		end
	elseif v10 == "held" then
		setPose(Vector3.new(0.3, 0.75, 0.6), Vector3.new(-25, -10, 18)) -- inferred equivalent call

		if not flag then
			v11 = false
			enter("throw") -- inferred equivalent call
			VoxelSound.swing(workspace.CurrentCamera.CFrame.Position)
		end
	elseif v10 == "throw" then
		local pos = {
			{ 0, Vector3.new(0.3, 0.75, 0.6) }
		}
		local v14 = {
			{ 0, Vector3.new(-25, -10, 18) }
		}

		for _, po in v6.pos do
			table.insert(pos, po)
		end

		for _, v15 in v6.rot do
			table.insert(v14, v15)
		end

		setPose(Keyframes.sample(pos, v13), Keyframes.sample(v14, v13)) -- inferred equivalent call

		if not v11 and v6.release <= v13 then
			v11 = true
			throw()
		end

		if v6.length <= v13 then
			if v12 > 0 then
				v.ammoVisible = true
				v.leftGun = nil
				enter("next") -- inferred equivalent call
			else
				empty() -- inferred equivalent call
			end
		end
	elseif v10 == "next" then
		setPose(Keyframes.sample(v7, v13), Keyframes.sample(v8, v13)) -- inferred equivalent call
		v.leftWeight = Keyframes.sample(v9, v13)
		v.leftTarget = Vector3.new(-1.4, -2.8, -1.6)

		if v13 >= 0.35 then
			rest() -- inferred equivalent call
			enter("idle") -- inferred equivalent call
		end
	end
end

local function start()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
	end

	flag = false
	showCount(count()) -- inferred equivalent call

	if v12 > 0 then
		rest() -- inferred equivalent call
		enter("idle") -- inferred equivalent call
	else
		empty() -- inferred equivalent call
	end

	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		if v.active then
			step()
		end
	end)
end

local function stop()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	flag = false
	v.firing = false
	rest() -- inferred equivalent call
	v10 = "idle"
end

parent.Equipped:Connect(start)
parent.Unequipped:Connect(stop)

local function press()
	if flag then
		return
	end

	flag = true
	v.firing = true

	if v10 ~= "idle" then
		return
	end

	local lastTime2 = os.clock()

	while v.active and not v:ready() and os.clock() - lastTime2 < 0.5 do
		task.wait()
	end

	if not v.active or v10 ~= "idle" or Viewmodel.held() or v12 <= 0 then
		return
	end

	enter("draw") -- inferred equivalent call
end
local function release()
	flag = false
	v.firing = false
end

parent.Activated:Connect(press)
parent.Deactivated:Connect(release)

TouchControls.register(parent, { label = "THROW", startFire = press, stopFire = release })