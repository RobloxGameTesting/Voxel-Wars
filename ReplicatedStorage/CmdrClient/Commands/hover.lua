local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

return {
	Name = "hover",
	Description = "Returns the name of the player you are hovering over.",
	Group = "DefaultUtil",
	Args = {},
	ClientRun = function()
		local target = LocalPlayer:GetMouse().Target

		if not target then
			return ""
		end

		local playerFromCharacter = Players:GetPlayerFromCharacter(target:FindFirstAncestorOfClass("Model"))

		if playerFromCharacter then
			return `{playerFromCharacter.DisplayName} @({playerFromCharacter.Name})`
		end

		return ""
	end
}