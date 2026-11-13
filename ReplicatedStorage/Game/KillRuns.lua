local KillRuns = {}
KillRuns.MIN = 5
KillRuns.CALLS = { 5 }
KillRuns.EVERY = 5
local v = { "ON A ROLL" }

function KillRuns.called(p: number): boolean
	local v2 = KillRuns.CALLS[#KillRuns.CALLS]

	if v2 < p then
		return (p - v2) % KillRuns.EVERY == 0
	end

	return table.find(KillRuns.CALLS, p) ~= nil
end

function KillRuns.title(p: number)
	local v2 = 1

	for k, v3 in KillRuns.CALLS do
		if v3 <= p then
			v2 = k
		end
	end

	return v[v2], v2
end

return KillRuns