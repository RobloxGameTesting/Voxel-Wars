local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SightRay = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("SightRay"))

local function worldInWay(position: Vector3) -- 1 equivalent call inferred from this helper
	local currentCamera = workspace.CurrentCamera
	local voxelWorld = workspace:FindFirstChild("VoxelWorld")

	if currentCamera and voxelWorld then
		local position2 = currentCamera.CFrame.Position
		return SightRay.blocked(voxelWorld, position2, position - position2)
	end

	return false
end

local function newMarker(friendMarkers)
	local friendMarker = Instance.new("BillboardGui")
	friendMarker.Name = "FriendMarker"
	friendMarker.Size = UDim2.fromOffset(14, 10)
	friendMarker.StudsOffset = Vector3.new(0, 3.4, 0)
	friendMarker.AlwaysOnTop = true
	friendMarker.MaxDistance = 1e999
	friendMarker.LightInfluence = 0
	friendMarker.ResetOnSpawn = false
	friendMarker.Enabled = false
	local mark = Instance.new("TextLabel")
	mark.Name = "Mark"
	mark.Size = UDim2.fromScale(1, 1)
	mark.BackgroundTransparency = 1
	mark.Text = "▼"
	mark.TextScaled = true
	mark.TextStrokeTransparency = 0.4
	mark.AutoLocalize = false
	mark.Parent = friendMarker
	friendMarker.Parent = friendMarkers
	return friendMarker
end

return {
	mount = function(p)
		local player = p.player

		local v = {}
		local v2 = {}
		Players.PlayerRemoving:Connect(function(player2)
			v2[player2] = nil
			local v3 = v[player2]

			if v3 then
				v[player2] = nil
				v3:Destroy()
			end
		end)
		local friendMarkers = nil

		while true do
			if not friendMarkers or friendMarkers.Parent ~= p.playerGui then
				if friendMarkers then
					friendMarkers:Destroy()
				end

				friendMarkers = Instance.new("Folder")
				friendMarkers.Name = "FriendMarkers"
				friendMarkers.Parent = p.playerGui

				table.clear(v)
			end

			local team = player.Team
			debug.profilebegin("FM.tick")

			for _, v3 in Players:GetPlayers() do
				if v3 == player then
					continue
				end

				local character = v3.Character
				local head = character and character:FindFirstChild("Head")
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				local v4

				if team == nil or v3.Team ~= team or head == nil or humanoid == nil or not (humanoid.Health > 0) then
					v4 = false
				else
					v4 = v3:GetAttribute("Invisible") ~= true
				end

				if v4 then
					v2[v3] = not worldInWay(head.Position) and 0 or (v2[v3] or 2) + 1 -- inferred equivalent call
					v4 = v2[v3] < 2
				else
					v2[v3] = nil
				end

				local v5 = v[v3]

				if v4 then
					if not v5 then
						v5 = newMarker(friendMarkers)
						v[v3] = v5
					end

					if v5.Adornee ~= head then
						v5.Adornee = head
					end

					local color = team.TeamColor.Color
					local mark = v5:FindFirstChild("Mark")

					if mark.TextColor3 ~= color then
						mark.TextColor3 = color
					end

					if not v5.Enabled then
						v5.Enabled = true
					end
				elseif v5 and v5.Enabled then
					v5.Enabled = false
					v5.Adornee = nil
				end
			end

			debug.profileend()
			task.wait(0.15)
		end
	end
}