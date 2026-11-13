--!native
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VoxelCore = require(ReplicatedStorage.Voxel.VoxelCore)
local Materials = require(ReplicatedStorage.Voxel.Materials)
local Toughness = require(ReplicatedStorage.Voxel.Toughness)
local Detail = require(ReplicatedStorage.Voxel.Detail)
local GroundHeight = require(ReplicatedStorage.Voxel.GroundHeight)
local ClientWorld = require(ReplicatedStorage.Voxel.ClientWorld)

local chunk = VoxelCore.CHUNK

local v = chunk * 2

local v2 = v * v

local Palette = Materials.Palette

local Voxel = ReplicatedStorage.Voxel

local v3 = Voxel:GetAttribute("MobileMergeTones") ~= false
Voxel:GetAttributeChangedSignal("MobileMergeTones"):Connect(function()
	v3 = Voxel:GetAttribute("MobileMergeTones") ~= false
end)

local buf = buffer.create(256)

for i = 0, 255 do
	buffer.writeu8(buf, i, i)
end

for k, offset in Materials.Ids do
	if string.sub(k, -1) ~= "B" then
		continue
	end

	local id = Materials.Ids[string.sub(k, 1, -2) .. "A"]

	if id then
		buffer.writeu8(buf, offset, id)
	end
end

local buf2 = buffer.create(131072)

for i = 0, 255 do
	for j = 0, 255 do
		buffer.writeu16(buf2, (j + i * 256) * 2, buffer.readu8(buf, j) + buffer.readu8(buf, i) * 256)
	end
end

local v4 = #Palette < 64 and Toughness.STAGES * 64 + 64 <= 256
assert(v4, "[CollisionBoxes] damage stages need palette ids below " .. 64 .. " and at most 3 stages")

local buf3 = buffer.create(256)

for i = 0, 255 do
	local v5 = i % 64
	local v6 = buffer.readu8(buf, v5)

	if v6 ~= v5 then
		assert(
			Palette[v5] and Palette[v6] and Palette[v5].transparency == Palette[v6].transparency,
			"[CollisionBoxes] two-tone pair " .. v5 .. "/" .. v6 .. " must be equally see-through"
		)
	end

	buffer.writeu8(buf3, i, v6 + (i - v5))
end

local buf4 = buffer.create(256)
buffer.writeu8(buf4, 0, 1)

for i = 1, 255 do
	local v5 = Palette[i % 64]

	if v5 and v5.transparency > 0 then
		buffer.writeu8(buf4, i, 1)
	end
end

local v5 = {}
local function colorOf(p: number)
	local v6 = v5[p]

	if v6 ~= nil then
		return v6
	end

	local v7 = Palette[p % 64]
	local v8 = p // 64
	local v9 = Toughness.SHADE[v8]
	v6 = Color3.new(v7.color.R * v9, v7.color.G * v9, v7.color.B * v9):Lerp(Toughness.DUST_COLOR, Toughness.DUST[v8])
	v5[p] = v6

	return v6
end

local count = 0
local v6 = 0

local function blockKey(p: number, p2: number, p3: number) -- 3 equivalent calls inferred from this helper
	return p + 512 + (p2 + 512) * 1024 + (p3 + 512) * 1048576
end

return {
	["blockKey"] = blockKey,
	new = function(data, parent, p)
		local voxelSize = data.voxelSize
		local origin = data.origin
		local v7 = {}
		local instances = {}
		local v8 = {}
		local cframe = CFrame.new(origin.X, workspace.FallenPartsDestroyHeight + 100, origin.Z)

		local v9 = {}
		local cframes = {}
		local v10 = {}
		local v11 = {}
		local v12 = {}
		local set = {}
		local buf5 = buffer.create(v * v * v)
		local buf6 = buffer.create(v * v * v)
		local v13 = 0

		local v14 = {}

		local v15 = {}
		local v16 = {}

		local v17 = {}
		local vector3 = nil
		local v18 = {}

		local v19 = {}
		local vector3_2 = nil

		local v20 = {}
		local v21 = {}
		local v22 = {}
		local v23 = {}
		local v24 = {}

		local v25 = {}
		local v26 = {}
		local v27 = {}

		local v28 = {}
		local v29 = nil

		local v30 = {}
		local v31 = {}
		local function shadowless(p2: number) -- 2 equivalent calls inferred from this helper
			return Detail.low and (v30[p2] ~= nil or v31[p2] ~= nil)
		end

		local function look(p2, p3: number, p4: number, p5: number, p6: number, p7: number, p8: number)
			local v32 = p3 % 64
			local v33 = Palette[v32]

			if v20[p2] ~= p3 then
				local v34 = v20[p2]
				v20[p2] = p3
				local color

				if p3 >= 64 then
					color = colorOf(p3)
				else
					color = v33.color
				end

				p2.Color = color

				if v34 == nil or v34 % 64 ~= v32 then
					p2.Material = v33.material
					p2.Transparency = v33.transparency
				end
			end

			local variantFor = Materials.variantFor(v33, p4, p5, p6)

			if v21[p2] ~= variantFor then
				v21[p2] = variantFor
				p2.MaterialVariant = variantFor
			end

			v25[p2] = v33.transparency ~= 0 and 0 or p7
			local castShadow

			if v33.transparency == 0 then
				castShadow = p8 <= p7
			else
				castShadow = false
			end

			if v22[p2] ~= castShadow then
				v22[p2] = castShadow
				p2.CastShadow = castShadow
			end
		end

		local function setLtm(p2, localTransparencyModifier: number) -- 7 equivalent calls inferred from this helper
			if v23[p2] ~= localTransparencyModifier then
				v23[p2] = localTransparencyModifier
				p2.LocalTransparencyModifier = localTransparencyModifier
			end
		end

		local function newPart()
			local part = Instance.new("Part")
			part.Anchored = true
			part.CanTouch = false
			part.TopSurface = Enum.SurfaceType.Smooth
			part.BottomSurface = Enum.SurfaceType.Smooth
			return part
		end

		local function acquire()
			local v32 = table.remove(v8)

			if v32 then
				return v32, true
			end

			local v33 = table.remove(instances)

			if v33 then
				return v33, false
			end

			v33 = Instance.new("Part")
			v33.Anchored = true
			v33.CanTouch = false
			v33.TopSurface = Enum.SurfaceType.Smooth
			v33.BottomSurface = Enum.SurfaceType.Smooth

			return v33, false
		end

		local function release(instance)
			if #v8 < 384 then
				setLtm(instance, 1) -- inferred equivalent call
				table.insert(v9, instance)
				table.insert(cframes, cframe)
				table.insert(v8, instance)
			else
				instance.Parent = nil

				if #instances < (Detail.low and 1024 or 4096) then
					table.insert(instances, instance)
					return
				end

				v20[instance] = nil
				v21[instance] = nil
				v22[instance] = nil
				v23[instance] = nil
				v24[instance] = nil
				v25[instance] = nil
				instance:Destroy()
			end
		end

		local function signature(p2, p3: number)
			local v32 = p2[p3 + 1]
			local v33 = p2[p3 + 2]
			local v34 = p2[p3 + 3]
			local v35 = p2[p3 + 4]
			local v36 = p2[p3 + 5]
			local v37 = p2[p3 + 6]
			local v38 = p2[p3 + 7]
			return v32 + v * (v33 + v * (v34 + v * (v35 - 1 + v * (v36 - 1 + v * (v37 - 1 + v * v38)))))
		end

		local function clearBuried(p2: number, p3: number, p4: number)
			local coverRow = GroundHeight.coverRow
			local writeu8 = buffer.writeu8
			local v32 = p2 * v
			local v33 = p3 * v
			local v34 = p4 * v

			local col = GroundHeight.COL
			local x0 = GroundHeight.X0
			local z0 = GroundHeight.Z0
			local v35 = #GroundHeight.TRENCHES > 0 and 5 or 1
			local v36 = math.floor((origin.X + v32 * voxelSize - x0) / col - 0.5) - 2
			local v37 = math.floor((origin.X + (v32 + v) * voxelSize - x0) / col - 0.5) + 2
			local v38 = math.floor((origin.Z + v34 * voxelSize - z0) / col - 0.5) - v35
			local v39 = math.floor((origin.Z + (v34 + v) * voxelSize - z0) / col - 0.5) + v35
			local columnHeight = GroundHeight.columnHeight
			local v40 = -1e999

			for i = v38, v39 do
				for j = v36, v37 do
					local v41 = columnHeight(j, i)

					if v40 < v41 then
						v40 = v41
					end
				end
			end

			if math.floor((v40 + GroundHeight.COVER_LIFT - origin.Y) / voxelSize) - 1 < v33 then
				return
			end

			for i = 0, v - 1 do
				for j = 0, v - 1 do
					local v41 = coverRow(v32 + j, v34 + i) - v33
					local v42 = v41 - 4 + 1

					if not (v41 >= 0 and v42 < v) then
						continue
					end

					local v43 = j + i * v2

					for k = math.max(v42, 0), math.min(v41, v - 1) do
						writeu8(buf5, v43 + k * v, 0)
					end
				end
			end
		end

		local function gather(p2: number, p3: number, p4: number, p5: number, flag: boolean)
			buffer.fill(buf5, 0, 0)
			local total = 0

			for i = 0, 1 do
				for j = 0, 1 do
					for k = 0, 1 do
						local chunk2 = data.chunks[VoxelCore.chunkKey(p3 * 2 + k, p4 * 2 + j, p5 * 2 + i)]

						if not (chunk2 and chunk2.count > 0) then
							continue
						end

						total += chunk2.count
						local data2 = chunk2.data
						local v32 = k * chunk + j * chunk * v + i * chunk * v2

						for i2 = 0, chunk - 1 do
							for i3 = 0, chunk - 1 do
								buffer.copy(buf5, v32 + i3 * v + i2 * v2, data2, i3 * chunk + i2 * chunk * chunk, chunk)
							end
						end
					end
				end
			end

			if total > 0 then
				clearBuried(p3, p4, p5)
			end

			if p and total > 0 then
				p.mask(p2, buf5)
			end

			local v32 = (v17[p2] or Detail.low and v3) and total > 0

			if v32 and not flag then
				local readu32 = buffer.readu32
				local readu16 = buffer.readu16
				local writeu16 = buffer.writeu16
				local band = bit32.band
				local rshift = bit32.rshift

				for i = 0, v * v2 - 4, 4 do
					local v33 = readu32(buf5, i)

					if v33 == 0 then
						continue
					end

					writeu16(buf5, i, (readu16(buf2, band(v33, 65535) * 2)))
					writeu16(buf5, i + 2, (readu16(buf2, rshift(v33, 16) * 2)))
				end
			end

			local v33

			if not (v17[p2] or v19[p2]) then
				v33 = v14[p2]
			end

			if not v33 then
				return total, v32 and flag
			end

			local readu8 = buffer.readu8

			for offset, v34 in v33 do
				local v35 = readu8(buf5, offset)

				if v35 == 0 then
					continue
				end

				local v36 = offset % v
				local v37 = offset // v % v
				local v38 = offset // v2

				if not (v36 == 0 or v37 == 0 or v38 == 0 or v36 == v - 1 or v37 == v - 1 or v38 == v - 1 or readu8(buf4, (readu8(buf5, offset - 1))) == 1 or readu8(buf4, (readu8(buf5, offset + 1))) == 1 or readu8(buf4, (readu8(buf5, offset - v))) == 1 or readu8(buf4, (readu8(buf5, offset + v))) == 1 or readu8(buf4, (readu8(buf5, offset - v2))) == 1 or readu8(buf4, (readu8(buf5, offset + v2))) == 1) then
					continue
				end

				buffer.writeu8(buf5, offset, v35 + 64 * v34)
			end

			return total, v32 and flag
		end

		local v32 = v * voxelSize * 0.5

		local v33 = {}
		local function blockDist(p2: number, vector3_3: Vector3)
			local v34 = v33[p2]

			if v34 == nil then
				local v35 = p2 % 1024 - 512
				local v36 = p2 // 1024 % 1024 - 512
				local v37 = p2 // 1048576 - 512
				v34 = Vector3.new(
					origin.X + v35 * v * voxelSize + v32,
					origin.Y + v36 * v * voxelSize + v32,
					origin.Z + v37 * v * voxelSize + v32
				)
				v33[p2] = v34
			end

			return (math.max((v34 - vector3_3).Magnitude - v32 * 1.7320508, 0))
		end

		local function blockCentre(p2: number)
			blockDist(p2, Vector3.new(0, 0, 0))
			return v33[p2]
		end

		local function wantFar(p2: number): boolean -- 3 equivalent calls inferred from this helper
			local vector3_3 = vector3

			return vector3_3 ~= nil and blockDist(p2, vector3_3) > (v17[p2] and 160 or 180)
		end

		local function wantPlain(p2: number): boolean -- 4 equivalent calls inferred from this helper
			local vector3_3 = vector3_2

			return vector3_3 ~= nil and blockDist(p2, vector3_3) > (v19[p2] and 100 or 120)
		end

		local v34 = {}

		local function prepare(p2: number, p3: number, p4: number, p5: number, flag: boolean) -- 2 equivalent calls inferred from this helper
			v17[p2] = wantFar(p2) and true or nil -- inferred equivalent call
			local v35

			if v14[p2] then
				v35 = wantPlain(p2) and true or nil -- inferred equivalent call
			end

			v19[p2] = v35
			v18[p2] = nil
			count += 1
			v34[p2] = count
			return gather(p2, p3, p4, p5, flag)
		end

		local function shadowCut(p2: number)
			local v35 = v26[p2]

			if v35 == nil or v27[p2] ~= Detail.shadowVersion then
				v35 = 0
				local shadowVersion = Detail.shadowVersion
				v26[p2] = v35
				v27[p2] = shadowVersion

				if v7[p2] then
					v27[p2] = -1
					v28[p2] = true
				end
			end

			if shadowless(p2) then -- inferred equivalent call
				return 1e999
			end

			return (math.max(4, Detail.bandCells(v35)))
		end

		local function place(p2, flag: boolean, p3, p4: number, p5: number, p6: number, p7: number, p8: number, p9: number, p10)
			local v35 = p3[p4 + 1]
			local v36 = p3[p4 + 2]
			local v37 = p3[p4 + 3]
			local v38 = p3[p4 + 4]
			local v39 = p3[p4 + 5]
			local v40 = p3[p4 + 6]
			local v41 = p3[p4 + 7]

			local v42 = not (64 * Toughness.STAGES <= v41) and 0 or Toughness.CRACK_INSET * 2
			local v43 = v38 - 1 + v * (v39 - 1) + v2 * (v40 - 1) + (not (v42 > 0) and 0 or v * v2)

			if v24[p2] ~= v43 then
				v24[p2] = v43
				p2.Size = Vector3.new(v38 * voxelSize - v42, v39 * voxelSize - v42, v40 * voxelSize - v42)
			end

			local cframe2 = CFrame.new(
				origin.X + p5 * v * voxelSize + (v35 + v38 * 0.5) * voxelSize,
				origin.Y + p6 * v * voxelSize + (v36 + v39 * 0.5) * voxelSize,
				origin.Z + p7 * v * voxelSize + (v37 + v40 * 0.5) * voxelSize
			)

			if flag then
				table.insert(v9, p2)
				table.insert(cframes, cframe2)
			else
				p2.CFrame = cframe2
			end

			look(p2, v41, p5, p6, p7, v38 * v39 * v40, p8)
			local v44 = math.max(v38, v39, v40)

			if v44 <= 3 then
				p10 = p10 or { {}, {}, {} }
				table.insert(p10[v44], p2)
				setLtm(p2, v44 <= p9 and 1 or 0) -- inferred equivalent call
			else
				setLtm(p2, 0) -- inferred equivalent call
			end

			if not flag then
				p2.Parent = parent
			end

			return p10
		end

		local function sendMoves() -- 3 equivalent calls inferred from this helper
			if #v9 > 0 then
				workspace:BulkMoveTo(v9, cframes, Enum.BulkMoveMode.FireCFrameChanged)
				table.clear(v9)
				table.clear(cframes)
			end
		end

		local v35 = true

		local v36 = nil

		local function dropSlices()
			local v37 = v36
			v36 = nil
			local v38 = v7[v37.key]

			if v38 == nil then
				v38 = {}
				v7[v37.key] = v38
			end

			for i = 1, v37.nextBox - 1 do
				local sig = v37.sigs[i]
				v38[sig] = v37.new[sig]
			end
		end

		local v37 = {}
		local v38 = {}
		local v39 = {}

		local function apply(p2: number, p3: number, p4: number, p5: number, p6: number)
			if v36 and v36.key == p2 then
				dropSlices()
			end

			local v40 = v7[p2] or {}

			local v41 = v16[p2] or 0

			local v42 = shadowCut(p2)
			local v43 = {}
			local v44 = nil
			local count2 = 0

			for i = 0, p6 - 1 do
				local v45 = i * 7
				local v46 = signature(v10, v45)
				local v47 = v40[v46]

				if v47 then
					v40[v46] = nil
					v43[v46] = v47
					local v48 = math.max(v10[v45 + 4], v10[v45 + 5], v10[v45 + 6])

					if v48 <= 3 then
						v44 = v44 or { {}, {}, {} }
						table.insert(v44[v48], v47)
					end
				else
					count2 += 1
					v12[count2] = v45
					v39[count2] = v46
				end
			end

			local v45 = 0

			for k, v46 in v40 do
				v45 += 1
				v11[v45] = v46

				local v47 = k // (v * v2) % (v * v2)
				v38[v45] = v37[v47] or 0
				v37[v47] = v45
			end

			for i = 1, count2 do
				local v46 = v12[i]

				local v47 = v10[v46 + 4] - 1 + v * (v10[v46 + 5] - 1) + v2 * (v10[v46 + 6] - 1)
				local v48 = v37[v47]
				local v49 = nil
				local v50 = true

				while v48 and v48 > 0 do
					local v51 = v11[v48]
					local v52 = v38[v48]

					if v51 then
						v11[v48] = false
						v37[v47] = v52
						v49 = v51
						break
					end

					v48 = v52
				end

				if v49 == nil then
					while v45 > 0 and not v49 do
						v49 = v11[v45] or nil
						v11[v45] = nil
						v45 -= 1
					end
				end

				if v49 == nil then
					v49 = table.remove(v8)

					if v49 then
						v50 = true
					else
						v49 = table.remove(instances)

						if not v49 then
							v49 = Instance.new("Part")
							v49.Anchored = true
							v49.CanTouch = false
							v49.TopSurface = Enum.SurfaceType.Smooth
							v49.BottomSurface = Enum.SurfaceType.Smooth
						end

						v50 = false
					end

					v13 += 1
				end

				v44 = place(v49, v50, v10, v46, p3, p4, p5, v42, v41, v44)
				v43[v39[i]] = v49
			end

			table.clear(v37)

			for i = 1, v45 do
				if v11[i] then
					release(v11[i])
					v13 -= 1
				end

				v11[i] = nil
			end

			sendMoves() -- inferred equivalent call

			if not (p6 > 0) then
				v43 = nil
			end

			v7[p2] = v43

			if p6 == 0 then
				v26[p2] = nil
				v27[p2] = nil
			end

			v15[p2] = v44

			if not v44 then
				v16[p2] = nil
			end

			v35 = true

			if p then
				p.rebuilt(p2)
			end

			ClientWorld.boxVersion += 1
		end

		local function rebuildBlock(p2: number)
			local v40 = p2 % 1024 - 512
			local v41 = p2 // 1024 % 1024 - 512
			local v42 = p2 // 1048576 - 512
			apply(
				p2,
				v40,
				v41,
				v42,
				not (prepare(p2, v40, v41, v42, false) > 0) and 0 or VoxelCore.greedy(buf5, v, v, v, buf6, v10) -- inferred equivalent call
			)
		end

		local v40 = {}
		local v41 = 0
		local connections = {}

		local v42 = {}
		local v43 = {}

		local v44 = {}
		local v45 = 1
		local count2 = 0

		local function farFromCamera(p2: number): boolean -- 1 equivalent call inferred from this helper
			local currentCamera = workspace.CurrentCamera
			return currentCamera ~= nil and blockDist(p2, currentCamera.CFrame.Position) > 120
		end

		local function request(p2: number)
			if #v40 == 0 then
				error("[CollisionBoxes] request needs useWorkers first")
			end

			if v42[p2] and farFromCamera(p2) then -- inferred equivalent call
				v18[p2] = nil
				count += 1
				v34[p2] = count
				v43[p2] = true
				return
			end

			v43[p2] = nil
			local v46 = p2 % 1024 - 512
			local v47 = p2 // 1024 % 1024 - 512
			local v48 = p2 // 1048576 - 512
			local v49, v50 = prepare(p2, v46, v47, v48, true) -- inferred equivalent call

			if v49 == 0 then
				apply(p2, v46, v47, v48, 0)
				return
			end

			v41 = v41 % #v40 + 1
			v6 += 1
			v42[p2] = (v42[p2] or 0) + 1
			local v51 = v40[v41]
			local v52 = v34[p2]
			local v53

			if v50 then
				v53 = buf3
			end

			v51:Fire(p2, v52, buf5, v53)
		end

		local function busy() -- 1 equivalent call inferred from this helper
			return v6 + count2 - v45 + 1 + (v36 and 1 or 0)
		end

		local function applying(): boolean
			return v36 ~= nil
		end

		local function changedBoxes(buf7: buffer, p2: number, items)
			if items == nil then
				return p2
			end

			local readu8 = buffer.readu8
			local count3 = 0

			for i = 0, (p2 - 1) * 7, 7 do
				if items[readu8(buf7, i) + v * (readu8(buf7, i + 1) + v * (readu8(buf7, i + 2) + v * (readu8(buf7, i + 3) - 1 + v * (readu8(buf7, i + 4) - 1 + v * (readu8(buf7, i + 5) - 1 + v * readu8(buf7, i + 6))))))] ~= nil then
					continue
				end

				count3 += 1
			end

			local count4 = 0

			for _ in items do
				count4 += 1
			end

			return (math.max(count3, count4 - (p2 - count3)))
		end

		local v46 = 0
		local function costSample(p2: number, p3: number) -- 1 equivalent call inferred from this helper
			if p3 > 0 then
				local v47 = p2 / p3

				if not (v46 < v47) then
					v47 = v46 + (v47 - v46) * 0.25
				end

				v46 = v47
			end
		end

		local function startSlices(p2: number, p3: number, buf7: buffer, p4: number)
			local v47 = table.create(p4 * 7)

			for i = 0, p4 * 7 - 1 do
				v47[i + 1] = buffer.readu8(buf7, i)
			end

			local v48 = v7[p2] or {}
			local new = {}
			local list = nil
			local queue = {}
			local sigs = {}

			for i = 0, p4 - 1 do
				local v53 = i * 7
				local v54 = signature(v47, v53)
				local v55 = v48[v54]

				if v55 then
					new[v54] = v55
					local v56 = math.max(v47[v53 + 4], v47[v53 + 5], v47[v53 + 6])

					if v56 <= 3 then
						list = list or { {}, {}, {} }
						table.insert(list[v56], v55)
					end
				else
					table.insert(queue, v53)
					table.insert(sigs, v54)
				end
			end

			v36 = {
				key = p2,
				g = p3,
				data = v47,
				new = new,
				queue = queue,
				sigs = sigs,
				list = list,
				nextBox = 1,
				minCells = shadowCut(p2)
			}
		end

		local function finishSlices()
			local v47 = v36
			v36 = nil
			local key = v47.key
			local new = v47.new
			local list = v47.list

			for k, v48 in v7[key] or {} do
				if new[k] ~= nil then
					continue
				end

				release(v48)
				v13 -= 1
			end

			sendMoves() -- inferred equivalent call
			v7[key] = new
			v15[key] = list

			if list then
				local v48 = v16[key] or 0

				for k, item in list do
					local localTransparencyModifier = k <= v48 and 1 or 0

					for _, v50 in item do
						setLtm(v50, localTransparencyModifier) -- inferred equivalent call
					end
				end
			else
				v16[key] = nil
			end

			v27[key] = -1
			v28[key] = true
			v35 = true

			if p then
				p.rebuilt(key)
			end

			ClientWorld.boxVersion += 1
		end

		local function stepSlices(lastTime: number, p2: number, flag: boolean?): boolean
			local v47 = v36
			local key = v47.key

			if v34[key] ~= v47.g then
				dropSlices()
				return true
			end

			local queue = v47.queue
			local nextBox = v47.nextBox
			local count3 = #queue

			if flag and v46 > 0 then
				count3 = math.min(count3, nextBox + math.max(32, (p2 - (os.clock() - lastTime)) // v46) - 1)
			elseif flag then
				count3 = math.min(count3, nextBox + 32 - 1)
			end

			local v48 = key % 1024 - 512
			local v49 = key // 1024 % 1024 - 512
			local v50 = key // 1048576 - 512
			local lastTime2 = os.clock()
			local list = v47.list

			for i = nextBox, count3 do
				local v51 = table.remove(v8)
				local v52

				if v51 then
					v52 = true
				else
					v51 = table.remove(instances)

					if not v51 then
						v51 = Instance.new("Part")
						v51.Anchored = true
						v51.CanTouch = false
						v51.TopSurface = Enum.SurfaceType.Smooth
						v51.BottomSurface = Enum.SurfaceType.Smooth
					end

					v52 = false
				end

				v13 += 1
				list = place(v51, v52, v47.data, queue[i], v48, v49, v50, v47.minCells, v16[key] or 0, list)
				v47.new[v47.sigs[i]] = v51
				v47.nextBox = i + 1
			end

			v47.list = list
			sendMoves() -- inferred equivalent call
			costSample(os.clock() - lastTime2, count3 - nextBox + 1) -- inferred equivalent call

			if count3 ~= #queue then
				return false
			end

			finishSlices()
			return true
		end

		local function cancel() -- 1 equivalent call inferred from this helper
			if v36 then
				dropSlices()
			end

			table.clear(v34)
			table.clear(v43)
			table.clear(v44)
			v45 = 1
			count2 = 0
		end

		local function blockOf(p2: number, p3: number, p4: number) -- 1 equivalent call inferred from this helper
			return blockKey(p2 // 2, p3 // 2, p4 // 2) -- inferred equivalent call
		end

		local v47 = {}
		local v48 = {}
		local function flushOne(p2: number, p3, callback, p4) -- 2 equivalent calls inferred from this helper
			if p3 and p3[p2] and v7[p2] == nil then
				return
			end

			if callback and v7[p2] ~= nil and callback(p2) then
				p4[p2] = true
			else
				rebuildBlock(p2)
			end
		end

		local function setStage(p2: number, p3: number, p4: number, p5: number)
			local v49 = p2 // v
			local v50 = p3 // v
			local v51 = p4 // v
			local v52 = blockKey(v49, v50, v51) -- inferred equivalent call
			local v53 = p2 - v49 * v + v * (p3 - v50 * v) + v2 * (p4 - v51 * v)
			local v54 = v14[v52]

			if p5 == 0 then
				if v54 and v54[v53] then
					v54[v53] = nil

					if next(v54) == nil then
						v14[v52] = nil
					end

					if not v19[v52] then
						set[v52] = true
					end
				end
			else
				if p5 < 1 or Toughness.STAGES < p5 then
					error("[CollisionBoxes] bad damage stage " .. tostring(p5))
				end

				if v54 == nil then
					v54 = {}
					v14[v52] = v54

					if not v19[v52] and wantPlain(v52) then -- inferred equivalent call
						v19[v52] = true
					end
				end

				assert(v54)

				if v54[v53] ~= p5 then
					v54[v53] = p5

					if not v19[v52] then
						set[v52] = true
					end
				end
			end
		end

		local v49 = 0

		local function lod(vector3_3: Vector3, flag: boolean)
			local v50

			if flag then
				v50 = vector3_3
			end

			vector3 = v50

			if not Detail.low then
				vector3_3 = nil
			end

			vector3_2 = vector3_3

			if flag or next(v17) ~= nil then
				for k in v7 do
					if wantFar(k) == (v17[k] == true) then -- inferred equivalent call
						v18[k] = nil
					else
						v18[k] = true
					end
				end
			else
				table.clear(v18)
			end

			local now = os.clock()
			local v51 = v49 <= now

			for k in v14 do
				if not v7[k] then
					continue
				end

				local v52 = wantPlain(k) -- inferred equivalent call

				if v52 == (v19[k] == true) then
					continue
				end

				if v52 and not v18[k] then
					if v51 then
						v51 = false
						v49 = os.clock() + 0.3
						v18[k] = true
					end
				else
					v18[k] = true
				end
			end
		end

		local function lodStep(p2: number, p3: number)
			if next(v18) == nil then
				return 0
			end

			local lastTime = os.clock()
			local v50 = vector3 or workspace.CurrentCamera.CFrame.Position

			while os.clock() - lastTime < p2 and busy() < p3 do -- inferred equivalent call
				local v51 = 1e999
				local v52 = nil

				for k in v18 do
					local v53 = blockDist(k, v50)

					if not (v53 < v51) then
						continue
					end

					v52 = k
					v51 = v53
				end

				if v52 == nil then
					break
				end

				v18[v52] = nil

				if not v7[v52] then
					continue
				end

				if wantFar(v52) == (v17[v52] == true) then -- inferred equivalent call
					if not (v14[v52] ~= nil and wantPlain(v52) ~= (v19[v52] == true)) then -- inferred equivalent call
						continue
					end
				end

				request(v52)
			end

			local count3 = 0

			for _ in v18 do
				count3 += 1
			end

			return count3
		end

		local function cullShadows(flag: boolean, flag2: boolean)
			if not flag then
				return flag2
			end

			local shadowVersion = Detail.shadowVersion
			local now = os.clock()
			local count3 = 0

			for k, v50 in v31 do
				if not (v50 <= now) then
					continue
				end

				v31[k] = nil
				v27[k] = -1
				v28[k] = true
			end

			local function reband(k: number, items): boolean
				if v26[k] == 0 and v27[k] == shadowVersion then
					return true
				end

				if count3 >= 24 then
					return false
				end

				count3 += 1
				v26[k] = 0
				v27[k] = shadowVersion
				local v50 = shadowless(k) and 1e999 or math.max(4, Detail.bandCells(0)) -- inferred equivalent call

				for _, item in items do
					local castShadow = v50 <= (v25[item] or 0)

					if v22[item] == castShadow then
						continue
					end

					v22[item] = castShadow
					item.CastShadow = castShadow
				end

				return true
			end

			if v29 == shadowVersion then
				for k in v28 do
					local v51 = v7[k]

					if v51 and not reband(k, v51) then
						break
					end

					v28[k] = nil
				end
			else
				local flag3 = true

				for k, v51 in v7 do
					if not reband(k, v51) then
						flag3 = false
						break
					end
				end

				if flag3 then
					v29 = shadowVersion
					table.clear(v28)
				end
			end

			return flag2
		end

		local vector3_3 = nil
		local v50 = nil
		local v51 = nil
		local vector3_4 = nil
		local v52 = nil

		local function cull(vector3_5: Vector3, p2: number, flag: boolean, data2)
			local v53 = math.min(2.5, (Detail.low and 1.5 or 1) / Detail.budget)
			local v54 = p2 * v53
			local v55

			if data2 then
				v55 = data2.wideK * v53
			else
				v55 = v54
			end

			local total = 0
			local v56 = false
			local look2

			if data2 then
				look2 = data2.look
			end

			local angle

			if data2 then
				angle = data2.angle
			end

			if
				not v35
				and vector3_5 == vector3_3
				and v54 == v50
				and v55 == v51
				and look2 == vector3_4
				and angle == v52
			then
				return cullShadows(flag, false)
			end

			vector3_3 = vector3_5
			v50 = v54
			v51 = v55
			vector3_4 = look2
			v52 = angle

			for k, v58 in v15 do
				local v59 = blockDist(k, vector3_5)
				local v60

				if data2 then
					local vector = v33[k] - vector3_5
					local magnitude = vector.Magnitude

					if v32 * 1.7320508 < magnitude then
						if math.acos((math.clamp(vector:Dot(data2.look) / magnitude, -1, 1))) > data2.angle + math.asin((math.min(1, v32 * 1.7320508 / magnitude))) then
							v60 = v55
						else
							v60 = v54
						end
					else
						v60 = v54
					end
				else
					v60 = v54
				end

				local v61 = 1 * voxelSize < v60 * v59 and 1 or 0
				local v62 = 2 * voxelSize < v60 * v59 and 2 or v61
				local v63 = 3 * voxelSize < v60 * v59 and 3 or v62

				local v64 = v16[k] or 0

				if v63 == v64 then
					continue
				end

				if total >= 300 then
					v56 = true
					break
				else
					local v65

					if v63 > 0 then
						v65 = v63
					end

					v16[k] = v65

					for k2, v66 in v58 do
						local localTransparencyModifier = k2 <= v63 and 1 or 0

						if (k2 <= v64) == (k2 <= v63) then
							continue
						end

						total += #v66

						for _, v68 in v66 do
							setLtm(v68, localTransparencyModifier) -- inferred equivalent call
						end
					end
				end
			end

			v35 = v56
			return cullShadows(flag, v56)
		end

		local v53 = {
			touch = function(p2: number, p3: number, p4: number)
				set[blockOf(p2, p3, p4)] = true -- inferred equivalent call
			end,
			freeze = function()
				cancel() -- inferred equivalent call
				assert(#v9 == 0, "[CollisionBoxes] freeze: moves left over")

				for _, connection in connections do
					connection:Disconnect()
				end

				table.clear(connections)
				v40 = {}

				for _, v53 in v8 do
					v53:Destroy()
				end

				table.clear(v8)

				for _, v53 in instances do
					v53:Destroy()
				end

				table.clear(instances)

				for _, v53 in v15 do
					for _, v54 in v53 do
						for _, v55 in v54 do
							setLtm(v55, 0) -- inferred equivalent call
						end
					end
				end

				table.clear(v15)
				table.clear(v16)
				table.clear(v18)
				table.clear(set)
				table.clear(v7)
				return v13
			end,
			flush = function(p2, callback, p3, callback2)
				assert((callback == nil) == (p3 == nil), "[CollisionBoxes] flush: park and parked go together")

				if callback2 then
					table.clear(v47)

					for k in set do
						table.insert(v47, k)
						v48[k] = callback2(k)
					end

					table.sort(v47, function(a: number, b: number): boolean
						return v48[a] < v48[b]
					end)

					for _, v54 in v47 do
						if not p2 or not p2[v54] or v7[v54] ~= nil then
							flushOne(v54, nil, callback, p3) -- inferred equivalent call
						end
					end

					table.clear(v47)
					table.clear(v48)
				else
					for k in set do
						if not p2 or not p2[k] or v7[k] ~= nil then
							flushOne(k, nil, callback, p3) -- inferred equivalent call
						end
					end
				end

				table.clear(set)
			end,
			blockOf = blockOf,
			distance = blockDist,
			centre = blockCentre,
			half = function()
				return v * data.voxelSize * 0.5
			end,
			queued = function()
				local result = {}

				for k in set do
					table.insert(result, k)
				end

				table.clear(set)
				return result
			end,
			rebuildBlock = rebuildBlock,
			useWorkers = function(list, list2)
				local v46 = #v40 == 0 and #list > 0 and #list == #list2
				assert(v46, "[CollisionBoxes] useWorkers once, with a done event per job event")
				v40 = list

				for _, item in list2 do
					table.insert(
						connections,
						item.Event:Connect(function(p2: number, p3: number, buf7: buffer, p4: number)
							v6 -= 1
							local v47 = (v42[p2] or 1) - 1

							if not (v47 > 0) then
								v47 = nil
							end

							v42[p2] = v47
							count2 += 1
							v44[count2] = { p2, p3, buf7, p4 }
						end)
					)
				end
			end,
			request = request,
			busy = busy,
			finished = function()
				return count2 - v45 + 1 + (v36 and 1 or 0)
			end,
			applyReady = function(p2: number, flag: boolean?)
				local lastTime = os.clock()
				local v47, v48, v49, v50, v51, v52, v53, v54, currentCamera, v55, lastTime2, v56, v57

				if v36 then
					if not stepSlices(lastTime, p2, flag) then
						return count2 - v45 + 2
					end

					v47 = 1
				else
					v47 = 0
				end

				while v45 <= count2 do
					v48 = v44[v45]
					v49 = v48[1]
					v50 = v48[2]
					v51 = v48[3]
					v52 = v48[4]

					if v34[v49] == v50 then
						v53 = v48[5]

						if v53 == nil then
							v53 = changedBoxes(v51, v52, v7[v49])
							v48[5] = v53
						end

						v54 = v53 * v46

						if v47 > 0 and p2 < os.clock() - lastTime + v54 then
							break
						end

						v44[v45] = nil
						v45 += 1

						if flag and p2 < v54 and v52 > 0 then
							currentCamera = workspace.CurrentCamera

							if currentCamera == nil then
								v55 = false
							else
								v55 = blockDist(v49, currentCamera.CFrame.Position) > 120
							end

							if v55 then
								startSlices(v49, v50, v51, v52)
								v47 += 1

								if not stepSlices(lastTime, p2, true) then
									break
								end
							else
								lastTime2 = os.clock()

								for i = 0, v52 * 7 - 1 do
									v10[i + 1] = buffer.readu8(v51, i)
								end

								apply(v49, v49 % 1024 - 512, v49 // 1024 % 1024 - 512, v49 // 1048576 - 512, v52)
								v47 += 1
								v56 = os.clock() - lastTime2

								if v53 > 0 then
									v57 = v56 / v53

									if not (v46 < v57) then
										v57 = v46 + (v57 - v46) * 0.25
									end

									v46 = v57
								end
							end
						else
							lastTime2 = os.clock()

							for i = 0, v52 * 7 - 1 do
								v10[i + 1] = buffer.readu8(v51, i)
							end

							apply(v49, v49 % 1024 - 512, v49 // 1024 % 1024 - 512, v49 // 1048576 - 512, v52)
							v47 += 1
							v56 = os.clock() - lastTime2

							if v53 > 0 then
								v57 = v56 / v53

								if not (v46 < v57) then
									v57 = v46 + (v57 - v46) * 0.25
								end

								v46 = v57
							end
						end
					else
						v44[v45] = nil
						v45 += 1

						if v43[v49] and not v42[v49] then
							request(v49)
						end
					end

					if p2 < os.clock() - lastTime then
						break
					end
				end

				if count2 < v45 then
					table.clear(v44)
					v45 = 1
					count2 = 0
				end

				return count2 - v45 + 1 + (v36 and 1 or 0)
			end,
			cancel = cancel,
			prune = 0,
			clearBoxes = 0,
			setStage = 0,
			clearStages = 0,
			warm = 0,
			setBurning = 0,
			clearBurning = 0,
			cull = 0,
			lod = 0,
			lodStep = 0,
			lodWaiting = 0,
			applying = 0,
			count = 0
		}

		v53.blockOf = blockOf

		function v53.prune()
			for k in v7 do
				local v49 = k % 1024 - 512
				local v50 = k // 1024 % 1024 - 512
				local v51 = k // 1048576 - 512
				local v52 = false

				for i = 0, 1 do
					for j = 0, 1 do
						for i2 = 0, 1 do
							if not data.chunks[VoxelCore.chunkKey(v49 * 2 + i2, v50 * 2 + j, v51 * 2 + i)] then
								continue
							end

							v52 = true
						end
					end
				end

				if not v52 then
					rebuildBlock(k)
				end
			end
		end

		function v53.clearBoxes()
			for k in v7 do
				apply(k, k % 1024 - 512, k // 1024 % 1024 - 512, k // 1048576 - 512, 0)
			end
		end
		v53.setStage = setStage

		function v53.clearStages()
			table.clear(v14)
			table.clear(v19)
		end

		function v53.warm(p2: number)
			for _ = 1, math.min(p2, 384 - #v8) do
				local v54 = table.remove(instances)

				if not v54 then
					v54 = Instance.new("Part")
					v54.Anchored = true
					v54.CanTouch = false
					v54.TopSurface = Enum.SurfaceType.Smooth
					v54.BottomSurface = Enum.SurfaceType.Smooth
				end

				setLtm(v54, 1) -- inferred equivalent call
				v54.CFrame = cframe
				v54.Parent = parent
				table.insert(v8, v54)
			end
		end

		function v53.setBurning(p2: number, p3: number, p4: number, p5: number)
			local v53 = blockKey(p2 // v, p3 // v, p4 // v) -- inferred equivalent call
			local v54 = (v30[v53] or 0) + p5

			if v54 > 0 then
				if v30[v53] == nil and v31[v53] == nil then
					v27[v53] = -1
					v28[v53] = true
				end

				v30[v53] = v54
				v31[v53] = nil
			elseif v30[v53] ~= nil then
				v30[v53] = nil
				v31[v53] = os.clock() + 4
			end
		end

		function v53.clearBurning()
			local v54 = os.clock() + 4

			for k in v30 do
				v31[k] = v54
			end

			table.clear(v30)
		end
		v53.cull = cull
		v53.lod = lod
		v53.lodStep = lodStep

		function v53.lodWaiting(): boolean
			return next(v18) ~= nil
		end
		v53.applying = applying
		function v53.count()
			return v13
		end

		return v53
	end
}