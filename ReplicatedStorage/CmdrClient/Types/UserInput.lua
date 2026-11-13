local v = {}

for _, v2 in ipairs(Enum.UserInputType:GetEnumItems()) do
	v[#v + 1] = v2
end

for _, v2 in ipairs(Enum.KeyCode:GetEnumItems()) do
	v[#v + 1] = v2
end

return function(registry)
	local v2 = {
		Transform = function(p: string)
			return registry.Cmdr.Util.MakeFuzzyFinder(v)(p)
		end,
		Validate = function(list): boolean
			return #list > 0
		end,
		Autocomplete = function(p)
			return registry.Cmdr.Util.GetNames(p)
		end,
		Parse = function(list)
			return list[1]
		end
	}

	registry:RegisterType("userInput", v2)
	registry:RegisterType("userInputs", registry.Cmdr.Util.MakeListableType(v2))
end