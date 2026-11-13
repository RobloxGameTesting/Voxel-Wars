local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local Style = require(script.Parent:WaitForChild("GameUI"):WaitForChild("Style"))
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("GameConfig"))

local LocalPlayer = Players.LocalPlayer
pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
end)

local playerHud = Instance.new("ScreenGui")
playerHud.Name = "PlayerHud"
playerHud.IgnoreGuiInset = true
playerHud.ResetOnSpawn = false
playerHud.DisplayOrder = 6

local region = Style.region(playerHud, "Vitals", Vector2.new(0.5, 1), Vector2.new(0, -18), Vector2.new(448, 48))
Style.boost(region, Style.touchHud())

local panel = Style.panel(region, "Health", UDim2.fromOffset(280, 28))
panel.AnchorPoint = Vector2.new(0.5, 1)
panel.Position = UDim2.fromScale(0.5, 1)

local v = {}

for i = 1, 8 do
	local fill = Style.fill(
		panel,
		"Plate" .. i,
		Color3.fromRGB(40, 41, 46),
		UDim2.fromOffset(30, 16),
		UDim2.fromOffset((i - 1) * 34 + 6, 6)
	)
	Style.corner(fill, 2)
	local fill2 = Style.fill(fill, "Fill", Style.WHITE, UDim2.fromScale(1, 1))
	Style.corner(fill2, 2)

	local hazard = Style.hazard(fill2, 3, 60, Style.WHITE:Lerp(Style.HAZARD, 0.2), Style.HAZARD)
	hazard.Enabled = false
	local fill3 = Style.fill(
		panel,
		"Snap" .. i,
		Style.WHITE,
		UDim2.fromOffset(30, 16),
		UDim2.fromOffset((i - 1) * 34 + 6, 6)
	)
	Style.corner(fill3, 2)
	fill3.Visible = false
	fill3.ZIndex = 2
	v[i] = {
		back = fill,
		fill = fill2,
		sweep = hazard,
		snap = fill3,
		snapT0 = -10
	}
end

local label = Style.label(region, "Value", "", 20, Style.FONT, 2)
label.AnchorPoint = Vector2.new(1, 1)
label.Position = UDim2.new(0.5, -148, 1, 0)
label.Size = UDim2.fromOffset(0, 28)
label.Visible = false

local frame = Style.frame(region, "Supply", UDim2.fromOffset(100, 28), UDim2.new(0.5, 148, 1, 0), Vector2.new(0, 1))
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.FillDirection = Enum.FillDirection.Horizontal
uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
uiListLayout.Padding = UDim.new(0, 6)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = frame
local supplyIcon = Style.supplyIcon(frame, 18)
supplyIcon.LayoutOrder = 1
local label2 = Style.label(frame, "Amount", "0", 19, Style.FONT, 1.5)
label2.RichText = true
label2.LayoutOrder = 2
local uiScale = Instance.new("UIScale")
uiScale.Parent = label2

playerHud.Parent = LocalPlayer:WaitForChild("PlayerGui")

local v2 = 200
local v3 = 200
local v4 = -10
local v5 = table.create(8, 1)
local v6 = false
local v7 = -1

local function step(_, now)
	local v8 = false

	for _, v9 in v do
		local v10 = (now - v9.snapT0) / 0.32

		if v10 < 1 then
			v8 = true
			v9.snap.Visible = true
			v9.snap.Position = UDim2.fromOffset(v9.back.Position.X.Offset, 6 + 10 * Style.easeIn(v10))
			v9.snap.Rotation = 12 * v10
			v9.snap.BackgroundTransparency = Style.easeIn(v10)
			local snap = v9.snap
			local backgroundColor

			if v10 < 0.25 then
				backgroundColor = Style.WHITE
			else
				backgroundColor = Style.ORANGE
			end

			snap.BackgroundColor3 = backgroundColor
		elseif v9.snap.Visible then
			v9.snap.Visible = false
		end
	end

	local v9

	if now - v4 < 0.4 then
		v9 = v2 < v3
	else
		v9 = false
	end

	local v10 = math.floor(now * 12)

	if v10 ~= v7 then
		v7 = v10
		local vector2 = Vector2.new(v10 / 12 * 1.6 % 1 * 2 - 1, 0)

		for _, v11 in v do
			if v11.sweeping then
				v11.sweep.Offset = vector2
			end
		end
	end

	local visible

	if v2 > 0 then
		visible = now - v4 < 1.2 or v2 / v3 < 0.25
	else
		visible = false
	end

	if visible ~= v6 then
		v6 = visible
		label.Visible = visible
	end

	return now - v4 < 1.2 or (v9 and true or v8)
end

local function setHealth(health: number, maxHealth: number)
	local now = os.clock()
	local v8 = v2 < health
	local v9 = math.max(maxHealth, 1)
	v2 = health
	v3 = v9

	if v8 then
		v4 = now
	end

	local v10 = v3 / 8
	local v11 = v2 / v3 < 0.25
	local v12 = if v11 then Style.ORANGE else Style.WHITE

	for k, v13 in v do
		local v14 = math.clamp((v2 - (k - 1) * v10) / v10, 0, 1)

		if v14 <= 0 and v5[k] > 0 and not v8 then
			v13.snapT0 = now
		end

		v5[k] = v14

		if v14 ~= v13.k then
			v13.k = v14
			v13.fill.Size = UDim2.fromScale(v14, 1)
			v13.fill.Visible = v14 > 0
		end

		if v12 ~= v13.color then
			v13.color = v12
			v13.fill.BackgroundColor3 = v12
		end

		local v15

		if v8 then
			if v14 > 0 then
				v15 = v14 < 1
			else
				v15 = false
			end
		else
			v15 = v8
		end

		if v15 == v13.sweeping then
			continue
		end

		v13.sweeping = v15
		v13.sweep.Enabled = v15
		v7 = -1
	end

	local text = v3 > 1000000 and "∞" or tostring((math.ceil(v2)))

	if label.Text ~= text then
		label.Text = text
	end

	local textColor = if v11 then Style.ORANGE else Style.WHITE

	if label.TextColor3 ~= textColor then
		label.TextColor3 = textColor
	end

	Style.animate(v, step)
	step(0, now)
end

local function setSupply(flag: boolean) -- 2 equivalent calls inferred from this helper
	local v8 = LocalPlayer:GetAttribute("Supply")
	local v9 = LocalPlayer:GetAttribute("SupplyMax")

	if type(v8) ~= "number" then
		v8 = GameConfig.SUPPLY_START
	end

	if type(v9) ~= "number" then
		v9 = GameConfig.SUPPLY_MAX
	end

	label2.Text = math.floor(v8) .. "<font size=\"12\" color=\"" .. Style.hex(Style.DIM) .. "\"> /" .. math.floor(v9) .. "</font>"

	if flag then
		local now = os.clock()
		Style.animate(label2, function(_, p): boolean
			local v10 = (p - now) / 0.2
			uiScale.Scale = 1 + 0.2 * (1 - Style.easeOut(v10))
			return v10 < 1
		end)
	end
end
local v8 = LocalPlayer:GetAttribute("Supply")
LocalPlayer:GetAttributeChangedSignal("Supply"):Connect(function()
	local supply = LocalPlayer:GetAttribute("Supply")
	local v9

	if type(supply) == "number" and type(v8) == "number" then
		v9 = math.abs(supply - v8) >= 5
	else
		v9 = false
	end

	v8 = supply
	setSupply(v9)
end)
LocalPlayer:GetAttributeChangedSignal("SupplyMax"):Connect(function()
	setSupply(false) -- inferred equivalent call
end)
setSupply(false) -- inferred equivalent call
frame.Visible = false

local v9 = false
local function visibility() -- 3 equivalent calls inferred from this helper
	local visible = v9

	if visible then
		if LocalPlayer.Team == nil then
			visible = false
		else
			visible = not LocalPlayer.Neutral
		end
	end

	region.Visible = visible
end
LocalPlayer:GetPropertyChangedSignal("Team"):Connect(visibility)
LocalPlayer:GetPropertyChangedSignal("Neutral"):Connect(visibility)

local function watchTool(instance) -- 1 equivalent call inferred from this helper
	local function check() -- 1 equivalent call inferred from this helper
		local buildHammer = instance:FindFirstChild("BuildHammer")
		frame.Visible = buildHammer ~= nil and buildHammer:IsA("Tool")
	end
	instance.ChildAdded:Connect(check)
	instance.ChildRemoved:Connect(check)
	check() -- inferred equivalent call
end

local function watch(instance)
	watchTool(instance) -- inferred equivalent call
	local humanoid = instance:WaitForChild("Humanoid")
	v9 = humanoid.Health > 0
	visibility() -- inferred equivalent call
	v2 = humanoid.MaxHealth
	table.clear(v5)

	v5[1] = 1
	v5[2] = 1
	v5[3] = 1
	v5[4] = 1
	v5[5] = 1
	v5[6] = 1
	v5[7] = 1
	v5[8] = 1

	local function update() -- 1 equivalent call inferred from this helper
		setHealth(humanoid.Health, humanoid.MaxHealth)
	end
	humanoid.HealthChanged:Connect(update)
	humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(update)
	humanoid.Died:Connect(function()
		v9 = false
		visibility() -- inferred equivalent call
	end)
	update() -- inferred equivalent call
end

LocalPlayer.CharacterAdded:Connect(watch)

if LocalPlayer.Character then
	task.spawn(watch, LocalPlayer.Character)
end

visibility() -- inferred equivalent call