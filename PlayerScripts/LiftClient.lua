local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local LiftShared = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("LiftShared"))
local Materials = require(Voxel:WaitForChild("Materials"))
local VoxelSound = require(Voxel:WaitForChild("VoxelSound"))
local EnterButton = require(Voxel:WaitForChild("EnterButton"))
local GameUI = script.Parent:WaitForChild("GameUI")
local Glyph = require(GameUI:WaitForChild("Glyph"))
local Style = require(GameUI:WaitForChild("Style"))

local Lifts = ReplicatedStorage:WaitForChild("Lifts")
local Cars = Lifts:WaitForChild("Cars")
local Press = Lifts:WaitForChild("Press")
local Moved = Lifts:WaitForChild("Moved")

local color = Color3.fromRGB(104, 108, 116)
local color2 = Color3.fromRGB(44, 46, 52)

local color3 = Color3.fromRGB(120, 214, 96)
local color4 = Color3.fromRGB(255, 198, 32)
local color5 = Color3.fromRGB(214, 62, 48)
local color6 = Color3.fromRGB(58, 60, 66)
local v = assert(Materials.Ids.BunkerSteel, "[LiftClient] Materials has no BunkerSteel")

local v2 = {}
local v3 = 0
local v4 = nil

local function block(model, name: string, size: Vector3, cframe: CFrame, color7: Color3, canCollide: boolean, flag: boolean)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = canCollide
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	local material

	if flag then
		material = Enum.Material.Neon
	else
		material = Enum.Material.SmoothPlastic
	end

	part.Material = material
	local smooth = Enum.SurfaceType.Smooth
	local smooth2 = Enum.SurfaceType.Smooth
	part.TopSurface = smooth
	part.BottomSurface = smooth2
	part.Color = color7
	part.Size = size
	part.CFrame = cframe
	part.Parent = model
	return part
end

local function apply(data, flag: boolean)
	local at = data.cfg:GetAttribute("At")
	local go = data.cfg:GetAttribute("Go")
	local out = data.cfg:GetAttribute("Out") == true
	local currentCamera = workspace.CurrentCamera

	for i = 0, 1 do
		local v5 = i + 1
		local v6

		if at == i then
			v6 = go == 0
		else
			v6 = false
		end

		if data.open[v5] ~= v6 then
			data.open[v5] = v6
			local v7 = not currentCamera or (currentCamera.CFrame.Position - data.doorAt[v5]).Magnitude
			local v8 = not flag

			if v8 then
				if v7 == true then
					v8 = false
				else
					v8 = v7 < 250
				end
			end

			for _, v9 in data.leaves[v5] do
				local cframe = if v6 then v9.open else v9.shut

				if v8 then
					local part = v9.part
					local v10

					if v6 then
						v10 = LiftShared.OPEN
					else
						v10 = LiftShared.CLOSE
					end

					TweenService:Create(part, TweenInfo.new(v10, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
						CFrame = cframe
					}):Play()
				else
					v9.part.CFrame = cframe
				end
			end

			if v8 and v7 < 120 then
				VoxelSound.hit(v, 8, data.doorAt[v5], 0.4)
			end
		end

		local color7

		if out then
			color7 = color6
		elseif go == 0 then
			color7 = if at == i then color3 else color5
		else
			color7 = color4
		end

		for _, v7 in data.lamps[v5] do
			if v7.Color ~= color7 then
				v7.Color = color7
			end
		end
	end
end

local v5 = nil
local v6 = nil
local v7 = nil
local v8 = false
local v9 = nil
local v10 = 0

local function buildPrompt()
	local layer = Style.layer(LocalPlayer:WaitForChild("PlayerGui"), "LiftPrompt", 7)
	layer.Enabled = false
	v5 = layer
	local region = Style.region(layer, "Prompt", Vector2.new(0.5, 0.5), Vector2.zero, Vector2.new(420, 46))
	region.Position = UDim2.fromScale(0.5, 0.68)
	local fill = Style.fill(
		region,
		"Band",
		Style.INK,
		UDim2.fromScale(1, 1),
		UDim2.fromScale(0.5, 0.5),
		Vector2.new(0.5, 0.5)
	)
	fill.BackgroundTransparency = 0.35
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.18, 0),
		NumberSequenceKeypoint.new(0.82, 0),
		NumberSequenceKeypoint.new(1, 1)
	})

	uiGradient.Parent = fill
	local frame = Style.frame(region, "Row", UDim2.fromScale(1, 1))
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0, 10)
	uiListLayout.Parent = frame
	local cap = Glyph.cap(frame, "E", Enum.KeyCode.ButtonY, 28)
	cap.LayoutOrder = 1
	v6 = Style.label(frame, "Line", "", 24, Style.FONT, 1.5)
	v6.LayoutOrder = 2
end

local function pressNow()
	local v11 = v9
	local now = os.clock()

	if not v11 or now - v10 < 0.4 then
		return
	end

	v10 = now
	Press:FireServer(v11.cfg.Name)
end

local function offer(p, text: string?)
	if not text then
		p = nil
	end

	v9 = p

	if v7 ~= text then
		v7 = text
		Glyph.claim("lift", text ~= nil)
		EnterButton.set("lift", text and {
			word = text,
			what = "ELEVATOR",
			icon = "LIFT",
			locked = false,
			press = pressNow
		} or nil)

		if text then
			if not v5 then
				buildPrompt()
			end

			v6.Text = text
		end
	end

	local enabled

	if text == nil then
		enabled = false
	else
		enabled = Glyph.mode() ~= "touch"
	end

	if v8 ~= enabled then
		v8 = enabled

		if v5 then
			v5.Enabled = enabled
		end
	end
end

local function rootNow()
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if
		character
		and humanoid
		and not (humanoid.Health <= 0)
		and humanoidRootPart
		and humanoidRootPart:IsA("BasePart")
	then
		return character, humanoidRootPart
	end

	return nil, nil
end

local function look()
	local _, v11 = rootNow()

	if
		v11
		and LocalPlayer.Team ~= nil
		and not LocalPlayer:GetAttribute("InVehicle")
		and LocalPlayer:GetAttribute("ReviveFocus") ~= true
		and not (Glyph.claimed("vehicle") or Glyph.claimed("heli") or Glyph.claimed("gun"))
	then
		local position = v11.Position

		for _, v12 in v2 do
			local lift = v12.lift

			if not (math.abs(position.X - lift.pos.X) < 30 and math.abs(position.Z - lift.pos.Z) < 30) then
				continue
			end

			if not (v12.cfg:GetAttribute("Go") == 0 and v12.cfg:GetAttribute("Out") ~= true) then
				continue
			end

			local at = v12.cfg:GetAttribute("At")
			local zone = LiftShared.zone(lift, at, position, 0)

			if zone then
				offer(v12, zone == "call" and "CALL ELEVATOR" or at == 0 and "ELEVATOR UP" or "ELEVATOR DOWN")
				return
			end
		end

		v9 = nil

		if v7 ~= nil then
			v7 = nil
			Glyph.claim("lift", false)
			EnterButton.set("lift", nil)
		end

		if v8 ~= false then
			v8 = false

			if v5 then
				v5.Enabled = false
			end
		end
	else
		v9 = nil

		if v7 ~= nil then
			v7 = nil
			Glyph.claim("lift", false)
			EnterButton.set("lift", nil)
		end

		if v8 ~= false then
			v8 = false

			if v5 then
				v5.Enabled = false
			end
		end
	end
end

local heartbeatConnection = nil
local total = 0
local function setLooking(flag: boolean) -- 2 equivalent calls inferred from this helper
	if flag and not heartbeatConnection then
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
			total += dt

			if total >= 0.15 then
				total = 0
				look()
			end
		end)
	elseif not flag and heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
		v9 = nil

		if v7 ~= nil then
			v7 = nil
			Glyph.claim("lift", false)
			EnterButton.set("lift", nil)
		end

		if v8 ~= false then
			v8 = false

			if v5 then
				v5.Enabled = false
			end
		end
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
	if gameProcessed or not v9 then
		return
	end

	if input.KeyCode == Enum.KeyCode.E or input.KeyCode == Enum.KeyCode.ButtonY then
		local v11 = v9
		local now = os.clock()

		if v11 then
			if now - v10 < 0.4 then
				return
			end

			v10 = now
			Press:FireServer(v11.cfg.Name)
		end
	end
end)

local function add(child)
	if v2[child.Name] then
		return
	end

	local lift = LiftShared.read(child)
	local lifts = v4

	if not lifts then
		lifts = Instance.new("Folder")
		lifts.Name = "Lifts"
		lifts.Parent = workspace
		v4 = lifts
	end

	local model = Instance.new("Model")
	model.Name = child.Name
	local vector3 = Vector3.new(-lift.face.Z, 0, lift.face.X)
	local v11 = {
		cfg = child,
		lift = lift,
		model = model,
		leaves = {},
		lamps = {},
		doorAt = {},
		open = {},
		conn = nil
	}

	for i = 0, 1 do
		local v12 = i + 1
		local v13 = lift.pos + Vector3.new(0, i * lift.rise + lift.doorH * 0.5, 0) + lift.face * (lift.hv + lift.wall * 0.5)
		local cframe = CFrame.fromMatrix(v13, vector3, Vector3.new(0, 1, 0), -lift.face)
		v11.doorAt[v12] = v13
		v11.leaves[v12] = {}

		for _, v14 in { -1, 1 } do
			local shut = cframe * CFrame.new(v14 * lift.doorW * 0.25, 0, 0)
			local open = cframe * CFrame.new(v14 * (lift.doorW * 0.75 + 0.08), 0, 0)
			local part = block(model, "Leaf", Vector3.new(lift.doorW * 0.5, lift.doorH, 0.4), open, color, true, false)
			table.insert(v11.leaves[v12], { part = part, shut = shut, open = open })
		end

		v11.open[v12] = true
		local v14 = lift.wall * 0.5 + 0.1
		v11.lamps[v12] = {
			block(
				model,
				"LampOut",
				Vector3.new(1.6, 0.5, 0.3),
				cframe * CFrame.new(0, lift.doorH * 0.5 + 1.1, -v14),
				color5,
				false,
				true
			),
			block(
				model,
				"LampIn",
				Vector3.new(1.6, 0.5, 0.3),
				cframe * CFrame.new(0, lift.doorH * 0.5 + 0.6, v14),
				color5,
				false,
				true
			)
		}

		local v15 = lift.doorW * 0.5 + 1.1
		block(
			model,
			"PlateOut",
			Vector3.new(0.7, 1.1, 0.3),
			cframe * CFrame.new(v15, 3.6 - lift.doorH * 0.5, -v14),
			color2,
			false,
			false
		)
		block(
			model,
			"PlateIn",
			Vector3.new(0.7, 1.1, 0.3),
			cframe * CFrame.new(v15, 3.6 - lift.doorH * 0.5, v14),
			color2,
			false,
			false
		)
	end

	v11.conn = child.AttributeChanged:Connect(function(p: string)
		if p == "At" or p == "Go" or p == "Out" then
			apply(v11, false)
		end
	end)
	apply(v11, true)
	model.Parent = lifts
	v2[child.Name] = v11
	v3 += 1
	setLooking(true) -- inferred equivalent call
end

local function drop(p)
	local v11 = v2[p.Name]

	if not v11 or v11.cfg ~= p then
		return
	end

	v11.conn:Disconnect()
	v11.model:Destroy()
	v2[p.Name] = nil
	v3 -= 1

	if v9 == v11 then
		v9 = nil

		if v7 ~= nil then
			v7 = nil
			Glyph.claim("lift", false)
			EnterButton.set("lift", nil)
		end

		if v8 ~= false then
			v8 = false

			if v5 then
				v5.Enabled = false
			end
		end
	end

	if v3 == 0 then
		setLooking(false) -- inferred equivalent call
	end
end

Moved.OnClientEvent:Connect(function(p: string, p2: number)
	task.delay(0.35, function()
		local v11 = v2[p]
		local v12, v13 = rootNow()

		if v11 and v12 and v13 and LiftShared.inCar(v11.lift, p2, v13.Position, 2) then
			v12:PivotTo(v12:GetPivot() + Vector3.new(0, (1 - p2 * 2) * v11.lift.rise, 0))
		end
	end)
end)

Cars.ChildAdded:Connect(function(child)
	add(child)
end)
Cars.ChildRemoved:Connect(drop)

for _, child in Cars:GetChildren() do
	add(child)
end