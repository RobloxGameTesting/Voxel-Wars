local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local AudioGraph = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("AudioGraph"))
local VehicleConfig = require(ReplicatedStorage:WaitForChild("Vehicles"):WaitForChild("VehicleConfig"))
local Style = require(script.Parent:WaitForChild("GameUI"):WaitForChild("Style"))

local AIR_BOUNDS = VehicleConfig.AIR_BOUNDS
assert(
	AIR_BOUNDS and AIR_BOUNDS.attr and AIR_BOUNDS.linger,
	"[AirBoundsView] VehicleConfig.AIR_BOUNDS is missing a field"
)

local _ = { id = "rbxassetid://9113129096", from = 0.065, to = 0.14, lowpass = 900 }
local v = { 1, 0.6 }
local v2 = { 0.8, 0.7 }

local v3 = nil
local warning = nil
local shade = nil
local v4 = nil
local uiScale = nil
local airBoundsGrey = nil

local function line(p: string, p2: string, p3: number, p4: number, textColor: Color3, p5: number)
	local label = Style.label(warning, p, p2, p3, Style.FONT, p5)
	label.AutomaticSize = Enum.AutomaticSize.None
	label.Size = UDim2.new(1, 0, 0, p3 + 8)
	label.Position = UDim2.fromOffset(0, p4)
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextColor3 = textColor
	local uiStroke = label:FindFirstChildOfClass("UIStroke")

	if uiStroke then
		uiStroke.Transparency = 0
		uiStroke.Color = Style.INK
	end

	return label
end

local function build()
	local airBounds = Instance.new("ScreenGui")
	airBounds.Name = "AirBounds"
	airBounds.ResetOnSpawn = false
	airBounds.IgnoreGuiInset = true
	airBounds.DisplayOrder = 40
	airBounds.Enabled = false
	shade = Instance.new("Frame")
	shade.Name = "Shade"
	shade.BorderSizePixel = 0
	shade.BackgroundColor3 = Style.INK
	shade.BackgroundTransparency = 1
	shade.Size = UDim2.fromScale(1, 1)
	shade.Parent = airBounds
	warning = Instance.new("Frame")
	warning.Name = "Warning"
	warning.BackgroundTransparency = 1
	warning.AnchorPoint = Vector2.new(0.5, 0.5)
	warning.Position = UDim2.fromScale(0.5, 0.34)
	warning.Size = UDim2.fromOffset(640, 190)
	warning.Parent = airBounds
	uiScale = Instance.new("UIScale")
	uiScale.Parent = warning
	line("Title", "OUT OF BOUNDS", 46, 0, Style.ORANGE, 3)
	line("Sub", "TURN BACK", 24, 56, Style.WHITE, 2)
	v4 = line("Count", "", 72, 92, Style.HAZARD, 3)
	v4.AutoLocalize = false
	airBoundsGrey = Instance.new("ColorCorrectionEffect")
	airBoundsGrey.Name = "AirBoundsGrey"
	airBoundsGrey.Enabled = false
	airBoundsGrey.Parent = Lighting
	airBounds.Parent = LocalPlayer:WaitForChild("PlayerGui")
	v3 = airBounds
end

local v5 = nil
local v6 = { 0, 0 }
local function thud(p: number)
	if not v5 then
		local players = {}

		for i = 1, 2 do
			local flat = AudioGraph.flat("AirBounds_" .. i)
			AudioGraph.route(flat, "ui")
			AudioGraph.lowpass(flat, 900)
			flat.player.Looping = false
			flat.player.Asset = "rbxassetid://9113129096"
			players[i] = flat.player
		end

		v5 = players
	end

	local v7 = v5[p]
	v7:Stop()
	v7.PlaybackRegion = NumberRange.new(0.065, 0.14)
	v7.PlaybackSpeed = v2[p]
	v7.Volume = v[p]
	v7.TimePosition = 0.065
	v7:Play()
	v6[p] += 1
	local v8 = v6[p]
	task.delay(0.07500000000000001 / v2[p] + 0.05, function()
		if v6[p] == v8 then
			v7:Stop()
		end
	end)
end
local function beat() -- 1 equivalent call inferred from this helper
	thud(1)
	task.delay(0.17, thud, 2)
end

local v7 = nil
local v8 = 0
local renderSteppedConnection = nil
local v9 = -1
local v10 = 0

local function step(p: number)
	local serverTimeNow = workspace:GetServerTimeNow()
	local visible

	if v7 == nil then
		visible = false
	else
		visible = serverTimeNow < v7 + AIR_BOUNDS.linger
	end

	local v11

	if visible then
		v11 = math.min(1, v8 + p / 0.35)
	else
		v11 = math.max(0, v8 - p / 0.6)
	end

	v8 = v11
	local v12 = v8 * v8 * (3 - v8 * 2)
	AudioGraph.setBounds(v12)
	airBoundsGrey.Saturation = v12 * -0.8
	shade.BackgroundTransparency = 1 - v12 * 0.4
	warning.Visible = visible

	if visible then
		local v13 = math.max(0, v7 - serverTimeNow)
		local v14 = math.ceil(v13 * 10)

		if v14 ~= v9 then
			v9 = v14
			v4.Text = string.format("%.1f", v14 / 10)
		end

		local now = os.clock()

		if v13 > 0 and v10 <= now then
			v10 = now + (v13 <= 3 and 0.5 or 1)
			beat() -- inferred equivalent call
		end
	elseif v8 <= 0 then
		airBoundsGrey.Enabled = false
		v3.Enabled = false

		if renderSteppedConnection then
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		end
	end
end

local function read()
	local attribute = LocalPlayer:GetAttribute(AIR_BOUNDS.attr)

	if type(attribute) ~= "number" then
		attribute = nil
	end

	v7 = attribute

	if not v7 or workspace:GetServerTimeNow() >= v7 + AIR_BOUNDS.linger or renderSteppedConnection then
		return
	end

	if not v3 then
		build()
	end

	local currentCamera = workspace.CurrentCamera
	uiScale.Scale = not currentCamera and 1 or Style.computeScale(currentCamera.ViewportSize)
	v9 = -1
	v10 = 0
	airBoundsGrey.Enabled = true
	v3.Enabled = true
	renderSteppedConnection = RunService.RenderStepped:Connect(step)
end

LocalPlayer:GetAttributeChangedSignal(AIR_BOUNDS.attr):Connect(read)
read()