return function(registry)
	local v = {
		Transform = function(p: string)
			return registry.Cmdr.Util.MakeFuzzyFinder(registry:GetTypeNames())(p)
		end,
		Validate = function(list): (boolean, string)
			return #list > 0, "No type with that name could be found."
		end,
		Autocomplete = function(p)
			return p
		end,
		Parse = function(list)
			return list[1]
		end
	}

	registry:RegisterType("type", v)
	registry:RegisterType("types", registry.Cmdr.Util.MakeListableType(v))
end