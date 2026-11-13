local Style = require(script.Parent:WaitForChild("Style"))

local Objective = {}

local function buildRow(region, team: string, p: number)
	local panel = Style.panel(region, team, UDim2.fromOffset(300, 30))
	local fill = Style.fill(panel, "Edge", Style.teamColor(team), UDim2.new(0, 4, 1, 0))
	Style.corner(fill, 2)
	local emblem = Style.emblem(panel, team, 20)
	emblem.Position = UDim2.fromOffset(10, 5)
	local label = Style.label(panel, "Name", string.upper(team), 15, Style.FONT, 1.5)
	label.TextColor3 = Style.teamText(team)
	label.Position = UDim2.fromOffset(36, 4)
	label.Size = UDim2.fromOffset(0, 22)
	local frame = Style.frame(panel, "Pips", UDim2.fromOffset(p * 8, 13), UDim2.new(0, 92, 0.5, 0), Vector2.new(0, 0.5))
	local fills = {}

	for i = 1, p do
		local fill2 = Style.fill(
			frame,
			"Pip" .. i,
			Style.teamColor(team),
			UDim2.fromOffset(6, 13),
			UDim2.fromOffset((i - 1) * 8, 0)
		)
		Style.corner(fill2, 1)
		fills[i] = fill2
	end

	local label2 = Style.label(panel, "Count", "0", 20, Style.FONT, 1.5)
	label2.AnchorPoint = Vector2.new(1, 0.5)
	label2.Position = UDim2.new(1, -8, 0.5, 0)
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = panel
	return {
		team = team,
		frame = panel,
		scale = uiScale,
		pips = fills,
		count = label2,
		shown = {}
	}
end

function Objective.new(p, p2)
	local region = Style.region(
		p,
		"Objective",
		Vector2.zero,
		Vector2.new(14, Style.topInset() + 10),
		Vector2.new(340, 120)
	)

	local box = Style.box(region, "Clock", Style.HAZARD, UDim2.fromOffset(0, 26), 2, 2)
	box.AutomaticSize = Enum.AutomaticSize.X
	box.Rotation = -2
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, 8)
	uiPadding.PaddingRight = UDim.new(0, 8)
	uiPadding.Parent = box
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.Padding = UDim.new(0, 8)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = box
	local label = Style.label(box, "Round", "ROUND 1", 12, Style.FONT, 0)
	label.TextColor3 = Style.INK
	label.TextTransparency = 0.3
	label.LayoutOrder = 1
	local label2 = Style.label(box, "Time", "15:00", 19, Style.FONT, 0)
	label2.TextColor3 = Style.INK
	label2.LayoutOrder = 2

	local v = {
		Reds = buildRow(region, "Reds", p2.Reds or 20),
		Blues = buildRow(region, "Blues", p2.Blues or 20)
	}

	local function place(p3: string)
		local total = 34

		for _, v2 in { p3, p3 == "Reds" and "Blues" or "Reds" } do
			local v3 = v[v2]
			local v4 = v3.scale.Scale > 1
			v3.frame.Position = UDim2.fromOffset(0, total)
			total += (v4 and 1.12 or 1) * 30 + 4
		end
	end

	local v2 = {
		["root"] = region,
		setBeacons = function(p3: string, p4)
			local v2 = v[p3]
			assert(v2, "GameUI: no objective row for team " .. tostring(p3))

			local teamColor = Style.teamColor(p3)
			local count = 0
			local pips = {}

			for k, pip in v2.pips do
				local v3 = p4[k] == true

				if v3 then
					count += 1
				end

				if v2.shown[k] == v3 then
					continue
				end

				if v2.shown[k] == true and not v3 then
					table.insert(pips, pip)
				end

				v2.shown[k] = v3
				local backgroundColor

				if v3 then
					backgroundColor = teamColor
				else
					backgroundColor = Color3.fromRGB(46, 47, 52)
				end

				pip.BackgroundColor3 = backgroundColor
			end

			v2.count.Text = tostring(count)

			if #pips > 0 then
				local now = os.clock()
				Style.animate(pips, function(_, p5): boolean
					local v3 = (p5 - now) / 0.6
					local lerped = Style.WHITE:Lerp(Color3.fromRGB(46, 47, 52), Style.easeIn(v3))

					for _, v4 in pips do
						v4.BackgroundColor3 = lerped
					end

					return v3 < 1
				end)
			end
		end,
		setClock = function(p3: number?, p4: string, p5: number)
			label.Text = not (p5 > 0) and "STANDBY" or "ROUND " .. p5

			if p4 == "Ended" then
				label2.Text = "ROUND OVER"
			else
				label2.Text = not p3 and "--:--" or Style.clock(p3)
			end

			local textColor

			if p4 == "Playing" and p3 and p3 <= 60 then
				textColor = Color3.fromRGB(150, 20, 10)
			else
				textColor = Style.INK
			end

			label2.TextColor3 = textColor
		end,
		setMine = function(value: string?)
			for k, v2 in v do
				v2.scale.Scale = k == value and 1.12 or 1
			end

			place(value or "Reds")
		end
	}

	v2.setMine(nil)
	return v2
end

function Objective.mount(data)
	local net = data.Net

	local v = { Reds = {}, Blues = {} }

	for k, v2 in net.BEACONS do
		assert(v[v2.team], "GameUI: beacon " .. k .. " has unknown team " .. tostring(v2.team))
		table.insert(v[v2.team], k)
	end

	local v2 = Objective.new(data.layers.hud, {
		Reds = #v.Reds,
		Blues = #v.Blues
	})

	local function beacons()
		local beaconsAlive = net.beaconsAlive()

		for k, v3 in v do
			local v4 = {}

			for k2, v5 in v3 do
				v4[k2] = beaconsAlive[v5]
			end

			v2.setBeacons(k, v4)
		end
	end

	for _, v3 in { "BeaconsAlive", "RedsBeacons", "BluesBeacons" } do
		net.changed(v3, beacons)
	end

	beacons()
	data.onTeam(v2.setMine)

	task.spawn(function()
		while true do
			local endsAt = net.get("EndsAt")
			local v3 = endsAt - net.now()
			local setClock = v2.setClock
			local v4

			if endsAt > 0 then
				v4 = math.max(v3, 0)
			end

			setClock(v4, net.get("Phase"), net.get("Round"))
			task.wait(not (v3 > 0) and 0.5 or v3 % 1 + 0.02)
		end
	end)
	net.changed("Phase", function()
		local endsAt = net.get("EndsAt")
		local setClock = v2.setClock
		local v3

		if endsAt > 0 then
			v3 = math.max(endsAt - net.now(), 0)
		end

		setClock(v3, net.get("Phase"), net.get("Round"))
	end)
end

return Objective