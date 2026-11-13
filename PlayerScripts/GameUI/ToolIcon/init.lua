local Art = require(script:WaitForChild("Art"))

local Art2 = require(script:WaitForChild("Art2"))
local ToolIcon = {}

for k, v in Art2 do
	Art[k] = v
end

local color = Color3.fromRGB(16, 16, 19)

local v = { Hammer = true, Shovel = true, BuildHammer = true }

local v2 = {}

local v3 = { Vector3.new(1, 0, 0), Vector3.new(0, 1, 0), Vector3.new(0, 0, 1) }

local function artOf(folder)
	local v4 = v2[folder.Name]

	if v4 then
		return v4
	end

	local handle = folder:FindFirstChild("Handle")
	assert(handle and handle:IsA("BasePart"), "GameUI: tool " .. folder.Name .. " has no Handle")
	local v5 = {}
	local v6 = Art[folder.Name]

	if v6 then
		for _, v7 in v6 do
			local v8 = v7[1]
			local v9 = v7[2]
			local v10 = v7[4]
			table.insert(v5, {
				cf = CFrame.new(table.unpack(v8)),
				size = Vector3.new(v9[1], v9[2], v9[3]),
				shape = Enum.PartType[v7[3]],
				color = Color3.fromRGB(v10[1], v10[2], v10[3])
			})
		end
	else
		for _, part in folder:GetDescendants() do
			if not (part:IsA("BasePart") and part.Transparency < 0.5) then
				continue
			end

			local v7 = {
				cf = handle.CFrame:ToObjectSpace(part.CFrame),
				size = part.Size,
				shape = 0,
				color = 0
			}
			local shape

			if part:IsA("Part") then
				shape = part.Shape
			end

			v7.shape = shape
			v7.color = part.Color
			table.insert(v5, v7)
		end
	end

	local v7 = Vector3.new(1, 1, 1) * 1e999
	local v8 = Vector3.new(-1, -1, -1) * 1e999

	for _, v9 in v5 do
		local halfSize = v9.size / 2

		for _, v10 in { -1, 1 } do
			for _, v11 in { -1, 1 } do
				for _, v12 in { -1, 1 } do
					local v13 = v9.cf * Vector3.new(halfSize.X * v10, halfSize.Y * v11, halfSize.Z * v12)
					v7 = v7:Min(v13)
					v8 = v8:Max(v13)
				end
			end
		end
	end

	assert(#v5 > 0, "GameUI: tool " .. folder.Name .. " has no visible parts to draw")

	local v9 = v8 - v7
	local v10 = { v9.X, v9.Y, v9.Z }
	local v11 = 1

	local v12 = v10[2] < v10[v11] and 2 or v11
	local v13 = v10[3] < v10[v12] and 3 or v12

	local v14 = {}

	if v13 ~= 1 then
		table.insert(v14, 1)
	end

	if v13 ~= 2 then
		table.insert(v14, 2)
	end

	if v13 ~= 3 then
		table.insert(v14, 3)
	end

	local v15 = v14[1]
	local v16 = v14[2]

	if v10[v16] > v10[v15] then
		v16, v15 = v15, v16
	end

	if v15 == 2 then
		v16, v15 = 2, v16
	end

	local v17 = v3[v13]
	local v18

	if v15 == 3 then
		if v[folder.Name] then
			v18 = v3[3]
		else
			v18 = -v3[3]
		end
	else
		v18 = v3[v15]
	end

	local v19 = v3[v16]
	local function flat(vector: Vector3) -- 5 equivalent calls inferred from this helper
		return Vector2.new(vector:Dot(v18), vector:Dot(v19))
	end

	local data = {}
	local min2 = Vector2.one * 1e999
	local max2 = -Vector2.one * 1e999
	local function add(data2)
		table.insert(data, data2)
		local v20 = math.cos(data2.angle)
		local v21 = math.sin(data2.angle)

		for _, v22 in {
			{ -1, -1 },
			{ 1, -1 },
			{ -1, 1 },
			{ 1, 1 }
		} do
			local v23 = v22[1] * data2.w / 2
			local v25 = v22[2] * data2.h / 2
			local v26 = data2.c + Vector2.new(v23 * v20 - v25 * v21, v23 * v21 + v25 * v20)
			local min = min2:Min(v26)
			local max = max2:Max(v26)
			min2 = min
			max2 = max
		end
	end

	local v20 = v24
	local depth = v27

	local function fn(p) -- 5 equivalent calls inferred from this helper
		p.color = v20.color
		p.depth = depth
		add(p)
	end

	for _, v24 in v5 do
		local cf = v24.cf
		local size = v24.size
		local v21 = flat(cf.Position) -- inferred equivalent call

		local midpoint = (math.abs((cf.RightVector:Dot(v17))) * size.X + math.abs((cf.UpVector:Dot(v17))) * size.Y + math.abs((cf.LookVector:Dot(v17))) * size.Z) / 2
		local v27 = cf.Position:Dot(v17) + midpoint

		if v24.shape == Enum.PartType.Ball then
			local v22 = math.min(size.X, size.Y, size.Z)
			fn({ -- inferred equivalent call
				c = v21,
				w = v22,
				h = v22,
				angle = 0,
				round = true
			})
		elseif v24.shape == Enum.PartType.Cylinder then
			local v22 = math.min(size.Y, size.Z)

			if math.abs((cf.RightVector:Dot(v17))) > 0.9 then
				fn({ -- inferred equivalent call
					c = v21,
					w = v22,
					h = v22,
					angle = 0,
					round = true
				})
			else
				local v23 = flat(cf.RightVector * size.X) -- inferred equivalent call
				fn({ -- inferred equivalent call
					c = v21,
					w = math.max(v23.Magnitude, 0.001),
					h = v22,
					angle = math.atan2(v23.Y, v23.X),
					round = false
				})
			end
		else
			local v22 = { cf.RightVector * size.X, cf.UpVector * size.Y, cf.LookVector * size.Z }
			local v23 = -1
			local v25 = 1

			for k, v26 in v22 do
				local v28 = math.abs((v26.Unit:Dot(v17)))

				if not (v23 < v28) then
					continue
				end

				v25 = k
				v23 = v28
			end

			if v23 > 0.95 then
				local v26 = nil
				local v28 = nil

				for k, v29 in v22 do
					if k == v25 then
						continue
					end

					if v26 then
						v28 = v29
					else
						v26 = v29
					end
				end

				local v29 = flat(v26) -- inferred equivalent call
				local v30 = flat(v28) -- inferred equivalent call
				fn({ -- inferred equivalent call
					c = v21,
					w = math.max(v29.Magnitude, 0.001),
					h = math.max(v30.Magnitude, 0.001),
					angle = math.atan2(v29.Y, v29.X),
					round = false
				})
			else
				local v26 = Vector2.one * 1e999
				local v28 = -Vector2.one * 1e999

				for _, v29 in { -0.5, 0.5 } do
					for _, v30 in { -0.5, 0.5 } do
						for _, v31 in { -0.5, 0.5 } do
							local v32 = flat(cf.Position + v22[1] * v29 + v22[2] * v30 + v22[3] * v31) -- inferred equivalent call
							v26 = v26:Min(v32)
							v28 = v28:Max(v32)
						end
					end
				end

				fn({ -- inferred equivalent call
					c = (v26 + v28) / 2,
					w = v28.X - v26.X,
					h = v28.Y - v26.Y,
					angle = 0,
					round = false
				})
			end
		end
	end

	local v21 = {
		shapes = data,
		min = min2,
		max = max2,
		fill = math.clamp(math.max(max2.X - min2.X, max2.Y - min2.Y) / 1.6, 0.6, 1)
	}
	v2[folder.Name] = v21
	return v21
end

ToolIcon.art = artOf

function ToolIcon.artFrom(shapes, value: number?)
	local min = Vector2.one * 1e999
	local max = -Vector2.one * 1e999

	for _, item in shapes do
		local v4 = math.cos(item.angle)
		local v5 = math.sin(item.angle)

		for _, v6 in {
			{ -1, -1 },
			{ 1, -1 },
			{ -1, 1 },
			{ 1, 1 }
		} do
			local v7 = v6[1] * item.w / 2
			local v8 = v6[2] * item.h / 2
			local v9 = item.c + Vector2.new(v7 * v4 - v8 * v5, v7 * v5 + v8 * v4)
			min = min:Min(v9)
			max = max:Max(v9)
		end
	end

	return {
		shapes = shapes,
		min = min,
		max = max,
		fill = value or 1
	}
end

local function local2(vector2: Vector2, data) -- 2 equivalent calls inferred from this helper
	local v4 = vector2 - data.c
	local v5 = math.cos(data.angle)
	local v6 = math.sin(data.angle)
	return v4.X * v5 + v4.Y * v6, -v4.X * v6 + v4.Y * v5
end

local function inside(shape, shape2): boolean
	if shape.round then
		local v4 = shape.w / 2

		if shape2.round then
			return (shape.c - shape2.c).Magnitude + v4 <= shape2.w / 2 + 0.0001
		end

		local v5, v6 = local2(shape.c, shape2) -- inferred equivalent call
		return math.abs(v5) + v4 <= shape2.w / 2 + 0.0001 and math.abs(v6) + v4 <= shape2.h / 2 + 0.0001
	else
		if shape2.round then
			return false
		end

		local v4 = (shape.angle - shape2.angle) / 1.5707963267948966

		if math.abs(v4 - math.round(v4)) > 0.001 then
			return false
		end

		local v5 = math.cos(shape.angle)
		local v6 = math.sin(shape.angle)

		for _, v7 in {
			{ -1, -1 },
			{ 1, -1 },
			{ -1, 1 },
			{ 1, 1 }
		} do
			local v8 = v7[1] * shape.w / 2
			local v9 = v7[2] * shape.h / 2
			local v10, v11 = local2(shape.c + Vector2.new(v8 * v5 - v9 * v6, v8 * v6 + v9 * v5), shape2) -- inferred equivalent call

			if math.abs(v10) > shape2.w / 2 + 0.0001 or math.abs(v11) > shape2.h / 2 + 0.0001 then
				return false
			end
		end

		return true
	end
end

local function visibleShapes(state)
	local drawn = state.drawn

	if drawn then
		return drawn
	end

	local shapes = {}

	for k, shape in state.shapes do
		local v4 = false

		for k2, shape2 in state.shapes do
			if k ~= k2 and inside(shape, shape2) and not (k < k2 and inside(shape2, shape)) then
				v4 = true
				break
			end
		end

		if not v4 then
			table.insert(shapes, shape)
		end
	end

	state.drawn = shapes
	return shapes
end

local function tinted(color2: Color3, color3: Color3) -- 2 equivalent calls inferred from this helper
	if 0.3 * color3.R + 0.59 * color3.G + 0.11 * color3.B < 0.35 then
		return color2
	end

	return Color3.new(color2.R * color3.R, color2.G * color3.G, color2.B * color3.B)
end

local function lift(color2: Color3, p: number) -- 2 equivalent calls inferred from this helper
	local v4 = math.min(p, 1 / math.max(color2.R, color2.G, color2.B, 0.001))
	return Color3.new(color2.R * v4, color2.G * v4, color2.B * v4)
end

local function draw(data, parent, color2: Color3?, flag: boolean?)
	local v4 = data.max - data.min
	local icon = Instance.new("Frame")
	icon.Name = "Icon"
	icon.BackgroundTransparency = 1
	icon.Size = UDim2.fromScale(1, 1)
	local art = Instance.new("Frame")
	art.Name = "Art"
	art.BackgroundTransparency = 1
	art.AnchorPoint = Vector2.new(0.5, 0.5)
	art.Position = UDim2.fromScale(0.5, 0.5)
	art.Size = UDim2.new(data.fill, -3, data.fill, -3)
	art.Parent = icon
	local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uiAspectRatioConstraint.AspectRatio = v4.X / v4.Y
	uiAspectRatioConstraint.AspectType = Enum.AspectType.FitWithinMaxSize
	uiAspectRatioConstraint.Parent = art
	local v5 = {}
	local function piece(data2, p: number, backgroundColor: Color3, zIndex: number)
		local frame = Instance.new("Frame")
		frame.BorderSizePixel = 0
		frame.BackgroundColor3 = backgroundColor
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.fromScale((data2.c.X - data.min.X) / v4.X, (data.max.Y - data2.c.Y) / v4.Y)
		frame.Size = UDim2.new(data2.w / v4.X, p, data2.h / v4.Y, p)
		frame.Rotation = -math.deg(data2.angle)
		frame.ZIndex = zIndex

		if data2.round then
			local uiCorner = Instance.new("UICorner")
			uiCorner.CornerRadius = UDim.new(0.5, 0)
			uiCorner.Parent = frame
		end

		frame.Parent = art
		return frame
	end

	if flag then
		local clones = {}

		for _, shape in data.shapes do
			table.insert(clones, table.clone(shape))
		end

		table.sort(clones, function(a, b): boolean
			local depth = a.depth or 0
			local depth2 = b.depth or 0

			if math.abs(depth - depth2) > 0.001 then
				return depth < depth2
			end

			return a.w * a.h > b.w * b.h
		end)

		for _, v6 in clones do
			v6.round = false
			piece(v6, 3, color, 1)
		end

		local colorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(0.22, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(0.221, Color3.new(1, 1, 1):Lerp(Color3.new(), 0.12280701754385959)),
			ColorSequenceKeypoint.new(0.78, Color3.new(1, 1, 1):Lerp(Color3.new(), 0.12280701754385959)),
			ColorSequenceKeypoint.new(0.781, Color3.new(1, 1, 1):Lerp(Color3.new(), 0.29824561403508765)),
			ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1):Lerp(Color3.new(), 0.29824561403508765))
		})

		local v6 = color2 or Color3.new(1, 1, 1)
		local colors = {}

		for k, v7 in clones do
			local color3 = v7.color or Color3.new(1, 1, 1)
			colors[k] = color3
			color3 = tinted(color3, v6) -- inferred equivalent call
			local parent2 = piece(v7, 0, lift(color3, 1.482), k + 2) -- inferred equivalent call
			local uiGradient = Instance.new("UIGradient")
			uiGradient.Rotation = 90 - parent2.Rotation
			uiGradient.Color = colorSequence
			uiGradient.Parent = parent2
			table.insert(v5, parent2)
		end

		icon.Parent = parent
		local v7 = v6
		return icon, function(color3: Color3)
			if color3 ~= v7 then
				v7 = color3

				for k, v8 in v5 do
					v8.BackgroundColor3 = lift(tinted(colors[k], color3), 1.482) -- inferred equivalent call
				end
			end
		end
	else
		local v6 = visibleShapes(data)

		for _, v7 in v6 do
			piece(v7, 3, color, 1)
		end

		for _, v7 in v6 do
			table.insert(v5, piece(v7, 0, color2 or Color3.new(1, 1, 1), 2))
		end

		icon.Parent = parent
		local v7 = color2
		local function paint(backgroundColor: Color3)
			if backgroundColor ~= v7 then
				v7 = backgroundColor

				for _, v8 in v5 do
					v8.BackgroundColor3 = backgroundColor
				end
			end
		end
		return icon, paint
	end
end

ToolIcon.draw = draw

function ToolIcon.flat(p, parent, color2: Color3?)
	return draw(artOf(p), parent, color2, v[p.Name])
end

function ToolIcon.voxel(p, parent, color2: Color3?, fill: number?)
	local clone = artOf(p)

	if fill then
		clone = table.clone(clone)
		clone.fill = fill
	end

	return draw(clone, parent, color2, true)
end

local Atlas = require(script:WaitForChild("Atlas"))

local function sheetRect(p: string, flag: boolean)
	local tool = Atlas.tools[p]

	if not tool then
		return nil, 1, Atlas.sheet
	end

	local v4 = if flag then tool.c else tool.f
	return v4, tool.fill, tool.sheet or Atlas.sheet
end

function ToolIcon.hasImage(p: string): boolean
	local v4 = v[p] == true
	local tool = Atlas.tools[p]
	local v5

	if tool then
		v5 = if v4 then tool.c else tool.f
		local _fill = tool.fill

		if not tool.sheet then
			local _sheet = Atlas.sheet
		end
	else
		local _sheet = Atlas.sheet
	end

	return v5 ~= nil
end

local function drawImage(list, p: number, sheet: string, parent, color2: Color3?, flag: boolean)
	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.BackgroundTransparency = 1
	icon.BorderSizePixel = 0
	icon.AnchorPoint = Vector2.new(0.5, 0.5)
	icon.Position = UDim2.fromScale(0.5, 0.5)
	icon.Size = UDim2.fromScale(p, p)
	icon.ScaleType = Enum.ScaleType.Fit
	icon.Image = sheet
	icon.ImageRectOffset = Vector2.new(list[1], list[2])
	icon.ImageRectSize = Vector2.new(list[3], list[4])
	local v4 = nil
	local function paint(imageColor: Color3) -- 1 equivalent call inferred from this helper
		if imageColor ~= v4 then
			v4 = imageColor

			local v5 = 0.3 * imageColor.R + 0.59 * imageColor.G + 0.11 * imageColor.B

			if flag and v5 < 0.35 then
				imageColor = Color3.new(1, 1, 1)
			end

			icon.ImageColor3 = imageColor
		end
	end
	paint(color2 or Color3.new(1, 1, 1)) -- inferred equivalent call
	icon.Parent = parent
	return icon, paint
end

function ToolIcon.flatImage(p, parent, color2: Color3?)
	local v4 = v[p.Name] == true
	local name = p.Name
	local tool = Atlas.tools[name]
	local v5, v6, sheet

	if tool then
		v5 = if v4 then tool.c else tool.f
		v6 = tool.fill
		sheet = tool.sheet or Atlas.sheet
	else
		sheet = Atlas.sheet
		v6 = 1
	end

	assert(v5, "GameUI: ToolIcon sheet has no picture of " .. p.Name .. " (re-run toolicon-atlas/atlas_build.py)")
	return drawImage(v5, v6, sheet, parent, color2, v4)
end

function ToolIcon.voxelImage(p, parent, color2: Color3?)
	local name = p.Name
	local tool = Atlas.tools[name]
	local c, v4, sheet

	if tool then
		c = tool.c
		v4 = tool.fill
		sheet = tool.sheet or Atlas.sheet
	else
		sheet = Atlas.sheet
		v4 = 1
	end

	if c then
		return drawImage(c, v4, sheet, parent, color2, true)
	end

	warn("GameUI: ToolIcon sheet has no picture of " .. p.Name .. " (re-run toolicon-atlas/atlas_build.py); drawn with frames")
	return draw(artOf(p), parent, color2, true)
end

function ToolIcon.make(folder, parent, value: number?)
	local handle = folder:FindFirstChild("Handle")
	assert(handle and handle:IsA("BasePart"), "GameUI: tool " .. folder.Name .. " has no Handle")
	local icon = Instance.new("ViewportFrame")
	icon.Name = "Icon"
	icon.BackgroundTransparency = 1
	icon.Ambient = Color3.fromRGB(175, 175, 185)
	icon.LightColor = Color3.new(1, 1, 1)
	icon.LightDirection = Vector3.new(-1, -1.5, -0.5)
	local model = Instance.new("Model")

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		local clone = part:Clone()

		for _, child in clone:GetChildren() do
			if child:IsA("DataModelMesh") or child:IsA("Decal") or child:IsA("SurfaceAppearance") then
				continue
			end

			child:Destroy()
		end

		clone.Anchored = true
		clone.CFrame = handle.CFrame:ToObjectSpace(part.CFrame)
		clone.LocalTransparencyModifier = 0
		clone.Parent = model
	end

	model.Parent = icon

	model.WorldPivot = CFrame.identity

	local _, v4 = model:GetBoundingBox()
	local v5 = { v4.X, v4.Y, v4.Z }
	local v6 = { 1, 2, 3 }
	table.sort(v6, function(a: number, b: number): boolean
		return v5[a] < v5[b]
	end)

	local v7 = v6[1]
	local v8 = v6[2]
	local v9 = v6[3]

	if v9 == 2 then
		v9, v8 = v8, 2
	end

	local v10 = v3[v8]
	local v11

	if v9 == 3 then
		if v[folder.Name] then
			v11 = v3[3]
		else
			v11 = -v3[3]
		end
	else
		v11 = v3[v9]
	end

	local vector = v3[v7]

	if vector:Cross(v10):Dot(-v11) < 0 then
		vector = -vector
	end

	local inverse = CFrame.fromMatrix(Vector3.new(0, 0, 0), vector, v10, -v11):Inverse()

	for _, part in model:GetChildren() do
		if part:IsA("BasePart") then
			part.CFrame = inverse * part.CFrame
		end
	end

	model.WorldPivot = CFrame.identity
	local boundingBox, v12 = model:GetBoundingBox()
	local camera = Instance.new("Camera")
	camera.FieldOfView = value or 22
	local unit = (Vector3.new(1, 0.35, 0.3)).Unit
	camera.CFrame = CFrame.lookAt(boundingBox.Position + unit * v12.Magnitude * 1.9, boundingBox.Position)
	camera.Parent = icon
	icon.CurrentCamera = camera
	icon.Parent = parent
	return icon
end

return ToolIcon