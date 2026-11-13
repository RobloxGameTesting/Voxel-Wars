local Style = require(script.Parent:WaitForChild("Style"))
local XpBar = require(script.Parent:WaitForChild("XpBar"))
local ToolIcon = require(script.Parent:WaitForChild("ToolIcon"))
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToolTemplates = ReplicatedStorage:WaitForChild("ToolTemplates")
local Players = game:GetService("Players")

local KillFeed = {}

local v = Style.isTouch() and 3 or 5

local v2 = {
	Heli = {
		image = "rbxassetid://125257738634901",
		aspect = 116 / 33
	},
	Jet = {
		image = "rbxassetid://109696642356654",
		aspect = 1044 / 255
	}
}

local v3 = {
	AssaultRifle = "VR-30",
	K433 = "K-433",
	GX36 = "GX-36",
	SK556 = "SK-556",
	RN545 = "RN-545",
	MX65 = "MX-65",
	BT762 = "BT-762",
	Pistol = "SP-17",
	HandCannon = "HC-7",
	LMG = "HB-100",
	BX110 = "BX-110",
	HX83 = "HX-83",
	MG60 = "MG-60",
	KT8 = "KT-8",
	NX68 = "NX-68",
	GR240 = "GR-240",
	SMG = "PX-9",
	KP50 = "KP-50",
	HM45 = "HM-45",
	PD46 = "PD-46",
	SP44 = "SP-44",
	TK17 = "TK-17",
	DMR = "MR-14",
	GV12 = "GV-12",
	FS16 = "FS-16",
	KR54 = "KR-54",
	QS9 = "QS-9",
	Shotgun = "PA-12",
	Sniper = "LR-7",
	RX10 = "RX-10",
	SC11 = "SC-11",
	VX50 = "VX-50",
	SV20 = "SV-20",
	ZK10 = "ZK-10",
	RocketLauncher = "ROCKET",
	Hammer = "HAMMER",
	PipeBomb = "DEMO CHARGE",
	Molotov = "MOLOTOV",
	Flamethrower = "FLAMETHROWER",
	AALauncher = "ANTI-AIR MISSILE",
	Grenade = "GRENADE",
	Claymore = "CLAYMORE",
	C4 = "C4",
	GunshipHeavy = "GUNSHIP",
	GunshipCannon = "GUNSHIP",
	GunshipGun = "GUNSHIP"
}

function KillFeed.weapon(value: string?)
	if value and value ~= "" then
		return v3[value] or string.upper((value:gsub("(%l)(%u)", "%1 %2")))
	end

	return nil
end

function KillFeed.shown(childName: string)
	local player = Players:FindFirstChild(childName)

	if player and player:IsA("Player") then
		return player.DisplayName
	end

	return childName
end

local function name(p: string?, p2: string?) -- 11 equivalent calls inferred from this helper
	return {
		kind = "text",
		text = not p and "?" or KillFeed.shown(p),
		color = Style.teamText(p2)
	}
end

local function word(text: string, color: Color3?) -- 11 equivalent calls inferred from this helper
	return {
		kind = "text",
		text = text,
		color = color or Style.WHITE
	}
end

local function tag(text: string) -- 6 equivalent calls inferred from this helper
	return { kind = "tag", text = text }
end

local function weaponPart(childName: string?)
	if childName and v2[childName] then
		return { kind = "icon", text = childName }
	end

	local tool

	if childName and childName ~= "" then
		tool = ToolTemplates:FindFirstChild(childName)
	end

	if tool and tool:IsA("Tool") and ToolIcon.hasImage(tool.Name) then
		return { kind = "icon", text = tool.Name }
	end

	return tag(KillFeed.weapon(childName) or "DOWN") -- inferred equivalent call
end

function KillFeed.parts(p: string?, callback, p2: string, ...)
	local v4 = { ... }

	if p2 == "takedown" then
		local v5 = v4[1]
		local v6 = v4[2]
		local v7 = v4[3]
		local v8 = v4[4]
		local text = v4[5]
		local v9 = v4[6]
		local v10 = weaponPart(text)

		if not v5 or v5 == "" then
			return { v10, name(v7, v8) }, v7 == p -- inferred equivalent call
		end

		if v9 == true then
			return {
				name(v5, v6), -- inferred equivalent call
				v10,
				{ kind = "skull", text = "" },
				name(v7, v8) -- inferred equivalent call
			}, v5 == p or v7 == p
		end

		return { name(v5, v6), v10, name(v7, v8) }, v5 == p or v7 == p -- inferred equivalent call
	elseif p2 == "roll" then
		local v5 = v4[1]
		local v6 = v4[2]
		return { name(v5, v4[3] or callback(v5)), word("ON A ROLL", Style.HAZARD), tag("×" .. tostring(v6)) }, v5 == p -- inferred equivalent call
	elseif p2 == "crew" then
		local v5 = v4[1]
		local v6 = v4[2]
		return { name(v5, callback(v5)), word("WRECKING CREW", Style.ORANGE), tag("×" .. tostring(v6)) }, v5 == p -- inferred equivalent call
	elseif p2 == "shutdown" then
		local v5 = v4[1]
		local v6 = v4[2]
		local v7 = v4[3]
		local v8 = name(v5, v4[4] or callback(v5)) -- inferred equivalent call
		local v9 = v4[5] or callback(v6)
		return {
			v8,
			tag("SHUT DOWN"), -- inferred equivalent call
			name(v6, v9), -- inferred equivalent call
			word("×" .. tostring(v7), Style.MUTED) -- inferred equivalent call
		}, v5 == p or v6 == p
	elseif p2 == "beacon" then
		local v5 = v4[1]
		local v6 = v4[2]
		local v7 = v4[3]
		local v8 = { word(string.upper(v7 or "?"), Style.teamText(v7)), word("BEACON DOWN", Style.MUTED) } -- inferred equivalent call

		if v5 and v5 ~= "" then
			return { name(v5, v6), tag("BREACH"), v8[1], v8[2] }, v5 == p -- inferred equivalent call
		end

		return v8, false
	elseif p2 == "spawn" then
		local v5 = v4[1]
		local v6 = v4[2]
		local v7 = v4[3]
		local v8 = { word(string.upper(v7 or "?") .. " SPAWN", Style.teamText(v7)), word("DESTROYED", Style.MUTED) } -- inferred equivalent call

		if v5 and v5 ~= "" then
			return { name(v5, v6), word("TOOK OUT", Style.MUTED), v8[1] }, v5 == p -- inferred equivalent call
		end

		return v8, false
	else
		if p2 ~= "round" then
			error("GameUI: unknown Feed kind '" .. tostring(p2) .. "'")
			return
		end

		local v5 = v4[1]

		if v5 and v5 ~= "" then
			return { word(string.upper(v5), Style.teamText(v5)), word("TAKE THE ROUND", Style.WHITE) }, false -- inferred equivalent call
		end

		return { tag("ROUND"), word("DRAWN", Style.WHITE) }, false -- inferred equivalent call
	end
end

function KillFeed.new(guiBase2d)
	local region = Style.region(
		guiBase2d,
		"KillFeed",
		Vector2.new(1, 0),
		Vector2.new(-14, Style.topInset() + 6 + 46 + 8),
		Vector2.new(340, v * 28)
	)

	local function place()
		local scaled = Style.scale()
		local v4

		if guiBase2d:IsA("GuiBase2d") and guiBase2d.AbsoluteSize.X > 0 then
			v4 = guiBase2d.AbsoluteSize.X
		else
			v4 = workspace.CurrentCamera.ViewportSize.X
		end

		region.Position = UDim2.new(1, -14, 0, Style.topInset() + 6 + XpBar.height(scaled, v4) * scaled + 8)
	end
	Style.onScale(function()
		place()
	end)

	if guiBase2d:IsA("GuiBase2d") then
		guiBase2d:GetPropertyChangedSignal("AbsoluteSize"):Connect(place)
	end

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	uiListLayout.Padding = UDim.new(0, 4)
	uiListLayout.Parent = region

	local v4 = {}

	for i = 1, v do
		local frame = Style.frame(region, "Line" .. i, UDim2.new(1, 0, 0, 24))
		frame.Visible = false
		local panel = Style.panel(frame, "Plate", UDim2.fromOffset(0, 24))
		panel.AutomaticSize = Enum.AutomaticSize.X
		panel.AnchorPoint = Vector2.new(1, 0)
		panel.Position = UDim2.fromScale(1, 0)
		local uiStroke = panel:FindFirstChildOfClass("UIStroke")
		local uiListLayout2 = Instance.new("UIListLayout")
		uiListLayout2.FillDirection = Enum.FillDirection.Horizontal
		uiListLayout2.VerticalAlignment = Enum.VerticalAlignment.Center
		uiListLayout2.Padding = UDim.new(0, 6)
		uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
		uiListLayout2.Parent = panel
		local uiPadding = Instance.new("UIPadding")
		uiPadding.PaddingLeft = UDim.new(0, 10)
		uiPadding.PaddingRight = UDim.new(0, 8)
		uiPadding.Parent = panel
		local fill = Style.fill(panel, "Edge", Style.HAZARD, UDim2.new(0, 3, 1, 0))
		fill.Position = UDim2.new(1, 5, 0, 0)
		fill.LayoutOrder = 99
		local slots = {}
		local uiStrokes = {}
		local labels = {}
		local icons = {}

		for j = 1, 4 do
			local label = Style.label(panel, "Text" .. j, "", 14, Style.FONT, 1.2)
			label.LayoutOrder = j * 2
			label.Size = UDim2.fromOffset(0, 24)
			local box = Style.box(panel, "Tag" .. j, Style.STEEL, UDim2.fromOffset(0, 16), 2, 1)
			box.AutomaticSize = Enum.AutomaticSize.X
			box.LayoutOrder = j * 2 + 1
			local uiPadding2 = Instance.new("UIPadding")
			uiPadding2.PaddingLeft = UDim.new(0, 5)
			uiPadding2.PaddingRight = UDim.new(0, 5)
			uiPadding2.Parent = box
			local label2 = Style.label(box, "Text", "", 11, Style.FONT, 0)
			label2.Size = UDim2.fromOffset(0, 16)
			slots[j * 2 - 1] = label
			slots[j * 2] = box
			uiStrokes[j * 2 - 1] = label:FindFirstChildOfClass("UIStroke")
			labels[j * 2] = label2

			if not (j <= 2) then
				continue
			end

			local frame2 = Instance.new("Frame")
			frame2.Name = "Icon" .. j
			frame2.BackgroundTransparency = 1
			frame2.BorderSizePixel = 0
			frame2.Size = UDim2.fromOffset(58, 20)
			frame2.LayoutOrder = j * 2 + 1
			frame2.Visible = false
			frame2.Parent = panel
			icons[j] = frame2
		end

		local headshot = Instance.new("ImageLabel")
		headshot.Name = "Headshot"
		headshot.BackgroundTransparency = 1
		headshot.Size = UDim2.fromOffset(17, 17)
		headshot.Image = "rbxassetid://98055525641890"
		headshot.ImageColor3 = Style.WHITE
		headshot.ScaleType = Enum.ScaleType.Fit
		headshot.LayoutOrder = 7
		headshot.Visible = false
		headshot.Parent = panel
		v4[i] = {
			holder = frame,
			plate = panel,
			plateStroke = uiStroke,
			edge = fill,
			slots = slots,
			icons = icons,
			arts = {},
			skull = headshot,
			iconOf = {},
			t0 = 0,
			live = false,
			serial = 0,
			strokes = uiStrokes,
			tagTexts = labels
		}
	end

	local count = 0

	local function step(_, t0)
		local v5 = false

		for _, v6 in v4 do
			if not v6.live then
				continue
			end

			local v7 = t0 - v6.t0

			local slide = 24 * (1 - Style.easeOut(v7 / 0.14))

			if slide ~= v6.slide then
				v6.slide = slide
				v6.plate.Position = UDim2.new(1, slide, 0, 0)
			end

			local v8 = math.clamp((v7 - 6) / 0.5, 0, 1)

			if v8 ~= v6.fade then
				v6.fade = v8
				v6.plate.BackgroundTransparency = Style.PANEL_ALPHA + (1 - Style.PANEL_ALPHA) * v8
				v6.plateStroke.Transparency = v8 * 0.65 + 0.35
				v6.edge.BackgroundTransparency = v8

				for _, art in v6.arts do
					art.ImageTransparency = v8
				end

				v6.skull.ImageTransparency = v8

				for k, slot in v6.slots do
					local tagText = v6.tagTexts[k]

					if tagText then
						slot.BackgroundTransparency = v8
						tagText.TextTransparency = v8
					else
						slot.TextTransparency = v8
						local stroke = v6.strokes[k]

						if stroke then
							stroke.Transparency = v8 * 0.75 + 0.25
						end
					end
				end
			end

			if v8 >= 1 then
				v6.live = false

				v6.holder.Visible = false
			else
				v5 = true
			end
		end

		return v5
	end

	local v5 = {}
	v5.root = region

	function v5.push(items, visible: boolean)
		local v6 = v4[1]

		for _, v7 in v4 do
			if v7.live then
				if v7.serial < v6.serial then
					v6 = v7
				end
			else
				v6 = v7
				break
			end
		end

		count += 1
		local serial = count
		local now = os.clock()
		v6.serial = serial
		v6.t0 = now
		v6.live = true
		v6.holder.LayoutOrder = -count
		v6.holder.Visible = true
		v6.edge.Visible = visible

		for _, slot in v6.slots do
			slot.Visible = false
		end

		for _, icon in v6.icons do
			icon.Visible = false
		end

		v6.skull.Visible = false

		for k, item in items do
			assert(k <= 4, "GameUI: feed line has too many parts")

			if item.kind == "skull" then
				assert(k == 3, "GameUI: feed headshot skull must be part " .. 3)
				v6.skull.Visible = true
			elseif item.kind == "icon" then
				local icon = v6.icons[k]
				assert(icon, "GameUI: feed line has a weapon past part " .. 2)

				if v6.iconOf[k] ~= item.text then
					local art = v6.arts[k]

					if art then
						art:Destroy()
					end

					local v7 = v2[item.text]

					if v7 then
						local icon2 = Instance.new("ImageLabel")
						icon2.Name = "Icon"
						icon2.BackgroundTransparency = 1
						icon2.AnchorPoint = Vector2.new(0.5, 0.5)
						icon2.Position = UDim2.fromScale(0.5, 0.5)
						icon2.Size = UDim2.fromOffset(58, (math.round(58 / v7.aspect)))
						icon2.Image = v7.image
						icon2.Parent = icon
						v6.arts[k] = icon2
					else
						local tool = ToolTemplates:FindFirstChild(item.text)
						assert(tool and tool:IsA("Tool"), "GameUI: kill feed icon for missing tool " .. item.text)
						v6.arts[k] = ToolIcon.flatImage(tool, icon, Style.WHITE)
					end

					v6.iconOf[k] = item.text
				end

				icon.Visible = true
			elseif item.kind == "tag" then
				local slot = v6.slots[k * 2]
				local text = slot:FindFirstChild("Text")
				text.Text = item.text
				slot.Visible = true
			else
				local slot = v6.slots[k * 2 - 1]
				slot.Text = item.text
				slot.TextColor3 = item.color or Style.WHITE
				slot.Visible = true
			end
		end

		v6.slide = nil
		v6.fade = nil
		step(0, v6.t0)
		Style.animate(v5, step)
	end
	return v5
end

function KillFeed.mount(data)
	local net = data.Net
	local v4 = KillFeed.new(data.layers.hud)
	local name2 = data.player.Name
	net.remote("Feed").OnClientEvent:Connect(function(p: string, ...)
		local parts, v5 = KillFeed.parts(name2, net.teamOfName, p, ...)
		v4.push(parts, v5)
	end)
end

return KillFeed