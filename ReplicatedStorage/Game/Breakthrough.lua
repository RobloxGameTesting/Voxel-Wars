local Breakthrough = {
	ENABLED = false,
	ID = "breakthrough",
	NAME = "BREAKTHROUGH",
	MAP = "longreach",
	ATTACKERS = "Blues",
	DEFENDERS = "Reds",
	GOAL = "ATTACK: TAKE EVERY SECTOR. DEFEND: HOLD THE LINE",
	TICKETS = 150,
	SECTOR_TICKETS = 75,
	CAPTURE_TIME = 18,
	RECAPTURE = true,
	FALLBACK_TIME = 12,
	ROUND_TIME = 1800,
	SECTORS = {
		{
			name = "SECTOR 1",
			oz = -784,
			zFrom = -1060,
			zTo = -420,
			points = {
				{
					id = "A",
					name = "OLD FARM",
					x = -150,
					z = -880,
					y = 0.5,
					radius = 26
				},
				{
					id = "B",
					name = "TERRACE POST",
					x = 150,
					z = -560,
					y = 10.5,
					radius = 26
				}
			},
			attack = { x = 30, z = -1210, y = 2, front = 1 },
			defend = { x = 40, z = -330, y = 13, front = -1 }
		},
		{
			name = "SECTOR 2",
			oz = 0,
			zFrom = -420,
			zTo = 260,
			points = {
				{
					id = "A",
					name = "RIVER GATE",
					x = -120,
					z = 10,
					y = 9.5,
					radius = 26
				},
				{
					id = "B",
					name = "THE KNUCKLE",
					x = 140,
					z = 40,
					y = 13,
					radius = 26
				}
			},
			attack = { x = 40, z = -330, y = 13, front = 1 },
			defend = { x = 0, z = 360, y = 16.5, front = -1 }
		},
		{
			name = "SECTOR 3",
			oz = 720,
			zFrom = 260,
			zTo = 1110,
			points = {
				{
					id = "A",
					name = "LAKESIDE",
					x = -110,
					z = 820,
					y = 17,
					radius = 28
				},
				{
					id = "B",
					name = "TERRACE WORKS",
					x = 220,
					z = 860,
					y = 18,
					radius = 28
				}
			},
			attack = { x = 0, z = 360, y = 16.5, front = 1 },
			defend = { x = 0, z = 1180, y = 20.5, front = -1 }
		}
	}
}

function Breakthrough.windowOf(p: number)
	local v = Breakthrough.SECTORS[p]
	assert(v, "[Breakthrough] no sector " .. tostring(p))
	return (Vector3.new(0, 0, v.oz))
end

function Breakthrough.sectorAt(p: number)
	for k, v in Breakthrough.SECTORS do
		if v.oz == p then
			return k
		end
	end

	error("[Breakthrough] no sector has its window at z " .. tostring(p))
end

for k, v in Breakthrough.SECTORS do
	assert(v.oz % 16 == 0, "[Breakthrough] sector " .. k .. ": window offsets are multiples of 16 studs")

	for _, v2 in { v.attack, v.defend } do
		assert(math.abs(v2.z - v.oz) <= 482, "[Breakthrough] sector " .. k .. ": a hall is outside its window")
	end

	for _, point in v.points do
		assert(math.abs(point.z - v.oz) <= 472, "[Breakthrough] sector " .. k .. ": an objective is outside its window")
	end
end

return Breakthrough