local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Style = require(script.Parent:WaitForChild("GameUI"):WaitForChild("Style"))

local LocalPlayer = Players.LocalPlayer
local spots = ReplicatedStorage:WaitForChild("Vehicles"):WaitForChild("Spots")

local v = { Humvee = "HUMVEE", Tank = "TANK", Bradley = "IFV", Heli = "HELICOPTER" }

local v2 = {}

local function label(frame, text: string, fontFace, textColor: Color3, p: number, p2: number)
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.fromScale(1, p2)
	textLabel.Position = UDim2.fromScale(0, p)
	textLabel.FontFace = fontFace
	textLabel.TextScaled = true
	textLabel.TextColor3 = textColor
	textLabel.Text = text
	textLabel.Parent = frame
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 1
	uiStroke.Transparency = 0.3
	uiStroke.Parent = textLabel
	return textLabel
end

local function build()
	local vehicleSpawnTimer = Instance.new("Attachment")
	vehicleSpawnTimer.Name = "VehicleSpawnTimer"
	vehicleSpawnTimer.Parent = workspace.Terrain
	local vehicleSpawnTimer2 = Instance.new("BillboardGui")
	vehicleSpawnTimer2.Name = "VehicleSpawnTimer"
	vehicleSpawnTimer2.Size = UDim2.fromScale(6, 2.3)
	vehicleSpawnTimer2.AlwaysOnTop = false
	vehicleSpawnTimer2.MaxDistance = 200
	vehicleSpawnTimer2.LightInfluence = 0
	vehicleSpawnTimer2.ResetOnSpawn = false
	vehicleSpawnTimer2.Adornee = vehicleSpawnTimer
	vehicleSpawnTimer2.Enabled = false
	vehicleSpawnTimer2.Parent = LocalPlayer:WaitForChild("PlayerGui")
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Style.PANEL
	frame.BackgroundTransparency = Style.PANEL_ALPHA
	frame.BorderSizePixel = 0
	frame.Parent = vehicleSpawnTimer2
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 3)
	uiCorner.Parent = frame
	local frame2 = Instance.new("Frame")
	frame2.Size = UDim2.fromScale(1, 0.065)
	frame2.BackgroundColor3 = Style.HAZARD
	frame2.BorderSizePixel = 0
	frame2.Parent = frame
	return {
		anchor = vehicleSpawnTimer,
		gui = vehicleSpawnTimer2,
		title = label(frame, "", Style.FONT_BODY, Style.MUTED, 0.1, 0.32),
		time = label(frame, "", Style.FONT, Style.HAZARD, 0.42, 0.52),
		pos = nil,
		model = nil,
		secs = -1
	}
end

local function forget(child) -- 1 equivalent call inferred from this helper
	local v3 = v2[child]

	if v3 then
		v3.gui:Destroy()
		v3.anchor:Destroy()
		v2[child] = nil
	end
end

local children = spots:GetChildren()
spots.ChildAdded:Connect(function(child)
	table.insert(children, child)
end)
spots.ChildRemoved:Connect(function(child)
	local index = table.find(children, child)

	if index then
		table.remove(children, index)
	end

	forget(child) -- inferred equivalent call
end)

local v3 = -1e999
RunService.Heartbeat:Connect(function()
	local now = os.clock()

	if now - v3 < 0.25 then
		return
	end

	v3 = now
	local serverTimeNow = workspace:GetServerTimeNow()
	local name = LocalPlayer.Team and LocalPlayer.Team.Name

	for _, configuration in children do
		if not configuration:IsA("Configuration") then
			continue
		end

		local respawnAt = configuration:GetAttribute("RespawnAt")
		local v4 = (typeof(respawnAt) ~= "number" or not (respawnAt > 0)) and 0 or respawnAt - serverTimeNow
		local v5

		if name == nil or configuration:GetAttribute("Team") ~= name then
			v5 = false
		else
			v5 = v4 > 0
		end

		local v6 = v2[configuration]

		if v5 then
			if not v6 then
				v6 = build()
				v2[configuration] = v6
			end

			assert(v6)
			local pos = configuration:GetAttribute("Pos")

			if typeof(pos) == "Vector3" and pos ~= v6.pos then
				v6.pos = pos
				v6.anchor.WorldPosition = pos + Vector3.new(0, 7, 0)
			end

			local model = configuration:GetAttribute("Model")

			if model ~= v6.model or v6.secs < 0 then
				v6.model = model
				v6.title.Text = (type(model) ~= "string" and "VEHICLE" or v[model] or string.upper(model)) .. " IN"
			end

			local secs = math.ceil(v4)

			if secs ~= v6.secs then
				v6.secs = secs
				v6.time.Text = string.format("%d:%02d", secs // 60, secs % 60)
			end

			if not v6.gui.Enabled then
				v6.gui.Enabled = true
			end
		elseif v6 and v6.gui.Enabled then
			v6.gui.Enabled = false
		end
	end
end)