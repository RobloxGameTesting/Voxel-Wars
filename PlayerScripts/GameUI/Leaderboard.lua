local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Viewmodel = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("Viewmodel"))
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local Style = require(script.Parent:WaitForChild("Style"))

local v = {
	{ key = "rank", caption = "#", w = 26 },
	{ key = "level", caption = "LV", w = 34 },
	{ key = "name", caption = "NAME", w = 178 },
	{ key = "kills", caption = "K", w = 42 },
	{ key = "deaths", caption = "D", w = 42 },
	{ key = "assists", caption = "A", w = 42 },
	{ key = "score", caption = "SCORE", w = 74 }
}
local total = 16
local Leaderboard = {}

local v2 = { "Reds", "Blues" }

for _, v3 in v do
	total += v3.w
end

local vector2 = Vector2.new(total * 2 + 20, 414)

local v3 = vector2.X / 4

local color = Color3.fromRGB(16, 16, 19)

local function robot(fill)
	local frame = Style.frame(fill, "Bot", UDim2.fromOffset(16, 16))
	local v4 = {}
	local function bit(p: string, p2: number, p3: number, p4: number, p5: number, flag: boolean, p6: number?)
		local fill2 = Style.fill
		local v5 = if flag then color else Style.MUTED
		local parent = fill2(frame, p, v5, UDim2.fromOffset(p4, p5), UDim2.fromOffset(p2, p3))

		if p6 then
			local uiCorner = Instance.new("UICorner")
			uiCorner.CornerRadius = UDim.new(0, p6)
			uiCorner.Parent = parent
		end

		parent.ZIndex = flag and 3 or 2

		if not flag then
			table.insert(v4, parent)
		end

		return parent
	end

	bit("Ball", 6, 0, 4, 4, false, 2)
	local fill2 = Style.fill(frame, "Stem", Style.MUTED, UDim2.fromOffset(2, 3), UDim2.fromOffset(7, 3))

	fill2.ZIndex = 2

	table.insert(v4, fill2)

	bit("Head", 2, 5, 12, 10, false, 3)
	local fill3 = Style.fill(frame, "EarL", Style.MUTED, UDim2.fromOffset(2, 4), UDim2.fromOffset(0, 8))

	fill3.ZIndex = 2

	table.insert(v4, fill3)
	local fill4 = Style.fill(frame, "EarR", Style.MUTED, UDim2.fromOffset(2, 4), UDim2.fromOffset(14, 8))

	fill4.ZIndex = 2

	table.insert(v4, fill4)
	local fill_2 = Style.fill(frame, "EyeL", color, UDim2.fromOffset(2, 3), UDim2.fromOffset(5, 8))

	fill_2.ZIndex = 3
	local fill_3 = Style.fill(frame, "EyeR", color, UDim2.fromOffset(2, 3), UDim2.fromOffset(9, 8))

	fill_3.ZIndex = 3
	local fill_4 = Style.fill(frame, "Mouth", color, UDim2.fromOffset(6, 1), UDim2.fromOffset(5, 12))

	fill_4.ZIndex = 3

	return frame, v4
end

Leaderboard.robot = robot
Leaderboard.BOT_ICON = 16
Leaderboard.BOT_GAP = 5

local function num(instance, attributeName: string) -- 10 equivalent calls inferred from this helper
	local attribute = instance:GetAttribute(attributeName)
	return if type(attribute) == "number" then attribute else 0
end

local function isTeam(p): boolean -- 2 equivalent calls inferred from this helper
	return p == "Reds" or p == "Blues"
end

function Leaderboard.collect(p)
	local result = {}

	for _, player in Players:GetPlayers() do
		local name = player.Team and player.Team.Name

		if not isTeam(name) then -- inferred equivalent call
			continue
		end

		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		local v4 = {
			name = player.DisplayName,
			team = name,
			kills = num(player, "Takedowns"), -- inferred equivalent call
			deaths = num(player, "Deaths"), -- inferred equivalent call
			assists = num(player, "Supports"), -- inferred equivalent call
			score = num(player, "Score"), -- inferred equivalent call
			level = num(player, "Level"), -- inferred equivalent call
			bot = false,
			me = player == p,
			alive = humanoid ~= nil and humanoid.Health > 0,
			player = player
		}
		table.insert(result, v4)
	end

	local bots = ReplicatedStorage:FindFirstChild("Bots")
	local roster = bots and bots:FindFirstChild("Roster")

	if roster then
		for _, child in roster:GetChildren() do
			local team = child:GetAttribute("Team")
			local name = child:GetAttribute("Name")

			if not isTeam(team) or type(name) ~= "string" or child:GetAttribute("Leaving") then -- inferred equivalent call
				continue
			end

			local v4 = {
				name = name,
				team = team,
				kills = num(child, "Takedowns"), -- inferred equivalent call
				deaths = num(child, "Deaths"), -- inferred equivalent call
				assists = num(child, "Supports"), -- inferred equivalent call
				score = num(child, "Score"), -- inferred equivalent call
				bot = true,
				me = false,
				alive = child:GetAttribute("Alive") == true,
				entry = child
			}
			table.insert(result, v4)
		end
	end

	table.sort(result, function(a, b): boolean
		if a.score ~= b.score then
			return a.score > b.score
		end

		if a.kills ~= b.kills then
			return a.kills > b.kills
		end

		if a.deaths == b.deaths then
			return a.name < b.name
		end

		return a.deaths < b.deaths
	end)

	return result
end

local function makeRow(p, p2: number)
	local fill = Style.fill(
		p.frame,
		"Row" .. p2,
		Style.PANEL,
		UDim2.new(1, 0, 0, 24),
		UDim2.fromOffset(0, (p2 - 1) * 26 + 62)
	)
	fill.BackgroundTransparency = p2 % 2 == 0 and 0.3 or 0.15
	local fill2 = Style.fill(fill, "Edge", Style.HAZARD, UDim2.new(0, 4, 1, 0))
	fill2.Visible = false
	local total2 = 8
	local cells = {}
	local v4 = 0

	for _, v5 in v do
		if v5.key == "name" then
			v4 = total2
		end

		local label = Style.label
		local key = v5.key
		local v6 = v5.key == "score" and 16 or 15
		local v7

		if v5.key == "name" then
			v7 = Style.FONT_BODY
		else
			v7 = Style.FONT
		end

		local v8 = label(fill, key, "", v6, v7, 0)
		v8.AutomaticSize = Enum.AutomaticSize.None
		v8.Size = UDim2.new(0, v5.w, 1, 0)
		v8.Position = UDim2.fromOffset(total2, 0)
		local textXAlignment

		if v5.key == "name" then
			textXAlignment = Enum.TextXAlignment.Left
		else
			textXAlignment = Enum.TextXAlignment.Center
		end

		v8.TextXAlignment = textXAlignment
		v8.TextTruncate = Enum.TextTruncate.AtEnd
		v8.RichText = v5.key == "name"
		v8.AutoLocalize = v5.key ~= "name"
		local textColor

		if v5.key == "rank" then
			textColor = Style.DIM
		elseif v5.key == "level" then
			textColor = Style.MUTED
		elseif v5.key == "score" then
			textColor = Style.HAZARD
		else
			textColor = Style.WHITE
		end

		v8.TextColor3 = textColor
		cells[v5.key] = v8
		total2 += v5.w
	end

	local bot, botParts = robot(fill)
	bot.AnchorPoint = Vector2.new(0, 0.5)
	bot.Position = UDim2.new(0, v4, 0.5, 0)
	bot.Visible = false
	local uiPadding = Instance.new("UIPadding")
	uiPadding.Parent = cells.name
	local row = {
		frame = fill,
		edge = fill2,
		cells = cells,
		bot = bot,
		botParts = botParts,
		namePad = uiPadding
	}
	p.rows[p2] = row
	return row
end

local function buildSide(folder, value: string, p: number)
	local frame = Style.frame(folder, value, UDim2.fromOffset(total, 374), UDim2.fromOffset(p, 40))
	local box = Style.box(frame, "Header", Style.PANEL, UDim2.new(1, 0, 0, 40), 3, 2)
	box.BackgroundTransparency = 0.05
	Style.fill(box, "Band", Style.teamColor(value), UDim2.new(0, 6, 1, 0))
	local emblem = Style.emblem(box, value, 24)
	emblem.Position = UDim2.fromOffset(16, 8)
	local label = Style.label(box, "Team", string.upper(value), 22, Style.FONT, 1.5)
	label.TextColor3 = Style.teamText(value)
	label.AnchorPoint = Vector2.new(0, 0.5)
	label.Position = UDim2.new(0, 48, 0.5, 0)
	local label2 = Style.label(box, "Kills", "", 14, Style.FONT, 0)
	label2.TextColor3 = Style.MUTED
	label2.AnchorPoint = Vector2.new(1, 0.5)
	label2.Position = UDim2.new(1, -96, 0.5, 0)
	local label3 = Style.label(box, "Score", "0", 22, Style.FONT, 1.5)
	label3.TextColor3 = Style.HAZARD
	label3.AnchorPoint = Vector2.new(1, 0.5)
	label3.Position = UDim2.new(1, -12, 0.5, 0)

	local frame2 = Style.frame(frame, "Captions", UDim2.new(1, 0, 0, 22), UDim2.fromOffset(0, 40))

	frame2.BackgroundColor3 = Style.PANEL
	frame2.BackgroundTransparency = 0.12
	local total2 = 8

	for _, v4 in v do
		local label4 = Style.label(frame2, v4.caption, v4.caption, 12, Style.FONT, 0)
		label4.AutomaticSize = Enum.AutomaticSize.None
		label4.Size = UDim2.fromOffset(v4.w, 22)
		label4.Position = UDim2.fromOffset(total2, 0)
		label4.TextColor3 = Style.WHITE
		local textXAlignment

		if v4.key == "name" then
			textXAlignment = Enum.TextXAlignment.Left
		else
			textXAlignment = Enum.TextXAlignment.Center
		end

		label4.TextXAlignment = textXAlignment
		total2 += v4.w
	end

	local side = { frame = frame, kills = label2, score = label3, rows = {} }

	for i = 1, 12 do
		local row = makeRow(side, i)
		row.frame.Visible = false
	end

	return side
end

function Leaderboard.mount(p, p2)
	local player = p.player
	local title = p2 and p2.title or function(): string
		return "SKIRMISH"
	end

	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

	local layer = Style.layer(p.playerGui, "GameBoard", 8)

	layer.Enabled = false
	local region = Style.region(layer, "Leaderboard", Vector2.new(0.5, 0.5), Vector2.zero, vector2)
	local fit = Style.fit(region, vector2)
	region.Visible = false

	local folder = Style.frame(region, "Board", UDim2.fromScale(1, 1))

	local frame = Style.frame(folder, "Heading", UDim2.new(1, 0, 0, 32))
	local frame2 = Style.frame(frame, "Left", UDim2.fromOffset(0, 32), UDim2.fromOffset(2, 0))
	frame2.AutomaticSize = Enum.AutomaticSize.X
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.Padding = UDim.new(0, 12)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = frame2
	local label = Style.label(frame2, "Title", "", 22, Style.FONT, 1.5)
	label.TextColor3 = Style.HAZARD
	label.LayoutOrder = 1
	local label2 = Style.label(frame2, "Caption", "SCOREBOARD", 16, Style.FONT, 1.5)
	label2.TextColor3 = Style.MUTED
	label2.LayoutOrder = 2

	if not Style.isTouch() then
		local frame3 = Style.frame(
			frame,
			"Hint",
			UDim2.fromOffset(0, 20),
			UDim2.new(1, -2, 0.5, 0),
			Vector2.new(1, 0.5)
		)
		frame3.AutomaticSize = Enum.AutomaticSize.X
		local uiListLayout2 = Instance.new("UIListLayout")
		uiListLayout2.FillDirection = Enum.FillDirection.Horizontal
		uiListLayout2.VerticalAlignment = Enum.VerticalAlignment.Center
		uiListLayout2.Padding = UDim.new(0, 6)
		uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
		uiListLayout2.Parent = frame3
		local label3 = Style.label(frame3, "Hold", "HOLD", 13, Style.FONT, 0)
		label3.TextColor3 = Style.DIM
		label3.LayoutOrder = 1
		local key = Style.key(frame3, "TAB", 18)
		key.LayoutOrder = 2
	end

	local v4 = {
		Reds = buildSide(folder, "Reds", 0),
		Blues = buildSide(folder, "Blues", total + 20)
	}

	local frame3 = Style.frame(folder, "Lobby", UDim2.new(1, 0, 0, 22))
	frame3.Visible = false
	local fill = Style.fill(frame3, "Plate", Style.PANEL, UDim2.new(1, 0, 0, 22))
	fill.BackgroundTransparency = 0.12
	local label3 = Style.label(fill, "Caption", "", 12, Style.FONT, 0)
	label3.AutomaticSize = Enum.AutomaticSize.None
	label3.Size = UDim2.new(1, -16, 1, 0)
	label3.Position = UDim2.fromOffset(8, 0)
	label3.TextXAlignment = Enum.TextXAlignment.Left
	label3.TextColor3 = Style.WHITE

	local v5 = {}
	local function lobbyCell(k: number)
		local v6 = (k - 1) % 4
		local v7 = (k - 1) // 4
		local fill2 = Style.fill(
			frame3,
			"Cell" .. k,
			Style.PANEL,
			UDim2.fromOffset(v3 - 4, 24),
			UDim2.fromOffset(v6 * v3, v7 * 26 + 22)
		)
		fill2.BackgroundTransparency = v7 % 2 == 0 and 0.15 or 0.3
		local fill3 = Style.fill(fill2, "Edge", Style.HAZARD, UDim2.new(0, 4, 1, 0))
		fill3.Visible = false
		local label4 = Style.label(fill2, "level", "", 15, Style.FONT, 0)
		label4.AutomaticSize = Enum.AutomaticSize.None
		label4.Size = UDim2.fromOffset(34, 24)
		label4.Position = UDim2.fromOffset(8, 0)
		label4.TextColor3 = Style.MUTED
		local label5 = Style.label(fill2, "name", "", 15, Style.FONT_BODY, 0)
		label5.AutomaticSize = Enum.AutomaticSize.None
		label5.Size = UDim2.fromOffset(v3 - 4 - 50, 24)
		label5.Position = UDim2.fromOffset(46, 0)
		label5.TextXAlignment = Enum.TextXAlignment.Left
		label5.TextTruncate = Enum.TextTruncate.AtEnd
		label5.RichText = true
		label5.AutoLocalize = false
		local v8 = { frame = fill2, edge = fill3, level = label4, name = label5 }
		v5[k] = v8
		return v8
	end

	local v6 = {}
	local v7 = -1
	local function gatherFade()
		local v8 = #v4.Reds.rows + #v4.Blues.rows + #v5

		if v8 == v7 then
			return
		end

		v7 = v8
		table.clear(v6)

		for _, descendant in folder:GetDescendants() do
			if descendant:IsA("GuiObject") then
				table.insert(v6, { descendant, "BackgroundTransparency", descendant.BackgroundTransparency })
			end

			if descendant:IsA("TextLabel") then
				table.insert(v6, { descendant, "TextTransparency", descendant.TextTransparency })
			elseif descendant:IsA("UIStroke") then
				table.insert(v6, { descendant, "Transparency", descendant.Transparency })
			end
		end
	end

	local function fade(p3: number) -- 3 equivalent calls inferred from this helper
		for _, v8 in v6 do
			v8[1][v8[2]] = v8[3] + (1 - v8[3]) * p3
		end
	end

	local v8 = ""
	local function placeSides()
		local v9 = (player.Team and player.Team.Name) == "Blues" and "Blues" or "Reds"

		if v9 == v8 then
			return
		end

		v8 = v9
		local v10 = v9 == "Reds" and "Blues" or "Reds"
		v4[v9].frame.Position = UDim2.fromOffset(0, 40)
		v4[v10].frame.Position = UDim2.fromOffset(total + 20, 40)
	end

	local function draw()
		placeSides()
		label.Text = title()
		local v9 = {}
		local v10 = {}
		local v11 = {}

		for _, v12 in v2 do
			v9[v12] = 0
			v10[v12] = 0
			v11[v12] = 0
		end

		for _, v12 in Leaderboard.collect(player) do
			local v13 = v4[v12.team]
			local v14 = v9[v12.team] + 1
			v9[v12.team] = v14
			local team = v12.team
			v10[team] += v12.score
			local team2 = v12.team
			v11[team2] += v12.kills
			local v15 = v13.rows[v14] or makeRow(v13, v14)
			v15.frame.Visible = true
			v15.edge.Visible = v12.me
			local cells = v15.cells
			cells.rank.Text = tostring(v14)
			cells.level.Text = not (v12.level and v12.level > 0) and "" or tostring(v12.level)
			cells.name.Text = Style.escape(v12.name)
			v15.bot.Visible = v12.bot
			v15.namePad.PaddingLeft = UDim.new(0, v12.bot and 21 or 0)

			if v12.bot then
				local backgroundColor

				if v12.alive then
					backgroundColor = Style.MUTED
				else
					backgroundColor = Style.DIM
				end

				for _, botPart in v15.botParts do
					botPart.BackgroundColor3 = backgroundColor
				end
			end

			local name = cells.name
			local textColor

			if v12.me then
				textColor = Style.HAZARD
			else
				textColor = if v12.alive then Style.WHITE else Style.DIM
			end

			name.TextColor3 = textColor
			cells.kills.Text = tostring(v12.kills)
			cells.deaths.Text = tostring(v12.deaths)
			cells.assists.Text = tostring(v12.assists)
			cells.score.Text = Style.thousands(v12.score)

			for _, v16 in { "kills", "deaths", "assists" } do
				local cell = cells[v16]
				local textColor2

				if v12.alive or v12.me then
					textColor2 = Style.WHITE
				else
					textColor2 = Style.MUTED
				end

				cell.TextColor3 = textColor2
			end
		end

		local v12 = math.max(v9.Reds, v9.Blues)
		local v13 = not (v12 > 12) and 26 or 312 // v12

		for _, v14 in v2 do
			local v15 = v4[v14]

			for k, row in v15.rows do
				row.frame.Size = UDim2.new(1, 0, 0, v13 - 2)
				row.frame.Position = UDim2.fromOffset(0, (k - 1) * v13 + 62)
			end

			for i = v9[v14] + 1, #v15.rows do
				v15.rows[i].frame.Visible = false
			end

			v15.kills.Text = v11[v14] .. " K"
			v15.score.Text = Style.thousands(v10[v14])
		end

		local v14 = {}

		for _, v15 in Players:GetPlayers() do
			local name = v15.Team and v15.Team.Name

			if name ~= "Reds" and name ~= "Blues" then
				table.insert(v14, v15)
			end
		end

		table.sort(v14, function(a, b): boolean
			return a.DisplayName < b.DisplayName
		end)

		frame3.Visible = #v14 > 0
		frame3.Position = UDim2.fromOffset(0, v12 * v13 + 102 + 10)
		frame3.Size = UDim2.new(1, 0, 0, math.ceil(#v14 / 4) * 26 + 22)
		label3.Text = "IN LOBBY  " .. #v14

		for k, v15 in v14 do
			local v16 = v5[k] or lobbyCell(k)
			v16.frame.Visible = true
			v16.edge.Visible = v15 == player
			local v17 = num(v15, "Level") -- inferred equivalent call
			v16.level.Text = not (v17 > 0) and "" or tostring(v17)
			v16.name.Text = Style.escape(v15.DisplayName)
			local name = v16.name
			local textColor

			if v15 == player then
				textColor = Style.HAZARD
			else
				textColor = Style.WHITE
			end

			name.TextColor3 = textColor
		end

		for i = #v14 + 1, #v5 do
			v5[i].frame.Visible = false
		end
	end

	local v9 = false
	local v10 = false
	local v11 = false
	local function fn() end

	local modal = Instance.new("TextButton")
	modal.Name = "Modal"
	modal.Text = ""
	modal.BackgroundTransparency = 1
	modal.Size = UDim2.fromOffset(1, 1)
	modal.Modal = true
	modal.Parent = region
	local v12 = true
	local function setOpen(flag: boolean)
		if flag == v11 then
			return
		end

		v11 = flag
		Viewmodel.pointerFree.Leaderboard = flag and true or nil

		if flag then
			v12 = UserInputService.MouseIconEnabled
			UserInputService.MouseIconEnabled = true
		else
			UserInputService.MouseIconEnabled = Viewmodel.cursorAfterMenu(v12)
		end

		if flag then
			draw()
			gatherFade()
			fade(1) -- inferred equivalent call
			layer.Enabled = true
			region.Visible = true
			local now = os.clock()
			Style.animate(region, function(_, p3): boolean
				local easeOut = Style.easeOut((p3 - now) / 0.12)
				fade(1 - easeOut) -- inferred equivalent call
				fit(0.97 + 0.03 * easeOut)
				return easeOut < 1
			end)
		else
			Style.stop(region)
			region.Visible = false
			layer.Enabled = false
			fade(0) -- inferred equivalent call
			fit(1)
		end
	end
	local function apply() -- 6 equivalent calls inferred from this helper
		setOpen(v9 or v10)
		fn()
	end

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if input.KeyCode == Enum.KeyCode.Tab and not gameProcessed then
			v9 = true
			apply() -- inferred equivalent call
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.Tab then
			v9 = false
			apply() -- inferred equivalent call
		end
	end)

	UserInputService.WindowFocusReleased:Connect(function()
		v9 = false
		apply() -- inferred equivalent call
	end)

	local PadMenus = require(script.Parent:WaitForChild("PadMenus"))
	PadMenus.onView(function()
		v10 = not v10
		apply() -- inferred equivalent call
	end)

	player:GetPropertyChangedSignal("Team"):Connect(function()
		if player.Team == nil then
			v10 = false
		end

		apply() -- inferred equivalent call
	end)

	if UserInputService.TouchEnabled then
		local Icon = require(ReplicatedStorage:WaitForChild("TopbarPlus"):WaitForChild("Icon"))
		local v13 = Icon.new()
		v13:setName("Leaderboard")
		v13:setImage("rbxassetid://111427172295395")
		v13:setCaption("Leaderboard")
		local v14 = false
		fn = function()
			v14 = true

			if v10 and not v13.isSelected then
				v13:select()
			elseif not v10 and v13.isSelected then
				v13:deselect()
			end

			v14 = false
		end
		v13.toggled:Connect(function(flag: boolean)
			if v14 or flag == v10 then
				return
			end

			v10 = flag
			apply() -- inferred equivalent call
		end)
	end

	task.spawn(function()
		while true do
			task.wait(0.25)

			if not v11 then
				continue
			end

			debug.profilebegin("LB.draw")
			draw()
			debug.profileend()
		end
	end)
end

return Leaderboard