local Style = require(script.Parent:WaitForChild("Style"))

local ClaimFx = {}
ClaimFx.GLOW = "rbxassetid://133718950618586"
ClaimFx.SPARKLE = "rbxassetid://130600362391445"
local color = Color3.fromRGB(214, 164, 58)
local v = {
	Style.HAZARD,
	Style.HAZARD,
	Style.WHITE,
	color,
	Style.ORANGE,
	Color3.fromRGB(120, 214, 96)
}

local v2 = { Color3.fromRGB(255, 244, 205), Style.HAZARD, Style.ORANGE }
local color2 = Color3.fromRGB(62, 62, 66)
local color3 = Color3.fromRGB(120, 84, 26)
local color4 = Color3.fromRGB(255, 226, 150)

function ClaimFx.image(parent, name: string, image: string, imageColor: Color3, p: number, position: UDim2)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = name
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = image
	imageLabel.ImageColor3 = imageColor
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Size = UDim2.fromOffset(p, p)
	imageLabel.Position = position
	imageLabel.Parent = parent
	return imageLabel
end

function ClaimFx.glow(p, p2: number, color5: Color3)
	return ClaimFx.image(p, "Glow", ClaimFx.GLOW, color5, p2, UDim2.fromScale(0.5, 0.5))
end

function ClaimFx.rays(parent, p: number, color5: Color3, p2: number)
	local rays = Instance.new("CanvasGroup")
	rays.Name = "Rays"
	rays.BackgroundTransparency = 1
	rays.Size = UDim2.fromOffset(p, p)
	rays.Position = UDim2.fromScale(0.5, 0.5)
	rays.AnchorPoint = Vector2.new(0.5, 0.5)
	rays.GroupTransparency = 1
	rays.Parent = parent

	for i = 1, p2 do
		local v3

		if i % 2 == 0 then
			v3 = p * 0.05
		else
			v3 = p * 0.09
		end

		local fill = Style.fill(
			rays,
			"Ray",
			color5,
			UDim2.fromOffset(v3, p),
			UDim2.fromScale(0.5, 0.5),
			Vector2.new(0.5, 0.5)
		)
		fill.Rotation = (i - 1) * 180 / p2
		local uiGradient = Instance.new("UIGradient")
		uiGradient.Rotation = 90
		uiGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, i % 2 == 0 and 0.45 or 0.15),
			NumberSequenceKeypoint.new(1, 1)
		})

		uiGradient.Parent = fill
	end

	return rays
end

function ClaimFx.confetti(p, vector2: Vector2, p2: number, p3: number, value: number?)
	local v3 = value or 1.3
	local v4 = {}

	for _ = 1, p2 do
		local v5 = p3 * (0.26 + math.random() * 0.2)
		local v6 = p3 * (0.12 + math.random() * 0.1)
		local fill = Style.fill(
			p,
			"Confetti",
			v[math.random(#v)],
			UDim2.fromOffset(v5, v6),
			UDim2.fromOffset(vector2.X, vector2.Y),
			Vector2.new(0.5, 0.5)
		)
		fill.ZIndex = 6
		local v7 = -1.5707963267948966 + (math.random() * 2 - 1) * v3
		local v8 = p3 * (10 + math.random() * 14)
		table.insert(v4, {
			frame = fill,
			w = v5,
			h = v6,
			v = Vector2.new(math.cos(v7), (math.sin(v7))) * v8,
			spin = (math.random() * 2 - 1) * 540,
			r0 = math.random() * 180,
			flip = 7 + math.random() * 9,
			sway = p3 * (0.4 + math.random() * 0.6),
			phase = math.random() * 2 * 3.141592653589793,
			life = 1.7 + math.random() * 1
		})
	end

	local now = os.clock()
	local v5 = p3 * 16
	Style.animate(v4, function(_, p4)
		local v6 = p4 - now

		local v7 = (1 - math.exp(-2.6 * v6)) / 2.6
		local v8 = false

		for _, v9 in v4 do
			local frame = v9.frame

			if not frame.Parent then
				continue
			end

			if v9.life <= v6 then
				frame:Destroy()
			else
				local v10 = v5 * (v6 - v7) / 2.6
				local v11 = vector2 + v9.v * v7 + Vector2.new(
					math.sin(v6 * 4 + v9.phase) * v9.sway * math.min(v6 * 2, 1),
					v10
				)
				frame.Position = UDim2.fromOffset(v11.X, v11.Y)
				frame.Rotation = v9.r0 + v9.spin * v6
				frame.Size = UDim2.fromOffset(
					v9.w * (math.abs((math.cos(v6 * v9.flip + v9.phase))) * 0.85 + 0.15),
					v9.h
				)
				frame.BackgroundTransparency = math.clamp((v6 - (v9.life - 0.45)) / 0.45, 0, 1)
				v8 = true
			end
		end

		return v8
	end)
end

function ClaimFx.sparkles(p, vector2: Vector2, p2: number, p3: number, p4: number, p5: number, color5: Color3?)
	for _ = 1, p3 do
		local v3 = math.random() * p5
		local v4 = math.random() * 2 * 3.141592653589793
		local v5 = p2 * (0.3 + math.random() * 0.7)
		local v6 = vector2 + Vector2.new(math.cos(v4), math.sin(v4) * 0.8) * v5
		local v7 = p4 * (1 + math.random() * 1.4)
		local image = ClaimFx.image(
			p,
			"Sparkle",
			ClaimFx.SPARKLE,
			color5 or Style.WHITE,
			0,
			UDim2.fromOffset(v6.X, v6.Y)
		)
		image.ZIndex = 7
		image.Rotation = math.random() * 40 - 20
		local v8 = 0.4 + math.random() * 0.35
		local v9 = os.clock() + v3
		Style.animate(image, function(_, p6): boolean
			local v10 = p6 - v9

			if v10 < 0 then
				return true
			end

			local v11 = v10 / v8

			if v11 >= 1 then
				image:Destroy()
				return false
			end

			local v12 = math.sin(v11 * 3.141592653589793) ^ 0.7
			image.Size = UDim2.fromOffset(v7 * v12, v7 * v12)
			image.Rotation += 1.5
			return true
		end)
	end
end

function ClaimFx.ring(p, vector2: Vector2, p2: number, p3: number, color5: Color3, p4: number, value: number?)
	local frame = Style.frame(
		p,
		"Ring",
		UDim2.fromOffset(0, 0),
		UDim2.fromOffset(vector2.X, vector2.Y),
		Vector2.new(0.5, 0.5)
	)
	frame.ZIndex = 6
	Style.corner(frame, 999)
	local stroke = Style.stroke(frame, p3, 1, color5)

	stroke.LineJoinMode = Enum.LineJoinMode.Round
	local v3 = os.clock() + (value or 0)
	Style.animate(frame, function(_, p5): boolean
		local v4 = p5 - v3

		if v4 < 0 then
			return true
		end

		local transparency = v4 / p4

		if transparency >= 1 then
			frame:Destroy()
			return false
		end

		local v5 = p2 * Style.easeOut(transparency)
		frame.Size = UDim2.fromOffset(v5, v5)
		stroke.Thickness = math.max(1, p3 * (1 - transparency))
		stroke.Transparency = transparency
		return true
	end)
end

function ClaimFx.sparks(p, vector2: Vector2, p2: number, p3: number, value: number?)
	local v3 = value or 0.3
	local v4 = {}

	for _ = 1, p2 do
		local v5 = math.random() * 2 * 3.141592653589793
		local unit = Vector2.new(math.cos(v5), math.sin(v5) - v3).Unit
		local v6 = p3 * (14 + math.random() * 22)
		local v7 = p3 * (0.08 + math.random() * 0.06)
		local fill = Style.fill(
			p,
			"Spark",
			v2[1],
			UDim2.fromOffset(v7, v7),
			UDim2.fromOffset(vector2.X, vector2.Y),
			Vector2.new(0.5, 0.5)
		)
		fill.ZIndex = 7
		fill.BorderSizePixel = 0
		table.insert(v4, {
			frame = fill,
			v = unit * v6,
			life = 0.35 + math.random() * 0.45,
			drag = 3 + math.random() * 2.5,
			h = v7
		})
	end

	local now = os.clock()
	local v5 = p3 * 26
	Style.animate(v4, function(_, p4)
		local v6 = p4 - now
		local v7 = false

		for _, v8 in v4 do
			local frame = v8.frame

			if not frame.Parent then
				continue
			end

			local v9 = v6 / v8.life

			if v9 >= 1 then
				frame:Destroy()
			else
				v7 = true
				local v10 = math.exp(-v8.drag * v6)
				local v11 = (1 - v10) / v8.drag
				local v12 = vector2 + v8.v * v11 + Vector2.new(0, v5 * (v6 - v11) / v8.drag)
				local v13 = v8.v * v10 + Vector2.new(0, v5 * (1 - v10) / v8.drag)
				frame.Position = UDim2.fromOffset(v12.X, v12.Y)
				frame.Rotation = math.deg((math.atan2(v13.Y, v13.X)))
				frame.Size = UDim2.fromOffset(math.max(v8.h, v13.Magnitude * 0.035), v8.h)
				local backgroundColor

				if v9 < 0.25 then
					backgroundColor = v2[1]:Lerp(v2[2], v9 / 0.25)
				else
					backgroundColor = v2[2]:Lerp(v2[3], (v9 - 0.25) / 0.75)
				end

				frame.BackgroundColor3 = backgroundColor
				frame.BackgroundTransparency = math.clamp((v9 - 0.6) / 0.4, 0, 1)
			end
		end

		return v7
	end)
end

function ClaimFx.casings(p, vector2: Vector2, p2: number, p3: number, p4: number, p5: number)
	local v3 = {}

	for _ = 1, p2 do
		local v4 = p3 * 0.22
		local v5 = p3 * 0.58
		local fill = Style.fill(
			p,
			"Casing",
			color,
			UDim2.fromOffset(v4, v5),
			UDim2.fromOffset(vector2.X, vector2.Y),
			Vector2.new(0.5, 0.5)
		)
		fill.ZIndex = 6
		Style.corner(fill, (math.max(1, (math.floor(v4 / 3)))))
		local fill_2 = Style.fill(
			fill,
			"Primer",
			color3,
			UDim2.new(1, 0, 0.22, 0),
			UDim2.fromScale(0, 1),
			Vector2.new(0, 1)
		)
		fill_2.ZIndex = 6
		local fill_3 = Style.fill(fill, "Shine", color4, UDim2.new(0.3, 0, 0.7, 0), UDim2.fromScale(0.2, 0.08))
		fill_3.ZIndex = 6
		local v6 = p4 + (math.random() * 2 - 1) * p5
		local v7 = p3 * (9 + math.random() * 9)
		table.insert(v3, {
			frame = fill,
			v = Vector2.new(math.cos(v6), (math.sin(v6))) * v7,
			spin = (math.random() < 0.5 and -1 or 1) * (720 + math.random() * 900),
			r0 = math.random() * 180,
			life = 0.9 + math.random() * 0.5
		})
	end

	local now = os.clock()
	local v4 = p3 * 38
	Style.animate(v3, function(_, p6)
		local v5 = p6 - now
		local v6 = false

		for _, v7 in v3 do
			local frame = v7.frame

			if not frame.Parent then
				continue
			end

			if v7.life <= v5 then
				frame:Destroy()
			else
				local v8 = vector2 + v7.v * v5 + Vector2.new(0, v4 * 0.5 * v5 * v5)
				frame.Position = UDim2.fromOffset(v8.X, v8.Y)
				frame.Rotation = v7.r0 + v7.spin * v5
				local backgroundTransparency = math.clamp((v5 - (v7.life - 0.3)) / 0.3, 0, 1)
				frame.BackgroundTransparency = backgroundTransparency
				v6 = true

				for _, frame2 in frame:GetChildren() do
					if frame2:IsA("Frame") then
						frame2.BackgroundTransparency = backgroundTransparency
					end
				end
			end
		end

		return v6
	end)
end

function ClaimFx.smoke(p, vector2: Vector2, p2: number, p3: number, p4: number)
	for i = 1, p2 do
		local v3 = (i + math.random() * 0.7) / p2 * 2 * 3.141592653589793
		local v4 = p4 * (0.5 + math.random() * 0.5)
		local v5 = p3 * (1.6 + math.random())
		local v6 = p3 * (4 + math.random() * 2.5)
		local v7 = 1.1 + math.random() * 0.7
		local lerped = color2:Lerp(Style.STEEL_LIGHT, math.random() * 0.6)
		local image = ClaimFx.image(p, "Smoke", ClaimFx.GLOW, lerped, v5, UDim2.fromOffset(vector2.X, vector2.Y))
		image.ZIndex = 5
		image.ImageTransparency = 1
		local v8 = 0.35 + math.random() * 0.2
		local now = os.clock()
		Style.animate(image, function(_, p5): boolean
			local v9 = (p5 - now) / v7

			if v9 >= 1 then
				image:Destroy()
				return false
			end

			local easeOut = Style.easeOut(v9)
			local v10 = vector2 + Vector2.new(math.cos(v3), math.sin(v3) * 0.7) * v4 * easeOut - Vector2.new(0, p3 * 1.5 * v9)
			local v11 = v5 + (v6 - v5) * easeOut
			image.Position = UDim2.fromOffset(v10.X, v10.Y)
			image.Size = UDim2.fromOffset(v11, v11)
			image.ImageTransparency = 1 - v8 * math.min(1, v9 * 8) * (1 - v9) ^ 1.5
			return true
		end)
	end
end

function ClaimFx.muzzle(p, vector2: Vector2, p2: number, value: number?)
	local v3 = p2 * (value or 4)
	local image = ClaimFx.image(
		p,
		"Bloom",
		ClaimFx.GLOW,
		Style.ORANGE,
		v3 * 1.6,
		UDim2.fromOffset(vector2.X, vector2.Y)
	)
	image.ZIndex = 7
	local image2 = ClaimFx.image(p, "Flash", ClaimFx.SPARKLE, v2[1], v3, UDim2.fromOffset(vector2.X, vector2.Y))
	image2.ZIndex = 8
	image2.Rotation = math.random() * 90
	local now = os.clock()
	Style.animate(image2, function(_, p3): boolean
		local imageTransparency = (p3 - now) / 0.14

		if imageTransparency >= 1 then
			image2:Destroy()
			image:Destroy()
			return false
		else
			local v4 = (1 - imageTransparency) ^ 1.5
			image2.Size = UDim2.fromOffset(v3 * (0.6 + 0.6 * v4), v3 * (0.6 + 0.6 * v4))
			image2.ImageTransparency = imageTransparency
			image.Size = UDim2.fromOffset(
				v3 * 1.6 * (0.8 + 0.4 * imageTransparency),
				v3 * 1.6 * (0.8 + 0.4 * imageTransparency)
			)
			image.ImageTransparency = 0.3 + 0.7 * imageTransparency
			return true
		end
	end)
end

function ClaimFx.spray(p, vector2: Vector2, p2: number)
	ClaimFx.muzzle(p, vector2, p2, 4)
	ClaimFx.sparks(p, vector2, 24, p2, 0.25)
	ClaimFx.casings(p, vector2, 5, p2, -0.9424777960769379, 0.35)
	ClaimFx.smoke(p, vector2, 5, p2, p2 * 2.2)
	ClaimFx.ring(p, vector2, p2 * 6, p2 * 0.28, Style.HAZARD, 0.34)
end

function ClaimFx.salvo(p, vector2: Vector2, p2: number)
	ClaimFx.muzzle(p, vector2, p2, 9)
	ClaimFx.sparks(p, vector2, 46, p2 * 1.3, 0.35)
	ClaimFx.casings(p, vector2, 9, p2 * 1.1, -0.8796459430051422, 0.4)
	ClaimFx.casings(p, vector2, 9, p2 * 1.1, -2.261946710584651, 0.4)
	ClaimFx.smoke(p, vector2, 10, p2, p2 * 7)
end

function ClaimFx.flash(p, p2: number, p3: number, color5: Color3?)
	local fill = Style.fill(p, "Flash", color5 or Color3.new(1, 1, 1), UDim2.fromScale(1, 1))
	fill.ZIndex = 8
	fill.BackgroundTransparency = 1 - p2
	local now = os.clock()
	Style.animate(fill, function(_, p4): boolean
		local v3 = (p4 - now) / p3

		if v3 >= 1 then
			fill:Destroy()
			return false
		end

		fill.BackgroundTransparency = 1 - p2 * (1 - Style.easeOut(v3))
		return true
	end)
end

return ClaimFx