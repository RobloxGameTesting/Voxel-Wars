local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local Vehicles = ReplicatedStorage:WaitForChild("Vehicles")
local Remotes = Vehicles:WaitForChild("Remotes")
local VehicleConfig = require(Vehicles:WaitForChild("VehicleConfig"))
local LoadoutGround = require(Vehicles:WaitForChild("LoadoutGround"))
local Materials = require(ReplicatedStorage.Voxel:WaitForChild("Materials"))
local VoxelSound = require(ReplicatedStorage.Voxel:WaitForChild("VoxelSound"))
local Tracers = require(ReplicatedStorage.Voxel:WaitForChild("Tracers"))
local ImpactFX = require(ReplicatedStorage.Voxel:WaitForChild("ImpactFX"))
local TouchControls = require(ReplicatedStorage.Voxel:WaitForChild("TouchControls"))
local Detail = require(ReplicatedStorage.Voxel:WaitForChild("Detail"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local LookSettings = require(ReplicatedStorage2:WaitForChild("Voxel"):WaitForChild("LookSettings"))
local MenuLock = require(ReplicatedStorage.Voxel:WaitForChild("MenuLock"))
local RigidParts = require(Vehicles:WaitForChild("RigidParts"))

local MountedGun = {}

local v = {
	model = Vehicles:WaitForChild("DoorGun"),
	heavyModel = Vehicles:WaitForChild("HeavyGun"),
	barrelTurn = 30,
	follow = 14,
	returnRate = 1.5,
	aimSend = 1 / 15,
	flash = Color3.fromRGB(255, 196, 110),
	jolt = 0.03,
	hum = 0.01,
	metal = Color3.fromRGB(52, 54, 58),
	glow = Color3.fromRGB(255, 112, 40),
	neonAt = 0.75,
	bloomEvery = 0.1,
	scopeFov = 40,
	scopeTime = 0.16,
	mouseTurn = 0.0035,
	padTurn = 3.2
}

local v2 = {
	distance = 11,
	up = 3,
	clearance = 0.6,
	outRate = 4,
	pitchUp = 0.8726646259971648,
	pitchDown = 0.6981317007977318,
	startPitch = -0.13962634015954636
}

local _ = {
	kickReturn = 11,
	gunKick = 0.06,
	barrelKick = 0.2,
	viewPush = 0.07,
	report = 0.95,
	flash = 1.35,
	flashLit = 0.55
}

local v3 = {
	{ size = Vector3.new(0.7, 0.45, 0.12), at = CFrame.new(0, -0.6, -0.95) },
	{
		size = Vector3.new(1.1, 1, 0.12),
		at = CFrame.new(-0.95, -0.42, -0.95)
	},
	{ size = Vector3.new(1.1, 1, 0.12), at = CFrame.new(0.95, -0.42, -0.95) },
	{
		size = Vector3.new(0.12, 0.85, 0.8),
		at = CFrame.new(-1.65, -0.5, -0.62) * CFrame.Angles(0, -0.4363323129985824, 0)
	},
	{
		size = Vector3.new(0.12, 0.85, 0.8),
		at = CFrame.new(1.65, -0.5, -0.62) * CFrame.Angles(0, 0.4363323129985824, 0)
	}
}

local v4 = Materials.Palette[Materials.Ids.HullOlive]

local _ = { fov = 24, saturation = -0.65, contrast = 0.12 }

local color = Color3.fromRGB(24, 25, 28)
local color2 = Color3.fromRGB(242, 238, 228)
local color3 = Color3.fromRGB(255, 198, 32)
local color4 = Color3.fromRGB(214, 72, 52)
local rbxassetfontsfamiliesOswaldjson = Font.new("rbxasset://fonts/families/Oswald.json", Enum.FontWeight.Bold)

local random = Random.new()

local function wrap(p: number) -- 10 equivalent calls inferred from this helper
	return (p + 3.141592653589793) % 6.283185307179586 - 3.141592653589793
end

local function yawOf(vector3: Vector3) -- 3 equivalent calls inferred from this helper
	return (math.atan2(-vector3.X, -vector3.Z))
end

local function ease(p: number, p2: number) -- 3 equivalent calls inferred from this helper
	return 1 - math.exp(-p * p2)
end

local function cfgOf(p) -- 5 equivalent calls inferred from this helper
	if p.def.DRIVER_GUN then
		return LoadoutGround.roofGun(p.def, p.folder)
	end

	local v5 = VehicleConfig.MountedGun[p.def.name]
	assert(v5, "[MountedGun] no VehicleConfig.MountedGun entry for " .. tostring(p.def.name))
	return v5
end

local v5 = nil
function MountedGun.init(p)
	v5 = p
end

function MountedGun:build()
	local def = self.def

	if not def.DOOR_GUNS then
		return
	end

	local v6 = cfgOf(self) -- inferred equivalent call
	local guns = {}

	for i = 1, #def.DOOR_GUNS do
		local v7

		if v6.model then
			v7 = Vehicles:WaitForChild(v6.model)
		else
			v7 = if v6.heavy then v.heavyModel else v.model
		end

		local clone = v7:Clone()
		local v8 = {
			parts = {},
			offsets = {},
			kinds = {},
			barrels = {},
			roots = {},
			frames = {},
			flash = nil,
			light = nil,
			yaw = 0,
			pitch = 0,
			spin = 0,
			angle = 0,
			firing = false,
			flashOn = false,
			lightB = 0,
			lightOn = false,
			heat = 0,
			glow = 0,
			bloomAt = 0,
			kick = 0,
			nextShot = 0,
			posed = nil,
			posedYaw = 1000000000,
			posedPitch = 0,
			posedAngle = 0,
			posedKick = 0,
			posedTurret = 0
		}

		for k, v9 in { "Mount", "Gun", "Barrels" } do
			local root = RigidParts.root(clone, v9 .. "Root")
			v8.roots[k] = root

			for _, part in clone[v9]:GetChildren() do
				if not part:IsA("BasePart") then
					continue
				end

				local cframe = part.CFrame
				table.insert(v8.parts, part)
				table.insert(v8.offsets, cframe)
				table.insert(v8.kinds, k)

				if part.Name == "Barrel" then
					table.insert(v8.barrels, part)
				end

				part.CanQuery = false
				RigidParts.weld(root, part, cframe)
			end
		end

		for _, v9 in def.GUN_SHIELD or v3 do
			local shield = Instance.new("Part")
			shield.Name = "Shield"
			shield.Size = v9.size
			shield.Anchored = true
			shield.CanCollide = false
			shield.CanQuery = false
			shield.CanTouch = false
			shield.Color = v4.color
			shield.Material = v4.material
			shield.MaterialVariant = v4.variant
			local smooth = Enum.SurfaceType.Smooth
			local smooth2 = Enum.SurfaceType.Smooth
			shield.TopSurface = smooth
			shield.BottomSurface = smooth2
			shield.Parent = clone
			RigidParts.weld(v8.roots[1], shield, v9.at)
			table.insert(v8.parts, shield)
			table.insert(v8.offsets, v9.at)
			table.insert(v8.kinds, 1)
		end

		local flash = Instance.new("Part")
		flash.Name = "Flash"
		flash.Size = Vector3.new(0.8, 0.8, 1)
		flash.Material = Enum.Material.Neon
		flash.Color = v.flash
		flash.Anchored = true
		flash.CanCollide = false
		flash.CanQuery = false
		flash.CanTouch = false
		flash.CastShadow = false
		flash.Transparency = 1
		flash.Parent = clone
		local pointLight = Instance.new("PointLight")
		pointLight.Color = v.flash
		pointLight.Range = 10
		pointLight.Brightness = 0
		pointLight.Enabled = false
		pointLight.Parent = flash
		table.insert(v8.parts, flash)
		table.insert(v8.offsets, CFrame.new(def.DOOR_MUZZLE + Vector3.new(0, 0, -0.35)))
		table.insert(v8.kinds, 3)
		RigidParts.weld(v8.roots[3], flash, v8.offsets[#v8.offsets])
		v8.flash = flash
		v8.light = pointLight
		v8.frames = table.create(3, CFrame.identity)
		clone.Name = "MountedGun" .. i
		clone.Parent = self.model
		guns[i] = v8
	end

	self.guns = guns
end

local v6 = {
	v = nil,
	gun = 0,
	yaw = 0,
	pitch = 0,
	spin = 0,
	firing = false,
	autoFire = false,
	heat = 0,
	heatAt = 0,
	last = 0,
	locked = false,
	nextAt = 0,
	shots = 0,
	kick = 0,
	kickYaw = 0,
	aimSentAt = 0,
	shake = CFrame.identity,
	zoom = 0,
	baseFov = nil,
	lastLook = nil,
	cursorHidden = false,
	hintUntil = 0,
	driver = false,
	remote = false,
	range = 0,
	grade = nil,
	camYaw = 0,
	camPitch = 0,
	camDist = 0
}

local v7 = {}
local v8 = {}

v7[1] = "S" .. 1
v8[1] = "Gun" .. 1
v7[2] = "S" .. 2
v8[2] = "Gun" .. 2
v7[3] = "S" .. 3
v8[3] = "Gun" .. 3
v7[4] = "S" .. 4
v8[4] = "Gun" .. 4
v7[5] = "S" .. 5
v8[5] = "Gun" .. 5
v7[6] = "S" .. 6
v8[6] = "Gun" .. 6
v7[7] = "S" .. 7
v8[7] = "Gun" .. 7
v7[8] = "S" .. 8
v8[8] = "Gun" .. 8
v7[9] = "S" .. 9
v8[9] = "Gun" .. 9
v7[10] = "S" .. 10
v8[10] = "Gun" .. 10
v7[11] = "S" .. 11
v8[11] = "Gun" .. 11
v7[12] = "S" .. 12
v8[12] = "Gun" .. 12
v7[13] = "S" .. 13
v8[13] = "Gun" .. 13
v7[14] = "S" .. 14
v8[14] = "Gun" .. 14
v7[15] = "S" .. 15
v8[15] = "Gun" .. 15
v7[16] = "S" .. 16
v8[16] = "Gun" .. 16

function MountedGun.yielded(p): boolean
	local GUNNER_SEAT = p.def.GUNNER_SEAT

	if not GUNNER_SEAT then
		return false
	end

	local attr = v5.attr(p.folder, v7[GUNNER_SEAT])
	return typeof(attr) == "number" and attr > 0 and attr ~= LocalPlayer.UserId
end

local function pose(data, gun, _: number, list, p)
	local posed

	if v6.v == data then
		posed = data.cf
	else
		posed = data.drawnCf or data.cf
	end

	local yaw = data.yaw or 0

	if
		gun.posed == posed
		and gun.posedYaw == gun.yaw
		and gun.posedPitch == gun.pitch
		and gun.posedAngle == gun.angle
		and gun.posedKick == gun.kick
		and gun.posedTurret == yaw
	then
		return
	end

	local yaw2 = gun.yaw
	local pitch = gun.pitch
	local angle = gun.angle
	local kick = gun.kick
	gun.posed = posed
	gun.posedYaw = yaw2
	gun.posedPitch = pitch
	gun.posedAngle = angle
	gun.posedKick = kick
	gun.posedTurret = yaw
	local def = data.def
	local v9 = posed * def.gunRingFrame(gun.yaw, yaw) * CFrame.new(def.GUN_ARM)
	local v10 = v9 * CFrame.Angles(gun.pitch, 0, 0)
	local v11

	if gun.kick > 0 then
		v11 = v10 * CFrame.new(0, 0, gun.kick * 0.06)
	else
		v11 = v10
	end

	if gun.kick > 0 then
		v10 *= CFrame.new(0, 0, gun.kick * 0.2)
	end

	local v12 = v10 * CFrame.Angles(0, 0, gun.angle)
	local frames = gun.frames
	local frames2 = gun.frames
	local frames3 = gun.frames
	frames[1] = v9
	frames2[2] = v11
	frames3[3] = v12

	if not (list and p) then
		workspace:BulkMoveTo(gun.roots, gun.frames, Enum.BulkMoveMode.FireCFrameChanged)

		return
	end

	local count = #list

	list[count + 1] = gun.roots[1]
	p[count + 1] = gun.frames[1]
	list[count + 2] = gun.roots[2]
	p[count + 2] = gun.frames[2]
	list[count + 3] = gun.roots[3]
	p[count + 3] = gun.frames[3]
end

function MountedGun.update(data, p: number, p2, p3)
	local guns = data.guns

	if not guns then
		return
	end

	local v9 = cfgOf(data) -- inferred equivalent call

	for k, gun in guns do
		local v10

		if v6.v == data and v6.gun == k then
			v10 = not (v6.driver and MountedGun.yielded(data))
		else
			v10 = false
		end

		if v10 then
			local yaw = v6.yaw
			local pitch = v6.pitch
			local spin = v6.spin
			local firing = v6.firing
			gun.yaw = yaw
			gun.pitch = pitch
			gun.spin = spin
			gun.firing = firing
			gun.heat = v6.heat
			gun.kick = v6.kick
		else
			local GUNNER_SEAT = data.def.GUNNER_SEAT
			local v11

			if (v5.attr(data.folder, v7[data.def.DOOR_GUNS[k].seat]) or 0) == 0 then
				if GUNNER_SEAT == nil then
					v11 = false
				else
					v11 = (v5.attr(data.folder, v7[GUNNER_SEAT]) or 0) ~= 0
				end
			else
				v11 = true
			end

			local attr = v5.attr(data.folder, v8[k])

			local v12 = ease(v.returnRate, p) -- inferred equivalent call
			local yaw, pitch, firing, v13

			if v11 and typeof(attr) == "Vector3" then
				yaw = attr.X
				pitch = attr.Y
				firing = attr.Z >= 2

				if firing then
					v13 = attr.Z - 2
				else
					v13 = attr.Z
				end

				v12 = ease(v.follow, p) -- inferred equivalent call
			else
				yaw = 0
				pitch = 0
				v13 = 0
				firing = false
			end

			gun.yaw = wrap(gun.yaw + ((yaw - gun.yaw + 3.141592653589793) % 6.283185307179586 - 3.141592653589793) * v12) -- inferred equivalent call
			gun.pitch += (pitch - gun.pitch) * v12

			if math.abs(wrap(yaw - gun.yaw)) < 0.0001 then -- inferred equivalent call
				gun.yaw = yaw
			end

			if math.abs(pitch - gun.pitch) < 0.0001 then
				gun.pitch = pitch
			end

			local spin

			if gun.spin < v13 then
				spin = math.min(v13, gun.spin + p / v9.spinUp)
			else
				spin = math.max(v13, gun.spin - p / v9.spinDown)
			end

			gun.spin = spin
			gun.firing = firing

			if gun.firing then
				gun.heat = math.min(1, gun.heat + v9.heat * v9.rate * p)
			else
				gun.heat = math.max(0, gun.heat - v9.cool * p)
			end
		end

		if gun.spin > 0 and not (v9.heavy or v9.belt) then
			gun.angle = (gun.angle + gun.spin * v.barrelTurn * p) % 6.283185307179586
		end

		local glow = math.clamp((gun.heat - 0.3) / 0.7, 0, 1)

		if math.abs(glow - gun.glow) > 0.03 or glow == 0 and gun.glow ~= 0 then
			gun.glow = glow
			local lerped = v.metal:Lerp(v.glow, glow)
			local material

			if v.neonAt <= glow then
				material = Enum.Material.Neon
			else
				material = Enum.Material.Metal
			end

			for _, barrel in gun.barrels do
				barrel.Color = lerped
				barrel.Material = material
			end
		end

		if v9.heavy then
			if not v10 then
				local now = os.clock()

				if gun.firing and not data.wrecked and gun.nextShot <= now then
					gun.nextShot = math.max(gun.nextShot + 1 / v9.rate, now)
					gun.kick = 1
				end

				gun.kick = not (gun.kick > 0.01) and 0 or gun.kick * math.exp(-11 * p)
			end

			if gun.kick > 0.55 and not data.wrecked then
				local v11 = 1.35 * (0.85 + 0.3 * gun.kick) * (not v10 and 1 or 1 - 0.55 * v6.zoom)

				if not gun.flashOn then
					gun.flash.Transparency = 0.05
				end

				gun.flash.Size = Vector3.new(v11, v11, v11 * 1.3)

				if not Detail.low then
					if gun.lightB ~= 7 then
						gun.lightB = 7
						gun.light.Brightness = 7
					end

					if not gun.lightOn then
						gun.lightOn = true
						gun.light.Enabled = true
					end
				end

				gun.flashOn = true
			elseif gun.flashOn then
				gun.flash.Transparency = 1
				gun.lightB = 0
				gun.lightOn = false
				gun.light.Brightness = 0
				gun.light.Enabled = false
				gun.flashOn = false
			end
		elseif gun.firing and not data.wrecked then
			local now = os.clock()
			local v11 = now - gun.bloomAt >= v.bloomEvery

			if v11 then
				gun.bloomAt = now
			end

			local v12

			if v11 then
				v12 = random:NextNumber(1.4, 1.7)
			else
				v12 = random:NextNumber(0.8, 1.05)
			end

			gun.flash.Transparency = v11 and 0.05 or random:NextNumber(0.2, 0.4)
			gun.flash.Size = Vector3.new(0.8 * v12, 0.8 * v12, random:NextNumber(0.7, 1.2) * v12)

			if not Detail.low then
				local v13 = v11 and 5 or 3

				if gun.lightB ~= v13 then
					gun.lightB = v13
					gun.light.Brightness = v13
				end

				if not gun.lightOn then
					gun.lightOn = true
					gun.light.Enabled = true
				end
			end

			gun.flashOn = true
		elseif gun.flashOn then
			gun.flash.Transparency = 1
			gun.lightB = 0
			gun.lightOn = false
			gun.light.Brightness = 0
			gun.light.Enabled = false
			gun.flashOn = false
		end

		if not data.culled then
			pose(data, gun, k, p2, p3)
		end
	end
end

function MountedGun.seatFrame(p, p2: number)
	local gun = p.def.seats[p2].gun

	if not (gun and p.guns) then
		return nil
	end

	local v9

	if v6.v == p and v6.gun == gun then
		v9 = v6.yaw
	else
		v9 = p.guns[gun].yaw
	end

	return p.def.gunnerFrame(v9)
end

local mountedGunHud = Instance.new("ScreenGui")
mountedGunHud.Name = "MountedGunHud"
mountedGunHud.ResetOnSpawn = false
mountedGunHud.IgnoreGuiInset = true
mountedGunHud.DisplayOrder = 7
mountedGunHud.Enabled = false
mountedGunHud.Parent = LocalPlayer:WaitForChild("PlayerGui")

local function label(parent, text: string, textSize: number, position: UDim2, anchorPoint: Vector2) -- 5 equivalent calls inferred from this helper
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.FontFace = rbxassetfontsfamiliesOswaldjson
	textLabel.TextColor3 = color2
	textLabel.TextSize = textSize
	textLabel.Text = text
	textLabel.AutomaticSize = Enum.AutomaticSize.XY
	textLabel.Position = position
	textLabel.AnchorPoint = anchorPoint
	textLabel.Parent = parent
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Transparency = 0.5
	uiStroke.Parent = textLabel
	return textLabel
end

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(124, 38)
frame.Position = UDim2.new(0.5, 0, 0.5, 64)
frame.AnchorPoint = Vector2.new(0.5, 0)
frame.BackgroundColor3 = color
frame.BackgroundTransparency = 0.12
frame.BorderSizePixel = 0
frame.Parent = mountedGunHud

local frame2 = Instance.new("Frame")
frame2.Size = UDim2.new(0, 22, 0, 4)
frame2.BackgroundColor3 = color3
frame2.BorderSizePixel = 0
frame2.Parent = frame

label(frame, "GUN", 13, UDim2.fromOffset(12, 20), Vector2.new(0, 0.5)) -- inferred equivalent call
local frame3 = Instance.new("Frame")
frame3.Size = UDim2.new(1, -56, 0, 6)
frame3.Position = UDim2.new(0, 44, 0, 17)
frame3.BackgroundColor3 = Color3.fromRGB(60, 60, 62)
frame3.BorderSizePixel = 0
frame3.Parent = frame
local frame4 = Instance.new("Frame")
frame4.Size = UDim2.fromScale(0, 1)
frame4.BackgroundColor3 = color2
frame4.BorderSizePixel = 0
frame4.Parent = frame3

local textLabel = label(mountedGunHud, "GUN HOT", 16, UDim2.new(0.5, 0, 0.5, 58), Vector2.new(0.5, 1)) -- inferred equivalent call
textLabel.TextColor3 = color4
textLabel.Visible = false
local textLabel2 = label(mountedGunHud, "", 14, UDim2.new(0.5, 0, 0.5, 110), Vector2.new(0.5, 0)) -- inferred equivalent call
textLabel2.TextTransparency = 0.15

local frame5 = Instance.new("Frame")
frame5.Size = UDim2.fromOffset(34, 34)
frame5.Position = UDim2.fromScale(0.5, 0.5)
frame5.AnchorPoint = Vector2.new(0.5, 0.5)
frame5.BackgroundTransparency = 1
frame5.Parent = mountedGunHud
local v9 = {}
local v10 = false
local v11 = false

for _, v12 in {
	{ 0.5, 0, 3, 9 },
	{ 0.5, 1, 3, 9 },
	{ 0, 0.5, 9, 3 },
	{ 1, 0.5, 9, 3 },
	{ 0.5, 0.5, 4, 4 }
} do
	local frame6 = Instance.new("Frame")
	frame6.Size = UDim2.fromOffset(v12[3], v12[4])
	frame6.Position = UDim2.fromScale(v12[1], v12[2])
	frame6.AnchorPoint = Vector2.new(v12[1], v12[2])
	frame6.BackgroundColor3 = color2
	frame6.BorderSizePixel = 0
	frame6.Parent = frame5
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = color
	uiStroke.Transparency = 0.4
	uiStroke.Parent = frame6
	table.insert(v9, frame6)
end

local station = Instance.new("Frame")
station.Name = "Station"
station.Size = UDim2.fromScale(1, 1)
station.BackgroundTransparency = 1
station.Visible = false
station.Parent = mountedGunHud
local function bar(parent, size: UDim2, position: UDim2, anchorPoint: Vector2) -- 5 equivalent calls inferred from this helper
	local frame6 = Instance.new("Frame")
	frame6.Size = size
	frame6.Position = position
	frame6.AnchorPoint = anchorPoint
	frame6.BackgroundColor3 = color2
	frame6.BackgroundTransparency = 0.1
	frame6.BorderSizePixel = 0
	frame6.Parent = parent
	return frame6
end

for _, v12 in {
	{ 0, 0 },
	{ 1, 0 },
	{ 0, 1 },
	{ 1, 1 }
} do
	local v13 = v12[1]
	local v14 = v12[2]
	local udim = UDim2.new(0.05 + 0.9 * v13, 0, 0.08 + 0.84 * v14, 0)
	local vector2 = Vector2.new(v13, v14)
	bar(station, UDim2.fromOffset(40, 2), udim, vector2) -- inferred equivalent call
	bar(station, UDim2.fromOffset(2, 40), udim, vector2) -- inferred equivalent call
end

for _, v12 in { -1, 1 } do
	local v13 = 0.5 + v12 * 0.2
	local vector2 = Vector2.new(v12 < 0 and 0 or 1, 0.5)
	bar(station, UDim2.new(0, 2, 0.36, 0), UDim2.fromScale(v13, 0.5), vector2) -- inferred equivalent call

	for _, v14 in { -1, 1 } do
		bar( -- inferred equivalent call
			station,
			UDim2.fromOffset(12, 2),
			UDim2.fromScale(v13, 0.5 + v14 * 0.36 / 2),
			Vector2.new(v12 < 0 and 0 or 1, v14 < 0 and 0 or 1)
		)
	end
end

local frame6 = Instance.new("Frame")
frame6.Size = UDim2.fromOffset(140, 70)
frame6.Position = UDim2.fromScale(0.5, 0.5)
frame6.AnchorPoint = Vector2.new(0.5, 0.5)
frame6.BackgroundTransparency = 1
frame6.Parent = station
local v12 = {}

local function piece(p: number, p2: number, p3: number, p4: number, p5: number, p6: number)
	table.insert(v12, bar(frame6, UDim2.fromOffset(p, p2), UDim2.new(0.5, p3, 0.5, p4), Vector2.new(p5, p6))) -- inferred equivalent call
end

for _, v13 in { -1, 1 } do
	for _, v14 in { -1, 1 } do
		local v15 = v13 < 0 and 0 or 1
		local v16 = v14 < 0 and 0 or 1
		piece(8, 2, v13 * 15, v14 * 15, v15, v16)
		piece(2, 8, v13 * 15, v14 * 15, v15, v16)
	end

	piece(34, 2, v13 * 26, 0, v13 < 0 and 1 or 0, 0.5)
	piece(2, 10, v13 * 60, 0, 0.5, 0.5)
end

piece(2, 9, 0, -22, 0.5, 1)
piece(2, 9, 0, 22, 0.5, 0)
piece(2, 2, 0, 0, 0.5, 0.5)

local function stationText(text: string, textSize: number, position: UDim2, anchorPoint: Vector2) -- 5 equivalent calls inferred from this helper
	local parent = label(station, text, textSize, position, anchorPoint) -- inferred equivalent call
	parent.TextTransparency = 0.05
	return parent
end

local v13 = stationText("RNG  ---", 14, UDim2.new(0.3, 0, 0.6799999999999999, 8), Vector2.new(0, 0)) -- inferred equivalent call
local v14 = stationText("AZ  000", 14, UDim2.new(0.7, 0, 0.6799999999999999, 8), Vector2.new(1, 0)) -- inferred equivalent call
stationText("ROOF GUN", 14, UDim2.new(0.05, 10, 0.08, 10), Vector2.new(0, 0)) -- inferred equivalent call
local v15 = stationText("WIDE", 12, UDim2.new(0.05, 10, 0.08, 30), Vector2.new(0, 0)) -- inferred equivalent call
v15.TextTransparency = 0.3

local function box(p: number, p2: number, text: string)
	local frame7 = Instance.new("Frame")
	frame7.Size = UDim2.fromOffset(46, 84)
	frame7.Position = UDim2.new(p, p2 * -18 + (1 - p2) * 18, 0.5, 0)
	frame7.AnchorPoint = Vector2.new(p2, 0.5)
	frame7.BackgroundTransparency = 1
	frame7.Parent = station
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = color2
	uiStroke.Thickness = 2
	uiStroke.Transparency = 0.1
	uiStroke.Parent = frame7
	stationText(text, 12, UDim2.new(0.5, 0, 1, 6), Vector2.new(0.5, 0)) -- inferred equivalent call
	return frame7
end

local parent = box(0.3, 1, "HEAT")
local frame7 = Instance.new("Frame")
frame7.AnchorPoint = Vector2.new(0.5, 1)
frame7.Position = UDim2.new(0.5, 0, 1, -5)
frame7.Size = UDim2.new(1, -10, 0, 0)
frame7.BackgroundColor3 = color2
frame7.BorderSizePixel = 0
frame7.Parent = parent
local textLabel3 = label(box(0.7, 0, "ZOOM"), "1x", 20, UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5)) -- inferred equivalent call

local v16 = {}

if UserInputService.TouchEnabled then
	local function button(text: string, position: UDim2)
		local textButton = Instance.new("TextButton")
		textButton.Size = UDim2.fromOffset(78, 46)
		textButton.Position = position
		textButton.AnchorPoint = Vector2.new(1, 1)
		textButton.BackgroundColor3 = color
		textButton.BackgroundTransparency = 0.12
		textButton.BorderSizePixel = 0
		textButton.AutoButtonColor = false
		textButton.FontFace = rbxassetfontsfamiliesOswaldjson
		textButton.TextColor3 = color2
		textButton.TextSize = 18
		textButton.Text = text
		textButton.Parent = mountedGunHud
		local frame8 = Instance.new("Frame")
		frame8.Size = UDim2.new(0, 18, 0, 4)
		frame8.BackgroundColor3 = color3
		frame8.BorderSizePixel = 0
		frame8.Parent = textButton
		return textButton
	end

	local v17 = button("FIRE", UDim2.new(1, -100, 0.5, -10))
	v17.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			v10 = true
		end
	end)
	v17.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			v10 = false
		end
	end)
	button("SIGHT", UDim2.new(1, -100, 0.5, -66)).Activated:Connect(function()
		v11 = not v11
	end)
end

function MountedGun.active(): boolean
	return v6.v ~= nil and not v6.driver
end

function MountedGun.start(p, p2: number): boolean
	local remote

	if p.def.seats[p2].gun == nil then
		remote = p2 == p.def.GUNNER_SEAT
	else
		remote = false
	end

	local gun2

	if remote then
		gun2 = p.def.DRIVER_GUN
	else
		gun2 = p.def.seats[p2].gun
	end

	if not (gun2 and p.guns) then
		return false
	end

	v6.v = p
	v6.gun = gun2
	v6.remote = remote
	local gun = p.guns[gun2]

	local yaw = gun.yaw
	local pitch = gun.pitch
	v6.yaw = yaw
	v6.pitch = pitch
	local yaw2 = gun.yaw
	local startPitch = v2.startPitch
	local distance = (p.def.GUNNER_VIEW or v2).distance
	v6.camYaw = yaw2
	v6.camPitch = startPitch
	v6.camDist = distance

	if remote then
		local stationGrade = Instance.new("ColorCorrectionEffect")
		stationGrade.Name = "StationGrade"
		stationGrade.Enabled = false
		stationGrade.Parent = workspace.CurrentCamera
		v6.grade = stationGrade
	end

	v6.spin = 0
	v6.firing = false
	v6.zoom = 0
	v6.autoFire = false
	v6.lastLook = nil
	v10 = false
	v11 = false
	v6.hintUntil = os.clock() + 6
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	mountedGunHud.Enabled = true

	TouchControls.setGunAim({
		aim = function()
			return v6.zoom
		end,
		range = 500,
		fire = function(autoFire: boolean)
			v6.autoFire = autoFire
		end
	})
	return true
end

function MountedGun.stop()
	if not v6.v then
		return
	end

	v6.v = nil
	v6.gun = 0
	v6.remote = false
	v6.firing = false
	v6.spin = 0
	v6.zoom = 0
	v6.kick = 0
	v6.autoFire = false

	if v6.grade then
		v6.grade:Destroy()
		v6.grade = nil
	end

	station.Visible = false

	if v6.driver then
		v6.driver = false
		VoxelSound.minigunOwn(0, false)
	else
		TouchControls.setGunAim(nil)
		v6.shake = CFrame.identity
		mountedGunHud.Enabled = false
		VoxelSound.minigunOwn(0, false)
		local currentCamera = workspace.CurrentCamera

		if v6.baseFov then
			currentCamera.FieldOfView = v6.baseFov
			v6.baseFov = nil
		end

		currentCamera.CameraType = Enum.CameraType.Custom
		local _, cameraSubject = v5.myCharacter()

		if cameraSubject then
			currentCamera.CameraSubject = cameraSubject
		end

		if v6.cursorHidden then
			UserInputService.MouseIconEnabled = true
			v6.cursorHidden = false
		end

		v5.setCharacterShown(true)
	end
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
local v17 = 0
local function refreshAim(p, p2: number)
	if p2 - v17 <= 0.5 then
		return
	end

	v17 = p2
	local excludeInstances = { p.model }

	if LocalPlayer.Character then
		table.insert(excludeInstances, LocalPlayer.Character)
	end

	for _, childName in {
		"VoxelTracers",
		"VoxelLoose",
		"VoxelChips",
		"VoxelFalling",
		"VoxelBombs",
		"VoxelAtmosphere"
	} do
		local child = workspace:FindFirstChild(childName)

		if child then
			table.insert(excludeInstances, child)
		end
	end

	if workspace.CurrentCamera then
		table.insert(excludeInstances, workspace.CurrentCamera)
	end

	raycastParams.ExcludeInstances = excludeInstances
end

function MountedGun.camera(p: number)
	local v18 = v6.v

	if not v18 then
		return
	end

	local v19 = cfgOf(v18) -- inferred equivalent call
	local currentCamera = workspace.CurrentCamera

	if currentCamera.CameraType ~= Enum.CameraType.Scriptable then
		currentCamera.CameraType = Enum.CameraType.Scriptable
	end

	if not GuiService.MenuIsOpen and UserInputService.MouseEnabled then
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		UserInputService.MouseIconEnabled = false
		v6.cursorHidden = true
	end

	v6.baseFov = v6.baseFov or currentCamera.FieldOfView
	local baseFov = v6.baseFov

	local v20 = math.tan(math.rad(currentCamera.FieldOfView) / 2) / math.tan(math.rad(baseFov) / 2)
	local v21 = 0
	local v22 = 0
	local v23

	if TouchControls.active() then
		v23 = Vector2.zero
	else
		v23 = UserInputService:GetMouseDelta()
	end

	if v23.Magnitude > 0 then
		v21 -= v23.X * v.mouseTurn * v20
		v22 += v23.Y * v.mouseTurn * v20
	end

	local stick = v5.stick()

	if stick.Magnitude > 0 then
		v21 -= stick.X * v.padTurn * v20 * LookSettings.look * p
		v22 -= stick.Y * v.padTurn * v20 * LookSettings.look * p
	end

	if v6.lastLook then
		local lastLook = v6.lastLook
		local lookVector = currentCamera.CFrame.LookVector
		local v24 = wrap(yawOf(lookVector) - yawOf(lastLook)) -- inferred equivalent call

		local v25 = math.asin((math.clamp(lastLook.Y, -1, 1))) - math.asin((math.clamp(lookVector.Y, -1, 1)))

		if math.abs(v24) > 0.0001 or math.abs(v25) > 0.0001 then
			v21 += v24
			v22 += v25
		end
	end

	local v24 = v21 * LookSettings.vehicle
	local v25 = v22 * LookSettings.vehicle
	local function turnGun(p2: number, value: number) -- 2 equivalent calls inferred from this helper
		local yaw

		if v19.yaw >= 3.141592653589793 then
			yaw = wrap(p2) -- inferred equivalent call
		else
			yaw = math.clamp(wrap(p2), -v19.yaw, v19.yaw) -- inferred equivalent call
		end

		v6.yaw = yaw
		v6.pitch = math.clamp(value, -v19.pitchDown, v19.pitchUp)
	end

	if v6.zoom > 0 then
		turnGun(v6.yaw + v24, v6.pitch - v25) -- inferred equivalent call
		local yaw = v6.yaw
		local camPitch = math.clamp(v6.pitch, -v2.pitchDown, v2.pitchUp)
		v6.camYaw = yaw
		v6.camPitch = camPitch
	else
		v6.camYaw = wrap(v6.camYaw + v24) -- inferred equivalent call
		v6.camPitch = math.clamp(v6.camPitch - v25, -v2.pitchDown, v2.pitchUp)
	end

	local v26 = v6.zoom * v6.zoom * (3 - 2 * v6.zoom)
	currentCamera.FieldOfView = baseFov + ((v6.remote and 24 or v.scopeFov) - baseFov) * v26

	if v6.grade then
		v6.grade.Enabled = v26 > 0.01
		v6.grade.Saturation = -0.65 * v26
		v6.grade.Contrast = 0.12 * v26
	end

	refreshAim(v18, os.clock())
	local GUNNER_VIEW = v18.def.GUNNER_VIEW or v2
	local position = v18.def.doorGunFrame(v6.gun, 0, 0, v18.yaw).Position
	local cframe = CFrame.fromEulerAnglesYXZ(v6.camPitch, yawOf(v18.cf.LookVector) + v6.camYaw, 0) -- inferred equivalent call
	local v27 = v18.cf:PointToWorldSpace(position) + Vector3.new(0, GUNNER_VIEW.up, 0)
	local v28 = -cframe.LookVector
	local spherecast = workspace:Spherecast(v27, v2.clearance, v28 * GUNNER_VIEW.distance, raycastParams)
	local camDist

	if spherecast then
		camDist = math.max(spherecast.Distance, 1.5)
	else
		camDist = GUNNER_VIEW.distance
	end

	if not (camDist < v6.camDist) then
		camDist = v6.camDist + (camDist - v6.camDist) * ease(v2.outRate, p) -- inferred equivalent call
	end

	v6.camDist = camDist
	local v29 = CFrame.new(v27 + v28 * v6.camDist) * cframe

	if v6.zoom <= 0 then
		local raycastResult = workspace:Raycast(v29.Position, v29.LookVector * 500, raycastParams)
		local v30

		if raycastResult then
			v30 = raycastResult.Position
		else
			v30 = v29.Position + v29.LookVector * 500
		end

		local v31 = v18.cf:PointToObjectSpace(v30) - position
		turnGun(math.atan2(-v31.X, -v31.Z), math.atan2(v31.Y, (math.sqrt(v31.X * v31.X + v31.Z * v31.Z)))) -- inferred equivalent call
	end

	local cframe2 = v29:Lerp(
		v18.cf * v18.def.doorGunFrame(v6.gun, v6.yaw, v6.pitch, v18.yaw) * CFrame.new(v18.def.DOOR_SCOPE_EYE),
		v26
	) * v6.shake

	if not v6.remote then
		v5.setCharacterShown(v26 < 0.5)
	end

	currentCamera.CFrame = cframe2
	currentCamera.Focus = CFrame.new(v27)
	v6.lastLook = cframe2.LookVector
end

local function spreadDir(vector3: Vector3, spread: number)
	local v18 = math.rad(spread) * math.sqrt((random:NextNumber()))
	return (CFrame.lookAt(Vector3.new(0, 0, 0), vector3) * CFrame.Angles(0, 0, random:NextNumber() * 6.283185307179586) * CFrame.Angles(v18, 0, 0)).LookVector
end

local function triggers()
	if UserInputService:GetFocusedTextBox() ~= nil or GuiService.MenuIsOpen then
		return false, false
	end

	local v18 = v10 or v6.autoFire
	local v19

	if UserInputService.MouseEnabled then
		v18 = v18 or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
		v19 = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
	else
		v19 = false
	end

	if UserInputService.GamepadEnabled and not MenuLock.held then
		v18 = v18
			or UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonR2)
			or UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonR1)
		v19 = v19 or UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonL2)
	end

	return v18, v19
end

local function cool(data, heatAt: number) -- 2 equivalent calls inferred from this helper
	local v18 = math.max(v6.heatAt, v6.last + data.coolDelay)

	if v18 < heatAt then
		v6.heat = math.max(0, v6.heat - data.cool * (heatAt - v18))
	end

	v6.heatAt = heatAt

	if v6.locked and v6.heat <= data.unlock then
		v6.locked = false
	end
end

local function shoot(data, aimSentAt: number, origin: Vector3, vector3: Vector3)
	if aimSentAt - v6.nextAt > 0.1 then
		v6.nextAt = aimSentAt
	end

	local result = {}

	while v6.nextAt <= aimSentAt and #result < 8 and not v6.locked do
		v6.nextAt += 1 / data.rate
		local lookVector = spreadDir(vector3, data.spread)
		v6.shots += 1

		if data.heavy then
			VoxelSound.ownSniper(0.95)
			v6.kick = 1
			v6.kickYaw = random:NextNumber(-1, 1)
			v6.pitch = math.clamp(v6.pitch + math.rad(data.climb), -data.pitchDown, data.pitchUp)
			local v18 = math.rad(data.climb * 0.4 * v6.kickYaw)
			local yaw

			if data.yaw >= 3.141592653589793 then
				yaw = wrap(v6.yaw + v18) -- inferred equivalent call
			else
				yaw = math.clamp(v6.yaw + v18, -data.yaw, data.yaw)
			end

			v6.yaw = yaw

			if v6.zoom <= 0 then
				v6.camPitch = math.clamp(v6.camPitch + math.rad(data.climb), -v2.pitchDown, v2.pitchUp)
				v6.camYaw = wrap(v6.camYaw + v18) -- inferred equivalent call
			end
		elseif data.belt then
			VoxelSound.ownLMG(1)
		end

		if v6.shots % data.tracerEvery == 0 then
			local raycastResult = workspace:Raycast(origin, lookVector * 500, raycastParams)
			local v18

			if raycastResult then
				v18 = raycastResult.Position
			else
				v18 = origin + lookVector * 500
			end

			Tracers.fire(origin, v18, nil, nil, true, nil, true)

			if raycastResult and not data.heavy then
				local v19 = raycastResult.Instance == workspace.Terrain
					and raycastResult.Material ~= Enum.Material.Water
				task.delay(
					Tracers.travelTime(origin, v18),
					ImpactFX.bullet,
					raycastResult.Position,
					raycastResult.Normal,
					lookVector,
					v19
				)
			end
		end

		table.insert(result, lookVector)
		v6.heat += data.heat

		if v6.heat >= 1 then
			v6.locked = true
		end
	end

	v6.last = aimSentAt
	return result
end

function MountedGun.step(aimSentAt: number, p: number)
	local v18 = v6.v

	if not v18 then
		return
	end

	local v19 = cfgOf(v18) -- inferred equivalent call
	refreshAim(v18, aimSentAt)

	local myCharacter, v20 = v5.myCharacter()

	if myCharacter and v20 and myCharacter:FindFirstChildOfClass("Tool") then
		v20:UnequipTools()
	end

	cool(v19, aimSentAt) -- inferred equivalent call
	local v21, v22 = triggers()

	if v18.wrecked then
		v22 = false
		v21 = false
	end

	local v23 = p / v.scopeTime
	local zoom

	if (v22 or v11) and not v18.wrecked then
		zoom = math.min(1, v6.zoom + v23)
	else
		zoom = math.max(0, v6.zoom - v23)
	end

	v6.zoom = zoom

	if (v21 or v22) and not v6.locked then
		v6.spin = math.min(1, v6.spin + p / v19.spinUp)
	else
		v6.spin = math.max(0, v6.spin - p / v19.spinDown)
	end

	v6.firing = v21 and not v6.locked and v6.spin >= v19.fireAt

	if not (v19.heavy or v19.belt) then
		VoxelSound.minigunOwn(v6.spin, v6.firing)
	end

	if v6.firing or v6.remote then
		local currentCamera = workspace.CurrentCamera
		local viewportSize = currentCamera.ViewportSize
		local viewportPointToRay = currentCamera:ViewportPointToRay(viewportSize.X * 0.5, viewportSize.Y * 0.5)
		local raycastResult = workspace:Raycast(
			viewportPointToRay.Origin,
			viewportPointToRay.Direction * 500,
			raycastParams
		)
		local v24

		if raycastResult then
			v24 = raycastResult.Position
		else
			v24 = viewportPointToRay.Origin + viewportPointToRay.Direction * 500
		end

		local cframe = v18.cf * v18.def.doorGunFrame(v6.gun, v6.yaw, v6.pitch, v18.yaw)
		local pointToWorldSpace = cframe:PointToWorldSpace(v18.def.DOOR_MUZZLE)
		local v25 = v24 - pointToWorldSpace
		v6.range = not raycastResult and 0 or v25.Magnitude
		local v26

		if v25.Magnitude > 1 and v25.Unit:Dot(cframe.LookVector) > 0.9975640502598242 then
			v26 = v25.Unit
		else
			v26 = cframe.LookVector
		end

		local v27 = not v6.firing and {} or shoot(v19, aimSentAt, pointToWorldSpace, v26)

		if #v27 > 0 then
			if v18.def.DRIVER_GUN then
				Remotes.HeliDoorFire:FireServer(v18.id, v18.yaw or 0, table.unpack(v27))
			else
				Remotes.HeliDoorFire:FireServer(v18.id, table.unpack(v27))
			end
		end

		if not v19.heavy then
			v6.shake = CFrame.Angles(
				math.rad(v.jolt * (random:NextNumber() * 2 - 1)),
				math.rad(v.jolt * (random:NextNumber() * 2 - 1)),
				0
			)
		end
	end

	if v19.heavy then
		v6.kick = not (v6.kick > 0.01) and 0 or v6.kick * math.exp(-11 * p)
		local kick = v6.kick
		local shake

		if kick > 0 then
			shake = CFrame.new(0, 0, 0.07 * kick) * CFrame.Angles(
				math.rad(v19.kick * kick),
				math.rad(v19.kick * 0.35 * v6.kickYaw * kick),
				0
			)
		else
			shake = CFrame.identity
		end

		v6.shake = shake
	elseif not v6.firing then
		if v6.spin > 0.3 then
			local v24 = v.hum * v6.spin
			v6.shake = CFrame.Angles(
				math.rad(v24 * (random:NextNumber() * 2 - 1)),
				math.rad(v24 * (random:NextNumber() * 2 - 1)),
				0
			)
		else
			v6.shake = CFrame.identity
		end
	end

	if aimSentAt - v6.aimSentAt >= v.aimSend then
		v6.aimSentAt = aimSentAt
		Remotes.HeliGunAim:FireServer(v18.id, v6.yaw, v6.pitch, v6.spin + (v6.firing and 2 or 0))
	end

	frame.Visible = not v6.remote
	station.Visible = v6.remote and not v18.wrecked
	local v24 = math.clamp(v6.heat, 0, 1)
	local locked = v6.locked == true
	local v25

	if locked then
		v25 = color4
	else
		v25 = if v24 > 0.7 then color3 else color2
	end

	if v6.remote then
		if v16.fillH ~= v24 then
			v16.fillH = v24
			frame7.Size = UDim2.new(1, -10, v24, v24 * -10)
		end

		if v16.fillTint ~= v25 then
			v16.fillTint = v25
			frame7.BackgroundColor3 = v25
		end

		if v16.stationLocked ~= locked then
			v16.stationLocked = locked

			for _, v26 in v12 do
				local backgroundColor

				if locked then
					backgroundColor = color4
				else
					backgroundColor = color2
				end

				v26.BackgroundColor3 = backgroundColor
			end
		end

		local range = not (v6.range > 0) and -1 or math.round(v6.range / 2.5)

		if v16.range ~= range then
			v16.range = range
			v13.Text = not (range >= 0) and "RNG  ---" or string.format("RNG  %03d M", range)
		end

		local bearing = math.round(-math.deg(v6.yaw)) % 360

		if v16.bearing ~= bearing then
			v16.bearing = bearing
			v14.Text = string.format("AZ  %03d", bearing)
		end

		local zoomed = v6.zoom > 0.5
		local mag = not zoomed and 1 or math.round(math.tan(math.rad(v6.baseFov or 70) / 2) / 0.21255656167002213)

		if v16.mag ~= mag then
			v16.mag = mag
			textLabel3.Text = string.format("%dx", mag)
		end

		if v16.zoomed ~= zoomed then
			v16.zoomed = zoomed
			v15.Text = zoomed and "SIGHT CAM" or "WIDE"
		end
	end

	if v16.barH ~= v24 then
		v16.barH = v24
		frame4.Size = UDim2.fromScale(v24, 1)
	end

	if v16.barTint ~= v25 then
		v16.barTint = v25
		frame4.BackgroundColor3 = v25
	end

	textLabel.Visible = v6.locked and not v18.wrecked
	frame5.Visible = not v6.remote and not v18.wrecked and v6.zoom < 0.35

	if v16.reticleLocked ~= locked then
		v16.reticleLocked = locked

		for _, v26 in v9 do
			local backgroundColor = if locked then color4 else color2
			v26.BackgroundColor3 = backgroundColor
		end
	end

	textLabel2.Visible = aimSentAt < v6.hintUntil
	local padMode = LocalPlayer:GetAttribute("PadMode") == true
	local hint = TouchControls.active() and "touch" or padMode and "pad" or "mouse"

	if v16.hint ~= hint then
		v16.hint = hint
		textLabel2.Text = hint == "touch" and "DRAG  AIM     FIRE  HOLD     SIGHT  AIM IN"
			or hint == "pad" and "RS  AIM     RT  FIRE     LT  SIGHT     Y  OUT"
			or "MOUSE  AIM     LMB  FIRE     RMB  SIGHT     E  OUT"
	end

	local gun = v18.guns[v6.gun]
	local yaw = v6.yaw
	local pitch = v6.pitch
	local spin = v6.spin
	local firing = v6.firing
	local kick = v6.kick
	gun.yaw = yaw
	gun.pitch = pitch
	gun.spin = spin
	gun.firing = firing
	gun.kick = kick
	pose(v18, gun, v6.gun)
end

function MountedGun.drive(p): boolean
	local DRIVER_GUN = p.def.DRIVER_GUN

	if not (DRIVER_GUN and p.guns) then
		return false
	end

	v6.v = p
	v6.gun = DRIVER_GUN
	v6.driver = true
	local gun = p.guns[DRIVER_GUN]
	local yaw = gun.yaw
	local pitch = gun.pitch
	v6.yaw = yaw
	v6.pitch = pitch
	v6.spin = 0
	v6.firing = false
	v6.zoom = 0
	v6.kick = 0
	v6.shake = CFrame.identity
	return true
end

function MountedGun.driveStep(aimSentAt: number, p: number, vector3: Vector3?, flag: boolean)
	local v18 = v6.v

	if not (v18 and v6.driver) then
		return 0, false, nil, nil
	end

	local v19 = cfgOf(v18) -- inferred equivalent call
	local def = v18.def

	if MountedGun.yielded(v18) then
		local gun = v18.guns[v6.gun]
		local yaw = gun.yaw
		local pitch = gun.pitch
		v6.yaw = yaw
		v6.pitch = pitch
		v6.firing = false
		v6.spin = 0
		return 0, false, nil, nil
	else
		refreshAim(v18, aimSentAt)
		cool(v19, aimSentAt) -- inferred equivalent call

		if vector3 then
			local cframe = v18.cf * def.gunRingFrame(0, v18.yaw)
			local pointToObjectSpace = cframe:PointToObjectSpace(vector3)
			local v20 = math.atan2(-pointToObjectSpace.X, -pointToObjectSpace.Z)
			local pointToObjectSpace2 = (cframe * CFrame.Angles(0, v20, 0) * CFrame.new(def.GUN_ARM)):PointToObjectSpace(vector3)
			local v21 = math.clamp(
				math.atan2(pointToObjectSpace2.Y, -pointToObjectSpace2.Z),
				-v19.pitchDown,
				v19.pitchUp
			)
			local v22 = v19.turn * p
			v6.yaw = wrap(v6.yaw + math.clamp(wrap(v20 - v6.yaw), -v22, v22)) -- inferred equivalent call
			v6.pitch += math.clamp(v21 - v6.pitch, -v22, v22)
		end

		local v20 = flag and not v18.wrecked

		if v20 and not v6.locked then
			v6.spin = math.min(1, v6.spin + p / v19.spinUp)
		else
			v6.spin = math.max(0, v6.spin - p / v19.spinDown)
		end

		v6.firing = v20 and not v6.locked and v6.spin >= v19.fireAt

		if not v19.belt then
			VoxelSound.minigunOwn(v6.spin, v6.firing)
		end

		if v6.firing then
			local cframe = v18.cf * def.doorGunFrame(v6.gun, v6.yaw, v6.pitch, v18.yaw)
			local v21 = shoot(v19, aimSentAt, cframe:PointToWorldSpace(def.DOOR_MUZZLE), cframe.LookVector)

			if #v21 > 0 then
				Remotes.HeliDoorFire:FireServer(v18.id, v18.yaw, table.unpack(v21))
			end
		end

		if aimSentAt - v6.aimSentAt >= v.aimSend then
			v6.aimSentAt = aimSentAt
			Remotes.HeliGunAim:FireServer(v18.id, v6.yaw, v6.pitch, v6.spin + (v6.firing and 2 or 0))
		end

		local gun = v18.guns[v6.gun]
		local yaw = v6.yaw
		local pitch = v6.pitch
		local spin = v6.spin
		local firing = v6.firing
		gun.yaw = yaw
		gun.pitch = pitch
		gun.spin = spin
		gun.firing = firing
		gun.kick = 0
		pose(v18, gun, v6.gun)
		local cframe = v18.cf * def.doorGunFrame(v6.gun, v6.yaw, v6.pitch, v18.yaw)
		return v6.heat, v6.locked, cframe:PointToWorldSpace(def.DOOR_MUZZLE), cframe.LookVector
	end
end

function MountedGun:destroy()
	if v6.v == self then
		MountedGun.stop()
	end

	self.guns = nil
end

return MountedGun