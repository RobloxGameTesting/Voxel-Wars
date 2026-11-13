local v = { "^%a[%w_]*$", "^%$%a[%w_]*$", "^%.%a[%w_]*$", "^%$%.%a[%w_]*$" }

return function(registry)
	local v2 = {
		Autocomplete = function(p: string)
			local store = registry:GetStore("vars_used") or {}
			return registry.Cmdr.Util.MakeFuzzyFinder(registry.Cmdr.Util.DictionaryKeys(store))(p)
		end,
		Validate = function(value: string)
			for _, v2 in ipairs(v) do
				if value:match(v2) then
					return true
				end
			end

			return false, "Key names must start with an optional modifier: . $ or $. and must begin with a letter."
		end,
		Parse = function(p: string)
			return p
		end
	}

	registry:RegisterType("storedKey", v2)
	registry:RegisterType("storedKeys", registry.Cmdr.Util.MakeListableType(v2))
end