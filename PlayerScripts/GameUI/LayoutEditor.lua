local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Style = require(script.Parent:WaitForChild("Style"))
local PanelLook = require(script.Parent:WaitForChild("PanelLook"))
local UiTrack = require(script.Parent:WaitForChild("UiTrack"))
local TouchLayout = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("TouchLayout"))

local v = {
	fire = "FIRE",
	aim = "AIM",
	jump = "JUMP",
	reload = "RELOAD",
	crouch = "CROUCH",
	weapons = "WEAPONS",
	streak = "STREAK"
}
local v2 = {
	fire = "f",
	aim = "a",
	jump = "j",
	reload = "r",
	crouch = "c",
	weapons = "w",
	streak = "s"
}

local color = Color3.fromRGB(24, 25, 28)
local color2 = Color3.fromRGB(12, 13, 16)

local function pill(parent) -- 5 equivalent calls inferred from this helper
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(1, 0)
	uiCorner.Parent = parent
end

local function percent(p: number) -- 1 equivalent call inferred from this helper
	return math.round(p * 100) .. "%"
end

local function boxed(p, p2: string, p3: string, maxTextSize: number, p4: number, p5: number, p6: number, p7: number)
	local label = Style.label(p, p2, p3, maxTextSize, Style.FONT, 0)
	label.AutomaticSize = Enum.AutomaticSize.None
	label.Size = UDim2.fromOffset(p4, p5)
	label.Position = UDim2.fromOffset(p6, p7)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextScaled = true
	local uiTextSizeConstraint = Instance.new("UITextSizeConstraint")
	uiTextSizeConstraint.MaxTextSize = maxTextSize
	uiTextSizeConstraint.MinTextSize = 9
	uiTextSizeConstraint.Parent = label
	return label
end

local function slider(p, total: number, p2: string, p3: number, fn)
	local frame = Style.frame(p, p2, UDim2.fromOffset(170, 76), UDim2.fromOffset(total, 0))
	local boxed_2 = boxed(frame, "Name", p2, 14, 118, 20, 0, 8)
	boxed_2.TextColor3 = Style.MUTED
	local label = Style.label(frame, "Value", "", 15, Style.FONT, 0)
	label.AutomaticSize = Enum.AutomaticSize.None
	label.Size = UDim2.fromOffset(48, 20)
	label.Position = UDim2.fromOffset(122, 8)
	label.TextXAlignment = Enum.TextXAlignment.Right
	label.TextColor3 = Style.HAZARD
	local fill = Style.fill(
		frame,
		"Track",
		color2,
		UDim2.fromOffset(142, 10),
		UDim2.fromOffset(14, 50),
		Vector2.new(0, 0.5)
	)
	pill(fill) -- inferred equivalent call
	Style.stroke(fill, 1.5, 0.1, Color3.fromRGB(70, 74, 84), true)
	local fill2 = Style.fill(fill, "Fill", Style.HAZARD, UDim2.fromScale(0, 1))
	pill(fill2) -- inferred equivalent call
	local fill3 = Style.fill(
		fill,
		"Knob",
		Style.WHITE,
		UDim2.fromOffset(28, 28),
		UDim2.fromScale(0, 0.5),
		Vector2.new(0.5, 0.5)
	)
	fill3.ZIndex = 2
	pill(fill3) -- inferred equivalent call
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = fill3
	local hit = Instance.new("TextButton")
	hit.Name = "Hit"
	hit.Text = ""
	hit.BackgroundTransparency = 1
	hit.Size = UDim2.new(1, 28, 0, 48)
	hit.Position = UDim2.fromScale(0.5, 0.5)
	hit.AnchorPoint = Vector2.new(0.5, 0.5)
	hit.ZIndex = 3
	hit.Parent = fill

	local v3 = 0
	local v4 = 1
	local v5 = -1
	local function show(p4: number)
		v5 = p4
		local v6 = not (v3 < v4) and 0 or math.clamp((p4 - v3) / (v4 - v3), 0, 1)
		fill2.Size = UDim2.fromScale(v6, 1)
		fill3.Position = UDim2.fromScale(v6, 0.5)
		label.Text = percent(p4) -- inferred equivalent call
	end
	local function at(x: number)
		local v6 = math.clamp((x - fill.AbsolutePosition.X) / math.max(fill.AbsoluteSize.X, 1), 0, 1)
		local v7 = math.clamp(math.round((v3 + v6 * (v4 - v3)) / p3) * p3, v3, v4)

		if math.abs(v7 - v5) > 1e-6 then
			show(v7)
			fn(v7)
		end
	end

	local v6 = nil
	local v7 = nil
	local function endDrag() -- 3 equivalent calls inferred from this helper
		v6 = nil
		uiScale.Scale = 1

		if v7 then
			for _, connection in v7 do
				connection:Disconnect()
			end

			v7 = nil
		end
	end
	hit.InputBegan:Connect(function(input)
		if
			input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end

		v6 = input
		uiScale.Scale = 1.2
		at(input.Position.X)

		if not v7 then
			v7 = {
				UserInputService.InputChanged:Connect(function(input2)
					if v6 and (input2.UserInputType == Enum.UserInputType.MouseMovement or input2 == v6) then
						at(input2.Position.X)
					end
				end),
				UserInputService.InputEnded:Connect(function(input2)
					if v6 and (input2 == v6 or input2.UserInputType == Enum.UserInputType.MouseButton1) then
						endDrag() -- inferred equivalent call
					end
				end)
			}
		end

		local userInputState = input.UserInputState

		if userInputState == Enum.UserInputState.End or userInputState == Enum.UserInputState.Cancel then
			endDrag() -- inferred equivalent call
		end
	end)
	hit.AncestryChanged:Connect(function()
		if not hit:IsDescendantOf(game) then
			endDrag() -- inferred equivalent call
		end
	end)
	return {
		root = frame,
		show = show,
		range = function(p4: number, p5: number)
			v3 = p4
			v4 = p5
		end
	}
end

local function drawWeapons(frame, vector2: Vector2)
	local label = Style.label(frame, "Ammo", "30", 24, Style.FONT, 2)
	label.AnchorPoint = Vector2.new(1, 0)
	label.Position = UDim2.new(0.5, 2, 0, 0)
	local label2 = Style.label(frame, "Reserve", "120", 14, Style.FONT, 1.5)
	label2.Position = UDim2.new(0.5, 8, 0, 8)
	label2.TextColor3 = Style.MUTED

	local v3 = (vector2.X - 18) / 4

	for i = 1, 4 do
		local fill = Style.fill
		local v4 = "Card" .. i
		local v5 = if i == 1 then Style.HAZARD else Style.PANEL
		local v6 = fill(
			frame,
			v4,
			v5,
			UDim2.fromOffset(v3, 34),
			UDim2.new(0, (i - 1) * (v3 + 6), 1, 0),
			Vector2.new(0, 1)
		)
		v6.BackgroundTransparency = i == 1 and 0.06 or 0.5
		Style.corner(v6, 8)
		Style.stroke(v6, 1.5, 0.35, Color3.new(0, 0, 0), true)
		local fill2 = Style.fill
		local v7 = if i == 1 then Style.INK else Style.WHITE
		local v8 = fill2(v6, "Gun", v7, UDim2.fromScale(0.56, 0.2), UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5))
		v8.BackgroundTransparency = i == 1 and 0 or 0.25
		Style.corner(v8, 2)
	end
end

local function drawStreak(frame, vector2: Vector2)
	local panel = Style.panel(frame, "Plate", UDim2.fromScale(1, 1))
	local label = Style.label(panel, "Title", "AIRSTRIKE", 15, Style.FONT, 0)
	label.Position = UDim2.fromOffset(10, 3)
	label.TextColor3 = Style.MUTED

	for i = 1, 5 do
		local fill = Style.fill
		local v3 = "Notch" .. i
		local v4 = if i <= 2 then Style.HAZARD else Style.STEEL
		local v5 = fill(panel, v3, v4, UDim2.fromOffset(22, 10), UDim2.fromOffset((i - 1) * 27 + 10, vector2.Y - 18))
		Style.corner(v5, 1)
		Style.stroke(v5, 1, 0.2, nil, true)
	end
end

local function overlap(data, data2): boolean
	local v3 = data.box.kind == "disc"
	local v4 = data2.box.kind == "disc"

	if v3 and v4 then
		return (data.centre - data2.centre).Magnitude < (data.size.X + data2.size.X) / 2 - 2
	end

	if v3 == v4 then
		local v5 = data.centre - data2.centre
		return math.abs(v5.X) < (data.size.X + data2.size.X) / 2 - 2
			and math.abs(v5.Y) < (data.size.Y + data2.size.Y) / 2 - 2
	else
		local v5 = if v3 then data else data2

		if v3 then
			data = data2
		end

		local halfSize = data.size / 2
		local v6 = v5.centre - data.centre
		return (v6 - Vector2.new(math.clamp(v6.X, -halfSize.X, halfSize.X), (math.clamp(v6.Y, -halfSize.Y, halfSize.Y)))).Magnitude < v5.size.X / 2 - 2
	end
end

return {
	mount = function(p, callback)
		local flag = false
		local v3 = ""
		local v4 = nil
		local v5 = nil
		local v6 = {}
		local v7 = 1
		local v8 = TouchLayout.ALPHA_DEFAULT
		local v9 = 0
		local flag2 = true

		local v10 = nil
		local parent = nil
		local v11 = nil
		local parent2 = nil
		local uiScale = nil
		local v12 = nil
		local v13 = nil
		local v14 = nil
		local v15 = nil
		local parent3 = nil
		local v16 = nil
		local v17 = {}
		local v18 = false

		local function screenSize() -- 3 equivalent calls inferred from this helper
			return parent.AbsoluteSize
		end

		local function spaceOf(p2: string) -- 8 equivalent calls inferred from this helper
			if TouchLayout.box(p2).space == "controls" then
				return v11
			end

			return parent
		end

		local function geometry(p2: string)
			local box = TouchLayout.box(p2)
			local item = TouchLayout.item(p2)
			local absoluteSize = spaceOf(p2).AbsoluteSize -- inferred equivalent call
			local size = box.size(absoluteSize)
			local v19

			if box.kind == "disc" then
				local discPx = TouchLayout.discPx(size.X, item.s)
				v19 = Vector2.new(discPx, discPx)
			else
				v19 = size * item.s
			end

			return v19, TouchLayout.spot(item, box.anchor, v19, absoluteSize) or box.home(absoluteSize)
		end

		local function eachDisc(fn)
			for _, v19 in TouchLayout.IDS do
				if TouchLayout.box(v19).kind == "disc" then
					fn(v19)
				end
			end
		end

		local function unsure() -- 4 equivalent calls inferred from this helper
			v9 = 0
			parent3.Text = "RESET"
			v15.BackgroundColor3 = Style.STEEL
			parent3.TextColor3 = Style.WHITE
		end

		local function dock(flag3: boolean) -- 2 equivalent calls inferred from this helper
			local absoluteSize = screenSize() -- inferred equivalent call
			local v19 = v4

			if v19 then
				local y = v17[v19].centre.Y

				if flag2 and y < absoluteSize.Y * 0.42 then
					flag2 = false
				elseif not flag2 and absoluteSize.Y * 0.5 < y then
					flag2 = true
				end
			else
				flag2 = true
			end

			local v20 = 76 * uiScale.Scale
			local v21

			if flag2 then
				v21 = Style.topOverlap(parent) + 6
			else
				v21 = absoluteSize.Y - v20 - 6
			end

			local udim = UDim2.new(0.5, 0, 0, v21)

			if flag3 then
				parent2.Position = udim
			elseif parent2.Position ~= udim then
				TweenService:Create(parent2, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Position = udim
				}):Play()
			end
		end

		local function draw()
			if not flag then
				return
			end

			local absoluteSize = screenSize() -- inferred equivalent call

			if absoluteSize.X < 1 or absoluteSize.Y < 1 or v11.AbsoluteSize.X < 1 or v11.AbsoluteSize.Y < 1 then
				return
			end

			for _, v19 in TouchLayout.IDS do
				local v20 = v17[v19]
				local item = TouchLayout.item(v19)
				local size2, v21 = geometry(v19)

				local centre = v21 + (Vector2.new(0.5, 0.5) - v20.box.anchor) * size2 + (spaceOf(v19).AbsolutePosition - parent.AbsolutePosition) -- inferred equivalent call
				v20.size = size2
				v20.centre = centre
				v20.hit.Position = UDim2.fromOffset(centre.X, centre.Y)
				v20.hit.Size = UDim2.fromOffset(math.max(size2.X, 48), (math.max(size2.Y, 48)))
				v20.body.Size = UDim2.fromOffset(size2.X, size2.Y)
				v20.ring.Size = UDim2.fromOffset(size2.X + 10, size2.Y + 10)
				local art = v20.art
				local glyph = v20.glyph

				if art then
					local x = size2.X
					local size = v20.box.size
					art.Scale = x / math.max(size(spaceOf(v19).AbsoluteSize).X / (Style.scale() * Style.touchHud()), 1) -- inferred equivalent call
				end

				if not glyph then
					continue
				end

				v20.body.BackgroundTransparency = item.a
				glyph.ImageTransparency = math.clamp(
					math.max(item.a - TouchLayout.ALPHA_DEFAULT, 0) * 1.2 + 0.08,
					0.08,
					0.6
				)
			end

			for _, v19 in TouchLayout.IDS do
				local v20 = v17[v19]
				local flag3 = false

				for _, v21 in TouchLayout.IDS do
					if v21 ~= v19 and overlap(v20, v17[v21]) then
						flag3 = true
						break
					end
				end

				local v21 = v19 == v4
				v20.ring.Visible = v21 or flag3
				local stroke = v20.stroke
				local color3

				if flag3 then
					color3 = Style.ORANGE
				else
					color3 = Style.HAZARD
				end

				stroke.Color = color3
				v20.stroke.Thickness = v21 and 4 or 2
				v20.hit.ZIndex = v21 and 3 or 2
			end

			local v19 = v4
			v12.Text = not v19 and "ALL BUTTONS" or v[v19]
			local visible = v19 == nil or TouchLayout.box(v19).kind == "disc"
			v14.root.Visible = visible
			local range = v13.range
			local v20

			if v19 then
				v20 = TouchLayout.sizeMin(v19, spaceOf(v19).AbsoluteSize) -- inferred equivalent call
			else
				v20 = TouchLayout.SIZE_MIN
			end

			range(v20, TouchLayout.SIZE_MAX)
			local show = v13.show
			local v21

			if v19 then
				v21 = TouchLayout.item(v19).s
			else
				v21 = v7
			end

			show(v21)
			v14.range(TouchLayout.ALPHA_MIN, TouchLayout.ALPHA_MAX)
			local show2 = v14.show
			local v22

			if v19 and visible then
				v22 = TouchLayout.item(v19).a
			else
				v22 = v8
			end

			show2(v22)
			dock(false)
		end

		local function readAll()
			local total = 0
			local count = 0
			local total2 = 0
			local count2 = 0

			for _, v19 in TouchLayout.IDS do
				local item = TouchLayout.item(v19)
				total += item.s
				count += 1

				if TouchLayout.box(v19).kind ~= "disc" then
					continue
				end

				total2 += item.a
				count2 += 1
			end

			v7 = math.round(total / count / TouchLayout.SIZE_STEP) * TouchLayout.SIZE_STEP
			v8 = math.round(total2 / count2 / TouchLayout.ALPHA_STEP) * TouchLayout.ALPHA_STEP
		end

		local function pick(name: string?) -- 2 equivalent calls inferred from this helper
			v4 = name
			unsure() -- inferred equivalent call

			if not name then
				readAll()
			end

			v16.Visible = false
			draw()
		end

		local function localPoint(input, p2: string) -- 2 equivalent calls inferred from this helper
			return Vector2.new(input.Position.X, input.Position.Y) - spaceOf(p2).AbsolutePosition -- inferred equivalent call
		end

		local function handle(name: string)
			local box = TouchLayout.box(name)
			local v19 = box.kind == "disc"
			local textButton = Instance.new("TextButton")
			textButton.Name = name
			textButton.Text = ""
			textButton.AutoButtonColor = false
			textButton.BackgroundTransparency = 1
			textButton.AnchorPoint = Vector2.new(0.5, 0.5)
			textButton.ZIndex = 2
			textButton.Parent = parent
			local frame = Style.frame(
				textButton,
				"Body",
				UDim2.fromOffset(1, 1),
				UDim2.fromScale(0.5, 0.5),
				Vector2.new(0.5, 0.5)
			)
			local frame2 = Style.frame(
				textButton,
				"Ring",
				UDim2.fromOffset(1, 1),
				UDim2.fromScale(0.5, 0.5),
				Vector2.new(0.5, 0.5)
			)
			frame2.Visible = false
			local uiStroke = Instance.new("UIStroke")
			uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			uiStroke.Color = Style.HAZARD
			uiStroke.Thickness = 2
			uiStroke.Parent = frame2
			local uiScale2 = nil
			local glyph = nil

			if v19 then
				pill(frame2) -- inferred equivalent call
				pill(frame) -- inferred equivalent call
				frame.BackgroundColor3 = color
				frame.BackgroundTransparency = TouchLayout.ALPHA_DEFAULT
				local uiStroke2 = Instance.new("UIStroke")
				uiStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				uiStroke2.Thickness = 1.5
				uiStroke2.Color = Style.INK
				uiStroke2.Transparency = 0.45
				uiStroke2.Parent = frame
				glyph = Instance.new("ImageLabel")
				glyph.Name = "Glyph"
				glyph.BackgroundTransparency = 1
				glyph.AnchorPoint = Vector2.new(0.5, 0.5)
				glyph.Position = UDim2.fromScale(0.5, 0.5)
				glyph.Size = UDim2.fromScale(0.6, 0.6)
				local glyph2 = box.glyph
				assert(glyph2, "LayoutEditor: disc " .. name .. " has no glyph")
				glyph.Image = glyph2
				glyph.ImageColor3 = Style.WHITE
				glyph.Parent = frame
			else
				Style.corner(frame2, 8)

				local v20 = box.size(spaceOf(name).AbsoluteSize) / (Style.scale() * Style.touchHud()) -- inferred equivalent call
				local frame3 = Style.frame(frame, "Art", UDim2.fromOffset(v20.X, v20.Y))
				uiScale2 = Instance.new("UIScale")
				uiScale2.Parent = frame3

				if name == "weapons" then
					drawWeapons(frame3, v20)
				elseif name == "streak" then
					drawStreak(frame3, v20)
				else
					error("LayoutEditor: no drawing for " .. name)
				end
			end

			textButton.InputBegan:Connect(function(input)
				local userInputType = input.UserInputType

				if
					userInputType ~= Enum.UserInputType.Touch and userInputType ~= Enum.UserInputType.MouseButton1
					or input.UserInputState ~= Enum.UserInputState.Begin
					or v5
				then
					return
				end

				pick(name) -- inferred equivalent call
				local _, v20 = geometry(name)
				local from = localPoint(input, name) -- inferred equivalent call
				v5 = {
					input = input,
					mouse = userInputType == Enum.UserInputType.MouseButton1,
					id = name,
					grab = v20 - from,
					from = from,
					moving = false
				}
			end)
			return {
				id = name,
				box = box,
				hit = textButton,
				body = frame,
				ring = frame2,
				stroke = uiStroke,
				art = uiScale2,
				glyph = glyph,
				size = Vector2.zero,
				centre = Vector2.zero
			}
		end

		local function fitBar() -- 2 equivalent calls inferred from this helper
			local x = screenSize().X -- inferred equivalent call

			if x >= 1 then
				uiScale.Scale = math.min((x - 12) / 734, 1.15)
			end
		end

		local v19 = {}

		local function build()
			v18 = true
			v10 = Style.layer(p.playerGui, "LayoutEditor", 10)

			parent = Style.frame(v10, "Screen", UDim2.fromScale(1, 1))
			parent.Visible = false

			local layoutEditorControls = Instance.new("ScreenGui")
			layoutEditorControls.Name = "LayoutEditorControls"
			layoutEditorControls.ResetOnSpawn = false
			layoutEditorControls.IgnoreGuiInset = true
			layoutEditorControls.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
			layoutEditorControls.Parent = p.playerGui
			v11 = Style.frame(layoutEditorControls, "Screen", UDim2.fromScale(1, 1))

			local shade = Instance.new("TextButton")
			shade.Name = "Shade"
			shade.Text = ""
			shade.AutoButtonColor = false
			shade.BorderSizePixel = 0
			shade.BackgroundColor3 = Style.INK
			shade.BackgroundTransparency = 0.45
			shade.AnchorPoint = Vector2.new(0.5, 0.5)
			shade.Position = UDim2.fromScale(0.5, 0.5)
			shade.Size = UDim2.fromOffset(8000, 8000)
			shade.Modal = true
			shade.Parent = parent
			shade.Activated:Connect(function()
				pick(nil) -- inferred equivalent call
			end)

			v16 = Style.label(parent, "Hint", "DRAG A BUTTON TO MOVE IT", 20, Style.FONT, 2)
			v16.AnchorPoint = Vector2.new(0.5, 0.5)
			v16.Position = UDim2.fromScale(0.5, 0.5)

			for _, v20 in TouchLayout.IDS do
				v17[v20] = handle(v20)
			end

			parent2 = Style.fill(
				parent,
				"Bar",
				Style.INK,
				UDim2.fromOffset(734, 76),
				UDim2.fromScale(0.5, 0),
				Vector2.new(0.5, 0)
			)
			parent2.BackgroundTransparency = 0.06
			parent2.Active = true
			parent2.ZIndex = 5
			Style.corner(parent2, 10)
			Style.stroke(parent2, 2, 0.3, Style.STEEL_LIGHT, true)
			uiScale = Instance.new("UIScale")
			uiScale.Parent = parent2
			local boxed_2 = boxed(parent2, "Caption", "CUSTOMIZE LAYOUT", 13, 150, 18, 12, 12)
			boxed_2.TextColor3 = Style.MUTED
			v12 = boxed(parent2, "Name", "ALL BUTTONS", 24, 150, 32, 12, 32)
			v12.TextColor3 = Style.HAZARD
			local total = 168
			v13 = slider(parent2, total, "SIZE", TouchLayout.SIZE_STEP, function(p2: number)
				local v20 = v4

				if v20 then
					TouchLayout.setItem(v20, { s = p2 })
					return
				end

				v7 = p2

				for _, v21 in TouchLayout.IDS do
					local setItem = TouchLayout.setItem
					local sizeMin = TouchLayout.sizeMin
					setItem(v21, {
						s = math.max(p2, sizeMin(v21, spaceOf(v21).AbsoluteSize)) -- inferred equivalent call
					})
				end
			end)
			total += 178
			v14 = slider(parent2, total, "SEE-THROUGH", TouchLayout.ALPHA_STEP, function(p2: number)
				local v20 = v4

				if v20 then
					TouchLayout.setItem(v20, { a = p2 })
					return
				end

				v8 = p2
				eachDisc(function(p3: string)
					TouchLayout.setItem(p3, { a = p2 })
				end)
			end)
			total += 178

			v15, parent3 = Style.button(
				parent2,
				"Reset",
				"RESET",
				Style.STEEL,
				UDim2.fromOffset(96, 52),
				Style.WHITE,
				18
			)
			v15.Position = UDim2.fromOffset(total, 12)
			v15.AutoButtonColor = false
			Style.corner(v15, 10)
			parent3.TextScaled = true
			local uiTextSizeConstraint = Instance.new("UITextSizeConstraint")
			uiTextSizeConstraint.MaxTextSize = 18
			uiTextSizeConstraint.MinTextSize = 9
			uiTextSizeConstraint.Parent = parent3
			PanelLook.feel(v15)

			v15.Activated:Connect(function()
				local v20 = v4

				if v20 then
					TouchLayout.reset(v20)
				elseif os.clock() < v9 then
					unsure() -- inferred equivalent call
					TouchLayout.reset()
					readAll()
					draw()
				else
					local v21 = os.clock() + 3
					v9 = v21
					parent3.Text = "SURE?"
					v15.BackgroundColor3 = Style.ORANGE
					parent3.TextColor3 = Style.INK
					task.delay(3, function()
						if v9 == v21 then
							unsure() -- inferred equivalent call
						end
					end)
				end
			end)
			total += 104
			local button, parent4 = Style.button(
				parent2,
				"Done",
				"DONE",
				Style.HAZARD,
				UDim2.fromOffset(96, 52),
				Style.INK,
				20
			)
			button.Position = UDim2.fromOffset(total, 12)
			button.AutoButtonColor = false
			Style.corner(button, 10)
			parent4.TextScaled = true
			local uiTextSizeConstraint2 = Instance.new("UITextSizeConstraint")
			uiTextSizeConstraint2.MaxTextSize = 20
			uiTextSizeConstraint2.MinTextSize = 9
			uiTextSizeConstraint2.Parent = parent4
			PanelLook.feel(button)
			button.Activated:Connect(function()
				v19.close()
			end)
			assert(total + 96 + 10 == 734, "LayoutEditor: the bar's pieces do not add up to BAR_W")

			local function resized()
				fitBar() -- inferred equivalent call

				if flag then
					draw()
					dock(true) -- inferred equivalent call
				end
			end
			parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(resized)
			parent:GetPropertyChangedSignal("AbsolutePosition"):Connect(resized)
			v11:GetPropertyChangedSignal("AbsoluteSize"):Connect(resized)
			v11:GetPropertyChangedSignal("AbsolutePosition"):Connect(resized)
			TouchLayout.onChange(draw)
		end

		local function summary()
			local v20 = {}

			for _, v21 in TouchLayout.IDS do
				if TouchLayout.isDefault(v21) then
					continue
				end

				local item = TouchLayout.item(v21)
				table.insert(
					v20,
					v2[v21] .. (item.s > 1 and "+" or item.s < 1 and "-" or "") .. (item.x and "m" or "") .. (math.abs(item.a - TouchLayout.ALPHA_DEFAULT) > 1e-6 and "t" or "")
				)
			end

			if #v20 > 0 then
				return (table.concat(v20, " "))
			end

			return "reset"
		end

		function v19.isOpen()
			return flag
		end

		function v19.open()
			if flag then
				return
			end

			for _, v20 in TouchLayout.IDS do
				TouchLayout.box(v20)
			end

			if not v18 then
				build()
			end

			flag = true
			v3 = TouchLayout.encode()
			v4 = nil
			v5 = nil
			parent.Visible = true
			TouchLayout.setEditing(true)
			p.setMenu(true)
			v6 = {
				UserInputService.InputChanged:Connect(function(input)
					local v20 = v5

					if
						not v20
						or input ~= v20.input
						and (not v20.mouse or input.UserInputType ~= Enum.UserInputType.MouseMovement)
					then
						return
					end

					local v21 = localPoint(input, v20.id) -- inferred equivalent call

					if not v20.moving and (v21 - v20.from).Magnitude < 6 then
						return
					end

					v20.moving = true
					local v22 = spaceOf(v20.id) -- inferred equivalent call
					local absoluteSize = v22.AbsoluteSize
					local v23 = geometry(v20.id)

					local keep = TouchLayout.keep(
						v21 + v20.grab,
						TouchLayout.box(v20.id).anchor,
						v23,
						absoluteSize,
						Style.topOverlap(v22)
					)
					TouchLayout.setItem(v20.id, {
						x = keep.X / absoluteSize.X,
						y = keep.Y / absoluteSize.Y
					})
				end),
				UserInputService.InputEnded:Connect(function(input)
					local v20 = v5

					if
						v20
						and (input == v20.input or v20.mouse and input.UserInputType == Enum.UserInputType.MouseButton1)
					then
						v5 = nil
					end
				end)
			}
			fitBar() -- inferred equivalent call
			unsure() -- inferred equivalent call
			readAll()
			draw()
			dock(true) -- inferred equivalent call
			v16.Visible = true
			UiTrack.send("layout_open")
		end

		function v19.close()
			if not flag then
				return
			end

			flag = false
			v5 = nil

			for _, connection in v6 do
				connection:Disconnect()
			end

			v6 = {}
			parent.Visible = false
			TouchLayout.setEditing(false)
			p.setMenu(false)
			local encoded = TouchLayout.encode()

			if encoded ~= v3 then
				callback(encoded)
				UiTrack.send("layout_save", summary())
			end
		end

		return v19
	end
}