local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local meleeSwing = ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("Remotes"):WaitForChild("MeleeSwing")
local LocalPlayer = Players.LocalPlayer

local v = {
	{ 0, 0, 0 },
	{ 0.05, 1.6, 0.05 },
	{ 0.12, 1.55, 0.1 },
	{ 0.34, 0, 0 }
}

local v2 = {
	{ 0, 0, 0 },
	{ 0.06, 0.7, 1.9 },
	{ 0.2, 0.7, 1.9 },
	{ 0.4, 0, 0 }
}

local v3 = {
	{ 0, 0, 0 },
	{ 0.08, 1.1, 0.7 },
	{ 0.15, -0.9, 0 },
	{ 0.26, -0.8, 0.05 },
	{ 0.5, 0, 0 }
}

local v4 = {
	{ 0, 0.5, 0.6 },
	{ 0.08, 0.25, 0.25 },
	{ 0.3, 1, 1 },
	{ 0.4, 1.25, 0.7 },
	{ 0.62, 0, 0 }
}

local v5 = {
	{ 0, 0.7, 0.4 },
	{ 0.08, 0.45, 0.2 },
	{ 0.3, 1.1, 0.8 },
	{ 0.4, 1, 0.5 },
	{ 0.62, 0, 0 }
}

local function sample(list, p: number)
	if p <= list[1][1] then
		return list[1][2], list[1][3]
	end

	for i = 1, #list - 1 do
		local item = list[i]
		local item2 = list[i + 1]

		if p <= item2[1] then
			local v6 = (p - item[1]) / (item2[1] - item[1])
			local v7 = v6 * v6 * (3 - v6 * 2)
			return item[2] + (item2[2] - item[2]) * v7, item[3] + (item2[3] - item[3]) * v7
		end
	end

	local item = list[#list]
	return item[2], item[3]
end

local v6 = {}

local steppedConnection = nil
local step

local function joint(instance, childName: string, childName2: string) -- 2 equivalent calls inferred from this helper
	local child = instance:FindFirstChild(childName)
	local instance2 = child and child:FindFirstChild(childName2)

	if instance2 and (instance2:IsA("Motor6D") or instance2:IsA("AnimationConstraint")) then
		return instance2
	end

	return nil
end

local function arm(character, p: string) -- 2 equivalent calls inferred from this helper
	local shoulder = joint(character, p .. "UpperArm", p .. "Shoulder") -- inferred equivalent call
	local elbow = joint(character, p .. "LowerArm", p .. "Elbow") -- inferred equivalent call

	if shoulder and elbow then
		return { shoulder = shoulder, elbow = elbow }
	end

	return nil
end

local function put(p, p2, cframe: CFrame) -- 4 equivalent calls inferred from this helper
	local v7 = p2.Transform

	if p.last[p2] == v7 then
		v7 = p.base[p2] or CFrame.identity
	end

	p.base[p2] = v7
	local transform = v7 * cframe
	p2.Transform = transform
	p.last[p2] = transform
end

local function poseArm(p, p2, p3, p4: number)
	local v7, v8 = sample(p3, p4)
	put(p, p2.shoulder, CFrame.Angles(v7, 0, 0)) -- inferred equivalent call
	put(p, p2.elbow, CFrame.Angles(v8, 0, 0)) -- inferred equivalent call
end

meleeSwing.OnClientEvent:Connect(function(player, kind: string, side: number)
	if player == LocalPlayer then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid or humanoid.Health <= 0 or humanoid.RigType ~= Enum.HumanoidRigType.R15 then
		return
	end

	local right = arm(character, "Right") -- inferred equivalent call
	local left = arm(character, "Left") -- inferred equivalent call

	if not (right and left) then
		return
	end

	local v7 = v6[character]
	v6[character] = {
		character = character,
		kind = kind,
		side = side,
		t0 = os.clock(),
		right = right,
		left = left,
		base = not v7 and {} or v7.base,
		last = not v7 and {} or v7.last
	}

	if not steppedConnection then
		steppedConnection = RunService.Stepped:Connect(step)
	end
end)

step = function()
	local now = os.clock()

	for k, v7 in v6 do
		local v8 = now - v7.t0

		if v8 > 0.65 or not k.Parent then
			if k.Parent then
				for _, v9 in { v7.right, v7.left } do
					put(v7, v9.shoulder, CFrame.identity) -- inferred equivalent call
					put(v7, v9.elbow, CFrame.identity) -- inferred equivalent call
				end
			end

			v6[k] = nil
		elseif v7.kind == "hammer" then
			poseArm(v7, v7.right, v3, v8)
		elseif v7.kind == "shovel" then
			poseArm(v7, v7.right, v4, v8)
			poseArm(v7, v7.left, v5, v8)
		else
			local v9 = if v7.side < 0 then v7.left else v7.right
			local v10

			if v7.side < 0 then
				v10 = v7.right
			else
				v10 = v7.left
			end

			poseArm(v7, v9, v, v8)
			poseArm(v7, v10, v2, v8)
		end
	end

	if next(v6) == nil and steppedConnection then
		steppedConnection:Disconnect()
		steppedConnection = nil
	end
end