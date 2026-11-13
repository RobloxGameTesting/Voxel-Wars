local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local color = Color3.new(1, 1, 1)

local lobbyGuide = Instance.new("Folder")
lobbyGuide.Name = "LobbyGuide"
lobbyGuide.Parent = workspace

local function arm()
	local chevron = Instance.new("Part")
	chevron.Name = "Chevron"
	chevron.Anchored = true
	chevron.CanCollide = false
	chevron.CanQuery = false
	chevron.CanTouch = false
	chevron.CastShadow = false
	chevron.Material = Enum.Material.Neon
	chevron.Size = Vector3.new(0.34, 0.05, 1.6)
	chevron.Transparency = 1
	chevron.Parent = lobbyGuide
	return chevron
end

local v = {}
local function trailFor(team: string) -- 1 equivalent call inferred from this helper
	local v2 = v[team]

	if not v2 then
		v2 = { arms = {}, shown = 0 }
		v[team] = v2
	end

	return v2
end

local function hideFrom(state, p: number) -- 2 equivalent calls inferred from this helper
	for i = p + 1, state.shown do
		state.arms[i].Transparency = 1
	end

	state.shown = math.min(state.shown, p)
end

local parts = {}
local v2 = {}
local v3 = 0
local function scan()
	table.clear(parts)
	table.clear(v2)

	for _, model in CollectionService:GetTagged("SkyLobby") do
		if not model:IsA("Model") then
			continue
		end

		for _, part in model:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			if part.Name == "TeamRing" then
				table.insert(parts, part)
			end

			local home = part:GetAttribute("Home")

			if part:GetAttribute("Spin") and typeof(home) == "CFrame" then
				table.insert(v2, { part = part, pad = model, home = home })
			end
		end
	end
end

local cframe = CFrame.Angles(0, 0.7330382858376184, 0)
local cframe2 = CFrame.Angles(0, -0.7330382858376184, 0)
local v4 = {}
local v5 = {}

local v6 = os.clock() + 2
RunService.RenderStepped:Connect(function()
	local now = os.clock()

	if LocalPlayer.Team == nil then
		v6 = now + 2
	elseif v6 <= now then
		return
	end

	if v3 <= now and (LocalPlayer.Team == nil or #v2 == 0) then
		v3 = now + 1
		scan()
	end

	local character = LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local v7

	if LocalPlayer.Team == nil then
		v7 = LocalPlayer:GetAttribute("PickingTeam") == true
	else
		v7 = false
	end

	local teamSet = {}
	table.clear(v4)
	table.clear(v5)

	if v7 and humanoidRootPart and humanoid and humanoid.Health > 0 then
		local position = humanoidRootPart.Position

		for _, v8 in parts do
			local team = v8:GetAttribute("Team")
			local radius = v8:GetAttribute("Radius")

			if not (type(team) == "string" and type(radius) == "number" and v8:GetAttribute("Open") == true) then
				continue
			end

			local position2 = v8.Position

			if math.abs(position.Y - position2.Y) > 9 then
				continue
			end

			local vector3 = Vector3.new(position.X, position2.Y + 0.12, position.Z)
			local vector3_2 = Vector3.new(position2.X - vector3.X, 0, position2.Z - vector3.Z)
			local v9 = vector3_2.Magnitude - radius - 0.6

			if v9 < 3.4 then
				continue
			end

			local unit = vector3_2.Unit
			local v10 = -unit
			local v11 = trailFor(team) -- inferred equivalent call
			teamSet[team] = true

			local v12 = 2.4 + now * 4.5 % 2.4
			local count = 0

			while v12 <= v9 and count < 60 do
				count += 1
				local v13 = vector3 + unit * v12
				local v14 = math.clamp((v12 - 2.4) / math.max(v9 - 2.4, 1) * 1.3, 0, 1)
				local lerped = color:Lerp(v8.Color, v14)
				local v15 = math.clamp(math.min((v12 - 2.4) / 3, (v9 - v12) / 3), 0, 1)

				for i = 1, 2 do
					local v16 = (count - 1) * 2 + i
					local chevron = v11.arms[v16]

					if not chevron then
						chevron = Instance.new("Part")
						chevron.Name = "Chevron"
						chevron.Anchored = true
						chevron.CanCollide = false
						chevron.CanQuery = false
						chevron.CanTouch = false
						chevron.CastShadow = false
						chevron.Material = Enum.Material.Neon
						chevron.Size = Vector3.new(0.34, 0.05, 1.6)
						chevron.Transparency = 1
						chevron.Parent = lobbyGuide

						v11.arms[v16] = chevron
					end

					local v17 = if i == 1 then cframe else cframe2
					local lookVector = (v17 * CFrame.new(Vector3.new(0, 0, 0), v10)).LookVector
					local v18 = v13 + lookVector * 0.8
					table.insert(v4, chevron)
					table.insert(v5, CFrame.lookAt(v18, v18 + lookVector))
					chevron.Color = lerped
					chevron.Transparency = 1 - v15 * 0.85
				end

				v12 += 2.4
			end

			hideFrom(v11, count * 2) -- inferred equivalent call
			v11.shown = count * 2
		end
	end

	for k, v8 in v do
		if not teamSet[k] then
			hideFrom(v8, 0) -- inferred equivalent call
		end
	end

	local v8 = workspace:GetServerTimeNow() / 4 % 1 * 2 * 3.141592653589793
	local currentCamera = workspace.CurrentCamera
	local v9 = not currentCamera and Vector3.new(0, 0, 0) or currentCamera.CFrame.Position

	for _, v10 in v2 do
		if v10.part.LocalTransparencyModifier >= 1 then
			continue
		end

		local pivot = v10.pad:GetPivot()

		if not ((pivot.Position - v9).Magnitude < 600) then
			continue
		end

		table.insert(v4, v10.part)
		table.insert(v5, pivot * v10.home * CFrame.Angles(0, v8, 0))
	end

	if #v4 > 0 then
		workspace:BulkMoveTo(v4, v5, Enum.BulkMoveMode.FireCFrameChanged)
	end
end)