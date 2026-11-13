local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Quality = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("Quality"))

local tuning = {
	light = 0.6,
	critical = 0.3,
	far = 450,
	smoke = {
		light = {
			rate = 2,
			c0 = Color3.fromRGB(120, 118, 114),
			c1 = Color3.fromRGB(160, 156, 150),
			s0 = 1,
			s1 = 4,
			life = 2.2,
			rise = 5,
			alpha = 0.75,
			drag = 0.6
		},
		critical = {
			rate = 9,
			c0 = Color3.fromRGB(30, 30, 30),
			c1 = Color3.fromRGB(60, 60, 60),
			s0 = 2.4,
			s1 = 10.5,
			life = 3.5,
			rise = 7.5,
			alpha = 0.15,
			drag = 0.35
		},
		wreck = {
			rate = 6,
			c0 = Color3.fromRGB(24, 22, 20),
			c1 = Color3.fromRGB(56, 54, 52),
			s0 = 3.6,
			s1 = 15,
			life = 5,
			rise = 7.5,
			alpha = 0.12,
			drag = 0.3
		}
	},
	wind = Vector3.new(1.6, 0, 0.8),
	hitSparks = 60,
	hitSparkSpeed = NumberRange.new(24, 48),
	hitPuffs = 4,
	flames = 5,
	flameHeight = 2,
	flameWidth = 1,
	flamePeriod = NumberRange.new(0.34, 0.56),
	flameJitter = 0.5,
	wreckFire = 1.8,
	flameYoung = Color3.fromRGB(255, 214, 120),
	flameMid = Color3.fromRGB(255, 132, 40),
	flameOld = Color3.fromRGB(196, 62, 22),
	flameGlow = 0.7,
	lightRange = 16,
	lightBrightness = 2.4,
	embers = 6,
	emberSpeed = NumberRange.new(2, 7)
}
local DamageFX = {}
DamageFX.TUNING = tuning
DamageFX.ENGINE = {
	Humvee = {
		at = Vector3.new(0, 5.1, -6.5),
		scale = 1,
		fire = 1,
		spots = { Vector3.new(-3.6, 4.2, -7.25), Vector3.new(3.6, 4.2, -7.25), Vector3.new(0, 5.1, -6.5) }
	},
	Tank = {
		at = Vector3.new(0, 5.6, 8.5),
		scale = 1.3,
		fire = 3.5,
		spots = { Vector3.new(-2, 5.6, 8.5), Vector3.new(2, 5.6, 8.5) }
	},
	Bradley = {
		at = Vector3.new(2.5, 6.6, -5),
		scale = 1.15,
		fire = 3,
		spots = { Vector3.new(2.5, 6.6, -5), Vector3.new(5.4, 5, -3.5) }
	}
}

local cframe = CFrame.new(0, -100000, 0)
local v = {}

local vehicleDamageFX = workspace:FindFirstChild("VehicleDamageFX") or Instance.new("Folder")
vehicleDamageFX.Name = "VehicleDamageFX"
vehicleDamageFX.Parent = workspace

local random = Random.new()

local function seq(items)
	local numberSequenceKeypoints = {}

	for _, item in items do
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(item[1], item[2]))
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

local function stageOf(p: number, flag: boolean): nil | string -- 1 equivalent call inferred from this helper
	if flag then
		return "wreck"
	end

	if p <= tuning.critical then
		return "critical"
	end

	return if p <= tuning.light then "light" else nil
end

function DamageFX.new(value: number?, p: number?, list)
	assert(RunService:IsClient(), "[DamageFX] clients only")
	local v2 = value or 1
	local v3 = p or v2
	local engine = Instance.new("Part")
	engine.Name = "Engine"
	engine.Anchored = true
	engine.CanCollide = false
	engine.CanQuery = false
	engine.CanTouch = false
	engine.CastShadow = false
	engine.Transparency = 1
	engine.Size = Vector3.new(0.2, 0.2, 0.2)
	engine.CFrame = cframe
	engine.Parent = vehicleDamageFX
	local attachment = Instance.new("Attachment")
	attachment.Parent = engine

	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = "rbxassetid://89598700477428"
	particleEmitter.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
	particleEmitter.FlipbookMode = Enum.ParticleFlipbookMode.OneShot
	particleEmitter.LightInfluence = 1
	particleEmitter.LockedToPart = false
	particleEmitter.Rate = 0
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.RotSpeed = NumberRange.new(-20, 20)
	particleEmitter.SpreadAngle = Vector2.new(14, 14)
	particleEmitter.EmissionDirection = Enum.NormalId.Top
	particleEmitter.Acceleration = tuning.wind
	particleEmitter.Parent = attachment

	local particleEmitter2 = Instance.new("ParticleEmitter")
	particleEmitter2.Texture = "rbxassetid://89598700477428"
	particleEmitter2.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
	particleEmitter2.FlipbookMode = Enum.ParticleFlipbookMode.OneShot
	particleEmitter2.LightInfluence = 1
	particleEmitter2.LockedToPart = false
	particleEmitter2.Rate = 0
	particleEmitter2.Color = ColorSequence.new(Color3.fromRGB(34, 32, 30), Color3.fromRGB(82, 78, 74))
	particleEmitter2.Size = seq({
		{ 0, 5 * v2 },
		{ 1, 9 * v2 }
	})
	particleEmitter2.Transparency = seq({
		{ 0, 0.2 },
		{ 0.6, 0.5 },
		{ 1, 1 }
	})
	particleEmitter2.Lifetime = NumberRange.new(1.8, 2.4)
	particleEmitter2.Speed = NumberRange.new(5, 10)
	particleEmitter2.SpreadAngle = Vector2.new(40, 40)
	particleEmitter2.EmissionDirection = Enum.NormalId.Top
	particleEmitter2.Rotation = NumberRange.new(0, 360)
	particleEmitter2.RotSpeed = NumberRange.new(-30, 30)
	particleEmitter2.Drag = 1.6
	particleEmitter2.Acceleration = Vector3.new(0, 3, 0)
	particleEmitter2.Parent = attachment

	local particleEmitter3 = Instance.new("ParticleEmitter")
	particleEmitter3.Texture = "rbxasset://textures/particles/fire_sparks_main.dds"
	particleEmitter3.LightEmission = 1
	particleEmitter3.LightInfluence = 0
	particleEmitter3.LockedToPart = false
	particleEmitter3.Rate = 0
	particleEmitter3.Color = ColorSequence.new(Color3.fromRGB(255, 235, 180), Color3.fromRGB(255, 140, 50))
	particleEmitter3.Size = seq({
		{ 0, 0.3 },
		{ 1, 0.05 }
	})
	particleEmitter3.Lifetime = NumberRange.new(0.4, 0.9)
	particleEmitter3.SpreadAngle = Vector2.new(75, 75)
	particleEmitter3.EmissionDirection = Enum.NormalId.Top
	particleEmitter3.Acceleration = Vector3.new(0, -40, 0)
	particleEmitter3.Drag = 1
	particleEmitter3.Parent = attachment

	local pointLight = Instance.new("PointLight")
	pointLight.Color = tuning.flameMid
	pointLight.Range = tuning.lightRange * math.max(v2, v3 * 0.6)
	pointLight.Brightness = 0
	pointLight.Shadows = false
	pointLight.Enabled = false
	pointLight.Parent = attachment

	local v4 = {}

	for i = 1, tuning.flames do
		local flame = Instance.new("Part")
		flame.Name = "Flame"
		flame.Anchored = true
		flame.CanCollide = false
		flame.CanQuery = false
		flame.CanTouch = false
		flame.CastShadow = false
		flame.Material = Enum.Material.Neon
		flame.Color = tuning.flameYoung
		flame.Size = Vector3.new(1, 1, 1) * tuning.flameWidth * v3
		flame.CFrame = cframe
		flame.Parent = engine
		v4[i] = {
			part = flame,
			t = (i - 1) / tuning.flames,
			period = random:NextNumber(tuning.flamePeriod.Min, tuning.flamePeriod.Max),
			at = Vector3.new(0, 0, 0),
			parked = true
		}
	end

	local v5 = nil
	local v6 = nil
	local v7 = 1
	local flag = false
	local v8 = Vector3.new(0, 0, 0)
	local flag2 = false
	local v9 = 0

	local function setStage(p2: string?)
		v5 = p2
		local v10

		if p2 then
			v10 = tuning.smoke[p2]
		end

		if not v10 then
			particleEmitter.Rate = 0
			return
		end

		particleEmitter.Rate = v10.rate * v7
		particleEmitter.Color = ColorSequence.new(v10.c0, v10.c1)
		particleEmitter.Size = seq({
			{ 0, v10.s0 * v2 },
			{ 1, v10.s1 * v2 }
		})
		particleEmitter.Transparency = seq({
			{ 0, 1 },
			{ 0.06, v10.alpha },
			{ 0.55, (v10.alpha + 1) * 0.5 },
			{ 1, 1 }
		})
		particleEmitter.Lifetime = NumberRange.new(v10.life * 0.85, v10.life * 1.15)
		particleEmitter.Speed = NumberRange.new(v10.rise * 0.8, v10.rise * 1.2)
		particleEmitter.Drag = v10.drag
	end

	local function hideFlames() -- 2 equivalent calls inferred from this helper
		for _, v10 in v4 do
			v10.part.CFrame = cframe
			v10.parked = true
		end

		pointLight.Brightness = 0
		pointLight.Enabled = false
	end

	return {
		update = function(cframe2: CFrame, vector3: Vector3, p2: number, flag3: boolean, p3: number, vector3_2: Vector3, flag4: boolean?)
			local pointToWorldSpace = cframe2:PointToWorldSpace(vector3)
			local v10 = (pointToWorldSpace - vector3_2).Magnitude <= tuning.far
			local v11

			if v10 then
				v11 = stageOf(p2, flag3) -- inferred equivalent call
			end

			local mobile = Quality.mobile or Quality.potato

			local v12 = not (mobile and v10) and 1
				or math.max(0.1, math.floor(Quality.detail(pointToWorldSpace) * 10 + 0.5) / 10)

			if v11 == v5 then
				if v12 ~= v7 then
					v7 = v12
					local v13

					if v5 then
						v13 = tuning.smoke[v5]
					end

					particleEmitter.Rate = not v13 and 0 or v13.rate * v12
				end
			else
				v7 = v12
				setStage(v11)
			end

			local v13

			if v10 then
				if v6 == nil then
					v13 = false
				else
					v13 = p2 < v6 - 0.02
				end
			else
				v13 = v10
			end

			if v10 then
				if (v11 ~= nil or v13) and (not flag or (pointToWorldSpace - v8).Magnitude > 0.05) then
					engine.CFrame = CFrame.new(pointToWorldSpace)
					v8 = pointToWorldSpace
					flag = true
				end
			elseif flag then
				engine.CFrame = cframe
				flag = false
			end

			if v13 then
				if mobile then
					particleEmitter2:Emit(Quality.count(tuning.hitPuffs, pointToWorldSpace, 1))
					particleEmitter3.Speed = tuning.hitSparkSpeed
					particleEmitter3:Emit(Quality.count(tuning.hitSparks, pointToWorldSpace, 6))
				else
					particleEmitter2:Emit(tuning.hitPuffs)
					particleEmitter3.Speed = tuning.hitSparkSpeed
					particleEmitter3:Emit(tuning.hitSparks)
				end
			end

			v6 = p2

			if v11 == "critical" or v11 == "wreck" then
				flag2 = true
				local v14 = v3 * (v11 ~= "wreck" and 1 or tuning.wreckFire)
				local v15

				if mobile then
					v15 = Quality.cap(#v4)
				else
					v15 = #v4
				end

				local v16 = if flag4 then v else v4

				for k, v17 in v16 do
					if v15 < k then
						if not v17.parked then
							v17.part.CFrame = cframe
							v17.parked = true
						end
					else
						v17.t += p3 / v17.period

						if v17.t >= 1 then
							v17.t -= 1
							v17.period = random:NextNumber(tuning.flamePeriod.Min, tuning.flamePeriod.Max)
							local v18 = tuning.flameJitter * v14
							local v19

							if list then
								v19 = list[random:NextInteger(1, #list)]
							else
								v19 = vector3
							end

							v17.at = v19 + Vector3.new(random:NextNumber(-v18, v18), 0, random:NextNumber(-v18, v18))
						end

						local t = v17.t
						local v18

						if v17.at == Vector3.new(0, 0, 0) then
							v18 = vector3
						else
							v18 = v17.at
						end

						local v19 = cframe2:PointToWorldSpace(v18) + Vector3.new(0, 1, 0) * (tuning.flameHeight * v14 * t)
						local v20 = tuning.flameWidth * v14 * (1 - 0.65 * t)
						v17.part.Size = Vector3.new(v20, v20 * (1.6 - 0.6 * t), v20)
						v17.part.CFrame = CFrame.new(v19) * CFrame.Angles(0, t * 1.4 + v17.period * 9, 0)
						v17.parked = false
						local part = v17.part
						local color

						if t < 0.45 then
							color = tuning.flameYoung:Lerp(tuning.flameMid, t / 0.45)
						else
							color = tuning.flameMid:Lerp(tuning.flameOld, (t - 0.45) / 0.55)
						end

						part.Color = color
						v17.part.Transparency = 1 - (1 - t * t * 0.9) * tuning.flameGlow
					end
				end

				local enabled = (not mobile or Quality.metres(pointToWorldSpace) <= 30) and not Quality.lowEnd()

				if pointLight.Enabled ~= enabled then
					pointLight.Enabled = enabled
				end

				local brightness

				if mobile then
					brightness = tuning.lightBrightness
				else
					brightness = tuning.lightBrightness * random:NextNumber(0.7, 1.15)
				end

				if pointLight.Brightness ~= brightness then
					pointLight.Brightness = brightness
				end

				v9 += tuning.embers * p3

				if v9 >= 1 then
					local v17 = math.floor(v9)
					v9 -= v17
					particleEmitter3.Speed = tuning.emberSpeed
					particleEmitter3:Emit(v17)
				end
			elseif flag2 then
				flag2 = false
				hideFlames() -- inferred equivalent call
			end
		end,
		destroy = function()
			particleEmitter.Rate = 0
			hideFlames() -- inferred equivalent call
			task.delay(6, function()
				engine:Destroy()
			end)
		end
	}
end

return DamageFX