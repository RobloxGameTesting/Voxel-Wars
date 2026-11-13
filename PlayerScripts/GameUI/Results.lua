local Style = require(script.Parent:WaitForChild("Style"))
local Scoreboard = require(script.Parent:WaitForChild("Scoreboard"))

local Results = {
	["new"] = nil,
	new = function(p)
		local region = Style.region(p, "Results", Vector2.new(0.5, 0.5), Vector2.zero, Vector2.new(0, 0))
		region.ZIndex = 5
		region.Visible = false
		local fill = Style.fill(p, "ResultsShade", Color3.new(0, 0, 0), UDim2.fromScale(1, 1))
		fill.BackgroundTransparency = 0.45
		fill.ZIndex = 4
		fill.Visible = false

		local v = Scoreboard.new(region)
		local x = v.size.X

		local v2 = 114 + v.size.Y + 70
		region.Size = UDim2.fromOffset(x, v2)
		local fit = Style.fit(region, Vector2.new(x, v2))

		local tape = Style.tape(region, "Tape", UDim2.new(1, 0, 0, 14), x, 22)
		tape.Position = UDim2.fromOffset(0, 28)
		local box = Style.box(region, "Banner", Style.PANEL, UDim2.fromOffset(0, 56), 3, 3)
		box.AutomaticSize = Enum.AutomaticSize.X
		box.AnchorPoint = Vector2.new(0.5, 0)
		box.Position = UDim2.fromScale(0.5, 0)
		box.BackgroundTransparency = 0
		local uiPadding = Instance.new("UIPadding")
		uiPadding.PaddingLeft = UDim.new(0, 22)
		uiPadding.PaddingRight = UDim.new(0, 22)
		uiPadding.Parent = box
		local label = Style.label(box, "Title", "", 38, Style.FONT, 2)
		label.Size = UDim2.fromOffset(0, 56)
		local label2 = Style.label(region, "Verdict", "", 15, Style.FONT, 1.5)
		label2.AnchorPoint = Vector2.new(0.5, 0)
		label2.Position = UDim2.new(0.5, 0, 0, 58)
		label2.Visible = false

		local box2 = Style.box(region, "MVP", Style.PANEL, UDim2.new(1, 0, 0, 36), 3, 2)
		box2.Position = UDim2.fromOffset(0, 76)
		box2.BackgroundTransparency = 0.05
		local box3 = Style.box(box2, "Tag", Style.HAZARD, UDim2.fromOffset(52, 24), 2, 1.5)
		box3.Position = UDim2.fromOffset(8, 6)
		local label3 = Style.label(box3, "Text", "MVP", 15, Style.FONT, 0)
		label3.AutomaticSize = Enum.AutomaticSize.None
		label3.Size = UDim2.fromScale(1, 1)
		label3.TextColor3 = Style.INK
		local label4 = Style.label(box2, "Text", "", 17, Style.FONT, 1.5)
		label4.RichText = true
		label4.Position = UDim2.fromOffset(70, 6)
		label4.Size = UDim2.fromOffset(0, 24)

		v.root.Position = UDim2.fromOffset(0, 118)

		local frame = Style.frame(region, "Footer", UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 1, -40))
		local box4 = Style.box(frame, "Scrap", Style.PANEL, UDim2.fromOffset(0, 36), 3, 2)
		box4.AutomaticSize = Enum.AutomaticSize.X
		local uiListLayout = Instance.new("UIListLayout")
		uiListLayout.FillDirection = Enum.FillDirection.Horizontal
		uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		uiListLayout.Padding = UDim.new(0, 8)
		uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uiListLayout.Parent = box4
		local uiPadding2 = Instance.new("UIPadding")
		uiPadding2.PaddingLeft = UDim.new(0, 10)
		uiPadding2.PaddingRight = UDim.new(0, 12)
		uiPadding2.Parent = box4
		local nut = Style.nut(box4, 22)
		nut.LayoutOrder = 1
		local label5 = Style.label(box4, "Amount", "+0", 22, Style.FONT, 1.5)
		label5.TextColor3 = Style.HAZARD
		label5.LayoutOrder = 2
		local label6 = Style.label(box4, "Caption", "SCRAP EARNED", 13, Style.FONT, 0)
		label6.TextColor3 = Style.MUTED
		label6.LayoutOrder = 3
		local label7 = Style.label(frame, "Next", "", 16, Style.FONT, 1.5)
		label7.RichText = true
		label7.AnchorPoint = Vector2.new(1, 0.5)
		label7.Position = UDim2.new(1, 0, 0.5, 0)

		local v3 = {}
		v3.root = region

		function v3.show(value: string, p2: string?)
			if value == "" then
				label.Text = "ROUND DRAWN"
				label.TextColor3 = Style.WHITE
			else
				label.Text = string.upper(value) .. " TAKE THE ROUND"
				label.TextColor3 = Style.teamText(value)
			end

			label2.Visible = p2 ~= nil and value ~= ""

			if p2 == value then
				label2.Text = "YOUR CREW WON"
				label2.TextColor3 = Style.HAZARD
			else
				label2.Text = "YOUR CREW LOST"
				label2.TextColor3 = Style.MUTED
			end

			if not region.Visible then
				region.Visible = true
				fill.Visible = true
				local now = os.clock()
				Style.animate(v3, function(_, p3): boolean
					local v4 = (p3 - now) / 0.18
					fit(0.9 + 0.1 * Style.pop(v4))
					return v4 < 1
				end)
			end
		end

		function v3.setBoard(list, p2)
			v.set(list, p2)
			local item = list[1]

			if item and item.score > 0 then
				label4.Text = Style.paint(item.name, Style.teamText(item.team)) .. Style.paint(
					"   " .. Style.thousands(item.score) .. " SCORE  ·  " .. item.takedowns .. " KILLS  ·  " .. item.breaches .. " BREACHES",
					Style.MUTED
				)
			else
				label4.Text = Style.paint("NO STANDOUT THIS ROUND", Style.MUTED)
			end
		end

		function v3.setScrap(p2: number)
			label5.Text = "+" .. Style.thousands((math.max(p2, 0)))
		end

		function v3.setNext(p2: number)
			label7.Text = "NEXT ROUND IN " .. Style.paint(Style.clock(p2), Style.HAZARD)
		end

		function v3.hide()
			region.Visible = false
			fill.Visible = false
		end

		return v3
	end
}

function Results.mount(data)
	local net = data.Net
	local player = data.player
	local v = Results.new(data.layers.screens)
	local count = 0
	local v2 = net.get("Phase")

	local function draw() -- 1 equivalent call inferred from this helper
		v.setBoard(Scoreboard.collect(net, player))
		v.setScrap(net.attr(player, "ScrapEarned", 0))
	end
	local v3 = Scoreboard.watch(data, function()
		return v.root.Visible
	end, draw)

	player:GetAttributeChangedSignal("ScrapEarned"):Connect(v3)

	local function update()
		local phase = net.get("Phase")
		local _ = phase == v2
		v2 = phase
		count += 1

		if phase ~= "Ended" then
			v.hide()
			return
		end

		local v4 = count
		v.show(net.get("Winner"), net.teamOf(player))
		draw() -- inferred equivalent call
		task.spawn(function()
			while count == v4 do
				local v5 = net.get("EndsAt") - net.now()
				v.setNext((math.max(v5, 0)))
				task.wait(not (v5 > 0) and 0.5 or v5 % 1 + 0.02)
			end
		end)
	end
	net.changed("Phase", update)
	net.changed("Winner", update)
	update()
end

return Results