local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local Crouch = require(Voxel:WaitForChild("Crouch"))
local Movement = require(Voxel:WaitForChild("Movement"))

local LocalPlayer = Players.LocalPlayer

local v = {}

local object = setmetatable({}, { __mode = "k" })
local function crouchAttrOf(character)
	local v2 = object[character]

	if v2 == nil then
		v2 = character:GetAttribute("Crouch") == true
		object[character] = v2
		character:GetAttributeChangedSignal("Crouch"):Connect(function()
			object[character] = character:GetAttribute("Crouch") == true
		end)
	end

	return v2
end

local players = Players:GetPlayers()
Players.PlayerAdded:Connect(function(player)
	if not table.find(players, player) then
		table.insert(players, player)
	end
end)
Players.PlayerRemoving:Connect(function(player)
	local index = table.find(players, player)

	if index then
		table.remove(players, index)
	end
end)

RunService.Stepped:Connect(function(_, dt)
	for _, player in players do
		local character = player.Character

		if not character then
			continue
		end

		local v2

		if player == LocalPlayer then
			v2 = Movement.state.crouching
		else
			v2 = crouchAttrOf(character)
		end

		local v3 = v[character]

		if not (v2 or v3 and (v3.alpha ~= 0 or v3.rig.posed or player == LocalPlayer and Movement.state.crouchAlpha ~= 0)) then
			continue
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if not (humanoid and humanoid.Health > 0 and humanoid.RigType == Enum.HumanoidRigType.R15) then
			continue
		end

		local v4 = v[character]

		if v4 and not Crouch.current(v4.rig, character) then
			v[character] = nil
			v4 = nil
		end

		if not v4 and v2 and Crouch.ready(character) then
			v4 = { rig = Crouch.rig(character), alpha = 0 }
			v[character] = v4
		end

		if not v4 then
			continue
		end

		local alpha

		if player == LocalPlayer then
			alpha = Movement.state.crouchAlpha
		else
			alpha = Crouch.ease(v4.alpha, v2, dt)
		end

		v4.alpha = alpha
		Crouch.pose(v4.rig, v4.alpha)
	end

	for k in v do
		if not k.Parent then
			v[k] = nil
		end
	end
end)