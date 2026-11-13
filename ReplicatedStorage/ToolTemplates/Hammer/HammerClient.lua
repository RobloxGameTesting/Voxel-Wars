local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local parent = script.Parent
local LocalPlayer = Players.LocalPlayer
local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local Viewmodel = require(Voxel:WaitForChild("Viewmodel"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local VR = require(ReplicatedStorage2:WaitForChild("Voxel"):WaitForChild("VR"))
local Keyframes = require(Voxel:WaitForChild("Keyframes"))
local VoxelSound = require(Voxel:WaitForChild("VoxelSound"))
local TouchControls = require(Voxel:WaitForChild("TouchControls"))
local StrikePredict = require(Voxel:WaitForChild("StrikePredict"))
local hammerHit = Voxel:WaitForChild("Remotes"):WaitForChild("HammerHit")

local newVector3 = Vector3.new

local function handleAt(vector3: Vector3, vector3_2: Vector3)
	local x = math.rad(vector3_2.X)
	local y = math.rad(vector3_2.Y)
	local z = math.rad(vector3_2.Z)
	local cframe = CFrame.Angles(0, z, 0) * CFrame.Angles(0, 0, y)
	local vectorToWorldSpace = cframe:VectorToWorldSpace((newVector3(0, math.sin(x), -math.cos(x))))
	local vector = cframe:VectorToWorldSpace((newVector3(0, -math.cos(x), -math.sin(x))))
	return CFrame.fromMatrix(
		vector3 + vectorToWorldSpace * 1.15,
		vector:Cross(vectorToWorldSpace),
		vector,
		vectorToWorldSpace
	)
end

local hold = handleAt(Vector3.new(2.2, -1.8, -1.6), Vector3.new(72.5, -3, 0))

local v = Viewmodel.new(parent, {
	name = "SLEDGEHAMMER",
	hold = hold,
	rightHand = Vector3.new(0, -0.1, -1.2),
	leftHand = Vector3.new(0, -0.1, -0.45),
	armThickness = 0.6,
	muzzle = Vector3.new(0, 0, 1.55),
	aimPoint = Vector3.new(0, 0, 0),
	aimDistance = 2,
	aimFov = 80,
	aimMove = 1,
	reach = 1,
	sprintHold = handleAt(Vector3.new(2, -1.5, -1.1), Vector3.new(100, -12, 8)),
	hipKick = Vector3.new(0, 0, 0),
	hipKickRot = Vector3.new(0, 0, 0),
	aimKick = Vector3.new(0, 0, 0),
	aimKickRot = Vector3.new(0, 0, 0),
	recoilTime = 0.3,
	punch = 0
})

v.aimBlocked = true
v.leftTarget = Vector3.new(-1.2, -2.9, -1)
v.leftWeight = 1

local function strike(vector3: Vector3, vector3_2: Vector3, vector3_3: Vector3, vector3_4: Vector3, vector3_5: Vector3, vector3_6: Vector3)
	local v2 = (vector3_5 - vector3_3) / 0.035 * 1.2
	local v3 = (vector3_6 - vector3_4) / 0.035 * 1.2
	return {
		length = 0.07,
		p = {
			{ 0, vector3, true },
			{ 0.035, vector3_3 },
			{ 0.07, vector3_5, v2 }
		},
		a = {
			{ 0, vector3_2, true },
			{ 0.035, vector3_4 },
			{ 0.07, vector3_6, v3 }
		}
	}, v2, v3
end

local function wall(vector3: Vector3, vector3_2: Vector3, vector3_3: Vector3, vector3_4: Vector3)
	return {
		length = 0.58,
		p = {
			{ 0, vector3, true },
			{ 0.07, vector3 + Vector3.new(0, -0.04, -0.08) },
			{ 0.22, vector3 + Vector3.new(0, -0.05, -0.1), true },
			{ 0.38, vector3_3 },
			{ 0.58, Vector3.new(2.2, -1.8, -1.6), true }
		},
		a = {
			{ 0, vector3_2, true },
			{ 0.07, vector3_2 + Vector3.new(-4, 0, 0) },
			{ 0.22, vector3_2 + Vector3.new(-5, 0, 0), true },
			{ 0.38, vector3_4 },
			{ 0.58, Vector3.new(72.5, -3, 0), true }
		},
		left = {
			{ 0, 0 },
			{ 0.3, 0, true },
			{ 0.5, 1, true }
		}
	}
end

local strike2, v2, v3 = strike(
	Vector3.new(0.25, -1.15, -1.1),
	Vector3.new(102, -76, 8),
	Vector3.new(0.85, -0.99, -2.3),
	Vector3.new(75, -55, 0),
	Vector3.new(-0.56, -1.22, -1.69),
	Vector3.new(42, -38, 0)
)
local wall2 = wall(
	Vector3.new(-0.56, -1.22, -1.69),
	Vector3.new(42, -38, 0),
	Vector3.new(0.9, -1.5, -1.6),
	Vector3.new(60, -20, 0)
)

local through = {
	length = 0.62,
	p = {
		{ 0, Vector3.new(-0.56, -1.22, -1.69), v2 * 0.6 },
		{ 0.08, Vector3.new(-1, -1.7, -1.4) },
		{ 0.2, Vector3.new(-0.8, -2.4, -1), true },
		{ 0.42, Vector3.new(1.6, -2.3, -1.4) },
		{ 0.62, Vector3.new(2.2, -1.8, -1.6), true }
	},
	a = {
		{ 0, Vector3.new(42, -38, 0), v3 * 0.6 },
		{ 0.08, Vector3.new(-10, -38, 0) },
		{ 0.2, Vector3.new(-45, -40, 0), true },
		{ 0.42, Vector3.new(50, -15, 0) },
		{ 0.62, Vector3.new(72.5, -3, 0), true }
	},
	left = {
		{ 0, 0 },
		{ 0.3, 0, true },
		{ 0.55, 1, true }
	}
}

local strike3, v4, v5 = strike(
	Vector3.new(0.6, -1.3, -1.2),
	Vector3.new(92, 100, 0),
	Vector3.new(-0.94, -1.21, -2.17),
	Vector3.new(72, 62, 0),
	Vector3.new(0.19, -0.8, -1.69),
	Vector3.new(42, 38, 0)
)
local v6 = {
	fore = {
		wind = {
			length = 0.36,
			p = {
				{ 0, Vector3.new(2.2, -1.8, -1.6), true },
				{ 0.12, Vector3.new(2.4, -1.7, -1.5) },
				{ 0.2, Vector3.new(0.35, -1.35, -1) },
				{ 0.36, Vector3.new(0.25, -1.15, -1.1), true }
			},
			a = {
				{ 0, Vector3.new(72.5, -3, 0), true },
				{ 0.12, Vector3.new(85, -40, 4) },
				{ 0.2, Vector3.new(108, -80, 8) },
				{ 0.36, Vector3.new(102, -76, 8), true }
			},
			left = {
				{ 0, 1 },
				{ 0.05, 1 },
				{ 0.18, 0, true }
			}
		},
		strike = strike2,
		wall = wall2,
		through = through
	},
	back = {
		wind = {
			length = 0.28,
			p = {
				{ 0, Vector3.new(2.2, -1.8, -1.6), true },
				{ 0.06, Vector3.new(1.2, -0.7, -1.2) },
				{ 0.12, Vector3.new(0.75, -0.55, -1.15) },
				{ 0.2, Vector3.new(0.75, -0.6, -1.15) },
				{ 0.28, Vector3.new(0.6, -1.3, -1.2), true }
			},
			a = {
				{ 0, Vector3.new(72.5, -3, 0), true },
				{ 0.06, Vector3.new(100, 45, -3) },
				{ 0.12, Vector3.new(105, 88, -5) },
				{ 0.2, Vector3.new(103, 90, -5) },
				{ 0.28, Vector3.new(92, 100, 0), true }
			},
			left = {
				{ 0, 1 },
				{ 0.03, 1 },
				{ 0.12, 0, true }
			}
		},
		strike = strike3,
		wall = wall(
			Vector3.new(0.19, -0.8, -1.69),
			Vector3.new(42, 38, 0),
			Vector3.new(1.3, -1.2, -1.5),
			Vector3.new(70, 20, 0)
		),
		through = {
			length = 0.62,
			p = {
				{ 0, Vector3.new(0.19, -0.8, -1.69), v4 * 0.6 },
				{ 0.08, Vector3.new(1, -0.9, -1.4) },
				{ 0.2, Vector3.new(1.4, -1.6, -1.1), true },
				{ 0.42, Vector3.new(2, -1.9, -1.5) },
				{ 0.62, Vector3.new(2.2, -1.8, -1.6), true }
			},
			a = {
				{ 0, Vector3.new(42, 38, 0), v5 * 0.6 },
				{ 0.08, Vector3.new(-10, 38, 0) },
				{ 0.2, Vector3.new(-45, 40, 0), true },
				{ 0.42, Vector3.new(45, 10, 0) },
				{ 0.62, Vector3.new(72.5, -3, 0), true }
			},
			left = {
				{ 0, 0 },
				{ 0.3, 0, true },
				{ 0.55, 1, true }
			}
		}
	},
	over = {
		wind = {
			length = 0.34,
			p = {
				{ 0, Vector3.new(2.2, -1.8, -1.6), true },
				{ 0.12, Vector3.new(1.9, -1, -1.3) },
				{ 0.26, Vector3.new(1.2, 0.9, -0.7) },
				{ 0.34, Vector3.new(1.15, 1, -0.6), true }
			},
			a = {
				{ 0, Vector3.new(72.5, -3, 0), true },
				{ 0.12, Vector3.new(100, 5, -8) },
				{ 0.26, Vector3.new(155, 18, -10) },
				{ 0.34, Vector3.new(162, 20, -10), true }
			},
			left = {
				{ 0, 1 },
				{ 0.06, 1 },
				{ 0.2, 0, true }
			}
		},
		strike = {
			length = 0.08,
			p = {
				{ 0, Vector3.new(1.15, 1, -0.6), true },
				{ 0.04, Vector3.new(0.85, 0.1, -1.3) },
				{ 0.08, Vector3.new(0.55, -1.15, -1.5), Vector3.new(-9.000001, -37.5, -6.000002) }
			},
			a = {
				{ 0, Vector3.new(162, 20, -10), true },
				{ 0.04, Vector3.new(95, 24, -4) },
				{ 0.08, Vector3.new(28.2, 25.6, 0), Vector3.new(-2004.0002, 48.000015, 120.00001) }
			}
		},
		wall = {
			length = 0.58,
			p = {
				{ 0, Vector3.new(0.55, -1.15, -1.5), true },
				{ 0.07, Vector3.new(0.55, -1.23, -1.54) },
				{ 0.22, Vector3.new(0.55, -1.25, -1.55), true },
				{ 0.38, Vector3.new(1.6, -0.9, -1.2) },
				{ 0.58, Vector3.new(2.2, -1.8, -1.6), true }
			},
			a = {
				{ 0, Vector3.new(28.2, 25.6, 0), true },
				{ 0.07, Vector3.new(24.2, 25.6, 0) },
				{ 0.22, Vector3.new(23.2, 25.6, 0), true },
				{ 0.38, Vector3.new(75, 10, -4) },
				{ 0.58, Vector3.new(72.5, -3, 0), true }
			},
			left = {
				{ 0, 0 },
				{ 0.3, 0, true },
				{ 0.5, 1, true }
			}
		},
		through = {
			length = 0.62,
			p = {
				{ 0, Vector3.new(0.55, -1.15, -1.5), Vector3.new(-5.4000006, -22.5, -3.6000013) },
				{ 0.08, Vector3.new(0.4, -2, -1.3) },
				{ 0.2, Vector3.new(0.6, -2.9, -1), true },
				{ 0.42, Vector3.new(1.9, -2.2, -1.4) },
				{ 0.62, Vector3.new(2.2, -1.8, -1.6), true }
			},
			a = {
				{ 0, Vector3.new(28.2, 25.6, 0), Vector3.new(-1202.4001, 28.80001, 72.00001) },
				{ 0.08, Vector3.new(-5, 25, 0) },
				{ 0.2, Vector3.new(-25, 20, 0), true },
				{ 0.42, Vector3.new(55, 0, 0) },
				{ 0.62, Vector3.new(72.5, -3, 0), true }
			},
			left = {
				{ 0, 0 },
				{ 0.3, 0, true },
				{ 0.55, 1, true }
			}
		}
	}
}

local v7 = v6.fore
local v8 = "fore"
local v9 = -1e999

local v10 = "idle"
local lastTime = 0
local firing = false
local renderSteppedConnection = nil

local function enter(p: string) -- 3 equivalent calls inferred from this helper
	v10 = p
	lastTime = os.clock()

	if p == "wind" then
		if lastTime - v9 > 1.2 then
			v8 = "fore"
		end

		if workspace.CurrentCamera.CFrame.LookVector.Y < -0.55 then
			v7 = v6.over
		else
			v7 = v6[v8]
			v8 = v8 == "fore" and "back" or "fore"
		end
	end
end

local function setPose(sample: Vector3, sample2: Vector3) -- 1 equivalent call inferred from this helper
	local v11 = handleAt(sample, sample2)
	v.pose = CFrame.new(v11.Position - hold.Position) * (hold.Rotation:Inverse() * v11.Rotation)
end

local function rest() -- 3 equivalent calls inferred from this helper
	v10 = "idle"
	v.pose = CFrame.identity
	v.leftWeight = 1
	v.firing = firing
end

local HttpService = game:GetService("HttpService")
local guid = HttpService:GenerateGUID(false)
local v11 = "HammerDipUndo" .. guid
local v12 = "HammerDip" .. guid
local lastTime2 = -1e999
local v13 = 0
local cframe = nil
local function gone(): boolean -- 2 equivalent calls inferred from this helper
	if parent:IsDescendantOf(game) then
		return false
	end

	RunService:UnbindFromRenderStep(v11)
	RunService:UnbindFromRenderStep(v12)
	return true
end

local function step1()
	if gone() then -- inferred equivalent call
		return
	end

	if cframe then
		workspace.CurrentCamera.CFrame *= cframe:Inverse()
		cframe = nil
	end
end
local function step2()
	if gone() then -- inferred equivalent call
		return
	end

	local v14 = (os.clock() - lastTime2) / 0.15

	if v14 >= 0 and v14 < 1 then
		local v15 = (1 - v14) * (1 - v14)
		cframe = CFrame.Angles(-math.rad(v13 * v15), 0, 0)
		local currentCamera = workspace.CurrentCamera

		if VR.on() then
			cframe = nil
		else
			currentCamera.CFrame *= cframe
		end
	end
end

local v14 = false
local count = 0
local function bindSteps()
	count += 1

	if v14 or not parent:IsDescendantOf(game) then
		return
	end

	v14 = true
	RunService:BindToRenderStep(v11, Enum.RenderPriority.Camera.Value - 3, step1)
	RunService:BindToRenderStep(v12, Enum.RenderPriority.Camera.Value + 3, step2)
end
local function unbindSteps()
	v14 = false

	for _, v15 in { v11, v12 } do
		RunService:UnbindFromRenderStep(v15)
	end

	if cframe then
		workspace.CurrentCamera.CFrame *= cframe:Inverse()
		cframe = nil
	end
end
parent.Equipped:Connect(bindSteps)
parent.Unequipped:Connect(function()
	count += 1
	local v15 = count
	task.delay(1, function()
		if v15 == count and v14 and parent.Parent ~= LocalPlayer.Character then
			unbindSteps()
		end
	end)
end)

if parent.Parent == LocalPlayer.Character then
	bindSteps()
end

local function dip(p: number) -- 2 equivalent calls inferred from this helper
	lastTime2 = os.clock()
	v13 = p
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local function contact(): nil | string
	local character = LocalPlayer.Character
	local currentCamera = workspace.CurrentCamera
	local v15 = { currentCamera }

	if character then
		table.insert(v15, character)
	end

	for _, childName in { "VoxelChips", "VoxelLoose", "VoxelTracers", "VoxelGrenades" } do
		local child = workspace:FindFirstChild(childName)

		if child then
			table.insert(v15, child)
		end
	end

	Viewmodel.setFilter(raycastParams, v15)
	local aimPoint = TouchControls.aimPoint()
	local ray = VR.ray(currentCamera, aimPoint.X, aimPoint.Y)
	local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 13, raycastParams)
	local v16

	if raycastResult == nil then
		v16 = false
	else
		v16 = (raycastResult.Position - ray.Origin).Magnitude <= 9
	end

	if not raycastResult then
		hammerHit:FireServer(nil, nil, ray.Direction)
		return nil
	end

	local instance = raycastResult.Instance
	local voxelWorld = workspace:FindFirstChild("VoxelWorld")
	local vehicleHulls = workspace:FindFirstChild("VehicleHulls")
	local helicopters = workspace:FindFirstChild("Helicopters")
	local botRigs = workspace:FindFirstChild("BotRigs")
	local model = instance:FindFirstAncestorWhichIsA("Model")
	local v17 = botRigs ~= nil and instance:IsDescendantOf(botRigs)

	if not v17 then
		if model == nil then
			v17 = false
		else
			v17 = model:FindFirstChildOfClass("Humanoid") ~= nil
		end
	end

	if v17 then
		hammerHit:FireServer(nil, nil, ray.Direction)
		VoxelSound.hammerBody(raycastResult.Position, true)
		return "body"
	else
		if not v16 then
			hammerHit:FireServer(nil, nil, ray.Direction)
			return nil
		end

		local v18 = vehicleHulls ~= nil and instance:IsDescendantOf(vehicleHulls)

		if not v18 then
			if helicopters == nil then
				v18 = false
			else
				v18 = instance:IsDescendantOf(helicopters)
			end
		end

		if voxelWorld and instance:IsDescendantOf(voxelWorld) or v18 or instance == workspace.Terrain then
			hammerHit:FireServer(raycastResult.Position, raycastResult.Normal, ray.Direction, v18)

			if not v18 then
				StrikePredict.strike(
					raycastResult.Position,
					raycastResult.Normal,
					ray.Direction,
					"Hammer",
					instance == workspace.Terrain
				)
			end
		else
			hammerHit:FireServer(nil, nil, ray.Direction)
			VoxelSound.click(raycastResult.Position, 1, 1)
		end

		return "wall"
	end
end

local function play(data, p: number) -- 3 equivalent calls inferred from this helper
	setPose(Keyframes.sample(data.p, p), Keyframes.sample(data.a, p)) -- inferred equivalent call

	if data.left then
		v.leftWeight = Keyframes.sample(data.left, p)
	end
end

local function step()
	local v15 = os.clock() - lastTime

	if v10 == "wind" then
		play(v7.wind, v15) -- inferred equivalent call

		if v7.wind.length <= v15 then
			enter("strike") -- inferred equivalent call
			VoxelSound.swing(workspace.CurrentCamera.CFrame.Position)

			local toolanim = Instance.new("StringValue")
			toolanim.Name = "toolanim"
			toolanim.Value = "Slash"
			toolanim.Parent = parent
		end
	elseif v10 == "strike" then
		play(v7.strike, v15) -- inferred equivalent call
		v.leftWeight = 0

		if v7.strike.length <= v15 then
			local v16 = contact()

			if v16 == "wall" then
				enter("wall") -- inferred equivalent call
				dip(2) -- inferred equivalent call
				v:bump(0.35)
			else
				enter("through") -- inferred equivalent call

				if v16 == "body" then
					dip(1) -- inferred equivalent call
				end
			end
		end
	elseif v10 == "wall" or v10 == "through" then
		local v16

		if v10 == "wall" then
			v16 = v7.wall
		else
			v16 = v7.through
		end

		play(v16, v15) -- inferred equivalent call

		if v16.length <= v15 then
			v9 = os.clock()
			rest() -- inferred equivalent call

			if firing and v.active then
				v10 = "wind"
				lastTime = os.clock()

				if lastTime - v9 > 1.2 then
					v8 = "fore"
				end

				if workspace.CurrentCamera.CFrame.LookVector.Y < -0.55 then
					v7 = v6.over
				else
					v7 = v6[v8]
					v8 = v8 == "fore" and "back" or "fore"
				end
			end
		end
	end
end

local function start()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
	end

	firing = false
	rest() -- inferred equivalent call
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		if v.active then
			step()
		end
	end)
end

local function stop()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	firing = false
	rest() -- inferred equivalent call
end

parent.Equipped:Connect(start)
parent.Unequipped:Connect(stop)

local function startFire()
	firing = true
	v.firing = true

	if v10 ~= "idle" then
		return
	end

	local lastTime3 = os.clock()

	while v.active and not v:ready() and os.clock() - lastTime3 < 0.5 do
		task.wait()
	end

	if v.active and v10 == "idle" and not Viewmodel.held() then
		v10 = "wind"
		lastTime = os.clock()

		if lastTime - v9 > 1.2 then
			v8 = "fore"
		end

		if workspace.CurrentCamera.CFrame.LookVector.Y < -0.55 then
			v7 = v6.over
		else
			v7 = v6[v8]
			v8 = v8 == "fore" and "back" or "fore"
		end
	end
end
local function stopFire() -- 1 equivalent call inferred from this helper
	firing = false
	v.firing = false
end

parent.Activated:Connect(startFire)
parent.Deactivated:Connect(stopFire)

parent:GetAttributeChangedSignal("QuickSwing"):Connect(function()
	if parent:GetAttribute("QuickSwing") == nil then
		return
	end

	task.spawn(function()
		local lastTime3 = os.clock()

		while not (v.active and v:ready()) and os.clock() - lastTime3 < 1.5 do
			task.wait()
		end

		startFire()
		stopFire() -- inferred equivalent call
		local lastTime4 = os.clock()

		while v.active and v10 ~= "idle" and os.clock() - lastTime4 < 2.5 do
			task.wait()
		end

		parent:SetAttribute("QuickSwing", nil)
		parent:SetAttribute("QuickDone", os.clock())
	end)
end)

TouchControls.register(parent, { label = "SWING", startFire = startFire, stopFire = stopFire })