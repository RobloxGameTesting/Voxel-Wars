local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")

local Movement = require(script.Parent:WaitForChild("Movement"))
local MenuLock = require(script.Parent:WaitForChild("MenuLock"))
local VR = require(script.Parent:WaitForChild("VR"))
local Ballistics = require(script.Parent:WaitForChild("Ballistics"))
local Viewmodel = require(script.Parent:WaitForChild("Viewmodel"))
local LookSettings = require(script.Parent:WaitForChild("LookSettings"))
local TouchLayout = require(script.Parent:WaitForChild("TouchLayout"))

local v = { 1, 5.5 }

local v2 = { 0.3, 0.9 }

local v3 = { 200, 90 }

local v4 = { reach = v3[1], full = v3[2], strength = 1 }

local v5 = { 40, 15 }

local color = Color3.fromRGB(24, 25, 28)
local color2 = Color3.fromRGB(14, 14, 16)
local color3 = Color3.fromRGB(242, 238, 228)
local color4 = Color3.fromRGB(255, 198, 32)

assert(TouchLayout.ALPHA_DEFAULT == 0.5, "TouchControls: TouchLayout.ALPHA_DEFAULT must be REST_ALPHA")

local v6 = {
	FIRE = "rbxassetid://139867532693652",
	SWING = "rbxassetid://119235994647072",
	DIG = "rbxassetid://119235994647072",
	THROW = "rbxassetid://117179039977602",
	CALL = "rbxassetid://83865007294676",
	LAUNCH = "rbxassetid://83865007294676",
	PLACE = "rbxassetid://83865007294676",
	PUNCH = "rbxassetid://115170977075860",
	BUILD = "rbxassetid://72991254454469",
	aim = "rbxassetid://108809774751448",
	jump = "rbxassetid://103275132199833",
	reload = "rbxassetid://92952596545684",
	crouch = "rbxassetid://101690770838529",
	stand = "rbxassetid://127671998685660",
	slide = "rbxassetid://124819695078817"
}

local TouchControls = {}
TouchControls.lookSink = nil
TouchControls.noAutoFire = false
local LocalPlayer = Players.LocalPlayer
local v7 = {}

local v8 = nil
local v9 = false
local padMode2 = false
local v10 = nil
local v11 = nil
local v12 = nil
local v13 = nil
local v14 = nil
local v15 = nil
local v16 = nil
local v17 = Vector2.zero
local v18 = nil
local v19 = {}
local total = Vector2.zero
local total2 = 0
local v20 = -1e999
local random = Random.new()

local v21 = { aim = 92, fire = 140, reload = 168, slide = 186 }
local v22 = {
	jump = 1.1,
	aim = 0.95,
	fire = 1.3,
	reload = 0.72,
	slide = 0.95
}
local v23 = {
	up = true,
	down = true,
	faster = true,
	slower = true,
	rocket = true,
	view = true
}

local v24 = {
	jump = "jump",
	aim = "aim",
	fire = "fire",
	reload = "reload",
	slide = "crouch"
}
local v25 = {
	Jump = "jump",
	Aim = "aim",
	Fire = "fire",
	Reload = "reload",
	Slide = "crouch"
}
local vector2 = Vector2.new(0.5, 0.5)
local v26 = { "Fire", "Jump", "Aim", "Reload", "Slide" }
local vehicle = nil
local v27 = {}
local v28 = {}

local function pressPrimary()
	local v29 = v10

	if not v29 or v12 then
		return
	end

	v12 = v29

	local current = Viewmodel.current

	if current then
		current:breakSprint()
	end

	if v13 ~= v29 then
		task.spawn(v29.startFire)
	end
end

local function fn() end

local function releasePrimary() -- 7 equivalent calls inferred from this helper
	local v29 = v12
	v12 = nil

	if v16 then
		v16 = nil
		fn()
	end

	if v29 and v29.stopFire and v13 ~= v29 then
		task.spawn(v29.stopFire)
	end
end

local function releaseVeh(k: string)
	local v29 = v27[k]

	if not v29 then
		return
	end

	v27[k] = nil
	v28[v29] = nil
	local v30 = vehicle

	if v30 then
		for _, v31 in v30 do
			if v31.name == k and v31.hold then
				v31.hold(false)
			end
		end
	end
end

local function releaseAllVeh() -- 3 equivalent calls inferred from this helper
	for k in table.clone(v27) do
		releaseVeh(k)
	end
end

local v29 = nil
local v30 = -1e999
local v31 = 0.08

local function stopAuto() -- 6 equivalent calls inferred from this helper
	local v32 = v13
	v13 = nil
	v29 = nil

	if v32 and v32.stopFire and v12 ~= v32 then
		task.spawn(v32.stopFire)
	end
end

local v32 = 0
local function updateAutoFire(data, flag: boolean, now: number)
	if data and v9 and (data.autoFire or data.hipAutoFire) then
		if flag then
			v30 = now

			if not v29 then
				v29 = now
				v31 = random:NextNumber(0.08, 0.15)
			end
		else
			v29 = nil
		end

		local v34 = v29
		local v35

		if v34 == nil then
			if v13 == nil then
				v35 = false
			else
				v35 = now - v30 < 0.12
			end
		else
			local v36 = now - v34

			if v31 <= v36 then
				v35 = true
			elseif v13 == nil then
				v35 = false
			else
				v35 = now - v30 < 0.12
			end
		end

		if v35 and v13 == data and data.hipAutoFire and not data.autoFire and v12 ~= data and now - v32 >= 0.25 then
			v32 = now

			if data.stopFire then
				task.spawn(data.stopFire)
			end

			task.spawn(data.startFire)
		end

		if v35 and not v13 then
			v32 = now
			v13 = data

			if v12 ~= data then
				local current = Viewmodel.current

				if current then
					current:breakSprint()
				end

				task.spawn(data.startFire)
			end
		elseif not v35 and v13 then
			stopAuto() -- inferred equivalent call
		end
	else
		if v13 then
			stopAuto() -- inferred equivalent call
		end

		v29 = nil
	end
end

local function releaseGamepad() -- 2 equivalent calls inferred from this helper
	local v34 = v14
	v14 = nil

	if v34 and v34.stopFire then
		task.spawn(v34.stopFire)
	end

	local v35 = v15
	v15 = nil

	if v35 and v35.setAim then
		v35.setAim(false)
	end
end

local v34 = nil
local function equipped()
	local character = LocalPlayer.Character

	if not character then
		return nil, nil
	end

	local v35 = v34
	local v36 = v35 and v35.Parent == character and v7[v35]

	if v36 then
		return v35, v36
	end

	for k, v37 in v7 do
		if k.Parent == character then
			v34 = k
			return k, v37
		end
	end

	local v37 = v8

	if v37 and v37.active() then
		return v37.tool, v37.actions
	end

	return nil, nil
end

local v35 = nil
local function alive(): boolean -- 2 equivalent calls inferred from this helper
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	return humanoid ~= nil and humanoid.Health > 0
end

local v36 = nil
local v37 = nil

local fn2

local function setMode(flag: boolean)
	if flag == v9 then
		return
	end

	v9 = flag

	local touchAim = ReplicatedStorage.Voxel.Remotes:FindFirstChild("TouchAim")
	assert(touchAim, "TouchControls: Voxel.Remotes.TouchAim is missing")
	touchAim:FireServer(flag)
	Movement.autoSprint = flag
	Viewmodel.touchMode = flag

	if not flag then
		releasePrimary() -- inferred equivalent call
		stopAuto() -- inferred equivalent call
		releaseAllVeh() -- inferred equivalent call
		v18 = nil
		Movement.touchJump = false
		table.clear(v19)
		total = Vector2.zero
	end

	for k in v7 do
		k.ManualActivationOnly = flag or MenuLock.held
	end
end

local set = {
	[Enum.UserInputType.MouseMovement] = true,
	[Enum.UserInputType.MouseButton1] = true,
	[Enum.UserInputType.MouseButton2] = true,
	[Enum.UserInputType.MouseButton3] = true,
	[Enum.UserInputType.MouseWheel] = true
}

local isTenFootInterface = GuiService:IsTenFootInterface()

local function onInputType(lastInputType)
	if isTenFootInterface then
		setMode(false)
	elseif lastInputType == Enum.UserInputType.Touch then
		if v36 and v9 ~= true then
			v9 = true

			local touchAim = ReplicatedStorage.Voxel.Remotes:FindFirstChild("TouchAim")
			assert(touchAim, "TouchControls: Voxel.Remotes.TouchAim is missing")
			touchAim:FireServer(true)
			Movement.autoSprint = true
			Viewmodel.touchMode = true

			for k in v7 do
				k.ManualActivationOnly = true
			end
		end
	elseif string.sub(lastInputType.Name, 1, 7) == "Gamepad" then
		setMode(false)
	elseif lastInputType == Enum.UserInputType.Keyboard then
		if UserInputService.KeyboardEnabled then
			setMode(false)
		end
	elseif set[lastInputType] and UserInputService.MouseEnabled then
		setMode(false)
	end

	fn2()
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
local targets = {}

local targets2 = {}
local function newTarget() -- 3 equivalent calls inferred from this helper
	local v38 = #targets + 1
	local target = targets2[v38]

	if not target then
		target = {
			model = nil,
			bottom = Vector3.new(0, 0, 0),
			top = Vector3.new(0, 0, 0),
			center = Vector3.new(0, 0, 0),
			radius = 0,
			vehicle = false,
			shoot = false,
			reach = 0
		}

		targets2[v38] = target
	end

	targets[v38] = target
	return target
end

local v38 = nil
local v39 = {}

local object = setmetatable({}, { __mode = "k" })
local v40 = { HumanoidRootPart = "root", Head = "head", UpperTorso = "torso" }
local function rigPart(model, name: string) -- 4 equivalent calls inferred from this helper
	local part = model:FindFirstChild(name)
	return if part and part:IsA("BasePart") then part else nil
end

local function rigOf(model)
	local v41 = object[model]

	if v41 or not model:IsA("Model") then
		return v41
	end

	local v42 = {
		root = rigPart(model, "HumanoidRootPart"), -- inferred equivalent call
		head = rigPart(model, "Head"), -- inferred equivalent call
		torso = rigPart(model, "UpperTorso"), -- inferred equivalent call
		botId = model:GetAttribute("BotId"),
		team = model:GetAttribute("Team"),
		alive = model:GetAttribute("Alive"),
		protected = model:GetAttribute("Protected")
	}

	object[model] = v42
	local function refind(p)
		local v43 = v40[p.Name]

		if v43 then
			v42[v43] = rigPart(model, p.Name) -- inferred equivalent call
		end
	end
	model.ChildAdded:Connect(refind)
	model.ChildRemoved:Connect(refind)
	model:GetAttributeChangedSignal("BotId"):Connect(function()
		v42.botId = model:GetAttribute("BotId")
	end)
	model:GetAttributeChangedSignal("Team"):Connect(function()
		v42.team = model:GetAttribute("Team")
	end)
	model:GetAttributeChangedSignal("Alive"):Connect(function()
		v42.alive = model:GetAttribute("Alive")
	end)
	model:GetAttributeChangedSignal("Protected"):Connect(function()
		v42.protected = model:GetAttribute("Protected")
	end)
	return v42
end

local function botRigs()
	local botRigs2 = workspace:FindFirstChild("BotRigs")

	if botRigs2 == v38 then
		return v39
	end

	v38 = botRigs2
	local children = {}
	v39 = children

	if not botRigs2 then
		return v39
	end

	for _, child in botRigs2:GetChildren() do
		table.insert(children, child)
	end

	botRigs2.ChildAdded:Connect(function(child)
		table.insert(children, child)
	end)
	botRigs2.ChildRemoved:Connect(function(child)
		local index = table.find(children, child)

		if index then
			table.remove(children, index)
		end
	end)

	return v39
end

local v41 = 540
local v42 = 0
local v43 = 0

local function autoFireReach(p: number) -- 2 equivalent calls inferred from this helper
	return p * 0.004363350820701567 + v43 * 1.5
end

local function enemyTeam(value) -- 4 equivalent calls inferred from this helper
	if type(value) ~= "string" or value == "" then
		return false
	end

	local team = LocalPlayer.Team
	return team == nil or (LocalPlayer.Neutral or team.Name ~= value)
end

local function addTarget(model, position: Vector3, vector3: Vector3, vector3_2: Vector3, head, torso)
	if (position - vector3).Magnitude > math.max(150, 180, v41, v42) + 5 then
		return
	end

	local v44

	if head then
		v44 = head.Position.Y + 0.7
	else
		v44 = position.Y + 2.4
	end

	local v45 = position.Y - 2.8

	local v46 = (position.X - vector3.X) * vector3_2.X + (position.Z - vector3.Z) * vector3_2.Z

	if v46 + (v45 - vector3.Y) * vector3_2.Y <= 0 and v46 + (v44 - vector3.Y) * vector3_2.Y <= 0 then
		return
	end

	local target = newTarget() -- inferred equivalent call
	target.model = model
	target.bottom = Vector3.new(position.X, v45, position.Z)
	target.top = Vector3.new(position.X, v44, position.Z)
	local center

	if torso then
		center = torso.Position
	else
		center = position + Vector3.new(0, 0.6, 0)
	end

	target.center = center
	target.radius = 1.1
	target.vehicle = false
	target.shoot = true
	target.reach = 0
end

local v44 = {}
local teamsById = {}
local v45 = -1e999
local function botTeam(p: number)
	local now = os.clock()

	if not (now - v45 > 1) then
		return teamsById[p]
	end

	v45 = now
	table.clear(teamsById)
	local bots = ReplicatedStorage:FindFirstChild("Bots")
	local roster = bots and bots:FindFirstChild("Roster")

	if not roster then
		return teamsById[p]
	end

	for _, child in roster:GetChildren() do
		local id = child:GetAttribute("Id")
		local team = child:GetAttribute("Team")

		if not (typeof(id) == "number" and typeof(team) == "string") then
			continue
		end

		teamsById[id] = team
	end

	return teamsById[p]
end

local v46 = { "S1", "S2", "S3", "S4", "S5", "S6", "S7", "S8" }
local function readCrew(instance)
	if instance:GetAttribute("Wrecked") == true then
		return false
	end

	local v47 = false

	for i = 1, 8 do
		local attribute = instance:GetAttribute(v46[i])

		if not (typeof(attribute) == "number" and attribute ~= 0) then
			continue
		end

		if attribute == LocalPlayer.UserId then
			return false
		end

		local v48

		if attribute > 0 then
			local playerByUserId = Players:GetPlayerByUserId(attribute)

			if playerByUserId and playerByUserId.Team and not playerByUserId.Neutral then
				v48 = playerByUserId.Team.Name
			end
		else
			v48 = botTeam(-attribute)
		end

		if enemyTeam(v48) then -- inferred equivalent call
			v47 = true
		end
	end

	return v47
end

local object2 = setmetatable({}, { __mode = "k" })
local function enemyCrew(p)
	local now = os.clock()
	local v47 = object2[p]

	if not v47 then
		v47 = { at = -1e999, enemy = false }

		object2[p] = v47
		p.AttributeChanged:Connect(function()
			v47.at = -1e999
		end)
	end

	assert(v47)

	if now - v47.at >= 0.25 then
		v47.enemy = readCrew(p)
		v47.at = now
	end

	return v47.enemy
end

local v47 = Vector3.new(0, 0, 0)
local function addVehicle(model, p, cframe: CFrame, vector3: Vector3, vector3_2: Vector3)
	local center = cframe * vector3

	if (center - v47).Magnitude > math.max(150, 180, v42) + vector3_2.Magnitude * 0.5 or not enemyCrew(p) then
		return
	end

	local radius = math.min(vector3_2.X, vector3_2.Y) * 0.5 * 0.85
	local v50 = math.max(vector3_2.Z * 0.5 - radius, 0)
	local target = newTarget() -- inferred equivalent call
	target.model = model
	target.bottom = center - cframe.LookVector * v50
	target.top = center + cframe.LookVector * v50
	target.center = center
	target.radius = radius
	target.vehicle = true
	target.shoot = false
	target.reach = math.max(vector3_2.X, vector3_2.Y) * 0.5 + 1
end

local object3 = setmetatable({}, { __mode = "k" })
local function turretOf(child)
	local v48 = object3[child]

	if v48 then
		return v48
	end

	local v49 = {
		pivot = child:GetAttribute("Pivot"),
		health = child:GetAttribute("Health"),
		team = child:GetAttribute("Team")
	}
	object3[child] = v49
	child.AttributeChanged:Connect(function(p: string)
		if p == "Pivot" then
			v49.pivot = child:GetAttribute("Pivot")
		elseif p == "Health" then
			v49.health = child:GetAttribute("Health")
		elseif p == "Team" then
			v49.team = child:GetAttribute("Team")
		end
	end)
	return v49
end

local function addTurrets(vector3: Vector3)
	local Game = ReplicatedStorage:FindFirstChild("Game")
	local turrets = Game and Game:FindFirstChild("Turrets")
	local turretHeads = workspace:FindFirstChild("TurretHeads")

	if not (turrets and turretHeads) then
		return
	end

	local v48 = math.max(150, 180, v41, v42) + 5

	for _, child in turrets:GetChildren() do
		local v49 = turretOf(child)
		local pivot = v49.pivot
		local health = v49.health

		if
			typeof(pivot) ~= "Vector3"
			or not (typeof(health) ~= "number" or not (health <= 0))
			or v48 < (pivot - vector3).Magnitude
		then
			continue
		end

		if not enemyTeam(v49.team) then -- inferred equivalent call
			continue
		end

		local model = turretHeads:FindFirstChild(child.Name)

		if not (model and model:IsA("Model")) then
			continue
		end

		local target = newTarget() -- inferred equivalent call
		target.model = model
		target.bottom = pivot - Vector3.new(0, 3.35, 0)
		target.top = pivot - Vector3.new(0, 0.2, 0)
		target.center = pivot - Vector3.new(0, 1.8, 0)
		target.radius = 1.9
		target.vehicle = true
		target.shoot = true
		target.reach = 2.5
	end
end

local players = Players:GetPlayers()
Players.PlayerAdded:Connect(function(player)
	if not table.find(players, player) then
		table.insert(players, player)
	end
end)
Players.PlayerRemoving:Connect(function(player)
	local index = table.find(players, player)

	if index then
		table.remove(players, index)
	end
end)

local object4 = setmetatable({}, { __mode = "k" })
local function bodyOf(character)
	local v48 = object4[character]

	if v48 == nil then
		v48 = { stale = true }

		object4[character] = v48
		local function mark()
			v48.stale = true
		end
		character.ChildAdded:Connect(mark)
		character.ChildRemoved:Connect(mark)
	end

	if not v48.stale then
		return v48
	end

	v48.stale = false
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local head = character:FindFirstChild("Head")
	local upperTorso = character:FindFirstChild("UpperTorso")
	v48.humanoid = character:FindFirstChildOfClass("Humanoid")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		humanoidRootPart = nil
	end

	v48.root = humanoidRootPart

	if not (head and head:IsA("BasePart")) then
		head = nil
	end

	v48.head = head

	if not (upperTorso and upperTorso:IsA("BasePart")) then
		upperTorso = nil
	end

	v48.torso = upperTorso

	return v48
end

local function gatherTargets(origin: Vector3, vector3: Vector3)
	table.clear(targets)
	v47 = origin

	for _, v48 in v44 do
		v48(addVehicle)
	end

	addTurrets(origin)

	for _, player in players do
		if
			player == LocalPlayer
			or player.Neutral
			or player:GetAttribute("God") == true
			or player:GetAttribute("Invisible") == true
		then
			continue
		end

		local team = player.Team

		if not (team and enemyTeam(team.Name)) then -- inferred equivalent call
			continue
		end

		local character = player.Character
		local v48 = character and bodyOf(character)
		local humanoid = v48 and v48.humanoid
		local root = v48 and v48.root

		if not (character and v48 and humanoid and humanoid.Health > 0) then
			continue
		end

		if not (root and character:GetAttribute("Protected") ~= true) then
			continue
		end

		addTarget(character, root.Position, origin, vector3, v48.head, v48.torso)
	end

	local v48 = math.max(150, 180, v41, v42) + 5

	for _, v49 in botRigs() do
		local v50 = rigOf(v49)

		if not (v50 and v49.Parent == v38) then
			continue
		end

		local root = v50.root

		if not root then
			continue
		end

		local position = root.Position

		if v48 < (position - origin).Magnitude or v50.botId == nil or v50.alive ~= true or v50.protected == true then
			continue
		end

		if not enemyTeam(v50.team) then -- inferred equivalent call
			continue
		end

		addTarget(v49, position, origin, vector3, v50.head, v50.torso)
	end
end

local function rayToSegment(origin: Vector3, vector: Vector3, bottom: Vector3, top: Vector3)
	local vector3 = top - bottom
	local v48 = bottom - origin
	local dot = vector3:Dot(vector3)
	local dot2 = vector3:Dot(vector)
	local dot3 = vector3:Dot(v48)
	local dot4 = vector:Dot(v48)
	local v49 = dot - dot2 * dot2
	local v50 = bottom + vector3 * (not (v49 > 1e-6) and 0 or math.clamp((dot2 * dot4 - dot3) / v49, 0, 1))
	local v51 = math.max(0, (v50 - origin):Dot(vector))
	return (origin + vector * v51 - v50).Magnitude, v50, v51
end

local v48 = { "VoxelChips", "VoxelLoose", "VoxelTracers" }
local v49 = nil
local v50 = nil
local children = {}
local v51 = false
local function syncFilter()
	local currentCamera = workspace.CurrentCamera
	local character = LocalPlayer.Character
	local v52 = v51

	if v52 then
		if currentCamera == v49 then
			v52 = character == v50
		else
			v52 = false
		end
	end

	for k, childName in v48 do
		local child = workspace:FindFirstChild(childName)

		if child == children[k] then
			continue
		end

		children[k] = child
		v52 = false
	end

	if v52 then
		return
	end

	v51 = true
	v49 = currentCamera
	v50 = character
	local excludeInstances = { currentCamera }

	if character then
		table.insert(excludeInstances, character)
	end

	for i = 1, #v48 do
		local v54 = children[i]

		if v54 then
			table.insert(excludeInstances, v54)
		end
	end

	raycastParams.ExcludeInstances = excludeInstances
end

local function visible(origin: Vector3, vector3: Vector3, model, reach: number) -- 1 equivalent call inferred from this helper
	local raycastResult = workspace:Raycast(origin, vector3 - origin, raycastParams)
	return raycastResult == nil
		or (raycastResult.Instance:IsDescendantOf(model) or (raycastResult.Position - vector3).Magnitude <= reach)
end

local v52 = {
	model = nil,
	center = Vector3.new(0, 0, 0),
	vehicle = false,
	off = 0,
	onBody = false,
	dist = 0
}

local function scan(position: Vector3, lookVector: Vector3, p: number, p2: number, p3: number, callback)
	gatherTargets(position, lookVector)

	if #targets == 0 then
		return nil, false
	end

	syncFilter()
	local v53 = 1e999
	local v54 = false
	local result = nil

	for _, v55 in targets do
		local magnitude, v57, dist = rayToSegment(position, lookVector, v55.bottom, v55.top)

		if dist <= 0 then
			continue
		end

		local off = math.deg((math.atan2(math.max(magnitude - v55.radius, 0), dist)))
		local onBody = v55.shoot

		if onBody then
			if magnitude <= v55.radius + autoFireReach(dist) then -- inferred equivalent call
				onBody = dist <= v41
			else
				onBody = false
			end
		end

		local v61

		if dist <= p3 then
			v61 = off <= math.min(p, (math.deg((math.atan(p2 / dist)))))
		else
			v61 = false
		end

		if not (onBody or v61) then
			continue
		end

		local v62

		if v61 and callback then
			v62 = callback(v55.model, v55.center, off)

			if not v62 then
				if not onBody then
					continue
				end

				v62 = off
				v61 = false
			end
		else
			v62 = off
		end

		if not ((v61 and v62 < v53 or onBody and not v54) and visible(position, v57, v55.model, v55.reach)) then -- inferred equivalent call
			continue
		end

		v54 = onBody and true or v54

		if not (v61 and v62 < v53) then
			continue
		end

		result = v52
		local model = v55.model
		local center = v55.center
		local vehicle2 = v55.vehicle
		result.model = model
		result.center = center
		result.vehicle = vehicle2
		result.off = off
		result.onBody = onBody
		result.dist = dist
		v53 = v62
	end

	return result, v54
end

local function wrap(p: number) -- 6 equivalent calls inferred from this helper
	return (p + 3.141592653589793) % 6.283185307179586 - 3.141592653589793
end

local function bearing(vector3: Vector3) -- 6 equivalent calls inferred from this helper
	return math.atan2(-vector3.X, -vector3.Z), (math.asin((math.clamp(vector3.Y, -1, 1))))
end

local function coneAt(p: number, p2: number, dist: number) -- 4 equivalent calls inferred from this helper
	return (math.min(p, (math.deg((math.atan(p2 / math.max(dist, 1)))))))
end

local model = nil
local v53 = Vector2.zero
local v54 = 0
local total3 = Vector2.zero
local v55 = nil
local v56 = 0
local v57 = nil
local v58 = Vector3.new(0, 0, 0)
local total4 = Vector3.new(0, 0, 0)
local v59 = 0
local v60 = -1e999
local v61 = 0

local flag = false

local v62 = nil

local v63 = Vector3.new(0, 0, 0)
local v64 = 0
local v65 = 0
local v66 = 0
local v67 = 0
local function weigh(p, vector3: Vector3, p2: number)
	local v68 = v65
	local v69

	if v68 > 0 then
		local v70, v71 = bearing((vector3 - v63).Unit) -- inferred equivalent call
		local vector2_2 = Vector2.new(wrap(v70 - v66), v71 - v67) -- inferred equivalent call
		v69 = not (vector2_2.Magnitude > 0.0001) and 1 or vector2_2.Unit:Dot(total3.Unit)
	else
		v69 = 0
	end

	if p == v55 then
		if v68 > 0 and v69 >= 0.35 then
			v55 = nil
		else
			if v68 > 0 and v69 <= -0.15 then
				v56 = v64 + 1.5
			end

			return nil
		end
	end

	if p == model and v68 > 0 and v69 <= -0.15 then
		v55 = p
		v56 = v64 + 1.5
		return nil
	else
		local v70 = p2 * (1 - v69 * 0.7 * v68)

		if p == model then
			return v70 * 0.75
		end

		return v70
	end
end

local function lookStep(p: number)
	local currentCamera = workspace.CurrentCamera
	local now = os.clock()
	local v68 = v62
	local v69 = if v68 then v68.actions else v10
	local v70 = alive() -- inferred equivalent call
	v35 = v70
	local cframe = currentCamera.CFrame
	local position = cframe.Position
	local lookVector = cframe.LookVector
	local v71

	if v69 == nil then
		v71 = false
	else
		v71 = v70
			and (v9 or padMode2)
			and (v69.assist == true or v9 and (v69.autoFire == true or v69.hipAutoFire ~= nil))
	end

	local v72

	if v69 == nil or v69.assist ~= true then
		v72 = false
	else
		v72 = v70 and (v9 or padMode2) and (padMode2 or LookSettings.touchAssist)
	end

	local current = Viewmodel.current
	local v73

	if v68 then
		v73 = math.clamp(v68.aim(), 0, 1)
	else
		v73 = (not current or current.tool ~= v11) and 0 or current.aimAlpha
	end

	if flag then
		flag = false
		v59 = v73
		total3 = Vector2.zero
		model = nil
	end

	local v74 = not v9 and 1 or math.clamp((v73 - v2[1]) / (v2[2] - v2[1]), 0, 1)

	if v74 <= 0 then
		v60 = -1e999
	elseif v60 == -1e999 then
		v60 = now
	end

	local v75 = v72 and v9
	local v76 = not v75 and 5 or v74 * 3 + 9
	local v77 = math.max(v76, 4, padMode2 and 8 or 0)
	local v78 = not v75 and 4 or v74 * 2 + 5
	local v79 = math.max(v78, 3.5, padMode2 and 5 or 0)
	local v80 = not v75 and 150 or v74 * 30 + 150
	local v81

	if v75 then
		v81 = v74 * 10 + 60
	else
		v81 = padMode2 and 90 or 60
	end

	local assistRange

	if v75 and v69 then
		assistRange = v69.assistRange
	end

	if assistRange then
		v80 += (math.max(assistRange.reach, v80) - v80) * v74
		v81 += (math.max(assistRange.full, v81) - v81) * v74
	end

	v42 = not assistRange and 0 or v80
	local hipAssist

	if v75 and v69 then
		hipAssist = v69.hipAssist or v4
	end

	if hipAssist then
		local v82 = 1 - v74
		v80 = math.max(v80, v80 + (hipAssist.reach - v80) * v82)
		v81 = math.max(v81, v81 + (hipAssist.full - v81) * v82)
		v42 = math.max(v42, v80)
	end

	v41 = 540 + 160 * v73
	v43 = 1 - v73

	if v69 and v69.range then
		v41 = math.min(v41, v69.range)
	end

	if v69 and not v69.autoFire and v69.hipAutoFire and v73 < 0.3 then
		v41 = math.min(v41, v69.hipAutoFire)
	end

	local v82 = 0
	local v83 = 0
	local v84 = total
	total = Vector2.zero
	local v85

	if v84 == Vector2.zero then
		v85 = v74
	else
		local v86 = now - v20

		if v86 > 0.1 then
			total2 = 0
			v86 = p
		end

		local v87 = math.clamp(v86, 1 / 240, 0.1)
		v20 = now
		local v88 = math.max(math.min(currentCamera.ViewportSize.X, currentCamera.ViewportSize.Y), 1)
		local v89 = math.min(v88, 640)
		local v90 = v89 + (math.min(v88, 480) - v89) * (1 - v73)
		local v91 = math.tan(math.rad(currentCamera.FieldOfView) / 2) / 0.8390996311772799
		local v92 = v84.Magnitude / v90 / v87

		local v93 = math.clamp(math.ceil(v87 * 240), 1, 24)
		local v94 = 1 - math.exp(-v87 / v93 / 0.05)
		v85 = v74
		local total5 = 0

		for _ = 1, v93 do
			total2 += (v92 - total2) * v94
			total5 += math.clamp((total2 - 1.2) / 2.8, 0, 1)
		end

		local v95 = 1 + total5 / v93 * 0.6000000000000001 * (1 - v73)
		local v96 = (3.7 + -1.6 * v73) / v90 * v91 * v95 * LookSettings.look * LookSettings.aimScale(v73)
		v82 = -v84.X * v96
		v83 = -v84.Y * v96 * (0.92 + -0.12 * v73)
	end

	if padMode2 and Viewmodel.stickInput.Magnitude > 0 then
		v20 = now
	end

	total3 += (Vector2.new(v82, v83) / math.max(p, 1 / 240) - total3) * (1 - math.exp(-p / 0.08))
	local v86 = math.clamp((total3.Magnitude - 0.3) / 1.0999999999999999, 0, 1)
	local v87, v88 = bearing(lookVector) -- inferred equivalent call

	if v55 and v56 < now then
		v55 = nil
	end

	local v89, v90

	if v71 then
		v63 = position
		v64 = now
		v65 = v86
		v66 = v87
		v67 = v88
		local v91

		if v75 then
			v91 = weigh
		end

		v89, v90 = scan(position, lookVector, v77, v79, v80, v91)
	else
		v90 = false
	end

	local v91 = not v89 and 0 or math.clamp((v80 - v89.dist) / math.max(v80 - v81, 1), 0, 1)

	local v92 = not (v9 and v89) and 1
		or math.clamp((v5[1] - v89.dist) / (v5[1] - v5[2]), 0, 1) * 0.30000000000000004 + 1

	if v9 then
		local v93 = v3[1]
		local v94 = v3[2]
		local v95

		if hipAssist then
			v93 = hipAssist.reach
			v94 = hipAssist.full
			v95 = hipAssist.strength
		else
			v95 = 1
		end

		local v96 = not v89 and 0 or v95 * 1.2 * math.clamp((v93 - v89.dist) / (v93 - v94), 0, 1)

		v85 = v74 + (1 - v74) * v96
	end

	if (v82 ~= 0 or v83 ~= 0) and v72 and v9 and v89 then
		local v93 = 0.45 + 0.04999999999999999 * v73
		local v94 = 1 - (1 - (v93 + (1 - v93) * math.clamp(v89.off / coneAt(4, 3.5, v89.dist), 0, 1))) * v85 * v91 * v92 -- inferred equivalent call
		v82 *= v94
		v83 *= v94
	end

	local stickScale = 1

	if v72 and padMode2 and v89 then
		local v94 = math.clamp(math.deg((math.atan(3.2 / math.max((v89.center - position).Magnitude, 1)))), v[1], v[2])

		if v89.off < v94 then
			local v95 = 0.42 + -0.07 * v73

			if isTenFootInterface then
				v95 = 1 - (1 - v95) * 1.2
			end

			stickScale = 1 - (1 - (v95 + (1 - v95) * (v89.off / v94))) * v91
		end
	end

	Viewmodel.stickScale = stickScale

	if padMode2 and v72 and v73 > 0.05 and v59 <= 0.05 then
		v61 = 0.14
	elseif not padMode2 or not v72 or v73 <= 0.05 then
		v61 = 0
	end

	v59 = v73

	if v61 > 0 then
		local v94 = math.min(p, v61)
		v61 -= p

		if v89 and v89.off <= coneAt(8, 5, v89.dist) then -- inferred equivalent call
			local v95, v96 = bearing((v89.center - position).Unit) -- inferred equivalent call
			local v97 = (isTenFootInterface and 1.2 or 1) * 0.75 * v94 / 0.14 * v91
			v82 += wrap(v95 - v87) * v97 -- inferred equivalent call
			v83 += (v96 - v88) * v97
		end
	end

	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local v94

	if humanoid == nil then
		v94 = false
	else
		v94 = humanoid.MoveDirection.Magnitude > 0.1
	end

	local v95 = nil

	local v96 = now - v20 < 0.25 or now - v60 < 0.4

	if v75 and v89 and v89.off <= coneAt(v76, v78, v89.dist) and (v89.model == model or v96) then -- inferred equivalent call
		if v57 == v89.model then
			local v97 = (v89.center - v58) / math.max(p, 1 / 240)
			v58 = v89.center

			if v97.Magnitude > (v89.vehicle and 200 or 40) then
				total4 = Vector3.new(0, 0, 0)
			else
				total4 += (v97 - total4) * (1 - math.exp(-p / 0.15))
			end
		else
			local model2 = v89.model
			local center = v89.center
			v57 = model2
			v58 = center
			total4 = Vector3.new(0, 0, 0)
		end

		local v97 = v89.center
		local bulletSpeed = v69 and v69.bulletSpeed

		if bulletSpeed and bulletSpeed > 0 then
			local v98 = Vector3.new(total4.X, total4.Y * 0.3, total4.Z) * 0.85
			local flightTime = Ballistics.flightTime((v89.center - position).Magnitude, bulletSpeed, v69.bulletArc)
			local flightTime2 = Ballistics.flightTime(
				(v89.center + v98 * flightTime - position).Magnitude,
				bulletSpeed,
				v69.bulletArc
			)
			v95 = v89.center + v98 * flightTime2

			local magnitude = (v95 - position).Magnitude
			v97 = v95 + Vector3.new(0, 1, 0) * (math.tan((Ballistics.holdover(magnitude, bulletSpeed, v69.bulletArc))) * magnitude)
		end

		local v98, v99 = bearing((v97 - position).Unit) -- inferred equivalent call

		if model ~= v89.model then
			v54 = 0
		end

		local v100 = wrap(v98 - v87) -- inferred equivalent call
		local v101 = v99 - v88

		local v102 = math.sqrt(v100 * v100 + v101 * v101)

		if v89.off <= 0 then
			v100 = 0
			v101 = 0
		elseif v102 > 1e-6 then
			local v103 = math.min(1, math.rad(v89.off + 0.35) / v102)
			v100 *= v103
			v101 *= v103
		end

		local vector2_2 = Vector2.new(v100, v101)
		local v103

		if v86 > 0 and vector2_2.Magnitude > 0.0001 then
			v103 = vector2_2.Unit:Dot(total3.Unit) > 0.35
		else
			v103 = false
		end

		v54 = math.min(1, v54 + p / 0.3 * (v103 and 2 or 1))
		local v104 = (1 - math.exp(p * -4.5)) * v54 * v54 * (3 - v54 * 2) * v85 * v91 * v92
		local v105 = p * 0.9599310885968813 * v85 * v91 * v92
		local v106

		if v82 * v100 < 0 then
			v106 = v104 * 0.25
		else
			v106 = v104
		end

		if v83 * v101 < 0 then
			v104 *= 0.25
		end

		v82 += math.clamp(v100 * v106, -v105, v105)
		v83 += math.clamp(v101 * v104, -v105, v105)

		if model == v89.model then
			local v107 = (0.25 + 0.2 * v73) * v85 * v91 * v92
			local v108 = p * 0.4363323129985824 * v85 * v91 * v92
			v82 += math.clamp(wrap(v98 - v53.X) * v107, -v108, v108) -- inferred equivalent call
			v83 += math.clamp((v99 - v53.Y) * v107, -v108, v108)
		end

		model = v89.model
		v53 = Vector2.new(v98, v99)
	elseif v72 and not v75 and v89 and v89.off <= coneAt(padMode2 and 6 or 5, padMode2 and 5 or 4, v89.dist) then -- inferred equivalent call
		local v97, v98 = bearing((v89.center - position).Unit) -- inferred equivalent call
		local v99 = v94 or now - v20 < 0.2

		if v99 and not (padMode2 and v89.off <= 0) then
			local v100, v101 = bearing(lookVector) -- inferred equivalent call
			local v102, v103

			if padMode2 then
				local v104 = isTenFootInterface and 1.2 or 1
				v102 = v104 * 16
				v103 = v104 * 20
			else
				v103 = 8
				v102 = 4
			end

			local v104 = math.rad(v102 + (v103 - v102) * v73) * p * v85 * v91
			local v105 = padMode2 and 6 or 3
			v82 += math.clamp(wrap(v97 - v100) * v105 * p, -v104, v104) -- inferred equivalent call
			v83 += math.clamp((v98 - v101) * v105 * p, -v104, v104)
		end

		if (v99 or padMode2) and model == v89.model then
			local v100, v101

			if padMode2 then
				local v102 = isTenFootInterface and 1.2 or 1
				v100 = v102 * 0.75
				v101 = v102 * 0.85
			else
				v101 = 0.45
				v100 = 0.25
			end

			local v102 = math.min(v100 + (v101 - v100) * v73, 1) * v85 * v91
			local v103 = p * 0.4363323129985824 * v85 * v91
			v82 += math.clamp(wrap(v97 - v53.X) * v102, -v103, v103) -- inferred equivalent call
			v83 += math.clamp((v98 - v53.Y) * v102, -v103, v103)
		end

		model = v89.model
		v53 = Vector2.new(v97, v98)
	else
		model = nil
	end

	if v82 ~= 0 or v83 ~= 0 then
		local v97 = math.asin((math.clamp(lookVector.Y, -1, 1)))
		local v98 = math.clamp(v97 + v83, -1.3962634015954636, 1.3962634015954636) - v97
		currentCamera.CFrame = CFrame.new(position) * CFrame.Angles(0, v82, 0) * cframe.Rotation * CFrame.Angles(v98, 0, 0)
	end

	if v95 and not v90 then
		local vector = v95 - position
		local magnitude = vector.Magnitude
		local magnitude2 = (vector - lookVector * vector:Dot(lookVector)).Magnitude
		v90 = vector:Dot(lookVector) > 0 and magnitude <= v41 and magnitude2 <= autoFireReach(magnitude) + 1.1 or v90 -- inferred equivalent call
	end

	if not v70 or TouchControls.noAutoFire or not LookSettings.touchAutoFire then
		v69 = nil
	end

	updateAutoFire(v69, v90, now)
	local v97

	if v70 and v9 and humanoid and humanoid.RootPart then
		local assemblyLinearVelocity = humanoid.RootPart.AssemblyLinearVelocity
		v97 = math.clamp(
			Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude / Movement.SPRINT_SPEED,
			0,
			1
		) * 4
	else
		v97 = 0
	end

	local fovOffset = Movement.fovOffset
	local fovOffset2 = fovOffset + (v97 - fovOffset) * (1 - math.exp(p * -3 / 0.25))

	if math.abs(v97 - fovOffset2) < 0.01 then
		fovOffset2 = v97
	end

	Movement.fovOffset = fovOffset2
	fn2()
end

local v68 = false
fn2 = function()
	local v69 = v9 or padMode2 or v13 ~= nil or Movement.fovOffset ~= 0 or total ~= Vector2.zero

	if v69 == v68 then
		return
	end

	v68 = v69

	if not v69 then
		RunService:UnbindFromRenderStep("TouchControlsLook")

		return
	end

	flag = true
	RunService:BindToRenderStep("TouchControlsLook", Enum.RenderPriority.Camera.Value - 2, lookStep)
end

local v69 = nil
local v70 = {}

local function plate(parent, name: string, image: string, size: number)
	local textButton = Instance.new("TextButton")
	textButton.Name = name
	textButton.Text = ""
	textButton.AutoButtonColor = false
	textButton.BorderSizePixel = 0
	textButton.BackgroundColor3 = color
	textButton.BackgroundTransparency = 0.5
	textButton.AnchorPoint = Vector2.new(0.5, 0.5)
	textButton.Visible = false
	textButton.Parent = parent
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0.5, 0)
	uiCorner.Parent = textButton

	local uiStroke = Instance.new("UIStroke")
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Thickness = 1.5
	uiStroke.Color = color2
	uiStroke.Transparency = 0.45
	uiStroke.Parent = textButton
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = textButton
	local glyph = Instance.new("ImageLabel")
	glyph.Name = "Glyph"
	glyph.BackgroundTransparency = 1
	glyph.AnchorPoint = Vector2.new(0.5, 0.5)
	glyph.Position = UDim2.fromScale(0.5, 0.5)
	glyph.Size = UDim2.fromScale(0.6, 0.6)
	glyph.Image = image
	glyph.ImageColor3 = color3
	glyph.ImageTransparency = 0.08
	glyph.Parent = textButton
	local v71 = {
		button = textButton,
		stroke = uiStroke,
		glyph = glyph,
		scale = uiScale,
		flashUntil = 0,
		size = size,
		rest = 0.5,
		glyphRest = 0.08,
		painted = -1,
		shown = false,
		image = image
	}

	v70[name] = v71
	return v71
end

local function onTap(p, fn3) -- 3 equivalent calls inferred from this helper
	p.button.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Touch or input.UserInputState ~= Enum.UserInputState.Begin then
			return
		end

		p.flashUntil = os.clock() + 0.14
		fn3()
	end)
end

local function paint(state, flag2: boolean, flag3: boolean, now: number)
	local v71 = now < state.flashUntil
	local v72 = flag2 or v71
	local painted = (v72 and 1 or 0) + ((flag3 or v71) and 2 or 0)

	if painted == state.painted then
		return
	end

	state.painted = painted
	local button = state.button
	local backgroundColor = if v72 then color4 else color
	button.BackgroundColor3 = backgroundColor
	state.button.BackgroundTransparency = v72 and 0.06 or state.rest
	local glyph = state.glyph
	local imageColor = if v72 then color2 else color3
	glyph.ImageColor3 = imageColor
	state.glyph.ImageTransparency = v72 and 0 or state.glyphRest
	local parts = state.parts

	if parts then
		for _, part in parts do
			local backgroundColor2 = if v72 then color2 else color3
			part.BackgroundColor3 = backgroundColor2
			part.BackgroundTransparency = v72 and 0 or state.glyphRest
		end
	end

	state.scale.Scale = (flag3 or v71) and 0.92 or 1
end

local function dress(state) -- 3 equivalent calls inferred from this helper
	local id = state.id

	if not id then
		return
	end

	local a = TouchLayout.item(id).a
	local v71 = math.max(a - 0.5, 0) * 1.2
	state.rest = a
	state.glyphRest = math.clamp(v71 + 0.08, 0.08, 0.6)
	state.stroke.Transparency = math.clamp(v71 + 0.45, 0.45, 0.9)
	state.painted = -1
end

local function setShown(state, flag2: boolean) -- 8 equivalent calls inferred from this helper
	if state.shown ~= flag2 then
		state.shown = flag2
		state.button.Visible = flag2
	end
end

local function setGlyph(state, image: string) -- 4 equivalent calls inferred from this helper
	if state.image ~= image then
		state.image = image
		state.glyph.Image = image
	end
end

local function drawGlyph(result, glyph: string)
	local glyph2 = result.glyph
	setGlyph(result, "") -- inferred equivalent call
	local parts = {}
	local function stroke(p: number, p2: number, p3: number, p4: number, rotation: number)
		local frame = Instance.new("Frame")
		frame.BorderSizePixel = 0
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.fromScale(p, p2)
		frame.Size = UDim2.fromScale(p3, p4)
		frame.Rotation = rotation
		frame.Parent = glyph2
		table.insert(parts, frame)
		return frame
	end

	if glyph == "up" or glyph == "down" then
		local v72 = glyph == "up" and 1 or -1

		for _, v73 in { 0.34, 0.66 } do
			stroke(0.36, v73, 0.38, 0.12, v72 * -45)
			stroke(0.64, v73, 0.38, 0.12, v72 * 45)
		end
	elseif glyph == "faster" or glyph == "slower" then
		local v72 = glyph == "faster" and 1 or -1

		for _, v73 in { 0.34, 0.66 } do
			stroke(v73, 0.36, 0.38, 0.12, v72 * 45)
			stroke(v73, 0.64, 0.38, 0.12, v72 * -45)
		end
	elseif glyph == "rocket" then
		local parent = stroke(0.5, 0.55, 0.2, 0.46, 0)
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0.2, 0)
		uiCorner.Parent = parent
		stroke(0.5, 0.33, 0.15, 0.15, 45)
		stroke(0.37, 0.76, 0.09, 0.24, 28)
		stroke(0.63, 0.76, 0.09, 0.24, -28)
	elseif glyph == "view" then
		stroke(0.33, 0.41, 0.4, 0.09, -24)
		stroke(0.67, 0.41, 0.4, 0.09, 24)
		stroke(0.33, 0.59, 0.4, 0.09, 24)
		stroke(0.67, 0.59, 0.4, 0.09, -24)
		local parent = stroke(0.5, 0.5, 0.2, 0.2, 0)
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0.5, 0)
		uiCorner.Parent = parent
	end

	result.parts = parts
end

local v71 = nil
local function hideRobloxJump()
	local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
	local touchGui = playerGui and playerGui:FindFirstChild("TouchGui")
	local touchControlFrame = touchGui and touchGui:FindFirstChild("TouchControlFrame")
	local jumpButton = touchControlFrame and touchControlFrame:FindFirstChild("JumpButton")

	if not jumpButton or not jumpButton:IsA("GuiObject") or jumpButton == v71 then
		return
	end

	v71 = jumpButton
	jumpButton.Visible = false
	jumpButton:GetPropertyChangedSignal("Visible"):Connect(function()
		if jumpButton.Visible then
			jumpButton.Visible = false
		end
	end)
end

local v72 = nil
local v73 = Vector2.zero
local v74 = 0
local v75 = nil
local v76 = nil
local v77 = Vector2.zero

local function baseFor(vector2_2: Vector2) -- 2 equivalent calls inferred from this helper
	return (math.clamp(math.min(vector2_2.X, vector2_2.Y) * 0.17, 56, 80))
end

local function arrange(vector2_2: Vector2, flag2: boolean)
	local v78 = math.min(vector2_2.X, vector2_2.Y)
	local v79 = baseFor(vector2_2) -- inferred equivalent call
	local v80 = v79 * 0.14

	local v81 = TouchLayout.discPx(v79 * v70.Jump.size, TouchLayout.item("jump").s) / 2
	local vector2_3

	if v78 <= 500 then
		vector2_3 = Vector2.new(vector2_2.X - 60, vector2_2.Y - 55)
	else
		vector2_3 = Vector2.new(vector2_2.X - 110, vector2_2.Y - 150)
	end

	local vector2_4 = Vector2.new(math.min(vector2_3.X + v79 * 0.3, vector2_2.X - v81 - 4), vector2_3.Y)
	local v82 = {}

	local function seat(p, p2: number?, p3: string, flag3: boolean)
		local item = TouchLayout.item(p3)
		local discPx = TouchLayout.discPx(v79 * p.size, item.s)
		local halfDiscPx = discPx / 2
		local v84 = vector2_4

		if p2 then
			local v85 = (math.rad)(p2)
			local vector2_5 = Vector2.new(math.cos(v85), -math.sin(v85))
			local v86 = v82[1].r + v80 + halfDiscPx

			for _ = 1, 300 do
				v84 = vector2_4 + vector2_5 * v86
				local flag4 = true

				for _, v88 in v82 do
					if (v84 - v88.c).Magnitude < halfDiscPx + v88.r + v80 then
						flag4 = false
						break
					end
				end

				if flag4 then
					break
				end

				v86 += 2
			end
		end

		local vector2_5 = Vector2.new(
			math.clamp(v84.X, halfDiscPx, vector2_2.X - halfDiscPx),
			(math.clamp(v84.Y, halfDiscPx, vector2_2.Y - halfDiscPx))
		)
		table.insert(v82, { c = vector2_5, r = halfDiscPx })
		local v85

		if flag3 then
			v85 = TouchLayout.spot(item, vector2, Vector2.new(discPx, discPx), vector2_2)
		end

		local v86 = v85 or vector2_5

		if flag2 then
			p.button.Size = UDim2.fromOffset(discPx, discPx)
			p.button.Position = UDim2.fromOffset(v86.X, v86.Y)
		end

		return vector2_5
	end

	local v83 = {}
	v83.jump = seat(v70.Jump, nil, "jump", true)
	v83.aim = seat(v70.Aim, 92, "aim", true)
	v83.fire = seat(v70.Fire, 140, "fire", true)

	if flag2 then
		local button = v70.Fire.button
		v73 = Vector2.new(button.Position.X.Offset, button.Position.Y.Offset)
		v74 = button.Size.X.Offset / 2

		if v75 then
			v75:Cancel()
			v75 = nil
		end
	end

	v83.crouch = seat(v70.Slide, 186, "crouch", true)
	v83.reload = seat(v70.Reload, 168, "reload", true)
	local v84 = vehicle

	if not (v84 and flag2) then
		return v83
	end

	table.clear(v82)
	local v85 = nil
	local set2 = {}

	for _, v86 in v84 do
		if v86.slot == "jump" then
			v85 = v86
		end
	end

	if v85 then
		seat(v70["V_" .. v85.name], nil, "jump", true)
	else
		table.insert(v82, {
			c = vector2_4,
			r = v79 * 1.1 / 2
		})
	end

	for _, v86 in { "aim", "fire", "slide", "reload" } do
		for _, v87 in v84 do
			if v87.slot ~= v86 then
				continue
			end

			seat(v70["V_" .. v87.name], v21[v86], v24[v86], not set2[v86])
			set2[v86] = true
		end
	end

	return v83
end

local function layout()
	local v78 = v69

	if not v78 then
		return
	end

	local absoluteSize = v78.AbsoluteSize

	if absoluteSize.X < 1 or absoluteSize.Y < 1 then
		return
	end

	v72 = absoluteSize
	arrange(absoluteSize, true)
end

local function vehPlate(item)
	local parent = v69

	if not parent then
		return nil
	end

	local name = "V_" .. item.name
	local result = v70[name]

	if not result then
		result = plate(parent, name, "", item.size or v22[item.slot])
		result.button.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.Touch or input.UserInputState ~= Enum.UserInputState.Begin then
				return
			end

			local v80 = vehicle

			if not v80 or v27[item.name] then
				return
			end

			for _, v81 in v80 do
				if v81.name ~= item.name then
					continue
				end

				if v81.hold then
					v27[v81.name] = input

					if v81.look then
						v28[input] = Vector2.new(input.Position.X, input.Position.Y)
					end

					v81.hold(true)
				elseif v81.tap then
					result.flashUntil = os.clock() + 0.14
					v81.tap()
				end
			end
		end)
	end

	assert(result)
	result.size = item.size or v22[item.slot]
	result.id = v24[item.slot]
	dress(result) -- inferred equivalent call

	for _, v80 in result.parts or {} do
		v80:Destroy()
	end

	result.parts = nil

	if v23[item.glyph] then
		drawGlyph(result, item.glyph)
	else
		setGlyph(result, v6[item.glyph]) -- inferred equivalent call
	end

	result.painted = -1
	return result
end

local function moveFire(vector2_2: Vector2) -- 2 equivalent calls inferred from this helper
	if not v69 then
		return
	end

	local v78 = vector2_2 - v77 - v73
	local v79 = v74 * 1.15

	if v79 < v78.Magnitude then
		v78 = v78.Unit * v79
	end

	if v75 then
		v75:Cancel()
		v75 = nil
	end

	local v80 = v73 + v78
	v70.Fire.button.Position = UDim2.fromOffset(v80.X, v80.Y)
end

local function inFireZone(vector2_2: Vector2): boolean -- 1 equivalent call inferred from this helper
	local v78 = v69
	local fire = v70.Fire

	if v78 and fire and fire.shown and not v16 and not vehicle and v10 then
		return (vector2_2 - v77 - v73).Magnitude <= v74 * 1.15
	end

	return false
end

local function grabFire(input)
	if v16 then
		return
	end

	local vector2_2 = Vector2.new(input.Position.X, input.Position.Y)
	v16 = input
	v17 = vector2_2
	moveFire(vector2_2) -- inferred equivalent call
	local v78 = v10

	if v78 then
		if v12 then
			return
		end

		v12 = v78

		local current = Viewmodel.current

		if current then
			current:breakSprint()
		end

		if v13 ~= v78 then
			task.spawn(v78.startFire)
		end
	end
end

fn = function()
	v76 = nil
	local fire = v70.Fire

	if not fire then
		return
	end

	if v75 then
		v75:Cancel()
	end

	v75 = TweenService:Create(fire.button, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.fromOffset(v73.X, v73.Y)
	})

	v75:Play()
end

local function build()
	local playerGui = LocalPlayer:WaitForChild("PlayerGui")

	local touchLook = Instance.new("ScreenGui")
	touchLook.Name = "TouchLook"
	touchLook.ResetOnSpawn = false
	touchLook.IgnoreGuiInset = true
	touchLook.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	touchLook.DisplayOrder = -10
	touchLook.Enabled = false
	local pad = Instance.new("TextButton")
	pad.Name = "Pad"
	pad.Text = ""
	pad.AutoButtonColor = false
	pad.BackgroundTransparency = 1
	pad.BorderSizePixel = 0
	pad.Position = UDim2.fromScale(0.42, 0)
	pad.Size = UDim2.fromScale(0.5800000000000001, 1)
	pad.Parent = touchLook
	local padTop = pad:Clone()
	padTop.Name = "PadTop"
	padTop.Position = UDim2.fromScale(0, 0)
	padTop.Size = UDim2.fromScale(0.42, 0.33)
	padTop.Parent = touchLook

	for _, v78 in { pad, padTop } do
		v78.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.Touch
				and input.UserInputState == Enum.UserInputState.Begin
			then
				local vector2_2 = Vector2.new(input.Position.X, input.Position.Y)

				if v9 and inFireZone(vector2_2) then -- inferred equivalent call
					grabFire(input)
					return
				end

				v19[input] = vector2_2
			end
		end)
	end

	touchLook.Parent = playerGui
	v37 = touchLook

	local touchControls = Instance.new("ScreenGui")
	touchControls.Name = "TouchControls"
	touchControls.ResetOnSpawn = false
	touchControls.IgnoreGuiInset = true
	touchControls.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	touchControls.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	touchControls.DisplayOrder = 6
	touchControls.Enabled = false
	local root = Instance.new("Frame")
	root.Name = "Root"
	root.BackgroundTransparency = 1
	root.Size = UDim2.fromScale(1, 1)
	root.Parent = touchControls
	v69 = root
	v77 = root.AbsolutePosition
	root:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		v77 = root.AbsolutePosition
	end)

	local v78 = plate(root, "Fire", "rbxassetid://139867532693652", 1.3)
	local v79 = plate(root, "Jump", "rbxassetid://103275132199833", 1.1)
	plate(root, "Aim", "rbxassetid://108809774751448", 0.95)
	plate(root, "Reload", "rbxassetid://92952596545684", 0.72)
	plate(root, "Slide", "rbxassetid://101690770838529", 0.95)

	v79.button.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Touch or input.UserInputState ~= Enum.UserInputState.Begin then
			return
		end

		v18 = input
		Movement.touchJump = true
	end)
	v78.button.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Touch or input.UserInputState ~= Enum.UserInputState.Begin then
			return
		end

		grabFire(input)
	end)
	local aim = v70.Aim
	local function fn3()
		local v80 = v10

		if v80 and v80.setAim and v80.isAiming then
			v80.setAim(not v80.isAiming())
		end
	end

	onTap(aim, fn3) -- inferred equivalent call
	local reload = v70.Reload
	local function fn4()
		local v80 = v10

		if v80 and v80.reload then
			task.spawn(v80.reload)
		end
	end

	onTap(reload, fn4) -- inferred equivalent call

	local function fn5()
		Movement.slide()
	end

	onTap(v70.Slide, fn5) -- inferred equivalent call

	for k, id in v25 do
		local v81 = v70[k]
		v81.id = id
		dress(v81) -- inferred equivalent call
		TouchLayout.register(id, {
			kind = "disc",
			space = "controls",
			anchor = vector2,
			size = function(vector2_2: Vector2)
				local v82 = baseFor(vector2_2) * v81.size -- inferred equivalent call
				return Vector2.new(v82, v82)
			end,
			home = function(vector2_2: Vector2)
				return arrange(vector2_2, false)[id]
			end,
			glyph = id == "fire" and "rbxassetid://139867532693652" or v6[id]
		})
	end

	TouchLayout.onChange(function()
		for _, v80 in v70 do
			dress(v80) -- inferred equivalent call
		end

		local v80 = v69

		if not v80 then
			return
		end

		local absoluteSize = v80.AbsoluteSize

		if not (absoluteSize.X < 1) then
			if absoluteSize.Y < 1 then
				return
			end

			v72 = absoluteSize
			arrange(absoluteSize, true)
		end
	end)

	root:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
	touchControls.Parent = playerGui
	v36 = touchControls
	local v80 = v69

	if not v80 then
		return
	end

	local absoluteSize = v80.AbsoluteSize

	if not (absoluteSize.X < 1) then
		if absoluteSize.Y < 1 then
			return
		end

		v72 = absoluteSize
		arrange(absoluteSize, true)
	end
end

UserInputService.TouchMoved:Connect(function(p)
	local position = p.Position
	local vector2_2 = Vector2.new(position.X, position.Y)
	local lookSink = TouchControls.lookSink

	if p == v16 then
		if lookSink then
			lookSink(vector2_2 - v17)
		else
			total += vector2_2 - v17
		end

		v17 = vector2_2
		v76 = vector2_2
	end

	local v78 = v28[p]

	if v78 then
		if lookSink then
			lookSink(vector2_2 - v78)
		else
			total += vector2_2 - v78
		end

		v28[p] = vector2_2
	end

	local v79 = v19[p]

	if v79 then
		if lookSink then
			lookSink(vector2_2 - v79)
		else
			total += vector2_2 - v79
		end

		v19[p] = vector2_2
	end
end)
UserInputService.TouchEnded:Connect(function(otherPart)
	if otherPart == v16 then
		releasePrimary() -- inferred equivalent call
	end

	if otherPart == v18 then
		v18 = nil
		Movement.touchJump = false
	end

	for k, v78 in v27 do
		if v78 == otherPart then
			releaseVeh(k)
		end
	end

	v19[otherPart] = nil
end)

local v78 = 0

local object5 = setmetatable({}, { __mode = "k" })
RunService.RenderStepped:Connect(function()
	local v79, v80 = equipped()

	if v79 ~= v11 then
		releasePrimary() -- inferred equivalent call
		stopAuto() -- inferred equivalent call
		releaseGamepad() -- inferred equivalent call
		v11 = v79
		v10 = v80
	end

	local v81 = v36

	if not v81 then
		return
	end

	local v82 = v76

	if v82 then
		v76 = nil

		if v16 then
			moveFire(v82) -- inferred equivalent call
		end
	end

	local enabled = v9 and not TouchLayout.editing

	if enabled then
		if v35 == nil then
			enabled = alive() -- inferred equivalent call
		else
			enabled = v35
		end
	end

	v35 = nil
	local enabled2

	if enabled then
		enabled2 = LocalPlayer.Team ~= nil or LocalPlayer:GetAttribute("PickingTeam") ~= true
	else
		enabled2 = enabled
	end

	if v81.Enabled ~= enabled or v37 ~= nil and v37.Enabled ~= enabled2 then
		v81.Enabled = enabled

		if v37 then
			v37.Enabled = enabled2
		end

		table.clear(v19)
	end

	if enabled then
		local v85 = v16

		if
			v85
			and (v85.UserInputState == Enum.UserInputState.End or v85.UserInputState == Enum.UserInputState.Cancel)
		then
			releasePrimary() -- inferred equivalent call
		end

		local v86 = v18

		if
			v86
			and (v86.UserInputState == Enum.UserInputState.End or v86.UserInputState == Enum.UserInputState.Cancel)
		then
			v18 = nil
			Movement.touchJump = false
		end

		for k in v19 do
			if k.UserInputState == Enum.UserInputState.End or k.UserInputState == Enum.UserInputState.Cancel then
				v19[k] = nil
			end
		end

		local now = os.clock()

		if v78 <= now then
			v78 = now + 0.5
			hideRobloxJump()
			local v87 = v69.AbsoluteSize ~= v72 and v69

			if v87 then
				local absoluteSize = v87.AbsoluteSize

				if not (absoluteSize.X < 1 or absoluteSize.Y < 1) then
					v72 = absoluteSize
					arrange(absoluteSize, true)
				end
			end
		end

		local v87 = vehicle

		if v87 then
			for _, v88 in v26 do
				setShown(v70[v88], false) -- inferred equivalent call
			end

			if v12 then
				releasePrimary() -- inferred equivalent call
			end

			v18 = nil
			Movement.touchJump = false

			for k, v88 in v27 do
				if
					v88.UserInputState == Enum.UserInputState.End
					or v88.UserInputState == Enum.UserInputState.Cancel
				then
					releaseVeh(k)
				end
			end

			for _, v88 in v87 do
				local v89 = object5[v88]

				if not v89 then
					v89 = "V_" .. v88.name
					object5[v88] = v89
				end

				local v90 = v70[v89]

				if not v90 then
					continue
				end

				setShown(v90, true) -- inferred equivalent call
				local v91 = v27[v88.name] ~= nil
				local v92

				if v91 then
					v92 = v91
				elseif v88.lit == nil then
					v92 = false
				else
					v92 = v88.lit()
				end

				paint(v90, v92, v91, now)
			end
		else
			local fire = v70.Fire
			setShown(fire, v80 ~= nil) -- inferred equivalent call

			if v80 then
				setGlyph(fire, v6[v80.label]) -- inferred equivalent call
			end

			paint(fire, v12 ~= nil or v13 ~= nil, v16 ~= nil, now)

			local character = LocalPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local v88 = not (humanoid == nil) and humanoid.Sit

			if v88 and v18 then
				v18 = nil
				Movement.touchJump = false
			end

			local jump = v70.Jump
			setShown(jump, not v88) -- inferred equivalent call
			paint(jump, v18 ~= nil, v18 ~= nil, now)
			local aim = v70.Aim
			local isAiming = v80 and v80.isAiming
			setShown(aim, isAiming ~= nil) -- inferred equivalent call

			if isAiming then
				paint(aim, isAiming(), false, now)
			end

			local reload = v70.Reload
			setShown(reload, v80 ~= nil and v80.reload ~= nil) -- inferred equivalent call
			paint(reload, false, false, now)

			local slide = v70.Slide
			local state = Movement.state
			setShown(slide, not v88) -- inferred equivalent call
			setGlyph( -- inferred equivalent call
				slide,
				(state.sliding or state.sprinting) and "rbxassetid://124819695078817" or state.crouching and "rbxassetid://127671998685660" or "rbxassetid://101690770838529"
			)
			paint(slide, state.sliding, false, now)
		end
	else
		if v12 then
			releasePrimary() -- inferred equivalent call
		end

		releaseAllVeh() -- inferred equivalent call
		v18 = nil
		Movement.touchJump = false
	end
end)

MenuLock.onChange(function(flag2: boolean)
	if flag2 then
		releaseGamepad() -- inferred equivalent call
	end

	for k in v7 do
		k.ManualActivationOnly = v9 or flag2
	end
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	local v79 = v10

	if gameProcessed or MenuLock.held or not v79 or v8 ~= nil and v79 == v8.actions then
		return
	end

	local keyCode = input.KeyCode

	if keyCode == Enum.KeyCode.ButtonR2 then
		if not v14 then
			v14 = v79
			task.spawn(v79.startFire)
		end
	elseif keyCode == Enum.KeyCode.ButtonL2 and not VR.on() then
		if v79.setAim then
			v15 = v79
			v79.setAim(true)
		end
	elseif keyCode == Enum.KeyCode.ButtonX and v79.reload then
		task.spawn(v79.reload)
	end
end)

local inputChangedConnection = nil
local function syncStick() -- 1 equivalent call inferred from this helper
	local gamepadEnabled = UserInputService.GamepadEnabled

	if gamepadEnabled and not inputChangedConnection then
		inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
			if input.KeyCode == Enum.KeyCode.Thumbstick2 and input.Position.Magnitude > 0.2 then
				v20 = os.clock()
			end
		end)
	elseif not gamepadEnabled and inputChangedConnection then
		inputChangedConnection:Disconnect()
		inputChangedConnection = nil
	end
end
syncStick()

UserInputService.GamepadConnected:Connect(function()
	syncStick() -- inferred equivalent call
	task.defer(syncStick)
end)
UserInputService.GamepadDisconnected:Connect(function()
	task.defer(syncStick)
end)
UserInputService:GetPropertyChangedSignal("GamepadEnabled"):Connect(syncStick)
UserInputService.InputEnded:Connect(function(input)
	local keyCode = input.KeyCode

	if keyCode == Enum.KeyCode.ButtonR2 then
		local v79 = v14
		v14 = nil

		if v79 and v79.stopFire then
			task.spawn(v79.stopFire)
		end
	elseif keyCode == Enum.KeyCode.ButtonL2 then
		local v79 = v15
		v15 = nil

		if v79 and v79.setAim then
			v79.setAim(false)
		end
	end
end)

function TouchControls:register(data)
	assert(type(data.label) == "string", "TouchControls.register: label must be a string")
	local v79 = data.label == string.upper(data.label) and v6[data.label] ~= nil
	assert(v79, "TouchControls.register: no glyph for label " .. data.label .. " (add one to GLYPHS)")
	assert(type(data.startFire) == "function", "TouchControls.register: startFire must be a function")
	assert((data.setAim == nil) == (data.isAiming == nil), "TouchControls.register: setAim and isAiming go together")
	assert(
		not (data.autoFire or data.hipAutoFire) or data.stopFire ~= nil,
		"TouchControls.register: autoFire needs stopFire"
	)
	local v80

	if data.hipAutoFire == nil then
		v80 = true
	elseif type(data.hipAutoFire) == "number" then
		v80 = data.hipAutoFire > 0
	else
		v80 = false
	end

	assert(v80, "TouchControls.register: hipAutoFire must be studs > 0")
	v7[self] = data
	self.ManualActivationOnly = v9 or MenuLock.held
	self.Destroying:Connect(function()
		v7[self] = nil
	end)
end

function TouchControls.registerHands(tool, actions, active)
	assert(v6[actions.label] ~= nil, "TouchControls.registerHands: no glyph for label " .. tostring(actions.label))
	assert(type(actions.startFire) == "function", "TouchControls.registerHands: startFire must be a function")
	v8 = { tool = tool, actions = actions, active = active }
end

function TouchControls.setVehicle(items)
	if items == vehicle then
		return
	end

	releaseAllVeh() -- inferred equivalent call
	vehicle = nil

	for k, v79 in v70 do
		if string.sub(k, 1, 2) == "V_" then
			setShown(v79, false) -- inferred equivalent call
		end
	end

	if items then
		for _, item in items do
			assert(v22[item.slot] ~= nil, "TouchControls.setVehicle: unknown slot " .. tostring(item.slot))
			assert(
				v23[item.glyph] or v6[item.glyph] ~= nil,
				"TouchControls.setVehicle: no glyph " .. tostring(item.glyph)
			)
			assert(item.hold or item.tap, "TouchControls.setVehicle: " .. item.name .. " needs hold or tap")
		end

		releasePrimary() -- inferred equivalent call
		stopAuto() -- inferred equivalent call
		v18 = nil
		Movement.touchJump = false

		for _, item in items do
			vehPlate(item)
		end
	end

	vehicle = items
	local v79 = v69

	if not v79 then
		return
	end

	local absoluteSize = v79.AbsoluteSize

	if not (absoluteSize.X < 1) then
		if absoluteSize.Y < 1 then
			return
		end

		v72 = absoluteSize
		arrange(absoluteSize, true)
	end
end

function TouchControls.addVehicles(callback)
	table.insert(v44, callback)
end

function TouchControls.setGunAim(data)
	stopAuto() -- inferred equivalent call

	if data then
		assert(type(data.fire) == "function", "TouchControls.setGunAim: fire must be a function")
		local fire = data.fire
		v62 = {
			aim = data.aim,
			actions = {
				label = "FIRE",
				startFire = function()
					fire(true)
				end,
				stopFire = function()
					fire(false)
				end,
				autoFire = true,
				assist = true,
				range = data.range
			}
		}
	else
		v62 = nil
	end

	local v79 = v37

	if v79 then
		local pad = v79:FindFirstChild("Pad")
		local padTop = v79:FindFirstChild("PadTop")
		pad.Position = UDim2.fromScale(data and 0 or 0.42, 0)
		pad.Size = UDim2.fromScale(data and 1 or 0.5800000000000001, 1)
		padTop.Visible = data == nil
	end

	GuiService.TouchControlsEnabled = data == nil
	fn2()
end

function TouchControls.setLookSink(lookSink)
	TouchControls.lookSink = lookSink
	total = Vector2.zero
	local v79 = lookSink ~= nil or v62 ~= nil
	local v80 = v37

	if v80 then
		local pad = v80:FindFirstChild("Pad")
		local padTop = v80:FindFirstChild("PadTop")
		pad.Position = UDim2.fromScale(v79 and 0 or 0.42, 0)
		pad.Size = UDim2.fromScale(v79 and 1 or 0.5800000000000001, 1)
		padTop.Visible = not v79
	end

	GuiService.TouchControlsEnabled = not v79
end

function TouchControls.getVehicle()
	return vehicle
end

function TouchControls.active()
	return v9
end

function TouchControls.aimPoint()
	if v9 then
		return workspace.CurrentCamera.ViewportSize * 0.5
	end

	return UserInputService:GetMouseLocation()
end

function TouchControls.reloadNow()
	local v79 = v10

	if v79 and v79.reload and not MenuLock.held and (v8 == nil or v79 ~= v8.actions) then
		task.spawn(v79.reload)
	end
end

if UserInputService.TouchEnabled then
	build()
end

UserInputService.LastInputTypeChanged:Connect(onInputType)

local function readPadMode() -- 1 equivalent call inferred from this helper
	local padMode = LocalPlayer:GetAttribute("PadMode")
	local v79

	if padMode == true then
		v79 = not VR.on()
	else
		v79 = isTenFootInterface

		if v79 then
			if padMode == nil then
				v79 = not VR.on()
			else
				v79 = false
			end
		end
	end

	padMode2 = v79
	Viewmodel.padMode = padMode2
	fn2()
end
LocalPlayer:GetAttributeChangedSignal("PadMode"):Connect(readPadMode)
readPadMode()
VR.watch(function()
	readPadMode() -- inferred equivalent call
end)

if UserInputService.TouchEnabled and not (UserInputService.KeyboardEnabled or UserInputService.MouseEnabled) then
	setMode(true)
else
	onInputType(UserInputService:GetLastInputType())
end

fn2()

return TouchControls