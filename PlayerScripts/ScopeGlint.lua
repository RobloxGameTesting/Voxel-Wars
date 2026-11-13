local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local SniperSpecs = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("SniperSpecs"))
local WorldConfig = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("WorldConfig"))
local ScopeFeed = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("ScopeFeed"))

local LocalPlayer = Players.LocalPlayer

local color = Color3.fromRGB(255, 244, 222)

local color2 = Color3.new(1, 1, 1)

local v = {}
local v2 = {}

local function image(scopeGlint, image2: string, p: number)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = image2
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Position = UDim2.fromScale(0.5, 0.5)
	imageLabel.Size = UDim2.fromScale(p, p)
	imageLabel.Parent = scopeGlint
	return imageLabel
end

local function build()
	local scopeGlint = Instance.new("Attachment")
	scopeGlint.Name = "ScopeGlint"
	scopeGlint.Parent = workspace.Terrain
	local scopeGlint2 = Instance.new("BillboardGui")
	scopeGlint2.Name = "ScopeGlint"
	scopeGlint2.Adornee = scopeGlint
	scopeGlint2.AlwaysOnTop = false
	scopeGlint2.LightInfluence = 0
	scopeGlint2.ResetOnSpawn = false
	scopeGlint2.Enabled = false
	local fan = image(scopeGlint2, "rbxassetid://106244102409684", 1)
	fan.Visible = false
	local star = image(scopeGlint2, "rbxassetid://105173936271463", 0.65)
	star.ImageColor3 = color
	star.ZIndex = 2
	scopeGlint2.Parent = LocalPlayer:WaitForChild("PlayerGui")
	return {
		gui = scopeGlint2,
		att = scopeGlint,
		star = star,
		fan = fan,
		k = 0,
		used = false,
		flare = 0,
		armed = true
	}
end

local v3 = {}

local renderSteppedConnection = nil
local step

local function wake() -- 1 equivalent call inferred from this helper
	if not renderSteppedConnection then
		renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
			step(dt)
		end)
	end
end
ScopeFeed.wake = wake

local function watch(character)
	local function changed() -- 1 equivalent call inferred from this helper
		if character:GetAttribute("Scoped") and character.Parent then
			v3[character] = true
			wake() -- inferred equivalent call
		else
			v3[character] = nil
		end
	end
	character:GetAttributeChangedSignal("Scoped"):Connect(changed)
	character.AncestryChanged:Connect(changed)
	changed() -- inferred equivalent call
end

local function joined(player) -- 1 equivalent call inferred from this helper
	if player == LocalPlayer then
		return
	end

	player.CharacterAdded:Connect(watch)

	if player.Character then
		watch(player.Character)
	end
end
Players.PlayerAdded:Connect(joined)

for _, v4 in Players:GetPlayers() do
	joined(v4) -- inferred equivalent call
end

local function enemy(character): boolean -- 1 equivalent call inferred from this helper
	local playerFromCharacter = Players:GetPlayerFromCharacter(character)

	if playerFromCharacter and playerFromCharacter:GetAttribute("Invisible") == true then
		return false
	end

	return playerFromCharacter == nil or LocalPlayer.Team == nil or playerFromCharacter.Team ~= LocalPlayer.Team
end

local function curveOf(instance) -- 1 equivalent call inferred from this helper
	local tool = instance:FindFirstChildOfClass("Tool")
	local v4

	if tool then
		v4 = SniperSpecs.of(tool.Name)
	end

	return if v4 then v4.damage.curve else SniperSpecs.SNIPER_CURVE
end

local function show(k, vector3: Vector3, vector: Vector3, p, currentCamera, position: Vector3, p2: number, _: number)
	local v4 = position - vector3
	local magnitude = v4.Magnitude

	if magnitude < 1 then
		return
	end

	local v5 = v4 / magnitude
	local v6 = math.acos((math.clamp(vector:Dot(v5), -1, 1)))
	local v7 = magnitude / WorldConfig.METER
	local v8

	if v6 < 0.2617993877991494 then
		local v9 = math.clamp((v6 - 0.061086523819801536) / 0.20071286397934787, 0, 1)
		v8 = (1 - v9 * v9) * math.clamp((v7 - 25) / 25, 0, 1)
	else
		v8 = 0
	end

	local v9 = v[k]

	if not v9 then
		if v8 <= 0 then
			return
		end

		v9 = table.remove(v2) or build()
		v[k] = v9
		v9.k = 0
		v9.flare = 0
		v9.armed = true
	end

	v9.used = true
	v9.k += (v8 - v9.k) * (1 - math.exp(p2 * -14))

	v9.flare *= math.exp(p2 * -4)

	if v6 > 0.17453292519943295 then
		v9.armed = true
	elseif v9.armed and v6 < 0.08726646259971647 and v8 > 0.5 then
		v9.armed = false
		v9.flare = 1
	end

	v9.att.WorldPosition = vector3 + v5 * math.min(4, magnitude * 0.5)
	local y = currentCamera.ViewportSize.Y
	local worldToViewportPoint = currentCamera:WorldToViewportPoint(v9.att.WorldPosition)
	local v10 = math.clamp(
		((Vector2.new(worldToViewportPoint.X, worldToViewportPoint.Y) - currentCamera.ViewportSize / 2).Magnitude / y - 0.05) / 0.15000000000000002,
		0,
		1
	) * 0.4 + 0.6
	local v11 = v10 + (1 - v10) * v9.flare
	local v12 = 0.115 * y * (v9.k * 0.5 + 0.5) * (v9.flare * 0.7 + 1)
	v9.gui.Size = UDim2.fromOffset(v12, v12)
	v9.star.ImageTransparency = 1 - math.max(v9.k, v9.flare) * v11
	v9.star.ImageColor3 = color:Lerp(color2, v9.flare)
	local visible = SniperSpecs.damageAt(p, v7) >= 200
	v9.fan.Visible = visible

	if visible then
		v9.fan.ImageTransparency = 1 - v9.k * v11
	end

	local enabled = v9.k > 0.01

	if v9.gui.Enabled ~= enabled then
		v9.gui.Enabled = enabled
	end
end

step = function(dt: number)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local position = currentCamera.CFrame.Position
	local now = os.clock()

	for _, v4 in v do
		v4.used = false
	end

	for k in v3 do
		local head = k:FindFirstChild("Head")
		local humanoidRootPart = k:FindFirstChild("HumanoidRootPart")

		if not (head and humanoidRootPart and enemy(k)) then -- inferred equivalent call
			continue
		end

		local aimPitch = k:GetAttribute("AimPitch")
		local v4 = type(aimPitch) ~= "number" and 0 or aimPitch
		local v5 = humanoidRootPart.CFrame.LookVector * math.cos(v4) + Vector3.new(0, 1, 0) * math.sin(v4)
		show(k, head.Position + v5 * 0.7, v5, curveOf(k), currentCamera, position, dt, now) -- inferred equivalent call
	end

	for k, bot in ScopeFeed.bots do
		if now - bot.at > 0.4 then
			ScopeFeed.bots[k] = nil
		else
			local v4 = math.cos(bot.pitch)
			local vector3 = Vector3.new(-math.sin(bot.yaw) * v4, math.sin(bot.pitch), -math.cos(bot.yaw) * v4)
			show(
				k,
				bot.pos + Vector3.new(0, 1.6, 0) + vector3 * 0.7,
				vector3,
				SniperSpecs.SNIPER_CURVE,
				currentCamera,
				position,
				dt,
				now
			)
		end
	end

	for k, v4 in v do
		if v4.used then
			continue
		end

		v4.k *= math.exp(dt * -14)
		v4.star.ImageTransparency = 1 - v4.k
		v4.fan.ImageTransparency = 1 - v4.k

		if not (v4.k < 0.02) then
			continue
		end

		v4.gui.Enabled = false
		v[k] = nil
		table.insert(v2, v4)
	end

	if next(v3) == nil and next(ScopeFeed.bots) == nil and next(v) == nil and renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end
end

task.spawn(function()
	ContentProvider:PreloadAsync({ "rbxassetid://105173936271463", "rbxassetid://106244102409684" })
end)