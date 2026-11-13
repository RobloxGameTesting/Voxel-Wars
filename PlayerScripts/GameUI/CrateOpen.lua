local ContentProvider = game:GetService("ContentProvider")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Style = require(script.Parent.Style)
local ClaimFx = require(script.Parent.ClaimFx)
local ClaimAudio = require(script.Parent.ClaimAudio)
local Game = ReplicatedStorage:WaitForChild("Game")
local Crates = require(Game:WaitForChild("Crates"))
local WeaponSkins = require(Game:WaitForChild("WeaponSkins"))
local ShopData = require(Game:WaitForChild("ShopData"))
local ToolIcon = require(script.Parent:WaitForChild("ToolIcon"))
local KillFeed = require(script.Parent:WaitForChild("KillFeed"))
local ToolTemplates = ReplicatedStorage:WaitForChild("ToolTemplates")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function ids(items)
	local result = {}

	for k, item in items do
		result[k] = "rbxassetid://" .. item
	end

	return result
end

local body = {}

local rifle = { body = 0, glow = 0 }
local v = {
	rifle = 0,
	smg = 0,
	lmg = 0,
	sniper = 0,
	dmr = 0,
	pistol = 0,
	shotgun = 0
}
local CrateOpen = {}

for k, v2 in {
	126831082367325,
	123072417073113,
	125944915581104,
	113369744429869,
	123198636274046,
	91932996478355,
	106443006245409,
	107503184895759,
	137934471545273
} do
	body[k] = "rbxassetid://" .. v2
end

rifle.body = body
local glow = {}

for k, v2 in { 119274895935283, 87780437381001, 80385058082068 } do
	glow[k] = "rbxassetid://" .. v2
end

rifle.glow = glow
v.rifle = rifle
local body2 = {}

local smg = { body = 0, glow = 0 }

for k, v2 in {
	84949784639187,
	74176815867056,
	72273577727512,
	98701203743380,
	77255210329605,
	105850395443686,
	91091716309018,
	100901955774188,
	117087205887964
} do
	body2[k] = "rbxassetid://" .. v2
end

smg.body = body2
local glow2 = {}

for k, v2 in { 121508364068682, 126227353701105, 99966627843254 } do
	glow2[k] = "rbxassetid://" .. v2
end

smg.glow = glow2
v.smg = smg
local body3 = {}

local lmg = { body = 0, glow = 0 }

for k, v2 in {
	121495787234126,
	129080584612059,
	136181256236703,
	134252941925752,
	86834252914294,
	107064221444344,
	117874108996440,
	105915462467744,
	71017406413138
} do
	body3[k] = "rbxassetid://" .. v2
end

lmg.body = body3
local glow3 = {}

for k, v2 in { 111422872668044, 100657609246044, 129308163179238 } do
	glow3[k] = "rbxassetid://" .. v2
end

lmg.glow = glow3
v.lmg = lmg
local body4 = {}

local sniper = { body = 0, glow = 0 }

for k, v2 in {
	135145966168929,
	132831720179000,
	118289775494499,
	75594310514853,
	77031833743303,
	84629026399993,
	80034704761614,
	106964918672113,
	94521094848485
} do
	body4[k] = "rbxassetid://" .. v2
end

sniper.body = body4
local glow4 = {}

for k, v2 in { 84488178031041, 107973607689735, 137285356265452 } do
	glow4[k] = "rbxassetid://" .. v2
end

sniper.glow = glow4
v.sniper = sniper
local body5 = {}

local dmr = { body = 0, glow = 0 }

for k, v2 in {
	127968550415376,
	115752046702405,
	90483858782730,
	105706095718658,
	116708118499261,
	83793377239999,
	91599426018426,
	123880408835811,
	83208917300790
} do
	body5[k] = "rbxassetid://" .. v2
end

dmr.body = body5
local glow5 = {}

for k, v2 in { 124655778569850, 100111251723389, 110173532989423 } do
	glow5[k] = "rbxassetid://" .. v2
end

dmr.glow = glow5
v.dmr = dmr
local body6 = {}

local pistol = { body = 0, glow = 0 }

for k, v2 in {
	134249002896139,
	113948388125489,
	78549109741059,
	113153198460087,
	75177560882025,
	103384876848110,
	96757926723025,
	137818419969110,
	128056453295417
} do
	body6[k] = "rbxassetid://" .. v2
end

pistol.body = body6
local glow6 = {}

for k, v2 in { 78874979501970, 138427124321361, 89117618435810 } do
	glow6[k] = "rbxassetid://" .. v2
end

pistol.glow = glow6
v.pistol = pistol
local body7 = {}

local shotgun = { body = 0, glow = 0 }

for k, v2 in {
	129428881380303,
	85930174566603,
	104173030913250,
	85458852434940,
	96620296332133,
	82666858217205,
	116289599014939,
	79428031179934,
	103484522531234
} do
	body7[k] = "rbxassetid://" .. v2
end

shotgun.body = body7
local glow7 = {}

for k, v2 in { 77978773354433, 84301306287577, 134494990221415 } do
	glow7[k] = "rbxassetid://" .. v2
end

shotgun.glow = glow7
v.shotgun = shotgun

local v2 = {
	rifle = "AssaultRifle",
	smg = "SMG",
	lmg = "LMG",
	sniper = "Sniper",
	dmr = "DMR",
	shotgun = "Shotgun",
	pistol = "Pistol"
}

for _, class in Crates.CLASSES do
	local v3 = v2[class.id]
	assert(v3 and WeaponSkins.classOf(v3) == class.id, "[CrateOpen] no first gun for the " .. class.id .. " crate")
	local v4 = assert(v[class.id], "[CrateOpen] no pictures for the " .. class.id .. " crate")
	local v5 = #v4.body == 9 and #v4.glow == 3
	assert(v5, "[CrateOpen] " .. class.id .. " crate: sheets missing")
end

local function sheetsOf(p) -- 1 equivalent call inferred from this helper
	return assert(v[p], "[CrateOpen] no crate for class " .. tostring(p))
end

local v3 = {
	"rbxassetid://80719025086581",
	"rbxassetid://129721946515432",
	"rbxassetid://87829046596764",
	"rbxassetid://137205171081221"
}

local vector2 = Vector2.new(0.512, 0.582)
local vector2_2 = Vector2.new(0.512, 0.719)
local v4 = { Vector2.new(0.402, 0.626), Vector2.new(0.734, 0.589) }

local v5 = { 1, 0.9, 0.8, 0.7, 0.62 }

local v6 = { 0.46, 1, 0.8, 0.66, 0.56 }

local v7 = { 1.07, 1.77, 2.42 }
local v8 = v7[3] + 0.3

local color = Color3.fromRGB(96, 100, 110)

local v9 = nil
local flag = false

task.spawn(function()
	ContentProvider:PreloadAsync({
		"rbxassetid://131110319862956",
		"rbxassetid://74731620905366",
		"rbxassetid://117683324143574",
		v3[1],
		v3[2],
		v3[3],
		v3[4],
		"rbxassetid://103525503120427",
		"rbxassetid://97164813758371",
		"rbxassetid://140593459045914",
		"rbxassetid://133242873335745"
	})
end)

local set = {}
local function fetch(p)
	if set[p] then
		return
	end

	local v10 = {}

	for _, v11 in p.body do
		table.insert(v10, v11)
	end

	for _, v11 in p.glow do
		table.insert(v10, v11)
	end

	ContentProvider:PreloadAsync(v10)
	set[p] = true
end
function CrateOpen.warm(p: string)
	task.spawn(fetch, sheetsOf(p))
end

local function toolOf(childName: string) -- 1 equivalent call inferred from this helper
	local tool = ToolTemplates:FindFirstChild(childName)
	assert(tool and tool:IsA("Tool"), "[CrateOpen] no tool " .. childName)
	return tool
end

local function gunsOf(class: string)
	local classGuns = WeaponSkins.classGuns(v2[class])
	assert(#classGuns > 0, "[CrateOpen] no guns in class " .. class)

	for _, v10 in { "primary", "secondary" } do
		local v11 = ShopData.PICKS[v10]
		local v12 = LocalPlayer:GetAttribute(v11.attr)

		if type(v12) ~= "string" then
			v12 = v11.default
		end

		local index = table.find(classGuns, v12)

		if index then
			return classGuns, index
		end
	end

	return classGuns, 1
end

local function picture(parent, name: string, image: string, zIndex: number)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = name
	imageLabel.BackgroundTransparency = 1
	imageLabel.BorderSizePixel = 0
	imageLabel.Image = image
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Position = UDim2.fromScale(0.5, 0.5)
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.ZIndex = zIndex
	imageLabel.Parent = parent
	return imageLabel
end

local function show(instance, p: number) -- 4 equivalent calls inferred from this helper
	instance.TextTransparency = 1 - p
	local uiStroke = instance:FindFirstChildOfClass("UIStroke")

	if uiStroke then
		uiStroke.Transparency = 1 - p * 0.75
	end
end

local function vivid(color2: Color3) -- 1 equivalent call inferred from this helper
	local hsv, v10 = color2:ToHSV()
	return Color3.fromHSV(hsv, math.min(1, v10 * 1.1 + 0.12), 1)
end

function CrateOpen.play(p, list, _, callback, callback2)
	local v10 = #list >= 1 and #list <= Crates.MAX_OPEN
	assert(v10, "[CrateOpen] " .. #list .. " prizes")
	assert(not flag, "[CrateOpen] already playing")
	flag = true

	if not v9 then
		v9 = Style.layer(p, "CrateOpen", 29, true)
	end

	local v11 = v9
	v11.Enabled = true
	local frame = Style.frame(v11, "Crates", UDim2.fromScale(1, 1))
	local v12 = nil
	local inputBeganConnection = nil
	local success, result = pcall(function()
		local count = #list

		local v13 = {}

		for k, item in list do
			v13[k] = sheetsOf(item.class) -- inferred equivalent call
		end

		local v14 = false
		task.spawn(function()
			for _, v15 in v13 do
				fetch(v15)
			end

			v14 = true
		end)
		local lastTime = os.clock()

		while not v14 and os.clock() - lastTime < 4 do
			task.wait()
		end

		local viewportSize = workspace.CurrentCamera.ViewportSize

		local v15 = math.max(viewportSize.X, viewportSize.Y * 16 / 9)
		local v16 = v15 * 9 / 16
		local v17 = v16 * 0.74
		local size = math.floor(v17 * v5[count])
		local v18 = size * 0.45 + (count - 1) * size * v6[count]

		if viewportSize.X * 0.94 < v18 then
			size = math.floor(size * viewportSize.X * 0.94 / v18)
		end

		local v19 = size * v6[count]

		local v20 = math.floor((count == 1 and 0.86 or v6[count] * 0.96) * size)
		local v21 = math.floor(v20 / 2.1)
		local _ = v21 * 0.74 / size + 0.37
		local v22 = v16 * 0.17000000000000004 + vector2_2.Y * v17
		local v23 = 32 * viewportSize.Y / 720 * math.clamp(size / 600, 0.5, 1.3)

		local fill = Style.fill(frame, "Dim", Style.INK, UDim2.fromScale(1, 1))
		fill.BackgroundTransparency = 1

		local v24 = v16 * 0.040000000000000036
		local frame2 = Style.frame(
			frame,
			"Shot",
			UDim2.fromOffset(v15, v16),
			UDim2.new(0.5, 0, 0.5, v24),
			Vector2.new(0.5, 0.54)
		)
		frame2.ZIndex = 2
		local uiScale = Instance.new("UIScale")
		uiScale.Parent = frame2
		local v25 = picture(frame2, "Place", "rbxassetid://131110319862956", 1)
		v25.ImageTransparency = 1
		local v26 = picture(frame2, "PlaceLit", "rbxassetid://74731620905366", 2)
		v26.ImageTransparency = 1
		local catch = Instance.new("TextButton")
		catch.Name = "Catch"
		catch.Text = ""
		catch.BackgroundTransparency = 1
		catch.Size = UDim2.fromScale(1, 1)
		catch.Modal = true
		catch.ZIndex = 20
		catch.Parent = frame
		local frame3 = Style.frame(frame, "Fx", UDim2.fromScale(1, 1))
		frame3.ZIndex = 10

		local v27 = math.clamp(viewportSize.Y / 720, 0.75, 1.5)
		local button, v28 = Style.button(
			frame,
			"Continue",
			"CONTINUE",
			Style.HAZARD,
			UDim2.fromOffset(math.floor(v27 * 230), (math.max(46, (math.floor(v27 * 50))))),
			Style.INK,
			(math.floor(v27 * 21))
		)
		button.AnchorPoint = Vector2.new(0.5, 1)
		button.Position = UDim2.fromScale(0.5, 0.95)
		button.Visible = false
		button.ZIndex = 22
		v28.ZIndex = 22
		local uiScale_2 = Instance.new("UIScale")
		uiScale_2.Parent = button

		local random = Random.new()
		local v29 = nil
		local flag2 = false
		local function readyAtOf() -- 1 equivalent call inferred from this helper
			return v29
		end

		local function isClosing()
			return flag2
		end

		local v30 = (count - 1) * 0.14 + v8 + 0.9
		local v31 = {}
		local v32 = 1

		for k, item in list do
			local tier = Crates.tierOf(item.tier)
			local v55 = vivid(tier.color) -- inferred equivalent call
			local rank = 1

			for k2, v57 in Crates.TIERS do
				if v57.id == tier.id then
					rank = k2
				end
			end

			local v57 = v15 / 2 + (vector2_2.X - 0.5) * v17 + (k - (count + 1) / 2) * v19
			local fall = picture(frame2, "Fall" .. k, "rbxassetid://117683324143574", 3)
			fall.ImageColor3 = Color3.new(0, 0, 0)
			fall.ImageTransparency = 1
			fall.Position = UDim2.fromOffset(v57, v22)
			fall.Size = UDim2.fromOffset(size * 0.5, size * 0.14)
			local frame4 = Style.frame(
				frame2,
				"Crate" .. k,
				UDim2.fromOffset(size, size),
				UDim2.fromOffset(v57, v22),
				vector2_2
			)
			frame4.ZIndex = k + 3
			frame4.Visible = false
			local halo = picture(frame4, "Halo", "rbxassetid://117683324143574", 1)
			halo.ImageColor3 = v55
			halo.ImageTransparency = 1
			halo.Position = UDim2.fromScale(vector2.X, vector2.Y)
			local body8 = {}
			local glow8 = {}

			for i = 1, 9 do
				local v62 = picture(frame4, "Body" .. i, v13[k].body[i], 2)
				v62.ImageRectSize = Vector2.new(512, 512)
				v62.ImageTransparency = i == 1 and 0 or 0.999
				body8[i] = v62
			end

			for i = 1, 3 do
				local v62 = picture(frame4, "Glow" .. i, v13[k].glow[i], 3)
				v62.ImageRectSize = Vector2.new(256, 256)
				v62.ImageColor3 = Style.WHITE
				v62.ImageTransparency = 0.999
				glow8[i] = v62
			end

			local frame5 = Style.frame(
				frame4,
				"Light",
				UDim2.fromScale(1.6, 1.6),
				UDim2.fromScale(0.5, 0.5),
				Vector2.new(0.5, 0.5)
			)
			frame5.ZIndex = 4
			local function lightPic(name: string, image: string, p2: number?, flag3: boolean)
				local v62 = picture(frame5, name, image, 4)

				if p2 then
					v62.ImageRectSize = Vector2.new(p2, p2)
				end

				local imageColor = if flag3 then Style.WHITE else v55
				v62.ImageColor3 = imageColor
				v62.ImageTransparency = 0.999
				return v62
			end

			local burstA = {}
			local burstB = {}

			for i = 1, #v3 do
				local v66 = picture(frame5, "BurstA" .. i, v3[i], 4)
				v66.ImageRectSize = Vector2.new(512, 512)

				v66.ImageColor3 = v55
				v66.ImageTransparency = 0.999

				burstA[i] = v66
				local v69 = picture(frame5, "BurstB" .. i, v3[i], 4)
				v69.ImageRectSize = Vector2.new(512, 512)

				v69.ImageColor3 = v55
				v69.ImageTransparency = 0.999

				burstB[i] = v69
			end

			local shaft = picture(frame5, "Shaft", "rbxassetid://97164813758371", 4)

			shaft.ImageColor3 = v55
			shaft.ImageTransparency = 0.999
			local hotA = picture(frame5, "HotA", "rbxassetid://103525503120427", 4)

			hotA.ImageRectSize = Vector2.new(256, 256)

			hotA.ImageColor3 = Style.WHITE
			hotA.ImageTransparency = 0.999
			local hotB = picture(frame5, "HotB", "rbxassetid://103525503120427", 4)

			hotB.ImageRectSize = Vector2.new(256, 256)

			hotB.ImageColor3 = Style.WHITE
			hotB.ImageTransparency = 0.999
			local shaftHot = picture(frame5, "ShaftHot", "rbxassetid://140593459045914", 4)

			shaftHot.ImageColor3 = Style.WHITE
			shaftHot.ImageTransparency = 0.999
			local v68

			if item.kind == "skin" then
				v68 = WeaponSkins.find(item.item)
			end

			local card = nil
			local aura = nil
			local v71 = nil
			local uiScale2 = nil
			local v72 = nil
			local uiScale3 = nil
			local dup

			if v68 == nil then
				dup = false
			else
				dup = item.dup == true
			end

			local v74 = nil
			local uiScale4 = nil
			local scrapLine = nil
			local xpLine = nil
			local xpCell = nil
			local guns, gunAt = gunsOf(item.class)

			if v68 then
				card = Style.frame(
					frame4,
					"Skin",
					UDim2.fromOffset(0, 0),
					UDim2.fromScale(vector2.X, vector2.Y),
					Vector2.new(0.5, 0.5)
				)
				card.ZIndex = 5
				card.Visible = false
				aura = picture(card, "Motes", "rbxassetid://133242873335745", 5)
				aura.SizeConstraint = Enum.SizeConstraint.RelativeXX
				aura.Size = UDim2.fromScale(0.9, 0.9)
				aura.ImageRectSize = Vector2.new(256, 256)
				aura.ImageColor3 = v55:Lerp(Style.WHITE, 0.45)
				aura.ImageTransparency = 0.2

				local label = Style.label(card, "Name", v68.name, 20, Style.FONT, 2.5)
				label.AutomaticSize = Enum.AutomaticSize.None
				label.AnchorPoint = Vector2.new(0.5, 1)
				label.Position = UDim2.fromScale(0.5, 0.2)
				label.Size = UDim2.fromScale(0.94, 0.2)
				label.TextScaled = true
				label.TextYAlignment = Enum.TextYAlignment.Bottom
				label.ZIndex = 7
				local uiTextSizeConstraint = Instance.new("UITextSizeConstraint")
				uiTextSizeConstraint.MinTextSize = 12
				uiTextSizeConstraint.MaxTextSize = math.max(16, (math.floor(size * 0.06)))
				uiTextSizeConstraint.Parent = label

				if callback2 and not dup then
					local v80

					if count == 1 then
						v80 = math.floor(v27 * 150)
					else
						v80 = math.floor((math.clamp(v19 - 10, 96, 170)))
					end

					local v81 = count ~= 1 and 44 or math.max(46, (math.floor(v27 * 50)))
					local v82
					v72, v82 = Style.button(
						frame,
						"Equip" .. k,
						"EQUIP",
						Style.STEEL_LIGHT,
						UDim2.fromOffset(v80, v81),
						Style.WHITE,
						(math.clamp(math.floor(v81 * 0.42), 14, 22))
					)
					v72.AnchorPoint = Vector2.new(0.5, 0)
					v72.Visible = false
					v72.ZIndex = 22
					v82.ZIndex = 22
					uiScale3 = Instance.new("UIScale")
					uiScale3.Parent = v72
					local v83 = false
					local item2 = item.item
					local v84 = v72
					v72.Activated:Connect(function()
						if v83 or not v84.Visible then
							return
						end

						v83 = true
						v84.AutoButtonColor = false
						v84.BackgroundColor3 = Style.STEEL
						ClaimAudio.press()
						v82.Text = callback2(item2)
						v82.TextColor3 = Style.GOOD
					end)
				end

				if dup then
					v71 = Style.fill(
						card,
						"Stamp",
						Style.INK,
						UDim2.fromScale(0.8, 0.44),
						UDim2.fromScale(0.5, 0.5),
						Vector2.new(0.5, 0.5)
					)
					v71.ZIndex = 9
					v71.Rotation = -7
					v71.Visible = false
					Style.corner(v71, 6)
					Style.stroke(v71, 3, 0, Style.HAZARD, true)
					local label2 = Style.label(v71, "Words", "ALREADY OWNED", 22, Style.FONT, 2)
					label2.AutomaticSize = Enum.AutomaticSize.None
					label2.AnchorPoint = Vector2.new(0.5, 0.5)
					label2.Position = UDim2.fromScale(0.5, 0.5)
					label2.Size = UDim2.fromScale(0.9, 0.7)
					label2.TextScaled = true
					label2.TextColor3 = Style.HAZARD
					label2.ZIndex = 10
					uiScale2 = Instance.new("UIScale")
					uiScale2.Parent = v71

					v74 = Style.frame(
						frame4,
						"Paid",
						UDim2.fromScale(0.8, 0.3),
						UDim2.fromScale(0.5, 0.37),
						Vector2.new(0.5, 0.5)
					)
					v74.ZIndex = 8
					v74.Visible = false
					uiScale4 = Instance.new("UIScale")
					uiScale4.Parent = v74
					local v80 = v74

					local function line(p2: string, p3: string, p4: number, p5: number, textColor: Color3)
						local label3 = Style.label(v80, p2, p3, p4, Style.FONT, 2.5)
						label3.AutomaticSize = Enum.AutomaticSize.None
						label3.AnchorPoint = Vector2.new(0.5, 0.5)
						label3.Position = UDim2.fromScale(0.5, p5)
						label3.Size = UDim2.new(1, 0, 0, p4 + 6)
						label3.TextColor3 = textColor
						label3.ZIndex = 8
						return label3
					end

					local v81 = math.max(18, (math.floor(size * 0.062)))
					local v82 = (item.xp or 0) > 0
					line("Owned", "ALREADY OWNED", math.max(12, (math.floor(size * 0.032))), 0.06, Style.HAZARD)
					scrapLine = line("Scrap", "+0 SCRAP", v81, v82 and 0.36 or 0.5, Style.HAZARD)

					if v82 then
						xpLine = line("Xp", "+0 XP", math.max(15, (math.floor(v81 * 0.8))), 0.66, Style.WHITE)
						local v83 = math.max(14, (math.floor(size * 0.05)))
						local v84 = math.max(6, (math.floor(v83 * 0.4)))
						local frame6 = Style.frame(
							v74,
							"Cells",
							UDim2.fromOffset(v83 * 5 + 16, v84),
							UDim2.fromScale(0.5, 0.92),
							Vector2.new(0.5, 0.5)
						)
						frame6.ZIndex = 8

						for i = 1, 5 do
							local fill2 = Style.fill(
								frame6,
								"Cell" .. i,
								Style.INK,
								UDim2.fromOffset(v83, v84),
								UDim2.fromOffset((i - 1) * (v83 + 4), 0)
							)
							fill2.BackgroundTransparency = 0.35
							fill2.ZIndex = 8
							Style.stroke(fill2, 1.5, 0.3, Style.WHITE, true)

							if i == 1 then
								xpCell = fill2
							end
						end
					end
				end
			end

			local label = Style.label(
				frame4,
				"Rarity",
				tier.name,
				math.max(16, (math.floor(size * 0.06))),
				Style.FONT,
				2.5
			)
			label.AnchorPoint = Vector2.new(0.5, 1)
			label.Position = UDim2.fromScale(0.5, 0.03)
			label.TextColor3 = v55:Lerp(Style.WHITE, 0.2)
			label.ZIndex = 6
			show(label, 0) -- inferred equivalent call
			local v80 = v68 and "" or string.format("+%d SCRAP", item.scrap or 0)
			local label2 = Style.label(
				frame4,
				"Name",
				v80,
				math.max(15, (math.floor(size * (dup and 0.05 or 0.04)))),
				Style.FONT,
				2.5
			)
			label2.AnchorPoint = Vector2.new(0.5, 0)
			label2.Position = UDim2.fromScale(0.5, 0.24)

			if dup then
				label2.TextColor3 = Style.HAZARD
			end

			label2.ZIndex = 6
			show(label2, 0) -- inferred equivalent call
			local v81 = {}
			v81.holder = frame4
			v81.body = body8
			v81.glow = glow8
			v81.fall = fall
			v81.halo = halo
			v81.burstA = burstA
			v81.burstB = burstB
			v81.hotA = hotA
			v81.hotB = hotB
			v81.shaft = shaft
			v81.shaftHot = shaftHot
			v81.settled = false
			v81.hitAt = 0
			v81.gone = false
			v81.paid = v74
			v81.paidScale = uiScale4
			v81.scrapLine = scrapLine
			v81.xpLine = xpLine
			v81.xpCell = xpCell
			v81.scrapAmt = item.scrap or 0
			v81.xpAmt = item.xp or 0
			v81.counted = false
			v81.nextTick = 0
			v81.card = card
			v81.equip = v72
			v81.equipScale = uiScale3
			v81.rarity = label
			v81.name = label2
			v81.stamp = v71
			v81.stampScale = uiScale2
			v81.dup = dup
			v81.stamped = false
			local skin

			if v68 then
				skin = item.item
			end

			v81.skin = skin
			v81.guns = guns
			v81.gunAt = gunAt
			v81.view = nil
			v81.cam = nil
			v81.gunCf = CFrame.identity
			v81.gunLook = Vector3.new(0, 0, 1)
			v81.swapAt = -10
			v81.swapDir = 0
			v81.aura = aura
			v81.hit = false
			v81.color = v55
			v81.rank = rank
			v81.size = size
			v81.x = v57
			v81.dropAt = (k - 1) * 0.14
			v81.burstAt = v30 + (k - 1) * 0.35
			v81.landed = false
			v81.kicks = 0
			v81.burst = false
			v81.risen = false
			v81.jolt = -10
			v81.phase = 0
			v81.light = 0
			v81.shown = -1
			v81.nextEmber = 0
			v81.nextSpark = 0
			v81.bits = {}
			table.insert(v31, v81)

			if v31[v32].rank < rank then
				v32 = k
			end
		end

		v26.ImageColor3 = v31[v32].color

		local function fitGun(state, swapDir: number)
			local card = state.card
			local skin = state.skin

			if not card or not skin or state.gone then
				return
			end

			if state.view then
				state.view:Destroy()
			end

			local view = ToolIcon.make(toolOf(state.guns[state.gunAt]), card, 17) -- inferred equivalent call
			view.AnchorPoint = Vector2.new(0.5, 0.5)
			view.Position = UDim2.fromScale(0.5, 0.5)
			view.Size = UDim2.fromScale(1, 1)
			view.ZIndex = 6
			local model = view:FindFirstChildOfClass("Model")
			WeaponSkins.paint(model, skin)
			local currentCamera = view.CurrentCamera
			local boundingBox = model:GetBoundingBox()
			local gunLook = currentCamera.CFrame.Position - boundingBox.Position
			state.view = view
			state.cam = currentCamera
			state.gunCf = boundingBox
			state.gunLook = gunLook
			state.swapAt = swapDir == 0 and -10 or os.clock()
			state.swapDir = swapDir

			if state.stamped then
				view.ImageColor3 = color
			end
		end

		local v55 = nil

		for _, v56 in v31 do
			fitGun(v56, 0)

			if not v56.card or (v56.dup or v55) then
				continue
			end

			v55 = v56
		end

		local fill2 = Style.fill(
			frame,
			"Dock",
			Style.INK,
			UDim2.fromOffset(0, 0),
			UDim2.new(0.5, 0, 1, -math.max(8, (math.floor(viewportSize.Y * 0.035)))),
			Vector2.new(0.5, 1)
		)
		fill2.AutomaticSize = Enum.AutomaticSize.XY
		fill2.BackgroundTransparency = 0.3
		fill2.ZIndex = 21
		fill2.Visible = false
		Style.corner(fill2, 10)
		local uiPadding = Instance.new("UIPadding")
		local udim = UDim.new(0, 10)
		local udim2 = UDim.new(0, 10)
		uiPadding.PaddingLeft = udim
		uiPadding.PaddingRight = udim2
		local udim3 = UDim.new(0, 8)
		local udim4 = UDim.new(0, 8)
		uiPadding.PaddingTop = udim3
		uiPadding.PaddingBottom = udim4
		uiPadding.Parent = fill2
		local uiListLayout = Instance.new("UIListLayout")
		uiListLayout.FillDirection = Enum.FillDirection.Horizontal
		uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uiListLayout.Padding = UDim.new(0, 10)
		uiListLayout.Parent = fill2
		local uiScale2 = Instance.new("UIScale")
		uiScale2.Parent = fill2
		button.AnchorPoint = Vector2.zero
		button.LayoutOrder = 3
		button.Visible = true
		button.Parent = fill2
		local v56

		if count == 1 and v31[1].equip then
			local equip = v31[1].equip
			equip.AnchorPoint = Vector2.zero
			equip.LayoutOrder = 2
			equip.Visible = true
			equip.Parent = fill2
			v56 = true
		else
			v56 = false
		end

		local v57 = math.max(48, (math.floor(56 * v27)))

		local v58 = {}

		if v55 and #v55.guns > 1 then
			local v59 = math.max(46, (math.floor(v27 * 50)))
			local v60 = math.floor((math.clamp(viewportSize.X * 0.22, 130, 240)))
			local v61 = math.max(14, (math.floor(19 * v27)))
			local frame4 = Style.frame(fill2, "Gun", UDim2.fromOffset(v60, v59))
			frame4.LayoutOrder = 1
			local label = Style.label(frame4, "Name", "", v61, Style.FONT, 2)
			label.AutomaticSize = Enum.AutomaticSize.None
			label.AutoLocalize = false
			label.AnchorPoint = Vector2.new(0.5, 0)
			label.Position = UDim2.new(0.5, 0, 0, 2)
			label.Size = UDim2.new(1, 0, 0, v61 + 6)
			label.TextTruncate = Enum.TextTruncate.AtEnd
			local v62 = math.max(7, (math.floor(8 * v27)))
			local frame5 = Style.frame(
				frame4,
				"Pips",
				UDim2.fromOffset(#v55.guns * (v62 + 5) - 5, v62),
				UDim2.new(0.5, 0, 1, -4),
				Vector2.new(0.5, 1)
			)
			local v63 = {}

			for i = 1, #v55.guns do
				v63[i] = Style.fill(
					frame5,
					"Pip" .. i,
					Style.WHITE,
					UDim2.fromOffset(v62, v62),
					UDim2.fromOffset((i - 1) * (v62 + 5), 0)
				)
			end

			local function says()
				local gun = v55.guns[v55.gunAt]
				label.Text = KillFeed.weapon(gun) or gun

				for k, v64 in v63 do
					local backgroundColor

					if k == v55.gunAt then
						backgroundColor = v55.color
					else
						backgroundColor = Style.WHITE
					end

					v64.BackgroundColor3 = backgroundColor
					v64.BackgroundTransparency = k == v55.gunAt and 0 or 0.65
				end
			end
			says()
			local function fn(swapDir: number)
				local v64 = readyAtOf() -- inferred equivalent call

				if flag2 or not v64 or os.clock() < v64 then
					return
				end

				for _, v65 in v31 do
					if not v65.card or v65.gone then
						continue
					end

					v65.gunAt = (v65.gunAt - 1 + swapDir) % #v65.guns + 1
					fitGun(v65, swapDir)
				end

				for _, v65 in v58 do
					if v65.dir == swapDir then
						v65.pressAt = os.clock()
					end
				end

				ClaimAudio.awardTick()
				says()
			end

			for _, dir in { -1, 1 } do
				local textButton = Instance.new("TextButton")
				textButton.Name = dir < 0 and "Prev" or "Next"
				textButton.Text = ""
				textButton.AutoButtonColor = false
				textButton.BackgroundTransparency = 1
				textButton.BorderSizePixel = 0
				textButton.AnchorPoint = Vector2.new(0.5, 0.5)
				textButton.Size = UDim2.fromOffset(v57, (math.floor(v57 * 1.3)))
				textButton.ZIndex = 22
				textButton.Visible = false
				textButton.Parent = frame
				local v65 = v57 * 0.46
				local v66 = math.max(5, (math.floor(v57 * 0.12)))

				for i = 1, 2 do
					for _, v67 in { -1, 1 } do
						local v68 = i == 1 and 5 or 0
						local fill3 = Style.fill
						local v70

						if i == 1 then
							v70 = Style.INK
						else
							v70 = Style.WHITE
						end

						local v71 = fill3(
							textButton,
							"Bar",
							v70,
							UDim2.fromOffset(v65 + v68, v66 + v68),
							UDim2.new(0.5, 0, 0.5, v67 * v65 * 0.33),
							Vector2.new(0.5, 0.5)
						)
						v71.Rotation = -v67 * dir * 45
						v71.ZIndex = i + 21
						Style.corner(v71, 2)
					end
				end

				local uiScale3 = Instance.new("UIScale")
				uiScale3.Parent = textButton
				textButton.Activated:Connect(function()
					fn(dir)
				end)
				table.insert(v58, { b = textButton, scale = uiScale3, dir = dir, pressAt = -10 })
			end

			inputBeganConnection = UserInputService.InputBegan:Connect(function(input)
				local keyCode = input.KeyCode

				if keyCode == Enum.KeyCode.ButtonL1 or keyCode == Enum.KeyCode.Left then
					fn(-1)
				elseif keyCode == Enum.KeyCode.ButtonR1 or keyCode == Enum.KeyCode.Right then
					fn(1)
				end
			end)
		end

		local function at(p2, vector2_3: Vector2) -- 8 equivalent calls inferred from this helper
			local v59 = p2.holder.AbsolutePosition - frame3.AbsolutePosition
			local absoluteSize = p2.holder.AbsoluteSize
			return v59 + Vector2.new(vector2_3.X * absoluteSize.X, vector2_3.Y * absoluteSize.Y)
		end

		local function frame4(state, shown: number)
			if shown == state.shown then
				return
			end

			state.shown = shown
			local v59 = shown // 4 + 1
			local v60 = shown % 4

			for i = 1, 9 do
				state.body[i].ImageTransparency = i == v59 and 0 or 0.999
			end

			state.body[v59].ImageRectOffset = Vector2.new(v60 % 2 * 512, v60 // 2 * 512)
			local v61 = shown // 16 + 1
			local v62 = shown % 16
			state.glow[v61].ImageRectOffset = Vector2.new(v62 % 4 * 256, v62 // 4 * 256)
		end

		local function lightFrame(items, p2, p3: number, p4: number, p5: number, p6: number)
			local v59 = p3 // 4 + 1
			local v60 = p3 % 4

			for k, item in items do
				if k == v59 then
					item.ImageRectOffset = Vector2.new(v60 % 2 * 512, v60 // 2 * 512)
					item.ImageTransparency = math.clamp(1 - p4 * p5, 0, 0.999)
				else
					item.ImageTransparency = 0.999
				end
			end

			p2.ImageRectOffset = Vector2.new(p3 % 4 * 256, p3 // 4 * 256)
			p2.ImageTransparency = math.clamp(1 - p4 * p6, 0, 0.999)
		end
		local v59 = false

		local function tint(p2, imageColor: Color3, p3: number)
			local v60 = p2.shown // 16 + 1

			for i = 1, 3 do
				p2.glow[i].ImageColor3 = imageColor
				p2.glow[i].ImageTransparency = i ~= v60 and 0.999 or math.min(0.999, 1 - p3)
			end
		end

		local function bit(data, vector2_3: Vector2, color2: Color3, p2: number, vx: number, vy: number, p3: number, life: number, born: number)
			local fill3 = Style.fill(data.holder, "Bit", color2, UDim2.fromOffset(p2, p2))
			fill3.AnchorPoint = Vector2.new(0.5, 0.5)
			fill3.ZIndex = 5
			table.insert(data.bits, {
				f = fill3,
				x = data.size * vector2_3.X,
				y = data.size * vector2_3.Y,
				vx = vx,
				vy = vy,
				g = p3,
				spin = random:NextNumber(-500, 500),
				born = born,
				life = life
			})
		end

		local now = os.clock()
		local v60 = -10
		local v61 = 0
		local v62 = -10
		local v63 = v31[1].dropAt + v8
		local v64 = now + v63 + 0.05
		local flag3 = false
		local function finish()
			if flag3 then
				return
			end

			flag3 = true
			Style.stop(frame)
			frame:Destroy()
			v11.Enabled = false
			flag = false

			if v12 then
				v12()
			end

			if inputBeganConnection then
				inputBeganConnection:Disconnect()
			end

			ClaimAudio.hush(0)
			callback()
		end
		local function kick(p2: number, p3: number) -- 5 equivalent calls inferred from this helper
			if v61 * math.max(0, 1 - (p2 - v60) / 0.35) <= p3 then
				v60 = p2
				v61 = p3
			end
		end
		local function land(p2, hitAt: number) -- 1 equivalent call inferred from this helper
			p2.landed = true
			p2.fall.ImageTransparency = 1
			ClaimAudio.crateDrop()
			ClaimFx.smoke(frame3, at(p2, vector2_2), 7, v23, v23 * 4.5) -- inferred equivalent call
			kick(hitAt, 6) -- inferred equivalent call
		end

		local function kicked(p2, kicks: number, jolt: number)
			p2.kicks = kicks
			p2.jolt = jolt
			v62 = jolt
			ClaimAudio.crateRoll(kicks * 0.3)

			if kicks >= 2 then
				ClaimAudio.crateLatch(kicks - 1)
				ClaimFx.sparks(frame3, at(p2, v4[kicks - 1]), kicks * 4 + 5, v23 * 0.6, 0.5) -- inferred equivalent call
			end

			ClaimFx.smoke(frame3, at(p2, vector2_2), kicks + 1, v23, v23 * (kicks + 1.5)) -- inferred equivalent call
			kick(jolt, kicks * 1.5 + 1) -- inferred equivalent call
		end
		local function burst(state, flag4: boolean, hitAt: number)
			state.burst = true
			local _ = at(state, vector2) -- inferred equivalent call
			local _ = (state.rank - 1) * 0.2 + 1
			ClaimAudio.crateBurst(state.rank, flag4 and 1 or 0.7)
			ClaimFx.flash(frame3, state.rank * 0.04 + 0.08, 0.3, state.color:Lerp(Style.WHITE, 0.3))

			kick(hitAt, state.rank * 3 + 5) -- inferred equivalent call
		end

		local function continue_()
			local v65 = v29

			if flag2 or not v65 or os.clock() < v65 + 0.25 then
				return
			end

			flag2 = true
			ClaimAudio.press()
		end
		button.Activated:Connect(continue_)
		local PadMenus = require(script.Parent:WaitForChild("PadMenus"))
		v12 = PadMenus.hold("crate", continue_)

		ClaimAudio.press()
		ClaimAudio.rewardIn(v30)
		local fn
		Style.animate(frame, function(p2: number, p3: number)
			local success, result = xpcall(fn, debug.traceback, p2, p3)

			if success then
				return result
			end

			finish()
			task.spawn(error, "[CrateOpen] " .. tostring(result), 0)
			return false
		end)

		fn = function(p2: number, hitAt: number): boolean
			if flag2 then
				finish()
				return false
			end

			local v65 = hitAt - now
			local v66 = math.min(1, v65 / 0.3)
			ClaimAudio.hush(v66)
			fill.BackgroundTransparency = 1 - v66 * 0.92
			v25.ImageTransparency = 1 - v66

			if v64 <= hitAt and v65 < v30 - 0.05 then
				local v67 = math.clamp((v65 - v63) / (v30 - v63), 0, 1)
				ClaimAudio.crateRoll(v67)
				v64 = hitAt + 0.24 - v67 * 0.17
			end

			local maxLight = 0
			local v67 = true

			for k, v68 in v31 do
				local v69 = v65 - v68.dropAt

				if v69 < 0 and not v68.burst then
					v67 = false
				else
					v68.holder.Visible = true

					if not v68.burst then
						v67 = false

						if v69 < 0.42 then
							local v70 = v69 / 0.42
							v68.holder.Position = UDim2.fromOffset(v68.x, v22 - (1 - v70 * v70) * v16 * 0.95)
							v68.holder.Rotation = (1 - v70) * (k % 2 == 0 and 9 or -9)
							v68.fall.ImageTransparency = 1 - 0.5 * v70
							v68.fall.Size = UDim2.fromOffset(
								v68.size * (0.75 - 0.3 * v70),
								v68.size * (0.2 - 0.07 * v70)
							)
							frame4(v68, 0)
							local white = Style.WHITE
							local v71 = v68.shown // 16 + 1

							v68.glow[1].ImageColor3 = white
							v68.glow[1].ImageTransparency = v71 == 1 and 0.55 or 0.999
							v68.glow[2].ImageColor3 = white
							v68.glow[2].ImageTransparency = v71 == 2 and 0.55 or 0.999
							v68.glow[3].ImageColor3 = white
							v68.glow[3].ImageTransparency = v71 == 3 and 0.55 or 0.999
						else
							if not v68.landed then
								land(v68, hitAt) -- inferred equivalent call
							end

							v68.holder.Position = UDim2.fromOffset(v68.x, v22)
							v68.holder.Rotation = 0

							for i = 1, 3 do
								if v68.kicks < i and v7[i] <= v69 then
									kicked(v68, i, hitAt)
								end
							end

							if v68.burstAt <= v65 then
								burst(v68, k == 1, hitAt)
							end

							local v70 = math.clamp((v69 - v8) / math.max(0.01, v68.burstAt - v68.dropAt - v8), 0, 1)

							if v69 < v7[1] then
								frame4(v68, math.clamp(math.floor((v69 - 0.42) * 24) + 1, 1, 6))
							elseif v69 < v7[2] then
								frame4(v68, math.clamp(math.floor((v69 - v7[1]) * 20) + 7, 7, 10))
							elseif v69 < v7[3] then
								frame4(v68, math.clamp(math.floor((v69 - v7[2]) * 20) + 11, 11, 15))
							elseif v69 < v8 then
								frame4(v68, math.clamp(math.floor((v69 - v7[3]) * 20) + 16, 16, 21))
							else
								v68.phase += p2 * (v70 * 17 + 11)
								frame4(v68, math.floor(v68.phase) % 4 + 22)
							end

							local v71 = math.clamp(
								(v69 - v7[1]) / math.max(0.01, v68.burstAt - v68.dropAt - v7[1]),
								0,
								1
							)
							local v72 = v70 * 0.06 * v70 + 1
							v68.holder.Size = UDim2.fromOffset(v68.size * v72, v68.size * v72)
							local v73 = math.max(0, 1 - (hitAt - v68.jolt) / 0.2)
							local v74 = math.clamp((v69 - v8) / 0.3, 0, 1)
							local v75 = math.sin(hitAt * (v70 * 22 + 6)) * 0.45 + 0.55
							tint(
								v68,
								Style.WHITE:Lerp(v68.color, v74),
								math.clamp(v71 * 0.3 + 0.35 + v70 * 0.35 * v75 + v73 * 0.5, 0, 1)
							)
							v68.halo.ImageTransparency = 1 - math.min(1, v73 * 0.25 + v74 * 0.55 * (v75 * 0.4 + 0.6))
							v68.halo.Size = UDim2.fromScale(v70 * 0.3 + 0.55, v70 * 0.3 + 0.55)
							v68.light = v74 * 0.3 * (v75 * 0.4 + 0.6) * (v70 * 0.6 + 0.4)

							if v70 > 0 and v68.nextSpark <= hitAt then
								v68.nextSpark = hitAt + 0.22 - v70 * 0.14
								ClaimFx.sparks(frame3, at(v68, v4[random:NextInteger(1, 2)]), 3, v23 * 0.5, 0.4) -- inferred equivalent call
							end
						end
					end

					if v68.burst then
						local v70 = v65 - v68.burstAt
						frame4(v68, math.clamp(math.floor(v70 * 26) + 26, 26, 35))
						local color2 = v68.color
						local v71 = v68.shown // 16 + 1

						v68.glow[1].ImageColor3 = color2
						v68.glow[1].ImageTransparency = v71 == 1 and 0 or 0.999
						v68.glow[2].ImageColor3 = color2
						v68.glow[2].ImageTransparency = v71 == 2 and 0 or 0.999
						v68.glow[3].ImageColor3 = color2
						v68.glow[3].ImageTransparency = v71 == 3 and 0 or 0.999

						v68.fall.ImageTransparency = 1
						v68.holder.Rotation = 0
						local v72 = math.max(0, 1 - v70 / 0.3)
						v68.holder.Size = UDim2.fromOffset(v68.size * (v72 * 0.1 + 1), v68.size * (v72 * 0.1 + 1))
						v68.holder.Position = UDim2.fromOffset(v68.x, v22)
						v68.light = math.min(1, v70 / 0.12) * 0.85 * (math.sin(hitAt * 3 + k) * 0.08 + 0.92)
						v68.halo.ImageTransparency = math.sin(hitAt * 3) * 0.05 + 0.5
						v68.halo.Size = UDim2.fromScale(1, 1)

						local v73 = math.min(1, v68.rank * 0.09 + 0.72)
						local v74 = v68.rank * 0.14 + 0.3
						local v75 = v70 / 0.8 * 15

						if v75 < 15 then
							local v76 = math.floor(v75)
							lightFrame(v68.burstA, v68.hotA, v76, 1, v73, math.min(1, v74 + 0.3))
							lightFrame(v68.burstB, v68.hotB, v76 + 1, v75 - v76, v73, math.min(1, v74 + 0.3))
						else
							if not v68.settled then
								v68.settled = true

								for i = 1, #v68.burstA do
									v68.burstA[i].ImageTransparency = 1
									v68.burstB[i].ImageTransparency = 1
								end

								v68.hotA.ImageTransparency = 1
								v68.hotB.ImageTransparency = 1
							end

							local v76 = not v68.hit and 0 or math.max(0, 1 - (hitAt - v68.hitAt) / 0.5)
							local v77 = math.sin(hitAt * 2.4 + k) * 0.07 + 0.93
							v68.shaft.ImageTransparency = math.clamp(1 - v73 * v77 - v76 * 0.2, 0, 0.999)
							v68.shaftHot.ImageTransparency = math.clamp(1 - v74 * v77 - v76 * 0.5, 0, 0.999)
						end

						local v76 = math.clamp((v70 - 0.3) / 0.45, 0, 1)

						if v76 > 0 then
							if not v68.risen then
								v68.risen = true
								ClaimAudio.crateShow(v68.rank)
							end

							local easeOut = Style.easeOut(v76)
							local card = v68.card

							if card then
								local v77 = Style.pop(v76)
								card.Visible = true
								card.Size = UDim2.fromOffset(v20 * v77, v21 * v77)
								card.Position = UDim2.new(
									vector2.X + (0.5 - vector2.X) * easeOut,
									0,
									vector2.Y + (0.37 - vector2.Y) * easeOut,
									math.sin(hitAt * 2.2 + k) * v68.size * 0.006
								)
								card.Rotation = (1 - easeOut) * (k % 2 == 0 and 10 or -10)

								local cam = v68.cam

								if cam then
									local v78 = math.sin((hitAt - now) * 0.9 + k) * 0.55 + (1 - easeOut) * 1.1
									cam.CFrame = CFrame.lookAt(
										v68.gunCf.Position + CFrame.Angles(0, v78, 0):VectorToWorldSpace(v68.gunLook),
										v68.gunCf.Position
									)
								end

								local view = v68.view

								if view and not v68.gone then
									local easeOut2 = Style.easeOut((math.clamp((hitAt - v68.swapAt) / 0.22, 0, 1)))
									view.Position = UDim2.new(
										0.5,
										math.floor(v68.swapDir * (1 - easeOut2) * v20 * 0.12),
										0.5,
										0
									)
									view.ImageTransparency = 1 - easeOut2
								end

								local aura = v68.aura

								if aura then
									local v78 = math.floor((hitAt - now) * 12) % 16
									aura.ImageRectOffset = Vector2.new(v78 % 4 * 256, v78 // 4 * 256)
								end

								if v76 >= 1 and not v68.hit then
									v68.hit = true
									v68.hitAt = hitAt
									local v78 = not (v68.dup or v59)
									v59 = v59 or v78
									ClaimAudio.crateVictory(v68.rank, v78, v68.dup and 0.45 or v78 and 1 or 0.6)
									kick(hitAt, v68.rank + 2) -- inferred equivalent call
								end
							end

							local v77 = math.clamp((v70 - 0.3 - 0.2) / 0.25, 0, 1)
							show(v68.rarity, v77) -- inferred equivalent call
							show(v68.name, v77) -- inferred equivalent call
							v68.rarity.Position = UDim2.fromScale(
								0.5,
								(not card and 0.22 or 0.37 - v21 / v68.size / 2 + 0.005) - 0.02 * Style.easeOut(v77)
							)

							if v68.dup then
								local v78 = v70 - 0.3 - 0.55
								local v79 = math.clamp(v78 / 0.16, 0, 1)
								local stamp = v68.stamp
								local stampScale = v68.stampScale
								local view = v68.view

								if v79 > 0 and stamp and stampScale then
									if not v68.stamped then
										v68.stamped = true
										ClaimAudio.crateLatch(2)
										kick(hitAt, 5) -- inferred equivalent call
									end

									local imageTransparency = math.clamp((v78 - 0.55) / 0.3, 0, 1)

									if imageTransparency > 0 and not v68.gone then
										v68.gone = true
										ClaimAudio.pay()
									end

									stamp.Visible = imageTransparency < 1
									stampScale.Scale = (2.4 - 1.4 * Style.easeOut(v79)) * (1 - imageTransparency * 0.5)

									if view then
										view.ImageColor3 = Style.WHITE:Lerp(color, v79)

										if imageTransparency > 0 then
											view.Position = UDim2.fromScale(0.5, 0.5)
											view.Size = UDim2.fromScale(
												1 - imageTransparency * 0.4,
												1 - imageTransparency * 0.4
											)
											view.ImageTransparency = imageTransparency
											view.Visible = imageTransparency < 1
										end
									end

									if v68.aura then
										v68.aura.ImageTransparency = imageTransparency * 0.8 + 0.2
									end

									local paid = v68.paid
									local paidScale = v68.paidScale
									local v81 = math.clamp((v78 - 0.55 - 0.25) / 0.2, 0, 1)

									if v81 > 0 and paid and paidScale then
										paid.Visible = true
										paidScale.Scale = math.max(0.01, Style.pop(v81))
										local v82 = math.clamp((v78 - 0.55 - 0.4) / 0.6, 0, 1)
										local easeOut2 = Style.easeOut(v82)

										if v68.scrapLine then
											v68.scrapLine.Text = string.format(
												"+%d SCRAP",
												(math.floor(v68.scrapAmt * easeOut2 + 0.5))
											)
										end

										if v68.xpLine then
											v68.xpLine.Text = string.format(
												"+%d XP",
												(math.floor(v68.xpAmt * easeOut2 + 0.5))
											)
										end

										if v68.xpCell then
											v68.xpCell.BackgroundColor3 = Style.INK:Lerp(Style.GOOD, v82)
											v68.xpCell.BackgroundTransparency = (1 - v82) * 0.35
										end

										if v82 > 0 and v82 < 1 and v68.nextTick <= hitAt then
											v68.nextTick = hitAt + 0.07
											ClaimAudio.countTick(v82)
										end

										if v82 >= 1 and not v68.counted then
											v68.counted = true
											ClaimAudio.countDone()
										end
									end
								end
							end
						end
					end

					maxLight = math.max(maxLight, v68.light)

					for i = #v68.bits, 1, -1 do
						local bit2 = v68.bits[i]
						local v70 = (hitAt - bit2.born) / bit2.life

						if v70 >= 1 then
							bit2.f:Destroy()
							table.remove(v68.bits, i)
						else
							bit2.vy += bit2.g * p2
							bit2.x += bit2.vx * p2
							bit2.y += bit2.vy * p2
							bit2.f.Position = UDim2.fromOffset(bit2.x, bit2.y)
							bit2.f.Rotation += bit2.spin * p2
							bit2.f.BackgroundTransparency = math.clamp((v70 - 0.5) / 0.5, 0, 1)
						end
					end
				end
			end

			v26.ImageTransparency = 1 - maxLight
			local scale

			if v65 < v30 then
				local v69 = math.clamp((v65 - 0.42) / (v30 - 0.42), 0, 1)
				scale = v69 * 0.3 * v69 + 1 + math.max(0, 1 - (hitAt - v62) / 0.25) * 0.02
			else
				scale = 1 + 0.3 * (1 - Style.easeOut((math.min(1, (v65 - v30) / 0.3))))
			end

			uiScale.Scale = scale

			local v69 = v61 * math.max(0, 1 - (hitAt - v60) / 0.35)
			frame2.Position = UDim2.new(0.5, math.sin(hitAt * 90) * v69, 0.5, v24 + math.cos(hitAt * 77) * v69)

			if v67 and not v29 then
				local v70 = false

				for _, v71 in v31 do
					v70 = v70 or v71.dup
				end

				v29 = hitAt + 1.9 + (v70 and 0.9 or 0)
			end

			if not (v29 and v29 <= hitAt) then
				return true
			end

			local scale2 = math.max(0.01, Style.pop((math.min(1, (hitAt - v29) / 0.25))))
			fill2.Visible = true
			uiScale2.Scale = scale2

			if #v58 > 0 then
				local v71 = (count == 1 and 0.36 or 0.5) * v20
				local v72 = at(v31[1], Vector2.new(0.5, 0.37)) -- inferred equivalent call
				local v73 = at(v31[count], Vector2.new(0.5, 0.37)) -- inferred equivalent call

				for _, v74 in v58 do
					local v75

					if v74.dir < 0 then
						v75 = v72.X - v71 - v57 * 0.5 - 6
					else
						v75 = v73.X + v71 + v57 * 0.5 + 6
					end

					local v76 = math.clamp(v75, v57 * 0.5 + 6, viewportSize.X - v57 * 0.5 - 6)
					local v77 = math.max(0, 1 - (hitAt - v74.pressAt) / 0.16)
					v74.b.Position = UDim2.fromOffset(v76 + v74.dir * (math.sin(hitAt * 3.2) * 3 + 3 + v77 * 6), v72.Y)
					v74.b.Visible = true
					v74.scale.Scale = scale2 * (1 - v77 * 0.14)
				end
			end

			if v56 then
				return true
			end

			local v71 = fill2.AbsolutePosition.Y - frame3.AbsolutePosition.Y - 6

			for _, v72 in v31 do
				local equip = v72.equip
				local equipScale = v72.equipScale

				if not (equip and equipScale) then
					continue
				end

				local v73 = at(v72, Vector2.new(0.5, 0.775)) -- inferred equivalent call
				equip.Position = UDim2.fromOffset(v73.X, (math.min(v73.Y, v71 - equip.AbsoluteSize.Y)))
				equip.Visible = true
				equipScale.Scale = scale2
			end

			return true
		end
	end)

	if not success then
		frame:Destroy()
		v11.Enabled = false
		flag = false

		if v12 then
			v12()
		end

		if inputBeganConnection then
			inputBeganConnection:Disconnect()
		end

		ClaimAudio.hush(0)
		error("[CrateOpen] " .. tostring(result))
	end
end

function CrateOpen.playing()
	return flag
end

local Players2 = game:GetService("Players")
local localPlayer = Players2.LocalPlayer
localPlayer:GetAttributeChangedSignal("CrateOpenTest"):Connect(function()
	local crateOpenTest = localPlayer:GetAttribute("CrateOpenTest")

	if type(crateOpenTest) ~= "string" then
		return
	end

	if flag then
		warn("[CrateOpen] crateopen: an opening is already playing")
		return
	end

	local v10, class = string.match(crateOpenTest, "^([^|]*)|([^|]*)|")
	assert(v10 and Crates.classOf(class), "[CrateOpen] crateopen: bad test value " .. crateOpenTest)
	local v11 = {}

	for k in string.gmatch(v10, "[^,]+") do
		local dup = string.sub(k, -1) == "!"

		if dup then
			k = string.sub(k, 1, -2)
		end

		local v12 = assert(WeaponSkins.find(k), "[CrateOpen] crateopen: no skin " .. k)
		local dupPay, xp = Crates.dupPay(v12.crate, localPlayer:GetAttribute("Level") or 1)
		local v13 = {
			tier = v12.crate,
			kind = "skin",
			item = k,
			class = class,
			dup = dup,
			scrap = 0,
			xp = 0
		}

		if not dup then
			dupPay = nil
		end

		v13.scrap = dupPay

		if not dup then
			xp = nil
		end

		v13.xp = xp
		table.insert(v11, v13)
	end

	CrateOpen.play(localPlayer:WaitForChild("PlayerGui"), v11, {}, function() end)
end)

return CrateOpen