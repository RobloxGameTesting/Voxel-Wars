local function parseHexDigit(list: string?)
	if not list then
		return nil
	end

	if #list == 1 then
		list = `{list}{list}`
	end

	return (tonumber(list, 16))
end

return function(registry)
	local sequenceType = registry.Cmdr.Util.MakeSequenceType({
		Prefixes = "# hexColor3 ! brickColor3",
		ValidateEach = function(p: number?, p2: number)
			if p == nil then
				return false, `Invalid or missing number at position {p2} in Color3 type.`
			end

			if p < 0 or p > 255 then
				return false, `Number out of acceptable range 0-255 at position {p2} in Color3 type.`
			end

			if p % 1 == 0 then
				return true
			end

			return false, `Number is not an integer at position {p2} in Color3 type.`
		end,
		TransformEach = function(p: string)
			return (tonumber(p))
		end,
		Constructor = Color3.fromRGB,
		Length = 3
	})

	local v = {
		Transform = function(value: string)
			local match, v, v2 = value:match("^#?(%x%x?)(%x%x?)(%x%x?)$")
			return registry.Cmdr.Util.Each(parseHexDigit, match, v, v2)
		end,
		Validate = function(p: number?, p2: number?, p3: number?): (boolean, string)
			return p ~= nil and p2 ~= nil and p3 ~= nil, "Invalid hex color"
		end,
		Parse = function(p: number, p2: number, p3: number)
			return Color3.fromRGB(p, p2, p3)
		end
	}

	registry:RegisterType("color3", sequenceType)
	registry:RegisterType(
		"color3s",
		registry.Cmdr.Util.MakeListableType(sequenceType, {
			Prefixes = "# hexColor3s ! brickColor3s"
		})
	)

	registry:RegisterType("hexColor3", v)
	registry:RegisterType("hexColor3s", registry.Cmdr.Util.MakeListableType(v))
end