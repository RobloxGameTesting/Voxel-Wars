local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ToolTemplates = ReplicatedStorage2:WaitForChild("ToolTemplates")
local UserInputService = game:GetService("UserInputService")

local Viewmodel = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("Viewmodel"))
local Style = require(script.Parent:WaitForChild("Style"))
local Glyph = require(script.Parent:WaitForChild("Glyph"))
local MenuAudio = require(script.Parent:WaitForChild("MenuAudio"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local GearSound = require(ReplicatedStorage3:WaitForChild("Voxel"):WaitForChild("GearSound"))
local ToolIcon = require(script.Parent:WaitForChild("ToolIcon"))
local WeaponSkins = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("WeaponSkins"))
local StreakIcon = require(script.Parent:WaitForChild("StreakIcon"))
local LoadoutData = require(script.Parent:WaitForChild("LoadoutData"))
local SkinPreview = require(script.Parent:WaitForChild("SkinPreview"))
local OutfitLook = require(script.Parent:WaitForChild("OutfitLook"))

local NewMenus = require(script.Parent:WaitForChild("NewMenus"))
local v = NewMenus.on("Outfits")

local NewMenus2 = require(script.Parent:WaitForChild("NewMenus"))
local v2 = NewMenus2.on("Quests")

local NewMenus3 = require(script.Parent:WaitForChild("NewMenus"))
local v3 = NewMenus3.on("Vehicles")
local CardSelect = require(script.Parent:WaitForChild("CardSelect"))
local PadMenus = require(script.Parent:WaitForChild("PadMenus"))
local ArmoryStore = require(script.Parent:WaitForChild("ArmoryStore"))
local ArmoryQuests = require(script.Parent:WaitForChild("ArmoryQuests"))
local Workbench = require(script.Parent:WaitForChild("Workbench"))
local MasteryBadge = require(script.Parent:WaitForChild("MasteryBadge"))
local ShopData = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("ShopData"))
local Skins = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("Skins"))
local RifleSpecs = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("RifleSpecs"))
local LMGSpecs = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("LMGSpecs"))
local SniperSpecs = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("SniperSpecs"))
local PistolSpecs = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("PistolSpecs"))
local SMGSpecs = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("SMGSpecs"))
local DMRSpecs = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("DMRSpecs"))

local touch = Style.isTouch()
local v4 = touch and 0 or 22
local v5 = 296 - v4 - 20

local v6 = math.floor((v5 - 8) / 2)

local v7 = v5 - 10 - 6 - 46 - 6 - 44 - 6 - 44 - 10

local color = Color3.fromRGB(226, 112, 86)
local color2 = Color3.fromRGB(255, 150, 124)
local color3 = Color3.fromRGB(38, 40, 45)
local color4 = Color3.fromRGB(26, 27, 31)

local v8 = {
	AssaultRifle = "RIFLE",
	SMG = "SMG",
	Shotgun = "SHOTGUN",
	DMR = "DMR",
	LMG = "LMG",
	Sniper = "SNIPER",
	Pistol = "PISTOL",
	HandCannon = "MAGNUM",
	RocketLauncher = "LAUNCHER",
	BuildHammer = "BUILDER",
	Hammer = "MELEE",
	Shovel = "MELEE",
	Grenade = "FRAG",
	PipeBomb = "DEMO",
	Molotov = "FIRE",
	Smoke = "SMOKE",
	Claymore = "MINE",
	C4 = "DEMO",
	Flamethrower = "FIRE",
	AALauncher = "LAUNCHER"
}

local v9 = {
	AssaultRifle = "AUTO",
	SMG = "AUTO",
	LMG = "AUTO",
	DMR = "SEMI",
	Pistol = "SEMI",
	HandCannon = "SEMI",
	Shotgun = "PUMP",
	Sniper = "BOLT"
}
local v10 = {
	{ slot = "primary", tab = "primary", label = "PRIMARY" },
	{ slot = "secondary", tab = "secondary", label = "SECONDARY" },
	{ slot = "utility", tab = "utility", label = "UTILITY" },
	{ slot = "melee", tab = "melee", label = "MELEE" },
	{ slot = "throwable", tab = "gear", label = "THROWABLE" },
	{ slot = "streak", tab = "streaks", label = "STREAK" }
}
local v11 = { primary = true }
local v12 = { "RIFLE", "SMG", "LMG", "DMR", "SNIPER", "SHOTGUN" }
local ArmoryTouch = {}
ArmoryTouch.toggle = nil
ArmoryTouch.openLoadout = nil
ArmoryTouch.close = nil

for k in RifleSpecs.LIST do
	v8[k] = "RIFLE"
	v9[k] = "AUTO"
end

for k in LMGSpecs.LIST do
	v8[k] = "LMG"
	v9[k] = "AUTO"
end

for k in SMGSpecs.LIST do
	v8[k] = "SMG"
	v9[k] = "AUTO"
end

for k in DMRSpecs.LIST do
	v8[k] = "DMR"
	v9[k] = "SEMI"
end

for k in SniperSpecs.LIST do
	v8[k] = "SNIPER"
	v9[k] = "BOLT"
end

for k, v13 in PistolSpecs.LIST do
	v8[k] = "PISTOL"
	v9[k] = v13.auto and "AUTO" or "SEMI"
end

local v13 = {
	AssaultRifle = { damage = 41.2, interval = 0.1 },
	SMG = { damage = 34.3, interval = 0.072 },
	Shotgun = { damage = 28, pellets = 8, interval = 0.6 },
	DMR = { damage = 75, interval = 0.2 },
	LMG = { damage = 41.2, interval = 0.092 },
	Sniper = { damage = 160, interval = 1.5 },
	Pistol = { damage = 40, interval = 0.165 },
	HandCannon = { damage = 105, interval = 0.42 }
}

for _, v14 in { RifleSpecs.LIST, LMGSpecs.LIST } do
	for k, v15 in v14 do
		v13[k] = { damage = v15.damage[1][2], interval = v15.interval }
	end
end

for k, v14 in SniperSpecs.LIST do
	v13[k] = { damage = v14.damage.body, interval = v14.interval }
end

for _, v14 in { PistolSpecs.LIST, SMGSpecs.LIST } do
	for k, v15 in v14 do
		v13[k] = { damage = v15.damage[1][2], interval = v15.interval }
	end
end

for k, v14 in DMRSpecs.LIST do
	v13[k] = { damage = v14.damage.body[1][2], interval = v14.interval }
end

local v14 = {}
local v15 = {}

for _, v16 in v10 do
	v14[v16.slot] = {}
end

for _, v16 in LoadoutData do
	for _, item in v16.items do
		local item2 = ShopData.item(item.id)
		v15[item.id] = item
		table.insert(v14[item2.slot], item)
	end
end

local v16 = {
	K433 = "Full auto, 30 rounds, fast. Climbs hard up and right; lighter rounds than the VR-30.",
	GX36 = "Full auto, 30 rounds. Straight up then a steady lean right, easy to learn. 1.8x prism.",
	SK556 = "Full auto, 30 rounds, slow and heavy. Barely climbs, the steadiest rifle at range. 3x scope.",
	RN545 = "Full auto, 30 rounds, very fast. Light rounds, the softest kick of the rifles.",
	MX65 = "Full auto, 20 rounds, slow. Holds its damage far out; leans up and right. 2x sight.",
	BT762 = "Full auto, 20 rounds, a short bullpup. VR-30 damage at a faster rate, and the biggest kick.",
	KP50 = "Full auto, 50-round top magazine, fast. Six torso hits out to mid range; a low, flat climb.",
	HM45 = "Full auto, 30 rounds, slow and heavy. Four torso hits up close; kicks up and left.",
	PD46 = "Full auto, 30 rounds, fast. Light rounds that hold their damage far out; a soft, straight climb.",
	SP44 = "Full auto, 44-round coil magazine. Five torso hits up close; a bouncy climb.",
	TK17 = "Full auto, 17 rounds, very fast. Six torso hits up close, then it drops off; climbs hard up and left.",
	GV12 = "Semi auto, 10 rounds, slow and heavy. Two torso hits at any range; one head inside 10 m. 4x scope.",
	FS16 = "Semi auto, 15 rounds, quick. Four torso hits, three heads; barely kicks. 2x prism.",
	KR54 = "Semi auto, 10 rounds. Three torso hits and two heads at any range; kicks up and a little left. 6x scope.",
	QS9 = "Semi auto, 20 rounds, built-in suppressor. A slow heavy round: four torso hits, two heads up close. 1.5x scope.",
	BX110 = "100-round pouch. Climbs to a flat ceiling with a slow weave; the widest hip spread.",
	HX83 = "100-round box, the quickest-firing LMG; loses damage sooner than the others. A light, busy kick that leans right.",
	MG60 = "100-round box, slow and hard-hitting. Four torso hits up close; drifts left, slow to handle.",
	KT8 = "60-round drum, light and quick to aim. The softest, straightest kick of the LMGs; the slowest to kill up close.",
	NX68 = "50-round pouch. Keeps its damage the furthest: five torso hits out to 60 m. Kicks up and left.",
	GR240 = "50-round box, the hardest hitter at range: four torso hits out to 30 m, five to 75 m. The biggest kick, slow to handle.",
	RX10 = "Bolt action, 5 rounds, 13x scope. A headshot kills; one torso hit kills from 75 to 100 m, two elsewhere. Long and heavy.",
	SC11 = "Bolt action, 10 rounds, 9x scope. A headshot kills, two torso hits at any range. Light and quick to aim.",
	VX50 = "Bolt action .50, 5 rounds, the most zoom. A headshot kills; one torso hit kills from 60 to 130 m, two elsewhere. Hits helicopters hard. The slowest bolt and aim.",
	SV20 = "Semi auto, 20 rounds. Lighter per round than the Pistol but holds damage far out.",
	ZK10 = "Full auto machine pistol, 20 rounds. Deadly up close, falls off fast; fire in bursts."
}

for _, v17 in {
	{ list = RifleSpecs.LIST, slot = "primary", caption = "PRIMARY" },
	{ list = SMGSpecs.LIST, slot = "primary", caption = "PRIMARY" },
	{ list = LMGSpecs.LIST, slot = "primary", caption = "PRIMARY" },
	{ list = DMRSpecs.LIST, slot = "primary", caption = "PRIMARY" },
	{ list = SniperSpecs.LIST, slot = "primary", caption = "PRIMARY" },
	{ list = PistolSpecs.LIST, slot = "secondary", caption = "SECONDARY" }
} do
	local v18 = {}

	for k in v17.list do
		table.insert(v18, k)
	end

	table.sort(v18)

	for _, v19 in v18 do
		if v15[v19] then
			continue
		end

		assert(
			ShopData.ITEMS[v19] and ShopData.item(v19).slot == v17.slot,
			"[Armory] " .. v19 .. " needs a " .. v17.slot .. " ShopData entry"
		)
		local v20 = {
			id = v19,
			tool = v19,
			name = v17.list[v19].name,
			slot = v17.caption,
			description = v16[v19] or ""
		}
		v15[v19] = v20
		local v21 = v14[v17.slot]
		local v22 = #v21 + 1

		for k, v23 in v21 do
			if v8[v23.id] == v8[v19] then
				v22 = k + 1
			end
		end

		table.insert(v21, v22, v20)
	end
end

for _, v17 in { "primary", "secondary" } do
	local v18 = v14[v17]
	local v19 = {}

	for k, v20 in v18 do
		local v21 = v8[v20.id] or v20.id
		v19[v21] = v19[v21] or k
	end

	table.sort(v18, function(a, b): boolean
		local v20 = v19[v8[a.id] or a.id]
		local v21 = v19[v8[b.id] or b.id]

		if v20 ~= v21 and v11[v17] then
			return v20 < v21
		end

		local v22 = ShopData.unlockLevel(a.id)
		local v23 = ShopData.unlockLevel(b.id)

		if v22 ~= v23 then
			return v22 < v23
		end

		local price = ShopData.item(a.id).price or 0
		local price2 = ShopData.item(b.id).price or 0

		if price == price2 then
			return a.id < b.id
		end

		return price < price2
	end)
end

local primary = v14.primary
local v17 = {}

for i = #primary, 1, -1 do
	if ShopData.ITEMS[primary[i].id].hidden then
		table.insert(v17, 1, table.remove(primary, i))
	end
end

local function listHiddenGuns()
	if #v17 ~= 0 then
		local Players = game:GetService("Players")

		if Players.LocalPlayer:GetAttribute("UnlockAll") == true then
			local primary2 = v14.primary

			for _, v18 in v17 do
				local v19 = #primary2 + 1

				for k, v20 in primary2 do
					if v8[v20.id] == v8[v18.id] then
						v19 = k + 1
					end
				end

				table.insert(primary2, v19, v18)
			end

			table.clear(v17)
		end
	end
end

local function nameOf(p: string) -- 4 equivalent calls inferred from this helper
	local v18 = v15[p]

	if v18 then
		return v18.name
	end

	local v19 = RifleSpecs.LIST[p]
		or SMGSpecs.LIST[p]
		or LMGSpecs.LIST[p]
		or DMRSpecs.LIST[p]
		or SniperSpecs.LIST[p]
		or PistolSpecs.LIST[p]
	return if v19 then v19.name else p
end

local function toolOf(childName: string)
	local v18 = v15[childName]

	if v18 and v18.tool then
		childName = v18.tool
	end

	local tool = ToolTemplates:FindFirstChild(childName)
	return if tool and tool:IsA("Tool") then tool else nil
end

local function row(parent, name: string, p: number, flag: boolean?) -- 11 equivalent calls inferred from this helper
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

local function padding(parent, p: number, p2: number) -- 7 equivalent calls inferred from this helper
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, p)
	uiPadding.PaddingRight = UDim.new(0, p2)
	uiPadding.Parent = parent
end

local function zAll(folder, zIndex: number)
	folder.ZIndex = zIndex

	for _, guiObject in folder:GetDescendants() do
		if guiObject:IsA("GuiObject") then
			guiObject.ZIndex = zIndex
		end
	end
end

local function small(p: string, p2: number) -- 1 equivalent call inferred from this helper
	return string.format("<font size=\"%d\">%s</font>", p2, p)
end

local function picture(value: string, p, white: Color3)
	local v18 = v15[value]
	local v19 = if v18 and v18.tool then v18.tool else value
	local tool = ToolTemplates:FindFirstChild(v19)

	if not (tool and tool:IsA("Tool")) then
		tool = nil
	end

	if tool then
		ToolIcon.voxel(tool, p, white)
		return
	end

	if StreakIcon.has(value) then
		StreakIcon.voxel(value, p, white)
		return
	end

	local label = Style.label
	value = nameOf(value) -- inferred equivalent call
	local v20 = label(p, "Letter", string.upper((string.sub(value, 1, 1))), 36, Style.FONT, 0)
	v20.AutomaticSize = Enum.AutomaticSize.None
	v20.Size = UDim2.fromScale(1, 1)
	v20.TextColor3 = Style.STEEL_LIGHT
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

local function trackOf(item, p: string) -- 3 equivalent calls inferred from this helper
	for _, track in item.tracks do
		if track.id == p then
			return track
		end
	end

	return nil
end

local function reloadBase(p) -- 1 equivalent call inferred from this helper
	return tonumber(string.match(p.show(1), "[%d%.]+")) or 0
end

local function statsOf(p: string, callback)
	local v18 = v13[p]

	if not v18 then
		return nil
	end

	local item = ShopData.item(p)
	local track = trackOf(item, "Damage") -- inferred equivalent call
	local track2 = trackOf(item, "Magazine") -- inferred equivalent call
	local track3 = trackOf(item, "Reload") -- inferred equivalent call
	local v19 = v18.damage * (not track and 1 or ShopData.value(track, callback("Damage")))
	local num = v19 * (v18.pellets or 1)
	local num2 = 60 / v18.interval
	local num3 = not track2 and 0 or ShopData.value(track2, callback("Magazine"))
	local num4 = not track3 and 0 or reloadBase(track3) * ShopData.value(track3, callback("Reload")) -- inferred equivalent call

	local v20 = {
		label = "DAMAGE",
		frac = math.clamp(num / 210, 0, 1),
		text = 0,
		num = 0
	}
	local text

	if v18.pellets then
		text = string.format("%dx%d", v18.pellets, (math.round(v19)))
	else
		text = tostring((math.round(v19)))
	end

	v20.text = text
	v20.num = num
	return {
		v20,
		{
			label = "RPM",
			frac = math.clamp(num2 / 900, 0, 1),
			text = tostring((math.round(num2))),
			num = num2
		},
		{
			label = "MAG",
			frac = math.clamp(num3 / 100, 0, 1),
			text = tostring((math.round(num3))),
			num = num3
		},
		{
			label = p == "Shotgun" and "SHELL" or "RELOAD",
			frac = math.clamp(1 - (num4 - 0.5) / 2.8, 0.05, 1),
			text = string.format("%.2f", num4),
			num = num4,
			lower = true
		}
	}
end

function ArmoryTouch.new(layer, instance, callback)
	local region = Style.region(layer, "Armory", Vector2.new(0.5, 0.5), Vector2.zero, Vector2.new(740, 350))
	region.Visible = false
	local fit = Style.fit(region, Vector2.new(740, 350), 0.96, { grow = true })
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
	local frame = Style.frame(fill, "Left", UDim2.new(1, -320, 1, 0))
	padding(frame, 10, 0) -- inferred equivalent call
	row(frame, "Row", 10) -- inferred equivalent call
	local button = Style.button(frame, "Back", "<", Style.PANEL, UDim2.fromOffset(44, 44), Style.WHITE, 26)
	button.LayoutOrder = 1
	button.Visible = false
	local label = Style.label(frame, "Title", "ARMORY", 26, Style.FONT, 1.5)
	label.LayoutOrder = 2
	label.RichText = true
	local frame2 = Style.frame(frame, "Tabs", UDim2.fromOffset(v3 and 316 or 314, 44))
	frame2.LayoutOrder = 3
	row(frame2, "Row", v3 and 4 or 6) -- inferred equivalent call
	local v18 = {}
	local v19 = {
		{ id = "kit", text = "LOADOUT" },
		{ id = "quests", text = "QUESTS" },
		{ id = "outfits", text = "OUTFITS" },
		{ id = "store", text = "STORE" }
	}

	if v3 then
		table.insert(v19, 4, { id = "vehicles", text = "VEHICLES" })
	end

	for k, v20 in v19 do
		local button2, v21 = Style.button(
			frame2,
			v20.id,
			v20.text,
			Style.PANEL,
			UDim2.fromOffset(v3 and 60 or 74, 44),
			Style.MUTED,
			18
		)

		if v3 then
			v21.TextScaled = true
			local uiTextSizeConstraint = Instance.new("UITextSizeConstraint")
			uiTextSizeConstraint.MaxTextSize = 15
			uiTextSizeConstraint.MinTextSize = 12
			uiTextSizeConstraint.Parent = v21
			local uiPadding = Instance.new("UIPadding")
			uiPadding.PaddingLeft = UDim.new(0, 3)
			uiPadding.PaddingRight = UDim.new(0, 3)
			uiPadding.Parent = v21
		end

		button2.LayoutOrder = k
		local tape = Style.tape(button2, "Underline", UDim2.new(1, 0, 0, 5), 120, 10)
		tape.AnchorPoint = Vector2.new(0, 1)
		tape.Position = UDim2.fromScale(0, 1)
		table.insert(v18, { id = v20.id, button = button2, label = v21, under = tape })

		if v20.id == "store" then
			ArmoryStore.freeBadge(button2, instance)
		elseif v20.id == "quests" then
			ArmoryQuests.claimBadge(button2, instance)
		end
	end

	local button2, v20 = Style.button(fill, "Close", "X", Style.ORANGE, UDim2.fromOffset(44, 44), Style.INK, 22)

	local cap = Glyph.cap(button2, nil, Enum.KeyCode.ButtonB, 30)
	cap.AnchorPoint = Vector2.new(0.5, 0.5)
	cap.Position = UDim2.fromScale(0.5, 0.5)
	local function closeFace() -- 1 equivalent call inferred from this helper
		v20.Visible = not Glyph.gamepad()
	end
	Glyph.onChange(closeFace)
	closeFace() -- inferred equivalent call
	button2.AnchorPoint = Vector2.new(1, 0.5)
	button2.Position = UDim2.new(1, -10, 0.5, 0)
	local frame3 = Style.frame(fill, "Stats", UDim2.fromOffset(0, 36), UDim2.new(1, -62, 0.5, 0), Vector2.new(1, 0.5))
	frame3.AutomaticSize = Enum.AutomaticSize.X
	row(frame3, "Row", 8) -- inferred equivalent call
	local box2 = Style.box(frame3, "Level", Style.INK, UDim2.fromOffset(0, 36), 3, 1.5)
	box2.AutomaticSize = Enum.AutomaticSize.X
	box2.LayoutOrder = 1
	padding(box2, 10, 10) -- inferred equivalent call
	row(box2, "Row", 8) -- inferred equivalent call
	local label2 = Style.label(box2, "Text", "", 18, Style.FONT, 0)
	label2.Size = UDim2.fromOffset(0, 36)
	label2.TextColor3 = Style.WHITE
	label2.LayoutOrder = 1
	local fill2 = Style.fill(box2, "Xp", color4, UDim2.fromOffset(48, 6))
	fill2.LayoutOrder = 2
	Style.stroke(fill2, 1, 0, Style.INK, true)
	local fill3 = Style.fill(fill2, "Fill", Style.HAZARD, UDim2.fromScale(0, 1))
	local box3 = Style.box(frame3, "Scrap", Style.INK, UDim2.fromOffset(0, 36), 3, 1.5)
	box3.AutomaticSize = Enum.AutomaticSize.X
	box3.LayoutOrder = 2
	row(box3, "Row", 6) -- inferred equivalent call
	padding(box3, 8, 10) -- inferred equivalent call
	local nut_2 = Style.nut(box3, 20)
	nut_2.LayoutOrder = 1
	local label3 = Style.label(box3, "Amount", "0", 20, Style.FONT, 0)
	label3.TextColor3 = Style.HAZARD
	label3.LayoutOrder = 2

	local fill4 = Style.fill(box, "Footer", Style.STEEL, UDim2.new(1, 0, 0, v4), UDim2.new(0, 0, 1, -v4))
	fill4.Visible = v4 > 0
	Style.corner(fill4, 3)
	local frame4 = Style.frame(fill4, "Prompts", UDim2.fromScale(1, 1))
	padding(frame4, 16, 16) -- inferred equivalent call
	row(frame4, "Row", 18) -- inferred equivalent call
	local frame5 = Style.frame(box, "Kit", UDim2.fromOffset(720, v5), UDim2.fromOffset(10, 64))

	local frame6 = Style.frame(box, "Slot", UDim2.fromOffset(720, v5), UDim2.fromOffset(10, 64))
	frame6.Visible = false
	local frame7 = Style.frame(frame6, "List", UDim2.fromOffset(362, v5))
	frame7.ClipsDescendants = true
	local function scroller(name: string)
		local scrollingFrame = Instance.new("ScrollingFrame")
		scrollingFrame.Name = name
		scrollingFrame.BackgroundTransparency = 1
		scrollingFrame.BorderSizePixel = 0
		scrollingFrame.Size = UDim2.fromScale(1, 1)
		scrollingFrame.ScrollBarThickness = 6
		scrollingFrame.ScrollBarImageColor3 = Style.HAZARD
		scrollingFrame.CanvasSize = UDim2.new()
		scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scrollingFrame.Parent = frame7
		local uiPadding = Instance.new("UIPadding")
		uiPadding.PaddingTop = UDim.new(0, 4)
		uiPadding.PaddingLeft = UDim.new(0, 4)
		uiPadding.PaddingBottom = UDim.new(0, 4)
		uiPadding.Parent = scrollingFrame
		local uiGridLayout = Instance.new("UIGridLayout")
		uiGridLayout.CellSize = UDim2.fromOffset(170, 104)
		uiGridLayout.CellPadding = UDim2.fromOffset(8, 8)
		uiGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uiGridLayout.Parent = scrollingFrame
		return scrollingFrame
	end

	local parent2 = scroller("Items")
	local parent3 = scroller("Outfits")
	parent3.Visible = false

	local frame8 = Style.frame(frame7, "ClassBar", UDim2.new(1, 0, 0, 50))
	frame8.Visible = false
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0, 4)
	uiListLayout.Parent = frame8
	local cap_2 = Glyph.cap(frame8, nil, Enum.KeyCode.ButtonL2, 26)
	cap_2.LayoutOrder = 1
	local cap_3 = Glyph.cap(frame8, nil, Enum.KeyCode.ButtonR2, 26)
	cap_3.LayoutOrder = 3
	local classes = Instance.new("ScrollingFrame")
	classes.Name = "Classes"
	classes.LayoutOrder = 2
	classes.BackgroundTransparency = 1
	classes.BorderSizePixel = 0
	classes.Size = UDim2.fromScale(0, 1)
	local uiFlexItem = Instance.new("UIFlexItem")
	uiFlexItem.FlexMode = Enum.UIFlexMode.Fill
	uiFlexItem.Parent = classes
	classes.ScrollBarThickness = 0
	classes.ScrollingDirection = Enum.ScrollingDirection.X
	classes.CanvasSize = UDim2.new()
	classes.AutomaticCanvasSize = Enum.AutomaticSize.X
	classes.Selectable = false
	classes.Visible = false
	classes.Parent = frame8
	classes:GetPropertyChangedSignal("Visible"):Connect(function()
		frame8.Visible = classes.Visible
	end)
	row(classes, "Row", 4) -- inferred equivalent call
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingTop = UDim.new(0, 3)
	uiPadding.PaddingBottom = UDim.new(0, 3)
	uiPadding.PaddingLeft = UDim.new(0, 3)
	uiPadding.PaddingRight = UDim.new(0, 3)
	uiPadding.Parent = classes

	local uiPadding2 = Instance.new("UIPadding")
	uiPadding2.Parent = frame8
	local function capRoom() -- 1 equivalent call inferred from this helper
		local udim = UDim.new(0, Glyph.gamepad() and 3 or 0)
		uiPadding2.PaddingLeft = udim
		uiPadding2.PaddingRight = udim
	end
	Glyph.onChange(capRoom)
	capRoom() -- inferred equivalent call
	local label4 = Style.label(frame7, "Empty", "", 16, Style.FONT, 1.5)
	label4.TextColor3 = Style.MUTED
	label4.AnchorPoint = Vector2.new(0.5, 0.5)
	label4.Position = UDim2.fromScale(0.5, 0.5)

	local box4 = Style.box(frame6, "Detail", color3, UDim2.fromOffset(348, v5), 3, 2)
	box4.AnchorPoint = Vector2.new(1, 0)
	box4.Position = UDim2.fromScale(1, 0)

	local label5 = Style.label(box4, "Toast", "", 16, Style.FONT, 1.5)
	label5.AnchorPoint = Vector2.new(0.5, 0.5)
	label5.Position = UDim2.fromOffset(174, v7 / 2 + 10)
	label5.Visible = false
	label5.ZIndex = 6

	local button3 = Style.button(box4, "Action", "", Style.HAZARD, UDim2.fromOffset(328, 44), Style.INK, 18)
	button3.Position = UDim2.fromOffset(10, v5 - 10 - 44)
	button3.ClipsDescendants = true
	local text_2 = button3:FindFirstChild("Text")
	text_2.Visible = false
	local fill5 = Style.fill(button3, "Hold", Style.WHITE, UDim2.fromScale(0, 1))
	fill5.BackgroundTransparency = 0.45
	fill5.ZIndex = 2
	local v21 = costContent(button3, 18)
	zAll(button3:FindFirstChild("Content"), 3)
	local tape = Style.tape(button3, "Tape", UDim2.new(1, 0, 0, 4), 328, 10)
	tape.ZIndex = 3

	local offset = button3.Size.Y.Offset
	local button4, v22 = Style.button(box4, "Instant", "", Style.HAZARD, UDim2.fromOffset(328, offset), Style.INK, 18)
	button4.Position = UDim2.fromOffset(button3.Position.X.Offset, button3.Position.Y.Offset - offset - 6)
	button4.Visible = false
	v22.Visible = false
	local robuxLine, v23 = Style.robuxLine(button4, "Line", 18)
	robuxLine:FindFirstChild("Words").UIStroke:Destroy()
	local run = nil
	local visible = false
	local v24 = false
	button4.Activated:Connect(function()
		if run then
			run()
		end
	end)

	local function fn() end
	local function fn2(_: boolean) end
	local function fn3() end
	local hook = Workbench.hook({
		player = instance,
		layer = layer,
		parent = box4,
		action = button3,
		width = 328,
		room = function(flag: boolean)
			v24 = flag
			fn2(flag or visible)
		end,
		hide = function(flag: boolean)
			region.Visible = not flag
		end,
		closeAll = function()
			fn3()
		end,
		closed = function()
			fn()
		end
	})

	local frame9 = Style.frame(box4, "Item", UDim2.fromScale(1, 1))
	local box5 = Style.box(frame9, "Stage", color4, UDim2.fromOffset(328, v7), 3, 1.5)
	box5.Position = UDim2.fromOffset(10, 10)
	box5.ClipsDescendants = true
	box5.Active = true
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Rotation = 90
	uiGradient.Color = ColorSequence.new(color4, color3)
	uiGradient.Parent = box5
	local frame10 = Style.frame(box5, "Holder", UDim2.fromScale(1, 1))
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = frame10
	local frame11 = Style.frame(box5, "Tags", UDim2.fromOffset(312, 20), UDim2.fromOffset(8, 6))
	row(frame11, "Row", 4) -- inferred equivalent call
	local label6 = Style.label(box5, "Compare", "", 12, Style.FONT, 1)
	label6.AnchorPoint = Vector2.new(1, 0)
	label6.Position = UDim2.new(1, -8, 0, 8)
	label6.TextColor3 = Style.MUTED
	label6.ZIndex = 3
	local label7 = Style.label(box5, "Name", "", 24, Style.FONT, 1.5)
	label7.AnchorPoint = Vector2.new(0, 1)
	label7.Position = UDim2.new(0, 8, 1, -2)
	label7.ZIndex = 3
	local plate = MasteryBadge.plate(box5, instance)

	local v25 = v7 + 10 + 6
	local frame12 = Style.frame(frame9, "Stats", UDim2.fromOffset(328, 46), UDim2.fromOffset(10, v25))
	local v26 = {}

	for i = 1, 4 do
		local box6 = Style.box(frame12, "Stat" .. i, color4, UDim2.fromOffset(77.5, 46), 3, 1)
		box6.Position = UDim2.fromOffset((i - 1) * 83.5, 0)
		local label8 = Style.label(box6, "Label", "", 12, Style.FONT, 0)
		label8.Position = UDim2.fromOffset(6, 2)
		label8.TextColor3 = Style.MUTED

		local label9 = Style.label(box6, "Note", "", 12, Style.FONT, 0)
		label9.AnchorPoint = Vector2.new(1, 0)
		label9.Position = UDim2.new(1, -5, 0, 2)
		local label10 = Style.label(box6, "Value", "", 19, Style.FONT, 0)
		label10.Position = UDim2.fromOffset(6, 16)
		local fill6 = Style.fill(box6, "Bar", Style.INK, UDim2.new(1, -12, 0, 4), UDim2.new(0, 6, 1, -7))
		local fill7 = Style.fill(fill6, "Base", Style.MUTED, UDim2.fromScale(0, 1))
		local fill8 = Style.fill(fill6, "Gain", Style.HAZARD, UDim2.fromScale(0, 1))
		local fill9 = Style.fill(fill6, "Loss", color, UDim2.fromScale(0, 1))
		fill9.BackgroundTransparency = 0.3
		local fill10 = Style.fill(
			fill6,
			"Equipped",
			Style.WHITE,
			UDim2.new(0, 2, 1, 4),
			UDim2.fromScale(0, 0.5),
			Vector2.new(0.5, 0.5)
		)
		fill10.ZIndex = 2
		table.insert(v26, {
			label = label8,
			note = label9,
			base = fill7,
			gain = fill8,
			loss = fill9,
			tick = fill10,
			value = label10
		})
	end

	local label8 = Style.label(frame9, "Facts", "", touch and 14 or 13, Style.FONT_BODY, 0)
	label8.AutomaticSize = Enum.AutomaticSize.None
	label8.Size = UDim2.fromOffset(328, 46)
	label8.Position = UDim2.fromOffset(10, v25)
	label8.TextWrapped = true
	label8.TextXAlignment = Enum.TextXAlignment.Left
	label8.TextYAlignment = Enum.TextYAlignment.Top
	label8.TextColor3 = Style.MUTED

	local frame13 = Style.frame(box4, "Outfit", UDim2.fromScale(1, 1))
	frame13.Visible = false
	local v27 = v5 - 10 - 44 - 6 - 20 - 6 - 10
	local box6 = Style.box(frame13, "Stage", color4, UDim2.fromOffset(328, v27), 3, 1.5)
	box6.Position = UDim2.fromOffset(10, 10)
	box6.ClipsDescendants = true
	local uiGradient2 = Instance.new("UIGradient")
	uiGradient2.Rotation = 90
	uiGradient2.Color = ColorSequence.new(color4, color3)
	uiGradient2.Parent = box6
	local view = SkinPreview.view(box6, "full")
	local stage = OutfitLook.stage(box6)
	local label9 = Style.label(box6, "NoBody", "DEPLOY TO SEE YOUR SOLDIER", 14, Style.FONT, 0)
	label9.AnchorPoint = Vector2.new(0.5, 0.5)
	label9.Position = UDim2.fromScale(0.5, 0.5)
	label9.TextColor3 = Style.DIM

	local v28 = {}
	local label10 = Style.label(box6, "Name", "", 24, Style.FONT, 1.5)
	label10.AnchorPoint = Vector2.new(0, 1)
	label10.Position = UDim2.new(0, 8, 1, -2)
	label10.ZIndex = 3
	local label11 = Style.label(frame13, "Lock", "", 14, Style.FONT, 0)
	label11.Position = UDim2.fromOffset(10, v27 + 10 + 6)
	label11.RichText = true

	local v29 = "kit"
	local v30 = "slots"
	local v31 = 1
	local v32 = nil
	local v36 = nil
	local v37 = (not instance.Team or instance.Team.Name ~= "Reds" and instance.Team.Name ~= "Blues") and "Reds"
		or instance.Team.Name
	local flag = false
	local count = 0
	local v38 = nil
	local v39 = {}
	local v40 = {}
	local v41 = "ALL"
	local v42 = 0
	local visible2 = false
	local v44 = ""

	local v45 = {}
	local v46 = {}
	local v47 = nil
	local v48 = nil
	local fn4

	local function picking(): boolean -- 10 equivalent calls inferred from this helper
		return v29 == "kit" and v30 == "pick"
	end

	local function scrap() -- 5 equivalent calls inferred from this helper
		local scrap2 = instance:GetAttribute("Scrap")
		return if type(scrap2) == "number" then scrap2 else 0
	end

	local function num(attributeName: string) -- 2 equivalent calls inferred from this helper
		local attribute = instance:GetAttribute(attributeName)
		return if type(attribute) == "number" then attribute else 0
	end

	local v49 = false
	local function rollScrap(p: number)
		if v49 then
			return
		end

		local v50 = v48
		v48 = p

		if v50 == nil or v50 == p then
			Style.stop(label3)
			label3.Text = Style.thousands(p)
		else
			local now = os.clock()
			Style.animate(label3, function(_, p2: number): boolean
				local v51 = math.min((p2 - now) / 0.45, 1)
				label3.Text = Style.thousands((math.round(v50 + (p - v50) * Style.easeOut(v51))))
				return v51 < 1
			end)
		end
	end

	local function refreshLevel()
		label2.Text = string.format("LV %d", Skins.levelOf(instance))
		local v50 = num("XP") -- inferred equivalent call
		local v51 = num("XPNext") -- inferred equivalent call
		fill3.Size = UDim2.fromScale(not (v51 > 0) and 1 or math.clamp(v50 / v51, 0, 1), 1)
	end

	local function levelFn(p: string) -- 2 equivalent calls inferred from this helper
		return function(p2: string)
			return ShopData.level(instance, p, p2)
		end
	end

	local function carried(slot: string) -- 5 equivalent calls inferred from this helper
		if slot == "streak" then
			return (ShopData.streak(instance))
		end

		return (ShopData.pick(instance, slot))
	end

	local function showToast(text: string, flag2: boolean) -- 1 equivalent call inferred from this helper
		count += 1
		local v50 = count
		label5.Text = text
		local textColor = if flag2 then Style.HAZARD else color
		label5.TextColor3 = textColor
		label5.Visible = true
		task.delay(2.4, function()
			if count == v50 then
				label5.Visible = false
			end
		end)
	end

	local function ask(p: string, p2: string, p3: string?) -- 4 equivalent calls inferred from this helper
		if flag then
			return
		end

		flag = true
		local v50, v51 = callback(p, p2, p3)
		flag = false

		if not v50 or string.sub(v51, 1, 8) ~= "Equipped" then
			showToast(string.upper(v51), v50) -- inferred equivalent call
		end
	end

	local function makeCard(parent, layoutOrder: number, id: string, p: string, name: string, fn5, p2)
		local textButton = Instance.new("TextButton")
		textButton.Name = id
		textButton.Text = ""
		textButton.LayoutOrder = layoutOrder
		textButton.AutoButtonColor = true
		textButton.BorderSizePixel = 0
		textButton.BackgroundColor3 = Style.STEEL
		textButton.Parent = parent
		Style.corner(textButton, 3)
		local stroke = Style.stroke(textButton, 2, 0, Style.INK, true)
		local label12 = Style.label(textButton, "Family", p, 12, Style.FONT, 0)
		label12.Position = UDim2.fromOffset(8, 3)
		label12.TextColor3 = Style.HAZARD
		local frame14 = Style.frame(textButton, "Picture", UDim2.new(1, -16, 0, 42), UDim2.fromOffset(8, 20))
		local v50 = fn5(frame14)

		if p2 then
			OutfitLook.card(textButton, frame14, label12, p2)
		end

		local fill6 = Style.fill(textButton, "Veil", Style.INK, UDim2.new(1, -16, 0, 42), UDim2.fromOffset(8, 20))
		fill6.BackgroundTransparency = 0.45
		fill6.ZIndex = 2
		fill6.Visible = false

		local folder = Style.frame(
			fill6,
			"Lock",
			UDim2.fromOffset(18, 26),
			UDim2.fromScale(0.5, 0.5),
			Vector2.new(0.5, 0.5)
		)
		local frame15 = Style.frame(
			folder,
			"Shackle",
			UDim2.fromOffset(12, 16),
			UDim2.fromScale(0.5, 0),
			Vector2.new(0.5, 0)
		)
		Style.corner(frame15, 16)
		Style.stroke(frame15, 3, 0, Style.STEEL_LIGHT, true)
		local box7 = Style.box(folder, "Body", Style.HAZARD, UDim2.new(1, 0, 0, 16), 3, 2)
		box7.AnchorPoint = Vector2.new(0, 1)
		box7.Position = UDim2.fromScale(0, 1)
		local fill7 = Style.fill(
			box7,
			"Keyhole",
			Style.INK,
			UDim2.fromOffset(4, 4),
			UDim2.fromScale(0.5, 0.4),
			Vector2.new(0.5, 0.5)
		)
		Style.corner(fill7, 16)
		Style.fill(box7, "Slot", Style.INK, UDim2.fromOffset(2, 5), UDim2.fromScale(0.5, 0.45), Vector2.new(0.5, 0))

		for _, guiObject in folder:GetDescendants() do
			if guiObject:IsA("GuiObject") then
				guiObject.ZIndex = 3
			end
		end

		folder.ZIndex = 3

		local label13 = Style.label(textButton, "Name", string.upper(name), 16, Style.FONT, 0)
		label13.AutomaticSize = Enum.AutomaticSize.None
		label13.Size = UDim2.new(1, -16, 0, 19)
		label13.Position = UDim2.fromOffset(8, 62)
		label13.TextXAlignment = Enum.TextXAlignment.Left
		label13.TextTruncate = Enum.TextTruncate.AtEnd
		local box8 = Style.box(textButton, "Chip", Style.INK, UDim2.fromOffset(0, 20), 2, 1)
		box8.AutomaticSize = Enum.AutomaticSize.X
		box8.AnchorPoint = Vector2.new(0, 0.5)
		box8.Position = UDim2.fromOffset(8, 91)
		local uiScale2 = Instance.new("UIScale")
		uiScale2.Parent = box8
		padding(box8, 5, 6) -- inferred equivalent call
		row(box8, "Row", 4) -- inferred equivalent call
		local nut = Style.nut(box8, 12)
		nut.LayoutOrder = 1
		local label14 = Style.label(box8, "Text", "", 13, Style.FONT, 0)
		label14.LayoutOrder = 2
		zAll(box8, 3)
		local uiStroke = box8:FindFirstChildOfClass("UIStroke")
		local v51 = nil
		local function setChip(p3: string, text: string, flag2: boolean?)
			if p3 == "equipped" and v51 ~= nil and v51 ~= "equipped" then
				local now = os.clock()
				Style.animate(uiScale2, function(_, p4: number): boolean
					local v52 = math.min((p4 - now) / 0.08, 1)
					uiScale2.Scale = 1.2 + -0.19999999999999996 * Style.easeOut(v52)
					return v52 < 1
				end)

				assert(MenuAudio.stamp, "[Armory] MenuAudio is not mounted")
				MenuAudio.stamp()

				if text == "WEARING" then
					GearSound.wear()
				else
					GearSound.equip()
				end
			end

			v51 = p3
			nut.Visible = flag2 == true
			label14.Text = text
			local backgroundColor

			if p3 == "equipped" then
				backgroundColor = Style.HAZARD
			else
				backgroundColor = Style.INK
			end

			box8.BackgroundColor3 = backgroundColor
			local textColor

			if p3 == "equipped" then
				textColor = Style.INK
			else
				textColor = if p3 == "short" then color else Style.WHITE
			end

			label14.TextColor3 = textColor
			local color5

			if p3 == "owned" then
				color5 = Style.MUTED
			else
				color5 = Style.INK
			end

			uiStroke.Color = color5
			fill6.Visible = p3 == "short" and flag2 ~= true
			local textColor2

			if fill6.Visible then
				textColor2 = Style.DIM
			else
				textColor2 = Style.WHITE
			end

			label13.TextColor3 = textColor2
		end
		return textButton, setChip, CardSelect.attach(textButton, stroke, Style.INK, 4), v50
	end

	local function span(p, frac: number, frac2: number) -- 2 equivalent calls inferred from this helper
		p.Visible = frac + 0.001 < frac2
		p.Position = UDim2.fromScale(frac, 0)
		p.Size = UDim2.fromScale(math.max(0, frac2 - frac), 1)
	end

	local function refreshBars()
		local v50 = v32
		local v51 = v50 and statsOf(v50, levelFn(v50)) -- inferred equivalent call
		frame12.Visible = v51 ~= nil
		label8.Visible = v50 ~= nil and v51 == nil

		if not v50 then
			return
		end

		local slot = ShopData.item(v50).slot
		local v53

		if ShopData.PICKS[slot] then
			v53 = ShopData.pick(instance, slot)
		end

		if v51 then
			local v54

			if v53 and v53 ~= v50 then
				v54 = statsOf(v53, levelFn(v53)) -- inferred equivalent call
			end

			local text

			if v54 and v53 then
				text = "VS " .. string.upper(nameOf(v53)) -- inferred equivalent call
			else
				text = ""
			end

			label6.Text = text

			for k, v56 in v26 do
				local v57 = v51[k]
				local v58 = v54 and v54[k]
				v56.label.Text = v57.label
				local frac = v57.frac

				if v58 then
					local base = v56.base
					local v59 = math.min(frac, v58.frac)
					base.Visible = v59 > 0.001
					base.Position = UDim2.fromScale(0, 0)
					base.Size = UDim2.fromScale(math.max(0, v59 - 0), 1)

					span(v56.gain, v58.frac, frac) -- inferred equivalent call
					span(v56.loss, frac, v58.frac) -- inferred equivalent call
					v56.tick.Visible = true
					v56.tick.Position = UDim2.fromScale(v58.frac, 0.5)
				else
					local base = v56.base
					base.Visible = frac > 0.001
					base.Position = UDim2.fromScale(0, 0)
					base.Size = UDim2.fromScale(math.max(0, frac - 0), 1)

					v56.gain.Visible = false
					v56.loss.Visible = false
					v56.tick.Visible = false
				end

				v56.value.Text = v57.text
				v56.note.Text = ""

				if not (v58 and math.abs(v57.num - v58.num) > 0.001) then
					continue
				end

				local v59 = v57.num - v58.num
				local v60

				if v57.lower then
					v60 = v59 < 0
				else
					v60 = v59 > 0
				end

				local note = v56.note
				local text2

				if v57.lower then
					text2 = string.format("%+.2f", v59)
				else
					text2 = string.format("%+d", (math.round(v59)))
				end

				note.Text = text2
				local note2 = v56.note
				local textColor = if v60 then Style.HAZARD else color
				note2.TextColor3 = textColor
			end
		else
			local v54 = v15[v50]
			label8.Text = not v54 and "" or v54.description
			label6.Text = ""
		end
	end

	local function kitAction(p: string)
		local item = ShopData.item(p)

		if ShopData.owns(instance, p) then
			if item.slot == "streak" then
				if ShopData.streak(instance) == p then
					return { key = "done", enabled = false, done = true, text = "EQUIPPED" }
				end

				return {
					key = "streak:" .. p,
					enabled = true,
					text = "EQUIP",
					run = function()
						ask("streak", p) -- inferred equivalent call
					end
				}
			end

			if not ShopData.PICKS[item.slot] then
				return { key = "done", enabled = false, done = true, text = "IN LOADOUT" }
			end

			if ShopData.pick(instance, item.slot) == p then
				return { key = "done", enabled = false, done = true, text = "EQUIPPED" }
			end

			return {
				key = "pick:" .. p,
				enabled = true,
				text = "EQUIP",
				run = function()
					ask("pick", p) -- inferred equivalent call
				end
			}
		else
			if not ShopData.unlocked(instance, p) then
				return {
					key = "locked",
					enabled = false,
					text = string.format("UNLOCKS AT LEVEL %d", ShopData.unlockLevel(p)),
					instant = ArmoryStore.instant(instance, p, fn4)
				}
			end

			local amount = item.price - scrap() -- inferred equivalent call

			if amount <= 0 then
				return {
					key = "buy:" .. p,
					enabled = true,
					text = "BUY",
					amount = item.price,
					run = function()
						ask("buy", p) -- inferred equivalent call
					end
				}
			end

			return {
				key = "need",
				enabled = false,
				text = "NEED",
				amount = amount,
				suffix = " MORE",
				instant = ArmoryStore.instant(instance, p, fn4)
			}
		end
	end

	local function outfitAction(p)
		if Skins.pick(instance) == p.id then
			return { key = "done", enabled = false, done = true, text = "WEARING" }
		end

		if Skins.unlocked(instance, p.id) then
			return {
				key = "skin:" .. p.id,
				enabled = true,
				text = "WEAR",
				run = function()
					ask("skin", p.id) -- inferred equivalent call
				end
			}
		end

		if not p.paid then
			return {
				key = "locked",
				enabled = false,
				text = Skins.lockText(p, "UNLOCKS AT LEVEL %d")
			}
		end

		local v50 = { key = "locked", enabled = false, text = Skins.lockText(p, ""), instant = 0 }
		local instant

		if Skins.PAID_ON then
			instant = ArmoryStore.outfit(instance, p.id, fn4)
		end

		v50.instant = instant
		return v50
	end

	local v50 = ""
	local function refreshFooter()
		if v4 == 0 then
			return
		end

		local mode = Glyph.mode()
		local v51 = v38
		local text

		if v51 and v51.enabled then
			text = v51.hold and "HOLD TO BUY" or v51.text
		end

		local v53 = {}

		if mode == "gamepad" and text then
			table.insert(v53, {
				caps = {
					{ pad = Enum.KeyCode.ButtonY }
				},
				text = text
			})
		end

		local texts = { mode }

		for _, v54 in v53 do
			table.insert(texts, v54.text)
		end

		local joined = table.concat(texts, "|")

		if joined == v50 then
			return
		end

		v50 = joined
		fill4.Visible = #v53 > 0

		for _, guiObject in frame4:GetChildren() do
			if guiObject:IsA("GuiObject") then
				guiObject:Destroy()
			end
		end

		for k, v54 in v53 do
			local frame14 = Style.frame(frame4, "Prompt", UDim2.fromOffset(0, v4))
			frame14.AutomaticSize = Enum.AutomaticSize.X
			frame14.LayoutOrder = k
			row(frame14, "Row", 4) -- inferred equivalent call

			for k2, cap2 in v54.caps do
				local cap = Glyph.cap(frame14, cap2.key, cap2.pad, 16)
				cap.LayoutOrder = k2
			end

			local label12 = Style.label(frame14, "Text", v54.text, 12, Style.FONT, 0)
			label12.LayoutOrder = #v54.caps + 1
			label12.TextColor3 = Style.MUTED
		end
	end
	Glyph.onChange(refreshFooter)

	local function setActionState(data)
		v38 = data
		visible = data ~= nil and data.instant ~= nil
		button4.Visible = visible

		if data and data.instant then
			run = data.instant.run
			v23(data.instant.label or "INSTANT UNLOCK", Style.thousands(data.instant.price), Style.INK)
		end

		refreshFooter()
		button3.Visible = data ~= nil
		local sync = hook.sync
		local v52

		if data and picking() then -- inferred equivalent call
			v52 = v32
		end

		sync(v52)

		if not data then
			return
		end

		local backgroundColor

		if data.enabled then
			backgroundColor = Style.HAZARD
		else
			backgroundColor = Style.STEEL
		end

		button3.BackgroundColor3 = backgroundColor
		button3.AutoButtonColor = data.enabled and not data.hold
		tape.Visible = data.enabled
		local text = data.text
		local amount = data.amount
		local v54

		if data.enabled then
			v54 = Style.INK
		else
			v54 = if data.done then Style.HAZARD else color2
		end

		v21(text, amount, v54, data.suffix)
	end

	local v51 = nil
	local v52 = nil
	local function holdBegin()
		local v53 = v38

		if not v53 or not v53.enabled or not v53.hold or flag then
			return
		end

		local now = os.clock()
		local key = v53.key
		v51 = now
		v52 = key
		Style.animate(fill5, function(_, p: number): boolean
			if v51 ~= now then
				fill5.Size = UDim2.fromScale(0, 1)
				return false
			end

			local v54 = (p - now) / 0.6
			fill5.Size = UDim2.fromScale(math.min(v54, 1), 1)

			if v54 < 1 then
				return true
			end

			v51 = nil
			fill5.Size = UDim2.fromScale(0, 1)
			local v55 = v38

			if v55 and v55.key == v52 and v55.run then
				task.spawn(v55.run)
			end

			return false
		end)
	end
	local function holdEnd() -- 2 equivalent calls inferred from this helper
		v51 = nil
	end
	button3.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			holdBegin()
		end
	end)
	UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.ButtonA and region.Visible and GuiService.SelectedObject == button3 then
			holdBegin()
		end
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
		if gameProcessed or not region.Visible then
			return
		end

		if input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.ButtonY then
			local v53 = v38

			if not v53 or not v53.enabled or flag then
				return
			end

			if v53.hold then
				holdBegin()
			elseif v53.run then
				v53.run()
			end
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		local keyCode = input.KeyCode

		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
			or keyCode == Enum.KeyCode.ButtonA
			or keyCode == Enum.KeyCode.Return
			or keyCode == Enum.KeyCode.ButtonY
		then
			holdEnd() -- inferred equivalent call
		end
	end)
	button3.MouseLeave:Connect(holdEnd)
	button3.Activated:Connect(function()
		local v53 = v38

		if v53 and v53.enabled and not v53.hold and v53.run then
			v53.run()
		end
	end)

	local v53 = 0
	local v54 = nil
	local v55 = Vector3.new(0, 0, 0)
	local unit = (Vector3.new(1, 0.2, 0.3)).Unit
	local v56 = 1
	local v57 = nil
	local v58 = 0
	local function placeTurn() -- 3 equivalent calls inferred from this helper
		if v54 then
			local vectorToWorldSpace = CFrame.Angles(0, v53, 0):VectorToWorldSpace(unit)
			v54.CFrame = CFrame.lookAt(v55 + vectorToWorldSpace * v56, v55)
		end
	end
	local function spin() -- 2 equivalent calls inferred from this helper
		Style.animate(box5, function(p: number): boolean
			if region.Visible and v54 and picking() then -- inferred equivalent call
				if not v57 then
					v53 += p * 0.3
					placeTurn() -- inferred equivalent call
				end

				return true
			end

			return false
		end)
	end

	local v59 = nil
	local function endDrag() -- 2 equivalent calls inferred from this helper
		v57 = nil

		if v59 then
			for _, connection in v59 do
				connection:Disconnect()
			end

			v59 = nil
		end
	end
	box5.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			v57 = input
			v58 = input.Position.X

			if not v59 then
				v59 = {
					UserInputService.InputChanged:Connect(function(input2)
						if v57 and (input2.UserInputType == Enum.UserInputType.MouseMovement or input2 == v57) then
							v53 -= (input2.Position.X - v58) * 0.012
							v58 = input2.Position.X
							placeTurn() -- inferred equivalent call
						end
					end),
					UserInputService.InputEnded:Connect(function(input2)
						if v57 and (input2 == v57 or input2.UserInputType == Enum.UserInputType.MouseButton1) then
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

	local function stagePicture(p: string)
		for _, uiScale2 in frame10:GetChildren() do
			if not uiScale2:IsA("UIScale") then
				uiScale2:Destroy()
			end
		end

		v54 = nil
		local tool = hook.dressed(p)

		if not tool then
			local v60 = v15[p]
			local v61 = if v60 and v60.tool then v60.tool else p
			tool = ToolTemplates:FindFirstChild(v61)

			if not (tool and tool:IsA("Tool")) then
				tool = nil
			end
		end

		if tool and not StreakIcon.has(p) and ShopData.item(p).slot ~= "throwable" then
			local v60 = ToolIcon.make(tool, frame10, 12)
			v60.Size = UDim2.fromScale(1, 1)
			local model = v60:FindFirstChildOfClass("Model")

			if WeaponSkins.wearsGold(model) then
				WeaponSkins.goldLight(v60)
			end

			local currentCamera = v60.CurrentCamera
			v55 = model:GetBoundingBox().Position

			local boundingBox, v61 = model:GetBoundingBox()
			local v62 = math.tan(math.rad(currentCamera.FieldOfView) / 2)
			local v63 = v62 * box5.Size.X.Offset / box5.Size.Y.Offset
			local maxValue = 0

			for i = 0, 23 do
				local vectorToWorldSpace = CFrame.Angles(0, i / 24 * 2 * 3.141592653589793, 0):VectorToWorldSpace(unit)
				local unit2 = (-vectorToWorldSpace):Cross(Vector3.new(0, 1, 0)).Unit
				local cross = unit2:Cross(-vectorToWorldSpace)

				for _, v64 in { -0.5, 0.5 } do
					for _, v65 in { -0.5, 0.5 } do
						for _, v66 in { -0.5, 0.5 } do
							local vector = boundingBox:PointToWorldSpace(v61 * Vector3.new(v64, v65, v66)) - v55
							maxValue = math.max(
								maxValue,
								vector:Dot(vectorToWorldSpace) + math.max(
									math.abs((vector:Dot(unit2))) / v63,
									math.abs((vector:Dot(cross))) / v62
								)
							)
						end
					end
				end
			end

			v56 = maxValue * 1.1
			v53 = 0
			v54 = currentCamera
			placeTurn() -- inferred equivalent call

			if not touch then
				spin() -- inferred equivalent call
			end
		else
			local frame14 = Style.frame(
				frame10,
				"Flat",
				UDim2.new(1, -60, 1, -40),
				UDim2.fromScale(0.5, 0.5),
				Vector2.new(0.5, 0.5)
			)

			if tool and not StreakIcon.has(p) then
				ToolIcon.voxel(tool, frame14, Style.WHITE, 1)
			else
				picture(p, frame14, Style.WHITE)
			end
		end

		local now = os.clock()
		Style.animate(uiScale, function(_, p2: number): boolean
			local v60 = math.min((p2 - now) / 0.1, 1)
			uiScale.Scale = 0.96 + 0.04 * Style.easeOut(v60)
			return v60 < 1
		end)
	end

	local function tag(p: string, flag2: boolean, layoutOrder: number)
		local box7 = Style.box
		local v61 = if flag2 then Style.HAZARD else Style.INK
		local parent = box7(frame11, "Tag", v61, UDim2.fromOffset(0, 20), 2, 1)
		parent.AutomaticSize = Enum.AutomaticSize.X
		parent.LayoutOrder = layoutOrder
		padding(parent, 6, 6) -- inferred equivalent call
		local label12 = Style.label(parent, "Text", p, 12, Style.FONT, 0)
		label12.Size = UDim2.fromOffset(0, 20)
		local textColor = if flag2 then Style.INK else Style.MUTED
		label12.TextColor3 = textColor
		zAll(parent, 3)
	end

	local function refreshDetail()
		if v29 == "outfits" then
			local v60 = v36

			if v60 then
				local level = Skins.levelOf(instance)

				if Skins.unlocked(instance, v60.id) then
					local text

					if v60.level <= 1 then
						text = Style.paint("STANDARD ISSUE", Style.MUTED)
					else
						text = Style.paint(Skins.lockText(v60, "LEVEL %d OUTFIT"), Style.MUTED)
					end

					label11.Text = text
				else
					local text

					if v60.paid then
						text = Style.paint(Skins.lockText(v60, ""), color)
					else
						text = Style.paint(Skins.lockText(v60, "REQUIRES LEVEL %d"), color) .. Style.paint(
							string.format("   YOU ARE LEVEL %d", level),
							Style.DIM
						)
					end

					label11.Text = text
				end

				for _, v61 in v28 do
					local v62 = v61.team == v37
					local button5 = v61.button
					local backgroundColor

					if v62 then
						backgroundColor = Style.teamColor(v61.team)
					else
						backgroundColor = Style.PANEL
					end

					button5.BackgroundColor3 = backgroundColor
					local label12 = v61.label
					local textColor

					if v62 then
						textColor = Style.WHITE
					else
						textColor = Style.MUTED
					end

					label12.TextColor3 = textColor
				end

				setActionState(outfitAction(v60))

				label11.Visible = not visible
				local v62

				if visible then
					v62 = v27 + 20 + 6 - offset - 6
				else
					v62 = v27
				end

				box6.Size = UDim2.fromOffset(328, v62)
			else
				v38 = nil
				visible = false
				button4.Visible = visible

				refreshFooter()
				button3.Visible = false
				hook.sync(nil)
			end
		else
			local v60 = v32

			if picking() and v60 then -- inferred equivalent call
				refreshBars()
				plate.set(v60)
				setActionState(kitAction(v60))
			else
				v38 = nil
				visible = false
				button4.Visible = visible

				refreshFooter()
				button3.Visible = false
				hook.sync(nil)
			end
		end
	end

	local v60 = nil
	fn2 = function(flag2: boolean)
		if flag2 == v60 then
			return
		end

		v60 = flag2
		local v61

		if flag2 then
			v61 = v7
		else
			v61 = v7 + 44 + 6
		end

		box5.Size = UDim2.fromOffset(328, v61)
		frame12.Position = UDim2.fromOffset(10, v61 + 10 + 6)
		label8.Position = frame12.Position
		local v62 = v32

		if v62 and picking() then -- inferred equivalent call
			stagePicture(v62)
		end
	end
	fn2(false)

	local function selectItem(p: string?)
		v32 = p

		for _, v61 in v40 do
			v61.setSelected(v61.key == p)
		end

		frame9.Visible = p ~= nil

		if p then
			local item = ShopData.item(p)

			for _, guiObject in frame11:GetChildren() do
				if guiObject:IsA("GuiObject") then
					guiObject:Destroy()
				end
			end

			tag(v8[p] or v10[v31].label, true, 1)

			if v9[p] then
				tag(v9[p], false, 2)
			end

			if item.kills then
				tag(string.format("%d KILLS", item.kills), false, 3)
			end

			label7.Text = string.upper(nameOf(p)) -- inferred equivalent call
			stagePicture(p)
			refreshDetail()
		else
			v38 = nil
			visible = false
			button4.Visible = visible

			refreshFooter()
			button3.Visible = false
			hook.sync(nil)
		end
	end
	fn = function()
		if v32 and picking() then -- inferred equivalent call
			selectItem(v32)
		end
	end

	local function stageOutfit()
		local v61 = v36
		stage.set(v61)
		local body = SkinPreview.body(instance)
		label9.Visible = body == nil

		if v61 and body then
			view.show(SkinPreview.dress(body, v61, v37, instance.UserId))
		else
			view.show(nil)
		end
	end

	local function selectSkin(p)
		v36 = p

		for _, v61 in v46 do
			v61.setSelected(p ~= nil and v61.key == p.id)
		end

		if p then
			label10.Text = string.upper(p.name)
			view.resetTurn()
			stageOutfit()
			refreshDetail()
		else
			v38 = nil
			visible = false
			button4.Visible = visible

			refreshFooter()
			button3.Visible = false
			hook.sync(nil)
		end
	end

	local function dressOutfitCards()
		local body = SkinPreview.body(instance)

		if body == v47 then
			return
		end

		v47 = body

		for _, v61 in v46 do
			local v62 = Skins.get(v61.key)
			local show = v61.view.show
			local v63

			if body then
				v63 = SkinPreview.dress(body, v62, v37, instance.UserId)
			end

			show(v63)
		end
	end

	instance:GetPropertyChangedSignal("Team"):Connect(function()
		local name = instance.Team and instance.Team.Name

		if (name == "Reds" or name == "Blues") and name ~= v37 then
			v37 = name
			v47 = nil
			dressOutfitCards()
			stageOutfit()
		end
	end)

	local function buildOutfitCards()
		if #v46 > 0 then
			return
		end

		for k, v61 in Skins.LIST do
			local card, v62, setSelected, view2 = makeCard(
				parent3,
				k,
				v61.id,
				v61.level <= 1 and "STANDARD" or Skins.lockText(v61, "LEVEL %d"),
				v61.name,
				function(p)
					return SkinPreview.view(p, "bust")
				end,
				v61
			)

			local function refresh()
				if Skins.pick(instance) == v61.id then
					v62("equipped", "WEARING")
				elseif Skins.unlocked(instance, v61.id) then
					v62("owned", "UNLOCKED")
				else
					v62("short", Skins.lockText(v61, "REQUIRES LVL %d"))
				end
			end
			local v65 = {
				button = card,
				key = v61.id,
				refresh = refresh,
				setSelected = setSelected,
				view = view2
			}
			card.Activated:Connect(function()
				selectSkin(v61)
			end)
			refresh()
			table.insert(v46, v65)
		end
	end

	local function slide(p) -- 2 equivalent calls inferred from this helper
		local now = os.clock()
		Style.animate(p, function(_, p2: number): boolean
			local v61 = math.min((p2 - now) / 0.12, 1)
			p.Position = UDim2.fromOffset(12 * (1 - Style.easeOut(v61)), p.Position.Y.Offset)
			return v61 < 1
		end)
	end

	local function classesOf(items)
		local v61 = {}
		local result = {}

		for _, item in items do
			local id = v8[item.id]

			if not id then
				continue
			end

			if not v61[id] then
				v61[id] = {
					id = id,
					count = 0,
					first = #result + 1
				}
				table.insert(result, v61[id])
			end

			v61[id].count += 1
		end

		table.sort(result, function(a, b): boolean
			local index = table.find(v12, a.id) or 99
			local index2 = table.find(v12, b.id) or 99

			if index == index2 then
				return a.first < b.first
			end

			return index < index2
		end)

		return result
	end

	local function inClass(id: string): boolean -- 1 equivalent call inferred from this helper
		return v41 == "ALL" or v8[id] == v41
	end

	local function refreshClassTabs()
		local v61 = v14[v10[v31].slot]

		for _, v62 in v45 do
			local visible3 = v62.id == v41
			local button5 = v62.button
			local backgroundColor

			if visible3 then
				backgroundColor = color3
			else
				backgroundColor = Style.PANEL
			end

			button5.BackgroundColor3 = backgroundColor
			local label12 = v62.label
			local textColor

			if visible3 then
				textColor = Style.WHITE
			else
				textColor = Style.MUTED
			end

			label12.TextColor3 = textColor
			v62.under.Visible = visible3
			local visible4 = false

			if v62.id ~= "ALL" then
				for _, v68 in v61 do
					if
						v8[v68.id] == v62.id
						and not ShopData.owns(instance, v68.id)
						and ShopData.unlocked(instance, v68.id)
						and ShopData.item(v68.id).price <= scrap() -- inferred equivalent call
					then
						visible4 = true
						break
					end
				end
			end

			v62.dot.Visible = visible4
		end
	end

	local function showClassTab()
		local v61 = not (frame7.AbsoluteSize.X > 0) and 362 or classes.AbsoluteSize.X * 362 / frame7.AbsoluteSize.X
		local total = 0

		for _, v62 in v45 do
			local offset2 = v62.button.Size.X.Offset

			if v62.id == v41 then
				local v63 = classes.CanvasPosition.X
				local v64 = total + offset2 + 24

				if v63 + v61 < v64 then
					v63 = total + offset2 + 24 - v61
				elseif total - 24 < v63 then
					v63 = math.max(0, total - 24)
				end

				local total2 = 0

				for _, v65 in v45 do
					if v63 <= 0 or v63 <= total2 then
						break
					end

					total2 += v65.button.Size.X.Offset + 4
				end

				classes.CanvasPosition = Vector2.new(not (v63 > 0) and 0 or total2, 0)
				break
			end

			total += offset2 + 4
		end
	end

	local function squeezeTabs()
		local v61 = frame7.AbsoluteSize.X / 362

		if v61 <= 0 or #v45 == 0 then
			return
		end

		local v62 = classes.AbsoluteSize.X / v61 - 6 - (#v45 - 1) * 4
		local v63 = 12

		while v63 > 6 do
			local total = 0

			for _, v64 in v45 do
				total += math.max(44, (math.ceil(v64.label.AbsoluteSize.X / v61 + v63 * 2)))
			end

			if total <= v62 then
				break
			end

			v63 -= 1
		end

		for _, v64 in v45 do
			local pad = v64.pad
			local pad2 = v64.pad
			local udim = UDim.new(0, v63)
			local udim2 = UDim.new(0, v63)
			pad.PaddingLeft = udim
			pad2.PaddingRight = udim2
		end
	end
	classes:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		squeezeTabs()
	end)

	local fn5

	local function makeClassTab(layoutOrder: number, id: string)
		local textButton = Instance.new("TextButton")
		textButton.Name = id
		textButton.Text = ""
		textButton.AutoButtonColor = true
		textButton.BorderSizePixel = 0
		textButton.BackgroundColor3 = Style.PANEL
		textButton.Size = UDim2.fromOffset(0, 44)
		textButton.LayoutOrder = layoutOrder
		textButton.Selectable = true
		textButton.Parent = classes
		Style.corner(textButton, 3)
		Style.stroke(textButton, 1.5, 0, Style.INK, true)
		local frame14 = Style.frame(textButton, "Content", UDim2.fromOffset(0, 44))
		frame14.AutomaticSize = Enum.AutomaticSize.X
		padding(frame14, 12, 12) -- inferred equivalent call
		row(frame14, "Row", 0) -- inferred equivalent call
		local label12 = Style.label(frame14, "Text", id, 15, Style.FONT, 0)

		local function fit2() -- 1 equivalent call inferred from this helper
			local v61 = frame7.AbsoluteSize.X / 362

			if v61 > 0 then
				textButton.Size = UDim2.fromOffset(math.max(44, (math.ceil(frame14.AbsoluteSize.X / v61))), 44)
			end
		end
		frame14:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit2)
		fit2() -- inferred equivalent call
		label12:GetPropertyChangedSignal("AbsoluteSize"):Connect(squeezeTabs)
		local tape2 = Style.tape(textButton, "Underline", UDim2.new(1, 0, 0, 4), 100, 8)
		tape2.AnchorPoint = Vector2.new(0, 1)
		tape2.Position = UDim2.fromScale(0, 1)
		local fill6 = Style.fill(
			textButton,
			"Affordable",
			Style.HAZARD,
			UDim2.fromOffset(7, 7),
			UDim2.new(1, -4, 0, 4),
			Vector2.new(1, 0)
		)
		Style.corner(fill6, 4)
		fill6.Visible = false
		textButton.Activated:Connect(function()
			fn5(id)
		end)
		table.insert(v45, {
			id = id,
			button = textButton,
			label = label12,
			under = tape2,
			dot = fill6,
			pad = frame14:FindFirstChildOfClass("UIPadding")
		})
		squeezeTabs()
	end

	local function buildClassStrip(items)
		for _, v61 in v45 do
			v61.button:Destroy()
		end

		table.clear(v45)

		for k, item in items do
			makeClassTab(k, item.id)
		end

		refreshClassTabs()
	end

	local function buildKitCards()
		listHiddenGuns()

		for _, v61 in v40 do
			v61.button:Destroy()
		end

		table.clear(v40)
		local v61 = v10[v31]
		local v62 = v14[v61.slot]
		local v63 = classesOf(v62)
		local v64 = visible2
		visible2 = v11[v61.slot] == true and #v63 >= 2 and #v62 >= 4

		if visible2 then
			local v66 = false

			for _, v67 in v63 do
				v66 = v66 or v67.id == v41
			end

			if v42 ~= v31 or not v66 then
				local v67 = v8[carried(v61.slot)] -- inferred equivalent call
				v41 = v63[1].id

				for _, v68 in v63 do
					if v68.id == v67 then
						v41 = v68.id
					end
				end
			end
		else
			v41 = "ALL"
		end

		v42 = v31

		if visible2 then
			local ids = {}

			for _, v66 in v63 do
				table.insert(ids, v66.id)
			end

			local joined = table.concat(ids, ",")

			if joined == v44 then
				refreshClassTabs()
			else
				v44 = joined
				buildClassStrip(v63)
			end
		end

		classes.Visible = visible2

		if visible2 then
			task.defer(showClassTab)
		end

		local v66 = visible2 and 55 or 0
		parent2.Position = UDim2.fromOffset(0, v66)
		parent2.Size = UDim2.new(1, 0, 1, -v66)

		if v64 ~= visible2 then
			refreshFooter()
		end

		local v67 = {}

		for _, v68 in v62 do
			if inClass(v68.id) then -- inferred equivalent call
				table.insert(v67, v68)
			end
		end

		local v68 = v41 == "ALL" and "" or "  /  " .. v41
		label.Text = v61.label .. small(Style.paint(string.format("%s  /  %d", v68, #v67), Style.DIM), 16) -- inferred equivalent call
		label4.Text = "NOTHING HERE YET"
		label4.Visible = #v67 == 0
		parent2.CanvasPosition = Vector2.zero

		for k, v69 in v67 do
			local item = ShopData.item(v69.id)
			local v70 = v8[v69.id]

			if not v70 then
				if item.kills then
					v70 = string.format("%d KILLS", item.kills)
				else
					v70 = v61.label
				end
			end

			local card, v71, setSelected = makeCard(parent2, k, v69.id, v70, v69.name, function(p): nil
				picture(v69.id, p, Style.WHITE)
				return nil
			end)

			local chip = MasteryBadge.chip(card, instance)
			local function refresh()
				chip.set(v69.id)

				if ShopData.owns(instance, v69.id) then
					if carried(v61.slot) == v69.id then -- inferred equivalent call
						v71("equipped", "EQUIPPED")
					else
						v71("owned", "OWNED")
					end
				elseif not ShopData.unlocked(instance, v69.id) then
					v71("short", string.format("REQUIRES LVL %d", ShopData.unlockLevel(v69.id)))
				elseif item.price - scrap() <= 0 then -- inferred equivalent call
					v71("price", Style.thousands(item.price), true)
				else
					v71("short", Style.thousands(item.price), true)
				end
			end
			local v73 = {
				button = card,
				key = v69.id,
				refresh = refresh,
				setSelected = setSelected,
				view = nil
			}
			card.Activated:Connect(function()
				selectItem(v69.id)
			end)
			refresh()
			table.insert(v40, v73)
		end

		slide(parent2) -- inferred equivalent call
	end

	local v61 = nil
	local frame14 = Style.frame(box, "Store", UDim2.fromOffset(720, v5), UDim2.fromOffset(10, 64))
	frame14.Visible = false
	local v62 = nil
	local frame15 = Style.frame(box, "Quests", frame14.Size, frame14.Position)
	frame15.Visible = false
	local function nextTab(p: number)
		local v63 = { "kit" }

		if not v2 then
			table.insert(v63, "quests")
		end

		if not v then
			table.insert(v63, "outfits")
		end

		return v63[(table.find(v63, v29) - 1 + p) % #v63 + 1]
	end

	local function setMode(p: string)
		v29 = p

		for _, v63 in v18 do
			local visible3 = v63.id == p
			local button5 = v63.button
			local backgroundColor

			if visible3 then
				backgroundColor = color3
			else
				backgroundColor = Style.PANEL
			end

			button5.BackgroundColor3 = backgroundColor
			local label12 = v63.label
			local textColor

			if visible3 then
				textColor = Style.WHITE
			else
				textColor = Style.MUTED
			end

			label12.TextColor3 = textColor
			v63.under.Visible = visible3
		end

		v61.show(p == "store")
		v62.show(p == "quests")

		if p == "store" or p == "quests" then
			v30 = "slots"
			label.Text = "ARMORY"
			button.Visible = false
			frame2.Visible = true
			frame5.Visible = false
			frame6.Visible = false
			label4.Visible = false
			v38 = nil
			visible = false
			button4.Visible = visible

			refreshFooter()
			button3.Visible = false
			hook.sync(nil)
		else
			local visible3 = picking() -- inferred equivalent call
			frame5.Visible = p == "kit" and not visible3
			frame6.Visible = not frame5.Visible
			button.Visible = visible3
			frame2.Visible = not visible3
			parent2.Visible = visible3
			parent3.Visible = p == "outfits"
			classes.Visible = false
			frame9.Visible = visible3 and v32 ~= nil
			frame13.Visible = p == "outfits"

			if p == "outfits" then
				label.Text = "ARMORY"
				buildOutfitCards()
				dressOutfitCards()
				label4.Text = "NO OUTFITS YET"
				label4.Visible = #Skins.LIST == 0

				for _, v65 in v46 do
					v65.refresh()
				end

				slide(parent3) -- inferred equivalent call
				local v65 = Skins.find(Skins.pick(instance))
				selectSkin(v36 or v65 or Skins.LIST[1])
			elseif visible3 then
				buildKitCards()
				local v65 = v10[v31]
				local v66 = v32

				if not v66 or not ShopData.ITEMS[v66] or ShopData.item(v66).slot ~= v65.slot or not v15[v66] then
					v66 = carried(v65.slot) -- inferred equivalent call

					if not v15[v66] then
						v66 = v14[v65.slot][1] and v14[v65.slot][1].id
					end
				end

				if v66 and v41 ~= "ALL" and v8[v66] ~= v41 then
					v66 = v40[1] and v40[1].key
				end

				selectItem(v66)

				if v54 and not touch then
					spin() -- inferred equivalent call
				end
			else
				label.Text = "ARMORY"
				label4.Visible = false
				v38 = nil
				visible = false
				button4.Visible = visible

				refreshFooter()
				button3.Visible = false
				hook.sync(nil)
			end

			for _, v65 in v39 do
				v65.refresh()
			end
		end
	end

	local function openTab(id: string)
		local v63 = { id = id }

		if v63.id == "quests" and v2 then
			local Quests = require(script.Parent:WaitForChild("Quests"))
			assert(Quests.open, "[Armory] the QUESTS screen is not mounted (SkirmishHud mounts it)")
			Quests.open(true)
		elseif v63.id == "outfits" and v then
			local Outfits = require(script.Parent:WaitForChild("Outfits"))
			assert(Outfits.open, "[Armory] the OUTFITS screen is not mounted (SkirmishHud mounts it)")
			Outfits.open(true)
		elseif v63.id == "vehicles" then
			local Garage = require(script.Parent:WaitForChild("Garage"))
			assert(Garage.open, "[Armory] the VEHICLES screen is not mounted (SkirmishHud mounts it)")
			Garage.open(true)
		elseif v63.id == "store" and ArmoryStore.SCREEN_ON then
			local Store = require(script.Parent:WaitForChild("Store"))
			assert(Store.open, "[Armory] the STORE screen is not mounted (SkirmishHud mounts it)")
			Store.open(true)
		elseif v29 ~= v63.id then
			setMode(v63.id)
			PadMenus.reseat()
		end
	end

	for _, v63 in v18 do
		v63.button.Activated:Connect(function()
			openTab(v63.id)
		end)
	end

	local function stepTabs(p: number) -- 1 equivalent call inferred from this helper
		local v63 = 1

		for k, v64 in v18 do
			if v64.id == v29 then
				v63 = k
			end
		end

		openTab(v18[(v63 - 1 + p) % #v18 + 1].id)
	end

	local function openSlot(k: number) -- 1 equivalent call inferred from this helper
		v31 = k
		v30 = "pick"
		v32 = nil
		setMode("kit")
		PadMenus.reseat()
	end
	local function backOut(): boolean -- 1 equivalent call inferred from this helper
		if not picking() then -- inferred equivalent call
			return false
		end

		v30 = "slots"
		setMode("kit")
		PadMenus.reseat()
		return true
	end

	button.Activated:Connect(backOut)

	fn5 = function(p: string)
		if p ~= v41 and picking() then -- inferred equivalent call
			local selectedObject = GuiService.SelectedObject
			local v63

			if selectedObject == nil then
				v63 = false
			else
				v63 = selectedObject:IsDescendantOf(classes)
			end

			v41 = p
			buildKitCards()
			local function find(p2: string?) -- 1 equivalent call inferred from this helper
				for _, v64 in v40 do
					if v64.key == p2 then
						return v64
					end
				end

				return nil
			end

			local v64 = find(v32) -- inferred equivalent call

			if not v64 then
				local v65 = carried(v10[v31].slot) -- inferred equivalent call
				local flag2 = true

				for _, v66 in v40 do
					if v66.key == v65 then
						v64 = v66
						flag2 = false
						break
					end
				end

				if flag2 then
					v64 = nil
				end

				if not v64 then
					v64 = v40[1]
				end
			end

			local key = v64 and v64.key

			if key == v32 then
				for _, v65 in v40 do
					v65.setSelected(v65.key == key)
				end
			else
				selectItem(key)
			end

			if Glyph.mode() == "gamepad" then
				local v65 = nil

				if v63 then
					for _, v66 in v45 do
						if v66.id == p then
							v65 = v66
						end
					end
				end

				if v65 then
					GuiService.SelectedObject = v65.button
				elseif v64 and v64.button then
					GuiService.SelectedObject = v64 and v64.button
				end
			end
		end
	end

	local function stepClass(p: number)
		if not (picking() and visible2) then -- inferred equivalent call
			return
		end

		local v63 = 1

		for k, v64 in v45 do
			if v64.id == v41 then
				v63 = k
			end
		end

		fn5(v45[(v63 - 1 + p) % #v45 + 1].id)
	end

	UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
		if gameProcessed or not region.Visible then
			return
		end

		local keyCode = input.KeyCode

		if keyCode == Enum.KeyCode.Q or keyCode == Enum.KeyCode.E then
			setMode(nextTab(keyCode == Enum.KeyCode.Q and -1 or 1))
		elseif keyCode == Enum.KeyCode.Z or keyCode == Enum.KeyCode.ButtonL2 then
			stepClass(-1)
		elseif keyCode == Enum.KeyCode.C or keyCode == Enum.KeyCode.ButtonR2 then
			stepClass(1)
		elseif keyCode == Enum.KeyCode.Backspace then
			backOut() -- inferred equivalent call
		end
	end)

	for k, v63 in v10 do
		local textButton = Instance.new("TextButton")
		textButton.Name = v63.slot
		textButton.Text = ""
		textButton.AutoButtonColor = true
		textButton.BorderSizePixel = 0
		textButton.BackgroundColor3 = Style.STEEL
		textButton.Size = UDim2.fromOffset(234, v6)
		textButton.Position = UDim2.fromOffset((k - 1) % 3 * 242, (math.ceil(k / 3) - 1) * (v6 + 8))
		textButton.Parent = frame5
		Style.corner(textButton, 3)
		Style.stroke(textButton, 2, 0, Style.INK, true)
		local label12 = Style.label(textButton, "Slot", v63.label, 14, Style.FONT, 0)
		label12.Position = UDim2.fromOffset(12, 6)
		label12.TextColor3 = Style.MUTED
		local frame16 = Style.frame(textButton, "Icon", UDim2.new(1, -40, 0, v6 - 76), UDim2.fromOffset(20, 30))
		local label13 = Style.label(textButton, "Name", "", 20, Style.FONT, 0)
		label13.AutomaticSize = Enum.AutomaticSize.None
		label13.Size = UDim2.new(1, -24, 0, 24)
		label13.Position = UDim2.new(0, 12, 1, -44)
		label13.TextXAlignment = Enum.TextXAlignment.Left
		label13.TextTruncate = Enum.TextTruncate.AtEnd
		local chip = MasteryBadge.chip(textButton, instance)
		local v64 = nil
		local function refresh()
			local v65 = carried(v63.slot) -- inferred equivalent call
			chip.set(v65)

			if v65 ~= v64 then
				v64 = v65

				for _, child in frame16:GetChildren() do
					child:Destroy()
				end

				picture(v65, frame16, Style.WHITE)
				v65 = nameOf(v65) -- inferred equivalent call
				label13.Text = string.upper(v65)
			end
		end
		textButton.Activated:Connect(function()
			openSlot(k) -- inferred equivalent call
		end)
		table.insert(v39, { refresh = refresh, button = textButton })
	end

	fn4 = function()
		rollScrap(scrap()) -- inferred equivalent call
		refreshLevel()

		for _, v63 in v39 do
			v63.refresh()
		end

		for _, v63 in v40 do
			v63.refresh()
		end

		for _, v63 in v46 do
			v63.refresh()
		end

		if visible2 then
			refreshClassTabs()
		end

		refreshDetail()
	end

	local v63 = {}
	fn3 = function()
		for _, v64 in v63 do
			v64()
		end
	end
	button2.Activated:Connect(function()
		for _, v64 in v63 do
			v64()
		end
	end)

	local v64 = {}
	v64.root = region
	function v64.isOpen()
		return region.Visible or hook.isOpen()
	end

	function v64.setOpen(flag2: boolean)
		holdEnd() -- inferred equivalent call

		if flag2 then
			region.Visible = true
			v30 = "slots"
			setMode(v29)
			fn4()
			local now = os.clock()
			Style.animate(region, function(_, p: number): boolean
				local v65 = math.min((p - now) / 0.16, 1)
				fit(0.92 + 0.08 * Style.easeOut(v65))
				return v65 < 1
			end)
		else
			hook.close()
			v61.show(false)
			v62.show(false)
			region.Visible = false
			v48 = nil
			view.show(nil)
		end
	end
	function v64.markLife()
		v64.refresh()
	end
	function v64.refresh()
		if region.Visible then
			fn4()
		end
	end
	function v64.firstPad()
		if v29 == "store" then
			return v61.firstPad()
		elseif v29 == "quests" then
			return v62.firstPad()
		end

		if v29 == "kit" and v30 == "slots" then
			return v39[v31].button
		end

		local v65 = if v29 == "kit" then v40 else v46
		local v66

		if v29 == "kit" then
			v66 = v32
		else
			v66 = v36 and v36.id
		end

		for _, v67 in v65 do
			if v67.key == v66 then
				return v67.button
			end
		end

		return if v65[1] then v65[1].button else v39[1].button
	end

	function v64.stepTab(p: number)
		stepTabs(p) -- inferred equivalent call
	end
	function v64.showKit()
		setMode("kit")
	end
	function v64.back()
		local v65 = v61.back()

		if v65 then
			return v65
		end

		if not picking() then -- inferred equivalent call
			return false
		end

		v30 = "slots"
		setMode("kit")
		PadMenus.reseat()
		v65 = true
		return true
	end

	function v64.onClose(callback2)
		table.insert(v63, callback2)
	end
	v61 = ArmoryStore.new(frame14, instance, { touch = true, reseat = PadMenus.reseat })
	v62 = ArmoryQuests.new(frame15, instance, {
		touch = true,
		reseat = PadMenus.reseat,
		scrapPlate = box3,
		levelPlate = box2,
		holdScrap = function(flag2: boolean)
			v49 = flag2

			if not flag2 then
				rollScrap(scrap()) -- inferred equivalent call
			end
		end
	})

	setMode("kit")
	return v64
end

function ArmoryTouch.mount(data)
	local player = data.player
	local shop = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Remotes"):WaitForChild("Shop", 30)
	assert(shop and shop:IsA("RemoteFunction"), "GameUI: remote Game.Remotes.Shop (RemoteFunction) is missing")
	local function request(p: string, p2: string, p3: string?)
		local success, result, v18 = pcall(shop.InvokeServer, shop, p, p2, p3)

		if not success then
			warn("[Armory] request failed: " .. tostring(result))
			return false, "No answer from the armory."
		end

		local selected = result == true

		if type(v18) == "string" then
			return selected, v18
		end

		return selected, ""
	end

	local v18 = ArmoryTouch.new(data.layers.menu, player, request)
	local v19 = true
	local function toggle()
		local v20 = not v18.isOpen()

		if v20 then
			v19 = UserInputService.MouseIconEnabled
			UserInputService.MouseIconEnabled = true
		else
			UserInputService.MouseIconEnabled = Viewmodel.cursorAfterMenu(v19)
		end

		v18.setOpen(v20)
		data.setMenu(v20)

		if v20 then
			PadMenus.open("armory", v18.root, function()
				if not v18.back() then
					toggle()
				end
			end, { first = v18.firstPad, tab = v18.stepTab })
		else
			PadMenus.close("armory")
		end
	end
	v18.onClose(toggle)
	ArmoryTouch.toggle = toggle
	function ArmoryTouch.close()
		if v18.isOpen() then
			toggle()
		end
	end
	function ArmoryTouch.openLoadout()
		if v18.isOpen() and not v18.root.Visible then
			toggle()
		end

		if not v18.isOpen() then
			toggle()
		end

		v18.showKit()
	end

	local v20 = false
	player.AttributeChanged:Connect(function(value: string)
		local v21 = value == "Scrap"
			or value == "Level"
			or value == Skins.PACK_ATTR
			or value == "XP"
			or value == "XPNext"
			or value == "RoundXP"
			or value == Skins.ATTR
			or value == ShopData.STREAK_ATTR
			or string.sub(value, 1, 5) == "Owns_"
			or string.sub(value, 1, 3) == "Mx_"

		for _, v22 in ShopData.PICKS do
			v21 = v21 or value == v22.attr
		end

		if v21 and not v20 then
			v20 = true
			task.defer(function()
				v20 = false
				v18.refresh()
			end)
		end
	end)
	data.onDead(function(flag: boolean)
		if flag and v18.isOpen() then
			toggle()
		end
	end)

	player.CharacterAdded:Connect(v18.markLife)

	if player.Character then
		v18.markLife()
	end
end

return ArmoryTouch