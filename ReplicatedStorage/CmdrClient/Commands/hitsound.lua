return {
	Name = "hitsound",
	Description = "Pick the hit marker sound: a to k, or old; no argument shows the current one.",
	Group = "Voxel",
	Args = {
		{ Type = "hitSound", Name = "sound", Description = "a to k, or old", Optional = true }
	},
	ClientRun = function(_, value: string?)
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local VoxelSound = require(ReplicatedStorage.Voxel.VoxelSound)
		local HIT_SOUNDS = VoxelSound.HIT_SOUNDS

		if not value then
			return "hit marker sound: " .. HIT_SOUNDS.pick
		end

		local pick = string.lower(value)

		if pick ~= "old" and type(HIT_SOUNDS[pick]) ~= "table" then
			return "unknown sound '" .. pick .. "' (a to k, or old)"
		end

		HIT_SOUNDS.pick = pick
		VoxelSound.ui("hit")

		return "hit marker sound: " .. HIT_SOUNDS.pick
	end
}