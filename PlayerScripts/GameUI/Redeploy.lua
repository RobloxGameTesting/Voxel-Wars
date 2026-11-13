local Style = require(script.Parent:WaitForChild("Style"))
local TacticalMap = require(script.Parent:WaitForChild("TacticalMap"))
local KillFeed = require(script.Parent:WaitForChild("KillFeed"))

local Redeploy = {}

function Redeploy.card(p, p2: string)
	local region = Style.region(p, p2, Vector2.new(1, 0.5), Vector2.new(-24, 0), Vector2.new(270, 240))
	Style.fit(region, Vector2.new(864, 240), 0.9)
	local box = Style.box(region, "Card", Style.PANEL, UDim2.fromScale(1, 1), 3, 2)
	box.BackgroundTransparency = 0.08
	local tape = Style.tape(box, "Tape", UDim2.new(1, 0, 0, 10), 270, 16)
	tape.Position = UDim2.fromOffset(0, 0)
	local frame = Style.frame(box, "Body", UDim2.new(1, -28, 1, -30), UDim2.fromOffset(14, 20))
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0, 6)
	uiListLayout.Parent = frame
	return region, frame
end

function Redeploy.new(p, p2, vector3: Vector3, vector3_2: Vector3)
	local frame = Style.frame(p, "Redeploy", UDim2.fromScale(1, 1))
	frame.Visible = false
	local map = TacticalMap.new(frame, p2, vector3, vector3_2)

	local _, v = Redeploy.card(frame, "Card")
	local label = Style.label(v, "Heading", "TAKEN DOWN BY", 13, Style.FONT, 0)
	label.TextColor3 = Style.MUTED
	label.LayoutOrder = 1
	local label2 = Style.label(v, "Killer", "", 24, Style.FONT, 1.5)
	label2.RichText = true
	label2.LayoutOrder = 2
	label2.TextTruncate = Enum.TextTruncate.AtEnd
	label2.AutomaticSize = Enum.AutomaticSize.None
	label2.Size = UDim2.new(1, 0, 0, 28)
	label2.TextXAlignment = Enum.TextXAlignment.Left
	local label3 = Style.label(v, "Damage", "", 15, Style.FONT_BODY, 0)
	label3.TextColor3 = Style.MUTED
	label3.RichText = true
	label3.LayoutOrder = 3
	local fill = Style.fill(v, "Rule", Style.STEEL, UDim2.new(1, 0, 0, 2))
	fill.LayoutOrder = 4
	local label4 = Style.label(v, "Caption", "REDEPLOY IN", 13, Style.FONT, 0)
	label4.TextColor3 = Style.MUTED
	label4.LayoutOrder = 5
	local label5 = Style.label(v, "Time", "", 44, Style.FONT, 2)
	label5.TextColor3 = Style.HAZARD
	label5.LayoutOrder = 6
	local label6 = Style.label(
		v,
		"Hint",
		Style.isTouch() and "TAP A BEACON TO DEPLOY THERE" or "CLICK A BEACON TO DEPLOY THERE",
		12,
		Style.FONT_BODY,
		0
	)
	label6.TextColor3 = Style.DIM
	label6.LayoutOrder = 7

	return {
		["root"] = frame,
		map = map,
		setKiller = function(p3: string?, p4: string?, p5: string?, p6: number?)
			if p3 and p3 ~= "" then
				label.Text = "TAKEN DOWN BY"
				local weapon = KillFeed.weapon(p5)
				label2.Text = Style.paint(KillFeed.shown(p3), Style.teamText(p4)) .. (not weapon and "" or Style.paint("  ·  " .. weapon, Style.MUTED))
				label3.Text = not (p6 and p6 > 0) and ""
					or "took " .. Style.paint(tostring((math.floor(p6 + 0.5))), Style.WHITE) .. " damage from them"
			else
				label.Text = "OUT OF ACTION"
				label2.Text = Style.paint(p5 == "fall" and "FELL" or "DOWN", Style.WHITE)
				label3.Text = ""
			end
		end,
		setTime = function(p3: number?, p4: number)
			if p3 == nil then
				label5.Text = "--"
				map.setProgress(nil)
			else
				label5.Text = not (p3 > 0) and "NOW" or string.format("%d", (math.ceil(p3)))
				map.setProgress(not (p4 > 0) and 1 or 1 - math.clamp(p3 / p4, 0, 1))
			end
		end,
		show = function(p3: string, p4, p5: number?)
			frame.Visible = true
			map.show(p3, p4, p5)
		end,
		hide = function()
			frame.Visible = false
			map.hide()
		end
	}
end

function Redeploy.mount(data)
	local net = data.Net
	local bounds, v = net.bounds()
	local v2 = Redeploy.new(data.layers.screens, net.BEACONS, bounds, v)
	local remote = net.remote("Redeploy")
	local remote2 = net.remote("Died")

	local v3 = nil
	local v4 = nil
	local v5 = net.Config.REDEPLOY_TIME
	local flag = false

	v2.map.onChoose(function(p)
		v2.map.choose(p)
		remote:FireServer(p)
	end)

	local function tick()
		while flag do
			local v6

			if v4 then
				v6 = v4 - net.now()
			end

			v2.setTime(v6, v5)
			task.wait(0.1)
		end
	end

	local function open()
		local team = net.teamOf(data.player)

		if flag or not team then
			return
		end

		flag = true
		local beaconsAlive = net.beaconsAlive()
		v2.show(team, beaconsAlive, nil)
		local nearest = v2.map.nearest(v3 or Vector3.new(0, 0, 0))

		if nearest then
			v2.map.choose(nearest)
			remote:FireServer(nearest)
		end

		v2.map.camera(nil)
		task.spawn(tick)
	end

	local function close() -- 3 equivalent calls inferred from this helper
		if not flag then
			return
		end

		flag = false
		v2.hide()
		v2.map.release()
		v4 = nil
		v2.setKiller(nil, nil, nil, nil)
	end

	data.onCharacter(function(instance, p)
		p.Died:Connect(function()
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
			local v6

			if humanoidRootPart then
				v6 = humanoidRootPart.Position
			end

			v3 = v6
		end)
	end)

	remote2.OnClientEvent:Connect(function(p: string?, p2: string?, p3: string?, p4: number?, p5: number?)
		v2.setKiller(p, p2, p3, p4)
		v4 = p5

		if p5 then
			v5 = math.max(p5 - net.now(), 0.1)
		end
	end)

	net.changed("BeaconsAlive", function()
		if flag then
			local beaconsAlive = net.beaconsAlive()
			v2.map.setAlive(beaconsAlive)
			local chosen = v2.map.chosen()
			local v6 = chosen and not beaconsAlive[chosen] and v2.map.nearest(net.BEACONS[chosen].spawn.Position)

			if v6 then
				v2.map.choose(v6)
				remote:FireServer(v6)
			end
		end
	end)

	data.onDead(function(flag2: boolean)
		if flag2 then
			task.delay(0.6, function()
				if data.isDead() then
					open()
				end
			end)
			return
		end

		close() -- inferred equivalent call
	end)
	data.onTeam(function(p)
		if not p then
			close() -- inferred equivalent call
		end
	end)
	net.changed("Phase", function()
		if net.get("Phase") == "Ended" then
			close() -- inferred equivalent call
		end
	end)
end

return Redeploy