--!native
local AssetService = game:GetService("AssetService")
local VoxelProp = {}

function VoxelProp.bake(vector3: Vector3, vector3_2: Vector3, p: number, callback)
	local x = vector3.X
	local y = vector3.Y
	local z = vector3.Z

	local v = { 1, x, x * y }
	local buf = buffer.create(x * y * z)

	local lastTime = os.clock()
	local v2 = {}
	local v3 = {}

	local v4 = { x, y, z }
	local v5 = { -1, -1, -1 }
	local v6 = { x, y, z }

	for i = 0, z - 1 do
		for j = 0, y - 1 do
			for k = 0, x - 1 do
				local v7 = callback((Vector3.new(
					vector3_2.X + (k + 0.5) * p,
					vector3_2.Y + (j + 0.5) * p,
					vector3_2.Z + (i + 0.5) * p
				)))

				if not v7 then
					continue
				end

				local hex = v7:ToHex()
				local v8 = v2[hex]

				if not v8 then
					table.insert(v3, v7)
					v8 = #v3
					assert(v8 < 256, "[VoxelProp] more than 255 colours")
					v2[hex] = v8
				end

				buffer.writeu8(buf, k + x * (j + y * i), v8)
				local v9 = math.min(v4[1], k)
				local v10 = math.max(v5[1], k)
				v4[1] = v9
				v5[1] = v10
				local v11 = math.min(v4[2], j)
				local v12 = math.max(v5[2], j)
				v4[2] = v11
				v5[2] = v12
				local v13 = math.min(v4[3], i)
				local v14 = math.max(v5[3], i)
				v4[3] = v13
				v5[3] = v14
			end
		end

		if not (os.clock() - lastTime > 0.004) then
			continue
		end

		task.wait()
		lastTime = os.clock()
	end

	assert(v5[1] >= 0, "[VoxelProp] the shape filled no cells")
	local v7 = { vector3_2.X, vector3_2.Y, vector3_2.Z }
	local v8 = {
		v7[1] + (v4[1] + v5[1] + 1) * 0.5 * p,
		v7[2] + (v4[2] + v5[2] + 1) * 0.5 * p,
		v7[3] + (v4[3] + v5[3] + 1) * 0.5 * p
	}

	local vector3_3 = Vector3.new(v8[1], v8[2], v8[3])

	local editableMesh = AssetService:CreateEditableMesh()
	assert(editableMesh, "[VoxelProp] no editable mesh memory")
	local v9 = {}

	for k, v10 in v3 do
		v9[k] = editableMesh:AddColor(v10, 1)
	end

	local buf2 = buffer.create((math.max(x * y, y * z, z * x)))
	local v10 = { 0, 0, 0 }
	local v11 = { 0, 0, 0 }
	local v12 = {}
	local function corner(i: number, p2: number, p3: number, p4: number, p5: number, p6: number)
		v11[i] = math.round((p4 - v7[i]) / p)
		v11[p2] = math.round((p5 - v7[p2]) / p)
		v11[p3] = math.round((p6 - v7[p3]) / p)
		local v13 = v11[1] + (x + 1) * (v11[2] + (y + 1) * v11[3])
		local v14 = v12[v13]

		if v14 then
			return v14
		end

		local v15 = p4 - v8[i]
		local v16 = p5 - v8[p2]
		local v17 = p6 - v8[p3]
		v10[i] = v15
		v10[p2] = v16
		v10[p3] = v17
		local v18 = editableMesh:AddVertex((Vector3.new(v10[1], v10[2], v10[3])))
		v12[v13] = v18
		return v18
	end

	local total = 0

	for i = 1, 3 do
		local v13 = i % 3 + 1
		local v14 = (i + 1) % 3 + 1
		local v15 = v6[v13]
		local v16 = v6[v14]
		local v17 = v[i]
		local v18 = v[v13]
		local v19 = v[v14]

		for j = -1, 1, 2 do
			local v20 = { 0, 0, 0 }
			v20[i] = j
			local v21 = editableMesh:AddNormal((Vector3.new(v20[1], v20[2], v20[3])))

			for k = 0, v6[i] - 1 do
				local v22 = k + j
				local v23 = v22 < 0 or v6[i] <= v22
				local flag = false

				for i2 = 0, v16 - 1 do
					for i3 = 0, v15 - 1 do
						local v24 = k * v17 + i3 * v18 + i2 * v19
						local v25 = buffer.readu8(buf, v24)
						local v26 = v25 > 0 and not v23 and buffer.readu8(buf, v24 + j * v17) > 0 and 0 or v25

						buffer.writeu8(buf2, i3 + v15 * i2, v26)

						if v26 > 0 then
							flag = true
						end
					end
				end

				if flag then
					local v24 = v7[i]
					local v25

					if j > 0 then
						v25 = k + 1
					else
						v25 = k
					end

					local v26 = v24 + v25 * p

					for i2 = 0, v16 - 1 do
						local total2 = 0

						while total2 < v15 do
							local v27 = buffer.readu8(buf2, total2 + v15 * i2)

							if v27 == 0 then
								total2 += 1
							else
								local v28 = 1

								while total2 + v28 < v15 and buffer.readu8(buf2, total2 + v28 + v15 * i2) == v27 do
									v28 += 1
								end

								local v29 = 1

								while i2 + v29 < v16 do
									local v30 = true

									for i3 = total2, total2 + v28 - 1 do
										if buffer.readu8(buf2, i3 + v15 * (i2 + v29)) ~= v27 then
											v30 = false
											break
										end
									end

									if not v30 then
										break
									end

									v29 += 1
								end

								for i3 = i2, i2 + v29 - 1 do
									for i4 = total2, total2 + v28 - 1 do
										buffer.writeu8(buf2, i4 + v15 * i3, 0)
									end
								end

								local v30 = v7[v13] + total2 * p
								local v31 = v7[v13] + (total2 + v28) * p
								local v32 = v7[v14] + i2 * p
								local v33 = v7[v14] + (i2 + v29) * p
								local v34 = corner(i, v13, v14, v26, v30, v32)
								local v35 = corner(i, v13, v14, v26, v31, v32)
								local v36 = corner(i, v13, v14, v26, v30, v33)
								local v37 = corner(i, v13, v14, v26, v31, v33)
								local v38 = v9[v27]
								local v39, v40

								if j > 0 then
									v39 = editableMesh:AddTriangle(v34, v35, v36)
									v40 = editableMesh:AddTriangle(v35, v37, v36)
								else
									v39 = editableMesh:AddTriangle(v34, v36, v35)
									v40 = editableMesh:AddTriangle(v35, v36, v37)
								end

								for _, v41 in { v39, v40 } do
									editableMesh:SetFaceNormals(v41, { v21, v21, v21 })
									editableMesh:SetFaceColors(v41, { v38, v38, v38 })
								end

								total += 2
								total2 += v28
							end
						end
					end
				end

				if not (os.clock() - lastTime > 0.004) then
					continue
				end

				task.wait()
				lastTime = os.clock()
			end
		end
	end

	assert(total <= 20000, ("[VoxelProp] %d triangles is over the editable mesh limit"):format(total))
	return {
		mesh = editableMesh,
		center = vector3_3,
		size = Vector3.new(v5[1] - v4[1] + 1, v5[2] - v4[2] + 1, v5[3] - v4[3] + 1) * p,
		triangles = total
	}
end

function VoxelProp.part(p, name: string)
	local meshPartAsync = AssetService:CreateMeshPartAsync(Content.fromObject(p.mesh), {
		CollisionFidelity = Enum.CollisionFidelity.Box,
		RenderFidelity = Enum.RenderFidelity.Precise
	})

	meshPartAsync.Name = name
	meshPartAsync.Anchored = true
	meshPartAsync.CanCollide = false
	meshPartAsync.CanQuery = false
	meshPartAsync.CanTouch = false
	meshPartAsync.CastShadow = false
	meshPartAsync.Material = Enum.Material.SmoothPlastic
	meshPartAsync.Color = Color3.new(1, 1, 1)
	return meshPartAsync
end

return VoxelProp