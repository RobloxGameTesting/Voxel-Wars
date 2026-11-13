local LocalizationService = game:GetService("LocalizationService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

local Style = require(script.Parent.Style)

local color = Color3.fromRGB(222, 62, 50)

local v = {
	"LobbyClock",
	"GameVote",
	"HudPointHud",
	"HudPointHudFx",
	"HudRare",
	"HudProgressPanel",
	"HudBadgeAward",
	"SkirmishPoints",
	"RoundIntroShade",
	"RoundEnd",
	"RoundEndFrame",
	"RoundEndBlack",
	"TeamSelect"
}

local function moveCover()
	local mobileMoveCover = Instance.new("ScreenGui")
	mobileMoveCover.Name = "MobileMoveCover"
	mobileMoveCover.IgnoreGuiInset = true
	mobileMoveCover.ResetOnSpawn = false
	mobileMoveCover.DisplayOrder = 1000
	mobileMoveCover.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	local plate = Instance.new("Frame")
	plate.Name = "Plate"
	plate.Size = UDim2.fromScale(1, 1)
	plate.BackgroundColor3 = Color3.fromRGB(24, 25, 28)
	plate.BorderSizePixel = 0
	plate.Active = true
	plate.Parent = mobileMoveCover
	local slot = Instance.new("Frame")
	slot.Name = "Slot"
	slot.AnchorPoint = Vector2.new(0.5, 1)
	slot.Position = UDim2.new(0.5, 0, 0.86, 0)
	slot.Size = UDim2.new(0.34, 0, 0, 10)
	slot.BackgroundColor3 = Color3.fromRGB(58, 61, 68)
	slot.BorderSizePixel = 0
	slot.ClipsDescendants = true
	slot.Parent = plate
	local uiSizeConstraint = Instance.new("UISizeConstraint")
	uiSizeConstraint.MinSize = Vector2.new(200, 0)
	uiSizeConstraint.MaxSize = Vector2.new(420, 1e999)
	uiSizeConstraint.Parent = slot
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.fromScale(0.1, 1)
	fill.BackgroundColor3 = Color3.fromRGB(255, 198, 32)
	fill.BorderSizePixel = 0
	fill.ClipsDescendants = true
	fill.Parent = slot

	for i = 0, 29 do
		local frame = Instance.new("Frame")
		frame.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
		frame.BorderSizePixel = 0
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.new(0, i * 20 - 20, 0.5, 0)
		frame.Size = UDim2.new(0, 8, 3, 0)
		frame.Rotation = 40
		frame.Parent = fill
	end

	local loading = Instance.new("TextLabel")
	loading.Name = "Loading"
	loading.AnchorPoint = Vector2.new(0.5, 1)
	loading.Position = UDim2.new(0.5, 0, 1, -120)
	loading.Size = UDim2.fromOffset(360, 30)
	loading.BackgroundTransparency = 1
	loading.TextStrokeColor3 = Color3.fromRGB(14, 14, 16)
	loading.TextStrokeTransparency = 0.4
	loading.FontFace = Font.new("rbxasset://fonts/families/Oswald.json", Enum.FontWeight.Bold)
	loading.TextSize = 20
	loading.TextColor3 = Color3.new(1, 1, 1)
	loading.Text = "MOVING TO MOBILE LOBBY"
	loading.Parent = mobileMoveCover
	return mobileMoveCover
end

local function fadeCover(folder, flag: boolean, duration: number)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	for _, guiObject in folder:GetDescendants() do
		if guiObject:IsA("TextLabel") then
			if flag then
				guiObject.TextTransparency = 1
				guiObject.TextStrokeTransparency = 1
			end

			TweenService:Create(guiObject, tweenInfo, {
				TextTransparency = flag and 0 or 1,
				TextStrokeTransparency = flag and 0.4 or 1
			}):Play()
		elseif guiObject:IsA("Frame") then
			if flag then
				guiObject.BackgroundTransparency = 1
			end

			TweenService:Create(guiObject, tweenInfo, {
				BackgroundTransparency = flag and 0 or 1
			}):Play()
		end
	end
end

local function bar(button, p: number, rotation: number, p2: number, p3: number)
	local fill = Style.fill(
		button,
		"Stroke",
		Style.WHITE,
		UDim2.fromOffset(p, 6),
		UDim2.new(p2, 0, p3, 0),
		Vector2.new(0.5, 0.5)
	)
	fill.Rotation = rotation
	Style.corner(fill, 2)
end

local function block(p: number, p2: number, p3: number, p4: number, color2: Color3, depth: number) -- 2 equivalent calls inferred from this helper
	return {
		c = Vector2.new(p, p2),
		w = p3,
		h = p4,
		angle = 0,
		round = false,
		color = color2,
		depth = depth
	}
end

local color2 = Color3.fromRGB(66, 70, 78)
local color3 = Color3.fromRGB(128, 168, 186)
local function phone(panel, p: number, p2: number)
	local ToolIcon = require(script.Parent:WaitForChild("ToolIcon"))
	local frame = Style.frame(panel, "Phone", UDim2.fromOffset(52, 84), UDim2.fromOffset(p, p2))
	local draw = ToolIcon.draw
	local artFrom = ToolIcon.artFrom
	local v2 = block(0, 0, 1.5, 2.7, color2, 1) -- inferred equivalent call
	draw(artFrom({ v2, block(0, 0.08, 1.2, 2.1, color3, 2) }), frame, Style.WHITE, true) -- inferred equivalent call
end

local function show(data, mobileLobby)
	local layer = Style.layer(data.playerGui, "MobileLobbyPrompt", 20, true)
	local fill = Style.fill(layer, "Shade", Style.INK, UDim2.fromScale(1, 1))
	fill.BackgroundTransparency = 0.45
	fill.Active = true

	local region = Style.region(layer, "Card", Vector2.new(0.5, 0.5), Vector2.zero, Vector2.new(400, 256))
	local panel = Style.panel(region, "Panel", UDim2.new(1, 0, 0, 198), 4)
	panel.BackgroundTransparency = 0
	Style.tape(panel, "Tape", UDim2.fromOffset(400, 8), 400, 10)

	local label = Style.label(panel, "Title", "MOBILE-ONLY LOBBY?", 28)
	label.AutomaticSize = Enum.AutomaticSize.None
	label.Size = UDim2.new(1, 0, 0, 34)
	label.Position = UDim2.fromOffset(0, 26)

	phone(panel, 26, 72)
	local label2 = Style.label(panel, "Body", "Move to a lobby with only mobile players?", 22, Style.FONT_BODY, 0)
	label2.AutomaticSize = Enum.AutomaticSize.None
	label2.TextWrapped = true
	label2.TextYAlignment = Enum.TextYAlignment.Center
	label2.TextColor3 = Style.MUTED
	label2.Size = UDim2.fromOffset(284, 84)
	label2.Position = UDim2.fromOffset(96, 72)

	local button = Style.button(region, "Yes", "", Style.GOOD, UDim2.fromOffset(92, 48))
	button.AnchorPoint = Vector2.new(0, 1)
	button.Position = UDim2.new(0.5, 8, 1, 0)
	bar(button, 14, 45, 0.42, 0.57)
	bar(button, 24, -50, 0.54, 0.49)

	local button2 = Style.button(region, "No", "", color, UDim2.fromOffset(92, 48))
	button2.AnchorPoint = Vector2.new(1, 1)
	button2.Position = UDim2.new(0.5, -8, 1, 0)
	bar(button2, 26, 45, 0.5, 0.5)
	bar(button2, 26, -45, 0.5, 0.5)

	data.setMenu(true)
	local onClientEventConnection = nil
	local function close() -- 1 equivalent call inferred from this helper
		if onClientEventConnection then
			onClientEventConnection:Disconnect()
		end

		layer:Destroy()
		data.setMenu(false)
	end
	local label3 = Style.label(layer, "Moving", "TELEPORTING TO MOBILE SERVER", 22)
	label3.AutomaticSize = Enum.AutomaticSize.None
	label3.AnchorPoint = Vector2.new(0.5, 0)
	label3.Size = UDim2.new(1, -32, 0, 28)
	label3.Position = UDim2.new(0.5, 0, 0, Style.topInset() + 8)
	label3.Visible = false
	label3.RichText = true
	local mobileMoveHeldGuis = nil
	local children = {}
	local function putAway()
		for _, childName in v do
			local child = data.playerGui:FindFirstChild(childName)

			if not child then
				continue
			end

			if not mobileMoveHeldGuis then
				mobileMoveHeldGuis = Instance.new("Folder")
				mobileMoveHeldGuis.Name = "MobileMoveHeldGuis"
				mobileMoveHeldGuis.Parent = data.player
			end

			child.Parent = mobileMoveHeldGuis
			table.insert(children, child)
		end
	end
	local count = 0
	local function card(visible: boolean) -- 1 equivalent call inferred from this helper
		count += 1
		local v2 = count
		fill.Visible = visible
		region.Visible = visible
		label3.Visible = not visible
		data.setMenu(visible)

		if not visible then
			task.spawn(function()
				local v3 = 0

				while v2 == count and layer.Parent do
					putAway()
					v3 = v3 % 3 + 1

					label3.Text = "TELEPORTING TO MOBILE SERVER" .. string.rep(".", v3) .. "<font transparency=\"1\">" .. string.rep(".", 3 - v3) .. "</font>"
					task.wait(0.4)
				end
			end)
			return
		end

		for _, v3 in children do
			if v3.Parent == mobileMoveHeldGuis then
				v3.Parent = data.playerGui
			end
		end

		table.clear(children)
	end

	local function offer(text: string) -- 2 equivalent calls inferred from this helper
		label2.Text = text
		count += 1

		fill.Visible = true
		region.Visible = true
		label3.Visible = false
		data.setMenu(true)

		for _, v2 in children do
			if v2.Parent == mobileMoveHeldGuis then
				v2.Parent = data.playerGui
			end
		end

		table.clear(children)
	end
	local count2 = 0
	local v2 = nil
	local v3 = moveCover()

	task.spawn(function()
		local success, translatorForPlayerAsync = pcall(
			LocalizationService.GetTranslatorForPlayerAsync,
			LocalizationService,
			data.player
		)

		if success then
			local loading = v3:FindFirstChild("Loading")
			loading.Text = translatorForPlayerAsync:Translate(v3, "MOVING TO MOBILE LOBBY")
		else
			warn("[MobileLobbyPrompt] no translator: " .. tostring(translatorForPlayerAsync))
		end
	end)
	local function uncover() -- 2 equivalent calls inferred from this helper
		local v4 = v2
		v2 = nil

		if v4 then
			fadeCover(v4, false, 0.2)
			task.delay(0.2, v4.Destroy, v4)
		end
	end
	button.Activated:Connect(function()
		count2 += 1
		local v4 = count2
		card(false) -- inferred equivalent call
		TeleportService:SetTeleportGui(v3)
		mobileLobby:FireServer("yes")
		task.delay(25, function()
			if v4 == count2 and layer.Parent then
				uncover() -- inferred equivalent call
				offer("Couldn't move you. Try again?") -- inferred equivalent call
			end
		end)
	end)
	button2.Activated:Connect(function()
		mobileLobby:FireServer("no")
		close() -- inferred equivalent call
	end)
	onClientEventConnection = mobileLobby.OnClientEvent:Connect(function(p: string)
		if p == "failed" then
			count2 += 1
			uncover() -- inferred equivalent call
			offer("Couldn't move you. Try again?") -- inferred equivalent call
		elseif p == "going" and not v2 then
			local v4 = moveCover()
			fadeCover(v4, true, 0.25)
			v4.Parent = data.playerGui
			v2 = v4
		end
	end)
end

return {
	mount = function(p)
		local Game = ReplicatedStorage:WaitForChild("Game")
		local mobileLobby = Game:WaitForChild("Remotes"):WaitForChild("MobileLobby")

		if Game:GetAttribute("MobileLobby") == true then
			if not Style.isTouch() then
				mobileLobby:FireServer("desk")
			end
		else
			if not Style.isTouch() then
				return
			end

			local onClientEventConnection = nil
			onClientEventConnection = mobileLobby.OnClientEvent:Connect(function(p2: string)
				if p2 == "ask" then
					onClientEventConnection:Disconnect()
					local player = p.player

					while player:GetAttribute("JoinCovered") == true do
						player:GetAttributeChangedSignal("JoinCovered"):Wait()
					end

					show(p, mobileLobby)
				end
			end)
			mobileLobby:FireServer("ask")
		end
	end
}