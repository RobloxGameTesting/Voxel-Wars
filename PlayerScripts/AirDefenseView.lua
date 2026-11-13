local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Vehicles = ReplicatedStorage:WaitForChild("Vehicles")
local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local AirDefense = require(Vehicles:WaitForChild("AirDefense"))
local VoxelSound = require(Voxel:WaitForChild("VoxelSound"))
local BattleFX = require(Voxel:WaitForChild("BattleFX"))
local Glyph = require(script.Parent:WaitForChild("GameUI"):WaitForChild("Glyph"))
local Remotes = Vehicles:WaitForChild("Remotes")
local AAOrdnance = Remotes:WaitForChild("AAOrdnance")
local AAFlare = Remotes:WaitForChild("AAFlare")

local LocalPlayer = Players.LocalPlayer
local color = Color3.fromRGB(214, 214, 208)
local color2 = Color3.fromRGB(255, 190, 90)
local color3 = Color3.fromRGB(46, 44, 42)

local aaOrdnance = Instance.new("Folder")
aaOrdnance.Name = "AAOrdnance"
aaOrdnance.Parent = workspace

local function part(size: Vector3, color4: Color3, flag: boolean)
	local part2 = Instance.new("Part")
	part2.Anchored = true
	part2.CanCollide = false
	part2.CanQuery = false
	part2.CanTouch = false
	part2.CastShadow = false
	part2.Size = size
	part2.Color = color4
	local material

	if flag then
		material = Enum.Material.Neon
	else
		material = Enum.Material.SmoothPlastic
	end

	part2.Material = material
	part2.Parent = aaOrdnance
	return part2
end

local function newBody()
	local color4 = Color3.fromRGB(205, 205, 196)
	local part2 = Instance.new("Part")
	part2.Anchored = true
	part2.CanCollide = false
	part2.CanQuery = false
	part2.CanTouch = false
	part2.CastShadow = false
	part2.Size = Vector3.new(0.6, 0.6, 3.4)
	part2.Color = color4
	part2.Material = Enum.Material.SmoothPlastic
	part2.Parent = aaOrdnance

	local color5 = Color3.fromRGB(44, 46, 48)
	local part3 = Instance.new("Part")
	part3.Anchored = true
	part3.CanCollide = false
	part3.CanQuery = false
	part3.CanTouch = false
	part3.CastShadow = false
	part3.Size = Vector3.new(0.45, 0.45, 0.6)
	part3.Color = color5
	part3.Material = Enum.Material.SmoothPlastic
	part3.Parent = aaOrdnance

	local color6 = Color3.fromRGB(70, 76, 58)
	local part4 = Instance.new("Part")
	part4.Anchored = true
	part4.CanCollide = false
	part4.CanQuery = false
	part4.CanTouch = false
	part4.CastShadow = false
	part4.Size = Vector3.new(1.5, 0.12, 0.6)
	part4.Color = color6
	part4.Material = Enum.Material.SmoothPlastic
	part4.Parent = aaOrdnance

	local color7 = Color3.fromRGB(70, 76, 58)
	local part5 = Instance.new("Part")
	part5.Anchored = true
	part5.CanCollide = false
	part5.CanQuery = false
	part5.CanTouch = false
	part5.CastShadow = false
	part5.Size = Vector3.new(0.12, 1.5, 0.6)
	part5.Color = color7
	part5.Material = Enum.Material.SmoothPlastic
	part5.Parent = aaOrdnance
	local part6 = Instance.new("Part")
	part6.Anchored = true
	part6.CanCollide = false
	part6.CanQuery = false
	part6.CanTouch = false
	part6.CastShadow = false
	part6.Size = Vector3.new(0.5, 0.5, 2.4)
	part6.Color = color2
	part6.Material = Enum.Material.Neon
	part6.Parent = aaOrdnance
	return { part2, part3, part4, part5, part6 }
end

local v = {}
local v2 = {}
local v3 = {}
local v4 = table.create(5, CFrame.identity)

local function spawn(value, pos: Vector3, vel: Vector3, vector3: Vector3?, own: boolean)
	local now = os.clock()
	local v5 = {
		parts = newBody(),
		pos = pos,
		vel = vel,
		off = not vector3 and Vector3.new(0, 0, 0) or vector3 - pos,
		born = now,
		smokeAt = 0,
		key = typeof(value) ~= "number" and 2999999 or value + 3000000,
		own = own
	}
	v[value] = v5
	VoxelSound.launch(pos, v5.key)
	BattleFX.billow(pos - vel.Unit * 3, color, 2.5, false)
	return v5
end

local function remove(p) -- 3 equivalent calls inferred from this helper
	local v5 = v[p]

	if v5 then
		v[p] = nil

		for _, part2 in v5.parts do
			part2:Destroy()
		end

		VoxelSound.rocketEnd(v5.key)
	end
end

AirDefense.fired:Connect(function(pos: Vector3, vector3: Vector3, vector3_2: Vector3?)
	local v5 = {}
	local v6 = spawn(v5, pos, vector3 * AirDefense.EJECT, vector3_2, true)
	table.insert(v2, v6)
	task.delay(1.5, function()
		local index = table.find(v2, v6)

		if index then
			table.remove(v2, index)
			remove(v5) -- inferred equivalent call
		end
	end)
end)

local function keyOf(p) -- 1 equivalent call inferred from this helper
	for k, v5 in v do
		if v5 == p then
			return k
		end
	end

	return nil
end

local function flare(pos: Vector3, vector3: Vector3)
	VoxelSound.flares(pos)

	for i = 1, 10 do
		local v5 = i / 10 * 3.141592653589793 * 2

		local color4 = Color3.fromRGB(255, 225, 150)
		local part2 = Instance.new("Part")
		part2.Anchored = true
		part2.CanCollide = false
		part2.CanQuery = false
		part2.CanTouch = false
		part2.CastShadow = false
		part2.Size = Vector3.new(1.1, 1.1, 1.1)
		part2.Color = color4
		part2.Material = Enum.Material.Neon
		part2.Parent = aaOrdnance

		local v6 = {
			part = part2,
			pos = pos,
			vel = vector3 * 0.5 + Vector3.new(math.cos(v5) * 45, math.sin(v5) * 26 + -18, math.sin(v5) * 45),
			till = os.clock() + 3,
			smokeAt = 0
		}
		table.insert(v3, v6)
	end
end

AAOrdnance.OnClientEvent:Connect(function(p: string, pos, pos2, vel, p2, p3)
	if p == "missile" then
		if p2 ~= LocalPlayer or not (#v2 > 0) then
			spawn(pos, pos2, vel, p3, false)
			return
		end

		local v5 = table.remove(v2, 1)
		local k = keyOf(v5) -- inferred equivalent call

		if not k then
			return
		end

		v[k] = nil
		v[pos] = v5
	elseif p == "gone" then
		remove(pos) -- inferred equivalent call
	elseif p == "pop" then
		remove(pos) -- inferred equivalent call
		BattleFX.billow(pos2, color, 3, false)
		BattleFX.flash(pos2, 30, 0.15)
	elseif p == "flare" then
		flare(pos, pos2)
	elseif p == "flak" then
		local part2 = Instance.new("Part")
		part2.Anchored = true
		part2.CanCollide = false
		part2.CanQuery = false
		part2.CanTouch = false
		part2.CastShadow = false
		part2.Size = Vector3.new(0.8, 0.8, 0.8)
		part2.Color = color2
		part2.Material = Enum.Material.Neon
		part2.Parent = aaOrdnance

		local v5 = {
			part = part2,
			pos = pos,
			vel = (pos2 - pos) / math.max(vel, 0.05) + Vector3.new(0, 15 * vel, 0),
			till = os.clock() + vel,
			smokeAt = 1e999
		}
		table.insert(v3, v5)
	elseif p == "burst" then
		BattleFX.flash(pos, 45, 0.18)
		BattleFX.billow(pos, color3, 7, false)
		BattleFX.billow(pos + Vector3.new(2, 1, -2), color3, 5, false)
		VoxelSound.explosion(0.6, pos)
	end
end)

Remotes:WaitForChild("AAOrdnanceTrack").OnClientEvent:Connect(function(p, pos: Vector3, vel: Vector3)
	local v5 = v[p]

	if v5 then
		v5.off += v5.pos - pos
		v5.pos = pos
		v5.vel = vel
	end
end)

local function drawMissiles(now: number, dt: number)
	for _, v5 in v do
		local v6 = now - v5.born

		if AirDefense.IGNITE <= v6 then
			local magnitude = v5.vel.Magnitude

			if magnitude > 1 and magnitude < AirDefense.MAX_SPEED then
				v5.vel += v5.vel / magnitude * (AirDefense.ACCEL * dt)
			end
		end

		v5.pos += v5.vel * dt
		v5.off *= math.exp(dt * -8)
		local v7 = v5.pos + v5.off
		local cframe = CFrame.lookAlong(v7, not (v5.vel.Magnitude > 1) and Vector3.new(0, 0, 1) or v5.vel.Unit)
		local v8 = AirDefense.IGNITE <= v6
		v4[1] = cframe
		v4[2] = cframe * CFrame.new(0, 0, -1.9)

		v4[3] = cframe * CFrame.new(0, 0, 1.3)
		v4[4] = cframe * CFrame.new(0, 0, 1.3)
		local v9

		if v8 then
			v9 = cframe * CFrame.new(0, 0, 2.85)
		else
			v9 = cframe * CFrame.new(0, -100000, 0)
		end

		v4[5] = v9
		workspace:BulkMoveTo(v5.parts, v4, Enum.BulkMoveMode.FireCFrameChanged)
		VoxelSound.rocketMove(v5.key, v7, v5.vel)

		if not (v8 and v5.smokeAt <= now) then
			continue
		end

		v5.smokeAt = now + 0.07
		BattleFX.billow(v7 - v5.vel.Unit * 3, color, 1.6, false)
	end

	for i = #v3, 1, -1 do
		local v5 = v3[i]

		if v5.till < now then
			v5.part:Destroy()
			v3[i] = v3[#v3]
			v3[#v3] = nil
		else
			v5.vel -= Vector3.new(0, dt * 30, 0)
			v5.pos += v5.vel * dt
			v5.part.CFrame = CFrame.new(v5.pos)

			if v5.smokeAt <= now then
				v5.smokeAt = now + 0.15
				BattleFX.billow(v5.pos, color, 0.9, false)
			end
		end
	end
end

local aaWarning = Instance.new("ScreenGui")
aaWarning.Name = "AAWarning"
aaWarning.ResetOnSpawn = false
aaWarning.ScreenInsets = Enum.ScreenInsets.None
aaWarning.DisplayOrder = 8
aaWarning.Enabled = false
aaWarning.Parent = LocalPlayer:WaitForChild("PlayerGui")

local rbxassetfontsfamiliesOswaldjson = Font.new("rbxasset://fonts/families/Oswald.json", Enum.FontWeight.Bold)
local color4 = Color3.fromRGB(255, 196, 70)
local color5 = Color3.fromRGB(255, 64, 48)

local textLabel = Instance.new("TextLabel")
textLabel.AnchorPoint = Vector2.new(0.5, 0)
textLabel.Position = UDim2.new(0.5, 0, 0.2, 0)
textLabel.Size = UDim2.fromOffset(320, 36)
textLabel.BackgroundTransparency = 1
textLabel.FontFace = rbxassetfontsfamiliesOswaldjson
textLabel.TextSize = 30
textLabel.TextStrokeTransparency = 0.4
textLabel.Parent = aaWarning

local textLabel2 = Instance.new("TextLabel")
textLabel2.AnchorPoint = Vector2.new(0.5, 0)
textLabel2.Position = UDim2.new(0.5, 0, 0.2, 38)
textLabel2.Size = UDim2.fromOffset(320, 22)
textLabel2.BackgroundTransparency = 1
textLabel2.FontFace = rbxassetfontsfamiliesOswaldjson
textLabel2.TextSize = 18
textLabel2.TextColor3 = Color3.new(1, 1, 1)
textLabel2.TextStrokeTransparency = 0.4
textLabel2.Parent = aaWarning

local flareSeconds = textLabel2:Clone()
flareSeconds.Name = "FlareSeconds"
flareSeconds.Position = UDim2.new(0.5, 74, 0.2, 38)
flareSeconds.Size = UDim2.fromOffset(40, 22)
flareSeconds.Parent = aaWarning
local cap = Glyph.cap(aaWarning, "F", Enum.KeyCode.ButtonB, 22)
cap.AnchorPoint = Vector2.new(0.5, 0)
cap.Position = UDim2.new(0.5, -74, 0.2, 38)

local v5 = false
local function flareLine(visible: boolean, p: number, jet: boolean)
	local v6 = UserInputService.TouchEnabled and not Glyph.gamepad()

	if jet ~= v5 then
		v5 = jet
		Glyph.setCap(cap, jet and "Q" or "F", Enum.KeyCode.ButtonB)
	end

	textLabel2.Text = visible and "FLARES" or ""
	flareSeconds.Text = not (visible and p > 0) and "" or tostring((math.ceil(p)))

	if visible then
		if p <= 0 then
			visible = not v6
		else
			visible = false
		end
	end

	cap.Visible = visible
end

local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Size = UDim2.fromOffset(40, 10)
frame.BorderSizePixel = 0
frame.Parent = aaWarning

local v6 = -100
local v7 = 0
local v8 = false

local function flareState(p)
	if p and p.def.jet then
		return p.flareAt or -100, p.def.tuning.flares.cooldown
	end

	return v6, AirDefense.flareCooldown or AirDefense.FLARE_COOLDOWN
end

local function dropFlares(riding, p: number) -- 2 equivalent calls inferred from this helper
	if p - v6 >= (AirDefense.flareCooldown or AirDefense.FLARE_COOLDOWN) and not riding.def.jet then
		v6 = p
		AAFlare:FireServer(riding.id)
	end
end

UserInputService.InputBegan:Connect(function(input)
	local riding = AirDefense.riding

	if not riding or not AirDefense.piloting or UserInputService:GetFocusedTextBox() then
		return
	end

	if
		input.KeyCode == Enum.KeyCode.F
		or input.KeyCode == Enum.KeyCode.Three
		or input.KeyCode == Enum.KeyCode.ButtonB
	then
		dropFlares(riding, os.clock()) -- inferred equivalent call
	end
end)

local v9 = 0
local v10 = nil
local function groundRide(p: number)
	if p < v9 then
		if v10 and AirDefense.ground[v10.id] == v10 then
			return v10
		end

		return nil
	else
		v9 = p + 0.25
		v10 = nil
		local userId = LocalPlayer.UserId

		for _, v11 in AirDefense.ground do
			local folder = v11.folder

			if not folder or v11.wrecked then
				continue
			end

			local seats = v11.def and v11.def.seats

			for i = 1, seats and #seats or 16 do
				if folder:GetAttribute("S" .. i) == userId then
					v10 = v11
					return v11
				end
			end
		end

		return nil
	end
end

local function warn_(now: number)
	local riding = AirDefense.riding or groundRide(now)
	local folder = riding and riding.folder

	if folder and not riding.wrecked then
		local inbound = folder:GetAttribute("Inbound")
		local aaLock = folder:GetAttribute("AALock")
		local aaFrom = folder:GetAttribute("AAFrom")
		local jet = riding.def.jet == true
		local v11, v12

		if riding and riding.def.jet then
			v11 = riding.flareAt or -100
			v12 = riding.def.tuning.flares.cooldown
		else
			v11 = v6
			v12 = AirDefense.flareCooldown or AirDefense.FLARE_COOLDOWN
		end

		if inbound or aaLock or folder:GetAttribute("Painted") then
			if AirDefense.piloting and inbound and UserInputService.TouchEnabled and not Glyph.gamepad() then
				dropFlares(riding, now) -- inferred equivalent call
			end

			aaWarning.Enabled = true
			local v13

			if type(aaLock) == "number" then
				v13 = aaLock >= 1
			else
				v13 = false
			end

			local v14 = if inbound or v13 then color5 else color4
			textLabel.Text = inbound and "MISSILE" or v13 and "LOCKED ON" or "ENEMY LOCK"
			textLabel.TextColor3 = v14
			frame.BackgroundColor3 = v14
			flareLine(AirDefense.piloting, v12 - (now - v11), jet)
			local currentCamera = workspace.CurrentCamera

			if typeof(aaFrom) == "Vector3" then
				local vectorToObjectSpace = currentCamera.CFrame:VectorToObjectSpace(aaFrom - currentCamera.CFrame.Position)
				local v15 = math.atan2(vectorToObjectSpace.X, -vectorToObjectSpace.Z)
				local v16 = currentCamera.ViewportSize.Y * 0.3
				frame.Visible = true
				frame.Position = UDim2.new(0.5, math.sin(v15) * v16, 0.5, -math.cos(v15) * v16)
				frame.Rotation = math.deg(v15)
			else
				frame.Visible = false
			end

			if v7 <= now then
				if inbound then
					v7 = now + 0.13
					v8 = not v8
					VoxelSound.aaBeep(v8 and 0.62 or 0.5, 0.7)
				else
					v7 = now + 0.55 - 0.35 * (type(aaLock) ~= "number" and 0 or aaLock)
					VoxelSound.aaBeep(0.5, 0.55)
				end
			end
		else
			local v13 = v12 - (now - v11)
			local enabled = AirDefense.piloting

			if enabled then
				if v13 > 0 then
					enabled = UserInputService.TouchEnabled and not Glyph.gamepad()
				else
					enabled = false
				end
			end

			if enabled then
				textLabel.Text = ""
				frame.Visible = false
				flareLine(true, v13, jet)
			end

			if aaWarning.Enabled ~= enabled then
				aaWarning.Enabled = enabled
			end
		end
	elseif aaWarning.Enabled then
		aaWarning.Enabled = false
	end
end

local v11 = nil
RunService.RenderStepped:Connect(function(dt: number)
	local now = os.clock()

	local riding = AirDefense.riding
	local v12, v13

	if riding and riding.def.jet then
		v12 = riding.flareAt or -100
		v13 = riding.def.tuning.flares.cooldown
	else
		v12 = v6
		v13 = AirDefense.flareCooldown or AirDefense.FLARE_COOLDOWN
	end

	if not (AirDefense.piloting and now - v12 < v13) then
		v12 = nil
	end

	if v12 ~= v11 then
		v11 = v12
		local v14

		if v12 then
			v14 = NumberRange.new(v12, v12 + v13)
		end

		LocalPlayer:SetAttribute("FlareCharge", v14)
	end

	if next(v) or #v3 > 0 then
		drawMissiles(now, dt)
	end

	warn_(now)
end)