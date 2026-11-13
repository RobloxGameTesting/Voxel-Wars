local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VRService = game:GetService("VRService")

local VoxelSound = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("VoxelSound"))

local LocalPlayer = Players.LocalPlayer

local _ = { sniper = 0.16, dmr = 0.1 }
local color = Color3.fromRGB(255, 236, 196)

local color2 = Color3.fromRGB(255, 205, 120)

local nearMissCue = Instance.new("ScreenGui")
nearMissCue.Name = "NearMissCue"
nearMissCue.IgnoreGuiInset = true
nearMissCue.ResetOnSpawn = false
nearMissCue.DisplayOrder = 2
nearMissCue.Enabled = false
nearMissCue.Parent = LocalPlayer:WaitForChild("PlayerGui")
local v = {}
local v2 = {}
local v3 = { 72, 14 }

for i = 1, 3 do
	local nearMissStreak = Instance.new("Part")
	nearMissStreak.Name = "NearMissStreak"
	nearMissStreak.Anchored = true
	nearMissStreak.CanCollide = false
	nearMissStreak.CanQuery = false
	nearMissStreak.CanTouch = false
	nearMissStreak.CastShadow = false
	nearMissStreak.Material = Enum.Material.Neon
	nearMissStreak.Color = color
	nearMissStreak.Transparency = 1
	nearMissStreak.Size = Vector3.new(0.1, 0.1, 1)
	nearMissStreak.Parent = workspace.CurrentCamera or workspace
	v[i] = { part = nearMissStreak, at = -1e999, life = 0.16 }

	local cue = Instance.new("Frame")
	cue.Name = "Cue"
	cue.AnchorPoint = Vector2.new(0.5, 0.5)
	cue.BackgroundColor3 = color2
	cue.BorderSizePixel = 0
	cue.Visible = false
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0.5, 0)
	uiCorner.Parent = cue
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(40, 28, 16)
	uiStroke.Thickness = 2
	uiStroke.Parent = cue
	cue.Parent = nearMissCue
	v2[i] = { frame = cue, at = -1e999, from = Vector3.new(0, 0, 0), k = 0 }
end

local renderSteppedConnection = nil
local function oldest(list) -- 2 equivalent calls inferred from this helper
	local v4 = list[1]

	for _, item in list do
		if item.at < v4.at then
			v4 = item
		end
	end

	return v4
end

local function step()
	local now = os.clock()
	local currentCamera = workspace.CurrentCamera
	local v4 = false

	for _, v5 in v do
		local v6 = now - v5.at

		if v6 < v5.life then
			v5.part.Transparency = 0.15 + 0.85 * (v6 / v5.life)
			v4 = true
		elseif v5.part.Transparency < 1 then
			v5.part.Transparency = 1
		end
	end

	local enabled = false

	if currentCamera then
		local viewportSize = currentCamera.ViewportSize
		local v5 = math.min(viewportSize.X, viewportSize.Y)
		local v6 = viewportSize.Y / 1080

		for _, v7 in v2 do
			local v8 = now - v7.at

			if v8 < 1.1 then
				local vectorToObjectSpace = currentCamera.CFrame:VectorToObjectSpace(v7.from - currentCamera.CFrame.Position)
				local v9 = math.atan2(vectorToObjectSpace.X, -vectorToObjectSpace.Z)
				local v10 = v5 * 0.27
				local frame = v7.frame
				frame.Visible = true
				frame.Position = UDim2.fromOffset(
					viewportSize.X / 2 + math.sin(v9) * v10,
					viewportSize.Y / 2 - math.cos(v9) * v10
				)
				frame.Rotation = math.deg(v9)
				local v11 = math.max(0, 1 - v8 / 0.12) * 0.25 + 1
				frame.Size = UDim2.fromOffset(v3[1] * v6 * (v7.k * 0.25 + 0.75) * v11, v3[2] * v6 * v11)
				local v12 = math.clamp((v8 - 0.35) / 0.7500000000000001, 0, 1)
				frame.BackgroundTransparency = v12 * 0.95 + 0.05
				local uiStroke = frame:FindFirstChildOfClass("UIStroke")
				uiStroke.Transparency = v12 * 0.7 + 0.3
				enabled = true
				v4 = true
			elseif v7.frame.Visible then
				v7.frame.Visible = false
			end
		end
	end

	if nearMissCue.Enabled ~= enabled then
		nearMissCue.Enabled = enabled
	end

	if not v4 and renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end
end

local function wake() -- 1 equivalent call inferred from this helper
	if not renderSteppedConnection then
		renderSteppedConnection = RunService.RenderStepped:Connect(step)
	end
end

function VoxelSound.passed(from: Vector3, vector3: Vector3, value: number, flag: boolean?)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local now = os.clock()
	local v4 = 1 - math.clamp(value, 0, 1)

	local v5 = vector3 - from

	if v5.Magnitude > 1 then
		local unit = v5.Unit

		if (vector3 - currentCamera.CFrame.Position).Magnitude > 1.2 then
			local v6 = vector3 - unit * math.min(22, v5.Magnitude)
			local v7 = vector3 + unit * 6
			local v8 = oldest(v) -- inferred equivalent call
			local v9 = flag and 0.16 or 0.1
			v8.part.Size = Vector3.new(v9, v9, (v7 - v6).Magnitude)
			v8.part.CFrame = CFrame.lookAt((v6 + v7) / 2, v7)
			v8.part.Transparency = 0.15
			v8.at = now
			v8.life = (flag and 1.25 or 1) * 0.16
		end
	end

	if not VRService.VREnabled then
		local v6 = oldest(v2) -- inferred equivalent call
		v6.at = now
		v6.from = from
		v6.k = v4
	end

	wake() -- inferred equivalent call
end