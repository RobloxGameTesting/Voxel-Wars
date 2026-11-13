local Turret = {
	ID = "Turret",
	NAME = "AUTO TURRET",
	WEAPON = "Turret",
	WRECK = "TurretWreck",
	TOOL = "BuildHammer",
	COST = 80,
	LIMIT = 3,
	BUILD_RANGE = 26,
	BUILD_GAP = 0.3,
	MAX_STEP = 6,
	SPAWN_CLEAR = 8,
	FOOT_HALF = 4,
	BODY_HALF = 3,
	RING_HALF = 2,
	FOOT_TOP = 1,
	BODY_ROWS = { 2, 4 },
	RING_ROWS = { 5, 6 },
	TOP = 7,
	PIVOT_UP = 1.35,
	MUZZLE = 2.7,
	BARREL_X = 0.35,
	CLEAR_HALF = 6,
	CLEAR_ROWS = 7,
	PAL_FOOT = "TurretFooting",
	PAL_BODY = "TurretBody",
	PAL_RING = "TurretPlate",
	HEALTH = 900,
	CELL_LOSS = 120,
	HEAD_R = 1.9,
	HEAD_TOP = 1.3,
	HEAD_LOSS = 1.8,
	RANGE = 170,
	SCAN = 0.2,
	IDLE_ARC = 55,
	IDLE_SPEED = 30,
	IDLE_PITCH = -3,
	TURN_SPEED = 95,
	PITCH_SPEED = 70,
	PITCH_MIN = -35,
	PITCH_MAX = 40,
	ACQUIRE = 0.6,
	LOSE = 1.2,
	FIRE_CONE = 4,
	BURST = 5,
	SHOT_GAP = 0.16,
	BURST_GAP = 0.9,
	SPREAD = 1.2,
	BASE_HELI_SPREAD = 2.5,
	DAMAGE = 14,
	BASE_TOUCH = {
		RANGE = 80,
		ACQUIRE = 1.6,
		BURST = 3,
		SHOT_GAP = 0.3,
		BURST_GAP = 2.4,
		SPREAD = 6
	},
	SYNC = 0.1,
	FLAK = {
		ID = "Flak",
		NAME = "FLAK GUN",
		WEAPON = "Flak",
		COST = 120,
		LIMIT = 1,
		RANGE = 560,
		SCAN = 0.3,
		ACQUIRE = 1,
		LOSE = 1.5,
		TURN_SPEED = 120,
		PITCH_SPEED = 90,
		PITCH_MIN = -5,
		PITCH_MAX = 82,
		IDLE_PITCH = 30,
		FIRE_CONE = 6,
		BURST = 4,
		SHOT_GAP = 0.3,
		BURST_GAP = 1.4,
		SHELL_SPEED = 450,
		SCATTER = 12,
		BLAST_SIZE = 1.2,
		MUZZLE = 3.4
	},
	center = function(p: number, p2: number, p3: number, vector3: Vector3)
		return vector3.X + p * p3, vector3.Z + p2 * p3
	end,
	corner = function(vector3: Vector3, p: number, vector3_2: Vector3)
		return math.round((vector3.X - vector3_2.X) / p), (math.round((vector3.Z - vector3_2.Z) / p))
	end,
	aim = function(position: Vector3, p: number, p2: number)
		return CFrame.new(position) * CFrame.Angles(0, p, 0) * CFrame.Angles(p2, 0, 0)
	end,
	angles = function(vector3: Vector3)
		local v = math.sqrt(vector3.X * vector3.X + vector3.Z * vector3.Z)
		return math.atan2(-vector3.X, -vector3.Z), (math.atan2(vector3.Y, v))
	end,
	inLayer = function(p: number, p2: number, p3: number, flag: boolean): boolean
		if p < -p3 or p3 <= p or p2 < -p3 or p3 <= p2 then
			return false
		end

		return not flag or p ~= -p3 and p ~= p3 - 1 or p2 ~= -p3 and p2 ~= p3 - 1
	end
}

function Turret.cellAt(p: number, p2: number, p3: number)
	if p3 <= Turret.FOOT_TOP then
		if Turret.inLayer(p, p2, Turret.FOOT_HALF, false) then
			return Turret.PAL_FOOT
		end
	elseif p3 <= Turret.BODY_ROWS[2] then
		if Turret.inLayer(p, p2, Turret.BODY_HALF, true) then
			return Turret.PAL_BODY
		end
	elseif p3 <= Turret.RING_ROWS[2] and Turret.inLayer(p, p2, Turret.RING_HALF, false) then
		return Turret.PAL_RING
	end

	return nil
end

function Turret.span(p: number, p2: number, callback, callback2)
	local FOOT_HALF = Turret.FOOT_HALF
	local minValue = 1e999
	local maxValue = -1e999

	for i = -FOOT_HALF, FOOT_HALF - 1 do
		for j = -FOOT_HALF, FOOT_HALF - 1 do
			local v = p + j
			local v2 = p2 + i
			local v3 = callback2(v, v2)

			if callback(v, v3, v2) ~= 0 then
				v3 += 1
			end

			minValue = math.min(minValue, v3)
			maxValue = math.max(maxValue, v3)
		end
	end

	return minValue, maxValue
end

function Turret.plan(p: number, p2: number, callback, callback2)
	local FOOT_HALF = Turret.FOOT_HALF
	local v = FOOT_HALF * 2
	local v2 = table.create(v * v, 0)
	local minValue = 1e999
	local maxValue = -1e999

	for i = -FOOT_HALF, FOOT_HALF - 1 do
		for j = -FOOT_HALF, FOOT_HALF - 1 do
			local v3 = p + j
			local v4 = p2 + i
			local v5 = callback2(v3, v4)

			if callback(v3, v5, v4) ~= 0 then
				v5 += 1
			end

			v2[(i + FOOT_HALF) * v + (j + FOOT_HALF) + 1] = v5
			minValue = math.min(minValue, v5)
			maxValue = math.max(maxValue, v5)
		end
	end

	if maxValue - minValue > Turret.MAX_STEP then
		return nil, nil, nil, "TOO STEEP HERE"
	end

	local result = {}
	local result2 = {}

	for i = -FOOT_HALF, FOOT_HALF - 1 do
		for j = -FOOT_HALF, FOOT_HALF - 1 do
			local v3 = p + j
			local v4 = p2 + i

			for k = v2[(i + FOOT_HALF) * v + (j + FOOT_HALF) + 1], maxValue + Turret.TOP - 1 do
				local cellAt = Turret.cellAt(j, i, k - maxValue)

				if not cellAt then
					continue
				end

				if callback(v3, k, v4) ~= 0 then
					return nil, nil, nil, "SOMETHING IS IN THE WAY"
				end

				local count = #result
				local v5 = count + 1
				local v6 = count + 2
				local v7 = count + 3
				result[v5] = v3
				result[v6] = k
				result[v7] = v4
				table.insert(result2, cellAt)
			end
		end
	end

	local CLEAR_HALF = Turret.CLEAR_HALF

	for i = maxValue + Turret.TOP, maxValue + Turret.TOP + Turret.CLEAR_ROWS - 1 do
		for j = -CLEAR_HALF, CLEAR_HALF - 1 do
			for k = -CLEAR_HALF, CLEAR_HALF - 1 do
				if callback(p + k, i, p2 + j) ~= 0 then
					return nil, nil, nil, "NO ROOM FOR THE GUNS"
				end
			end
		end
	end

	return result, result2, maxValue, nil
end

function Turret.pivot(p: number, p2: number, p3: number, p4: number, vector3: Vector3)
	local center, v = Turret.center(p, p2, p4, vector3)
	return (Vector3.new(center, vector3.Y + (p3 + Turret.TOP) * p4 + Turret.PIVOT_UP, v))
end

return Turret