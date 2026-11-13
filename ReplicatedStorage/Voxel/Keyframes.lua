--!native
local function tangent(list, p: number) -- 2 equivalent calls inferred from this helper
	local v = list[p]
	local v2 = list[p - 1]
	local v3 = list[p + 1]

	if v[3] ~= nil and v[3] ~= true then
		return v[3]
	end

	if v[3] or not (v2 and v3) then
		return v[2] * 0
	end

	return (v3[2] - v2[2]) / (v3[1] - v2[1])
end

local function loopTangent(list, count: number, p: number)
	local v = list[p]

	if v[3] == true then
		return v[2] * 0
	end

	if v[3] ~= nil then
		return v[3]
	end

	local v2 = p - 1
	local v3 = p + 1
	local v4

	if p == 1 or p == count then
		v2 = count - 1
		v3 = 2
		v4 = list[v2][1] - 1
	else
		v4 = list[v2][1]
	end

	local v5 = list[v3][1]

	return (list[v3][2] - list[v2][2]) / (v5 - v4)
end

local Keyframes = {}

function Keyframes.sample(list, p: number)
	local count = #list

	if p <= list[1][1] then
		return list[1][2]
	end

	if list[count][1] <= p then
		return list[count][2]
	end

	local v = 1

	while list[v + 1][1] < p do
		v += 1
	end

	local item = list[v]
	local item2 = list[v + 1]
	local v2 = item2[1] - item[1]
	local v3 = (p - item[1]) / v2
	local v4 = v3 * v3
	local v5 = v3 * v3 * v3
	local v6 = 2 * v5 - 3 * v4 + 1
	local v7 = v5 - 2 * v4 + v3
	local v8 = -2 * v5 + 3 * v4
	local v9 = v5 - v4
	return item[2] * v6 + tangent(list, v) * (v7 * v2) + item2[2] * v8 + tangent(list, v + 1) * (v9 * v2) -- inferred equivalent call
end

function Keyframes.sampleLoop(list, p: number)
	local count = #list
	local v = p % 1
	local v2 = 1

	while v2 < count - 1 and list[v2 + 1][1] < v do
		v2 += 1
	end

	local item = list[v2]
	local item2 = list[v2 + 1]
	local v3 = item2[1] - item[1]
	local v4 = (v - item[1]) / v3
	local v5 = v4 * v4
	local v6 = v4 * v4 * v4
	return item[2] * (2 * v6 - 3 * v5 + 1) + loopTangent(list, count, v2) * ((v6 - 2 * v5 + v4) * v3) + item2[2] * (-2 * v6 + 3 * v5) + loopTangent(list, count, v2 + 1) * ((v6 - v5) * v3)
end

function Keyframes.pose(position: Vector3, vector3: Vector3)
	return CFrame.new(position) * CFrame.fromOrientation(
		math.rad(vector3.X),
		math.rad(vector3.Y),
		(math.rad(vector3.Z))
	)
end

function Keyframes.length(list)
	return list[#list][1]
end

return Keyframes