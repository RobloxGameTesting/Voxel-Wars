return {
	Name = "voxelstats",
	Description = "Show world box, loose chunk and edit timing stats for this client.",
	Group = "Voxel",
	Args = {},
	ClientRun = function()
		local Players = game:GetService("Players")
		local voxelRenderHud = Players.LocalPlayer.PlayerGui:FindFirstChild("VoxelRenderHud")
		local textLabel = voxelRenderHud and voxelRenderHud:FindFirstChildOfClass("TextLabel")

		if textLabel then
			return textLabel.Text
		end

		return "voxel world not running"
	end
}