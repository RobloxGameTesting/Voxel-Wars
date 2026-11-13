local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Style = require(script.Parent.Style)

local v = { [7872316101] = true, [11547363793] = true }

local function field(parent, name: string, p: string, p2: number, placeholderText: string)
	local label = Style.label(parent, name .. "Caption", p, 16)
	label.AutomaticSize = Enum.AutomaticSize.None
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Size = UDim2.fromOffset(376, 20)
	label.Position = UDim2.fromOffset(22, p2)
	local textBox = Instance.new("TextBox")
	textBox.Name = name
	textBox.ClearTextOnFocus = false
	textBox.Text = ""
	textBox.PlaceholderText = placeholderText
	textBox.PlaceholderColor3 = Style.DIM
	textBox.FontFace = Style.FONT
	textBox.TextSize = 24
	textBox.TextColor3 = Style.WHITE
	textBox.TextXAlignment = Enum.TextXAlignment.Left
	textBox.BackgroundColor3 = Style.INK
	textBox.BorderSizePixel = 0
	textBox.Size = UDim2.fromOffset(376, 46)
	textBox.Position = UDim2.fromOffset(22, p2 + 22)
	textBox.Parent = parent
	Style.corner(textBox, 4)
	Style.stroke(textBox, 2, 0, Style.STEEL_LIGHT, true)
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, 12)
	uiPadding.PaddingRight = UDim.new(0, 12)
	uiPadding.Parent = textBox
	textBox:GetPropertyChangedSignal("Text"):Connect(function()
		local text = string.sub(string.gsub(textBox.Text, "%D", ""), 1, 16)

		if text ~= textBox.Text then
			textBox.Text = text
		end
	end)
	return textBox
end

local function open(p)
	local ownerGift = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Remotes"):WaitForChild("OwnerGift")
	local layer = Style.layer(p.playerGui, "OwnerGiftPanel", 22, true)
	local fill = Style.fill(layer, "Shade", Style.INK, UDim2.fromScale(1, 1))
	fill.BackgroundTransparency = 0.45
	fill.Active = true
	local region = Style.region(layer, "Card", Vector2.new(0.5, 0.5), Vector2.zero, Vector2.new(420, 452))
	local panel = Style.panel(region, "Panel", UDim2.fromScale(1, 1), 4)
	panel.BackgroundTransparency = 0
	Style.tape(panel, "Tape", UDim2.fromOffset(420, 8), 420, 10)

	local label = Style.label(panel, "Title", "SEND A GIFT", 26)
	label.AutomaticSize = Enum.AutomaticSize.None
	label.Size = UDim2.new(1, 0, 0, 32)
	label.Position = UDim2.fromOffset(0, 18)

	local parent = field(panel, "UserId", "USER ID", 60, "numbers only")
	local label2 = Style.label(panel, "Who", "", 16, Style.FONT_BODY, 0)
	label2.AutomaticSize = Enum.AutomaticSize.None
	label2.TextXAlignment = Enum.TextXAlignment.Left
	label2.TextColor3 = Style.MUTED
	label2.Size = UDim2.fromOffset(376, 20)
	label2.Position = UDim2.fromOffset(22, 132)
	local parent2 = field(panel, "Scrap", "SCRAP (leave empty for none)", 160, "0")
	local parent3 = field(panel, "Xp", "XP (leave empty for none)", 236, "0")

	local label3 = Style.label(panel, "Note", "", 16, Style.FONT_BODY, 0)
	label3.AutomaticSize = Enum.AutomaticSize.None
	label3.TextWrapped = true
	label3.TextYAlignment = Enum.TextYAlignment.Top
	label3.TextXAlignment = Enum.TextXAlignment.Left
	label3.TextColor3 = Style.MUTED
	label3.Size = UDim2.fromOffset(376, 62)
	label3.Position = UDim2.fromOffset(22, 312)

	local button = Style.button(panel, "Send", "SEND", Style.HAZARD, UDim2.fromOffset(182, 50), Style.INK, 22)
	button.Position = UDim2.fromOffset(22, 384)
	local button2 = Style.button(panel, "Close", "CLOSE", Style.STEEL, UDim2.fromOffset(182, 50), Style.WHITE, 22)
	button2.Position = UDim2.fromOffset(216, 384)

	local v2 = nil
	local v3 = ""
	local flag = false
	local function say(text: string, textColor: Color3) -- 6 equivalent calls inferred from this helper
		label3.Text = text
		label3.TextColor3 = textColor
	end
	local function amounts() -- 2 equivalent calls inferred from this helper
		return tonumber(parent2.Text) or 0, tonumber(parent3.Text) or 0
	end

	local function preview()
		local v4, v5 = amounts() -- inferred equivalent call

		if not v2 or v3 ~= parent.Text then
			return
		end

		if v4 + v5 == 0 then
			say("Enter some Scrap, some XP, or both.", Style.MUTED) -- inferred equivalent call
		else
			local v6 = {}

			if v4 > 0 then
				table.insert(v6, Style.thousands(v4) .. " Scrap")
			end

			if v5 > 0 then
				table.insert(v6, Style.thousands(v5) .. " XP")
			end

			say("SEND gives " .. table.concat(v6, " and ") .. " to " .. v2 .. ".", Style.WHITE) -- inferred equivalent call
		end
	end
	local function lookup()
		local text = parent.Text
		v2 = nil
		v3 = text

		if text == "" then
			label2.Text = ""
			return
		end

		label2.Text = "Looking up..."
		label2.TextColor3 = Style.MUTED
		local v4, text2 = ownerGift:InvokeServer("name", (tonumber(text)))

		if parent.Text ~= text then
			return
		end

		if v4 then
			v2 = text2
			label2.Text = "Account: " .. text2
			label2.TextColor3 = Style.GOOD
			preview()
		else
			label2.Text = text2
			label2.TextColor3 = Style.ORANGE
		end
	end
	parent.FocusLost:Connect(function()
		task.spawn(lookup)
	end)
	parent2:GetPropertyChangedSignal("Text"):Connect(preview)
	parent3:GetPropertyChangedSignal("Text"):Connect(preview)

	button.Activated:Connect(function()
		if flag then
			return
		end

		flag = true

		if v3 ~= parent.Text or not v2 then
			lookup()
		end

		if v2 then
			local v4, v5 = amounts() -- inferred equivalent call
			say("Sending...", Style.MUTED) -- inferred equivalent call
			local v6, v7 = ownerGift:InvokeServer("send", tonumber(parent.Text), v4, v5)
			local v8

			if v6 then
				v8 = "SENT. " .. v7
			else
				v8 = v7
			end

			local v9 = if v6 then Style.GOOD else Style.ORANGE
			say(v8, v9) -- inferred equivalent call

			if v6 then
				parent2.Text = ""
				parent3.Text = ""
				say("SENT. " .. v7, Style.GOOD) -- inferred equivalent call
			end
		else
			say("Enter a real user ID first.", Style.ORANGE) -- inferred equivalent call
		end

		flag = false
	end)

	p.setMenu(true)
	local function close()
		layer:Destroy()
		p.setMenu(false)
	end
	button2.Activated:Connect(close)
	return close
end

return {
	mount = function(p)
		local player = p.player

		if v[player.UserId] or RunService:IsStudio() then
			local _ = nil

			player:GetAttributeChangedSignal("OwnerGiftPanel"):Connect(function()
				if p.playerGui:FindFirstChild("OwnerGiftPanel") then
					return
				end

				_ = open(p)
			end)
		end
	end
}