return function(registry)
	local v = {
		Transform = function(p: string)
			return registry.Cmdr.Util.MakeFuzzyFinder(registry:GetCommandNames())(p)
		end,
		Validate = function(list): (boolean, string)
			return #list > 0, "No command with that name could be found."
		end,
		Autocomplete = function(p)
			return p
		end,
		Parse = function(list)
			return list[1]
		end
	}

	registry:RegisterType("command", v)
	registry:RegisterType("commands", registry.Cmdr.Util.MakeListableType(v))
end