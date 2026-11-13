return {
	Name = "killring",
	Description = "Pick the takedown ring: a (glass), b (metal), c (pipe) or off; no argument shows the current one.",
	Group = "Voxel",
	Args = {
		{ Type = "killRing", Name = "ring", Description = "a, b, c or off", Optional = true }
	},
	ClientRun = function(_, value: string?)
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local KILL_RINGS = require(ReplicatedStorage.Voxel.VoxelSound).KILL_RINGS

		if not value then
			return "takedown ring: " .. KILL_RINGS.pick
		end

		local pick = string.lower(value)

		if pick ~= "off" and type(KILL_RINGS[pick]) ~= "table" then
			return "unknown ring '" .. pick .. "' (a, b, c or off)"
		end

		KILL_RINGS.pick = pick

		return "takedown ring: " .. KILL_RINGS.pick
	end
}