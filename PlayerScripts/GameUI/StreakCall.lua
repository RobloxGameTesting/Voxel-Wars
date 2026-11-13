local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalizationService = game:GetService("LocalizationService")

local Style = require(script.Parent.Style)

local function str(value) -- 3 equivalent calls inferred from this helper
	if type(value) == "string" and value ~= "" then
		return value
	end

	return nil
end

local function teamName(p) -- 3 equivalent calls inferred from this helper
	return if p == "Reds" or p == "Blues" then p else nil
end

local function esc(value: string) -- 1 equivalent call inferred from this helper
	return (string.gsub(string.gsub(string.gsub(value, "&", "&amp;"), "<", "&lt;"), ">", "&gt;"))
end

local function hex(hazard: Color3) -- 3 equivalent calls inferred from this helper
	return string.format(
		"#%02X%02X%02X",
		math.floor(hazard.R * 255 + 0.5),
		math.floor(hazard.G * 255 + 0.5),
		(math.floor(hazard.B * 255 + 0.5))
	)
end

return {
	mount = function(p)
		local name = p.player.Name
		local hud = p.layers.hud
		local feed = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Remotes"):WaitForChild("Feed")

		local region = Style.region(
			hud,
			"StreakCall",
			Vector2.new(0.5, 0),
			Vector2.new(0, Style.topInset() + 6),
			Vector2.new(560, 104)
		)
		local label = Style.label(region, "Call", "", 15, Style.FONT, 1.5)
		label.RichText = true
		label.AutoLocalize = false
		label.AnchorPoint = Vector2.new(0.5, 0)
		label.Position = UDim2.fromOffset(280, 58)
		label.TextTransparency = 1
		label.Visible = false
		local uiStroke = label:FindFirstChildOfClass("UIStroke")

		local function name2(p2: string?, p3: string?)
			local v

			if p3 then
				v = Style.teamText(p3)
			else
				v = Style.WHITE
			end

			return string.format("<font color=\"%s\">%s</font>", hex(v), esc(not p2 and "?" or Style.shown(p2))) -- inferred equivalent call
		end

		local function compose(p2)
			local args = p2.args

			if p2.kind == "spawnattack" then
				return string.format("<font color=\"%s\">YOUR SPAWNS ARE UNDER ATTACK</font>", hex(Style.HAZARD)), true
			end

			if p2.kind == "roll" then
				local v = str(args[1]) -- inferred equivalent call
				local v2 = tonumber(args[2]) or 0
				local v3 = v == name
				local v4 = string.format("IS ON A %d PLAYER KILL STREAK", v2)
				local v5 = name2(v, teamName(args[3])) -- inferred equivalent call
				local v6 = if v3 then Style.HAZARD else Style.WHITE
				return v5 .. string.format("  <font color=\"%s\">%s</font>", hex(v6), v4), v3 -- inferred equivalent call
			else
				local v = str(args[1]) -- inferred equivalent call
				local v2 = str(args[2]) -- inferred equivalent call
				local v3 = tonumber(args[3]) or 0
				local v4 = v == name or v2 == name
				local v5 = if v4 then Style.HAZARD else Style.WHITE
				local v6 = hex(v5) -- inferred equivalent call
				return
					name2(v, teamName(args[4])) .. string.format("  <font color=\"%s\">ENDED</font>  ", v6) .. name2(v2, teamName(args[5])) .. string.format( -- inferred equivalent call
						"<font color=\"%s\">'S  %d PLAYER KILL STREAK</font>",
						v6,
						v3
					),
					v4
			end
		end

		local v = nil
		local function messageUp()
			if v and v.Parent then
				return v ~= nil and v.Visible
			end

			local huds = p.layers.huds
			local pointHud = (huds and huds.PointHud or hud):FindFirstChild("PointHud")
			local message = pointHud and pointHud:FindFirstChild("Message", true)

			if not (message and message:IsA("GuiObject")) then
				message = nil
			end

			v = message

			return v ~= nil and v.Visible
		end

		local translatorForPlayerAsync = nil
		task.spawn(function()
			translatorForPlayerAsync = LocalizationService:GetTranslatorForPlayerAsync(p.player)
		end)

		local v2 = {}
		local v3 = false
		local v4 = 0

		local function nextCall()
			local v5 = table.remove(v2, 1)

			if v5 then
				local text = compose(v5)

				if translatorForPlayerAsync then
					text = translatorForPlayerAsync:Translate(label, text)
				end

				label.Text = text
				v3 = true
				v4 = os.clock()
				label.Visible = true
			else
				v3 = false
				label.Visible = false
			end
		end

		local v5 = nil
		local v6 = nil
		local function step(_, p2: number)
			if not v3 then
				return false
			end

			local v7 = messageUp() and 80 or 58

			if v7 ~= v5 then
				v5 = v7
				label.Position = UDim2.fromOffset(280, v7)
			end

			local v8 = p2 - v4
			local v9 = #v2 > 0 and 1.5 or 3
			local textTransparency

			if v8 < 0.15 then
				textTransparency = 1 - v8 / 0.15
			else
				textTransparency = math.clamp((v8 - v9) / 0.4, 0, 1)
			end

			if textTransparency ~= v6 then
				v6 = textTransparency
				label.TextTransparency = textTransparency

				if uiStroke then
					uiStroke.Transparency = textTransparency * 0.6 + 0.4
				end
			end

			if v9 < v8 and textTransparency >= 1 then
				nextCall()
				return v3
			end

			return true
		end

		local function push(kind: string, args)
			if #v2 >= 3 then
				table.remove(v2, 1)
			end

			table.insert(v2, { kind = kind, args = args })

			if not v3 then
				nextCall()
				Style.animate(label, step)
			end
		end

		feed.OnClientEvent:Connect(function(kind: string, ...)
			if kind ~= "roll" and kind ~= "shutdown" then
				return
			end

			push(kind, { ... })
		end)

		local player = p.player
		local domination = ReplicatedStorage.Game:WaitForChild("Domination")
		domination.AttributeChanged:Connect(function(attributeName: string)
			local v7 = string.match(attributeName, "^SpawnAlert(%a+)$")

			if not v7 or not player.Team or player.Team.Name ~= v7 then
				return
			end

			local attribute = domination:GetAttribute(attributeName)

			if type(attribute) == "number" and workspace:GetServerTimeNow() - attribute < 3 then
				push("spawnattack", {})
			end
		end)
	end
}