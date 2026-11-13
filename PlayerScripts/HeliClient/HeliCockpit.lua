local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RigidParts = require(ReplicatedStorage.Vehicles.RigidParts)
local VehicleConfig = require(ReplicatedStorage.Vehicles.VehicleConfig)
local HeliModel = require(ReplicatedStorage.Vehicles.HeliModel)

local HeliCockpit = {}

local color = Color3.fromRGB(20, 21, 24)
local color2 = Color3.fromRGB(108, 114, 122)
local color3 = Color3.fromRGB(242, 238, 228)
local color4 = Color3.fromRGB(255, 198, 32)
local color5 = Color3.fromRGB(232, 112, 36)
local color6 = Color3.fromRGB(214, 72, 52)
local color7 = Color3.fromRGB(140, 230, 150)
local color8 = Color3.fromRGB(12, 14, 14)
local color9 = Color3.fromRGB(34, 34, 36)

local color10 = Color3.fromRGB(72, 78, 66)
local color11 = Color3.fromRGB(52, 55, 54)
local color12 = Color3.fromRGB(40, 41, 45)
local color13 = Color3.fromRGB(58, 60, 66)
local color14 = Color3.fromRGB(255, 104, 80)
local color15 = Color3.fromRGB(176, 40, 30)
local rbxassetfontsfamiliesOswaldjson = Font.new("rbxasset://fonts/families/Oswald.json", Enum.FontWeight.Bold)

local park = RigidParts.PARK

local function newKit(name: string)
	local folder = Instance.new("Folder")
	folder.Name = name
	local root = RigidParts.root(folder, "Root")
	local kit = {
		folder = folder,
		movers = { root },
		frames = { park }
	}

	local function make(size: Vector3, color16: Color3, flag: boolean?)
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
		part.Color = color16
		part.Parent = folder
		return part
	end

	function kit.add(size: Vector3, cframe: CFrame, color16: Color3, flag: boolean?)
		local v = make(size, color16, flag)
		RigidParts.weld(root, v, cframe)
		return v
	end

	function kit.bar(vector3: Vector3, vector3_2: Vector3, p: number, color16: Color3)
		return kit.add(
			Vector3.new(p, p, (vector3_2 - vector3).Magnitude),
			CFrame.lookAt((vector3 + vector3_2) / 2, vector3_2),
			color16
		)
	end

	function kit.group(items)
		local v = {
			first = #kit.movers + 1,
			at = {}
		}

		for _, item in items do
			table.insert(kit.movers, make(item[1], item[3], item[4]))
			table.insert(kit.frames, park)
			table.insert(v.at, item[2])
		end

		return v
	end

	function kit.place(p, cframe: CFrame)
		for k, v in p.at do
			kit.frames[p.first + k - 1] = cframe * v
		end
	end
	return kit
end

local function gui(className: string, items, parent) -- 13 equivalent calls inferred from this helper
	local instance = Instance.new(className)

	for k, item in items do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

local function surface(parent)
	local parent2 = gui("SurfaceGui", { -- inferred equivalent call
		Face = Enum.NormalId.Back,
		LightInfluence = 0,
		Brightness = 1.4,
		PixelsPerStud = 300,
		SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud,
		ZOffset = 1
	}, parent)
	return
		gui("Frame", { -- inferred equivalent call
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = color8,
			BorderSizePixel = 0
		}, parent2),
		parent.Size.X * 300,
		parent.Size.Y * 300
end

local function box(parent, p: number, p2: number, p3: number, p4: number, backgroundColor: Color3, color16: Color3?)
	local parent2 = gui("Frame", { -- inferred equivalent call
		Position = UDim2.fromOffset(p, p2),
		Size = UDim2.fromOffset(p3, p4),
		BackgroundColor3 = backgroundColor,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5)
	}, parent)

	if color16 then
		gui("UIStroke", { Color = color16, Thickness = 2 }, parent2) -- inferred equivalent call
	end

	return parent2
end

local function label(parent, text: string, textSize: number, p: number, p2: number, textColor: Color3, vector2: Vector2?)
	return gui("TextLabel", { -- inferred equivalent call
		BackgroundTransparency = 1,
		FontFace = rbxassetfontsfamiliesOswaldjson,
		TextSize = textSize,
		TextColor3 = textColor,
		Text = text,
		AutomaticSize = Enum.AutomaticSize.XY,
		Size = UDim2.fromOffset(0, 0),
		Position = UDim2.fromOffset(p, p2),
		AnchorPoint = vector2 or Vector2.new(0.5, 0.5)
	}, parent)
end

local function meter(parent, p: number, p2: number, p3: number, text: string, color16: Color3, color17: Color3)
	label(parent, text, 20, p, p2, color16, Vector2.new(0, 0.5))
	local parent2 = gui("Frame", { -- inferred equivalent call
		Position = UDim2.fromOffset(p, p2 + 17),
		Size = UDim2.fromOffset(p3, 10),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = color9,
		BorderSizePixel = 0
	}, parent)
	gui("UIStroke", { Color = color, Thickness = 2 }, parent2) -- inferred equivalent call
	return gui("Frame", { -- inferred equivalent call
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = color17,
		BorderSizePixel = 0
	}, parent2)
end

local function attitude(parent, p: number, p2: number, color16: Color3, color17: Color3)
	label(parent, "ATT", 20, 8, 14, color17, Vector2.new(0, 0.5))

	local v = p2 / 60
	local v2 = {}

	for _, deg in { 0, -20, -10, 10, 20 } do
		local v3

		if deg == 0 then
			v3 = p * 0.56
		elseif deg % 20 == 0 then
			v3 = p * 0.3
		else
			v3 = p * 0.18
		end

		local v4 = {
			Size = UDim2.fromOffset(v3, deg == 0 and 4 or 3),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = 0,
			BorderSizePixel = 0
		}
		local backgroundColor

		if deg < 0 then
			backgroundColor = Color3.fromRGB(196, 150, 96)
		else
			backgroundColor = color16
		end

		v4.BackgroundColor3 = backgroundColor
		local frame = gui("Frame", v4, parent) -- inferred equivalent call
		table.insert(v2, { frame = frame, deg = deg })
	end

	box(parent, p / 2 + p * -1 * 0.17, p2 / 2, p * 0.16, 6, color4, color)
	box(parent, p / 2 + p * 1 * 0.17, p2 / 2, p * 0.16, 6, color4, color)

	box(parent, p / 2, p2 / 2, 8, 8, color4, color)
	box(parent, p / 2, p2 - 16, 58, 24, color8, color16)
	local v3 = label(parent, "000", 24, p / 2, p2 - 16, color16)
	return function(p3: number, p4: number, p5: number)
		local v4 = math.sin(p4)
		local v5 = math.cos(p4)

		for _, v6 in v2 do
			local v7 = (math.deg(p3) - v6.deg) * v
			local v8 = v4 * v7
			local v9 = v5 * v7
			local frame = v6.frame
			frame.Visible = math.abs(v8) < p * 0.2 and math.abs(v9) < p2 * 0.36
			v6.frame.Position = UDim2.new(0.5, v8, 0.5, v9)
			v6.frame.Rotation = -math.deg(p4)
		end

		v3.Text = string.format("%03d", math.floor(p5 + 0.5) % 360)
	end
end

local function dial(parent, p: number, color16: Color3)
	local parent2, v, v2 = surface(parent)
	local parent3 = box(parent2, v / 2, v2 / 2, v - 10, v2 - 10, color8)
	gui("UICorner", { CornerRadius = UDim.new(1, 0) }, parent3) -- inferred equivalent call
	gui("UIStroke", { Color = color16, Thickness = 3 }, parent3) -- inferred equivalent call

	local parent4 = gui("Frame", { -- inferred equivalent call
		Size = UDim2.fromOffset(4, v2 - 22),
		Position = UDim2.fromOffset(v / 2, v2 / 2),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1
	}, parent2)
	gui("Frame", { Size = UDim2.fromScale(1, 0.5), BackgroundColor3 = color4, BorderSizePixel = 0 }, parent4) -- inferred equivalent call
	box(parent2, v / 2, v2 / 2, 10, 10, color16)
	return function(p2: number)
		parent4.Rotation = math.clamp(p2 / p, 0, 1) * 270 + -135
	end
end

local function light(p, color16: Color3?) -- 9 equivalent calls inferred from this helper
	local color17 = color16 or color9

	if p.Color ~= color17 then
		p.Color = color17
		local material

		if color16 then
			material = Enum.Material.Neon
		else
			material = Enum.Material.SmoothPlastic
		end

		p.Material = material
	end
end

local function lamp(parent, color16: Color3, brightness: number, range: number) -- 2 equivalent calls inferred from this helper
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = brightness
	pointLight.Range = range
	pointLight.Shadows = false
	pointLight.Color = color16
	pointLight.Parent = parent
end

local function hullColor(p: number, color16: Color3) -- 2 equivalent calls inferred from this helper
	if p < 0.35 then
		return color6
	end

	return if p < 0.7 then color4 else color16
end

local function buildHeli()
	local kit = newKit("HeliCockpit")
	local add = kit.add

	local v = {}
	local v2 = {}
	local v3 = {}

	for k, v4 in { -1, 1 } do
		local v5 = CFrame.new(v4 * 1.2, 4.2, -8.5) * CFrame.Angles(0, -v4 * 0.3, 0) * CFrame.Angles(-0.35, 0, 0)
		add(Vector3.new(1.05, 1, 0.16), v5, color11)
		local parent = add(Vector3.new(1.15, 0.07, 0.46), v5 * CFrame.new(0, 0.535, 0.12), color)
		add(Vector3.new(1.17, 0.09, 0.05), v5 * CFrame.new(0, 0.525, 0.34), color10)

		if k == 1 then
			lamp(parent, Color3.fromRGB(255, 240, 220), 0.6, 3.5) -- inferred equivalent call
		end

		local v6 = k == 1 and 2 or 3

		for i = 1, v6 do
			local v7 = (i - (v6 + 1) / 2) * 0.33
			add(Vector3.new(0.3, 0.11, 0.03), v5 * CFrame.new(v7, 0.435, 0.085), color)
			table.insert(v, add(Vector3.new(0.25, 0.07, 0.03), v5 * CFrame.new(v7, 0.435, 0.1), color9))
		end

		local v7 = -v4 * 0.19
		add(Vector3.new(0.64, 0.54, 0.05), v5 * CFrame.new(v7, 0.05, 0.09), color)
		v2[k] = add(Vector3.new(0.58, 0.48, 0.02), v5 * CFrame.new(v7, 0.05, 0.12), color8)

		for i = 0, 1 do
			local v8 = 0.19 - i * 0.28
			add(Vector3.new(0.27, 0.26, 0.04), v5 * CFrame.new(v4 * 0.34, v8, 0.085), color)
			v3[(k - 1) * 2 + i + 1] = add(Vector3.new(0.22, 0.22, 0.02), v5 * CFrame.new(v4 * 0.34, v8, 0.11), color8)
		end

		for i = 0, 3 do
			local v8 = i * 0.2 + -0.3
			add(Vector3.new(0.13, 0.11, 0.02), v5 * CFrame.new(v8, -0.38, 0.09), color)
			local v9 = v5 * CFrame.new(v8, -0.38, 0.14) * CFrame.Angles((i + k) % 2 == 0 and -0.45 or 0.45, 0, 0)
			local v10 = if k == 2 and i == 3 then color6 else color2
			add(Vector3.new(0.05, 0.05, 0.13), v9, v10)
		end

		add(Vector3.new(0.5, 1, 0.3), CFrame.new(v4 * 1.3, 3.35, -8.9), color10)

		add(Vector3.new(0.5, 0.9, 1.8), CFrame.new(v4 * 1.75, 2.95, -6.1), color10)
		add(Vector3.new(0.44, 0.03, 1.7), CFrame.new(v4 * 1.75, 3.41, -6.1), color11)
		add(Vector3.new(0.38, 0.03, 0.38), CFrame.new(v4 * 1.75, 3.43, -6.1), color)
		local cframe = CFrame.new(v4 * 1.75, 3.45, -6.2)
		local v8 = if v4 < 0 then color7 else color4
		add(Vector3.new(0.24, 0.02, 0.07), cframe, v8, true)

		for _, v9 in { -0.1, 0.1 } do
			add(Vector3.new(0.08, 0.07, 0.08), CFrame.new(v4 * 1.75 + v9, 3.47, -6), color2)
		end

		for i = 0, 2 do
			add(Vector3.new(0.09, 0.04, 0.09), CFrame.new(v4 * 1.75, 3.45, i * 0.14 + -5.65), color2)
		end

		if v4 > 0 then
			add(Vector3.new(0.3, 0.03, 0.28), CFrame.new(1.75, 3.43, -6.65), color4)
			add(Vector3.new(0.11, 0.09, 0.15), CFrame.new(1.75, 3.48, -6.65), color6)
		else
			add(Vector3.new(0.38, 0.03, 0.38), CFrame.new(-1.75, 3.43, -6.65), color)
			add(Vector3.new(0.24, 0.02, 0.07), CFrame.new(-1.75, 3.45, -6.75), color4, true)
		end

		add(Vector3.new(0.06, 0.34, 0.06), CFrame.new(v4 * 0.45, 3.02, -8.5), color2)
	end

	local cframe = CFrame.new(0, 2.6, -6.95)
	add(Vector3.new(0.34, 0.1, 0.34), CFrame.new(0, 2.55, -6.95), color)
	local group = kit.group({
		{ Vector3.new(0.07, 1, 0.07), CFrame.new(0, 0.5, 0), color2 },
		{ Vector3.new(0.15, 0.32, 0.17), CFrame.new(0, 1.1, 0), color },
		{ Vector3.new(0.04, 0.08, 0.05), CFrame.new(0, 1.12, -0.1), color4 },
		{ Vector3.new(0.05, 0.03, 0.05), CFrame.new(0, 1.275, 0.02), color6 }
	})

	local cframe2 = CFrame.new(-1.12, 2.8, -5.1)
	local group2 = kit.group({
		{ Vector3.new(0.07, 0.07, 1), CFrame.new(0, 0, -0.5), color2 },
		{ Vector3.new(0.12, 0.12, 0.34), CFrame.new(0, 0, -0.82), color },
		{ Vector3.new(0.18, 0.14, 0.2), CFrame.new(0, 0.03, -1.1), color11 },
		{ Vector3.new(0.05, 0.04, 0.05), CFrame.new(-0.04, 0.11, -1.12), color4 },
		{ Vector3.new(0.05, 0.04, 0.05), CFrame.new(0.04, 0.11, -1.08), color6 }
	})

	local cframe3 = CFrame.Angles(-0.8, 0, 0)

	local function pedalParts()
		return {
			{ Vector3.new(0.24, 0.28, 0.05), CFrame.identity, color2 },
			{ Vector3.new(0.25, 0.05, 0.07), CFrame.new(0, 0.07, 0), color },
			{ Vector3.new(0.25, 0.05, 0.07), CFrame.new(0, -0.07, 0), color }
		}
	end

	local v4 = { kit.group(pedalParts()), kit.group(pedalParts()) }

	local parent, v5, v6 = surface(v2[1])
	local v7 = attitude(parent, v5, v6, color3, color2)
	local parent2, v8, v9 = surface(v2[2])
	local v10 = meter(parent2, 10, 16, v8 - 20, "HULL", color2, color3)
	local v11 = meter(parent2, 10, 56, v8 - 20, "FLARES", color2, color3)
	label(parent2, "RKT", 20, 10, v9 - 26, color2, Vector2.new(0, 0.5))
	local v12 = label(parent2, "8", 40, v8 - 12, v9 - 28, color3, Vector2.new(1, 0.5))
	local v13 = dial(v3[1], 300, color3)
	local v14 = dial(v3[2], 200, color3)
	local v15 = dial(v3[3], 1, color3)
	local v16 = dial(v3[4], 1, color3)

	local function pose(cframe4: CFrame, data)
		kit.place(group, cframe4 * cframe * CFrame.Angles(0.2 - data.fwd * 0.2, 0, -data.side * 0.2))
		kit.place(group2, cframe4 * cframe2 * CFrame.Angles(data.lift * 0.14 + 0.2, 0, 0))

		for k, v17 in { -1, 1 } do
			kit.place(v4[k], cframe4 * CFrame.new(v17 * 0.45, 3.25, -8.45 - data.turn * 0.12 * v17) * cframe3)
		end

		local v17 = math.floor(data.now * 4) % 2 == 0
		local v18 = v[1]
		local v19

		if data.health < 0.25 then
			if v17 then
				v19 = color4
			end
		elseif data.health < 0.5 then
			v19 = color4
		end

		light(v18, v19) -- inferred equivalent call
		local v20 = v[2]
		local v21

		if data.spin < 0.97 then
			v21 = color4
		end

		light(v20, v21) -- inferred equivalent call
		local v22 = v[3]
		local v23

		if data.locked then
			if v17 then
				v23 = color6
			end
		elseif data.heat > 0.7 then
			v23 = color5
		end

		light(v22, v23) -- inferred equivalent call
		local v24 = v[4]
		local v25

		if data.painted then
			v25 = color4
		end

		light(v24, v25) -- inferred equivalent call
		local v26 = v[5]
		local v27

		if data.inbound and v17 then
			v27 = color6
		end

		light(v26, v27) -- inferred equivalent call
	end
	local function draw(data)
		v7(data.pitch, data.bank, data.heading)
		local v17 = math.clamp(data.health, 0, 1)
		v10.Size = UDim2.fromScale(v17, 1)
		v10.BackgroundColor3 = hullColor(v17, color3) -- inferred equivalent call
		v11.Size = UDim2.fromScale(math.clamp(data.flares, 0, 1), 1)
		local backgroundColor

		if data.flares >= 1 then
			backgroundColor = color3
		else
			backgroundColor = color2
		end

		v11.BackgroundColor3 = backgroundColor
		v12.Text = not (data.rockets > 0) and "LOAD" or tostring(data.rockets)
		local textColor = if data.rockets > 0 then color3 else color4
		v12.TextColor3 = textColor
		v13(data.speed)
		v14(data.alt)
		v15(data.spin)
		v16(data.heat)
	end
	return { kit = kit, pose = pose, screens = draw }
end

local function buildStealth()
	local kit = newKit("StealthCockpit")
	local add = kit.add

	local v = {}
	local v2 = {}

	for k, v3 in { -1, 1 } do
		local v4 = CFrame.new(v3 * 1.2, 4.05, -8.45) * CFrame.Angles(0, -v3 * 0.35, 0) * CFrame.Angles(-0.3, 0, 0)
		add(Vector3.new(1.25, 1, 0.18), v4, color13)
		local parent = add(Vector3.new(1.33, 0.06, 0.42), v4 * CFrame.new(0, 0.53, 0.1), color)
		add(Vector3.new(1.25, 0.025, 0.03), v4 * CFrame.new(0, 0.495, 0.29), color15, true)

		if k == 1 then
			lamp(parent, Color3.fromRGB(255, 120, 96), 0.5, 3) -- inferred equivalent call
		end

		add(Vector3.new(1.07, 0.66, 0.05), v4 * CFrame.new(0, 0.02, 0.1), color)
		v[k] = add(Vector3.new(0.98, 0.58, 0.02), v4 * CFrame.new(0, 0.02, 0.125), color8)

		for i = 0, 1 do
			local v5 = (i - 0.5) * 0.5
			add(Vector3.new(0.36, 0.1, 0.03), v4 * CFrame.new(v5, 0.425, 0.095), color)
			v2[(k - 1) * 2 + i + 1] = add(Vector3.new(0.3, 0.065, 0.03), v4 * CFrame.new(v5, 0.425, 0.11), color9)
		end

		for i = 0, 5 do
			add(Vector3.new(0.11, 0.07, 0.04), v4 * CFrame.new(i * 0.168 + -0.42, -0.4, 0.1), color)
			add(Vector3.new(0.07, 0.02, 0.02), v4 * CFrame.new(i * 0.168 + -0.42, -0.385, 0.125), color15, true)
		end

		add(Vector3.new(0.9, 0.22, 0.3), CFrame.new(v3 * 1.95, 3.8, -8.8), color12)
	end

	local v3 = {}

	for k, v4 in { -1, 1 } do
		local v5 = CFrame.new(v4 * 2, 3.72, -6.3) * CFrame.Angles(0, v4 * 0.185, 0)
		v3[k] = v5
		add(Vector3.new(0.42, 0.14, 3.3), v5, color12)
		add(Vector3.new(0.36, 0.02, 3.1), v5 * CFrame.new(0, 0.075, 0), color13)
		add(Vector3.new(0.025, 0.03, 3.2), v5 * CFrame.new(-v4 * 0.215, 0.06, 0), color15, true)

		for i = 0, 2 do
			for j = 0, 1 do
				local v6 = v5 * CFrame.new((j - 0.5) * 0.14, 0.1, i * 0.15 + 0.7)
				local v7 = if i == 0 and j == 0 then color14 else color
				add(Vector3.new(0.09, 0.04, 0.09), v6, v7, i == 0 and j == 0)
			end
		end

		add(Vector3.new(0.06, 0.4, 0.06), CFrame.new(v4 * 0.5, 2.92, -8.25), color2)
	end

	add(Vector3.new(0.24, 0.08, 0.24), v3[2] * CFrame.new(0, 0.11, -0.5), color)
	add(Vector3.new(0.1, 0.02, 1), v3[1] * CFrame.new(0, 0.09, -0.6), color)

	local group = kit.group({
		{ Vector3.new(0.06, 0.22, 0.06), CFrame.new(0, 0.11, 0), color2 },
		{ Vector3.new(0.13, 0.26, 0.15), CFrame.new(0, 0.33, 0), color },
		{ Vector3.new(0.04, 0.08, 0.04), CFrame.new(0, 0.31, -0.09), color14 },
		{ Vector3.new(0.05, 0.03, 0.05), CFrame.new(0, 0.475, -0.02), color4 }
	})

	local group2 = kit.group({
		{ Vector3.new(0.05, 0.26, 0.05), CFrame.new(0, 0.13, 0), color2 },
		{ Vector3.new(0.15, 0.13, 0.24), CFrame.new(0, 0.3, 0.02), color },
		{ Vector3.new(0.16, 0.035, 0.25), CFrame.new(0, 0.28, 0.02), color15 },
		{ Vector3.new(0.05, 0.04, 0.05), CFrame.new(-0.05, 0.38, -0.05), color4 }
	})

	local cframe = CFrame.Angles(-0.8, 0, 0)
	local function pedalParts()
		return {
			{ Vector3.new(0.24, 0.28, 0.05), CFrame.identity, color2 },
			{ Vector3.new(0.25, 0.05, 0.07), CFrame.new(0, 0.07, 0), color },
			{ Vector3.new(0.25, 0.05, 0.07), CFrame.new(0, -0.07, 0), color }
		}
	end

	local v4 = { kit.group(pedalParts()), kit.group(pedalParts()) }

	local parent, v5, v6 = surface(v[1])
	local v7 = attitude(parent, v5, v6, color14, color2)
	local v8 = label(parent, "0", 34, 10, v6 / 2 - 6, color3, Vector2.new(0, 0.5))
	label(parent, "KM/H", 16, 10, v6 / 2 + 20, color2, Vector2.new(0, 0.5))
	local v9 = label(parent, "0", 34, v5 - 10, v6 / 2 - 6, color3, Vector2.new(1, 0.5))
	label(parent, "M", 16, v5 - 10, v6 / 2 + 20, color2, Vector2.new(1, 0.5))
	local parent2, v10, _ = surface(v[2])
	local v11 = v10 / 2 - 16
	local v12 = meter(parent2, 10, 16, v11, "GUNS", color2, color14)
	local v13 = meter(parent2, 10, 60, v11, "FLARES", color2, color14)
	local v14 = meter(parent2, 10, 104, v11, "HULL", color2, color14)
	local v15 = meter(parent2, 10, 144, v11, "ROTOR", color2, color14)
	label(parent2, "ROCKETS", 20, v10 * 0.75, 16, color2)
	local v16 = label(parent2, "8", 56, v10 * 0.75, 62, color3)
	local v17 = {}

	for i = 1, 8 do
		v17[i] = box(parent2, v10 * 0.75 + ((i - 1) % 4 - 1.5) * 26, (i - 1) // 4 * 26 + 116, 18, 18, color14, color)
	end

	local function pose(cframe2: CFrame, data)
		kit.place(
			group,
			cframe2 * v3[2] * CFrame.new(0, 0.12, -0.5) * CFrame.Angles(-data.fwd * 0.3, 0, -data.side * 0.3)
		)
		kit.place(
			group2,
			cframe2 * v3[1] * CFrame.new(0, 0.09, -0.6 - data.lift * 0.3) * CFrame.Angles(-data.lift * 0.2, 0, 0)
		)

		for k, v18 in { -1, 1 } do
			kit.place(v4[k], cframe2 * CFrame.new(v18 * 0.5, 3.2, -8.2 - data.turn * 0.12 * v18) * cframe)
		end

		local v18 = math.floor(data.now * 4) % 2 == 0
		local v19 = v2[1]
		local v20

		if data.health < 0.25 then
			if v18 then
				v20 = color4
			end
		elseif data.health < 0.5 then
			v20 = color4
		end

		light(v19, v20) -- inferred equivalent call
		local v21 = v2[2]
		local v22

		if data.locked then
			if v18 then
				v22 = color6
			end
		elseif data.heat > 0.7 then
			v22 = color5
		end

		light(v21, v22) -- inferred equivalent call
		local v23 = v2[3]
		local v24

		if data.painted then
			v24 = color4
		end

		light(v23, v24) -- inferred equivalent call
		local v25 = v2[4]
		local v26

		if data.inbound and v18 then
			v26 = color6
		end

		light(v25, v26) -- inferred equivalent call
	end
	local function draw(data)
		v7(data.pitch, data.bank, data.heading)
		v8.Text = tostring((math.floor(data.speed + 0.5)))
		v9.Text = tostring((math.floor(data.alt + 0.5)))
		v12.Size = UDim2.fromScale(math.clamp(data.heat, 0, 1), 1)
		local backgroundColor

		if data.locked then
			backgroundColor = color6
		elseif data.heat > 0.7 then
			backgroundColor = color4
		else
			backgroundColor = color14
		end

		v12.BackgroundColor3 = backgroundColor
		v13.Size = UDim2.fromScale(math.clamp(data.flares, 0, 1), 1)
		local backgroundColor2

		if data.flares >= 1 then
			backgroundColor2 = color14
		else
			backgroundColor2 = color2
		end

		v13.BackgroundColor3 = backgroundColor2
		local v18 = math.clamp(data.health, 0, 1)
		v14.Size = UDim2.fromScale(v18, 1)
		v14.BackgroundColor3 = hullColor(v18, color14) -- inferred equivalent call
		v15.Size = UDim2.fromScale(math.clamp(data.spin, 0, 1), 1)
		local backgroundColor3

		if data.spin < 0.97 then
			backgroundColor3 = color4
		else
			backgroundColor3 = color14
		end

		v15.BackgroundColor3 = backgroundColor3
		v16.Text = not (data.rockets > 0) and "LOAD" or tostring(data.rockets)
		local textColor = if data.rockets > 0 then color3 else color4
		v16.TextColor3 = textColor

		for k, v19 in v17 do
			v19.Visible = k <= data.maxRockets
			local backgroundColor4

			if k <= data.rockets then
				backgroundColor4 = color14
			else
				backgroundColor4 = color9
			end

			v19.BackgroundColor3 = backgroundColor4
		end
	end
	return { kit = kit, pose = pose, screens = draw }
end

local v = {}
local v2 = nil
local v3 = nil
local v4 = {
	at = nil,
	screenAt = 0,
	yaw = 0,
	fwd = 0,
	side = 0,
	lift = 0,
	turn = 0
}

local function park2(p) -- 1 equivalent call inferred from this helper
	local kit = p.kit
	workspace:BulkMoveTo(kit.movers, table.create(#kit.movers, park), Enum.BulkMoveMode.FireCFrameChanged)
end

function HeliCockpit.hide()
	if v2 then
		park2(v2) -- inferred equivalent call
		v2 = nil
	end

	if v3 then
		v3.clearInner(false)
		v3 = nil
	end

	v4.at = nil
end

function HeliCockpit.update(data, speed: number, alt: number, health: number, heat: number, locked: boolean, rockets: number, p: number)
	local v5 = data.def == HeliModel and "heli" or "stealth"
	local v6 = v[v5]

	if not v6 then
		if v5 == "heli" then
			v6 = buildHeli()
		else
			v6 = buildStealth()
		end

		v[v5] = v6
		v6.kit.folder.Parent = workspace
	end

	if v2 ~= v6 or v3 ~= data.rig then
		HeliCockpit.hide()
		local rig = data.rig
		v2 = v6
		v3 = rig
		data.rig.clearInner(true)
	end

	local cf = data.cf
	local lookVector = cf.LookVector
	local yaw = math.atan2(lookVector.X, -lookVector.Z)
	local v7 = math.clamp(p - (v4.at or p), 1 / 240, 0.1)
	local v8 = not v4.at and 0 or ((yaw - v4.yaw + 3.141592653589793) % 6.283185307179586 - 3.141592653589793) / v7
	v4.at = p
	v4.yaw = yaw

	local input = data.sim and data.sim.input
	local v9 = 1 - math.exp(v7 * -12)
	v4.fwd += ((not input and 0 or input.fwd) - v4.fwd) * v9
	v4.side += ((not input and 0 or input.side) - v4.side) * v9
	v4.lift += ((not input and 0 or input.lift) - v4.lift) * v9
	v4.turn += (math.clamp(v8 / 1.5, -1, 1) - v4.turn) * v9
	local folder = data.folder
	local flareCharge = Players.LocalPlayer and Players.LocalPlayer:GetAttribute("FlareCharge")
	local tuning = data.def.tuning or VehicleConfig.Heli
	local v10 = {
		fwd = v4.fwd,
		side = v4.side,
		lift = v4.lift,
		turn = v4.turn,
		speed = speed,
		alt = alt,
		health = health,
		heat = heat,
		locked = locked,
		rockets = rockets,
		maxRockets = tuning.rockets.count,
		flares = typeof(flareCharge) ~= "NumberRange" and 1 or math.clamp(
			(os.clock() - flareCharge.Min) / math.max(flareCharge.Max - flareCharge.Min, 0.01),
			0,
			1
		),
		spin = data.spin or 1,
		inbound = folder ~= nil and folder:GetAttribute("Inbound") ~= nil,
		painted = folder ~= nil and folder:GetAttribute("Painted") == true,
		pitch = math.asin((math.clamp(lookVector.Y, -1, 1))),
		bank = math.atan2(-cf.RightVector.Y, cf.UpVector.Y),
		heading = math.deg(yaw) % 360,
		now = p
	}

	v6.pose(cf, v10)
	v6.kit.frames[1] = cf
	workspace:BulkMoveTo(v6.kit.movers, v6.kit.frames, Enum.BulkMoveMode.FireCFrameChanged)

	if v4.screenAt <= p then
		v4.screenAt = p + 1 / 15
		v6.screens(v10)
	end
end

return HeliCockpit