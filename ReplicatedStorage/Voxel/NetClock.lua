local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local clockProbe = ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("Remotes"):WaitForChild("ClockProbe")

local v = {}

if RunService:IsServer() then
	local v2 = {}
	local function clockOf(p)
		local v3 = v2[p]

		if not v3 then
			v3 = {
				up = nil,
				upDev = 0.02,
				down = nil,
				interp = 0.125,
				n = 0,
				upSum = 0,
				downSum = 0,
				pingSum = 0,
				shots = 0,
				capped = 0,
				predBot = 0,
				missBot = 0,
				predPlayer = 0,
				missPlayer = 0
			}

			v2[p] = v3
		end

		return v3
	end

	clockProbe.OnServerEvent:Connect(function(p, buf)
		if typeof(buf) ~= "buffer" or buffer.len(buf) ~= 16 then
			return
		end

		local v3 = buffer.readf64(buf, 0)
		local v4 = workspace:GetServerTimeNow() - v3

		if v3 ~= v3 or v4 < -0.5 or v4 > 3 then
			return
		end

		local up = math.max(v4, 0)
		local v5 = buffer.readu16(buf, 8) / 1000
		local v6 = clockOf(p)

		if v6.up then
			v6.upDev += (math.abs(up - v6.up) - v6.upDev) * 0.2
			v6.up += (up - v6.up) * 0.2
		else
			v6.up = up
		end

		local down

		if v5 > 0 then
			down = math.min(v5, 3)
		else
			down = v6.down
		end

		v6.down = down
		v6.interp = math.clamp(buffer.readu16(buf, 10) / 1000, 0.03, 0.3)
		v6.n += 1
		v6.upSum += up
		v6.downSum += v6.down or 0
		local success, networkPing = pcall(p.GetNetworkPing, p)
		v6.pingSum += (not success or type(networkPing) ~= "number") and 0 or networkPing
		v6.predBot += buffer.readu8(buf, 12)
		v6.missBot += buffer.readu8(buf, 13)
		v6.predPlayer += buffer.readu8(buf, 14)
		v6.missPlayer += buffer.readu8(buf, 15)
	end)
	Players.PlayerRemoving:Connect(function(player)
		v2[player] = nil
	end)

	function v.upload(object, value)
		local v3 = v2[object]

		if typeof(value) == "number" and value == value then
			local v4 = workspace:GetServerTimeNow() - value

			if v4 >= -0.05 and v4 <= 1 then
				local v5 = math.max(v4, 0)

				if v3 and v3.up then
					return (math.min(v5, v3.up + v3.upDev * 3 + 0.05))
				end

				return v5
			end
		end

		if v3 and v3.up then
			return v3.up
		end

		return object:GetNetworkPing()
	end

	local function capped(p, p2: number, p3: number) -- 2 equivalent calls inferred from this helper
		local v3 = clockOf(p)
		v3.shots += 1

		if p3 < p2 then
			v3.capped += 1
			return p3
		end

		return (math.max(p2, 0))
	end

	function v.botRewind(p, p2, p3: number)
		local v3 = v2[p]
		return capped(p, v.upload(p, p2) + (not v3 and 0.125 or v3.interp), p3) -- inferred equivalent call
	end

	function v.playerRewind(p, p2, p3: number, p4: number)
		local upload = v.upload(p, p2)
		local v3 = v2[p]
		local v4 = if v3 and v3.down then v3.down else upload
		return capped(p, upload + v4 + p3, p4) -- inferred equivalent call
	end

	local v3 = { player = nil, fired = nil }
	function v.shooting(player, fired)
		v3.player = player
		v3.fired = fired
	end
	function v.stampOf(p)
		return if v3.player == p then v3.fired else nil
	end

	function v.takeStats()
		local result = {}

		for k, v4 in v2 do
			if v4.n > 0 or v4.shots > 0 then
				result[k] = {
					n = v4.n,
					up = not (v4.n > 0) and 0 or v4.upSum / v4.n,
					down = not (v4.n > 0) and 0 or v4.downSum / v4.n,
					ping = not (v4.n > 0) and 0 or v4.pingSum / v4.n,
					shots = v4.shots,
					capped = v4.capped,
					predBot = v4.predBot,
					missBot = v4.missBot,
					predPlayer = v4.predPlayer,
					missPlayer = v4.missPlayer
				}
			end

			v4.n = 0
			v4.upSum = 0
			v4.downSum = 0
			v4.pingSum = 0
			v4.shots = 0
			v4.capped = 0
			v4.predBot = 0
			v4.missBot = 0
			v4.predPlayer = 0
			v4.missPlayer = 0
		end

		return result
	end

	return v
else
	local v2 = nil
	v.botInterp = 0.125
	local v3 = { 0, 0, 0, 0 }

	function v.arrived(p: number)
		local v4 = workspace:GetServerTimeNow() - p

		if v4 >= 0 and v4 < 3 then
			if v2 then
				v4 = v2 + (v4 - v2) * 0.05
			end

			v2 = v4
		end
	end

	function v.stamp()
		return workspace:GetServerTimeNow()
	end

	function v.predicted(p: string)
		local v4 = p == "bot" and 1 or 3
		v3[v4] += 1
	end
	function v.unconfirmed(p: string)
		local v4 = p == "bot" and 2 or 4
		v3[v4] += 1
	end

	task.spawn(function()
		while true do
			task.wait(0.5)
			local buf = buffer.create(16)
			buffer.writef64(buf, 0, (workspace:GetServerTimeNow()))
			buffer.writeu16(buf, 8, (math.clamp(math.round((v2 or 0) * 1000), 0, 65535)))
			buffer.writeu16(buf, 10, (math.clamp(math.round(v.botInterp * 1000), 0, 65535)))

			buffer.writeu8(buf, 12, (math.min(v3[1], 255)))
			v3[1] = 0
			buffer.writeu8(buf, 13, (math.min(v3[2], 255)))
			v3[2] = 0
			buffer.writeu8(buf, 14, (math.min(v3[3], 255)))
			v3[3] = 0
			buffer.writeu8(buf, 15, (math.min(v3[4], 255)))
			v3[4] = 0

			clockProbe:FireServer(buf)
		end
	end)

	return v
end