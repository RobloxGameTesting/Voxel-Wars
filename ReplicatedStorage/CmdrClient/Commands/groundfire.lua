return {
	Name = "groundfire",
	Aliases = { "burngrass" },
	Description = "Set the grass you aim at alight. radius: studs of the burn, default 5.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "number",
			Name = "radius",
			Description = "Studs (2..9, default 5)",
			Optional = true
		}
	},
	Data = function()
		local currentCamera = workspace.CurrentCamera
		return { currentCamera.CFrame.Position, currentCamera.CFrame.LookVector }
	end
}