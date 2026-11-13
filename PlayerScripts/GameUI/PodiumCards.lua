local Style = require(script.Parent:WaitForChild("Style"))
local ToolIcon = require(script.Parent:WaitForChild("ToolIcon"))

local PodiumCards = {}

local vector2 = Vector2.new(760, 174)

local v = { 2, 1, 3 }

local v2 = { "MVP", "2ND", "3RD" }

function PodiumCards.appearAt(p: number)
	return (3 - p) * 0.28 + 0.75
end

local function flipAt(rank: number, p: number) -- 1 equivalent call inferred from this helper
	return p + 0.1 + (3 - rank) * 0.08
end

local function fader(folder, items)
	local v3 = {}
	local function add(instance)
		if instance:IsA("GuiObject") then
			table.insert(v3, { instance, "BackgroundTransparency", instance.BackgroundTransparency })
		end

		if instance:IsA("TextLabel") then
			table.insert(v3, { instance, "TextTransparency", instance.TextTransparency })
		end

		if instance:IsA("ImageLabel") then
			table.insert(v3, { instance, "ImageTransparency", instance.ImageTransparency })
		end

		if instance:IsA("UIStroke") then
			table.insert(v3, { instance, "Transparency", instance.Transparency })
		end
	end
	add(folder)

	for _, descendant in folder:GetDescendants() do
		local v4 = false

		if items then
			for _, ancestor in items do
				if descendant == ancestor or descendant:IsDescendantOf(ancestor) then
					v4 = true
					break
				end
			end
		end

		if not v4 then
			add(descendant)
		end
	end

	local v4 = -1
	return function(p: number)
		if p == v4 then
			return
		end

		v4 = p

		for _, v5 in v3 do
			v5[1][v5[2]] = v5[3] + (1 - v5[3]) * p
		end
	end
end

local function text(p, p2: string, p3: string, p4: number, p5, textColor: Color3, p6: number, p7: number, value: number?) -- 9 equivalent calls inferred from this helper
	local label = Style.label(p, p2, p3, p4, p5, 0)
	label.TextColor3 = textColor
	label.AnchorPoint = Vector2.new(value or 0, 0)
	label.Position = UDim2.fromOffset(p6, p7)
	return label
end

function PodiumCards.new(p)
	local region = Style.region(p, "PodiumCards", Vector2.new(0.5, 1), Vector2.new(0, -34), vector2)
	region.ZIndex = 4
	region.Visible = false
	Style.fit(region, vector2, 0.96, { grow = Style.isTouch() })

	local v3 = {}

	for i = 1, 3 do
		local frame = Style.frame(region, "Card" .. i, UDim2.fromOffset(236, 174), UDim2.fromOffset((i - 1) * 262, 0))
		local frame2 = Style.frame(frame, "Body", UDim2.fromOffset(236, 150), UDim2.fromOffset(0, 24))
		local frame3 = Style.frame(frame2, "Front", UDim2.fromOffset(236, 104), UDim2.fromOffset(0, 46))
		local frame4 = Style.frame(frame2, "Back", UDim2.fromOffset(236, 104), UDim2.fromOffset(0, 46))
		v3[i] = {
			root = frame,
			body = frame2,
			front = frame3,
			back = frame4,
			pic = Style.frame(frame4, "Pic", UDim2.fromOffset(196, 60), UDim2.fromOffset(20, 6))
		}
	end

	local function fill(state, entry)
		state.entry = entry

		for _, child in state.root:GetChildren() do
			if child.Name ~= "Body" then
				child:Destroy()
			end
		end

		for _, v4 in { state.body, state.front, state.back } do
			for _, child in v4:GetChildren() do
				if child ~= state.front and child ~= state.back and child ~= state.pic then
					child:Destroy()
				end
			end
		end

		for _, child in state.pic:GetChildren() do
			child:Destroy()
		end

		local body = state.body

		local fill2 = Style.fill(body, "Plate", Style.PANEL, UDim2.fromScale(1, 1))
		fill2.BackgroundTransparency = 0.12
		fill2.ZIndex = 0
		local stroke = Style.stroke
		local v4 = if entry.me then Style.HAZARD else Style.STEEL_LIGHT
		stroke(fill2, 1.5, 0.35, v4, true)
		local fill = Style.fill(body, "Edge", Style.teamColor(entry.team), UDim2.new(0, 4, 1, 0))
		fill.ZIndex = 2
		local fill3 = Style.fill(body, "Head", Style.STEEL, UDim2.new(1, 0, 0, 46))
		fill3.BackgroundTransparency = 0.25
		fill3.ZIndex = 1

		local fill4 = Style.fill
		local v5

		if entry.rank == 1 then
			v5 = Style.HAZARD
		else
			v5 = Style.STEEL_LIGHT
		end

		local v6 = fill4(body, "Rank", v5, UDim2.fromOffset(34, 34), UDim2.fromOffset(12, 6))
		v6.ZIndex = 2
		local rank = tostring(entry.rank)
		local font = Style.FONT
		local v7 = if entry.rank == 1 then Style.INK else Style.WHITE
		local label = text(v6, "N", rank, 24, font, v7, 17, 1, 0.5) -- inferred equivalent call
		label.ZIndex = 3
		local label2 = text(body, "Name", entry.name, 19, Style.FONT, Style.WHITE, 56, 2) -- inferred equivalent call
		label2.AutomaticSize = Enum.AutomaticSize.None
		label2.Size = UDim2.fromOffset(172, 23)
		label2.TextXAlignment = Enum.TextXAlignment.Left
		label2.TextTruncate = Enum.TextTruncate.AtEnd
		label2.ZIndex = 3
		local v8 = v2[entry.rank] or ""

		if entry.bot then
			v8 ..= "  ·  BOT"
		elseif entry.level then
			v8 ..= "  ·  LV " .. entry.level
		end

		local FONT_BODY = Style.FONT_BODY
		local v9 = if entry.rank == 1 then Style.HAZARD else Style.MUTED
		local label3 = text(body, "Sub", v8, 13, FONT_BODY, v9, 56, 25) -- inferred equivalent call
		label3.ZIndex = 3

		local front = state.front
		local label4 = text(front, "Score", Style.thousands(entry.score), 38, Style.FONT, Style.WHITE, 118, 6, 0.5) -- inferred equivalent call
		label4.ZIndex = 3
		local label5 = text(front, "Caption", "SCORE", 13, Style.FONT_BODY, Style.MUTED, 118, 50, 0.5) -- inferred equivalent call
		label5.ZIndex = 3
		local label6 = text( -- inferred equivalent call
			front,
			"Row",
			string.format("K  %d      D  %d      A  %d", entry.kills, entry.deaths, entry.assists),
			15,
			Style.FONT,
			Style.WHITE,
			118,
			72,
			0.5
		)
		label6.ZIndex = 3

		local back = state.back

		if entry.tool then
			local voxelImage = ToolIcon.voxelImage(entry.tool, state.pic, Style.WHITE)
			voxelImage.ZIndex = 3
		end

		local label7 = text(back, "Gun", entry.gunName .. " /", 15, Style.FONT, Style.WHITE, 118, 68, 0.5) -- inferred equivalent call
		label7.ZIndex = 3
		local label8 = text(back, "Skin", entry.skinName, 15, Style.FONT, entry.skinColor, 118, 84, 0.5) -- inferred equivalent call
		label8.ZIndex = 3

		if entry.me then
			local label9 = text( -- inferred equivalent call
				Style.fill(
					state.root,
					"You",
					Style.HAZARD,
					UDim2.fromOffset(46, 20),
					UDim2.fromOffset(118, 22),
					Vector2.new(0.5, 1)
				),
				"T",
				"YOU",
				15,
				Style.FONT,
				Style.INK,
				23,
				0,
				0.5
			)
			label9.ZIndex = 3
		end

		state.fade = fader(state.root, { state.front, state.back })
		local front2 = state.front
		local v10 = {}
		local function add(instance)
			if instance:IsA("GuiObject") then
				table.insert(v10, { instance, "BackgroundTransparency", instance.BackgroundTransparency })
			end

			if instance:IsA("TextLabel") then
				table.insert(v10, { instance, "TextTransparency", instance.TextTransparency })
			end

			if instance:IsA("ImageLabel") then
				table.insert(v10, { instance, "ImageTransparency", instance.ImageTransparency })
			end

			if instance:IsA("UIStroke") then
				table.insert(v10, { instance, "Transparency", instance.Transparency })
			end
		end
		add(front2)

		for _, descendant in front2:GetDescendants() do
			add(descendant)
		end

		local v11 = -1
		function state.frontFade(p2: number)
			if p2 == v11 then
				return
			end

			v11 = p2

			for _, v12 in v10 do
				v12[1][v12[2]] = v12[3] + (1 - v12[3]) * p2
			end
		end
		local back2 = state.back
		local v12 = {}
		local function add2(instance)
			if instance:IsA("GuiObject") then
				table.insert(v12, { instance, "BackgroundTransparency", instance.BackgroundTransparency })
			end

			if instance:IsA("TextLabel") then
				table.insert(v12, { instance, "TextTransparency", instance.TextTransparency })
			end

			if instance:IsA("ImageLabel") then
				table.insert(v12, { instance, "ImageTransparency", instance.ImageTransparency })
			end

			if instance:IsA("UIStroke") then
				table.insert(v12, { instance, "Transparency", instance.Transparency })
			end
		end
		add2(back2)

		for _, descendant in back2:GetDescendants() do
			add2(descendant)
		end

		local v13 = -1
		function state.backFade(p2: number)
			if p2 == v13 then
				return
			end

			v13 = p2

			for _, v14 in v12 do
				v14[1][v14[2]] = v14[3] + (1 - v14[3]) * p2
			end
		end
		state.frontFade(1)
		state.backFade(1)
		state.fade(1)
	end

	local v4 = false
	return {
		set = function(items)
			v3[1].entry = nil
			v3[1].root.Visible = false
			v3[2].entry = nil
			v3[2].root.Visible = false
			v3[3].entry = nil
			v3[3].root.Visible = false

			for _, item in items do
				local v5 = v[item.rank]

				if not v5 then
					continue
				end

				local v6 = v3[v5]
				v6.root.Visible = true
				fill(v6, item)
			end
		end,
		step = function(p2: number, p3: number)
			if not v4 then
				v4 = true
				region.Visible = true
			end

			for _, v5 in v3 do
				local entry = v5.entry

				if not (entry and v5.fade and v5.frontFade and v5.backFade) then
					continue
				end

				local easeOut = Style.easeOut((math.clamp((p2 - PodiumCards.appearAt(entry.rank)) / 0.32, 0, 1)))
				v5.fade(1 - easeOut)
				v5.body.Position = UDim2.fromOffset(0, 24 + 22 * (1 - easeOut))

				if not (easeOut > 0) then
					continue
				end

				local v6 = flipAt(entry.rank, p3) -- inferred equivalent call
				local v7 = math.clamp((p2 - v6) / 0.22, 0, 1)
				local easeOut2 = Style.easeOut((math.clamp((p2 - v6 - 0.132) / 0.22, 0, 1)))
				v5.frontFade((math.max(1 - easeOut, v7)))
				v5.front.Position = UDim2.fromOffset(-14 * Style.easeIn(v7), 46)
				v5.backFade((math.max(1 - easeOut, 1 - easeOut2)))
				v5.back.Position = UDim2.fromOffset(14 * (1 - easeOut2), 46)
			end
		end,
		hide = function()
			v4 = false
			region.Visible = false
		end
	}
end

return PodiumCards