local WeaponSkins = require(script.Parent.WeaponSkins)
local Progression = require(script.Parent.Progression)

local Crates = {}
Crates.OFF_ATTR = "CratesOff"
Crates.STOCK_KIND = "crate"
Crates.REPEATS = true
Crates.DUP = {
	rare = { scrap = 150 },
	epic = { scrap = 200 },
	legendary = { scrap = 300 },
	mythic = { scrap = 500 }
}
Crates.DUP_XP_SHARE = 0.2

for _, v in WeaponSkins.CRATE_RARITY do
	assert(Crates.DUP[v.id], "[Crates] no DUP for rarity " .. v.id)
end

Crates.MAX_OPEN = 5

Crates.TIERS = {}

for _, v in WeaponSkins.CRATE_RARITY do
	table.insert(Crates.TIERS, { id = v.id, name = v.name, color = v.color })
end

Crates.CLASSES = {
	{
		id = "rifle",
		name = "ASSAULT RIFLE CRATE",
		short = "RIFLE",
		guns = "A SKIN FOR EVERY ASSAULT RIFLE"
	},
	{ id = "smg", name = "SMG CRATE", short = "SMG", guns = "A SKIN FOR EVERY SMG" },
	{ id = "lmg", name = "LMG CRATE", short = "LMG", guns = "A SKIN FOR EVERY LMG" },
	{
		id = "sniper",
		name = "SNIPER CRATE",
		short = "SNIPER",
		guns = "A SKIN FOR EVERY SNIPER RIFLE"
	},
	{ id = "dmr", name = "DMR CRATE", short = "DMR", guns = "A SKIN FOR EVERY DMR" },
	{ id = "shotgun", name = "SHOTGUN CRATE", short = "SHOTGUN", guns = "A SKIN FOR EVERY SHOTGUN" },
	{ id = "pistol", name = "PISTOL CRATE", short = "PISTOL", guns = "A SKIN FOR EVERY PISTOL" }
}

assert(#Crates.CLASSES == #WeaponSkins.CRATE_CLASSES, "[Crates] CLASSES and WeaponSkins.CRATE_CLASSES differ")

for k, class in Crates.CLASSES do
	assert(
		WeaponSkins.CRATE_CLASSES[k] == class.id,
		"[Crates] class " .. k .. " is " .. class.id .. ", WeaponSkins has " .. tostring(WeaponSkins.CRATE_CLASSES[k])
	)
end

function Crates.classOf(p)
	for _, class in Crates.CLASSES do
		if class.id == p then
			return class
		end
	end

	return nil
end

function Crates.tierOf(p: string)
	for _, v in Crates.TIERS do
		if v.id == p then
			return v
		end
	end

	error("[Crates] no tier " .. p)
end

function Crates.dupPay(p: string, value: number)
	local v = assert(Crates.DUP[p], "[Crates] no DUP for rarity " .. tostring(p))
	local v2 = type(value) == "number" and value >= 1
	assert(v2, "[Crates] dupPay level " .. tostring(value))
	return v.scrap, math.floor(Progression.need(value) * Crates.DUP_XP_SHARE / 10 + 0.5) * 10
end

function Crates.odds(callback, p: number)
	local v = {}
	local total = 0

	for _, v2 in WeaponSkins.CRATE_RARITY do
		local v3 = {}

		for _, v4 in WeaponSkins.CRATE do
			if v4.crate ~= v2.id or callback(v4.id) then
				continue
			end

			table.insert(v3, v4)
		end

		v[v2.id] = v3

		if #v3 > 0 then
			total += v2.share
		end
	end

	local result = {}

	if Crates.REPEATS or total <= 0 then
		for _, v2 in WeaponSkins.CRATE_RARITY do
			local v3 = {}

			for _, v4 in WeaponSkins.CRATE do
				if v4.crate == v2.id then
					table.insert(v3, v4)
				end
			end

			assert(#v3 > 0, "[Crates] no skin of rarity " .. v2.id)

			for _, v4 in v3 do
				local dup = callback(v4.id)
				local dupPay, xp = Crates.dupPay(v2.id, p)
				local v5 = {
					tier = v2.id,
					kind = "skin",
					item = v4.id,
					label = v4.name,
					p = v2.share / #v3,
					dup = dup,
					scrap = 0,
					xp = 0
				}

				if not dup then
					dupPay = nil
				end

				v5.scrap = dupPay

				if not dup then
					xp = nil
				end

				v5.xp = xp
				table.insert(result, v5)
			end
		end
	else
		for _, v2 in WeaponSkins.CRATE_RARITY do
			local v3 = v[v2.id]

			for _, v4 in v3 do
				table.insert(result, {
					tier = v2.id,
					kind = "skin",
					item = v4.id,
					label = v4.name,
					p = v2.share / total / #v3
				})
			end
		end
	end

	local total2 = 0

	for _, v2 in result do
		total2 += v2.p
	end

	assert(math.abs(total2 - 1) < 1e-9, "[Crates] odds add up to " .. total2)
	return result
end

function Crates.pick(list, p: number)
	local total = 0

	for _, item in list do
		total += item.p

		if p < total then
			return item
		end
	end

	return list[#list]
end

function Crates.topWithin(callback)
	local count = 0
	local count2 = 0

	for _, v in WeaponSkins.CRATE do
		if callback(v.id) then
			continue
		end

		if v.crate == "rare" or v.crate == "epic" then
			count += 1
		else
			count2 += 1
		end
	end

	if count2 > 0 then
		return count + 1
	end

	return nil
end

function Crates.percent(p: number)
	local v = p * 100

	if v >= 1 then
		return string.format("%.2f%%", v)
	end

	return string.format("%.3f%%", v)
end

return Crates