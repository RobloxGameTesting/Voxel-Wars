local SeatedBots = {}
SeatedBots.hook = nil
local nows = {}

function SeatedBots.place(p: number, cframe: CFrame, p2: number, p3, vector3: Vector3, p4: number)
	nows[p] = os.clock()
	local hook = SeatedBots.hook

	if hook then
		hook(p, cframe, p2, p3, vector3, p4)
	end
end

function SeatedBots.seated(p: number, p2: number?): boolean
	local v = nows[p]
	return v ~= nil and (p2 or os.clock()) - v < 0.25
end

return SeatedBots