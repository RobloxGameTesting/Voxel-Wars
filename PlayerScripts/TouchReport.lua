local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local reportTouch = ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("Remotes"):WaitForChild("ReportTouch")
local Glyph = require(script.Parent:WaitForChild("GameUI"):WaitForChild("Glyph"))

local v = nil
local v2 = nil
local function report() -- 2 equivalent calls inferred from this helper
	local v3 = UserInputService.TouchEnabled

	if v3 then
		local keyboardEnabled = UserInputService.KeyboardEnabled or UserInputService.MouseEnabled
		v3 = not keyboardEnabled
	end

	local mode = Glyph.mode()

	if v3 ~= v or mode ~= v2 then
		v = v3
		v2 = mode
		reportTouch:FireServer(v3, mode)
	end
end

local count = 0
local function later()
	count += 1
	local v3 = count
	task.delay(2.5, function()
		if v3 == count then
			report() -- inferred equivalent call
		end
	end)
end

report() -- inferred equivalent call
UserInputService:GetPropertyChangedSignal("KeyboardEnabled"):Connect(later)
UserInputService:GetPropertyChangedSignal("MouseEnabled"):Connect(later)
Glyph.onChange(later)