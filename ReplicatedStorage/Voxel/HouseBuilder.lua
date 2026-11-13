local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ids = require(ReplicatedStorage.Voxel.Materials).Ids

local HouseBuilder = {}
HouseBuilder.WIDTH = 80
HouseBuilder.DEPTH = 56
local width = HouseBuilder.WIDTH
local depth = HouseBuilder.DEPTH

local function within(p: number, p2: number, p3: number): boolean
	return p2 <= p and p <= p3
end

local function isWall(i: number, i2: number): boolean -- 1 equivalent call inferred from this helper
	return i < 2 or width - 2 <= i or i2 < 2 or depth - 2 <= i2
end

local function windowColumn(i: number, i2: number, flag: boolean)
	if i2 < 2 then
		local v

		if i >= 10 then
			v = i <= 21
		else
			v = false
		end

		if v then
			return v
		end

		if i >= 58 then
			v = i <= 69
		else
			v = false
		end

		if v then
			return v
		end

		if flag then
			if i >= 34 then
				return i <= 45
			end

			return false
		else
			return flag
		end

		return v
	elseif depth - 2 <= i2 then
		local v

		if i >= 10 then
			v = i <= 21
		else
			v = false
		end

		if v then
			return v
		end

		if i >= 34 then
			v = i <= 45
		else
			v = false
		end

		if not v then
			if i >= 58 then
				return i <= 69
			end

			return false
		end

		return v
	else
		local v

		if i2 >= 14 then
			v = i2 <= 25
		else
			v = false
		end

		if not v then
			if i2 >= 30 then
				return i2 <= 41
			end

			return false
		end

		return v
	end
end

local function glassLayer(i: number, i2: number): boolean -- 1 equivalent call inferred from this helper
	if i2 < 2 then
		return i2 == 1
	end

	if depth - 2 <= i2 then
		return i2 == depth - 2
	end

	if i < 2 then
		return i == 1
	end

	return i == width - 2
end

local function wallStory(callback, p: number, p2: number, p3: number, p4: number, flag: boolean, fn)
	for i = p, p2 do
		local v = fn(i)

		for j = 0, depth - 1 do
			for k = 0, width - 1 do
				if not isWall(k, j) then -- inferred equivalent call
					continue
				end

				local v2 = windowColumn(k, j, flag)

				if not flag and j < 2 then
					local v3

					if k >= 36 then
						v3 = k <= 43
					else
						v3 = false
					end

					if v3 and i <= 19 then
						continue
					end
				end

				if v2 then
					local v3

					if p3 <= i then
						v3 = i <= p4
					else
						v3 = false
					end

					if v3 then
						if glassLayer(k, j) then -- inferred equivalent call
							callback(k, i, j, ids.Glass)
						end

						continue
					end
				end

				if v2 and (i == p3 - 1 or i == p4 + 1) then
					callback(k, i, j, ids.Timber)
				else
					callback(k, i, j, v)
				end
			end
		end
	end
end

function HouseBuilder.build(callback)
	for i = 0, depth - 1 do
		for j = 0, width - 1 do
			callback(j, 0, i, ids.Concrete)
			callback(j, 1, i, ids.Concrete)
		end
	end

	wallStory(callback, 2, 25, 9, 18, false, function(p)
		return if p // 2 % 2 == 0 then ids.BrickA else ids.BrickB
	end)

	for i = 2, 25 do
		for j = 2, depth - 2 - 1 do
			local v

			if j >= 24 then
				v = j <= 31
			else
				v = false
			end

			if not (not v or i > 19) then
				continue
			end

			callback(46, i, j, ids.Plaster)
			callback(47, i, j, ids.Plaster)
		end
	end

	for _, v in { 22, 62 } do
		for i = 2, 23 do
			for j = 27, 28 do
				callback(v, i, j, ids.Steel)
				callback(v + 1, i, j, ids.Steel)
			end
		end
	end

	for i = 2, width - 2 - 1 do
		for j = 24, 25 do
			callback(i, j, 27, ids.Steel)
			callback(i, j, 28, ids.Steel)
		end
	end

	for i = 0, 23 do
		for j = 2, i + 2 do
			for k = 44, 51 do
				callback(i + 4, j, k, ids.Floorboards)
			end
		end
	end

	for i = 0, depth - 1 do
		for j = 0, width - 1 do
			local v

			if j >= 4 then
				v = j <= 27
			else
				v = false
			end

			if v then
				local v2

				if i >= 44 then
					v2 = i <= 51
				else
					v2 = false
				end

				if v2 then
					continue
				end
			end

			callback(j, 26, i, ids.Floorboards)
			callback(j, 27, i, ids.Floorboards)
		end
	end

	wallStory(callback, 28, 49, 34, 43, true, function(p)
		if p == 28 or p == 49 then
			return ids.PlasterTrim
		end

		return ids.Plaster
	end)

	for i = 0, depth - 1 do
		for j = 0, width - 1 do
			callback(j, 50, i, ids.Floorboards)
			callback(j, 51, i, ids.Floorboards)
		end
	end

	local function eave(i: number) -- 2 equivalent calls inferred from this helper
		return math.min(i + 2, depth + 1 - i) + 50
	end

	for i = -2, depth + 1 do
		local v = eave(i) -- inferred equivalent call

		for j = -2, width + 1 do
			callback(j, v, i, ids.Timber)
			callback(j, v + 1, i, ids.RoofTile)
		end
	end

	for _, v in {
		0,
		1,
		width - 2,
		width - 1
	} do
		local v2 = v == 1 or v == width - 2

		for i = 0, depth - 1 do
			for j = 52, eave(i) - 1 do -- inferred equivalent call
				local v3

				if i >= 24 then
					v3 = i <= 31
				else
					v3 = false
				end

				if v3 then
					local v4

					if j >= 58 then
						v4 = j <= 65
					else
						v4 = false
					end

					if v4 then
						if v2 then
							callback(v, j, i, ids.Glass)
						end

						continue
					end
				end

				callback(v, j, i, ids.Plaster)
			end
		end
	end
end

return HouseBuilder