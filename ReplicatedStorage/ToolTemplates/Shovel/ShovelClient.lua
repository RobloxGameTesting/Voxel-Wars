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
local StrikePredict = require(Voxel:WaitForChild("StrikePredict"))
local shovelDig = Voxel:WaitForChild("Remotes"):WaitForChild("ShovelDig")

local newVector3 = Vector3.new

local function handleAt(vector3: Vector3, vector3_2: Vector3)
	local x = math.rad(vector3_2.X)
	local y = math.rad(vector3_2.Y)
	local z = math.rad(vector3_2.Z)
	local cframe = CFrame.Angles(0, z, 0) * CFrame.Angles(0, 0, y)
	local vectorToWorldSpace = cframe:VectorToWorldSpace((newVector3(0, math.sin(x), -math.cos(x))))
	local vector = cframe:VectorToWorldSpace((newVector3(0, -math.cos(x), -math.sin(x))))
	return CFrame.fromMatrix(
		vector3 + vectorToWorldSpace * 1.95,
		vector:Cross(vectorToWorldSpace),
		vector,
		vectorToWorldSpace
	)
end

local hold = handleAt(Vector3.new(1.1, -0.9, -0.6), Vector3.new(-18, -15, 20))

local v = Viewmodel.new(parent, {
	name = "SHOVEL",
	hold = hold,
	rightHand = Vector3.new(0, -0.05, -1.95),
	leftHand = Vector3.new(0, -0.12, 0.7),
	armThickness = 0.6,
	muzzle = Vector3.new(0, 0, 3.2),
	aimPoint = Vector3.new(0, 0, 0),
	aimDistance = 2,
	aimFov = 80,
	aimMove = 1,
	reach = 1,
	sprintHold = handleAt(Vector3.new(1.3, -0.6, -0.3), Vector3.new(35, -25, 25)),
	hipKick = Vector3.new(0, 0, 0),
	hipKickRot = Vector3.new(0, 0, 0),
	aimKick = Vector3.new(0, 0, 0),
	aimKickRot = Vector3.new(0, 0, 0),
	recoilTime = 0.3,
	punch = 0
})

v.aimBlocked = true
v.leftWeight = 0

local lift = {
	length = 0.15,
	p = {
		{ 0, Vector3.new(1.1, -0.9, -0.6), true },
		{ 0.15, Vector3.new(1.2, -0.59999996, -0.20000002), true }
	},
	a = {
		{ 0, Vector3.new(-18, -15, 20), true },
		{ 0.15, Vector3.new(-8, -12, 18), true }
	}
}

local drive = {
	length = 0.09,
	p = {
		{ 0, Vector3.new(1.2, -0.59999996, -0.20000002), true },
		{ 0.09, Vector3.new(0.85, -1.25, -1.55), Vector3.new(-3.7333336, -6.933334, -14.399999) }
	},
	a = {
		{ 0, Vector3.new(-8, -12, 18), true },
		{ 0.09, Vector3.new(-34, -8, 12) }
	}
}

local scoop = {
	length = 0.48,
	p = {
		{ 0, Vector3.new(0.85, -1.25, -1.55), true },
		{ 0.05, Vector3.new(0.85, -1.3, -1.5999999), true },
		{ 0.155, Vector3.new(0.90000004, -1.7, -1.3) },
		{ 0.25, Vector3.new(1.6500001, -0.75, -0.5) },
		{ 0.31, Vector3.new(1.85, -0.84999996, -0.6) },
		{ 0.48, Vector3.new(1.1, -0.9, -0.6), true }
	},
	a = {
		{ 0, Vector3.new(-34, -8, 12), true },
		{ 0.05, Vector3.new(-36, -8, 12), true },
		{ 0.155, Vector3.new(-12, -10, 14) },
		{ 0.25, Vector3.new(-6, -30, -18) },
		{ 0.31, Vector3.new(-10, -95, -28) },
		{ 0.48, Vector3.new(-18, -15, 20), true }
	}
}

for _, v2 in { lift, drive, scoop } do
	v2.length *= 0.75

	for _, v3 in { v2.p, v2.a } do
		for _, v4 in v3 do
			v4[1] *= 0.75

			if typeof(v4[3]) == "Vector3" then
				v4[3] /= 0.75
			end
		end
	end
end

local v2 = "idle"
local lastTime = 0
local firing = false
local renderSteppedConnection = nil
local v3 = {
	lift = lift,
	drive = drive,
	scoop = scoop,
	through = {
		length = 0.4,
		p = {
			{ 0, Vector3.new(0.85, -1.25, -1.55), Vector3.new(-1.4933335, -2.7733335, -5.7599998) },
			{ 0.1, Vector3.new(0.8, -1.45, -1.8), true },
			{ 0.4, Vector3.new(1.1, -0.9, -0.6), true }
		},
		a = {
			{ 0, Vector3.new(-34, -8, 12) },
			{ 0.1, Vector3.new(-40, -8, 12), true },
			{ 0.4, Vector3.new(-18, -15, 20), true }
		}
	},
	jar = {
		length = 0.36,
		p = {
			{ 0, Vector3.new(0.85, -1.25, -1.55), true },
			{ 0.08, Vector3.new(0.90000004, -1.13, -1.3499999) },
			{ 0.36, Vector3.new(1.1, -0.9, -0.6), true }
		},
		a = {
			{ 0, Vector3.new(-34, -8, 12), true },
			{ 0.08, Vector3.new(-29, -8, 12) },
			{ 0.36, Vector3.new(-18, -15, 20), true }
		}
	}
}

local function enter(p: string) -- 6 equivalent calls inferred from this helper
	v2 = p
	lastTime = os.clock()
end

local function setPose(sample: Vector3, sample2: Vector3) -- 1 equivalent call inferred from this helper
	local v4 = handleAt(sample, sample2)
	v.pose = CFrame.new(v4.Position - hold.Position) * (hold.Rotation:Inverse() * v4.Rotation)
end

local function rest() -- 3 equivalent calls inferred from this helper
	v2 = "idle"
	v.pose = CFrame.identity
	v.firing = firing
end

local HttpService = game:GetService("HttpService")
local guid = HttpService:GenerateGUID(false)
local v4 = "ShovelDipUndo" .. guid
local v5 = "ShovelDip" .. guid
local lastTime2 = -1e999
local v6 = 0
local cframe = nil
local function gone(): boolean -- 2 equivalent calls inferred from this helper
	if parent:IsDescendantOf(game) then
		return false
	end

	RunService:UnbindFromRenderStep(v4)
	RunService:UnbindFromRenderStep(v5)
	return true
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
local function step2()
	if gone() then -- inferred equivalent call
		return
	end

	local v7 = (os.clock() - lastTime2) / 0.15

	if v7 >= 0 and v7 < 1 then
		local v8 = (1 - v7) * (1 - v7)
		cframe = CFrame.Angles(-math.rad(v6 * v8), 0, 0)
		local currentCamera = workspace.CurrentCamera

		if VR.on() then
			cframe = nil
		else
			currentCamera.CFrame *= cframe
		end
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
	RunService:BindToRenderStep(v4, Enum.RenderPriority.Camera.Value - 3, step1)
	RunService:BindToRenderStep(v5, Enum.RenderPriority.Camera.Value + 3, step2)
end
local function unbindSteps()
	v7 = false

	for _, v8 in { v4, v5 } do
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

local function dip(p: number) -- 3 equivalent calls inferred from this helper
	lastTime2 = os.clock()
	v6 = p
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local function contact(): nil | string
	local character = LocalPlayer.Character
	local currentCamera = workspace.CurrentCamera
	local v8 = { currentCamera }

	if character then
		table.insert(v8, character)
	end

	for _, childName in { "VoxelChips", "VoxelLoose", "VoxelTracers", "VoxelGrenades" } do
		local child = workspace:FindFirstChild(childName)

		if child then
			table.insert(v8, child)
		end
	end

	Viewmodel.setFilter(raycastParams, v8)
	local aimPoint = TouchControls.aimPoint()
	local ray = VR.ray(currentCamera, aimPoint.X, aimPoint.Y)
	local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 10, raycastParams)

	if not raycastResult then
		shovelDig:FireServer(nil, nil, ray.Direction)
		return nil
	end

	local instance = raycastResult.Instance
	local botRigs = workspace:FindFirstChild("BotRigs")
	local model = instance:FindFirstAncestorWhichIsA("Model")
	local v9 = botRigs ~= nil and instance:IsDescendantOf(botRigs)

	if not v9 then
		if model == nil then
			v9 = false
		else
			v9 = model:FindFirstChildOfClass("Humanoid") ~= nil
		end
	end

	if v9 then
		shovelDig:FireServer(nil, nil, ray.Direction)
		VoxelSound.bodyHit(raycastResult.Position, 1)
		return "body"
	elseif instance == workspace.Terrain and raycastResult.Material ~= Enum.Material.Water then
		shovelDig:FireServer(raycastResult.Position, raycastResult.Normal, ray.Direction)
		StrikePredict.strike(raycastResult.Position, raycastResult.Normal, ray.Direction, "Shovel", true)
		return "ground"
	else
		shovelDig:FireServer(nil, nil, ray.Direction)
		VoxelSound.click(raycastResult.Position, 1, 1)
		return "hard"
	end
end

local function play(p, p2: number) -- 1 equivalent call inferred from this helper
	setPose(Keyframes.sample(p.p, p2), Keyframes.sample(p.a, p2)) -- inferred equivalent call
end

local function step()
	local v8 = os.clock() - lastTime
	local v9 = v3[v2]

	if not v9 then
		return
	end

	play(v9, v8) -- inferred equivalent call

	if v8 < v9.length then
		return
	end

	if v2 == "lift" then
		enter("drive") -- inferred equivalent call
		VoxelSound.swing(workspace.CurrentCamera.CFrame.Position)
	elseif v2 == "drive" then
		local v10 = contact()

		if v10 == "ground" then
			enter("scoop") -- inferred equivalent call
			dip(1.2) -- inferred equivalent call
			v:bump(0.25)
		elseif v10 == "hard" then
			enter("jar") -- inferred equivalent call
			dip(1.8) -- inferred equivalent call
			v:bump(0.4)
		else
			enter("through") -- inferred equivalent call

			if v10 == "body" then
				dip(1) -- inferred equivalent call
			end
		end
	else
		rest() -- inferred equivalent call

		if firing and v.active then
			enter("lift") -- inferred equivalent call
		end
	end
end

local function start()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
	end

	firing = false
	rest() -- inferred equivalent call
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

	firing = false
	rest() -- inferred equivalent call
end

parent.Equipped:Connect(start)
parent.Unequipped:Connect(stop)

local function startFire()
	firing = true
	v.firing = true

	if v2 ~= "idle" then
		return
	end

	local lastTime3 = os.clock()

	while v.active and not v:ready() and os.clock() - lastTime3 < 0.5 do
		task.wait()
	end

	if v.active and v2 == "idle" and not Viewmodel.held() then
		enter("lift") -- inferred equivalent call
	end
end
local function stopFire() -- 1 equivalent call inferred from this helper
	firing = false
	v.firing = false
end

parent.Activated:Connect(startFire)
parent.Deactivated:Connect(stopFire)

parent:GetAttributeChangedSignal("QuickSwing"):Connect(function()
	if parent:GetAttribute("QuickSwing") == nil then
		return
	end

	task.spawn(function()
		local lastTime3 = os.clock()

		while not (v.active and v:ready()) and os.clock() - lastTime3 < 1.5 do
			task.wait()
		end

		startFire()
		stopFire() -- inferred equivalent call
		local lastTime4 = os.clock()

		while v.active and v2 ~= "idle" and os.clock() - lastTime4 < 2.5 do
			task.wait()
		end

		parent:SetAttribute("QuickSwing", nil)
		parent:SetAttribute("QuickDone", os.clock())
	end)
end)

TouchControls.register(parent, { label = "DIG", startFire = startFire, stopFire = stopFire })