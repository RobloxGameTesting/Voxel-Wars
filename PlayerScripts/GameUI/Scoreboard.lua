local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Style = require(script.Parent:WaitForChild("Style"))

local v = {
	{ key = "rank", caption = "#", w = 24 },
	{ key = "name", caption = "NAME", w = 136 },
	{ key = "takedowns", caption = "TKD", w = 38 },
	{ key = "supports", caption = "SUP", w = 38 },
	{ key = "breaches", caption = "BRH", w = 42 },
	{ key = "beacons", caption = "BCN", w = 38 },
	{ key = "score", caption = "SCORE", w = 60 }
}
local total = 0
local Scoreboard = {}

for _, v2 in v do
	total += v2.w
end

local v2 = total + 16

function Scoreboard.collect(data, p)
	local v3 = {
		Reds = { beacons = data.get("RedsBeacons"), score = 0 },
		Blues = { beacons = data.get("BluesBeacons"), score = 0 }
	}
	local result = {}

	for _, v4 in Players:GetPlayers() do
		local team = data.teamOf(v4)

		if not (team and v3[team]) then
			continue
		end

		local v5 = {
			name = v4.DisplayName,
			team = team,
			takedowns = data.attr(v4, "Takedowns", 0),
			supports = data.attr(v4, "Supports", 0),
			breaches = data.attr(v4, "Breaches", 0),
			beacons = data.attr(v4, "BeaconsDown", 0),
			score = data.attr(v4, "Score", 0),
			me = v4 == p
		}

		v3[team].score += v5.score
		table.insert(result, v5)
	end

	table.sort(result, function(a, b): boolean
		if a.score ~= b.score then
			return a.score > b.score
		end

		if a.takedowns == b.takedowns then
			return a.name < b.name
		end

		return a.takedowns > b.takedowns
	end)

	return result, v3
end

local function buildSide(frame, value: string, p: number)
	local teamColor = Style.teamColor(value)
	local frame2 = Style.frame(frame, value, UDim2.fromOffset(v2, 348), UDim2.fromOffset(p, 0))
	local box = Style.box(frame2, "Header", Style.PANEL, UDim2.new(1, 0, 0, 36), 3, 2)
	box.BackgroundTransparency = 0.05
	Style.fill(box, "Band", teamColor, UDim2.new(0, 6, 1, 0))

	local emblem = Style.emblem(box, value, 24)
	emblem.Position = UDim2.fromOffset(14, 6)
	local label = Style.label(box, "Team", string.upper(value), 20, Style.FONT, 1.5)
	label.TextColor3 = Style.teamText(value)
	label.Position = UDim2.fromOffset(44, 5)
	local label2 = Style.label(box, "Beacons", "", 13, Style.FONT, 0)
	label2.TextColor3 = Style.MUTED
	label2.AnchorPoint = Vector2.new(1, 0.5)
	label2.Position = UDim2.new(1, -78, 0.5, 0)
	local label3 = Style.label(box, "Score", "0", 20, Style.FONT, 1.5)
	label3.AnchorPoint = Vector2.new(1, 0.5)
	label3.Position = UDim2.new(1, -10, 0.5, 0)

	local frame3 = Style.frame(frame2, "Captions", UDim2.new(1, 0, 0, 20), UDim2.fromOffset(0, 38))
	local total2 = 8

	for _, v3 in v do
		local label4 = Style.label(frame3, v3.caption, v3.caption, 11, Style.FONT, 0)
		label4.AutomaticSize = Enum.AutomaticSize.None
		label4.Size = UDim2.fromOffset(v3.w, 20)
		label4.Position = UDim2.fromOffset(total2, 0)
		label4.TextColor3 = Style.DIM
		local textXAlignment

		if v3.key == "name" then
			textXAlignment = Enum.TextXAlignment.Left
		else
			textXAlignment = Enum.TextXAlignment.Center
		end

		label4.TextXAlignment = textXAlignment
		total2 += v3.w
	end

	local rows = {}

	for i = 1, 12 do
		local fill = Style.fill(
			frame2,
			"Row" .. i,
			Style.PANEL,
			UDim2.new(1, 0, 0, 22),
			UDim2.fromOffset(0, (i - 1) * 24 + 60)
		)
		fill.BackgroundTransparency = i % 2 == 0 and 0.25 or 0.12
		fill.Visible = false
		local fill2 = Style.fill(fill, "Edge", Style.HAZARD, UDim2.new(0, 4, 1, 0))
		fill2.Visible = false
		local total3 = 8
		local cells = {}

		for _, v3 in v do
			local label4 = Style.label
			local key = v3.key
			local v4 = v3.key == "score" and 15 or 14
			local v5

			if v3.key == "name" then
				v5 = Style.FONT_BODY
			else
				v5 = Style.FONT
			end

			local v6 = label4(fill, key, "", v4, v5, 0)
			v6.AutomaticSize = Enum.AutomaticSize.None
			v6.Size = UDim2.fromOffset(v3.w, 22)
			v6.Position = UDim2.fromOffset(total3, 0)
			local textXAlignment

			if v3.key == "name" then
				textXAlignment = Enum.TextXAlignment.Left
			else
				textXAlignment = Enum.TextXAlignment.Center
			end

			v6.TextXAlignment = textXAlignment
			v6.TextTruncate = Enum.TextTruncate.AtEnd
			local textColor

			if v3.key == "rank" then
				textColor = Style.DIM
			elseif v3.key == "score" then
				textColor = Style.HAZARD
			else
				textColor = Style.WHITE
			end

			v6.TextColor3 = textColor
			cells[v3.key] = v6
			total3 += v3.w
		end

		rows[i] = { frame = fill, edge = fill2, cells = cells }
	end

	return {
		header = box,
		beacons = label2,
		score = label3,
		rows = rows,
		crest = label
	}
end

function Scoreboard.new(p)
	local vector2 = Vector2.new(v2 * 2 + 20, 348)
	local frame = Style.frame(p, "Scoreboard", UDim2.fromOffset(vector2.X, vector2.Y))
	local v3 = {
		Reds = buildSide(frame, "Reds", 0),
		Blues = buildSide(frame, "Blues", v2 + 20)
	}

	return {
		["root"] = frame,
		size = vector2,
		set = function(items, p2)
			local v4 = { Reds = 0, Blues = 0 }

			for _, item in items do
				local v5 = v3[item.team]
				local v6 = v4[item.team] + 1
				v4[item.team] = v6
				local row = v5.rows[v6]

				if not row then
					continue
				end

				row.frame.Visible = true
				row.edge.Visible = item.me
				local cells = row.cells
				cells.rank.Text = tostring(v6)
				cells.name.Text = item.name
				local name = cells.name
				local textColor

				if item.me then
					textColor = Style.HAZARD
				else
					textColor = Style.WHITE
				end

				name.TextColor3 = textColor
				cells.takedowns.Text = tostring(item.takedowns)
				cells.supports.Text = tostring(item.supports)
				cells.breaches.Text = tostring(item.breaches)
				cells.beacons.Text = tostring(item.beacons)
				cells.score.Text = Style.thousands(item.score)
			end

			for k, v5 in v3 do
				for i = v4[k] + 1, 12 do
					v5.rows[i].frame.Visible = false
				end

				local v6 = p2[k]
				v5.beacons.Text = not v6 and "" or v6.beacons .. " BEACONS"
				v5.score.Text = not v6 and "0" or Style.thousands(v6.score)
			end
		end
	}
end

function Scoreboard.watch(p, callback, callback2)
	local net = p.Net
	local v3 = false
	local function queue() -- 2 equivalent calls inferred from this helper
		if not v3 and callback() then
			v3 = true
			task.defer(function()
				v3 = false
				callback2()
			end)
		end
	end
	local v4 = {
		Score = true,
		Takedowns = true,
		Supports = true,
		Breaches = true,
		BeaconsDown = true
	}
	p.eachPlayer(function(instance)
		instance.AttributeChanged:Connect(function(p2)
			if v4[p2] then
				queue() -- inferred equivalent call
			end
		end)
		instance:GetPropertyChangedSignal("Team"):Connect(queue)
		instance:GetPropertyChangedSignal("DisplayName"):Connect(queue)
		queue() -- inferred equivalent call
	end)
	Players.PlayerRemoving:Connect(queue)
	net.changed("RedsBeacons", queue)
	net.changed("BluesBeacons", queue)
	return queue
end

function Scoreboard.mount(data)
	local net = data.Net
	local player = data.player
	local region = Style.region(data.layers.screens, "TabBoard", Vector2.new(0.5, 0.5), Vector2.zero, Vector2.new(0, 0))
	local v3 = Scoreboard.new(region)
	region.Size = UDim2.fromOffset(v3.size.X, v3.size.Y + 40)
	Style.fit(region, v3.size + Vector2.new(0, 40))
	local label = Style.label(region, "Title", "", 16, Style.FONT, 1.5)
	label.AnchorPoint = Vector2.new(0.5, 0)
	label.Position = UDim2.fromScale(0.5, 0)
	label.TextColor3 = Style.HAZARD
	v3.root.Position = UDim2.fromOffset(0, 32)
	region.Visible = false

	local v4 = false
	local v5 = false
	local function isOpen()
		return region.Visible
	end

	local function draw() -- 1 equivalent call inferred from this helper
		label.Text = "ROUND " .. math.max(net.get("Round"), 1) .. "  ·  SCOREBOARD"
		v3.set(Scoreboard.collect(net, player))
	end
	local v6 = Scoreboard.watch(data, isOpen, draw)
	local function apply() -- 4 equivalent calls inferred from this helper
		local visible = v4 or v5

		if visible then
			if net.get("Phase") == "Ended" then
				visible = false
			else
				visible = net.teamOf(player) ~= nil
			end
		end

		if visible ~= region.Visible then
			region.Visible = visible

			if visible then
				draw() -- inferred equivalent call
			end
		end
	end

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if input.KeyCode == Enum.KeyCode.Tab and not gameProcessed then
			v4 = true
			apply() -- inferred equivalent call
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.Tab then
			v4 = false
			apply() -- inferred equivalent call
		end
	end)

	if Style.isTouch() then
		local region2 = Style.region(
			data.layers.hud,
			"ScoresButton",
			Vector2.zero,
			Vector2.new(14, 0),
			Vector2.new(96, 32)
		)
		Style.onScale(function(p)
			region2.Position = UDim2.new(0, 14, 0, Style.topInset() + 10 + 116 * p)
		end)
		Style.button(region2, "Scores", "SCORES", Style.STEEL, UDim2.fromScale(1, 1), Style.WHITE, 15).Activated:Connect(function()
			v5 = not v5
			apply() -- inferred equivalent call
		end)
	end

	net.changed("Phase", apply)
	data.onTeam(function()
		apply() -- inferred equivalent call
		v6()
	end)
end

return Scoreboard