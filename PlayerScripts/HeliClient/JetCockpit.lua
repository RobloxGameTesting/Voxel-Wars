local color = Color3.fromRGB(20, 21, 24)
local color2 = Color3.fromRGB(80, 84, 91)
local color3 = Color3.fromRGB(100, 105, 113)
local color4 = Color3.fromRGB(108, 114, 122)
local color5 = Color3.fromRGB(242, 238, 228)
local color6 = Color3.fromRGB(255, 198, 32)
local color7 = Color3.fromRGB(232, 112, 36)
local color8 = Color3.fromRGB(214, 72, 52)
local color9 = Color3.fromRGB(140, 230, 150)
local color10 = Color3.fromRGB(12, 14, 14)
local color11 = Color3.fromRGB(170, 215, 205)
local color12 = Color3.fromRGB(34, 34, 36)
local rbxassetfontsfamiliesOswaldjson = Font.new("rbxasset://fonts/families/Oswald.json", Enum.FontWeight.Bold)

local at = CFrame.new(0, 5.85, -10.62) * CFrame.Angles(0.2, 0, 0)
local v = CFrame.new(0, 6.99, -10.55) * CFrame.Angles(0.12, 0, 0)
local vector2 = Vector2.new(1.1, 1)
local cframe = CFrame.new(-0.95, 5.88, -9.15)
local cframe2 = CFrame.new(0.97, 5.98, -9)
local v2 = at * CFrame.new(-0.95, -0.36, 0.1)
local v3 = { -0.78, 0, 0.78 }

local v4 = nil

local function newPart(jetCockpit, size: Vector3, color13: Color3, flag: boolean?)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	local material

	if flag then
		material = Enum.Material.Neon
	else
		material = Enum.Material.SmoothPlastic
	end

	part.Material = material
	local smooth = Enum.SurfaceType.Smooth
	local smooth2 = Enum.SurfaceType.Smooth
	part.TopSurface = smooth
	part.BottomSurface = smooth2
	part.Size = size
	part.Color = color13
	part.Parent = jetCockpit
	return part
end

local function gui(className: string, items, parent) -- 14 equivalent calls inferred from this helper
	local instance = Instance.new(className)

	for k, item in items do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

local function box(parent, position: UDim2, size: UDim2, backgroundColor: Color3, color13: Color3?) -- 1 equivalent call inferred from this helper
	local parent2 = gui("Frame", { -- inferred equivalent call
		Position = position,
		Size = size,
		BackgroundColor3 = backgroundColor,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5)
	}, parent)

	if color13 then
		gui("UIStroke", { Color = color13, Thickness = 3 }, parent2) -- inferred equivalent call
	end

	return parent2
end

local function label(parent, text: string, textSize: number, position: UDim2, vector2_2: Vector2?, color13: Color3?)
	return gui("TextLabel", { -- inferred equivalent call
		BackgroundTransparency = 1,
		FontFace = rbxassetfontsfamiliesOswaldjson,
		TextSize = textSize,
		TextColor3 = color13 or color5,
		Text = text,
		AutomaticSize = Enum.AutomaticSize.XY,
		Size = UDim2.fromOffset(0, 0),
		Position = position,
		AnchorPoint = vector2_2 or Vector2.new(0.5, 0.5)
	}, parent)
end

local function screens(state, list)
	local parent = gui("SurfaceGui", { -- inferred equivalent call
		Face = Enum.NormalId.Back,
		LightInfluence = 0,
		Brightness = 1.4,
		PixelsPerStud = 400,
		SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud,
		ZOffset = 1
	}, list[1])
	local parent2 = gui( -- inferred equivalent call
		"Frame",
		{ Size = UDim2.fromScale(1, 1), BackgroundColor3 = color10, BorderSizePixel = 0 },
		parent
	)
	label(parent2, "STORES", 26, UDim2.new(0.5, 0, 0, 18), nil, color4)
	local v5 = {
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(16, 120),
		BackgroundColor3 = color4,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5)
	}
	local frame = Instance.new("Frame")

	for k, v6 in v5 do
		frame[k] = v6
	end

	frame.Parent = parent2

	local v6 = {
		Position = UDim2.fromScale(0.5, 0.56),
		Size = UDim2.fromOffset(170, 10),
		BackgroundColor3 = color4,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5)
	}
	local frame2 = Instance.new("Frame")

	for k, v7 in v6 do
		frame2[k] = v7
	end

	frame2.Parent = parent2

	frame2.BackgroundTransparency = 0.2
	local v7 = {
		Position = UDim2.fromScale(0.5, 0.74),
		Size = UDim2.fromOffset(70, 8),
		BackgroundColor3 = color4,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5)
	}
	local frame3 = Instance.new("Frame")

	for k, v8 in v7 do
		frame3[k] = v8
	end

	frame3.Parent = parent2

	state.bombs = {}

	for k, v8 in {
		{ -0.075, 0.6 },
		{ 0.075, 0.6 },
		{ -0.075, 0.68 },
		{ 0.075, 0.68 }
	} do
		state.bombs[k] = box(parent2, UDim2.fromScale(0.5 + v8[1], v8[2]), UDim2.fromOffset(20, 20), color12, color)
	end

	label(parent2, "GUN", 26, UDim2.fromScale(0.5, 0.2), nil, color5)
	state.mode = label(parent2, "BOMB", 30, UDim2.new(0.5, 0, 1, -22), nil, color)
	state.modePlate = box(parent2, UDim2.new(0.5, 0, 1, -22), UDim2.fromOffset(110, 32), color6) -- inferred equivalent call
	state.modePlate.ZIndex = 0
	state.mode.ZIndex = 2

	local parent3 = gui("SurfaceGui", { -- inferred equivalent call
		Face = Enum.NormalId.Back,
		LightInfluence = 0,
		Brightness = 1.4,
		PixelsPerStud = 400,
		SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud,
		ZOffset = 1
	}, list[2])
	local parent4 = gui( -- inferred equivalent call
		"Frame",
		{ Size = UDim2.fromScale(1, 1), BackgroundColor3 = color10, BorderSizePixel = 0 },
		parent3
	)
	label(parent4, "ATT", 24, UDim2.new(0, 24, 0, 16), nil, color4)
	state.adi = {}

	for _, deg in { 0, -20, -10, 10, 20 } do
		local v8 = {
			Size = UDim2.fromOffset(deg == 0 and 150 or deg % 20 == 0 and 70 or 40, deg == 0 and 4 or 3),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = 0,
			BorderSizePixel = 0
		}
		local backgroundColor

		if deg < 0 then
			backgroundColor = Color3.fromRGB(196, 150, 96)
		else
			backgroundColor = color5
		end

		v8.BackgroundColor3 = backgroundColor
		local frame4 = gui("Frame", v8, parent4) -- inferred equivalent call
		table.insert(state.adi, { frame = frame4, deg = deg })
	end

	for i = -1, 1, 2 do
		box(parent4, UDim2.new(0.5, i * 42, 0.5, 0), UDim2.fromOffset(52, 8), color6, color)
	end

	box(parent4, UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(10, 10), color6, color)
	state.heading = label(parent4, "000", 30, UDim2.new(0.5, 0, 1, -20), nil, color5)
	state.headingPlate = box(parent4, UDim2.new(0.5, 0, 1, -20), UDim2.fromOffset(66, 30), color10, color5)
	state.headingPlate.ZIndex = 0
	state.heading.ZIndex = 2

	local parent5 = gui("SurfaceGui", { -- inferred equivalent call
		Face = Enum.NormalId.Back,
		LightInfluence = 0,
		Brightness = 1.4,
		PixelsPerStud = 400,
		SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud,
		ZOffset = 1
	}, list[3])
	local frame4 = gui( -- inferred equivalent call
		"Frame",
		{ Size = UDim2.fromScale(1, 1), BackgroundColor3 = color10, BorderSizePixel = 0 },
		parent5
	)
	label(frame4, "THR", 24, UDim2.new(0, 34, 0, 18), nil, color4)
	local parent6 = box(frame4, UDim2.new(0, 34, 0.53, 0), UDim2.fromOffset(28, 150), color12, color)
	box(parent6, UDim2.new(0.5, 0, 0, 12), UDim2.new(1, 0, 0, 24), Color3.fromRGB(110, 84, 20))
	state.thr = gui("Frame", { -- inferred equivalent call
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.fromScale(1, 0),
		BackgroundColor3 = color5,
		BorderSizePixel = 0
	}, parent6)
	state.thrText = label(frame4, "0", 24, UDim2.new(0, 34, 1, -14), nil, color5)
	local function meter(p: number, text: string)
		label(frame4, text, 24, UDim2.new(0, 72, 0, p), Vector2.new(0, 0.5), color4)
		local parent7 = gui("Frame", { -- inferred equivalent call
			Position = UDim2.new(0, 72, 0, p + 22),
			Size = UDim2.fromOffset(150, 12),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = color12,
			BorderSizePixel = 0
		}, frame4)
		gui("UIStroke", { Color = color, Thickness = 2 }, parent7) -- inferred equivalent call
		return gui("Frame", { -- inferred equivalent call
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = color5,
			BorderSizePixel = 0
		}, parent7)
	end

	state.hull = meter(24, "HULL")
	state.flr = meter(78, "FLARES")
	label(frame4, "WHEELS", 24, UDim2.new(0, 72, 0, 140), Vector2.new(0, 0.5), color4)
	state.gearLights = {}

	for i = 1, 3 do
		local gearLights = state.gearLights
		gearLights[i] = box(frame4, UDim2.new(0, (i - 1) * 30 + 84, 0, 172), UDim2.fromOffset(20, 20), color12, color)
	end

	state.g = label(frame4, "1.0 G", 28, UDim2.new(0, 72, 1, -18), Vector2.new(0, 0.5), color5)
end

local function build()
	local jetCockpit = Instance.new("Folder")
	jetCockpit.Name = "JetCockpit"
	local pieces = {}
	local function add(size: Vector3, at2: CFrame, color13: Color3, flag: boolean?) -- 16 equivalent calls inferred from this helper
		local part = newPart(jetCockpit, size, color13, flag)
		table.insert(pieces, { part = part, at = at2 })
		return part
	end

	local v5 = { folder = jetCockpit, pieces = pieces }

	local cframe3 = CFrame.new(0, 6.33, -11)
	table.insert(pieces, {
		part = newPart(jetCockpit, Vector3.new(2.5, 0.24, 1.1), color2, nil),
		at = cframe3
	})

	local cframe4 = CFrame.new(0, 6.41, -10.45)
	table.insert(pieces, {
		part = newPart(jetCockpit, Vector3.new(2.52, 0.1, 0.08), color, nil),
		at = cframe4
	})

	local cframe5 = CFrame.new(-0.95, 6.53, -10.62)
	table.insert(pieces, {
		part = newPart(jetCockpit, Vector3.new(0.44, 0.16, 0.16), color, nil),
		at = cframe5
	})

	local cframe6 = CFrame.new(0.95, 6.53, -10.62)
	table.insert(pieces, {
		part = newPart(jetCockpit, Vector3.new(0.44, 0.16, 0.16), color, nil),
		at = cframe6
	})

	v5.caution = add(Vector3.new(0.38, 0.1, 0.02), CFrame.new(-0.95, 6.53, -10.535), color12) -- inferred equivalent call
	v5.burnLight = add(Vector3.new(0.13, 0.1, 0.02), CFrame.new(0.83, 6.53, -10.535), color12) -- inferred equivalent call
	v5.warn = add(Vector3.new(0.21, 0.1, 0.02), CFrame.new(1.04, 6.53, -10.535), color12) -- inferred equivalent call

	local cframe7 = CFrame.new(0, 6.48, -10.62)
	table.insert(pieces, {
		part = newPart(jetCockpit, Vector3.new(1.36, 0.08, 0.34), color, nil),
		at = cframe7
	})

	for i = -1, 1, 2 do
		local at2 = v * CFrame.new(i * 0.6, 0, 0)
		table.insert(pieces, {
			part = newPart(jetCockpit, Vector3.new(0.1, 1.06, 0.1), color, nil),
			at = at2
		})

		local at3 = v * CFrame.new(i * 0.6, -0.12, 0.01)
		table.insert(pieces, {
			part = newPart(jetCockpit, Vector3.new(0.04, 0.62, 0.11), color6, nil),
			at = at3
		})
	end

	local at2 = v * CFrame.new(0, 0.53, 0)
	table.insert(pieces, {
		part = newPart(jetCockpit, Vector3.new(1.3, 0.09, 0.1), color, nil),
		at = at2
	})

	local v6 = add(Vector3.new(vector2.X, vector2.Y, 0.02), v, color11) -- inferred equivalent call
	v6.Transparency = 0.88

	local pointLight = Instance.new("PointLight")
	local color13 = Color3.fromRGB(255, 240, 220)
	pointLight.Brightness = 0.7
	pointLight.Range = 2.6
	pointLight.Shadows = false
	pointLight.Color = color13
	pointLight.Parent = v6
	table.insert(pieces, {
		part = newPart(jetCockpit, Vector3.new(2.4, 1, 0.14), color3, nil),
		at = at
	})

	local v7 = {}

	for k, v8 in v3 do
		local at3 = at * CFrame.new(v8, 0.12, 0.09)
		table.insert(pieces, {
			part = newPart(jetCockpit, Vector3.new(0.7, 0.66, 0.06), color, nil),
			at = at3
		})

		v7[k] = add(Vector3.new(0.58, 0.54, 0.02), at * CFrame.new(v8, 0.12, 0.125), color10) -- inferred equivalent call

		for _, v9 in { -0.21, -0.07, 0.07, 0.21 } do
			for _, v10 in { -0.3, 0.3 } do
				local at4 = at * CFrame.new(v8 + v9, 0.12 + v10, 0.13)
				table.insert(pieces, {
					part = newPart(jetCockpit, Vector3.new(0.08, 0.04, 0.05), color4, nil),
					at = at4
				})
			end
		end
	end

	for i = -3, 3 do
		if i == -3 then
			continue
		end

		local at3 = at * CFrame.new(i * 0.24, -0.38, 0.13) * CFrame.Angles(-0.4, 0, 0)
		table.insert(pieces, {
			part = newPart(jetCockpit, Vector3.new(0.06, 0.06, 0.14), color4, nil),
			at = at3
		})

		local at4 = at * CFrame.new(i * 0.24, -0.38, 0.09)
		table.insert(pieces, {
			part = newPart(jetCockpit, Vector3.new(0.14, 0.1, 0.02), color, nil),
			at = at4
		})
	end

	local at3 = v2 * CFrame.new(0, 0, -0.02)
	table.insert(pieces, {
		part = newPart(jetCockpit, Vector3.new(0.1, 0.26, 0.03), color, nil),
		at = at3
	})

	v5.gearLever = add(Vector3.new(0.05, 0.05, 0.16), v2, color4) -- inferred equivalent call
	v5.gearKnob = add(Vector3.new(0.14, 0.14, 0.06), v2, color5) -- inferred equivalent call
	v5.gearLight = add(Vector3.new(0.07, 0.07, 0.03), v2 * CFrame.new(0.14, 0.12, 0), color12) -- inferred equivalent call

	for i = -1, 1, 2 do
		local cframe8 = CFrame.new(i * 1.27, 6.32, -8.3)
		table.insert(pieces, {
			part = newPart(jetCockpit, Vector3.new(0.16, 0.26, 3.9), color2, nil),
			at = cframe8
		})

		local cframe9 = CFrame.new(i * 1.27, 6.47, -8.3)
		table.insert(pieces, {
			part = newPart(jetCockpit, Vector3.new(0.18, 0.04, 3.9), color4, nil),
			at = cframe9
		})

		local cframe10 = CFrame.new(i * 0.98, 5.7, -8.35)
		table.insert(pieces, {
			part = newPart(jetCockpit, Vector3.new(0.48, 0.3, 3.5), color2, nil),
			at = cframe10
		})

		local cframe11 = CFrame.new(i * 0.98, 5.865, -8.35)
		table.insert(pieces, {
			part = newPart(jetCockpit, Vector3.new(0.44, 0.03, 3.3), color3, nil),
			at = cframe11
		})

		local cframe12 = CFrame.new(i * 0.86, 5.9, -7.2)
		table.insert(pieces, {
			part = newPart(jetCockpit, Vector3.new(0.08, 0.05, 0.08), color4, nil),
			at = cframe12
		})

		local cframe13 = CFrame.new(i * 0.98, 5.9, -6.95)
		table.insert(pieces, {
			part = newPart(jetCockpit, Vector3.new(0.08, 0.05, 0.08), color4, nil),
			at = cframe13
		})

		local cframe14 = CFrame.new(i * 0.86, 5.9, -6.7)
		table.insert(pieces, {
			part = newPart(jetCockpit, Vector3.new(0.08, 0.05, 0.08), color4, nil),
			at = cframe14
		})
	end

	local cframe8 = CFrame.new(-0.95, 5.885, -9.15)
	table.insert(pieces, {
		part = newPart(jetCockpit, Vector3.new(0.12, 0.02, 1.3), color, nil),
		at = cframe8
	})

	local v8 = add(Vector3.new(0.06, 0.3, 0.06), CFrame.identity, color4) -- inferred equivalent call
	local v9 = add(Vector3.new(0.16, 0.14, 0.24), CFrame.identity, color7) -- inferred equivalent call
	local v10 = add(Vector3.new(0.17, 0.045, 0.25), CFrame.identity, color) -- inferred equivalent call
	local v11 = add(Vector3.new(0.05, 0.04, 0.05), CFrame.identity, color6) -- inferred equivalent call
	v5.throttle = { v8, v9, v10, v11 }

	v5.throttleAt = {
		CFrame.new(0, 0.15, 0),
		CFrame.new(0, 0.34, 0.02),
		CFrame.new(0, 0.31, 0.02),
		CFrame.new(0.06, 0.43, -0.06)
	}

	local at4 = cframe2 * CFrame.new(0, -0.04, 0)
	table.insert(pieces, {
		part = newPart(jetCockpit, Vector3.new(0.26, 0.1, 0.26), color, nil),
		at = at4
	})

	local v12 = add(Vector3.new(0.07, 0.28, 0.07), CFrame.identity, color4) -- inferred equivalent call
	local v13 = add(Vector3.new(0.14, 0.26, 0.16), CFrame.identity, color) -- inferred equivalent call
	local v14 = add(Vector3.new(0.04, 0.08, 0.04), CFrame.identity, color6) -- inferred equivalent call
	local v15 = add(Vector3.new(0.05, 0.03, 0.05), CFrame.identity, color8) -- inferred equivalent call
	v5.stick = { v12, v13, v14, v15 }

	v5.stickAt = {
		CFrame.new(0, 0.14, 0),
		CFrame.new(0, 0.38, 0),
		CFrame.new(0, 0.36, -0.1),
		CFrame.new(0, 0.525, -0.03)
	}

	local cframe9 = CFrame.new(0, 6.95, -7)
	table.insert(pieces, {
		part = newPart(jetCockpit, Vector3.new(0.9, 0.55, 0.3), color2, nil),
		at = cframe9
	})

	for _, v16 in { 6.8, 7 } do
		local cframe10 = CFrame.new(0, v16, -7)
		table.insert(pieces, {
			part = newPart(jetCockpit, Vector3.new(0.92, 0.06, 0.31), color6, nil),
			at = cframe10
		})
	end

	local cframe10 = CFrame.new(0, 7.27, -7.12)
	table.insert(pieces, {
		part = newPart(jetCockpit, Vector3.new(0.5, 0.06, 0.06), color6, nil),
		at = cframe10
	})

	local cframe11 = CFrame.new(0, 5.45, -9.3)
	table.insert(pieces, {
		part = newPart(jetCockpit, Vector3.new(0.34, 0.06, 0.06), color6, nil),
		at = cframe11
	})

	local cframe12 = CFrame.new(-0.15, 5.38, -9.3)
	table.insert(pieces, {
		part = newPart(jetCockpit, Vector3.new(0.05, 0.14, 0.05), color, nil),
		at = cframe12
	})

	local cframe13 = CFrame.new(0.15, 5.38, -9.3)
	table.insert(pieces, {
		part = newPart(jetCockpit, Vector3.new(0.05, 0.14, 0.05), color, nil),
		at = cframe13
	})

	screens(v5, v7)
	v5.glass = v6
	v5.parts = table.create(#pieces)
	v5.frames = table.create(#pieces, CFrame.identity)

	for k, v16 in pieces do
		v5.parts[k] = v16.part
	end

	v5.screenAt = 0
	v5.stickTilt = Vector2.zero
	v5.throttleZ = 0
	return v5
end

local function pieceIndex(p, p2) -- 4 equivalent calls inferred from this helper
	for k, piece in p.pieces do
		if piece.part == p2 then
			return k
		end
	end

	error("[JetCockpit] part not in the cockpit")
end

local function light(p, color13: Color3?) -- 4 equivalent calls inferred from this helper
	local color14 = color13 or color12

	if p.Color ~= color14 then
		p.Color = color14
		local material

		if color13 then
			material = Enum.Material.Neon
		else
			material = Enum.Material.SmoothPlastic
		end

		p.Material = material
	end
end

local JetCockpit = {}

function JetCockpit.update(cframe3: CFrame, data, p: number)
	local v5 = v4

	if not v5 then
		v5 = build()
		v4 = v5
		v5.iThrottle = {}

		for k, v6 in v5.throttle do
			local iThrottle = v5.iThrottle
			iThrottle[k] = pieceIndex(v5, v6) -- inferred equivalent call
		end

		v5.iStick = {}

		for k, v6 in v5.stick do
			local iStick = v5.iStick
			iStick[k] = pieceIndex(v5, v6) -- inferred equivalent call
		end

		local iLever = pieceIndex(v5, v5.gearLever) -- inferred equivalent call
		local iKnob = pieceIndex(v5, v5.gearKnob) -- inferred equivalent call
		v5.iLever = iLever
		v5.iKnob = iKnob
	end

	if v5.folder.Parent ~= workspace then
		v5.folder.Parent = workspace
	end

	local v6 = data.burn and -0.62 or math.clamp(data.throttle, 0, 1) * -0.48
	v5.throttleZ += (v6 - v5.throttleZ) * (1 - math.exp(p * -10))
	local v7 = cframe * CFrame.new(0, 0, 0.55 + v5.throttleZ) * CFrame.Angles(v5.throttleZ * 0.5, 0, 0)

	for k, v8 in v5.iThrottle do
		v5.pieces[v8].at = v7 * v5.throttleAt[k]
	end

	local vector2_2 = Vector2.new(data.side, data.fwd)
	v5.stickTilt = v5.stickTilt:Lerp(vector2_2, 1 - math.exp(p * -14))
	local v8 = cframe2 * CFrame.Angles(-v5.stickTilt.Y * 0.3, 0, -v5.stickTilt.X * 0.3)

	for k, v9 in v5.iStick do
		v5.pieces[v9].at = v8 * v5.stickAt[k]
	end

	local v9 = data.gearUp and 1 or 0
	local v10 = v2 * CFrame.new(0, v9 * 0.16 + -0.08, 0.06)
	v5.pieces[v5.iLever].at = v10 * CFrame.new(0, 0, -0.04)
	v5.pieces[v5.iKnob].at = v10 * CFrame.new(0, 0, 0.06) * CFrame.Angles(0, 0, 0.7853981633974483)
	local v11 = math.abs(data.gearT - v9) > 0.01
	local gearLight = v5.gearLight
	local v12

	if v11 then
		v12 = color8
	end

	light(gearLight, v12) -- inferred equivalent call
	local v13 = math.floor(data.now * 4) % 2 == 0
	local caution = v5.caution
	local v14

	if data.health < 0.25 then
		if v13 then
			v14 = color6
		end
	elseif data.health < 0.5 then
		v14 = color6
	end

	light(caution, v14) -- inferred equivalent call
	local Warn = v5.warn
	local v15

	if data.inbound then
		if v13 then
			v15 = color8
		end
	elseif data.painted then
		v15 = color6
	end

	light(Warn, v15) -- inferred equivalent call
	local burnLight = v5.burnLight
	local v16

	if data.burn then
		v16 = color7
	end

	light(burnLight, v16) -- inferred equivalent call

	for k, piece in v5.pieces do
		v5.frames[k] = cframe3 * piece.at
	end

	workspace:BulkMoveTo(v5.parts, v5.frames, Enum.BulkMoveMode.FireCFrameChanged)

	if data.now >= v5.screenAt then
		v5.screenAt = data.now + 1 / 15

		for k, bomb in v5.bombs do
			local backgroundColor

			if k <= data.bombs then
				backgroundColor = color6
			else
				backgroundColor = color12
			end

			bomb.BackgroundColor3 = backgroundColor
		end

		local v17 = math.sin(data.bank)
		local v18 = math.cos(data.bank)

		for _, v19 in v5.adi do
			local v20 = (math.deg(data.pitch) - v19.deg) * 4

			local v21 = v17 * v20
			local v22 = v18 * v20
			local frame = v19.frame
			frame.Visible = math.abs(v21) < 70 and math.abs(v22) < 80
			v19.frame.Position = UDim2.new(0.5, v21, 0.5, v22)
			v19.frame.Rotation = -math.deg(data.bank)
		end

		v5.heading.Text = string.format("%03d", math.floor(data.heading + 0.5) % 360)
		local v19 = data.burn and 1 or math.clamp(data.throttle, 0, 1) * 0.84
		v5.thr.Size = UDim2.fromScale(1, v19)
		local thr = v5.thr
		local backgroundColor = if data.burn then color7 else color5
		thr.BackgroundColor3 = backgroundColor
		v5.thrText.Text = data.burn and "AB" or tostring((math.floor(data.throttle * 100 + 0.5)))
		local thrText = v5.thrText
		local textColor = if data.burn then color7 else color5
		thrText.TextColor3 = textColor
		local v20 = math.clamp(data.health, 0, 1)
		v5.hull.Size = UDim2.fromScale(v20, 1)
		local hull = v5.hull
		local backgroundColor2

		if v20 < 0.35 then
			backgroundColor2 = color8
		else
			backgroundColor2 = if v20 < 0.7 then color6 else color5
		end

		hull.BackgroundColor3 = backgroundColor2
		v5.flr.Size = UDim2.fromScale(math.clamp(data.flares, 0, 1), 1)
		local flr = v5.flr
		local backgroundColor3

		if data.flares >= 1 then
			backgroundColor3 = color5
		else
			backgroundColor3 = color4
		end

		flr.BackgroundColor3 = backgroundColor3

		for _, gearLight2 in v5.gearLights do
			local backgroundColor4

			if data.gearT <= 0.01 then
				backgroundColor4 = color9
			elseif data.gearT >= 0.99 then
				backgroundColor4 = color12
			else
				backgroundColor4 = color8
			end

			gearLight2.BackgroundColor3 = backgroundColor4
		end

		v5.g.Text = string.format("%.1f G", data.g)
	end
end

function JetCockpit.glassCorners(cframe3: CFrame)
	local cframe4 = cframe3 * v
	local v5 = vector2.X / 2
	local v6 = vector2.Y / 2
	return {
		cframe4:PointToWorldSpace((Vector3.new(-v5, v6, 0))),
		cframe4:PointToWorldSpace((Vector3.new(v5, v6, 0))),
		cframe4:PointToWorldSpace((Vector3.new(v5, -v6, 0))),
		cframe4:PointToWorldSpace((Vector3.new(-v5, -v6, 0)))
	}
end

function JetCockpit.hide()
	if v4 and v4.folder.Parent then
		v4.folder.Parent = nil
	end
end

return JetCockpit