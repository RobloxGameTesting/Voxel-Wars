local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Style = require(script.Parent:WaitForChild("GameUI"):WaitForChild("Style"))

local v = {
	GameMenu = true,
	StoreBackdrop = true,
	StoreWindow = true,
	OutfitsBackdrop = true,
	OutfitsWindow = true,
	GarageBackdrop = true,
	GarageWindow = true,
	QuestsBackdrop = true,
	QuestsWindow = true,
	RewardsBackdrop = true,
	RewardsWindow = true,
	BadgesBackdrop = true,
	BadgesWindow = true,
	ClaimFx = true,
	PurchaseShow = true,
	CrateOpen = true,
	GiftOpen = true,
	OwnerGift = true,
	OwnerGiftPanel = true,
	QuestClaimShow = true,
	GameLevel = true,
	GameVote = true,
	MobileLobbyPrompt = true,
	GameBoard = true,
	LobbyClock = true,
	SkirmishFeed = true,
	LayoutEditor = true,
	LayoutEditorControls = true,
	TouchControls = true,
	TouchLook = true,
	TouchGui = true,
	Cmdr = true,
	VoxelRenderHud = true,
	Freecam = true,
	StyleScreenRef = true,
	StyleSafeRef = true
}

local function held(instance) -- 2 equivalent calls inferred from this helper
	return instance:IsA("ScreenGui") or instance:IsA("BillboardGui")
end

local function kept(screenGui): boolean -- 1 equivalent call inferred from this helper
	return v[screenGui.Name] == true or string.sub(screenGui.Name, 1, 6) == "Topbar"
end

local lobbyHeldGuis = Instance.new("Folder")
lobbyHeldGuis.Name = "LobbyHeldGuis"
lobbyHeldGuis.Parent = LocalPlayer

local screenGuis = {}
local enabledsByScreenGui = {}
local v2 = false

local function hold(screenGui)
	if kept(screenGui) or enabledsByScreenGui[screenGui] ~= nil or screenGui.Parent ~= PlayerGui then -- inferred equivalent call
		return
	end

	if screenGui.ResetOnSpawn and screenGui:IsA("ScreenGui") then
		enabledsByScreenGui[screenGui] = screenGui.Enabled
		screenGui.Enabled = false
	else
		table.insert(screenGuis, screenGui)
		screenGui.Parent = lobbyHeldGuis
	end
end

local function releaseAll()
	for _, v3 in screenGuis do
		if v3.Parent == lobbyHeldGuis then
			v3.Parent = PlayerGui
		end
	end

	table.clear(screenGuis)

	for k, enabled in enabledsByScreenGui do
		if k.Parent == PlayerGui then
			k.Enabled = enabled
		end
	end

	table.clear(enabledsByScreenGui)
end

local layer = Style.layer(PlayerGui, "LobbyClock", 7)
layer.Enabled = false
local label = Style.label(layer, "Head", "", 20, Style.FONT, 1.5)
label.AutomaticSize = Enum.AutomaticSize.None
label.AnchorPoint = Vector2.new(0.5, 0)
label.Size = UDim2.fromOffset(420, 24)
label.Position = UDim2.new(0.5, 0, 0, Style.topInset() + 8)
local label2 = Style.label(layer, "Clock", "", 44, Style.FONT, 2)
label2.AutomaticSize = Enum.AutomaticSize.None
label2.AnchorPoint = Vector2.new(0.5, 0)
label2.Size = UDim2.fromOffset(420, 48)
label2.Position = UDim2.new(0.5, 0, 0, Style.topInset() + 30)

local Game = ReplicatedStorage:WaitForChild("Game")
local Vote = Game:WaitForChild("Vote")
local domination = nil
task.spawn(function()
	domination = Game:WaitForChild("Domination")
end)

local function num(value) -- 3 equivalent calls inferred from this helper
	return if type(value) == "number" then value else 0
end

local v3 = {
	enabled = false,
	head = "",
	clock = "",
	color = nil,
	clockOn = nil
}
local function setEnabled(enabled: boolean) -- 1 equivalent call inferred from this helper
	if enabled ~= v3.enabled then
		v3.enabled = enabled
		layer.Enabled = enabled
	end
end
local function setClockText(clock: string, color: Color3) -- 4 equivalent calls inferred from this helper
	if clock ~= v3.clock then
		v3.clock = clock
		label2.Text = clock
	end

	if color ~= v3.color then
		v3.color = color
		label2.TextColor3 = color
	end

	if v3.clockOn ~= true then
		v3.clockOn = true
		label2.Visible = true
	end
end
local function setHead(p: string) -- 1 equivalent call inferred from this helper
	if p ~= v3.head then
		v3.head = p
		label.Text = p
	end
end
local function setClock(p: string, p2: number?)
	setHead(p) -- inferred equivalent call

	if p2 then
		local v4 = math.max(0, p2)
		local clock = Style.clock(v4)
		local v5 = if v4 <= 10 then Style.HAZARD else Style.WHITE
		setClockText(clock, v5) -- inferred equivalent call
	elseif v3.clockOn ~= false then
		v3.clockOn = false
		label2.Visible = false
	end
end

local function clockStep()
	if v2 then
		local stage = Vote:GetAttribute("Stage")
		local v4 = v2

		if v4 then
			if domination == nil then
				v4 = false
			else
				v4 = type(stage) ~= "string" or stage == ""
			end
		end

		setEnabled(v4) -- inferred equivalent call

		if not v4 then
			return
		end

		local v5 = domination
		local serverTimeNow = workspace:GetServerTimeNow()
		local phase = v5:GetAttribute("Phase")

		if phase == "starting" then
			local v6 = num(v5:GetAttribute("StartsAt")) -- inferred equivalent call

			if v6 > 0 then
				local v7 = v6 - serverTimeNow

				if v3.head ~= "GAME STARTING IN" then
					v3.head = "GAME STARTING IN"
					label.Text = "GAME STARTING IN"
				end

				if v7 then
					local v8 = math.max(0, v7)
					local clock = Style.clock(v8)
					local v9

					if v8 <= 10 then
						v9 = Style.HAZARD
					else
						v9 = Style.WHITE
					end

					setClockText(clock, v9) -- inferred equivalent call
				elseif v3.clockOn ~= false then
					v3.clockOn = false
					label2.Visible = false
				end
			else
				if v3.head ~= "GAME STARTING" then
					v3.head = "GAME STARTING"
					label.Text = "GAME STARTING"
				end

				if v3.clockOn ~= false then
					v3.clockOn = false
					label2.Visible = false
				end
			end
		elseif phase == "live" then
			if v5:GetAttribute("Overtime") == true then
				if v3.head ~= "MATCH IN PROGRESS" then
					v3.head = "MATCH IN PROGRESS"
					label.Text = "MATCH IN PROGRESS"
				end

				local hazard = Style.HAZARD

				if v3.clock ~= "OVERTIME" then
					v3.clock = "OVERTIME"
					label2.Text = "OVERTIME"
				end

				if hazard ~= v3.color then
					v3.color = hazard
					label2.TextColor3 = hazard
				end

				if v3.clockOn ~= true then
					v3.clockOn = true
					label2.Visible = true
				end
			else
				local v6 = num(v5:GetAttribute("EndsAt")) - serverTimeNow -- inferred equivalent call

				if v3.head ~= "MATCH IN PROGRESS" then
					v3.head = "MATCH IN PROGRESS"
					label.Text = "MATCH IN PROGRESS"
				end

				if v6 then
					local v7 = math.max(0, v6)
					local clock = Style.clock(v7)
					local v8

					if v7 <= 10 then
						v8 = Style.HAZARD
					else
						v8 = Style.WHITE
					end

					setClockText(clock, v8) -- inferred equivalent call
				elseif v3.clockOn ~= false then
					v3.clockOn = false
					label2.Visible = false
				end
			end
		elseif phase == "over" then
			local v6 = num(v5:GetAttribute("NextAt")) -- inferred equivalent call

			if v6 > 0 then
				local v7 = v6 - serverTimeNow

				if v3.head ~= "NEXT ROUND IN" then
					v3.head = "NEXT ROUND IN"
					label.Text = "NEXT ROUND IN"
				end

				if v7 then
					local v8 = math.max(0, v7)
					local clock = Style.clock(v8)
					local v9

					if v8 <= 10 then
						v9 = Style.HAZARD
					else
						v9 = Style.WHITE
					end

					setClockText(clock, v9) -- inferred equivalent call
				elseif v3.clockOn ~= false then
					v3.clockOn = false
					label2.Visible = false
				end
			else
				if v3.head ~= "ROUND OVER" then
					v3.head = "ROUND OVER"
					label.Text = "ROUND OVER"
				end

				if v3.clockOn ~= false then
					v3.clockOn = false
					label2.Visible = false
				end
			end
		elseif v3.enabled ~= false then
			v3.enabled = false
			layer.Enabled = false
		end
	elseif v3.enabled ~= false then
		v3.enabled = false
		layer.Enabled = false
	end
end
local renderSteppedConnection = nil

local function update()
	local v4

	if LocalPlayer.Team == nil then
		v4 = LocalPlayer:GetAttribute("PickingTeam") == true
	else
		v4 = false
	end

	if v4 then
		for _, screenGui in PlayerGui:GetChildren() do
			if not (held(screenGui) and v[screenGui.Name] ~= true and string.sub(screenGui.Name, 1, 6) ~= "Topbar" and enabledsByScreenGui[screenGui] == nil) then -- inferred equivalent call
				continue
			end

			if screenGui.Parent ~= PlayerGui then
				continue
			end

			if screenGui.ResetOnSpawn and screenGui:IsA("ScreenGui") then
				enabledsByScreenGui[screenGui] = screenGui.Enabled
				screenGui.Enabled = false
			else
				table.insert(screenGuis, screenGui)
				screenGui.Parent = lobbyHeldGuis
			end
		end
	elseif v2 then
		releaseAll()
	end

	v2 = v4

	if v4 and not renderSteppedConnection then
		renderSteppedConnection = RunService.RenderStepped:Connect(clockStep)
	elseif not v4 and renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil

		if v3.enabled ~= false then
			v3.enabled = false
			layer.Enabled = false
		end
	end
end

LocalPlayer:GetPropertyChangedSignal("Team"):Connect(update)
LocalPlayer:GetAttributeChangedSignal("PickingTeam"):Connect(update)
PlayerGui.ChildAdded:Connect(function(child)
	if v2 and held(child) then -- inferred equivalent call
		task.defer(hold, child)
	end
end)
task.spawn(function()
	while true do
		task.wait(0.5)
		update()
	end
end)
update()

if not v2 and v3.enabled ~= false then
	v3.enabled = false
	layer.Enabled = false
end