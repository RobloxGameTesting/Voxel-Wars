local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VehicleConfig = require(script.Parent:WaitForChild("VehicleConfig"))
local VehicleLoadouts = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("VehicleLoadouts"))

local LoadoutAir = {}

function LoadoutAir.modelOf(p): nil | string
	if p == VehicleConfig.Heli then
		return "Heli"
	end

	if p == VehicleConfig.StealthHeli then
		return "StealthHeli"
	end

	if p == VehicleConfig.Jet then
		return "Jet"
	end

	return if p == VehicleConfig.Bomber then "Bomber" else nil
end

local object = setmetatable({}, { __mode = "k" })
local function lay(p, p2)
	local result = object[p2]

	if result then
		return result
	end

	result = table.clone(p)

	for k, v in p2 do
		if k ~= "plain" and k ~= "drop" then
			result[k] = v
		end
	end

	if p2.plain then
		result.heavy = nil
	end

	if p2.drop then
		for _, v in p2.drop do
			result[v] = nil
		end
	end

	object[p2] = result

	return result
end

local function fxOf(p, p2, p3: string) -- 8 equivalent calls inferred from this helper
	local model = LoadoutAir.modelOf(p2)

	if model and VehicleLoadouts.slot(model, p3) then
		return VehicleLoadouts.fx(p, model, p3)
	end

	return nil
end

function LoadoutAir.gun(p, p2)
	local v = fxOf(p, p2, "gun") -- inferred equivalent call

	if v and v.gun then
		return lay(p2.gun, v.gun)
	end

	return p2.gun
end

function LoadoutAir.rockets(p, p2)
	local v = fxOf(p, p2, "rockets") -- inferred equivalent call

	if v and v.rockets then
		return lay(p2.rockets, v.rockets)
	end

	return p2.rockets
end

function LoadoutAir.bomb(p, p2)
	local v = fxOf(p, p2, "rockets") -- inferred equivalent call

	if v and v.bomb then
		return lay(p2.bomb, v.bomb)
	end

	return p2.bomb
end

function LoadoutAir.doorGun(p, p2)
	local v = fxOf(p, p2, "doorgun") -- inferred equivalent call

	if v and v.doorGun then
		return lay(p2.doorGun, v.doorGun)
	end

	return p2.doorGun
end

function LoadoutAir.roundWear(p, p2)
	local v = fxOf(p, p2, "upgrade") -- inferred equivalent call

	if v and type(v.roundWear) == "number" then
		return v.roundWear
	end

	return 1
end

function LoadoutAir.flareCooldown(p, p2)
	local v = fxOf(p, p2, "upgrade") -- inferred equivalent call

	if v and type(v.flareCooldown) == "number" then
		return v.flareCooldown
	end

	return nil
end

function LoadoutAir:arm(state, pilot, p: number)
	state.pilot = pilot
	local tuning = self.tuning

	if not LoadoutAir.modelOf(tuning) then
		return
	end

	if tuning.gun then
		state.gunCfg = LoadoutAir.gun(pilot, tuning)
	end

	local bombCfg

	if tuning.bomb then
		bombCfg = LoadoutAir.bomb(pilot, tuning)
	end

	state.bombCfg = bombCfg
	local rockets = LoadoutAir.rockets(pilot, tuning)

	if rockets ~= state.rocketCfg then
		local v

		if state.rocketCfg == nil then
			v = false
		else
			v = state.rockets >= state.rocketCfg.count
		end

		state.rocketCfg = rockets

		if v and state.rockets ~= rockets.count then
			state.rockets = rockets.count
			state.nextReload = nil
		elseif state.rockets > rockets.count then
			state.rockets = rockets.count
			state.nextReload = nil
		elseif state.rockets < rockets.count and not state.nextReload then
			state.nextReload = p + rockets.reloadDelay
		end

		self.folder:SetAttribute("Rockets", state.rockets)
	end

	local roundWear = LoadoutAir.roundWear(pilot, tuning)

	if roundWear == 1 then
		roundWear = nil
	end

	self.roundWearScale = roundWear
	self.flareCooldown = LoadoutAir.flareCooldown(pilot, tuning)
end

LoadoutAir.cards = {}

function LoadoutAir.board(p, data, flag: boolean)
	local gun = data.gun
	local rockets = data.rockets
	local doorGun = data.doorGun
	local cards = LoadoutAir.cards
	cards.gun = nil
	cards.door = nil
	local AirDefense = require(script.Parent:WaitForChild("AirDefense"))
	AirDefense.flareCooldown = nil

	if flag then
		local gun2 = LoadoutAir.gun(p, data)
		local rockets2 = LoadoutAir.rockets(p, data)
		AirDefense.flareCooldown = LoadoutAir.flareCooldown(p, data)
		local v = fxOf(p, data, "gun") -- inferred equivalent call
		local gun3

		if v then
			gun3 = v.card
		end

		cards.gun = gun3
		return gun2, rockets2, doorGun
	else
		local doorGun2 = LoadoutAir.doorGun(p, data)
		local v = fxOf(p, data, "doorgun") -- inferred equivalent call
		local door

		if v then
			door = v.card
		end

		cards.door = door

		return gun, rockets, doorGun2
	end
end

return LoadoutAir