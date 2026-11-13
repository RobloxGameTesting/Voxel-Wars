local Players = game:GetService("Players")

local v = {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = Color3.fromRGB(17, 17, 17),
	BackgroundTransparency = 0.05,
	BorderColor3 = Color3.fromRGB(17, 17, 17),
	BorderSizePixel = 20,
	ClearTextOnFocus = false,
	MultiLine = true,
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.5, 0.4),
	Font = Enum.Font.Code,
	TextColor3 = Color3.fromRGB(241, 241, 241),
	TextWrapped = true,
	TextSize = 18,
	TextXAlignment = "Left",
	TextYAlignment = "Top",
	AutoLocalize = false,
	PlaceholderText = "Right click to exit"
}

local v2 = nil

return {
	Name = "edit",
	Description = "Edit text in a TextBox.",
	Group = "DefaultUtil",
	Args = {
		{
			Type = "string",
			Name = "Input text",
			Description = "The text you wish to edit.",
			Default = ""
		},
		{
			Type = "string",
			Name = "Delimiter",
			Description = "The character that separates each line.",
			Default = ","
		}
	},
	ClientRun = function(object, value: string, p: string)
		v2 = v2 or object.Cmdr.Util.Mutex()

		local v3 = v2()
		object:Reply("Right-click on the text area to exit.", Color3.fromRGB(158, 158, 158))

		local cmdrEditBox = Instance.new("ScreenGui")
		cmdrEditBox.Name = "CmdrEditBox"
		cmdrEditBox.ResetOnSpawn = false

		local textBox = Instance.new("TextBox")

		for k, v4 in pairs(v) do
			textBox[k] = v4
		end

		textBox.Text = value:gsub(p, "\n")
		textBox.Parent = cmdrEditBox

		cmdrEditBox.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

		local thread = coroutine.running()
		textBox.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton2 then
				coroutine.resume(thread, textBox.Text:gsub("\n", p))
				cmdrEditBox:Destroy()
				v3()
			end
		end)

		return coroutine.yield()
	end
}