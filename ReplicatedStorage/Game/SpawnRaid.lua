local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SpawnRaid = {
	ID = "spawnraid",
	NAME = "SPAWN RAID",
	GOAL = "DESTROY THEIR SPAWNS",
	PER_TEAM = 5,
	ROUND_TIME = 900,
	SIEGE_ID = "siege",
	SIEGE_PER_TEAM = 30,
	PAD_HP = 2000,
	PAD_ALERT_GAP = 15,
	PAD_BULLET = 0.5,
	PAD_MELEE = 150,
	PAD_BLAST = 1.9,
	PAD_BLAST_MIN = 0.3,
	PAD_CELL_HP = 1500,
	PAD_ARMOR = 10,
	PAD_CELLS_MIN = 0.5,
	SIEGE_INTRO = 9,
	SIEGE_INTRO_ON = false,
	PAD_SCORE = 150
}

SpawnRaid.SETTINGS = {
	spawnraid = {
		id = "spawnraid",
		name = SpawnRaid.NAME,
		goal = SpawnRaid.GOAL,
		perTeam = SpawnRaid.PER_TEAM,
		roundTime = SpawnRaid.ROUND_TIME,
		pads = false
	},
	siege = {
		id = "siege",
		name = "SPAWN SIEGE",
		goal = "DESTROY THEIR SPAWNS",
		perTeam = SpawnRaid.SIEGE_PER_TEAM,
		roundTime = SpawnRaid.ROUND_TIME,
		pads = true
	}
}

SpawnRaid.MODES = { "domination", "spawnraid", "siege" }

function SpawnRaid.isRaid(value): boolean
	return type(value) == "string" and SpawnRaid.SETTINGS[value] ~= nil
end

function SpawnRaid.settings(p: string)
	local v = SpawnRaid.SETTINGS[p]
	assert(v, "[SpawnRaid] no spawn game for GameMode " .. tostring(p))
	return v
end

function SpawnRaid.mode()
	local Game = ReplicatedStorage:FindFirstChild("Game")
	local gameMode = Game and Game:GetAttribute("GameMode")

	if type(gameMode) == "string" and gameMode ~= "" then
		return gameMode
	end

	return "domination"
end

function SpawnRaid.on()
	return SpawnRaid.isRaid(SpawnRaid.mode())
end

function SpawnRaid.parseAlive(value, p: number)
	local alive = table.create(p, false)

	if type(value) == "string" then
		for i = 1, math.min(p, #value) do
			alive[i] = string.sub(value, i, i) == "1"
		end
	end

	return alive
end

return SpawnRaid