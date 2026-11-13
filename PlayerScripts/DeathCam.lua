local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local Movement = require(Voxel:WaitForChild("Movement"))
local WorldConfig = require(Voxel:WaitForChild("WorldConfig"))
local Style = require(script.Parent:WaitForChild("GameUI"):WaitForChild("Style"))
local died = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Remotes"):WaitForChild("Died")
local v = nil
task.spawn(function()
	local Viewmodel = require(Voxel:WaitForChild("Viewmodel"))
	v = Viewmodel
end)
local flag = false

local color = Color3.fromRGB(226, 52, 40)

local deathGrade = Instance.new("ColorCorrectionEffect")
deathGrade.Name = "DeathGrade"
deathGrade.Enabled = false
deathGrade.Parent = Lighting

local v2 = nil
local killerName2 = nil
local v3 = -1e999

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local v4 = { "VoxelChips", "VoxelLoose", "VoxelTracers", "VoxelGrenades", "BotRigs" }
local excludeInstances2 = {}
local v5 = {}
local v6 = -1

local function smooth(value: number) -- 5 equivalent calls inferred from this helper
	local v7 = math.clamp(value, 0, 1)
	return v7 * v7 * (3 - v7 * 2)
end

local function centre(instance) -- 3 equivalent calls inferred from this helper
	local upperTorso = instance:FindFirstChild("UpperTorso")
		or instance:FindFirstChild("HumanoidRootPart")
		or instance.PrimaryPart

	if upperTorso and upperTorso:IsA("BasePart") then
		return upperTorso.Position
	end

	return instance:GetPivot().Position
end

local function findKiller(killerName: string)
	local player = Players:FindFirstChild(killerName)

	if player and player:IsA("Player") then
		return player.Character
	end

	local botRigs = workspace:FindFirstChild("BotRigs")
	local model = botRigs and botRigs:FindFirstChild(killerName)
	return if model and model:IsA("Model") then model else nil
end

local function markKiller(p, adornee)
	local deathCamKiller = Instance.new("Highlight")
	deathCamKiller.Name = "DeathCamKiller"
	deathCamKiller.Adornee = adornee
	deathCamKiller.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	deathCamKiller.FillColor = color
	deathCamKiller.FillTransparency = 1
	deathCamKiller.OutlineColor = color
	deathCamKiller.OutlineTransparency = 1
	deathCamKiller.Parent = workspace.CurrentCamera
	p.highlight = deathCamKiller

	local head = adornee:FindFirstChild("Head") or adornee:FindFirstChild("HumanoidRootPart") or adornee.PrimaryPart
	local deathCamMarker = Instance.new("BillboardGui")
	deathCamMarker.Name = "DeathCamMarker"

	if not (head and head:IsA("BasePart")) then
		head = nil
	end

	deathCamMarker.Adornee = head
	deathCamMarker.AlwaysOnTop = true
	deathCamMarker.LightInfluence = 0
	deathCamMarker.Size = UDim2.fromOffset(180, 46)
	deathCamMarker.StudsOffsetWorldSpace = Vector3.new(0, 2.4, 0)
	deathCamMarker.Parent = LocalPlayer:WaitForChild("PlayerGui")
	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 1)
	frame.Position = UDim2.new(0.5, 0, 1, -2)
	frame.Size = UDim2.fromOffset(10, 10)
	frame.Rotation = 45
	frame.BackgroundColor3 = color
	frame.BorderSizePixel = 0
	frame.Parent = deathCamMarker
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.new(1, 0, 0, 20)
	textLabel.FontFace = Style.FONT
	textLabel.TextSize = 18
	textLabel.TextColor3 = Style.WHITE
	textLabel.TextStrokeTransparency = 0.5
	textLabel.AutoLocalize = false

	local player = p.killerName

	if player then
		local Players2 = game:GetService("Players")
		player = Players2:FindFirstChild(p.killerName)
	end

	local v7

	if player and player:IsA("Player") then
		v7 = player.DisplayName
	else
		v7 = p.killerName or ""
	end

	textLabel.Text = string.upper(v7)
	textLabel.Parent = deathCamMarker
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.BackgroundTransparency = 1
	textLabel2.Position = UDim2.fromOffset(0, 18)
	textLabel2.Size = UDim2.new(1, 0, 0, 14)
	textLabel2.FontFace = Style.FONT_BODY
	textLabel2.TextSize = 13
	textLabel2.TextColor3 = Style.MUTED
	textLabel2.TextStrokeTransparency = 0.6
	textLabel2.Text = ""
	textLabel2.Parent = deathCamMarker
	p.marker = deathCamMarker
	p.distance = textLabel2
end

local function onGamepadConnected() end

local function finish()
	local v7 = v2

	if not v7 then
		return
	end

	v2 = nil
	RunService:UnbindFromRenderStep("VoxelDeathCam")
	onGamepadConnected()

	if flag then
		flag = false
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true
	end

	if v7.partConn then
		v7.partConn:Disconnect()
	end

	if v7.highlight then
		v7.highlight:Destroy()
	end

	if v7.marker then
		v7.marker:Destroy()
	end

	deathGrade.Enabled = false
	local currentCamera = workspace.CurrentCamera
	currentCamera.CameraType = Enum.CameraType.Custom
	currentCamera.FieldOfView = Movement.FIELD_OF_VIEW
end

local function clear(origin: Vector3, position: Vector3, excludeInstances)
	local v7 = #excludeInstances == #v5

	if v7 then
		for k, excludeInstance in excludeInstances do
			if v5[k] ~= excludeInstance then
				v7 = false
				break
			end
		end
	end

	if not v7 then
		raycastParams.ExcludeInstances = excludeInstances
		table.clear(v5)
		table.move(excludeInstances, 1, #excludeInstances, 1, v5)
	end

	local v8 = position - origin

	if v8.Magnitude < 0.001 then
		return position
	end

	local raycastResult = workspace:Raycast(origin, v8, raycastParams)

	if raycastResult then
		return raycastResult.Position - v8.Unit * 0.6
	end

	return position
end

local function turn(p: number, p2: number)
	local v7 = v2

	if not v7 or os.clock() - v7.t0 < 0.35 then
		return
	end

	if not v7.free then
		local v8 = workspace.CurrentCamera.CFrame.Position - (centre(v7.body) + Vector3.new(0, 0.8, 0)) -- inferred equivalent call
		v7.yaw = math.atan2(v8.X, v8.Z)
		v7.pitch = math.clamp(
			math.atan2(v8.Y, Vector3.new(v8.X, 0, v8.Z).Magnitude),
			0.13962634015954636,
			1.3089969389957472
		)
		v7.dist = math.clamp(v8.Magnitude, 6, 9)
		v7.free = true
		v7.freeAt = os.clock()
	end

	v7.yaw -= p
	v7.pitch = math.clamp(v7.pitch + p2, 0.13962634015954636, 1.3089969389957472)
end

local v7 = Vector2.zero

local function frame(p: number)
	local v8 = v2

	if not v8 then
		return
	end

	if v == nil or next(v.pointerFree) == nil then
		flag = true
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		UserInputService.MouseIconEnabled = false
	elseif flag then
		flag = false
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true
	end

	if v7.Magnitude > 0.15 then
		turn(v7.X * 2.6 * p, -v7.Y * 2.6 * p)
	end

	local currentCamera = workspace.CurrentCamera
	currentCamera.CameraType = Enum.CameraType.Scriptable
	local now = os.clock()
	local v9 = now - v8.t0

	local v10 = centre(v8.body) -- inferred equivalent call

	for _, part in v8.parts do
		if part.LocalTransparencyModifier ~= 0 then
			part.LocalTransparencyModifier = 0
		end
	end

	local killer2 = v8.killerName and not v8.killer and findKiller(v8.killerName)

	if killer2 then
		v8.killer = killer2
		v8.killerAt = now
		markKiller(v8, killer2)
	end

	local killer = v8.killer

	if killer and not killer.Parent then
		killer = nil
	end

	local v11 = smooth(v9 / 0.35) -- inferred equivalent call
	local cframe3 = CFrame.new(v8.eye0.Position + Vector3.new(0, v11 * -1.2, 0)) * v8.eye0.Rotation * CFrame.Angles(v11 * -0.14, 0, v11 * 0.22)
	local cframe = CFrame.lookAt(v10 + v8.back * 7 + Vector3.new(0, 4, 0), v10 + Vector3.new(0, 0.8, 0))

	local fieldOfView = Movement.FIELD_OF_VIEW

	if not (v9 < 0.35) then
		if v9 < 1.2999999999999998 then
			cframe3 = cframe3:Lerp(cframe, smooth((v9 - 0.35) / 0.95)) -- inferred equivalent call
		else
			local v12

			if killer then
				v12 = centre(killer) -- inferred equivalent call
			end

			local cframe2, hlK

			if v12 then
				local vector3 = Vector3.new(v10.X - v12.X, 0, v10.Z - v12.Z)
				local vector

				if vector3.Magnitude > 0.001 then
					vector = vector3.Unit
				else
					vector = v8.back
				end

				local cross = vector:Cross(Vector3.new(0, 1, 0))
				local v13 = LocalPlayer:GetAttribute("DownUntil") ~= nil
				local v14 = v10 + vector * 5.5 + Vector3.new(0, 3, 0) + cross * 1.6
				local v15

				if v13 then
					v15 = v10 - vector * 2 + Vector3.new(0, 0.6, 0)
				else
					v15 = v12
				end

				cframe2 = CFrame.lookAt(v14, v15)
				hlK = smooth((now - math.max(v8.killerAt, v8.t0 + 0.35 + 0.95)) / 0.7) -- inferred equivalent call
				local v16 = math.clamp(
					math.deg(math.atan(16.25 / math.max((v12 - cframe2.Position).Magnitude, 1)) * 2),
					22,
					70
				)

				if v13 then
					fieldOfView = Movement.FIELD_OF_VIEW
				else
					fieldOfView = Movement.FIELD_OF_VIEW + (v16 - Movement.FIELD_OF_VIEW) * hlK
				end

				if v8.distance then
					local v17 = string.format("%d m", (math.round((v12 - v10).Magnitude / WorldConfig.METER)))

					if v17 ~= v8.distText then
						v8.distText = v17
						v8.distance.Text = v17
					end
				end
			else
				local v13 = (v9 - 0.35 - 0.95) * 0.25
				local vectorToWorldSpace = CFrame.Angles(0, v13, 0):VectorToWorldSpace(v8.back)
				cframe2 = CFrame.lookAt(
					v10 + vectorToWorldSpace * 7 + Vector3.new(0, 4, 0),
					v10 + Vector3.new(0, 0.8, 0)
				)
				hlK = 1
			end

			cframe3 = cframe:Lerp(cframe2, hlK)

			if v8.highlight and hlK ~= v8.hlK then
				v8.hlK = hlK
				v8.highlight.OutlineTransparency = 1 - hlK
				v8.highlight.FillTransparency = 1 - hlK * 0.25
			end
		end
	end

	if v8.free then
		local v12 = Vector3.new(math.sin(v8.yaw), 0, (math.cos(v8.yaw))) * math.cos(v8.pitch) + Vector3.new(0, 1, 0) * math.sin(v8.pitch)
		local v13 = v10 + Vector3.new(0, 0.8, 0)
		local v14 = smooth((now - v8.freeAt) / 0.2) -- inferred equivalent call
		cframe3 = cframe3:Lerp(CFrame.lookAt(v13 + v12 * v8.dist, v13), v14)
		fieldOfView += (Movement.FIELD_OF_VIEW - fieldOfView) * v14
	end

	if v9 >= 0.35 then
		local excludeInstances = excludeInstances2
		table.clear(excludeInstances)
		table.insert(excludeInstances, v8.body)
		table.insert(excludeInstances, currentCamera)

		if killer then
			table.insert(excludeInstances, killer)
		end

		for _, childName in v4 do
			local child = workspace:FindFirstChild(childName)

			if child then
				table.insert(excludeInstances, child)
			end
		end

		local v12 = clear(v10 + Vector3.new(0, 1.5, 0), cframe3.Position, excludeInstances)

		if v8.free and now - v8.freeAt >= 0.2 then
			cframe3 = CFrame.lookAt(v12, v10 + Vector3.new(0, 0.8, 0))
		else
			cframe3 = CFrame.new(v12) * cframe3.Rotation
		end
	end

	currentCamera.CFrame = cframe3
	currentCamera.Focus = CFrame.new(v10)
	currentCamera.FieldOfView = fieldOfView

	local v12 = smooth(v9 / 0.45) -- inferred equivalent call

	if v12 ~= v6 then
		v6 = v12
		deathGrade.Saturation = v12 * -0.7
		deathGrade.Contrast = v12 * 0.12
		deathGrade.TintColor = Color3.new(1, 1, 1):Lerp(Color3.fromRGB(255, 226, 220), v12)
	end
end

local function start(folder)
	finish()
	local currentCamera = workspace.CurrentCamera
	local lookVector = currentCamera.CFrame.LookVector
	local vector3 = Vector3.new(-lookVector.X, 0, -lookVector.Z)
	local back = not (vector3.Magnitude > 0.001) and Vector3.new(0, 0, 1) or vector3.Unit
	v2 = {
		t0 = os.clock(),
		eye0 = currentCamera.CFrame,
		back = back,
		body = folder,
		killerName = nil,
		killer = nil,
		killerAt = nil,
		highlight = nil,
		marker = nil,
		distance = nil,
		parts = {},
		partConn = nil,
		distText = nil,
		hlK = -1,
		free = false,
		freeAt = 0,
		yaw = 0,
		pitch = 0,
		dist = 0
	}

	local v8 = v2

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			table.insert(v8.parts, part)
		end
	end

	v8.partConn = folder.DescendantAdded:Connect(function(part)
		if part:IsA("BasePart") then
			table.insert(v8.parts, part)
		end
	end)

	if killerName2 and os.clock() - v3 < 2 then
		v2.killerName = killerName2
	end

	killerName2 = nil
	deathGrade.Enabled = true
	v6 = -1
	RunService:BindToRenderStep("VoxelDeathCam", Enum.RenderPriority.Camera.Value + 10, frame)
	onGamepadConnected()
end

died.OnClientEvent:Connect(function(killerName: string?)
	if type(killerName) ~= "string" or killerName == LocalPlayer.Name then
		return
	end

	local v8 = v2

	if v8 then
		v8.killerName = killerName
		return
	end

	local now = os.clock()
	killerName2 = killerName
	v3 = now
end)

local function onTouchMoved(p)
	if v2 then
		turn(p.Delta.X * 0.008, p.Delta.Y * 0.008)
	end
end
local function onChanged(data)
	if data.KeyCode == Enum.KeyCode.Thumbstick2 then
		v7 = Vector2.new(data.Position.X, data.Position.Y)
	elseif
		v2
		and data.UserInputType == Enum.UserInputType.MouseMovement
		and UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter
	then
		turn(data.Delta.X * 0.005, data.Delta.Y * 0.005)
	end
end
local touchMovedConnection = nil
local inputChangedConnection = nil
local v8 = false
onGamepadConnected = function()
	if UserInputService.GamepadEnabled or UserInputService.MouseEnabled then
		v8 = true
	end

	if v2 and not touchMovedConnection then
		touchMovedConnection = UserInputService.TouchMoved:Connect(onTouchMoved)
	elseif not v2 and touchMovedConnection then
		touchMovedConnection:Disconnect()
		touchMovedConnection = nil
	end

	local v9 = v2 ~= nil or v8

	if v9 and not inputChangedConnection then
		inputChangedConnection = UserInputService.InputChanged:Connect(onChanged)
	elseif not v9 and inputChangedConnection then
		inputChangedConnection:Disconnect()
		inputChangedConnection = nil
	end
end
UserInputService.GamepadConnected:Connect(onGamepadConnected)
UserInputService:GetPropertyChangedSignal("GamepadEnabled"):Connect(onGamepadConnected)
UserInputService:GetPropertyChangedSignal("MouseEnabled"):Connect(onGamepadConnected)
onGamepadConnected()

local function follow(humanoid) -- 2 equivalent calls inferred from this helper
	local currentCamera = workspace.CurrentCamera
	currentCamera.CameraType = Enum.CameraType.Custom

	if currentCamera.CameraSubject ~= humanoid then
		currentCamera.CameraSubject = humanoid
	end
end

local function watchCharacter(instance)
	finish()
	local humanoid = instance:WaitForChild("Humanoid", 10)
	assert(humanoid and humanoid:IsA("Humanoid"), "DeathCam: character has no Humanoid")
	follow(humanoid) -- inferred equivalent call
	task.spawn(function()
		for _ = 1, 10 do
			RunService.Heartbeat:Wait()

			if LocalPlayer.Character ~= instance or v2 then
				break
			end

			follow(humanoid) -- inferred equivalent call
		end
	end)
	humanoid.Died:Connect(function()
		if LocalPlayer.Character == instance then
			start(instance)
		end
	end)
end
LocalPlayer.CharacterAdded:Connect(watchCharacter)

if LocalPlayer.Character then
	task.spawn(watchCharacter, LocalPlayer.Character)
end