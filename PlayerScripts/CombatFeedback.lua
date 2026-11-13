local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Game = ReplicatedStorage:WaitForChild("Game")
local Remotes = Game:WaitForChild("Remotes")
local GameUI = script.Parent:WaitForChild("GameUI")
local Style = require(GameUI:WaitForChild("Style"))
local VoxelSound = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("VoxelSound"))
local HitPredict = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("HitPredict"))
local Viewmodel = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("Viewmodel"))

local function remote(childName: string) -- 3 equivalent calls inferred from this helper
	local remoteEvent = Remotes:WaitForChild(childName, 30)
	assert(
		remoteEvent and remoteEvent:IsA("RemoteEvent"),
		"CombatFeedback: Game.Remotes." .. childName .. " is missing"
	)
	return remoteEvent
end

local color = Color3.fromRGB(226, 52, 40)

local layer = Style.layer(PlayerGui, "CombatFeedback", 6)
local layer2 = Style.layer(PlayerGui, "CombatOverlay", 4, true)

local function sound(asset: string, volume: number, playbackSpeed: number)
	assert(playbackSpeed <= 1, "CombatFeedback: sounds are never pitched above 1.0")
	local player = nil
	return {
		play = function()
			if not player then
				local AudioGraph = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("AudioGraph"))
				local flat = AudioGraph.flat("Heartbeat" .. string.format("%.2f", playbackSpeed))
				AudioGraph.route(flat, "ui")
				flat.player.Looping = false
				flat.player.Asset = asset
				flat.player.Volume = volume
				flat.player.PlaybackSpeed = playbackSpeed
				player = flat.player
			end

			local v = player
			v:Stop()
			v.TimePosition = 0
			v:Play()
		end
	}
end

assert(true, "CombatFeedback: sounds are never pitched above 1.0")
local player = nil
local v = {}
local playbackSpeed = 0.5
local asset = "rbxassetid://9118608146"
local volume = 0.5
function v.play()
	if not player then
		local AudioGraph = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("AudioGraph"))
		local flat = AudioGraph.flat("Heartbeat" .. string.format("%.2f", playbackSpeed))
		AudioGraph.route(flat, "ui")
		flat.player.Looping = false
		flat.player.Asset = asset
		flat.player.Volume = volume
		flat.player.PlaybackSpeed = playbackSpeed
		player = flat.player
	end

	local v2 = player
	v2:Stop()
	v2.TimePosition = 0
	v2:Play()
end

assert(true, "CombatFeedback: sounds are never pitched above 1.0")
local player2 = nil
local v2 = {}
local playbackSpeed2 = 0.45
local asset2 = "rbxassetid://9118608146"
local volume2 = 0.36
function v2.play()
	if not player2 then
		local AudioGraph = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("AudioGraph"))
		local flat = AudioGraph.flat("Heartbeat" .. string.format("%.2f", playbackSpeed2))
		AudioGraph.route(flat, "ui")
		flat.player.Looping = false
		flat.player.Asset = asset2
		flat.player.Volume = volume2
		flat.player.PlaybackSpeed = playbackSpeed2
		player2 = flat.player
	end

	local v3 = player2
	v3:Stop()
	v3.TimePosition = 0
	v3:Play()
end

local v3 = {
	body = {
		len = 8,
		thick = 1.5,
		gap = 7,
		color = Style.WHITE,
		hold = 0.08,
		fade = 0.12,
		pop = 1.25
	},
	head = {
		len = 9,
		thick = 2,
		gap = 7,
		color = Style.HAZARD,
		hold = 0.14,
		fade = 0.16,
		pop = 1.35
	},
	kill = {
		len = 17,
		thick = 2,
		gap = 5,
		color = color,
		hold = 0.45,
		fade = 0.25,
		pop = 1.5
	}
}

local frame = Style.frame(layer, "HitX", UDim2.fromOffset(0, 0), UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5))
local uiScale = Instance.new("UIScale")
uiScale.Parent = frame
frame.Visible = false

local v4 = {}
local fills = {}

for i = 1, 4 do
	local fill = Style.fill(frame, "Arm" .. i, Style.WHITE, UDim2.fromOffset(8, 2), UDim2.new(), Vector2.new(0.5, 0.5))
	fill.Rotation = (i - 1) * 90 + 45
	table.insert(v4, Style.stroke(fill, 1, 0.35, nil, true))
	table.insert(fills, fill)
end

local v5 = v3.body
local v6 = -10
local v7 = -10

local function layoutMarker(data)
	for _, v8 in fills do
		local rotation = math.rad(v8.Rotation)
		local v9 = data.gap + data.len / 2
		v8.Size = UDim2.fromOffset(data.len, data.thick)
		v8.Position = UDim2.fromOffset(math.cos(rotation) * v9, math.sin(rotation) * v9)
		v8.BackgroundColor3 = data.color
	end
end

local udim = UDim2.fromScale(0.5, 0.5)
local function aimHere()
	local current = Viewmodel.current
	local currentCamera = workspace.CurrentCamera

	if not (current and currentCamera) then
		return udim
	end

	local recoilPitch = tonumber(current.recoilPitch) or 0
	local recoilYaw = tonumber(current.recoilYaw) or 0

	if recoilPitch == 0 and recoilYaw == 0 then
		return udim
	end

	local lookVector = CFrame.Angles(math.rad(recoilPitch), math.rad(recoilYaw), 0).LookVector
	local viewportSize = currentCamera.ViewportSize

	if lookVector.Z > -0.05 or viewportSize.Y <= 0 then
		return udim
	end

	local v8 = math.tan(math.rad(currentCamera.FieldOfView) / 2)
	local v9 = v8 * viewportSize.X / viewportSize.Y
	return UDim2.new(
		0.5,
		lookVector.X / -lookVector.Z / v9 * viewportSize.X / 2,
		0.5,
		-(lookVector.Y / -lookVector.Z) / v8 * viewportSize.Y / 2
	)
end

local function markerStep(_, now: number): boolean
	local v8 = now - v6

	if v5.hold + v5.fade <= v8 then
		frame.Visible = false
		return false
	end

	local backgroundTransparency = math.clamp((v8 - v5.hold) / v5.fade, 0, 1)
	frame.Position = aimHere()
	uiScale.Scale = (1 + (v5.pop - 1) * (1 - Style.easeOut(v8 / 0.07))) * Style.scale()

	for k, v9 in fills do
		v9.BackgroundTransparency = backgroundTransparency
		v4[k].Transparency = backgroundTransparency * 0.65 + 0.35
	end

	return true
end

local function showHit(flag: boolean, p: string?)
	local now = os.clock()
	local v8 = flag and "kill" or p == "head" and "head" or "body"

	if v8 == "body" and v5 == v3.kill and now - v6 < v3.kill.hold then
		return
	end

	v5 = v3[v8]
	v6 = now
	layoutMarker(v5)
	frame.Visible = true
	markerStep(0, now)
	Style.animate(frame, markerStep)

	if not flag then
		VoxelSound.ui(p == "head" and "headshot" or "hit")

		return
	end

	VoxelSound.ui(p == "head" and "headshotkill" or "kill")

	if now - v7 < 3 then
		VoxelSound.ui("multikill")
	end

	v7 = now
end

HitPredict.predicted:Connect(function()
	local now = os.clock()

	if v5 == v3.kill and now - v6 < v3.kill.hold then
		return
	end

	v5 = v3.body
	v6 = now
	layoutMarker(v5)
	frame.Visible = true
	markerStep(0, now)
	Style.animate(frame, markerStep)

	VoxelSound.ui("hit")
end)
HitPredict.confirmed:Connect(function(_: Vector3, _: number, flag: boolean, _: string, p: string?, flag2: boolean)
	if flag2 and not flag and p ~= "head" then
		return
	end

	debug.profilebegin("CF.confirmed")
	showHit(flag == true, p)
	debug.profileend()
end)

local function edge(p: string, udim2: UDim2, udim3: UDim2, vector2: Vector2, rotation: number)
	local fill = Style.fill(layer2, p, color, udim2, udim3, vector2)
	fill.BackgroundTransparency = 1
	fill.Visible = false
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Rotation = rotation
	uiGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.35, 0.65),
		NumberSequenceKeypoint.new(1, 1)
	})

	uiGradient.Parent = fill
	return fill
end

local v8 = {
	edge("Left", UDim2.fromScale(0.22, 1), UDim2.fromScale(0, 0), Vector2.zero, 0),
	edge("Right", UDim2.fromScale(0.22, 1), UDim2.fromScale(1, 0), Vector2.new(1, 0), 180),
	edge("Top", UDim2.fromScale(1, 0.26), UDim2.fromScale(0, 0), Vector2.zero, 90),
	edge("Bottom", UDim2.fromScale(1, 0.26), UDim2.fromScale(0, 1), Vector2.new(0, 1), -90)
}

local lowHealthGrade = Instance.new("ColorCorrectionEffect")
lowHealthGrade.Name = "LowHealthGrade"
lowHealthGrade.Enabled = false
lowHealthGrade.Parent = Lighting

local v9 = 0
local v10 = -10
local v11 = 0
local v12 = 0
local v13 = 0
local v14 = 1e999

local v15 = -1
local v16 = 0
local function edgeStep(p: number, p2: number): boolean
	v11 += (v12 - v11) * math.min(p * 4, 1)

	if math.abs(v12 - v11) < 0.002 then
		v11 = v12
	end

	local v17 = math.round(math.max(
		v9 * (1 - Style.easeOut((p2 - v10) / 0.5)),
		v11 * (math.sin(math.floor(p2 * 12) / 12 * (v12 * 3 + 3)) * 0.1 + 0.22)
	) * 128) / 128

	if v17 ~= v16 then
		local visible = v17 > 0

		if visible ~= (v16 > 0) then
			for _, v18 in v8 do
				v18.Visible = visible
			end
		end

		v16 = v17

		for _, v18 in v8 do
			v18.BackgroundTransparency = 1 - v17
		end
	end

	if v11 ~= v15 then
		v15 = v11
		lowHealthGrade.Enabled = v11 > 0.001
		lowHealthGrade.Saturation = v11 * -0.6
		lowHealthGrade.Contrast = v11 * 0.12
	end

	if v12 > 0 then
		if v13 <= p2 then
			v.play()
			v14 = p2 + 0.22
			v13 = p2 + (1.2 - v12 * 0.5)
		end

		if v14 <= p2 then
			v2.play()
			v14 = 1e999
		end
	end

	return v12 > 0 or v11 > 0 or p2 - v10 < 0.5
end

local function hurtFlash(p: number, p2: number)
	local now = os.clock()
	v9 = math.max(math.clamp(p / math.max(p2, 1) * 2.4, 0.12, 0.6), v9 * (1 - Style.easeOut((now - v10) / 0.5)))
	v10 = now
	Style.animate(v8, edgeStep)
end

local function setLow(p: number, flag: boolean) -- 1 equivalent call inferred from this helper
	local v17 = v12
	v12 = not (flag and p < 0.3) and 0 or (1 - p / 0.3) * 0.65 + 0.35

	if v12 > 0 and v17 == 0 then
		v13 = os.clock()
	end

	Style.animate(v8, edgeStep)
end

local frame2 = Style.frame(layer2, "Direction", UDim2.fromOffset(0, 0), UDim2.fromScale(0.5, 0.5))
Style.scaler(frame2)
local v17 = {}

for i = 1, 5 do
	local frame3 = Style.frame(frame2, "Marker" .. i, UDim2.fromOffset(0, 0), UDim2.new(), Vector2.new(0.5, 0.5))
	frame3.Visible = false
	local fill = Style.fill(
		frame3,
		"Bar",
		color,
		UDim2.fromOffset(56, 6),
		UDim2.fromOffset(0, -92),
		Vector2.new(0.5, 0.5)
	)
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.3, 0),
		NumberSequenceKeypoint.new(0.7, 0),
		NumberSequenceKeypoint.new(1, 1)
	})

	uiGradient.Parent = fill
	local fill2 = Style.fill(
		frame3,
		"Tip",
		color,
		UDim2.fromOffset(9, 9),
		UDim2.fromOffset(0, -101),
		Vector2.new(0.5, 0.5)
	)
	fill2.Rotation = 45
	Style.stroke(fill2, 1, 0.4, nil, true)
	v17[i] = {
		holder = frame3,
		bar = fill,
		tip = fill2,
		from = Vector3.new(0, 0, 0),
		t0 = 0,
		live = false,
		size = 1
	}
end

local function bearing(from: Vector3)
	local cframe = workspace.CurrentCamera.CFrame
	local vector = from - cframe.Position
	local v18 = Vector3.new(cframe.LookVector.X, 0, cframe.LookVector.Z)

	if v18.Magnitude < 0.001 then
		v18 = Vector3.new(-cframe.UpVector.X, 0, -cframe.UpVector.Z) * math.sign(cframe.LookVector.Y)
	end

	local unit = v18.Unit
	return (math.atan2(vector:Dot((Vector3.new(-unit.Z, 0, unit.X))), (vector:Dot(unit))))
end

local function dirStep(_, now: number)
	local v18 = false

	for _, v19 in v17 do
		if not v19.live then
			continue
		end

		local v20 = now - v19.t0

		if v20 >= 1.4 then
			v19.live = false
			v19.holder.Visible = false
		else
			v19.holder.Rotation = math.deg(bearing(v19.from))
			local backgroundTransparency = math.clamp((v20 - 0.8999999999999999) / 0.5, 0, 1)
			local v21 = 1 - math.clamp(v20 / 0.12, 0, 1)
			local lerped = color:Lerp(Color3.new(1, 0.85, 0.8), v21 * 0.6)
			v19.bar.BackgroundColor3 = lerped
			v19.tip.BackgroundColor3 = lerped
			v19.bar.BackgroundTransparency = backgroundTransparency
			v19.tip.BackgroundTransparency = backgroundTransparency
			v19.bar.Size = UDim2.fromOffset(v19.size * 40 + 40, v19.size * 3 + 5)
			v18 = true
		end
	end

	return v18
end

local function pointAt(from: Vector3, p: number, p2: number)
	local now = os.clock()
	local v18 = bearing(from)
	local v19 = nil

	for _, v20 in v17 do
		if
			v20.live
			and math.abs((bearing(v20.from) - v18 + 3.141592653589793) % 6.283185307179586 - 3.141592653589793) < 0.4363323129985824
		then
			v19 = v20
			break
		end
	end

	if not v19 then
		v19 = v17[1]

		for _, v20 in v17 do
			if v20.live then
				if v20.t0 < v19.t0 then
					v19 = v20
				end
			else
				v19 = v20
				break
			end
		end
	end

	local size = math.clamp(p / math.max(p2, 1) * 4, 0.2, 1)

	if v19.live then
		size = math.max(v19.size, size)
	end

	v19.size = size
	v19.from = from
	v19.t0 = now
	v19.live = true
	v19.holder.Visible = true
	dirStep(0, now)
	Style.animate(v17, dirStep)
end

local v18 = nil

remote("Damaged").OnClientEvent:Connect(function(from: Vector3?, p: number, _: string?) -- inferred equivalent call
	debug.profilebegin("CF.damaged")
	local v19 = not v18 and 100 or v18.MaxHealth
	hurtFlash(p, v19)

	if from then
		pointAt(from, p, v19)
	end

	debug.profileend()
end)

local v19 = nil

local function watch(instance)
	local humanoid = instance:WaitForChild("Humanoid", 10)
	assert(humanoid and humanoid:IsA("Humanoid"), "CombatFeedback: character has no Humanoid")
	v18 = humanoid

	if v19 then
		v19.hide()
	end

	local function update() -- 1 equivalent call inferred from this helper
		setLow(humanoid.Health / math.max(humanoid.MaxHealth, 1), humanoid.Health > 0) -- inferred equivalent call
	end
	humanoid.HealthChanged:Connect(update)
	humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(update)
	humanoid.Died:Connect(function()
		local v20 = v12
		v12 = 0

		if v12 > 0 and v20 == 0 then
			v13 = os.clock()
		end

		Style.animate(v8, edgeStep)

		for _, v21 in v17 do
			v21.live = false
			v21.holder.Visible = false
		end
	end)
	update() -- inferred equivalent call
end
LocalPlayer.CharacterAdded:Connect(watch)

if LocalPlayer.Character then
	task.spawn(watch, LocalPlayer.Character)
end

local function teamOfName(childName: string?)
	local player3 = childName and Players:FindFirstChild(childName)

	if player3 and player3:IsA("Player") and player3.Team and not player3.Neutral then
		return player3.Team.Name
	end

	return nil
end

local function weaponTag(p: string?) -- 1 equivalent call inferred from this helper
	local KillFeed = require(GameUI:WaitForChild("KillFeed"))
	return KillFeed.weapon(p)
end

local function buildNote()
	local region = Style.region(layer, "DownNote", Vector2.new(0.5, 0.5), Vector2.new(0, 120), Vector2.new(320, 64))
	local panel = Style.panel(region, "Plate", UDim2.fromOffset(0, 58))
	panel.AutomaticSize = Enum.AutomaticSize.XY
	panel.AnchorPoint = Vector2.new(0.5, 0)
	panel.Position = UDim2.fromScale(0.5, 0)
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, 14)
	uiPadding.PaddingRight = UDim.new(0, 14)
	uiPadding.PaddingTop = UDim.new(0, 6)
	uiPadding.PaddingBottom = UDim.new(0, 6)
	uiPadding.Parent = panel
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uiListLayout.Padding = UDim.new(0, 2)
	uiListLayout.Parent = panel
	local label = Style.label(panel, "Headline", "", 22, Style.FONT, 1.5)
	label.RichText = true
	label.LayoutOrder = 1
	local label2 = Style.label(panel, "Detail", "", 14, Style.FONT_BODY, 1)
	label2.RichText = true
	label2.TextColor3 = Style.MUTED
	label2.LayoutOrder = 2

	local label3 = Style.label(panel, "Dealt", "", 14, Style.FONT_BODY, 1)
	label3.RichText = true
	label3.TextColor3 = Style.MUTED
	label3.LayoutOrder = 3
	label3.Visible = false
	local fill = Style.fill(panel, "Edge", color, UDim2.new(1, 28, 0, 3), UDim2.new(0, -14, 1, 0), Vector2.new(0, 1))
	fill.LayoutOrder = 0
	local uiScale2 = Instance.new("UIScale")
	uiScale2.Parent = panel
	region.Visible = false

	local v20 = -10
	local v21 = -10
	local v22 = 0
	local text = ""

	local position = region.Position
	local udim2 = UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale, -120)
	local v23 = false
	local v24 = nil
	local v25 = nil
	local scale = -1
	local function step(_, p: number): boolean
		local v26 = LocalPlayer:GetAttribute("DownUntil") ~= nil

		if v21 <= p and not v26 then
			region.Visible = false
			return false
		end

		if v26 ~= v23 then
			v23 = v26
			local position2 = if v26 then udim2 else position
			region.Position = position2
		end

		if scale ~= 1 then
			scale = 0.9 + 0.1 * Style.easeOut((p - v20) / 0.15)
			uiScale2.Scale = scale
		end

		local v27 = math.ceil(v22 - workspace:GetServerTimeNow())
		local v28 = (v27 <= 0 or v26) and 0 or v27

		if text ~= v24 or v28 ~= v25 then
			v24 = text
			v25 = v28
			label2.Text = text
		end

		return true
	end

	local note = {}

	function note.show(p: string?, p2: string?, p3: string?, p4: number?, value: number?, p5: string?, _: boolean?, value2: number?, value3: number?)
		local v26 = weaponTag(p3) -- inferred equivalent call
		local v27 = math.floor((value2 or 0) + 0.5)
		local v28 = math.floor((value3 or 0) + 0.5)

		if v28 > 0 then
			local v29 = {}

			if p then
				table.insert(v29, "You hit them for " .. Style.paint(tostring(v27), Style.ORANGE))
			end

			if v27 < v28 or not p then
				table.insert(v29, Style.paint(tostring(v28), Style.ORANGE) .. " damage this life")
			end

			label3.Text = table.concat(v29, "  ·  ")
			label3.Visible = true
		else
			label3.Visible = false
		end

		if p then
			local v29 = Style.paint("DROPPED BY ", Style.MUTED)
			local paint = Style.paint
			local KillFeed = require(GameUI:WaitForChild("KillFeed"))
			label.Text = v29 .. paint(string.upper(KillFeed.shown(p)), Style.teamText(p2))
			local v30 = {}

			if v26 then
				table.insert(v30, v26)
			end

			if p5 == "head" then
				table.insert(v30, Style.paint("HEADSHOT", Style.HAZARD))
			end

			if p4 and p4 > 0 then
				table.insert(v30, math.floor(p4 + 0.5) .. " damage from them")
			end

			text = table.concat(v30, "  ·  ")
		else
			if v26 then
				label.Text = Style.paint("CAUGHT IN YOUR OWN ", Style.MUTED) .. Style.paint(v26, Style.ORANGE)
			else
				label.Text = Style.paint("YOU WENT DOWN", Style.MUTED)
			end

			text = ""
		end

		v20 = os.clock()
		scale = -1
		v22 = value or 0
		v21 = v20 + math.max(3, v22 - workspace:GetServerTimeNow() + 0.5)
		region.Visible = true
		step(0, v20)
		Style.animate(note, step)
	end
	function note.hide()
		v21 = -10
		region.Visible = false
	end
	return note
end

local function startSkirmish()
	v19 = buildNote()
	remote("Died").OnClientEvent:Connect(function(p: string?, p2: string?, p3: string?, p4: number?, p5: number?, p6: string?, flag: boolean?, p7: number?, p8: number?) -- inferred equivalent call
		debug.profilebegin("CF.died")
		v19.show(p, p2, p3, p4, p5, p6, flag, p7, p8)
		debug.profileend()
	end)
	local KillFeed = require(GameUI:WaitForChild("KillFeed"))
	local v20 = KillFeed.new(Style.layer(PlayerGui, "SkirmishFeed", 7))
	remote("Feed").OnClientEvent:Connect(function(p: string, ...) -- inferred equivalent call
		if p == "roll" or p == "shutdown" then
			return
		end

		debug.profilebegin("CF.feed")
		local parts, v21 = KillFeed.parts(LocalPlayer.Name, teamOfName, p, ...)
		v20.push(parts, v21)
		debug.profileend()
	end)
	local ScoreFeed = require(GameUI:WaitForChild("ScoreFeed"))
	local v21 = ScoreFeed.new(Style.layer(PlayerGui, "SkirmishPoints", 7))
	ScoreFeed.listen(v21, remote, LocalPlayer)
end

if Game:GetAttribute("Sandbox") == true then
	startSkirmish()
else
	local sandboxChangedConnection = nil
	sandboxChangedConnection = Game:GetAttributeChangedSignal("Sandbox"):Connect(function()
		if Game:GetAttribute("Sandbox") == true then
			sandboxChangedConnection:Disconnect()
			startSkirmish()
		end
	end)
end