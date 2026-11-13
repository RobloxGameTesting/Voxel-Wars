local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local v = { Enum.KeyCode.Space, Enum.KeyCode.E }
local v2 = { Enum.KeyCode.LeftControl, Enum.KeyCode.Q }

local fn = nil

local function held(items): boolean -- 2 equivalent calls inferred from this helper
	for _, item in items do
		if UserInputService:IsKeyDown(item) then
			return true
		end
	end

	return false
end

local function start(folder)
	local humanoidRootPart = folder:WaitForChild("HumanoidRootPart", 10)
	local humanoid = folder:WaitForChild("Humanoid", 10)

	if
		not humanoidRootPart
		or not humanoid
		or LocalPlayer.Character ~= folder
		or not LocalPlayer:GetAttribute("Flying")
	then
		return
	end

	local flyAttachment = Instance.new("Attachment")
	flyAttachment.Name = "FlyAttachment"
	flyAttachment.Parent = humanoidRootPart
	local flyMover = Instance.new("LinearVelocity")
	flyMover.Name = "FlyMover"
	flyMover.Attachment0 = flyAttachment
	flyMover.RelativeTo = Enum.ActuatorRelativeTo.World
	flyMover.ForceLimitsEnabled = false
	flyMover.VectorVelocity = Vector3.new(0, 0, 0)
	flyMover.Parent = humanoidRootPart
	local parts = {}
	local steppedConnection = RunService.Stepped:Connect(function()
		for _, part in folder:GetDescendants() do
			if not (part:IsA("BasePart") and part.CanCollide) then
				continue
			end

			part.CanCollide = false

			if not table.find(parts, part) then
				table.insert(parts, part)
			end
		end
	end)
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local flying = LocalPlayer:GetAttribute("Flying")
		local currentCamera = workspace.CurrentCamera
		flyMover.Enabled = humanoid.SeatPart == nil

		if type(flying) ~= "number" or not currentCamera then
			return
		end

		local lookVector = currentCamera.CFrame.LookVector
		local rightVector = currentCamera.CFrame.RightVector
		local vector3 = Vector3.new(lookVector.X, 0, lookVector.Z)
		local v3 = not (vector3.Magnitude > 0.01) and Vector3.new(0, 0, -1) or vector3.Unit
		local vector3_2 = Vector3.new(rightVector.X, 0, rightVector.Z)
		local v4 = not (vector3_2.Magnitude > 0.01) and Vector3.new(1, 0, 0) or vector3_2.Unit
		local moveDirection = humanoid.MoveDirection
		local v5 = lookVector * moveDirection:Dot(v3) + rightVector * moveDirection:Dot(v4)

		if not UserInputService:GetFocusedTextBox() then
			if held(v) then -- inferred equivalent call
				v5 += Vector3.new(0, 1, 0)
			end

			if held(v2) then -- inferred equivalent call
				v5 -= Vector3.new(0, 1, 0)
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
				flying *= 3
			end
		end

		flyMover.VectorVelocity = not (v5.Magnitude > 0.01) and Vector3.new(0, 0, 0) or v5.Unit * flying
	end)
	fn = function()
		fn = nil
		steppedConnection:Disconnect()
		renderSteppedConnection:Disconnect()
		flyMover:Destroy()
		flyAttachment:Destroy()

		for _, v3 in parts do
			v3.CanCollide = true
		end

		humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
	end
end

local function follow() -- 1 equivalent call inferred from this helper
	if fn then
		fn()
	end

	if LocalPlayer:GetAttribute("Flying") and LocalPlayer.Character then
		task.spawn(start, LocalPlayer.Character)
	end
end
LocalPlayer:GetAttributeChangedSignal("Flying"):Connect(function()
	if not (LocalPlayer:GetAttribute("Flying") and fn) then
		follow() -- inferred equivalent call
	end
end)
LocalPlayer.CharacterAdded:Connect(follow)
LocalPlayer.CharacterRemoving:Connect(function()
	if fn then
		fn()
	end
end)