--!native
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quality = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("Quality"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Detail = require(ReplicatedStorage2:WaitForChild("Voxel"):WaitForChild("Detail"))

local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local WorldRay = require(ReplicatedStorage3:WaitForChild("Voxel"):WaitForChild("WorldRay"))

local ParticleSim = {}
ParticleSim.METER = 2.5
local meter = ParticleSim.METER

ParticleSim.glide = true

ParticleSim.CONSTANT = 0
ParticleSim.LINEAR = 1
ParticleSim.SMOOTH = 2
ParticleSim.EASEIN = 3
ParticleSim.EASEOUT = 4

function ParticleSim.curve(mode: number, value: number?, value2: number?)
	return {
		mode = mode,
		fadeIn = value or 0,
		fadeOut = value2 or 0
	}
end

function ParticleSim.gravityScale()
	return workspace.Gravity / (10 * meter)
end

function ParticleSim.speedScale()
	return (math.sqrt(workspace.Gravity / (10 * meter)))
end

local function smoothstep(p: number) -- 3 equivalent calls inferred from this helper
	return (3 - p * 2) * p * p
end

local function evaluate(data, total: number, p: number, p2: number)
	local v = 1 - p2
	local v2

	if p2 < data.fadeIn then
		v2 = smoothstep(p2 / data.fadeIn) -- inferred equivalent call
	else
		v2 = 1
	end

	if v < data.fadeOut then
		v2 *= smoothstep(v / data.fadeOut) -- inferred equivalent call
	end

	local mode = data.mode

	if mode == 1 then
		total += (p - total) * p2
	elseif mode == 2 then
		total += (p - total) * smoothstep(p2) -- inferred equivalent call
	elseif mode == 3 then
		total += (p - total) * p2 * p2
	elseif mode == 4 then
		total += (p - total) * (1 - v * v)
	end

	return v2 * total
end

local v = 0
local v2 = table.create(1200, 0)
local v3 = table.create(1200, 0)
local v4 = table.create(1200, 0)
local v5 = table.create(1200, 0)
local v6 = table.create(1200, 0)
local v7 = table.create(1200, 0)
local v8 = table.create(1200, 0)
local v9 = table.create(1200, 0)
local v10 = table.create(1200, 0)
local v11 = table.create(1200, 0)
local v12 = table.create(1200, 0)
local v13 = table.create(1200, 0)
local v14 = table.create(1200, 0)
local v15 = table.create(1200, 0)
local v16 = table.create(1200, 0)
local v17 = table.create(1200, 0)
local v18 = table.create(1200, 0)
local v19 = table.create(1200, 0)
local v20 = table.create(1200, 0)
local v21 = table.create(1200, Vector3.new(0, 1, 0))
local v22 = {}
local v23 = {}
local v24 = table.create(1200, false)
local v25 = table.create(1200, false)
local v26 = table.create(1200, 1)

local v27 = table.create(1200, 0)
local v28 = table.create(1200, 0)
local v29 = table.create(1200, 0)
local v30 = table.create(1200, Vector3.new(0, 1, 0))

local v31 = table.create(1200, 0)
local v32 = table.create(1200, Vector3.new(0, 1, 0))
local v33 = table.create(1200, 0)

local v34 = table.create(1200, 0)
local v35 = table.create(1200, 0)
local v36 = table.create(1200, 0)

local v37 = {}
local v38 = {}
local v39 = table.create(1200, -1)
local v40 = table.create(1200, -1)
local v41 = table.create(1200, -1)

local v42 = table.create(1200, -1)

local v43 = table.create(1200, 0)
local v44 = table.create(1200, true)
local count = 0
local v45 = {}
local v46 = {}

local v47 = table.create(1200, 0)
local v48 = table.create(1200, 0)
local v49 = table.create(1200, 0)
local v50 = table.create(1200, 0)

local parent = nil
local v52 = {}

local v53 = {}
local random = Random.new()

local raycastParams = RaycastParams.new()
raycastParams.IgnoreWater = true

local function refreshFilter() -- 1 equivalent call inferred from this helper
	local characters = { parent }
	local character = Players.LocalPlayer and Players.LocalPlayer.Character

	if character then
		table.insert(characters, character)
	end

	raycastParams.ExcludeInstances = characters
end

local function newChip() -- 1 equivalent call inferred from this helper
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	return part
end

local function acquire() -- 1 equivalent call inferred from this helper
	local selected = table.remove(v52)

	if not selected then
		selected = Instance.new("Part")
		selected.Anchored = true
		selected.CanCollide = false
		selected.CanQuery = false
		selected.CanTouch = false
		selected.CastShadow = false
		selected.TopSurface = Enum.SurfaceType.Smooth
		selected.BottomSurface = Enum.SurfaceType.Smooth
	end

	assert(selected)
	return selected
end

local function release(instance) -- 1 equivalent call inferred from this helper
	if #v52 + v > Quality.cap(1200) then
		v53[instance] = nil
		instance:Destroy()
	else
		instance.Transparency = 1
		table.insert(v52, instance)
	end
end

local function kill(p: number)
	release(v37[p]) -- inferred equivalent call
	local v54 = v

	if p ~= v54 then
		local v55 = v2[v54]
		local v56 = v3[v54]
		local v57 = v4[v54]
		v2[p] = v55
		v3[p] = v56
		v4[p] = v57
		local v58 = v5[v54]
		local v59 = v6[v54]
		local v60 = v7[v54]
		v5[p] = v58
		v6[p] = v59
		v7[p] = v60
		local v61 = v8[v54]
		local v62 = v9[v54]
		v8[p] = v61
		v9[p] = v62
		local v63 = v10[v54]
		local v64 = v11[v54]
		local v65 = v12[v54]
		local v66 = v13[v54]
		v10[p] = v63
		v11[p] = v64
		v12[p] = v65
		v13[p] = v66
		local v67 = v14[v54]
		local v68 = v15[v54]
		local v69 = v16[v54]
		local v70 = v17[v54]
		v14[p] = v67
		v15[p] = v68
		v16[p] = v69
		v17[p] = v70
		local v71 = v18[v54]
		local v72 = v19[v54]
		v18[p] = v71
		v19[p] = v72
		local v73 = v20[v54]
		local v74 = v21[v54]
		v20[p] = v73
		v21[p] = v74
		local v75 = v22[v54]
		local v76 = v23[v54]
		local v77 = v24[v54]
		v22[p] = v75
		v23[p] = v76
		v24[p] = v77
		local v78 = v25[v54]
		local v79 = v26[v54]
		v25[p] = v78
		v26[p] = v79
		local v80 = v27[v54]
		local v81 = v28[v54]
		local v82 = v29[v54]
		local v83 = v30[v54]
		v27[p] = v80
		v28[p] = v81
		v29[p] = v82
		v30[p] = v83
		local v84 = v31[v54]
		local v85 = v32[v54]
		local v86 = v33[v54]
		v31[p] = v84
		v32[p] = v85
		v33[p] = v86
		local v87 = v34[v54]
		local v88 = v35[v54]
		local v89 = v36[v54]
		v34[p] = v87
		v35[p] = v88
		v36[p] = v89
		local v90 = v37[v54]
		local v91 = v38[v54]
		v37[p] = v90
		v38[p] = v91
		local v92 = v39[v54]
		local v93 = v40[v54]
		local v94 = v41[v54]
		v39[p] = v92
		v40[p] = v93
		v41[p] = v94
		v42[p] = v42[v54]
		local v95 = v43[v54]
		local v96 = v44[v54]
		v43[p] = v95
		v44[p] = v96
		local v97 = v47[v54]
		local v98 = v48[v54]
		local v99 = v49[v54]
		local v100 = v50[v54]
		v47[p] = v97
		v48[p] = v98
		v49[p] = v99
		v50[p] = v100
	end

	v37[v54] = nil
	v38[v54] = nil
	v22[v54] = nil
	v -= 1
end

function ParticleSim.spawn(p, position: Vector3, vector3: Vector3, p2: number, color: Color3, p3: number, p4: number, p5: number, p6: number, p7: number, p8: number, p9: number, p10: number, p11: number, p12: number, p13, p14: number?, value: string?)
	if v >= Quality.cap(1200) or p2 <= 0 then
		return
	end

	if Detail.pixels(position, math.max(p3, p4) * 2 * 2 * meter) < (Detail.low and 1.5 or 0.75) then
		return
	end

	v += 1
	local v54 = v
	local speedScale = ParticleSim.speedScale()
	local v55 = position.X / meter
	local v56 = position.Y / meter
	local v57 = position.Z / meter
	v2[v54] = v55
	v3[v54] = v56
	v4[v54] = v57
	local v58 = vector3.X * speedScale
	local v59 = vector3.Y * speedScale
	local v60 = vector3.Z * speedScale
	v5[v54] = v58
	v6[v54] = v59
	v7[v54] = v60
	v8[v54] = 0
	v9[v54] = p2
	local v61 = p3 * 2
	local v62 = p4 * 2
	v10[v54] = v61
	v11[v54] = v62
	v12[v54] = p9
	v13[v54] = p10
	v14[v54] = p5
	v15[v54] = p6
	v16[v54] = p7
	v17[v54] = p8
	v18[v54] = p11
	v19[v54] = p12
	v20[v54] = random:NextNumber(0, 6.283185307179586)
	v21[v54] = random:NextUnitVector()
	v22[v54] = p
	v23[v54] = color
	v24[v54] = false
	v25[v54] = false
	v31[v54] = 0
	v26[v54] = 1
	v34[v54] = v10[v54]
	v35[v54] = p9
	v36[v54] = p11
	v39[v54] = -1
	v40[v54] = -1
	v41[v54] = -1
	v42[v54] = -1
	count += 1
	v43[v54] = count % 2 == 0 and 1 / 60 or 0
	v44[v54] = true
	local v63 = acquire() -- inferred equivalent call
	local material = p13 or p.material
	local v65 = value or ""
	local v66 = v53[v63]

	if v66 == nil then
		v63.Material = material
		v63.MaterialVariant = v65
		v63.Color = color
		v53[v63] = { material = material, variant = v65, color = color }
	else
		if v66.material ~= material then
			v66.material = material
			v63.Material = material
		end

		if v66.variant ~= v65 then
			v66.variant = v65
			v63.MaterialVariant = v65
		end

		if v66.color ~= color then
			v66.color = color
			v63.Color = color
		end
	end

	if p14 and p14 > 0 then
		local v67 = v12[v54] * (1 - p14)
		local v68 = v13[v54] * (1 - p14)
		v12[v54] = v67
		v13[v54] = v68
	end

	local v67 = v2[v54]
	local v68 = v3[v54]
	local v69 = v4[v54]
	v47[v54] = v67
	v48[v54] = v68
	v49[v54] = v69
	v50[v54] = 1e999

	if v66 == nil then
		v63.Parent = parent
	end

	v37[v54] = v63
	v38[v54] = CFrame.new(position)
end

local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
local BLAST_SCALE = require(ReplicatedStorage4:WaitForChild("Voxel"):WaitForChild("WorldConfig")).BLAST_SCALE

function ParticleSim.push(vector3: Vector3, p: number)
	local v54 = vector3.X / meter
	local v55 = vector3.Y / meter
	local v56 = vector3.Z / meter
	local v57 = math.max(0.4, p * 2.1) * BLAST_SCALE * 6
	local v58 = math.max(p * 7, 0.01) * BLAST_SCALE
	local speedScale = ParticleSim.speedScale()

	for i = 1, v do
		local v59 = v2[i] - v54
		local v60 = v3[i] - v55
		local v61 = v4[i] - v56
		local v62 = math.sqrt(v59 * v59 + v60 * v60 + v61 * v61)

		if not (v62 < v57) then
			continue
		end

		local v63 = 1 / (v62 + 0.001)
		v59 *= v63
		v60 *= v63
		v61 *= v63
		local v64 = 1 - math.clamp(v62 / v58, 0, 1)
		local v65 = v64 * v64 * (p + 1 + p + 1) * speedScale
		local v66 = v5[i] * v59 + v6[i] * v60 + v7[i] * v61

		if v66 > 0 then
			v65 = v65 <= v66 and 0 or v65 - v66
		end

		v5[i] += v59 * v65
		v6[i] += v60 * v65
		v7[i] += v61 * v65
		v24[i] = false
		v31[i] = 0
	end
end

function ParticleSim.wake(vector3: Vector3, p: number)
	local v54 = vector3.X / meter
	local v55 = vector3.Y / meter
	local v56 = vector3.Z / meter
	local v57 = p / meter
	local v58 = v57 * v57

	for i = 1, v do
		if not (v24[i] or v31[i] > 0) then
			continue
		end

		local v59 = v2[i] - v54
		local v60 = v3[i] - v55
		local v61 = v4[i] - v56

		if not (v59 * v59 + v60 * v60 + v61 * v61 < v58) then
			continue
		end

		v24[i] = false
		v31[i] = 0
	end
end

function ParticleSim.count()
	return v
end

local v54 = {
	Vector3.new(1, 0, 0),
	Vector3.new(0, 1, 0),
	Vector3.new(0, 0, 1),
	-Vector3.new(1, 0, 0),
	-Vector3.new(0, 1, 0),
	-Vector3.new(0, 0, 1)
}

local function settleFlat(p: number, vector3: Vector3)
	local cframe = CFrame.fromAxisAngle(v21[p], v20[p])
	local v55 = -2
	local vector = Vector3.new(0, 1, 0)

	for _, v56 in v54 do
		local vector2 = cframe:VectorToWorldSpace(v56)
		local dot = vector2:Dot(vector3)

		if not (v55 < dot) then
			continue
		end

		vector = vector2
		v55 = dot
	end

	local cross = vector:Cross(vector3)

	if cross.Magnitude > 0.00001 then
		cframe = CFrame.fromAxisAngle(cross.Unit, (math.acos((math.clamp(v55, -1, 1))))) * cframe
	end

	local axisAngle, v56 = cframe:ToAxisAngle()
	v21[p] = axisAngle
	v20[p] = v56
end

local function tick(p: number, flag: boolean)
	local gravityScale = ParticleSim.gravityScale()
	local v55 = math.sqrt(gravityScale)
	local v56 = (v55 * 0.15) ^ 2
	local v57 = v55 * 1.5
	local v58 = v

	while v58 >= 1 do
		local v59, v60, v61, v62, v63, v64, v65, v66, v67, v68, v69, v70, v71, v72, collide, v73, v74, v75, vector3, v76, v77, v78, v79, x, y, z, v80, v81, v82, v83, v84, v85, v86, v87, v88, v89, v90, v91, v92, v93, v94, v95, v96, v97, v98, v99, v100, vector3_2, v101, v102, v103, v104, v105, v106, drag, v107, v108, v109, v110, v111

		if flag then
			v59 = math.min(v43[v58] + p, 1 / 15)

			if v59 < 1 / 30 then
				v43[v58] = v59
			else
				v43[v58] = 0

				v60 = v59 / (1 / 60)
				v44[v58] = true
				v61 = v8[v58] + v59

				if v9[v58] <= v61 then
					kill(v58)
				else
					v8[v58] = v61
					v62 = v22[v58]
					v63 = v61 / v9[v58]
					v64 = evaluate(v62.radius, v10[v58], v11[v58], v63)
					v34[v58] = v64
					v35[v58] = evaluate(v62.alpha, v12[v58], v13[v58], v63)
					v36[v58] = evaluate(v62.emissive, v18[v58], v19[v58], v63)

					if not v24[v58] then
						v65 = v20
						v65[v58] += evaluate(v62.rotation, v16[v58], v17[v58], v63) * v26[v58] * v59
						v66 = v2[v58]
						v67 = v3[v58]
						v68 = v4[v58]
						v69 = v5[v58]
						v70 = v6[v58]
						v71 = v7[v58]
						v72 = math.sqrt(v69 * v69 + v70 * v70 + v71 * v71)

						collide = v62.collide

						if collide > 0 then
							v74 = 0
							v75 = 0

							if v61 < v31[v58] then
								v73 = v32[v58]
								v74 = v33[v58]
								v75 = v66 * v73.X + v67 * v73.Y + v68 * v73.Z - v74 - v64

								if v75 > 0.02 then
									v31[v58] = 0
									v73 = nil
								end
							else
								v31[v58] = 0
								vector3 = Vector3.new(v66 * meter, v67 * meter, v68 * meter)

								if v72 > 0.0001 then
									v76 = (v72 * v59 + v64 + 0.02) / v72
									v77, v78 = WorldRay.cast(
										vector3,
										Vector3.new(v69, v70, v71) * (v76 * meter),
										raycastParams,
										true
									)
								end

								if not v77 and (v25[v58] or v72 <= 0.0001) then
									v79 = v64 + 0.02 + math.max(-v70, 0) * v59
									v77, v78 = WorldRay.cast(
										vector3,
										Vector3.new(0, -v79 * meter, 0),
										raycastParams,
										true
									)
								end

								if v77 and v78 then
									v74 = (v77.X * v78.X + v77.Y * v78.Y + v77.Z * v78.Z) / meter
									v75 = v66 * v78.X + v67 * v78.Y + v68 * v78.Z - v74 - v64
									v73 = v78
								end
							end

							v25[v58] = false

							if v73 then
								x = v73.X
								y = v73.Y
								z = v73.Z

								if v75 < 0 then
									v66 -= x * v75
									v67 -= y * v75
									v68 -= z * v75
									v75 = 0
								end

								v80 = v69 * x + v70 * y + v71 * z
								v81 = -v75 / v59

								if v80 < v81 then
									if v75 <= 0.02 and v57 < -v80 then
										v81 = -v80 * 0.25 * collide
									end

									v69 += x * (v81 - v80)
									v70 += y * (v81 - v80)
									v71 += z * (v81 - v80)
								end

								if v75 <= 0.02 then
									v25[v58] = y > 0.5
									v82 = (1 - v62.sticky) ^ v60
									v69 *= v82
									v70 *= v82
									v71 *= v82
									v83 = v26
									v83[v58] *= 0.85 ^ v60

									if v69 * v69 + v70 * v70 + v71 * v71 < v56 then
										v84 = v66 - x * (v75 + v64)
										v85 = v67 - y * (v75 + v64)
										v86 = v68 - z * (v75 + v64)
										v87 = v28
										v88 = v29
										v89 = v30
										v27[v58] = v84
										v87[v58] = v85
										v88[v58] = v86
										v89[v58] = v73
										v90 = v2
										v91 = v3
										v92 = v4
										v93 = v84 + x * v64
										v94 = v85 + y * v64
										v95 = v86 + z * v64
										v90[v58] = v93
										v91[v58] = v94
										v92[v58] = v95
										v96 = v6
										v97 = v7
										v5[v58] = 0
										v96[v58] = 0
										v97[v58] = 0
										settleFlat(v58, v73)
										v24[v58] = true
										v31[v58] = 0
										v42[v58] = -1
									else
										if v25[v58] and v31[v58] == 0 and ParticleSim.glide then
											v98 = math.sqrt(v69 * v69 + v70 * v70 + v71 * v71)
											v99 = math.min(0.1, 0.4 / v98)

											if v99 >= 1 / 30 then
												v100 = (v98 * v99 + v64 + 0.02) / v98
												vector3_2 = Vector3.new(v66 * meter, v67 * meter, v68 * meter)

												if not WorldRay.cast(
													vector3_2,
													Vector3.new(v69, v70, v71) * (v100 * meter),
													raycastParams,
													true
												) then
													v101 = v32
													v102 = v33
													v31[v58] = v61 + v99
													v101[v58] = v73
													v102[v58] = v74
												end
											end
										end

										v103 = v66 + v69 * v59
										v104 = v67 + v70 * v59
										v105 = v68 + v71 * v59
										v106 = v70 + evaluate(v62.gravity, v14[v58], v15[v58], v63) * gravityScale * v59
										drag = v62.drag

										if drag > 0 then
											v107 = (1 / (math.sqrt(v69 * v69 + v106 * v106 + v71 * v71) / v55 + 1)) ^ (drag * 0.1 * v59 / (1 / 60))
											v69 *= v107
											v106 *= v107
											v71 *= v107
										end

										v108 = v3
										v109 = v4
										v2[v58] = v103
										v108[v58] = v104
										v109[v58] = v105
										v110 = v6
										v111 = v7
										v5[v58] = v69
										v110[v58] = v106
										v111[v58] = v71
									end
								else
									v103 = v66 + v69 * v59
									v104 = v67 + v70 * v59
									v105 = v68 + v71 * v59
									v106 = v70 + evaluate(v62.gravity, v14[v58], v15[v58], v63) * gravityScale * v59
									drag = v62.drag

									if drag > 0 then
										v107 = (1 / (math.sqrt(v69 * v69 + v106 * v106 + v71 * v71) / v55 + 1)) ^ (drag * 0.1 * v59 / (1 / 60))
										v69 *= v107
										v106 *= v107
										v71 *= v107
									end

									v108 = v3
									v109 = v4
									v2[v58] = v103
									v108[v58] = v104
									v109[v58] = v105
									v110 = v6
									v111 = v7
									v5[v58] = v69
									v110[v58] = v106
									v111[v58] = v71
								end
							else
								v103 = v66 + v69 * v59
								v104 = v67 + v70 * v59
								v105 = v68 + v71 * v59
								v106 = v70 + evaluate(v62.gravity, v14[v58], v15[v58], v63) * gravityScale * v59
								drag = v62.drag

								if drag > 0 then
									v107 = (1 / (math.sqrt(v69 * v69 + v106 * v106 + v71 * v71) / v55 + 1)) ^ (drag * 0.1 * v59 / (1 / 60))
									v69 *= v107
									v106 *= v107
									v71 *= v107
								end

								v108 = v3
								v109 = v4
								v2[v58] = v103
								v108[v58] = v104
								v109[v58] = v105
								v110 = v6
								v111 = v7
								v5[v58] = v69
								v110[v58] = v106
								v111[v58] = v71
							end
						else
							v103 = v66 + v69 * v59
							v104 = v67 + v70 * v59
							v105 = v68 + v71 * v59
							v106 = v70 + evaluate(v62.gravity, v14[v58], v15[v58], v63) * gravityScale * v59
							drag = v62.drag

							if drag > 0 then
								v107 = (1 / (math.sqrt(v69 * v69 + v106 * v106 + v71 * v71) / v55 + 1)) ^ (drag * 0.1 * v59 / (1 / 60))
								v69 *= v107
								v106 *= v107
								v71 *= v107
							end

							v108 = v3
							v109 = v4
							v2[v58] = v103
							v108[v58] = v104
							v109[v58] = v105
							v110 = v6
							v111 = v7
							v5[v58] = v69
							v110[v58] = v106
							v111[v58] = v71
						end
					end
				end
			end
		else
			v59 = p
			v60 = v59 / (1 / 60)
			v44[v58] = true
			v61 = v8[v58] + v59

			if v9[v58] <= v61 then
				kill(v58)
			else
				v8[v58] = v61
				v62 = v22[v58]
				v63 = v61 / v9[v58]
				v64 = evaluate(v62.radius, v10[v58], v11[v58], v63)
				v34[v58] = v64
				v35[v58] = evaluate(v62.alpha, v12[v58], v13[v58], v63)
				v36[v58] = evaluate(v62.emissive, v18[v58], v19[v58], v63)

				if not v24[v58] then
					v65 = v20
					v65[v58] += evaluate(v62.rotation, v16[v58], v17[v58], v63) * v26[v58] * v59
					v66 = v2[v58]
					v67 = v3[v58]
					v68 = v4[v58]
					v69 = v5[v58]
					v70 = v6[v58]
					v71 = v7[v58]
					v72 = math.sqrt(v69 * v69 + v70 * v70 + v71 * v71)

					collide = v62.collide

					if collide > 0 then
						v74 = 0
						v75 = 0

						if v61 < v31[v58] then
							v73 = v32[v58]
							v74 = v33[v58]
							v75 = v66 * v73.X + v67 * v73.Y + v68 * v73.Z - v74 - v64

							if v75 > 0.02 then
								v31[v58] = 0
								v73 = nil
							end
						else
							v31[v58] = 0
							vector3 = Vector3.new(v66 * meter, v67 * meter, v68 * meter)

							if v72 > 0.0001 then
								v76 = (v72 * v59 + v64 + 0.02) / v72
								v77, v78 = WorldRay.cast(
									vector3,
									Vector3.new(v69, v70, v71) * (v76 * meter),
									raycastParams,
									true
								)
							end

							if not v77 and (v25[v58] or v72 <= 0.0001) then
								v79 = v64 + 0.02 + math.max(-v70, 0) * v59
								v77, v78 = WorldRay.cast(vector3, Vector3.new(0, -v79 * meter, 0), raycastParams, true)
							end

							if v77 and v78 then
								v74 = (v77.X * v78.X + v77.Y * v78.Y + v77.Z * v78.Z) / meter
								v75 = v66 * v78.X + v67 * v78.Y + v68 * v78.Z - v74 - v64
								v73 = v78
							end
						end

						v25[v58] = false

						if v73 then
							x = v73.X
							y = v73.Y
							z = v73.Z

							if v75 < 0 then
								v66 -= x * v75
								v67 -= y * v75
								v68 -= z * v75
								v75 = 0
							end

							v80 = v69 * x + v70 * y + v71 * z
							v81 = -v75 / v59

							if v80 < v81 then
								if v75 <= 0.02 and v57 < -v80 then
									v81 = -v80 * 0.25 * collide
								end

								v69 += x * (v81 - v80)
								v70 += y * (v81 - v80)
								v71 += z * (v81 - v80)
							end

							if v75 <= 0.02 then
								v25[v58] = y > 0.5
								v82 = (1 - v62.sticky) ^ v60
								v69 *= v82
								v70 *= v82
								v71 *= v82
								v83 = v26
								v83[v58] *= 0.85 ^ v60

								if v69 * v69 + v70 * v70 + v71 * v71 < v56 then
									v84 = v66 - x * (v75 + v64)
									v85 = v67 - y * (v75 + v64)
									v86 = v68 - z * (v75 + v64)
									v87 = v28
									v88 = v29
									v89 = v30
									v27[v58] = v84
									v87[v58] = v85
									v88[v58] = v86
									v89[v58] = v73
									v90 = v2
									v91 = v3
									v92 = v4
									v93 = v84 + x * v64
									v94 = v85 + y * v64
									v95 = v86 + z * v64
									v90[v58] = v93
									v91[v58] = v94
									v92[v58] = v95
									v96 = v6
									v97 = v7
									v5[v58] = 0
									v96[v58] = 0
									v97[v58] = 0
									settleFlat(v58, v73)
									v24[v58] = true
									v31[v58] = 0
									v42[v58] = -1
								else
									if v25[v58] and v31[v58] == 0 and ParticleSim.glide then
										v98 = math.sqrt(v69 * v69 + v70 * v70 + v71 * v71)
										v99 = math.min(0.1, 0.4 / v98)

										if v99 >= 1 / 30 then
											v100 = (v98 * v99 + v64 + 0.02) / v98
											vector3_2 = Vector3.new(v66 * meter, v67 * meter, v68 * meter)

											if not WorldRay.cast(
												vector3_2,
												Vector3.new(v69, v70, v71) * (v100 * meter),
												raycastParams,
												true
											) then
												v101 = v32
												v102 = v33
												v31[v58] = v61 + v99
												v101[v58] = v73
												v102[v58] = v74
											end
										end
									end

									v103 = v66 + v69 * v59
									v104 = v67 + v70 * v59
									v105 = v68 + v71 * v59
									v106 = v70 + evaluate(v62.gravity, v14[v58], v15[v58], v63) * gravityScale * v59
									drag = v62.drag

									if drag > 0 then
										v107 = (1 / (math.sqrt(v69 * v69 + v106 * v106 + v71 * v71) / v55 + 1)) ^ (drag * 0.1 * v59 / (1 / 60))
										v69 *= v107
										v106 *= v107
										v71 *= v107
									end

									v108 = v3
									v109 = v4
									v2[v58] = v103
									v108[v58] = v104
									v109[v58] = v105
									v110 = v6
									v111 = v7
									v5[v58] = v69
									v110[v58] = v106
									v111[v58] = v71
								end
							else
								v103 = v66 + v69 * v59
								v104 = v67 + v70 * v59
								v105 = v68 + v71 * v59
								v106 = v70 + evaluate(v62.gravity, v14[v58], v15[v58], v63) * gravityScale * v59
								drag = v62.drag

								if drag > 0 then
									v107 = (1 / (math.sqrt(v69 * v69 + v106 * v106 + v71 * v71) / v55 + 1)) ^ (drag * 0.1 * v59 / (1 / 60))
									v69 *= v107
									v106 *= v107
									v71 *= v107
								end

								v108 = v3
								v109 = v4
								v2[v58] = v103
								v108[v58] = v104
								v109[v58] = v105
								v110 = v6
								v111 = v7
								v5[v58] = v69
								v110[v58] = v106
								v111[v58] = v71
							end
						else
							v103 = v66 + v69 * v59
							v104 = v67 + v70 * v59
							v105 = v68 + v71 * v59
							v106 = v70 + evaluate(v62.gravity, v14[v58], v15[v58], v63) * gravityScale * v59
							drag = v62.drag

							if drag > 0 then
								v107 = (1 / (math.sqrt(v69 * v69 + v106 * v106 + v71 * v71) / v55 + 1)) ^ (drag * 0.1 * v59 / (1 / 60))
								v69 *= v107
								v106 *= v107
								v71 *= v107
							end

							v108 = v3
							v109 = v4
							v2[v58] = v103
							v108[v58] = v104
							v109[v58] = v105
							v110 = v6
							v111 = v7
							v5[v58] = v69
							v110[v58] = v106
							v111[v58] = v71
						end
					else
						v103 = v66 + v69 * v59
						v104 = v67 + v70 * v59
						v105 = v68 + v71 * v59
						v106 = v70 + evaluate(v62.gravity, v14[v58], v15[v58], v63) * gravityScale * v59
						drag = v62.drag

						if drag > 0 then
							v107 = (1 / (math.sqrt(v69 * v69 + v106 * v106 + v71 * v71) / v55 + 1)) ^ (drag * 0.1 * v59 / (1 / 60))
							v69 *= v107
							v106 *= v107
							v71 *= v107
						end

						v108 = v3
						v109 = v4
						v2[v58] = v103
						v108[v58] = v104
						v109[v58] = v105
						v110 = v6
						v111 = v7
						v5[v58] = v69
						v110[v58] = v106
						v111[v58] = v71
					end
				end
			end
		end

		v58 -= 1
	end
end

local function render()
	if v == 0 then
		return
	end

	local count2 = 0
	local currentCamera = workspace.CurrentCamera
	local v55

	if currentCamera then
		v55 = currentCamera.CFrame
	else
		v55 = CFrame.identity
	end

	local v56 = v55.Position / meter
	local x = v56.X
	local y = v56.Y
	local z = v56.Z

	local lookVector = v55.LookVector
	local x2 = lookVector.X
	local y2 = lookVector.Y
	local z2 = lookVector.Z
	local v57

	if currentCamera then
		local viewportSize = currentCamera.ViewportSize
		local v58 = viewportSize.X / math.max(viewportSize.Y, 1)
		v57 = math.cos((math.min(
			math.atan(math.tan(math.rad((math.max(currentCamera.FieldOfView, 80))) * 0.5) * math.sqrt(1 + v58 * v58)) + 0.5235987755982988,
			3.141592653589793
		)))
	else
		v57 = -2
	end

	for i = 1, v do
		if not v44[i] then
			continue
		end

		local v58 = v37[i]
		local v59 = math.max(v34[i] * 2 * meter, 0.01)
		local v60 = v2[i] - x
		local v61 = v3[i] - y
		local v62 = v4[i] - z
		local v63 = math.sqrt(v60 * v60 + v61 * v61 + v62 * v62)
		local v64 = v59 / meter + 0.1

		if v64 < v63 and v60 * x2 + v61 * y2 + v62 * z2 + v64 < v63 * v57 then
			local v65 = v47[i] - x
			local v66 = v48[i] - y
			local v67 = v49[i] - z
			local v68 = math.sqrt(v65 * v65 + v66 * v66 + v67 * v67)
			local v69 = v50[i] + 0.1

			if v69 < v68 and v65 * x2 + v66 * y2 + v67 * z2 + v69 < v68 * v57 then
				v42[i] = -1
				continue
			end
		end

		v44[i] = false
		local v65 = v39[i]

		local v66 = math.max(0.08, v63 * (meter * 0.002))
		local v67 = math.abs(v59 - v65)

		if v65 * v66 + 0.005 < v67 then
			v58.Size = Vector3.new(v59, v59, v59)
			v39[i] = v59
			v50[i] = v59 * 0.8661 / meter
		end

		local v68 = math.clamp(v35[i], 0, 1)

		if math.abs(v68 - v40[i]) > 0.04 then
			local transparency

			if Quality.mobile then
				transparency = v68 > 0.4 and 0 or 1
			else
				transparency = 1 - v68
			end

			v58.Transparency = transparency
			v40[i] = v68
		end

		local v69 = v18[i]

		if v69 > 0 then
			local v70 = math.clamp(v36[i] / v69, 0, 1)

			if math.abs(v70 - v41[i]) > 0.05 then
				local color = v23[i]
				local v71 = v70 * 0.85 + 0.15
				local color2 = Color3.new(color.R * v71, color.G * v71, color.B * v71)
				v58.Color = color2
				v53[v58].color = color2
				v41[i] = v70
			end
		end

		local v70 = v2[i]
		local v71 = v3[i]
		local v72 = v4[i]

		if v24[i] then
			local vector3 = v30[i]
			local v73 = v34[i]

			if v73 == v42[i] then
				continue
			end

			v42[i] = v73
			v70 = v27[i] + vector3.X * v73
			v71 = v28[i] + vector3.Y * v73
			v72 = v29[i] + vector3.Z * v73
		else
			v42[i] = -1
		end

		local v73 = CFrame.fromAxisAngle(v21[i], v20[i]) + Vector3.new(v70 * meter, v71 * meter, v72 * meter)
		v38[i] = v73
		v47[i] = v70
		v48[i] = v71
		v49[i] = v72
		count2 += 1
		v45[count2] = v58
		v46[count2] = v73
	end

	for i = count2 + 1, #v45 do
		v45[i] = nil
		v46[i] = nil
	end

	if count2 > 0 then
		workspace:BulkMoveTo(v45, v46, Enum.BulkMoveMode.FireCFrameChanged)
	end
end

local v55 = 0
local v56 = false

function ParticleSim.start(p)
	parent = p
	refreshFilter() -- inferred equivalent call
	local localPlayer = Players.LocalPlayer

	if localPlayer then
		localPlayer.CharacterAdded:Connect(function()
			task.defer(refreshFilter)
		end)
	end

	RunService.Heartbeat:Connect(function(dt)
		debug.profilebegin("Voxel.particles")

		if Detail.low then
			if v > 0 then
				tick(dt, true)
			end

			v55 = 0
		else
			v55 = math.min(v55 + dt, 0.05)

			while v55 >= 1 / 60 do
				tick(1 / 60, false)
				v55 -= 1 / 60
			end
		end

		if v == 0 and not v56 then
			local v57 = math.min(200, Quality.cap(1200))

			for _ = 1, 8 do
				if v57 <= #v52 then
					v56 = true
					break
				end

				local part = newChip() -- inferred equivalent call
				part.Transparency = 1
				v53[part] = {
					material = part.Material,
					variant = part.MaterialVariant,
					color = part.Color
				}
				part.Parent = parent
				table.insert(v52, part)
			end
		end

		debug.profileend()
	end)

	RunService:BindToRenderStep("VoxelParticles", Enum.RenderPriority.Last.Value, function()
		debug.profilebegin("Voxel.particlesDraw")
		render()
		debug.profileend()
	end)
end

return ParticleSim