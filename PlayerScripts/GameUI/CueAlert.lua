local Style = require(script.Parent.Style)

local fn
local CueAlert = {}

function CueAlert.show(p: string, flag: boolean, p2: string)
	local v = fn
	assert(v, "[CueAlert] not mounted")
	local v2

	if flag then
		v2 = Style.teamText(p2)
	else
		v2 = Style.HAZARD
	end

	v(p, v2)
end

function CueAlert.mount(p)
	local region = Style.region(
		p.layers.hud,
		"CueAlert",
		Vector2.new(0.5, 0),
		Vector2.new(0, Style.topInset() + 110),
		Vector2.new(480, 34)
	)
	region.Visible = false
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = region
	local fill = Style.fill(
		region,
		"Band",
		Style.INK,
		UDim2.fromScale(1, 1),
		UDim2.fromScale(0.5, 0.5),
		Vector2.new(0.5, 0.5)
	)
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.18, 0),
		NumberSequenceKeypoint.new(0.82, 0),
		NumberSequenceKeypoint.new(1, 1)
	})

	uiGradient.Parent = fill
	local fill2 = Style.fill(
		region,
		"Accent",
		Style.WHITE,
		UDim2.fromOffset(150, 3),
		UDim2.fromScale(0.5, 0),
		Vector2.new(0.5, 0)
	)
	local label = Style.label(region, "Line", "", 20, Style.FONT, 1.5)
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.fromScale(0.5, 0.54)
	local uiStroke = label:FindFirstChildOfClass("UIStroke")

	local v = 0
	local v2 = false

	local v3 = nil
	local v4 = nil
	local function step(_, p2: number): boolean
		local v5 = p2 - v

		if v5 > 4.7 then
			v2 = false
			region.Visible = false
			return false
		else
			local v6

			if v5 < 0.2 then
				v6 = 1 - v5 / 0.2
			else
				v6 = math.clamp((v5 - 0.2 - 4) / 0.5, 0, 1)
			end

			if v6 ~= v3 then
				v3 = v6
				label.TextTransparency = v6
				fill.BackgroundTransparency = v6 * 0.65 + 0.35
				fill2.BackgroundTransparency = v6

				if uiStroke then
					uiStroke.Transparency = v6 * 0.6 + 0.4
				end
			end

			local scale = 1 + 0.14 * (1 - Style.easeOut((math.min(v5 / 0.30000000000000004, 1))))

			if scale ~= v4 then
				v4 = scale
				uiScale.Scale = scale
			end

			return true
		end
	end

	fn = function(text: string, backgroundColor: Color3)
		label.Text = text
		fill2.BackgroundColor3 = backgroundColor
		v = os.clock()
		v3 = nil
		v4 = nil
		region.Visible = true

		if not v2 then
			v2 = true
			Style.animate(label, step)
		end
	end
end

return CueAlert