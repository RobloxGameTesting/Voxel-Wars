local Barrier = {
	["ID"] = nil,
	["ID"] = nil,
	["ID"] = nil,
	["ID"] = nil,
	["ID"] = nil,
	["ID"] = nil,
	["ID"] = nil,
	["ID"] = nil,
	["ID"] = nil,
	["ID"] = nil,
	["ID"] = nil,
	["ID"] = nil,
	["ID"] = nil,
	["ID"] = nil,
	["ID"] = nil,
	["ID"] = nil,
	["ID"] = nil,
	ID = "Barrier",
	TOOL = "BuildHammer",
	BUILD_RANGE = 26,
	MAX_STEP = 12,
	SPAWN_CLEAR = 4,
	GONE_SHARE = 0.25,
	LIFETIME = 240,
	BLOCK_SHARE = 0.3,
	MIN_CELLS = 40,
	HP = 480,
	ARMOR = 10,
	YAW_STEP = 0.7853981633974483,
	FOLDER = "BuiltCover",
	STACK_REACH = 1.5,
	PAL_PLATE = "TurretBody",
	PAL_FRAME = "TurretPlate"
}

local PAL_PLATE = Barrier.PAL_PLATE
local PAL_FRAME = Barrier.PAL_FRAME

Barrier.KINDS = {
	Barrier = {
		id = "Barrier",
		name = "BARRICADE",
		cost = 25,
		limit = 4,
		half = 10,
		rows = 8,
		v0 = -3,
		v1 = 1,
		ramp = false,
		stacks = true
	},
	Wall = {
		id = "Wall",
		name = "TALL WALL",
		cost = 40,
		limit = 3,
		half = 10,
		rows = 14,
		v0 = -3,
		v1 = 1,
		ramp = false,
		stacks = true
	},
	Ramp = {
		id = "Ramp",
		name = "RAMP",
		cost = 30,
		limit = 2,
		half = 4,
		rows = 10,
		v0 = 0,
		v1 = 20,
		ramp = true,
		stacks = false
	}
}

Barrier.ORDER = { "Barrier", "Wall", "Ramp" }
Barrier.NAME = Barrier.KINDS.Barrier.name
Barrier.COST = Barrier.KINDS.Barrier.cost
Barrier.LIMIT = Barrier.KINDS.Barrier.limit
Barrier.RAMP_RISE = 2

function Barrier.countAttr(p: string)
	return "Built_" .. p
end

function Barrier.cellAt(p, p2: number, p3: number, p4: number)
	local half = p.half

	if p2 < -half or half <= p2 or p3 < 0 or p.rows <= p3 then
		return nil
	end

	local v = p.rows > 8

	if p4 == -1 or p4 == 0 then
		if v and p3 >= 8 and p3 <= 9 and p2 >= -4 and p2 < 4 then
			return nil
		end

		if
			p3 == p.rows - 1
			or p2 < -half + 2
			or half - 2 <= p2
			or v and (p3 == 7 or p3 == 10) and p2 >= -5 and p2 < 5
		then
			return PAL_FRAME
		end

		return PAL_PLATE
	else
		local v2 = v and 7 or 6

		if
			(p2 == -v2 or p2 == -v2 + 1 or p2 == v2 - 2 or p2 == v2 - 1)
			and (p4 == -2 and p3 < (v and 6 or 4) or p4 == -3 and p3 < (v and 3 or 2))
		then
			return PAL_FRAME
		end

		return nil
	end
end

function Barrier.rampRise(p, p2: number)
	return (math.min(p.rows, p2 // Barrier.RAMP_RISE + 1))
end

function Barrier.snapYaw(p: number)
	return math.round(p / Barrier.YAW_STEP) * Barrier.YAW_STEP
end

function Barrier.centerOf(vector3: Vector3, p: number, vector3_2: Vector3)
	return math.round((vector3.X - vector3_2.X) / p * 2) / 2, math.round((vector3.Z - vector3_2.Z) / p * 2) / 2
end

function Barrier.axes(p: number)
	local v = math.sin(p)
	local v2 = math.cos(p)
	return Vector2.new(v2, -v), Vector2.new(-v, -v2)
end

function Barrier.tops(p)
	local result = table.create(#p.bases, 0)

	for k, v in p.bases do
		result[k] = v + p.rows
	end

	return result
end

function Barrier.encodeTops(list)
	return table.concat(list, ",")
end

function Barrier.decodeTops(value: string)
	local result = {}

	for k in string.gmatch(value, "-?%d+") do
		table.insert(result, (tonumber(k)))
	end

	assert(#result == 20, "[Barrier] tops of a wall record have the wrong length")
	return result
end

function Barrier.under(vector3: Vector3, items, p: number, vector3_2: Vector3)
	local v = (vector3.X - vector3_2.X) / p
	local v2 = (vector3.Z - vector3_2.Z) / p
	local v3 = -1e999
	local v4 = nil

	for _, item in items do
		local axes, v5 = Barrier.axes(item.yaw)
		local v6 = v - item.cx
		local v7 = v2 - item.cz
		local v8 = v6 * axes.X + v7 * axes.Y
		local v9 = v6 * v5.X + v7 * v5.Y

		if not (v8 >= -10 and v8 < 10 and v9 >= -2 and v9 < 2) then
			continue
		end

		local top = item.tops[math.floor(v8) + 10 + 1]

		if not (top and math.abs(vector3.Y - (vector3_2.Y + top * p)) < Barrier.STACK_REACH and v3 < top) then
			continue
		end

		v4 = item
		v3 = top
	end

	return v4
end

function Barrier.footing(data, p: number, p2: number, p3: number, callback, callback2, p4)
	local half = data.half
	local axes, v = Barrier.axes(p3)
	local v2 = math.max(half, data.v1, -data.v0) + 2

	local bases = table.create(half * 2, -1e999)
	local lows = table.create(half * 2, 1e999)
	local cells = {}
	local maxValue = -1e999

	for i = math.floor(p) - v2, math.floor(p) + v2 do
		for j = math.floor(p2) - v2, math.floor(p2) + v2 do
			local v3 = i + 0.5 - p
			local v4 = j + 0.5 - p2
			local v5 = v3 * axes.X + v4 * axes.Y
			local v6 = v3 * v.X + v4 * v.Y

			if not (-half <= v5 and v5 < half and data.v0 <= v6 and v6 < data.v1) then
				continue
			end

			local v7 = math.floor(v5)
			local v8 = math.floor(v6)
			local ramp = data.ramp or v8 == -1 or v8 == 0

			if not (not p4 or ramp) then
				continue
			end

			local v9 = v7 + half + 1
			local bottom

			if p4 then
				bottom = p4[v9]
			else
				bottom = callback2(i, j)

				if callback(i, bottom, j) ~= 0 then
					bottom += 1
				end
			end

			table.insert(cells, {
				x = i,
				z = j,
				i = v7,
				v = v8,
				bottom = bottom
			})

			if data.ramp then
				if v8 < Barrier.RAMP_RISE then
					maxValue = math.max(maxValue, bottom)
				end

				lows[v9] = math.min(lows[v9], bottom)
			elseif ramp then
				local v10 = math.max(bases[v9], bottom)
				local v11 = math.min(lows[v9], bottom)
				bases[v9] = v10
				lows[v9] = v11
			end
		end
	end

	if data.ramp then
		assert(maxValue > -1e999, "[Barrier] no ground under the ramp's foot")

		for i = 1, half * 2 do
			bases[i] = maxValue
			lows[i] = math.min(lows[i], maxValue)
		end
	else
		for i = 1, half * 2 do
			if bases[i] ~= -1e999 then
				continue
			end

			for j = 1, half * 2 do
				local v3

				if i - j >= 1 and bases[i - j] > -1e999 then
					v3 = i - j
				elseif i + j <= half * 2 and bases[i + j] > -1e999 then
					v3 = i + j
				end

				if v3 then
					local v4 = bases[v3]
					local v5 = lows[v3]
					bases[i] = v4
					lows[i] = v5
					break
				end
			end
		end
	end

	local minValue = 1e999
	local maxValue2 = -1e999

	for i = 1, half * 2 do
		assert(bases[i] > -1e999, "[Barrier] no ground under it")
		minValue = math.min(minValue, lows[i])
		maxValue2 = math.max(maxValue2, bases[i])
	end

	return {
		cells = cells,
		bases = bases,
		lows = lows,
		lo = minValue,
		top = maxValue2
	}
end

function Barrier.plan(data, p: number, p2: number, p3: number, callback, callback2, p4)
	local half = data.half
	local footing = Barrier.footing(data, p, p2, p3, callback, callback2, p4)
	local bases = footing.bases
	local cells = {}
	local pals = {}
	local count = 0
	local count2 = 0
	local function add(x: number, p5: number, z: number, p6: string, flag: boolean) -- 3 equivalent calls inferred from this helper
		if flag then
			count += 1
		end

		if callback(x, p5, z) == 0 then
			local count3 = #cells
			local v = count3 + 1
			local v2 = count3 + 2
			local v3 = count3 + 3
			cells[v] = x
			cells[v2] = p5
			cells[v3] = z
			table.insert(pals, p6)
		elseif flag then
			count2 += 1
		end
	end

	if data.ramp then
		local v = bases[1]

		if v - footing.lo > Barrier.MAX_STEP then
			return nil, "TOO STEEP HERE"
		end

		for _, cell in footing.cells do
			local v2 = v + Barrier.rampRise(data, cell.v)

			local v3 = cell.i == -half or cell.i == half - 1

			for i = cell.bottom, v2 - 1 do
				local x = cell.x
				local z = cell.z
				local v4

				if i == v2 - 1 or v3 then
					v4 = PAL_FRAME
				else
					v4 = PAL_PLATE
				end

				add(x, i, z, v4, v <= i) -- inferred equivalent call
			end
		end
	else
		local minValue = 1e999

		for i = 1, half * 2 do
			minValue = math.min(minValue, bases[i])
		end

		if footing.top - minValue > Barrier.MAX_STEP then
			return nil, "TOO STEEP HERE"
		end

		for _, cell in footing.cells do
			local i = cell.i
			local v = bases[i + half + 1]

			if Barrier.cellAt(data, i, 0, cell.v) then
				for j = cell.bottom, v - 1 do
					add(cell.x, j, cell.z, PAL_FRAME) -- inferred equivalent call
				end
			end

			for j = 0, data.rows - 1 do
				local cellAt = Barrier.cellAt(data, i, j, cell.v)

				if not cellAt then
					continue
				end

				if v + j < cell.bottom then
					if cell.v == -1 or cell.v == 0 then
						count += 1
						count2 += 1
					end
				else
					add(cell.x, v + j, cell.z, cellAt, cell.v == -1 or cell.v == 0) -- inferred equivalent call
				end
			end
		end
	end

	if #pals < Barrier.MIN_CELLS or count * Barrier.BLOCK_SHARE < count2 then
		return nil, "SOMETHING IS IN THE WAY"
	end

	return {
		cells = cells,
		pals = pals,
		bases = bases,
		lows = footing.lows,
		top = footing.top,
		rows = data.rows
	}, nil
end

function Barrier.frame(data, p: number, p2: number, p3: number, p4, p5: number, vector3: Vector3)
	local minValue = 1e999

	for _, low in p4.lows do
		minValue = math.min(minValue, low)
	end

	local v = vector3.Y + minValue * p5
	local v2 = vector3.Y + (p4.top + data.rows) * p5
	local _, v3 = Barrier.axes(p3)
	local v4 = not data.ramp and -1 or data.v0
	local v5 = not data.ramp and 1 or data.v1
	local midpoint = (v4 + v5) / 2
	local vector3_2 = Vector3.new(
		vector3.X + (p + v3.X * midpoint) * p5,
		(v2 + v) / 2,
		vector3.Z + (p2 + v3.Y * midpoint) * p5
	)
	local vector3_3 = Vector3.new(data.half * 2 * p5, v2 - v, (v5 - v4) * p5)
	return CFrame.new(vector3_2) * CFrame.fromEulerAnglesYXZ(0, p3, 0), vector3_3
end

function Barrier.box(p, p2: number, p3: number, p4: number, p5, p6: number, vector3: Vector3)
	local frame, v = Barrier.frame(p, p2, p3, p4, p5, p6, vector3)
	local rightVector = frame.RightVector
	local lookVector = frame.LookVector
	local v2 = math.abs(rightVector.X) * v.X / 2 + math.abs(lookVector.X) * v.Z / 2
	local v3 = math.abs(rightVector.Z) * v.X / 2 + math.abs(lookVector.Z) * v.Z / 2
	return frame.Position, (Vector3.new(v2, v.Y / 2, v3))
end

return Barrier