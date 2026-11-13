return {
	Name = "voxelhp",
	Aliases = { "toughness" },
	Description = "Scale voxel toughness: 1 = default, 2 = twice as tough, 0 = off (hits break voxels at once).",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "number",
			Name = "scale",
			Description = "Toughness scale, 0 or more",
			Optional = true
		}
	}
}