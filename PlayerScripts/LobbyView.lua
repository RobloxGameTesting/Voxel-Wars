local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local v = nil

local object = setmetatable({}, { __mode = "k" })
local function apply(descendant, enabled: boolean)
	if descendant:IsA("BasePart") then
		descendant.LocalTransparencyModifier = enabled and 0 or 1

		if enabled then
			if object[descendant] then
				descendant.CanCollide = true
			end
		elseif descendant.CanCollide then
			object[descendant] = true
			descendant.CanCollide = false
		end
	elseif descendant:IsA("Decal") then
		descendant.LocalTransparencyModifier = enabled and 0 or 1
	elseif descendant:IsA("BillboardGui") or descendant:IsA("SurfaceGui") then
		descendant.Enabled = enabled
	end
end

local function setPad(enabled: boolean)
	for _, folder in CollectionService:GetTagged("SkyLobby") do
		for _, descendant in folder:GetDescendants() do
			apply(descendant, enabled)
		end
	end
end

local v2 = {}
local function watch(instance) -- 2 equivalent calls inferred from this helper
	if v2[instance] then
		return
	end

	v2[instance] = instance.DescendantAdded:Connect(function(descendant)
		if v ~= nil then
			apply(descendant, v)
		end
	end)
end

for _, v3 in CollectionService:GetTagged("SkyLobby") do
	watch(v3) -- inferred equivalent call
end

CollectionService:GetInstanceRemovedSignal("SkyLobby"):Connect(function(p)
	local connection = v2[p]

	if connection then
		connection:Disconnect()
		v2[p] = nil
	end
end)

local v3 = {}
local function setPickers(flag: boolean)
	for _, v4 in Players:GetPlayers() do
		local character = v4.Character

		if not (v4 ~= LocalPlayer and character) then
			continue
		end

		local v5 = not flag and v4.Team == nil

		if not (v5 or v3[character]) then
			continue
		end

		for _, descendant in character:GetDescendants() do
			if descendant:IsA("BasePart") or descendant:IsA("Decal") then
				descendant.LocalTransparencyModifier = v5 and 1 or 0
			end
		end

		v3[character] = v5 and true or nil
	end

	for k in v3 do
		if k.Parent == nil then
			v3[k] = nil
		end
	end
end

task.spawn(function()
	while true do
		task.wait(0.5)
		local enabled = LocalPlayer.Team == nil

		if enabled ~= v then
			v = enabled
			setPad(enabled)
		end

		setPickers(enabled)
	end
end)

local flag = false
local v4 = 0
local function padCamera()
	local v5

	if LocalPlayer.Team == nil then
		v5 = LocalPlayer:GetAttribute("PickingTeam") == true
	else
		v5 = false
	end

	if v5 then
		if LocalPlayer.CameraMode ~= Enum.CameraMode.Classic then
			LocalPlayer.CameraMode = Enum.CameraMode.Classic
		end

		if flag then
			if v4 >= 0 then
				v4 += 1

				if v4 >= 2 then
					v4 = -1
					LocalPlayer.CameraMinZoomDistance = 0.5
					LocalPlayer.CameraMaxZoomDistance = 128
				end
			end
		else
			flag = true
			v4 = 0

			LocalPlayer.CameraMaxZoomDistance = 12
			LocalPlayer.CameraMinZoomDistance = 12
			UserInputService.MouseIconEnabled = true
		end
	elseif flag then
		flag = false
		LocalPlayer.CameraMinZoomDistance = 0.5
		LocalPlayer.CameraMaxZoomDistance = 0.5
		LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
	end
end

local v5 = Enum.RenderPriority.Last.Value + 11
local v6 = false
local renderSteppedConnection = nil
local function refreshPad()
	local v7

	if LocalPlayer.Team == nil then
		v7 = LocalPlayer:GetAttribute("PickingTeam") == true
	else
		v7 = false
	end

	if v7 and not renderSteppedConnection then
		renderSteppedConnection = RunService.RenderStepped:Connect(padCamera)
	elseif not v7 and renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
		padCamera()
	end

	if v7 and not v6 then
		v6 = true
		RunService:BindToRenderStep("LobbyPointer", v5, function()
			if not UserInputService.MouseEnabled then
				return
			end

			local currentCamera = workspace.CurrentCamera

			if currentCamera and (currentCamera.Focus.Position - currentCamera.CFrame.Position).Magnitude < 1 then
				return
			end

			UserInputService.MouseIconEnabled = true

			if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
				UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			end
		end)
	elseif not v7 and v6 then
		v6 = false
		RunService:UnbindFromRenderStep("LobbyPointer")
	end
end
LocalPlayer:GetPropertyChangedSignal("Team"):Connect(refreshPad)
LocalPlayer:GetAttributeChangedSignal("PickingTeam"):Connect(refreshPad)
refreshPad()

local GuiService = game:GetService("GuiService")
local Viewmodel = nil
task.spawn(function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	Viewmodel = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("Viewmodel"))
end)
RunService:BindToRenderStep("CentrePointer", Enum.RenderPriority.Camera.Value + 5, function()
	if not UserInputService.MouseIconEnabled or GuiService.MenuIsOpen or Viewmodel == nil then
		return
	end

	local current = Viewmodel.current
	local v7

	if current == nil then
		v7 = false
	else
		v7 = current.active == true
	end

	if
		UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter and not v7
		or LocalPlayer.Team == nil and LocalPlayer:GetAttribute("PickingTeam") == true
		or next(Viewmodel.pointerFree) ~= nil
	then
		return
	end

	UserInputService.MouseIconEnabled = false
end)

local flag2 = false
local function bodyReady(): boolean -- 1 equivalent call inferred from this helper
	local character = LocalPlayer.Character
	return character ~= nil
		and character:FindFirstChild("HumanoidRootPart") ~= nil
		and character:FindFirstChildOfClass("Humanoid") ~= nil
end

local v7 = false
local function waitStep()
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local v8

	if LocalPlayer.Team == nil then
		v8 = not bodyReady() -- inferred equivalent call
	else
		v8 = false
	end

	if v8 or flag2 or LocalPlayer.Team == nil then
		if v8 then
			flag2 = true
			currentCamera.CameraType = Enum.CameraType.Scriptable
			local model = CollectionService:GetTagged("SkyLobby")[1]
			local v9 = math.sin(os.clock() * 0.25) * 0.06

			if model and model:IsA("Model") then
				local cframe = model:GetPivot() * CFrame.Angles(0, v9, 0)
				currentCamera.CFrame = CFrame.lookAt(
					cframe:PointToWorldSpace(Vector3.new(56, 16, 0)),
					cframe:PointToWorldSpace(Vector3.new(-16, 3, 0))
				)
			else
				currentCamera.CFrame = CFrame.new(0, 400, 0) * CFrame.Angles(0, v9, 0) * CFrame.Angles(-0.20943951023931956, 0, 0)
			end
		elseif flag2 then
			flag2 = false
			local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

			if currentCamera.CameraType == Enum.CameraType.Scriptable then
				currentCamera.CameraType = Enum.CameraType.Custom
			end

			if humanoid then
				currentCamera.CameraSubject = humanoid
			end
		end
	else
		v7 = false
		RunService:UnbindFromRenderStep("LobbyWait")
	end
end
local function bindWait()
	if not v7 and LocalPlayer.Team == nil then
		v7 = true
		RunService:BindToRenderStep("LobbyWait", Enum.RenderPriority.Camera.Value + 1, waitStep)
	end
end
LocalPlayer:GetPropertyChangedSignal("Team"):Connect(bindWait)
v7 = true
RunService:BindToRenderStep("LobbyWait", Enum.RenderPriority.Camera.Value + 1, waitStep)

LocalPlayer.CharacterAdded:Connect(function(character)
	local humanoid = character:WaitForChild("Humanoid", 10)

	if not humanoid or LocalPlayer.Character ~= character then
		return
	end

	local v8 = os.clock() + 15
	local count = 0
	local renderSteppedConnection2 = nil
	renderSteppedConnection2 = RunService.RenderStepped:Connect(function()
		if LocalPlayer.Character == character and not (v8 < os.clock()) and LocalPlayer.Team ~= nil then
			local spawnLook = character:GetAttribute("SpawnLook")
			local currentCamera = workspace.CurrentCamera

			if typeof(spawnLook) ~= "Vector3" or not currentCamera then
				return
			end

			if currentCamera.CameraType ~= Enum.CameraType.Custom or currentCamera.CameraSubject ~= humanoid then
				count = 0
				return
			end

			local vector3 = Vector3.new(spawnLook.X, 0, spawnLook.Z)

			if vector3.Magnitude < 0.1 then
				renderSteppedConnection2:Disconnect()
				return
			end

			local position = currentCamera.CFrame.Position
			currentCamera.CFrame = CFrame.lookAt(position, position + vector3.Unit)
			count += 1

			if count >= 4 then
				renderSteppedConnection2:Disconnect()
			end

			return
		end

		renderSteppedConnection2:Disconnect()
	end)
end)

CollectionService:GetInstanceAddedSignal("SkyLobby"):Connect(function(instance)
	watch(instance) -- inferred equivalent call

	if v ~= nil then
		setPad(v)
	end
end)