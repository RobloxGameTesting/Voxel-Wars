local Crouch = {}
Crouch.DEPTH = 0.78
Crouch.WALK = 8
Crouch.RATE = 14
Crouch.LEAN = 0.34

local function motor(instance, childName: string, childName2: string) -- 1 equivalent call inferred from this helper
	local child = instance:FindFirstChild(childName)
	local instance2 = child and child:FindFirstChild(childName2)
	assert(
		instance2 and (instance2:IsA("Motor6D") or instance2:IsA("AnimationConstraint")),
		"[Crouch] " .. instance.Name .. " has no " .. childName .. "." .. childName2 .. " joint (R15 needed)"
	)
	return instance2
end

local v = {
	{ "LeftUpperLeg", "LeftHip" },
	{ "RightUpperLeg", "RightHip" },
	{ "LeftLowerLeg", "LeftKnee" },
	{ "RightLowerLeg", "RightKnee" },
	{ "LeftFoot", "LeftAnkle" },
	{ "RightFoot", "RightAnkle" },
	{ "UpperTorso", "Waist" }
}

local v2 = {
	{ "LeftUpperLeg", "LeftHipRigAttachment" },
	{ "LeftUpperLeg", "LeftKneeRigAttachment" },
	{ "LeftLowerLeg", "LeftKneeRigAttachment" },
	{ "LeftLowerLeg", "LeftAnkleRigAttachment" }
}

function Crouch.ready(instance): boolean
	for _, v3 in v do
		local child = instance:FindFirstChild(v3[1])
		local instance2 = child and child:FindFirstChild(v3[2])

		if not (instance2 and (instance2:IsA("Motor6D") or instance2:IsA("AnimationConstraint"))) then
			return false
		end
	end

	for _, v3 in v2 do
		local child = instance:FindFirstChild(v3[1])
		local attachment = child and child:FindFirstChild(v3[2])

		if not (attachment and attachment:IsA("Attachment")) then
			return false
		end
	end

	return true
end

local function span(instance, childName: string, childName2: string, childName3: string)
	local child = instance:FindFirstChild(childName)
	local attachment = child and child:FindFirstChild(childName2)
	local attachment2 = child and child:FindFirstChild(childName3)
	assert(
		attachment and attachment2 and attachment:IsA("Attachment") and attachment2:IsA("Attachment"),
		"[Crouch] " .. instance.Name .. "." .. childName .. " lacks " .. childName2 .. " / " .. childName3
	)
	return (attachment.Position - attachment2.Position).Magnitude
end

function Crouch.rig(instance)
	local hips = {}
	local knees = {}
	local ankles = {}

	for _, v3 in { "Left", "Right" } do
		table.insert(hips, motor(instance, v3 .. "UpperLeg", v3 .. "Hip"))
		table.insert(knees, motor(instance, v3 .. "LowerLeg", v3 .. "Knee"))
		table.insert(ankles, motor(instance, v3 .. "Foot", v3 .. "Ankle"))
	end

	local l1 = span(instance, "LeftUpperLeg", "LeftHipRigAttachment", "LeftKneeRigAttachment")
	local l2 = span(instance, "LeftLowerLeg", "LeftKneeRigAttachment", "LeftAnkleRigAttachment")
	local v3 = l1 > 0.1 and l2 > 0.1
	assert(v3, "[Crouch] leg lengths look wrong on " .. instance.Name)
	return {
		hips = hips,
		knees = knees,
		ankles = ankles,
		waist = motor(instance, "UpperTorso", "Waist"), -- inferred equivalent call
		l1 = l1,
		l2 = l2,
		drop = Crouch.DEPTH * (l1 + l2),
		base = {},
		last = {},
		posed = false
	}
end

function Crouch.current(data, ancestor)
	for _, v3 in { data.hips, data.knees, data.ankles } do
		for _, v4 in v3 do
			if not v4:IsDescendantOf(ancestor) then
				return false
			end
		end
	end

	return data.waist:IsDescendantOf(ancestor)
end

function Crouch.depth(p, value: number)
	local v3 = math.clamp(value, 0, 1)
	return p.drop * v3 * v3 * (3 - v3 * 2)
end

local function put(state, p, cframe: CFrame) -- 6 equivalent calls inferred from this helper
	local v3 = p.Transform

	if state.last[p] == v3 then
		v3 = state.base[p] or CFrame.identity
	end

	state.base[p] = v3
	local transform = v3 * cframe
	p.Transform = transform
	state.last[p] = transform
end

function Crouch:pose(value: number)
	if value <= 0 then
		if self.posed then
			for _, v3 in { self.hips, self.knees, self.ankles } do
				for _, v4 in v3 do
					put(self, v4, CFrame.identity) -- inferred equivalent call
				end
			end

			put(self, self.waist, CFrame.identity) -- inferred equivalent call
			self.posed = false
		end
	else
		self.posed = true
		local l1 = self.l1
		local l2 = self.l2

		local v3 = math.max(l1 + l2 - Crouch.depth(self, value), math.abs(l1 - l2) + 0.05)
		local v4 = math.acos((math.clamp((l1 * l1 + v3 * v3 - l2 * l2) / (l1 * 2 * v3), -1, 1)))
		local v5 = math.asin((math.clamp(l1 * math.sin(v4) / l2, -1, 1)))
		local cframe = CFrame.Angles(v4, 0, 0)
		local cframe2 = CFrame.Angles(-(v4 + v5), 0, 0)
		local cframe3 = CFrame.Angles(v5, 0, 0)

		for i = 1, 2 do
			put(self, self.hips[i], cframe) -- inferred equivalent call
			put(self, self.knees[i], cframe2) -- inferred equivalent call
			put(self, self.ankles[i], cframe3) -- inferred equivalent call
		end

		local v6 = math.clamp(value, 0, 1)
		put(self, self.waist, CFrame.Angles(-Crouch.LEAN * v6 * v6 * (3 - v6 * 2), 0, 0)) -- inferred equivalent call
	end
end

function Crouch.ease(p: number, flag: boolean, p2: number)
	local v3 = flag and 1 or 0
	local v4 = p + (v3 - p) * (1 - math.exp(-Crouch.RATE * p2))
	return if math.abs(v3 - v4) < 0.001 then v3 else v4
end

return Crouch