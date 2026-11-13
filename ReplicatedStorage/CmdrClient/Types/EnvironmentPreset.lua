return function(registry)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Environment = require(ReplicatedStorage.Voxel.Environment)
	registry:RegisterType(
		"environmentPreset",
		registry.Cmdr.Util.MakeEnumType("Environment preset", Environment.names())
	)
end