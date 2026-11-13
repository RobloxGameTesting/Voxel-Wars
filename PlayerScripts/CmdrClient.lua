local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CmdrClient = require(ReplicatedStorage:WaitForChild("CmdrClient"))

CmdrClient:SetActivationKeys({ Enum.KeyCode.F2 })
CmdrClient:SetPlaceName("voxel")
CmdrClient:SetActivationUnlocksMouse(true)

local v = false
local mouseIconEnabled = true
CmdrClient.Toggled:Connect(function(flag: boolean)
	if flag and not v then
		v = true
		mouseIconEnabled = UserInputService.MouseIconEnabled
		RunService:BindToRenderStep("CmdrPointer", Enum.RenderPriority.Last.Value + 11, function()
			UserInputService.MouseIconEnabled = true
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end)
	elseif not flag and v then
		v = false
		RunService:UnbindFromRenderStep("CmdrPointer")
		UserInputService.MouseIconEnabled = mouseIconEnabled
	end
end)