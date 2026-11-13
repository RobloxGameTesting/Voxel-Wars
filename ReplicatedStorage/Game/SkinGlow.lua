local CollectionService = game:GetService("CollectionService")
local MaterialService = game:GetService("MaterialService")
local RunService = game:GetService("RunService")

local SkinGlow = {
	["TAG"] = nil,
	["TAG"] = nil,
	["TAG"] = nil,
	["TAG"] = nil,
	TAG = "SkinGlow"
}

local function rgb(p: number, p2: number, p3: number) -- 59 equivalent calls inferred from this helper
	return Color3.fromRGB(p, p2, p3)
end

local function smooth(value: number) -- 22 equivalent calls inferred from this helper
	local v = math.clamp(value, 0, 1)
	return v * v * (3 - v * 2)
end

local v = -10
local v2 = 0
local function storm(p: number)
	if v2 <= p then
		v = p
		v2 = p + 1.4 + math.random() * 2.4
	end

	local v3 = p - v
	local v4 = math.exp(-v3 * 14) + (not (v3 > 0.11) and 0 or math.exp(-(v3 - 0.11) * 9) * 0.8)
	return (math.clamp(math.sin(p * 2.3) * 0.05 + 0.12 + v4, 0, 1))
end

local function bursts(p: number, p2: number, p3: number, p4: number, p5: number)
	local v3 = -100
	local v4 = 0
	return function(p6: number)
		if v4 <= p6 then
			v3 = p6
			v4 = p6 + p + math.random() * (p2 - p)
		end

		local v5 = p6 - v3

		if v5 < p3 then
			return smooth(v5 / p3) -- inferred equivalent call
		end

		if v5 < p3 + p4 then
			return 1
		end

		return (math.max(0, 1 - (v5 - p3 - p4) / p5))
	end
end

local v3 = -100
local v4 = 0
local v5 = 1.2
local v6 = 2.5
local v7 = 0.03
local v8 = 0.05
local v9 = 0.12
local function fn(p: number)
	if v4 <= p then
		v3 = p
		v4 = p + v5 + math.random() * (v6 - v5)
	end

	local v10 = p - v3

	if v10 < v7 then
		return smooth(v10 / v7) -- inferred equivalent call
	end

	if v10 < v7 + v8 then
		return 1
	end

	return (math.max(0, 1 - (v10 - v7 - v8) / v9))
end

local v10 = -100
local v11 = 0
local v12 = 4
local v13 = 8
local v14 = 0.6
local v15 = 0.3
local v16 = 1.2
local function fn2(p: number)
	if v11 <= p then
		v10 = p
		v11 = p + v12 + math.random() * (v13 - v12)
	end

	local v17 = p - v10

	if v17 < v14 then
		return smooth(v17 / v14) -- inferred equivalent call
	end

	if v17 < v14 + v15 then
		return 1
	end

	return (math.max(0, 1 - (v17 - v14 - v15) / v16))
end

local v17 = -100
local v18 = 0
local v19 = 6
local v20 = 10
local v21 = 0.08
local v22 = 0.15
local v23 = 0.7
local function fn3(p: number)
	if v18 <= p then
		v17 = p
		v18 = p + v19 + math.random() * (v20 - v19)
	end

	local v24 = p - v17

	if v24 < v21 then
		return smooth(v24 / v21) -- inferred equivalent call
	end

	if v24 < v21 + v22 then
		return 1
	end

	return (math.max(0, 1 - (v24 - v21 - v22) / v23))
end

local v24 = -100
local v25 = 0
local v26 = 2.5
local v27 = 6
local v28 = 0.08
local v29 = 0
local v30 = 0.35
local function fn4(p: number)
	if v25 <= p then
		v24 = p
		v25 = p + v26 + math.random() * (v27 - v26)
	end

	local v31 = p - v24

	if v31 < v28 then
		return smooth(v31 / v28) -- inferred equivalent call
	end

	if v31 < v28 + v29 then
		return 1
	end

	return (math.max(0, 1 - (v31 - v28 - v29) / v30))
end

local v31 = -100
local v32 = 0
local v33 = 3
local v34 = 5
local v35 = 0.05
local v36 = 0.03
local v37 = 0.12
local function fn5(p: number)
	if v32 <= p then
		v31 = p
		v32 = p + v33 + math.random() * (v34 - v33)
	end

	local v38 = p - v31

	if v38 < v35 then
		return smooth(v38 / v35) -- inferred equivalent call
	end

	if v38 < v35 + v36 then
		return 1
	end

	return (math.max(0, 1 - (v38 - v35 - v36) / v37))
end

local v38 = -100
local v39 = 0
local v40 = 7
local v41 = 12
local v42 = 0.25
local v43 = 0.2
local v44 = 1.2
local function fn6(p: number)
	if v39 <= p then
		v38 = p
		v39 = p + v40 + math.random() * (v41 - v40)
	end

	local v45 = p - v38

	if v45 < v42 then
		return smooth(v45 / v42) -- inferred equivalent call
	end

	if v45 < v42 + v43 then
		return 1
	end

	return (math.max(0, 1 - (v45 - v42 - v43) / v44))
end

local v45 = -100
local v46 = 0
local v47 = 5
local v48 = 9
local v49 = 0.15
local v50 = 0.25
local v51 = 0.9
local function fn7(p: number)
	if v46 <= p then
		v45 = p
		v46 = p + v47 + math.random() * (v48 - v47)
	end

	local v52 = p - v45

	if v52 < v49 then
		return smooth(v52 / v49) -- inferred equivalent call
	end

	if v52 < v49 + v50 then
		return 1
	end

	return (math.max(0, 1 - (v52 - v49 - v50) / v51))
end

local v52 = -100
local v53 = 0
local v54 = 6
local v55 = 11
local v56 = 0.4
local v57 = 0.2
local v58 = 1.4
local function fn8(p: number)
	if v53 <= p then
		v52 = p
		v53 = p + v54 + math.random() * (v55 - v54)
	end

	local v59 = p - v52

	if v59 < v56 then
		return smooth(v59 / v56) -- inferred equivalent call
	end

	if v59 < v56 + v57 then
		return 1
	end

	return (math.max(0, 1 - (v59 - v56 - v57) / v58))
end

local v59 = {
	rgb(255, 74, 106), -- inferred equivalent call
	rgb(255, 208, 64), -- inferred equivalent call
	rgb(90, 255, 120), -- inferred equivalent call
	rgb(64, 224, 255), -- inferred equivalent call
	rgb(80, 110, 255), -- inferred equivalent call
	rgb(160, 96, 255)
}

SkinGlow.PROFILES = {
	MOLTEN = {
		variant = "WeaponSkinMolten",
		low = rgb(255, 52, 8), -- inferred equivalent call
		high = rgb(255, 172, 64), -- inferred equivalent call
		min = 0.9,
		max = 3.4,
		wave = function(p: number)
			local v60 = smooth(math.sin(6.283185307179586 * p / 2.6) * 0.5 + 0.5) -- inferred equivalent call
			local v61 = (math.sin(p * 7.3) + math.sin(p * 11.7 + 1.3) + math.sin(p * 17.9 + 2.1)) / 3
			return (math.clamp(v60 * 0.8 + 0.1 + v61 * 0.12, 0, 1))
		end
	},
	STORMGLASS = {
		variant = "WeaponSkinStormglass",
		low = rgb(70, 130, 255), -- inferred equivalent call
		high = rgb(215, 238, 255), -- inferred equivalent call
		min = 0.8,
		max = 6,
		wave = storm
	},
	DEEP_FIELD = {
		variant = "WeaponSkinDeepField",
		low = rgb(160, 180, 255), -- inferred equivalent call
		high = rgb(235, 205, 255), -- inferred equivalent call
		min = 1.5,
		max = 3.2,
		wave = function(p: number)
			return (math.clamp(math.sin(6.283185307179586 * p / 5) * 0.38 + 0.5 + math.sin(p * 3.1) * 0.12, 0, 1))
		end
	},
	GEODE = {
		variant = "WeaponSkinGeode",
		low = rgb(150, 95, 255), -- inferred equivalent call
		high = rgb(225, 170, 255), -- inferred equivalent call
		min = 1.2,
		max = 2.8,
		wave = function(p: number)
			return smooth(math.sin(6.283185307179586 * p / 4) * 0.5 + 0.5) -- inferred equivalent call
		end
	},
	CIRCUIT = {
		variant = "WeaponSkinCircuit",
		low = rgb(80, 220, 140), -- inferred equivalent call
		high = rgb(170, 255, 200), -- inferred equivalent call
		min = 0.6,
		max = 2.4,
		wave = function(p: number)
			return (math.clamp(0.1 + 0.9 * fn(p), 0, 1))
		end
	},
	TOXIC = {
		variant = "WeaponSkinToxic",
		low = rgb(110, 230, 50), -- inferred equivalent call
		high = rgb(170, 255, 90), -- inferred equivalent call
		min = 0.7,
		max = 2,
		wave = function(p: number)
			return (math.clamp(smooth(math.sin(6.283185307179586 * p / 3.2) * 0.5 + 0.5) * 0.75 + 0.25 * fn2(p), 0, 1)) -- inferred equivalent call
		end
	},
	PLASMA = {
		variant = "WeaponSkinPlasma",
		low = rgb(255, 225, 255), -- inferred equivalent call
		high = rgb(235, 250, 255), -- inferred equivalent call
		min = 1,
		max = 2.6,
		wave = function(p: number)
			return (math.clamp(
				smooth(math.sin(6.283185307179586 * p / 4) * 0.5 + 0.5) * 0.8 + 0.1 + math.sin(p * 13.1) * 0.08, -- inferred equivalent call
				0,
				1
			))
		end
	},
	HEXGRID = {
		variant = "WeaponSkinHexgrid",
		low = rgb(255, 140, 40), -- inferred equivalent call
		high = rgb(255, 200, 110), -- inferred equivalent call
		min = 0.8,
		max = 2.8,
		wave = function(p: number)
			return (math.clamp(
				smooth(math.sin(6.283185307179586 * p / 2.4) * 0.5 + 0.5) * 0.2 + 0.15 + 0.65 * fn3(p), -- inferred equivalent call
				0,
				1
			))
		end
	},
	FROSTBITE = {
		variant = "WeaponSkinFrostbite",
		low = rgb(111, 180, 255), -- inferred equivalent call
		high = rgb(255, 255, 255), -- inferred equivalent call
		min = 0.6,
		max = 2.4,
		wave = function(p: number)
			return (math.clamp(
				smooth(math.sin(6.283185307179586 * p / 4.5) * 0.5 + 0.5) * 0.3 + 0.15 + 0.55 * fn4(p), -- inferred equivalent call
				0,
				1
			))
		end
	},
	HOLO = {
		variant = "WeaponSkinHolo",
		low = rgb(255, 255, 255), -- inferred equivalent call
		high = rgb(255, 255, 255), -- inferred equivalent call
		min = 1.3,
		max = 2.4,
		wave = function(p: number)
			return (math.clamp(
				smooth(math.sin(6.283185307179586 * p / 3) * 0.5 + 0.5) * 0.3 + 0.25 + 0.45 * fn5(p), -- inferred equivalent call
				0,
				1
			))
		end,
		tint = function(p: number, _: number)
			local v60 = p / 8 % 1 * #v59
			local v61 = math.floor(v60)
			return v59[v61 + 1]:Lerp(v59[(v61 + 1) % #v59 + 1], smooth(v60 - v61)) -- inferred equivalent call
		end
	},
	DRAGONSCALE = {
		variant = "WeaponSkinDragonscale",
		low = rgb(255, 48, 16), -- inferred equivalent call
		high = rgb(255, 208, 112), -- inferred equivalent call
		min = 0.9,
		max = 4.2,
		wave = function(p: number)
			local v60 = p % 3.6
			local v61

			if v60 < 1.6 then
				v61 = smooth(v60 / 1.6) -- inferred equivalent call
			else
				v61 = smooth(1 - (v60 - 1.6) / 2) -- inferred equivalent call
			end

			local midpoint = (math.sin(p * 23.1) + math.sin(p * 31.7 + 1.1)) / 2
			return (math.clamp(v61 * 0.45 + 0.55 * fn6(p) + midpoint * 0.03, 0, 1))
		end
	},
	AFTERBURN = {
		variant = "WeaponSkinAfterburn",
		low = rgb(255, 110, 20), -- inferred equivalent call
		high = rgb(255, 190, 110), -- inferred equivalent call
		min = 0.7,
		max = 2.6,
		wave = function(p: number)
			return (math.clamp(
				smooth(math.sin(6.283185307179586 * p / 3) * 0.5 + 0.5) * 0.25 + 0.2 + 0.55 * fn7(p), -- inferred equivalent call
				0,
				1
			))
		end
	},
	FANG = {
		variant = "WeaponSkinFang",
		low = rgb(120, 230, 40), -- inferred equivalent call
		high = rgb(210, 255, 110), -- inferred equivalent call
		min = 0.7,
		max = 2.2,
		wave = function(p: number)
			local v60 = p % 2.2
			return (math.clamp(
				(math.exp(-v60 * 6) + (not (v60 > 0.35) and 0 or math.exp(-(v60 - 0.35) * 7) * 0.7)) * 0.85 + 0.15,
				0,
				1
			))
		end
	},
	CINDER = {
		variant = "WeaponSkinCinder",
		low = rgb(255, 60, 10), -- inferred equivalent call
		high = rgb(255, 150, 40), -- inferred equivalent call
		min = 0.7,
		max = 2.2,
		wave = function(p: number)
			local v60 = smooth(math.sin(6.283185307179586 * p / 3.4) * 0.5 + 0.5) -- inferred equivalent call
			local v61 = (math.sin(p * 8.9) + math.sin(p * 13.3 + 0.7) + math.sin(p * 21.1 + 2.4)) / 3
			return (math.clamp(v60 * 0.7 + 0.15 + v61 * 0.15, 0, 1))
		end
	},
	PHANTOM = {
		variant = "WeaponSkinPhantom",
		low = rgb(120, 90, 255), -- inferred equivalent call
		high = rgb(215, 195, 255), -- inferred equivalent call
		min = 0.6,
		max = 2.4,
		wave = function(p: number)
			return (math.clamp(
				smooth(math.sin(6.283185307179586 * p / 5.5) * 0.5 + 0.5) * 0.45 + 0.15 + 0.4 * fn8(p), -- inferred equivalent call
				0,
				1
			))
		end
	}
}

local flag = false

function SkinGlow.start()
	assert(RunService:IsClient(), "SkinGlow.start runs on the client")

	if flag then
		return
	end

	flag = true
	local v60 = {}

	for k, v61 in SkinGlow.PROFILES do
		local materialVariants = {}

		for _, childName in { v61.variant, v61.variant .. "View" } do
			local materialVariant = MaterialService:WaitForChild(childName, 30)
			assert(
				materialVariant and materialVariant:IsA("MaterialVariant"),
				"SkinGlow: no MaterialVariant " .. childName
			)
			table.insert(materialVariants, materialVariant)
		end

		v60[k] = materialVariants
	end

	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Detail = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("Detail"))

	local v61 = {}

	for k in SkinGlow.PROFILES do
		v61[k] = {}
	end

	local v62 = true
	local v63 = 0
	local function dirty()
		v62 = true
	end
	CollectionService:GetInstanceAddedSignal(SkinGlow.TAG):Connect(dirty)
	CollectionService:GetInstanceRemovedSignal(SkinGlow.TAG):Connect(dirty)

	local v64 = {}
	local v65 = {}
	local v66 = 0
	RunService.Heartbeat:Connect(function()
		local now = os.clock()

		if now - v66 < ((Detail.low or Detail.strain >= 1) and 1 / 15 or 1 / 30) then
			return
		end

		v66 = now

		if v62 or now - v63 >= 2 then
			v62 = false
			v63 = now

			for _, list in v61 do
				table.clear(list)
			end

			for _, surfaceAppearance in CollectionService:GetTagged(SkinGlow.TAG) do
				local surfaceAppearances = v61[surfaceAppearance.Name]

				if surfaceAppearances and surfaceAppearance:IsA("SurfaceAppearance") then
					table.insert(surfaceAppearances, surfaceAppearance)
				end
			end

			table.clear(v64)
		end

		for k, v67 in SkinGlow.PROFILES do
			local wave = v67.wave(now)
			local emissiveStrength = v67.min + (v67.max - v67.min) * wave
			local emissiveTint

			if v67.tint then
				emissiveTint = v67.tint(now, wave)
			else
				emissiveTint = v67.low:Lerp(v67.high, wave)
			end

			if not (v64[k] ~= emissiveStrength or v65[k] ~= emissiveTint) then
				continue
			end

			v64[k] = emissiveStrength
			v65[k] = emissiveTint

			for _, v70 in v60[k] do
				v70.EmissiveStrength = emissiveStrength
				v70.EmissiveTint = emissiveTint
			end

			for _, v70 in v61[k] do
				v70.EmissiveStrength = emissiveStrength
				v70.EmissiveTint = emissiveTint
			end
		end
	end)
end

local v60 = {
	MOLTEN = {
		count = 34,
		colours = { rgb(255, 214, 110), rgb(255, 132, 30), rgb(214, 52, 12) }, -- inferred equivalent call
		size = 0.016,
		rise = 0.16,
		spread = 0.03,
		life = 2.4
	},
	STORMGLASS = {
		count = 14,
		colours = { rgb(225, 242, 255), rgb(110, 175, 255) }, -- inferred equivalent call
		size = 0.008,
		rise = 0.02,
		spread = 0.06,
		life = 0.5,
		blink = true
	},
	DEEP_FIELD = {
		count = 22,
		colours = { rgb(240, 236, 255), rgb(190, 170, 255), rgb(150, 200, 255) }, -- inferred equivalent call
		size = 0.007,
		rise = 0.015,
		spread = 0.02,
		life = 3.2,
		blink = true
	},
	GEODE = {
		count = 12,
		colours = { rgb(220, 180, 255), rgb(170, 110, 255) }, -- inferred equivalent call
		size = 0.009,
		rise = 0.03,
		spread = 0.015,
		life = 2.2
	},
	CIRCUIT = {
		count = 12,
		colours = { rgb(150, 255, 190), rgb(80, 220, 140) }, -- inferred equivalent call
		size = 0.006,
		rise = 0.01,
		spread = 0.03,
		life = 0.6,
		blink = true
	},
	TOXIC = {
		count = 16,
		colours = { rgb(170, 255, 90), rgb(110, 230, 50) }, -- inferred equivalent call
		size = 0.012,
		rise = 0.05,
		spread = 0.01,
		life = 2.4
	},
	PLASMA = {
		count = 16,
		colours = { rgb(255, 90, 230), rgb(80, 220, 255), rgb(190, 120, 255) }, -- inferred equivalent call
		size = 0.008,
		rise = 0.02,
		spread = 0.03,
		life = 1.8,
		blink = true
	},
	HEXGRID = {
		count = 14,
		colours = { rgb(255, 200, 110), rgb(255, 140, 40) }, -- inferred equivalent call
		size = 0.008,
		rise = 0.04,
		spread = 0.02,
		life = 1.4
	},
	FROSTBITE = {
		count = 24,
		colours = { rgb(240, 250, 255), rgb(160, 220, 255) }, -- inferred equivalent call
		size = 0.008,
		rise = -0.02,
		spread = 0.03,
		life = 2.6,
		blink = true
	},
	HOLO = {
		count = 22,
		colours = {
			rgb(255, 74, 106), -- inferred equivalent call
			rgb(255, 208, 64), -- inferred equivalent call
			rgb(90, 255, 120), -- inferred equivalent call
			rgb(64, 224, 255), -- inferred equivalent call
			rgb(160, 96, 255)
		},
		size = 0.007,
		rise = 0.01,
		spread = 0.025,
		life = 1.6,
		blink = true
	},
	AFTERBURN = {
		count = 14,
		colours = { rgb(255, 210, 140), rgb(255, 140, 40) }, -- inferred equivalent call
		size = 0.007,
		rise = 0.02,
		spread = 0.05,
		life = 0.7,
		blink = true
	},
	FANG = {
		count = 14,
		colours = { rgb(228, 255, 138), rgb(140, 235, 50) }, -- inferred equivalent call
		size = 0.01,
		rise = -0.04,
		spread = 0.01,
		life = 2.2
	},
	CINDER = {
		count = 28,
		colours = { rgb(255, 200, 100), rgb(255, 138, 40), rgb(216, 66, 12) }, -- inferred equivalent call
		size = 0.013,
		rise = 0.14,
		spread = 0.03,
		life = 2.2
	},
	PHANTOM = {
		count = 18,
		colours = { rgb(230, 220, 255), rgb(160, 130, 255) }, -- inferred equivalent call
		size = 0.009,
		rise = 0.05,
		spread = 0.02,
		life = 3,
		blink = true
	},
	DRAGONSCALE = {
		count = 40,
		colours = { rgb(255, 214, 110), rgb(255, 120, 30), rgb(220, 50, 12) }, -- inferred equivalent call
		size = 0.016,
		rise = 0.18,
		spread = 0.035,
		life = 2.4
	}
}

function SkinGlow.hasFx(p: string?): boolean
	return p ~= nil and v60[p] ~= nil
end

function SkinGlow.fx(parent, vector3: Vector3, vector3_2: Vector3, p: string)
	local v61 = v60[p]
	assert(v61, "SkinGlow: no fx for " .. p)
	local v62 = vector3_2 - vector3
	local v63 = math.max(v62.X, v62.Y, v62.Z)
	local skinFx = Instance.new("Folder")
	skinFx.Name = "SkinFx"

	local function spawn(options, now: number, flag2: boolean)
		local part

		if options then
			part = options.part
		else
			part = Instance.new("Part")
		end

		if not options then
			part.Anchored = true
			part.CanCollide = false
			part.CastShadow = false
			part.Material = Enum.Material.Neon
			part.Parent = skinFx
		end

		local v65

		if v61.rise > 0.1 then
			v65 = vector3.Y + v62.Y * math.random() * 0.6
		else
			v65 = vector3.Y + v62.Y * math.random()
		end

		local vector3_3 = Vector3.new(vector3.X + v62.X * math.random(), v65, vector3.Z + v62.Z * math.random())
		local life = v61.life * (0.6 + 0.8 * math.random())
		local size = v63 * v61.size * (0.6 + 0.8 * math.random())
		local v68 = Vector3.new(math.random() - 0.5, 0, math.random() - 0.5) * 2 * v63 * v61.spread
		local v69 = options or {}
		v69.part = part

		if flag2 then
			now -= life * math.random()
		end

		v69.born = now
		v69.life = life
		v69.at = vector3_3
		v69.vel = Vector3.new(0, v63 * v61.rise * (0.6 + 0.8 * math.random()), 0) + v68
		v69.size = size
		v69.colour = v61.colours[math.random(1, #v61.colours)]
		v69.spin = Vector3.new(math.random(), math.random(), math.random()) * 4
		v69.phase = math.random() * 6.283185307179586
		part.Color = v69.colour
		return v69
	end

	local now = os.clock()
	local v64 = {}

	for i = 1, v61.count do
		v64[i] = spawn(nil, now, true)
	end

	skinFx.Parent = parent
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local now2 = os.clock()

		for k, v65 in v64 do
			local v66 = now2 - v65.born

			if v65.life <= v66 then
				v65 = spawn(v65, now2, false)
				v64[k] = v65
				v66 = 0
			end

			local v67 = v66 / v65.life
			local v68 = Vector3.new(math.sin(now2 * 2.1 + v65.phase), 0, (math.cos(now2 * 1.7 + v65.phase))) * v63 * 0.006
			local v69 = v65.at + v65.vel * v66 + v68
			local v70 = math.min(v67 / 0.12, 1, (1 - v67) / 0.35)

			if v61.blink then
				v70 *= math.sin(now2 * 9 + v65.phase) * 0.5 + 0.5
			end

			local v71 = v65.size * (not (v61.rise > 0.1) and 1 or 1 - 0.6 * v67)
			v65.part.Size = Vector3.new(1, 1, 1) * v71
			v65.part.CFrame = CFrame.new(v69) * CFrame.Angles(v65.spin.X * v66, v65.spin.Y * v66, v65.spin.Z * v66)
			v65.part.Transparency = 1 - math.clamp(v70, 0, 1)

			if v61.rise > 0.1 then
				v65.part.Color = v65.colour:Lerp(rgb(150, 30, 8), v67 * 0.8) -- inferred equivalent call
			end
		end
	end)
	return function()
		renderSteppedConnection:Disconnect()
		skinFx:Destroy()
	end
end

return SkinGlow