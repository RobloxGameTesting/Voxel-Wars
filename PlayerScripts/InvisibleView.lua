local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local v = {}

local function setOne(descendant, localTransparencyModifier: number) -- 4 equivalent calls inferred from this helper
	if descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture") then
		descendant.LocalTransparencyModifier = localTransparencyModifier
	end
end

local function setAll(folder, localTransparencyModifier: number) -- 4 equivalent calls inferred from this helper
	if not folder then
		return
	end

	for _, descendant in folder:GetDescendants() do
		setOne(descendant, localTransparencyModifier) -- inferred equivalent call
	end
end

local function stop(player) -- 1 equivalent call inferred from this helper
	local v2 = v[player]

	if v2 then
		for _, connection in v2 do
			connection:Disconnect()
		end

		v[player] = nil
	end
end

local function hideCharacter(p, instance)
	setAll(instance, 1) -- inferred equivalent call
	table.insert(v[p], instance.DescendantAdded:Connect(function(descendant)
		setOne(descendant, 1) -- inferred equivalent call
	end))
end

local function refresh(player)
	if player == LocalPlayer then
		return
	end

	local invisible = player:GetAttribute("Invisible") == true

	if invisible and not v[player] then
		v[player] = {}
		table.insert(v[player], player.CharacterAdded:Connect(function(character)
			setAll(character, 1) -- inferred equivalent call
			table.insert(v[player], character.DescendantAdded:Connect(function(descendant)
				setOne(descendant, 1) -- inferred equivalent call
			end))
		end))

		if player.Character then
			local character = player.Character
			setAll(character, 1) -- inferred equivalent call
			table.insert(v[player], character.DescendantAdded:Connect(function(descendant)
				setOne(descendant, 1) -- inferred equivalent call
			end))
		end
	elseif not invisible and v[player] then
		stop(player) -- inferred equivalent call
		setAll(player.Character, 0) -- inferred equivalent call
	end
end

local function added(object) -- 1 equivalent call inferred from this helper
	if object == LocalPlayer then
		return
	end

	object:GetAttributeChangedSignal("Invisible"):Connect(function()
		refresh(object)
	end)
	refresh(object)
end

Players.PlayerAdded:Connect(added)

for _, v2 in Players:GetPlayers() do
	added(v2) -- inferred equivalent call
end

Players.PlayerRemoving:Connect(stop)