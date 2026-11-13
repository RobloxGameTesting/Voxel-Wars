local v = {
	-30,
	-20,
	-15,
	-10,
	-5,
	5,
	10,
	15,
	20,
	30
}

local function new(className: string, items, parent) -- 20 equivalent calls inferred from this helper
	local instance = Instance.new(className)

	for k, item in items do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

return {
	new = function(parent, data)
		local white = data.white
		local hazard = data.hazard
		local danger = data.danger

		local parent3 = new( -- inferred equivalent call
			"Frame",
			{
				Name = "CockpitHud",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Visible = false
			},
			parent
		)

		local function bar(parent2, size: UDim2, color: Color3?)
			local parent4 = new("Frame", { -- inferred equivalent call
				Size = size,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = color or white,
				BorderSizePixel = 0
			}, parent2)

			new("UIStroke", { Color = data.panel, Transparency = 0.55, Thickness = 1 }, parent4) -- inferred equivalent call
			return parent4
		end

		local function text(parent2, text2: string, textSize: number, anchorPoint: Vector2, position: UDim2)
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
			}, parent2)

			new("UIStroke", { Color = data.panel, Transparency = 0.45, Thickness = 1.5 }, parent4) -- inferred equivalent call
			return parent4
		end

		local parent2 = new("Frame", { -- inferred equivalent call
			Size = UDim2.fromOffset(360, 40),
			Position = UDim2.new(0.5, 0, 0, 22),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			ClipsDescendants = true
		}, parent3)

		local bar_2 = bar(parent2, UDim2.new(1, 0, 0, 2), nil)
		bar_2.Position = UDim2.new(0.5, 0, 0, 1)

		local v2 = {}
		local v3 = {}

		for _ = 1, 21 do
			local v4 = bar(parent2, UDim2.fromOffset(2, 6))
			v4.AnchorPoint = Vector2.new(0.5, 0)
			table.insert(v2, v4)
			table.insert(v3, text(parent2, "", 14, Vector2.new(0.5, 0), UDim2.fromOffset(0, 14)))
		end

		local parent4 = bar(parent2, UDim2.fromOffset(10, 4), hazard)
		parent4.AnchorPoint = Vector2.new(0.5, 0)

		local v4 = bar(parent3, UDim2.fromOffset(2, 10))
		v4.AnchorPoint = Vector2.new(0.5, 0)
		v4.Position = UDim2.new(0.5, 0, 0, 62)
		local parent5 = new("Frame", { -- inferred equivalent call
			Size = UDim2.fromOffset(46, 22),
			Position = UDim2.new(0.5, 0, 0, 74),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = data.panel,
			BackgroundTransparency = 0.35,
			BorderSizePixel = 0
		}, parent3)

		new("UIStroke", { Color = white, Thickness = 1.5 }, parent5) -- inferred equivalent call
		local v5 = text(parent5, "000", 16, Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5))

		local v6 = {}
		local function rung(deg: number)
			local v7 = deg == 0 and 300 or 150
			local v8 = deg == 0 and 90 or 70
			local frame = new( -- inferred equivalent call
				"Frame",
				{
					Size = UDim2.fromOffset(v7, 14),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Visible = false
				},
				parent3
			)

			local v9 = (v7 - v8) / 2
			local v10 = deg == 0 and 3 or 2

			for i = -1, 1, 2 do
				if deg < 0 then
					local v11 = v9 / 5

					for j = 0, 2 do
						local v12 = i * (v8 / 2 + v11 * (j * 2 + 0.5))
						local bar_2 = bar(frame, UDim2.fromOffset(v11, v10))
						bar_2.Position = UDim2.new(0.5, v12, 0.5, 0)
					end
				else
					local bar_3 = bar(frame, UDim2.fromOffset(v9, v10))
					bar_3.Position = UDim2.new(0.5, i * (v8 / 2 + v9 / 2), 0.5, 0)
				end

				if deg == 0 then
					continue
				end

				local v11 = bar(frame, UDim2.fromOffset(2, 6))
				v11.AnchorPoint = Vector2.new(0.5, deg > 0 and 0 or 1)
				v11.Position = UDim2.new(0.5, i * (v7 / 2 - 1), 0.5, 0)
				text(
					frame,
					tostring(((math.abs)(deg))),
					12,
					Vector2.new(i < 0 and 1 or 0, 0.5),
					UDim2.new(0.5, i * (v7 / 2 + 4), 0.5, 0)
				)
			end

			table.insert(v6, { frame = frame, deg = deg })
		end
		rung(0)

		for _, v7 in v do
			rung(v7)
		end

		local parent6 = new( -- inferred equivalent call
			"Frame",
			{
				Size = UDim2.fromOffset(44, 20),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Visible = false
			},
			parent3
		)

		local parent7 = new( -- inferred equivalent call
			"Frame",
			{
				Size = UDim2.fromOffset(12, 12),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1
			},
			parent6
		)

		new("UICorner", { CornerRadius = UDim.new(1, 0) }, parent7) -- inferred equivalent call
		new("UIStroke", { Color = white, Thickness = 2 }, parent7) -- inferred equivalent call
		local bar_3 = bar(parent6, UDim2.fromOffset(12, 2))
		bar_3.Position = UDim2.new(0.5, -13, 0.5, 0)
		local bar_4 = bar(parent6, UDim2.fromOffset(12, 2))
		bar_4.Position = UDim2.new(0.5, 13, 0.5, 0)
		local bar_5 = bar(parent6, UDim2.fromOffset(2, 6))
		bar_5.Position = UDim2.new(0.5, 0, 0.5, -9)

		local parent8 = new( -- inferred equivalent call
			"Frame",
			{
				Size = UDim2.fromOffset(28, 14),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Visible = false
			},
			parent3
		)

		for i = -1, 1, 2 do
			local parent9 = bar(parent8, UDim2.fromOffset(12, 2), hazard)
			parent9.Position = UDim2.new(0.5, i * 5, 0.5, 2)
			parent9.Rotation = i * 35
		end

		local function box(p: number, p2: number, text2: string)
			local parent9 = new("Frame", { -- inferred equivalent call
				Size = UDim2.fromOffset(72, 30),
				Position = UDim2.new(0.5, p, 0.5, 0),
				AnchorPoint = Vector2.new(p2, 0.5),
				BackgroundColor3 = data.panel,
				BackgroundTransparency = 0.35,
				BorderSizePixel = 0
			}, parent3)

			new("UIStroke", { Color = white, Thickness = 1.5 }, parent9) -- inferred equivalent call
			local v7 = text(parent9, "0", 22, Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5))
			text(parent9, text2, 12, Vector2.new(p2, 0), UDim2.new(p2, 0, 1, 4))
			return v7
		end

		local v7 = box(-190, 1, "KM/H")
		local v8 = box(190, 0, "M")

		local v9 = text(parent3, "", 14, Vector2.new(0, 0.5), UDim2.new(0.5, 270, 0.5, 0))

		local parent9 = new( -- inferred equivalent call
			"Frame",
			{
				Size = UDim2.fromOffset(330, 24),
				Position = UDim2.new(0.5, 0, 0.5, 150),
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = 1
			},
			parent3
		)

		local function meter(p: number, text2: string)
			text(parent9, text2, 13, Vector2.new(0, 0.5), UDim2.new(0, p, 0.5, 0))
			local parent10 = new("Frame", { -- inferred equivalent call
				Size = UDim2.fromOffset(64, 6),
				Position = UDim2.new(0, p + 38, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = data.panel,
				BackgroundTransparency = 0.3,
				BorderSizePixel = 0
			}, parent9)

			new("UIStroke", { Color = white, Thickness = 1, Transparency = 0.3 }, parent10) -- inferred equivalent call
			return new( -- inferred equivalent call
				"Frame",
				{ Size = UDim2.fromScale(1, 1), BackgroundColor3 = white, BorderSizePixel = 0 },
				parent10
			)
		end

		local v10 = meter(0, "HULL")
		local v11 = meter(118, "GUN")
		text(parent9, "RKT", 13, Vector2.new(0, 0.5), UDim2.new(0, 248, 0.5, 0))
		local v12 = text(parent9, "", 16, Vector2.new(1, 0.5), UDim2.new(1, 0, 0.5, 0))

		return {
			hide = function()
				parent3.Visible = false
			end,
			update = function(data2)
				parent3.Visible = true
				local cam = data2.cam
				local cframe = cam.CFrame
				local viewportSize = cam.ViewportSize
				local v13 = viewportSize * 0.5
				local v14 = viewportSize.Y * 0.3

				local lookVector = cframe.LookVector
				local v15 = math.deg((math.atan2(lookVector.X, -lookVector.Z))) % 360
				local lookVector2 = data2.body.LookVector
				local v16 = math.deg((math.atan2(lookVector2.X, -lookVector2.Z))) % 360
				local v17 = math.floor((v15 - 45) / 5) * 5

				for i = 1, 21 do
					local v18 = v17 + (i - 1) * 5
					local v19 = (v18 - v15) * 4 + 180
					local v20 = v18 % 360
					local visible = v20 % 30 == 0
					local v21 = v2[i]
					v21.Position = UDim2.fromOffset(v19, 2)
					v21.Size = UDim2.fromOffset(2, visible and 10 or v20 % 10 == 0 and 6 or 3)
					local v22 = v3[i]
					v22.Visible = visible

					if not visible then
						continue
					end

					v22.Position = UDim2.fromOffset(v19, 14)
					v22.Text = v20 == 0 and "N"
						or v20 == 90 and "E"
						or v20 == 180 and "S"
						or v20 == 270 and "W"
						or string.format("%02d", v20 // 10)
				end

				local v18 = (v16 - v15 + 540) % 360 - 180
				parent4.Position = UDim2.fromOffset(math.clamp(v18 * 4, -174, 174) + 180, 2)
				v5.Text = string.format("%03d", math.floor(v15 + 0.5) % 360)

				local v19 = Vector3.new(lookVector.X, 0, lookVector.Z)

				if v19.Magnitude < 0.001 then
					v19 = Vector3.new(cframe.UpVector.X, 0, cframe.UpVector.Z) * -math.sign(lookVector.Y)
				end

				local unit = v19.Unit
				local vector3 = Vector3.new(-unit.Z, 0, unit.X)
				local position = cframe.Position

				for _, v20 in v6 do
					local deg = math.rad(v20.deg)
					local v21 = unit * math.cos(deg) + Vector3.new(0, math.sin(deg), 0)
					local worldToViewportPoint, visible = cam:WorldToViewportPoint(position + v21 * 1000)
					local worldToViewportPoint2 = cam:WorldToViewportPoint(position + (v21 + vector3 * 0.05) * 1000)
					local vector2 = Vector2.new(worldToViewportPoint.X, worldToViewportPoint.Y)

					if visible then
						if worldToViewportPoint.Z > 0 then
							visible = (vector2 - v13).Magnitude < v14
						else
							visible = false
						end
					end

					v20.frame.Visible = visible

					if not visible then
						continue
					end

					v20.frame.Position = UDim2.fromOffset(vector2.X, vector2.Y)
					v20.frame.Rotation = math.deg((math.atan2(
						worldToViewportPoint2.Y - worldToViewportPoint.Y,
						worldToViewportPoint2.X - worldToViewportPoint.X
					)))
				end

				if data2.vel.Magnitude > 4 then
					local worldToViewportPoint = cam:WorldToViewportPoint(position + data2.vel.Unit * 1000)
					local vector2 = Vector2.new(worldToViewportPoint.X, worldToViewportPoint.Y)
					parent6.Visible = worldToViewportPoint.Z > 0 and (vector2 - v13).Magnitude < viewportSize.Y * 0.42
					parent6.Position = UDim2.fromOffset(vector2.X, vector2.Y)
				else
					parent6.Visible = false
				end

				local worldToViewportPoint = cam:WorldToViewportPoint(data2.nose)
				parent8.Visible = worldToViewportPoint.Z > 0
					and (Vector2.new(worldToViewportPoint.X, worldToViewportPoint.Y) - v13).Magnitude < viewportSize.Y * 0.42
				parent8.Position = UDim2.fromOffset(worldToViewportPoint.X, worldToViewportPoint.Y)

				v7.Text = tostring((math.floor(data2.speed + 0.5)))
				v8.Text = tostring((math.floor(data2.alt + 0.5)))
				local textColor

				if data2.alt < 4 then
					textColor = hazard
				else
					textColor = white
				end

				v8.TextColor3 = textColor
				local v20 = math.floor(data2.climb + 0.5)
				local text2

				if v20 > 0 then
					text2 = "▲ " .. v20
				else
					text2 = not (v20 < 0) and "" or "▼ " .. -v20
				end

				v9.Text = text2
				local textColor2

				if v20 < -8 and data2.alt < 30 then
					textColor2 = danger
				else
					textColor2 = white
				end

				v9.TextColor3 = textColor2

				local v21 = math.clamp(data2.health, 0, 1)
				v10.Size = UDim2.fromScale(v21, 1)
				local backgroundColor

				if v21 < 0.35 then
					backgroundColor = danger
				elseif v21 < 0.7 then
					backgroundColor = hazard
				else
					backgroundColor = white
				end

				v10.BackgroundColor3 = backgroundColor
				v11.Size = UDim2.fromScale(math.clamp(data2.heat, 0, 1), 1)
				local backgroundColor2

				if data2.locked then
					backgroundColor2 = danger
				elseif data2.heat > 0.7 then
					backgroundColor2 = hazard
				else
					backgroundColor2 = white
				end

				v11.BackgroundColor3 = backgroundColor2
				v12.Text = not (data2.rockets > 0) and "RELOAD" or tostring(data2.rockets)
				local textColor3

				if data2.rockets > 0 then
					textColor3 = white
				else
					textColor3 = hazard
				end

				v12.TextColor3 = textColor3
			end
		}
	end
}