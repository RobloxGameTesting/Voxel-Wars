local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local maps = {
	ironfield = true,
	sandline = true,
	saltpan = true,
	frostmill = true,
	pinewold = true,
	drywell = true,
	highcrag = true
}

local v = {
	{ map = "highcrag", mode = "domination", weight = 2 },
	{ map = "highcrag", mode = "domination", onePoint = true, weight = 2 },
	{ map = "saltpan", mode = "domination", weight = 1 },
	{ map = "saltpan", mode = "domination", onePoint = true, weight = 1 },
	{ map = "drywell", mode = "domination", weight = 1 },
	{ map = "drywell", mode = "domination", onePoint = true, weight = 1 },
	{ map = "saltpan", mode = "tdm", weight = 0.5 }
}

local Game = ReplicatedStorage:WaitForChild("Game")

if RunService:IsServer() and RunService:IsRunning() and not RunService:IsStudio() then
	local total = 0

	for _, v2 in v do
		total += v2.weight
	end

	local v2 = math.random() * total
	local v3 = v[#v]

	for _, v4 in v do
		v2 -= v4.weight

		if v2 <= 0 then
			v3 = v4
			break
		end
	end

	Game:SetAttribute("Map", v3.map)
	Game:SetAttribute("GameMode", v3.mode)
	Game:SetAttribute("OnePoint", v3.onePoint and true or nil)
	print(string.format("[MapSelect] opening on %s %s%s", v3.map, v3.mode, v3.onePoint and " (king of the hill)" or ""))
end

if RunService:IsServer() and RunService:IsRunning() then
	local Players = game:GetService("Players")
	Game:SetAttribute("ServerSize", Players.MaxPlayers)
	Game:SetAttribute("MapReady", true)
elseif RunService:IsRunning() then
	while Game:GetAttribute("MapReady") ~= true do
		Game:GetAttributeChangedSignal("MapReady"):Wait()
	end
end

local v2 = {
	sandline = "Sandline",
	saltpan = "Saltpan",
	frostmill = "Frostmill",
	pinewold = "Pinewold",
	drywell = "Drywell",
	highcrag = "Highcrag"
}

local Breakthrough = require(Game:WaitForChild("Breakthrough"))

if Breakthrough.ENABLED then
	maps[Breakthrough.MAP] = true
	v2[Breakthrough.MAP] = "Longreach"
end

local v3 = { "MapBuilder", "GroundHeight" }
local v4 = RunService:IsServer() and RunService:IsRunning()

local function parked(name: string)
	local parkedMapCode = ServerStorage:FindFirstChild("ParkedMapCode")

	if not parkedMapCode then
		parkedMapCode = Instance.new("Folder")
		parkedMapCode.Name = "ParkedMapCode"
		parkedMapCode.Parent = ServerStorage
	end

	local v5 = parkedMapCode:FindFirstChild(name)

	if not v5 then
		v5 = Instance.new("Folder")
		v5.Name = name
		v5.Parent = parkedMapCode
	end

	return v5
end

local function offer(map: string)
	for _, childName in v3 do
		local child = script.Parent:WaitForChild(childName)
		local v5 = parked(childName)

		for k, childName2 in v2 do
			local v6 = child:FindFirstChild(childName2) or v5:FindFirstChild(childName2)
			assert(v6, "[MapSelect] " .. childName .. " has no module " .. childName2)
			local parent = if k == map then child else v5
			v6.Parent = parent
		end
	end
end

local map = Game:GetAttribute("Map")
local v5 = type(map) == "string" and maps[map]
assert(
	v5,
	"[MapSelect] ReplicatedStorage.Game Map must be \"ironfield\", \"sandline\", \"saltpan\", \"frostmill\", \"pinewold\", \"drywell\" or \"highcrag\", got " .. tostring(map)
)

local MapSelect = { name = map, MAPS = maps }

if v4 then
	offer(map)
end

function MapSelect.module(childName: string, p: string)
	local v6 = v2[p]
	assert(v6, "[MapSelect] no child modules for map " .. tostring(p))
	local child = script.Parent:WaitForChild(childName)

	if v4 then
		return child:FindFirstChild(v6) or parked(childName):FindFirstChild(v6)
	end

	return (child:WaitForChild(v6))
end

local v6 = {}

function MapSelect.onChange(fn, value: number?)
	table.insert(v6, {
		order = value or 10,
		seq = #v6 + 1,
		fn = fn
	})
	table.sort(v6, function(a, b): boolean
		if a.order == b.order then
			return a.seq < b.seq
		end

		return a.order < b.order
	end)
end

local function apply(name: string)
	if name == MapSelect.name then
		return
	end

	assert(maps[name], "[MapSelect] unknown map " .. tostring(name))
	MapSelect.name = name

	for _, v7 in v6 do
		v7.fn(name)
	end
end

function MapSelect.set(map2: string)
	assert(RunService:IsServer(), "[MapSelect] set is the server's")
	assert(maps[map2], "[MapSelect] unknown map " .. tostring(map2))
	offer(map2)
	Game:SetAttribute("Map", map2)
	apply(map2)
end

function MapSelect.sync()
	local map2 = Game:GetAttribute("Map")

	if type(map2) == "string" and maps[map2] then
		apply(map2)
	end
end

if RunService:IsClient() then
	Game:GetAttributeChangedSignal("Map"):Connect(MapSelect.sync)
end

return MapSelect