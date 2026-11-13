local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Style = require(script.Parent:WaitForChild("Style"))
local Detail = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("Detail"))
local SmokeCloud = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("SmokeCloud"))

local NameTags = {}

function NameTags.newTag(parent)
	local nameTag = Instance.new("BillboardGui")
	nameTag.Name = "NameTag"
	nameTag.Size = UDim2.fromOffset(200, 44)
	nameTag.StudsOffsetWorldSpace = Vector3.new(0, 2.2, 0)
	nameTag.LightInfluence = 0
	nameTag.MaxDistance = 350
	nameTag.ResetOnSpawn = false
	nameTag.Enabled = false
	nameTag.Parent = parent
	local label = Style.label(nameTag, "Name", "", 16, Style.FONT, 0)
	label.AutoLocalize = false
	label.AutomaticSize = Enum.AutomaticSize.None
	label.AnchorPoint = Vector2.new(0.5, 1)
	label.Position = UDim2.fromScale(0.5, 1)
	label.Size = UDim2.new(1, 0, 0, 22)
	Style.stroke(label, 2, 0)
	local frame = Style.frame(
		nameTag,
		"Chevron",
		UDim2.fromOffset(18, 12),
		UDim2.new(0.5, 0, 0, 4),
		Vector2.new(0.5, 0)
	)
	local fills = {}

	for _, v in { -1, 1 } do
		local fill = Style.fill(
			frame,
			"Bar",
			Style.WHITE,
			UDim2.fromOffset(11, 4),
			UDim2.new(0.5, v * 4, 0.5, 0),
			Vector2.new(0.5, 0.5)
		)
		fill.Rotation = v * -35
		Style.stroke(fill, 1.5, 0, nil, true)
		table.insert(fills, fill)
	end

	return { gui = nameTag, label = label, chevron = frame, bars = fills }
end

function NameTags.mount(data)
	local player = data.player
	local net = data.Net
	local nameTags = Instance.new("Folder")
	nameTags.Name = "NameTags"
	nameTags.Parent = data.playerGui
	local teamOutlines = Instance.new("Folder")
	teamOutlines.Name = "TeamOutlines"
	teamOutlines.Parent = workspace

	local v = {}
	local v2 = {}
	local v3 = {}

	local function drop(p) -- 4 equivalent calls inferred from this helper
		local v4 = v2[p]

		if v4 then
			v2[p] = nil
			v4.gui.Adornee = nil
			v4.gui.Enabled = false
			table.insert(v, v4)
		end
	end

	local function attach(instance, player2)
		if player2 == player then
			return
		end

		local humanoid = instance:WaitForChild("Humanoid", 10)
		local head = instance:WaitForChild("Head", 10)

		if not humanoid or not head or player2.Character ~= instance then
			return
		end

		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		drop(player2) -- inferred equivalent call
		local v4 = table.remove(v) or NameTags.newTag(nameTags)
		v4.label.Text = player2.DisplayName
		v4.gui.Adornee = head
		v4.gui.Enabled = false
		v2[player2] = v4
		humanoid.Died:Connect(function()
			if v2[player2] == v4 and player2.Character == instance then
				drop(player2) -- inferred equivalent call
			end
		end)
	end

	data.eachCharacter(attach)
	data.eachPlayer(function(p)
		p.CharacterRemoving:Connect(function()
			drop(p) -- inferred equivalent call
		end)
	end)
	Players.PlayerRemoving:Connect(function(player2)
		drop(player2) -- inferred equivalent call
		v3[player2] = nil
	end)

	data.Net.remote("HitConfirm").OnClientEvent:Connect(function(vector3: Vector3)
		local team = net.teamOf(player)
		local v4 = 6
		local v5 = nil

		for _, v6 in Players:GetPlayers() do
			local v7

			if v6 == player then
				v7 = false
			else
				v7 = v6.Character and v6.Character:FindFirstChild("Head")
			end

			local team2 = net.teamOf(v6)

			if not (v7 and team2 and team2 ~= team) then
				continue
			end

			local magnitude = (v7.Position - vector3).Magnitude

			if not (magnitude < v4) then
				continue
			end

			v5 = v6
			v4 = magnitude
		end

		if v5 then
			v3[v5] = os.clock()
		end
	end)

	local v4 = {}

	for i = 1, 24 do
		local highlight = Instance.new("Highlight")
		highlight.Name = "Outline" .. i
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.FillTransparency = 1
		highlight.OutlineTransparency = 0.1
		highlight.Enabled = false
		highlight.Parent = teamOutlines
		v4[i] = highlight
	end

	local v5 = {}
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = true
	local filterDescendantsInstances = {}

	local function visible(position: Vector3, head, character)
		if SmokeCloud.blocks(position, head.Position) then
			return false
		end

		table.clear(filterDescendantsInstances)

		if player.Character then
			table.insert(filterDescendantsInstances, player.Character)
		end

		table.insert(filterDescendantsInstances, workspace.CurrentCamera)
		raycastParams.FilterDescendantsInstances = filterDescendantsInstances
		local raycastResult = workspace:Raycast(position, head.Position - position, raycastParams)
		return raycastResult == nil or raycastResult.Instance:IsDescendantOf(character)
	end

	task.spawn(function()
		while true do
			table.clear(v5)
			local team = net.teamOf(player)
			local currentCamera = workspace.CurrentCamera
			local now = os.clock()
			local low = Detail.low
			local maxDistance = Detail.maxDistance(350)
			local v6 = not low and 150 or 150 * Detail.reach()
			local v7 = low and 6 or 24

			if currentCamera then
				local position = currentCamera.CFrame.Position
				local viewportSize = currentCamera.ViewportSize
				local halfViewportSize = viewportSize / 2
				local v8 = viewportSize.Y * 0.12

				for _, v9 in Players:GetPlayers() do
					if v9 == player then
						continue
					end

					local v10 = v2[v9]
					local team2 = net.teamOf(v9)
					local character = v9.Character
					local head = character and character:FindFirstChild("Head")
					local humanoid = character and character:FindFirstChildOfClass("Humanoid")
					local enabled

					if
						team2
						and head
						and humanoid
						and humanoid.Health > 0
						and team
						and v9:GetAttribute("Invisible") ~= true
					then
						local magnitude = (head.Position - position).Magnitude
						local teamColor = Style.teamColor(team2)

						if team2 == team then
							enabled = magnitude < maxDistance

							if magnitude < v6 then
								table.insert(v5, {
									character = character,
									color = teamColor,
									priority = magnitude + 1000
								})
							end
						else
							local v11

							if v3[v9] == nil then
								v11 = false
							else
								v11 = now - v3[v9] < 3
							end

							local v12

							if magnitude < 250 then
								local worldToViewportPoint, v13 = currentCamera:WorldToViewportPoint(head.Position)
								v12 = v13
									and (Vector2.new(worldToViewportPoint.X, worldToViewportPoint.Y) - halfViewportSize).Magnitude < v8
							else
								v12 = false
							end

							local v13

							if v12 or magnitude < 60 then
								v13 = visible(position, head, character)
							else
								v13 = false
							end

							enabled = v11 or v12 and v13

							if v11 or v13 and magnitude < 60 then
								table.insert(v5, {
									character = character,
									color = teamColor,
									priority = magnitude
								})
							end
						end

						if v10 then
							if v10.gui.MaxDistance ~= maxDistance then
								v10.gui.MaxDistance = maxDistance
							end

							v10.label.TextColor3 = Style.teamText(team2)
							v10.gui.AlwaysOnTop = team2 == team
							v10.chevron.Visible = team2 == team

							for _, bar in v10.bars do
								bar.BackgroundColor3 = teamColor
							end
						end
					else
						enabled = false
					end

					if v10 and v10.gui.Enabled ~= enabled then
						v10.gui.Enabled = enabled
					end
				end

				table.sort(v5, function(a, b): boolean
					return a.priority < b.priority
				end)
			end

			for k, v8 in v4 do
				local v9

				if k <= v7 then
					v9 = v5[k]
				end

				if v9 then
					if v8.Adornee ~= v9.character then
						v8.Adornee = v9.character
					end

					if v8.OutlineColor ~= v9.color then
						v8.OutlineColor = v9.color
					end

					v8.Enabled = true
				elseif v8.Enabled then
					v8.Enabled = false
					v8.Adornee = nil
				end
			end

			task.wait(0.125)
		end
	end)
end

return NameTags