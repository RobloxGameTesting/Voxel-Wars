local Turret = require(script.Parent:WaitForChild("Turret"))

local TurretHead = {
	["BODY"] = Color3.fromRGB(88, 96, 72),
	STEEL = Color3.fromRGB(52, 56, 62),
	BLACK = Color3.fromRGB(28, 28, 30),
	LAMP_ON = Color3.fromRGB(255, 70, 50),
	LAMP_OFF = Color3.fromRGB(70, 30, 26)
}

function TurretHead.build(name: string, color: Color3, flag: boolean, flag2: boolean?)
	local model = Instance.new("Model")
	model.Name = name
	local pieces = {}
	local function block(name2: string, size: Vector3, color2: Color3, offset: CFrame, on: string, flag3: boolean?)
		local part = Instance.new("Part")
		part.Name = name2
		part.Size = size
		part.Color = color2
		local material

		if flag3 and not flag then
			material = Enum.Material.Neon
		else
			material = Enum.Material.SmoothPlastic
		end

		part.Material = material
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = not flag
		part.Parent = model
		table.insert(pieces, { part = part, offset = offset, on = on })
		return part
	end

	local newCFrame = CFrame.new
	local _newVector3 = Vector3.new
	local v = -Turret.PIVOT_UP

	block("Turntable", Vector3.new(2.1, 0.32, 2.1), TurretHead.STEEL, newCFrame(0, v + 0.14, 0), "yoke")
	block("CheekL", Vector3.new(0.3, 1.45, 1.1), TurretHead.STEEL, newCFrame(-0.95, -0.375, 0.05), "yoke")
	block("CheekR", Vector3.new(0.3, 1.45, 1.1), TurretHead.STEEL, newCFrame(0.95, -0.375, 0.05), "yoke")

	block("Housing", Vector3.new(1.5, 0.9, 1.6), TurretHead.BODY, newCFrame(0, 0, 0.1), "cradle")
	block("Band", Vector3.new(1.56, 0.2, 1.64), color, newCFrame(0, 0.12, 0.1), "cradle")
	block("Roof", Vector3.new(1.56, 0.2, 1.3), TurretHead.BODY, newCFrame(0, 0.53, 0.15), "cradle")
	block("Mantlet", Vector3.new(1.56, 0.8, 0.25), TurretHead.STEEL, newCFrame(0, 0, -0.75), "cradle")
	block("Sight", Vector3.new(0.36, 0.34, 0.55), TurretHead.STEEL, newCFrame(0.45, 0.76, -0.15), "cradle")
	local lamp = block(
		"Lamp",
		Vector3.new(0.2, 0.2, 0.08),
		TurretHead.LAMP_OFF,
		newCFrame(0.45, 0.76, -0.46),
		"cradle",
		true
	)

	for _, v2 in { -1, 1 } do
		local v3 = v2 < 0 and "gunL" or "gunR"
		local v4 = v2 * Turret.BARREL_X
		block("Shroud", Vector3.new(0.34, 0.34, 0.7), TurretHead.STEEL, newCFrame(v4, 0, -1.15), v3)

		if flag2 then
			block("Barrel", Vector3.new(0.2, 0.2, 2.5), TurretHead.BLACK, newCFrame(v4, 0, -2.1), v3)
			block("Brake", Vector3.new(0.34, 0.34, 0.4), TurretHead.STEEL, newCFrame(v4, 0, -3.2), v3)
			block("Drum", Vector3.new(0.36, 0.3, 0.6), TurretHead.BODY, newCFrame(v2 * 0.42, 0.78, 0.45), "cradle")
		else
			block("Barrel", Vector3.new(0.2, 0.2, 1.84), TurretHead.BLACK, newCFrame(v4, 0, -1.77), v3)
			block("Brake", Vector3.new(0.3, 0.3, 0.24), TurretHead.STEEL, newCFrame(v4, 0, -2.6), v3)
		end
	end

	if flag2 then
		block("Mast", Vector3.new(0.12, 0.5, 0.12), TurretHead.STEEL, newCFrame(0, 0.85, 0.4), "cradle")
		block("Dish", Vector3.new(0.7, 0.42, 0.08), TurretHead.STEEL, newCFrame(0, 1.2, 0.4), "cradle")
	end

	local v2 = {
		model = model,
		pieces = pieces,
		lamp = lamp,
		flashL = nil,
		flashR = nil
	}

	if flag then
		return v2
	end

	local function flash(p: number)
		local color2 = Color3.fromRGB(255, 214, 140)
		local v3 = if flag2 then Turret.FLAK.MUZZLE else Turret.MUZZLE
		local parent = block(
			"Flash",
			Vector3.new(0.42, 0.42, 0.55),
			color2,
			newCFrame(p, 0, -v3 - 0.2),
			p < 0 and "gunL" or "gunR",
			true
		)
		parent.Transparency = 1
		parent.CastShadow = false
		local pointLight = Instance.new("PointLight")
		pointLight.Color = Color3.fromRGB(255, 196, 120)
		pointLight.Range = 10
		pointLight.Brightness = 3
		pointLight.Enabled = false
		pointLight.Parent = parent
		return parent
	end

	local flashL = flash(-Turret.BARREL_X)
	local flashR = flash(Turret.BARREL_X)
	v2.flashL = flashL
	v2.flashR = flashR

	return v2
end

function TurretHead.pose(p, position: Vector3, p2: number, p3: number, p4: number, p5: number, parts, list)
	local v = CFrame.new(position) * CFrame.Angles(0, p2, 0)
	local v2 = v * CFrame.Angles(p3, 0, 0)
	local v3 = v2 * CFrame.new(0, 0, p4)
	local v4 = v2 * CFrame.new(0, 0, p5)

	for _, piece in p.pieces do
		local v5

		if piece.on == "yoke" then
			v5 = v
		elseif piece.on == "cradle" then
			v5 = v2
		else
			v5 = if piece.on == "gunL" then v3 else v4
		end

		table.insert(parts, piece.part)
		table.insert(list, v5 * piece.offset)
	end
end

return TurretHead