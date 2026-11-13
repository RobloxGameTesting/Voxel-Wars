local GarageLooks = {}

local color = Color3.fromRGB(34, 34, 36)
local color2 = Color3.fromRGB(50, 50, 47)
local color3 = Color3.fromRGB(150, 156, 166)
local color4 = Color3.fromRGB(84, 96, 66)
local color5 = Color3.fromRGB(64, 74, 52)
local color6 = Color3.fromRGB(96, 104, 66)
local color7 = Color3.fromRGB(110, 106, 100)
local color8 = Color3.fromRGB(70, 74, 80)
local color9 = Color3.fromRGB(150, 36, 28)
local color10 = Color3.fromRGB(216, 184, 106)

local function b(p: number, p2: number, p3: number, p4: number, p5: number, p6: number, color11: Color3) -- 8 equivalent calls inferred from this helper
	return { p, p2, p3, p4, p5, p6, color11 }
end

local function both(items)
	local result = {}

	for _, item in items do
		table.insert(result, item)
		table.insert(result, {
			-item[1],
			item[2],
			item[3],
			item[4],
			item[5],
			item[6],
			item[7]
		})
	end

	return result
end

local function join(...)
	local result = {}

	for _, v in { ... } do
		for _, v2 in v do
			table.insert(result, v2)
		end
	end

	return result
end

local function round(p: number, p2: number, p3: number, p4: number, p5: number, color11: Color3, color12: Color3, flag: boolean?)
	local v = {
		b(p, p2, p3, p4, p4, p5, color11), -- inferred equivalent call
		b(p, p2, p3 - p5 / 2 - 0.25, p4 - 0.5, p4 - 0.5, 0.5, color12), -- inferred equivalent call
		b(p, p2, p3 + p5 / 2 - 0.5, 0.25, p4 + 1, 0.75, color) -- inferred equivalent call
	}

	if not flag then
		table.insert(v, b(p, p2, p3 + p5 / 2 - 0.5, p4 + 1, 0.25, 0.75, color)) -- inferred equivalent call
	end

	return v
end

local function plates(p: number, p2: number, p3: number, p4: number, p5: number, p6: number, color11: Color3)
	local v = math.max(1, ((math.floor)((p4 - p3 + 0.5) / 3.5 + 0.5)))
	local v2 = (p4 - p3 + 0.5) / v
	local result = {}

	for i = 0, v - 1 do
		table.insert(result, b(p, p2, p3 + i * v2 + (v2 - 0.5) / 2, p6, p5, v2 - 0.5, color11)) -- inferred equivalent call
	end

	return result
end

local function trolley(p: number, p2: number, p3: number, p4: number, p5: number, color11: Color3)
	local v = p4 + 1
	local v2 = (p3 - 1) * v + p4 + 1
	local v3 = p + (p3 - 1) * v / 2
	local result = {
		b(v3, 0.125, p2, v2, 0.25, p5 - 1, color), -- inferred equivalent call
		b(v3, 0.5, p2 - p5 / 4, v2, 0.5, 0.5, color2), -- inferred equivalent call
		b(v3, 0.5, p2 + p5 / 4 - 0.5, v2, 0.5, 0.5, color2) -- inferred equivalent call
	}

	for i = 0, p3 - 1 do
		for _, v4 in round(p + i * v, p4 / 2 + 0.75, p2, p4, p5, color5, color11, true) do
			table.insert(result, v4)
		end
	end

	return result
end

local v = {
	Tank = {
		shell = {
			ap = {
				{ 0, 6.3, -19.5, 1, 1, 4, color4 },
				{ 0, 6.3, -21.75, 1.5, 1.5, 0.5, color }
			},
			mp = {
				{ 0, 6.3, -18.25, 1.5, 1.5, 1.5, color2 },
				{ 0, 6.3, -18.25, 2.5, 0.5, 0.75, color4 },
				{ 0, 6.3, -8.625, 1.5, 1.5, 6.25, color5 }
			}
		},
		roof = {
			hmg = {
				{ 2.75, 8.375, 1.75, 0.5, 0.75, 0.5, color },
				{ 2.75, 9.25, 1.5, 1, 1, 2.5, color2 },
				{ 2.75, 9.25, -1.75, 0.5, 0.5, 4, color },
				{ 3.75, 9, 1.5, 1, 1, 1.5, color4 },
				{ 2.75, 9.5, -0.125, 2.5, 1.5, 0.25, color4 },
				{ 3.25, 9.875, 1.5, 1.5, 0.25, 0.5, color },
				{ 3.75, 9.625, 1.5, 0.5, 0.25, 0.5, color }
			}
		},
		upgrade = {
			plating = join(
				both(plates(6.25, 2.875, -10.5, 11, 2.25, 0.5, color5)),
				both(plates(5.75, 6.375, -4, 10, 1.25, 0.5, color5))
			),
			loader = {
				{ 0, 6, 12.5, 8, 2, 2, color4 },
				{ -2.5, 6, 13.625, 1.5, 1.5, 0.25, color2 },
				{ 0, 6, 13.625, 1.5, 1.5, 0.25, color2 },
				{ 2.5, 6, 13.625, 1.5, 1.5, 0.25, color2 }
			}
		}
	},
	Bradley = {
		shell = {
			ap = {
				{ 0, 7.75, -13.25, 0.5, 0.5, 3, color },
				{ 0, 7.75, -15.25, 1, 1, 1, color2 }
			},
			he = {
				{ 0, 7.75, -8.25, 1, 1, 4, color2 },
				{ 0, 7.75, -9.5, 1.5, 1.5, 0.5, color },
				{ 0, 7.75, -7, 1.5, 1.5, 0.5, color }
			}
		},
		launcher = {
			salvo = {
				{ -4.5, 9.75, -0.25, 2, 1.5, 6, color4 },
				{ -5, 9.75, -3.375, 0.5, 0.75, 0.25, color },
				{ -4, 9.75, -3.375, 0.5, 0.75, 0.25, color }
			}
		},
		upgrade = {
			plating = both(plates(5.75, 3.5, -8, 9.25, 3, 0.5, color5)),
			loader = {
				{ 0, 7.25, 5.75, 5, 1.5, 1.5, color4 },
				{ -1.25, 7.25, 6.625, 1, 1, 0.25, color2 },
				{ 1.25, 7.25, 6.625, 1, 1, 0.25, color2 }
			}
		}
	},
	Heli = 0,
	StealthHeli = 0,
	Jet = 0,
	Bomber = 0
}
local heli = {
	gun = {
		cannon = {
			{ 0, 1.5, -10, 0.5, 0.5, 4, color },
			{ 0, 1.5, -12.25, 1, 1, 0.5, color2 }
		}
	},
	rockets = {
		heavy = both({
			{ 5, 2.25, -2.25, 2.5, 2.5, 6.5, color6 },
			{ 5, 2.25, 1.125, 2, 2, 0.25, color2 },
			{ 4.5, 1.75, -5.625, 0.75, 0.75, 0.25, color },
			{ 5.5, 1.75, -5.625, 0.75, 0.75, 0.25, color },
			{ 4.5, 2.75, -5.625, 0.75, 0.75, 0.25, color },
			{ 5.5, 2.75, -5.625, 0.75, 0.75, 0.25, color },
			{ 4.5, 1.75, -5.875, 0.25, 0.25, 0.25, color9 },
			{ 5.5, 1.75, -5.875, 0.25, 0.25, 0.25, color9 },
			{ 4.5, 2.75, -5.875, 0.25, 0.25, 0.25, color9 },
			{ 5.5, 2.75, -5.875, 0.25, 0.25, 0.25, color9 }
		}),
		rapid = both({
			{ 6.75, 2.5, -2.25, 1.5, 1.5, 5.5, color6 },
			{ 6.75, 2.5, 0.625, 1.5, 1.5, 0.25, color2 },
			{ 6.75, 2.5, -5.125, 0.25, 0.25, 0.25, color },
			{ 6.25, 2.5, -5.125, 0.25, 0.25, 0.25, color },
			{ 7.25, 2.5, -5.125, 0.25, 0.25, 0.25, color },
			{ 6.5, 3, -5.125, 0.25, 0.25, 0.25, color },
			{ 7, 3, -5.125, 0.25, 0.25, 0.25, color },
			{ 6.5, 2, -5.125, 0.25, 0.25, 0.25, color },
			{ 7, 2, -5.125, 0.25, 0.25, 0.25, color }
		})
	},
	doorgun = {
		lmg = both({
			{ 2.25, 3.25, 1.5, 0.25, 1.5, 0.25, color },
			{ 2.5, 4.25, 1.5, 1, 0.5, 0.5, color2 },
			{ 4, 4.25, 1.5, 2, 0.25, 0.25, color },
			{ 2.5, 4.25, 2.125, 0.5, 0.5, 0.75, color4 }
		}),
		launcher = both({
			{ 2.25, 3.25, 1.5, 0.25, 1.5, 0.25, color },
			{ 2.5, 4.25, 1.5, 1, 1, 1, color2 },
			{ 3.625, 4.25, 1.5, 1.25, 0.75, 0.75, color },
			{ 2.5, 4.25, 2.375, 0.75, 0.75, 0.75, color5 }
		})
	},
	upgrade = 0
}
local v2 = both({
	{ 2.75, 4.75, -3.5, 0.5, 1.5, 3, color5 }
})
local v3 = {}
table.insert(v3, { 2.75, 3, -2.75, 0.5, 1, 4.5, color5 })
heli.upgrade = {
	plating = join(v2, both(v3)),
	flares = both({
		{ 1.25, 6, 12, 0.5, 1, 2, color2 },
		{ 1.625, 6.25, 11.5, 0.25, 0.25, 0.5, color10 },
		{ 1.625, 6.25, 12.5, 0.25, 0.25, 0.5, color10 },
		{ 1.625, 5.75, 11.5, 0.25, 0.25, 0.5, color10 },
		{ 1.625, 5.75, 12.5, 0.25, 0.25, 0.5, color10 }
	})
}
v.Heli = heli
v.StealthHeli = {
	gun = {
		cannon = both({
			{ 4.75, 2.75, -10.5, 0.5, 0.5, 4, color },
			{ 4.75, 2.75, -12.75, 1, 1, 0.5, color8 }
		})
	},
	rockets = {
		swarm = both({
			{ 8.75, 2.5, -1.5, 1.5, 1.5, 6, color2 },
			{ 8.375, 2.125, -4.625, 0.5, 0.5, 0.25, color9 },
			{ 9.125, 2.125, -4.625, 0.5, 0.5, 0.25, color9 },
			{ 8.375, 2.875, -4.625, 0.5, 0.5, 0.25, color9 },
			{ 9.125, 2.875, -4.625, 0.5, 0.5, 0.25, color9 }
		}),
		buster = both({
			{ 7, 2.25, -1.5, 2.5, 2.5, 7.5, color2 },
			{ 7, 2.25, 2.375, 2, 2, 0.25, color },
			{ 6.375, 2.25, -5.75, 1, 1, 1, color3 },
			{ 7.625, 2.25, -5.75, 1, 1, 1, color3 },
			{ 6.375, 2.25, -6.5, 0.5, 0.5, 0.5, color9 },
			{ 7.625, 2.25, -6.5, 0.5, 0.5, 0.5, color9 }
		})
	},
	upgrade = {
		plating = join(both({
			{ 1.5, 7.25, -3, 1, 0.5, 3, color8 }
		}), both({
			{ 3.25, 4, 3, 0.5, 1.5, 3, color8 }
		})),
		flares = both({
			{ 2.25, 4.75, 8.75, 0.5, 1, 1.5, color8 },
			{ 2.625, 5, 8.375, 0.25, 0.25, 0.5, color10 },
			{ 2.625, 5, 9.125, 0.25, 0.25, 0.5, color10 },
			{ 2.625, 4.5, 8.375, 0.25, 0.25, 0.5, color10 },
			{ 2.625, 4.5, 9.125, 0.25, 0.25, 0.5, color10 }
		})
	}
}
local jet = {
	gun = {
		burst = both({
			{ 1.25, 5.25, -14.5, 0.5, 0.5, 3, color7 },
			{ 1.25, 5.25, -16.75, 0.25, 0.25, 1.5, color }
		})
	},
	rockets = {
		quick = both(join(round(5.5, 3, 4, 1, 4.5, color5, color10), {
			{ 5.5, 3.75, 4, 0.5, 0.5, 1.5, color }
		}, round(8, 3, 5.5, 1, 4.5, color5, color10), {
			{ 8, 3.75, 5.5, 0.5, 0.5, 1.5, color }
		}, round(10.5, 3, 7, 1, 4.5, color5, color10), {
			{ 10.5, 3.75, 7, 0.5, 0.5, 1.5, color }
		})),
		bunker = both(join(round(6.5, 2.75, 5, 1.5, 7, color5, color9), {
			{ 6.5, 3.75, 5, 0.5, 0.5, 2, color }
		}))
	},
	upgrade = 0
}
local v4 = {}
table.insert(v4, { 3.75, 4, -5.75, 0.5, 1, 2.5, color7 })
table.insert(v4, { 3.75, 4, -2.75, 0.5, 1, 2.5, color7 })

jet.upgrade = { plating = both(v4) }
v.Jet = jet
v.Bomber = {
	rockets = {
		wide = both(trolley(17.5, -16, 6, 1.5, 6, color10)),
		quick = both(trolley(19, -15.5, 4, 1, 4.5, color9))
	},
	upgrade = {
		plating = {
			{ 0, 11.25, -7, 5, 0.5, 7.5, color8 }
		}
	}
}

function GarageLooks.boxes(p: string, p2: string, p3: string)
	local v5 = v[p]
	local v6 = v5 and v5[p2]
	return v6 and v6[p3]
end

function GarageLooks.reach(p: string, vector3: Vector3)
	local maxValue = 0
	local maxValue2 = 0

	for _, v5 in v[p] or {} do
		for _, v6 in v5 do
			for _, v7 in v6 do
				local v8 = math.abs(v7[1] - vector3.X) + v7[4] / 2
				local v9 = math.abs(v7[2] - vector3.Y) + v7[5] / 2
				local v10 = math.abs(v7[3] - vector3.Z) + v7[6] / 2
				maxValue = math.max(maxValue, (math.sqrt(v8 * v8 + v10 * v10)))
				maxValue2 = math.max(maxValue2, v9)
			end
		end
	end

	return maxValue, maxValue2
end

function GarageLooks.apply(parent, p: string, items)
	local v5 = {}

	for k, item in items do
		if GarageLooks.boxes(p, k, item) then
			table.insert(v5, k .. "=" .. item)
		end
	end

	table.sort(v5)
	local v6 = p .. ":" .. table.concat(v5, ",")
	local looks = parent:FindFirstChild("Looks")

	if looks and parent:GetAttribute("LooksKey") == v6 then
		return
	end

	parent:SetAttribute("LooksKey", v6)

	if looks then
		looks:Destroy()
	end

	local looks2 = Instance.new("Folder")
	looks2.Name = "Looks"

	for k, item in items do
		local boxes = GarageLooks.boxes(p, k, item)

		if not boxes then
			continue
		end

		for _, box in boxes do
			local part = Instance.new("Part")
			part.Name = k .. "_" .. item
			part.Anchored = true
			part.CanCollide = false
			part.CastShadow = false
			part.Size = Vector3.new(box[4], box[5], box[6])
			part.CFrame = CFrame.new(box[1], box[2], box[3])
			part.Color = box[7]
			part.Material = Enum.Material.SmoothPlastic
			local smooth = Enum.SurfaceType.Smooth
			local smooth2 = Enum.SurfaceType.Smooth
			part.TopSurface = smooth
			part.BottomSurface = smooth2
			part.Parent = looks2
		end
	end

	looks2.Parent = parent
end

return GarageLooks