--!native
local GroundHeight = require(script.Parent:WaitForChild("GroundHeight"))

local SightRay = {}

local col = GroundHeight.COL

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.IgnoreWater = true
local raycastParams2 = RaycastParams.new()
raycastParams2.FilterType = Enum.RaycastFilterType.Include
raycastParams2.IgnoreWater = true
raycastParams2.FilterDescendantsInstances = { workspace.Terrain }
local v = nil

local function castRun(origin: Vector3, direction: Vector3, p: number, p2: number, p3: number): boolean -- 2 equivalent calls inferred from this helper
	local v2 = math.max(0, p - p3)
	local v3 = math.min(1, p2 + p3)
	return workspace:Raycast(origin + direction * v2, direction * (v3 - v2), raycastParams2) ~= nil
end

function SightRay.blocked(p, origin: Vector3, direction: Vector3)
	if p then
		if v ~= p then
			v = p
			raycastParams.FilterDescendantsInstances = { p }
		end

		if workspace:Raycast(origin, direction, raycastParams) then
			return true
		end
	end

	local v2 = math.max(1, (math.ceil(math.sqrt(direction.X * direction.X + direction.Z * direction.Z) / col)))
	local v3 = 1 / v2
	local x = origin.X
	local y = origin.Y
	local z = origin.Z
	local x2 = direction.X
	local y2 = direction.Y
	local z2 = direction.Z
	local v4 = nil
	local v5 = 0

	for i = 0, v2 do
		local v6 = i * v3

		if y + y2 * v6 < GroundHeight.at(x + x2 * v6, z + z2 * v6) + 2 then
			if v4 == nil then
				v4 = v6
			end

			v5 = v6
		elseif v4 ~= nil then
			if castRun(origin, direction, v4, v5, v3) then -- inferred equivalent call
				return true
			end

			v4 = nil
		end
	end

	if v4 == nil then
		return false
	end

	return castRun(origin, direction, v4, v5, v3) -- inferred equivalent call
end

return SightRay