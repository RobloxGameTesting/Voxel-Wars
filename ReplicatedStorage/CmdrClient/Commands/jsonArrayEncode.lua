local HttpService = game:GetService("HttpService")

return {
	Name = "json-array-encode",
	Description = "Encodes a comma-separated list into a JSON array.",
	Group = "DefaultUtil",
	Args = {
		{ Type = "string", Name = "CSV", Description = "The comma-separated list." }
	},
	ClientRun = function(_, value: string)
		return HttpService:JSONEncode(value:split(","))
	end
}