game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Style = require(script.Parent:WaitForChild("Style"))
local ShopData = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("ShopData"))
local Icons = require(script:WaitForChild("Icons"))
local Mastery = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("Mastery"))
local WeaponSkins = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("WeaponSkins"))
local SkinGlow = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("SkinGlow"))
local slot = WeaponSkins.SLOT
local Skins = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("Skins"))

local NewMenus = require(script.Parent:WaitForChild("NewMenus"))
local v = NewMenus.on("Crates")

local NewMenus2 = require(script.Parent:WaitForChild("NewMenus"))
local v2 = NewMenus2.on("Store")

local Gunsmith = ReplicatedStorage:FindFirstChild("Gunsmith")
local Gunsmith2

if Gunsmith then
	Gunsmith2 = require(Gunsmith:WaitForChild("Gunsmith"))
else
	Gunsmith2 = nil
end

local Workbench = {}

local touch = Style.isTouch()
local v3 = touch and 740 or 1000
local v4 = touch and 350 or 606
local v5 = touch and 36 or 40
local v6 = touch and 310 or 580
local v7 = touch and 310 or 380
local v8 = touch and 52 or 64
local v9 = touch and 16 or 18
local v10 = touch and 22 or 18
local v11 = touch and 156 or 190
local v12 = touch and 52 or 64
local v13 = touch and 58 or 74
local v14 = touch and 70 or 90
local v15 = touch and 62 or 78
local v16 = touch and 16 or 20
local v17 = (v15 + 6) * 2 + 6
local v18 = v4 - 10 - 8 - v17
local v19 = touch and 96 or 150
local v20 = v18 - 8 - v19
local v21 = touch and 2 or 3
local v22 = v6 + 26 + (touch and 14 or 30)
local v23 = v3 - 10 - 8 - 8 - v22
local v24 = touch and 64 or 92
local v25 = touch and 24 or 28
local v26 = math.floor(v17 / v25)
local v27 = touch and 150 or 190
local color = Color3.fromRGB(13, 14, 16)
local color2 = Color3.fromRGB(34, 36, 41)
local color3 = Color3.fromRGB(104, 108, 116)

local v28 = v3 * 0.1227845609029046 / v4

local unit = (Vector3.new(-1, 0.2, 0.3)).Unit

local v29 = {
	Optic = { dir = unit, zoom = 0.8 },
	Muzzle = { dir = (Vector3.new(-0.85, 0.2, -0.45)).Unit, zoom = 0.72 },
	Barrel = { dir = (Vector3.new(-1, 0.18, -0.2)).Unit, zoom = 0.75 },
	Magazine = { dir = (Vector3.new(-1, 0.16, 0.12)).Unit, zoom = 0.78 },
	Underbarrel = { dir = (Vector3.new(-1, 0.14, -0.12)).Unit, zoom = 0.75 },
	Skin = { dir = unit, zoom = 1 }
}

local v30 = {
	x0 = 26,
	y0 = v8 + 72 + v9 + 12,
	x1 = v3 - 10 - 16,
	y1 = v4 - 10 - 8 - v8 - v9 - 12
}
local v31 = { x0 = 0, y0 = 0, x1 = 0, y1 = 0 }
local x0_2

if touch then
	x0_2 = v22
else
	x0_2 = v7 + 26 + 30
end

v31.x0 = x0_2
v31.y0 = (touch and 0 or 40) + 72
v31.x1 = v3 - 10 - 16
v31.y1 = v18 - 10
local x0 = v31.x0
local color4 = Color3.fromRGB(226, 112, 86)
local color5 = Color3.fromRGB(92, 160, 74)
local color6 = Color3.fromRGB(136, 208, 114)
local color7 = Color3.fromRGB(208, 244, 198)
Color3.fromRGB(38, 40, 45)
local color8 = Color3.fromRGB(26, 27, 31)
local color9 = Color3.fromRGB(62, 64, 70)
local color10 = Color3.fromRGB(86, 196, 104)
local color11 = Color3.fromRGB(224, 76, 60)

local v32 = v3 - 20
local v34 = v4 - 64 - 10

local function zAll(folder, zIndex: number)
	folder.ZIndex = zIndex

	for _, guiObject in folder:GetDescendants() do
		if guiObject:IsA("GuiObject") then
			guiObject.ZIndex = zIndex
		end
	end
end

local function row(parent, p: number) -- 1 equivalent call inferred from this helper
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.Padding = UDim.new(0, p)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = parent
end

local function inset(parent, p: number, p2: number) -- 2 equivalent calls inferred from this helper
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, p)
	uiPadding.PaddingRight = UDim.new(0, p2)
	uiPadding.Parent = parent
end

local function stretch(p, vector2: Vector2, vector2_2: Vector2, value: number?)
	local v35 = vector2_2 - vector2
	p.AnchorPoint = Vector2.new(0.5, 0.5)
	p.Size = UDim2.fromOffset(v35.Magnitude, value or 1)
	p.Position = UDim2.fromOffset((vector2.X + vector2_2.X) / 2, (vector2.Y + vector2_2.Y) / 2)
	p.Rotation = math.deg((math.atan2(v35.Y, v35.X)))
end

local function trackOf(p: string, p2: string) -- 2 equivalent calls inferred from this helper
	for _, track in ShopData.item(p).tracks do
		if track.id == p2 then
			return track
		end
	end

	return nil
end

local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local GearSound = require(ReplicatedStorage2:WaitForChild("Voxel"):WaitForChild("GearSound"))

local Game = ReplicatedStorage:WaitForChild("Game")
local GameConfig = require(Game:WaitForChild("GameConfig"))
local damage = GameConfig.DAMAGE
local lists = {}
local v35 = {
	5,
	0.4,
	150,
	150,
	60,
	4,
	100,
	150,
	100,
	150,
	150,
	150,
	150
}
local v36 = {
	3,
	4,
	2,
	13,
	11,
	12,
	7,
	10,
	6,
	8,
	9
}

for _, childName in {
	"RifleSpecs",
	"SMGSpecs",
	"LMGSpecs",
	"DMRSpecs",
	"SniperSpecs",
	"PistolSpecs"
} do
	local module = require(Game:WaitForChild(childName))
	table.insert(lists, module.LIST)
end

local v37 = {
	AssaultRifle = { steps = damage.RIFLE_STEPS, interval = 0.1 },
	LMG = { steps = damage.LMG_STEPS, interval = 0.092 },
	SMG = { steps = damage.SMG_STEPS, interval = 0.072 },
	DMR = { near = damage.DMR, far = damage.DMR_MIN, interval = 0.2 },
	Sniper = { near = damage.SNIPER, interval = 1.5 }
}

local function gunNumbers(p: string)
	local v38 = v37[p]
	local v39 = nil
	local v40 = nil
	local interval = nil

	if v38 then
		v39 = v38.steps
		v40 = v38.near
		interval = v38.interval
	else
		local v41 = nil

		for _, v42 in lists do
			v41 = v41 or v42[p]
		end

		if v41 then
			interval = v41.interval
			local damage2 = v41.damage

			if type(damage2.body) == "number" then
				v40 = damage2.body
			elseif type(damage2.body) == "table" then
				v39 = damage2.body
			else
				v39 = damage2
			end
		end
	end

	if v39 and #v39 > 0 then
		v40 = v39[1][2]
	end

	local selected = not v40 and "-" or tostring((math.round(v40)))

	if interval then
		return selected, (tostring((math.round(60 / interval))))
	end

	return selected, "-"
end

local function percent(p: number, p2: number)
	if math.abs(p2) < 1e-6 then
		return ""
	end

	local v38 = math.round(p / p2 * 100)
	local v39 = v38 == 0 and (p > 0 and 1 or -1) or v38

	return string.format("%+d%%", v39)
end

local function numbersOf(p, p2: string, p3)
	local result = Gunsmith2.result(p2, p3)
	local track = trackOf(p2, "Magazine") -- inferred equivalent call
	local track2 = trackOf(p2, "Reload") -- inferred equivalent call
	local v40 = (not track and 0 or ShopData.value(track, ShopData.level(p, p2, "Magazine"))) + result.rounds

	local v41 = not track2 and 0
		or (tonumber(string.match(track2.show(1), "[%d%.]+")) or 0) * ShopData.value(track2, ShopData.level(p, p2, "Reload")) * result.reload

	local zoom = Gunsmith2.zoomOf(result.aimFov)
	return {
		{
			label = "ZOOM",
			value = zoom,
			text = Gunsmith2.zoomText(zoom),
			delta = function(p4)
				return string.format("%+.1f", p4)
			end,
			neutral = true
		},
		{
			label = "AIM TIME",
			value = result.aimTime,
			text = string.format("%.2fs", result.aimTime),
			delta = percent,
			lower = true
		},
		{
			label = "RECOIL UP",
			value = result.climb * 100,
			text = string.format("%d%%", (math.round(result.climb * 100))),
			delta = percent,
			lower = true
		},
		{
			label = "RECOIL SIDE",
			value = result.yaw * 100,
			text = string.format("%d%%", (math.round(result.yaw * 100))),
			delta = percent,
			lower = true
		},
		{
			label = "MAG",
			value = v40,
			text = tostring((math.round(v40))),
			delta = function(p4)
				return string.format("%+d", (math.round(p4)))
			end
		},
		{
			label = "RELOAD",
			value = v41,
			text = string.format("%.2fs", v41),
			delta = percent,
			lower = true
		},
		{
			label = "AIMED WALK",
			value = result.aimMove * 100,
			text = string.format("%d%%", (math.round(result.aimMove * 100))),
			delta = percent
		},
		{
			label = "FLASH",
			value = result.flash * 100,
			text = string.format("%d%%", (math.round(result.flash * 100))),
			delta = percent,
			lower = true
		},
		{
			label = "HEARD FROM",
			value = (result.quiet or 1) * 100,
			text = string.format("%d%%", (math.round((result.quiet or 1) * 100))),
			delta = percent,
			lower = true
		},
		{
			label = "MOVING SPREAD",
			value = 100 + result.moveSpread * 34,
			text = string.format("%d%%", (math.round(100 + result.moveSpread * 34))),
			delta = percent,
			lower = true
		},
		{
			label = "HIP SPREAD",
			value = result.hip * 100,
			text = string.format("%d%%", (math.round(result.hip * 100))),
			delta = percent,
			lower = true
		},
		{
			label = "AIMED BLOOM",
			value = result.bloom * 100,
			text = string.format("%d%%", (math.round(result.bloom * 100))),
			delta = percent,
			lower = true
		},
		{
			label = "BULLET SPEED",
			value = result.velocity * 100,
			text = string.format("%d%%", (math.round(result.velocity * 100))),
			delta = percent
		}
	}
end

local function plainGun(name: string)
	local folder = ReplicatedStorage:WaitForChild("ToolTemplates"):FindFirstChild(name)
	local handle = folder and folder:FindFirstChild("Handle")
	assert(handle and handle:IsA("BasePart"), "[Workbench] ToolTemplates." .. name .. " has no Handle")
	local tool = Instance.new("Tool")
	tool.Name = name

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		local clone = part:Clone()

		for _, child in clone:GetChildren() do
			if
				child:IsA("Attachment")
				or child:IsA("DataModelMesh")
				or child:IsA("Decal")
				or child:IsA("SurfaceAppearance")
			then
				continue
			end

			child:Destroy()
		end

		clone.Anchored = true
		clone.CFrame = handle.CFrame:ToObjectSpace(part.CFrame)
		clone.Parent = tool
	end

	return tool
end

local function build(p, p2)
	local region = Style.region(p, "Workbench", Vector2.new(0.5, 0.5), Vector2.zero, Vector2.new(v3, v4))
	region.Visible = false
	local fit = Style.fit(region, Vector2.new(v3, v4), 0.96, { grow = touch })
	local modal = Instance.new("TextButton")
	modal.Name = "Modal"
	modal.Text = ""
	modal.BackgroundTransparency = 1
	modal.Size = UDim2.fromOffset(1, 1)
	modal.Modal = true
	modal.Selectable = false
	modal.Parent = region

	local box = Style.box(region, "Body", Style.PANEL, UDim2.fromScale(1, 1), 3, 3)
	box.BackgroundTransparency = 0.04
	box.Active = true

	local fill = Style.fill(box, "Header", Style.STEEL, UDim2.new(1, 0, 0, 54))
	Style.corner(fill, 3)
	local frame = Style.frame(fill, "Left", UDim2.new(1, -72, 1, 0))
	inset(frame, 10, 0) -- inferred equivalent call
	row(frame, 10) -- inferred equivalent call
	local button = Style.button(frame, "Back", "<", Style.PANEL, UDim2.fromOffset(44, 44), Style.WHITE, 26)
	button.LayoutOrder = 1
	local label_2 = Style.label(frame, "Title", "WORKBENCH", 26, Style.FONT, 1.5)
	label_2.LayoutOrder = 2
	local box2 = Style.box(frame, "Gun", Style.HAZARD, UDim2.fromOffset(0, 30), 2, 1)
	box2.AutomaticSize = Enum.AutomaticSize.X
	box2.LayoutOrder = 3
	inset(box2, 10, 10) -- inferred equivalent call
	local label = Style.label(box2, "Name", "", 20, Style.FONT, 0)
	label.Size = UDim2.fromOffset(0, 30)
	label.TextColor3 = Style.INK
	local button2, v38 = Style.button(fill, "Close", "X", Style.ORANGE, UDim2.fromOffset(44, 44), Style.INK, 22)
	button2.AnchorPoint = Vector2.new(1, 0.5)
	button2.Position = UDim2.new(1, -10, 0.5, 0)

	local frame2 = Style.frame
	local udim = UDim2.fromOffset(200, 36)
	local v40

	if touch then
		v40 = UDim2.fromOffset(v3 - 10 - 44 - 12 - 200, 9)
	else
		v40 = UDim2.fromOffset(v3 - 10 - 8 - 200, 72)
	end

	local v41 = frame2(box, "Level", udim, v40)

	local function levelLabel(p3: string, maxTextSize: number, p4: number, p5: number, p6: number, textXAlignment)
		local label2 = Style.label(v41, p3, "", maxTextSize, Style.FONT, 0)
		label2.AutomaticSize = Enum.AutomaticSize.None
		label2.AnchorPoint = Vector2.new(0, 1)
		label2.Position = UDim2.fromOffset(p4, p6)
		label2.Size = UDim2.fromOffset(p5, maxTextSize + 4)
		label2.TextXAlignment = textXAlignment
		label2.TextYAlignment = Enum.TextYAlignment.Bottom
		label2.TextWrapped = false
		label2.TextScaled = true
		local uiTextSizeConstraint = Instance.new("UITextSizeConstraint")
		uiTextSizeConstraint.MaxTextSize = maxTextSize
		uiTextSizeConstraint.MinTextSize = 8
		uiTextSizeConstraint.Parent = label2
		return label2
	end

	local parent2 = levelLabel("Text", 20, 0, 124, 29, Enum.TextXAlignment.Left)
	local parent3 = levelLabel("Next", 12, 130, 70, 28, Enum.TextXAlignment.Right)
	parent3.TextColor3 = Style.MUTED
	local fill2 = Style.fill(v41, "Xp", color9, UDim2.new(1, 0, 0, 3), UDim2.new(0, 0, 1, -3))
	local fill3 = Style.fill(fill2, "Fill", Style.WHITE, UDim2.fromScale(0, 1))

	local Glyph = require(script.Parent:WaitForChild("Glyph"))
	local cap = Glyph.cap(button2, nil, Enum.KeyCode.ButtonB, 30)
	cap.AnchorPoint = Vector2.new(0.5, 0.5)
	cap.Position = UDim2.fromScale(0.5, 0.5)
	local function face() -- 1 equivalent call inferred from this helper
		v38.Visible = not Glyph.gamepad()
	end
	Glyph.onChange(face)
	face() -- inferred equivalent call
	local box3 = Style.box(box, "Stage", color8, UDim2.fromOffset(v32, v34), 3, 1.5)
	box3.Position = UDim2.fromOffset(10, 64)
	box3.ClipsDescendants = true
	local backdrop = Instance.new("ImageLabel")
	backdrop.Name = "Backdrop"
	backdrop.BackgroundTransparency = 1
	backdrop.Image = "rbxassetid://104925965502649"
	backdrop.ScaleType = Enum.ScaleType.Crop
	backdrop.AnchorPoint = Vector2.new(0.5, 0.5)
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.Position = UDim2.fromScale(0.5, 0.5)
	backdrop.Parent = box3
	local gun = Instance.new("ViewportFrame")
	gun.Name = "Gun"
	gun.BackgroundTransparency = 1
	gun.Size = UDim2.fromOffset(v3, v4)
	gun.Position = UDim2.fromOffset(-10, -64)
	gun.Active = true
	gun.Ambient = Color3.fromRGB(175, 175, 185)
	gun.LightColor = Color3.new(1, 1, 1)
	gun.LightDirection = Vector3.new(1, -1.5, -0.5)
	gun.Parent = box3
	local camera = Instance.new("Camera")
	camera.FieldOfView = 14
	camera.Parent = gun
	gun.CurrentCamera = camera
	local model = Instance.new("Model")
	model.Parent = gun
	local frame3 = Style.frame(box3, "Lines", UDim2.fromOffset(v3, v4), UDim2.fromOffset(-10, -64))
	local v44 = touch and 22 or 34
	local v45 = touch and 12 or 15
	local frame4 = Style.frame(box, "Side", UDim2.fromOffset(v7, v19), UDim2.fromOffset(26, v20))
	frame4.Visible = false
	local fill_2 = Style.fill(frame4, "Rule", color3, UDim2.new(0, 2, 1, 0), UDim2.fromOffset(-10, 0))
	fill_2.BackgroundTransparency = 0.3
	local label2 = Style.label(frame4, "Name", "", v44, Style.FONT, 1.5)
	label2.AutomaticSize = Enum.AutomaticSize.None
	label2.Size = UDim2.new(1, 0, 0, v44 + 4)
	label2.TextXAlignment = Enum.TextXAlignment.Left
	label2.TextTruncate = Enum.TextTruncate.AtEnd
	local label3 = Style.label(frame4, "About", "", v45, Style.FONT_BODY, 1)
	label3.AutomaticSize = Enum.AutomaticSize.None
	label3.Position = UDim2.fromOffset(0, v44 + 6)
	label3.Size = UDim2.new(1, 0, 0, v21 * (v45 + 3))
	label3.TextWrapped = true
	label3.TextTruncate = Enum.TextTruncate.AtEnd
	label3.TextXAlignment = Enum.TextXAlignment.Left
	label3.TextYAlignment = Enum.TextYAlignment.Top
	label3.TextColor3 = Style.MUTED
	local frame5 = Style.frame(frame4, "Status", UDim2.new(1, 0, 0, v5), UDim2.new(0, 0, 1, -v5))
	local button3, v46 = Style.button(
		frame5,
		"Fit",
		"",
		Style.HAZARD,
		UDim2.fromOffset(v27, v5),
		Style.INK,
		touch and 18 or 22
	)

	local folder, v47 = Style.button(
		frame5,
		"Off",
		"UNEQUIP",
		color2,
		UDim2.fromOffset(v27, v5),
		Style.HAZARD,
		touch and 18 or 22
	)

	for _, uiStroke in folder:GetDescendants() do
		if not uiStroke:IsA("UIStroke") then
			continue
		end

		uiStroke.Color = Style.HAZARD
		uiStroke.Thickness = 2
	end

	local fill4 = Style.fill(frame5, "Fitted", color2, UDim2.fromOffset(v27, v5))
	Style.corner(fill4, 3)
	Style.stroke(fill4, 2, 0, Style.HAZARD, true)
	local label4 = Style.label(fill4, "Text", "EQUIPPED", touch and 18 or 22, Style.FONT, 0)
	label4.AnchorPoint = Vector2.new(0.5, 0.5)
	label4.Position = UDim2.fromScale(0.5, 0.5)
	label4.TextColor3 = Style.HAZARD
	local label5 = Style.label(frame5, "Lock", "", touch and 13 or 15, Style.FONT, 1)
	label5.AnchorPoint = Vector2.new(0, 0.5)
	label5.Position = UDim2.fromScale(0, 0.5)
	label5.RichText = true

	local label6 = Style.label(frame5, "Lock2", "", touch and 13 or 15, Style.FONT, 1)
	label6.AnchorPoint = Vector2.new(0, 0.5)
	label6.Position = UDim2.new(0, 0, 0.5, 9)
	label6.Visible = false
	local label7 = Style.label(box, "Toast", "", 16, Style.FONT, 1.5)
	label7.AnchorPoint = Vector2.new(0.5, 0)
	label7.Position = UDim2.fromOffset(v3 / 2, 70)
	label7.Visible = false

	local fill5 = Style.fill(box, "Numbers", color, UDim2.fromOffset(v23, v17), UDim2.fromOffset(v22, v18))
	fill5.BackgroundTransparency = 0.35
	Style.corner(fill5, 3)
	fill5.Visible = false

	local v48 = math.floor((v17 - 8) / 3)
	local v49 = {}

	for i = 1, 3 do
		local frame6 = Style.frame(
			fill5,
			"Big" .. i,
			UDim2.fromOffset(v24, v48),
			UDim2.fromOffset(10, (i - 1) * v48 + 4)
		)
		local label8 = Style.label(frame6, "Label", "", 12, Style.FONT, 0)
		label8.TextColor3 = Style.MUTED
		local label9 = Style.label(frame6, "Value", "", touch and 20 or 28, Style.FONT, 0)
		label9.Position = UDim2.fromOffset(0, 13)
		local label10 = Style.label(frame6, "Note", "", 12, Style.FONT, 0)
		label10.AnchorPoint = Vector2.new(1, 0)
		label10.Position = UDim2.fromScale(1, 0)
		v49[i] = { label = label8, value = label9, note = label10 }
	end

	local v50 = v24 + 10 + (touch and 8 or 14)
	local v51 = v23 - v50 - 10
	local v52 = {}

	for i = 1, v26 do
		local frame6 = Style.frame(
			fill5,
			"Bar" .. i,
			UDim2.fromOffset(v51, v25),
			UDim2.fromOffset(v50, (i - 1) * v25 + 4)
		)
		local label8 = Style.label(frame6, "Label", "", touch and 12 or 13, Style.FONT, 0)
		label8.TextColor3 = Style.MUTED
		local label9 = Style.label(frame6, "Value", "", touch and 12 or 13, Style.FONT, 0)
		label9.AnchorPoint = Vector2.new(1, 0)
		label9.Position = UDim2.fromScale(1, 0)
		local label10 = Style.label(frame6, "Note", "", 12, Style.FONT, 0)
		label10.AnchorPoint = Vector2.new(1, 0)
		label10.Position = UDim2.new(1, -46, 0, 0)
		local fill6 = Style.fill(frame6, "Track", color9, UDim2.new(1, 0, 0, 2), UDim2.fromOffset(0, v25 - 8))
		local fill7 = Style.fill(fill6, "Base", Style.WHITE, UDim2.fromScale(0, 1))
		local fill8 = Style.fill(fill6, "Change", Style.HAZARD, UDim2.fromScale(0, 1))

		local frame7 = Style.frame(fill6, "Mark", UDim2.fromOffset(10, 5))
		frame7.AnchorPoint = Vector2.new(0.5, 0)
		frame7.ClipsDescendants = true
		local fill9 = Style.fill(frame7, "Tip", Style.WHITE, UDim2.fromOffset(7, 7), UDim2.fromOffset(5, 5))
		fill9.AnchorPoint = Vector2.new(0.5, 0.5)
		fill9.Rotation = 45
		v52[i] = {
			frame = frame6,
			label = label8,
			value = label9,
			note = label10,
			base = fill7,
			change = fill8,
			mark = frame7
		}
	end

	local options = Instance.new("ScrollingFrame")
	options.Name = "Options"
	options.BackgroundTransparency = 1
	options.BorderSizePixel = 0
	options.Position = UDim2.fromOffset(23, v18)
	options.Size = UDim2.fromOffset(v6 + 8, v17)
	options.ScrollingDirection = Enum.ScrollingDirection.Y
	options.ScrollBarThickness = 4
	options.ScrollBarImageColor3 = Style.HAZARD
	options.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
	options.Visible = false
	options.Parent = box

	local uiGridLayout = Instance.new("UIGridLayout")
	uiGridLayout.CellSize = UDim2.fromOffset(v14, v15)
	uiGridLayout.CellPadding = UDim2.fromOffset(6, 6)
	uiGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiGridLayout.Parent = options
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingTop = UDim.new(0, 3)
	uiPadding.PaddingBottom = UDim.new(0, 3)
	uiPadding.PaddingLeft = UDim.new(0, 3)
	uiPadding.PaddingRight = UDim.new(0, 5)
	uiPadding.Parent = options

	zAll(box3, 1)
	gun.ZIndex = 2
	zAll(frame3, 3)
	local v53 = {}

	for _, v54 in { fill, frame4, options, v41, fill5 } do
		zAll(v54, 4)
	end

	zAll(v41, 5)
	zAll(label7, 6)

	local v54 = nil
	local v55 = {}
	local v56 = {}
	local v57 = nil
	local v58 = nil
	local flag = false
	local count = 0
	local v59 = 0

	local v60 = {
		c = Vector3.new(0, 0, 0),
		d = 3,
		x = 0,
		y = 0,
		dir = 0
	}
	v60.x = v3 / 2
	v60.y = v4 / 2
	v60.dir = unit
	local v61 = 0
	local v62 = {}

	local v63 = {}

	local v64 = {}
	local fn

	local function slotOf(p3: string) -- 3 equivalent calls inferred from this helper
		if p3 == slot then
			return WeaponSkins.SLOT_INFO
		end

		return (Gunsmith2.slot(v54, p3))
	end

	local function optionOf(p3: string?, p4: string?) -- 4 equivalent calls inferred from this helper
		if p3 == nil or p4 == nil then
			return nil
		end

		if p3 == slot then
			return (WeaponSkins.find(p4))
		end

		return (Gunsmith2.option(v54, p3, p4))
	end

	local function bareOf(p3: string) -- 2 equivalent calls inferred from this helper
		if p3 == slot then
			return WeaponSkins.DEFAULT
		end

		return (Gunsmith2.bare(v54, p3))
	end

	local function isOpen(p3: string?, p4) -- 3 equivalent calls inferred from this helper
		if p3 == slot then
			return (WeaponSkins.unlocked(p2, v54, p4))
		end

		return (Gunsmith2.unlocked(p2, v54, p4))
	end

	local function picksOf(p3: string)
		local selected = not Gunsmith2.has(p3) and {} or Gunsmith2.picks(p2, p3)
		selected[slot] = WeaponSkins.pick(p2, p3)
		return selected
	end

	local function showToast(text: string) -- 7 equivalent calls inferred from this helper
		count += 1
		local v65 = count
		label7.Text = text
		label7.TextColor3 = color4
		label7.Visible = true
		task.delay(2.4, function()
			if v65 == count then
				label7.Visible = false
			end
		end)
	end

	local function basis(vector3: Vector3)
		local vectorToWorldSpace = CFrame.Angles(0, v59, 0):VectorToWorldSpace(vector3)
		local unit2 = (-vectorToWorldSpace):Cross(Vector3.new(0, 1, 0)).Unit
		return vectorToWorldSpace, unit2, unit2:Cross(-vectorToWorldSpace)
	end

	local function project(vector3: Vector3)
		local pointToObjectSpace = camera.CFrame:PointToObjectSpace(vector3)
		local v65 = math.max(-pointToObjectSpace.Z, 0.01)
		return Vector2.new(
			v3 / 2 + pointToObjectSpace.X / v65 / v28 * v3 / 2,
			v4 / 2 - pointToObjectSpace.Y / v65 / 0.1227845609029046 * v4 / 2
		)
	end

	local function updateLines()
		for _, v65 in v63 do
			local v66 = v62[v65.id]
			local visible

			if v57 == nil and v66 ~= nil then
				visible = v65.id ~= slot
			else
				visible = false
			end

			v65.line.Visible = visible
			v65.dot.Visible = visible

			if not visible then
				continue
			end

			local v68 = project(v66)
			local button4 = v65.button
			local vector2 = Vector2.new(
				button4.Position.X.Offset + v65.w / 2,
				button4.Position.Y.Offset + (not v65.up and 0 or v65.h + v9)
			)
			stretch(v65.line, vector2, v68, 2)
			v65.dot.Position = UDim2.fromOffset(v68.X, v68.Y)
		end
	end
	local function placeCam()
		local dir = v60.dir
		local vectorToWorldSpace = CFrame.Angles(0, v59, 0):VectorToWorldSpace(dir)
		local unit2 = (-vectorToWorldSpace):Cross(Vector3.new(0, 1, 0)).Unit
		local cross = unit2:Cross(-vectorToWorldSpace)

		local v65 = (v60.x - v3 / 2) / (v3 / 2)
		local v66 = (v4 / 2 - v60.y) / (v4 / 2)
		local v67 = v60.c + vectorToWorldSpace * v60.d - unit2 * (v65 * v28 * v60.d) - cross * (v66 * 0.1227845609029046 * v60.d)
		camera.CFrame = CFrame.lookAt(v67, v67 - vectorToWorldSpace)
		updateLines()
	end

	local function boxOf(items)
		local v65 = Vector3.new(1, 1, 1) * 1e999
		local v66 = Vector3.new(-1, -1, -1) * 1e999

		for _, item in items do
			local gsLo = item:GetAttribute("GsLo")
			local gsHi = item:GetAttribute("GsHi")

			if typeof(gsLo) == "Vector3" and typeof(gsHi) == "Vector3" then
				v65 = v65:Min(gsLo)
				v66 = v66:Max(gsHi)
			else
				local halfSize = item.Size / 2

				for _, v68 in { -1, 1 } do
					for _, v69 in { -1, 1 } do
						for _, v70 in { -1, 1 } do
							local pointToWorldSpace = item.CFrame:PointToWorldSpace(halfSize * Vector3.new(v68, v69, v70))
							v65 = v65:Min(pointToWorldSpace)
							v66 = v66:Max(pointToWorldSpace)
						end
					end
				end
			end
		end

		return v65, v66
	end

	local function distFor(vector3: Vector3, vector3_2: Vector3, data, vector3_3: Vector3)
		local vectorToWorldSpace = CFrame.Angles(0, v59, 0):VectorToWorldSpace(vector3_3)
		local unit2 = (-vectorToWorldSpace):Cross(Vector3.new(0, 1, 0)).Unit
		local cross = unit2:Cross(-vectorToWorldSpace)

		local v65 = vector3_2 - vector3
		local v66 = v28 * (data.x1 - data.x0) / v3
		local v67 = (data.y1 - data.y0) * 0.1227845609029046 / v4
		local maxValue = 0

		for _, v68 in { -0.5, 0.5 } do
			for _, v69 in { -0.5, 0.5 } do
				for _, v70 in { -0.5, 0.5 } do
					local vector = v65 * Vector3.new(v68, v69, v70)
					maxValue = math.max(
						maxValue,
						vector:Dot(vectorToWorldSpace) + math.max(
							math.abs((vector:Dot(unit2))) / v66,
							math.abs((vector:Dot(cross))) / v67
						)
					)
				end
			end
		end

		return maxValue
	end

	local function aim(flag2: boolean)
		local parts = {}
		local parts2 = {}

		for _, part in model:GetChildren() do
			if not part:IsA("BasePart") then
				continue
			end

			table.insert(parts, part)

			if v57 and (v57 == slot or part:GetAttribute("GsSlot") == v57) then
				table.insert(parts2, part)
			end
		end

		if #parts == 0 then
			return
		end

		local v65, v66 = boxOf(parts)
		local v67 = distFor(v65, v66, v30, unit) * 1.04
		local v68

		if #parts2 > 0 then
			local v69, v70 = boxOf(parts2)
			local v71 = v29[v57]
			local v72 = v57 == slot and 0 or 0.3
			v68 = {
				c = ((v69 + v70) / 2):Lerp((v65 + v66) / 2, v72),
				d = math.max(v67 * v71.zoom, distFor(v69, v70, v31, v71.dir) * (v57 == slot and 1 or 1.5)),
				x = (v31.x0 + v31.x1) / 2,
				y = (v31.y0 + v31.y1) / 2,
				dir = v71.dir
			}
		else
			v68 = {
				c = (v65 + v66) / 2,
				d = v67,
				x = (v30.x0 + v30.x1) / 2,
				y = (v30.y0 + v30.y1) / 2,
				dir = unit
			}
		end

		if flag2 then
			v60 = v68
			v59 = 0
			Style.stop(camera)
			placeCam()
		else
			local v69 = v60
			local v70 = v59
			v61 = os.clock()
			Style.animate(camera, function(_, p3: number): boolean
				local v71 = math.min((p3 - v61) / 0.3, 1)
				local smoothed = Style.smooth(v71)
				v60 = {
					c = v69.c:Lerp(v68.c, smoothed),
					d = v69.d + (v68.d - v69.d) * smoothed,
					x = v69.x + (v68.x - v69.x) * smoothed,
					y = v69.y + (v68.y - v69.y) * smoothed,
					dir = v69.dir:Lerp(v68.dir, smoothed).Unit
				}

				v59 = v70 * (1 - smoothed)
				placeCam()
				return v71 < 1
			end)
		end
	end

	local v65 = nil
	local function endFx() -- 2 equivalent calls inferred from this helper
		if v65 then
			v65()
			v65 = nil
		end
	end
	local function drawGun()
		endFx() -- inferred equivalent call
		model:ClearAllChildren()

		gun.Ambient = Color3.fromRGB(175, 175, 185)
		gun.LightColor = Color3.new(1, 1, 1)

		if v56[slot] == WeaponSkins.GOLD then
			WeaponSkins.goldLight(gun)
		end

		local v66

		if Gunsmith2.has(v54) then
			v66 = Gunsmith2.preview(v54, v56)
		else
			v66 = plainGun(v54)
		end

		WeaponSkins.paint(v66, v56[slot])
		local v67 = {}

		for _, part in v66:GetChildren() do
			if not part:IsA("BasePart") then
				continue
			end

			for _, child in part:GetChildren() do
				if child:IsA("DataModelMesh") or child:IsA("Decal") or child:IsA("SurfaceAppearance") then
					continue
				end

				child:Destroy()
			end

			part.Anchored = true
			part.Parent = model
			local gsSlot = part:GetAttribute("GsSlot")

			if type(gsSlot) ~= "string" then
				continue
			end

			v67[gsSlot] = v67[gsSlot] or {}
			table.insert(v67[gsSlot], part)
		end

		v66:Destroy()

		table.clear(v62)

		for k, v68 in v67 do
			local v69 = -1
			local v70 = nil

			for _, v71 in v68 do
				local v72, v73 = boxOf({ v71 })
				local v74 = v73 - v72
				local v75

				if k == "Underbarrel" then
					v75 = v74.Y
				else
					v75 = v74.X * v74.Y * v74.Z
				end

				if not (v71.Transparency < 1 and v69 < v75) then
					continue
				end

				v70 = (v72 + v73) / 2
				v69 = v75
			end

			v62[k] = v70
		end

		if Gunsmith2.has(v54) and Gunsmith2.slot(v54, "Underbarrel") then
			local underbarrel = v56.Underbarrel
			local v68

			if slot == "Underbarrel" then
				v68 = WeaponSkins.DEFAULT
			else
				v68 = Gunsmith2.bare(v54, "Underbarrel")
			end

			if underbarrel == v68 then
				local underbarrel2 = v67.Underbarrel
				local v69

				if underbarrel2 then
					local v70, v71 = boxOf(underbarrel2)
					v69 = math.max(v71.X - v70.X, v71.Y - v70.Y, v71.Z - v70.Z)
				else
					v69 = 0
				end

				if v69 < 0.16 then
					v62.Underbarrel = Gunsmith2.mount(v54, "Underbarrel") or v62.Underbarrel
				end
			end
		end

		if Gunsmith2.has(v54) then
			for _, slot2 in Gunsmith2.GUNS[v54].slots do
				if not v62[slot2.id] then
					v62[slot2.id] = Gunsmith2.mount(v54, slot2.id)
				end
			end
		end

		if SkinGlow.hasFx(v56[slot]) then
			local parts = {}

			for _, part in model:GetChildren() do
				if part:IsA("BasePart") then
					table.insert(parts, part)
				end
			end

			if #parts > 0 then
				local v68, v69 = boxOf(parts)
				v65 = SkinGlow.fx(gun, v68, v69, v56[slot])
			end
		end

		updateLines()
	end

	local function placeCallouts()
		local midpointY = (v30.y0 + v30.y1) / 2
		local v67 = { [true] = {}, [false] = {} }

		for _, v68 in v63 do
			local v69 = v62[v68.id]
			local v70

			if v69 then
				v70 = project(v69)
			else
				v70 = Vector2.new(v3 / 2, midpointY)
			end

			v68.up = v70.Y < midpointY

			if v68.id == slot then
				v68.up = false
				v70 = Vector2.new(-1e999, midpointY)
			end

			table.insert(v67[v68.up], {
				c = v68,
				x = v70.X - v68.w / 2
			})
		end

		for k, list in v67 do
			table.sort(list, function(a, b): boolean
				return a.x < b.x
			end)

			local v68 = v3 - 10 - 8 - (k and 208 or 0)
			local v69 = 18

			for k2, item in list do
				item.x = math.max(item.x, v69, not (k2 > 1) and 18 or list[k2 - 1].x + list[k2 - 1].c.w + v10)
			end

			for i = #list, 1, -1 do
				local item = list[i]
				local x = item.x
				local v70

				if i < #list then
					v70 = list[i + 1].x - item.c.w - v10
				else
					v70 = v68 - item.c.w
				end

				item.x = math.min(x, v70)
			end

			for _, item in list do
				local v70 = k and 72 or v4 - 10 - 8 - item.c.h - (item.c.id == slot and 0 or v9)
				item.c.button.Position = UDim2.fromOffset(math.round(item.x), v70)
			end
		end

		updateLines()
	end

	local v66 = nil
	local v67 = 0
	local v68 = nil
	local function endDrag() -- 3 equivalent calls inferred from this helper
		v66 = nil

		if v68 then
			for _, connection in v68 do
				connection:Disconnect()
			end

			v68 = nil
		end
	end
	gun.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			v66 = input
			v67 = input.Position.X

			if not v68 then
				v68 = {
					UserInputService.InputChanged:Connect(function(input2)
						if v66 and (input2.UserInputType == Enum.UserInputType.MouseMovement or input2 == v66) then
							v59 -= (input2.Position.X - v67) * 0.012
							v67 = input2.Position.X
							placeCam()
						end
					end),
					UserInputService.InputEnded:Connect(function(input2)
						if v66 and (input2 == v66 or input2.UserInputType == Enum.UserInputType.MouseButton1) then
							endDrag() -- inferred equivalent call
						end
					end)
				}
			end

			local userInputState = input.UserInputState

			if userInputState == Enum.UserInputState.End or userInputState == Enum.UserInputState.Cancel then
				endDrag() -- inferred equivalent call
			end
		end
	end)

	local function stamp() -- 1 equivalent call inferred from this helper
		local MenuAudio = require(script.Parent:WaitForChild("MenuAudio"))

		if MenuAudio.stamp then
			MenuAudio.stamp()
		end
	end

	local function showNumber(data, value: number, value2, note)
		value2.Text = data.text
		local v69 = data.value - value
		local textColor = Style.WHITE

		if math.abs(v69) < 1e-6 then
			note.Text = ""
		else
			local v71

			if data.lower then
				v71 = v69 < 0
			else
				v71 = v69 > 0
			end

			if data.neutral then
				textColor = Style.WHITE
			else
				textColor = if v71 then color10 else color11
			end

			note.Text = data.delta(v69, value)
		end

		note.TextColor3 = textColor
		value2.TextColor3 = textColor
		return textColor
	end

	local function refreshNumbers()
		if not Gunsmith2.has(v54) then
			return
		end

		local v69 = numbersOf(p2, v54, v56)
		local v70 = numbersOf(p2, v54, v55)
		local v71, v72 = gunNumbers(v54)

		for k, v73 in {
			{ "DMG", v71 },
			{ "RPM", v72 }
		} do
			v49[k].label.Text = v73[1]
			v49[k].value.Text = v73[2]
			v49[k].value.TextColor3 = Style.WHITE
			v49[k].note.Text = ""
		end

		local v73 = v57 == "Optic" and 1 or 5
		v49[3].label.Text = v69[v73].label
		showNumber(v69[v73], v70[v73].value, v49[3].value, v49[3].note)

		for k, v74 in v52 do
			local v75 = v53[k]
			v74.frame.Visible = v75 ~= nil

			if not v75 then
				continue
			end

			local v76 = v69[v75]
			local value = v70[v75].value
			v74.label.Text = v76.label
			local backgroundColor = showNumber(v76, value, v74.value, v74.note)
			local function share(p3: number) -- 3 equivalent calls inferred from this helper
				return (math.clamp(p3 / v35[v75], 0, 1))
			end

			local v78 = share(math.min(v76.value, value)) -- inferred equivalent call
			local v79 = share(math.max(v76.value, value)) -- inferred equivalent call
			v74.base.Size = UDim2.fromScale(v78, 1)
			v74.change.Position = UDim2.fromScale(v78, 0)
			v74.change.Size = UDim2.fromScale(v79 - v78, 1)
			v74.change.BackgroundColor3 = backgroundColor
			v74.mark.Position = UDim2.new(share(value), 0, 0, 3) -- inferred equivalent call
		end
	end

	local function refreshWords()
		local child = ReplicatedStorage:WaitForChild("ToolTemplates"):FindFirstChild(v54)
		local text = child and child:GetAttribute("DisplayName")

		if type(text) ~= "string" then
			text = string.upper(v54)
		end

		local v70 = optionOf(v57, v58) -- inferred equivalent call
		frame4.Visible = v70 ~= nil
		fill5.Visible = v70 ~= nil and v57 ~= slot and Gunsmith2.has(v54)
		button3.Visible = false
		folder.Visible = false
		fill4.Visible = false
		label5.Visible = false
		label6.Visible = false
		label5.Position = UDim2.fromScale(0, 0.5)

		if not (v57 and v70) then
			label.Text = text
			return
		end

		label.Text = text .. "  /  " .. slotOf(v57).label -- inferred equivalent call
		label2.Text = v70.name
		label3.Text = v70.about

		if v55[v57] == v58 then
			folder.Visible = bareOf(v57) ~= v58 -- inferred equivalent call
			fill4.Visible = not folder.Visible
			v47.Text = flag and "UNEQUIPPING..." or "UNEQUIP"
		elseif isOpen(v57, v70) then -- inferred equivalent call
			button3.Visible = true
			v46.Text = flag and "EQUIPPING..." or "EQUIP"
			button3.AutoButtonColor = not flag
			local backgroundColor

			if flag then
				backgroundColor = Style.STEEL
			else
				backgroundColor = Style.HAZARD
			end

			button3.BackgroundColor3 = backgroundColor
		else
			label5.Visible = true

			if v57 == slot and v70.challenge then
				local needs = WeaponSkins.needs(p2, v54, v70)
				label5.Position = UDim2.new(0, 0, 0.5, -9)

				for k, v73 in { label5, label6 } do
					v73.Visible = true
					v73.Text = needs[k].text
					local textColor

					if needs[k].done then
						textColor = Style.MUTED
					else
						textColor = color4
					end

					v73.TextColor3 = textColor
				end
			else
				if v57 ~= slot or not (v70.bundle or v70.streak) then
					label5.Text = Style.paint(string.format("WEAPON LEVEL %d", v70.level), color4) .. Style.paint(
						string.format("  /  NOW: %d", Mastery.level(p2, v54)),
						Style.DIM
					)
					return
				end

				label5.Text = WeaponSkins.needs(p2, v54, v70)[1].text
				label5.TextColor3 = color4
			end
		end
	end

	local function refreshCallouts()
		for _, v69 in v63 do
			local v70 = optionOf(v69.id, v55[v69.id]) -- inferred equivalent call
			v69.name.Text = not v70 and "" or v70.name
			v69.tag.Text = not (v70 and v70.tag) and "" or v70.tag
			v69.button.Visible = v57 == nil

			if v69.shows == v55[v69.id] then
				continue
			end

			v69.holder:ClearAllChildren()
			v69.shows = v55[v69.id]
			fn(v69.holder, v69.id, v55[v69.id])
		end
	end

	local function refreshTiles()
		if not v57 then
			return
		end

		for _, v69 in v64 do
			local v70 = optionOf(v57, v69.id) -- inferred equivalent call
			local v71 = v69.id == v58
			local visible = v55[v57] == v69.id
			local open = isOpen(v57, v70) -- inferred equivalent call
			local button4 = v69.button
			local backgroundColor = if v71 then color2 else color
			button4.BackgroundColor3 = backgroundColor
			local stroke = v69.stroke
			local color12 = if v71 then Style.HAZARD else color3
			stroke.Color = color12
			v69.stroke.Thickness = v71 and 2.5 or 1.5
			v69.check.Visible = visible
			v69.icon.ImageTransparency = open and 0 or 0.55
			local name = v69.name
			local textColor = if open then Style.WHITE else Style.DIM
			name.TextColor3 = textColor

			if open then
				v69.top.Text = v70.tag or ""
				v69.top.TextColor3 = Style.MUTED
			else
				local top = v69.top
				local text

				if v57 == slot then
					text = WeaponSkins.lockTag(p2, v54, v70)
				else
					text = string.format("LV %d", v70.level)
				end

				top.Text = text
				v69.top.TextColor3 = color4
			end
		end
	end

	local function fn2()
		if not v54 then
			return
		end

		local level, v69, v70 = Mastery.levelOf(Mastery.xp(p2, v54))
		parent2.Text = string.format("WEAPON LEVEL %d", level)

		if v70 > 0 then
			local v71 = math.ceil((v70 - v69) / Mastery.KILL_XP)
			parent3.Text = string.format("%d %s TO %d", v71, v71 == 1 and "KILL" or "KILLS", level + 1)
		else
			parent3.Text = "MAX"
		end

		fill3.Size = UDim2.fromScale(not (v70 > 0) and 1 or math.clamp(v69 / v70, 0, 1), 1)
		refreshCallouts()
		refreshTiles()
		refreshNumbers()
		refreshWords()
	end

	local function reshow()
		local clone = table.clone(v55)

		if v57 and v58 then
			clone[v57] = v58
		end

		local v69 = true

		for k, v70 in clone do
			v69 = v69 and v56[k] == v70
		end

		v56 = clone

		if not v69 then
			drawGun()

			if v57 then
				aim(false)
			end
		end

		fn2()
	end

	local function selectOption(id: string) -- 1 equivalent call inferred from this helper
		v58 = id
		reshow()
	end

	local function fit2()
		local v69 = optionOf(v57, v58) -- inferred equivalent call

		if flag or not v69 or v55[v57] == v58 then
			return
		end

		if isOpen(v57, v69) then -- inferred equivalent call
			flag = true
			refreshWords()
			local remote = Gunsmith:WaitForChild("Remote")
			local v70 = v54
			local v71 = v57
			local v72 = v58
			local success, result, v73 = pcall(remote.InvokeServer, remote, "pick", v70, v71, v72)
			flag = false

			if v54 ~= v70 or v57 ~= v71 then
				return
			end

			if success then
				if result == true then
					if v57 ~= slot then
						GearSound.fit(v57)
					end

					stamp() -- inferred equivalent call
					v55 = picksOf(v54)
					v55[v57] = v72
				else
					showToast(string.upper(type(v73) ~= "string" and "COULD NOT EQUIP" or v73)) -- inferred equivalent call
				end
			else
				warn("[Workbench] request failed: " .. tostring(result))
				showToast("NO ANSWER FROM THE WORKBENCH") -- inferred equivalent call
			end

			reshow()
		elseif v57 == slot and v69.class then
			showToast("EARN GOLD ON EVERY GUN OF THIS CLASS") -- inferred equivalent call
		elseif v57 == slot and v69.challenge then
			showToast("EARN EVERY OTHER CAMO AND BEAT THE CHALLENGE") -- inferred equivalent call
		elseif v57 == slot and v69.bundle then
			showToast(WeaponSkins.BUNDLE_NEED) -- inferred equivalent call
		elseif v57 == slot and v69.streak then
			showToast(WeaponSkins.STREAK_NEED) -- inferred equivalent call
		else
			showToast(string.format("UNLOCKS AT WEAPON LEVEL %d", v69.level)) -- inferred equivalent call
		end
	end
	button3.Activated:Connect(fit2)

	folder.Activated:Connect(function()
		if flag or not v57 then
			return
		end

		v58 = bareOf(v57) -- inferred equivalent call
		reshow()
		fit2()
	end)

	local fn3

	local function buildCallouts()
		for _, v69 in v63 do
			v69.button:Destroy()
			v69.line:Destroy()
			v69.dot:Destroy()
		end

		table.clear(v63)
		local SLOT_INFOs = not Gunsmith2.has(v54) and {} or table.clone(Gunsmith2.GUNS[v54].slots)
		table.insert(SLOT_INFOs, WeaponSkins.SLOT_INFO)

		for _, v69 in SLOT_INFOs do
			local textButton = Instance.new("TextButton")
			textButton.Name = v69.id
			textButton.Text = ""
			textButton.AutoButtonColor = true
			textButton.BorderSizePixel = 0
			textButton.BackgroundColor3 = color
			local v70 = v69.id == slot
			local v71 = if v70 then v11 else v8
			local v72 = if v70 then v12 else v8
			textButton.Size = UDim2.fromOffset(v71, v72)
			textButton.Parent = box
			Style.corner(textButton, 3)
			local stroke = Style.stroke(textButton, 1.5, 0, color3, true)
			local holder, tag, name

			if v70 then
				holder = Style.frame(
					textButton,
					"Picture",
					UDim2.fromOffset(v13, v72 - 8),
					UDim2.new(1, -(v13 + 4), 0, 4)
				)
				local label8 = Style.label(textButton, "Slot", v69.label, 12, Style.FONT, 0)
				label8.Position = UDim2.fromOffset(8, 3)
				label8.TextColor3 = Style.MUTED
				tag = Style.label(textButton, "Tag", "", 12, Style.FONT, 0)
				tag.AnchorPoint = Vector2.new(1, 0)
				tag.Position = UDim2.new(1, -(v13 + 8), 0, 3)
				tag.TextColor3 = Style.HAZARD
				name = Style.label(textButton, "Name", "", touch and 15 or 18, Style.FONT, 0)
				name.AnchorPoint = Vector2.new(0, 1)
				name.Position = UDim2.new(0, 8, 1, -3)
				name.TextColor3 = Style.WHITE
			else
				holder = Style.frame(
					textButton,
					"Picture",
					UDim2.fromOffset(v71 - 10, v72 - 10),
					UDim2.fromOffset(5, 5)
				)
				tag = Style.label(textButton, "Tag", "", 12, Style.FONT, 0)
				tag.Visible = false
				name = Style.label(textButton, "Name", "", touch and 12 or 13, Style.FONT, 1.5)
				name.AnchorPoint = Vector2.new(0.5, 0)
				name.Position = UDim2.new(0.5, 0, 1, 2)
				name.TextColor3 = Style.WHITE
			end

			local fill6 = Style.fill(frame3, v69.id, Style.HAZARD, UDim2.new())
			fill6.BackgroundTransparency = 0.45
			local fill7 = Style.fill(frame3, v69.id .. "Dot", Style.HAZARD, UDim2.fromOffset(8, 8))
			fill7.AnchorPoint = Vector2.new(0.5, 0.5)
			Style.stroke(fill7, 1.5, 0, Style.INK, true)
			zAll(textButton, 5)
			fill6.ZIndex = 3
			fill7.ZIndex = 3
			local v76 = {
				id = v69.id,
				button = textButton,
				name = name,
				tag = tag,
				stroke = stroke,
				line = fill6,
				dot = fill7,
				up = true,
				holder = holder,
				w = v71,
				h = v72
			}
			local function hot(flag2: boolean)
				local color12 = if flag2 then Style.HAZARD else color3
				stroke.Color = color12
				fill6.BackgroundTransparency = flag2 and 0 or 0.45
			end
			textButton.MouseEnter:Connect(function()
				stroke.Color = Style.HAZARD
				fill6.BackgroundTransparency = 0
			end)
			textButton.MouseLeave:Connect(function()
				stroke.Color = color3
				fill6.BackgroundTransparency = 0.45
			end)
			textButton.SelectionGained:Connect(function()
				stroke.Color = Style.HAZARD
				fill6.BackgroundTransparency = 0
			end)
			textButton.SelectionLost:Connect(function()
				stroke.Color = color3
				fill6.BackgroundTransparency = 0.45
			end)
			textButton.Activated:Connect(function()
				stroke.Color = color3
				fill6.BackgroundTransparency = 0.45

				fn3(v76.id)
			end)
			table.insert(v63, v76)
		end
	end

	fn = function(parent, p3: string, p4: string)
		local icon = Instance.new("ImageLabel")
		icon.Name = "Icon"
		icon.BackgroundTransparency = 1
		icon.BorderSizePixel = 0
		icon.Size = UDim2.fromScale(1, 1)
		icon.ScaleType = Enum.ScaleType.Fit
		icon.ZIndex = parent.ZIndex
		icon.Parent = parent

		if p3 == slot then
			local v69 = WeaponSkins.find(p4)
			icon.AnchorPoint = Vector2.new(0.5, 0.5)
			icon.Position = UDim2.fromScale(0.5, 0.5)
			local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
			uiAspectRatioConstraint.AspectRatio = 1
			uiAspectRatioConstraint.Parent = icon
			Style.corner(icon, 3)
			Style.stroke(icon, 1.5, 0, Style.INK, true)

			if v69 and v69.image then
				icon.Image = v69.image
				icon.ScaleType = Enum.ScaleType.Crop
				return icon
			else
				icon.BackgroundTransparency = 0
				local backgroundColor

				if v69 and v69.metal then
					backgroundColor = v69.metal
				else
					backgroundColor = Color3.fromRGB(52, 54, 58)
				end

				icon.BackgroundColor3 = backgroundColor

				if not v69 or v69.material ~= Enum.Material.Metal then
					return icon
				end

				local uiGradient = Instance.new("UIGradient")
				uiGradient.Rotation = 45
				uiGradient.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 150, 150)),
					ColorSequenceKeypoint.new(0.45, Color3.new(1, 1, 1)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 120, 120))
				})

				uiGradient.Parent = icon

				return icon
			end
		else
			local rect = Icons.rects[string.format("%s/%s/%s", v54, p3, p4)]

			if not rect then
				warn(string.format(
					"[Workbench] no icon for %s %s %s (analysis/optimization/toolicon-atlas/attachment)",
					tostring(v54),
					p3,
					p4
				))
				return icon
			end

			icon.Image = Icons.sheets[rect[5]]
			icon.ImageRectOffset = Vector2.new(rect[1], rect[2])
			icon.ImageRectSize = Vector2.new(rect[3], rect[4])
			return icon
		end
	end

	local function buildTiles()
		for _, v69 in v64 do
			v69.button:Destroy()
		end

		table.clear(v64)
		local v69 = slotOf(v57) -- inferred equivalent call

		for k, option in v69.options do
			if not (not option.crate or v or WeaponSkins.ownsCrate(p2, option.id, WeaponSkins.classOf(v54))) then
				continue
			end

			if not (not option.bundle or Skins.PAID_ON and v2 or WeaponSkins.ownsCrate(p2, option.id)) then
				continue
			end

			local textButton = Instance.new("TextButton")
			textButton.Name = option.id
			textButton.Text = ""
			textButton.AutoButtonColor = true
			textButton.BorderSizePixel = 0
			textButton.BackgroundColor3 = color
			textButton.LayoutOrder = k
			textButton.Parent = options
			Style.corner(textButton, 3)
			local stroke = Style.stroke(textButton, 1.5, 0, color3, true)

			local v70 = v15 - 15 - v16
			local frame6 = Style.frame(textButton, "Picture", UDim2.fromOffset(v14 - 14, v70), UDim2.fromOffset(7, 15))
			local icon = fn(frame6, v57, option.id)
			local label8 = Style.label(textButton, "Top", "", 12, Style.FONT, 0)
			label8.Position = UDim2.fromOffset(6, 1)

			local fill6 = Style.fill(textButton, "Check", color6, UDim2.fromOffset(28, 28))
			fill6.BackgroundTransparency = 0.74
			fill6.AnchorPoint = Vector2.new(0.5, 0.5)
			fill6.Position = UDim2.fromOffset(v14 / 2, v70 * 0.7 + 15)
			Style.corner(fill6, 4)
			local fill7 = Style.fill(fill6, "Box", color5, UDim2.fromOffset(24, 24), UDim2.fromOffset(2, 2))
			Style.corner(fill7, 2)
			Style.stroke(fill7, 1.5, 0, color6, true)

			local uiScale = Instance.new("UIScale")
			uiScale.Scale = touch and 0.62 or 0.75
			uiScale.Parent = fill6

			stretch(
				Style.fill(fill7, "Short", color7, UDim2.new()),
				Vector2.new(6.5, 12.5),
				Vector2.new(10.5, 16.5),
				2.5
			)
			stretch(Style.fill(fill7, "Long", color7, UDim2.new()), Vector2.new(9.8, 16.5), Vector2.new(18, 8), 2.5)
			local label9 = Style.label(textButton, "Name", option.name, touch and 12 or 14, Style.FONT, 0)
			label9.AnchorPoint = Vector2.new(0, 1)
			label9.Position = UDim2.new(0, 5, 1, -1)
			zAll(textButton, 5)
			zAll(fill6, 6)
			local id = option.id
			textButton.Activated:Connect(function()
				selectOption(id) -- inferred equivalent call
			end)
			table.insert(v64, {
				id = id,
				button = textButton,
				stroke = stroke,
				top = label8,
				name = label9,
				check = fill6,
				icon = icon
			})
		end
	end

	local v69 = {}
	v69.root = region

	fn3 = function(id: string)
		v57 = id
		v58 = v55[id]
		buildTiles()
		options.Visible = true
		local v70

		if id == slot then
			v70 = not touch
		else
			v70 = false
		end

		local position

		if v70 then
			position = UDim2.fromOffset(v22 + 12, v18 + 8)
		else
			position = UDim2.fromOffset(26, v20)
		end

		frame4.Position = position
		local size

		if v70 then
			size = UDim2.fromOffset(v23 - 20, v17 - 16)
		else
			size = UDim2.fromOffset(v7, v19)
		end

		frame4.Size = size
		v31.x0 = v70 and 26 or x0
		local y1

		if id == slot and touch then
			y1 = v4 - 10 - 8 - 8
		else
			y1 = v18 - 10
		end

		v31.y1 = y1

		table.clear(v53)

		if id ~= slot and Gunsmith2.has(v54) then
			local v74 = numbersOf(p2, v54, v55)
			local set = {}
			local v75 = slotOf(id) -- inferred equivalent call

			for _, option in v75.options do
				local clone = table.clone(v55)
				clone[id] = option.id

				for k, v76 in numbersOf(p2, v54, clone) do
					if math.abs(v76.value - v74[k].value) > 1e-6 then
						set[k] = true
					end
				end
			end

			for _, v76 in v36 do
				if set[v76] and #v53 < v26 then
					table.insert(v53, v76)
				end
			end
		end

		local v74 = math.max(1, (v6 + 6) // (v14 + 6))
		options.CanvasSize = UDim2.fromOffset(0, math.ceil(#v64 / v74) * (v15 + 6) + 6)
		options.CanvasPosition = Vector2.zero

		for k, v75 in v64 do
			if v75.id == v58 then
				options.CanvasPosition = Vector2.new(0, (k - 1) // v74 * (v15 + 6) * box.AbsoluteSize.X / v3)
			end
		end

		reshow()
		updateLines()
		aim(false)
		local PadMenus = require(script.Parent:WaitForChild("PadMenus"))
		PadMenus.reseat()
	end

	function v69.firstPad()
		if v57 then
			for _, v70 in v64 do
				if v70.id == v58 then
					return v70.button
				end
			end

			return if v64[1] then v64[1].button else nil
		else
			return if v63[1] then v63[1].button else nil
		end
	end

	function v69.back(): boolean
		if not v57 then
			return false
		end

		local v70 = v57
		v57 = nil
		v58 = nil
		options.Visible = false
		reshow()
		aim(false)
		local PadMenus = require(script.Parent:WaitForChild("PadMenus"))
		PadMenus.reseat()

		for _, v71 in v63 do
			if v71.id ~= v70 then
				continue
			end

			local GuiService = game:GetService("GuiService")

			if GuiService.SelectedObject then
				GuiService.SelectedObject = v71.button
			end
		end

		return true
	end

	button.Activated:Connect(function()
		if not v69.back() and v69.onBack then
			v69.onBack()
		end
	end)
	button2.Activated:Connect(function()
		if v69.onClose then
			v69.onClose()
		end
	end)

	function v69.show(p3: string)
		v54 = p3
		v55 = picksOf(p3)
		v57 = nil
		v58 = nil
		options.Visible = false
		buildCallouts()
		v56 = table.clone(v55)
		drawGun()
		v59 = 0
		aim(true)
		placeCallouts()
		fn2()
		region.Visible = true
		local now = os.clock()
		Style.animate(region, function(_, p4: number): boolean
			local v70 = math.min((p4 - now) / 0.16, 1)
			fit(0.92 + 0.08 * Style.easeOut(v70))
			return v70 < 1
		end)
	end

	function v69.hide()
		region.Visible = false
		endDrag() -- inferred equivalent call
		Style.stop(camera)
		endFx() -- inferred equivalent call
		model:ClearAllChildren()
		v54 = nil
	end

	function v69.isOpen()
		return region.Visible
	end

	p2.AttributeChanged:Connect(function(value: string)
		if not (region.Visible and v54) then
			return
		end

		if
			string.sub(value, 1, 3) == "Mx_"
			or value == "UnlockAll"
			or string.sub(value, 1, 5) == "Gold_"
			or string.sub(value, 1, 3) == "Gs_"
			or string.sub(value, 1, 3) == "Cs_"
			or string.sub(value, 1, 3) == "Ck_"
		then
			if string.sub(value, 1, 3) == "Gs_" and not flag then
				v55 = picksOf(v54)
				reshow()
			else
				fn2()
			end
		end
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
		if gameProcessed or not region.Visible then
			return
		end

		if input.KeyCode == Enum.KeyCode.Backspace then
			if not v69.back() and v69.onBack then
				v69.onBack()
			end
		elseif input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.ButtonY then
			fit2()
		end
	end)

	return v69
end

function Workbench.hook(data)
	if not Gunsmith2 then
		return {
			sync = function(_: string?) end,
			isOpen = function(): boolean
				return false
			end,
			close = function() end,
			dressed = function(_: string): nil
				return nil
			end
		}
	end

	local player = data.player
	local action = data.action
	local offset = action.Size.Y.Offset
	local button, v38 = Style.button(
		data.parent,
		"Customize",
		"CUSTOMIZE",
		Style.HAZARD,
		UDim2.fromOffset(data.width, offset),
		Style.INK,
		18
	)
	button.Position = UDim2.fromOffset(action.Position.X.Offset, action.Position.Y.Offset - offset - 6)
	button.Visible = false
	local v39 = nil
	local v40 = nil
	local v41 = {}
	local v42 = nil

	local function leave()
		local v43 = v39

		if not (v43 and v43.isOpen()) then
			return
		end

		v43.hide()
		local PadMenus = require(script.Parent:WaitForChild("PadMenus"))
		PadMenus.close("workbench")
		data.hide(false)
		data.closed()
	end

	function v41.sync(p: string?)
		local visible

		if p == nil then
			visible = false
		else
			visible = action.Visible and (Gunsmith2.has(p) or WeaponSkins.has(p)) and ShopData.owns(player, p)
		end

		if not visible then
			p = nil
		end

		v40 = p
		button.Visible = visible
		data.room(visible)
	end
	function v41.isOpen()
		return v39 ~= nil and v39.isOpen()
	end

	function v41.close()
		leave()
	end
	function v41.dressed(name: string)
		local v43

		if WeaponSkins.has(name) then
			v43 = WeaponSkins.pick(player, name)
		else
			v43 = WeaponSkins.DEFAULT
		end

		if Gunsmith2.has(name) then
			v42 = name
			local dressed = Gunsmith2.dressed(player, name)

			if dressed then
				WeaponSkins.paint(dressed, v43)
			end

			if not dressed then
				Gunsmith2.askDressed(player, name, function()
					if v42 == name and not v41.isOpen() then
						data.closed()
					end
				end)
			end

			return dressed
		else
			if v43 == WeaponSkins.DEFAULT then
				return nil
			end

			local v44 = plainGun(name)
			WeaponSkins.paint(v44, v43)
			return v44
		end
	end

	local v43 = false
	button.Activated:Connect(function()
		local v44 = v40

		if not v44 or v43 then
			return
		end

		v43 = true
		v38.Text = "LOADING"
		local v45 = not Gunsmith2.has(v44) or Gunsmith2.loadKit(v44)
		v38.Text = "CUSTOMIZE"
		v43 = false
		assert(v45, "[Workbench] the kit for " .. v44 .. " never came")

		if v40 ~= v44 or not button.Visible then
			return
		end

		if not v39 then
			local v46 = build(data.layer, player)
			v46.onBack = leave
			v46.onClose = data.closeAll
			v39 = v46
		end

		local v46 = v39
		data.hide(true)
		v46.show(v44)
		local PadMenus = require(script.Parent:WaitForChild("PadMenus"))
		PadMenus.open("workbench", v46.root, function()
			if not v46.back() then
				leave()
			end
		end, { first = v46.firstPad })
	end)
	return v41
end

function Workbench._preview(p, p2, p3: string)
	local v38 = build(p, p2)
	v38.show(p3)
	return v38
end

return Workbench