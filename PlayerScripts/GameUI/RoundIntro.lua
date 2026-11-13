local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Style = require(script.Parent.Style)
local Hardpoint = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("Hardpoint"))
local Music = require(script.Parent.Music)
local Settings = require(script.Parent.Settings)
local MusicTracks = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("MusicTracks"))

local function objective()
	if #Hardpoint.POINTS == 1 then
		return "TAKE THE " .. Hardpoint.NAME
	end

	local letters = {}

	for _, v in Hardpoint.POINTS do
		table.insert(letters, v.letter)
	end

	return "TAKE AND HOLD " .. table.concat(letters, " · ")
end

local function breakthroughLine(domination, name: string?)
	local sector = domination:GetAttribute("Sector")
	assert(type(sector) == "number", "RoundIntro: breakthrough without Sector")
	local letters = {}

	for _, v in Hardpoint.POINTS do
		table.insert(letters, v.letter)
	end

	local v = name == nil or name == domination:GetAttribute("Attackers")

	return (v and "ATTACK SECTOR " or "DEFEND SECTOR ") .. sector .. "  ·  " .. (v and "TAKE " or "KEEP ") .. table.concat(letters, " AND ")
end

local function num(value) -- 6 equivalent calls inferred from this helper
	return if type(value) == "number" then value else 0
end

return {
	mount = function(data)
		local domination = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Domination", 30)
		assert(
			domination and domination:IsA("Configuration"),
			"RoundIntro: ReplicatedStorage.Game.Domination is missing (the server's Game.Domination did not start)"
		)
		local player = data.player

		local layer = Style.layer(data.playerGui, "RoundIntroShade", 6, true)
		layer.Enabled = false
		local fill = Style.fill(
			layer,
			"RoundIntroBand",
			Style.INK,
			UDim2.new(1, 0, 0, 0),
			UDim2.fromScale(0.5, 0.42),
			Vector2.new(0.5, 0.5)
		)
		fill.Visible = false
		local uiGradient = Instance.new("UIGradient")
		uiGradient.Rotation = 90
		uiGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.3, 0.45),
			NumberSequenceKeypoint.new(0.7, 0.45),
			NumberSequenceKeypoint.new(1, 1)
		})

		uiGradient.Parent = fill

		local region = Style.region(
			data.layers.hud,
			"RoundIntro",
			Vector2.new(0.5, 0.42),
			Vector2.new(0, 0),
			Vector2.new(520, 200)
		)
		region.AnchorPoint = Vector2.new(0.5, 0.5)
		region.Visible = false
		local tape = Style.tape(region, "Tape", UDim2.fromOffset(180, 5), 180)
		tape.AnchorPoint = Vector2.new(0.5, 0)
		tape.Position = UDim2.new(0.5, 0, 0, 6)
		local label = Style.label(region, "Round", "", 20, Style.FONT, 1.5)
		label.TextColor3 = Style.MUTED
		label.AnchorPoint = Vector2.new(0.5, 0)
		label.Position = UDim2.new(0.5, 0, 0, 16)
		local label2 = Style.label(region, "Count", "", 92, Style.FONT, 2.5)
		label2.AnchorPoint = Vector2.new(0.5, 0.5)
		label2.Position = UDim2.new(0.5, 0, 0, 96)
		local uiScale = Instance.new("UIScale")
		uiScale.Parent = label2
		local label3 = Style.label(region, "Objective", "", 18, Style.FONT_BODY, 1.5)
		label3.RichText = true
		label3.AnchorPoint = Vector2.new(0.5, 0)
		label3.Position = UDim2.new(0.5, 0, 0, 152)

		local function setAlpha(p: number)
			local v = 1 - p

			for _, v2 in { label, label2, label3 } do
				v2.TextTransparency = v
				local uiStroke = v2:FindFirstChildOfClass("UIStroke")

				if uiStroke then
					uiStroke.Transparency = v * 0.75 + 0.25
				end
			end

			tape.BackgroundTransparency = v

			for _, frame in tape:GetChildren() do
				if frame:IsA("Frame") then
					frame.BackgroundTransparency = v
				end
			end

			fill.Size = UDim2.new(1, 0, 0, 320)
			fill.BackgroundTransparency = 1 - p
		end

		local v = -1
		local v2 = -1
		local v3 = -1

		local function tail() -- 2 equivalent calls inferred from this helper
			if Settings.track(player) ~= MusicTracks.OFF then
				Music.tail(12, 10)
			end
		end

		local fn

		player.CharacterAdded:Connect(function(character)
			local lastTime = os.clock()

			while os.clock() - lastTime < 0.5 and character:GetAttribute("IntroUntil") == nil do
				task.wait()
			end

			if player.Character ~= character or not player.Team or player.Neutral then
				return
			end

			local v4 = num(domination:GetAttribute("StartsAt")) -- inferred equivalent call

			if domination:GetAttribute("Phase") ~= "live" or v4 <= 0 or v3 == v4 then
				return
			end

			v3 = v4
			local serverTimeNow = workspace:GetServerTimeNow()
			local v5 = num(domination:GetAttribute("EndsAt")) -- inferred equivalent call

			if v5 > 0 and v5 - serverTimeNow < 45 then
				return
			end

			local track = Settings.track(player)

			if track == MusicTracks.OFF then
				return
			end

			local v6 = num(character:GetAttribute("IntroUntil")) -- inferred equivalent call
			local v7 = not (serverTimeNow < v6) and 4 or v6 - serverTimeNow
			local hit = MusicTracks.byId[track].hit
			local v8 = math.clamp(v7, 1, hit)
			v = v4
			Music.play(track, hit - v8)
			v2 = serverTimeNow + v8 + 4.5
			fn()
			task.delay(v8, function()
				if player.Character == character and Music.isPlaying() then
					tail() -- inferred equivalent call
				end
			end)
		end)

		local v4 = ""
		local v5 = ""
		local v6 = ""
		local v7 = nil
		local v8 = -1
		local lastTime = -1
		local flag = false
		local v9 = false

		local function show(flag2: boolean)
			if flag2 ~= v9 then
				v9 = flag2
				region.Visible = flag2
				fill.Visible = flag2
				layer.Enabled = flag2
			end
		end
		local function setText(text: string, textColor: Color3) -- 1 equivalent call inferred from this helper
			if text ~= v4 then
				v4 = text
				label2.Text = text
			end

			if textColor ~= v7 then
				v7 = textColor
				label2.TextColor3 = textColor
			end
		end
		local function popBig() -- 2 equivalent calls inferred from this helper
			local now = os.clock()
			Style.animate(uiScale, function(_, p): boolean
				local v10 = (p - now) / 0.25
				uiScale.Scale = 1 + 0.18 * (1 - Style.easeOut(v10))
				return v10 < 1
			end)
		end

		local renderSteppedConnection = nil
		local function step()
			local phase = domination:GetAttribute("Phase")
			local v10 = num(domination:GetAttribute("StartsAt")) -- inferred equivalent call
			local serverTimeNow = workspace:GetServerTimeNow()
			local v11 = phase == "starting"

			if v11 then
				if not flag then
					flag = true
					lastTime = -1
					v8 = -1
					setAlpha(1)
				end

				if v9 ~= true then
					v9 = true
					region.Visible = true
					fill.Visible = true
					layer.Enabled = true
				end

				local name

				if player.Team and not player.Neutral then
					name = player.Team.Name
				end

				local text = "ROUND " .. math.max(1, num(domination:GetAttribute("Round"))) -- inferred equivalent call

				if text ~= v5 then
					v5 = text
					label.Text = text
				end

				local v12 = not name and "" or Style.paint(string.upper(name), Style.teamText(name)) .. "  ·  "
				local v13

				if
					domination:GetAttribute("GameMode") == "spawnraid"
					or domination:GetAttribute("GameMode") == "siege"
				then
					v13 = "DESTROY THEIR SPAWNS"
				elseif domination:GetAttribute("GameMode") == "tdm" then
					v13 = "FIRST TO " .. num(domination:GetAttribute("Target")) .. " KILLS" -- inferred equivalent call
				elseif domination:GetAttribute("GameMode") == "breakthrough" then
					v13 = breakthroughLine(domination, name)
				else
					v13 = objective()
				end

				local text2 = v12 .. v13

				if text2 ~= v6 then
					v6 = text2
					label3.Text = text2
				end

				if v10 <= 0 then
					local white = Style.WHITE

					if v4 ~= "STAND BY" then
						v4 = "STAND BY"
						label2.Text = "STAND BY"
					end

					if white ~= v7 then
						v7 = white
						label2.TextColor3 = white
					end
				else
					local v14 = v10 - serverTimeNow
					local v15 = math.max(1, (math.ceil(v14)))
					local text3 = tostring(v15)
					local v16

					if v15 <= 3 then
						v16 = Style.HAZARD
					else
						v16 = Style.WHITE
					end

					setText(text3, v16) -- inferred equivalent call

					if v15 ~= v8 then
						v8 = v15
						popBig() -- inferred equivalent call
					end

					if name then
						v3 = v10
					end

					if v ~= v10 and v14 > 2 then
						v = v10
						v2 = -1
						Music.play(Settings.track(player), Hardpoint.COUNTDOWN - v14)
					end
				end
			elseif flag then
				flag = false

				if phase == "live" then
					lastTime = os.clock()
					local hazard = Style.HAZARD

					if v4 ~= "MOVE OUT" then
						v4 = "MOVE OUT"
						label2.Text = "MOVE OUT"
					end

					if hazard ~= v7 then
						v7 = hazard
						label2.TextColor3 = hazard
					end

					popBig() -- inferred equivalent call

					if v == v10 and Music.isPlaying() then
						v2 = serverTimeNow + 4.5
						tail() -- inferred equivalent call
					end
				elseif v9 ~= false then
					v9 = false
					region.Visible = false
					fill.Visible = false
					layer.Enabled = false
				end
			end

			if lastTime > 0 then
				local v12 = os.clock() - lastTime

				if v12 > 1.8 then
					lastTime = -1

					if v9 ~= false then
						v9 = false
						region.Visible = false
						fill.Visible = false
						layer.Enabled = false
					end
				elseif v12 > 1.3 then
					setAlpha(1 - (v12 - 1.3) / 0.5)
				end
			end

			if v2 > 0 and v2 <= serverTimeNow then
				v2 = -1
				Music.fadeOut(1.8)
			end

			if not v11 and not flag and lastTime <= 0 and v2 <= 0 and renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end
		end
		fn = function()
			if not renderSteppedConnection then
				renderSteppedConnection = RunService.RenderStepped:Connect(step)
			end
		end
		domination:GetAttributeChangedSignal("Phase"):Connect(fn)
		fn()
	end
}