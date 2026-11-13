return {
	Name = "headshotsound",
	Description = "Pick the headshot takedown sound: new or old; no argument shows the current one.",
	Group = "Voxel",
	Args = {
		{ Type = "headshotSound", Name = "sound", Description = "new or old", Optional = true }
	},
	ClientRun = function(_, value: string?)
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local headshot = require(ReplicatedStorage.Voxel.VoxelSound).HEADSHOT

		if not value then
			return "headshot takedown: " .. headshot.pick
		end

		local pick = string.lower(value)

		if pick ~= "new" and pick ~= "old" then
			return "unknown sound '" .. pick .. "' (new or old)"
		end

		headshot.pick = pick

		return "headshot takedown: " .. headshot.pick
	end
}