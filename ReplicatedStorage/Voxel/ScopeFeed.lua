local ScopeFeed = { bots = {}, wake = nil }

function ScopeFeed.bot(p: number, pos: Vector3, yaw: number, pitch: number)
	local bot = ScopeFeed.bots[p]

	if bot then
		local now = os.clock()
		bot.pos = pos
		bot.yaw = yaw
		bot.pitch = pitch
		bot.at = now
	else
		ScopeFeed.bots[p] = { pos = pos, yaw = yaw, pitch = pitch, at = os.clock() }
	end

	local wake = ScopeFeed.wake

	if wake then
		wake()
	end
end

return ScopeFeed