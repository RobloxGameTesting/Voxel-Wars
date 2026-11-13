local v = {
	Years = 31556926,
	Months = 2629744,
	Weeks = 604800,
	Days = 86400,
	Hours = 3600,
	Minutes = 60,
	Seconds = 1
}

local v2 = {}

for k in pairs(v) do
	v2[#v2 + 1] = k
end

local function mapUnits(list, value: string, p: number?, value2: number?)
	local v3 = value2 or 1
	local result = {}

	for i, item in ipairs(list) do
		local v4

		if p == 1 then
			v4 = item:sub(v3, #item - 1)
		else
			v4 = item:sub(v3)
		end

		result[i] = `{value}{v4}`
	end

	return result
end

return function(registry)
	local fuzzyFinder = registry.Cmdr.Util.MakeFuzzyFinder(v2)
	local function stringToSecondDuration(value: string)
		if value == nil or value == "" then
			return nil
		end

		if tonumber(value) == 0 then
			return 0, 0, true
		end

		local match = value:gsub("-?%d+%a+", ""):match("-?%d+")

		if match then
			return nil, tonumber(match), true
		end

		local total = 0
		local v3 = nil

		for k in value:gmatch("-?%d+%a+") do
			local match2, v4 = k:match("(-?%d+)(%a+)")

			if not (match2 ~= nil and v4 ~= nil) then
				continue
			end

			v3 = tonumber(match2)

			local v5 = fuzzyFinder(v4, false, true)

			if #v5 == 0 then
				return nil, v3
			end

			total += (v4:lower() == "m" and 60 or v[v5[1]]) * v3
		end

		if total == 0 then
			return nil
		end

		return total, v3
	end

	local v3 = {
		Transform = function(p: string)
			return p, stringToSecondDuration(p)
		end,
		Validate = function(_, p: number?): (boolean, string)
			return p ~= nil, "Invalid duration format. Example: 1d6h, 30m, 10s."
		end,
		Autocomplete = function(value: string, p: number?, p2: number?, flag: boolean?)
			local v3 = {}

			if flag then
				return mapUnits(fuzzyFinder("", false, true), value, p2)
			end

			if p == nil then
				return v3
			end

			local match = value:match("^.*-?%d+(%a+)%s?$")
			v3 = mapUnits(fuzzyFinder(match, false, true), value, p2, #match + 1)
			table.sort(v3)

			return v3
		end,
		Parse = function(_, p: number)
			return p
		end
	}

	registry:RegisterType("duration", v3)
	registry:RegisterType("durations", registry.Cmdr.Util.MakeListableType(v3))
end