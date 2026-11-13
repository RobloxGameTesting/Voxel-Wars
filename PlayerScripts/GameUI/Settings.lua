local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Detail = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("Detail"))

local Viewmodel = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("Viewmodel"))
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Style = require(script.Parent.Style)
local Music = require(script.Parent.Music)
local MusicTracks = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("MusicTracks"))
local AudioGraph = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("AudioGraph"))
local Icon = require(ReplicatedStorage:WaitForChild("TopbarPlus"):WaitForChild("Icon"))
local Quality = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("Quality"))
local LookSettings = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("LookSettings"))
local PadMenus = require(script.Parent.PadMenus)
local DebugMenu = require(script.Parent.DebugMenu)
local PanelLook = require(script.Parent:WaitForChild("PanelLook"))
local TouchLayout = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("TouchLayout"))
local LayoutEditor = require(script.Parent:WaitForChild("LayoutEditor"))

local color = Color3.fromRGB(12, 13, 16)
local color2 = Color3.fromRGB(38, 40, 46)

local function num(value, p: number) -- 5 equivalent calls inferred from this helper
	return if type(value) == "number" then value else p
end

local v = {
	toT = function(p)
		return p
	end,
	fromT = function(p)
		return math.round(p * 100) / 100
	end,
	text = function(p)
		return math.round(p * 100) .. "%"
	end,
	step = function(p, p2)
		return (math.clamp(math.round((p + p2 * 0.05) * 100) / 100, 0, 1))
	end
}

local v2 = math.log(LookSettings.MAX / LookSettings.MIN)
local v3 = {
	toT = function(p)
		return math.log(p / LookSettings.MIN) / v2
	end,
	fromT = function(p)
		return LookSettings.clean(LookSettings.MIN * math.exp(p * v2))
	end,
	text = function(p)
		return string.format("%.2f", p)
	end,
	step = function(p, p2)
		return LookSettings.clean(p + p2 * LookSettings.STEP)
	end
}

local function pill(parent) -- 5 equivalent calls inferred from this helper
	local uiCorner = parent:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(1, 0)
	uiCorner.Parent = parent
end

local function slider(box, p: number, p2: number, p3: number, p4: string, fn, p5)
	local v4 = p5 or v
	local label = Style.label(box, p4, p4, 17, Style.FONT, 0)

	label.AutomaticSize = Enum.AutomaticSize.None
	label.Size = UDim2.fromOffset(p3 - 64 - 8, 26)
	label.TextScaled = true
	local uiTextSizeConstraint = Instance.new("UITextSizeConstraint")
	uiTextSizeConstraint.MaxTextSize = 17
	uiTextSizeConstraint.MinTextSize = 11
	uiTextSizeConstraint.Parent = label
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Position = UDim2.fromOffset(p, p2)
	local label2 = Style.label(box, p4 .. "Value", "", 17, Style.FONT, 0)
	label2.AutomaticSize = Enum.AutomaticSize.None
	label2.Size = UDim2.fromOffset(64, 26)
	label2.TextXAlignment = Enum.TextXAlignment.Right
	label2.TextColor3 = Style.HAZARD
	label2.Position = UDim2.fromOffset(p + p3 - 64, p2)
	local fill = Style.fill(
		box,
		p4 .. "Track",
		color,
		UDim2.fromOffset(p3 - 30, 10),
		UDim2.fromOffset(p + 15, p2 + 48),
		Vector2.new(0, 0.5)
	)
	pill(fill) -- inferred equivalent call
	Style.stroke(fill, 1.5, 0.1, Color3.fromRGB(70, 74, 84), true)
	fill.Active = true
	local fill2 = Style.fill(fill, "Fill", Style.HAZARD, UDim2.fromScale(0, 1))
	pill(fill2) -- inferred equivalent call
	local fill3 = Style.fill(
		fill,
		"Knob",
		Style.WHITE,
		UDim2.fromOffset(30, 30),
		UDim2.fromScale(0, 0.5),
		Vector2.new(0.5, 0.5)
	)
	fill3.ZIndex = 2
	pill(fill3) -- inferred equivalent call
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = fill3

	local hit = Instance.new("TextButton")
	hit.Name = "Hit"
	hit.Text = ""
	hit.BackgroundTransparency = 1
	hit.Size = UDim2.new(1, 30, 0, 48)
	hit.Position = UDim2.fromScale(0.5, 0.5)
	hit.AnchorPoint = Vector2.new(0.5, 0.5)
	hit.ZIndex = 3
	hit.Parent = fill

	local v5 = 0
	local function show(p6: number)
		v5 = p6
		local v6 = math.clamp(v4.toT(p6), 0, 1)
		fill2.Size = UDim2.fromScale(v6, 1)
		fill3.Position = UDim2.fromScale(v6, 0.5)
		label2.Text = v4.text(p6)
	end
	local v6 = nil
	local function at(x: number) -- 2 equivalent calls inferred from this helper
		local v7 = math.clamp((x - fill.AbsolutePosition.X) / math.max(fill.AbsoluteSize.X, 1), 0, 1)
		local v8 = v4.fromT(v7)
		show(v8)
		fn(v8)
	end

	local v7 = nil
	local function endDrag() -- 2 equivalent calls inferred from this helper
		v6 = nil
		uiScale.Scale = 1

		if v7 then
			for _, connection in v7 do
				connection:Disconnect()
			end

			v7 = nil
		end
	end
	hit.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			v6 = input
			uiScale.Scale = 1.2
			at(input.Position.X) -- inferred equivalent call

			if not v7 then
				v7 = {
					UserInputService.InputChanged:Connect(function(input2)
						if v6 and (input2.UserInputType == Enum.UserInputType.MouseMovement or input2 == v6) then
							at(input2.Position.X) -- inferred equivalent call
						end
					end),
					UserInputService.InputEnded:Connect(function(input2)
						if v6 and (input2 == v6 or input2.UserInputType == Enum.UserInputType.MouseButton1) then
							endDrag() -- inferred equivalent call
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

	hit.NextSelectionLeft = hit
	hit.NextSelectionRight = hit
	local function padDir(): number
		for _, v8 in UserInputService:GetConnectedGamepads() do
			if UserInputService:IsGamepadButtonDown(v8, Enum.KeyCode.DPadLeft) then
				return -1
			end

			if UserInputService:IsGamepadButtonDown(v8, Enum.KeyCode.DPadRight) then
				return 1
			end

			for _, v9 in UserInputService:GetGamepadState(v8) do
				if v9.KeyCode ~= Enum.KeyCode.Thumbstick1 then
					continue
				end

				if v9.Position.X <= -0.6 then
					return -1
				end

				if v9.Position.X >= 0.6 then
					return 1
				end
			end
		end

		return 0
	end

	local heartbeatConnection = nil
	local function padOff() -- 2 equivalent calls inferred from this helper
		if heartbeatConnection then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end

		if not v6 then
			uiScale.Scale = 1
		end
	end
	hit.SelectionGained:Connect(function()
		padOff() -- inferred equivalent call
		uiScale.Scale = 1.2

		local v8 = padDir()
		local v9 = os.clock() + 0.35
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			local v10 = padDir()

			if v10 == 0 then
				v8 = 0
				return
			end

			local now = os.clock()

			if v10 == v8 then
				if now < v9 then
					return
				end

				v9 = now + 0.08
			else
				v8 = v10
				v9 = now + 0.35
			end

			local v11 = v4.step(v5, v10)

			if v11 ~= v5 then
				show(v11)
				fn(v11)
			end
		end)
	end)
	hit.SelectionLost:Connect(padOff)
	hit.AncestryChanged:Connect(function()
		if not hit:IsDescendantOf(game) then
			padOff() -- inferred equivalent call
		end
	end)
	return show, hit
end

local Settings = {}

function Settings.mount(data)
	local player = data.player or Players.LocalPlayer
	local settings = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Remotes"):WaitForChild("Settings", 30)
	assert(settings and settings:IsA("RemoteEvent"), "Settings: Game.Remotes.Settings (RemoteEvent) is missing")

	local voxelSfx = SoundService:FindFirstChild("VoxelSfx")

	if not voxelSfx then
		voxelSfx = Instance.new("SoundGroup")
		voxelSfx.Name = "VoxelSfx"
		voxelSfx.Parent = SoundService
	end

	assert(voxelSfx and voxelSfx:IsA("SoundGroup"), "Settings: SoundService.VoxelSfx is not a SoundGroup")

	local function adopt(sound) -- 1 equivalent call inferred from this helper
		if sound:IsA("Sound") and sound.SoundGroup == nil then
			sound.SoundGroup = voxelSfx
		end
	end

	for _, descendant in data.playerGui:GetDescendants() do
		adopt(descendant) -- inferred equivalent call
	end

	data.playerGui.DescendantAdded:Connect(adopt)

	local sfxVolume = player:GetAttribute("SfxVolume")
	local sfx = MusicTracks.DEFAULT_SFX

	if type(sfxVolume) == "number" then
		sfx = sfxVolume
	end

	local musicVolume = player:GetAttribute("MusicVolume")
	local music = MusicTracks.DEFAULT_MUSIC

	if type(musicVolume) == "number" then
		music = musicVolume
	end

	local track = player:GetAttribute("MusicTrack")

	if not MusicTracks.valid(track) then
		track = MusicTracks.DEFAULT
	end

	local potato = player:GetAttribute("PotatoMode") == true
	local noAuto = player:GetAttribute("PotatoNoAuto") == true
	local sens = player:GetAttribute("LookSensitivity")
	local default = LookSettings.DEFAULT

	if type(sens) ~= "number" then
		sens = default
	end

	local aimSensitivity = player:GetAttribute("AimSensitivity")
	local aimSens = LookSettings.DEFAULT

	if type(aimSensitivity) == "number" then
		aimSens = aimSensitivity
	end

	local vehicleSensitivity = player:GetAttribute("VehicleSensitivity")
	local vehSens = LookSettings.DEFAULT

	if type(vehicleSensitivity) == "number" then
		vehSens = vehicleSensitivity
	end

	local strain = 0
	local hideDebug = player:GetAttribute("HideDebugMenu") == true
	local noAssist = player:GetAttribute("TouchAssistOff") == true
	local noAutoShoot = player:GetAttribute("TouchAutoShootOff") == true
	local layout = TouchLayout.clean(player:GetAttribute("TouchLayout"))
	local owner = DebugMenu.isOwner(player.UserId)
	local touch = Style.isTouch()

	local function apply()
		AudioGraph.setLevels(MusicTracks.amplitude(sfx), MusicTracks.amplitude(music))
		voxelSfx.Volume = MusicTracks.amplitude(sfx)
		Music.prepare(track)
		Quality.set(false)
		LookSettings.set(sens, aimSens, vehSens)
		LookSettings.touchAssist = not noAssist
		LookSettings.touchAutoFire = not noAutoShoot
		TouchLayout.load(layout)
	end
	apply()

	local v4 = -1
	local function send() -- 3 equivalent calls inferred from this helper
		local v5 = os.clock() + 0.4
		v4 = v5
		task.delay(0.4, function()
			if v4 == v5 then
				settings:FireServer({
					sfx = sfx,
					music = music,
					track = track,
					potato = potato,
					noAuto = noAuto,
					sens = sens,
					aimSens = aimSens,
					vehSens = vehSens,
					strain = strain,
					hideDebug = hideDebug,
					noAssist = noAssist,
					noAutoShoot = noAutoShoot,
					layout = layout
				})
			end
		end)
	end
	local function changed() -- 9 equivalent calls inferred from this helper
		apply()
		send() -- inferred equivalent call
	end

	local function seedStrain() -- 1 equivalent call inferred from this helper
		if player:GetAttribute("SettingsLoaded") == true then
			local strainSaved = player:GetAttribute("StrainSaved")
			strain = type(strainSaved) ~= "number" and 0 or strainSaved
			Detail.seedStrain(strain)
		end
	end

	seedStrain() -- inferred equivalent call
	player:GetAttributeChangedSignal("SettingsLoaded"):Connect(seedStrain)
	Detail.onStrainSave(function(p: number)
		if p ~= strain then
			strain = p
			send() -- inferred equivalent call
		end
	end)
	local v5 = touch and 952 or 480
	local v6 = touch and 494 or 22
	local v7 = touch and 302 or 440
	local v8 = (touch and 1 or 0) + 1 + (owner and 1 or 0)
	local v9

	if touch then
		v9 = LayoutEditor.mount(data, function(touchLayout: string)
			layout = touchLayout
			player:SetAttribute("TouchLayout", touchLayout)
			send() -- inferred equivalent call
		end)
	else
		v9 = nil
	end

	local v10 = math.max((touch and 4 or 5) * 72 + 76 - 6, v7 + v8 * 62 - 10) + 22
	local region = Style.region(
		data.layers.menu,
		"Settings",
		Vector2.new(0.5, 0.5),
		Vector2.new(0, 0),
		Vector2.new(v5, v10)
	)
	region.Visible = false
	Style.fit(region, Vector2.new(v5, v10))
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
	local fill = Style.fill(box, "Header", Style.STEEL, UDim2.new(1, 0, 0, 60))
	Style.tape(fill, "Tape", UDim2.new(1, 0, 0, 6), v5, 16)
	local label = Style.label(fill, "Title", "SETTINGS", 22, Style.FONT, 0)
	label.Position = UDim2.fromOffset(22, 16)
	local button = Style.button(fill, "Close", "X", Style.INK, UDim2.fromOffset(44, 44), Style.WHITE, 20)
	button.AnchorPoint = Vector2.new(1, 0)
	button.Position = UDim2.new(1, -10, 0, 8)
	local dress = PanelLook.dress(region, box, fill, label, button)

	if touch then
		local fill_2 = Style.fill(
			box,
			"ColumnRule",
			Style.STEEL_LIGHT,
			UDim2.fromOffset(2, v10 - 76 - 22),
			UDim2.fromOffset(475, 76)
		)
		fill_2.BackgroundTransparency = 0.7
	end

	local v11, v12 = slider(box, 22, 76, 436, "SOUND EFFECTS", function(p)
		sfx = p
		changed() -- inferred equivalent call
	end)
	local v13 = slider(box, 22, 148, 436, "MUSIC", function(p)
		music = p
		changed() -- inferred equivalent call
	end)
	local v14 = slider(box, 22, 220, 436, "SENSITIVITY", function(p)
		sens = p
		changed() -- inferred equivalent call
	end, v3)
	local v15 = slider(box, 22, 292, 436, "AIM SENSITIVITY", function(p)
		aimSens = p
		changed() -- inferred equivalent call
	end, v3)
	local v16 = slider(box, not touch and 22 or v6, touch and 220 or 364, 436, "VEHICLE SENSITIVITY", function(p)
		vehSens = p
		changed() -- inferred equivalent call
	end, v3)

	local function switch(p: number, name: string, p2: string)
		local label2 = Style.label(box, p2, p2, 17, Style.FONT, 0)
		label2.AutomaticSize = Enum.AutomaticSize.None
		label2.Size = UDim2.fromOffset(340, 48)
		label2.TextWrapped = true
		label2.TextXAlignment = Enum.TextXAlignment.Left
		label2.Position = UDim2.fromOffset(v6, p + 6)
		local textButton = Instance.new("TextButton")
		textButton.Name = name
		textButton.Text = ""
		textButton.AutoButtonColor = false
		textButton.BorderSizePixel = 0
		textButton.BackgroundColor3 = color2
		textButton.AnchorPoint = Vector2.new(0.5, 0.5)
		textButton.Size = UDim2.fromOffset(84, 44)
		textButton.Position = UDim2.fromOffset(v6 + 436 - 42, p + 30)
		textButton.Parent = box
		pill(textButton) -- inferred equivalent call
		Style.stroke(textButton, 2, 0, Style.INK, true)
		local label3 = Style.label(textButton, "Word", "", 15, Style.FONT, 0)
		label3.AutomaticSize = Enum.AutomaticSize.None
		label3.Size = UDim2.fromOffset(40, 44)
		label3.TextXAlignment = Enum.TextXAlignment.Center
		local fill2 = Style.fill(
			textButton,
			"Grip",
			Style.WHITE,
			UDim2.fromOffset(34, 34),
			UDim2.new(0, 22, 0.5, 0),
			Vector2.new(0.5, 0.5)
		)
		pill(fill2) -- inferred equivalent call
		Style.stroke(fill2, 2, 0, Style.INK, true)
		PanelLook.feel(textButton)
		return textButton, function(flag: boolean)
			local backgroundColor

			if flag then
				backgroundColor = Style.HAZARD
			else
				backgroundColor = color2
			end

			textButton.BackgroundColor3 = backgroundColor
			label3.Text = flag and "ON" or "OFF"
			local textColor

			if flag then
				textColor = Style.INK
			else
				textColor = Color3.fromRGB(190, 192, 198)
			end

			label3.TextColor3 = textColor
			label3.Position = UDim2.fromOffset(flag and 4 or 40, 0)
			fill2:TweenPosition(
				UDim2.new(flag and 1 or 0, flag and -22 or 22, 0.5, 0),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				0.12,
				true
			)
		end
	end

	local v17 = nil
	local v18 = nil
	local function refreshAssist() -- 3 equivalent calls inferred from this helper
		if v17 then
			v17(not noAssist)
		end

		if v18 then
			v18(not noAutoShoot)
		end
	end

	if touch then
		local v19, v20 = switch(76, "AimAssist", "AIM ASSIST")
		v17 = v20
		v19.Activated:Connect(function()
			noAssist = not noAssist
			changed() -- inferred equivalent call
			player:SetAttribute("TouchAssistOff", noAssist)
			refreshAssist() -- inferred equivalent call
		end)

		local v21, v22 = switch(148, "AutoShoot", "AUTO SHOOT")
		v18 = v22
		v21.Activated:Connect(function()
			noAutoShoot = not noAutoShoot
			changed() -- inferred equivalent call
			player:SetAttribute("TouchAutoShootOff", noAutoShoot)
			refreshAssist() -- inferred equivalent call
		end)
	end

	local function rounder(parent) -- 3 equivalent calls inferred from this helper
		local uiCorner = parent:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0, 10)
		uiCorner.Parent = parent
	end
	local button2 = Style.button(
		box,
		"ResetSensitivity",
		"RESET SENSITIVITY",
		Style.STEEL,
		UDim2.fromOffset(436, 52),
		Style.WHITE,
		17
	)
	rounder(button2) -- inferred equivalent call
	PanelLook.feel(button2)
	button2.Position = UDim2.fromOffset(v6, v7)
	local v19 = v7 + 52 + 10
	local v20

	if touch then
		v20 = Style.button(
			box,
			"CustomizeLayout",
			"CUSTOMIZE LAYOUT",
			Style.HAZARD,
			UDim2.fromOffset(436, 52),
			Style.INK,
			17
		)
		rounder(v20) -- inferred equivalent call
		PanelLook.feel(v20)
		v20.Position = UDim2.fromOffset(v6, v19)
		v19 += 62
	end

	local v21 = nil
	local function refresh() -- 4 equivalent calls inferred from this helper
		v11(sfx)
		v13(music)
		v14(sens)
		v15(aimSens)
		v16(vehSens)
		refreshAssist() -- inferred equivalent call

		if v21 then
			v21.Text = hideDebug and "SHOW DEBUG MENU" or "HIDE DEBUG MENU"
		end
	end

	if owner then
		local button3, v22 = Style.button(
			box,
			"HideDebugMenu",
			"HIDE DEBUG MENU",
			Style.STEEL,
			UDim2.fromOffset(436, 52),
			Style.WHITE,
			17
		)
		rounder(button3) -- inferred equivalent call
		PanelLook.feel(button3)
		button3.Position = UDim2.fromOffset(v6, v19)
		v21 = v22
		button3.Activated:Connect(function()
			hideDebug = not hideDebug
			changed() -- inferred equivalent call
			player:SetAttribute("HideDebugMenu", hideDebug)
			refresh() -- inferred equivalent call
		end)
	end

	button2.Activated:Connect(function()
		local default2 = LookSettings.DEFAULT
		local default3 = LookSettings.DEFAULT
		local default4 = LookSettings.DEFAULT
		sens = default2
		aimSens = default3
		vehSens = default4
		refresh() -- inferred equivalent call
		changed() -- inferred equivalent call
	end)
	refresh() -- inferred equivalent call
	player.AttributeChanged:Connect(function(p: string)
		if
			p ~= "SfxVolume"
			and p ~= "MusicVolume"
			and p ~= "MusicTrack"
			and p ~= "PotatoMode"
			and p ~= "PotatoNoAuto"
			and p ~= "LookSensitivity"
			and p ~= "AimSensitivity"
			and p ~= "VehicleSensitivity"
			and p ~= "HideDebugMenu"
			and p ~= "TouchAssistOff"
			and p ~= "TouchAutoShootOff"
			and p ~= "TouchLayout"
		then
			return
		end

		if v4 > 0 and os.clock() < v4 + 2 then
			return
		end

		sfx = num(player:GetAttribute("SfxVolume"), sfx) -- inferred equivalent call
		music = num(player:GetAttribute("MusicVolume"), music) -- inferred equivalent call
		local musicTrack = player:GetAttribute("MusicTrack")

		if MusicTracks.valid(musicTrack) then
			track = musicTrack
		end

		potato = player:GetAttribute("PotatoMode") == true
		noAuto = player:GetAttribute("PotatoNoAuto") == true
		sens = num(player:GetAttribute("LookSensitivity"), sens) -- inferred equivalent call
		aimSens = num(player:GetAttribute("AimSensitivity"), aimSens) -- inferred equivalent call
		vehSens = num(player:GetAttribute("VehicleSensitivity"), vehSens) -- inferred equivalent call
		hideDebug = player:GetAttribute("HideDebugMenu") == true
		noAssist = player:GetAttribute("TouchAssistOff") == true
		noAutoShoot = player:GetAttribute("TouchAutoShootOff") == true

		if not (v9 and v9.isOpen()) then
			layout = TouchLayout.clean(player:GetAttribute("TouchLayout"))
		end

		apply()
		refresh() -- inferred equivalent call
	end)

	local v22 = true
	local v23 = Icon.new()
	v23:setName("Settings")
	v23:setImage("rbxassetid://111850658399080")
	v23:setCaption("Settings")

	local TopbarKey = require(script.Parent:WaitForChild("TopbarKey"))
	TopbarKey.add(v23, "SETTINGS", Enum.KeyCode.P, Enum.KeyCode.DPadUp)
	local function setOpen(visible: boolean)
		if visible == region.Visible then
			return
		end

		if visible and v9 and v9.isOpen() then
			v9.close()
		end

		if visible then
			v22 = UserInputService.MouseIconEnabled
			UserInputService.MouseIconEnabled = true
		else
			UserInputService.MouseIconEnabled = Viewmodel.cursorAfterMenu(v22)
			Music.endPreview()
		end

		region.Visible = visible
		data.setMenu(visible)

		if not visible then
			PadMenus.close("settings")

			return
		end

		dress()

		PadMenus.open("settings", region, function()
			v23:deselect()
		end, {
			first = function()
				return v12
			end
		})
	end
	v23.toggled:Connect(function(visible: boolean)
		setOpen(visible)
	end)
	button.Activated:Connect(function()
		v23:deselect()
	end)

	if v20 and v9 then
		v20.Activated:Connect(function()
			v23:deselect()
			v9.open()
		end)
	end
end

function Settings.track(instance)
	local musicTrack = instance:GetAttribute("MusicTrack")

	if MusicTracks.valid(musicTrack) then
		return musicTrack
	end

	return MusicTracks.DEFAULT
end

return Settings