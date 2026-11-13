local Airstrike = {
	TOOL = "Airstrike",
	WEAPON = "Airstrike",
	KILLS = 4,
	MAX_HELD = 1,
	MAX_RANGE = 650,
	CALL_GAP = 1,
	SPEED = 450,
	ARRIVE = 8,
	SPAWN = 0.4,
	LEAVE = 14.3,
	LOCK_TIME = 0.7,
	LOCK_DRIFT = 25,
	BOMBS = 6,
	BOMB_SPACING = 22,
	BOMB_FALL = 1.4,
	BOMB_SIZE = 2.2,
	BOMB_DAMAGE = 650,
	BLAST_REACH = 1.3,
	ZONE_WIDTH = 94
}

Airstrike.ZONE_LENGTH = (Airstrike.BOMBS - 1) * Airstrike.BOMB_SPACING + 94
Airstrike.ZONE_COLOR = Color3.fromRGB(235, 40, 30)

local v = {
	{ -2800, 560 },
	{ -1500, 500 },
	{ -760, 155 },
	{ -560, 140 },
	{ 200, 270 },
	{ 900, 520 },
	{ 2800, 1250 }
}

local count = #v
local v2 = {}
local v3 = {}

for i = 1, count - 1 do
	v2[i] = (v[i + 1][2] - v[i][2]) / (v[i + 1][1] - v[i][1])
end

local v4 = v2[1]
local v5 = v2[count - 1]
v3[1] = v4
v3[count] = v5

for i = 2, count - 1 do
	v3[i] = v2[i - 1] * v2[i] <= 0 and 0 or (v2[i - 1] + v2[i]) / 2
end

for i = 1, count - 1 do
	if v2[i] == 0 then
		local v6 = i + 1
		v3[i] = 0
		v3[v6] = 0
	else
		local v6 = v3[i] / v2[i]
		local v7 = v3[i + 1] / v2[i]
		local v8 = v6 * v6 + v7 * v7

		if v8 > 9 then
			local v9 = 3 / math.sqrt(v8)
			local v10 = i + 1
			local v11 = v9 * v6 * v2[i]
			local v12 = v9 * v7 * v2[i]
			v3[i] = v11
			v3[v10] = v12
		end
	end
end

function Airstrike.height(p: number)
	local count2 = #v

	if p <= v[1][1] then
		return v[1][2] + v3[1] * (p - v[1][1]), v3[1]
	end

	if v[count2][1] <= p then
		return v[count2][2] + v3[count2] * (p - v[count2][1]), v3[count2]
	end

	local v6 = 1

	while v[v6 + 1][1] < p do
		v6 += 1
	end

	local v7 = v[v6][1]
	local v8 = v[v6][2]
	local v9 = v[v6 + 1][1]
	local v10 = v[v6 + 1][2]
	local v11 = v9 - v7
	local v12 = (p - v7) / v11
	local v13 = v3[v6] * v11
	local v14 = v3[v6 + 1] * v11
	local v15 = v12 * v12
	local v16 = v12 * v12 * v12
	return
		(2 * v16 - 3 * v15 + 1) * v8 + (v16 - 2 * v15 + v12) * v13 + (-2 * v16 + 3 * v15) * v10 + (v16 - v15) * v14,
		((6 * v15 - 6 * v12) * v8 + (3 * v15 - 4 * v12 + 1) * v13 + (-6 * v15 + 6 * v12) * v10 + (3 * v15 - 2 * v12) * v14) / v11
end

function Airstrike.runAt(p: number)
	return Airstrike.SPEED * (p - Airstrike.ARRIVE)
end

function Airstrike.jet(data, p: number)
	local v6 = Airstrike.runAt(p)
	local height, v7 = Airstrike.height(v6)
	local v8 = data.center + data.dir * v6 + Vector3.new(0, 1, 0) * height
	local v9 = data.dir * Airstrike.SPEED + Vector3.new(0, 1, 0) * (Airstrike.SPEED * v7)

	local v10 = math.clamp((v6 - 250) / 900, 0, 1)
	local v11 = data.side * 0.6632251157578453 * v10 * v10 * (3 - v10 * 2) + math.sin(p * 2.3) * 0.026179938779914945
	return CFrame.lookAt(v8, v8 + v9) * CFrame.Angles(0, 0, v11), v9
end

function Airstrike.bombs()
	local result = {}

	for i = 1, Airstrike.BOMBS do
		local v6 = (i - (Airstrike.BOMBS + 1) / 2) * Airstrike.BOMB_SPACING
		local impact = Airstrike.ARRIVE + v6 / Airstrike.SPEED
		table.insert(result, {
			x = v6,
			release = impact - Airstrike.BOMB_FALL,
			impact = impact
		})
	end

	return result
end

function Airstrike.heading(vector3: Vector3)
	local vector3_2 = Vector3.new(vector3.X, 0, vector3.Z)
	return if vector3_2.Magnitude > 0.001 then vector3_2.Unit else nil
end

return Airstrike