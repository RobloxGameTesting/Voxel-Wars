local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VRService = game:GetService("VRService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local VR = require(Voxel:WaitForChild("VR"))
local Viewmodel = require(Voxel:WaitForChild("Viewmodel"))
local TouchControls = require(Voxel:WaitForChild("TouchControls"))
local MenuLock = require(Voxel:WaitForChild("MenuLock"))

local LocalPlayer = Players.LocalPlayer

local v = CFrame.new(0, 0.12, 0.32) * CFrame.Angles(1.5707963267948966, 0, 0)

local color = Color3.fromRGB(120, 220, 120)
local color2 = Color3.fromRGB(235, 80, 60)

local function setPointer(held: boolean) -- 2 equivalent calls inferred from this helper
	pcall(function()
		local laserPointer

		if held then
			laserPointer = Enum.VRLaserPointerMode.Pointer
		else
			laserPointer = Enum.VRLaserPointerMode.Disabled
		end

		VRService.LaserPointer = laserPointer
	end)
end

local v2 = nil
local v3 = nil
local v4 = nil
local function buildPanel()
	local vrWrist = Instance.new("Part")
	vrWrist.Name = "VRWrist"
	vrWrist.Anchored = true
	vrWrist.CanCollide = false
	vrWrist.CanQuery = false
	vrWrist.CanTouch = false
	vrWrist.CastShadow = false
	vrWrist.Transparency = 1
	vrWrist.Size = Vector3.new(0.5, 0.2, 0.02)
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Face = Enum.NormalId.Front
	surfaceGui.LightInfluence = 0
	surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surfaceGui.PixelsPerStud = 300
	surfaceGui.Parent = vrWrist
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = Color3.fromRGB(16, 18, 20)
	frame.BackgroundTransparency = 0.25
	frame.BorderSizePixel = 0
	frame.Size = UDim2.fromScale(1, 1)
	frame.Parent = surfaceGui
	local frame2 = Instance.new("Frame")
	frame2.BackgroundColor3 = Color3.fromRGB(50, 54, 58)
	frame2.BorderSizePixel = 0
	frame2.Position = UDim2.fromScale(0.06, 0.62)
	frame2.Size = UDim2.fromScale(0.88, 0.22)
	frame2.Parent = frame
	local frame3 = Instance.new("Frame")
	frame3.BackgroundColor3 = color
	frame3.BorderSizePixel = 0
	frame3.Size = UDim2.fromScale(1, 1)
	frame3.Parent = frame2
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Position = UDim2.fromScale(0.06, 0.08)
	textLabel.Size = UDim2.fromScale(0.88, 0.48)
	textLabel.Font = Enum.Font.GothamBlack
	textLabel.TextScaled = true
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.Text = ""
	textLabel.Parent = frame
	v2 = vrWrist
	v3 = frame3
	v4 = textLabel
end

local v5 = -1
local v6 = nil
local function step()
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local v7

	if humanoid == nil then
		v7 = false
	else
		v7 = humanoid.Health > 0
	end

	local current = Viewmodel.current
	local v8 = current ~= nil and current.active and v7
	local held = MenuLock.held or not v8

	if held ~= v6 then
		v6 = held
		setPointer(held) -- inferred equivalent call
	end

	local v9 = v2

	if not (v7 and VR.tracked("Left")) then
		v9.Parent = nil
		return
	end

	v9.CFrame = VR.hand("Left") * v
	v9.Parent = workspace.CurrentCamera
	local health = math.ceil(humanoid.Health)

	if health ~= v5 then
		v5 = health
		local v10 = math.clamp(health / math.max(humanoid.MaxHealth, 1), 0, 1)
		v3.Size = UDim2.fromScale(v10, 1)
		local v11 = v3
		local backgroundColor = if v10 < 0.35 then color2 else color
		v11.BackgroundColor3 = backgroundColor
		v4.Text = "HP " .. tostring(health)
	end
end

local v7 = false
VR.watch(function(flag: boolean)
	if flag and not v7 then
		v7 = true
		pcall(function()
			VRService.ControllerModels = Enum.VRControllerModelMode.Disabled
		end)
		Viewmodel.vrReload = TouchControls.reloadNow

		if not v2 then
			buildPanel()
		end

		v6 = nil
		RunService:BindToRenderStep("VoxelVRControls", Enum.RenderPriority.Camera.Value + 5, step)
	elseif not flag and v7 then
		v7 = false
		RunService:UnbindFromRenderStep("VoxelVRControls")
		Viewmodel.vrReload = nil

		if v2 then
			v2.Parent = nil
		end

		setPointer(true) -- inferred equivalent call
	end
end)