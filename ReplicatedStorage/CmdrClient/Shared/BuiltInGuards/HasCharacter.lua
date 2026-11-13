local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local isServer = RunService:IsServer()

local function hasValidCharacter(player): boolean -- 1 equivalent call inferred from this helper
	local character = player.Character
	return character ~= nil and character:FindFirstChild("HumanoidRootPart") ~= nil
end

return function(p: number?)
	return function(object): nil | string
		local player = object.Executor

		if p then
			local argument = object:GetArgument(p)

			if argument then
				player = argument:GetValue()
			else
				player = nil
			end
		end

		local v

		if typeof(player) == "Instance" then
			v = player:IsA("Player")
		else
			v = false
		end

		local v2

		if typeof(player) == "table" and typeof(player[1]) == "Instance" then
			v2 = player[1]:IsA("Player")
		else
			v2 = false
		end

		if not (v or v2) then
			return nil
		end

		local v3 = v and { player } or player
		local v4 = isServer or not workspace.StreamingEnabled

		for _, v5 in ipairs(v3) do
			if not (v4 or v5 == Players.LocalPlayer) or hasValidCharacter(v5) then -- inferred equivalent call
				continue
			end

			if v then
				if p then
					return "Target player has no character."
				end

				return "You don't have a character."
			elseif #v3 == 1 then
				return "Target player has no character."
			else
				return "One or more target players don't have a character."
			end
		end

		return nil
	end
end