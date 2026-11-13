return function(registry)
	local v = {
		Validate = function(value: string)
			if value:match("^https?://.+$") then
				return true
			end

			return false, "URLs must begin with http:// or https://"
		end,
		Parse = function(p: string)
			return p
		end
	}

	registry:RegisterType("url", v)
	registry:RegisterType("urls", registry.Cmdr.Util.MakeListableType(v))
end