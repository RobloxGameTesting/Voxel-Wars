local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vehicles = ReplicatedStorage:WaitForChild("Vehicles")
local VehicleConfig = require(Vehicles:WaitForChild("VehicleConfig"))
require(Vehicles:WaitForChild("JetModel"))
local JetSound = require(script.Parent:WaitForChild("JetSound"))
local JetHud = require(script.Parent:WaitForChild("JetHud"))
local JetCockpit = require(script.Parent:WaitForChild("JetCockpit"))
local Glyph = require(script.Parent.Parent:WaitForChild("GameUI"):WaitForChild("Glyph"))
local Remotes = Vehicles:WaitForChild("Remotes")

local gravity = VehicleConfig.GRAVITY
local LocalPlayer = Players.LocalPlayer
local color = Color3.fromRGB(255, 150, 60)

local v = { h = nil }
local v2 = {
	x = 0,
	y = 0,
	movedAt = 0,
	ray = nil,
	rot = nil,
	side = 1,
	flareAt = -100,
	bombAt = 0,
	cockpit = false,
	gearKey = false,
	gearCheckAt = 0,
	height = 0,
	holdDown = false
}
local JetPilot = {}

function JetPilot.board()
	v2.x = 0
	v2.y = 0
	v2.rot = nil
	v2.ray = nil
	v2.holdDown = false
	v2.airAt = nil
end

local controls = nil
function JetPilot.touchStick()
	if not controls then
		local playerModule = LocalPlayer.PlayerScripts:FindFirstChild("PlayerModule")

		if not playerModule then
			return 0, 0
		end

		local module = require(playerModule)
		controls = module:GetControls()
	end

	local moveVector = controls:GetMoveVector()
	return moveVector.X, -moveVector.Z
end

local function deadened(p: number, p2: number) -- 2 equivalent calls inferred from this helper
	local v3 = math.abs(p2) * 0.3 + 0.15
	local v4 = math.max(math.abs(p) - v3, 0) / (1 - v3)

	if p < 0 then
		return -v4
	end

	return v4
end

function JetPilot.shape(p: number, p2: number, p3: number)
	local v3 = deadened(p, p2) -- inferred equivalent call
	local selected = deadened(p2, p) -- inferred equivalent call
	local v4 = math.sign(v3) * math.abs(v3) ^ 1.4
	local v5 = math.max(math.abs(p3) - 0.15, 0) / 0.85

	if p3 < 0 then
		return v4, selected, -v5
	end

	return v4, selected, v5
end

local function gear(data, state, cframe: CFrame, vector: Vector3, health: number, tuning, callback, p: number)
	local v3 = not state.ground
	local v4 = state.ground and 1.2 or 0.15
	local count = 0
	local total = Vector3.new(0, 0, 0)
	local total2 = 0
	local v5 = -1e999

	if cframe.UpVector.Y > 0.3 then
		for _, foot in data.def.feet do
			local v6 = state.pos + cframe:VectorToWorldSpace(foot)
			local raycastResult = workspace:Raycast(v6 + Vector3.new(0, 3, 0), Vector3.new(0, -4.7, 0), data.params)

			if not raycastResult then
				continue
			end

			local v7 = raycastResult.Position.Y - v6.Y

			if not (-v4 < v7) then
				continue
			end

			count += 1
			total += raycastResult.Normal
			total2 += v7
			v5 = math.max(v5, v7)
		end
	end

	if state.lifting > 0 then
		state.ground = false

		if v5 > 0 then
			state.pos += Vector3.new(0, v5, 0)
		end

		if vector.Y < 3 then
			return (Vector3.new(vector.X, 3, vector.Z))
		end

		return vector
	else
		state.ground = count > 0

		if not state.ground then
			return vector
		end

		local v6 = -vector:Dot(total.Unit)

		if v3 then
			local v7

			if data.wrecked then
				v7 = VehicleConfig.CRASH_SOUND
			elseif health <= tuning.disabledAt then
				v7 = tuning.downCrash
			else
				v7 = tuning.landCrash
			end

			if v7 < v6 then
				callback(data, v6, state.pos, Vector3.new(0, 1, 0))
			end
		end

		local v7 = total2 / count
		local pos = state.pos

		if not (v5 > 0.8) then
			v5 = v7 * (1 - math.exp(p * -14))
		end

		state.pos = pos + Vector3.new(0, v5, 0)
		state.normal = (state.normal or Vector3.new(0, 1, 0)):Lerp(total.Unit, 1 - math.exp(p * -6)).Unit

		if v3 and vector.Y < 0 then
			return (Vector3.new(vector.X, 0, vector.Z))
		end

		return vector
	end
end

function JetPilot.step(data, state, p: number, callback)
	local tuning = data.def.tuning
	local input = state.input
	local health = data.folder:GetAttribute("Health") or 1
	local wrecked = data.wrecked
	local v3 = data.running and not wrecked
	local rotation = state.cf.Rotation
	local vector = rotation.LookVector
	local magnitude = state.vel.Magnitude
	state.throttle = state.throttle or math.clamp(magnitude / tuning.cruise, 0, 1) * 0.85
	local lift = input.lift
	local v4

	if state.ground then
		v4 = input.fwd
	else
		v4 = magnitude < tuning.stall + 20 and input.lift >= 0 and 1 or 0
	end

	local v5 = lift + v4
	state.throttle = not v3 and 0 or math.clamp(state.throttle + v5 * 0.6 * p, 0, 0.85)
	local v6 = v3 and health <= tuning.disabledAt

	if v6 then
		state.throttle = math.min(state.throttle, 0.5)
	end

	local v7 = v3 and not v6 and input.lift > 0
	local v8

	if v7 then
		v8 = tuning.afterburner
	else
		v8 = not v3 and 0 or tuning.cruise * state.throttle / 0.85
	end

	local v9 = magnitude + math.clamp(v8 - magnitude, -tuning.accel * 0.4 * p, tuning.accel * p)

	if not state.ground then
		v9 -= gravity * vector.Y * 0.5 * p
	end

	if input.lift < 0 or state.ground and (not v3 or input.fwd < 0 and v9 < tuning.stall + 10) then
		v9 = math.max(v9 - tuning.brake * p, (state.ground or not v3) and 0 or math.min(v9, tuning.stall + 15))
	end

	local v10 = math.min(v9, tuning.topSpeed)
	local v11 = v7 and 1 or not v3 and 0 or 0.3 + 0.55 * state.throttle
	state.spin += math.clamp(v11 - state.spin, p * -1.5, p * 1.5)

	local v12 = wrecked and 0 or math.clamp(v10 / (tuning.stall * 1.2), 0, 1)
	local v13 = 1 - math.exp(-((state.lifting or 0) > 0 and 15 or 5) * p)

	local v14 = math.asin((math.clamp(vector.Y, -1, 1)))
	local v15 = math.min(
		math.clamp((v10 - tuning.stall) / (tuning.cruise - tuning.stall), 0, 1) * 0.8999999999999999 + 0.3,
		math.clamp((tuning.ceiling - state.pos.Y) / 150, 0, 1) * 1.2
	)

	if state.ground or state.climbOut and input.fwd <= 0 and (state.lifting or 0) <= 0 or input.fwd < 0 then
		state.climbOut = nil
	end

	state.stickHeld = input.fwd == 0 and 0 or math.min((state.stickHeld or 0) + p / 0.5, 1)
	local stickHeld = state.stickHeld
	local v16

	if state.climbOut then
		v16 = math.clamp((0.3 - v14) * 1.5, -0.5, 0.5) * v12
	elseif input.fwd == 0 then
		v16 = math.clamp(-v14 * 1.2, -0.6, 0.6) * v12 * math.clamp((v14 + 0.25) / 0.1, 0, 1)
	else
		v16 = -input.fwd * tuning.pitchRate * (0.45 + 0.55 * stickHeld) * v12
	end

	local v17

	if v16 > 0 then
		v17 = math.clamp((v15 - v14) / 0.2, 0, 1)
	else
		v17 = math.clamp((v14 + 1.45) / 0.5, 0, 1)
	end

	local v18 = v16 * v17

	if v15 < v14 then
		v18 = math.min(v18, (v15 - v14) * 1.5 * v12)
	end

	state.q = (state.q or 0) + (v18 - (state.q or 0)) * v13

	local v19 = math.atan2(-rotation.RightVector.Y, rotation.UpVector.Y)
	local v20 = math.clamp((input.side * tuning.bank - v19) * 3, -tuning.rollRate, tuning.rollRate) * v12
	state.p = (state.p or 0) + (v20 - (state.p or 0)) * v13
	state.r = (state.r or 0) + ((math.sin(v19) / math.sin(tuning.bank) * tuning.turnRate + input.side * 0.2) * v12 - (state.r or 0)) * v13

	state.out = false
	state.lifting = math.max((state.lifting or 0) - p, 0)
	state.rolled = not state.ground and 0 or (state.rolled or 0) + p

	if state.ground and state.lifting <= 0 and v3 and input.lift >= 0 then
		local v21

		if input.fwd < -0.1 then
			v21 = tuning.stall + 10 <= v10
		else
			v21 = false
		end

		local v22

		if tuning.rotate <= v10 and tuning.rotate <= v8 then
			v22 = state.rolled > 1
		else
			v22 = false
		end

		if v21 or v22 then
			state.lifting = tuning.liftTime
			state.p = v20
			state.ground = false
			state.climbOut = true
		end
	end

	local cframe, vector2

	if state.ground then
		local normal = state.normal or Vector3.new(0, 1, 0)
		local v21 = 1 - math.clamp(v10 / tuning.cruise, 0, 1) * 0.7
		local v22 = -input.side * tuning.taxiYaw * v21 * math.clamp(v10 / 10, 0, 1) * p
		local vector3 = CFrame.Angles(0, v22, 0):VectorToWorldSpace(vector)
		local v23 = vector3 - normal * vector3:Dot(normal)

		if v23.Magnitude > 0.05 then
			vector = v23.Unit
		end

		cframe = (CFrame.Angles(0, v22, 0) * rotation):Lerp(
			CFrame.lookAlong(Vector3.new(0, 0, 0), vector, normal),
			1 - math.exp(p * -10)
		)
		vector2 = vector * v10

		state.p = 0
		state.q = 0
		state.r = input.side * tuning.taxiYaw * v21 * math.clamp(v10 / 10, 0, 1)
	else
		local q = state.q
		local p2 = state.p

		if state.lifting > 0 then
			q = math.max(q, rotation.LookVector.Y < 0.18 and 0.35 or 0)
		end

		local cross = vector:Cross(Vector3.new(0, 1, 0))
		local v21

		if cross.Magnitude > 0.05 then
			v21 = cross.Unit
		else
			v21 = rotation.RightVector
		end

		local v22 = Vector3.new(0, 1, 0) - vector * vector.Y
		local v23 = not (v22.Magnitude > 0.05) and Vector3.new(0, 1, 0) or v22.Unit
		local cframe2 = CFrame.fromAxisAngle(v23, -state.r * p) * CFrame.fromAxisAngle(v21, q * p) * rotation * CFrame.Angles(0, 0, -p2 * p)

		if wrecked then
			cframe2 *= CFrame.Angles(p * -0.6, 0, data.spinDir * 1.5 * p)
		end

		local cross2 = cframe2.LookVector:Cross(-Vector3.new(0, 1, 0))

		if v12 < 1 and cross2.Magnitude > 0.01 and not state.ground then
			cframe2 = CFrame.fromAxisAngle(cross2.Unit, (1 - v12) * 0.9 * p) * cframe2
		end

		local vector3 = Vector3.new(state.pos.X, 0, state.pos.Z)

		if vector3.Magnitude > tuning.boundary and not wrecked then
			state.out = true
			local v24 = -vector3.Unit

			if cframe2.LookVector:Dot(v24) < 0.95 then
				local y = cframe2.LookVector:Cross(v24).Y
				cframe2 = CFrame.fromAxisAngle(Vector3.new(0, 1, 0), (y >= 0 and 0.5 or -0.5) * p) * cframe2
			end
		end

		cframe = cframe2:Orthonormalize()
		local v24

		if state.vel.Magnitude > 1 then
			v24 = state.vel.Unit
		else
			v24 = cframe.LookVector
		end

		local lerped = v24:Lerp(cframe.LookVector, 1 - math.exp(-tuning.grip * v12 * p))
		local v25

		if lerped.Magnitude > 0.001 then
			v25 = lerped.Unit
		else
			v25 = cframe.LookVector
		end

		vector2 = v25 * v10 - Vector3.new(0, gravity * (1 - v12 * v12) * p, 0)
		local v26 = state.pos.Y - tuning.ceiling

		if v26 > 0 and vector2.Y > 0 then
			vector2 -= Vector3.new(0, vector2.Y * math.min(v26 / 40, 1) * 3 * p, 0)
		end

		if state.pos.Y < tuning.floor and vector2.Y < 0 then
			vector2 = Vector3.new(vector2.X, 0, vector2.Z)
		end
	end

	local v21 = vector2 * p

	if v21.Magnitude > 0.0001 then
		for _, sphere in data.def.spheres do
			local v22 = state.pos + cframe:VectorToWorldSpace(sphere.at)
			local spherecast = workspace:Spherecast(v22, sphere.r, v21, data.params)

			if not spherecast or spherecast.Normal.Y > 0.5 and (state.ground or state.lifting > 0) then
				continue
			end

			local normal = spherecast.Normal
			local v23 = -vector2:Dot(normal)

			if v23 > 0 then
				vector2 += normal * v23 * 1.2
				callback(data, v23, spherecast.Position, normal)
			end

			v21 = v21.Unit * math.max(spherecast.Distance - 0.05, 0)
		end
	end

	state.pos += v21
	local vel = gear(data, state, cframe, vector2, health, tuning, callback, p)
	state.vel = vel
	local v22 = state.ground

	if v22 then
		if state.spin < 0.01 and vel.Magnitude < 0.3 then
			v22 = not v3
		else
			v22 = false
		end
	end

	state.still = not v22 and 0 or state.still + p

	if state.still > VehicleConfig.SLEEP_TIME then
		state.asleep = true
		state.vel = Vector3.new(0, 0, 0)
	end

	state.cf = CFrame.new(state.pos) * cframe
end

function JetPilot.camera(p, p2: number, p3: number, p4: number, cockpit: boolean, flag: boolean)
	local tuning = p.def.tuning
	v.h = p
	v2.cockpit = cockpit
	local now = os.clock()
	local lastInputType = UserInputService:GetLastInputType()
	local v3 = lastInputType == Enum.UserInputType.Keyboard
		or lastInputType == Enum.UserInputType.MouseMovement
		or lastInputType == Enum.UserInputType.MouseButton1
		or lastInputType == Enum.UserInputType.MouseButton2
		or lastInputType == Enum.UserInputType.MouseWheel

	if (flag or not v3) and (p3 ~= 0 or p4 ~= 0) then
		v2.x = math.clamp(v2.x + p3, -2.6, 2.6)
		v2.y = math.clamp(v2.y - p4, -1, 1.2)
		v2.movedAt = now
	elseif not flag and (v3 or now - v2.movedAt > 0.8) then
		v2.x *= math.exp(p2 * -8)
		v2.y *= math.exp(p2 * -8)
	end

	local v4 = CFrame.Angles(0, v2.x, 0) * CFrame.Angles(v2.y, 0, 0)

	if cockpit then
		local v5 = p.cf * CFrame.new(p.def.EYE)
		v2.ray = Ray.new(v5.Position, v5.LookVector)
		return v5 * v4
	else
		local lookVector = p.cf.LookVector
		local upVector = p.cf.UpVector
		local cframe = (v2.rot or CFrame.lookAlong(Vector3.new(0, 0, 0), lookVector, upVector)):Lerp(
			CFrame.lookAlong(Vector3.new(0, 0, 0), lookVector, upVector * 0.3 + Vector3.new(0, 0.7, 0)),
			1 - math.exp(p2 * -10)
		)
		v2.rot = cframe
		local v5 = p.cf.Position + cframe:VectorToWorldSpace((Vector3.new(0, tuning.chase.height, tuning.chase.distance)))
		local v6 = p.cf.Position + lookVector * 300
		local cframe2 = CFrame.lookAt(v5, v6, cframe.UpVector)
		v2.ray = Ray.new(cframe2.Position, cframe2.LookVector)
		return cframe2 * v4
	end
end

function JetPilot.aimRay()
	return v2.ray
end

function JetPilot.touchHint(data, p: number): nil | string
	local sim = data.sim

	if not sim or data.wrecked then
		return nil
	end

	if sim.ground then
		v2.airAt = nil
		return "PUSH THE STICK UP TO TAKE OFF\n>>  FASTER     <<  BRAKE"
	end

	v2.airAt = v2.airAt or p

	if p - v2.airAt < 10 then
		if data.def.bomber then
			return "PULL THE STICK DOWN  NOSE UP     PUSH IT UP  NOSE DOWN\nBIG BUTTON  BOMBS     FLARES  AUTOMATIC"
		end

		return "PULL THE STICK DOWN  NOSE UP     PUSH IT UP  NOSE DOWN\nBIG BUTTON  GUN     ROCKET  BOMB     FLARES  AUTOMATIC"
	end

	return nil
end

local function inputOn(...): boolean
	if UserInputService:GetFocusedTextBox() ~= nil or GuiService.MenuIsOpen then
		return false
	end

	for _, v3 in { ... } do
		if UserInputService:IsKeyDown(v3) or UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, v3) then
			return true
		end
	end

	return false
end

local function setGear(state, gearUp: boolean) -- 3 equivalent calls inferred from this helper
	if (state.gearUp == true) ~= gearUp then
		state.gearUp = gearUp
		Remotes.HeliFire:FireServer(state.id, "gear", Vector3.new(0, 0, 0), gearUp)
	end
end

local function gearControl(state, flareAt: number)
	local sim = state.sim

	if not sim then
		return
	end

	local tuning = state.def.tuning
	local gearKey = inputOn(Enum.KeyCode.G, Enum.KeyCode.DPadUp)

	if gearKey and not v2.gearKey then
		local gearUp = not (sim.ground or state.gearUp)
		v2.holdDown = not (gearUp or sim.ground)
		setGear(state, gearUp) -- inferred equivalent call
	end

	v2.gearKey = gearKey

	if v2.gearCheckAt <= flareAt then
		v2.gearCheckAt = flareAt + 0.2
		local raycastResult = workspace:Raycast(sim.pos, Vector3.new(0, -110, 0), state.params)
		v2.height = not raycastResult and 110 or raycastResult.Distance
	end

	if sim.ground then
		v2.holdDown = false

		if state.gearUp and (state.gearUp == true) ~= false then
			state.gearUp = false
			Remotes.HeliFire:FireServer(state.id, "gear", Vector3.new(0, 0, 0), false)
		end
	elseif sim.lifting <= 0 then
		if v2.holdDown and (v2.height > 100 or sim.vel.Y > 8 and v2.height > 25) then
			v2.holdDown = false
		end

		if state.gearUp then
			if v2.height < 60 and sim.vel.Y < -2 and sim.vel.Y > -45 and sim.vel.Magnitude < tuning.stall + 90 then
				v2.holdDown = true
				setGear(state, false) -- inferred equivalent call
			end
		elseif not v2.holdDown and v2.height > 25 then
			setGear(state, true) -- inferred equivalent call
		end
	end
end

function JetPilot:fire(flag: boolean, vector3: Vector3, flareAt: number)
	gearControl(self, flareAt)
	local tuning = self.def.tuning

	if flag and v2.bombAt <= flareAt then
		local LoadoutAir = require(ReplicatedStorage.Vehicles.LoadoutAir)
		local rockets = LoadoutAir.rockets
		local Players2 = game:GetService("Players")
		v2.bombAt = flareAt + rockets(Players2.LocalPlayer, tuning).spacing
		v2.side = 3 - v2.side
		Remotes.HeliFire:FireServer(self.id, "bomb", vector3, v2.side)
	end

	local inbound = self.folder:GetAttribute("Inbound")

	if
		(inputOn(Enum.KeyCode.Q, Enum.KeyCode.ButtonB) or inbound and UserInputService.TouchEnabled)
		and flareAt - v2.flareAt >= tuning.flares.cooldown
	then
		v2.flareAt = flareAt
		self.flareAt = flareAt
		Remotes.HeliFire:FireServer(self.id, "flare", vector3)
	end
end

local unit = VehicleConfig.UNIT

local v3 = {
	at = nil,
	vel = nil,
	g = 1,
	groundAt = 0,
	alt = 0
}

local function bombPoint(data)
	local position = data.cf.Position
	local v4 = data.vel

	for _ = 1, 14 do
		local v5 = v4 - Vector3.new(0, gravity * 0.35, 0)
		local v6 = (v4 + v5) * 0.5 * 0.35
		local raycastResult = workspace:Raycast(position, v6, data.params)

		if raycastResult then
			return raycastResult.Position
		end

		position += v6
		v4 = v5
	end

	return nil
end

local v4 = {}
local function padLine(flag: boolean)
	local family = Glyph.family()
	local v5 = v4[family]

	if not v5 then
		local function name(p) -- 6 equivalent calls inferred from this helper
			return Glyph.text(p)
		end

		v5 = { ground = 0, air = 0 }
		v5.ground = "LEFT STICK UP TO TAKE OFF   " .. name(Enum.KeyCode.ButtonL2) .. " BRAKE" -- inferred equivalent call
		v5.air = "STICK DOWN NOSE UP   STICK UP NOSE DOWN   " .. name(Enum.KeyCode.ButtonR2) .. " AFTERBURNER   " .. name(Enum.KeyCode.ButtonL2) .. " SLOW   " .. name(Enum.KeyCode.ButtonB) .. " FLARES   " .. name(Enum.KeyCode.DPadUp) .. " WHEELS   " .. name(Enum.KeyCode.ButtonR3) .. " CAMERA" -- inferred equivalent call

		v4[family] = v5
	end

	return if flag then v5.ground else v5.air
end

function JetPilot.hud(data, _, _, p: number)
	local tuning = data.def.tuning
	local folder = data.folder
	local sim = data.sim
	local cf = data.cf
	local vel = data.vel
	local v5 = math.clamp(p - (v3.at or p), 1 / 240, 0.1)
	v3.at = p

	local v6 = not v3.vel and Vector3.new(0, 0, 0) or (vel - v3.vel) / v5
	v3.vel = vel
	local v7 = (v6 + Vector3.new(0, gravity, 0)):Dot(cf.UpVector) / gravity
	v3.g += (v7 - v3.g) * (1 - math.exp(v5 * -6))
	local ground = not (sim == nil) and sim.ground

	if v3.groundAt <= p then
		v3.groundAt = p + 0.1
		local raycastResult = workspace:Raycast(cf.Position, Vector3.new(0, -3000, 0), data.params)
		v3.alt = not raycastResult and 999 or (cf.Position.Y - raycastResult.Position.Y) / unit
	end

	local lookVector = cf.LookVector
	local pitch = math.asin((math.clamp(lookVector.Y, -1, 1)))
	local bank = math.atan2(-cf.RightVector.Y, cf.UpVector.Y)
	local heading = math.deg((math.atan2(lookVector.X, -lookVector.Z))) % 360
	local input = sim and sim.input
	local health = folder:GetAttribute("Health") or 1
	local burn

	if input == nil or not (input.lift > 0) then
		burn = false
	else
		burn = data.running and not data.wrecked
	end

	local throttle = not (sim and sim.throttle) and 0 or sim.throttle / 0.85
	local flareWait = math.max(tuning.flares.cooldown - (p - v2.flareAt), 0)
	local flares = 1 - flareWait / tuning.flares.cooldown
	local bombs = folder:GetAttribute("Rockets")

	if not bombs then
		local LoadoutAir = require(ReplicatedStorage.Vehicles.LoadoutAir)
		local rockets = LoadoutAir.rockets
		local Players2 = game:GetService("Players")
		bombs = rockets(Players2.LocalPlayer, tuning).count
	end

	local gamepad = Glyph.gamepad()
	local touch = UserInputService.TouchEnabled and not gamepad
	local keys = touch and ""
		or not gamepad
		and (ground and "HOLD W TO TAKE OFF   CTRL BRAKE" or "S UP   W DOWN   A D TURN   SPACE AFTERBURNER   CTRL SLOW   Q FLARES   G WHEELS   V CAMERA")
		or padLine(ground)
	local ray = v2.ray
	local v8 = cf * CFrame.new(data.def.EYE)
	local gunAt

	if ray then
		gunAt = ray.Origin + ray.Direction.Unit * 500
	else
		gunAt = v8.Position + lookVector * 500
	end

	local cockpit = v2.cockpit and not data.def.bomber
	local update = JetHud.update
	local v9 = {
		cam = workspace.CurrentCamera,
		cockpit = cockpit,
		noGun = data.def.bomber == true,
		glass = 0,
		body = 0,
		vel = 0,
		gunAt = 0,
		speed = 0,
		alt = 0,
		climb = 0,
		g = 0,
		throttle = 0,
		burn = 0,
		brake = 0,
		pitch = 0,
		bank = 0,
		heading = 0,
		health = 0,
		wrecked = 0,
		out = 0,
		bombs = 0,
		maxBombs = 0,
		dropAt = 0,
		flares = 0,
		flareWait = 0,
		gearUp = 0,
		ground = 0,
		keys = 0,
		touch = 0,
		now = 0
	}
	local glass

	if cockpit then
		glass = JetCockpit.glassCorners(cf)
	end

	v9.glass = glass
	v9.body = cf
	v9.vel = vel
	v9.gunAt = gunAt
	v9.speed = vel.Magnitude / unit * 3.6
	v9.alt = v3.alt
	v9.climb = vel.Y / unit
	v9.g = v3.g
	v9.throttle = throttle
	v9.burn = burn
	v9.brake = input ~= nil and input.lift < 0
	v9.pitch = pitch
	v9.bank = bank
	v9.heading = heading
	v9.health = health
	v9.wrecked = data.wrecked == true
	v9.out = sim ~= nil and sim.out == true
	v9.bombs = bombs
	local LoadoutAir = require(ReplicatedStorage.Vehicles.LoadoutAir)
	local rockets = LoadoutAir.rockets
	local Players2 = game:GetService("Players")
	v9.maxBombs = rockets(Players2.LocalPlayer, tuning).count
	local dropAt

	if sim and not ground then
		dropAt = bombPoint(data)
	end

	v9.dropAt = dropAt
	v9.flares = flares
	v9.flareWait = flareWait
	v9.gearUp = data.gearUp == true
	v9.ground = ground
	v9.keys = keys
	v9.touch = touch
	v9.now = p
	update(v9)

	if cockpit then
		JetCockpit.update(cf, {
			throttle = throttle,
			burn = burn,
			fwd = not input and 0 or input.fwd,
			side = not input and 0 or input.side,
			gearUp = data.gearUp == true,
			gearT = data.gearT or 0,
			health = health,
			inbound = folder:GetAttribute("Inbound") ~= nil,
			painted = folder:GetAttribute("Painted") == true,
			bombs = bombs,
			flares = flares,
			pitch = pitch,
			bank = bank,
			heading = heading,
			g = v3.g,
			now = p
		}, v5)
	else
		JetCockpit.hide()
	end
end

function JetPilot.hideHud()
	v.h = nil
	v3.at = nil
	v3.vel = nil
	JetSound.leaveCabin()
	JetHud.hide()
	JetCockpit.hide()
end

function JetPilot.sound(p, p2: number)
	JetSound.step(p, p2, v.h == p, v2.cockpit)
end

local function moveGear(state)
	local v5

	if state.sim then
		v5 = state.gearUp == true
	else
		v5 = state.folder:GetAttribute("GearUp") == true
	end

	if not state.sim then
		state.gearUp = v5
	end

	local gearT = state.gearT or 0

	if state.rig and state.gearRig ~= state.rig then
		state.gearRig = state.rig
		state.rig.gear(gearT)
	end

	if gearT == (v5 and 1 or 0) then
		state.gearAt = nil
		state.gearMoving = nil
	else
		local now = os.clock()
		local v6 = math.min(now - (state.gearAt or now), 0.1)

		if v5 ~= state.gearMoving then
			state.gearMoving = v5
			JetSound.gear(state, v.h == state and v2.cockpit)
		end

		state.gearAt = now

		if not v5 then
			v6 = -v6
		end

		local gearT2 = math.clamp(gearT + v6 / 2.5, 0, 1)
		state.gearT = gearT2

		if state.rig then
			state.rig.gear(gearT2)
		end
	end
end

function JetPilot:draw()
	moveGear(self)
	local v5

	if self.spin > 0.1 then
		v5 = not self.wrecked
	else
		v5 = false
	end

	if not self.flames then
		if not v5 or self.def.noFlames then
			return
		end

		self.flames = {}

		for i = 1, #self.def.NOZZLES do
			local flame = Instance.new("Part")
			flame.Name = "Flame"
			flame.Anchored = true
			flame.CanCollide = false
			flame.CanQuery = false
			flame.CanTouch = false
			flame.CastShadow = false
			flame.Material = Enum.Material.Neon
			flame.Color = color
			flame.Parent = self.model
			self.flames[i] = flame
		end
	end

	for k, flame in self.flames do
		local v6 = self.spin > 0.9
		local v7

		if v6 then
			v7 = 7 + math.random() * 2
		else
			v7 = 0.8 + self.spin
		end

		flame.Transparency = v5 and (v6 and 0.15 or 0.55) or 1
		flame.Size = Vector3.new(1.3, 1.3, v7)
		flame.CFrame = self.cf * CFrame.new(self.def.NOZZLES[k] + Vector3.new(0, 0, v7 * 0.5 - 0.5))
	end
end

local v5 = {}
local jetOrdnance = Instance.new("Folder")
jetOrdnance.Name = "JetOrdnance"
jetOrdnance.Parent = workspace

local function shell(size: Vector3, color2: Color3, flag: boolean)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Size = size
	part.Color = color2
	local material

	if flag then
		material = Enum.Material.Neon
	else
		material = Enum.Material.SmoothPlastic
	end

	part.Material = material
	part.Parent = jetOrdnance
	return part
end

local function drop(p: number) -- 2 equivalent calls inferred from this helper
	local v6 = v5[p]

	if v6 then
		v5[p] = nil
		v6.part:Destroy()
	end
end

local function flare(pos: Vector3, vector3: Vector3)
	local VoxelSound = require(ReplicatedStorage.Voxel.VoxelSound)
	VoxelSound.flares(pos)

	for i = 1, 8 do
		local v6 = i / 8 * 3.141592653589793 * 2
		local color2 = Color3.fromRGB(255, 225, 150)
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.Size = Vector3.new(1.2, 1.2, 1.2)
		part.Color = color2
		part.Material = Enum.Material.Neon
		part.Parent = jetOrdnance

		v5[-i - os.clock()] = {
			part = part,
			pos = pos,
			vel = vector3 * 0.5 + Vector3.new(math.cos(v6) * 45, math.sin(v6) * 30 + -20, math.sin(v6) * 45),
			g = 0.3,
			till = os.clock() + 3
		}
	end
end

Remotes:WaitForChild("JetOrdnance").OnClientEvent:Connect(function(p: string, pos, pos2, vel)
	if p == "bomb" then
		local clone = Vehicles:WaitForChild("JetBomb"):Clone()
		clone.Parent = jetOrdnance
		v5[pos] = {
			part = clone,
			pos = pos2,
			vel = vel,
			g = 1,
			till = os.clock() + 25
		}
	elseif p == "gone" then
		drop(pos) -- inferred equivalent call
	elseif p == "flare" then
		flare(pos, pos2)
	end
end)

RunService.Heartbeat:Connect(function(dt: number)
	local now = os.clock()

	for k, v6 in v5 do
		if v6.till < now then
			drop(k) -- inferred equivalent call
		else
			v6.vel -= Vector3.new(0, gravity * v6.g * dt, 0)
			v6.pos += v6.vel * dt
			v6.part.CFrame = CFrame.lookAlong(
				v6.pos,
				not (v6.vel.Magnitude > 1) and Vector3.new(0, 0, 1) or v6.vel.Unit
			)
		end
	end
end)

return JetPilot