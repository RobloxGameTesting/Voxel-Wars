local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local parent = script.Parent
local LocalPlayer = Players.LocalPlayer
local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local Viewmodel = require(Voxel:WaitForChild("Viewmodel"))
local VR = require(Voxel:WaitForChild("VR"))
local Keyframes = require(Voxel:WaitForChild("Keyframes"))
local VoxelSound = require(Voxel:WaitForChild("VoxelSound"))
local TouchControls = require(Voxel:WaitForChild("TouchControls"))
local C4Shared = require(Voxel:WaitForChild("C4Shared"))
local C4Visuals = require(Voxel:WaitForChild("C4Visuals"))
local throwC4 = Voxel:WaitForChild("Remotes"):WaitForChild("ThrowC4")
local detonateC4 = Voxel:WaitForChild("Remotes"):WaitForChild("DetonateC4")

local newVector3 = Vector3.new

local v = Viewmodel.new(parent, {
	name = "C4",
	hold = CFrame.new(0.72, -1.15, -2) * CFrame.Angles(0.6632251157578453, -0.17453292519943295, 0),
	rightHand = Vector3.new(0.32, -0.2, 0.2),
	leftHand = Vector3.new(-1.3199999, -0.12, 0.12),
	muzzle = Vector3.new(0, 0, 0),
	aimPoint = Vector3.new(0, 0, 0),
	aimDistance = 2,
	aimFov = 70,
	aimMove = 1,
	reach = 3,
	sprintHold = CFrame.new(0.7, -1.65, -1.7) * CFrame.Angles(
		0.17453292519943295,
		0.2617993877991494,
		0.13962634015954636
	),
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
	{ 0.09, Vector3.new(0.12, -0.3, 0.3) },
	{ 0.17, Vector3.new(-0.05, 0.15, -0.55) },
	{ 0.42, Vector3.new(0.5, 0.12, 0.15), true }
}
local v3 = {
	{ 0, Vector3.new(0, 0, 0) },
	{ 0.09, Vector3.new(-14, 0, 0) },
	{ 0.17, Vector3.new(16, 0, 0) },
	{ 0.42, Vector3.new(0, 0, 0), true }
}

local v4 = {
	{ 0, Vector3.new(0.5, 0.12, 0.15) },
	{ 0.35, Vector3.new(0, 0, 0), true }
}

local v5 = {
	{ 0, 0 },
	{ 0.06, 1 },
	{ 0.16, 1 },
	{ 0.3, 0, true }
}

local v6 = "idle"
local lastTime = 0
local flag = false
local v7 = false
local v8 = 0
local total = 0
local v9 = 0
local renderSteppedConnection = nil
local gSet = { [Enum.KeyCode.G] = true }
local v10 = nil
local flag2 = false

local count = 0

local function count2() -- 5 equivalent calls inferred from this helper
	local attribute = parent:GetAttribute(C4Shared.ATTR)
	return if typeof(attribute) == "number" then attribute else 0
end

local function out() -- 2 equivalent calls inferred from this helper
	local attribute = LocalPlayer:GetAttribute(C4Shared.LIVE_ATTR)
	return (math.max(typeof(attribute) ~= "number" and 0 or attribute, C4Visuals.mine()))
end

local function showCount(p: number) -- 4 equivalent calls inferred from this helper
	v8 = p
	v:setAmmo(math.min(p, 1), (math.max(p - 1, 0)))
end

local function enter(p: string) -- 6 equivalent calls inferred from this helper
	v6 = p
	lastTime = os.clock()
end

local function lever(sample: number) -- 1 equivalent call inferred from this helper
	v.pinDelta = CFrame.new(Vector3.new(-1.19, -0.16, 0)) * CFrame.Angles(0, 0, (math.rad(sample * 16))) * CFrame.new(Vector3.new(1.19, 0.16, -0))
end

local function settle() -- 2 equivalent calls inferred from this helper
	if v8 > 0 then
		v.ammoVisible = true
		v.pose = CFrame.identity
		v6 = "idle"
	else
		v.ammoVisible = false
		v.pose = Keyframes.pose(Vector3.new(0.5, 0.12, 0.15), Vector3.new(0, 0, 0))
		v6 = "det"
	end

	lastTime = os.clock()
end

parent:GetAttributeChangedSignal(C4Shared.ATTR):Connect(function()
	showCount(count2()) -- inferred equivalent call

	if v.active and v6 == "det" and v8 > 0 then
		v.ammoVisible = true
		enter("next") -- inferred equivalent call
	end
end)

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local function throw()
	local character = LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local currentCamera = workspace.CurrentCamera
	local children = { character }

	for _, childName in { "VoxelChips", "VoxelLoose", "VoxelGrenades", "VoxelMolotovs", "VoxelC4" } do
		local child = workspace:FindFirstChild(childName)

		if child then
			table.insert(children, child)
		end
	end

	local muzzle = v:muzzle(children)

	local frame = VR.frame(currentCamera)
	local lookVector = frame.LookVector
	local position = frame.Position
	Viewmodel.setFilter(raycastParams, children)
	local raycastResult = workspace:Raycast(position, lookVector * 30, raycastParams)
	local v11 = math.max(not raycastResult and 30 or raycastResult.Distance, 4)
	local launch = C4Shared.launch((position + lookVector * v11 - muzzle).Unit, humanoidRootPart.AssemblyLinearVelocity)
	throwC4:FireServer(muzzle, launch)
	C4Visuals.predict(muzzle, launch)
	VoxelSound.swing(muzzle)
	v.ammoVisible = false

	if parent:GetAttribute("Infinite") ~= true then
		showCount(math.max(v8 - 1, 0)) -- inferred equivalent call

		count += 1
		local v12 = count
		task.delay(1.5, function()
			if count == v12 and v8 ~= count2() then -- inferred equivalent call
				showCount(count2()) -- inferred equivalent call

				if v.active and v6 == "det" and v8 > 0 then
					v.ammoVisible = true
					enter("next") -- inferred equivalent call
				end
			end
		end)
	end
end

local function quickBack()
	flag2 = false
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local v11 = v10
	v10 = nil

	if humanoid and humanoid.Health > 0 then
		if v11 and v11.Parent == LocalPlayer:FindFirstChildOfClass("Backpack") then
			humanoid:EquipTool(v11)
		else
			humanoid:UnequipTools()
		end
	end
end

local function squeeze()
	if not v.active or v6 == "throw" or v6 == "squeeze" then
		return
	end

	local now = os.clock()

	if now - v9 < C4Shared.DETONATE_COOLDOWN then
		return
	end

	v9 = now
	VoxelSound.grenadePin()

	if out() > 0 then -- inferred equivalent call
		detonateC4:FireServer()
		VoxelSound.designator("tick")
	else
		VoxelSound.designator("bad")
	end

	enter("squeeze") -- inferred equivalent call
end

local function step(dt: number)
	local v11 = os.clock() - lastTime

	local v12 = v.ammoVisible and v6 ~= "squeeze" and 0 or 1
	total += (v12 - total) * math.min(dt * 14, 1)
	v.rightGun = Vector3.new(-1.16, 0.06, 0.12)
	v.rightWeight = total

	if v6 == "throw" then
		v.pose = Keyframes.pose(Keyframes.sample(v2, v11), Keyframes.sample(v3, v11))

		if not v7 and v11 >= 0.17 then
			v7 = true
			throw()
		end

		if v11 >= 0.42 then
			if v8 > 0 then
				v.ammoVisible = true
				v6 = "next"
			elseif v8 > 0 then
				v.ammoVisible = true
				v.pose = CFrame.identity
				v6 = "idle"
			else
				v.ammoVisible = false
				v.pose = Keyframes.pose(Vector3.new(0.5, 0.12, 0.15), Vector3.new(0, 0, 0))
				v6 = "det"
			end

			lastTime = os.clock()
		end
	elseif v6 == "next" then
		v.pose = Keyframes.pose(Keyframes.sample(v4, v11), Vector3.new(0, 0, 0))
		v.ammoDelta = CFrame.new(0, math.max(1 - v11 / 0.35, 0) * -1.4, 0)

		if v11 >= 0.35 then
			v.ammoDelta = CFrame.identity
			settle() -- inferred equivalent call
		end
	elseif v6 == "squeeze" then
		local sample = Keyframes.sample(v5, v11)
		lever(sample) -- inferred equivalent call
		v.pose = Keyframes.pose(
			(v.ammoVisible and Vector3.new(0, 0, 0) or Vector3.new(0.5, 0.12, 0.15)) + Vector3.new(0, -0.05, 0.04) * sample,
			Vector3.new(0, 0, 0)
		)

		if v11 >= 0.3 then
			v.pinDelta = CFrame.new(Vector3.new(-1.19, -0.16, 0)) * CFrame.Angles(0, 0, 0) * CFrame.new(Vector3.new(1.19, 0.16, -0))

			if flag2 then
				quickBack()
			elseif v8 > 0 then
				v.ammoVisible = true
				v.pose = CFrame.identity
				enter("idle") -- inferred equivalent call
			else
				v.ammoVisible = false
				v.pose = Keyframes.pose(Vector3.new(0.5, 0.12, 0.15), Vector3.new(0, 0, 0))
				enter("det") -- inferred equivalent call
			end
		end
	end
end

local function start()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
	end

	flag = false
	total = 0
	v.pinDelta = CFrame.new(Vector3.new(-1.19, -0.16, 0)) * CFrame.Angles(0, 0, 0) * CFrame.new(Vector3.new(1.19, 0.16, -0))

	v.ammoDelta = CFrame.identity
	showCount(count2()) -- inferred equivalent call
	settle() -- inferred equivalent call
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		if not v.active then
			return
		end

		step(dt)
	end)
end

local function stop()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	flag = false
	flag2 = false
	v10 = nil
	v.firing = false
	v.rightWeight = 0
	v.ammoDelta = CFrame.identity
	v.ammoVisible = true
	v.pose = CFrame.identity
	v.pinDelta = CFrame.new(Vector3.new(-1.19, -0.16, 0)) * CFrame.Angles(0, 0, 0) * CFrame.new(Vector3.new(1.19, 0.16, -0))

	v6 = "idle"
end

parent.Equipped:Connect(start)
parent.Unequipped:Connect(stop)

local function press()
	if flag then
		return
	end

	flag = true
	v.firing = true
	local lastTime2 = os.clock()

	while v.active and not v:ready() and os.clock() - lastTime2 < 0.5 do
		task.wait()
	end

	if not v.active or Viewmodel.held() then
		return
	end

	if v6 == "det" then
		squeeze()
	elseif v6 == "idle" and v8 > 0 then
		v7 = false
		enter("throw") -- inferred equivalent call
	end
end
local function release()
	flag = false
	v.firing = false
end

parent.Activated:Connect(press)
parent.Deactivated:Connect(release)

local v11 = false
local function quickBegan(p, flag3: boolean)
	if flag3 or not gSet[p.KeyCode] or v11 then
		return
	end

	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if
		not humanoid
		or humanoid.Health <= 0
		or humanoid.SeatPart ~= nil
		or parent.Parent ~= character and parent.Parent ~= LocalPlayer:FindFirstChildOfClass("Backpack")
	then
		return
	end

	v11 = true

	if parent.Parent == character then
		if v6 ~= "throw" and v6 ~= "squeeze" then
			quickBack()
		end
	else
		if count2() <= 0 and out() <= 0 then -- inferred equivalent call
			return
		end

		local tool = character:FindFirstChildOfClass("Tool")
		flag2 = true
		humanoid:EquipTool(parent)

		if not tool or tool == parent then
			tool = nil
		end

		v10 = tool
		flag2 = true
	end
end
local function quickEnded(p)
	if gSet[p.KeyCode] then
		v11 = false
	end
end

local flag3 = false
local function wireQuick() -- 2 equivalent calls inferred from this helper
	if flag3 then
		return
	end

	flag3 = true
	UserInputService.InputBegan:Connect(quickBegan)
	UserInputService.InputEnded:Connect(quickEnded)
end

if UserInputService.KeyboardEnabled or UserInputService.GamepadEnabled then
	wireQuick() -- inferred equivalent call
else
	local connections = {}
	local function arrived() -- 1 equivalent call inferred from this helper
		for _, connection in connections do
			connection:Disconnect()
		end

		wireQuick() -- inferred equivalent call
	end
	table.insert(connections, UserInputService.GamepadConnected:Connect(arrived))
	table.insert(connections, UserInputService.LastInputTypeChanged:Connect(function(p)
		if p == Enum.UserInputType.Keyboard then
			arrived() -- inferred equivalent call
		end
	end))
end

local connections = {}
local function wire()
	if #connections > 0 then
		return
	end

	table.insert(connections, UserInputService.InputBegan:Connect(function(input)
		if v.active and input.UserInputType == Enum.UserInputType.MouseButton2 then
			squeeze()
		end
	end))
end
parent.Equipped:Connect(wire)
parent.Unequipped:Connect(function()
	for _, connection in connections do
		connection:Disconnect()
	end

	table.clear(connections)
end)

if parent.Parent ~= nil and parent.Parent == LocalPlayer.Character and not (#connections > 0) then
	table.insert(connections, UserInputService.InputBegan:Connect(function(input)
		if v.active and input.UserInputType == Enum.UserInputType.MouseButton2 then
			squeeze()
		end
	end))
end

TouchControls.register(parent, {
	label = "THROW",
	startFire = press,
	stopFire = release,
	setAim = function(flag4: boolean)
		if flag4 then
			squeeze()
		end
	end,
	isAiming = function(): boolean
		return false
	end
})