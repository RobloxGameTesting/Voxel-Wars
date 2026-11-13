local Style = require(script.Parent:WaitForChild("Style"))
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Game = ReplicatedStorage:WaitForChild("Game")
local Hardpoint = require(Game:WaitForChild("Hardpoint"))

local TacticalMap = {}

local color = Color3.fromRGB(70, 72, 78)

function TacticalMap.cameraFor(vector3: Vector3, vector3_2: Vector3, p: string?, p2: number, p3: number)
	local midpoint = (vector3 + vector3_2) / 2
	local v = vector3_2.X - vector3.X
	local v2 = vector3_2.Z - vector3.Z

	local v3 = p == "Blues" and Vector3.new(0, 0, 1) or Vector3.new(0, 0, -1)

	local cross = (Vector3.new(0, 1, 0)):Cross(v3)
	local v4 = math.tan(math.rad(p2) / 2)

	local v5 = math.max(v / 2 / v4, v2 / 2 / (v4 * p3 * 0.8)) * 1.08

	local v6 = Vector3.new(midpoint.X, vector3_2.Y + v5, midpoint.Z) + v3 * (v2 * 0.1)
	return CFrame.fromMatrix(v6, v3, cross, Vector3.new(0, 1, 0))
end

function TacticalMap.new(p, items, vector3: Vector3, vector3_2: Vector3)
	local frame = Style.frame(p, "TacticalMap", UDim2.fromScale(1, 1))
	frame.Visible = false
	local fill_2 = Style.fill(frame, "Tint", Color3.fromRGB(16, 20, 26), UDim2.fromScale(1, 1))
	fill_2.BackgroundTransparency = 0.55

	for _, v in { 0, 1 } do
		local tape = Style.tape(frame, "Tape", UDim2.new(1, 0, 0, 10), 3000, 20)
		tape.AnchorPoint = Vector2.new(0, v)
		tape.Position = UDim2.fromScale(0, v)
	end

	local frame2 = Style.frame(frame, "Markers", UDim2.fromScale(1, 1))

	local frame3 = Style.frame(frame, "Points", UDim2.fromScale(1, 1))
	frame3.ZIndex = frame2.ZIndex - 1

	local fills = {}
	local v = nil
	local function ensurePlates()
		local v2 = ""

		for _, v3 in Hardpoint.POINTS do
			v2 ..= v3.letter .. ","
		end

		if v2 == v then
			return
		end

		v = v2

		for _, v3 in fills do
			v3:Destroy()
		end

		table.clear(fills)

		for k, v3 in Hardpoint.POINTS do
			local fill = Style.fill(
				frame3,
				"Point" .. k,
				Style.STEEL,
				UDim2.fromOffset(24, 24),
				nil,
				Vector2.new(0.5, 0.5)
			)
			Style.corner(fill, 12)
			Style.stroke(fill, 2, 0, Style.WHITE, true)
			local label = Style.label(fill, "Letter", v3.letter, #v3.letter > 1 and 11 or 15, Style.FONT, 1.5)
			label.AutomaticSize = Enum.AutomaticSize.None
			label.Size = UDim2.fromScale(1, 1)
			fills[k] = fill
		end
	end
	ensurePlates()

	local v2 = {}
	local v3 = {}

	for k in items do
		local textButton = Instance.new("TextButton")
		textButton.Name = "Beacon" .. k
		textButton.Text = ""
		textButton.BackgroundTransparency = 1
		textButton.AutoButtonColor = false
		textButton.Size = UDim2.fromOffset(34, 34)
		textButton.AnchorPoint = Vector2.new(0.5, 0.5)
		textButton.Parent = frame2
		local scaler = Style.scaler(textButton)
		local fill = Style.fill(
			textButton,
			"Plate",
			Style.HAZARD,
			UDim2.fromOffset(20, 20),
			UDim2.fromScale(0.5, 0.5),
			Vector2.new(0.5, 0.5)
		)
		Style.corner(fill, 2)
		local stroke = Style.stroke(fill, 2, 0, nil, true)
		local label = Style.label(fill, "Number", "", 12, Style.FONT, 0)
		label.AutomaticSize = Enum.AutomaticSize.None
		label.Size = UDim2.fromScale(1, 1)
		label.TextColor3 = Style.INK
		local frame4 = Style.frame(textButton, "Ring", UDim2.fromOffset(0, 0), UDim2.fromScale(0.5, 0.5))
		frame4.Visible = false
		local fills2 = {}

		for i = 1, 16 do
			local v4 = (i - 1) / 16 * 3.141592653589793 * 2
			local fill2 = Style.fill(
				frame4,
				"Tick" .. i,
				Style.WHITE,
				UDim2.fromOffset(4, 9),
				UDim2.fromOffset(math.sin(v4) * 26, -math.cos(v4) * 26),
				Vector2.new(0.5, 0.5)
			)
			fill2.Rotation = math.deg(v4)
			Style.stroke(fill2, 1, 0.2, nil, true)
			fills2[i] = fill2
		end

		textButton.Activated:Connect(function()
			for _, v4 in v2 do
				v4(k)
			end
		end)
		v3[k] = {
			button = textButton,
			plate = fill,
			plateStroke = stroke,
			number = label,
			ring = frame4,
			ticks = fills2,
			scale = scaler
		}
	end

	local v4 = nil
	local v5 = {}
	local v6 = nil
	local v7 = nil
	local v8 = 0
	local v9 = CFrame.identity
	local cframe2 = CFrame.identity
	local flag = false
	local cameraType = nil

	local function styleMarker(p2: number)
		local v10 = v3[p2]
		local item = items[p2]
		local v11 = item.team == v4
		local v12 = v5[p2] ~= false
		local visible = p2 == v6
		v10.button.Active = v11 and v12
		v10.button.Interactable = v11 and v12
		v10.ring.Visible = visible

		if v11 and v12 then
			v10.plate.Size = UDim2.fromOffset(visible and 26 or 18, visible and 26 or 18)
			v10.plate.Rotation = 0
			local plate = v10.plate
			local backgroundColor

			if visible then
				backgroundColor = Style.HAZARD
			else
				backgroundColor = Style.WHITE
			end

			plate.BackgroundColor3 = backgroundColor
			v10.plateStroke.Color = Style.INK
			v10.number.Visible = visible
		else
			if v12 then
				v10.plate.Size = UDim2.fromOffset(11, 11)
				v10.plate.Rotation = 45
				v10.plate.BackgroundColor3 = Style.teamColor(item.team)
				v10.plateStroke.Color = Style.INK
			else
				v10.plate.Size = UDim2.fromOffset(10, 10)
				v10.plate.Rotation = 45
				v10.plate.BackgroundColor3 = color
				v10.plateStroke.Color = Color3.new(0, 0, 0)
			end

			v10.number.Visible = false
		end
	end

	local function placeMarkers()
		local currentCamera = workspace.CurrentCamera

		for k, v10 in v3 do
			local worldToViewportPoint, visible = currentCamera:WorldToViewportPoint(items[k].spawn.Position)
			v10.button.Visible = visible
			v10.button.Position = UDim2.fromOffset(worldToViewportPoint.X, worldToViewportPoint.Y)
		end

		local domination = Game:FindFirstChild("Domination")
		local v10

		if
			domination == nil
			or domination:GetAttribute("GameMode") == "spawnraid"
			or domination:GetAttribute("GameMode") == "siege"
		then
			v10 = false
		else
			v10 = domination:GetAttribute("GameMode") ~= "tdm"
		end

		ensurePlates()

		for k, v11 in fills do
			local worldToViewportPoint, v12 = currentCamera:WorldToViewportPoint(Hardpoint.POINTS[k].center)
			v11.Visible = v10 and v12

			if not v11.Visible then
				continue
			end

			v11.Position = UDim2.fromOffset(worldToViewportPoint.X, worldToViewportPoint.Y)
			local attribute = domination:GetAttribute(Hardpoint.attr("Holder", k))
			local backgroundColor

			if attribute == "Reds" or attribute == "Blues" then
				backgroundColor = Style.teamColor(attribute)
			else
				backgroundColor = Style.STEEL
			end

			v11.BackgroundColor3 = backgroundColor
		end
	end

	local function step(_, p2): boolean
		if not frame.Visible then
			return false
		end

		if flag then
			local v10 = (p2 - v8) / 1.3

			if v10 < 1 then
				workspace.CurrentCamera.CFrame = v9:Lerp(cframe2, Style.smooth(v10))
			else
				workspace.CurrentCamera.CFrame = cframe2
			end
		end

		placeMarkers()

		if not v6 then
			return true
		end

		local v10 = v3[v6]
		local v11 = not v7 and 0 or math.floor(v7 * 16 + 0.0001)

		for k, tick in v10.ticks do
			local backgroundColor

			if k <= v11 then
				backgroundColor = Style.HAZARD
			else
				backgroundColor = Style.STEEL
			end

			tick.BackgroundColor3 = backgroundColor
		end

		v10.ring.Rotation = 0

		return true
	end

	local v10 = {}
	v10.root = frame

	function v10.show(p2: string, p3, p4: number?)
		v4 = p2
		v5 = p3
		v6 = p4

		for k in v3 do
			styleMarker(k)
		end

		frame.Visible = true
		Style.animate(v10, step)
	end

	function v10.hide()
		frame.Visible = false
		Style.stop(v10)
	end

	function v10.setAlive(p2)
		v5 = p2

		for k in v3 do
			styleMarker(k)
		end
	end

	function v10.choose(p2: number)
		local v11 = v6
		v6 = p2

		if v11 then
			styleMarker(v11)
		end

		styleMarker(p2)
	end

	function v10.chosen()
		return v6
	end

	function v10.setProgress(p2: number?)
		v7 = p2
	end

	function v10.onChoose(callback)
		table.insert(v2, callback)
	end

	function v10.nearest(vector3_3: Vector3)
		local v11 = 1e999
		local v12 = nil

		for k, item in items do
			if not (item.team == v4 and v5[k] ~= false) then
				continue
			end

			local magnitude = (item.spawn.Position - vector3_3).Magnitude

			if not (magnitude < v11) then
				continue
			end

			v12 = k
			v11 = magnitude
		end

		return v12
	end

	function v10.camera(cframe: CFrame?)
		local currentCamera = workspace.CurrentCamera

		if not flag then
			cameraType = currentCamera.CameraType
		end

		flag = true
		currentCamera.CameraType = Enum.CameraType.Scriptable
		local viewportSize = currentCamera.ViewportSize
		v9 = cframe or currentCamera.CFrame
		cframe2 = TacticalMap.cameraFor(
			vector3,
			vector3_2,
			v4,
			currentCamera.FieldOfView,
			viewportSize.X / math.max(viewportSize.Y, 1)
		)
		v8 = os.clock()
		Style.animate(v10, step)
	end

	function v10.release()
		if not flag then
			return
		end

		flag = false
		local currentCamera = workspace.CurrentCamera
		local cameraType2

		if cameraType == Enum.CameraType.Scriptable or cameraType == nil then
			cameraType2 = Enum.CameraType.Custom
		else
			cameraType2 = cameraType
		end

		currentCamera.CameraType = cameraType2
		cameraType = nil

		local Players = game:GetService("Players")
		local character = Players.LocalPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			currentCamera.CameraSubject = humanoid
		end
	end

	return v10
end

return TacticalMap