local Players = game:GetService("Players")

local v = {}

local function getUserId(value: string)
	local v2 = value:match("%(@([^%)]+)%)") or value

	if v[v2] then
		return v[v2]
	end

	if Players:FindFirstChild(v2) then
		local player = Players[v2]

		v[v2] = player.UserId
		return player.UserId
	else
		local success, userIdFromNameAsync = pcall(Players.GetUserIdFromNameAsync, Players, v2)

		if not success then
			return nil
		end

		v[v2] = userIdFromNameAsync
		return userIdFromNameAsync
	end
end

return function(registry)
	local v2 = {
		DisplayName = "Full Player Name",
		Prefixes = "# positiveInteger",
		Transform = function(p: string)
			return p, registry.Cmdr.Util.MakeFuzzyFinder(Players:GetPlayers())(p)
		end,
		ValidateOnce = function(p: string): (boolean, string)
			return getUserId(p) ~= nil, "No player with that name could be found."
		end,
		Autocomplete = function(_, p)
			return registry.Cmdr.Util.GetNames(p)
		end,
		Parse = function(p: string)
			return getUserId(p)
		end,
		Default = function(p)
			return p.Name
		end,
		ArgumentOperatorAliases = { me = ".", all = "*", others = "**", random = "?" }
	}

	registry:RegisterType("playerId", v2)
	registry:RegisterType("playerIds", registry.Cmdr.Util.MakeListableType(v2, {
		Prefixes = "# positiveIntegers"
	}))
end