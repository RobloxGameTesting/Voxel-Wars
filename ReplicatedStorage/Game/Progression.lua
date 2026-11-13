local GameConfig = require(script.Parent.GameConfig)

local Progression = {}

local LEVEL_XP_BASE = GameConfig.LEVEL_XP_BASE
local LEVEL_XP_STEP = GameConfig.LEVEL_XP_STEP
local LEVEL_MAX = GameConfig.LEVEL_MAX
local LEVEL_EASE_UNTIL = GameConfig.LEVEL_EASE_UNTIL
local LEVEL_EASE_FROM = GameConfig.LEVEL_EASE_FROM
local LEVEL_EASE_STEP = GameConfig.LEVEL_EASE_STEP
local v = type(LEVEL_XP_BASE) == "number" and type(LEVEL_XP_STEP) == "number" and type(LEVEL_MAX) == "number"
assert(v, "[Progression] GameConfig needs LEVEL_XP_BASE, LEVEL_XP_STEP and LEVEL_MAX")
local v2 = type(LEVEL_EASE_UNTIL) == "number"
	and type(LEVEL_EASE_FROM) == "number"
	and type(LEVEL_EASE_STEP) == "number"
assert(v2, "[Progression] GameConfig needs LEVEL_EASE_UNTIL, LEVEL_EASE_FROM and LEVEL_EASE_STEP")

Progression.MAX_LEVEL = LEVEL_MAX

function Progression.need(p: number)
	if LEVEL_MAX <= p then
		return 0
	end

	local v3 = LEVEL_XP_BASE + LEVEL_XP_STEP * (p - 1)

	if p < LEVEL_EASE_UNTIL then
		return math.floor(v3 * (LEVEL_EASE_FROM + LEVEL_EASE_STEP * (p - 1)) / 10 + 0.5) * 10
	end

	return v3
end

function Progression.xpRate(p: number)
	if p < GameConfig.LEVEL_SLOW_FROM then
		return 1
	end

	local v3 = 1 / (1 + GameConfig.LEVEL_SLOW_STEP * (p - GameConfig.LEVEL_SLOW_FROM + 1))

	if GameConfig.LEVEL_LATE_FROM <= p then
		v3 /= 1 + GameConfig.LEVEL_LATE_STEP * (p - GameConfig.LEVEL_LATE_FROM + 1)
	end

	return (math.max(GameConfig.LEVEL_SLOW_MIN, v3))
end

function Progression.levelOf(p: number)
	local v3 = math.max(0, p)
	local v4 = 1

	while v4 < LEVEL_MAX do
		local need = Progression.need(v4)

		if v3 < need then
			return v4, v3, need
		end

		v3 -= need
		v4 += 1
	end

	return LEVEL_MAX, v3, 0
end

function Progression.startOf(p: number)
	local total = 0

	for i = 1, math.min(p, LEVEL_MAX) - 1 do
		total += Progression.need(i)
	end

	return total
end

Progression.GROUPS = {
	{
		id = "combat",
		label = "COMBAT",
		icon = "skull",
		reasons = {
			"TAKEDOWN",
			"SUPPORT",
			"REVIVE",
			"VEHICLE_HIT",
			"VEHICLE_DOWN",
			"VEHICLE_ASSIST",
			"TURRET_HIT",
			"TURRET_DOWN"
		}
	},
	{
		id = "objective",
		label = "OBJECTIVE",
		icon = "flag",
		reasons = {
			"NEUTRALIZING",
			"CAPTURING",
			"NEUTRALIZED",
			"CAPTURED",
			"DEFENDING",
			"BEACON",
			"SPAWN",
			"SPAWN_HIT"
		}
	},
	{
		id = "wrecking",
		label = "WRECKING",
		icon = "bricks",
		reasons = { "BREACH", "DEMOLITION" }
	},
	{
		id = "round",
		label = "ROUND BONUS",
		icon = "chevrons",
		reasons = { "WIN", "ROUND" }
	},
	{ id = "admin", label = "GRANTED", icon = "stack", reasons = {} }
}

Progression.REASONS = {
	TAKEDOWN = { label = "KILL", icon = "skull", counted = true },
	SUPPORT = { label = "SUPPORT", icon = "plus", counted = true },
	REVIVE = { label = "REVIVE", icon = "plus", counted = true },
	VEHICLE_HIT = { label = "VEHICLE DAMAGE", icon = "tank", counted = false },
	VEHICLE_DOWN = { label = "VEHICLE WRECKED", icon = "tank", counted = true },
	VEHICLE_ASSIST = { label = "WRECK SUPPORT", icon = "tank", counted = true },
	TURRET_HIT = { label = "TURRET DAMAGE", icon = "turret", counted = false },
	TURRET_DOWN = { label = "TURRET DESTROYED", icon = "turret", counted = true },
	NEUTRALIZING = { label = "NEUTRALIZING", icon = "flag", counted = false },
	CAPTURING = { label = "CAPTURING", icon = "flag", counted = false },
	NEUTRALIZED = { label = "NEUTRALIZED", icon = "flag", counted = true },
	CAPTURED = { label = "CAPTURED", icon = "flag", counted = true },
	DEFENDING = { label = "DEFENDING", icon = "shield", counted = false },
	BEACON = { label = "BEACON DOWN", icon = "beacon", counted = true },
	SPAWN = { label = "SPAWN DESTROYED", icon = "beacon", counted = true },
	SPAWN_HIT = { label = "SPAWN DAMAGE", icon = "beacon", counted = false },
	BREACH = { label = "BREACH", icon = "bricks", counted = false },
	DEMOLITION = { label = "DEMOLITION", icon = "bricks", counted = false },
	WIN = { label = "ROUND WON", icon = "chevrons", counted = false },
	ROUND = { label = "ROUND PLAYED", icon = "chevrons", counted = false }
}

local labelsById = {}
local idsByReason = {}

for _, v3 in Progression.GROUPS do
	labelsById[v3.id] = v3.label

	for _, reason in v3.reasons do
		assert(Progression.REASONS[reason], "[Progression] reason with no REASONS entry: " .. reason)
		assert(idsByReason[reason] == nil, "[Progression] reason in two groups: " .. reason)
		idsByReason[reason] = v3.id
	end
end

function Progression.groupOf(p: string)
	local v3 = idsByReason[p]

	if not v3 then
		error("[Progression] Score reason '" .. tostring(p) .. "' is in no XP group: add it to Progression.GROUPS")
	end

	return v3
end

function Progression.label(p: string)
	return labelsById[p] or error("[Progression] unknown group " .. tostring(p))
end

return Progression