local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToolTemplates = ReplicatedStorage:WaitForChild("ToolTemplates")

local Style = require(script.Parent:WaitForChild("Style"))
local ToolIcon = require(script.Parent:WaitForChild("ToolIcon"))
local Glyph = require(script.Parent:WaitForChild("Glyph"))
local QuestIcons = require(script.Parent:WaitForChild("QuestIcons"))
local QuestData = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("QuestData"))
local Progression = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("Progression"))
local remotes = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Remotes")

local ArmoryQuests = {}

local color = Color3.fromRGB(38, 40, 45)
local color2 = Color3.fromRGB(26, 27, 31)
Color3.fromRGB(38, 58, 36)
local color3 = Color3.fromRGB(34, 62, 38)
local color4 = Color3.fromRGB(190, 222, 186)

local color5 = Color3.fromRGB(66, 32, 24)
local color6 = Color3.fromRGB(214, 96, 62)

local function text(p, p2: string, p3: string, p4: number, p5: number, p6: number, p7: number, p8: number, options)
	local v = options or {}
	local label = Style.label(p, p2, p3, p4, v.font or Style.FONT, v.outline or 0)
	label.AutomaticSize = Enum.AutomaticSize.None
	label.Position = UDim2.fromOffset(p5, p6)
	label.Size = UDim2.fromOffset(p7, p8)
	label.TextXAlignment = v.ax or Enum.TextXAlignment.Left
	label.TextYAlignment = v.ay or Enum.TextYAlignment.Center
	label.TextColor3 = v.color or Style.WHITE
	label.TextWrapped = v.wrap == true
	local textTruncate

	if v.wrap then
		textTruncate = Enum.TextTruncate.None
	else
		textTruncate = Enum.TextTruncate.AtEnd
	end

	label.TextTruncate = textTruncate
	return label
end

local function plate(parent, name: string, backgroundColor: Color3, size: UDim2)
	local textButton = Instance.new("TextButton")
	textButton.Name = name
	textButton.Text = ""
	textButton.AutoButtonColor = false
	textButton.BorderSizePixel = 0
	textButton.BackgroundColor3 = backgroundColor
	textButton.Size = size
	textButton.Parent = parent
	Style.corner(textButton, 3)
	local stroke = Style.stroke(textButton, 2, 0, Style.INK, true)
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = textButton
	local count = 0
	local function go(p: number, p2: number)
		count += 1
		local v = count
		local scale = uiScale.Scale
		local now = os.clock()
		Style.animate(uiScale, function(_, p3: number): boolean
			if v ~= count then
				return false
			end

			local v2 = math.min((p3 - now) / p2, 1)
			uiScale.Scale = scale + (p - scale) * Style.easeOut(v2)
			return v2 < 1
		end)
	end
	local v = 1

	if not Style.isTouch() then
		local fill = Style.fill(textButton, "Hover", Style.WHITE, UDim2.fromScale(1, 1))
		fill.BackgroundTransparency = 1
		fill.ZIndex = 5
		Style.corner(fill, 3)
		local function light(flag: boolean) -- 2 equivalent calls inferred from this helper
			v = flag and 1.015 or 1
			fill.BackgroundTransparency = flag and 0.93 or 1
			local v2 = v
			count += 1
			local v3 = count
			local scale = uiScale.Scale
			local now = os.clock()
			local v4 = 0.1
			Style.animate(uiScale, function(_, p: number): boolean
				if v3 ~= count then
					return false
				end

				local v5 = math.min((p - now) / v4, 1)
				uiScale.Scale = scale + (v2 - scale) * Style.easeOut(v5)
				return v5 < 1
			end)
		end
		textButton.MouseEnter:Connect(function()
			light(true) -- inferred equivalent call
		end)
		textButton.MouseLeave:Connect(function()
			light(false) -- inferred equivalent call
		end)
	end

	textButton.InputBegan:Connect(function(input)
		local userInputType = input.UserInputType

		if userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.Touch then
			count += 1
			local v2 = count
			local scale = uiScale.Scale
			local now = os.clock()
			local v3 = 0.07
			local v4 = 0.96
			Style.animate(uiScale, function(_, p: number): boolean
				if v2 ~= count then
					return false
				end

				local v5 = math.min((p - now) / v3, 1)
				uiScale.Scale = scale + (v4 - scale) * Style.easeOut(v5)
				return v5 < 1
			end)
		end
	end)
	textButton.InputEnded:Connect(function(input)
		local userInputType = input.UserInputType

		if userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.Touch then
			local v2 = v
			count += 1
			local v3 = count
			local scale = uiScale.Scale
			local now = os.clock()
			local v4 = 0.22
			Style.animate(uiScale, function(_, p: number): boolean
				if v3 ~= count then
					return false
				end

				local v5 = math.min((p - now) / v4, 1)
				uiScale.Scale = scale + (v2 - scale) * Style.easeOut(v5)
				return v5 < 1
			end)
		end
	end)
	return textButton, stroke
end

local function tick(box, p: number, p2: number, p3: number, white: Color3?)
	local frame = Style.frame(box, "Tick", UDim2.fromOffset(p, p), UDim2.fromOffset(p2, p3), Vector2.new(0.5, 0.5))
	local v = math.max(3, (math.round(p * 0.18)))
	local v2 = Vector2.new(0.4, 0.74) * p
	local function bar(p4: string, vector2: Vector2)
		local v3 = vector2 - v2
		local v4 = v2 + v3 / 2

		local fill = Style.fill(
			frame,
			p4,
			white or Style.GOOD,
			UDim2.fromOffset(math.round(v3.Magnitude + v), v),
			UDim2.fromOffset(v4.X, v4.Y),
			Vector2.new(0.5, 0.5)
		)
		fill.Rotation = math.deg((math.atan2(v3.Y, v3.X)))
	end
	bar("Short", Vector2.new(0.14, 0.48) * p)
	bar("Long", Vector2.new(0.88, 0.2) * p)
end

local function lock(box, p: number, p2: number, p3: number)
	local frame = Style.frame(
		box,
		"Lock",
		UDim2.fromOffset(math.round(p * 1.15), (math.round(p * 1.6))),
		UDim2.fromOffset(p2, p3),
		Vector2.new(0.5, 0.5)
	)
	local frame2 = Style.frame(
		frame,
		"Shackle",
		UDim2.fromOffset(math.round(p * 0.72), p),
		UDim2.fromScale(0.5, 0),
		Vector2.new(0.5, 0)
	)
	Style.corner(frame2, p)
	Style.stroke(frame2, math.max(2, (math.round(p * 0.16))), 0, Style.STEEL_LIGHT, true)
	local box2 = Style.box(frame, "Body", color6, UDim2.new(1, 0, 0, p), 3, 2)
	box2.AnchorPoint = Vector2.new(0, 1)
	box2.Position = UDim2.fromScale(0, 1)
end

local function short(p: number) -- 1 equivalent call inferred from this helper
	if p >= 86400 then
		return p // 86400 .. "D"
	end

	if p >= 3600 then
		return p // 3600 .. "H"
	end

	return math.max(1, p // 60) .. "M"
end

function ArmoryQuests.claimBadge(p, instance)
	local fill = Style.fill(
		p,
		"ClaimMark",
		Style.HAZARD,
		UDim2.fromOffset(10, 10),
		UDim2.new(1, -10, 0, 10),
		Vector2.new(0.5, 0.5)
	)
	fill.Rotation = 45
	fill.ZIndex = 3
	local function paint() -- 1 equivalent call inferred from this helper
		fill.Visible = #QuestData.outList(instance:GetAttribute("QuestClaim")) > 0
	end
	instance:GetAttributeChangedSignal("QuestClaim"):Connect(paint)
	paint() -- inferred equivalent call
end

function ArmoryQuests:new(instance, data)
	local touch = data.touch == true
	local v = data.sections or QuestData.sections(instance)
	local v2 = {}
	local flag = false
	local v3 = false

	local offset = self.Size.X.Offset
	local offset2 = self.Size.Y.Offset
	local v4 = touch and 1 or 1.3

	local function S(p: number)
		return (math.floor(p * v4))
	end
	local v5 = math.floor(v4 * 124)
	local v6 = math.max(60, (math.floor(v4 * 66)))
	local v7 = math.floor(v4 * 150)

	local v8 = v5 + 8
	local v9 = offset - v8 - v7 - 8
	local v10 = v9 - 6 - 8
	local v11 = (v10 - 8) // 2
	local v12 = math.floor(v4 * 76)
	local v13 = math.floor(v4 * 24)
	local v14 = math.floor(v4 * 44)

	local parent = nil
	local scroll = nil
	local v15 = nil
	local v16 = {}
	local v17 = nil
	local v18 = {}
	local flag2 = false
	local v19 = 1
	local v20 = nil
	local count = 0

	local function progress(data2) -- 6 equivalent calls inferred from this helper
		local attribute = instance:GetAttribute(QuestData.attr(data2.id))
		return (math.min(type(attribute) ~= "number" and (data2.sample or 0) or attribute, data2.goal))
	end

	local function weekliesDone()
		local count2 = 0

		for _, v21 in v do
			if v21.id ~= "weekly" then
				continue
			end

			for _, quest in v21.quests do
				if quest.needs or not (progress(quest) >= quest.goal) then -- inferred equivalent call
					continue
				end

				count2 += 1
			end
		end

		return count2
	end

	local function locked(data2): boolean -- 2 equivalent calls inferred from this helper
		local level = instance:GetAttribute("Level")

		if data2.level == nil or not ((type(level) ~= "number" and 1 or level) < data2.level) then
			if data2.needs == nil then
				return false
			end

			return weekliesDone() < data2.needs
		end

		return true
	end

	local function lockWord(data2) -- 2 equivalent calls inferred from this helper
		if data2.needs then
			return (string.format("%d / %d WEEKLIES", weekliesDone(), data2.needs))
		end

		return (string.format("LEVEL %d", data2.level))
	end

	local function tracked(data2): boolean -- 2 equivalent calls inferred from this helper
		return table.find(QuestData.outList(instance:GetAttribute("QuestTrack")), data2.id) ~= nil
	end

	local function claimable(p): boolean -- 4 equivalent calls inferred from this helper
		return table.find(QuestData.outList(instance:GetAttribute("QuestClaim")), p.id) ~= nil
	end

	local v21 = {}
	local total = 0
	local function holdScrap(flag3: boolean) -- 2 equivalent calls inferred from this helper
		total += flag3 and 1 or -1

		if data.holdScrap then
			data.holdScrap(total > 0)
		end
	end
	local function releaseScrap(p) -- 3 equivalent calls inferred from this helper
		if p.holding then
			p.holding = false
			holdScrap(false) -- inferred equivalent call
		end
	end

	local function looksWaiting(data2) -- 2 equivalent calls inferred from this helper
		return v21[data2.id] ~= nil or claimable(data2) -- inferred equivalent call
	end

	local function paintRail()
		local serverTimeNow = workspace:GetServerTimeNow()

		for k, v22 in v16 do
			local v23 = v[k]
			local count2 = 0
			local v24 = false

			for _, quest in v23.quests do
				if progress(quest) >= quest.goal then -- inferred equivalent call
					count2 += 1
				end

				v24 = v24 or claimable(quest) -- inferred equivalent call
			end

			local note = v22.note
			local textColor = if v24 then Style.HAZARD else Style.MUTED
			note.TextColor3 = textColor
			local v25 = QuestData.resetIn(v23, serverTimeNow)
			local v26 = not (#v23.quests > 0) and "SOON" or string.format("%d / %d", count2, #v23.quests)
			local note2 = v22.note
			local v27

			if v25 and #v23.quests > 0 then
				v27 = "   " .. short(math.floor(v25)) -- inferred equivalent call
			else
				v27 = ""
			end

			note2.Text = v26 .. v27
			local v28 = k == v19
			local button = v22.button
			local backgroundColor = if v28 then color else Style.PANEL
			button.BackgroundColor3 = backgroundColor
			local title = v22.title
			local textColor2 = if v28 then Style.WHITE else Style.MUTED
			title.TextColor3 = textColor2
		end
	end

	local function startTimer() -- 1 equivalent call inferred from this helper
		count += 1
		local v22 = count
		task.spawn(function()
			while count == v22 and v3 do
				paintRail()
				task.wait(30)
			end
		end)
	end

	local function act(data2, p)
		if v21[data2.id] then
			return
		end

		if claimable(data2) then -- inferred equivalent call
			local v22 = { paid = false, holding = true }
			v21[data2.id] = v22
			holdScrap(true) -- inferred equivalent call
			remotes:WaitForChild("QuestAction"):FireServer("claim", data2.id)
			local QuestClaimShow = require(script.Parent:WaitForChild("QuestClaimShow"))
			QuestClaimShow.press(instance:WaitForChild("PlayerGui"), p)
			task.delay(6, function()
				if v21[data2.id] == v22 and not v22.paid then
					warn("[ArmoryQuests] no reply to the claim of " .. data2.id)
					v21[data2.id] = nil
					releaseScrap(v22) -- inferred equivalent call

					if v2.refresh then
						v2.refresh()
					end
				end
			end)
		elseif progress(data2) < data2.goal then -- inferred equivalent call
			remotes:WaitForChild("QuestAction"):FireServer("track", data2.id)
		end
	end

	local function buildDetail(p)
		local v22 = offset2 - 8
		local box = Style.box(p, "Detail", color, UDim2.fromOffset(v7, v22), 3, 2)
		box.Position = UDim2.fromOffset(offset - v7, 4)
		Style.tape(box, "Tape", UDim2.new(1, 0, 0, 5), v7, 10)
		local v23 = v7 - 16
		local v24 = v22 - 44 - 8 - math.floor(v4 * 20)
		local v25 = v24 - math.floor(v4 * 26)
		local v26 = v25 - math.floor(v4 * 3)
		local v27 = v26 - math.floor(v4 * 25)
		local v28 = v27 - math.floor(v4 * 30)
		local v29 = v28 - math.floor(v4 * 44)
		local v30 = math.floor(v4 * 12)
		local v31 = v29 - math.floor(v4 * 4) - v30

		local box2 = Style.box(box, "Stage", color2, UDim2.fromOffset(v23, v31), 3, 1.5)
		box2.Position = UDim2.fromOffset(8, v30)
		local frame = Style.frame(box2, "Picture", UDim2.new(), UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5))
		local uiScale = Instance.new("UIScale")
		uiScale.Parent = frame
		local v32 = text(box, "Name", "", math.floor(v4 * 16), 8, v29, v23, math.floor(v4 * 42), {
			ax = Enum.TextXAlignment.Center,
			wrap = true
		})
		local v34 = text(box, "Xp", "", math.floor(v4 * 24), 8, v28, v23, math.floor(v4 * 30), {
			color = Style.HAZARD,
			ax = Enum.TextXAlignment.Center
		})
		local frame2 = Style.frame(box, "Scrap", UDim2.fromOffset(v23, (math.floor(v4 * 22))), UDim2.fromOffset(8, v27))
		local nut = Style.nut(frame2, (math.floor(v4 * 16)))
		nut.AnchorPoint = Vector2.new(1, 0.5)
		nut.Position = UDim2.new(0.5, -math.floor(v4 * 14), 0.5, 0)
		local v35 = text(
			frame2,
			"Amount",
			"",
			math.floor(v4 * 16),
			v23 // 2 - math.floor(v4 * 10),
			0,
			v23 // 2 + math.floor(v4 * 10),
			math.floor(v4 * 22),
			{ color = Style.WHITE }
		)
		Style.fill(box, "Rule", Style.STEEL, UDim2.fromOffset(v23, 1), UDim2.fromOffset(8, v26))
		local v36 = text(box, "State", "", math.floor(v4 * 16), 8, v25, v23, math.floor(v4 * 26), {
			ax = Enum.TextXAlignment.Center
		})
		local v37 = text(box, "Tag", "", math.floor(v4 * 13), 8, v24, v23, math.floor(v4 * 18), {
			color = Style.HAZARD,
			ax = Enum.TextXAlignment.Center
		})
		local id = nil
		local function drawPicture(data2)
			if data2.id == id then
				return
			end

			id = data2.id
			local v38 = QuestIcons.COLOR[data2.cat] or Style.STEEL_LIGHT
			box2.BackgroundColor3 = v38:Lerp(Style.INK, 0.72)

			for _, child in frame:GetChildren() do
				if child ~= uiScale then
					child:Destroy()
				end
			end

			local v39 = math.min(v31 - 12, v23 - 12)

			if data2.tool then
				frame.Size = UDim2.fromOffset(v23 - 12, v31 - 8)
				ToolIcon.voxelImage(ToolTemplates:FindFirstChild(data2.tool), frame)
			else
				local v40 = math.min(math.floor(v39 * 0.72), (math.floor(v4 * 96)))
				frame.Size = UDim2.fromOffset(v40, v40)
				QuestIcons.draw(frame, data2.icon, v38)
			end

			if not data.still then
				local now = os.clock()
				Style.animate(uiScale, function(_, p2: number): boolean
					local v40 = math.min((p2 - now) / 0.16, 1)
					uiScale.Scale = 0.86 + 0.14 * Style.easeOut(v40)
					return v40 < 1
				end)
			end
		end
		local v38 = plate(box, "Track", Style.STEEL, UDim2.fromOffset(v23, 44))
		v38.Position = UDim2.fromOffset(8, v22 - 44 - 8)
		v38.Selectable = false
		local cap = Glyph.cap(v38, nil, Enum.KeyCode.ButtonA, 24)
		cap.AnchorPoint = Vector2.new(0, 0.5)
		cap.Position = UDim2.new(0, 8, 0.5, 0)
		local v39 = text(v38, "Word", "", math.floor(v4 * 15), 2, 0, v23 - 4, 44, {
			ax = Enum.TextXAlignment.Center
		})
		v38.Activated:Connect(function()
			if v20 then
				act(v20, v38)
			end
		end)
		return function(data2)
			box.Visible = data2 ~= nil

			if not data2 then
				return
			end

			local v40 = progress(data2) -- inferred equivalent call
			local v41 = locked(data2) -- inferred equivalent call
			local v42 = data2.goal <= v40
			drawPicture(data2)
			v32.Text = string.upper(data2.name)

			local level = instance:GetAttribute("Level")
			v34.Text = Style.thousands((math.floor(data2.xp * Progression.xpRate(type(level) ~= "number" and 1 or level)))) .. " XP"
			v35.Text = Style.thousands(data2.scrap or 0)
			local text2

			if v42 then
				text2 = (v21[data2.id] ~= nil or claimable(data2)) and "DONE" or "CLAIMED" -- inferred equivalent call
			elseif v41 then
				text2 = lockWord(data2) -- inferred equivalent call
			else
				text2 = string.format("%s / %s", Style.thousands(v40), Style.thousands(data2.goal))
			end

			v36.Text = text2
			local textColor

			if v42 then
				textColor = Style.GOOD
			else
				textColor = if v41 then color6 else Style.WHITE
			end

			v36.TextColor3 = textColor
			v37.Text = data2.tag or ""
			local v45 = looksWaiting(data2) -- inferred equivalent call
			v38.Visible = not v42 or v45
			local backgroundColor

			if v45 then
				backgroundColor = Style.HAZARD
			else
				backgroundColor = Style.STEEL
			end

			v38.BackgroundColor3 = backgroundColor
			local v47 = tracked(data2) -- inferred equivalent call
			v39.Text = v45 and "CLAIM" or v47 and "TRACKED" or "TRACK"
			local textColor2

			if v45 then
				textColor2 = Style.INK
			else
				textColor2 = if v47 then Style.HAZARD else Style.WHITE
			end

			v39.TextColor3 = textColor2
		end
	end

	local function select(p) -- 3 equivalent calls inferred from this helper
		if v20 and v18[v20.id] then
			v18[v20.id].stroke.Color = Style.INK
		end

		v20 = p

		if p and v18[p.id] then
			v18[p.id].stroke.Color = Style.HAZARD
		end

		v15(p)
	end

	local function buildCard(data2, p: number, total2: number, count2: number)
		local v22 = QuestIcons.COLOR[data2.cat] or Style.STEEL_LIGHT
		local button, stroke = plate(scroll, data2.id, color, UDim2.fromOffset(v11, v12))
		button.Position = UDim2.fromOffset(p, total2)
		local fill = Style.fill(button, "Stripe", v22, UDim2.new(0, 5, 1, 0))
		Style.corner(fill, 3)
		local lerped = v22:Lerp(Style.INK, 0.72)
		local box = Style.box(button, "Emblem", lerped, UDim2.fromOffset(v14, v14), 3, 1.5)
		box.Position = UDim2.fromOffset(11, (math.floor(v4 * 5)))
		local v23 = data2.tool and 2 or math.floor(v4 * 8)
		local frame = Style.frame(
			box,
			"Picture",
			UDim2.fromOffset(v14 - v23 * 2, v14 - v23 * 2),
			UDim2.fromOffset(v23, v23)
		)

		if data2.tool then
			ToolIcon.voxelImage(ToolTemplates:FindFirstChild(data2.tool), frame)
		else
			QuestIcons.draw(frame, data2.icon, v22)
		end

		local v24 = v14 + 11 + 7
		local v25 = text(
			button,
			"Name",
			string.upper(data2.name),
			math.floor(v4 * 15),
			v24,
			math.floor(v4 * 3),
			v11 - v24 - 4,
			math.floor(v4 * 46),
			{ wrap = true }
		)
		local fill2 = Style.fill(
			button,
			"Tracked",
			Style.HAZARD,
			UDim2.fromOffset(8, 8),
			UDim2.new(1, -9, 0, 9),
			Vector2.new(0.5, 0.5)
		)
		fill2.Rotation = 45
		local v26 = math.floor(v4 * 84)
		local v27 = v12 - math.floor(v4 * 22)
		local fill3 = Style.fill(
			button,
			"Track",
			color2,
			UDim2.fromOffset(v11 - v26 - 21, 8),
			UDim2.fromOffset(11, v27 + math.floor(v4 * 5))
		)
		Style.stroke(fill3, 1, 0, Style.INK, true)
		local fill4 = Style.fill(fill3, "Fill", v22, UDim2.fromScale(0, 1))
		local v28 = text(button, "Count", "", math.floor(v4 * 13), v11 - v26 - 6, v27, v26, math.floor(v4 * 18), {
			color = Style.MUTED,
			ax = Enum.TextXAlignment.Right
		})

		local v29 = "pic"
		local v30 = nil
		local function redraw(flag3: boolean)
			local v31 = progress(data2) -- inferred equivalent call
			local v32 = locked(data2) -- inferred equivalent call
			local v36 = data2.goal <= v31
			local v37 = looksWaiting(data2) -- inferred equivalent call
			local v38 = v36 and not v37
			local backgroundColor

			if v38 then
				backgroundColor = color3
			elseif v32 and not v36 then
				backgroundColor = color5
			else
				backgroundColor = color
			end

			button.BackgroundColor3 = backgroundColor
			local backgroundColor2

			if v38 then
				backgroundColor2 = Style.GOOD
			elseif v37 then
				backgroundColor2 = Style.HAZARD
			else
				backgroundColor2 = if v32 then color6 else v22
			end

			fill.BackgroundColor3 = backgroundColor2
			local backgroundColor3 = if v37 then Style.HAZARD else v22
			fill4.BackgroundColor3 = backgroundColor3
			fill3.Visible = not v38
			local textColor = if v38 then color4 else Style.WHITE
			v25.TextColor3 = textColor
			local backgroundColor4

			if v38 then
				backgroundColor4 = Style.GOOD:Lerp(Style.INK, 0.3)
			else
				backgroundColor4 = lerped
			end

			box.BackgroundColor3 = backgroundColor4
			local text2

			if v38 then
				text2 = "CLAIMED"
			elseif v37 then
				text2 = "CLAIM"
			elseif v32 then
				text2 = lockWord(data2) -- inferred equivalent call
			else
				text2 = string.format("%s / %s", Style.thousands((math.floor(v31))), Style.thousands(data2.goal))
			end

			v28.Text = text2
			local textColor2

			if v38 then
				textColor2 = Style.GOOD
			elseif v37 then
				textColor2 = Style.HAZARD
			else
				textColor2 = if v32 then color6 else Style.MUTED
			end

			v28.TextColor3 = textColor2
			fill2.Visible = tracked(data2) and not v36 -- inferred equivalent call
			local v46 = v38 and "tick" or v32 and not v36 and "lock" or "pic"

			if v46 ~= v29 then
				v29 = v46

				for _, childName in { "Tick", "Lock" } do
					local child = box:FindFirstChild(childName)

					if child then
						child:Destroy()
					end
				end

				frame.Visible = v46 == "pic"

				if v46 == "tick" then
					tick(box, math.floor(v4 * 28), v14 // 2, v14 // 2, Style.WHITE)
				elseif v46 == "lock" then
					lock(box, math.floor(v4 * 14), v14 // 2, v14 // 2)
				end
			end

			if v38 and v30 == false and not data.still then
				local fill5 = Style.fill(button, "ClaimFlash", Style.WHITE, UDim2.fromScale(1, 1))
				fill5.ZIndex = 20
				fill5.BackgroundTransparency = 0.35
				Style.corner(fill5, 4)
				local now = os.clock()
				Style.animate(fill5, function(_, p2: number): boolean
					local v47 = math.min((p2 - now) / 0.4, 1)
					fill5.BackgroundTransparency = 0.35 + 0.65 * Style.easeOut(v47)

					if v47 >= 1 then
						fill5:Destroy()
					end

					return v47 < 1
				end)
			end

			v30 = v38
			local v47 = v31 / data2.goal

			if flag3 and not data.still then
				local v48 = os.clock() + (count2 - 1) * 0.04
				Style.animate(fill4, function(_, p2: number): boolean
					local v49 = math.clamp((p2 - v48) / 0.4, 0, 1)
					fill4.Size = UDim2.fromScale(v47 * Style.easeOut(v49), 1)
					return v49 < 1
				end)
			else
				fill4.Size = UDim2.fromScale(v47, 1)
			end
		end
		redraw(true)
		v18[data2.id] = { button = button, stroke = stroke, redraw = redraw, emblem = box }
		button.Activated:Connect(function()
			if Glyph.gamepad() and v20 == data2 then
				act(data2, button)
			end

			select(data2) -- inferred equivalent call
		end)
		button.SelectionGained:Connect(function()
			select(data2) -- inferred equivalent call
		end)

		if not data.still then
			local v31 = os.clock() + (count2 - 1) * 0.04
			button.Position = UDim2.fromOffset(p + 26, total2)
			Style.animate(button, function(_, p2: number): boolean
				local v32 = math.clamp((p2 - v31) / 0.2, 0, 1)
				button.Position = UDim2.fromOffset(p + 26 * (1 - Style.easeOut(v32)), total2)
				return v32 < 1
			end)
		end
	end

	local function showSection(p: number)
		v19 = p

		for _, guiObject in scroll:GetChildren() do
			if guiObject:IsA("GuiObject") then
				guiObject:Destroy()
			end
		end

		table.clear(v18)
		v20 = nil
		local quests = v[p].quests
		local total2 = 4
		local v22 = nil
		local count2 = 0

		for _, v23 in QuestData.CATS do
			local quests2 = {}
			local total3 = 0

			for _, quest in quests do
				if quest.cat ~= v23.id then
					continue
				end

				table.insert(quests2, quest)
				total3 += progress(quest) >= quest.goal and 1 or 0 -- inferred equivalent call
			end

			if not (#quests2 > 0) then
				continue
			end

			text(scroll, v23.id .. "Head", v23.title, math.floor(v4 * 14), 6, total2, v10 // 2, v13, {
				color = QuestIcons.COLOR[v23.id]
			})
			text(
				scroll,
				v23.id .. "Done",
				string.format("%d / %d", total3, #quests2),
				math.floor(v4 * 13),
				4 + v10 // 2,
				total2,
				v10 - v10 // 2 - 2,
				v13,
				{ color = Style.MUTED, ax = Enum.TextXAlignment.Right }
			)
			total2 += v13
			v22 = v22 or quests2[1]

			for k, v24 in quests2 do
				count2 += 1
				buildCard(v24, 4 + (k - 1) % 2 * (v11 + 8), total2, count2)

				if k % 2 == 0 or k == #quests2 then
					total2 += v12 + 8
				end
			end
		end

		scroll.CanvasSize = UDim2.fromOffset(0, total2 - 8 + 4)
		scroll.CanvasPosition = Vector2.zero

		if #quests == 0 then
			text(scroll, "None", "NOTHING POSTED YET", math.floor(v4 * 18), 0, 0, v9 - 6, offset2, {
				color = Style.DIM,
				ax = Enum.TextXAlignment.Center
			})
		end

		select(v22) -- inferred equivalent call
		paintRail()

		if data.reseat then
			data.reseat()
		end

		local v23 = (p - 1) * (v6 + 8) + v6 - 5

		if data.still then
			v17.Position = UDim2.fromOffset(0, v23)
			return
		end

		local offset3 = v17.Position.Y.Offset
		local now = os.clock()
		Style.animate(v17, function(_, p2: number): boolean
			local v24 = math.min((p2 - now) / 0.16, 1)
			v17.Position = UDim2.fromOffset(0, offset3 + (v23 - offset3) * Style.easeOut(v24))
			return v24 < 1
		end)
	end

	local function cardLanded(p)
		local uiScale = p.button:FindFirstChildOfClass("UIScale")
		local tick2 = p.emblem:FindFirstChild("Tick")
		local uiScale2

		if tick2 then
			uiScale2 = Instance.new("UIScale")
			uiScale2.Scale = 0
			uiScale2.Parent = tick2
		else
			uiScale2 = nil
		end

		local now = os.clock()
		Style.animate(p, function(_, p2: number): boolean
			local v22 = math.min(1, (p2 - now) / 0.32)

			if uiScale then
				uiScale.Scale = 0.88 + 0.12 * Style.pop(v22)
			end

			if uiScale2 then
				uiScale2.Scale = Style.pop(v22)
			end

			return v22 < 1
		end)
	end

	local function claimPaid(p, xp, scrap)
		local v22 = v21[p]

		if not v22 then
			return
		end

		v22.paid = true
		local quest2 = nil
		local tier = nil

		for _, v23 in v do
			for _, quest in v23.quests do
				if quest.id ~= p then
					continue
				end

				if quest.needs then
					quest2 = quest
					tier = "bonus"
				else
					tier = v23.id
					quest2 = quest
				end
			end
		end

		local function landed() -- 1 equivalent call inferred from this helper
			v21[p] = nil
			releaseScrap(v22) -- inferred equivalent call

			if v3 then
				local v23 = v18[p]

				if v23 then
					v23.redraw(false)
					cardLanded(v23)
				end

				paintRail()

				if v20 then
					v15(v20)
				end
			else
				flag2 = true
			end
		end

		if not quest2 then
			landed() -- inferred equivalent call
			error("[ArmoryQuests] paid quest " .. tostring(p) .. " is not on the lists")
		end

		local QuestClaimShow = require(script.Parent:WaitForChild("QuestClaimShow"))
		QuestClaimShow.play(instance:WaitForChild("PlayerGui"), {
			quest = quest2,
			tier = tier,
			xp = xp,
			scrap = scrap,
			from = function()
				local v23 = v18[p]
				return if v3 and v23 then v23.emblem else nil
			end,
			scrapPlate = data.scrapPlate,
			levelPlate = data.levelPlate,
			drawTick = tick,
			landed = landed,
			scrapIn = function()
				releaseScrap(v22) -- inferred equivalent call
			end
		})
	end

	local function build()
		flag = true
		remotes:WaitForChild("QuestAction").OnClientEvent:Connect(function(p, p2, xp, scrap)
			if p == "paid" then
				claimPaid(p2, xp, scrap)
			end
		end)
		parent = Style.frame(self, "Home", UDim2.fromScale(1, 1))

		for k, v22 in v do
			local button = plate(parent, v22.id .. "Rail", Style.PANEL, UDim2.fromOffset(v5, v6))
			button.Position = UDim2.fromOffset(0, (k - 1) * (v6 + 8))
			v16[k] = {
				button = button,
				title = text(
					button,
					"Title",
					v22.title,
					math.floor(v4 * 18),
					12,
					math.floor(v4 * 8),
					v5 - 20,
					(math.floor(v4 * 24))
				),
				note = text(
					button,
					"Note",
					"",
					math.floor(v4 * 13),
					12,
					math.floor(v4 * 8) + math.floor(v4 * 24),
					v5 - 20,
					math.floor(v4 * 18),
					{ color = Style.MUTED }
				)
			}
			button.Activated:Connect(function()
				if v19 ~= k then
					showSection(k)
				end
			end)
		end

		v17 = Style.tape(parent, "RailTape", UDim2.fromOffset(v5, 5), v5, 10)
		v17.ZIndex = 2
		v17.Position = UDim2.fromOffset(0, v6 - 5)
		scroll = Instance.new("ScrollingFrame")
		scroll.Name = "Scroll"
		scroll.BackgroundTransparency = 1
		scroll.BorderSizePixel = 0
		scroll.ScrollBarThickness = 6
		scroll.ScrollBarImageColor3 = Style.HAZARD
		scroll.ScrollingDirection = Enum.ScrollingDirection.Y
		scroll.Selectable = false
		scroll.Size = UDim2.fromOffset(v9, offset2)
		scroll.Position = UDim2.fromOffset(v8, 0)
		scroll.Parent = parent
		v15 = buildDetail(parent)
		showSection(1)
		local function refresh() -- 1 equivalent call inferred from this helper
			for _, v22 in v18 do
				v22.redraw(false)
			end

			paintRail()

			if v20 then
				v15(v20)
			end
		end
		v2.refresh = refresh
		instance.AttributeChanged:Connect(function(value: string)
			if value == "QuestDay" or value == "QuestWeek" or value == "QuestOutDaily" or value == "QuestOutWeekly" then
				v = QuestData.sections(instance)
				v19 = math.min(v19, #v)

				if v3 then
					showSection(v19)
				else
					flag2 = true
				end
			elseif
				value == "QuestTrack"
				or value == "QuestClaim"
				or value == "Level"
				or string.sub(value, 1, 6) == "Quest_"
			then
				if v3 then
					refresh() -- inferred equivalent call
				else
					flag2 = true
				end
			end
		end)
	end

	function v2.show(visible: boolean)
		if visible == v3 then
			return
		end

		v3 = visible
		self.Visible = visible

		if not visible then
			count += 1
			return
		end

		if flag then
			if flag2 then
				showSection(v19)
			end
		else
			build()
		end

		flag2 = false

		if not data.still then
			startTimer() -- inferred equivalent call
		end
	end

	function v2.firstPad()
		if v20 and v18[v20.id] then
			return v18[v20.id].button
		end

		return v16[v19] and v16[v19].button
	end

	return v2
end

return ArmoryQuests