local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Viewmodel = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("Viewmodel"))
local Style = require(script.Parent:WaitForChild("Style"))
local PadMenus = require(script.Parent:WaitForChild("PadMenus"))
local Armory = require(script.Parent:WaitForChild("Armory"))
local PurchaseShow = require(script.Parent:WaitForChild("PurchaseShow"))
local GiftOpen = require(script.Parent:WaitForChild("GiftOpen"))
local ArmoryStore = require(script.Parent:WaitForChild("ArmoryStore"))
require(script.Parent:WaitForChild("StreakIcon"))
local CareerData = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("CareerData"))
local WeaponSkins = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("WeaponSkins"))
local ShopData = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("ShopData"))
local ClaimAudio = require(script.Parent:WaitForChild("ClaimAudio"))
local ClaimFx = require(script.Parent:WaitForChild("ClaimFx"))
local Leaderboards = require(script.Parent:WaitForChild("Leaderboards"))
local LobbyFeatured = require(script.Parent:WaitForChild("LobbyFeatured"))
local Rewards = require(script.Parent:WaitForChild("Rewards"))
local Badges = require(script.Parent:WaitForChild("Badges"))

local vector2 = Vector2.new(700, 450)

local color = Color3.fromRGB(38, 40, 45)
local color2 = Color3.fromRGB(26, 27, 31)
local color3 = Color3.fromRGB(214, 164, 58)
local color4 = Color3.fromRGB(255, 226, 170)

local function list(parent, p: number, flag: boolean?)
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.Padding = UDim.new(0, p)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	local fillDirection

	if flag then
		fillDirection = Enum.FillDirection.Horizontal
	else
		fillDirection = Enum.FillDirection.Vertical
	end

	uiListLayout.FillDirection = fillDirection

	if flag then
		uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	end

	uiListLayout.Parent = parent
	return uiListLayout
end

local function body(box, p: string, p2: string, p3: number, color5: Color3?) -- 1 equivalent call inferred from this helper
	local label = Style.label(box, p, p2, p3, Style.FONT_BODY, 0)
	label.TextColor3 = color5 or Style.MUTED
	return label
end

local function bar(p, udim: UDim2, position: UDim2)
	local box = Style.box(p, "Bar", color2, udim, 2, 1)
	box.Position = position
	local fill = Style.fill(box, "Fill", Style.HAZARD, UDim2.fromScale(0, 1))
	Style.corner(fill, 2)
	return box, function(value: number, backgroundColor: Color3)
		fill.Size = UDim2.fromScale(math.clamp(value, 0, 1), 1)
		fill.BackgroundColor3 = backgroundColor
	end
end

local function scrollArea(parent, position: UDim2, size: UDim2) -- 2 equivalent calls inferred from this helper
	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "Scroll"
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.Position = position
	scroll.Size = size
	scroll.ScrollBarThickness = 6
	scroll.ScrollBarImageColor3 = Style.HAZARD
	scroll.CanvasSize = UDim2.new()
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.Parent = parent
	return scroll
end

local function window(menu, p: string, p2: string, vector2_2: Vector2?, flag: boolean?)
	local v = vector2_2 or Vector2.new(880, 540)
	local region = Style.region(menu, "Lobby" .. p2, Vector2.new(0.5, 0.5), Vector2.zero, v)
	region.Visible = false
	local fit = Style.fit(region, v)
	local modal = Instance.new("TextButton")
	modal.Name = "Modal"
	modal.Text = ""
	modal.BackgroundTransparency = 1
	modal.Size = UDim2.fromOffset(1, 1)
	modal.Modal = true
	modal.Parent = region
	local box = Style.box(region, "Body", Style.PANEL, UDim2.fromScale(1, 1), 3, 3)
	box.BackgroundTransparency = 0.04
	box.Active = true
	local fill = Style.fill(box, "Header", Style.STEEL, UDim2.new(1, 0, 0, 64))
	Style.tape(fill, "Tape", UDim2.new(1, 0, 0, 8), v.X, 16)

	if not flag then
		local label = Style.label(fill, "Kicker", p, 13, Style.FONT, 0)
		label.TextColor3 = Style.MUTED
		label.Position = UDim2.fromOffset(16, 12)
	end

	local label_2 = Style.label(fill, "Title", p2, 28, Style.FONT, 1.5)
	label_2.Position = UDim2.fromOffset(16, flag and 20 or 26)
	local box2 = Style.box(fill, "Scrap", Style.INK, UDim2.fromOffset(0, 32), 3, 1.5)
	box2.AutomaticSize = Enum.AutomaticSize.X
	box2.AnchorPoint = Vector2.new(1, 0)
	box2.Position = UDim2.new(1, -60, 0, 20)
	box2.Visible = not flag
	list(box2, 6, true)
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, 8)
	uiPadding.PaddingRight = UDim.new(0, 10)
	uiPadding.Parent = box2
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = box2
	local nut = Style.nut(box2, 20)
	nut.LayoutOrder = 1
	local label = Style.label(box2, "Amount", "0", 20, Style.FONT, 0)
	label.TextColor3 = Style.HAZARD
	label.LayoutOrder = 2
	local button = Style.button(fill, "Close", "X", Style.ORANGE, UDim2.fromOffset(36, 36), Style.INK, 20)
	button.AnchorPoint = Vector2.new(1, 0)
	button.Position = UDim2.new(1, -12, 0, 18)
	local frame = Style.frame(box, "Content", UDim2.new(1, -24, 1, -110), UDim2.fromOffset(12, 76))
	local label2 = Style.label(box, "Toast", "", 16, Style.FONT, 1.5)
	label2.AnchorPoint = Vector2.new(0.5, 1)
	label2.Position = UDim2.new(0.5, 0, 1, -8)
	label2.Visible = false
	return region, fit, frame, label, button, label2, uiScale
end

local function badgeCard(frame, data, layoutOrder: number, callback)
	local badgeId = CareerData.badgeId(data, layoutOrder)
	local goal = data.goals[layoutOrder]
	local v = data.scrap[layoutOrder]
	local box = Style.box(frame, "Badge" .. layoutOrder, color, UDim2.fromOffset(266, 112), 3, 2)
	box.LayoutOrder = layoutOrder
	box.Selectable = true

	local frame2 = Style.frame(box, "Mark", UDim2.fromOffset(64, 64), UDim2.fromOffset(12, 14))
	local box2 = Style.box(frame2, "Diamond", Style.STEEL_LIGHT, UDim2.fromScale(0.72, 0.72), 3, 2)
	box2.AnchorPoint = Vector2.new(0.5, 0.5)
	box2.Position = UDim2.fromScale(0.5, 0.5)
	box2.Rotation = 45
	local box3 = Style.box(frame2, "Inner", Style.STEEL, UDim2.fromScale(0.46, 0.46), 2, 1)
	box3.AnchorPoint = Vector2.new(0.5, 0.5)
	box3.Position = UDim2.fromScale(0.5, 0.5)
	box3.Rotation = 45
	local label = Style.label(frame2, "Numeral", CareerData.NUMERALS[layoutOrder], 18, Style.FONT, 1.5)
	label.AutomaticSize = Enum.AutomaticSize.None
	label.Size = UDim2.fromScale(1, 1)
	local label_2 = Style.label(box, "Name", data.name .. " " .. CareerData.NUMERALS[layoutOrder], 18, Style.FONT, 1.5)
	label_2.Position = UDim2.fromOffset(88, 10)
	local label4 = body(box, "What", string.format(data.what, Style.thousands(goal)), 14) -- inferred equivalent call
	label4.AutomaticSize = Enum.AutomaticSize.None
	label4.Size = UDim2.fromOffset(166, 34)
	label4.TextWrapped = true
	label4.TextXAlignment = Enum.TextXAlignment.Left
	label4.TextYAlignment = Enum.TextYAlignment.Top
	label4.Position = UDim2.fromOffset(88, 34)
	local label2 = Style.label(box, "Count", "", 13, Style.FONT, 0)
	label2.AnchorPoint = Vector2.new(1, 0)
	label2.Position = UDim2.new(1, -12, 0, 72)
	local frame3 = Style.frame(box, "Pay", UDim2.fromOffset(0, 18), UDim2.fromOffset(88, 72))
	frame3.AutomaticSize = Enum.AutomaticSize.X
	list(frame3, 4, true)
	local nut = Style.nut(frame3, 14)
	nut.LayoutOrder = 1
	local label3 = Style.label(frame3, "Amount", "+" .. Style.thousands(v), 14, Style.FONT, 0)
	label3.TextColor3 = Style.HAZARD
	label3.LayoutOrder = 2
	local _, v2 = bar(box, UDim2.new(1, -100, 0, 8), UDim2.fromOffset(88, 96))
	local button = Style.button(box, "Claim", "CLAIM", Style.HAZARD, UDim2.fromOffset(84, 30), Style.INK, 16)
	button.AnchorPoint = Vector2.new(1, 0)
	button.Position = UDim2.new(1, -10, 0, 8)
	button.Visible = false
	button.Activated:Connect(function()
		callback(badgeId, button)
	end)
	return {
		refresh = function(p)
			local v3 = p.stats and p.stats[data.stat] or 0
			local v4 = p.claimed and table.find(p.claimed, badgeId) ~= nil
			local v5 = goal <= v3
			button.Visible = v5 and not v4
			local backgroundColor

			if v5 then
				backgroundColor = color3
			else
				backgroundColor = Style.STEEL_LIGHT
			end

			box2.BackgroundColor3 = backgroundColor
			local backgroundColor2

			if v5 then
				backgroundColor2 = Color3.fromRGB(168, 120, 36)
			else
				backgroundColor2 = Style.STEEL
			end

			box3.BackgroundColor3 = backgroundColor2
			local textColor = if v5 then Style.WHITE else Style.MUTED
			label.TextColor3 = textColor

			if v4 then
				label2.Text = "EARNED"
				label2.TextColor3 = Style.GOOD
				v2(1, Style.GOOD)
			elseif v5 then
				label2.Text = "READY"
				label2.TextColor3 = Style.HAZARD
				v2(1, Style.HAZARD)
			else
				label2.Text = Style.thousands(v3) .. " / " .. Style.thousands(goal)
				label2.TextColor3 = Style.MUTED
				v2(v3 / goal, Style.HAZARD)
			end
		end
	}
end

local function badgesContent(parent, fn)
	local parent2 = scrollArea(parent, UDim2.new(), UDim2.fromScale(1, 1)) -- inferred equivalent call
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.Padding = UDim.new(0, 14)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.FillDirection = Enum.FillDirection.Vertical

	uiListLayout.Parent = parent2

	local v = {}
	local v2 = {}

	for k, track in CareerData.TRACKS do
		local frame = Style.frame(parent2, track.id, UDim2.new(1, -12, 0, 0))
		frame.AutomaticSize = Enum.AutomaticSize.Y
		frame.LayoutOrder = k
		local uiListLayout2 = Instance.new("UIListLayout")
		uiListLayout2.Padding = UDim.new(0, 8)
		uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
		uiListLayout2.FillDirection = Enum.FillDirection.Vertical

		uiListLayout2.Parent = frame

		local frame2 = Style.frame(frame, "Head", UDim2.new(1, 0, 0, 26))
		frame2.LayoutOrder = 0
		local tape = Style.tape(frame2, "Tape", UDim2.fromOffset(6, 22), 30, 10)
		tape.Position = UDim2.fromOffset(0, 2)
		local label_2 = Style.label(frame2, "Title", track.name, 20, Style.FONT, 1.5)
		label_2.Position = UDim2.fromOffset(14, 0)
		local label = Style.label(frame2, "Total", "", 14, Style.FONT, 0)
		label.TextColor3 = Style.MUTED
		label.AnchorPoint = Vector2.new(1, 0)
		label.Position = UDim2.new(1, -6, 0, 4)
		table.insert(v, { track = track, label = label })
		local frame3 = Style.frame(frame, "Grid", UDim2.new(1, 0, 0, 0))
		frame3.AutomaticSize = Enum.AutomaticSize.Y
		frame3.LayoutOrder = 1
		local uiGridLayout = Instance.new("UIGridLayout")
		uiGridLayout.CellSize = UDim2.fromOffset(266, 112)
		uiGridLayout.CellPadding = UDim2.fromOffset(10, 10)
		uiGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uiGridLayout.Parent = frame3

		for i = 1, #track.goals do
			table.insert(v2, badgeCard(frame3, track, i, fn))
		end
	end

	return function(p)
		for _, v3 in v2 do
			v3.refresh(p)
		end

		for _, v3 in v do
			local v4 = p.stats and p.stats[v3.track.stat] or 0
			v3.label.Text = "LIFETIME " .. Style.thousands(v4)
		end
	end
end

local function section(p, layoutOrder: number, p2: string, p3: number)
	local box = Style.box(p, p2, color, UDim2.new(1, -12, 0, p3), 3, 2)
	box.LayoutOrder = layoutOrder
	local tape = Style.tape(box, "Tape", UDim2.fromOffset(6, 22), 30, 10)
	tape.Position = UDim2.fromOffset(12, 12)
	local label = Style.label(box, "Title", p2, 20, Style.FONT, 1.5)
	label.Position = UDim2.fromOffset(26, 10)
	return box
end

local function rewardsContent(parent, fn)
	local parent2 = scrollArea(parent, UDim2.new(), UDim2.fromScale(1, 1)) -- inferred equivalent call
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.Padding = UDim.new(0, 12)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.FillDirection = Enum.FillDirection.Vertical

	uiListLayout.Parent = parent2

	local function chip(p, p2: string, color5: Color3, textColor: Color3)
		local box = Style.box(p, p2, color5, UDim2.fromOffset(0, 26), 2, 1.5)
		box.AutomaticSize = Enum.AutomaticSize.X
		local uiPadding = Instance.new("UIPadding")
		uiPadding.PaddingLeft = UDim.new(0, 8)
		uiPadding.PaddingRight = UDim.new(0, 8)
		uiPadding.Parent = box
		local label = Style.label(box, "Text", "", 16, Style.FONT, 0)
		label.Size = UDim2.fromOffset(0, 26)
		label.TextColor3 = textColor
		return box, label
	end

	local function claimButton(p, p2: number, p3: string)
		local button, v = Style.button(p, "Claim", "CLAIM", Style.HAZARD, UDim2.fromOffset(196, 36), Style.INK, 18)
		button.AnchorPoint = Vector2.new(1, 0)
		button.Position = UDim2.new(1, -14, 0, p2)
		button.Activated:Connect(function()
			fn(p3, button)
		end)
		return button, v
	end

	local function setButton(p, p2, autoButtonColor: boolean, text: string) -- 2 equivalent calls inferred from this helper
		p.AutoButtonColor = autoButtonColor
		local backgroundColor

		if autoButtonColor then
			backgroundColor = Style.HAZARD
		else
			backgroundColor = Style.STEEL
		end

		p.BackgroundColor3 = backgroundColor
		local textColor

		if autoButtonColor then
			textColor = Style.INK
		else
			textColor = Style.MUTED
		end

		p2.TextColor3 = textColor
		p2.Text = text
	end

	local v = section(parent2, 1, "DAILY SUPPLY", 156)
	local parent3, v2 = chip(v, "Streak", Style.INK, Style.HAZARD)
	parent3.Position = UDim2.fromOffset(190, 9)
	local v3, v4 = claimButton(v, 8, "daily")
	local frame = Style.frame(v, "Days", UDim2.new(1, -28, 0, 88), UDim2.fromOffset(14, 54))
	list(frame, 6, true)
	local v5 = {}

	for i = 1, #CareerData.DAILY do
		local box = Style.box(frame, "Day" .. i, color2, UDim2.new(1 / #CareerData.DAILY, -6, 1, 0), 3, 2)
		box.LayoutOrder = i
		box.ClipsDescendants = true
		local uiStroke = box:FindFirstChildOfClass("UIStroke")
		assert(uiStroke, "LobbyMenus: Style.box with an outline gave no UIStroke")

		if i == #CareerData.DAILY then
			Style.tape(box, "Tape", UDim2.new(1, 0, 0, 5), 140, 10)
		end

		local label = Style.label(box, "Day", "DAY " .. i, 15, Style.FONT, 0)
		label.TextColor3 = Style.MUTED
		label.Position = UDim2.fromOffset(8, 8)
		local frame2 = Style.frame(box, "Amount", UDim2.fromOffset(0, 26), UDim2.fromOffset(8, 34))
		frame2.AutomaticSize = Enum.AutomaticSize.X
		list(frame2, 4, true)
		local nut = Style.nut(frame2, 18)
		nut.LayoutOrder = 1
		local label2 = Style.label(frame2, "N", Style.thousands(CareerData.DAILY[i]), 21, Style.FONT, 0)
		label2.TextColor3 = Style.HAZARD
		label2.LayoutOrder = 2
		local label3 = Style.label(box, "Done", "TAKEN", 14, Style.FONT, 0)
		label3.TextColor3 = Style.GOOD
		label3.Position = UDim2.fromOffset(8, 62)
		table.insert(v5, { tile = box, stroke = uiStroke, done = label3, dayText = label })
	end

	local v6 = section(parent2, 2, "ON DUTY", 106)
	local parent4, v7 = chip(v6, "Rate", Style.INK, Style.HAZARD)
	parent4.Position = UDim2.fromOffset(150, 9)
	v7.Text = "+" .. Style.thousands(CareerData.DUTY.scrap) .. " EVERY " .. CareerData.DUTY.every // 60 .. " MIN"
	local v8, v9 = claimButton(v6, 56, "duty")
	local _, v10 = bar(v6, UDim2.new(1, -242, 0, 34), UDim2.fromOffset(14, 57))
	local label = Style.label(v6, "Clock", "", 17, Style.FONT, 1.5)
	label.Position = UDim2.fromOffset(24, 62)

	local parent5, v11 = chip(section(parent2, 3, "DOUBLE XP", 52), "State", Style.STEEL, Style.MUTED)
	parent5.AnchorPoint = Vector2.new(1, 0)
	parent5.Position = UDim2.new(1, -14, 0, 13)

	local count = #CareerData.DAILY
	return function(data)
		local daily = data.daily

		if daily then
			local v12

			if daily.can then
				v12 = daily.nextDay
			else
				v12 = math.min((daily.day or 0) + 1, count)
			end

			local v13

			if daily.can then
				v13 = v12 - 1
			else
				v13 = daily.day or 0
			end

			for k, v14 in v5 do
				local v15 = k == v12
				v14.done.Visible = k <= v13
				local stroke = v14.stroke
				local color5

				if v15 and daily.can then
					color5 = Style.HAZARD
				else
					color5 = Style.INK
				end

				stroke.Color = color5
				v14.stroke.Thickness = v15 and daily.can and 3 or 2
				local dayText = v14.dayText
				local textColor

				if v15 then
					textColor = Style.WHITE
				else
					textColor = Style.MUTED
				end

				dayText.TextColor3 = textColor
			end

			parent3.Visible = daily.streak > 0
			v2.Text = "STREAK " .. tostring(daily.streak)
			local can = daily.can
			local v14

			if daily.can then
				v14 = "CLAIM DAY " .. v12
			else
				v14 = "NEXT " .. Style.duration(daily.resetIn)
			end

			setButton(v3, v4, can, v14) -- inferred equivalent call
		end

		local duty = data.duty

		if duty then
			local progress = duty.progress
			local v12

			if duty.ready > 0 then
				v12 = Style.GOOD
			else
				v12 = Style.HAZARD
			end

			v10(progress, v12)
			label.Text = not (duty.left > 0) and "FULL" or "NEXT " .. Style.duration(duty.left)
			local autoButtonColor = duty.ready > 0
			setButton( -- inferred equivalent call
				v8,
				v9,
				autoButtonColor,
				not autoButtonColor and "NOT YET" or "CLAIM " .. Style.thousands(duty.ready * CareerData.DUTY.scrap)
			)
		end

		local v12 = (data.boostUntil or 0) - (data.now or 0)
		local backgroundColor

		if v12 > 0 then
			backgroundColor = Style.GOOD
		else
			backgroundColor = Style.STEEL
		end

		parent5.BackgroundColor3 = backgroundColor
		local textColor = if v12 > 0 then Style.INK else Style.MUTED
		v11.TextColor3 = textColor
		v11.Text = not (v12 > 0) and "OFF  ·  STORE" or "ON  ·  " .. Style.duration(v12)
	end
end

local vector2_2 = Vector2.new(600, 440)

local v = { "😢", "😐", "😀" }

local function feedbackContent(p, fn)
	local label_2 = Style.label(p, "Ask", "HOW IS THE GAME?", 20, Style.FONT, 1.5)
	label_2.Position = UDim2.fromOffset(2, 0)
	local frame = Style.frame(p, "Faces", UDim2.new(1, 0, 0, 60), UDim2.fromOffset(0, 30))
	list(frame, 10, true)
	local v2 = 0
	local v3 = {}
	local button, v4 = Style.button(p, "Send", "SUBMIT", Style.HAZARD, UDim2.fromOffset(170, 46), Style.INK, 20)
	local v5 = false
	local function paint()
		for k, v6 in v3 do
			local stroke = v6.stroke
			local color5 = if k == v2 then Style.HAZARD else Style.INK
			stroke.Color = color5
			v6.stroke.Thickness = k == v2 and 3 or 2
			local button2 = v6.button
			local backgroundColor

			if k == v2 then
				backgroundColor = Style.STEEL_LIGHT
			else
				backgroundColor = color
			end

			button2.BackgroundColor3 = backgroundColor
		end

		local autoButtonColor

		if v2 > 0 then
			autoButtonColor = not v5
		else
			autoButtonColor = false
		end

		button.AutoButtonColor = autoButtonColor
		local backgroundColor

		if autoButtonColor then
			backgroundColor = Style.HAZARD
		else
			backgroundColor = Style.STEEL
		end

		button.BackgroundColor3 = backgroundColor
		local textColor

		if autoButtonColor then
			textColor = Style.INK
		else
			textColor = Style.MUTED
		end

		v4.TextColor3 = textColor
		v4.Text = v5 and "SENDING..." or "SUBMIT"
	end

	for k, v6 in v do
		local button2, v7 = Style.button(frame, "Face" .. k, v6, color, UDim2.fromOffset(96, 60), Style.WHITE, 34)
		button2.LayoutOrder = k
		v7.FontFace = Style.FONT_BODY
		v7.AutoLocalize = false
		local uiStroke = button2:FindFirstChildOfClass("UIStroke")
		assert(uiStroke, "LobbyMenus: Style.button gave no UIStroke")
		table.insert(v3, { button = button2, stroke = uiStroke })
		button2.Activated:Connect(function()
			v2 = k
			paint()
		end)
	end

	local box = Style.box(p, "Note", color2, UDim2.new(1, -4, 0, 150), 3, 2)
	box.Position = UDim2.fromOffset(2, 102)
	local text = Instance.new("TextBox")
	text.Name = "Text"
	text.AutoLocalize = false
	text.BackgroundTransparency = 1
	text.ClearTextOnFocus = false
	text.MultiLine = true
	text.TextWrapped = true
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.TextYAlignment = Enum.TextYAlignment.Top
	text.FontFace = Style.FONT_BODY
	text.TextSize = 17
	text.TextColor3 = Style.WHITE
	text.PlaceholderText = "Tell us what to fix or add (optional)"
	text.PlaceholderColor3 = Style.DIM
	text.Text = ""
	text.Position = UDim2.fromOffset(12, 10)
	text.Size = UDim2.new(1, -24, 1, -34)
	text.Parent = box
	local label = Style.label(box, "Count", "0 / " .. 300, 13, Style.FONT, 0)
	label.AutoLocalize = false
	label.TextColor3 = Style.DIM
	label.AnchorPoint = Vector2.new(1, 1)
	label.Position = UDim2.new(1, -10, 1, -4)
	text:GetPropertyChangedSignal("Text"):Connect(function()
		local v6 = utf8.len(text.Text)

		if v6 and v6 > 300 then
			local v7 = utf8.offset(text.Text, 301)
			text.Text = string.sub(text.Text, 1, v7 - 1)
		else
			label.Text = tostring(v6 or 0) .. " / " .. 300
		end
	end)

	button.AnchorPoint = Vector2.new(1, 0)
	button.Position = UDim2.new(1, -2, 0, 262)
	button.Activated:Connect(function()
		if v5 or v2 == 0 then
			return
		end

		v5 = true
		paint()
		fn(v2, text.Text, function(flag: boolean, _: string)
			v5 = false

			if flag then
				v2 = 0
				text.Text = ""
			end

			paint()
		end)
	end)
	paint()
	return function(_) end
end

return {
	mount = function(data)
		local player = data.player
		local career = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Remotes"):WaitForChild("Career", 30)
		assert(
			career and career:IsA("RemoteFunction"),
			"GameUI: remote Game.Remotes.Career (RemoteFunction) is missing (ServerScriptService.Career)"
		)
		local menu = data.layers.menu
		local v2 = {}
		local v3 = nil
		local v4 = true
		local v5 = { stats = 0, claimed = 0 }
		v5.stats = {}
		v5.claimed = {}
		local count = 0

		local function invoke(...)
			local success, result, v6 = pcall(career.InvokeServer, career, ...)

			if not success then
				warn("[LobbyMenus] Career request failed: " .. tostring(result))
			end

			return success, result, v6
		end

		local function toast(text: string, flag: boolean)
			count += 1
			local v6 = count

			for _, v7 in v2 do
				v7.toast.Text = text
				local toast2 = v7.toast
				local textColor

				if flag then
					textColor = Style.GOOD
				else
					textColor = Style.ORANGE
				end

				toast2.TextColor3 = textColor
				v7.toast.Visible = text ~= ""
			end

			task.delay(2.4, function()
				if count == v6 then
					for _, v7 in v2 do
						v7.toast.Visible = false
					end
				end
			end)
		end

		local v6 = nil
		local function scrapNow() -- 2 equivalent calls inferred from this helper
			local scrap = player:GetAttribute("Scrap")
			return if type(scrap) == "number" then scrap else 0
		end

		local function refreshAll()
			local v7 = v6 or scrapNow() -- inferred equivalent call

			for _, v8 in v2 do
				if not v8.open then
					continue
				end

				v8.scrap.Text = Style.thousands((math.floor(v7)))
				v8.refresh(v5)
			end
		end

		local function poll() -- 1 equivalent call inferred from this helper
			local v7, v8 = invoke("state")

			if v7 and type(v8) == "table" then
				v5 = v8
			end

			refreshAll()
		end

		local layer = Style.layer(data.playerGui, "ClaimFx", 25)

		layer.Enabled = false
		layer.ChildAdded:Connect(function()
			layer.Enabled = true
		end)
		layer.ChildRemoved:Connect(function()
			layer.Enabled = #layer:GetChildren() > 0
		end)
		local count2 = 0
		local function centreOf(p) -- 6 equivalent calls inferred from this helper
			return p.AbsolutePosition + p.AbsoluteSize / 2 - layer.AbsolutePosition
		end

		local function claimFx(p, p2, p3: number, p4: number, flag: boolean?)
			count2 += 1
			local v7 = count2
			local parent = p.scrap.Parent
			local v8 = centreOf(p2) -- inferred equivalent call
			local v9 = math.max(8, parent.AbsoluteSize.Y)
			local now = os.clock()

			local frame = Style.frame(
				layer,
				"Ring",
				UDim2.fromOffset(0, 0),
				UDim2.fromOffset(v8.X, v8.Y),
				Vector2.new(0.5, 0.5)
			)
			Style.corner(frame, 999)
			local stroke = Style.stroke(frame, 5, 0, Style.HAZARD)
			local fill = Style.fill(p2, "Flash", Style.WHITE, UDim2.fromScale(1, 1))
			Style.corner(fill, 3)
			fill.ZIndex = 10

			local label = Style.label(layer, "Rise", "+" .. Style.thousands(p4), 30, Style.FONT, 2)
			label.TextColor3 = Style.HAZARD
			label.AnchorPoint = Vector2.new(0.5, 0.5)
			label.TextScaled = false
			local uiScale = Instance.new("UIScale")
			uiScale.Scale = v9 / 32
			uiScale.Parent = label
			local v10

			if flag then
				v10 = math.clamp(p4 // 40 + 14, 18, 30)
			else
				v10 = math.clamp(p4 // 60 + 6, 8, 18)
			end

			local v11 = {}
			local v12 = false

			for i = 1, v10 do
				local nut = Style.nut(layer, 1)
				nut.AnchorPoint = Vector2.new(0.5, 0.5)
				local v13 = v9 * (0.55 + math.random() * 0.25)
				nut.Size = UDim2.fromOffset(v13, v13)
				local v14 = math.random() * 2 * 3.141592653589793
				local v15 = v9 * (3 + math.random() * 3)
				table.insert(v11, {
					frame = nut,
					v = Vector2.new(math.cos(v14), math.sin(v14) - 0.6) * v15,
					delay = (i - 1) * (flag and 0.024 or 0.035) + 0.18,
					spin = (math.random() * 2 - 1) * 540,
					landed = false
				})
			end

			local count3 = 0
			ClaimAudio.pay()
			Style.animate(frame, function(_, p5): boolean
				local v13 = p5 - now

				local transparency = math.clamp(v13 / 0.45, 0, 1)
				local v14 = v9 * 5 * Style.easeOut(transparency)
				frame.Size = UDim2.fromOffset(v14, v14)
				stroke.Thickness = math.max(1, v9 * 0.2 * (1 - transparency))
				stroke.Transparency = transparency
				fill.BackgroundTransparency = math.clamp(v13 / 0.3, 0, 1) * 0.85 + 0.15

				local v15 = math.clamp(v13 / 1.2, 0, 1)
				label.Position = UDim2.fromOffset(v8.X, v8.Y - v9 * 0.6 - v9 * 2.2 * Style.easeOut(v15))
				label.TextTransparency = math.clamp((v13 - 0.7) / 0.5, 0, 1)
				local uiStroke = label:FindFirstChildOfClass("UIStroke")

				if uiStroke then
					uiStroke.Transparency = label.TextTransparency
				end

				uiScale.Scale = v9 / 32 * Style.pop((math.clamp(v13 / 0.25, 0, 1)))
				local v16 = centreOf(parent) -- inferred equivalent call
				local v17 = false

				for _, v18 in v11 do
					if v18.landed then
						continue
					end

					v17 = true
					local v19 = math.min(v13, 0.22)
					local v20 = v8 + v18.v * v19 * (1 - v19 / 0.44)
					local v21 = math.clamp((v13 - v18.delay - 0.22) / 0.42, 0, 1)
					local easeIn = Style.easeIn(v21)
					local v22 = v20:Lerp(v16, 0.5) - Vector2.new(0, v9 * 1.5)
					local lerped = v20:Lerp(v22, easeIn):Lerp(v22:Lerp(v16, easeIn), easeIn)
					v18.frame.Position = UDim2.fromOffset(lerped.X, lerped.Y)
					v18.frame.Rotation = v18.spin * v13

					if not (v21 >= 1) then
						continue
					end

					v18.landed = true
					v18.frame:Destroy()
					count3 += 1
					ClaimAudio.nut(count3 / v10)

					if v7 ~= count2 then
						continue
					end

					v6 = p3 + p4 * count3 / v10
					p.scrapPop.Scale = 1.28
					refreshAll()
				end

				if p.scrapPop.Scale > 1 then
					p.scrapPop.Scale = math.max(1, p.scrapPop.Scale - 1 / 24)
				end

				if flag and not (v17 or v12) then
					v12 = true
					local v18 = centreOf(parent) -- inferred equivalent call
					ClaimFx.ring(layer, v18, v9 * 4.5, v9 * 0.18, Style.HAZARD, 0.4)
					ClaimFx.sparks(layer, v18, 14, v9 * 0.6, 0.5)
					p.scrapPop.Scale = 1.5
				end

				if v17 or v13 < 1.3 or p.scrapPop.Scale > 1 then
					return true
				end

				frame:Destroy()
				fill:Destroy()
				label:Destroy()

				if v7 == count2 then
					v6 = nil
					refreshAll()
				end

				return false
			end)
		end

		local function revealFx(data2)
			local v7 = math.clamp(layer.AbsoluteSize.Y / 22.5, 14, 48)
			local scale = v7 / 32
			local halfAbsoluteSize = layer.AbsoluteSize / 2

			local amount = data2.amount

			local frame = Style.frame(layer, "RewardFx", UDim2.fromScale(1, 1))
			local fill = Style.fill(frame, "Dim", Style.INK, UDim2.fromScale(1, 1))
			fill.BackgroundTransparency = 1
			local frame2 = Style.frame(
				frame,
				"Stage",
				UDim2.fromOffset(420, 420),
				UDim2.fromOffset(halfAbsoluteSize.X, halfAbsoluteSize.Y),
				Vector2.new(0.5, 0.5)
			)
			local uiScale = Instance.new("UIScale")
			uiScale.Scale = scale
			uiScale.Parent = frame2

			local glow = ClaimFx.glow(frame2, 360, Style.HAZARD)
			glow.ImageTransparency = 1
			glow.ZIndex = 1
			local rays = ClaimFx.rays(frame2, 420, Style.HAZARD, 12)
			rays.ZIndex = 2

			local v8 = nil
			local parent

			if data2.image then
				parent = ClaimFx.image(frame2, "Prize", data2.image, Style.WHITE, 0, UDim2.fromOffset(210, 202))
				local imageSize = data2.imageSize or Vector2.new(270, 135)
				parent.Size = UDim2.fromOffset(imageSize.X, imageSize.Y)
				parent.ScaleType = Enum.ScaleType.Fit
				parent.ImageTransparency = 1
				v8 = parent
			else
				parent = Style.nut(frame2, 120)
				parent.AnchorPoint = Vector2.new(0.5, 0.5)
				parent.Position = UDim2.fromOffset(210, 202)
			end

			parent.ZIndex = 3
			local uiScale2 = Instance.new("UIScale")
			uiScale2.Scale = data2.from and 0.45 or 2.6
			uiScale2.Parent = parent

			local function word(p: string, p2: string, p3: number, textColor: Color3)
				local label = Style.label(frame2, p, p2, p3, Style.FONT, 2)
				label.AnchorPoint = Vector2.new(0.5, 0.5)
				label.TextColor3 = textColor
				label.TextTransparency = 1
				label.ZIndex = 4
				local uiStroke = label:FindFirstChildOfClass("UIStroke")

				if uiStroke then
					uiStroke.Transparency = 1
				end

				return label, uiStroke
			end

			local v9, v10 = word("Caption", data2.caption, 26, Style.HAZARD)
			local parent2, v11 = word("Value", amount and "+0" or data2.title or "", amount and 54 or 38, Style.WHITE)
			local uiScale3 = Instance.new("UIScale")
			uiScale3.Parent = parent2

			local v12 = halfAbsoluteSize + Vector2.new(0, scale * 146)

			local v13 = not amount and 0 or math.clamp(amount // 25, 6, 16)
			local v14 = 0
			local v15 = false
			local v16 = false
			ClaimAudio.prizeIn(0.32)
			local now = os.clock()
			Style.animate(frame, function(p, p2): boolean
				if data2.alive() then
					local v17 = p2 - now
					local v18 = halfAbsoluteSize

					if v17 < 0.32 then
						local v19 = v17 / 0.32

						if data2.from then
							v18 = data2.from:Lerp(halfAbsoluteSize, Style.easeOut(v19)) - Vector2.new(0, math.sin(v19 * 3.141592653589793) * v7 * 2.5)
							uiScale2.Scale = 0.45 + 0.95 * Style.easeIn(v19)
							parent.Rotation = -16 * (1 - v19)
						else
							uiScale2.Scale = 2.6 - 1.6 * Style.easeIn(v19)
						end

						if v8 then
							v8.ImageTransparency = 1 - math.min(1, v19 * 2)
						end

						fill.BackgroundTransparency = 1 - 0.55 * v19
					else
						if not v16 then
							v16 = true
							ClaimAudio.prizeHit()
							ClaimFx.flash(layer, 0.45, 0.3, color4)
							ClaimFx.ring(layer, halfAbsoluteSize, v7 * 16, v7 * 0.45, Style.HAZARD, 0.55)
							ClaimFx.ring(layer, halfAbsoluteSize, v7 * 10, v7 * 0.25, Style.WHITE, 0.45, 0.07)
							ClaimFx.salvo(layer, halfAbsoluteSize, v7)

							if data2.rich then
								ClaimFx.ring(layer, halfAbsoluteSize, v7 * 24, v7 * 0.3, Style.HAZARD, 0.7, 0.12)
								ClaimFx.sparks(layer, halfAbsoluteSize, 30, v7, 0)
								ClaimFx.sparkles(layer, halfAbsoluteSize, v7 * 7, 16, v7, 1.25, Style.HAZARD)
							end

							parent.Rotation = 0
						end

						local v19 = v17 - 0.32

						if data2.from then
							uiScale2.Scale = (math.exp(-v19 * 9) * 0.4 * math.cos(v19 * 20) + 1) * (math.sin(v19 * 5) * 0.025 + 1)
						else
							uiScale2.Scale = (1 - 0.1 * (1 - Style.easeOut((math.clamp(v19 / 0.22, 0, 1))))) * (math.sin(v19 * 5) * 0.025 + 1)
						end

						local v20 = math.max(0, 1 - v19 / 0.28) * 8 * scale
						v18 += Vector2.new((math.random() * 2 - 1) * v20, (math.random() * 2 - 1) * v20)
						local v21 = math.clamp(v19 / 0.25, 0, 1)
						glow.ImageTransparency = 1 - (math.sin(v19 * 6) * 0.1 + 0.6) * v21
						rays.GroupTransparency = 1 - v21 * 0.75
						rays.Rotation = v19 * 24

						local v22 = math.clamp((v19 - 0.04) / 0.22, 0, 1)
						local v23 = 14 * (1 - Style.easeOut(v22))
						v9.Position = UDim2.fromOffset(210, 52 + v23)
						parent2.Position = UDim2.fromOffset(210, 356 - v23)
						v9.TextTransparency = 1 - v22
						parent2.TextTransparency = 1 - v22

						if v10 then
							v10.Transparency = 1 - v22
						end

						if v11 then
							v11.Transparency = 1 - v22
						end

						if amount then
							local v24 = math.clamp((v19 - 0.1) / 0.75, 0, 1)
							parent2.Text = "+" .. Style.thousands((math.floor(amount * Style.easeOut(v24) + 0.5)))
							local v25 = math.floor(v24 * v13)

							if v14 < v25 and v25 < v13 then
								v14 = v25
								ClaimAudio.prizeTick(v25 / v13)
								uiScale3.Scale = 1.16
							end
						end

						if not v15 and (amount and 0.85 or 0.25) <= v19 then
							v15 = true
							ClaimAudio.prizeDone()
							uiScale3.Scale = 1.35
							ClaimFx.sparks(layer, v12, 14, v7 * 0.8, 0.5)

							if data2.rich then
								ClaimFx.ring(layer, v12, v7 * 9, v7 * 0.22, Style.HAZARD, 0.4)
								ClaimFx.sparks(layer, v12, 16, v7 * 0.9, 0)
							end
						end

						uiScale3.Scale = math.max(1, uiScale3.Scale - p * 2.4)

						if v17 >= 2 then
							local v24 = math.clamp((v17 - 2) / 0.25, 0, 1)
							fill.BackgroundTransparency = v24 * 0.55 + 0.45

							if data2.rich then
								if v24 < 0.5 then
									uiScale.Scale = scale * (1 - 0.14 * Style.easeOut(v24 / 0.5))
								else
									local v25 = (v24 - 0.5) / 0.5
									uiScale.Scale = scale * (0.86 + 0.9 * Style.easeOut(v25))

									if v8 then
										v8.ImageTransparency = v25
									end

									v9.TextTransparency = v25
									parent2.TextTransparency = v25

									if v10 then
										v10.Transparency = v25
									end

									if v11 then
										v11.Transparency = v25
									end

									glow.ImageTransparency = math.max(glow.ImageTransparency, v25)
									rays.GroupTransparency = math.max(rays.GroupTransparency, v25)
								end

								if v24 >= 1 then
									ClaimFx.flash(layer, 0.3, 0.25, color4)
									ClaimFx.ring(layer, halfAbsoluteSize, v7 * 14, v7 * 0.4, Style.HAZARD, 0.45)
								end
							else
								uiScale.Scale = scale * (1 - Style.easeIn(v24))
							end

							if v24 >= 1 then
								frame:Destroy()
								data2.done(halfAbsoluteSize)
								return false
							end
						end
					end

					frame2.Position = UDim2.fromOffset(v18.X, v18.Y)
					return true
				end

				frame:Destroy()
				data2.cancel()
				return false
			end)
		end

		local function rewardFx(p, p2: string, p3: number, amount: number, nextDay: number?, p4)
			local v7 = p2 == "daily" and "scrapM" or "scrapS"
			local v8 = nil

			for _, v9 in CareerData.STORE.scrap do
				if v9.id == v7 then
					v8 = v9
				end
			end

			assert(v8 and v8.image, "[LobbyMenus] rewardFx: no Scrap product picture")

			local v9 = Rewards.ON

			if v9 then
				if p2 == "daily" then
					v9 = nextDay ~= nil
				else
					v9 = false
				end
			end

			local image

			if v9 then
				image = Rewards.dayImage(nextDay)
			else
				image = v8.image
			end

			local imageSize

			if v9 then
				imageSize = Vector2.new(210, 210)
			end

			local v10 = {
				image = image,
				imageSize = imageSize,
				caption = p2 == "daily" and "DAILY SUPPLY" or "ON DUTY",
				amount = amount,
				from = 0,
				rich = true,
				alive = 0,
				done = 0,
				cancel = 0
			}
			local from

			if p4 then
				from = centreOf(p4) -- inferred equivalent call
			end

			v10.from = from

			function v10.alive()
				return p.open
			end

			function v10.done(vector2_3: Vector2)
				local frame = Style.frame(
					layer,
					"From",
					UDim2.fromOffset(0, 0),
					UDim2.fromOffset(vector2_3.X, vector2_3.Y),
					Vector2.new(0.5, 0.5)
				)
				claimFx(p, frame, p3, amount, true)
				task.delay(4, frame.Destroy, frame)
			end
			function v10.cancel()
				v6 = nil
				refreshAll()
			end

			revealFx(v10)
		end

		function ArmoryStore.reveal(amount: number)
			revealFx({
				image = CareerData.STORE.scrap[1].image,
				caption = "FREE SCRAP",
				amount = amount,
				alive = function(): boolean
					return true
				end,
				done = function(_: Vector2) end,
				cancel = function() end
			})
		end

		local function pressFx(p, parent)
			local parent2 = p.scrap.Parent
			ClaimFx.spray(layer, centreOf(parent), (math.max(8, parent2.AbsoluteSize.Y))) -- inferred equivalent call
			ClaimAudio.press()
			local punch = parent:FindFirstChild("Punch")

			if not punch then
				punch = Instance.new("UIScale")
				punch.Name = "Punch"
				punch.Parent = parent
			end

			local now = os.clock()
			Style.animate(punch, function(_, p2): boolean
				local v7 = math.min(1, (p2 - now) / 0.32)
				punch.Scale = 0.82 + 0.18 * Style.pop(v7)
				return v7 < 1
			end)
		end

		local function badgeOf(p: string)
			for _, v7 in CareerData.TRACKS do
				for i = 1, #v7.goals do
					if CareerData.badgeId(v7, i) == p then
						return v7, i
					end
				end
			end

			return nil, 0
		end

		local function badgeFx(p, p2, p3: string, p4: number, p5: number)
			local v7, v8 = badgeOf(p3)
			local parent = p2.Parent
			local mark = parent and parent:FindFirstChild("Mark")
			assert(
				v7 and parent and parent:IsA("GuiObject") and mark and mark:IsA("GuiObject"),
				"[LobbyMenus] badgeFx: no card for badge " .. p3
			)
			local scale = math.max(8, p.scrap.Parent.AbsoluteSize.Y) / 32
			local v9 = CareerData.NUMERALS[v8]

			local frame = Style.frame(layer, "BadgeFx", UDim2.fromScale(1, 1))
			local fill = Style.fill(frame, "Dim", Style.INK, UDim2.fromScale(1, 1))
			fill.BackgroundTransparency = 1
			local halfAbsoluteSize = layer.AbsoluteSize / 2

			local frame2 = Style.frame(
				frame,
				"Stage",
				UDim2.fromOffset(360, 360),
				UDim2.fromOffset(halfAbsoluteSize.X, halfAbsoluteSize.Y),
				Vector2.new(0.5, 0.5)
			)
			local uiScale = Instance.new("UIScale")
			uiScale.Scale = scale
			uiScale.Parent = frame2

			local rays = Instance.new("CanvasGroup")
			rays.Name = "Rays"
			rays.BackgroundTransparency = 1
			rays.Size = UDim2.fromOffset(360, 360)
			rays.Position = UDim2.fromScale(0.5, 0.5)
			rays.AnchorPoint = Vector2.new(0.5, 0.5)
			rays.GroupTransparency = 1
			rays.Parent = frame2

			for i = 1, 8 do
				local fill2 = Style.fill(
					rays,
					"Ray",
					Style.HAZARD,
					UDim2.fromOffset(22, 360),
					UDim2.fromScale(0.5, 0.5),
					Vector2.new(0.5, 0.5)
				)
				fill2.Rotation = i * 22.5
				local uiGradient = Instance.new("UIGradient")
				uiGradient.Rotation = 90
				uiGradient.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.5, 0.25),
					NumberSequenceKeypoint.new(1, 1)
				})

				uiGradient.Parent = fill2
			end

			local glow = ClaimFx.glow(frame2, 330, Style.HAZARD)
			glow.ImageTransparency = 1

			local frame3 = Style.frame(
				frame2,
				"Ring",
				UDim2.fromOffset(0, 0),
				UDim2.fromScale(0.5, 0.5),
				Vector2.new(0.5, 0.5)
			)
			Style.corner(frame3, 999)
			local stroke = Style.stroke(frame3, 10, 1, Style.HAZARD)

			local frame4 = Style.frame(
				frame2,
				"Medal",
				UDim2.fromOffset(160, 160),
				UDim2.fromScale(0.5, 0.5),
				Vector2.new(0.5, 0.5)
			)
			local uiScale2 = Instance.new("UIScale")
			uiScale2.Scale = 2.6
			uiScale2.Parent = frame4
			local box = Style.box(frame4, "Diamond", Color3.new(1, 1, 1), UDim2.fromScale(0.72, 0.72), 6, 3)
			box.AnchorPoint = Vector2.new(0.5, 0.5)
			box.Position = UDim2.fromScale(0.5, 0.5)
			box.Rotation = 45
			local uiGradient = Instance.new("UIGradient")
			uiGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, color3),
				ColorSequenceKeypoint.new(0.4, color3),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 238, 190)),
				ColorSequenceKeypoint.new(0.6, color3),
				ColorSequenceKeypoint.new(1, color3)
			})

			uiGradient.Offset = Vector2.new(-1, 0)
			uiGradient.Parent = box
			local box2 = Style.box(frame4, "Inner", Color3.fromRGB(168, 120, 36), UDim2.fromScale(0.46, 0.46), 4, 2)
			box2.AnchorPoint = Vector2.new(0.5, 0.5)
			box2.Position = UDim2.fromScale(0.5, 0.5)
			box2.Rotation = 45
			local label = Style.label(frame4, "Numeral", v9, 44, Style.FONT, 2)
			label.AutomaticSize = Enum.AutomaticSize.None
			label.Size = UDim2.fromScale(1, 1)

			if Badges.ON then
				box.Visible = false
				box2.Visible = false
				label.Visible = false
				local picture = Instance.new("ImageLabel")
				picture.Name = "Picture"
				picture.BackgroundTransparency = 1
				picture.ScaleType = Enum.ScaleType.Fit
				picture.Image = Badges.medal(v7, v8)
				picture.AnchorPoint = Vector2.new(0.5, 0.5)
				picture.Position = UDim2.fromScale(0.5, 0.5)
				picture.Size = UDim2.fromScale(1.15, 1.15)
				picture.Parent = frame4
			end

			local function word(p6: string, p7: string, p8: number, white: Color3) -- 2 equivalent calls inferred from this helper
				local label2 = Style.label(frame2, p6, p7, p8, Style.FONT, 2)
				label2.AnchorPoint = Vector2.new(0.5, 0.5)
				label2.TextColor3 = white
				label2.TextTransparency = 1
				local uiStroke = label2:FindFirstChildOfClass("UIStroke")

				if uiStroke then
					uiStroke.Transparency = 1
				end

				return label2, uiStroke
			end

			local label2, uiStroke = word("Title", "BADGE EARNED", 24, Style.WHITE) -- inferred equivalent call

			local folder = Style.frame(
				frame2,
				"Stamp",
				UDim2.fromOffset(250, 40),
				UDim2.fromOffset(180, 50),
				Vector2.new(0.5, 0.5)
			)
			folder.Visible = false
			local uiScale3 = Instance.new("UIScale")
			uiScale3.Parent = folder
			local fill2 = Style.fill(folder, "Back", Style.INK, UDim2.fromScale(1, 1))
			local tape_2 = Style.tape(fill2, "Tape", UDim2.new(1, 0, 0, 6), 250, 10)
			tape_2.Position = UDim2.fromScale(0, 0)
			local tape = Style.tape(fill2, "TapeLow", UDim2.new(1, 0, 0, 6), 250, 10)
			tape.AnchorPoint = Vector2.new(0, 1)
			tape.Position = UDim2.fromScale(0, 1)
			label2.Parent = folder
			label2.Position = UDim2.fromScale(0.5, 0.5)
			label2.ZIndex = 2
			local label3, uiStroke2 = word("Name", v7.name .. " " .. v9, 36, Style.WHITE) -- inferred equivalent call

			local v10 = {}

			for i = 1, 16 do
				local v11 = 8 + math.random() * 10
				local fill3 = Style.fill
				local v12

				if i % 3 == 0 then
					v12 = Style.STEEL_LIGHT
				else
					v12 = if i % 3 == 1 then Style.STEEL else color3
				end

				local frame5 = fill3(
					frame2,
					"Shard",
					v12,
					UDim2.fromOffset(v11, v11),
					UDim2.fromOffset(180, 180),
					Vector2.new(0.5, 0.5)
				)
				frame5.Visible = false
				frame5.Rotation = math.random() * 90
				local v13 = math.random() * 2 * 3.141592653589793
				local v14 = 380 + math.random() * 420
				table.insert(v10, {
					frame = frame5,
					v = Vector2.new(math.cos(v13), math.sin(v13) - 0.35) * v14,
					spin = (math.random() * 2 - 1) * 720,
					r0 = frame5.Rotation
				})
			end

			ClaimAudio.badgeIn(0.35)
			local now = os.clock()
			local v11 = false
			Style.animate(frame, function(_, p6): boolean
				local v12 = p6 - now
				local v13 = halfAbsoluteSize
				local v14

				if v12 >= 1.75 then
					local v15 = math.clamp((v12 - 1.75) / 0.38, 0, 1)
					local smoothed = Style.smooth(v15)
					v14 = math.clamp(v15 / 0.5, 0, 1)

					v13 = halfAbsoluteSize:Lerp(centreOf(mark), smoothed) -- inferred equivalent call
					uiScale.Scale = scale + (mark.AbsoluteSize.X / 160 - scale) * smoothed

					if v15 >= 1 then
						ClaimAudio.badgeHome()
						frame:Destroy()

						if p.open then
							claimFx(p, parent, p4, p5)
						else
							v6 = nil
							refreshAll()
						end

						return false
					end
				else
					v14 = 0
				end

				if v12 < 0.35 then
					local v15 = v12 / 0.35
					uiScale2.Scale = 2.6 - 1.6 * Style.easeIn(v15)
					fill.BackgroundTransparency = 1 - 0.5 * v15
				else
					if not v11 then
						v11 = true
						ClaimAudio.badgeSlam()
						local v15 = scale * 32
						ClaimFx.flash(layer, 0.45, 0.3, color4)
						ClaimFx.salvo(layer, halfAbsoluteSize, v15)
						ClaimFx.ring(layer, halfAbsoluteSize, v15 * 18, v15 * 0.35, Style.WHITE, 0.5, 0.05)

						for _, v16 in v10 do
							v16.frame.Visible = true
						end
					end

					local v15 = v12 - 0.35

					uiScale2.Scale = 1 - 0.08 * (1 - Style.easeOut((math.clamp(v15 / 0.22, 0, 1))))
					local v16 = math.max(0, 1 - v15 / 0.25) * 7 * scale
					v13 += Vector2.new((math.random() * 2 - 1) * v16, (math.random() * 2 - 1) * v16)
					fill.BackgroundTransparency = v14 * 0.5 + 0.5

					local transparency = math.clamp(v15 / 0.5, 0, 1)
					local v17 = 420 * Style.easeOut(transparency)
					frame3.Size = UDim2.fromOffset(v17, v17)
					stroke.Thickness = math.max(1, (1 - transparency) * 10)
					stroke.Transparency = transparency

					for _, v18 in v10 do
						if not v18.frame.Visible then
							continue
						end

						local v19 = Vector2.new(180, 180) + v18.v * v15 + Vector2.new(0, 700 * v15 * v15)
						v18.frame.Position = UDim2.fromOffset(v19.X, v19.Y)
						v18.frame.Rotation = v18.r0 + v18.spin * v15
						v18.frame.BackgroundTransparency = math.clamp((v15 - 0.35) / 0.45, 0, 1)

						if v15 > 0.8 then
							v18.frame.Visible = false
						end
					end

					rays.GroupTransparency = 1 - math.clamp(v15 / 0.3, 0, 1) * 0.7 * (1 - v14)
					rays.Rotation = v15 * 20
					glow.ImageTransparency = 1 - (math.sin(v15 * 6) * 0.1 + 0.55) * math.clamp(v15 / 0.2, 0, 1) * (1 - v14)
					uiGradient.Offset = Vector2.new(math.clamp((v15 - 0.1) / 0.5, 0, 1) * 2 + -1, 0)

					local v18 = math.clamp((v15 - 0.05) / 0.25, 0, 1)
					local v19 = math.max(1 - v18, v14)
					local v20 = 12 * (1 - Style.easeOut(v18))

					local v21 = math.clamp((v15 - 0.05) / 0.12, 0, 1)
					folder.Visible = v15 >= 0.05 and v14 < 1
					uiScale3.Scale = 1.6 - 0.6 * Style.easeIn(v21)

					for _, frame5 in folder:GetDescendants() do
						if frame5:IsA("Frame") then
							frame5.BackgroundTransparency = math.max(1 - v21, v14)
						end
					end

					label2.TextTransparency = math.max(1 - v21, v14)
					label3.Position = UDim2.fromOffset(180, 314 - v20)
					label3.TextTransparency = v19

					if uiStroke then
						uiStroke.Transparency = math.max(1 - v21, v14)
					end

					if uiStroke2 then
						uiStroke2.Transparency = v19
					end
				end

				frame2.Position = UDim2.fromOffset(v13.X, v13.Y)
				return true
			end)
		end

		local function equipSkin(p: string): string
			local gunsmith = ReplicatedStorage:FindFirstChild("Gunsmith")
			local remote = gunsmith and gunsmith:FindFirstChild("Remote")

			if not (remote and remote:IsA("RemoteFunction")) then
				return "COULD NOT EQUIP"
			end

			local count3 = 0

			for _, v7 in { "primary", "secondary" } do
				local v8 = ShopData.PICKS[v7]
				local v9 = player:GetAttribute(v8.attr)

				if type(v9) ~= "string" then
					v9 = v8.default
				end

				if not WeaponSkins.has(v9) then
					continue
				end

				if WeaponSkins.pick(player, v9) == p then
					count3 += 1
				else
					local success, result = pcall(remote.InvokeServer, remote, "pick", v9, WeaponSkins.SLOT, p)

					if success and result == true then
						count3 += 1
					end
				end
			end

			return if count3 > 0 then "EQUIPPED" else "COULD NOT EQUIP"
		end

		local function claim(p: string, p2: string?, parent)
			local v7 = v6 or scrapNow() -- inferred equivalent call
			v6 = v7
			local daily = v5.daily
			local nextDay

			if p == "daily" and daily and type(daily.nextDay) == "number" then
				nextDay = daily.nextDay
			else
				nextDay = nil
			end

			local v8, v9, v10 = invoke(p, p2)

			if v8 then
				toast(type(v10) ~= "string" and "" or v10, v9 == true)
			end

			local v11

			if v8 and v9 == true and type(v10) == "string" then
				v11 = tonumber(string.match(v10, "%+(%d+) Scrap"))
			else
				v11 = nil
			end

			local v12

			if v3 then
				v12 = v2[v3]
			else
				v12 = nil
			end

			if v8 and v9 == true and p == "daily" and v10 == CareerData.DAILY_SKIN_SAID then
				v6 = nil

				if parent and v12 then
					pressFx(v12, parent)
				end

				task.delay(0.22, function()
					PurchaseShow.play(data.playerGui, {
						kind = "streakSkin",
						id = "streakSkin",
						name = "",
						skin = CareerData.DAILY_SKIN,
						equip = equipSkin
					})
				end)
			elseif v11 and parent and v12 then
				pressFx(v12, parent)
				task.delay(0.22, function()
					if v12.open then
						if p == "badge" and p2 then
							badgeFx(v12, parent, p2, v7, v11)
						elseif p == "daily" or p == "duty" then
							rewardFx(v12, p, v7, v11, nextDay, parent)
						else
							claimFx(v12, parent, v7, v11)
						end
					else
						v6 = nil
						refreshAll()
					end
				end)
			else
				v6 = nil
			end

			poll() -- inferred equivalent call
		end

		local function setOpen(p: string?)
			if p == v3 then
				return
			end

			local v7 = v3
			v3 = p

			for k, v8 in v2 do
				local open = k == p

				if v8.open == open then
					continue
				end

				v8.open = open

				if open then
					v8.root.Visible = true

					if v8.show then
						v8.show(true)
					end

					local now = os.clock()
					Style.animate(v8, function(_, p2): boolean
						local v9 = math.min(1, (p2 - now) / 0.16)
						v8.pop(0.92 + 0.08 * Style.easeOut(v9))
						return v9 < 1
					end)
				else
					Style.stop(v8)
					v8.root.Visible = false

					if v8.show then
						v8.show(false)
					end
				end
			end

			if p and not v7 then
				v4 = UserInputService.MouseIconEnabled
				UserInputService.MouseIconEnabled = true
			elseif not p and v7 then
				UserInputService.MouseIconEnabled = Viewmodel.cursorAfterMenu(v4)
			end

			data.setMenu(p ~= nil)

			if v7 then
				PadMenus.close("lobby")
			end

			if p then
				PadMenus.open("lobby", v2[p].root, function()
					setOpen(nil)
				end, { first = v2[p].first })
				refreshAll()
				task.spawn(poll)
			end
		end

		local function add(kind: string, p: string, p2: string, fn, vector2_3: Vector2?, flag: boolean?)
			local root, pop, v7, scrap, v8, toast2, scrapPop = window(menu, p, p2, vector2_3, flag)
			v2[kind] = {
				kind = kind,
				root = root,
				pop = pop,
				scrap = scrap,
				scrapPop = scrapPop,
				toast = toast2,
				refresh = fn(v7),
				open = false
			}
			v8.Activated:Connect(function()
				setOpen(nil)
			end)
		end

		if Badges.ON then
			local v7 = Badges.build(data, function(p: string, parent)
				claim("badge", p, parent)
			end, function()
				setOpen(nil)
			end)
			v2.badges = {
				kind = "badges",
				root = v7.root,
				pop = v7.pop,
				scrap = v7.scrap,
				scrapPop = v7.scrapPop,
				toast = v7.toast,
				refresh = v7.refresh,
				open = false,
				show = v7.show
			}
		else
			add("badges", "SKY DECK · CAREER", "BADGES", function(parent)
				return badgesContent(parent, function(p, parent2)
					claim("badge", p, parent2)
				end)
			end)
		end

		if Rewards.ON then
			local v7 = Rewards.build(data, function(p: string, parent)
				claim(p, nil, parent)
			end, function()
				setOpen(nil)
			end)
			v2.rewards = {
				kind = "rewards",
				root = v7.root,
				pop = v7.pop,
				scrap = v7.scrap,
				scrapPop = v7.scrapPop,
				toast = v7.toast,
				refresh = v7.refresh,
				open = false,
				show = v7.show,
				first = v7.first
			}
		else
			add("rewards", "SKY DECK · SUPPLY", "REWARDS", function(parent)
				return rewardsContent(parent, function(p, parent2)
					claim(p, nil, parent2)
				end)
			end, vector2)
		end

		add("feedback", "SKY DECK · FEEDBACK", "FEEDBACK", function(p)
			return feedbackContent(p, function(p2: number, p3: string, callback)
				task.spawn(function()
					local feedback = ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("Remotes"):WaitForChild(
						"Feedback",
						10
					)
					assert(
						feedback and feedback:IsA("RemoteFunction"),
						"GameUI: remote Voxel.Remotes.Feedback (RemoteFunction) is missing (ServerScriptService.Analytics)"
					)
					local success, result, v7 = pcall(feedback.InvokeServer, feedback, p2, p3)

					if not success then
						warn("[LobbyMenus] feedback failed: " .. tostring(result))
					end

					local v8 = success and result == true
					toast((not success or type(v7) ~= "string") and "Couldn't send. Try again." or v7, v8)
					callback(v8, type(v7) ~= "string" and "" or v7)

					if v8 then
						task.delay(1.6, function()
							if v3 == "feedback" then
								setOpen(nil)
							end
						end)
					end
				end)
			end)
		end, vector2_2, true)

		task.spawn(Leaderboards.start)

		LobbyFeatured.mount(player, data.playerGui)

		MarketplaceService.PromptProductPurchaseFinished:Connect(function(p: number, p2: number, flag: boolean)
			if p == player.UserId and flag and CareerData.giftProduct(p2) then
				return
			end

			if p == player.UserId and flag then
				toast("Thanks! It's yours.", true)

				local product = CareerData.product(p2)

				if not product or product.kind ~= "revive" then
					if product and product.kind == "crate" then
						assert(
							ArmoryStore.openBought,
							"[LobbyMenus] the store is not mounted: crates bought cannot open"
						)(product.n)
					elseif product and product.kind ~= "scrap" then
						PurchaseShow.play(data.playerGui, product)
					elseif product then
						local v7 = {
							image = product.image,
							caption = "Thanks! It's yours.",
							title = 0,
							amount = 0,
							alive = 0,
							done = 0,
							cancel = 0
						}
						local title

						if not product.scrap then
							title = product.name
						end

						v7.title = title
						v7.amount = product.scrap
						function v7.alive(): boolean
							return true
						end

						function v7.done(_: Vector2) end
						function v7.cancel() end

						revealFx(v7)
					end
				end

				task.delay(1, poll)
			end
		end)

		task.spawn(function()
			local child = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Remotes"):WaitForChild(CareerData.GIFT_REMOTE)

			local function revealGift(data2, giftFrom: string?)
				if data2.kind == "scrap" then
					revealFx({
						image = data2.image,
						caption = not giftFrom and "Thanks! It's yours." or "GIFT FROM " .. string.upper(giftFrom),
						amount = data2.scrap,
						alive = function(): boolean
							return true
						end,
						done = function(_: Vector2) end,
						cancel = function() end
					})
					return
				end

				local clone = table.clone(data2)
				clone.giftFrom = giftFrom
				PurchaseShow.play(data.playerGui, clone)
			end

			local v7 = {}
			local function inLobby(): boolean -- 2 equivalent calls inferred from this helper
				return player.Team == nil
			end

			local function openGift(data2)
				GiftOpen.play(data.playerGui, {
					fromName = data2.from,
					fromId = data2.fromId,
					reveal = function()
						revealGift(data2.product, data2.from)
					end
				})
			end
			task.spawn(function()
				while true do
					task.wait(1)

					if not (#v7 > 0) or not inLobby() or data.isDead() then -- inferred equivalent call
						continue
					end

					local v8 = v7
					v7 = {}

					for _, v9 in v8 do
						openGift(v9)
					end
				end
			end)
			child.OnClientEvent:Connect(function(p: string, value, value2, fromId)
				if p == "got" or p == "kept" then
					local product

					if type(value) == "string" then
						product = CareerData.byId(value)
					end

					if not product then
						return
					end

					if p ~= "got" or type(value2) ~= "string" then
						value2 = nil
					end

					if value2 then
						if type(fromId) ~= "number" or not (fromId > 0) then
							fromId = nil
						end

						local v8 = { product = product, from = value2, fromId = fromId }

						if inLobby() then -- inferred equivalent call
							openGift(v8)
						else
							table.insert(v7, v8)
							toast("A gift from " .. value2 .. "! Open it in the lobby.", true)
						end
					else
						revealGift(product, nil)
						toast("Thanks! It's yours.", true)
					end

					task.delay(1, poll)
				elseif p == "sent" then
					toast("Gift sent to " .. tostring(value2) .. "!", true)
				elseif p == "told" and type(value) == "string" and type(value2) == "string" then
					local v8

					if type(fromId) == "string" then
						v8 = CareerData.byId(fromId)
					end

					local TextChatService = game:GetService("TextChatService")
					local textChannels = TextChatService:FindFirstChild("TextChannels")
					local rbxGeneral = textChannels and textChannels:FindFirstChild("RBXGeneral")

					if v8 and rbxGeneral and rbxGeneral:IsA("TextChannel") then
						local v9 = string.format(
							"<font color=\"#FFC83C\"><b>%s</b> sent <b>%s</b> a gift: %s!</font>",
							Style.escape(value),
							Style.escape(value2),
							Style.escape(v8.name)
						)
						pcall(function()
							rbxGeneral:DisplaySystemMessage(v9)
						end)
					end
				end
			end)
		end)
		player.AttributeChanged:Connect(function(value: string)
			if value == "Scrap" or value == CareerData.BOOST_ATTR or string.sub(value, 1, 5) == "Owns_" then
				refreshAll()
			end
		end)

		local v7 = nil
		local total = 0
		local total2 = 0

		local object = setmetatable({}, { __mode = "k" })
		local function stations(folder)
			local parts = object[folder]

			if parts and #parts ~= 0 then
				return parts
			end

			parts = {}

			for _, part in folder:GetDescendants() do
				if part.Name == "Station" and part:IsA("BasePart") then
					table.insert(parts, part)
				end
			end

			object[folder] = parts

			return parts
		end

		RunService.Heartbeat:Connect(function(dt)
			total += dt
			total2 += dt

			if v3 and total2 >= 1 then
				total2 = 0
				task.spawn(poll)
			end

			if total < 0.1 then
				return
			end

			total = 0
			local v8

			if player.Team == nil then
				v8 = player:GetAttribute("PickingTeam") == true
			else
				v8 = false
			end

			local character = player.Character
			local humanoidRootPart = v8 and character and character:FindFirstChild("HumanoidRootPart")

			if v8 and humanoidRootPart and not data.isDead() then
				local v9 = nil

				for _, v10 in CollectionService:GetTagged("SkyLobby") do
					for _, v11 in stations(v10) do
						local radius = v11:GetAttribute("Radius")
						local kind = v11:GetAttribute("Kind")
						local v12 = humanoidRootPart.Position - v11.Position

						if not (type(radius) == "number" and type(kind) == "string") then
							continue
						end

						if not (Vector3.new(v12.X, 0, v12.Z).Magnitude < radius and math.abs(v12.Y) < 8) then
							continue
						end

						v9 = kind
					end
				end

				if v9 ~= v7 then
					v7 = v9

					if v9 == "shop" then
						setOpen(nil)
						assert(Armory.openLoadout, "[LobbyMenus] the ARMORY is not mounted")()
					elseif v9 == "store" then
						setOpen(nil)
						local Store = require(script.Parent:WaitForChild("Store"))
						assert(Store.open, "[LobbyMenus] the STORE screen is not mounted")()
					elseif v9 == "vehicles" then
						setOpen(nil)
						local Garage = require(script.Parent:WaitForChild("Garage"))
						assert(Garage.open, "[LobbyMenus] the VEHICLES screen is not mounted")()
					elseif v9 and v2[v9] then
						assert(Armory.close, "[LobbyMenus] the ARMORY is not mounted")()
						setOpen(v9)
					end
				end
			else
				v7 = nil

				if v3 then
					setOpen(nil)
				end
			end
		end)
		refreshAll()
	end
}