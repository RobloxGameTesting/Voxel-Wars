local VehicleMastery = require(script.Parent:WaitForChild("VehicleMastery"))

local list = {}
local VehicleLoadouts = {}
VehicleLoadouts.OWNED_ATTR = "VLOwned"
VehicleLoadouts.KINDS = { "ground", "air" }

for _, childName in { "Ground", "Air" } do
	local module = require(script:WaitForChild(childName))

	for _, v in module do
		table.insert(list, v)
	end
end

VehicleLoadouts.LIST = list

local function word(id): boolean -- 3 equivalent calls inferred from this helper
	return type(id) == "string" and id:match("^%w+$") ~= nil
end

local v = {}
local slots = {}
local options = {}
local options2 = {}

for _, v2 in list do
	assert(word(v2.id) and type(v2.name) == "string", "[VehicleLoadouts] bad vehicle row") -- inferred equivalent call
	assert(not v[v2.id], "[VehicleLoadouts] vehicle twice: " .. v2.id)
	assert(table.find(VehicleLoadouts.KINDS, v2.kind), "[VehicleLoadouts] kind must be ground or air: " .. v2.id)
	v[v2.id] = v2
	assert(#v2.slots > 0, "[VehicleLoadouts] no slots: " .. v2.id)

	for _, slot in v2.slots do
		assert(word(slot.id) and type(slot.name) == "string", "[VehicleLoadouts] bad slot in " .. v2.id) -- inferred equivalent call
		assert(
			slot.seat == nil or slot.seat == "driver" or slot.seat == "passenger",
			"[VehicleLoadouts] bad seat in " .. v2.id .. "." .. slot.id
		)
		local v3 = v2.id .. "." .. slot.id
		assert(not slots[v3], "[VehicleLoadouts] slot twice: " .. v3)
		slots[v3] = slot

		for _, option in slot.options do
			assert(word(option.id), "[VehicleLoadouts] bad option id in " .. v3) -- inferred equivalent call
			local v4 = v3 .. "." .. option.id
			assert(not options[v4], "[VehicleLoadouts] option twice: " .. v4)
			local v5 = type(option.name) == "string"
				and type(option.blurb) == "string"
				and type(option.icon) == "string"
				and type(option.scrap) == "number"
			assert(v5, "[VehicleLoadouts] bad option row: " .. v4)
			options[v4] = option

			if option.default then
				assert(not options2[v3], "[VehicleLoadouts] two defaults: " .. v3)
				local v6 = option.scrap == 0 and option.level == nil and option.rank == nil and option.fx == nil
				assert(v6, "[VehicleLoadouts] a default is free and has no fx: " .. v4)
				options2[v3] = option
			else
				assert(
					type(option.fx) == "table",
					"[VehicleLoadouts] an option that is not the default needs fx: " .. v4
				)
				local v6 = type(option.rank) == "number"
					and option.rank >= 2
					and option.rank <= VehicleMastery.MAX_LEVEL
					and option.rank % 1 == 0
				assert(
					v6,
					"[VehicleLoadouts] an option that is not the default needs a rank (vehicle level 2.." .. VehicleMastery.MAX_LEVEL .. "): " .. v4
				)
			end
		end

		assert(options2[v3], "[VehicleLoadouts] no default: " .. v3)
	end
end

local StarterPlayer = game:GetService("StarterPlayer")
local newMenus = StarterPlayer:WaitForChild("StarterPlayerScripts"):WaitForChild("GameUI"):WaitForChild("NewMenus")
VehicleLoadouts.ON = newMenus:GetAttribute("On") == true and newMenus:GetAttribute("Vehicles") == true

function VehicleLoadouts.vehicle(p: string)
	return v[p]
end

function VehicleLoadouts.slot(p: string, p2: string)
	return slots[p .. "." .. p2]
end

function VehicleLoadouts.option(p: string, p2: string, p3: string)
	return options[p .. "." .. p2 .. "." .. p3]
end

function VehicleLoadouts.default(p: string, p2: string)
	local v2 = options2[p .. "." .. p2]
	assert(v2, "[VehicleLoadouts] no slot " .. p .. "." .. p2)
	return v2
end

function VehicleLoadouts.key(p: string, p2: string, p3: string)
	return p .. "." .. p2 .. "." .. p3
end

function VehicleLoadouts.attr(p: string, p2: string)
	return "VL_" .. p .. "_" .. p2
end

local object = setmetatable({}, { __mode = "k" })
local function ownedSet(instance)
	local vlOwned = instance:GetAttribute("VLOwned")

	if type(vlOwned) ~= "string" or vlOwned == "" then
		return {}
	end

	local result = object[vlOwned]

	if result then
		return result
	end

	result = {}

	for k in vlOwned:gmatch("[^;]+") do
		result[k] = true
	end

	object[vlOwned] = result

	return result
end

VehicleLoadouts.ownedSet = ownedSet

local function isPlayer(player) -- 3 equivalent calls inferred from this helper
	return typeof(player) == "Instance" and player:IsA("Player")
end

function VehicleLoadouts.owns(player, p: string, p2: string, p3: string): boolean
	local v2 = p .. "." .. p2 .. "." .. p3
	local v3 = options[v2]

	if not v3 then
		return false
	end

	if v3.default then
		return true
	end

	if isPlayer(player) then -- inferred equivalent call
		return ownedSet(player)[v2] == true or VehicleMastery.level(player, p) >= v3.rank
	end

	return false
end

function VehicleLoadouts.opened(p: string, p2: number, p3: number)
	local v2 = v[p]
	local options3 = {}

	if not v2 then
		return options3
	end

	for _, slot in v2.slots do
		for _, option in slot.options do
			if option.rank and p2 < option.rank and option.rank <= p3 then
				table.insert(options3, option)
			end
		end
	end

	table.sort(options3, function(a, b): boolean
		return a.rank < b.rank
	end)

	return options3
end

function VehicleLoadouts.equipped(instance, p: string, p2: string)
	if not VehicleLoadouts.ON then
		return VehicleLoadouts.default(p, p2)
	end

	local v2 = p .. "." .. p2
	local v3 = options2[v2]
	assert(v3, "[VehicleLoadouts] no slot " .. v2)

	if not isPlayer(instance) then -- inferred equivalent call
		return v3
	end

	local attribute = instance:GetAttribute("VL_" .. p .. "_" .. p2)

	if type(attribute) ~= "string" then
		return v3
	end

	local v4 = options[v2 .. "." .. attribute]

	if v4 and VehicleLoadouts.owns(instance, p, p2, attribute) then
		return v4
	end

	return v3
end

function VehicleLoadouts.fx(p, p2: string, p3: string)
	return VehicleLoadouts.equipped(p, p2, p3).fx
end

function VehicleLoadouts.blocked(instance, p: string, p2: string, p3: string): nil | string
	local v2 = options[p .. "." .. p2 .. "." .. p3]

	if not v2 then
		return "bad"
	end

	if not isPlayer(instance) then -- inferred equivalent call
		return "bad"
	end

	if VehicleLoadouts.owns(instance, p, p2, p3) then
		return "owned"
	end

	local level = instance:GetAttribute("Level")

	if v2.level ~= nil and (type(level) ~= "number" or level < v2.level) then
		return "level"
	end

	local scrap = instance:GetAttribute("Scrap")

	if type(scrap) == "number" and not (scrap < v2.scrap) then
		return nil
	end

	return "scrap"
end

return VehicleLoadouts