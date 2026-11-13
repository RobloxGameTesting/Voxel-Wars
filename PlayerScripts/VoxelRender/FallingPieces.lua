--!native
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local Collapse = require(Voxel:WaitForChild("Collapse"))
local WorldConfig = require(Voxel:WaitForChild("WorldConfig"))
local VoxelSound = require(Voxel:WaitForChild("VoxelSound"))
local BattleFX = require(Voxel:WaitForChild("BattleFX"))
local Materials = require(Voxel:WaitForChild("Materials"))
local LooseChunks = require(script.Parent:WaitForChild("LooseChunks"))

local VOXEL_SIZE = WorldConfig.VOXEL_SIZE

local function dust(pal: number) -- 2 equivalent calls inferred from this helper
	local v = Materials.Palette[pal]
	local v2

	if v then
		v2 = v.color
	else
		v2 = Color3.new(0.6, 0.6, 0.6)
	end

	return v2:Lerp(Color3.new(0.62, 0.6, 0.57), 0.45)
end

local function extent(voxels: number) -- 2 equivalent calls inferred from this helper
	return voxels ^ (1 / 3) * VOXEL_SIZE * 1.4
end

local FallingPieces = {}

local voxelFalling = Instance.new("Folder")
voxelFalling.Name = "VoxelFalling"
voxelFalling.Parent = workspace

local v = {}
local v2 = 0
local v3 = {}
local v4 = {}

function FallingPieces.init(p)
	Collapse.init(p, {
		hit = function(p2: number, p3: number)
			local v5 = v[p2]
			local now = os.clock()

			if v5 and now - v5.lastSound > 0.15 then
				v5.lastSound = now
				VoxelSound.hit(v5.pal, v5.voxels, v5.piece.center, (math.clamp(p3 / 7, 0.1, 1)))
			end
		end
	})
end

function FallingPieces.spawn(p, vector3: Vector3, p2: number, flag: boolean?)
	local piece = LooseChunks.build(p, false, voxelFalling)
	Collapse.add(p, vector3, p2)
	local v5 = Collapse.get(p2)
	assert(v5, "falling piece was not added")
	v[p2] = {
		piece = piece,
		base = piece.center,
		x0 = v5.x,
		y0 = v5.y,
		z0 = v5.z,
		px = v5.x,
		py = v5.y,
		pz = v5.z,
		pal = piece.pal,
		voxels = piece.voxels,
		lastSound = os.clock()
	}

	v2 += 1

	if not flag then
		VoxelSound.breakApart(piece.pal, piece.voxels, piece.center, 1)
	end

	BattleFX.billow(piece.center, dust(piece.pal), extent(piece.voxels), false) -- inferred equivalent call
end

function FallingPieces.land(buf: buffer)
	for i = 0, buffer.len(buf) // 4 - 1 do
		local v5 = buffer.readu32(buf, i * 4)
		Collapse.remove(v5)
		local v6 = v[v5]

		if not v6 then
			continue
		end

		v[v5] = nil
		v2 -= 1

		BattleFX.billow(v6.piece.center, dust(v6.pal), extent(v6.voxels), true) -- inferred equivalent call
		LooseChunks.free(v6.piece)
	end
end

function FallingPieces.blast(vector3: Vector3, p: number)
	Collapse.blast(vector3, p)
end

function FallingPieces.count()
	return v2
end

function FallingPieces.clear()
	for k, v5 in v do
		v[k] = nil
		LooseChunks.free(v5.piece)
	end

	v2 = 0
	Collapse.clear()
end

RunService.Heartbeat:Connect(function(dt)
	if v2 == 0 then
		return
	end

	Collapse.step(dt)
	local count = 0

	for k, v5 in v do
		local v6 = Collapse.get(k)

		if v6 and v6.age > Collapse.MAX_FALL_TIME + 5 then
			Collapse.remove(k)
			v[k] = nil
			v2 -= 1
			LooseChunks.free(v5.piece)
		elseif v6 then
			local px = v6.x + v6.ax
			local py = v6.y + v6.ay
			local pz = v6.z + v6.az

			if px ~= v5.px or py ~= v5.py or pz ~= v5.pz then
				v5.px = px
				v5.py = py
				v5.pz = pz
				local center = v5.base + Vector3.new(px - v5.x0, py - v5.y0, pz - v5.z0) * VOXEL_SIZE
				v5.piece.center = center
				local cframe = CFrame.new(center)

				for k2, part in v5.piece.parts do
					count += 1
					v3[count] = part
					v4[count] = cframe * v5.piece.offsets[k2]
				end
			end
		end
	end

	if count > 0 then
		for i = count + 1, #v3 do
			v3[i] = nil
			v4[i] = nil
		end

		workspace:BulkMoveTo(v3, v4, Enum.BulkMoveMode.FireCFrameChanged)
	end
end)

return FallingPieces