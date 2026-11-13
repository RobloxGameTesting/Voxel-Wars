local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Game = ReplicatedStorage:WaitForChild("Game")
local Detail = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("Detail"))
local TurretHead = require(Game:WaitForChild("TurretHead"))
local Turret = require(Game:WaitForChild("Turret"))
local LocalPlayer = Players.LocalPlayer

local v = { Reds = Color3.fromRGB(186, 64, 50), Blues = Color3.fromRGB(58, 104, 170) }

local turretHeads = Instance.new("Folder")
turretHeads.Name = "TurretHeads"
turretHeads.Parent = workspace

local v2 = {}

local renderSteppedConnection = nil
local step

local function wrap(p: number) -- 3 equivalent calls inferred from this helper
	return (p + 3.141592653589793) % 6.283185307179586 - 3.141592653589793
end

local v3 = {
	SweepDir = true,
	SweepFrom = true,
	SweepAt = true,
	Facing = true,
	Yaw = true,
	Pitch = true,
	IdlePitch = true
}

local function add(configuration)
	if v2[configuration] then
		return
	end

	local pivot = configuration:GetAttribute("Pivot")
	local team = configuration:GetAttribute("Team")
	assert(typeof(pivot) == "Vector3", "[TurretView] turret " .. configuration.Name .. " has no Pivot")
	local v4 = v[team]
	assert(v4, "[TurretView] turret " .. configuration.Name .. " has no team colour for " .. tostring(team))
	local head = TurretHead.build(configuration.Name, v4, false, configuration:GetAttribute("Kind") == "flak")
	local flashL = head.flashL
	local flashR = head.flashR
	assert(flashL and flashR, "[TurretView] head built without muzzle flashes")
	head.model.Parent = turretHeads
	local lamp = head.lamp
	local yaw = configuration:GetAttribute("Yaw")
	local pitch = configuration:GetAttribute("Pitch")
	local shots = configuration:GetAttribute("Shots")
	local attributesByAttributeName = {}

	for attributeName in v3 do
		attributesByAttributeName[attributeName] = configuration:GetAttribute(attributeName)
	end

	local v5 = {
		config = configuration,
		head = head,
		flashL = flashL,
		flashR = flashR,
		lightL = flashL:FindFirstChildOfClass("PointLight"),
		lightR = flashR:FindFirstChildOfClass("PointLight"),
		attrs = attributesByAttributeName,
		pivot = pivot,
		yaw = type(yaw) ~= "number" and 0 or yaw,
		pitch = type(pitch) ~= "number" and 0 or pitch,
		shots = type(shots) ~= "number" and 0 or shots,
		kickL = 0,
		kickR = 0,
		flashAt = -1,
		flashSide = 1,
		posed = false,
		onL = nil,
		onR = nil,
		conns = {}
	}

	table.insert(v5.conns, configuration:GetAttributeChangedSignal("Shots"):Connect(function()
		local shots2 = configuration:GetAttribute("Shots")

		if type(shots2) ~= "number" or shots2 <= v5.shots then
			return
		end

		v5.shots = shots2

		local flashSide = shots2 % 2 == 0 and 1 or -1

		if flashSide > 0 then
			v5.kickR = 0.22
		else
			v5.kickL = 0.22
		end

		local now = os.clock()
		v5.flashSide = flashSide
		v5.flashAt = now
	end))
	table.insert(v5.conns, configuration.AttributeChanged:Connect(function(attributeName: string)
		if v3[attributeName] then
			attributesByAttributeName[attributeName] = configuration:GetAttribute(attributeName)
		end
	end))
	table.insert(v5.conns, configuration:GetAttributeChangedSignal("Lock"):Connect(function()
		local color

		if configuration:GetAttribute("Lock") == true then
			color = TurretHead.LAMP_ON
		else
			color = TurretHead.LAMP_OFF
		end

		lamp.Color = color
	end))
	v2[configuration] = v5

	if not renderSteppedConnection then
		renderSteppedConnection = RunService.RenderStepped:Connect(step)
	end
end

local function drop(p)
	local v4 = v2[p]

	if not v4 then
		return
	end

	v2[p] = nil

	if next(v2) == nil and renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	for _, conn in v4.conns do
		conn:Disconnect()
	end

	v4.head.model:Destroy()
end

local v4 = {}
local v5 = {}
step = function(p: number)
	table.clear(v4)
	table.clear(v5)
	local v6 = 1 - math.exp(p * -14)
	local v7 = math.exp(p * -18)
	local now = os.clock()
	local serverTimeNow = workspace:GetServerTimeNow()

	for _, v8 in v2 do
		local yaw = nil
		local pitch = nil
		local attrs = v8.attrs
		local sweepDir = attrs.SweepDir

		if type(sweepDir) == "number" and sweepDir ~= 0 then
			local sweepFrom = attrs.SweepFrom
			local sweepAt = attrs.SweepAt
			local facing = attrs.Facing

			if type(sweepFrom) == "number" and type(sweepAt) == "number" and type(facing) == "number" then
				yaw = wrap(facing + math.rad((math.clamp( -- inferred equivalent call
					sweepFrom + sweepDir * Turret.IDLE_SPEED * (serverTimeNow - sweepAt),
					-Turret.IDLE_ARC,
					Turret.IDLE_ARC
				))))
				local v9

				if type(attrs.IdlePitch) == "number" then
					v9 = attrs.IdlePitch
				else
					v9 = Turret.IDLE_PITCH
				end

				pitch = math.rad(v9)
			end
		else
			yaw = attrs.Yaw
			pitch = attrs.Pitch
		end

		local v9 = not v8.posed

		if type(yaw) == "number" and yaw ~= v8.yaw then
			local v10 = wrap(yaw - v8.yaw) -- inferred equivalent call

			if math.abs(v10) > 0.001 then
				yaw = wrap(v8.yaw + v10 * v6) -- inferred equivalent call
			end

			v8.yaw = yaw
			v9 = true
		end

		if type(pitch) == "number" and pitch ~= v8.pitch then
			local v10 = pitch - v8.pitch

			if math.abs(v10) > 0.001 then
				pitch = v8.pitch + v10 * v6
			end

			v8.pitch = pitch
			v9 = true
		end

		if v8.kickL ~= 0 or v8.kickR ~= 0 then
			v8.kickL = not (v8.kickL > 0.002) and 0 or v8.kickL * v7
			v8.kickR = not (v8.kickR > 0.002) and 0 or v8.kickR * v7
			v9 = true
		end

		if v9 then
			if Detail.distance(v8.pivot) < 450 * Detail.reach() and Detail.onScreen(v8.pivot, 6) then
				TurretHead.pose(v8.head, v8.pivot, v8.yaw, v8.pitch, v8.kickL, v8.kickR, v4, v5)
				v8.posed = true
			else
				v8.posed = false
			end
		end

		local v10 = now - v8.flashAt < 0.05
		local onL = v10 and v8.flashSide < 0
		local onR = v10 and v8.flashSide > 0

		if onL ~= v8.onL then
			v8.onL = onL
			v8.flashL.Transparency = onL and 0.15 or 1
			v8.lightL.Enabled = onL and not Detail.low
		end

		if onR == v8.onR then
			continue
		end

		v8.onR = onR
		v8.flashR.Transparency = onR and 0.15 or 1
		v8.lightR.Enabled = onR and not Detail.low
	end

	if #v4 > 0 then
		workspace:BulkMoveTo(v4, v5, Enum.BulkMoveMode.FireCFrameChanged)
	end
end

local Turrets = Game:WaitForChild("Turrets")
Turrets.ChildAdded:Connect(function(configuration)
	if configuration:IsA("Configuration") then
		add(configuration)
	end
end)
Turrets.ChildRemoved:Connect(drop)

for _, configuration in Turrets:GetChildren() do
	if configuration:IsA("Configuration") then
		add(configuration)
	end
end