game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VRService = game:GetService("VRService")
local HapticService = game:GetService("HapticService")

local VR = {}

VR.GRIP = CFrame.Angles(-0.20943951023931956, 0, 0)

VR.HAND_POINT = CFrame.Angles(-0.20943951023931956, 0, 0)

function VR.on()
	return VRService.VREnabled
end

function VR.watch(callback)
	local vREnabledChangedConnection = VRService:GetPropertyChangedSignal("VREnabled"):Connect(function()
		callback(VRService.VREnabled)
	end)
	task.spawn(callback, VRService.VREnabled)
	return vREnabledChangedConnection
end

local v = {
	Head = Enum.UserCFrame.Head,
	Left = Enum.UserCFrame.LeftHand,
	Right = Enum.UserCFrame.RightHand
}

local function world(p) -- 1 equivalent call inferred from this helper
	local currentCamera = workspace.CurrentCamera
	local userCFrame = VRService:GetUserCFrame(p)
	return currentCamera.CFrame * (userCFrame.Rotation + userCFrame.Position * currentCamera.HeadScale)
end

function VR.head()
	if VR.on() then
		return workspace.CurrentCamera:GetRenderCFrame()
	end

	return workspace.CurrentCamera.CFrame
end

function VR.tracked(p: string)
	local v2 = if p == "Left" then v.Left else v.Right
	return VRService:GetUserCFrameEnabled(v2)
end

function VR.hand(p: string)
	if not VR.on() then
		return workspace.CurrentCamera.CFrame
	end

	local v2 = if p == "Left" then v.Left else v.Right
	return world(v2) -- inferred equivalent call
end

local Gamepad1 = Enum.UserInputType.Gamepad1
function VR.grip(p: string)
	local v2

	if p == "Left" then
		v2 = Enum.KeyCode.ButtonL1
	else
		v2 = Enum.KeyCode.ButtonR1
	end

	return UserInputService:IsGamepadButtonDown(Gamepad1, v2)
end

function VR.trigger(p: string)
	local v2

	if p == "Left" then
		v2 = Enum.KeyCode.ButtonL2
	else
		v2 = Enum.KeyCode.ButtonR2
	end

	return UserInputService:IsGamepadButtonDown(Gamepad1, v2)
end

function VR.stick(p: string)
	local v2

	if p == "Left" then
		v2 = Enum.KeyCode.Thumbstick1
	else
		v2 = Enum.KeyCode.Thumbstick2
	end

	for _, v3 in UserInputService:GetGamepadState(Gamepad1) do
		if v3.KeyCode == v2 then
			return Vector2.new(v3.Position.X, v3.Position.Y)
		end
	end

	return Vector2.zero
end

local v2 = { Left = Enum.VibrationMotor.LeftHand, Right = Enum.VibrationMotor.RightHand }
local v3 = { Left = 0, Right = 0 }
function VR.buzz(p: string, value: number, duration: number)
	if not VR.on() then
		return
	end

	local v4 = v2[p]

	if not v4 then
		return
	end

	local v5 = Gamepad1
	local success, result = pcall(HapticService.IsMotorSupported, HapticService, Gamepad1, v4)

	if not (success and result) then
		v4 = Enum.VibrationMotor.Large

		if p == "Right" then
			v5 = Enum.UserInputType.Gamepad2
		else
			v5 = Gamepad1
		end

		local success2, result2 = pcall(HapticService.IsMotorSupported, HapticService, v5, v4)

		if not (success2 and result2) then
			return
		end
	end

	v3[p] += 1
	local v6 = v3[p]
	local setMotor = HapticService.SetMotor
	pcall(setMotor, HapticService, v5, v4, (math.clamp(value, 0, 1)))
	task.delay(duration, function()
		if v3[p] == v6 then
			pcall(HapticService.SetMotor, HapticService, v5, v4, 0)
		end
	end)
end

local v4 = nil
local function view() -- 1 equivalent call inferred from this helper
	if not v4 then
		local Viewmodel = require(script.Parent:WaitForChild("Viewmodel"))
		v4 = Viewmodel
	end

	local current = v4.current
	return if current and current.active then current else nil
end

function VR.frame(p)
	if not VR.on() then
		return p.CFrame
	end

	local current = view() -- inferred equivalent call

	if current and current.vrAim then
		return current.vrAim
	end

	return VR.hand("Right") * VR.HAND_POINT
end

function VR.ray(object, p: number, p2: number)
	if not VR.on() then
		return object:ViewportPointToRay(p, p2)
	end

	local frame = VR.frame(object)
	return Ray.new(frame.Position, frame.LookVector)
end

function VR.eye()
	return VR.head().Position
end

return VR