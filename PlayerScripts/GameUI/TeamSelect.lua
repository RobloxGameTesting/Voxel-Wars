game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Viewmodel = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("Viewmodel"))
local Teams = game:GetService("Teams")
local UserInputService = game:GetService("UserInputService")

local Style = require(script.Parent:WaitForChild("Style"))
local Game = ReplicatedStorage:WaitForChild("Game")
local GameConfig = require(Game:WaitForChild("GameConfig"))
local Hardpoint = require(Game:WaitForChild("Hardpoint"))

local TeamSelect = {}

local v = { "Reds", "Blues" }

local v2 = 230
local v3 = 120

local function orbitSize() -- 1 equivalent call inferred from this helper
	if #Hardpoint.POINTS > 1 then
		v2 = 340
		v3 = 200
	else
		v2 = 230
		v3 = 120
	end
end

orbitSize() -- inferred equivalent call
local MapSelect = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("MapSelect"))
MapSelect.onChange(orbitSize, 20)
Hardpoint.onPointsChange(orbitSize)

local function num(value) -- 9 equivalent calls inferred from this helper
	return if type(value) == "number" then value else 0
end

local function other(p: string): string -- 2 equivalent calls inferred from this helper
	return if p == "Reds" then "Blues" else "Reds"
end

local function humans(childName: string) -- 2 equivalent calls inferred from this helper
	local team = Teams:FindFirstChild(childName)

	if team and team:IsA("Team") then
		return (team:GetPlayers())
	end

	return {}
end

local function botCount(attributeName: string)
	local bots = ReplicatedStorage:FindFirstChild("Bots")
	local roster = bots and bots:FindFirstChild("Roster")
	local count = 0

	if not roster then
		return count
	end

	for _, child in roster:GetChildren() do
		if child:GetAttribute("Team") ~= attributeName or child:GetAttribute("Leaving") then
			continue
		end

		count += 1
	end

	return count
end

function TeamSelect.mount(data)
	local player = data.player
	local pickTeam = Game:WaitForChild("Remotes"):WaitForChild("PickTeam")

	local layer = Style.layer(data.playerGui, "TeamSelect", 12, true)
	layer.Enabled = false
	local fill = Style.fill(layer, "Shade", Style.INK, UDim2.fromScale(1, 1))
	fill.BackgroundTransparency = 0.38
	fill.Active = true
	local modal = Instance.new("TextButton")
	modal.Name = "Modal"
	modal.Text = ""
	modal.BackgroundTransparency = 1
	modal.Size = UDim2.fromOffset(1, 1)
	modal.Modal = true
	modal.Parent = fill

	local region = Style.region(layer, "Picker", Vector2.new(0.5, 0.5), Vector2.zero, Vector2.new(602, 394))
	local fit = Style.fit(region, Vector2.new(602, 394))

	local box = Style.box(region, "Head", Style.STEEL, UDim2.new(1, 0, 0, 74), 3, 2)
	box.ClipsDescendants = true
	Style.tape(box, "Tape", UDim2.new(1, 0, 0, 6), 602, 16)
	local label_2 = Style.label(box, "Title", "CHOOSE YOUR SIDE", 30, Style.FONT, 0)
	label_2.Position = UDim2.fromOffset(16, 12)
	local label = Style.label(box, "Round", "", 14, Style.FONT_BODY, 0)
	label.TextColor3 = Style.MUTED
	label.Position = UDim2.fromOffset(17, 48)

	local label2 = Style.label(region, "Note", "", 15, Style.FONT, 1.5)
	label2.TextColor3 = Style.ORANGE
	label2.AnchorPoint = Vector2.new(0.5, 1)
	label2.Position = UDim2.new(0.5, 0, 1, 0)
	label2.Size = UDim2.new(1, 0, 0, 22)
	label2.AutomaticSize = Enum.AutomaticSize.None

	local v4 = false

	local function makeCard(value: string, k: number)
		local teamColor = Style.teamColor(value)
		local panel = Style.panel(region, "Card_" .. value, UDim2.fromOffset(290, 270), 3)
		panel.Position = UDim2.fromOffset((k - 1) * 312, 90)
		panel.BackgroundTransparency = 0.06
		panel.ClipsDescendants = true
		local uiStroke = panel:FindFirstChildOfClass("UIStroke")

		local fill2 = Style.fill(panel, "Band", Style.STEEL, UDim2.new(1, 0, 0, 56))
		Style.fill(fill2, "Edge", teamColor, UDim2.new(0, 6, 1, 0))
		local fill = Style.fill(fill2, "Tint", teamColor, UDim2.fromScale(1, 1))
		fill.BackgroundTransparency = 0.82
		local emblem = Style.emblem(fill2, value, 34)
		emblem.Position = UDim2.fromOffset(18, 11)
		local label3 = Style.label(fill2, "Name", string.upper(value), 30, Style.FONT, 1.5)
		label3.TextColor3 = Style.teamText(value)
		label3.Position = UDim2.fromOffset(62, 11)

		local label4 = Style.label(panel, "Points", "", 40, Style.FONT, 1.5)
		label4.RichText = true
		label4.Position = UDim2.fromOffset(18, 66)

		local box2 = Style.box(panel, "Holds", Style.HAZARD, UDim2.fromOffset(0, 22), 2, 1.5)
		box2.AutomaticSize = Enum.AutomaticSize.X
		box2.AnchorPoint = Vector2.new(1, 0)
		box2.Position = UDim2.new(1, -16, 0, 78)
		local uiPadding = Instance.new("UIPadding")
		uiPadding.PaddingLeft = UDim.new(0, 6)
		uiPadding.PaddingRight = UDim.new(0, 6)
		uiPadding.Parent = box2
		local label5 = Style.label(box2, "Text", "HOLDS THE POST", 14, Style.FONT, 0)
		label5.TextColor3 = Style.INK
		label5.Size = UDim2.fromOffset(0, 22)

		local label6 = Style.label(panel, "Counts", "", 16, Style.FONT, 0)
		label6.RichText = true
		label6.Position = UDim2.fromOffset(18, 122)

		local label7 = Style.label(panel, "Names", "", 14, Style.FONT_BODY, 0)
		label7.TextColor3 = Style.DIM
		label7.Position = UDim2.fromOffset(18, 148)
		label7.AutomaticSize = Enum.AutomaticSize.None
		label7.Size = UDim2.new(1, -36, 0, 54)
		label7.TextWrapped = true
		label7.TextXAlignment = Enum.TextXAlignment.Left
		label7.TextYAlignment = Enum.TextYAlignment.Top

		local button, buttonText = Style.button(
			panel,
			"Join",
			"JOIN " .. string.upper(value),
			Style.HAZARD,
			UDim2.new(1, -32, 0, 42),
			Style.INK,
			20
		)
		button.AnchorPoint = Vector2.new(0.5, 1)
		button.Position = UDim2.new(0.5, 0, 1, -14)

		local card = {
			frame = panel,
			stroke = uiStroke,
			points = label4,
			holds = box2,
			holdsText = label5,
			counts = label6,
			names = label7,
			button = button,
			buttonText = buttonText,
			open = true
		}

		button.MouseEnter:Connect(function()
			if card.open and not v4 then
				uiStroke.Color = Style.HAZARD
				uiStroke.Transparency = 0
				uiStroke.Thickness = 2.5
			end
		end)
		button.MouseLeave:Connect(function()
			uiStroke.Color = Color3.new(0, 0, 0)
			uiStroke.Transparency = 0.35
			uiStroke.Thickness = 1.5
		end)
		button.Activated:Connect(function()
			if not card.open or v4 then
				return
			end

			v4 = true
			label2.Text = ""
			buttonText.Text = "JOINING..."
			pickTeam:FireServer(value)

			task.delay(4, function()
				v4 = false
			end)
		end)
		return card
	end

	local v5 = {}

	for k, v6 in v do
		v5[v6] = makeCard(v6, k)
	end

	local function roundLine()
		local domination = Game:FindFirstChild("Domination")

		if not domination then
			return ""
		end

		local v6 = num(domination:GetAttribute("Round")) -- inferred equivalent call
		local phase = domination:GetAttribute("Phase")
		local v7 = "ROUND " .. math.max(v6, 1)

		if phase == "starting" then
			return v7 .. "  ·  ABOUT TO START"
		elseif phase == "over" then
			return v7 .. "  ·  ENDING, THE NEXT ONE IS ABOUT TO START"
		end

		if domination:GetAttribute("Overtime") == true then
			return v7 .. "  ·  OVERTIME"
		end

		local v8 = num(domination:GetAttribute("EndsAt")) - workspace:GetServerTimeNow() -- inferred equivalent call

		if domination:GetAttribute("GameMode") == "spawnraid" or domination:GetAttribute("GameMode") == "siege" then
			return v7 .. "  ·  " .. Style.clock(v8) .. " LEFT  ·  DESTROY THEIR SPAWNS"
		end

		if domination:GetAttribute("GameMode") == "breakthrough" then
			return v7 .. "  ·  " .. Style.clock(v8) .. " LEFT  ·  SECTOR " .. num(domination:GetAttribute("Sector")) .. " OF " .. num(domination:GetAttribute("Sectors")) -- inferred equivalent call
		else
			local v9 = domination:GetAttribute("GameMode") == "tdm" and " KILLS" or ""
			return v7 .. "  ·  " .. Style.clock(v8) .. " LEFT  ·  FIRST TO " .. num(domination:GetAttribute("Target")) .. v9 -- inferred equivalent call
		end
	end

	local function refresh()
		label.Text = roundLine()
		local domination = Game:FindFirstChild("Domination")

		for _, attributeName in v do
			local v6 = v5[attributeName]
			local v7 = humans(attributeName) -- inferred equivalent call
			local v8 = humans(other(attributeName)) -- inferred equivalent call
			local v9 = botCount(attributeName)
			v6.open = #v7 + 1 - #v8 <= GameConfig.TEAM_MAX_GAP
			local v10

			if domination then
				v10 = num(domination:GetAttribute(attributeName)) -- inferred equivalent call
			else
				v10 = 0
			end

			local v11

			if domination == nil then
				v11 = false
			else
				v11 = domination:GetAttribute("GameMode") == "spawnraid"
					or domination:GetAttribute("GameMode") == "siege"
			end

			local v12

			if domination == nil then
				v12 = false
			else
				v12 = domination:GetAttribute("GameMode") == "tdm"
			end

			local v13

			if domination and domination:GetAttribute("GameMode") == "breakthrough" then
				if domination:GetAttribute("Attackers") == attributeName then
					v10 = num(domination:GetAttribute("Tickets")) -- inferred equivalent call
					v13 = " TICKETS"
				else
					v10 = math.max(
						0,
						num(domination:GetAttribute("Sectors")) - num(domination:GetAttribute("Sector")) + 1 -- inferred equivalent call
					)

					if v10 == 1 then
						v13 = " SECTOR LEFT"
					else
						v13 = " SECTORS LEFT"
					end
				end
			else
				v13 = v11 and " SPAWNS" or v12 and " KILLS" or " PTS"
			end

			v6.points.Text = Style.paint(tostring(v10), Style.teamText(attributeName)) .. "<font size=\"16\" color=\"" .. Style.hex(Style.DIM) .. "\">" .. v13 .. "</font>"

			local letters = {}

			if domination and not (v11 or v12) then
				for k, v14 in Hardpoint.POINTS do
					if domination:GetAttribute(Hardpoint.attr("Holder", k)) == attributeName then
						table.insert(letters, v14.letter)
					end
				end
			end

			v6.holds.Visible = #letters > 0

			if #letters > 0 then
				v6.holdsText.Text = #Hardpoint.POINTS == 1 and "HOLDS THE POST"
					or "HOLDS " .. table.concat(letters, " · ")
			end

			v6.counts.Text = Style.paint(tostring(#v7), Style.WHITE) .. Style.paint(
				#v7 == 1 and " PLAYER" or " PLAYERS",
				Style.MUTED
			) .. Style.paint("   " .. v9, Style.WHITE) .. Style.paint(v9 == 1 and " BOT" or " BOTS", Style.MUTED)
			local v14 = {}

			for k, v15 in v7 do
				if k > 3 then
					table.insert(v14, "+" .. #v7 - 3 .. " MORE")
					break
				end

				table.insert(v14, v15.DisplayName)
			end

			v6.names.Text = not (#v14 > 0) and "No players yet" or table.concat(v14, ", ")

			if v4 then
				continue
			end

			local button = v6.button
			local backgroundColor

			if v6.open then
				backgroundColor = Style.HAZARD
			else
				backgroundColor = Style.STEEL
			end

			button.BackgroundColor3 = backgroundColor
			local buttonText = v6.buttonText
			local textColor = if v6.open then Style.INK else Style.MUTED
			buttonText.TextColor3 = textColor
			v6.buttonText.Text = not v6.open and "MORE PLAYERS HERE" or "JOIN " .. string.upper(attributeName)
			v6.button.AutoButtonColor = v6.open
		end
	end

	local currentCamera = workspace.CurrentCamera
	local v6 = true
	local function orbit(_: number, p: number): boolean
		if not layer.Enabled then
			return false
		end

		currentCamera = workspace.CurrentCamera
		local v7 = p / 120 * 3.141592653589793 * 2
		local center = Hardpoint.CENTER
		local v8 = center + Vector3.new(math.cos(v7) * v2, v3, math.sin(v7) * v2)
		currentCamera.CameraType = Enum.CameraType.Scriptable
		currentCamera.CFrame = CFrame.lookAt(v8, center)
		return true
	end

	local v7 = 0
	local function tick(_: number, p: number): boolean
		if not layer.Enabled then
			return false
		end

		if p - v7 >= 0.25 then
			v7 = p
			refresh()
		end

		return true
	end

	local function setOpen(enabled: boolean)
		if enabled == layer.Enabled then
			return
		end

		layer.Enabled = enabled
		data.setMenu(enabled)

		if enabled then
			v4 = false
			label2.Text = ""
			v6 = UserInputService.MouseIconEnabled
			UserInputService.MouseIconEnabled = true
			refresh()
			local now = os.clock()
			Style.animate(region, function(_, p): boolean
				local v8 = (p - now) / 0.3
				fit(0.9 + 0.1 * Style.pop(v8))
				return v8 < 1
			end)

			Style.animate(orbit, orbit)
			Style.animate(tick, tick)
		else
			UserInputService.MouseIconEnabled = Viewmodel.cursorAfterMenu(v6)
			Style.stop(orbit)
			Style.stop(tick)
			local currentCamera2 = workspace.CurrentCamera
			currentCamera2.CameraType = Enum.CameraType.Custom
			local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				currentCamera2.CameraSubject = humanoid
			end
		end
	end

	local function update() -- 2 equivalent calls inferred from this helper
		setOpen(player:GetAttribute("PickingTeam") == true and player.Team == nil)
	end
	player:GetAttributeChangedSignal("PickingTeam"):Connect(update)
	player:GetPropertyChangedSignal("Team"):Connect(update)
	player.CharacterAdded:Connect(function(character)
		if not layer.Enabled then
			local humanoid = character:WaitForChild("Humanoid", 10)
			local currentCamera2 = workspace.CurrentCamera

			if humanoid and currentCamera2.CameraType == Enum.CameraType.Scriptable then
				currentCamera2.CameraType = Enum.CameraType.Custom
				currentCamera2.CameraSubject = humanoid
			end
		end
	end)

	pickTeam.OnClientEvent:Connect(function(p: string, p2: string, value: string?)
		if p == "refused" then
			v4 = false
			label2.Text = (value or "THAT SIDE IS FULL") .. ": PICK " .. string.upper(other(p2)) -- inferred equivalent call
			refresh()
		elseif p == "joined" then
			v4 = false
			update() -- inferred equivalent call
		end
	end)
	update() -- inferred equivalent call
end

return TeamSelect