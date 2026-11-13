local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Style = require(script.Parent:WaitForChild("Style"))
local UiTrack = require(script.Parent:WaitForChild("UiTrack"))
local CareerData = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("CareerData"))

local color = Color3.fromRGB(24, 26, 31)
local color2 = Color3.fromRGB(34, 37, 44)
local color3 = Color3.fromRGB(44, 48, 56)

local v = nil

local function label(p, p2: string, p3: number, p4: number, p5: number, p6: number, p7: number, options)
	local v2 = options or {}
	local label2 = Style.label(p, "Text", p2, p3, v2.font or Style.FONT, v2.outline or 1.5)
	label2.AutomaticSize = Enum.AutomaticSize.None
	label2.Size = UDim2.fromOffset(p6, p7)
	label2.Position = UDim2.fromOffset(p4, p5)
	label2.TextXAlignment = v2.ax or Enum.TextXAlignment.Left
	label2.TextYAlignment = v2.ay or Enum.TextYAlignment.Center
	label2.TextColor3 = v2.color or Style.WHITE
	label2.TextTruncate = Enum.TextTruncate.AtEnd
	label2.TextWrapped = v2.wrap == true
	label2.ZIndex = 42
	return label2
end

local function button(parent, name: string, p: string, backgroundColor: Color3, color4: Color3, p2: number, p3: number, p4: number, p5: number, p6: number)
	local textButton = Instance.new("TextButton")
	textButton.Name = name
	textButton.Text = ""
	textButton.AutoButtonColor = true
	textButton.BackgroundColor3 = backgroundColor
	textButton.BorderSizePixel = 0
	textButton.Size = UDim2.fromOffset(p4, p5)
	textButton.Position = UDim2.fromOffset(p2, p3)
	textButton.ZIndex = 42
	textButton.Parent = parent
	Style.corner(textButton, 6)
	Style.stroke(textButton, 2, 0, Style.INK, true)
	local label_2 = label(textButton, p, p6, 0, 0, p4, p5, {
		ax = Enum.TextXAlignment.Center,
		color = color4,
		outline = color4 == Style.INK and 0 or 1.5
	})
	label_2.Name = "Label"
	return textButton
end

local GiftPicker = {}

function GiftPicker.open(parent, p, data, data2)
	if v then
		v.close()
	end

	local gift = CareerData.giftOf(data.id)

	if not gift then
		data2.say("GIFTS COMING SOON")
		return
	end

	local remotes = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Remotes")
	local career = remotes:FindFirstChild("Career")
	local child = remotes:FindFirstChild(CareerData.GIFT_REMOTE)

	if not (career and child) then
		data2.say("NO ANSWER, TRY AGAIN")
		return
	end

	UiTrack.send("gift_open", data.id)

	local touch = data2.touch
	local v2 = touch and 1 or 1.25

	local function S(p2: number)
		return (math.floor(p2 * v2))
	end

	local v3 = parent.AbsoluteSize.X
	local v4 = parent.AbsoluteSize.Y

	if parent.Size.X.Offset > 0 then
		v3 = parent.Size.X.Offset
		v4 = parent.Size.Y.Offset
	end

	local v5 = math.min(v3 - 12, touch and 600 or 760)
	local v6 = math.min(v4 - 12, touch and 264 or 440)
	local connections = {}
	local v7 = true

	local giftPicker = Instance.new("TextButton")
	giftPicker.Name = "GiftPicker"
	giftPicker.Text = ""
	giftPicker.AutoButtonColor = false
	giftPicker.BackgroundColor3 = Color3.new(0, 0, 0)
	giftPicker.BackgroundTransparency = 0.35
	giftPicker.BorderSizePixel = 0
	giftPicker.Size = UDim2.fromScale(1, 1)
	giftPicker.ZIndex = 40
	giftPicker.Parent = parent

	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.BackgroundColor3 = color
	panel.BorderSizePixel = 0
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.fromOffset(v5, v6)
	panel.ZIndex = 41
	panel.Active = true
	panel.Parent = giftPicker
	Style.corner(panel, 10)
	Style.stroke(panel, 3, 0, Style.INK, true)

	local function close()
		if not v7 then
			return
		end

		v7 = false

		for _, connection in connections do
			connection:Disconnect()
		end

		giftPicker:Destroy()
		v = nil
	end
	v = { close = close }
	local v8 = touch and 10 or 14
	local label_2 = label(panel, "SEND A GIFT", math.floor(v2 * 22), v8, 0, v5 - v8 * 2 - 44, 44, {
		outline = 2
	})
	label_2.TextColor3 = Style.HAZARD
	button(panel, "Close", "X", Style.ORANGE, Style.INK, v5 - 44 - 4, 4, 40, 40, math.floor(v2 * 20)).Activated:Connect(close)
	local v9 = touch and 170 or 240
	local v10 = v6 - 46 - v8
	local item = Instance.new("Frame")
	item.Name = "Item"
	item.BackgroundColor3 = color2
	item.BorderSizePixel = 0
	item.Size = UDim2.fromOffset(v9, v10)
	item.Position = UDim2.fromOffset(v8, 46)
	item.ZIndex = 41
	item.Parent = panel
	Style.corner(item, 8)
	local v11 = v10 - math.floor(v2 * 18) * 2 - math.floor(v2 * 20) - 20

	local picture = Instance.new("Frame")
	picture.Name = "Picture"
	picture.BackgroundTransparency = 1
	picture.Size = UDim2.fromOffset(v9 - 12, v11)
	picture.Position = UDim2.fromOffset(6, 6)
	picture.ZIndex = 42
	picture.Parent = item

	if data2.picture then
		data2.picture(picture)
	elseif data.image then
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.BackgroundTransparency = 1
		imageLabel.Image = data.image
		imageLabel.ScaleType = Enum.ScaleType.Fit
		imageLabel.Size = UDim2.fromScale(1, 1)
		imageLabel.ZIndex = 42
		imageLabel.Parent = picture
	end

	for _, guiObject in picture:GetDescendants() do
		if guiObject:IsA("GuiObject") then
			guiObject.ZIndex = math.max(guiObject.ZIndex, 42)
		end
	end

	label(item, data.name, math.floor(v2 * 18), 8, v11 + 6 + 2, v9 - 16, math.floor(v2 * 18) * 2 + 4, {
		ax = Enum.TextXAlignment.Center,
		wrap = true,
		outline = 2
	})
	local v12

	if data2.price then
		v12 = Style.thousands(data2.price)
	end

	local folder = Style.frame(
		item,
		"Price",
		UDim2.fromOffset(v9, math.floor(v2 * 20) + 6),
		UDim2.fromOffset(0, v10 - math.floor(v2 * 20) - 12)
	)
	local robuxLine, v13 = Style.robuxLine(folder, "Line", (math.floor(v2 * 20)))
	v13(nil, v12 or "...", Style.WHITE)
	robuxLine.AnchorPoint = Vector2.new(0.5, 0.5)
	robuxLine.Position = UDim2.fromScale(0.5, 0.5)

	for _, guiObject in folder:GetDescendants() do
		if guiObject:IsA("GuiObject") then
			guiObject.ZIndex = 42
		end
	end

	local v14 = v8 + v9 + 6 + 2
	local v15 = v5 - v14 - v8
	local label_3 = label(panel, "PLAYERS IN THIS SERVER", math.floor(v2 * 16), v14, 46, v15, 44, {
		outline = 1.5,
		color = Style.MUTED
	})
	label_3.Name = "Heading"

	local list = Instance.new("ScrollingFrame")
	list.Name = "List"
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.Size = UDim2.fromOffset(v15, v6 - 96 - v8)
	list.Position = UDim2.fromOffset(v14, 96)
	list.ScrollingDirection = Enum.ScrollingDirection.Y
	list.ScrollBarThickness = 6
	list.ScrollBarImageColor3 = Style.HAZARD
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.CanvasSize = UDim2.new()
	list.ZIndex = 42
	list.Parent = panel
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.Padding = UDim.new(0, 4)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = list
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingRight = UDim.new(0, 10)
	uiPadding.Parent = list
	local v16 = label(panel, "", math.floor(v2 * 18), v14, 96, v15, v6 - 96 - v8, {
		ax = Enum.TextXAlignment.Center,
		wrap = true,
		outline = 2
	})
	v16.Visible = false

	local v17 = nil
	local flag = false

	local function showNote(text: string, good: Color3?) -- 2 equivalent calls inferred from this helper
		list.Visible = text == ""
		v16.Visible = text ~= ""
		v16.Text = text
		v16.TextColor3 = good or Style.WHITE
	end

	local function send(data3)
		if flag then
			return
		end

		flag = true

		if data2.sound then
			data2.sound()
		end

		UiTrack.send("gift_send", data.id)
		list.Visible = false
		v16.Visible = true
		v16.Text = "ASKING ROBLOX..."
		v16.TextColor3 = Style.WHITE

		local success, result, v18 = pcall(function()
			return career:InvokeServer("gift", data.id, data3.id)
		end)

		if not v7 then
			return
		end

		if success and result == true then
			showNote("FINISH IN THE ROBLOX WINDOW\nTO SEND IT TO " .. string.upper(data3.display)) -- inferred equivalent call
		else
			flag = false
			list.Visible = true
			v16.Visible = false
			v16.Text = ""
			v16.TextColor3 = Style.WHITE

			data2.say((not success or type(v18) ~= "string") and "NO ANSWER, TRY AGAIN" or string.upper(v18))
		end
	end

	local function row(layoutOrder: number, data3, flag2: boolean)
		local frame = Instance.new("Frame")
		frame.Name = "Row" .. layoutOrder
		frame.LayoutOrder = layoutOrder
		frame.BackgroundColor3 = color2
		frame.BorderSizePixel = 0
		frame.Size = UDim2.new(1, 0, 0, 54)
		frame.ZIndex = 42
		frame.Parent = list
		Style.corner(frame, 6)
		local head = Instance.new("ImageLabel")
		head.Name = "Head"
		head.BackgroundColor3 = Color3.fromRGB(60, 64, 72)
		head.BorderSizePixel = 0
		head.Image = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", data3.id)
		head.Size = UDim2.fromOffset(44, 44)
		head.Position = UDim2.fromOffset(5, 5)
		head.ZIndex = 43
		head.Parent = frame
		Style.corner(head, 22)
		local v18 = touch and 96 or 120
		local v19 = v15 - 10 - 56 - v18 - 12
		local label_2 = label(frame, data3.display, math.floor(v2 * 17), 56, 6, v19, math.floor(v2 * 17) + 4, {
			outline = 1.5
		})
		label_2.ZIndex = 43
		local v20 = "@" .. data3.name

		if not flag2 then
			v20 = (data3.online and "ONLINE · " or "") .. v20
		end

		local v21 = math.floor(v2 * 12)

		local v22 = 56
		local v23 = math.floor(v2 * 17) + 8 + 2
		local v24 = math.floor(v2 * 12) + 4

		local v25 = { font = Style.FONT_BODY, color = 0, outline = 0 }
		local color4 = if data3.online then Style.GOOD else Style.MUTED
		v25.color = color4
		local label_3 = label(frame, v20, v21, v22, v23, v19, v24, v25)
		label_3.ZIndex = 43
		local v26 = v15 - 10 - v18 - 5

		if data3.has then
			local v27 = button(frame, "Has", "HAS IT", color3, Style.MUTED, v26, 5, v18, 44, math.floor(v2 * 15))
			v27.AutoButtonColor = false
			v27.ZIndex = 43
			v27.Activated:Connect(function()
				data2.say("THEY ALREADY HAVE IT")
			end)
		else
			local v27 = button(frame, "Send", "SEND", Style.HAZARD, Style.INK, v26, 5, v18, 44, math.floor(v2 * 17))
			v27.ZIndex = 43
			local label_4 = v27:FindFirstChild("Label")
			label_4.ZIndex = 44
			v27.Activated:Connect(function()
				send(data3)
			end)
		end
	end

	local function fn()
		for _, frame in list:GetChildren() do
			if frame:IsA("Frame") then
				frame:Destroy()
			end
		end

		if v17 then
			local here = v17.here

			if #here == 0 then
				list.Visible = false
				v16.Visible = true
				v16.Text = "NOBODY ELSE IS IN THIS SERVER YET"
				v16.TextColor3 = Style.WHITE
			else
				list.Visible = true
				v16.Visible = false
				v16.Text = ""
				v16.TextColor3 = Style.WHITE

				for k, v18 in here do
					row(k, v18, true)
				end

				list.CanvasPosition = Vector2.zero
			end
		else
			list.Visible = false
			v16.Visible = true
			v16.Text = "LOADING..."
			v16.TextColor3 = Style.WHITE
		end
	end
	fn()

	table.insert(
		connections,
		MarketplaceService.PromptProductPurchaseFinished:Connect(function(p2: number, p3: number, flag2: boolean)
			if p2 ~= p.UserId or p3 ~= gift or not flag then
				return
			end

			if flag2 then
				list.Visible = false
				v16.Visible = true
				v16.Text = "SENDING..."
				v16.TextColor3 = Style.WHITE
			else
				flag = false
				fn()
			end
		end)
	)
	table.insert(connections, child.OnClientEvent:Connect(function(p2: string, p3, p4)
		if p2 == "sent" and p3 == data.id then
			flag = false
			showNote("GIFT SENT!\n" .. string.upper((tostring(p4))) .. " GETS " .. data.name, Style.GOOD) -- inferred equivalent call
		end
	end))

	task.spawn(function()
		local success, result = pcall(function()
			return career:InvokeServer("giftTargets", data.id)
		end)

		if not v7 then
			return
		end

		if success and type(result) == "table" and type(result.here) == "table" and type(result.friends) == "table" then
			v17 = result
			fn()
		else
			list.Visible = false
			v16.Visible = true
			v16.Text = "NO ANSWER, TRY AGAIN"
			v16.TextColor3 = Style.WHITE
		end
	end)
end

function GiftPicker.isOpen(): boolean
	return v ~= nil
end

function GiftPicker.close()
	if v then
		v.close()
	end
end

return GiftPicker