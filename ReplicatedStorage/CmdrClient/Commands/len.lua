return {
	Name = "len",
	Description = "Returns the length of a comma-separated list.",
	Group = "DefaultUtil",
	Args = {
		{ Type = "string", Name = "CSV", Description = "The comma-separated list." }
	},
	ClientRun = function(_, value: string)
		if #value == 0 then
			return "0"
		end

		return (tostring(#value:split(",")))
	end
}