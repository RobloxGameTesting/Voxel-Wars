local Style = require(script.Parent:WaitForChild("Style"))
local KillFeed = require(script.Parent:WaitForChild("KillFeed"))

local ScoreFeed = {}

local white = Style.WHITE
local color = Color3.fromRGB(255, 84, 64)
local color2 = Color3.new(1, 1, 1)
local ink = Style.INK
local panel = Style.PANEL
local PANEL_ALPHA = Style.PANEL_ALPHA
local hazard = Style.HAZARD
local ink2 = Style.INK

local font = Style.FONT
local font2 = Style.FONT
local FONT_BODY = Style.FONT_BODY

local v = {
	TAKEDOWN = "KILL",
	SUPPORT = "SUPPORT",
	REVIVE = "REVIVE",
	BREACH = "BREACH",
	DEMOLITION = "DEMOLITION",
	BEACON = "BEACON DOWN",
	SPAWN = "SPAWN DESTROYED",
	SPAWN_HIT = "SPAWN DAMAGE",
	WIN = "ROUND WON",
	ROUND = "ROUND PLAYED",
	VEHICLE_HIT = "VEHICLE DAMAGE",
	VEHICLE_DOWN = "VEHICLE WRECKED",
	VEHICLE_ASSIST = "WRECK SUPPORT",
	TURRET_HIT = "TURRET DAMAGE",
	TURRET_DOWN = "TURRET DESTROYED"
}

local v2 = { [2] = "DOUBLE KILL", [3] = "TRIPLE KILL" }

local v3 = {
	BREACH = true,
	DEMOLITION = true,
	["VEHICLE DAMAGE"] = true,
	["SPAWN DAMAGE"] = true,
	["TURRET DAMAGE"] = true
}

local function vis(p: number, p2: number) -- 5 equivalent calls inferred from this helper
	return 1 - (1 - p) * p2
end

local function since(p: number, p2: number, p3: number) -- 10 equivalent calls inferred from this helper
	return (math.clamp((p - p2) / p3, 0, 1))
end

local function text(parent, name: string, textSize: number, fontFace, textColor: Color3) -- 4 equivalent calls inferred from this helper
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = name
	textLabel.BackgroundTransparency = 1
	textLabel.BorderSizePixel = 0
	textLabel.FontFace = fontFace
	textLabel.TextSize = textSize
	textLabel.TextColor3 = textColor
	textLabel.Text = ""
	textLabel.Size = UDim2.fromOffset(0, textSize + 2)
	textLabel.AutomaticSize = Enum.AutomaticSize.X
	textLabel.Parent = parent
	return textLabel
end

local function row(p, p2: string, p3: number, p4: number, vector2: Vector2)
	local frame = Style.frame(p, p2, UDim2.fromOffset(0, p3), nil, vector2)
	frame.AutomaticSize = Enum.AutomaticSize.X
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0, p4)
	uiListLayout.Parent = frame
	return frame
end

local function px(p: number) -- 4 equivalent calls inferred from this helper
	return (math.max(1, (math.floor(p + 0.5))))
end

local function iconFlash(frame)
	local fill = Style.fill(
		frame,
		"Flash",
		color2,
		UDim2.new(1, 6, 1, 4),
		UDim2.fromScale(0.5, 0.5),
		Vector2.new(0.5, 0.5)
	)
	fill.ZIndex = 3
	fill.BackgroundTransparency = 1
	return fill
end

local function skull(p, p2: number, imageColor: Color3, flag: boolean)
	local frame = Style.frame(p, "Skull", UDim2.fromOffset(p2, p2))
	local image = Instance.new("ImageLabel")
	image.Name = "Image"
	image.BackgroundTransparency = 1
	image.BorderSizePixel = 0
	image.Image = "rbxassetid://98055525641890"
	image.ImageColor3 = imageColor
	image.ScaleType = Enum.ScaleType.Fit
	image.AnchorPoint = Vector2.new(0.5, 0.5)
	image.Position = UDim2.fromScale(0.5, 0.5)
	image.Size = UDim2.fromScale(1, 1)
	image.Parent = frame
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = image
	local flash

	if flag then
		flash = iconFlash(frame)
	end

	return {
		holder = frame,
		image = image,
		pop = uiScale,
		solid = {},
		dark = {},
		strokes = {},
		flash = flash,
		base = 0,
		t0 = -10
	}
end

local function diamond(p, p2: number, white2: Color3)
	local frame = Style.frame(p, "Diamond", UDim2.fromOffset(p2, p2))
	local frame2 = Style.frame(
		frame,
		"Shape",
		UDim2.fromOffset(px(p2 * 0.6), px(p2 * 0.6)), -- inferred equivalent call
		UDim2.fromScale(0.5, 0.5),
		Vector2.new(0.5, 0.5)
	)
	frame2.Rotation = 45
	local stroke = Style.stroke(frame2, 2, 0, white2, true)
	local fill = Style.fill(
		frame,
		"Core",
		white2,
		UDim2.fromOffset(px(p2 * 0.24), px(p2 * 0.24)), -- inferred equivalent call
		UDim2.fromScale(0.5, 0.5),
		Vector2.new(0.5, 0.5)
	)
	fill.Rotation = 45
	return {
		holder = frame,
		solid = { fill },
		dark = {},
		strokes = { stroke },
		flash = iconFlash(frame),
		base = 0,
		t0 = -10
	}
end

local object = setmetatable({}, { __mode = "k" })
local function put(p, p2: string, p3) -- 32 equivalent calls inferred from this helper
	local v4 = object[p]

	if not v4 then
		v4 = {}
		object[p] = v4
	end

	if v4[p2] ~= p3 then
		v4[p2] = p3
		p[p2] = p3
	end
end

local function paintIcon(data, p: number, p2: number)
	for _, v4 in data.solid do
		put(v4, "BackgroundTransparency", vis(data.base, p)) -- inferred equivalent call
	end

	for _, v4 in data.dark do
		put(v4, "BackgroundTransparency", vis(math.max(data.base, 0.1), p)) -- inferred equivalent call
	end

	for _, stroke in data.strokes do
		put(stroke, "Transparency", vis(data.base, p)) -- inferred equivalent call
	end

	if data.image then
		put(data.image, "ImageTransparency", vis(data.base, p)) -- inferred equivalent call
	end

	if data.pop then
		local v4 = 1 - since(p2, data.t0, 0.24) -- inferred equivalent call
		put(data.pop, "Scale", v4 * 0.8 * v4 + 1) -- inferred equivalent call
	end

	if data.flash then
		put(data.flash, "BackgroundTransparency", vis(Style.easeOut(since(p2, data.t0, 0.22)), p)) -- inferred equivalent call
	end
end

function ScoreFeed.new(p)
	local region = Style.region(p, "ScorePopups", Vector2.new(0.5, 0.5), Vector2.zero, Vector2.new(640, 480))
	region.Visible = false
	local parent = text(region, "Total", 40, font, white) -- inferred equivalent call
	parent.AnchorPoint = Vector2.new(0, 0.5)
	parent.Position = UDim2.fromOffset(172, 360)
	local stroke = Style.stroke(parent, 2, 0.25)
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = parent
	local fill = Style.fill(
		parent,
		"Flash",
		color2,
		UDim2.new(1, 8, 1, -2),
		UDim2.fromScale(0.5, 0.5),
		Vector2.new(0.5, 0.5)
	)
	fill.BackgroundTransparency = 1

	local v4 = row(region, "Icons", 36, 6, Vector2.new(1, 0.5))
	v4.Position = UDim2.fromOffset(160, 360)
	local textLabel = text(region, "Name", 21, FONT_BODY, color) -- inferred equivalent call
	textLabel.AutoLocalize = false
	textLabel.AnchorPoint = Vector2.new(1, 0.5)
	textLabel.Position = UDim2.fromOffset(160, 400)
	local stroke2 = Style.stroke(textLabel, 2, 0.3)
	local fill2 = Style.fill(
		textLabel,
		"Flash",
		color,
		UDim2.new(1, 8, 1, -2),
		UDim2.fromScale(0.5, 0.5),
		Vector2.new(0.5, 0.5)
	)
	fill2.BackgroundTransparency = 1

	local v5 = row(region, "Tags", 26, 5, Vector2.new(1, 0.5))
	local v6 = {}

	for i = 1, 6 do
		local fill3 = Style.fill(v5, "Tag" .. i, panel, UDim2.fromOffset(0, 26))
		fill3.AutomaticSize = Enum.AutomaticSize.X
		fill3.Visible = false
		Style.corner(fill3, 2)
		local stroke3 = Style.stroke(fill3, 2, 0.35, Color3.new(0, 0, 0), true)
		local uiListLayout = Instance.new("UIListLayout")
		uiListLayout.FillDirection = Enum.FillDirection.Horizontal
		uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uiListLayout.Padding = UDim.new(0, 8)
		uiListLayout.Parent = fill3
		local uiPadding = Instance.new("UIPadding")
		uiPadding.PaddingRight = UDim.new(0, 9)
		uiPadding.Parent = fill3
		local fill4 = Style.fill(fill3, "Edge", Style.HAZARD, UDim2.fromOffset(5, 26))
		fill4.LayoutOrder = 1
		local label = text(fill3, "Text", 18, font2, white) -- inferred equivalent call
		label.Size = UDim2.fromOffset(0, 26)
		label.LayoutOrder = 2
		v6[i] = {
			frame = fill3,
			stripe = fill4,
			label = label,
			stroke = stroke3,
			key = "",
			count = 0,
			t0 = 0,
			live = false
		}
	end

	local v7 = row(region, "Badge", 29, 4, Vector2.new(1, 0.5))
	v7.Visible = false
	local fill3 = Style.fill(v7, "Label", hazard, UDim2.fromOffset(0, 27))
	fill3.AutomaticSize = Enum.AutomaticSize.X
	fill3.LayoutOrder = 1
	Style.corner(fill3, 2)
	local stroke3 = Style.stroke(fill3, 2, 0, nil, true)
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, 8)
	uiPadding.PaddingRight = UDim.new(0, 8)
	uiPadding.Parent = fill3
	local textLabel2 = text(fill3, "Text", 18, font2, ink2) -- inferred equivalent call
	textLabel2.Size = UDim2.fromOffset(0, 27)
	local parent2 = row(v7, "Emblem", 28, 3, Vector2.zero)
	parent2.LayoutOrder = 2
	local v8 = {}
	local function speedLines(layoutOrder: number, flag: boolean)
		local frame = Style.frame(parent2, "Lines", UDim2.fromOffset(11, 24))
		frame.LayoutOrder = layoutOrder

		for k, v9 in { 4, 11, 18 } do
			local v10 = k == 2 and 11 or 7
			local fill4 = Style.fill(
				frame,
				"Line",
				white,
				UDim2.fromOffset(v10, 3),
				UDim2.fromOffset(flag and 0 or 11 - v10, v9)
			)
			table.insert(v8, fill4)
		end
	end
	local function bracket(layoutOrder: number, flag: boolean)
		local frame = Style.frame(parent2, "Bracket", UDim2.fromOffset(7, 26))
		frame.LayoutOrder = layoutOrder

		table.insert(
			v8,
			Style.fill(frame, "Bar", Style.HAZARD, UDim2.fromOffset(3, 26), UDim2.fromOffset(flag and 4 or 0, 0))
		)
		table.insert(v8, Style.fill(frame, "Top", Style.HAZARD, UDim2.fromOffset(7, 3), UDim2.fromOffset(0, 0)))
		table.insert(v8, Style.fill(frame, "Bottom", Style.HAZARD, UDim2.fromOffset(7, 3), UDim2.fromOffset(0, 23)))
	end
	speedLines(1, false)
	bracket(2, false)
	local v9 = {}

	local v10 = skull(parent2, 21, white, false)
	v10.holder.LayoutOrder = 3
	v9[1] = v10
	local v11 = skull(parent2, 21, white, false)
	v11.holder.LayoutOrder = 4
	v9[2] = v11
	local v12 = skull(parent2, 21, white, false)
	v12.holder.LayoutOrder = 5
	v9[3] = v12

	bracket(6, true)
	speedLines(7, true)

	local fill4 = Style.fill(region, "Streak", color2, UDim2.fromOffset(0, 3), UDim2.new(), Vector2.new(1, 0.5))
	fill4.Visible = false

	local v13 = false
	local v14 = 0
	local v15 = 0
	local total = 0
	local v16 = 0
	local v17 = -10
	local count = 0
	local v18 = {}
	local v19 = nil
	local v20 = -10
	local count2 = 0
	local v21 = -10
	local v22 = false
	local v23 = false

	local function shownTotal(p2: number) -- 2 equivalent calls inferred from this helper
		local easeOut = Style.easeOut(since(p2, v17, 0.3)) -- inferred equivalent call
		return (math.floor(v16 + (total - v16) * easeOut + 0.5))
	end

	local v24 = { skull = {}, diamond = {} }
	local function dropIcon(p2) -- 2 equivalent calls inferred from this helper
		p2.holder.Visible = false
		local v25 = if p2.image then v24.skull else v24.diamond
		table.insert(v25, p2)
	end

	local function clearIcons() -- 1 equivalent call inferred from this helper
		for _, v25 in v18 do
			dropIcon(v25) -- inferred equivalent call
		end

		table.clear(v18)
	end

	local function reset() -- 2 equivalent calls inferred from this helper
		v13 = false
		region.Visible = false
		total = 0
		v16 = 0
		v17 = -10
		count = 0
		clearIcons() -- inferred equivalent call
		v19 = nil

		for _, v25 in v6 do
			v25.live = false
			v25.frame.Visible = false
		end

		v22 = false
		v7.Visible = false
		fill4.Visible = false
	end

	local function addIcon(p2: string, now: number)
		local imageColor = if p2 == "head" then color else white
		local v25 = if p2 == "beacon" then v24.diamond else v24.skull
		local v26 = table.remove(v25)

		if v26 then
			v26.holder.Visible = true
			v26.base = 0

			if v26.image then
				v26.image.ImageColor3 = imageColor
			end
		elseif p2 == "beacon" then
			v26 = diamond(v4, 36, white)
		else
			v26 = skull(v4, 36, imageColor, true)
		end

		assert(v26)

		if p2 == "support" then
			v26.base = 0.45
		end

		v26.t0 = now
		count2 += 1
		v26.holder.LayoutOrder = count2
		table.insert(v18, v26)

		while #v18 > 2 do
			dropIcon(table.remove(v18, 1)) -- inferred equivalent call
		end
	end

	local function addTag(p2: string, count3: number, now: number)
		local v25 = nil

		for _, v26 in v6 do
			if v26.live and v26.key == p2 then
				v25 = v26
				break
			end
		end

		if v25 then
			v25.count += count3
		else
			for _, v26 in v6 do
				if not v26.live then
					v25 = v26
					break
				end
			end

			if not v25 then
				v25 = v6[1]

				for _, v26 in v6 do
					if v26.frame.LayoutOrder < v25.frame.LayoutOrder then
						v25 = v26
					end
				end
			end

			v25.live = true
			v25.key = p2
			v25.count = count3
			count2 += 1
			v25.frame.LayoutOrder = count2
			v25.frame.Visible = true
		end

		v25.t0 = now
		v25.label.Text = p2 .. ((not (v25.count > 1) or v3[p2]) and "" or " x" .. v25.count)
	end

	local function setBadge(text2: string, p2: number, imageColor: Color3, now: number)
		textLabel2.Text = text2

		for k, v25 in v9 do
			v25.holder.Visible = k <= p2

			if v25.image then
				v25.image.ImageColor3 = imageColor
			end

			v25.t0 = now
		end

		v22 = true
		v21 = now
		v7.Visible = true
		fill4.Visible = true
	end

	local function step(_, now: number): boolean
		if not v13 then
			return false
		end

		local v25 = now - v15

		if v25 >= 3.5500000000000003 then
			reset() -- inferred equivalent call
			return false
		else
			local v26

			if v25 >= 0.35 then
				v26 = v25 < 3.2
			else
				v26 = false
			end

			if v26 and v23 then
				return true
			end

			v23 = v26
			local v27

			if v25 < 3.2 then
				v27 = since(now, v14, 0.06) -- inferred equivalent call
			else
				v27 = 1 - (v25 - 3.2) / 0.35
			end

			local v28 = #v18 > 0
			local v29 = v28 and v19 ~= nil
			put(v4, "Visible", v28) -- inferred equivalent call
			put(textLabel, "Visible", v29) -- inferred equivalent call
			put(v5, "Position", UDim2.fromOffset(160, (v28 and (v29 and 192 or 162) or 120) + 240)) -- inferred equivalent call

			put(parent, "Text", Style.thousands(shownTotal(now))) -- inferred equivalent call
			put(parent, "TextTransparency", 1 - v27 * 1) -- inferred equivalent call
			put(stroke, "Transparency", 1 - v27 * 0.44999999999999996) -- inferred equivalent call
			put(fill, "BackgroundTransparency", 1 - (1 - Style.easeOut(since(now, v17, 0.22))) * v27) -- inferred equivalent call
			local v30 = 1 - since(now, v17, 0.24) -- inferred equivalent call

			put(uiScale, "Scale", v30 * 0.4 * v30 + 1) -- inferred equivalent call

			for _, v31 in v18 do
				paintIcon(v31, v27, now)
			end

			if v29 then
				local v31 = since(now, v20, 0.26) -- inferred equivalent call
				put(fill2, "BackgroundTransparency", 1 - (1 - (0.05 + 0.95 * Style.easeOut(v31))) * v27) -- inferred equivalent call
				put(textLabel, "TextTransparency", 1 - (1 - (1 - since(now, v20 + 0.06, 0.12))) * v27) -- inferred equivalent call
				put(stroke2, "Transparency", 1 - v27 * 0.4) -- inferred equivalent call
			end

			for _, v31 in v6 do
				if not v31.live then
					continue
				end

				local v32 = since(now, v31.t0, 0.22) -- inferred equivalent call
				put(v31.frame, "BackgroundColor3", color2:Lerp(panel, v32)) -- inferred equivalent call
				put(v31.frame, "BackgroundTransparency", 1 - (1 - (0.05 + (PANEL_ALPHA - 0.05) * v32)) * v27) -- inferred equivalent call
				put(v31.label, "TextColor3", ink:Lerp(white, v32)) -- inferred equivalent call
				put(v31.label, "TextTransparency", 1 - v27 * 1) -- inferred equivalent call
				put(v31.stroke, "Transparency", 1 - v27 * 0.65) -- inferred equivalent call
				put(v31.stripe, "BackgroundTransparency", 1 - v27 * 1) -- inferred equivalent call
			end

			if not v22 then
				return true
			end

			local v31 = since(now, v21, 0.2) -- inferred equivalent call
			local easeOut = Style.easeOut(v31)
			local v32 = -56 * (1 - easeOut)
			put(v7, "Position", UDim2.fromOffset(160 + v32, 314)) -- inferred equivalent call
			put(fill3, "BackgroundColor3", color2:Lerp(hazard, v31)) -- inferred equivalent call
			put(fill3, "BackgroundTransparency", 1 - v27 * 1) -- inferred equivalent call
			put(stroke3, "Transparency", 1 - v27 * 1) -- inferred equivalent call
			put(textLabel2, "TextTransparency", 1 - v27 * 1) -- inferred equivalent call

			for _, v38 in v8 do
				put(v38, "BackgroundTransparency", 1 - v27 * 1) -- inferred equivalent call
			end

			for _, v38 in v9 do
				paintIcon(v38, v27, now)
			end

			local v38 = v7.AbsoluteSize.X / math.max(Style.scale(), 0.01)
			put(fill4, "Position", UDim2.fromOffset(160 + v32 - v38 - 3, 314)) -- inferred equivalent call
			put(fill4, "Size", UDim2.fromOffset(math.floor(130 * (1 - easeOut)), 4)) -- inferred equivalent call
			put(fill4, "BackgroundTransparency", 1 - (1 - (v31 * 0.8 + 0.2)) * v27) -- inferred equivalent call

			return true
		end
	end

	local v25 = {}
	v25.root = region

	function v25.push(p2: number, p3: string, p4: string?, value: number?, p5: string?, text2: string?)
		local now = os.clock()

		if not v13 or now - v15 >= 3.2 then
			reset() -- inferred equivalent call
			v13 = true
			v14 = now
		end

		v15 = now
		local count3 = value or 1
		v16 = shownTotal(now) -- inferred equivalent call
		total += p2
		v17 = now

		if p3 == "TAKEDOWN" then
			count += 1
			local v26 = p5 == "head"
			addIcon(v26 and "head" or "kill", now)
			addTag(v26 and "HEADSHOT" or "KILL", count3, now)

			if p4 then
				v19 = p4
				textLabel.Text = KillFeed.shown(p4)
				v20 = now
			end

			if text2 == "SHUTDOWN" or text2 == "PAYBACK" then
				setBadge(text2, 1, color, now)
			elseif count >= 2 then
				setBadge(v2[count] or "MULTI KILL", math.min(count, 3), white, now)
			end
		else
			if p3 == "SUPPORT" then
				addIcon("support", now)

				if p4 then
					v19 = p4
					textLabel.Text = KillFeed.shown(p4)
					v20 = now
				end
			elseif p3 == "BEACON" or p3 == "SPAWN" or p3 == "SPAWN_HIT" or p3 == "NEUTRALIZED" or p3 == "CAPTURED" then
				addIcon("beacon", now)
			end

			addTag(v[p3] or p3, count3, now)
		end

		region.Visible = true
		step(0, now)
		Style.animate(v25, step)
	end

	return v25
end

function ScoreFeed.listen(p, remote, p2)
	local v4 = { remote = remote }

	local v5 = nil
	local v6 = -1e999
	local v7 = {}
	v4.remote("Died").OnClientEvent:Connect(function(p3: string?)
		local now = os.clock()
		v5 = p3
		v6 = now
	end)
	v4.remote("Feed").OnClientEvent:Connect(function(p3: string, p4, value)
		if p3 == "shutdown" and p4 == p2.Name and type(value) == "string" then
			v7[value] = os.clock()
		end
	end)

	v4.remote("Score").OnClientEvent:Connect(function(p3: number, p4: string, p5: string?, p6: number?, p7: string?)
		local v8 = nil

		if p4 == "TAKEDOWN" and p5 then
			local now = os.clock()
			local v9 = v7[p5]
			v7[p5] = nil

			if v9 and now - v9 < 2 then
				v8 = "SHUTDOWN"
			elseif v5 == p5 and now - v6 < 60 then
				v8 = "PAYBACK"
				v5 = nil
			end
		end

		p.push(p3, p4, p5, p6, p7, v8)
	end)
end

function ScoreFeed.mount(data)
	local net = data.Net
	local player = data.player
	local v4 = ScoreFeed.new(data.layers.hud)
	ScoreFeed.listen(v4, net.remote, player)
end

return ScoreFeed