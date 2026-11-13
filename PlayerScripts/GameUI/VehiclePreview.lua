local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VoxelCore = require(ReplicatedStorage.Voxel:WaitForChild("VoxelCore"))
local Materials = require(ReplicatedStorage.Voxel:WaitForChild("Materials"))
local WorldConfig = require(ReplicatedStorage.Voxel:WaitForChild("WorldConfig"))

local VOXEL_SIZE = WorldConfig.VOXEL_SIZE
local Palette = Materials.Palette
local unit = (Vector3.new(-0.75, 0.3, -0.75)).Unit

local v = {
	Jet = "JetModel",
	StealthHeli = "StealthHeliModel",
	Heli = "HeliModel",
	Tank = "TankModel",
	Bradley = "BradleyModel",
	Humvee = "HumveeModel"
}

local v2 = { Bomber = "BomberMesh" }

local v3 = { Bomber = 0.95 }
local v4 = { Bomber = 1.55 }
local v5 = {
	"body",
	"mainRotor",
	"tailRotor",
	"light",
	"arms",
	"gearNose",
	"gearRight",
	"gearLeft"
}

local VehiclePreview = {}

local function draw(parent, buf: buffer, p: number, p2: number, p3: number, vector3: Vector3)
	local v6 = {}

	for i = 0, VoxelCore.greedy(buf, p, p2, p3, buffer.create(p * p2 * p3), v6) - 1 do
		local v7 = i * 7
		local v8 = v6[v7 + 1]
		local v9 = v6[v7 + 2]
		local v10 = v6[v7 + 3]
		local v11 = v6[v7 + 4]
		local v12 = v6[v7 + 5]
		local v13 = v6[v7 + 6]
		local v14 = Palette[v6[v7 + 7]]
		local part = Instance.new("Part")
		part.Anchored = true
		part.Size = Vector3.new(v11, v12, v13) * VOXEL_SIZE
		part.CFrame = CFrame.new(vector3 + Vector3.new(v8 + v11 * 0.5, v9 + v12 * 0.5, v10 + v13 * 0.5) * VOXEL_SIZE)
		part.Color = v14.color
		part.Material = v14.material
		part.MaterialVariant = v14.variant
		part.Transparency = v14.transparency
		local smooth = Enum.SurfaceType.Smooth
		local smooth2 = Enum.SurfaceType.Smooth
		part.TopSurface = smooth
		part.BottomSurface = smooth2
		part.Parent = parent
	end
end

local function fromCells(model, list, x: number, y: number, z: number, vector3: Vector3)
	local buf = buffer.create(x * y * z)

	for i = 1, #list, 4 do
		buffer.writeu8(buf, list[i] + x * (list[i + 1] + y * list[i + 2]), list[i + 3])
	end

	draw(model, buf, x, y, z, vector3)
end

function VehiclePreview.model(name: string)
	local v6 = v2[name]

	if v6 then
		local clone = ReplicatedStorage.Vehicles:WaitForChild(v6):Clone()
		clone.Name = name

		for _, part in clone:GetDescendants() do
			if part:IsA("BasePart") then
				part.Anchored = true
			end
		end

		return clone
	else
		local v7 = v[name]
		assert(v7, "[VehiclePreview] no vehicle " .. name)
		local module = require(ReplicatedStorage.Vehicles:WaitForChild(v7))
		local model = Instance.new("Model")
		model.Name = name
		local pieces = module.PIECES

		if pieces then
			local cellsOf = module.cellsOf

			for _, v8 in v5 do
				local piece = pieces[v8]

				if piece then
					fromCells(model, cellsOf(v8), piece.counts.X, piece.counts.Y, piece.counts.Z, piece.at + piece.lo)
				end
			end

			return model
		else
			draw(model, module.data, module.sx, module.sy, module.sz, module.origin)
			local wheelGrid = module.wheelGrid

			if wheelGrid then
				local v8 = Vector3.new(wheelGrid.X, wheelGrid.Y, wheelGrid.Z) * (VOXEL_SIZE * 0.5)

				for _, wheel in module.wheels do
					fromCells(
						model,
						module.wheelCells,
						wheelGrid.X,
						wheelGrid.Y,
						wheelGrid.Z,
						wheel.mount - Vector3.new(0, wheel.travel * 0.5, 0) - v8
					)
				end
			end

			local turret = module.turret

			if turret then
				fromCells(
					model,
					turret.cells,
					turret.grid.X,
					turret.grid.Y,
					turret.grid.Z,
					turret.pivot + turret.origin
				)
				local gun = module.gun
				fromCells(
					model,
					gun.cells,
					gun.grid.X,
					gun.grid.Y,
					gun.grid.Z,
					turret.pivot + gun.trunnion + gun.origin
				)
			end

			return model
		end
	end
end

function VehiclePreview.view(parent, p: string, p2: number, flag: boolean?)
	local vehicle = Instance.new("ViewportFrame")
	vehicle.Name = "Vehicle"
	vehicle:SetAttribute("Zoom", p2 * (v4[p] or 1))

	if not flag then
		p2 = nil
	end

	vehicle:SetAttribute("Fit", p2)
	vehicle:SetAttribute("Rise", v3[p])
	vehicle.BackgroundTransparency = 1
	vehicle.Size = UDim2.fromScale(1, 1)
	vehicle.Ambient = Color3.fromRGB(175, 175, 185)
	vehicle.LightColor = Color3.new(1, 1, 1)
	vehicle.LightDirection = Vector3.new(-1, -1.5, -0.5)
	local model = VehiclePreview.model(p)
	model.Parent = vehicle
	local camera = Instance.new("Camera")
	camera.FieldOfView = 22
	camera.Parent = vehicle
	vehicle.CurrentCamera = camera
	vehicle.Parent = parent
	VehiclePreview.turn(vehicle, 0)
	return vehicle
end

function VehiclePreview.turn(instance, p: number)
	local model = instance:FindFirstChildOfClass("Model")
	local currentCamera = instance.CurrentCamera
	assert(model and currentCamera, "[VehiclePreview] not a vehicle view")
	local boundingBox, v6 = model:GetBoundingBox()
	local rise = instance:GetAttribute("Rise")
	local cframe = CFrame.Angles(0, p, 0)
	local v7

	if type(rise) == "number" then
		v7 = Vector3.new(unit.X, rise, unit.Z).Unit
	else
		v7 = unit
	end

	local vectorToWorldSpace = cframe:VectorToWorldSpace(v7)
	local fit = instance:GetAttribute("Fit")

	if type(fit) ~= "number" then
		currentCamera.CFrame = CFrame.lookAt(
			boundingBox.Position + vectorToWorldSpace * v6.Magnitude * instance:GetAttribute("Zoom"),
			boundingBox.Position
		)
		return
	end

	local absoluteSize = instance.AbsoluteSize
	local v8 = not (absoluteSize.X > 1 and absoluteSize.Y > 1) and 1.6 or absoluteSize.X / absoluteSize.Y
	local v9 = math.tan(math.rad(currentCamera.FieldOfView) / 2)
	local v10 = v9 * v8

	local reachR = instance:GetAttribute("ReachR")
	local reachY = instance:GetAttribute("ReachY")
	local v11 = math.max(math.sqrt(v6.X * v6.X + v6.Z * v6.Z) / 2, type(reachR) ~= "number" and 0 or reachR)
	local v12 = math.max(v6.Y / 2, type(reachY) ~= "number" and 0 or reachY)
	local v13 = math.clamp(vectorToWorldSpace.Y, 0, 1)
	local v14 = math.sqrt(1 - v13 * v13)
	local v15 = v12 * v14 + v11 * v13
	local v16 = v11 * v14 + v12 * v13
	local v17 = math.max(v11 / v10, v15 / v9) * fit + v16
	currentCamera.CFrame = CFrame.lookAt(boundingBox.Position + vectorToWorldSpace * v17, boundingBox.Position)
end

return VehiclePreview