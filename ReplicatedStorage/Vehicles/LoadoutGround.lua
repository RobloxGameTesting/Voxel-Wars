local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VehicleConfig = require(script.Parent:WaitForChild("VehicleConfig"))
local VehicleLoadouts = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("VehicleLoadouts"))

local LoadoutGround = {}

local slots = {
	Tank = { "shell", "roof", "upgrade" },
	Bradley = { "shell", "launcher", "upgrade" }
}

LoadoutGround.SLOTS = slots
local attr = { shell = "VLshell", roof = "VLroof", launcher = "VLlauncher", upgrade = "VLupgrade" }
LoadoutGround.ATTR = attr

for k, v in slots do
	for _, v2 in v do
		assert(VehicleLoadouts.slot(k, v2), "[LoadoutGround] no VehicleLoadouts slot " .. k .. "." .. v2)
	end
end

local function fxOf(name: string, p: string, value) -- 5 equivalent calls inferred from this helper
	if type(value) ~= "string" then
		return nil
	end

	local option = VehicleLoadouts.option(name, p, value)
	return if option then option.fx else nil
end

local function overlay(p, items)
	local clone = table.clone(p)

	for k, item in items do
		clone[k] = item
	end

	return clone
end

local v = {}

function LoadoutGround.cannonBy(p, value, value2)
	local cannon = VehicleConfig.cannonOf(p)
	local v2 = fxOf(p.name, "shell", value) -- inferred equivalent call
	local v3 = fxOf(p.name, "upgrade", value2) -- inferred equivalent call
	local cannon2

	if v2 then
		cannon2 = v2.cannon
	end

	local refillK

	if v3 then
		refillK = v3.refillK
	end

	if not (cannon2 or refillK) then
		return cannon
	end

	local v4 = "cannon." .. p.name .. "." .. tostring(value) .. "." .. tostring(value2)
	local result = v[v4]

	if result then
		return result
	end

	result = table.clone(cannon)

	for k, v5 in cannon2 or {} do
		result[k] = v5
	end

	if refillK then
		result.refill *= refillK
	end

	v[v4] = result

	return result
end

function LoadoutGround.cannon(p, instance)
	if slots[p.name] then
		return LoadoutGround.cannonBy(p, instance:GetAttribute(attr.shell), instance:GetAttribute(attr.upgrade))
	end

	return VehicleConfig.cannonOf(p)
end

function LoadoutGround.launcherBy(p, value)
	local v2 = VehicleConfig[p.launcher.config]
	local v3 = fxOf(p.name, "launcher", value) -- inferred equivalent call

	if not (v3 and v3.launcher) then
		return v2
	end

	local v4 = "launcher." .. p.name .. "." .. value
	local result = v[v4]

	if result then
		return result
	end

	local launcher = v3.launcher
	result = table.clone(v2)

	for k, v5 in launcher do
		result[k] = v5
	end

	v[v4] = result

	return result
end

function LoadoutGround.launcher(p, instance)
	local launcherBy = LoadoutGround.launcherBy
	local v2

	if slots[p.name] then
		v2 = instance:GetAttribute(attr.launcher)
	end

	return launcherBy(p, v2)
end

function LoadoutGround.roofGunBy(p, value)
	local v2 = fxOf(p.name, "roof", value) -- inferred equivalent call

	if not (v2 and v2.gun) then
		return VehicleConfig.TankGun
	end

	local v3 = "roof." .. p.name .. "." .. value
	local result = v[v3]

	if result then
		return result
	end

	local tankGun = VehicleConfig.TankGun
	local gun = v2.gun
	result = table.clone(tankGun)

	for k, v4 in gun do
		result[k] = v4
	end

	v[v3] = result

	return result
end

function LoadoutGround.roofGun(p, instance)
	local roofGunBy = LoadoutGround.roofGunBy
	local v2

	if slots[p.name] then
		v2 = instance:GetAttribute(attr.roof)
	end

	return roofGunBy(p, v2)
end

function LoadoutGround.shownName(p, instance, p2: string)
	if not slots[p.name] then
		return nil
	end

	local attribute = instance:GetAttribute(attr[p2])
	local v2

	if type(attribute) == "string" then
		v2 = VehicleLoadouts.option(p.name, p2, attribute)
	end

	return if v2 and not v2.default then v2.name else nil
end

local function refillStamp(p: number?) -- 2 equivalent calls inferred from this helper
	if p then
		return workspace:GetServerTimeNow() + math.max(p - os.clock(), 0)
	end

	return 0
end

function LoadoutGround:sync()
	local v2 = slots[self.def.name]

	if not v2 then
		return
	end

	local player = self.seats[1]

	if self.loDriver == (player or false) then
		return
	end

	self.loDriver = player or false

	local lo = self.lo
	local v3

	if self.def.gun == nil then
		v3 = false
	else
		local shells = self.shells
		local v4

		if lo and lo.cannon then
			v4 = lo.cannon
		else
			v4 = VehicleConfig.cannonOf(self.def)
		end

		v3 = v4.shells <= shells
	end

	local v4

	if self.def.launcher == nil then
		v4 = false
	else
		local missiles = self.missiles or 0
		local v5

		if lo and lo.launcher then
			v5 = lo.launcher
		else
			v5 = VehicleConfig[self.def.launcher.config]
		end

		v4 = v5.count <= missiles
	end

	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		player = nil
	end

	local ids = {}
	local flag = false

	for _, v5 in v2 do
		local equipped = VehicleLoadouts.equipped(player, self.def.name, v5)
		local id

		if not equipped.default then
			id = equipped.id
		end

		if id then
			ids[v5] = id
			flag = true
		end

		self.folder:SetAttribute(attr[v5], id)
	end

	if flag then
		local v5 = fxOf(self.def.name, "upgrade", ids.upgrade) -- inferred equivalent call
		local cannon

		if self.def.gun then
			cannon = LoadoutGround.cannonBy(self.def, ids.shell, ids.upgrade)
		end

		local launcher

		if self.def.launcher then
			launcher = LoadoutGround.launcherBy(self.def, ids.launcher)
		end

		local gun

		if self.def.DRIVER_GUN then
			gun = LoadoutGround.roofGunBy(self.def, ids.roof)
		end

		self.lo = {
			cannon = cannon,
			launcher = launcher,
			gun = gun,
			blastWear = not (v5 and v5.blastWear) and 1 or v5.blastWear
		}
	else
		self.lo = nil
	end

	local now = os.clock()

	if self.def.gun then
		local cannon = LoadoutGround.cannonOf(self)

		if self.shells > cannon.shells then
			self.shells = cannon.shells
		elseif v3 and self.shells < cannon.shells then
			self.shells = cannon.shells
			self.refillAt = nil
		end

		if self.shells < cannon.shells and not (self.refillAt or cannon.magazine) then
			self.refillAt = now + cannon.refill
		end

		self.folder:SetAttribute("Shells", self.shells)
		self.folder:SetAttribute("RefillAt", refillStamp(self.refillAt)) -- inferred equivalent call
	end

	if self.def.launcher then
		local launcher = LoadoutGround.launcherOf(self)
		local missiles = self.missiles or 0

		if launcher.count < missiles or v4 and missiles < launcher.count then
			missiles = launcher.count
			self.missiles = missiles
		end

		if missiles < launcher.count and not self.missileRefillAt then
			self.missileRefillAt = now + launcher.refill
		elseif launcher.count <= missiles then
			self.missileRefillAt = nil
		end

		self.folder:SetAttribute("Missiles", self.missiles)
		self.folder:SetAttribute("MissileRefillAt", refillStamp(self.missileRefillAt)) -- inferred equivalent call
	end
end

function LoadoutGround.cannonOf(p)
	LoadoutGround.sync(p)
	local lo = p.lo

	if lo and lo.cannon then
		return lo.cannon
	end

	return (VehicleConfig.cannonOf(p.def))
end

function LoadoutGround.launcherOf(p)
	LoadoutGround.sync(p)
	local lo = p.lo

	if lo and lo.launcher then
		return lo.launcher
	end

	return VehicleConfig[p.def.launcher.config]
end

function LoadoutGround.roofGunOf(p)
	LoadoutGround.sync(p)
	local lo = p.lo
	return if lo and lo.gun then lo.gun else VehicleConfig.TankGun
end

LoadoutGround.wearNow = nil

function LoadoutGround.burst(callback, data, vector3: Vector3, p, vector3_2: Vector3?, p2: number?)
	if not data.hullWear then
		callback(vector3, data.size, p, data.damage, data.weapon, data.kind, vector3_2, nil, data.blast, nil, p2)
		return
	end

	LoadoutGround.wearNow = data.hullWear
	local success, result = pcall(
		callback,
		vector3,
		data.size,
		p,
		data.damage,
		data.weapon,
		data.kind,
		vector3_2,
		nil,
		data.blast,
		nil,
		p2
	)
	LoadoutGround.wearNow = nil

	if not success then
		error(result, 0)
	end
end

function LoadoutGround.wearOn(p)
	local wearNow = LoadoutGround.wearNow or 1

	if not slots[p.def.name] then
		return wearNow
	end

	LoadoutGround.sync(p)
	local lo = p.lo

	if lo then
		wearNow *= lo.blastWear
	end

	return wearNow
end

return LoadoutGround