local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VehicleConfig = require(ReplicatedStorage:WaitForChild("Vehicles"):WaitForChild("VehicleConfig"))

local VehicleBayData = {
	HALF_X = 13,
	HALF_Z = 16,
	BACK = 2.5,
	WRECK_WAIT = 120,
	PARKED_WAIT = 30,
	EMPTY_GONE = 60,
	PAD_EMPTY_GONE = 45,
	BOT_WAIT = 60,
	HELI_PLAYER_WAIT = 75,
	HELI_PLAYER_PARKED_WAIT = 30
}

local function statsOf(p: string, p2: number, p3: number)
	local v = VehicleConfig[p]
	local v2 = p2 * v.gun.rate
	return {
		{
			name = "SPEED",
			text = tostring(v.topSpeed),
			value = v.topSpeed / 140
		},
		{
			name = "GUN DAMAGE",
			text = math.round(v2) .. "/S",
			value = v2 / 320
		},
		{
			name = "ARMOR",
			text = (math.round)(p3 * 100) .. "%",
			value = p3 / 1.5
		}
	}
end

VehicleBayData.LIST = {
	{
		id = "StealthHeli",
		pad = "air",
		name = "STEALTH CHOPPER",
		blurb = "One seat, yours alone. Quiet rotors, twin rotary guns, heavy rockets.",
		scrap = 10000,
		own = 3727056060,
		call = 3727056071,
		ownRobux = 1499,
		callRobux = 149,
		stats = statsOf("StealthHeli", 9.6, 1.25)
	},
	{
		id = "Jet",
		pad = "air",
		name = "FIGHTER JET",
		blurb = "One seat, yours alone. Fast, with a cannon and bombs.",
		scrap = 20000,
		own = 0,
		call = 0,
		ownRobux = 0,
		callRobux = 0,
		maps = { drywell = true, highcrag = true },
		stats = statsOf("Jet", 30, 1)
	},
	{
		id = "Bomber",
		pad = "air",
		name = "STEALTH BOMBER",
		blurb = "One seat, yours alone. A flying wing that drops a long line of bombs.",
		scrap = 30000,
		own = 0,
		call = 0,
		ownRobux = 0,
		callRobux = 0,
		maps = { drywell = true, highcrag = true },
		hidden = true,
		stats = {
			{
				name = "SPEED",
				text = tostring(VehicleConfig.Bomber.topSpeed),
				value = VehicleConfig.Bomber.topSpeed / 140
			},
			{
				name = "BOMBS",
				text = tostring(VehicleConfig.Bomber.rockets.count),
				value = 1
			},
			{
				name = "ARMOR",
				text = "100%",
				value = 2 / 3
			}
		}
	}
}

VehicleBayData.FREE = {
	{ model = "Heli", name = "HELICOPTER", pad = "air", stats = statsOf("Heli", 16, 1) }
}

VehicleBayData.JET_RUNWAY = {
	drywell = {
		Blues = { pos = Vector3.new(0, 0, -496), look = Vector3.new(1, 0, 0) },
		Reds = { pos = Vector3.new(0, 0, 496), look = Vector3.new(-1, 0, 0) }
	},
	highcrag = {
		Blues = { pos = Vector3.new(160, 0, -486), look = Vector3.new(1, 0, 0) },
		Reds = { pos = Vector3.new(-160, 0, 486), look = Vector3.new(-1, 0, 0) }
	}
}

function VehicleBayData.offered(p, p2: string): boolean
	return p.maps == nil or p.maps[p2] == true
end

function VehicleBayData.centre(vector3: Vector3, vector3_2: Vector3)
	return vector3 - vector3_2 * VehicleBayData.BACK
end

function VehicleBayData.find(p: string)
	for _, v in VehicleBayData.LIST do
		if v.id == p then
			return v
		end
	end

	return nil
end

return VehicleBayData