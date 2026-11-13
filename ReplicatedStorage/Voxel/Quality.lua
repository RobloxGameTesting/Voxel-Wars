local RunService = game:GetService("RunService")

local Detail = require(script.Parent:WaitForChild("Detail"))

local isClient = RunService:IsClient()

local Quality = {}
Quality.potato = false
local v = false

Quality.mobile = Detail.mobile

Quality.CHIP_SHARE = 0.35
Quality.LOOSE_CHUNKS = 40
Quality.SMOKE_DRAWN = 3
Quality.FIRE_LIGHTS = 0
Quality.MIN_FIRE_RIGS = 4

Quality.SHARE_NORMAL = 1
Quality.SHARE_MOBILE = 0.55
Quality.SHARE_POTATO = 0.35

Quality.FULL_M = 40
Quality.FAR_M = 180
Quality.CUT_M = 260
Quality.MOBILE_FULL_M = 25
Quality.MOBILE_FAR_M = 110
Quality.MOBILE_CUT_M = 170
Quality.FLOOR = 0.25

local v2 = {
	[0] = 1,
	0.7,
	0.45,
	0.25
}
local v3 = {
	[0] = 1,
	1,
	0.85,
	0.7
}

function Quality.share()
	local v4 = v2[Detail.strain]

	if v then
		return Quality.SHARE_POTATO * v4
	end

	local v5

	if Quality.mobile then
		v5 = Quality.SHARE_MOBILE
	else
		v5 = Quality.SHARE_NORMAL
	end

	return v4 * v5
end

function Quality.strainShare()
	return v2[Detail.strain]
end

function Quality.groundChips(): boolean
	return Detail.strain < 1
end

function Quality.burstKeep()
	return (Quality.mobile and 4 or 1) + Detail.strain
end

function Quality.lowEnd()
	return Quality.potato or Quality.mobile and Detail.strain >= 1
end

function Quality.metres(vector3: Vector3)
	if isClient then
		return (vector3 - Detail.eye).Magnitude / 2.5
	end

	return 0
end

function Quality.detail(vector3: Vector3)
	local mobile = Quality.mobile or Quality.potato
	local v4 = if mobile then Quality.MOBILE_FULL_M else Quality.FULL_M
	local v5 = if mobile then Quality.MOBILE_FAR_M else Quality.FAR_M
	local v6 = if mobile then Quality.MOBILE_CUT_M else Quality.CUT_M
	local v7 = Quality.metres(vector3) / (Detail.reach() * v3[Detail.strain])

	if v6 <= v7 then
		return 0
	end

	local v8

	if v7 <= v4 then
		v8 = 1
	elseif v5 <= v7 then
		v8 = Quality.FLOOR
	else
		v8 = 1 - (1 - Quality.FLOOR) * (v7 - v4) / (v5 - v4)
	end

	return v8 * Quality.share()
end

function Quality.count(p: number, vector3: Vector3, value: number?)
	local detail = Quality.detail(vector3)

	if detail <= 0 then
		return 0
	end

	return (math.max(value or 1, (math.floor(p * detail + 0.5))))
end

function Quality.cap(p: number)
	return (math.max(1, (math.floor(p * Quality.share() + 0.5))))
end

local v4 = {}

function Quality.onChanged(callback)
	table.insert(v4, callback)
end

local function refresh()
	local potato = v or Detail.strain >= 2

	if potato == Quality.potato then
		return
	end

	Quality.potato = potato

	for _, callback in v4 do
		task.spawn(callback, potato)
	end
end
Detail.onStrain(refresh)

function Quality.set(flag: boolean)
	assert(RunService:IsClient(), "[Quality] potato mode is client-side")

	if flag == v then
		return
	end

	v = flag
	Detail.setPotato(flag)
	refresh()
end

return Quality