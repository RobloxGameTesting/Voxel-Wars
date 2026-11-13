local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local MapSelect = require(Voxel:WaitForChild("MapSelect"))
local RunwayPaint = require(Voxel:WaitForChild("RunwayPaint"))

local v = nil
local function show(name: string) -- 1 equivalent call inferred from this helper
	if v then
		v:Destroy()
	end

	v = RunwayPaint.draw(name, workspace)
end
show(MapSelect.name) -- inferred equivalent call
MapSelect.onChange(show)