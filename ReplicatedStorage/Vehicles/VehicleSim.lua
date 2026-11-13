--!native
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VehicleConfig = require(ReplicatedStorage.Vehicles.VehicleConfig)
local VehicleGrid = require(ReplicatedStorage.Vehicles.VehicleGrid)

local step = VehicleConfig.STEP

local v = {
	[Enum.Material.Sand] = 0.8,
	[Enum.Material.Mud] = 0.75,
	[Enum.Material.Snow] = 0.6,
	[Enum.Material.Ice] = 0.3,
	[Enum.Material.Glacier] = 0.35,
	[Enum.Material.Glass] = 0.45,
	[Enum.Material.Water] = 0.3,
	[Enum.Material.Grass] = 0.9,
	[Enum.Material.LeafyGrass] = 0.9,
	[Enum.Material.Ground] = 0.9
}

local v2 = {
	[Enum.Material.Wood] = 0,
	[Enum.Material.WoodPlanks] = 0,
	[Enum.Material.Glass] = 0,
	[Enum.Material.Plaster] = 0,
	[Enum.Material.Fabric] = 0,
	[Enum.Material.Brick] = 1,
	[Enum.Material.ClayRoofTiles] = 1
}

local VehicleSim = {}

local object = setmetatable({}, { __mode = "k" })
local function probeKinds(def)
	local result = object[def]

	if result then
		return result
	end

	local v3 = def.size.X / 2 - 1.6
	result = {}

	for k, probe in def.probes do
		result[k] = probe.Y > 1.7 and 0 or v3 <= math.abs(probe.X) and 2 or 1
	end

	object[def] = result

	return result
end

local v3 = {}
local count = 0

local function invInertia(p, vector3: Vector3) -- 2 equivalent calls inferred from this helper
	local cf = p.cf
	return cf:VectorToWorldSpace(cf:VectorToObjectSpace(vector3) * p.invI)
end

local function addRow(state, vector: Vector3, vector2: Vector3, target: number, lo: number, hi: number)
	count += 1
	local v4 = v3[count]

	if not v4 then
		v4 = {
			r = vector,
			n = vector2,
			ia = Vector3.new(0, 0, 0),
			m = 0,
			target = 0,
			lo = 0,
			hi = 0,
			lambda = 0
		}
		v3[count] = v4
	end

	local vector3 = invInertia(state, vector:Cross(vector2)) -- inferred equivalent call
	v4.r = vector
	v4.n = vector2
	v4.ia = vector3
	local v5 = state.invMass + vector2:Dot(vector3:Cross(vector))
	v4.m = not (v5 > 1e-12) and 0 or 1 / v5
	v4.target = target
	v4.lo = lo
	v4.hi = hi
	v4.lambda = 0
	return v4
end

local function relVel(state, p) -- 2 equivalent calls inferred from this helper
	return (state.vel + state.ang:Cross(p.r)):Dot(p.n)
end

local function push(state, state2, p: number) -- 3 equivalent calls inferred from this helper
	if p ~= 0 then
		state2.lambda += p
		state.vel += state2.n * (p * state.invMass)
		state.ang += state2.ia * p
	end
end

local function solveRow(state, data) -- 7 equivalent calls inferred from this helper
	local v4 = (data.target - relVel(state, data)) * data.m -- inferred equivalent call
	push(state, data, math.clamp(data.lambda + v4, data.lo, data.hi) - data.lambda) -- inferred equivalent call
end

local function isStep(data, position: Vector3, vector: Vector3, upVector: Vector3, climb: number): boolean
	local y = data.cf:PointToObjectSpace(position).Y

	if climb <= y then
		return false
	end

	local v4 = vector - upVector * vector:Dot(upVector)

	if v4.Magnitude < 0.001 then
		return false
	end

	local unit = v4.Unit
	local v5 = upVector * (climb - y)
	local v6 = position + v5 + unit * 1.5
	local v7 = -unit * 1.9
	local v8

	if data.query then
		v8 = data.query.ray(v6, v7)
	else
		v8 = workspace:Raycast(v6, v7, data.params)
	end

	if v8 then
		return false
	end

	local v9 = position - unit * 0.4 + v5
	local v10 = -upVector * (climb - y + 0.05)
	local v11

	if data.query then
		v11 = data.query.ray(v9, v10)
	else
		v11 = workspace:Raycast(v9, v10, data.params)
	end

	return v11 ~= nil and v11.Distance >= 0.02 and v11.Normal:Dot(upVector) >= 0.3
end

function VehicleSim.new(def, tuning, cframe: CFrame, buf: buffer, params)
	local minZ = 1e999
	local maxZ = -1e999
	local wheels = {}

	for _, wheel in def.wheels do
		minZ = math.min(minZ, wheel.mount.Z)
		maxZ = math.max(maxZ, wheel.mount.Z)
		table.insert(wheels, {
			def = wheel,
			comp = 0,
			over = 0,
			shown = wheel.travel * 0.5,
			steer = 0,
			angle = 0,
			speed = 0,
			contact = false,
			point = Vector3.new(0, 0, 0),
			normal = Vector3.new(0, 1, 0),
			material = Enum.Material.Air,
			instance = nil,
			support = 0,
			slip = 0,
			slipAngle = 0,
			spinning = false,
			landing = 0
		})
	end

	local v4 = {
		def = def,
		tuning = tuning,
		cf = cframe,
		vel = Vector3.new(0, 0, 0),
		ang = Vector3.new(0, 0, 0),
		mass = 1,
		invMass = 1,
		com = Vector3.new(0, 0, 0),
		invI = Vector3.new(1, 1, 1),
		wheels = wheels,
		input = { steer = 0, throttle = 0, handbrake = false, driver = false },
		steer = 0,
		steerMove = 0,
		throttle = 0,
		dir = 0,
		gear = 1,
		shifted = false,
		shift = 0,
		startup = 0,
		prevCf = cframe,
		wheelRows = {},
		hullRows = {},
		running = false,
		health = 1,
		braking = false,
		asleep = false,
		still = 0,
		accum = 0,
		params = params,
		crash = nil,
		plough = 0,
		ploughSpeed = 0,
		speed = 0,
		wheelbase = math.max(maxZ - minZ, 0),
		pivot = 0
	}

	VehicleSim.setHull(v4, buf)
	return v4
end

function VehicleSim:setHull(buf: buffer)
	local def = self.def
	local v4 = {}

	for _, wheel in def.wheels do
		table.insert(v4, wheel.mount - Vector3.new(0, 1, 0) * (wheel.travel * 0.5))
	end

	local massPropsShare, com, invI = VehicleGrid.massPropsShare(def, buf, v4, 0.035)

	local tuning = self.tuning

	if tuning.inertia then
		invI /= Vector3.new(tuning.inertia, 1, tuning.inertia)
	end

	if tuning.comDrop then
		com -= Vector3.new(0, 1, 0) * tuning.comDrop
	end

	local pointToWorldSpace = self.cf:PointToWorldSpace(self.com)
	local pointToWorldSpace2 = self.cf:PointToWorldSpace(com)
	self.vel += self.ang:Cross(pointToWorldSpace2 - pointToWorldSpace)
	local invMass = 1 / massPropsShare
	self.mass = massPropsShare
	self.invMass = invMass
	self.com = com
	self.invI = invI
end

function VehicleSim:wake()
	self.asleep = false
	self.still = 0
end

function VehicleSim:kick(vector3: Vector3, vector3_2: Vector3?)
	VehicleSim.wake(self)
	local vector3_3 = vector3 * self.mass
	self.vel += vector3

	if vector3_2 then
		local vector = vector3_2 - self.cf:PointToWorldSpace(self.com)
		self.ang += invInertia(self, vector:Cross(vector3_3)) -- inferred equivalent call
	end
end

function VehicleSim:takeCrash()
	local crash = self.crash
	self.crash = nil
	return crash
end

function VehicleSim.wheelCFrame(cframe: CFrame, p, p2: number, p3: number, p4: number)
	return cframe * (CFrame.fromEulerAnglesYXZ(-p4, -p3, 0) + (p.mount - Vector3.new(0, 1, 0) * (p.travel - p2)))
end

local function controls(state, p: number)
	local tuning = state.tuning
	local input = state.input
	local speed = state.speed

	local v4 = math.clamp(input.steer, -1, 1)
	local v5 = math.abs(speed) / VehicleConfig.UNIT

	local steerMove2 = (v4 ~= 0 and 0 or -state.steer * VehicleConfig.STEER_BACK * math.clamp((v5 - 0.2) / 4, 0, 1)) + math.sign(v4 - state.steer) * VehicleConfig.STEER_SPEED / (1 + 0.05 * v5)
	local steerMove = state.steerMove

	if math.abs(steerMove2) > math.abs(steerMove) and math.sign(steerMove2) == math.sign(steerMove) then
		steerMove2 = steerMove + (steerMove2 - steerMove) * VehicleConfig.STEER_RESPONSE
	end

	state.steerMove = steerMove2

	if math.abs(v4 - state.steer) < math.abs(steerMove2) then
		state.steer += (v4 - state.steer) * 0.3
	else
		state.steer = math.clamp(state.steer + steerMove2, -1, 1)
	end

	local v6 = not (input.driver and state.running and state.health > 0) and 0 or input.throttle
	local dir = v6 > 0.05 and 1 or v6 < -0.05 and 2 or 0

	if dir == 0 then
		if state.dir == 3 then
			state.dir = 0
		end
	elseif dir ~= state.dir then
		if state.dir == 3 then
			local v7

			if dir == 1 and speed < -VehicleConfig.SWITCH_SHIFT then
				v7 = true
			elseif dir == 2 then
				v7 = VehicleConfig.SWITCH_SHIFT < speed
			else
				v7 = false
			end

			if not v7 then
				state.dir = dir
				state.shift = VehicleConfig.SHIFT_TIME
			end
		else
			local v7

			if dir == 2 and VehicleConfig.SWITCH_BRAKE < speed then
				v7 = true
			elseif dir == 1 then
				v7 = speed < -VehicleConfig.SWITCH_BRAKE
			else
				v7 = false
			end

			if v7 then
				state.dir = 3
			else
				if state.dir ~= 0 then
					state.shift = VehicleConfig.SHIFT_TIME
				end

				state.dir = dir
			end
		end
	end

	local v7 = 0

	if state.dir == 1 then
		v7 = math.max(v6, 0)
	elseif state.dir == 2 then
		v7 = math.min(v6, 0)
	end

	if state.shift > 0 then
		state.shift -= p
		v7 = 0
	end

	if v7 == 0 then
		state.throttle = 0
	else
		state.throttle += (v7 - state.throttle) * VehicleConfig.PEDAL_RESPONSE
	end

	state.startup = math.max(state.startup - p * VehicleConfig.STARTUP_DECAY, 0)
	local v8 = 1 - state.startup
	state.throttle = math.clamp(state.throttle, -v8, v8)
	state.braking = state.dir == 3

	local gears = tuning.gears
	local gear = state.gear

	if state.dir == 1 then
		local v9 = math.max(speed, 0)

		if
			gear < #gears
			and gears[gear] * tuning.topSpeed * VehicleConfig.UPSHIFT < v9
			and v6 > 0.3
			and not (tuning.hill and state.cf.LookVector.Y > 0.2)
		then
			gear += 1
			state.shift = math.max(state.shift, VehicleConfig.UPSHIFT_TIME)
		elseif gear > 1 and state.shift <= 0 and v9 < gears[gear - 1] * tuning.topSpeed * VehicleConfig.DOWNSHIFT then
			gear -= 1
		end
	else
		gear = 1
	end

	state.shifted = gear ~= state.gear and state.dir == 1
	state.gear = gear
end

local function stepOnce(state, step2: number)
	local def = state.def
	local tuning = state.tuning
	local timeScale = VehicleConfig.timeScale()
	local gravity = VehicleConfig.GRAVITY
	local mass = state.mass
	local cf = state.cf
	local upVector = cf.UpVector
	local lookVector = cf.LookVector
	state.speed = state.vel:Dot(lookVector)

	controls(state, step2)

	state.vel += Vector3.new(0, -gravity * step2, 0)
	local pointToWorldSpace = cf:PointToWorldSpace(state.com)
	count = 0

	local v4 = math.clamp(math.abs(state.speed) / tuning.topSpeed, 0, 1)
	local v5 = tuning.maxSteer * (1 + (tuning.highSpeedSteer - 1) * v4)

	local steerGrip = tuning.steerGrip

	if steerGrip and state.wheelbase > 0 and math.abs(state.speed) > 1 then
		v5 = math.min(
			v5,
			(math.atan(steerGrip * tuning.friction * gravity * state.wheelbase / (state.speed * state.speed)))
		)
	end

	local v6 = not (state.input.driver or state.input.coast)
	local v7 = state.health * 0.5 + 0.5

	local v8 = 0
	local vector = Vector3.new(0, 0, 0)

	if tuning.pivot then
		local input = state.input

		local v9 = (not input.driver or not state.running or not (state.health > 0) or input.handbrake or not (math.abs(input.throttle) < 0.05 and math.abs(input.steer) > 0.05))
			and 0
			or math.clamp(1 - math.abs(state.speed) / 5, 0, 1)

		state.pivot += (v9 - state.pivot) * math.min(step2 * 6, 1)

		if state.pivot > 0.01 and not (v6 or input.handbrake) then
			v8 = state.pivot
			vector = -upVector * (tuning.pivot * state.steer)
		end
	end

	local count2 = 0
	local total = 0

	for _, wheel in state.wheels do
		if not (wheel.def.drive > 0) then
			continue
		end

		count2 += 1
		total += wheel.support
	end

	local wheelRows = state.wheelRows
	local count3 = 0
	local v9 = state.input.driver

	if v9 then
		if state.throttle == 0 then
			v9 = not state.braking and math.abs(state.speed) < VehicleConfig.HOLD_SPEED
		else
			v9 = false
		end
	end

	for _, wheel in state.wheels do
		local def2 = wheel.def
		local v10

		if state.steer > 0 and def2.side < 0 then
			v10 = true
		elseif state.steer < 0 then
			v10 = def2.side > 0
		else
			v10 = false
		end

		wheel.steer = state.steer * v5 * def2.steer * (not v10 and 1 or tuning.outerSteer) * (1 - v8)

		local v11 = cf:PointToWorldSpace(def2.mount) + upVector * 1.1
		local v12 = def2.travel + 1.1
		local v13

		if state.query then
			v13 = state.query.sphere(v11, def2.radius, -upVector * v12)
		else
			v13 = workspace:Spherecast(v11, def2.radius, -upVector * v12, state.params)
		end

		local comp = wheel.comp

		if v13 and v13.Normal:Dot(upVector) > 0.3 then
			local v14 = v12 - v13.Distance
			wheel.comp = math.clamp(v14, 0, def2.travel)
			wheel.over = math.max(v14 - def2.travel, 0)
			wheel.contact = true
			wheel.point = v13.Position
			wheel.normal = v13.Normal
			wheel.material = v13.Material
			wheel.instance = v13.Instance
		else
			wheel.comp = 0
			wheel.over = 0
			wheel.contact = false
			wheel.instance = nil
		end

		wheel.landing = not wheel.contact and 0 or (wheel.comp - comp) / step2

		if wheel.comp >= wheel.shown then
			wheel.shown = wheel.comp
		else
			wheel.shown += (wheel.comp - wheel.shown) * math.min(step2 * 14, 1)
		end

		if wheel.contact then
			local vector2 = wheel.normal

			if def.climb and vector2:Dot(upVector) < 0.9659258262890683 then
				local v14 = vector2 - upVector * vector2:Dot(upVector)

				if v14.Magnitude > 0.001 then
					vector2 = upVector * 0.9659258262890683 + v14.Unit * 0.25881904510252074
				end
			end

			local v14 = math.max(vector2:Dot(upVector), 0)
			local v15 = wheel.point - pointToWorldSpace
			local dot = (state.vel + state.ang:Cross(v15)):Dot(vector2)

			local v16 = wheel.comp * mass * 40 * tuning.spring * v14 * timeScale * timeScale * step2
			local v17 = math.max(-dot, 0) * mass * 3 * tuning.damping * v14 * timeScale * step2
			local spring = addRow(state, v15, vector2, wheel.comp * 10 * timeScale, 0, v16 + v17)
			local bump

			if wheel.over > 0 or wheel.comp >= def2.travel - 0.001 then
				bump = addRow(state, v15, vector2, math.min(wheel.over * 0.25 / step2, tuning.bumpPush or 25), 0, 1e999)
			end

			local vector3 = cf:VectorToWorldSpace((Vector3.new(math.sin(wheel.steer), 0, -math.cos(wheel.steer))))
			local v18 = vector3 - vector2 * vector3:Dot(vector2)

			if not (v18.Magnitude < 0.001) then
				local unit = v18.Unit
				local unit2 = unit:Cross(vector2).Unit
				local v19 = v15 + upVector * ((pointToWorldSpace - wheel.point):Dot(upVector) * tuning.antiroll)
				local dot2 = (state.vel + state.ang:Cross(v15)):Dot(unit)
				local dot3 = (state.vel + state.ang:Cross(v15)):Dot(unit2)
				wheel.slip = math.abs(dot3)
				wheel.slipAngle = math.atan2(math.abs(dot3), (math.max(math.abs(dot2), 6)))

				local v20 = mass * gravity * step2 / #state.wheels

				local v21 = not tuning.hill and 0 or math.min(math.abs(unit.Y), tuning.hill) * gravity
				local v22

				if state.shift > 0 and state.input.driver then
					v22 = tuning.rollResist
				else
					v22 = tuning.engineBrake + tuning.rollResist
				end

				local goal = 0
				local limit = v22 * v20 + v21 * mass * step2 / #state.wheels

				if v6 or state.input.handbrake and (def2.steer == 0 or def.allBrake) then
					limit = tuning.brakeForce * 2 * v20
					goal = 0
				elseif state.braking or v9 then
					limit = tuning.brakeForce * v20
					goal = 0
				elseif state.throttle ~= 0 and def2.drive > 0 then
					if state.throttle > 0 then
						goal = tuning.topSpeed
					else
						goal = -tuning.reverseSpeed
					end

					local v23 = math.min(tuning.launch * gravity, tuning.power / math.max(math.abs(dot2), 1))
					local v24

					if total > 0 then
						v24 = wheel.support / total
					else
						v24 = 1 / count2
					end

					local v25 = v24 + (1 / count2 - v24) * tuning.difflock
					limit = (v23 * v7 + v21) * mass * step2 * math.abs(state.throttle) * v25
				end

				local v23

				if v8 > 0 then
					local vector4 = vector:Cross(v15)
					local v24 = (tuning.launch * gravity * v7 + v21) * mass * step2 / #state.wheels
					goal += (vector4:Dot(unit) - goal) * v8
					limit += (v24 - limit) * v8
					v23 = vector4:Dot(unit2) * v8
				else
					v23 = 0
				end

				local drive = addRow(state, v19, unit, goal, -limit, limit)
				local lateral = addRow(state, v19, unit2, v23, 0, 0)
				count3 += 1
				local v24 = wheelRows[count3]

				if not v24 then
					v24 = {}
					wheelRows[count3] = v24
				end

				v24.w = wheel
				v24.spring = spring
				v24.bump = bump
				v24.drive = drive
				v24.lateral = lateral
				v24.limit = limit
				v24.goal = goal
				v24.grip = 0
				v24.surface = (v[wheel.material] or 1) * tuning.friction
				wheel.spinning = false
			end
		else
			wheel.support = 0
			wheel.slip = 0
			wheel.slipAngle = 0
		end
	end

	local hullRows = state.hullRows
	local count4 = 0
	local pointToWorldSpace2 = cf:PointToWorldSpace(def.probeCenter)
	local climb = def.climb
	local v10

	if climb then
		v10 = probeKinds(def)
	end

	local v11 = 0
	local v12 = 1

	if v6 or state.braking or state.input.handbrake or state.throttle == 0 then
		if not (v6 or state.braking or state.input.handbrake) then
			v12 = 0.35
		end
	else
		if state.throttle > 0 then
			v11 = tuning.topSpeed
		else
			v11 = -tuning.reverseSpeed
		end

		v12 = math.max(math.abs(state.throttle), 0.35) * v7
	end

	local upVector2 = cf.UpVector
	local voxelWorld = nil
	local crash = nil

	for k, probe in def.probes do
		local pointToWorldSpace3 = cf:PointToWorldSpace(probe)
		local v13 = pointToWorldSpace3 - pointToWorldSpace2
		local v14

		if state.query then
			v14 = state.query.ray(pointToWorldSpace2, v13)
		else
			v14 = workspace:Raycast(pointToWorldSpace2, v13, state.params)
		end

		if not v14 then
			continue
		end

		local vector2 = v14.Normal
		local v15 = not v10 and 0 or v10[k]
		local v16

		if
			v15 > 0
			and math.abs((vector2:Dot(upVector2))) < 0.6
			and isStep(state, v14.Position, vector2, upVector2, climb)
		then
			local unit = (vector2 - upVector2 * vector2:Dot(upVector2)).Unit
			vector2 = (unit * math.max(
				1,
				-(state.vel + state.ang:Cross(v14.Position - pointToWorldSpace)):Dot(unit) / 18
			) + upVector2).Unit
			v16 = true
		else
			v16 = false
		end

		local v17 = v13.Magnitude - v14.Distance

		if v15 > 0 then
			v17 *= math.abs((v13.Unit:Dot(vector2)))
		end

		local v18 = pointToWorldSpace3 - pointToWorldSpace
		local dot = (state.vel + state.ang:Cross(v18)):Dot(vector2)
		local v19 = math.clamp((v17 - 0.03) * 0.25 / step2, 0, v15 > 0 and (tuning.lowPush or 8) or 25)

		if dot < -4 then
			v19 = math.max(v19, -dot * 0.1)
		end

		local v20 = 1e999

		local v21 = v2[v14.Material]
		local v22 = def.ram ~= nil
		local v23

		if state.query == nil then
			v23 = false
		else
			v23 = v14.voxel == true
		end

		if math.abs((vector2:Dot(upVector2))) < 0.6 then
			local now = os.clock()
			local position = v14.Position
			state.wallAt = now
			state.wallPoint = position
			state.wallNormal = vector2
			local wallHull = not v23

			if wallHull then
				if v14.Instance == nil then
					wallHull = v14.Material == Enum.Material.Metal
				else
					wallHull = false
				end
			end

			state.wallHull = wallHull

			state.wallKind = v23 and "voxel" or state.wallHull and "hull" or "terrain"
			local voxelWorld2

			if not (v23 or v14.Instance == nil) then
				voxelWorld2 = workspace:FindFirstChild("VoxelWorld")
			end

			local wallVoxel

			if v23 then
				wallVoxel = v23
			elseif voxelWorld2 == nil or v14.Instance == nil then
				wallVoxel = false
			else
				wallVoxel = v14.Instance:IsDescendantOf(voxelWorld2)
			end

			state.wallVoxel = wallVoxel
		end

		if v21 and not (v23 or voxelWorld) then
			voxelWorld = workspace:FindFirstChild("VoxelWorld")
		end

		if v21 and (v23 or voxelWorld and v14.Instance and v14.Instance:IsDescendantOf(voxelWorld)) then
			local ploughSpeed = -dot
			local crashHole, v24 = VehicleConfig.crashHole((math.max(ploughSpeed, state.ploughSpeed)))
			local v25

			if v21 == 0 then
				v25 = crashHole > 0
			else
				v25 = v24 > 0
			end

			local v26 = VehicleConfig.CRASH_DAMAGE

			if v22 then
				local v27 = VehicleConfig.PUSH[def.name]
				v25 = true

				if v21 == 0 then
					v26 = VehicleConfig.RAM_FROM
				else
					v26 = v27 and v27.brick or VehicleConfig.RAM_BRICK
				end
			end

			if v25 and (v26 < ploughSpeed or state.plough > 0) then
				if state.plough <= 0 then
					state.ploughSpeed = ploughSpeed
				end

				state.plough = 0.3
				v20 = mass * state.ploughSpeed * 0.30000000000000004 / 3
				v19 = 0
			end
		end

		local normal = addRow(state, v18, vector2, v19, 0, v20)
		local vector3 = state.vel + state.ang:Cross(v18)
		local v24 = vector3 - vector2 * vector3:Dot(vector2)
		local friction = nil
		local tread = nil
		local v25 = lookVector - vector2 * lookVector:Dot(vector2)

		if v15 == 2 and v25.Magnitude > 0.001 then
			local unit = v25.Unit
			tread = addRow(state, v18, unit, v11, 0, 0)
			friction = addRow(state, v18, unit:Cross(vector2).Unit, 0, 0, 0)
		elseif v15 ~= 1 and not v16 and v24.Magnitude > 0.001 then
			friction = addRow(state, v18, v24.Unit, 0, 0, 0)
		end

		count4 += 1
		local v26 = hullRows[count4]

		if not v26 then
			v26 = {}
			hullRows[count4] = v26
		end

		v26.normal = normal
		v26.friction = friction
		v26.tread = tread

		if -dot > VehicleConfig.CRASH_SOUND and (not crash or -dot > crash.speed) then
			crash = {
				speed = -dot,
				point = v14.Position,
				normal = vector2,
				instance = v14.Instance,
				material = v14.Material
			}
		end
	end

	state.plough = math.max(state.plough - step2, 0)

	if crash and (not state.crash or crash.speed > state.crash.speed) then
		state.crash = crash
	end

	local vel = state.vel
	local ang = state.ang

	for _ = 1, 8 do
		for i = 1, count3 do
			local wheelRow = wheelRows[i]
			solveRow(state, wheelRow.spring) -- inferred equivalent call

			if wheelRow.bump then
				solveRow(state, wheelRow.bump) -- inferred equivalent call
			end

			local v13 = wheelRow.spring.lambda + (not wheelRow.bump and 0 or wheelRow.bump.lambda)

			local v14 = math.clamp((wheelRow.w.slipAngle - 0.10471975511965978) / 0.17453292519943295, 0, 1)
			local v15 = v13 * wheelRow.surface * (1 + ((tuning.slideGrip or 0.88) - 1) * v14)
			wheelRow.grip = v15
			local drive = wheelRow.drive
			local lateral = wheelRow.lateral
			local lo = -math.min(wheelRow.limit, v15)
			local hi = math.min(wheelRow.limit, v15)
			drive.lo = lo
			drive.hi = hi
			solveRow(state, drive) -- inferred equivalent call
			lateral.lo = -v15
			lateral.hi = v15
			solveRow(state, lateral) -- inferred equivalent call
			local lambda = drive.lambda
			local lambda2 = lateral.lambda
			local v16 = math.sqrt(lambda * lambda + lambda2 * lambda2)

			if not (v15 < v16 and v16 > 0) then
				continue
			end

			local v17 = v15 / v16
			push(state, drive, lambda * v17 - lambda) -- inferred equivalent call
			push(state, lateral, lambda2 * v17 - lambda2) -- inferred equivalent call
		end

		for i = 1, count4 do
			local hullRow = hullRows[i]
			solveRow(state, hullRow.normal) -- inferred equivalent call
			local friction = hullRow.friction

			if friction then
				local hi = hullRow.normal.lambda * 0.5
				friction.lo = -hi
				friction.hi = hi
				solveRow(state, friction) -- inferred equivalent call
			end

			local tread = hullRow.tread

			if not tread then
				continue
			end

			local hi = hullRow.normal.lambda * 1 * v12
			tread.lo = -hi
			tread.hi = hi
			solveRow(state, tread) -- inferred equivalent call
		end
	end

	local lift = tuning.lift

	if lift then
		local y = state.vel.Y
		local v13 = math.max(math.max(vel.Y, 0) + lift * gravity * step2, tuning.liftFree or 0)

		if v13 < y then
			state.vel = Vector3.new(state.vel.X, v13, state.vel.Z)
		end
	end

	local tiltKick = tuning.tiltKick

	if tiltKick then
		local dot = state.ang:Dot(lookVector)
		local v13 = math.abs((ang:Dot(lookVector))) + tiltKick * step2

		if v13 < math.abs(dot) then
			state.ang -= lookVector * (dot - math.sign(dot) * v13)
		end
	end

	for i = 1, count3 do
		local wheelRow = wheelRows[i]
		local w = wheelRow.w
		w.support = wheelRow.spring.lambda + (not wheelRow.bump and 0 or wheelRow.bump.lambda)
		local drive = wheelRow.drive
		local speed = relVel(state, drive) -- inferred equivalent call
		local spinning

		if wheelRow.grip < wheelRow.limit and math.abs(drive.lambda) >= wheelRow.grip * 0.98 then
			spinning = math.abs(wheelRow.goal - speed) > 1.5
		else
			spinning = false
		end

		w.spinning = spinning

		if spinning then
			speed = wheelRow.goal == 0 and 0 or speed + math.clamp(wheelRow.goal - speed, -10, 10)
		end

		w.speed = speed
		wheelRow.w = nil
		wheelRow.spring = nil
		wheelRow.bump = nil
		wheelRow.drive = nil
		wheelRow.lateral = nil
	end

	for i = 1, count4 do
		local hullRow = hullRows[i]
		hullRow.normal = nil
		hullRow.friction = nil
		hullRow.tread = nil
	end

	for _, wheel in state.wheels do
		if not wheel.contact then
			local v13

			if state.braking or v6 then
				v13 = 0
			elseif state.throttle > 0 then
				v13 = state.throttle * tuning.topSpeed
			elseif state.throttle < 0 then
				v13 = state.throttle * tuning.reverseSpeed
			else
				v13 = wheel.speed
			end

			wheel.speed += (v13 - wheel.speed) * math.min(step2 * 3, 1)
			wheel.spinning = false
		end

		wheel.angle = (wheel.angle + wheel.speed / wheel.def.radius * step2) % 6.283185307179586
	end

	local yawHold = tuning.yawHold

	if yawHold and state.wheelbase > 0 and state.input.driver and not state.input.handbrake and v8 == 0 then
		local maxSlipAngle = 0

		for _, wheel in state.wheels do
			if wheel.contact then
				maxSlipAngle = math.max(maxSlipAngle, wheel.slipAngle)
			end
		end

		local v13 = math.clamp((maxSlipAngle - 0.10471975511965978) / 0.17453292519943295, 0, 1)

		if v13 > 0 then
			local dot = state.ang:Dot(upVector)
			local v14 = math.abs(state.speed * math.tan(math.abs(state.steer) * v5)) / state.wheelbase
			local v15 = math.abs(dot) - v14

			if v15 > 0 then
				state.ang -= upVector * (math.sign(dot) * v15 * math.min(yawHold * v13 * step2, 1))
			end
		end
	end

	local tiltDamp = tuning.tiltDamp

	if tiltDamp then
		local count5 = 0

		for _, wheel in state.wheels do
			if wheel.contact then
				count5 += 1
			end
		end

		if count5 > 0 then
			local v13 = state.ang - upVector * state.ang:Dot(upVector)
			state.ang -= v13 * math.min(tiltDamp * step2 * count5 / #state.wheels, 1)
		end
	end

	local magnitude = state.vel.Magnitude
	state.vel *= math.max(1 - tuning.airDrag * magnitude * step2, 0)
	state.ang *= math.max(1 - step2 * 0.15, 0)
	local v13 = pointToWorldSpace + state.vel * step2
	local magnitude2 = state.ang.Magnitude
	local v14 = cf.Rotation

	if magnitude2 > 1e-6 then
		v14 = (CFrame.fromAxisAngle(state.ang / magnitude2, magnitude2 * step2) * v14):Orthonormalize()
	end

	state.cf = CFrame.new(v13) * v14 * CFrame.new(-state.com)
	state.speed = state.vel:Dot(state.cf.LookVector)

	if state.input.driver or not (state.vel.Magnitude < 0.4 and magnitude2 < 0.15) then
		state.still = 0
	else
		state.still += step2

		if state.still > VehicleConfig.SLEEP_TIME then
			state.asleep = true
			state.vel = Vector3.new(0, 0, 0)
			state.ang = Vector3.new(0, 0, 0)

			for _, wheel in state.wheels do
				wheel.speed = 0
			end
		end
	end
end

function VehicleSim:step(p: number)
	if self.asleep then
		return 0
	end

	self.accum = math.min(self.accum + p, (math.max(step * VehicleConfig.MAX_STEPS, VehicleConfig.simTime(p))))
	local count2 = 0

	while step <= self.accum do
		self.accum -= step
		self.prevCf = self.cf
		stepOnce(self, step)
		count2 += 1

		if self.asleep then
			self.accum = 0
			return count2
		end
	end

	return count2
end

function VehicleSim:setRunning(running: boolean)
	if running and not self.running then
		self.startup = 1
	end

	self.running = running

	if not running then
		self.throttle = 0
		self.dir = 0
	end
end

function VehicleSim.supported(data): boolean
	local cf = data.cf
	local upVector = cf.UpVector
	local count2 = 0

	for _, wheel in data.wheels do
		local def = wheel.def
		local v4 = cf:PointToWorldSpace(def.mount) + upVector * 1.1
		local v5 = -upVector * (def.travel + 1.1)
		local v6

		if data.query then
			v6 = data.query.sphere(v4, def.radius, v5)
		else
			v6 = workspace:Spherecast(v4, def.radius, v5, data.params)
		end

		if not (v6 and math.abs(math.min(def.travel + 1.1 - v6.Distance, def.travel) - wheel.comp) < 0.25) then
			continue
		end

		count2 += 1
	end

	return count2 >= 3
end

return VehicleSim