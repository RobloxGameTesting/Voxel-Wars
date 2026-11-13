local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")

local LocalPlayer = Players.LocalPlayer
local live = ReplicatedStorage:WaitForChild("Vehicles"):WaitForChild("Live")
local roster = ReplicatedStorage:WaitForChild("Bots"):WaitForChild("Roster")

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local function driverTeam(child)
	local s1 = child:GetAttribute("S1")

	if typeof(s1) ~= "number" or s1 == 0 or s1 == LocalPlayer.UserId then
		return nil
	end

	if s1 > 0 then
		local playerByUserId = Players:GetPlayerByUserId(s1)

		if playerByUserId and playerByUserId.Team and not playerByUserId.Neutral then
			return playerByUserId.Team.Name
		end

		return nil
	end

	for _, child2 in roster:GetChildren() do
		if child2:GetAttribute("Id") == -s1 then
			local team = child2:GetAttribute("Team")
			return if typeof(team) == "string" then team else nil
		end
	end

	return nil
end

local function drawnModel(name: string)
	for _, childName in { "VehicleHulls", "Helicopters" } do
		local child = workspace:FindFirstChild(childName)
		local model = child and child:FindFirstChild(name)

		if model and model:IsA("Model") then
			return model
		end
	end

	return nil
end

local object = setmetatable({}, { __mode = "k" })
local object2 = setmetatable({}, { __mode = "k" })
local function partsOf(folder)
	local v = object[folder]

	if v then
		return v
	end

	if not object2[folder] then
		object2[folder] = true
		local function dirty()
			object[folder] = nil
		end
		folder.DescendantAdded:Connect(dirty)
		folder.DescendantRemoving:Connect(dirty)
	end

	local parts = {}

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			table.insert(parts, part)
		end
	end

	object[folder] = parts
	return parts
end

local function drawnBounds(p, sound)
	local position = sound.Position
	local v = Vector3.new(1, 1, 1) * 1e999
	local v2 = Vector3.new(-1, -1, -1) * 1e999

	for _, v3 in partsOf(p) do
		if not (v3.Transparency < 1) then
			continue
		end

		local cframe = v3.CFrame
		local position2 = cframe.Position

		if not ((position2 - position).Magnitude < 80) then
			continue
		end

		local v4 = v3.Size * 0.5
		local xVector = cframe.XVector
		local yVector = cframe.YVector
		local zVector = cframe.ZVector
		local vector3 = Vector3.new(
			math.abs(xVector.X) * v4.X + math.abs(yVector.X) * v4.Y + math.abs(zVector.X) * v4.Z,
			math.abs(xVector.Y) * v4.X + math.abs(yVector.Y) * v4.Y + math.abs(zVector.Y) * v4.Z,
			math.abs(xVector.Z) * v4.X + math.abs(yVector.Z) * v4.Y + math.abs(zVector.Z) * v4.Z
		)

		v = v:Min(position2 - vector3)
		v2 = v2:Max(position2 + vector3)
	end

	if v.X > v2.X then
		return nil, 0
	end

	return (v + v2) * 0.5, v2.Y
end

local function put(p, p2: string, p3, p4: string, p5) -- 9 equivalent calls inferred from this helper
	if p.sent[p2] ~= p5 then
		p.sent[p2] = p5
		p3[p4] = p5
	end
end

local function newMarker()
	local vehicleMarker = Instance.new("BillboardGui")
	vehicleMarker.Name = "VehicleMarker"
	vehicleMarker.Size = UDim2.fromOffset(16, 10)
	vehicleMarker.AlwaysOnTop = true
	vehicleMarker.MaxDistance = 1e999
	vehicleMarker.LightInfluence = 0
	vehicleMarker.ResetOnSpawn = false
	vehicleMarker.Enabled = false

	local clip = Instance.new("Frame")
	clip.Name = "Clip"
	clip.AnchorPoint = Vector2.new(0.5, 0)
	clip.Position = UDim2.new(0.5, 0, 0, 2)
	clip.Size = UDim2.fromOffset(16, 8)
	clip.BackgroundTransparency = 1
	clip.ClipsDescendants = true
	clip.Parent = vehicleMarker

	local mark = Instance.new("Frame")
	mark.Name = "Mark"
	mark.AnchorPoint = Vector2.new(0.5, 0.5)
	mark.Position = UDim2.fromScale(0.5, 0)
	mark.Size = UDim2.fromOffset(8.48528137423857, 8.48528137423857)
	mark.Rotation = 45
	mark.BorderSizePixel = 0
	mark.Parent = clip
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.new(0, 0, 0)
	uiStroke.Thickness = 1
	uiStroke.Transparency = 0.3
	uiStroke.Parent = mark
	local vehicleMarkerAt = Instance.new("Attachment")
	vehicleMarkerAt.Name = "VehicleMarkerAt"
	vehicleMarker.Adornee = vehicleMarkerAt
	vehicleMarker.Parent = PlayerGui
	return {
		gui = vehicleMarker,
		mark = mark,
		att = vehicleMarkerAt,
		anchor = nil,
		sent = { enabled = false }
	}
end

local v = {}

local object3 = setmetatable({}, { __mode = "k" })

live.ChildRemoved:Connect(function(child)
	local v2 = v[child]

	if v2 then
		v[child] = nil
		v2.gui:Destroy()
		v2.att:Destroy()
	end
end)

local v2 = {}

while true do
	local name

	if LocalPlayer.Team and not LocalPlayer.Neutral then
		name = LocalPlayer.Team.Name
	end

	local Game = ReplicatedStorage:FindFirstChild("Game")
	local turrets = Game and Game:FindFirstChild("Turrets")
	local childSet = {}

	if turrets and name then
		for _, child in turrets:GetChildren() do
			local pivot = child:GetAttribute("Pivot")
			local health = child:GetAttribute("Health")

			if not (typeof(pivot) == "Vector3" and child:GetAttribute("Team") == name and (typeof(health) ~= "number" or not (health <= 0))) then
				continue
			end

			childSet[child] = true
			local v3 = v2[child]

			if not v3 or v3.gui.Parent == nil then
				if v3 then
					v3.gui:Destroy()
					v3.att:Destroy()
				end

				v3 = newMarker()
				v2[child] = v3
				v3.att.Parent = workspace.Terrain
			end

			assert(v3)
			put(v3, "pos", v3.att, "WorldPosition", pivot) -- inferred equivalent call
			put(v3, "offset", v3.gui, "StudsOffsetWorldSpace", Vector3.new(0, 3.8, 0)) -- inferred equivalent call
			local child2 = Teams:FindFirstChild(name)
			local mark = v3.mark
			local v4

			if child2 then
				v4 = child2.TeamColor.Color
			else
				v4 = Color3.new(1, 1, 1)
			end

			put(v3, "color", mark, "BackgroundColor3", v4) -- inferred equivalent call
			put(v3, "enabled", v3.gui, "Enabled", true) -- inferred equivalent call
		end
	end

	for k, v3 in v2 do
		if childSet[k] then
			continue
		end

		v2[k] = nil
		v3.gui:Destroy()
		v3.att:Destroy()
	end

	for _, child in live:GetChildren() do
		local v3

		if name then
			if child:GetAttribute("Wrecked") == true then
				v3 = false
			else
				v3 = driverTeam(child)
			end
		else
			v3 = name
		end

		local v4

		if v3 == name then
			v4 = drawnModel(child.Name) or nil
		end

		local sound = v4 and v4:FindFirstChild("Sound")
		local v5 = v[child]

		if sound and v4 and v3 then
			if v5 and (v5.anchor ~= sound or v5.gui.Parent == nil) then
				v5.gui:Destroy()
				v5.att:Destroy()
				v5 = nil
			end

			if not v5 then
				v5 = newMarker()
				v[child] = v5
				v5.att.Parent = sound
				v5.anchor = sound
			end

			assert(v5)

			local now = os.clock()
			local v6 = object3[v4]
			local v7, v8

			if v6 and (now - v6.at < 1 or v4:GetAttribute("Culled") == true) then
				v7 = sound.CFrame:PointToWorldSpace(v6.centre)
				v8 = v7.Y + v6.up
			else
				v7, v8 = drawnBounds(v4, sound)

				if v7 then
					object3[v4] = {
						centre = sound.CFrame:PointToObjectSpace(v7),
						up = v8 - v7.Y,
						at = now
					}
				end
			end

			local v9 = v7 or sound.Position
			put(v5, "pos", v5.att, "WorldPosition", v9) -- inferred equivalent call

			if not v7 then
				v8 = sound.Position.Y
			end

			local v10 = v8 - v9.Y + 2.5
			put(v5, "offset", v5.gui, "StudsOffsetWorldSpace", Vector3.new(0, v10, 0)) -- inferred equivalent call
			local child2 = Teams:FindFirstChild(v3)
			local mark = v5.mark
			local v11

			if child2 then
				v11 = child2.TeamColor.Color
			else
				v11 = Color3.new(1, 1, 1)
			end

			put(v5, "color", mark, "BackgroundColor3", v11) -- inferred equivalent call
			put(v5, "enabled", v5.gui, "Enabled", true) -- inferred equivalent call
		elseif v5 and v5.sent.enabled then
			put(v5, "enabled", v5.gui, "Enabled", false) -- inferred equivalent call
		end
	end

	task.wait(0.25)
end