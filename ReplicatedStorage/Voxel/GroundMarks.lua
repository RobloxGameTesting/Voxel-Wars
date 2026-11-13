local AssetService = game:GetService("AssetService")

local GroundHit = require(script.Parent:WaitForChild("GroundHit"))
local GroundFlatten = require(script.Parent:WaitForChild("GroundFlatten"))
local Quality = require(script.Parent:WaitForChild("Quality"))
local Detail = require(script.Parent:WaitForChild("Detail"))

local function kind(grid: number, count: number, rim: number, fn)
	return {
		marks = {},
		grid = grid,
		count = count,
		rim = rim,
		cell = fn,
		verts = {},
		uvs = {},
		normals = {},
		em = nil,
		next = 1,
		layer = 0
	}
end

local v = kind(11, Quality.cap(16), 0.01, function(p)
	return p % 4 * 0.25, p // 4 * 0.25, 0.25
end)

local v2 = kind(3, Quality.cap(96), 0, function(p)
	return p % 8 * 0.125, 0.5 + p // 8 * 0.125, 0.125
end)

local raycastParams = RaycastParams.new()
raycastParams.IncludeInstances = { workspace.Terrain }
raycastParams.IgnoreWater = true

local groundMarks = Instance.new("Folder")
groundMarks.Name = "GroundMarks"
groundMarks.Parent = workspace

local function build(state, name: string)
	local editableMesh = AssetService:CreateEditableMesh()

	if not editableMesh then
		error("GroundMarks: no editable mesh memory for " .. name)
	end

	local grid = state.grid

	for i = 1, state.count * grid * grid do
		state.verts[i] = editableMesh:AddVertex(Vector3.new(0, 0, 0))
		state.uvs[i] = editableMesh:AddUV(Vector2.zero)
		state.normals[i] = editableMesh:AddNormal(Vector3.new(0, 1, 0))
	end

	local function tri(p: number, p2: number, p3: number)
		local v3 = editableMesh:AddTriangle(state.verts[p], state.verts[p2], state.verts[p3])
		editableMesh:SetFaceUVs(v3, { state.uvs[p], state.uvs[p2], state.uvs[p3] })
		editableMesh:SetFaceNormals(v3, { state.normals[p], state.normals[p2], state.normals[p3] })
	end

	for i = 0, state.count - 1 do
		for j = 0, grid - 2 do
			for k = 0, grid - 2 do
				local v3 = i * grid * grid + j * grid + k + 1
				local v4 = v3 + 1
				local v5 = v3 + grid
				tri(v3, v4, v5)
				tri(v4, v5 + 1, v5)
			end
		end
	end

	local v3 = editableMesh:AddVertex(Vector3.new(-1020, -255, -1020))
	editableMesh:AddTriangle(v3, v3, (editableMesh:AddVertex(Vector3.new(1020, 255, 1020))))
	local meshPartAsync = AssetService:CreateMeshPartAsync(Content.fromObject(editableMesh), {
		CollisionFidelity = Enum.CollisionFidelity.Box,
		RenderFidelity = Enum.RenderFidelity.Precise
	})

	meshPartAsync.Name = name
	meshPartAsync.Anchored = true
	meshPartAsync.CanCollide = false
	meshPartAsync.CanQuery = false
	meshPartAsync.CanTouch = false
	meshPartAsync.CastShadow = false
	meshPartAsync.CFrame = CFrame.identity
	local clone = script.Parent:WaitForChild("GroundMarkLook"):Clone()
	clone.Parent = meshPartAsync
	meshPartAsync.Parent = groundMarks
	state.em = editableMesh
end

local random = Random.new()
local drape

local function place(state, pos: Vector3, vector3: Vector3, p: number)
	if not state.em then
		return
	end

	local soil = GroundHit.soil(pos - vector3 * 0.5)

	if not soil then
		return
	end

	local nextNode = state.next
	state.next = nextNode % state.count + 1
	state.layer = (state.layer + 1) % 8
	local unit = vector3.Unit
	local unit2 = unit:Cross(math.abs(unit.Y) > 0.9 and Vector3.new(1, 0, 0) or Vector3.new(0, 1, 0)).Unit
	local v3 = random:NextNumber() * 3.141592653589793 * 2
	local side = unit2 * math.cos(v3) + unit:Cross(unit2) * math.sin(v3)
	local cross = unit:Cross(side)
	local cell, v4, size = state.cell(soil)
	local v5 = {
		pos = pos,
		n = unit,
		side = side,
		across = cross,
		half = p * 0.5,
		lift = state.layer * 0.006 + 0.05,
		rimHeight = state.rim * p,
		u0 = cell,
		v0 = v4,
		size = size
	}
	state.marks[nextNode] = v5
	drape(state, nextNode, v5, 4)
end

drape = function(data, p: number, data2, p2: number)
	local em = data.em
	local pos = data2.pos
	local n = data2.n
	local side = data2.side
	local across = data2.across
	local half = data2.half
	local lift = data2.lift
	local rimHeight = data2.rimHeight
	local u0 = data2.u0
	local v0 = data2.v0
	local size = data2.size
	local grid = data.grid

	for i = 0, grid - 1 do
		for j = 0, grid - 1 do
			local v3 = j / (grid - 1) * 2 - 1
			local v4 = i / (grid - 1) * 2 - 1
			local v5 = pos + (side * v3 + across * v4) * half
			local raycastResult = workspace:Raycast(v5 + n * 2, n * -p2, raycastParams)
			local v6

			if raycastResult then
				v5 = raycastResult.Position
				v6 = raycastResult.Normal
			else
				v6 = n
			end

			local v7 = rimHeight * math.exp(-((math.sqrt(v3 * v3 + v4 * v4) - 0.5) / 0.2) ^ 2)
			local v8 = (p - 1) * grid * grid + i * grid + j + 1
			em:SetPosition(data.verts[v8], v5 + v6 * (lift + v7))
			em:SetNormal(data.normals[v8], v6)
			em:SetUV(data.uvs[v8], Vector2.new(u0 + (v3 + 1) * 0.5 * size, v0 + (v4 + 1) * 0.5 * size))
		end
	end
end

local GroundMarks = {
	bullet = function(pos: Vector3, vector3: Vector3)
		if
			Quality.detail(pos) > 0
			and not (Detail.low and (Detail.distance(pos) > 300 or Detail.pixels(pos, 1.15) < 2))
		then
			place(v2, pos, vector3, random:NextNumber(1, 1.3))
		end

		GroundFlatten.at(pos, 0)
	end,
	scorch = function(pos: Vector3, vector3: Vector3, p: number)
		if Detail.low then
			local distance = Detail.distance(pos)

			if not (p * 1.6 + 300 < distance) then
				place(v, pos, vector3, p * 1.6)
			end
		else
			place(v, pos, vector3, p * 1.6)
		end

		GroundFlatten.at(pos, p * 0.9)
	end,
	redrape = function(vector3: Vector3, p: number)
		for _, v3 in { v, v2 } do
			if not v3.em then
				continue
			end

			for k, mark in v3.marks do
				local v4 = mark.pos - vector3

				if not (math.sqrt(v4.X * v4.X + v4.Z * v4.Z) < p + mark.half) then
					continue
				end

				drape(v3, k, mark, 12)
			end
		end
	end
}

task.spawn(function()
	build(v2, "GroundPocks")
	build(v, "GroundCraters")
end)

return GroundMarks