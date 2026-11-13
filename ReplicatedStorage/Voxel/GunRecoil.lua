local Viewmodel = require(script.Parent:WaitForChild("Viewmodel"))

local v = {
	{ 1, -0.5 },
	{ 1.25, -0.2548 },
	{ 1.5, -0.0845 },
	{ 1.75, 0.0413 },
	{ 2, 0.1385 },
	{ 2.5, 0.2793 },
	{ 3, 0.3771 },
	{ 3.5, 0.4494 },
	{ 4, 0.5052 },
	{ 4.5, 0.5497 },
	{ 5, 0.5861 }
}

local function cameraShare(aimFov: number)
	local v2 = 0.5205670505517462 / math.tan(math.rad(aimFov) / 2)
	local v3 = v[#v][2]

	if v2 <= v[1][1] then
		v3 = v[1][2]
	else
		for i = 2, #v do
			local v4 = v[i - 1]
			local v5 = v[i]

			if v2 <= v5[1] then
				v3 = v4[2] + (v5[2] - v4[2]) * (v2 - v4[1]) / (v5[1] - v4[1])
				break
			end
		end
	end

	return (v3 + 1) * 0.5
end

local v2 = { back = 72, curve = 1.2 }
local v3 = { back = 46, curve = 0.92 }
local v4 = { back = 104, curve = 1.46 }
local v5 = { back = 16, curve = 1 }
local v6 = { back = 13.7, curve = 0.555 }
local v7 = { back = 21.5, curve = 1.33 }
local v8 = { back = 400, curve = 2 }

local function gun(p, amount: number, dir: number, vary: number, roll: number, lean, hip: number?) -- 32 equivalent calls inferred from this helper
	return {
		amount = amount,
		dir = dir,
		vary = vary,
		back = p.back,
		curve = p.curve,
		roll = roll,
		lean = lean,
		hip = hip
	}
end

local profiles = {}
profiles.AssaultRifle = gun(v2, 0.42, 12, 30, 0.2) -- inferred equivalent call
profiles.K433 = gun(v2, 0.47, 22, 41, 0.2) -- inferred equivalent call
profiles.GX36 = {
	amount = 0.42,
	dir = 3,
	vary = 18,
	back = v2.back,
	curve = v2.curve,
	roll = 0.2,
	lean = { 5, 22 },
	hip = nil
}
profiles.SK556 = gun(v2, 0.36, 9, 13, 0.2) -- inferred equivalent call
profiles.RN545 = gun({ back = 44, curve = 1.023 }, 0.324639, -18, 28.9, 0.2) -- inferred equivalent call
profiles.MX65 = gun({ back = 60.800000000000004, curve = 1.24 }, 0.47820959999999996, 19, 27.6, 0.2) -- inferred equivalent call
profiles.BT762 = gun({ back = 83.2, curve = 1.459 }, 0.6957582, -20, 40.8, 0.25) -- inferred equivalent call
profiles.SMG = gun(v3, 0.36, 14, 24, 0.15) -- inferred equivalent call
profiles.KP50 = gun(v3, 0.27, 8, 16, 0.15) -- inferred equivalent call
profiles.HM45 = gun(v3, 0.52, -10, 20, 0.3) -- inferred equivalent call
local v9 = { back = 40, curve = 0.92 }
profiles.TK17 = {
	amount = 0.34,
	dir = -24,
	vary = 16,
	back = v9.back,
	curve = v9.curve,
	roll = 0.12,
	lean = { 6, -32 },
	hip = nil
}
profiles.PD46 = gun(v3, 0.29, 4, 12, 0.12) -- inferred equivalent call
profiles.SP44 = gun(v3, 0.31, 10, 20, 0.18) -- inferred equivalent call
profiles.LMG = gun(v4, 0.36, 5, 30, 0.4) -- inferred equivalent call
profiles.BX110 = gun(v4, 0.32, 0, 22, 0.4) -- inferred equivalent call
profiles.HX83 = gun(v4, 0.26, 10, 30, 0.5) -- inferred equivalent call
profiles.MG60 = gun(v4, 0.42, -12, 18, 0.8) -- inferred equivalent call

profiles.KT8 = gun(v2, 0.3, 8, 9.5, 0.3) -- inferred equivalent call
profiles.NX68 = gun({ back = 76, curve = 1.24 }, 0.38, -14, 36, 0.45) -- inferred equivalent call
profiles.GR240 = gun(v4, 0.46, 5, 34.5, 0.85) -- inferred equivalent call
profiles.DMR = gun(v5, 0.62, 8, 10, 0.5) -- inferred equivalent call
profiles.FS16 = gun(v5, 0.36, 5, 10, 0.3) -- inferred equivalent call
profiles.GV12 = gun(v5, 1.2, 18, 10, 0.7) -- inferred equivalent call

profiles.KR54 = gun({ back = 16, curve = 1.1 }, 0.56, -20, 10, 0.45) -- inferred equivalent call
profiles.QS9 = gun({ back = 13.7, curve = 0.5555 }, 0.29, 13, 9.2, 0.25) -- inferred equivalent call
profiles.Pistol = gun(v6, 0.45, -7, 12, 0) -- inferred equivalent call
profiles.SV20 = gun(v6, 0.4, -7, 12, 0) -- inferred equivalent call
profiles.ZK10 = gun(v3, 0.32, -8, 22, 0) -- inferred equivalent call
profiles.HandCannon = gun(v7, 3.2, -8, 12, 2.2) -- inferred equivalent call
profiles.Shotgun = gun(v7, 2.2, -5, 15, 2.4) -- inferred equivalent call

profiles.Sniper = gun(v8, 1.1, -5, 10, 1, nil, 4) -- inferred equivalent call
profiles.RX10 = gun(v8, 1.35, -5, 10, 1.3, nil, 5) -- inferred equivalent call
profiles.SC11 = gun(v8, 0.85, -5, 6, 0.7, nil, 3.2) -- inferred equivalent call
profiles.VX50 = gun(v8, 1.95, -8, 10, 1.8, nil, 6) -- inferred equivalent call

local GunRecoil = {}
GunRecoil.__index = GunRecoil
GunRecoil.PROFILES = profiles

function GunRecoil.new(name: string)
	local profile = profiles[name]
	assert(profile, "[GunRecoil] no profile for " .. name)
	return (setmetatable({
		profile = profile,
		name = name,
		camPitch = 0,
		camYaw = 0,
		rng = Random.new(),
		pitch = 0,
		yaw = 0,
		rawPitch = 0,
		rawYaw = 0,
		held = false,
		dipPitch = 0,
		dipYaw = 0,
		velPitch = 0,
		velYaw = 0,
		pendPitch = 0,
		pendYaw = 0,
		left = 0,
		age = 1e999,
		round = 0,
		dip = 0,
		roll = 0,
		rollAge = 1e999,
		spare = 0
	}, GunRecoil))
end

local function add(state, p: number, p2: number) -- 2 equivalent calls inferred from this helper
	state.rawPitch += p
	state.rawYaw += p2
	state.dipPitch -= p * state.dip
	state.dipYaw -= p2 * state.dip
end

function GunRecoil:shot(p: number, value: number?, value2: number?)
	local profile = self.profile

	if self.age > 0.25 then
		self.round = 0
	end

	self.round += 1

	if self.left > 0 then
		local v10 = self.left / 0.025
		add(self, self.pendPitch * v10, self.pendYaw * v10) -- inferred equivalent call
	end

	local v10

	if profile.lean and self.round > profile.lean[1] then
		v10 = profile.lean[2]
	else
		v10 = profile.dir
	end

	local v11 = math.rad(v10 + (self.rng:NextNumber() * 2 - 1) * profile.vary)
	local v12

	if Viewmodel.touchMode then
		v12 = 0.75 * (Viewmodel.TOUCH_EASE[self.name] or 1)
	else
		v12 = Viewmodel.padKick(self.name)
	end

	local v13 = profile.amount + ((profile.hip or profile.amount) - profile.amount) * (1 - p)
	self.pendPitch = math.cos(v11) * v13 * v12 * (value or 1)
	self.pendYaw = -math.sin(v11) * v13 * v12 * (value2 or 1)
	self.left = 0.025
	self.held = self.age < 0.13
	self.age = 0
	self.dip = math.min((1 - p) * 2.4, 1 / profile.amount)
	local v14

	if self.round == 1 then
		v14 = math.max(profile.roll, (math.min(profile.roll * 2.5, 0.5)))
	else
		v14 = profile.roll
	end

	self.roll = v14 * v12 * (self.rng:NextNumber() * 2 - 1)
	self.rollAge = 0
end

function GunRecoil:step(p: number)
	self.rollAge += p
	local current = Viewmodel.current
	local v10

	if current == nil then
		v10 = false
	else
		v10 = current.tool.Name == self.name
	end

	if
		self.rawPitch == 0
		and self.rawYaw == 0
		and self.pitch == 0
		and self.yaw == 0
		and self.dipPitch == 0
		and self.dipYaw == 0
		and self.camPitch == 0
		and self.camYaw == 0
		and self.left <= 0
	then
		self.age += p

		if v10 then
			current.recoilPitch = 0
			current.recoilYaw = 0
			current.recoilRoll = 0
		end

		return 0, 0, 0
	else
		local profile = self.profile
		self.spare = math.min(self.spare + p, 0.1)

		while self.spare >= 1 / 120 do
			self.spare -= 1 / 120
			self.age += 1 / 120

			if self.left > 0 then
				local v11 = math.min(1 / 120, self.left)
				add(self, self.pendPitch * v11 / 0.025, self.pendYaw * v11 / 0.025) -- inferred equivalent call
				self.left -= v11
			end

			local v11 = math.sqrt(self.rawPitch * self.rawPitch + self.rawYaw * self.rawYaw)

			if v11 > 0 then
				local v12 = math.max(0, v11 - (profile.back * v11 * self.age ^ profile.curve + 0.06) * (1 / 120))
				self.rawPitch *= v12 / v11
				self.rawYaw *= v12 / v11
			end

			if self.held then
				self.pitch += (self.rawPitch - self.pitch) * 0.18806365384936496
				self.yaw += (self.rawYaw - self.yaw) * 0.18806365384936496
			else
				local rawPitch = self.rawPitch
				local rawYaw = self.rawYaw
				self.pitch = rawPitch
				self.yaw = rawYaw
			end

			local v12 = self.age > 0.1
			local v13 = v12 and 200 or 1500
			local v14 = (1 - (v12 and 0.42 or 0.5)) ^ ((v12 and 30 or 50) * (1 / 120))
			self.velPitch = (self.velPitch - self.dipPitch * v13 * (1 / 120)) * v14
			self.velYaw = (self.velYaw - self.dipYaw * v13 * (1 / 120)) * v14
			self.dipPitch += self.velPitch * (1 / 120)
			self.dipYaw += self.velYaw * (1 / 120)
		end

		if self.rawPitch == 0 and self.rawYaw == 0 and math.abs(self.pitch) < 0.005 and math.abs(self.yaw) < 0.005 then
			self.pitch = 0
			self.yaw = 0
		end

		if
			math.abs(self.dipPitch) < 0.005
			and math.abs(self.dipYaw) < 0.005
			and math.abs(self.velPitch) < 0.05
			and math.abs(self.velYaw) < 0.05
		then
			self.dipPitch = 0
			self.dipYaw = 0
			self.velPitch = 0
			self.velYaw = 0
		end

		local v11 = math.max(0, 1 - self.rollAge / 0.1)
		local camPitch = self.pitch + self.dipPitch
		local camYaw = self.yaw + self.dipYaw
		local recoilRoll = self.roll * v11 * v11

		if v10 and not current.spec.scope then
			local v12 = math.clamp(current.aimAlpha or 1, 0, 1)
			local v13 = (1 - cameraShare(current.spec.aimFov or 55)) * v12
			local v14 = 1 - math.exp(-p / 0.1)
			self.camPitch += (self.pitch * (1 - v13) - self.camPitch) * v14
			self.camYaw += (self.yaw * (1 - v13) - self.camYaw) * v14

			if
				self.pitch == 0
				and self.yaw == 0
				and math.abs(self.camPitch) < 0.005
				and math.abs(self.camYaw) < 0.005
			then
				self.camPitch = 0
				self.camYaw = 0
			end

			local recoilPitch = camPitch - self.camPitch
			local recoilYaw = camYaw - self.camYaw
			current.recoilPitch = recoilPitch
			current.recoilYaw = recoilYaw
			current.recoilRoll = recoilRoll
			return self.camPitch, self.camYaw, 0
		end

		self.camPitch = camPitch
		self.camYaw = camYaw
		return camPitch, camYaw, recoilRoll
	end
end

function GunRecoil.cool(p, p2: number, p3: number, p4: number)
	if p.age < 0.15 then
		return (math.max(0, p2 - (p2 ^ 2.5 * 1.2 + p3 * 0.1) * p4))
	end

	return (math.max(0, p2 - p3 * 1.44 * p4))
end

function GunRecoil.coolExact(p, p2: number, data, p3: number)
	local v10 = data.rest

	if p.age >= data.idleAfter then
		v10 = data.idle
	elseif p.age < data.fireFor + p3 then
		v10 = data.fire[1] * p2 ^ data.fire[2] + data.fire[3]
	end

	return (math.max(0, p2 - v10 * p3))
end

return GunRecoil