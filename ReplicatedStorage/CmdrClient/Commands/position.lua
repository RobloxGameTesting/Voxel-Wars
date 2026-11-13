local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BuiltInGuards = ReplicatedStorage.CmdrClient.Shared.BuiltInGuards
local HasCharacter = require(BuiltInGuards.HasCharacter)

return {
	Name = "position",
	Aliases = { "pos" },
	Description = "Returns the Vector3 position of you or another player.",
	Group = "DefaultDebug",
	Args = {
		{
			Type = "player",
			Name = "Player",
			Description = "The player to report the position of. Omit for your own position.",
			Default = Players.LocalPlayer
		}
	},
	Guards = { HasCharacter(1) },
	ClientRun = function(_, player)
		local character = player.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			return (tostring(humanoidRootPart.Position):gsub("%s", ""))
		end

		return nil
	end
}