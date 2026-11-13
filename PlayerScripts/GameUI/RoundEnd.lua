game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VehicleConfig = require(ReplicatedStorage:WaitForChild("Vehicles"):WaitForChild("VehicleConfig"))
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local Style = require(script.Parent:WaitForChild("Style"))
local Leaderboard = require(script.Parent:WaitForChild("Leaderboard"))
local RoundEndAudio = require(script.Parent:WaitForChild("RoundEndAudio"))
local ToolIcon = require(script.Parent:WaitForChild("ToolIcon"))
local SkinPreview = require(script.Parent:WaitForChild("SkinPreview"))
local PodiumCards = require(script.Parent:WaitForChild("PodiumCards"))
local Game = ReplicatedStorage:WaitForChild("Game")
local Hardpoint = require(Game:WaitForChild("Hardpoint"))
local Progression = require(Game:WaitForChild("Progression"))
local Skins = require(Game:WaitForChild("Skins"))
local ShopData = require(Game:WaitForChild("ShopData"))
local Podium = require(Game:WaitForChild("Podium"))
local WeaponSkins = require(Game:WaitForChild("WeaponSkins"))
local Detail = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("Detail"))
local ToolTemplates = ReplicatedStorage:WaitForChild("ToolTemplates")

local names = {}

for _, childName in {
	"RifleSpecs",
	"SMGSpecs",
	"LMGSpecs",
	"DMRSpecs",
	"SniperSpecs",
	"PistolSpecs"
} do
	local module = require(Game:WaitForChild(childName))

	for k, v in module.LIST do
		names[k] = v.name
	end
end

local LoadoutData = require(script.Parent:WaitForChild("LoadoutData"))

for _, v in LoadoutData do
	for _, item in v.items do
		names[item.id] = item.name
	end
end

local MapSelect = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("MapSelect"))

local RoundEnd = {}

local touch = Style.isTouch()
local function label(p, p2: string, p3: string, p4: number, p5, p6: number?) -- 16 equivalent calls inferred from this helper
	if touch then
		if p4 <= 18 then
			p4 = math.round(p4 * 1.3)
		elseif p4 <= 30 then
			p4 = math.round(p4 * 1.12)
		end
	end

	return Style.label(p, p2, p3, p4, p5, p6)
end

local function chromeTop()
	return 74 * Style.scale()
end

local v = { grow = true, top = chromeTop }

local v2 = false

local text = ""

local v3 = 4.3 + Podium.LENGTH
local v4 = v3 + 0.45
local v5 = v4 + 7
local v6 = v5 + 0.6
local v7 = Hardpoint.INTERMISSION - 0.8

assert(v7 - v6 >= 6, "RoundEnd: Hardpoint.INTERMISSION is too short for the round-end screens")

local v8 = 260
local v9 = 205
local v10 = 150
local v11 = 120
local function perMap()
	v2 = #Hardpoint.POINTS > 1
	local v12

	if v2 then
		v12 = "DOMINATION  ·  " .. #Hardpoint.POINTS .. " POINTS"
	else
		v12 = "KING OF THE HILL  ·  " .. Hardpoint.NAME
	end

	text = v12

	if v2 then
		v8 = 470
		v9 = 400
		v10 = 330
		v11 = 280
	else
		v8 = 260
		v9 = 205
		v10 = 150
		v11 = 120
	end
end

v2 = #Hardpoint.POINTS > 1

if v2 then
	text = "DOMINATION  ·  " .. #Hardpoint.POINTS .. " POINTS"
else
	text = "KING OF THE HILL  ·  " .. Hardpoint.NAME
end

if v2 then
	v8 = 470
	v9 = 400
	v10 = 330
	v11 = 280
else
	v8 = 260
	v9 = 205
	v10 = 150
	v11 = 120
end

MapSelect.onChange(perMap, 20)
Hardpoint.onPointsChange(perMap)

local v12 = {
	{ key = "rank", caption = "#", w = 28 },
	{ key = "level", caption = "LV", w = 34 },
	{ key = "name", caption = "NAME", w = 170 },
	{ key = "kills", caption = "K", w = 40 },
	{ key = "deaths", caption = "D", w = 40 },
	{ key = "assists", caption = "A", w = 40 },
	{ key = "score", caption = "SCORE", w = 72 }
}
local total = 12

for _, v13 in v12 do
	total += v13.w
end

local vector2 = Vector2.new(total * 2 + 24, 320)

local color = Color3.fromRGB(127, 238, 95)
local color2 = Color3.fromRGB(72, 180, 54)
local color3 = Color3.fromRGB(74, 168, 240)
local color4 = Color3.fromRGB(38, 116, 198)

local function sh(p: number, p2: number, p3: number, p4: number, value: number?, flag: boolean?)
	return {
		c = Vector2.new(p, p2),
		w = p3,
		h = p4,
		angle = math.rad(value or 0),
		round = flag == true
	}
end
local v13 = {
	plus = {
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
	flag = {
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
	shield = {
		{
			c = Vector2.new(0, 0.3),
			w = 1.6,
			h = 1.2,
			angle = 0,
			round = true
		},
		{
			c = Vector2.new(0, -0.35),
			w = 1.13,
			h = 1.13,
			angle = 0.7853981633974483,
			round = false
		}
	},
	tank = {
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
	heli = {
		{
			c = Vector2.new(-0.3, -0.1),
			w = 1.3,
			h = 0.78,
			angle = 0,
			round = true
		},
		{
			c = Vector2.new(0.75, 0),
			w = 1.25,
			h = 0.2,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(1.32, 0.22),
			w = 0.18,
			h = 0.6,
			angle = -0.2617993877991494,
			round = false
		},
		{
			c = Vector2.new(-0.3, 0.76),
			w = 2.4,
			h = 0.13,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(-0.3, 0.5),
			w = 0.16,
			h = 0.4,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(-0.3, -0.78),
			w = 1.5,
			h = 0.12,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(-0.68, -0.62),
			w = 0.1,
			h = 0.3,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0.08, -0.62),
			w = 0.1,
			h = 0.3,
			angle = 0,
			round = false
		}
	},
	beacon = {
		{
			c = Vector2.new(0, -0.25),
			w = 0.24,
			h = 1.7,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0, 0.78),
			w = 1,
			h = 0.5,
			angle = 0,
			round = true
		},
		{
			c = Vector2.new(0, -1.1),
			w = 1.1,
			h = 0.24,
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
	bricks = {
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
	chevrons = {
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
	stack = {
		{
			c = Vector2.new(0, -0.65),
			w = 1.9,
			h = 0.42,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0, -0.05),
			w = 1.4,
			h = 0.42,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0, 0.55),
			w = 0.9,
			h = 0.42,
			angle = 0,
			round = false
		}
	},
	lock = {
		{
			c = Vector2.new(0, -0.4),
			w = 1.5,
			h = 1.15,
			angle = 0,
			round = true
		},
		{
			c = Vector2.new(-0.48, 0.45),
			w = 0.24,
			h = 0.9,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0.48, 0.45),
			w = 0.24,
			h = 0.9,
			angle = 0,
			round = false
		},
		{
			c = Vector2.new(0, 0.86),
			w = 1.2,
			h = 0.24,
			angle = 0,
			round = false
		}
	}
}

local iconsByLabel = {}
local v14 = touch and 150 or 220
local v15 = touch and 6 or 36

for _, v16 in Progression.GROUPS do
	iconsByLabel[v16.label] = v16.icon
end

local function num(value) -- 22 equivalent calls inferred from this helper
	return if type(value) == "number" then value else 0
end

local function str(value) -- 7 equivalent calls inferred from this helper
	return if type(value) == "string" then value else ""
end

local function zeros(p: number, width: number) -- 1 equivalent call inferred from this helper
	local v16 = #tostring((math.floor((math.max(0, p)))))
	return Style.paint(string.rep("0", (math.max(0, width - v16))), Style.DIM) .. Style.paint(Style.thousands(p), Style.WHITE)
end

local function canvas(frame, name: string, udim: UDim2, udim2: UDim2?) -- 1 equivalent call inferred from this helper
	local canvasGroup = Instance.new("CanvasGroup")
	canvasGroup.Name = name
	canvasGroup.BackgroundTransparency = 1
	canvasGroup.BorderSizePixel = 0
	canvasGroup.Size = udim
	canvasGroup.Position = udim2 or UDim2.new()
	canvasGroup.Parent = frame
	return canvasGroup
end

local function fadeGroup(parent, name: string, size: UDim2, udim: UDim2?)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Size = size
	frame.Position = udim or UDim2.new()
	frame.Parent = parent
	local udim2, v16 = UDim2.fromScale(1, 1)
	local canvasGroup = canvas(frame, "Fade", udim2, v16) -- inferred equivalent call
	local body = Instance.new("Frame")
	body.Name = "Body"
	body.BackgroundTransparency = 1
	body.BorderSizePixel = 0
	body.Size = UDim2.fromScale(1, 1)
	body.ClipsDescendants = true
	body.Parent = frame
	local v17 = 0
	return {
		slot = frame,
		body = body,
		set = function(groupTransparency: number)
			if groupTransparency == v17 then
				return
			end

			v17 = groupTransparency
			local v18 = groupTransparency > 0.001
			local parent2 = if v18 then canvasGroup else frame

			if body.Parent ~= parent2 then
				body.Parent = parent2
			end

			if v18 then
				canvasGroup.GroupTransparency = groupTransparency
			end
		end
	}
end

local function fader(folder)
	local v16 = {}
	local function add(instance)
		if instance:IsA("GuiObject") then
			table.insert(v16, { instance, "BackgroundTransparency", instance.BackgroundTransparency })
		end

		if instance:IsA("TextLabel") then
			table.insert(v16, { instance, "TextTransparency", instance.TextTransparency })
		end

		if instance:IsA("UIStroke") then
			table.insert(v16, { instance, "Transparency", instance.Transparency })
		end
	end
	add(folder)

	for _, descendant in folder:GetDescendants() do
		add(descendant)
	end

	local v17 = -1
	return function(p: number)
		if p == v17 then
			return
		end

		v17 = p

		for _, v18 in v16 do
			v18[1][v18[2]] = v18[3] + (1 - v18[3]) * p
		end
	end
end

local function gradient(parent, rotation: number, items)
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Rotation = rotation
	local numberSequenceKeypoints = {}

	for _, item in items do
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(item[1], item[2]))
	end

	uiGradient.Transparency = NumberSequence.new(numberSequenceKeypoints)
	uiGradient.Parent = parent
	return uiGradient
end

local function plan(data, p: number)
	local groups = {}

	for _, group in data.groups do
		local parts = {}

		if type(group.parts) == "table" then
			for _, part in group.parts do
				if not (type(part) == "table" and num(part.xp) > 0) then -- inferred equivalent call
					continue
				end

				local v16 = {
					reason = str(part.reason), -- inferred equivalent call
					xp = num(part.xp), -- inferred equivalent call
					count = num(part.count) -- inferred equivalent call
				}
				table.insert(parts, v16)
			end
		end

		if #parts == 0 then
			parts = {
				{ reason = "", xp = num(group.xp), count = 0 } -- inferred equivalent call
			}
		end

		local v16 = { label = str(group.label), xp = num(group.xp), parts = parts } -- inferred equivalent call
		table.insert(groups, v16)
	end

	local result = {
		before = data.before,
		after = data.after,
		groups = groups,
		pops = {},
		partAt = {},
		groupFrom = {},
		groupEnd = {},
		fills = {},
		beats = {},
		bonusFrom = nil,
		done = 0
	}

	local before = data.before
	local done = 0.75

	for k, v16 in groups do
		result.pops[k] = done
		result.groupFrom[k] = before

		if v16.label == "ROUND BONUS" and not result.bonusFrom then
			result.bonusFrom = before
		end

		local t0 = done + 0.25
		result.partAt[k] = {}
		local v17 = #v16.parts > 1 and 0.2 or 0.55

		for k2, part in v16.parts do
			result.partAt[k][k2] = t0
			local xp = part.xp

			while xp > 0 do
				local level, v18, v19 = Progression.levelOf(before)
				local v20, flag

				if v19 > 0 and v19 - v18 <= xp then
					v20 = v19 - v18
					flag = true
				else
					v20 = xp
					flag = false
				end

				local v21 = math.max(0.08, v17 * v20 / part.xp)
				table.insert(result.fills, {
					t0 = t0,
					t1 = t0 + v21,
					from = before,
					to = before + v20
				})
				t0 += v21
				before += v20
				xp -= v20

				if not flag then
					continue
				end

				table.insert(result.beats, {
					t0 = t0,
					t1 = t0 + 2.6,
					level = level + 1
				})
				t0 += 2.6
			end
		end

		result.groupEnd[k] = t0
		done = t0 + 0.3
	end

	if p < done then
		local v16 = p / done

		for k, pop in result.pops do
			result.pops[k] = pop * v16
		end

		for k, v17 in result.partAt do
			for k2, v18 in v17 do
				v17[k2] = v18 * v16
			end

			result.groupEnd[k] *= v16
		end

		for _, fill in result.fills do
			fill.t0 *= v16
			fill.t1 *= v16
		end

		for _, beat in result.beats do
			beat.t0 *= v16
			beat.t1 *= v16
		end

		done = p
	end

	result.done = done
	return result
end

local function totalAt(p, p2: number)
	local v16 = p.before

	for _, fill in p.fills do
		if fill.t1 <= p2 then
			v16 = fill.to
		elseif fill.t0 < p2 then
			return fill.from + (fill.to - fill.from) * Style.smooth((p2 - fill.t0) / (fill.t1 - fill.t0))
		else
			break
		end
	end

	return v16
end

function RoundEnd.mount(p)
	local domination = Game:WaitForChild("Domination", 30)
	assert(
		domination and domination:IsA("Configuration"),
		"RoundEnd: ReplicatedStorage.Game.Domination is missing (the server's Game.Domination did not start)"
	)
	local player = p.player
	local playerGui = p.playerGui
	local progress = Game:WaitForChild("Remotes"):WaitForChild("Progress")

	local layer = Style.layer(playerGui, "RoundEnd", 20, true)
	local layer2 = Style.layer(playerGui, "RoundEndFrame", 21)
	local layer3 = Style.layer(playerGui, "RoundEndBlack", 22, true)
	local function setShown(enabled: boolean) -- 3 equivalent calls inferred from this helper
		layer.Enabled = enabled
		layer2.Enabled = enabled
		layer3.Enabled = enabled
	end

	setShown(false) -- inferred equivalent call
	local roundEndGrade = Instance.new("ColorCorrectionEffect")
	roundEndGrade.Name = "RoundEndGrade"
	roundEndGrade.Enabled = false
	roundEndGrade.Parent = Lighting
	local roundEndBlur = Instance.new("BlurEffect")
	roundEndBlur.Name = "RoundEndBlur"
	roundEndBlur.Size = 0
	roundEndBlur.Enabled = false
	roundEndBlur.Parent = Lighting

	local frame = Style.frame(layer, "Shade", UDim2.fromScale(1, 1))
	frame.ZIndex = 1
	local fill = Style.fill(frame, "Top", Style.INK, UDim2.fromScale(1, 0.32))
	gradient(fill, 90, {
		{ 0, 0.2 },
		{ 1, 1 }
	})
	local fill2 = Style.fill(
		frame,
		"Bottom",
		Style.INK,
		UDim2.fromScale(1, 0.62),
		UDim2.fromScale(0, 1),
		Vector2.new(0, 1)
	)
	gradient(fill2, 90, {
		{ 0, 1 },
		{ 1, 0.12 }
	})
	local fill3 = Style.fill(frame, "Tint", Style.INK, UDim2.fromScale(1, 1))
	fill3.BackgroundTransparency = 0.5

	local frame2 = Style.frame(
		layer,
		"Banner",
		UDim2.new(1, 0, 0, 130),
		UDim2.fromScale(0.5, 0.42),
		Vector2.new(0.5, 0.5)
	)
	frame2.ZIndex = 4
	Style.onScale(function(p2)
		frame2.Size = UDim2.new(1, 0, 0, 130 * p2)
	end)
	local fill4 = Style.fill(
		frame2,
		"Band",
		Style.STEEL,
		UDim2.fromScale(1, 1),
		UDim2.fromScale(0.5, 0.5),
		Vector2.new(0.5, 0.5)
	)
	gradient(fill4, 0, {
		{ 0, 1 },
		{ 0.18, 0.2 },
		{ 0.82, 0.2 },
		{ 1, 1 }
	})
	local tape = Style.tape(fill4, "TapeTop", UDim2.new(1, 0, 0, 4), 4000, 14)
	local tape2 = Style.tape(fill4, "TapeBottom", UDim2.new(1, 0, 0, 4), 4000, 14)
	tape2.AnchorPoint = Vector2.new(0, 1)
	tape2.Position = UDim2.fromScale(0, 1)
	local parent2 = Style.region(frame2, "Text", Vector2.new(0.5, 0.5), Vector2.zero, Vector2.new(900, 130))
	parent2.AnchorPoint = Vector2.new(0.5, 0.5)
	local v16 = 60
	local v17 = Style.FONT

	if touch then
		if v16 <= 18 then
			v16 = math.round(v16 * 1.3)
		elseif v16 <= 30 then
			v16 = math.round(v16 * 1.12)
		end
	end

	local label2 = Style.label(parent2, "Result", "", v16, v17, 2.5)

	label2.AnchorPoint = Vector2.new(0.5, 0.5)
	label2.Position = UDim2.fromOffset(450, 52)
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = label2
	v16 = 17
	v17 = Style.FONT_BODY

	if touch then
		if v16 <= 18 then
			v16 = math.round(v16 * 1.3)
		elseif v16 <= 30 then
			v16 = math.round(v16 * 1.12)
		end
	end

	local label3 = Style.label(parent2, "Reason", "", v16, v17, 1.5)

	label3.RichText = true
	label3.AnchorPoint = Vector2.new(0.5, 0.5)
	label3.Position = UDim2.fromOffset(450, 102)
	local v18 = fader(frame2)

	local frame3 = Style.frame(layer, "Chrome", UDim2.fromScale(1, 1))
	frame3.ZIndex = 3
	local frame4 = Style.frame(layer2, "ChromeText", UDim2.fromScale(1, 1))
	Style.tape(frame3, "TapeTop", UDim2.new(1, 0, 0, 5), 4000, 14).Position = UDim2.fromScale(0, 0)
	parent2 = Style.tape(frame3, "TapeBottom", UDim2.new(1, 0, 0, 5), 4000, 14)
	parent2.AnchorPoint = Vector2.new(0, 1)
	parent2.Position = UDim2.fromScale(0, 1)

	local region = Style.region(frame4, "Mode", Vector2.zero, Vector2.zero, Vector2.new(300, 56))
	parent2 = text
	v16 = 14
	v17 = Style.FONT

	if touch then
		if v16 <= 18 then
			v16 = math.round(v16 * 1.3)
		elseif v16 <= 30 then
			v16 = math.round(v16 * 1.12)
		end
	end

	local label4 = Style.label(region, "Mode", parent2, v16, v17, 1)

	label4.TextColor3 = Style.MUTED
	parent2 = string.upper(MapSelect.name)
	v16 = 30
	v17 = Style.FONT

	if touch then
		if v16 <= 18 then
			v16 = math.round(v16 * 1.3)
		elseif v16 <= 30 then
			v16 = math.round(v16 * 1.12)
		end
	end

	local label5 = Style.label(region, "Map", parent2, v16, v17, 2)

	label5.Position = UDim2.fromOffset(0, 16)

	local region2 = Style.region(frame4, "Result", Vector2.new(1, 0), Vector2.zero, Vector2.new(300, 56))
	parent2 = 26
	v16 = Style.FONT

	if touch then
		if parent2 <= 18 then
			parent2 = math.round(parent2 * 1.3)
		elseif parent2 <= 30 then
			parent2 = math.round(parent2 * 1.12)
		end
	end

	local label6 = Style.label(region2, "Result", "", parent2, v16, 2)

	label6.AnchorPoint = Vector2.new(1, 0)
	label6.Position = UDim2.fromScale(1, 0)
	parent2 = 14
	v16 = Style.FONT

	if touch then
		if parent2 <= 18 then
			parent2 = math.round(parent2 * 1.3)
		elseif parent2 <= 30 then
			parent2 = math.round(parent2 * 1.12)
		end
	end

	local label7 = Style.label(region2, "Round", "", parent2, v16, 1)

	label7.TextColor3 = Style.MUTED
	label7.AnchorPoint = Vector2.new(1, 0)
	label7.Position = UDim2.new(1, 0, 0, 32)

	Style.onScale(function(p2)
		local v19 = Style.topInset() + 14 * p2
		region.Position = UDim2.new(0, 24, 0, v19)
		region2.Position = UDim2.new(1, -24, 0, v19)
	end)

	local region3 = Style.region(frame4, "Steps", Vector2.new(0.5, 0), Vector2.zero, Vector2.new(450, 30))
	Style.onScale(function(p2)
		region3.Position = UDim2.new(0.5, 0, 0, Style.topInset() + 18 * p2)
	end)

	if touch then
		region.Visible = false
		region3.Visible = false
	end

	parent2 = Instance.new("UIListLayout")
	parent2.FillDirection = Enum.FillDirection.Horizontal
	parent2.HorizontalAlignment = Enum.HorizontalAlignment.Center
	parent2.Padding = UDim.new(0, 10)
	parent2.SortOrder = Enum.SortOrder.LayoutOrder
	parent2.Parent = region3
	local v19 = {}

	for k, v20 in { "TOP 3", "SCOREBOARD", "LEVEL" } do
		local box = Style.box(region3, "Step" .. k, Style.PANEL, UDim2.fromOffset(0, 28), 2, 1.5)
		box.AutomaticSize = Enum.AutomaticSize.X
		box.LayoutOrder = k
		local v21 = Instance.new("UIPadding")
		v21.PaddingLeft = UDim.new(0, 10)
		v21.PaddingRight = UDim.new(0, 10)
		v21.Parent = box
		v21 = string.format("%02d  %s", k, v20)
		local label8 = label(box, "Text", v21, 15, Style.FONT, 0) -- inferred equivalent call
		label8.Size = UDim2.fromOffset(0, 28)
		v19[k] = { chip = box, label = label8 }
	end

	local v20 = 0
	local function setStep(p2: number)
		if p2 == v20 then
			return
		end

		v20 = p2

		for k, v21 in v19 do
			local chip = v21.chip
			local backgroundColor

			if k == p2 then
				backgroundColor = Style.HAZARD
			else
				backgroundColor = Style.PANEL
			end

			chip.BackgroundColor3 = backgroundColor
			v21.chip.BackgroundTransparency = k == p2 and 0 or Style.PANEL_ALPHA
			local label8 = v21.label
			local textColor = if k == p2 then Style.INK else Style.DIM
			label8.TextColor3 = textColor
		end
	end

	local region4 = Style.region(frame4, "Next", Vector2.new(1, 1), Vector2.new(-24, -20), Vector2.new(220, 56))
	parent2 = 30
	v16 = Style.FONT

	if touch then
		if parent2 <= 18 then
			parent2 = math.round(parent2 * 1.3)
		elseif parent2 <= 30 then
			parent2 = math.round(parent2 * 1.12)
		end
	end

	local label8 = Style.label(region4, "Clock", "", parent2, v16, 2)

	label8.TextColor3 = Style.HAZARD
	label8.AnchorPoint = Vector2.new(1, 1)
	label8.Position = UDim2.fromScale(1, 1)
	parent2 = 14
	v16 = Style.FONT

	if touch then
		if parent2 <= 18 then
			parent2 = math.round(parent2 * 1.3)
		elseif parent2 <= 30 then
			parent2 = math.round(parent2 * 1.12)
		end
	end

	v17 = Style.label(region4, "Caption", "NEXT ROUND IN", parent2, v16, 1)

	v17.TextColor3 = Style.MUTED
	v17.AnchorPoint = Vector2.new(1, 1)
	v17.Position = UDim2.new(1, 0, 1, -34)

	if touch then
		region4.AnchorPoint = Vector2.zero
		label8.AnchorPoint = Vector2.new(0, 1)
		label8.Position = UDim2.fromScale(0, 1)
		v17.AnchorPoint = Vector2.new(0, 1)
		v17.Position = UDim2.new(0, 0, 1, -36)
		Style.onScale(function(p2)
			region4.Position = UDim2.new(0, 24, 0, Style.topInset() + 14 * p2)
		end)
	end

	local region5 = Style.region(layer, "Board", Vector2.new(0.5, 0.5), Vector2.zero, vector2)
	region5.ZIndex = 2
	parent2 = Style.fit
	v16 = vector2
	v17 = touch and 0.97 or 0.9
	local parent3

	if touch then
		parent3 = v
	end

	local v21 = parent2(region5, v16, v17, parent3)

	local function buildSide(p2: number)
		local frame5 = Style.frame(region5, "Side", UDim2.fromOffset(total, vector2.Y), UDim2.fromOffset(p2, 0))
		local box = Style.box(frame5, "Header", Style.PANEL, UDim2.new(1, 0, 0, 60), 3, 2)
		box.BackgroundTransparency = 0.05
		local fill5 = Style.fill(box, "Band", Style.WHITE, UDim2.new(0, 6, 1, 0))
		local frame6 = Style.frame(
			box,
			"EmblemHolder",
			UDim2.fromOffset(30, 30),
			UDim2.new(0, 18, 0.5, 0),
			Vector2.new(0, 0.5)
		)
		local name = label(box, "Team", "", 26, Style.FONT, 1.5) -- inferred equivalent call
		name.AnchorPoint = Vector2.new(0, 0.5)
		name.Position = UDim2.new(0, 58, 0.5, -8)
		local tag = label(box, "Tag", "", 13, Style.FONT, 0) -- inferred equivalent call
		tag.TextColor3 = Style.HAZARD
		tag.AnchorPoint = Vector2.new(0, 0.5)
		tag.Position = UDim2.new(0, 59, 0.5, 15)
		local points = label(box, "Points", "", 40, Style.FONT, 2) -- inferred equivalent call
		points.AnchorPoint = Vector2.new(1, 0.5)
		points.Position = UDim2.new(1, -14, 0.5, 0)

		local frame7 = Style.frame(frame5, "Captions", UDim2.new(1, 0, 0, 20), UDim2.fromOffset(0, 60))
		local total2 = 8

		for _, v22 in v12 do
			local v23 = label(frame7, v22.caption, v22.caption, 12, Style.FONT, 0) -- inferred equivalent call
			v23.AutomaticSize = Enum.AutomaticSize.None
			v23.Size = UDim2.fromOffset(v22.w, 20)
			v23.Position = UDim2.fromOffset(total2, 0)
			v23.TextColor3 = Style.DIM
			local textXAlignment

			if v22.key == "name" then
				textXAlignment = Enum.TextXAlignment.Left
			else
				textXAlignment = Enum.TextXAlignment.Center
			end

			v23.TextXAlignment = textXAlignment
			total2 += v22.w
		end

		local rows = {}

		for i = 1, 16 do
			local frame8 = Style.frame(
				frame5,
				"Row" .. i,
				UDim2.fromOffset(total, 22),
				UDim2.fromOffset(0, (i - 1) * 24 + 80)
			)
			frame8.Visible = false
			local fill6 = Style.fill(frame8, "Plate", Style.PANEL, UDim2.fromScale(1, 1))
			fill6.BackgroundTransparency = i % 2 == 0 and 0.3 or 0.15
			local fill7 = Style.fill(frame8, "Edge", Style.HAZARD, UDim2.new(0, 6, 1, 0))
			fill7.ZIndex = 2
			local total3 = 8
			local cells = {}
			local v22 = 0

			for _, v23 in v12 do
				if v23.key == "name" then
					v22 = total3
				end

				local key = v23.key
				local v24 = v23.key == "score" and 16 or 15
				local v25

				if v23.key == "name" then
					v25 = Style.FONT_BODY
				else
					v25 = Style.FONT
				end

				local v26 = label(frame8, key, "", v24, v25, 0) -- inferred equivalent call
				v26.AutomaticSize = Enum.AutomaticSize.None
				v26.Size = UDim2.new(0, v23.w, 1, 0)
				v26.Position = UDim2.fromOffset(total3, 0)
				local textXAlignment

				if v23.key == "name" then
					textXAlignment = Enum.TextXAlignment.Left
				else
					textXAlignment = Enum.TextXAlignment.Center
				end

				v26.TextXAlignment = textXAlignment
				v26.TextTruncate = Enum.TextTruncate.AtEnd
				local textColor

				if v23.key == "rank" then
					textColor = Style.DIM
				elseif v23.key == "level" then
					textColor = Style.MUTED
				elseif v23.key == "score" then
					textColor = Style.HAZARD
				else
					textColor = Style.WHITE
				end

				v26.TextColor3 = textColor
				cells[v23.key] = v26
				total3 += v23.w
			end

			local robot, botParts = Leaderboard.robot(frame8)
			robot.AnchorPoint = Vector2.new(0, 0.5)
			robot.Position = UDim2.new(0, v22, 0.5, 0)
			robot.Visible = false
			local uiPadding = Instance.new("UIPadding")
			uiPadding.Parent = cells.name
			rows[i] = {
				group = frame8,
				fade = fader(frame8),
				alpha = 1,
				plate = fill6,
				plateAlpha = fill6.BackgroundTransparency,
				plateRest = fill6.BackgroundTransparency,
				edge = fill7,
				cells = cells,
				bot = robot,
				botParts = botParts,
				namePad = uiPadding,
				score = 0,
				at = 0,
				shown = -1
			}
		end

		return {
			band = fill5,
			emblem = frame6,
			name = name,
			tag = tag,
			points = points,
			rows = rows
		}
	end

	local v22 = { buildSide(0), buildSide(total + 24) }

	local region6 = Style.region(layer, "Level", Vector2.new(0.5, 0.5), Vector2.zero, Vector2.new(1000, 500))

	region6.AnchorPoint = Vector2.new(not touch and 0.5 or 0.5 - (v14 + v15) / 2000, 0.5)
	region6.Position = UDim2.new(0.5, 0, touch and 0.5 or 0.53, 0)
	region6.ZIndex = 2

	if touch then
		Style.fit(region6, Vector2.new(v14 + 1000 + v15, 500), 0.97, { grow = true })
	else
		Style.fit(region6, Vector2.new((v14 + v15) * 2 + 1000, 500), 0.9)
	end

	local v23 = fadeGroup(region6, "BarRow", UDim2.fromOffset(1000, 214), UDim2.fromOffset(0, 120))
	local body = v23.body

	local v24 = {}
	local function drawIcon(parent, p2: string)
		if p2 == "skull" then
			local skull = Instance.new("ImageLabel")
			skull.Name = "Skull"
			skull.BackgroundTransparency = 1
			skull.Image = "rbxassetid://98055525641890"
			skull.ScaleType = Enum.ScaleType.Fit
			skull.AnchorPoint = Vector2.new(0.5, 0.5)
			skull.Position = UDim2.fromScale(0.5, 0.5)
			skull.Size = UDim2.fromScale(1, 1)
			skull.Parent = parent
			return function(imageColor: Color3)
				skull.ImageColor3 = imageColor
			end
		else
			local v25 = v24[p2]

			if not v25 then
				local v26 = v13[p2]
				assert(v26, "RoundEnd: no award picture " .. tostring(p2))
				v25 = ToolIcon.artFrom(v26)
				v24[p2] = v25
			end

			local _, v26 = ToolIcon.draw(v25, parent, Style.WHITE)
			return v26
		end
	end

	local function reasonIcon(reason: string, label9: string) -- 2 equivalent calls inferred from this helper
		local v25 = Progression.REASONS[reason]

		if v25 then
			return v25.icon
		end

		return iconsByLabel[label9] or "stack"
	end

	local function makePlate(body2, p2: string, p3: number)
		local box = Style.box(body2, p2, Style.PANEL, UDim2.fromOffset(p3, p3), 3, 1.5)
		box.AnchorPoint = Vector2.new(0.5, 0.5)
		local frame5 = Style.frame(
			box,
			"Icon",
			UDim2.fromScale(0.7, 0.7),
			UDim2.fromScale(0.5, 0.5),
			Vector2.new(0.5, 0.5)
		)
		local fill5 = Style.fill(box, "Flash", Style.WHITE, UDim2.fromScale(1, 1))
		fill5.BackgroundTransparency = 1
		fill5.ZIndex = 5
		local uiScale2 = Instance.new("UIScale")
		uiScale2.Parent = box
		return {
			frame = box,
			holder = frame5,
			flash = fill5,
			scale = uiScale2,
			id = "",
			paint = function(_: Color3) end,
			color = nil
		}
	end

	local function setIcon(state, id: string)
		if state.id == id then
			return
		end

		state.id = id
		state.color = nil

		for _, child in state.holder:GetChildren() do
			child:Destroy()
		end

		state.paint = drawIcon(state.holder, id)
	end
	local function paintPlate(state, color5: Color3) -- 2 equivalent calls inferred from this helper
		if state.color ~= color5 then
			state.color = color5
			state.paint(color5)
		end
	end

	local plate = makePlate(body, "Award", 64)
	plate.frame.Position = UDim2.fromOffset(500, 40)
	local v25 = {}

	for i = -1, 1, 2 do
		local tape3 = Style.tape(body, i < 0 and "StubL" or "StubR", UDim2.fromOffset(14, 34), 14, 8)
		tape3.AnchorPoint = Vector2.new(i < 0 and 1 or 0, 0.5)
		tape3.Position = UDim2.fromOffset(i * 42 + 500, 40)
		table.insert(v25, tape3)
	end

	local plates = {}

	for i = 1, 8 do
		local plate2 = makePlate(body, "Reel" .. i, 42)
		plate2.frame.Visible = false
		plates[i] = plate2
	end

	parent2 = 30
	v16 = Style.FONT

	if touch then
		if parent2 <= 18 then
			parent2 = math.round(parent2 * 1.3)
		elseif parent2 <= 30 then
			parent2 = math.round(parent2 * 1.12)
		end
	end

	local label9 = Style.label(body, "Amount", "", parent2, v16, 2)

	label9.AnchorPoint = Vector2.new(0.5, 0)
	label9.Position = UDim2.fromOffset(500, 76)
	local uiScale2 = Instance.new("UIScale")
	uiScale2.Parent = label9
	parent2 = 14
	v16 = Style.FONT

	if touch then
		if parent2 <= 18 then
			parent2 = math.round(parent2 * 1.3)
		elseif parent2 <= 30 then
			parent2 = math.round(parent2 * 1.12)
		end
	end

	local label10 = Style.label(body, "Caption", "", parent2, v16, 1)

	label10.RichText = true
	label10.AnchorPoint = Vector2.new(0.5, 0)
	label10.Position = UDim2.fromOffset(500, 110)

	local function badge(p2: string, p3: number, flag: boolean)
		local box = Style.box(body, p2, Style.PANEL, UDim2.fromOffset(96, 96), 3, 2)
		box.Position = UDim2.fromOffset(p3, 101)
		box.BackgroundTransparency = flag and 0.35 or 0.05
		local tape3 = Style.tape(box, "Tape", UDim2.new(1, 0, 0, 6), 96, 10)
		local backgroundColor

		if flag then
			backgroundColor = Style.STEEL
		else
			backgroundColor = Style.HAZARD
		end

		tape3.BackgroundColor3 = backgroundColor
		local v26 = label(box, "Word", "LEVEL", 13, Style.FONT, 0) -- inferred equivalent call
		v26.TextColor3 = Style.MUTED
		v26.AnchorPoint = Vector2.new(0.5, 0)
		v26.Position = UDim2.new(0.5, 0, 0, 12)
		local v27 = label(box, "Number", "", 46, Style.FONT, 2) -- inferred equivalent call
		v27.AnchorPoint = Vector2.new(0.5, 0.5)
		v27.Position = UDim2.new(0.5, 0, 0, 60)
		local textColor = if flag then Style.MUTED else Style.WHITE
		v27.TextColor3 = textColor
		local uiScale3 = Instance.new("UIScale")
		uiScale3.Parent = v27
		return {
			frame = box,
			number = v27,
			pop = uiScale3,
			x = p3,
			fade = fader(box)
		}
	end

	local v26 = badge("Now", 0, false)
	local v27 = badge("Next", 904, true)

	local fill5 = Style.fill(
		body,
		"Track",
		Color3.fromRGB(46, 47, 50),
		UDim2.fromOffset(760, 18),
		UDim2.fromOffset(500, 140),
		Vector2.new(0.5, 0)
	)
	fill5.BackgroundTransparency = 0.15
	fill5.ClipsDescendants = true
	table.insert(v25, fill5)
	local fill6 = Style.fill(fill5, "Had", Style.WHITE, UDim2.fromScale(0, 1))
	fill6.ZIndex = 2

	local function segment(p2: string, color5: Color3, color6: Color3)
		local fill7 = Style.fill(fill5, p2, color5, UDim2.fromScale(0, 1))
		fill7.ClipsDescendants = true
		fill7.ZIndex = 2
		local frame5 = Style.frame(fill7, "Strip", UDim2.fromOffset(788, 18))
		local fills = {}

		for i = 0, 57 do
			for j = 1, 2 do
				local fill8 = Style.fill(
					frame5,
					"Chevron",
					color6,
					UDim2.fromOffset(4, 11),
					UDim2.fromOffset(i * 14, (j == 1 and 0.27 or 0.73) * 18),
					Vector2.new(0.5, 0.5)
				)
				fill8.Rotation = j == 1 and -42 or 42
				table.insert(fills, fill8)
			end
		end

		return {
			window = fill7,
			strip = frame5,
			color = color5,
			dark = color6,
			slats = fills
		}
	end

	local v28 = segment("Gain", color, color2)
	local v29 = segment("Bonus", color3, color4)
	local function placeSeg(p2, p3: number, p4: number, p5: number)
		p2.window.Visible = p3 < p4
		p2.window.Position = UDim2.fromScale(p3, 0)
		p2.window.Size = UDim2.fromScale(math.max(0, p4 - p3), 1)
		p2.strip.Position = UDim2.fromOffset(-p3 * 760 - 14 + p5, 0)
	end
	local function tintSeg(data, p2: number) -- 4 equivalent calls inferred from this helper
		data.window.BackgroundColor3 = data.color:Lerp(Style.STEEL_LIGHT, p2)
		local lerped = data.dark:Lerp(Style.STEEL, p2)

		for _, slat in data.slats do
			slat.BackgroundColor3 = lerped
		end
	end

	for i = -1, 1, 2 do
		table.insert(
			v25,
			(Style.fill(
				body,
				"Cap",
				Style.DIM,
				UDim2.fromOffset(2, 30),
				UDim2.fromOffset(i * 386 + 500, 134),
				Vector2.new(0.5, 0)
			))
		)
	end

	local fill7 = Style.fill(
		body,
		"Tick",
		Style.WHITE,
		UDim2.fromOffset(7, 7),
		UDim2.fromOffset(120, 164),
		Vector2.new(0.5, 0.5)
	)
	fill7.Rotation = 45
	table.insert(v25, fill7)

	parent2 = Style.box(body, "Counter", Style.PANEL, UDim2.fromOffset(250, 38), 2, 1.5)
	parent2.BackgroundTransparency = 0.35
	parent2.AnchorPoint = Vector2.new(0.5, 0)
	parent2.Position = UDim2.fromOffset(500, 174)
	v16 = 26
	v17 = Style.FONT

	if touch then
		if v16 <= 18 then
			v16 = math.round(v16 * 1.3)
		elseif v16 <= 30 then
			v16 = math.round(v16 * 1.12)
		end
	end

	local label11 = Style.label(parent2, "Count", "", v16, v17, 0)

	label11.RichText = true
	label11.AnchorPoint = Vector2.new(0.5, 0.5)
	label11.Position = UDim2.new(0.5, -8, 0.5, 0)
	v16 = 12
	v17 = Style.FONT

	if touch then
		if v16 <= 18 then
			v16 = math.round(v16 * 1.3)
		elseif v16 <= 30 then
			v16 = math.round(v16 * 1.12)
		end
	end

	parent3 = Style.label(parent2, "XP", "XP", v16, v17, 0)

	parent3.TextColor3 = Style.MUTED
	parent3.AnchorPoint = Vector2.new(0, 0.5)
	parent3.Position = UDim2.new(0.5, 50, 0.5, 2)
	local v30 = fader(parent2)
	parent2 = 14
	v16 = Style.FONT_BODY

	if touch then
		if parent2 <= 18 then
			parent2 = math.round(parent2 * 1.3)
		elseif parent2 <= 30 then
			parent2 = math.round(parent2 * 1.12)
		end
	end

	local label12 = Style.label(body, "Into", "", parent2, v16, 1)

	label12.TextColor3 = Style.MUTED
	label12.AnchorPoint = Vector2.new(1, 0)
	label12.Position = UDim2.fromOffset(880, 166)

	local function head(p2: string, p3: number)
		local v31 = label(region6, p2, p2, 14, Style.FONT, 1) -- inferred equivalent call
		v31.TextColor3 = Style.MUTED
		v31.Position = UDim2.fromOffset(0, p3)
		local fill8 = Style.fill(
			region6,
			p2 .. "Rule",
			Style.DIM,
			UDim2.fromOffset(0, 1),
			UDim2.fromOffset(120, p3 + 10)
		)
		fill8.BackgroundTransparency = 0.3
		return { fade = fader(v31), rule = fill8 }
	end

	local v31 = head("YOUR ROUND", 236)
	local v32 = head("UNLOCKS", 350)

	local v36 = {}

	for k, v37 in {
		{ "KILLS", "Takedowns", 3 },
		{ "ASSISTS", "Supports", 3 },
		{ "DEATHS", "Deaths", 3 },
		{ "SCORE", "Score", 5 }
	} do
		local v38 = (k - 1) * 254
		local group = fadeGroup(region6, "Tile" .. k, UDim2.fromOffset(238, 78), UDim2.fromOffset(v38, 260))
		group.slot.Visible = false
		local body2 = group.body
		Style.fill(body2, "Plate", Style.PANEL, UDim2.fromScale(1, 1)).BackgroundTransparency = 0.25
		local v41 = Style.FONT
		local v42 = label(body2, "Value", "", 34, v41, 0) -- inferred equivalent call
		v42.RichText = true
		v42.Position = UDim2.fromOffset(14, 2)
		v41 = v37[1]
		local v43 = label(body2, "Caption", v41, 13, Style.FONT, 0) -- inferred equivalent call
		v43.TextColor3 = Style.MUTED
		v43.Position = UDim2.fromOffset(15, 46)
		local fill8 = Style.fill(body2, "Line", Style.STEEL, UDim2.new(1, -28, 0, 2), UDim2.new(0, 14, 1, -9))
		v36[k] = {
			group = group,
			value = v42,
			fill = Style.fill(fill8, "Fill", Style.WHITE, UDim2.fromScale(0, 1)),
			attr = v37[2],
			width = v37[3],
			final = 0,
			x = v38
		}
	end

	local v37 = {}

	for i = 1, 4 do
		local box = Style.box(region6, "Card" .. i, Style.PANEL, UDim2.fromOffset(168, 118), 3, 1.5)
		box.AnchorPoint = Vector2.new(0.5, 0.5)
		box.Position = UDim2.fromOffset((i - 1) * 182 + 84, 433)
		box.Visible = false
		local tape3 = Style.tape(box, "Tape", UDim2.new(1, 0, 0, 5), 168, 10)
		local frame5 = Style.frame(box, "Pic", UDim2.new(1, -8, 0, 70), UDim2.fromOffset(4, 8))
		frame5.ClipsDescendants = true
		local flash = Style.FONT
		local name = label(box, "Name", "", 16, flash, 1) -- inferred equivalent call
		name.AutomaticSize = Enum.AutomaticSize.None
		name.Size = UDim2.new(1, -16, 0, 20)
		name.TextXAlignment = Enum.TextXAlignment.Left
		name.TextTruncate = Enum.TextTruncate.AtEnd
		name.Position = UDim2.fromOffset(8, 78)
		flash = Style.FONT
		local sub = label(box, "Sub", "", 12, flash, 0) -- inferred equivalent call
		sub.TextColor3 = Style.MUTED
		sub.Position = UDim2.fromOffset(8, 98)
		flash = Style.fill(box, "Flash", Style.WHITE, UDim2.fromScale(1, 1))
		flash.BackgroundTransparency = 1
		flash.ZIndex = 6
		local uiScale3 = Instance.new("UIScale")
		uiScale3.Parent = box
		v37[i] = {
			root = box,
			pic = frame5,
			tape = tape3,
			name = name,
			sub = sub,
			flash = flash,
			scale = uiScale3,
			locked = false
		}
	end

	parent2 = 16
	v16 = Style.FONT

	if touch then
		if parent2 <= 18 then
			parent2 = math.round(parent2 * 1.3)
		elseif parent2 <= 30 then
			parent2 = math.round(parent2 * 1.12)
		end
	end

	local label13 = Style.label(region6, "More", "", parent2, v16, 1)

	label13.TextColor3 = Style.MUTED
	label13.AnchorPoint = Vector2.new(0, 0.5)
	label13.Position = UDim2.fromOffset(732, 433)
	parent2 = 15
	v16 = Style.FONT

	if touch then
		if parent2 <= 18 then
			parent2 = math.round(parent2 * 1.3)
		elseif parent2 <= 30 then
			parent2 = math.round(parent2 * 1.12)
		end
	end

	local label14 = Style.label(region6, "AllUnlocked", "", parent2, v16, 1)

	label14.TextColor3 = Style.MUTED
	label14.Position = UDim2.fromOffset(0, 380)

	local v38 = -(v14 + v15)
	local frame5 = Style.frame(region6, "Soldier", UDim2.fromOffset(v14, 500), UDim2.fromOffset(v38, 0))
	frame5.Visible = false
	local fill8 = Style.fill(
		frame5,
		"Glow",
		Style.WHITE,
		UDim2.new(1, 0, 0, 200),
		UDim2.new(0, 0, 1, -60),
		Vector2.new(0, 1)
	)
	gradient(fill8, 90, {
		{ 0, 1 },
		{ 1, 0.9 }
	})
	local tape3 = Style.tape(frame5, "Floor", UDim2.new(1, 0, 0, 5), v14, 10)
	tape3.AnchorPoint = Vector2.new(0, 1)
	tape3.Position = UDim2.new(0, 0, 1, -56)

	parent2 = Style.frame
	v16 = "View"

	if touch then
		v17 = UDim2.fromOffset(180, 310)
	else
		v17 = UDim2.new(1, 0, 1, -40)
	end

	parent3 = parent2(frame5, v16, v17, UDim2.new(0.5, 0, 1, -64), Vector2.new(0.5, 1))
	local uiScale3 = Instance.new("UIScale")
	uiScale3.Parent = parent3
	local view = SkinPreview.view(parent3, "full")
	view.frame.Active = false
	parent2 = 20
	v16 = Style.FONT

	if touch then
		if parent2 <= 18 then
			parent2 = math.round(parent2 * 1.3)
		elseif parent2 <= 30 then
			parent2 = math.round(parent2 * 1.12)
		end
	end

	local label15 = Style.label(frame5, "Name", "", parent2, v16, 1.5)

	label15.AutoLocalize = false
	label15.AutomaticSize = Enum.AutomaticSize.None
	label15.Size = UDim2.new(1, 0, 0, 24)
	label15.TextTruncate = Enum.TextTruncate.AtEnd
	label15.Position = UDim2.new(0, 0, 1, -48)
	parent2 = 13
	v16 = Style.FONT

	if touch then
		if parent2 <= 18 then
			parent2 = math.round(parent2 * 1.3)
		elseif parent2 <= 30 then
			parent2 = math.round(parent2 * 1.12)
		end
	end

	local label16 = Style.label(frame5, "Outfit", "", parent2, v16, 0)

	label16.AutomaticSize = Enum.AutomaticSize.None
	label16.Size = UDim2.new(1, 0, 0, 16)
	label16.Position = UDim2.new(0, 0, 1, -22)
	label16.TextColor3 = Style.MUTED

	local v39 = CFrame.identity

	local frame6 = Style.frame(region6, "Dissolve", UDim2.fromOffset(792, 64), UDim2.fromOffset(104, 237))
	frame6.Visible = false
	frame6.ZIndex = 4

	local random = Random.new(11)
	local v40 = {}
	local v41 = nil

	for i = 0, 3 do
		for j = 0, 48 do
			local fill9 = Style.fill(
				frame6,
				"Cell",
				Style.WHITE,
				UDim2.fromOffset(13, 13),
				UDim2.fromOffset(j * 16, i * 16)
			)
			fill9.BackgroundTransparency = 1
			table.insert(v40, {
				f = fill9,
				d = random:NextNumber(),
				u = (j * 16 + 8 - 396) / 396
			})
		end
	end

	local frame7 = Style.frame(
		region6,
		"Slab",
		UDim2.fromOffset(760, 26),
		UDim2.fromOffset(500, 269),
		Vector2.new(0.5, 0.5)
	)
	frame7.Visible = false
	frame7.ZIndex = 6
	local function slabBar(p2: string, color5: Color3)
		return Style.fill(frame7, p2, color5, UDim2.fromScale(1, 1), UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5))
	end

	local v42 = slabBar("Red", Color3.fromRGB(255, 72, 60))
	local v43 = slabBar("Blue", Color3.fromRGB(70, 140, 255))
	local v44 = slabBar("White", Style.WHITE)

	local frame8 = Style.frame(
		region6,
		"Beat",
		UDim2.fromOffset(2600, 560),
		UDim2.fromOffset(500, 250),
		Vector2.new(0.5, 0.5)
	)
	frame8.Visible = false
	frame8.ZIndex = 5
	parent2 = Style.fill(frame8, "Band", Style.INK, UDim2.fromScale(1, 1))
	parent2.BackgroundTransparency = 0.12
	gradient(parent2, 0, {
		{ 0, 1 },
		{ 0.3, 0.12 },
		{ 0.7, 0.12 },
		{ 1, 1 }
	})
	parent2 = Style.tape(frame8, "TapeTop", UDim2.new(0, 1400, 0, 4), 1400, 14)
	parent2.AnchorPoint = Vector2.new(0.5, 0)
	parent2.Position = UDim2.fromScale(0.5, 0)
	parent2 = Style.tape(frame8, "TapeBottom", UDim2.new(0, 1400, 0, 4), 1400, 14)
	parent2.AnchorPoint = Vector2.new(0.5, 1)
	parent2.Position = UDim2.fromScale(0.5, 1)
	local v45 = fader(frame8)

	local fill9 = Style.fill(
		frame8,
		"Flare",
		Style.WHITE,
		UDim2.new(1, 0, 0, 0),
		UDim2.new(0.5, 0, 0, 207),
		Vector2.new(0.5, 0.5)
	)
	gradient(fill9, 90, {
		{ 0, 1 },
		{ 0.5, 0.15 },
		{ 1, 1 }
	})
	fill9.Visible = false

	local frame9 = Style.frame(frame8, "Ring", UDim2.fromOffset(0, 0), UDim2.new(0.5, 0, 0, 300), Vector2.new(0.5, 0.5))
	Style.corner(frame9, 999)
	local stroke = Style.stroke(frame9, 6, 1, Style.HAZARD)
	local v46 = {}

	for i = 1, 12 do
		local v47 = 5 + random:NextNumber() * 6
		local fill10 = Style.fill
		local v49 = if i % 3 == 0 then Style.WHITE else Style.HAZARD
		local frame10 = fill10(
			frame8,
			"Shard",
			v49,
			UDim2.fromOffset(v47, v47),
			UDim2.new(0.5, 0, 0, 300),
			Vector2.new(0.5, 0.5)
		)
		frame10.Visible = false
		frame10.Rotation = random:NextNumber() * 90
		v47 = random:NextNumber() * 2 * 3.141592653589793
		local v51 = 170 + random:NextNumber() * 150
		table.insert(v46, {
			frame = frame10,
			v = Vector2.new(math.cos(v47), math.sin(v47) - 0.45) * v51,
			spin = (random:NextNumber() * 2 - 1) * 540,
			r0 = frame10.Rotation
		})
	end

	local folder = Style.frame(
		frame8,
		"Mark",
		UDim2.fromOffset(150, 150),
		UDim2.new(0.5, 0, 0, 300),
		Vector2.new(0.5, 0.5)
	)
	folder.Visible = false
	local uiScale4 = Instance.new("UIScale")
	uiScale4.Parent = folder

	local box = Style.box(folder, "Diamond", Color3.new(1, 1, 1), UDim2.fromScale(0.72, 0.72), 4, 2.5)
	box.AnchorPoint = Vector2.new(0.5, 0.5)
	box.Position = UDim2.fromScale(0.5, 0.5)
	box.Rotation = 45
	local color5 = Color3.fromRGB(255, 250, 215)
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Offset = Vector2.new(-1, 0)
	uiGradient.Parent = box
	local v47 = nil
	local function markFace(color6: Color3)
		if color6 == v47 then
			return
		end

		v47 = color6
		uiGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, color6),
			ColorSequenceKeypoint.new(0.4, color6),
			ColorSequenceKeypoint.new(0.5, color5),
			ColorSequenceKeypoint.new(0.6, color6),
			ColorSequenceKeypoint.new(1, color6)
		})
	end
	markFace(Style.HAZARD)
	local box2 = Style.box(folder, "Inner", Style.INK, UDim2.fromScale(0.5, 0.5), 3, 1.5)
	box2.AnchorPoint = Vector2.new(0.5, 0.5)
	box2.Position = UDim2.fromScale(0.5, 0.5)
	box2.Rotation = 45
	parent2 = 40
	v16 = Style.FONT

	if touch then
		if parent2 <= 18 then
			parent2 = math.round(parent2 * 1.3)
		elseif parent2 <= 30 then
			parent2 = math.round(parent2 * 1.12)
		end
	end

	local label17 = Style.label(folder, "Number", "", parent2, v16, 2)

	label17.AutomaticSize = Enum.AutomaticSize.None
	label17.AnchorPoint = Vector2.new(0.5, 0.5)
	label17.Position = UDim2.fromScale(0.5, 0.5)
	label17.Size = UDim2.fromScale(1, 1)
	label17.TextXAlignment = Enum.TextXAlignment.Center
	label17.TextColor3 = Style.HAZARD
	local box3 = Style.box(folder, "Flash", Style.WHITE, UDim2.fromScale(0.72, 0.72), 4)
	box3.AnchorPoint = Vector2.new(0.5, 0.5)
	box3.Position = UDim2.fromScale(0.5, 0.5)
	box3.Rotation = 45
	local uiStrokes = {}

	for _, uiStroke in folder:GetDescendants() do
		if uiStroke:IsA("UIStroke") then
			table.insert(uiStrokes, uiStroke)
		end
	end

	local function markAlpha(p2: number) -- 1 equivalent call inferred from this helper
		box.BackgroundTransparency = p2
		box2.BackgroundTransparency = p2
		label17.TextTransparency = p2

		for _, v48 in uiStrokes do
			v48.Transparency = p2
		end
	end

	local frame10 = Style.frame(
		frame8,
		"Brackets",
		UDim2.fromOffset(212, 212),
		UDim2.new(0.5, 0, 0, 300),
		Vector2.new(0.5, 0.5)
	)
	local uiScale5 = Instance.new("UIScale")
	uiScale5.Parent = frame10
	local v48 = {}

	for _, v49 in { 0, 1 } do
		for _, v50 in { 0, 1 } do
			for _, v51 in { Vector2.new(24, 3), Vector2.new(3, 24) } do
				table.insert(
					v48,
					(Style.fill(
						frame10,
						"Corner",
						Style.WHITE,
						UDim2.fromOffset(v51.X, v51.Y),
						UDim2.fromScale(v49, v50),
						Vector2.new(v49, v50)
					))
				)
			end
		end
	end

	local function bracketAlpha(p2: number) -- 2 equivalent calls inferred from this helper
		for _, v49 in v48 do
			v49.BackgroundTransparency = p2 * 0.85 + 0.15
		end
	end

	bracketAlpha(1) -- inferred equivalent call
	local v49 = {}

	for i = 1, 5 do
		local fill10 = Style.fill
		local v51

		if i % 2 == 0 then
			v51 = Style.WHITE
		else
			v51 = Style.STEEL_LIGHT
		end

		local v52 = fill10(
			frame8,
			"Sliver",
			v51,
			UDim2.fromOffset(60, 3),
			UDim2.new(0.5, 0, 0, 80),
			Vector2.new(0.5, 0.5)
		)
		v52.BackgroundTransparency = 0.25
		v52.Visible = false
		table.insert(v49, v52)
	end

	local frame11 = Style.frame(frame8, "Title", UDim2.fromScale(1, 1))
	frame11.Visible = false
	parent2 = Style.box(frame11, "Chip", Style.HAZARD, UDim2.fromOffset(0, 26), 2, 1.5)
	parent2.AutomaticSize = Enum.AutomaticSize.X
	parent2.AnchorPoint = Vector2.new(0.5, 0)
	parent2.Position = UDim2.new(0.5, 0, 0, 40)
	v16 = Instance.new("UIPadding")
	v16.PaddingLeft = UDim.new(0, 10)
	v16.PaddingRight = UDim.new(0, 10)
	v16.Parent = parent2
	v16 = 18
	v17 = Style.FONT

	if touch then
		if v16 <= 18 then
			v16 = math.round(v16 * 1.3)
		elseif v16 <= 30 then
			v16 = math.round(v16 * 1.12)
		end
	end

	parent3 = Style.label(parent2, "Text", "LEVEL UP", v16, v17, 0)

	parent3.Size = UDim2.fromOffset(0, 26)
	parent3.TextColor3 = Style.INK
	parent2 = 72
	v16 = Style.FONT

	if touch then
		if parent2 <= 18 then
			parent2 = math.round(parent2 * 1.3)
		elseif parent2 <= 30 then
			parent2 = math.round(parent2 * 1.12)
		end
	end

	local label18 = Style.label(frame11, "Level", "", parent2, v16, 3)

	label18.AnchorPoint = Vector2.new(0.5, 0.5)
	label18.Position = UDim2.new(0.5, 0, 0, 118)
	local uiScale6 = Instance.new("UIScale")
	uiScale6.Parent = label18

	local fill10 = Style.fill(
		frame11,
		"RuleL",
		Style.WHITE,
		UDim2.fromOffset(0, 2),
		UDim2.new(0.5, -170, 0, 118),
		Vector2.new(1, 0.5)
	)
	local fill11 = Style.fill(
		frame11,
		"RuleR",
		Style.WHITE,
		UDim2.fromOffset(0, 2),
		UDim2.new(0.5, 170, 0, 118),
		Vector2.new(0, 0.5)
	)
	fill10.BackgroundTransparency = 0.35
	fill11.BackgroundTransparency = 0.35

	parent2 = 15
	v16 = Style.FONT

	if touch then
		if parent2 <= 18 then
			parent2 = math.round(parent2 * 1.3)
		elseif parent2 <= 30 then
			parent2 = math.round(parent2 * 1.12)
		end
	end

	local label19 = Style.label(frame11, "Unlock", "", parent2, v16, 1)

	label19.TextColor3 = Style.HAZARD
	label19.AnchorPoint = Vector2.new(0.5, 0.5)
	label19.Position = UDim2.new(0.5, 0, 0, 160)

	parent2 = 15
	v16 = Style.FONT

	if touch then
		if parent2 <= 18 then
			parent2 = math.round(parent2 * 1.3)
		elseif parent2 <= 30 then
			parent2 = math.round(parent2 * 1.12)
		end
	end

	local label20 = Style.label(frame11, "Unlock2", "", parent2, v16, 1)

	label20.TextColor3 = Style.HAZARD
	label20.AnchorPoint = Vector2.new(0.5, 0.5)
	label20.Position = UDim2.new(0.5, 0, 0, 170)
	parent2 = 15
	v16 = Style.FONT
	local v50 = label(frame11, "Unlock3", "", parent2, v16, 1) -- inferred equivalent call
	v50.TextColor3 = Style.HAZARD
	v50.AnchorPoint = Vector2.new(0.5, 0.5)
	v50.Position = UDim2.new(0.5, 0, 0, 190)
	local v51 = fader(frame11)

	local fill12 = Style.fill(layer3, "Black", Style.INK, UDim2.fromScale(1, 1))
	fill12.ZIndex = 10
	fill12.BackgroundTransparency = 1

	local v52 = nil
	local lastTime = -1e999
	progress.OnClientEvent:Connect(function(data)
		local v53 = type(data) == "table"
			and type(data.before) == "number"
			and type(data.after) == "number"
			and type(data.groups) == "table"
		assert(v53, "RoundEnd: bad summary from the server")

		v52 = data
		lastTime = os.clock()
	end)

	local flag = false
	local v53 = false
	local v54 = 0
	local v55 = -1
	local v56 = "Reds"
	local v57 = "Blues"
	local v58 = "Reds"
	local flag2 = false
	local childSet = {}
	local v59 = false
	local v60 = nil

	local set = {}
	local flag3 = false
	local v61 = 70
	local v62 = 0

	local v63 = -1e999
	local v64 = true
	local v65 = false
	local v66 = false
	local v67 = false
	local v68 = 0

	local function crossed(p2: number, p3: number): boolean
		return v63 < p3 and p3 <= p2 and p2 - p3 < 0.3
	end

	local function clockT() -- 3 equivalent calls inferred from this helper
		return workspace:GetServerTimeNow() - v54
	end

	local v69 = nil
	local v70 = PodiumCards.new(layer)
	local v71 = 0
	local flag4 = false

	local set2 = {}
	local v72 = {}

	local function makeTags()
		for _, v73 in v72 do
			v73.bb:Destroy()
			v73.att:Destroy()
		end

		table.clear(v72)
		table.clear(set2)

		if not v2 then
			return
		end

		for _, v73 in Hardpoint.POINTS do
			local attachment = Instance.new("Attachment")
			attachment.Name = "RoundEndPoint" .. v73.id
			attachment.Position = v73.marker
			attachment.Parent = workspace.Terrain
			local billboardGui = Instance.new("BillboardGui")
			billboardGui.Name = "RoundEndPoint" .. v73.id
			billboardGui.Adornee = attachment
			billboardGui.AlwaysOnTop = true
			billboardGui.LightInfluence = 0
			billboardGui.ResetOnSpawn = false
			billboardGui.Size = UDim2.fromOffset(34, 34)
			billboardGui.Enabled = false
			billboardGui.Parent = playerGui
			local fill13 = Style.fill(
				billboardGui,
				"Plate",
				Style.STEEL,
				UDim2.fromOffset(28, 28),
				UDim2.fromScale(0.5, 0.5),
				Vector2.new(0.5, 0.5)
			)
			Style.corner(fill13, 14)
			Style.stroke(fill13, 2, 0, Style.WHITE, true)
			local v74 = label(fill13, "Letter", v73.letter, 17, Style.FONT, 1.5) -- inferred equivalent call
			v74.AutomaticSize = Enum.AutomaticSize.None
			v74.Size = UDim2.fromScale(1, 1)
			set2[billboardGui] = true
			table.insert(v72, { bb = billboardGui, plate = fill13, att = attachment })
		end
	end
	makeTags()
	MapSelect.onChange(function()
		label5.Text = string.upper(MapSelect.name)
		label4.Text = text
		makeTags()
	end, 21)
	local v73 = false
	local function showTags(enabled: boolean) -- 1 equivalent call inferred from this helper
		if enabled ~= v73 then
			v73 = enabled

			for _, v74 in v72 do
				v74.bb.Enabled = enabled
			end
		end
	end

	local function hideHud()
		for _, child in playerGui:GetChildren() do
			if child == layer or child == layer2 or child == layer3 or set2[child] then
				continue
			end

			if
				not (child:IsA("ScreenGui") or child:IsA("BillboardGui"))
				or not child.Enabled
				or string.find(child.Name, "Cmdr")
			then
				continue
			end

			childSet[child] = true
			child.Enabled = false
		end
	end
	local function showHud() -- 1 equivalent call inferred from this helper
		for k in childSet do
			if k.Parent then
				k.Enabled = true
			end
		end

		table.clear(childSet)
	end

	local function cameraAt(p2: number)
		local v74 = math.clamp((p2 - v4) / (Hardpoint.INTERMISSION - v4), 0, 1)
		local v75 = v62 + 0.03 * (p2 - v4)
		local v76 = v8 + (v9 - v8) * Style.smooth(v74)
		local v77 = v10 + (v11 - v10) * v74
		local center = Hardpoint.CENTER
		local v78 = center + Vector3.new(math.sin(v75) * v76, v77, math.cos(v75) * v76)
		return CFrame.lookAt(v78, center)
	end

	local function holdCamera() -- 1 equivalent call inferred from this helper
		if flag3 then
			return
		end

		flag3 = true
		v61 = workspace.CurrentCamera.FieldOfView
		RunService:BindToRenderStep("RoundEndCamera", Enum.RenderPriority.Camera.Value + 20, function()
			local currentCamera = workspace.CurrentCamera
			currentCamera.CameraType = Enum.CameraType.Scriptable
			local v74 = clockT() -- inferred equivalent call

			if v69 and v74 < v4 then
				local camera, fieldOfView = Podium.camera(v69, (math.max(0, v74 - 4.3)))
				currentCamera.FieldOfView = fieldOfView
				currentCamera.CFrame = camera
			else
				currentCamera.FieldOfView = 50
				currentCamera.CFrame = cameraAt(v74)
			end
		end)
	end
	local function releaseCamera()
		if not flag3 then
			return
		end

		flag3 = false
		RunService:UnbindFromRenderStep("RoundEndCamera")
		local currentCamera = workspace.CurrentCamera

		local voxel = ReplicatedStorage:WaitForChild("Voxel")
		local Movement = require(voxel:WaitForChild("Movement"))
		local Viewmodel = require(voxel:WaitForChild("Viewmodel"))
		currentCamera.FieldOfView = Movement.FIELD_OF_VIEW

		if Viewmodel.current == nil then
			Movement.weaponScale = 1
			Movement.blockSprint = false
			Movement.weaponFov = false
		end

		currentCamera.CameraType = Enum.CameraType.Custom
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			currentCamera.CameraSubject = humanoid
		end
	end

	local function blackAt(p2: number)
		if p2 < 3.6 then
			return 1
		end

		if p2 < 4.1 then
			return 1 - (p2 - 3.6) / 0.5
		end

		if p2 < 4.3 then
			return 0
		end

		if p2 < 4.7 then
			return (p2 - 4.3) / 0.4
		end

		if p2 < v3 then
			return 1
		end

		if p2 < v3 + 0.3 then
			return 1 - (p2 - v3) / 0.3
		end

		if p2 < v4 then
			return 0
		end

		if p2 < v4 + 0.4 then
			return (p2 - v4) / 0.4
		end

		if p2 < v5 then
			return 1
		end

		if p2 < v5 + 0.3 then
			return 1 - (p2 - v5) / 0.3
		end

		if p2 < v6 then
			return 0
		end

		if p2 < v6 + 0.4 then
			return (p2 - v6) / 0.4
		end

		if p2 < v7 then
			return 1
		end

		return 1 - math.clamp((p2 - v7) / 0.4, 0, 1)
	end

	local function setRowAlpha(row, alpha: number) -- 2 equivalent calls inferred from this helper
		row.alpha = alpha
		row.fade(alpha)
		row.plate.BackgroundTransparency = row.plateRest + (1 - row.plateRest) * alpha
	end

	local function fillBoard(p2: number)
		v59 = true
		v68 = 0
		local v74 = { 0, 0 }

		for _, v75 in Leaderboard.collect(player) do
			local v76 = v75.team == v56 and 1 or 2
			local v77 = v74[v76] + 1
			v74[v76] = v77
			local row = v22[v76].rows[v77]

			if not row then
				continue
			end

			local cells = row.cells
			cells.rank.Text = tostring(v77)
			local rank = cells.rank
			local textColor

			if v77 == 1 then
				textColor = Style.HAZARD
			else
				textColor = Style.DIM
			end

			rank.TextColor3 = textColor
			cells.level.Text = not (v75.level and v75.level > 0) and "" or tostring(v75.level)
			local name = cells.name
			local text2

			if v75.me then
				text2 = v75.name .. "  (YOU)"
			else
				text2 = v75.name
			end

			name.Text = text2
			local name2 = cells.name
			local textColor2

			if v75.me then
				textColor2 = Style.HAZARD
			elseif v75.bot then
				textColor2 = Style.MUTED
			else
				textColor2 = Style.WHITE
			end

			name2.TextColor3 = textColor2
			local name3 = cells.name
			local fontFace

			if v75.me then
				fontFace = Style.FONT
			else
				fontFace = Style.FONT_BODY
			end

			name3.FontFace = fontFace
			row.bot.Visible = v75.bot
			row.namePad.PaddingLeft = UDim.new(0, not v75.bot and 0 or Leaderboard.BOT_ICON + Leaderboard.BOT_GAP)

			local plate2 = row.plate
			local backgroundColor

			if v75.me then
				backgroundColor = Style.PANEL:Lerp(Style.HAZARD, 0.22)
			else
				backgroundColor = Style.PANEL
			end

			plate2.BackgroundColor3 = backgroundColor
			row.plateRest = v75.me and 0 or row.plateAlpha

			for _, v83 in { "kills", "deaths", "assists" } do
				cells[v83].TextColor3 = Style.WHITE
			end

			local rank2 = cells.rank
			local textColor3

			if v77 == 1 or v75.me then
				textColor3 = Style.HAZARD
			else
				textColor3 = Style.DIM
			end

			rank2.TextColor3 = textColor3
			cells.kills.Text = tostring(v75.kills)
			cells.deaths.Text = tostring(v75.deaths)
			cells.assists.Text = tostring(v75.assists)
			cells.score.Text = "0"
			row.edge.Visible = v75.me
			row.score = v75.score
			row.shown = -1

			row.at = math.max(p2, v4 + 0.4) + 0.15 + (v77 - 1) * 0.06
			row.group.Visible = true
			setRowAlpha(row, 1) -- inferred equivalent call
		end

		local v75 = math.max(v74[1], v74[2])
		local v76 = v75 > 12 and 20 or 24
		v21(not (v75 > 12) and 1 or vector2.Y / (v75 * v76 + 80))

		for i = 1, 2 do
			for k, row in v22[i].rows do
				row.group.Size = UDim2.fromOffset(total, v76 - 2)
				row.group.Position = UDim2.fromOffset(0, 80 + (k - 1) * v76)
			end

			for j = v74[i] + 1, 16 do
				v22[i].rows[j].group.Visible = false
			end
		end
	end

	local function animateBoard(p2: number)
		for _, v74 in v22 do
			for _, row in v74.rows do
				if not row.group.Visible then
					continue
				end

				local v75 = math.clamp((p2 - row.at) / 0.25, 0, 1)

				if v75 < 1 or row.alpha > 0 then
					setRowAlpha(row, 1 - v75) -- inferred equivalent call
					row.group.Position = UDim2.new(
						0,
						-14 * (1 - Style.easeOut(v75)),
						row.group.Position.Y.Scale,
						row.group.Position.Y.Offset
					)
				end

				local shown = math.floor(row.score * Style.easeOut((p2 - row.at) / 0.8))

				if shown == row.shown then
					continue
				end

				row.shown = shown
				row.cells.score.Text = Style.thousands(shown)
			end
		end

		local maxValue = 0

		for _, v74 in v22 do
			for k, row in v74.rows do
				if row.group.Visible and row.at <= p2 then
					maxValue = math.max(maxValue, k)
				end
			end
		end

		if v68 < maxValue then
			local v74 = false

			for i = v68 + 1, maxValue do
				v74 = v74 or i % 2 == 1
			end

			v68 = maxValue

			if v74 then
				RoundEndAudio.rowTick()
			end
		end
	end

	local views = {}
	local v74 = {}
	local v75 = 0
	local set3 = {}

	local function cue(p2: string, p3: number, p4: number, callback) -- 11 equivalent calls inferred from this helper
		if p4 <= p3 and not set3[p2] then
			set3[p2] = true

			if p3 - p4 < 0.3 then
				callback()
			end
		end
	end
	local function bump(p2: number) -- 1 equivalent call inferred from this helper
		if p2 <= 0 or p2 >= 1 then
			return 0
		end

		return (math.sin(3.141592653589793 * p2))
	end

	local v76 = 0
	local v77 = -1

	local function startLevel()
		local v78 = v52

		if not v78 or os.clock() - lastTime > Hardpoint.INTERMISSION + 5 then
			local v80 = Progression.startOf((math.max(1, num(player:GetAttribute("Level"))))) + num(player:GetAttribute("XP")) -- inferred equivalent call
			v78 = { before = v80, after = v80, groups = {} }
		end

		local v79 = plan(v78, v7 - v6 - 3.6 - 0.3)
		v60 = v79
		table.clear(set3)
		table.clear(set)
		v76 = 0
		v77 = -1
		tintSeg(v28, 0) -- inferred equivalent call
		tintSeg(v29, 0) -- inferred equivalent call
		fill6.BackgroundColor3 = Style.WHITE

		for _, v80 in views do
			v80.destroy()
		end

		table.clear(views)
		table.clear(v74)
		local level = Progression.levelOf(v79.before)
		local level2 = Progression.levelOf(v79.after)
		local clone = table.clone(Skins.LIST)
		table.sort(clone, function(a, b): boolean
			return a.level < b.level
		end)

		local v80 = {}
		local v81 = {}
		local function consider(p2)
			if level < p2.level and p2.level <= level2 then
				table.insert(v80, p2)
			elseif level2 < p2.level then
				table.insert(v81, p2)
			end
		end

		for _, skin in clone do
			if skin.paid or skin.pack then
				continue
			end

			local v83 = { name = skin.name, level = skin.level, skin = skin }

			if level < v83.level and v83.level <= level2 then
				table.insert(v80, v83)
			elseif level2 < v83.level then
				table.insert(v81, v83)
			end

			if not (level < skin.level and skin.level <= level2) then
				continue
			end

			local v84 = string.upper(skin.name)
			local level3 = skin.level

			if v74[skin.level] then
				v84 = v74[skin.level] .. ", " .. v84
			end

			v74[level3] = v84
		end

		for k, level3 in VehicleConfig.DRIVE_LEVEL do
			local icon = (k == "Tank" or k == "Bradley") and "tank" or k == "Heli" and "heli" or nil
			assert(icon, "RoundEnd: no unlock picture for vehicle " .. tostring(k))
			local v84 = { name = VehicleConfig.DRIVE_NAMES[k], level = level3, icon = icon }

			if level < v84.level and v84.level <= level2 then
				table.insert(v80, v84)
			elseif level2 < v84.level then
				table.insert(v81, v84)
			end
		end

		for k, v82 in ShopData.ITEMS do
			if
				not v82.level
				or (v82.retired or v82.hidden)
				or not (not ShopData.owns(player, k) or level < v82.level and v82.level <= level2)
			then
				continue
			end

			local v83 = {
				name = names[k] or k,
				level = v82.level,
				weapon = k
			}

			if level < v83.level and v83.level <= level2 then
				table.insert(v80, v83)
			elseif level2 < v83.level then
				table.insert(v81, v83)
			end
		end

		local function rank(p2): number -- 4 equivalent calls inferred from this helper
			if p2.icon then
				return 0
			end

			return if p2.weapon then 1 else 2
		end

		local function order(p2, p3): boolean
			if p2.level ~= p3.level then
				return p2.level < p3.level
			end

			if rank(p2) == rank(p3) then -- inferred equivalent call
				return p2.name < p3.name
			end

			return rank(p2) < rank(p3) -- inferred equivalent call
		end

		table.sort(v80, order)
		table.sort(v81, order)
		local locked = #v80 == 0
		local v83

		if locked then
			v83 = {}
			local v84 = false

			for _, v85 in v81 do
				if v85.level ~= v81[1].level then
					continue
				end

				table.insert(v83, v85)
				v84 = v84 or v85.weapon ~= nil
			end

			local level3 = nil

			for _, v85 in v81 do
				if v84 or not v85.weapon or not (level3 == nil or v85.level == level3) then
					continue
				end

				level3 = v85.level
				table.insert(v83, v85)
			end
		else
			v83 = v80
		end

		v75 = math.min(#v83, 4)
		local body2 = SkinPreview.body(player)

		v41 = nil
		view.show(nil)

		if body2 then
			local v84 = Skins.get(Skins.pick(player))
			local dress = SkinPreview.dress(body2, v84, v56, player.UserId)
			v39 = dress:GetPivot()
			view.show(dress)
			v41 = dress
			label15.Text = string.upper(player.DisplayName)
			label16.Text = string.upper(v84.name)
		end

		for k, v84 in v37 do
			v84.root.Visible = false

			for _, child in v84.pic:GetChildren() do
				child:Destroy()
			end

			local v85 = v83[k]
			local skin = v85 and v85.skin

			if not (v85 and k <= v75) then
				continue
			end

			v84.locked = locked
			v84.tape.Visible = not locked
			v84.name.Text = string.upper(v85.name)
			local name = v84.name
			local textColor

			if locked then
				textColor = Style.MUTED
			else
				textColor = Style.WHITE
			end

			name.TextColor3 = textColor
			v84.sub.Text = (locked and "NEXT  ·  LEVEL " or v85.icon and "VEHICLE  ·  LEVEL " or v85.weapon and "WEAPON  ·  LEVEL " or "OUTFIT  ·  LEVEL ") .. v85.level
			local tool

			if v85.weapon then
				local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
				tool = ReplicatedStorage2:WaitForChild("ToolTemplates"):FindFirstChild(v85.weapon)
			end

			assert(
				not v85.weapon or tool and tool:IsA("Tool"),
				"RoundEnd: no Tool for unlock weapon " .. tostring(v85.weapon)
			)

			if tool then
				local frame12 = Style.frame(
					v84.pic,
					"Weapon",
					UDim2.new(1, -16, 1, -8),
					UDim2.fromScale(0.5, 0.5),
					Vector2.new(0.5, 0.5)
				)
				local voxel = ToolIcon.voxel
				local v87

				if locked then
					v87 = Color3.fromRGB(80, 82, 88)
				else
					v87 = Style.WHITE
				end

				voxel(tool, frame12, v87)
			elseif v85.icon then
				local v87 = drawIcon(
					Style.frame(
						v84.pic,
						"Vehicle",
						UDim2.fromOffset(92, 62),
						UDim2.fromScale(0.5, 0.5),
						Vector2.new(0.5, 0.5)
					),
					v85.icon
				)
				local v88

				if locked then
					v88 = Color3.fromRGB(80, 82, 88)
				else
					v88 = Style.WHITE
				end

				v87(v88)
			elseif body2 then
				local view2 = SkinPreview.view(v84.pic, "bust")
				view2.frame.Active = false
				view2.show(SkinPreview.dress(body2, skin, v56, player.UserId))

				if locked then
					view2.frame.ImageColor3 = Color3.fromRGB(80, 82, 88)
				end

				table.insert(views, view2)
			else
				local v87 = label(v84.pic, "Letter", string.upper((string.sub(skin.name, 1, 1))), 40, Style.FONT, 2) -- inferred equivalent call
				v87.AnchorPoint = Vector2.new(0.5, 0.5)
				v87.Position = UDim2.fromScale(0.5, 0.5)
			end

			if not locked then
				continue
			end

			local frame12 = Style.frame(
				v84.pic,
				"Lock",
				UDim2.fromOffset(26, 26),
				UDim2.new(1, -4, 0, 4),
				Vector2.new(1, 0)
			)
			frame12.ZIndex = 4
			local lock2 = v24.lock

			if not lock2 then
				local lock = v13.lock
				assert(lock, "RoundEnd: no award picture " .. tostring("lock"))
				lock2 = ToolIcon.artFrom(lock)
				v24.lock = lock2
			end

			local _, v88 = ToolIcon.draw(lock2, frame12, Style.WHITE)

			v88(Style.WHITE)
		end

		label13.Text = not (#v83 > 4) and "" or "+" .. #v83 - 4 .. " MORE"
		label14.Text = #v83 == 0 and "EVERYTHING UNLOCKED" or ""

		for _, v84 in v36 do
			v84.final = num(player:GetAttribute(v84.attr)) -- inferred equivalent call
			local value = v84.value
			local width = v84.width
			local v85 = #tostring(0)
			value.Text = Style.paint(string.rep("0", (math.max(0, width - v85))), Style.DIM) .. Style.paint(Style.thousands(0), Style.WHITE)
			v84.group.slot.Visible = false
		end

		setIcon(plate, v79.groups[1] and iconsByLabel[v79.groups[1].label] or "stack")
		label9.Text = ""
		label10.Text = ""
		frame8.Visible = false
		frame6.Visible = false
		frame7.Visible = false
	end

	local function animateLevel(p2: number)
		local v78 = v60
		local v79 = totalAt(v78, p2)
		local level, v80, v81 = Progression.levelOf(v79)
		local v82 = Progression.startOf(level)
		v26.number.Text = tostring(level)
		v27.number.Text = not (v81 > 0) and "MAX" or tostring(level + 1)

		local function frac(p3: number) -- 3 equivalent calls inferred from this helper
			if v81 > 0 then
				return (math.clamp((p3 - v82) / v81, 0, 1))
			end

			return 1
		end

		local v83 = frac(v79) -- inferred equivalent call
		local v84 = math.min(frac(v78.before), v83) -- inferred equivalent call
		local v85

		if v78.bonusFrom and v78.bonusFrom < v79 then
			v85 = math.clamp(frac(v78.bonusFrom), v84, v83) -- inferred equivalent call
		else
			v85 = v83
		end

		local v86 = false

		for _, fill13 in v78.fills do
			if fill13.t0 <= p2 and p2 < fill13.t1 then
				v76 = p2 * 42 % 14
				v86 = true
				break
			end
		end

		local v88 = not (v78.after > v78.before) and 0
			or math.clamp((v79 - v78.before) / (v78.after - v78.before), 0, 1)
		RoundEndAudio.fill(v86, v88)
		fill6.Size = UDim2.fromScale(v84, 1)
		placeSeg(v28, v84, v85, v76)
		placeSeg(v29, v85, v83, v76)
		fill7.Position = UDim2.fromOffset(v83 * 760 + 120, 164)
		label12.Text = not (v81 > 0) and "MAX LEVEL" or Style.thousands(v80) .. " / " .. Style.thousands(v81)
		label11.Text = zeros(v79 - v78.before, 7) -- inferred equivalent call

		local v89 = math.clamp((p2 - 0.3) / 0.3, 0, 1)
		local easeOut = Style.easeOut(v89)

		for _, v90 in v25 do
			v90.Visible = p2 >= 0.3
		end

		fill5.Size = UDim2.fromOffset(760 * easeOut, 18)
		v26.fade(1 - v89)
		v27.fade(1 - v89)
		v26.frame.Position = UDim2.fromOffset(v26.x - 30 * (1 - easeOut), 101)
		v27.frame.Position = UDim2.fromOffset(v27.x + 30 * (1 - easeOut), 101)
		v30(1 - math.clamp((p2 - 0.45) / 0.25, 0, 1))
		label12.Visible = p2 >= 0.6
		local v90 = 0

		for k, pop in v78.pops do
			if pop <= p2 then
				v90 = k
			end
		end

		local v91

		if v90 > 0 then
			v91 = v78.groups[v90]
		end

		local v92 = 0

		if v91 then
			for k, v93 in v78.partAt[v90] do
				if v93 <= p2 then
					v92 = k
				end
			end
		end

		local v93

		if v91 == nil then
			v93 = false
		else
			v93 = #v91.parts > 1
		end

		local v94

		if #v78.groups > 0 then
			v94 = v78.done <= p2
		else
			v94 = false
		end

		local v95 = plate.id
		local v96 = 1e999
		local v97 = 1e999

		if v94 then
			v96 = v78.done
			v97 = v78.done
			v95 = "stack"
		elseif v91 then
			if v93 and v92 >= 1 then
				v95 = reasonIcon(v91.parts[v92].reason, v91.label) -- inferred equivalent call
			else
				v95 = iconsByLabel[v91.label] or "stack"
			end

			if v93 and v92 >= 1 then
				v96 = v78.partAt[v90][v92]
			else
				v96 = v78.pops[v90]
			end

			v97 = v78.partAt[v90][math.max(v92, 1)]
		end

		setIcon(plate, v95)
		plate.frame.Visible = p2 >= 0.05
		plate.holder.Visible = p2 >= 0.3
		local v98 = 0.15 + 0.85 * Style.easeOut((math.clamp((p2 - 0.05) / 0.3, 0, 1)))
		local scale = not (v96 <= p2) and 1 or 1 + 0.22 * (1 - Style.easeOut((math.clamp((p2 - v96) / 0.2, 0, 1))))
		plate.scale.Scale = v98 * scale
		local v100 = if v97 <= p2 then Style.WHITE else Style.DIM
		paintPlate(plate, v100) -- inferred equivalent call
		local v101 = math.clamp((p2 - 0.2) / 0.25, 0, 1) * 0.7 + 0.3
		local v102 = not (v97 <= p2) and 1 or math.clamp((p2 - v97) / 0.22, 0, 1) * 0.65 + 0.35
		plate.flash.BackgroundTransparency = math.min(v101, v102)
		uiScale2.Scale = scale

		if v94 then
			label9.Text = "+" .. Style.thousands(v78.after - v78.before)
			label10.Text = Style.paint("ROUND TOTAL", Style.MUTED)
		elseif v91 then
			label9.Text = "+" .. Style.thousands((math.floor((math.clamp(v79 - v78.groupFrom[v90], 0, v91.xp)))))
			local v103

			if v93 then
				if v92 >= 1 then
					v103 = v91.parts[v92]
				end
			else
				v103 = v91.parts[1]
			end

			local v104 = ""

			if v103 and v103.reason ~= "" then
				local v105 = Progression.REASONS[v103.reason]
				local v106

				if v105 then
					v106 = v105.label
				else
					v106 = v103.reason
				end

				if v93 or v106 ~= v91.label then
					v104 = v106 .. (not (v105 and v105.counted and v103.count > 1) and "" or "  x" .. v103.count)
				end
			end

			label10.Text = Style.paint(v91.label, Style.MUTED) .. (v104 == "" and "" or Style.paint("   ·   ", Style.DIM) .. Style.paint(v104, Style.WHITE))
		elseif #v78.groups == 0 and p2 >= 0.75 then
			label9.Text = ""
			label10.Text = Style.paint("NO XP THIS ROUND", Style.MUTED)
		end

		local v103 = k

		local function fn()
			RoundEndAudio.pop(v103, #v78.pops)
		end

		local function fn2()
			RoundEndAudio.part(v88)
		end

		for k, pop in v78.pops do
			cue("pop" .. k, p2, pop, fn) -- inferred equivalent call

			if not (#v78.groups[k].parts > 1) then
				continue
			end

			for k2, v104 in v78.partAt[k] do
				cue("part" .. k .. ":" .. k2, p2, v104, fn2) -- inferred equivalent call
			end

			cue("end" .. k, p2, v78.groupEnd[k], RoundEndAudio.groupEnd) -- inferred equivalent call
		end

		if #v78.groups > 0 then
			cue("total", p2, v78.done, RoundEndAudio.done) -- inferred equivalent call
		end

		local function fn3()
			RoundEndAudio.tick(1, v88)
		end

		for k, fill13 in v78.fills do
			for i = 1, math.max(1, (math.floor((fill13.t1 - fill13.t0) / 0.08))) do
				cue("fill" .. k .. ":" .. i, p2, fill13.t0 + (i - 0.5) * 0.08, fn3) -- inferred equivalent call
			end
		end

		local v104

		if v91 and v93 then
			if v92 >= 1 then
				v104 = v78.partAt[v90][v92]
			else
				v104 = v78.pops[v90]
			end
		else
			v104 = 0
		end

		for k, v105 in plates do
			local v106

			if v91 and v93 and not v94 then
				v106 = v91.parts[v92 + k]
			end

			v105.frame.Visible = v106 ~= nil

			if not (v91 and v106) then
				continue
			end

			local easeOut2 = Style.easeOut((math.clamp((p2 - v104) / (v92 >= 1 and 0.15 or 0.25), 0, 1)))
			local v107 = k - 1 + (v92 >= 1 and 1 or 3) * (1 - easeOut2)
			v105.frame.Position = UDim2.fromOffset(589 + v107 * 54, 40)
			setIcon(v105, reasonIcon(v106.reason, v91.label)) -- inferred equivalent call
			local v108 = math.clamp(v107 / 7.5, 0, 1)
			v105.frame.BackgroundTransparency = v108 * 0.7 + 0.2
			paintPlate(v105, Style.MUTED:Lerp(Style.STEEL, v108)) -- inferred equivalent call
		end

		local v105 = math.floor(p2 * 30)
		local v106 = false
		local v107 = 0

		for k, beat in v78.beats do
			local v108 = beat.t1 - beat.t0
			local v109 = beat.t0 + v108 * 0.5 / 2.6
			cue("glitch" .. k, p2, beat.t0 + 0.06, RoundEndAudio.glitch) -- inferred equivalent call
			cue("sweep" .. k, p2, v109 - RoundEndAudio.SWEEP_LEAD, RoundEndAudio.sweep) -- inferred equivalent call

			if not (beat.t0 <= p2 and p2 < beat.t1) then
				continue
			end

			v106 = true
			local v110 = p2 - beat.t0
			local v111 = p2 - v109

			if not set[k] then
				set[k] = true
				label18.Text = "LEVEL " .. beat.level
				label17.Text = tostring(beat.level)
				label17.TextSize = beat.level >= 100 and 32 or 40

				local v112 = {}

				if v74[beat.level] then
					table.insert(v112, "OUTFIT UNLOCKED  ·  " .. v74[beat.level])
				end

				for k2, v113 in VehicleConfig.DRIVE_LEVEL do
					if v113 == beat.level then
						table.insert(v112, VehicleConfig.DRIVE_NAMES[k2] .. " UNLOCKED")
					end
				end

				local v113 = {}

				for k2, v114 in ShopData.ITEMS do
					if v114.level ~= beat.level or (v114.retired or v114.hidden) then
						continue
					end

					table.insert(v113, string.upper(names[k2] or k2))
				end

				table.sort(v113)

				if #v113 > 0 then
					table.insert(
						v112,
						(#v113 == 1 and "WEAPON UNLOCKED  ·  " or "WEAPONS UNLOCKED  ·  ") .. table.concat(v113, ", ")
					)
				end

				label19.Text = v112[1] or ""
				label20.Text = v112[2] or ""
				v50.Text = v112[3] or ""
				label19.Position = UDim2.new(0.5, 0, 0, 427)
				label20.Position = UDim2.new(0.5, 0, 0, 447)
				v50.Position = UDim2.new(0.5, 0, 0, 467)
			end

			cue("level" .. k, p2, v109, RoundEndAudio.levelUp) -- inferred equivalent call
			local v112 = math.clamp((v110 - (v108 - 0.3)) / 0.25, 0, 1)

			local v113 = v110 - 0.05
			frame7.Visible = v113 > 0 and v113 < 0.22

			if frame7.Visible then
				local easeIn = Style.easeIn((math.clamp((v113 - 0.08) / 0.14, 0, 1)))
				local v115 = 760 * (0.7 + 0.3 * Style.easeOut((math.clamp(v113 / 0.05, 0, 1)))) * (1 - 0.85 * easeIn)
				frame7.Size = UDim2.fromOffset(v115, 26 * (1 - 0.5 * easeIn))
				local v116 = 6 * (1 - easeIn)
				v42.Position = UDim2.new(0.5, -v116, 0.5, 0)
				v43.Position = UDim2.new(0.5, v116, 0.5, 0)
				v44.BackgroundTransparency = 0.1 + 0.9 * easeIn
				v42.BackgroundTransparency = 0.35 + 0.65 * easeIn
				v43.BackgroundTransparency = 0.35 + 0.65 * easeIn
			end

			frame6.Visible = true
			local v115 = math.clamp((v110 - 0.12) / math.max(0.05, v109 - beat.t0 - 0.12), 0, 1)
			local v116 = 1 - 0.8 * Style.easeIn(v115)
			local v117 = v115 * 0.4 + 0.35

			for k2, v118 in v40 do
				local v119 = v110 > 0.12
					and v111 < 0.04
					and math.abs(v118.u) <= v116
					and (k2 * 7919 + v105 * 104729) % 97 / 97 < v117
					and 1
					or 0

				local v120 = math.max(v119, bump((v110 - (v108 - 0.34) - v118.d * 0.14) / 0.2)) -- inferred equivalent call
				v118.f.BackgroundTransparency = 1 - v120 * 0.8
			end

			local v118 = v110 - 0.1
			frame8.Visible = v118 > 0

			if v118 > 0 then
				v45((math.max(1 - math.clamp(v118 / 0.15, 0, 1), v112)))
			end

			local v119 = (v111 + 0.06) / 0.3
			fill9.Visible = v119 > 0 and v119 < 1

			if fill9.Visible then
				fill9.Size = UDim2.new(1, 0, 0, math.sin(3.141592653589793 * v119) * 90 + 4)
				fill9.BackgroundTransparency = math.clamp((v119 - 0.35) / 0.65, 0, 1) * 0.85 + 0.15
			end

			folder.Visible = v111 >= 0
			frame9.Visible = v111 >= 0 and v111 < 0.4
			frame10.Visible = v111 >= 0

			if v111 >= 0 then
				uiScale4.Scale = (1.22 - 0.22 * Style.easeOut((math.clamp(v111 / 0.14, 0, 1)))) * (1 - 0.12 * Style.easeIn(v112))
				markAlpha(v112) -- inferred equivalent call
				box3.BackgroundTransparency = math.max(math.clamp(v111 / 0.22, 0, 1), v112)
				markFace(Style.WHITE:Lerp(Style.HAZARD, (math.clamp(v111 / 0.25, 0, 1))))
				uiGradient.Offset = Vector2.new(math.clamp((v111 - 0.1) / 0.45, 0, 1) * 2 + -1, 0)
				local v122 = math.clamp((v111 - 0.04) / 0.16, 0, 1)
				uiScale5.Scale = 1.3 - 0.3 * Style.easeOut(v122)
				bracketAlpha(math.max(1 - v122, v112)) -- inferred equivalent call
				local transparency = math.clamp(v111 / 0.4, 0, 1)
				local v124 = 260 * Style.easeOut(transparency)
				frame9.Size = UDim2.fromOffset(v124, v124)
				stroke.Thickness = math.max(1, (1 - transparency) * 6)
				stroke.Transparency = transparency
			end

			for _, v122 in v46 do
				local frame12 = v122.frame
				frame12.Visible = v111 >= 0 and v111 < 0.6

				if not v122.frame.Visible then
					continue
				end

				local v124 = v122.v * v111 + Vector2.new(0, v111 * 420 * v111)
				v122.frame.Position = UDim2.new(0.5, v124.X, 0, 300 + v124.Y)
				v122.frame.Rotation = v122.r0 + v122.spin * v111
				v122.frame.BackgroundTransparency = math.clamp((v111 - 0.25) / 0.35, 0, 1)
			end

			local v122 = math.clamp((v111 - 0.12) / 0.2, 0, 1)
			frame11.Visible = v122 > 0

			if v122 > 0 then
				v51((math.max(1 - v122, v112)))
				uiScale6.Scale = 1 + 0.25 * (1 - Style.easeOut(v122))
				local v123 = 170 * Style.easeOut((math.clamp((v111 - 0.15) / 0.3, 0, 1)))
				fill10.Size = UDim2.fromOffset(v123, 2)
				fill11.Size = UDim2.fromOffset(v123, 2)
			end

			local v123

			if v111 > 0.1 and v111 < 0.4 then
				v123 = true
			elseif v112 > 0 then
				v123 = v112 < 0.6
			else
				v123 = false
			end

			for k2, v124 in v49 do
				local v125 = (k2 * 7349 + v105 * 30011) % 101 / 101
				v124.Visible = v123 and v125 < 0.6

				if not v124.Visible then
					continue
				end

				local v126 = (k2 * 1543 + v105 * 7907) % 89 / 89
				v124.Size = UDim2.fromOffset(v126 * 150 + 30, 3)
				v124.Position = UDim2.new(0.5, (v125 - 0.3) * 900, 0, v126 * 110 + 40)
			end

			v107 = math.min(math.clamp(v110 / 0.15, 0, 1), (math.clamp((v108 - v110) / 0.3, 0, 1)))

			local v124 = (v110 - (v108 - 0.3)) / 0.3
			v26.pop.Scale = not (v124 > 0) and 1 or 1 + 0.3 * (1 - Style.easeOut((math.min(v124, 1))))
		end

		if not v106 and (frame8.Visible or frame6.Visible) then
			frame8.Visible = false
			frame6.Visible = false
			frame7.Visible = false
			v26.pop.Scale = 1
		end

		local v108 = p2 - v78.done
		local smoothed = Style.smooth((math.clamp((v108 - 0.5) / 0.45, 0, 1)))
		v23.slot.Position = UDim2.fromOffset(0, 120 + -120 * smoothed)
		local function showHead(p3, p4: number) -- 2 equivalent calls inferred from this helper
			p3.fade(1 - math.clamp((v108 - p4) / 0.2, 0, 1))
			p3.rule.Size = UDim2.fromOffset(880 * Style.easeOut((math.clamp((v108 - p4) / 0.4, 0, 1))), 1)
		end

		showHead(v31, 0.8) -- inferred equivalent call
		local v109 = i

		local function fn4()
			RoundEndAudio.tick(0.55, (v109 - 1) * 0.75 / 5 + 0.25)
		end

		for k, v110 in v36 do
			local v111 = (k - 1) * 0.25 + 1
			local v112 = math.clamp((v108 - v111) / 0.25, 0, 1)
			v110.group.slot.Visible = v112 > 0

			if v112 > 0 then
				v110.group.set(1 - v112)
				v110.group.slot.Position = UDim2.fromOffset(v110.x, 260 + 12 * (1 - Style.easeOut(v112)))
				local easeOut2 = Style.easeOut((math.clamp((v108 - v111) / 0.6, 0, 1)))
				v110.value.Text = zeros(math.floor(v110.final * easeOut2), v110.width)
				v110.fill.Size = UDim2.fromScale(easeOut2, 1)
			end

			if v110.final > 0 then
				for i = 1, 6 do
					cue("tileTick" .. k .. ":" .. i, p2, v78.done + v111 + (i - 0.5) * 0.09, fn4) -- inferred equivalent call
				end
			end

			cue("tile" .. k, p2, v78.done + v111 + 0.6, RoundEndAudio.tileLand) -- inferred equivalent call
		end

		showHead(v32, 2.1) -- inferred equivalent call
		local v110 = not (v75 > 1) and 0.6 or math.min(0.6, 1 / (v75 - 1))
		local v111 = k
		local v112 = v113

		local function fn5()
			RoundEndAudio.card(v111, v112.locked)
		end

		for k, v113 in v37 do
			if not (k <= v75) then
				continue
			end

			local v114 = v110 * (k - 1) + 2.35
			local v115 = v108 - v114
			v113.root.Visible = v115 >= 0

			if v115 >= 0 then
				v113.scale.Scale = 1 + 0.28 * (1 - Style.easeOut((math.clamp(v115 / 0.18, 0, 1))))
				local v116 = v113.locked and 0.6 or 0.2
				v113.flash.BackgroundTransparency = v116 + (1 - v116) * math.clamp(v115 / 0.3, 0, 1)
			end

			cue("card" .. k, p2, v78.done + v114, fn5) -- inferred equivalent call
		end

		label13.Visible = v110 * 4 + 2.35 <= v108
		label14.Visible = v108 >= 2.35

		local v113 = math.clamp((p2 - (v7 - v6 - 0.3)) / 0.3, 0, 1)

		local easeOut2 = Style.easeOut((math.clamp((p2 - 0.35) / 0.4, 0, 1)))
		local v114 = v41
		frame5.Visible = v114 ~= nil and easeOut2 > 0

		if v114 and easeOut2 > 0 then
			frame5.Position = UDim2.fromOffset(v38 - 40 * (1 - easeOut2), 0)
			view.frame.ImageTransparency = 1 - easeOut2
			view.frame.ImageColor3 = Color3.new(1, 1, 1):Lerp(Color3.fromRGB(120, 122, 128), v113)
			label15.TextTransparency = 1 - easeOut2
			label15.TextColor3 = Style.WHITE:Lerp(Style.DIM, v113)
			label16.TextTransparency = 1 - easeOut2
			tape3.BackgroundTransparency = 1 - easeOut2
			fill8.BackgroundTransparency = 1 - easeOut2
			local maxValue = 0

			for _, beat in v78.beats do
				local v116 = p2 - beat.t0 - (beat.t1 - beat.t0) * 0.5 / 2.6

				if v116 >= 0 and v116 < 0.5 then
					maxValue = math.max(maxValue, 1 - Style.easeOut(v116 / 0.5))
				end
			end

			uiScale3.Scale = maxValue * 0.08 + 1
			v114:PivotTo(v39 * CFrame.Angles(0, math.sin(p2 * 0.55) * 0.24434609527920614, 0))
		end

		if v113 ~= v77 then
			v77 = v113
			tintSeg(v28, v113) -- inferred equivalent call
			tintSeg(v29, v113) -- inferred equivalent call
			fill6.BackgroundColor3 = Style.WHITE:Lerp(Style.DIM, v113)
		end

		v23.set((math.max(v107, v113 * 0.45)))
	end

	local function start(p2: number)
		flag = true
		v53 = false
		v54 = p2
		v58 = str(domination:GetAttribute("Winner")) -- inferred equivalent call
		local name

		if player.Team and not player.Neutral then
			name = player.Team.Name
		end

		if name ~= "Reds" and name ~= "Blues" then
			name = nil
		end

		v56 = name or v58 == "" and "Reds" or v58
		v57 = Hardpoint.other(v56)
		local v78 = {
			Reds = num(domination:GetAttribute("Reds")), -- inferred equivalent call
			Blues = num(domination:GetAttribute("Blues")) -- inferred equivalent call
		}

		if domination:GetAttribute("GameMode") == "breakthrough" then
			local attackers = domination:GetAttribute("Attackers")
			assert(attackers == "Reds" or attackers == "Blues", "RoundEnd: breakthrough without Attackers")
			local v79 = num(domination:GetAttribute("Sectors")) -- inferred equivalent call
			local reds

			if domination:GetAttribute("WinHow") == "sectors" then
				reds = v79
			else
				reds = math.max(0, num(domination:GetAttribute("Sector")) - 1) -- inferred equivalent call
			end

			if attackers ~= "Reds" then
				reds = v79 - reds
			end

			v78.Reds = reds
			v78.Blues = v79 - v78.Reds
		end

		local v79

		if name == nil then
			v79 = false
		else
			v79 = name == v58
		end

		v64 = v79 or name == nil
		v63 = -1e999
		v65 = false
		v66 = false
		v67 = false
		local text2

		if name == nil then
			text2 = string.upper(v58) .. " TAKE THE ROUND"
			label2.TextColor3 = Style.teamText(v58)
		else
			text2 = v79 and "ROUND WON" or "ROUND LOST"
			local textColor = if v79 then Style.WHITE else Style.MUTED
			label2.TextColor3 = textColor
		end

		label2.Text = text2
		local backgroundColor

		if v79 then
			backgroundColor = Style.teamColor(v56):Lerp(Style.INK, 0.45)
		elseif name then
			backgroundColor = Style.STEEL:Lerp(Style.INK, 0.35)
		else
			backgroundColor = Style.teamColor(v58):Lerp(Style.INK, 0.45)
		end

		fill4.BackgroundColor3 = backgroundColor

		for _, v82 in { tape, tape2 } do
			v82.Visible = v79 or name == nil
		end

		local v82 = num(domination:GetAttribute("EndsAt")) -- inferred equivalent call
		local v83 = domination:GetAttribute("GameMode") == "siege"
		local v84 = domination:GetAttribute("GameMode") == "spawnraid" or v83
		local v85 = domination:GetAttribute("GameMode") == "tdm"
		local v86 = domination:GetAttribute("GameMode") == "breakthrough"
		local v87 = num(domination:GetAttribute("Target")) -- inferred equivalent call
		local text3

		if v86 then
			text3 = "BREAKTHROUGH  ·  SECTOR " .. num(domination:GetAttribute("Sector")) .. " OF " .. num(domination:GetAttribute("Sectors")) -- inferred equivalent call
		elseif v83 then
			text3 = "SPAWN SIEGE  ·  DESTROY THEIR SPAWNS"
		elseif v84 then
			text3 = "SPAWN RAID  ·  DESTROY THEIR SPAWNS"
		elseif v85 then
			text3 = "TEAM DEATHMATCH  ·  FIRST TO " .. v87 .. " KILLS"
		else
			text3 = text
		end

		label4.Text = text3
		local v89

		if v86 then
			local v90 = str(domination:GetAttribute("WinHow")) -- inferred equivalent call

			if v90 == "sectors" then
				v89 = "ALL SECTORS TAKEN"
			elseif v90 == "tickets" then
				v89 = "TICKETS RAN OUT"
			elseif v90 == "time" then
				v89 = "TIME RAN OUT"
			elseif v90 == "" then
				v89 = "ROUND CALLED"
			else
				v89 = error("RoundEnd: unknown WinHow " .. v90)
			end
		elseif v85 then
			if v87 > 0 and v87 <= (v78[v58] or 0) then
				v89 = "FIRST TO " .. v87 .. " KILLS"
			else
				v89 = domination:GetAttribute("Overtime") == true and "DECIDED IN OVERTIME"
					or v82 > 0 and v82 - 1 <= p2 and "MORE KILLS AT TIME"
					or "ROUND CALLED"
			end
		elseif v84 then
			local other = Hardpoint.other(v58)

			if v78[other] == 0 then
				v89 = "EVERY " .. string.upper(other) .. " SPAWN DESTROYED"
			else
				v89 = domination:GetAttribute("Overtime") == true and "DECIDED IN OVERTIME"
					or v82 > 0 and v82 - 1 <= p2 and "MORE SPAWNS LEFT AT TIME"
					or "ROUND CALLED"
			end
		elseif v78[v58] then
			local v90 = v78[v58]

			if num(domination:GetAttribute("Target")) <= v90 then -- inferred equivalent call
				if num(domination:GetAttribute("Target")) > 0 then -- inferred equivalent call
					if v2 then
						v89 = "FIRST TO " .. v78[v58]
					else
						v89 = Hardpoint.NAME .. " HELD TO " .. v78[v58]
					end
				else
					v89 = domination:GetAttribute("Overtime") == true and "DECIDED IN OVERTIME"
						or v82 > 0 and v82 - 1 <= p2 and "AHEAD WHEN TIME RAN OUT"
						or "ROUND CALLED"
				end
			else
				v89 = domination:GetAttribute("Overtime") == true and "DECIDED IN OVERTIME"
					or v82 > 0 and v82 - 1 <= p2 and "AHEAD WHEN TIME RAN OUT"
					or "ROUND CALLED"
			end
		else
			v89 = domination:GetAttribute("Overtime") == true and "DECIDED IN OVERTIME"
				or v82 > 0 and v82 - 1 <= p2 and "AHEAD WHEN TIME RAN OUT"
				or "ROUND CALLED"
		end

		label3.Text = v89 .. "   " .. Style.paint(tostring(v78[v56] or 0), Style.teamText(v56)) .. Style.paint("  -  ", Style.MUTED) .. Style.paint(tostring(v78[v57] or 0), Style.teamText(v57))
		label6.Text = text2
		local textColor

		if name == nil then
			textColor = Style.teamText(v58)
		else
			textColor = if v79 then Style.HAZARD else Style.MUTED
		end

		label6.TextColor3 = textColor
		local v91 = num(domination:GetAttribute("RoundTime")) -- inferred equivalent call
		local v92

		if v82 > 0 then
			if not (v91 > 0) then
				v91 = Hardpoint.ROUND_TIME
			end

			v92 = math.max(0, p2 - (v82 - v91))
		else
			v92 = 0
		end

		label7.Text = "ROUND " .. math.max(1, num(domination:GetAttribute("Round"))) .. "  ·  " .. Style.clock(v92) -- inferred equivalent call

		for k, v93 in { v56, v57 } do
			local v94 = v22[k]
			v94.band.BackgroundColor3 = Style.teamColor(v93)

			for _, child in v94.emblem:GetChildren() do
				child:Destroy()
			end

			Style.emblem(v94.emblem, v93, 30)
			v94.name.Text = string.upper(v93)
			v94.name.TextColor3 = Style.teamText(v93)
			v94.tag.Text = v93 == v58 and "TOOK THE ROUND" or ""
			v94.points.Text = tostring(v78[v93] or 0)
			local points = v94.points
			local textColor2

			if v93 == v58 then
				textColor2 = Style.HAZARD
			else
				textColor2 = Style.MUTED
			end

			points.TextColor3 = textColor2

			for _, row in v94.rows do
				row.group.Visible = false
			end
		end

		v62 = v56 == "Blues" and 3.141592653589793 or 0

		for k, v93 in v72 do
			local v94 = str(domination:GetAttribute(Hardpoint.attr("Holder", k))) -- inferred equivalent call
			local plate2 = v93.plate
			local backgroundColor2

			if v94 == "" then
				backgroundColor2 = Style.STEEL
			else
				backgroundColor2 = Style.teamColor(v94)
			end

			plate2.BackgroundColor3 = backgroundColor2
		end

		flag2 = false
		v59 = false
		v60 = nil
		v20 = 0

		if v69 then
			Podium.destroy(v69)
			v69 = nil
		end

		v71 = 0

		if clockT() < v3 - 1 then -- inferred equivalent call
			local v93 = Leaderboard.collect(player)
			local v94 = {}
			local v95 = {}
			local v96 = {}

			for i = 1, math.min(3, #v93) do
				local v97 = v93[i]
				local v98 = {
					name = v97.name,
					team = v97.team,
					bot = v97.bot,
					player = v97.player,
					entry = v97.entry
				}
				local v99, v100 = Podium.gunOf(v98, ShopData.PRIMARY_ATTR, ShopData.DEFAULT_PRIMARY)
				table.insert(v94, v98)
				table.insert(v95, { v99, v100 })
				local tool = ToolTemplates:FindFirstChild(v99)
				local v101 = WeaponSkins.find(v100)
				local skinColor

				if v101 and v101.crate then
					skinColor = WeaponSkins.rarity(v101.crate).color
				elseif v101 and v101.challenge then
					skinColor = Style.HAZARD
				elseif v100 == WeaponSkins.DEFAULT then
					skinColor = Style.MUTED
				else
					skinColor = Style.WHITE
				end

				local displayName = tool and tool:GetAttribute("DisplayName")
				local v103 = {
					rank = i,
					name = v97.name,
					team = v97.team,
					bot = v97.bot,
					level = v97.level,
					me = v97.me,
					score = v97.score,
					kills = v97.kills,
					deaths = v97.deaths,
					assists = v97.assists,
					tool = 0,
					gunName = 0,
					skinName = 0,
					skinColor = 0
				}

				if not (tool and tool:IsA("Tool")) then
					tool = nil
				end

				v103.tool = tool

				if type(displayName) == "string" then
					v99 = displayName
				end

				v103.gunName = string.upper(v99)
				local skinName

				if v101 then
					skinName = v101.name
				else
					skinName = WeaponSkins.DEFAULT
				end

				v103.skinName = skinName
				v103.skinColor = skinColor
				table.insert(v96, v103)
			end

			if #v94 > 0 then
				local groundAt, color6 = Podium.groundAt()
				v69 = Podium.build(v94, v95, { material = groundAt, color = color6 }, Detail.low == true)
				v70.set(v96)
				v71 = #v96
			end
		end

		flag4 = false
		v70.hide()
		setShown(true) -- inferred equivalent call
		fill12.BackgroundTransparency = 1
		roundEndGrade.Saturation = 0
		roundEndGrade.Enabled = true
		roundEndBlur.Size = 0
		roundEndBlur.Enabled = false
	end

	local function close()
		flag = false
		v53 = true
		RoundEndAudio.stop()
		releaseCamera()
		showHud() -- inferred equivalent call
		roundEndGrade.Enabled = false
		roundEndBlur.Enabled = false
		frame2.Visible = false

		if v69 then
			Podium.destroy(v69)
			v69 = nil
		end

		flag4 = false
		v70.hide()
		frame3.Visible = false
		frame4.Visible = false
		frame.Visible = false
		region5.Visible = false

		if v73 ~= false then
			v73 = false

			for _, v78 in v72 do
				v78.bb.Enabled = false
			end
		end

		region6.Visible = false

		v41 = nil
		view.show(nil)

		for _, v78 in views do
			v78.destroy()
		end

		table.clear(views)

		for _, v78 in v37 do
			v78.root.Visible = false

			for _, child in v78.pic:GetChildren() do
				child:Destroy()
			end
		end

		v75 = 0
		local backgroundTransparency = fill12.BackgroundTransparency
		local now = os.clock()
		Style.animate(fill12, function(_, p2): boolean
			local v78 = math.clamp((p2 - now) / 0.4, 0, 1)
			fill12.BackgroundTransparency = backgroundTransparency + (1 - backgroundTransparency) * v78

			if not (v78 >= 1) then
				return true
			end

			v53 = false
			setShown(false) -- inferred equivalent call
			return false
		end)
	end

	local function frame12(p2: number)
		local serverTimeNow = workspace:GetServerTimeNow()

		if p2 >= 0.5 and not flag2 then
			flag2 = true
			hideHud()
		end

		if flag2 then
			local character = player.Character
			local humanoid = character
				and character:FindFirstChildOfClass("Tool")
				and character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				humanoid:UnequipTools()
			end
		end

		if flag2 and math.floor(p2 * 2) ~= math.floor((p2 - 1 / 60) * 2) then
			hideHud()
		end

		fill12.BackgroundTransparency = blackAt(p2)
		local saturation

		if p2 < 3 then
			saturation = 0
		elseif p2 < 4.3 then
			saturation = -0.85 * Style.smooth((p2 - 3) / 1.0999999999999996)
		else
			saturation = p2 < v4 and 0 or -0.15
		end

		roundEndGrade.Saturation = saturation

		if p2 >= 4.1 then
			holdCamera() -- inferred equivalent call
		end

		local visible

		if p2 >= 0.5 then
			visible = p2 < 4.3
		else
			visible = false
		end

		frame2.Visible = visible

		if visible then
			local v80 = p2 - 0.5
			fill4.Size = UDim2.fromScale(Style.easeOut(v80 / 0.35), 1)
			v18(1 - Style.easeOut(v80 / 0.25))
			uiScale.Scale = 1 + 0.15 * (1 - Style.easeOut(v80 / 0.3))
		end

		if v69 then
			if p2 < v4 then
				if p2 >= 4.3 then
					Podium.step(v69, p2 - 4.3)
				end
			else
				Podium.destroy(v69)
				v69 = nil
			end
		end

		local v80

		if v71 > 0 and p2 >= 4.3 then
			v80 = p2 < v3 + 0.3
		else
			v80 = false
		end

		if v80 then
			flag4 = true
			v70.step(p2 - 4.3, Podium.PUSH_AT)
		elseif flag4 then
			flag4 = false
			v70.hide()
		end

		local visible2 = p2 >= 4.3
		frame3.Visible = visible2
		local visible3

		if visible2 then
			visible3 = not (touch and v6 <= p2)
		else
			visible3 = visible2
		end

		frame4.Visible = visible3
		frame.Visible = visible2

		if visible2 then
			setStep(p2 < v4 and 1 or p2 < v6 and 2 or 3)
			label8.Text = Style.clock(num(domination:GetAttribute("NextAt")) - serverTimeNow + Hardpoint.COUNTDOWN) -- inferred equivalent call
		end

		local visible4

		if v4 <= p2 then
			visible4 = p2 < v6
		else
			visible4 = false
		end

		region5.Visible = visible4
		showTags(visible4) -- inferred equivalent call

		if visible4 then
			if not v59 then
				fillBoard(p2)
			end

			animateBoard(p2)
		end

		local v84 = v6 <= p2
		region6.Visible = v84
		fill3.Visible = v84
		fill.Visible = not v84
		fill2.Visible = not v84
		roundEndBlur.Enabled = v84

		if v84 then
			roundEndBlur.Size = 18 * Style.easeOut((p2 - v6) / 0.4)

			if not v60 then
				startLevel()
			end

			animateLevel(p2 - v6)
		end

		if not v65 and p2 >= 0.5 then
			v65 = true
			RoundEndAudio.start(v64, p2 - 0.5)
		end

		local v85

		if v63 < 4.3 and p2 >= 4.3 then
			v85 = p2 - 4.3 < 0.3
		else
			v85 = false
		end

		if v85 then
			RoundEndAudio.boardIn()
		else
			local v86 = v4
			local v87

			if v63 < v86 and v86 <= p2 then
				v87 = p2 - v86 < 0.3
			else
				v87 = false
			end

			if v87 then
				RoundEndAudio.boardIn()
			end
		end

		for i = 1, v71 do
			local v86 = 4.3 + PodiumCards.appearAt(i)
			local v87

			if v63 < v86 and v86 <= p2 then
				v87 = p2 - v86 < 0.3
			else
				v87 = false
			end

			if v87 then
				RoundEndAudio.tileLand()
			end
		end

		if v71 > 0 then
			local v86 = 4.3 + Podium.PUSH_AT - RoundEndAudio.WHOOSH_LEAD
			local v87

			if v63 < v86 and v86 <= p2 then
				v87 = p2 - v86 < 0.3
			else
				v87 = false
			end

			if v87 then
				RoundEndAudio.whoosh()
			end
		end

		local v86 = v6 - RoundEndAudio.WHOOSH_LEAD
		local v87

		if v63 < v86 and v86 <= p2 then
			v87 = p2 - v86 < 0.3
		else
			v87 = false
		end

		if v87 then
			RoundEndAudio.whoosh()
		end

		if not v66 and v6 <= p2 then
			v66 = true
			RoundEndAudio.toLevel()
		end

		if not v67 and v7 <= p2 then
			v67 = true
			RoundEndAudio.fadeOut()
		end

		v63 = p2
	end

	local function voting(): boolean -- 2 equivalent calls inferred from this helper
		local vote = Game:FindFirstChild("Vote")
		return vote ~= nil and str(vote:GetAttribute("Stage")) ~= "" -- inferred equivalent call
	end

	local function inLobby(): boolean -- 2 equivalent calls inferred from this helper
		return player.Team == nil and player:GetAttribute("PickingTeam") == true
	end

	local renderSteppedConnection = nil
	local function step()
		local v78 = str(domination:GetAttribute("Phase")) -- inferred equivalent call
		local v79 = num(domination:GetAttribute("NextAt")) -- inferred equivalent call

		if flag then
			if v78 == "over" and v79 - Hardpoint.INTERMISSION == v54 and not voting() and not inLobby() then -- inferred equivalent call
				frame12(clockT()) -- inferred equivalent call
				return
			end

			close()
		else
			if v78 == "over" and v79 > 0 and not v53 and not voting() then -- inferred equivalent call
				local v80 = v79 - Hardpoint.INTERMISSION

				if v80 ~= v55 then
					v55 = v80

					if workspace:GetServerTimeNow() - v80 < v7 and not inLobby() then -- inferred equivalent call
						start(v80)
					end
				end
			end

			if not flag and v78 ~= "over" and renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end
		end
	end
	domination:GetAttributeChangedSignal("Phase"):Connect(function()
		if not renderSteppedConnection then
			renderSteppedConnection = RunService.RenderStepped:Connect(step)
		end
	end)
	renderSteppedConnection = RunService.RenderStepped:Connect(step)
end

return RoundEnd