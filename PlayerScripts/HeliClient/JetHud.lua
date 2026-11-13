local Players = game:GetService("Players")

local JetHud = {}
JetHud.parent = nil
local color = Color3.fromRGB(20, 21, 24)
local color2 = Color3.fromRGB(242, 238, 228)
local color3 = Color3.fromRGB(255, 198, 32)
local color4 = Color3.fromRGB(214, 72, 52)
local color5 = Color3.fromRGB(24, 25, 28)
local color6 = Color3.fromRGB(150, 156, 164)
local rbxassetfontsfamiliesOswaldjson = Font.new("rbxasset://fonts/families/Oswald.json", Enum.FontWeight.Bold)

local v = {
	-60,
	-45,
	-30,
	-20,
	-10,
	10,
	20,
	30,
	45,
	60
}

local v2 = {
	-45,
	-30,
	-20,
	-10,
	0,
	10,
	20,
	30,
	45
}

local function new(className: string, items, parent) -- 30 equivalent calls inferred from this helper
	local instance = Instance.new(className)

	for k, item in items do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

local function line(parent, p: number, p2: number, color7: Color3?)
	local parent2 = new("Frame", { -- inferred equivalent call
		Size = UDim2.fromOffset(p, p2),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = color7 or color2,
		BorderSizePixel = 0
	}, parent)
	new( -- inferred equivalent call
		"UIStroke",
		{
			Color = color,
			Transparency = 0.35,
			Thickness = 1.5,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		},
		parent2
	)
	return parent2
end

local function text(parent, text2: string, textSize: number, position: UDim2, vector2: Vector2?, color7: Color3?)
	local parent2 = new("TextLabel", { -- inferred equivalent call
		BackgroundTransparency = 1,
		FontFace = rbxassetfontsfamiliesOswaldjson,
		TextSize = textSize,
		TextColor3 = color7 or color2,
		Text = text2,
		AutomaticSize = Enum.AutomaticSize.XY,
		Size = UDim2.fromOffset(0, 0),
		Position = position,
		AnchorPoint = vector2 or Vector2.new(0.5, 0.5)
	}, parent)

	new("UIStroke", { Color = color, Transparency = 0.3, Thickness = 1.5 }, parent2) -- inferred equivalent call
	return parent2
end

local function ring(parent, p: number, thickness: number, color7: Color3?)
	local parent2 = new( -- inferred equivalent call
		"Frame",
		{
			Size = UDim2.fromOffset(p, p),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1
		},
		parent
	)
	new("UICorner", { CornerRadius = UDim.new(0.5, 0) }, parent2) -- inferred equivalent call
	new("UIStroke", { -- inferred equivalent call
		Color = color7 or color2,
		Thickness = thickness
	}, parent2)
	return parent2
end

local v3 = nil

local function build()
	local v4 = {
		Name = "JetHud",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 4,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	}
	local screenGui = Instance.new("ScreenGui")

	local v5 = {}

	for k, v6 in v4 do
		screenGui[k] = v6
	end

	screenGui.Parent = nil

	v5.gui = screenGui

	local v6 = new( -- inferred equivalent call
		"Frame",
		{
			Name = "Glass",
			Size = UDim2.fromOffset(400, 400),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1
		},
		screenGui
	)
	v5.glass = v6
	v5.scale = new("UIScale", {}, v6) -- inferred equivalent call

	local frame2 = new("Frame", { -- inferred equivalent call
		Size = UDim2.fromOffset(220, 38),
		Position = UDim2.fromOffset(200, 34),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		ClipsDescendants = true
	}, v6)
	v5.headTicks = {}

	for i = 1, 14 do
		local tick = line(frame2, 2, 8)
		tick.AnchorPoint = Vector2.new(0.5, 1)
		local label = text(frame2, "", 18, UDim2.fromOffset(0, 0), Vector2.new(0.5, 0))
		v5.headTicks[i] = { tick = tick, label = label }
	end

	local line_2 = line(v6, 3, 10)
	line_2.Position = UDim2.fromOffset(200, 56)
	v5.headBox = new("Frame", { -- inferred equivalent call
		Size = UDim2.fromOffset(62, 28),
		Position = UDim2.fromOffset(200, 76),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = color5,
		BackgroundTransparency = 0.45,
		BorderSizePixel = 0
	}, v6)
	new("UIStroke", { Color = color2, Thickness = 2 }, v5.headBox) -- inferred equivalent call
	v5.headText = text(v5.headBox, "000", 22, UDim2.fromScale(0.5, 0.5))

	local function vtape(p: number, right: boolean)
		local v7 = {
			Size = UDim2.fromOffset(56, 200),
			Position = UDim2.fromOffset(p, 210),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			ClipsDescendants = true
		}
		local frame = Instance.new("Frame")

		local v8 = { right = right }

		for k, v9 in v7 do
			frame[k] = v9
		end

		frame.Parent = v6

		local line_2 = line(frame, 2, 200)
		line_2.Position = UDim2.new(right and 0 or 1, right and 1 or -1, 0.5, 0)
		v8.frame = frame
		v8.ticks = {}

		for i = 1, 24 do
			local tick = line(frame, 8, 2)
			tick.AnchorPoint = Vector2.new(right and 0 or 1, 0.5)
			local label = text(frame, "", 17, UDim2.fromOffset(0, 0), Vector2.new(right and 0 or 1, 0.5))
			v8.ticks[i] = { tick = tick, label = label }
		end

		local box = new("Frame", { -- inferred equivalent call
			Size = UDim2.fromOffset(70, 32),
			Position = UDim2.fromOffset(p + (right and 4 or -4), 210),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = color5,
			BackgroundTransparency = 0.3,
			BorderSizePixel = 0,
			ZIndex = 3
		}, v6)
		new("UIStroke", { Color = color2, Thickness = 2 }, box) -- inferred equivalent call
		v8.box = box
		v8.value = text(box, "0", 24, UDim2.fromScale(0.5, 0.5))
		v8.value.ZIndex = 4
		return v8
	end

	v5.speed = vtape(64, false)
	v5.alt = vtape(336, true)
	v5.gText = text(v6, "1.0 G", 20, UDim2.fromOffset(62, 92), Vector2.new(0.5, 1))
	v5.thrText = text(v6, "", 20, UDim2.fromOffset(62, 328), Vector2.new(0.5, 0))
	v5.climbText = text(v6, "", 20, UDim2.fromOffset(338, 92), Vector2.new(0.5, 1))
	v5.gearText = text(v6, "", 20, UDim2.fromOffset(338, 328), Vector2.new(0.5, 0))

	v5.rungs = {}
	local function rung(deg: number)
		local v7 = deg == 0 and 250 or 120
		local v8 = deg == 0 and 60 or 52
		local frame = new( -- inferred equivalent call
			"Frame",
			{
				Size = UDim2.fromOffset(v7, 16),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Visible = false
			},
			v6
		)
		local v9 = (v7 - v8) / 2

		for i = -1, 1, 2 do
			if deg < 0 then
				for j = 0, 2 do
					local v10 = v9 / 5
					local v11 = line(frame, v10, 2)

					v11.Position = UDim2.new(0.5, i * (v8 / 2 + v10 * (j * 2 + 0.5)), 0.5, -j * 2)
					v11.Rotation = -i * 6
				end
			else
				local line_2 = line(frame, v9, deg == 0 and 3 or 2)
				line_2.Position = UDim2.new(0.5, i * (v8 / 2 + v9 / 2), 0.5, 0)
			end

			if deg == 0 then
				continue
			end

			local v10 = line(frame, 2, 7)
			v10.AnchorPoint = Vector2.new(0.5, deg > 0 and 0 or 1)
			v10.Position = UDim2.new(0.5, i * (v7 / 2 - 1), 0.5, 0)
			text(
				frame,
				tostring(((math.abs)(deg))),
				16,
				UDim2.new(0.5, i * (v7 / 2 + 5), 0.5, 0),
				Vector2.new(i < 0 and 1 or 0, 0.5)
			)
		end

		table.insert(v5.rungs, { frame = frame, deg = deg })
	end
	rung(0)

	for _, v7 in v do
		rung(v7)
	end

	local fpm = new( -- inferred equivalent call
		"Frame",
		{
			Size = UDim2.fromOffset(52, 24),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			ZIndex = 2
		},
		v6
	)
	local ring_2 = ring(fpm, 14, 2.5)
	ring_2.Position = UDim2.fromScale(0.5, 0.5)

	for i = -1, 1, 2 do
		local line_3 = line(fpm, 14, 2.5)
		line_3.Position = UDim2.new(0.5, i * 15, 0.5, 0)
	end

	local line_3 = line(fpm, 2.5, 8)
	line_3.Position = UDim2.new(0.5, 0, 0.5, -11)
	v5.fpm = fpm

	local gun = new( -- inferred equivalent call
		"Frame",
		{
			Size = UDim2.fromOffset(30, 30),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			ZIndex = 2
		},
		v6
	)

	for _, v7 in {
		{ 0, -10, 2.5, 8 },
		{ 0, 10, 2.5, 8 },
		{ -10, 0, 8, 2.5 },
		{ 10, 0, 8, 2.5 }
	} do
		local line_4 = line(gun, v7[3], v7[4], color3)
		line_4.Position = UDim2.new(0.5, v7[1], 0.5, v7[2])
	end

	v5.gun = gun

	for _, v7 in v2 do
		local v8 = math.rad(v7)
		local v9 = line(v6, 2, v7 % 30 == 0 and 10 or 6)
		v9.Position = UDim2.fromOffset(math.sin(v8) * 110 + 200, math.cos(v8) * 110 + 260)
		v9.Rotation = -v7
	end

	v5.bankPtr = line(v6, 10, 10, color3)
	v5.bankPtr.Rotation = 45

	v5.armText = text(v6, "", 20, UDim2.fromOffset(36, 374), Vector2.new(0, 0.5))
	v5.flrText = text(v6, "", 20, UDim2.fromOffset(364, 374), Vector2.new(1, 0.5))

	local screen = new( -- inferred equivalent call
		"Frame",
		{ Name = "Screen", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 },
		screenGui
	)
	v5.screen = screen

	v5.drop = ring(screen, 34, 2.5)
	v5.drop.Visible = false
	local line_4 = line(v5.drop, 5, 5)
	line_4.Position = UDim2.fromScale(0.5, 0.5)
	v5.fall = line(screen, 2, 10)
	v5.fall.Visible = false

	local plate = new("Frame", { -- inferred equivalent call
		Size = UDim2.fromOffset(0, 40),
		AutomaticSize = Enum.AutomaticSize.X,
		Position = UDim2.fromScale(0.5, 0.7),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = color4,
		BorderSizePixel = 0,
		Visible = false
	}, screen)
	new("UIStroke", { Color = color, Thickness = 3 }, plate) -- inferred equivalent call
	new("UIPadding", { PaddingLeft = UDim.new(0, 18), PaddingRight = UDim.new(0, 18) }, plate) -- inferred equivalent call
	v5.plateText = new("TextLabel", { -- inferred equivalent call
		BackgroundTransparency = 1,
		FontFace = rbxassetfontsfamiliesOswaldjson,
		TextSize = 26,
		TextColor3 = color,
		Text = "",
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromScale(0, 1)
	}, plate)
	v5.plate = plate

	local card = new("Frame", { -- inferred equivalent call
		Size = UDim2.fromOffset(176, 102),
		Position = UDim2.new(1, -24, 0.56, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = color5,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0
	}, screen)
	new("UIStroke", { Color = color, Thickness = 2 }, card) -- inferred equivalent call
	new("UICorner", { CornerRadius = UDim.new(0, 4) }, card) -- inferred equivalent call
	v5.rows = {}

	for k, text2 in { "GUN", "BOMB", "FLARES" } do
		local v7 = 8 + (k - 1) * 30
		local sel = new("Frame", { -- inferred equivalent call
			Size = UDim2.new(1, -12, 0, 26),
			Position = UDim2.fromOffset(6, v7),
			BackgroundColor3 = color3,
			BorderSizePixel = 0,
			Visible = false
		}, card)
		new("UICorner", { CornerRadius = UDim.new(0, 3) }, sel) -- inferred equivalent call
		local name = new("TextLabel", { -- inferred equivalent call
			BackgroundTransparency = 1,
			FontFace = rbxassetfontsfamiliesOswaldjson,
			TextSize = 18,
			TextColor3 = color2,
			Text = text2,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(0, 70, 0, 26),
			Position = UDim2.fromOffset(14, v7),
			ZIndex = 2
		}, card)
		local textLabel = new("TextLabel", { -- inferred equivalent call
			BackgroundTransparency = 1,
			FontFace = rbxassetfontsfamiliesOswaldjson,
			TextSize = 18,
			TextColor3 = color2,
			Text = "",
			TextXAlignment = Enum.TextXAlignment.Right,
			Size = UDim2.new(0, 80, 0, 26),
			Position = UDim2.fromOffset(82, v7),
			ZIndex = 2
		}, card)
		v5.rows[text2] = { sel = sel, name = name, value = textLabel }
	end

	v5.card = card
	v5.keys = new("TextLabel", { -- inferred equivalent call
		BackgroundTransparency = 1,
		FontFace = rbxassetfontsfamiliesOswaldjson,
		TextSize = 14,
		TextColor3 = color2,
		TextStrokeTransparency = 0.5,
		Text = "",
		Size = UDim2.new(1, 0, 0, 18),
		Position = UDim2.fromOffset(0, 8)
	}, screen)
	return v5
end

local function setText(state, text2: string, color7: Color3?) -- 11 equivalent calls inferred from this helper
	if state.Text ~= text2 then
		state.Text = text2
	end

	local textColor = color7 or color2

	if state.TextColor3 ~= textColor then
		state.TextColor3 = textColor
	end
end

local function drawTape(p, p2: number, p3: number, p4: number, p5: number)
	local v4 = math.floor((p2 - 100 / p3) / p4) * p4

	for k, tick in p.ticks do
		local v5 = v4 + (k - 1) * p4
		local v6 = 100 - (v5 - p2) * p3
		local visible

		if v6 >= -4 and v6 <= 204 then
			visible = v5 >= 0
		else
			visible = false
		end

		tick.tick.Visible = visible
		tick.label.Visible = visible and v5 % p5 == 0

		if not visible then
			continue
		end

		local v7 = p.right and 2 or 54
		tick.tick.Position = UDim2.fromOffset(v7, v6)
		tick.tick.Size = UDim2.fromOffset(v5 % p5 == 0 and 12 or 6, 2)

		if v5 % p5 ~= 0 then
			continue
		end

		tick.label.Position = UDim2.fromOffset(p.right and 18 or 38, v6)
		local text2 = tostring(v5)

		if tick.label.Text ~= text2 then
			tick.label.Text = text2
		end
	end
end

function JetHud.update(data)
	local v4 = v3

	if not v4 then
		v4 = build()
		v3 = v4
	end

	if v4.gui.Parent == nil then
		v4.gui.Parent = JetHud.parent or Players.LocalPlayer:WaitForChild("PlayerGui")
	end

	v4.gui.Enabled = true
	local cam = data.cam
	local _viewportSize = cam.ViewportSize
	local now = data.now

	local v5 = 0
	local v6 = 0
	local scale = 1
	local flag

	if data.cockpit and data.glass and not data.wrecked then
		local minX = 1e999
		local maxX = -1e999
		local minY = 1e999
		local maxY = -1e999
		flag = true

		for _, v7 in data.glass do
			local worldToViewportPoint = cam:WorldToViewportPoint(v7)

			if worldToViewportPoint.Z <= 0 then
				flag = false
				break
			end

			minX = math.min(minX, worldToViewportPoint.X)
			maxX = math.max(maxX, worldToViewportPoint.X)
			minY = math.min(minY, worldToViewportPoint.Y)
			maxY = math.max(maxY, worldToViewportPoint.Y)
		end

		if flag then
			v5 = (minX + maxX) / 2
			v6 = (minY + maxY) / 2
			scale = (maxY - minY) / 400
			flag = scale > 0.2
		end
	else
		flag = false
	end

	v4.glass.Visible = flag
	local function toGlass(vector3: Vector3)
		local worldToViewportPoint = cam:WorldToViewportPoint(vector3)
		local vector2 = Vector2.new(worldToViewportPoint.X, worldToViewportPoint.Y)

		if worldToViewportPoint.Z <= 0 then
			return nil, vector2
		end

		return
			Vector2.new(200 + (worldToViewportPoint.X - v5) / scale, 200 + (worldToViewportPoint.Y - v6) / scale),
			vector2
	end

	local function inside(vector2: Vector2?): boolean -- 3 equivalent calls inferred from this helper
		return vector2 ~= nil and vector2.X > 36 and vector2.X < 364 and vector2.Y > 96 and vector2.Y < 354
	end

	local v7 = nil

	if flag then
		v4.glass.Position = UDim2.fromOffset(v5, v6)
		v4.scale.Scale = scale
		local v8 = if data.health < 0.35 then color4 else color2

		local heading = data.heading
		local v9 = math.floor((heading - 27.5) / 5) * 5

		for k, headTick in v4.headTicks do
			local v10 = v9 + (k - 1) * 5
			local v11 = 110 + (v10 - heading) * 4
			local v12 = v10 % 360
			local v13 = v12 % 10 == 0
			headTick.tick.Position = UDim2.fromOffset(v11, 34)
			headTick.tick.Size = UDim2.fromOffset(2, v13 and 10 or 5)
			headTick.label.Visible = v13 and v12 % 30 == 0 and true or v13 and v12 % 10 == 0

			if not headTick.label.Visible then
				continue
			end

			headTick.label.Position = UDim2.fromOffset(v11, 0)
			local text2

			if v12 == 0 then
				text2 = "N"
			elseif v12 == 90 then
				text2 = "E"
			elseif v12 == 180 then
				text2 = "S"
			elseif v12 == 270 then
				text2 = "W"
			else
				text2 = string.format("%02d", v12 // 10)
			end

			if headTick.label.Text ~= text2 then
				headTick.label.Text = text2
			end
		end

		local headText = v4.headText
		local text2, v10 = string.format("%03d", math.floor(heading + 0.5) % 360)
		setText(headText, text2, v10) -- inferred equivalent call
		drawTape(v4.speed, data.speed, 1.2, 10, 50)
		drawTape(v4.alt, data.alt, 1.6, 10, 50)
		setText(v4.speed.value, tostring((math.floor(data.speed + 0.5))), color2) -- inferred equivalent call
		local value = v4.alt.value
		local text3 = tostring((math.floor(data.alt + 0.5)))
		local v11

		if data.alt < 15 and not data.ground then
			v11 = color3
		else
			v11 = color2
		end

		setText(value, text3, v11) -- inferred equivalent call
		local gText = v4.gText
		local text4 = string.format("%.1f G", data.g)
		local v12 = if data.g > 6 then color3 else color2
		setText(gText, text4, v12) -- inferred equivalent call
		local thrText = v4.thrText
		local v13

		if data.burn then
			v13 = "AB"
		elseif data.brake then
			v13 = "BRK"
		else
			v13 = "THR " .. math.floor(data.throttle * 100 + 0.5)
		end

		local v14 = if data.burn then color3 else color2
		setText(thrText, v13, v14) -- inferred equivalent call
		local v15 = math.floor(data.climb + 0.5)
		local climbText = v4.climbText
		local v16

		if v15 > 0 then
			v16 = "▲ " .. v15
		else
			v16 = not (v15 < 0) and "" or "▼ " .. -v15
		end

		setText(climbText, v16, color2) -- inferred equivalent call
		setText(v4.gearText, data.gearUp and "" or "WHEELS", color3) -- inferred equivalent call

		local lookVector = data.body.LookVector
		local v17 = Vector3.new(lookVector.X, 0, lookVector.Z)

		if v17.Magnitude < 0.001 then
			v17 = Vector3.new(data.body.UpVector.X, 0, data.body.UpVector.Z) * -math.sign(lookVector.Y)
		end

		local unit = v17.Unit
		local vector3 = Vector3.new(-unit.Z, 0, unit.X)
		local position = cam.CFrame.Position

		for _, rung in v4.rungs do
			local deg = math.rad(rung.deg)
			local v18 = unit * math.cos(deg) + Vector3.new(0, math.sin(deg), 0)
			local v19 = toGlass(position + v18 * 1000)
			local v20 = toGlass(position + (v18 + vector3 * 0.05) * 1000)
			local visible = inside(v19) and v20 ~= nil -- inferred equivalent call
			rung.frame.Visible = visible

			if not (visible and v19 and v20) then
				continue
			end

			rung.frame.Position = UDim2.fromOffset(v19.X, v19.Y)
			rung.frame.Rotation = math.deg((math.atan2(v20.Y - v19.Y, v20.X - v19.X)))
		end

		if data.vel.Magnitude > 5 then
			local v18, v19 = toGlass(position + data.vel.Unit * 1000)
			local fpm = v4.fpm
			fpm.Visible = inside(v18) -- inferred equivalent call

			if v18 then
				v4.fpm.Position = UDim2.fromOffset(v18.X, v18.Y)
				v7 = v19
			end
		else
			v4.fpm.Visible = false
		end

		local v18 = toGlass(data.gunAt)
		local gun = v4.gun
		gun.Visible = not data.noGun and inside(v18) -- inferred equivalent call

		if v18 then
			v4.gun.Position = UDim2.fromOffset(v18.X, v18.Y)
		end

		local v19 = math.rad((math.clamp(-math.deg(data.bank), -45, 45)))
		v4.bankPtr.Position = UDim2.fromOffset(math.sin(v19) * 98 + 200, math.cos(v19) * 98 + 260)

		setText(v4.armText, "BOMB " .. data.bombs, v8) -- inferred equivalent call
		local flrText = v4.flrText
		local text5 = data.flares >= 1 and "FLR RDY" or "FLR " .. math.ceil(data.flareWait)
		local v20 = if data.flares >= 1 then color2 else color6
		setText(flrText, text5, v20) -- inferred equivalent call
	end

	local visible = false

	if data.dropAt then
		local worldToViewportPoint = cam:WorldToViewportPoint(data.dropAt)

		if worldToViewportPoint.Z > 0 then
			visible = true
			v4.drop.Position = UDim2.fromOffset(worldToViewportPoint.X, worldToViewportPoint.Y)

			if v7 then
				local v8 = Vector2.new(worldToViewportPoint.X, worldToViewportPoint.Y) - v7
				local v9 = v8.Magnitude - 30
				v4.fall.Visible = v9 > 10

				if v9 > 10 then
					local v10 = v7 + v8.Unit * (12 + v9 / 2)
					v4.fall.Position = UDim2.fromOffset(v10.X, v10.Y)
					v4.fall.Size = UDim2.fromOffset(2, v9)
					v4.fall.Rotation = math.deg((math.atan2(v8.Y, v8.X))) - 90
				end
			else
				v4.fall.Visible = false
			end
		end
	end

	v4.drop.Visible = visible

	if not visible then
		v4.fall.Visible = false
	end

	local v8 = math.floor(now * 4) % 2 == 0
	local v9 = nil
	local backgroundColor = color4
	local v10 = false

	if data.wrecked then
		v9 = "EJECT"
		v10 = true
	elseif data.out then
		backgroundColor = color3
		v9 = "RETURN TO BATTLEFIELD"
	end

	local plate = v4.plate
	plate.Visible = v9 ~= nil and (not v10 or v8)

	if v9 then
		setText(v4.plateText, v9, color) -- inferred equivalent call
		v4.plate.BackgroundColor3 = backgroundColor
	end

	v4.card.Visible = not data.touch

	if not data.touch then
		local rows = v4.rows
		rows.GUN.value.Text = "∞"
		rows.BOMB.value.Text = data.bombs .. "/" .. data.maxBombs
		rows.FLARES.value.Text = data.flares >= 1 and "RDY" or tostring((math.ceil(data.flareWait))) .. " S"

		for k, row in rows do
			local visible2 = k == "BOMB"
			row.sel.Visible = visible2
			local textColor

			if visible2 then
				textColor = color
			elseif k == "FLARES" and data.flares < 1 then
				textColor = color6
			else
				textColor = color2
			end

			local name = row.name
			local value = row.value
			name.TextColor3 = textColor
			value.TextColor3 = textColor
		end
	end

	setText(v4.keys, data.keys) -- inferred equivalent call
end

function JetHud.hide()
	if v3 then
		v3.gui.Enabled = false
	end
end

return JetHud