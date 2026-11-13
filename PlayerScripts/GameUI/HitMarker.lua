local Style = require(script.Parent:WaitForChild("Style"))

local HitMarker = {
	["new"] = nil,
	new = function(p)
		local region = Style.region(p, "HitMarker", Vector2.new(0.5, 0.5), Vector2.zero, Vector2.new(200, 160))
		local frame = Style.frame(region, "Center", UDim2.fromOffset(0, 0), UDim2.fromScale(0.5, 0.5))

		local v = {}
		local v2 = {}

		for _, v3 in {
			{ -1, -1 },
			{ 1, -1 },
			{ -1, 1 },
			{ 1, 1 }
		} do
			local frame2 = Style.frame(
				frame,
				"Bracket",
				UDim2.fromOffset(9, 9),
				UDim2.new(),
				Vector2.new((1 - v3[1]) / 2, (1 - v3[2]) / 2)
			)

			local fill = Style.fill(
				frame2,
				"H",
				Style.WHITE,
				UDim2.fromOffset(9, 3),
				UDim2.fromScale(0, v3[2] < 0 and 0 or 1),
				Vector2.new(0, v3[2] < 0 and 0 or 1)
			)
			local fill2 = Style.fill(
				frame2,
				"V",
				Style.WHITE,
				UDim2.fromOffset(3, 9),
				UDim2.fromScale(v3[1] < 0 and 0 or 1, 0),
				Vector2.new(v3[1] < 0 and 0 or 1, 0)
			)

			for _, v4 in { fill, fill2 } do
				Style.stroke(v4, 1, 0.3, nil, true)
				table.insert(v, v4)
			end

			table.insert(v2, {
				frame = frame2,
				arms = { fill, fill2 },
				dx = v3[1],
				dy = v3[2]
			})
		end

		local box = Style.box(frame, "Down", Style.ORANGE, UDim2.fromOffset(58, 20), 2, 2)
		box.AnchorPoint = Vector2.new(0.5, 0)
		box.Position = UDim2.fromOffset(0, 34)
		local label = Style.label(box, "Text", "DOWN", 16, Style.FONT, 0)
		label.AutomaticSize = Enum.AutomaticSize.None
		label.Size = UDim2.fromScale(1, 1)
		label.TextColor3 = Style.INK
		local uiScale = Instance.new("UIScale")
		uiScale.Parent = box
		box.Visible = false

		local label2 = Style.label(frame, "Combo", "0", 20, Style.FONT, 2)
		label2.AnchorPoint = Vector2.new(0, 0)
		label2.Position = UDim2.fromOffset(26, 16)
		label2.Visible = false
		local uiStroke = label2:FindFirstChildOfClass("UIStroke")
		local uiScale2 = Instance.new("UIScale")
		uiScale2.Parent = label2

		local hitTick = Instance.new("Sound")
		hitTick.Name = "HitTick"
		hitTick.SoundId = "rbxassetid://9117563161"
		hitTick.Volume = 0.35
		hitTick.Parent = region
		local killTick = Instance.new("Sound")
		killTick.Name = "KillTick"
		killTick.SoundId = "rbxassetid://9118608146"
		killTick.Volume = 0.7
		killTick.PlaybackSpeed = 0.8
		killTick.Parent = region

		local v3 = -10
		local v4 = false
		local v5 = -10
		local v6 = -10
		local v7 = -10
		local total = 0
		local v8 = -10
		local v9 = 0
		local random = Random.new()

		local function setBrackets(p2: number, backgroundTransparency: number, backgroundColor: Color3)
			for _, v10 in v2 do
				v10.frame.Position = UDim2.fromOffset(v10.dx * p2, v10.dy * p2)
			end

			for _, v10 in v do
				v10.BackgroundTransparency = backgroundTransparency
				v10.BackgroundColor3 = backgroundColor
			end
		end

		local function step(_, now)
			local v10 = false

			local v11 = now - v3
			local v12 = v4 and 0.35 or 0.12

			if v11 < v12 + 0.12 then
				v10 = true
				local easeOut = Style.easeOut(v11 / 0.05)
				local v13

				if v4 then
					v13 = 22 - 18 * easeOut
				else
					v13 = 22 - 7 * easeOut * (1 - math.clamp((v11 - 0.05) / v12, 0, 1) * 0.6)
				end

				local backgroundTransparency = math.clamp((v11 - v12) / 0.12, 0, 1)
				local v14

				if v4 and v11 < 0.08 then
					v14 = Style.WHITE
				else
					v14 = if v4 then Style.ORANGE else Style.WHITE
				end

				setBrackets(v13, backgroundTransparency, v14)
			else
				for _, v13 in v2 do
					v13.frame.Visible = false
				end
			end

			local v13 = now - v5

			if v13 < 0.75 then
				uiScale.Scale = 1 + 0.6 * (1 - Style.easeOut(v13 / 0.08))
				box.Rotation = -4 + 3 * Style.easeOut(v13 / 0.08)
				local v14 = math.clamp((v13 - 0.55) / 0.2, 0, 1)
				box.BackgroundTransparency = v14
				label.TextTransparency = v14
				v10 = true
			else
				box.Visible = false
			end

			local v14 = now - v7

			if v14 < 1.25 then
				local textTransparency = math.clamp((v14 - 1) / 0.25, 0, 1)
				label2.TextTransparency = textTransparency
				uiStroke.Transparency = textTransparency * 0.75 + 0.25
				local v15 = now - v6
				uiScale2.Scale = 1 + 0.35 * (1 - Style.easeOut(v15 / 0.1))
				local v16 = now - v8

				if v16 < 0.18 then
					local v17 = 3 * (1 - v16 / 0.18)
					label2.Position = UDim2.fromOffset(
						26 + random:NextNumber(-v17, v17),
						16 + random:NextNumber(-v17, v17)
					)
					return true
				end

				label2.Position = UDim2.fromOffset(26, 16)
				return true
			end

			label2.Visible = false
			total = 0

			return v10
		end

		local v10 = {}
		v10.root = region

		function v10.hit(p2: number, flag: boolean)
			local now = os.clock()
			v3 = now
			v4 = flag

			for _, v11 in v2 do
				v11.frame.Visible = true
			end

			if now - v7 > 1 then
				total = 0
			end

			total += p2
			v7 = now
			v6 = now

			if p2 >= 60 then
				v8 = now
			end

			label2.Text = tostring((math.floor(total + 0.5)))
			local textColor

			if flag then
				textColor = Style.ORANGE
			else
				textColor = Style.HAZARD
			end

			label2.TextColor3 = textColor
			label2.Visible = true

			if flag then
				v5 = now
				box.Visible = true
				killTick:Play()
				v9 = now
			elseif now - v9 >= 0.035 then
				hitTick:Play()
				v9 = now
			end

			step(0, now)
			Style.animate(v10, step)
		end

		setBrackets(22, 1, Style.WHITE)

		for _, v11 in v2 do
			v11.frame.Visible = false
		end

		return v10
	end
}

function HitMarker.mount(p)
	local v = HitMarker.new(p.layers.hud)
	p.Net.remote("HitConfirm").OnClientEvent:Connect(function(_: Vector3, p2: number, flag: boolean, _: string)
		v.hit(p2, flag)
	end)
end

return HitMarker