local Players = game:GetService("Players")

return function(registry)
	local v = {
		Transform = function(p: string)
			return registry.Cmdr.Util.MakeFuzzyFinder(Players:GetPlayers())(p)
		end,
		Validate = function(list): (boolean, string)
			return #list > 0, "No player with that name could be found."
		end,
		Autocomplete = function(p)
			return registry.Cmdr.Util.GetNames(p)
		end,
		Parse = function(list)
			return list[1]
		end,
		Default = function(p)
			return p.Name
		end,
		ArgumentOperatorAliases = { me = ".", all = "*", others = "**", random = "?" }
	}

	registry:RegisterType("player", v)
	registry:RegisterType("players", registry.Cmdr.Util.MakeListableType(v, {
		Prefixes = "% teamPlayers"
	}))
end