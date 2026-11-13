local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Style = require(script.Parent.Style)
local Glyph = require(script.Parent.Glyph)
local ReviveHands = require(script.Parent.ReviveHands)
local ReviveAudio = require(script.Parent.ReviveAudio)
local WorldConfig = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("WorldConfig"))
local GameConfig = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("GameConfig"))
local CareerData = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("CareerData"))
local MarketplaceService = game:GetService("MarketplaceService")

local revive = GameConfig.REVIVE

local color = Color3.fromRGB(20, 23, 21)

local e = Enum.KeyCode.E
local DPadRight = Enum.KeyCode.DPadRight

local colorSequences = {}
local ReviveHud = {}

for i = 0, 24 do
	local v = i / 24
	local colorSequence

	if i == 0 then
		colorSequence = ColorSequence.new(color)
	elseif i == 24 then
		colorSequence = ColorSequence.new(Style.GOOD)
	else
		colorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Style.GOOD),
			ColorSequenceKeypoint.new(v, Style.GOOD),
			ColorSequenceKeypoint.new(v + 0.005, color),
			ColorSequenceKeypoint.new(1, color)
		})
	end

	colorSequences[i] = colorSequence
end

local function disc(frame, p: string, color2: Color3, p2: number, zIndex: number)
	local fill = Style.fill(
		frame,
		p,
		color2,
		UDim2.fromOffset(p2, p2),
		UDim2.fromScale(0.5, 0.5),
		Vector2.new(0.5, 0.5)
	)
	fill.ZIndex = zIndex
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0.5, 0)
	uiCorner.Parent = fill
	return fill
end

local function bar(frame, p: string, color2: Color3, p2: number, p3: number, zIndex: number, p4: number)
	local fill = Style.fill(
		frame,
		p,
		color2,
		UDim2.fromOffset(p2, p3),
		UDim2.fromScale(0.5, 0.5),
		Vector2.new(0.5, 0.5)
	)
	fill.ZIndex = zIndex
	Style.corner(fill, p4)
	return fill
end

local function over(instance)
	local upperTorso = instance:FindFirstChild("UpperTorso") or instance:FindFirstChild("Torso")

	if not (upperTorso and upperTorso:IsA("BasePart")) then
		return nil
	end

	local lowerTorso = instance:FindFirstChild("LowerTorso")
	local position = upperTorso.Position
	local v

	if lowerTorso and lowerTorso:IsA("BasePart") then
		v = lowerTorso.Position
	else
		v = position
	end

	local v2 = math.max(position.Y, v.Y)
	local head = instance:FindFirstChild("Head")

	if head and head:IsA("BasePart") and (head.Position - position).Magnitude < 4 then
		v2 = math.max(v2, head.Position.Y)
	end

	return (Vector3.new((position.X + v.X) / 2, v2 + 2.4, (position.Z + v.Z) / 2))
end

local function holdPlate(region, p: string, text: string, p2: string, dPadRight, p3: number, p4: number)
	local button, v = Style.button(region, p, "", Style.STEEL, UDim2.fromScale(1, 1), Style.WHITE, p4)
	button.AutoButtonColor = false
	button.ClipsDescendants = true
	local fill = Style.fill(button, "Fill", Style.GOOD, UDim2.fromScale(0, 1))
	fill.ZIndex = 1
	v.ZIndex = 3
	v.AutomaticSize = Enum.AutomaticSize.None
	v.Text = text
	local cap = Glyph.cap(button, p2, dPadRight, p3)
	cap.AnchorPoint = Vector2.new(0, 0.5)
	cap.Position = UDim2.new(0, 5, 0.5, 0)
	cap.ZIndex = 3

	local function placeWord()
		local size

		if cap.Visible then
			size = UDim2.new(1, -(p3 + 10), 1, 0)
		else
			size = UDim2.fromScale(1, 1)
		end

		v.Size = size
		local position

		if cap.Visible then
			position = UDim2.fromOffset(p3 + 8, 0)
		else
			position = UDim2.new()
		end

		v.Position = position
	end
	cap:GetPropertyChangedSignal("Visible"):Connect(placeWord)
	placeWord()
	return button, fill, v
end

function ReviveHud.mount(data)
	local player = data.player
	ReviveAudio.prepare()
	local Game = ReplicatedStorage:WaitForChild("Game")
	local downed = Game:WaitForChild("Downed")
	local revive2 = Game:WaitForChild("Remotes"):WaitForChild("Revive")
	local hud = data.layers.hud

	local reviveMarks = Instance.new("Folder")
	reviveMarks.Name = "ReviveMarks"
	reviveMarks.Parent = workspace

	local marks = {}
	local function newMark()
		local mark = Instance.new("Part")
		mark.Name = "Mark"
		mark.Anchored = true
		mark.CanCollide = false
		mark.CanQuery = false
		mark.CanTouch = false
		mark.CastShadow = false
		mark.Transparency = 1
		mark.Size = Vector3.new(1, 1, 1)
		local billboardGui = Instance.new("BillboardGui")
		billboardGui.Size = UDim2.fromOffset(160, 150)
		billboardGui.AlwaysOnTop = true
		billboardGui.LightInfluence = 0
		billboardGui.MaxDistance = 250
		billboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		billboardGui.Parent = mark

		local frame = Style.frame(
			billboardGui,
			"Icon",
			UDim2.fromOffset(34, 34),
			UDim2.fromScale(0.5, 0.5),
			Vector2.new(0.5, 0.5)
		)
		local uiScale = Instance.new("UIScale")
		uiScale.Parent = frame
		local frame2 = Style.frame(
			frame,
			"Ripple",
			UDim2.fromOffset(34, 34),
			UDim2.fromScale(0.5, 0.5),
			Vector2.new(0.5, 0.5)
		)
		frame2.ZIndex = 1
		frame2.Visible = false
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0.5, 0)
		uiCorner.Parent = frame2
		local stroke = Style.stroke(frame2, 2, 1, Style.GOOD)
		local glow = disc(frame, "Glow", Style.GOOD, 44, 2)
		glow.BackgroundTransparency = 0.88
		local disc_2 = disc(frame, "Rim", Style.INK, 34, 3)
		disc_2.BackgroundTransparency = 0.1
		disc(frame, "Ring", Style.GOOD, 30, 4)
		local parent = disc(frame, "Disc", Color3.new(1, 1, 1), 24, 5)
		local uiGradient = Instance.new("UIGradient")
		uiGradient.Rotation = -90
		uiGradient.Color = colorSequences[0]
		uiGradient.Parent = parent
		bar(frame, "CrossInkUp", Style.INK, 8, 18, 6, 2)
		bar(frame, "CrossInkAcross", Style.INK, 18, 8, 6, 2)
		bar(frame, "CrossUp", Style.WHITE, 6, 16, 7, 1)
		bar(frame, "CrossAcross", Style.WHITE, 16, 6, 7, 1)

		local label = Style.label(billboardGui, "Name", "", 12, Style.FONT, 1)
		label.AutomaticSize = Enum.AutomaticSize.None
		label.Size = UDim2.new(1, 0, 0, 15)
		label.Position = UDim2.fromOffset(0, 99.1)
		label.TextColor3 = Style.GOOD
		label.TextTruncate = Enum.TextTruncate.AtEnd
		label.AutoLocalize = false
		local label2 = Style.label(billboardGui, "Distance", "", 12, Style.FONT_BODY, 1)
		label2.AutomaticSize = Enum.AutomaticSize.None
		label2.Size = UDim2.new(1, 0, 0, 15)
		label2.Position = UDim2.fromOffset(0, 113.1)
		label2.TextColor3 = Style.WHITE
		label2.AutoLocalize = false
		return {
			part = mark,
			gui = billboardGui,
			icon = frame,
			scale = uiScale,
			glow = glow,
			ripple = frame2,
			rippleLine = stroke,
			fill = uiGradient,
			name = label,
			dist = label2,
			shown = nil,
			filled = nil,
			called = nil,
			at = nil
		}
	end

	local v = {}

	local function findModel(state)
		local inst = state.inst
		local owner = inst:GetAttribute("Owner")

		if type(owner) == "number" and owner ~= 0 then
			local playerByUserId = Players:GetPlayerByUserId(owner)

			if playerByUserId then
				return playerByUserId.Character
			end

			return nil
		else
			local pos = inst:GetAttribute("Pos")
			local botRigs = workspace:FindFirstChild("BotRigs")

			if typeof(pos) ~= "Vector3" or not botRigs then
				return nil
			end

			local team = inst:GetAttribute("Team")
			local v2 = 12
			local v3 = nil

			for _, model in botRigs:GetChildren() do
				if not (model:IsA("Model") and model:GetAttribute("Alive") == false and model:GetAttribute("Team") == team) then
					continue
				end

				local position = model:GetPivot().Position
				local magnitude = Vector2.new(position.X - pos.X, position.Z - pos.Z).Magnitude

				if not (magnitude < v2) then
					continue
				end

				v3 = model
				v2 = magnitude
			end

			return v3
		end
	end

	local function markPoint(state)
		local model = state.model

		if model and (model.Parent == nil or model:GetAttribute("Alive") == true) then
			state.model = nil
			model = nil
		end

		if not model and os.clock() >= state.findAt then
			state.findAt = os.clock() + 0.5
			model = findModel(state)
			state.model = model
		end

		local selected

		if model then
			selected = over(model)
		end

		if selected then
			return selected
		end

		local pos = state.inst:GetAttribute("Pos")

		if typeof(pos) == "Vector3" then
			return pos + Vector3.new(0, 2.4, 0)
		end

		return nil
	end

	local function placeMark(p, dt: number?) -- 1 equivalent call inferred from this helper
		local mark = p.mark
		local at2

		if mark then
			at2 = markPoint(p)
		end

		if not (mark and at2) then
			return
		end

		local at = mark.at

		if dt and at and (at2 - at).Magnitude < 20 then
			at2 = at:Lerp(at2, 1 - math.exp(-14 * dt))
		end

		if not at or (at2 - at).Magnitude > 0.01 then
			mark.at = at2
			mark.part.CFrame = CFrame.new(at2)
		end
	end

	local function dropMark(p) -- 2 equivalent calls inferred from this helper
		local mark = p.mark

		if mark then
			p.mark = nil
			mark.shown = nil
			mark.at = nil
			mark.part.Parent = nil
			table.insert(marks, mark)
		end
	end

	local function friendly(instance): boolean -- 2 equivalent calls inferred from this helper
		local team = player.Team
		return team ~= nil
			and instance:GetAttribute("Team") == team.Name
			and instance:GetAttribute("Owner") ~= player.UserId
	end

	local function called(p)
		local inst = p.inst

		if not friendly(inst) then -- inferred equivalent call
			return
		end

		p.popAt = os.clock()
		local pos = inst:GetAttribute("Pos")

		if typeof(pos) ~= "Vector3" then
			return
		end

		ReviveAudio.world("groan", pos)
		local magnitude = (pos - workspace.CurrentCamera.CFrame.Position).Magnitude

		if magnitude <= 250 then
			local v2 = math.clamp((magnitude - 30) / 220, 0, 1)
			ReviveAudio.call(1 - v2 * 0.55)
		end
	end

	local function addBody(configuration)
		if configuration:IsA("Configuration") then
			local v2 = {
				inst = configuration,
				mark = nil,
				cue = 0,
				model = nil,
				findAt = 0,
				popAt = -1e999
			}
			v[configuration] = v2
			configuration:GetAttributeChangedSignal("AskedAt"):Connect(function()
				called(v2)
			end)
		end
	end

	for _, child in downed:GetChildren() do
		addBody(child)
	end

	downed.ChildAdded:Connect(addBody)
	local function fn() end
	downed.ChildRemoved:Connect(function(child)
		local v2 = v[child]

		if v2 then
			fn(v2)
			dropMark(v2) -- inferred equivalent call
			v[child] = nil
		end
	end)

	local touch = Style.isTouch()

	local region = Style.region(
		hud,
		"RevivePrompt",
		Vector2.new(0.5, 0.5),
		Vector2.new(0, 96),
		Vector2.new(touch and 130 or 110, touch and 44 or 30)
	)
	region.Visible = false
	local v2, v3 = holdPlate(region, "Hold", "REVIVE", "E", DPadRight, touch and 22 or 18, 14)
	v2.Selectable = false

	local region2 = Style.region(hud, "RespawnTimer", Vector2.new(0.5, 1), Vector2.zero, Vector2.new(220, 78))
	region2.Visible = false
	local label = Style.label(region2, "Caption", "RESPAWNING IN", 14, Style.FONT, 1)
	label.AutomaticSize = Enum.AutomaticSize.None
	label.Size = UDim2.new(1, 0, 0, 18)
	label.TextXAlignment = Enum.TextXAlignment.Center
	local label2 = Style.label(region2, "Seconds", "", 44, Style.FONT, 2)
	label2.AutomaticSize = Enum.AutomaticSize.None
	label2.Size = UDim2.new(1, 0, 0, 48)
	label2.Position = UDim2.fromOffset(0, 18)
	label2.TextXAlignment = Enum.TextXAlignment.Center
	label2.AutoLocalize = false
	local fill = Style.fill(
		region2,
		"Bar",
		Style.INK,
		UDim2.fromOffset(180, 5),
		UDim2.new(0.5, 0, 0, 70),
		Vector2.new(0.5, 0)
	)
	fill.BackgroundTransparency = 0.45
	local fill2 = Style.fill(fill, "Fill", Style.WHITE, UDim2.fromScale(1, 1))
	local v4 = touch and 196 or 206
	local v5 = touch and 46 or 32
	local region3 = Style.region(hud, "ReviveRequest", Vector2.new(0.5, 1), Vector2.new(0, -124), Vector2.new(v4, v5))
	region3.Visible = false
	local v6, v7, v8 = holdPlate(region3, "Request", "REQUEST REVIVE", "E", DPadRight, touch and 22 or 18, 14)
	v6.Selectable = false
	v7.BackgroundTransparency = 0.55

	local region4 = Style.region(hud, "RevivedBy", Vector2.new(0.5, 1), Vector2.new(0, -120), Vector2.new(280, 62))
	region4.Visible = false
	local label3 = Style.label(region4, "Caption", "BEING REVIVED BY", 14, Style.FONT, 1)
	label3.AutomaticSize = Enum.AutomaticSize.None
	label3.Size = UDim2.new(1, 0, 0, 18)
	label3.TextXAlignment = Enum.TextXAlignment.Center
	local label4 = Style.label(region4, "Name", "", 24, Style.FONT, 2)
	label4.AutomaticSize = Enum.AutomaticSize.None
	label4.Size = UDim2.new(1, 0, 0, 28)
	label4.Position = UDim2.fromOffset(0, 17)
	label4.TextXAlignment = Enum.TextXAlignment.Center
	label4.TextColor3 = Style.GOOD
	label4.TextTruncate = Enum.TextTruncate.AtEnd
	label4.AutoLocalize = false
	local fill3 = Style.fill(
		region4,
		"Bar",
		Style.INK,
		UDim2.fromOffset(240, 10),
		UDim2.new(0.5, 0, 0, 49),
		Vector2.new(0.5, 0)
	)
	fill3.BackgroundTransparency = 0.3
	Style.corner(fill3, 5)
	Style.stroke(fill3, 1.5, 0.2, Style.INK)
	local fill4 = Style.fill(fill3, "Fill", Style.GOOD, UDim2.fromScale(0, 1))
	Style.corner(fill4, 5)

	local v9 = CareerData.STORE.revive[1]
	local region5 = Style.region(hud, "ReviveNow", Vector2.new(0.5, 1), Vector2.zero, Vector2.new(v4, v5))
	region5.Visible = false
	local button = Style.button(region5, "Buy", "", Style.STEEL, UDim2.fromScale(1, 1), Style.WHITE, 14)
	button.AutoButtonColor = true
	button.Selectable = false
	Style.stroke(button, 2, 0, Style.HAZARD, true)
	local v10 = touch and 22 or 18
	local cap = Glyph.cap(button, "R", Enum.KeyCode.DPadUp, v10)
	cap.AnchorPoint = Vector2.new(0, 0.5)
	cap.Position = UDim2.new(0, 5, 0.5, 0)
	cap.ZIndex = 3
	local frame = Style.frame(button, "Words", UDim2.fromScale(1, 1))
	frame.ZIndex = 3
	local robuxLine, v11 = Style.robuxLine(frame, "Price", 15)
	v11("INSTANT REVIVE", tostring(v9.robux), Style.WHITE)

	task.spawn(function()
		local success, productInfoAsync = pcall(
			MarketplaceService.GetProductInfoAsync,
			MarketplaceService,
			v9.productId,
			Enum.InfoType.Product
		)

		if success and type(productInfoAsync) == "table" and type(productInfoAsync.PriceInRobux) == "number" then
			v11("INSTANT REVIVE", tostring(productInfoAsync.PriceInRobux), Style.WHITE)
		else
			warn("[ReviveHud] no price for developer product " .. v9.productId .. ": " .. tostring(productInfoAsync))
		end
	end)

	local frame2 = Style.frame(frame, "Kept", UDim2.fromScale(1, 1))
	frame2.Visible = false

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0, 5)
	uiListLayout.Parent = frame2

	local label_2 = Style.label(frame2, "Words", "INSTANT REVIVE", 15, Style.FONT, 1.5)
	label_2.LayoutOrder = 1
	local label5 = Style.label(frame2, "Count", "", 15, Style.FONT, 1.5)
	label5.LayoutOrder = 2
	label5.AutoLocalize = false
	local function placeBuyWords()
		local size

		if cap.Visible then
			size = UDim2.new(1, -(v10 + 10), 1, 0)
		else
			size = UDim2.fromScale(1, 1)
		end

		frame.Size = size
		local position

		if cap.Visible then
			position = UDim2.fromOffset(v10 + 8, 0)
		else
			position = UDim2.new()
		end

		frame.Position = position
	end
	cap:GetPropertyChangedSignal("Visible"):Connect(placeBuyWords)
	placeBuyWords()
	local v12 = -1
	local function drawKept() -- 1 equivalent call inferred from this helper
		local attribute = player:GetAttribute(CareerData.STOCK_ATTR.revive) or 0

		if attribute == v12 then
			return
		end

		v12 = attribute
		label5.Text = string.format("(x%d)", attribute)
		frame2.Visible = attribute > 0
		robuxLine.Visible = attribute <= 0
	end

	drawKept() -- inferred equivalent call
	player:GetAttributeChangedSignal(CareerData.STOCK_ATTR.revive):Connect(drawKept)
	local v13 = false
	local function buyRevive()
		if not region5.Visible or v13 then
			return
		end

		v13 = true

		if (player:GetAttribute(CareerData.STOCK_ATTR.revive) or 0) > 0 then
			local career = Game:WaitForChild("Remotes"):WaitForChild("Career")
			local success, result, v14 = pcall(career.InvokeServer, career, "revive")

			if not success or result ~= true then
				warn("[ReviveHud] kept revive: " .. tostring(result) .. " " .. tostring(v14))
			end
		else
			revive2:FireServer("paying")
			MarketplaceService:PromptProductPurchase(player, v9.productId)
		end

		task.delay(1, function()
			v13 = false
		end)
	end
	button.Activated:Connect(buyRevive)
	local v14 = -1
	local v15 = 1
	local v16 = touch and 410 or 480
	local v17 = touch and 28 or 24
	local v18 = v15 * v17 + 0
	local region6 = Style.region(hud, "NearTeam", Vector2.new(0.5, 1), Vector2.zero, Vector2.new(v16, v18))
	region6.Visible = false
	local v19 = math.floor((v16 - 28) / 3)

	local v20 = {}

	for i = 1, v15 * 3 do
		local v21 = (i - 1) % 3 * (v19 + 14)
		local v22 = (i - 1) // 3 * v17 + 0
		local label6 = Style.label(region6, "Distance" .. i, "", 15, Style.FONT, 1.5)
		label6.AutomaticSize = Enum.AutomaticSize.None
		label6.Size = UDim2.fromOffset(48, v17 - 1)
		label6.Position = UDim2.fromOffset(v21 + 4, v22)
		label6.TextXAlignment = Enum.TextXAlignment.Left
		label6.TextColor3 = Style.GOOD
		label6.RichText = true
		label6.AutoLocalize = false
		local label7 = Style.label(region6, "Name" .. i, "", 14, Style.FONT_BODY, 1.5)
		label7.AutomaticSize = Enum.AutomaticSize.None
		label7.Size = UDim2.fromOffset(v19 - 48 - 8, v17 - 1)
		label7.Position = UDim2.fromOffset(v21 + 4 + 48, v22)
		label7.TextXAlignment = Enum.TextXAlignment.Left
		label7.TextColor3 = Style.GOOD
		label7.TextTruncate = Enum.TextTruncate.AtEnd
		label7.AutoLocalize = false
		local nearTeammate

		if i <= (math.min)(3, v15 * 3) then
			nearTeammate = Instance.new("Highlight")
			nearTeammate.Name = "NearTeammate"
			nearTeammate.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			nearTeammate.FillColor = Style.WHITE
			nearTeammate.FillTransparency = 0.8
			nearTeammate.OutlineColor = Style.GOOD
			nearTeammate.OutlineTransparency = 0.15
			nearTeammate.Enabled = false
			nearTeammate.Parent = reviveMarks
		end

		v20[i] = {
			name = label7,
			dist = label6,
			outline = nearTeammate,
			shown = nil,
			empty = nil
		}
	end

	local function metresText(value: number)
		local v21 = string.format("%03d", (math.clamp(value, 0, 999)))
		local count = #string.match(v21, "^0*")
		local v22 = count >= 3 and 2 or count

		if v22 == 0 then
			return v21 .. "m"
		end

		return "<font transparency=\"" .. 0.65 .. "\">" .. string.sub(v21, 1, v22) .. "</font>" .. string.sub(v21, v22 + 1) .. "m"
	end

	local v21 = false
	local function layout()
		local scaled = Style.scale()
		local v22 = v18 + 14 + 10
		local v23 = not v21 and 24 or v22 + v5 + 10
		local midpoint = (v4 + 10) / 2
		region3.Position = UDim2.new(0.5, -midpoint * scaled, 1, -v22 * scaled)
		region5.Position = UDim2.new(0.5, midpoint * scaled, 1, -v22 * scaled)
		region2.Position = UDim2.new(0.5, 0, 1, -v23 * scaled)
		region4.Position = UDim2.new(0.5, 0, 1, -(v23 + 78 + 6) * scaled)
		region6.Position = UDim2.new(0.5, 0, 1, -14 * scaled)
	end
	local function stackUp(flag: boolean) -- 1 equivalent call inferred from this helper
		if v21 ~= flag then
			v21 = flag
			layout()
		end
	end
	Style.onScale(function()
		layout()
	end)

	local function showNear(vector3: Vector3?)
		local v22 = {}
		local team = player.Team

		if vector3 and team then
			for _, v23 in Players:GetPlayers() do
				local character = v23.Character

				if not (v23 ~= player and v23.Team == team and character and v23:GetAttribute("Invisible") ~= true) then
					continue
				end

				local humanoid = character:FindFirstChildOfClass("Humanoid")
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

				if humanoid and humanoid.Health > 0 and humanoidRootPart and humanoidRootPart:IsA("BasePart") then
					table.insert(v22, {
						name = v23.DisplayName,
						model = character,
						d = (humanoidRootPart.Position - vector3).Magnitude
					})
				end
			end

			local botRigs = workspace:FindFirstChild("BotRigs")

			if botRigs then
				for _, model in botRigs:GetChildren() do
					if not (model:IsA("Model") and model:GetAttribute("Alive") == true and model:GetAttribute("Team") == team.Name) then
						continue
					end

					table.insert(v22, {
						name = model.Name,
						model = model,
						d = (model:GetPivot().Position - vector3).Magnitude
					})
				end
			end

			table.sort(v22, function(a, b): boolean
				return a.d < b.d
			end)
		end

		for k, v23 in v20 do
			local v24

			if vector3 then
				v24 = v22[k]
			end

			if v24 then
				if v23.empty ~= false then
					v23.empty = false
					v23.dist.TextTransparency = 0
					v23.name.TextTransparency = 0
					v23.dist.TextColor3 = Style.GOOD
					v23.name.TextColor3 = Style.GOOD
				end

				if v23.name.Text ~= v24.name then
					v23.name.Text = v24.name
				end

				local shown = math.round(v24.d / WorldConfig.METER)

				if v23.shown ~= shown then
					v23.shown = shown
					v23.dist.Text = metresText(shown)
				end
			elseif v23.empty ~= true then
				v23.empty = true
				v23.shown = nil
				v23.dist.Text = ""
				v23.name.Text = ""
				v23.dist.TextColor3 = Style.DIM
				v23.name.TextColor3 = Style.DIM
				v23.dist.TextTransparency = 0.55
				v23.name.TextTransparency = 0.55
			end

			local outline = v23.outline

			if not outline then
				continue
			end

			local model

			if v24 then
				model = v24.model
			end

			if outline.Adornee ~= model then
				outline.Adornee = model
			end

			if outline.Enabled ~= (model ~= nil) then
				outline.Enabled = model ~= nil
			end
		end

		local visible = vector3 ~= nil

		if region6.Visible ~= visible then
			region6.Visible = visible
		end

		stackUp(visible) -- inferred equivalent call
	end
	local total = 1e999
	local lastTime = -1e999
	local v22 = nil
	local maxValue = 0
	local v23 = -1

	local v24 = nil
	Game:WaitForChild("Remotes"):WaitForChild("Died").OnClientEvent:Connect(function(_, _, _, _, p: number?)
		v24 = p
	end)

	local v25 = false
	data.onMenu(function(flag: boolean)
		v25 = flag
	end)

	local v26 = nil
	local v27 = nil
	local v28 = nil
	local lastTime2 = 0
	local count = 0
	local lastTime3 = -1e999
	local v29 = 0
	local v30 = nil

	fn = function(p)
		local holdEnd = p.inst:GetAttribute("HoldEnd")

		if type(holdEnd) ~= "number" or workspace:GetServerTimeNow() < holdEnd - 0.4 then
			return
		end

		if p == v28 then
			lastTime3 = os.clock()
			ReviveAudio.own("done")
		elseif p == v27 then
			ReviveAudio.own("up")
		end
	end

	local function letGo() -- 4 equivalent calls inferred from this helper
		if v28 then
			v28 = nil
			ReviveHands.stop()

			if os.clock() - lastTime3 > 0.5 then
				ReviveAudio.own("letgo")
			end

			revive2:FireServer("stop")
		end
	end

	local function request()
		if not region3.Visible then
			return
		end

		if v27 and v27.inst:GetAttribute("Requested") == true then
			lastTime = os.clock()
			revive2:FireServer("cancel")
		else
			if os.clock() - lastTime < revive.ASK_EVERY then
				return
			end

			lastTime = os.clock()
			ReviveAudio.own("request")
			revive2:FireServer("request")
		end
	end
	v6.Activated:Connect(request)

	local function press()
		if data.isDead() then
			request()
		elseif v26 then
			v28 = v26
			lastTime2 = os.clock()
			count = 0
			ReviveHands.start()
			revive2:FireServer("start", (tonumber(v26.inst.Name)))
		end
	end

	UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
		if gameProcessed or Glyph.claimed() then
			return
		end

		if input.KeyCode == e or input.KeyCode == DPadRight then
			press()
		elseif (input.KeyCode == Enum.KeyCode.R or input.KeyCode == Enum.KeyCode.DPadUp) and data.isDead() then
			buyRevive()
		end
	end)

	local v31 = nil
	local function plateLifted(input) -- 1 equivalent call inferred from this helper
		if
			v31
			and (input == v31 or input.UserInputType == Enum.UserInputType.MouseButton1 and v31.UserInputType == Enum.UserInputType.MouseButton1)
		then
			v31 = nil
			letGo() -- inferred equivalent call
		end
	end
	UserInputService.TouchEnded:Connect(plateLifted)
	UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == e or input.KeyCode == DPadRight then
			letGo() -- inferred equivalent call
		end

		plateLifted(input) -- inferred equivalent call
	end)
	local function holdable(p, press2) -- 1 equivalent call inferred from this helper
		p.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.Touch
				or input.UserInputType == Enum.UserInputType.MouseButton1
			then
				v31 = input
				press2()
			end
		end)
	end

	holdable(v2, press) -- inferred equivalent call

	local function look()
		local character = player.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local position

		if humanoidRootPart then
			position = humanoidRootPart.Position
		else
			position = workspace.CurrentCamera.CFrame.Position
		end

		local v32

		if humanoidRootPart == nil then
			v32 = false
		else
			v32 = not data.isDead() and not v25 and player:GetAttribute("InVehicle") ~= true
		end

		local v33 = nil
		local v34 = revive.REACH
		local cframe = workspace.CurrentCamera.CFrame
		local flag = false
		v27 = nil
		local serverTimeNow = workspace:GetServerTimeNow()

		for k, v35 in v do
			local holdEnd = k:GetAttribute("HoldEnd")
			local pos = k:GetAttribute("Pos")

			if type(holdEnd) == "number" and typeof(pos) == "Vector3" and v35 ~= v28 then
				local v36 = (revive.HOLD - (holdEnd - serverTimeNow)) * 3 / revive.HOLD
				local v37 = ReviveAudio.CUES[v35.cue + 1]

				while v37 and v37[1] <= v36 do
					v35.cue += 1
					ReviveAudio.world(v37[2], pos)
					v37 = ReviveAudio.CUES[v35.cue + 1]
				end
			elseif holdEnd == nil then
				v35.cue = 0
			end

			if k:GetAttribute("Owner") == player.UserId then
				v27 = v35
			elseif friendly(k) then -- inferred equivalent call
				local mark = v35.mark

				if not mark then
					mark = table.remove(marks) or newMark()
					v35.mark = mark

					mark.name.Text = tostring(k:GetAttribute("Who") or "")
					mark.filled = nil
					mark.called = nil
					placeMark(v35) -- inferred equivalent call
					mark.part.Parent = reviveMarks
				end

				local pos2 = k:GetAttribute("Pos")

				if typeof(pos2) == "Vector3" then
					local magnitude = (pos2 - position).Magnitude
					local shown = math.round(magnitude / WorldConfig.METER)

					if mark.shown ~= shown then
						mark.shown = shown
						mark.dist.Text = shown .. " m"
					end

					local requested = k:GetAttribute("Requested") == true
					local v38 = pos2 - cframe.Position
					local v39 = not (v38.Magnitude > 0.1) and 1 or v38.Unit:Dot(cframe.LookVector)
					local v40 = v39 >= 0.985
					local enabled = requested or magnitude <= revive.CALL_RANGE

					if mark.gui.Enabled ~= enabled then
						mark.gui.Enabled = enabled
					end

					local visible = v40 or requested or magnitude <= 25

					if mark.name.Visible ~= visible then
						mark.name.Visible = visible
						mark.dist.Visible = visible
					end

					local text = requested and not v40 and "NEEDS HELP" or tostring(k:GetAttribute("Who") or "")

					if mark.name.Text ~= text then
						mark.name.Text = text
					end

					local v44

					if k:GetAttribute("HoldEnd") == nil then
						v44 = false
					else
						v44 = v28 ~= v35
					end

					if v32 and magnitude < v34 and not v44 and v39 >= 0.5 then
						v33 = v35
						v34 = magnitude
					end

					if v32 and v35 == v28 and magnitude < revive.REACH + revive.REACH_SLACK then
						flag = true
					end
				end
			else
				dropMark(v35) -- inferred equivalent call
			end
		end

		if flag then
			v33 = v28
		end

		v26 = v33

		if v28 and v28 ~= v26 then
			letGo() -- inferred equivalent call
		end

		local visible = v26 ~= nil

		if region.Visible ~= visible then
			region.Visible = visible
			player:SetAttribute("ReviveFocus", visible and true or nil)
		end
	end

	local function width(p, value: number) -- 4 equivalent calls inferred from this helper
		p.Size = UDim2.fromScale(math.clamp(value, 0, 1), 1)
	end

	local total2 = 0
	RunService.Heartbeat:Connect(function(dt: number)
		total2 += dt
		local v32 = next(v) == nil

		if total2 >= 0.1 and (not v32 or v26 or v27) then
			total2 = 0
			debug.profilebegin("RH.look")
			look()
			debug.profileend()
		end

		local serverTimeNow = workspace:GetServerTimeNow()

		local now = os.clock()

		for _, v33 in v do
			local mark = v33.mark

			if not (mark and mark.gui.Enabled) then
				continue
			end

			placeMark(v33, dt)
			local inst = v33.inst
			local holdEnd = inst:GetAttribute("HoldEnd")
			local filled = type(holdEnd) ~= "number" and 0
				or math.clamp(math.floor((1 - (holdEnd - serverTimeNow) / revive.HOLD) * 24), 0, 24)

			if mark.filled ~= filled then
				mark.filled = filled
				mark.fill.Color = colorSequences[filled]
			end

			local requested = inst:GetAttribute("Requested") == true
			local v35 = now - v33.popAt
			local v36 = not (v35 < 1.35) and 0 or math.exp(-2.5 * v35 / 0.45) * 0.55

			if mark.called ~= requested then
				mark.called = requested
				mark.ripple.Visible = requested
				mark.glow.BackgroundTransparency = 0.88
				mark.scale.Scale = 1
			end

			if requested then
				local v37 = math.sin(now * 1.4 * 2 * 3.141592653589793)
				mark.scale.Scale = v37 * 0.05 + 1.3 + v36
				mark.glow.BackgroundTransparency = v37 * 0.08 + 0.72
				local v38 = (now - (not (v35 < 1e999) and 0 or v33.popAt)) % 1.1 / 1.1
				local v39 = 34 * (1 + 1.5 * (1 - (1 - v38) ^ 2))
				mark.ripple.Size = UDim2.fromOffset(v39, v39)
				mark.rippleLine.Transparency = 0.1 + 0.9 * v38
			elseif v36 > 0 then
				mark.scale.Scale = v36 + 1
			end
		end

		local v33 = v28

		if
			v33
			and (os.clock() - lastTime2 > 0.25 and ReviveHands.wantsWeapon() or os.clock() - lastTime2 > 1 and v33.inst:GetAttribute("HoldEnd") == nil)
		then
			letGo() -- inferred equivalent call
		end

		if v28 then
			local v34 = (os.clock() - lastTime2) * 3 / revive.HOLD
			local v35 = ReviveAudio.CUES[count + 1]

			while v35 and v35[1] <= v34 do
				count += 1
				ReviveAudio.own(v35[2])
				v35 = ReviveAudio.CUES[count + 1]
			end
		end

		if v26 then
			local holdEnd = v26.inst:GetAttribute("HoldEnd")
			width(v3, (type(holdEnd) ~= "number" or v28 ~= v26) and 0 or 1 - (holdEnd - serverTimeNow) / revive.HOLD) -- inferred equivalent call
		end

		local v34 = v27
		local v35 = player:GetAttribute("DownUntil")

		if type(v35) ~= "number" then
			v35 = v24
		end

		local holdEnd

		if v34 then
			holdEnd = v34.inst:GetAttribute("HoldEnd")
		end

		local visible = data.isDead() and type(holdEnd) == "number"
		local downPaused = player:GetAttribute("DownPaused")

		local downRate = player:GetAttribute("DownRate")
		local v37 = (not v34 or type(downRate) ~= "number") and 1 or downRate
		local v38

		if data.isDead() and type(v35) == "number" then
			if type(downPaused) == "number" then
				v38 = downPaused
			else
				v38 = v35 - serverTimeNow
			end
		end

		if region4.Visible ~= visible then
			region4.Visible = visible
			v14 = -1
		end

		local text = (visible or v34 and type(downPaused) == "number") and "RESPAWN PAUSED"
			or v37 < 1 and "RESPAWN SLOWED"
			or "RESPAWNING IN"

		if label.Text ~= text then
			label.Text = text
		end

		if visible and v34 then
			local by = tostring(v34.inst:GetAttribute("By") or "")

			if label4.Text ~= by then
				label4.Text = by
			end

			local v40 = math.floor(math.clamp(1 - (holdEnd - serverTimeNow) / revive.HOLD, 0, 1) * 90)

			if v40 ~= v14 then
				v14 = v40
				width(fill4, v40 / 90) -- inferred equivalent call
			end
		end

		local visible2

		if v38 == nil then
			visible2 = false
		else
			visible2 = v38 > 0 or v34 ~= nil
		end

		if region2.Visible ~= visible2 then
			region2.Visible = visible2
		end

		if v38 and visible2 then
			label2.Text = tostring(not (v38 > 0) and 0 or math.ceil(v38))
			maxValue = math.max(maxValue, v38)
			local v41 = not (maxValue > 0) and 0 or math.ceil(math.max(v38, 0) / maxValue * 90)

			if v41 ~= v23 then
				v23 = v41
				width(fill2, v41 / 90) -- inferred equivalent call
			end
		elseif maxValue ~= 0 then
			maxValue = 0
			v23 = -1
		end

		local visible3

		if v34 == nil or v38 == nil or not (v38 > 0.75) then
			visible3 = false
		else
			visible3 = type(v34.inst:GetAttribute("HoldEnd")) ~= "number"
		end

		if region3.Visible ~= visible3 then
			region3.Visible = visible3
		end

		if region5.Visible ~= visible3 then
			region5.Visible = visible3
		end

		if visible3 and v34 then
			local v42 = revive.ASK_EVERY - (os.clock() - lastTime)
			local v43 = v34.inst:GetAttribute("Requested") == true and "cancel" or v42 > 0 and "wait" or "ask"

			if v43 ~= v22 then
				v22 = v43
				v8.Text = v43 == "cancel" and "CANCEL REQUEST" or "REQUEST REVIVE"
				v7.Size = UDim2.fromScale(0, 1)
			end

			if v43 == "wait" then
				width(v7, math.ceil(v42 / revive.ASK_EVERY * 90) / 90) -- inferred equivalent call
			end
		end

		if v34 and type(v34.inst:GetAttribute("HoldEnd")) ~= "number" then
			local coming = v34.inst:GetAttribute("Coming")

			if coming ~= v30 then
				v30 = coming

				if coming then
					ReviveAudio.own("coming")
				end
			end

			local now2 = os.clock()

			if v29 <= now2 and (v38 or 0) <= 10 then
				v29 = now2 + ((v38 or 0) < 3 and 0.55 or 1)
				ReviveAudio.own("beat")
			end
		end

		local pos

		if v34 and data.isDead() and not visible then
			pos = v34.inst:GetAttribute("Pos")
		end

		if typeof(pos) == "Vector3" then
			total += dt

			if total >= 0.5 then
				total = 0
				showNear(pos)
			end
		elseif total ~= 1e999 then
			total = 1e999
			showNear(nil)
		end
	end)
end

return ReviveHud