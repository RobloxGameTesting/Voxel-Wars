local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Style = require(script.Parent.Style)
local Hardpoint = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("Hardpoint"))

local function num(value) -- 6 equivalent calls inferred from this helper
	return if type(value) == "number" then value else 0
end

local function str(value) -- 2 equivalent calls inferred from this helper
	return if type(value) == "string" then value else ""
end

return {
	mount = function(data)
		local domination = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Domination", 30)
		assert(
			domination and domination:IsA("Configuration"),
			"BreakthroughHud: ReplicatedStorage.Game.Domination is missing"
		)
		local player = data.player
		local hud = data.layers.hud
		assert(hud:IsA("ScreenGui"), "BreakthroughHud: the hud layer is not a ScreenGui")
		local function sideLayer(p: string) -- 2 equivalent calls inferred from this helper
			local layer = Style.layer(data.playerGui, hud.Name .. p, hud.DisplayOrder)
			layer.IgnoreGuiInset = hud.IgnoreGuiInset
			layer.ScreenInsets = hud.ScreenInsets
			return layer
		end

		local layer = sideLayer("Live") -- inferred equivalent call
		local layer2 = sideLayer("Banner") -- inferred equivalent call
		hud.Enabled = false
		layer.Enabled = false
		layer2.Enabled = false

		local vector2 = Vector2.new(0, Style.topInset() + 6)
		local region = Style.region(hud, "BreakthroughHud", Vector2.new(0.5, 0), vector2, Vector2.new(360, 60))
		local fill = Style.fill(
			region,
			"RoleBox",
			Style.PANEL,
			UDim2.fromOffset(76, 28),
			UDim2.new(0, 0, 0, 14),
			Vector2.new(0, 0.5)
		)
		fill.BackgroundTransparency = 0.2
		Style.corner(fill, 2)
		local label = Style.label(fill, "Role", "", 18, Style.FONT, 1.5)
		label.AutomaticSize = Enum.AutomaticSize.None
		label.Size = UDim2.fromScale(1, 1)
		local frame = Style.frame(
			region,
			"Sectors",
			UDim2.fromOffset(74, 8),
			UDim2.new(0, 82, 0, 14),
			Vector2.new(0, 0.5)
		)
		local label2 = Style.label(region, "SectorWord", "", 18, Style.FONT, 1.5)
		label2.Position = UDim2.fromOffset(0, 32)
		local label3 = Style.label(region, "TicketsWord", "TICKETS", 18, Style.FONT, 1.5)
		label3.TextColor3 = Style.MUTED
		label3.AnchorPoint = Vector2.new(1, 0)
		label3.Position = UDim2.new(1, 0, 0, 32)
		local fill_2 = Style.fill(
			region,
			"Track",
			Style.INK,
			UDim2.fromOffset(74, 8),
			UDim2.new(0, 204, 0, 14),
			Vector2.new(0, 0.5)
		)
		fill_2.BackgroundTransparency = 0.45
		local fill2 = Style.fill(
			region,
			"TicketsBox",
			Style.PANEL,
			UDim2.fromOffset(76, 28),
			UDim2.new(1, 0, 0, 14),
			Vector2.new(1, 0.5)
		)
		fill2.BackgroundTransparency = 0.2
		Style.corner(fill2, 2)

		local region2 = Style.region(layer, "BreakthroughHud", Vector2.new(0.5, 0), vector2, Vector2.new(360, 60))
		local fill3 = Style.fill(
			region2,
			"Fill",
			Style.WHITE,
			UDim2.fromOffset(74, 8),
			UDim2.new(0, 278, 0, 14),
			Vector2.new(1, 0.5)
		)
		local label4 = Style.label(region2, "Tickets", "", 22, Style.FONT, 1.5)
		label4.AutomaticSize = Enum.AutomaticSize.None
		label4.Size = UDim2.fromOffset(76, 28)
		label4.AnchorPoint = Vector2.new(1, 0.5)
		label4.Position = UDim2.new(1, 0, 0, 14)

		local region3 = Style.region(
			layer2,
			"BreakthroughBanner",
			Vector2.new(0.5, 0.36),
			Vector2.zero,
			Vector2.new(440, 84)
		)
		local panel = Style.panel(region3, "Plate", UDim2.fromScale(1, 1))
		local uiScale = Instance.new("UIScale")
		uiScale.Parent = panel
		local fill4 = Style.fill(panel, "Accent", Style.HAZARD, UDim2.new(1, 0, 0, 4))
		local label5 = Style.label(panel, "Headline", "", 34, Style.FONT, 2)
		label5.AnchorPoint = Vector2.new(0.5, 0)
		label5.Position = UDim2.new(0.5, 0, 0, 8)
		local label6 = Style.label(panel, "Detail", "", 18, Style.FONT_BODY, 1)
		label6.TextColor3 = Style.MUTED
		label6.AnchorPoint = Vector2.new(0.5, 0)
		label6.Position = UDim2.new(0.5, 0, 0, 52)

		local fills = {}
		local function buildPips(p: number)
			for _, v in fills do
				v:Destroy()
			end

			table.clear(fills)
			local v = (74 - (p - 1) * 4) / p

			for i = 1, p do
				local fill5 = Style.fill(
					frame,
					"Sector" .. i,
					Style.INK,
					UDim2.fromOffset(v, 8),
					UDim2.fromOffset((i - 1) * (v + 4), 0)
				)
				Style.corner(fill5, 2)
				fills[i] = fill5
			end
		end

		local v = nil
		local v2 = ""
		local v3 = ""
		local v4 = -1
		local v5 = -1
		local v6 = false
		local v7 = ""
		local v8 = ""
		local function forget() -- 1 equivalent call inferred from this helper
			v = nil
			v2 = ""
			v3 = ""
			v4 = -1
			v5 = -1
			v7 = ""
			v8 = ""
		end
		local function showBanner(enabled: boolean) -- 1 equivalent call inferred from this helper
			if enabled ~= v6 then
				v6 = enabled
				layer2.Enabled = enabled
			end
		end

		local attributes = domination:GetAttributes()
		domination.AttributeChanged:Connect(function(attributeName: string)
			attributes[attributeName] = domination:GetAttribute(attributeName)
		end)

		local function step()
			local v9 = str(attributes.Phase) -- inferred equivalent call
			local visible = v9 == "starting" or v9 == "live" or v9 == "moving"

			if visible ~= v then
				v = visible
				region.Visible = visible
				region2.Visible = visible
			end

			if visible then
				local attackers = attributes.Attackers
				local defenders = attributes.Defenders
				local v10 = (attackers == "Reds" or attackers == "Blues") and defenders == Hardpoint.other(attackers)
				assert(v10, "BreakthroughHud: Attackers/Defenders not set in breakthrough")
				local name

				if player.Team and not player.Neutral then
					name = player.Team.Name
				end

				if name ~= "Reds" and name ~= "Blues" then
					name = nil
				end

				local v11 = tostring(name) .. "|" .. attackers

				if v11 ~= v2 then
					v2 = v11
					fill.Visible = name ~= nil

					if name then
						label.Text = name == attackers and "ATTACK" or "DEFEND"
						label.TextColor3 = Style.teamText(name)
						fill.BackgroundColor3 = Style.teamColor(name):Lerp(Style.INK, 0.65)
					end

					fill2.BackgroundColor3 = Style.teamColor(attackers):Lerp(Style.INK, 0.65)
					fill3.BackgroundColor3 = Style.teamColor(attackers)
					v3 = ""
					v4 = -1
				end

				local v12 = num(attributes.Sector) -- inferred equivalent call
				local v13 = num(attributes.Sectors) -- inferred equivalent call
				local v14 = v13 >= 1 and v12 >= 1 and v12 <= v13
				assert(v14, "BreakthroughHud: bad Sector " .. v12 .. " of " .. v13)

				if v13 ~= #fills then
					buildPips(v13)
					v3 = ""
				end

				local v15 = v12 .. "/" .. v13

				if v15 ~= v3 then
					v3 = v15

					for k, v16 in fills do
						local backgroundColor

						if k < v12 then
							backgroundColor = Style.teamColor(attackers)
						elseif k == v12 then
							backgroundColor = Style.HAZARD
						else
							backgroundColor = Style.INK
						end

						v16.BackgroundColor3 = backgroundColor
						v16.BackgroundTransparency = v12 < k and 0.45 or 0
					end

					label2.Text = "SECTOR " .. v12 .. " OF " .. v13
				end

				local v16 = num(attributes.Tickets) -- inferred equivalent call
				local v17 = num(attributes.TicketsMax) -- inferred equivalent call
				assert(v17 > 0, "BreakthroughHud: TicketsMax not set in breakthrough")

				if v16 ~= v4 or v17 ~= v5 then
					v4 = v16
					v5 = v17
					fill3.Size = UDim2.fromOffset(math.clamp(v16 / v17, 0, 1) * 74, 8)
					label4.Text = tostring((math.max(0, v16)))
					local textColor

					if v16 <= v17 * 0.25 then
						textColor = Style.HAZARD
					else
						textColor = Style.teamText(attackers)
					end

					label4.TextColor3 = textColor
				end

				local serverTimeNow = workspace:GetServerTimeNow()
				local v18 = str(attributes.SectorEvent) -- inferred equivalent call
				local v19 = num(attributes.SectorEventAt) -- inferred equivalent call
				local v20 = v9 == "moving"
				local v21

				if v18 == "" or not (v19 > 0) then
					v21 = false
				else
					v21 = serverTimeNow - v19 < 4
				end

				if v20 then
					v21 = v20
				elseif v21 then
					v21 = v18 ~= "start" or v12 ~= 1
				end

				showBanner(v21) -- inferred equivalent call

				if not v21 then
					return
				end

				local v22 = v20 or v18 == "captured" or v18 == "lost"
				assert(v22 or v18 == "start", "BreakthroughHud: unknown SectorEvent " .. v18)
				local v23 = name == attackers
				local v24 = (v22 and "fell" or "start") .. v19 .. "|" .. tostring(name)

				if v24 ~= v7 then
					v7 = v24
					local textColor, text

					if v22 then
						if name == nil then
							textColor = Style.WHITE
							text = "SECTOR CAPTURED"
						elseif v23 then
							textColor = Style.teamText(name)
							text = "SECTOR CAPTURED"
						else
							textColor = Style.HAZARD
							text = "FALL BACK"
						end
					elseif name == nil then
						text = "SECTOR " .. v12 .. " OPEN"
						textColor = Style.WHITE
					elseif v23 then
						text = "ATTACK SECTOR " .. v12
						textColor = Style.teamText(name)
					else
						textColor = Style.teamText(name)
						text = "HOLD THE LINE"
					end

					label5.Text = text
					label5.TextColor3 = textColor
					local backgroundColor

					if textColor == Style.HAZARD or name == nil then
						backgroundColor = Style.HAZARD
					else
						backgroundColor = Style.teamColor(name)
					end

					fill4.BackgroundColor3 = backgroundColor
					v8 = ""
					local now = os.clock()
					Style.animate(uiScale, function(_, p): boolean
						local v25 = (p - now) / 0.25
						uiScale.Scale = Style.pop(v25)
						return v25 < 1
					end)
				end

				local text

				if v20 then
					local v25 = num(attributes.MoveEndsAt) -- inferred equivalent call
					assert(v25 > 0, "BreakthroughHud: MoveEndsAt not set while moving")
					text = "NEXT SECTOR IN " .. Style.clock(v25 - serverTimeNow)
				elseif v22 then
					text = ""
				else
					local letters = {}

					for _, v25 in Hardpoint.POINTS do
						table.insert(letters, v25.letter)
					end

					text = ((v23 or name == nil) and "TAKE " or "KEEP ") .. table.concat(letters, " AND ")
				end

				if text ~= v8 then
					v8 = text
					label6.Text = text
				end
			elseif v6 ~= false then
				v6 = false
				layer2.Enabled = false
			end
		end

		local heartbeatConnection = nil
		local function check()
			local enabled = domination:GetAttribute("GameMode") == "breakthrough"

			if enabled == (heartbeatConnection ~= nil) then
				return
			end

			hud.Enabled = enabled
			layer.Enabled = enabled

			if enabled then
				forget() -- inferred equivalent call
				heartbeatConnection = RunService.Heartbeat:Connect(step)
			else
				heartbeatConnection:Disconnect()
				heartbeatConnection = nil

				if v6 ~= false then
					v6 = false
					layer2.Enabled = false
				end
			end
		end
		domination:GetAttributeChangedSignal("GameMode"):Connect(check)
		check()
	end
}