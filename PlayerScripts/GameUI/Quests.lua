local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ToolTemplates = ReplicatedStorage:WaitForChild("ToolTemplates")

local Style = require(script.Parent:WaitForChild("Style"))
local NewMenus = require(script.Parent:WaitForChild("NewMenus"))
local Armory = require(script.Parent:WaitForChild("Armory"))
local PadMenus = require(script.Parent:WaitForChild("PadMenus"))
local CardSelect = require(script.Parent:WaitForChild("CardSelect"))
local ToolIcon = require(script.Parent:WaitForChild("ToolIcon"))
local Glyph = require(script.Parent:WaitForChild("Glyph"))
local QuestIcons = require(script.Parent:WaitForChild("QuestIcons"))
local QuestData = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("QuestData"))
local Progression = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("Progression"))

local Quests = {
	["ON"] = NewMenus.on("Quests"),
	toggle = nil,
	open = nil,
	close = nil,
	isOpen = nil
}

local v = {
	claim = { image = "rbxassetid://98153179041297", words = Color3.fromRGB(255, 255, 255) },
	track = { image = "rbxassetid://135003051670967", words = Color3.fromRGB(255, 255, 255) },
	untrack = { image = "rbxassetid://122248367155092", words = Color3.fromRGB(255, 198, 32) },
	off = { image = "rbxassetid://116067232788719", words = Color3.fromRGB(176, 178, 184) }
}

local color = Color3.fromRGB(226, 226, 226)
local color2 = Color3.fromRGB(34, 36, 42)
local color3 = Color3.fromRGB(20, 21, 25)
local color4 = Color3.fromRGB(30, 56, 36)
local color5 = Color3.fromRGB(190, 222, 186)
Color3.fromRGB(56, 30, 24)
local color6 = Color3.fromRGB(240, 128, 96)

local function text(p, p2: string, p3: string, p4: number, p5: number, p6: number, p7: number, p8: number, options)
	local v2 = options or {}
	local label = Style.label(p, p2, p3, p4, v2.font or Style.FONT, v2.outline or 0)
	label.AutomaticSize = Enum.AutomaticSize.None
	label.Position = UDim2.fromOffset(p5, p6)
	label.Size = UDim2.fromOffset(p7, p8)
	label.TextXAlignment = v2.ax or Enum.TextXAlignment.Left
	label.TextYAlignment = v2.ay or Enum.TextYAlignment.Center
	label.TextColor3 = v2.color or Style.WHITE
	label.TextWrapped = v2.wrap == true
	local textTruncate

	if v2.wrap then
		textTruncate = Enum.TextTruncate.None
	else
		textTruncate = Enum.TextTruncate.AtEnd
	end

	label.TextTruncate = textTruncate
	local uiStroke = label:FindFirstChildOfClass("UIStroke")

	if uiStroke then
		uiStroke.LineJoinMode = Enum.LineJoinMode.Round
	end

	return label
end

local function feel(button, p: number, callback)
	local punch = Instance.new("UIScale")
	punch.Name = "Punch"
	punch.Parent = button
	local v2 = 1
	local function go(scale: number, duration: number, p2)
		TweenService:Create(punch, TweenInfo.new(duration, p2, Enum.EasingDirection.Out), {
			Scale = scale
		}):Play()
	end

	if not Style.isTouch() then
		local fill = Style.fill(button, "Hover", Style.WHITE, UDim2.fromScale(1, 1))
		fill.BackgroundTransparency = 1
		fill.ZIndex = 8
		Style.corner(fill, ((math.max)(p, 0)))
		local v3

		if p < 0 and button:IsA("ImageButton") then
			v3 = button
		else
			v3 = nil
		end

		fill.Visible = v3 == nil
		button.MouseEnter:Connect(function()
			if callback and not callback() then
				return
			end

			v2 = callback and 1.04 or 1.02
			fill.BackgroundTransparency = callback and 0.82 or 0.93

			if v3 then
				v3.ImageColor3 = Color3.new(1, 1, 1)
			end

			go(v2, 0.1, Enum.EasingStyle.Quad)
		end)
		button.MouseLeave:Connect(function()
			v2 = 1
			fill.BackgroundTransparency = 1

			if v3 then
				v3.ImageColor3 = color
			end

			go(v2, 0.1, Enum.EasingStyle.Quad)
		end)
	end

	button.InputBegan:Connect(function(input)
		local userInputType = input.UserInputType

		if
			(userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.Touch)
			and (not callback or callback())
		then
			go(0.95, 0.07, Enum.EasingStyle.Quad)
		end
	end)
	button.InputEnded:Connect(function(input)
		local userInputType = input.UserInputType

		if userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.Touch then
			go(v2, 0.24, Enum.EasingStyle.Back)
		end
	end)
end

local function tick(emblem, p: number, p2: number, p3: number, white: Color3?)
	local frame = Style.frame(emblem, "Tick", UDim2.fromOffset(p, p), UDim2.fromOffset(p2, p3), Vector2.new(0.5, 0.5))
	local v2 = math.max(3, (math.round(p * 0.18)))
	local v3 = Vector2.new(0.4, 0.74) * p
	local function bar(p4: string, vector2: Vector2)
		local v4 = vector2 - v3
		local v5 = v3 + v4 / 2
		local fill = Style.fill(
			frame,
			p4,
			white or Style.GOOD,
			UDim2.fromOffset(math.round(v4.Magnitude + v2), v2),
			UDim2.fromOffset(v5.X, v5.Y),
			Vector2.new(0.5, 0.5)
		)
		fill.Rotation = math.deg((math.atan2(v4.Y, v4.X)))
	end
	bar("Short", Vector2.new(0.14, 0.48) * p)
	bar("Long", Vector2.new(0.88, 0.2) * p)
end

local function lock(emblem, p: number, p2: number, p3: number)
	local lock2 = Instance.new("ImageLabel")
	lock2.Name = "Lock"
	lock2.BackgroundTransparency = 1
	lock2.Image = "rbxassetid://119994231721439"
	lock2.ScaleType = Enum.ScaleType.Fit
	lock2.AnchorPoint = Vector2.new(0.5, 0.5)
	lock2.Size = UDim2.fromOffset(p, p)
	lock2.Position = UDim2.fromOffset(p2, p3)
	lock2.ZIndex = 3
	lock2.Parent = emblem
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

function Quests.mount(data)
	if not Quests.ON then
		return
	end

	local player = data.player
	local touch = Style.isTouch()
	local still = data.still == true

	local layer = Style.layer(data.playerGui, "QuestsBackdrop", 10, true)
	layer.Enabled = false
	local layer2 = Style.layer(data.playerGui, "QuestsWindow", 11)
	layer2.Enabled = false
	local v2 = touch and 1 or 1.3

	local function S(p: number)
		return (math.floor(p * v2))
	end

	local v3 = false
	local room = nil
	local v4 = nil
	local parent = nil
	local parent2 = nil
	local function fn() end
	local function fn2() end
	local function fn3(): nil
		return nil
	end

	local function fn4(_: number) end
	local v5 = false

	local function build()
		v3 = true
		room = Instance.new("ImageLabel")
		room.Name = "Room"
		room.BorderSizePixel = 0
		room.BackgroundColor3 = Style.INK
		room.Image = "rbxassetid://101274562317334"
		room.ScaleType = Enum.ScaleType.Crop
		room.Size = UDim2.fromScale(1, 1)
		room.Active = true
		room.Parent = layer
		v4 = Style.fill(room, "Ink", Style.INK, UDim2.fromScale(1, 1))
		v4.BackgroundTransparency = 0.75
		local v6 = touch and 540 or 700
		local viewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(16, 9)
		local v7 = math.floor(v6 * math.clamp(viewportSize.X / math.max(viewportSize.Y, 1), 1.6, 2.2))
		parent = Style.region(layer2, "Quests", Vector2.new(0.5, 0.5), Vector2.zero, Vector2.new(v7, v6))
		Style.fit(parent, Vector2.new(v7, v6), 0.98)
		local modal = Instance.new("TextButton")
		modal.Name = "Modal"
		modal.Text = ""
		modal.BackgroundTransparency = 1
		modal.Size = UDim2.fromOffset(1, 1)
		modal.Modal = true
		modal.Selectable = false
		modal.Parent = parent
		parent2 = Style.frame(parent, "Body", UDim2.fromScale(1, 1))

		local v8 = QuestData.sections(player)
		local v9 = 1
		local v10 = nil
		local v11 = {}
		local v12 = {}
		local v13 = false
		local count = 0
		local fn5
		local fn6

		local function progress(data2) -- 6 equivalent calls inferred from this helper
			local attribute = player:GetAttribute(QuestData.attr(data2.id))
			return (math.min(type(attribute) ~= "number" and (data2.sample or 0) or attribute, data2.goal))
		end

		local function weekliesDone()
			local count2 = 0

			for _, v14 in v8 do
				if v14.id ~= "weekly" then
					continue
				end

				for _, quest in v14.quests do
					if quest.needs or not (progress(quest) >= quest.goal) then -- inferred equivalent call
						continue
					end

					count2 += 1
				end
			end

			return count2
		end

		local function locked(p): boolean -- 3 equivalent calls inferred from this helper
			local level = player:GetAttribute("Level")

			if p.level == nil or not ((type(level) ~= "number" and 1 or level) < p.level) then
				if p.needs == nil then
					return false
				end

				return weekliesDone() < p.needs
			end

			return true
		end

		local function lockWord(p) -- 2 equivalent calls inferred from this helper
			if p.needs then
				return (string.format("%d / %d WEEKLIES", weekliesDone(), p.needs))
			end

			return (string.format("LEVEL %d", p.level))
		end

		local function tracked(p): boolean -- 2 equivalent calls inferred from this helper
			return table.find(QuestData.outList(player:GetAttribute("QuestTrack")), p.id) ~= nil
		end

		local function claimable(p): boolean -- 6 equivalent calls inferred from this helper
			return table.find(QuestData.outList(player:GetAttribute("QuestClaim")), p.id) ~= nil
		end

		local function looksWaiting(p) -- 2 equivalent calls inferred from this helper
			return v12[p.id] ~= nil or claimable(p) -- inferred equivalent call
		end

		local function pays(p) -- 2 equivalent calls inferred from this helper
			local level = player:GetAttribute("Level")
			return (math.floor(p.xp * Progression.xpRate(type(level) ~= "number" and 1 or level)))
		end

		local label = Style.label(parent2, "Title", "QUESTS", 44, Style.FONT, 2.5)
		label.TextColor3 = Style.HAZARD
		label.Position = UDim2.fromOffset(16, 4)

		local CLOSE_SIZE = Style.CLOSE_SIZE
		local v14 = Style.closeButton(parent2)
		v14.AnchorPoint = Vector2.new(1, 0)
		v14.Position = UDim2.new(1, -16, 0, 10)
		v14.Activated:Connect(function()
			Quests.leave()
		end)
		local box = Style.box(parent2, "Scrap", Style.INK, UDim2.fromOffset(0, CLOSE_SIZE), 6, 1.5)
		box.AutomaticSize = Enum.AutomaticSize.X
		box.AnchorPoint = Vector2.new(1, 0)
		box.Position = UDim2.new(1, -16 - CLOSE_SIZE - 10, 0, 10)

		local uiListLayout = Instance.new("UIListLayout")
		uiListLayout.FillDirection = Enum.FillDirection.Horizontal
		uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		uiListLayout.Padding = UDim.new(0, 7)
		uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uiListLayout.Parent = box
		local uiPadding = Instance.new("UIPadding")
		uiPadding.PaddingLeft = UDim.new(0, 10)
		uiPadding.PaddingRight = UDim.new(0, 14)
		uiPadding.Parent = box
		local nut_2 = Style.nut(box, 26)
		nut_2.LayoutOrder = 1

		local label2 = Style.label(box, "Amount", "0", 24, Style.FONT, 0)
		label2.LayoutOrder = 2
		local v15 = 0
		local function paintScrap() -- 3 equivalent calls inferred from this helper
			if v15 == 0 then
				local scrap = player:GetAttribute("Scrap")
				label2.Text = Style.thousands(type(scrap) ~= "number" and 0 or scrap)
			end
		end
		local function releaseScrap(p) -- 3 equivalent calls inferred from this helper
			if p.holding then
				p.holding = false
				v15 -= 1
				paintScrap() -- inferred equivalent call
			end
		end

		local v16 = touch and 168 or 196
		local v17 = {}

		for k, v18 in v8 do
			local textButton = Instance.new("TextButton")
			textButton.Name = "Section_" .. v18.id
			textButton.Text = ""
			textButton.AutoButtonColor = false
			textButton.BorderSizePixel = 0
			textButton.BackgroundColor3 = Style.PANEL
			textButton.Size = UDim2.fromOffset(v16, 44)
			textButton.Position = UDim2.fromOffset(28 + (k - 1) * (v16 + 8), 64)
			textButton.Parent = parent2
			Style.corner(textButton, 4)
			Style.stroke(textButton, 2, 0, Style.INK, true)
			local name = text(textButton, "Title", v18.title, 20, 12, 0, v16 * 0.5, 40)
			local note = text(textButton, "Note", "", 14, v16 * 0.45, 0, v16 * 0.55 - 12, 40, {
				ax = Enum.TextXAlignment.Right,
				color = Style.MUTED
			})
			local tape = Style.tape(textButton, "Underline", UDim2.new(1, 0, 0, 5), v16, 10)
			tape.AnchorPoint = Vector2.new(0, 1)
			tape.Position = UDim2.fromScale(0, 1)
			local fill = Style.fill(
				textButton,
				"ClaimMark",
				Style.HAZARD,
				UDim2.fromOffset(10, 10),
				UDim2.new(1, -4, 0, 4),
				Vector2.new(0.5, 0.5)
			)
			fill.Rotation = 45
			fill.ZIndex = 3
			Style.stroke(fill, 1.5, 0, Style.INK, true)
			feel(textButton, 4)
			v17[k] = {
				button = textButton,
				name = name,
				note = note,
				under = tape,
				mark = fill
			}
			textButton.Activated:Connect(function()
				if v9 ~= k then
					fn5(k)
				end
			end)
		end

		local function paintTabs()
			local serverTimeNow = workspace:GetServerTimeNow()

			for k, v18 in v17 do
				local v19 = v8[k]

				if not v19 then
					continue
				end

				local count2 = 0
				local visible = false

				for _, quest in v19.quests do
					if progress(quest) >= quest.goal then -- inferred equivalent call
						count2 += 1
					end

					visible = visible or claimable(quest) -- inferred equivalent call
				end

				local v20 = QuestData.resetIn(v19, serverTimeNow)
				local note = v18.note
				local v21 = string.format("%d / %d", count2, #v19.quests)
				local v22

				if v20 then
					v22 = "   " .. short(math.floor(v20)) -- inferred equivalent call
				else
					v22 = ""
				end

				note.Text = v21 .. v22
				v18.mark.Visible = visible
				local visible2 = k == v9
				local name = v18.name
				local textColor

				if visible2 then
					textColor = Style.WHITE
				else
					textColor = Style.MUTED
				end

				name.TextColor3 = textColor
				local note2 = v18.note
				local textColor2

				if visible then
					textColor2 = Style.HAZARD
				else
					textColor2 = Style.MUTED
				end

				note2.TextColor3 = textColor2
				v18.under.Visible = visible2
				local button = v18.button
				local backgroundColor

				if visible2 then
					backgroundColor = color2
				else
					backgroundColor = Style.PANEL
				end

				button.BackgroundColor3 = backgroundColor
			end
		end

		local v18 = v6 - 64 - 16

		local v19 = math.floor((v7 - 32 - 14) * 0.36)
		local v20 = v7 - 32 - 14 - v19
		local v21 = v20 + 16 + 14

		local v22 = v20 - 6 - 24
		local v23 = math.floor((v22 - 12) / 2)
		local v24 = math.floor(v2 * 92)
		local v25 = math.floor(v2 * 30)
		local v26 = math.floor(v2 * 54)

		local cards = Instance.new("ScrollingFrame")
		cards.Name = "Cards"
		cards.BackgroundTransparency = 1
		cards.BorderSizePixel = 0
		cards.Position = UDim2.fromOffset(16, 116)
		cards.Size = UDim2.fromOffset(v20, v18 - 44 - 8)
		cards.ScrollingDirection = Enum.ScrollingDirection.Y
		cards.ScrollBarThickness = 6
		cards.ScrollBarImageColor3 = Style.HAZARD
		cards.CanvasSize = UDim2.new()
		cards.Selectable = false
		cards.Parent = parent2

		local function act(data2, p)
			if v12[data2.id] or still then
				return
			end

			local remotes = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Remotes")

			if claimable(data2) then -- inferred equivalent call
				local v27 = { paid = false, holding = true }
				v12[data2.id] = v27
				v15 += 1
				remotes:WaitForChild("QuestAction"):FireServer("claim", data2.id)
				local QuestClaimShow = require(script.Parent:WaitForChild("QuestClaimShow"))
				QuestClaimShow.press(data.playerGui, p)
				task.delay(6, function()
					if v12[data2.id] == v27 and not v27.paid then
						warn("[Quests] no reply to the claim of " .. data2.id)
						v12[data2.id] = nil
						releaseScrap(v27) -- inferred equivalent call
						local v28 = v11[data2.id]

						if v28 then
							v28.redraw(false)
						end

						fn6()
					end
				end)
			elseif progress(data2) < data2.goal and not locked(data2) then -- inferred equivalent call
				remotes:WaitForChild("QuestAction"):FireServer("track", data2.id)
			end
		end

		local function select(p)
			v10 = p

			for k, v27 in v11 do
				v27.setSelected(p ~= nil and k == p.id)
			end

			fn6()
		end

		local function buildCard(data2, p: number, p2: number, count2: number)
			local imageColor = QuestIcons.COLOR[data2.cat] or Style.STEEL_LIGHT
			local textButton = Instance.new("TextButton")
			textButton.Name = data2.id
			textButton.Text = ""
			textButton.AutoButtonColor = false
			textButton.BorderSizePixel = 0
			textButton.BackgroundColor3 = color2
			textButton.Size = UDim2.fromOffset(v23, v24)
			textButton.Position = UDim2.fromOffset(p, p2)
			textButton.Parent = cards
			Style.corner(textButton, 0)
			local stroke = Style.stroke(textButton, 2, 0, Style.INK, true)

			local function deep(color7: Color3) -- 2 equivalent calls inferred from this helper
				return color7:Lerp(Style.INK, 0.42)
			end

			local face = Instance.new("ImageLabel")
			face.Name = "Face"
			face.BackgroundTransparency = 1
			face.Image = "rbxassetid://103486403003468"
			face.ImageColor3 = deep(imageColor) -- inferred equivalent call
			face.ScaleType = Enum.ScaleType.Stretch
			face.Size = UDim2.fromScale(1, 1)
			face.Parent = textButton
			Style.corner(face, 0)

			local emblem = Instance.new("ImageLabel")
			emblem.Name = "Emblem"
			emblem.BackgroundColor3 = Style.INK
			emblem.BorderSizePixel = 0
			emblem.Image = "rbxassetid://103486403003468"
			emblem.ImageColor3 = imageColor
			emblem.Size = UDim2.fromOffset(v26, v26)
			emblem.Parent = textButton
			Style.corner(emblem, 0)
			Style.stroke(emblem, 2, 0, Style.INK, true)
			emblem.Position = UDim2.fromOffset(10, (math.floor(v2 * 8)))
			local v27 = data2.tool and 2 or math.floor(v2 * 11)
			local frame = Style.frame(
				emblem,
				"Picture",
				UDim2.fromOffset(v26 - v27 * 2, v26 - v27 * 2),
				UDim2.fromOffset(v27, v27)
			)

			if data2.tool then
				ToolIcon.voxelImage(ToolTemplates:FindFirstChild(data2.tool), frame)
			else
				QuestIcons.draw(frame, data2.icon, imageColor:Lerp(Color3.new(1, 1, 1), 0.5))
			end

			local v28 = v26 + 10 + 9
			local v29 = v23 - v28 - 8
			local v30 = text(
				textButton,
				"Name",
				string.upper(data2.name),
				math.floor(v2 * 15),
				v28,
				math.floor(v2 * 5),
				v29,
				math.floor(v2 * 38),
				{ wrap = true, outline = 1.5 }
			)
			local v31 = math.floor(v2 * 5) + math.floor(v2 * 38)
			local v32 = math.floor(v2 * 74)
			local v36 = text(textButton, "Xp", "", math.floor(v2 * 14), v28, v31, v32, math.floor(v2 * 18), {
				color = Style.HAZARD,
				outline = 1.5
			})
			local nut = Style.nut(textButton, (math.floor(v2 * 13)))
			nut.AnchorPoint = Vector2.new(0, 0.5)
			nut.Position = UDim2.fromOffset(v28 + v32, v31 + math.floor(v2 * 9))
			text(
				textButton,
				"Scrap",
				Style.thousands(data2.scrap or 0),
				math.floor(v2 * 14),
				v28 + v32 + math.floor(v2 * 13) + 5,
				v31,
				math.max(v29 - v32 - math.floor(v2 * 13) - 5, 10),
				math.floor(v2 * 18),
				{ outline = 1.5 }
			)
			local fill = Style.fill(
				textButton,
				"Tracked",
				Style.HAZARD,
				UDim2.fromOffset(9, 9),
				UDim2.new(1, -10, 0, 10),
				Vector2.new(0.5, 0.5)
			)
			fill.Rotation = 45
			local v37 = math.floor(v2 * 96)
			local v38 = v24 - math.floor(v2 * 22)
			local fill2 = Style.fill(
				textButton,
				"Track",
				color3,
				UDim2.fromOffset(v23 - v37 - 24, 8),
				UDim2.fromOffset(10, v38 + math.floor(v2 * 5))
			)
			Style.corner(fill2, 4)
			Style.stroke(fill2, 1, 0, Style.INK, true)
			local fill3 = Style.fill(fill2, "Fill", imageColor, UDim2.fromScale(0, 1))
			Style.corner(fill3, 4)
			local v39 = text(
				textButton,
				"Count",
				"",
				math.floor(v2 * 13),
				v23 - v37 - 8,
				v38,
				v37,
				math.floor(v2 * 18),
				{ color = Style.WHITE, ax = Enum.TextXAlignment.Right, outline = 1.5 }
			)
			local setSelected = CardSelect.attach(textButton, stroke, Style.INK)
			feel(textButton, 0)

			local v41 = "pic"
			local v42 = nil
			local function redraw(flag: boolean)
				local v43 = progress(data2) -- inferred equivalent call
				local v44 = locked(data2) -- inferred equivalent call
				local v45 = data2.goal <= v43
				local v46 = looksWaiting(data2) -- inferred equivalent call
				local v47 = v45 and not v46
				local backgroundColor = if v47 then color4 else color2
				textButton.BackgroundColor3 = backgroundColor
				local v49

				if v47 then
					v49 = Style.GOOD
				else
					v49 = if v46 then Style.HAZARD else imageColor
				end

				face.ImageColor3 = deep(v49) -- inferred equivalent call
				local backgroundColor2

				if v46 then
					backgroundColor2 = Style.HAZARD
				else
					backgroundColor2 = imageColor
				end

				fill3.BackgroundColor3 = backgroundColor2
				fill2.Visible = not v47
				local textColor = if v47 then color5 else Style.WHITE
				v30.TextColor3 = textColor
				local imageColor2

				if v47 then
					imageColor2 = Style.GOOD
				elseif v44 and not v45 then
					imageColor2 = imageColor:Lerp(Style.INK, 0.5)
				else
					imageColor2 = imageColor
				end

				emblem.ImageColor3 = imageColor2
				v36.Text = Style.thousands(pays(data2)) .. " XP" -- inferred equivalent call
				local textColor2 = if v47 then color5 else Style.HAZARD
				v36.TextColor3 = textColor2
				local text2

				if v47 then
					text2 = "CLAIMED"
				elseif v46 then
					text2 = "CLAIM"
				elseif v44 then
					text2 = lockWord(data2) -- inferred equivalent call
				else
					text2 = string.format("%s / %s", Style.thousands((math.floor(v43))), Style.thousands(data2.goal))
				end

				v39.Text = text2
				local textColor3

				if v47 then
					textColor3 = Style.GOOD
				elseif v46 then
					textColor3 = Style.HAZARD
				else
					textColor3 = if v44 then color6 else Style.WHITE
				end

				v39.TextColor3 = textColor3
				fill.Visible = tracked(data2) and not v45 -- inferred equivalent call
				local v56 = v47 and "tick" or v44 and not v45 and "lock" or "pic"

				if v56 ~= v41 then
					v41 = v56

					for _, childName in { "Tick", "Lock" } do
						local child = emblem:FindFirstChild(childName)

						if child then
							child:Destroy()
						end
					end

					frame.Visible = v56 ~= "tick"

					if v56 == "tick" then
						tick(emblem, math.floor(v2 * 30), v26 // 2, v26 // 2, Style.WHITE)
					elseif v56 == "lock" then
						lock(emblem, math.floor(v2 * 26), v26 - math.floor(v2 * 7), v26 - math.floor(v2 * 7))
					end
				end

				if v47 and v42 == false and not still then
					local fill4 = Style.fill(textButton, "ClaimFlash", Style.WHITE, UDim2.fromScale(1, 1))
					fill4.ZIndex = 20
					fill4.BackgroundTransparency = 0.35
					Style.corner(fill4, 0)
					local tween = TweenService:Create(
						fill4,
						TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ BackgroundTransparency = 1 }
					)
					tween.Completed:Once(function()
						fill4:Destroy()
					end)
					tween:Play()
				end

				v42 = v47
				local v57 = v43 / data2.goal

				if flag and not still then
					fill3.Size = UDim2.fromScale(0, 1)
					TweenService:Create(
						fill3,
						TweenInfo.new(
							0.4,
							Enum.EasingStyle.Quad,
							Enum.EasingDirection.Out,
							0,
							false,
							(count2 - 1) * 0.035
						),
						{ Size = UDim2.fromScale(v57, 1) }
					):Play()
				else
					fill3.Size = UDim2.fromScale(v57, 1)
				end
			end
			redraw(true)
			v11[data2.id] = {
				button = textButton,
				emblem = emblem,
				redraw = redraw,
				setSelected = setSelected
			}
			textButton.Activated:Connect(function()
				if v10 ~= data2 then
					select(data2)

					return
				end

				if not Glyph.gamepad() then
					local v43 = data2

					if v12[v43.id] == nil and not claimable(v43) then -- inferred equivalent call
						select(data2)

						return
					end
				end

				act(data2, textButton)
			end)
			textButton.SelectionGained:Connect(function()
				if v10 ~= data2 then
					select(data2)
				end
			end)

			if not still then
				textButton.Position = UDim2.fromOffset(p + 26, p2)
				TweenService:Create(
					textButton,
					TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, (count2 - 1) * 0.035),
					{ Position = UDim2.fromOffset(p, p2) }
				):Play()
			end
		end

		local box2 = Style.box(parent2, "Stage", Style.INK, UDim2.fromOffset(v19, v18), 4, 3)
		box2.Position = UDim2.fromOffset(v21, 64)
		box2.ClipsDescendants = true

		local v27 = math.max(v19, v18)
		local scene = Instance.new("ImageLabel")
		scene.Name = "Scene"
		scene.BackgroundTransparency = 1
		scene.Image = "rbxassetid://119465883115259"
		scene.ScaleType = Enum.ScaleType.Stretch
		scene.Size = UDim2.fromOffset(v27, v27)
		scene.Position = UDim2.fromOffset(math.floor((v19 - v27) / 2), 0)
		scene.Parent = box2
		local v28 = math.floor(v27 * 0.4)
		local v29 = math.floor(v27 * 0.36)
		local fill = Style.fill(
			box2,
			"Glow",
			Style.WHITE,
			UDim2.fromOffset(v28 - 10, v28 - 10),
			UDim2.fromOffset(v19 // 2, v29),
			Vector2.new(0.5, 0.5)
		)
		fill.BackgroundTransparency = 0.9
		local folder = Style.frame(box2, "Picture", UDim2.new(), UDim2.fromOffset(v19 // 2, v29), Vector2.new(0.5, 0.5))
		folder.ZIndex = 2
		local uiScale = Instance.new("UIScale")
		uiScale.Parent = folder
		local v30 = text(box2, "Group", "", math.floor(v2 * 15), 14, 10, v19 - 28, math.floor(v2 * 15) + 6, {
			outline = 2
		})
		v30.ZIndex = 3
		local v31 = touch and 52 or 60
		local v32 = math.min(v19 - 28, v31 * 5)
		local v35 = v18 - v31 - 12
		local v36 = v29 + v28 // 2

		local v37 = v35 - v36
		local v38 = (math.floor(v2 * 21) + 3) * 2
		local v39 = math.floor(v2 * 30)
		local v40 = math.floor(v2 * 20)

		local v41 = math.max(2, (v37 - v38 - v39 - 10 - v40) // 5)
		local v42 = v36 + v41
		local v43 = v42 + v38 + v41
		local v44 = v43 + v39 + v41
		local v45 = v44 + 10 + v41
		local v46 = text(box2, "Name", "", math.floor(v2 * 21), 14, v42, v19 - 28, v38, {
			wrap = true,
			ax = Enum.TextXAlignment.Center,
			outline = 2
		})
		v46.ZIndex = 3
		local frame = Style.frame(box2, "Pays", UDim2.fromOffset(v19, v39), UDim2.fromOffset(0, v43))
		frame.ZIndex = 3
		local v47 = text(frame, "Xp", "", math.floor(v2 * 26), 0, 0, v19 // 2 - 8, v39, {
			color = Style.HAZARD,
			ax = Enum.TextXAlignment.Right,
			outline = 2
		})
		v47.ZIndex = 3
		local nut = Style.nut(frame, (math.floor(v2 * 20)))
		nut.AnchorPoint = Vector2.new(0, 0.5)
		nut.Position = UDim2.fromOffset(v19 // 2 + 10, v39 // 2)
		nut.ZIndex = 3
		local v48 = text(
			frame,
			"Scrap",
			"",
			math.floor(v2 * 22),
			v19 // 2 + 10 + math.floor(v2 * 20) + 6,
			0,
			v19 // 2 - math.floor(v2 * 20) - 20,
			v39,
			{ outline = 2 }
		)
		v48.ZIndex = 3
		local v49 = math.min(v19 - 28, 340)
		local fill2 = Style.fill(
			box2,
			"Progress",
			color3,
			UDim2.fromOffset(v49, 10),
			UDim2.fromOffset((v19 - v49) // 2, v44)
		)
		fill2.ZIndex = 3
		Style.corner(fill2, 5)
		Style.stroke(fill2, 1.5, 0, Style.INK, true)
		local fill3 = Style.fill(fill2, "Fill", Style.HAZARD, UDim2.fromScale(0, 1))
		fill3.ZIndex = 3
		Style.corner(fill3, 5)
		local v50 = text(box2, "State", "", math.floor(v2 * 15), 14, v45, v19 - 28, v40, {
			ax = Enum.TextXAlignment.Center,
			outline = 2
		})
		v50.RichText = true
		v50.ZIndex = 3
		local action = Instance.new("ImageButton")
		action.Name = "Action"
		action.AutoButtonColor = false
		action.BackgroundTransparency = 1
		action.ScaleType = Enum.ScaleType.Stretch
		action.ImageColor3 = color
		action.AnchorPoint = Vector2.new(0.5, 0.5)
		action.Size = UDim2.fromOffset(v32, v31)
		action.Position = UDim2.fromOffset(v19 // 2, v35 + v31 // 2)
		action.ZIndex = 4
		action.Selectable = false
		action.Parent = box2
		local fill4 = Style.fill(
			action,
			"Pin",
			Style.WHITE,
			UDim2.fromOffset(math.floor(v2 * 12), (math.floor(v2 * 12))),
			UDim2.new(0, math.floor(v2 * 44), 0.5, 0),
			Vector2.new(0.5, 0.5)
		)
		fill4.Rotation = 45
		fill4.ZIndex = 5
		Style.stroke(fill4, 2, 0, Style.INK, true)
		local v51 = false
		feel(action, -1, function()
			return v51
		end)
		local v52 = text(action, "Text", "", math.floor(v2 * 24), 0, 0, v32, v31, {
			ax = Enum.TextXAlignment.Center,
			outline = 2
		})
		v52.ZIndex = 5
		action.Activated:Connect(function()
			if v10 then
				act(v10, action)
			end
		end)
		local v53 = text(box2, "Empty", "NOTHING POSTED YET", math.floor(v2 * 18), 0, v36 + 20, v19, 30, {
			ax = Enum.TextXAlignment.Center,
			color = Style.MUTED,
			outline = 2
		})
		v53.ZIndex = 3
		local id = nil
		local v54 = nil
		local punch = action:FindFirstChild("Punch")

		fn6 = function()
			local v55 = v10
			local visible = v55 ~= nil

			for _, v57 in { folder, v30, v46, frame, fill2, v50, action, fill } do
				v57.Visible = visible
			end

			v53.Visible = not visible

			if not v55 then
				return
			end

			local backgroundColor = QuestIcons.COLOR[v55.cat] or Style.STEEL_LIGHT

			if id ~= v55.id then
				id = v55.id
				folder:ClearAllChildren()
				uiScale = Instance.new("UIScale")
				uiScale.Parent = folder

				if v55.tool then
					folder.Size = UDim2.fromOffset(v28 - 16, v28 - 16)
					ToolIcon.voxelImage(ToolTemplates:FindFirstChild(v55.tool), folder)
				else
					local v58 = math.floor(v28 * (QuestIcons.RENDERED and 0.64 or 0.58))
					folder.Size = UDim2.fromOffset(v58, v58)
					QuestIcons.draw(folder, v55.icon, backgroundColor)
				end

				for _, guiObject in folder:GetDescendants() do
					if guiObject:IsA("GuiObject") then
						guiObject.ZIndex = 2
					end
				end

				if not still then
					uiScale.Scale = 0.8
					TweenService:Create(uiScale, TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Scale = 1
					}):Play()
				end
			end

			fill.BackgroundColor3 = backgroundColor
			local text2 = ""

			for _, v59 in QuestData.CATS do
				if v59.id == v55.cat then
					text2 = v59.title
				end
			end

			v30.Text = text2
			v30.TextColor3 = backgroundColor:Lerp(Style.WHITE, 0.35)
			v46.Text = string.upper(v55.name)
			v47.Text = Style.thousands(pays(v55)) .. " XP" -- inferred equivalent call
			v48.Text = Style.thousands(v55.scrap or 0)
			local v59 = progress(v55) -- inferred equivalent call
			local v60 = locked(v55) -- inferred equivalent call
			local v61 = v55.goal <= v59
			local v62 = looksWaiting(v55) -- inferred equivalent call
			fill3.Size = UDim2.fromScale(v59 / v55.goal, 1)

			if v61 then
				if v62 then
					backgroundColor = Style.HAZARD
				else
					backgroundColor = Style.GOOD
				end
			end

			fill3.BackgroundColor3 = backgroundColor
			local v63

			if v61 then
				v63 = Style.paint(v62 and "DONE" or "CLAIMED", Style.GOOD)
			elseif v60 then
				v63 = Style.paint(lockWord(v55), color6) -- inferred equivalent call
			else
				v63 = Style.paint(
					string.format("%s / %s", Style.thousands((math.floor(v59))), Style.thousands(v55.goal)),
					Style.WHITE
				)
			end

			local v64 = tracked(v55) and not v61 -- inferred equivalent call
			v50.Text = v63 .. (not v64 and "" or "   " .. Style.paint("TRACKED", Style.HAZARD)) .. ((not v55.tag or v61) and "" or "   " .. Style.paint(Style.escape(v55.tag), Style.HAZARD))

			v51 = v62 or not (v61 or v60)
			local v65

			if v62 then
				v65 = v.claim
			elseif v51 then
				v65 = if v64 then v.untrack else v.track
			else
				v65 = v.off
			end

			action.Image = v65.image
			fill4.Visible = v51 and not v62
			fill4.BackgroundColor3 = v65.words
			v52.Text = v62 and "CLAIM" or v61 and "CLAIMED" or v60 and "LOCKED" or v64 and "UNTRACK" or "TRACK"
			local textColor

			if v61 and not v62 then
				textColor = Style.GOOD
			elseif v60 and not v62 then
				textColor = color6
			else
				textColor = v65.words
			end

			v52.TextColor3 = textColor

			if v62 then
				if v12[v55.id] == nil then
					v62 = not still
				else
					v62 = false
				end
			end

			if v62 and not v54 then
				v54 = TweenService:Create(
					punch,
					TweenInfo.new(0.55, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
					{ Scale = 1.05 }
				)
				v54:Play()
			elseif not v62 and v54 then
				v54:Cancel()
				v54 = nil
				punch.Scale = 1
			end
		end

		fn5 = function(p: number)
			v9 = p

			for _, guiObject in cards:GetChildren() do
				if guiObject:IsA("GuiObject") then
					guiObject:Destroy()
				end
			end

			table.clear(v11)
			v10 = nil
			local quests = v8[p].quests
			local v55 = 8
			local count2 = 0
			local v56 = nil
			local v57 = nil

			for _, v58 in QuestData.CATS do
				local quests2 = {}
				local total = 0

				for _, quest in quests do
					if quest.cat ~= v58.id then
						continue
					end

					table.insert(quests2, quest)
					total += progress(quest) >= quest.goal and 1 or 0 -- inferred equivalent call
				end

				if not (#quests2 > 0) then
					continue
				end

				local v59 = QuestIcons.COLOR[v58.id] or Style.STEEL_LIGHT
				text(cards, v58.id .. "Head", v58.title, math.floor(v2 * 16), 14, v55, v22 // 2, v25, {
					color = v59:Lerp(Style.WHITE, 0.25),
					outline = 2
				})
				text(
					cards,
					v58.id .. "Done",
					string.format("%d / %d", total, #quests2),
					math.floor(v2 * 13),
					v22 // 2 + 12,
					v55,
					v22 - v22 // 2 - 2,
					v25,
					{ color = Style.MUTED, ax = Enum.TextXAlignment.Right, outline = 2 }
				)
				local fill = Style.fill(
					cards,
					v58.id .. "Rule",
					v59,
					UDim2.fromOffset(v22, 2),
					UDim2.fromOffset(12, v55 + v25 - 3)
				)
				fill.BackgroundTransparency = 0.45

				local v60 = v55 + (v25 + 6)

				for k, v61 in quests2 do
					count2 += 1
					buildCard(v61, 12 + (k - 1) % 2 * (v23 + 12), v60, count2)
					v56 = v56 or v61

					if not v57 and claimable(v61) then -- inferred equivalent call
						v57 = v61
					end

					if k % 2 == 0 or k == #quests2 then
						v60 += v24 + 12
					end
				end

				v55 = v60 + 4
			end

			cards.CanvasSize = UDim2.fromOffset(0, v55 + 12)
			cards.CanvasPosition = Vector2.zero
			select(v57 or v56)
			paintTabs()
			PadMenus.reseat()
		end

		local function cardLanded(p)
			local punch2 = p.button:FindFirstChild("Punch")

			if punch2 and punch2:IsA("UIScale") then
				punch2.Scale = 0.88
				TweenService:Create(punch2, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Scale = 1
				}):Play()
			end

			local tick2 = p.emblem:FindFirstChild("Tick")

			if tick2 then
				local uiScale2 = Instance.new("UIScale")
				uiScale2.Scale = 0
				uiScale2.Parent = tick2
				TweenService:Create(uiScale2, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Scale = 1
				}):Play()
			end
		end

		local function claimPaid(p, xp, scrap)
			local v55 = v12[p]

			if not v55 then
				return
			end

			v55.paid = true
			local quest2 = nil
			local tier = nil

			for _, v58 in v8 do
				for _, quest in v58.quests do
					if quest.id ~= p then
						continue
					end

					if quest.needs then
						quest2 = quest
						tier = "bonus"
					else
						tier = v58.id
						quest2 = quest
					end
				end
			end

			local function landed() -- 1 equivalent call inferred from this helper
				v12[p] = nil
				releaseScrap(v55) -- inferred equivalent call

				if not v5 then
					v13 = true

					return
				end

				local v58 = v11[p]

				if v58 then
					v58.redraw(false)
					cardLanded(v58)
				end

				paintTabs()
				fn6()
			end

			if not quest2 then
				landed() -- inferred equivalent call
				error("[Quests] paid quest " .. tostring(p) .. " is not on the lists")
			end

			local QuestClaimShow = require(script.Parent:WaitForChild("QuestClaimShow"))
			QuestClaimShow.play(data.playerGui, {
				quest = quest2,
				tier = tier,
				xp = xp,
				scrap = scrap,
				from = function()
					local v58 = v11[p]
					return if v5 and v58 then v58.emblem else nil
				end,
				scrapPlate = box,
				levelPlate = nil,
				drawTick = tick,
				landed = landed,
				scrapIn = function()
					releaseScrap(v55) -- inferred equivalent call
				end
			})
		end

		local function refresh() -- 1 equivalent call inferred from this helper
			for _, v55 in v11 do
				v55.redraw(false)
			end

			paintTabs()
			fn6()
			paintScrap() -- inferred equivalent call
		end
		player.AttributeChanged:Connect(function(value: string)
			if value == "QuestDay" or value == "QuestWeek" or value == "QuestOutDaily" or value == "QuestOutWeekly" then
				v8 = QuestData.sections(player)
				v9 = math.min(v9, #v8)

				if v5 then
					fn5(v9)
				else
					v13 = true
				end
			elseif
				value == "QuestTrack"
				or value == "QuestClaim"
				or value == "Level"
				or value == "Scrap"
				or string.sub(value, 1, 6) == "Quest_"
			then
				if v5 then
					refresh() -- inferred equivalent call
				else
					v13 = true
				end
			end
		end)

		if not still then
			task.spawn(function()
				ReplicatedStorage:WaitForChild("Game"):WaitForChild("Remotes"):WaitForChild("QuestAction").OnClientEvent:Connect(function(p, p2, xp, scrap)
					if p == "paid" then
						claimPaid(p2, xp, scrap)
					end
				end)
			end)
		end

		local v55 = false
		fn = function()
			if not v55 or v13 then
				local v56 = not v55 and 1 or v9

				if not v55 then
					for k, v58 in v8 do
						for _, quest in v58.quests do
							if claimable(quest) then -- inferred equivalent call
								v56 = k
								break
							end
						end

						if v56 ~= 1 then
							break
						end
					end
				end

				v55 = true
				v13 = false
				fn5(v56)
			end

			paintScrap() -- inferred equivalent call
			paintTabs()

			if not still then
				count += 1
				local v56 = count
				task.spawn(function()
					while count == v56 and v5 do
						paintTabs()
						task.wait(30)
					end
				end)
			end
		end
		fn2 = function()
			count += 1
		end
		fn3 = function()
			if v10 and v11[v10.id] then
				return v11[v10.id].button
			end

			return v17[v9] and v17[v9].button
		end

		fn4 = function(p: number)
			fn5((v9 - 1 + p) % #v8 + 1)
		end
	end

	local count = 0
	local tweens = {}
	local mouseIconEnabled = true
	local udim = UDim2.new()

	local v6 = false
	local fn5
	local function toggle()
		v5 = not v5

		if not v5 then
			v6 = false
		end

		if v5 then
			if not v3 then
				build()
			end

			if Armory.close then
				Armory.close()
			end

			for _, childName in { "Store", "Outfits" } do
				local module = require(script.Parent:WaitForChild(childName))

				if module.close then
					module.close()
				end
			end

			mouseIconEnabled = UserInputService.MouseIconEnabled
			UserInputService.MouseIconEnabled = true
		else
			UserInputService.MouseIconEnabled = mouseIconEnabled
			fn2()
		end

		count += 1
		local v7 = count

		for _, v8 in tweens do
			v8:Cancel()
		end

		table.clear(tweens)
		local function tween(instance, duration: number, p, p2, goal) -- 6 equivalent calls inferred from this helper
			local tween2 = TweenService:Create(instance, TweenInfo.new(duration, p, p2), goal)
			table.insert(tweens, tween2)
			tween2:Play()
			return tween2
		end

		if v5 then
			if not layer.Enabled then
				room.ImageTransparency = 1
				room.BackgroundTransparency = 1
				v4.BackgroundTransparency = 1
				parent2.Position = udim + UDim2.fromScale(0, 0.22)
			end

			layer.Enabled = true
			layer2.Enabled = true
			fn()
			tween(room, 0.256, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, { -- inferred equivalent call
				ImageTransparency = 0,
				BackgroundTransparency = 0
			})
			tween(v4, 0.256, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, { -- inferred equivalent call
				BackgroundTransparency = 0.75
			})
			tween(parent2, 0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, { -- inferred equivalent call
				Position = udim
			})
		else
			tween(room, 0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.In, { -- inferred equivalent call
				ImageTransparency = 1,
				BackgroundTransparency = 1
			})
			tween(v4, 0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.In, { -- inferred equivalent call
				BackgroundTransparency = 1
			})
			tween(parent2, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In, { -- inferred equivalent call
				Position = udim + UDim2.fromScale(0, 0.22)
			}).Completed:Once(function()
				if count == v7 then
					layer.Enabled = false
					layer2.Enabled = false
				end
			end)
		end

		data.setMenu(v5)

		if v5 then
			PadMenus.open("quests", parent, fn5, {
				first = function()
					return fn3()
				end,
				tab = function(p: number)
					fn4(p)
				end
			})
		else
			PadMenus.close("quests")
		end
	end
	fn5 = function()
		local v7 = v6
		toggle()

		if v7 and Armory.toggle then
			Armory.toggle()
		end
	end
	Quests.leave = fn5
	Quests.toggle = toggle
	function Quests.isOpen()
		return v5
	end

	function Quests.open(flag: boolean?)
		if not v5 then
			toggle()
		end

		v6 = flag == true
	end
	function Quests.close()
		if v5 then
			toggle()
		end
	end

	data.onTeam(function(p: string?)
		if p ~= nil and v5 then
			toggle()
		end
	end)
	data.onDead(function(flag: boolean)
		if flag and v5 then
			toggle()
		end
	end)
end

return Quests