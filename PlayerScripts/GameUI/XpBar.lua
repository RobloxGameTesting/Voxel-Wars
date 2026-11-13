local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Style = require(script.Parent.Style)
local CareerData = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("CareerData"))

local XpBar = {}

local v = Style.isTouch() and 18 or 15
XpBar.HEIGHT = 46

local v2 = Style.isTouch() and 340 or 320

function XpBar.compact(p: number, p2: number): boolean
	return p2 - 14 - v2 * p < p2 / 2 + p * 180 + 10
end

function XpBar.height(p: number, p2: number): number
	return if XpBar.compact(p, p2) then 62 else 46
end

local color = Color3.fromRGB(26, 27, 31)

function XpBar.mount(p)
	local player = p.player

	local layer = Style.layer(p.playerGui, "GameLevel", 7)
	local region = Style.region(
		layer,
		"XpBar",
		Vector2.new(1, 0),
		Vector2.new(-14, Style.topInset() + 6),
		Vector2.new(330, 46)
	)

	local frame = Style.frame(region, "Rank", UDim2.fromOffset(32, 32))
	frame.AnchorPoint = Vector2.new(1, 0.5)
	frame.Position = UDim2.new(1, 0, 0, 14)
	local box = Style.box(frame, "Plate", Style.STEEL_LIGHT, UDim2.fromScale(0.72, 0.72), 3, 2.5)
	box.AnchorPoint = Vector2.new(0.5, 0.5)
	box.Position = UDim2.fromScale(0.5, 0.5)
	box.Rotation = 45
	local box2 = Style.box(frame, "Inner", Style.STEEL, UDim2.fromScale(0.54, 0.54), 2, 1.5)
	box2.AnchorPoint = Vector2.new(0.5, 0.5)
	box2.Position = UDim2.fromScale(0.5, 0.5)
	box2.Rotation = 45
	local label = Style.label(frame, "Level", "1", 16, Style.FONT, 1.5)
	label.AutomaticSize = Enum.AutomaticSize.None
	label.Size = UDim2.fromScale(1, 1)
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = frame

	local box3 = Style.box(region, "Bar", color, UDim2.fromOffset(150, 12), 2, 2)
	box3.AnchorPoint = Vector2.new(1, 0.5)
	box3.Position = UDim2.new(1, -40, 0, 14)
	box3.ClipsDescendants = true

	local fill = Style.fill(box3, "Fill", Style.HAZARD, UDim2.fromScale(0, 1))

	local label2 = Style.label(region, "Amount", "", v, Style.FONT, 1.5)
	label2.AnchorPoint = Vector2.new(1, 0.5)
	label2.Position = UDim2.new(1, -198, 0, 14)

	local v3 = 28
	local label3 = Style.label(region, "Round", "", v - 2, Style.FONT, 1.5)
	label3.TextColor3 = Style.HAZARD
	label3.AnchorPoint = Vector2.new(1, 0)
	label3.Position = UDim2.new(1, -40, 0, v3)
	local box4 = Style.box(region, "Boost", Style.GOOD, UDim2.fromOffset(30, 16), 2, 1.5)
	box4.AnchorPoint = Vector2.new(1, 0)
	local label4 = Style.label(box4, "Text", "2X", 13, Style.FONT, 0)
	label4.AutomaticSize = Enum.AutomaticSize.None
	label4.Size = UDim2.fromScale(1, 1)
	label4.TextColor3 = Style.INK

	local box5 = Style.box(region, "GunBoost", Style.ORANGE, UDim2.fromOffset(0, 16), 2, 1.5)
	box5.AnchorPoint = Vector2.new(1, 0)
	box5.AutomaticSize = Enum.AutomaticSize.X
	local uiPadding = Instance.new("UIPadding")
	local udim = UDim.new(0, 5)
	local udim2 = UDim.new(0, 5)
	uiPadding.PaddingLeft = udim
	uiPadding.PaddingRight = udim2
	uiPadding.Parent = box5
	local label5 = Style.label(box5, "Text", "2X GUN", 13, Style.FONT, 0)
	label5.Size = UDim2.fromOffset(0, 16)
	label5.TextColor3 = Style.INK

	local v4 = nil
	local function num(attributeName: string) -- 6 equivalent calls inferred from this helper
		local attribute = player:GetAttribute(attributeName)
		return if type(attribute) == "number" then attribute else 0
	end

	local v5 = {}
	local function put(p2: string, p3, fn): boolean -- 9 equivalent calls inferred from this helper
		if v5[p2] == p3 then
			return false
		end

		v5[p2] = p3
		fn(p3)
		return true
	end

	local function placeBoost()
		local v6 = not v5.roundOn and 0 or label3.TextBounds.X + 6
		local function fn(p2)
			box4.Position = UDim2.new(1, -(40 + p2), 0, v3 + 1)
		end

		put("boostX", v6, fn) -- inferred equivalent call

		local function fn2(p2)
			box5.Position = UDim2.new(1, -(40 + p2), 0, v3 + 1)
		end

		put("gunX", v6 + (v5.boost and 34 or 0), fn2) -- inferred equivalent call
	end

	local v6 = nil
	local function layout()
		local x = layer.AbsoluteSize.X

		if x <= 0 then
			x = workspace.CurrentCamera.ViewportSize.X
		end

		local compact = XpBar.compact(Style.scale(), x)

		if compact == v6 then
			return
		end

		v6 = compact

		if compact then
			label2.AnchorPoint = Vector2.new(1, 0)
			label2.Position = UDim2.new(1, -40, 0, 23)
			v3 = v + 26
		else
			label2.AnchorPoint = Vector2.new(1, 0.5)
			label2.Position = UDim2.new(1, -198, 0, 14)
			v3 = 28
		end

		region.Size = UDim2.fromOffset(330, compact and 62 or 46)
		label3.Position = UDim2.new(1, -40, 0, v3)
		v5.boostX = nil
		v5.gunX = nil
		placeBoost()
	end
	Style.onScale(function()
		layout()
	end)
	layer:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
	local function refresh()
		local v7 = num("Level") -- inferred equivalent call
		local v8 = num("XP") -- inferred equivalent call
		local v9 = num("XPNext") -- inferred equivalent call
		local v10 = num("RoundXP") -- inferred equivalent call

		local function fn(text)
			label.Text = text
		end
		put("level", tostring((math.max(v7, 1))), fn) -- inferred equivalent call

		local function fn2(p2)
			fill.Size = UDim2.fromScale(p2, 1)
		end

		put("fill", not (v9 > 0) and 1 or math.clamp(v8 / v9, 0, 1), fn2) -- inferred equivalent call

		local function fn3(text)
			label2.Text = text
		end

		put( -- inferred equivalent call
			"amount",
			not (v9 > 0) and "MAX LEVEL" or Style.thousands((math.min(v8, v9))) .. " / " .. Style.thousands(v9) .. " XP",
			fn3
		)

		local v11 = put("boost", num(CareerData.BOOST_ATTR) > os.time(), function(visible) -- inferred equivalent call
			box4.Visible = visible
		end)
		local function fn4(visible)
			box5.Visible = visible
		end
		put("gun", num(CareerData.GUN_BOOST_ATTR) > os.time(), fn4) -- inferred equivalent call
		local v12 = put("roundOn", v10 > 0, function(visible) -- inferred equivalent call
			label3.Visible = visible
		end)
		local v13 = put("round", "+" .. Style.thousands(v10) .. " THIS ROUND", function(text) -- inferred equivalent call
			label3.Text = text
		end)

		if v12 or v13 or v11 then
			placeBoost()
		end

		if v4 and v4 < v7 then
			local now = os.clock()
			Style.animate(frame, function(_, p2): boolean
				local v14 = (p2 - now) / 0.45
				uiScale.Scale = not (v14 < 1) and 1 or math.sin(3.141592653589793 * math.clamp(v14, 0, 1)) * 0.35 + 1
				local backgroundColor

				if v14 < 1 then
					backgroundColor = Style.HAZARD
				else
					backgroundColor = Style.STEEL_LIGHT
				end

				box.BackgroundColor3 = backgroundColor
				return v14 < 1
			end)
		end

		v4 = v7
	end
	label3:GetPropertyChangedSignal("TextBounds"):Connect(placeBoost)
	player.AttributeChanged:Connect(function(p2: string)
		if
			p2 == "Level"
			or p2 == "XP"
			or p2 == "XPNext"
			or p2 == "RoundXP"
			or p2 == CareerData.BOOST_ATTR
			or p2 == CareerData.GUN_BOOST_ATTR
		then
			refresh()
		end
	end)

	task.spawn(function()
		while region.Parent do
			task.wait(5)
			refresh()
		end
	end)
	refresh()
end

return XpBar