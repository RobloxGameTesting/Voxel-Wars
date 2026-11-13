local Style = require(script.Parent:WaitForChild("Style"))

local function build(parent)
	local selected = Instance.new("Frame")
	selected.Name = "Selected"
	selected.BackgroundTransparency = 1
	selected.Size = UDim2.fromScale(1, 1)
	selected.ZIndex = 6
	selected.Visible = false
	local result = {}

	for _, v in {
		{ 0, 0 },
		{ 1, 0 },
		{ 0, 1 },
		{ 1, 1 }
	} do
		local v2 = v[1]
		local v3 = v[2]
		local corner = Instance.new("Frame")
		corner.Name = "Corner"
		corner.BackgroundTransparency = 1
		corner.AnchorPoint = Vector2.new(v2, v3)
		corner.Size = UDim2.fromOffset(18, 18)
		corner.ZIndex = 6
		corner.Parent = selected
		local fill = Style.fill(
			corner,
			"Across",
			Style.HAZARD,
			UDim2.new(1, 0, 0, 3),
			UDim2.fromScale(0, v3),
			Vector2.new(0, v3)
		)
		local fill2 = Style.fill(
			corner,
			"Down",
			Style.HAZARD,
			UDim2.new(0, 3, 1, 0),
			UDim2.fromScale(v2, 0),
			Vector2.new(v2, 0)
		)
		fill.ZIndex = 6
		fill2.ZIndex = 6
		table.insert(result, { holder = corner, x = v2, y = v3 })
	end

	local fill = Style.fill(parent, "SelectFlash", Color3.new(1, 1, 1), UDim2.fromScale(1, 1))
	fill.ZIndex = 5
	fill.BackgroundTransparency = 1
	fill.Visible = false
	local uiCorner = parent:FindFirstChildOfClass("UICorner")

	if uiCorner then
		local clone = uiCorner:Clone()
		clone.Parent = fill
	end

	selected.Parent = parent
	return selected, result, fill
end

local function place(items, p: number)
	for _, item in items do
		item.holder.Position = UDim2.new(item.x, (item.x * 2 - 1) * p, item.y, (item.y * 2 - 1) * p)
	end
end

return {
	attach = function(parent, p, color: Color3, value: number?)
		local v = value or 5
		local v2 = nil
		local v3 = {}
		local v4 = nil
		local v5 = false
		return function(flag: boolean)
			local color2 = if flag then Style.WHITE else color
			p.Color = color2
			p.Thickness = 2

			if flag == v5 then
				return
			end

			v5 = flag

			if flag then
				if not v2 then
					v2, v3, v4 = build(parent)
				end

				local v6 = v2
				local v7 = v4
				v6.Visible = true
				v7.Visible = true
				place(v3, v + 9)
				v7.BackgroundTransparency = 0.78
				local now = os.clock()
				Style.animate(v6, function(_: number, p2: number): boolean
					local v8 = p2 - now
					place(v3, v + 9 * (1 - Style.pop(v8 / 0.2)))
					local v9 = math.min(v8 / 0.24, 1)
					v7.BackgroundTransparency = 0.78 + 0.21999999999999997 * Style.easeOut(v9)

					if v8 >= 0.24 then
						place(v3, v)
						v7.Visible = false
						return false
					end

					return true
				end)
			elseif v2 then
				Style.stop(v2)
				v2.Visible = false
				v4.Visible = false
			end
		end
	end
}