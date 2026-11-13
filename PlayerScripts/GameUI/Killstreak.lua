local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Style = require(script.Parent:WaitForChild("Style"))
local StreakIcon = require(script.Parent:WaitForChild("StreakIcon"))
local Glyph = require(script.Parent:WaitForChild("Glyph"))
local LoadoutStrip = require(script.Parent:WaitForChild("LoadoutStrip"))
local Airstrike = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("Airstrike"))
local ShopData = require(ReplicatedStorage.Game:WaitForChild("ShopData"))
local TouchLayout = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("TouchLayout"))
local airstrikeInbound = ReplicatedStorage.Game:WaitForChild("Remotes"):WaitForChild("AirstrikeInbound")

local DPadDown = Enum.KeyCode.DPadDown

local HellfireState = ReplicatedStorage.Game.Remotes:WaitForChild("HellfireState")
local GunshipState = ReplicatedStorage.Game.Remotes:WaitForChild("GunshipState")

local set = {}
local Killstreak = {}

for k, v in ShopData.ITEMS do
	if v.slot == "streak" then
		set[k] = true
	end
end

function Killstreak.mount(data)
	local player = data.player
	local hud = data.layers.hud

	local region = Style.region(hud, "Killstreak", Vector2.new(0, 1), Vector2.new(14, -18), Vector2.new(196, 44))
	Style.boost(region, Style.touchHud())
	local panel = Style.panel(region, "Plate", UDim2.fromScale(1, 1))

	local frame = Style.frame(panel, "IconBox", UDim2.fromOffset(38, 19), UDim2.fromOffset(8, 3))

	local label = Style.label(panel, "Title", "AIRSTRIKE", 15, Style.FONT, 0)
	label.Position = UDim2.fromOffset(52, 3)
	label.TextColor3 = Style.MUTED
	local maxKills = 0
	local fills = {}
	local v = nil
	local v2 = nil
	local v3 = nil

	for _, v4 in ShopData.ITEMS do
		if v4.slot == "streak" then
			maxKills = math.max(maxKills, v4.kills)
		end
	end

	for i = 1, maxKills do
		local fill = Style.fill(
			panel,
			"Notch" .. i,
			Style.STEEL,
			UDim2.fromOffset(22, 10),
			UDim2.fromOffset((i - 1) * 27 + 10, 26)
		)
		Style.corner(fill, 1)
		Style.stroke(fill, 1, 0.2, nil, true)
		fills[i] = fill
	end

	local frame2 = Style.frame(panel, "Held", UDim2.fromOffset(52, 44), UDim2.new(1, -8, 0, 0), Vector2.new(1, 0))
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.Padding = UDim.new(0, 4)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = frame2

	local cap = Glyph.cap(frame2, "?", DPadDown, 20)
	cap.LayoutOrder = 1
	local label2 = Style.label(frame2, "Count", "", 18, Style.FONT)
	label2.LayoutOrder = 3
	label2.TextColor3 = Style.HAZARD

	local touch = Style.isTouch()
	local label3 = Style.label(frame2, "Tap", "TAP", 18, Style.FONT, 1.5)
	label3.LayoutOrder = 0
	label3.TextColor3 = Style.HAZARD
	label3.Visible = false
	local fill = Style.fill(panel, "Ready", Style.HAZARD, UDim2.fromScale(1, 1))
	fill.BackgroundTransparency = 0.8
	fill.ZIndex = 0
	fill.Visible = false
	Style.corner(fill, 4)
	local tap = Instance.new("TextButton")
	tap.Name = "Tap"
	tap.Text = ""
	tap.BackgroundTransparency = 1
	tap.AutoButtonColor = false
	tap.Size = UDim2.fromScale(1, 1)
	tap.ZIndex = 5
	tap.Visible = false
	tap.Parent = panel

	local frame3 = Style.frame(panel, "InHand", UDim2.fromScale(1, 1))
	frame3.ZIndex = 4
	Style.corner(frame3, 4)
	Style.stroke(frame3, 2, 0, Style.HAZARD, true)
	frame3.Visible = false

	local function streakTool()
		for _, v4 in { player.Character, player:FindFirstChildOfClass("Backpack") } do
			if not v4 then
				continue
			end

			for _, tool in v4:GetChildren() do
				if tool:IsA("Tool") and set[tool.Name] then
					return tool
				end
			end
		end

		return nil
	end

	tap.Activated:Connect(function()
		local v4 = streakTool()
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if v4 and humanoid and humanoid.Health > 0 and v4.Parent ~= character then
			humanoid:EquipTool(v4)
		end
	end)
	local v4 = false
	local v5 = false
	local v6 = -1

	local function washStep(_, p: number): boolean
		if not v4 or v5 then
			return false
		end

		local backgroundTransparency = math.cos(math.floor(p * 10) / 10 * 4) * 0.12 + 0.72

		if backgroundTransparency ~= v6 then
			v6 = backgroundTransparency
			fill.BackgroundTransparency = backgroundTransparency
		end

		return true
	end

	local function setWash(visible: boolean) -- 1 equivalent call inferred from this helper
		if visible == v4 then
			return
		end

		v4 = visible
		fill.Visible = visible
		tap.Visible = visible and touch

		if visible then
			Style.animate(fill, washStep)
		end
	end

	local region2 = Style.region(hud, "Scrap", Vector2.new(0, 1), Vector2.new(14, -68), Vector2.new(196, 28))
	Style.boost(region2, Style.touchHud())

	local vector2 = Vector2.new(0, 1)
	local function place()
		local v7 = Style.scale() * Style.touchHud()
		local v8

		if touch then
			local item = TouchLayout.item("streak")
			Style.boost(region, Style.touchHud() * item.s)
			local spot = TouchLayout.spot(item, vector2, Vector2.new(196, 44) * (v7 * item.s), hud.AbsoluteSize)
			local udim

			if TouchLayout.editing then
				udim = UDim2.fromScale(-4, -4)
			elseif spot then
				udim = UDim2.fromOffset(spot.X, spot.Y)
			else
				udim = UDim2.new(0, 14, 1, -18)
			end

			region.Position = udim
			v8 = spot and 1 or item.s
		else
			v8 = 1
		end

		region2.Position = UDim2.new(0, 14, 1, -18 - 50 * v7 * v8)
	end
	Style.onScale(place)

	if touch then
		TouchLayout.onChange(place)
		hud:GetPropertyChangedSignal("AbsoluteSize"):Connect(place)
		TouchLayout.register("streak", {
			kind = "hud",
			space = "hud",
			anchor = vector2,
			size = function()
				return Vector2.new(196, 44) * (Style.scale() * Style.touchHud())
			end,
			home = function(vector2_2: Vector2)
				return Vector2.new(14, vector2_2.Y - 18)
			end
		})
	end

	local frame4 = Style.frame(region2, "Row", UDim2.fromScale(0, 1))
	frame4.AutomaticSize = Enum.AutomaticSize.X
	local uiListLayout2 = Instance.new("UIListLayout")
	uiListLayout2.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout2.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout2.Padding = UDim.new(0, 6)
	uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout2.Parent = frame4
	local panel2 = Style.panel(frame4, "Chip", UDim2.fromOffset(0, 28))
	panel2.AutomaticSize = Enum.AutomaticSize.X
	panel2.LayoutOrder = 1
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, 8)
	uiPadding.PaddingRight = UDim.new(0, 10)
	uiPadding.Parent = panel2
	local uiListLayout3 = Instance.new("UIListLayout")
	uiListLayout3.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout3.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout3.Padding = UDim.new(0, 6)
	uiListLayout3.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout3.Parent = panel2
	local nut = Style.nut(panel2, 18)
	nut.LayoutOrder = 1
	local label4 = Style.label(panel2, "Balance", "0", 20, Style.FONT, 1.5)
	label4.TextColor3 = Style.HAZARD
	label4.LayoutOrder = 2
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = label4
	local label5 = Style.label(frame4, "Gain", "", 18, Style.FONT, 1.5)
	label5.TextColor3 = Style.HAZARD
	label5.LayoutOrder = 2
	label5.Visible = false
	local v7 = nil
	local v8 = -10
	local v9 = true
	local function scrapStep(_, p: number): boolean
		local v10 = p - v8

		if not v9 then
			uiScale.Scale = 1 + 0.25 * (1 - Style.easeOut((math.min(v10 / 0.15, 1))))
			v9 = v10 >= 0.15
		end

		if v10 >= 3 then
			label5.Visible = false
			return false
		end

		return true
	end

	local v10 = 0
	local function scrap()
		local scrap2 = player:GetAttribute("Scrap")

		if type(scrap2) ~= "number" then
			return
		end

		if v7 and v7 < scrap2 then
			local now = os.clock()
			v10 = (not (now - v8 < 3) and 0 or v10) + (scrap2 - v7)
			v8 = now
			label5.Text = "+" .. Style.thousands(v10)
			label5.Visible = true
			v9 = false
			Style.animate(label4, scrapStep)
		end

		v7 = scrap2
		label4.Text = Style.thousands(scrap2)
	end
	player:GetAttributeChangedSignal("Scrap"):Connect(scrap)
	scrap()

	local function keyNumber() -- 4 equivalent calls inferred from this helper
		return LoadoutStrip.streakKey(player)
	end

	local v11 = 0
	local function refresh()
		local streak = player:GetAttribute("Streak") or 0
		local airstrikes = player:GetAttribute("Airstrikes") or 0
		local streak2 = ShopData.streak(player)

		local v12 = streakTool()
		local visible = airstrikes > 0 or v12 ~= nil
		local v13

		if v12 then
			v13 = v12.Name
		else
			v13 = if airstrikes > 0 then Airstrike.TOOL else streak2
		end

		local kills = ShopData.item(v13).kills
		label.Text = string.upper(v13)

		if v ~= v13 then
			if v2 then
				v2:Destroy()
			end

			v2, v3 = StreakIcon.flat(v13, frame, Style.MUTED)
			v = v13
		end

		local v14 = streak % kills

		if v13 == Airstrike.TOOL and Airstrike.MAX_HELD <= airstrikes then
			v14 = kills
		end

		if v12 and v12.Name ~= Airstrike.TOOL or v13 ~= streak2 then
			v14 = kills
		end

		local v15 = kills * 22 + 10 + (kills - 1) * 5
		local v16 = not visible and 0 or (touch and 34 or 20) + 8 + (airstrikes > 1 and 26 or 0)
		region.Size = UDim2.fromOffset(math.max(196, v15 + 10 + v16), 44)

		for k, v17 in fills do
			v17.Visible = k <= kills
			local backgroundColor

			if k <= v14 then
				backgroundColor = Style.HAZARD
			else
				backgroundColor = Style.STEEL
			end

			v17.BackgroundColor3 = backgroundColor
		end

		frame2.Visible = visible
		local visible2

		if v12 == nil or player.Character == nil then
			visible2 = false
		else
			visible2 = v12.Parent == player.Character
		end

		label3.Visible = touch and visible and not visible2
		setWash(visible and not visible2) -- inferred equivalent call
		frame3.Visible = visible2
		Glyph.setCap(cap, tostring(keyNumber()), DPadDown)
		label2.Text = not (airstrikes > 1) and "" or "x" .. airstrikes
		local textColor = if visible then Style.WHITE else Style.MUTED
		label.TextColor3 = textColor

		if v3 then
			v3(label.TextColor3)
		end
	end

	local region3 = Style.region(hud, "StrikeBanner", Vector2.new(0.5, 0.3), Vector2.zero, Vector2.new(420, 60))
	local frame5 = Style.frame(region3, "Banner", UDim2.fromScale(1, 1))
	frame5.Visible = false
	local uiScale2 = Instance.new("UIScale")
	uiScale2.Parent = frame5
	local tape = Style.tape(frame5, "Tape", UDim2.new(1, 0, 0, 5), 420, 12)
	tape.Position = UDim2.fromOffset(0, 0)
	local label6 = Style.label(frame5, "Head", "", 30, Style.FONT, 2)
	label6.AnchorPoint = Vector2.new(0.5, 0)
	label6.Position = UDim2.new(0.5, 0, 0, 8)
	local label7 = Style.label(frame5, "Sub", "", 16, Style.FONT_BODY, 1.5)
	label7.AnchorPoint = Vector2.new(0.5, 0)
	label7.Position = UDim2.new(0.5, 0, 0, 40)
	label7.RichText = true

	local v12 = -1e999
	local function show(text: string, textColor: Color3, text2: string) -- 11 equivalent calls inferred from this helper
		label6.Text = text
		label6.TextColor3 = textColor
		label7.Text = text2
		frame5.Visible = true
		label6.TextTransparency = 0
		label7.TextTransparency = 0
		v12 = os.clock()

		local v13 = false
		Style.animate(frame5, function(_, p): boolean
			local v14 = p - v12

			if v14 < 3.2 then
				if not v13 then
					uiScale2.Scale = Style.pop(v14 / 0.22)
					v13 = v14 >= 0.22
				end

				return true
			else
				local v15 = (v14 - 3.2) / 0.35

				if v15 >= 1 then
					frame5.Visible = false
					return false
				end

				uiScale2.Scale = 1 - 0.1 * v15
				label6.TextTransparency = v15
				label7.TextTransparency = v15
				tape.BackgroundTransparency = v15
				return true
			end
		end)

		tape.BackgroundTransparency = 0
	end

	local v13 = player:GetAttribute("Airstrikes") or 0
	player:GetAttributeChangedSignal("Airstrikes"):Connect(function()
		local airstrikes = player:GetAttribute("Airstrikes") or 0

		if v13 < airstrikes then
			local hazard = Style.HAZARD
			local v14

			if touch then
				v14 = "Tap " .. Style.paint("AIRSTRIKE", Style.HAZARD) .. " bottom left"
			elseif Glyph.gamepad() then
				v14 = "Take it out with " .. Style.paint("[D-PAD DOWN]", Style.HAZARD)
			else
				v14 = "Take it out with " .. Style.paint("[" .. keyNumber() .. "]", Style.HAZARD) -- inferred equivalent call
			end

			show("AIRSTRIKE READY", hazard, v14 .. ", mark the ground and call it in") -- inferred equivalent call
			v11 = os.clock() + 1.2
			local v15 = nil
			Style.animate(fills, function(_, p): boolean
				local v16

				if p < v11 then
					v16 = math.floor(p * 8) % 2 == 0
				else
					v16 = false
				end

				if v16 ~= v15 then
					v15 = v16

					for _, v17 in fills do
						local backgroundColor

						if v16 then
							backgroundColor = Style.WHITE
						else
							backgroundColor = Style.HAZARD
						end

						v17.BackgroundColor3 = backgroundColor
					end
				end

				if v11 <= p then
					refresh()
					return false
				end

				return true
			end)
		end

		v13 = airstrikes
		refresh()
	end)
	player:GetAttributeChangedSignal("Streak"):Connect(refresh)
	player:GetAttributeChangedSignal(ShopData.STREAK_ATTR):Connect(refresh)

	airstrikeInbound.OnClientEvent:Connect(function(_, _, _, _, _, _, p: string?, p2: string?)
		if player.Team == nil then
			return
		end

		local v14

		if player.Team == nil or p == nil then
			v14 = false
		else
			v14 = player.Team.Name == p
		end

		if p2 == player.Name then
			show("STRIKE INBOUND", Style.HAZARD, "Jet on its way to your mark") -- inferred equivalent call
		elseif v14 then
			show( -- inferred equivalent call
				"FRIENDLY AIRSTRIKE",
				Style.HAZARD,
				Style.paint(not p2 and "A teammate" or Style.shown(p2), Style.WHITE) .. " called an airstrike. Keep out of the red"
			)
		else
			show( -- inferred equivalent call
				"ENEMY KILLSTREAK",
				Style.ORANGE,
				Style.paint(not p2 and "Someone" or Style.shown(p2), Style.WHITE) .. " called in a killstreak"
			)
		end
	end)

	HellfireState.OnClientEvent:Connect(function(p: string, _, p2: string?, p3: string?)
		if p ~= "start" or p2 == player.Name or player.Team == nil then
			return
		end

		local v14

		if player.Team == nil or p3 == nil then
			v14 = false
		else
			v14 = player.Team.Name == p3
		end

		if v14 then
			show( -- inferred equivalent call
				"FRIENDLY HELLFIRE",
				Style.HAZARD,
				Style.paint(not p2 and "A teammate" or Style.shown(p2), Style.WHITE) .. " launched a Hellfire missile"
			)
		else
			show( -- inferred equivalent call
				"ENEMY HELLFIRE",
				Style.ORANGE,
				Style.paint(not p2 and "Someone" or Style.shown(p2), Style.WHITE) .. " launched a Hellfire missile. Get under cover"
			)
		end
	end)

	GunshipState.OnClientEvent:Connect(function(p: string, _, p2: string?, p3: string?)
		if p ~= "start" or p2 == player.Name or player.Team == nil then
			return
		end

		local v14

		if player.Team == nil or p3 == nil then
			v14 = false
		else
			v14 = player.Team.Name == p3
		end

		if v14 then
			show( -- inferred equivalent call
				"FRIENDLY GUNSHIP",
				Style.HAZARD,
				Style.paint(not p2 and "A teammate" or Style.shown(p2), Style.WHITE) .. " has a gunship circling overhead"
			)
		else
			show( -- inferred equivalent call
				"ENEMY GUNSHIP",
				Style.ORANGE,
				Style.paint(not p2 and "Someone" or Style.shown(p2), Style.WHITE) .. " has a gunship overhead. Stay under a roof"
			)
		end
	end)

	local object = setmetatable({}, { __mode = "k" })
	local function minigunArrived(tool)
		if tool.Name == "Minigun" and tool:IsA("Tool") and not object[tool] then
			object[tool] = true
			local hazard = Style.HAZARD
			local v14

			if touch then
				v14 = "Tap MINIGUN bottom left"
			elseif Glyph.gamepad() then
				v14 = "Take it out with " .. Style.paint("[D-PAD DOWN]", Style.HAZARD)
			else
				v14 = "Take it out with " .. Style.paint("[" .. keyNumber() .. "]", Style.HAZARD) -- inferred equivalent call
			end

			show("MINIGUN READY", hazard, v14 .. " and hold fire to spin it up") -- inferred equivalent call
		elseif tool.Name == "Hellfire" and tool:IsA("Tool") and not object[tool] then
			object[tool] = true
			local hazard = Style.HAZARD
			local v14

			if touch then
				v14 = "Tap HELLFIRE bottom left, then fire to launch"
			elseif Glyph.gamepad() then
				v14 = "Take out the remote with " .. Style.paint("[D-PAD DOWN]", Style.HAZARD) .. " and fire to launch"
			else
				v14 = "Take out the remote with " .. Style.paint("[" .. keyNumber() .. "]", Style.HAZARD) .. " and click to launch" -- inferred equivalent call
			end

			show("HELLFIRE READY", hazard, v14) -- inferred equivalent call
		elseif tool.Name == "Gunship" and tool:IsA("Tool") and not object[tool] then
			object[tool] = true
			local hazard = Style.HAZARD
			local v14

			if touch then
				v14 = "Tap GUNSHIP bottom left, then fire to call it in"
			elseif Glyph.gamepad() then
				v14 = "Take out the radio with " .. Style.paint("[D-PAD DOWN]", Style.HAZARD) .. " and fire to call it in"
			else
				v14 = "Take out the radio with " .. Style.paint("[" .. keyNumber() .. "]", Style.HAZARD) .. " and click to call it in" -- inferred equivalent call
			end

			show("GUNSHIP READY", hazard, v14) -- inferred equivalent call
		end
	end

	local function watch(backpack) -- 3 equivalent calls inferred from this helper
		if backpack then
			backpack.ChildAdded:Connect(refresh)
			backpack.ChildRemoved:Connect(refresh)

			if backpack:IsA("Backpack") then
				backpack.ChildAdded:Connect(minigunArrived)
			end
		end
	end
	player.ChildAdded:Connect(function(backpack)
		if backpack:IsA("Backpack") then
			watch(backpack) -- inferred equivalent call
			refresh()
		end
	end)
	watch(player:FindFirstChildOfClass("Backpack")) -- inferred equivalent call
	data.onCharacter(function(backpack)
		watch(backpack) -- inferred equivalent call
		refresh()
	end)
	data.onDead(function(flag: boolean)
		v5 = flag
		region.Visible = not flag
		region2.Visible = not flag

		if not flag and v4 then
			Style.animate(fill, washStep)
		end
	end)
	refresh()
end

return Killstreak