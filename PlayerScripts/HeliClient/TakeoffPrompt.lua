local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local GameUI = script.Parent.Parent:WaitForChild("GameUI")
local Glyph = require(GameUI:WaitForChild("Glyph"))
local Style = require(GameUI:WaitForChild("Style"))

local TakeoffPrompt = {}

local v = nil
local group = nil
local uiScale = nil

local function pressed() -- 1 equivalent call inferred from this helper
	return UserInputService:IsKeyDown(Enum.KeyCode.Space)
		or UserInputService.GamepadEnabled
		and UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonR2)
end

local function build()
	local layer = Style.layer(Players.LocalPlayer:WaitForChild("PlayerGui"), "HeliTakeoffPrompt", 7)
	v = layer
	local region = Style.region(layer, "Prompt", Vector2.new(0.5, 0.5), Vector2.zero, Vector2.new(520, 46))
	region.Position = UDim2.fromScale(0.5, 0.68)
	group = Instance.new("CanvasGroup")
	group.Name = "Group"
	group.BackgroundTransparency = 1
	group.BorderSizePixel = 0
	group.Size = UDim2.fromScale(1, 1)
	group.Parent = region
	uiScale = Instance.new("UIScale")
	uiScale.Parent = group
	local fill = Style.fill(
		group,
		"Band",
		Style.INK,
		UDim2.fromScale(1, 1),
		UDim2.fromScale(0.5, 0.5),
		Vector2.new(0.5, 0.5)
	)
	fill.BackgroundTransparency = 0.35
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.18, 0),
		NumberSequenceKeypoint.new(0.82, 0),
		NumberSequenceKeypoint.new(1, 1)
	})

	uiGradient.Parent = fill
	Style.fill(group, "Accent", Style.HAZARD, UDim2.fromOffset(150, 3), UDim2.fromScale(0.5, 0), Vector2.new(0.5, 0))
	local frame = Style.frame(group, "Row", UDim2.fromScale(1, 1))
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0, 10)
	uiListLayout.Parent = frame
	local cap = Glyph.cap(frame, "SPACE", Enum.KeyCode.ButtonR2, 28)
	cap.LayoutOrder = 1
	local label = Style.label(frame, "Line", "HOLD TO TAKE OFF", 24, Style.FONT, 1.5)
	label.LayoutOrder = 2
end

function TakeoffPrompt.show(callback)
	if not v then
		build()
	end

	local v2 = v
	local now = os.clock()
	local v3 = nil
	group.GroupTransparency = 1
	uiScale.Scale = 1.1400000000000001
	v2.Enabled = true
	Style.animate(TakeoffPrompt, function(_, p: number): boolean
		local v4 = p - now

		if not v3 and (v4 > 8 or pressed() or callback()) then -- inferred equivalent call
			v3 = p
		end

		local v5 = not v3 and 0 or (p - v3) / 0.35

		if v5 >= 1 then
			v2.Enabled = false
			return false
		end

		group.GroupTransparency = math.max(1 - v4 / 0.2, v5)
		uiScale.Scale = 1 + 0.14 * (1 - Style.easeOut((math.min(v4 / 0.30000000000000004, 1))))
		return true
	end)
end

return TakeoffPrompt