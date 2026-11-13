local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local function createInputLayers(cmdr)
	if not cmdr:FindFirstChild("Backdrop") then
		local backdrop = Instance.new("Frame")
		backdrop.Active = false
		backdrop.BackgroundTransparency = 1
		backdrop.Name = "Backdrop"
		backdrop.Size = UDim2.fromScale(1, 1)
		backdrop.Visible = false
		backdrop.ZIndex = 0
		backdrop.Parent = cmdr
	end

	if not cmdr:FindFirstChild("MouseUnlocker") then
		local mouseUnlocker = Instance.new("TextButton")
		mouseUnlocker.Active = false
		mouseUnlocker.BackgroundTransparency = 1
		mouseUnlocker.Modal = true
		mouseUnlocker.Name = "MouseUnlocker"
		mouseUnlocker.Selectable = false
		mouseUnlocker.Size = UDim2.fromOffset(0, 0)
		mouseUnlocker.Text = ""
		mouseUnlocker.Visible = false
		mouseUnlocker.Parent = cmdr
	end
end

return function()
	if StarterGui:FindFirstChild("Cmdr") then
		local cmdr = PlayerGui:WaitForChild("Cmdr")
		createInputLayers(cmdr)
		return cmdr
	else
		local cmdr = Instance.new("ScreenGui")
		cmdr.DisplayOrder = 1000
		cmdr.Name = "Cmdr"
		cmdr.ResetOnSpawn = false
		cmdr.AutoLocalize = false

		local frame = Instance.new("ScrollingFrame")
		frame.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
		frame.BackgroundTransparency = 0.4
		frame.BorderSizePixel = 0
		frame.CanvasSize = UDim2.new(0, 0, 0, 0)
		frame.Name = "Frame"
		frame.Position = UDim2.new(0.025, 0, 0, 25)
		frame.ScrollBarThickness = 6
		frame.ScrollingDirection = Enum.ScrollingDirection.Y
		frame.Selectable = false
		frame.Size = UDim2.fromScale(0.95, 0)
		frame.Visible = false
		frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
		frame.Parent = cmdr

		local autocomplete = Instance.new("ScrollingFrame")
		autocomplete.BackgroundColor3 = Color3.fromRGB(59, 59, 59)
		autocomplete.BackgroundTransparency = 0.5
		autocomplete.BorderSizePixel = 0
		autocomplete.CanvasSize = UDim2.new(0, 0, 0, 0)
		autocomplete.Name = "Autocomplete"
		autocomplete.Position = UDim2.fromOffset(167, 75)
		autocomplete.ScrollBarThickness = 6
		autocomplete.ScrollingDirection = Enum.ScrollingDirection.Y
		autocomplete.Selectable = false
		autocomplete.Size = UDim2.fromOffset(200, 200)
		autocomplete.Visible = false
		autocomplete.AutomaticCanvasSize = Enum.AutomaticSize.Y
		autocomplete.Parent = cmdr

		local uiListLayout = Instance.new("UIListLayout")
		uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uiListLayout.Parent = frame

		local line = Instance.new("TextBox")
		line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		line.BackgroundTransparency = 1
		line.Font = Enum.Font.Code
		line.Name = "Line"
		line.Size = UDim2.new(1, 0, 0, 20)
		line.AutomaticSize = Enum.AutomaticSize.Y
		line.TextColor3 = Color3.fromRGB(255, 255, 255)
		line.TextSize = 14
		line.TextXAlignment = Enum.TextXAlignment.Left
		line.TextEditable = false
		line.ClearTextOnFocus = false
		line.Parent = frame

		local uiPadding = Instance.new("UIPadding")
		uiPadding.PaddingBottom = UDim.new(0, 10)
		uiPadding.PaddingLeft = UDim.new(0, 10)
		uiPadding.PaddingRight = UDim.new(0, 10)
		uiPadding.PaddingTop = UDim.new(0, 10)
		uiPadding.Parent = frame

		local entry = Instance.new("Frame")
		entry.BackgroundTransparency = 1
		entry.LayoutOrder = 999999999
		entry.Name = "Entry"
		entry.Size = UDim2.new(1, 0, 0, 20)
		entry.Parent = frame

		local uiListLayout2 = Instance.new("UIListLayout")
		uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
		uiListLayout2.Parent = autocomplete

		local title = Instance.new("Frame")
		title.BackgroundColor3 = Color3.fromRGB(59, 59, 59)
		title.BackgroundTransparency = 0.2
		title.BorderSizePixel = 0
		title.LayoutOrder = -2
		title.Name = "Title"
		title.Size = UDim2.new(1, 0, 0, 40)
		title.Parent = autocomplete

		local description = Instance.new("Frame")
		description.BackgroundColor3 = Color3.fromRGB(59, 59, 59)
		description.BackgroundTransparency = 0.2
		description.BorderSizePixel = 0
		description.LayoutOrder = -1
		description.Name = "Description"
		description.Size = UDim2.new(1, 0, 0, 20)
		description.Parent = autocomplete

		local textButton = Instance.new("TextButton")
		textButton.BackgroundColor3 = Color3.fromRGB(59, 59, 59)
		textButton.BackgroundTransparency = 0.5
		textButton.BorderSizePixel = 0
		textButton.Font = Enum.Font.Code
		textButton.Size = UDim2.new(1, 0, 0, 30)
		textButton.Text = ""
		textButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		textButton.TextSize = 14
		textButton.TextXAlignment = Enum.TextXAlignment.Left
		textButton.Parent = autocomplete

		local uiListLayout3 = Instance.new("UIListLayout")
		uiListLayout3.FillDirection = Enum.FillDirection.Horizontal
		uiListLayout3.SortOrder = Enum.SortOrder.LayoutOrder
		uiListLayout3.Padding = UDim.new(0, 7)
		uiListLayout3.Parent = entry

		local textBox = Instance.new("TextBox")
		textBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		textBox.BackgroundTransparency = 1
		textBox.ClearTextOnFocus = false
		textBox.Font = Enum.Font.Code
		textBox.LayoutOrder = 999999999
		textBox.Position = UDim2.fromOffset(140, 0)
		textBox.Size = UDim2.new(1, 0, 0, 20)
		textBox.Text = "x"
		textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
		textBox.TextSize = 14
		textBox.TextXAlignment = Enum.TextXAlignment.Left
		textBox.Selectable = false
		textBox.Parent = entry

		local textLabel = Instance.new("TextLabel")
		textLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		textLabel.BackgroundTransparency = 1
		textLabel.Font = Enum.Font.Code
		textLabel.Size = UDim2.fromOffset(0, 20)
		textLabel.AutomaticSize = Enum.AutomaticSize.X
		textLabel.Text = ""
		textLabel.TextColor3 = Color3.fromRGB(255, 223, 93)
		textLabel.TextSize = 14
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.Parent = entry

		local field = Instance.new("TextLabel")
		field.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		field.BackgroundTransparency = 1
		field.Font = Enum.Font.SourceSansBold
		field.Name = "Field"
		field.Size = UDim2.new(0, 37, 1, 0)
		field.Text = "from"
		field.TextColor3 = Color3.fromRGB(255, 255, 255)
		field.TextSize = 20
		field.TextXAlignment = Enum.TextXAlignment.Left
		field.Parent = title

		local uiPadding2 = Instance.new("UIPadding")
		uiPadding2.PaddingLeft = UDim.new(0, 10)
		uiPadding2.Parent = title

		local label = Instance.new("TextLabel")
		label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.SourceSansLight
		label.Name = "Label"
		label.Size = UDim2.fromScale(1, 1)
		label.Text = "The players to teleport. The players to teleport. The players to teleport. The players to teleport. "
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextSize = 16
		label.TextWrapped = true
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextYAlignment = Enum.TextYAlignment.Top
		label.Parent = description

		local uiPadding3 = Instance.new("UIPadding")
		uiPadding3.PaddingBottom = UDim.new(0, 10)
		uiPadding3.PaddingLeft = UDim.new(0, 10)
		uiPadding3.PaddingRight = UDim.new(0, 10)
		uiPadding3.Parent = description

		local typed = Instance.new("TextLabel")
		typed.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		typed.BackgroundTransparency = 1
		typed.Font = Enum.Font.Code
		typed.Name = "Typed"
		typed.Size = UDim2.fromScale(1, 1)
		typed.Text = "Lab"
		typed.TextColor3 = Color3.fromRGB(131, 222, 255)
		typed.TextSize = 14
		typed.TextXAlignment = Enum.TextXAlignment.Left
		typed.Parent = textButton

		local uiPadding4 = Instance.new("UIPadding")
		uiPadding4.PaddingLeft = UDim.new(0, 10)
		uiPadding4.Parent = textButton

		local suggest = Instance.new("TextLabel")
		suggest.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		suggest.BackgroundTransparency = 1
		suggest.Font = Enum.Font.Code
		suggest.Name = "Suggest"
		suggest.Size = UDim2.fromScale(1, 1)
		suggest.Text = "   el"
		suggest.TextColor3 = Color3.fromRGB(255, 255, 255)
		suggest.TextSize = 14
		suggest.TextXAlignment = Enum.TextXAlignment.Left
		suggest.Parent = textButton

		local kind = Instance.new("TextLabel")
		kind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		kind.BackgroundTransparency = 1
		kind.BorderColor3 = Color3.fromRGB(255, 153, 153)
		kind.Font = Enum.Font.SourceSans
		kind.Name = "Type"
		kind.Position = UDim2.fromScale(1, 0)
		kind.Size = UDim2.fromScale(0, 1)
		kind.Text = ": Players"
		kind.TextColor3 = Color3.fromRGB(255, 255, 255)
		kind.TextSize = 15
		kind.TextXAlignment = Enum.TextXAlignment.Left
		kind.Parent = field

		createInputLayers(cmdr)

		cmdr.Parent = PlayerGui
		return cmdr
	end
end