return function(p: number)
	return function(object)
		local argument = object:GetArgument(p)
		local value = argument and argument:GetValue()

		if typeof(value) == "string" and not value:match("^%s*$") then
			return nil
		end

		return `Argument #{p} cannot be empty or blank.`
	end
end