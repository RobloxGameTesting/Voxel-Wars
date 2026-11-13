local ContextActionService = game:GetService("ContextActionService")

return {
	Name = "unbind",
	Description = "Unbinds an input previously bound with Bind.",
	Group = "DefaultUtil",
	Args = {
		{
			Type = "userInput @ player",
			Name = "Input/Key",
			Description = "The key or input type you'd like to unbind."
		}
	},
	ClientRun = function(object, p): string
		local store = object:GetStore("CMDR_Binds")
		local v = store[p]

		if not v then
			return "That input wasn't bound."
		end

		if type(v) == "string" then
			ContextActionService:UnbindAction(v)
		end

		store[p] = nil
		return "Unbound command from input."
	end
}