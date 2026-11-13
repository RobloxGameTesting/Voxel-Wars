local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local Style = require(script.Parent.Style)
local PadMenus = require(script.Parent.PadMenus)
local PanelLook = require(script.Parent:WaitForChild("PanelLook"))
local Icon = require(ReplicatedStorage:WaitForChild("TopbarPlus"):WaitForChild("Icon"))
local Viewmodel = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("Viewmodel"))

local color = Color3.fromRGB(200, 50, 46)
local color2 = Color3.fromRGB(34, 37, 44)
local color3 = Color3.fromRGB(44, 48, 56)

local v = {
	{ id = "cheating", text = "CHEATING" },
	{ id = "name", text = "BAD NAME OR AVATAR" },
	{ id = "rude", text = "RUDE OR BULLYING" },
	{ id = "other", text = "OTHER" }
}

local function text(p, p2: string, p3: string, p4: number, p5, value: number?) -- 9 equivalent calls inferred from this helper
	local label = Style.label(p, p2, p3, p4, p5 or Style.FONT, value or 0)
	label.AutomaticSize = Enum.AutomaticSize.None
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.TextTruncate = Enum.TextTruncate.AtEnd
	return label
end

return {
	mount = function(data)
		local player = data.player or Players.LocalPlayer
		local playerReport = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Remotes"):WaitForChild(
			"PlayerReport",
			60
		)
		assert(
			playerReport and playerReport:IsA("RemoteEvent"),
			"ReportPlayers: Game.Remotes.PlayerReport (RemoteEvent) is missing"
		)
		local userIdSet = {}

		local region = Style.region(
			data.layers.menu,
			"ReportPlayers",
			Vector2.new(0.5, 0.5),
			Vector2.new(0, 0),
			Vector2.new(460, 540)
		)
		region.Visible = false
		Style.fit(region, Vector2.new(460, 540))
		local modal = Instance.new("TextButton")
		modal.Name = "Modal"
		modal.Text = ""
		modal.BackgroundTransparency = 1
		modal.Size = UDim2.fromOffset(1, 1)
		modal.Modal = true
		modal.Parent = region
		local box = Style.box(region, "Body", Style.PANEL, UDim2.fromScale(1, 1), 3, 3)
		box.BackgroundTransparency = 0.04
		box.Active = true
		local fill = Style.fill(box, "Header", Style.STEEL, UDim2.new(1, 0, 0, 52))
		Style.tape(fill, "Tape", UDim2.new(1, 0, 0, 6), 460, 16)
		local label = text(fill, "Title", "REPORT A PLAYER", 22, Style.FONT) -- inferred equivalent call
		label.Size = UDim2.new(1, -76, 0, 30)
		label.Position = UDim2.fromOffset(14, 14)
		local button = Style.button(fill, "Close", "X", color, UDim2.fromOffset(42, 38), Style.WHITE, 18)
		button.AnchorPoint = Vector2.new(1, 0)
		button.Position = UDim2.new(1, -8, 0, 11)
		local dress = PanelLook.dress(region, box, fill, label, button)

		local label2 = text(box, "Heading", "PLAYERS IN THIS SERVER", 15, Style.FONT) -- inferred equivalent call
		label2.TextColor3 = Style.MUTED
		label2.Size = UDim2.new(1, -28, 0, 22)
		label2.Position = UDim2.fromOffset(14, 62)

		local list = Instance.new("ScrollingFrame")
		list.Name = "List"
		list.BackgroundTransparency = 1
		list.BorderSizePixel = 0
		list.Size = UDim2.new(1, -20, 0, 396)
		list.Position = UDim2.fromOffset(14, 90)
		list.ScrollingDirection = Enum.ScrollingDirection.Y
		list.ScrollBarThickness = 6
		list.ScrollBarImageColor3 = Style.HAZARD
		list.AutomaticCanvasSize = Enum.AutomaticSize.Y
		list.CanvasSize = UDim2.new()
		list.Parent = box
		local uiListLayout = Instance.new("UIListLayout")
		uiListLayout.Padding = UDim.new(0, 6)
		uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uiListLayout.Parent = list
		local uiPadding = Instance.new("UIPadding")
		uiPadding.PaddingRight = UDim.new(0, 12)
		uiPadding.PaddingBottom = UDim.new(0, 6)
		uiPadding.Parent = list

		local label3 = text(box, "Empty", "NOBODY ELSE IS IN THIS SERVER YET", 17, Style.FONT, 1.5) -- inferred equivalent call
		label3.TextXAlignment = Enum.TextXAlignment.Center
		label3.TextWrapped = true
		label3.Size = UDim2.new(1, -28, 0, 80)
		label3.Position = UDim2.fromOffset(14, 130)
		label3.Visible = false

		local label4 = text( -- inferred equivalent call
			box,
			"Hint",
			"Chat or bullying? Also report them in the Roblox menu, top left.",
			13,
			Style.FONT_BODY
		)
		label4.TextColor3 = Style.MUTED
		label4.TextWrapped = true
		label4.TextXAlignment = Enum.TextXAlignment.Center
		label4.Size = UDim2.new(1, -28, 0, 40)
		label4.Position = UDim2.new(0, 14, 1, -48)

		local frame = Style.frame(box, "Page", UDim2.new(1, -28, 0, 464), UDim2.fromOffset(14, 62))
		frame.Visible = false
		local head = Instance.new("ImageLabel")
		head.Name = "Head"
		head.BackgroundColor3 = Color3.fromRGB(60, 64, 72)
		head.BorderSizePixel = 0
		head.Size = UDim2.fromOffset(56, 56)
		head.Position = UDim2.fromOffset(0, 4)
		head.Parent = frame
		Style.corner(head, 28)
		local label5 = text(frame, "Name", "", 20, Style.FONT, 1.5) -- inferred equivalent call
		label5.AutoLocalize = false
		label5.Size = UDim2.new(1, -70, 0, 26)
		label5.Position = UDim2.fromOffset(68, 6)
		local label6 = text(frame, "At", "", 14, Style.FONT_BODY) -- inferred equivalent call
		label6.AutoLocalize = false
		label6.TextColor3 = Style.MUTED
		label6.Size = UDim2.new(1, -70, 0, 20)
		label6.Position = UDim2.fromOffset(68, 34)
		local label7 = text(frame, "Title", "", 18, Style.FONT, 1.5) -- inferred equivalent call
		label7.TextColor3 = Style.HAZARD
		label7.TextWrapped = true
		label7.Size = UDim2.new(1, 0, 0, 48)
		label7.Position = UDim2.fromOffset(0, 68)
		local frame2 = Style.frame(frame, "Buttons", UDim2.new(1, 0, 1, -124), UDim2.fromOffset(0, 124))
		local uiListLayout2 = Instance.new("UIListLayout")
		uiListLayout2.Padding = UDim.new(0, 8)
		uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
		uiListLayout2.Parent = frame2

		local fn
		local function clearButtons()
			for _, guiObject in frame2:GetChildren() do
				if guiObject:IsA("GuiObject") then
					guiObject:Destroy()
				end
			end
		end
		local function showList() -- 2 equivalent calls inferred from this helper
			frame.Visible = false
			clearButtons()
			label2.Visible = true
			label4.Visible = true
			label.Text = "REPORT A PLAYER"
			fn()
		end

		local function pageButton(layoutOrder: number, p: string, color4: Color3, color5: Color3, onActivated)
			local button2 = Style.button(frame2, "Choice" .. layoutOrder, p, color4, UDim2.new(1, 0, 0, 52), color5, 18)
			button2.LayoutOrder = layoutOrder
			PanelLook.feel(button2)
			button2.Activated:Connect(onActivated)
		end

		local function showPage(player2) -- 2 equivalent calls inferred from this helper
			list.Visible = false
			label3.Visible = false
			label2.Visible = false
			label4.Visible = false
			frame.Visible = true
			clearButtons()
			head.Image = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", player2.UserId)
			label5.Text = player2.DisplayName
			label6.Text = "@" .. player2.Name
		end

		local function showThanks(player2)
			showPage(player2) -- inferred equivalent call
			label7.Text = "THANKS! WE'LL LOOK INTO IT."
			label7.TextColor3 = Style.GOOD
			pageButton(1, "BLOCK", color3, Style.WHITE, function()
				pcall(function()
					StarterGui:SetCore("PromptBlockPlayer", player2)
				end)
			end)
			pageButton(2, "DONE", Style.HAZARD, Style.INK, showList)
		end

		local function showWhy(player2)
			showPage(player2) -- inferred equivalent call
			label.Text = "REPORT"
			label7.Text = "WHY ARE YOU REPORTING THEM?"
			label7.TextColor3 = Style.HAZARD

			for k, v2 in v do
				local text2 = v2.text
				local v3 = if v2.id == "cheating" then color else color2
				pageButton(k, text2, v3, Style.WHITE, function()
					if userIdSet[player2.UserId] or player2.Parent ~= Players then
						showList() -- inferred equivalent call
					else
						userIdSet[player2.UserId] = true
						playerReport:FireServer(player2, v2.id)
						showThanks(player2)
					end
				end)
			end

			pageButton(#v + 1, "BACK", color3, Style.MUTED, showList)
		end

		local function row(layoutOrder: number, player2)
			local frame3 = Instance.new("Frame")
			frame3.Name = "Row" .. layoutOrder
			frame3.LayoutOrder = layoutOrder
			frame3.BackgroundColor3 = PanelLook.RAISED
			frame3.BackgroundTransparency = 0.2
			frame3.BorderSizePixel = 0
			frame3.Size = UDim2.new(1, 0, 0, 60)
			frame3.Parent = list
			Style.corner(frame3, 6)
			Style.stroke(frame3, 1.5, 0.2, Style.INK, true)
			local team = Instance.new("Frame")
			team.Name = "Team"
			team.BorderSizePixel = 0
			local backgroundColor

			if player2.Team then
				backgroundColor = Style.teamColor(player2.Team.Name)
			else
				backgroundColor = color3
			end

			team.BackgroundColor3 = backgroundColor
			team.Size = UDim2.new(0, 5, 1, -12)
			team.Position = UDim2.fromOffset(4, 6)
			team.Parent = frame3
			Style.corner(team, 2)
			local head2 = Instance.new("ImageLabel")
			head2.Name = "Head"
			head2.BackgroundColor3 = Color3.fromRGB(60, 64, 72)
			head2.BorderSizePixel = 0
			head2.Image = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", player2.UserId)
			head2.Size = UDim2.fromOffset(48, 48)
			head2.Position = UDim2.fromOffset(14, 6)
			head2.Parent = frame3
			Style.corner(head2, 24)
			local stroke = Style.stroke
			local v2

			if player2.Team then
				v2 = Style.teamColor(player2.Team.Name)
			else
				v2 = Style.STEEL_LIGHT
			end

			stroke(head2, 2, 0, v2, true)

			local label8 = text(frame3, "Name", player2.DisplayName, 18, Style.FONT, 1.5) -- inferred equivalent call
			label8.AutoLocalize = false
			label8.Size = UDim2.new(1, -212, 0, 24)
			label8.Position = UDim2.fromOffset(72, 8)
			local label9 = text(frame3, "At", "@" .. player2.Name, 13, Style.FONT_BODY) -- inferred equivalent call
			label9.AutoLocalize = false
			label9.TextColor3 = Style.MUTED
			label9.Size = UDim2.new(1, -212, 0, 18)
			label9.Position = UDim2.fromOffset(72, 33)
			local v3 = userIdSet[player2.UserId] == true
			local button2 = Style.button
			local v4 = if v3 then color3 else color
			local udim = UDim2.fromOffset(124, 48)
			local v5 = if v3 then Style.MUTED else Style.WHITE
			local v6 = button2(frame3, "Report", v3 and "REPORTED" or "REPORT", v4, udim, v5, 17)
			v6.AnchorPoint = Vector2.new(1, 0.5)
			v6.Position = UDim2.new(1, -6, 0.5, 0)
			v6.AutoButtonColor = not v3

			if not v3 then
				PanelLook.feel(v6)
			end

			v6.Activated:Connect(function()
				if not v3 then
					showWhy(player2)
				end
			end)
		end

		fn = function()
			if not region.Visible or frame.Visible then
				return
			end

			for _, frame3 in list:GetChildren() do
				if frame3:IsA("Frame") then
					frame3:Destroy()
				end
			end

			local v2 = {}

			for _, v3 in Players:GetPlayers() do
				if v3 ~= player then
					table.insert(v2, v3)
				end
			end

			local team = player.Team
			local function rank(p): number -- 2 equivalent calls inferred from this helper
				if p.Team == nil then
					return 2
				end

				return if p.Team == team then 0 else 1
			end

			table.sort(v2, function(a, b): boolean
				local v3 = rank(a) -- inferred equivalent call
				local v4 = rank(b) -- inferred equivalent call

				if v3 == v4 then
					return string.lower(a.DisplayName) < string.lower(b.DisplayName)
				end

				return v3 < v4
			end)

			list.Visible = #v2 > 0
			label3.Visible = #v2 == 0

			for k, v3 in v2 do
				row(k, v3)
			end
		end

		local v2 = false
		local function soon()
			if v2 or not region.Visible then
				return
			end

			v2 = true
			task.delay(0.25, function()
				v2 = false
				fn()
			end)
		end
		local v3 = {}
		local function watch(instance) -- 2 equivalent calls inferred from this helper
			v3[instance] = instance:GetPropertyChangedSignal("Team"):Connect(soon)
		end

		for _, v4 in Players:GetPlayers() do
			watch(v4) -- inferred equivalent call
		end

		Players.PlayerAdded:Connect(function(player2)
			watch(player2) -- inferred equivalent call

			if not v2 then
				if not region.Visible then
					return
				end

				v2 = true
				task.delay(0.25, function()
					v2 = false
					fn()
				end)
			end
		end)
		Players.PlayerRemoving:Connect(function(player2)
			local connection = v3[player2]

			if connection then
				connection:Disconnect()
				v3[player2] = nil
			end

			if not v2 then
				if not region.Visible then
					return
				end

				v2 = true
				task.delay(0.25, function()
					v2 = false
					fn()
				end)
			end
		end)

		playerReport.OnClientEvent:Connect(function() end)

		local v4 = true
		local v5 = Icon.new()
		v5:setName("Report")
		v5:setImage("rbxassetid://128433643679631")
		v5:setCaption("Report")

		local TopbarKey = require(script.Parent:WaitForChild("TopbarKey"))
		TopbarKey.add(v5, "REPORT", Enum.KeyCode.J, Enum.KeyCode.DPadDown)
		local function setOpen(visible: boolean)
			if visible == region.Visible then
				return
			end

			if visible then
				v4 = UserInputService.MouseIconEnabled
				UserInputService.MouseIconEnabled = true
			else
				UserInputService.MouseIconEnabled = Viewmodel.cursorAfterMenu(v4)
			end

			region.Visible = visible
			data.setMenu(visible)

			if not visible then
				PadMenus.close("report")

				return
			end

			dress()
			showList() -- inferred equivalent call
			list.CanvasPosition = Vector2.zero
			PadMenus.open("report", region, function()
				v5:deselect()
			end)
		end
		v5.toggled:Connect(function(visible: boolean)
			setOpen(visible)
		end)
		button.Activated:Connect(function()
			v5:deselect()
		end)
	end
}