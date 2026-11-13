local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToolTemplates = ReplicatedStorage:WaitForChild("ToolTemplates")

local Style = require(script.Parent:WaitForChild("Style"))
local ToolIcon = require(script.Parent:WaitForChild("ToolIcon"))
local StreakIcon = require(script.Parent:WaitForChild("StreakIcon"))
local PurchaseShow = require(script.Parent:WaitForChild("PurchaseShow"))
local Crates = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("Crates"))
local WeaponSkins = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("WeaponSkins"))
local NewMenus = require(script.Parent:WaitForChild("NewMenus"))
local CrateOpen = require(script.Parent:WaitForChild("CrateOpen"))

local v = NewMenus.on("Crates")

local v2 = NewMenus.on("Store")
local SkinPreview = require(script.Parent:WaitForChild("SkinPreview"))
local StoreData = require(script.Parent:WaitForChild("StoreData"))
local MenuAudio = require(script.Parent:WaitForChild("MenuAudio"))
local KillFeed = require(script.Parent:WaitForChild("KillFeed"))
local UiTrack = require(script.Parent:WaitForChild("UiTrack"))
local Skins = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("Skins"))
local CareerData = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("CareerData"))
local ShopData = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("ShopData"))

local ArmoryStore = {}
ArmoryStore.SCREEN_ON = v2
ArmoryStore.reveal = nil
ArmoryStore.openBought = nil
local color = Color3.fromRGB(38, 40, 45)
local color2 = Color3.fromRGB(26, 27, 31)

local v3 = {
	buy = "rbxassetid://80064079542018",
	buyShort = "rbxassetid://116221824437572",
	buyOffShort = "rbxassetid://79409238052878",
	claim = "rbxassetid://98153179041297",
	buyOff = "rbxassetid://116067232788719",
	gift = "rbxassetid://115494446598123",
	giftOff = "rbxassetid://126172481374912",
	starter = "rbxassetid://138769693991535",
	card = {
		blue = "rbxassetid://138323273551129",
		purple = "rbxassetid://128221842491313",
		gold = "rbxassetid://98153853312708",
		teal = "rbxassetid://90906943027118",
		navy = "rbxassetid://136281166400515"
	},
	barBuy = "rbxassetid://123967744353452",
	barOff = "rbxassetid://81238639513248",
	barGift = "rbxassetid://89895069740669",
	barGiftOff = "rbxassetid://111390117460768",
	barClaim = "rbxassetid://119379531050956",
	barClaimOff = "rbxassetid://118383637929940",
	pack = {
		scrapS = "rbxassetid://123654579772078",
		scrapM = "rbxassetid://99435192586264",
		scrapL = "rbxassetid://76965385181363",
		xp30 = "rbxassetid://70693654167865",
		xp120 = "rbxassetid://139793994385832",
		xp240 = "rbxassetid://80595016235700",
		gunxp30 = "rbxassetid://120706164038867",
		gunxp120 = "rbxassetid://83327781334602",
		gunxp240 = "rbxassetid://134607784627640"
	},
	crate = {
		rifle = {
			[1] = "rbxassetid://123558714864300",
			[3] = "rbxassetid://127600561631408",
			[8] = "rbxassetid://128349775048252"
		},
		smg = {
			[1] = "rbxassetid://128796581946205",
			[3] = "rbxassetid://117482574428509",
			[8] = "rbxassetid://94097973838413"
		},
		lmg = {
			[1] = "rbxassetid://112131133240551",
			[3] = "rbxassetid://138054309065648",
			[8] = "rbxassetid://129782927103132"
		},
		sniper = {
			[1] = "rbxassetid://86088669427927",
			[3] = "rbxassetid://107918351863846",
			[8] = "rbxassetid://75711218340093"
		},
		dmr = {
			[1] = "rbxassetid://104097903505924",
			[3] = "rbxassetid://94329611306122",
			[8] = "rbxassetid://102561461189756"
		},
		pistol = {
			[1] = "rbxassetid://117580497869652",
			[3] = "rbxassetid://98954119266424",
			[8] = "rbxassetid://84896777048309"
		},
		shotgun = {
			[1] = "rbxassetid://109231361166263",
			[3] = "rbxassetid://131893111141576",
			[8] = "rbxassetid://128319978602971"
		}
	}
}

local v4 = {
	{
		id = "packAll",
		kind = "weaponPack",
		name = "EVERY GUN",
		productId = 0,
		robux = 899,
		tier = "gold",
		items = {
			"K433",
			"GX36",
			"SK556",
			"RN545",
			"MX65",
			"BT762",
			"KP50",
			"HM45",
			"GV12",
			"FS16",
			"BX110",
			"HX83",
			"MG60",
			"RX10",
			"SC11",
			"HandCannon",
			"SV20",
			"ZK10",
			"Molotov",
			"Flamethrower"
		},
		show = { "BT762", "MG60", "RX10" },
		lines = { "20 WEAPONS", "ALL RIFLES", "ALL SNIPERS", "ALL LMGS" }
	},
	{
		id = "packRifles",
		kind = "weaponPack",
		name = "RIFLE PACK",
		productId = 0,
		robux = 349,
		tier = "purple",
		items = { "K433", "GX36", "SK556", "RN545", "MX65", "BT762" },
		show = { "MX65", "RN545", "BT762" },
		lines = { "6 RIFLES" }
	},
	{
		id = "packSnipers",
		kind = "weaponPack",
		name = "SNIPER PACK",
		productId = 0,
		robux = 299,
		tier = "blue",
		items = { "RX10", "SC11", "GV12", "FS16" },
		show = { "RX10", "GV12", "SC11" },
		lines = { "2 SNIPERS", "2 DMRS" }
	},
	{
		id = "packHeavy",
		kind = "weaponPack",
		name = "HEAVY PACK",
		productId = 0,
		robux = 249,
		tier = "blue",
		items = { "BX110", "HX83", "MG60", "Flamethrower" },
		show = { "MG60", "Flamethrower", "BX110" },
		lines = { "3 LMGS", "FLAMETHROWER" }
	}
}

local numberSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.5, 0),
	NumberSequenceKeypoint.new(1, 1)
})

local v5 = { boost = "brass", unlock = "viper", scrap = "ember" }

local function rgb(p: number, p2: number, p3: number) -- 52 equivalent calls inferred from this helper
	return Color3.fromRGB(p, p2, p3)
end

local v6 = {
	starter = {
		wall = rgb(230, 98, 26), -- inferred equivalent call
		glow = rgb(255, 150, 60), -- inferred equivalent call
		hot = rgb(255, 214, 150), -- inferred equivalent call
		deep = rgb(112, 30, 10) -- inferred equivalent call
	},
	free = {
		wall = rgb(20, 150, 150), -- inferred equivalent call
		glow = rgb(70, 210, 200), -- inferred equivalent call
		hot = rgb(190, 250, 240), -- inferred equivalent call
		deep = rgb(6, 58, 68) -- inferred equivalent call
	},
	tiers = {
		{
			wall = rgb(36, 122, 222), -- inferred equivalent call
			glow = rgb(90, 170, 255), -- inferred equivalent call
			hot = rgb(200, 230, 255), -- inferred equivalent call
			deep = rgb(14, 42, 116) -- inferred equivalent call
		},
		{
			wall = rgb(40, 170, 80), -- inferred equivalent call
			glow = rgb(96, 222, 120), -- inferred equivalent call
			hot = rgb(206, 255, 210), -- inferred equivalent call
			deep = rgb(10, 72, 40) -- inferred equivalent call
		},
		{
			wall = rgb(238, 152, 20), -- inferred equivalent call
			glow = rgb(255, 204, 70), -- inferred equivalent call
			hot = rgb(255, 238, 170), -- inferred equivalent call
			deep = rgb(136, 58, 6) -- inferred equivalent call
		}
	}
}

local v7 = {}

local function priceOf(p: number, callback) -- 12 equivalent calls inferred from this helper
	local v8 = v7[p]

	if v8 == nil then
		v7[p] = "?"
		task.spawn(function()
			local success, productInfoAsync = pcall(
				MarketplaceService.GetProductInfoAsync,
				MarketplaceService,
				p,
				Enum.InfoType.Product
			)

			if success and type(productInfoAsync) == "table" and type(productInfoAsync.PriceInRobux) == "number" then
				v7[p] = productInfoAsync.PriceInRobux
			else
				warn("[ArmoryStore] no price for developer product " .. p .. ": " .. tostring(productInfoAsync))
				v7[p] = nil
			end

			callback()
		end)
		return nil
	else
		return if type(v8) == "number" then v8 else nil
	end
end

local function toolOf(childName: string) -- 3 equivalent calls inferred from this helper
	local tool = ToolTemplates:FindFirstChild(childName)
	assert(tool and tool:IsA("Tool"), "[ArmoryStore] no tool " .. childName)
	return tool
end

local function softBar(p, color3: Color3, udim: UDim2, udim2: UDim2, backgroundTransparency: number) -- 4 equivalent calls inferred from this helper
	local fill = Style.fill(p, "Glow", color3, udim, udim2)
	fill.BackgroundTransparency = backgroundTransparency
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Transparency = numberSequence
	uiGradient.Parent = fill
	return fill
end

local function text(p, p2: string, p3: string, p4: number, p5: number, p6: number, p7: number, p8: number, options)
	local v8 = options or {}
	local label = Style.label(p, p2, p3, p4, v8.font or Style.FONT, v8.outline or 0)
	label.AutomaticSize = Enum.AutomaticSize.None
	label.Position = UDim2.fromOffset(p5, p6)
	label.Size = UDim2.fromOffset(p7, p8)
	label.TextXAlignment = v8.ax or Enum.TextXAlignment.Left
	label.TextYAlignment = v8.ay or Enum.TextYAlignment.Center
	label.TextColor3 = v8.color or Style.WHITE
	label.TextWrapped = v8.wrap == true
	label.RichText = v8.rich == true

	local uiStroke = label:FindFirstChildOfClass("UIStroke")

	if uiStroke then
		uiStroke.LineJoinMode = Enum.LineJoinMode.Round
	end

	return label
end

local function buySound() -- 10 equivalent calls inferred from this helper
	assert(MenuAudio.buy, "[ArmoryStore] MenuAudio is not mounted")()
end

local function springy(parent, flag: boolean?)
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = parent
	local uiStroke = parent:FindFirstChildOfClass("UIStroke")
	local color3 = uiStroke and uiStroke.Color
	local v8 = false
	local function rest() -- 1 equivalent call inferred from this helper
		if not v8 then
			return 1
		end

		local v9 = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y, 1)
		return (math.min((flag and 3 or 5) * 2 / v9 + 1, 1.08))
	end

	local function go(p: number, p2: number, callback) -- 3 equivalent calls inferred from this helper
		local scale = uiScale.Scale
		local now = os.clock()
		Style.animate(uiScale, function(_, p3: number): boolean
			local v9 = math.min((p3 - now) / p2, 1)
			uiScale.Scale = scale + (p - scale) * callback(v9)
			return v9 < 1
		end)
	end
	parent.InputBegan:Connect(function(input)
		local userInputType = input.UserInputType

		if userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.Touch then
			local easeOut = Style.easeOut
			local scale = uiScale.Scale
			local now = os.clock()
			local v9 = 0.07
			local v10 = 0.94
			Style.animate(uiScale, function(_, p: number): boolean
				local v11 = math.min((p - now) / v9, 1)
				uiScale.Scale = scale + (v10 - scale) * easeOut(v11)
				return v11 < 1
			end)
		elseif userInputType == Enum.UserInputType.MouseMovement then
			v8 = true
			local v9 = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y, 1)
			go(math.min((flag and 3 or 5) * 2 / v9 + 1, 1.08), 0.12, Style.easeOut) -- inferred equivalent call

			if uiStroke then
				uiStroke.Color = Style.WHITE
			end
		end
	end)

	parent.SelectionGained:Connect(function()
		v8 = true
		local v9 = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y, 1)
		go(math.min((flag and 3 or 5) * 2 / v9 + 1, 1.08), 0.12, Style.easeOut) -- inferred equivalent call

		if uiStroke then
			uiStroke.Color = Style.WHITE
		end
	end)
	parent.SelectionLost:Connect(function()
		v8 = false
		local easeOut = Style.easeOut
		local scale = uiScale.Scale
		local now = os.clock()
		local v9 = 0.12
		local v10 = 1
		Style.animate(uiScale, function(_, p: number): boolean
			local v11 = math.min((p - now) / v9, 1)
			uiScale.Scale = scale + (v10 - scale) * easeOut(v11)
			return v11 < 1
		end)

		if uiStroke and color3 then
			uiStroke.Color = color3
		end
	end)
	parent.InputEnded:Connect(function(input)
		local userInputType = input.UserInputType

		if userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.Touch then
			local v9 = rest() -- inferred equivalent call
			local v10 = if flag then Style.easeOut else Style.pop
			go(v9, 0.22, v10) -- inferred equivalent call
		elseif userInputType == Enum.UserInputType.MouseMovement then
			v8 = false
			local easeOut = Style.easeOut
			local scale = uiScale.Scale
			local now = os.clock()
			local v9 = 0.12
			local v10 = 1
			Style.animate(uiScale, function(_, p: number): boolean
				local v11 = math.min((p - now) / v9, 1)
				uiScale.Scale = scale + (v10 - scale) * easeOut(v11)
				return v11 < 1
			end)

			if uiStroke then
				uiStroke.Color = color3
			end
		end
	end)
end

function ArmoryStore.instant(p, p2: string, callback)
	local v8 = CareerData.unlockOf(p2)

	if not v8 then
		return nil
	end

	local v9 = priceOf(v8.productId, callback) -- inferred equivalent call
	return {
		price = v9 or v8.robux,
		run = function()
			buySound() -- inferred equivalent call
			UiTrack.send("instant_tap", v8.id)
			MarketplaceService:PromptProductPurchase(p, v8.productId)
		end
	}
end

function ArmoryStore.outfit(p, p2: string, callback)
	local v8 = nil

	for _, outfitBundle in CareerData.STORE.outfitBundles do
		if outfitBundle.skin == p2 then
			v8 = outfitBundle
		end
	end

	assert(v8, "[ArmoryStore] paid outfit " .. p2 .. " has no bundle")
	local v9 = priceOf(v8.productId, callback) -- inferred equivalent call
	return {
		price = v9 or v8.robux,
		label = "BUY BUNDLE",
		run = function()
			buySound() -- inferred equivalent call
			UiTrack.send("outfit_tap", v8.id)
			MarketplaceService:PromptProductPurchase(p, v8.productId)
		end
	}
end

function ArmoryStore.freeLeft(instance)
	local attribute = instance:GetAttribute(CareerData.FREE_ATTR)

	if type(attribute) == "number" then
		return (math.max(0, attribute - workspace:GetServerTimeNow()))
	end

	return 0
end

function ArmoryStore.freeBadge(p, p2)
	local box = Style.box(p, "FreeBadge", Style.HAZARD, UDim2.fromOffset(40, 20), 2, 1.5)
	box.AnchorPoint = Vector2.new(1, 0)
	box.Position = UDim2.new(1, 4, 0, -6)
	box.ZIndex = 3
	local text_2 = text(box, "Text", "FREE", 12, 0, 0, 40, 20, {
		color = Style.INK,
		ax = Enum.TextXAlignment.Center
	})
	text_2.ZIndex = 3
	local count = 0
	local function draw()
		count += 1
		local v8 = count
		local freeLeft = ArmoryStore.freeLeft(p2)
		box.Visible = freeLeft <= 0

		if freeLeft > 0 then
			task.delay(freeLeft + 0.1, function()
				if count == v8 then
					draw()
				end
			end)
		end
	end
	p2.AttributeChanged:Connect(function(p3: string)
		if p3 == CareerData.FREE_ATTR then
			count += 1
			local v8 = count
			local freeLeft = ArmoryStore.freeLeft(p2)
			box.Visible = freeLeft <= 0

			if freeLeft > 0 then
				task.delay(freeLeft + 0.1, function()
					if count == v8 then
						draw()
					end
				end)
			end
		end
	end)
	count += 1
	local v8 = count
	local freeLeft = ArmoryStore.freeLeft(p2)
	box.Visible = freeLeft <= 0

	if freeLeft > 0 then
		task.delay(freeLeft + 0.1, function()
			if count == v8 then
				draw()
			end
		end)
	end
end

function ArmoryStore:new(instance, data)
	local touch = data.touch == true
	local v8 = {}
	local v9 = false
	local v10 = false

	local offset = self.Size.X.Offset
	local offset2 = self.Size.Y.Offset

	local v11 = math.max(
		44,
		(math.floor((offset2 - (#StoreData.Sections - 1) * 8) / #StoreData.Sections * (touch and 1 or 0.6)))
	)
	local v12 = (touch and 128 or 170) + 8
	local v13 = offset - v12
	local v14 = touch and 1 or 1.3

	local function S(p: number) -- 1 equivalent call inferred from this helper
		return (math.floor(p * v14))
	end

	local v15 = v13 - 6 - 8
	local v16 = math.floor((v15 - 16) / 3)
	local v17 = touch and 236 or 330
	local v18 = math.floor(v14 * 18) + 10

	local v19 = offset2 - v18

	local v20 = 1
	local v21 = nil
	local v22 = 1
	local v23 = {}
	local v24 = {}
	local v25 = {}
	local v26 = {}
	local v27 = {}
	local fn
	local v28 = false

	local parent = nil
	local v29 = nil
	local v30 = nil
	local v31 = nil
	local v32 = nil
	local parent3 = nil
	local v35 = nil
	local v36 = nil
	local v37 = nil
	local v38 = nil
	local v39 = nil
	local v40 = nil
	local v41 = nil
	local v42 = nil
	local v43 = nil
	local currentCamera = nil

	local function chip(p, list: string, color3: Color3, ink: Color3, p2: number, p3: number)
		local v44 = math.floor(v14 * 12)

		local v45 = math.floor(#list * v44 * 0.58) + 12
		local v46 = v44 + 8
		local box = Style.box(p, "Chip", color3, UDim2.fromOffset(v45, v46), 2, 1.5)
		box.Position = UDim2.fromOffset(p2, p3)
		local v47 = text(box, "Text", list, v44, 0, 0, v45, v46, {
			color = ink,
			ax = Enum.TextXAlignment.Center
		})
		return p2 + v45 + 4, v47
	end

	local function tagRow(tags, item, p: number, p2: number) -- 1 equivalent call inferred from this helper
		if item.elite then
			p = chip(tags, "ELITE", Style.ORANGE, Style.INK, p, p2)
		end

		if item.new then
			chip(tags, "NEW", Style.HAZARD, Style.INK, p, p2)
		end
	end

	local function priceTag(p, price: number, p2: number, p3: number)
		local v44 = math.floor(v14 * 16)

		local thousands = Style.thousands(price)
		local v45 = math.floor(#thousands * v44 * 0.55) + v44 + 22
		local v46 = v44 + 12
		local frame = Style.frame(p, "Price", UDim2.fromOffset(v45, v46), UDim2.fromOffset(p2, p3))
		local _, v47 = Style.robuxLine(frame, "Line", v44)
		v47(nil, thousands, Style.HAZARD)
		return frame
	end

	local function plainButton(p, p2: string, p3: string, color3: Color3, p4: number, p5: number, color4: Color3?, p6: number?) -- 4 equivalent calls inferred from this helper
		local button = Style.button(p, p2, p3, color3, UDim2.fromOffset(p4, p5), color4, p6)
		button.AutoButtonColor = false
		springy(button)
		return button
	end

	local function dressViews()
		local v44

		if data.body then
			v44 = data.body()
		else
			v44 = SkinPreview.body(instance)
		end

		if not v44 then
			return
		end

		for _, v45 in v26 do
			if v45.done then
				continue
			end

			v45.done = true
			v45.view.show(SkinPreview.dress(v44, Skins.get(v45.skin), "Reds", instance.UserId))
		end
	end

	local function release(p: string)
		for i = #v26, 1, -1 do
			if v26[i].group ~= p then
				continue
			end

			v26[i].view.destroy()
			table.remove(v26, i)
		end
	end

	local function soldierView(p, skin: string, p2: string, group: string?)
		assert(Skins.get(skin), "[ArmoryStore] no outfit " .. skin)
		local view = SkinPreview.view(p, p2)
		table.insert(v26, { view = view, skin = skin, done = false, group = group })
		return view
	end

	local function picture(p, childName: string) -- 6 equivalent calls inferred from this helper
		local tool = toolOf(childName) -- inferred equivalent call

		if ToolIcon.hasImage(childName) then
			ToolIcon.voxelImage(tool, p)
		else
			ToolIcon.voxel(tool, p)
		end
	end

	local function plateArt(kind: string, frame, theme)
		local function at(p: string, color3: Color3, p2: number, p3: number, p4: number, p5: number)
			return Style.fill(frame, p, color3, UDim2.fromScale(p2, p3), UDim2.fromScale(p4, p5), Vector2.new(0.5, 0.5))
		end

		if kind == "charm" then
			at("Cord", Style.MUTED, 0.015, 0.38, 0.5, 0.26)
			local v44 = at("Body", theme.glow, 0.26, 0.26, 0.5, 0.56)
			v44.Rotation = 45
			Style.corner(v44, 3)
			Style.stroke(v44, 2, 0, theme.hot, true)
			local at_2 = at("Core", theme.deep, 0.1, 0.1, 0.5, 0.56)
			at_2.Rotation = 45
		else
			local v44 = at("Hull", theme.wall, 0.8, 0.2, 0.5, 0.6)
			Style.corner(v44, 3)
			Style.stroke(v44, 2, 0, theme.glow, true)
			at("Tracks", Style.INK, 0.86, 0.09, 0.5, 0.73)
			local v45 = at("Turret", theme.wall, 0.34, 0.15, 0.47, 0.43)
			Style.corner(v45, 3)
			Style.stroke(v45, 2, 0, theme.glow, true)
			at("Barrel", theme.glow, 0.38, 0.03, 0.8, 0.42)
		end
	end

	local function heroArt(frame, p, p2: number, p3: number, group: string?)
		local skins = p.hero.skins or {}
		local tools = p.hero.tools or {}
		local v44

		if #skins > 1 then
			v44 = p2 * 0.62
		else
			v44 = p2
		end

		local v45 = math.floor((math.min(p3, v44)))
		local v46 = not (#skins > 1) and 0 or (p2 - v45) / (#skins - 1)

		for k, skin in skins do
			local v47

			if #skins > 1 then
				v47 = (k - 1) * v46
			else
				v47 = (p2 - v45) / 2
			end

			soldierView(
				Style.frame(frame, "Soldier", UDim2.fromOffset(v45, v45), UDim2.fromOffset(v47, p3 - v45)),
				skin,
				"full",
				group
			)
		end

		local count = #tools

		for k, tool in tools do
			local v47 = p3 / math.max(count, 2)
			local v48

			if #skins > 0 then
				v48 = p3 - v47
			else
				v48 = (k - 1) * v47 + (p3 - v47 * count) / 2
			end

			picture(Style.frame(frame, "Gun", UDim2.fromOffset(p2 - 12, v47), UDim2.fromOffset(6, v48)), tool) -- inferred equivalent call
		end
	end

	local function makeRoom(p, p2: number, p3: number, p4: number, p5: number)
		local box = Style.box(p, "Room", Style.INK, UDim2.fromOffset(p2, p3), 3, 2)
		box.Position = UDim2.fromOffset(p4, p5)
		box.ClipsDescendants = true
		local fill = Style.fill(box, "Wall", Style.INK, UDim2.fromScale(1, 1))
		local uiGradient = Instance.new("UIGradient")
		uiGradient.Rotation = 20
		uiGradient.Transparency = NumberSequence.new(0.5, 0)
		uiGradient.Parent = fill
		local v44 = {}

		for k, v45 in {
			{ 0.66, 0.34, p3 * 0.9 },
			{ 0.92, 0.6, p3 * 0.55 },
			{ 0.5, 0.1, p3 * 0.3 }
		} do
			local frame = Style.frame(
				fill,
				"Motif",
				UDim2.fromOffset(v45[3], v45[3]),
				UDim2.fromScale(v45[1], v45[2]),
				Vector2.new(0.5, 0.5)
			)
			frame.Rotation = 45
			v44[k] = Style.stroke(frame, 3, 0.55, Style.WHITE, true)
		end

		local parent2 = softBar(fill, Style.WHITE, UDim2.fromScale(0.7, 0.1), UDim2.fromScale(0.3, 0.3), 0.15) -- inferred equivalent call
		local parent4 = softBar(fill, Style.WHITE, UDim2.fromScale(0.5, 0.05), UDim2.fromScale(0.45, 0.12), 0.4) -- inferred equivalent call
		local v47 = { parent2, parent4 }

		local fill2 = Style.fill(box, "Floor", Style.INK, UDim2.fromScale(1, 0.3), UDim2.fromScale(0, 0.7))
		local uiGradient2 = Instance.new("UIGradient")
		uiGradient2.Rotation = 90
		uiGradient2.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.1),
			NumberSequenceKeypoint.new(0.12, 0.5),
			NumberSequenceKeypoint.new(1, 0.05)
		})
		uiGradient2.Parent = fill2
		local parent5 = softBar(fill2, Style.WHITE, UDim2.fromScale(0.6, 0.5), UDim2.fromScale(0.3, 0.2), 0.55) -- inferred equivalent call
		local frame = Style.frame(box, "Art", UDim2.fromScale(1, 1))
		local fill3 = Style.fill(box, "Dip", Style.INK, UDim2.fromScale(1, 1))
		fill3.BackgroundTransparency = 1
		local room = {
			plate = box,
			art = frame,
			above = Style.frame(box, "Above", UDim2.fromScale(1, 1))
		}
		function room.paint(data2)
			fill.BackgroundColor3 = data2.wall

			for _, v49 in v44 do
				v49.Color = data2.glow
			end

			v47[1].BackgroundColor3 = data2.hot
			v47[2].BackgroundColor3 = data2.glow
			parent5.BackgroundColor3 = data2.hot
		end
		function room.dip()
			if data.still then
				return
			end

			fill3.BackgroundTransparency = 0
			local now = os.clock()
			Style.animate(fill3, function(_, p6: number): boolean
				local v49 = math.min((p6 - now) / 0.32, 1)
				fill3.BackgroundTransparency = Style.smooth(v49)
				return v49 < 1
			end)
		end
		return room
	end

	local function enter(instance2, p: number, flag: boolean?)
		if data.still then
			return
		end

		local rest = instance2:GetAttribute("Rest") or instance2.Position
		instance2:SetAttribute("Rest", rest)
		local udim

		if flag then
			udim = UDim2.fromOffset(0, 26)
		else
			udim = UDim2.fromOffset(26, 0)
		end

		instance2.Position = rest + udim
		local v44 = os.clock() + p
		Style.animate(instance2, function(_, p2: number): boolean
			local v45 = math.clamp((p2 - v44) / 0.2, 0, 1)
			instance2.Position = rest + UDim2.new(
				0,
				udim.X.Offset * (1 - Style.easeOut(v45)),
				0,
				udim.Y.Offset * (1 - Style.easeOut(v45))
			)
			return v45 < 1
		end)
	end

	local fn2

	local scroll = nil

	local function scrollY() -- 4 equivalent calls inferred from this helper
		return scroll.CanvasPosition.Y * offset2 / scroll.AbsoluteSize.Y
	end

	local function setScrollY(p: number) -- 2 equivalent calls inferred from this helper
		scroll.CanvasPosition = Vector2.new(0, p * scroll.AbsoluteSize.Y / offset2)
	end

	local fn3
	local v44 = {}

	local function cardPlate(parent2, name: string, data2, flag: boolean, p: number, p2: number, p3: number, p4: number, flag2: boolean?)
		local textButton = Instance.new("TextButton")
		textButton.Name = name
		textButton.Text = ""
		textButton.AutoButtonColor = false
		textButton.BorderSizePixel = 0
		textButton.BackgroundColor3 = Style.WHITE
		textButton.Size = UDim2.fromOffset(p3, p4)
		textButton.Position = UDim2.fromOffset(p, p2)
		textButton.ClipsDescendants = true
		textButton.Parent = parent2
		Style.corner(textButton, flag2 and 8 or 3)
		local uiGradient = Instance.new("UIGradient")
		uiGradient.Rotation = flag2 and 90 or 65
		uiGradient.Color = ColorSequence.new(data2.wall, data2.deep)
		uiGradient.Parent = textButton

		if flag2 then
			Style.stroke(textButton, 3, 0, Style.INK, true)
		else
			local stroke = Style.stroke
			local v47 = if flag then Style.ORANGE else Style.INK
			stroke(textButton, flag and 3 or 2, 0, v47, true)
			local frame = Style.frame(
				textButton,
				"Motif",
				UDim2.fromOffset(p3 * 0.8, p3 * 0.8),
				UDim2.fromScale(0.72, 0.56),
				Vector2.new(0.5, 0.5)
			)
			frame.Rotation = 45
			Style.stroke(frame, 3, 0.68, data2.glow, true)
			softBar(textButton, data2.glow, UDim2.new(1, 0, 0, p4 * 0.09), UDim2.fromScale(0.1, 0.36), 0.45) -- inferred equivalent call
		end

		springy(textButton, true)
		return textButton
	end

	local function card(p, data2, p2: number, p3: number, p4: number, p5: number)
		local v45 = cardPlate(p, data2.id, StoreData.Themes[data2.theme], data2.elite == true, p2, p3, p4, p5)
		local v46 = touch and 8 or 12
		local v47 = math.floor(v14 * 22)
		local v48 = math.floor(v14 * 12) + 14 + v47 + 8
		local v49 = p5 - v48 - (math.floor(v14 * 16) + 30)
		heroArt(Style.frame(v45, "Art", UDim2.fromOffset(p4, v49), UDim2.fromOffset(0, v48)), data2, p4, v49)
		local v50

		if data2.elite then
			v50 = chip(v45, "ELITE", Style.ORANGE, Style.INK, v46, 8)
		else
			v50 = v46
		end

		if data2.new then
			chip(v45, "NEW", Style.HAZARD, Style.INK, v50, 8)
		end

		text(v45, "Title", data2.title, v47, v46, math.floor(v14 * 12) + 12, p4 - v46 * 2, v47 + 6, {
			outline = 1.5
		})
		priceTag(v45, data2.price, v46, p5 - (math.floor(v14 * 16) + 12) - v46)

		if data2.elite then
			Style.tape(v45, "Tape", UDim2.new(1, 0, 0, 5), p4, 10)
		end

		v45.Activated:Connect(function()
			fn2(data2)
		end)
		return v45
	end

	local function redrawProducts() -- 3 equivalent calls inferred from this helper
		for _, v45 in v27 do
			v45()
		end
	end

	local function giftTap(p: string?)
		UiTrack.send("gift_tap", p)
		local v45

		if p then
			v45 = CareerData.byId(p)
		end

		local giftPicker = script.Parent:FindFirstChild("GiftPicker")

		if not (v45 and CareerData.giftOf(v45.id) and giftPicker) then
			fn3("GIFTS COMING SOON")
			return
		end

		local module = require(giftPicker)
		local item = v45.item
		local open = module.open
		local v46 = {
			touch = touch,
			price = 0,
			say = 0,
			sound = 0,
			picture = 0
		}

		local function fn4() end
		v46.price = priceOf(CareerData.giftOf(v45.id), fn4) or v45.robux -- inferred equivalent call
		v46.say = fn3
		v46.sound = buySound
		v46.picture = v45.kind == "unlock" and not v45.image and item and function(p2)
			picture(p2, item) -- inferred equivalent call
		end or nil
		open(self, instance, v45, v46)
	end

	local function buyPlate(parent2, total: number, total2: number, p: number, p2: number, value)
		local function piece(name: string, image: string, total3: number, p3: number)
			local imageButton = Instance.new("ImageButton")
			imageButton.Name = name
			imageButton.BackgroundTransparency = 1
			imageButton.AutoButtonColor = false
			imageButton.Image = image
			imageButton.AnchorPoint = Vector2.new(0.5, 0.5)
			imageButton.Size = UDim2.fromOffset(p3, p2)
			imageButton.Position = UDim2.fromOffset(total3 + p3 / 2, total2 + p2 / 2)
			imageButton.ZIndex = 2
			imageButton.Selectable = false
			imageButton.Parent = parent2
			springy(imageButton)
			return imageButton
		end

		local v45 = math.floor(p / ((value and 99 / 112 or 0) + 5))

		if v45 < p2 then
			local v46 = math.floor(v45 * 5) + (not value and 0 or math.floor(v45 * 1.25) - math.floor(v45 * (41 / 112)))
			total += p - v46
			total2 += p2 - v45
			p2 = v45
			p = v46
		end

		if value then
			local v46 = math.floor(p2 * 1.25)
			local v47 = piece("Gift", v3.gift, total, v46)
			v47.ZIndex = 3
			v47.Activated:Connect(function()
				local v48

				if type(value) == "string" then
					v48 = value
				end

				giftTap(v48)
			end)
			local v48 = v46 - math.floor(p2 * (41 / 112))
			total += v48
			p -= v48
		end

		return piece("Buy", v3.buy, total, p)
	end

	local function buyCard(parent2, name: string, p, image: string, p2: string, p3: string, p4: number, p5: number, p6: number, options)
		local v45 = options or {}
		local h = v45.h or v17
		local parent4 = cardPlate(parent2, name, p, v45.elite == true, p4, p5, p6, h, v45.sale)
		local v47 = touch and 8 or 12
		local v48 = (v45.nameLines or 2) * (math.floor(v14 * 16) + 2)
		local v49 = (v45.blurbLines or 3) * (math.floor(v14 * 13) + 3)
		local v50 = h - 44 - v47
		local v51 = v50 - v49 - 4
		local v52

		if v45.bare then
			v52 = v50 - (v45.room or 0) - 4
		else
			v52 = v51 - v48 - 2
		end

		local art = Instance.new("ImageLabel")
		art.Name = "Art"
		art.BackgroundTransparency = 1
		art.Image = image
		art.ScaleType = Enum.ScaleType.Fit
		art.Size = UDim2.fromOffset(p6 - v47 * 2, v52 - v47)
		art.Position = UDim2.fromOffset(v47, v47)
		art.Parent = parent4

		if not v45.bare then
			text(parent4, "Name", p2, math.floor(v14 * 16), v47, v52, p6 - v47 * 2, v48, {
				outline = 1.5,
				wrap = true,
				ay = Enum.TextYAlignment.Bottom
			})
			text(parent4, "Blurb", p3, math.floor(v14 * 13), v47, v51, p6 - v47 * 2, v49, {
				font = Style.FONT_BODY,
				wrap = true,
				ay = Enum.TextYAlignment.Top,
				outline = 1
			})
		end

		local v53 = buyPlate(parent4, v47, v50, p6 - v47 * 2, 44, v45.gift == true)
		return
			parent4,
			v53,
			text(v53, "Amount", "", math.floor(v14 * 18), 0, 0, v53.Size.X.Offset, 44, {
				color = Style.INK,
				ax = Enum.TextXAlignment.Center
			})
	end

	local function productCard(parent2, data2, p: number, p2: number, p3: number, p4)
		assert(data2.image, "[ArmoryStore] no picture for " .. data2.id)
		local look = p4 and p4.look or StoreData.Themes[v5[data2.kind]]
		local v45, v46, v47 = buyCard(parent2, data2.id, look, data2.image, data2.name, data2.blurb, p, p2, p3, p4)
		local function owned() -- 2 equivalent calls inferred from this helper
			return data2.kind == "unlock" and ShopData.owns(instance, data2.item)
		end

		local robuxLine, v48 = Style.robuxLine(v46, "Line", (math.floor(v14 * 18)))
		table.insert(v27, function()
			local v49 = owned() -- inferred equivalent call
			local v50 = data2.productId ~= 0
			local v51

			if v50 then
				v51 = priceOf(data2.productId, redrawProducts) or data2.robux -- inferred equivalent call
			end

			local image

			if v50 and not v49 then
				image = v3.buy
			else
				image = v3.buyOff
			end

			v46.Image = image
			local textColor

			if v49 then
				textColor = Style.GOOD
			else
				textColor = if v50 then Style.INK else Style.MUTED
			end

			v47.TextColor3 = textColor
			v47.Text = v49 and "OWNED" or v50 and "" or "NOT ON SALE"
			robuxLine.Visible = v50 and not v49
			v48(nil, not v51 and "..." or Style.thousands(v51), Style.INK)
		end)
		v45.Activated:Connect(function()
			UiTrack.send("store_tap", data2.id)

			if data2.productId == 0 then
				fn3("NOT ON SALE YET")
				return
			end

			if owned() then -- inferred equivalent call
				fn3("ALREADY OWNED")
				return
			end

			buySound() -- inferred equivalent call
			MarketplaceService:PromptProductPurchase(instance, data2.productId)
		end)
		return v45
	end

	local function clock(freeLeft: number) -- 4 equivalent calls inferred from this helper
		local v45 = math.ceil(freeLeft)
		return string.format("%d:%02d", v45 // 60, v45 % 60)
	end

	local function freeCard(parent2, p: number, p2: number)
		local free = CareerData.FREE
		local v45 = "+" .. Style.thousands(free.scrap) .. " SCRAP"
		local v46, v47, v48 = buyCard(
			parent2,
			"FreeScrap",
			v6.free,
			CareerData.STORE.scrap[1].image,
			"FREE SCRAP",
			v45,
			p,
			p2,
			v16,
			{ sale = true, blurbLines = 1, nameLines = 1 }
		)
		Style.tape(v46, "Tape", UDim2.new(1, 0, 0, 5), v16, 10)
		fn = function()
			local freeLeft = ArmoryStore.freeLeft(instance)
			local v49 = freeLeft <= 0
			local image = if v49 then v3.claim else v3.buyOff
			v47.Image = image
			local textColor = if v49 then Style.INK else Style.MUTED
			v48.TextColor3 = textColor
			local text2

			if v49 then
				text2 = "CLAIM"
			else
				text2 = "NEXT IN " .. clock(freeLeft) -- inferred equivalent call
			end

			v48.Text = text2
		end
		fn()
		v46.Activated:Connect(function()
			local freeLeft = ArmoryStore.freeLeft(instance)

			if freeLeft > 0 then
				fn3("NEXT FREE SCRAP IN " .. clock(freeLeft)) -- inferred equivalent call
			elseif not v28 then
				v28 = true
				local career = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Remotes"):WaitForChild("Career")
				local success, result, v49 = pcall(career.InvokeServer, career, "free")
				v28 = false

				if success and result == true then
					assert(ArmoryStore.reveal, "[ArmoryStore] LobbyMenus has not set the reveal")(free.scrap)
				else
					warn("[ArmoryStore] free claim: " .. tostring(result) .. " " .. tostring(v49))
					fn3((not success or type(v49) ~= "string") and "NO ANSWER, TRY AGAIN" or string.upper(v49))
				end
			end
		end)
		return v46
	end

	local function runFree() -- 2 equivalent calls inferred from this helper
		if data.still then
			return
		end

		local v45 = 0
		Style.animate(v44, function(_, p: number): boolean
			if not v10 or v21 then
				return false
			end

			if v45 <= p then
				v45 = p + 1
				fn()
			end

			return true
		end)
	end

	local function slot(p: number) -- 2 equivalent calls inferred from this helper
		return (p - 1) % 3 * (v16 + 8) + 4, v18 + (p - 1) // 3 * (v17 + 8)
	end

	local function bundlesOf(p)
		local result = {}

		for _, row in p.rows do
			for _, v45 in row do
				table.insert(result, StoreData.byId[v45])
			end
		end

		return result
	end

	local function sectionHeight(section) -- 1 equivalent call inferred from this helper
		if section.spotlight then
			return v18 + v19
		end

		local v45

		if section.products then
			v45 = #CareerData.STORE[section.products]
		else
			v45 = #bundlesOf(section) + (section.free and 1 or 0)
		end

		return v18 + math.ceil(v45 / 3) * (v17 + 8) - 8
	end

	local function productPage(frame, section)
		local result = {}

		for k, v45 in CareerData.STORE[section.products] do
			local v46, v47 = slot(k) -- inferred equivalent call
			table.insert(result, productCard(frame, v45, v46, v47, v16))
		end

		redrawProducts() -- inferred equivalent call
		return result
	end

	local function bundlePage(frame, section)
		local result = {}

		if section.free then
			local v45 = (v16 + 8) * 0 + 4
			local v46 = v18 + (v17 + 8) * 0

			table.insert(result, freeCard(frame, v45, v46))
		end

		for _, v45 in bundlesOf(section) do
			local v46, v47 = slot(#result + 1) -- inferred equivalent call
			table.insert(result, card(frame, v45, v46, v47, v16, v17))
		end

		return result
	end

	local v45 = { index = 1, fills = {}, list = {}, t0 = 0 }

	local function showSpot(p: number)
		v45.index = p
		v45.t0 = os.clock()
		local item = v45.list[p]
		v45.room.paint(StoreData.Themes[item.theme])
		release("spot")
		v45.room.art:ClearAllChildren()
		local v46 = math.floor(v15 * 0.58)
		heroArt(
			Style.frame(v45.room.art, "Hero", UDim2.fromOffset(v46, v19), UDim2.fromOffset(v15 - v46, 0)),
			item,
			v46,
			v19,
			"spot"
		)
		dressViews()
		v45.tags:ClearAllChildren()
		tagRow(v45.tags, item, 0, 0) -- inferred equivalent call
		v45.title.Text = item.title
		v45.blurb.Text = item.blurb
		v45.price:ClearAllChildren()
		priceTag(v45.price, item.price, 0, 0)

		for k, fill in v45.fills do
			fill.Size = UDim2.fromScale(k < p and 1 or 0, 1)
		end

		v45.room.dip()
	end

	local function spotPage(frame, section)
		for _, v46 in section.spotlight do
			table.insert(v45.list, StoreData.byId[v46])
		end

		local room = makeRoom(frame, v15, v19, 4, v18)
		v45.room = room
		local above = room.above

		local v46 = math.floor(v15 * 0.5)
		local v47 = 12
		v45.tags = Style.frame(
			above,
			"Tags",
			UDim2.fromOffset(v46, math.floor(v14 * 12) + 8),
			UDim2.fromOffset(14, v47)
		)
		local v48 = v47 + (math.floor(v14 * 12) + 10)
		v45.title = text(above, "Title", "", math.floor(v14 * 34), 14, v48, v46 + 40, math.floor(v14 * 34) + 8, {
			outline = 2
		})
		local v49 = v48 + (math.floor(v14 * 34) + 10)
		v45.price = Style.frame(
			above,
			"Price",
			UDim2.fromOffset(v46, math.floor(v14 * 16) + 12),
			UDim2.fromOffset(14, v49)
		)
		local v50 = v49 + (math.floor(v14 * 16) + 18)
		v45.blurb = text(above, "Blurb", "", math.floor(v14 * 14), 14, v50, v46, math.floor(v14 * 14) * 2 + 10, {
			font = Style.FONT_BODY,
			wrap = true,
			ay = Enum.TextYAlignment.Top,
			outline = 1
		})
		local v51 = v19 - 8 - 44
		local frame2 = Style.frame(
			above,
			"Dots",
			UDim2.fromOffset(#v45.list * 52, 44),
			UDim2.fromOffset(10, v51 - 44 - 2)
		)
		local button = plainButton(above, "View", "VIEW", Style.HAZARD, 146, 44, Style.INK, 18) -- inferred equivalent call
		button.Position = UDim2.fromOffset(14, v51)
		button.Activated:Connect(function()
			fn2(v45.list[v45.index])
		end)

		for k in v45.list do
			local dot = Instance.new("TextButton")
			dot.Name = "Dot"
			dot.Text = ""
			dot.BackgroundTransparency = 1
			dot.AutoButtonColor = false
			dot.Size = UDim2.fromOffset(52, 44)
			dot.Position = UDim2.fromOffset((k - 1) * 52, 0)
			dot.Parent = frame2
			local fill = Style.fill(dot, "Track", color2, UDim2.new(1, -8, 0, 6), UDim2.new(0, 4, 0.5, -3))
			Style.stroke(fill, 1, 0, Style.INK, true)
			v45.fills[k] = Style.fill(fill, "Fill", Style.HAZARD, UDim2.fromScale(0, 1))
			dot.Activated:Connect(function()
				showSpot(k)
			end)
		end

		return button
	end

	local function runSpot() -- 2 equivalent calls inferred from this helper
		if data.still then
			return
		end

		v45.t0 = os.clock()
		local v46 = 0
		Style.animate(v45, function(_, t0: number): boolean
			if not v10 or v21 then
				return false
			end

			if t0 < v46 then
				return true
			end

			v46 = t0 + 0.1
			local v47 = scrollY() -- inferred equivalent call
			local top = v45.top

			if v47 + offset2 < top or v45.top + v45.height < v47 then
				v45.t0 = t0
				return true
			end

			local v48 = (t0 - v45.t0) / 7

			if v48 >= 1 then
				showSpot(v45.index % #v45.list + 1)
			else
				v45.fills[v45.index].Size = UDim2.fromScale(v48, 1)
			end

			return true
		end)
	end

	local function moveRailTape(p: number)
		local v46 = (p - 1) * (v11 + 8) + v11 - 5

		if data.still then
			v30.Position = UDim2.fromOffset(0, v46)
			return
		end

		local offset3 = v30.Position.Y.Offset
		local now = os.clock()
		Style.animate(v30, function(_, p2: number): boolean
			local v47 = math.min((p2 - now) / 0.16, 1)
			v30.Position = UDim2.fromOffset(0, offset3 + (v46 - offset3) * Style.easeOut(v47))
			return v47 < 1
		end)
	end

	local function markRail(p: number)
		v20 = p

		for k, v46 in v24 do
			local v47 = k == p
			local button = v46.button
			local backgroundColor = if v47 then color else Style.PANEL
			button.BackgroundColor3 = backgroundColor
			local label = v46.label
			local textColor = if v47 then Style.WHITE else Style.MUTED
			label.TextColor3 = textColor
		end

		moveRailTape(p)
	end

	local function fill(k: number)
		local v46 = v23[k]

		if v46.built then
			return
		end

		v46.built = true
		local section = StoreData.Sections[k]

		if section.spotlight then
			local top = v46.top
			local height = v46.height
			v45.top = top
			v45.height = height
			v46.first = spotPage(v46.frame, section)
			showSpot(v45.index)
			runSpot() -- inferred equivalent call
		else
			local cards

			if section.products then
				cards = productPage(v46.frame, section)
			else
				cards = bundlePage(v46.frame, section)
			end

			v46.cards = cards

			if section.free then
				runFree() -- inferred equivalent call
			end
		end

		dressViews()

		for k2, card2 in v46.cards do
			enter(card2, ((k2 - 1) % 3 + (k2 - 1) // 3) * 0.04, true)
		end
	end

	local flag = false

	local function follow()
		local v46 = scrollY() -- inferred equivalent call

		for k, v47 in v23 do
			if v47.built or not (v47.top < v46 + 1.5 * offset2) then
				continue
			end

			local v48 = v47.top + v47.height

			if v46 - 0.5 * offset2 < v48 then
				fill(k)
			end
		end

		if flag then
			return
		end

		local v47 = 1

		for k, v48 in v23 do
			if v48.top <= v46 + 0.4 * offset2 then
				v47 = k
			end
		end

		if v47 ~= v20 then
			markRail(v47)
		end
	end

	local function buildHome()
		scroll = Instance.new("ScrollingFrame")
		scroll.Name = "Scroll"
		scroll.BackgroundTransparency = 1
		scroll.BorderSizePixel = 0
		scroll.ScrollBarThickness = 6
		scroll.ScrollBarImageColor3 = Style.HAZARD
		scroll.ScrollingDirection = Enum.ScrollingDirection.Y
		scroll.Size = UDim2.fromOffset(v13, offset2)
		scroll.Position = UDim2.fromOffset(v12, 0)
		scroll.Parent = parent
		local total = 0

		for k, section in StoreData.Sections do
			local height = sectionHeight(section) -- inferred equivalent call
			local frame = Style.frame(scroll, section.id, UDim2.fromOffset(v13 - 6, height), UDim2.fromOffset(0, total))
			text(frame, "Heading", section.title, math.floor(v14 * 18), 4, 0, v15, v18, {
				color = Style.MUTED
			})
			v23[k] = {
				frame = frame,
				top = total,
				height = height,
				built = false,
				cards = {}
			}
			total += height + 16
		end

		local v46 = v23[#v23]
		scroll.CanvasSize = UDim2.fromOffset(0, v46.top + math.max(v46.height, offset2))
		scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(follow)
		follow()
	end

	local function startTimers() -- 3 equivalent calls inferred from this helper
		if v45.room then
			runSpot() -- inferred equivalent call
		end

		if fn then
			runFree() -- inferred equivalent call
		end
	end

	local function clearStage() -- 3 equivalent calls inferred from this helper
		release("stage")
		currentCamera = nil
		v31:ClearAllChildren()
	end

	local function rockGun()
		if touch or data.still or not currentCamera then
			return
		end

		local v46 = currentCamera
		local model = v46.Parent:FindFirstChildOfClass("Model")
		local position = model and model:GetBoundingBox().Position or Vector3.new(0, 0, 0)
		local v47 = v46.CFrame.Position - position
		local now = os.clock()
		Style.animate(v31, function(_, p: number): boolean
			if currentCamera ~= v46 then
				return false
			end

			local v48 = math.sin((p - now) * 0.5) * 0.35
			v46.CFrame = CFrame.lookAt(position + CFrame.Angles(0, v48, 0):VectorToWorldSpace(v47), position)
			return true
		end)
	end

	local function moveMark(p: number)
		local v46 = (p - 1) * (v25.pitch or 0)

		if data.still then
			v35.Position = UDim2.new(0, v46, 1, -5)
			return
		end

		local offset3 = v35.Position.X.Offset
		local now = os.clock()
		Style.animate(v35, function(_, p2: number): boolean
			local v47 = math.min((p2 - now) / 0.16, 1)
			v35.Position = UDim2.new(0, offset3 + (v46 - offset3) * Style.easeOut(v47), 1, -5)
			return v47 < 1
		end)
	end

	local function showItem(p: number)
		v22 = p
		local v46 = v21
		local item = v46.items[p]
		local theme = StoreData.Themes[v46.theme]
		clearStage() -- inferred equivalent call

		if item.kind == "soldier" then
			soldierView(v31, item.skin, "full", "stage")
			dressViews()
		elseif item.tool then
			local v47 = ToolIcon.make(toolOf(item.tool), v31) -- inferred equivalent call
			v47.Size = UDim2.fromScale(1, 1)
			currentCamera = v47.CurrentCamera
			rockGun()
		else
			local frame = Style.frame(
				v31,
				"Plate",
				UDim2.fromOffset(v31.Size.Y.Offset, v31.Size.Y.Offset),
				UDim2.fromScale(0.5, 0),
				Vector2.new(0.5, 0)
			)
			plateArt(item.kind, frame, theme)
		end

		v39.Text = item.label .. (item.reactive and "  /  REACTIVE" or "")
		v38.Text = item.name
		v40.Text = item.about
		v36:ClearAllChildren()

		if item.parts then
			local total = 0

			for _, part in item.parts do
				local v47 = math.floor(v14 * 12)

				local v48 = math.floor(#part * v47 * 0.58) + 12
				local box = Style.box(v36, "Part", color2, UDim2.fromOffset(v48, v47 + 10), 2, 1.5)
				box.Position = UDim2.fromOffset(total, 0)
				text(box, "Text", part, v47, 0, 0, v48, v47 + 10, {
					ax = Enum.TextXAlignment.Center,
					color = theme.hot
				})
				total += v48 + 4
			end
		end

		moveMark(p)
		v32.dip()
	end

	local function buildTiles(data2)
		release("tiles")

		for _, v46 in v25 do
			if typeof(v46) == "table" then
				v46.button:Destroy()
			end
		end

		table.clear(v25)
		local theme = StoreData.Themes[data2.theme]
		local count = #data2.items
		local v46 = math.floor((parent3.Size.X.Offset - (count - 1) * 6) / count)
		v25.pitch = v46 + 6
		v35.Size = UDim2.new(0, v46, 0, 5)
		v35.Position = UDim2.new(0, 0, 1, -5)

		for k, item in data2.items do
			local tile = Instance.new("TextButton")
			tile.Name = "Tile"
			tile.Text = ""
			tile.AutoButtonColor = false
			tile.BorderSizePixel = 0
			tile.BackgroundColor3 = color2
			tile.Size = UDim2.new(0, v46, 1, -7)
			tile.Position = UDim2.fromOffset((k - 1) * (v46 + 6), 0)
			tile.ClipsDescendants = true
			tile.Parent = parent3
			Style.corner(tile, 3)
			Style.stroke(tile, 2, 0, nil, true)
			local frame = Style.frame(tile, "Art", UDim2.new(1, -8, 1, -8), UDim2.fromOffset(4, 4))

			if item.kind == "soldier" then
				soldierView(frame, item.skin, "bust", "tiles")
			elseif item.tool then
				picture(frame, item.tool) -- inferred equivalent call
			else
				plateArt(item.kind, frame, theme)
			end

			springy(tile, true)
			tile.Activated:Connect(function()
				if k ~= v22 then
					showItem(k)
				end
			end)
			v25[k] = { button = tile }
		end
	end

	fn2 = function(data2)
		v21 = data2
		parent.Visible = false
		v29.Visible = true
		v32.paint(StoreData.Themes[data2.theme])
		v41.Text = data2.title
		v42:ClearAllChildren()
		local v46 = priceTag(v42, data2.price, 0, 0)
		local offset3 = v46.Size.X.Offset
		v42.Size = UDim2.fromOffset(offset3, v46.Size.Y.Offset)
		v42.Position = UDim2.fromOffset(v42.Parent.Size.X.Offset - offset3, v42.Position.Y.Offset)
		v43.Size = UDim2.fromOffset(v42.Parent.Size.X.Offset - offset3 - 8, 44)
		buildTiles(data2)
		dressViews()
		showItem(1)
		enter(v29, 0)

		if data.reseat then
			data.reseat()
		end
	end

	local function closeOffer() -- 1 equivalent call inferred from this helper
		v21 = nil
		clearStage() -- inferred equivalent call
		v29.Visible = false
		parent.Visible = true
		startTimers() -- inferred equivalent call

		if data.reseat then
			data.reseat()
		end
	end

	local v46 = 0

	fn3 = function(text2: string)
		assert(MenuAudio.deny, "[ArmoryStore] MenuAudio is not mounted")()
		v37.Text = text2
		v37.Visible = true
		v46 = os.clock()
		local v47 = v46
		task.delay(2.4, function()
			if v46 == v47 then
				v37.Visible = false
			end
		end)
	end

	local function buildOffer()
		v29 = Style.frame(self, "Offer", UDim2.fromScale(1, 1))
		v29.Visible = false
		local v47 = touch and 300 or 380
		local v48 = offset - v47 - 8
		v32 = makeRoom(v29, v48, offset2, 0, 0)
		v31 = Style.frame(v32.art, "Stage", UDim2.fromOffset(v48, offset2 - 12), UDim2.fromOffset(0, 8))
		v39 = text(v32.above, "Label", "", math.floor(v14 * 12), 12, 8, v48 - 24, math.floor(v14 * 12) + 6, {
			color = Style.MUTED,
			outline = 1
		})
		v38 = text(
			v32.above,
			"Name",
			"",
			math.floor(v14 * 24),
			12,
			offset2 - math.floor(v14 * 24) - 16,
			v48 - 24,
			math.floor(v14 * 24) + 8,
			{ outline = 2 }
		)

		local frame = Style.frame(v29, "Side", UDim2.fromOffset(v47, offset2), UDim2.fromOffset(v48 + 8, 0))
		plainButton(frame, "Back", "<", Style.PANEL, 44, 44, nil, 26).Activated:Connect(closeOffer) -- inferred equivalent call
		v41 = text(frame, "Bundle", "", math.floor(v14 * 20), 52, 0, v47 - 44 - 8, 44, {
			outline = 1.5
		})
		local v49 = 50
		local v50 = touch and 62 or 92
		parent3 = Style.frame(frame, "Tiles", UDim2.fromOffset(v47, v50), UDim2.fromOffset(0, v49))
		v35 = Style.tape(parent3, "Mark", UDim2.fromOffset(60, 5), v47, 10)
		v35.ZIndex = 2
		local v51 = v49 + (v50 + 6)
		local v52 = offset2 - 44
		v40 = text(frame, "About", "", math.floor(v14 * 14), 0, v51, v47, math.floor(v14 * 14) * 2 + 8, {
			font = Style.FONT_BODY,
			wrap = true,
			ay = Enum.TextYAlignment.Top
		})
		v36 = Style.frame(
			frame,
			"Parts",
			UDim2.fromOffset(v47, math.floor(v14 * 12) + 10),
			UDim2.fromOffset(0, v52 - math.floor(v14 * 12) - 16)
		)
		v42 = Style.frame(
			frame,
			"PriceBox",
			UDim2.fromOffset(92, math.floor(v14 * 16) + 12),
			UDim2.fromOffset(v47 - 92, v52 + (44 - (math.floor(v14 * 16) + 12)) / 2)
		)
		v43 = plainButton(frame, "Buy", "NOT ON SALE YET", Style.HAZARD, v47 - 100, 44, Style.INK, 18) -- inferred equivalent call
		v43.Position = UDim2.fromOffset(0, v52)
		v43.Activated:Connect(function()
			fn3("PREVIEW ONLY: NOTHING IS ON SALE YET")
		end)
	end

	local function buildToast()
		v37 = Style.label(self, "Toast", "", 16, Style.FONT, 0)
		v37.AutomaticSize = Enum.AutomaticSize.None
		v37.AnchorPoint = Vector2.new(0.5, 1)
		v37.Position = UDim2.new(0.5, 0, 1, -52)
		v37.Size = UDim2.fromOffset(360, 30)
		v37.BackgroundTransparency = 0.1
		v37.BackgroundColor3 = Style.INK
		v37.TextColor3 = Style.HAZARD
		v37.ZIndex = 5
		v37.Visible = false
	end

	local v47 = {
		blue = { rgb(214, 234, 255), rgb(70, 156, 255), rgb(8, 24, 64) }, -- inferred equivalent call
		purple = { rgb(246, 214, 255), rgb(184, 86, 255), rgb(36, 8, 64) }, -- inferred equivalent call
		gold = { rgb(255, 244, 184), rgb(255, 172, 24), rgb(64, 30, 0) }, -- inferred equivalent call
		teal = { rgb(206, 255, 248), rgb(30, 210, 196), rgb(4, 50, 50) }, -- inferred equivalent call
		navy = { rgb(214, 228, 255), rgb(80, 130, 255), rgb(8, 16, 56) } -- inferred equivalent call
	}

	local v48 = { "blue", "purple", "gold" }

	local v49 = {
		blue = { rgb(52, 142, 245), rgb(18, 52, 140) }, -- inferred equivalent call
		purple = { rgb(170, 88, 250), rgb(62, 20, 134) }, -- inferred equivalent call
		gold = { rgb(255, 176, 34), rgb(160, 66, 8) }, -- inferred equivalent call
		teal = { rgb(30, 186, 176), rgb(6, 70, 82) } -- inferred equivalent call
	}

	local function tierFillBright(parent2, p: string, p2: number, p3: number)
		local fill2 = Style.fill(parent2, "Back", Style.WHITE, UDim2.fromScale(1, 1))
		Style.corner(fill2, 8)
		Style.stroke(fill2, 3, 0, Style.INK, true)
		local uiGradient = Instance.new("UIGradient")
		uiGradient.Rotation = 90
		uiGradient.Color = ColorSequence.new(v49[p][1], v49[p][2])
		uiGradient.Parent = fill2
		local v50 = math.floor(p2 * 1.1)
		local light = Instance.new("ImageLabel")
		light.Name = "Light"
		light.BackgroundTransparency = 1
		light.Image = "rbxassetid://133718950618586"
		light.ImageColor3 = Style.WHITE
		light.ImageTransparency = 0.55
		light.Size = UDim2.fromOffset(v50, (math.floor(p3 * 0.75)))
		light.Position = UDim2.fromOffset((p2 - v50) / 2, -p3 * 0.08)
		light.Parent = parent2
	end

	local function tierFill(textButton, p: string, p2: number, p3: number)
		local back = Instance.new("ImageLabel")
		back.Name = "Back"
		back.BackgroundTransparency = 1
		back.Image = v3.card[p]
		back.Size = UDim2.fromOffset(p2, p3)
		back.ScaleType = Enum.ScaleType.Slice
		back.SliceCenter = Rect.new(12, 12, 228, 288)
		back.Parent = textButton
	end

	local function image(parent2, name: string, image2: string, p: number, p2: number, p3: number, p4: number) -- 17 equivalent calls inferred from this helper
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = name
		imageLabel.BackgroundTransparency = 1
		imageLabel.Image = image2
		imageLabel.Size = UDim2.fromOffset(p3, p4)
		imageLabel.Position = UDim2.fromOffset(p, p2)
		imageLabel.Parent = parent2
		return imageLabel
	end

	local function gradientText(parent2, color3: Color3, color4: Color3, color5: Color3?)
		parent2.TextColor3 = Color3.new(1, 1, 1)
		local uiGradient = Instance.new("UIGradient")
		uiGradient.Rotation = 90
		uiGradient.Color = ColorSequence.new(color3, color4)
		uiGradient.Parent = parent2
		local uiStroke = parent2:FindFirstChildOfClass("UIStroke")

		if uiStroke and color5 then
			uiStroke.Color = color5
		end
	end

	local function boldPrice(folder)
		local amount = folder:FindFirstChild("Amount", true)
		local robux = folder:FindFirstChild("Robux", true)
		assert(amount and robux, "[ArmoryStore] not a Robux line")
		local textSize = amount.TextSize
		local v50 = math.round(textSize * 0.75)
		robux.Size = UDim2.fromOffset(v50 + 4, textSize)
		local v51 = math.round(textSize * 0.04)

		for _, descendant in folder:GetDescendants() do
			if descendant:IsA("UIStroke") then
				descendant.Thickness = 2.5
				descendant.Color = Style.INK
				descendant.LineJoinMode = Enum.LineJoinMode.Round
			elseif descendant:IsA("ImageLabel") and descendant.Name == "Icon" then
				if descendant.ImageColor3 == Style.INK then
					descendant.Visible = false
				else
					local v52 = math.round(v50 * (40 / 27))
					descendant.Image = "rbxassetid://72859981496113"
					descendant.ImageColor3 = Color3.new(1, 1, 1)
					descendant.Size = UDim2.fromOffset(v52, v52)
					descendant.Position = UDim2.new(0.5, 0, 0.5, v51)
				end
			end
		end
	end

	local function slash(instance2)
		local amount = instance2:FindFirstChild("Amount", true)
		assert(amount, "[ArmoryStore] no amount to strike")
		local fill2 = Style.fill(
			amount,
			"Slash",
			rgb(232, 36, 24), -- inferred equivalent call
			UDim2.new(1, 8, 0, 4),
			UDim2.fromScale(0.5, 0.5),
			Vector2.new(0.5, 0.5)
		)
		fill2.Rotation = -12
		fill2.ZIndex = amount.ZIndex + 1
		Style.stroke(fill2, 1.5, 0, Style.INK, true)
	end

	local function shadow(instance2, p: number?)
		local v50 = p or math.max(2, (math.round(instance2.TextSize * 0.09)))
		local clone = instance2:Clone()
		clone.Name = instance2.Name .. "Shadow"

		for _, uiGradient in clone:GetChildren() do
			if uiGradient:IsA("UIGradient") then
				uiGradient:Destroy()
			end
		end

		clone.TextColor3 = Style.INK
		clone.TextTransparency = 0.25
		local uiStroke = clone:FindFirstChildOfClass("UIStroke")

		if uiStroke then
			uiStroke.Color = Style.INK
			uiStroke.Transparency = 0.25
		end

		clone.Position = instance2.Position + UDim2.fromOffset(0, v50)
		clone.ZIndex = instance2.ZIndex
		instance2.ZIndex += 1
		clone.Parent = instance2.Parent
		return clone
	end

	local v50 = rgb(236, 40, 52) -- inferred equivalent call

	local function oldPrice(p, p2: number, p3: number, p4: number, p5: number, p6: number)
		local frame = Style.frame(p, "Was", UDim2.fromOffset(p5, p6 + 6), UDim2.fromOffset(p3, p4))
		local frame2 = Style.frame(frame, "Row", UDim2.fromOffset(0, p6 + 6))
		frame2.AutomaticSize = Enum.AutomaticSize.X
		frame2.AnchorPoint = Vector2.new(1, 0)
		frame2.Position = UDim2.fromScale(1, 0)
		local uiListLayout = Instance.new("UIListLayout")
		uiListLayout.FillDirection = Enum.FillDirection.Horizontal
		uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		uiListLayout.Padding = UDim.new(0, 3)
		uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uiListLayout.Parent = frame2
		local v51 = math.round(p6 * 0.75 * (40 / 27))
		local mark = Instance.new("ImageLabel")
		mark.Name = "Mark"
		mark.BackgroundTransparency = 1
		mark.Image = "rbxassetid://72859981496113"
		mark.Size = UDim2.fromOffset(v51, v51)
		mark.LayoutOrder = 1
		mark.Parent = frame2
		local label = Style.label(frame2, "Amount", Style.thousands(p2), p6, Style.FONT, 2.5)
		label.TextColor3 = Style.WHITE
		label.LayoutOrder = 2
		local uiStroke = label:FindFirstChildOfClass("UIStroke")

		if uiStroke then
			uiStroke.Transparency = 0
			uiStroke.Color = Style.INK
			uiStroke.LineJoinMode = Enum.LineJoinMode.Round
		end

		local TextService = game:GetService("TextService")
		local v52 = TextService:GetTextSize(Style.thousands(p2), p6, Enum.Font.Oswald, Vector2.new(1000, 100)).X + v51 + 3 + 8
		local fill2 = Style.fill(
			frame,
			"Strike",
			v50,
			UDim2.fromOffset(v52, (math.max(2, (math.round(p6 * 0.11))))),
			UDim2.new(1, 4, 0.55, 0),
			Vector2.new(1, 0.5)
		)
		fill2.Rotation = -7
		fill2.ZIndex = 4
		return frame
	end

	local function fit(parent2, maxTextSize: number) -- 28 equivalent calls inferred from this helper
		parent2.TextScaled = true
		local uiTextSizeConstraint = Instance.new("UITextSizeConstraint")
		uiTextSizeConstraint.MaxTextSize = maxTextSize
		uiTextSizeConstraint.Parent = parent2
	end

	local function fadeBand(p, color3: Color3, p2: number, p3: number, p4: number, p5: number, flag2: boolean?)
		local fill2 = Style.fill(p, "Band", color3, UDim2.fromOffset(p4, p5), UDim2.fromOffset(p2, p3))
		local uiGradient = Instance.new("UIGradient")
		uiGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.35, 0.6),
			NumberSequenceKeypoint.new(1, 0.1)
		})
		uiGradient.Rotation = flag2 and 180 or 0
		uiGradient.Parent = fill2
		return fill2
	end

	local function artButton(parent2, name: string, image2: string, p: number, p2: number, p3: number, p4: number)
		local imageButton = Instance.new("ImageButton")
		imageButton.Name = name
		imageButton.BackgroundTransparency = 1
		imageButton.AutoButtonColor = false
		imageButton.Image = image2
		imageButton.AnchorPoint = Vector2.new(0.5, 0.5)
		imageButton.Size = UDim2.fromOffset(p3, p4)
		imageButton.Position = UDim2.fromOffset(p + p3 / 2, p2 + p4 / 2)
		imageButton.ZIndex = 2
		imageButton.Parent = parent2
		springy(imageButton)
		return imageButton
	end

	local function saleCard(parent2, name: string, p: string, p2: number, p3: number, p4: number, p5: number, flag2: boolean, flag3: boolean?)
		local textButton = Instance.new("TextButton")
		textButton.Name = name
		textButton.Text = ""
		textButton.AutoButtonColor = false
		textButton.BackgroundTransparency = 1
		textButton.AnchorPoint = Vector2.new(0.5, 0.5)
		textButton.Size = UDim2.fromOffset(p4, p5)
		textButton.Position = UDim2.fromOffset(p2 + p4 / 2, p3 + p5 / 2)
		textButton.Parent = parent2
		tierFill(textButton, p, p4, p5)
		springy(textButton, true)
		local v51 = touch and 44 or 52
		local v52 = p5 - 3 - v51
		local v53 = nil
		local v54

		if flag2 and not flag3 then
			local v55 = math.floor(v51 * 1.45)
			local v56 = math.floor(v51 * 0.3)
			v54 = artButton(textButton, "Buy", v3.barBuy, 3, v52, p4 - 6 - v55 + v56, v51)

			v54.ScaleType = Enum.ScaleType.Slice
			v54.SliceCenter = Rect.new(4, 0, 400, 112)
			v54.SliceScale = v51 / 112
			v53 = artButton(textButton, "Gift", v3.barGift, p4 - 3 - v55, v52, v55, v51)
			v53.Activated:Connect(function()
				giftTap(name)
			end)
		elseif flag3 then
			local v55 = math.min(v51, (math.floor((p4 - 6 - 8) / ((flag2 and 99 / 112 or 0) + 75 / 28))))
			local v56 = not flag2 and 0 or math.floor(v55 * 1.25)
			local v57 = not flag2 and 0 or math.floor(v55 * (41 / 112))
			local v58 = math.floor(v55 * (75 / 28))
			local v59 = math.floor((p4 - (v58 + v56 - v57)) / 2)
			local v60 = v52 - 3 + v51 - v55

			if flag2 then
				v53 = artButton(textButton, "Gift", v3.gift, v59, v60, v56, v55)
				v53.Activated:Connect(function()
					giftTap(name)
				end)

				v53.ZIndex = 3
				v59 += v56 - v57
			end

			v54 = artButton(textButton, "Buy", v3.buyShort, v59, v60, v58, v55)
		else
			v54 = artButton(textButton, "Claim", v3.barClaim, 3, v52, p4 - 6, v51)
		end

		v54.Selectable = false

		if v53 then
			v53.Selectable = false
		end

		return textButton, v54, v53, v52
	end

	local v51 = nil
	local function starterCard(p: number, total: number, p2: number, p3: number)
		local v52 = CareerData.STORE.starter[1]
		local starterPack = Instance.new("TextButton")
		starterPack.Name = "StarterPack"
		starterPack.Text = ""
		starterPack.AutoButtonColor = false
		starterPack.BackgroundTransparency = 1
		starterPack.AnchorPoint = Vector2.new(0.5, 0.5)
		starterPack.Size = UDim2.fromOffset(p2, p3)
		starterPack.Position = UDim2.fromOffset(p + p2 / 2, total + p3 / 2)
		starterPack.ClipsDescendants = true
		starterPack.Parent = parent
		local imageLabel = image(starterPack, "Scene", v3.starter, 0, 0, p2, p3) -- inferred equivalent call
		imageLabel.ScaleType = Enum.ScaleType.Crop
		Style.corner(imageLabel, 6)
		Style.stroke(imageLabel, 3, 0, Style.INK, true)
		springy(starterPack, true)
		local v54 = touch and 8 or 12
		local v55 = math.floor(v14 * 30)

		text(starterPack, "Title", v52.name, v55, v54, 8, p2 - v54 * 2, v55 + 6, { outline = 2 })

		local v56 = v55 + 8 + 6
		local v57 = math.floor(v14 * 15)

		text(starterPack, "Offer", "ONE TIME OFFER", v57, v54, v56, p2 - v54 * 2, v57 + 6, {
			outline = 2
		})

		local v58 = math.floor(p2 * 0.6)
		local v59 = p2 - v58 - v54
		local v60 = touch and 44 or 54
		local v61 = p3 - v60 - v54
		local v62 = math.floor(v14 * 15) + 8

		local v63 = v56 + v57 + 22
		local v64 = math.min(math.floor(v14 * 17) + 16, (math.floor((v61 - v62 - 6 - v63) / 3)))

		for k, v65 in { "STEALTH CHOPPER", "3 PLAYER XP BOOSTS" } do
			local v66 = v63 + (k - 1) * (v64 + 4)
			fadeBand(starterPack, Style.INK, v58 - 10, v66, p2 - v58 + 10, v64, true)
			text(starterPack, "Item" .. k, v65, math.floor(v14 * 17), v58, v66, v59, v64, {
				outline = 2
			})
		end

		local v65 = buyPlate(starterPack, v58, v61, v59, v60, "starter")
		local v66 = text(v65, "Owned", "OWNED", math.floor(v14 * 20), 0, 0, v65.Size.X.Offset, v60, {
			color = Style.GOOD,
			ax = Enum.TextXAlignment.Center
		})
		local frame = Style.frame(v65, "Now", UDim2.fromScale(1, 1))
		local robuxLine, v67 = Style.robuxLine(frame, "Line", (math.floor(v14 * 22)))
		boldPrice(robuxLine)

		local offset3 = v65.Position.X.Offset
		local halfOffset = v65.Size.X.Offset / 2
		local frame2 = Style.frame(
			starterPack,
			"Was",
			UDim2.fromOffset(halfOffset, v62),
			UDim2.fromOffset(offset3 + 4, v61 - v62 - 4)
		)
		local robuxLine2, v69 = Style.robuxLine(frame2, "Line", (math.floor(v14 * 17)))
		local uiListLayout = robuxLine2:FindFirstChildOfClass("UIListLayout")
		uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
		v69(nil, Style.thousands(v52.worth), Style.WHITE)
		boldPrice(robuxLine2)
		slash(robuxLine2)
		local v70 = math.floor(v14 * 22)

		local parent2 = text(
			starterPack,
			"Save",
			"",
			v70,
			offset3 - halfOffset,
			v61 - v62 - 4 + (v62 - v70 - 6) / 2,
			halfOffset - 4,
			v70 + 6,
			{ outline = 3, ax = Enum.TextXAlignment.Right }
		)
		gradientText(parent2, rgb(255, 244, 160), Style.HAZARD, Style.INK) -- inferred equivalent call
		local function bought(): boolean -- 2 equivalent calls inferred from this helper
			return instance:GetAttribute(Skins.PACK_ATTR) == true
		end

		local function fn4()
			local visible = bought() -- inferred equivalent call
			local v73

			if v52.productId == 0 then
				v73 = v52.robux
			else
				v73 = priceOf(v52.productId, fn4) or v52.robux -- inferred equivalent call
			end

			local image2 = if visible then v3.buyOff else v3.buy
			v65.Image = image2
			v66.Visible = visible
			frame2.Visible = not visible
			frame.Visible = not visible
			v67(nil, Style.thousands(v73), Style.WHITE)
			parent2.Text = string.format("SAVE %d%%", (math.round((1 - v73 / v52.worth) * 100)))
			parent2.Visible = not visible
		end
		v51 = fn4
		fn4()
		local function press()
			UiTrack.send("store_tap", v52.id)

			if bought() then -- inferred equivalent call
				fn3("ALREADY OWNED")
				return
			end

			if v52.productId == 0 then
				fn3("ON SALE SOON")
				return
			end

			buySound() -- inferred equivalent call
			MarketplaceService:PromptProductPurchase(instance, v52.productId)
		end
		starterPack.Activated:Connect(press)
		v65.Activated:Connect(press)
		return starterPack
	end

	local function soonFree(p: number, total: number, p2: number, p3: number)
		local free = CareerData.FREE

		local parent2, v53, _, v54 = saleCard(parent, "FreeScrap", "navy", p, total, p2, p3, false)
		local v55 = touch and 8 or 12
		local maxTextSize = math.floor(v14 * 32)

		local parent4 = text(parent2, "Big", "FREE SCRAP", maxTextSize, v55, 8, p2 - v55 * 2, maxTextSize + 6, {
			outline = 2.5,
			ax = Enum.TextXAlignment.Center
		})
		fit(parent4, maxTextSize) -- inferred equivalent call
		gradientText(parent4, rgb(255, 250, 200), rgb(255, 200, 40), Style.INK) -- inferred equivalent call
		shadow(parent4)
		local v58 = maxTextSize + 8 + 6
		shadow(
			text(
				parent2,
				"Small",
				"+" .. Style.thousands(free.scrap) .. " SCRAP",
				math.floor(v14 * 17),
				v55,
				v58,
				p2 - v55 * 2,
				math.floor(v14 * 17) + 6,
				{ outline = 2, ax = Enum.TextXAlignment.Center }
			),
			2
		)
		local v60 = v58 + math.floor(v14 * 17) + 10

		local v61 = v54 - v60 - 6
		local v62 = math.floor(p2 * 1.1)
		local imageLabel = image( -- inferred equivalent call
			parent2,
			"Glow",
			"rbxassetid://133718950618586",
			(p2 - v62) / 2,
			v60 + v61 / 2 - v62 * 0.4,
			v62,
			math.floor(v62 * 0.8)
		)
		imageLabel.ImageColor3 = rgb(255, 160, 60) -- inferred equivalent call
		imageLabel.ImageTransparency = 0.3
		local imageLabel2 = image(parent2, "Art", v3.pack.scrapS, v55 + 6, v60, p2 - v55 * 2 - 12, v61) -- inferred equivalent call
		imageLabel2.ScaleType = Enum.ScaleType.Fit
		local v65 = {}
		local function breathe(flag2: boolean) -- 1 equivalent call inferred from this helper
			Style.stop(v65)
			imageLabel.ImageTransparency = flag2 and 0.3 or 0.75

			if flag2 and not data.still then
				Style.animate(v65, function(_: number, p4: number): boolean
					if not imageLabel.Parent then
						return false
					end

					imageLabel.ImageTransparency = 0.38 - math.sin(p4 * 3) * 0.18
					return true
				end)
			end
		end

		local v66 = text(v53, "Amount", "", math.floor(v14 * 18), 0, 0, v53.Size.X.Offset, v53.Size.Y.Offset, {
			outline = 2,
			ax = Enum.TextXAlignment.Center
		})
		fn = function()
			local freeLeft = ArmoryStore.freeLeft(instance)
			local v67 = freeLeft <= 0
			local image2 = if v67 then v3.barClaim else v3.barClaimOff
			v53.Image = image2
			local textColor = if v67 then Style.WHITE else Style.MUTED
			v66.TextColor3 = textColor
			local text2

			if v67 then
				text2 = "CLAIM"
			else
				text2 = "NEXT IN " .. clock(freeLeft) -- inferred equivalent call
			end

			v66.Text = text2
			breathe(v67) -- inferred equivalent call
		end
		fn()
		local function press()
			local freeLeft = ArmoryStore.freeLeft(instance)
			UiTrack.send("free_tap", freeLeft > 0 and "wait" or "ready")

			if freeLeft > 0 then
				fn3("NEXT FREE SCRAP IN " .. clock(freeLeft)) -- inferred equivalent call
			elseif not v28 then
				v28 = true
				local career = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Remotes"):WaitForChild("Career")
				local success, result, v67 = pcall(career.InvokeServer, career, "free")
				v28 = false

				if success and result == true then
					assert(ArmoryStore.reveal, "[ArmoryStore] LobbyMenus has not set the reveal")(free.scrap)
				else
					warn("[ArmoryStore] free claim: " .. tostring(result) .. " " .. tostring(v67))
					fn3((not success or type(v67) ~= "string") and "NO ANSWER, TRY AGAIN" or string.upper(v67))
				end
			end
		end
		parent2.Activated:Connect(press)
		v53.Activated:Connect(press)
		return parent2
	end

	local v52 = { shotgun = true }
	local v53 = Crates.CLASSES[1].id

	local v54 = instance:GetAttribute(ShopData.PRIMARY_ATTR)
	local classOf = WeaponSkins.classOf

	if type(v54) ~= "string" then
		v54 = ShopData.DEFAULT_PRIMARY
	end

	local v55 = classOf(v54)

	if Crates.classOf(v55) and not v52[v55] then
		v53 = v55
	end

	local v56 = {}
	local function pickCrate(p: string)
		assert(Crates.classOf(p), "[ArmoryStore] no crate for class " .. p)

		if v53 == p then
			return
		end

		v53 = p
		UiTrack.send("store_tap", "crateClass_" .. p)

		for _, v57 in v56 do
			v57()
		end
	end

	local function packCard(data2, p: string, flag2: boolean, p2: number, total: number, p3: number, p4: number, p5: string?)
		local v57 = data2.kind == "scrapBoost"
		local parent2, v59, v60, v61 = saleCard(parent, data2.id, p, p2, total, p3, p4, not v57, v57)
		local v62 = touch and 6 or 10
		local maxTextSize = math.floor(v14 * 30)
		local maxTextSize2 = math.floor(v14 * 15)

		local v65 = v47[p]

		if v57 then
			local v66 = p4 - v62 * 2
			local imageLabel = image(parent2, "Art", data2.image, v62 + 4, v62, v66, v66) -- inferred equivalent call
			imageLabel.ScaleType = Enum.ScaleType.Fit
			local offset3 = v59.Size.X.Offset
			v59.Position = UDim2.fromOffset(p3 - 3 - 14 - offset3 / 2, p4 / 2)
			local v68 = v62 + 4 + v66 + 14
			local v69 = p3 - v68 - offset3 - 3 - 28
			local v70 = math.floor((p4 - (maxTextSize + 6 + 2 + maxTextSize2 + 6)) / 2)
			local parent4 = text(parent2, "Big", data2.name, maxTextSize, v68, v70, v69, maxTextSize + 6, {
				outline = 2
			})
			fit(parent4, maxTextSize) -- inferred equivalent call
			gradientText(parent4, v65[1], v65[2], v65[3])
			fit( -- inferred equivalent call
				text(parent2, "Small", data2.blurb, maxTextSize2, v68, v70 + maxTextSize + 8, v69, maxTextSize2 + 6, {
					outline = 2
				}),
				maxTextSize2
			)
		elseif p5 then
			local v66 = v61 - 2
			local v67 = math.min(v66 - 6, (math.floor(p3 * 0.4)))

			local imageLabel = image( -- inferred equivalent call
				parent2,
				"Art",
				assert(
					(v3.crate[p5] or {})[data2.n],
					"[ArmoryStore] no crate picture for " .. p5 .. " x" .. tostring(data2.n)
				),
				v62,
				math.floor((v66 - v67) / 2) + 1,
				v67,
				v67
			)
			imageLabel.ScaleType = Enum.ScaleType.Fit
			local maxTextSize3 = math.floor(v14 * 22)

			local parent4 = text(
				parent2,
				"Big",
				data2.big,
				maxTextSize3,
				v62 + v67 + 4,
				3,
				p3 - v67 - v62 * 2 - 4,
				v66 - 4,
				{ outline = 2, ax = Enum.TextXAlignment.Center }
			)
			fit(parent4, maxTextSize3) -- inferred equivalent call
			gradientText(parent4, v65[1], v65[2], v65[3])
		else
			local parent4 = text(parent2, "Big", data2.big, maxTextSize, v62, 8, p3 - v62 * 2, maxTextSize + 6, {
				outline = 2,
				ax = Enum.TextXAlignment.Center
			})
			fit(parent4, maxTextSize) -- inferred equivalent call
			gradientText(parent4, v65[1], v65[2], v65[3])
			local v67 = maxTextSize + 8 + 4

			if data2.line2 then
				fit( -- inferred equivalent call
					text(parent2, "Small", data2.line2, maxTextSize2, v62, v67, p3 - v62 * 2, maxTextSize2 + 6, {
						outline = 2,
						ax = Enum.TextXAlignment.Center
					}),
					maxTextSize2
				)
			end

			local v68 = v67 + maxTextSize2 + 8
			local imageLabel = image( -- inferred equivalent call
				parent2,
				"Art",
				v3.pack[data2.id] or data2.image,
				v62,
				v68,
				p3 - v62 * 2,
				v61 - v68 - (math.floor(v14 * 14) + 8) - 2
			)
			imageLabel.ScaleType = Enum.ScaleType.Fit
		end

		if flag2 then
			local v66 = math.floor(v14 * 14) + 8

			fadeBand(parent2, rgb(150, 20, 10), 3, v61 - v66, p3 - 6, v66) -- inferred equivalent call
			text(parent2, "Best", "BEST VALUE", math.floor(v14 * 14), v62, v61 - v66, p3 - v62 * 2, v66, {
				outline = 1.5,
				ax = Enum.TextXAlignment.Right
			})
		end

		local v66 = text(v59, "Amount", "", math.floor(v14 * 18), 0, 0, v59.Size.X.Offset, v59.Size.Y.Offset, {
			outline = 1.5,
			ax = Enum.TextXAlignment.Center
		})
		local robuxLine, v67 = Style.robuxLine(v59, "Line", (math.floor(v14 * 20)))
		boldPrice(robuxLine)

		local function collected(): boolean -- 2 equivalent calls inferred from this helper
			if data2.kind ~= "crate" or Crates.REPEATS then
				return false
			end

			local crateCount, v68 = WeaponSkins.crateCount(instance, p5 or v53)
			return v68 <= crateCount
		end

		local function drawCard()
			local v68 = v57 and instance:GetAttribute(CareerData.SCRAP2X_ATTR) == true
			local v69 = collected() or v68 -- inferred equivalent call
			local visible

			if data2.productId == 0 then
				visible = false
			else
				visible = not v69
			end

			local v71

			if visible then
				v71 = priceOf(data2.productId, redrawProducts) or data2.robux -- inferred equivalent call
			end

			local image2

			if v57 then
				image2 = if visible then v3.buyShort else v3.buyOffShort
			else
				image2 = if visible then v3.barBuy else v3.barOff
			end

			v59.Image = image2

			if v60 then
				local image3

				if visible then
					image3 = v3.barGift
				else
					image3 = v3.barGiftOff
				end

				v60.Image = image3
			end

			v66.TextColor3 = Style.MUTED
			v66.Text = visible and "" or v68 and "OWNED" or v69 and "ALL COLLECTED" or "NOT ON SALE"
			robuxLine.Visible = visible
			v67(nil, not v71 and "..." or Style.thousands(v71), Style.WHITE)
		end
		table.insert(v27, drawCard)

		if v57 then
			instance:GetAttributeChangedSignal(CareerData.SCRAP2X_ATTR):Connect(drawCard)
		end

		if data2.kind == "crate" then
			table.insert(v56, drawCard)
			instance.AttributeChanged:Connect(function(value: string)
				if string.sub(value, 1, 3) == "Cs_" then
					drawCard()
				end
			end)
		end

		local function press()
			UiTrack.send("store_tap", data2.id)

			if v57 and instance:GetAttribute(CareerData.SCRAP2X_ATTR) == true then
				fn3("ALREADY OWNED")
				return
			end

			if collected() then -- inferred equivalent call
				fn3("YOU OWN EVERY SKIN IN THIS CRATE")
				return
			end

			if data2.productId == 0 then
				fn3("NOT ON SALE YET")
				return
			end

			if p5 then
				pickCrate(p5)
				CrateOpen.warm(p5)
			end

			buySound() -- inferred equivalent call
			MarketplaceService:PromptProductPurchase(instance, data2.productId)
		end
		parent2.Activated:Connect(press)
		v59.Activated:Connect(press)
		return parent2
	end

	local v57 = false
	local draws = {}
	local function useButton(p: string, p2: number, total: number, p3: number, p4: number)
		local v58 = CareerData.STOCK_ATTR[p]
		local v59

		if p == "boost" then
			v59 = CareerData.BOOST_ATTR
		else
			v59 = CareerData.GUN_BOOST_ATTR
		end

		assert(v58 and v59, "[ArmoryStore] no boost kind " .. p)
		local v60 = artButton(parent, "Use" .. p, v3.buy, p2, total, p3, p4)
		local v61 = text(v60, "Use", "", math.floor(v14 * 20), 0, 0, p3, p4, {
			outline = 2,
			ax = Enum.TextXAlignment.Center
		})
		local function stock() -- 3 equivalent calls inferred from this helper
			return instance:GetAttribute(v58) or 0
		end

		local function endsAt() -- 4 equivalent calls inferred from this helper
			return instance:GetAttribute(v59) or 0
		end

		local count = 0
		local function seen()
			local instance2 = v60

			while instance2 do
				if instance2:IsA("LayerCollector") then
					return instance2.Enabled
				end

				if instance2:IsA("GuiObject") and not instance2.Visible then
					return false
				end

				instance2 = instance2.Parent
			end

			return false
		end

		local function clock2() -- 2 equivalent calls inferred from this helper
			local v62 = math.max(0, endsAt() - os.time()) -- inferred equivalent call
			return string.format("%d:%02d (x%d)", v62 // 60, v62 % 60, stock()) -- inferred equivalent call
		end

		local function draw()
			local v62 = stock() -- inferred equivalent call
			local v63 = os.time() < endsAt() -- inferred equivalent call
			local v64

			if v62 > 0 then
				v64 = not v63
			else
				v64 = false
			end

			local image2 = if v64 then v3.buy else v3.buyOff
			v60.Image = image2
			local textColor

			if v64 or v63 then
				textColor = Style.WHITE
			else
				textColor = Style.MUTED
			end

			v61.TextColor3 = textColor
			local text2

			if v63 then
				text2 = clock2() -- inferred equivalent call
			else
				text2 = string.format("USE (x%d)", v62)
			end

			v61.Text = text2
			count += 1

			if v63 then
				local v68 = count
				task.spawn(function()
					while count == v68 and v60.Parent and os.time() < endsAt() do -- inferred equivalent call
						task.wait(1)

						if count == v68 and seen() then
							v61.Text = clock2() -- inferred equivalent call
						end
					end

					if count == v68 and v60.Parent then
						draw()
					end
				end)
			end
		end
		table.insert(draws, draw)
		draw()
		v60.Activated:Connect(function()
			if os.time() < endsAt() then -- inferred equivalent call
				fn3("BOOST ALREADY ON")
			elseif stock() < 1 then -- inferred equivalent call
				fn3("NO BOOSTS LEFT")
			elseif not v57 then
				v57 = true
				local career = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Remotes"):WaitForChild("Career")
				local success, result, v62 = pcall(career.InvokeServer, career, "use", p)
				v57 = false

				if success and result == true then
					assert(MenuAudio.stamp, "[ArmoryStore] MenuAudio is not mounted")()
				else
					warn("[ArmoryStore] use boost: " .. tostring(result) .. " " .. tostring(v62))
					fn3((not success or type(v62) ~= "string") and "NO ANSWER, TRY AGAIN" or string.upper(v62))
				end
			end
		end)
	end

	local function ownsCrate(p: string) -- 3 equivalent calls inferred from this helper
		return WeaponSkins.ownsCrate(instance, p, v53)
	end

	local v58 = {
		rifle = "AssaultRifle",
		smg = "SMG",
		lmg = "LMG",
		sniper = "Sniper",
		dmr = "DMR",
		shotgun = "Shotgun",
		pistol = "Pistol"
	}

	for _, class in Crates.CLASSES do
		local v59 = v58[class.id]
		assert(
			v59 and WeaponSkins.classOf(v59) == class.id,
			"[ArmoryStore] no first gun for the " .. class.id .. " crate"
		)
	end

	local function carried(p: string)
		local result = {}

		for _, v59 in { "primary", "secondary" } do
			local v60 = ShopData.PICKS[v59]
			local v61 = instance:GetAttribute(v60.attr)

			if type(v61) ~= "string" then
				v61 = v60.default
			end

			if not (WeaponSkins.has(v61) and WeaponSkins.classOf(v61) == p) then
				continue
			end

			table.insert(result, v61)
		end

		return result
	end

	local function classGun(p: string) -- 1 equivalent call inferred from this helper
		return carried(p)[1] or v58[p]
	end

	local function myOdds() -- 1 equivalent call inferred from this helper
		local odds = Crates.odds
		local Players = game:GetService("Players")
		return odds(ownsCrate, Players.LocalPlayer:GetAttribute("Level") or 1)
	end

	local function ownedCrateSkins()
		local idSet = {}

		for _, v59 in WeaponSkins.CRATE do
			if ownsCrate(v59.id) then -- inferred equivalent call
				idSet[v59.id] = true
			end
		end

		return idSet
	end

	local v59 = nil
	local function closeOdds() -- 3 equivalent calls inferred from this helper
		if v59 then
			v59:Destroy()
			v59 = nil
		end
	end
	local function showOdds()
		closeOdds() -- inferred equivalent call
		UiTrack.send("store_tap", "crateOdds")
		local v60 = myOdds() -- inferred equivalent call
		local crateOdds = Instance.new("TextButton")
		crateOdds.Name = "CrateOdds"
		crateOdds.Text = ""
		crateOdds.AutoButtonColor = false
		crateOdds.BackgroundColor3 = Style.INK
		crateOdds.BackgroundTransparency = 0.3
		crateOdds.BorderSizePixel = 0
		crateOdds.Size = UDim2.fromScale(1, 1)
		crateOdds.ZIndex = 50
		crateOdds.Parent = self
		v59 = crateOdds
		crateOdds.Activated:Connect(closeOdds)
		local v61 = math.min(offset - 24, 560)
		local v62 = offset2 - 24
		local fill2 = Style.fill(
			crateOdds,
			"Panel",
			Style.PANEL,
			UDim2.fromOffset(v61, v62),
			UDim2.fromScale(0.5, 0.5),
			Vector2.new(0.5, 0.5)
		)
		fill2.Active = true
		Style.corner(fill2, 6)
		Style.stroke(fill2, 2, 0, Style.INK, true)
		local maxTextSize = math.floor(v14 * 22)

		fit( -- inferred equivalent call
			text(fill2, "Title", Crates.classOf(v53).name .. " ODDS", maxTextSize, 12, 12, v61 - 24, maxTextSize + 6, {
				outline = 2
			}),
			maxTextSize
		)
		local v64 = math.floor(v14 * 13)
		local v65 = false

		for _, v66 in v60 do
			v65 = v65 or v66.dup == true
		end

		text(
			fill2,
			"Note",
			(v65 or Crates.REPEATS) and "ONE SKIN PER CRATE, FOR EVERY GUN OF THAT KIND. A SKIN YOU ALREADY OWN TURNS INTO SCRAP AND XP." or "ONE SKIN PER CRATE, FOR EVERY GUN OF THAT KIND. YOUR ODDS: SKINS YOU OWN ARE LEFT OUT, SO NO REPEATS.",
			v64,
			12,
			maxTextSize + 12 + 8,
			v61 - 24,
			v64 + 6,
			{ outline = 1.5, color = Style.MUTED }
		)
		local v66 = touch and 44 or 40
		local v67 = maxTextSize + 12 + 8 + v64 + 12
		local v68 = math.floor(v14 * 12)

		local v69 = v62 - 12 - v66 - 8 - v68 - 8
		local list = Instance.new("ScrollingFrame")
		list.Name = "List"
		list.BackgroundTransparency = 1
		list.BorderSizePixel = 0
		list.ScrollBarThickness = 6
		list.ScrollBarImageColor3 = Style.HAZARD
		list.ScrollingDirection = Enum.ScrollingDirection.Y
		list.Size = UDim2.fromOffset(v61 - 24, v69 - v67)
		list.Position = UDim2.fromOffset(12, v67)
		list.Parent = fill2
		local maxTextSize2 = math.floor(v14 * 15)

		local v71 = maxTextSize2 + 10
		local v72 = v61 - 24 - 14
		local v73 = 0

		for _, v74 in Crates.TIERS do
			local total = 0

			for _, v75 in v60 do
				if v75.tier == v74.id then
					total += v75.p
				end
			end

			local text_2 = text(list, v74.id .. "Head", v74.name, math.floor(v14 * 17), 0, v73, v72, v71 + 2, {
				outline = 2,
				color = v74.color
			})
			text_2.AutoLocalize = true
			local text_3 = text(
				list,
				v74.id .. "HeadP",
				Crates.percent(total),
				math.floor(v14 * 17),
				0,
				v73,
				v72,
				v71 + 2,
				{ outline = 2, color = v74.color, ax = Enum.TextXAlignment.Right }
			)
			text_3.AutoLocalize = false
			local v75 = v73 + (v71 + 4)

			for k, v76 in v60 do
				if v76.tier ~= v74.id then
					continue
				end

				if v76.dup then
					local v77 = v74.id .. k
					local v78

					if (v76.xp or 0) > 0 then
						v78 = string.format("%s  (OWNED: +%d SCRAP +%d XP)", v76.label, v76.scrap or 0, v76.xp or 0)
					else
						v78 = string.format("%s  (OWNED: +%d SCRAP)", v76.label, v76.scrap or 0)
					end

					local parent2 = text(list, v77, v78, maxTextSize2, 14, v75, v72 - 14, v71, {
						outline = 1.5,
						color = Style.MUTED
					})
					parent2.AutoLocalize = false
					fit(parent2, maxTextSize2) -- inferred equivalent call
				else
					text(list, v74.id .. k, v76.label, maxTextSize2, 14, v75, v72 - 14, v71, {
						outline = 1.5
					})
				end

				local text_4 = text(
					list,
					v74.id .. k .. "P",
					Crates.percent(v76.p),
					maxTextSize2,
					14,
					v75,
					v72 - 14,
					v71,
					{ outline = 1.5, ax = Enum.TextXAlignment.Right }
				)
				text_4.AutoLocalize = false
				v75 += v71
			end

			v73 = v75 + 8
		end

		list.CanvasSize = UDim2.fromOffset(0, v73)
		text(
			fill2,
			"Foot",
			"Odds are rounded, so the numbers shown may not add up to exactly 100%.",
			v68,
			12,
			v69 + 8,
			v61 - 24,
			v68 + 6,
			{ outline = 1, color = Style.MUTED }
		)
		local v74 = math.floor(v61 * 0.4)
		local v75 = artButton(fill2, "Close", v3.buy, (v61 - v74) / 2, v62 - 12 - v66, v74, v66)
		text(v75, "Label", "CLOSE", math.floor(v14 * 18), 0, 0, v74, v66, {
			outline = 2,
			ax = Enum.TextXAlignment.Center
		})
		v75.Activated:Connect(closeOdds)
	end

	local function vivid(color3: Color3) -- 2 equivalent calls inferred from this helper
		local hsv, v60 = color3:ToHSV()
		return Color3.fromHSV(hsv, math.min(1, v60 * 1.1 + 0.12), 1)
	end

	local v60 = nil
	local v61 = nil
	local function closeSkin() -- 2 equivalent calls inferred from this helper
		v61 = nil

		if v60 then
			Style.stop(v60)
			v60:Destroy()
			v60 = nil
		end
	end
	local function showSkin(data2)
		closeSkin() -- inferred equivalent call
		closeOdds() -- inferred equivalent call
		UiTrack.send("store_tap", "crateSkin")

		local tier = Crates.tierOf(data2.crate)
		local imageColor2 = vivid(tier.color) -- inferred equivalent call
		local crateSkin = Instance.new("TextButton")
		crateSkin.Name = "CrateSkin"
		crateSkin.Text = ""
		crateSkin.AutoButtonColor = false
		crateSkin.BackgroundColor3 = Style.INK
		crateSkin.BackgroundTransparency = 0.15
		crateSkin.BorderSizePixel = 0
		crateSkin.Size = UDim2.fromScale(1, 1)
		crateSkin.ZIndex = 50
		crateSkin.Parent = self
		v60 = crateSkin
		crateSkin.Activated:Connect(closeSkin)
		local v63 = math.min(offset - 16, 980)
		local v64 = math.min(offset2 - 16, (math.max(300, (math.floor(v63 * 0.6)))))
		local fill2 = Style.fill(
			crateSkin,
			"Panel",
			Style.INK,
			UDim2.fromOffset(v63, v64),
			UDim2.fromScale(0.5, 0.5),
			Vector2.new(0.5, 0.5)
		)
		fill2.Active = true
		fill2.ClipsDescendants = true
		Style.corner(fill2, 8)
		Style.stroke(fill2, 3, 0, Style.INK, true)
		local imageLabel = image(fill2, "Vault", "rbxassetid://72850554293442", 0, 0, v63, v64) -- inferred equivalent call
		imageLabel.ScaleType = Enum.ScaleType.Crop
		imageLabel.ImageColor3 = imageColor2:Lerp(Style.WHITE, 0.3)
		Style.corner(imageLabel, 8)

		local fill3 = Style.fill(fill2, "Dusk", Style.INK, UDim2.fromOffset(v63, v64), UDim2.fromOffset(0, 0))
		Style.corner(fill3, 8)
		local uiGradient = Instance.new("UIGradient")
		uiGradient.Rotation = 90
		uiGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(0.22, 1),
			NumberSequenceKeypoint.new(0.62, 1),
			NumberSequenceKeypoint.new(1, 0.1)
		})
		uiGradient.Parent = fill3
		local frame = Style.frame(fill2, "Rim", UDim2.fromOffset(v63 - 8, v64 - 8), UDim2.fromOffset(4, 4))
		Style.corner(frame, 5)
		Style.stroke(frame, 2.5, 0.1, imageColor2, true)
		local maxTextSize = math.floor(v14 * 30)
		local v67 = math.floor(v14 * 17)
		local maxTextSize2 = math.floor(v14 * 22)
		local v69 = touch and 44 or 40
		local v70 = math.max(48, maxTextSize2 + 12)
		local v71 = maxTextSize + 6 + v67 + 6 + 8 + v69
		local v72 = v70 + 14 + 4
		local v73 = v64 - v72 - 14 - v71 - 4
		local v74 = v63 - 28
		local frame2 = Style.frame(fill2, "Stage", UDim2.fromOffset(v74, v73), UDim2.fromOffset(14, v72))
		local v75 = math.min(math.floor(v73 * 1.6), v74)
		local function light(name: string, image2: string, p: number, p2: number, imageColor: Color3, imageTransparency: number)
			local imageLabel2 = image(frame2, name, image2, 0, 0, p, p2) -- inferred equivalent call
			imageLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
			imageLabel2.Position = UDim2.fromScale(0.5, 0.5)
			imageLabel2.ImageColor3 = imageColor
			imageLabel2.ImageTransparency = imageTransparency
			return imageLabel2
		end

		local v76 = light("Glow", "rbxassetid://117683324143574", v75, v75, imageColor2, 0.3)
		local v77 = light("Rays", "rbxassetid://86169893101770", v75, v75, imageColor2:Lerp(Style.WHITE, 0.25), 0.55)
		light(
			"Core",
			"rbxassetid://117683324143574",
			math.floor(v75 * 0.7),
			math.floor(v75 * 0.3),
			imageColor2:Lerp(Style.WHITE, 0.7),
			0.5
		)

		local classGuns = WeaponSkins.classGuns(v58[v53])
		local v78 = table.find(classGuns, classGun(v53)) or 1 -- inferred equivalent call
		local v79 = nil
		local currentCamera2 = nil
		local boundingBox = nil
		local v80 = nil
		local v81 = -10
		local v82 = 0
		local v83 = math.min(v63 - 28 - 116, math.floor(v14 * 22) * 12)
		local parent2 = text(fill2, "Gun", "", maxTextSize2, (v63 - v83) / 2, 14, v83, maxTextSize2 + 6, {
			outline = 2.5,
			ax = Enum.TextXAlignment.Center
		})
		parent2.AutoLocalize = false
		parent2.ZIndex = 6
		fit(parent2, maxTextSize2) -- inferred equivalent call
		local v85 = math.max(math.floor(v14 * 12), 12)
		local v86 = text(fill2, "GunCount", "", v85, (v63 - v83) / 2, maxTextSize2 + 14 + 4, v83, v85 + 4, {
			outline = 1.5,
			ax = Enum.TextXAlignment.Center,
			color = imageColor2:Lerp(Style.WHITE, 0.55)
		})
		v86.AutoLocalize = false
		v86.ZIndex = 6
		local function setGun(p: number, p2: number)
			v78 = (p - 1) % #classGuns + 1

			if v79 then
				v79:Destroy()
			end

			local v87 = ToolIcon.make(toolOf(classGuns[v78]), frame2) -- inferred equivalent call
			v87.Size = UDim2.fromScale(1, 1)
			v87.ZIndex = 4
			local model = v87:FindFirstChildOfClass("Model")
			WeaponSkins.paint(model, data2.id)
			currentCamera2 = v87.CurrentCamera
			boundingBox = model:GetBoundingBox()
			v80 = currentCamera2.CFrame.Position - boundingBox.Position
			v79 = v87
			parent2.Text = KillFeed.weapon(classGuns[v78]) or classGuns[v78]
			v86.Text = v78 .. " / " .. #classGuns
			v81 = os.clock()
			v82 = p2
		end
		setGun(v78, 0)
		v81 = -10
		local function step(p: number) -- 1 equivalent call inferred from this helper
			if #classGuns > 1 then
				assert(MenuAudio.stamp, "[ArmoryStore] MenuAudio is not mounted")()
				setGun(v78 + p, p)
			end
		end
		v61 = step

		if #classGuns > 1 then
			for _, v87 in {
				{ "Prev", "<", -1 },
				{ "Next", ">", 1 }
			} do
				local textButton = Instance.new("TextButton")
				textButton.Name = v87[1]
				textButton.Text = ""
				textButton.AutoButtonColor = false
				textButton.BackgroundColor3 = Style.INK
				textButton.BackgroundTransparency = 0.2
				textButton.BorderSizePixel = 0
				textButton.AnchorPoint = Vector2.new(0.5, 0.5)
				textButton.Size = UDim2.fromOffset(48, 48)
				textButton.Position = UDim2.fromOffset(v63 / 2 + v87[3] * (v83 / 2 + 10 + 24), v70 / 2 + 14)
				textButton.ZIndex = 6
				textButton.Parent = fill2
				Style.corner(textButton, 8)
				Style.stroke(textButton, 2.5, 0, imageColor2, true)
				local v88 = text(textButton, "Glyph", v87[2], math.floor(v14 * 26), 0, 0, 48, 48, {
					outline = 2,
					ax = Enum.TextXAlignment.Center
				})
				v88.AutoLocalize = false
				v88.ZIndex = 7
				springy(textButton)
				textButton.Activated:Connect(function()
					step(v87[3]) -- inferred equivalent call
				end)
			end
		end

		local v87 = v64 - 14 - v71
		local parent4 = text(fill2, "Name", data2.name, maxTextSize, 14, v87, v63 - 28, maxTextSize + 6, {
			outline = 2.5,
			ax = Enum.TextXAlignment.Center
		})
		parent4.ZIndex = 6
		fit(parent4, maxTextSize) -- inferred equivalent call
		gradientText(parent4, Style.WHITE, imageColor2:Lerp(Style.WHITE, 0.35), Style.INK)
		local v89 = (v63 - 28 - 14) // 2
		local v90 = v87 + maxTextSize + 6
		local v91 = text(fill2, "Tier", tier.name, v67, 14, v90, v89, v67 + 6, {
			outline = 2,
			color = imageColor2:Lerp(Style.WHITE, 0.2),
			ax = Enum.TextXAlignment.Right
		})
		v91.AutoLocalize = true
		v91.ZIndex = 6

		if ownsCrate(data2.id) then -- inferred equivalent call
			local text_2 = text(fill2, "Owned", "OWNED", v67, v89 + 14 + 14, v90, v89, v67 + 6, {
				outline = 2,
				color = Style.GOOD
			})
			text_2.ZIndex = 6
		else
			local odds = Crates.odds
			local Players = game:GetService("Players")
			local v92 = 0

			for _, v93 in odds(ownsCrate, Players.LocalPlayer:GetAttribute("Level") or 1) do
				if v93.item == data2.id then
					v92 = v93.p
				end
			end

			local v93 = text(fill2, "Chance", Crates.percent(v92), v67, v89 + 14 + 14, v90, v89, v67 + 6, {
				outline = 2
			})
			v93.AutoLocalize = false
			v93.ZIndex = 6
		end

		local v92 = math.floor((math.min(v63 * 0.4, 320)))
		local v93 = artButton(fill2, "Close", v3.buy, (v63 - v92) / 2, v64 - 14 - v69, v92, v69)
		v93.ZIndex = 6
		local text_2 = text(v93, "Label", "CLOSE", math.floor(v14 * 18), 0, 0, v92, v69, {
			outline = 2,
			ax = Enum.TextXAlignment.Center
		})
		text_2.ZIndex = 7
		v93.Activated:Connect(closeSkin)
		local uiScale = Instance.new("UIScale")
		uiScale.Scale = 0.9
		uiScale.Parent = fill2
		local now = os.clock()
		Style.animate(crateSkin, function(_, p: number): boolean
			if v60 ~= crateSkin then
				return false
			end

			local v94 = p - now
			uiScale.Scale = 0.9 + 0.1 * Style.easeOut(v94 / 0.18)
			local v95 = math.sin(v94 * 0.9) * 0.9
			currentCamera2.CFrame = CFrame.lookAt(
				boundingBox.Position + CFrame.Angles(0, v95, 0):VectorToWorldSpace(v80),
				boundingBox.Position
			)
			v77.Rotation = v94 * 22
			v76.ImageTransparency = math.sin(v94 * 3) * 0.1 + 0.28

			local v96 = v79

			if v96 then
				local easeOut = Style.easeOut((math.clamp((p - v81) / 0.22, 0, 1)))
				v96.Position = UDim2.fromOffset(math.floor(v82 * (1 - easeOut) * v74 * 0.12), 0)
				v96.ImageTransparency = 1 - easeOut
			end

			return true
		end)
	end

	local function crateStock() -- 5 equivalent calls inferred from this helper
		return instance:GetAttribute(CareerData.STOCK_ATTR.crate) or 0
	end

	local function equipSkin(p: string, p2: string): string
		local gunsmith = ReplicatedStorage:FindFirstChild("Gunsmith")
		local remote = gunsmith and gunsmith:FindFirstChild("Remote")

		if not (remote and remote:IsA("RemoteFunction")) then
			return "COULD NOT EQUIP"
		end

		local v62 = carried(p2)

		if #v62 == 0 then
			v62 = WeaponSkins.classGuns(v58[p2])
		end

		local count = 0

		for _, v63 in v62 do
			if WeaponSkins.pick(instance, v63) == p then
				count += 1
			else
				local success, result = pcall(remote.InvokeServer, remote, "pick", v63, WeaponSkins.SLOT, p)

				if success and result == true then
					count += 1
				end
			end
		end

		return if count > 0 then "EQUIPPED" else "COULD NOT EQUIP"
	end

	local v62 = {}

	for k, v63 in Crates.TIERS do
		v62[v63.id] = k
	end

	local v63 = false
	local function openCrates(p: number)
		UiTrack.send("store_tap", "crateOpen" .. p)
		local v64 = crateStock() -- inferred equivalent call

		if v64 < 1 then
			fn3("NO CRATES LEFT")
			return
		end

		if v63 or CrateOpen.playing() then
			return
		end

		v63 = true
		local v65 = v53
		CrateOpen.warm(v65)
		local v66 = ownedCrateSkins()
		local career = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Remotes"):WaitForChild("Career")
		local success, result, v67 = pcall(
			career.InvokeServer,
			career,
			"openCrate",
			math.min(p, v64, Crates.MAX_OPEN),
			v65
		)

		if success and type(result) == "table" and #result > 0 then
			local playerGui = instance:WaitForChild("PlayerGui")

			local success2, result2 = pcall(CrateOpen.play, playerGui, result, v66, function()
				v63 = false
			end, function(p2: string)
				return equipSkin(p2, v65)
			end)

			if not success2 then
				v63 = false
				error("[ArmoryStore] " .. tostring(result2))
			end
		else
			v63 = false
			warn("[ArmoryStore] open crate: " .. tostring(result) .. " " .. tostring(v67))
			fn3((not success or type(v67) ~= "string") and "NO ANSWER, TRY AGAIN" or string.upper(v67))
		end
	end

	local flag2 = false
	function ArmoryStore.openBought(p: number)
		if flag2 then
			return
		end

		flag2 = true
		task.spawn(function()
			local success, result = pcall(function()
				local lastTime = os.clock()

				while crateStock() < p and os.clock() - lastTime < 10 do -- inferred equivalent call
					task.wait(0.1)
				end

				local v64 = math.min(p, crateStock()) -- inferred equivalent call

				while v64 > 0 and crateStock() > 0 do -- inferred equivalent call
					while v63 or CrateOpen.playing() or PurchaseShow.playing() do
						task.wait(0.1)
					end

					local v65 = math.min(v64, Crates.MAX_OPEN)
					openCrates(v65)
					v64 -= v65
					task.wait(0.2)
				end
			end)
			flag2 = false

			if not success then
				error("[ArmoryStore] " .. tostring(result), 0)
			end
		end)
	end

	local function crateInfo(p: number, total: number, p2: number, p3: number)
		local v64 = text(parent, "CrateInfo", "", math.floor(v14 * 18), p, total, p2, p3, {
			outline = 2,
			color = Style.HAZARD,
			ax = Enum.TextXAlignment.Right
		})
		v64.AutoLocalize = false
		local function draw() -- 2 equivalent calls inferred from this helper
			local crateCount, v65 = WeaponSkins.crateCount(instance, v53)
			v64.Text = string.format("%d/%d", crateCount, v65)
		end

		draw() -- inferred equivalent call
		table.insert(v56, draw)
		instance.AttributeChanged:Connect(function(value: string)
			if string.sub(value, 1, 3) == "Cs_" then
				draw() -- inferred equivalent call
			end
		end)
	end

	local function crateButtons(p: number, p2: number, p3: number, p4: number, p5: number, total: number, p6: number, p7: number)
		local v64 = artButton(parent, "OpenCrate", v3.buy, p, p2, p3, p4)
		local parent2 = text(v64, "Label", "", math.floor(v14 * 20), 8, 0, p3 - 16, p4, {
			outline = 2,
			ax = Enum.TextXAlignment.Center
		})
		fit(parent2, math.floor(v14 * 20)) -- inferred equivalent call

		local v66 = artButton(parent, "CrateOdds", v3.buyOff, p5, total, p6, p7)
		fit( -- inferred equivalent call
			text(v66, "Label", "SEE ODDS", math.floor(v14 * 18), 8, 0, p6 - 16, p7, {
				outline = 2,
				ax = Enum.TextXAlignment.Center
			}),
			math.floor(v14 * 18)
		)

		local function draw() -- 1 equivalent call inferred from this helper
			local v67 = crateStock() -- inferred equivalent call
			v64.Visible = v67 > 0
			parent2.Text = string.format("OPEN (x%d)", v67)
		end

		draw() -- inferred equivalent call
		instance:GetAttributeChangedSignal(CareerData.STOCK_ATTR.crate):Connect(draw)
		v64.Activated:Connect(function()
			openCrates(Crates.MAX_OPEN)
		end)
		v66.Activated:Connect(showOdds)
	end

	local v64 = nil
	local v65 = touch and 84 or 140
	local v66 = {
		K433 = "RIFLE",
		GX36 = "RIFLE",
		SK556 = "RIFLE",
		RN545 = "RIFLE",
		MX65 = "RIFLE",
		BT762 = "RIFLE",
		KP50 = "SMG",
		HM45 = "SMG",
		PD46 = "SMG",
		SP44 = "SMG",
		TK17 = "SMG",
		GV12 = "DMR",
		FS16 = "DMR",
		QS9 = "DMR",
		KR54 = "DMR",
		BX110 = "LMG",
		HX83 = "LMG",
		MG60 = "LMG",
		KT8 = "LMG",
		NX68 = "LMG",
		GR240 = "LMG",
		RX10 = "SNIPER",
		SC11 = "SNIPER",
		VX50 = "SNIPER",
		HandCannon = "PISTOL",
		SV20 = "PISTOL",
		ZK10 = "PISTOL",
		Molotov = "THROWABLE",
		Flamethrower = "FLAMER",
		Claymore = "THROWABLE",
		C4 = "THROWABLE"
	}

	local v67 = {
		{ id = "featured", label = "FEATURED" },
		{ id = "outfits", label = "OUTFITS" },
		{ id = "weapons", label = "WEAPONS" },
		{ id = "scrap", label = "SCRAP" },
		{ id = "boosts", label = "BOOSTS" }
	}

	local v68 = v and instance:GetAttribute(Crates.OFF_ATTR) == false

	if not v2 then
		table.remove(v67, 2)
		assert(v67[2].id == "weapons")
	end

	if v68 then
		table.insert(v67, v2 and 4 or 3, { id = "crates", label = "SUPPLY CRATES" })
	end

	local function salesIndex(p: string) -- 1 equivalent call inferred from this helper
		for k, v69 in v67 do
			if v69.id == p then
				return k
			end
		end

		error("[ArmoryStore] no section " .. p)
	end

	local top = data.top == true
	local v69 = touch and 52 or 56
	local v70 = offset2
	local v71 = nil
	local v72 = {}
	local v73 = {}
	local v74 = 0
	local v75 = false
	local frames = {}
	local v76 = {}

	local function markSales(p: number)
		if p == v74 then
			return
		end

		v74 = p

		for k, v77 in v73 do
			local visible = k == p
			local button = v77.button
			local backgroundColor

			if visible then
				backgroundColor = color
			else
				backgroundColor = Style.PANEL
			end

			button.BackgroundColor3 = backgroundColor
			local label = v77.label
			local textColor

			if visible then
				textColor = Style.HAZARD
			else
				textColor = Style.MUTED
			end

			label.TextColor3 = textColor
			v77.bar.Visible = visible
		end
	end

	local function showTab(p: number)
		markSales(p)

		for k, v77 in frames do
			v77.Visible = k == p
		end

		scroll.CanvasSize = UDim2.fromOffset(0, v76[p])
		scroll.CanvasPosition = Vector2.zero

		if data.reseat then
			data.reseat()
		end
	end

	local function salesFollow()
		if v75 or top then
			return
		end

		local v77 = scrollY() -- inferred equivalent call
		local v78 = scroll.CanvasSize.Y.Offset - v70 - 2
		local v79 = 1

		for k, v80 in v72 do
			if v80 <= v77 + 0.3 * v70 then
				v79 = k
			end
		end

		markSales(v78 <= v77 and #v72 or v79)
	end

	local function salesJump(k: number)
		if top then
			showTab(k)
			return
		end

		markSales(k)
		local v77 = math.min(v72[k], (math.max(0, scroll.CanvasSize.Y.Offset - v70)))

		if data.still then
			setScrollY(v77) -- inferred equivalent call
			return
		end

		local v78 = scrollY() -- inferred equivalent call
		local now = os.clock()
		v75 = true
		Style.animate(scroll, function(_, p: number): boolean
			local v79 = math.min((p - now) / 0.28, 1)
			setScrollY(v78 + (v77 - v78) * Style.easeOut(v79)) -- inferred equivalent call

			if v79 >= 1 then
				v75 = false
			end

			return v79 < 1
		end)
	end

	local function railPicture(parent2, id: string)
		if id == "weapons" then
			picture(parent2, "AssaultRifle") -- inferred equivalent call
		else
			local v77 = id == "featured" or id == "outfits"
			local image2

			if id == "featured" then
				image2 = v3.starter
			elseif id == "outfits" then
				image2 = CareerData.STORE.outfitPacks[1].image
			elseif id == "crates" then
				image2 = CareerData.STORE.crates[1].image
			elseif id == "scrap" then
				image2 = v3.pack.scrapL
			else
				image2 = v3.pack.xp120
			end

			local offset3 = parent2.Size.X.Offset
			local offset4 = parent2.Size.Y.Offset
			local pic = Instance.new("ImageLabel")
			pic.Name = "Pic"
			pic.BackgroundTransparency = 1
			pic.Image = image2
			pic.Size = UDim2.fromOffset(offset3, offset4)
			pic.Position = UDim2.fromOffset(0, 0)
			pic.Parent = parent2
			local scaleType

			if v77 then
				scaleType = Enum.ScaleType.Crop
			else
				scaleType = Enum.ScaleType.Fit
			end

			pic.ScaleType = scaleType

			if v77 then
				Style.corner(pic, 4)
			end
		end
	end

	local function buildSalesRail(parent2)
		local count = #v67

		if top then
			local v77 = v69 - 4
			local v78 = math.min(touch and 230 or 190, (math.floor((offset - 4 - (count - 1) * 8) / count)))
			local v79 = v77 - 12

			for k, v80 in v67 do
				local textButton = Instance.new("TextButton")
				textButton.Name = v80.id .. "Tab"
				textButton.Text = ""
				textButton.AutoButtonColor = false
				textButton.BorderSizePixel = 0
				textButton.BackgroundColor3 = Style.PANEL
				textButton.Size = UDim2.fromOffset(v78, v77)
				textButton.Position = UDim2.fromOffset(2 + (k - 1) * (v78 + 8), 2)
				textButton.Parent = parent2
				Style.corner(textButton, 4)
				Style.stroke(textButton, 2, 0, Style.INK, true)
				railPicture(Style.frame(textButton, "Icon", UDim2.fromOffset(v79, v79), UDim2.fromOffset(6, 6)), v80.id)
				local label = text(
					textButton,
					"Label",
					v80.label,
					math.floor(v14 * 15),
					v79 + 12,
					0,
					v78 - v79 - 16,
					v77,
					{ outline = 1.5, color = Style.MUTED }
				)
				fit(label, math.floor(v14 * 15)) -- inferred equivalent call

				local fill2 = Style.fill(
					textButton,
					"On",
					Style.HAZARD,
					UDim2.new(1, -12, 0, 4),
					UDim2.new(0, 6, 1, -5)
				)
				fill2.Visible = false
				springy(textButton, true)
				textButton.Activated:Connect(function()
					salesJump(k)
				end)
				v73[k] = { button = textButton, label = label, bar = fill2 }
			end
		else
			local v77 = v65 - 4
			local v78 = math.floor((offset2 - 8 - (count - 1) * 8) / count)
			local v79 = math.floor(v14 * 13) + 6

			for k, v80 in v67 do
				local textButton = Instance.new("TextButton")
				textButton.Name = v80.id .. "Rail"
				textButton.Text = ""
				textButton.AutoButtonColor = false
				textButton.BorderSizePixel = 0
				textButton.BackgroundColor3 = Style.PANEL
				textButton.Size = UDim2.fromOffset(v77, v78)
				textButton.Position = UDim2.fromOffset(4, 4 + (k - 1) * (v78 + 8))
				textButton.Parent = parent2
				Style.corner(textButton, 4)
				Style.stroke(textButton, 2, 0, Style.INK, true)

				railPicture(
					Style.frame(textButton, "Icon", UDim2.fromOffset(v77 - 12, v78 - v79 - 6), UDim2.fromOffset(6, 6)),
					v80.id
				)
				local label = text(textButton, "Label", v80.label, math.floor(v14 * 13), 0, v78 - v79 - 2, v77, v79, {
					outline = 1.5,
					ax = Enum.TextXAlignment.Center,
					color = Style.MUTED
				})
				local fill2 = Style.fill(
					textButton,
					"On",
					Style.HAZARD,
					UDim2.new(0, 4, 1, -12),
					UDim2.fromOffset(0, 6)
				)
				fill2.Visible = false
				springy(textButton, true)
				textButton.Activated:Connect(function()
					salesJump(k)
				end)
				v73[k] = { button = textButton, label = label, bar = fill2 }
			end
		end
	end

	local function weaponCard(data2, p: number, p2: number, p3: number, p4: number)
		local item = data2.item
		local robux = data2.robux
		local v77 = robux <= 99 and "blue" or robux <= 199 and "purple" or "gold"
		local parent2, v79, _, v80 = saleCard(parent, data2.id, v77, p, p2, p3, p4, true, true)
		local v81 = touch and 6 or 10
		local v82 = v47[v77]
		local v83 = math.floor(v14 * 12)

		local text_2 = text(parent2, "Family", v66[item] or "", v83, v81 + 2, 6, p3 - v81 * 2, v83 + 4, {
			outline = 1.5,
			color = v82[1]
		})
		text_2.ZIndex = 3
		local v84 = math.floor(v14 * 12)
		local maxTextSize = math.floor(v14 * 20)

		local v86 = v80 - v84 - 8
		local v87 = v86 - maxTextSize - 4

		local v88 = v83 + 6 + 6
		local v89 = v87 - v88 - 6
		local v90 = math.max(v81 + 4, (math.floor(p3 * 0.12)))

		local v91 = math.floor(p3 * 1.15)
		local imageLabel = image( -- inferred equivalent call
			parent2,
			"Glow",
			"rbxassetid://133718950618586",
			(p3 - v91) / 2,
			v88 + v89 / 2 - v91 * 0.35,
			v91,
			math.floor(v91 * 0.7)
		)
		imageLabel.ImageColor3 = v82[2]
		imageLabel.ImageTransparency = 0.35
		picture(Style.frame(parent2, "Gun", UDim2.fromOffset(p3 - v90 * 2, v89), UDim2.fromOffset(v90, v88)), item) -- inferred equivalent call

		local parent4 = text(parent2, "Name", data2.name, maxTextSize, v81, v87, p3 - v81 * 2, maxTextSize + 6, {
			outline = 2,
			ax = Enum.TextXAlignment.Center
		})
		fit(parent4, maxTextSize) -- inferred equivalent call
		gradientText(parent4, v82[1], v82[2], v82[3])
		local v94 = text(parent2, "Or", "", v84, v81, v86, p3 - v81 * 2, v84 + 4, {
			outline = 1.5,
			ax = Enum.TextXAlignment.Center,
			color = Style.MUTED
		})

		local v95 = math.max(14, (math.floor(v79.Size.Y.Offset * 0.58)))
		local v96 = text(v79, "Amount", "", v95 - 2, 0, 0, v79.Size.X.Offset, v79.Size.Y.Offset, {
			outline = 1.5,
			ax = Enum.TextXAlignment.Center,
			color = Style.GOOD
		})
		local robuxLine, v97 = Style.robuxLine(v79, "Line", v95)
		boldPrice(robuxLine)
		local function owned() -- 2 equivalent calls inferred from this helper
			return ShopData.owns(instance, item)
		end

		table.insert(v27, function()
			local v98 = owned() -- inferred equivalent call
			local v99 = priceOf(data2.productId, redrawProducts) or robux -- inferred equivalent call
			local image2

			if v98 then
				image2 = v3.buyOffShort
			else
				image2 = v3.buyShort
			end

			v79.Image = image2
			v96.Text = v98 and "OWNED" or ""
			robuxLine.Visible = not v98
			v97(nil, Style.thousands(v99), Style.WHITE)

			if v98 then
				v94.Text = ""
			elseif ShopData.unlocked(instance, item) then
				v94.Text = "OR " .. Style.thousands(ShopData.item(item).price) .. " SCRAP"
			else
				v94.Text = "OR REACH LEVEL " .. ShopData.unlockLevel(item)
			end
		end)
		local function press()
			UiTrack.send("store_tap", data2.id)

			if owned() then -- inferred equivalent call
				fn3("ALREADY OWNED")
				return
			end

			buySound() -- inferred equivalent call
			MarketplaceService:PromptProductPurchase(instance, data2.productId)
		end
		parent2.Activated:Connect(press)
		v79.Activated:Connect(press)
		return parent2
	end

	local function packWorth(data2)
		local total = 0

		for _, item in data2.items do
			local v77 = CareerData.unlockOf(item)
			assert(v77, "[ArmoryStore] pack " .. data2.id .. " has " .. item .. ", which no product sells")
			total += v77.robux
		end

		return total
	end

	local function weaponPackCard(data2, p: number, p2: number, p3: number, p4: number)
		local tier = data2.tier or "gold"
		local v77 = v47[tier]
		local textButton = Instance.new("TextButton")
		textButton.Name = data2.id
		textButton.Text = ""
		textButton.AutoButtonColor = false
		textButton.BackgroundTransparency = 1
		textButton.AnchorPoint = Vector2.new(0.5, 0.5)
		textButton.Size = UDim2.fromOffset(p3, p4)
		textButton.Position = UDim2.fromOffset(p + p3 / 2, p2 + p4 / 2)
		textButton.Parent = parent
		tierFill(textButton, tier, p3, p4)
		springy(textButton, true)
		local v78 = touch and 10 or 14
		local v79 = math.floor(v14 * 26)

		local parent2 = text(textButton, "Title", data2.name, v79, v78, v78 - 4, p3 - v78 * 2, v79 + 6, {
			outline = 2.5
		})
		gradientText(parent2, rgb(255, 246, 150), Style.HAZARD, Style.INK) -- inferred equivalent call
		shadow(parent2)
		local v81 = touch and 44 or 52
		local v82 = p4 - v81 - v78 + 3

		local v83 = v79 + 6 + 6
		local v84 = math.floor(p3 * 0.58)
		local v85 = v82 - (v79 + 6 + 6) - 4
		local imageLabel = image( -- inferred equivalent call
			textButton,
			"Glow",
			"rbxassetid://133718950618586",
			v78 - v84 * 0.15,
			v83 - v85 * 0.1,
			v84 * 1.3,
			v85 * 1.2
		)
		imageLabel.ImageColor3 = v77[2]
		imageLabel.ImageTransparency = 0.35
		local show = data2.show or data2.items
		local v87 = math.min(#show, 3)
		local v88 = math.floor(v85 * (v87 > 1 and 0.5 or 0.9))

		for i = 1, v87 do
			local v90

			if v87 > 1 then
				v90 = v83 + (i - 1) * (v85 - v88) / (v87 - 1)
			else
				v90 = v83 + (v85 - v88) / 2
			end

			local v91 = v78 + (not (v87 > 1) and 0 or (i - 1) % 2 * v84 * 0.08)
			local frame = Style.frame(
				textButton,
				"Gun" .. i,
				UDim2.fromOffset(v84 * 0.92, v88),
				UDim2.fromOffset(v91, v90)
			)
			frame.ZIndex = i + 1

			if StreakIcon.has(show[i]) then
				StreakIcon.voxel(show[i], frame)
			else
				picture(frame, show[i]) -- inferred equivalent call
			end
		end

		local v90 = v78 + v84 + 4
		local v91 = p3 - v90 - v78
		local v92 = math.floor(v14 * 17)
		local v93 = math.floor(v14 * 20) + 8

		local v94 = v82 - v93 - 4 - v83
		local v95 = math.min(v92 + 6, (math.floor(v94 / math.max(#data2.lines, 1))))

		for k, line in data2.lines do
			local v96 = v83 + (k - 1) * v95
			shadow(
				text(textButton, "Line" .. k, line, v92, v90 - 20, v96, v91 + 20, v95 - 2, {
					outline = 2,
					ax = Enum.TextXAlignment.Right
				}),
				2
			)
		end

		local v96 = packWorth(data2)
		local v97 = math.floor(p3 * 0.42)
		local v98 = p3 - v78 - v97 + 5
		local v99 = math.floor(v14 * 30)

		local parent4 = text(textButton, "Value", "", v99, v78, v82 + (v81 - v99 - 6) / 2, v98 - v78 - 4, v99 + 6, {
			outline = 2.5
		})

		local function valueText(p5: number) -- 2 equivalent calls inferred from this helper
			local v101 = v96 / p5

			if v101 >= 2 then
				return (string.format("%dX VALUE", (math.floor(v101))))
			end

			return (string.format("SAVE %d%%", (math.round((1 - p5 / v96) * 100))))
		end

		parent4.Text = valueText(data2.robux) -- inferred equivalent call

		gradientText(parent4, rgb(255, 248, 170), rgb(255, 170, 20), Style.INK) -- inferred equivalent call
		shadow(parent4)
		local v101 = artButton(textButton, "Buy", v3.buy, v98, v82, v97, v81)
		v101.Selectable = false
		local v102 = text(v101, "Owned", "OWNED", math.floor(v14 * 20), 0, 0, v97, v81, {
			color = Style.GOOD,
			ax = Enum.TextXAlignment.Center,
			outline = 1.5
		})
		local robuxLine, v103 = Style.robuxLine(v101, "Line", (math.floor(v14 * 22)))
		boldPrice(robuxLine)
		local v104 = oldPrice(textButton, v96, v98, v82 - v93, v97 - 14, math.floor(v14 * 20))
		local function allOwned(): boolean
			for _, item in data2.items do
				if not ShopData.owns(instance, item) then
					return false
				end
			end

			return true
		end

		table.insert(v27, function()
			local visible = allOwned()
			local v106

			if data2.productId == 0 then
				v106 = data2.robux
			else
				v106 = priceOf(data2.productId, redrawProducts) or data2.robux -- inferred equivalent call
			end

			local image2 = if visible then v3.buyOff else v3.buy
			v101.Image = image2
			v102.Visible = visible
			robuxLine.Visible = not visible
			v104.Visible = not visible
			parent4.Visible = not visible
			parent4.Text = valueText(v106) -- inferred equivalent call
			v103(nil, Style.thousands(v106), Style.WHITE)
		end)
		local function press()
			UiTrack.send("store_tap", data2.id)

			if allOwned() then
				fn3("ALREADY OWNED")
				return
			end

			if data2.productId == 0 then
				fn3("ON SALE SOON")
				return
			end

			buySound() -- inferred equivalent call
			MarketplaceService:PromptProductPurchase(instance, data2.productId)
		end
		textButton.Activated:Connect(press)
		v101.Activated:Connect(press)
		return textButton
	end

	local v77 = nil
	local v78 = nil
	local fn4 = nil
	local function itemOwned(data2)
		if data2.kind == "outfitBundle" then
			return instance:GetAttribute(Skins.ownsAttr(data2.skin)) == true
				and WeaponSkins.ownsCrate(instance, data2.camo)
		end

		for _, skin in data2.skins do
			if
				instance:GetAttribute(Skins.ownsAttr(skin)) ~= true
				or not WeaponSkins.ownsCrate(instance, WeaponSkins.bundleFor(skin).id)
			then
				return false
			end
		end

		return true
	end

	local function itemOnSale(p) -- 3 equivalent calls inferred from this helper
		return Skins.PAID_ON and p.productId ~= 0
	end

	local function itemPress(data2)
		UiTrack.send("store_tap", data2.id)

		if itemOwned(data2) then
			fn3("ALREADY OWNED")
			return
		end

		if not itemOnSale(data2) then -- inferred equivalent call
			fn3("COMING SOON")
			return
		end

		buySound() -- inferred equivalent call
		MarketplaceService:PromptProductPurchase(instance, data2.productId)
	end
	local function closeItem() -- 1 equivalent call inferred from this helper
		if v77 then
			v77:Destroy()
			v77 = nil
		end

		v78 = nil
		fn4 = nil
		v71.Visible = true

		if data.reseat then
			data.reseat()
		end
	end
	local function showItemPage(data2)
		if v77 then
			v77:Destroy()
		end

		v78 = data2
		v71.Visible = false
		local frame = Style.frame(self, "Item", UDim2.fromScale(1, 1))
		v77 = frame
		local v79 = math.floor(offset * (touch and 0.36 or 0.32))
		local button = plainButton( -- inferred equivalent call
			frame,
			"Back",
			"BACK",
			Style.STEEL,
			touch and 124 or 130,
			44,
			Style.WHITE,
			math.floor(v14 * 16)
		)
		button.Position = UDim2.fromOffset(4, 4)
		button.Activated:Connect(closeItem)
		local v81 = data2.kind == "outfitBundle" and 1.414 or 3
		local v82 = offset - v79 - 8 - 4
		local v83 = math.min(offset2 - 8, (math.floor(v82 / v81)))
		local imageLabel = image(frame, "Scene", data2.image, v79 + 8, math.floor((offset2 - v83) / 2), v82, v83) -- inferred equivalent call
		imageLabel.ScaleType = Enum.ScaleType.Crop
		Style.corner(imageLabel, 8)
		Style.stroke(imageLabel, 3, 0, Style.INK, true)
		local v85 = v79 - 4
		local v86 = 64

		local v87 = {}

		if data2.kind == "outfitBundle" then
			local outfit = CareerData.outfitOf(data2.skin)
			local v88 = WeaponSkins.find(data2.camo)
			v87 = {
				{ "OUTFIT", data2.name, not outfit and "" or outfit.blurb },
				{ "GUN SKIN", v88.name, v88.about or "" }
			}
		else
			for _, skin in data2.skins do
				local outfit = CareerData.outfitOf(skin)
				local v90 = if outfit then outfit.name else skin
				local v88 = { "OUTFIT + GUN SKIN", v90 .. " + " .. WeaponSkins.bundleFor(skin).name, "" }
				table.insert(v87, v88)
			end
		end

		local v88 = offset2 - 4 - ((touch and 44 or 52) + 8) - math.floor(v14 * 22) - 18
		local v89 = 1
		local v90, v91, v92, v93, v94, v95

		while true do
			v90 = math.floor(math.floor(v14 * 52) * v89)
			v91 = math.max(12, (math.floor(math.floor(v14 * 16) * v89)))
			v92 = math.floor(S(#v87 > 2 and 24 or 34) * v89) -- inferred equivalent call
			v93 = math.max(12, (math.floor(math.floor(v14 * 15) * v89)))
			v94 = math.max(12, (math.floor(math.floor(v14 * 22) * v89)))
			v95 = math.floor(v89 * 18)
			local v96 = v90 + 8 + v95 + v94 + 8

			for _, v97 in v87 do
				v96 += v91 + 4 + v92 + 6 + (v97[3] == "" and 0 or (v93 + 4) * 2) + v95
			end

			if v86 + v96 <= v88 or v89 <= 0.5 then
				break
			end

			v89 -= 0.1
		end

		local parent2 = text(frame, "Title", data2.name, v90, 4, v86, v85, v90 + 8, { outline = 3 })
		fit(parent2, v90) -- inferred equivalent call
		gradientText(parent2, rgb(255, 246, 150), Style.HAZARD, Style.INK) -- inferred equivalent call
		shadow(parent2)
		local v97 = v86 + (v90 + 8 + v95)

		for k, v98 in v87 do
			text(frame, "Kind" .. k, v98[1], v91, 4, v97, v85, v91 + 4, {
				outline = 1.5,
				color = Style.HAZARD
			})
			local v99 = v97 + (v91 + 4)
			fit(text(frame, "Name" .. k, v98[2], v92, 4, v99, v85, v92 + 6, { outline = 2.5 }), v92) -- inferred equivalent call

			local v100 = v99 + (v92 + 6)

			if v98[3] ~= "" then
				text(frame, "About" .. k, v98[3], v93, 4, v100, v85, (v93 + 4) * 2, {
					outline = 1.5,
					color = Style.MUTED,
					wrap = true,
					ay = Enum.TextYAlignment.Top
				})
				v100 += (v93 + 4) * 2
			end

			v97 = v100 + v95
		end

		text(frame, "Fits", "FITS EVERY GUN", v94, 4, v97, v85, v94 + 8, {
			outline = 2,
			color = rgb(150, 240, 165) -- inferred equivalent call
		})

		local v98 = (touch and 44 or 52) + 8
		local v99 = math.min(v85, 340)
		local v100 = artButton(frame, "Buy", v3.buy, -1, offset2 - v98 - 4, v99, v98)
		local v101 = text(v100, "State", "OWNED", math.floor(v14 * 22), 0, 0, v99, v98, {
			color = Style.GOOD,
			ax = Enum.TextXAlignment.Center,
			outline = 1.5
		})
		local robuxLine, v102 = Style.robuxLine(v100, "Line", (math.floor(v14 * 26)))
		boldPrice(robuxLine)
		local v103

		if data2.was then
			v103 = oldPrice(
				frame,
				data2.was,
				-1,
				offset2 - v98 - 4 - math.floor(v14 * 22) - 10,
				v99 - 14,
				math.floor(v14 * 22)
			)
		else
			v103 = nil
		end

		fn4 = function()
			local v104 = itemOwned(data2)
			local v105 = itemOnSale(data2) -- inferred equivalent call
			local v106

			if v105 then
				v106 = priceOf(data2.productId, redrawProducts) or data2.robux -- inferred equivalent call
			else
				v106 = data2.robux
			end

			local visible = v105 and not v104
			local image2 = if visible then v3.buy else v3.buyOff
			v100.Image = image2
			v101.Text = v104 and "OWNED" or "COMING SOON"
			local textColor = if v104 then Style.GOOD else Style.WHITE
			v101.TextColor3 = textColor
			v101.Visible = not visible
			robuxLine.Visible = visible

			if v103 then
				v103.Visible = visible
			end

			v102(nil, Style.thousands(v106), Style.WHITE)
		end
		fn4()
		v100.Activated:Connect(function()
			itemPress(data2)
		end)
		enter(frame, 0)

		if data.reseat then
			data.reseat()
		end
	end
	table.insert(v27, function()
		if fn4 then
			fn4()
		end
	end)

	local v79 = {
		bundleSkyRaider = rgb(214, 150, 84),
		bundleVenom = rgb(150, 255, 40),
		bundleInferno = rgb(255, 120, 30),
		bundleRevenant = rgb(170, 140, 255)
	}

	local function outfitBundleCard(outfitBundle, p: number, p2: number, p3: number, p4: number)
		local v80 = v79[outfitBundle.id]
		assert(v80, "[ArmoryStore] no colour for outfit bundle " .. tostring(outfitBundle.id))
		local textButton = Instance.new("TextButton")
		textButton.Name = outfitBundle.id
		textButton.Text = ""
		textButton.AutoButtonColor = false
		textButton.BorderSizePixel = 0
		textButton.BackgroundColor3 = Style.WHITE
		textButton.AnchorPoint = Vector2.new(0.5, 0.5)
		textButton.Size = UDim2.fromOffset(p3, p4)
		textButton.Position = UDim2.fromOffset(p + p3 / 2, p2 + p4 / 2)
		textButton.ClipsDescendants = true
		textButton.Parent = parent
		Style.corner(textButton, 6)
		Style.stroke(textButton, 3, 0, Style.INK, true)
		local uiGradient = Instance.new("UIGradient")
		uiGradient.Color = ColorSequence.new(Color3.fromRGB(12, 13, 16):Lerp(v80, 0.3), Color3.fromRGB(12, 13, 16))
		uiGradient.Parent = textButton
		springy(textButton, true)

		local imageLabel = image(textButton, "Scene", outfitBundle.image, 0, 0, p3, p4) -- inferred equivalent call
		imageLabel.ScaleType = Enum.ScaleType.Crop
		Style.corner(imageLabel, 6)
		local v82 = touch and 10 or 16
		local v83 = touch and 44 or 50
		local v84 = touch and 150 or 210
		local maxTextSize = math.floor(v14 * 40)
		local maxTextSize2 = math.floor(v14 * 21)
		local maxTextSize3 = math.floor(v14 * 15)

		local v88 = (maxTextSize3 + 6) * 2
		local v89 = math.max(v88, v83) + v82 * 2
		local v90 = v82 + maxTextSize + 4 + maxTextSize2 + 8 + v82
		local topScrim = Instance.new("Frame")
		topScrim.Name = "TopScrim"
		topScrim.BorderSizePixel = 0
		topScrim.BackgroundColor3 = Color3.fromRGB(8, 9, 12):Lerp(v80, 0.08)
		topScrim.Size = UDim2.fromOffset(p3, (math.floor(v90 * 1.6)))
		topScrim.Parent = textButton
		local uiGradient2 = Instance.new("UIGradient")
		uiGradient2.Rotation = 90
		uiGradient2.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.1),
			NumberSequenceKeypoint.new(0.55, 0.4),
			NumberSequenceKeypoint.new(1, 1)
		})

		uiGradient2.Parent = topScrim
		local scrim = Instance.new("Frame")
		scrim.Name = "Scrim"
		scrim.BorderSizePixel = 0
		scrim.BackgroundColor3 = Color3.fromRGB(8, 9, 12):Lerp(v80, 0.08)
		scrim.Size = UDim2.fromOffset(p3, v89 * 2)
		scrim.Position = UDim2.fromOffset(0, p4 - v89 * 2)
		scrim.Parent = textButton
		local uiGradient3 = Instance.new("UIGradient")
		uiGradient3.Rotation = 90
		uiGradient3.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 0.25),
			NumberSequenceKeypoint.new(1, 0.05)
		})

		uiGradient3.Parent = scrim

		local v91 = p3 - v84 - v82 * 3
		local parent2 = text(
			textButton,
			"Title",
			outfitBundle.name,
			maxTextSize,
			v82,
			v82,
			p3 - v82 * 2,
			maxTextSize + 4,
			{ outline = 3 }
		)
		fit(parent2, maxTextSize) -- inferred equivalent call
		gradientText(parent2, rgb(255, 246, 150), Style.HAZARD, Style.INK) -- inferred equivalent call
		shadow(parent2)
		local parent4 = text(
			textButton,
			"Holds",
			"OUTFIT + GUN SKIN",
			maxTextSize2,
			v82,
			v82 + maxTextSize + 4,
			p3 - v82 * 2,
			maxTextSize2 + 8,
			{ outline = 2.5, color = v80:Lerp(Style.WHITE, 0.55) }
		)
		fit(parent4, maxTextSize2) -- inferred equivalent call
		shadow(parent4)
		local v94 = p4 - v89 + v82 + math.floor((v89 - v82 * 2 - v88) / 2)
		local v95 = touch and 72 or 86
		text(textButton, "Kind", "GUN SKIN", maxTextSize3, v82, v94, v95, maxTextSize3 + 6, {
			outline = 1.5,
			color = v80:Lerp(Style.WHITE, 0.45)
		})
		fit( -- inferred equivalent call
			text(
				textButton,
				"Name",
				WeaponSkins.find(outfitBundle.camo).name,
				maxTextSize3,
				v82 + v95,
				v94,
				v91 - v95,
				maxTextSize3 + 6,
				{ outline = 1.5 }
			),
			maxTextSize3
		)

		fit( -- inferred equivalent call
			text(
				textButton,
				"Fits",
				"FITS EVERY GUN",
				maxTextSize3,
				v82,
				v94 + maxTextSize3 + 6,
				v91,
				maxTextSize3 + 6,
				{ outline = 1.5, color = rgb(150, 240, 165) } -- inferred equivalent call
			),
			maxTextSize3
		)

		local v96 = artButton(
			textButton,
			"Buy",
			v3.buyShort,
			p3 - v84 - v82,
			p4 - v89 + math.floor((v89 - v83) / 2),
			v84,
			v83
		)
		v96.Selectable = false
		local v97 = text(v96, "State", "OWNED", math.floor(v14 * 15), 0, 0, v84, v83, {
			color = Style.GOOD,
			ax = Enum.TextXAlignment.Center,
			outline = 1.5
		})
		local robuxLine, v98 = Style.robuxLine(v96, "Line", (math.floor(v14 * 20)))
		boldPrice(robuxLine)
		local v99

		if outfitBundle.was then
			v99 = oldPrice(
				textButton,
				outfitBundle.was,
				p3 - v84 - v82,
				p4 - v89 + math.floor((v89 - v83) / 2) - math.floor(v14 * 16) - 10,
				v84 - 8,
				math.floor(v14 * 16)
			)
		else
			v99 = nil
		end

		table.insert(v27, function()
			local v100 = itemOwned(outfitBundle)
			local v101 = itemOnSale(outfitBundle) -- inferred equivalent call
			local v102

			if v101 then
				v102 = priceOf(outfitBundle.productId, redrawProducts) or outfitBundle.robux -- inferred equivalent call
			else
				v102 = outfitBundle.robux
			end

			local visible = v101 and not v100
			local image2

			if visible then
				image2 = v3.buyShort
			else
				image2 = v3.buyOffShort
			end

			v96.Image = image2
			v97.Text = v100 and "OWNED" or "COMING SOON"
			local textColor

			if v100 then
				textColor = Style.GOOD
			else
				textColor = Style.WHITE
			end

			v97.TextColor3 = textColor
			v97.Visible = not visible
			robuxLine.Visible = visible

			if v99 then
				v99.Visible = visible
			end

			v98(nil, Style.thousands(v102), Style.WHITE)
		end)
		local function press()
			UiTrack.send("store_tap", outfitBundle.id)
			showItemPage(outfitBundle)
		end
		textButton.Activated:Connect(press)
		v96.Activated:Connect(press)
		return textButton
	end

	local function outfitPackWorth(data2)
		local total = 0

		for _, skin in data2.skins do
			local v80 = nil

			for _, outfitBundle in CareerData.STORE.outfitBundles do
				if outfitBundle.skin == skin then
					v80 = outfitBundle
				end
			end

			assert(v80, "[ArmoryStore] pack " .. data2.id .. " has " .. skin .. ", which no bundle sells")
			total += v80.robux
		end

		return total
	end

	local function outfitPackCard(data2, p: number, total: number, p2: number, p3: number)
		local textButton = Instance.new("TextButton")
		textButton.Name = data2.id
		textButton.Text = ""
		textButton.AutoButtonColor = false
		textButton.BackgroundTransparency = 1
		textButton.AnchorPoint = Vector2.new(0.5, 0.5)
		textButton.Size = UDim2.fromOffset(p2, p3)
		textButton.Position = UDim2.fromOffset(p + p2 / 2, total + p3 / 2)
		textButton.ClipsDescendants = true
		textButton.Parent = parent
		local imageLabel = image(textButton, "Scene", data2.image, 0, 0, p2, p3) -- inferred equivalent call
		imageLabel.ScaleType = Enum.ScaleType.Crop
		Style.corner(imageLabel, 6)
		Style.stroke(imageLabel, 3, 0, Style.INK, true)
		springy(textButton, true)
		local v81 = touch and 10 or 14
		local v82 = math.floor(p2 * 0.36)
		local v83 = math.floor(v14 * 28)

		local parent2 = text(textButton, "Title", data2.name, v83, v81, v81 - 4, v82 + 60, v83 + 6, {
			outline = 2.5
		})
		gradientText(parent2, rgb(255, 246, 150), Style.HAZARD, Style.INK) -- inferred equivalent call
		shadow(parent2)

		local v85 = v81 - 4 + v83 + 6
		local v86 = math.floor(v14 * 15)

		text(
			textButton,
			"Count",
			string.format("%d OUTFITS + %d GUN SKINS", #data2.skins, #data2.skins),
			v86,
			v81,
			v85,
			v82 + 60,
			v86 + 6,
			{ outline = 2, color = rgb(150, 240, 165) } -- inferred equivalent call
		)
		local v87 = math.floor(v14 * 14)

		local v88 = v85 + v86 + 10
		local v89 = math.floor(v82 / 2)

		for k, name in data2.skins do
			local outfit = CareerData.outfitOf(name)
			local v90 = (k - 1) % 2
			local v91 = (k - 1) // 2
			local v92 = "Name" .. k

			if outfit then
				name = outfit.name
			end

			text(textButton, v92, name, v87, v81 + v90 * v89, v88 + v91 * (v87 + 6), v89 - 4, v87 + 6, {
				outline = 2
			})
		end

		local v90 = outfitPackWorth(data2)
		local v91 = touch and 44 or 52
		local v92 = p3 - v91 - v81 + 3

		local v93 = v81 - 5
		local v94 = artButton(textButton, "Buy", v3.buy, v93, v92, v82, v91)
		v94.Selectable = false
		local v95 = text(v94, "State", "OWNED", math.floor(v14 * 20), 0, 0, v82, v91, {
			color = Style.GOOD,
			ax = Enum.TextXAlignment.Center,
			outline = 1.5
		})
		local robuxLine, v96 = Style.robuxLine(v94, "Line", (math.floor(v14 * 22)))
		boldPrice(robuxLine)
		local v97 = math.floor(v14 * 20) + 8
		local v98 = oldPrice(textButton, v90, v93, v92 - v97, v82 - 14, math.floor(v14 * 20))
		local v99 = math.floor(v14 * 20)

		local parent4 = text(
			textButton,
			"Save",
			"",
			v99,
			v81,
			v92 - v97 + (v97 - v99 - 6) / 2,
			math.floor(v82 * 0.55),
			v99 + 6,
			{ outline = 2.5 }
		)
		gradientText(parent4, rgb(255, 248, 170), rgb(255, 170, 20), Style.INK) -- inferred equivalent call
		shadow(parent4)
		local function allOwned() -- 2 equivalent calls inferred from this helper
			return itemOwned(data2)
		end

		local function onSale() -- 2 equivalent calls inferred from this helper
			return Skins.PAID_ON and data2.productId ~= 0
		end

		table.insert(v27, function()
			local v101 = allOwned() -- inferred equivalent call
			local v102 = onSale() -- inferred equivalent call
			local v103

			if v102 then
				v103 = priceOf(data2.productId, redrawProducts) or data2.robux -- inferred equivalent call
			else
				v103 = data2.robux
			end

			local visible = v102 and not v101
			local image2 = if visible then v3.buy else v3.buyOff
			v94.Image = image2
			v95.Text = v101 and "OWNED" or "COMING SOON"
			local textColor

			if v101 then
				textColor = Style.GOOD
			else
				textColor = Style.WHITE
			end

			v95.TextColor3 = textColor
			v95.Visible = not visible
			robuxLine.Visible = visible
			v98.Visible = visible
			parent4.Visible = visible
			parent4.Text = string.format("SAVE %d%%", (math.round((1 - v103 / v90) * 100)))
			v96(nil, Style.thousands(v103), Style.WHITE)
		end)
		local function press()
			UiTrack.send("store_tap", data2.id)

			if allOwned() then -- inferred equivalent call
				fn3("ALREADY OWNED")
				return
			end

			if not onSale() then -- inferred equivalent call
				fn3("COMING SOON")
				return
			end

			buySound() -- inferred equivalent call
			MarketplaceService:PromptProductPurchase(instance, data2.productId)
		end
		textButton.Activated:Connect(function()
			UiTrack.send("store_tap", data2.id)
			showItemPage(data2)
		end)
		v94.Activated:Connect(press)
		return textButton
	end

	local function packsOnSale()
		local result = {}

		for _, v80 in CareerData.STORE.weaponPacks or v4 do
			if v80.productId ~= 0 or data.still then
				table.insert(result, v80)
			end
		end

		return result
	end

	local function weaponsOnSale()
		local result = {}

		for _, v80 in CareerData.STORE.instant do
			if v80.productId ~= 0 then
				table.insert(result, v80)
			end
		end

		table.sort(result, function(a, b)
			local owns = ShopData.owns(instance, a.item)
			local owns2 = ShopData.owns(instance, b.item)

			if owns == owns2 then
				return ShopData.unlockLevel(a.item) < ShopData.unlockLevel(b.item)
			end

			return owns2
		end)

		return result
	end

	local function legendaryOnSale()
		local result = {}

		for _, v80 in CareerData.STORE.instant do
			if v80.productId == 0 or not (v80.robux > 199) or ShopData.owns(instance, v80.item) then
				continue
			end

			table.insert(result, v80)
		end

		table.sort(result, function(a, b): boolean
			return a.robux > b.robux
		end)

		while #result > 2 do
			table.remove(result)
		end

		return result
	end

	local function buildSoon()
		local frame = Style.frame(self, "Soon", UDim2.fromScale(1, 1))
		v71 = frame
		buildSalesRail(frame)
		local v80 = top and 0 or v65 + 8
		local v81 = not top and 0 or v69 + 8
		v70 = offset2 - v81
		local v82 = offset - v80
		scroll = Instance.new("ScrollingFrame")
		scroll.Name = "Scroll"
		scroll.BackgroundTransparency = 1
		scroll.BorderSizePixel = 0
		scroll.ScrollBarThickness = 6
		scroll.ScrollBarImageColor3 = Style.HAZARD
		scroll.ScrollingDirection = Enum.ScrollingDirection.Y
		scroll.Size = UDim2.fromOffset(v82, v70)
		scroll.Position = UDim2.fromOffset(v80, v81)
		scroll.Parent = frame
		parent = scroll
		local v83 = v82 - 6
		local v84 = v83 - 8
		local v85 = math.floor((v84 - 16) / 3)
		local v86 = v83 - v85 - 4
		local v87 = v86 - 4 - 8
		local total = 4

		local function tab(p: string)
			local k = salesIndex(p) -- inferred equivalent call

			if top then
				if k > 1 then
					assert(frames[k - 1], "[ArmoryStore] sections built out of SALES' order at " .. p)
					v76[k - 1] = total + 4
					frames[k - 1].Size = UDim2.fromOffset(v83, total + 4)
				end

				local frame2 = Style.frame(scroll, p .. "Page", UDim2.fromOffset(v83, 0))
				frame2.Visible = false
				frames[k] = frame2
				parent = frame2
				total = 4
			else
				if k > 1 then
					total += 16
				end

				v72[k] = k == 1 and 0 or total
			end
		end
		tab("featured")

		local function outfitPackRows(flag3: boolean)
			for _, v88 in CareerData.STORE.outfitPacks or {} do
				if not flag3 then
					total += 8
				end

				local v89 = math.min(v17, (math.floor(v84 / 3)))
				outfitPackCard(v88, 4, total, v84, v89)
				total += v89

				if flag3 then
					total += 8
				end
			end
		end

		if v2 then
			outfitPackRows(true)
		end

		v64 = starterCard(4, total, v87, v17)
		soonFree(v86, total, v85, v17)
		total += v17

		if not v2 then
			outfitPackRows(false)
		end

		local v88 = touch and 4 or 5
		local v89 = math.floor((v84 - (v88 - 1) * 8) / v88)
		local v90 = touch and 176 or 220
		local v91 = packsOnSale()
		local v92 = touch and 2 or 3
		local v93 = math.floor((v84 - (v92 - 1) * 8) / v92)
		local v94 = touch and 196 or 240

		if #v91 > 0 then
			total += 8

			for k, v95 in v91 do
				local v96 = (k - 1) % v92
				local v97 = (k - 1) // v92
				weaponPackCard(v95, v96 * (v93 + 8) + 4, total + v97 * (v94 + 8), v93, v94)
			end

			total += math.ceil(#v91 / v92) * (v94 + 8) - 8
		end

		local v95 = legendaryOnSale()

		if #v95 > 0 then
			total += 8
			local v96 = math.floor((v84 - (#v95 - 1) * 8) / #v95)

			for k, v97 in v95 do
				weaponCard(v97, (k - 1) * (v96 + 8) + 4, total, v96, v90)
			end

			total += v90
		end

		if v2 then
			local outfitBundles = CareerData.STORE.outfitBundles
			tab("outfits")

			if not top then
				text(parent, "outfitsHeading", "OUTFITS", math.floor(v14 * 20), 4, total, v84, v18, {
					outline = 2
				})
				total += v18
			end

			local v96 = math.floor((v84 - 8) / 2)
			local v97 = math.min(math.floor(v96 / 1.414), v70 - 8)

			for k, outfitBundle in outfitBundles do
				local v98 = (k - 1) % 2
				local v99 = (k - 1) // 2
				outfitBundleCard(outfitBundle, 4 + v98 * (v96 + 8), total + v99 * (v97 + 8), v96, v97)
			end

			total += math.ceil(#outfitBundles / 2) * (v97 + 8) - 8
		end

		tab("weapons")

		if not top then
			text(parent, "weaponsHeading", "WEAPONS", math.floor(v14 * 20), 4, total, v84, v18, {
				outline = 2
			})
			total += v18
		end

		local v96 = weaponsOnSale()

		if v2 then
			local total2 = 0

			for k, v97 in {
				{
					"RIFLES",
					{ "RIFLE" }
				},
				{
					"SMGS",
					{ "SMG" }
				},
				{
					"DMRS",
					{ "DMR" }
				},
				{
					"SNIPERS",
					{ "SNIPER" }
				},
				{
					"LMGS",
					{ "LMG" }
				},
				{
					"PISTOLS",
					{ "PISTOL" }
				},
				{
					"SPECIAL",
					{ "THROWABLE", "FLAMER" }
				}
			} do
				local v98 = {}

				for _, v99 in v96 do
					if table.find(v97[2], v66[v99.item]) then
						table.insert(v98, v99)
					end
				end

				if not (#v98 > 0) then
					continue
				end

				if total2 > 0 then
					total += 16
				end

				Style.fill(
					parent,
					"Group" .. k .. "Bar",
					Style.HAZARD,
					UDim2.fromOffset(4, (math.floor(v14 * 18))),
					UDim2.fromOffset(4, total + (v18 - math.floor(v14 * 18)) // 2)
				)
				local v99 = parent
				local v100 = "Group" .. k
				local v101 = v97[1]
				local v102 = math.floor(v14 * 18)

				local v103 = total
				text(v99, v100, v101, v102, 16, v103, v84 - 12, v18, { outline = 2 })
				total += v18

				for k2, v104 in v98 do
					local v105 = (k2 - 1) % v88
					local v106 = (k2 - 1) // v88
					weaponCard(v104, 4 + v105 * (v89 + 8), total + v106 * (v90 + 8), v89, v90)
				end

				total += math.ceil(#v98 / v88) * (v90 + 8) - 8
				total2 += #v98
			end

			assert(total2 == #v96, "[ArmoryStore] a gun on sale has no category in FAMILY")
		else
			for k, v97 in v96 do
				local v98 = (k - 1) % v88
				local v99 = (k - 1) // v88
				weaponCard(v97, v98 * (v89 + 8) + 4, total + v99 * (v90 + 8), v89, v90)
			end

			total += math.ceil(#v96 / v88) * (v90 + 8) - 8
		end

		if v68 then
			tab("crates")
			local crates = CareerData.STORE.crates

			local gold = v47.gold
			local v97 = touch and 2 or 3
			local v98 = touch and 8 or 10
			local v99 = touch and 64 or 84
			local v100 = math.floor(v14 * 15) + 4

			local v101 = v98 + v99 + 4 + v100 + 44 + v98
			local v102 = math.floor((v84 - (v97 - 1) * 8) / v97)
			local v103 = math.floor((v102 - v98 * 2 - (#crates - 1) * 6) / #crates)
			local count = 0
			local v104 = {}
			local drawBuys = {}

			for _, class in Crates.CLASSES do
				if v52[class.id] then
					continue
				end

				local v105 = count % v97
				local v106 = count // v97
				count += 1
				local textButton = Instance.new("TextButton")
				textButton.Name = "Crate" .. class.id
				textButton.Text = ""
				textButton.AutoButtonColor = false
				textButton.BackgroundTransparency = 1
				textButton.AnchorPoint = Vector2.new(0.5, 0.5)
				textButton.Size = UDim2.fromOffset(v102, v101)
				textButton.Position = UDim2.fromOffset(
					v105 * (v102 + 8) + 4 + v102 / 2,
					total + v106 * (v101 + 8) + v101 / 2
				)
				textButton.Parent = parent
				tierFill(textButton, "navy", v102, v101)
				springy(textButton, true)
				local frame2 = Style.frame(
					textButton,
					"Mark",
					UDim2.fromOffset(v102 - 6, v101 - 6),
					UDim2.fromOffset(3, 3)
				)
				Style.corner(frame2, 6)
				Style.stroke(frame2, 3, 0, Style.HAZARD, true)
				local imageLabel = image( -- inferred equivalent call
					textButton,
					"Glow",
					"rbxassetid://133718950618586",
					v98 - v99 * 0.25,
					v98 - v99 * 0.25,
					v99 * 1.5,
					v99 * 1.5
				)
				imageLabel.ImageColor3 = gold[2]
				imageLabel.ImageTransparency = 0.6
				local imageLabel2 = image( -- inferred equivalent call
					textButton,
					"Art",
					assert((v3.crate[class.id] or {})[1], "[ArmoryStore] no crate picture for " .. class.id),
					v98,
					v98,
					v99,
					v99
				)

				imageLabel2.ScaleType = Enum.ScaleType.Fit
				local maxTextSize = math.floor(v14 * 20)
				local v110 = math.floor(v14 * 15)

				local v111 = v98 + v99 + v98
				local v112 = v102 - v111 - v98
				local v113 = v98 + math.floor((v99 - (maxTextSize + 6 + v110 + 6)) / 2)
				local parent2 = text(textButton, "Name", class.name, maxTextSize, v111, v113, v112, maxTextSize + 6, {
					outline = 2
				})
				fit(parent2, maxTextSize) -- inferred equivalent call
				gradientText(parent2, gold[1], gold[2], gold[3])
				local count2 = text(textButton, "Count", "", v110, v111, v113 + maxTextSize + 6, v112, v110 + 6, {
					outline = 1.5,
					color = Style.HAZARD
				})
				count2.AutoLocalize = false
				v104[class.id] = { bar = frame2, count = count2 }
				textButton.Activated:Connect(function()
					pickCrate(class.id)
				end)
				local function collected(): boolean -- 2 equivalent calls inferred from this helper
					if Crates.REPEATS then
						return false
					end

					local crateCount, v116 = WeaponSkins.crateCount(instance, class.id)
					return v116 <= crateCount
				end

				for k, crate in crates do
					local v116 = v98 + (k - 1) * (v103 + 6)
					local v117 = v98 + v99 + 4
					local v118 = v47[v48[math.min(k, #v48)]]
					local parent4 = text(
						textButton,
						"Qty" .. k,
						crate.big,
						math.floor(v14 * 15),
						v116,
						v117,
						v103,
						v100,
						{ outline = 2, ax = Enum.TextXAlignment.Center }
					)
					fit(parent4, math.floor(v14 * 15)) -- inferred equivalent call

					gradientText(parent4, v118[1], v118[2], v118[3])
					local v120 = artButton(textButton, "Buy" .. k, v3.buyShort, v116, v117 + v100, v103, 44)

					v120.ScaleType = Enum.ScaleType.Slice
					v120.SliceCenter = Rect.new(40, 0, 260, 112)
					v120.SliceScale = 11 / 28
					local robuxLine, v121 = Style.robuxLine(v120, "Line", (math.floor(v14 * 17)))
					boldPrice(robuxLine)
					local v122 = crate

					local function drawBuy()
						local visible

						if v122.productId == 0 then
							visible = false
						else
							visible = not collected() -- inferred equivalent call
						end

						local v124

						if visible then
							v124 = priceOf(v122.productId, redrawProducts) or v122.robux -- inferred equivalent call
						end

						local image2

						if visible then
							image2 = v3.buyShort
						else
							image2 = v3.buyOffShort
						end

						v120.Image = image2
						robuxLine.Visible = visible
						v121(nil, not v124 and "..." or Style.thousands(v124), Style.WHITE)
					end
					drawBuy()
					table.insert(v27, drawBuy)
					table.insert(drawBuys, drawBuy)
					local v123 = crate
					v120.Activated:Connect(function()
						UiTrack.send("store_tap", v123.id)

						if collected() then -- inferred equivalent call
							fn3("YOU OWN EVERY SKIN IN THIS CRATE")
							return
						end

						if v123.productId == 0 then
							fn3("NOT ON SALE YET")
							return
						end

						pickCrate(class.id)
						CrateOpen.warm(class.id)
						buySound() -- inferred equivalent call
						MarketplaceService:PromptProductPurchase(instance, v123.productId)
					end)
				end
			end

			total += math.ceil(count / v97) * (v101 + 8)

			local v105 = math.min(math.floor(v84 / #crates), (touch and 96 or 150) + 55)
			local count2 = 0

			for i = #crates, 1, -1 do
				local crate = crates[i]

				if not CareerData.giftOf(crate.id) then
					continue
				end

				count2 += 1
				local v106 = 4 + v84 - count2 * v105
				artButton(parent, "CrateGift" .. i, v3.gift, v106, total, 55, 44).Activated:Connect(function()
					giftTap(crate.id)
				end)
				local v107 = parent
				local v108 = "CrateGiftWords" .. i
				local big = crate.big
				local v109 = math.floor(v14 * 15)

				local v110 = v106 + 55 + 6
				local v111 = total
				fit(text(v107, v108, big, v109, v110, v111, v105 - 55 - 12, 44, { outline = 2 }), math.floor(v14 * 15)) -- inferred equivalent call
			end

			if count2 > 0 then
				total += 52
			end

			local function drawCounts()
				for k, v106 in v104 do
					local crateCount, v107 = WeaponSkins.crateCount(instance, k)
					v106.count.Text = string.format("%d/%d", crateCount, v107)
					local count3 = v106.count
					local textColor

					if v107 <= crateCount then
						textColor = Style.GOOD
					else
						textColor = Style.HAZARD
					end

					count3.TextColor3 = textColor
				end

				for _, v106 in drawBuys do
					v106()
				end
			end
			drawCounts()
			instance.AttributeChanged:Connect(function(value: string)
				if string.sub(value, 1, 3) == "Cs_" then
					drawCounts()
				end
			end)
			total += 8
			local maxTextSize = math.floor(v14 * 26)
			local maxTextSize2 = math.floor(v14 * 14)
			local v108 = touch and 150 or 220
			local v109 = touch and 44 or 52
			local v110 = math.max(maxTextSize + 6 + maxTextSize2 + 6, v109)
			local v111 = total
			local v112 = total
			local parent2 = text(parent, "CrateName", "", maxTextSize, 4, v112, v84 - v108 - 8, maxTextSize + 6, {
				outline = 2.5
			})
			fit(parent2, maxTextSize) -- inferred equivalent call
			gradientText(parent2, gold[1], gold[2], gold[3])
			local parent4 = text(
				parent,
				"CrateGuns",
				"",
				maxTextSize2,
				4,
				total + maxTextSize + 6,
				v84 - v108 - 8,
				maxTextSize2 + 6,
				{ outline = 1.5, color = Style.MUTED }
			)
			fit(parent4, maxTextSize2) -- inferred equivalent call

			local function drawPicked() -- 1 equivalent call inferred from this helper
				local class = Crates.classOf(v53)
				parent2.Text = class.name
				parent4.Text = class.guns

				for k, v115 in v104 do
					v115.bar.Visible = k == v53
				end
			end

			drawPicked() -- inferred equivalent call
			table.insert(v56, drawPicked)
			total += v110 + 8

			total += 8
			local v115 = touch and 132 or 180
			local v116 = math.max(44, v18)
			local v117 = math.floor(v14 * 18) * 4
			Style.fill(
				parent,
				"CrateSkinsBar",
				Style.HAZARD,
				UDim2.fromOffset(4, (math.floor(v14 * 18))),
				UDim2.fromOffset(4, total + (v116 - math.floor(v14 * 18)) // 2)
			)
			local v118 = parent
			local v119 = math.floor(v14 * 18)

			local v120 = total
			text(v118, "CrateSkinsHeading", "CRATE SKINS", v119, 16, v120, v84 - v115 - v117 - 36, v116, {
				outline = 2
			})
			crateInfo(4 + v84 - v115 - 12 - v117, total, v117, v116)
			crateButtons(4 + v84 - v108, v111 + (v110 - v109) // 2, v108, v109, 4 + v84 - v115, total, v115, v116)
			total += v116 + 8
			local v121 = touch and 3 or 4
			local v122 = math.floor((v84 - (v121 - 1) * 8) / v121)
			local maxTextSize3 = math.floor(v14 * 17)
			local maxTextSize4 = math.floor(v14 * 13)

			local v125 = maxTextSize3 + 16
			local v126 = {}

			for k, v127 in WeaponSkins.CRATE do
				local tier = Crates.tierOf(v127.crate)
				local v128 = (k - 1) % v121
				local v129 = (k - 1) // v121
				local v130 = vivid(tier.color) -- inferred equivalent call
				local textButton = Instance.new("TextButton")
				textButton.Name = "Skin" .. v127.id
				textButton.Text = ""
				textButton.AutoButtonColor = false
				textButton.BackgroundColor3 = Style.INK
				textButton.BorderSizePixel = 0
				textButton.AnchorPoint = Vector2.new(0.5, 0.5)
				textButton.Size = UDim2.fromOffset(v122, v122)
				textButton.Position = UDim2.fromOffset(
					4 + v128 * (v122 + 8) + v122 / 2,
					total + v129 * (v122 + 8) + v122 / 2
				)
				textButton.Parent = parent
				Style.corner(textButton, 8)
				Style.stroke(textButton, 3, 0, Style.INK, true)
				springy(textButton, true)
				textButton.Activated:Connect(function()
					showSkin(v127)
				end)
				local imageLabel = image(textButton, "Tile", v127.image, 0, 0, v122, v122) -- inferred equivalent call
				imageLabel.ScaleType = Enum.ScaleType.Crop
				Style.corner(imageLabel, 8)
				local fill2 = Style.fill(
					textButton,
					"Band",
					Color3.new(1, 1, 1),
					UDim2.fromOffset(v122, v125 * 2),
					UDim2.fromOffset(0, v122 - v125 * 2)
				)
				Style.corner(fill2, 8)
				local uiGradient = Instance.new("UIGradient")
				uiGradient.Rotation = 90
				uiGradient.Color = ColorSequence.new(v130:Lerp(Style.INK, 0.2), v130:Lerp(Style.INK, 0.65))
				uiGradient.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.5, 0.15),
					NumberSequenceKeypoint.new(1, 0.02)
				})
				uiGradient.Parent = fill2
				local frame2 = Style.frame(
					textButton,
					"Rim",
					UDim2.fromOffset(v122 - 8, v122 - 8),
					UDim2.fromOffset(4, 4)
				)
				Style.corner(frame2, 5)
				Style.stroke(frame2, 2, 0.15, v130, true)
				local v132 = math.floor(v122 * 0.36)
				fit( -- inferred equivalent call
					text(textButton, "Name", v127.name, maxTextSize3, 8, v122 - v125, v122 - v132 - 16, v125 - 4, {
						outline = 2
					}),
					maxTextSize3
				)

				local pct = text(textButton, "Chance", "", maxTextSize4, v122 - v132 - 8, v122 - v125, v132, v125 - 4, {
					outline = 2,
					ax = Enum.TextXAlignment.Right
				})
				pct.AutoLocalize = false
				local own = text(
					textButton,
					"Owned",
					"OWNED",
					maxTextSize4,
					v122 - v132 - 8,
					v122 - v125,
					v132,
					v125 - 4,
					{ outline = 2, color = Style.GOOD, ax = Enum.TextXAlignment.Right }
				)
				fit(own, maxTextSize4) -- inferred equivalent call
				v126[v127.id] = { own = own, pct = pct }
			end

			local function drawTiles()
				local odds = Crates.odds
				local Players = game:GetService("Players")

				local v127 = {}

				for _, v128 in odds(ownsCrate, Players.LocalPlayer:GetAttribute("Level") or 1) do
					if v128.item then
						v127[v128.item] = v128.p
					end
				end

				for k, v128 in v126 do
					local visible = ownsCrate(k) -- inferred equivalent call
					v128.own.Visible = visible
					v128.pct.Text = (visible or not v127[k]) and "" or Crates.percent(v127[k])
				end
			end
			drawTiles()
			table.insert(v56, drawTiles)
			instance.AttributeChanged:Connect(function(value: string)
				if string.sub(value, 1, 3) == "Cs_" then
					drawTiles()
				end
			end)
			total += math.ceil(#WeaponSkins.CRATE / v121) * (v122 + 8) - 8
		end

		local v97 = touch and 230 or 290

		for _, v98 in {
			{ "scrap", "SCRAP" },
			{ "boosts", "2X PLAYER XP BOOSTS" },
			{ "gunBoosts", "2X WEAPON XP BOOSTS" }
		} do
			local v99 = CareerData.STORE[v98[1]]

			if v98[1] == "gunBoosts" then
				total += 32
			else
				tab(v98[1])
			end

			local v100 = math.floor((v84 - (#v99 - 1) * 8) / #v99)
			local v101 = v98[1] == "boosts" and "boost" or v98[1] == "gunBoosts" and "gunBoost" or nil

			if v101 then
				local v102 = touch and 44 or 52
				local v103 = math.min(v100, touch and 170 or 240)
				local imageLabel = image(parent, v98[1] .. "Mark", v3.pack[v99[1].id], 4, total, v102, v102) -- inferred equivalent call
				imageLabel.ScaleType = Enum.ScaleType.Fit
				local v105 = parent
				local v106 = v98[1] .. "Heading"
				local v107 = v98[2]
				local v108 = math.floor(v14 * 20)

				local v109 = v102 + 4 + 8
				local v110 = total
				fit( -- inferred equivalent call
					text(v105, v106, v107, v108, v109, v110, v84 - v102 - 16 - v103, v102, {
						outline = 2
					}),
					math.floor(v14 * 20)
				)

				useButton(v101, 4 + v84 - v103, total, v103, v102)
				total += v102 + 8
			elseif not top then
				text(parent, v98[1] .. "Heading", v98[2], math.floor(v14 * 20), 4, total, v84, v18, {
					outline = 2
				})
				total += v18
			end

			for k, v102 in v99 do
				packCard(v102, v48[k], k == #v99, 4 + (k - 1) * (v100 + 8), total, v100, v97)
			end

			total += v97

			if v98[1] ~= "scrap" then
				continue
			end

			for _, v102 in CareerData.STORE.scrapBoost do
				total += 8
				local v103 = touch and 112 or 140
				packCard(v102, "gold", false, 4, total, v84, v103)
				total += v103
			end
		end

		redrawProducts() -- inferred equivalent call

		if top then
			v76[#v67] = total + 4
			frames[#v67].Size = UDim2.fromOffset(v83, total + 4)
			assert(#frames == #v67, "[ArmoryStore] a section has no page")
			showTab(1)
		else
			scroll.CanvasSize = UDim2.fromOffset(0, total + 4)
			scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(salesFollow)
			markSales(1)
		end

		instance.AttributeChanged:Connect(function(value: string)
			if string.sub(value, 1, 5) == "Owns_" or value == "Level" or value == "UnlockAll" then
				redrawProducts() -- inferred equivalent call
			elseif value == CareerData.FREE_ATTR and fn then
				fn()
			elseif value == Skins.PACK_ATTR and v51 then
				v51()
			elseif
				value == CareerData.BOOST_ATTR
				or value == CareerData.GUN_BOOST_ATTR
				or value == CareerData.STOCK_ATTR.boost
				or value == CareerData.STOCK_ATTR.gunBoost
			then
				for _, v98 in draws do
					v98()
				end
			end
		end)
	end

	local function build() -- 1 equivalent call inferred from this helper
		v9 = true

		buildSoon()
		buildToast()
	end

	function v8.show(visible: boolean)
		if visible == v10 then
			return
		end

		v10 = visible
		self.Visible = visible

		if visible then
			UiTrack.send("store_open")
		end

		if visible then
			if not v9 then
				build() -- inferred equivalent call
			end

			dressViews()
			startTimers() -- inferred equivalent call
		else
			if v21 then
				closeOffer() -- inferred equivalent call
			end

			if v78 then
				closeItem() -- inferred equivalent call
			end
		end
	end

	function v8.back(): boolean
		if v10 and v60 then
			closeSkin() -- inferred equivalent call
			return true
		elseif v10 and v59 then
			closeOdds() -- inferred equivalent call
			return true
		else
			local giftPicker = script.Parent:FindFirstChild("GiftPicker")

			if v10 and giftPicker then
				local module = require(giftPicker)

				if module.isOpen() then
					module.close()
					return true
				end
			end

			if v10 and v78 then
				if v77 then
					v77:Destroy()
					v77 = nil
				end

				v78 = nil
				fn4 = nil
				v71.Visible = true
			else
				if not (v10 and v21) then
					return false
				end

				v21 = nil
				clearStage() -- inferred equivalent call
				v29.Visible = false
				parent.Visible = true
				startTimers() -- inferred equivalent call
			end

			if data.reseat then
				data.reseat()
			end

			return true
		end
	end

	function v8.tab(p: number)
		if v10 and v60 and v61 then
			v61(p)
			return
		end

		if not top or not v9 or v78 or #frames == 0 then
			return
		end

		showTab((v74 - 1 + p) % #frames + 1)
	end

	function v8.firstPad()
		if v77 then
			return (v77:FindFirstChild("Buy"))
		end

		local v80

		if top then
			v80 = frames[v74]
		end

		if v80 then
			local v81 = nil

			for _, button in v80:GetChildren() do
				if not (button:IsA("GuiButton") and button.Selectable and button.Visible) then
					continue
				end

				local absolutePosition = button.AbsolutePosition
				local absolutePosition2

				if v81 then
					absolutePosition2 = v81.AbsolutePosition
				end

				if not (not absolutePosition2 or absolutePosition.Y < absolutePosition2.Y - 4 or math.abs(absolutePosition.Y - absolutePosition2.Y) <= 4 and absolutePosition.X < absolutePosition2.X) then
					continue
				end

				v81 = button
			end

			if v81 then
				return v81
			end
		end

		if top and v74 > 1 then
			return v73[v74].button
		end

		return v64
	end

	return v8
end

return ArmoryStore