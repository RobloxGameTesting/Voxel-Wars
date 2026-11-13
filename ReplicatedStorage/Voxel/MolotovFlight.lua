--!native
local GrenadeFlight = require(script.Parent:WaitForChild("GrenadeFlight"))

local MolotovFlight = {
	["STEP"] = GrenadeFlight.STEP,
	MAX_FLIGHT = 6,
	CARRY = GrenadeFlight.CARRY,
	launch = function(vector3: Vector3, flag: boolean, vector3_2: Vector3)
		return GrenadeFlight.launch(vector3, flag, vector3_2)
	end,
	maxLaunch = function()
		return GrenadeFlight.maxLaunch()
	end,
	scale = function()
		return GrenadeFlight.scale()
	end,
	new = function(vector3: Vector3, vector3_2: Vector3)
		local v = GrenadeFlight.new(vector3, vector3_2)
		v.broken = false
		return v
	end
}

local v = nil
local v2 = nil
local function traced(vector3: Vector3, vector3_2: Vector3, p: number)
	local v3, v4, v5, v6 = v(vector3, vector3_2, p)
	v2 = v6
	return v3, v4, v5, v6
end

function MolotovFlight:advance(p: number, p2)
	if self.broken then
		return true, nil
	end

	v = p2
	v2 = nil

	while self.t + MolotovFlight.STEP <= p + 1e-9 do
		local touched = self.touched
		GrenadeFlight.advance(self, self.t + MolotovFlight.STEP, traced)

		if self.touched ~= touched then
			self.broken = true
			return true, v2
		end

		if self.t >= MolotovFlight.MAX_FLIGHT then
			self.broken = true
			self.normal = Vector3.new(0, 1, 0)
			return true, nil
		end
	end

	return false, nil
end

return MolotovFlight