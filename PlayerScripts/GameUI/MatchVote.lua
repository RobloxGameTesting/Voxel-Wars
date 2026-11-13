local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Style = require(script.Parent.Style)
local Glyph = require(script.Parent.Glyph)
local MatchVote = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("MatchVote"))

local v = {
	ironfield = Color3.fromRGB(58, 84, 62),
	sandline = Color3.fromRGB(150, 120, 74),
	saltpan = Color3.fromRGB(176, 150, 112),
	frostmill = Color3.fromRGB(122, 140, 158),
	pinewold = Color3.fromRGB(70, 96, 64),
	drywell = Color3.fromRGB(176, 150, 112),
	highcrag = Color3.fromRGB(150, 146, 138)
}

local touch = Style.isTouch()
local v2 = touch and 1.5 or 1
local v3 = v2 * 14
local v4 = v3 + 30 + 4
local v5 = touch and 20 or 17
local v6 = touch and 18 or 14
local v7 = v5 + 142 + v6 + 6
local v8 = touch and 20 or 18
local v9 = touch and 16 or 12
local v10 = v4 + v7 + 8
local v11 = v10 + 10 + 6
local v12 = v2 * 14
local v13 = v11 + v12 + 8

local v14 = v2 * 16
local v15 = touch and 152 or 128
local v16 = v15 / 2
local v17 = touch and 18 or 14
local v18 = v2 * 4
local v19 = touch and 18 or 13
local v20 = v14 + 2
local v21 = v16 + 3 + 1 + v17 + 1
local v22 = v20 + v21 + 2

local v23 = {
	[Enum.KeyCode.One] = 1,
	[Enum.KeyCode.KeypadOne] = 1,
	[Enum.KeyCode.DPadLeft] = 1,
	[Enum.KeyCode.Two] = 2,
	[Enum.KeyCode.KeypadTwo] = 2,
	[Enum.KeyCode.DPadUp] = 2,
	[Enum.KeyCode.Three] = 3,
	[Enum.KeyCode.KeypadThree] = 3,
	[Enum.KeyCode.DPadRight] = 3
}

local v24 = { Enum.KeyCode.DPadLeft, Enum.KeyCode.DPadUp, Enum.KeyCode.DPadRight }
local v25 = { Reds = "RED", Blues = "BLUE" }

local function num(value) -- 6 equivalent calls inferred from this helper
	return if type(value) == "number" then value else 0
end

local function str(value) -- 8 equivalent calls inferred from this helper
	return if type(value) == "string" then value else ""
end

local object = setmetatable({}, { __mode = "k" })
local function put(p, p2: string, p3) -- 36 equivalent calls inferred from this helper
	local v26 = object[p]

	if not v26 then
		v26 = {}
		object[p] = v26
	end

	if v26[p2] ~= p3 then
		v26[p2] = p3
		p[p2] = p3
	end
end

local function optionColor(p: number) -- 2 equivalent calls inferred from this helper
	if p == 1 then
		return (Style.teamColor("Blues"))
	elseif p == 2 then
		return Style.GOOD
	end

	return (Style.teamColor("Reds"))
end

local function fitted(panel, p: string, p2, p3: number, size: UDim2, position: UDim2) -- 2 equivalent calls inferred from this helper
	local label = Style.label(panel, p, "", 14, p2, p3)
	label.AutomaticSize = Enum.AutomaticSize.None
	label.TextScaled = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Size = size
	label.Position = position
	return label
end

return {
	mount = function(p)
		local player = p.player
		local Game = ReplicatedStorage:WaitForChild("Game")
		local vote = Game:WaitForChild("Vote")
		local vote2 = Game:WaitForChild("Remotes"):WaitForChild("Vote")
		local touch2 = Style.isTouch()

		local layer = Style.layer(p.playerGui, "GameVote", 7)
		layer.Enabled = false
		local region = Style.region(
			layer,
			"MatchVote",
			Vector2.new(0.5, 0),
			Vector2.new(0, Style.topInset() + 6),
			Vector2.new(816, v13)
		)
		Style.fit(region, Vector2.new(816, v13 + 24), 0.96)
		region.Visible = false
		local frame = Style.frame(
			region,
			"Body",
			UDim2.fromOffset(816, v13),
			UDim2.fromOffset(408, 0),
			Vector2.new(0.5, 0)
		)

		local label = Style.label(frame, "Head", "", 24, Style.FONT, 1.5)
		label.AutomaticSize = Enum.AutomaticSize.None
		label.Size = UDim2.new(1, 0, 0, 30)
		label.RichText = true
		local label2 = Style.label(frame, "Sub", "", v2 * 12, Style.FONT, 1)
		label2.AutomaticSize = Enum.AutomaticSize.None
		label2.Size = UDim2.new(1, 0, 0, v3)
		label2.Position = UDim2.fromOffset(0, 30)
		label2.TextColor3 = Style.MUTED

		local function vote3(p2: number)
			if
				vote:GetAttribute("Stage") == "vote"
				and p2 <= num(vote:GetAttribute("Count")) -- inferred equivalent call
				and player:GetAttribute("Vote") ~= p2
			then
				vote2:FireServer(p2)
			end
		end

		local function makeCard(i: number)
			local v26 = optionColor(i) -- inferred equivalent call
			local frame2 = Style.frame(
				frame,
				"Card" .. i,
				UDim2.fromOffset(264, v7),
				UDim2.fromOffset(0, v4),
				Vector2.new(0.5, 0)
			)
			local uiScale = Instance.new("UIScale")
			uiScale.Parent = frame2
			local frame3 = Style.frame(
				frame2,
				"Edge",
				UDim2.new(1, 8, 1, 8),
				UDim2.fromScale(0.5, 0.5),
				Vector2.new(0.5, 0.5)
			)
			Style.corner(frame3, 6)
			Style.stroke(frame3, 3, 0, Style.HAZARD, true)
			frame3.Visible = false
			local panel = Style.panel(frame2, "Plate", UDim2.fromScale(1, 1), 4)
			panel.BackgroundTransparency = 0.08
			panel.ClipsDescendants = true
			local fill = Style.fill(panel, "Stripe", v26, UDim2.new(1, 0, 0, 6))

			local picture = Instance.new("ImageLabel")
			picture.Name = "Picture"
			picture.BackgroundColor3 = Style.INK
			picture.BorderSizePixel = 0
			picture.ScaleType = Enum.ScaleType.Crop
			picture.Size = UDim2.new(1, 0, 0, 132)
			picture.Position = UDim2.fromOffset(0, 6)
			picture.Parent = panel
			local fill2 = Style.fill(picture, "StandIn", Style.STEEL, UDim2.fromScale(1, 1))
			local uiGradient = Instance.new("UIGradient")
			uiGradient.Rotation = 90
			uiGradient.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(110, 110, 110))
			uiGradient.Parent = fill2
			local label3 = Style.label(fill2, "MapName", "", 30, Style.FONT, 2)
			label3.AutomaticSize = Enum.AutomaticSize.None
			label3.Size = UDim2.new(1, 0, 1, -20)
			label3.TextTransparency = 0.15

			local fill3 = Style.fill(
				picture,
				"Shade",
				Style.INK,
				UDim2.new(1, 0, 0, 44),
				UDim2.fromScale(0, 1),
				Vector2.new(0, 1)
			)
			local uiGradient2 = Instance.new("UIGradient")
			uiGradient2.Rotation = 90
			uiGradient2.Transparency = NumberSequence.new(1, 0.15)
			uiGradient2.Parent = fill3
			local label4 = Style.label(picture, "Map", "", v8, Style.FONT, 1.5)
			label4.AnchorPoint = Vector2.new(0, 1)
			label4.ZIndex = 2

			local name = fitted(panel, "Name", Style.FONT, 1, UDim2.new(1, -24, 0, v5), UDim2.fromOffset(12, 142)) -- inferred equivalent call
			name.TextColor3 = v26:Lerp(Color3.new(1, 1, 1), 0.45)
			local blurb = fitted( -- inferred equivalent call
				panel,
				"Blurb",
				Style.FONT_BODY,
				0,
				UDim2.new(1, -24, 0, v6),
				UDim2.fromOffset(12, v5 + 142)
			)
			blurb.TextColor3 = Style.MUTED

			local label5 = Style.label(picture, "Votes", "", v8, Style.FONT, 1.5)
			label5.RichText = true
			label5.AnchorPoint = Vector2.new(1, 1)
			label5.ZIndex = 2
			local cap = Glyph.cap(panel, nil, nil, 22)
			cap.Position = UDim2.fromOffset(12, 14)
			cap.ZIndex = 3
			Glyph.setCap(cap, tostring(i), v24[i])
			cap.Visible = not touch2
			local fill4 = Style.fill(frame2, "Dim", Style.INK, UDim2.fromScale(1, 1))
			Style.corner(fill4, 4)
			fill4.BackgroundTransparency = 1
			fill4.ZIndex = 3
			local hit = Instance.new("TextButton")
			hit.Name = "Hit"
			hit.Text = ""
			hit.BackgroundTransparency = 1
			hit.AnchorPoint = Vector2.new(0.5, 0.5)
			hit.Position = UDim2.fromScale(0.5, 0.5)
			hit.Size = UDim2.new(1, v18, 1, v2 * 8)
			hit.ZIndex = 8
			hit.Parent = frame2
			hit.Activated:Connect(function()
				vote3(i)
			end)
			return {
				holder = frame2,
				pop = uiScale,
				plate = panel,
				name = name,
				map = label4,
				blurb = blurb,
				votes = label5,
				key = cap,
				edge = frame3,
				dim = fill4,
				stripe = fill,
				shade = fill3,
				pic = picture,
				standIn = fill2,
				standInName = label3,
				shownMap = nil,
				shownVotes = nil,
				shownCompact = nil
			}
		end

		local box = Style.box(frame, "Bar", Style.INK, UDim2.fromOffset(792, 10), 2, 2)
		box.AnchorPoint = Vector2.new(0.5, 0)
		box.Position = UDim2.fromOffset(408, v10)
		box.ClipsDescendants = true
		local v26 = {}
		local v27 = {}
		local v28 = {}
		local v29 = {}

		for i = 1, 3 do
			v26[i] = Style.fill(box, "Segment" .. i, optionColor(i), UDim2.fromScale(1 / 3, 1)) -- inferred equivalent call
			v27[i] = Style.fill(
				box,
				"Notch" .. i,
				Style.WHITE,
				UDim2.new(0, 3, 1, 0),
				UDim2.fromScale(0, 0),
				Vector2.new(0.5, 0)
			)
			v27[i].ZIndex = 2
			v28[i] = 1 / 3
		end

		local v30 = table.create(3, 0)

		local label3 = Style.label(region, "Side", "", v2 * 12, Style.FONT, 1.5)
		label3.AutomaticSize = Enum.AutomaticSize.None
		label3.Size = UDim2.new(1, 0, 0, v12)
		label3.Position = UDim2.fromOffset(0, v11)
		label3.RichText = true

		UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
			local v31 = v23[input.KeyCode]

			if v31 and not gameProcessed and region.Visible then
				vote3(v31)
			end
		end)

		local v31 = 0
		local lastTime = 0
		local v32 = 0

		local v33 = {}
		local function attr(p2: string, p3: number) -- 7 equivalent calls inferred from this helper
			local v34 = v33[p2]

			if not v34 then
				v34 = {}
				v33[p2] = v34
			end

			local v35 = v34[p3]

			if not v35 then
				v35 = p2 .. p3
				v34[p3] = v35
			end

			return v35
		end

		local v34 = ""
		local v35 = -1
		local v36 = false
		local v37 = nil
		local v38 = nil
		local v39 = nil
		local v40 = nil

		local renderSteppedConnection = nil
		local function step(p2: number)
			local v41 = str(vote:GetAttribute("Stage")) -- inferred equivalent call
			Glyph.claim("vote", v41 ~= "")

			if v41 == "" then
				if region.Visible then
					region.Visible = false
					layer.Enabled = false
					v31 = 0

					for k in v28 do
						v28[k] = 1 / 3
					end

					v32 = 0
				end

				if renderSteppedConnection then
					renderSteppedConnection:Disconnect()
					renderSteppedConnection = nil
				end
			else
				if not region.Visible then
					layer.Enabled = true
					region.Visible = true
				end

				local serverTimeNow = workspace:GetServerTimeNow()
				local v42 = num(vote:GetAttribute("Count")) -- inferred equivalent call
				local v43 = num(vote:GetAttribute("Picked")) -- inferred equivalent call
				local vote4 = player:GetAttribute("Vote")

				local v44 = type(vote4) == "number" and vote4 > 0 or v41 == "picked"
				local v45 = v32
				local v46

				if v44 then
					v46 = p2
				else
					v46 = -p2
				end

				v32 = math.clamp(v45 + v46 * 7 * 0.5, 0, 1)
				local smoothed = Style.smooth(v32)
				local shownCompact = smoothed >= 0.5
				put(label2, "Visible", not shownCompact) -- inferred equivalent call
				put(label, "TextSize", math.round(24 + (v2 * 14 - 24) * smoothed)) -- inferred equivalent call
				put(label, "Size", UDim2.new(1, 0, 0, 30 + (v14 - 30) * smoothed)) -- inferred equivalent call
				put(label3, "Position", UDim2.fromOffset(0, v11 + (v22 - v11) * smoothed)) -- inferred equivalent call
				local v48 = 264 + (v15 - 264) * smoothed
				local v49 = v7 + (v21 - v7) * smoothed
				local v50 = 12 + (v18 - 12) * smoothed
				local v51 = v4 + (v20 - v4) * smoothed
				local v52 = 6 + -3 * smoothed
				local v53 = 132 + (v16 - 132) * smoothed
				local v54 = 12 - 6 * smoothed
				local v55 = v5 + (v17 - v5) * smoothed
				local v56 = v52 + v53 + 4 - 3 * smoothed
				local v57 = math.round(v8 + (v19 - v8) * smoothed)
				local v58 = 10 - 5 * smoothed
				local v59 = 4 - 3 * smoothed
				local v60

				if v41 == "vote" then
					v60 = num(vote:GetAttribute("EndsAt")) - serverTimeNow -- inferred equivalent call
				else
					v60 = num(vote:GetAttribute("StartsAt")) - serverTimeNow -- inferred equivalent call
				end

				local v61 = math.max(0, (math.ceil(v60)))
				local v62 = v60 <= 5

				if v41 ~= v34 or v61 ~= v35 or v62 ~= v36 then
					v34 = v41
					v35 = v61
					v36 = v62
					local v63 = v41 == "vote" and "VOTE FOR THE NEXT GAME" or "GAME STARTING IN"
					local paint = Style.paint
					local clock = Style.clock(v60)
					local v65

					if v62 then
						v65 = Style.HAZARD
					else
						v65 = Style.WHITE
					end

					label.Text = v63 .. "  " .. paint(clock, v65)
				end

				if v41 == "vote" then
					v37 = nil
					v38 = nil
					put(label2, "Text", touch2 and "TAP A GAME TO VOTE" or "CLICK A GAME OR PRESS 1 / 2 / 3 TO VOTE") -- inferred equivalent call
				else
					local v63 = str(vote:GetAttribute(attr("Name", v43))) -- inferred equivalent call
					local v64 = str(vote:GetAttribute(attr("MapName", v43))) -- inferred equivalent call

					if v63 ~= v37 or v64 ~= v38 then
						v37 = v63
						v38 = v64
						put(label2, "Text", v63 .. " ON " .. v64) -- inferred equivalent call
					end
				end

				for i = #v29 + 1, v42 do
					v29[i] = makeCard(i)
				end

				if v43 ~= v31 then
					v31 = v43
					lastTime = os.clock()
				end

				local v63 = os.clock() - lastTime

				for k, v64 in v29 do
					local v65 = k <= v42
					put(v64.holder, "Visible", v65) -- inferred equivalent call

					if not v65 then
						continue
					end

					put(v64.holder, "Position", UDim2.fromOffset(408 + (k - (v42 + 1) / 2) * (v48 + v50), v51)) -- inferred equivalent call
					put(v64.holder, "Size", UDim2.fromOffset(v48, v49)) -- inferred equivalent call
					put(v64.stripe, "Size", UDim2.new(1, 0, 0, v52)) -- inferred equivalent call
					put(v64.pic, "Position", UDim2.fromOffset(0, v52)) -- inferred equivalent call
					put(v64.pic, "Size", UDim2.new(1, 0, 0, v53)) -- inferred equivalent call
					put(v64.shade, "Size", UDim2.new(1, 0, 0, 44 - 18 * smoothed)) -- inferred equivalent call
					put(v64.map, "TextSize", v57) -- inferred equivalent call
					put(v64.map, "Position", UDim2.new(0, v58, 1, -v59)) -- inferred equivalent call
					put(v64.votes, "TextSize", v57) -- inferred equivalent call
					put(v64.votes, "Position", UDim2.new(1, -v58, 1, -v59)) -- inferred equivalent call
					put(v64.standInName, "TextSize", math.round(30 - 14 * smoothed)) -- inferred equivalent call
					put(v64.name, "Position", UDim2.fromOffset(v54, v56)) -- inferred equivalent call
					put(v64.name, "Size", UDim2.new(1, -2 * v54, 0, v55)) -- inferred equivalent call
					put(v64.blurb, "Position", UDim2.fromOffset(v54, v56 + v55)) -- inferred equivalent call
					put(v64.blurb, "Visible", not shownCompact) -- inferred equivalent call
					put(v64.name, "Text", str(vote:GetAttribute(attr("Name", k)))) -- inferred equivalent call
					local text = str(vote:GetAttribute(attr("MapName", k))) -- inferred equivalent call
					put(v64.map, "Text", text) -- inferred equivalent call
					local shownMap = str(vote:GetAttribute(attr("Map", k))) -- inferred equivalent call

					if shownMap ~= v64.shownMap then
						v64.shownMap = shownMap
						local image = MatchVote.MAP_IMAGES[shownMap] or ""
						v64.pic.Image = image
						v64.standIn.Visible = image == ""
						v64.standIn.BackgroundColor3 = v[shownMap] or Style.STEEL
						v64.standInName.Text = text
						v64.map.Visible = image ~= ""
					end

					put(v64.blurb, "Text", str(vote:GetAttribute(attr("Blurb", k)))) -- inferred equivalent call
					local shownVotes = num(vote:GetAttribute(attr("Votes", k))) -- inferred equivalent call
					v30[k] = shownVotes

					if shownVotes ~= v64.shownVotes or shownCompact ~= v64.shownCompact then
						v64.shownVotes = shownVotes
						v64.shownCompact = shownCompact
						local votes = v64.votes
						local text2

						if shownCompact then
							text2 = tostring(shownVotes)
						else
							text2 = tostring(shownVotes) .. "<font size=\"" .. v9 .. "\"> " .. (shownVotes == 1 and "VOTE" or "VOTES") .. "</font>"
						end

						votes.Text = text2
					end

					local key = v64.key
					local v69 = not touch2

					if v69 then
						if v41 == "vote" then
							v69 = not shownCompact
						else
							v69 = false
						end
					end

					put(key, "Visible", v69) -- inferred equivalent call
					local v70 = v43 == k
					local edge = v64.edge
					local v71

					if v70 then
						v71 = v70
					elseif v43 == 0 then
						v71 = vote4 == k
					else
						v71 = false
					end

					put(edge, "Visible", v71) -- inferred equivalent call

					if v70 then
						put(v64.pop, "Scale", 1 + 0.12 * (1 - Style.easeOut((math.clamp(v63 / 0.35, 0, 1))))) -- inferred equivalent call
					else
						put(v64.pop, "Scale", 1) -- inferred equivalent call
					end

					put( -- inferred equivalent call
						v64.dim,
						"BackgroundTransparency",
						(not (v43 > 0) or v70) and 1 or 1 - math.clamp(v63 / 0.3, 0, 1) * 0.55
					)
				end

				put(box, "Visible", not shownCompact and v42 >= 2) -- inferred equivalent call

				if not shownCompact then
					local total = 0

					for i = 1, math.min(v42, 3) do
						total += v30[i]
					end

					local total2 = 0

					for k, v66 in v26 do
						local v67 = k <= v42
						put(v66, "Visible", v67) -- inferred equivalent call
						put(v27[k], "Visible", k < v42) -- inferred equivalent call

						if not v67 then
							continue
						end

						local v68

						if total > 0 then
							v68 = v30[k] / total
						else
							v68 = 1 / v42
						end

						v28[k] += (v68 - v28[k]) * math.min(1, p2 * 8)

						if math.abs(v68 - v28[k]) * 792 < 0.1 then
							v28[k] = v68
						end

						put(v66, "Position", UDim2.fromScale(total2, 0)) -- inferred equivalent call
						put(v66, "Size", UDim2.fromScale(v28[k], 1)) -- inferred equivalent call
						total2 += v28[k]
						put(v27[k], "Position", UDim2.fromScale(total2, 0)) -- inferred equivalent call
					end
				end

				local v66 = str(player:GetAttribute("NextTeam")) -- inferred equivalent call

				if v66 == v39 and v41 == v40 then
					return
				end

				v39 = v66
				v40 = v41

				if v66 == "Reds" or v66 == "Blues" then
					label3.Text = "YOUR SIDE: " .. Style.paint(v25[v66], Style.teamText(v66)) .. Style.paint(
						"  ·  STEP OUT TO STAY IN THE LOBBY",
						Style.MUTED
					)
				else
					label3.Text = Style.paint("STAND IN A RING TO PLAY THE NEXT GAME", Style.HAZARD)
				end
			end
		end
		vote:GetAttributeChangedSignal("Stage"):Connect(function()
			if not renderSteppedConnection then
				renderSteppedConnection = RunService.RenderStepped:Connect(step)
			end
		end)
		renderSteppedConnection = RunService.RenderStepped:Connect(step)
	end
}