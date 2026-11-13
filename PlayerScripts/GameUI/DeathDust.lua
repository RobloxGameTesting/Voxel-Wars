local Style = require(script.Parent:WaitForChild("Style"))
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quality = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("Quality"))

local DeathDust = {
	["new"] = nil,
	new = function(parent, data)
		local deathDust = Instance.new("Folder")
		deathDust.Name = "DeathDust"
		deathDust.Parent = parent

		local v = {}

		for i = 1, Quality.cap(72) do
			local voxel = Instance.new("Part")
			voxel.Name = "Voxel"
			voxel.Material = Enum.Material.SmoothPlastic
			voxel.Anchored = true
			voxel.CanCollide = false
			voxel.CanQuery = false
			voxel.CanTouch = false
			voxel.CastShadow = false
			voxel.TopSurface = Enum.SurfaceType.Smooth
			voxel.BottomSurface = Enum.SurfaceType.Smooth
			v[i] = {
				part = voxel,
				pos = Vector3.new(0, 0, 0),
				vel = Vector3.new(0, 0, 0),
				spin = Vector3.new(0, 0, 0),
				floor = 0,
				size = 1,
				t0 = 0,
				live = false,
				bounced = false
			}
		end

		local random = Random.new()
		local parts = {}
		local v2 = {}
		local v3 = os.clock()
		local v4

		if data then
			local curve = data.curve
			local constant = data.CONSTANT
			v4 = {
				radius = curve(constant, 0, 0.3),
				alpha = curve(constant),
				gravity = curve(constant),
				rotation = curve(data.EASEOUT),
				emissive = curve(constant),
				drag = 0,
				sticky = 0.2,
				collide = 1,
				material = Enum.Material.SmoothPlastic
			}
		else
			v4 = nil
		end

		local function step(_, p): boolean
			local v5 = math.min(p - v3, 0.05)
			v3 = p
			table.clear(parts)
			table.clear(v2)

			for _, v6 in v do
				if not v6.live then
					continue
				end

				local v7 = p - v6.t0

				if v7 >= 1.1 then
					v6.live = false
					v6.part.Parent = nil
				elseif v7 >= 0 then
					v6.vel -= Vector3.new(0, v5 * 60, 0)
					v6.pos += v6.vel * v5

					if v6.pos.Y < v6.floor + v6.size / 2 then
						v6.pos = Vector3.new(v6.pos.X, v6.floor + v6.size / 2, v6.pos.Z)

						if v6.bounced then
							v6.vel = Vector3.new(v6.vel.X * 0.8, 0, v6.vel.Z * 0.8)
							v6.spin *= 0.8
						else
							v6.bounced = true
							v6.vel = Vector3.new(v6.vel.X * 0.5, -v6.vel.Y * 0.3, v6.vel.Z * 0.5)
						end
					end

					local v8 = 1 - Style.easeIn(math.max(v7 / 1.1 - 0.6, 0) / 0.4)
					local v9 = math.max(v6.size * v8, 0.05)
					v6.part.Size = Vector3.new(v9, v9, v9)
					table.insert(parts, v6.part)
					table.insert(v2, CFrame.new(v6.pos) * CFrame.Angles(v6.spin.X * v7, v6.spin.Y * v7, v6.spin.Z * v7))
				end
			end

			if #parts > 0 then
				workspace:BulkMoveTo(parts, v2, Enum.BulkMoveMode.FireCFrameChanged)
			end

			for _, v6 in v do
				if v6.live then
					return true
				end
			end

			return false
		end

		local function play(vector3: Vector3, p: string?)
			local now = os.clock()
			local v5

			if p then
				v5 = Style.teamColor(p)
			else
				v5 = Style.STEEL_LIGHT
			end

			local v6 = math.max(Quality.count(22, vector3, 6), 6)
			local count = Quality.count(16, vector3, 0)
			local count2 = 0

			for _, v7 in v do
				if v6 <= count2 then
					break
				end

				if v7.live then
					continue
				end

				count2 += 1

				local number = random:NextNumber(0, 5)
				local v8 = number > 4.2 and 0.5 or number > 2 and 1 or 0.7
				v7.size = random:NextNumber(0.45, 0.8)
				v7.pos = vector3 + Vector3.new(
					random:NextNumber(-v8, v8),
					number - 3 + v7.size / 2,
					random:NextNumber(-0.4, 0.4)
				)
				v7.vel = Vector3.new(random:NextNumber(-3, 3), random:NextNumber(0, 4), random:NextNumber(-3, 3))
				v7.spin = Vector3.new(random:NextNumber(-6, 6), random:NextNumber(-6, 6), random:NextNumber(-6, 6))
				v7.floor = vector3.Y - 3
				v7.t0 = now + (5 - number) * 0.012
				v7.bounced = false
				v7.live = true
				local number2 = random:NextNumber(-0.25, 0.2)
				local part = v7.part
				local color

				if number2 < 0 then
					color = v5:Lerp(Color3.new(0, 0, 0), -number2)
				else
					color = v5:Lerp(Color3.new(1, 1, 1), number2)
				end

				part.Color = color
				v7.part.Size = Vector3.new(1, 1, 1) * v7.size
				v7.part.CFrame = CFrame.new(v7.pos)
				v7.part.Parent = deathDust
			end

			v3 = now
			Style.animate(v, step)

			if data then
				for _ = 1, count do
					local v7 = random:NextUnitVector() * random:NextNumber(2, 6) + Vector3.new(0, random:NextNumber(2, 5), 0)
					local number = random:NextNumber(0.06, 0.12)
					data.spawn(
						v4,
						vector3 + Vector3.new(
							random:NextNumber(-0.8, 0.8),
							random:NextNumber(-1.5, 1.5),
							random:NextNumber(-0.8, 0.8)
						),
						v7,
						random:NextNumber(1, 1.6),
						v5,
						number,
						number,
						-10,
						-10,
						random:NextNumber(6, 14),
						0,
						1,
						1,
						0,
						0
					)
				end
			end
		end

		return { folder = deathDust, play = play }
	end
}

function DeathDust.mount(p)
	local voxelFX = p.player:WaitForChild("PlayerScripts"):WaitForChild("VoxelFX", 30)
	assert(voxelFX, "GameUI: VoxelFX is missing")
	local ParticleSim = require((voxelFX:WaitForChild("ParticleSim")))
	assert(workspace:WaitForChild("VoxelChips", 30), "GameUI: ParticleSim was never started")
	local v = DeathDust.new(workspace, ParticleSim)
	p.Net.remote("Eliminated").OnClientEvent:Connect(function(vector3: Vector3, p2: string?)
		v.play(vector3, p2)
	end)
end

return DeathDust