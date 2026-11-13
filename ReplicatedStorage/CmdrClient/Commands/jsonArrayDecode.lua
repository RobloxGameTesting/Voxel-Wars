return {
	Name = "json-array-decode",
	Description = "Decodes a JSON Array into a comma-separated list.",
	Group = "DefaultUtil",
	Args = {
		{ Type = "json", Name = "JSON", Description = "The JSON array." }
	},
	ClientRun = function(_, list)
		if type(list) ~= "table" then
			return (tostring(list))
		end

		local v = {}

		for i, item in ipairs(list) do
			v[i] = tostring(item)
		end

		return table.concat(v, ",")
	end
}