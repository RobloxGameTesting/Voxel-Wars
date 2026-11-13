return function(p: number, p2: number)
	return function(object)
		local argument = object:GetArgument(p)
		local value = argument and argument:GetValue()

		if typeof(value) == "string" and p2 < #value then
			return `Argument #{p} exceeds the maximum character limit of {p2}`
		end

		return nil
	end
end