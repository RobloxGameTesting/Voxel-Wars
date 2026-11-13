local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

while LocalPlayer:GetAttribute("JoinCovered") == true do
	LocalPlayer:GetAttributeChangedSignal("JoinCovered"):Wait()
end

task.wait(1.8)

local ContentProvider = game:GetService("ContentProvider")
local Players2 = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Airstrike = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("Airstrike"))
local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local StrikeZone = require(Voxel:WaitForChild("StrikeZone"))
local VoxelSound = require(Voxel:WaitForChild("VoxelSound"))
local WorldConfig = require(Voxel:WaitForChild("WorldConfig"))
local VoxelProp = require(Voxel:WaitForChild("VoxelProp"))
local Quality = require(Voxel:WaitForChild("Quality"))
local airstrikeInbound = ReplicatedStorage.Game:WaitForChild("Remotes"):WaitForChild("AirstrikeInbound")
local Style = require(script.Parent:WaitForChild("GameUI"):WaitForChild("Style"))

local localPlayer = Players2.LocalPlayer
local v = 343 * WorldConfig.METER

local airstrikes = Instance.new("Folder")
airstrikes.Name = "Airstrikes"
airstrikes.Parent = workspace

local cframe = CFrame.new(0, workspace.FallenPartsDestroyHeight + 60, 0)

local color = Color3.fromRGB(122, 128, 134)
local color2 = Color3.fromRGB(92, 97, 104)
local color3 = Color3.fromRGB(46, 48, 52)
local color4 = Color3.fromRGB(36, 34, 33)
local color5 = Color3.fromRGB(32, 42, 54)
local color6 = Color3.fromRGB(70, 78, 52)
local color7 = Color3.fromRGB(196, 166, 62)
local color8 = Color3.fromRGB(214, 214, 208)
local VOXEL_SIZE = WorldConfig.VOXEL_SIZE

local v2 = {
	{ -4.75, 0.75 },
	{ 4.75, 0.75 },
	{ -7.75, 2.25 },
	{ 7.75, 2.25 },
	{ -10.75, 3.75 },
	{ 10.75, 3.75 }
}

local function fuselageR(z: number) -- 1 equivalent call inferred from this helper
	if z < -22 or z > 18 then
		return nil
	end

	if z < -14 then
		return (z + 22) / 8 * 1.5 + 0.3
	end

	if z < -8 then
		return (z + 14) / 6 * 0.3 + 1.8
	end

	if z < 12 then
		return 2.1
	end

	if z < 15.5 then
		return 2.1 - (z - 12) / 3.5 * 0.35
	end

	return 1.75
end

local function airframe(vector3: Vector3)
	local x = math.abs(vector3.X)
	local y = vector3.Y
	local z = vector3.Z

	if math.abs(x - 15.5) < 0.5 and y > -1 and y < 0 and z > 1.8 and z < 9.2 then
		return if z < 2.6 then color3 else color8
	else
		for i = 2, #v2, 2 do
			local v3 = v2[i]

			if math.abs(x - v3[1]) < 0.1 and y > -1.5 and y < -0.5 and math.abs(z - v3[2]) < 1.2 then
				return color3
			end
		end

		local v3 = fuselageR(z) -- inferred equivalent call

		if v3 and x * x + (y / 0.92) ^ 2 <= v3 * v3 then
			if z > 17 and x * x + y * y < 1.21 then
				return nil
			end

			if z > 15.5 then
				return color4
			end

			if z < -20.5 then
				return color3
			end

			if y < -1.3 or z > -14 and z < 14 and (z + 22) % 6 < 0.5 then
				return color2
			end

			return color
		elseif y > 1 and (x / 1.15) ^ 2 + ((y - 1.9) / 1.1) ^ 2 + ((z + 10.5) / 3.6) ^ 2 <= 1 then
			if math.abs(z + 9.25) < 0.25 then
				return color2
			end

			return color5
		else
			if x < 1.3 and y >= 0 and z > -7 and z < 8 and y < 2.6 - math.max(0, (-4 - z) * 0.5, (z - 5) * 0.6) then
				return color2
			end

			if x >= 1.6 and x <= 3.4 and y >= -1.9 and y <= 0.4 and z >= -7.3 and z <= -0.5 then
				if z < -6.8 and x > 1.9 and x < 3.1 and y > -1.6 and y < 0.1 then
					return color4
				end

				return color2
			end

			if y > -0.5 and y < 0 and x >= 2 and x <= 15.3 then
				local v4 = (x - 2.3) / 13 * 15 + -6

				if v4 <= z and z <= 9 then
					if z - v4 < 0.7 or z > 8 then
						return color2
					end

					return color
				end
			end

			if y > 0 and y < 0.5 and x >= 2 and x <= 8.1 and (x - 2.1) / 6 * 6.5 + 13.5 <= z and z <= 20 then
				return color2
			end

			if x < 0.5 and y >= 1.6 and y <= 9.6 and (y - 2.1) / 7.5 * 8.5 + 10 <= z and z <= 19.5 then
				return if y > 8.6 then color3 else color2
			end

			return nil
		end
	end
end

local function bombShape(vector3: Vector3)
	local v3 = math.round(vector3.X / VOXEL_SIZE)
	local v4 = math.round(vector3.Y / VOXEL_SIZE)
	local v5 = math.round(vector3.Z / VOXEL_SIZE)
	local v6 = math.abs(v3)
	local v7 = math.abs(v4)

	if v5 == -4 then
		if v6 == 0 and v7 == 0 then
			return color3
		end
	elseif v5 <= 2 then
		if v6 <= 1 and v7 <= 1 and (v5 ~= -3 or v6 ~= 1 or v7 ~= 1) then
			return if v5 == -2 then color7 else color6
		end
	elseif v5 <= 4 and (v6 == 0 and v7 <= 2 or v7 == 0 and v6 <= 2) then
		return color3
	end

	return nil
end

local v3 = nil
local v4 = nil
local flag = false

local function ensureBaked()
	if v3 then
		return
	end

	if flag then
		repeat
			task.wait()
		until v3
	else
		flag = true
		v4 = VoxelProp.bake(Vector3.new(5, 5, 9), Vector3.new(-1.25, -1.25, -2.25), VOXEL_SIZE, bombShape)
		v3 = VoxelProp.bake(Vector3.new(66, 26, 86), Vector3.new(-16.5, -3, -22.5), VOXEL_SIZE, airframe)
	end
end

local function buildJet()
	ensureBaked()
	local v5 = v3
	local v6 = v4
	local strikeJet = Instance.new("Model")
	strikeJet.Name = "StrikeJet"
	local parts2 = {}
	local offsets = {}
	local part = VoxelProp.part(v5, "Airframe")
	part.Parent = strikeJet
	table.insert(parts2, part)
	table.insert(offsets, CFrame.new(v5.center))
	local function on(vector3: Vector3) -- 3 equivalent calls inferred from this helper
		local attachment = Instance.new("Attachment")
		attachment.Position = vector3 - v5.center
		attachment.Parent = part
		return attachment
	end

	local glow = Instance.new("Part")
	glow.Name = "Glow"
	glow.Size = Vector3.new(2, 2, 0.5)
	glow.Color = Color3.fromRGB(255, 150, 60)
	glow.Material = Enum.Material.Neon
	glow.Anchored = true
	glow.CanCollide = false
	glow.CanQuery = false
	glow.CanTouch = false
	glow.CastShadow = false
	glow.Parent = strikeJet
	table.insert(parts2, glow)
	table.insert(offsets, CFrame.new(0, 0, 17.25))

	local cframe2 = CFrame.new(v6.center)
	local bombs = {}
	local parts = {}

	for i = 1, Airstrike.BOMBS do
		local v7 = v2[(i - 1) % #v2 + 1]
		local part2 = VoxelProp.part(v6, "Bomb")
		part2.Parent = strikeJet
		table.insert(parts2, part2)
		local offset = CFrame.new(v7[1], -2.25, v7[2]) * cframe2
		table.insert(offsets, offset)
		table.insert(bombs, {
			part = part2,
			offset = offset,
			at = #parts2
		})
		local part3 = VoxelProp.part(v6, "FallingBomb")
		part3.CFrame = cframe
		part3.Parent = strikeJet
		table.insert(parts, part3)
	end

	local parent = on(Vector3.new(0, 0, 17.6)) -- inferred equivalent call
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = "rbxassetid://13145063652"
	particleEmitter.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
	particleEmitter.FlipbookMode = Enum.ParticleFlipbookMode.Loop
	particleEmitter.LightEmission = 1
	particleEmitter.LightInfluence = 0
	particleEmitter.LockedToPart = true
	particleEmitter.EmissionDirection = Enum.NormalId.Back
	particleEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 225, 160), Color3.fromRGB(255, 110, 40))
	particleEmitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 2.6), NumberSequenceKeypoint.new(1, 0.6) })
	particleEmitter.Transparency = NumberSequence.new(0.1, 1)
	particleEmitter.Lifetime = NumberRange.new(0.08, 0.14)
	particleEmitter.Speed = NumberRange.new(45, 60)
	particleEmitter.Rate = 90 * Quality.share()
	particleEmitter.SpreadAngle = Vector2.new(4, 4)
	particleEmitter.Enabled = false
	particleEmitter.Parent = parent
	local pointLight = Instance.new("PointLight")
	pointLight.Color = Color3.fromRGB(255, 160, 80)
	pointLight.Range = 22
	pointLight.Brightness = 3
	pointLight.Shadows = false
	pointLight.Enabled = false
	pointLight.Parent = parent

	local function trail(vector3: Vector3, vector3_2: Vector3, lifetime: number, color9: Color3, p: number, p2: number)
		local trail2 = Instance.new("Trail")
		local attachment = on(vector3) -- inferred equivalent call
		local attachment2 = on(vector3_2) -- inferred equivalent call
		trail2.Attachment0 = attachment
		trail2.Attachment1 = attachment2
		trail2.Lifetime = lifetime
		trail2.Color = ColorSequence.new(color9)
		trail2.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, p), NumberSequenceKeypoint.new(1, 1) })
		trail2.WidthScale = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, p2) })
		trail2.LightInfluence = 1
		trail2.FaceCamera = true
		trail2.MinLength = 0.5
		trail2.Enabled = false
		trail2.Parent = part
		return trail2
	end

	local haze = trail(Vector3.new(0, 1.1, 18), Vector3.new(0, -1.1, 18), 1.6, Color3.fromRGB(150, 146, 140), 0.72, 3)

	local tipTrails = {}

	for _, v7 in { -1, 1 } do
		local vector3 = Vector3.new(v7 * 15.5, -0.5, 9.300000190734863)
		table.insert(
			tipTrails,
			trail(
				vector3 + Vector3.new(0, 0.18, 0),
				vector3 - Vector3.new(0, 0.18, 0),
				0.9,
				Color3.fromRGB(245, 245, 245),
				0.35,
				2.5
			)
		)
	end

	local frames = table.create(#parts2)

	for k, v7 in offsets do
		frames[k] = cframe * v7
		parts2[k].CFrame = frames[k]
	end

	strikeJet.Parent = airstrikes
	return {
		model = strikeJet,
		parts = parts2,
		offsets = offsets,
		bombs = bombs,
		drops = parts,
		dropOffset = cframe2,
		frames = frames,
		flame = particleEmitter,
		light = pointLight,
		haze = haze,
		tipTrails = tipTrails
	}
end

local function parkJet(jet)
	jet.flame.Enabled = false
	jet.light.Enabled = false
	jet.haze.Enabled = false

	for _, tipTrail in jet.tipTrails do
		tipTrail.Enabled = false
	end

	for k, offset in jet.offsets do
		jet.frames[k] = cframe * offset
	end

	workspace:BulkMoveTo(jet.parts, jet.frames, Enum.BulkMoveMode.FireCFrameChanged)

	for k, bomb in jet.bombs do
		bomb.part.Transparency = 0
		jet.drops[k].CFrame = cframe
	end
end

local function buildTag()
	local strikeTag = Instance.new("Part")
	strikeTag.Name = "StrikeTag"
	strikeTag.Anchored = true
	strikeTag.CanCollide = false
	strikeTag.CanQuery = false
	strikeTag.CanTouch = false
	strikeTag.CastShadow = false
	strikeTag.Transparency = 1
	strikeTag.Size = Vector3.new(0.2, 0.2, 0.2)
	strikeTag.CFrame = cframe
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.AlwaysOnTop = true
	billboardGui.LightInfluence = 0
	billboardGui.Size = UDim2.fromOffset(240, 46)
	billboardGui.MaxDistance = 2000
	billboardGui.ResetOnSpawn = false
	billboardGui.Enabled = false
	billboardGui.Parent = strikeTag
	local label = Style.label(billboardGui, "Head", "AIRSTRIKE", 22, Style.FONT, 2)
	label.AutomaticSize = Enum.AutomaticSize.None
	label.Size = UDim2.new(1, 0, 0, 24)
	label.TextColor3 = Airstrike.ZONE_COLOR:Lerp(Color3.new(1, 1, 1), 0.2)
	local label2 = Style.label(billboardGui, "Caller", "", 14, Style.FONT, 1.5)
	label2.AutomaticSize = Enum.AutomaticSize.None
	label2.Size = UDim2.new(1, 0, 0, 18)
	label2.Position = UDim2.fromOffset(0, 26)
	strikeTag.Parent = airstrikes
	return { part = strikeTag, gui = billboardGui, who = label2 }
end

local v5 = {}
local function buildSlot() -- 2 equivalent calls inferred from this helper
	return { jet = buildJet(), tag = buildTag() }
end

local v6 = {}
local v7 = 0
local renderSteppedConnection = nil

local function untag(state) -- 2 equivalent calls inferred from this helper
	if state.tagOn then
		state.tagOn = false
		state.slot.tag.gui.Enabled = false
	end
end

local function finish(k: number, state) -- 1 equivalent call inferred from this helper
	v6[k] = nil
	v7 -= 1

	if state.zone then
		state.zone:release()
		state.zone = nil
	end

	untag(state) -- inferred equivalent call
	VoxelSound.jetEnd(k)
	parkJet(state.jet)
	table.insert(v5, state.slot)
end

local function fallPose(data, p: number)
	local v8 = data.impact - data.release
	local v9 = math.clamp((p - data.release) / v8, 0, 1)

	local lerped = data.from:Lerp(data.to, v9)
	local v10 = data.vel.Y * v8
	local v11 = data.to.Y - data.from.Y
	local v12 = data.from.Y + v10 * v9 + (v11 - v10) * v9 * v9
	local vector3 = Vector3.new(lerped.X, v12, lerped.Z)
	local vector3_2 = Vector3.new(data.to.X - data.from.X, v10 + (v11 - v10) * 2 * v9, data.to.Z - data.from.Z)
	return CFrame.lookAt(vector3, vector3 + vector3_2) * data.offset
end

local function step()
	local serverTimeNow = workspace:GetServerTimeNow()
	local now = os.clock()
	local position = workspace.CurrentCamera.CFrame.Position

	for k, v8 in v6 do
		local v9 = serverTimeNow - v8.strike.t0

		if Airstrike.LEAVE <= v9 then
			finish(k, v8) -- inferred equivalent call
		else
			if v8.zone then
				if v8.lastImpact + 0.4 < v9 or not localPlayer.Team or localPlayer.Team.Name ~= v8.team then
					v8.zone:release()
					v8.zone = nil
					untag(v8) -- inferred equivalent call
				else
					v8.zone:pulse(now)
				end
			end

			local jet = v8.jet
			local jet2, vel = Airstrike.jet(v8.strike, v9)

			if Airstrike.SPAWN <= v9 then
				local frames = jet.frames

				for k2, offset in jet.offsets do
					frames[k2] = jet2 * offset
				end

				for k2, bomb in v8.bombs do
					if v8.falling[k2] or not (bomb.release <= v9) then
						continue
					end

					local bomb2 = jet.bombs[k2]
					bomb2.part.Transparency = 1
					v8.falling[k2] = {
						part = jet.drops[k2],
						offset = jet.dropOffset,
						from = (jet2 * bomb2.offset).Position,
						vel = vel,
						to = v8.impacts[k2],
						release = bomb.release,
						impact = bomb.impact,
						done = false
					}

					if k2 % 2 == 1 then
						VoxelSound.bombFall(v8.impacts[k2], bomb.impact - v9)
					end
				end

				workspace:BulkMoveTo(jet.parts, frames, Enum.BulkMoveMode.FireCFrameChanged)

				if not v8.shown then
					v8.shown = true
					jet.haze:Clear()

					for _, tipTrail in jet.tipTrails do
						tipTrail:Clear()
					end

					jet.haze.Enabled = true
					jet.flame.Enabled = true
					jet.light.Enabled = not (Quality.mobile or Quality.potato)
				end

				local v10 = Airstrike.runAt(v9)
				local enabled

				if v10 > -700 then
					enabled = v10 < 500
				else
					enabled = false
				end

				for _, tipTrail in jet.tipTrails do
					if tipTrail.Enabled ~= enabled then
						tipTrail.Enabled = enabled
					end
				end
			end

			local v10 = v9

			for _ = 1, 4 do
				v10 = v9 - (Airstrike.jet(v8.strike, v10).Position - position).Magnitude / v
			end

			if Airstrike.SPAWN <= v10 then
				local jet3, v11 = Airstrike.jet(v8.strike, v10)
				VoxelSound.jet(k, jet3.Position, v11)
			end

			for _, v11 in v8.falling do
				if not v11 or v11.done then
					continue
				end

				if v11.impact <= v9 then
					v11.done = true
					v11.part.CFrame = cframe
				else
					v11.part.CFrame = fallPose(v11, v9)
				end
			end
		end
	end

	if v7 == 0 and renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end
end

airstrikeInbound.OnClientEvent:Connect(function(id: number, center: Vector3, dir: Vector3, t0: number, side: number, impacts, team: string?, p: string?)
	if v6[id] then
		return
	end

	local Detail = require(Voxel:WaitForChild("Detail"))
	Detail.mark("strike", center)

	local bombs = Airstrike.bombs()
	assert(#impacts == #bombs, "[AirstrikeView] impact count does not match the bombs")
	local slot = table.remove(v5) or buildSlot() -- inferred equivalent call
	assert(#slot.jet.drops == #bombs, "[AirstrikeView] the jet carries a different bomb count")
	local v8 = {
		strike = {
			id = id,
			center = center,
			dir = dir,
			t0 = t0,
			side = side
		},
		slot = slot,
		jet = slot.jet,
		shown = false,
		falling = {},
		impacts = impacts,
		bombs = bombs,
		zone = nil,
		tagOn = false,
		lastImpact = bombs[#bombs].impact,
		team = team
	}
	local v9

	if localPlayer.Team == nil or team == nil then
		v9 = false
	else
		v9 = localPlayer.Team.Name == team
	end

	if v9 then
		local zone = StrikeZone.take(true)
		zone:place(center, dir, "locked")
		v8.zone = zone
		local tag = slot.tag
		tag.part.CFrame = CFrame.new(center + Vector3.new(0, 14, 0))
		tag.who.Text = "FRIENDLY · " .. string.upper(not p and "someone" or Style.shown(p)) .. " CALLED IT"
		tag.who.TextColor3 = Style.WHITE
		tag.gui.Enabled = true
		v8.tagOn = true
	end

	v6[id] = v8
	v7 += 1

	if not renderSteppedConnection then
		renderSteppedConnection = RunService.RenderStepped:Connect(step)
	end
end)

task.spawn(function()
	while localPlayer:GetAttribute("JoinCovered") == true do
		localPlayer:GetAttributeChangedSignal("JoinCovered"):Wait()
	end

	StrikeZone.prewarm(3)

	while #v5 < 2 do
		table.insert(v5, buildSlot()) -- inferred equivalent call
		task.wait()
	end

	ContentProvider:PreloadAsync({ airstrikes })
end)

task.spawn(function()
	while true do
		task.wait(0.5)
		StrikeZone.sweep()
	end
end)

task.spawn(function()
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local flag2 = false
	local function watch()
		if flag2 then
			return
		end

		flag2 = true

		while true do
			local airstrikeHint = playerGui:FindFirstChild("AirstrikeHint")

			if not airstrikeHint then
				break
			end

			local character = localPlayer.Character
			local tool = character and character:FindFirstChild(Airstrike.TOOL)

			if not (tool and tool:IsA("Tool")) then
				airstrikeHint.Parent = nil
			end

			task.wait(0.15)
		end

		flag2 = false
	end
	playerGui.ChildAdded:Connect(function(child)
		if child.Name == "AirstrikeHint" then
			watch()
		end
	end)
	watch()
end)