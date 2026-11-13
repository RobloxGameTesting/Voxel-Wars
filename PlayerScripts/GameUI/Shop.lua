local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ToolTemplates = ReplicatedStorage2:WaitForChild("ToolTemplates")
local UserInputService = game:GetService("UserInputService")

local Style = require(script.Parent:WaitForChild("Style"))
local ToolIcon = require(script.Parent:WaitForChild("ToolIcon"))
local StreakIcon = require(script.Parent:WaitForChild("StreakIcon"))
local LoadoutData = require(script.Parent:WaitForChild("LoadoutData"))
local ShopData = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("ShopData"))
local Skins = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("Skins"))
local SkinPreview = require(script.Parent:WaitForChild("SkinPreview"))
local Glyph = require(script.Parent:WaitForChild("Glyph"))
local Armory = require(script.Parent:WaitForChild("Armory"))

local Shop = {}

local b = Enum.KeyCode.B
local n = Enum.KeyCode.N

local v = Style.isTouch() and 22 or 14
local textColor2

if Style.isTouch() then
	textColor2 = Style.WHITE
else
	textColor2 = Style.MUTED
end

local color = Color3.fromRGB(38, 40, 45)
local color2 = Color3.fromRGB(26, 27, 31)

local function validate()
	local idSet = {}

	for _, v2 in LoadoutData do
		local v3 = type(v2.id) == "string" and type(v2.title) == "string" and type(v2.items) == "table"
		assert(v3, "GameUI: bad shop tab")

		for _, item in v2.items do
			local v4 = type(item.id) == "string" and not idSet[item.id]
			assert(v4, "GameUI: shop item id missing or repeated: " .. tostring(item.id))
			idSet[item.id] = true
			local v5 = type(item.name) == "string" and type(item.description) == "string"
			assert(v5, "GameUI: shop item " .. item.id .. " needs a name and description")
			assert(ShopData.ITEMS[item.id], "GameUI: shop item " .. item.id .. " is not in ShopData")

			if not item.tool then
				continue
			end

			local tool = ToolTemplates:FindFirstChild(item.tool)
			assert(tool and tool:IsA("Tool"), "GameUI: shop item " .. item.id .. " names a missing tool " .. item.tool)
		end
	end
end

local function picture(data, p, udim: UDim2, udim2: UDim2)
	if data.tool then
		local frame = Style.frame(p, "Picture", udim, udim2)
		ToolIcon.voxel(ToolTemplates:FindFirstChild(data.tool), frame, Style.WHITE)
		return frame
	elseif StreakIcon.has(data.id) then
		local frame = Style.frame(p, "Picture", udim, udim2)
		StreakIcon.voxel(data.id, frame, Style.WHITE)
		return frame
	else
		local frame = Style.frame(p, "Icon", udim, udim2)
		local label = Style.label(frame, "Text", string.upper((string.sub(data.name, 1, 1))), 44, Style.FONT, 0)
		label.AutomaticSize = Enum.AutomaticSize.None
		label.Size = UDim2.fromScale(1, 1)
		label.TextColor3 = Style.STEEL_LIGHT
		return frame
	end
end

local function lockOverlay(p, udim: UDim2, udim2: UDim2, p2: number, zIndex: number)
	local folder = Style.fill(p, "Locked", Style.INK, udim, udim2)
	folder.BackgroundTransparency = 0.42
	Style.corner(folder, 3)
	local frame = Style.frame(
		folder,
		"Lock",
		UDim2.fromOffset((math.round)(p2 * 1.15), ((math.round)(p2 * 1.6))),
		UDim2.fromScale(0.5, 0.5),
		Vector2.new(0.5, 0.5)
	)
	local frame2 = Style.frame(
		frame,
		"Shackle",
		UDim2.fromOffset((math.round)(p2 * 0.72), ((math.round)(p2 * 1))),
		UDim2.fromScale(0.5, 0),
		Vector2.new(0.5, 0)
	)
	Style.corner(frame2, p2)
	Style.stroke(frame2, math.max(3, ((math.round)(p2 * 0.16))), 0, Style.STEEL_LIGHT, true)
	local box = Style.box(frame, "Body", Style.HAZARD, UDim2.new(1, 0, 0, p2), 3, 2)
	box.AnchorPoint = Vector2.new(0, 1)
	box.Position = UDim2.fromScale(0, 1)
	local fill = Style.fill(
		box,
		"Keyhole",
		Style.INK,
		UDim2.fromOffset((math.round)(p2 * 0.26), ((math.round)(p2 * 0.26))),
		UDim2.fromScale(0.5, 0.4),
		Vector2.new(0.5, 0.5)
	)
	Style.corner(fill, p2)
	Style.fill(
		box,
		"Slot",
		Style.INK,
		UDim2.fromOffset(math.max(2, ((math.round)(p2 * 0.1))), ((math.round)(p2 * 0.3))),
		UDim2.fromScale(0.5, 0.45),
		Vector2.new(0.5, 0)
	)
	folder.ZIndex = zIndex

	for _, guiObject in folder:GetDescendants() do
		if guiObject:IsA("GuiObject") then
			guiObject.ZIndex = zIndex + 1
		end
	end

	return folder
end

local function brackets(textButton, hazard: Color3, p: number)
	for _, v2 in {
		{ 0, 0 },
		{ 1, 0 },
		{ 0, 1 },
		{ 1, 1 }
	} do
		local udim = UDim2.new(v2[1], v2[1] == 0 and 4 or -4, v2[2], v2[2] == 0 and 4 or -4)
		local fill = Style.fill(textButton, "CornerH", hazard, UDim2.fromOffset(p, 3), udim, Vector2.new(v2[1], v2[2]))
		local fill2 = Style.fill(textButton, "CornerV", hazard, UDim2.fromOffset(3, p), udim, Vector2.new(v2[1], v2[2]))
		fill.ZIndex = 2
		fill2.ZIndex = 2
	end
end

local function row(parent, name: string, p: number, flag: boolean?) -- 5 equivalent calls inferred from this helper
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.Name = name
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

	if flag then
		uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	end

	uiListLayout.Padding = UDim.new(0, p)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = parent
	return uiListLayout
end

local function costContent(button, p: number)
	local frame = Style.frame(button, "Content", UDim2.fromScale(1, 1))
	row(frame, "Row", 6, true)
	local label = Style.label(frame, "Text", "", p, Style.FONT, 0)
	label.LayoutOrder = 1
	local nut = Style.nut(frame, p - 2)
	nut.LayoutOrder = 2
	local label2 = Style.label(frame, "Amount", "", p, Style.FONT, 0)
	label2.LayoutOrder = 3
	return function(text: string, p2: number?, textColor: Color3, value: string?)
		label.Text = text
		label.Visible = text ~= ""
		label.TextColor3 = textColor
		nut.Visible = p2 ~= nil
		label2.Visible = p2 ~= nil
		label2.Text = not p2 and "" or Style.thousands(p2) .. (value or "")
		label2.TextColor3 = textColor
	end
end

local function pips(box, p: number, vector2: Vector2)
	local frame = Style.frame(box, "Pips", UDim2.fromOffset(p * (vector2.X + 3), vector2.Y))
	row(frame, "Row", 3) -- inferred equivalent call
	local fills = {}

	for i = 1, p do
		local fill = Style.fill(frame, "Pip", color2, UDim2.fromOffset(vector2.X, vector2.Y))
		fill.LayoutOrder = i
		Style.stroke(fill, 1, 0, Style.INK, true)
		fills[i] = fill
	end

	return function(p2: number)
		for k, v2 in fills do
			local backgroundColor

			if k <= p2 then
				backgroundColor = Style.HAZARD
			else
				backgroundColor = color2
			end

			v2.BackgroundColor3 = backgroundColor
		end
	end
end

function Shop.new(p, instance, callback)
	validate()

	local v2 = Style.isTouch() and 1.2 or 1
	local v3 = Style.isTouch() and 0 or 8
	local region = Style.region(
		p,
		"ShopButton",
		Vector2.new(0, 0.5),
		Vector2.new(12, 0),
		Vector2.new(math.round(v2 * 112) + v3, (math.round(v2 * 48)))
	)
	local button = Style.button(
		region,
		"Open",
		"",
		Style.STEEL,
		UDim2.fromOffset(math.round(v2 * 106) + v3, (math.round(v2 * 42))),
		Style.WHITE,
		(math.round(v2 * 18))
	)
	local tape = Style.tape(button, "Tape", UDim2.new(0, math.round(v2 * 6), 1, 0), 60, 10)
	tape.Rotation = 0
	local frame = Style.frame(
		button,
		"Face",
		UDim2.new(1, -math.round(v2 * 10), 1, 0),
		UDim2.fromOffset(math.round(v2 * 10), 0)
	)
	row(frame, "Row", math.round(v2 * 6), true)
	local nut_2 = Style.nut(frame, (math.round(v2 * 18)))
	nut_2.LayoutOrder = 1
	local label_2 = Style.label(frame, "Text", "GUNS", math.round(v2 * 19), Style.FONT, 1.5)
	label_2.LayoutOrder = 2

	if not Style.isTouch() then
		local cap = Glyph.cap(frame, "B", Enum.KeyCode.DPadLeft, 18)
		cap.LayoutOrder = 3
	end

	local button2 = Style.button(region, "Store", "", Style.STEEL, button.Size, Style.WHITE, (math.round(v2 * 18)))
	button2.Position = UDim2.fromOffset(0, math.round(v2 * 48) + math.round(v2 * 4))
	local tape_2 = Style.tape(button2, "Tape", UDim2.new(0, math.round(v2 * 6), 1, 0), 60, 10)
	tape_2.Rotation = 0
	local frame2 = Style.frame(
		button2,
		"Face",
		UDim2.new(1, -math.round(v2 * 10), 1, 0),
		UDim2.fromOffset(math.round(v2 * 10), 0)
	)
	row(frame2, "Row", math.round(v2 * 6), true)

	if not Style.isTouch() then
		local cap = Glyph.cap(frame2, "N", Enum.KeyCode.DPadRight, 18)
		cap.LayoutOrder = 3
	end

	local cart = Instance.new("ImageLabel")
	cart.Name = "Cart"
	cart.BackgroundTransparency = 1
	cart.Image = "rbxassetid://127842047588461"
	cart.ImageColor3 = Style.HAZARD
	cart.Size = UDim2.fromOffset(math.round(v2 * 22), (math.round(v2 * 22)))
	cart.LayoutOrder = 1
	cart.Parent = frame2
	local label_3 = Style.label(frame2, "Text", "STORE", math.round(v2 * 19), Style.FONT, 1.5)
	label_3.LayoutOrder = 2

	local region2 = Style.region(p, "Shop", Vector2.new(0.5, 0.5), Vector2.zero, Vector2.new(880, 540))
	region2.Visible = false
	local fit = Style.fit(region2, Vector2.new(880, 540))
	local modal = Instance.new("TextButton")
	modal.Name = "Modal"
	modal.Text = ""
	modal.BackgroundTransparency = 1
	modal.Size = UDim2.fromOffset(1, 1)
	modal.Modal = true
	modal.Parent = region2

	local box = Style.box(region2, "Bench", Style.PANEL, UDim2.fromScale(1, 1), 3, 3)
	box.BackgroundTransparency = 0.04
	box.Active = true

	local fill = Style.fill(box, "Header", Style.STEEL, UDim2.new(1, 0, 0, 64))
	local tape_3 = Style.tape(fill, "Tape", UDim2.new(1, 0, 0, 8), 880, 16)
	tape_3.Position = UDim2.fromOffset(0, 0)
	local label = Style.label(fill, "Title", "SCRAPYARD SHOP", 13, Style.FONT, 0)
	label.TextColor3 = Style.MUTED
	label.Position = UDim2.fromOffset(16, 12)
	local frame3 = Style.frame(fill, "Tabs", UDim2.new(1, -250, 0, 34), UDim2.fromOffset(12, 28))
	local uiListLayout2 = row(frame3, "Row", 6) -- inferred equivalent call
	uiListLayout2.VerticalAlignment = Enum.VerticalAlignment.Top

	local box2 = Style.box(fill, "Scrap", Style.INK, UDim2.fromOffset(0, 32), 3, 1.5)
	box2.AutomaticSize = Enum.AutomaticSize.X
	box2.AnchorPoint = Vector2.new(1, 0)
	box2.Position = UDim2.new(1, -60, 0, 20)
	row(box2, "Row", 6) -- inferred equivalent call
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, 8)
	uiPadding.PaddingRight = UDim.new(0, 10)
	uiPadding.Parent = box2
	local nut_3 = Style.nut(box2, 20)
	nut_3.LayoutOrder = 1
	local label2 = Style.label(box2, "Amount", "0", 20, Style.FONT, 0)
	label2.TextColor3 = Style.HAZARD
	label2.LayoutOrder = 2

	local button3 = Style.button(fill, "Close", "X", Style.ORANGE, UDim2.fromOffset(36, 36), Style.INK, 20)
	button3.AnchorPoint = Vector2.new(1, 0)
	button3.Position = UDim2.new(1, -12, 0, 18)

	local crates = Instance.new("ScrollingFrame")
	crates.Name = "Crates"
	crates.BackgroundTransparency = 1
	crates.BorderSizePixel = 0
	crates.Position = UDim2.fromOffset(12, 78)
	crates.Size = UDim2.new(0, 456, 1, -92)
	crates.ScrollBarThickness = 6
	crates.ScrollBarImageColor3 = Style.HAZARD
	crates.CanvasSize = UDim2.new()
	crates.AutomaticCanvasSize = Enum.AutomaticSize.Y
	crates.Parent = box
	local uiPadding2 = Instance.new("UIPadding")
	uiPadding2.PaddingTop = UDim.new(0, 4)
	uiPadding2.PaddingLeft = UDim.new(0, 6)
	uiPadding2.Parent = crates
	local uiGridLayout = Instance.new("UIGridLayout")
	uiGridLayout.CellSize = UDim2.fromOffset(136, 158)
	uiGridLayout.CellPadding = UDim2.fromOffset(12, 12)
	uiGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiGridLayout.Parent = crates
	local label3 = Style.label(box, "Empty", "", 17, Style.FONT, 1.5)
	label3.TextColor3 = Style.MUTED
	label3.AnchorPoint = Vector2.new(0.5, 0.5)
	label3.Position = UDim2.new(0, 240, 0.5, 32)

	local box3 = Style.box(box, "Pegboard", color, UDim2.new(0, 388, 1, -92), 3, 2)
	box3.AnchorPoint = Vector2.new(1, 0)
	box3.Position = UDim2.new(1, -12, 0, 78)

	for i = 0, 2 do
		for j = 0, 6 do
			local fill2 = Style.fill(
				box3,
				"Hole",
				color2,
				UDim2.fromOffset(5, 5),
				UDim2.new((j + 0.5) / 7, 0, 0, i * 30 + 12),
				Vector2.new(0.5, 0.5)
			)
			Style.corner(fill2, 3)
		end
	end

	local frame4 = Style.frame(box3, "Picture", UDim2.new(1, -20, 0, 92), UDim2.fromOffset(10, 6))
	local box4 = Style.box(box3, "Slot", Style.HAZARD, UDim2.fromOffset(0, 18), 2, 1)
	box4.AutomaticSize = Enum.AutomaticSize.X
	box4.Position = UDim2.fromOffset(14, 102)
	local uiPadding3 = Instance.new("UIPadding")
	uiPadding3.PaddingLeft = UDim.new(0, 5)
	uiPadding3.PaddingRight = UDim.new(0, 5)
	uiPadding3.Parent = box4
	local label4 = Style.label(box4, "Text", "", 11, Style.FONT, 0)
	label4.Size = UDim2.fromOffset(0, 18)
	label4.TextColor3 = Style.INK
	local label5 = Style.label(box3, "Owned", "OWNED", 12, Style.FONT, 0)
	label5.AnchorPoint = Vector2.new(1, 0)
	label5.Position = UDim2.new(1, -14, 0, 102)
	label5.TextColor3 = Style.GOOD
	local label6 = Style.label(box3, "Name", "", 24, Style.FONT, 1.5)
	label6.Position = UDim2.fromOffset(14, 122)
	local label7 = Style.label(box3, "Description", "", v, Style.FONT_BODY, 0)
	label7.AutomaticSize = Enum.AutomaticSize.None
	label7.Size = UDim2.new(1, -28, 0, 50)
	label7.Position = UDim2.fromOffset(14, 152)
	label7.TextWrapped = true
	label7.TextXAlignment = Enum.TextXAlignment.Left
	label7.TextYAlignment = Enum.TextYAlignment.Top
	label7.TextColor3 = textColor2

	local label8 = Style.label(box3, "UpgradesTitle", "UPGRADES", 12, Style.FONT, 0)
	label8.Position = UDim2.fromOffset(14, 206)
	label8.TextColor3 = Style.MUTED
	local fill2 = Style.fill(box3, "Rule", Style.STEEL, UDim2.new(1, -110, 0, 2), UDim2.new(0, 92, 0, 215))

	local frame5 = Style.frame(box3, "Upgrades", UDim2.new(1, -24, 0, 144), UDim2.fromOffset(12, 224))
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.Padding = UDim.new(0, 0)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = frame5
	local label9 = Style.label(box3, "NoUpgrades", "NO UPGRADES", 14, Style.FONT_BODY, 0)
	label9.Position = UDim2.fromOffset(14, 228)
	label9.TextColor3 = Style.DIM

	local frame6 = Style.frame(box3, "Outfit", UDim2.fromScale(1, 1))
	frame6.Visible = false
	local box5 = Style.box(frame6, "Stage", color2, UDim2.new(1, -20, 0, 236), 3, 1.5)
	box5.Position = UDim2.fromOffset(10, 10)
	box5.ClipsDescendants = true
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Rotation = 90
	uiGradient.Color = ColorSequence.new(color2, color)
	uiGradient.Parent = box5
	local view = SkinPreview.view(box5, "full")
	local label10 = Style.label(box5, "NoBody", "DEPLOY TO SEE YOUR SOLDIER", 14, Style.FONT, 0)
	label10.AnchorPoint = Vector2.new(0.5, 0.5)
	label10.Position = UDim2.fromScale(0.5, 0.5)
	label10.TextColor3 = Style.DIM
	local label11 = Style.label(box5, "Hint", "DRAG TO TURN", 11, Style.FONT, 0)
	label11.AnchorPoint = Vector2.new(1, 1)
	label11.Position = UDim2.new(1, -8, 1, -6)
	label11.TextColor3 = Style.DIM
	local frame7 = Style.frame(box5, "Camo", UDim2.fromOffset(130, 24), UDim2.fromOffset(8, 8))
	row(frame7, "Row", 4) -- inferred equivalent call
	local v4 = {}
	local v5 = {
		frame4,
		box4,
		label5,
		label6,
		label7,
		label8,
		fill2,
		frame5,
		label9
	}

	for k, team in { "Reds", "Blues" } do
		local button4, label12 = Style.button(
			frame7,
			team,
			string.upper(team),
			Style.PANEL,
			UDim2.fromOffset(60, 24),
			Style.MUTED,
			13
		)
		button4.LayoutOrder = k
		button4.ZIndex = 3
		label12.ZIndex = 3
		table.insert(v4, { button = button4, label = label12, team = team })
	end

	local box6 = Style.box(frame6, "Level", Style.HAZARD, UDim2.fromOffset(0, 18), 2, 1)
	box6.AutomaticSize = Enum.AutomaticSize.X
	box6.Position = UDim2.fromOffset(14, 256)
	local uiPadding4 = Instance.new("UIPadding")
	uiPadding4.PaddingLeft = UDim.new(0, 5)
	uiPadding4.PaddingRight = UDim.new(0, 5)
	uiPadding4.Parent = box6
	local label12 = Style.label(box6, "Text", "", 11, Style.FONT, 0)
	label12.Size = UDim2.fromOffset(0, 18)
	label12.TextColor3 = Style.INK
	local label13 = Style.label(frame6, "State", "", 12, Style.FONT, 0)
	label13.AnchorPoint = Vector2.new(1, 0)
	label13.Position = UDim2.new(1, -14, 0, 256)
	local label14 = Style.label(frame6, "Name", "", 24, Style.FONT, 1.5)
	label14.Position = UDim2.fromOffset(14, 276)
	local label15 = Style.label(frame6, "Description", "", v, Style.FONT_BODY, 0)
	label15.AutomaticSize = Enum.AutomaticSize.None
	label15.Size = UDim2.new(1, -28, 0, 74)
	label15.Position = UDim2.fromOffset(14, 306)
	label15.TextWrapped = true
	label15.TextXAlignment = Enum.TextXAlignment.Left
	label15.TextYAlignment = Enum.TextYAlignment.Top
	label15.TextColor3 = textColor2

	local label16 = Style.label(box3, "Toast", "", 15, Style.FONT, 1.5)
	label16.ZIndex = 4
	label16.AnchorPoint = Vector2.new(0.5, 1)
	label16.Position = UDim2.new(0.5, 0, 1, -62)
	label16.Visible = false

	local button4 = Style.button(box3, "Action", "", Style.HAZARD, UDim2.new(1, -28, 0, 44), Style.INK, 18)
	button4.AnchorPoint = Vector2.new(0.5, 1)
	button4.Position = UDim2.new(0.5, 0, 1, -14)
	local text_2 = button4:FindFirstChild("Text")
	text_2.Visible = false
	local v6 = costContent(button4, 18)

	local v7 = {}
	local v8 = {}
	local v9 = 0
	local v10 = nil
	local visible2 = false
	local v11 = "Reds"
	local flag = false
	local count = 0

	local function scrap() -- 5 equivalent calls inferred from this helper
		local scrap2 = instance:GetAttribute("Scrap")
		return if type(scrap2) == "number" then scrap2 else 0
	end

	local function showToast(text: string, flag2: boolean) -- 1 equivalent call inferred from this helper
		count += 1
		local v12 = count
		label16.Text = text
		local textColor = if flag2 then Style.GOOD else Style.ORANGE
		label16.TextColor3 = textColor
		label16.Visible = true
		task.delay(2.4, function()
			if count == v12 then
				label16.Visible = false
			end
		end)
	end

	local function ask(p2: string, id: string, id2: string?) -- 5 equivalent calls inferred from this helper
		if flag then
			return
		end

		flag = true
		local v12, v13 = callback(p2, id, id2)
		flag = false

		if not v12 or string.sub(v13, 1, 8) ~= "Equipped" then
			showToast(string.upper(v13), v12) -- inferred equivalent call
		end
	end

	local v12 = {}
	local v13 = nil

	local function buildRows(data)
		for _, v14 in v12 do
			v14.frame:Destroy()
		end

		table.clear(v12)
		local item = ShopData.item(data.id)
		label9.Visible = #item.tracks == 0

		for k, track in item.tracks do
			local frame8 = Style.frame(frame5, track.id, UDim2.new(1, 0, 0, 48))
			frame8.LayoutOrder = k
			local box7 = Style.box(frame8, "Plate", Style.PANEL, UDim2.new(1, 0, 1, -6), 3, 1.5)
			box7.BackgroundTransparency = 0.2
			local label = Style.label(box7, "Name", track.name, 14, Style.FONT, 0)
			label.Position = UDim2.fromOffset(10, 3)
			local v14 = pips(box7, ShopData.maxLevel(track), Vector2.new(14, 6))
			local pips_2 = box7:FindFirstChild("Pips")
			pips_2.Position = UDim2.fromOffset(10, 26)
			local label17 = Style.label(box7, "Stat", "", 14, Style.FONT_BODY, 0)
			label17.RichText = true
			label17.AnchorPoint = Vector2.new(0, 0.5)
			label17.Position = UDim2.new(0, 112, 0.5, 0)
			local button5 = Style.button(box7, "Buy", "", Style.HAZARD, UDim2.fromOffset(92, 30), Style.INK, 15)
			button5.AnchorPoint = Vector2.new(1, 0.5)
			button5.Position = UDim2.new(1, -6, 0.5, 0)
			local text = button5:FindFirstChild("Text")
			text.Visible = false
			local v15 = costContent(button5, 15)
			local function refresh()
				local owns = ShopData.owns(instance, data.id)
				local level = ShopData.level(instance, data.id, track.id)
				local maxLevel = ShopData.maxLevel(track)
				v14(level)
				local v16 = track.show(ShopData.value(track, level))

				if level < maxLevel then
					local v17 = track.show(ShopData.value(track, level + 1))
					label17.Text = Style.paint(v16, Style.MUTED) .. "  " .. Style.paint(">", Style.DIM) .. "  " .. Style.paint(v17, Style.WHITE)
				else
					label17.Text = Style.paint(v16, Style.WHITE)
				end

				if owns then
					if maxLevel <= level then
						button5.BackgroundColor3 = Style.STEEL
						button5.AutoButtonColor = false
						v15("MAX", nil, Style.GOOD)
					else
						local cost = track.costs[level + 1]
						local autoButtonColor = cost <= scrap() -- inferred equivalent call
						local backgroundColor

						if autoButtonColor then
							backgroundColor = Style.HAZARD
						else
							backgroundColor = Style.STEEL
						end

						button5.BackgroundColor3 = backgroundColor
						button5.AutoButtonColor = autoButtonColor
						local v17

						if autoButtonColor then
							v17 = Style.INK
						else
							v17 = Style.MUTED
						end

						v15("", cost, v17)
					end
				else
					button5.BackgroundColor3 = Style.STEEL
					button5.AutoButtonColor = false
					v15("LOCKED", nil, Style.MUTED)
				end
			end
			button5.Activated:Connect(function()
				local level = ShopData.level(instance, data.id, track.id)

				if ShopData.owns(instance, data.id) and level < ShopData.maxLevel(track) then
					ask("upgrade", data.id, track.id) -- inferred equivalent call
				end
			end)
			refresh()
			table.insert(v12, { frame = frame8, refresh = refresh })
		end
	end

	local function level()
		return Skins.levelOf(instance)
	end

	local function refreshOutfit()
		local v14 = v10

		if not v14 then
			return
		end

		local unlocked = Skins.unlocked(instance, v14.id)
		local v15 = Skins.pick(instance) == v14.id
		local backgroundColor

		if unlocked then
			backgroundColor = Style.HAZARD
		else
			backgroundColor = Style.STEEL
		end

		box6.BackgroundColor3 = backgroundColor
		local textColor = if unlocked then Style.INK else Style.MUTED
		label12.TextColor3 = textColor
		label12.Text = v14.level <= 1 and "STANDARD ISSUE" or Skins.lockText(v14, "LEVEL %d")
		label13.Visible = v15 or not unlocked
		label13.Text = v15 and "WEARING" or string.format("YOU ARE LEVEL %d", level())
		local textColor3 = if v15 then Style.GOOD else Style.DIM
		label13.TextColor3 = textColor3

		for _, v16 in v4 do
			local v17 = v16.team == v11
			local button5 = v16.button
			local backgroundColor2

			if v17 then
				backgroundColor2 = Style.teamColor(v16.team)
			else
				backgroundColor2 = Style.PANEL
			end

			button5.BackgroundColor3 = backgroundColor2
			local label17 = v16.label
			local textColor4 = if v17 then Style.WHITE else Style.MUTED
			label17.TextColor3 = textColor4
		end

		if v15 then
			button4.BackgroundColor3 = Style.STEEL
			button4.AutoButtonColor = false
			v6("WEARING", nil, Style.GOOD)
		elseif unlocked then
			button4.BackgroundColor3 = Style.HAZARD
			button4.AutoButtonColor = true
			v6("WEAR", nil, Style.INK)
		else
			button4.BackgroundColor3 = Style.STEEL
			button4.AutoButtonColor = false
			v6(Skins.lockText(v14, "UNLOCKS AT LEVEL %d"), nil, Style.MUTED)
		end
	end

	local function stageOutfit() -- 1 equivalent call inferred from this helper
		local v14 = v10
		local body = SkinPreview.body(instance)
		label10.Visible = body == nil

		if v14 and body then
			view.show(SkinPreview.dress(body, v14, v11, instance.UserId))
		else
			view.show(nil)
		end
	end

	local function refreshDetail()
		if visible2 then
			refreshOutfit()
			return
		end

		local v14 = v10

		if not v14 then
			return
		end

		local item = ShopData.item(v14.id)
		local owns = ShopData.owns(instance, v14.id)

		if v13 then
			v13.Visible = not owns
		end

		local v15

		if item.slot == "streak" then
			v15 = ShopData.streak(instance) == v14.id
		else
			v15 = false
		end

		local v16 = ShopData.PICKS[item.slot]
		local v17

		if v16 == nil then
			v17 = false
		else
			v17 = ShopData.pick(instance, item.slot) == v14.id
		end

		local visible

		if owns then
			if v16 then
				visible = v17
			else
				visible = item.slot ~= "streak" or v15
			end
		else
			visible = owns
		end

		label5.Visible = visible
		label5.Text = item.slot == "streak" and "EQUIPPED" or "OWNED"

		for _, v18 in v12 do
			v18.refresh()
		end

		if owns and item.slot == "streak" and not v15 then
			button4.BackgroundColor3 = Style.HAZARD
			button4.AutoButtonColor = true
			v6("EQUIP", nil, Style.INK)
		elseif owns and item.slot == "streak" then
			button4.BackgroundColor3 = Style.STEEL
			button4.AutoButtonColor = false
			v6("EQUIPPED", nil, Style.GOOD)
		elseif owns and v16 and not v17 then
			button4.BackgroundColor3 = Style.HAZARD
			button4.AutoButtonColor = true
			v6("EQUIP", nil, Style.INK)
		elseif owns and v16 then
			button4.BackgroundColor3 = Style.STEEL
			button4.AutoButtonColor = false
			v6("YOUR " .. string.upper(v16.label), nil, Style.GOOD)
		elseif owns then
			button4.BackgroundColor3 = Style.STEEL
			button4.AutoButtonColor = false
			v6("OWNED", nil, Style.MUTED)
		else
			local v18 = item.price - scrap() -- inferred equivalent call

			if v18 <= 0 then
				button4.BackgroundColor3 = Style.HAZARD
				button4.AutoButtonColor = true
				v6("BUY", item.price, Style.INK)
			else
				button4.BackgroundColor3 = Style.STEEL
				button4.AutoButtonColor = false
				v6("NEED", v18, Style.MUTED, " MORE")
			end
		end
	end

	local function select(data, p2)
		for _, v14 in v8 do
			v14.stroke.Color = Style.INK
			v14.stroke.Thickness = 2
		end

		if p2 then
			p2.stroke.Color = Style.HAZARD
			p2.stroke.Thickness = 3
		end

		for _, child in frame4:GetChildren() do
			child:Destroy()
		end

		v10 = data
		box3.Visible = data ~= nil

		for _, v14 in v5 do
			v14.Visible = not visible2
		end

		frame6.Visible = visible2

		if not data then
			return
		end

		if visible2 then
			label14.Text = string.upper(data.name)
			label15.Text = data.description
			view.resetTurn()
			stageOutfit() -- inferred equivalent call
			refreshOutfit()
		else
			label9.Visible = false
			picture(data, frame4, UDim2.fromScale(1, 1), UDim2.new())
			v13 = lockOverlay(frame4, UDim2.fromScale(1, 1), UDim2.new(), 32, 2)
			label4.Text = data.slot or "ITEM"
			label6.Text = string.upper(data.name)
			label7.Text = data.description
			buildRows(data)
			refreshDetail()
		end
	end

	button4.Activated:Connect(function()
		local v14 = v10

		if not v14 then
			return
		end

		if visible2 then
			if Skins.unlocked(instance, v14.id) and Skins.pick(instance) ~= v14.id then
				ask("skin", v14.id) -- inferred equivalent call
			end
		else
			local item = ShopData.item(v14.id)

			if ShopData.owns(instance, v14.id) then
				if ShopData.PICKS[item.slot] and ShopData.pick(instance, item.slot) ~= v14.id then
					ask("pick", v14.id) -- inferred equivalent call
				elseif item.slot == "streak" and ShopData.streak(instance) ~= v14.id then
					ask("streak", v14.id) -- inferred equivalent call
				end
			elseif scrap() >= item.price then -- inferred equivalent call
				ask("buy", v14.id) -- inferred equivalent call
			end
		end
	end)

	local function makeCrate(item, layoutOrder: number)
		local textButton = Instance.new("TextButton")
		textButton.Name = item.id
		textButton.Text = ""
		textButton.LayoutOrder = layoutOrder
		textButton.AutoButtonColor = true
		textButton.BorderSizePixel = 0
		textButton.BackgroundColor3 = Style.STEEL
		textButton.Parent = crates
		Style.corner(textButton, 3)
		local stroke = Style.stroke(textButton, 2, 0, Style.INK, true)

		for i = 1, 2 do
			local fill = Style.fill(
				textButton,
				"Slat",
				Style.STEEL_LIGHT,
				UDim2.new(1, -16, 0, 3),
				UDim2.fromOffset(8, i * 30)
			)
			fill.BackgroundTransparency = 0.6
		end

		brackets(textButton, Style.HAZARD, 10)
		picture(item, textButton, UDim2.new(1, -16, 0, 86), UDim2.fromOffset(8, 16))
		local v14 = lockOverlay(textButton, UDim2.new(1, -16, 0, 86), UDim2.fromOffset(8, 16), 26, 2)

		local folder = Style.box(textButton, "Tag", Style.INK, UDim2.fromOffset(0, 20), 2, 1)
		folder.AutomaticSize = Enum.AutomaticSize.X
		folder.AnchorPoint = Vector2.new(1, 0)
		folder.Position = UDim2.new(1, -8, 0, 8)
		folder.ZIndex = 3
		local uiPadding5 = Instance.new("UIPadding")
		uiPadding5.PaddingLeft = UDim.new(0, 5)
		uiPadding5.PaddingRight = UDim.new(0, 6)
		uiPadding5.Parent = folder
		row(folder, "Row", 4) -- inferred equivalent call
		local nut = Style.nut(folder, 13)
		nut.LayoutOrder = 1
		local label17 = Style.label(folder, "Text", "", 13, Style.FONT, 0)
		label17.LayoutOrder = 2

		for _, guiObject in folder:GetDescendants() do
			if guiObject:IsA("GuiObject") then
				guiObject.ZIndex = 3
			end
		end

		local fill3 = Style.fill(
			textButton,
			"Label",
			Style.INK,
			UDim2.new(1, 0, 0, 46),
			UDim2.fromScale(0, 1),
			Vector2.new(0, 1)
		)
		fill3.BackgroundTransparency = 0.25
		local label18 = Style.label(fill3, "Slot", item.slot or "", 10, Style.FONT, 0)
		label18.TextColor3 = Style.HAZARD
		label18.Position = UDim2.fromOffset(8, 3)
		label18.Size = UDim2.fromOffset(0, 14)
		local label19 = Style.label(fill3, "Name", string.upper(item.name), 15, Style.FONT, 0)
		label19.Position = UDim2.fromOffset(8, 19)
		label19.Size = UDim2.fromOffset(0, 20)
		local label20 = Style.label(fill3, "Upgrades", "", 11, Style.FONT, 0)
		label20.AnchorPoint = Vector2.new(1, 0)
		label20.Position = UDim2.new(1, -8, 0, 4)
		label20.Size = UDim2.fromOffset(0, 14)
		label20.TextColor3 = Style.HAZARD
		local item2 = ShopData.item(item.id)
		local total = 0

		for _, track in item2.tracks do
			total += ShopData.maxLevel(track)
		end

		local function refresh()
			local owns = ShopData.owns(instance, item.id)
			v14.Visible = not owns

			if owns then
				nut.Visible = false
				local v15

				if ShopData.PICKS[item2.slot] then
					v15 = ShopData.pick(instance, item2.slot) == item.id
				else
					v15 = item2.slot ~= "streak" or ShopData.streak(instance) == item.id
				end

				label17.Text = item2.slot == "streak" and (v15 and "EQUIPPED" or "UNLOCKED")
					or v15 and "EQUIPPED"
					or "OWNED"
				local textColor

				if v15 then
					textColor = Style.GOOD
				else
					textColor = Style.MUTED
				end

				label17.TextColor3 = textColor
			else
				nut.Visible = true
				label17.Text = Style.thousands(item2.price)
				local textColor

				if scrap() >= item2.price then -- inferred equivalent call
					textColor = Style.HAZARD
				else
					textColor = Style.DIM
				end

				label17.TextColor3 = textColor
			end

			local total2 = 0

			for _, track in item2.tracks do
				total2 += ShopData.level(instance, item.id, track.id)
			end

			label20.Visible = owns and total > 0
			label20.Text = string.format("UPG %d/%d", total2, total)
		end
		local crate = { button = textButton, stroke = stroke, item = item, refresh = refresh }
		textButton.Activated:Connect(function()
			select(item, crate)
		end)
		refresh()
		return crate
	end

	local function makeOutfitCrate(data, layoutOrder: number)
		local textButton = Instance.new("TextButton")
		textButton.Name = data.id
		textButton.Text = ""
		textButton.LayoutOrder = layoutOrder
		textButton.AutoButtonColor = true
		textButton.BorderSizePixel = 0
		textButton.BackgroundColor3 = Style.STEEL
		textButton.Parent = crates
		Style.corner(textButton, 3)
		local stroke = Style.stroke(textButton, 2, 0, Style.INK, true)
		brackets(textButton, Style.HAZARD, 10)
		local box7 = Style.box(textButton, "Portrait", color2, UDim2.new(1, -16, 0, 96), 2, 0)
		box7.Position = UDim2.fromOffset(8, 8)
		box7.ClipsDescendants = true
		local view2 = nil
		local body = SkinPreview.body(instance)

		if body then
			view2 = SkinPreview.view(box7, "bust")
			view2.frame.Active = false
			view2.show(SkinPreview.dress(body, data, v11, instance.UserId))
		else
			local label17 = Style.label(box7, "Text", string.upper((string.sub(data.name, 1, 1))), 44, Style.FONT, 0)
			label17.AutomaticSize = Enum.AutomaticSize.None
			label17.Size = UDim2.fromScale(1, 1)
			label17.TextColor3 = Style.STEEL_LIGHT
		end

		local box8 = Style.box(textButton, "Tag", Style.INK, UDim2.fromOffset(0, 20), 2, 1)
		box8.AutomaticSize = Enum.AutomaticSize.X
		box8.AnchorPoint = Vector2.new(1, 0)
		box8.Position = UDim2.new(1, -8, 0, 8)
		box8.ZIndex = 3
		local uiPadding5 = Instance.new("UIPadding")
		uiPadding5.PaddingLeft = UDim.new(0, 5)
		uiPadding5.PaddingRight = UDim.new(0, 6)
		uiPadding5.Parent = box8
		local label17 = Style.label(box8, "Text", "", 13, Style.FONT, 0)
		label17.Size = UDim2.fromOffset(0, 20)
		label17.ZIndex = 3
		local fill3 = Style.fill(
			textButton,
			"Label",
			Style.INK,
			UDim2.new(1, 0, 0, 46),
			UDim2.fromScale(0, 1),
			Vector2.new(0, 1)
		)
		fill3.BackgroundTransparency = 0.25
		local label18 = Style.label(fill3, "Slot", data.kind, 10, Style.FONT, 0)
		label18.TextColor3 = Style.HAZARD
		label18.Position = UDim2.fromOffset(8, 3)
		label18.Size = UDim2.fromOffset(0, 14)
		local label19 = Style.label(fill3, "Name", string.upper(data.name), 15, Style.FONT, 0)
		label19.Position = UDim2.fromOffset(8, 19)
		label19.Size = UDim2.fromOffset(0, 20)
		local function refresh()
			local unlocked = Skins.unlocked(instance, data.id)
			local v14 = Skins.pick(instance) == data.id
			label17.Text = v14 and "WEARING" or unlocked and "UNLOCKED" or Skins.lockText(data, "LV %d")
			local textColor

			if v14 then
				textColor = Style.GOOD
			elseif unlocked then
				textColor = Style.MUTED
			else
				textColor = Style.HAZARD
			end

			label17.TextColor3 = textColor

			if view2 then
				local frame8 = view2.frame
				local imageColor

				if unlocked then
					imageColor = Color3.new(1, 1, 1)
				else
					imageColor = Color3.fromRGB(118, 118, 122)
				end

				frame8.ImageColor3 = imageColor
			end
		end
		local outfitCrate = {
			button = textButton,
			stroke = stroke,
			item = data,
			refresh = refresh,
			view = view2
		}
		textButton.Activated:Connect(function()
			select(data, outfitCrate)
		end)
		refresh()
		return outfitCrate
	end

	local function clearCrates()
		for _, v14 in v8 do
			if v14.view then
				v14.view.destroy()
			end

			v14.button:Destroy()
		end

		table.clear(v8)
	end

	local v14 = nil
	local function fillOutfits(p2: string?)
		clearCrates()
		v14 = SkinPreview.body(instance)
		local v15 = p2 or Skins.pick(instance)
		local v16 = nil
		local v17 = nil

		for k, v18 in Skins.LIST do
			local outfitCrate = makeOutfitCrate(v18, k)
			table.insert(v8, outfitCrate)

			if v18.id ~= v15 then
				continue
			end

			v17 = outfitCrate
			v16 = v18
		end

		label3.Visible = #Skins.LIST == 0
		select(v16 or Skins.LIST[1], v17 or v8[1])
	end

	for _, v15 in v4 do
		v15.button.Activated:Connect(function()
			if not visible2 or v11 == v15.team then
				return
			end

			v11 = v15.team
			local v16

			if v10 then
				v16 = v10.id
			end

			fillOutfits(v16)
		end)
	end

	local function showTab(p2: number)
		if p2 == v9 then
			return
		end

		v9 = p2

		for k, v15 in v7 do
			local v16 = k == p2
			local button5 = v15.button
			local backgroundColor

			if v16 then
				backgroundColor = Style.HAZARD
			else
				backgroundColor = Style.PANEL
			end

			button5.BackgroundColor3 = backgroundColor
			local label17 = v15.label
			local textColor = if v16 then Style.INK else Style.MUTED
			label17.TextColor3 = textColor
		end

		clearCrates()
		local v15 = LoadoutData[p2]
		visible2 = v15.outfits == true
		label3.Text = v15.empty or ""

		if visible2 then
			local v16

			if instance.Team then
				v16 = instance.Team.Name
			end

			if v16 ~= "Reds" and v16 ~= "Blues" then
				v16 = v11
			end

			v11 = v16
			fillOutfits()
		else
			for k, item in v15.items do
				table.insert(v8, makeCrate(item, k))
			end

			label3.Visible = #v15.items == 0
			select(v15.items[1], v8[1])
		end
	end

	for k, v15 in LoadoutData do
		local button5, label17 = Style.button(
			frame3,
			"Tab" .. v15.id,
			v15.title,
			Style.PANEL,
			UDim2.fromOffset(0, 32),
			Style.MUTED,
			17
		)
		button5.AutomaticSize = Enum.AutomaticSize.X
		label17.AutomaticSize = Enum.AutomaticSize.X
		label17.Size = UDim2.new(0, 0, 1, 0)
		local uiPadding5 = Instance.new("UIPadding")
		uiPadding5.PaddingLeft = UDim.new(0, 11)
		uiPadding5.PaddingRight = UDim.new(0, 11)
		uiPadding5.Parent = button5
		button5.LayoutOrder = k
		button5.Activated:Connect(function()
			showTab(k)
		end)
		v7[k] = { button = button5, label = label17 }
	end

	local v15 = {}
	local function toggle()
		for _, v16 in v15 do
			v16()
		end
	end
	button.Activated:Connect(toggle)
	button3.Activated:Connect(toggle)

	local v16 = 1
	local function release()
		v16 = math.max(v9, 1)
		clearCrates()

		for _, child in frame4:GetChildren() do
			child:Destroy()
		end

		v13 = nil

		for _, v17 in v12 do
			v17.frame:Destroy()
		end

		table.clear(v12)
		view.show(nil)
		v10 = nil
		v9 = 0
	end

	local v17 = {}
	v17.root = region2
	v17.button = button
	v17.storeButton = button2

	function v17.isOpen()
		return region2.Visible
	end

	function v17.setOpen(visible: boolean)
		if visible == region2.Visible then
			return
		end

		region2.Visible = visible

		if not visible then
			release()
		end

		if visible then
			if v9 == 0 then
				showTab(v16)
			elseif visible2 and SkinPreview.body(instance) ~= v14 then
				local v18

				if v10 then
					v18 = v10.id
				end

				fillOutfits(v18)
			end

			v17.refresh()
			local now = os.clock()
			Style.animate(v17, function(_, p2): boolean
				local v18 = (p2 - now) / 0.16
				fit(0.92 + 0.08 * Style.pop(v18))
				return v18 < 1
			end)
		end
	end
	function v17.onToggle(callback2)
		table.insert(v15, callback2)
	end

	function v17.stepTab(p2: number)
		local v18 = #LoadoutData
		showTab((math.max(v9, 1) - 1 + p2) % v18 + 1)
	end
	function v17.firstPad()
		local v18 = v8[1]
		return if v18 and v18.button.Visible then v18.button else nil
	end

	function v17.refresh()
		label2.Text = Style.thousands(scrap()) -- inferred equivalent call

		for _, v18 in v8 do
			v18.refresh()
		end

		refreshDetail()
	end
	return v17
end

function Shop.mount(data)
	local player = data.player
	local shop = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Remotes"):WaitForChild("Shop", 30)
	assert(shop and shop:IsA("RemoteFunction"), "GameUI: remote Game.Remotes.Shop (RemoteFunction) is missing")
	local function request(p: string, p2: string, p3: string?)
		local success, result, v2 = pcall(shop.InvokeServer, shop, p, p2, p3)

		if not success then
			warn("[Shop] request failed: " .. tostring(result))
			return false, "No answer from the shop."
		end

		local selected = result == true

		if type(v2) == "string" then
			return selected, v2
		end

		return selected, ""
	end

	local v2 = Shop.new(data.layers.menu, player, request)

	local function armoryRoot() -- 2 equivalent calls inferred from this helper
		local armory = data.layers.menu:FindFirstChild("Armory")

		if armory and armory:IsA("GuiObject") then
			return armory
		end

		return nil
	end

	local function armoryOpen() -- 5 equivalent calls inferred from this helper
		local armory = armoryRoot() -- inferred equivalent call
		return armory ~= nil and armory.Visible
	end

	local function toggle()
		if not (Armory.toggle and Armory.openLoadout) then
			return
		end

		if armoryOpen() then -- inferred equivalent call
			Armory.toggle()
		else
			Armory.openLoadout()
		end
	end
	v2.onToggle(toggle)

	local parent = v2.button.Parent
	local v3 = false
	local v4 = false

	local ArmoryStore = require(script.Parent:WaitForChild("ArmoryStore"))
	local SCREEN_ON = ArmoryStore.SCREEN_ON == true
	v2.storeButton.Visible = false

	local function placeStore()
		local visible = v4 and SCREEN_ON
		v2.storeButton.Visible = visible

		if Style.isTouch() then
			local uiScale = parent:FindFirstChildOfClass("UIScale")
			local v5 = v2.storeButton.Position.Y.Offset * (not uiScale and 1 or uiScale.Scale)
			parent.Position = UDim2.new(0, parent.Position.X.Offset, 0.5, not visible and 0 or -math.round(v5 / 2))
		end
	end
	local function showButton() -- 2 equivalent calls inferred from this helper
		parent.Visible = not v3 and not armoryOpen() -- inferred equivalent call
		placeStore()
	end
	data.onTeam(function(p: string?)
		v4 = p == nil
		placeStore()
	end)
	local function toggleStore() -- 1 equivalent call inferred from this helper
		local Store = require(script.Parent:WaitForChild("Store"))

		if not Store.toggle then
			return
		end

		Store.toggle()
	end
	v2.storeButton.Activated:Connect(toggleStore)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or not SCREEN_ON then
			return
		end

		local v5 = input.KeyCode == Enum.KeyCode.DPadRight

		if input.KeyCode ~= n and not v5 or v5 and Glyph.claimed("vote") then
			return
		end

		local Store = require(script.Parent:WaitForChild("Store"))

		if v2.storeButton.Visible or Store.isOpen and Store.isOpen() then
			toggleStore() -- inferred equivalent call
		end
	end)
	local v5 = nil
	local function watchArmory() -- 1 equivalent call inferred from this helper
		local armory = armoryRoot() -- inferred equivalent call

		if armory and armory ~= v5 then
			v5 = armory
			armory:GetPropertyChangedSignal("Visible"):Connect(showButton)
			showButton() -- inferred equivalent call
		end
	end
	data.layers.menu.ChildAdded:Connect(watchArmory)
	watchArmory() -- inferred equivalent call
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or input.KeyCode ~= Enum.KeyCode.DPadLeft or Glyph.claimed("vote") then
			return
		end

		if (armoryOpen() or parent.Visible) and Armory.toggle then -- inferred equivalent call
			if not Armory.openLoadout then
				return
			end

			if armoryOpen() then -- inferred equivalent call
				Armory.toggle()
			else
				Armory.openLoadout()
			end
		end
	end)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == b and Armory.toggle then
			if not Armory.openLoadout then
				return
			end

			if armoryOpen() then -- inferred equivalent call
				Armory.toggle()
			else
				Armory.openLoadout()
			end
		end
	end)

	local v6 = false
	player.AttributeChanged:Connect(function(value: string)
		if
			(value == "Scrap" or value == "Level" or value == Skins.ATTR or value == ShopData.PICKS.primary.attr or value == ShopData.PICKS.secondary.attr or value == ShopData.PICKS.utility.attr or value == ShopData.PICKS.melee.attr or value == ShopData.PICKS.throwable.attr or value == ShopData.STREAK_ATTR or string.sub(value, 1, 5) == "Owns_" or string.sub(value, 1, 3) == "Up_")
			and not v6
		then
			v6 = true
			task.defer(function()
				v6 = false

				if v2.isOpen() then
					v2.refresh()
				end
			end)
		end
	end)
	v2.refresh()

	data.onDead(function(flag: boolean)
		v3 = flag
		showButton() -- inferred equivalent call
	end)
end

return Shop