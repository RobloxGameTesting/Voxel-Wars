local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Style = require(script.Parent.Style)
local ClaimAudio = require(script.Parent.ClaimAudio)

local function show(p, scrap: number, xp: number, fn)
	local v = {}

	if scrap > 0 then
		table.insert(v, {
			text = "+" .. Style.thousands(scrap) .. " SCRAP",
			color = Style.HAZARD
		})
	end

	if xp > 0 then
		table.insert(v, {
			text = "+" .. Style.thousands(xp) .. " XP",
			color = Style.GOOD
		})
	end

	local v2 = #v * 50 + 92 + 12 + 48 + 16

	local layer = Style.layer(p.playerGui, "OwnerGift", 21, true)
	local fill = Style.fill(layer, "Shade", Style.INK, UDim2.fromScale(1, 1))
	fill.BackgroundTransparency = 0.45
	fill.Active = true

	local region = Style.region(layer, "Card", Vector2.new(0.5, 0.5), Vector2.zero, Vector2.new(360, v2))
	local panel = Style.panel(region, "Panel", UDim2.fromScale(1, 1), 4)
	panel.BackgroundTransparency = 0
	Style.tape(panel, "Tape", UDim2.fromOffset(360, 8), 360, 10)

	local label = Style.label(panel, "Title", "GIFT FOR YOU", 28)
	label.AutomaticSize = Enum.AutomaticSize.None
	label.Size = UDim2.new(1, 0, 0, 34)
	label.Position = UDim2.fromOffset(0, 20)

	local label2 = Style.label(panel, "From", "FROM THE DEVELOPERS", 15, Style.FONT_BODY, 0)
	label2.AutomaticSize = Enum.AutomaticSize.None
	label2.TextColor3 = Style.MUTED
	label2.Size = UDim2.new(1, 0, 0, 20)
	label2.Position = UDim2.fromOffset(0, 58)

	for k, v3 in v do
		local label3 = Style.label(panel, "Row" .. k, v3.text, 36)
		label3.AutomaticSize = Enum.AutomaticSize.None
		label3.TextColor3 = v3.color
		label3.Size = UDim2.new(1, 0, 0, 44)
		label3.Position = UDim2.fromOffset(0, (k - 1) * 50 + 92)
	end

	local button = Style.button(panel, "Ok", "OK", Style.HAZARD, UDim2.fromOffset(150, 48), Style.INK, 22)
	button.AnchorPoint = Vector2.new(0.5, 1)
	button.Position = UDim2.new(0.5, 0, 1, -16)

	local uiScale = Instance.new("UIScale")
	uiScale.Scale = 0.8
	uiScale.Parent = panel
	TweenService:Create(uiScale, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1
	}):Play()
	task.spawn(ClaimAudio.prizeHit)

	p.setMenu(true)
	local inputBeganConnection = nil
	local flag = false
	local function close() -- 1 equivalent call inferred from this helper
		if flag then
			return
		end

		flag = true
		inputBeganConnection:Disconnect()
		layer:Destroy()
		p.setMenu(false)
		fn()
	end
	button.Activated:Connect(close)
	inputBeganConnection = UserInputService.InputBegan:Connect(function(input)
		if
			input.KeyCode == Enum.KeyCode.ButtonA
			or input.KeyCode == Enum.KeyCode.ButtonB
			or input.KeyCode == Enum.KeyCode.Return
		then
			close() -- inferred equivalent call
		end
	end)
end

return {
	mount = function(p)
		local player = p.player
		local v = {}
		local v2 = false
		local v3 = nil
		local function nextOne()
			if v2 or #v == 0 then
				return
			end

			v2 = true
			local v4 = table.remove(v, 1)
			show(p, v4.scrap, v4.xp, function()
				v2 = false
				nextOne()
			end)
		end
		local function read()
			local ownerGift = player:GetAttribute("OwnerGift")

			if type(ownerGift) ~= "string" or ownerGift == v3 then
				return
			end

			v3 = ownerGift
			local v4 = string.split(ownerGift, "|")
			local scrap = tonumber(v4[2])
			local xp = tonumber(v4[3])
			assert(scrap and xp, "[OwnerGift] bad attribute " .. ownerGift)
			table.insert(v, { scrap = scrap, xp = xp })
			nextOne()
		end
		player:GetAttributeChangedSignal("OwnerGift"):Connect(read)
		read()
	end
}