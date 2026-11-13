return {
	Name = "ignite",
	Aliases = { "burn" },
	Description = "Set fire to the wood you aim at (only wood burns). radius: studs around the aim point, default 1.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "number",
			Name = "radius",
			Description = "Studs around the aim point (0..12, default 1)",
			Optional = true
		}
	},
	Data = function()
		local currentCamera = workspace.CurrentCamera
		return { currentCamera.CFrame.Position, currentCamera.CFrame.LookVector }
	end
}