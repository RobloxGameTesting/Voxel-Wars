local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Style = require(script.Parent:WaitForChild("Style"))
local NewMenus = require(script.Parent:WaitForChild("NewMenus"))
local MenuAudio = require(script.Parent:WaitForChild("MenuAudio"))
local ToolIcon = require(script.Parent:WaitForChild("ToolIcon"))
local LoadoutData = require(script.Parent:WaitForChild("LoadoutData"))
local Game = ReplicatedStorage:WaitForChild("Game")
local CareerData = require(Game:WaitForChild("CareerData"))
local WeaponSkins = require(Game:WaitForChild("WeaponSkins"))
local ShopData = require(Game:WaitForChild("ShopData"))

local Rewards = { ["ON"] = nil, ["ON"] = nil, ON = NewMenus.on("Rewards") }

local v = {
	"rbxassetid://78022275319456",
	"rbxassetid://92665377401885",
	"rbxassetid://107302826195863",
	"rbxassetid://93016271554615",
	"rbxassetid://127538301454342",
	"rbxassetid://104593427364266",
	"rbxassetid://136402585885496"
}

local color = Color3.fromRGB(255, 214, 110)

local color2 = Color3.fromRGB(255, 240, 150)
local color3 = Color3.fromRGB(255, 160, 24)

function Rewards.dayImage(value: number)
	return v[math.clamp(value, 1, #v)]
end

local function row(parent, p: number, p2)
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.Padding = UDim.new(0, p)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.HorizontalAlignment = p2 or Enum.HorizontalAlignment.Left
	uiListLayout.Parent = parent
	return uiListLayout
end

local function label(p, p2: string, p3: string, p4: number, p5: number, p6: number, p7: number, p8: number, options)
	local v2 = options or {}
	local label2 = Style.label(p, p2, p3, p4, v2.font or Style.FONT, v2.outline or 0)
	label2.AutomaticSize = Enum.AutomaticSize.None
	label2.Position = UDim2.fromOffset(p5, p6)
	label2.Size = UDim2.fromOffset(p7, p8)
	label2.TextXAlignment = v2.ax or Enum.TextXAlignment.Left
	label2.TextYAlignment = v2.ay or Enum.TextYAlignment.Center
	label2.TextColor3 = v2.color or Style.WHITE
	local uiStroke = label2:FindFirstChildOfClass("UIStroke")

	if uiStroke then
		uiStroke.LineJoinMode = Enum.LineJoinMode.Round
	end

	return label2
end

local function gradient(parent, color4: Color3, color5: Color3) -- 4 equivalent calls inferred from this helper
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Rotation = 90
	uiGradient.Color = ColorSequence.new(color4, color5)
	uiGradient.Parent = parent
	return uiGradient
end

local function glowImage(parent, name: string, imageColor: Color3, p: number, p2: number, p3: number, p4: number)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = name
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://133718950618586"
	imageLabel.ImageColor3 = imageColor
	imageLabel.ImageTransparency = 1
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Size = UDim2.fromOffset(p, p2)
	imageLabel.Position = UDim2.fromOffset(p3, p4)
	imageLabel.Parent = parent
	return imageLabel
end

local function plate(parent, name: string, p: number, p2: number, p3: number)
	local imageButton = Instance.new("ImageButton")
	imageButton.Name = name
	imageButton.BackgroundTransparency = 1
	imageButton.AutoButtonColor = false
	imageButton.Image = "rbxassetid://116067232788719"
	imageButton.AnchorPoint = Vector2.new(0.5, 0.5)
	imageButton.Size = UDim2.fromOffset(p, p2)
	imageButton.Parent = parent
	local v2 = label(imageButton, "Text", "", p3, 0, 0, p, p2, {
		ax = Enum.TextXAlignment.Center,
		outline = 2
	})
	v2.ZIndex = 2
	return imageButton, v2
end

local function feel(data, parent, p: number, p2, fn)
	local punch = Instance.new("UIScale")
	punch.Name = "Punch"
	punch.Parent = parent
	local v2 = false
	local function go(p3: number, p4: number, callback) -- 2 equivalent calls inferred from this helper
		local scale = punch.Scale
		local now = os.clock()
		Style.animate(punch, function(_, p5: number): boolean
			local v3 = math.min((p5 - now) / p4, 1)
			punch.Scale = scale + (p3 - scale) * callback(v3)
			return v3 < 1
		end)
	end
	local function hover(flag: boolean) -- 2 equivalent calls inferred from this helper
		if v2 == flag then
			return
		end

		v2 = flag
		go(not flag and 1 or p, 0.1, Style.easeOut) -- inferred equivalent call

		if p2 then
			p2.BackgroundTransparency = flag and 0.9 or 1
		end

		if flag and MenuAudio.hover then
			MenuAudio.hover()
		end
	end
	data.InputBegan:Connect(function(input)
		local userInputType = input.UserInputType

		if userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.Touch then
			local easeOut = Style.easeOut
			local scale = punch.Scale
			local now = os.clock()
			local v3 = 0.06
			local v4 = 0.94
			Style.animate(punch, function(_, p3: number): boolean
				local v5 = math.min((p3 - now) / v3, 1)
				punch.Scale = scale + (v4 - scale) * easeOut(v5)
				return v5 < 1
			end)
		elseif userInputType == Enum.UserInputType.MouseMovement then
			hover(true) -- inferred equivalent call
		end
	end)
	data.InputEnded:Connect(function(input)
		local userInputType = input.UserInputType

		if userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.Touch then
			go(not v2 and 1 or p, 0.22, Style.pop) -- inferred equivalent call
		elseif userInputType == Enum.UserInputType.MouseMovement then
			if v2 == false then
				return
			end

			v2 = false
			local easeOut = Style.easeOut
			local scale = punch.Scale
			local now = os.clock()
			local v3 = 0.1
			local v4 = 1
			Style.animate(punch, function(_, p3: number): boolean
				local v5 = math.min((p3 - now) / v3, 1)
				punch.Scale = scale + (v4 - scale) * easeOut(v5)
				return v5 < 1
			end)

			if p2 then
				p2.BackgroundTransparency = 1
			end
		end
	end)
	data.SelectionGained:Connect(function()
		hover(true) -- inferred equivalent call
	end)
	data.SelectionLost:Connect(function()
		if v2 == false then
			return
		end

		v2 = false
		local easeOut = Style.easeOut
		local scale = punch.Scale
		local now = os.clock()
		local v3 = 0.1
		local v4 = 1
		Style.animate(punch, function(_, p3: number): boolean
			local v5 = math.min((p3 - now) / v3, 1)
			punch.Scale = scale + (v4 - scale) * easeOut(v5)
			return v5 < 1
		end)

		if p2 then
			p2.BackgroundTransparency = 1
		end
	end)
	data.Activated:Connect(function()
		if fn() then
			if MenuAudio.press then
				MenuAudio.press()
			end
		else
			if MenuAudio.quiet then
				MenuAudio.quiet()
			end

			if MenuAudio.deny then
				MenuAudio.deny()
			end

			local now = os.clock()
			Style.animate(parent, function(_, p3: number): boolean
				local v3 = math.min((p3 - now) / 0.28, 1)
				parent.Rotation = math.sin(v3 * 3.141592653589793 * 5) * 2.2 * (1 - v3)
				return v3 < 1
			end)
		end
	end)
end

local toolsById = {}
local v2 = { 24, 24, 26, 26, 28, 28, 34 }

for _, v3 in LoadoutData do
	for _, item in v3.items do
		if item.tool then
			toolsById[item.id] = item.tool
		end
	end
end

local function primaryTool(player)
	local toolTemplates = ReplicatedStorage:WaitForChild("ToolTemplates")
	local function find(p: string) -- 1 equivalent call inferred from this helper
		local tool = toolTemplates:FindFirstChild(toolsById[p] or p)
		return if tool and tool:IsA("Tool") then tool else nil
	end

	local v3 = player:GetAttribute(ShopData.PRIMARY_ATTR)

	if type(v3) ~= "string" then
		v3 = ShopData.DEFAULT_PRIMARY
	end

	local tool = find(v3) -- inferred equivalent call

	if not tool then
		local DEFAULT_PRIMARY = ShopData.DEFAULT_PRIMARY
		tool = toolTemplates:FindFirstChild(toolsById[DEFAULT_PRIMARY] or DEFAULT_PRIMARY)

		if not (tool and tool:IsA("Tool")) then
			tool = nil
		end
	end

	assert(tool, "[Rewards] no tool for the primary gun")
	return tool
end

function Rewards.build(p, callback, onActivated)
	assert(Rewards.ON, "[Rewards] built while its NewMenus switch is off")
	local count = #CareerData.DAILY
	assert(#v == count, "[Rewards] a prize picture per day of CareerData.DAILY is needed")
	assert(#v2 == count, "[Rewards] an amount size per day of CareerData.DAILY is needed")
	local v3 = WeaponSkins.find(CareerData.DAILY_SKIN)
	assert(v3 and v3.streak, "[Rewards] CareerData.DAILY_SKIN is not a streak skin")
	local player = p.player or Players.LocalPlayer
	local touch = Style.isTouch()

	local layer = Style.layer(p.playerGui, "RewardsBackdrop", 10, true)
	layer.Enabled = false
	local layer2 = Style.layer(p.playerGui, "RewardsWindow", 11)
	layer2.Enabled = false
	local v4 = touch and 1 or 1.3

	local function S(p2: number) -- 2 equivalent calls inferred from this helper
		return (math.floor(p2 * v4))
	end

	local room = Instance.new("ImageLabel")
	room.Name = "Room"
	room.BorderSizePixel = 0
	room.BackgroundColor3 = Style.INK
	room.ScaleType = Enum.ScaleType.Crop
	room.Size = UDim2.fromScale(1, 1)
	room.Active = true
	room.Parent = layer
	local fill = Style.fill(room, "Ink", Style.INK, UDim2.fromScale(1, 1))
	fill.BackgroundTransparency = 0.7
	local v5 = touch and 540 or 700
	local viewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(16, 9)
	local v6 = math.floor(v5 * math.clamp(viewportSize.X / math.max(viewportSize.Y, 1), 1.6, 2.2))
	local region = Style.region(layer2, "Rewards", Vector2.new(0.5, 0.5), Vector2.zero, Vector2.new(v6, v5))
	region.Visible = false
	Style.fit(region, Vector2.new(v6, v5), 0.98)
	local modal = Instance.new("TextButton")
	modal.Name = "Modal"
	modal.Text = ""
	modal.BackgroundTransparency = 1
	modal.Size = UDim2.fromOffset(1, 1)
	modal.Modal = true
	modal.Selectable = false
	modal.Parent = region
	local frame = Style.frame(region, "Body", UDim2.fromScale(1, 1))

	local label2 = Style.label(frame, "Title", "REWARDS", 44, Style.FONT, 2.5)
	label2.TextColor3 = Style.HAZARD
	label2.Position = UDim2.fromOffset(16, 4)

	local v7 = Style.closeButton(frame)
	v7.AnchorPoint = Vector2.new(0.5, 0.5)
	v7.Position = UDim2.new(1, -38, 0, 32)
	v7.Activated:Connect(onActivated)
	feel(v7, v7, 1.045, nil, function(): boolean
		return true
	end)

	local frame2 = Style.frame(
		frame,
		"Right",
		UDim2.fromOffset(v6 - 32 - 44 - 10, 44),
		UDim2.new(1, -70, 0, 10),
		Vector2.new(1, 0)
	)
	row(frame2, 10, Enum.HorizontalAlignment.Right)
	local box = Style.box(frame2, "Boost", Style.GOOD, UDim2.fromOffset(0, 44), 6, 1.5)
	box.AutomaticSize = Enum.AutomaticSize.X
	box.LayoutOrder = 1
	box.Visible = false
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, 10)
	uiPadding.PaddingRight = UDim.new(0, 10)
	uiPadding.Parent = box
	local label3 = Style.label(box, "Text", "", math.floor(v4 * 15), Style.FONT, 0)
	label3.Size = UDim2.fromOffset(0, 44)
	label3.TextColor3 = Style.INK
	local v8 = math.floor(v4 * 176)

	local frame3 = Style.frame(frame2, "DutySlot", UDim2.fromOffset(v8, 44))
	frame3.LayoutOrder = 2
	local box2 = Style.box(frame3, "Duty", Style.INK, UDim2.fromOffset(v8, 44), 6, 1.5)
	box2.AnchorPoint = Vector2.new(0.5, 0.5)
	box2.Position = UDim2.fromScale(0.5, 0.5)
	local fill2 = Style.fill(box2, "Wash", Style.WHITE, UDim2.fromScale(1, 1))
	fill2.BackgroundTransparency = 1
	fill2.ZIndex = 4
	Style.corner(fill2, 6)
	local fill3 = Style.fill(box2, "Glint", Style.WHITE, UDim2.fromScale(1, 1))
	fill3.BackgroundTransparency = 1
	fill3.ZIndex = 3
	Style.corner(fill3, 6)
	local prize = Instance.new("ImageLabel")
	prize.Name = "Prize"
	prize.BackgroundTransparency = 1
	prize.ScaleType = Enum.ScaleType.Fit
	prize.Size = UDim2.fromOffset(34, 34)
	prize.Position = UDim2.fromOffset(5, 5)
	prize.ZIndex = 2
	prize.Parent = box2

	local v9 = v8 - 43 - 8
	local v10 = math.max(12, (math.floor(v4 * 11)))
	local v11 = label(box2, "Title", "ON DUTY", v10, 43, 3, v9, v10 + 3, { color = Style.MUTED })
	v11.ZIndex = 2
	local v12 = label(box2, "Clock", "", math.floor(v4 * 15), 43, v10 + 5, v9, 44 - v10 - 14, {})
	v12.ZIndex = 2
	local fill4 = Style.fill(box2, "Bar", Color3.fromRGB(44, 46, 52), UDim2.fromOffset(v9, 3), UDim2.fromOffset(43, 37))
	fill4.ZIndex = 2
	local fill5 = Style.fill(fill4, "Fill", Style.HAZARD, UDim2.fromScale(0, 1))
	local claimDuty = Instance.new("TextButton")
	claimDuty.Name = "ClaimDuty"
	claimDuty.Text = ""
	claimDuty.BackgroundTransparency = 1
	claimDuty.AutoButtonColor = false
	claimDuty.Size = UDim2.fromScale(1, 1)
	claimDuty.ZIndex = 5
	claimDuty.Parent = box2
	local v13 = false
	feel(claimDuty, box2, 1.045, fill2, function()
		return v13
	end)

	claimDuty.Activated:Connect(function()
		callback("duty", box2)
	end)
	local tween = TweenService:Create(
		fill3,
		TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ BackgroundTransparency = 0.72 }
	)

	local box3 = Style.box(frame2, "Scrap", Style.INK, UDim2.fromOffset(0, 44), 6, 1.5)
	box3.AutomaticSize = Enum.AutomaticSize.X
	box3.LayoutOrder = 3
	row(box3, 7)
	local uiPadding2 = Instance.new("UIPadding")
	uiPadding2.PaddingLeft = UDim.new(0, 10)
	uiPadding2.PaddingRight = UDim.new(0, 14)
	uiPadding2.Parent = box3
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = box3
	local nut = Style.nut(box3, 26)
	nut.LayoutOrder = 1
	local label4 = Style.label(box3, "Amount", "0", 24, Style.FONT, 0)
	label4.TextColor3 = Style.HAZARD
	label4.LayoutOrder = 2
	local label5 = Style.label(frame, "Toast", "", math.floor(v4 * 16), Style.FONT, 2)
	label5.AnchorPoint = Vector2.new(0.5, 0)
	label5.Position = UDim2.new(0.5, 0, 0, 58)
	label5.ZIndex = 5
	label5.Visible = false
	local v14 = math.floor(v4 * 20) + 8
	label(frame, "Daily", "DAILY SUPPLY", math.floor(v4 * 20), 16, 68, 320, v14, { outline = 2 })
	local v15 = label(frame, "Streak", "", math.floor(v4 * 16), v6 - 16 - 320, 68, 320, v14, {
		ax = Enum.TextXAlignment.Right,
		color = Style.HAZARD,
		outline = 2
	})
	v15.Visible = false
	local v16 = touch and 56 or 64
	local v17 = v14 + 68 + 6 + 10
	local v18 = v5 - 16 - v16 - 16 - v17
	local v19 = math.floor((v6 - 32 - (count - 1) * 10) / (count - 1 + 1.5))
	local v20 = math.min(v18, (math.floor(v19 * 2.1)))

	local v21 = v17 + (v18 + 16 - 14 - v20) // 2
	local v22 = math.floor(v4 * 14) + 6
	local v23 = math.max(12, (math.floor(v4 * 12))) + 6
	local v24 = S(v2[count]) + 8 -- inferred equivalent call
	local v25 = v24 + v23 + 10
	local v26 = math.min(v19 - 10, v20 - v22 - 8 - v25)

	local v27 = {}
	local visible = false
	local v28 = 0
	local v29 = nil
	local v30 = nil
	local v31 = nil
	local v32 = 1
	local v34 = false
	local v35 = nil
	local v36 = false

	for i = 1, count do
		local v37 = i == count
		local v38

		if v37 then
			v38 = v6 - 32 - (count - 1) * (v19 + 10)
		else
			v38 = v19
		end

		local textButton = Instance.new("TextButton")
		textButton.Name = "Day" .. i
		textButton.Text = ""
		textButton.AutoButtonColor = false
		textButton.Selectable = true
		textButton.BorderSizePixel = 0
		textButton.BackgroundColor3 = Color3.new(1, 1, 1)
		textButton.AnchorPoint = Vector2.new(0.5, 0.5)
		textButton.Size = UDim2.fromOffset(v38, v20)
		local udim = UDim2.fromOffset((i - 1) * (v19 + 10) + 16 + v38 // 2, v21 + v20 // 2)
		textButton.Position = udim
		textButton.Parent = frame
		Style.corner(textButton, 6)

		if v37 then
			gradient(textButton, Color3.fromRGB(112, 82, 28), Color3.fromRGB(34, 24, 10)) -- inferred equivalent call
		else
			gradient(textButton, Color3.fromRGB(54, 58, 66), Color3.fromRGB(22, 23, 27)) -- inferred equivalent call
		end

		local stroke = Style.stroke(textButton, 2, 0, Style.INK, true)
		local v39 = v22 + 6 + (v20 - v22 - 8 - v25 - v26) // 2
		local v41 = if v37 then color else Style.HAZARD
		local glow = glowImage(
			textButton,
			"Glow",
			v41,
			math.floor(v26 * 1.5),
			math.floor(v26 * 1.5),
			v38 // 2,
			v39 + v26 // 2
		)
		local prize2 = Instance.new("ImageLabel")
		prize2.Name = "Prize"
		prize2.BackgroundTransparency = 1
		prize2.ScaleType = Enum.ScaleType.Fit
		prize2.AnchorPoint = Vector2.new(0.5, 0)
		local v43

		if v37 then
			v43 = math.min(v38 - 10, (math.floor(v26 * 1.2)))
		else
			v43 = v26
		end

		prize2.Size = UDim2.fromOffset(v43, v26)
		prize2.Position = UDim2.fromOffset(v38 // 2, v39)
		prize2.ZIndex = 2
		prize2.Parent = textButton
		local day = label(textButton, "Day", "DAY " .. i, math.floor(v4 * 14), 0, 5, v38, v22, {
			ax = Enum.TextXAlignment.Center,
			color = Style.MUTED,
			outline = 2
		})
		day.ZIndex = 3

		local v45 = S(v2[i]) -- inferred equivalent call
		local v46 = v20 - v25 + v24 // 2
		local amountGlow = glowImage(
			textButton,
			"AmountGlow",
			Style.HAZARD,
			math.floor(v38 * 1.15),
			math.floor(v24 * 2.4),
			v38 // 2,
			v46
		)
		amountGlow.ZIndex = 2
		local frame4 = Style.frame(
			textButton,
			"Amount",
			UDim2.fromOffset(0, v24),
			UDim2.fromOffset(v38 // 2, v46),
			Vector2.new(0.5, 0.5)
		)
		frame4.AutomaticSize = Enum.AutomaticSize.X
		frame4.ZIndex = 3
		row(frame4, 5)
		local uiScale2 = Instance.new("UIScale")
		uiScale2.Parent = frame4
		local nut_2 = Style.nut(frame4, (math.floor(v45 * 0.86)))
		nut_2.LayoutOrder = 1
		local label6 = Style.label(frame4, "N", Style.thousands(CareerData.DAILY[i]), v45, Style.FONT, 2.5)
		label6.TextColor3 = Style.WHITE
		label6.LayoutOrder = 2
		local uiStroke = label6:FindFirstChildOfClass("UIStroke")

		if uiStroke then
			uiStroke.LineJoinMode = Enum.LineJoinMode.Round
		end

		local amountGradient = gradient(label6, color2, color3) -- inferred equivalent call
		local state = label(textButton, "State", "", math.max(12, (math.floor(v4 * 12))), 0, v20 - v23 - 6, v38, v23, {
			ax = Enum.TextXAlignment.Center,
			color = Style.GOOD,
			outline = 2
		})
		state.ZIndex = 3
		state.Visible = false

		if v37 then
			v31 = Style.frame(
				textButton,
				"Skin",
				UDim2.fromOffset(v38 - 12, v26),
				UDim2.fromOffset(v38 // 2, v39),
				Vector2.new(0.5, 0)
			)
			v31.ZIndex = 2
			v31.Visible = false
			v35 = label(textButton, "SkinName", v3.name, math.floor(v4 * 26), 0, v46 - v24 // 2, v38, v24, {
				ax = Enum.TextXAlignment.Center,
				outline = 2.5
			})
			v35.ZIndex = 3
			v35.Visible = false
			gradient(v35, color2, color3) -- inferred equivalent call
		end

		local v50 = math.floor(math.min(v26, v38) * 0.6)
		local claimed = Instance.new("ImageLabel")
		claimed.Name = "Claimed"
		claimed.BackgroundTransparency = 1
		claimed.Image = "rbxassetid://99834261274361"
		claimed.ScaleType = Enum.ScaleType.Fit
		claimed.AnchorPoint = Vector2.new(0.5, 0.5)
		claimed.Size = UDim2.fromOffset(v50, v50)
		claimed.Position = UDim2.fromOffset(v38 // 2, v39 + v26 // 2)
		claimed.ZIndex = 5
		claimed.Visible = false
		claimed.Parent = textButton
		local uiScale3 = Instance.new("UIScale")
		uiScale3.Parent = claimed
		local fill6 = Style.fill(textButton, "Wash", Style.WHITE, UDim2.fromScale(1, 1))
		fill6.BackgroundTransparency = 1
		fill6.ZIndex = 4
		Style.corner(fill6, 6)
		local tween2 = TweenService:Create(
			glow,
			TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{ ImageTransparency = 0.72 }
		)
		table.insert(v27, {
			button = textButton,
			stroke = stroke,
			glow = glow,
			pic = prize2,
			day = day,
			amountRow = frame4,
			amount = label6,
			amountGradient = amountGradient,
			amountGlow = amountGlow,
			amountBeat = TweenService:Create(
				uiScale2,
				TweenInfo.new(0.55, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
				{ Scale = 1.1 }
			),
			amountScale = uiScale2,
			state = state,
			home = udim,
			pulse = tween2,
			check = claimed,
			checkScale = uiScale3,
			done = nil
		})

		feel(textButton, textButton, 1.045, fill6, function()
			return visible and i == v28
		end)

		textButton.Activated:Connect(function()
			if visible and i == v28 then
				callback("daily", v29)
			end
		end)
	end

	local v37 = math.min(v6 - 32, (math.floor(v16 * 6.5)))

	local v38 = v21 + v20 + 14 + v16 // 2

	local v39 = glowImage(frame, "ClaimGlow", Style.HAZARD, math.floor(v37 * 1.5), math.floor(v16 * 2.6), v6 // 2, v38)
	v39.ImageTransparency = 0.45
	v39.Visible = false
	local tween2 = TweenService:Create(
		v39,
		TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ ImageTransparency = 0.75 }
	)
	local v40, v41 = plate(frame, "ClaimDaily", v37, v16, math.floor(v4 * 26))
	v29 = v40
	v29.Position = UDim2.fromOffset(v6 // 2, v38)
	feel(v29, v29, 1.03, nil, function()
		return visible
	end)

	v29.Activated:Connect(function()
		callback("daily", v29)
	end)

	local function setPlate(p2, p3, selectable: boolean, text: string) -- 1 equivalent call inferred from this helper
		local image = selectable and "rbxassetid://98153179041297" or "rbxassetid://116067232788719"

		if p2.Image ~= image then
			p2.Image = image
		end

		p2.Selectable = selectable
		local textColor

		if selectable then
			textColor = Style.WHITE
		else
			textColor = Style.MUTED
		end

		p3.TextColor3 = textColor

		if p3.Text ~= text then
			p3.Text = text
		end
	end

	local function drawSkin()
		if v30 then
			return
		end

		local v43 = ToolIcon.make(primaryTool(player), v31)
		v43.Size = UDim2.fromScale(1, 1)
		local model = v43:FindFirstChildOfClass("Model")
		assert(model, "[Rewards] the gun's picture has no model")
		WeaponSkins.paint(model, v3.id)
		v30 = v43
	end

	local v43 = ""
	local v44 = ""
	local v45 = false
	local function refresh(data)
		local daily = data.daily

		if daily then
			visible = daily.can == true
			local v46

			if daily.can then
				v46 = daily.nextDay
			else
				v46 = math.min((daily.day or 0) + 1, count)
			end

			local v47

			if daily.can then
				v47 = v46 - 1
			else
				v47 = daily.day or 0
			end

			v28 = not visible and 0 or v46
			v32 = math.clamp(v46, 1, count)

			local visible2 = daily.gaveSkin == true or not WeaponSkins.ownsCrate(player, v3.id)
			local v49 = string.format(
				"%d %d %s %d %s",
				v46,
				v47,
				tostring(daily.can),
				daily.streak,
				(tostring(visible2))
			)

			if v49 ~= v43 then
				v43 = v49
				v34 = visible2

				for k, v50 in v27 do
					local v51 = k <= v47
					local v52 = k == v46 and visible
					local v53 = k == count and visible2
					v50.pic.Visible = not v53
					v50.pic.ImageTransparency = v51 and 0.62 or 0

					if v51 and v50.done == false and v45 then
						task.delay(2.5, function()
							if v50.done then
								v50.check.Visible = true
								v50.checkScale.Scale = 2.2
								TweenService:Create(
									v50.checkScale,
									TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
									{ Scale = 1 }
								):Play()

								if MenuAudio.press then
									MenuAudio.press()
								end
							end
						end)
					else
						v50.check.Visible = v51
						v50.checkScale.Scale = 1
					end

					v50.done = v51
					v50.amountRow.Visible = not v53
					v50.amountGradient.Enabled = not v51
					local amount = v50.amount
					local textColor

					if v51 then
						textColor = Style.MUTED
					else
						textColor = Style.WHITE
					end

					amount.TextColor3 = textColor
					v50.amountGlow.ImageTransparency = v51 and 1 or (v52 or k == count) and 0.55 or 0.8
					v50.state.Visible = v51 or v53
					v50.state.Text = v51 and "TAKEN" or "GUN SKIN"
					local state = v50.state
					local textColor2 = if v51 then Style.GOOD else color
					state.TextColor3 = textColor2
					local day = v50.day
					local textColor3

					if k == v46 and not v51 then
						textColor3 = Style.WHITE
					else
						textColor3 = Style.MUTED
					end

					day.TextColor3 = textColor3
					local stroke = v50.stroke
					local color4

					if v52 then
						color4 = Style.HAZARD
					else
						color4 = Style.INK
					end

					stroke.Color = color4
					v50.stroke.Thickness = v52 and 3 or 2
					local button = v50.button
					local position

					if v52 then
						position = v50.home - UDim2.fromOffset(0, 10)
					else
						position = v50.home
					end

					button.Position = position
					v50.pulse:Cancel()
					v50.amountBeat:Cancel()
					v50.amountScale.Scale = 1
					v50.glow.ImageTransparency = v52 and 0.35 or k == count and not v51 and 0.7 or 1

					if not (v52 and v45) then
						continue
					end

					v50.pulse:Play()
					v50.amountBeat:Play()
				end

				v31.Visible = visible2
				v35.Visible = visible2
				v35.TextTransparency = count <= v47 and 0.45 or 0

				if visible2 and v45 then
					drawSkin()
				end

				if v30 then
					v30.ImageTransparency = count <= v47 and 0.62 or 0
				end

				v15.Visible = daily.streak > 0
				v15.Text = "STREAK " .. tostring(daily.streak)
			end

			local v50 = v29
			local selectable = visible
			local v52

			if visible then
				v52 = "CLAIM DAY " .. v46
			else
				v52 = "NEXT " .. Style.duration(daily.resetIn)
			end

			setPlate(v50, v41, selectable, v52) -- inferred equivalent call

			if v39.Visible ~= visible then
				v39.Visible = visible

				if visible then
					v39.ImageTransparency = 0.45
					tween2:Play()
				else
					tween2:Cancel()
				end
			end
		end

		local duty = data.duty

		if duty then
			local selectable = duty.ready > 0
			v13 = selectable
			local v47 = math.clamp(duty.progress, 0, 1)

			if fill5.Size.X.Scale ~= v47 then
				fill5.Size = UDim2.fromScale(v47, 1)
			end

			local text

			if selectable then
				text = "CLAIM " .. Style.thousands(duty.ready * CareerData.DUTY.scrap)
			else
				text = not (duty.left > 0) and "FULL" or "NEXT " .. Style.duration(duty.left)
			end

			if v12.Text ~= text then
				v12.Text = text
			end

			local v49 = tostring(selectable) .. tostring(v45)

			if v49 ~= v44 then
				v44 = v49
				local backgroundColor

				if selectable then
					backgroundColor = Style.HAZARD
				else
					backgroundColor = Style.INK
				end

				box2.BackgroundColor3 = backgroundColor
				local textColor

				if selectable then
					textColor = Color3.fromRGB(70, 52, 8)
				else
					textColor = Style.MUTED
				end

				v11.TextColor3 = textColor
				local textColor2

				if selectable then
					textColor2 = Style.INK
				else
					textColor2 = Style.WHITE
				end

				v12.TextColor3 = textColor2
				fill4.Visible = not selectable
				claimDuty.Selectable = selectable
				tween:Cancel()
				fill3.BackgroundTransparency = 1

				if selectable and v45 then
					tween:Play()
				end
			end
		end

		local v46 = (data.boostUntil or 0) - (data.now or 0)

		if v36 and daily then
			v36 = false
			local PadMenus = require(script.Parent:WaitForChild("PadMenus"))
			PadMenus.reseat()
		end

		box.Visible = v46 > 0

		if v46 > 0 then
			label3.Text = "DOUBLE XP  ·  " .. Style.duration(v46)
		end
	end

	local count2 = 0
	local tweens = {}
	local position = frame.Position
	local v46 = false
	return {
		root = region,
		pop = function(_: number) end,
		scrap = label4,
		scrapPop = uiScale,
		toast = label5,
		refresh = refresh,
		show = function(flag: boolean)
			v45 = flag
			count2 += 1
			local v47 = count2

			for _, v48 in tweens do
				v48:Cancel()
			end

			table.clear(tweens)
			local function tween3(instance, duration: number, p2, p3, goal) -- 5 equivalent calls inferred from this helper
				local tween4 = TweenService:Create(instance, TweenInfo.new(duration, p2, p3), goal)
				table.insert(tweens, tween4)
				tween4:Play()
				return tween4
			end

			if flag then
				if not v46 then
					v46 = true
					room.Image = "rbxassetid://83903595171242"

					for k, v48 in v27 do
						v48.pic.Image = v[k]
					end

					prize.Image = CareerData.STORE.scrap[1].image
				end

				if not layer.Enabled then
					room.ImageTransparency = 1
					room.BackgroundTransparency = 1
					fill.BackgroundTransparency = 1
				end

				frame.Position = position + UDim2.fromScale(0, 0.22)
				layer.Enabled = true
				layer2.Enabled = true
				v43 = ""
				v44 = ""
				v36 = true
				tween3(room, 0.256, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, { -- inferred equivalent call
					ImageTransparency = 0,
					BackgroundTransparency = 0
				})
				tween3(fill, 0.256, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, { -- inferred equivalent call
					BackgroundTransparency = 0.7
				})
				tween3(frame, 0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, { -- inferred equivalent call
					Position = position
				})
			else
				layer2.Enabled = false

				for _, v48 in v27 do
					v48.pulse:Cancel()
					v48.amountBeat:Cancel()
					v48.amountScale.Scale = 1
				end

				tween:Cancel()
				tween3(room, 0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.In, { -- inferred equivalent call
					ImageTransparency = 1,
					BackgroundTransparency = 1
				})
				tween3(fill, 0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.In, { -- inferred equivalent call
					BackgroundTransparency = 1
				}).Completed:Once(function()
					if count2 == v47 then
						layer.Enabled = false
					end
				end)
			end
		end,
		first = function()
			if visible then
				return v29
			end

			if v13 then
				return claimDuty
			end

			return v27[v32].button
		end
	}
end

return Rewards