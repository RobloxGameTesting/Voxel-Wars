local v = {
	startsWith = function(value, list)
		return value:sub(1, #list) == list and value:sub(#list + 1)
	end,
	contains = function(value, p)
		return value:find(p, 1, true) and value
	end,
	endsWith = function(value, list)
		return value:sub(-#list) == list and value:sub(1, -#list - 1)
	end,
	pattern = function(value, p)
		return value:match(p) and value
	end,
	equals = function(p, p2)
		if p ~= p2 then
			p = false
		end

		return p
	end,
	notEquals = function(p, p2)
		if p == p2 then
			p = false
		end

		return p
	end,
	greaterThan = function(p, p2)
		if not (tonumber(p2) > tonumber(p)) then
			p = false
		end

		return p
	end,
	lessThan = function(p, p2)
		if not (tonumber(p2) < tonumber(p)) then
			p = false
		end

		return p
	end,
	greaterThanOrEqual = function(p, p2)
		if not (tonumber(p2) >= tonumber(p)) then
			p = false
		end

		return p
	end,
	lessThanOrEqual = function(p, p2)
		if not (tonumber(p2) <= tonumber(p)) then
			p = false
		end

		return p
	end,
	length = function(list, p)
		if #list ~= tonumber(p) then
			list = false
		end

		return list
	end
}

local v2 = {}

for k in pairs(v) do
	v2[#v2 + 1] = k
end

return {
	Name = "runif",
	Description = "Runs a given command string if a certain condition is met.",
	Group = "DefaultUtil",
	Args = {
		function(p)
			return {
				Type = p.Cmdr.Util.MakeEnumType("ConditionFunction", v2),
				Name = "Condition",
				Description = "The condition function."
			}
		end,
		{
			Type = "string",
			Name = "Argument",
			Description = "The argument to the condition function."
		},
		{ Type = "string", Name = "Test against", Description = "The text to test against." },
		{
			Type = "string",
			Name = "Command",
			Description = "The command string to run if requirements are met. If omitted, return value from condition function is used.",
			Optional = true
		}
	},
	ClientRun = function(p, p2: string, p3: string, p4: string, p5: string?)
		local success, result = pcall(v[p2], p4, p3)

		if success and result then
			return p.Dispatcher:EvaluateAndRun(p.Cmdr.Util.RunEmbeddedCommands(p.Dispatcher, p5 or result))
		end

		return ""
	end
}