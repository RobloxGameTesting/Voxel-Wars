local Mastery = require(script.Parent:WaitForChild("Mastery"))

local VehicleMastery = {}

VehicleMastery.MAX_LEVEL = Mastery.MAX_LEVEL
VehicleMastery.KILL_XP = 100
VehicleMastery.POINT_XP = 50
VehicleMastery.DOWN_XP = 200

function VehicleMastery.key(p: string)
	return "Veh_" .. p
end

function VehicleMastery.attr(p: string)
	return Mastery.attr(VehicleMastery.key(p))
end

function VehicleMastery.xp(instance, p: string)
	local attribute = instance:GetAttribute(VehicleMastery.attr(p))
	return if type(attribute) == "number" then attribute else 0
end

function VehicleMastery.progress(p, p2: string)
	return Mastery.levelOf(VehicleMastery.xp(p, p2))
end

function VehicleMastery.level(p, p2: string)
	return (Mastery.levelOf(VehicleMastery.xp(p, p2)))
end

VehicleMastery.levelOf = Mastery.levelOf
VehicleMastery.startOf = Mastery.startOf

return VehicleMastery