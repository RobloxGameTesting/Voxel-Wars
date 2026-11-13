local Teams = game:GetService("Teams")

return function(registry)
	local v = {
		Transform = function(p: string)
			return registry.Cmdr.Util.MakeFuzzyFinder(Teams:GetTeams())(p)
		end,
		Validate = function(list): (boolean, string)
			return #list > 0, "No team with that name could be found."
		end,
		Autocomplete = function(p)
			return registry.Cmdr.Util.GetNames(p)
		end,
		Parse = function(list)
			return list[1]
		end
	}

	local v2 = {
		Listable = true,
		Transform = v.Transform,
		Validate = v.Validate,
		Autocomplete = v.Autocomplete,
		Parse = function(list)
			return list[1]:GetPlayers()
		end
	}

	local v3 = {
		Transform = v.Transform,
		Validate = v.Validate,
		Autocomplete = v.Autocomplete,
		Parse = function(list)
			return list[1].TeamColor
		end
	}

	registry:RegisterType("team", v)
	registry:RegisterType("teams", registry.Cmdr.Util.MakeListableType(v))

	registry:RegisterType("teamPlayers", v2)

	registry:RegisterType("teamColor", v3)
	registry:RegisterType("teamColors", registry.Cmdr.Util.MakeListableType(v3))
end