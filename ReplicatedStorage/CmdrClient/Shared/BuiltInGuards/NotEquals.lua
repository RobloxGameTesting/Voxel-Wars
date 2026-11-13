return function(p: number, p2)
	return function(object)
		local argument = object:GetArgument(p)

		if (argument and argument:GetValue()) == p2 then
			return `Argument #{p} cannot be "{p2}".`
		end

		return nil
	end
end