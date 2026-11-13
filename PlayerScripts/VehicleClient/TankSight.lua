local color = Color3.fromRGB(14, 14, 16)

local function new(className: string, items, parent) -- 30 equivalent calls inferred from this helper
	local instance = Instance.new(className)

	for k, item in items do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

return {
	new = function(parent2, data)
		local white = data.white
		local hazard = data.hazard
		local danger = data.danger

		local parent3 = new( -- inferred equivalent call
			"Frame",
			{
				Name = "TankSight",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Visible = false
			},
			parent2
		)

		local function bar(parent, size: UDim2, color2: Color3?)
			local parent4 = new("Frame", { -- inferred equivalent call
				Size = size,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = color2 or white,
				BorderSizePixel = 0
			}, parent)

			new("UIStroke", { Color = data.panel, Transparency = 0.55, Thickness = 1 }, parent4) -- inferred equivalent call
			return parent4
		end

		local function text(parent, text2: string, textSize: number, anchorPoint: Vector2, position: UDim2)
			local parent4 = new("TextLabel", { -- inferred equivalent call
				BackgroundTransparency = 1,
				FontFace = data.font,
				TextSize = textSize,
				TextColor3 = white,
				Text = text2,
				AutomaticSize = Enum.AutomaticSize.XY,
				Size = UDim2.fromOffset(0, 0),
				AnchorPoint = anchorPoint,
				Position = position
			}, parent)

			new("UIStroke", { Color = data.panel, Transparency = 0.45, Thickness = 1.5 }, parent4) -- inferred equivalent call
			return parent4
		end

		local parent = new("ScreenGui", { -- inferred equivalent call
			Name = "TankPeriscope",
			ResetOnSpawn = false,
			IgnoreGuiInset = parent2.IgnoreGuiInset,
			ScreenInsets = parent2.ScreenInsets,
			DisplayOrder = 3
		}, parent2.Parent)
		local parent4 = new("Frame", { -- inferred equivalent call
			Name = "Periscope",
			Size = UDim2.fromScale(0.9, 0.8),
			Position = UDim2.fromScale(0.5, 0.47),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Visible = false
		}, parent)

		new("UICorner", { CornerRadius = UDim.new(0, 36) }, parent4) -- inferred equivalent call
		new("UIStroke", { Color = color, Thickness = 1600, Transparency = 0.04 }, parent4) -- inferred equivalent call

		local parent5 = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 }, parent4) -- inferred equivalent call
		new("UICorner", { CornerRadius = UDim.new(0, 36) }, parent5) -- inferred equivalent call
		new("UIStroke", { Color = color, Thickness = 14, Transparency = 0.55 }, parent5) -- inferred equivalent call

		for _, anchorPoint in {
			Vector2.new(0, 0),
			Vector2.new(1, 0),
			Vector2.new(0, 1),
			Vector2.new(1, 1)
		} do
			local v = anchorPoint.X == 0 and 1 or -1
			local v2 = anchorPoint.Y == 0 and 1 or -1
			local parent6 = bar(parent4, UDim2.fromOffset(34, 3), hazard)
			parent6.AnchorPoint = anchorPoint
			parent6.Position = UDim2.new(anchorPoint.X, v * 22, anchorPoint.Y, v2 * 22)
			local parent7 = bar(parent4, UDim2.fromOffset(3, 34), hazard)
			parent7.AnchorPoint = anchorPoint
			parent7.Position = UDim2.new(anchorPoint.X, v * 22, anchorPoint.Y, v2 * 22)
		end

		local parent6 = new("Frame", { -- inferred equivalent call
			Name = "SightMarks",
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Visible = false
		}, parent3)

		for _, anchorPoint in {
			Vector2.new(0, 0),
			Vector2.new(1, 0),
			Vector2.new(0, 1),
			Vector2.new(1, 1)
		} do
			local v = bar(parent6, UDim2.fromOffset(18, 2))
			v.AnchorPoint = anchorPoint
			v.Position = UDim2.fromScale(anchorPoint.X, anchorPoint.Y)
			local v2 = bar(parent6, UDim2.fromOffset(2, 18))
			v2.AnchorPoint = anchorPoint
			v2.Position = UDim2.fromScale(anchorPoint.X, anchorPoint.Y)
		end

		local v = text(parent6, "", 14, Vector2.new(0, 1), UDim2.fromOffset(0, -4))
		local v2 = text(parent4, "", 16, Vector2.new(0, 0), UDim2.fromOffset(30, 34))
		v2.TextColor3 = hazard

		local parent7 = new("Frame", { -- inferred equivalent call
			Size = UDim2.fromOffset(340, 40),
			Position = UDim2.new(0.5, 0, 0, 58),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			ClipsDescendants = true
		}, parent3)

		local bar_2 = bar(parent7, UDim2.new(1, 0, 0, 2), nil)
		bar_2.Position = UDim2.new(0.5, 0, 0, 1)

		local v3 = {}
		local v4 = {}

		for _ = 1, 22 do
			local v5 = bar(parent7, UDim2.fromOffset(2, 6))
			v5.AnchorPoint = Vector2.new(0.5, 0)
			table.insert(v3, v5)
			table.insert(v4, text(parent7, "", 14, Vector2.new(0.5, 0), UDim2.fromOffset(0, 14)))
		end

		local parent8 = bar(parent7, UDim2.fromOffset(12, 5), hazard)
		parent8.AnchorPoint = Vector2.new(0.5, 0)
		local v5 = bar(parent3, UDim2.fromOffset(2, 10))
		v5.AnchorPoint = Vector2.new(0.5, 0)
		v5.Position = UDim2.new(0.5, 0, 0, 98)
		local v6 = text(parent3, "000", 16, Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 108))

		local parent9 = new( -- inferred equivalent call
			"Frame",
			{
				Size = UDim2.fromOffset(0, 0),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1
			},
			parent3
		)

		local v7 = {}
		local function rbit(p: number, p2: number, p3: number, p4: number) -- 8 equivalent calls inferred from this helper
			local parent10 = bar(parent9, UDim2.fromOffset(p, p2), hazard)
			parent10.Position = UDim2.fromOffset(p3, p4)
			table.insert(v7, parent10)
		end

		rbit(2, 2, 0, 0) -- inferred equivalent call

		for i = -1, 1, 2 do
			rbit(50, 2, i * 39, 0) -- inferred equivalent call
			rbit(2, 12, i * 64, 0) -- inferred equivalent call
			rbit(2, 6, i * 38, 3) -- inferred equivalent call
		end

		rbit(2, 34, 0, 31) -- inferred equivalent call
		rbit(10, 2, 0, 26) -- inferred equivalent call
		rbit(6, 2, 0, 38) -- inferred equivalent call
		rbit(2, 10, 0, -19) -- inferred equivalent call
		local v8 = text(parent9, "---", 15, Vector2.new(0.5, 0), UDim2.fromOffset(0, 56))

		local parent10 = new("Frame", { -- inferred equivalent call
			Size = UDim2.fromOffset(9, 9),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Rotation = 45,
			BackgroundTransparency = 1,
			Visible = false
		}, parent3)

		new("UIStroke", { Color = white, Thickness = 2 }, parent10) -- inferred equivalent call
		local parent11 = new("Frame", { -- inferred equivalent call
			Size = UDim2.fromOffset(84, 4),
			Position = UDim2.fromOffset(0, 80),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = data.panel,
			BackgroundTransparency = 0.3,
			BorderSizePixel = 0
		}, parent9)

		new("UIStroke", { Color = white, Thickness = 1, Transparency = 0.4 }, parent11) -- inferred equivalent call
		local frame = new( -- inferred equivalent call
			"Frame",
			{ Size = UDim2.fromScale(0, 1), BackgroundColor3 = hazard, BorderSizePixel = 0 },
			parent11
		)
		local v9 = text(parent9, "READY", 16, Vector2.new(0.5, 0), UDim2.fromOffset(0, 76))
		v9.TextColor3 = hazard
		v9.Visible = false
		local uiScale = new("UIScale", {}, parent9) -- inferred equivalent call

		local parent12 = new( -- inferred equivalent call
			"Frame",
			{
				Size = UDim2.fromOffset(0, 0),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1,
				Visible = false
			},
			parent3
		)

		local v10 = {}

		for _, v11 in {
			Vector2.new(0, -1),
			Vector2.new(0, 1),
			Vector2.new(-1, 0),
			Vector2.new(1, 0)
		} do
			local v12

			if v11.X == 0 then
				v12 = UDim2.fromOffset(2, 8)
			else
				v12 = UDim2.fromOffset(8, 2)
			end

			local parent13 = bar(parent12, v12, white)
			parent13.Position = UDim2.fromOffset(v11.X * 10, v11.Y * 10)
			table.insert(v10, parent13)
		end

		local parent13 = new("Frame", { -- inferred equivalent call
			Size = UDim2.fromOffset(56, 4),
			Position = UDim2.fromOffset(0, 24),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = data.panel,
			BackgroundTransparency = 0.3,
			BorderSizePixel = 0
		}, parent12)

		new("UIStroke", { Color = white, Thickness = 1, Transparency = 0.4 }, parent13) -- inferred equivalent call
		local frame2 = new( -- inferred equivalent call
			"Frame",
			{ Size = UDim2.fromScale(0, 1), BackgroundColor3 = white, BorderSizePixel = 0 },
			parent13
		)
		local v11 = text(parent12, "GUN HOT", 15, Vector2.new(0.5, 0), UDim2.fromOffset(0, 32))
		v11.TextColor3 = danger
		v11.Visible = false

		local function readout(p: number, p2: number, p3: number, text2: string)
			local textXAlignment

			if p2 == 1 then
				textXAlignment = Enum.TextXAlignment.Right
			else
				textXAlignment = Enum.TextXAlignment.Left
			end

			local v12 = text(parent3, text2, 12, Vector2.new(p2, 1), UDim2.new(0.5, p, 0.5, p3))
			v12.TextXAlignment = textXAlignment
			v12.TextColor3 = hazard
			local v13 = text(parent3, "", 20, Vector2.new(p2, 0), UDim2.new(0.5, p, 0.5, p3))
			v13.TextXAlignment = textXAlignment
			return v13, v12
		end

		local v12, v13 = readout(-200, 1, -40, "CANNON")
		local v14, v15 = readout(-200, 1, 12, "SHELLS")
		local v16, v17 = readout(200, 0, -40, "GUN")
		local v18 = readout(200, 0, 12, "KM/H")
		local v19 = readout(200, 0, 64, "GEAR")

		local parent14 = new("Frame", { -- inferred equivalent call
			Size = UDim2.fromOffset(150, 40),
			Position = UDim2.new(0.5, 0, 1, -16),
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = data.panel,
			BackgroundTransparency = 0.25,
			BorderSizePixel = 0
		}, parent3)

		new("UICorner", { CornerRadius = UDim.new(0, 4) }, parent14) -- inferred equivalent call
		local bar_3 = bar(parent14, UDim2.fromOffset(22, 4), hazard)
		bar_3.Position = UDim2.fromOffset(11, 2)
		local parent15 = new( -- inferred equivalent call
			"Frame",
			{
				Size = UDim2.fromOffset(126, 6),
				Position = UDim2.new(0.5, 0, 1, -12),
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = 1
			},
			parent14
		)

		new( -- inferred equivalent call
			"UIListLayout",
			{
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 2),
				SortOrder = Enum.SortOrder.LayoutOrder
			},
			parent15
		)

		local v20 = {}

		for i = 1, 10 do
			v20[i] = new("Frame", { -- inferred equivalent call
				Size = UDim2.fromOffset(10, 6),
				BorderSizePixel = 0,
				LayoutOrder = i
			}, parent15)
		end

		local v21 = text(parent14, "", 13, Vector2.new(1, 1), UDim2.new(1, -10, 1, -16))
		local v22 = text(parent14, "HULL", 13, Vector2.new(0, 1), UDim2.new(0, 10, 1, -16))
		v22.TextColor3 = hazard

		local v23 = 1
		local v24 = 0
		local v25 = true
		local v26 = -1e999

		local v27 = {}
		local function put(p, p2: string, p3) -- 36 equivalent calls inferred from this helper
			local v28 = v27[p]

			if v28 == nil then
				v28 = {}
				v27[p] = v28
			end

			if v28[p2] ~= p3 then
				v28[p2] = p3
				p[p2] = p3
			end
		end
		local v28 = {}
		return {
			hide = function()
				put(parent3, "Visible", false) -- inferred equivalent call
				put(parent4, "Visible", false) -- inferred equivalent call
			end,
			update = function(data2)
				put(parent3, "Visible", true) -- inferred equivalent call
				put(parent4, "Visible", data2.periscope) -- inferred equivalent call
				local zoom = data2.zoom
				local v29

				if zoom == nil then
					v29 = false
				else
					v29 = zoom > 0
				end

				local v30 = v29 and 1 or 0

				if v28[parent4] ~= v30 then
					v28[parent4] = v30
					local size

					if v29 then
						size = UDim2.fromScale(0.62, 0.84)
					else
						size = UDim2.fromScale(0.9, 0.8)
					end

					parent4.Size = size
				end

				put(v2, "Visible", v29) -- inferred equivalent call
				put(parent6, "Visible", zoom ~= nil and zoom < 0) -- inferred equivalent call

				if zoom then
					local v31 = math.abs(zoom)

					if v28[parent6] ~= v31 then
						v28[parent6] = v31
						local text2 = string.format("%dX", v31)
						v2.Text = text2
						v.Text = text2
						parent6.Size = UDim2.fromScale(1 / v31, 1 / v31)
					end
				end

				local cframe = data2.cam.CFrame
				local now = os.clock()

				local lookVector = cframe.LookVector
				local v31 = math.deg((math.atan2(lookVector.X, -lookVector.Z))) % 360
				local lookVector2 = data2.body.LookVector
				local v32 = math.deg((math.atan2(lookVector2.X, -lookVector2.Z))) % 360
				local v53 = math.floor((v31 - 340 / 7) / 5) * 5

				for i = 1, 22 do
					local v54 = v53 + (i - 1) * 5
					local v55 = (v54 - v31) * 3.5 + 170
					local v56 = v54 % 360
					local v57 = v56 % 30 == 0
					local v58 = v3[i]
					put(v58, "Position", UDim2.fromOffset(v55, 2)) -- inferred equivalent call
					local v59 = v57 and 10 or v56 % 15 == 0 and 6 or 3

					if v28[v58] ~= v59 then
						v28[v58] = v59
						v58.Size = UDim2.fromOffset(2, v59)
					end

					local v60 = v4[i]
					put(v60, "Visible", v57) -- inferred equivalent call

					if not v57 then
						continue
					end

					put(v60, "Position", UDim2.fromOffset(v55, 14)) -- inferred equivalent call

					if v28[v60] == v56 then
						continue
					end

					v28[v60] = v56
					v60.Text = v56 == 0 and "N"
						or v56 == 90 and "E"
						or v56 == 180 and "S"
						or v56 == 270 and "W"
						or tostring(v56)
				end

				local v54 = (v32 - v31 + 540) % 360 - 180
				put(parent8, "Position", UDim2.fromOffset(math.clamp(v54 * 3.5, -164, 164) + 170, 2)) -- inferred equivalent call
				local v55 = math.floor(v31 + 0.5) % 360

				if v28[v6] ~= v55 then
					v28[v6] = v55
					v6.Text = string.format("%03d", v55)
				end

				local viewportSize = data2.cam.ViewportSize
				local v56 = data2.minigun and data2.gunAtMg ~= nil
				local cam = data2.cam
				local v57 = if v56 then data2.gunAtMg else data2.gunAt
				local worldToViewportPoint, v58 = cam:WorldToViewportPoint(v57)
				local v59 = Vector2.new(worldToViewportPoint.X, worldToViewportPoint.Y)

				if worldToViewportPoint.Z < 0 then
					v59 = viewportSize / 2 - (v59 - viewportSize / 2) * 10000
				end

				if not v58 then
					v59 = Vector2.new(
						math.clamp(v59.X, 40, viewportSize.X - 40),
						(math.clamp(v59.Y, 40, viewportSize.Y - 40))
					)
				end

				local rider = data2.rider == true
				put(parent9, "Visible", not (v56 or rider)) -- inferred equivalent call
				put(parent12, "Visible", v56 and not rider) -- inferred equivalent call

				for _, v62 in { v12, v13, v14, v15, v16, v17 } do
					put(v62, "Visible", not rider) -- inferred equivalent call
				end

				if v56 then
					put(parent12, "Position", UDim2.fromOffset(v59.X, v59.Y)) -- inferred equivalent call
					local v62 = if data2.mgHot then danger else white

					for _, v63 in v10 do
						put(v63, "BackgroundColor3", v62) -- inferred equivalent call
					end

					put(parent13, "Visible", data2.mgHeat > 0.01 or data2.mgHot) -- inferred equivalent call
					put(frame2, "Size", UDim2.fromScale(math.clamp(data2.mgHeat, 0, 1), 1)) -- inferred equivalent call
					local v64

					if data2.mgHot then
						v64 = danger
					elseif data2.mgHeat > 0.7 then
						v64 = hazard
					else
						v64 = white
					end

					put(frame2, "BackgroundColor3", v64) -- inferred equivalent call
					put(v11, "Visible", data2.mgHot and not data2.wrecked) -- inferred equivalent call
				else
					put(parent9, "Position", UDim2.fromOffset(v59.X, v59.Y)) -- inferred equivalent call
				end

				put(parent10, "Visible", not rider and (v59 - viewportSize / 2).Magnitude > 6) -- inferred equivalent call
				local v64

				if data2.shells >= 1 then
					v64 = (data2.magazine or not data2.cooling) and not data2.wrecked
				else
					v64 = false
				end

				if v64 and not v25 then
					v26 = now
				end

				v25 = v64
				local v65 = now - v26
				put(v9, "Visible", v65 < 0.8 and not rider) -- inferred equivalent call
				put(uiScale, "Scale", math.clamp(1 - v65 / 0.25, 0, 1) * 0.30000000000000004 + 1) -- inferred equivalent call
				local v68 = v64 and 1 or 0

				if v28[parent9] ~= v68 then
					v28[parent9] = v68

					for _, v69 in v7 do
						local backgroundColor

						if v64 then
							backgroundColor = hazard
						else
							backgroundColor = danger
						end

						v69.BackgroundColor3 = backgroundColor
						v69.BackgroundTransparency = v64 and 0 or 0.4
					end
				end

				local v69 = not data2.range and -1 or math.floor(data2.range + 0.5)

				if v28[v8] ~= v69 then
					v28[v8] = v69
					v8.Text = not data2.range and "---" or string.format("%d M", v69)
				end

				put(parent11, "Visible", data2.load < 1 or not data2.magazine and data2.shells < data2.maxShells) -- inferred equivalent call
				put(frame, "Size", UDim2.fromScale(math.clamp(data2.load, 0, 1), 1)) -- inferred equivalent call

				put(v13, "Text", data2.gunName or "CANNON") -- inferred equivalent call
				put(v15, "Text", data2.ammoName or "SHELLS") -- inferred equivalent call

				if data2.wrecked then
					put(v12, "Text", "DEAD") -- inferred equivalent call
					put(v12, "TextColor3", danger) -- inferred equivalent call
				elseif data2.shells < 1 or data2.cooling and not data2.magazine then
					put( -- inferred equivalent call
						v12,
						"Text",
						not (data2.loadLeft > 0) and "LOADING" or string.format("LOADING %.1f", data2.loadLeft)
					)
					put(v12, "TextColor3", danger) -- inferred equivalent call
				else
					put(v12, "Text", "READY") -- inferred equivalent call
					put(v12, "TextColor3", white) -- inferred equivalent call
				end

				local v70 = data2.shells * 4096 + data2.maxShells

				if v28[v14] ~= v70 then
					v28[v14] = v70
					local text2

					if data2.maxShells > 6 then
						text2 = string.format("%d / %d", data2.shells, data2.maxShells)
					else
						text2 = string.rep("■ ", data2.shells) .. string.rep(
							"□ ",
							(math.max(0, data2.maxShells - data2.shells))
						)
					end

					v14.Text = text2
				end

				local pitch = math.deg(data2.pitch)
				local v71 = math.floor(pitch + (pitch >= 0 and 0.5 or -0.5))

				if v28[v16] ~= v71 then
					v28[v16] = v71
					v16.Text = string.format("%+d°", v71)
				end

				local v72 = math.floor(data2.speed + 0.5)

				if v28[v18] ~= v72 then
					v28[v18] = v72
					v18.Text = tostring(v72)
				end

				put(v19, "Text", data2.gear) -- inferred equivalent call

				local v73 = math.clamp(data2.health, 0, 1)

				if v73 < v23 - 0.001 then
					v24 = now + 0.35
				end

				v23 = v73
				local v74

				if v73 < 0.35 then
					v74 = danger
				else
					v74 = if v73 < 0.7 then hazard else white
				end

				local v75 = math.ceil(v73 * 10 - 1e-6)
				local v76 = v75 * 4 + (v73 < 0.35 and 2 or v73 < 0.7 and 1 or 0)

				if v28[parent15] ~= v76 then
					v28[parent15] = v76

					for k, v77 in v20 do
						local backgroundColor

						if k <= v75 then
							backgroundColor = v74
						else
							backgroundColor = data.panel
						end

						v77.BackgroundColor3 = backgroundColor
						v77.BackgroundTransparency = k <= v75 and 0 or 0.1
					end
				end

				local v77 = math.floor(v73 * 100 + 0.5)

				if v28[v21] ~= v77 then
					v28[v21] = v77
					v21.Text = tostring(v77) .. "%"
				end

				put(v21, "TextColor3", v74) -- inferred equivalent call
				local v80

				if now < v24 or data2.wrecked then
					v80 = danger
				else
					v80 = hazard
				end

				put(v22, "TextColor3", v80) -- inferred equivalent call
			end
		}
	end
}