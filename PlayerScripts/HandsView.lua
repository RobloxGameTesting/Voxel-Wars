local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local Viewmodel = require(Voxel:WaitForChild("Viewmodel"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local VR = require(ReplicatedStorage2:WaitForChild("Voxel"):WaitForChild("VR"))
local VoxelSound = require(Voxel:WaitForChild("VoxelSound"))
local TouchControls = require(Voxel:WaitForChild("TouchControls"))
local MenuLock = require(Voxel:WaitForChild("MenuLock"))
local punch = Voxel:WaitForChild("Remotes"):WaitForChild("Punch")

local LocalPlayer = Players.LocalPlayer
local newVector3 = Vector3.new

local hands = Instance.new("Tool")
hands.Name = "Hands"
hands.CanBeDropped = false
local handle = Instance.new("Part")
handle.Name = "Handle"
handle.Size = Vector3.new(0.2, 0.2, 0.2)
handle.Transparency = 1
handle.Anchored = true
handle.CanCollide = false
handle.CanQuery = false
handle.CanTouch = false
handle.Parent = hands

local v = Viewmodel.new(hands, {
	name = "HANDS",
	hold = CFrame.new(0, -1.35, -1.9) * CFrame.Angles(-0.13962634015954636, 0, 0),
	rightHand = Vector3.new(0.62, 0, 0.1),
	leftHand = Vector3.new(-0.62, 0, 0.1),
	muzzle = Vector3.new(0, 0, 0),
	aimPoint = Vector3.new(0, 0, 0),
	aimDistance = 2,
	aimFov = 70,
	silentGear = true,
	aimMove = 1,
	reach = 2,
	sprintHold = CFrame.new(0, -1.9, -1.5) * CFrame.Angles(-0.3490658503988659, 0, 0),
	hipKick = Vector3.new(0, 0, 0),
	hipKickRot = Vector3.new(0, 0, 0),
	aimKick = Vector3.new(0, 0, 0),
	aimKickRot = Vector3.new(0, 0, 0),
	recoilTime = 0.3,
	punch = 0
})

v.aimBlocked = true

local v2 = {
	"RightUpperArm",
	"RightLowerArm",
	"RightHand",
	"LeftUpperArm",
	"LeftLowerArm",
	"LeftHand"
}

local function wanted(): boolean
	if Viewmodel.current ~= nil and Viewmodel.current ~= v then
		return false
	end

	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not character or not humanoid or humanoid.Health <= 0 or humanoid.Sit then
		return false
	end

	if LocalPlayer.Team == nil and LocalPlayer:GetAttribute("PickingTeam") == true then
		return false
	end

	local currentCamera = workspace.CurrentCamera

	if
		currentCamera and currentCamera.CameraType == Enum.CameraType.Scriptable
		or (humanoid.RigType ~= Enum.HumanoidRigType.R15 or character:FindFirstChildOfClass("Tool"))
	then
		return false
	end

	for _, childName in v2 do
		if not character:FindFirstChild(childName) then
			return false
		end
	end

	return true
end

local cframe = CFrame.new(0, 0.45, 0.25)

local function smooth(value: number) -- 5 equivalent calls inferred from this helper
	local v3 = math.clamp(value, 0, 1)
	return v3 * v3 * (3 - v3 * 2)
end

local function easeOut(value: number) -- 2 equivalent calls inferred from this helper
	local v3 = math.clamp(value, 0, 1)
	return 1 - (1 - v3) * (1 - v3)
end

local v3 = {}
local v4 = { right = Vector3.new(0.6, -1, 0.3), left = Vector3.new(-0.4, -1, 0.3) }

for k, v5 in {
	left = {
		wind = 0.075,
		strike = 0.035,
		hold = 0.07,
		recover = 0.16,
		chamber = Vector3.new(-0.95, -1.3, -1.2),
		contact = Vector3.new(-0.32, -0.5, -3.1),
		pole = Vector3.new(-1, -0.3, 0.4),
		yaw = 2,
		roll = 1,
		pitch = 0.6,
		kickTime = 0.09,
		dolly = 0.25,
		whoosh = 0.32
	},
	right = {
		wind = 0.1,
		strike = 0.045,
		hold = 0.15,
		recover = 0.21,
		chamber = Vector3.new(1, -1.35, -1.15),
		contact = Vector3.new(-0.08, -0.3, -2.9),
		pole = Vector3.new(1, -0.2, 0.4),
		yaw = 3.5,
		roll = 2.5,
		pitch = 1,
		kickTime = 0.12,
		dolly = 0.4,
		whoosh = 0.45
	}
} do
	v3[k] = {
		name = k,
		side = k == "right" and 1 or -1,
		p = v5,
		t0 = -1e999,
		landed = true,
		hit = false,
		holdLen = 0,
		dolly = 0
	}
end

local function contactAt(p) -- 5 equivalent calls inferred from this helper
	return p.p.wind + p.p.strike
end

local function endAt(data) -- 2 equivalent calls inferred from this helper
	if data.hit then
		return contactAt(data) + data.holdLen + data.p.recover -- inferred equivalent call
	end

	return contactAt(data) + 0.03 + 0.05 + data.p.recover * 0.85 -- inferred equivalent call
end

local function free(data, now: number) -- 1 equivalent call inferred from this helper
	local landed = data.landed

	if landed then
		local v5 = now - data.t0
		return endAt(data) - data.p.recover * 0.5 <= v5 -- inferred equivalent call
	end

	return landed
end

local function fistPose(data, p: number)
	local p2 = data.p

	if p < 0 or endAt(data) <= p then -- inferred equivalent call
		return p2.contact, 0, 0, 0, 0
	end

	if p < p2.wind then
		local v5 = smooth(p / p2.wind) -- inferred equivalent call
		return p2.chamber, v5, v5 * -0.3, 0, 0
	else
		local v5 = contactAt(data) -- inferred equivalent call

		if p < v5 then
			local v6 = easeOut((p - p2.wind) / p2.strike) -- inferred equivalent call
			return p2.chamber:Lerp(p2.contact, v6), 1, v6 * 1.3 + -0.3, v6, v6
		else
			local v6 = p - v5
			local vector3 = newVector3(data.side, 1, 1)

			if data.hit then
				if v6 < data.holdLen then
					return p2.contact + Vector3.new(0.04, -0.1, 0.06) * vector3 * (v6 / p2.hold), 1, 1, 1, 1
				end

				local v7 = math.min((v6 - data.holdLen) / p2.recover, 1)
				local v8 = p2.contact + Vector3.new(0.04, -0.1, 0.06) * vector3 * math.min(data.holdLen / p2.hold, 1)
				local v9 = 1 - smooth(v7) -- inferred equivalent call
				return
					v8 + Vector3.new(0.25, -0.4, 0.25) * vector3 * math.sin(3.141592653589793 * v7),
					v9,
					v9,
					v9,
					1 - smooth(v7 / 0.6) -- inferred equivalent call
			else
				local v7 = p2.contact + (p2.contact - p2.chamber).Unit * 0.35

				if v6 < 0.03 then
					return p2.contact:Lerp(v7, easeOut(v6 / 0.03)), 1, 1, 1, 1 -- inferred equivalent call
				else
					local v8 = v6 - 0.03
					local v9 = v7 + Vector3.new(0.5, -1, 0.5) * vector3

					if v8 < 0.05 then
						local v10 = smooth(v8 / 0.05) -- inferred equivalent call
						return v7:Lerp(v9, v10), 1, 1 - v10 * 0.5, 1, 1 - v10
					else
						local v10 = 1 - smooth((v8 - 0.05) / (p2.recover * 0.85)) -- inferred equivalent call
						return v9, v10, v10 * 0.5, v10, 0
					end
				end
			end
		end
	end
end

local v5 = "left"
local v6 = -1e999
local v7 = false
local now = nil
local total = 0
local v8 = 0

local v9 = {
	t0 = -1e999,
	yaw = 0,
	roll = 0,
	pitch = 0,
	time = 0.1
}
local cframe2 = nil

local flag = false
local function kickStep()
	if not v.active then
		return
	end

	local v10 = (os.clock() - v9.t0) / v9.time
	local v11 = not (v10 >= 0 and v10 < 1) and 0 or (1 - v10) * (1 - v10)

	if v11 == 0 and v8 == 0 then
		return
	end

	local v12 = CFrame.new(0, 0, -v8) * CFrame.Angles(
		math.rad(v9.pitch * v11),
		math.rad(v9.yaw * v11),
		(math.rad(v9.roll * v11))
	)
	cframe2 = v12
	local currentCamera = workspace.CurrentCamera

	if VR.on() then
		cframe2 = nil
	else
		currentCamera.CFrame *= v12
	end
end
local function kickUndo()
	if cframe2 then
		workspace.CurrentCamera.CFrame *= cframe2:Inverse()
		cframe2 = nil
	end

	if not v.active then
		flag = false
		RunService:UnbindFromRenderStep("HandsKickUndo")
		RunService:UnbindFromRenderStep("HandsKick")
	end
end
local function bindKick() -- 1 equivalent call inferred from this helper
	if flag then
		return
	end

	flag = true
	RunService:BindToRenderStep("HandsKickUndo", Enum.RenderPriority.Camera.Value - 3, kickUndo)
	RunService:BindToRenderStep("HandsKick", Enum.RenderPriority.Camera.Value + 3, kickStep)
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local function aimRay()
	local currentCamera = workspace.CurrentCamera
	local excludeInstances = { currentCamera }

	if LocalPlayer.Character then
		table.insert(excludeInstances, LocalPlayer.Character)
	end

	for _, childName in { "VoxelChips", "VoxelLoose", "VoxelTracers", "VoxelGrenades" } do
		local child = workspace:FindFirstChild(childName)

		if child then
			table.insert(excludeInstances, child)
		end
	end

	raycastParams.ExcludeInstances = excludeInstances
	local aimPoint = TouchControls.aimPoint()
	return VR.ray(currentCamera, aimPoint.X, aimPoint.Y), raycastParams
end

local function land(state)
	local v10, v11 = aimRay()
	punch:FireServer(v10.Direction)
	local raycastResult = workspace:Raycast(v10.Origin, v10.Direction * 8, v11)
	local p = state.p

	if raycastResult then
		state.hit = true
		local instance = raycastResult.Instance
		local botRigs = workspace:FindFirstChild("BotRigs")
		local model = instance:FindFirstAncestorWhichIsA("Model")
		local v12 = botRigs ~= nil and instance:IsDescendantOf(botRigs)

		if not v12 then
			if model == nil then
				v12 = false
			else
				v12 = model:FindFirstChildOfClass("Humanoid") ~= nil
			end
		end

		VoxelSound.punchHit(raycastResult.Position, v12, state.name == "right")
		local v13 = v12 and 1 or 1.2
		local now2 = os.clock()
		local kickTime = p.kickTime
		v9.t0 = now2
		v9.time = kickTime
		local yaw = p.yaw * v13 * state.side
		local roll = p.roll * v13 * state.side
		v9.yaw = yaw
		v9.roll = roll
		v9.pitch = -p.pitch * (v12 and 1 or 1.6)
		v:bump(v12 and 0.1 or 0.22)
	else
		state.hit = false
		local now2 = os.clock()
		local time = p.kickTime * 0.8
		v9.t0 = now2
		v9.time = time
		local yaw = p.yaw * 0.25 * state.side
		local roll = p.roll * 0.25 * state.side
		v9.yaw = yaw
		v9.roll = roll
		v9.pitch = 0
	end
end

local function leanFor(p) -- 1 equivalent call inferred from this helper
	local v10, v11 = aimRay()
	local raycastResult = workspace:Raycast(v10.Origin, v10.Direction * 3, v11)

	if raycastResult then
		return p.dolly * math.clamp((raycastResult.Distance - 1) / 1.5, 0, 1)
	end

	return p.dolly
end

local function punch2(): boolean
	if not (v.active and v:ready()) then
		return false
	end

	local now2 = os.clock()

	if now2 - v6 < 0.24 then
		return false
	end

	if now2 - v6 > 0.9 then
		v5 = "left"
	end

	local v10 = v3[v5]

	if not free(v10, now2) then -- inferred equivalent call
		return false
	end

	local v11 = v3[v5 == "right" and "left" or "right"]
	local holdLen = now2 - v11.t0 - contactAt(v11) -- inferred equivalent call

	if v11.landed and v11.hit and holdLen >= 0 and holdLen < v11.holdLen then
		v11.holdLen = holdLen
	end

	v5 = v11.name
	v6 = now2
	local hold = v10.p.hold
	v10.t0 = now2
	v10.landed = false
	v10.hit = false
	v10.holdLen = hold
	v10.dolly = leanFor(v10.p) -- inferred equivalent call
	VoxelSound.jab(workspace.CurrentCamera.CFrame.Position, v10.p.whoosh)
	return true
end

local function resetFists() -- 2 equivalent calls inferred from this helper
	v7 = false
	now = nil
	total = 0
	v8 = 0
	v5 = "left"

	for _, v10 in v3 do
		v10.t0 = -1e999
		v10.landed = true
		v10.hit = false
	end

	v.rightReach = 0
	v.leftReach = 0
	v.rightPole = nil
	v.leftPole = nil
	v.pose = CFrame.identity
	v.firing = false
	v9.t0 = -1e999
end

local function fistStep(p: number)
	if not v.active then
		return
	end

	local now2 = os.clock()

	if now and (now2 - now > 0.2 or punch2()) then
		now = nil
	end

	if v7 and now2 - v6 >= 0.4 then
		punch2()
	end

	local total2 = 0
	local maxValue = 0

	for k, v10 in v3 do
		local v11 = now2 - v10.t0

		if not v10.landed and contactAt(v10) <= v11 then -- inferred equivalent call
			v10.landed = true
			land(v10)
		end

		local v12, v13, v14, v15, v16 = fistPose(v10, v11)
		local v17

		if v15 > 0 then
			v17 = v4[k]:Lerp(v10.p.pole, v15)
		end

		if k == "right" then
			v.rightReachTo = v12
			v.rightReach = v13
			v.rightPole = v17
		else
			v.leftReachTo = v12
			v.leftReach = v13
			v.leftPole = v17
		end

		total2 += v14 * v10.side
		maxValue = math.max(maxValue, v10.dolly * v16)
	end

	v8 = maxValue
	local v10 = now2 - v6 < 1.6 and 1 or 0
	total += (v10 - total) * (1 - math.exp(-(total < v10 and 18 or 6) * p))
	v.pose = cframe:Lerp(CFrame.identity, 1 - total) * CFrame.Angles(
		math.min(math.abs(total2), 1) * -0.04,
		total2 * 0.2,
		total2 * 0.07
	)
	v.firing = v7 or now2 - v6 < 0.4
end
local renderSteppedConnection = nil

TouchControls.registerHands(hands, {
	label = "PUNCH",
	startFire = function()
		if v.active then
			v7 = true

			if not punch2() then
				now = os.clock()
			end
		end
	end,
	stopFire = function()
		v7 = false
	end
}, function()
	return v.active
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or MenuLock.held and input.KeyCode == Enum.KeyCode.ButtonR2 then
		return
	end

	if
		(input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.ButtonR2)
		and v.active
	then
		v7 = true

		if not punch2() then
			now = os.clock()
		end
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.ButtonR2 then
		v7 = false
	end
end)

RunService.Heartbeat:Connect(function()
	local v10 = wanted()

	if v10 and not v.active then
		resetFists() -- inferred equivalent call
		debug.profilebegin("HV.start")
		v:start()
		debug.profileend()
		bindKick() -- inferred equivalent call

		if not renderSteppedConnection then
			renderSteppedConnection = RunService.RenderStepped:Connect(fistStep)
		end
	elseif not v10 and v.active then
		v:stop()
		resetFists() -- inferred equivalent call
	end

	if renderSteppedConnection and not v.active then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end
end)