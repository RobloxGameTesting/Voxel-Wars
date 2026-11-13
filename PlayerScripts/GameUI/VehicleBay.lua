local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Style = require(script.Parent.Style)
local VehicleIcon = require(script.Parent.VehicleIcon)
local VehiclePreview = require(script.Parent.VehiclePreview)
local UiTrack = require(script.Parent.UiTrack)
local PadMenus = require(script.Parent.PadMenus)
local GuiService = game:GetService("GuiService")
local GroundHeight = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("GroundHeight"))
local MapSelect = require(ReplicatedStorage.Voxel:WaitForChild("MapSelect"))
local VehicleBayData = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("VehicleBayData"))

local touch = Style.isTouch()

local color = Color3.fromRGB(38, 40, 45)
local color2 = Color3.fromRGB(26, 27, 31)
local color3 = Color3.fromRGB(181, 82, 59)

local v = { Reds = Color3.fromRGB(255, 8, 8), Blues = Color3.fromRGB(8, 55, 255) }

local function falloff(frame, backgroundColor: Color3, udim: UDim2, udim2: UDim2, vector2: Vector2, rotation: number) -- 4 equivalent calls inferred from this helper
	local frame2 = Style.frame(frame, "Glow", udim, udim2, vector2)
	frame2.BackgroundTransparency = 0
	frame2.BackgroundColor3 = backgroundColor
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Rotation = rotation
	uiGradient.Transparency = NumberSequence.new(0.5, 1)
	uiGradient.Parent = frame2
end

local function outline(folder, vector3: Vector3, look: Vector3, backgroundColor: Color3)
	local cross = look:Cross(Vector3.new(0, 1, 0))
	local HALF_X = VehicleBayData.HALF_X
	local HALF_Z = VehicleBayData.HALF_Z
	local maxValue = -1e999

	for i = -HALF_X, HALF_X, 3 do
		for j = -HALF_Z, HALF_Z, 3 do
			local v2 = vector3 + cross * i + look * j
			maxValue = math.max(maxValue, GroundHeight.at(v2.X, v2.Z))
		end
	end

	local padLight = Instance.new("Part")
	padLight.Name = "PadLight"
	padLight.Anchored = true
	padLight.CanCollide = false
	padLight.CanQuery = false
	padLight.CanTouch = false
	padLight.CastShadow = false
	padLight.Transparency = 1
	padLight.Size = Vector3.new(HALF_X * 2, 0.05, HALF_Z * 2)
	padLight.CFrame = CFrame.lookAlong(Vector3.new(vector3.X, maxValue + 0.2, vector3.Z), look)
	padLight.Parent = folder
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Face = Enum.NormalId.Top
	surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surfaceGui.PixelsPerStud = 12
	surfaceGui.LightInfluence = 0
	surfaceGui.Brightness = 2
	surfaceGui.MaxDistance = 450
	surfaceGui.Parent = padLight

	local frame = Style.frame(
		surfaceGui,
		"Wash",
		UDim2.new(1, -20, 1, -20),
		UDim2.fromScale(0.5, 0.5),
		Vector2.new(0.5, 0.5)
	)
	frame.BackgroundTransparency = 1
	frame.BackgroundColor3 = backgroundColor
	Style.stroke(frame, 10, 0, backgroundColor, true)

	falloff(frame, backgroundColor, UDim2.new(0, 9.600000000000001, 1, 0), UDim2.fromScale(0, 0), Vector2.zero, 0) -- inferred equivalent call
	falloff( -- inferred equivalent call
		frame,
		backgroundColor,
		UDim2.new(0, 9.600000000000001, 1, 0),
		UDim2.fromScale(1, 0),
		Vector2.new(1, 0),
		180
	)
	falloff(frame, backgroundColor, UDim2.new(1, 0, 0, 9.600000000000001), UDim2.fromScale(0, 0), Vector2.zero, 90) -- inferred equivalent call
	falloff( -- inferred equivalent call
		frame,
		backgroundColor,
		UDim2.new(1, 0, 0, 9.600000000000001),
		UDim2.fromScale(0, 1),
		Vector2.new(0, 1),
		270
	)
end

local function sign(folder, pos: Vector3)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = Vector3.new(1, 1, 1)
	part.CFrame = CFrame.new(pos + Vector3.new(0, 14, 0))
	part.Parent = folder
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Size = UDim2.fromScale(14, 3)
	billboardGui.LightInfluence = 0
	billboardGui.MaxDistance = 180
	billboardGui.Parent = part
	local label = Style.label(billboardGui, "Word", "AIR VEHICLES", 40)
	label.AutomaticSize = Enum.AutomaticSize.None
	label.Size = UDim2.fromScale(1, 1)
	label.TextScaled = true
end

local function row(parent, p: number) -- 3 equivalent calls inferred from this helper
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0, p)
	uiListLayout.Parent = parent
end

local function padding(parent, p: number, p2: number) -- 2 equivalent calls inferred from this helper
	local uiPadding = Instance.new("UIPadding")
	local udim = UDim.new(0, p)
	local udim2 = UDim.new(0, p2)
	uiPadding.PaddingLeft = udim
	uiPadding.PaddingRight = udim2
	uiPadding.Parent = parent
end

return {
	mount = function(data)
		local player = data.player
		local vehicleBay = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Remotes"):WaitForChild("VehicleBay")
		local vehicles = ReplicatedStorage:WaitForChild("Vehicles")
		local bays = vehicles:WaitForChild("Bays")
		vehicles:WaitForChild("Spots")

		local vehicleBayPads = Instance.new("Folder")
		vehicleBayPads.Name = "VehicleBayPads"
		vehicleBayPads.Parent = workspace
		local function draw(instance)
			local child = vehicleBayPads:FindFirstChild(instance.Name)

			if child then
				child:Destroy()
			end

			local pos = instance:GetAttribute("Pos")
			local look = instance:GetAttribute("Look")

			if typeof(pos) ~= "Vector3" or typeof(look) ~= "Vector3" or not instance.Parent then
				return
			end

			local folder = Instance.new("Folder")
			folder.Name = instance.Name
			outline(folder, VehicleBayData.centre(pos, look), look, v[instance.Name])
			sign(folder, pos)
			folder.Parent = vehicleBayPads
		end
		local function watch(child) -- 1 equivalent call inferred from this helper
			draw(child)
			child:GetAttributeChangedSignal("Pos"):Connect(function()
				draw(child)
			end)
		end

		for _, child in bays:GetChildren() do
			watch(child) -- inferred equivalent call
		end

		bays.ChildAdded:Connect(watch)
		bays.ChildRemoved:Connect(draw)
		MapSelect.onChange(function()
			for _, child in bays:GetChildren() do
				draw(child)
			end
		end, 22)

		local layer = Style.layer(data.playerGui, "VehicleBay", 19, true)
		local region = Style.region(layer, "Bay", Vector2.new(0.5, 0.5), Vector2.zero, Vector2.new(740, 370))
		region.Visible = false

		layer.Enabled = false

		local fit = Style.fit(region, Vector2.new(740, 370), 0.96, { grow = touch })
		local modal = Instance.new("TextButton")
		modal.Name = "Modal"
		modal.Text = ""
		modal.BackgroundTransparency = 1
		modal.Size = UDim2.fromOffset(1, 1)
		modal.Modal = true
		modal.Selectable = false
		modal.Parent = region
		local box = Style.box(region, "Body", Style.PANEL, UDim2.fromScale(1, 1), 3, 3)
		box.BackgroundTransparency = 0.04
		box.Active = true

		local fill = Style.fill(box, "Header", Style.STEEL, UDim2.new(1, 0, 0, 54))
		Style.corner(fill, 3)
		local label = Style.label(fill, "Title", "AIR VEHICLES", 26, Style.FONT, 1.5)
		label.AnchorPoint = Vector2.new(0, 0.5)
		label.Position = UDim2.new(0, 14, 0.5, 0)
		local button = Style.button(fill, "Close", "X", Style.ORANGE, UDim2.fromOffset(44, 44), Style.INK, 22)
		button.AnchorPoint = Vector2.new(1, 0.5)
		button.Position = UDim2.new(1, -10, 0.5, 0)
		local box2 = Style.box(fill, "Scrap", Style.INK, UDim2.fromOffset(0, 36), 3, 1.5)
		box2.AutomaticSize = Enum.AutomaticSize.X
		box2.AnchorPoint = Vector2.new(1, 0.5)
		box2.Position = UDim2.new(1, -62, 0.5, 0)
		row(box2, 6) -- inferred equivalent call
		padding(box2, 8, 10) -- inferred equivalent call
		local nut_2 = Style.nut(box2, 20)
		nut_2.LayoutOrder = 1
		local label2 = Style.label(box2, "Amount", "0", 20, Style.FONT, 0)
		label2.TextColor3 = Style.HAZARD
		label2.LayoutOrder = 2

		local frame = Style.frame(box, "Picker", UDim2.fromOffset(720, 296), UDim2.fromOffset(10, 64))
		local items = Instance.new("ScrollingFrame")
		items.Name = "Items"
		items.BackgroundTransparency = 1
		items.BorderSizePixel = 0
		items.Size = UDim2.fromOffset(358, 296)
		items.ScrollBarThickness = 6
		items.ScrollBarImageColor3 = Style.HAZARD
		items.ScrollingDirection = Enum.ScrollingDirection.Y
		items.CanvasSize = UDim2.new()
		items.AutomaticCanvasSize = Enum.AutomaticSize.Y
		items.Parent = frame
		local uiPadding = Instance.new("UIPadding")
		local udim = UDim.new(0, 2)
		local udim2 = UDim.new(0, 2)
		local udim3 = UDim.new(0, 2)
		uiPadding.PaddingTop = udim
		uiPadding.PaddingLeft = udim2
		uiPadding.PaddingBottom = udim3
		uiPadding.Parent = items
		local uiGridLayout = Instance.new("UIGridLayout")
		uiGridLayout.CellSize = UDim2.fromOffset(348, 104)
		uiGridLayout.FillDirectionMaxCells = 1
		uiGridLayout.CellPadding = UDim2.fromOffset(8, 8)
		uiGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uiGridLayout.Parent = items

		local box3 = Style.box(frame, "Detail", color, UDim2.fromOffset(352, 296), 3, 2)
		box3.AnchorPoint = Vector2.new(1, 0)
		box3.Position = UDim2.fromScale(1, 0)
		local box4 = Style.box(box3, "Stage", color2, UDim2.fromOffset(332, 163), 3, 1.5)
		box4.Position = UDim2.fromOffset(10, 10)
		box4.ClipsDescendants = true
		box4.Active = true
		local uiGradient = Instance.new("UIGradient")
		uiGradient.Rotation = 90
		uiGradient.Color = ColorSequence.new(color2, color)
		uiGradient.Parent = box4
		local frame2 = Style.frame(box4, "Holder", UDim2.fromScale(1, 1))
		local label3 = Style.label(box4, "Name", "", 24, Style.FONT, 1.5)
		label3.AnchorPoint = Vector2.new(0, 1)
		label3.Position = UDim2.new(0, 8, 1, -2)
		label3.ZIndex = 3
		local label4 = Style.label(box4, "Toast", "", 16, Style.FONT, 1.5)
		label4.AnchorPoint = Vector2.new(0.5, 0.5)
		label4.Position = UDim2.fromScale(0.5, 0.5)
		label4.Visible = false
		label4.ZIndex = 4

		local frame3 = Style.frame(box3, "Stats", UDim2.fromOffset(332, 57), UDim2.fromOffset(10, 179))
		local v2 = {}

		for i = 1, 3 do
			local v3 = (i - 1) * 19
			local label5 = Style.label(frame3, "Label" .. i, "", 12, Style.FONT, 0)
			label5.AutomaticSize = Enum.AutomaticSize.None
			label5.Size = UDim2.fromOffset(112, 19)
			label5.Position = UDim2.fromOffset(0, v3)
			label5.TextXAlignment = Enum.TextXAlignment.Left
			label5.TextColor3 = Style.MUTED
			local fill2 = Style.fill(
				frame3,
				"Bar" .. i,
				color2,
				UDim2.fromOffset(164, 8),
				UDim2.fromOffset(112, v3 + 5.5)
			)
			local fill3 = Style.fill(fill2, "Fill", Style.HAZARD, UDim2.fromScale(0, 1))
			local label6 = Style.label(frame3, "Value" .. i, "", 13, Style.FONT, 0)
			label6.AutomaticSize = Enum.AutomaticSize.None
			label6.Size = UDim2.fromOffset(56, 19)
			label6.AnchorPoint = Vector2.new(1, 0)
			label6.Position = UDim2.new(1, 0, 0, v3)
			label6.TextXAlignment = Enum.TextXAlignment.Right
			table.insert(v2, { label = label5, value = label6, fill = fill3 })
		end

		local frame4 = Style.frame(box3, "Actions", UDim2.fromOffset(332, 44), UDim2.fromOffset(10, 242))
		local uiListLayout = Instance.new("UIListLayout")
		uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uiListLayout.Padding = UDim.new(0, 6)
		uiListLayout.Parent = frame4

		local function setRows(p: number)
			local v3 = (p - 1) * 50
			box4.Size = UDim2.fromOffset(332, 163 - v3)
			frame3.Position = UDim2.fromOffset(10, 179 - v3)
			frame4.Size = UDim2.fromOffset(332, v3 + 44)
			frame4.Position = UDim2.fromOffset(10, 242 - v3)
		end

		local v3 = { loaded = false }
		local v4 = {}
		local v5 = nil
		local v6 = false
		local v7 = false
		local v8 = 0
		local v9 = nil
		local fn

		local function teamName()
			return if player.Team then player.Team.Name else nil
		end

		local function spotText(_) -- 7 equivalent calls inferred from this helper
			if not v3.loaded then
				return ""
			end

			if v3.heliOut then
				return "TEAM HELI IN USE"
			end

			local v10 = math.max(v3.heliWait, v3.heliMine or 0)

			if v10 > 0 then
				return "READY IN " .. Style.clock((math.ceil(v10)))
			end

			return "READY"
		end

		local count = 0
		local function say(text: string) -- 1 equivalent call inferred from this helper
			label4.Text = text
			label4.Visible = true
			count += 1
			local v10 = count
			task.delay(2.4, function()
				if v10 == count then
					label4.Visible = false
				end
			end)
		end

		local function showStage() -- 3 equivalent calls inferred from this helper
			if v9 then
				v9:Destroy()
			end

			v8 = 0
			v9 = VehiclePreview.view(frame2, v5.item.id or v5.item.model, 1.3)
		end

		local function makeCard(data2, layoutOrder: number)
			local card = Instance.new("TextButton")
			card.Name = "Card"
			card.Text = ""
			card.LayoutOrder = layoutOrder
			card.BorderSizePixel = 0
			card.BackgroundColor3 = Style.STEEL
			card.Parent = items
			Style.corner(card, 3)
			local stroke = Style.stroke(card, 2, 0, Style.INK, true)

			local frame5 = Style.frame(
				card,
				"Picture",
				UDim2.fromOffset(200, 62),
				UDim2.fromOffset(338, 8),
				Vector2.new(1, 0)
			)
			VehicleIcon.voxel(data2.id or data2.model, frame5)
			local label5 = Style.label(card, "Name", data2.name, 20, Style.FONT, 1.5)
			label5.AutomaticSize = Enum.AutomaticSize.None
			label5.Size = UDim2.new(1, -120, 0, 24)
			label5.Position = UDim2.fromOffset(10, 76)
			label5.TextXAlignment = Enum.TextXAlignment.Left
			label5.TextTruncate = Enum.TextTruncate.AtEnd
			label5.ZIndex = 3
			local folder = Style.box(card, "Chip", Style.INK, UDim2.fromOffset(0, 22), 2, 1)
			folder.AutomaticSize = Enum.AutomaticSize.X
			folder.AnchorPoint = Vector2.new(1, 0.5)
			folder.Position = UDim2.fromOffset(340, 88)
			folder.ZIndex = 3
			padding(folder, 5, 6) -- inferred equivalent call
			row(folder, 4) -- inferred equivalent call
			local nut = Style.nut(folder, 12)
			nut.LayoutOrder = 1
			local label6 = Style.label(folder, "Text", "", 13, Style.FONT, 0)
			label6.LayoutOrder = 2

			for _, guiObject in folder:GetDescendants() do
				if guiObject:IsA("GuiObject") then
					guiObject.ZIndex = 3
				end
			end

			card.SelectionGained:Connect(function()
				local nextSelectionRight = nil

				for _, button2 in frame4:GetChildren() do
					if not (button2:IsA("GuiButton") and button2.Visible and (not nextSelectionRight or button2.LayoutOrder < nextSelectionRight.LayoutOrder)) then
						continue
					end

					nextSelectionRight = button2
				end

				card.NextSelectionRight = nextSelectionRight
			end)
			local v10 = {
				item = data2,
				button = card,
				stroke = stroke,
				picture = frame5,
				chip = label6,
				chipPlate = folder,
				nut = nut
			}
			table.insert(v4, v10)
			card.Activated:Connect(function()
				v6 = true

				if v5 ~= v10 then
					v5 = v10
					showStage() -- inferred equivalent call
					fn()
				end
			end)
		end

		for k, v10 in VehicleBayData.LIST do
			if not v10.maps then
				makeCard(v10, k)
			end
		end

		for k, v10 in VehicleBayData.FREE do
			if not v10.maps then
				makeCard(v10, 100 + k)
			end
		end

		local set = {}
		local function addOffered()
			for k, v10 in { [50] = VehicleBayData.LIST, [100] = VehicleBayData.FREE } do
				for k2, v11 in v10 do
					if not v11.maps or set[v11] or not VehicleBayData.offered(v11, MapSelect.name) then
						continue
					end

					set[v11] = true
					makeCard(v11, k + k2)
				end
			end
		end
		addOffered()
		v5 = v4[1]

		local function rank(p): number
			if not VehicleBayData.offered(p.item, MapSelect.name) then
				return 9
			end

			if p.item.model then
				return 1
			end

			local v10 = v3.loaded and v3.items[p.item.id]
			local owned = v10 and (v10.owned or v10.calls > 0)

			if p.item.hidden and not owned then
				return 9
			end

			return if owned then 2 else 3
		end

		local function arrange()
			local clone = table.clone(v4)
			table.sort(clone, function(a, b): boolean
				local v10 = rank(a)
				local v11 = rank(b)

				if v10 ~= v11 then
					return v10 < v11
				end

				local scrap = a.item.scrap or 0
				local scrap2 = b.item.scrap or 0

				if scrap == scrap2 then
					return a.item.name < b.item.name
				end

				return scrap < scrap2
			end)

			for k, v10 in clone do
				v10.button.LayoutOrder = k
				v10.button.Visible = rank(v10) ~= 9
			end

			if not v6 and clone[1] ~= v5 then
				v5 = clone[1]

				if v9 then
					showStage() -- inferred equivalent call
				end
			end
		end

		local function setOpen(flag: boolean)
			if flag == v7 then
				return
			end

			v7 = flag
			region.Visible = flag
			layer.Enabled = flag
			data.setMenu(flag)

			if v9 then
				v9:Destroy()
				v9 = nil
			end

			if flag then
				PadMenus.open("vehiclebay", region, function()
					setOpen(false)
				end, {
					first = function()
						return v5 and v5.button
					end
				})
			else
				PadMenus.close("vehiclebay")
			end

			if flag then
				v6 = false
				items.CanvasPosition = Vector2.zero
				addOffered()
				arrange()
				showStage() -- inferred equivalent call
				local now = os.clock()
				Style.animate(region, function(_, p: number): boolean
					local v10 = math.min((p - now) / 0.16, 1)
					fit(0.92 + 0.08 * Style.easeOut(v10))
					return v10 < 1
				end)
			end
		end
		button.Activated:Connect(function()
			if v7 == false then
				return
			end

			v7 = false
			region.Visible = false
			layer.Enabled = false
			data.setMenu(false)

			if v9 then
				v9:Destroy()
				v9 = nil
			end

			PadMenus.close("vehiclebay")
		end)

		local function fetch(flag: boolean?) -- 2 equivalent calls inferred from this helper
			local success, result = pcall(function()
				return vehicleBay:InvokeServer("state", flag == true)
			end)

			if success and result then
				v3 = result

				if v7 then
					fn()
				end
			end
		end

		local flag = false
		local function send(p: string, p2: string)
			if flag then
				return
			end

			flag = true
			local success, result, text = pcall(function()
				return vehicleBay:InvokeServer(p, p2)
			end)

			flag = false

			if success and result and p == "call" then
				if v7 == false then
					return
				end

				v7 = false
				region.Visible = false
				layer.Enabled = false
				data.setMenu(false)

				if v9 then
					v9:Destroy()
					v9 = nil
				end

				PadMenus.close("vehiclebay")
			else
				if success and not result and text then
					say(text) -- inferred equivalent call
				end

				fetch(nil) -- inferred equivalent call
			end
		end

		local v10 = ""

		local v11 = {}
		local function priceOf(own: number, ownRobux: number) -- 1 equivalent call inferred from this helper
			local v12 = v11[own]

			if v12 == nil then
				v11[own] = false
				task.spawn(function()
					local success, productInfoAsync = pcall(
						MarketplaceService.GetProductInfoAsync,
						MarketplaceService,
						own,
						Enum.InfoType.Product
					)

					if
						success
						and type(productInfoAsync) == "table"
						and type(productInfoAsync.PriceInRobux) == "number"
					then
						v11[own] = productInfoAsync.PriceInRobux
						v10 = ""

						if v7 then
							fn()
						end
					else
						warn("[VehicleBay] no price for developer product " .. own .. ": " .. tostring(productInfoAsync))
					end
				end)
			end

			return if type(v12) == "number" then v12 else ownRobux
		end

		local v12 = false
		local function addButton(text: string, autoButtonColor: boolean, layoutOrder: number, flag2: boolean, onActivated)
			local button2 = Style.button
			local v13

			if autoButtonColor then
				v13 = Style.HAZARD
			else
				v13 = Style.STEEL
			end

			local selectedObject, v14 = button2(frame4, "Action", "", v13, UDim2.new(1, 0, 0, 44), Style.INK, 18)
			selectedObject.LayoutOrder = layoutOrder
			v14.ZIndex = 3
			v14.Text = text
			local textColor

			if autoButtonColor then
				textColor = Style.INK
			else
				textColor = Style.WHITE
			end

			v14.TextColor3 = textColor
			selectedObject.AutoButtonColor = autoButtonColor
			selectedObject.ClipsDescendants = true
			selectedObject.NextSelectionLeft = v5.button

			if v12 then
				v12 = false
				GuiService.SelectedObject = selectedObject
			end

			if not autoButtonColor then
				return selectedObject, v14
			end

			if flag2 then
				local tape = Style.tape(selectedObject, "Tape", UDim2.new(1, 0, 0, 4), 332, 10)
				tape.ZIndex = 3
			end

			selectedObject.Activated:Connect(onActivated)

			return selectedObject, v14
		end

		local function raise(folder)
			for _, guiObject in folder:GetDescendants() do
				if guiObject:IsA("GuiObject") then
					guiObject.ZIndex = 3
				end
			end
		end

		local function instantButton(own: number, p: number)
			local v13, v14 = addButton("", true, 1, false, function()
				UiTrack.send("bay_tap", (tostring(own)))
				MarketplaceService:PromptProductPurchase(player, own)
			end)
			v14.Visible = false
			local robuxLine, v15 = Style.robuxLine(v13, "Line", 18)
			robuxLine:FindFirstChild("Words").UIStroke:Destroy()
			v15("INSTANT UNLOCK", Style.thousands(p), Style.INK)
			raise(v13)
		end

		local function scrapButton(item, p: number)
			local autoButtonColor = item.scrap <= p
			local v13, v14 = addButton("", autoButtonColor, 2, true, function()
				task.spawn(send, "buy", item.id)
			end)
			v14.Visible = false
			local frame5 = Style.frame(v13, "Line", UDim2.fromScale(1, 1))
			row(frame5, 6) -- inferred equivalent call
			local uiListLayout = frame5:FindFirstChildOfClass("UIListLayout")
			uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			local textColor

			if autoButtonColor then
				textColor = Style.INK
			else
				textColor = color3
			end

			local v15

			if autoButtonColor then
				v15 = item.scrap
			else
				v15 = item.scrap - p
			end

			for k, v16 in {
				autoButtonColor and "UNLOCK" or "NEED",
				"",
				Style.thousands(v15),
				autoButtonColor and "" or "MORE"
			} do
				if k == 2 then
					local nut = Style.nut(frame5, 18)
					nut.LayoutOrder = 2
				elseif v16 ~= "" then
					local label5 = Style.label(frame5, "Text", v16, 18, Style.FONT, 0)
					label5.TextColor3 = textColor
					label5.LayoutOrder = k
				end
			end

			raise(frame5)
		end

		fn = function()
			if v3.loaded then
				label2.Text = Style.thousands(v3.scrap)
			end

			arrange()

			for _, v13 in v4 do
				local v14 = v13 == v5
				local stroke = v13.stroke
				local color4 = if v14 then Style.HAZARD else Style.INK
				stroke.Color = color4
				v13.stroke.Thickness = v14 and 3 or 2
				v13.nut.Visible = false
				v13.chip.TextColor3 = Style.WHITE

				if v13.item.model then
					local chip = v13.chip
					local _ = v13.item
					chip.Text = spotText() -- inferred equivalent call
				else
					local v15 = v3.loaded and v3.items[v13.item.id]

					if v15 and (v15.owned or v15.calls > 0) and v13.item.id ~= "Jet" and v13.item.id ~= "Bomber" then
						local _ = v13.item

						if spotText() ~= "READY" then -- inferred equivalent call
							local chip = v13.chip
							local _ = v13.item
							chip.Text = spotText() -- inferred equivalent call
							continue
						end
					end

					if v15 and v15.owned then
						v13.chip.Text = "OWNED"
					elseif v15 and v15.calls > 0 then
						v13.chip.Text = v15.calls .. (v15.calls == 1 and " SPAWN" or " SPAWNS")
					else
						v13.nut.Visible = true
						v13.chip.Text = Style.thousands(v13.item.scrap)
						local chip = v13.chip
						local textColor

						if v3.loaded and v3.scrap >= v13.item.scrap then
							textColor = Style.WHITE
						else
							textColor = color3
						end

						chip.TextColor3 = textColor
					end
				end
			end

			local item = v5.item
			local v13 = item.model ~= nil
			label3.Text = item.name

			for k, v14 in v2 do
				local stat = item.stats[k]
				v14.label.Text = stat.name
				v14.value.Text = stat.text
				v14.fill.Size = UDim2.fromScale(math.min(stat.value, 1), 1)
			end

			local v14

			if not (v13 or not v3.loaded) then
				v14 = v3.items[item.id]
			end

			local v15 = not (v14 == nil) and v14.owned
			local v16 = not v14 and 0 or v14.calls
			local v17 = v13 or v15 or v16 > 0
			local v18 = nil

			if v13 then
				if v3.loaded and spotText() ~= "READY" then -- inferred equivalent call
					v18 = spotText() -- inferred equivalent call
				end
			elseif v17 then
				if v3.mine then
					v18 = "YOURS IS OUT"
				elseif item.id == "Jet" or item.id == "Bomber" then
					if v3.wait > 0 then
						v18 = "READY IN " .. Style.clock((math.ceil(v3.wait)))
					else
						v18 = item.id == "Jet" and v3.jetOut and "TEAM JET IN USE"
							or item.id == "Bomber" and v3.bomberOut and "TEAM BOMBER IN USE"
							or v18
					end
				elseif spotText() ~= "READY" then -- inferred equivalent call
					v18 = spotText() -- inferred equivalent call
				end
			end

			local v19 = not v3.loaded and 0 or v3.scrap
			local joined = table.concat({
				v13 and "free" or item.id,
				tostring(v17),
				tostring(v16),
				v18 or "",
				(tostring(v19))
			}, "|")

			if joined == v10 then
				return
			end

			v10 = joined
			local selectedObject = GuiService.SelectedObject
			v12 = selectedObject ~= nil and selectedObject:IsDescendantOf(frame4)

			for _, button2 in frame4:GetChildren() do
				if button2:IsA("GuiButton") then
					button2:Destroy()
				end
			end

			if not v3.loaded or v17 then
				setRows(1)
			end

			if not v3.loaded then
				return
			end

			if v17 then
				addButton(
					v18 or (v13 or v15) and "SPAWN" or "SPAWN (" .. v16 .. " LEFT)",
					v18 == nil,
					1,
					true,
					function()
						task.spawn(send, "call", item.id or item.model)
					end
				)
				return
			end

			setRows(item.own == 0 and 1 or 2)

			if item.own ~= 0 then
				instantButton(item.own, priceOf(item.own, item.ownRobux)) -- inferred equivalent call
			end

			scrapButton(item, v19)
		end

		MarketplaceService.PromptProductPurchaseFinished:Connect(function(p, _, p2)
			if p2 and p == player.UserId and v7 then
				for _ = 1, 4 do
					task.wait(1)
					fetch(nil) -- inferred equivalent call
				end
			end
		end)

		local v13 = false
		local v14 = nil
		local function endDrag() -- 2 equivalent calls inferred from this helper
			v13 = false

			if v14 then
				for _, connection in v14 do
					connection:Disconnect()
				end

				v14 = nil
			end
		end
		box4.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				v13 = true

				if not v14 then
					v14 = {
						UserInputService.InputEnded:Connect(function(input2)
							if
								input2.UserInputType == Enum.UserInputType.MouseButton1
								or input2.UserInputType == Enum.UserInputType.Touch
							then
								endDrag() -- inferred equivalent call
							end
						end),
						UserInputService.InputChanged:Connect(function(input2)
							if
								v13
								and v9
								and (input2.UserInputType == Enum.UserInputType.MouseMovement or input2.UserInputType == Enum.UserInputType.Touch)
							then
								v8 -= input2.Delta.X * 0.012
								VehiclePreview.turn(v9, v8)
							end
						end)
					}
				end

				local userInputState = input.UserInputState

				if userInputState == Enum.UserInputState.End or userInputState == Enum.UserInputState.Cancel then
					endDrag() -- inferred equivalent call
				end
			end
		end)

		local v15 = false
		local total = 0
		local total2 = 0
		RunService.Heartbeat:Connect(function(dt)
			total += dt

			if v7 and not touch and not v13 and v9 then
				v8 += dt * 0.3
				VehiclePreview.turn(v9, v8)
			end

			if total < 0.1 then
				return
			end

			total2 += total
			total = 0
			local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			local child = player.Team and bays:FindFirstChild(player.Team.Name)
			local pos = child and child:GetAttribute("Pos")
			local look = child and child:GetAttribute("Look")
			local v16

			if
				humanoidRootPart
				and child
				and typeof(pos) == "Vector3"
				and typeof(look) == "Vector3"
				and not (data.isDead() or player:GetAttribute("InVehicle"))
			then
				local v17 = humanoidRootPart.Position - VehicleBayData.centre(pos, look)
				local vector3 = Vector3.new(v17.X, 0, v17.Z)
				v16 = v7 or not child:GetAttribute("Busy")

				if v16 then
					if
						math.abs((vector3:Dot(look:Cross(Vector3.new(0, 1, 0))))) < VehicleBayData.HALF_X
						and math.abs((vector3:Dot(look))) < VehicleBayData.HALF_Z
					then
						v16 = math.abs(v17.Y) < 12
					else
						v16 = false
					end
				end
			else
				v16 = false
			end

			if v16 ~= v15 then
				v15 = v16
				setOpen(v16)

				if v16 then
					v10 = ""
					fn()
					task.spawn(fetch, true)
				end
			end

			if v7 and total2 >= 1 then
				total2 = 0
				task.spawn(fetch)
			end
		end)
	end
}