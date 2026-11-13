local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Style = require(script.Parent:WaitForChild("Style"))
local Armory = require(script.Parent:WaitForChild("Armory"))
local ArmoryStore = require(script.Parent:WaitForChild("ArmoryStore"))
local PadMenus = require(script.Parent:WaitForChild("PadMenus"))

local Store = {}
Store.toggle = nil
Store.close = nil
Store.open = nil
Store.isOpen = nil
local color = Color3.fromRGB(255, 255, 255)

function Store.mount(data)
	local player = data.player
	local touch = Style.isTouch()

	local layer = Style.layer(data.playerGui, "StoreBackdrop", 10, true)
	layer.Enabled = false
	local room = Instance.new("ImageLabel")
	room.Name = "Room"
	room.BorderSizePixel = 0
	room.BackgroundColor3 = Style.INK
	room.Image = "rbxassetid://136795488317712"
	room.ImageColor3 = color
	room.ScaleType = Enum.ScaleType.Crop
	room.Size = UDim2.fromScale(1, 1)
	room.Active = true
	room.Parent = layer
	local fill = Style.fill(room, "Ink", Style.INK, UDim2.fromScale(1, 1))
	fill.BackgroundTransparency = 0.75

	local layer2 = Style.layer(data.playerGui, "StoreWindow", 11)
	layer2.Enabled = false
	local v = touch and 540 or 700
	local viewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(16, 9)
	local v2 = math.floor(v * math.clamp(viewportSize.X / math.max(viewportSize.Y, 1), 1.6, 2.2))
	local region = Style.region(layer2, "Store", Vector2.new(0.5, 0.5), Vector2.zero, Vector2.new(v2, v))
	Style.fit(region, Vector2.new(v2, v), 0.98)
	local modal = Instance.new("TextButton")
	modal.Name = "Modal"
	modal.Text = ""
	modal.BackgroundTransparency = 1
	modal.Size = UDim2.fromOffset(1, 1)
	modal.Modal = true
	modal.Selectable = false
	modal.Parent = region

	local frame = Style.frame(region, "Body", UDim2.fromScale(1, 1))

	local label = Style.label(frame, "Title", "STORE", 44, Style.FONT, 2.5)
	label.TextColor3 = Style.HAZARD
	label.Position = UDim2.fromOffset(16, 4)
	local CLOSE_SIZE = Style.CLOSE_SIZE
	local v3 = Style.closeButton(frame)
	v3.AnchorPoint = Vector2.new(1, 0)
	v3.Position = UDim2.new(1, -16, 0, 8)
	local box = Style.box(frame, "Scrap", Style.INK, UDim2.fromOffset(0, 40), 3, 1.5)
	box.AutomaticSize = Enum.AutomaticSize.X
	box.AnchorPoint = Vector2.new(1, 0)
	box.Position = UDim2.new(1, -16 - CLOSE_SIZE - 12, 0, 12)
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.Padding = UDim.new(0, 6)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = box
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, 10)
	uiPadding.PaddingRight = UDim.new(0, 12)
	uiPadding.Parent = box
	local nut = Style.nut(box, 22)
	nut.LayoutOrder = 1
	local label2 = Style.label(box, "Amount", "0", 24, Style.FONT, 0)
	label2.TextColor3 = Style.HAZARD
	label2.LayoutOrder = 2
	local function drawScrap() -- 1 equivalent call inferred from this helper
		local scrap = player:GetAttribute("Scrap")
		label2.Text = Style.thousands(type(scrap) ~= "number" and 0 or scrap)
	end
	player:GetAttributeChangedSignal("Scrap"):Connect(drawScrap)
	drawScrap() -- inferred equivalent call
	local frame2 = Style.frame(frame, "Page", UDim2.fromOffset(v2 - 32, v - 64 - 16), UDim2.fromOffset(16, 64))
	frame2.ClipsDescendants = true
	frame2.Visible = false
	local v4 = ArmoryStore.new(frame2, player, {
		touch = touch,
		top = true,
		reseat = PadMenus.reseat
	})

	local v5 = false
	local udim = UDim2.new()
	local count = 0
	local tweens = {}
	local mouseIconEnabled = true

	local onActivated

	local v6 = false
	local function toggle()
		v5 = not v5

		if not v5 then
			v6 = false
		end

		if v5 then
			if Armory.close then
				Armory.close()
			end

			local Outfits = require(script.Parent:WaitForChild("Outfits"))

			if Outfits.close then
				Outfits.close()
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
		local v7 = count

		for _, v8 in tweens do
			v8:Cancel()
		end

		table.clear(tweens)
		local function tween(instance, duration: number, p, p2, goal) -- 6 equivalent calls inferred from this helper
			local tween2 = TweenService:Create(instance, TweenInfo.new(duration, p, p2), goal)
			table.insert(tweens, tween2)
			tween2:Play()
			return tween2
		end

		if v5 then
			if not layer.Enabled then
				room.ImageTransparency = 1
				room.BackgroundTransparency = 1
				fill.BackgroundTransparency = 1
				frame.Position = udim + UDim2.fromScale(0, 0.22)
			end

			layer.Enabled = true
			layer2.Enabled = true
			v4.show(true)
			tween(room, 0.256, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, { -- inferred equivalent call
				ImageTransparency = 0,
				BackgroundTransparency = 0
			})
			tween(fill, 0.256, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, { -- inferred equivalent call
				BackgroundTransparency = 0.75
			})
			tween(frame, 0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, { Position = udim }) -- inferred equivalent call
		else
			tween(room, 0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.In, { -- inferred equivalent call
				ImageTransparency = 1,
				BackgroundTransparency = 1
			})
			tween(fill, 0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.In, { -- inferred equivalent call
				BackgroundTransparency = 1
			})
			tween(frame, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In, { -- inferred equivalent call
				Position = udim + UDim2.fromScale(0, 0.22)
			}).Completed:Once(function()
				if count == v7 then
					layer.Enabled = false
					layer2.Enabled = false
					v4.show(false)
				end
			end)
		end

		data.setMenu(v5)

		if v5 then
			PadMenus.open("store", region, function()
				if not v4.back() then
					onActivated()
				end
			end, { first = v4.firstPad, tab = v4.tab })
		else
			PadMenus.close("store")
		end
	end
	onActivated = function()
		local v7 = v6
		toggle()

		if v7 and Armory.toggle then
			Armory.toggle()
		end
	end
	v3.Activated:Connect(onActivated)
	Store.toggle = toggle
	function Store.isOpen()
		return v5
	end

	function Store.open(flag: boolean?)
		if not v5 then
			toggle()
		end

		v6 = flag == true
	end
	function Store.close()
		if v5 then
			toggle()
		end
	end

	local _ = nil
	local v7 = false
	data.onTeam(function(p: string?)
		_ = p

		if p ~= nil and v5 then
			toggle()
		end
	end)
	data.onDead(function(flag: boolean)
		v7 = flag

		if flag and v5 then
			toggle()
		end
	end)
end

return Store