local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local v = nil
local object = setmetatable({}, { __mode = "k" })

local function watch(tool)
	if object[tool] then
		return
	end

	object[tool] = true
	tool.Activated:Connect(function()
		if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
			v = tool
		end
	end)
	tool.Deactivated:Connect(function()
		if v == tool then
			v = nil
		end
	end)
end

local function onCharacter(character)
	for _, tool in character:GetChildren() do
		if tool:IsA("Tool") then
			watch(tool)
		end
	end

	character.ChildAdded:Connect(function(tool)
		if tool:IsA("Tool") then
			watch(tool)
		end
	end)
end

if LocalPlayer.Character then
	onCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(onCharacter)

UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
	if
		gameProcessed
		or input.UserInputType ~= Enum.UserInputType.MouseButton1
		or not (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl))
	then
		return
	end

	local character = LocalPlayer.Character
	local tool = character and character:FindFirstChildOfClass("Tool")

	if tool and tool.Enabled and not tool.ManualActivationOnly then
		tool:Activate()
	end
end)

RunService.Heartbeat:Connect(function()
	local v2 = v

	if not v2 or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
		return
	end

	v = nil

	if v2.Parent == LocalPlayer.Character then
		v2:Deactivate()
	end
end)