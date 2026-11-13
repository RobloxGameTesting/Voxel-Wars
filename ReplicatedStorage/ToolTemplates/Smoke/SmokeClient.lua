local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local parent = script.Parent
local LocalPlayer = Players.LocalPlayer
local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local Viewmodel = require(Voxel:WaitForChild("Viewmodel"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local VR = require(ReplicatedStorage2:WaitForChild("Voxel"):WaitForChild("VR"))
local Keyframes = require(Voxel:WaitForChild("Keyframes"))
local VoxelSound = require(Voxel:WaitForChild("VoxelSound"))
local TouchControls = require(Voxel:WaitForChild("TouchControls"))
local GrenadeFlight = require(Voxel:WaitForChild("GrenadeFlight"))
local SmokeVisuals = require(Voxel:WaitForChild("SmokeVisuals"))
local throwSmoke = Voxel:WaitForChild("Remotes"):WaitForChild("ThrowSmoke")

local newVector3 = Vector3.new

local v = Viewmodel.new(parent, {
	name = "SMOKE",
	hold = CFrame.new(0.95, -1.05, -2.05) * CFrame.Angles(
		0.10471975511965978,
		-0.24434609527920614,
		-0.10471975511965978
	),
	rightHand = Vector3.new(0.05, -0.28, 0.16),
	leftHand = Vector3.new(-0.27, 0.435, 0),
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
	{ 0.04, Vector3.new(-0.03, 0, 0) },
	{ 0.13, Vector3.new(-0.55, -0.05, 0.15), true }
}
local v3 = {
	{ 0, 0 },
	{ 0.13, 0, true },
	{ 0.25, 1, true }
}

local v4 = {
	{ 0, Vector3.new(0, 0, 0) },
	{ 0.08, Vector3.new(-0.05, 0.02, 0) },
	{ 0.13, Vector3.new(0, 0, 0) },
	{ 0.28, Vector3.new(0.3, 0.75, 0.6), true }
}
local v5 = {
	{ 0, Vector3.new(0, 0, 0) },
	{ 0.08, Vector3.new(0, -6, -8) },
	{ 0.13, Vector3.new(0, 0, 0) },
	{ 0.28, Vector3.new(-25, -10, 18), true }
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
	release = 0.13,
	length = 0.45,
	pos = {
		{ 0.07, Vector3.new(0.15, -0.9, 0.5) },
		{ 0.15, Vector3.new(0, 0.1, -1) },
		{ 0.25, Vector3.new(0, 0.3, -0.9) },
		{ 0.45, Vector3.new(0.1, -1.6, -0.2), true }
	},
	rot = {
		{ 0.07, Vector3.new(45, 0, -10) },
		{ 0.15, Vector3.new(-20, 0, 0) },
		{ 0.25, Vector3.new(-30, 0, 0) },
		{ 0.45, Vector3.new(0, 0, 0), true }
	}
}

local v8 = {
	{ 0, Vector3.new(0.1, -1.4, 0.3) },
	{ 0.35, Vector3.new(0, 0, 0), true }
}
local v9 = {
	{ 0, Vector3.new(-40, 15, 20) },
	{ 0.35, Vector3.new(0, 0, 0), true }
}
local v10 = {
	{ 0, 1 },
	{ 0.15, 1, true },
	{ 0.35, 0, true }
}

local v11 = "idle"
local lastTime = 0
local flag = false
local v12 = false
local v13 = 0
local v14 = v6
local v15 = { nil, nil, nil }
v15[1], v15[2], v15[3] = CFrame.identity, Vector3.new(0, 0, 0), Vector3.new(0, 0, 0)
local v16 = false
local v17 = 0
local renderSteppedConnection = nil

local gSet = { [Enum.KeyCode.G] = true }
local v18 = false
local v19 = false
local v20 = nil
local v21 = false

local function count() -- 4 equivalent calls inferred from this helper
	local smokes = parent:GetAttribute("Smokes")
	return if typeof(smokes) == "number" then smokes else 0
end

local function showCount(p: number) -- 3 equivalent calls inferred from this helper
	v17 = p
	v:setAmmo(math.min(p, 1), (math.max(p - 1, 0)))
end
parent:GetAttributeChangedSignal("Smokes"):Connect(function()
	showCount(count()) -- inferred equivalent call
end)

local function setPose(vector3: Vector3, vector3_2: Vector3) -- 5 equivalent calls inferred from this helper
	v.pose = Keyframes.pose(vector3, vector3_2)
end

local function rest() -- 3 equivalent calls inferred from this helper
	v.pinDelta = CFrame.identity
	v.pinVisible = true
	v.ammoVisible = true
	v.leftGun = nil
	v.leftWeight = 0
	v.pose = CFrame.identity
end

local function empty() -- 2 equivalent calls inferred from this helper
	v11 = "empty"
	v.ammoVisible = false
	v.pinVisible = false
	v.leftWeight = 1
	v.leftTarget = Vector3.new(-1.4, -2.8, -1.6)
	setPose(Vector3.new(0.1, -1.6, 0.3), Vector3.new(-40, 15, 20)) -- inferred equivalent call
end

local function enter(p: string) -- 7 equivalent calls inferred from this helper
	v11 = p
	lastTime = os.clock()
end

parent:GetAttributeChangedSignal("Smokes"):Connect(function()
	if v.active and v11 == "empty" and count() > 0 then -- inferred equivalent call
		v.pinDelta = CFrame.identity
		v.pinVisible = true
		v.ammoVisible = true
		v.leftGun = nil
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

	for _, childName in { "VoxelChips", "VoxelLoose", "VoxelGrenades", "VoxelSmoke" } do
		local child = workspace:FindFirstChild(childName)

		if child then
			table.insert(children, child)
		end
	end

	local muzzle = v:muzzle(children)
	local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity

	local lookVector = VR.frame(currentCamera).LookVector
	local position = VR.frame(currentCamera).Position
	local v22 = raycastParams
	Viewmodel.setFilter(v22, children)
	local raycastResult = workspace:Raycast(position, lookVector * 150, v22)
	local unit = (position + lookVector * math.max(not raycastResult and 150 or raycastResult.Distance, 8) - muzzle).Unit
	local launch = GrenadeFlight.launch(unit, v14 == v7, assemblyLinearVelocity)
	throwSmoke:FireServer(muzzle, launch)
	SmokeVisuals.predict(muzzle, launch)
	SmokeVisuals.spoon(CFrame.new(muzzle) * currentCamera.CFrame.Rotation, assemblyLinearVelocity)
	VoxelSound.grenadeSpoon()
	v.ammoVisible = false

	if parent:GetAttribute("Infinite") ~= true then
		showCount(math.max(v17 - 1, 0)) -- inferred equivalent call
	end
end

local function step(p: number)
	local v22 = os.clock() - lastTime
	v13 = math.clamp(v13 + (v12 and 1 or -1) * 9 * p, 0, 1)
	local lerped = (Vector3.new(0.3, 0.75, 0.6)):Lerp(Vector3.new(0.05, -0.5, 0.2), v13)
	local lerped2 = (Vector3.new(-25, -10, 18)):Lerp(Vector3.new(30, 0, -10), v13)

	if v11 == "pull" then
		local sample = Keyframes.sample(v2, v22)
		v.pinDelta = CFrame.new(sample)
		v.leftGun = Vector3.new(-0.27, 0.435, 0) + sample
		v.leftWeight = Keyframes.sample(v3, v22)
		v.leftTarget = Vector3.new(-1.4, -2.8, -1.6)
		v.pinVisible = v22 < 0.25
		local v23 = math.clamp((v22 - 0.13) / 0.15000000000000002, 0, 1)
		local sample2 = Keyframes.sample(v4, v22)
		local sample3 = Keyframes.sample(v5, v22)

		setPose(sample2:Lerp(lerped, v23 * v13), sample3:Lerp(lerped2, v23 * v13)) -- inferred equivalent call

		if v22 >= 0.28 then
			enter("held") -- inferred equivalent call
		end
	elseif v11 == "held" then
		setPose(lerped, lerped2) -- inferred equivalent call

		if not flag then
			local v23 = if v13 > 0.5 then v7 else v6
			v14 = v23
			v15 = { CFrame.identity, lerped, lerped2 }
			v16 = false
			enter("throw") -- inferred equivalent call
			VoxelSound.swing(workspace.CurrentCamera.CFrame.Position)
		end
	elseif v11 == "throw" then
		local v23 = v14
		local pos = {
			{ 0, v15[2] }
		}
		local v24 = {
			{ 0, v15[3] }
		}

		for _, po in v23.pos do
			table.insert(pos, po)
		end

		for _, v25 in v23.rot do
			table.insert(v24, v25)
		end

		setPose(Keyframes.sample(pos, v22), Keyframes.sample(v24, v22)) -- inferred equivalent call

		if not v16 and v23.release <= v22 then
			v16 = true
			throw()
		end

		if v23.length <= v22 and v18 and not v21 then
			v18 = false
		end

		if v23.length <= v22 and v18 then
			v18 = false
			v21 = false
			local character = LocalPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local v25 = v20
			v20 = nil

			if humanoid and humanoid.Health > 0 then
				if v25 and v25.Parent == LocalPlayer:FindFirstChildOfClass("Backpack") then
					humanoid:EquipTool(v25)
				else
					humanoid:UnequipTools()
				end
			end
		elseif v23.length <= v22 then
			if v17 > 0 then
				v.pinDelta = CFrame.identity
				v.pinVisible = true
				v.ammoVisible = true
				v.leftGun = nil
				enter("next") -- inferred equivalent call
			else
				empty() -- inferred equivalent call
			end
		end
	elseif v11 == "next" then
		setPose(Keyframes.sample(v8, v22), Keyframes.sample(v9, v22)) -- inferred equivalent call
		v.leftWeight = Keyframes.sample(v10, v22)
		v.leftTarget = Vector3.new(-1.4, -2.8, -1.6)

		if v22 >= 0.35 then
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
	v12 = false
	v13 = 0
	showCount(count()) -- inferred equivalent call

	if v17 > 0 then
		rest() -- inferred equivalent call
		enter("idle") -- inferred equivalent call
	else
		empty() -- inferred equivalent call
	end

	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		if not v.active then
			return
		end

		step(math.min(dt, 0.1))
	end)
end

local function stop()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	flag = false
	v12 = false
	v18 = false
	v21 = false
	v.firing = false
	rest() -- inferred equivalent call
	v11 = "idle"
end

parent.Equipped:Connect(start)
parent.Unequipped:Connect(stop)

local function press()
	if flag then
		return
	end

	flag = true
	v.firing = true

	if v11 ~= "idle" or v17 <= 0 then
		return
	end

	local lastTime2 = os.clock()

	while v.active and not v:ready() and os.clock() - lastTime2 < 0.5 do
		task.wait()
	end

	if not v.active or v11 ~= "idle" or Viewmodel.held() then
		return
	end

	enter("pull") -- inferred equivalent call
	VoxelSound.grenadePin()
end
local function release() -- 2 equivalent calls inferred from this helper
	flag = false
	v.firing = false
end
local function setLob(flag2: boolean)
	v12 = flag2 and v.active
end

parent.Activated:Connect(press)
parent.Deactivated:Connect(release)

local function quickBegan(p, flag2: boolean)
	if flag2 or not gSet[p.KeyCode] or v19 then
		return
	end

	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid and not (humanoid.Health <= 0) and humanoid.SeatPart == nil and not (count() <= 0) then -- inferred equivalent call
		if
			parent.Parent ~= character and parent.Parent ~= LocalPlayer:FindFirstChildOfClass("Backpack")
			or parent.Parent == character and v11 ~= "idle"
		then
			return
		end

		v19 = true
		v18 = true

		if parent.Parent == character then
			v20 = nil
			v21 = false
		else
			local tool = character:FindFirstChildOfClass("Tool")

			if not tool or tool == parent then
				tool = nil
			end

			v20 = tool
			v21 = true
			humanoid:EquipTool(parent)
		end

		task.spawn(function()
			local lastTime2 = os.clock()

			while not v.active and os.clock() - lastTime2 < 0.5 do
				task.wait()
			end

			if v.active then
				press()

				if not v19 then
					release() -- inferred equivalent call
				end
			else
				v18 = false
				v19 = false
				v21 = false
			end
		end)
	end
end
local function quickEnded(p)
	if not (gSet[p.KeyCode] and v19) then
		return
	end

	v19 = false

	if flag then
		release() -- inferred equivalent call
	end
end

local flag2 = false
local function wireQuick() -- 2 equivalent calls inferred from this helper
	if flag2 then
		return
	end

	flag2 = true
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

	table.insert(connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if v.active then
			local ReplicatedStorage3 = game:GetService("ReplicatedStorage")

			if require(ReplicatedStorage3:WaitForChild("Voxel"):WaitForChild("AimKey")).began(input, gameProcessed) then
				v12 = v.active
			end
		end
	end))
	table.insert(connections, UserInputService.InputEnded:Connect(function(input)
		local ReplicatedStorage3 = game:GetService("ReplicatedStorage")

		if require(ReplicatedStorage3:WaitForChild("Voxel"):WaitForChild("AimKey")).ended(input) then
			v12 = false
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

if parent.Parent ~= nil and parent.Parent == LocalPlayer.Character then
	wire()
end

TouchControls.register(parent, {
	label = "THROW",
	startFire = press,
	stopFire = release,
	setAim = setLob,
	isAiming = function()
		return v12
	end
})