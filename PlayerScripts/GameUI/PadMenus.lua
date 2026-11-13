local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Style = require(script.Parent:WaitForChild("Style"))
local Glyph = require(script.Parent:WaitForChild("Glyph"))
local MenuLock = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("MenuLock"))

local PadMenus = {}

local v = Enum.ContextActionPriority.High.Value + 100

local LocalPlayer = Players.LocalPlayer
local v2 = {}
local v3 = 0

GuiService.AutoSelectGuiEnabled = false

local padSelection = Instance.new("Frame")
padSelection.Name = "PadSelection"
padSelection.BackgroundTransparency = 1
padSelection.Size = UDim2.new(1, 8, 1, 8)
padSelection.Position = UDim2.fromOffset(-4, -4)

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Style.HAZARD
uiStroke.Thickness = 3
uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uiStroke.Parent = padSelection
Style.corner(padSelection, 5)

task.spawn(function()
	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	playerGui.SelectionImageObject = padSelection
end)

local padMenuHints = Instance.new("ScreenGui")
padMenuHints.Name = "PadMenuHints"
padMenuHints.DisplayOrder = 60
padMenuHints.ResetOnSpawn = false
padMenuHints.IgnoreGuiInset = true
padMenuHints.Enabled = false
local region = Style.region(padMenuHints, "Hints", Vector2.new(0.5, 1), Vector2.new(0, -18), Vector2.new(720, 34))
local row = Instance.new("Frame")
row.Name = "Row"
row.BackgroundTransparency = 1
row.Size = UDim2.fromScale(1, 1)
row.Parent = region
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.FillDirection = Enum.FillDirection.Horizontal
uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
uiListLayout.Padding = UDim.new(0, 18)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = row

local function hint(layoutOrder: number, list, name: string)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.BackgroundTransparency = 1
	frame.AutomaticSize = Enum.AutomaticSize.X
	frame.Size = UDim2.fromOffset(0, 26)
	frame.LayoutOrder = layoutOrder
	frame.Parent = row
	local uiListLayout2 = Instance.new("UIListLayout")
	uiListLayout2.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout2.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout2.Padding = UDim.new(0, 4)
	uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout2.Parent = frame

	for k, item in list do
		local cap = Glyph.cap(frame, nil, item, 24)
		cap.LayoutOrder = k
	end

	local label = Style.label(frame, "Word", name, 17, Style.FONT, 1.5)
	label.LayoutOrder = #list + 1
	return frame
end

hint(1, { Enum.KeyCode.ButtonA }, "SELECT")
hint(2, { Enum.KeyCode.ButtonB }, "BACK")
local v4 = hint(3, { Enum.KeyCode.ButtonL1, Enum.KeyCode.ButtonR1 }, "TABS")
task.spawn(function()
	padMenuHints.Parent = LocalPlayer:WaitForChild("PlayerGui")
end)

local function top() -- 5 equivalent calls inferred from this helper
	return v2[#v2]
end

local function shown(instance)
	while instance do
		if instance:IsA("GuiObject") and not instance.Visible then
			return false
		end

		if instance:IsA("ScreenGui") then
			return instance.Enabled
		end

		instance = instance.Parent
	end

	return false
end

local function firstButton(folder)
	local v5 = nil

	for _, button in folder:GetDescendants() do
		if not (button:IsA("GuiButton") and button.Selectable and button.Active ~= false and button.AbsoluteSize.X > 2) then
			continue
		end

		if not shown(button) then
			continue
		end

		local absolutePosition = button.AbsolutePosition
		local absolutePosition2

		if v5 then
			absolutePosition2 = v5.AbsolutePosition
		end

		if not (not absolutePosition2 or absolutePosition.Y < absolutePosition2.Y - 4 or math.abs(absolutePosition.Y - absolutePosition2.Y) <= 4 and absolutePosition.X < absolutePosition2.X) then
			continue
		end

		v5 = button
	end

	return v5
end

local function inside(instance, root) -- 3 equivalent calls inferred from this helper
	return instance ~= nil and (instance == root or instance:IsDescendantOf(root))
end

local function seat()
	local v5 = top() -- inferred equivalent call

	if not v5 or not Glyph.gamepad() or v3 > 0 then
		return
	end

	local selectedObject = v5.opts.first and v5.opts.first() or firstButton(v5.root)

	if selectedObject and shown(selectedObject) then
		GuiService.SelectedObject = selectedObject
	end
end

local v5 = nil
task.spawn(function()
	local Icon = require(ReplicatedStorage:WaitForChild("TopbarPlus"):WaitForChild("Icon"))
	v5 = Icon
	v5.highlightKey = #v2 > 0 and Enum.KeyCode.ButtonSelect
end)

local v6 = -1e999
local function closeTop() -- 1 equivalent call inferred from this helper
	local now = os.clock()

	if now - v6 < 0.15 then
		return
	end

	v6 = now
	local v7 = top() -- inferred equivalent call

	if v7 and v7.close then
		v7.close()
	end
end
local function back(_: string, p)
	if p == Enum.UserInputState.Begin then
		closeTop() -- inferred equivalent call
	end

	return Enum.ContextActionResult.Sink
end

UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.ButtonB and #v2 > 0 then
		task.defer(closeTop)
	end
end)
local function tabs(_: string, p, p2)
	local v7 = top() -- inferred equivalent call

	if not (v7 and v7.opts.tab) then
		return Enum.ContextActionResult.Pass
	end

	if p == Enum.UserInputState.Begin then
		v7.opts.tab(p2.KeyCode == Enum.KeyCode.ButtonL1 and -1 or 1)
		task.defer(seat)
	end

	return Enum.ContextActionResult.Sink
end

local function update()
	local v7 = top() -- inferred equivalent call
	local open = v7 ~= nil
	Glyph.claim("menu", open)

	if v5 then
		local v8 = v5
		local highlightKey

		if open then
			highlightKey = Enum.KeyCode.ButtonSelect
		else
			highlightKey = false
		end

		v8.highlightKey = highlightKey
	end

	if open then
		ContextActionService:BindActionAtPriority("PadMenuBack", back, false, v, Enum.KeyCode.ButtonB)
		ContextActionService:BindActionAtPriority(
			"PadMenuTabs",
			tabs,
			false,
			v,
			Enum.KeyCode.ButtonL1,
			Enum.KeyCode.ButtonR1
		)
	else
		ContextActionService:UnbindAction("PadMenuBack")
		ContextActionService:UnbindAction("PadMenuTabs")
	end

	local enabled = open and Glyph.gamepad()
	MenuLock.open = open
	MenuLock.set(enabled)
	padMenuHints.Enabled = enabled

	if v4 then
		v4.Visible = v7 ~= nil and v7.opts.tab ~= nil
	end

	if enabled then
		task.defer(seat)
	elseif GuiService.SelectedObject and not open then
		GuiService.SelectedObject = nil
	end
end

local function listsOf(button, folder)
	local parent = button.Parent

	while parent and parent ~= folder and parent:IsA("GuiObject") do
		if parent:IsA("ScrollingFrame") and parent.Selectable then
			parent.Selectable = false
		end

		parent = parent.Parent
	end
end
local function fixLists(folder)
	for _, button in folder:GetDescendants() do
		if button:IsA("GuiButton") then
			listsOf(button, folder)
		end
	end

	return folder.DescendantAdded:Connect(function(button)
		if button:IsA("GuiButton") then
			listsOf(button, folder)
		end
	end)
end

local function scaleOver(guiBase2d)
	local v7 = 1

	while guiBase2d and guiBase2d:IsA("GuiBase2d") do
		local uiScale = guiBase2d:FindFirstChildOfClass("UIScale")

		if uiScale then
			v7 *= uiScale.Scale
		end

		guiBase2d = guiBase2d.Parent
	end

	return v7
end

local function showInLists(selectedObject)
	local parent = selectedObject.Parent

	while parent and parent:IsA("GuiObject") do
		if parent:IsA("ScrollingFrame") then
			local v7 = math.max(scaleOver(parent), 0.001)
			local function shift(p: number, p2: number, p3: number, p4: number) -- 2 equivalent calls inferred from this helper
				local v8 = p4 - p3

				if p2 - p - 20 < v8 or p3 < p + 10 then
					return p3 - p - 10
				end

				if p2 - 10 < p4 then
					return p4 - p2 + 10
				end

				return 0
			end

			local absolutePosition = parent.AbsolutePosition
			local absoluteWindowSize = parent.AbsoluteWindowSize
			local absolutePosition2 = selectedObject.AbsolutePosition
			local v8 = selectedObject.AbsolutePosition + selectedObject.AbsoluteSize
			local v9 = shift(absolutePosition.X, absolutePosition.X + absoluteWindowSize.X, absolutePosition2.X, v8.X) -- inferred equivalent call
			local v10 = shift(absolutePosition.Y, absolutePosition.Y + absoluteWindowSize.Y, absolutePosition2.Y, v8.Y) -- inferred equivalent call

			if v9 ~= 0 or v10 ~= 0 then
				parent.CanvasPosition += Vector2.new(v9 / v7, v10 / v7)
			end
		end

		parent = parent.Parent
	end
end

function PadMenus.open(id: string, root, close, options)
	pcall(function()
		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		local voxelWarsAnalyticsReport = ReplicatedStorage2:FindFirstChild("VoxelWarsAnalyticsReport")

		if voxelWarsAnalyticsReport and voxelWarsAnalyticsReport:IsA("RemoteEvent") then
			voxelWarsAnalyticsReport:FireServer("menu", id)
		end
	end)

	for k, v7 in v2 do
		if v7.id == id then
			table.remove(v2, k)

			if not v7.watch then
				break
			end

			v7.watch:Disconnect()
			break
		end
	end

	table.insert(v2, {
		id = id,
		root = root,
		close = close,
		opts = options or {},
		watch = fixLists(root)
	})
	update()
end

function PadMenus.close(p: string)
	for k, v7 in v2 do
		if v7.id == p then
			table.remove(v2, k)

			if v7.watch then
				v7.watch:Disconnect()
			end

			local selectedObject = GuiService.SelectedObject

			if selectedObject and inside(selectedObject, v7.root) then -- inferred equivalent call
				GuiService.SelectedObject = nil
			end

			update()
			break
		end
	end
end

function PadMenus.reseat()
	task.defer(seat)
end

function PadMenus.isOpen(): boolean
	return #v2 > 0
end

local v7 = nil
GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(function()
	local selectedObject = GuiService.SelectedObject

	if v3 > 0 then
		return
	end

	if selectedObject and #v2 > 0 then
		local flag = false

		for _, v8 in v2 do
			if inside(selectedObject, v8.root) then -- inferred equivalent call
				flag = true
				break
			end
		end

		if flag then
			v7 = selectedObject
			showInLists(selectedObject)
		else
			local selectedObject2 = v7
			task.defer(function()
				if GuiService.SelectedObject ~= selectedObject or #v2 == 0 then
					return
				end

				local v8 = top() -- inferred equivalent call

				if selectedObject2 and v8 and inside(selectedObject2, v8.root) and shown(selectedObject2) then -- inferred equivalent call
					GuiService.SelectedObject = selectedObject2
					return
				end

				GuiService.SelectedObject = nil
				seat()
			end)
			return
		end
	end

	if GuiService.SelectedObject == nil and #v2 > 0 and Glyph.gamepad() then
		task.delay(0.05, function()
			if GuiService.SelectedObject == nil then
				seat()
			end
		end)
	end
end)
Glyph.onChange(update)

local controls = nil
MenuLock.onChange(function(flag: boolean)
	if controls then
		if flag then
			controls:Disable()
		else
			controls:Enable()
		end
	end
end)
task.spawn(function()
	local playerScripts = LocalPlayer:WaitForChild("PlayerScripts")
	local playerModule = playerScripts:FindFirstChild("PlayerModule")

	if not playerModule then
		local thread = task.delay(60, function()
			warn("[PadMenus] PlayerScripts.PlayerModule still missing after 60 s: menus can't hold the pad's walking until it arrives")
		end)

		repeat
			playerScripts.ChildAdded:Wait()
			playerModule = playerScripts:FindFirstChild("PlayerModule")
		until playerModule

		task.cancel(thread)
	end

	assert(playerModule:IsA("ModuleScript"), "[PadMenus] PlayerScripts.PlayerModule is not a ModuleScript")
	local module = require(playerModule)
	controls = module:GetControls()

	if MenuLock.held then
		controls:Disable()
	end
end)

local v8 = {}
local v9 = {}
function PadMenus.onView(callback, callback2)
	if callback then
		table.insert(v8, callback)
	end

	if callback2 then
		table.insert(v9, callback2)
	end
end
local v10 = nil
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode ~= Enum.KeyCode.ButtonSelect or gameProcessed or #v2 > 0 then
		return
	end

	local now = os.clock()
	v10 = now
	task.delay(0.4, function()
		if v10 == now then
			v10 = nil

			for _, callback in v9 do
				task.spawn(callback)
			end
		end
	end)
end)
UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.ButtonSelect and v10 then
		v10 = nil

		for _, callback in v8 do
			task.spawn(callback)
		end
	end
end)

function PadMenus.hold(p: string, callback)
	local v11 = "PadShow_" .. p
	v3 += 1
	GuiService.SelectedObject = nil
	ContextActionService:BindActionAtPriority(v11, function(_: string, p2)
		if p2 == Enum.UserInputState.Begin then
			callback()
		end

		return Enum.ContextActionResult.Sink
	end, false, v + 100, Enum.KeyCode.ButtonA, Enum.KeyCode.ButtonB, Enum.KeyCode.Return, Enum.KeyCode.Space)
	local flag = false
	return function()
		if flag then
			return
		end

		flag = true
		ContextActionService:UnbindAction(v11)
		v3 -= 1

		if v3 == 0 then
			task.defer(seat)
		end
	end
end

return PadMenus