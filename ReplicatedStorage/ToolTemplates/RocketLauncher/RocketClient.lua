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
local Keyframes = require(Voxel:WaitForChild("Keyframes"))
local VoxelSound = require(Voxel:WaitForChild("VoxelSound"))
local TouchControls = require(Voxel:WaitForChild("TouchControls"))
local RocketPredict = require(Voxel:WaitForChild("RocketPredict"))
local Remotes = Voxel:WaitForChild("Remotes")
local FireRocket = Remotes:WaitForChild("FireRocket")
local ReloadRocket = Remotes:WaitForChild("ReloadRocket")

local function reloadScale() -- 1 equivalent call inferred from this helper
	local reloadScale2 = parent:GetAttribute("ReloadScale")
	return if type(reloadScale2) == "number" then reloadScale2 else 1
end

local v = Viewmodel.new(parent, {
	name = "RPG",
	weight = 1.4,
	hold = CFrame.new(1.3, -1.6, -2.3) * CFrame.Angles(0.05235987755982989, 0.10471975511965978, 0),
	rightHand = Vector3.new(0, -0.82, 0.28),
	leftHand = Vector3.new(0, -0.68, -1.4),
	muzzle = muzzleAttachment.Position,
	aimPoint = Vector3.new(0, 0.86, 0.35),
	aimDistance = 1.5,
	aimFov = 52,
	aimMove = 0.55,
	reach = 5.4,
	sprintHold = CFrame.new(0.9, -2, -1.9) * CFrame.Angles(-0.20943951023931956, 1.0821041362364843, 0.3141592653589793),
	hipKick = Vector3.new(0.1, 0.06, 1.2),
	hipKickRot = Vector3.new(5, 3, 12),
	aimKick = Vector3.new(0.06, 0.04, 0.9),
	aimKickRot = Vector3.new(4, 2, 8),
	recoilTime = 0.4,
	punch = 6
})

local newVector3 = Vector3.new

local v2 = {
	{ 0, Vector3.new(0, 0, 0) },
	{ 0.1, Vector3.new(0, -0.04, 0) },
	{ 0.38, Vector3.new(-0.47249997, 0.36749998, 0.2625) },
	{ 0.5, Vector3.new(-0.45, 0.35, 0.25) },
	{ 0.8, Vector3.new(-0.41, 0.29999998, 0.25) },
	{ 0.98, Vector3.new(-0.42, 0.37, 0.25) },
	{ 1.24, Vector3.new(-0.39999998, 0.47, 0.15) },
	{ 1.3, Vector3.new(-0.39999998, 0.47, 0.15), true },
	{ 1.35, Vector3.new(-0.45, 0.28, 0.32) },
	{ 1.43, Vector3.new(-0.3825, 0.2775, 0.2125) },
	{ 1.62, Vector3.new(0, -0.04, 0) },
	{ 1.75, Vector3.new(0, 0, 0), true }
}

local v3 = {
	{ 0, Vector3.new(0, 0, 0) },
	{ 0.1, Vector3.new(-3, 0, 2) },
	{ 0.38, Vector3.new(16.8, 27.3, -25.199999) },
	{ 0.5, Vector3.new(16, 26, -24) },
	{ 0.8, Vector3.new(18, 29, -24) },
	{ 0.98, Vector3.new(16, 27, -24) },
	{ 1.24, Vector3.new(12, 23, -24) },
	{ 1.3, Vector3.new(12, 23, -24), true },
	{ 1.35, Vector3.new(11, 26, -23) },
	{ 1.43, Vector3.new(12.8, 20.800001, -19.2) },
	{ 1.62, Vector3.new(-2, 0, 2) },
	{ 1.75, Vector3.new(0, 0, 0), true }
}

local v4 = {
	{ 0, 0 },
	{ 0.15, 0.1 },
	{ 0.35, 1, true },
	{ 1.36, 1, true },
	{ 1.62, 0, true }
}
local v5 = {
	{ 0, 0 },
	{ 0.42, 0, true },
	{ 0.52, 1, true }
}

local v6 = {
	{ 0.45, Vector3.new(-0.9, -1.7, -0.2) },
	{ 0.7, Vector3.new(-0.3, -0.45, -1.2) },
	{ 0.92, Vector3.new(0, 0, -1.8) },
	{ 1, Vector3.new(0, 0, -1.65) },
	{ 1.22, Vector3.new(0, 0, -0.35) },
	{ 1.3, Vector3.new(0, 0, 0), true }
}

local v7 = {
	{ 0.45, Vector3.new(40, -25, 15) },
	{ 0.7, Vector3.new(12, -8, 5) },
	{ 0.92, Vector3.new(0, 0, 0), true }
}

local function sample(p: number, p2: number)
	v.pose = CFrame.identity:Lerp(Keyframes.pose(Keyframes.sample(v2, p), Keyframes.sample(v3, p)), p2)
	v.leftWeight = Keyframes.sample(v4, p) * p2
	v.leftTarget = Vector3.new(-1.3, -2.8, -2.4)
	v.leftOnAmmo = Keyframes.sample(v5, p)
	v.ammoGrab = Vector3.new(-0.22, -0.1, -1.5)
	v.ammoVisible = p >= 0.45
	v.ammoDelta = CFrame.new(Vector3.new(0, 0, -1.7)) * Keyframes.pose(Keyframes.sample(v6, p), Keyframes.sample(v7, p)) * CFrame.new(Vector3.new(-0, -0, 1.7))
	local reloadProgress

	if p < 1.3 then
		reloadProgress = p / 1.3
	end

	v.reloadProgress = reloadProgress
end

local v8 = false
local flag = false
local v9 = 0
local renderSteppedConnection = nil

local function spare() -- 3 equivalent calls inferred from this helper
	local reserve = parent:GetAttribute("Reserve")
	return if type(reserve) == "number" then reserve else 0
end

local function refreshAmmo() -- 2 equivalent calls inferred from this helper
	local v10 = parent:GetAttribute("Loaded") and 1 or 0
	v:setAmmo(v10, spare()) -- inferred equivalent call

	if not flag then
		v.ammoVisible = v10 > 0
	end
end
parent:GetAttributeChangedSignal("Loaded"):Connect(refreshAmmo)
parent:GetAttributeChangedSignal("Reserve"):Connect(refreshAmmo)

local function endReload() -- 2 equivalent calls inferred from this helper
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	v8 = false
	flag = false
	v9 = 0
	v.aimBlocked = false
	v.pose = CFrame.identity
	v.leftWeight = 0
	v.leftOnAmmo = 0
	v.ammoDelta = CFrame.identity
	v.reloadProgress = nil
	refreshAmmo() -- inferred equivalent call
end

local function startReload()
	if not flag and v.active and not parent:GetAttribute("Loaded") and not (spare() <= 0) then -- inferred equivalent call
		v8 = true
		flag = true
		v9 = 1
		v.aimBlocked = true
		ReloadRocket:FireServer()
		local now = os.clock()
		local v10 = { 0.2, 0.92, 1.3 }
		local v11 = 1
		local v12 = nil
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			local now2 = os.clock()
			local v13 = (now2 - now) / reloadScale() -- inferred equivalent call

			if v8 and v13 >= 1.3 then
				v8 = false
				v.aimBlocked = false
			end

			if not v8 and not v12 and (v.firing or v.aiming) then
				v12 = now2
			end

			v9 = not v12 and 1 or 1 - (now2 - v12) / 0.12
			local v14 = v10[v11]

			if v14 and v14 <= v13 then
				local position = workspace.CurrentCamera.CFrame.Position

				if v11 == 1 then
					VoxelSound.swing(position)
				elseif v11 == 2 then
					VoxelSound.click(position, 0.5, 0.5)
				else
					VoxelSound.click(position, 1, 1)
				end

				v11 += 1
			end

			if not (v9 <= 0 or v13 >= 1.75) then
				sample(math.min(v13, 1.75), v9)
				return
			end

			endReload() -- inferred equivalent call
			v.ammoVisible = true
		end)
	end
end

parent:GetAttributeChangedSignal("Reserve"):Connect(function()
	if v.active and not parent:GetAttribute("Loaded") and spare() > 0 then -- inferred equivalent call
		startReload()
	end
end)

parent.Equipped:Connect(function()
	refreshAmmo() -- inferred equivalent call

	if not parent:GetAttribute("Loaded") then
		task.delay(0.4, startReload)
	end
end)
parent.Unequipped:Connect(function()
	if flag then
		endReload() -- inferred equivalent call
	end
end)

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local v10 = false

local function fire()
	local character = LocalPlayer.Character

	if not character or v8 or v10 or not parent:GetAttribute("Loaded") then
		return
	end

	v10 = true
	local voxelChips = workspace:FindFirstChild("VoxelChips")
	local v11 = voxelChips and { character, voxelChips } or { character }
	Viewmodel.setFilter(raycastParams, v11)
	local currentCamera = workspace.CurrentCamera
	local v12 = currentCamera.ViewportSize * 0.5
	local ray = VR.ray(currentCamera, v12.X, v12.Y)

	local head = character:FindFirstChild("Head")
	local v13 = not head and 0 or math.max((head.Position - ray.Origin):Dot(ray.Direction), 0)
	local v14 = ray.Origin + ray.Direction * v13
	local v15

	if v.active then
		v15 = v:muzzle(v11)
	else
		v15 = muzzleAttachment.WorldPosition
	end

	RocketPredict.fire(v14, ray.Direction.Unit, v15)
	FireRocket:FireServer(v14, ray.Direction.Unit, v15)
	v:fired()
	v.ammoVisible = false
	v:setAmmo(0)
	task.delay(0.25, function()
		local lastTime = os.clock()

		while parent:GetAttribute("Loaded") and os.clock() - lastTime < 1 do
			task.wait()
		end

		v10 = false
		startReload()
	end)
end

local function startFire()
	if v.firing then
		return
	end

	v.firing = true
	local lastTime = os.clock()

	while v.active and not (v:ready() and v9 <= 0.3) and os.clock() - lastTime < 0.5 do
		task.wait()
	end

	if v:ready() and v9 <= 0.3 then
		fire()
	end
end
local function stopFire()
	v.firing = false
end
local function setAim(aiming: boolean) -- 2 equivalent calls inferred from this helper
	if aiming and not v.active then
		return
	end

	v.aiming = aiming
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
	if not v.active then
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
	assist = true,
	startFire = startFire,
	stopFire = stopFire,
	setAim = setAim,
	isAiming = function()
		return v.aiming
	end,
	reload = startReload
})