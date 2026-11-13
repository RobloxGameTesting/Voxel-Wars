local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Hardpoint = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("Hardpoint"))
local MusicTracks = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("MusicTracks"))
local CueAlert = require(script.Parent.CueAlert)
local Music = require(script.Parent.Music)
local Settings = require(script.Parent.Settings)

local function num(value) -- 12 equivalent calls inferred from this helper
	return if type(value) == "number" then value else 0
end

return {
	mount = function(p)
		local domination = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Domination", 30)
		assert(
			domination and domination:IsA("Configuration"),
			"MusicCues: ReplicatedStorage.Game.Domination is missing"
		)
		local player = p.player

		local v = -1
		local v2 = num(domination:GetAttribute("CueReset")) -- inferred equivalent call
		local v3 = true
		local count = 0
		local lastTime = -1e999
		local flag = false
		local v4 = false
		local v5 = false
		local v6 = nil
		local v7 = nil
		local v8 = 0
		local v9 = false

		local function forget(flag2: boolean) -- 2 equivalent calls inferred from this helper
			v3 = flag2
			count = 0
			lastTime = -1e999
			flag = false
			v4 = false
			v5 = false
			v6 = nil
			v7 = nil
			v8 = 0
			v9 = not flag2
		end

		local function play(p2: string, p3: number?) -- 3 equivalent calls inferred from this helper
			count += 1
			lastTime = os.clock()

			if Settings.track(player) ~= MusicTracks.OFF then
				Music.cue(p2, p3)
			end
		end

		local function allHeldBy()
			if #Hardpoint.POINTS < 2 then
				return nil
			end

			local v10 = nil

			for k in Hardpoint.POINTS do
				local attribute = domination:GetAttribute(Hardpoint.attr("Holder", k))

				if type(attribute) ~= "string" or attribute == "" or v10 and attribute ~= v10 then
					return nil
				end

				v10 = attribute
			end

			return v10
		end

		local function look()
			local v10 = num(domination:GetAttribute("StartsAt")) -- inferred equivalent call

			if v10 ~= v then
				v = v10
				forget(true) -- inferred equivalent call
			end

			local v11 = num(domination:GetAttribute("CueReset")) -- inferred equivalent call

			if v11 ~= v2 then
				v2 = v11
				forget(false) -- inferred equivalent call
				Music.cueOut(0.3)
			end

			local name

			if player.Team and not player.Neutral then
				name = player.Team.Name
			end

			if Settings.track(player) == MusicTracks.OFF then
				Music.cueOut(0.6)
			end

			local gameMode = domination:GetAttribute("GameMode")
			local v12 = gameMode == "breakthrough"
			local phase = domination:GetAttribute("Phase")

			if phase ~= "live" and (not v12 or phase ~= "moving") or not name then
				Music.cueOut(0.6)
				return
			end

			local v13

			if gameMode == "domination" or gameMode == "tdm" then
				v13 = false
			else
				v13 = not v12
			end

			local v14 = v12 and name == domination:GetAttribute("Defenders")
			local v15 = num(domination:GetAttribute("TicketsMax")) -- inferred equivalent call
			local v16

			if v12 then
				if v15 > 0 then
					v16 = num(domination:GetAttribute("Tickets")) <= v15 * 0.25 -- inferred equivalent call
				else
					v16 = false
				end
			else
				v16 = v12
			end

			local v17

			if v12 then
				if num(domination:GetAttribute("Sectors")) > 0 then -- inferred equivalent call
					local v18 = num(domination:GetAttribute("Sector")) -- inferred equivalent call
					v17 = num(domination:GetAttribute("Sectors")) <= v18 -- inferred equivalent call
				else
					v17 = false
				end
			else
				v17 = v12
			end

			local v18 = num(domination:GetAttribute(name)) -- inferred equivalent call
			local v19 = num(domination:GetAttribute(Hardpoint.other(name))) -- inferred equivalent call
			local v20 = num(domination:GetAttribute("Target")) -- inferred equivalent call
			local v21

			if gameMode == "domination" then
				v21 = allHeldBy()
			end

			if v3 then
				v3 = false
				v6 = v21
			end

			local v22 = num(domination:GetAttribute("EndsAt")) -- inferred equivalent call
			local v23 = v22 - workspace:GetServerTimeNow()
			local v24

			if v22 > 0 then
				v24 = v23 <= 60
			else
				v24 = false
			end

			local v25

			if v12 then
				v25 = v16 or v17
			elseif v13 then
				if v20 > 0 then
					v25 = math.min(v18, v19) <= math.max(1, (math.ceil(v20 * 0.1)))
				else
					v25 = false
				end
			elseif v20 > 0 then
				local v26 = math.max(v18, v19)
				v25 = v20 * 0.75 <= v26
			else
				v25 = false
			end

			local overtime = domination:GetAttribute("Overtime") == true

			if overtime and not v4 then
				v4 = true

				if Settings.track(player) ~= MusicTracks.OFF then
					Music.cueHit("hit")
				end

				CueAlert.show("OVERTIME", v19 <= v18, name)
			end

			local v26 = MusicTracks.CUES.final.ending + 1
			local v27

			if v22 > 0 and v23 > 0 then
				v27 = not overtime
			else
				v27 = false
			end

			if v27 and v23 <= v26 and not v5 then
				v5 = true
				play("final", v26 - v23) -- inferred equivalent call
			end

			if flag or not (overtime or v24 or v25) then
				if flag then
					return
				end

				local v28

				if count < 3 and os.clock() - lastTime >= 90 then
					v28 = not Music.cuePlaying()
				else
					v28 = false
				end

				if gameMode == "domination" then
					if v21 ~= v7 then
						v7 = v21
						v8 = v9 and -10 or os.clock()
						v9 = false
					end

					if v21 and v21 ~= v6 and v28 and os.clock() - v8 >= 10 then
						v6 = v21
						play(v21 == name and "up" or "down") -- inferred equivalent call
						CueAlert.show(
							v21 == name and "WE HOLD EVERY POINT" or "ENEMY HOLDS EVERY POINT",
							v21 == name,
							name
						)
					end
				end
			else
				flag = true

				if not (v27 and v23 <= 75) then
					play("final") -- inferred equivalent call
				end

				if v25 then
					if v12 then
						if v16 then
							CueAlert.show(v14 and "ATTACKERS RUNNING LOW" or "TICKETS RUNNING LOW", v14, name)
						else
							CueAlert.show(v14 and "LAST LINE: HOLD IT" or "FINAL SECTOR", not v14, name)
						end
					elseif v13 then
						CueAlert.show(
							v19 <= v18 and "ENEMY SPAWNS RUNNING LOW" or "OUR SPAWNS RUNNING LOW",
							v19 <= v18,
							name
						)
					else
						CueAlert.show(
							v19 <= v18 and "CLOSING IN ON VICTORY" or "ENEMY APPROACHING VICTORY",
							v19 <= v18,
							name
						)
					end
				elseif not overtime then
					local show = CueAlert.show
					local v28 = string.format("%d SECONDS LEFT", 60)

					if not v12 then
						v14 = v19 <= v18
					end

					show(v28, v14, name)
				end
			end
		end

		while true do
			debug.profilebegin("MC.look")
			look()
			debug.profileend()
			task.wait(0.5)
		end
	end
}