local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local parent = script.Parent
local LocalPlayer = Players.LocalPlayer
local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local Viewmodel = require(Voxel:WaitForChild("Viewmodel"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local VR = require(ReplicatedStorage2:WaitForChild("Voxel"):WaitForChild("VR"))
local VoxelSound = require(Voxel:WaitForChild("VoxelSound"))
local TouchControls = require(Voxel:WaitForChild("TouchControls"))
local ClientWorld = require(Voxel:WaitForChild("ClientWorld"))
local VoxelCore = require(Voxel:WaitForChild("VoxelCore"))
local WorldConfig = require(Voxel:WaitForChild("WorldConfig"))
local GroundHeight = require(Voxel:WaitForChild("GroundHeight"))
local Game = ReplicatedStorage:WaitForChild("Game")
local Turret = require(Game:WaitForChild("Turret"))
local TurretHead = require(Game:WaitForChild("TurretHead"))
local Barrier = require(Game:WaitForChild("Barrier"))
local build = Game:WaitForChild("Remotes"):WaitForChild("Build")
local Style = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("GameUI"):WaitForChild("Style"))
local ToolIcon = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("GameUI"):WaitForChild("ToolIcon"))

local newVector3 = Vector3.new
local VOXEL_SIZE = WorldConfig.VOXEL_SIZE
local v = WorldConfig.ORIGIN
WorldConfig.onOrigin(function(p)
	v = p
end)

local function handleAt(vector3: Vector3, vector3_2: Vector3)
	local x = math.rad(vector3_2.X)
	local y = math.rad(vector3_2.Y)
	local z = math.rad(vector3_2.Z)
	local cframe = CFrame.Angles(0, z, 0) * CFrame.Angles(0, 0, y)
	local vectorToWorldSpace = cframe:VectorToWorldSpace((newVector3(0, math.sin(x), -math.cos(x))))
	local vector = cframe:VectorToWorldSpace((newVector3(0, -math.cos(x), -math.sin(x))))
	return CFrame.fromMatrix(
		vector3 + vectorToWorldSpace * 0.6,
		vector:Cross(vectorToWorldSpace),
		vector,
		vectorToWorldSpace
	)
end

local v2 = Viewmodel.new(parent, {
	name = "BUILDER'S HAMMER",
	hold = handleAt(Vector3.new(1.75, -1.45, -1.75), Vector3.new(66, -6, 4)),
	rightHand = Vector3.new(0, -0.08, -0.62),
	leftHand = Vector3.new(0, -0.08, -0.2),
	armThickness = 0.55,
	muzzle = Vector3.new(0, 0.46, 1),
	aimPoint = Vector3.new(0, 0, 0),
	aimDistance = 2,
	aimFov = 80,
	aimMove = 1,
	reach = 1,
	sprintHold = handleAt(Vector3.new(1.7, -1.35, -1.1), Vector3.new(100, -12, 8)),
	hipKick = Vector3.new(0, 0, 0),
	hipKickRot = Vector3.new(0, 0, 0),
	aimKick = Vector3.new(0, 0, 0),
	aimKickRot = Vector3.new(0, 0, 0),
	recoilTime = 0.3,
	punch = 0
})

v2.aimBlocked = true
v2.leftTarget = Vector3.new(-1.2, -2.9, -1)
v2.leftWeight = 1

local lastTime = -1

local function knock() -- 2 equivalent calls inferred from this helper
	lastTime = os.clock()
end

local v3 = {}

for _, v4 in Barrier.ORDER do
	local kind = Barrier.KINDS[v4]
	table.insert(v3, {
		id = kind.id,
		name = kind.name,
		cost = kind.cost,
		limit = kind.limit,
		kind = kind,
		attr = Barrier.countAttr(kind.id),
		swaps = true
	})
end

table.insert(v3, {
	id = Turret.ID,
	name = Turret.NAME,
	cost = Turret.COST,
	limit = Turret.LIMIT,
	attr = "Turrets",
	swaps = false
})
table.insert(v3, {
	id = Turret.FLAK.ID,
	name = Turret.FLAK.NAME,
	cost = Turret.FLAK.COST,
	limit = Turret.FLAK.LIMIT,
	attr = "FlakGuns",
	swaps = false
})

local buildPick = LocalPlayer:GetAttribute("BuildPick")
local v4 = (type(buildPick) ~= "number" or not v3[buildPick]) and 1 or buildPick

local v5 = v3[v4]
local v6 = 0
local flag = false

local function supply() -- 2 equivalent calls inferred from this helper
	local supply2 = LocalPlayer:GetAttribute("Supply")
	return if type(supply2) == "number" then supply2 else 0
end

local function upOf(p) -- 6 equivalent calls inferred from this helper
	local attribute = LocalPlayer:GetAttribute(p.attr)
	return if type(attribute) == "number" then attribute else 0
end

local function fullText(p) -- 3 equivalent calls inferred from this helper
	if p.id == Turret.ID then
		return (string.format("%d/%d TURRETS UP", p.limit, p.limit))
	end

	return "FLAK GUN ALREADY UP"
end

local function padInput() -- 1 equivalent call inferred from this helper
	return GuiService:IsTenFootInterface() or UserInputService:GetLastInputType().Name:find("Gamepad") ~= nil
end

local v7 = nil
local v8 = nil
local v9 = ""
local v10 = Style.WHITE
local function buildHint()
	local buildHint2 = Instance.new("ScreenGui")
	buildHint2.Name = "BuildHint"
	buildHint2.ResetOnSpawn = false
	buildHint2.IgnoreGuiInset = true
	buildHint2.DisplayOrder = 6
	v8 = Style.label(buildHint2, "Hint", "", 17, Style.FONT, 1.5)
	v8.AnchorPoint = Vector2.new(0.5, 0)
	v8.Position = UDim2.new(0.5, 0, 0.5, 46)
	v8.Size = UDim2.fromOffset(0, 22)
	v8.AutomaticSize = Enum.AutomaticSize.X
	v7 = buildHint2
end
local function setHint(text: string, textColor: Color3) -- 3 equivalent calls inferred from this helper
	if text ~= v9 or textColor ~= v10 then
		v9 = text
		v10 = textColor
		local v11 = v8
		v8.Text = text
		v11.TextColor3 = textColor
	end
end

local v11 = ""
local v12 = Style.WHITE
local v13 = 0
local function flash(p: string, color: Color3) -- 5 equivalent calls inferred from this helper
	local v14 = os.clock() + 1.6
	v11 = p
	v12 = color
	v13 = v14
end

local v14 = #v3 * 96 + (#v3 - 1) * 8

local v15 = {}
local v16 = nil
local parent2 = nil
local v17 = nil
local parent3 = nil

local function sh(p: number, p2: number, p3: number, p4: number, value: number?, flag2: boolean?)
	return {
		c = Vector2.new(p, p2),
		w = p3,
		h = p4,
		angle = math.rad(value or 0),
		round = flag2 == true
	}
end
local v18 = {
	Barrier = ToolIcon.artFrom({
		{
			c = Vector2.new(0, 0.62),
			w = 3,
			h = 1,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(-1.62, 0.7),
			w = 0.3,
			h = 1.4,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(1.62, 0.7),
			w = 0.3,
			h = 1.4,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0, 1.3),
			w = 3.6,
			h = 0.2,
			angle = 0,
			round = false
		}
	}),
	Wall = ToolIcon.artFrom({
		{
			c = Vector2.new(-1.15, 1.2),
			w = 0.9,
			h = 2.4,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(1.15, 1.2),
			w = 0.9,
			h = 2.4,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0, 0.65),
			w = 1.5,
			h = 1.3,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0, 2.1),
			w = 1.5,
			h = 0.6,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0, 2.5),
			w = 3.5,
			h = 0.2,
			angle = 0,
			round = false
		}
	}),
	Ramp = ToolIcon.artFrom({
		{
			c = Vector2.new(-1.2, 0.25),
			w = 0.82,
			h = 0.5,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(-0.4, 0.5),
			w = 0.82,
			h = 1,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0.4, 0.75),
			w = 0.82,
			h = 1.5,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(1.2, 1),
			w = 0.82,
			h = 2,
			angle = 0,
			round = false
		}
	}),
	[Turret.ID] = ToolIcon.artFrom({
		{
			c = Vector2.new(0, 0.15),
			w = 2.3,
			h = 0.3,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0, 0.72),
			w = 1.5,
			h = 0.84,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0, 1.24),
			w = 1.05,
			h = 0.2,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0.05, 1.6),
			w = 1,
			h = 0.52,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(-0.1, 1.94),
			w = 0.42,
			h = 0.16,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(1.1, 1.64),
			w = 1.15,
			h = 0.14,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(1.7, 1.64),
			w = 0.16,
			h = 0.26,
			angle = 0,
			round = false
		}
	}),
	[Turret.FLAK.ID] = ToolIcon.artFrom({
		{
			c = Vector2.new(0, 0.15),
			w = 2.3,
			h = 0.3,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0, 0.72),
			w = 1.5,
			h = 0.84,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0, 1.24),
			w = 1.05,
			h = 0.2,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0, 1.62),
			w = 1,
			h = 0.56,
			angle = 0.7853981633974483,
			round = false
		},
		{
			c = Vector2.new(1.05, 2.67),
			w = 2.3,
			h = 0.14,
			angle = 0.7853981633974483,
			round = false
		},
		{
			c = Vector2.new(1.86, 3.48),
			w = 0.42,
			h = 0.26,
			angle = 0.7853981633974483,
			round = false
		}
	})
}

local fn
local fn2

local function seatTray()
	local active = TouchControls.active()

	if active then
		parent2.AnchorPoint = Vector2.new(0.5, 0)
		parent2.Position = UDim2.new(0.5, 0, 0, Style.topInset() + 58 * Style.scale() * Style.touchHud())
	else
		parent2.AnchorPoint = Vector2.new(0.5, 1)
		parent2.Position = UDim2.new(0.5, 0, 1, -(18 + 64 * Style.scale()))
	end

	parent3.Visible = not active and not padInput() -- inferred equivalent call
end

local function buildTray()
	local buildTray2 = Instance.new("ScreenGui")
	buildTray2.Name = "BuildTray"
	buildTray2.ResetOnSpawn = false
	buildTray2.IgnoreGuiInset = true
	buildTray2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	buildTray2.DisplayOrder = 6
	parent2 = Style.region(buildTray2, "Tray", Vector2.new(0.5, 1), Vector2.zero, Vector2.new(v14, 122))
	Style.boost(parent2, Style.touchHud())

	for k, bp in v3 do
		local v19 = v18[bp.id]
		assert(v19, "[BuildClient] no icon for " .. bp.id)
		local textButton = Instance.new("TextButton")
		textButton.Name = "Card_" .. bp.id
		textButton.Text = ""
		textButton.AutoButtonColor = false
		textButton.BackgroundColor3 = Style.PANEL
		textButton.BackgroundTransparency = Style.PANEL_ALPHA
		textButton.BorderSizePixel = 0
		textButton.AnchorPoint = Vector2.new(0.5, 1)
		textButton.Size = UDim2.fromOffset(96, 92)
		textButton.Position = UDim2.new(0, (k - 1) * 104 + 48, 1, 0)
		textButton.Parent = parent2
		Style.corner(textButton, 3)
		local stroke = Style.stroke(textButton, 1.5, 0.35, Color3.new(0, 0, 0), true)

		local frame = Style.frame(textButton, "Icon", UDim2.fromOffset(72, 40), UDim2.fromOffset(12, 7))
		local _, paint = ToolIcon.draw(v19, frame, Style.WHITE)

		local label = Style.label(textButton, "Count", "", 13, Style.FONT, 1.5)
		label.AutomaticSize = Enum.AutomaticSize.None
		label.AnchorPoint = Vector2.new(1, 0)
		label.Position = UDim2.new(1, -6, 0, 3)
		label.Size = UDim2.fromOffset(34, 14)
		label.TextXAlignment = Enum.TextXAlignment.Right

		local label2 = Style.label(textButton, "Name", bp.name, 15, Style.FONT, 1.5)
		label2.AutomaticSize = Enum.AutomaticSize.None
		label2.Position = UDim2.fromOffset(4, 47)
		label2.Size = UDim2.new(1, -8, 0, 24)
		label2.TextXAlignment = Enum.TextXAlignment.Center
		label2.TextSize = #bp.name > 10 and 14 or 16

		local frame2 = Style.frame(textButton, "Price", UDim2.new(1, 0, 0, 18), UDim2.new(0, 0, 1, -22))
		local uiListLayout = Instance.new("UIListLayout")
		uiListLayout.FillDirection = Enum.FillDirection.Horizontal
		uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		uiListLayout.Padding = UDim.new(0, 5)
		uiListLayout.Parent = frame2
		uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		local supplyIcon = Style.supplyIcon(frame2, 13)
		supplyIcon.LayoutOrder = 1
		local label3 = Style.label(frame2, "Cost", tostring(bp.cost), 16, Style.FONT, 1.5)
		label3.LayoutOrder = 2
		label3.TextColor3 = Style.HAZARD
		v15[k] = {
			bp = bp,
			button = textButton,
			stroke = stroke,
			name = label2,
			cost = label3,
			count = label,
			paint = paint
		}
		textButton.Activated:Connect(function()
			fn(k)
		end)
	end

	local button = Style.button(
		buildTray2,
		"TearDown",
		"TEAR DOWN",
		Style.ORANGE,
		UDim2.fromOffset(112, 34),
		Style.INK,
		15
	)
	button.AnchorPoint = Vector2.new(0, 1)
	button.Position = UDim2.new(1, 8, 1, 0)
	button.Parent = parent2
	button.Visible = false
	button.Activated:Connect(function()
		fn2()
	end)
	v17 = button

	parent3 = Style.frame(parent2, "Legend", UDim2.new(1, 0, 0, 18), UDim2.fromOffset(0, 0))
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.Padding = UDim.new(0, 6)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = parent3
	local layoutOrder = 0

	for _, v19 in {
		{ "Q", "NEXT" },
		{ "R", "TURN" },
		{ "X", "TEAR DOWN" }
	} do
		local layoutOrder2 = layoutOrder + 1
		local key = Style.key(parent3, v19[1], 16)
		key.LayoutOrder = layoutOrder2
		layoutOrder2 += 1
		local label = Style.label(parent3, "Word", v19[2], 13, Style.FONT, 1.5)
		label.TextColor3 = Style.MUTED
		label.LayoutOrder = layoutOrder2
		layoutOrder = layoutOrder2 + 1
		local frame = Style.frame(parent3, "Gap", UDim2.fromOffset(8, 1))
		frame.LayoutOrder = layoutOrder
	end

	v16 = buildTray2
	seatTray()
end

local v19 = -1
local v20 = nil
local function paintTray(flag2: boolean?)
	local v21 = supply() -- inferred equivalent call
	local visible = TouchControls.active()

	if visible ~= v20 then
		v20 = visible
		seatTray()
	end

	for k, v22 in v15 do
		local on = k == v4
		local up = upOf(v22.bp) -- inferred equivalent call
		local v23 = not v22.bp.swaps and v22.bp.limit <= up
		local off = v21 < v22.bp.cost or v23

		if flag2 or on ~= v22.on then
			v22.on = on
			local stroke = v22.stroke
			local color

			if on then
				color = Style.HAZARD
			else
				color = Color3.new(0, 0, 0)
			end

			stroke.Color = color
			v22.stroke.Thickness = on and 2 or 1.5
			v22.stroke.Transparency = on and 0 or 0.35
			v22.button.BackgroundTransparency = on and 0.05 or Style.PANEL_ALPHA
		end

		if flag2 or off ~= v22.off then
			v22.off = off
			local paint = v22.paint
			local v24 = if off then Style.MUTED else Style.WHITE
			paint(v24)
			local name = v22.name
			local textColor = if off then Style.MUTED else Style.WHITE
			name.TextColor3 = textColor
		end

		if not (flag2 or up ~= v22.up or v21 ~= v19) then
			continue
		end

		v22.up = up
		v22.count.Text = string.format("%d/%d", up, v22.bp.limit)
		local count = v22.count
		local textColor

		if v22.bp.limit <= up then
			textColor = Style.ORANGE
		else
			textColor = Style.WHITE
		end

		count.TextColor3 = textColor
		local cost = v22.cost
		local textColor2

		if v21 < v22.bp.cost then
			textColor2 = Style.ORANGE
		else
			textColor2 = Style.HAZARD
		end

		cost.TextColor3 = textColor2
	end

	v19 = v21

	if visible then
		visible = upOf(v5) > 0 -- inferred equivalent call
	end

	if v17.Visible ~= visible then
		v17.Visible = visible
	end
end

local function ensureUi() -- 2 equivalent calls inferred from this helper
	if v7 then
		return
	end

	buildHint()
	buildTray()

	v2:ownGui(v7)
	v2:ownGui(v16)
	paintTray(true)
end

local color = Color3.fromRGB(120, 214, 96)
local color2 = Color3.fromRGB(230, 70, 50)

local function ghostPart(name: string, turretGhost) -- 5 equivalent calls inferred from this helper
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Material = Enum.Material.SmoothPlastic
	part.Transparency = 0.55
	part.Parent = turretGhost
	return part
end

local turretGhost = Instance.new("Folder")
turretGhost.Name = "TurretGhost"
local part2 = ghostPart("Foot", turretGhost) -- inferred equivalent call
local part3 = ghostPart("Body", turretGhost) -- inferred equivalent call
local part4 = ghostPart("BodyFront", turretGhost) -- inferred equivalent call
local part5 = ghostPart("BodyBack", turretGhost) -- inferred equivalent call
local part6 = ghostPart("Ring", turretGhost) -- inferred equivalent call
local v21 = TurretHead.build("Head", Color3.new(1, 1, 1), true)

for _, child in v21.model:GetChildren() do
	child.Transparency = 0.55
end

v21.model.Parent = turretGhost
local v22 = TurretHead.build("FlakHead", Color3.new(1, 1, 1), true, true)

for _, child in v22.model:GetChildren() do
	child.Transparency = 0.55
end

v22.model.Parent = turretGhost
local parts = {}

for _, part in turretGhost:GetDescendants() do
	if part:IsA("BasePart") then
		table.insert(parts, part)
	end
end

local v23 = {}
local v24 = {}

local buildGhost = Instance.new("Folder")
buildGhost.Name = "BuildGhost"
local v25 = {}
local v26 = 0
local count = 0
local function nextBox() -- 4 equivalent calls inferred from this helper
	count += 1
	local v27 = v25[count]

	if v27 then
		return v27
	end

	local name = "Box" .. count
	v27 = Instance.new("Part")
	v27.Name = name
	v27.Anchored = true
	v27.CanCollide = false
	v27.CanQuery = false
	v27.CanTouch = false
	v27.CastShadow = false
	v27.Material = Enum.Material.SmoothPlastic
	v27.Transparency = 0.55
	v27.Parent = nil

	v25[count] = v27

	return v27
end

local function endBoxes(color3: Color3)
	for i = 1, count do
		local v27 = v25[i]
		v27.Color = color3

		if v27.Parent ~= buildGhost then
			v27.Parent = buildGhost
		end
	end

	for i = count + 1, v26 do
		v25[i].Parent = nil
	end

	v26 = count
end

local v27 = {}
local function boxesOf(data)
	local v28 = v27[data.id]

	if v28 then
		return v28
	end

	local result = {}
	local function runs(i: number, p: number, p2: number, p3: number, brace: boolean)
		local r0 = nil

		for j = 0, data.rows do
			local v29

			if j < data.rows then
				v29 = Barrier.cellAt(data, i, j, p) ~= nil
			else
				v29 = false
			end

			if v29 and not r0 then
				r0 = j
			elseif not v29 and r0 then
				table.insert(result, {
					i = i,
					v0 = p2,
					v1 = p3,
					r0 = r0,
					r1 = j - 1,
					brace = brace
				})
				r0 = nil
			end
		end
	end

	for i = -data.half, data.half - 1 do
		runs(i, 0, -1, 1, false)
		runs(i, -2, -2, -1, true)
		runs(i, -3, -3, -2, true)
	end

	v27[data.id] = result
	return result
end

local function turnedBox(p, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number, p8: number, p9: number, p10: number)
	local axes, v28 = Barrier.axes(p4)
	local midpoint = (p5 + p6) / 2
	local midpoint2 = (p7 + p8) / 2
	local v29 = p2 + axes.X * midpoint + v28.X * midpoint2
	local v30 = p3 + axes.Y * midpoint + v28.Y * midpoint2
	local v31 = v.Y + p9 * VOXEL_SIZE
	local v32 = v.Y + (p10 + 1) * VOXEL_SIZE
	p.Size = newVector3((p6 - p5) * VOXEL_SIZE, v32 - v31, (p8 - p7) * VOXEL_SIZE)
	p.CFrame = CFrame.new(v.X + v29 * VOXEL_SIZE, (v31 + v32) / 2, v.Z + v30 * VOXEL_SIZE) * CFrame.fromEulerAnglesYXZ(0, p4, 0)
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.IgnoreWater = true
raycastParams.FilterDescendantsInstances = { workspace.Terrain }

local function firstHit(origin: Vector3, vector3: Vector3, p: number)
	local v28 = nil
	local v29 = nil

	local world = ClientWorld.world
	local v30

	if world then
		local v31, v32, _
		v31, v32, _, v30 = VoxelCore.raycast(world, origin, vector3, p)

		if v31 then
			v29 = v32
			v28 = v31
		else
			v30 = p
		end
	else
		v30 = p
	end

	local raycastResult = workspace:Raycast(origin, vector3 * p, raycastParams)

	if raycastResult and raycastResult.Distance < v30 then
		v28 = raycastResult.Position
		v29 = raycastResult.Normal
	end

	return v28, v29
end

local function headPos() -- 4 equivalent calls inferred from this helper
	local character = LocalPlayer.Character
	local head = character and character:FindFirstChild("Head")

	if head and head:IsA("BasePart") then
		return head.Position
	end

	return workspace.CurrentCamera.CFrame.Position
end

local function dropTo(vector3: Vector3, p: number)
	return firstHit(vector3 + newVector3(0, p, 0), Vector3.new(0, -1, 0), 60) or vector3
end

local function aimSpot(BUILD_RANGE: number)
	local currentCamera = workspace.CurrentCamera
	local viewportSize = currentCamera.ViewportSize
	local ray = VR.ray(currentCamera, viewportSize.X * 0.5, viewportSize.Y * 0.5)
	local unit = ray.Direction.Unit
	local v28 = headPos() -- inferred equivalent call
	local v29, v30 = firstHit(ray.Origin, unit, BUILD_RANGE + 40)
	local v31 = BUILD_RANGE - 1

	if v29 and (v29 - v28).Magnitude <= v31 then
		if v30 and math.abs(v30.Y) < 0.5 then
			return v29, newVector3(v30.X, 0, v30.Z).Unit, v29
		end

		return v29, nil, nil
	else
		local vector3 = newVector3(unit.X, 0, unit.Z)

		if vector3.Magnitude < 0.05 then
			return v29, nil, nil
		end

		local unit2 = vector3.Unit

		local v32 = v31 * math.max(0.35, (math.sqrt((math.max(0, 1 - unit.Y * unit.Y)))))

		if v29 then
			local v40 = v29.X - v28.X
			local v41 = v29.Z - v28.Z
			v32 = math.min(v32, newVector3(v40, 0, v41).Magnitude)
		end

		local vector3_2 = newVector3(v28.X + unit2.X * v32, v28.Y, v28.Z + unit2.Z * v32)
		return firstHit(vector3_2 + Vector3.new(0, 1.5, 0), Vector3.new(0, -1, 0), 60) or vector3_2, nil, nil
	end
end

local v28 = nil
local v29 = 0
local v30 = false
local v31 = ""

local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include

local function hullIn(cframe: CFrame, vector3: Vector3): boolean
	local vehicleHulls = workspace:FindFirstChild("VehicleHulls")

	if not vehicleHulls then
		return false
	end

	overlapParams.FilterDescendantsInstances = { vehicleHulls }
	return #workspace:GetPartBoundsInBox(cframe, vector3, overlapParams) > 0
end

local function commonWhy(vector3: Vector3, p: number)
	if p < (vector3 - headPos()).Magnitude then -- inferred equivalent call
		return "TOO FAR AWAY"
	end

	if not v5.swaps and upOf(v5) >= v5.limit then -- inferred equivalent call
		return fullText(v5) -- inferred equivalent call
	end

	if supply() < v5.cost then -- inferred equivalent call
		return "NOT ENOUGH SUPPLY"
	end

	return nil
end

local function getter(world) -- 2 equivalent calls inferred from this helper
	return function(p: number, p2: number, p3: number)
		return VoxelCore.get(world, p, p2, p3)
	end
end

local function lookYaw() -- 2 equivalent calls inferred from this helper
	return Turret.angles(workspace.CurrentCamera.CFrame.LookVector) + v6 * Barrier.YAW_STEP
end

local function placeTurretGhost()
	local v32, v40 = aimSpot(Turret.BUILD_RANGE)
	local world = ClientWorld.world

	if v32 and v40 then
		v32 += v40 * (Turret.FOOT_HALF * VOXEL_SIZE + 0.01)
	end

	if v32 and world then
		local v41 = lookYaw() -- inferred equivalent call
		local corner, v42 = Turret.corner(v32, VOXEL_SIZE, v)
		local v43 = getter(world) -- inferred equivalent call
		local surface = GroundHeight.surface(v32, VOXEL_SIZE, v, v43)
		local plan, _, v44, v45 = Turret.plan(corner, v42, v43, surface)
		local span, v46 = Turret.span(corner, v42, v43, surface)
		local v47 = v44 or v46
		local v48 = v.Y + (v47 + 0.5) * VOXEL_SIZE
		local v49 = plan ~= nil
		local v50 = v45 or ""

		if v49 and math.abs(v32.Y - v48) > 5 then
			v49 = false
			v50 = "AIM AT THE FLOOR"
		elseif v49 then
			local BUILD_RANGE = Turret.BUILD_RANGE
			local v51 = headPos() -- inferred equivalent call
			local v52

			if BUILD_RANGE < (v32 - v51).Magnitude then
				v52 = "TOO FAR AWAY"
			else
				local supply2

				if v5.swaps then
					supply2 = LocalPlayer:GetAttribute("Supply")
					v52 = (type(supply2) ~= "number" and 0 or supply2) < v5.cost and "NOT ENOUGH SUPPLY" or nil
				elseif upOf(v5) >= v5.limit then -- inferred equivalent call
					v52 = fullText(v5) -- inferred equivalent call
				else
					supply2 = LocalPlayer:GetAttribute("Supply")
					v52 = (type(supply2) ~= "number" and 0 or supply2) < v5.cost and "NOT ENOUGH SUPPLY" or nil
				end
			end

			if v52 then
				v50 = v52
				v49 = false
			else
				local pivot = Turret.pivot(corner, v42, v47, VOXEL_SIZE, v)
				local v53 = Turret.FOOT_HALF * VOXEL_SIZE + 1 + 1.5
				local v54 = pivot.Y + 1.5 + 1.5
				local v55 = v48 - 1.5

				if hullIn(CFrame.new(pivot.X, (v55 + v54) / 2, pivot.Z), newVector3(v53 * 2, v54 - v55, v53 * 2)) then
					v49 = false
					v50 = "A VEHICLE IS IN THE WAY"
				end
			end
		end

		v28 = v32
		v29 = v41
		v30 = v49
		v31 = v50

		local center, v51 = Turret.center(corner, v42, VOXEL_SIZE, v)
		local v52 = v.Y + v47 * VOXEL_SIZE
		local function slab(p, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number)
			local v53 = v52 + p6 * VOXEL_SIZE
			local v54 = v52 + (p7 + 1) * VOXEL_SIZE
			p.Size = newVector3((p3 - p2) * VOXEL_SIZE, v54 - v53, (p5 - p4) * VOXEL_SIZE)
			p.CFrame = CFrame.new(
				center + (p2 + p3) * 0.5 * VOXEL_SIZE,
				(v53 + v54) / 2,
				v51 + (p4 + p5) * 0.5 * VOXEL_SIZE
			)
		end
		local FOOT_HALF = Turret.FOOT_HALF
		local BODY_HALF = Turret.BODY_HALF
		local RING_HALF = Turret.RING_HALF
		local v53 = Turret.BODY_ROWS[1]
		local v54 = Turret.BODY_ROWS[2]
		slab(part2, -FOOT_HALF, FOOT_HALF, -FOOT_HALF, FOOT_HALF, span - v47, Turret.FOOT_TOP)
		slab(part3, -BODY_HALF, BODY_HALF, -BODY_HALF + 1, BODY_HALF - 1, v53, v54)
		slab(part4, -BODY_HALF + 1, BODY_HALF - 1, -BODY_HALF, -BODY_HALF + 1, v53, v54)
		slab(part5, -BODY_HALF + 1, BODY_HALF - 1, BODY_HALF - 1, BODY_HALF, v53, v54)
		slab(part6, -RING_HALF, RING_HALF, -RING_HALF, RING_HALF, Turret.RING_ROWS[1], Turret.RING_ROWS[2])
		table.clear(v23)
		table.clear(v24)
		local v55 = v5.id == Turret.FLAK.ID
		local model = v21.model
		local parent4

		if not v55 then
			parent4 = turretGhost
		end

		model.Parent = parent4
		local model2 = v22.model
		local parent5

		if v55 then
			parent5 = turretGhost
		end

		model2.Parent = parent5
		local pose = TurretHead.pose
		local v58 = if v55 then v22 else v21
		local pivot = Turret.pivot(corner, v42, v47, VOXEL_SIZE, v)
		local v59

		if v55 then
			v59 = Turret.FLAK.IDLE_PITCH
		else
			v59 = Turret.IDLE_PITCH
		end

		pose(v58, pivot, v41, math.rad(v59), 0, 0, v23, v24)
		workspace:BulkMoveTo(v23, v24, Enum.BulkMoveMode.FireCFrameChanged)
		local color3 = if v49 then color else color2

		for _, v61 in parts do
			v61.Color = color3
		end

		turretGhost.Parent = workspace
	else
		v28 = nil
		v30 = false
		v31 = "AIM AT THE GROUND"
		turretGhost.Parent = nil
	end
end

local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local child = ReplicatedStorage3:WaitForChild(Barrier.FOLDER, 30)
assert(child, "BuildClient: ReplicatedStorage." .. Barrier.FOLDER .. " is missing (Game.Barriers)")
local v32 = {}
local function coverRecords()
	local result = {}

	for _, child2 in child:GetChildren() do
		local v40 = v32[child2]

		if not v40 then
			local cx = child2:GetAttribute("Cx")
			local cz = child2:GetAttribute("Cz")
			local yaw = child2:GetAttribute("Yaw")
			local tops = child2:GetAttribute("Tops")

			if type(cx) == "number" and type(cz) == "number" and type(yaw) == "number" and type(tops) == "string" then
				v40 = { cx = cx, cz = cz, yaw = yaw, tops = Barrier.decodeTops(tops) }
				v32[child2] = v40
				child2.Destroying:Once(function()
					v32[child2] = nil
				end)
			end
		end

		if v40 then
			table.insert(result, v40)
		end
	end

	return result
end

local v40 = ""
local v41 = 0

local function placePieceGhost(kind)
	local v42, v43, v44 = aimSpot(Barrier.BUILD_RANGE)
	local world = ClientWorld.world

	if v42 and world then
		local v45 = Barrier.snapYaw(lookYaw()) -- inferred equivalent call

		if v43 and v44 then
			if kind.ramp then
				v45 = Barrier.snapYaw((Turret.angles(-v43)))
				local _, v46 = Barrier.axes(v45)
				local v47 = kind.v1 * VOXEL_SIZE + 0.05
				local vector3 = newVector3(v44.X - v46.X * v47, v44.Y, v44.Z - v46.Y * v47)
				v42 = firstHit(vector3 + Vector3.new(0, 1, 0), Vector3.new(0, -1, 0), 60) or vector3
			else
				v42 += v43 * (VOXEL_SIZE + 0.01)
			end
		end

		local v46, v47 = Barrier.centerOf(v42, VOXEL_SIZE, v)
		local v48 = string.format(
			"%s|%.1f|%.1f|%d|%d",
			kind.id,
			v46,
			v47,
			math.round(v45 / Barrier.YAW_STEP),
			(math.floor(v42.Y / VOXEL_SIZE))
		)
		local now = os.clock()

		if v48 == v40 and now - v41 < 0.2 then
			v28 = v42
			return
		end

		v40 = v48
		v41 = now
		local v49

		if kind.stacks then
			v49 = Barrier.under(v42, coverRecords(), VOXEL_SIZE, v)
		end

		local tops

		if v49 then
			tops = v49.tops
		end

		if v49 then
			v46 = v49.cx
			v47 = v49.cz
			v45 = v49.yaw
		end

		local v50 = getter(world) -- inferred equivalent call
		local surface = GroundHeight.surface(v42, VOXEL_SIZE, v, v50)
		local footing = Barrier.footing(kind, v46, v47, v45, v50, surface, tops)
		local plan, v51 = Barrier.plan(kind, v46, v47, v45, v50, surface, tops)
		local v52 = plan ~= nil
		local v53 = v51 or ""

		if v52 then
			local BUILD_RANGE = Barrier.BUILD_RANGE
			local v54 = headPos() -- inferred equivalent call
			local v55

			if BUILD_RANGE < (v42 - v54).Magnitude then
				v55 = "TOO FAR AWAY"
			else
				local supply2

				if v5.swaps then
					supply2 = LocalPlayer:GetAttribute("Supply")
					v55 = (type(supply2) ~= "number" and 0 or supply2) < v5.cost and "NOT ENOUGH SUPPLY" or nil
				elseif upOf(v5) >= v5.limit then -- inferred equivalent call
					v55 = fullText(v5) -- inferred equivalent call
				else
					supply2 = LocalPlayer:GetAttribute("Supply")
					v55 = (type(supply2) ~= "number" and 0 or supply2) < v5.cost and "NOT ENOUGH SUPPLY" or nil
				end
			end

			if v55 then
				v53 = v55
				v52 = false
			else
				local cframe, v56 = Barrier.frame(kind, v46, v47, v45, footing, VOXEL_SIZE, v)
				local humanoidRootPart = LocalPlayer.Character
					and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				local v57

				if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
					v57 = cframe:PointToObjectSpace(humanoidRootPart.Position)
				end

				if
					v57
					and math.abs(v57.X) < v56.X / 2 + 0.6
					and math.abs(v57.Z) < v56.Z / 2 + 0.6
					and math.abs(v57.Y) < v56.Y / 2 + 2.5
				then
					v52 = false
					v53 = "SOMEONE IS STANDING THERE"
				elseif hullIn(cframe, v56 + Vector3.new(2, 0, 2)) then
					v52 = false
					v53 = "A VEHICLE IS IN THE WAY"
				end
			end
		end

		v28 = v42
		v29 = v45
		v30 = v52
		v31 = v53

		count = 0
		local half = kind.half

		if kind.ramp then
			local v54 = footing.bases[1]

			if footing.lo < v54 then
				turnedBox(nextBox(), v46, v47, v45, -half, half, kind.v0, kind.v1, footing.lo, v54 - 1) -- inferred equivalent call
			end

			local RAMP_RISE = Barrier.RAMP_RISE

			for i = 0, kind.rows - 1 do
				local v55 = kind.v0 + i * RAMP_RISE
				local v56

				if i == kind.rows - 1 then
					v56 = kind.v1
				else
					v56 = v55 + RAMP_RISE
				end

				turnedBox(nextBox(), v46, v47, v45, -half, half, v55, v56, v54, v54 + i) -- inferred equivalent call
			end
		else
			for _, v54 in boxesOf(kind) do
				if tops and v54.brace then
					continue
				end

				local v55 = footing.bases[v54.i + half + 1]
				turnedBox(nextBox(), v46, v47, v45, v54.i, v54.i + 1, v54.v0, v54.v1, v55 + v54.r0, v55 + v54.r1) -- inferred equivalent call
			end

			for i = 1, 2 * half do
				local v54 = footing.bases[i]
				local low = footing.lows[i]

				if low < v54 then
					turnedBox(nextBox(), v46, v47, v45, i - half - 1, i - half, -1, 1, low, v54 - 1) -- inferred equivalent call
				end
			end
		end

		local v54 = if v52 then color else color2
		endBoxes(v54)
		buildGhost.Parent = workspace
	else
		v28 = nil
		v30 = false
		v31 = "AIM AT THE GROUND"
		buildGhost.Parent = nil
		v40 = ""
	end
end

local function hideGhosts() -- 3 equivalent calls inferred from this helper
	turretGhost.Parent = nil
	buildGhost.Parent = nil
	v40 = ""
	v28 = nil
end

fn = function(buildPick2: number)
	if not v3[buildPick2] or buildPick2 == v4 then
		return
	end

	v4 = buildPick2
	v5 = v3[buildPick2]
	v6 = 0
	LocalPlayer:SetAttribute("BuildPick", buildPick2)
	hideGhosts() -- inferred equivalent call
	knock() -- inferred equivalent call
	VoxelSound.click(workspace.CurrentCamera.CFrame.Position, 0.5, 0.4)

	if v16 then
		paintTray()
	end
end

local function cycle(p: number) -- 2 equivalent calls inferred from this helper
	fn((v4 - 1 + p) % #v3 + 1)
end

local function rotate() -- 1 equivalent call inferred from this helper
	v6 = (v6 + 1) % 8
	v40 = ""
	VoxelSound.click(workspace.CurrentCamera.CFrame.Position, 0.4, 0.3)
end

fn2 = function()
	if flag then
		return
	end

	if upOf(v5) <= 0 then -- inferred equivalent call
		flash("NOTHING TO TEAR DOWN", Style.ORANGE) -- inferred equivalent call
	else
		flag = true
		local v42, v43 = build:InvokeServer("dismantle", v5.id)
		flag = false
		local v44 = if v42 then Style.GOOD else Style.ORANGE
		flash(v43, v44) -- inferred equivalent call
		v40 = ""
	end
end

local function place()
	if flag then
		return
	end

	if v28 and v30 then
		flag = true
		knock() -- inferred equivalent call
		local v42, v43 = build:InvokeServer("build", v5.id, v28, v29)
		flag = false
		v40 = ""

		if v42 then
			VoxelSound.click(workspace.CurrentCamera.CFrame.Position, 0.8, 0.6)

			if v43 ~= "" then
				flash(v43, Style.GOOD) -- inferred equivalent call
			end
		else
			flash(v43, Style.ORANGE) -- inferred equivalent call
		end
	else
		VoxelSound.click(workspace.CurrentCamera.CFrame.Position, 0.3, 0.1)
		flash(v31 == "" and "CAN'T BUILD HERE" or v31, Style.ORANGE) -- inferred equivalent call
	end
end

local lastTime2 = 0
local function primary()
	if not v2.active or os.clock() - lastTime2 < 0.25 then
		return
	end

	place()
end

local function step(_: number)
	if v2.active then
		local v42 = (os.clock() - lastTime) / 0.26

		if v42 >= 0 and v42 < 1 then
			local v43 = math.sin(v42 * 3.141592653589793)
			v2.pose = CFrame.new(0, v43 * -0.06, v43 * -0.1) * CFrame.Angles(v43 * -0.5585053606381855, 0, 0)
		else
			v2.pose = CFrame.identity
		end

		if v5.kind then
			turretGhost.Parent = nil
			placePieceGhost(v5.kind)
		else
			buildGhost.Parent = nil
			placeTurretGhost()
		end

		ensureUi() -- inferred equivalent call
		local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
		local v43 = v7
		local v44 = v16

		if v43.Parent ~= playerGui then
			v43.Parent = playerGui
		end

		if v44.Parent ~= playerGui then
			v44.Parent = playerGui
		end

		paintTray()

		if os.clock() < v13 then
			setHint(v11, v12) -- inferred equivalent call
		elseif v30 then
			setHint(TouchControls.active() and "BUILD TO PLACE" or "CLICK TO PLACE", Style.GOOD) -- inferred equivalent call
		else
			setHint(v31, Style.ORANGE) -- inferred equivalent call
		end
	else
		hideGhosts() -- inferred equivalent call

		if v16 then
			v16.Parent = nil
		end

		if v7 then
			v7.Parent = nil
		end
	end
end

local renderSteppedConnection = nil

local inputBeganConnection = nil
local function onInput(p, flag2: boolean)
	if not v2.active or flag2 then
		return
	end

	local keyCode = p.KeyCode

	if keyCode == Enum.KeyCode.Q or keyCode == Enum.KeyCode.DPadRight then
		cycle(1) -- inferred equivalent call
	elseif keyCode == Enum.KeyCode.DPadLeft then
		cycle(-1) -- inferred equivalent call
	elseif keyCode == Enum.KeyCode.R then
		rotate() -- inferred equivalent call
	elseif keyCode == Enum.KeyCode.X or keyCode == Enum.KeyCode.DPadDown then
		task.spawn(fn2)
	end
end
local flag2 = false
parent.Equipped:Connect(function()
	if flag2 then
		return
	end

	lastTime2 = os.clock()
	ensureUi() -- inferred equivalent call

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
	end

	renderSteppedConnection = RunService.RenderStepped:Connect(step)

	if not inputBeganConnection then
		inputBeganConnection = UserInputService.InputBegan:Connect(onInput)
	end
end)

local function putAway() -- 3 equivalent calls inferred from this helper
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	if inputBeganConnection then
		inputBeganConnection:Disconnect()
		inputBeganConnection = nil
	end

	hideGhosts() -- inferred equivalent call
	v2.pose = CFrame.identity

	if v7 then
		v7.Parent = nil
	end

	if v16 then
		v16.Parent = nil
	end
end
parent.Unequipped:Connect(putAway)

local function cleanup()
	if flag2 then
		return
	end

	flag2 = true
	putAway() -- inferred equivalent call
	turretGhost:Destroy()
	buildGhost:Destroy()

	for _, v42 in v25 do
		v42:Destroy()
	end

	if v7 then
		v7:Destroy()
	end

	if v16 then
		v16:Destroy()
	end
end
parent.Destroying:Connect(cleanup)
script.Destroying:Connect(cleanup)
parent.AncestryChanged:Connect(function()
	if not parent:IsDescendantOf(game) then
		putAway() -- inferred equivalent call
	end
end)

LocalPlayer.CharacterRemoving:Connect(function(character)
	if parent.Parent == character or parent.Parent == LocalPlayer:FindFirstChildOfClass("Backpack") then
		putAway() -- inferred equivalent call
	end
end)

parent.Activated:Connect(primary)

TouchControls.register(parent, { label = "BUILD", startFire = primary, reload = rotate })