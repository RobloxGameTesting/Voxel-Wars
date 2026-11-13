local ReplicatedStorage = game:GetService("ReplicatedStorage")

local color = Color3.fromRGB(136, 130, 121)
local color2 = Color3.fromRGB(94, 88, 82)
local color3 = Color3.fromRGB(196, 186, 162)
local color4 = Color3.fromRGB(166, 160, 149)
local color5 = Color3.fromRGB(88, 76, 62)
local color6 = Color3.fromRGB(66, 54, 44)
local color7 = Color3.fromRGB(104, 74, 52)
local color8 = Color3.fromRGB(70, 52, 42)
local color9 = Color3.fromRGB(104, 106, 108)
local color10 = Color3.fromRGB(116, 64, 44)
local color11 = Color3.fromRGB(170, 96, 64)
local color12 = Color3.fromRGB(118, 114, 106)
local color13 = Color3.fromRGB(46, 66, 44)
local color14 = Color3.fromRGB(236, 240, 246)
local color15 = Color3.fromRGB(40, 46, 54)
local color16 = Color3.fromRGB(170, 104, 80)

local v = { Vector2.new(0, 1.6), Vector2.new(-4.6, -0.6), Vector2.new(4.6, -0.6) }

local function block(data, cframe: CFrame, size: Vector3, color17: Color3, p, flag: boolean?)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Locked = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Size = size
	part.CFrame = data.frame * cframe
	part.Color = color17
	part.Material = p or Enum.Material.Concrete
	part.CastShadow = flag ~= false and not data.low
	part.Parent = data.parent
	return part
end

local function jitter(p, color17: Color3, p2: number) -- 26 equivalent calls inferred from this helper
	local v2 = 1 + (p.rng:NextNumber() * 2 - 1) * p2
	return Color3.new(
		math.clamp(color17.R * v2, 0, 1),
		math.clamp(color17.G * v2, 0, 1),
		(math.clamp(color17.B * v2, 0, 1))
	)
end

local function spin(p) -- 2 equivalent calls inferred from this helper
	local rng = p.rng
	return CFrame.Angles(rng:NextNumber() * 6.283, rng:NextNumber() * 6.283, rng:NextNumber() * 6.283)
end

local function clearOfFeet(number: number, number2: number, p: number): boolean
	for _, v2 in v do
		if (Vector2.new(number, number2) - v2).Magnitude < p then
			return false
		end
	end

	return true
end

local function snowCap(p, cframe: CFrame, p2: number, p3: number)
	if p.snow then
		block(
			p,
			cframe * CFrame.new(0, 0.12, 0),
			Vector3.new(p2 + 0.2, 0.24, p3 + 0.2),
			jitter(p, color14, 0.02), -- inferred equivalent call
			Enum.Material.Snow,
			false
		)
	end
end

local function heap(p, vector3: Vector3, p2: number, p3: number, p4: number, value: number?, p5)
	local rng = p.rng
	local v2 = p5 or { color, color, color2 }

	for _ = 1, p4 do
		local v3 = p2 * math.sqrt((rng:NextNumber()))
		local v4 = rng:NextNumber() * 6.283
		local v5 = rng:NextNumber(0.7, 2.3) * (value or 1)
		local v6 = p3 * (1 - v3 / p2) * rng:NextNumber(0.5, 1)
		block(
			p,
			CFrame.new(vector3 + Vector3.new(math.cos(v4) * v3, v6, math.sin(v4) * v3 * 0.6)) * spin(p), -- inferred equivalent call
			Vector3.new(v5, v5 * 0.7, v5),
			jitter(p, v2[rng:NextInteger(1, #v2)], 0.1)
		)
	end
end

local function facade(p, cframe: CFrame, list, p2: number, p3: number, color17: Color3, p4, p5: number, color18: Color3?)
	local v2 = -#list * p2 / 2

	for k, item in list do
		local v3 = v2 + (k - 0.5) * p2
		local v4 = jitter(p, color17, 0.05) -- inferred equivalent call

		local function seg(p6: number, p7: number) -- 2 equivalent calls inferred from this helper
			if p7 - p6 > 0.05 then
				block(p, cframe * CFrame.new(v3, (p6 + p7) / 2, 0), Vector3.new(p2, p7 - p6, p3), v4, p4)
			end
		end

		if k % 2 == 0 then
			local count = 0
			local v5 = 0

			while true do
				local v6 = count * p5 + p5 * 0.32
				local v7 = count * p5 + p5 * 0.82

				if item <= v6 then
					break
				end

				seg(v5, v6) -- inferred equivalent call

				if color18 and v7 <= item then
					block(
						p,
						cframe * CFrame.new(v3, (v6 + v7) / 2, -p3 * 0.25),
						Vector3.new(p2, v7 - v6, 0.1),
						color18,
						Enum.Material.Glass,
						false
					)

					if color18 ~= color15 and not p.low then
						block(
							p,
							cframe * CFrame.new(v3, (v6 + v7) / 2, -p3 * 0.25 + 0.08),
							Vector3.new(0.18, v7 - v6, 0.06),
							Color3.fromRGB(232, 232, 228),
							Enum.Material.SmoothPlastic,
							false
						)
						block(
							p,
							cframe * CFrame.new(v3, v6 + (v7 - v6) * 0.62, -p3 * 0.25 + 0.08),
							Vector3.new(p2, 0.18, 0.06),
							Color3.fromRGB(232, 232, 228),
							Enum.Material.SmoothPlastic,
							false
						)
					end
				end

				v5 = math.min(v7, item)
				count += 1
			end

			seg(v5, item) -- inferred equivalent call
		elseif item - 0 > 0.05 then
			block(p, cframe * CFrame.new(v3, (item + 0) / 2, 0), Vector3.new(p2, item - 0, p3), v4, p4)
		end

		local v5 = 1

		while v5 * p5 < item - 0.4 do
			block(
				p,
				cframe * CFrame.new(v3, v5 * p5, p3 / 2 + 0.15),
				Vector3.new(p2, 0.6, 0.3),
				v4:Lerp(Color3.new(), 0.25),
				p4
			)
			v5 += 1
		end

		snowCap(p, cframe * CFrame.new(v3, item, 0), p2, p3)
	end

	return v2
end

local function rebar(p, cframe: CFrame, p2: number)
	if p.low then
		return
	end

	local rng = p.rng

	for i = 1, p2 do
		local number = rng:NextNumber(1.2, 2.6)
		local cframe2 = CFrame.Angles(rng:NextNumber(-0.5, 0.5), 0, rng:NextNumber(-0.6, 0.6))
		block(
			p,
			cframe * CFrame.new((i - (p2 + 1) / 2) * 1.1, 0, rng:NextNumber(-0.4, 0.4)) * cframe2 * CFrame.new(0, number / 2, 0),
			Vector3.new(0.14, number, 0.14),
			color8,
			Enum.Material.Metal,
			false
		)
	end
end

local function twall(p, cframe: CFrame)
	local v2 = jitter(p, color4, 0.04) -- inferred equivalent call
	block(p, cframe * CFrame.new(0, 0.5, 0), Vector3.new(3.3, 1, 3), v2)
	block(p, cframe * CFrame.new(0, 4.6, 0), Vector3.new(3.2, 7.2, 0.9), v2)
	block(p, cframe * CFrame.new(0, 8.4, 0), Vector3.new(3, 0.4, 0.75), v2)
	local v3 = cframe * CFrame.new(0, 8.6, 0)

	if p.snow then
		block(
			p,
			v3 * CFrame.new(0, 0.12, 0),
			Vector3.new(3.2, 0.24, 0.95),
			jitter(p, color14, 0.02), -- inferred equivalent call
			Enum.Material.Snow,
			false
		)
	end

	if not p.low then
		block(
			p,
			cframe * CFrame.new(0, 6.6, 0.47),
			Vector3.new(3.2, 0.3, 0.04),
			Color3.fromRGB(176, 150, 70),
			Enum.Material.SmoothPlastic,
			false
		)
		block(p, cframe * CFrame.new(0, 1.3, 0.47), Vector3.new(3.2, 0.6, 0.04), color5, Enum.Material.Ground, false)
	end
end

local function container(p, cframe: CFrame, color17: Color3)
	block(p, cframe * CFrame.new(0, 3.4, 0), Vector3.new(20, 6.8, 6.8), color17, Enum.Material.CorrodedMetal)
	local lerped = color17:Lerp(Color3.new(), 0.35)

	for i = -1, 1, 2 do
		for j = -1, 1, 2 do
			block(
				p,
				cframe * CFrame.new(i * 9.75, 3.4, j * 3.15),
				Vector3.new(0.6, 6.9, 0.6),
				lerped,
				Enum.Material.Metal
			)
		end
	end

	if not p.low then
		for i = 0, 12 do
			block(
				p,
				cframe * CFrame.new(i * 1.4 + -8.4, 3.4, 3.44),
				Vector3.new(0.4, 6.2, 0.1),
				jitter(p, color17, 0.05), -- inferred equivalent call
				Enum.Material.CorrodedMetal,
				false
			)
		end
	end

	local v2 = cframe * CFrame.new(0, 6.8, 0)

	if p.snow then
		block(
			p,
			v2 * CFrame.new(0, 0.12, 0),
			Vector3.new(20.2, 0.24, 7),
			jitter(p, color14, 0.02), -- inferred equivalent call
			Enum.Material.Snow,
			false
		)
	end
end

local function spruce(p, position: Vector3, p2: number, flag: boolean?)
	local rng = p.rng
	local v2 = CFrame.new(position) * CFrame.Angles(0, rng:NextNumber() * 1.57, 0)
	local v3 = flag ~= false
	block(
		p,
		v2 * CFrame.new(0, p2 * 0.2, 0),
		Vector3.new(p2 * 0.05, p2 * 0.4, p2 * 0.05),
		color6,
		Enum.Material.Wood,
		v3
	)
	local v4 = p.low and 4 or 7
	local color17 = jitter(p, color13, 0.08) -- inferred equivalent call
	local v5 = p2 * 0.82 / v4

	for i = 0, v4 - 1 do
		local v6 = p2 * (0.3 - i / (v4 - 1) * 0.24)
		local v7 = v5 * 0.7
		local v8 = p2 * 0.14 + i * v5 + v7 / 2

		local cframe = CFrame.Angles(0, i % 2 * 0.7853981633974483, 0)
		block(p, v2 * CFrame.new(0, v8, 0) * cframe, Vector3.new(v6, v7, v6), color17, Enum.Material.Grass, v3)
		snowCap(p, v2 * CFrame.new(0, v8 + v7 / 2 - 0.1, 0) * cframe, v6 * 0.85, v6 * 0.85)
	end

	block(
		p,
		v2 * CFrame.new(0, p2 * 0.97, 0),
		Vector3.new(p2 * 0.04, p2 * 0.1, p2 * 0.04),
		color17,
		Enum.Material.Grass,
		v3
	)
end

local function treeline(p, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number, p8: number)
	local rng = p.rng

	if p.low then
		p6 = math.ceil(p6 * 0.5)
	end

	for _ = 1, p6 do
		spruce(p, Vector3.new(rng:NextNumber(p4, p5), 0, rng:NextNumber(p2, p3)), rng:NextNumber(p7, p8), false)
	end
end

local function bunker(p, cframe: CFrame, p2: number, p3: number, p4: number)
	local v2 = jitter(p, color, 0.04) -- inferred equivalent call
	block(p, cframe * CFrame.new(0, p4 / 2, 0), Vector3.new(p2, p4, p3), v2)

	block(
		p,
		cframe * CFrame.new(0, p4 + 0.3, 0),
		Vector3.new(p2 - 2.2399999999999998, 0.8, p3 - 2.2399999999999998),
		v2
	)

	for i = -1, 1, 2 do
		block(
			p,
			cframe * CFrame.new(0, p4 - 0.15, i * (p3 / 2 - 0.55)) * CFrame.Angles(0.7853981633974483, 0, 0),
			Vector3.new(p2 - 0.3, 1.6, 1.6),
			v2
		)
		block(
			p,
			cframe * CFrame.new(i * (p2 / 2 - 0.55), p4 - 0.15, 0) * CFrame.Angles(0, 0, 0.7853981633974483),
			Vector3.new(1.6, 1.6, p3 - 0.3),
			v2
		)
	end

	block(
		p,
		cframe * CFrame.new(0, p4 * 0.62, p3 / 2 + 0.02),
		Vector3.new(p2 * 0.45, 0.7, 0.1),
		Color3.fromRGB(18, 18, 20),
		Enum.Material.SmoothPlastic,
		false
	)
	snowCap(p, cframe * CFrame.new(0, p4 + 0.7, 0), p2 - 2.2399999999999998, p3 - 2.2399999999999998)

	for i = -1, 1, 2 do
		block(
			p,
			cframe * CFrame.new(i * (p2 / 2 + 1.2), 0.6, 0),
			Vector3.new(3, 1.2, p3 + 1),
			p.ground:Lerp(color5, 0.3),
			p.groundMat
		)
	end
end

local function gableRoof(p, cframe: CFrame, p2: number, p3: number, p4: number, p5: number, color17: Color3, slate, p6: number?)
	local v2 = p3 / 2 / (math.cos)(p5) + 0.6

	for i = -1, 1, 2 do
		local v3

		if p6 and i == 1 then
			v3 = p2 * p6
		else
			v3 = p2
		end

		local v4 = (not p6 or i ~= 1) and 0 or -(p2 - v3) / 2
		local v5 = cframe * CFrame.new(v4, p4 + (math.tan)(p5) * p3 / 4, i * p3 / 4) * CFrame.Angles(i * p5, 0, 0)
		block(p, v5, Vector3.new(v3 + 0.8, 0.45, v2), color17, slate)

		if p.snow then
			block(p, v5 * CFrame.new(0, 0.3, 0), Vector3.new(v3 + 0.8, 0.2, v2), color14, Enum.Material.Snow, false)
		end
	end
end

local function poles(p, p2, p3: number)
	local clone = table.clone(p2)
	table.insert(clone, 3, -1000)
	local v2 = {}

	for k, v3 in clone do
		local v4 = v3 == -1000
		local v5 = k == 4 and 0.15707963267948966 or math.rad((p.rng:NextNumber(-2, 2)))
		local v6

		if v4 then
			v6 = CFrame.new(-17, 6, -6) * CFrame.Angles(0, 0.6981317007977318, 0)
		else
			v6 = CFrame.new(v3, 0, p3 + k % 2 * 5) * CFrame.Angles(0, 0.13962634015954636, v5)
		end

		local v7 = block(p, v6 * CFrame.new(0, 13, 0), Vector3.new(0.75, 26, 0.75), color6, Enum.Material.Wood)
		local v8 = block(p, v6 * CFrame.new(0, 24, 0), Vector3.new(6, 0.45, 0.45), color6, Enum.Material.Wood)
		local v9 = {}

		for k2, v10 in { -2.7, 0, 2.7 } do
			local attachment = Instance.new("Attachment")

			attachment.Position = k2 == 2 and Vector3.new(0, 12.8, 0) or Vector3.new(v10, 0.3, 0)
			attachment.Axis = Vector3.new(0, -1, 0)
			attachment.SecondaryAxis = Vector3.new(0, 0, 1)
			local parent = if k2 == 2 then v7 else v8
			attachment.Parent = parent
			v9[k2] = attachment
		end

		v2[k] = v9
	end

	for i = 1, #v2 - 1 do
		for j = 1, 3 do
			local beam = Instance.new("Beam")
			beam.Attachment0 = v2[i][j]
			beam.Attachment1 = v2[i + 1][j]
			local curveSize = (clone[i] == -1000 or clone[i + 1] == -1000) and 5 or 3.2
			beam.CurveSize0 = curveSize
			beam.CurveSize1 = -curveSize
			beam.Width0 = 0.09
			beam.Width1 = 0.09
			beam.Segments = 14
			beam.FaceCamera = true
			beam.Color = ColorSequence.new(Color3.fromRGB(28, 28, 30))
			beam.Transparency = NumberSequence.new(0)
			beam.LightInfluence = 1
			beam.Parent = v2[i][j].Parent
		end
	end
end

local function berm(p, p2: number, color17: Color3)
	local rng = p.rng
	local total = -90

	while total < 90 do
		local number = rng:NextNumber(10, 22)
		local number2 = rng:NextNumber(0.75, 1.1)
		local v2 = p2 + rng:NextNumber(-2, 2)

		for i = 0, 2 do
			block(
				p,
				CFrame.new(total + number / 2, number2 * (i + 0.5), v2),
				Vector3.new(number - i * 1.2, number2, 9 - i * 2.8),
				jitter(p, color17, 0.05), -- inferred equivalent call
				p.groundMat,
				i == 0
			)
		end

		total += number - 0.6
	end
end

local function ridges(p, color17: Color3, p2: number, p3: number, flag: boolean?)
	local rng = p.rng
	local total = -900

	while total < 900 do
		local number = rng:NextNumber(160, 320)
		local number2 = rng:NextNumber(p2, p3)
		local number3 = rng:NextNumber(-900, -720)

		for i = 0, 3 do
			local v2

			if flag and i >= 2 then
				v2 = color14:Lerp(color17, 0.2)
			else
				v2 = jitter(p, color17, 0.04) -- inferred equivalent call
			end

			local cframe = CFrame.new(
				total + number / 2 + i % 2 * number * 0.06,
				number2 * (i + 0.5) / 4,
				number3 - i * 18
			)
			local vector3 = Vector3.new(number * (1 - i * 0.22), number2 / 4, 120)
			local v3

			if flag and i >= 2 then
				v3 = Enum.Material.Snow
			else
				v3 = p.groundMat
			end

			block(p, cframe, vector3, v2, v3, false)
		end

		total += number * 0.75
	end
end

local function skyline(p, list, p2: number, p3: number, flag: boolean)
	local rng = p.rng
	local total = -300

	while total < 300 do
		local number = rng:NextNumber(12, 34)
		local number2 = rng:NextNumber(p2, p3)
		local number3 = rng:NextNumber(-340, -190)
		local number4 = rng:NextNumber(12, 28)
		local color17 = jitter(p, list[rng:NextInteger(1, #list)], 0.08) -- inferred equivalent call
		block(
			p,
			CFrame.new(total + number / 2, number2 / 2, number3),
			Vector3.new(number, number2, number4),
			color17,
			nil,
			false
		)
		local lerped = color17:Lerp(Color3.fromRGB(30, 30, 34), 0.7)
		local total2 = 4

		while total2 < number2 - 2 do
			if rng:NextNumber() < 0.85 then
				block(
					p,
					CFrame.new(total + number / 2, total2, number3 + number4 / 2 + 0.1),
					Vector3.new(number * 0.84, 1.5, 0.2),
					lerped,
					Enum.Material.SmoothPlastic,
					false
				)
			end

			total2 += 4.6
		end

		local number5 = rng:NextNumber()

		if number5 < 0.4 then
			local v2 = number * rng:NextNumber(0.3, 0.6)
			local number6 = rng:NextNumber(5, 16)
			block(
				p,
				CFrame.new(
					total + number / 2 + (number - v2) / 2 * (rng:NextNumber() < 0.5 and -1 or 1),
					number2 + number6 / 2,
					number3
				),
				Vector3.new(v2, number6, 10),
				color17,
				nil,
				false
			)
		elseif flag and number5 < 0.55 then
			block(
				p,
				CFrame.new(total + number * 0.7, number2 + 9, number3),
				Vector3.new(2.2, 18, 2.2),
				color2,
				nil,
				false
			)
		end

		snowCap(p, CFrame.new(total + number / 2, number2, number3), number, number4)
		total += number + rng:NextNumber(-3, 14)
	end
end

local function frame(p, cframe: CFrame, p2: number, p3: number, p4: number, p5: number, p6: number, color17: Color3, p7: number)
	local rng = p.rng

	for i = 0, p2 do
		for j = 0, p3 do
			local v2 = p4 - (not (rng:NextNumber() < 0.25) and 0 or rng:NextInteger(1, 2))

			if v2 > 0 then
				block(
					p,
					cframe * CFrame.new((i - p2 / 2) * p5, v2 * p6 / 2, (j - p3 / 2) * p5),
					Vector3.new(p7, v2 * p6, p7),
					color17,
					nil,
					false
				)
			end
		end
	end

	for i = 1, p4 do
		for j = 0, p3 do
			if rng:NextNumber() < 0.85 then
				block(
					p,
					cframe * CFrame.new(0, i * p6, (j - p3 / 2) * p5),
					Vector3.new(p2 * p5 + p7, p7 * 0.8, p7 * 0.8),
					color17,
					nil,
					false
				)
			end
		end

		for j = 0, p2 do
			if rng:NextNumber() < 0.7 then
				block(
					p,
					cframe * CFrame.new((j - p2 / 2) * p5, i * p6, 0),
					Vector3.new(p7 * 0.8, p7 * 0.8, p3 * p5),
					color17,
					nil,
					false
				)
			end
		end
	end
end

local function ground(data, color17: Color3, color18: Color3?)
	local rng = data.rng

	for i = 1, data.low and 8 or 16 do
		local number = rng:NextNumber(-34, 34)
		local number2 = rng:NextNumber(-44, 9)
		local v2

		if color18 and i % 3 == 0 then
			v2 = color18
		else
			v2 = data.ground:Lerp(color17, rng:NextNumber(0.16, 0.38))
		end

		local v3 = CFrame.new(number, i * 0.004 + 0.01, number2) * CFrame.Angles(0, rng:NextNumber() * 3.14, 0)
		local vector3 = Vector3.new(rng:NextNumber(4, 13), 0.05, rng:NextNumber(3, 8))
		local color19 = jitter(data, v2, 0.05) -- inferred equivalent call
		local v4

		if data.snow then
			v4 = Enum.Material.Snow
		else
			v4 = Enum.Material.Ground
		end

		block(data, v3, vector3, color19, v4, false)
	end

	local lerped = data.ground:Lerp(color17, 0.75)

	for i = -1, 1, 2 do
		for j = 0, 5 do
			block(
				data,
				CFrame.new(j * 11 + -30 + i * 1.6, 0.09, -8 - j * 6) * CFrame.Angles(0, math.rad(j * 4 + -62), 0),
				Vector3.new(1.1, 0.04, 12.5),
				lerped,
				Enum.Material.Ground,
				false
			)
		end
	end
end

local function rubble(p, list)
	local rng = p.rng

	for _ = 1, p.low and 18 or 36 do
		local number = rng:NextNumber(-22, 22)
		local number2 = rng:NextNumber(-26, 8)

		if not clearOfFeet(number, number2, 2.2) then
			continue
		end

		local v2

		if number2 > -2 then
			v2 = rng:NextNumber(0.25, 0.6)
		else
			v2 = rng:NextNumber(0.4, 1.4)
		end

		block(
			p,
			CFrame.new(number, v2 * 0.25, number2) * spin(p), -- inferred equivalent call
			Vector3.new(v2, v2 * rng:NextNumber(0.5, 1), v2 * rng:NextNumber(0.6, 1.2)),
			jitter(p, list[rng:NextInteger(1, #list)], 0.08), -- inferred equivalent call
			nil,
			number2 < -2
		)
	end

	heap(p, Vector3.new(-8.5, 0, 6.5), 2.6, 0.9, p.low and 6 or 14, 0.45, list)
	heap(p, Vector3.new(8, 0, 7.5), 2.2, 0.7, p.low and 5 or 11, 0.45, list)
end

local function emitterPart(p, cframe: CFrame, size: Vector3) -- 4 equivalent calls inferred from this helper
	local v2 = block(p, cframe, size, Color3.new(), Enum.Material.SmoothPlastic, false)
	v2.Transparency = 1
	return v2
end

local function smoke(p, position: Vector3, p2: number, rate: number, color17: Color3)
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
	particleEmitter.Rate = rate
	particleEmitter.Lifetime = NumberRange.new(9, 14)
	particleEmitter.Speed = NumberRange.new(p2 * 0.35, p2 * 0.6)
	particleEmitter.SpreadAngle = Vector2.new(8, 8)
	particleEmitter.Acceleration = Vector3.new(2.2, 0.4, 0)
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, p2),
		NumberSequenceKeypoint.new(1, p2 * 3.5)
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.1, p2 < 8 and 0.6 or 0.42),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Color = ColorSequence.new(color17, color17:Lerp(Color3.new(1, 1, 1), 0.4))
	particleEmitter.RotSpeed = NumberRange.new(-12, 12)
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.LightInfluence = 1
	particleEmitter.Parent = emitterPart(p, CFrame.new(position), Vector3.new(p2, 1, p2)) -- inferred equivalent call
	particleEmitter:Emit(((math.floor)(rate * 9)))
end

local function air(p, color17: Color3, flag: boolean)
	smoke(p, Vector3.new(-95, 4, -230), 16, 4.5, Color3.fromRGB(58, 56, 54))
	smoke(p, Vector3.new(70, 4, -150), 18, 4.5, Color3.fromRGB(62, 60, 58))
	smoke(p, Vector3.new(-26, 1, -60), 5, 2.5, Color3.fromRGB(80, 78, 76))

	if p.snow then
		local particleEmitter = Instance.new("ParticleEmitter")
		particleEmitter.Shape = Enum.ParticleEmitterShape.Box
		particleEmitter.Rate = 60
		particleEmitter.Lifetime = NumberRange.new(6, 9)
		particleEmitter.Speed = NumberRange.new(2.5, 4)
		particleEmitter.EmissionDirection = Enum.NormalId.Bottom
		particleEmitter.SpreadAngle = Vector2.new(15, 15)
		particleEmitter.Acceleration = Vector3.new(0.8, 0, 0)
		particleEmitter.Size = NumberSequence.new(0.08, 0.14)
		particleEmitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.1, 0.15),
			NumberSequenceKeypoint.new(1, 0.4)
		})
		particleEmitter.Color = ColorSequence.new(Color3.new(1, 1, 1))
		particleEmitter.LightEmission = 0.3
		particleEmitter.Parent = emitterPart(p, CFrame.new(0, 16, -6), Vector3.new(50, 1, 34)) -- inferred equivalent call
		particleEmitter:Emit(200)
	else
		local particleEmitter = Instance.new("ParticleEmitter")
		particleEmitter.Shape = Enum.ParticleEmitterShape.Box
		particleEmitter.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
		particleEmitter.Rate = 14
		particleEmitter.Lifetime = NumberRange.new(5, 8)
		particleEmitter.Speed = NumberRange.new(0.2, 0.6)
		particleEmitter.SpreadAngle = Vector2.new(180, 180)
		particleEmitter.Acceleration = Vector3.new(0.25, 0.05, 0)
		particleEmitter.Size = NumberSequence.new(0.07, 0.12)
		particleEmitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.3, 0.35),
			NumberSequenceKeypoint.new(1, 1)
		})
		particleEmitter.Color = ColorSequence.new(color17)
		particleEmitter.LightEmission = 0.4
		particleEmitter.Parent = emitterPart(p, CFrame.new(0, 4.5, -2), Vector3.new(30, 8, 14)) -- inferred equivalent call
		particleEmitter:Emit(60)
	end

	if flag then
		local particleEmitter = Instance.new("ParticleEmitter")
		particleEmitter.Shape = Enum.ParticleEmitterShape.Box
		particleEmitter.Rate = 3
		particleEmitter.Lifetime = NumberRange.new(4, 6)
		particleEmitter.Speed = NumberRange.new(0.8, 1.6)
		particleEmitter.SpreadAngle = Vector2.new(25, 25)
		particleEmitter.Acceleration = Vector3.new(0.4, 0.3, 0)
		particleEmitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.1),
			NumberSequenceKeypoint.new(1, 0)
		})
		particleEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 150, 60))
		particleEmitter.LightEmission = 1
		particleEmitter.Parent = emitterPart(p, CFrame.new(-4, 0.5, -8), Vector3.new(36, 1, 10)) -- inferred equivalent call
		particleEmitter:Emit(10)
	end
end

local v2 = {
	drywell = function(p)
		local color17 = Color3.fromRGB(176, 112, 84)
		ground(p, color5, p.ground:Lerp(color17, 0.45))
		rubble(p, { color3, color, color2 })
		local v2 = CFrame.new(-15, 0, -22) * CFrame.Angles(0, 0.3141592653589793, 0)
		local v3 = {
			21,
			22.5,
			20,
			18,
			18.5,
			14,
			12.5,
			9,
			6.5,
			3.5
		}
		local v4 = facade(p, v2, v3, 2.6, 1.6, color3, nil, 3.6, color15)

		for i = 4, #v3 do
			rebar(p, v2 * CFrame.new(v4 + (i - 0.5) * 2.6, v3[i], 0), 2)
		end

		block(
			p,
			v2 * CFrame.new(v4 + 0.8, 10.5, -6),
			Vector3.new(1.6, 21, 10.4),
			jitter(p, color3:Lerp(Color3.new(), 0.2), 0.04)
		)
		block(
			p,
			v2 * CFrame.new(v4 + #v3 * 2.6 - 1.5, 4.6, 1.2) * CFrame.Angles(-0.13962634015954636, 0, -0.5585053606381855),
			Vector3.new(6.5, 0.7, 3.6),
			color3
		)
		heap(p, (v2 * CFrame.new(3, 0, 3.5)).Position, 7, 2.6, p.low and 8 or 16, 1, { color3, color })
		twall(p, CFrame.new(8.8, 0, -15.5) * CFrame.Angles(0, -0.20943951023931956, 0))
		twall(p, CFrame.new(12.1, 0, -16.2) * CFrame.Angles(0, -0.13962634015954636, 0))
		twall(p, CFrame.new(15.6, 0, -16.6) * CFrame.Angles(0, -0.24434609527920614, -0.19198621771937624))
		container(p, CFrame.new(22, 0, -28) * CFrame.Angles(0, -0.4188790204786391, 0), color10)
		container(p, CFrame.new(25, 6.8, -29) * CFrame.Angles(0, -0.3490658503988659, 0), Color3.fromRGB(64, 96, 84))
		frame(p, CFrame.new(14, 0, -70) * CFrame.Angles(0, -0.17453292519943295, 0), 3, 2, 6, 6, 4.6, color3, 1)
		berm(p, -44, p.ground:Lerp(color17, 0.5))
		poles(p, { -64, -28, 6, 40, 76 }, -66)
		skyline(p, { color3, Color3.fromRGB(176, 170, 156), color }, 18, 70, false)
		ridges(p, p.ground:Lerp(color17, 0.4), 50, 130)

		if not p.low then
			air(p, Color3.fromRGB(255, 232, 196), true)
		end
	end,
	saltpan = function(p)
		ground(p, color5, Color3.fromRGB(226, 224, 216))
		rubble(p, { color, color9, color2 })
		frame(p, CFrame.new(-17, 0, -24) * CFrame.Angles(0, 0.3490658503988659, 0), 3, 2, 6, 5, 4.4, color9, 0.8)
		heap(p, Vector3.new(-12, 0, -17), 5, 1.8, p.low and 6 or 12, 1, { color9, color })

		local v2 = CFrame.new(16, 0, -18) * CFrame.Angles(0, -0.5235987755982988, 0)

		for i = 0, 4 do
			block(p, v2 * CFrame.new(i * 6 - 12, 3.5, 0), Vector3.new(0.6, 7, 3.6), color9, Enum.Material.Metal)
		end

		for k, v3 in { 6.2, 6.2, 7.6 } do
			local v4 = v2 * CFrame.new(0, v3, (k - 2) * 1.1)
			local v5 = Vector3.new(30, 0.9, 0.9)
			local v6

			if k == 3 then
				v6 = Color3.fromRGB(176, 150, 70)
			else
				v6 = Color3.fromRGB(150, 150, 146)
			end

			local block_2 = block(p, v4, v5, v6, Enum.Material.Metal)
			block_2.Shape = Enum.PartType.Cylinder
		end

		container(p, CFrame.new(10, 0, -30) * CFrame.Angles(0, 0.17453292519943295, 0), color10)
		container(p, CFrame.new(31, 0, -34) * CFrame.Angles(0, -0.3490658503988659, 0), Color3.fromRGB(56, 92, 82))
		twall(p, CFrame.new(7.5, 0, -12) * CFrame.Angles(0, -0.3141592653589793, 0))

		for _, v3 in {
			{ -40, -110, 58 },
			{ -18, -150, 74 },
			{ 30, -125, 52 },
			{ 58, -170, 66 }
		} do
			local cframe = CFrame.new(v3[1], 0, v3[2])
			block(p, cframe * CFrame.new(0, v3[3] / 2, 0), Vector3.new(4.5, v3[3], 4.5), color, nil, false)
			block(
				p,
				cframe * CFrame.new(0, v3[3] - 2, 0),
				Vector3.new(4.9, 4, 4.9),
				Color3.fromRGB(40, 40, 42),
				nil,
				false
			)
			block(
				p,
				cframe * CFrame.new(0, v3[3] * 0.6, 0),
				Vector3.new(4.8, 1.2, 4.8),
				Color3.fromRGB(150, 70, 60),
				nil,
				false
			)
			block(p, cframe * CFrame.new(0, 2, 0), Vector3.new(9, 4, 9), color2, nil, false)
		end

		berm(p, -46, p.ground:Lerp(color5, 0.3))
		poles(p, { -64, -28, 6, 40, 76 }, -66)
		skyline(p, { color, color9, Color3.fromRGB(160, 156, 146) }, 10, 36, true)
		ridges(p, color16, 70, 170)

		if not p.low then
			smoke(p, Vector3.new(-18, 74, -150), 9, 3, Color3.fromRGB(70, 68, 66))
			air(p, Color3.fromRGB(255, 236, 205), true)
		end
	end,
	ironfield = function(data)
		ground(data, color5)
		rubble(data, { color12, color12, color7 })

		local rng = data.rng

		for i = 0, 15 do
			if not (rng:NextNumber() > 0.18) then
				continue
			end

			local number = rng:NextNumber(1.6, 2.4)
			block(
				data,
				CFrame.new(i * 2.1 + -26, number / 2, -13 - i * 0.35) * CFrame.Angles(0, -0.17453292519943295, 0),
				Vector3.new(2.15, number, 1.4),
				jitter(data, color12, 0.08), -- inferred equivalent call
				Enum.Material.Slate
			)
		end

		local v2 = CFrame.new(-17, 0, -26) * CFrame.Angles(0, 0.3839724354387525, 0)
		block(data, v2 * CFrame.new(0, 0.6, 0), Vector3.new(18.4, 1.2, 12.4), color12, Enum.Material.Slate)

		for i = -1, 1, 2 do
			block(
				data,
				v2 * CFrame.new(0, 5.2, i * 6),
				Vector3.new(18, 8, 0.6),
				jitter(data, color7, 0.06), -- inferred equivalent call
				Enum.Material.WoodPlanks
			)
			block(
				data,
				v2 * CFrame.new(i * 9, 5.2, 0),
				Vector3.new(0.6, 8, 12),
				jitter(data, color7, 0.06), -- inferred equivalent call
				Enum.Material.WoodPlanks
			)
		end

		block(
			data,
			v2 * CFrame.new(-3, 4, 6.35),
			Vector3.new(4.5, 6, 0.2),
			Color3.fromRGB(28, 24, 22),
			Enum.Material.SmoothPlastic,
			false
		)
		block(
			data,
			v2 * CFrame.new(5, 6.5, 6.35),
			Vector3.new(2, 1.6, 0.2),
			Color3.fromRGB(28, 24, 22),
			Enum.Material.SmoothPlastic,
			false
		)
		gableRoof(
			data,
			v2 * CFrame.new(0, 9.2, 0),
			18,
			12.6,
			0,
			0.5585053606381855,
			Color3.fromRGB(70, 62, 58),
			Enum.Material.Slate,
			0.55
		)

		for i = -1, 1, 2 do
			block(
				data,
				v2 * CFrame.new(i * 9, 11.3, 0) * CFrame.Angles(0.7853981633974483, 0, 0),
				Vector3.new(0.6, 5.2, 5.2),
				color7,
				Enum.Material.WoodPlanks
			)
		end

		heap(data, (v2 * CFrame.new(6, 0, 8)).Position, 4, 1.4, data.low and 4 or 9, 0.8, { color7, color12 })

		for _, v3 in { Vector3.new(-6, 0, -16), Vector3.new(-3.6, 0, -16.6), Vector3.new(-4.8, 1.6, -16.3) } do
			block(
				data,
				CFrame.new(v3 + Vector3.new(0, 0.8, 0)) * CFrame.Angles(0, data.rng:NextNumber(-0.3, 0.3), 0),
				Vector3.new(2.3, 1.6, 1.6),
				Color3.fromRGB(196, 168, 96),
				Enum.Material.Fabric
			)
		end

		bunker(data, CFrame.new(16, 0, -22) * CFrame.Angles(0, -0.3141592653589793, 0), 14, 9, 5)

		for i = 0, 6 do
			local v3 = CFrame.new(i * 3 + 9, 0, -12 - i * 0.8) * CFrame.Angles(0, -0.2617993877991494, 0)
			block(data, v3 * CFrame.new(0, 1.1, 0), Vector3.new(0.35, 2.2, 0.35), color7, Enum.Material.Wood)

			if not (i < 6) then
				continue
			end

			block(data, v3 * CFrame.new(1.5, 1.6, 0), Vector3.new(3, 0.25, 0.2), color7, Enum.Material.Wood)
			block(data, v3 * CFrame.new(1.5, 0.9, 0), Vector3.new(3, 0.25, 0.2), color7, Enum.Material.Wood)
		end

		treeline(data, -60, -110, -120, -30, 16, 18, 30)
		treeline(data, -55, -100, 30, 120, 16, 18, 30)
		treeline(data, -140, -220, -200, 200, 26, 22, 34)
		poles(data, { -64, -28, 6, 40, 76 }, -66)
		ridges(data, data.ground:Lerp(Color3.fromRGB(70, 92, 70), 0.4), 60, 150)

		if not data.low then
			air(data, Color3.fromRGB(255, 240, 210), true)
		end
	end,
	pinewold = function(p)
		ground(p, color5)
		rubble(p, { color11, color, color5 })
		local v2 = CFrame.new(-16, 0, -24) * CFrame.Angles(0, 0.3141592653589793, 0)
		local v3 = {
			13.5,
			13.5,
			13.5,
			13.5,
			13.5,
			13.5,
			11,
			8.5,
			5,
			2.5
		}
		local v4 = facade(p, v2, v3, 2.8, 1.4, color11, Enum.Material.Brick, 4.4, Color3.fromRGB(150, 196, 222))
		block(p, v2 * CFrame.new(0, 0.5, 0.6), Vector3.new(#v3 * 2.8, 1, 0.4), color)
		gableRoof(
			p,
			v2 * CFrame.new(v4 + 8.399999999999999, 13.5, -4.3),
			16.799999999999997,
			10,
			0,
			0.4886921905584123,
			Color3.fromRGB(96, 98, 102),
			Enum.Material.Slate
		)
		block(
			p,
			v2 * CFrame.new(v4 + 0.7, 6.75, -4.3),
			Vector3.new(1.4, 13.5, 8.6),
			jitter(p, color11, 0.05), -- inferred equivalent call
			Enum.Material.Brick
		)
		heap(p, (v2 * CFrame.new(5, 0, 3.5)).Position, 6, 2.2, p.low and 7 or 14, 0.9, { color11, color11, color })

		local cframe = CFrame.new(-6, 0, -120)

		for i = 0, 11 do
			local v5 = cframe * CFrame.new(0, i * 3.5 + 1.75, 0)
			local v6

			if i % 4 == 2 or i % 4 == 3 then
				v6 = Color3.fromRGB(176, 56, 50)
			else
				v6 = Color3.fromRGB(226, 224, 218)
			end

			block(p, v5, Vector3.new(5, 3.5, 5), v6, nil, false)
		end

		block(p, cframe * CFrame.new(0, 43.5, 0), Vector3.new(7, 3, 7), Color3.fromRGB(226, 224, 218), nil, false)
		block(p, cframe * CFrame.new(0, 45.6, 0), Vector3.new(7.6, 0.6, 7.6), Color3.fromRGB(60, 60, 64), nil, false)
		block(
			p,
			cframe * CFrame.new(0, 50, 0),
			Vector3.new(0.4, 8, 0.4),
			Color3.fromRGB(60, 60, 64),
			Enum.Material.Metal,
			false
		)

		local v5 = CFrame.new(14, 0, -15) * CFrame.Angles(0, -0.24434609527920614, 0)

		for i = 0, 5 do
			local v6 = v5 * CFrame.new(i * 3.2 - 6, 0, 0)
			block(
				p,
				v6 * CFrame.new(0, 0.9, -1.8),
				Vector3.new(3.3, 1.8, 2.4),
				jitter(p, p.ground:Lerp(color5, 0.6), 0.05), -- inferred equivalent call
				Enum.Material.Ground
			)
			block(
				p,
				v6 * CFrame.new(0, 0.7, 1.5),
				Vector3.new(3.3, 1.4, 1.8),
				jitter(p, p.ground:Lerp(color5, 0.5), 0.05), -- inferred equivalent call
				Enum.Material.Ground
			)
			block(p, v6 * CFrame.new(0, 0.8, -0.55), Vector3.new(3.2, 1.6, 0.25), color7, Enum.Material.WoodPlanks)
			block(p, v6 * CFrame.new(1.55, 1.1, -0.55), Vector3.new(0.3, 2.2, 0.3), color6, Enum.Material.Wood)
		end

		bunker(p, CFrame.new(22, 0, -30) * CFrame.Angles(0, -0.3839724354387525, 0), 12, 8, 4.5)

		for i = 0, 5 do
			local v6 = i < 3 and 0 or 1
			local block_2 = block(
				p,
				CFrame.new(i % 3 * 1.1 + 7 + v6 * 0.55, v6 * 0.95 + 0.5, -25) * CFrame.Angles(0, 1.3962634015954636, 0),
				Vector3.new(7, 1, 1),
				Color3.fromRGB(110, 82, 58),
				Enum.Material.Wood
			)
			block_2.Shape = Enum.PartType.Cylinder
		end

		treeline(p, -40, -80, -110, -40, 14, 20, 32)
		treeline(p, -45, -85, 35, 110, 14, 20, 32)
		treeline(p, -110, -230, -220, 220, 34, 24, 36)
		poles(p, { -64, -28, 6, 40, 76 }, -66)
		ridges(p, p.ground:Lerp(Color3.fromRGB(80, 100, 80), 0.4), 50, 120)

		if not p.low then
			air(p, Color3.fromRGB(255, 240, 210), true)
		end
	end,
	frostmill = function(p)
		ground(p, Color3.fromRGB(170, 176, 186), Color3.fromRGB(120, 116, 112))
		rubble(p, { color, color7, color12 })
		local v2 = CFrame.new(-18, 0, -26) * CFrame.Angles(0, 0.3490658503988659, 0)
		block(p, v2 * CFrame.new(0, 0.6, 0), Vector3.new(20.4, 1.2, 12.4), color12, Enum.Material.Slate)

		for i = -1, 1, 2 do
			block(
				p,
				v2 * CFrame.new(0, 5.2, i * 6),
				Vector3.new(20, 8, 0.6),
				jitter(p, Color3.fromRGB(96, 66, 50), 0.06), -- inferred equivalent call
				Enum.Material.WoodPlanks
			)
			block(
				p,
				v2 * CFrame.new(i * 10, 5.2, 0),
				Vector3.new(0.6, 8, 12),
				jitter(p, Color3.fromRGB(96, 66, 50), 0.06), -- inferred equivalent call
				Enum.Material.WoodPlanks
			)
		end

		for i = 0, 3 do
			block(
				p,
				v2 * CFrame.new(i * 4.6 + -7, 6, 6.35),
				Vector3.new(2, 2, 0.2),
				Color3.fromRGB(46, 52, 60),
				Enum.Material.Glass,
				false
			)
			block(
				p,
				v2 * CFrame.new(i * 4.6 + -7, 6, 6.42),
				Vector3.new(2.4, 0.25, 0.1),
				Color3.fromRGB(214, 210, 200),
				Enum.Material.WoodPlanks,
				false
			)
			local v3 = v2 * CFrame.new(i * 4.6 + -7, 7.05, 6.45)

			if p.snow then
				block(
					p,
					v3 * CFrame.new(0, 0.12, 0),
					Vector3.new(2.6, 0.24, 0.5),
					jitter(p, color14, 0.02), -- inferred equivalent call
					Enum.Material.Snow,
					false
				)
			end
		end

		block(
			p,
			v2 * CFrame.new(4, 3.6, 6.35),
			Vector3.new(4, 5.2, 0.2),
			Color3.fromRGB(28, 24, 22),
			Enum.Material.SmoothPlastic,
			false
		)
		gableRoof(
			p,
			v2 * CFrame.new(0, 9.2, 0),
			20,
			12.6,
			0,
			0.5934119456780721,
			Color3.fromRGB(78, 70, 66),
			Enum.Material.Slate
		)
		block(p, v2 * CFrame.new(6, 14, -2), Vector3.new(2.2, 7, 2.2), color11, Enum.Material.Brick)

		for i = 0, 1 do
			for j = 0, 5 do
				local v3 = j < 3 and 0 or 1
				local block_2 = block(
					p,
					CFrame.new(i * 7 + 8 + j % 3 * 1.1 + v3 * 0.55, v3 * 0.95 + 0.5, -17 - i * 3) * CFrame.Angles(0, 1.361356816555577, 0),
					Vector3.new(6, 1, 1),
					Color3.fromRGB(110, 82, 58),
					Enum.Material.Wood
				)
				block_2.Shape = Enum.PartType.Cylinder
			end

			block(
				p,
				CFrame.new(i * 7 + 9.6, 2.05, -17 - i * 3) * CFrame.Angles(0, -0.20943951023931956, 0),
				Vector3.new(2.6, 0.3, 6),
				color14,
				Enum.Material.Snow,
				false
			)
		end

		local v3 = CFrame.new(22, 0, -30) * CFrame.Angles(0, -0.3141592653589793, 0)

		for i = -1, 1, 2 do
			block(p, v3 * CFrame.new(0, 0.15, i * 1.6), Vector3.new(40, 0.3, 0.3), color9, Enum.Material.Metal)
		end

		block(
			p,
			v3 * CFrame.new(0, 3.2, 0),
			Vector3.new(14, 4.4, 5.4),
			Color3.fromRGB(110, 46, 40),
			Enum.Material.CorrodedMetal
		)
		block(p, v3 * CFrame.new(0, 0.8, 0), Vector3.new(12, 1, 4), Color3.fromRGB(30, 30, 32), Enum.Material.Metal)
		local v4 = v3 * CFrame.new(0, 5.4, 0)

		if p.snow then
			block(
				p,
				v4 * CFrame.new(0, 0.12, 0),
				Vector3.new(14.2, 0.24, 5.6),
				jitter(p, color14, 0.02), -- inferred equivalent call
				Enum.Material.Snow,
				false
			)
		end

		twall(p, CFrame.new(8.5, 0, -11.5) * CFrame.Angles(0, -0.24434609527920614, 0))

		local cframe = CFrame.new(30, 0, -290)
		block(p, cframe * CFrame.new(0, 11, 0), Vector3.new(190, 22, 8), Color3.fromRGB(150, 156, 164), nil, false)

		for i = 0, 11 do
			block(
				p,
				cframe * CFrame.new(i * 16 + -88, 13, 5),
				Vector3.new(4, 26, 4),
				Color3.fromRGB(120, 126, 136),
				nil,
				false
			)
			local v5 = cframe * CFrame.new(i * 16 + -88, 26, 5)

			if p.snow then
				block(
					p,
					v5 * CFrame.new(0, 0.12, 0),
					Vector3.new(4.2, 0.24, 4.2),
					jitter(p, color14, 0.02), -- inferred equivalent call
					Enum.Material.Snow,
					false
				)
			end
		end

		for _, v5 in { -1, 1 } do
			block(
				p,
				cframe * CFrame.new(v5 * 97, 17, 0),
				Vector3.new(12, 34, 12),
				Color3.fromRGB(150, 156, 164),
				nil,
				false
			)
			local v6 = cframe * CFrame.new(v5 * 97, 34, 0)

			if p.snow then
				block(
					p,
					v6 * CFrame.new(0, 0.12, 0),
					Vector3.new(12.2, 0.24, 12.2),
					jitter(p, color14, 0.02), -- inferred equivalent call
					Enum.Material.Snow,
					false
				)
			end
		end

		local v5 = cframe * CFrame.new(0, 22, 0)

		if p.snow then
			block(
				p,
				v5 * CFrame.new(0, 0.12, 0),
				Vector3.new(190.2, 0.24, 8.2),
				jitter(p, color14, 0.02), -- inferred equivalent call
				Enum.Material.Snow,
				false
			)
		end

		treeline(p, -45, -95, -120, -35, 16, 18, 30)
		treeline(p, -50, -100, 35, 120, 16, 18, 30)
		treeline(p, -170, -260, -240, 240, 30, 22, 34)
		poles(p, { -64, -28, 6, 40, 76 }, -66)
		ridges(p, Color3.fromRGB(110, 120, 134), 110, 230, true)

		if not p.low then
			air(p, Color3.new(1, 1, 1), false)
		end
	end
}
return {
	build = function(parent, frame2: CFrame, p, low: boolean, p2: string?)
		local v3 = p2 or ReplicatedStorage:WaitForChild("Game"):GetAttribute("Map")
		local v4 = (type(v3) ~= "string" or not v2[v3]) and "drywell" or v3
		local set = Instance.new("Model")
		set.Name = "Set"
		local v5 = {
			parent = set,
			frame = frame2,
			rng = Random.new(),
			low = low,
			ground = p.color,
			groundMat = p.material,
			snow = v4 == "frostmill"
		}

		v2[v4](v5)
		set.Parent = parent
	end
}