local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local AudioGraph = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("AudioGraph"))
local MapSelect = require(ReplicatedStorage.Voxel:WaitForChild("MapSelect"))
local Hardpoint = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("Hardpoint"))
local SpawnRaid = require(ReplicatedStorage.Game:WaitForChild("SpawnRaid"))

local v = {
	chime = {
		id = 9117375071,
		from = 0,
		to = 1.4,
		gain = 0.6,
		fade = 0.5,
		lowpass = 4500,
		speed = 0.69
	},
	thump = {
		id = 1842312348,
		from = 0,
		to = 0.35,
		gain = 0.2,
		fade = 0.15,
		lowpass = 1500,
		speed = 1
	},
	clank = {
		id = 9117375064,
		from = 0,
		to = 1,
		gain = 0.55,
		fade = 0.4,
		lowpass = 4500,
		speed = 0.65
	},
	tink = {
		id = 9117375071,
		from = 0,
		to = 0.15,
		gain = 0.25,
		fade = 0.12,
		lowpass = 4500,
		speed = 0.69
	},
	boom = {
		id = 9116503293,
		from = 0,
		to = 2.2,
		gain = 0.22,
		fade = 0.8,
		lowpass = 3000,
		speed = 1
	},
	tick = {
		id = 9125419091,
		from = 0,
		to = 0.04,
		gain = 0.8,
		fade = 0.01,
		lowpass = 3500,
		speed = 1
	},
	knock = {
		id = 9125654847,
		from = 0,
		to = 0.25,
		gain = 0.5,
		fade = 0.1,
		lowpass = 2500,
		speed = 0.8
	},
	pulse = {
		id = 1842312794,
		from = 0,
		to = 0.5,
		gain = 0.12,
		fade = 0.2,
		lowpass = 1200,
		speed = 1
	}
}

local v2 = {}
local v3 = {}

local function fire(p: string, value: number?, p2: number?)
	local v4 = v2[p]
	assert(v4, "[PointAudio] unknown cue " .. p)
	local cut = v4.cut
	local voice = v4.voices[v4.next]
	v4.next = v4.next % #v4.voices + 1

	for i = #v3, 1, -1 do
		if v3[i].player == voice then
			table.remove(v3, i)
		end
	end

	local playbackSpeed = math.min(p2 or cut.speed, 1)
	local v5 = cut.gain * (value or 1)
	voice:Stop()
	voice.PlaybackRegion = NumberRange.new(cut.from, cut.to)
	voice.PlaybackSpeed = playbackSpeed
	voice.Volume = v5
	voice.TimePosition = cut.from
	voice:Play()
	table.insert(v3, {
		player = voice,
		gain = v5,
		endAt = os.clock() + (cut.to - cut.from) / playbackSpeed,
		fade = cut.fade
	})
end

local function num(value) -- 3 equivalent calls inferred from this helper
	return if type(value) == "number" then value else 0
end

local function str(value) -- 4 equivalent calls inferred from this helper
	return if type(value) == "string" then value else ""
end

return {
	mount = function(p)
		local domination = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Domination", 30)
		assert(
			domination and domination:IsA("Configuration"),
			"PointAudio: ReplicatedStorage.Game.Domination is missing"
		)
		local player = p.player

		local attributes = domination:GetAttributes()
		domination.AttributeChanged:Connect(function(attributeName: string)
			attributes[attributeName] = domination:GetAttribute(attributeName)
		end)

		for k, cut in v do
			local players = {}

			for i = 1, 2 do
				local flat = AudioGraph.flat("Point_" .. k .. "_" .. i)
				AudioGraph.route(flat, "ui")
				AudioGraph.lowpass(flat, cut.lowpass)
				flat.player.Looping = false
				flat.player.Asset = "rbxassetid://" .. cut.id
				players[i] = flat.player
			end

			v2[k] = { cut = cut, voices = players, next = 1 }
		end

		task.delay(20, function()
			for k, v4 in v2 do
				for _, voice in v4.voices do
					if not voice.IsReady then
						warn("[PointAudio] cue " .. k .. " (" .. voice.Asset .. ") has not loaded")
						break
					end
				end
			end
		end)

		local v4 = nil
		local v5 = nil
		local v6 = 0
		local v7 = num(attributes.EventAt) -- inferred equivalent call

		local function reset() -- 1 equivalent call inferred from this helper
			v4 = nil
			v5 = nil
			v6 = 0
		end
		MapSelect.onChange(reset, 21)
		Hardpoint.onPointsChange(reset)

		local function feetPoint()
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if humanoid and humanoid.Health > 0 and humanoidRootPart and humanoidRootPart:IsA("BasePart") then
				return Hardpoint.pointAt(humanoidRootPart.Position - Vector3.new(
					0,
					humanoid.HipHeight + humanoidRootPart.Size.Y * 0.5,
					0
				))
			end

			return nil
		end

		local function indexOf(p2: string) -- 1 equivalent call inferred from this helper
			for k, v8 in Hardpoint.POINTS do
				if v8.id == p2 then
					return k
				end
			end

			return nil
		end

		RunService.Heartbeat:Connect(function()
			local now = os.clock()

			for i = #v3, 1, -1 do
				local v8 = v3[i]
				local v9 = v8.endAt - now

				if v9 <= 0 then
					v8.player:Stop()
					table.remove(v3, i)
				elseif v9 < v8.fade then
					v8.player.Volume = v8.gain * v9 / v8.fade
				end
			end

			local name

			if player.Team and not player.Neutral then
				name = player.Team.Name
			end

			local v8 = num(attributes.EventAt) -- inferred equivalent call
			local v9

			if name == nil or attributes.Phase ~= "live" then
				v9 = false
			else
				v9 = not SpawnRaid.isRaid(attributes.GameMode) and attributes.GameMode ~= "tdm"
			end

			if v9 then
				local v10 = feetPoint()

				if v8 ~= v7 then
					v7 = v8
					local v11 = str(attributes.Event) -- inferred equivalent call
					local k = indexOf(str(attributes.EventPoint)) -- inferred equivalent call

					if workspace:GetServerTimeNow() - v8 < 1 and k and (v11 == "captured" or v11 == "neutralized") then
						local v12 = str(attributes.EventTeam) == name -- inferred equivalent call
						local v13 = v10 == k

						if v12 and v11 == "captured" then
							fire("chime", v13 and 1 or 0.35)

							if v13 then
								fire("thump")
							end
						elseif v12 then
							fire("clank", v13 and 1 or 0.35)
						elseif v11 == "neutralized" then
							fire("boom", v13 and 1 or 0.6)
						else
							fire("boom", v13 and 0.8 or 0.45)
						end
					end
				end

				if v10 ~= v4 then
					v4 = v10
					v5 = nil
					v6 = 0

					if v10 then
						fire("tink")
					end
				end

				if not v10 then
					return
				end

				local v11 = str(attributes[Hardpoint.attr("Mode", v10)]) -- inferred equivalent call

				if v11 == "contested" then
					if v6 <= now then
						v6 = now + 1.2
						fire("pulse")
					end
				else
					v6 = 0
				end

				local v12 = num(attributes[Hardpoint.attr("Control", v10)]) * (name == "Reds" and 1 or -1) -- inferred equivalent call
				local v13 = math.floor(v12 * 12 + 1e-6)

				if v11 ~= "capturing" and v11 ~= "neutralizing" then
					v5 = v13
					return
				end

				local v14 = v5
				v5 = v13

				if
					v14 == nil
					or v13 == v14
					or math.abs(v12) >= 0.999
					or math.abs(v12) < 1e-6
					or (v12 > 0) ~= (v14 >= 0)
				then
					return
				end

				if not (v14 < v13) then
					fire("knock")

					return
				end

				if not (v12 >= 0) then
					v12 += 1
				end

				fire("tick", nil, math.clamp(v12, 0, 1) * 0.1 + 0.9)
			else
				v7 = v8
				reset() -- inferred equivalent call
			end
		end)
	end
}