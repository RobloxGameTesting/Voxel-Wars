local v = {
	"true",
	"t",
	"yes",
	"y",
	"on",
	"enable",
	"enabled",
	"1",
	"+"
}
local v2 = {
	"false",
	"f",
	"no",
	"n",
	"off",
	"disable",
	"disabled",
	"0",
	"-"
}

local v3 = {
	Validate = function(p): boolean
		return p ~= nil
	end,
	Parse = function(p)
		return (tostring(p))
	end
}

local v4 = {
	Transform = function(p: string)
		return (tonumber(p))
	end,
	Validate = function(p: number?): boolean
		return p ~= nil
	end,
	Parse = function(p: number)
		return p
	end
}

local v5 = {
	Transform = function(p: string)
		return (tonumber(p))
	end,
	Validate = function(p: number?): (boolean, string)
		return p ~= nil and p == math.floor(p), "Only whole numbers are valid."
	end,
	Parse = function(p: number)
		return p
	end
}

local v6 = {
	Transform = function(p: string)
		return (tonumber(p))
	end,
	Validate = function(p: number?): (boolean, string)
		return p ~= nil and p == math.floor(p) and p > 0, "Only positive whole numbers are valid."
	end,
	Parse = function(p: number)
		return p
	end
}

local v7 = {
	Transform = function(p: string)
		return (tonumber(p))
	end,
	Validate = function(p: number?): (boolean, string)
		return p ~= nil and p == math.floor(p) and p >= 0, "Only non-negative whole numbers are valid."
	end,
	Parse = function(p: number)
		return p
	end
}

local v8 = {
	Transform = function(p: string)
		return (tonumber(p))
	end,
	Validate = function(p: number?): (boolean, string)
		return p ~= nil and p == math.floor(p) and p >= 0 and p <= 255, "Only bytes are valid."
	end,
	Parse = function(p: number)
		return p
	end
}

local v9 = {
	Transform = function(p: string)
		return (tonumber(p))
	end,
	Validate = function(p: number?): (boolean, string)
		return p ~= nil and p == math.floor(p) and p >= 0 and p <= 9, "Only digits are valid."
	end,
	Parse = function(p: number)
		return p
	end
}

return function(registry)
	local dictionary = registry.Cmdr.Util.MakeDictionary(v)
	local dictionary2 = registry.Cmdr.Util.MakeDictionary(v2)

	local v10 = {
		Transform = function(value: string)
			return value:lower()
		end,
		Validate = function(p: string): (boolean, string)
			return dictionary[p] ~= nil or dictionary2[p] ~= nil, "Please use true/yes/on or false/no/off."
		end,
		Parse = function(p: string): nil | boolean
			if dictionary[p] then
				return true
			end

			return if dictionary2[p] then false else nil
		end
	}

	registry:RegisterType("string", v3)
	registry:RegisterType("number", v4)
	registry:RegisterType("integer", v5)
	registry:RegisterType("positiveInteger", v6)
	registry:RegisterType("nonNegativeInteger", v7)
	registry:RegisterType("byte", v8)
	registry:RegisterType("digit", v9)
	registry:RegisterType("boolean", v10)

	registry:RegisterType("strings", registry.Cmdr.Util.MakeListableType(v3))
	registry:RegisterType("numbers", registry.Cmdr.Util.MakeListableType(v4))
	registry:RegisterType("integers", registry.Cmdr.Util.MakeListableType(v5))
	registry:RegisterType("positiveIntegers", registry.Cmdr.Util.MakeListableType(v6))
	registry:RegisterType("nonNegativeIntegers", registry.Cmdr.Util.MakeListableType(v7))
	registry:RegisterType("bytes", registry.Cmdr.Util.MakeListableType(v8))
	registry:RegisterType("digits", registry.Cmdr.Util.MakeListableType(v9))
	registry:RegisterType("booleans", registry.Cmdr.Util.MakeListableType(v10))
end