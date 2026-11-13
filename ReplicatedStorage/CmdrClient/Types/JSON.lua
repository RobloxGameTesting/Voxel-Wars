local HttpService = game:GetService("HttpService")

return function(registry)
	registry:RegisterType("json", {
		Validate = function(p: string)
			return pcall(HttpService.JSONDecode, HttpService, p)
		end,
		Parse = function(json: string)
			return HttpService:JSONDecode(json)
		end
	})
end