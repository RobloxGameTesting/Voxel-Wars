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

local v4 = Style.isTouch() and 18 or 13
local color = Color3.fromRGB(226, 112, 86)
local color2 = Color3.fromRGB(255, 150, 124)
local color3 = Color3.fromRGB(38, 40, 45)
local color4 = Color3.fromRGB(26, 27, 31)

local v5 = {
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

local v6 = {
	AssaultRifle = "AUTO",
	SMG = "AUTO",
	LMG = "AUTO",
	DMR = "SEMI",
	Pistol = "SEMI",
	HandCannon = "SEMI",
	Shotgun = "PUMP",
	Sniper = "BOLT"
}
local v7 = {
	{ slot = "primary", tab = "primary", label = "PRIMARY" },
	{ slot = "secondary", tab = "secondary", label = "SECONDARY" },
	{ slot = "utility", tab = "utility", label = "UTILITY" },
	{ slot = "melee", tab = "melee", label = "MELEE" },
	{ slot = "throwable", tab = "gear", label = "THROWABLE" },
	{ slot = "streak", tab = "streaks", label = "STREAK" }
}
local v8 = { primary = true }
local v9 = { "RIFLE", "SMG", "LMG", "DMR", "SNIPER", "SHOTGUN" }
local ArmoryDesk = {}
ArmoryDesk.toggle = nil
ArmoryDesk.openLoadout = nil
ArmoryDesk.close = nil

for k in RifleSpecs.LIST do
	v5[k] = "RIFLE"
	v6[k] = "AUTO"
end

for k in LMGSpecs.LIST do
	v5[k] = "LMG"
	v6[k] = "AUTO"
end

for k in SMGSpecs.LIST do
	v5[k] = "SMG"
	v6[k] = "AUTO"
end

for k in DMRSpecs.LIST do
	v5[k] = "DMR"
	v6[k] = "SEMI"
end

for k in SniperSpecs.LIST do
	v5[k] = "SNIPER"
	v6[k] = "BOLT"
end

for k, v10 in PistolSpecs.LIST do
	v5[k] = "PISTOL"
	v6[k] = v10.auto and "AUTO" or "SEMI"
end

local v10 = {
	AssaultRifle = { damage = 41.2, interval = 0.1 },
	SMG = { damage = 34.3, interval = 0.072 },
	Shotgun = { damage = 28, pellets = 8, interval = 0.6 },
	DMR = { damage = 75, interval = 0.2 },
	LMG = { damage = 41.2, interval = 0.092 },
	Sniper = { damage = 160, interval = 1.5 },
	Pistol = { damage = 40, interval = 0.165 },
	HandCannon = { damage = 105, interval = 0.42 }
}

for _, v11 in { RifleSpecs.LIST, LMGSpecs.LIST } do
	for k, v12 in v11 do
		v10[k] = { damage = v12.damage[1][2], interval = v12.interval }
	end
end

for k, v11 in SniperSpecs.LIST do
	v10[k] = { damage = v11.damage.body, interval = v11.interval }
end

for _, v11 in { PistolSpecs.LIST, SMGSpecs.LIST } do
	for k, v12 in v11 do
		v10[k] = { damage = v12.damage[1][2], interval = v12.interval }
	end
end

for k, v11 in DMRSpecs.LIST do
	v10[k] = { damage = v11.damage.body[1][2], interval = v11.interval }
end

local v11 = {}
local v12 = {}

for _, v13 in v7 do
	v11[v13.slot] = {}
end

for _, v13 in LoadoutData do
	for _, item in v13.items do
		local item2 = ShopData.item(item.id)
		v12[item.id] = item
		table.insert(v11[item2.slot], item)
	end
end

local v13 = {
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

for _, v14 in {
	{ list = RifleSpecs.LIST, slot = "primary", caption = "PRIMARY" },
	{ list = SMGSpecs.LIST, slot = "primary", caption = "PRIMARY" },
	{ list = LMGSpecs.LIST, slot = "primary", caption = "PRIMARY" },
	{ list = DMRSpecs.LIST, slot = "primary", caption = "PRIMARY" },
	{ list = SniperSpecs.LIST, slot = "primary", caption = "PRIMARY" },
	{ list = PistolSpecs.LIST, slot = "secondary", caption = "SECONDARY" }
} do
	local v15 = {}

	for k in v14.list do
		table.insert(v15, k)
	end

	table.sort(v15)

	for _, v16 in v15 do
		if v12[v16] then
			continue
		end

		assert(
			ShopData.ITEMS[v16] and ShopData.item(v16).slot == v14.slot,
			"[Armory] " .. v16 .. " needs a " .. v14.slot .. " ShopData entry"
		)
		local v17 = {
			id = v16,
			tool = v16,
			name = v14.list[v16].name,
			slot = v14.caption,
			description = v13[v16] or ""
		}
		v12[v16] = v17
		local v18 = v11[v14.slot]
		local v19 = #v18 + 1

		for k, v20 in v18 do
			if v5[v20.id] == v5[v16] then
				v19 = k + 1
			end
		end

		table.insert(v18, v19, v17)
	end
end

for _, v14 in { "primary", "secondary" } do
	local v15 = v11[v14]
	local v16 = {}

	for k, v17 in v15 do
		local v18 = v5[v17.id] or v17.id
		v16[v18] = v16[v18] or k
	end

	table.sort(v15, function(a, b): boolean
		local v17 = v16[v5[a.id] or a.id]
		local v18 = v16[v5[b.id] or b.id]

		if v17 ~= v18 and v8[v14] then
			return v17 < v18
		end

		local v19 = ShopData.unlockLevel(a.id)
		local v20 = ShopData.unlockLevel(b.id)

		if v19 ~= v20 then
			return v19 < v20
		end

		local price = ShopData.item(a.id).price or 0
		local price2 = ShopData.item(b.id).price or 0

		if price == price2 then
			return a.id < b.id
		end

		return price < price2
	end)
end

local primary = v11.primary
local v14 = {}

for i = #primary, 1, -1 do
	if ShopData.ITEMS[primary[i].id].hidden then
		table.insert(v14, 1, table.remove(primary, i))
	end
end

local function listHiddenGuns()
	if #v14 ~= 0 then
		local Players = game:GetService("Players")

		if Players.LocalPlayer:GetAttribute("UnlockAll") == true then
			local primary2 = v11.primary

			for _, v15 in v14 do
				local v16 = #primary2 + 1

				for k, v17 in primary2 do
					if v5[v17.id] == v5[v15.id] then
						v16 = k + 1
					end
				end

				table.insert(primary2, v16, v15)
			end

			table.clear(v14)
		end
	end
end

local function nameOf(p: string) -- 4 equivalent calls inferred from this helper
	local v15 = v12[p]

	if v15 then
		return v15.name
	end

	local v16 = RifleSpecs.LIST[p]
		or SMGSpecs.LIST[p]
		or LMGSpecs.LIST[p]
		or DMRSpecs.LIST[p]
		or SniperSpecs.LIST[p]
		or PistolSpecs.LIST[p]
	return if v16 then v16.name else p
end

local function toolOf(childName: string)
	local v15 = v12[childName]

	if v15 and v15.tool then
		childName = v15.tool
	end

	local tool = ToolTemplates:FindFirstChild(childName)
	return if tool and tool:IsA("Tool") then tool else nil
end

local function row(parent, name: string, p: number, flag: boolean?) -- 10 equivalent calls inferred from this helper
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

local function padding(parent, p: number, p2: number) -- 6 equivalent calls inferred from this helper
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

local function picture(value: string, p, white: Color3)
	local v15 = v12[value]
	local v16 = if v15 and v15.tool then v15.tool else value
	local tool = ToolTemplates:FindFirstChild(v16)

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
	local v17 = label(p, "Letter", string.upper((string.sub(value, 1, 1))), 36, Style.FONT, 0)
	v17.AutomaticSize = Enum.AutomaticSize.None
	v17.Size = UDim2.fromScale(1, 1)
	v17.TextColor3 = Style.STEEL_LIGHT
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
	local v15 = v10[p]

	if not v15 then
		return nil
	end

	local item = ShopData.item(p)
	local track = trackOf(item, "Damage") -- inferred equivalent call
	local track2 = trackOf(item, "Magazine") -- inferred equivalent call
	local track3 = trackOf(item, "Reload") -- inferred equivalent call
	local v16 = v15.damage * (not track and 1 or ShopData.value(track, callback("Damage")))
	local num = v16 * (v15.pellets or 1)
	local num2 = 60 / v15.interval
	local num3 = not track2 and 0 or ShopData.value(track2, callback("Magazine"))
	local num4 = not track3 and 0 or reloadBase(track3) * ShopData.value(track3, callback("Reload")) -- inferred equivalent call

	local v17 = {
		label = "DAMAGE",
		frac = math.clamp(num / 210, 0, 1),
		text = 0,
		num = 0
	}
	local text

	if v15.pellets then
		text = string.format("%dx%d", v15.pellets, (math.round(v16)))
	else
		text = tostring((math.round(v16)))
	end

	v17.text = text
	v17.num = num
	return {
		v17,
		{
			label = "FIRE RATE",
			frac = math.clamp(num2 / 900, 0, 1),
			text = string.format("%d RPM", (math.round(num2))),
			num = num2
		},
		{
			label = "MAGAZINE",
			frac = math.clamp(num3 / 100, 0, 1),
			text = tostring((math.round(num3))),
			num = num3
		},
		{
			label = p == "Shotgun" and "PER SHELL" or "RELOAD",
			frac = math.clamp(1 - (num4 - 0.5) / 2.8, 0.05, 1),
			text = string.format("%.2f S", num4),
			num = num4,
			lower = true
		}
	}
end

function ArmoryDesk.new(layer, instance, callback)
	local region = Style.region(layer, "Armory", Vector2.new(0.5, 0.5), Vector2.zero, Vector2.new(1000, 606))
	region.Visible = false
	local fit = Style.fit(region, Vector2.new(1000, 606))
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

	local fill = Style.fill(box, "Header", Style.STEEL, UDim2.new(1, 0, 0, 58))
	Style.corner(fill, 3)
	local label_2 = Style.label(fill, "Title", "ARMORY", 28, Style.FONT, 1.5)
	label_2.Position = UDim2.fromOffset(16, 13)
	local frame = Style.frame(
		fill,
		"Tabs",
		UDim2.fromOffset(v3 and 424 or 386, 58),
		UDim2.fromOffset(v3 and 122 or 150, 0)
	)
	row(frame, "Row", 6) -- inferred equivalent call
	local v15 = {}
	local v16 = {
		{ id = "kit", text = "LOADOUT" },
		{ id = "quests", text = "QUESTS" },
		{ id = "outfits", text = "OUTFITS" },
		{ id = "store", text = "STORE" }
	}

	if v3 then
		table.insert(v16, 4, { id = "vehicles", text = "VEHICLES" })
	end

	for k, v17 in v16 do
		local button, v18 = Style.button(
			frame,
			v17.id,
			v17.text,
			Style.PANEL,
			UDim2.fromOffset(v3 and 80 or 92, 36),
			Style.MUTED,
			18
		)

		if v3 then
			v18.TextScaled = true
			local uiTextSizeConstraint = Instance.new("UITextSizeConstraint")
			uiTextSizeConstraint.MaxTextSize = 17
			uiTextSizeConstraint.MinTextSize = 12
			uiTextSizeConstraint.Parent = v18
			local uiPadding = Instance.new("UIPadding")
			uiPadding.PaddingLeft = UDim.new(0, 3)
			uiPadding.PaddingRight = UDim.new(0, 3)
			uiPadding.Parent = v18
		end

		button.LayoutOrder = k
		local tape = Style.tape(button, "Underline", UDim2.new(1, 0, 0, 5), 120, 10)
		tape.AnchorPoint = Vector2.new(0, 1)
		tape.Position = UDim2.fromScale(0, 1)
		table.insert(v15, { id = v17.id, button = button, label = v18, under = tape })

		if v17.id == "store" then
			ArmoryStore.freeBadge(button, instance)
		elseif v17.id == "quests" then
			ArmoryQuests.claimBadge(button, instance)
		end
	end

	local button, v17 = Style.button(fill, "Close", "X", Style.ORANGE, UDim2.fromOffset(36, 36), Style.INK, 20)

	local cap = Glyph.cap(button, nil, Enum.KeyCode.ButtonB, 26)
	cap.AnchorPoint = Vector2.new(0.5, 0.5)
	cap.Position = UDim2.fromScale(0.5, 0.5)
	local function closeFace() -- 1 equivalent call inferred from this helper
		v17.Visible = not Glyph.gamepad()
	end
	Glyph.onChange(closeFace)
	closeFace() -- inferred equivalent call
	button.AnchorPoint = Vector2.new(1, 0.5)
	button.Position = UDim2.new(1, -12, 0.5, 0)
	local frame2 = Style.frame(fill, "Stats", UDim2.fromOffset(0, 32), UDim2.new(1, -60, 0.5, 0), Vector2.new(1, 0.5))
	frame2.AutomaticSize = Enum.AutomaticSize.X
	row(frame2, "Row", 8) -- inferred equivalent call
	local box2 = Style.box(frame2, "Level", Style.INK, UDim2.fromOffset(0, 32), 3, 1.5)
	box2.AutomaticSize = Enum.AutomaticSize.X
	box2.LayoutOrder = 1
	padding(box2, 10, 10) -- inferred equivalent call
	row(box2, "Row", 8) -- inferred equivalent call
	local label = Style.label(box2, "Text", "", 18, Style.FONT, 0)
	label.Size = UDim2.fromOffset(0, 32)
	label.TextColor3 = Style.WHITE
	label.LayoutOrder = 1
	local fill2 = Style.fill(box2, "Xp", color4, UDim2.fromOffset(64, 6))
	fill2.LayoutOrder = 2
	Style.stroke(fill2, 1, 0, Style.INK, true)
	local fill3 = Style.fill(fill2, "Fill", Style.HAZARD, UDim2.fromScale(0, 1))
	local label2 = Style.label(box2, "XpText", "", 12, Style.FONT, 0)
	label2.Size = UDim2.fromOffset(0, 32)
	label2.TextColor3 = Style.MUTED
	label2.LayoutOrder = 3
	local box3 = Style.box(frame2, "Scrap", Style.INK, UDim2.fromOffset(0, 32), 3, 1.5)
	box3.AutomaticSize = Enum.AutomaticSize.X
	box3.LayoutOrder = 2
	row(box3, "Row", 6) -- inferred equivalent call
	padding(box3, 8, 10) -- inferred equivalent call
	local nut_2 = Style.nut(box3, 20)
	nut_2.LayoutOrder = 1
	local label3 = Style.label(box3, "Amount", "0", 20, Style.FONT, 0)
	label3.TextColor3 = Style.HAZARD
	label3.LayoutOrder = 2

	local fill4 = Style.fill(box, "Footer", Style.STEEL, UDim2.new(1, 0, 0, 26), UDim2.new(0, 0, 1, -26))
	Style.corner(fill4, 3)
	local frame3 = Style.frame(fill4, "Prompts", UDim2.fromScale(1, 1))
	padding(frame3, 16, 16) -- inferred equivalent call
	row(frame3, "Row", 18) -- inferred equivalent call
	local frame4 = Style.frame(box, "Kit", UDim2.fromOffset(212, 498), UDim2.fromOffset(12, 70))
	local label_3 = Style.label(frame4, "Title", "LOADOUT", 13, Style.FONT, 0)
	label_3.TextColor3 = Style.MUTED

	local frame5 = Style.frame(box, "Grid", UDim2.fromOffset(410, 498), UDim2.fromOffset(236, 70))
	frame5.ClipsDescendants = true
	local label4 = Style.label(frame5, "Title", "", 13, Style.FONT, 0)
	label4.TextColor3 = Style.MUTED
	label4.RichText = true
	local function scroller(name: string)
		local scrollingFrame = Instance.new("ScrollingFrame")
		scrollingFrame.Name = name
		scrollingFrame.BackgroundTransparency = 1
		scrollingFrame.BorderSizePixel = 0
		scrollingFrame.Position = UDim2.fromOffset(0, 22)
		scrollingFrame.Size = UDim2.new(1, 0, 1, -22)
		scrollingFrame.ScrollBarThickness = 6
		scrollingFrame.ScrollBarImageColor3 = Style.HAZARD
		scrollingFrame.CanvasSize = UDim2.new()
		scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scrollingFrame.Parent = frame5
		local uiPadding = Instance.new("UIPadding")
		uiPadding.PaddingTop = UDim.new(0, 6)
		uiPadding.PaddingLeft = UDim.new(0, 6)
		uiPadding.Parent = scrollingFrame
		local uiGridLayout = Instance.new("UIGridLayout")
		uiGridLayout.CellSize = UDim2.fromOffset(124, 138)
		uiGridLayout.CellPadding = UDim2.fromOffset(10, 10)
		uiGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uiGridLayout.Parent = scrollingFrame
		return scrollingFrame
	end

	local parent2 = scroller("Items")
	local parent3 = scroller("Outfits")
	parent3.Visible = false
	parent3.Size = UDim2.new(269 / 309, 0, 269 / 309, -5918 / 309)
	local uiScale = Instance.new("UIScale")
	uiScale.Scale = 309 / 269
	uiScale.Parent = parent3

	local frame6 = Style.frame(frame5, "ClassBar", UDim2.new(1, 0, 0, 32), UDim2.fromOffset(0, 19))
	frame6.Visible = false
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0, 4)
	uiListLayout.Parent = frame6
	local cap_2 = Glyph.cap(frame6, nil, Enum.KeyCode.ButtonL2, 22)
	cap_2.LayoutOrder = 1
	local cap_3 = Glyph.cap(frame6, nil, Enum.KeyCode.ButtonR2, 22)
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
	classes.Parent = frame6
	classes:GetPropertyChangedSignal("Visible"):Connect(function()
		frame6.Visible = classes.Visible
	end)
	row(classes, "Row", 4) -- inferred equivalent call
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingTop = UDim.new(0, 3)
	uiPadding.PaddingBottom = UDim.new(0, 3)
	uiPadding.PaddingLeft = UDim.new(0, 3)
	uiPadding.PaddingRight = UDim.new(0, 3)
	uiPadding.Parent = classes

	local uiPadding2 = Instance.new("UIPadding")
	uiPadding2.Parent = frame6
	local function capRoom() -- 1 equivalent call inferred from this helper
		local udim = UDim.new(0, Glyph.gamepad() and 3 or 0)
		uiPadding2.PaddingLeft = udim
		uiPadding2.PaddingRight = udim
	end
	Glyph.onChange(capRoom)
	capRoom() -- inferred equivalent call
	local label5 = Style.label(frame5, "Empty", "", 16, Style.FONT, 1.5)
	label5.TextColor3 = Style.MUTED
	label5.AnchorPoint = Vector2.new(0.5, 0.5)
	label5.Position = UDim2.fromScale(0.5, 0.5)

	local box4 = Style.box(box, "Detail", color3, UDim2.fromOffset(330, 498), 3, 2)
	box4.AnchorPoint = Vector2.new(1, 0)
	box4.Position = UDim2.new(1, -12, 0, 70)

	local label6 = Style.label(box4, "Toast", "", 15, Style.FONT, 1.5)
	label6.AnchorPoint = Vector2.new(0.5, 1)
	label6.Position = UDim2.fromOffset(165, 126)
	label6.Visible = false
	label6.ZIndex = 6

	local button2 = Style.button(box4, "Action", "", Style.HAZARD, UDim2.fromOffset(310, 50), Style.INK, 18)
	button2.Position = UDim2.fromOffset(10, 438)
	button2.ClipsDescendants = true
	local text_2 = button2:FindFirstChild("Text")
	text_2.Visible = false
	local fill5 = Style.fill(button2, "Hold", Style.WHITE, UDim2.fromScale(0, 1))
	fill5.BackgroundTransparency = 0.45
	fill5.ZIndex = 2
	local v18 = costContent(button2, 18)
	zAll(button2:FindFirstChild("Content"), 3)
	local tape = Style.tape(button2, "Tape", UDim2.new(1, 0, 0, 4), 310, 10)
	tape.ZIndex = 3

	local offset = button2.Size.Y.Offset
	local button3, v19 = Style.button(box4, "Instant", "", Style.HAZARD, UDim2.fromOffset(310, offset), Style.INK, 18)
	button3.Position = UDim2.fromOffset(button2.Position.X.Offset, button2.Position.Y.Offset - offset - 6)
	button3.Visible = false
	v19.Visible = false
	local robuxLine, v20 = Style.robuxLine(button3, "Line", 18)
	robuxLine:FindFirstChild("Words").UIStroke:Destroy()
	local run = nil
	local visible = false
	local v21 = false
	button3.Activated:Connect(function()
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
		action = button2,
		width = 310,
		room = function(flag: boolean)
			v21 = flag
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

	local frame7 = Style.frame(box4, "Item", UDim2.fromScale(1, 1))
	local box5 = Style.box(frame7, "Stage", color4, UDim2.fromOffset(310, 120), 3, 1.5)
	box5.Position = UDim2.fromOffset(10, 10)
	box5.ClipsDescendants = true
	box5.Active = true
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Rotation = 90
	uiGradient.Color = ColorSequence.new(color4, color3)
	uiGradient.Parent = box5
	local frame8 = Style.frame(box5, "Holder", UDim2.fromScale(1, 1))
	local uiScale2 = Instance.new("UIScale")
	uiScale2.Parent = frame8
	local plate = MasteryBadge.plate(box5, instance)
	local frame9 = Style.frame(frame7, "Tags", UDim2.fromOffset(310, 18), UDim2.fromOffset(10, 138))
	row(frame9, "Row", 4) -- inferred equivalent call
	local label7 = Style.label(frame7, "Name", "", 26, Style.FONT, 1.5)
	label7.Position = UDim2.fromOffset(10, 158)
	local label8 = Style.label(frame7, "Description", "", v4, Style.FONT_BODY, 0)
	label8.AutomaticSize = Enum.AutomaticSize.None
	label8.Size = UDim2.fromOffset(310, 34)
	label8.Position = UDim2.fromOffset(10, 190)
	label8.TextWrapped = true
	label8.TextXAlignment = Enum.TextXAlignment.Left
	label8.TextYAlignment = Enum.TextYAlignment.Top
	label8.TextColor3 = Style.MUTED
	label8.TextTransparency = 0.15

	local frame10 = Style.frame(frame7, "Stats", UDim2.fromOffset(310, 88), UDim2.fromOffset(10, 230))
	local v22 = {}

	for i = 1, 4 do
		local v23 = (i - 1) * 22
		local label9 = Style.label(frame10, "Label" .. i, "", 12, Style.FONT, 0)
		label9.Position = UDim2.fromOffset(0, v23 + 1)
		label9.TextColor3 = Style.MUTED
		local fill6 = Style.fill(frame10, "Bar" .. i, color4, UDim2.fromOffset(122, 8), UDim2.fromOffset(84, v23 + 7))
		Style.stroke(fill6, 1, 0, Style.INK, true)
		local fill7 = Style.fill(fill6, "Base", Style.MUTED, UDim2.fromScale(0, 1))
		local fill8 = Style.fill(fill6, "Gain", Style.HAZARD, UDim2.fromScale(0, 1))
		local fill9 = Style.fill(fill6, "Loss", color, UDim2.fromScale(0, 1))
		fill9.BackgroundTransparency = 0.3
		local fill10 = Style.fill(
			fill6,
			"Equipped",
			Style.WHITE,
			UDim2.new(0, 2, 1, 6),
			UDim2.fromScale(0, 0.5),
			Vector2.new(0.5, 0.5)
		)
		fill10.ZIndex = 2
		local label10 = Style.label(frame10, "Value" .. i, "", 13, Style.FONT, 0)
		label10.RichText = true
		label10.AutomaticSize = Enum.AutomaticSize.None
		label10.Size = UDim2.fromOffset(98, 18)
		label10.Position = UDim2.fromOffset(310, v23)
		label10.AnchorPoint = Vector2.new(1, 0)
		label10.TextXAlignment = Enum.TextXAlignment.Right
		table.insert(v22, {
			label = label9,
			base = fill7,
			gain = fill8,
			loss = fill9,
			tick = fill10,
			value = label10
		})
	end

	local label9 = Style.label(frame7, "Facts", "", 13, Style.FONT, 0)
	label9.AutomaticSize = Enum.AutomaticSize.None
	label9.Size = UDim2.fromOffset(310, 88)
	label9.Position = UDim2.fromOffset(10, 230)
	label9.TextWrapped = true
	label9.TextXAlignment = Enum.TextXAlignment.Left
	label9.TextYAlignment = Enum.TextYAlignment.Top
	label9.LineHeight = 1.25
	local label10 = Style.label(frame7, "Compare", "", 11, Style.FONT, 0)
	label10.Position = UDim2.fromOffset(10, 318)
	label10.TextColor3 = Style.DIM

	local frame11 = Style.frame(box4, "Outfit", UDim2.fromScale(1, 1))
	frame11.Visible = false
	local box6 = Style.box(frame11, "Stage", color4, UDim2.fromOffset(310, 290), 3, 1.5)
	box6.Position = UDim2.fromOffset(10, 10)
	box6.ClipsDescendants = true
	local uiGradient2 = Instance.new("UIGradient")
	uiGradient2.Rotation = 90
	uiGradient2.Color = ColorSequence.new(color4, color3)
	uiGradient2.Parent = box6
	local view = SkinPreview.view(box6, "full")
	local stage = OutfitLook.stage(box6)
	local label11 = Style.label(box6, "NoBody", "DEPLOY TO SEE YOUR SOLDIER", 14, Style.FONT, 0)
	label11.AnchorPoint = Vector2.new(0.5, 0.5)
	label11.Position = UDim2.fromScale(0.5, 0.5)
	label11.TextColor3 = Style.DIM

	local v23 = {}
	local label12 = Style.label(frame11, "Name", "", 26, Style.FONT, 1.5)
	label12.Position = UDim2.fromOffset(10, 308)
	local label13 = Style.label(frame11, "Description", "", v4, Style.FONT_BODY, 0)
	label13.AutomaticSize = Enum.AutomaticSize.None
	label13.Size = UDim2.fromOffset(310, 52)
	label13.Position = UDim2.fromOffset(10, 340)
	label13.TextWrapped = true
	label13.TextXAlignment = Enum.TextXAlignment.Left
	label13.TextYAlignment = Enum.TextYAlignment.Top
	label13.TextColor3 = Style.MUTED
	local label14 = Style.label(frame11, "Lock", "", 14, Style.FONT, 0)
	label14.Position = UDim2.fromOffset(10, 398)
	label14.RichText = true

	local v24 = "kit"
	local v25 = 1
	local v26 = nil
	local v27 = nil
	local v28 = (not instance.Team or instance.Team.Name ~= "Reds" and instance.Team.Name ~= "Blues") and "Reds"
		or instance.Team.Name
	local flag = false
	local count = 0
	local v29 = nil
	local v30 = {}
	local v31 = {}
	local v32 = "ALL"
	local v36 = 0
	local visible2 = false
	local v38 = ""

	local v39 = {}
	local v40 = {}
	local v41 = nil
	local v42 = nil
	local fn4

	local function scrap() -- 5 equivalent calls inferred from this helper
		local scrap2 = instance:GetAttribute("Scrap")
		return if type(scrap2) == "number" then scrap2 else 0
	end

	local function num(attributeName: string) -- 2 equivalent calls inferred from this helper
		local attribute = instance:GetAttribute(attributeName)
		return if type(attribute) == "number" then attribute else 0
	end

	local v43 = false
	local function rollScrap(p: number)
		if v43 then
			return
		end

		local v44 = v42
		v42 = p

		if v44 == nil or v44 == p then
			Style.stop(label3)
			label3.Text = Style.thousands(p)
		else
			local now = os.clock()
			Style.animate(label3, function(_, p2: number): boolean
				local v45 = math.min((p2 - now) / 0.45, 1)
				label3.Text = Style.thousands((math.round(v44 + (p - v44) * Style.easeOut(v45))))
				return v45 < 1
			end)
		end
	end

	local function refreshLevel()
		label.Text = string.format("LV %d", Skins.levelOf(instance))
		local v44 = num("XP") -- inferred equivalent call
		local v45 = num("XPNext") -- inferred equivalent call

		if v45 > 0 then
			fill3.Size = UDim2.fromScale(math.clamp(v44 / v45, 0, 1), 1)
			label2.Text = Style.thousands((math.min(v44, v45))) .. " / " .. Style.thousands(v45) .. " XP"
		else
			fill3.Size = UDim2.fromScale(1, 1)
			label2.Text = "MAX"
		end
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
		local v44 = count
		label6.Text = text
		local textColor = if flag2 then Style.HAZARD else color
		label6.TextColor3 = textColor
		label6.Visible = true
		task.delay(2.4, function()
			if count == v44 then
				label6.Visible = false
			end
		end)
	end

	local function ask(p: string, p2: string, p3: string?) -- 4 equivalent calls inferred from this helper
		if flag then
			return
		end

		flag = true
		local v44, v45 = callback(p, p2, p3)
		flag = false

		if not v44 or string.sub(v45, 1, 8) ~= "Equipped" then
			showToast(string.upper(v45), v44) -- inferred equivalent call
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
		local label15 = Style.label(textButton, "Family", p, 11, Style.FONT, 0)
		label15.Position = UDim2.fromOffset(8, 4)
		label15.TextColor3 = Style.HAZARD
		local frame12 = Style.frame(textButton, "Picture", UDim2.new(1, -16, 0, 64), UDim2.fromOffset(8, 22))
		local v44 = fn5(frame12)

		if p2 then
			OutfitLook.card(textButton, frame12, label15, p2)
		end

		local fill6 = Style.fill(textButton, "Veil", Style.INK, UDim2.new(1, -16, 0, 64), UDim2.fromOffset(8, 22))
		fill6.BackgroundTransparency = 0.45
		fill6.ZIndex = 2
		fill6.Visible = false

		local folder = Style.frame(
			fill6,
			"Lock",
			UDim2.fromOffset(25, 35),
			UDim2.fromScale(0.5, 0.5),
			Vector2.new(0.5, 0.5)
		)
		local frame13 = Style.frame(
			folder,
			"Shackle",
			UDim2.fromOffset(16, 22),
			UDim2.fromScale(0.5, 0),
			Vector2.new(0.5, 0)
		)
		Style.corner(frame13, 22)
		Style.stroke(frame13, 4, 0, Style.STEEL_LIGHT, true)
		local box7 = Style.box(folder, "Body", Style.HAZARD, UDim2.new(1, 0, 0, 22), 3, 2)
		box7.AnchorPoint = Vector2.new(0, 1)
		box7.Position = UDim2.fromScale(0, 1)
		local fill7 = Style.fill(
			box7,
			"Keyhole",
			Style.INK,
			UDim2.fromOffset(6, 6),
			UDim2.fromScale(0.5, 0.4),
			Vector2.new(0.5, 0.5)
		)
		Style.corner(fill7, 22)
		Style.fill(box7, "Slot", Style.INK, UDim2.fromOffset(2, 7), UDim2.fromScale(0.5, 0.45), Vector2.new(0.5, 0))

		for _, guiObject in folder:GetDescendants() do
			if guiObject:IsA("GuiObject") then
				guiObject.ZIndex = 3
			end
		end

		folder.ZIndex = 3

		local label16 = Style.label(textButton, "Name", string.upper(name), 16, Style.FONT, 0)
		label16.AutomaticSize = Enum.AutomaticSize.None
		label16.Size = UDim2.new(1, -16, 0, 20)
		label16.Position = UDim2.fromOffset(8, 88)
		label16.TextXAlignment = Enum.TextXAlignment.Left
		label16.TextTruncate = Enum.TextTruncate.AtEnd
		local box8 = Style.box(textButton, "Chip", Style.INK, UDim2.fromOffset(0, 20), 2, 1)
		box8.AutomaticSize = Enum.AutomaticSize.X
		box8.AnchorPoint = Vector2.new(0, 0.5)
		box8.Position = UDim2.fromOffset(8, 121)
		local uiScale3 = Instance.new("UIScale")
		uiScale3.Parent = box8
		padding(box8, 5, 6) -- inferred equivalent call
		row(box8, "Row", 4) -- inferred equivalent call
		local nut = Style.nut(box8, 12)
		nut.LayoutOrder = 1
		local label17 = Style.label(box8, "Text", "", 12, Style.FONT, 0)
		label17.LayoutOrder = 2
		zAll(box8, 3)
		local uiStroke = box8:FindFirstChildOfClass("UIStroke")
		local v45 = nil
		local function setChip(p3: string, text: string, flag2: boolean?)
			if p3 == "equipped" and v45 ~= nil and v45 ~= "equipped" then
				local now = os.clock()
				Style.animate(uiScale3, function(_, p4: number): boolean
					local v46 = math.min((p4 - now) / 0.08, 1)
					uiScale3.Scale = 1.2 + -0.19999999999999996 * Style.easeOut(v46)
					return v46 < 1
				end)

				assert(MenuAudio.stamp, "[Armory] MenuAudio is not mounted")
				MenuAudio.stamp()

				if text == "WEARING" then
					GearSound.wear()
				else
					GearSound.equip()
				end
			end

			v45 = p3
			nut.Visible = flag2 == true
			label17.Text = text
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

			label17.TextColor3 = textColor
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

			label16.TextColor3 = textColor2
		end
		return textButton, setChip, CardSelect.attach(textButton, stroke, Style.INK), v44
	end

	local function span(p, frac: number, frac2: number) -- 2 equivalent calls inferred from this helper
		p.Visible = frac + 0.001 < frac2
		p.Position = UDim2.fromScale(frac, 0)
		p.Size = UDim2.fromScale(math.max(0, frac2 - frac), 1)
	end

	local function refreshBars()
		local v44 = v26
		local v45 = v44 and statsOf(v44, levelFn(v44)) -- inferred equivalent call
		frame10.Visible = v45 ~= nil
		label9.Visible = v44 ~= nil and v45 == nil
		label10.Visible = v45 ~= nil

		if not v44 then
			return
		end

		local item = ShopData.item(v44)

		if v45 then
			local slot = item.slot
			local v47

			if ShopData.PICKS[slot] then
				v47 = ShopData.pick(instance, slot)
			end

			local v48

			if v47 and v47 ~= v44 then
				v48 = statsOf(v47, levelFn(v47)) -- inferred equivalent call
			end

			local text

			if v48 and v47 then
				text = "VS EQUIPPED: " .. string.upper(nameOf(v47)) -- inferred equivalent call
			else
				text = v47 == v44 and "EQUIPPED" or ""
			end

			label10.Text = text

			for k, v50 in v22 do
				local v51 = v45[k]
				local v52 = v48 and v48[k]
				v50.label.Text = v51.label
				local frac = v51.frac

				if v52 then
					local base = v50.base
					local v53 = math.min(frac, v52.frac)
					base.Visible = v53 > 0.001
					base.Position = UDim2.fromScale(0, 0)
					base.Size = UDim2.fromScale(math.max(0, v53 - 0), 1)

					span(v50.gain, v52.frac, frac) -- inferred equivalent call
					span(v50.loss, frac, v52.frac) -- inferred equivalent call
					v50.tick.Visible = true
					v50.tick.Position = UDim2.fromScale(v52.frac, 0.5)
				else
					local base = v50.base
					base.Visible = frac > 0.001
					base.Position = UDim2.fromScale(0, 0)
					base.Size = UDim2.fromScale(math.max(0, frac - 0), 1)

					v50.gain.Visible = false
					v50.loss.Visible = false
					v50.tick.Visible = false
				end

				local text2 = Style.paint(v51.text, Style.WHITE)

				if v52 and math.abs(v51.num - v52.num) > 0.001 then
					local v54 = v51.num - v52.num
					local v55

					if v51.lower then
						v55 = v54 < 0
					else
						v55 = v54 > 0
					end

					local v56

					if v51.lower then
						v56 = string.format("%+.2f", v54)
					else
						v56 = string.format("%+d", (math.round(v54)))
					end

					local paint = Style.paint
					local v58 = if v55 then Style.HAZARD else color
					text2 ..= "  " .. paint(v56, v58)
				end

				v50.value.Text = text2
			end
		else
			local v47 = {}

			if item.kills then
				table.insert(v47, string.format("EARNED AFTER %d KILLS IN A ROW IN ONE LIFE", item.kills))
			end

			label9.Text = table.concat(v47, "\n")
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

		local v44 = { key = "locked", enabled = false, text = Skins.lockText(p, ""), instant = 0 }
		local instant

		if Skins.PAID_ON then
			instant = ArmoryStore.outfit(instance, p.id, fn4)
		end

		v44.instant = instant
		return v44
	end

	local v44 = ""
	local function refreshFooter()
		local mode = Glyph.mode()
		local v45 = v29
		local text

		if v45 and v45.enabled then
			text = v45.hold and "HOLD TO BUY" or v45.text
		end

		local v47 = {}

		if mode == "gamepad" and text then
			table.insert(v47, {
				caps = {
					{ pad = Enum.KeyCode.ButtonY }
				},
				text = text
			})
		end

		local texts = { mode }

		for _, v48 in v47 do
			table.insert(texts, v48.text)
		end

		local joined = table.concat(texts, "|")

		if joined == v44 then
			return
		end

		v44 = joined
		fill4.Visible = #v47 > 0

		for _, guiObject in frame3:GetChildren() do
			if guiObject:IsA("GuiObject") then
				guiObject:Destroy()
			end
		end

		for k, v48 in v47 do
			local frame12 = Style.frame(frame3, "Prompt", UDim2.fromOffset(0, 26))
			frame12.AutomaticSize = Enum.AutomaticSize.X
			frame12.LayoutOrder = k
			row(frame12, "Row", 4) -- inferred equivalent call

			for k2, cap2 in v48.caps do
				local cap = Glyph.cap(frame12, cap2.key, cap2.pad, 18)
				cap.LayoutOrder = k2
			end

			local label15 = Style.label(frame12, "Text", v48.text, 13, Style.FONT, 0)
			label15.LayoutOrder = #v48.caps + 1
			label15.TextColor3 = Style.MUTED
		end
	end
	Glyph.onChange(refreshFooter)

	local function setActionState(data)
		v29 = data
		visible = data ~= nil and data.instant ~= nil
		button3.Visible = visible

		if data and data.instant then
			run = data.instant.run
			v20(data.instant.label or "INSTANT UNLOCK", Style.thousands(data.instant.price), Style.INK)
		end

		refreshFooter()
		button2.Visible = data ~= nil
		local sync = hook.sync
		local v46

		if data and v24 == "kit" then
			v46 = v26
		end

		sync(v46)

		if not data then
			return
		end

		local backgroundColor

		if data.enabled then
			backgroundColor = Style.HAZARD
		else
			backgroundColor = Style.STEEL
		end

		button2.BackgroundColor3 = backgroundColor
		button2.AutoButtonColor = data.enabled and not data.hold
		tape.Visible = data.enabled
		local text = data.text
		local amount = data.amount
		local v48

		if data.enabled then
			v48 = Style.INK
		else
			v48 = if data.done then Style.HAZARD else color2
		end

		v18(text, amount, v48, data.suffix)
	end

	local v45 = nil
	local v46 = nil
	local function holdBegin()
		local v47 = v29

		if not v47 or not v47.enabled or not v47.hold or flag then
			return
		end

		local now = os.clock()
		local key = v47.key
		v45 = now
		v46 = key
		Style.animate(fill5, function(_, p: number): boolean
			if v45 ~= now then
				fill5.Size = UDim2.fromScale(0, 1)
				return false
			end

			local v48 = (p - now) / 0.6
			fill5.Size = UDim2.fromScale(math.min(v48, 1), 1)

			if v48 < 1 then
				return true
			end

			v45 = nil
			fill5.Size = UDim2.fromScale(0, 1)
			local v49 = v29

			if v49 and v49.key == v46 and v49.run then
				task.spawn(v49.run)
			end

			return false
		end)
	end
	local function holdEnd() -- 2 equivalent calls inferred from this helper
		v45 = nil
	end
	button2.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			holdBegin()
		end
	end)
	UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.ButtonA and region.Visible and GuiService.SelectedObject == button2 then
			holdBegin()
		end
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
		if gameProcessed or not region.Visible then
			return
		end

		if input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.ButtonY then
			local v47 = v29

			if not v47 or not v47.enabled or flag then
				return
			end

			if v47.hold then
				holdBegin()
			elseif v47.run then
				v47.run()
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
	button2.MouseLeave:Connect(holdEnd)
	button2.Activated:Connect(function()
		local v47 = v29

		if v47 and v47.enabled and not v47.hold and v47.run then
			v47.run()
		end
	end)

	local v47 = 0
	local v48 = nil
	local v49 = Vector3.new(0, 0, 0)
	local unit = (Vector3.new(1, 0.2, 0.3)).Unit
	local v50 = 1
	local v51 = nil
	local v52 = 0
	local function placeTurn() -- 3 equivalent calls inferred from this helper
		if v48 then
			local vectorToWorldSpace = CFrame.Angles(0, v47, 0):VectorToWorldSpace(unit)
			v48.CFrame = CFrame.lookAt(v49 + vectorToWorldSpace * v50, v49)
		end
	end
	local function spin() -- 2 equivalent calls inferred from this helper
		Style.animate(box5, function(p: number): boolean
			if not region.Visible or not v48 or v24 ~= "kit" then
				return false
			end

			if not v51 then
				v47 += p * 0.3
				placeTurn() -- inferred equivalent call
			end

			return true
		end)
	end

	local v53 = nil
	local function endDrag() -- 2 equivalent calls inferred from this helper
		v51 = nil

		if v53 then
			for _, connection in v53 do
				connection:Disconnect()
			end

			v53 = nil
		end
	end
	box5.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			v51 = input
			v52 = input.Position.X

			if not v53 then
				v53 = {
					UserInputService.InputChanged:Connect(function(input2)
						if v51 and (input2.UserInputType == Enum.UserInputType.MouseMovement or input2 == v51) then
							v47 -= (input2.Position.X - v52) * 0.012
							v52 = input2.Position.X
							placeTurn() -- inferred equivalent call
						end
					end),
					UserInputService.InputEnded:Connect(function(input2)
						if v51 and (input2 == v51 or input2.UserInputType == Enum.UserInputType.MouseButton1) then
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
		for _, uiScale3 in frame8:GetChildren() do
			if not uiScale3:IsA("UIScale") then
				uiScale3:Destroy()
			end
		end

		v48 = nil
		local tool = hook.dressed(p)

		if not tool then
			local v54 = v12[p]
			local v55 = if v54 and v54.tool then v54.tool else p
			tool = ToolTemplates:FindFirstChild(v55)

			if not (tool and tool:IsA("Tool")) then
				tool = nil
			end
		end

		if tool and not StreakIcon.has(p) and ShopData.item(p).slot ~= "throwable" then
			local v54 = ToolIcon.make(tool, frame8, 12)
			v54.Size = UDim2.fromScale(1, 1)
			local model = v54:FindFirstChildOfClass("Model")

			if WeaponSkins.wearsGold(model) then
				WeaponSkins.goldLight(v54)
			end

			local currentCamera = v54.CurrentCamera
			v49 = model:GetBoundingBox().Position

			local boundingBox, v55 = model:GetBoundingBox()
			local v56 = math.tan(math.rad(currentCamera.FieldOfView) / 2)
			local v57 = v56 * box5.Size.X.Offset / box5.Size.Y.Offset
			local maxValue = 0

			for i = 0, 23 do
				local vectorToWorldSpace = CFrame.Angles(0, i / 24 * 2 * 3.141592653589793, 0):VectorToWorldSpace(unit)
				local unit2 = (-vectorToWorldSpace):Cross(Vector3.new(0, 1, 0)).Unit
				local cross = unit2:Cross(-vectorToWorldSpace)

				for _, v58 in { -0.5, 0.5 } do
					for _, v59 in { -0.5, 0.5 } do
						for _, v60 in { -0.5, 0.5 } do
							local vector = boundingBox:PointToWorldSpace(v55 * Vector3.new(v58, v59, v60)) - v49
							maxValue = math.max(
								maxValue,
								vector:Dot(vectorToWorldSpace) + math.max(
									math.abs((vector:Dot(unit2))) / v57,
									math.abs((vector:Dot(cross))) / v56
								)
							)
						end
					end
				end
			end

			v50 = maxValue * 1.1
			v47 = 0
			v48 = currentCamera
			placeTurn() -- inferred equivalent call

			if not Style.isTouch() then
				spin() -- inferred equivalent call
			end
		else
			local frame12 = Style.frame(
				frame8,
				"Flat",
				UDim2.new(1, -40, 1, -24),
				UDim2.fromScale(0.5, 0.5),
				Vector2.new(0.5, 0.5)
			)

			if tool and not StreakIcon.has(p) then
				ToolIcon.voxel(tool, frame12, Style.WHITE, 1)
			else
				picture(p, frame12, Style.WHITE)
			end
		end

		local now = os.clock()
		Style.animate(uiScale2, function(_, p2: number): boolean
			local v54 = math.min((p2 - now) / 0.1, 1)
			uiScale2.Scale = 0.96 + 0.04 * Style.easeOut(v54)
			return v54 < 1
		end)
	end

	local function tag(p: string, flag2: boolean, layoutOrder: number)
		local box7 = Style.box
		local v55 = if flag2 then Style.HAZARD else Style.INK
		local parent = box7(frame9, "Tag", v55, UDim2.fromOffset(0, 18), 2, 1)
		parent.AutomaticSize = Enum.AutomaticSize.X
		parent.LayoutOrder = layoutOrder
		padding(parent, 5, 5) -- inferred equivalent call
		local label15 = Style.label(parent, "Text", p, 11, Style.FONT, 0)
		label15.Size = UDim2.fromOffset(0, 18)
		local textColor = if flag2 then Style.INK else Style.MUTED
		label15.TextColor3 = textColor
	end

	local function refreshDetail()
		if v24 == "outfits" then
			local v54 = v27

			if v54 then
				local unlocked = Skins.unlocked(instance, v54.id)
				local level = Skins.levelOf(instance)

				if unlocked then
					local text

					if v54.level <= 1 then
						text = Style.paint("STANDARD ISSUE", Style.MUTED)
					else
						text = Style.paint(Skins.lockText(v54, "LEVEL %d OUTFIT"), Style.MUTED)
					end

					label14.Text = text
				else
					local text

					if v54.paid then
						text = Style.paint(Skins.lockText(v54, ""), color)
					else
						text = Style.paint(Skins.lockText(v54, "REQUIRES LEVEL %d"), color) .. Style.paint(
							string.format("   YOU ARE LEVEL %d", level),
							Style.DIM
						)
					end

					label14.Text = text
				end

				for _, v55 in v23 do
					local v56 = v55.team == v28
					local button4 = v55.button
					local backgroundColor

					if v56 then
						backgroundColor = Style.teamColor(v55.team)
					else
						backgroundColor = Style.PANEL
					end

					button4.BackgroundColor3 = backgroundColor
					local label15 = v55.label
					local textColor

					if v56 then
						textColor = Style.WHITE
					else
						textColor = Style.MUTED
					end

					label15.TextColor3 = textColor
				end

				setActionState(outfitAction(v54))

				label14.Visible = not visible
				label13.Size = UDim2.fromOffset(
					310,
					not visible and 52 or button3.Position.Y.Offset - 4 - label13.Position.Y.Offset
				)
			else
				v29 = nil
				visible = false
				button3.Visible = visible

				refreshFooter()
				button2.Visible = false
				hook.sync(nil)
			end
		else
			local v54 = v26

			if v54 then
				refreshBars()
				plate.set(v54)
				setActionState(kitAction(v54))
			else
				v29 = nil
				visible = false
				button3.Visible = visible

				refreshFooter()
				button2.Visible = false
				hook.sync(nil)
			end
		end
	end

	local v54 = {}

	for _, v55 in {
		{ label6, 126 },
		{ frame9, 138 },
		{ label7, 158 },
		{ label8, 190 },
		{ frame10, 230 },
		{ label9, 230 },
		{ label10, 318 }
	} do
		table.insert(v54, { item = v55[1], y = v55[2] })
	end

	local v55 = nil
	fn2 = function(flag2: boolean)
		if flag2 == v55 then
			return
		end

		v55 = flag2
		local v56 = flag2 and 40 or 96
		box5.Size = UDim2.fromOffset(310, v56 + 120)

		for _, v57 in v54 do
			v57.item.Position = UDim2.fromOffset(v57.item.Position.X.Offset, v57.y + v56)
		end

		local v57 = v26

		if v57 and v24 == "kit" then
			stagePicture(v57)
		end
	end
	fn2(false)

	local function selectItem(p: string?)
		v26 = p

		for _, v56 in v31 do
			v56.setSelected(v56.key == p)
		end

		frame7.Visible = p ~= nil

		if p then
			local item = ShopData.item(p)

			for _, guiObject in frame9:GetChildren() do
				if guiObject:IsA("GuiObject") then
					guiObject:Destroy()
				end
			end

			tag(v5[p] or v7[v25].label, true, 1)

			if v6[p] then
				tag(v6[p], false, 2)
			end

			if item.kills then
				tag(string.format("%d KILLS", item.kills), false, 3)
			end

			local v56 = v12[p]
			label7.Text = string.upper(nameOf(p)) -- inferred equivalent call
			label8.Text = not v56 and "" or v56.description
			stagePicture(p)
			refreshDetail()
		else
			v29 = nil
			visible = false
			button3.Visible = visible

			refreshFooter()
			button2.Visible = false
			hook.sync(nil)
		end
	end
	fn = function()
		if v26 and v24 == "kit" then
			selectItem(v26)
		end
	end

	local function stageOutfit()
		local v56 = v27
		stage.set(v56)
		local body = SkinPreview.body(instance)
		label11.Visible = body == nil

		if v56 and body then
			view.show(SkinPreview.dress(body, v56, v28, instance.UserId))
		else
			view.show(nil)
		end
	end

	local function selectSkin(p)
		v27 = p

		for _, v56 in v40 do
			v56.setSelected(p ~= nil and v56.key == p.id)
		end

		if p then
			label12.Text = string.upper(p.name)
			label13.Text = ""
			view.resetTurn()
			stageOutfit()
			refreshDetail()
		else
			v29 = nil
			visible = false
			button3.Visible = visible

			refreshFooter()
			button2.Visible = false
			hook.sync(nil)
		end
	end

	local function dressOutfitCards()
		local body = SkinPreview.body(instance)

		if body == v41 then
			return
		end

		v41 = body

		for _, v56 in v40 do
			local v57 = Skins.get(v56.key)
			local show = v56.view.show
			local v58

			if body then
				v58 = SkinPreview.dress(body, v57, v28, instance.UserId)
			end

			show(v58)
		end
	end

	instance:GetPropertyChangedSignal("Team"):Connect(function()
		local name = instance.Team and instance.Team.Name

		if (name == "Reds" or name == "Blues") and name ~= v28 then
			v28 = name
			v41 = nil
			dressOutfitCards()
			stageOutfit()
		end
	end)

	local function buildOutfitCards()
		if #v40 > 0 then
			return
		end

		for k, v56 in Skins.LIST do
			local card, v57, setSelected, view2 = makeCard(
				parent3,
				k,
				v56.id,
				v56.level <= 1 and "STANDARD" or Skins.lockText(v56, "LEVEL %d"),
				v56.name,
				function(p)
					return SkinPreview.view(p, "bust")
				end,
				v56
			)

			local function refresh()
				if Skins.pick(instance) == v56.id then
					v57("equipped", "WEARING")
				elseif Skins.unlocked(instance, v56.id) then
					v57("owned", "UNLOCKED")
				else
					v57("short", Skins.lockText(v56, "REQUIRES LVL %d"))
				end
			end
			local v60 = {
				button = card,
				key = v56.id,
				refresh = refresh,
				setSelected = setSelected,
				view = view2
			}
			card.Activated:Connect(function()
				selectSkin(v56)
			end)
			refresh()
			table.insert(v40, v60)
		end
	end

	local function slide(p) -- 2 equivalent calls inferred from this helper
		local now = os.clock()
		Style.animate(p, function(_, p2: number): boolean
			local v56 = math.min((p2 - now) / 0.12, 1)
			p.Position = UDim2.fromOffset(12 * (1 - Style.easeOut(v56)), p.Position.Y.Offset)
			return v56 < 1
		end)
	end

	local function classesOf(items)
		local v56 = {}
		local result = {}

		for _, item in items do
			local id = v5[item.id]

			if not id then
				continue
			end

			if not v56[id] then
				v56[id] = {
					id = id,
					count = 0,
					first = #result + 1
				}
				table.insert(result, v56[id])
			end

			v56[id].count += 1
		end

		table.sort(result, function(a, b): boolean
			local index = table.find(v9, a.id) or 99
			local index2 = table.find(v9, b.id) or 99

			if index == index2 then
				return a.first < b.first
			end

			return index < index2
		end)

		return result
	end

	local function inClass(id: string): boolean -- 1 equivalent call inferred from this helper
		return v32 == "ALL" or v5[id] == v32
	end

	local function refreshClassTabs()
		local v56 = v11[v7[v25].slot]

		for _, v57 in v39 do
			local visible3 = v57.id == v32
			local button4 = v57.button
			local backgroundColor

			if visible3 then
				backgroundColor = color3
			else
				backgroundColor = Style.PANEL
			end

			button4.BackgroundColor3 = backgroundColor
			local label15 = v57.label
			local textColor

			if visible3 then
				textColor = Style.WHITE
			else
				textColor = Style.MUTED
			end

			label15.TextColor3 = textColor
			local count2 = v57.count
			local textColor2

			if visible3 then
				textColor2 = Style.HAZARD
			else
				textColor2 = Style.DIM
			end

			count2.TextColor3 = textColor2
			v57.under.Visible = visible3
			local visible4 = false

			if v57.id ~= "ALL" then
				for _, v64 in v56 do
					if
						v5[v64.id] == v57.id
						and not ShopData.owns(instance, v64.id)
						and ShopData.unlocked(instance, v64.id)
						and ShopData.item(v64.id).price <= scrap() -- inferred equivalent call
					then
						visible4 = true
						break
					end
				end
			end

			v57.dot.Visible = visible4
		end
	end

	local fn5

	local function squeezeTabs()
		local v56 = frame5.AbsoluteSize.X / frame5.Size.X.Offset

		if v56 <= 0 or #v39 == 0 then
			return
		end

		local v57 = classes.AbsoluteSize.X / v56 - 6 - (#v39 - 1) * 4
		local count2 = 0

		while count2 < 6 do
			local total = 0

			for _, v58 in v39 do
				total += math.ceil((v58.label.AbsoluteSize.X + v58.count.AbsoluteSize.X) / v56 + 5 + 20 - count2 * 2)
			end

			if total <= v57 then
				break
			end

			count2 += 1
		end

		for _, v58 in v39 do
			local pad = v58.pad
			local pad2 = v58.pad
			local udim = UDim.new(0, 9 - count2)
			local udim2 = UDim.new(0, 11 - count2)
			pad.PaddingLeft = udim
			pad2.PaddingRight = udim2
		end
	end
	classes:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		squeezeTabs()
	end)

	local function makeClassTab(layoutOrder: number, id: string, id2: string, count2: number)
		local textButton = Instance.new("TextButton")
		textButton.Name = id
		textButton.Text = ""
		textButton.AutoButtonColor = true
		textButton.BorderSizePixel = 0
		textButton.BackgroundColor3 = Style.PANEL
		textButton.Size = UDim2.fromOffset(0, 26)
		textButton.LayoutOrder = layoutOrder
		textButton.Selectable = true
		textButton.Parent = classes
		Style.corner(textButton, 3)
		Style.stroke(textButton, 1.5, 0, Style.INK, true)
		local frame12 = Style.frame(textButton, "Content", UDim2.fromOffset(0, 26))
		frame12.AutomaticSize = Enum.AutomaticSize.X
		padding(frame12, 9, 11) -- inferred equivalent call
		row(frame12, "Row", 5) -- inferred equivalent call
		local label15 = Style.label(frame12, "Text", id2, 13, Style.FONT, 0)
		label15.LayoutOrder = 1
		local label16 = Style.label(frame12, "Count", tostring(count2), 11, Style.FONT, 0)
		label16.LayoutOrder = 2

		local function fit2() -- 1 equivalent call inferred from this helper
			local v56 = frame5.AbsoluteSize.X / frame5.Size.X.Offset

			if v56 > 0 then
				textButton.Size = UDim2.fromOffset(math.ceil(frame12.AbsoluteSize.X / v56), 26)
			end
		end
		frame12:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit2)
		fit2() -- inferred equivalent call
		label15:GetPropertyChangedSignal("AbsoluteSize"):Connect(squeezeTabs)
		local tape2 = Style.tape(textButton, "Underline", UDim2.new(1, 0, 0, 3), 100, 8)
		tape2.AnchorPoint = Vector2.new(0, 1)
		tape2.Position = UDim2.fromScale(0, 1)
		local fill6 = Style.fill(
			textButton,
			"Affordable",
			Style.HAZARD,
			UDim2.fromOffset(6, 6),
			UDim2.new(1, -3, 0, 3),
			Vector2.new(1, 0)
		)
		Style.corner(fill6, 3)
		fill6.Visible = false
		textButton.Activated:Connect(function()
			fn5(id)
		end)
		table.insert(v39, {
			id = id,
			button = textButton,
			label = label15,
			count = label16,
			under = tape2,
			dot = fill6,
			pad = frame12:FindFirstChildOfClass("UIPadding")
		})
		squeezeTabs()
	end

	local function buildClassStrip(items, _: number)
		for _, v56 in v39 do
			v56.button:Destroy()
		end

		table.clear(v39)

		for k, item in items do
			makeClassTab(k, item.id, item.id, item.count)
		end

		refreshClassTabs()
	end

	local function buildKitCards()
		listHiddenGuns()

		for _, v56 in v31 do
			v56.button:Destroy()
		end

		table.clear(v31)
		local v56 = v7[v25]
		local v57 = v11[v56.slot]
		local v58 = classesOf(v57)
		local v59 = visible2
		visible2 = v8[v56.slot] == true and #v58 >= 2 and #v57 >= 4

		if visible2 then
			local v61 = false

			for _, v62 in v58 do
				v61 = v61 or v62.id == v32
			end

			if v36 ~= v25 or not v61 then
				local v62 = v5[carried(v56.slot)] -- inferred equivalent call
				v32 = v58[1].id

				for _, v63 in v58 do
					if v63.id == v62 then
						v32 = v63.id
					end
				end
			end
		else
			v32 = "ALL"
		end

		v36 = v25

		if visible2 then
			local v61 = {}

			for _, v62 in v58 do
				table.insert(v61, v62.id .. ":" .. v62.count)
			end

			local joined = table.concat(v61, ",")

			if joined == v38 then
				refreshClassTabs()
			else
				v38 = joined
				buildClassStrip(v58, #v57)
			end
		end

		classes.Visible = visible2
		local v61 = visible2 and 56 or 22
		parent2.Position = UDim2.fromOffset(0, v61)
		parent2.Size = UDim2.new(1, 0, 1, -v61)

		if v59 ~= visible2 then
			refreshFooter()
		end

		local v62 = {}

		for _, v63 in v57 do
			if inClass(v63.id) then -- inferred equivalent call
				table.insert(v62, v63)
			end
		end

		local v63 = v32 == "ALL" and "" or "  /  " .. v32
		label4.Text = v56.label .. Style.paint(string.format("%s  /  %d ITEMS", v63, #v62), Style.DIM)
		label5.Text = "NOTHING HERE YET"
		label5.Visible = #v62 == 0
		parent2.CanvasPosition = Vector2.zero

		for k, v64 in v62 do
			local item = ShopData.item(v64.id)
			local v65 = v5[v64.id]

			if not v65 then
				if item.kills then
					v65 = string.format("%d KILLS", item.kills)
				else
					v65 = v56.label
				end
			end

			local card, v66, setSelected = makeCard(parent2, k, v64.id, v65, v64.name, function(p): nil
				picture(v64.id, p, Style.WHITE)
				return nil
			end)

			local chip = MasteryBadge.chip(card, instance)
			local function refresh()
				chip.set(v64.id)

				if ShopData.owns(instance, v64.id) then
					if carried(v56.slot) == v64.id then -- inferred equivalent call
						v66("equipped", "EQUIPPED")
					else
						v66("owned", "OWNED")
					end
				elseif not ShopData.unlocked(instance, v64.id) then
					v66("short", string.format("REQUIRES LVL %d", ShopData.unlockLevel(v64.id)))
				elseif item.price - scrap() <= 0 then -- inferred equivalent call
					v66("price", Style.thousands(item.price), true)
				else
					v66("short", Style.thousands(item.price), true)
				end
			end
			local v68 = {
				button = card,
				key = v64.id,
				refresh = refresh,
				setSelected = setSelected,
				view = nil
			}
			card.Activated:Connect(function()
				selectItem(v64.id)
			end)
			refresh()
			table.insert(v31, v68)
		end

		slide(parent2) -- inferred equivalent call
	end

	local v56 = nil
	local frame12 = Style.frame(box, "Store", UDim2.fromOffset(976, 498), UDim2.fromOffset(12, 70))
	frame12.Visible = false
	local v57 = nil
	local frame13 = Style.frame(box, "Quests", frame12.Size, frame12.Position)
	frame13.Visible = false
	local function nextTab(p: number)
		local v58 = { "kit" }

		if not v2 then
			table.insert(v58, "quests")
		end

		if not v then
			table.insert(v58, "outfits")
		end

		return v58[(table.find(v58, v24) - 1 + p) % #v58 + 1]
	end

	local function setMode(p: string)
		v24 = p

		for _, v58 in v15 do
			local visible3 = v58.id == p
			local button4 = v58.button
			local backgroundColor

			if visible3 then
				backgroundColor = color3
			else
				backgroundColor = Style.PANEL
			end

			button4.BackgroundColor3 = backgroundColor
			local label15 = v58.label
			local textColor

			if visible3 then
				textColor = Style.WHITE
			else
				textColor = Style.MUTED
			end

			label15.TextColor3 = textColor
			v58.under.Visible = visible3
		end

		v56.show(p == "store")
		v57.show(p == "quests")
		local v58 = p == "store" or p == "quests"
		frame4.Visible = not v58
		frame5.Visible = not v58
		box4.Visible = not v58

		if v58 then
			v29 = nil
			visible = false
			button3.Visible = visible

			refreshFooter()
			button2.Visible = false
			hook.sync(nil)
		else
			frame4.Visible = p == "kit"
			frame5.Position = UDim2.fromOffset(p == "kit" and 236 or 12, 70)
			frame5.Size = UDim2.fromOffset(p == "kit" and 410 or 634, 498)
			parent2.Visible = p == "kit"
			parent3.Visible = p == "outfits"
			classes.Visible = p == "kit" and visible2
			frame7.Visible = p == "kit" and v26 ~= nil
			frame11.Visible = p == "outfits"

			if p == "outfits" then
				buildOutfitCards()
				dressOutfitCards()
				label4.Text = "OUTFITS" .. Style.paint(string.format("  /  %d", #Skins.LIST), Style.DIM)
				label5.Text = "NO OUTFITS YET"
				label5.Visible = #Skins.LIST == 0

				for _, v61 in v40 do
					v61.refresh()
				end

				slide(parent3) -- inferred equivalent call
				local v61 = Skins.find(Skins.pick(instance))
				selectSkin(v27 or v61 or Skins.LIST[1])
			else
				buildKitCards()
				local v61 = v7[v25]
				local v62 = v26

				if not v62 or not ShopData.ITEMS[v62] or ShopData.item(v62).slot ~= v61.slot or not v12[v62] then
					v62 = carried(v61.slot) -- inferred equivalent call

					if not v12[v62] then
						v62 = v11[v61.slot][1] and v11[v61.slot][1].id
					end
				end

				if v62 and v32 ~= "ALL" and v5[v62] ~= v32 then
					v62 = v31[1] and v31[1].key
				end

				selectItem(v62)

				if v48 and not Style.isTouch() then
					spin() -- inferred equivalent call
				end
			end

			for _, v61 in v30 do
				v61.refresh()
			end
		end
	end

	local function openTab(id: string)
		local v58 = { id = id }

		if v58.id == "quests" and v2 then
			local Quests = require(script.Parent:WaitForChild("Quests"))
			assert(Quests.open, "[Armory] the QUESTS screen is not mounted (SkirmishHud mounts it)")
			Quests.open(true)
		elseif v58.id == "outfits" and v then
			local Outfits = require(script.Parent:WaitForChild("Outfits"))
			assert(Outfits.open, "[Armory] the OUTFITS screen is not mounted (SkirmishHud mounts it)")
			Outfits.open(true)
		elseif v58.id == "vehicles" then
			local Garage = require(script.Parent:WaitForChild("Garage"))
			assert(Garage.open, "[Armory] the VEHICLES screen is not mounted (SkirmishHud mounts it)")
			Garage.open(true)
		elseif v58.id == "store" and ArmoryStore.SCREEN_ON then
			local Store = require(script.Parent:WaitForChild("Store"))
			assert(Store.open, "[Armory] the STORE screen is not mounted (SkirmishHud mounts it)")
			Store.open(true)
		elseif v24 ~= v58.id then
			setMode(v58.id)
		end
	end

	for _, v58 in v15 do
		v58.button.Activated:Connect(function()
			openTab(v58.id)
		end)
	end

	local function stepTabs(p: number) -- 1 equivalent call inferred from this helper
		local v58 = 1

		for k, v59 in v15 do
			if v59.id == v24 then
				v58 = k
			end
		end

		openTab(v15[(v58 - 1 + p) % #v15 + 1].id)
	end

	fn5 = function(p: string)
		if p == v32 or v24 ~= "kit" then
			return
		end

		local selectedObject = GuiService.SelectedObject
		local v58

		if selectedObject == nil then
			v58 = false
		else
			v58 = selectedObject:IsDescendantOf(classes)
		end

		v32 = p
		buildKitCards()
		local function find(p2: string?) -- 1 equivalent call inferred from this helper
			for _, v59 in v31 do
				if v59.key == p2 then
					return v59
				end
			end

			return nil
		end

		local v59 = find(v26) -- inferred equivalent call

		if not v59 then
			local v60 = carried(v7[v25].slot) -- inferred equivalent call
			local flag2 = true

			for _, v61 in v31 do
				if v61.key == v60 then
					v59 = v61
					flag2 = false
					break
				end
			end

			if flag2 then
				v59 = nil
			end

			if not v59 then
				v59 = v31[1]
			end
		end

		local key = v59 and v59.key
		local button4 = v59 and v59.button

		if key == v26 then
			for _, v60 in v31 do
				v60.setSelected(v60.key == key)
			end
		else
			selectItem(key)
		end

		if Glyph.mode() == "gamepad" then
			local v60 = nil

			if v58 then
				for _, v61 in v39 do
					if v61.id == p then
						v60 = v61
					end
				end
			end

			if v60 then
				GuiService.SelectedObject = v60.button
			elseif button4 then
				GuiService.SelectedObject = button4
			end
		end
	end

	local function stepClass(p: number)
		if v24 ~= "kit" or not visible2 then
			return
		end

		local v58 = 1

		for k, v59 in v39 do
			if v59.id == v32 then
				v58 = k
			end
		end

		fn5(v39[(v58 - 1 + p) % #v39 + 1].id)
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
		end
	end)

	for k, v58 in v7 do
		local textButton = Instance.new("TextButton")
		textButton.Name = v58.slot
		textButton.Text = ""
		textButton.AutoButtonColor = true
		textButton.BorderSizePixel = 0
		textButton.BackgroundColor3 = Style.STEEL
		textButton.BackgroundTransparency = 0.4
		textButton.Size = UDim2.fromOffset(212, 72)
		textButton.Position = UDim2.fromOffset(0, 22 + (k - 1) * 78)
		textButton.Parent = frame4
		Style.corner(textButton, 3)
		Style.stroke(textButton, 1.5, 0, Style.INK, true)
		local fill6 = Style.fill(textButton, "Focus", Style.HAZARD, UDim2.new(0, 6, 1, 0))
		local label15 = Style.label(textButton, "Slot", v58.label, 11, Style.FONT, 0)
		label15.Position = UDim2.fromOffset(14, 4)
		label15.TextColor3 = Style.MUTED
		local frame14 = Style.frame(textButton, "Icon", UDim2.fromOffset(64, 40), UDim2.fromOffset(14, 24))
		local label16 = Style.label(textButton, "Name", "", 17, Style.FONT, 0)
		label16.AutomaticSize = Enum.AutomaticSize.None
		label16.Size = UDim2.fromOffset(116, 22)
		label16.Position = UDim2.fromOffset(86, 22)
		label16.TextXAlignment = Enum.TextXAlignment.Left
		label16.TextTruncate = Enum.TextTruncate.AtEnd
		local chip = MasteryBadge.chip(textButton, instance)
		local v59 = nil
		local function refresh()
			local v60 = carried(v58.slot) -- inferred equivalent call
			chip.set(v60)

			if v60 ~= v59 then
				v59 = v60

				for _, child in frame14:GetChildren() do
					child:Destroy()
				end

				picture(v60, frame14, Style.WHITE)
				v60 = nameOf(v60) -- inferred equivalent call
				label16.Text = string.upper(v60)
			end

			local visible3

			if v24 == "kit" then
				visible3 = k == v25
			else
				visible3 = false
			end

			fill6.Visible = visible3
			local backgroundColor

			if visible3 then
				backgroundColor = color3
			else
				backgroundColor = Style.STEEL
			end

			textButton.BackgroundColor3 = backgroundColor
			textButton.BackgroundTransparency = visible3 and 0 or 0.4
			local textColor

			if visible3 then
				textColor = Style.WHITE
			else
				textColor = Style.MUTED
			end

			label16.TextColor3 = textColor
		end
		textButton.Activated:Connect(function()
			v25 = k
			v26 = nil
			setMode("kit")
		end)
		table.insert(v30, { refresh = refresh, button = textButton })
	end

	fn4 = function()
		rollScrap(scrap()) -- inferred equivalent call
		refreshLevel()

		for _, v58 in v30 do
			v58.refresh()
		end

		for _, v58 in v31 do
			v58.refresh()
		end

		for _, v58 in v40 do
			v58.refresh()
		end

		if visible2 then
			refreshClassTabs()
		end

		refreshDetail()
	end

	local v58 = {}
	fn3 = function()
		for _, v59 in v58 do
			v59()
		end
	end
	button.Activated:Connect(function()
		for _, v59 in v58 do
			v59()
		end
	end)

	local v59 = {}
	v59.root = region
	function v59.isOpen()
		return region.Visible or hook.isOpen()
	end

	function v59.setOpen(flag2: boolean)
		holdEnd() -- inferred equivalent call

		if flag2 then
			region.Visible = true
			setMode(v24)
			fn4()
			local now = os.clock()
			Style.animate(region, function(_, p: number): boolean
				local v60 = math.min((p - now) / 0.16, 1)
				fit(0.92 + 0.08 * Style.easeOut(v60))
				return v60 < 1
			end)
		else
			hook.close()
			v56.show(false)
			v57.show(false)
			region.Visible = false
			v42 = nil
			view.show(nil)
		end
	end
	function v59.markLife()
		v59.refresh()
	end
	function v59.refresh()
		if region.Visible then
			fn4()
		end
	end
	function v59.firstPad()
		if v24 == "store" then
			return v56.firstPad()
		elseif v24 == "quests" then
			return v57.firstPad()
		end

		local v60 = if v24 == "kit" then v31 else v40
		local v61

		if v24 == "kit" then
			v61 = v26
		else
			v61 = v27 and v27.id
		end

		for _, v62 in v60 do
			if v62.key == v61 then
				return v62.button
			end
		end

		return if v60[1] then v60[1].button else v30[1].button
	end

	function v59.stepTab(p: number)
		stepTabs(p) -- inferred equivalent call
	end
	function v59.showKit()
		setMode("kit")
	end
	function v59.back()
		return v56.back()
	end

	function v59.onClose(callback2)
		table.insert(v58, callback2)
	end

	local function padSides()
		local selectedObject = GuiService.SelectedObject

		if not selectedObject or not region.Visible or v24 ~= "kit" and v24 ~= "outfits" then
			return
		end

		local v60 = if v24 == "kit" then v31 else v40
		local buttons = {}

		for _, button4 in { box4:FindFirstChild("Customize"), button3, button2 } do
			if button4 and button4:IsA("GuiButton") and button4.Visible then
				table.insert(buttons, button4)
			end
		end

		table.sort(buttons, function(a, b): boolean
			return a.AbsolutePosition.Y < b.AbsolutePosition.Y
		end)
		local flag2 = false

		for _, v62 in v60 do
			if v62.button == selectedObject then
				flag2 = true
				break
			end
		end

		if flag2 then
			local y = selectedObject.AbsolutePosition.Y
			local x = selectedObject.AbsolutePosition.X
			local flag3 = true

			for _, v63 in v60 do
				local button4 = v63.button

				if
					button4 ~= selectedObject
					and button4.Visible
					and math.abs(button4.AbsolutePosition.Y - y) < 4
					and x < button4.AbsolutePosition.X
				then
					flag3 = false
					break
				end
			end

			local nextSelectionRight

			if flag3 then
				nextSelectionRight = buttons[1]
			end

			selectedObject.NextSelectionRight = nextSelectionRight
		elseif table.find(buttons, selectedObject) then
			selectedObject.NextSelectionLeft = v59.firstPad()
		end
	end
	GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(padSides)
	v56 = ArmoryStore.new(frame12, instance, { touch = false, reseat = PadMenus.reseat })
	v57 = ArmoryQuests.new(frame13, instance, {
		touch = false,
		reseat = PadMenus.reseat,
		scrapPlate = box3,
		levelPlate = box2,
		holdScrap = function(flag2: boolean)
			v43 = flag2

			if not flag2 then
				rollScrap(scrap()) -- inferred equivalent call
			end
		end
	})

	setMode("kit")
	return v59
end

function ArmoryDesk.mount(data)
	local player = data.player
	local shop = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Remotes"):WaitForChild("Shop", 30)
	assert(shop and shop:IsA("RemoteFunction"), "GameUI: remote Game.Remotes.Shop (RemoteFunction) is missing")
	local function request(p: string, p2: string, p3: string?)
		local success, result, v15 = pcall(shop.InvokeServer, shop, p, p2, p3)

		if not success then
			warn("[Armory] request failed: " .. tostring(result))
			return false, "No answer from the armory."
		end

		local selected = result == true

		if type(v15) == "string" then
			return selected, v15
		end

		return selected, ""
	end

	local v15 = ArmoryDesk.new(data.layers.menu, player, request)
	local v16 = true
	local function toggle()
		local v17 = not v15.isOpen()

		if v17 then
			v16 = UserInputService.MouseIconEnabled
			UserInputService.MouseIconEnabled = true
		else
			UserInputService.MouseIconEnabled = Viewmodel.cursorAfterMenu(v16)
		end

		v15.setOpen(v17)
		data.setMenu(v17)

		if v17 then
			PadMenus.open("armory", v15.root, function()
				if not v15.back() then
					toggle()
				end
			end, { first = v15.firstPad, tab = v15.stepTab })
		else
			PadMenus.close("armory")
		end
	end
	v15.onClose(toggle)
	ArmoryDesk.toggle = toggle
	function ArmoryDesk.close()
		if v15.isOpen() then
			toggle()
		end
	end
	function ArmoryDesk.openLoadout()
		if v15.isOpen() and not v15.root.Visible then
			toggle()
		end

		if not v15.isOpen() then
			toggle()
		end

		v15.showKit()
	end

	local v17 = false
	player.AttributeChanged:Connect(function(value: string)
		local v18 = value == "Scrap"
			or value == "Level"
			or value == Skins.PACK_ATTR
			or value == "XP"
			or value == "XPNext"
			or value == "RoundXP"
			or value == Skins.ATTR
			or value == ShopData.STREAK_ATTR
			or string.sub(value, 1, 5) == "Owns_"
			or string.sub(value, 1, 3) == "Mx_"

		for _, v19 in ShopData.PICKS do
			v18 = v18 or value == v19.attr
		end

		if v18 and not v17 then
			v17 = true
			task.defer(function()
				v17 = false
				v15.refresh()
			end)
		end
	end)
	data.onDead(function(flag: boolean)
		if flag and v15.isOpen() then
			toggle()
		end
	end)

	player.CharacterAdded:Connect(v15.markLife)

	if player.Character then
		v15.markLife()
	end
end

return ArmoryDesk