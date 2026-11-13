local random = Random.new()

return {
	Name = "rand",
	Description = "Returns a random number between min and max.",
	Group = "DefaultUtil",
	Args = {
		{
			Type = "integer",
			Name = "First number",
			Description = "If second number is nil, random number is between 1 and this value. If second number is provided, number is between this number and the second number."
		},
		{
			Type = "integer",
			Name = "Second number",
			Description = "The upper bound.",
			Optional = true
		}
	},
	ClientRun = function(_, p: number, p2: number?)
		local v

		if p2 then
			v = math.min(p, p2)
		else
			v = math.min(1, p)
		end

		local v2

		if p2 then
			v2 = math.max(p, p2)
		else
			v2 = math.max(1, p)
		end

		return (tostring(random:NextInteger(v, v2)))
	end
}