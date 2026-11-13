local RunwayPaint = {}

RunwayPaint.STRIPS = {
	drywell = {
		{ center = Vector3.new(0, 5.3, -496), length = 900, width = 40 },
		{ center = Vector3.new(0, 5.3, 496), length = 900, width = 40 }
	},
	highcrag = {
		{ center = Vector3.new(0, 6.3, -486), length = 880, width = 40 },
		{ center = Vector3.new(0, 6.3, 486), length = 880, width = 40 }
	}
}

local color = Color3.fromRGB(226, 222, 208)

local function strip(runwayPaint, data, vector3: Vector3)
	local runwayPaint2 = Instance.new("Part")
	runwayPaint2.Name = "RunwayPaint"
	runwayPaint2.Anchored = true
	runwayPaint2.CanCollide = false
	runwayPaint2.CanQuery = false
	runwayPaint2.CanTouch = false
	runwayPaint2.CastShadow = false
	runwayPaint2.Transparency = 1
	runwayPaint2.Size = Vector3.new(data.length, 0.05, data.width)
	runwayPaint2.CFrame = CFrame.new(data.center + vector3)
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Face = Enum.NormalId.Top
	surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surfaceGui.PixelsPerStud = 2
	surfaceGui.LightInfluence = 1
	surfaceGui.Brightness = 1
	surfaceGui.Parent = runwayPaint2

	local function mark(p: number, p2: number, p3: number, p4: number)
		local frame = Instance.new("Frame")
		frame.BorderSizePixel = 0
		frame.BackgroundColor3 = color
		frame.BackgroundTransparency = 0.18
		frame.Position = UDim2.fromOffset((p3 + data.width / 2) * 2, (p + data.length / 2) * 2)
		frame.Size = UDim2.fromOffset((p4 - p3) * 2, (p2 - p) * 2)
		frame.Parent = surfaceGui
	end
	local halfLength = data.length / 2
	local halfWidth = data.width / 2

	mark(-halfLength + 2, halfLength - 2, -halfWidth + 1, -halfWidth + 2)
	mark(-halfLength + 2, halfLength - 2, halfWidth - 2, halfWidth - 1)

	local v = -halfLength + 60

	while v < halfLength - 80 do
		mark(v, v + 20, -0.5, 0.5)
		v += 36
	end

	for _, v2 in { -1, 1 } do
		local v3 = math.min(v2 * (halfLength - 4), v2 * (halfLength - 24))
		local v4 = math.max(v2 * (halfLength - 4), v2 * (halfLength - 24))

		for i = 0, 4 do
			local v5 = i * 3.5 + 3
			mark(v3, v4, v5, v5 + 2)
			mark(v3, v4, -v5 - 2, -v5)
		end

		local v5 = math.min(v2 * (halfLength - 90), v2 * (halfLength - 125))
		local v6 = math.max(v2 * (halfLength - 90), v2 * (halfLength - 125))
		mark(v5, v6, 5, 10)
		mark(v5, v6, -10, -5)
	end

	runwayPaint2.Parent = runwayPaint
end

function RunwayPaint.draw(p: string, parent, vector3: Vector3?)
	local v = RunwayPaint.STRIPS[p]

	if not v then
		return nil
	end

	local runwayPaint = Instance.new("Folder")
	runwayPaint.Name = "RunwayPaint"

	for _, v2 in v do
		strip(runwayPaint, v2, vector3 or Vector3.new(0, 0, 0))
	end

	runwayPaint.Parent = parent
	return runwayPaint
end

return RunwayPaint