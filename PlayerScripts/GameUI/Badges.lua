local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Style = require(script.Parent:WaitForChild("Style"))
local NewMenus = require(script.Parent:WaitForChild("NewMenus"))
local CareerData = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("CareerData"))

local Badges = { ["ON"] = nil, ["ON"] = nil, ON = NewMenus.on("Badges") }

local function ids(items)
	local result = {}

	for k, item in items do
		result[k] = "rbxassetid://" .. item
	end

	return result
end

local takedowns = {}

local v = {
	takedowns = 0,
	headshots = 0,
	support = 0,
	wrecker = 0,
	captures = 0,
	wins = 0
}

for k, v2 in {
	114690503587866,
	117943882602497,
	95709329205471,
	137983856584790,
	94129435739217,
	101137057079232,
	90835609072662,
	71976033796411,
	97749490014951,
	100961384335101
} do
	takedowns[k] = "rbxassetid://" .. v2
end

v.takedowns = takedowns
local headshots = {}

for k, v2 in {
	80395566905051,
	106801967569605,
	109865343061198,
	79375750737081,
	135583318096339,
	100592947786597
} do
	headshots[k] = "rbxassetid://" .. v2
end

v.headshots = headshots
local support = {}

for k, v2 in { 95944996571759, 124604981644320, 122514951899375, 98014846246660, 139947481948461 } do
	support[k] = "rbxassetid://" .. v2
end

v.support = support
local wrecker = {}

for k, v2 in { 135281857472362, 133291745366693, 75860557203835, 103195369115866, 85907787363820 } do
	wrecker[k] = "rbxassetid://" .. v2
end

v.wrecker = wrecker
local captures = {}

for k, v2 in { 86328856456902, 137802463972515, 128845340475311, 104975440515996, 88090216352909 } do
	captures[k] = "rbxassetid://" .. v2
end

v.captures = captures
local wins = {}

for k, v2 in { 106690846355873, 94711131670659, 98129726622272, 124926593421453, 122652075753882 } do
	wins[k] = "rbxassetid://" .. v2
end

v.wins = wins

local color = Color3.fromRGB(58, 61, 68)
local color2 = Color3.new(1, 1, 1)
local v2 = {
	{ name = "BRONZE", color = Color3.fromRGB(232, 156, 98) },
	{ name = "SILVER", color = Color3.fromRGB(214, 220, 230) },
	{ name = "GOLD", color = Color3.fromRGB(255, 206, 60) },
	{ name = "DIAMOND", color = Color3.fromRGB(130, 232, 242) },
	{ name = "LEGEND", color = Color3.fromRGB(255, 128, 104) }
}

local v3 = {
	Color3.fromRGB(170, 92, 44),
	Color3.fromRGB(104, 116, 134),
	Color3.fromRGB(206, 144, 22),
	Color3.fromRGB(30, 140, 168),
	Color3.fromRGB(190, 48, 40)
}

local v4 = {
	takedowns = Color3.fromRGB(222, 62, 48),
	headshots = Color3.fromRGB(255, 104, 96),
	support = Color3.fromRGB(112, 206, 92),
	wrecker = Color3.fromRGB(255, 150, 40),
	captures = Color3.fromRGB(64, 138, 228),
	wins = Color3.fromRGB(255, 198, 32)
}

local v5 = {
	claim = { image = "rbxassetid://98153179041297", words = Color3.fromRGB(255, 255, 255) },
	off = { image = "rbxassetid://116067232788719", words = Color3.fromRGB(176, 178, 184) }
}

Color3.fromRGB(34, 36, 42)
Color3.fromRGB(34, 36, 42)

local color3 = Color3.fromRGB(20, 21, 25)
local color4 = Color3.fromRGB(255, 226, 90)

function Badges.rank(p, p2: number)
	return (math.clamp(math.ceil(p2 / #p.goals * #v2), 1, #v2))
end

function Badges.medal(p, p2: number)
	local v6 = v[p.id]
	assert(v6 and v6[p2], "[Badges] no badge picture for " .. tostring(p.id) .. " tier " .. tostring(p2))
	return v6[p2]
end

local function text(p, p2: string, p3: string, p4: number, p5: number, p6: number, p7: number, p8: number, options)
	local v6 = options or {}
	local label = Style.label(p, p2, p3, p4, v6.font or Style.FONT, v6.outline or 0)
	label.AutomaticSize = Enum.AutomaticSize.None
	label.Position = UDim2.fromOffset(p5, p6)
	label.Size = UDim2.fromOffset(p7, p8)
	label.TextXAlignment = v6.ax or Enum.TextXAlignment.Left
	label.TextYAlignment = v6.ay or Enum.TextYAlignment.Center
	label.TextColor3 = v6.color or Style.WHITE
	label.TextWrapped = v6.wrap == true
	local textTruncate

	if v6.wrap then
		textTruncate = Enum.TextTruncate.None
	else
		textTruncate = Enum.TextTruncate.AtEnd
	end

	label.TextTruncate = textTruncate
	local uiStroke = label:FindFirstChildOfClass("UIStroke")

	if uiStroke then
		uiStroke.LineJoinMode = Enum.LineJoinMode.Round
	end

	return label
end

local function feel(parent, p: number, callback)
	local punch = Instance.new("UIScale")
	punch.Name = "Punch"
	punch.Parent = parent
	local v6 = 1
	local function go(scale: number, duration: number, p2)
		TweenService:Create(punch, TweenInfo.new(duration, p2, Enum.EasingDirection.Out), {
			Scale = scale
		}):Play()
	end

	if not Style.isTouch() then
		local fill = Style.fill(parent, "Hover", Style.WHITE, UDim2.fromScale(1, 1))
		fill.BackgroundTransparency = 1
		fill.ZIndex = 8
		Style.corner(fill, p)
		parent.MouseEnter:Connect(function()
			if callback and not callback() then
				return
			end

			v6 = callback and 1.04 or 1.08
			fill.BackgroundTransparency = callback and 0.82 or 0.9
			go(v6, 0.1, Enum.EasingStyle.Quad)
		end)
		parent.MouseLeave:Connect(function()
			v6 = 1
			fill.BackgroundTransparency = 1
			go(v6, 0.1, Enum.EasingStyle.Quad)
		end)
	end

	parent.InputBegan:Connect(function(input)
		local userInputType = input.UserInputType

		if
			(userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.Touch)
			and (not callback or callback())
		then
			go(0.93, 0.07, Enum.EasingStyle.Quad)
		end
	end)
	parent.InputEnded:Connect(function(input)
		local userInputType = input.UserInputType

		if userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.Touch then
			go(v6, 0.24, Enum.EasingStyle.Back)
		end
	end)
end

function Badges.build(p, callback, onActivated)
	assert(Badges.ON, "[Badges] built while its NewMenus switch is off")
	local total = 0

	for _, v6 in CareerData.TRACKS do
		assert(
			v[v6.id] and #v[v6.id] == #v6.goals,
			"[Badges] a badge picture per tier is needed for track " .. tostring(v6.id)
		)
		total += #v6.goals
	end

	local touch = Style.isTouch()

	local layer = Style.layer(p.playerGui, "BadgesBackdrop", 10, true)
	layer.Enabled = false
	local layer2 = Style.layer(p.playerGui, "BadgesWindow", 11)
	layer2.Enabled = false
	local v6 = touch and 1 or 1.3

	local function S(p2: number)
		return (math.floor(p2 * v6))
	end

	local room = Instance.new("ImageLabel")
	room.Name = "Room"
	room.BorderSizePixel = 0
	room.BackgroundColor3 = Style.INK
	room.ScaleType = Enum.ScaleType.Crop
	room.Size = UDim2.fromScale(1, 1)
	room.Active = true
	room.Parent = layer
	local fill = Style.fill(room, "Ink", Style.INK, UDim2.fromScale(1, 1))
	fill.BackgroundTransparency = 0.75
	local v7 = touch and 540 or 700
	local viewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(16, 9)
	local v8 = math.floor(v7 * math.clamp(viewportSize.X / math.max(viewportSize.Y, 1), 1.6, 2.2))
	local region = Style.region(layer2, "Badges", Vector2.new(0.5, 0.5), Vector2.zero, Vector2.new(v8, v7))
	region.Visible = false
	Style.fit(region, Vector2.new(v8, v7), 0.98)
	local modal = Instance.new("TextButton")
	modal.Name = "Modal"
	modal.Text = ""
	modal.BackgroundTransparency = 1
	modal.Size = UDim2.fromOffset(1, 1)
	modal.Modal = true
	modal.Selectable = false
	modal.Parent = region
	local frame = Style.frame(region, "Body", UDim2.fromScale(1, 1))

	local label = Style.label(frame, "Title", "BADGES", 44, Style.FONT, 2.5)
	label.TextColor3 = Style.HAZARD
	label.Position = UDim2.fromOffset(16, 4)
	local v9 = text(frame, "Earned", "", math.floor(v6 * 16), 226, 10, 260, 44, { outline = 2 })
	v9.RichText = true

	local v10 = Style.closeButton(nil)
	v10.AnchorPoint = Vector2.new(0.5, 0.5)
	v10.Position = UDim2.new(1, -38, 0, 32)
	v10.Parent = frame
	v10.Activated:Connect(onActivated)
	feel(v10, 4)
	local hover = v10:FindFirstChild("Hover")

	if hover and hover:IsA("GuiObject") then
		hover.Visible = false
	end

	local box = Style.box(frame, "Scrap", Style.INK, UDim2.fromOffset(0, 44), 6, 1.5)
	box.AutomaticSize = Enum.AutomaticSize.X
	box.AnchorPoint = Vector2.new(1, 0)
	box.Position = UDim2.new(1, -70, 0, 10)

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.Padding = UDim.new(0, 7)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = box
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, 10)
	uiPadding.PaddingRight = UDim.new(0, 14)
	uiPadding.Parent = box

	local uiScale = Instance.new("UIScale")
	uiScale.Parent = box
	local nut_2 = Style.nut(box, 26)
	nut_2.LayoutOrder = 1
	local label2 = Style.label(box, "Amount", "0", 24, Style.FONT, 0)
	label2.TextColor3 = Style.HAZARD
	label2.LayoutOrder = 2
	local label3 = Style.label(frame, "Toast", "", math.floor(v6 * 16), Style.FONT, 2)
	label3.AnchorPoint = Vector2.new(0.5, 0)
	label3.Position = UDim2.new(0.5, 0, 0, 58)
	label3.ZIndex = 9
	label3.Visible = false

	local v11 = v7 - 64 - 16

	local v12 = math.floor((v8 - 32 - 14) * 0.36)
	local v13 = v8 - 32 - 14 - v12
	local v14 = v13 + 16 + 14

	local v15 = {}
	local v16 = {}
	local function have(p2) -- 5 equivalent calls inferred from this helper
		local v17 = v15[p2.stat]
		return if type(v17) == "number" then v17 else 0
	end

	local function isClaimed(p2, p3: number): boolean -- 3 equivalent calls inferred from this helper
		return table.find(v16, CareerData.badgeId(p2, p3)) ~= nil
	end

	local function isReady(p2, p3: number): boolean -- 5 equivalent calls inferred from this helper
		return have(p2) >= p2.goals[p3] and not isClaimed(p2, p3) -- inferred equivalent call
	end

	local v17 = nil
	local v18 = 0
	local fn
	local nowsByBadgeId = {}
	local claim = nil

	local v19 = v13 - 6 - 16

	local v20 = (v19 - 24 - 32) // 5
	assert(v20 >= 88, "[Badges] the medal tiles are too small for this window")
	local v21 = math.floor(v6 * 22)
	local v22 = math.floor(v6 * 18)
	local v23 = math.floor(v6 * 14)

	local v24 = v23 + 4
	local v25 = math.max(12, (math.floor(v6 * 11)))
	local v26 = v21 + 8 + 4
	local v27 = v26 + v22 + 8
	local v28 = math.floor(v20 * 0.64)

	local tracks = Instance.new("ScrollingFrame")
	tracks.Name = "Tracks"
	tracks.BackgroundTransparency = 1
	tracks.BorderSizePixel = 0
	tracks.Position = UDim2.fromOffset(16, 64)
	tracks.Size = UDim2.fromOffset(v13, v11)
	tracks.ScrollingDirection = Enum.ScrollingDirection.Y
	tracks.ScrollBarThickness = 6
	tracks.ScrollBarImageColor3 = Style.HAZARD
	tracks.Selectable = false
	tracks.Parent = frame

	local v29 = {}

	local function select(p2, p3: number)
		local v30 = v17 ~= p2 or v18 ~= p3
		v17 = p2
		v18 = p3

		for _, v31 in v29 do
			for k, pip in v31.pips do
				local v32

				if v31.track == p2 then
					v32 = k == p3
				else
					v32 = false
				end

				local stroke = pip.stroke
				local color5 = if v32 then Style.HAZARD else Style.INK
				stroke.Color = color5
				pip.stroke.Thickness = v32 and 4 or 3
			end
		end

		fn(v30)
	end

	local function claim2(p2, p3: number)
		local badgeId = CareerData.badgeId(p2, p3)
		local v30 = nowsByBadgeId[badgeId]

		if isReady(p2, p3) and not (v30 and os.clock() - v30 < 4) then -- inferred equivalent call
			nowsByBadgeId[badgeId] = os.clock()
			callback(badgeId, claim)
		end
	end

	local total2 = 8
	local v30 = false

	for k, track in CareerData.TRACKS do
		local v31 = v4[track.id] or Style.STEEL_LIGHT
		local count = #track.goals
		local v32 = (count + 5 - 1) // 5
		local v40 = v27 + v32 * v20 + (v32 - 1) * 8 + 12
		local frame2 = Style.frame(tracks, track.id, UDim2.fromOffset(v19, v40))
		local udim = UDim2.fromOffset(8, total2)
		total2 += v40 + 10
		frame2.Position = udim
		text(frame2, "Name", track.name, math.floor(v6 * 21), 12, 6, v19 // 2, v21 + 4, {
			outline = 2.5,
			color = v31:Lerp(Style.WHITE, 0.45)
		})
		local lifetime = text(frame2, "Lifetime", "", math.floor(v6 * 13), v19 // 2, 8, v19 - v19 // 2 - 12, v21, {
			ax = Enum.TextXAlignment.Right,
			outline = 1.5
		})
		local v42 = math.floor(v6 * 130)

		local fill2 = Style.fill(
			frame2,
			"Bar",
			color3,
			UDim2.fromOffset(v19 - 24 - v42 - 8, 8),
			UDim2.fromOffset(12, v26 + (v22 - 8) // 2)
		)
		Style.corner(fill2, 4)
		Style.stroke(fill2, 1, 0, Style.INK, true)
		local fill3 = Style.fill(fill2, "Fill", v31, UDim2.fromScale(0, 1))
		Style.corner(fill3, 4)
		local count2 = text(frame2, "Count", "", math.floor(v6 * 13), v19 - 12 - v42, v26, v42, v22, {
			ax = Enum.TextXAlignment.Right,
			outline = 1.5
		})
		local pips = {}

		for i = 1, count do
			local imageButton = Instance.new("ImageButton")
			imageButton.Name = "Tier" .. i
			imageButton.AutoButtonColor = false
			imageButton.BorderSizePixel = 0
			imageButton.BackgroundColor3 = Style.INK
			imageButton.Image = "rbxassetid://103486403003468"
			imageButton.ImageColor3 = color
			imageButton.AnchorPoint = Vector2.new(0.5, 0.5)
			imageButton.Size = UDim2.fromOffset(v20, v20)
			imageButton.Position = UDim2.fromOffset(
				(i - 1) % 5 * (v20 + 8) + 12 + v20 // 2,
				v27 + (i - 1) // 5 * (v20 + 8) + v20 // 2
			)
			imageButton.Parent = frame2
			Style.corner(imageButton, 0)
			local stroke = Style.stroke(imageButton, 3, 0, Style.INK, true)
			local medal = Instance.new("ImageLabel")
			medal.Name = "Medal"
			medal.BackgroundTransparency = 1
			medal.ScaleType = Enum.ScaleType.Fit
			medal.AnchorPoint = Vector2.new(0.5, 0)
			medal.Size = UDim2.fromOffset(v28, v28)
			medal.Position = UDim2.fromOffset(v20 // 2, (math.floor(v20 * 0.06)))
			medal.Parent = imageButton
			local roman = text(imageButton, "Roman", CareerData.NUMERALS[i], v25, 8, 5, v20 // 2, v25 + 4, {
				color = Style.MUTED,
				outline = 1.5
			})
			roman.TextTruncate = Enum.TextTruncate.None

			local numeral = text(
				imageButton,
				"Goal",
				Style.thousands(track.goals[i]),
				v23,
				0,
				v20 - v24 - 11,
				v20,
				v24,
				{ ax = Enum.TextXAlignment.Center, color = Style.MUTED, outline = 2 }
			)
			numeral.TextTruncate = Enum.TextTruncate.None
			local fill4 = Style.fill(
				imageButton,
				"Bar",
				color3,
				UDim2.fromOffset(v20 - 20, 5),
				UDim2.fromOffset(10, v20 - 10)
			)
			fill4.Visible = false
			Style.corner(fill4, 3)
			local fill5 = Style.fill(fill4, "Fill", v31, UDim2.fromScale(0, 1))
			Style.corner(fill5, 3)
			local fill6 = Style.fill(
				imageButton,
				"ClaimMark",
				Style.HAZARD,
				UDim2.fromOffset(13, 13),
				UDim2.new(1, -13, 0, 13),
				Vector2.new(0.5, 0.5)
			)
			fill6.Rotation = 45
			fill6.Visible = false
			Style.stroke(fill6, 1.5, 0, Style.INK, true)
			local v49 = math.floor(v20 * 0.3)
			local claimed = Instance.new("ImageLabel")
			claimed.Name = "Claimed"
			claimed.BackgroundTransparency = 1
			claimed.Image = "rbxassetid://99834261274361"
			claimed.ScaleType = Enum.ScaleType.Fit
			claimed.AnchorPoint = Vector2.new(1, 0)
			claimed.Size = UDim2.fromOffset(v49, v49)
			claimed.Position = UDim2.new(1, -3, 0, 3)
			claimed.ZIndex = 2
			claimed.Visible = false
			claimed.Parent = imageButton
			feel(imageButton, 0)
			pips[i] = {
				button = imageButton,
				image = medal,
				stroke = stroke,
				numeral = numeral,
				roman = roman,
				mark = fill6,
				tick = claimed,
				bar = fill4,
				barFill = fill5,
				beat = TweenService:Create(
					imageButton,
					TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
					{ ImageColor3 = color4 }
				),
				look = "",
				base = color
			}
			local v50 = i
			imageButton.Activated:Connect(function()
				if v17 == track and v18 == v50 and isReady(track, v50) then -- inferred equivalent call
					claim2(track, v50)
					return
				end

				select(track, v50)
			end)
			local v51 = i
			imageButton.SelectionGained:Connect(function()
				if v17 ~= track or v18 ~= v51 then
					select(track, v51)
				end
			end)
		end

		v29[k] = {
			track = track,
			frame = frame2,
			home = udim,
			lifetime = lifetime,
			count = count2,
			fill = fill3,
			pips = pips
		}
	end

	tracks.CanvasSize = UDim2.fromOffset(0, total2 - 10 + 8)

	local box2 = Style.box(frame, "Stage", Style.INK, UDim2.fromOffset(v12, v11), 4, 3)
	box2.Position = UDim2.fromOffset(v14, 64)
	box2.ClipsDescendants = true

	local v31 = math.max(v12, v11)
	local scene = Instance.new("ImageLabel")
	scene.Name = "Scene"
	scene.BackgroundTransparency = 1
	scene.ScaleType = Enum.ScaleType.Stretch
	scene.Size = UDim2.fromOffset(v31, v31)
	scene.Position = UDim2.fromOffset(math.floor((v12 - v31) / 2), 0)
	scene.Parent = box2
	local v32 = math.floor(v31 * 0.4)
	local v39 = math.floor(v31 * 0.36)

	local frame2 = Style.frame(box2, "Award", UDim2.fromScale(1, 1))
	local fill2 = Style.fill(
		frame2,
		"Glow",
		Style.WHITE,
		UDim2.fromOffset(v32 - 10, v32 - 10),
		UDim2.fromOffset(v12 // 2, v39),
		Vector2.new(0.5, 0.5)
	)
	fill2.BackgroundTransparency = 0.92
	local halo = Instance.new("ImageLabel")
	halo.Name = "Halo"
	halo.BackgroundTransparency = 1
	halo.Image = "rbxassetid://133718950618586"
	halo.AnchorPoint = Vector2.new(0.5, 0.5)
	halo.Position = UDim2.fromOffset(v12 // 2, v39)
	halo.Size = UDim2.fromOffset(math.floor(v32 * 1.5), (math.floor(v32 * 1.5)))
	halo.Parent = frame2
	local v40 = math.floor(v32 * 0.84)
	local frame3 = Style.frame(
		frame2,
		"Mark",
		UDim2.fromOffset(v40, v40),
		UDim2.fromOffset(v12 // 2, v39),
		Vector2.new(0.5, 0.5)
	)
	frame3.ZIndex = 2
	local medal = Instance.new("ImageLabel")
	medal.Name = "Medal"
	medal.BackgroundTransparency = 1
	medal.ScaleType = Enum.ScaleType.Fit
	medal.Size = UDim2.fromScale(1, 1)
	medal.ZIndex = 2
	medal.Parent = frame3
	local uiScale2 = Instance.new("UIScale")
	uiScale2.Parent = medal
	local v41 = text(frame2, "Rank", "", math.floor(v6 * 15), 14, 10, v12 // 2, math.floor(v6 * 15) + 6, {
		outline = 2
	})
	v41.ZIndex = 3
	local v42 = text(
		frame2,
		"Tier",
		"",
		math.floor(v6 * 13),
		v12 // 2,
		10,
		v12 - v12 // 2 - 14,
		math.floor(v6 * 15) + 6,
		{ ax = Enum.TextXAlignment.Right, color = Style.MUTED, outline = 2 }
	)
	v42.ZIndex = 3
	local v43 = touch and 52 or 60
	local v44 = math.min(v12 - 28, v43 * 5)
	local v45 = v11 - v43 - 12
	local v46 = v39 + v32 // 2

	local v47 = v45 - v46
	local v48 = math.floor(v6 * 22) + 4
	local v49 = math.floor(v6 * 14) + 4
	local v50 = math.floor(v6 * 26) + 2
	local v51 = math.floor(v6 * 15) + 4

	local v52 = math.max(2, (v47 - v48 - v49 - v50 - 10 - v51) // 6)
	local v53 = v46 + v52
	local v54 = v53 + v48 + v52
	local v55 = v54 + v49 + v52
	local v56 = v55 + v50 + v52
	local v57 = v56 + 10 + v52
	local v58 = text(frame2, "Name", "", math.floor(v6 * 22), 14, v53, v12 - 28, v48, {
		ax = Enum.TextXAlignment.Center,
		outline = 2
	})
	v58.ZIndex = 3
	local v59 = text(frame2, "What", "", math.floor(v6 * 14), 14, v54, v12 - 28, v49, {
		ax = Enum.TextXAlignment.Center,
		outline = 2
	})
	v59.ZIndex = 3
	local frame4 = Style.frame(frame2, "Pays", UDim2.fromOffset(v12, v50), UDim2.fromOffset(0, v55))
	frame4.ZIndex = 3
	local nut = Style.nut(frame4, (math.floor(v6 * 22)))
	nut.AnchorPoint = Vector2.new(1, 0.5)
	nut.Position = UDim2.fromOffset(v12 // 2 - 6, v50 // 2)
	nut.ZIndex = 3
	local v60 = text(frame4, "Amount", "", math.floor(v6 * 26), v12 // 2, 0, v12 // 2 - 14, v50, {
		color = Style.HAZARD,
		outline = 2
	})
	v60.ZIndex = 3
	local v61 = math.min(v12 - 28, 340)
	local fill3 = Style.fill(
		frame2,
		"Progress",
		color3,
		UDim2.fromOffset(v61, 10),
		UDim2.fromOffset((v12 - v61) // 2, v56)
	)
	fill3.ZIndex = 3
	Style.corner(fill3, 5)
	Style.stroke(fill3, 1.5, 0, Style.INK, true)
	local fill4 = Style.fill(fill3, "Fill", Style.HAZARD, UDim2.fromScale(0, 1))
	fill4.ZIndex = 3
	Style.corner(fill4, 5)
	local v62 = text(frame2, "State", "", math.floor(v6 * 15), 14, v57, v12 - 28, v51, {
		ax = Enum.TextXAlignment.Center,
		outline = 2
	})
	v62.ZIndex = 3
	claim = Instance.new("ImageButton")
	claim.Name = "Claim"
	claim.AutoButtonColor = false
	claim.BackgroundTransparency = 1
	claim.ScaleType = Enum.ScaleType.Stretch
	claim.AnchorPoint = Vector2.new(0.5, 0.5)
	claim.Size = UDim2.fromOffset(v44, v43)
	claim.Position = UDim2.fromOffset(v12 // 2, v45 + v43 // 2)
	claim.ZIndex = 4
	claim.Selectable = false
	claim.Parent = frame2
	local v63 = false
	feel(claim, 10, function()
		return v63
	end)

	local hover2 = claim:FindFirstChild("Hover")

	if hover2 and hover2:IsA("GuiObject") then
		hover2.Visible = false
	end

	local v64 = claim
	local v65 = text(v64, "Text", "", math.floor(v6 * 24), 0, 0, v44, v43, {
		ax = Enum.TextXAlignment.Center,
		outline = 2
	})
	v65.ZIndex = 5
	claim.Activated:Connect(function()
		if v17 then
			claim2(v17, v18)
		end
	end)
	local punch = claim:FindFirstChild("Punch")
	local v66 = nil

	fn = function(flag: boolean)
		local v67 = v17
		local v68 = v18

		if not v67 then
			return
		end

		local v69 = v2[Badges.rank(v67, v68)]
		local goal = v67.goals[v68]
		local v70 = have(v67) -- inferred equivalent call
		local claimed = isClaimed(v67, v68) -- inferred equivalent call
		local ready = isReady(v67, v68) -- inferred equivalent call
		local v71 = claimed or ready
		medal.Image = Badges.medal(v67, v68)
		medal.ImageColor3 = Color3.new(1, 1, 1)
		halo.ImageColor3 = v69.color
		halo.ImageTransparency = v71 and 0.3 or 0.62

		if flag and v30 then
			uiScale2.Scale = 0.8
			TweenService:Create(uiScale2, TweenInfo.new(0.26, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Scale = 1
			}):Play()
		end

		fill2.BackgroundColor3 = v69.color
		fill2.BackgroundTransparency = v71 and 0.84 or 0.93
		v41.Text = v69.name
		v41.TextColor3 = v69.color
		v42.Text = string.format("TIER %d / %d", v68, #v67.goals)
		v58.Text = v67.name .. " " .. CareerData.NUMERALS[v68]
		v59.Text = string.format(v67.what, Style.thousands(goal))
		v60.Text = "+" .. Style.thousands(v67.scrap[v68])
		fill4.Size = UDim2.fromScale(math.clamp(v70 / goal, 0, 1), 1)
		local backgroundColor

		if claimed then
			backgroundColor = Style.GOOD
		else
			backgroundColor = Style.HAZARD
		end

		fill4.BackgroundColor3 = backgroundColor
		v62.Text = claimed and "EARNED"
			or ready and "READY"
			or string.format("%s / %s", Style.thousands((math.floor(v70))), Style.thousands(goal))
		local textColor

		if claimed then
			textColor = Style.GOOD
		else
			textColor = if ready then Style.HAZARD else Style.WHITE
		end

		v62.TextColor3 = textColor

		v63 = ready
		local v74 = if ready then v5.claim else v5.off
		claim.Image = v74.image
		v65.Text = ready and "CLAIM"
			or claimed and "EARNED"
			or string.format("%s MORE", Style.thousands((math.max(1, (math.ceil(goal - v70))))))
		local textColor2 = if claimed then Style.GOOD else v74.words
		v65.TextColor3 = textColor2
		local v76 = ready and v30

		if v76 and not v66 then
			v66 = TweenService:Create(
				punch,
				TweenInfo.new(0.55, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
				{ Scale = 1.05 }
			)
			v66:Play()
		elseif not v76 and v66 then
			v66:Cancel()
			v66 = nil
			punch.Scale = 1
		end
	end

	local function paint(flag: boolean)
		local count = 0

		for k, v67 in v29 do
			local track = v67.track
			local v68 = have(track) -- inferred equivalent call
			local v69 = nil

			for k2, pip in v67.pips do
				local claimed = isClaimed(track, k2) -- inferred equivalent call
				local ready = isReady(track, k2) -- inferred equivalent call

				if claimed then
					count += 1
				end

				if not (claimed or ready) then
					v69 = v69 or k2
				end

				local look = claimed and "earned" or ready and "ready" or "far"

				if pip.look ~= look then
					pip.look = look
					pip.image.Image = Badges.medal(track, k2)
					local image = pip.image
					local imageColor

					if look == "far" then
						imageColor = color2
					else
						imageColor = Color3.new(1, 1, 1)
					end

					image.ImageColor3 = imageColor
					local base

					if look == "far" then
						base = v3[Badges.rank(track, k2)]:Lerp(Style.INK, 0.58)
					else
						base = v3[Badges.rank(track, k2)]
					end

					pip.base = base
					pip.numeral.Text = look == "ready" and "CLAIM" or Style.thousands(track.goals[k2])
					local numeral = pip.numeral
					local textColor

					if look == "ready" then
						textColor = Style.HAZARD
					elseif look == "earned" then
						textColor = Style.WHITE
					else
						textColor = Style.MUTED
					end

					numeral.TextColor3 = textColor
					local roman = pip.roman
					local textColor2

					if look == "far" then
						textColor2 = Style.MUTED
					else
						textColor2 = Style.WHITE
					end

					roman.TextColor3 = textColor2
					pip.tick.Visible = look == "earned"
					pip.mark.Visible = look == "ready"
					pip.beat:Cancel()
					pip.button.ImageColor3 = pip.base
				end

				if look == "ready" and v30 and pip.beat.PlaybackState ~= Enum.PlaybackState.Playing then
					pip.beat:Play()
				end
			end

			v67.lifetime.Text = "LIFETIME " .. Style.thousands((math.floor(v68)))
			local v70

			if v69 then
				local goal = track.goals[v69]
				v67.count.Text = string.format("%s / %s", Style.thousands((math.floor(v68))), Style.thousands(goal))
				v67.count.TextColor3 = Style.WHITE
				v70 = math.clamp(v68 / goal, 0, 1)
			else
				v67.count.Text = "COMPLETE"
				v67.count.TextColor3 = Style.GOOD
				v70 = 1
			end

			for k2, pip in v67.pips do
				local visible = k2 == v69

				if pip.bar.Visible ~= visible then
					pip.bar.Visible = visible
				end

				if visible then
					pip.barFill.Size = UDim2.fromScale(v70, 1)
				end
			end

			if flag then
				v67.fill.Size = UDim2.fromScale(0, 1)
				local tweenInfo = TweenInfo.new(
					0.45,
					Enum.EasingStyle.Quad,
					Enum.EasingDirection.Out,
					0,
					false,
					(k - 1) * 0.045
				)
				TweenService:Create(v67.fill, tweenInfo, { Size = UDim2.fromScale(v70, 1) }):Play()
			else
				v67.fill.Size = UDim2.fromScale(v70, 1)
			end
		end

		v9.Text = "EARNED  " .. Style.paint(string.format("%d / %d", count, total), Style.HAZARD)
	end

	local function firstPick()
		for _, v67 in v29 do
			for i = 1, #v67.track.goals do
				if isReady(v67.track, i) then -- inferred equivalent call
					return v67.track, i
				end
			end
		end

		local track = v29[1].track

		for i = 1, #track.goals do
			if have(track) < track.goals[i] then -- inferred equivalent call
				return track, i
			end
		end

		return track, #track.goals
	end

	local v67 = ""
	local v68 = false
	local function refresh(p2)
		v15 = (type(p2) ~= "table" or type(p2.stats) ~= "table") and {} or p2.stats
		v16 = (type(p2) ~= "table" or type(p2.claimed) ~= "table") and {} or p2.claimed
		local v69 = { (tostring(#v16)) }

		for _, v70 in v29 do
			table.insert(v69, (tostring((math.floor(have(v70.track)))))) -- inferred equivalent call
		end

		local joined = table.concat(v69, ",")

		if joined == v67 and not v68 then
			return
		end

		v67 = joined
		local v70 = v68
		v68 = false
		paint(v70)

		if not v70 and v17 then
			fn(false)

			return
		end

		local v71, v72 = firstPick()
		v17 = nil
		v18 = 0
		select(v71, v72)
	end

	local count = 0
	local tweens = {}
	local position = frame.Position
	local v69 = false
	return {
		root = region,
		pop = function(_: number) end,
		scrap = label2,
		scrapPop = uiScale,
		toast = label3,
		refresh = refresh,
		show = function(flag: boolean)
			v30 = flag
			count += 1
			local v70 = count

			for _, v71 in tweens do
				v71:Cancel()
			end

			table.clear(tweens)
			local function tween(instance, duration: number, p2, p3, goal, value: number?) -- 6 equivalent calls inferred from this helper
				local tween2 = TweenService:Create(
					instance,
					TweenInfo.new(duration, p2, p3, 0, false, value or 0),
					goal
				)
				table.insert(tweens, tween2)
				tween2:Play()
				return tween2
			end

			if flag then
				if not v69 then
					v69 = true
					room.Image = "rbxassetid://111275713745161"
					scene.Image = "rbxassetid://110500161636907"
				end

				if not layer.Enabled then
					room.ImageTransparency = 1
					room.BackgroundTransparency = 1
					fill.BackgroundTransparency = 1
				end

				frame.Position = position + UDim2.fromScale(0, 0.22)
				layer.Enabled = true
				layer2.Enabled = true
				v68 = true
				tracks.CanvasPosition = Vector2.zero

				for k, v71 in v29 do
					v71.frame.Position = v71.home + UDim2.fromOffset(26, 0)
					tween( -- inferred equivalent call
						v71.frame,
						0.22,
						Enum.EasingStyle.Quad,
						Enum.EasingDirection.Out,
						{ Position = v71.home },
						(k - 1) * 0.045
					)
				end

				tween(room, 0.256, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, { -- inferred equivalent call
					ImageTransparency = 0,
					BackgroundTransparency = 0
				})
				tween(fill, 0.256, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, { -- inferred equivalent call
					BackgroundTransparency = 0.75
				})
				tween(frame, 0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, { -- inferred equivalent call
					Position = position
				})
			else
				layer2.Enabled = false

				for _, v71 in v29 do
					v71.frame.Position = v71.home

					for _, pip in v71.pips do
						pip.beat:Cancel()
						pip.button.ImageColor3 = pip.base
					end
				end

				if v66 then
					v66:Cancel()
					v66 = nil
					punch.Scale = 1
				end

				tween(room, 0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.In, { -- inferred equivalent call
					ImageTransparency = 1,
					BackgroundTransparency = 1
				})
				tween(fill, 0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.In, { -- inferred equivalent call
					BackgroundTransparency = 1
				}).Completed:Once(function()
					if count == v70 then
						layer.Enabled = false
					end
				end)
			end
		end
	}
end

return Badges