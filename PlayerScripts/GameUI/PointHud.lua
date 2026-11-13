local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Style = require(script.Parent.Style)
local Hardpoint = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("Hardpoint"))
local SpawnRaid = require(ReplicatedStorage.Game:WaitForChild("SpawnRaid"))
local TeamDeathmatch = require(ReplicatedStorage.Game:WaitForChild("TeamDeathmatch"))
local MapBuilder = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("MapBuilder"))
local WorldConfig = require(ReplicatedStorage.Voxel:WaitForChild("WorldConfig"))

local PointHud = {}

local points = Hardpoint.POINTS
local v = #points > 1

local MapSelect = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("MapSelect"))

local function pulse(now: number) -- 3 equivalent calls inferred from this helper
	return (math.sin(math.floor(now * 10) / 10 * 8))
end

local function teamWord(value: string) -- 1 equivalent call inferred from this helper
	return string.upper(value)
end

local function pointIcon(p, p2: number, p3: string, p4: string?)
	local frame = Style.frame(p, p3, UDim2.fromOffset(p2, p2))
	local v2 = (math.max)(1.5, p2 * 0.07)
	local udim = UDim2.fromScale(0.5, 0.5)
	local vector2 = Vector2.new(0.5, 0.5)
	local fill = Style.fill(frame, "Ring", Style.INK, UDim2.fromScale(0.9, 0.9), udim, vector2)
	Style.corner(fill, p2)
	local stroke = Style.stroke(fill, v2, 0, Style.WHITE, true)
	local fill2 = Style.fill(frame, "Diamond", Style.INK, UDim2.fromScale(0.66, 0.66), udim, vector2)
	fill2.Rotation = 45
	Style.corner(fill2, 2)
	local stroke2 = Style.stroke(fill2, v2, 0, Style.WHITE, true)
	local fill3 = Style.fill(frame, "Square", Style.INK, UDim2.fromScale(0.72, 0.72), udim, vector2)
	fill3.BackgroundTransparency = 0.5
	fill3.ClipsDescendants = true
	Style.corner(fill3, 2)
	Style.stroke(fill3, v2, 0, Style.MUTED, true)
	local fill4 = Style.fill(fill3, "Fill", Style.WHITE, UDim2.fromScale(0, 1))

	if p4 then
		local label = Style.label(frame, "Letter", p4, (math.floor)(p2 * 0.55), Style.FONT, 1.5)
		label.AutomaticSize = Enum.AutomaticSize.None
		label.Size = UDim2.fromScale(1, 1)
		label.ZIndex = 3
	end

	local v3 = nil
	local v4 = nil
	local v5 = 0
	local v6 = 0
	local v7 = nil
	local function set(p5: string, color: Color3, p6: number, p7: number, backgroundColor: Color3)
		local v8 = math.round(p6 * 32) / 32
		local v9 = math.round(p7 * 32) / 32

		if p5 == v3 and color == v4 and v8 == v5 and v9 == v6 and backgroundColor == v7 then
			return
		end

		v3 = p5
		v4 = color
		v5 = v8
		v6 = v9
		v7 = backgroundColor
		fill.Visible = p5 == "ring"
		fill2.Visible = p5 == "diamond"
		fill3.Visible = p5 == "square"

		if p5 == "square" then
			fill4.Size = UDim2.fromScale(v9, 1)
			fill4.BackgroundColor3 = backgroundColor
		else
			local v10 = if p5 == "ring" then fill else fill2
			local v11 = if p5 == "ring" then stroke else stroke2
			v10.BackgroundColor3 = color:Lerp(Style.INK, 0.6)
			v10.BackgroundTransparency = 1 - v8 * 0.85
			v11.Color = color
			v11.Transparency = 1 - v8
		end
	end
	return { holder = frame, set = set }
end

local function iconLook(holder: string, mine: string, p: number)
	if holder == "" then
		local v2 = p > 0 and "Reds" or p < 0 and "Blues" or mine
		return "square", Style.STEEL, 1, math.abs(p), Style.teamColor(v2)
	end

	local teamColor = Style.teamColor(holder)
	return holder == mine and "ring" or "diamond", teamColor, math.clamp(math.abs(p), 0.2, 1), 0, teamColor
end

local function pointWord(eventPoint: number) -- 3 equivalent calls inferred from this helper
	return points[eventPoint].letter .. "  ·  " .. points[eventPoint].name
end

local function scoreSide(region, flag: boolean)
	local v2 = flag and 0 or 1
	local fill = Style.fill(
		region,
		flag and "MineBox" or "TheirsBox",
		Style.PANEL,
		UDim2.fromOffset(60, 26),
		UDim2.new(v2, 0, 0, 14),
		Vector2.new(v2, 0.5)
	)
	Style.corner(fill, 2)
	local label = Style.label(fill, "Points", "0", 22, Style.FONT, 1.5)
	label.AutomaticSize = Enum.AutomaticSize.None
	label.Size = UDim2.fromScale(1, 1)
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = label
	local fill2 = Style.fill(
		region,
		"Track",
		Style.INK,
		UDim2.fromOffset(90, 6),
		UDim2.new(0, flag and 66 or 204, 0, 14),
		Vector2.new(0, 0.5)
	)
	fill2.BackgroundTransparency = 0.45
	local fill3 = Style.fill(
		fill2,
		"Fill",
		Style.WHITE,
		UDim2.fromScale(0, 1),
		UDim2.fromScale(v2, 0),
		Vector2.new(v2, 0)
	)

	local v3 = ""
	local v4 = -1
	local v5 = nil
	return {
		show = function(visible: boolean)
			fill.Visible = visible
			fill2.Visible = visible
		end,
		set = function(p: string, p2: number, p3: number, flag2: boolean)
			if p ~= v3 then
				v3 = p
				fill.BackgroundColor3 = Style.teamColor(p):Lerp(Style.INK, 0.65)
				fill.BackgroundTransparency = 0.2
				label.TextColor3 = Style.teamText(p)
				fill3.BackgroundColor3 = Style.teamColor(p)
				v4 = -1
				v5 = nil
			end

			if p2 ~= v4 or flag2 ~= v5 then
				local v6

				if v4 >= 0 then
					v6 = v4 < p2
				else
					v6 = false
				end

				v4 = p2
				v5 = flag2
				local text

				if flag2 then
					text = "[" .. p2 .. "]"
				else
					text = tostring(p2)
				end

				label.Text = text
				fill3.Size = UDim2.fromScale(math.clamp(p2 / math.max(p3, 1), 0, 1), 1)

				if v6 then
					local now = os.clock()
					Style.animate(uiScale, function(_, p4): boolean
						local v7 = (p4 - now) / 0.2
						uiScale.Scale = 1 + 0.12 * (1 - Style.easeOut(v7))
						return v7 < 1
					end)
				end
			end
		end
	}
end

local function bracket(frame, p: number, p2: number)
	local frame2 = Style.frame(frame, "Bracket", UDim2.fromOffset(10, 10))
	frame2.AnchorPoint = Vector2.new((p + 1) / 2, (p2 + 1) / 2)
	local midpoint = (p + 1) / 2
	local midpoint2 = (p2 + 1) / 2
	Style.fill(
		frame2,
		"H",
		Style.HAZARD,
		UDim2.new(1, 0, 0, 2.5),
		UDim2.fromScale(0, midpoint2),
		Vector2.new(0, midpoint2)
	)
	Style.fill(
		frame2,
		"V",
		Style.HAZARD,
		UDim2.new(0, 2.5, 1, 0),
		UDim2.fromScale(midpoint, 0),
		Vector2.new(midpoint, 0)
	)
	return frame2
end

function PointHud.new(screenGui, p)
	local region = Style.region(
		screenGui,
		"PointHud",
		Vector2.new(0.5, 0),
		Vector2.new(0, Style.topInset() + 6),
		Vector2.new(360, 200)
	)

	assert(screenGui:IsA("ScreenGui"), "PointHud: the hud layer is not a ScreenGui")
	local layer = Style.layer(p, screenGui.Name .. "Fx", screenGui.DisplayOrder)
	layer.IgnoreGuiInset = screenGui.IgnoreGuiInset
	layer.ScreenInsets = screenGui.ScreenInsets
	local region2 = Style.region(
		layer,
		"PointHud",
		Vector2.new(0.5, 0),
		Vector2.new(0, Style.topInset() + 6),
		Vector2.new(360, 200)
	)

	local v2 = scoreSide(region, true)
	local v3 = scoreSide(region, false)

	local workEntries = {}
	local v4 = nil

	for k, point in points do
		local v5 = not v and "Point" or "Point" .. point.id
		local v6

		if v then
			v6 = point.letter
		end

		local icon = pointIcon(region, 22, v5, v6)
		icon.holder.AnchorPoint = Vector2.new(0.5, 0)
		icon.holder.Position = UDim2.new(0.5, (k - (#points + 1) / 2) * 30, 0, 32)
		local work

		if v then
			work = Style.fill(icon.holder, "Work", Style.HAZARD, UDim2.new(1, 0, 0, 2), UDim2.new(0, 0, 1, 2))
			work.Visible = false
		end

		workEntries[k] = { icon = icon, work = work, workKey = "", workT = -1 }
	end

	local label = Style.label(region, "Clock", "", 15, Style.FONT, 1.5)
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.new(0.5, 0, 0, 14)

	local label2 = Style.label(region, "SpawnsWord", "SPAWNS", 12, Style.FONT, 1)
	label2.TextColor3 = Style.MUTED
	label2.AnchorPoint = Vector2.new(0.5, 0)
	label2.Position = UDim2.new(0.5, 0, 0, 35)
	label2.Visible = false

	local label3 = Style.label(region, "Message", "", 14, Style.FONT, 1.5)
	label3.AnchorPoint = Vector2.new(0.5, 0)
	label3.Position = UDim2.new(0.5, 0, 0, 60)
	label3.Visible = false

	local frame = Style.frame(region, "Zone", UDim2.fromOffset(360, 110), UDim2.fromOffset(0, 78))
	frame.Visible = false
	local frame2 = Style.frame(
		frame,
		"BigHolder",
		UDim2.fromOffset(46, 46),
		UDim2.new(0.5, 0, 0, 4),
		Vector2.new(0.5, 0)
	)

	local v5 = {}
	local v6 = nil
	local v7 = ""
	local v8 = nil

	for k, point in points do
		local v9 = not v and "Big" or "Big" .. point.id
		local v10

		if v then
			v10 = point.letter
		end

		v5[k] = pointIcon(frame2, 46, v9, v10)
		v5[k].holder.Visible = not v
	end

	local v9 = not v and 1 or nil
	local frame3 = Style.frame(region2, "Zone", UDim2.fromOffset(360, 110), UDim2.fromOffset(0, 78))
	frame3.Visible = false
	local frame4 = Style.frame(
		frame3,
		"BigHolder",
		UDim2.fromOffset(46, 46),
		UDim2.new(0.5, 0, 0, 4),
		Vector2.new(0.5, 0)
	)
	local frame5 = Style.frame(frame4, "Burst", UDim2.fromScale(1, 1), UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5))
	Style.corner(frame5, 46)
	local stroke = Style.stroke(frame5, 3, 1, Style.WHITE, true)
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = frame5
	local v10 = {}

	for _, v11 in {
		{ -1, -1 },
		{ 1, -1 },
		{ -1, 1 },
		{ 1, 1 }
	} do
		table.insert(v10, {
			f = bracket(frame4, v11[1], v11[2]),
			cx = v11[1],
			cy = v11[2]
		})
	end

	local label4 = Style.label(frame, "MineCount", "0", 14, Style.FONT, 1.5)
	label4.AnchorPoint = Vector2.new(1, 0.5)
	label4.Position = UDim2.new(0.5, -52, 0, 60)
	local label5 = Style.label(frame, "TheirsCount", "0", 14, Style.FONT, 1.5)
	label5.AnchorPoint = Vector2.new(0, 0.5)
	label5.Position = UDim2.new(0.5, 52, 0, 60)
	local fill = Style.fill(
		frame,
		"Tug",
		Style.INK,
		UDim2.fromOffset(92, 4),
		UDim2.new(0.5, 0, 0, 60),
		Vector2.new(0.5, 0.5)
	)
	fill.BackgroundTransparency = 0.45
	local fill2 = Style.fill(fill, "Mine", Style.WHITE, UDim2.fromScale(0.5, 1))
	local fill3 = Style.fill(
		fill,
		"Theirs",
		Style.WHITE,
		UDim2.fromScale(0.5, 1),
		UDim2.fromScale(1, 0),
		Vector2.new(1, 0)
	)

	local label6 = Style.label(frame, "Word", "", 16, Style.FONT, 1.5)
	label6.AnchorPoint = Vector2.new(0.5, 0.5)
	label6.Position = UDim2.new(0.5, 0, 0, 78)
	local fill4 = Style.fill(
		frame,
		"RuleTop",
		Style.MUTED,
		UDim2.fromOffset(150, 1),
		UDim2.new(0.5, 0, 0, 66),
		Vector2.new(0.5, 0.5)
	)
	local fill5 = Style.fill(
		frame,
		"RuleBottom",
		Style.MUTED,
		UDim2.fromOffset(150, 1),
		UDim2.new(0.5, 0, 0, 90),
		Vector2.new(0.5, 0.5)
	)

	local panel = Style.panel(region, "Banner", UDim2.fromOffset(0, 54))
	panel.AutomaticSize = Enum.AutomaticSize.X
	panel.AnchorPoint = Vector2.new(0.5, 0)
	panel.Position = UDim2.new(0.5, 0, 0, 60)
	panel.Visible = false
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uiListLayout.Parent = panel
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, 16)
	uiPadding.PaddingRight = UDim.new(0, 16)
	uiPadding.PaddingTop = UDim.new(0, 5)
	uiPadding.Parent = panel
	local label7 = Style.label(panel, "Headline", "", 24, Style.FONT, 1.5)
	label7.LayoutOrder = 1
	local label8 = Style.label(panel, "Detail", "", 13, Style.FONT_BODY, 1)
	label8.TextColor3 = Style.MUTED
	label8.LayoutOrder = 2

	local v11 = {}

	for k in points do
		v11[k] = 0
	end

	local v12 = 0
	local v13 = -10
	local v14 = nil
	local v15 = ""

	local v16 = false
	local v17 = false
	local v18 = false
	local v19 = ""
	local v20 = nil
	local v21 = 78
	local v22 = false
	local v23 = nil
	local v24 = ""

	local v25 = nil
	local v26 = ""
	local v27 = nil
	local bt = nil
	local function showBanner(visible: boolean) -- 1 equivalent call inferred from this helper
		if visible ~= v16 then
			v16 = visible
			panel.Visible = visible
		end
	end
	local function showZone(visible: boolean) -- 1 equivalent call inferred from this helper
		if visible ~= v17 then
			v17 = visible
			frame.Visible = visible
			frame3.Visible = visible
		end
	end
	local function showMsg(visible: boolean) -- 1 equivalent call inferred from this helper
		if visible ~= v18 then
			v18 = visible
			label3.Visible = visible
		end
	end

	local function set(data)
		local now = os.clock()
		local visible = screenGui.Enabled and region.Visible

		if visible ~= v4 then
			v4 = visible
			layer.Enabled = visible
		end

		local v28 = data.points[data.mine] or 0
		local v29 = data.points[data.theirs] or 0
		v2.set(data.mine, v28, data.target, v29 < v28)
		v3.set(data.theirs, v29, data.target, v28 < v29)

		if data.bt ~= bt then
			bt = data.bt
			v2.show(not data.bt)
			v3.show(not data.bt)
		end

		for k, pt in data.pts do
			local v30 = v11[k] + (pt.control - v11[k]) * 0.25

			if math.abs(pt.control - v30) < 0.005 then
				v30 = pt.control
			end

			v11[k] = v30
		end

		local raid = data.raid or data.tdm
		local v30 = data.tdm and "tdm" or data.raid and "raid" or "point"

		if v30 ~= v6 then
			v6 = v30

			for _, v31 in workEntries do
				v31.icon.holder.Visible = not raid
			end

			label2.Text = data.tdm and "KILLS" or "SPAWNS"
			label2.Visible = raid
		end

		if not raid then
			for k, v31 in workEntries do
				local pt = data.pts[k]
				v31.icon.set(iconLook(pt.holder, data.mine, v11[k]))
				local work = v31.work

				if not work then
					continue
				end

				local v32 = pt.mode == "neutralizing" or pt.mode == "capturing"
				local workKey = pt.mode == "contested" and "c"
					or v32 and ((pt.on.Reds or 0) > (pt.on.Blues or 0) and "Reds" or "Blues")
					or ""

				if workKey ~= v31.workKey then
					v31.workKey = workKey
					work.Visible = workKey ~= ""
					local backgroundColor

					if workKey == "c" then
						backgroundColor = Style.HAZARD
					elseif workKey == "" then
						backgroundColor = Style.HAZARD
					else
						backgroundColor = Style.teamColor(workKey)
					end

					work.BackgroundColor3 = backgroundColor
				end

				if workKey == "" then
					continue
				end

				local v34 = 0.35 - pulse(now) * 0.35 -- inferred equivalent call

				if v34 == v31.workT then
					continue
				end

				v31.workT = v34
				work.BackgroundTransparency = v34
			end
		end

		local visible2 = data.phase == "over"

		local textColor = Style.WHITE
		local text

		if visible2 then
			text = ""
		elseif data.phase == "starting" then
			text = Style.clock(data.roundTime)
		elseif data.overtime then
			textColor = Style.HAZARD
			text = "OT"
		else
			local v31 = math.max(0, (math.ceil(data.endsIn)))
			text = Style.clock(v31)

			if v31 <= 30 then
				textColor = Style.HAZARD
			else
				textColor = Style.WHITE
			end
		end

		if text ~= v7 then
			v7 = text
			label.Text = text
		end

		if textColor ~= v8 then
			v8 = textColor
			label.TextColor3 = textColor
		end

		showBanner(visible2) -- inferred equivalent call

		if visible2 then
			if v17 ~= false then
				v17 = false
				frame.Visible = false
				frame3.Visible = false
			end

			if v18 ~= false then
				v18 = false
				label3.Visible = false
			end

			local v31

			if data.winner == "" then
				v31 = data.mine
			else
				v31 = data.winner
			end

			if v31 ~= v14 then
				v14 = v31
				label7.Text = teamWord(v31) .. " TAKE THE ROUND" -- inferred equivalent call
				label7.TextColor3 = Style.teamText(v31)
			end

			local text2

			if data.bt then
				text2 = "NEW ROUND IN " .. Style.clock(data.nextIn)
			else
				text2 = string.format(
					data.raid and "%d - %d SPAWNS LEFT  ·  NEW ROUND IN %s" or data.tdm and "%d - %d KILLS  ·  NEW ROUND IN %s" or "%d - %d  ·  NEW ROUND IN %s",
					data.points[v31] or 0,
					data.points[Hardpoint.other(v31)] or 0,
					Style.clock(data.nextIn)
				)
			end

			if text2 ~= v15 then
				v15 = text2
				label8.Text = text2
			end
		else
			v14 = nil
			local v31

			if data.event == "captured" or data.event == "neutralized" or data.event == "spawnlost" then
				v31 = data.eventAge < 3.5
			else
				v31 = false
			end

			showMsg(v31) -- inferred equivalent call

			if v31 then
				local text2, textColor2

				if data.event == "spawnlost" then
					local v32 = data.eventTeam == data.mine
					text2 = v32 and "WE LOST A SPAWN" or "ENEMY SPAWN DESTROYED"

					if v32 then
						textColor2 = Style.HAZARD
					else
						textColor2 = Style.teamText(data.mine)
					end
				else
					if v then
						local eventPoint = data.eventPoint
						assert(eventPoint, "PointHud: EventPoint names no point of this map")

						if data.event == "neutralized" then
							text2 = pointWord(eventPoint) .. " NEUTRALIZED" -- inferred equivalent call
						elseif data.eventTeam == data.mine then
							text2 = "WE HOLD " .. pointWord(eventPoint) -- inferred equivalent call
						else
							text2 = "THE ENEMY HOLDS " .. pointWord(eventPoint) -- inferred equivalent call
						end
					else
						text2 = data.event == "neutralized" and "POINT NEUTRALIZED"
							or data.eventTeam == data.mine and "WE HOLD THE POINT"
							or "THE ENEMY HOLDS THE POINT"
					end

					if data.event == "neutralized" then
						textColor2 = Style.WHITE
					else
						textColor2 = Style.teamText(data.eventTeam)
					end
				end

				if text2 ~= v19 then
					v19 = text2
					label3.Text = text2
				end

				if textColor2 ~= v20 then
					v20 = textColor2
					label3.TextColor3 = textColor2
				end
			end

			showZone(data.inZone and not raid) -- inferred equivalent call
			local v32 = v31 and 92 or 78

			if v32 ~= v21 then
				v21 = v32
				frame.Position = UDim2.fromOffset(0, v32)
				frame3.Position = UDim2.fromOffset(0, v32)
			end

			if not data.inZone or raid then
				return
			end

			local at = data.at

			if at ~= v9 then
				if v9 then
					v5[v9].holder.Visible = false
				end

				v9 = at
				v5[at].holder.Visible = true
			end

			v5[at].set(iconLook(data.holder, data.mine, v11[at]))
			local visible3 = data.eventPoint == at

			if data.eventAt ~= v12 then
				v12 = data.eventAt

				if data.event == "captured" and data.eventAge < 1 and visible3 then
					v13 = now
				end
			end

			local v38 = (now - v13) / 0.55

			if v38 < 1 then
				v22 = false
				uiScale.Scale = 1 + 0.9 * Style.easeOut(v38)
				stroke.Transparency = Style.easeIn(v38)
			elseif not v22 then
				v22 = true
				stroke.Transparency = 1
			end

			local visible4 = data.mode == "contested" or data.mode == "neutralizing" or data.mode == "capturing"

			if visible4 ~= v23 then
				v23 = visible4

				for _, v40 in v10 do
					v40.f.Visible = visible4
				end
			end

			if visible4 then
				local v40 = math.sin(now * 7) * 2 + 4

				for _, v41 in v10 do
					v41.f.Position = UDim2.new(0.5, v41.cx * (v40 + 23), 0.5, v41.cy * (v40 + 23))
				end
			end

			local v40 = data.on[data.mine] or 0
			local v41 = data.on[data.theirs] or 0
			local v42 = data.mine .. v40 .. "|" .. v41

			if v42 ~= v24 then
				v24 = v42
				label4.Text = tostring(v40)
				label4.TextColor3 = Style.teamText(data.mine)
				label5.Text = tostring(v41)
				label5.TextColor3 = Style.teamText(data.theirs)
				local v43 = not (v40 + v41 > 0) and 0.5 or v40 / (v40 + v41)
				fill2.Size = UDim2.fromScale(v43, 1)
				fill2.BackgroundColor3 = Style.teamColor(data.mine)
				fill3.Size = UDim2.fromScale(1 - v43, 1)
				fill3.BackgroundColor3 = Style.teamColor(data.theirs)
			end

			if data.event == "captured" then
				if visible3 then
					if data.eventAge < 2.2 then
						visible3 = data.holder == data.eventTeam
					else
						visible3 = false
					end
				end
			else
				visible3 = false
			end

			if visible3 ~= v25 then
				v25 = visible3
				fill4.Visible = visible3
				fill5.Visible = visible3
			end

			local text2 = ""
			local textColor2 = Style.WHITE

			if visible3 then
				text2 = "CAPTURED"
			elseif data.mode == "contested" then
				textColor2 = Style.HAZARD
				text2 = "CONTESTED"
			elseif data.mode == "neutralizing" then
				text2 = "NEUTRALIZING"
			elseif data.mode == "capturing" then
				text2 = "CAPTURING"
			elseif data.mode == "holding" then
				if data.holder == data.mine then
					text2 = "DEFENDING"
				else
					text2 = "ENEMY HOLDS"
				end
			end

			if text2 ~= v26 then
				v26 = text2
				label6.Text = text2
			end

			if textColor2 ~= v27 then
				v27 = textColor2
				label6.TextColor3 = textColor2
			end
		end
	end

	return { root = region, fx = layer, set = set }
end

local v2 = {}
local function marker(playerGui, k: number)
	local point = points[k]
	local attachment = Instance.new("Attachment")
	attachment.Name = "DominationMarker" .. point.id
	attachment.Position = point.marker
	attachment.Parent = workspace.Terrain
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "PointMarker" .. point.id
	billboardGui.Adornee = attachment
	billboardGui.AlwaysOnTop = true
	billboardGui.LightInfluence = 0
	billboardGui.ResetOnSpawn = false
	billboardGui.Size = UDim2.fromOffset(150, 96)
	billboardGui.Parent = playerGui
	table.insert(v2, billboardGui)
	local label = Style.label(billboardGui, "Order", "", 22, Style.FONT, 1.5)
	label.AutomaticSize = Enum.AutomaticSize.None
	label.Size = UDim2.new(1, 0, 0, 26)
	label.Position = UDim2.fromOffset(0, 0)
	local v3

	if v then
		v3 = point.letter
	end

	local v4 = pointIcon(billboardGui, 32, "Icon", v3)
	v4.holder.AnchorPoint = Vector2.new(0.5, 0)
	v4.holder.Position = UDim2.new(0.5, 0, 0, 28)
	local label2 = Style.label(billboardGui, "Distance", "", 17, Style.FONT, 1.5)
	label2.AutomaticSize = Enum.AutomaticSize.None
	label2.Size = UDim2.new(1, 0, 0, 20)
	label2.Position = UDim2.fromOffset(0, 64)
	local v5 = -1
	local v6 = 0
	local v7 = ""
	local v8 = ""
	local v9 = ""
	local v10 = 0
	local v11 = nil
	return function(data, vector3: Vector3)
		local enabled

		if data.at == k then
			enabled = false
		else
			local raid = data.raid or data.tdm
			enabled = not raid
		end

		if v11 ~= enabled then
			v11 = enabled
			billboardGui.Enabled = enabled
		end

		if not enabled then
			return
		end

		local pt = data.pts[k]
		v4.set(iconLook(pt.holder, data.mine, pt.control))
		local textColor, text

		if pt.mode == "contested" then
			textColor = Style.HAZARD
			text = "CONTESTED"
		elseif pt.holder == data.mine then
			textColor = Style.teamText(data.mine)
			text = "DEFEND"
		elseif pt.holder == "" then
			textColor = Style.WHITE
			text = "CAPTURE"
		else
			textColor = Style.teamText(pt.holder)
			text = "ATTACK"
		end

		if text ~= v7 or data.mine ~= v8 or pt.holder ~= v9 then
			local mine = data.mine
			local holder = pt.holder
			v7 = text
			v8 = mine
			v9 = holder
			label.Text = text
			label.TextColor3 = textColor
			label.TextTransparency = 0
			v10 = 0
		end

		local now = os.clock()

		if text == "CONTESTED" then
			local textTransparency = 0.18 - pulse(now) * 0.18 -- inferred equivalent call

			if textTransparency ~= v10 then
				v10 = textTransparency
				label.TextTransparency = textTransparency
			end
		end

		local v12 = math.floor((vector3 - point.marker).Magnitude + 0.5)

		if v12 ~= v5 and (v5 < 0 or now - v6 >= 0.25) then
			v5 = v12
			v6 = now
			label2.Text = tostring(v12)
		end
	end
end

local function spawnMarkers(playerGui)
	local v3 = {}
	local VOXEL_SIZE = WorldConfig.VOXEL_SIZE
	local origin = WorldConfig.ORIGIN

	local spawnZoneMarker = Instance.new("Attachment")
	spawnZoneMarker.Name = "SpawnZoneMarker"
	spawnZoneMarker.Parent = workspace.Terrain
	local spawnZoneMarker2 = Instance.new("BillboardGui")
	spawnZoneMarker2.Name = "SpawnZoneMarker"
	spawnZoneMarker2.Adornee = spawnZoneMarker
	spawnZoneMarker2.AlwaysOnTop = true
	spawnZoneMarker2.LightInfluence = 0
	spawnZoneMarker2.ResetOnSpawn = false
	spawnZoneMarker2.Size = UDim2.fromOffset(150, 96)
	spawnZoneMarker2.Enabled = false
	spawnZoneMarker2.Parent = playerGui

	local label = Style.label(spawnZoneMarker2, "Order", "DESTROY", 22, Style.FONT, 1.5)
	label.AutomaticSize = Enum.AutomaticSize.None
	label.Size = UDim2.new(1, 0, 0, 26)
	local v4 = pointIcon(spawnZoneMarker2, 32, "Icon")
	v4.holder.AnchorPoint = Vector2.new(0.5, 0)
	v4.holder.Position = UDim2.new(0.5, 0, 0, 28)
	local label2 = Style.label(spawnZoneMarker2, "Distance", "", 17, Style.FONT, 1.5)
	label2.AutomaticSize = Enum.AutomaticSize.None
	label2.Size = UDim2.new(1, 0, 0, 20)
	label2.Position = UDim2.fromOffset(0, 64)
	label2.AutoLocalize = false
	local v5 = false
	local v6 = -1
	local v7 = ""
	local v8 = 0
	local function make()
		local spawnMarker = Instance.new("Attachment")
		spawnMarker.Name = "SpawnMarker"
		spawnMarker.Parent = workspace.Terrain
		local spawnMarker2 = Instance.new("BillboardGui")
		spawnMarker2.Name = "SpawnMarker"
		spawnMarker2.Adornee = spawnMarker
		spawnMarker2.AlwaysOnTop = true
		spawnMarker2.LightInfluence = 0
		spawnMarker2.ResetOnSpawn = false
		spawnMarker2.Size = UDim2.fromOffset(40, 44)
		spawnMarker2.Enabled = false
		spawnMarker2.Parent = playerGui
		local icon = pointIcon(spawnMarker2, 20, "Icon")
		icon.holder.AnchorPoint = Vector2.new(0.5, 0)
		icon.holder.Position = UDim2.fromScale(0.5, 0)
		local label3 = Style.label(spawnMarker2, "Distance", "", 12, Style.FONT, 1.5)
		label3.AutomaticSize = Enum.AutomaticSize.None
		label3.Size = UDim2.new(1, 0, 0, 14)
		label3.Position = UDim2.fromOffset(0, 23)
		label3.AutoLocalize = false
		local label4 = Style.label(spawnMarker2, "Order", "", 12, Style.FONT, 1.5)
		label4.AutomaticSize = Enum.AutomaticSize.None
		label4.Size = UDim2.new(1, 0, 0, 14)
		label4.Visible = false
		return {
			bb = spawnMarker2,
			icon = icon,
			dist = label3,
			word = label4,
			att = spawnMarker,
			shown = false,
			look = "",
			lookTeam = "",
			lookMine = false,
			lastDist = -1,
			lastHp = -1,
			distAt = 0,
			pulse = -1
		}
	end

	local v9 = {}
	local v10 = {}
	local function topOf(i: number, beacon)
		if v10[i * 2 - 1] == beacon.min and v10[i * 2] == beacon.max then
			return v9[i]
		end

		local v11 = i * 2 - 1
		local v12 = i * 2
		local min = beacon.min
		local max = beacon.max
		v10[v11] = min
		v10[v12] = max
		v9[i] = origin + Vector3.new(
			(beacon.min.X + beacon.max.X + 1) * 0.5,
			beacon.max.Y + 1,
			(beacon.min.Z + beacon.max.Z + 1) * 0.5
		) * VOXEL_SIZE

		return v9[i]
	end

	local v11 = {}
	local v12 = {}
	local v13 = ""
	local v14 = ""
	local function digits(value: string, list) -- 2 equivalent calls inferred from this helper
		table.clear(list)

		for i = 1, #value do
			list[i] = tonumber((string.sub(value, i, i)))
		end
	end
	return function(data, vector3: Vector3, flag: boolean?)
		local beacons = MapBuilder.BEACONS

		if data.heat ~= v13 then
			v13 = data.heat
			digits(v13, v11) -- inferred equivalent call
		end

		if data.health ~= v14 then
			v14 = data.health
			digits(v14, v12) -- inferred equivalent call
		end

		local now = os.clock()
		local total = Vector3.new(0, 0, 0)
		local count = 0
		local v15 = false
		local v16 = ""

		for i = 1, math.max(#beacons, #v3) do
			local beacon = beacons[i]
			local v17 = data.raid

			if v17 then
				if beacon == nil or data.alive[i] ~= true or data.phase == "over" then
					v17 = false
				else
					v17 = not flag
				end
			end

			local v18

			if v17 and beacon and data.siege then
				local v19 = topOf(i, beacon)
				local v20 = beacon.team == data.mine
				v18 = v20 and (v11[i] or 0) > 0
				v17 = v18 or (vector3 - v19).Magnitude < (v20 and 60 or 180)

				if not v20 then
					total += v19
					count += 1
					v16 = beacon.team
					v15 = v15 or v17
				end
			else
				v18 = false
			end

			local v19 = v3[i]

			if v17 and not v19 then
				v19 = make()
				v3[i] = v19
			end

			if not v19 then
				continue
			end

			if v19.shown ~= v17 then
				v19.shown = v17
				v19.bb.Enabled = v17
			end

			if not (v17 and beacon) then
				continue
			end

			local position = topOf(i, beacon) + Vector3.new(0, 3, 0)

			if v19.att.Position ~= position then
				v19.att.Position = position
			end

			local lookMine = beacon.team == data.mine

			local v20 = data.siege and (lookMine and (v18 and "DEFEND" or "") or "DESTROY") or ""

			if v20 ~= v19.look or beacon.team ~= v19.lookTeam or lookMine ~= v19.lookMine then
				local team = beacon.team
				v19.look = v20
				v19.lookTeam = team
				v19.lookMine = lookMine
				v19.icon.set(
					lookMine and "ring" or "diamond",
					Style.teamColor(beacon.team),
					lookMine and 0.6 or 1,
					0,
					Style.teamColor(beacon.team)
				)
				v19.dist.Visible = not lookMine
				local v21 = v20 == "" and 0 or 16
				v19.word.Visible = v20 ~= ""
				v19.word.Text = v20
				local word = v19.word
				local textColor

				if lookMine then
					textColor = Style.HAZARD
				else
					textColor = Style.teamText(beacon.team)
				end

				word.TextColor3 = textColor
				local bb = v19.bb
				local size

				if lookMine then
					size = UDim2.fromOffset(v20 == "" and 28 or 90, v21 + 28)
				else
					size = UDim2.fromOffset(90, v21 + 44)
				end

				bb.Size = size
				local holder = v19.icon.holder
				local size2

				if lookMine then
					size2 = UDim2.fromOffset(14, 14)
				else
					size2 = UDim2.fromOffset(20, 20)
				end

				holder.Size = size2
				v19.icon.holder.Position = UDim2.new(0.5, 0, 0, v21)
				v19.dist.Position = UDim2.fromOffset(0, v21 + 23)
			end

			if v18 then
				local v21 = 0.25 - pulse(now) * 0.25 -- inferred equivalent call

				if v21 ~= v19.pulse then
					v19.pulse = v21
					v19.word.TextTransparency = v21
				end
			end

			if lookMine then
				continue
			end

			local lastHp = data.siege and (v12[i] or 9) or -1

			local lastDist = lastHp >= 0 and -1 or math.floor((vector3 - position).Magnitude + 0.5)

			if not (lastHp ~= v19.lastHp or lastDist ~= v19.lastDist and (v19.lastDist < 0 or now - v19.distAt >= 0.25)) then
				continue
			end

			v19.lastDist = lastDist
			v19.lastHp = lastHp
			v19.distAt = now

			local dist = v19.dist
			local text

			if lastHp >= 0 then
				text = string.format("%d%%", (math.round(lastHp / 9 * 100)))
			else
				text = tostring(lastDist)
			end

			dist.Text = text
		end

		local enabled = data.siege

		if enabled then
			if count > 0 then
				enabled = not v15

				if enabled then
					if data.phase == "over" or data.mine == "" then
						enabled = false
					else
						enabled = not flag
					end
				end
			else
				enabled = false
			end
		end

		if enabled ~= v5 then
			v5 = enabled
			spawnZoneMarker2.Enabled = enabled
		end

		if enabled then
			if v16 ~= v7 then
				v7 = v16
				label.TextColor3 = Style.teamText(v16)
				v4.set("diamond", Style.teamColor(v16), 1, 0, Style.teamColor(v16))
			end

			local position = total / count + Vector3.new(0, 46, 0)

			if spawnZoneMarker.Position ~= position then
				spawnZoneMarker.Position = position
			end

			local v17 = math.floor((vector3 - position).Magnitude + 0.5)

			if v17 ~= v6 and (v6 < 0 or now - v8 >= 0.25) then
				v6 = v17
				v8 = now
				label2.Text = tostring(v17)
			end
		end
	end
end

local function num(value) -- 9 equivalent calls inferred from this helper
	return if type(value) == "number" then value else 0
end

local function str(value) -- 9 equivalent calls inferred from this helper
	return if type(value) == "string" then value else ""
end

function PointHud.mount(data)
	local domination = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Domination", 30)
	assert(
		domination and domination:IsA("Configuration"),
		"PointHud: ReplicatedStorage.Game.Domination is missing (the server's Game.Domination did not start)"
	)
	local player = data.player
	local v3 = nil
	local v4 = {}
	local v5 = spawnMarkers(data.playerGui)

	local v6 = nil
	local humanoid = nil
	local humanoidRootPart = nil

	local function feetPoint()
		local character = player.Character

		if
			character ~= v6
			or humanoid and humanoid.Parent ~= character
			or humanoidRootPart and humanoidRootPart.Parent ~= character
			or not (humanoid and humanoidRootPart)
		then
			v6 = character
			humanoid = character and character:FindFirstChildOfClass("Humanoid")
			humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		end

		local v7 = humanoid
		local part = humanoidRootPart

		if v7 and v7.Health > 0 and part and part:IsA("BasePart") then
			return Hardpoint.pointAt(part.Position - Vector3.new(0, v7.HipHeight + part.Size.Y * 0.5, 0))
		end

		return nil
	end

	local v7 = {}
	local pts = {}
	local v8 = {}
	local v9 = nil

	local function build()
		v3 = PointHud.new(data.layers.hud, data.playerGui)
		v4 = {}

		for k in points do
			v4[k] = marker(data.playerGui, k)
		end

		v7 = {}
		pts = {}
		v8 = {}

		for k, point in points do
			v7[k] = {
				holder = Hardpoint.attr("Holder", k),
				control = Hardpoint.attr("Control", k),
				mode = Hardpoint.attr("Mode", k),
				reds = Hardpoint.attr("RedsOn", k),
				blues = Hardpoint.attr("BluesOn", k)
			}

			pts[k] = {
				holder = "",
				control = 0,
				mode = "idle",
				on = { Reds = 0, Blues = 0 }
			}
			v8[point.id] = k
		end

		v9 = {
			mine = "Reds",
			theirs = "Blues",
			points = { Reds = 0, Blues = 0 },
			target = Hardpoint.TARGET,
			pts = pts,
			at = nil,
			eventPoint = not v and 1 or nil,
			holder = "",
			control = 0,
			mode = "idle",
			on = { Reds = 0, Blues = 0 },
			inZone = false,
			phase = "live",
			winner = "",
			nextIn = 0,
			endsIn = 0,
			overtime = false,
			event = "",
			eventTeam = "",
			eventAge = 1e999,
			eventAt = 0,
			raid = false,
			siege = false,
			health = "",
			heat = "",
			tdm = false,
			bt = false,
			roundTime = Hardpoint.ROUND_TIME,
			alive = {}
		}
	end
	build()

	local function remount()
		v = #points > 1
		v3.root:Destroy()
		v3.fx:Destroy()

		for _, child in workspace.Terrain:GetChildren() do
			if string.sub(child.Name, 1, 16) == "DominationMarker" then
				child:Destroy()
			end
		end

		for _, v10 in v2 do
			v10:Destroy()
		end

		table.clear(v2)
		build()
	end
	MapSelect.onChange(remount, 20)
	Hardpoint.onPointsChange(remount)

	local attributes = domination:GetAttributes()
	domination.AttributeChanged:Connect(function(attributeName: string)
		attributes[attributeName] = domination:GetAttribute(attributeName)
	end)
	local v10 = false
	local Game = ReplicatedStorage:WaitForChild("Game")

	local v11 = false
	local function readVote() -- 2 equivalent calls inferred from this helper
		local vote = Game:FindFirstChild("Vote")
		local stage = vote and vote:GetAttribute("Stage")
		v11 = type(stage) == "string" and stage ~= ""
	end
	local function watchVote(child) -- 1 equivalent call inferred from this helper
		if child.Name == "Vote" then
			child:GetAttributeChangedSignal("Stage"):Connect(readVote)
			readVote() -- inferred equivalent call
		end
	end

	for _, child in Game:GetChildren() do
		watchVote(child) -- inferred equivalent call
	end

	Game.ChildAdded:Connect(watchVote)
	Game.ChildRemoved:Connect(function(child)
		if child.Name == "Vote" then
			readVote() -- inferred equivalent call
		end
	end)
	RunService.RenderStepped:Connect(function()
		if data.layers.hud.Parent ~= data.playerGui then
			return
		end

		if v3.root.Visible == v11 then
			v3.root.Visible = not v11
		end

		local v12

		if player.Team and not player.Neutral then
			v12 = player.Team.Name
		end

		v9.mine = v12 == "Blues" and "Blues" or "Reds"
		v9.theirs = Hardpoint.other(v9.mine)
		local points2 = v9.points
		local points3 = v9.points
		local reds2 = num(attributes.Reds) -- inferred equivalent call
		local blues2 = num(attributes.Blues) -- inferred equivalent call
		points2.Reds = reds2
		points3.Blues = blues2
		v9.target = num(attributes.Target) -- inferred equivalent call

		for k, v13 in v7 do
			local v14 = pts[k]
			v14.holder = str(attributes[v13.holder]) -- inferred equivalent call
			v14.control = num(attributes[v13.control]) -- inferred equivalent call
			v14.mode = str(attributes[v13.mode]) -- inferred equivalent call
			local on = v14.on
			local on2 = v14.on
			local reds = num(attributes[v13.reds]) -- inferred equivalent call
			local blues = num(attributes[v13.blues]) -- inferred equivalent call
			on.Reds = reds
			on2.Blues = blues
		end

		v9.phase = str(attributes.Phase) -- inferred equivalent call
		v9.winner = str(attributes.Winner) -- inferred equivalent call
		local serverTimeNow = workspace:GetServerTimeNow()
		v9.nextIn = num(attributes.NextAt) - serverTimeNow -- inferred equivalent call
		v9.endsIn = num(attributes.EndsAt) - serverTimeNow -- inferred equivalent call
		v9.overtime = attributes.Overtime == true
		v9.event = str(attributes.Event) -- inferred equivalent call
		v9.eventTeam = str(attributes.EventTeam) -- inferred equivalent call
		v9.eventAt = num(attributes.EventAt) -- inferred equivalent call
		v9.eventAge = not (v9.eventAt > 0) and 1e999 or serverTimeNow - v9.eventAt

		if v then
			v9.eventPoint = v8[str(attributes.EventPoint)] -- inferred equivalent call
		end

		v9.raid = SpawnRaid.isRaid(attributes.GameMode)
		v9.siege = attributes.GameMode == SpawnRaid.SIEGE_ID
		v9.health = str(attributes.SpawnHealth) -- inferred equivalent call
		v9.heat = str(attributes.SpawnHeat) -- inferred equivalent call
		v9.tdm = attributes.GameMode == TeamDeathmatch.ID
		v9.bt = attributes.GameMode == "breakthrough"
		local v13 = v9
		local roundTime

		if type(attributes.RoundTime) == "number" then
			roundTime = attributes.RoundTime
		else
			roundTime = Hardpoint.ROUND_TIME
		end

		v13.roundTime = roundTime

		if v9.raid then
			local spawnsAlive = attributes.SpawnsAlive
			local v14 = tostring(spawnsAlive) .. "#" .. #MapBuilder.BEACONS

			if v14 ~= v10 then
				v10 = v14
				v9.alive = SpawnRaid.parseAlive(spawnsAlive, #MapBuilder.BEACONS)
			end
		end

		local v14 = v9
		local at

		if not v9.tdm then
			at = feetPoint()
		end

		v14.at = at
		v9.inZone = v9.at ~= nil
		local v15 = pts[v9.at or Hardpoint.MAIN]
		local v16 = v9
		local v17 = v9
		local v18 = v9
		local holder = v15.holder
		local control = v15.control
		local mode = v15.mode
		v16.holder = holder
		v17.control = control
		v18.mode = mode
		local on = v9.on
		local on2 = v9.on
		local reds = v15.on.Reds
		local blues = v15.on.Blues
		on.Reds = reds
		on2.Blues = blues
		debug.profilebegin("PH.bar")
		v3.set(v9)
		debug.profileend()
		local currentCamera = workspace.CurrentCamera
		local v19

		if currentCamera then
			v19 = currentCamera.CFrame.Position
		else
			v19 = Hardpoint.MARKER
		end

		debug.profilebegin("PH.marks")

		for _, v20 in v4 do
			v20(v9, v19)
		end

		local cinematic = data.playerGui:GetAttribute("Cinematic") == true
		v5(v9, v19, cinematic)
		debug.profileend()
	end)
end

return PointHud