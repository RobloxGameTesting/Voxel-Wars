local Glyph = require(script.Parent.Parent:WaitForChild("GameUI"):WaitForChild("Glyph"))

local function new(className: string, items, parent) -- 8 equivalent calls inferred from this helper
	local instance = Instance.new(className)

	for k, item in items do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

return {
	new = function(parent, data)
		local parent2 = new("CanvasGroup", { -- inferred equivalent call
			Name = "DriveKeys",
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.XY,
			Size = UDim2.fromOffset(0, 0),
			Position = UDim2.new(0.5, 112, 1, -18),
			AnchorPoint = Vector2.new(0, 1),
			Visible = false
		}, parent)

		new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) }, parent2) -- inferred equivalent call
		local function key(layoutOrder: number, p: string, p2, text: string)
			local parent3 = new("Frame", { -- inferred equivalent call
				Name = "Row" .. layoutOrder,
				LayoutOrder = layoutOrder,
				BackgroundColor3 = data.panel,
				BackgroundTransparency = 0.15,
				AutomaticSize = Enum.AutomaticSize.XY,
				Size = UDim2.fromOffset(0, 0)
			}, parent2)

			new( -- inferred equivalent call
				"UIListLayout",
				{
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 8)
				},
				parent3
			)

			new("UICorner", { CornerRadius = UDim.new(0, 4) }, parent3) -- inferred equivalent call
			new( -- inferred equivalent call
				"UIPadding",
				{
					PaddingTop = UDim.new(0, 4),
					PaddingBottom = UDim.new(0, 4),
					PaddingLeft = UDim.new(0, 5),
					PaddingRight = UDim.new(0, 10)
				},
				parent3
			)

			local cap = Glyph.cap(parent3, p, p2, 22)
			cap.LayoutOrder = 1
			local parent4 = new("TextLabel", { -- inferred equivalent call
				BackgroundTransparency = 1,
				FontFace = data.font,
				TextSize = 16,
				TextColor3 = data.white,
				Text = text,
				AutomaticSize = Enum.AutomaticSize.XY,
				Size = UDim2.fromOffset(0, 0),
				LayoutOrder = 2
			}, parent3)

			new("UIStroke", { Color = data.panel, Transparency = 0.4, Thickness = 1.5 }, parent4) -- inferred equivalent call
			return parent3, parent4
		end

		local v = key(-4, "W", Enum.KeyCode.ButtonR2, "DRIVE")
		local v2 = key(-3, "S", Enum.KeyCode.ButtonL2, "REVERSE")
		local parent3, parent4 = key(-2, "LMB", Enum.KeyCode.ButtonR1, "FIRE")
		local v3 = key(-1, "1 2", Enum.KeyCode.ButtonL1, "SWITCH WEAPON")
		parent4.TextColor3 = data.hazard
		local v4 = key(1, "V", Enum.KeyCode.ButtonR3, "VIEW")
		local parent5, parent6 = key(2, "RMB", Enum.KeyCode.ButtonL3, "ZOOM")
		local v5 = key(3, "X", Enum.KeyCode.DPadUp, "SWITCH SEAT")
		key(4, "E", Enum.KeyCode.ButtonY, "GET OUT")

		local v6 = false
		local v7 = false
		local v8 = 0

		local v9 = {}
		return {
			update = function(data2)
				if data2 then
					local now = os.clock()

					if not v6 then
						v6 = true
						v8 = now + (v7 and 3.5 or 7)
						v7 = true
					end

					local mode = Glyph.mode()

					local v10 = mode == "gamepad" and "ZOOM" or "ZOOM (HOLD)"

					if v9.word ~= v10 then
						v9.word = v10
						parent6.Text = v10
					end

					if v9.row ~= data2.turret then
						v9.row = data2.turret
						parent5.Visible = data2.turret
					end

					local passenger = data2.passenger == true
					local visible

					if mode == "gamepad" and data2.rider ~= true then
						visible = not passenger
					else
						visible = false
					end

					local armed = data2.armed == true
					local rows = (visible and 1 or 0) + (armed and 2 or 0) + (armed and data2.swap and 4 or 0)
					local seatRows = (data2.seat and 1 or 0) + (passenger and 2 or 0)

					if v9.seatRows ~= seatRows then
						v9.seatRows = seatRows
						v5.Visible = data2.seat == true
						v4.Visible = not passenger
					end

					if v9.rows ~= rows then
						v9.rows = rows
						v.Visible = visible
						v2.Visible = visible
						parent3.Visible = armed
						v3.Visible = armed and data2.swap == true
					end

					local v11 = mode ~= "touch"

					if v9.list ~= v11 then
						v9.list = v11
						parent2.Visible = v11
					end

					local v12 = now < v8 and 0 or 0.45

					if v9.alpha ~= v12 then
						v9.alpha = v12
						parent2.GroupTransparency = v12
					end
				else
					v6 = false

					if v9.list ~= false then
						v9.list = false
						parent2.Visible = false
					end
				end
			end
		}
	end
}