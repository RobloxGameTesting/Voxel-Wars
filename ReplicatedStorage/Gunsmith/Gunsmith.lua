local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local ShopData = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("ShopData"))
local Mastery = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("Mastery"))
local WeaponSkins = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("WeaponSkins"))

local parent = script.Parent
local Gunsmith = {}

local isRunning = RunService:IsRunning()
local isServer = RunService:IsServer()

local gunsmithKits = isRunning and isServer and parent:FindFirstChild("Kits")

if gunsmithKits then
	gunsmithKits.Name = "GunsmithKits"
	gunsmithKits.Parent = ServerStorage
end

local newVector3 = Vector3.new

Gunsmith.BASE_FOV = 80

function Gunsmith.fovOf(p: number)
	return math.deg((math.atan(0.5205670505517462 / p))) * 2
end

function Gunsmith.zoomOf(p: number)
	return 0.5205670505517462 / math.tan(math.rad(p) / 2)
end

function Gunsmith.zoomText(p: number)
	local v = math.round(p * 20) / 20
	return string.format(math.abs(v * 10 - math.round(v * 10)) < 1e-6 and "%.1fx" or "%.2fx", v)
end

local v = {
	{
		id = "BLOCK",
		name = "BLOCK 4X",
		level = 3,
		y = 0.345,
		r = 0.09,
		zoom = 4,
		posts = 1.4,
		about = "A short fat tube on a tall hollow block. The widest view, for close lanes."
	},
	{
		id = "HOOD",
		name = "HOOD 5X",
		level = 5,
		y = 0.33,
		r = 0.09,
		zoom = 5,
		posts = 1.2,
		about = "A hooded tube high on a square block. Quick pick-ups at mid range."
	},
	{
		id = "TAPER",
		name = "TAPER 6X",
		level = 7,
		y = 0.31,
		r = 0.085,
		zoom = 6,
		posts = 1,
		about = "A fat prism with a red strip on top and amber glass."
	},
	{
		id = "TWIN",
		name = "TWIN 7X",
		level = 10,
		y = 0.31,
		r = 0.085,
		zoom = 7,
		posts = 0.8,
		about = "A side tube on a fat bell, turned on a geared base."
	},
	{
		id = "FACET",
		name = "FACET 8X",
		level = 12,
		y = 0.3,
		r = 0.08,
		zoom = 8,
		posts = 0.8,
		about = "An angular housing with a big slanted dial and blue glass."
	},
	{
		id = "FIELD",
		name = "FIELD 10X",
		level = 14,
		y = 0.29,
		r = 0.075,
		zoom = 10,
		posts = 0.6,
		about = "A wide tan scope with a screened front and its cover flipped up."
	},
	{
		id = "DIAL",
		name = "DIAL 12X",
		level = 17,
		y = 0.285,
		r = 0.07,
		zoom = 12,
		posts = 0.5,
		about = "A long scope with big knurled turrets. A thin reticle for far targets."
	},
	{
		id = "LANCE",
		name = "LANCE 14X",
		level = 20,
		y = 0.28,
		r = 0.068,
		zoom = 14,
		posts = 0.4,
		about = "The longest scope, with a sunshade. The most zoom, the least of the world."
	}
}

local function sniperOptics(p, p2: number, list)
	local options = {
		{
			id = "IRON",
			name = "IRON SIGHTS",
			level = 1,
			about = "No optic: plain iron sights on the rail. Nothing in the way, no zoom.",
			aim = {
				point = newVector3(0, list[1] + 0.1, list[2] + 0.015),
				distance = 0.5,
				zoom = 1
			}
		},
		p
	}

	for _, v2 in v do
		local distance = v2.r / (math.tan(math.rad((Gunsmith.fovOf(v2.zoom))) / 2) * 0.72) - 0.08
		local v3 = {
			id = v2.id,
			name = v2.name,
			level = v2.level,
			about = v2.about,
			aim = {
				point = newVector3(0, v2.y, p2 + 0.5),
				distance = distance,
				zoom = v2.zoom,
				posts = v2.posts,
				exact = true
			}
		}
		table.insert(options, v3)
	end

	return { id = "Optic", label = "OPTIC", default = p.id, options = options }
end

Gunsmith.GUNS = {
	Sniper = {
		aimTime = 0.3,
		aimMove = 0.55,
		slots = { sniperOptics({
				id = "STOCK",
				name = "ISSUE SCOPE",
				level = 1,
				about = "The rifle's own scope. Quick to find a target.",
				aim = {
					point = Vector3.new(0, 0.27, 0.5),
					distance = 1.08,
					zoom = Gunsmith.zoomOf(11),
					exact = true
				}
			}, 0, { 0.099, 0.25 }) }
	},
	RX10 = {
		aimTime = 0.34,
		aimMove = 0.4,
		slots = { sniperOptics({
				id = "STOCK",
				name = "ISSUE SCOPE",
				level = 1,
				about = "The rifle's own long scope.",
				aim = {
					point = Vector3.new(0, 0.27, 0.5),
					distance = 1.335,
					zoom = Gunsmith.zoomOf(9.5),
					exact = true
				}
			}, 0, { 0.1, 0.22 }) }
	},
	SC11 = {
		aimTime = 0.26,
		aimMove = 0.65,
		slots = { sniperOptics({
				id = "STOCK",
				name = "ISSUE SCOPE",
				level = 1,
				about = "The rifle's own scope, its covers flipped up.",
				aim = {
					point = Vector3.new(0, 0.27, 0.44),
					distance = 0.858,
					zoom = Gunsmith.zoomOf(14),
					posts = 0.5,
					exact = true
				}
			}, -0.06, { 0.11, 0.22 }) }
	},
	VX50 = {
		aimTime = 0.44,
		aimMove = 0.35,
		slots = { sniperOptics({
				id = "STOCK",
				name = "ISSUE SCOPE",
				level = 1,
				about = "The rifle's own heavy scope with a long sunshade. The most zoom of the issue scopes.",
				aim = {
					point = Vector3.new(0, 0.27, 0.5),
					distance = 1.493,
					zoom = Gunsmith.zoomOf(8.5),
					exact = true
				}
			}, 0, { 0.1, 0.22 }) }
	},
	AssaultRifle = {
		aimTime = 0.24,
		aimMove = 0.7,
		slots = {
			{
				id = "Optic",
				label = "OPTIC",
				default = "RING",
				options = {
					{
						id = "IRON",
						name = "IRON SIGHTS",
						level = 1,
						about = "No optic: plain iron sights on the rail. Nothing in the way, no zoom.",
						aim = { point = Vector3.new(0, 0.31, 0.115), distance = 0.5, zoom = 1 }
					},
					{
						id = "RING",
						name = "RING SIGHT",
						level = 1,
						about = "A round window on a tall mount. Strong zoom for mid range.",
						aim = { point = Vector3.new(0, 0.4, 0), distance = 0.94, zoom = 2.5 }
					},
					{
						id = "PIN",
						name = "PIN DOT",
						level = 4,
						about = "A small square window on two legs. No zoom: the whole room in view.",
						aim = { point = Vector3.new(0, 0.385, -0.036), distance = 0.53, zoom = 1 }
					},
					{
						id = "OCTO",
						name = "OCTO TUBE",
						level = 9,
						about = "A short eight-sided tube on a tall riser. A touch of zoom, a red ring to aim with.",
						aim = { point = Vector3.new(0, 0.4, 0.005), distance = 0.619, zoom = 1.5 }
					},
					{
						id = "DOT",
						name = "MICRO DOT",
						level = 2,
						about = "A small open hoop low on the rail. Barely zooms: the most of the world in view.",
						aim = {
							point = Vector3.new(0, 0.315, -0.0775),
							distance = 0.638,
							zoom = 1.5
						}
					},
					{
						id = "CUBE",
						name = "CUBE SIGHT",
						level = 7,
						about = "A small closed box on a long clamp. Light zoom through a tidy window.",
						aim = { point = Vector3.new(0, 0.335, 0), distance = 0.55, zoom = 1.75 }
					},
					{
						id = "HOLO",
						name = "BOX HOLO",
						level = 6,
						about = "A wide box window with a ring reticle. Light zoom, wide view.",
						aim = {
							point = Vector3.new(0, 0.345, -0.005),
							distance = 0.637,
							zoom = 1.75
						}
					},
					{
						id = "SHROUD",
						name = "SHROUD",
						level = 11,
						about = "A round tube inside a square shroud. Between a sight and a scope.",
						aim = { point = Vector3.new(0, 0.375, 0.01), distance = 0.632, zoom = 2 }
					},
					{
						id = "MINIPRISM",
						name = "MINI PRISM",
						level = 12,
						about = "A stubby prism with teal glass and a red chevron. Close to mid range.",
						aim = { point = Vector3.new(0, 0.385, 0.04), distance = 0.831, zoom = 2.5 }
					},
					{
						id = "CAGE",
						name = "CAGE SIGHT",
						level = 13,
						about = "A round sight in a guard cage, high on its mount. A big red circle frames targets.",
						aim = { point = Vector3.new(0, 0.43, 0.005), distance = 0.695, zoom = 2.5 }
					},
					{
						id = "SCOUT",
						name = "SCOUT SCOPE",
						level = 14,
						about = "A short tube scope on two rings. A red ladder for longer shots.",
						aim = { point = Vector3.new(0, 0.4, 0.11), distance = 0.903, zoom = 3 }
					},
					{
						id = "PRISM",
						name = "PRISM 3.5X",
						level = 15,
						about = "A squat 3.5x scope for long lanes. Tunnel view up close.",
						aim = { point = Vector3.new(0, 0.4, 0.1), distance = 0.993, zoom = 3.5 }
					},
					{
						id = "FLIP",
						name = "FLIP PRISM",
						level = 16,
						about = "A big-eyed prism with its cover flipped open. For long lanes.",
						aim = { point = Vector3.new(0, 0.41, 0.105), distance = 1.075, zoom = 4 }
					},
					{
						id = "BELL",
						name = "BELL 5X",
						level = 18,
						about = "A stout 5x with a huge front ring on a tall mount. Sees far, hides the sides.",
						aim = { point = Vector3.new(0, 0.44, 0.095), distance = 1.186, zoom = 5 }
					},
					{
						id = "LONG",
						name = "LONG SCOPE",
						level = 20,
						about = "A long tube scope with turrets. The most zoom: hold lanes from far back.",
						aim = { point = Vector3.new(0, 0.44, 0.24), distance = 1.321, zoom = 6 }
					}
				}
			},
			{
				id = "Muzzle",
				label = "MUZZLE",
				default = "COMP",
				options = {
					{
						id = "COMP",
						name = "COMPENSATOR",
						level = 1,
						about = "Balanced. The standard ported tip.",
						muzzle = -1.67,
						climb = 1,
						yaw = 1,
						flash = 1
					},
					{
						id = "FLASH",
						name = "FLASH HIDER",
						level = 5,
						about = "Hides most of the flash; kicks up a little more.",
						muzzle = -1.67,
						climb = 1.1,
						yaw = 1.05,
						flash = 0.4
					},
					{
						id = "BRAKE",
						name = "MUZZLE BRAKE",
						level = 8,
						about = "Kills the sideways kick. A bigger flash.",
						muzzle = -1.71,
						climb = 0.9,
						yaw = 0.6,
						flash = 1.4
					},
					{
						id = "SUPPRESSOR",
						name = "SUPPRESSOR",
						level = 12,
						about = "Quiet shots and almost no flash. Enemies hear you from much closer. Long and slower to aim.",
						muzzle = -1.95,
						climb = 1,
						yaw = 1,
						flash = 0.1,
						quiet = 0.35,
						aimTime = 1.1
					}
				}
			},
			{
				id = "Magazine",
				label = "MAGAZINE",
				default = "STD",
				options = {
					{
						id = "STD",
						name = "30 ROUND",
						level = 1,
						about = "The standard curved magazine.",
						rounds = 0,
						reload = 1
					},
					{
						id = "SHORT",
						name = "20 ROUND FAST MAG",
						level = 3,
						about = "Short and light: quicker to aim, reload and walk aimed.",
						rounds = -10,
						reload = 0.85,
						aimTime = 0.82,
						move = 1.15
					},
					{
						id = "LONG",
						name = "40 ROUND",
						level = 10,
						about = "Long and heavy: slower to reload and to walk aimed.",
						rounds = 10,
						reload = 1.15,
						move = 0.88
					}
				}
			}
		}
	}
}

local v2 = {
	RN545 = {
		aimTime = 0.2285,
		aimMove = 0.75,
		y = -0.07,
		z = -0.1,
		optic = {
			id = "STOCK",
			name = "ISSUE DOT",
			level = 1,
			about = "The rifle's own small open dot.",
			aim = {
				point = Vector3.new(0, 0.25, 0.1),
				distance = 1.15,
				zoom = Gunsmith.zoomOf(44),
				exact = true
			}
		},
		muzzle = {
			id = "STOCK",
			name = "ISSUE BRAKE",
			level = 1,
			about = "Balanced. The rifle's own ported brake.",
			muzzle = -1.71,
			climb = 1,
			yaw = 1,
			flash = 1
		}
	},
	MX65 = {
		aimTime = 0.26,
		aimMove = 0.68,
		y = -0.0675,
		z = -0.19,
		mag = { 20, 15, 30 },
		optic = {
			id = "STOCK",
			name = "ISSUE TUBE",
			level = 1,
			about = "The rifle's own short tube sight.",
			aim = {
				point = Vector3.new(0, 0.28, 0.08),
				distance = 0.93,
				zoom = Gunsmith.zoomOf(29.4),
				exact = true
			}
		},
		muzzle = {
			id = "STOCK",
			name = "ISSUE BRAKE",
			level = 1,
			about = "Balanced. The rifle's own round brake.",
			muzzle = -1.85,
			climb = 1,
			yaw = 1,
			flash = 1
		}
	},
	BT762 = {
		aimTime = 0.217,
		aimMove = 0.72,
		y = -0.01,
		z = 0.35,
		mag = { 20, 15, 30 },
		optic = {
			id = "STOCK",
			name = "ISSUE BOX",
			level = 1,
			about = "The rifle's own open box dot.",
			aim = {
				point = Vector3.new(0, 0.31, -0.14),
				distance = 1.15,
				zoom = Gunsmith.zoomOf(44),
				exact = true
			}
		},
		muzzle = {
			id = "STOCK",
			name = "ISSUE BRAKE",
			level = 1,
			about = "Balanced. The rifle's own wide brake.",
			muzzle = -1.31,
			climb = 1,
			yaw = 1,
			flash = 1
		}
	},
	K433 = {
		aimTime = 0.24,
		aimMove = 0.75,
		y = -0.06,
		z = -0.09,
		optic = {
			id = "STOCK",
			name = "ISSUE HOLO",
			level = 1,
			about = "The rifle's own box holo.",
			aim = {
				point = Vector3.new(0, 0.27, 0),
				distance = 1.105,
				zoom = Gunsmith.zoomOf(38.3),
				exact = true
			}
		},
		muzzle = {
			id = "STOCK",
			name = "ISSUE HIDER",
			level = 1,
			about = "Balanced. The rifle's own slotted tip.",
			muzzle = -1.635,
			climb = 1,
			yaw = 1,
			flash = 1
		}
	},
	GX36 = {
		aimTime = 0.2285,
		aimMove = 0.7,
		y = 0.1,
		z = -0.06,
		optic = {
			id = "STOCK",
			name = "ISSUE SIGHT",
			level = 1,
			about = "The rifle's own round sight on the carry arch.",
			aim = {
				point = Vector3.new(0, 0.42, 0.02),
				distance = 0.919,
				zoom = Gunsmith.zoomOf(33.1),
				exact = true
			}
		},
		muzzle = {
			id = "STOCK",
			name = "BIRDCAGE",
			level = 1,
			about = "Balanced. The rifle's own caged tip.",
			muzzle = -1.675,
			climb = 1,
			yaw = 1,
			flash = 1
		}
	},
	SK556 = {
		aimTime = 0.26,
		aimMove = 0.62,
		y = -0.05,
		z = -0.09,
		optic = {
			id = "STOCK",
			name = "ISSUE SCOPE",
			level = 1,
			about = "The rifle's own long-eyed scope.",
			aim = {
				point = Vector3.new(0, 0.3, 0.04),
				distance = 1.299,
				zoom = Gunsmith.zoomOf(19.7),
				exact = true
			}
		},
		muzzle = {
			id = "STOCK",
			name = "ISSUE HIDER",
			level = 1,
			about = "Balanced. The rifle's own slotted tip.",
			muzzle = -1.705,
			climb = 1,
			yaw = 1,
			flash = 1
		}
	},
	SMG = {
		aimTime = 0.171,
		aimMove = 0.85,
		y = -0.09,
		z = 0.66,
		mag = { 32, 24, 45 },
		optic = {
			id = "STOCK",
			name = "ISSUE SIGHT",
			level = 1,
			about = "The gun's own sight.",
			aim = {
				point = Vector3.new(0, 0.26, 0),
				distance = 0.961,
				zoom = Gunsmith.zoomOf(45.2),
				exact = true
			}
		},
		muzzle = {
			id = "STOCK",
			name = "ISSUE BRAKE",
			level = 1,
			about = "Balanced. The gun's own ported tip.",
			muzzle = -0.92,
			climb = 1,
			yaw = 1,
			flash = 1
		}
	},
	KP50 = {
		aimTime = 0.1825,
		aimMove = 0.87,
		y = -0.015,
		z = 0.7,
		belt = true,
		noIron = true,
		optic = {
			id = "STOCK",
			name = "ISSUE SIGHT",
			level = 1,
			about = "The gun's own sight, over the top magazine.",
			aim = {
				point = Vector3.new(0, 0.295, 0),
				distance = 0.961,
				zoom = Gunsmith.zoomOf(45.2),
				exact = true
			}
		},
		muzzle = {
			id = "STOCK",
			name = "ISSUE HIDER",
			level = 1,
			about = "Balanced. The gun's own tip.",
			muzzle = -0.91,
			climb = 1,
			yaw = 1,
			flash = 1
		}
	},
	HM45 = {
		aimTime = 0.171,
		aimMove = 0.82,
		y = -0.08,
		z = 0.7,
		mag = { 30, 20, 40 },
		optic = {
			id = "STOCK",
			name = "ISSUE SIGHT",
			level = 1,
			about = "The gun's own sight.",
			aim = {
				point = Vector3.new(0, 0.25, 0),
				distance = 0.961,
				zoom = Gunsmith.zoomOf(45.2),
				exact = true
			}
		},
		muzzle = {
			id = "STOCK",
			name = "ISSUE BRAKE",
			level = 1,
			about = "Balanced. The gun's own tip.",
			muzzle = -0.93,
			climb = 1,
			yaw = 1,
			flash = 1
		}
	},
	TK17 = {
		aimTime = 0.1595,
		aimMove = 0.88,
		y = -0.07,
		z = 0.76,
		mag = { 17, 12, 25 },
		optic = {
			id = "STOCK",
			name = "ISSUE SIGHT",
			level = 1,
			about = "The gun's own sight.",
			aim = {
				point = Vector3.new(0, 0.23, 0),
				distance = 0.961,
				zoom = Gunsmith.zoomOf(45.2),
				exact = true
			}
		},
		muzzle = {
			id = "STOCK",
			name = "ISSUE HIDER",
			level = 1,
			about = "Balanced. The gun's own tip.",
			muzzle = -0.85,
			climb = 1,
			yaw = 1,
			flash = 1
		}
	},
	PD46 = {
		aimTime = 0.1526,
		aimMove = 0.9,
		y = -0.06,
		z = 0.83,
		belt = true,
		optic = {
			id = "STOCK",
			name = "ISSUE SIGHT",
			level = 1,
			about = "The gun's own sight.",
			aim = {
				point = Vector3.new(0, 0.225, 0),
				distance = 0.961,
				zoom = Gunsmith.zoomOf(45.2),
				exact = true
			}
		},
		muzzle = {
			id = "STOCK",
			name = "ISSUE HIDER",
			level = 1,
			about = "Balanced. The gun's own tip.",
			muzzle = -0.76,
			climb = 1,
			yaw = 1,
			flash = 1
		}
	},
	SP44 = {
		aimTime = 0.1894,
		aimMove = 0.84,
		y = -0.075,
		z = 0.74,
		belt = true,
		optic = {
			id = "STOCK",
			name = "ISSUE SIGHT",
			level = 1,
			about = "The gun's own sight.",
			aim = {
				point = Vector3.new(0, 0.26, 0),
				distance = 0.961,
				zoom = Gunsmith.zoomOf(45.2),
				exact = true
			}
		},
		muzzle = {
			id = "STOCK",
			name = "ISSUE BRAKE",
			level = 1,
			about = "Balanced. The gun's own tip.",
			muzzle = -0.87,
			climb = 1,
			yaw = 1,
			flash = 1
		}
	},
	LMG = {
		aimTime = 0.38,
		aimMove = 0.5,
		y = 0.06,
		z = -0.3,
		belt = true,
		optic = {
			id = "STOCK",
			name = "ISSUE SIGHT",
			level = 1,
			about = "The gun's own sight.",
			aim = {
				point = Vector3.new(0, 0.42, 0),
				distance = 0.918,
				zoom = Gunsmith.zoomOf(45.2),
				exact = true
			}
		},
		muzzle = {
			id = "STOCK",
			name = "ISSUE HIDER",
			level = 1,
			about = "Balanced. The gun's own tip.",
			muzzle = -1.99,
			climb = 1,
			yaw = 1,
			flash = 1
		}
	},
	MG60 = {
		aimTime = 0.4,
		aimMove = 0.45,
		y = 0,
		z = -0.41,
		belt = true,
		optic = {
			id = "STOCK",
			name = "ISSUE REFLEX",
			level = 1,
			about = "The gun's own reflex sight.",
			aim = {
				point = Vector3.new(0, 0.29, 0),
				distance = 1.008,
				zoom = Gunsmith.zoomOf(45.2),
				exact = true
			}
		},
		muzzle = {
			id = "STOCK",
			name = "ISSUE HIDER",
			level = 1,
			about = "Balanced. The gun's own slotted tip.",
			muzzle = -2.04,
			climb = 1,
			yaw = 1,
			flash = 1
		}
	},
	BX110 = {
		aimTime = 0.372,
		aimMove = 0.55,
		y = 0,
		z = -0.27,
		belt = true,
		optic = {
			id = "STOCK",
			name = "ISSUE DOT",
			level = 1,
			about = "The gun's own dot sight.",
			aim = {
				point = Vector3.new(0, 0.33, 0),
				distance = 1.008,
				zoom = Gunsmith.zoomOf(45.2),
				exact = true
			}
		},
		muzzle = {
			id = "STOCK",
			name = "ISSUE HIDER",
			level = 1,
			about = "Balanced. The gun's own slotted tip.",
			muzzle = -1.9,
			climb = 1,
			yaw = 1,
			flash = 1
		}
	},
	HX83 = {
		aimTime = 0.372,
		aimMove = 0.55,
		y = 0.01,
		z = -0.22,
		belt = true,
		optic = {
			id = "STOCK",
			name = "ISSUE REFLEX",
			level = 1,
			about = "The gun's own reflex sight.",
			aim = {
				point = Vector3.new(0, 0.3, 0),
				distance = 1.008,
				zoom = Gunsmith.zoomOf(45.2),
				exact = true
			}
		},
		muzzle = {
			id = "STOCK",
			name = "ISSUE HIDER",
			level = 1,
			about = "Balanced. The gun's own slotted tip.",
			muzzle = -1.84,
			climb = 1,
			yaw = 1,
			flash = 1
		}
	},
	KT8 = {
		aimTime = 0.3,
		aimMove = 0.7,
		y = -0.02,
		z = -0.14,
		belt = true,
		optic = {
			id = "STOCK",
			name = "ISSUE RING",
			level = 1,
			about = "The gun's own ring sight on a stem.",
			aim = {
				point = Vector3.new(0, 0.3, 0),
				distance = 1.008,
				zoom = Gunsmith.zoomOf(45.2),
				exact = true
			}
		},
		muzzle = {
			id = "STOCK",
			name = "ISSUE HIDER",
			level = 1,
			about = "Balanced. The gun's own slotted tip.",
			muzzle = -1.76,
			climb = 1,
			yaw = 1,
			flash = 1
		}
	},
	NX68 = {
		aimTime = 0.352,
		aimMove = 0.58,
		y = 0,
		z = -0.22,
		belt = true,
		optic = {
			id = "STOCK",
			name = "ISSUE HOOD",
			level = 1,
			about = "The gun's own hood sight with leaning walls.",
			aim = {
				point = Vector3.new(0, 0.3, 0),
				distance = 1.008,
				zoom = Gunsmith.zoomOf(45.2),
				exact = true
			}
		},
		muzzle = {
			id = "STOCK",
			name = "ISSUE BRAKE",
			level = 1,
			about = "Balanced. The gun's own three-port block brake.",
			muzzle = -1.89,
			climb = 1,
			yaw = 1,
			flash = 1
		}
	},
	GR240 = {
		aimTime = 0.408,
		aimMove = 0.42,
		y = 0.02,
		z = -0.49,
		belt = true,
		optic = {
			id = "STOCK",
			name = "ISSUE REFLEX",
			level = 1,
			about = "The gun's own horseshoe reflex sight.",
			aim = {
				point = Vector3.new(0, 0.31, 0),
				distance = 1.008,
				zoom = Gunsmith.zoomOf(45.2),
				exact = true
			}
		},
		muzzle = {
			id = "STOCK",
			name = "ISSUE HIDER",
			level = 1,
			about = "Balanced. The gun's own long slotted tip.",
			muzzle = -2.16,
			climb = 1,
			yaw = 1,
			flash = 1
		}
	},
	DMR = {
		aimTime = 0.28,
		aimMove = 0.65,
		y = -0.085,
		z = -0.445,
		mag = { 20, 15, 30 },
		optic = {
			id = "STOCK",
			name = "ISSUE SCOPE",
			level = 1,
			about = "The rifle's own scope.",
			aim = {
				point = Vector3.new(0, 0.305, -0.08),
				distance = 0.923,
				zoom = Gunsmith.zoomOf(19.7),
				exact = true
			}
		},
		muzzle = {
			id = "STOCK",
			name = "ISSUE BRAKE",
			level = 1,
			about = "Balanced. The rifle's own ported tip.",
			muzzle = -2.13,
			climb = 1,
			yaw = 1,
			flash = 1
		}
	},
	FS16 = {
		aimTime = 0.26,
		aimMove = 0.75,
		y = -0.09,
		z = -0.09,
		mag = { 15, 10, 25 },
		optic = {
			id = "STOCK",
			name = "ISSUE SCOPE",
			level = 1,
			about = "The rifle's own scope.",
			aim = {
				point = Vector3.new(0, 0.305, -0.02),
				distance = 0.908,
				zoom = Gunsmith.zoomOf(29.2),
				exact = true
			}
		},
		muzzle = {
			id = "STOCK",
			name = "ISSUE HIDER",
			level = 1,
			about = "Balanced. The rifle's own slotted tip.",
			muzzle = -1.72,
			climb = 1,
			yaw = 1,
			flash = 1
		}
	},
	GV12 = {
		aimTime = 0.32,
		aimMove = 0.55,
		y = -0.08,
		z = -0.42,
		mag = { 10, 7, 15 },
		optic = {
			id = "STOCK",
			name = "ISSUE SCOPE",
			level = 1,
			about = "The rifle's own long scope.",
			aim = {
				point = Vector3.new(0, 0.305, 0.02),
				distance = 1.422,
				zoom = Gunsmith.zoomOf(14.8),
				exact = true
			}
		},
		muzzle = {
			id = "STOCK",
			name = "ISSUE BRAKE",
			level = 1,
			about = "Balanced. The rifle's own ported tip.",
			muzzle = -2.16,
			climb = 1,
			yaw = 1,
			flash = 1
		}
	},
	KR54 = {
		aimTime = 0.29,
		aimMove = 0.62,
		y = -0.05,
		z = -0.52,
		mag = { 10, 7, 15 },
		optic = {
			id = "STOCK",
			name = "ISSUE SCOPE",
			level = 1,
			about = "The rifle's own scope.",
			aim = {
				point = Vector3.new(0, 0.305, 0.03),
				distance = 1.54,
				zoom = Gunsmith.zoomOf(9.9),
				exact = true
			}
		},
		muzzle = {
			id = "STOCK",
			name = "ISSUE HIDER",
			level = 1,
			about = "Balanced. The rifle's own slotted tip.",
			muzzle = -2.21,
			climb = 1,
			yaw = 1,
			flash = 1
		}
	},
	QS9 = {
		aimTime = 0.25,
		aimMove = 0.72,
		y = -0.065,
		z = 0,
		mag = { 20, 15, 30 },
		fixedMuzzle = true,
		optic = {
			id = "STOCK",
			name = "ISSUE SCOPE",
			level = 1,
			about = "The rifle's own scope.",
			aim = {
				point = Vector3.new(0, 0.305, 0.03),
				distance = 0.528,
				zoom = Gunsmith.zoomOf(38.3),
				exact = true
			}
		},
		muzzle = {
			id = "STOCK",
			name = "SUPPRESSOR",
			level = 1,
			about = "Quiet shots and almost no flash. Built into the barrel.",
			muzzle = -1.5,
			climb = 1,
			yaw = 1,
			flash = 0.1,
			quiet = 0.35
		}
	}
}

local slots = Gunsmith.GUNS.AssaultRifle.slots

local function fittedMuzzles(muzzle, z: number)
	local clones = { muzzle }

	for _, option in slots[2].options do
		if option.id == "COMP" then
			continue
		end

		local clone = table.clone(option)
		clone.muzzle = option.muzzle + z
		table.insert(clones, clone)
	end

	return { id = "Muzzle", label = "MUZZLE", default = "STOCK", options = clones }
end

local function fittedMags(mag)
	local clones = {}

	for k, option in slots[3].options do
		local clone = table.clone(option)

		if clone.id == "STD" then
			clone.about = "The gun's own magazine."
		end

		if mag then
			clone.rounds = mag[k] - mag[1]
			clone.name = string.format(clone.id == "SHORT" and "%d ROUND FAST MAG" or "%d ROUND", mag[k])
		end

		table.insert(clones, clone)
	end

	return { id = "Magazine", label = "MAGAZINE", default = "STD", options = clones }
end

for k, v3 in v2 do
	local options = {}

	for _, option in slots[1].options do
		if not (option.id ~= "RING" and (option.id ~= "IRON" or not v3.noIron)) then
			continue
		end

		local clone = table.clone(option)
		local clone2 = table.clone(option.aim)
		clone2.point += newVector3(0, v3.y, 0)
		clone.aim = clone2
		table.insert(options, clone)
	end

	table.insert(options, v3.noIron and 1 or 2, v3.optic)
	local v4

	if v3.fixedMuzzle then
		v4 = {
			id = "Muzzle",
			label = "MUZZLE",
			default = "STOCK",
			options = { v3.muzzle }
		}
	else
		v4 = fittedMuzzles(v3.muzzle, v3.z)
	end

	local slots2 = {
		{ id = "Optic", label = "OPTIC", default = "STOCK", options = options },
		v4
	}

	if not v3.belt then
		table.insert(slots2, fittedMags(v3.mag))
	end

	Gunsmith.GUNS[k] = { aimTime = v3.aimTime, aimMove = v3.aimMove, slots = slots2 }
end

for k, v3 in {
	Sniper = {
		z = -1.02,
		mag = { 10, 6, 15 },
		muzzle = {
			id = "STOCK",
			name = "ISSUE BRAKE",
			level = 1,
			about = "Balanced. The rifle's own brake.",
			muzzle = -2.71,
			climb = 1,
			yaw = 1,
			flash = 1
		}
	},
	RX10 = {
		z = -1.27,
		mag = { 5, 3, 8 },
		muzzle = {
			id = "STOCK",
			name = "ISSUE BRAKE",
			level = 1,
			about = "Balanced. The rifle's own brake.",
			muzzle = -2.97,
			climb = 1,
			yaw = 1,
			flash = 1
		}
	},
	SC11 = {
		z = -0.62,
		mag = { 10, 6, 15 },
		muzzle = {
			id = "STOCK",
			name = "THREAD CAP",
			level = 1,
			about = "Balanced. The rifle's plain capped barrel.",
			muzzle = -2.2,
			climb = 1,
			yaw = 1,
			flash = 1
		}
	},
	VX50 = {
		z = -1.15,
		mag = { 5, 3, 8 },
		muzzle = {
			id = "STOCK",
			name = "SLAB BRAKE",
			level = 1,
			about = "Balanced. The rifle's own wide three-port brake.",
			muzzle = -2.94,
			climb = 1,
			yaw = 1,
			flash = 1
		}
	}
} do
	local slots2 = Gunsmith.GUNS[k].slots
	table.insert(slots2, fittedMuzzles(v3.muzzle, v3.z))
	table.insert(slots2, fittedMags(v3.mag))
end

Gunsmith.SPREAD_STEP = 0.11
local function grip(id: string, name: string, level: number, about: string, p: number, p2: number, p3: number, spread: number)
	local v3

	if p > 0 then
		v3 = 0.94 ^ p
	end

	local aimTime

	if p2 > 0 then
		aimTime = 0.83 ^ p2
	end

	local move

	if p3 > 0 then
		move = 0.89 ^ p3
	end

	if not (spread > 0) then
		spread = nil
	end

	return {
		id = id,
		name = name,
		level = level,
		about = about,
		climb = v3,
		yaw = v3,
		aimTime = aimTime,
		move = move,
		spread = spread
	}
end

local grips = {
	{
		id = "HANDSTOP",
		name = "HANDSTOP",
		level = 2,
		about = "A small stop for the front hand. Quicker to aim, no kick cut.",
		climb = nil,
		yaw = nil,
		aimTime = 0.83,
		move = nil,
		spread = nil
	},
	{
		id = "FOLD",
		name = "FOLDING GRIP",
		level = 4,
		about = "A vertical grip that folds flat. Less kick, more spread when moving aimed.",
		climb = 0.8835999999999999,
		yaw = 0.8835999999999999,
		aimTime = nil,
		move = nil,
		spread = 1
	},
	{
		id = "ANGLED",
		name = "ANGLED GRIP",
		level = 6,
		about = "A slim raked wedge. Quicker to aim, a little less kick, more spread when moving aimed.",
		climb = 0.94,
		yaw = 0.94,
		aimTime = 0.83,
		move = nil,
		spread = 1
	},
	{
		id = "STUBBY",
		name = "STUBBY GRIP",
		level = 8,
		about = "A short block grip. Less kick and quicker to aim, more spread when moving aimed.",
		climb = 0.8835999999999999,
		yaw = 0.8835999999999999,
		aimTime = 0.83,
		move = nil,
		spread = 1
	},
	{
		id = "ALLOY",
		name = "ALLOY GRIP",
		level = 10,
		about = "A round steel vertical grip. Less kick, no downside.",
		climb = 0.8835999999999999,
		yaw = 0.8835999999999999,
		aimTime = nil,
		move = nil,
		spread = nil
	},
	{
		id = "RIBBED",
		name = "RIBBED GRIP",
		level = 11,
		about = "A long ribbed vertical grip. Much less kick, more spread when moving aimed.",
		climb = 0.8305839999999999,
		yaw = 0.8305839999999999,
		aimTime = nil,
		move = nil,
		spread = 1
	},
	{
		id = "FULLANGLE",
		name = "LONG ANGLED",
		level = 13,
		about = "A long angled ramp. Quicker to aim and a little less kick, no downside.",
		climb = 0.94,
		yaw = 0.94,
		aimTime = 0.83,
		move = nil,
		spread = nil
	},
	{
		id = "CANTED",
		name = "RAKED STUBBY",
		level = 15,
		about = "A stubby grip leaning back. Much less kick and quicker to aim, more spread when moving aimed.",
		climb = 0.8305839999999999,
		yaw = 0.8305839999999999,
		aimTime = 0.83,
		move = nil,
		spread = 1
	},
	{
		id = "LOWPRO",
		name = "LOW GRIP",
		level = 17,
		about = "A flat grip with a front lip. Less kick and quicker to aim, no downside.",
		climb = 0.8835999999999999,
		yaw = 0.8835999999999999,
		aimTime = 0.83,
		move = nil,
		spread = nil
	},
	{
		id = "HEAVY",
		name = "HEAVY GRIP",
		level = 20,
		about = "A thick grip with a finger guard. The least kick. More spread when moving aimed, slower aimed walk.",
		climb = 0.7339040223999997,
		yaw = 0.7339040223999997,
		aimTime = nil,
		move = 0.89,
		spread = 1
	}
}

Gunsmith.GRIPS = grips

local v3 = {
	AssaultRifle = "STOP",
	SMG = "STOP",
	HM45 = "STOP",
	BT762 = "STOP",
	PD46 = "GRIP",
	LMG = "GRIP",
	MG60 = "GRIP",
	KT8 = "GRIP",
	DMR = "BIPOD",
	Sniper = "BIPOD",
	VX50 = "BIPOD",
	GR240 = "BIPOD",
	NX68 = "STOP"
}

Gunsmith.ISSUE_GRIP = v3
local v4 = { KP50 = true, TK17 = true }

for k, v5 in Gunsmith.GUNS do
	if v4[k] then
		continue
	end

	local v6 = v3[k]

	local options = { v6 and {
			id = "ISSUE",
			name = "ISSUE " .. v6,
			level = 1,
			about = "The gun's own " .. (v6 == "STOP" and "handstop" or string.lower(v6)) .. ". Balanced."
		} or { id = "ISSUE", name = "NO GRIP", level = 1, about = "A bare guard. Balanced." } }

	for _, v7 in grips do
		table.insert(options, v7)
	end

	table.insert(v5.slots, {
		id = "Underbarrel",
		label = "UNDERBARREL",
		default = "ISSUE",
		options = options
	})
end

local barrels2 = {
	AssaultRifle = { kind = "auto", short = 0.12 },
	RN545 = { kind = "auto", short = 0.18 },
	MX65 = { kind = "auto", short = 0.16 },
	BT762 = { kind = "auto", short = 0.11 },
	K433 = { kind = "auto", short = 0.14 },
	GX36 = { kind = "auto", short = 0.15 },
	SK556 = { kind = "auto", short = 0.2 },
	SMG = { kind = "auto", short = 0.05 },
	KP50 = { kind = "auto", short = 0.04 },
	HM45 = { kind = "auto", short = 0.04 },
	TK17 = { kind = "auto", short = 0.07 },
	PD46 = { kind = "auto", short = 0.045 },
	SP44 = { kind = "auto", short = 0.04 },
	LMG = { kind = "lmg", short = 0.17 },
	MG60 = { kind = "lmg", short = 0.07 },
	BX110 = { kind = "lmg", short = 0.17 },
	HX83 = { kind = "lmg", short = 0.17 },
	KT8 = { kind = "lmg", short = 0.17 },
	NX68 = { kind = "lmg", short = 0.17 },
	GR240 = { kind = "lmg", short = 0.2 },
	DMR = { kind = "flies", short = 0.2, long = 0.3 },
	FS16 = { kind = "flies", short = 0.16, long = 0.25 },
	GV12 = { kind = "flies", short = 0.22, long = 0.3 },
	KR54 = { kind = "flies", short = 0.25, long = 0.3 },
	Sniper = { kind = "flies", short = 0.35, long = 0.35 },
	RX10 = { kind = "flies", short = 0.35, long = 0.35 },
	SC11 = { kind = "flies", short = 0.3, long = 0.3 },
	VX50 = { kind = "flies", short = 0.35, long = 0.3 }
}

Gunsmith.BARRELS = barrels2
local function barrels(data)
	if data.kind == "lmg" then
		return {
			{
				id = "ISSUE",
				name = "ISSUE BARREL",
				level = 1,
				about = "The gun's own heavy barrel. Spread grows slowly in long aimed bursts."
			},
			{
				id = "SHORT",
				name = "SHORT BARREL",
				level = 7,
				about = "A short barrel. Tighter hip fire and quicker to aim. Spread grows faster in aimed bursts.",
				hip = 0.74,
				aimTime = 0.83,
				bloom = 1.5,
				length = -data.short
			},
			{
				id = "LIGHT",
				name = "LIGHT BARREL",
				level = 12,
				about = "A fluted barrel. Tighter aimed spread on the move and quicker to aim. Spread grows faster in aimed bursts.",
				spread = -0.9090909090909092,
				aimTime = 0.83,
				bloom = 1.5
			}
		}
	end

	if data.kind == "flies" then
		return {
			{
				id = "ISSUE",
				name = "ISSUE BARREL",
				level = 1,
				about = "The gun's own barrel. Balanced."
			},
			{
				id = "EXTENDED",
				name = "LONG BARREL",
				level = 3,
				about = "A long barrel. Faster rounds: they land sooner, less lead on moving targets. Slower to aim.",
				velocity = 1.25,
				aimTime = 100 / 83,
				length = data.long
			},
			{
				id = "SHORT",
				name = "SHORT BARREL",
				level = 7,
				about = "A short barrel. Tighter hip fire. Slower rounds.",
				hip = 0.74,
				velocity = 0.8,
				length = -data.short
			},
			{
				id = "LIGHT",
				name = "LIGHT BARREL",
				level = 12,
				about = "A fluted barrel. Tighter aimed spread on the move. No downside.",
				spread = -0.9090909090909092
			}
		}
	end

	return {
		{
			id = "ISSUE",
			name = "ISSUE BARREL",
			level = 1,
			about = "The gun's own barrel. Balanced."
		},
		{
			id = "HEAVY",
			name = "HEAVY BARREL",
			level = 5,
			about = "A thick barrel. Spread grows slower in aimed bursts. Slower to aim.",
			bloom = 2 / 3,
			aimTime = 100 / 83
		},
		{
			id = "SHORT",
			name = "SHORT BARREL",
			level = 7,
			about = "A short barrel. Tighter hip fire.",
			hip = 0.74,
			length = -data.short
		},
		{
			id = "LIGHT",
			name = "LIGHT BARREL",
			level = 12,
			about = "A fluted barrel. Tighter aimed spread on the move. No downside.",
			spread = -0.9090909090909092
		},
		{
			id = "COLD",
			name = "COLD FORGED",
			level = 14,
			about = "A hardened barrel with cooling rings. Spread grows slower in aimed bursts. No downside.",
			bloom = 2 / 3
		}
	}
end

for k, v5 in barrels2 do
	local v6 = Gunsmith.GUNS[k]
	assert(v6, "Gunsmith: a barrel fit for " .. k .. ", which has no slots")
	local v7 = #v6.slots + 1

	for k2, slot in v6.slots do
		if slot.id == "Muzzle" then
			v7 = k2 + 1
		end
	end

	table.insert(v6.slots, v7, {
		id = "Barrel",
		label = "BARREL",
		default = "ISSUE",
		options = barrels(v5)
	})
	v6.flies = v5.kind == "flies"
end

local function sightDistance(p: number, value: number?)
	return (value or 0.75) * p
end

local v5 = {
	{
		id = "SLIM",
		name = "SLIM DOT",
		level = 2,
		y = 0.244,
		zoom = 1,
		about = "A low mini sight with a blue lens. No zoom: the most of the world in view."
	},
	{
		id = "WIDE",
		name = "WIDE RING",
		level = 4,
		y = 0.262,
		zoom = 1.25,
		about = "A big round lens with a red ring. A touch of zoom."
	},
	{
		id = "HOODED",
		name = "HOODED DOT",
		level = 6,
		y = 0.243,
		zoom = 1.5,
		about = "A long hooded sight with a red chevron. Light zoom."
	},
	{
		id = "BOXED",
		name = "BOXED DOT",
		level = 8,
		y = 0.25,
		zoom = 1.75,
		about = "A closed box with a sloped front lens. The most zoom of the small sights."
	}
}

local magnified = {
	SHROUD = 10,
	MINIPRISM = 12,
	SCOUT = 14,
	PRISM = 15,
	FLIP = 17,
	BELL = 19
}

local pistols = {
	Pistol = {
		aimTime = 0.1667,
		aimMove = 0.8,
		dy = 0,
		optic = {
			id = "STOCK",
			name = "ISSUE REFLEX",
			level = 1,
			about = "The pistol's own round reflex sight. No zoom.",
			aim = { point = Vector3.new(0, 0.275, 0.371), distance = 0.75, zoom = 1, exact = true }
		}
	},
	SV20 = {
		aimTime = 0.1667,
		aimMove = 0.82,
		dy = 0.003,
		optic = {
			id = "STOCK",
			name = "ISSUE WINDOW",
			level = 1,
			about = "The SV-20's own open square window. No zoom.",
			aim = { point = Vector3.new(0, 0.276, 0.371), distance = 0.75, zoom = 1, exact = true }
		}
	},
	ZK10 = {
		aimTime = 0.1667,
		aimMove = 0.8,
		dy = 0.02,
		optic = {
			id = "STOCK",
			name = "IRON SIGHTS",
			level = 1,
			about = "The ZK-10's own notch and post. Light zoom.",
			aim = {
				point = Vector3.new(0, 0.24, 0.371),
				distance = 1.278,
				zoom = 1.5,
				exact = true
			}
		}
	},
	HandCannon = {
		aimTime = 0.2167,
		aimMove = 0.7,
		dy = 0,
		magnified = true,
		optic = {
			id = "STOCK",
			name = "ISSUE SHIELD",
			level = 1,
			about = "The hand cannon's own shielded reflex. A touch of zoom.",
			aim = {
				point = Vector3.new(0, 0.255, 0.371),
				distance = 0.9375,
				zoom = 1.25,
				exact = true
			}
		}
	}
}

Gunsmith.PISTOLS = pistols
Gunsmith.PISTOL_SIGHTS = v5
Gunsmith.MAGNIFIED = magnified
Gunsmith.MAGNIFIED_AT = Vector3.new(0, -0.028, 0.15)

for k, v6 in pistols do
	local options = { v6.optic }

	for _, v7 in v5 do
		table.insert(options, {
			id = v7.id,
			name = v7.name,
			level = v7.level,
			about = v7.about,
			aim = {
				point = newVector3(0, v7.y + v6.dy, 0.375),
				distance = 0.75 * v7.zoom,
				zoom = v7.zoom,
				exact = true
			}
		})
	end

	if v6.magnified then
		for _, option in slots[1].options do
			local level = magnified[option.id]

			if not level then
				continue
			end

			local clone = table.clone(option)
			local clone2 = table.clone(option.aim)
			clone2.point += Vector3.new(0, -0.028, 0.15) + newVector3(0, v6.dy, 0)
			clone.aim = clone2
			clone.level = level
			table.insert(options, clone)
		end
	end

	Gunsmith.GUNS[k] = {
		aimTime = v6.aimTime,
		aimMove = v6.aimMove,
		slots = {
			{ id = "Optic", label = "OPTIC", default = "STOCK", options = options }
		}
	}
end

for _, v6 in Gunsmith.GUNS do
	for _, slot in v6.slots do
		local idSet = {}

		for _, option in slot.options do
			assert(not idSet[option.id], "Gunsmith: two options " .. option.id)
			idSet[option.id] = true

			if option.aim then
				option.aim.fov = Gunsmith.fovOf(option.aim.zoom)

				if not option.aim.exact then
					option.aim.distance *= 1.6118953942396521
				end

				option.tag = Gunsmith.zoomText(option.aim.zoom)
			end

			if option.quiet then
				option.tag = "QUIET"
			end

			if not option.rounds then
				continue
			end

			local tag

			if option.rounds ~= 0 then
				tag = string.format("%+d RDS", option.rounds)
			end

			option.tag = tag
		end

		assert(idSet[slot.default], "Gunsmith: slot " .. slot.id .. " has no default option")
	end
end

function Gunsmith.bare(p: string, p2: string)
	local slot = Gunsmith.slot(p, p2)

	for _, option in slot.options do
		if option.id == "IRON" then
			return option.id
		end
	end

	return slot.default
end

function Gunsmith.enabled(): boolean
	return parent.Parent == ReplicatedStorage
end

local function copies() -- 2 equivalent calls inferred from this helper
	local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
	return playerGui and playerGui:FindFirstChild("GunsmithCopies")
end

local function kitOf(childName: string)
	local v6

	if isRunning then
		if isServer then
			v6 = ServerStorage:FindFirstChild("GunsmithKits")
		else
			v6 = copies() -- inferred equivalent call
		end
	else
		v6 = parent:FindFirstChild("Kits")
	end

	local folder = v6 and v6:FindFirstChild(childName)
	return if folder and folder:IsA("Folder") then folder else nil
end

local function whole(folder): boolean -- 4 equivalent calls inferred from this helper
	local size = folder:GetAttribute("Size")
	return type(size) == "number" and size <= #folder:GetDescendants()
end

function Gunsmith.has(p: string)
	return Gunsmith.enabled() and Gunsmith.GUNS[p] ~= nil
end

function Gunsmith.attr(p: string, p2: string)
	return "Gs_" .. p .. "_" .. p2
end

function Gunsmith.slot(p: string, p2: string)
	for _, slot in Gunsmith.GUNS[p].slots do
		if slot.id == p2 then
			return slot
		end
	end

	return nil
end

function Gunsmith.option(p: string, p2: string, p3: string)
	local v6 = Gunsmith.GUNS[p] and Gunsmith.slot(p, p2)

	if v6 then
		for _, option in v6.options do
			if option.id == p3 then
				return option
			end
		end
	end

	return nil
end

function Gunsmith.defaults(p: string)
	local defaultsById = {}

	for _, slot in Gunsmith.GUNS[p].slots do
		defaultsById[slot.id] = slot.default
	end

	return defaultsById
end

function Gunsmith.picks(instance, p: string)
	local idsById = Gunsmith.defaults(p)

	for _, slot in Gunsmith.GUNS[p].slots do
		local attribute = instance:GetAttribute(Gunsmith.attr(p, slot.id))
		local v6

		if type(attribute) == "string" then
			v6 = Gunsmith.option(p, slot.id, attribute)
		end

		if v6 and Gunsmith.unlocked(instance, p, v6) then
			idsById[slot.id] = v6.id
		end
	end

	return idsById
end

function Gunsmith.unlocked(instance, p: string, p2): boolean
	return Mastery.level(instance, p) >= p2.level or instance:GetAttribute("UnlockAll") == true
end

function Gunsmith.opened(p: string, p2: number, p3: number)
	local options = {}

	for _, slot in Gunsmith.GUNS[p].slots do
		for _, option in slot.options do
			if p2 < option.level and option.level <= p3 then
				table.insert(options, option)
			end
		end
	end

	table.sort(options, function(a, b): boolean
		if a.level == b.level then
			return a.name < b.name
		end

		return a.level < b.level
	end)

	return options
end

function Gunsmith.result(p: string, p2)
	local v6 = Gunsmith.GUNS[p]
	local result = {
		aimPoint = Vector3.new(0, 0, 0),
		aimDistance = 1,
		aimFov = 80,
		posts = nil,
		aimTime = v6.aimTime,
		aimMove = v6.aimMove,
		moveSpread = 0,
		climb = 1,
		yaw = 1,
		flash = 1,
		muzzle = 0,
		rounds = 0,
		reload = 1,
		velocity = 1,
		hip = 1,
		bloom = 1,
		length = 0
	}

	for _, slot in v6.slots do
		local v7 = Gunsmith.option(p, slot.id, p2[slot.id] or slot.default) or Gunsmith.option(p, slot.id, slot.default)

		if v7.aim then
			local point = v7.aim.point
			local distance = v7.aim.distance
			local fov = v7.aim.fov
			result.aimPoint = point
			result.aimDistance = distance
			result.aimFov = fov
			result.posts = v7.aim.posts
		end

		result.aimTime *= v7.aimTime or 1
		result.aimMove = math.min(1, result.aimMove * (v7.move or 1))
		result.climb *= v7.climb or 1
		result.yaw *= v7.yaw or 1
		result.flash *= v7.flash or 1
		result.muzzle = v7.muzzle or result.muzzle
		result.quiet = v7.quiet or result.quiet
		result.rounds += v7.rounds or 0
		result.reload *= v7.reload or 1
		result.moveSpread += v7.spread or 0
		result.velocity *= v7.velocity or 1
		result.hip *= v7.hip or 1
		result.bloom *= v7.bloom or 1
		result.length += v7.length or 0
	end

	if result.muzzle ~= 0 then
		result.muzzle -= result.length
	end

	return result
end

function Gunsmith.assemble(parent2, p: string, p2)
	local v6 = kitOf(p)
	assert(v6, "Gunsmith: no kit for " .. p)
	local handle = parent2:FindFirstChild("Handle")
	assert(handle and handle:IsA("BasePart"), "Gunsmith: " .. parent2:GetFullName() .. " has no Handle")

	for _, part in parent2:GetChildren() do
		if part:IsA("BasePart") and part ~= handle then
			part:Destroy()
		end
	end

	local result = Gunsmith.result(p, p2)
	local cframe = CFrame.new(0, 0, -result.length)
	local function add(instance, gsSlot: string?)
		for _, part in instance:GetChildren() do
			if not (part:IsA("BasePart") and part.Name ~= "Handle") then
				continue
			end

			local clone = part:Clone()
			local c0

			if gsSlot == "Muzzle" then
				c0 = cframe * part.CFrame
			else
				c0 = part.CFrame
			end

			clone.Anchored = handle.Anchored
			clone.CollisionGroup = handle.CollisionGroup
			clone.CFrame = handle.CFrame * c0

			if gsSlot then
				clone:SetAttribute("GsSlot", gsSlot)
			end

			if not handle.Anchored then
				local weld = Instance.new("Weld")
				weld.Part0 = handle
				weld.Part1 = clone
				weld.C0 = c0
				weld.Parent = clone
			end

			clone.Parent = parent2
		end
	end
	local base = v6:WaitForChild("Base")
	add(base, nil)

	if base:FindFirstChild("BodyMesh") then
		handle.Transparency = 1
	end

	for _, slot in Gunsmith.GUNS[p].slots do
		local v7 = p2[slot.id] or slot.default
		add(v6:WaitForChild(slot.id):WaitForChild(v7), slot.id)
		parent2:SetAttribute("Gs" .. slot.id, v7)
	end

	parent2:SetAttribute("GsAimPoint", result.aimPoint)
	parent2:SetAttribute("GsAimDistance", result.aimDistance)
	parent2:SetAttribute("GsAimFov", result.aimFov)
	parent2:SetAttribute("GsPosts", result.posts)
	parent2:SetAttribute("GsAimTime", result.aimTime)
	parent2:SetAttribute("GsAimMove", result.aimMove)
	parent2:SetAttribute("GsMoveSpread", result.moveSpread * 0.11)
	parent2:SetAttribute("GsClimb", result.climb)
	parent2:SetAttribute("GsYaw", result.yaw)
	parent2:SetAttribute("GsFlash", result.flash)
	parent2:SetAttribute("GsQuiet", result.quiet)
	parent2:SetAttribute("GsRounds", result.rounds)
	parent2:SetAttribute("GsReload", result.reload)
	parent2:SetAttribute("GsVelocity", result.velocity)
	parent2:SetAttribute("GsHip", result.hip)
	parent2:SetAttribute("GsBloom", result.bloom)
	local muzzleAttachment = handle:FindFirstChild("MuzzleAttachment")

	if muzzleAttachment and muzzleAttachment:IsA("Attachment") and result.muzzle ~= 0 then
		muzzleAttachment.Position = Vector3.new(muzzleAttachment.Position.X, muzzleAttachment.Position.Y, result.muzzle)
	end
end

function Gunsmith.mount(p: string, childName: string)
	local v6 = kitOf(p)
	local child = v6 and v6:FindFirstChild(childName)

	if not child then
		return nil
	end

	local v7 = Vector3.new(1, 1, 1) * 1e999
	local v8 = Vector3.new(-1, -1, -1) * 1e999

	for _, child2 in child:GetChildren() do
		for _, part in child2:GetChildren() do
			if not (part:IsA("BasePart") and part.Name ~= "Handle") then
				continue
			end

			local cframe = part.CFrame
			local halfSize = part.Size / 2

			for _, v9 in { -1, 1 } do
				for _, v10 in { -1, 1 } do
					for _, v11 in { -1, 1 } do
						local pointToWorldSpace = cframe:PointToWorldSpace(halfSize * Vector3.new(v9, v10, v11))
						v7 = v7:Min(pointToWorldSpace)
						v8 = v8:Max(pointToWorldSpace)
					end
				end
			end
		end
	end

	if v7.X > v8.X then
		return nil
	end

	return (Vector3.new((v7.X + v8.X) / 2, v8.Y + 0.025, (v7.Z + v8.Z) / 2))
end

function Gunsmith.preview(name: string, p)
	local child = ReplicatedStorage:WaitForChild("ToolTemplates"):FindFirstChild(name)
	assert(child, "Gunsmith: ToolTemplates." .. name .. " is missing")
	local tool = Instance.new("Tool")
	tool.Name = name
	local clone = child:FindFirstChild("Handle"):Clone()

	for _, attachment in clone:GetChildren() do
		if not attachment:IsA("Attachment") then
			attachment:Destroy()
		end
	end

	clone.Anchored = true
	clone.CFrame = CFrame.identity
	clone.Parent = tool
	Gunsmith.assemble(tool, name, p)
	return tool
end

function Gunsmith.loadKit(p: string): boolean
	if not isRunning then
		return true
	end

	local v6 = kitOf(p)

	if v6 and whole(v6) then -- inferred equivalent call
		return true
	end

	local v7 = parent:WaitForChild("Remote"):InvokeServer("kit", p)
	local lastTime = os.clock()

	while v7 and os.clock() - lastTime < 20 do
		local v8 = kitOf(p)

		if v8 and whole(v8) then -- inferred equivalent call
			return true
		end

		task.wait()
	end

	return false
end

local function sign(items)
	local v6 = {}

	for k, item in items do
		table.insert(v6, k .. "=" .. item)
	end

	table.sort(v6)
	return table.concat(v6, ",")
end

local function dressedCopy(p: string, picks)
	local v6 = copies() -- inferred equivalent call
	local tool = v6 and v6:FindFirstChild("Dressed_" .. p)

	if tool and tool:IsA("Tool") and whole(tool) and tool:GetAttribute("Sign") == sign(picks) then -- inferred equivalent call
		return tool
	end

	return nil
end

function Gunsmith.dressed(p, name: string)
	local picks = Gunsmith.picks(p, name)
	local v6 = kitOf(name)
	local v7, clone

	if v6 then
		if isRunning and not whole(v6) then -- inferred equivalent call
			v7 = dressedCopy(name, picks)

			if not v7 then
				return nil
			end

			clone = v7:Clone()
			clone.Name = name
			return clone
		end

		return Gunsmith.preview(name, picks)
	end

	v7 = dressedCopy(name, picks)

	if not v7 then
		return nil
	end

	clone = v7:Clone()
	clone.Name = name
	return clone
end

local v6 = {}

function Gunsmith.askDressed(p, p2: string, callback)
	local picks = Gunsmith.picks(p, p2)
	local v7 = p2 .. "|" .. sign(picks)

	if v6[v7] then
		return
	end

	v6[v7] = true
	task.spawn(function()
		local v8 = parent:WaitForChild("Remote"):InvokeServer("dressed", p2)
		local lastTime = os.clock()

		while v8 and not dressedCopy(p2, picks) and os.clock() - lastTime < 20 do
			task.wait()
		end

		v6[v7] = nil

		if dressedCopy(p2, picks) then
			callback()
		end
	end)
end

function Gunsmith.applySpec(instance, state)
	local v7 = {
		aimPoint = state.aimPoint,
		aimDistance = state.aimDistance,
		aimFov = state.aimFov,
		aimTime = state.aimTime,
		aimMove = state.aimMove,
		flashScale = state.flashScale
	}
	local flashScale = state.flashScale or 1
	local handle = instance:FindFirstChild("Handle")
	local muzzleAttachment = handle and handle:FindFirstChild("MuzzleAttachment")
	local function apply()
		local gsAimPoint = instance:GetAttribute("GsAimPoint")
		local gsAimDistance = instance:GetAttribute("GsAimDistance")
		local gsAimFov = instance:GetAttribute("GsAimFov")

		if typeof(gsAimPoint) == "Vector3" and type(gsAimDistance) == "number" and type(gsAimFov) == "number" then
			state.aimPoint = gsAimPoint
			state.aimDistance = gsAimDistance
			state.aimFov = gsAimFov
		else
			local aimPoint = v7.aimPoint
			local aimDistance = v7.aimDistance
			local aimFov = v7.aimFov
			state.aimPoint = aimPoint
			state.aimDistance = aimDistance
			state.aimFov = aimFov
		end

		local aimTime = instance:GetAttribute("GsAimTime")

		if type(aimTime) ~= "number" then
			aimTime = v7.aimTime
		end

		state.aimTime = aimTime
		local aimMove = instance:GetAttribute("GsAimMove")

		if type(aimMove) ~= "number" then
			aimMove = v7.aimMove
		end

		state.aimMove = aimMove
		local gsFlash = instance:GetAttribute("GsFlash")
		local flashScale2

		if type(gsFlash) == "number" then
			flashScale2 = flashScale * gsFlash
		else
			flashScale2 = v7.flashScale
		end

		state.flashScale = flashScale2

		if muzzleAttachment and muzzleAttachment:IsA("Attachment") then
			state.muzzle = muzzleAttachment.Position
		end
	end
	apply()
	instance.AttributeChanged:Connect(function(value: string)
		if string.sub(value, 1, 2) == "Gs" then
			apply()
		end
	end)
end

function Gunsmith.kick(instance)
	local gsClimb = instance:GetAttribute("GsClimb")
	local gsYaw = instance:GetAttribute("GsYaw")
	local selected = type(gsClimb) ~= "number" and 1 or gsClimb

	if type(gsYaw) == "number" then
		return selected, gsYaw
	end

	return selected, 1
end

function Gunsmith.moveSpread(instance)
	local gsMoveSpread = instance:GetAttribute("GsMoveSpread")
	return if type(gsMoveSpread) == "number" then gsMoveSpread else 0
end

local function attr1(instance, attributeName: string) -- 3 equivalent calls inferred from this helper
	local attribute = instance:GetAttribute(attributeName)
	return if type(attribute) == "number" then attribute else 1
end

function Gunsmith.velocity(instance)
	return attr1(instance, "GsVelocity") -- inferred equivalent call
end

function Gunsmith.hip(instance)
	return attr1(instance, "GsHip") -- inferred equivalent call
end

function Gunsmith.bloomAt(instance, value: number)
	return (attr1(instance, "GsBloom") - 1) * math.clamp(value, 0, 1) + 1 -- inferred equivalent call
end

function Gunsmith.fit(p, p2)
	if Gunsmith.has(p2.Name) then
		Gunsmith.assemble(p2, p2.Name, Gunsmith.picks(p, p2.Name))
	end
end

function Gunsmith.restat(instance)
	local gsRounds = instance:GetAttribute("GsRounds")
	local gsReload = instance:GetAttribute("GsReload")
	local magSize = instance:GetAttribute("MagSize")
	local reloadScale = instance:GetAttribute("ReloadScale")

	if type(gsRounds) == "number" and type(magSize) == "number" then
		instance:SetAttribute("MagSize", (math.max(1, magSize + gsRounds)))
	end

	if type(gsReload) == "number" and type(reloadScale) == "number" then
		instance:SetAttribute("ReloadScale", reloadScale * gsReload)
	end
end

function Gunsmith.serve(p)
	assert(RunService:IsServer(), "Gunsmith.serve is server only")
	local remote = parent:FindFirstChild("Remote")
	assert(
		remote and remote:IsA("RemoteFunction"),
		"Gunsmith: ReplicatedStorage.Gunsmith.Remote (RemoteFunction) is missing"
	)
	local v7 = {}
	local v8 = {}
	local v9 = {}

	local function storeOf(instance)
		local playerGui = instance:FindFirstChildOfClass("PlayerGui")

		if not playerGui then
			return nil
		end

		local gunsmithCopies = playerGui:FindFirstChild("GunsmithCopies")

		if not gunsmithCopies then
			gunsmithCopies = Instance.new("Folder")
			gunsmithCopies.Name = "GunsmithCopies"
			gunsmithCopies.Parent = playerGui
		end

		return gunsmithCopies
	end

	local function sendKit(instance, gunsmithCopies, childName: string)
		if gunsmithCopies:FindFirstChild(childName) then
			return
		end

		local clone = kitOf(childName):Clone()
		clone:SetAttribute("Size", #clone:GetDescendants())
		clone.Parent = gunsmithCopies
		local clones = v9[instance] or {}
		v9[instance] = clones
		table.insert(clones, clone)

		if #clones > 3 then
			table.remove(clones, 1):Destroy()
		end
	end

	local function sendDressed(instance, gunsmithCopies, value: string)
		local picks = Gunsmith.picks(instance, value)
		local name = "Dressed_" .. value
		local child = gunsmithCopies:FindFirstChild(name)

		if child and child:GetAttribute("Sign") == sign(picks) then
			return
		end

		if child then
			child:Destroy()
		end

		local folder = Gunsmith.preview(value, picks)
		folder.Name = name
		folder:SetAttribute("Sign", sign(picks))
		folder:SetAttribute("Size", #folder:GetDescendants())
		folder.Parent = gunsmithCopies
	end

	remote.OnServerInvoke = function(instance, p2, value, value2, value3)
		local now = os.clock()

		if p2 == "kit" or p2 == "dressed" then
			if now - (v8[instance] or 0) < 0.05 or type(value) ~= "string" or not Gunsmith.has(value) then
				return false, "Unknown request."
			end

			v8[instance] = now
			local playerGui = instance:FindFirstChildOfClass("PlayerGui")
			local gunsmithCopies

			if playerGui then
				gunsmithCopies = playerGui:FindFirstChild("GunsmithCopies")

				if not gunsmithCopies then
					gunsmithCopies = Instance.new("Folder")
					gunsmithCopies.Name = "GunsmithCopies"
					gunsmithCopies.Parent = playerGui
				end
			end

			if not gunsmithCopies then
				return false, "Not ready."
			end

			if p2 == "kit" then
				sendKit(instance, gunsmithCopies, value)
			else
				sendDressed(instance, gunsmithCopies, value)
			end

			return true, ""
		end

		if now - (v7[instance] or 0) < 0.15 then
			return false, "One at a time."
		end

		v7[instance] = now

		if p2 ~= "pick" or type(value) ~= "string" or type(value2) ~= "string" or type(value3) ~= "string" then
			return false, "Unknown request."
		end

		if value2 == WeaponSkins.SLOT then
			local v10 = WeaponSkins.find(value3)

			if not (WeaponSkins.has(value) and v10) then
				return false, "No such skin."
			end

			if not ShopData.owns(instance, value) then
				return false, "Buy the gun first."
			end

			if WeaponSkins.unlocked(instance, value, v10) then
				if WeaponSkins.pick(instance, value) == value3 then
					return false, "Already equipped."
				end

				p.setPick(instance, value, value2, value3)
				return true, v10.name .. " equipped."
			end

			if v10.class then
				return false, "Earn GOLD on every gun of this class first."
			end

			if v10.challenge then
				return false, "Earn every other camo and beat the challenge first."
			end

			if v10.bundle then
				return false, "Comes with an outfit bundle."
			end

			if v10.streak then
				return false, "Claim day 7 of the daily supply first."
			end

			return false, string.format("Unlocks at weapon level %d.", v10.level)
		else
			if not Gunsmith.has(value) then
				return false, "This gun can't be customised."
			end

			local option = Gunsmith.option(value, value2, value3)

			if not option then
				return false, "No such attachment."
			end

			if not ShopData.owns(instance, value) then
				return false, "Buy the gun first."
			end

			if not Gunsmith.unlocked(instance, value, option) then
				return false, string.format("Unlocks at weapon level %d.", option.level)
			end

			if Gunsmith.picks(instance, value)[value2] == value3 then
				return false, "Already equipped."
			end

			p.setPick(instance, value, value2, value3)
			return true, option.name .. " equipped."
		end
	end

	local function watch(p2) -- 1 equivalent call inferred from this helper
		local v10 = {}
		p2.AttributeChanged:Connect(function(value: string)
			local v11 = string.match(value, "^Gs_(.-)_[^_]+$")
			local v12

			if v11 == nil or value ~= WeaponSkins.attr(v11) then
				v12 = false
			else
				v12 = WeaponSkins.has(v11)
			end

			if v11 and (Gunsmith.has(v11) or v12) and not v10[v11] then
				v10[v11] = true
				task.defer(function()
					v10[v11] = nil

					if p2.Parent then
						p.refit(p2, v11)
					end
				end)
			end
		end)
	end
	Players.PlayerAdded:Connect(watch)

	for _, v10 in Players:GetPlayers() do
		watch(v10) -- inferred equivalent call
	end

	Players.PlayerRemoving:Connect(function(player)
		v7[player] = nil
		v8[player] = nil
		v9[player] = nil
	end)
end

return Gunsmith