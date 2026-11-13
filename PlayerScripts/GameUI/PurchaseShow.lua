local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Style = require(script.Parent.Style)
local ClaimFx = require(script.Parent.ClaimFx)
local ClaimAudio = require(script.Parent.ClaimAudio)
local ToolIcon = require(script.Parent.ToolIcon)
local StreakIcon = require(script.Parent.StreakIcon)
local VehiclePreview = require(script.Parent.VehiclePreview)
require(script.Parent.SkinPreview)
local LoadoutData = require(script.Parent.LoadoutData)
local Game = ReplicatedStorage:WaitForChild("Game")
local CareerData = require(Game:WaitForChild("CareerData"))
require(Game:WaitForChild("Skins"))
local WeaponSkins = require(Game:WaitForChild("WeaponSkins"))
local ShopData = require(Game:WaitForChild("ShopData"))
local ToolTemplates = ReplicatedStorage:WaitForChild("ToolTemplates")

local color = Color3.fromRGB(255, 236, 190)

local v = { Style.HAZARD, Style.ORANGE, Color3.fromRGB(255, 226, 150) }

local toolsById = {}
local PurchaseShow = {}

for _, v2 in LoadoutData do
	for _, item in v2.items do
		if item.tool then
			toolsById[item.id] = item.tool
		end
	end
end

local function toolOf(item: string) -- 1 equivalent call inferred from this helper
	local tool = ToolTemplates:FindFirstChild(toolsById[item] or item)
	return if tool and tool:IsA("Tool") then tool else nil
end

local function kindText(data)
	if data.kind == "unlock" then
		if StreakIcon.has(data.item) then
			return "SCORESTREAK UNLOCKED"
		end

		return "WEAPON UNLOCKED"
	end

	if data.kind == "vehicle" then
		return "VEHICLE UNLOCKED"
	end

	if data.kind == "vehicleCall" then
		return "SPAWN READY"
	end

	if data.kind == "starter" then
		return "STEALTH PACK"
	end

	if data.kind == "boost" then
		return "2X PLAYER XP BOOSTS"
	end

	if data.kind == "gunBoost" then
		return "2X WEAPON XP BOOSTS"
	end

	if data.kind == "weaponPack" then
		if StreakIcon.has(data.show[1]) then
			return "SCORESTREAKS UNLOCKED"
		end

		return "WEAPONS UNLOCKED"
	end

	if data.kind == "crate" then
		return "SUPPLY CRATES"
	end

	if data.kind == "prize" then
		return data.tierText
	end

	if data.kind == "crateSkins" then
		return "CRATE SKINS"
	end

	if data.kind == "outfit" or data.kind == "outfitBundle" then
		return "OUTFIT UNLOCKED"
	end

	if data.kind == "outfitPack" then
		return "OUTFITS UNLOCKED"
	end

	if data.kind == "scrapBoost" then
		return "DOUBLE SCRAP UNLOCKED"
	end

	error("[PurchaseShow] no show for product kind " .. tostring(data.kind))
end

local function titleOf(data) -- 1 equivalent call inferred from this helper
	if data.kind == "starter" then
		return "STEALTH CHOPPER"
	end

	return data.name
end

local function drawItem(parent, data)
	if data.kind == "vehicle" or data.kind == "vehicleCall" or data.kind == "starter" then
		local view = VehiclePreview.view(parent, data.item, 0.95)
		return function(p: number)
			VehiclePreview.turn(view, p * 0.7 + 0.5)
		end
	end

	if data.kind == "prize" and data.item then
		return drawItem(parent, { kind = "unlock", item = data.item, id = data.id })
	end

	if data.kind == "skinOnGun" then
		local v2 = Players.LocalPlayer:GetAttribute(ShopData.PRIMARY_ATTR)
		local tool

		if data.gun then
			local gun = data.gun
			tool = ToolTemplates:FindFirstChild(toolsById[gun] or gun)

			if not (tool and tool:IsA("Tool")) then
				tool = nil
			end

			assert(tool, "[PurchaseShow] no tool for " .. tostring(data.gun))
		else
			if type(v2) ~= "string" then
				v2 = ShopData.DEFAULT_PRIMARY
			end

			tool = ToolTemplates:FindFirstChild(toolsById[v2] or v2)

			if not (tool and tool:IsA("Tool")) then
				tool = nil
			end

			if not tool then
				local DEFAULT_PRIMARY = ShopData.DEFAULT_PRIMARY
				tool = ToolTemplates:FindFirstChild(toolsById[DEFAULT_PRIMARY] or DEFAULT_PRIMARY)

				if not (tool and tool:IsA("Tool")) then
					tool = nil
				end
			end
		end

		assert(tool, "[PurchaseShow] no tool for the primary gun")
		local v3 = ToolIcon.make(tool, parent)
		v3.Size = UDim2.fromScale(1, 1)
		local model = v3:FindFirstChildOfClass("Model")
		WeaponSkins.paint(model, data.skin)
		local currentCamera = v3.CurrentCamera
		local boundingBox = model:GetBoundingBox()
		local v4 = currentCamera.CFrame.Position - boundingBox.Position
		return function(p: number)
			local v5 = math.sin(p * 0.7) * 0.9
			currentCamera.CFrame = CFrame.lookAt(
				boundingBox.Position + CFrame.Angles(0, v5, 0):VectorToWorldSpace(v4),
				boundingBox.Position
			)
		end
	end

	if data.kind == "unlock" and StreakIcon.has(data.item) then
		StreakIcon.voxel(data.item, parent)
		return nil
	end

	if data.kind == "unlock" then
		local tool = toolOf(data.item) -- inferred equivalent call
		assert(tool, "[PurchaseShow] no tool for " .. tostring(data.item))
		local v2 = ToolIcon.make(tool, parent)
		v2.Size = UDim2.fromScale(1, 1)
		local currentCamera = v2.CurrentCamera
		local boundingBox, _ = v2:FindFirstChildOfClass("Model"):GetBoundingBox()
		local v3 = currentCamera.CFrame.Position - boundingBox.Position
		return function(p: number)
			local v4 = math.sin(p * 0.7) * 0.9
			currentCamera.CFrame = CFrame.lookAt(
				boundingBox.Position + CFrame.Angles(0, v4, 0):VectorToWorldSpace(v3),
				boundingBox.Position
			)
		end
	else
		if not data.image then
			error("[PurchaseShow] nothing to draw for " .. tostring(data.id))
			return
		end

		local imageLabel = Instance.new("ImageLabel")
		imageLabel.BackgroundTransparency = 1
		imageLabel.Image = data.image
		imageLabel.ScaleType = Enum.ScaleType.Fit
		imageLabel.Size = UDim2.fromScale(1, 1)
		imageLabel.Parent = parent
		return nil
	end
end

local function word(frame, p: string, p2: number, textColor: Color3, p3: number) -- 2 equivalent calls inferred from this helper
	local label = Style.label(frame, "Word", p, p2, Style.FONT, p3)
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.TextColor3 = textColor
	return label
end

local fn

local function beatsOf(p)
	local v2 = fn(p)

	if type(p.giftFrom) ~= "string" then
		return v2
	end

	local v3 = string.upper(p.giftFrom)

	if utf8.len(v3) and utf8.len(v3) > 16 then
		v3 = string.sub(v3, 1, (utf8.offset(v3, 17) or #v3 + 1) - 1) .. "..."
	end

	v2[1].kind = "GIFT FROM " .. v3

	return v2
end

fn = function(data)
	if data.kind == "weaponPack" then
		local result = {}

		for k, id in data.show do
			local v2 = CareerData.unlockOf(id)
			assert(v2, "[PurchaseShow] pack " .. data.id .. " shows " .. id .. ", which no product sells")
			local v3 = { kind = kindText(data), title = 0, draw = 0 }
			local title = if k == 1 then data.name else v2.name
			v3.title = title
			function v3.draw(p)
				return drawItem(p, { kind = "unlock", item = id, id = id }), nil
			end

			table.insert(result, v3)
		end

		return result
	elseif data.kind == "crateSkins" then
		local result = {}

		for _, priz in data.prizes do
			if priz.kind == "skin" and priz.dup then
				local title

				if (priz.xp or 0) > 0 then
					title = string.format("+%d SCRAP  +%d XP", priz.scrap or 0, priz.xp or 0)
				else
					title = string.format("+%d SCRAP", priz.scrap or 0)
				end

				table.insert(result, {
					kind = "ALREADY OWNED",
					title = title,
					draw = function(p)
						return
							drawItem(p, {
								kind = "scrap",
								image = CareerData.STORE.scrap[2].image,
								id = "crateScrap"
							}),
							nil
					end
				})
			elseif priz.kind == "skin" then
				local v2 = WeaponSkins.find(priz.item)
				assert(v2 and v2.crate, "[PurchaseShow] " .. tostring(priz.item) .. " is not a crate skin")
				local rarity = WeaponSkins.rarity(v2.crate)
				table.insert(result, {
					kind = rarity.name .. " SKIN",
					title = v2.name,
					color = rarity.color,
					action = data.equip and {
						text = "EQUIP",
						run = function()
							return data.equip(v2.id)
						end
					} or nil,
					draw = function(p)
						return drawItem(p, {
							kind = "skinOnGun",
							skin = v2.id,
							id = v2.id,
							gun = priz.gun
						}), nil
					end
				})
			else
				table.insert(result, {
					kind = "EVERY SKIN OWNED",
					title = string.format("+%d SCRAP", priz.scrap or 0),
					draw = function(p)
						return
							drawItem(p, {
								kind = "scrap",
								image = CareerData.STORE.scrap[2].image,
								id = "crateScrap"
							}),
							nil
					end
				})
			end
		end

		assert(#result > 0, "[PurchaseShow] a crate show with no prizes")
		return result
	elseif data.kind == "outfitPack" or data.kind == "outfitBundle" then
		local color2 = Color3.fromRGB(70, 225, 100)
		local result = {}
		local v2

		if data.kind == "outfitPack" then
			v2 = data.skins
		else
			v2 = { data.skin }
		end

		for _, v3 in v2 do
			local outfit = CareerData.outfitOf(v3)
			assert(outfit, "[PurchaseShow] no outfit product for " .. tostring(v3))
			table.insert(result, {
				kind = "OUTFIT UNLOCKED",
				title = outfit.name,
				color = color2,
				draw = function(p)
					return drawItem(p, { kind = "outfit", image = outfit.image, id = outfit.id }), nil
				end
			})
		end

		if data.kind == "outfitPack" then
			local bundleFor = WeaponSkins.bundleFor(data.skins[1])
			assert(bundleFor, "[PurchaseShow] no bundle skin for " .. tostring(data.skins[1]))
			table.insert(result, {
				kind = "GUN SKINS UNLOCKED",
				title = #data.skins .. " GUN SKINS",
				color = color2,
				draw = function(p)
					return drawItem(p, { kind = "skinOnGun", skin = bundleFor.id, id = data.id }), nil
				end
			})
		end

		if data.kind == "outfitBundle" then
			table.insert(result, {
				kind = "GUN SKIN UNLOCKED",
				title = WeaponSkins.find(data.camo).name,
				color = color2,
				draw = function(p)
					return drawItem(p, { kind = "skinOnGun", skin = data.camo, id = data.id }), nil
				end
			})
		end

		return result
	elseif data.kind == "streakSkin" then
		local v2 = WeaponSkins.find(data.skin)
		assert(v2 and v2.streak, "[PurchaseShow] " .. tostring(data.skin) .. " is not a streak skin")
		return {
			{
				kind = "GUN SKIN UNLOCKED",
				title = v2.name,
				color = WeaponSkins.STREAK_COLOR,
				action = data.equip and {
					text = "EQUIP",
					run = function()
						return data.equip(v2.id)
					end
				} or nil,
				draw = function(p)
					return drawItem(p, { kind = "skinOnGun", skin = v2.id, id = v2.id }), nil
				end
			}
		}
	elseif data.kind == "starter" then
		return {
			{
				kind = "VEHICLE UNLOCKED",
				title = "STEALTH CHOPPER",
				draw = function(p)
					return drawItem(p, { kind = "vehicle", item = data.item }), nil
				end
			},
			{
				kind = "2X PLAYER XP BOOSTS",
				title = "3 PLAYER XP BOOSTS",
				draw = function(p)
					return drawItem(p, { kind = "boost", image = CareerData.STORE.boosts[1].image }), nil
				end
			}
		}
	else
		return {
			{
				kind = kindText(data),
				title = titleOf(data), -- inferred equivalent call
				draw = function(p)
					return drawItem(p, data), nil
				end
			}
		}
	end
end

local v2 = nil
local v3 = {}
local flag = false

local v4 = {}
local v5 = {}
local function takeDown()
	for _, v6 in v5 do
		v6()
	end

	v5 = {}

	for _, v6 in v4 do
		v6:Destroy()
	end

	v4 = {}

	if v2 then
		v2.Enabled = false
	end

	ClaimAudio.hush(0)
	flag = false
end

local fn2

local function play(p)
	flag = true
	local v6 = beatsOf(p)
	local v7 = v2
	v7.Enabled = true

	local viewportSize = workspace.CurrentCamera.ViewportSize
	local v8 = math.clamp(viewportSize.Y / 22.5, 14, 48)

	local scale = math.min(math.max(v8 / 32, 0.7), viewportSize.Y * 0.83 / 420, viewportSize.X / 640)
	local halfViewportSize = viewportSize / 2
	local v9 = halfViewportSize + Vector2.new(0, scale * -14)

	local frame = Style.frame(v7, "Show", UDim2.fromScale(1, 1))
	v4 = { frame }
	local fill = Style.fill(frame, "Dim", Style.INK, UDim2.fromScale(1, 1))
	fill.BackgroundTransparency = 1
	local catch = Instance.new("TextButton")
	catch.Name = "Catch"
	catch.Text = ""
	catch.BackgroundTransparency = 1
	catch.Size = UDim2.fromScale(1, 1)
	catch.Modal = true
	catch.Parent = frame
	local fill2 = Style.fill(
		frame,
		"BarTop",
		Color3.new(0, 0, 0),
		UDim2.fromScale(1, 0.085),
		UDim2.fromScale(0, -0.085)
	)
	local fill3 = Style.fill(frame, "BarBottom", Color3.new(0, 0, 0), UDim2.fromScale(1, 0.085), UDim2.fromScale(0, 1))

	local frame2 = Style.frame(
		frame,
		"Stage",
		UDim2.fromOffset(640, 420),
		UDim2.fromOffset(halfViewportSize.X, halfViewportSize.Y),
		Vector2.new(0.5, 0.5)
	)
	frame2.ZIndex = 2
	local uiScale = Instance.new("UIScale")
	uiScale.Scale = scale
	uiScale.Parent = frame2

	local frame3 = Style.frame(frame2, "Back", UDim2.fromOffset(0, 0), UDim2.fromOffset(320, 196))
	local glow = ClaimFx.glow(frame3, 520, Style.HAZARD)
	glow.ImageTransparency = 1
	local image = ClaimFx.image(frame3, "Flare", ClaimFx.GLOW, Style.HAZARD, 0, UDim2.fromScale(0.5, 0.5))
	image.ImageTransparency = 1
	local image2 = ClaimFx.image(frame3, "Core", ClaimFx.GLOW, color, 0, UDim2.fromScale(0.5, 0.5))
	image2.ImageTransparency = 1

	for _, v10 in { image, image2 } do
		v10.AnchorPoint = Vector2.new(0.5, 0.5)
	end

	local frame4 = Style.frame(frame2, "Embers", UDim2.fromScale(1, 1))

	local v10 = {}
	local v11 = 0

	local kind = word(frame2, "", 50, Style.HAZARD, 3) -- inferred equivalent call
	kind.Name = "Kind"
	kind.Position = UDim2.fromOffset(320, 26)
	kind.ZIndex = 4

	kind.Visible = false
	local uiScale2 = Instance.new("UIScale")
	uiScale2.Parent = kind
	local parent = word(frame2, "", 46, Style.WHITE, 2) -- inferred equivalent call
	parent.Position = UDim2.fromOffset(320, 330)
	parent.ZIndex = 4
	local uiScale3 = Instance.new("UIScale")
	uiScale3.Parent = parent

	local boxes = {}

	if #v6 > 1 then
		local frame5 = Style.frame(
			frame2,
			"Pips",
			UDim2.fromOffset(#v6 * 22, 12),
			UDim2.fromOffset(320, 364),
			Vector2.new(0.5, 0.5)
		)
		local uiListLayout = Instance.new("UIListLayout")
		uiListLayout.FillDirection = Enum.FillDirection.Horizontal
		uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uiListLayout.Padding = UDim.new(0, 10)
		uiListLayout.Parent = frame5

		for i = 1, #v6 do
			local box = Style.box(frame5, "Pip", Style.STEEL, UDim2.fromOffset(12, 12), 2, 1.5)
			box.LayoutOrder = i
			box.Rotation = 45
			table.insert(boxes, box)
		end
	end

	local v12 = math.max(48, 46 / scale)
	local button, v13 = Style.button(frame2, "Continue", "", Style.HAZARD, UDim2.fromOffset(220, v12), Style.INK, 20)
	button.AnchorPoint = Vector2.new(0.5, 0)
	button.Position = UDim2.fromOffset(320, 376)
	button.Visible = false
	button.ZIndex = 4
	v13.ZIndex = 4

	local button2, v14 = Style.button(
		frame2,
		"Action",
		"",
		Style.STEEL_LIGHT,
		UDim2.fromOffset(200, v12),
		Style.WHITE,
		20
	)
	button2.AnchorPoint = Vector2.new(0.5, 0)
	button2.Position = UDim2.fromOffset(208, 376)
	button2.Visible = false
	button2.ZIndex = 4
	v14.ZIndex = 4
	local v15 = false
	local v16 = nil
	button2.Activated:Connect(function()
		local v17 = v16

		if v15 or not (v17 and v17.action and button2.Visible) then
			return
		end

		v15 = true
		v14.Text = v17.action.run()
		button2.AutoButtonColor = false
		button2.BackgroundColor3 = Style.STEEL
		v14.TextColor3 = Style.GOOD
	end)

	local blurEffect = Instance.new("BlurEffect")
	blurEffect.Size = 0
	blurEffect.Parent = workspace.CurrentCamera
	table.insert(v4, blurEffect)

	local function makeItem(p2)
		local frame5 = Style.frame(
			frame2,
			"Item",
			UDim2.fromOffset(420, 230),
			UDim2.fromOffset(320, 196),
			Vector2.new(0.5, 0.5)
		)
		frame5.Visible = false
		frame5.ZIndex = 2
		local uiScale4 = Instance.new("UIScale")
		uiScale4.Parent = frame5
		local spin, clean = p2.draw(frame5)

		if clean then
			table.insert(v5, clean)
		end

		return { holder = frame5, pop = uiScale4, spin = spin, clean = clean }
	end

	local function dropItem(p2) -- 2 equivalent calls inferred from this helper
		if p2.clean then
			p2.clean()
			local index = table.find(v5, p2.clean)

			if index then
				table.remove(v5, index)
			end
		end

		p2.holder:Destroy()
	end

	local v17 = 1
	local v18 = makeItem(v6[1])
	local v19 = nil
	local v20 = 0
	local lastTime = os.clock()
	local v21 = 1.15

	local v22 = false
	local v23 = false
	local v24 = 0
	local v25 = false
	local now = nil

	local function ready() -- 1 equivalent call inferred from this helper
		return v22 and os.clock() - lastTime - v21 >= 1.3
	end

	local function advance()
		if now or not ready() then -- inferred equivalent call
			return
		end

		if not (v17 < #v6) then
			now = os.clock()

			return
		end

		v17 += 1

		if v19 then
			dropItem(v19) -- inferred equivalent call
		end

		local v26 = v18
		local v27 = os.clock() - lastTime
		v19 = v26
		v20 = v27
		v18 = makeItem(v6[v17])
		v21 = v20 + 0.3
		v22 = false
		v23 = false
		v24 = 0
		v25 = false
		kind.Visible = false
		parent.Text = ""
		button.Visible = false
		button2.Visible = false
		ClaimAudio.purchaseIn(0.3)
	end
	catch.Activated:Connect(advance)
	button.Activated:Connect(advance)

	local v26 = v5
	local PadMenus = require(script.Parent:WaitForChild("PadMenus"))
	table.insert(v26, PadMenus.hold("purchase", advance))

	ClaimAudio.purchaseIn(1.15)
	local function step(p2: number, p3: number): boolean
		local v27 = p3 - lastTime
		local v28 = halfViewportSize

		local easeOut = Style.easeOut((math.clamp(v27 / 0.5, 0, 1)))
		local v29 = not now and 0 or Style.easeIn((math.clamp((p3 - now) / 0.35, 0, 1)))
		local v30 = easeOut * (1 - v29)
		fill.BackgroundTransparency = 1 - 0.7 * v30
		fill2.Position = UDim2.fromScale(0, -0.085 * (1 - v30))
		fill3.Position = UDim2.fromScale(0, 1 - 0.085 * v30)
		blurEffect.Size = 18 * v30
		ClaimAudio.hush(v30)
		local scale2

		if v27 < 1.15 then
			scale2 = scale * (0.9 + 0.1 * Style.easeOut((math.min(1, v27 / 0.4))))
		else
			scale2 = scale * (1 - v29)
		end

		uiScale.Scale = scale2

		if v27 < 1.15 then
			local v31 = v27 / 1.15
			glow.ImageTransparency = 1 - 0.55 * v31 * v31
			image2.Size = UDim2.fromOffset(240 * v31 * v31, 88 * v31 * v31)
			image2.ImageTransparency = 1 - 0.8 * v31
		else
			local born = v27 - 1.15

			glow.ImageTransparency = 1 - (math.sin(born * 3) * 0.06 + 0.42) * math.clamp(born / 0.3, 0, 1)
			v11 += p2

			while v11 >= 0.07 do
				v11 -= 0.07
				local v31 = math.random(3, 7)
				local fill4 = Style.fill(frame4, "Ember", v[math.random(#v)], UDim2.fromOffset(v31, v31))
				fill4.AnchorPoint = Vector2.new(0.5, 0.5)
				table.insert(v10, {
					f = fill4,
					x = 320 + (math.random() * 2 - 1) * 260,
					y = 286 + math.random() * 40,
					v = 50 + math.random() * 70,
					sway = math.random() * 6,
					born = born
				})
			end

			for i = #v10, 1, -1 do
				local v31 = v10[i]
				local v32 = born - v31.born

				if v32 >= 1.8 then
					v31.f:Destroy()
					table.remove(v10, i)
				else
					v31.f.Position = UDim2.fromOffset(v31.x + math.sin(v32 * 2 + v31.sway) * 10, v31.y - v31.v * v32)
					v31.f.BackgroundTransparency = math.max(0.15, v32 / 1.8)
					v31.f.Rotation = v32 * 90
				end
			end
		end

		if v19 then
			local v31 = math.clamp((v27 - v20) / 0.3, 0, 1)
			v19.pop.Scale = 1 - 0.7 * Style.easeIn(v31)
			v19.holder.Position = UDim2.fromOffset(320, 196 - 60 * Style.easeIn(v31))

			if v31 >= 1 then
				dropItem(v19) -- inferred equivalent call
				v19 = nil
			end
		end

		if v21 <= v27 then
			local v31 = v27 - v21

			if not v22 then
				v22 = true
				v18.holder.Visible = true

				local color2 = v6[v17].color or Style.HAZARD
				glow.ImageColor3 = color2
				image.ImageColor3 = color2
				kind.TextColor3 = color2
				ClaimAudio.purchaseHit()
				ClaimFx.flash(v7, 0.6, 0.35, color)
				ClaimFx.ring(v7, v9, v8 * 20, v8 * 0.5, color2, 0.6)
				ClaimFx.ring(v7, v9, v8 * 12, v8 * 0.3, Style.WHITE, 0.5, 0.08)
				ClaimFx.salvo(v7, v9, v8)

				for k, v32 in boxes do
					local backgroundColor

					if k <= v17 then
						backgroundColor = Style.HAZARD
					else
						backgroundColor = Style.STEEL
					end

					v32.BackgroundColor3 = backgroundColor
				end
			end

			local v32 = math.clamp(v31 / 0.18, 0, 1)
			local pop = v18.pop
			local scale3

			if v32 < 1 then
				scale3 = 1.9 - 0.95 * Style.easeIn(v32)
			else
				scale3 = 0.95 + 0.05 * Style.easeOut((math.clamp((v31 - 0.18) / 0.25, 0, 1)))
			end

			pop.Scale = scale3
			v18.holder.Position = UDim2.fromOffset(320, math.sin(v31 * 2.2) * 5 + 196)

			if v18.spin then
				v18.spin(v31)
			end

			local v38 = math.max(0, 1 - v31 / 0.3) * 10 * scale
			v28 += Vector2.new((math.random() * 2 - 1) * v38, (math.random() * 2 - 1) * v38)

			local easeOut2 = Style.easeOut((math.clamp(v31 / 0.4, 0, 1)))
			local v39 = math.sin(v31 * 2.6) * 0.04 + 1
			image.Size = UDim2.fromOffset(620 * easeOut2 * v39, 260 * easeOut2 * v39)
			image.ImageTransparency = 1 - 0.45 * easeOut2
			image2.Size = UDim2.fromOffset(300 * (0.8 + 0.2 * easeOut2) * v39, 110 * (0.8 + 0.2 * easeOut2) * v39)
			image2.ImageTransparency = 1 - 0.75 * easeOut2

			if v31 >= 0.25 then
				if not v23 then
					v23 = true
					kind.Text = v6[v17].kind

					kind.TextSize = 50

					if kind.TextBounds.X > 616 then
						kind.TextSize = math.max(24, (math.floor(30800 / kind.TextBounds.X)))
					end

					kind.Visible = true
					ClaimAudio.press()
				end

				uiScale2.Scale = 1 + 0.8 * (1 - Style.easeOut((math.clamp((v31 - 0.25) / 0.14, 0, 1))))
			end

			local title = v6[v17].title
			local v40 = math.clamp(math.floor((v31 - 0.45) / 0.045) + 1, 0, #title)

			if v24 < v40 then
				v24 = v40
				parent.Text = string.sub(title, 1, v24)

				if string.sub(title, v24, v24) ~= " " then
					ClaimAudio.countTick(v24 / #title)
				end

				uiScale3.Scale = 1.08
			end

			if v24 == #title and not v25 then
				v25 = true
				ClaimAudio.purchaseLand()
				uiScale3.Scale = 1.25
				ClaimFx.sparks(v7, halfViewportSize + Vector2.new(0, scale * 120), 16, v8 * 0.8, 0.5)
			end

			uiScale3.Scale = math.max(1, uiScale3.Scale - p2 * 2.4)

			if v31 >= 1.3 and not (button.Visible or now) then
				v13.Text = v17 < #v6 and "NEXT" or "CONTINUE"
				button.Visible = true
				local action = v6[v17].action
				button2.Visible = action ~= nil
				button.Position = UDim2.fromOffset(action and 432 or 320, 376)
				v16 = v6[v17]

				if action then
					v15 = false
					v14.Text = action.text
					button2.AutoButtonColor = true
					button2.BackgroundColor3 = Style.STEEL_LIGHT
					v14.TextColor3 = Style.WHITE
				end
			end

			if (v17 < #v6 and 5 or 9) <= v31 then
				advance()
			end
		end

		frame2.Position = UDim2.fromOffset(v28.X, v28.Y)

		if not (now and p3 - now >= 0.35) then
			return true
		end

		takeDown()
		local v31 = table.remove(v3, 1)

		if v31 then
			task.defer(fn2, v31)
		end

		return false
	end

	Style.animate(frame, function(p2: number, p3: number)
		local success, result = xpcall(step, debug.traceback, p2, p3)

		if not success then
			takeDown()
			error("[PurchaseShow] " .. tostring(result))
		end

		return result
	end)
end

fn2 = function(p)
	local success, result = xpcall(play, debug.traceback, p)

	if not success then
		takeDown()
		error("[PurchaseShow] " .. tostring(result))
	end
end

function PurchaseShow.play(p, p2)
	assert(p2.kind ~= "scrap", "[PurchaseShow] Scrap keeps LobbyMenus' reveal")
	kindText(p2)

	if not v2 then
		v2 = Style.layer(p, "PurchaseShow", 30, true)
	end

	if flag then
		table.insert(v3, p2)
	else
		fn2(p2)
	end
end

function PurchaseShow.playing()
	return flag or #v3 > 0
end

return PurchaseShow