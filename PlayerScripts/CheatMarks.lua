local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local v = {
	move = { Color3.fromRGB(255, 40, 40), Color3.fromRGB(255, 60, 60), Color3.fromRGB(255, 90, 90) },
	aim = { Color3.fromRGB(170, 70, 255), Color3.fromRGB(190, 110, 255), Color3.fromRGB(205, 150, 255) }
}

local v2 = {}

local function drop(p) -- 2 equivalent calls inferred from this helper
	local v3 = v2[p]

	if v3 then
		v3.highlight:Destroy()
		v3.tag:Destroy()
		v2[p] = nil
	end
end

ReplicatedStorage:WaitForChild("Game"):WaitForChild("Remotes"):WaitForChild("CheatFlag").OnClientEvent:Connect(function(player, p: string, p2: string?)
	if not (player and player:IsA("Player")) then
		return
	end

	local character = player.Character
	local head = character and character:FindFirstChild("Head")

	if not (character and head) then
		return
	end

	local v3 = v2[player]

	if v3 and v3.character ~= character then
		drop(player) -- inferred equivalent call
		v3 = nil
	end

	if not v3 then
		local highlight = Instance.new("Highlight")
		highlight.FillColor = Color3.fromRGB(255, 40, 40)
		highlight.FillTransparency = 0.6
		highlight.OutlineColor = Color3.fromRGB(255, 60, 60)
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Adornee = character
		highlight.Parent = script
		local billboardGui = Instance.new("BillboardGui")
		billboardGui.Adornee = head
		billboardGui.AlwaysOnTop = true
		billboardGui.Size = UDim2.fromOffset(260, 44)
		billboardGui.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
		billboardGui.LightInfluence = 0
		billboardGui.Parent = script
		local textLabel = Instance.new("TextLabel")
		textLabel.BackgroundTransparency = 1
		textLabel.Size = UDim2.fromScale(1, 1)
		textLabel.Font = Enum.Font.GothamBold
		textLabel.TextSize = 14
		textLabel.TextWrapped = true
		textLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
		textLabel.TextStrokeTransparency = 0.3
		textLabel.Parent = billboardGui
		v3 = {
			character = character,
			highlight = highlight,
			tag = billboardGui,
			text = textLabel,
			untilT = 0
		}
		v2[player] = v3
	end

	local v4 = v[p2 == "aim" and "aim" or "move"]
	v3.highlight.FillColor = v4[1]
	v3.highlight.OutlineColor = v4[2]
	v3.text.TextColor3 = v4[3]
	v3.text.Text = player.Name .. "\n" .. p
	v3.untilT = os.clock() + 20
end)

Players.PlayerRemoving:Connect(drop)

task.spawn(function()
	while true do
		task.wait(1)
		local now = os.clock()

		for k, v3 in v2 do
			if v3.untilT < now or v3.character.Parent == nil then
				drop(k) -- inferred equivalent call
			end
		end
	end
end)