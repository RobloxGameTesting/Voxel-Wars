local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local Movement = require(Voxel:WaitForChild("Movement"))
local Viewmodel = require(Voxel:WaitForChild("Viewmodel"))

local function scoped(tool): boolean -- 2 equivalent calls inferred from this helper
	return tool ~= nil
		and (tool:FindFirstChild("SniperClient") ~= nil or tool:FindFirstChild("SniperFamilyClient") ~= nil)
end

local v = 0

while true do
	task.wait(0.5)
	local character = LocalPlayer.Character
	local tool = character and character:FindFirstChildOfClass("Tool")
	local v2 = false

	if not scoped(tool) then -- inferred equivalent call
		for _, screenGui in PlayerGui:GetChildren() do
			if screenGui.Name == "SniperSight" and screenGui:IsA("ScreenGui") and screenGui.Enabled then
				v2 = true
				break
			end
		end

		local currentCamera = workspace.CurrentCamera

		if
			currentCamera
			and (currentCamera:FindFirstChild("ScopeBlur") or currentCamera:FindFirstChild("ScopeBlurFocus"))
		then
			v2 = true
		end
	end

	local v3 = tool == nil and Viewmodel.current == nil and Movement.weaponFov == true

	v = not (v2 or v3) and 0 or v + 1

	if not (v >= 2) then
		continue
	end

	v = 0

	for _, screenGui in PlayerGui:GetChildren() do
		if screenGui.Name == "SniperSight" and screenGui:IsA("ScreenGui") then
			screenGui.Enabled = false
		end
	end

	if not scoped(tool) then -- inferred equivalent call
		for _, child in workspace.CurrentCamera:GetChildren() do
			if child.Name == "ScopeBlur" or child.Name == "ScopeBlurFocus" then
				child:Destroy()
			end
		end
	end

	if not (tool == nil and Viewmodel.current == nil and Movement.weaponFov == true) then
		continue
	end

	workspace.CurrentCamera.FieldOfView = Movement.FIELD_OF_VIEW
	Movement.weaponScale = 1
	Movement.blockSprint = false
	Movement.weaponFov = false
end