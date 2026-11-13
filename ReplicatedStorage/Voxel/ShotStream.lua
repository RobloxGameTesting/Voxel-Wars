local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ShotFX = ReplicatedStorage.Voxel.Remotes:WaitForChild("ShotFX")

local v = {}

local v2 = {
	Rifle = 0,
	Pistol = 1,
	Sniper = 2,
	LMG = 3,
	SMG = 4,
	Minigun = 5,
	DMR = 6,
	Shotgun = 7,
	ShotgunPellet = 8,
	HeavyGun = 9,
	HandCannon = 10
}
local v3 = {
	[0] = nil,
	[1] = "Pistol",
	[2] = "Sniper",
	[3] = "LMG",
	[4] = "SMG",
	[5] = "Minigun",
	[6] = "DMR",
	[7] = "Shotgun",
	[8] = "ShotgunPellet",
	[9] = "HeavyGun",
	[10] = "HandCannon"
}

if RunService:IsServer() then
	local v4 = {}
	local v5 = {}
	local function assign(instance)
		for i = 1, 255 do
			if not v5[i] then
				v5[i] = true
				v4[instance] = i
				instance:SetAttribute("ShotSlot", i)
				return
			end
		end

		error("[ShotStream] more than 255 players")
	end
	Players.PlayerAdded:Connect(assign)

	for _, v6 in Players:GetPlayers() do
		assign(v6)
	end

	Players.PlayerRemoving:Connect(function(player)
		local v6 = v4[player]

		if v6 then
			v5[v6] = nil
			v4[player] = nil
		end
	end)
	local function slotOf(p) -- 2 equivalent calls inferred from this helper
		if p then
			return v4[p] or 0
		end

		return 0
	end

	local NetStats = require(script.Parent.NetStats)

	NetStats.stream(ShotFX)

	local v6 = buffer.create(4096)
	local total = 0
	local v7 = {}
	local v8 = {}
	local v9 = {}
	local v10 = {}
	local buf = buffer.create(900)
	local function fire(player, size: number)
		local buf2 = buffer.create(size)
		buffer.copy(buf2, 0, buf, 0, size)
		NetStats.count("ShotFX", size + 12, 1)
		ShotFX:FireClient(player, buf2)
	end
	local function send()
		local count = #v7

		if count == 0 then
			return
		end

		for _, v11 in Players:GetPlayers() do
			if not NetStats.hears(v11, ShotFX) then
				continue
			end

			local view = NetStats.viewOf(v11)
			local total2 = 0

			for i = 1, count do
				local v12 = v9[i]

				if not ((v12 or v10[i] ~= v11) and (not v12 or not view or v10[i] == v11 or not ((v12 - view).Magnitude > 650))) then
					continue
				end

				local v13 = v8[i]

				if total2 + v13 > 900 then
					fire(v11, total2)
					total2 = 0
				end

				buffer.copy(buf, total2, v6, v7[i], v13)
				total2 += v13
			end

			if total2 > 0 then
				fire(v11, total2)
			end
		end

		total = 0
		table.clear(v7)
		table.clear(v8)
		table.clear(v9)
		table.clear(v10)
	end
	local function room(p: number, p2, p3)
		if total + p > buffer.len(v6) then
			local buf2 = buffer.create(buffer.len(v6) * 2)
			buffer.copy(buf2, 0, v6, 0, total)
			v6 = buf2
		end

		local v11 = total
		total += p
		table.insert(v7, v11)
		table.insert(v8, p)
		table.insert(v9, p2)
		table.insert(v10, p3 or false)
		return v11
	end

	local function q(p: number) -- 3 equivalent calls inferred from this helper
		return (math.clamp(math.round(p * 16), -32768, 32767))
	end

	local function qi(p: number) -- 3 equivalent calls inferred from this helper
		return (math.clamp(math.round(p * 4096), -32768, 32767))
	end

	local function writeQ(offset: number, vector3: Vector3) -- 3 equivalent calls inferred from this helper
		buffer.writei16(v6, offset, q(vector3.X)) -- inferred equivalent call
		buffer.writei16(v6, offset + 2, q(vector3.Y)) -- inferred equivalent call
		buffer.writei16(v6, offset + 4, q(vector3.Z)) -- inferred equivalent call
	end

	function v.shot(p, vector3: Vector3, vector3_2: Vector3, value: string?)
		local v11 = v2[value or "Rifle"]
		assert(v11, "[ShotStream] unknown weapon " .. tostring(value))
		local v12 = room(15, false, p)
		buffer.writeu8(v6, v12, 1)
		buffer.writeu8(v6, v12 + 1, slotOf(p)) -- inferred equivalent call
		buffer.writeu8(v6, v12 + 2, v11)
		writeQ(v12 + 3, vector3) -- inferred equivalent call
		writeQ(v12 + 9, vector3_2) -- inferred equivalent call
	end

	function v.impact(vector3: Vector3, vector3_2: Vector3, vector3_3: Vector3, value: number, p: number, flag: boolean, p2, value2: number?, flag2: boolean?, flag3: boolean?)
		local v11 = value >= 0 and value <= 255 and value % 1 == 0
		assert(v11, "[ShotStream] palette id out of range")
		local v12 = room(22, vector3, p2)
		local v13 = (flag and 1 or 0) + (flag2 and 2 or 0) + (value2 and 4 or 0) + (flag3 and 8 or 0)
		buffer.writeu8(v6, v12, 2)
		buffer.writeu8(v6, v12 + 1, v13)
		buffer.writeu8(v6, v12 + 2, slotOf(p2)) -- inferred equivalent call
		buffer.writeu8(v6, v12 + 3, value)
		buffer.writeu8(v6, v12 + 4, (math.clamp(math.round(value2 or 0), 0, 255)))
		buffer.writeu16(v6, v12 + 5, (math.clamp(math.round(p * 100), 0, 65535)))
		writeQ(v12 + 7, vector3) -- inferred equivalent call
		local v14 = not (vector3_2.Magnitude > 1e-6) and Vector3.new(0, 1, 0) or vector3_2.Unit
		buffer.writei8(v6, v12 + 13, (math.round(v14.X * 127)))
		buffer.writei8(v6, v12 + 14, (math.round(v14.Y * 127)))
		buffer.writei8(v6, v12 + 15, (math.round(v14.Z * 127)))
		buffer.writei16(v6, v12 + 16, qi(vector3_3.X)) -- inferred equivalent call
		buffer.writei16(v6, v12 + 18, qi(vector3_3.Y)) -- inferred equivalent call
		buffer.writei16(v6, v12 + 20, qi(vector3_3.Z)) -- inferred equivalent call
	end

	v.flush = send
	return v
else
	local v4 = {}
	local v5 = {}

	local v6 = {}

	local Detail = require(script.Parent:WaitForChild("Detail"))

	local v7 = {}
	local v8 = 1
	local count = 0
	RunService.Heartbeat:Connect(function()
		if count < v8 then
			return
		end

		for _ = 1, math.max(4, (math.ceil((count - v8 + 1) / 4))) do
			local v9 = v7[v8]

			if v9 == nil then
				break
			end

			v7[v8] = nil
			v8 += 1

			for _, v10 in v5 do
				v10(v9.pos, v9.n, v9.incoming, v9.pal, v9.radius, v9.broke, v9.shooter, v9.removed, v9.ground, v9.body)
			end
		end

		if count < v8 then
			v8 = 1
			count = 0
		end
	end)
	local set = {}
	local function playerOf(p: number)
		if p == 0 then
			return nil
		end

		local v9 = v6[p]

		if v9 and set[p] then
			return v9
		end

		if v9 and v9.Parent and v9:GetAttribute("ShotSlot") == p then
			set[p] = true
			return v9
		end

		table.clear(set)
		table.clear(v6)

		for _, v10 in Players:GetPlayers() do
			local shotSlot = v10:GetAttribute("ShotSlot")

			if typeof(shotSlot) == "number" then
				v6[shotSlot] = v10
			end
		end

		return v6[p]
	end

	local function readQ(buf: buffer, offset: number) -- 3 equivalent calls inferred from this helper
		return Vector3.new(
			buffer.readi16(buf, offset),
			buffer.readi16(buf, offset + 2),
			(buffer.readi16(buf, offset + 4))
		) / 16
	end

	local NetStats = require(script.Parent.NetStats)
	NetStats.listen(ShotFX, function(buf: buffer)
		table.clear(set)
		local v9 = buffer.len(buf)
		local total = 0

		while total < v9 do
			local v10 = buffer.readu8(buf, total)

			if v10 == 1 then
				local v11 = playerOf(buffer.readu8(buf, total + 1))
				local v12 = v3[buffer.readu8(buf, total + 2)]
				local q = readQ(buf, total + 3) -- inferred equivalent call
				local q2 = readQ(buf, total + 9) -- inferred equivalent call
				total += 15

				for _, v13 in v4 do
					v13(v11, q, q2, v12)
				end
			elseif v10 == 2 then
				local v11 = buffer.readu8(buf, total + 1)
				local shooter = playerOf(buffer.readu8(buf, total + 2))
				local pal = buffer.readu8(buf, total + 3)
				local removed

				if bit32.btest(v11, 4) then
					removed = buffer.readu8(buf, total + 4)
				end

				local radius = buffer.readu16(buf, total + 5) / 100
				local pos = readQ(buf, total + 7) -- inferred equivalent call
				local vector3 = Vector3.new(
					buffer.readi8(buf, total + 13),
					buffer.readi8(buf, total + 14),
					(buffer.readi8(buf, total + 15))
				)
				local v12 = not (vector3.Magnitude > 0) and Vector3.new(0, 1, 0) or vector3.Unit
				local incoming = Vector3.new(
					buffer.readi16(buf, total + 16),
					buffer.readi16(buf, total + 18),
					(buffer.readi16(buf, total + 20))
				) / 4096
				local broke = bit32.btest(v11, 1)
				local v13 = bit32.btest(v11, 2)
				local v14 = bit32.btest(v11, 8)
				total += 22

				if Detail.low then
					count += 1
					v7[count] = {
						pos = pos,
						n = v12,
						incoming = incoming,
						pal = pal,
						radius = radius,
						broke = broke,
						shooter = shooter,
						removed = removed,
						ground = v13 and true or nil,
						body = v14 and true or nil
					}
				else
					for _, v15 in v5 do
						v15(
							pos,
							v12,
							incoming,
							pal,
							radius,
							broke,
							shooter,
							removed,
							v13 and true or nil,
							v14 and true or nil
						)
					end
				end
			else
				error("[ShotStream] bad record tag " .. v10 .. " at byte " .. total)
			end
		end
	end)

	function v.onShot(callback)
		table.insert(v4, callback)
	end
	function v.onImpact(callback)
		table.insert(v5, callback)
	end

	return v
end