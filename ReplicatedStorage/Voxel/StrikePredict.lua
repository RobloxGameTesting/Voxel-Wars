local parent = script.Parent
local VoxelCore = require(parent:WaitForChild("VoxelCore"))
local ClientWorld = require(parent:WaitForChild("ClientWorld"))
local GroundHit = require(parent:WaitForChild("GroundHit"))
local Materials = require(parent:WaitForChild("Materials"))
local Toughness = require(parent:WaitForChild("Toughness"))
local WorldConfig = require(parent:WaitForChild("WorldConfig"))

local meter = WorldConfig.METER
local VOXEL_SIZE = WorldConfig.VOXEL_SIZE
local v = WorldConfig.ORIGIN
WorldConfig.onOrigin(function(p)
	v = p
end)

local v2 = {
	Hammer = 0.4 * meter,
	Shovel = 0.6 * meter
}

local random = Random.new()

local bindableEvent = Instance.new("BindableEvent")
local StrikePredict = {}

StrikePredict.struck = bindableEvent.Event

local v3 = {}

function StrikePredict.strike(pos: Vector3, vector3: Vector3, vector3_2: Vector3, p: string, flag: boolean)
	local v4 = v2[p]
	assert(v4, "[StrikePredict] unknown tool " .. p)
	local v5 = 0
	local broke = false

	if flag then
		local mixed = GroundHit.mix(pos - vector3 * 0.5, v4)

		if mixed then
			v5 = GroundHit.pick(mixed, random)
		end
	else
		local world = ClientWorld.world
		assert(world, "[StrikePredict] the client voxel world is not built")
		local v6 = (pos - vector3 * (VOXEL_SIZE * 0.5) - v) / VOXEL_SIZE
		v5 = VoxelCore.get(world, math.floor(v6.X), math.floor(v6.Y), (math.floor(v6.Z)))
		local v7 = Materials.Palette[v5]

		if v7 then
			if Toughness.dealt(Toughness.Weapons.Hammer, 0, v7.type.armor) >= v7.type.hp then
				broke = true
			else
				broke = false
			end
		end
	end

	if v5 == 0 or not Materials.Palette[v5] then
		return
	end

	table.insert(v3, { pos = pos, at = os.clock(), broke = broke })
	bindableEvent:Fire(pos, vector3, vector3_2, v5, v4, broke, flag)
end

function StrikePredict.match(vector3: Vector3)
	local now = os.clock()

	for i = #v3, 1, -1 do
		local v4 = v3[i]

		if now - v4.at > 2 then
			table.remove(v3, i)
		elseif (v4.pos - vector3).Magnitude < 2 then
			return true, v4.broke
		end
	end

	return false, false
end

return StrikePredict