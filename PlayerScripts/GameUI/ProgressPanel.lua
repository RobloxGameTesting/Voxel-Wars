local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Style = require(script.Parent.Style)
local Progression = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("Progression"))

local ProgressPanel = {}

local function segments(before: number, after: number)
	local level, from, need = Progression.levelOf(before)
	local v = after - before
	local result = {}

	while v > 0 and need > 0 do
		local v2 = need - from
		local v3 = math.min(v2, v)
		table.insert(result, {
			level = level,
			need = need,
			from = from,
			to = from + v3,
			up = v2 <= v3
		})
		v -= v3

		if v2 <= v3 then
			level += 1

			need = Progression.need(level)
			from = 0
		else
			from += v3
		end
	end

	return result
end

local function line(p, p2: string, layoutOrder: number, p3: number) -- 6 equivalent calls inferred from this helper
	local frame = Style.frame(p, p2, UDim2.new(1, 0, 0, p3))
	frame.LayoutOrder = layoutOrder
	return frame
end

function ProgressPanel.new(p, callback)
	local region = Style.region(p, "ProgressPanel", Vector2.new(0.5, 0), Vector2.zero, Vector2.new(320, 200))
	Style.onScale(function(p2)
		region.Position = UDim2.new(0.5, 0, 0, Style.topInset() + 132 * p2)
	end)
	region.Visible = false
	local fade = Instance.new("CanvasGroup")
	fade.Name = "Fade"
	fade.BackgroundTransparency = 1
	fade.BorderSizePixel = 0
	fade.Size = UDim2.fromScale(1, 0)
	fade.AutomaticSize = Enum.AutomaticSize.Y
	fade.Parent = region

	local panel = Style.panel(fade, "Plate", UDim2.new(1, 0, 0, 0))
	panel.AutomaticSize = Enum.AutomaticSize.Y
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, 12)
	uiPadding.PaddingRight = UDim.new(0, 12)
	uiPadding.PaddingTop = UDim.new(0, 8)
	uiPadding.PaddingBottom = UDim.new(0, 10)
	uiPadding.Parent = panel
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0, 2)
	uiListLayout.Parent = panel

	local tape = Style.tape(fade, "Tape", UDim2.new(1, 0, 0, 3), 320, 10)
	tape.ZIndex = 2
	local frame3 = line(panel, "Head", 1, 26) -- inferred equivalent call
	local label = Style.label(frame3, "Title", "ROUND XP", 16, Style.FONT, 1.5)
	label.TextColor3 = Style.MUTED
	label.AnchorPoint = Vector2.new(0, 0.5)
	label.Position = UDim2.fromScale(0, 0.5)
	local label2 = Style.label(frame3, "Total", "", 22, Style.FONT, 1.5)
	label2.TextColor3 = Style.HAZARD
	label2.AnchorPoint = Vector2.new(1, 0.5)
	label2.Position = UDim2.fromScale(1, 0.5)
	local parent = line(panel, "Groups", 2, 0) -- inferred equivalent call
	parent.AutomaticSize = Enum.AutomaticSize.Y
	local uiListLayout2 = Instance.new("UIListLayout")
	uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout2.Parent = parent

	Style.fill(line(panel, "RuleRow", 3, 9), "Rule", Style.STEEL, UDim2.new(1, 0, 0, 1), UDim2.fromScale(0, 0.5)) -- inferred equivalent call
	local frame4 = line(panel, "LevelRow", 4, 24) -- inferred equivalent call
	local frame = Style.frame(frame4, "Level", UDim2.fromOffset(0, 24))
	frame.AutomaticSize = Enum.AutomaticSize.X
	local uiListLayout3 = Instance.new("UIListLayout")
	uiListLayout3.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout3.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout3.Padding = UDim.new(0, 8)
	uiListLayout3.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout3.Parent = frame
	local label_2 = Style.label(frame, "Word", "LEVEL", 18, Style.FONT, 1.5)
	label_2.LayoutOrder = 1
	local label3 = Style.label(frame, "Number", "1", 18, Style.FONT, 1.5)
	label3.LayoutOrder = 2
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = label3
	local box = Style.box(frame, "LevelUp", Style.HAZARD, UDim2.fromOffset(0, 18), 2, 1.5)
	box.AutomaticSize = Enum.AutomaticSize.X
	box.LayoutOrder = 3
	box.Visible = false
	local uiPadding2 = Instance.new("UIPadding")
	uiPadding2.PaddingLeft = UDim.new(0, 5)
	uiPadding2.PaddingRight = UDim.new(0, 5)
	uiPadding2.Parent = box
	local label4 = Style.label(box, "Text", "LEVEL UP", 14, Style.FONT, 0)
	label4.Size = UDim2.fromOffset(0, 18)
	label4.TextColor3 = Style.INK
	local uiScale2 = Instance.new("UIScale")
	uiScale2.Parent = box
	local label5 = Style.label(frame4, "Count", "", 13, Style.FONT_BODY, 1)
	label5.TextColor3 = Style.MUTED
	label5.AnchorPoint = Vector2.new(1, 0.5)
	label5.Position = UDim2.fromScale(1, 0.5)
	local frame5 = line(panel, "BarRow", 5, 12) -- inferred equivalent call
	local fill = Style.fill(
		frame5,
		"Track",
		Style.INK,
		UDim2.new(1, 0, 0, 8),
		UDim2.fromScale(0, 0.5),
		Vector2.new(0, 0.5)
	)
	fill.BackgroundTransparency = 0.3
	Style.stroke(fill, 1, 0.5, Color3.new(0, 0, 0), true)
	local fill2 = Style.fill(fill, "Gain", Style.WHITE, UDim2.fromScale(0, 1))
	local fill3 = Style.fill(fill, "Fill", Style.HAZARD, UDim2.fromScale(0, 1))

	local function setLevel(p2: number, p3: number, p4: number) -- 4 equivalent calls inferred from this helper
		label3.Text = tostring(p2)

		if p4 > 0 then
			label5.Text = Style.thousands(p3) .. " / " .. Style.thousands(p4)
		else
			label5.Text = "MAX"
		end
	end

	local function pop(uiScale3, p2: number, p3: number) -- 2 equivalent calls inferred from this helper
		Style.animate(uiScale3, function(_, p4): boolean
			local v = (p4 - p2) / 0.35
			uiScale3.Scale = 1 + p3 * (1 - Style.easeOut(v))
			return v < 1
		end)
	end

	local count = 0
	local function show(data)
		count += 1
		local v = count
		local v2 = data.after - data.before
		label2.Text = "+" .. Style.thousands(v2)

		for _, frame2 in parent:GetChildren() do
			if frame2:IsA("Frame") then
				frame2:Destroy()
			end
		end

		for k, group in data.groups do
			local frame2 = line(parent, "Group", k, 18) -- inferred equivalent call
			local label6 = Style.label(frame2, "Name", group.label, 14, Style.FONT_BODY, 1)
			label6.TextColor3 = Style.MUTED
			label6.AnchorPoint = Vector2.new(0, 0.5)
			label6.Position = UDim2.fromScale(0, 0.5)
			local label7 = Style.label(frame2, "XP", "+" .. Style.thousands(group.xp), 14, Style.FONT, 1)
			label7.AnchorPoint = Vector2.new(1, 0.5)
			label7.Position = UDim2.fromScale(1, 0.5)
		end

		local v3 = segments(data.before, data.after)
		local level, v4, v5 = Progression.levelOf(data.before)
		setLevel(level, v4, v5) -- inferred equivalent call
		box.Visible = false
		fill3.Size = UDim2.fromScale(not (v5 > 0) and 1 or v4 / v5, 1)
		fill2.Size = fill3.Size
		region.Visible = true
		fade.GroupTransparency = 0
		local total = 0

		for _, v6 in v3 do
			total += (v6.to - v6.from) / v6.need
		end

		local v6 = os.clock() + 0.6
		local v7 = {}
		local total2 = 0
		local v8 = {}

		for k, v9 in v3 do
			local v10 = math.max(0.25, (not (total > 0) and 1 or (v9.to - v9.from) / v9.need / total) * 2.6)
			v7[k] = total2
			total2 += v10
			v8[k] = total2
		end

		local v9 = 1
		local v10 = 0
		Style.animate(region, function(_, p2): boolean
			if v ~= count then
				return false
			end

			local v11 = p2 - v6

			if v11 < 0 then
				return true
			end

			while v9 <= #v3 and v8[v9] <= v11 do
				local v12 = v3[v9]

				if v12.up then
					local v13 = v12.level + 1
					local need = Progression.need(v13)
					setLevel(v13, 0, need) -- inferred equivalent call
					fill3.Size = UDim2.fromScale(need > 0 and 0 or 1, 1)
					fill2.Size = fill3.Size
					box.Visible = true
					pop(uiScale, p2, 0.45) -- inferred equivalent call
					pop(uiScale2, p2, 0.3) -- inferred equivalent call

					if callback then
						callback()
					end
				else
					setLevel(v12.level, v12.to, v12.need) -- inferred equivalent call
					fill3.Size = UDim2.fromScale(v12.to / v12.need, 1)
					fill2.Size = fill3.Size
				end

				v9 += 1
			end

			if v9 <= #v3 then
				local v12 = v3[v9]
				local smoothed = Style.smooth((v11 - v7[v9]) / (v8[v9] - v7[v9]))
				local v13 = v12.from + (v12.to - v12.from) * smoothed
				fill2.Size = UDim2.fromScale(v12.to / v12.need, 1)
				fill3.Size = UDim2.fromScale(v13 / v12.need, 1)
				setLevel(v12.level, math.floor(v13), v12.need) -- inferred equivalent call
				return true
			else
				local v12 = (v11 - total2 - 8) / 0.4

				if v12 >= 1 then
					region.Visible = false
					return false
				end

				local groupTransparency = math.clamp(v12, 0, 1)

				if groupTransparency ~= v10 then
					v10 = groupTransparency
					fade.GroupTransparency = groupTransparency
				end

				return true
			end
		end)
	end

	return { root = region, show = show }
end

function ProgressPanel.mount(p)
	local VoxelSound = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("VoxelSound"))
	local progress = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Remotes"):WaitForChild("Progress")
	local v = ProgressPanel.new(p.layers.hud, function()
		VoxelSound.ui("points", 100)
	end)
	progress.OnClientEvent:Connect(function(data)
		local v2 = type(data) == "table"
			and type(data.before) == "number"
			and type(data.after) == "number"
			and type(data.groups) == "table"
		assert(v2, "ProgressPanel: bad summary from the server")

		local domination = ReplicatedStorage.Game:FindFirstChild("Domination")

		if domination and domination:GetAttribute("Phase") == "over" then
			return
		end

		v.show(data)
	end)
end

return ProgressPanel