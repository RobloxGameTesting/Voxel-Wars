local Lighting = game:GetService("Lighting")

local Style = require(script.Parent:WaitForChild("Style"))

local Pressure = {}

local function bearing(from: Vector3)
	local cframe = workspace.CurrentCamera.CFrame
	local vector = from - cframe.Position
	local v = Vector3.new(cframe.LookVector.X, 0, cframe.LookVector.Z)

	if v.Magnitude < 0.001 then
		v = Vector3.new(-cframe.UpVector.X, 0, -cframe.UpVector.Z) * math.sign(cframe.LookVector.Y)
	end

	local unit = v.Unit
	return (math.atan2(vector:Dot((Vector3.new(-unit.Z, 0, unit.X))), (vector:Dot(unit))))
end

local function edge(frame, p: string, udim: UDim2, udim2: UDim2, vector2: Vector2, rotation: number)
	local frame2 = Style.frame(frame, p, udim, udim2, vector2)
	frame2.BackgroundColor3 = Color3.new(0, 0, 0)
	frame2.BackgroundTransparency = 1
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Rotation = rotation
	uiGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.4, 0.6),
		NumberSequenceKeypoint.new(1, 1)
	})

	uiGradient.Parent = frame2
	return frame2
end

function Pressure.new(p, parent)
	local frame = Style.frame(p, "Pressure", UDim2.fromScale(1, 1))

	local v = {
		edge(frame, "Left", UDim2.fromScale(0.25, 1), UDim2.fromScale(0, 0), Vector2.zero, 0),
		edge(frame, "Right", UDim2.fromScale(0.25, 1), UDim2.fromScale(1, 0), Vector2.new(1, 0), 180),
		edge(frame, "Top", UDim2.fromScale(1, 0.3), UDim2.fromScale(0, 0), Vector2.zero, 90),
		edge(frame, "Bottom", UDim2.fromScale(1, 0.3), UDim2.fromScale(0, 1), Vector2.new(0, 1), -90)
	}

	local v2 = {}

	for i = 1, 4 do
		local frame2 = Style.frame(frame, "Chevron" .. i, UDim2.fromOffset(48, 48), UDim2.new(), Vector2.new(0.5, 0.5))
		frame2.Visible = false
		Style.scaler(frame2)
		local fills = {}

		for _, v3 in { -1, 1 } do
			local fill = Style.fill(
				frame2,
				"Bar",
				Style.ORANGE,
				UDim2.fromOffset(30, 9),
				UDim2.new(0.5, v3 * 10, 0.5, 2),
				Vector2.new(0.5, 0.5)
			)
			fill.Rotation = v3 * 38
			Style.stroke(fill, 2, 0, nil, true)
			table.insert(fills, fill)
		end

		v2[i] = {
			frame = frame2,
			bars = fills,
			from = Vector3.new(0, 0, 0),
			t0 = 0,
			live = false
		}
	end

	local function chevronStep(_, t0)
		local viewportSize = workspace.CurrentCamera.ViewportSize
		local v3 = 46 * Style.scale()
		local v4 = viewportSize.X / 2 - v3
		local v5 = viewportSize.Y / 2 - v3
		local v6 = false

		for _, v7 in v2 do
			if not v7.live then
				continue
			end

			local v8 = t0 - v7.t0

			if v8 >= 1 then
				v7.live = false
				v7.frame.Visible = false
			else
				local v9 = bearing(v7.from)
				local v10 = math.sin(v9)
				local v11 = -math.cos(v9)

				local v12 = math.min(v10 == 0 and 1e999 or v4 / math.abs(v10), v11 == 0 and 1e999 or v5 / math.abs(v11))
				v7.frame.Position = UDim2.fromOffset(viewportSize.X / 2 + v10 * v12, viewportSize.Y / 2 + v11 * v12)
				v7.frame.Rotation = math.deg(v9)
				local lerped = Style.WHITE:Lerp(Style.ORANGE, (math.clamp(v8 / 0.15, 0, 1)))
				local v13 = math.clamp((v8 - 0.6) / 0.4, 0, 1)
				v6 = true

				for _, bar in v7.bars do
					bar.BackgroundColor3 = lerped
					bar.BackgroundTransparency = v13
					local uiStroke = bar:FindFirstChildOfClass("UIStroke")
					uiStroke.Transparency = v13
				end
			end
		end

		return v6
	end

	local lowHealthGrade = Instance.new("ColorCorrectionEffect")
	lowHealthGrade.Name = "LowHealthGrade"
	lowHealthGrade.Enabled = false
	lowHealthGrade.Parent = parent

	local heartbeat = Instance.new("Sound")
	heartbeat.Name = "Heartbeat"
	heartbeat.SoundId = "rbxassetid://9118608146"
	heartbeat.Volume = 0.55
	heartbeat.PlaybackSpeed = 0.5
	heartbeat.Parent = frame
	local clone = heartbeat:Clone()
	clone.PlaybackSpeed = 0.45
	clone.Volume = 0.4
	clone.Parent = frame

	local v3 = 0
	local v4 = 0
	local v5 = 0
	local v6 = 1e999
	local function lowStep(p2, p3): boolean
		v3 += (v4 - v3) * math.min(p2 * 4, 1)

		if math.abs(v4 - v3) < 0.002 then
			v3 = v4
		end

		lowHealthGrade.Enabled = v3 > 0.001
		lowHealthGrade.Saturation = v3 * -0.75
		lowHealthGrade.Contrast = v3 * 0.18
		local backgroundTransparency = 1 - v3 * 0.55

		for _, v7 in v do
			v7.BackgroundTransparency = backgroundTransparency
		end

		if v4 > 0 then
			if v5 <= p3 then
				heartbeat:Play()
				v6 = p3 + 0.22
				v5 = p3 + (1.15 - v4 * 0.45)
			end

			if v6 <= p3 then
				clone:Play()
				v6 = 1e999
			end
		end

		return v4 > 0 or v3 > 0
	end

	return {
		["root"] = frame,
		grade = lowHealthGrade,
		hit = function(from: Vector3)
			local v7 = v2[1]

			for _, v8 in v2 do
				if v8.live then
					if v8.t0 < v7.t0 then
						v7 = v8
					end
				else
					v7 = v8
					break
				end
			end

			local now = os.clock()
			v7.from = from
			v7.t0 = now
			v7.live = true
			v7.frame.Visible = true
			chevronStep(0, v7.t0)
			Style.animate(v2, chevronStep)
		end,
		setHealth = function(p2: number, flag: boolean)
			local v7 = v4
			v4 = not flag and 0 or math.clamp((0.35 - p2) / 0.35, 0, 1) * 0.6 + (p2 < 0.35 and 0.4 or 0)

			if v4 > 0 and v7 == 0 then
				v5 = os.clock()
			end

			Style.animate(v, lowStep)
		end
	}
end

function Pressure.mount(data)
	local v = Pressure.new(data.layers.overlay, Lighting)
	data.Net.remote("Damaged").OnClientEvent:Connect(function(vector3: Vector3?, _: number)
		if vector3 then
			v.hit(vector3)
		end
	end)
	data.onCharacter(function(_, instance)
		local function update() -- 1 equivalent call inferred from this helper
			v.setHealth(instance.Health / math.max(instance.MaxHealth, 1), instance.Health > 0)
		end
		instance.HealthChanged:Connect(update)
		instance:GetPropertyChangedSignal("MaxHealth"):Connect(update)
		update() -- inferred equivalent call
	end)
	data.onDead(function(flag: boolean)
		if flag then
			v.setHealth(1, false)
		end
	end)
end

return Pressure