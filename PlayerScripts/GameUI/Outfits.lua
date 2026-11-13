local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local UserInputService = game:GetService("UserInputService")

local Style = require(script.Parent:WaitForChild("Style"))
local NewMenus = require(script.Parent:WaitForChild("NewMenus"))
local Armory = require(script.Parent:WaitForChild("Armory"))
local ArmoryStore = require(script.Parent:WaitForChild("ArmoryStore"))
local PadMenus = require(script.Parent:WaitForChild("PadMenus"))
local SkinPreview = require(script.Parent:WaitForChild("SkinPreview"))
local OutfitLook = require(script.Parent:WaitForChild("OutfitLook"))
local CardSelect = require(script.Parent:WaitForChild("CardSelect"))
local MenuAudio = require(script.Parent:WaitForChild("MenuAudio"))
local Skins = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("Skins"))
local WeaponSkins = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("WeaponSkins"))
local ShopData = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("ShopData"))

local Outfits = {
	["ON"] = NewMenus.on("Outfits"),
	toggle = nil,
	open = nil,
	close = nil,
	isOpen = nil
}

local v = {
	SkyRaider = {
		image = "rbxassetid://101307816657279",
		color = Color3.fromRGB(70, 170, 255),
		ambient = Color3.fromRGB(84, 112, 168),
		light = Color3.fromRGB(214, 232, 255)
	},
	Venom = {
		image = "rbxassetid://137171946314391",
		color = Color3.fromRGB(70, 255, 96),
		ambient = Color3.fromRGB(78, 134, 84),
		light = Color3.fromRGB(226, 255, 214)
	},
	Inferno = {
		image = "rbxassetid://76804748441660",
		color = Color3.fromRGB(255, 122, 28),
		ambient = Color3.fromRGB(150, 92, 70),
		light = Color3.fromRGB(255, 222, 180)
	},
	Revenant = {
		image = "rbxassetid://103703913344015",
		color = Color3.fromRGB(168, 96, 255),
		ambient = Color3.fromRGB(112, 92, 158),
		light = Color3.fromRGB(232, 222, 255)
	}
}

local color = Color3.fromRGB(92, 104, 130)
local color2 = Color3.fromRGB(255, 232, 196)

local color3 = Color3.fromRGB(150, 240, 165)
local color4 = Color3.fromRGB(255, 132, 110)

local color5 = Color3.fromRGB(34, 36, 42)

local v2 = {
	{ id = "all", text = "ALL" },
	{ id = "owned", text = "OWNED" },
	{ id = "premium", text = "PREMIUM" }
}

local function label(p, p2: string, p3: string, p4: number, p5: number, p6: number, p7: number, p8: number, options)
	local v3 = options or {}
	local label2 = Style.label(p, p2, p3, p4, v3.font or Style.FONT, v3.outline or 0)
	label2.AutomaticSize = Enum.AutomaticSize.None
	label2.Position = UDim2.fromOffset(p5, p6)
	label2.Size = UDim2.fromOffset(p7, p8)
	label2.TextXAlignment = v3.ax or Enum.TextXAlignment.Left
	label2.TextYAlignment = v3.ay or Enum.TextYAlignment.Center
	label2.TextColor3 = v3.color or Style.WHITE
	label2.TextWrapped = v3.wrap == true
	local uiStroke = label2:FindFirstChildOfClass("UIStroke")

	if uiStroke then
		uiStroke.LineJoinMode = Enum.LineJoinMode.Round
	end

	return label2
end

function Outfits.mount(data)
	if not Outfits.ON then
		return
	end

	local player = data.player
	local touch = Style.isTouch()
	local shop = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Remotes"):WaitForChild("Shop", 30)
	assert(shop and shop:IsA("RemoteFunction"), "[Outfits] remote Game.Remotes.Shop (RemoteFunction) is missing")

	local layer = Style.layer(data.playerGui, "OutfitsBackdrop", 10, true)
	layer.Enabled = false
	local layer2 = Style.layer(data.playerGui, "OutfitsWindow", 11)
	layer2.Enabled = false
	local v3 = touch and 1 or 1.3

	local function S(p: number)
		return (math.floor(p * v3))
	end

	local v4 = false
	local room = nil
	local v5 = nil
	local parent = nil
	local parent2 = nil
	local function fn() end
	local function fn2() end
	local function fn3(): nil
		return nil
	end

	local function fn4(_: number) end

	local function build()
		v4 = true
		room = Instance.new("ImageLabel")
		room.Name = "Room"
		room.BorderSizePixel = 0
		room.BackgroundColor3 = Style.INK
		room.Image = "rbxassetid://91618037992213"
		room.ScaleType = Enum.ScaleType.Crop
		room.Size = UDim2.fromScale(1, 1)
		room.Active = true
		room.Parent = layer
		v5 = Style.fill(room, "Ink", Style.INK, UDim2.fromScale(1, 1))
		v5.BackgroundTransparency = 0.7
		local v6 = touch and 540 or 700
		local viewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(16, 9)
		local v7 = math.floor(v6 * math.clamp(viewportSize.X / math.max(viewportSize.Y, 1), 1.6, 2.2))
		parent = Style.region(layer2, "Outfits", Vector2.new(0.5, 0.5), Vector2.zero, Vector2.new(v7, v6))
		Style.fit(parent, Vector2.new(v7, v6), 0.98)
		local modal = Instance.new("TextButton")
		modal.Name = "Modal"
		modal.Text = ""
		modal.BackgroundTransparency = 1
		modal.Size = UDim2.fromOffset(1, 1)
		modal.Modal = true
		modal.Selectable = false
		modal.Parent = parent
		parent2 = Style.frame(parent, "Body", UDim2.fromScale(1, 1))

		local label2 = Style.label(parent2, "Title", "OUTFITS", 44, Style.FONT, 2.5)
		label2.TextColor3 = Style.HAZARD
		label2.Position = UDim2.fromOffset(16, 4)
		local _CLOSE_SIZE = Style.CLOSE_SIZE
		local v8 = Style.closeButton(parent2)
		v8.AnchorPoint = Vector2.new(1, 0)
		v8.Position = UDim2.new(1, -16, 0, 8)
		v8.Activated:Connect(function()
			Outfits.leave()
		end)
		local v9 = touch and 104 or 124
		local v10 = {}

		for k, v11 in v2 do
			local button, label3 = Style.button(
				parent2,
				"Filter_" .. v11.id,
				v11.text,
				Style.PANEL,
				UDim2.fromOffset(v9, 44),
				Style.MUTED,
				18
			)

			button.Position = UDim2.fromOffset(28 + (k - 1) * (v9 + 8), 64)
			local tape = Style.tape(button, "Underline", UDim2.new(1, 0, 0, 5), v9, 10)
			tape.AnchorPoint = Vector2.new(0, 1)
			tape.Position = UDim2.fromScale(0, 1)
			table.insert(v10, { id = v11.id, button = button, label = label3, under = tape })
		end

		local v11 = v6 - 64 - 16

		local v12 = math.floor((v7 - 32 - 14) * 0.57)
		local v13 = v7 - 32 - 14 - v12
		local v14 = v12 + 16 + 14
		local v15 = touch and 3 or 4
		local v16 = math.floor((v12 - 6 - 24 - (v15 - 1) * 12) / v15)
		local v17 = math.floor(v3 * 16) + math.floor(v3 * 13) + 14

		local v18 = math.floor(v16 * 1.02) + v17
		local cards = Instance.new("ScrollingFrame")
		cards.Name = "Cards"
		cards.BackgroundTransparency = 1
		cards.BorderSizePixel = 0
		cards.Position = UDim2.fromOffset(16, 116)
		cards.Size = UDim2.fromOffset(v12, v11 - 52)
		cards.ScrollingDirection = Enum.ScrollingDirection.Y
		cards.ScrollBarThickness = 6
		cards.ScrollBarImageColor3 = Style.HAZARD
		cards.CanvasSize = UDim2.new()
		cards.Selectable = false
		cards.Parent = parent2
		local v19 = label(parent2, "Empty", "NOTHING HERE YET", math.floor(v3 * 18), 16, 156, v12, 30, {
			ax = Enum.TextXAlignment.Center,
			color = Style.MUTED,
			outline = 2
		})
		v19.Visible = false

		local v20 = {}
		local v21 = nil
		local v22 = "all"
		local v23 = (not player.Team or player.Team.Name ~= "Reds" and player.Team.Name ~= "Blues") and "Reds"
			or player.Team.Name

		local function state(p): string -- 2 equivalent calls inferred from this helper
			if Skins.pick(player) == p.id then
				return "equipped"
			end

			if Skins.unlocked(player, p.id) then
				return "owned"
			end

			if not p.paid then
				return "level"
			end

			return if Skins.PAID_ON then "paid" else "soon"
		end

		local v24 = false

		local function v25() end

		local fn5
		local v26 = nil
		local flag = false

		for _, skin in Skins.LIST do
			local textButton = Instance.new("TextButton")
			textButton.Name = skin.id
			textButton.Text = ""
			textButton.AutoButtonColor = false
			textButton.BorderSizePixel = 0
			textButton.BackgroundColor3 = Style.INK
			textButton.Size = UDim2.fromOffset(v16, v18)
			textButton.Parent = cards
			Style.corner(textButton, 6)
			local glows = OutfitLook.glows(skin)
			local imageLabel

			if glows then
				imageLabel = Instance.new("ImageLabel")
				imageLabel.Name = skin.id .. "_Halo"
				imageLabel.BackgroundTransparency = 1
				imageLabel.Image = OutfitLook.HALO
				imageLabel.ImageColor3 = OutfitLook.HALO_COLOR
				imageLabel.ImageTransparency = 0.1
				imageLabel.ScaleType = Enum.ScaleType.Stretch
				imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
				imageLabel.Size = UDim2.fromOffset(
					math.floor(v16 * OutfitLook.HALO_GROW.X),
					(math.floor(v18 * OutfitLook.HALO_GROW.Y))
				)
				imageLabel.ZIndex = 0
				imageLabel.Visible = false
				imageLabel.Parent = cards
			end

			local rimColor = OutfitLook.rimColor(skin)
			local stroke = Style.stroke(textButton, 2, 0, rimColor, true)
			local frame = Style.frame(textButton, "Picture", UDim2.fromOffset(v16, v18 - v17))
			frame.ClipsDescendants = true
			local v27 = label(textButton, "Rarity", "", math.floor(v3 * 12), 8, 5, v16 - 16, math.floor(v3 * 12) + 6, {
				outline = 2
			})
			v27.ZIndex = 3
			OutfitLook.card(textButton, frame, v27, skin, true)
			local view = SkinPreview.view(frame, "bust")
			local fill = Style.fill(frame, "Veil", Style.INK, UDim2.fromScale(1, 1))
			fill.BackgroundTransparency = glows and 0.9 or 0.72
			fill.ZIndex = 2

			local fill2 = Style.fill(
				textButton,
				"Fade",
				Style.INK,
				UDim2.fromOffset(v16, v17 + 26),
				UDim2.fromOffset(0, v18 - v17 - 26)
			)
			fill2.BackgroundTransparency = 0.55
			local uiGradient = Instance.new("UIGradient")
			uiGradient.Rotation = 90
			uiGradient.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.45, 0.25),
				NumberSequenceKeypoint.new(1, 0)
			})
			uiGradient.Parent = fill2
			Style.corner(fill2, 6)
			local v28 = label(
				textButton,
				"Name",
				string.upper(skin.name),
				math.floor(v3 * 16),
				6,
				v18 - v17 + 2,
				v16 - 12,
				math.floor(v3 * 16) + 4,
				{ ax = Enum.TextXAlignment.Center, outline = 2 }
			)
			v28.TextTruncate = Enum.TextTruncate.AtEnd
			v28.ZIndex = 3
			local v29 = v18 - math.floor(v3 * 13) - 10
			local v30 = label(textButton, "State", "", math.floor(v3 * 13), 6, v29, v16 - 12, math.floor(v3 * 13) + 6, {
				ax = Enum.TextXAlignment.Center,
				outline = 2
			})
			v30.ZIndex = 3
			local folder = Style.frame(
				textButton,
				"Price",
				UDim2.fromOffset(v16 - 12, math.floor(v3 * 13) + 6),
				UDim2.fromOffset(6, v29)
			)
			folder.ZIndex = 3
			local _, v31 = Style.robuxLine(folder, "Robux", (math.floor(v3 * 14)))

			for _, guiObject in folder:GetDescendants() do
				if guiObject:IsA("GuiObject") then
					guiObject.ZIndex = 3
				end
			end

			local setSelected = CardSelect.attach(textButton, stroke, rimColor)
			local v32 = nil
			local function draw()
				local v37 = state(skin) -- inferred equivalent call
				fill.Visible = v37 == "level"
				folder.Visible = v37 == "paid"
				v30.Visible = v37 ~= "paid"

				if v37 == "equipped" then
					v30.Text = "EQUIPPED"
					v30.TextColor3 = Style.GOOD
				elseif v37 == "owned" then
					v30.Text = "OWNED"
					v30.TextColor3 = Style.WHITE
				elseif v37 == "level" then
					v30.Text = string.format("LEVEL %d", skin.level)
					v30.TextColor3 = Style.WHITE
				elseif v37 == "soon" then
					v30.Text = "COMING SOON"
					v30.TextColor3 = Style.WHITE
				else
					local outfit = ArmoryStore.outfit(player, skin.id, function()
						v32.draw()
					end)
					v31(nil, Style.thousands(outfit.price), Style.WHITE)
				end
			end
			v32 = {
				skin = skin,
				button = textButton,
				view = view,
				setSelected = setSelected,
				draw = draw,
				halo = imageLabel
			}
			table.insert(v20, v32)
			textButton.Activated:Connect(function()
				if v21 == skin and v24 then
					v25()
				else
					fn5(skin)
				end
			end)
		end

		local function shows(skin) -- 2 equivalent calls inferred from this helper
			if v22 == "owned" then
				return Skins.unlocked(player, skin.id)
			end

			return v22 ~= "premium" or skin.paid == true
		end

		local function layout()
			local v27 = {}

			for _, v28 in v20 do
				if v28.skin.paid and shows(v28.skin) then -- inferred equivalent call
					table.insert(v27, v28)
				end
			end

			for _, v28 in v20 do
				if v28.skin.paid or not shows(v28.skin) then -- inferred equivalent call
					continue
				end

				table.insert(v27, v28)
			end

			for _, v28 in v20 do
				v28.button.Visible = false

				if v28.halo then
					v28.halo.Visible = false
				end
			end

			for k, v28 in v27 do
				local v29 = (k - 1) % v15
				local v30 = (k - 1) // v15
				local v31 = v29 * (v16 + 12) + 12
				local v32 = v30 * (v18 + 12) + 12
				v28.button.Position = UDim2.fromOffset(v31, v32)
				v28.button.LayoutOrder = k
				v28.button.Visible = true

				if not v28.halo then
					continue
				end

				v28.halo.Position = UDim2.fromOffset(v31 + v16 // 2, v32 + v18 // 2)
				v28.halo.Visible = true
			end

			local v28 = math.ceil(#v27 / v15)
			cards.CanvasSize = UDim2.fromOffset(0, v28 * v18 + 24 + math.max(v28 - 1, 0) * 12)
			cards.CanvasPosition = Vector2.zero
			v19.Visible = #v27 == 0

			for _, v29 in v10 do
				local visible = v29.id == v22
				local label3 = v29.label
				local textColor

				if visible then
					textColor = Style.WHITE
				elseif v29.id == "premium" then
					textColor = color3
				else
					textColor = Style.MUTED
				end

				label3.TextColor3 = textColor
				v29.under.Visible = visible
				local button = v29.button
				local backgroundColor

				if visible then
					backgroundColor = color5
				else
					backgroundColor = Style.PANEL
				end

				button.BackgroundColor3 = backgroundColor
			end
		end

		local box = Style.box(parent2, "Stage", Style.INK, UDim2.fromOffset(v13, v11), 4, 3)
		box.Position = UDim2.fromOffset(v14, 64)
		box.ClipsDescendants = true
		local maxTextSize = math.floor(v3 * 40)
		local v27 = math.floor(v3 * 15) + 12 + 4

		local v28 = v27 + maxTextSize + 8
		local v29 = touch and 52 or 60
		local v30 = math.min(v13 - 32, (math.floor(v29 * 6.5)))
		local v31 = v11 - v29 - 14
		local v32 = math.floor(v3 * 15) + 6

		local v36 = v31 - 10 - 8
		local v37 = v36 - 6 - v32
		local v38 = v37 - 2

		local v39 = v38 - 2
		local v40 = v39 - v28 - 4
		local v41 = math.floor(v40 / 0.8)
		local v42 = math.ceil((math.max(v13, v11, (v11 - v39) / 0.26, v39 / 0.74)))
		local scene = Instance.new("ImageLabel")
		scene.Name = "Scene"
		scene.BackgroundTransparency = 1
		scene.Image = "rbxassetid://75413393261285"
		scene.ScaleType = Enum.ScaleType.Stretch
		scene.Size = UDim2.fromOffset(v42, v42)
		scene.Position = UDim2.fromOffset(math.floor((v13 - v42) / 2), (math.floor(v39 - v42 * 0.74)))
		scene.Parent = box

		local themedScene = scene:Clone()
		themedScene.Name = "ThemedScene"
		themedScene.Image = ""
		themedScene.ImageTransparency = 1
		themedScene.Parent = box
		local fill = Style.fill(box, "ThemeFlash", Style.WHITE, UDim2.fromScale(1, 1))
		fill.BackgroundTransparency = 1

		task.spawn(function()
			local images = {}

			for _, v43 in v do
				table.insert(images, v43.image)
			end

			pcall(ContentProvider.PreloadAsync, ContentProvider, images)
		end)
		local uiStroke = box:FindFirstChildOfClass("UIStroke")

		local v43 = math.floor((math.min(v13 * 1.25, v40 * 1.35)))
		local rarityLight = Instance.new("ImageLabel")
		rarityLight.Name = "RarityLight"
		rarityLight.BackgroundTransparency = 1
		rarityLight.Image = OutfitLook.LIGHT
		rarityLight.ImageTransparency = 0.3
		rarityLight.AnchorPoint = Vector2.new(0.5, 0.5)
		rarityLight.Size = UDim2.fromOffset(v43, v43)
		rarityLight.Position = UDim2.fromOffset(math.floor(v13 / 2), (math.floor(v39 - v40 * 0.55)))
		rarityLight.Parent = box
		local frame = Style.frame(
			box,
			"Soldier",
			UDim2.fromOffset(v13, v41),
			UDim2.fromOffset(0, (math.floor(v39 - v41 * 0.91)))
		)
		frame.ZIndex = 2
		local view = SkinPreview.view(frame, "full", "stage")
		view.frame.ZIndex = 2
		local v44 = label(
			box,
			"NoBody",
			"LOADING YOUR SOLDIER",
			math.floor(v3 * 16),
			0,
			math.floor(v11 * 0.42),
			v13,
			30,
			{ ax = Enum.TextXAlignment.Center, color = Style.MUTED, outline = 2 }
		)
		v44.ZIndex = 3

		local function scrim(p: string, p2: number, flag2: boolean)
			local fill2 = Style.fill(
				box,
				p,
				Style.INK,
				UDim2.fromOffset(v13, p2),
				UDim2.fromOffset(0, flag2 and 0 or v11 - p2)
			)
			fill2.BackgroundTransparency = 0.1
			fill2.ZIndex = 3
			local uiGradient = Instance.new("UIGradient")
			uiGradient.Rotation = flag2 and 90 or -90
			uiGradient.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.6, 0.35),
				NumberSequenceKeypoint.new(1, 1)
			})
			uiGradient.Parent = fill2
		end
		scrim("TopFade", v28 + 30, true)
		scrim("FootFade", v11 - v38 + 36, false)
		local v45 = label(box, "Rarity", "", math.floor(v3 * 15), 16, 12, v13 - 32, math.floor(v3 * 15) + 4, {
			outline = 2
		})
		v45.ZIndex = 4
		local parent3 = label(box, "Name", "", maxTextSize, 16, v27, v13 - 32, maxTextSize + 6, {
			outline = 2.5
		})
		parent3.TextScaled = true
		local uiTextSizeConstraint = Instance.new("UITextSizeConstraint")
		uiTextSizeConstraint.MaxTextSize = maxTextSize
		uiTextSizeConstraint.MinTextSize = 18
		uiTextSizeConstraint.Parent = parent3
		parent3.ZIndex = 4
		local v47 = label(box, "Line", "", math.floor(v3 * 15), 16, v37, v13 - 32, v32, {
			ax = Enum.TextXAlignment.Center,
			outline = 2
		})
		v47.RichText = true
		v47.ZIndex = 4

		local v48 = math.min(v13 - 32, 320)
		local fill2 = Style.fill(
			box,
			"Progress",
			Style.INK,
			UDim2.fromOffset(v48, 8),
			UDim2.fromOffset(math.floor((v13 - v48) / 2), v36)
		)
		fill2.ZIndex = 4
		Style.corner(fill2, 4)
		Style.stroke(fill2, 1.5, 0, Style.INK, true)
		local fill3 = Style.fill(fill2, "Fill", Style.HAZARD, UDim2.fromScale(0, 1))
		fill3.ZIndex = 4
		Style.corner(fill3, 4)
		local action = Instance.new("ImageButton")
		action.Name = "Action"
		action.BackgroundTransparency = 1
		action.AutoButtonColor = false
		action.Image = "rbxassetid://116067232788719"
		action.AnchorPoint = Vector2.new(0.5, 0.5)
		action.Size = UDim2.fromOffset(v30, v29)
		action.Position = UDim2.fromOffset(math.floor(v13 / 2), v31 + v29 / 2)
		action.ZIndex = 4
		action.Parent = box
		local uiScale = Instance.new("UIScale")
		uiScale.Parent = action
		local v49 = label(action, "Text", "", math.floor(v3 * 24), 0, 0, v30, v29, {
			ax = Enum.TextXAlignment.Center,
			outline = 2
		})
		v49.ZIndex = 5
		local folder, v50 = Style.robuxLine(action, "Robux", (math.floor(v3 * 22)))
		local v51 = nil

		for _, guiObject in folder:GetDescendants() do
			if guiObject:IsA("GuiObject") then
				guiObject.ZIndex = 5
			end
		end

		folder.ZIndex = 5
		local v52 = label(box, "Toast", "", math.floor(v3 * 15), 16, v38 - v32 - 4, v13 - 32, v32, {
			ax = Enum.TextXAlignment.Center,
			outline = 2,
			color = color4
		})
		v52.ZIndex = 5
		v52.Visible = false
		local count = 0
		local function showToast(text: string) -- 2 equivalent calls inferred from this helper
			count += 1
			local v53 = count
			v52.Text = text
			v52.Visible = true
			task.delay(2.4, function()
				if count == v53 then
					v52.Visible = false
				end
			end)
		end

		local v53 = touch and 76 or 70
		local v54 = touch and 44 or 32
		local v55 = {}

		for k, team in { "Reds", "Blues" } do
			local button, label3 = Style.button(
				box,
				"Camo" .. team,
				string.upper(team),
				Style.PANEL,
				UDim2.fromOffset(v53, v54),
				Style.MUTED,
				14
			)
			button.Position = UDim2.fromOffset(v13 - 16 - v53, v28 + 8 + (k - 1) * (v54 + 6))
			button.ZIndex = 4
			label3.ZIndex = 5
			table.insert(v55, { team = team, button = button, label = label3 })
		end

		local function held()
			local tool = player:GetAttribute(ShopData.PRIMARY_ATTR)

			if type(tool) ~= "string" or not ReplicatedStorage:WaitForChild("ToolTemplates"):FindFirstChild(tool) then
				tool = ShopData.DEFAULT_PRIMARY
			end

			return { tool = tool, skin = WeaponSkins.pick(player, tool) }
		end

		local function dressStage() -- 3 equivalent calls inferred from this helper
			local body = SkinPreview.body(player)
			v44.Visible = body == nil
			local show = view.show
			local v56

			if v21 and body then
				v56 = SkinPreview.dress(body, v21, v23, player.UserId, held())
			end

			show(v56)
		end
		local function dressCards()
			local body = SkinPreview.body(player)

			if body == v26 then
				return
			end

			v26 = body

			for _, v56 in v20 do
				local show = v56.view.show
				local v57

				if body then
					v57 = SkinPreview.dress(body, v56.skin, v23, player.UserId)
				end

				show(v57)
			end
		end

		local function ask(id: string)
			if flag then
				return
			end

			flag = true
			local success, result, v56 = pcall(shop.InvokeServer, shop, "skin", id)
			flag = false

			if success then
				if result == true then
					if MenuAudio.stamp then
						MenuAudio.stamp()
					end
				else
					showToast(string.upper(type(v56) ~= "string" and "" or v56)) -- inferred equivalent call

					if MenuAudio.deny then
						MenuAudio.deny()
					end
				end
			else
				warn("[Outfits] request failed: " .. tostring(result))
				showToast("NO ANSWER FROM THE ARMORY") -- inferred equivalent call
			end
		end

		local function drawStage()
			local IMAGE_ID = "rbxassetid://116067232788719"
			local v56 = v21

			if not v56 then
				return
			end

			local rarity = Skins.rarityOf(v56)
			v45.Text = rarity.name
			v45.TextColor3 = OutfitLook.tagColor(v56)
			rarityLight.ImageColor3 = rarity.color
			local glows = OutfitLook.glows(v56)
			rarityLight.ImageTransparency = glows and 0.05 or 0.3
			local v57 = math.floor(v43 * (glows and 1.25 or 1))
			rarityLight.Size = UDim2.fromOffset(v57, v57)

			if uiStroke then
				uiStroke.Color = OutfitLook.rimColor(v56)
			end

			local v58 = v[v56.id]

			if v58 then
				rarityLight.ImageColor3 = v58.color
				rarityLight.ImageTransparency = 0.35

				if uiStroke then
					uiStroke.Color = v58.color
				end
			end

			local v59 = v51
			local v60

			if v58 then
				v60 = v56.id
			end

			if v59 ~= v60 then
				local v61

				if v58 then
					v61 = v56.id
				end

				v51 = v61
				local frame2 = view.frame
				local ambient = if v58 then v58.ambient else color
				frame2.Ambient = ambient
				local frame3 = view.frame
				local lightColor = if v58 then v58.light else color2
				frame3.LightColor = lightColor

				if v58 then
					themedScene.Image = v58.image
					themedScene.ImageTransparency = 1
					TweenService:Create(
						themedScene,
						TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{ ImageTransparency = 0 }
					):Play()
					fill.BackgroundColor3 = v58.color
					fill.BackgroundTransparency = 0.45
					TweenService:Create(
						fill,
						TweenInfo.new(0.45499999999999996, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ BackgroundTransparency = 1 }
					):Play()
				else
					TweenService:Create(themedScene, TweenInfo.new(0.18), { ImageTransparency = 1 }):Play()
					fill.BackgroundTransparency = 1
				end
			end

			parent3.Text = string.upper(v56.name)
			local visible = v56.shirt == nil

			for _, v62 in v55 do
				v62.button.Visible = visible
				local v63 = v62.team == v23
				local button = v62.button
				local backgroundColor

				if v63 then
					backgroundColor = Style.teamColor(v62.team)
				else
					backgroundColor = Style.PANEL
				end

				button.BackgroundColor3 = backgroundColor
				local label3 = v62.label
				local textColor

				if v63 then
					textColor = Style.WHITE
				else
					textColor = Style.MUTED
				end

				label3.TextColor3 = textColor
			end

			local v62 = state(v56) -- inferred equivalent call
			fill2.Visible = v62 == "level"
			folder.Visible = v62 == "paid"
			v49.Visible = v62 ~= "paid"
			v24 = v62 == "owned"
			action.Selectable = v62 == "owned" or v62 == "paid"

			if v62 == "equipped" then
				action.Image = IMAGE_ID
				v49.Text = "EQUIPPED"
				v49.TextColor3 = Style.GOOD
				v47.Text = ""
				v25 = function() end
			elseif v62 == "owned" then
				action.Image = "rbxassetid://98153179041297"
				v49.Text = "EQUIP"
				v49.TextColor3 = Style.WHITE
				v47.Text = ""
				v25 = function()
					ask(v56.id)
				end
			elseif v62 == "soon" then
				action.Image = IMAGE_ID
				v49.Text = "COMING SOON"
				v49.TextColor3 = Style.MUTED
				v47.Text = ""
				v25 = function() end
			elseif v62 == "level" then
				local level = Skins.levelOf(player)
				action.Image = IMAGE_ID
				v49.Text = string.format("REACH LEVEL %d", v56.level)
				v49.TextColor3 = Style.WHITE
				v47.Text = Style.paint(string.format("YOU ARE LEVEL %d", level), Style.WHITE)
				fill3.Size = UDim2.fromScale(math.clamp(level / v56.level, 0, 1), 1)
				v25 = function()
					if MenuAudio.deny then
						MenuAudio.deny()
					end
				end
			else
				local outfit = ArmoryStore.outfit(player, v56.id, function()
					fn()
				end)
				local bundleFor = WeaponSkins.bundleFor(v56.id)
				action.Image = "rbxassetid://80064079542018"
				v50(outfit.label, Style.thousands(outfit.price), Style.WHITE)
				v47.Text = Style.paint("OUTFIT + GUN SKIN", OutfitLook.tagColor(v56)) .. (not bundleFor and "" or "  " .. Style.paint(string.upper(bundleFor.name), Style.WHITE))
				v25 = outfit.run
			end
		end

		fn5 = function(p)
			local v56 = v21 ~= p
			v21 = p

			for _, v57 in v20 do
				v57.setSelected(v57.skin == p)
			end

			if v56 then
				view.resetTurn()
			end

			drawStage()
			dressStage() -- inferred equivalent call
		end

		action.Activated:Connect(function()
			v25()
		end)

		action.MouseEnter:Connect(function()
			if action.Selectable then
				TweenService:Create(uiScale, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Scale = 1.05
				}):Play()
			end
		end)
		action.MouseLeave:Connect(function()
			TweenService:Create(uiScale, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Scale = 1
			}):Play()
		end)
		action.InputBegan:Connect(function(input)
			local userInputType = input.UserInputType

			if userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.Touch then
				TweenService:Create(uiScale, TweenInfo.new(0.07), { Scale = 0.95 }):Play()
			end
		end)
		action.InputEnded:Connect(function(input)
			local userInputType = input.UserInputType

			if userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.Touch then
				TweenService:Create(uiScale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Scale = 1
				}):Play()
			end
		end)

		for _, v56 in v55 do
			v56.button.Activated:Connect(function()
				if v23 ~= v56.team then
					v23 = v56.team
					v26 = nil
					dressCards()
					drawStage()
					dressStage() -- inferred equivalent call
				end
			end)
		end

		for _, v56 in v10 do
			v56.button.Activated:Connect(function()
				if v22 ~= v56.id then
					v22 = v56.id
					layout()
					PadMenus.reseat()
				end
			end)
		end

		fn = function()
			for _, v56 in v20 do
				v56.draw()
			end

			if v22 == "owned" then
				layout()
			end

			drawStage()
		end
		fn2 = function()
			dressCards()

			if not v21 then
				v22 = "all"
				layout()
			end

			fn5(v21 or Skins.get(Skins.pick(player)))
			fn()
		end
		fn3 = function()
			for _, v56 in v20 do
				if v56.skin == v21 and v56.button.Visible then
					return v56.button
				end
			end

			for _, v56 in v20 do
				if v56.button.Visible then
					return v56.button
				end
			end

			return nil
		end

		fn4 = function(p: number)
			local v56 = 1

			for k, v57 in v2 do
				if v57.id == v22 then
					v56 = k
				end
			end

			v22 = v2[(v56 - 1 + p) % #v2 + 1].id
			layout()
			PadMenus.reseat()
		end

		local function bodyChanged()
			if layer2.Enabled then
				dressCards()
				dressStage() -- inferred equivalent call
			end
		end
		data.playerGui.ChildAdded:Connect(function(child)
			if child.Name == "SoldierBody" then
				task.defer(bodyChanged)
			end
		end)
		player.CharacterAdded:Connect(function()
			task.delay(1, bodyChanged)
		end)
		player:GetPropertyChangedSignal("Team"):Connect(function()
			local name = player.Team and player.Team.Name

			if (name == "Reds" or name == "Blues") and name ~= v23 then
				v23 = name
				v26 = nil
			end
		end)
		player.AttributeChanged:Connect(function(value: string)
			if
				value == "Level"
				or value == Skins.ATTR
				or value == "UnlockAll"
				or value == Skins.PACK_ATTR
				or string.sub(value, 1, 12) == "Owns_Outfit_"
			then
				fn()
			end
		end)
		layout()
	end

	local v6 = false
	local count = 0
	local tweens = {}
	local mouseIconEnabled = true
	local udim = UDim2.new()

	local v7 = false
	local fn5
	local function toggle()
		v6 = not v6

		if not v6 then
			v7 = false
		end

		if v6 then
			if not v4 then
				build()
			end

			if Armory.close then
				Armory.close()
			end

			local Store = require(script.Parent:WaitForChild("Store"))

			if Store.close then
				Store.close()
			end

			local Quests = require(script.Parent:WaitForChild("Quests"))

			if Quests.close then
				Quests.close()
			end

			mouseIconEnabled = UserInputService.MouseIconEnabled
			UserInputService.MouseIconEnabled = true
		else
			UserInputService.MouseIconEnabled = mouseIconEnabled
		end

		count += 1
		local v8 = count

		for _, v9 in tweens do
			v9:Cancel()
		end

		table.clear(tweens)
		local function tween(instance, duration: number, p, p2, goal) -- 6 equivalent calls inferred from this helper
			local tween2 = TweenService:Create(instance, TweenInfo.new(duration, p, p2), goal)
			table.insert(tweens, tween2)
			tween2:Play()
			return tween2
		end

		if v6 then
			if not layer.Enabled then
				room.ImageTransparency = 1
				room.BackgroundTransparency = 1
				v5.BackgroundTransparency = 1
				parent2.Position = udim + UDim2.fromScale(0, 0.22)
			end

			layer.Enabled = true
			layer2.Enabled = true
			fn2()
			tween(room, 0.256, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, { -- inferred equivalent call
				ImageTransparency = 0,
				BackgroundTransparency = 0
			})
			tween(v5, 0.256, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, { -- inferred equivalent call
				BackgroundTransparency = 0.7
			})
			tween(parent2, 0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, { -- inferred equivalent call
				Position = udim
			})
		else
			tween(room, 0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.In, { -- inferred equivalent call
				ImageTransparency = 1,
				BackgroundTransparency = 1
			})
			tween(v5, 0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.In, { -- inferred equivalent call
				BackgroundTransparency = 1
			})
			tween(parent2, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In, { -- inferred equivalent call
				Position = udim + UDim2.fromScale(0, 0.22)
			}).Completed:Once(function()
				if count == v8 then
					layer.Enabled = false
					layer2.Enabled = false
				end
			end)
		end

		data.setMenu(v6)

		if v6 then
			PadMenus.open("outfits", parent, fn5, {
				first = function()
					return fn3()
				end,
				tab = function(p: number)
					fn4(p)
				end
			})
		else
			PadMenus.close("outfits")
		end
	end
	fn5 = function()
		local v8 = v7
		toggle()

		if v8 and Armory.toggle then
			Armory.toggle()
		end
	end
	Outfits.leave = fn5
	Outfits.toggle = toggle
	function Outfits.isOpen()
		return v6
	end

	function Outfits.open(flag: boolean?)
		if not v6 then
			toggle()
		end

		v7 = flag == true
	end
	function Outfits.close()
		if v6 then
			toggle()
		end
	end

	data.onTeam(function(p: string?)
		if p ~= nil and v6 then
			toggle()
		end
	end)
	data.onDead(function(flag: boolean)
		if flag and v6 then
			toggle()
		end
	end)
end

return Outfits