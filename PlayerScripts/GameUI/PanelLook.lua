local TweenService = game:GetService("TweenService")

local Style = require(script.Parent:WaitForChild("Style"))

local PanelLook = {}

PanelLook.RAISED = Color3.fromRGB(40, 43, 50)

function PanelLook.feel(parent)
	local punch = Instance.new("UIScale")
	punch.Name = "Punch"
	punch.Parent = parent
	local v = 1
	local function go(scale: number, duration: number, p)
		TweenService:Create(punch, TweenInfo.new(duration, p, Enum.EasingDirection.Out), {
			Scale = scale
		}):Play()
	end

	if not Style.isTouch() then
		local fill = Style.fill(parent, "Hover", Style.WHITE, UDim2.fromScale(1, 1))
		fill.BackgroundTransparency = 1
		fill.ZIndex = 8
		Style.corner(fill, 4)
		parent.MouseEnter:Connect(function()
			v = 1.03
			fill.BackgroundTransparency = 0.9
			go(v, 0.1, Enum.EasingStyle.Quad)
		end)
		parent.MouseLeave:Connect(function()
			v = 1
			fill.BackgroundTransparency = 1
			go(v, 0.1, Enum.EasingStyle.Quad)
		end)
	end

	parent.InputBegan:Connect(function(input)
		local userInputType = input.UserInputType

		if userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.Touch then
			go(0.95, 0.07, Enum.EasingStyle.Quad)
		end
	end)
	parent.InputEnded:Connect(function(input)
		local userInputType = input.UserInputType

		if userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.Touch then
			go(v, 0.24, Enum.EasingStyle.Back)
		end
	end)
end

function PanelLook.row(p, p2: number, p3: number, p4: number, p5: number)
	local fill = Style.fill(p, "RowPlate", PanelLook.RAISED, UDim2.fromOffset(p4, p5), UDim2.fromOffset(p2, p3))
	fill.BackgroundTransparency = 0.25
	Style.corner(fill, 6)
	Style.stroke(fill, 1.5, 0.2, Style.INK, true)
	return fill
end

function PanelLook.dress(p, parent, p2, parent2, instance)
	local fill = Style.fill(
		p,
		"Dim",
		Style.INK,
		UDim2.fromOffset(8000, 8000),
		UDim2.fromScale(0.5, 0.5),
		Vector2.new(0.5, 0.5)
	)
	fill.BackgroundTransparency = 0.45
	fill.ZIndex = 0

	parent.AnchorPoint = Vector2.new(0.5, 0.5)
	parent.Position = UDim2.fromScale(0.5, 0.5)
	parent.BackgroundColor3 = Style.INK
	parent.BackgroundTransparency = 0
	local uiCorner = parent:FindFirstChildOfClass("UICorner")

	if uiCorner then
		uiCorner.CornerRadius = UDim.new(0, 8)
	end

	local room = Instance.new("ImageLabel")
	room.Name = "Room"
	room.BackgroundTransparency = 1
	room.Image = "rbxassetid://101274562317334"
	room.ScaleType = Enum.ScaleType.Crop
	room.Size = UDim2.fromScale(1, 1)
	room.ZIndex = 0
	room.Parent = parent
	Style.corner(room, 8)
	local fill2 = Style.fill(room, "Ink", Style.INK, UDim2.fromScale(1, 1))
	fill2.BackgroundTransparency = 0.3
	fill2.ZIndex = 0
	Style.corner(fill2, 8)

	p2.BackgroundTransparency = 1
	local fill_2 = Style.fill(p2, "Rule", Style.STEEL_LIGHT, UDim2.new(1, -28, 0, 2), UDim2.new(0, 14, 1, -2))
	fill_2.BackgroundTransparency = 0.4
	parent2.TextColor3 = Style.HAZARD
	parent2.TextSize = 26
	local uiStroke = parent2:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
	uiStroke.Thickness = 2
	uiStroke.Color = Style.INK
	uiStroke.LineJoinMode = Enum.LineJoinMode.Round
	uiStroke.Parent = parent2
	instance.BackgroundColor3 = Style.ORANGE
	local textLabel = instance:FindFirstChildWhichIsA("TextLabel")

	if textLabel then
		textLabel.TextColor3 = Style.INK
	end

	PanelLook.feel(instance)
	local pop = Instance.new("UIScale")
	pop.Name = "Pop"
	pop.Parent = parent
	return function()
		pop.Scale = 0.92
		fill.BackgroundTransparency = 1
		TweenService:Create(pop, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = 1
		}):Play()
		TweenService:Create(fill, TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.45
		}):Play()
	end
end

return PanelLook