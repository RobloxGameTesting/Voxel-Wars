--!native
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local Viewmodel = require(Voxel:WaitForChild("Viewmodel"))
local Detail = require(Voxel:WaitForChild("Detail"))
local BotRig = require(script.Parent:WaitForChild("BotView"):WaitForChild("BotRig"))
local aimShare = Voxel:WaitForChild("Remotes"):WaitForChild("AimShare")
local HeldScale = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("HeldScale"))

local LocalPlayer = Players.LocalPlayer

local function pistolSpec(p)
	local position = p.Grip.Position
	return {
		tool = p.Name,
		right = position,
		left = position + Vector3.new(-0.3, -0.2, 0.05),
		pivot = Vector3.new(0.2, 0.6, -0.1),
		up = CFrame.new(0, 0, -1.55),
		pistol = true
	}
end

local v = CFrame.new(0.3, -0.75, -0.95) * CFrame.Angles(-0.95, 0, 0)

local PistolSpecs = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("PistolSpecs"))
local v2 = { Pistol = true, HandCannon = true }
local v3 = { BuildHammer = true }

for k in PistolSpecs.LIST do
	v2[k] = true
end

local Game = ReplicatedStorage:WaitForChild("Game")
local v4 = { Flamethrower = "LMG" }

for childName, v5 in {
	RifleSpecs = "AssaultRifle",
	SMGSpecs = "SMG",
	LMGSpecs = "LMG",
	DMRSpecs = "DMR",
	SniperSpecs = "Sniper"
} do
	local module = require(Game:WaitForChild(childName))

	for k in module.LIST do
		v4[k] = v5
	end
end

local function measure(childName: string)
	local toolTemplates = ReplicatedStorage:FindFirstChild("ToolTemplates")
	local folder = toolTemplates and toolTemplates:FindFirstChild(childName)
	local handle = folder and folder:FindFirstChild("Handle")

	if not (handle and handle:IsA("BasePart")) then
		return nil, nil
	end

	local v5 = 0
	local vector3 = nil

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("Attachment") and descendant.Name == "MuzzleAttachment" and not vector3 then
			vector3 = handle.CFrame:PointToObjectSpace(descendant.WorldPosition)
		elseif descendant:IsA("BasePart") then
			local objectSpace = handle.CFrame:ToObjectSpace(descendant.CFrame)
			local halfSize = descendant.Size / 2

			for _, v6 in {
				Vector3.new(halfSize.X, halfSize.Y, halfSize.Z),
				Vector3.new(-halfSize.X, halfSize.Y, halfSize.Z),
				Vector3.new(halfSize.X, -halfSize.Y, halfSize.Z),
				(Vector3.new(-halfSize.X, -halfSize.Y, halfSize.Z))
			} do
				v5 = math.max(v5, (objectSpace * v6).Z, (objectSpace * -v6).Z)
			end
		end
	end

	return vector3, v5
end

local function familySpec(name: string, p: string)
	local v5 = BotRig.SPECS[p]

	if not v5 then
		return nil
	end

	local clone = table.clone(v5)
	clone.tool = name
	local vector3, v6 = measure(p)
	local vector3_2, v7 = measure(name)

	if vector3 and v6 and vector3_2 and v7 then
		local v8 = (v5.left.Z - v5.right.Z) / (vector3.Z - v5.right.Z)
		local v9 = math.min(v5.right.Z + v8 * (vector3_2.Z - v5.right.Z), v5.right.Z - 0.45)
		clone.left = Vector3.new(v5.left.X, v5.left.Y, v9)

		clone.up = v5.up * CFrame.new(0, 0, v6 - v7)
	end

	return clone
end

local object = setmetatable({}, { __mode = "k" })

local v5 = {}
local function specOf(tool)
	local v6 = object[tool]

	if v6 ~= nil then
		return v6 or nil
	end

	local v7 = false

	if v2[tool.Name] then
		v7 = pistolSpec(tool)
	elseif v3[tool.Name] or not BotRig.SPECS[tool.Name] then
		if v4[tool.Name] then
			v7 = v5[tool.Name]

			if v7 == nil then
				v7 = familySpec(tool.Name, v4[tool.Name]) or false
				v5[tool.Name] = v7
			end
		end
	else
		v7 = BotRig.SPECS[tool.Name]
	end

	local v8 = v7 and BotRig.scaleSpec(v7)

	object[tool] = v8
	return v8 or nil
end

local object2 = setmetatable({}, { __mode = "k" })
local function growTool(folder)
	if object2[folder] then
		return
	end

	object2[folder] = true
	local v6 = HeldScale.of(folder.Name)

	if v6 == 1 then
		return
	end

	local function one(descendant)
		if descendant:GetAttribute("HeldGrown") then
			return
		end

		if descendant:IsA("BasePart") then
			descendant:SetAttribute("HeldGrown", true)
			HeldScale.grow(descendant, v6)
		elseif descendant:IsA("JointInstance") then
			local part0 = descendant.Part0
			local part1 = descendant.Part1

			if part0 and part1 and part0:IsDescendantOf(folder) and part1:IsDescendantOf(folder) then
				descendant:SetAttribute("HeldGrown", true)
				descendant.C0 = HeldScale.offset(descendant.C0, v6)
				descendant.C1 = HeldScale.offset(descendant.C1, v6)
			end
		end
	end

	for _, descendant in folder:GetDescendants() do
		one(descendant)
	end

	folder.DescendantAdded:Connect(one)
	folder.Grip = HeldScale.offset(folder.Grip, v6)
end

local v6 = 1e999
local v7 = -1
local v8 = -1e999
RunService.Heartbeat:Connect(function()
	local character = LocalPlayer.Character

	if not (character and character:FindFirstChildOfClass("Tool")) then
		return
	end

	local now = os.clock()

	if now - v8 < 0.2 then
		return
	end

	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local v9 = math.asin((math.clamp(currentCamera.CFrame.LookVector.Y, -1, 1)))
	local total = 0
	local current = Viewmodel.current

	if current then
		if (current.sprintAlpha or 0) > 0.5 then
			total += 1
		end

		if current.reloadProgress ~= nil then
			total += 2
		end

		if (current.aimAlpha or 0) > 0.5 then
			total += 4
		end
	end

	if math.abs(v9 - v6) < 0.05 and total == v7 and now - v8 < 1 then
		return
	end

	v8 = now
	v6 = v9
	v7 = total
	aimShare:FireServer(v9, total)
end)

local object3 = setmetatable({}, { __mode = "k" })
local object4 = setmetatable({}, { __mode = "k" })

local function stateOf(character)
	local v9 = object3[character]

	if v9 ~= nil then
		return v9 or nil
	end

	local now = os.clock()

	if now < (object4[character] or 0) then
		return nil
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local joint = BotRig.findJoint(character, "LowerTorso", "Root")
	local joint2 = BotRig.findJoint(character, "UpperTorso", "Waist")
	local joint3 = BotRig.findJoint(character, "Head", "Neck")
	local arm = BotRig.makeArm(character, "Right")
	local arm2 = BotRig.makeArm(character, "Left")
	local joint4 = BotRig.findJoint(character, "RightHand", "RightWrist")
	local joint5 = BotRig.findJoint(character, "LeftHand", "LeftWrist")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart") and humanoid and joint and joint2 and joint3 and arm and arm2 and joint4 and joint5) then
		object4[character] = now + 0.5
		return nil
	end

	local v10 = {
		character = character,
		root = humanoidRootPart,
		humanoid = humanoid,
		rootJ = joint,
		waist = joint2,
		neck = joint3,
		arms = { arm, arm2 },
		wrists = { joint4, joint5 },
		pitch = 0,
		sprint = 0,
		reload = 0,
		ads = 0,
		reloadT = 0,
		posed = false,
		grip = nil,
		gripTool = nil,
		lastC1 = nil,
		aimPitch = 0,
		aimFlags = 0
	}

	local function readAim() -- 1 equivalent call inferred from this helper
		local aimPitch = character:GetAttribute("AimPitch")
		local aimFlags = character:GetAttribute("AimFlags")
		v10.aimPitch = type(aimPitch) ~= "number" and 0 or aimPitch
		v10.aimFlags = type(aimFlags) ~= "number" and 0 or aimFlags
	end
	character:GetAttributeChangedSignal("AimPitch"):Connect(readAim)
	character:GetAttributeChangedSignal("AimFlags"):Connect(readAim)
	readAim() -- inferred equivalent call
	object3[character] = v10
	return v10
end

local function approach(p: number, p2: number, p3: number, p4: number)
	return p + (p2 - p) * (1 - math.exp(-p3 * p4))
end

local function release(state) -- 2 equivalent calls inferred from this helper
	if not state.posed then
		return
	end

	state.posed = false
	state.waist.j.Transform = CFrame.identity
	state.neck.j.Transform = CFrame.identity
	local grip = state.grip
	local gripTool = state.gripTool

	if grip and gripTool and grip.Parent then
		grip.C1 = gripTool.Grip
	end

	state.grip = nil
	state.gripTool = nil
	state.lastC1 = nil
end

local function pose(state, tool, data, dt: number)
	local rightHand = state.character:FindFirstChild("RightHand")
	local rightGrip = rightHand and rightHand:FindFirstChild("RightGrip")

	if rightGrip and rightGrip:IsA("Weld") and rightGrip.Part1 == tool:FindFirstChild("Handle") then
		if state.grip ~= rightGrip then
			state.lastC1 = nil
		end

		state.posed = true
		state.grip = rightGrip
		state.gripTool = tool

		local aimPitch = state.aimPitch
		local aimFlags = state.aimFlags
		local pitch = state.pitch
		state.pitch = pitch + (math.clamp(aimPitch, -1.35, 1.35) - pitch) * (1 - math.exp(dt * -12))
		local v9 = data.tool == "RocketLauncher" or data.tool == "AALauncher"
		local sprint = state.sprint
		state.sprint = sprint + ((bit32.btest(aimFlags, 1) and not v9 and 1 or 0) - sprint) * (1 - math.exp(dt * -10))
		local reload = state.reload
		state.reload = reload + ((bit32.btest(aimFlags, 2) and not v9 and 1 or 0) - reload) * (1 - math.exp(dt * -10))
		local ads = state.ads
		state.ads = ads + ((bit32.btest(aimFlags, 4) and 1 or 0) - ads) * (1 - math.exp(dt * -14))
		local pitch2 = state.pitch

		local v10 = (v9 and -0.6 or -0.45 - state.ads * 0.25) * (1 - state.sprint * 0.7)
		local v11 = pitch2 * 0.35 * (1 - state.sprint)
		local cframe = CFrame.fromEulerAnglesYXZ(v11, v10, 0)
		state.waist.j.Transform = cframe
		state.neck.j.Transform = CFrame.fromEulerAnglesYXZ(pitch2 - v11, -v10 * 0.9, 0)

		local transform = state.rootJ.j.Transform
		local cframe2 = state.root.CFrame
		local cframe3 = cframe2 * state.rootJ.c0 * transform * state.rootJ.c1i * state.waist.c0 * cframe * state.waist.c1i
		local inverse = cframe3:Inverse()
		local lookVector = cframe2.LookVector
		local v12 = math.atan2(-lookVector.X, -lookVector.Z)
		local v13 = CFrame.new(cframe3.Position) * CFrame.Angles(0, v12, 0)
		local v14 = math.cos(pitch2)
		local vector3 = Vector3.new(-math.sin(v12) * v14, math.sin(pitch2), -math.cos(v12) * v14)

		local cframe4 = CFrame.lookAlong(v13 * data.pivot, vector3) * data.up

		if not v9 then
			cframe4 *= CFrame.new(0, (1 - state.ads) * -0.08, (1 - state.ads) * 0.08)
		end

		if not v9 then
			local poses = BotRig.POSES
			local v15 = if data.pistol then v else poses.low
			local v16 = if data.pistol then v else poses.sprint
			local lerped = v15:Lerp(v16, state.sprint)
			local v17 = if data.pistol then v else poses.reload
			cframe4 = (v13 * lerped:Lerp(v17, state.reload)):Lerp(cframe4, 1 - math.max(state.sprint, state.reload))
		end

		local cframe5 = inverse * cframe4

		local arm = state.arms[2]
		local v15 = (cframe5 * data.left - arm.shoulder.c0.Position).Magnitude - (arm.upperLen + arm.lowerLen - 0.02)

		if v15 > 0 then
			cframe5 *= CFrame.new(0, 0, (math.min(v15 * 1.3, 0.6)))
		end

		local v16 = cframe5 * data.right
		local v17 = cframe5 * data.left

		if state.reload > 0.01 then
			state.reloadT += dt
			local v18 = 0.5 - math.cos(state.reloadT * 2 * 3.141592653589793 / 1.6) * 0.5
			local v19 = inverse * (v13 * BotRig.POSES.pouch)
			v17 = v17:Lerp((cframe5 * (data.mag or BotRig.POSES.mag)):Lerp(v19, v18), state.reload)
		else
			state.reloadT = 0
		end

		BotRig.solveArm(state.arms[1], v16, BotRig.POSES.rightPole)
		BotRig.solveArm(state.arms[2], v17, BotRig.POSES.leftPole)
		state.wrists[1].j.Transform = CFrame.identity
		state.wrists[2].j.Transform = CFrame.identity

		local arm2 = state.arms[1]
		local wrist = state.wrists[1]
		local v18 = arm2.shoulder.c0 * arm2.shoulder.j.Transform * arm2.shoulder.c1i * arm2.elbow.c0 * arm2.elbow.j.Transform * arm2.elbow.c1i * wrist.c0 * wrist.c1i
		local v19 = cframe5:Inverse() * v18 * rightGrip.C0
		local lastC1 = state.lastC1

		if
			not lastC1
			or (v19.Position - lastC1.Position).Magnitude > 0.004
			or (v19.LookVector - lastC1.LookVector).Magnitude > 0.004
			or (v19.UpVector - lastC1.UpVector).Magnitude > 0.004
		then
			state.lastC1 = v19
			rightGrip.C1 = v19
		end
	else
		release(state) -- inferred equivalent call
	end
end

local object5 = setmetatable({}, { __mode = "k" })
local function trimShadow(folder)
	if object5[folder] or not Detail.low then
		return
	end

	object5[folder] = true

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			part.CastShadow = false
		end
	end
end

local players = Players:GetPlayers()
Players.PlayerAdded:Connect(function(player)
	if not table.find(players, player) then
		table.insert(players, player)
	end
end)
Players.PlayerRemoving:Connect(function(player)
	local index = table.find(players, player)

	if index then
		table.remove(players, index)
	end
end)

RunService.PreSimulation:Connect(function(dt: number)
	for _, player in players do
		if player == LocalPlayer then
			continue
		end

		local character = player.Character

		if not character then
			continue
		end

		local v9 = stateOf(character)

		if not v9 then
			continue
		end

		local position = v9.root.Position

		if not Detail.onScreen(position, 6) then
			continue
		end

		local tool = character:FindFirstChildOfClass("Tool")

		if tool then
			trimShadow(tool)
		end

		local v10 = tool and specOf(tool)

		if v10 and tool then
			growTool(tool)
		end

		local v11

		if tool == nil or v10 == nil or not (v9.humanoid.Health > 0) then
			v11 = false
		else
			v11 = not v9.humanoid.Sit
		end

		if v11 then
			pose(v9, tool, v10, dt)
		else
			release(v9) -- inferred equivalent call
		end
	end
end)