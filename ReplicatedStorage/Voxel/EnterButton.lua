local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local v = { "heli", "vehicle", "gun", "lift" }

local v2 = {}
local v3 = nil
local v4 = 0
local v5 = -1
local v6 = nil

local v7 = {
	TANK = {
		{ 2, 15, 32, 7, 3 },
		{ 4, 11, 28, 5, 1 },
		{ 11, 6, 13, 6, 2 },
		{ 22, 7.5, 13, 2 }
	},
	IFV = {
		{ 3, 16, 30, 6, 3 },
		{ 3, 8, 30, 9, 2 },
		{ 14, 4, 9, 5, 1 },
		{ 22, 5, 9, 1.5 }
	},
	HUMVEE = {
		{ 2, 10, 32, 7, 2 },
		{ 9, 4, 15, 7, 2 },
		{ 5, 15, 8, 8, 4 },
		{ 23, 15, 8, 8, 4 }
	},
	HELICOPTER = {
		{ 1, 3, 34, 2, 1 },
		{ 16, 4, 3, 4 },
		{ 4, 8, 17, 9, 4 },
		{ 19, 10, 15, 3, 1 },
		{ 31, 6, 3, 6, 1 },
		{ 6, 20, 16, 2, 1 }
	},
	LOCK = {
		{ 13, 2, 10, 10, 5 },
		{ 9, 10, 18, 13, 2 }
	},
	GUN = {
		{ 3, 7.5, 18, 2.5, 1 },
		{ 1, 6.5, 4, 4.5, 1 },
		{ 19, 5.5, 11, 6.5, 1 },
		{ 30, 6.5, 3, 8, 1 },
		{ 21, 11, 6, 5, 1 },
		{ 13.5, 12, 3, 12, 1, 28 },
		{ 20.5, 12, 3, 12, 1, -28 }
	},
	LIFT = {
		{ 8, 1, 20, 22, 3 },
		{ 10.5, 3.5, 15, 17, 2, 0, 1 },
		{ 16.5, 8, 3, 11, 1 },
		{ 12.3, 8, 8, 3, 1, -45 },
		{ 15.7, 8, 8, 3, 1, 45 }
	}
}

local function build()
	local Style = require(Players.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("GameUI"):WaitForChild("Style"))
	local enterButton = Instance.new("ScreenGui")
	enterButton.Name = "EnterButton"
	enterButton.ResetOnSpawn = false
	enterButton.DisplayOrder = 6
	enterButton.Enabled = false
	enterButton.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	enterButton.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

	local button = Instance.new("TextButton")
	button.Name = "Button"
	button.Text = ""
	button.AutoButtonColor = false
	button.AnchorPoint = Vector2.new(0.5, 1)
	button.Position = UDim2.fromScale(0.5, 0.7)
	button.Size = UDim2.fromOffset(184, 60)
	button.BackgroundColor3 = Style.PANEL
	button.BackgroundTransparency = 0.28
	button.BorderSizePixel = 0
	button.Parent = enterButton
	Style.corner(button, 8)
	local stroke_2 = Style.stroke(button, 1.5, 0.35, Color3.new(0, 0, 0), true)
	stroke_2.LineJoinMode = Enum.LineJoinMode.Round
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = button

	local frame = Style.frame(button, "Ring", UDim2.fromScale(1, 1), UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5))
	Style.corner(frame, 8)
	local stroke = Style.stroke(frame, 2, 1, Style.HAZARD, true)
	stroke.LineJoinMode = Enum.LineJoinMode.Round

	local box = Style.box(button, "Tile", Style.HAZARD, UDim2.fromOffset(48, 48), 6, 0)
	box.Position = UDim2.fromOffset(6, 6)
	local frames = {}

	for k, v8 in v7 do
		local frame2 = Style.frame(box, k, UDim2.fromOffset(36, 24), UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5))
		frame2.Visible = false

		for k2, v9 in v8 do
			local fill = Style.fill
			local v10 = "Part" .. k2
			local v11 = if v9[7] == 1 then Style.HAZARD else Style.INK
			local v12 = fill(frame2, v10, v11, UDim2.fromOffset(v9[3], v9[4]), UDim2.fromOffset(v9[1], v9[2]))
			v12.ZIndex = k2

			if v9[5] and v9[5] > 0 then
				Style.corner(v12, v9[5])
			end

			if v9[6] and v9[6] ~= 0 then
				v12.Rotation = v9[6]
			end
		end

		frames[k] = frame2
	end

	local fill = Style.fill(frames.LOCK, "Hole", Style.STEEL_LIGHT, UDim2.fromOffset(5, 5), UDim2.fromOffset(15.5, 4.5))
	Style.corner(fill, 3)
	fill.ZIndex = 3
	local fill2 = Style.fill(
		frames.LOCK,
		"Keyhole",
		Style.STEEL_LIGHT,
		UDim2.fromOffset(3, 6),
		UDim2.fromOffset(16.5, 14)
	)
	Style.corner(fill2, 2)
	fill2.ZIndex = 3

	local frame2 = Style.frame(
		button,
		"Chevron",
		UDim2.fromOffset(10, 16),
		UDim2.new(1, -14, 0.5, 0),
		Vector2.new(0.5, 0.5)
	)

	for k, rotation in { 45, -45 } do
		local fill3 = Style.fill(
			frame2,
			"Bar" .. k,
			Style.HAZARD,
			UDim2.fromOffset(10, 3),
			UDim2.new(0.5, 0, 0.5, k == 1 and -3.5 or 3.5),
			Vector2.new(0.5, 0.5)
		)
		fill3.Rotation = rotation
		Style.corner(fill3, 1)
	end

	local label = Style.label(button, "What", "", 13, Style.FONT, 0)
	label.AutomaticSize = Enum.AutomaticSize.None
	label.Size = UDim2.new(1, -88, 0, 15)
	label.Position = UDim2.fromOffset(64, 7)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextColor3 = Style.MUTED
	local label2 = Style.label(button, "Word", "", 30, Style.FONT, 1.5)
	label2.AutomaticSize = Enum.AutomaticSize.None
	label2.Size = UDim2.new(1, -88, 0, 32)
	label2.Position = UDim2.new(0, 64, 1, -4)
	label2.AnchorPoint = Vector2.new(0, 1)
	label2.TextXAlignment = Enum.TextXAlignment.Left
	label2.TextScaled = true
	local uiTextSizeConstraint = Instance.new("UITextSizeConstraint")
	uiTextSizeConstraint.MaxTextSize = 30
	uiTextSizeConstraint.Parent = label2

	button.Activated:Connect(function()
		local v8 = v3

		if v8 and not v8.locked then
			v5 = os.clock()
			v8.press()
		end
	end)
	v6 = {
		gui = enterButton,
		button = button,
		posY = 1e999,
		scale = uiScale,
		tile = box,
		icons = frames,
		word = label2,
		what = label,
		ring = frame,
		ringStroke = stroke,
		chevron = frame2,
		kind = nil,
		lockShown = nil
	}

	return Style
end

local v8 = nil
RunService.RenderStepped:Connect(function(_: number)
	local v9 = nil

	for _, v10 in v do
		local v11 = v2[v10]

		if v11 then
			v9 = v11
			break
		end
	end

	if v9 then
		if not v6 then
			v8 = build()
		end

		local v10 = assert(v6)
		local now = os.clock()

		if not v3 then
			v4 = now
		end

		v3 = v9

		if not v10.gui.Enabled then
			v10.gui.Enabled = true
		end

		local v11 = (workspace.CurrentCamera.ViewportSize.Y - v10.gui.AbsolutePosition.Y) / 560
		local posY = -(18 + 116 * v11 + 14)

		if v10.posY ~= posY then
			v10.posY = posY
			v10.button.Position = UDim2.new(0.5, 0, 1, posY)
		end

		if v10.word.Text ~= v9.word then
			v10.word.Text = v9.word
		end

		if v10.what.Text ~= v9.what then
			v10.what.Text = v9.what
		end

		local icon = v9.icon or v9.what
		assert(v9.icon == nil or v7[icon], "[EnterButton] no picture named " .. tostring(v9.icon))
		local kind = v9.locked and "LOCK" or not v7[icon] and "TANK" or icon

		if v10.kind ~= kind then
			if v10.kind then
				v10.icons[v10.kind].Visible = false
			end

			v10.icons[kind].Visible = true
			v10.kind = kind
		end

		if v10.lockShown ~= v9.locked then
			v10.lockShown = v9.locked
			local tile = v10.tile
			local backgroundColor

			if v9.locked then
				backgroundColor = v8.STEEL_LIGHT
			else
				backgroundColor = v8.HAZARD
			end

			tile.BackgroundColor3 = backgroundColor
			local word = v10.word
			local textColor = if v9.locked then v8.MUTED else v8.WHITE
			word.TextColor3 = textColor
			v10.chevron.Visible = not v9.locked
			v10.ringStroke.Transparency = 1
		end

		local v12 = now - v4
		local v13 = math.clamp(v11, 0.85, 1.4)
		local v14 = not (v12 < 0.22) and 1 or 0.6 + 0.4 * v8.pop(v12 / 0.22)
		local v15 = now - v5

		if v15 < 0.18 then
			v14 *= 1 - math.sin(v15 / 0.18 * 3.141592653589793) * 0.08
		end

		local scale = v13 * v14

		if math.abs(v10.scale.Scale - scale) > 0.001 then
			v10.scale.Scale = scale
		end

		if not v9.locked and v12 > 0.3 then
			local v16 = (v12 - 0.3) % 1.6 / 0.7

			if v16 <= 1 then
				local easeOut = v8.easeOut(v16)
				v10.ring.Size = UDim2.new(1, 18 * easeOut, 1, 18 * easeOut)
				v10.ringStroke.Transparency = 0.15 + 0.85 * easeOut
			elseif v10.ringStroke.Transparency < 1 then
				v10.ringStroke.Transparency = 1
			end
		end
	else
		if v3 and v6 then
			v6.gui.Enabled = false
		end

		v3 = nil
	end
end)
return {
	set = function(p: string, p2)
		assert(table.find(v, p), "[EnterButton] unknown owner " .. tostring(p))

		if not UserInputService.TouchEnabled then
			return
		end

		v2[p] = p2
	end
}