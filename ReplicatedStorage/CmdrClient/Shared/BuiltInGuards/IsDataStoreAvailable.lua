local RunService = game:GetService("RunService")

return function(p: number)
	return function(object): nil | string
		local argument = object:GetArgument(p)
		local value

		if argument then
			value = argument:GetValue()
		end

		if type(value) ~= "string" then
			return nil
		end

		local v = true

		if value:sub(1, 1) == "$" then
			value = value:sub(2)
		end

		if value:sub(1, 1) == "." then
			v = false
		end

		if not v then
			return nil
		end

		if RunService:IsClient() then
			if game.PlaceId == 0 then
				return "# You must publish this place to the web to use saved keys."
			end
		elseif not object.Cmdr.Util.GetDataStore() then
			return "# You must publish this place to the web to use saved keys."
		end

		return nil
	end
end