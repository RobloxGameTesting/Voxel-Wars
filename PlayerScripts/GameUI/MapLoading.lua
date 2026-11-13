game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Style = require(script.Parent.Style)

local function spawnedIn(player): boolean -- 1 equivalent call inferred from this helper
	if player.Neutral or not player.Team or player:GetAttribute("PickingTeam") == true then
		return false
	end

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	return humanoid ~= nil and humanoid.Health > 0
end

return {
	mount = function(p)
		local player = p.player
		local Game = ReplicatedStorage:WaitForChild("Game")

		local mapLoading = Instance.new("ScreenGui")
		mapLoading.Name = "MapLoading"
		mapLoading.ResetOnSpawn = false
		mapLoading.IgnoreGuiInset = true
		mapLoading.DisplayOrder = 50
		mapLoading.Enabled = false
		local textLabel = Instance.new("TextLabel")
		textLabel.AnchorPoint = Vector2.new(0.5, 1)
		textLabel.Position = UDim2.new(0.5, 0, 1, -120)
		textLabel.Size = UDim2.fromOffset(260, 30)
		textLabel.BackgroundTransparency = 1
		textLabel.TextStrokeColor3 = Style.INK
		textLabel.TextStrokeTransparency = 0.4
		textLabel.FontFace = Style.FONT
		textLabel.TextSize = 20
		textLabel.TextColor3 = Style.WHITE
		textLabel.Text = "LOADING MAP"
		textLabel.Parent = mapLoading
		mapLoading.Parent = player:WaitForChild("PlayerGui")

		local now = nil
		local v = 0
		local v2 = false

		local heartbeatConnection = nil
		local function step()
			local v3 = now

			if v3 then
				local now2 = os.clock()
				local worldMeshing = player:GetAttribute("WorldMeshing") == true

				if worldMeshing then
					v2 = true
				end

				if
					Game:GetAttribute("MapLoading") == nil
					and (spawnedIn(player) or not worldMeshing and (v2 or now2 - v3 > 1.5)) -- inferred equivalent call
					or now2 - v3 > 30
				then
					now = nil
					mapLoading.Enabled = false
				else
					if not mapLoading.Enabled then
						mapLoading.Enabled = true
					end

					local v4 = math.floor(now2 * 2) % 4

					if v4 ~= v then
						v = v4
						textLabel.Text = "LOADING MAP" .. string.rep(".", v4)
					end
				end
			else
				if mapLoading.Enabled then
					mapLoading.Enabled = false
				end

				if heartbeatConnection then
					heartbeatConnection:Disconnect()
					heartbeatConnection = nil
				end
			end
		end
		local function begin() -- 2 equivalent calls inferred from this helper
			if not now then
				now = os.clock()
				v2 = false
			end

			if not heartbeatConnection then
				heartbeatConnection = RunService.Heartbeat:Connect(step)
			end
		end
		Game:GetAttributeChangedSignal("MapLoading"):Connect(function()
			if Game:GetAttribute("MapLoading") ~= nil then
				begin() -- inferred equivalent call
			end
		end)
		Game:GetAttributeChangedSignal("Map"):Connect(begin)

		if Game:GetAttribute("MapLoading") ~= nil then
			begin() -- inferred equivalent call
		end
	end
}