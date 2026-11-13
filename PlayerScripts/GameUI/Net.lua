local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Game = ReplicatedStorage:WaitForChild("Game", 30)
assert(Game, "GameUI: ReplicatedStorage.Game is missing")
local Remotes = Game:WaitForChild("Remotes", 30)
assert(Remotes, "GameUI: ReplicatedStorage.Game.Remotes is missing")
local Match = Game:WaitForChild("Match", 30)
assert(Match and Match:IsA("Configuration"), "GameUI: ReplicatedStorage.Game.Match is missing")

local GameConfig = require(Game:WaitForChild("GameConfig"))
local MapBuilder = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("MapBuilder"))

local Net = {}
Net.Match = Match
Net.Config = GameConfig
Net.Map = MapBuilder

function Net.remote(childName: string)
	local remoteEvent = Remotes:WaitForChild(childName, 30)
	assert(remoteEvent and remoteEvent:IsA("RemoteEvent"), "GameUI: remote Game.Remotes." .. childName .. " is missing")
	return remoteEvent
end

local v = {
	Phase = "Lobby",
	EndsAt = 0,
	RedsBeacons = 20,
	BluesBeacons = 20,
	BeaconsMax = 20,
	BeaconsAlive = "",
	Winner = "",
	Round = 0
}

function Net.get(attributeName: string)
	local attribute = Match:GetAttribute(attributeName)

	if attribute ~= nil then
		return attribute
	end

	local v2 = v[attributeName]
	assert(v2 ~= nil, "GameUI: no default for Match." .. attributeName)
	return v2
end

function Net.changed(p: string, callback)
	Match:GetAttributeChangedSignal(p):Connect(callback)
end

function Net.now()
	return workspace:GetServerTimeNow()
end

function Net.teamOf(p)
	local team = p.Team
	return if team and not p.Neutral then team.Name else nil
end

function Net.teamOfName(childName: string?)
	local player = childName and Players:FindFirstChild(childName)

	if player and player:IsA("Player") then
		return (Net.teamOf(player))
	end

	return nil
end

function Net.attr(instance, attributeName: string, p)
	local attribute = instance:GetAttribute(attributeName)
	return if attribute == nil then p else attribute
end

Net.BEACONS = MapBuilder.BEACONS
local v2 = type(Net.BEACONS) == "table" and #Net.BEACONS > 0
assert(v2, "GameUI: MapBuilder.BEACONS is empty")

function Net.beaconsAlive()
	local beaconsAlive = Net.get("BeaconsAlive")
	local result = table.create(#Net.BEACONS, true)

	if beaconsAlive ~= "" then
		assert(
			#beaconsAlive == #Net.BEACONS,
			"GameUI: Match.BeaconsAlive has " .. #beaconsAlive .. " entries, MapBuilder.BEACONS " .. #Net.BEACONS
		)

		for i = 1, #beaconsAlive do
			result[i] = string.sub(beaconsAlive, i, i) == "1"
		end
	end

	return result
end

function Net.bounds()
	local MAP_BOUNDS = MapBuilder.MAP_BOUNDS
	assert(type(MAP_BOUNDS) == "table", "GameUI: MapBuilder.MAP_BOUNDS is missing")
	local min = MAP_BOUNDS.min or MAP_BOUNDS[1]
	local max = MAP_BOUNDS.max or MAP_BOUNDS[2]
	local v3 = typeof(min) == "Vector3" and typeof(max) == "Vector3"
	assert(v3, "GameUI: MapBuilder.MAP_BOUNDS needs min and max Vector3s")
	return min, max
end

return Net