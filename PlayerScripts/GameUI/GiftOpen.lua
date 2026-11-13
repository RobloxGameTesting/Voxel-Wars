local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")

local Style = require(script.Parent:WaitForChild("Style"))
local ClaimFx = require(script.Parent:WaitForChild("ClaimFx"))
local ClaimAudio = require(script.Parent:WaitForChild("ClaimAudio"))

local GiftOpen = {}

local color = Color3.fromRGB(255, 196, 40)
local color2 = Color3.fromRGB(226, 150, 18)
local color3 = Color3.fromRGB(222, 44, 52)
local color4 = Color3.fromRGB(170, 26, 36)

local v = nil
local flag = false
local v2 = {}

local function block(parent, name: string, backgroundColor: Color3, p: number, p2: number, p3: number, p4: number, zIndex: number, p5: number?)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.BackgroundColor3 = backgroundColor
	frame.BorderSizePixel = 0
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Size = UDim2.fromOffset(p, p2)
	frame.Position = UDim2.fromOffset(p3, p4)
	frame.ZIndex = zIndex
	frame.Parent = parent
	Style.corner(frame, 6)

	if p5 then
		local stroke = Style.stroke(frame, p5, 0, Style.INK, true)
		stroke.LineJoinMode = Enum.LineJoinMode.Round
	end

	return frame
end

local function drawBox(folder)
	local v3 = block(folder, "Body", color2, 140, 104, 80, 108, 3, 4)
	block(v3, "Ribbon", color3, 26, 104, 70, 52, 4)
	block(v3, "Shade", color4, 26, 8, 70, 4, 5)
	local parent = block(folder, "Lid", color, 160, 38, 80, 50, 6, 4)
	block(parent, "Ribbon", color3, 26, 38, 80, 19, 7)

	for _, v4 in { -1, 1 } do
		local v5 = block(parent, "Loop", color3, 40, 30, 80 + v4 * 24, -14, 6, 4)
		v5.Rotation = v4 * 28
		Style.corner(v5, 14)
		local v6 = block(v5, "Hole", Style.INK, 16, 10, 20, 15, 7)
		Style.corner(v6, 5)
	end

	local v4 = block(parent, "Knot", color4, 20, 20, 80, -8, 8, 3)
	Style.corner(v4, 10)
	return v3, parent
end

local function label(folder, p: string, p2: number, p3: number, textColor: Color3, p4: number, zIndex: number)
	local label2 = Style.label(folder, "Text", p, p2, Style.FONT, p4)
	label2.AutomaticSize = Enum.AutomaticSize.None
	label2.AnchorPoint = Vector2.new(0.5, 0.5)
	label2.Size = UDim2.fromOffset(600, p2 + 8)
	label2.Position = UDim2.fromOffset(320, p3)
	label2.TextXAlignment = Enum.TextXAlignment.Center
	label2.TextColor3 = textColor
	label2.TextTruncate = Enum.TextTruncate.AtEnd
	label2.ZIndex = zIndex
	return label2
end

local fn

local function finish(p) -- 1 equivalent call inferred from this helper
	flag = false
	p.reveal()
	local v3 = table.remove(v2, 1)

	if v3 then
		task.delay(0.2, fn, v3)
	end
end

fn = function(p)
	flag = true
	local parent = v
	local absoluteSize = parent.AbsoluteSize

	local v3 = math.clamp(math.min(absoluteSize.X / 680, (absoluteSize.Y - 58) / 430), 0.5, 1.25)
	local vector2 = Vector2.new(absoluteSize.X / 2, 58 + (absoluteSize.Y - 58) / 2)

	local giftOpen = Instance.new("TextButton")
	giftOpen.Name = "GiftOpen"
	giftOpen.Text = ""
	giftOpen.AutoButtonColor = false
	giftOpen.BackgroundColor3 = Style.INK
	giftOpen.BackgroundTransparency = 1
	giftOpen.BorderSizePixel = 0
	giftOpen.Size = UDim2.fromScale(1, 1)
	giftOpen.ZIndex = 1
	giftOpen.Parent = parent
	local folder = Style.frame(
		giftOpen,
		"Stage",
		UDim2.fromOffset(640, 420),
		UDim2.fromOffset(vector2.X, vector2.Y),
		Vector2.new(0.5, 0.5)
	)
	local uiScale = Instance.new("UIScale")
	uiScale.Scale = v3 * 0.6
	uiScale.Parent = folder

	local glow = ClaimFx.glow(folder, 420, Style.HAZARD)
	glow.Position = UDim2.fromOffset(320, 214)
	glow.ImageTransparency = 1
	glow.ZIndex = 2
	local v4 = label(folder, "YOU GOT A GIFT!", 44, 34, Style.HAZARD, 3, 10)

	local v5 = {}
	local text = "FROM " .. string.upper(p.fromName)
	local v6 = label(folder, text, 24, 92, Style.WHITE, 2, 10)
	local head

	if p.fromId then
		local getTextBoundsParams = Instance.new("GetTextBoundsParams")
		getTextBoundsParams.Text = text
		getTextBoundsParams.Font = Style.FONT
		getTextBoundsParams.Size = 24
		getTextBoundsParams.Width = 1000
		local success, textBoundsAsync = pcall(TextService.GetTextBoundsAsync, TextService, getTextBoundsParams)
		local v7

		if success then
			v7 = textBoundsAsync.X
		else
			v7 = #text * 14
		end

		local v8 = math.min(500, v7 + 8)
		local v9 = (640 - (v8 + 70)) / 2
		local ring = Instance.new("Frame")
		ring.Name = "Ring"
		ring.BackgroundColor3 = Style.HAZARD
		ring.BorderSizePixel = 0
		ring.AnchorPoint = Vector2.new(0.5, 0.5)
		ring.Size = UDim2.fromOffset(60, 60)
		ring.Position = UDim2.fromOffset(v9 + 26 + 4, 92)
		ring.ZIndex = 9
		ring.Parent = folder
		Style.corner(ring, 30)
		head = Instance.new("ImageLabel")
		head.Name = "Head"
		head.BackgroundColor3 = Color3.fromRGB(60, 64, 72)
		head.BorderSizePixel = 0
		head.AnchorPoint = Vector2.new(0.5, 0.5)
		head.Image = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", p.fromId)
		head.Size = UDim2.fromOffset(52, 52)
		head.Position = UDim2.fromScale(0.5, 0.5)
		head.ZIndex = 10
		head.Parent = ring
		Style.corner(head, 26)
		v6.TextXAlignment = Enum.TextXAlignment.Left
		v6.AnchorPoint = Vector2.new(0, 0.5)
		v6.Size = UDim2.fromOffset(v8, 32)
		v6.Position = UDim2.fromOffset(v9 + 52 + 8 + 10, 92)

		table.insert(v5, ring)
	end

	local folder2 = Style.frame(
		folder,
		"Box",
		UDim2.fromOffset(160, 170),
		UDim2.fromOffset(320, 230),
		Vector2.new(0.5, 0.5)
	)
	local _, v7 = drawBox(folder2)
	local open = Instance.new("TextButton")
	open.Name = "Open"
	open.Text = ""
	open.AutoButtonColor = true
	open.BackgroundColor3 = Style.HAZARD
	open.BorderSizePixel = 0
	open.AnchorPoint = Vector2.new(0.5, 0.5)
	local v8 = math.max(56, (math.ceil(44 / v3)))
	local v9 = math.max(200, (math.ceil(160 / v3)))
	open.Size = UDim2.fromOffset(v9, v8)
	open.Position = UDim2.fromOffset(320, 420 - v8 / 2 - 4)
	open.ZIndex = 10
	open.Parent = folder
	Style.corner(open, 8)
	local stroke = Style.stroke(open, 3, 0, Style.INK, true)
	stroke.LineJoinMode = Enum.LineJoinMode.Round
	local label2 = Style.label(open, "Label", "OPEN", 30, Style.FONT, 0)
	label2.AutomaticSize = Enum.AutomaticSize.None
	label2.Size = UDim2.fromScale(1, 1)
	label2.TextXAlignment = Enum.TextXAlignment.Center
	label2.TextColor3 = Style.INK
	label2.ZIndex = 11
	local v10 = { v4, v6, open, label2 }

	if head then
		table.insert(v10, head)
	end

	for _, v11 in v5 do
		table.insert(v10, v11)
	end

	for _, uiStroke in folder:GetDescendants() do
		if uiStroke:IsA("UIStroke") then
			table.insert(v10, uiStroke)
		end
	end

	ClaimAudio.giftIn()
	local now = os.clock()
	local now2 = nil
	local v11 = false
	local function open2() -- 2 equivalent calls inferred from this helper
		if not now2 then
			now2 = os.clock()
			open.Active = false
			ClaimAudio.prizeIn(0.45)
		end
	end
	giftOpen.Activated:Connect(open2)
	open.Activated:Connect(open2)

	local inputBeganConnection = UserInputService.InputBegan:Connect(function(input)
		local keyCode = input.KeyCode

		if
			keyCode == Enum.KeyCode.Return
			or keyCode == Enum.KeyCode.Space
			or keyCode == Enum.KeyCode.ButtonA
			or keyCode == Enum.KeyCode.KeypadEnter
		then
			open2() -- inferred equivalent call
		end
	end)

	Style.animate(giftOpen, function(_: number, p2: number): boolean
		if not giftOpen.Parent then
			inputBeganConnection:Disconnect()
			return false
		end

		local v12 = p2 - now

		local v13 = math.clamp(v12 / 0.3, 0, 1)
		giftOpen.BackgroundTransparency = 1 - v13 * 0.6
		local v14 = math.clamp(v12 / 0.35, 0, 1)
		local v15 = math.sin(v14 * 3.141592653589793) * 0.12 * (1 - v14) + 1
		uiScale.Scale = v3 * (0.6 + 0.4 * Style.easeOut(v14)) * v15
		glow.ImageTransparency = 1 - v13 * 0.55
		glow.Rotation = v12 * 10

		if not now2 and v12 >= 7 then
			open2() -- inferred equivalent call
		end

		if now2 then
			local v16 = p2 - now2

			if v16 < 0.45 then
				local v17 = v16 / 0.45
				folder2.Rotation = math.sin(v16 * 60) * (v17 * 10 + 4)
				folder2.Position = UDim2.fromOffset(math.sin(v16 * 47) * 4 * v17 + 320, 230)

				for _, instance in v10 do
					if instance:IsA("TextLabel") then
						instance.TextTransparency = v17
					elseif instance:IsA("ImageLabel") then
						instance.ImageTransparency = v17
						instance.BackgroundTransparency = v17
					elseif instance:IsA("UIStroke") then
						instance.Transparency = v17
					elseif instance:IsA("GuiObject") then
						instance.BackgroundTransparency = v17
					end
				end

				return true
			else
				if not v11 then
					v11 = true
					ClaimAudio.giftOpen()
					local vector2_2 = Vector2.new(vector2.X, vector2.Y + v3 * 20)
					local v17 = v3 * 32
					ClaimFx.flash(parent, 0.5, 0.3, Color3.fromRGB(255, 220, 150))
					ClaimFx.ring(parent, vector2_2, v17 * 14, v17 * 0.45, Style.HAZARD, 0.5)
					ClaimFx.salvo(parent, vector2_2, v17)
				end

				local v17 = math.clamp((v16 - 0.45) / 0.35, 0, 1)
				v7.Position = UDim2.fromOffset(v17 * 60 + 80, 50 - 260 * Style.easeOut(v17))
				v7.Rotation = v17 * 140
				folder2.Rotation = 0
				folder2.Size = UDim2.fromOffset((v17 * 0.3 + 1) * 160, (v17 * 0.3 + 1) * 170)

				for _, descendant in folder2:GetDescendants() do
					if descendant:IsA("Frame") then
						descendant.BackgroundTransparency = v17
					elseif descendant:IsA("UIStroke") then
						descendant.Transparency = v17
					end
				end

				glow.ImageTransparency = v17 * 0.55 + 0.45
				giftOpen.BackgroundTransparency = v17 * 0.6 + 0.4

				if not (v17 >= 1) then
					return true
				end

				inputBeganConnection:Disconnect()
				giftOpen:Destroy()
				finish(p) -- inferred equivalent call
				return false
			end
		else
			local v16 = v12 % 1.5
			folder2.Rotation = not (v16 < 0.4) and 0
				or math.sin(v16 / 0.4 * 3.141592653589793 * 3) * 6 * (1 - v16 / 0.4)
			folder2.Position = UDim2.fromOffset(320, 230 - math.abs((math.sin(v12 * 2.2))) * 6)
			open.Size = UDim2.fromOffset(v9 + math.sin(v12 * 4) * 8, v8)
			return true
		end
	end)
end

function GiftOpen.play(p, p2)
	if not v then
		v = Style.layer(p, "GiftOpen", 31, true)
	end

	if flag then
		table.insert(v2, p2)
	else
		fn(p2)
	end
end

return GiftOpen