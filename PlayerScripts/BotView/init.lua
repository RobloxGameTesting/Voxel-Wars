--!native
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Teams = game:GetService("Teams")

local BotRig = require(script:WaitForChild("BotRig"))
local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local NetStats = require(Voxel:WaitForChild("NetStats"))
local Tracers = require(Voxel:WaitForChild("Tracers"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local SniperTrace = require(ReplicatedStorage2:WaitForChild("Voxel"):WaitForChild("SniperTrace"))
local Ballistics = require(Voxel:WaitForChild("Ballistics"))
local VoxelSound = require(Voxel:WaitForChild("VoxelSound"))

local Detail = require(Voxel:WaitForChild("Detail"))
local SeatedBots = require(ReplicatedStorage:WaitForChild("Vehicles"):WaitForChild("SeatedBots"))
local NetClock = require(Voxel:WaitForChild("NetClock"))
local ScopeFeed = require(Voxel:WaitForChild("ScopeFeed"))

local LocalPlayer = Players.LocalPlayer
local Bots = ReplicatedStorage:WaitForChild("Bots")
local Roster = Bots:WaitForChild("Roster")

local total = 0.125
local v = { mean = 0.024999999999999994, dev = 0.01 }
NetClock.botInterp = total

local botRigs = Instance.new("Folder")
botRigs.Name = "BotRigs"
botRigs.Parent = workspace

local v2 = {}

local v3 = { Reds = Color3.fromRGB(196, 72, 60), Blues = Color3.fromRGB(70, 118, 196) }

local function teamColor(team: string) -- 3 equivalent calls inferred from this helper
	local child = Teams:FindFirstChild(team)

	if child then
		return child.TeamColor.Color
	end

	return v3[team] or Color3.new(0.7, 0.7, 0.7)
end

local v4

if LocalPlayer.Team then
	v4 = LocalPlayer.Team.Name
else
	v4 = nil
end

local function friendly(team: string): boolean -- 6 equivalent calls inferred from this helper
	return v4 ~= nil and v4 == team
end

local v5 = 0
local lastTime = -1e999
local bindableEvent = Instance.new("BindableEvent")

local function build(state) -- 2 equivalent calls inferred from this helper
	state.token += 1
	local token = state.token
	task.spawn(function()
		local avatar = state.entry:WaitForChild("Avatar", 10)

		if not avatar then
			warn("[BotView] bot " .. state.id .. " has no avatar description")
			return
		end

		while true do
			if v5 >= (Detail.low and 1 or 4) then
				bindableEvent.Event:Wait()
			elseif Detail.low and os.clock() - lastTime < 0.3 then
				task.wait(0.3 - (os.clock() - lastTime))
			else
				break
			end
		end

		if v2[state.id] ~= state or state.token ~= token then
			return
		end

		v5 += 1
		local build2 = BotRig.build
		local success, result = pcall(build2, avatar, teamColor(state.team), friendly(state.team)) -- inferred equivalent call
		v5 -= 1
		lastTime = os.clock()
		bindableEvent:Fire()

		if not success then
			error(result, 0)
		end

		if not result then
			return
		end

		if v2[state.id] ~= state or state.token ~= token then
			BotRig.destroy(result)
			return
		end

		debug.profilebegin("BV.setup")

		BotRig.setLook(result, teamColor(state.team), friendly(state.team)) -- inferred equivalent call
		result.model.Name = state.entry:GetAttribute("Name") or "Bot" .. state.id
		result.model:SetAttribute("BotId", state.id)
		result.model:SetAttribute("Team", state.team)
		result.model:SetAttribute("Alive", state.alive and state.deathT == nil)

		result.model:SetAttribute("Protected", state.entry:GetAttribute("Protected") == true)

		result.model:SetAttribute("Burning", state.entry:GetAttribute("Burning"))
		BotRig.setStyle(
			result,
			tonumber(state.entry:GetAttribute("Style")) or state.id,
			tonumber(state.entry:GetAttribute("Mood")) or 0
		)
		BotRig.setGun(result, (tostring(state.entry:GetAttribute("Gun") or "rifle")))
		BotRig.setAA(result, state.entry:GetAttribute("AA") == true)
		state.sniper = state.entry:GetAttribute("Gun") == "sniper"
		debug.profileend()

		if v2[state.id] ~= state or state.token ~= token then
			BotRig.destroy(result)
			return
		end

		if state.rig then
			BotRig.destroy(state.rig)
			state.diedAt = nil
		end

		state.rig = result
		state.posed = false
	end)
end

local function refreshLook(p) -- 2 equivalent calls inferred from this helper
	if p.rig then
		BotRig.setLook(p.rig, teamColor(p.team), friendly(p.team)) -- inferred equivalent call
		p.rig.model:SetAttribute("Team", p.team)
	end
end

local function setAlive(state, alive: boolean)
	state.alive = alive

	if alive then
		state.diedAt = nil
		state.deathT = nil
		state.deathDir = nil
		state.posed = false
		table.clear(state.snaps)

		if state.rig then
			BotRig.revive(state.rig)
			BotRig.park(state.rig)
			state.rig.model:SetAttribute("Alive", true)
			BotRig.setStyle(
				state.rig,
				tonumber(state.entry:GetAttribute("Style")) or state.id,
				tonumber(state.entry:GetAttribute("Mood")) or 0
			)
		end
	end
end

local function kill(state, vector3: Vector3?) -- 2 equivalent calls inferred from this helper
	local rig = state.rig

	if state.diedAt then
		if vector3 and rig and rig.dying and os.clock() - state.diedAt < 0.3 then
			BotRig.redirect(rig, vector3)
		end
	else
		state.alive = false
		state.deathT = nil
		state.corpseAt = nil
		state.slide = nil

		if rig then
			rig.model:SetAttribute("Alive", false)
		end

		if rig and rig.model.Parent then
			state.diedAt = os.clock()
			BotRig.die(rig, vector3)
		end
	end
end

local function scheduleDeath(state, p: number, unit: Vector3?) -- 1 equivalent call inferred from this helper
	if state.diedAt then
		kill(state, unit)
		return
	end

	if not state.alive then
		return
	end

	if unit then
		state.deathDir = unit
	end

	state.deathT = math.min(state.deathT or p, p)

	if state.rig then
		state.rig.model:SetAttribute("Alive", false)
	end
end

local function addEntry(configuration)
	if not configuration:IsA("Configuration") then
		return
	end

	local id = configuration:GetAttribute("Id")
	local v6 = {
		id = id,
		entry = configuration,
		team = configuration:GetAttribute("Team"),
		rig = nil,
		token = 0,
		snaps = {},
		alive = configuration:GetAttribute("Alive") == true,
		diedAt = nil,
		scratch = {
			t = 0,
			pos = Vector3.new(0, 0, 0),
			yaw = 0,
			pitch = 0,
			crouch = 0,
			lean = 0,
			flags = 0,
			head = 0
		}
	}

	v2[id] = v6
	configuration:GetAttributeChangedSignal("Alive"):Connect(function()
		if configuration:GetAttribute("Alive") == true then
			if not v6.alive then
				setAlive(v6, true)
			end
		elseif v6.alive then
			local snaps = v6.snaps

			if #snaps == 0 then
				kill(v6) -- inferred equivalent call
			else
				local v7 = v6
				local t = snaps[#snaps].t

				if v7.diedAt then
					kill(v7) -- inferred equivalent call
				else
					if not v7.alive then
						return
					end

					v7.deathT = math.min(v7.deathT or t, t)

					if v7.rig then
						v7.rig.model:SetAttribute("Alive", false)
					end
				end
			end
		end
	end)
	configuration:GetAttributeChangedSignal("Protected"):Connect(function()
		if v6.rig then
			v6.rig.model:SetAttribute("Protected", configuration:GetAttribute("Protected") == true)
		end
	end)
	configuration:GetAttributeChangedSignal("Burning"):Connect(function()
		if v6.rig then
			v6.rig.model:SetAttribute("Burning", configuration:GetAttribute("Burning"))
		end
	end)
	configuration:GetAttributeChangedSignal("Gun"):Connect(function()
		local rig = v6.rig

		if rig then
			task.spawn(BotRig.setGun, rig, (tostring(configuration:GetAttribute("Gun") or "rifle")))
		end

		v6.sniper = configuration:GetAttribute("Gun") == "sniper"
	end)
	configuration:GetAttributeChangedSignal("AA"):Connect(function()
		local rig = v6.rig

		if rig then
			task.spawn(BotRig.setAA, rig, configuration:GetAttribute("AA") == true)
		end
	end)
	configuration:GetAttributeChangedSignal("Team"):Connect(function()
		v6.team = configuration:GetAttribute("Team")
		refreshLook(v6) -- inferred equivalent call
	end)
	configuration.ChildAdded:Connect(function(humanoidDescription)
		if humanoidDescription.Name == "Avatar" and humanoidDescription:IsA("HumanoidDescription") then
			build(v6) -- inferred equivalent call
		end
	end)
	build(v6) -- inferred equivalent call
end

local function removeEntry(p)
	for k, v6 in v2 do
		if v6.entry ~= p then
			continue
		end

		v6.token += 1

		if v6.rig then
			BotRig.destroy(v6.rig)
			v6.rig = nil
		end

		v2[k] = nil
	end
end

for _, child in Roster:GetChildren() do
	addEntry(child)
end

Roster.ChildAdded:Connect(addEntry)
Roster.ChildRemoved:Connect(removeEntry)

LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function()
	local v6

	if LocalPlayer.Team then
		v6 = LocalPlayer.Team.Name
	end

	v4 = v6

	for _, v7 in v2 do
		refreshLook(v7) -- inferred equivalent call
	end
end)

local v6 = -1
NetStats.listen(Bots:WaitForChild("State"), function(buf: buffer)
	local v7 = buffer.readu16(buf, 0)

	if v6 >= 0 then
		local v8 = (v7 - v6) % 65536

		if v8 == 0 or v8 > 32768 then
			return
		end
	end

	v6 = v7
	local v8 = buffer.readf64(buf, 2)
	NetClock.arrived(v8)
	local v9 = workspace:GetServerTimeNow() - v8

	if v9 > -1 and v9 < 2 then
		v.dev += (math.abs(v9 - v.mean) - v.dev) * 0.1
		v.mean += (v9 - v.mean) * 0.05
	end

	local v10 = buffer.readu8(buf, 10)

	local vector3 = Vector3.new(buffer.readi16(buf, 11) * 16, 0, buffer.readi16(buf, 13) * 16)
	local total2 = 15

	for _ = 1, v10 do
		local v11 = v2[buffer.readu8(buf, total2)]

		if v11 then
			local flags = buffer.readu8(buf, total2 + 1)
			local pos = Vector3.new(
				buffer.readi16(buf, total2 + 2),
				buffer.readi16(buf, total2 + 4),
				(buffer.readi16(buf, total2 + 6))
			) / 50 + vector3
			local yaw = buffer.readu16(buf, total2 + 8) / 65535 * 2 * 3.141592653589793
			local pitch = math.rad((buffer.readi8(buf, total2 + 10)))
			local crouch = buffer.readu8(buf, total2 + 11) / 255
			local lean = buffer.readi8(buf, total2 + 12) / 100
			local head = math.rad((buffer.readi8(buf, total2 + 13)))
			local snaps = v11.snaps
			local v12

			if #snaps >= 12 then
				v12 = table.remove(snaps, 1)
				v12.t = v8
				v12.flags = flags
				v12.pos = pos
				v12.yaw = yaw
				v12.pitch = pitch
				v12.crouch = crouch
				v12.lean = lean
				v12.head = head
			else
				v12 = {
					t = v8,
					flags = flags,
					pos = pos,
					yaw = yaw,
					pitch = pitch,
					crouch = crouch,
					lean = lean,
					head = head
				}
			end

			table.insert(snaps, v12)
		end

		total2 += 14
	end
end)

local function angleLerp(yaw: number, yaw2: number, p: number) -- 1 equivalent call inferred from this helper
	return yaw + ((yaw2 - yaw + 3.141592653589793) % 6.283185307179586 - 3.141592653589793) * p
end

@native local function sample(snaps, p: number, scratch)
	local count = #snaps

	if count == 0 then
		return nil, Vector3.new(0, 0, 0)
	end

	if p <= snaps[1].t then
		return snaps[1], Vector3.new(0, 0, 0)
	end

	for i = count, 2, -1 do
		local item = snaps[i - 1]
		local item2 = snaps[i]

		if not (item.t <= p) then
			continue
		end

		local v7 = math.max(item2.t - item.t, 0.0001)
		local vector3 = (item2.pos - item.pos) / v7
		local selected = vector3.Magnitude > 120 and Vector3.new(0, 0, 0) or vector3

		if item2.t <= p then
			local v8 = p - item2.t

			if not (selected.Magnitude > 0.5) then
				return item2, Vector3.new(0, 0, 0)
			end

			local v9 = v8 < 0.1
			scratch.t = p
			scratch.flags = item2.flags
			scratch.pos = item2.pos + selected * (not v9 and 0.1 or v8)
			scratch.yaw = item2.yaw
			scratch.pitch = item2.pitch
			scratch.crouch = item2.crouch
			scratch.lean = item2.lean
			scratch.head = item2.head
			scratch.ex = true

			if v9 or v8 < 0.15 then
				return scratch, selected
			end

			return scratch, Vector3.new(0, 0, 0)
		else
			local v8 = (p - item.t) / v7
			scratch.t = p
			scratch.flags = item2.flags
			scratch.pos = item.pos:Lerp(item2.pos, v8)
			scratch.yaw = angleLerp(item.yaw, item2.yaw, v8) -- inferred equivalent call
			scratch.pitch = item.pitch + (item2.pitch - item.pitch) * v8
			scratch.crouch = item.crouch + (item2.crouch - item.crouch) * v8
			scratch.lean = item.lean + (item2.lean - item.lean) * v8
			scratch.head = item.head + (item2.head - item.head) * v8
			scratch.ex = nil
			return scratch, selected
		end
	end

	return snaps[count], Vector3.new(0, 0, 0)
end

local v7 = {}
local v8 = {}

local v9 = {}
local function playShot(data, to: Vector3, gun: number)
	if data and data.alive and data.rig and data.rig.model.Parent then
		local muzzlePos = BotRig.muzzlePos(data.rig)

		if gun == 3 then
			BotRig.fired(data.rig, to, 0.5)
			local v10 = (v9[data.id] or 0) + 1
			v9[data.id] = v10

			if v10 % 2 == 0 then
				Tracers.fire(muzzlePos, to, nil, nil, true)
			end

			VoxelSound.minigunShot("bot" .. data.id, muzzlePos, to)
		elseif gun == 7 then
			Tracers.fire(muzzlePos, to)
		elseif gun == 6 then
			BotRig.fired(data.rig, to, 2)
			Tracers.fire(muzzlePos, to)
			VoxelSound.shot(muzzlePos, 1.5, to, "Shotgun")
		elseif gun == 5 then
			BotRig.fired(data.rig, to, 1.6)
			Tracers.fire(muzzlePos, to, Ballistics.DMR_SPEED, nil, true)
			VoxelSound.shot(muzzlePos, 1.3, to, "DMR")
		elseif gun == 4 then
			BotRig.fired(data.rig, to, 0.8)
			Tracers.fire(muzzlePos, to)
			VoxelSound.shot(muzzlePos, 0.85, to, "SMG")
		elseif gun == 2 then
			BotRig.fired(data.rig, to, 2.2)
			SniperTrace.fire(muzzlePos, to, Ballistics.flightTime((to - muzzlePos).Magnitude), 0.8, Ballistics.BOT_ARC)
			VoxelSound.shot(muzzlePos, 1.5, to, "Sniper")
		elseif gun == 1 then
			BotRig.fired(data.rig, to, 1.1)
			Tracers.fire(muzzlePos, to, nil, nil, true)
			VoxelSound.shot(muzzlePos, 1.1, to, "LMG")
		else
			BotRig.fired(data.rig, to)
			Tracers.fire(muzzlePos, to)
			VoxelSound.shot(muzzlePos, 1, to)
		end
	end
end

NetStats.listen(Bots:WaitForChild("Shots"), function(buf: buffer)
	local v10 = buffer.readf64(buf, 0)
	local vector3 = Vector3.new(buffer.readi16(buf, 8) * 16, 0, buffer.readi16(buf, 10) * 16)

	for i = 0, (buffer.len(buf) - 12) // 8 - 1 do
		local v11 = i * 8 + 12
		local id = buffer.readu8(buf, v11)
		local to = Vector3.new(
			buffer.readi16(buf, v11 + 1),
			buffer.readi16(buf, v11 + 3),
			(buffer.readi16(buf, v11 + 5))
		) / 16 + vector3
		local gun = buffer.readu8(buf, v11 + 7) // 2
		local v12 = table.remove(v8)

		if v12 then
			v12.t = v10
			v12.id = id
			v12.to = to
			v12.gun = gun
		else
			v12 = { t = v10, id = id, to = to, gun = gun }
		end

		table.insert(v7, v12)
	end
end)

Bots:WaitForChild("Event").OnClientEvent:Connect(function(p: string, p2: number, p3, p4, p5)
	local v10 = v2[p2]

	if not v10 then
		return
	end

	if p == "died" then
		local vector3 = Vector3.new(tonumber(p3) or 0, 0, tonumber(p4) or 0)
		local v11 = tonumber(p5)
		local unit

		if vector3.Magnitude > 0.001 then
			unit = vector3.Unit
		end

		if not v11 then
			kill(v10, unit)
			return
		end

		scheduleDeath(v10, v11, unit) -- inferred equivalent call
	elseif p == "throw" and v10.rig and v10.alive then
		BotRig.throw(v10.rig)
	end
end)

local count = 0

local v10 = Vector3.new(0, 0, 0)
local v11 = Vector3.new(0, 0, 1)
local v12 = 3.141592653589793

local function offScreen(vector: Vector3, magnitude: number, vector3: Vector3, p: number): boolean -- 2 equivalent calls inferred from this helper
	if magnitude <= 25 or p >= 3.141592653589793 then
		return false
	end

	return math.acos((math.clamp(vector:Dot(vector3) / magnitude, -1, 1))) > p + math.asin(25 / magnitude)
end

local function moveEvery(flag: boolean, flag2: boolean, flag3: boolean): number
	if flag2 then
		return if flag3 then 3 else 6
	else
		return if flag then 3 else 1
	end
end

local v13 = {
	[0] = 160,
	120,
	90,
	60
}

local SightRay = require(Voxel:WaitForChild("SightRay"))
local v14 = 0

local v15 = Voxel:GetAttribute("TeamCull") ~= false
Voxel:GetAttributeChangedSignal("TeamCull"):Connect(function()
	v15 = Voxel:GetAttribute("TeamCull") ~= false
end)

local function teamBlocked(state, vector3: Vector3)
	if state.sightFrame == count then
		return state.sightHit
	end

	local voxelWorld = workspace:FindFirstChild("VoxelWorld")
	local sightHit

	if voxelWorld == nil then
		sightHit = false
	else
		sightHit = SightRay.blocked(voxelWorld, v10, vector3 + Vector3.new(0, 2, 0))
	end

	state.sightFrame = count
	state.sightHit = sightHit
	return sightHit
end

local function teamSight(state, rig, vector: Vector3, magnitude: number, p: number)
	if Detail.low and friendly(state.team) then -- inferred equivalent call
		local teamHidden = rig.teamHidden == true
		local v16

		if magnitude <= 60 then
			v16 = false
		elseif v13[Detail.strain] * (teamHidden and 0.9 or 1) < magnitude and v15 then
			v16 = true
		elseif p % 8 == 0 then
			if workspace:FindFirstChild("VoxelWorld") and v15 then
				local sightHit

				if state.sightFrame == count then
					sightHit = state.sightHit
				else
					local voxelWorld = workspace:FindFirstChild("VoxelWorld")

					if voxelWorld == nil then
						sightHit = false
					else
						sightHit = SightRay.blocked(voxelWorld, v10, vector + Vector3.new(0, 2, 0))
					end

					state.sightFrame = count
					state.sightHit = sightHit
				end

				state.teamBlocked = not sightHit and 0 or (state.teamBlocked or 0) + 1
				v16 = state.teamBlocked >= 2
			else
				v16 = false
			end
		else
			v16 = teamHidden
		end

		if v16 ~= teamHidden and v14 ~= count then
			v14 = count
			BotRig.teamHide(rig, v16)
		end
	end
end

function SeatedBots.hook(p: number, cframe: CFrame, p2: number, _, seatVel: Vector3, p3: number)
	local v16 = v2[p]

	if not v16 or not v16.alive or v16.diedAt then
		return
	end

	local rig = v16.rig

	if not rig then
		return
	end

	if v16.shown ~= rig then
		v16.shown = rig
		rig.model.Parent = botRigs
	end

	local v17 = v16.seatVel

	if not v17 then
		rig.pending = 0
		v17 = seatVel
	end

	v16.seatVel = seatVel
	local position = cframe.Position
	v16.lastDraw = position
	local snaps, _, _, _, _

	-- [DEDUP] synthesized from 2 duplicated terminal regions
	local function deduplicatedTail()
		local yaw, lookVector, v18, v19

		if #snaps > 0 then
			yaw = snaps[#snaps].yaw
			lookVector = cframe.LookVector
			v19 = (yaw - math.atan2(-lookVector.X, -lookVector.Z) + 3.141592653589793) % 6.283185307179586 - 3.141592653589793
		else
			v19 = 0
		end

		v18 = not (p3 > 0) and Vector3.new(0, 0, 0) or (seatVel - v17) / p3
		BotRig.seat(rig, cframe, p2 == 1, v19, v18, p3)
		v16.posed = true
	end

	if v16.posed then
		local v18 = position - v10
		local magnitude = v18.Magnitude

		if not (Detail.low and magnitude > 300) and not offScreen(v18, magnitude, v11, v12) then -- inferred equivalent call
			snaps = v16.snaps
			return deduplicatedTail()
		end

		local seatHidden = BotRig.seatHidden

		if (count + p) % 3 ~= 0 then
			cframe = nil
		end

		seatHidden(rig, cframe, p3)
	else
		snaps = v16.snaps
		return deduplicatedTail()
	end
end

local v16 = {}
local v17 = {}
local v18 = 1
local total2 = 1 / 60
RunService.PreSimulation:Connect(Detail.timed("bots", function(p: number)
	local v19 = math.clamp(v.mean + 2.5 * v.dev + 0.1, 0.08, 0.35)
	total += math.clamp(v19 - total, p * -0.05, p * 0.05)
	NetClock.botInterp = total
	local v20 = workspace:GetServerTimeNow() - total
	local now = os.clock()
	local currentCamera = workspace.CurrentCamera
	local cframe

	if currentCamera then
		cframe = currentCamera.CFrame
	end

	local v21 = not cframe and Vector3.new(0, 0, 0) or cframe.Position
	local v22 = not cframe and Vector3.new(0, 0, 1) or cframe.LookVector
	local v23

	if currentCamera then
		local viewportSize = currentCamera.ViewportSize
		local v24 = viewportSize.X / math.max(viewportSize.Y, 1)
		v23 = math.atan(math.tan(math.rad(currentCamera.FieldOfView) / 2) * math.sqrt(1 + v24 * v24)) + 0.35
	else
		v23 = 3.141592653589793
	end

	v10 = v21
	v11 = v22
	v12 = v23
	count += 1
	local reach = Detail.reach()
	local v24 = 120 * reach * (Detail.strain >= 3 and 0.6 or 1)
	local v25 = 300 * reach
	total2 += (math.min(p, 0.1) - total2) * 0.05

	local v26 = Detail.strain >= 3 and 2 or 1
	local v27 = math.max(math.round(1 / (total2 * 30)), 1) * v26
	local v28 = math.max(math.round(1 / (total2 * 20)), 1) * v26
	local v29 = not currentCamera and 1
		or math.max(0.5205670505517462 / math.tan(math.rad(currentCamera.FieldOfView) / 2), 1)
	local v30 = count % v18

	debug.profilebegin("BV.shots")
	local v31 = 1
	local count2 = 0

	while v31 <= #v7 do
		local v32 = v7[v31]

		if v32.t <= v20 then
			playShot(v2[v32.id], v32.to, v32.gun)
			table.remove(v7, v31)
			table.insert(v8, v32)
		else
			v31 += 1
		end
	end

	debug.profileend()
	debug.profilebegin("BV.bots")

	for _, v32 in v2 do
		if v32.deathT and v32.deathT <= v20 then
			kill(v32, v32.deathDir)
		end

		local rig = v32.rig

		if not rig then
			continue
		end

		if rig.hideQueue then
			BotRig.teamHideStep(rig)
		end

		if rig.teamHidden then
			if v32.diedAt or not (v32.alive and Detail.low) then
				BotRig.teamHide(rig, false)
				v32.teamBlocked = 0
			elseif not friendly(v32.team) or SeatedBots.seated(v32.id, now) then -- inferred equivalent call
				BotRig.teamHide(rig, false)
				v32.teamBlocked = 0
			end
		end

		local marker = rig.marker

		if marker then
			local v33 = v32.alive and not v32.diedAt

			if v33 then
				if v32.lastDraw and (count + v32.id) % 8 == 0 then
					local vector3 = v32.lastDraw - v21
					local sightHit

					if v32.sightFrame == count then
						sightHit = v32.sightHit
					else
						local voxelWorld = workspace:FindFirstChild("VoxelWorld")

						if voxelWorld == nil then
							sightHit = false
						else
							sightHit = SightRay.blocked(voxelWorld, v10, vector3 + Vector3.new(0, 2, 0))
						end

						v32.sightFrame = count
						v32.sightHit = sightHit
					end

					v32.markerBlocked = not sightHit and 0 or (v32.markerBlocked or 2) + 1
				end
			else
				v32.markerBlocked = nil
			end

			local v34 = v33 and (v32.markerBlocked or 2) < 2

			if v32.marker ~= marker then
				v32.marker = marker
				v32.markerOn = marker.Enabled
			end

			if v32.markerOn ~= v34 then
				v32.markerOn = v34
				marker.Enabled = v34
			end
		end

		if v32.diedAt then
			local corpseAt = v32.entry:GetAttribute("CorpseAt")

			if corpseAt ~= v32.corpseAt then
				v32.corpseAt = corpseAt
				local deathCF = rig.deathCF

				if
					typeof(corpseAt) == "Vector3"
					and deathCF
					and Vector2.new(corpseAt.X - deathCF.Position.X, corpseAt.Z - deathCF.Position.Z).Magnitude < 30
				then
					BotRig.settle(rig, corpseAt.Y)
				end
			end

			local v33 = now - v32.diedAt

			if v33 > 4 and v32.entry:GetAttribute("Downed") == true then
				v33 = 4
				v32.diedAt = now - v33
			end

			if v33 > 5 then
				BotRig.park(rig)
				v32.diedAt = nil
			else
				local v34 = v33 > 4
				local corpseSlide = v32.entry:GetAttribute("CorpseSlide")
				local v35 = false

				if typeof(corpseSlide) == "Vector3" then
					local slide = v32.slide or Vector3.new(0, 0, 0)

					if slide ~= corpseSlide then
						v35 = true
						local magnitude = (corpseSlide - slide).Magnitude

						if not (magnitude < 0.02 or magnitude > 12) then
							corpseSlide = slide:Lerp(corpseSlide, 1 - math.exp(p * -18))
						end

						v32.slide = corpseSlide
					end
				end

				if v34 or v35 or not rig.fallLanded then
					local lastDraw = v32.lastDraw
					local v36

					if lastDraw then
						local v37 = lastDraw - v21
						local magnitude = v37.Magnitude

						if Detail.low and magnitude > 300 then
							v36 = true
						else
							v36 = offScreen(v37, magnitude, v22, v23) -- inferred equivalent call
						end
					else
						v36 = false
					end

					if not v36 or not v34 and v33 >= 0.6 then
						BotRig.fall(rig, math.clamp((v33 - 4) / 1, 0, 1), v16, v17, v32.slide)
					end
				end
			end
		elseif v32.alive and not SeatedBots.seated(v32.id, now) then
			v32.seatVel = nil
			local v33 = count + v32.id
			local v34

			if marker == nil then
				v34 = false
			else
				v34 = v32.markerOn == true
			end

			local lastDraw = v32.lastDraw

			if lastDraw and rig.written then
				local vector = lastDraw - v21
				local magnitude = vector.Magnitude
				teamSight(v32, rig, vector, magnitude, v33)
				local v35 = v32.posed == true
					and not (magnitude <= 25 or v23 >= 3.141592653589793)
					and math.acos((math.clamp(vector:Dot(v22) / magnitude, -1, 1))) > v23 + math.asin(25 / magnitude)
				local v36 = (Detail.low and magnitude > 300 or rig.teamHidden == true) and (v34 and 3 or 6)
					or v35 and 3
					or 1

				if v36 > 1 and v33 % v36 ~= 0 then
					rig.pending += p
					v32.exFrame = nil
					v32.off = nil

					if count2 == v30 then
						BotRig.lod(rig, lastDraw)
					end

					count2 += 1
					BotRig.updateFlash(rig, true)
					continue
				end
			end

			local v35, v36 = sample(v32.snaps, v20, v32.scratch)

			if v35 then
				if v32.shown ~= rig then
					v32.shown = rig
					rig.model.Parent = botRigs
				end

				local pos = v35.pos

				if v35.ex then
					v32.exFrame = true
				elseif v32.exFrame then
					v32.exFrame = false
					local lastDraw2 = v32.lastDraw
					local off = not lastDraw2 and Vector3.new(0, 0, 0) or lastDraw2 + v36 * p - pos

					if not (off.Magnitude < 4) then
						off = nil
					end

					v32.off = off
				end

				local off = v32.off

				if off then
					local off2 = off * math.exp(-p * 12)

					if off2.Magnitude < 0.02 then
						v32.off = nil
					else
						v32.off = off2
						pos += off2
					end
				end

				v32.lastDraw = pos

				if v32.sniper and bit32.btest(v35.flags, 32) and not friendly(v32.team) then -- inferred equivalent call
					ScopeFeed.bot(v32.id, pos, v35.yaw, v35.pitch)
				end

				if count2 == v30 then
					BotRig.lod(rig, pos)
				end

				count2 += 1
				local vector = pos - v21
				local magnitude = vector.Magnitude
				local v37

				if v32.posed == true and not (magnitude <= 25 or v23 >= 3.141592653589793) then
					v37 = math.acos((math.clamp(vector:Dot(v22) / magnitude, -1, 1))) > v23 + math.asin(25 / magnitude)
				else
					v37 = false
				end

				local v38 = Detail.low and magnitude > 300 and true or rig.teamHidden == true
				local v39 = v38 and (v34 and 3 or 6) or v37 and 3 or 1

				if v39 > 1 and v33 % v39 ~= 0 then
					rig.pending += p
					BotRig.updateFlash(rig, true)
				else
					local v40 = magnitude / v29
					local v41 = not (v37 or v38)

					if v41 then
						if v40 < v24 then
							v41 = true
						else
							local v42

							if v40 < v25 then
								v42 = v27
							else
								v42 = v28
							end

							v41 = v33 % v42 == 0
						end
					end

					BotRig.update(rig, pos, v35.yaw, v35.pitch, v35.crouch, v35.lean, v35.flags, v36, p, v41, v35.head)
					BotRig.queueRoot(rig, v16, v17)

					if v41 then
						v32.posed = true
					end

					if v37 or v38 then
						BotRig.updateFlash(rig, true)
					end
				end
			end
		end
	end

	debug.profileend()
	v18 = math.max(count2, 1)

	debug.profilebegin("BV.move")

	if #v16 > 0 then
		workspace:BulkMoveTo(v16, v17, Enum.BulkMoveMode.FireCFrameChanged)
		table.clear(v16)
		table.clear(v17)
	end

	debug.profileend()
end))