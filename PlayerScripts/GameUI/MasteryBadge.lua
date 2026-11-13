local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Style = require(script.Parent:WaitForChild("Style"))
local Game = ReplicatedStorage:WaitForChild("Game")
local ShopData = require(Game:WaitForChild("ShopData"))
local Mastery = require(Game:WaitForChild("Mastery"))

local function raise(folder)
	folder.ZIndex = 3

	for _, guiObject in folder:GetDescendants() do
		if guiObject:IsA("GuiObject") then
			guiObject.ZIndex = 3
		end
	end
end

local function levelled(p, p2: string?) -- 2 equivalent calls inferred from this helper
	return p2 ~= nil and Mastery.isGun(p2) and ShopData.owns(p, p2)
end

local MasteryBadge = {}

function MasteryBadge.chip(p, p2)
	local box = Style.box(p, "WeaponLevel", Style.INK, UDim2.fromOffset(0, 20), 2, 1)
	box.AutomaticSize = Enum.AutomaticSize.X
	box.AnchorPoint = Vector2.new(1, 0)
	box.Position = UDim2.new(1, -6, 0, 4)
	box.Visible = false
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, 6)
	uiPadding.PaddingRight = UDim.new(0, 6)
	uiPadding.Parent = box
	local label = Style.label(box, "Text", "", 13, Style.FONT, 0)
	label.Size = UDim2.fromOffset(0, 20)
	raise(box)
	local v = {}
	v.frame = box
	function v.set(p3: string?)
		if not levelled(p2, p3) then -- inferred equivalent call
			p3 = nil
		end

		box.Visible = p3 ~= nil

		if p3 then
			local level = Mastery.level(p2, p3)
			local v2 = Mastery.MAX_LEVEL <= level
			label.Text = string.format("LV %d", level)
			local textColor = if v2 then Style.INK else Style.WHITE
			label.TextColor3 = textColor
			local backgroundColor

			if v2 then
				backgroundColor = Style.HAZARD
			else
				backgroundColor = Style.INK
			end

			box.BackgroundColor3 = backgroundColor
		end
	end
	return v
end

function MasteryBadge.plate(p, p2)
	local box = Style.box(p, "WeaponLevel", Style.INK, UDim2.fromOffset(168, 34), 3, 1.5)
	box.BackgroundTransparency = 0.15
	box.AnchorPoint = Vector2.new(1, 1)
	box.Position = UDim2.new(1, -6, 1, -6)
	box.Visible = false
	local label = Style.label(box, "Level", "", 13, Style.FONT, 0)
	label.Position = UDim2.fromOffset(8, 2)
	local label2 = Style.label(box, "Xp", "", 12, Style.FONT, 0)
	label2.AnchorPoint = Vector2.new(1, 0)
	label2.Position = UDim2.new(1, -8, 0, 3)
	label2.TextColor3 = Style.MUTED
	local fill = Style.fill(box, "Track", Style.STEEL, UDim2.new(1, -16, 0, 6), UDim2.fromOffset(8, 23))
	local fill2 = Style.fill(fill, "Fill", Style.HAZARD, UDim2.fromScale(0, 1))
	raise(box)
	local v = {}
	v.frame = box
	function v.set(p3: string?)
		if not levelled(p2, p3) then -- inferred equivalent call
			p3 = nil
		end

		box.Visible = p3 ~= nil

		if p3 then
			local level, v2, v3 = Mastery.levelOf(Mastery.xp(p2, p3))
			label.Text = string.format("WEAPON LV %d", level)
			label2.Text = not (v3 > 0) and "MAX" or string.format("%d/%d", v2, v3)
			fill2.Size = UDim2.fromScale(not (v3 > 0) and 1 or math.clamp(v2 / v3, 0, 1), 1)
		end
	end
	return v
end

return MasteryBadge