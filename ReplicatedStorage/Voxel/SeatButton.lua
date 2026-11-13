local SeatButton = {}

local color = Color3.fromRGB(24, 25, 28)

local color2 = Color3.fromRGB(0, 0, 0)
local color3 = Color3.fromRGB(242, 238, 228)
local color4 = Color3.fromRGB(255, 198, 32)
local rbxassetfontsfamiliesOswaldjson = Font.new("rbxasset://fonts/families/Oswald.json", Enum.FontWeight.Bold)

SeatButton.SIZE = Vector2.new(92, 48)

function SeatButton.make(parent, name: string, text: string, position: UDim2, flag: boolean)
	local textButton = Instance.new("TextButton")
	textButton.Name = name
	textButton.Size = UDim2.fromOffset(SeatButton.SIZE.X, SeatButton.SIZE.Y)
	textButton.Position = position
	textButton.AnchorPoint = Vector2.new(1, 1)
	textButton.BackgroundColor3 = color
	textButton.BackgroundTransparency = 0.18
	textButton.BorderSizePixel = 0
	textButton.AutoButtonColor = false
	textButton.FontFace = rbxassetfontsfamiliesOswaldjson
	textButton.TextColor3 = color3
	textButton.TextSize = 18
	textButton.Text = text
	textButton.Visible = false
	textButton.Parent = parent
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 3)
	uiCorner.Parent = textButton
	local uiStroke = Instance.new("UIStroke")
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Color = color2
	uiStroke.Thickness = 1.5
	uiStroke.Transparency = 0.35
	uiStroke.Parent = textButton

	if flag then
		local bar = Instance.new("Frame")
		bar.Name = "Bar"
		bar.AnchorPoint = Vector2.new(0, 0.5)
		bar.Position = UDim2.new(0, 5, 0.5, 0)
		bar.Size = UDim2.new(0, 4, 1, -12)
		bar.BackgroundColor3 = color4
		bar.BorderSizePixel = 0
		bar.Active = false
		bar.Parent = textButton
		local uiPadding = Instance.new("UIPadding")
		uiPadding.PaddingLeft = UDim.new(0, 8)
		uiPadding.Parent = textButton
		bar.Position = UDim2.new(0, -3, 0.5, 0)
	end

	local function held(flag2: boolean)
		textButton.BackgroundTransparency = flag2 and 0.05 or 0.18
		local color5 = if flag2 then color4 else color2
		uiStroke.Color = color5
		uiStroke.Thickness = flag2 and 2 or 1.5
		uiStroke.Transparency = flag2 and 0 or 0.35
	end
	textButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			textButton.BackgroundTransparency = 0.05
			uiStroke.Color = color4
			uiStroke.Thickness = 2
			uiStroke.Transparency = 0
		end
	end)
	textButton.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			textButton.BackgroundTransparency = 0.18
			uiStroke.Color = color2
			uiStroke.Thickness = 1.5
			uiStroke.Transparency = 0.35
		end
	end)

	textButton:GetPropertyChangedSignal("Visible"):Connect(function()
		textButton.BackgroundTransparency = 0.18
		uiStroke.Color = color2
		uiStroke.Thickness = 1.5
		uiStroke.Transparency = 0.35
	end)
	return textButton
end

return SeatButton