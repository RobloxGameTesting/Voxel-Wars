local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local parent = script.Parent
local muzzleAttachment = parent:WaitForChild("Handle"):WaitForChild("MuzzleAttachment")
local LocalPlayer = Players.LocalPlayer
local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local Vehicles = ReplicatedStorage:WaitForChild("Vehicles")
local Viewmodel = require(Voxel:WaitForChild("Viewmodel"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local VR = require(ReplicatedStorage2:WaitForChild("Voxel"):WaitForChild("VR"))
local Keyframes = require(Voxel:WaitForChild("Keyframes"))
local VoxelSound = require(Voxel:WaitForChild("VoxelSound"))
local TouchControls = require(Voxel:WaitForChild("TouchControls"))
local AirDefense = require(Vehicles:WaitForChild("AirDefense"))
local VehicleConfig = require(Vehicles:WaitForChild("VehicleConfig"))
local Remotes = Voxel:WaitForChild("Remotes")
local FireAA = Remotes:WaitForChild("FireAA")
local ReloadAA = Remotes:WaitForChild("ReloadAA")
local AATrack = Remotes:WaitForChild("AATrack")
local aaOrdnance = Vehicles:WaitForChild("Remotes"):WaitForChild("AAOrdnance")

local function onTouch()
	return UserInputService.TouchEnabled
		and not UserInputService.KeyboardEnabled
		and UserInputService:GetLastInputType() == Enum.UserInputType.Touch
end

local color = Color3.fromRGB(255, 196, 70)
local color2 = Color3.fromRGB(255, 64, 48)
local rbxassetfontsfamiliesOswaldjson = Font.new("rbxasset://fonts/families/Oswald.json", Enum.FontWeight.Bold)
local newVector3 = Vector3.new

local v = Viewmodel.new(parent, {
	name = "ANTI-AIR LAUNCHER",
	weight = 1.6,
	aimTime = 0.38,
	hold = CFrame.new(0.4, -1.7, -2.35) * CFrame.Angles(-0.29670597283903605, 0, -0.2792526803190927),
	rightHand = Vector3.new(0, -0.82, 0.28),
	leftHand = Vector3.new(0, -0.3, -1.25),
	muzzle = muzzleAttachment.Position,
	aimPoint = Vector3.new(-0.36, 0.5, 1.35),
	aimDistance = 0.9,
	aimFov = AirDefense.FOV,
	aimMove = 0.55,
	aimSensitivity = 0.9,
	scopeHide = 0.9,
	scopeShow = 0.6,
	reach = 5.4,
	sprintHold = CFrame.new(0.9, -2, -1.9) * CFrame.Angles(-0.20943951023931956, 1.0821041362364843, 0.3141592653589793),
	hipKick = Vector3.new(0.08, 0.05, 0.9),
	hipKickRot = Vector3.new(4, 2, 8),
	aimKick = Vector3.new(0.04, 0.03, 0.6),
	aimKickRot = Vector3.new(3, 2, 5),
	recoilTime = 0.45,
	punch = 4
})

local reload = AirDefense.RELOAD
local v2 = reload - 0.45

local v3 = {
	{ 0, Vector3.new(0, 0, 0) },
	{ 0.45, Vector3.new(-0.5, -0.1, 0.2) },
	{ v2 - 0.25, Vector3.new(-0.47, -0.08, 0.2) },
	{ v2, Vector3.new(-0.45, 0, 0.1), true },
	{ v2 + 0.1, Vector3.new(-0.5, -0.17, 0.27) },
	{ reload, Vector3.new(0, 0, 0), true }
}
local v4 = {
	{ 0, Vector3.new(0, 0, 0) },
	{ 0.45, Vector3.new(-14, 30, -30) },
	{ v2 - 0.25, Vector3.new(-12, 32, -30) },
	{ v2, Vector3.new(-17, 28, -30), true },
	{ v2 + 0.1, Vector3.new(-19, 30, -29) },
	{ reload, Vector3.new(0, 0, 0), true }
}
local v5 = {
	{ 0, 0 },
	{ 0.15, 0.1 },
	{ 0.4, 1, true },
	{ v2 - 0.5, 1, true },
	{ v2 - 0.2, 0, true },
	{ reload, 0 }
}

local v6 = false
local flag = false
local v7 = 0
local renderSteppedConnection = nil

local function spare() -- 3 equivalent calls inferred from this helper
	local reserve = parent:GetAttribute("Reserve")
	return if type(reserve) == "number" then reserve else 0
end

local function refreshAmmo() -- 2 equivalent calls inferred from this helper
	v:setAmmo(parent:GetAttribute("Loaded") and 1 or 0, spare()) -- inferred equivalent call
end
parent:GetAttributeChangedSignal("Loaded"):Connect(refreshAmmo)
parent:GetAttributeChangedSignal("Reserve"):Connect(refreshAmmo)

local function endReload() -- 2 equivalent calls inferred from this helper
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	v6 = false
	flag = false
	v7 = 0
	v.aimBlocked = false
	v.pose = CFrame.identity
	v.leftWeight = 0
	v.reloadProgress = nil
	refreshAmmo() -- inferred equivalent call
end

local function startReload()
	if not flag and v.active and not parent:GetAttribute("Loaded") and not (spare() <= 0) then -- inferred equivalent call
		v6 = true
		flag = true
		v7 = 1
		v.aimBlocked = true
		ReloadAA:FireServer()
		local lastTime = os.clock()
		local v8 = { 0.2, v2 - 0.3, v2 }
		local v9 = 1
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			local v10 = os.clock() - lastTime

			if v6 and v2 <= v10 then
				v6 = false
			end

			local v11 = v8[v9]

			if v11 and v11 <= v10 then
				local position = workspace.CurrentCamera.CFrame.Position

				if v9 == 1 then
					VoxelSound.swing(position)
				else
					VoxelSound.click(position, v9 == 2 and 0.5 or 1, v9 == 2 and 0.5 or 1)
				end

				v9 += 1
			end

			if reload <= v10 then
				endReload() -- inferred equivalent call
			else
				v.pose = Keyframes.pose(Keyframes.sample(v3, v10), Keyframes.sample(v4, v10))
				v.leftWeight = Keyframes.sample(v5, v10)
				v.leftTarget = Vector3.new(-1.2, -2.8, -2.4)
				local reloadProgress

				if v10 < v2 then
					reloadProgress = v10 / v2
				end

				v.reloadProgress = reloadProgress
			end
		end)
	end
end

parent:GetAttributeChangedSignal("Reserve"):Connect(function()
	if v.active and not parent:GetAttribute("Loaded") and spare() > 0 then -- inferred equivalent call
		startReload()
	end
end)

local function screen(name: string, displayOrder: number) -- 2 equivalent calls inferred from this helper
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = name
	screenGui.ResetOnSpawn = false
	screenGui.ScreenInsets = Enum.ScreenInsets.None
	screenGui.DisplayOrder = displayOrder
	screenGui.Enabled = false
	screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	v:ownGui(screenGui)
	return screenGui
end

local parent3 = screen("AASight", 0) -- inferred equivalent call
local v8 = {}

local function round(parent2, p: number)
	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromScale(0.5, 0.5)
	frame.Size = UDim2.fromScale(p, p)
	frame.SizeConstraint = Enum.SizeConstraint.RelativeYY
	frame.BackgroundTransparency = 1
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0.5, 0)
	uiCorner.Parent = frame
	frame.Parent = parent2
	return frame
end

local function ringOf(p: number, thickness: number, color3: Color3, transparency: number)
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = thickness
	uiStroke.Color = color3
	uiStroke.Transparency = transparency
	uiStroke.Parent = round(parent3, p)
	table.insert(v8, { s = uiStroke, t = transparency })
	return uiStroke
end

local v9 = ringOf(0.98, 3000, Color3.fromRGB(4, 6, 8), 0)
ringOf(0.955, 8, Color3.new(0, 0, 0), 0.25)
ringOf(0.925, 12, Color3.new(0, 0, 0), 0.6)
ringOf(0.88, 16, Color3.new(0, 0, 0), 0.82)
ringOf(0.528, 2, Color3.new(0, 0, 0), 0)

for i = 0, 3 do
	local v10 = i * 3.141592653589793 / 2
	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromScale(0.5, 0.5) + UDim2.new(math.sin(v10) * 0.264 * 9 / 16, 0, -math.cos(v10) * 0.264, 0)
	local size

	if i % 2 == 0 then
		size = UDim2.fromOffset(2, 12)
	else
		size = UDim2.fromOffset(12, 2)
	end

	frame.Size = size
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BorderSizePixel = 0
	frame.Parent = parent3
end

local function placeTicks()
	local viewportSize = workspace.CurrentCamera.ViewportSize
	local count = 0

	for _, frame in parent3:GetChildren() do
		if not frame:IsA("Frame") or frame:FindFirstChildOfClass("UIStroke") then
			continue
		end

		local v10 = count * 3.141592653589793 / 2
		frame.Position = UDim2.new(0.5, 0, 0.5, 0) + UDim2.fromOffset(
			math.sin(v10) * 0.264 * viewportSize.Y,
			-math.cos(v10) * 0.264 * viewportSize.Y
		)
		count += 1
	end

	v9.Thickness = math.max(viewportSize.X, viewportSize.Y)
end

local v10 = -1
local function showSight(p: number)
	if p == v10 then
		return
	end

	v10 = p
	parent3.Enabled = p > 0

	if p > 0 then
		for _, v11 in v8 do
			v11.s.Transparency = 1 - (1 - v11.t) * p
		end
	end
end

local parent2 = screen("AALock", 3) -- inferred equivalent call
local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Size = UDim2.fromOffset(38, 38)
frame.BackgroundTransparency = 1
frame.Parent = parent2

local function bar(size: UDim2, udim: UDim2, vector2: Vector2) -- 2 equivalent calls inferred from this helper
	local frame2 = Instance.new("Frame")
	frame2.BorderSizePixel = 0
	frame2.Size = size
	frame2.Position = udim
	frame2.AnchorPoint = vector2
	frame2.Parent = frame
	return frame2
end

local v11 = {}

for _, v12 in {
	{ 0, 0 },
	{ 1, 0 },
	{ 0, 1 },
	{ 1, 1 }
} do
	local vector2 = Vector2.new(v12[1], v12[2])
	local udim = UDim2.fromScale(v12[1], v12[2])
	table.insert(v11, bar(UDim2.fromOffset(9, 2), udim, vector2)) -- inferred equivalent call
	table.insert(v11, bar(UDim2.fromOffset(2, 9), udim, vector2)) -- inferred equivalent call
end

local frame2 = Instance.new("Frame")
frame2.AnchorPoint = Vector2.new(0.5, 0.5)
frame2.Position = UDim2.fromScale(0.5, 0.5)
frame2.Size = UDim2.fromOffset(18, 18)
frame2.Rotation = 45
frame2.BackgroundTransparency = 1
frame2.Parent = frame
local uiStroke = Instance.new("UIStroke")
uiStroke.Thickness = 2
uiStroke.Parent = frame2

local frame3 = Instance.new("Frame")
frame3.AnchorPoint = Vector2.new(0.5, 0.5)
frame3.Position = UDim2.fromScale(0.5, 0.5)
frame3.Size = UDim2.fromOffset(28, 28)
frame3.BackgroundTransparency = 1
frame3.Parent = frame
local uiStroke2 = Instance.new("UIStroke")
uiStroke2.Thickness = 2
uiStroke2.Color = color2
uiStroke2.Parent = frame3

for _, rotation in { 45, -45 } do
	local frame4 = Instance.new("Frame")
	frame4.AnchorPoint = Vector2.new(0.5, 0.5)
	frame4.Position = UDim2.fromScale(0.5, 0.5)
	frame4.Size = UDim2.fromOffset(36, 2)
	frame4.Rotation = rotation
	frame4.BackgroundColor3 = color2
	frame4.BorderSizePixel = 0
	frame4.Parent = frame3
end

local function caption(p: number, p2: number, textSize: number)
	local textLabel = Instance.new("TextLabel")
	textLabel.AnchorPoint = Vector2.new(0.5, p2)
	textLabel.Position = UDim2.new(0.5, 0, p, 0)
	textLabel.Size = UDim2.fromOffset(140, textSize + 4)
	textLabel.BackgroundTransparency = 1
	textLabel.FontFace = rbxassetfontsfamiliesOswaldjson
	textLabel.TextSize = textSize
	textLabel.TextStrokeTransparency = 0.5
	textLabel.Parent = frame
	return textLabel
end

local v12 = caption(-0.12, 1, 16)
local v13 = caption(1.12, 0, 14)
v13.TextColor3 = Color3.new(1, 1, 1)

local v14 = nil
local v15 = 0
local v16 = 0
local v17 = nil
local v18 = nil
local v19 = 0
local v20 = nil

local function flying(data, _: number): boolean
	if data.wrecked or not data.running then
		return false
	end

	local team = data.folder:GetAttribute("Team")

	if team == "" or team == nil or LocalPlayer.Team and team == LocalPlayer.Team.Name then
		return false
	end

	local flareUntil = data.folder:GetAttribute("FlareUntil")
	return type(flareUntil) ~= "number" or not (workspace:GetServerTimeNow() < flareUntil)
end

local function angleTo(vector3: Vector3, vector3_2: Vector3, position: Vector3) -- 2 equivalent calls inferred from this helper
	local v21 = position - vector3_2
	return math.acos((math.clamp(v21.Unit:Dot(vector3), -1, 1))), v21.Magnitude
end

local function setLock(p) -- 5 equivalent calls inferred from this helper
	if v14 and not p then
		AATrack:FireServer(0)
		VoxelSound.aaTone(false)
	end

	v14 = p
end

local function known(p): boolean -- 2 equivalent calls inferred from this helper
	return AirDefense.list[p.id] == p or AirDefense.ground[p.id] == p
end

local function candidate(position: Vector3, lookVector: Vector3, lastIn: number)
	local v21 = AirDefense.CONE * (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and UserInputService:GetLastInputType() == Enum.UserInputType.Touch and 1.4 or 1)
	local v22 = nil

	for _, v23 in { AirDefense.list, AirDefense.ground } do
		for _, v24 in v23 do
			if not flying(v24, lastIn) then
				continue
			end

			local v25, v26 = angleTo(lookVector, position, v24.cf.Position) -- inferred equivalent call

			if not (v25 < v21 and v26 < AirDefense.RANGE) then
				continue
			end

			v22 = v24
			v21 = v25
		end
	end

	return v22
end

local function stepLock(p: number, now: number)
	local currentCamera = workspace.CurrentCamera
	local position = currentCamera.CFrame.Position
	local lookVector = currentCamera.CFrame.LookVector
	local v21 = v.active

	if v21 then
		if v.aimAlpha >= 0.55 then
			v21 = not v6 and parent:GetAttribute("Loaded") == true
		else
			v21 = false
		end
	end

	local v22 = v21 and not v14 and candidate(position, lookVector, now)

	if v22 then
		setLock({ h = v22, t = 0, locked = false, lastIn = now }) -- inferred equivalent call
	end

	local v23 = v14

	if v23 then
		local h = v23.h

		if known(h) and flying(h, now) then -- inferred equivalent call
			local v24, v25 = angleTo(lookVector, position, h.cf.Position) -- inferred equivalent call
			local v26 = UserInputService.TouchEnabled
				and not UserInputService.KeyboardEnabled
				and UserInputService:GetLastInputType() == Enum.UserInputType.Touch

			if v21 then
				if v24 < AirDefense.CONE * (v26 and 1.4 or 1) and v25 < AirDefense.RANGE then
					v21 = parent:GetAttribute("AABlocked") ~= true
				else
					v21 = false
				end
			end

			if v21 then
				v23.lastIn = now

				if not v23.locked then
					v23.t += p

					if v23.t >= AirDefense.LOCK_TIME then
						v23.locked = true
						VoxelSound.aaTone(true)
					end
				end
			else
				local v27 = now - v23.lastIn
				local v28

				if v23.locked then
					v28 = AirDefense.RELEASE
				else
					v28 = v26 and 0.9 or AirDefense.UNLOCK
				end

				if v28 < v27 then
					setLock(nil) -- inferred equivalent call
					return
				end
			end

			if now - v15 >= AirDefense.SEND then
				v15 = now
				AATrack:FireServer(h.id, lookVector)
			end

			if not v23.locked and v21 and v16 <= now then
				v16 = now + 0.34 - math.min(v23.t / AirDefense.LOCK_TIME, 1) * 0.2
				VoxelSound.aaBeep(0.7, 0.5)
			end
		else
			setLock(nil) -- inferred equivalent call
		end
	end
end

local function drawMark(now: number)
	local currentCamera = workspace.CurrentCamera
	local v21 = v14
	local v22

	if v21 then
		v22 = v21.h
	elseif v18 and known(v18) then -- inferred equivalent call
		v22 = v18
	end

	local v23

	if v22 then
		v23 = v22.cf.Position
	end

	local v24 = now < v19

	if v24 then
		v23 = v20
	end

	local v25

	if v23 then
		v25 = currentCamera:WorldToViewportPoint(v23)
	end

	if not v23 or not v25 or v25.Z <= 0 then
		frame.Visible = false
		return
	end

	frame.Visible = true
	frame.Position = UDim2.fromOffset(math.floor(v25.X), (math.floor(v25.Y)))
	local v26 = v21 and v21.locked

	if not v26 then
		v26 = not v21

		if v26 then
			if v22 == v18 then
				v26 = v22 ~= nil
			else
				v26 = false
			end
		end
	end

	local v27 = if v26 or v24 then color2 else color
	frame3.Visible = v26 and not v24
	frame2.Visible = not (v26 or v24)
	uiStroke.Color = v27

	for _, v28 in v11 do
		v28.BackgroundColor3 = v27
		v28.Visible = not v26
	end

	v12.Text = v24 and "MISSED" or v26 and "LOCKED ON" or "LOCKING"
	v12.TextColor3 = v27
	v13.Text = string.format("%d m", (v23 - currentCamera.CFrame.Position).Magnitude / VehicleConfig.UNIT)
end

local renderSteppedConnection2 = nil
local function start() -- 1 equivalent call inferred from this helper
	if renderSteppedConnection2 then
		return
	end

	placeTicks()
	parent2.Enabled = true
	local v21 = os.clock()
	renderSteppedConnection2 = RunService.RenderStepped:Connect(function()
		local now = os.clock()
		local v22 = math.min(now - v21, 0.1)
		v21 = now
		showSight(not v.active and 0 or math.clamp((v.aimAlpha - 0.55) / 0.35, 0, 1))
		stepLock(v22, now)
		drawMark(now)
	end)
end
local function stop() -- 1 equivalent call inferred from this helper
	if renderSteppedConnection2 then
		renderSteppedConnection2:Disconnect()
		renderSteppedConnection2 = nil
	end

	if v10 ~= 0 then
		v10 = 0
		parent3.Enabled = false
	end

	parent2.Enabled = false
	setLock(nil) -- inferred equivalent call
	VoxelSound.aaTone(false)
end

parent.Equipped:Connect(function()
	refreshAmmo() -- inferred equivalent call
	start() -- inferred equivalent call

	if not parent:GetAttribute("Loaded") then
		task.delay(0.4, startReload)
	end
end)
parent.Unequipped:Connect(function()
	stop() -- inferred equivalent call

	if flag then
		endReload() -- inferred equivalent call
	end
end)

aaOrdnance.OnClientEvent:Connect(function(p: string, p2, p3, _, p4)
	if p == "missile" and p4 == LocalPlayer then
		v17 = p2
	elseif (p == "gone" or p == "pop") and p2 == v17 then
		if p == "pop" and v18 then
			v19 = os.clock() + 1.5
			v20 = p3
		end

		if p == "gone" then
			task.defer(function()
				if p2 == v17 then
					v17 = nil
					v18 = nil
				end
			end)
		end
	end
end)

local v21 = false

local function fire()
	local character = LocalPlayer.Character

	if not character or v6 or v21 or not parent:GetAttribute("Loaded") then
		return
	end

	local v22 = v14
	local h

	if v22 and v22.locked then
		h = v22.h
	end

	v21 = true
	local currentCamera = workspace.CurrentCamera
	local v23 = currentCamera.ViewportSize * 0.5
	local ray = VR.ray(currentCamera, v23.X, v23.Y)
	local head = character:FindFirstChild("Head")
	local v24 = not head and 0 or math.max((head.Position - ray.Origin):Dot(ray.Direction), 0)
	local v25 = ray.Origin + ray.Direction * v24
	local unit = ray.Direction.Unit
	local voxelChips = workspace:FindFirstChild("VoxelChips")
	local v26 = voxelChips and { character, voxelChips } or { character }
	local v27

	if v.active and v.aimAlpha < 0.9 then
		v27 = v:muzzle(v26)
	else
		v27 = v25 + unit * 3
	end

	v18 = h
	AirDefense.fire(v25, unit, v27)
	FireAA:FireServer(not h and 0 or h.id, v25, unit, v27)
	v:fired()
	v:setAmmo(0)
	setLock(nil) -- inferred equivalent call
	task.delay(0.45, function()
		local lastTime = os.clock()

		while parent:GetAttribute("Loaded") and os.clock() - lastTime < 1 do
			task.wait()
		end

		v21 = false
		startReload()
	end)
end

local function startFire()
	if v.firing then
		return
	end

	v.firing = true
	local lastTime = os.clock()

	while v.active and not v:ready() and os.clock() - lastTime < 0.5 do
		task.wait()
	end

	if v:ready() then
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

local connections = {}
local function bind()
	if #connections > 0 then
		return
	end

	table.insert(connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not v.active then
			return
		end

		local ReplicatedStorage3 = game:GetService("ReplicatedStorage")

		if require(ReplicatedStorage3:WaitForChild("Voxel"):WaitForChild("AimKey")).began(input, gameProcessed) then
			setAim(true) -- inferred equivalent call
		elseif input.KeyCode == Enum.KeyCode.R and not gameProcessed then
			startReload()
		end
	end))
	table.insert(connections, UserInputService.InputEnded:Connect(function(input)
		local ReplicatedStorage3 = game:GetService("ReplicatedStorage")

		if require(ReplicatedStorage3:WaitForChild("Voxel"):WaitForChild("AimKey")).ended(input) then
			setAim(false) -- inferred equivalent call
		end
	end))
end
parent.Equipped:Connect(bind)
parent.Unequipped:Connect(function()
	for _, connection in connections do
		connection:Disconnect()
	end

	table.clear(connections)
end)

if parent.Parent ~= nil and parent.Parent == LocalPlayer.Character then
	bind()
end

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