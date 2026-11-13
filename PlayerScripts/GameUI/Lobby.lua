local Players = game:GetService("Players")

local Style = require(script.Parent:WaitForChild("Style"))

local Lobby = {
	["new"] = nil,
	new = function(p)
		local frame = Style.frame(p, "Lobby", UDim2.fromScale(1, 1))

		local region = Style.region(
			frame,
			"Hint",
			Vector2.new(0.5, 0),
			Vector2.new(0, Style.topInset() + 14),
			Vector2.new(460, 64)
		)
		local tape = Style.tape(region, "Tape", UDim2.new(1, 0, 0, 10), 460, 16)
		tape.Position = UDim2.fromOffset(0, 0)
		local box = Style.box(region, "Plate", Style.PANEL, UDim2.new(1, -40, 0, 42), 3, 2)
		box.AnchorPoint = Vector2.new(0.5, 0)
		box.Position = UDim2.new(0.5, 0, 0, 14)
		box.BackgroundTransparency = 0.08
		local label = Style.label(box, "Text", "STEP INTO A CIRCLE TO JOIN A TEAM", 22, Style.FONT, 1.5)
		label.AutomaticSize = Enum.AutomaticSize.None
		label.Size = UDim2.fromScale(1, 1)
		label.TextColor3 = Style.HAZARD

		local region2 = Style.region(frame, "Teams", Vector2.new(0.5, 1), Vector2.new(0, -22), Vector2.new(464, 120))

		local v = {}
		local v2 = {}

		for k, v3 in { "Reds", "Blues" } do
			local teamColor = Style.teamColor(v3)
			local box2 = Style.box(region2, v3, Style.PANEL, UDim2.fromOffset(220, 120), 3, 2)
			box2.BackgroundTransparency = 0.1
			box2.Position = UDim2.fromOffset((k - 1) * 244, 0)
			Style.fill(box2, "Band", teamColor, UDim2.new(1, 0, 0, 5))
			local emblem = Style.emblem(box2, v3, 26)
			emblem.Position = UDim2.fromOffset(12, 13)
			local label2 = Style.label(box2, "Team", string.upper(v3), 22, Style.FONT, 1.5)
			label2.TextColor3 = Style.teamText(v3)
			label2.Position = UDim2.fromOffset(46, 11)
			local label3 = Style.label(box2, "Crew", "", 13, Style.FONT, 0)
			label3.TextColor3 = Style.MUTED
			label3.AnchorPoint = Vector2.new(1, 0)
			label3.Position = UDim2.new(1, -12, 0, 10)
			local label4 = Style.label(box2, "Beacons", "", 13, Style.FONT, 0)
			label4.TextColor3 = Style.MUTED
			label4.AnchorPoint = Vector2.new(1, 0)
			label4.Position = UDim2.new(1, -12, 0, 26)
			local button, joinLabel = Style.button(
				box2,
				"Join",
				"JOIN " .. string.upper(v3),
				teamColor,
				UDim2.new(1, -24, 0, 44),
				Style.WHITE,
				20
			)
			button.Position = UDim2.new(0, 12, 1, -56)
			button.Activated:Connect(function()
				for _, v4 in v do
					v4(v3)
				end
			end)
			v2[v3] = { players = label3, beacons = label4, join = button, joinLabel = joinLabel }
		end

		local box2 = Style.box(region2, "Toast", Style.ORANGE, UDim2.fromOffset(0, 32), 3, 2)
		box2.AutomaticSize = Enum.AutomaticSize.X
		box2.AnchorPoint = Vector2.new(0.5, 1)
		box2.Position = UDim2.new(0.5, 0, 0, -12)
		local uiPadding = Instance.new("UIPadding")
		uiPadding.PaddingLeft = UDim.new(0, 12)
		uiPadding.PaddingRight = UDim.new(0, 12)
		uiPadding.Parent = box2
		local label2 = Style.label(box2, "Text", "", 16, Style.FONT, 0)
		label2.Size = UDim2.fromOffset(0, 32)
		label2.TextColor3 = Style.INK
		box2.Visible = false

		local v3 = {}
		v3.root = frame

		function v3.setStats(p2: string, p3)
			local v4 = v2[p2]
			local players = v4.players
			local players2 = p3.players
			local _ = p3.players == 1
			players.Text = players2 .. " IN CREW"
			v4.beacons.Text = p3.beacons .. " BEACONS"
		end

		function v3.onJoin(p2)
			table.insert(v, p2)
		end

		local v4 = 0
		function v3.toast(text: string)
			label2.Text = text
			box2.Visible = true
			v4 = os.clock()
			local v5 = v4
			task.delay(3.5, function()
				if v4 == v5 then
					box2.Visible = false
				end
			end)
		end

		function v3.setBusy(flag: boolean)
			for _, v5 in v2 do
				v5.join.Active = not flag
				v5.join.AutoButtonColor = not flag
				v5.joinLabel.TextTransparency = flag and 0.5 or 0
			end
		end

		return v3
	end
}

function Lobby.mount(data)
	local net = data.Net
	local _player = data.player
	local v = Lobby.new(data.layers.screens)
	local remote = net.remote("PickTeam")
	local visible = false

	local v2 = false
	local function refresh()
		v2 = false

		for _, v3 in { "Reds", "Blues" } do
			local count = 0

			for _, v4 in Players:GetPlayers() do
				if net.teamOf(v4) == v3 then
					count += 1
				end
			end

			v.setStats(v3, {
				players = count,
				beacons = net.get(v3 .. "Beacons")
			})
		end
	end
	local function queue() -- 2 equivalent calls inferred from this helper
		if not v2 and visible then
			v2 = true
			task.defer(refresh)
		end
	end
	data.eachPlayer(function(instance)
		instance:GetPropertyChangedSignal("Team"):Connect(queue)
		instance:GetPropertyChangedSignal("Neutral"):Connect(queue)
		queue() -- inferred equivalent call
	end)
	Players.PlayerRemoving:Connect(queue)
	net.changed("RedsBeacons", queue)
	net.changed("BluesBeacons", queue)

	v.onJoin(function(p)
		v.setBusy(true)
		remote:FireServer(p)
		task.delay(2, function()
			v.setBusy(false)
		end)
	end)
	net.remote("MatchEvent").OnClientEvent:Connect(function(p: string, _: string?, value: string?)
		if p == "teamRefused" then
			v.setBusy(false)
			v.toast(string.upper(value or "THAT TEAM IS FULL"))
		end
	end)

	data.onTeam(function(p)
		visible = p == nil
		v.root.Visible = visible
		v.setBusy(false)
		queue() -- inferred equivalent call
	end)
end

return Lobby