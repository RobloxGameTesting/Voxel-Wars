local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local lastTime = os.clock()
local LocalPlayer = Players.LocalPlayer
LocalPlayer:SetAttribute("JoinT0", lastTime)
LocalPlayer:SetAttribute("JoinCovered", true)

local color = Color3.fromRGB(24, 25, 28)
local color2 = Color3.fromRGB(58, 61, 68)
local color3 = Color3.fromRGB(255, 198, 32)
local color4 = Color3.fromRGB(14, 14, 16)
local color5 = Color3.fromRGB(255, 255, 255)
local TouchEnabled = UserInputService.TouchEnabled

local arrivingTeleportGui = TeleportService:GetArrivingTeleportGui()
local visible

if arrivingTeleportGui == nil then
	visible = false
else
	visible = arrivingTeleportGui.Name == "MobileMoveCover"
end

local text

if visible then
	local loading = arrivingTeleportGui:FindFirstChild("Loading")
	assert(loading and loading:IsA("TextLabel"), "MobileMoveCover has no Loading label")
	text = loading.Text
else
	text = "LOADING"
end

local loadingCover = Instance.new("ScreenGui")
loadingCover.Name = "LoadingCover"
loadingCover.IgnoreGuiInset = true
loadingCover.ResetOnSpawn = false
loadingCover.DisplayOrder = 1000
loadingCover.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local plate = Instance.new("Frame")
plate.Name = "Plate"
plate.Size = UDim2.fromScale(1, 1)
plate.BackgroundColor3 = color
plate.BorderSizePixel = 0
plate.Parent = loadingCover

local slot = Instance.new("Frame")
slot.Name = "Slot"
slot.AnchorPoint = Vector2.new(0.5, 1)
slot.Position = UDim2.new(0.5, 0, 0.86, 0)
slot.Size = UDim2.new(0.34, 0, 0, 10)
slot.BackgroundColor3 = color2
slot.BorderSizePixel = 0
slot.ClipsDescendants = true
slot.Parent = plate
local uiSizeConstraint = Instance.new("UISizeConstraint")
uiSizeConstraint.MinSize = Vector2.new(200, 0)
uiSizeConstraint.MaxSize = Vector2.new(420, 1e999)
uiSizeConstraint.Parent = slot

local fill = Instance.new("Frame")
fill.Name = "Fill"
fill.Size = UDim2.fromScale(0, 1)
fill.BackgroundColor3 = color3
fill.BorderSizePixel = 0
fill.ClipsDescendants = true
fill.Parent = slot

local stripes = Instance.new("Frame")
stripes.Name = "Stripes"
stripes.BackgroundTransparency = 1
stripes.Size = UDim2.new(0, 2000, 1, 0)
stripes.Parent = fill

for i = 0, 99 do
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = color4
	frame.BorderSizePixel = 0
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.new(0, i * 20, 0.5, 0)
	frame.Size = UDim2.new(0, 8, 3, 0)
	frame.Rotation = 40
	frame.Parent = stripes
end

local loading

if TouchEnabled or visible then
	plate.Visible = visible
	loading = Instance.new("TextLabel")
	loading.Name = "Loading"
	loading.AnchorPoint = Vector2.new(0.5, 1)
	loading.Position = UDim2.new(0.5, 0, 1, -120)
	loading.Size = UDim2.fromOffset(360, 30)
	loading.BackgroundTransparency = 1
	loading.TextStrokeColor3 = color4
	loading.TextStrokeTransparency = 0.4
	loading.FontFace = Font.new("rbxasset://fonts/families/Oswald.json", Enum.FontWeight.Bold)
	loading.TextSize = 20
	loading.TextColor3 = color5
	loading.Text = text
	loading.Parent = loadingCover
else
	loading = nil
end

loadingCover.Parent = LocalPlayer:WaitForChild("PlayerGui")
ReplicatedFirst:RemoveDefaultLoadingScreen()

if arrivingTeleportGui then
	arrivingTeleportGui:Destroy()
end

local function stamp(attributeName: string) -- 4 equivalent calls inferred from this helper
	if LocalPlayer:GetAttribute(attributeName) == nil then
		LocalPlayer:SetAttribute(attributeName, os.clock())
	end
end

local v = visible and 0.1 or 0
local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
	local v2 = not game:IsLoaded() and 0.1 or 0.25 + 0.75 * (LocalPlayer:GetAttribute("JoinProgress") or 0)
	v += (math.max(v2, v) - v) * math.min(dt * 8, 1)
	fill.Size = UDim2.fromScale(v, 1)
	stripes.Position = UDim2.fromOffset(-(os.clock() * 24 % 20) - 20, 0)

	if loading then
		loading.Text = text .. string.rep(".", math.floor(os.clock() * 2) % 4)
	end
end)

if not game:IsLoaded() then
	game.Loaded:Wait()
end

stamp("JoinLoaded") -- inferred equivalent call
local Game = ReplicatedStorage:WaitForChild("Game")
local function ready() -- 1 equivalent call inferred from this helper
	local v2 = Game:GetAttribute("Sandbox") ~= true or LocalPlayer:GetAttribute("JoinHud") ~= nil
	return LocalPlayer:GetAttribute("JoinNear") ~= nil and v2 and LocalPlayer.Character ~= nil
end

local flag = false

while not ready() do -- inferred equivalent call
	if LocalPlayer.Character then
		stamp("JoinBody") -- inferred equivalent call
	end

	if os.clock() - lastTime > 45 then
		flag = true
		break
	end

	task.wait()
end

if LocalPlayer.Character then
	stamp("JoinBody") -- inferred equivalent call
end

LocalPlayer:SetAttribute("JoinTimedOut", flag)
LocalPlayer:SetAttribute("JoinCovered", false)
stamp("JoinDone") -- inferred equivalent call
v = 1
fill.Size = UDim2.fromScale(1, 1)
local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
TweenService:Create(plate, tweenInfo, { BackgroundTransparency = 1 }):Play()

if loading then
	TweenService:Create(loading, tweenInfo, { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
end

TweenService:Create(slot, tweenInfo, { BackgroundTransparency = 1 }):Play()
TweenService:Create(fill, tweenInfo, { BackgroundTransparency = 1 }):Play()

for _, instance in stripes:GetChildren() do
	TweenService:Create(instance, tweenInfo, { BackgroundTransparency = 1 }):Play()
end

task.wait(0.35)
renderSteppedConnection:Disconnect()
loadingCover:Destroy()

if flag then
	local attributeNames = {}

	for _, attributeName in { "JoinSynced", "JoinNear", "JoinHud", "JoinBody" } do
		if LocalPlayer:GetAttribute(attributeName) == nil then
			table.insert(attributeNames, attributeName)
		end
	end

	error("LoadingCover: gave up after " .. 45 .. " s waiting for " .. table.concat(attributeNames, ", "))
end