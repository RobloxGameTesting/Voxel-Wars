local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Style = require(script.Parent:WaitForChild("Style"))
local QuestIcons = require(script.Parent:WaitForChild("QuestIcons"))
local QuestData = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("QuestData"))

local touch = Style.isTouch()
local v = touch or GuiService:IsTenFootInterface()
local v2 = v and 236 or 210
local v3 = v and 50 or 42
local v4 = v and 18 or 15
local v5 = v and 17 or 13
local v6 = touch and 8 or 20
local color = Color3.fromRGB(26, 27, 31)
return {
	mount = function(p)
		local player = p.player
		local region = Style.region(
			p.layers.hud,
			"QuestTracker",
			Vector2.zero,
			Vector2.new(14, Style.topInset() + v6),
			Vector2.new(v2, QuestData.TRACK_MAX * (v3 + 4))
		)

		local function place() -- 1 equivalent call inferred from this helper
			region.Position = UDim2.fromOffset(14, math.max(Style.topInset(), GuiService.TopbarInset.Max.Y) + v6)
		end
		GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(place)
		place() -- inferred equivalent call
		local v7 = {}

		for i = 1, QuestData.TRACK_MAX do
			local panel = Style.panel(region, "Row" .. i, UDim2.fromOffset(v2, v3))
			panel.Position = UDim2.fromOffset(0, (i - 1) * (v3 + 4))
			local fill = Style.fill(panel, "Stripe", Style.HAZARD, UDim2.new(0, 4, 1, 0))

			local v8 = v2 - 12 - 8
			local label = Style.label(panel, "Name", "", v4, Style.FONT, 1.5)
			label.AutomaticSize = Enum.AutomaticSize.None
			label.Position = UDim2.fromOffset(12, 3)
			label.Size = UDim2.fromOffset(v8, v4 + 4)
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextTruncate = Enum.TextTruncate.AtEnd
			local v9 = math.floor(v8 * 0.52)
			local v10 = v3 - v5 - 6
			local fill2 = Style.fill(
				panel,
				"Track",
				color,
				UDim2.fromOffset(v8 - v9 - 6, 7),
				UDim2.fromOffset(12, v10 + (v5 + 2 - 7) // 2)
			)
			Style.stroke(fill2, 1, 0, Style.INK, true)
			local fill3 = Style.fill(fill2, "Fill", Style.HAZARD, UDim2.fromScale(0, 1))
			local label2 = Style.label(panel, "Count", "", v5, Style.FONT, 1.5)
			label2.AutomaticSize = Enum.AutomaticSize.None
			label2.Position = UDim2.fromOffset(v8 + 12 - v9, v10)
			label2.Size = UDim2.fromOffset(v9, v5 + 2)
			label2.TextXAlignment = Enum.TextXAlignment.Right
			label2.TextColor3 = Style.MUTED
			v7[i] = {
				frame = panel,
				stripe = fill,
				name = label,
				fill = fill3,
				count = label2
			}
		end

		local v8 = {}
		local function counts()
			for k, v9 in v8 do
				local attribute = player:GetAttribute(QuestData.attr(v9.id))
				local v10 = math.min(type(attribute) ~= "number" and 0 or attribute, v9.goal)
				local v11 = v9.goal <= v10
				local backgroundColor = QuestIcons.COLOR[v9.cat] or Style.HAZARD
				v7[k].fill.Size = UDim2.fromScale(v10 / v9.goal, 1)
				local fill = v7[k].fill
				local backgroundColor2

				if v11 then
					backgroundColor2 = Style.GOOD
				else
					backgroundColor2 = backgroundColor
				end

				fill.BackgroundColor3 = backgroundColor2
				local stripe = v7[k].stripe

				if v11 then
					backgroundColor = Style.GOOD
				end

				stripe.BackgroundColor3 = backgroundColor
				v7[k].count.Text = Style.thousands(v10) .. " / " .. Style.thousands(v9.goal)
				local count = v7[k].count
				local textColor

				if v11 then
					textColor = Style.GOOD
				else
					textColor = Style.WHITE
				end

				count.TextColor3 = textColor
			end
		end
		local function lists()
			table.clear(v8)
			local questsById = {}

			for _, v9 in QuestData.sections(player) do
				for _, quest in v9.quests do
					questsById[quest.id] = quest
				end
			end

			for _, v9 in QuestData.outList(player:GetAttribute("QuestTrack")) do
				if questsById[v9] then
					table.insert(v8, questsById[v9])
				end
			end

			for k, v9 in v7 do
				local v10 = v8[k]
				v9.frame.Visible = v10 ~= nil

				if v10 then
					v9.name.Text = string.upper(v10.name)
				end
			end

			region.Visible = #v8 > 0
			counts()
		end
		player.AttributeChanged:Connect(function(value: string)
			if
				value == "QuestTrack"
				or value == "QuestDay"
				or value == "QuestWeek"
				or value == "QuestOutDaily"
				or value == "QuestOutWeekly"
			then
				lists()
			elseif #v8 > 0 and string.sub(value, 1, 6) == "Quest_" then
				counts()
			end
		end)
		lists()
	end
}