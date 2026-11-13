local PoseTiming = {}

PoseTiming.stats = { gaps = 0, held = 0, frozen = 0, snaps = 0 }
local stats = PoseTiming.stats

function PoseTiming.stamper()
	return { who = nil, lat = 0, at = 0, last = -1e999 }
end

function PoseTiming:stamp(who, p: number, at: number)
	local lat = math.clamp(at - p, 0, 2)

	if self.who == who then
		self.lat = math.min(lat, self.lat + math.max(at - self.at, 0) * 0.1)
	else
		self.who = who
		self.lat = lat
		self.last = -1e999
	end

	self.at = at

	local last = math.clamp(p + self.lat, self.last + 0.001, (math.max(at, self.last + 0.001)))
	self.last = last
	return last
end

function PoseTiming.new()
	return {
		late = 0,
		dev = 0,
		gap = 0.05,
		lastT = nil,
		delay = nil,
		clock = os.clock(),
		step = 0,
		moving = false,
		offPos = Vector3.new(0, 0, 0),
		offRot = CFrame.identity,
		offClock = os.clock()
	}
end

function PoseTiming:observe(lastT: number, vector3: Vector3?)
	local late = workspace:GetServerTimeNow() - lastT

	if self.lastT == nil then
		self.late = late
		self.dev = 0
	else
		if self.moving and lastT - self.lastT > 0.35 then
			stats.gaps += 1
		end

		self.late += (late - self.late) * 0.08
		self.dev += (math.abs(late - self.late) - self.dev) * 0.08
		self.gap += (math.min(lastT - self.lastT, 0.5) - self.gap) * 0.08
	end

	self.lastT = lastT
	self.moving = vector3 ~= nil and vector3.Magnitude > 1
end

function PoseTiming:delay()
	local now = os.clock()
	local step = math.min(now - self.clock, 0.25)
	self.clock = now
	self.step = step
	local delay2 = math.clamp(self.late + self.dev * 2.5 + self.gap * 1.15, 0.12, 0.4)
	local delay = self.delay

	if delay ~= nil then
		if delay < delay2 then
			delay2 = math.min(delay2, delay + step * 0.6)
		else
			delay2 = math.max(delay2, delay - (delay > 0.4 and 0.15 or 0.08) * step)
		end
	end

	self.delay = delay2
	return delay2
end

function PoseTiming:drawTime(p: number, flag: boolean)
	local serverTimeNow = workspace:GetServerTimeNow()
	local v = PoseTiming.delay(self)
	local v2 = serverTimeNow - v

	if not (flag and p + 0.4 < v2) then
		return v2
	end

	if v < 1.2 then
		local delay = math.min(serverTimeNow - p - 0.4, 1.2)
		stats.held += delay - v

		self.delay = delay
		return serverTimeNow - delay
	end

	stats.frozen += self.step

	return v2
end

function PoseTiming.lead(p: number)
	if p <= 0 then
		return 0
	end

	return (1 - math.exp(-p / 0.3)) * 0.3
end

function PoseTiming.hermite(vector3: Vector3, vector3_2: Vector3, vector3_3: Vector3, vector3_4: Vector3, p: number, p2: number)
	local v = 2 * (vector3_3 - vector3).Magnitude / p + 2

	if v < vector3_2.Magnitude then
		vector3_2 = vector3_2.Unit * v
	end

	if v < vector3_4.Magnitude then
		vector3_4 = vector3_4.Unit * v
	end

	local v2 = p2 * p2
	local v3 = p2 * p2 * p2
	return vector3 * (v3 * 2 - v2 * 3 + 1) + vector3_2 * (p * (v3 - v2 * 2 + p2)) + vector3_3 * (v2 * 3 - v3 * 2) + vector3_4 * (p * (v3 - v2))
end

function PoseTiming:correct(cframe: CFrame, cframe2: CFrame)
	local v = cframe.Position - cframe2.Position

	if (self.offPos + v).Magnitude > 40 then
		local identity = CFrame.identity
		self.offPos = Vector3.new(0, 0, 0)
		self.offRot = identity
		stats.snaps += 1
	else
		self.offPos += v
		self.offRot = self.offRot * cframe.Rotation * cframe2.Rotation:Inverse()
	end
end

function PoseTiming:apply(cframe: CFrame)
	local now = os.clock()
	local v = math.exp(-math.min(now - self.offClock, 0.25) / 0.15)
	self.offClock = now

	if self.offPos.Magnitude < 0.001 and self.offRot == CFrame.identity then
		return cframe
	end

	self.offPos *= v
	self.offRot = CFrame.identity:Lerp(self.offRot, v)

	if self.offPos.Magnitude < 0.001 and math.acos((math.clamp(self.offRot.LookVector.Z * -1, -1, 1))) < 0.001 then
		local identity = CFrame.identity
		self.offPos = Vector3.new(0, 0, 0)
		self.offRot = identity
	end

	return CFrame.new(cframe.Position + self.offPos) * self.offRot * cframe.Rotation
end

return PoseTiming