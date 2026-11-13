local Lighting = game:GetService("Lighting")

local function id(p: number)
	return "rbxassetid://" .. p
end

local Environment = {}
Environment.Presets = {
	sunset = {
		sky = {
			bk = "rbxassetid://" .. 76885576066434,
			ft = "rbxassetid://" .. 126122805681279,
			lf = "rbxassetid://" .. 127699025002122,
			rt = "rbxassetid://" .. 136112594524812,
			up = "rbxassetid://" .. 94403968119429,
			dn = "rbxassetid://" .. 101105096644388,
			sun = "rbxassetid://" .. 127890164731340,
			sunSize = 12
		},
		clockTime = 17.55,
		latitude = 30,
		brightness = 2.6,
		sunColor = Color3.fromRGB(255, 186, 118),
		bounceColor = Color3.fromRGB(58, 50, 46),
		outdoorAmbient = Color3.fromRGB(86, 98, 122),
		ambient = Color3.fromRGB(44, 46, 56),
		diffuseScale = 0.55,
		specularScale = 0.5,
		shadowSoftness = 0.1,
		haze = {
			color = Color3.fromRGB(222, 176, 128),
			decay = Color3.fromRGB(108, 118, 140),
			density = 0.32,
			offset = 0.1,
			glare = 1,
			haze = 1.8
		},
		rays = { intensity = 0.08, spread = 0.45 },
		bloom = { intensity = 0.6, size = 30, threshold = 1.15 },
		grade = {
			brightness = -0.02,
			contrast = 0.2,
			saturation = -0.1,
			tint = Color3.fromRGB(255, 249, 240)
		},
		exposure = 0.1,
		clouds = { cover = 0.5, density = 0.55, color = Color3.fromRGB(206, 210, 220) }
	},
	afternoon = {
		sky = {
			bk = "rbxasset://textures/sky/sky512_bk.tex",
			ft = "rbxasset://textures/sky/sky512_ft.tex",
			lf = "rbxasset://textures/sky/sky512_lf.tex",
			rt = "rbxasset://textures/sky/sky512_rt.tex",
			up = "rbxasset://textures/sky/sky512_up.tex",
			dn = "rbxasset://textures/sky/sky512_dn.tex",
			sun = "rbxasset://sky/sun.jpg",
			sunSize = 11
		},
		clockTime = 15.3,
		latitude = 38,
		brightness = 2.6,
		sunColor = Color3.fromRGB(255, 238, 218),
		bounceColor = Color3.fromRGB(70, 66, 60),
		outdoorAmbient = Color3.fromRGB(124, 130, 140),
		ambient = Color3.fromRGB(84, 80, 82),
		diffuseScale = 0.8,
		specularScale = 0.4,
		shadowSoftness = 0.2,
		haze = {
			color = Color3.fromRGB(198, 206, 216),
			decay = Color3.fromRGB(150, 160, 178),
			density = 0.2,
			offset = 0.2,
			glare = 0.2,
			haze = 0.8
		},
		rays = { intensity = 0.03, spread = 0.5 },
		bloom = { intensity = 0.3, size = 24, threshold = 1.6 },
		grade = {
			brightness = 0,
			contrast = 0.06,
			saturation = -0.04,
			tint = Color3.fromRGB(255, 252, 248)
		},
		exposure = 0
	}
}

Environment.Presets.frontline = {
	sky = {
		bk = "rbxasset://textures/sky/sky512_bk.tex",
		ft = "rbxasset://textures/sky/sky512_ft.tex",
		lf = "rbxasset://textures/sky/sky512_lf.tex",
		rt = "rbxasset://textures/sky/sky512_rt.tex",
		up = "rbxasset://textures/sky/sky512_up.tex",
		dn = "rbxasset://textures/sky/sky512_dn.tex",
		sun = "rbxasset://sky/sun.jpg",
		sunSize = 8
	},
	clockTime = 14.6,
	latitude = 38,
	brightness = 3.2,
	sunColor = Color3.fromRGB(255, 232, 200),
	bounceColor = Color3.fromRGB(40, 46, 58),
	outdoorAmbient = Color3.fromRGB(88, 104, 132),
	ambient = Color3.fromRGB(46, 52, 64),
	diffuseScale = 0.55,
	specularScale = 0.5,
	shadowSoftness = 0.08,
	haze = {
		color = Color3.fromRGB(190, 202, 216),
		decay = Color3.fromRGB(116, 134, 160),
		density = 0.3,
		offset = 0.1,
		glare = 0.35,
		haze = 1.6
	},
	rays = { intensity = 0.06, spread = 0.35 },
	bloom = { intensity = 0.55, size = 30, threshold = 1.15 },
	grade = {
		brightness = -0.02,
		contrast = 0.22,
		saturation = -0.18,
		tint = Color3.fromRGB(246, 249, 255)
	},
	exposure = 0.1,
	clouds = { cover = 0.55, density = 0.6, color = Color3.fromRGB(236, 238, 242) }
}

Environment.Presets.desert = {
	sky = {
		bk = "rbxasset://textures/sky/sky512_bk.tex",
		ft = "rbxasset://textures/sky/sky512_ft.tex",
		lf = "rbxasset://textures/sky/sky512_lf.tex",
		rt = "rbxasset://textures/sky/sky512_rt.tex",
		up = "rbxasset://textures/sky/sky512_up.tex",
		dn = "rbxasset://textures/sky/sky512_dn.tex",
		sun = "rbxasset://sky/sun.jpg",
		sunSize = 9
	},
	clockTime = 13.4,
	latitude = 26,
	brightness = 3.4,
	sunColor = Color3.fromRGB(255, 240, 214),
	bounceColor = Color3.fromRGB(92, 76, 58),
	outdoorAmbient = Color3.fromRGB(122, 124, 132),
	ambient = Color3.fromRGB(70, 62, 56),
	diffuseScale = 0.6,
	specularScale = 0.35,
	shadowSoftness = 0.1,
	haze = {
		color = Color3.fromRGB(226, 210, 184),
		decay = Color3.fromRGB(176, 168, 158),
		density = 0.27,
		offset = 0.15,
		glare = 0.3,
		haze = 1.4
	},
	rays = { intensity = 0.04, spread = 0.4 },
	bloom = { intensity = 0.45, size = 28, threshold = 1.25 },
	grade = {
		brightness = 0,
		contrast = 0.16,
		saturation = -0.12,
		tint = Color3.fromRGB(255, 250, 242)
	},
	exposure = 0.05,
	clouds = { cover = 0.22, density = 0.3, color = Color3.fromRGB(246, 242, 236) }
}

Environment.Presets.winter = {
	sky = {
		bk = "rbxasset://textures/sky/sky512_bk.tex",
		ft = "rbxasset://textures/sky/sky512_ft.tex",
		lf = "rbxasset://textures/sky/sky512_lf.tex",
		rt = "rbxasset://textures/sky/sky512_rt.tex",
		up = "rbxasset://textures/sky/sky512_up.tex",
		dn = "rbxasset://textures/sky/sky512_dn.tex",
		sun = "rbxasset://sky/sun.jpg",
		sunSize = 8
	},
	clockTime = 15.2,
	latitude = 62,
	brightness = 2.2,
	sunColor = Color3.fromRGB(255, 235, 214),
	bounceColor = Color3.fromRGB(92, 108, 128),
	outdoorAmbient = Color3.fromRGB(126, 140, 162),
	ambient = Color3.fromRGB(86, 96, 110),
	diffuseScale = 0.5,
	specularScale = 0.7,
	shadowSoftness = 0.25,
	haze = {
		color = Color3.fromRGB(201, 211, 220),
		decay = Color3.fromRGB(147, 162, 180),
		density = 0.4,
		offset = 0.15,
		glare = 0.25,
		haze = 1.9
	},
	rays = { intensity = 0.04, spread = 0.6 },
	bloom = { intensity = 0.35, size = 24, threshold = 1.7 },
	grade = {
		brightness = 0,
		contrast = 0.06,
		saturation = -0.08,
		tint = Color3.fromRGB(241, 245, 255)
	},
	exposure = -0.2,
	clouds = { cover = 0.45, density = 0.5, color = Color3.fromRGB(232, 236, 242) }
}

Environment.Presets.works = table.clone(Environment.Presets.frontline)
Environment.Presets.works.ambient = Color3.fromRGB(118, 112, 104)

Environment.Presets.crag = table.clone(Environment.Presets.frontline)
Environment.Presets.crag.ambient = Color3.fromRGB(90, 92, 98)
Environment.Presets.crag.outdoorAmbient = Color3.fromRGB(108, 120, 144)

local v = {
	ironfield = "frontline",
	sandline = "desert",
	saltpan = "frontline",
	frostmill = "winter",
	pinewold = "frontline",
	deepworks = "works",
	drywell = "frontline",
	highcrag = "crag",
	longreach = "frontline"
}
local MapSelect = require(script.Parent:WaitForChild("MapSelect"))
Environment.NORMAL = v[MapSelect.name]
assert(Environment.NORMAL, "[Environment] no everyday look for this map")

function Environment.names()
	local result = { "normal" }

	for k in Environment.Presets do
		table.insert(result, k)
	end

	table.sort(result)
	return result
end

local function child(className: string, name: string)
	local v2 = Lighting:FindFirstChild(name)

	if v2 and not v2:IsA(className) then
		v2:Destroy()
		v2 = nil
	end

	if not v2 then
		v2 = Instance.new(className)
		v2.Name = name
		v2.Parent = Lighting
	end

	return v2
end

function Environment.apply(environment: string)
	if environment == "normal" then
		environment = Environment.NORMAL
	end

	local preset = Environment.Presets[environment]
	assert(preset, "unknown environment preset: " .. tostring(environment))

	Lighting.ClockTime = preset.clockTime
	Lighting.GeographicLatitude = preset.latitude
	Lighting.Brightness = preset.brightness
	Lighting.ColorShift_Top = preset.sunColor
	Lighting.ColorShift_Bottom = preset.bounceColor
	Lighting.OutdoorAmbient = preset.outdoorAmbient
	Lighting.Ambient = preset.ambient
	Lighting.EnvironmentDiffuseScale = preset.diffuseScale
	Lighting.EnvironmentSpecularScale = preset.specularScale
	Lighting.ShadowSoftness = preset.shadowSoftness
	Lighting.GlobalShadows = true
	Lighting.ExposureCompensation = preset.exposure

	local v2 = child("Sky", "Sky")
	local bk = preset.sky.bk
	local ft = preset.sky.ft
	local lf = preset.sky.lf
	v2.SkyboxBk = bk
	v2.SkyboxFt = ft
	v2.SkyboxLf = lf
	local rt = preset.sky.rt
	local up = preset.sky.up
	local dn = preset.sky.dn
	v2.SkyboxRt = rt
	v2.SkyboxUp = up
	v2.SkyboxDn = dn
	v2.SunTextureId = preset.sky.sun
	v2.SunAngularSize = preset.sky.sunSize
	v2.MoonAngularSize = 0
	v2.StarCount = 0
	v2.CelestialBodiesShown = true

	local v3 = child("Atmosphere", "Atmosphere")
	local color = preset.haze.color
	local decay = preset.haze.decay
	v3.Color = color
	v3.Decay = decay
	local density = preset.haze.density
	local offset = preset.haze.offset
	v3.Density = density
	v3.Offset = offset
	local glare = preset.haze.glare
	local haze = preset.haze.haze
	v3.Glare = glare
	v3.Haze = haze

	local v4 = child("SunRaysEffect", "SunRays")
	v4.Enabled = true
	local intensity = preset.rays.intensity
	local spread = preset.rays.spread
	v4.Intensity = intensity
	v4.Spread = spread

	local v5 = child("BloomEffect", "Bloom")
	v5.Enabled = true
	local intensity2 = preset.bloom.intensity
	local size = preset.bloom.size
	local threshold = preset.bloom.threshold
	v5.Intensity = intensity2
	v5.Size = size
	v5.Threshold = threshold

	local v6 = child("ColorCorrectionEffect", "Grade")
	v6.Enabled = true
	local brightness = preset.grade.brightness
	local contrast = preset.grade.contrast
	v6.Brightness = brightness
	v6.Contrast = contrast
	local saturation = preset.grade.saturation
	local tint = preset.grade.tint
	v6.Saturation = saturation
	v6.TintColor = tint

	local v7 = workspace.Terrain:FindFirstChildOfClass("Clouds")

	if preset.clouds then
		if not v7 then
			v7 = Instance.new("Clouds")
			v7.Parent = workspace.Terrain
		end

		v7.Enabled = true
		local cover = preset.clouds.cover
		local density2 = preset.clouds.density
		local color2 = preset.clouds.color
		v7.Cover = cover
		v7.Density = density2
		v7.Color = color2
	elseif v7 then
		v7.Enabled = false
	end

	Lighting:SetAttribute("Environment", environment)
end

MapSelect.onChange(function(p: string)
	Environment.NORMAL = v[p]
	assert(Environment.NORMAL, "[Environment] no everyday look for map " .. p)
	local RunService = game:GetService("RunService")

	if RunService:IsServer() then
		Environment.apply("normal")
	end
end, 5)

return Environment