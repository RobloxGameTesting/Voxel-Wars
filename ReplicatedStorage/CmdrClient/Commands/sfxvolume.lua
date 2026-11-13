return {
	Name = "sfxvolume",
	Description = "Set destruction and tool sound volume (0 to 2); no argument shows the current value.",
	Group = "Voxel",
	Args = {
		{ Type = "number", Name = "volume", Description = "0 mutes, 1 is normal", Optional = true }
	},
	ClientRun = function(_, value: number?)
		local SoundService = game:GetService("SoundService")
		local voxelSfx = SoundService:FindFirstChild("VoxelSfx")

		if not voxelSfx then
			return "sound effects not loaded"
		end

		if value then
			voxelSfx.Volume = math.clamp(value, 0, 2)
		end

		return string.format("sfx volume %.2f", voxelSfx.Volume)
	end
}