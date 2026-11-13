local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PadMenus = require(script.Parent:WaitForChild("GameUI"):WaitForChild("PadMenus"))

local v = { Hammer = true, Shovel = true }

local v2 = false

local function meleeTool(character)
	for _, v3 in { character, LocalPlayer:FindFirstChildOfClass("Backpack") } do
		if not v3 then
			continue
		end

		for _, tool in v3:GetChildren() do
			if tool:IsA("Tool") and v[tool.Name] then
				return tool
			end
		end
	end

	return nil
end

local function quick()
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if v2 or not humanoid or humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if
		LocalPlayer:GetAttribute("InVehicle")
		or PadMenus.isOpen()
		or workspace.CurrentCamera.CameraType ~= Enum.CameraType.Custom
	then
		return
	end

	local v3 = meleeTool(character)

	if not v3 then
		return
	end

	local tool = character:FindFirstChildOfClass("Tool")
	v2 = true

	if tool ~= v3 then
		humanoid:EquipTool(v3)
	end

	local v4 = false
	local quickDoneChangedConnection = v3:GetAttributeChangedSignal("QuickDone"):Connect(function()
		v4 = true
	end)
	v3:SetAttribute("QuickSwing", os.clock())
	local lastTime = os.clock()

	while not v4 and os.clock() - lastTime < 4 and v3.Parent == character do
		task.wait()
	end

	quickDoneChangedConnection:Disconnect()

	local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")

	if tool and tool ~= v3 and v3.Parent == character and tool.Parent == backpack and humanoid.Health > 0 then
		humanoid:EquipTool(tool)
	end

	v2 = false
end

UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
	if input.KeyCode == Enum.KeyCode.ButtonR3 and not gameProcessed then
		task.spawn(quick)
	end
end)