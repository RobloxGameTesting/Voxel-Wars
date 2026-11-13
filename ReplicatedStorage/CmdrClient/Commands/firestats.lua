return {
	Name = "firestats",
	Description = "Fire stats: burning voxels, tick cost, budget use, network; and this client's flames.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "boolean",
			Name = "reset",
			Description = "Reset the counters after printing",
			Optional = true
		}
	},
	Data = function()
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		return require(ReplicatedStorage.Voxel.VoxelFire).stats()
	end
}