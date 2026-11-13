return {
	Name = "armory",
	Description = "Open or close the ARMORY kit screen (in testing).",
	Group = "DefaultAdmin",
	Args = {},
	ClientRun = function(): string
		local Players = game:GetService("Players")
		local playerScripts = Players.LocalPlayer:FindFirstChild("PlayerScripts")
		local gameUI = playerScripts and playerScripts:FindFirstChild("GameUI")
		local armory = gameUI and gameUI:FindFirstChild("Armory")

		if not armory then
			return "armory not loaded"
		end

		local module = require(armory)

		if not module.toggle then
			return "armory not mounted yet (it mounts with the skirmish HUD)"
		end

		module.toggle()
		return "armory toggled"
	end
}