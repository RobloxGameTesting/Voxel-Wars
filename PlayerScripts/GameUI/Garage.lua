local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Style = require(script.Parent:WaitForChild("Style"))
local NewMenus = require(script.Parent:WaitForChild("NewMenus"))
local Armory = require(script.Parent:WaitForChild("Armory"))
local PadMenus = require(script.Parent:WaitForChild("PadMenus"))
local CardSelect = require(script.Parent:WaitForChild("CardSelect"))
local MenuAudio = require(script.Parent:WaitForChild("MenuAudio"))
local ClaimFx = require(script.Parent:WaitForChild("ClaimFx"))
local UiTrack = require(script.Parent:WaitForChild("UiTrack"))
local VehiclePreview = require(script.Parent:WaitForChild("VehiclePreview"))
require(script.Parent:WaitForChild("GarageIcons"))
local OutfitLook = require(script.Parent:WaitForChild("OutfitLook"))
local Glyph = require(script.Parent:WaitForChild("Glyph"))
local GarageArt = require(script.Parent:WaitForChild("GarageArt"))
local VehicleLoadouts = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("VehicleLoadouts"))
local VehicleMastery = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("VehicleMastery"))
require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("VehicleBayData"))

local Garage = {
	["ON"] = NewMenus.on("Vehicles"),
	toggle = nil,
	open = nil,
	close = nil,
	isOpen = nil,
	leave = nil
}

local color = Color3.fromRGB(255, 132, 110)
local color2 = Color3.fromRGB(34, 36, 42)
local color3 = Color3.fromRGB(46, 49, 57)
local color4 = Color3.fromRGB(8, 8, 10)

local v = {
	scrap = "NOT ENOUGH SCRAP",
	level = "LEVEL TOO LOW",
	owned = "ALREADY UNLOCKED",
	locked = "UNLOCK IT FIRST",
	bad = "NOT AVAILABLE",
	busy = "ONE MOMENT"
}

local function label(p, p2: string, p3: string, p4: number, p5: number, p6: number, p7: number, p8: number, options)
	local v2 = options or {}
	local label2 = Style.label(p, p2, p3, p4, v2.font or Style.FONT, v2.outline or 0)
	label2.AutomaticSize = Enum.AutomaticSize.None
	label2.Position = UDim2.fromOffset(p5, p6)
	label2.Size = UDim2.fromOffset(p7, p8)
	label2.TextXAlignment = v2.ax or Enum.TextXAlignment.Left
	label2.TextYAlignment = v2.ay or Enum.TextYAlignment.Center
	label2.TextColor3 = v2.color or Style.WHITE
	label2.TextWrapped = v2.wrap == true
	local uiStroke = label2:FindFirstChildOfClass("UIStroke")

	if uiStroke then
		uiStroke.LineJoinMode = Enum.LineJoinMode.Round
	end

	return label2
end

local function shrink(parent, maxTextSize: number, minTextSize: number) -- 16 equivalent calls inferred from this helper
	parent.TextScaled = true
	local uiTextSizeConstraint = Instance.new("UITextSizeConstraint")
	uiTextSizeConstraint.MaxTextSize = maxTextSize
	uiTextSizeConstraint.MinTextSize = minTextSize
	uiTextSizeConstraint.Parent = parent
end

local function tick(textButton, p: number)
	local fill = Style.fill(textButton, "Tick", Style.GOOD, UDim2.fromOffset(p, p))
	Style.corner(fill, p)
	Style.stroke(fill, 1.5, 0, Style.INK, true)
	local fill_2 = Style.fill(
		fill,
		"Short",
		Style.INK,
		UDim2.fromScale(0.16, 0.34),
		UDim2.fromScale(0.34, 0.6),
		Vector2.new(0.5, 0.5)
	)
	fill_2.Rotation = -45
	local fill_3 = Style.fill(
		fill,
		"Long",
		Style.INK,
		UDim2.fromScale(0.16, 0.6),
		UDim2.fromScale(0.58, 0.49),
		Vector2.new(0.5, 0.5)
	)
	fill_3.Rotation = 40
	return fill
end

local function scroller(parent, name: string, p: number, p2: number, p3: number, p4: number, scrollBarThickness: number)
	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Name = name
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.Position = UDim2.fromOffset(p, p2)
	scrollingFrame.Size = UDim2.fromOffset(p3, p4)
	scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
	scrollingFrame.ScrollBarThickness = scrollBarThickness
	scrollingFrame.ScrollBarImageColor3 = Style.HAZARD
	scrollingFrame.CanvasSize = UDim2.new()
	scrollingFrame.Selectable = false
	scrollingFrame.Parent = parent
	return scrollingFrame
end

local function plate(parent, name: string, image: string)
	local plates = GarageArt.PLATES
	local v2 = type(plates) == "table" and type(image) == "string" and image ~= ""
	assert(v2, "[Garage] GameUI.GarageArt.PLATES has no picture for " .. name)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = name
	imageLabel.BackgroundTransparency = 1
	imageLabel.BorderSizePixel = 0
	imageLabel.Image = image
	imageLabel.ScaleType = Enum.ScaleType.Slice
	imageLabel.SliceCenter = plates.slice
	imageLabel.SliceScale = plates.scale
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.ZIndex = 0
	imageLabel.Parent = parent
	return imageLabel
end

function Garage.mount(data)
	if not Garage.ON then
		return
	end

	local player = data.player
	local touch = Style.isTouch()
	local vehicleLoadout = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Remotes"):WaitForChild(
		"VehicleLoadout",
		30
	)
	assert(
		vehicleLoadout and vehicleLoadout:IsA("RemoteFunction"),
		"[Garage] remote Game.Remotes.VehicleLoadout (RemoteFunction) is missing"
	)

	local layer = Style.layer(data.playerGui, "GarageBackdrop", 10, true)
	layer.Enabled = false
	local layer2 = Style.layer(data.playerGui, "GarageWindow", 11)
	layer2.Enabled = false
	local v2 = touch and 1 or 1.3

	local function S(p: number) -- 4 equivalent calls inferred from this helper
		return (math.floor(p * v2))
	end

	local v3 = false
	local room = nil
	local v4 = nil
	local parent2 = nil
	local v5 = nil
	local function fn() end
	local function fn2() end
	local function fn3() end
	local function fn4(): nil
		return nil
	end

	local function fn5(_: number) end

	local function build()
		local room2 = layer:FindFirstChild("Room")
		local garage = layer2:FindFirstChild("Garage")

		if room2 then
			room2:Destroy()
		end

		if garage then
			garage:Destroy()
		end

		local list = VehicleLoadouts.LIST
		assert(
			#list > 0,
			"[Garage] ReplicatedStorage.Game.VehicleLoadouts has no vehicles (Ground / Air rows are empty)"
		)
		local v6 = type(GarageArt.BAY) == "table" and type(GarageArt.BAY.vehicles) == "table"
		assert(v6, "[Garage] GameUI.GarageArt.BAY is not set")
		room = Instance.new("ImageLabel")
		room.Name = "Room"
		room.BorderSizePixel = 0
		room.BackgroundColor3 = Style.INK
		room.Image = ""
		room.ScaleType = Enum.ScaleType.Crop
		room.Size = UDim2.fromScale(1, 1)
		room.Active = true
		room.Parent = layer
		v4 = Style.fill(room, "Ink", Style.INK, UDim2.fromScale(1, 1))
		v4.BackgroundTransparency = 0.86
		local v7 = touch and 540 or 700
		local viewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(16, 9)
		local v8 = math.floor(v7 * math.clamp(viewportSize.X / math.max(viewportSize.Y, 1), 1.6, 2.2))
		parent2 = Style.region(layer2, "Garage", Vector2.new(0.5, 0.5), Vector2.zero, Vector2.new(v8, v7))
		Style.fit(parent2, Vector2.new(v8, v7), 0.98)
		local modal = Instance.new("TextButton")
		modal.Name = "Modal"
		modal.Text = ""
		modal.BackgroundTransparency = 1
		modal.Size = UDim2.fromOffset(1, 1)
		modal.Modal = true
		modal.Selectable = false
		modal.Parent = parent2
		v5 = Style.frame(parent2, "Body", UDim2.fromScale(1, 1))

		local label2 = Style.label(v5, "Title", "VEHICLES", 44, Style.FONT, 2.5)
		label2.TextColor3 = Style.HAZARD
		label2.Position = UDim2.fromOffset(16, 4)

		local frame = Style.frame(v5, "PadHints", UDim2.fromOffset(120, 26), UDim2.new(0, 16, 0, 4))
		frame.AnchorPoint = Vector2.new(0, 0)
		local function placeHints()
			frame.Position = UDim2.fromOffset(
				16 + label2.AbsoluteSize.X / math.max(parent2.AbsoluteSize.X / v8, 0.01) + 18,
				16
			)
		end
		local uiListLayout = Instance.new("UIListLayout")
		uiListLayout.FillDirection = Enum.FillDirection.Horizontal
		uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		uiListLayout.Padding = UDim.new(0, 6)
		uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uiListLayout.Parent = frame
		local cap = Glyph.cap(frame, nil, Enum.KeyCode.ButtonL1, 22)
		cap.LayoutOrder = 1
		local cap_2 = Glyph.cap(frame, nil, Enum.KeyCode.ButtonR1, 22)
		cap_2.LayoutOrder = 2
		label2:GetPropertyChangedSignal("AbsoluteSize"):Connect(placeHints)
		task.defer(placeHints)
		local fill = Style.fill(v5, "HeaderRule", Style.HAZARD, UDim2.new(1, -32, 0, 2), UDim2.fromOffset(16, 56))
		local uiGradient = Instance.new("UIGradient")
		uiGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2),
			NumberSequenceKeypoint.new(0.5, 0.75),
			NumberSequenceKeypoint.new(1, 1)
		})
		uiGradient.Parent = fill
		local v9 = Style.closeButton(v5)
		v9.AnchorPoint = Vector2.new(1, 0)
		v9.Position = UDim2.new(1, -16, 0, 8)
		v9.Activated:Connect(function()
			Garage.leave()
		end)
		local box = Style.box(v5, "Scrap", Style.INK, UDim2.fromOffset(0, 40), 3, 1.5)
		box.AutomaticSize = Enum.AutomaticSize.X
		box.AnchorPoint = Vector2.new(1, 0)
		box.Position = UDim2.new(1, -(16 + Style.CLOSE_SIZE + 10), 0, 10)
		local uiListLayout2 = Instance.new("UIListLayout")
		uiListLayout2.FillDirection = Enum.FillDirection.Horizontal
		uiListLayout2.VerticalAlignment = Enum.VerticalAlignment.Center
		uiListLayout2.Padding = UDim.new(0, 6)
		uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
		uiListLayout2.Parent = box
		local uiPadding = Instance.new("UIPadding")
		uiPadding.PaddingLeft = UDim.new(0, 10)
		uiPadding.PaddingRight = UDim.new(0, 12)
		uiPadding.Parent = box
		local nut = Style.nut(box, 20)
		nut.LayoutOrder = 1
		local label3 = Style.label(box, "Amount", "0", 22, Style.FONT, 0)
		label3.LayoutOrder = 2
		label3.TextColor3 = Style.HAZARD

		local function scrapOf() -- 3 equivalent calls inferred from this helper
			local scrap = player:GetAttribute("Scrap")
			return if type(scrap) == "number" then scrap else 0
		end

		local function levelOf() -- 1 equivalent call inferred from this helper
			local level = player:GetAttribute("Level")
			return if type(level) == "number" then level else 1
		end

		local v10 = v7 - 64 - 16
		local v11 = touch and 188 or 232
		local v12 = v11 + 16 + 16
		local v13 = v8 - 16 - v12
		local v14 = touch and 54 or 60
		local v15 = touch and 40 or 54
		local v16 = (math.floor(v2 * 13) + 1) * 2 + 2
		local v17 = math.floor(v2 * 12) + 6

		local v18 = v15 + 8 + 4 + v16 + 2 + v17 + 6
		local v19 = v10 - v14 - v18 - 16 - 8 - 8

		local v20 = math.floor((math.clamp(v13 * 0.5, 400, 560)))

		local v21 = v13 - v20 - 16
		local v22 = v12 + v21 + 16
		local v23 = v19 + 64 + 16
		local v24 = v23 + v14 + 8

		local v25 = nil
		local v26 = nil
		local v27 = nil
		local flag = false
		local function fn6() end
		local v28 = false

		local function state(p, p2, data2): string
			if VehicleLoadouts.equipped(player, p.id, p2.id) == data2 then
				return "equipped"
			end

			if VehicleLoadouts.owns(player, p.id, p2.id, data2.id) then
				return "owned"
			end

			if data2.level ~= nil and levelOf() < data2.level then -- inferred equivalent call
				return "level"
			end

			if scrapOf() < data2.scrap then -- inferred equivalent call
				return "poor"
			end

			return "buy"
		end

		local function feel(textButton, face)
			local uiScale = Instance.new("UIScale")
			uiScale.Parent = textButton
			textButton.MouseEnter:Connect(function()
				TweenService:Create(textButton, TweenInfo.new(0.1), {
					BackgroundColor3 = face():Lerp(Style.WHITE, 0.09)
				}):Play()

				if MenuAudio.hover then
					MenuAudio.hover()
				end
			end)
			textButton.MouseLeave:Connect(function()
				TweenService:Create(textButton, TweenInfo.new(0.14), { BackgroundColor3 = face() }):Play()
			end)
			textButton.InputBegan:Connect(function(input)
				local userInputType = input.UserInputType

				if userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.Touch then
					TweenService:Create(uiScale, TweenInfo.new(0.07), { Scale = 0.96 }):Play()
				end
			end)
			textButton.InputEnded:Connect(function(input)
				local userInputType = input.UserInputType

				if userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.Touch then
					TweenService:Create(uiScale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Scale = 1
					}):Play()
				end
			end)
		end

		local vehicleBay = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Remotes"):WaitForChild("VehicleBay", 30)
		assert(
			vehicleBay and vehicleBay:IsA("RemoteFunction"),
			"[Garage] remote Game.Remotes.VehicleBay (RemoteFunction) is missing"
		)
		local v29 = nil
		local v30 = {}
		local fn7
		local fn8
		local function loadBay() -- 1 equivalent call inferred from this helper
			task.spawn(function()
				local success, result = pcall(vehicleBay.InvokeServer, vehicleBay, "state")

				if success and type(result) == "table" and type(result.items) == "table" then
					table.clear(v30)
					local v31 = {}

					for k, item in result.items do
						local v32

						if type(item) == "table" then
							v32 = item.owned == true
						else
							v32 = false
						end

						v31[k] = v32

						if not v32 then
							if type(item) == "table" and type(item.calls) == "number" then
								v32 = item.calls > 0
							else
								v32 = false
							end
						end

						v30[k] = v32
					end

					v29 = v31
					fn8()

					if v25 then
						fn7()
					end
				elseif not success then
					warn("[Garage] Vehicle Bay state failed: " .. tostring(result))
				end
			end)
		end

		local function shown(_): boolean -- 1 equivalent call inferred from this helper
			return true
		end

		local function showing(p: string?)
			local result = {}

			for _, v31 in VehicleLoadouts.KINDS do
				if not (p == nil or p == v31) then
					continue
				end

				for _, item in list do
					if item.kind == v31 then
						table.insert(result, item)
					end
				end
			end

			return result
		end

		local v31 = VehicleLoadouts.KINDS[1]

		local frame2 = Style.frame(v5, "Kinds", UDim2.fromOffset(v11, 44), UDim2.fromOffset(16, 64))
		local count = #VehicleLoadouts.KINDS
		local v32 = math.floor((v11 - (count - 1) * 8) / count)
		local v34 = { ground = "GROUND", air = "AIR" }

		local v35 = {}
		local fn9
		local v36 = nil

		for k, v37 in VehicleLoadouts.KINDS do
			assert(v34[v37], "[Garage] no name for the vehicle category " .. tostring(v37))
			local textButton = Instance.new("TextButton")
			textButton.Name = v37
			textButton.Text = ""
			textButton.AutoButtonColor = false
			textButton.BorderSizePixel = 0
			textButton.BackgroundColor3 = Style.PANEL
			textButton.Size = UDim2.fromOffset(v32, 44)
			textButton.Position = UDim2.fromOffset((k - 1) * (v32 + 8), 0)
			textButton.LayoutOrder = k
			textButton.Parent = frame2
			Style.corner(textButton, 6)
			local parent = label(textButton, "Name", v34[v37], math.floor(v2 * 16), 4, 0, v32 - 8, 40, {
				ax = Enum.TextXAlignment.Center,
				outline = 2
			})
			shrink(parent, math.floor(v2 * 16), 12) -- inferred equivalent call

			local fill2 = Style.fill(
				textButton,
				"Under",
				Style.HAZARD,
				UDim2.new(1, -20, 0, 3),
				UDim2.new(0, 10, 1, -7)
			)
			Style.corner(fill2, 2)
			local function face() -- 1 equivalent call inferred from this helper
				return if v31 == v37 then color2 else Style.PANEL
			end

			local function draw()
				local visible = v31 == v37
				textButton.BackgroundColor3 = face() -- inferred equivalent call
				local textColor

				if visible then
					textColor = Style.HAZARD
				else
					textColor = Style.MUTED
				end

				parent.TextColor3 = textColor
				fill2.Visible = visible
			end
			feel(textButton, face)
			table.insert(v35, { kind = v37, draw = draw })
			textButton.Activated:Connect(function()
				if v31 ~= v37 then
					fn9(v37)

					if MenuAudio.press then
						MenuAudio.press()
					end

					PadMenus.reseat()
				end
			end)
		end

		local v37 = v11 - 6 - 24
		local v38 = touch and 84 or 104
		local parent3 = scroller(v5, "Vehicles", 16, 114, v11, v10 - 44 - 6, 6)

		local v40 = {}
		local fn10

		for k, item in list do
			local textButton = Instance.new("TextButton")
			textButton.Name = item.id
			textButton.Text = ""
			textButton.AutoButtonColor = false
			textButton.BorderSizePixel = 0
			textButton.BackgroundColor3 = Style.PANEL
			textButton.Size = UDim2.fromOffset(v37, v38)
			textButton.Visible = false
			textButton.LayoutOrder = k
			textButton.Parent = parent3
			Style.corner(textButton, 6)
			local stroke = Style.stroke(textButton, 2, 0, Style.STEEL, true)
			local v41 = math.floor(v2 * 16) + 10

			local frame3 = Style.frame(
				textButton,
				"Picture",
				UDim2.fromOffset(v37 - 20, v38 - v41 - 10),
				UDim2.fromOffset(10, 6)
			)

			local vehicle = GarageArt.BAY.vehicles[item.id]
			local v42 = type(vehicle) == "table" and type(vehicle.icon) == "string" and vehicle.icon ~= ""
			assert(v42, "[Garage] GameUI.GarageArt.BAY.vehicles has no icon for vehicle " .. tostring(item.id))
			local icon = Instance.new("ImageLabel")
			icon.Name = "Icon"
			icon.BackgroundTransparency = 1
			icon.Image = vehicle.icon
			icon.ScaleType = Enum.ScaleType.Fit
			icon.Size = UDim2.fromScale(1, 1)
			icon.Parent = frame3
			local v43 = math.floor(v2 * 12) * 3 + 12
			local v44 = math.floor(v2 * 12) + 8
			shrink( -- inferred equivalent call
				label(textButton, "Name", item.name, math.floor(v2 * 16), 10, v38 - v41 - 2, v37 - 26 - v43, v41, {
					outline = 2
				}),
				math.floor(v2 * 16),
				12
			)

			local box2 = Style.box(textButton, "Level", Style.INK, UDim2.fromOffset(v43, v44), 2, 1)
			box2.AnchorPoint = Vector2.new(1, 1)
			box2.Position = UDim2.new(1, -8, 1, -7)
			local v45 = label(box2, "Text", "", math.floor(v2 * 12), 0, 0, v43, v44, {
				ax = Enum.TextXAlignment.Center
			})
			local setSelected = CardSelect.attach(textButton, stroke, Style.STEEL)
			local function face() -- 1 equivalent call inferred from this helper
				return if v25 == item then color2 else Style.PANEL
			end

			local function draw()
				local level = VehicleMastery.level(player, item.id)
				local v47 = VehicleMastery.MAX_LEVEL <= level
				v45.Text = string.format("LV %d", level)
				local textColor = if v47 then Style.INK else Style.WHITE
				v45.TextColor3 = textColor
				local backgroundColor

				if v47 then
					backgroundColor = Style.HAZARD
				else
					backgroundColor = Style.INK
				end

				box2.BackgroundColor3 = backgroundColor
				textButton.BackgroundColor3 = face() -- inferred equivalent call
			end
			feel(textButton, face)
			table.insert(v40, {
				vehicle = item,
				button = textButton,
				setSelected = setSelected,
				draw = draw
			})
			textButton.Activated:Connect(function()
				if v25 ~= item then
					fn10(item)

					if MenuAudio.press then
						MenuAudio.press()
					end
				end
			end)
		end

		fn8 = function()
			local count2 = 0

			for _, v41 in v40 do
				local visible

				if v41.vehicle.kind == v31 then
					local _vehicle = v41.vehicle
					visible = shown() -- inferred equivalent call
				else
					visible = false
				end

				v41.button.Visible = visible

				if not visible then
					continue
				end

				v41.button.Position = UDim2.fromOffset(12, count2 * (v38 + 10) + 12)
				count2 += 1
			end

			parent3.CanvasSize = UDim2.fromOffset(0, count2 * v38 + 24 + math.max(count2 - 1, 0) * 10)

			if v36 ~= v31 then
				parent3.CanvasPosition = Vector2.zero
			end

			v36 = v31

			for _, v41 in v35 do
				v41.draw()
			end
		end
		fn9 = function(p: string)
			v31 = p
			fn8()
			local v41 = (not v25 or v25.kind ~= p) and showing(p)[1]

			if v41 then
				fn10(v41)
			end
		end

		local frame3 = Style.frame(v5, "Stage", UDim2.fromOffset(v13, v19), UDim2.fromOffset(v12, 64))
		local floorGlow = Instance.new("ImageLabel")
		floorGlow.Name = "FloorGlow"
		floorGlow.BackgroundTransparency = 1
		floorGlow.Image = OutfitLook.LIGHT
		floorGlow.ImageColor3 = Style.HAZARD
		floorGlow.ImageTransparency = 0.74
		floorGlow.AnchorPoint = Vector2.new(0.5, 0.5)
		floorGlow.Size = UDim2.fromOffset(math.floor(v13 * 1.1), (math.floor(v19 * 0.6)))
		floorGlow.Position = UDim2.fromOffset(math.floor(v13 / 2), (math.floor(v19 * 0.72)))
		floorGlow.Parent = frame3
		local fill2 = Style.fill(
			frame3,
			"BayLine",
			Style.HAZARD,
			UDim2.fromOffset(math.floor(v13 * 0.86), 3),
			UDim2.fromOffset(math.floor(v13 * 0.07), v19 - 6)
		)
		local uiGradient2 = Instance.new("UIGradient")
		uiGradient2.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.18, 0.3),
			NumberSequenceKeypoint.new(0.82, 0.3),
			NumberSequenceKeypoint.new(1, 1)
		})
		uiGradient2.Parent = fill2
		floorGlow.Visible = false
		fill2.Visible = false
		local frame_2 = Style.frame(frame3, "Vehicle", UDim2.fromScale(1, 1))
		frame_2.ZIndex = 2

		local id = nil
		local v41 = 0
		local v42 = math.floor((math.min(v13 * 0.6, math.floor(v2 * 13) * 24)))
		local v43 = math.floor(v2 * 26) + 6 + 6
		local v44 = v43 + math.floor(v2 * 13) + 9

		local fill3 = Style.fill(frame3, "NameShade", Style.INK, UDim2.fromOffset(v42, v44 + 16))
		fill3.ZIndex = 3
		Style.corner(fill3, 4)
		local uiGradient3 = Instance.new("UIGradient")
		uiGradient3.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.4),
			NumberSequenceKeypoint.new(0.55, 0.7),
			NumberSequenceKeypoint.new(1, 1)
		})
		uiGradient3.Parent = fill3
		local parent4 = label(frame3, "Name", "", math.floor(v2 * 26), 10, 6, v42 - 20, math.floor(v2 * 26) + 6, {
			outline = 2.5
		})
		parent4.ZIndex = 4
		shrink(parent4, math.floor(v2 * 26), 14) -- inferred equivalent call
		local parent5 = label(frame3, "Level", "", math.floor(v2 * 13), 10, v43, v42 - 20, math.floor(v2 * 13) + 4, {
			outline = 2,
			color = Style.HAZARD
		})
		parent5.ZIndex = 4
		shrink(parent5, math.floor(v2 * 13), 12) -- inferred equivalent call
		local v47 = touch and 110 or 140
		local fill4 = Style.fill(frame3, "LevelTrack", color4, UDim2.fromOffset(v47, 6), UDim2.fromOffset(10, v44))
		fill4.ZIndex = 4
		Style.corner(fill4, 3)
		Style.stroke(fill4, 1, 0, Style.STEEL, true)
		local fill5 = Style.fill(fill4, "Fill", Style.HAZARD, UDim2.fromScale(0, 1))
		fill5.ZIndex = 4
		Style.corner(fill5, 3)
		local v48 = label(
			frame3,
			"Xp",
			"",
			math.floor(v2 * 12),
			v47 + 10 + 8,
			v44 + 3 - math.floor((math.floor(v2 * 12) + 4) / 2),
			v42 - v47 - 28,
			math.floor(v2 * 12) + 4,
			{ outline = 2, color = Style.MUTED }
		)
		v48.ZIndex = 4
		local box2 = Style.box(
			frame3,
			"Bay",
			Style.INK,
			UDim2.fromOffset(math.min(v13 - 24, math.floor(v2 * 12) * 24), math.floor(v2 * 12) + 14),
			3,
			1.5
		)
		box2.Position = UDim2.fromOffset(10, v19 - math.floor(v2 * 12) - 14 - 16)
		box2.BackgroundTransparency = 0.15
		box2.ZIndex = 4
		box2.Visible = false
		local parent6 = label(
			box2,
			"Text",
			"CALLED FROM THE AIR VEHICLES PAD",
			math.floor(v2 * 12),
			8,
			0,
			math.min(v13 - 24, math.floor(v2 * 12) * 24) - 16,
			math.floor(v2 * 12) + 14,
			{ color = Style.HAZARD }
		)
		parent6.ZIndex = 5
		shrink(parent6, math.floor(v2 * 12), 12) -- inferred equivalent call

		local turn = Instance.new("TextButton")
		turn.Name = "Turn"
		turn.Text = ""
		turn.BackgroundTransparency = 1
		turn.Size = UDim2.fromScale(1, 1)
		turn.Selectable = false
		turn.AutoButtonColor = false
		turn.ZIndex = 6
		turn.Visible = false
		turn.Parent = frame3

		local bay = GarageArt.BAY
		local frame4 = Style.frame(room, "Hall", UDim2.fromOffset(16, 9))
		v4.ZIndex = 6
		local fills = {}

		for i = 1, 2 do
			local fill6 = Style.fill(
				frame4,
				i == 1 and "TopFade" or "BottomFade",
				Style.INK,
				UDim2.fromScale(1, 0.22),
				UDim2.fromScale(0, i == 1 and 0 or 0.78)
			)
			fill6.ZIndex = 5
			local uiGradient4 = Instance.new("UIGradient")
			uiGradient4.Rotation = 90
			local transparency

			if i == 1 then
				transparency = NumberSequence.new(0, 1)
			else
				transparency = NumberSequence.new(1, 0)
			end

			uiGradient4.Transparency = transparency
			uiGradient4.Parent = fill6
			fills[i] = fill6
		end

		local function placeHall()
			local absoluteSize = room.AbsoluteSize
			local v50 = frame3.AbsolutePosition - room.AbsolutePosition
			local absoluteSize2 = frame3.AbsoluteSize

			if absoluteSize.X < 1 or absoluteSize.Y < 1 or absoluteSize2.X < 1 or absoluteSize2.Y < 1 then
				return
			end

			local v51 = math.max(
				math.min(absoluteSize2.X / bay.fit.X, absoluteSize2.Y / bay.fit.Y * 16 / 9) * 0.8,
				absoluteSize.X
			)
			local v52 = v51 * 9 / 16
			local v53 = math.clamp(v50.X + absoluteSize2.X / 2 - bay.aim.X * v51, absoluteSize.X - v51, 0)
			local v54 = v50.Y + absoluteSize2.Y / 2 - bay.aim.Y * v52
			local visible = v52 < absoluteSize.Y - 1

			if not visible then
				v54 = math.clamp(v54, absoluteSize.Y - v52, 0)
			end

			frame4.Size = UDim2.fromOffset(math.ceil(v51), (math.ceil(v52)))
			frame4.Position = UDim2.fromOffset(math.floor(v53), (math.floor(v54)))
			fills[1].Visible = visible
			fills[2].Visible = visible
		end
		room:GetPropertyChangedSignal("AbsoluteSize"):Connect(placeHall)
		frame3:GetPropertyChangedSignal("AbsoluteSize"):Connect(placeHall)
		frame3:GetPropertyChangedSignal("AbsolutePosition"):Connect(placeHall)
		local v50 = {}
		local v51 = {}
		local function hallPicture(parent, name: string, image: string, list2, zIndex: number)
			local v52 = type(image) == "string" and image ~= ""
			assert(v52, "[Garage] GameUI.GarageArt.BAY has no picture for " .. name)
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = name
			imageLabel.BackgroundTransparency = 1
			imageLabel.BorderSizePixel = 0
			imageLabel.Image = image
			imageLabel.ScaleType = Enum.ScaleType.Stretch
			local position

			if list2 then
				position = UDim2.fromScale(list2[1], list2[2])
			else
				position = UDim2.new()
			end

			imageLabel.Position = position
			local size

			if list2 then
				size = UDim2.fromScale(list2[3], list2[4])
			else
				size = UDim2.fromScale(1, 1)
			end

			imageLabel.Size = size
			imageLabel.ZIndex = zIndex
			imageLabel.Parent = parent
			return imageLabel
		end

		local function showLooks()
			local parent = v50[v25.id]

			if not parent or id ~= v25.id then
				return
			end

			local vehicle = bay.vehicles[v25.id]
			local set = {}

			for k, slot in v25.slots do
				local v53
				v53 = slot == v26 and v27 or VehicleLoadouts.equipped(player, v25.id, slot.id)
				local look = vehicle.looks[slot.id .. "/" .. v53.id]

				if not look then
					continue
				end

				local v54 = v25.id .. "/" .. slot.id .. "/" .. v53.id
				set[v54] = true

				if not v51[v54] then
					v51[v54] = hallPicture(parent, "L_" .. slot.id .. "_" .. v53.id, look.image, look.box, 2 + k)
				end
			end

			for k, v53 in v51 do
				v53.Visible = set[k] == true
			end
		end

		local function showVehicle()
			if id == v25.id and v50[v25.id] then
				return
			end

			if id and v50[id] then
				v50[id].Visible = false
			end

			id = v25.id
			local v52 = v50[v25.id]

			if not v52 then
				local vehicle = bay.vehicles[v25.id]
				local v53 = type(vehicle) == "table" and type(vehicle.looks) == "table"
				assert(v53, "[Garage] GameUI.GarageArt.BAY.vehicles has no pictures for vehicle " .. tostring(v25.id))
				v52 = Style.frame(frame4, "B_" .. v25.id, UDim2.fromScale(1, 1))
				hallPicture(v52, "Room", vehicle.room, nil, 1)

				for k, v54 in bay.hero do
					hallPicture(v52, "Hero" .. k, vehicle.hero[k], v54, 2)
				end

				v50[v25.id] = v52
			end

			v52.Visible = true
			placeHall()
			showLooks()
		end
		local v52 = nil
		local v53 = nil
		local function endDrag() -- 3 equivalent calls inferred from this helper
			v52 = nil

			if v53 then
				for _, connection in v53 do
					connection:Disconnect()
				end

				v53 = nil
			end
		end
		turn.InputBegan:Connect(function(input)
			if
				input.UserInputType ~= Enum.UserInputType.MouseButton1
				and input.UserInputType ~= Enum.UserInputType.Touch
			then
				return
			end

			v52 = input

			if not v53 then
				v53 = {
					UserInputService.InputChanged:Connect(function(_)
						if v52 then
						end
					end),
					UserInputService.InputEnded:Connect(function(input2)
						if v52 and (input2 == v52 or input2.UserInputType == Enum.UserInputType.MouseButton1) then
							endDrag() -- inferred equivalent call
						end
					end)
				}
			end

			local userInputState = input.UserInputState

			if userInputState == Enum.UserInputState.End or userInputState == Enum.UserInputState.Cancel then
				endDrag() -- inferred equivalent call
			end
		end)
		local connection = nil

		local v54 = v14 + 8 + v18 + 8

		local frame5 = Style.frame(v5, "Detail", UDim2.fromOffset(v20, v54))
		plate(frame5, "Plate", GarageArt.PLATES.well)
		frame5.Position = UDim2.fromOffset(v22, v23)

		local v55 = math.floor((v20 - 42) * 0.52)
		local v56 = v20 - 42 - v55
		local v57 = v55 + 14 + 14
		frame5.BackgroundTransparency = 1
		local fill_2 = Style.fill(frame5, "Top", Style.HAZARD, UDim2.new(1, 0, 0, 3))
		fill_2.ZIndex = 2
		local parent = label(frame5, "Slot", "", math.floor(v2 * 13), 14, 9, v55, math.floor(v2 * 13) + 4, {
			color = Style.MUTED
		})
		shrink(parent, math.floor(v2 * 13), 12) -- inferred equivalent call
		local v59 = math.floor(v2 * 13) + 9 + 4
		local parent7 = label(frame5, "Name", "", math.floor(v2 * 26), 14, v59, v55, math.floor(v2 * 26) + 6, {
			outline = 2
		})
		shrink(parent7, math.floor(v2 * 26), 14) -- inferred equivalent call
		local v61 = v59 + math.floor(v2 * 26) + 8
		local v62 = math.floor(v2 * 13) + 6

		local v63 = v54 - v62 - 8
		local v64 = v63 - v61 - 4
		local parent8 = label(frame5, "About", "", math.floor(v2 * 14), 14, v61, v55, v64, {
			font = Style.FONT_BODY,
			wrap = true,
			ay = Enum.TextYAlignment.Top
		})
		shrink(parent8, math.floor(v2 * 14), 12) -- inferred equivalent call
		local v66 = touch and 46 or 52
		local v67 = math.min(v56, (math.floor(v66 * 6.5)))
		local v68 = v54 - v66 - 10

		local v69 = v68 - 12 - 8
		local frame6 = Style.frame(frame5, "Stats", UDim2.fromOffset(v56, v69), UDim2.fromOffset(v57, 12))
		frame6.ClipsDescendants = true
		local parent9 = label(frame5, "Line", "", math.floor(v2 * 13), 14, v63, v55, v62, {
			color = Style.WHITE
		})
		shrink(parent9, math.floor(v2 * 13), 12) -- inferred equivalent call
		local v71 = label(frame5, "Toast", "", math.floor(v2 * 13), 14, v63, v55, v62, {
			color = color
		})
		v71.BackgroundColor3 = Style.PANEL
		v71.BackgroundTransparency = 0
		v71.ZIndex = 3
		v71.Visible = false
		local count2 = 0
		local function showToast(text: string) -- 2 equivalent calls inferred from this helper
			count2 += 1
			local v72 = count2
			v71.Text = text
			v71.Visible = true
			task.delay(2.4, function()
				if count2 == v72 then
					v71.Visible = false
				end
			end)
		end
		local action = Instance.new("ImageButton")
		action.Name = "Action"
		action.BackgroundTransparency = 1
		action.AutoButtonColor = false
		action.Image = "rbxassetid://116067232788719"
		action.AnchorPoint = Vector2.new(0.5, 0.5)
		action.Size = UDim2.fromOffset(v67, v66)
		action.Position = UDim2.fromOffset(v57 + math.floor(v56 / 2), v68 + v66 / 2)
		action.ZIndex = 2
		action.Parent = frame5
		local uiScale = Instance.new("UIScale")
		uiScale.Parent = action
		local parent10 = label(action, "Text", "", math.floor(v2 * 24), 0, 0, v67, v66, {
			ax = Enum.TextXAlignment.Center,
			outline = 2
		})
		parent10.ZIndex = 3
		shrink(parent10, math.floor(v2 * 24), 14) -- inferred equivalent call

		local frame7 = Style.frame(action, "Price", UDim2.fromScale(1, 1))
		frame7.ZIndex = 3
		local uiListLayout3 = Instance.new("UIListLayout")
		uiListLayout3.FillDirection = Enum.FillDirection.Horizontal
		uiListLayout3.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uiListLayout3.VerticalAlignment = Enum.VerticalAlignment.Center
		uiListLayout3.Padding = UDim.new(0, 7)
		uiListLayout3.SortOrder = Enum.SortOrder.LayoutOrder
		uiListLayout3.Parent = frame7
		local label4 = Style.label(frame7, "Lead", "UNLOCK", S(22), Style.FONT, 2) -- inferred equivalent call
		label4.LayoutOrder = 1
		label4.ZIndex = 3
		local folder = Style.nut(frame7, S(18)) -- inferred equivalent call
		folder.LayoutOrder = 2
		folder.ZIndex = 3

		for _, guiObject in folder:GetDescendants() do
			if guiObject:IsA("GuiObject") then
				guiObject.ZIndex = 3
			end
		end

		local label5 = Style.label(frame7, "Amount", "", S(22), Style.FONT, 2) -- inferred equivalent call
		label5.LayoutOrder = 3
		label5.ZIndex = 3
		local label6 = Style.label(frame7, "Tail", "MORE", S(22), Style.FONT, 2) -- inferred equivalent call
		label6.LayoutOrder = 4
		label6.ZIndex = 3

		local function statRow(k: number, p: number, stat, p2)
			local v73 = v56
			local v74 = math.floor(v73 * 0.4)
			local v75 = math.floor(v73 * 0.22)
			local v76 = v73 - v74 - v75 - 12
			local v77 = (k - 1) * p
			shrink( -- inferred equivalent call
				label(frame6, "Name" .. k, stat.name, math.floor(v2 * 13), 0, v77, v74, p, {
					color = Style.MUTED
				}),
				math.floor(v2 * 13),
				12
			)

			local fill6 = Style.fill(
				frame6,
				"Bar" .. k,
				color4,
				UDim2.fromOffset(v76, 8),
				UDim2.fromOffset(v74 + 6, v77 + math.floor(p / 2) - 4)
			)
			Style.corner(fill6, 4)
			Style.stroke(fill6, 1, 0, Style.STEEL, true)
			local v78 = math.clamp(stat.value, 0, 1)
			local v79

			if p2 then
				v79 = math.clamp(p2.value, 0, 1)
			else
				v79 = v78
			end

			local fill7 = Style.fill(fill6, "Base", Style.WHITE, UDim2.fromScale(0, 1))
			Style.corner(fill7, 4)
			TweenService:Create(fill7, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.fromScale(math.min(v78, v79), 1)
			}):Play()
			local color5 = Style.WHITE

			if math.abs(v78 - v79) > 0.004 then
				color5 = if v79 < v78 then Style.GOOD else color
				local fill8 = Style.fill(
					fill6,
					"Change",
					color5,
					UDim2.fromScale(0, 1),
					UDim2.fromScale(math.min(v78, v79), 0)
				)
				Style.corner(fill8, 4)
				TweenService:Create(
					fill8,
					TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.12),
					{
						Size = UDim2.fromScale(math.abs(v78 - v79), 1)
					}
				):Play()
			end

			shrink( -- inferred equivalent call
				label(frame6, "Text" .. k, stat.text or "", math.floor(v2 * 13), v73 - v75, v77, v75, p, {
					ax = Enum.TextXAlignment.Right,
					color = color5
				}),
				math.floor(v2 * 13),
				12
			)
		end

		local function setPrice(text: string, p: number, visible: boolean, textColor: Color3) -- 2 equivalent calls inferred from this helper
			label4.Text = text
			label4.TextColor3 = textColor
			label5.Text = Style.thousands(p)
			label5.TextColor3 = textColor
			label6.Visible = visible
			label6.TextColor3 = textColor
		end

		local fn11
		local v73 = nil
		local v74 = nil
		local function drawDetail()
			local IMAGE_ID = "rbxassetid://116067232788719"

			if not v27 then
				return
			end

			local v75 = v25
			local v76 = v26
			local v77 = v27

			if v76.seat == "passenger" then
				parent.Text = "FOR YOU AS A PASSENGER"
				parent.TextColor3 = Style.HAZARD
			else
				parent.Text = v76.name
				parent.TextColor3 = Style.MUTED
			end

			parent7.Text = v77.name
			parent8.Text = v77.blurb
			local equipped = VehicleLoadouts.equipped(player, v75.id, v76.id)

			if v73 ~= v77 or v74 ~= equipped then
				v73 = v77
				v74 = equipped
				frame6:ClearAllChildren()
				local stats = v77.stats

				if stats and #stats > 0 then
					local statsByName = {}

					if equipped ~= v77 and equipped.stats then
						for _, stat in equipped.stats do
							statsByName[stat.name] = stat
						end
					end

					local v78 = math.min(math.floor(v2 * 13) + 12, (math.floor(v69 / #stats)))

					for k, stat in stats do
						statRow(k, v78, stat, statsByName[stat.name])
					end
				end
			end

			local v78 = state(v75, v76, v77)
			v28 = v78 == "owned"
			action.Selectable = v78 == "owned" or v78 == "buy"
			action.ImageTransparency = flag and 0.45 or 0
			frame7.Visible = v78 == "buy" or v78 == "poor"
			parent10.Visible = not frame7.Visible
			parent9.Text = ""

			if (v78 == "buy" or v78 == "poor" or v78 == "level") and v77.rank then
				parent9.Text = string.format("UNLOCKS AT VEHICLE LEVEL %d", v77.rank)
			end

			if v78 == "equipped" then
				action.Image = IMAGE_ID
				parent10.Text = "EQUIPPED"
				parent10.TextColor3 = Style.GOOD
				fn6 = function() end
			elseif v78 == "owned" then
				action.Image = "rbxassetid://98153179041297"
				parent10.Text = "EQUIP"
				parent10.TextColor3 = Style.WHITE
				fn6 = function()
					task.spawn(function()
						if fn11("equip", v75, v76, v77) and MenuAudio.stamp then
							MenuAudio.stamp()
						end
					end)
				end
			elseif v78 == "level" then
				action.Image = IMAGE_ID
				parent10.Text = string.format("REACH LEVEL %d", v77.level)
				parent10.TextColor3 = Style.WHITE
				fn6 = function()
					if MenuAudio.deny then
						MenuAudio.deny()
					end
				end
			elseif v78 == "poor" then
				action.Image = IMAGE_ID
				setPrice("NEED", v77.scrap - scrapOf(), true, color) -- inferred equivalent call
				fn6 = function()
					showToast("NOT ENOUGH SCRAP") -- inferred equivalent call

					if MenuAudio.deny then
						MenuAudio.deny()
					end
				end
			else
				action.Image = "rbxassetid://98153179041297"
				setPrice("UNLOCK NOW", v77.scrap, false, Style.WHITE) -- inferred equivalent call
				fn6 = function()
					task.spawn(function()
						if not fn11("buy", v75, v76, v77) then
							return
						end

						local v79 = action.AbsolutePosition + action.AbsoluteSize / 2
						ClaimFx.spray(layer2, v79, (math.max(action.AbsoluteSize.Y * 0.6, 16)))

						if MenuAudio.buy then
							MenuAudio.buy()
						end
					end)
				end
			end
		end

		local frame8 = Style.frame(v5, "Slots", UDim2.fromOffset(v21, v14), UDim2.fromOffset(v12, v23))

		plate(
			Style.frame(v5, "Tray", UDim2.fromOffset(v21, v18 + 8 + 8), UDim2.fromOffset(v12, v23 + v14)),
			"Plate",
			GarageArt.PLATES.well
		)

		local v75 = {}
		local fn12
		local function buildStrip()
			frame8:ClearAllChildren()
			table.clear(v75)
			local count3 = #v25.slots

			local v76 = math.floor((v21 - (count3 - 1) * 3) / count3)
			local visible = v76 >= 140

			for k, slot in v25.slots do
				local textButton = Instance.new("TextButton")
				textButton.Name = slot.id
				textButton.Text = ""
				textButton.AutoButtonColor = false
				textButton.BorderSizePixel = 0
				textButton.BackgroundTransparency = 1
				textButton.Size = UDim2.fromOffset(v76, v14)
				textButton.Position = UDim2.fromOffset((k - 1) * (v76 + 3), 0)
				textButton.LayoutOrder = k
				textButton.Parent = frame8
				local v78 = plate(textButton, "Plate", GarageArt.PLATES.tabOff)
				local fill6 = Style.fill(
					textButton,
					"Hover",
					Style.WHITE,
					UDim2.new(1, -4, 1, -4),
					UDim2.fromOffset(2, 2)
				)
				fill6.BackgroundTransparency = 1
				textButton.MouseEnter:Connect(function()
					fill6.BackgroundTransparency = 0.93
				end)
				textButton.MouseLeave:Connect(function()
					fill6.BackgroundTransparency = 1
				end)
				local v79 = v14
				local frame9 = Style.frame(textButton, "In", UDim2.fromOffset(v76, v79))
				frame9.ZIndex = 2
				local image = GarageArt.SLOTS[slot.icon or slot.id]
				local v81 = type(image) == "string" and image ~= ""
				assert(
					v81,
					"[Garage] GameUI.GarageArt.SLOTS has no picture for slot " .. tostring(slot.icon or slot.id)
				)
				local v82 = v79 - 18
				local icon = Instance.new("ImageLabel")
				icon.Name = "Icon"
				icon.BackgroundTransparency = 1
				icon.Image = image
				icon.ScaleType = Enum.ScaleType.Fit
				icon.Size = UDim2.fromOffset(v82, v82)
				icon.Position = UDim2.fromOffset(8, 9)
				icon.Visible = visible
				icon.Parent = frame9
				local v83 = not visible and 8 or v82 + 8 + 8
				local v84 = math.floor(v2 * 12) + 4
				local parent11 = label(frame9, "Slot", slot.name, math.floor(v2 * 12), v83, 5, v76 - v83 - 6, v84, {
					color = Style.MUTED
				})
				shrink(parent11, math.floor(v2 * 12), 12) -- inferred equivalent call
				local parent12 = label(
					frame9,
					"On",
					"",
					math.floor(v2 * 15),
					v83,
					v84 + 5,
					v76 - v83 - 6,
					v79 - 11 - v84,
					{ outline = 2 }
				)
				shrink(parent12, math.floor(v2 * 15), 12) -- inferred equivalent call

				local fill7 = Style.fill(
					textButton,
					"Under",
					Style.HAZARD,
					UDim2.new(1, -4, 0, 3),
					UDim2.fromOffset(2, 1)
				)
				fill7.ZIndex = 2
				fill7.Visible = false
				local function face()
					return if v26 == slot then color2 else Style.PANEL
				end

				local function draw()
					parent12.Text = VehicleLoadouts.equipped(player, v25.id, slot.id).name
					local visible2 = v26 == slot
					local image2

					if visible2 then
						image2 = GarageArt.PLATES.tabOn
					else
						image2 = GarageArt.PLATES.tabOff
					end

					v78.Image = image2
					fill7.Visible = visible2
					local imageColor

					if visible2 then
						imageColor = Style.HAZARD
					else
						imageColor = Style.WHITE
					end

					icon.ImageColor3 = imageColor
					local textColor

					if visible2 then
						textColor = Style.HAZARD
					else
						textColor = Style.MUTED
					end

					parent11.TextColor3 = textColor
				end
				feel(textButton, face)
				table.insert(v75, {
					slot = slot,
					button = textButton,
					setSelected = function(_: boolean) end,
					draw = draw
				})
				textButton.Activated:Connect(function()
					if v26 ~= slot then
						fn12(slot)

						if MenuAudio.press then
							MenuAudio.press()
						end

						PadMenus.reseat()
					end
				end)
			end
		end

		local frame9 = Style.frame(v5, "Options", UDim2.fromOffset(v21 - 16, v18), UDim2.fromOffset(v12 + 8, v24))

		local v76 = {}
		local fn13

		local function makeTile(slot, option, p: number, p2: number, layoutOrder: number)
			local image = GarageArt.ICONS[option.icon]
			local v78 = type(image) == "string" and image ~= ""
			assert(v78, "[Garage] GameUI.GarageArt.ICONS has no picture for icon key " .. tostring(option.icon))
			local textButton = Instance.new("TextButton")
			textButton.Name = slot.id .. "_" .. option.id
			textButton.Text = ""
			textButton.AutoButtonColor = false
			textButton.BorderSizePixel = 0
			textButton.BackgroundColor3 = Style.PANEL
			textButton.Size = UDim2.fromOffset(p2, v18)
			textButton.Position = UDim2.fromOffset(p, 0)
			textButton.LayoutOrder = layoutOrder
			textButton.Parent = frame9
			Style.corner(textButton, 6)
			local stroke = Style.stroke(textButton, 2, 0, Style.STEEL, true)
			local icon = Instance.new("ImageLabel")
			icon.Name = "Icon"
			icon.BackgroundTransparency = 1
			icon.Image = image
			icon.ScaleType = Enum.ScaleType.Fit
			icon.AnchorPoint = Vector2.new(0.5, 0)
			icon.Position = UDim2.new(0.5, 0, 0, 8)
			icon.Size = UDim2.fromOffset(math.min(p2 - 16, v15 * 2), v15)
			icon.Parent = textButton
			local v79 = tick(textButton, touch and 18 or 22)
			v79.AnchorPoint = Vector2.new(1, 0)
			v79.Position = UDim2.new(1, -6, 0, 6)
			v79.ZIndex = 2
			local lock = Instance.new("ImageLabel")
			lock.Name = "Lock"
			lock.BackgroundTransparency = 1
			lock.Image = "rbxassetid://119994231721439"
			lock.ScaleType = Enum.ScaleType.Fit
			lock.AnchorPoint = Vector2.new(1, 0)
			lock.Size = UDim2.fromOffset(touch and 18 or 22, touch and 18 or 22)
			lock.Position = UDim2.new(1, -6, 0, 6)
			lock.ZIndex = 2
			lock.Parent = textButton
			local fill6 = Style.fill(textButton, "OnBar", Style.GOOD, UDim2.new(1, -16, 0, 3), UDim2.new(0, 8, 1, -4))
			Style.corner(fill6, 2)
			local parent11 = label(textButton, "Name", option.name, math.floor(v2 * 13), 5, v15 + 8 + 4, p2 - 10, v16, {
				ax = Enum.TextXAlignment.Center,
				wrap = true
			})
			shrink(parent11, math.floor(v2 * 13), 12) -- inferred equivalent call

			local v81 = v18 - v17 - 7
			local parent12 = label(textButton, "State", "", math.floor(v2 * 12), 5, v81, p2 - 10, v17, {
				ax = Enum.TextXAlignment.Center
			})
			shrink(parent12, math.floor(v2 * 12), 12) -- inferred equivalent call

			local setSelected = CardSelect.attach(textButton, stroke, Style.STEEL)
			local function face() -- 1 equivalent call inferred from this helper
				local v84 = state(v25, slot, option)

				if v84 == "equipped" or v84 == "owned" then
					return color3
				end

				return Style.PANEL
			end

			local function draw()
				local v84 = state(v25, slot, option)
				local v85 = v84 == "equipped" or v84 == "owned"
				v79.Visible = v84 == "equipped"
				fill6.Visible = v84 == "equipped"
				lock.Visible = not v85
				textButton.BackgroundColor3 = face() -- inferred equivalent call
				icon.ImageTransparency = v85 and 0 or 0.5
				local imageColor

				if v84 == "equipped" then
					imageColor = Style.HAZARD
				else
					imageColor = Style.WHITE
				end

				icon.ImageColor3 = imageColor
				local textColor

				if v85 then
					textColor = Style.WHITE
				else
					textColor = Style.MUTED
				end

				parent11.TextColor3 = textColor

				if v84 == "equipped" then
					parent12.Text = "EQUIPPED"
					parent12.TextColor3 = Style.GOOD
				elseif v84 == "owned" then
					parent12.Text = "OWNED"
					parent12.TextColor3 = Style.MUTED
				else
					parent12.Text = string.format("LEVEL %d", option.rank)
					parent12.TextColor3 = Style.HAZARD
				end
			end
			feel(textButton, face)
			table.insert(v76, {
				slot = slot,
				option = option,
				button = textButton,
				setSelected = setSelected,
				draw = draw
			})
			textButton.Activated:Connect(function()
				if v27 == option and v28 then
					fn6()
					return
				end

				fn13(slot, option)

				if MenuAudio.press then
					MenuAudio.press()
				end
			end)
		end

		local function buildTiles()
			frame9:ClearAllChildren()
			table.clear(v76)
			local count3 = #v26.options
			local v77 = math.min(math.floor((v21 - 16 - (count3 - 1) * 12) / count3), touch and 150 or 176)
			assert(v77 >= 96, "[Garage] too many options in one slot to fit a row: " .. tostring(v26.id))

			local v78 = {}

			for k, option in v26.options do
				table.insert(v78, {
					at = (option.rank or 0) * 100 + k,
					option = option
				})
			end

			table.sort(v78, function(a, b): boolean
				return a.at < b.at
			end)

			for k, v79 in v78 do
				makeTile(v26, v79.option, (k - 1) * (v77 + 12), v77, k)
			end
		end

		fn7 = function()
			parent4.Text = v25.name
			local progress, v77, v78 = VehicleMastery.progress(player, v25.id)
			parent5.Text = string.format("VEHICLE LEVEL %d", progress)
			v48.Text = not (v78 > 0) and "MAX" or string.format("%d/%d", v77, v78)
			fill5.Size = UDim2.fromScale(not (v78 > 0) and 1 or math.clamp(v77 / v78, 0, 1), 1)

			box2.Visible = v25.bay ~= nil and v29 ~= nil and v29[v25.bay] ~= true
		end

		fn13 = function(p, p2)
			v26 = p
			v27 = p2

			for _, v77 in v76 do
				v77.setSelected(v77.option == p2)
			end

			drawDetail()
			showLooks()
		end
		fn12 = function(slot, p)
			local v77 = v26 ~= slot or #v76 == 0
			v26 = slot

			for _, v78 in v75 do
				v78.setSelected(v78.slot == slot)
				v78.draw()
			end

			if v77 then
				buildTiles()
			end

			for _, v78 in v76 do
				v78.draw()
			end

			fn13(slot, p or VehicleLoadouts.equipped(player, v25.id, slot.id))
		end
		fn10 = function(p, flag2: boolean?)
			local v77 = v25 ~= p
			v25 = p

			if v36 ~= p.kind then
				v31 = p.kind
				fn8()
			end

			for _, v78 in v40 do
				v78.setSelected(v78.vehicle == p)
				v78.draw()
			end

			if v77 or #v75 == 0 then
				v26 = nil
				table.clear(v76)
				buildStrip()
			end

			fn7()

			if layer2.Enabled or flag2 then
				showVehicle()
			end

			local v78 = fn12
			local v79 = if v26 and not v77 then v26 else p.slots[1]
			v78(v79)
		end

		fn11 = function(p: string, p2, p3, p4, flag2: boolean?)
			if flag then
				return false
			end

			flag = true
			action.ImageTransparency = 0.45
			local success, result, v77 = pcall(vehicleLoadout.InvokeServer, vehicleLoadout, p, p2.id, p3.id, p4.id)
			flag = false
			local v78 = success and result == true

			if not success then
				warn("[Garage] request failed: " .. tostring(result))
			end

			if not (v78 or flag2) then
				showToast(success and (v[v77] or "NOT AVAILABLE") or "NO ANSWER FROM THE ARMORY") -- inferred equivalent call

				if MenuAudio.deny then
					MenuAudio.deny()
				end
			end

			fn()
			return v78
		end

		action.Activated:Connect(function()
			if not flag then
				fn6()
			end
		end)
		action.MouseEnter:Connect(function()
			if action.Selectable and MenuAudio.hover then
				MenuAudio.hover()
			end

			if action.Selectable then
				TweenService:Create(uiScale, TweenInfo.new(0.1), { Scale = 1.03 }):Play()
			end
		end)
		action.MouseLeave:Connect(function()
			TweenService:Create(uiScale, TweenInfo.new(0.14), { Scale = 1 }):Play()
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

		local function drawScrap() -- 3 equivalent calls inferred from this helper
			label3.Text = Style.thousands(scrapOf()) -- inferred equivalent call
		end
		fn = function()
			drawScrap() -- inferred equivalent call

			if not v25 then
				return
			end

			for _, v77 in v40 do
				v77.draw()
			end

			for _, v77 in v75 do
				v77.draw()
			end

			for _, v77 in v76 do
				v77.draw()
			end

			fn7()
			drawDetail()
		end
		fn2 = function()
			fn10(v25 or showing(nil)[1], true)
			fn()
			loadBay() -- inferred equivalent call
		end
		fn3 = function()
			endDrag() -- inferred equivalent call

			if connection then
				connection:Disconnect()
				connection = nil
			end
		end
		fn4 = function()
			for _, v77 in v76 do
				if v77.option == v27 then
					return v77.button
				end
			end

			return if v76[1] then v76[1].button else nil
		end

		fn5 = function(p: number)
			local v77 = showing(nil)
			local v78 = 1

			for k, v79 in v77 do
				if v79 == v25 then
					v78 = k
				end
			end

			fn10(v77[(v78 - 1 + p) % #v77 + 1])

			if MenuAudio.press then
				MenuAudio.press()
			end

			PadMenus.reseat()
		end

		local OWNED_ATTR = VehicleLoadouts.OWNED_ATTR
		player.AttributeChanged:Connect(function(value: string)
			if value == "Scrap" then
				drawScrap() -- inferred equivalent call

				if layer2.Enabled then
					fn()
				end
			elseif
				(value == "Level" or value == OWNED_ATTR or string.sub(value, 1, 3) == "VL_" or string.sub(value, 1, 7) == "Mx_Veh_")
				and layer2.Enabled
			then
				fn()
			end
		end)
		drawScrap() -- inferred equivalent call
	end

	local v6 = false
	local count = 0
	local tweens = {}
	local mouseIconEnabled = true
	local udim = UDim2.new()

	local v7 = false
	local fn6
	local function toggle()
		if not (v6 or v3) then
			build()
			v3 = true
		end

		v6 = not v6

		if not v6 then
			v7 = false
		end

		if v6 then
			if Armory.close then
				Armory.close()
			end

			for _, childName in { "Store", "Outfits", "Quests" } do
				local module = require(script.Parent:WaitForChild(childName))

				if module.close then
					module.close()
				end
			end

			mouseIconEnabled = UserInputService.MouseIconEnabled
			UserInputService.MouseIconEnabled = true
			UiTrack.send("garage_open")
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
				v4.BackgroundTransparency = 1
				v5.Position = udim + UDim2.fromScale(0, 0.22)
			end

			layer.Enabled = true
			layer2.Enabled = true
			fn2()
			tween(room, 0.256, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, { -- inferred equivalent call
				ImageTransparency = 0,
				BackgroundTransparency = 0
			})
			tween(v4, 0.256, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, { -- inferred equivalent call
				BackgroundTransparency = 0.86
			})
			tween(v5, 0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, { Position = udim }) -- inferred equivalent call
		else
			fn3()
			tween(room, 0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.In, { -- inferred equivalent call
				ImageTransparency = 1,
				BackgroundTransparency = 1
			})
			tween(v4, 0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.In, { -- inferred equivalent call
				BackgroundTransparency = 1
			})
			tween(v5, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In, { -- inferred equivalent call
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
			PadMenus.open("garage", parent2, fn6, {
				first = function()
					return fn4()
				end,
				tab = function(p: number)
					fn5(p)
				end
			})
		else
			PadMenus.close("garage")
		end
	end
	fn6 = function()
		local v8 = v7
		toggle()

		if v8 and Armory.toggle then
			Armory.toggle()
		end
	end
	Garage.leave = fn6
	Garage.toggle = toggle
	function Garage.isOpen()
		return v6
	end

	function Garage.open(flag: boolean?)
		if not v6 then
			toggle()
		end

		v7 = flag == true
	end
	function Garage.close()
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

return Garage