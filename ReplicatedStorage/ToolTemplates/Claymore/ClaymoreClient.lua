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
local ClaymoreShared = require(Voxel:WaitForChild("ClaymoreShared"))
local ClaymoreVisuals = require(Voxel:WaitForChild("ClaymoreVisuals"))
local placeClaymore = Voxel:WaitForChild("Remotes"):WaitForChild("PlaceClaymore")

local newVector3 = Vector3.new

local v = Viewmodel.new(parent, {
	name = "CLAYMORE",
	hold = CFrame.new(0.55, -1.2, -2.1) * CFrame.Angles(0.17453292519943295, 2.9670597283903604, 0),
	rightHand = Vector3.new(-0.5, 0.2, -0.12),
	leftHand = Vector3.new(0.5, 0.2, -0.12),
	muzzle = Vector3.new(0, 0, 0),
	aimPoint = Vector3.new(0, 0, 0),
	aimDistance = 2,
	aimFov = 70,
	aimMove = 1,
	reach = 3,
	sprintHold = CFrame.new(0.6, -1.65, -1.7) * CFrame.Angles(
		-0.20943951023931956,
		3.490658503988659,
		0.17453292519943295
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
	{ 0.2, Vector3.new(-0.3, -0.75, -0.9) },
	{ 0.42, Vector3.new(-0.3, -1.7, -0.5), true }
}
local v3 = {
	{ 0, Vector3.new(0, 0, 0) },
	{ 0.2, Vector3.new(-28, 0, 0) },
	{ 0.42, Vector3.new(-45, 0, 0), true }
}

local v4 = {
	{ 0, Vector3.new(0, -1.5, 0.3) },
	{ 0.35, Vector3.new(0, 0, 0), true }
}
local v5 = {
	{ 0, Vector3.new(-35, 0, 0) },
	{ 0.35, Vector3.new(0, 0, 0), true }
}

local v6 = "idle"
local lastTime = 0
local flag = false
local v7 = false
local v8 = 0
local renderSteppedConnection = nil

local gSet = { [Enum.KeyCode.G] = true }
local flag2 = false
local v9 = false
local v10 = nil
local v11 = false

local count = 0

local function count2() -- 6 equivalent calls inferred from this helper
	local attribute = parent:GetAttribute(ClaymoreShared.ATTR)
	return if typeof(attribute) == "number" then attribute else 0
end

local function showCount(p: number) -- 4 equivalent calls inferred from this helper
	v8 = p
	v:setAmmo(math.min(p, 1), (math.max(p - 1, 0)))
end
parent:GetAttributeChangedSignal(ClaymoreShared.ATTR):Connect(function()
	showCount(count2()) -- inferred equivalent call
end)

local function setPose(sample: Vector3, sample2: Vector3) -- 4 equivalent calls inferred from this helper
	v.pose = Keyframes.pose(sample, sample2)
end

local function rest() -- 4 equivalent calls inferred from this helper
	v.ammoVisible = true
	v.pose = CFrame.identity
end

local function empty() -- 2 equivalent calls inferred from this helper
	v6 = "empty"
	v.ammoVisible = false
	setPose(Vector3.new(0, -1.7, 0.3), Vector3.new(-40, 0, 0)) -- inferred equivalent call
end

local function enter(p: string) -- 6 equivalent calls inferred from this helper
	v6 = p
	lastTime = os.clock()
end

local function bringNext() -- 3 equivalent calls inferred from this helper
	v.ammoVisible = true
	enter("next") -- inferred equivalent call
end

parent:GetAttributeChangedSignal(ClaymoreShared.ATTR):Connect(function()
	if v.active and v6 == "empty" and count2() > 0 then -- inferred equivalent call
		bringNext() -- inferred equivalent call
	end
end)

local function spot()
	local character = LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return nil, nil, nil
	end

	local lookVector = VR.frame(workspace.CurrentCamera).LookVector
	local spot2, v12 = ClaymoreVisuals.spot(humanoidRootPart, lookVector)

	if spot2 and v12 then
		return spot2, v12, lookVector
	end

	return nil, nil, nil
end

local function place(): boolean
	local character = LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local lookVector, v12, v13

	if humanoidRootPart then
		lookVector = VR.frame(workspace.CurrentCamera).LookVector
		v12, v13 = ClaymoreVisuals.spot(humanoidRootPart, lookVector)

		if not (v12 and v13) then
			v12 = nil
			v13 = nil
			lookVector = nil
		end
	end

	if not (v12 and v13 and lookVector) then
		return false
	end

	local frame = ClaymoreShared.frame(v12, v13, lookVector)

	if not frame then
		return false
	end

	placeClaymore:FireServer(v12, lookVector)
	ClaymoreVisuals.predict(frame)
	VoxelSound.grenadePin()
	v.ammoVisible = false

	if parent:GetAttribute("Infinite") == true then
		return true
	end

	showCount(math.max(v8 - 1, 0)) -- inferred equivalent call

	count += 1
	local v14 = count
	task.delay(1.5, function()
		if count == v14 and v8 ~= count2() then -- inferred equivalent call
			showCount(count2()) -- inferred equivalent call

			if v.active and v6 == "empty" and v8 > 0 then
				bringNext() -- inferred equivalent call
			end
		end
	end)

	return true
end

local function quickBack()
	flag2 = false
	v11 = false
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local v12 = v10
	v10 = nil

	if humanoid and humanoid.Health > 0 then
		if v12 and v12.Parent == LocalPlayer:FindFirstChildOfClass("Backpack") then
			humanoid:EquipTool(v12)
		else
			humanoid:UnequipTools()
		end
	end
end

local function step()
	local v12 = os.clock() - lastTime

	if v6 == "aim" then
		if flag then
			setPose(Vector3.new(-0.15, -0.2, -0.35), Vector3.new(-12, 0, 0)) -- inferred equivalent call
			local character = LocalPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			local lookVector, v13, v14

			if humanoidRootPart then
				lookVector = VR.frame(workspace.CurrentCamera).LookVector
				v13, v14 = ClaymoreVisuals.spot(humanoidRootPart, lookVector)

				if not (v13 and v14) then
					v13 = nil
					v14 = nil
					lookVector = nil
				end
			end

			local ghost = ClaymoreVisuals.ghost
			local v15

			if v13 and v14 and lookVector then
				v15 = ClaymoreShared.frame(v13, v14, lookVector)
			end

			ghost(v15)
		else
			ClaymoreVisuals.ghost(nil)

			if place() then
				v7 = true
				enter("plant") -- inferred equivalent call
			else
				VoxelSound.designator("bad")
				rest() -- inferred equivalent call
				enter("idle") -- inferred equivalent call

				if flag2 and v11 then
					quickBack()
				end

				flag2 = false
			end
		end
	elseif v6 == "plant" then
		setPose(Keyframes.sample(v2, v12), Keyframes.sample(v3, v12)) -- inferred equivalent call

		if v12 >= 0.42 then
			if flag2 and v11 then
				quickBack()
				return
			end

			flag2 = false

			if v8 > 0 then
				bringNext() -- inferred equivalent call
			else
				empty() -- inferred equivalent call
			end
		end
	elseif v6 == "next" then
		setPose(Keyframes.sample(v4, v12), Keyframes.sample(v5, v12)) -- inferred equivalent call

		if v12 >= 0.35 then
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
	showCount(count2()) -- inferred equivalent call

	if v8 > 0 then
		rest() -- inferred equivalent call
		enter("idle") -- inferred equivalent call
	else
		empty() -- inferred equivalent call
	end

	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		if not v.active then
			return
		end

		step()
	end)
end

local function stop()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	flag = false
	flag2 = false
	v11 = false
	v.firing = false
	ClaymoreVisuals.ghost(nil)
	rest() -- inferred equivalent call
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

	if v6 ~= "idle" or v8 <= 0 then
		return
	end

	local lastTime2 = os.clock()

	while v.active and not v:ready() and os.clock() - lastTime2 < 0.5 do
		task.wait()
	end

	if not v.active or v6 ~= "idle" or Viewmodel.held() then
		return
	end

	v7 = false
	enter("aim") -- inferred equivalent call
end
local function release() -- 2 equivalent calls inferred from this helper
	flag = false
	v.firing = false
end

parent.Activated:Connect(press)
parent.Deactivated:Connect(release)

local function quickBegan(p, flag3: boolean)
	if flag3 or not gSet[p.KeyCode] or v9 then
		return
	end

	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid and not (humanoid.Health <= 0) and humanoid.SeatPart == nil and not (count2() <= 0) then -- inferred equivalent call
		if
			parent.Parent ~= character and parent.Parent ~= LocalPlayer:FindFirstChildOfClass("Backpack")
			or parent.Parent == character and v6 ~= "idle"
		then
			return
		end

		v9 = true
		flag2 = true

		if parent.Parent == character then
			v10 = nil
			v11 = false
		else
			local tool = character:FindFirstChildOfClass("Tool")

			if not tool or tool == parent then
				tool = nil
			end

			v10 = tool
			v11 = true
			humanoid:EquipTool(parent)
		end

		task.spawn(function()
			local lastTime2 = os.clock()

			while not v.active and os.clock() - lastTime2 < 0.5 do
				task.wait()
			end

			if v.active then
				press()

				if not v9 then
					release() -- inferred equivalent call
				end
			else
				flag2 = false
				v9 = false
				v11 = false
			end
		end)
	end
end
local function quickEnded(p)
	if gSet[p.KeyCode] then
		v9 = false

		if flag2 then
			release() -- inferred equivalent call
		end
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

TouchControls.register(parent, { label = "PLACE", startFire = press, stopFire = release })