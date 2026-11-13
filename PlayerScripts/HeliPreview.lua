local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Vehicles = ReplicatedStorage:WaitForChild("Vehicles")
local HeliModel = require(Vehicles:WaitForChild("HeliModel"))

local LocalPlayer = Players.LocalPlayer
local heliPreview = Instance.new("Folder")
heliPreview.Name = "HeliPreview"
heliPreview.Parent = workspace

local v = nil
local flag = false
local renderSteppedConnection = nil
local v2 = 0
local v3 = nil

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = true

local function findGround(position: Vector3)
	local characters = { heliPreview }

	for _, v4 in Players:GetPlayers() do
		if v4.Character then
			table.insert(characters, v4.Character)
		end
	end

	raycastParams.FilterDescendantsInstances = characters
	local raycastResult = workspace:Raycast(position + Vector3.new(0, 150, 0), Vector3.new(0, -400, 0), raycastParams)

	if raycastResult then
		return raycastResult.Position
	end

	return position - Vector3.new(0, 3, 0)
end

local function step(p: number)
	local v4 = v
	local heliPreview2 = Vehicles:GetAttribute("HeliPreview")
	local heliPreviewMode = Vehicles:GetAttribute("HeliPreviewMode")

	if not v4 or typeof(heliPreview2) ~= "CFrame" then
		return
	end

	local now = os.clock()
	v2 = math.clamp(v2 + (v2 < (heliPreviewMode == "parked" and 0 or 1) and 0.6 or -0.6) * (math.min)(p, 0.1), 0, 1)
	local v5 = CFrame.new(v3) * heliPreview2.Rotation
	local position = nil

	if heliPreviewMode == "hover" then
		v5 = v5 * CFrame.new(0, math.sin(now * 1.1) * 0.8 + 30, 0) * CFrame.Angles(
			math.rad(math.sin(now * 0.9) * 3),
			math.rad(math.sin(now * 0.4) * 4),
			(math.rad(math.sin(now * 1.3) * 4))
		)
		local character = LocalPlayer.Character
		local head = character and character:FindFirstChild("Head")

		if head and head:IsA("BasePart") then
			position = head.Position
		end
	end

	v4.pose(v5, now, v2, position)
end

local function update()
	local heliPreviewMode = Vehicles:GetAttribute("HeliPreviewMode")
	local heliPreview2 = Vehicles:GetAttribute("HeliPreview")

	if heliPreviewMode == nil or heliPreviewMode == "clear" or typeof(heliPreview2) ~= "CFrame" then
		if renderSteppedConnection then
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		end

		if v then
			v.model.Parent = nil
		end
	elseif v then
		v3 = findGround(heliPreview2.Position)

		v.model.Parent = heliPreview

		if not renderSteppedConnection then
			renderSteppedConnection = RunService.RenderStepped:Connect(step)
		end

		step(0)
	else
		if flag then
			return
		end

		flag = true
		v = HeliModel.build()
		flag = false
		update()
	end
end

Vehicles:GetAttributeChangedSignal("HeliPreview"):Connect(update)
Vehicles:GetAttributeChangedSignal("HeliPreviewMode"):Connect(update)
task.spawn(update)