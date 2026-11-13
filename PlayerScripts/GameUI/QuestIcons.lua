local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToolTemplates = ReplicatedStorage:WaitForChild("ToolTemplates")

local Style = require(script.Parent:WaitForChild("Style"))
local ToolIcon = require(script.Parent:WaitForChild("ToolIcon"))
local StreakIcon = require(script.Parent:WaitForChild("StreakIcon"))
local NewMenus = require(script.Parent:WaitForChild("NewMenus"))

local QuestIcons = {}

QuestIcons.RENDERED = NewMenus.on("Quests")
local v = {
	kills = "rbxassetid://104697584449776",
	headshot = "rbxassetid://136163157218658",
	assist = "rbxassetid://89249115547579",
	score = "rbxassetid://77416124735701",
	damage = "rbxassetid://116389751377389",
	capture = "rbxassetid://80671891588913",
	neutralize = "rbxassetid://103028359111383",
	round = "rbxassetid://76826585605972",
	win = "rbxassetid://88829777101055",
	wreck = "rbxassetid://109548197251544",
	vehicle = "rbxassetid://96808718265974",
	turret = "rbxassetid://127104385063300",
	close = "rbxassetid://129940694067274",
	long = "rbxassetid://123960727367015",
	aimed = "rbxassetid://102078115884115",
	hip = "rbxassetid://102433943749881",
	streak = "rbxassetid://74900354560974",
	explosive = "rbxassetid://79483084031332",
	fire = "rbxassetid://109239962901239",
	melee = "rbxassetid://88052726913643"
}

QuestIcons.COLOR = {
	bonus = Style.HAZARD,
	combat = Color3.fromRGB(255, 86, 56),
	weapons = Color3.fromRGB(36, 204, 190),
	points = Color3.fromRGB(52, 150, 255),
	vehicles = Color3.fromRGB(124, 214, 56),
	feats = Color3.fromRGB(190, 112, 255)
}

local function sh(p: number, p2: number, p3: number, p4: number, value: number?, flag: boolean?)
	return {
		c = Vector2.new(p, p2),
		w = p3,
		h = p4,
		angle = math.rad(value or 0),
		round = flag == true
	}
end
local v2 = {
	{
		c = Vector2.new(0, 0.9),
		w = 0.24,
		h = 0.7,
		angle = 0,
		round = false
	},
	{
		c = Vector2.new(0, -0.9),
		w = 0.24,
		h = 0.7,
		angle = 0,
		round = false
	},
	{
		c = Vector2.new(0.9, 0),
		w = 0.7,
		h = 0.24,
		angle = 0,
		round = false
	},
	{
		c = Vector2.new(-0.9, 0),
		w = 0.7,
		h = 0.24,
		angle = 0,
		round = false
	}
}
local v3 = {
	assist = {
		{
			c = Vector2.new(0, 0),
			w = 1.9,
			h = 0.62,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0, 0),
			w = 0.62,
			h = 1.9,
			angle = 0,
			round = false
		}
	},
	score = {
		{
			c = Vector2.new(-0.37, 0.55),
			w = 0.98,
			h = 0.28,
			angle = 0.5585053606381855,
			round = false
		},
		{
			c = Vector2.new(0.37, 0.55),
			w = 0.98,
			h = 0.28,
			angle = -0.5585053606381855,
			round = false
		},
		{
			c = Vector2.new(-0.37, -0.05),
			w = 0.98,
			h = 0.28,
			angle = 0.5585053606381855,
			round = false
		},
		{
			c = Vector2.new(0.37, -0.05),
			w = 0.98,
			h = 0.28,
			angle = -0.5585053606381855,
			round = false
		},
		{
			c = Vector2.new(-0.37, -0.65),
			w = 0.98,
			h = 0.28,
			angle = 0.5585053606381855,
			round = false
		},
		{
			c = Vector2.new(0.37, -0.65),
			w = 0.98,
			h = 0.28,
			angle = -0.5585053606381855,
			round = false
		}
	},
	damage = {
		{
			c = Vector2.new(0, 0),
			w = 2.5,
			h = 0.42,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0, 0),
			w = 0.42,
			h = 2.5,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0, 0),
			w = 2,
			h = 0.42,
			angle = 0.7853981633974483,
			round = false
		},
		{
			c = Vector2.new(0, 0),
			w = 2,
			h = 0.42,
			angle = -0.7853981633974483,
			round = false
		},
		{
			c = Vector2.new(0, 0),
			w = 1,
			h = 1,
			angle = 0,
			round = true
		}
	},
	capture = {
		{
			c = Vector2.new(-0.8, -0.05),
			w = 0.18,
			h = 2.3,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0.02, 0.55),
			w = 1.5,
			h = 0.95,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(-0.8, -1.15),
			w = 0.7,
			h = 0.16,
			angle = 0,
			round = false
		}
	},
	neutralize = {
		{
			c = Vector2.new(-0.8, -0.05),
			w = 0.18,
			h = 2.3,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0.02, 0.55),
			w = 1.5,
			h = 0.95,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(-0.8, -1.15),
			w = 0.7,
			h = 0.16,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0, 0),
			w = 2.9,
			h = 0.22,
			angle = 0.7853981633974483,
			round = false
		}
	},
	round = {
		{
			c = Vector2.new(-0.9, -0.05),
			w = 0.18,
			h = 2.3,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(-0.5, 0.85),
			w = 0.42,
			h = 0.42,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0.34, 0.85),
			w = 0.42,
			h = 0.42,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(1.18, 0.85),
			w = 0.42,
			h = 0.42,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(-0.08, 0.43),
			w = 0.42,
			h = 0.42,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0.76, 0.43),
			w = 0.42,
			h = 0.42,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(-0.5, 0.01),
			w = 0.42,
			h = 0.42,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0.34, 0.01),
			w = 0.42,
			h = 0.42,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(1.18, 0.01),
			w = 0.42,
			h = 0.42,
			angle = 0,
			round = false
		}
	},
	win = {
		{
			c = Vector2.new(0, 0.45),
			w = 1.3,
			h = 1.2,
			angle = 0,
			round = true
		},
		{
			c = Vector2.new(-0.82, 0.55),
			w = 0.55,
			h = 0.22,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0.82, 0.55),
			w = 0.55,
			h = 0.22,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0, -0.45),
			w = 0.3,
			h = 0.7,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0, -0.95),
			w = 1.2,
			h = 0.28,
			angle = 0,
			round = false
		}
	},
	wreck = {
		{
			c = Vector2.new(-0.53, -0.62),
			w = 0.98,
			h = 0.52,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0.53, -0.62),
			w = 0.98,
			h = 0.52,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0, 0),
			w = 0.98,
			h = 0.52,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0.78, 0.72),
			w = 0.62,
			h = 0.42,
			angle = 0.4886921905584123,
			round = false
		}
	},
	vehicle = {
		{
			c = Vector2.new(0, -0.45),
			w = 2.3,
			h = 0.62,
			angle = 0,
			round = true
		},
		{
			c = Vector2.new(-0.15, 0.12),
			w = 1.1,
			h = 0.55,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0.95, 0.2),
			w = 1.3,
			h = 0.17,
			angle = 0,
			round = false
		}
	},
	turret = {
		{
			c = Vector2.new(0, -1),
			w = 1.7,
			h = 0.3,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0, -0.45),
			w = 0.9,
			h = 0.85,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0, 0.3),
			w = 1.2,
			h = 0.65,
			angle = 0,
			round = true
		},
		{
			c = Vector2.new(1, 0.42),
			w = 1,
			h = 0.14,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(1, 0.18),
			w = 1,
			h = 0.14,
			angle = 0,
			round = false
		}
	},
	close = {
		{
			c = Vector2.new(-0.8, 0.32),
			w = 0.9,
			h = 0.28,
			angle = -0.7853981633974483,
			round = false
		},
		{
			c = Vector2.new(-0.8, -0.32),
			w = 0.9,
			h = 0.28,
			angle = 0.7853981633974483,
			round = false
		},
		{
			c = Vector2.new(0.8, 0.32),
			w = 0.9,
			h = 0.28,
			angle = 0.7853981633974483,
			round = false
		},
		{
			c = Vector2.new(0.8, -0.32),
			w = 0.9,
			h = 0.28,
			angle = -0.7853981633974483,
			round = false
		}
	},
	long = {
		{
			c = Vector2.new(-1.25, 0),
			w = 0.24,
			h = 1.2,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(-0.1, 0),
			w = 2,
			h = 0.3,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0.72, 0.3),
			w = 0.86,
			h = 0.3,
			angle = -0.7853981633974483,
			round = false
		},
		{
			c = Vector2.new(0.72, -0.3),
			w = 0.86,
			h = 0.3,
			angle = 0.7853981633974483,
			round = false
		}
	},
	aimed = table.move(v2, 1, #v2, 2, {
		{
			c = Vector2.new(0, 0),
			w = 0.42,
			h = 0.42,
			angle = 0,
			round = true
		}
	}),
	hip = {
		{
			c = Vector2.new(-1.25, 0.8),
			w = 0.26,
			h = 0.76,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(-0.98, 1.17),
			w = 0.8,
			h = 0.26,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(1.25, 0.8),
			w = 0.26,
			h = 0.76,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0.98, 1.17),
			w = 0.8,
			h = 0.26,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(-1.25, -0.8),
			w = 0.26,
			h = 0.76,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(-0.98, -1.17),
			w = 0.8,
			h = 0.26,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(1.25, -0.8),
			w = 0.26,
			h = 0.76,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0.98, -1.17),
			w = 0.8,
			h = 0.26,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(-0.45, 0.42),
			w = 0.4,
			h = 0.4,
			angle = 0,
			round = true
		},
		{
			c = Vector2.new(0.55, 0.5),
			w = 0.4,
			h = 0.4,
			angle = 0,
			round = true
		},
		{
			c = Vector2.new(0.08, -0.08),
			w = 0.4,
			h = 0.4,
			angle = 0,
			round = true
		},
		{
			c = Vector2.new(-0.42, -0.58),
			w = 0.4,
			h = 0.4,
			angle = 0,
			round = true
		},
		{
			c = Vector2.new(0.6, -0.5),
			w = 0.4,
			h = 0.4,
			angle = 0,
			round = true
		}
	}
}

local v4 = { explosive = "Grenade", fire = "Flamethrower", melee = "Hammer" }
local v5 = {}

local function skull(parent, p: number, imageColor: Color3)
	local skull2 = Instance.new("ImageLabel")
	skull2.Name = "Skull"
	skull2.BackgroundTransparency = 1
	skull2.Image = "rbxassetid://98055525641890"
	skull2.ImageColor3 = imageColor
	skull2.ScaleType = Enum.ScaleType.Fit
	skull2.AnchorPoint = Vector2.new(0.5, 0.5)
	skull2.Position = UDim2.fromScale(0.5, 0.5)
	skull2.Size = UDim2.fromScale(p, p)
	skull2.Parent = parent
end

local function shapes(parent, p: string, p2, color: Color3) -- 2 equivalent calls inferred from this helper
	local v6 = v5[p]

	if not v6 then
		v6 = ToolIcon.artFrom(p2)
		v5[p] = v6
	end

	ToolIcon.draw(v6, parent, color)
end

function QuestIcons.draw(parent, p: string, imageColor: Color3)
	if QuestIcons.RENDERED then
		local image = v[p]
		assert(image, "[QuestIcons] no drawn picture " .. tostring(p))
		local render = Instance.new("ImageLabel")
		render.Name = "Render"
		render.BackgroundTransparency = 1
		render.Image = image
		render.ScaleType = Enum.ScaleType.Fit
		render.AnchorPoint = Vector2.new(0.5, 0.5)
		render.Position = UDim2.fromScale(0.5, 0.5)
		render.Size = UDim2.fromScale(1.3, 1.3)
		render.ImageColor3 = imageColor:Lerp(Color3.new(1, 1, 1), 0.35)
		render.Parent = parent
	elseif p == "kills" then
		skull(parent, 1, imageColor)
	elseif p == "headshot" then
		shapes(parent, "sight", v2, imageColor) -- inferred equivalent call
		skull(parent, 0.5, imageColor)
	else
		if p == "streak" then
			StreakIcon.flat("Airstrike", parent, imageColor)
			return
		end

		if v4[p] then
			ToolIcon.flat(ToolTemplates:FindFirstChild(v4[p]), parent, imageColor)
			return
		end

		local v6 = v3[p]
		assert(v6, "[QuestIcons] no picture " .. tostring(p))
		shapes(parent, p, v6, imageColor) -- inferred equivalent call
	end
end

return QuestIcons