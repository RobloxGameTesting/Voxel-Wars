local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Style = require(script.Parent.Style)
local Hardpoint = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("Hardpoint"))
local SpawnRaid = require(ReplicatedStorage.Game:WaitForChild("SpawnRaid"))
local MapSelect = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("MapSelect"))
local GroundHeight = require(ReplicatedStorage.Voxel:WaitForChild("GroundHeight"))

local color = Color3.fromRGB(150, 152, 158)
return {
	mount = function(_)
		local domination = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Domination", 30)
		assert(
			domination and domination:IsA("Configuration"),
			"PointRings: ReplicatedStorage.Game.Domination is missing"
		)

		local pointRings = Instance.new("Folder")
		pointRings.Name = "PointRings"
		local v = {}

		local function strip(vector3: Vector3, vector3_2: Vector3)
			local part = Instance.new("Part")
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.CastShadow = false
			part.Material = Enum.Material.Neon
			part.Transparency = 0.25
			part.Color = color:Lerp(Color3.new(), 0.35)
			part.Size = Vector3.new(1.4, 0.15, (vector3_2 - vector3).Magnitude + 1.4)
			part.CFrame = CFrame.lookAt((vector3 + vector3_2) * 0.5, vector3_2)
			part.Parent = pointRings
			return part
		end

		local function rebuild()
			pointRings:ClearAllChildren()
			table.clear(v)

			for k, v2 in Hardpoint.POINTS do
				local center = v2.center
				local halfX = v2.halfX
				local halfZ = v2.halfZ
				local v3 = {
					Vector3.new(center.X - halfX, 0, center.Z - halfZ),
					Vector3.new(center.X + halfX, 0, center.Z - halfZ),
					Vector3.new(center.X + halfX, 0, center.Z + halfZ),
					(Vector3.new(center.X - halfX, 0, center.Z + halfZ))
				}

				local parts = {}

				for i = 1, 4 do
					local v4 = v3[i]
					local v5 = v3[i % 4 + 1]
					local v6 = math.max(1, (math.ceil((v5 - v4).Magnitude / 2)))
					local v7 = (v5 - v4).Unit * 0.7
					local vector3 = Vector3.new(-v7.Z, 0, v7.X)
					local vector3s = {}

					for j = 0, v6 do
						local lerped = v4:Lerp(v5, j / v6)
						local floor = v2.floor or -1e999

						if not v2.floor then
							for _, v8 in {
								Vector3.new(0, 0, 0),
								v7,
								-v7,
								vector3,
								-vector3
							} do
								floor = math.max(floor, GroundHeight.at(lerped.X + v8.X, lerped.Z + v8.Z))
							end
						end

						table.insert(vector3s, (Vector3.new(lerped.X, floor + 0.3, lerped.Z)))
					end

					local v8 = 1

					while v8 < #vector3s do
						local v9 = v8 + 1

						while v9 < #vector3s do
							local v10 = v9 + 1
							local v11 = true

							for j = v8 + 1, v10 - 1 do
								if math.abs(vector3s[v8].Y + (vector3s[v10].Y - vector3s[v8].Y) * (j - v8) / (v10 - v8) - vector3s[j].Y) > 0.05 then
									v11 = false
									break
								end
							end

							if not v11 then
								break
							end

							v9 = v10
						end

						table.insert(parts, strip(vector3s[v8], vector3s[v9]))
						v8 = v9
					end
				end

				v[k] = { parts = parts, color = color }
			end
		end
		rebuild()
		MapSelect.onChange(rebuild, 21)
		Hardpoint.onPointsChange(rebuild)

		local function num(attribute) -- 2 equivalent calls inferred from this helper
			return if type(attribute) == "number" then attribute else 0
		end

		local v2 = false
		local function readShow() -- 1 equivalent call inferred from this helper
			local gameMode = domination:GetAttribute("GameMode")
			v2 = domination:GetAttribute("Phase") ~= nil and gameMode ~= "tdm" and not SpawnRaid.isRaid(gameMode)
		end

		readShow() -- inferred equivalent call
		domination:GetAttributeChangedSignal("GameMode"):Connect(readShow)
		domination:GetAttributeChangedSignal("Phase"):Connect(readShow)

		local v3 = -1e999
		local v4 = false
		RunService.Heartbeat:Connect(function()
			if v2 ~= v4 then
				v4 = v2
				local parent

				if v2 then
					parent = workspace
				end

				pointRings.Parent = parent
			end

			if not v2 then
				return
			end

			local now = os.clock()

			if now - v3 < 0.05 then
				return
			end

			v3 = now

			for k, v5 in v do
				local attribute = domination:GetAttribute(Hardpoint.attr("Holder", k))
				local color2

				if attribute == "Reds" or attribute == "Blues" then
					color2 = Style.teamColor(attribute)
				else
					color2 = color
				end

				local attribute2 = domination:GetAttribute(Hardpoint.attr("Mode", k))

				if attribute2 == "contested" or attribute2 == "capturing" or attribute2 == "neutralizing" then
					local v6 = num(domination:GetAttribute(Hardpoint.attr("RedsOn", k))) -- inferred equivalent call
					local v7 = num(domination:GetAttribute(Hardpoint.attr("BluesOn", k))) -- inferred equivalent call
					local v8

					if attribute2 == "contested" then
						v8 = Style.HAZARD
					elseif v7 < v6 then
						v8 = Style.teamColor("Reds")
					else
						v8 = Style.teamColor("Blues")
					end

					color2 = color2:Lerp(v8, math.sin(now * 5) * 0.5 + 0.5)
				end

				if color2 == v5.color then
					continue
				end

				v5.color = color2
				local lerped = color2:Lerp(Color3.new(), 0.35)

				for _, part in v5.parts do
					part.Color = lerped
				end
			end
		end)
	end
}