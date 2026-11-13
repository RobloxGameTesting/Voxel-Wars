local TouchLayout = {}

TouchLayout.IDS = { "fire", "aim", "jump", "reload", "crouch", "weapons", "streak" }
TouchLayout.SIZE_MIN = 0.7
TouchLayout.SIZE_MAX = 1.6
TouchLayout.SIZE_STEP = 0.05
TouchLayout.ALPHA_MIN = 0.1
TouchLayout.ALPHA_MAX = 0.85
TouchLayout.ALPHA_DEFAULT = 0.5
TouchLayout.ALPHA_STEP = 0.05
TouchLayout.MIN_PX = 44
TouchLayout.MAX_LEN = 400
local set = {}

for _, v in TouchLayout.IDS do
	set[v] = true
end

local function fresh() -- 4 equivalent calls inferred from this helper
	return { x = nil, y = nil, s = 1, a = TouchLayout.ALPHA_DEFAULT }
end

local v = {}

for _, v2 in TouchLayout.IDS do
	v[v2] = fresh() -- inferred equivalent call
end

local v2 = {}
local v3 = {}

TouchLayout.editing = false

local function round(p: number, p2: number) -- 4 equivalent calls inferred from this helper
	return math.round(p / p2) * p2
end

local function real(value) -- 4 equivalent calls inferred from this helper
	if type(value) == "number" and value == value and math.abs(value) ~= 1e999 then
		return value
	end

	return nil
end

local function cleanItem(p, p2, value, p3)
	p = real(p) -- inferred equivalent call
	p2 = real(p2) -- inferred equivalent call
	local v4

	if p == nil then
		v4 = false
	else
		v4 = p2 ~= nil
	end

	local v6

	if v4 then
		v6 = math.clamp(round(p, 0.001), 0, 1) -- inferred equivalent call
	end

	local v7

	if v4 then
		v7 = math.clamp(round(p2, 0.001), 0, 1) -- inferred equivalent call
	end

	value = real(value) -- inferred equivalent call
	local v5 = {
		x = v6,
		y = v7,
		s = math.clamp(round(value or 1, TouchLayout.SIZE_STEP), TouchLayout.SIZE_MIN, TouchLayout.SIZE_MAX), -- inferred equivalent call
		a = 0
	}
	p3 = real(p3) -- inferred equivalent call
	v5.a = math.clamp(
		round(p3 or TouchLayout.ALPHA_DEFAULT, TouchLayout.ALPHA_STEP), -- inferred equivalent call
		TouchLayout.ALPHA_MIN,
		TouchLayout.ALPHA_MAX
	)
	return v5
end

local function isDefault(data): boolean -- 2 equivalent calls inferred from this helper
	return data.x == nil and math.abs(data.s - 1) < 1e-6 and math.abs(data.a - TouchLayout.ALPHA_DEFAULT) < 1e-6
end

local function parse(value)
	local result = {}

	if type(value) ~= "string" or #value > TouchLayout.MAX_LEN then
		return result
	end

	for k in string.gmatch(value, "[^;]+") do
		local v4, v5, v6, v7, v8 = string.match(k, "^(%a+):([%d%.%-]+),([%d%.%-]+),([%d%.]+),([%d%.]+)$")

		if v4 and set[v4] then
			result[v4] = cleanItem(tonumber(v5), tonumber(v6), tonumber(v7), tonumber(v8))
		end
	end

	return result
end

local function write(p)
	local v4 = {}

	for _, v5 in TouchLayout.IDS do
		local v6 = p[v5]

		if not v6 or isDefault(v6) then -- inferred equivalent call
			continue
		end

		local x = v6.x
		local y = v6.y
		table.insert(
			v4,
			string.format(
				"%s:%s,%s,%.2f,%.2f",
				v5,
				not x and "-" or string.format("%.3f", x),
				not y and "-" or string.format("%.3f", y),
				v6.s,
				v6.a
			)
		)
	end

	return table.concat(v4, ";")
end

function TouchLayout.clean(p)
	return write(parse(p))
end

function TouchLayout.encode()
	return write(v)
end

local function fire() -- 4 equivalent calls inferred from this helper
	for _, v4 in table.clone(v3) do
		v4()
	end
end

function TouchLayout.onChange(callback)
	table.insert(v3, callback)
end

function TouchLayout.load(p)
	local v4 = parse(p)

	if write(v4) == write(v) then
		return
	end

	for _, v5 in TouchLayout.IDS do
		v[v5] = v4[v5] or fresh() -- inferred equivalent call
	end

	fire() -- inferred equivalent call
end

function TouchLayout.item(p: string)
	local v4 = v[p]
	assert(v4, "TouchLayout.item: unknown id " .. tostring(p))
	return v4
end

function TouchLayout.setItem(p: string, data)
	local item = TouchLayout.item(p)
	local x = item.x
	local y = item.y

	if data.x == false then
		x = nil
		y = nil
	elseif data.x ~= nil then
		x = data.x
		y = data.y
	end

	local v4 = cleanItem(x, y, data.s or item.s, data.a or item.a)

	if v4.x == item.x and v4.y == item.y and v4.s == item.s and v4.a == item.a then
		return
	end

	v[p] = v4
	fire() -- inferred equivalent call
end

function TouchLayout.reset(p: string?)
	if p then
		assert(set[p], "TouchLayout.reset: unknown id " .. p)
		v[p] = fresh() -- inferred equivalent call
	else
		for _, v4 in TouchLayout.IDS do
			v[v4] = fresh() -- inferred equivalent call
		end
	end

	fire() -- inferred equivalent call
end

function TouchLayout.isDefault(p: string)
	return isDefault(TouchLayout.item(p)) -- inferred equivalent call
end

function TouchLayout.setEditing(editing: boolean)
	if TouchLayout.editing ~= editing then
		TouchLayout.editing = editing
		fire() -- inferred equivalent call
	end
end

function TouchLayout.register(p: string, p2)
	assert(set[p], "TouchLayout.register: unknown id " .. tostring(p))
	assert(p2.kind == "disc" or p2.kind == "hud", "TouchLayout.register: kind must be disc or hud")
	assert(p2.space == "controls" or p2.space == "hud", "TouchLayout.register: space must be controls or hud")
	v2[p] = p2
end

function TouchLayout.box(p: string)
	local v4 = v2[p]
	assert(v4, "TouchLayout.box: nothing registered " .. tostring(p) .. " (its owner did not mount)")
	return v4
end

function TouchLayout.discPx(p: number, p2: number)
	if p2 >= 1 then
		return p * p2
	end

	return (math.max(p * p2, (math.min(p, TouchLayout.MIN_PX))))
end

function TouchLayout.sizeMin(p: string, vector2: Vector2)
	local box = TouchLayout.box(p)

	if box.kind ~= "disc" then
		return TouchLayout.SIZE_MIN
	end

	local x = box.size(vector2).X
	return (math.clamp(
		math.ceil(math.min(1, TouchLayout.MIN_PX / math.max(x, 1)) / TouchLayout.SIZE_STEP - 1e-6) * TouchLayout.SIZE_STEP,
		TouchLayout.SIZE_MIN,
		1
	))
end

function TouchLayout.keep(vector2: Vector2, vector2_2: Vector2, vector2_3: Vector2, vector2_4: Vector2, value: number?)
	local v4 = vector2_3.X * vector2_2.X
	local v5 = vector2_3.X * (1 - vector2_2.X)
	local v6 = vector2_3.Y * vector2_2.Y
	local v7 = vector2_3.Y * (1 - vector2_2.Y)
	local v8 = math.min(value or 0, (math.max(vector2_4.Y - vector2_3.Y, 0)))
	return Vector2.new(
		math.clamp(vector2.X, v4, (math.max(v4, vector2_4.X - v5))),
		(math.clamp(vector2.Y, v8 + v6, (math.max(v8 + v6, vector2_4.Y - v7))))
	)
end

function TouchLayout.spot(p, vector2: Vector2, vector2_2: Vector2, vector2_3: Vector2)
	local x = p.x
	local y = p.y

	if x and y then
		return TouchLayout.keep(Vector2.new(x * vector2_3.X, y * vector2_3.Y), vector2, vector2_2, vector2_3)
	end

	return nil
end

return TouchLayout