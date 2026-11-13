local ReplicatedStorage = game:GetService("ReplicatedStorage")

local v = {
	roundWinner = { "Reds", "Blues", "draw" },
	teamName = { "Reds", "Blues" },
	botDifficulty = { "easy", "normal", "hard" },
	gameMode = {
		"koth",
		"tdm",
		"siege",
		"saltpan",
		"saltpantdm",
		"saltpanhill",
		"frostmill",
		"frostmilltdm",
		"frostmillhill",
		"pinewold",
		"pinewoldtdm",
		"pinewoldhill",
		"drywell",
		"drywelltdm",
		"drywellhill",
		"highcrag",
		"highcraghill"
	},
	gameMap = { "ironfield", "sandline", "saltpan", "frostmill", "pinewold", "drywell", "highcrag" },
	matchMode = { "domination", "hill", "tdm", "siege" },
	heliMode = { "parked", "idle", "hover", "clear" },
	killRing = { "a", "b", "c", "off" },
	headshotSound = { "new", "old" },
	hitSound = {
		"a",
		"b",
		"c",
		"d",
		"e",
		"f",
		"g",
		"h",
		"i",
		"j",
		"k",
		"old"
	},
	streakSide = { "enemy", "friendly" },
	featureName = { "craters", "grasspress", "mobileshadows" },
	probeSet = { "all", "lighting" },
	onOff = { "on", "off" },
	cheatServerPick = { "flyer", "aim", "next", "prev", "fullest", "back" },
	musicCue = { "swing", "final", "clock", "overtime", "lastspawn", "finalkills" },
	cueSide = { "us", "them" },
	grantAction = { "give", "take" },
	questList = { "daily", "weekly", "bonus" },
	crateTest = { "stock5", "allskins", "noskins", "allbutmythic" },
	crateCount = { "1", "2", "3", "4", "5" },
	crateRarity = { "random", "rare", "epic", "legendary", "mythic" },
	crateOwned = { "new", "owned", "mixed" },
	crateKind = { "rifle", "smg", "lmg", "sniper", "dmr", "shotgun", "pistol" },
	dailyTest = { "day1", "day2", "day3", "day4", "day5", "day6", "day7", "noskin" },
	vehicleOptionTest = { "all", "reset" },
	pardonReason = { "admitted", "falsealarm", "appeal", "other" }
}

local function bayVehicles()
	local VehicleBayData = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("VehicleBayData"))
	local ids = {}

	for _, v2 in VehicleBayData.LIST do
		table.insert(ids, v2.id)
	end

	table.sort(ids)
	assert(#ids > 0, "[CmdrTypes] no vehicles in Game.VehicleBayData.LIST")
	return ids
end

local function vehicleModels()
	local result = {}

	for _, moduleScript in ReplicatedStorage:WaitForChild("Vehicles"):GetChildren() do
		local v2 = string.match(moduleScript.Name, "^(%w+)Model$")

		if v2 and moduleScript:IsA("ModuleScript") then
			table.insert(result, v2)
		end
	end

	table.sort(result)
	assert(#result > 0, "[CmdrTypes] no vehicle models in ReplicatedStorage.Vehicles")
	return result
end

local function testRifles()
	local Game = ReplicatedStorage:WaitForChild("Game")
	local result = {}

	for _, childName in {
		"RifleSpecs",
		"SMGSpecs",
		"LMGSpecs",
		"DMRSpecs",
		"SniperSpecs",
		"PistolSpecs"
	} do
		local module = require(Game:WaitForChild(childName))

		for k in module.LIST do
			table.insert(result, k)
		end
	end

	table.sort(result)
	assert(#result > 0, "[CmdrTypes] no rifles in Game.RifleSpecs")
	table.insert(result, "saved")
	return result
end

local function botNames()
	local names = {}
	local bots = ReplicatedStorage:FindFirstChild("Bots")
	local roster = bots and bots:FindFirstChild("Roster")

	if roster then
		for _, child in roster:GetChildren() do
			local name = child:GetAttribute("Name")

			if typeof(name) == "string" then
				table.insert(names, name)
			end
		end
	end

	table.sort(names)
	return names
end

local function playerLevels()
	local Progression = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("Progression"))
	local result = {}

	for i = 1, Progression.MAX_LEVEL do
		table.insert(result, (tostring(i)))
	end

	return result
end

local function masteryGuns()
	local Game = ReplicatedStorage:WaitForChild("Game")
	local Mastery = require(Game:WaitForChild("Mastery"))

	local ShopData = require(Game:WaitForChild("ShopData"))
	local result = {}

	for k in ShopData.ITEMS do
		if Mastery.isGun(k) then
			table.insert(result, k)
		end
	end

	table.sort(result)
	return result
end

local function weaponLevels()
	local Mastery = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("Mastery"))
	local result = {}

	for i = 1, Mastery.MAX_LEVEL do
		table.insert(result, (tostring(i)))
	end

	return result
end

local Breakthrough = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("Breakthrough"))

if Breakthrough.ENABLED then
	table.insert(v.gameMode, "breakthrough")
end

return function(registry)
	local util = registry.Cmdr.Util
	registry:RegisterType("masteryGun", util.MakeEnumType("masteryGun", masteryGuns()))
	registry:RegisterType("weaponLevel", util.MakeEnumType("weaponLevel", weaponLevels()))

	local VehicleLoadouts = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("VehicleLoadouts"))
	local ids = {}

	for _, v2 in VehicleLoadouts.LIST do
		table.insert(ids, v2.id)
	end

	registry:RegisterType("masteryVehicle", util.MakeEnumType("masteryVehicle", ids))

	registry:RegisterType("goldStep", util.MakeEnumType("goldStep", { "done", "almost", "reset" }))
	registry:RegisterType("playerLevel", util.MakeEnumType("playerLevel", playerLevels()))

	for k, v2 in v do
		registry:RegisterType(k, util.MakeEnumType(k, v2))
	end

	registry:RegisterType("vehicleModel", util.MakeEnumType("vehicleModel", vehicleModels()))
	registry:RegisterType("bayVehicle", util.MakeEnumType("bayVehicle", bayVehicles()))
	registry:RegisterType("testRifle", util.MakeEnumType("testRifle", testRifles()))
	registry:RegisterType("botCallsign", {
		Validate = function(p: string)
			return util.MakeFuzzyFinder(botNames())(p, true) ~= nil, "No bot called " .. p .. "."
		end,
		Autocomplete = function(p: string)
			return util.MakeFuzzyFinder(botNames())(p)
		end,
		Parse = function(p: string)
			return util.MakeFuzzyFinder(botNames())(p, true)
		end
	})
end