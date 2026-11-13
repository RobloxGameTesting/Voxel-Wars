local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ShopData = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("ShopData"))

local Mastery = {}
Mastery.MAX_LEVEL = 20
Mastery.KILL_XP = 100
Mastery.HEAD_XP = 50
Mastery.LONG_XP = 50
Mastery.MULTI_XP = 50
Mastery.POINT_XP = 50
Mastery.MULTI_GAP = 4
Mastery.LONG_METRES = {
	shotgun = 20,
	pistol = 40,
	smg = 45,
	rifle = 55,
	lmg = 70,
	dmr = 120,
	sniper = 180
}
Mastery.REV = 3

local function need(p: number) -- 3 equivalent calls inferred from this helper
	local v = math.max(0, p - 4)
	return (p - 1) * 300 + 600 + v * 30 * v
end

local v = {
	function(p: number)
		return (p - 1) * 100 + 200
	end,
	function(p: number)
		return (p - 1) * 300 + 600
	end
}

function Mastery.levelOf(p: number)
	local v2 = math.max(0, p)
	local v3 = 1

	while v3 < Mastery.MAX_LEVEL do
		local v4 = need(v3) -- inferred equivalent call

		if v2 < v4 then
			return v3, v2, v4
		end

		v2 -= v4
		v3 += 1
	end

	return v3, 0, 0
end

function Mastery.startOf(p: number)
	local total = 0

	for i = 1, p - 1 do
		total += need(i) -- inferred equivalent call
	end

	return total
end

function Mastery.fromOld(p: number, value: number?)
	local v2 = v[type(value) ~= "number" and 1 or math.floor(value)]
	assert(v2, "Mastery.fromOld: no curve for rev " .. tostring(value))
	local v3 = math.max(0, p)
	local v4 = 1

	while v4 < Mastery.MAX_LEVEL do
		local v5 = v2(v4)

		if v3 < v5 then
			local v6 = Mastery.startOf(v4)
			return (math.floor(v6 + need(v4) * v3 / v5)) -- inferred equivalent call
		end

		v3 -= v5
		v4 += 1
	end

	return Mastery.startOf(Mastery.MAX_LEVEL)
end

function Mastery.isGun(p: string): boolean
	local v2 = ShopData.ITEMS[p]
	return v2 ~= nil and not v2.retired and (v2.slot == "primary" or v2.slot == "secondary")
end

function Mastery.gunOf(p: string?)
	return if p and Mastery.isGun(p) then p else nil
end

function Mastery.attr(p: string)
	return "Mx_" .. p
end

function Mastery.xp(instance, p: string)
	local attribute = instance:GetAttribute(Mastery.attr(p))
	return if type(attribute) == "number" then attribute else 0
end

function Mastery.level(p, p2: string)
	return (Mastery.levelOf(Mastery.xp(p, p2)))
end

return Mastery