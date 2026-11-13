local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Style = require(script.Parent.Style)
local ClaimAudio = require(script.Parent.ClaimAudio)
local RoundEndAudio = require(script.Parent.RoundEndAudio)
local GearSound = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("GearSound"))
local Game = ReplicatedStorage:WaitForChild("Game")
local CareerData = require(Game:WaitForChild("CareerData"))
local ShopData = require(Game:WaitForChild("ShopData"))
local Skins = require(Game:WaitForChild("Skins"))
local ToolIcon = require(script.Parent:WaitForChild("ToolIcon"))
local Icons = require(script.Parent:WaitForChild("Workbench"):WaitForChild("Icons"))
local VehicleConfig = require(ReplicatedStorage:WaitForChild("Vehicles"):WaitForChild("VehicleConfig"))
local Gunsmith = ReplicatedStorage:FindFirstChild("Gunsmith")
local Gunsmith2

if Gunsmith then
	Gunsmith2 = require(Gunsmith:WaitForChild("Gunsmith"))
else
	Gunsmith2 = nil
end

local WeaponSkins = require(Game:WaitForChild("WeaponSkins"))
local Mastery = require(Game:WaitForChild("Mastery"))

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

local function scramble(folder, vector2: Vector2, p: number, p2: number, p3: number)
	local v = math.max(2, ((math.floor)(p / p3)))
	local v2 = math.max(1, ((math.floor)(p2 / p3)))
	local v3 = {}

	for i = 1, v do
		for j = 1, v2 do
			local frame = Style.frame(
				folder,
				"Bit",
				UDim2.fromOffset(BIT, BIT),
				UDim2.fromOffset(vector2.X, vector2.Y),
				Vector2.new(0.5, 0.5)
			)
			frame.ZIndex = 6
			frame.Visible = false
			local stroke = Style.stroke
			local v4

			if math.random() < 0.2 then
				v4 = Style.HAZARD
			else
				v4 = Style.STEEL_LIGHT
			end

			stroke(frame, 1, 0.15, v4)

			if math.random() < 0.35 then
				for _, rotation in { 45, -45 } do
					local fill = Style.fill(
						frame,
						"X",
						Style.STEEL_LIGHT,
						UDim2.new(1.3, 0, 0, 1),
						UDim2.fromScale(0.5, 0.5),
						Vector2.new(0.5, 0.5)
					)
					fill.Rotation = rotation
					fill.ZIndex = 6
				end
			end

			table.insert(v3, {
				frame = frame,
				home = Vector2.new(vector2.X - p / 2 + (i - 0.5) * p / v, vector2.Y - p2 / 2 + (j - 0.5) * p2 / v2)
			})
		end
	end

	local v4 = -1
	return function(value: number?)
		if value == nil then
			for _, v5 in v3 do
				v5.frame.Visible = false
			end

			v4 = -1
		else
			local v5 = math.floor(os.clock() * 30)

			if v5 == v4 then
				return
			end

			v4 = v5
			local v6 = 0.6 * Style.easeIn((math.clamp(value, 0, 1)))

			for _, v7 in v3 do
				v7.frame.Visible = math.random() < 0.7 - 0.3 * value
				local lerped = v7.home:Lerp(vector2, v6)
				v7.frame.Position = UDim2.fromOffset(lerped.X, lerped.Y)
			end
		end
	end
end

local function fadeWord(instance, textTransparency: number) -- 4 equivalent calls inferred from this helper
	instance.TextTransparency = textTransparency
	local uiStroke = instance:FindFirstChildOfClass("UIStroke")

	if uiStroke then
		uiStroke.Transparency = 1 - (1 - textTransparency) * 0.75
	end
end

local color = Color3.fromRGB(214, 164, 58)
local color2 = Color3.fromRGB(168, 120, 36)

local SWEEP_LEAD = RoundEndAudio.SWEEP_LEAD

local color3 = Color3.fromRGB(13, 14, 16)

local function attachments(childName: string, p: number, p2: number)
	local result = {}

	if WeaponSkins.has(childName) then
		for _, v in WeaponSkins.opened(p, p2) do
			table.insert(result, { name = v.name, slot = WeaponSkins.SLOT, id = v.id })
		end
	end

	if Gunsmith2 and Gunsmith2.has(childName) then
		for _, v in Gunsmith2.opened(childName, p, p2) do
			for _, slot in Gunsmith2.GUNS[childName].slots do
				if table.find(slot.options, v) then
					table.insert(result, { name = v.name, slot = slot.id, id = v.id })
					break
				end
			end
		end
	end

	return result
end

local function opened(player, from: number, to: number)
	local function within(p: number?): boolean -- 3 equivalent calls inferred from this helper
		return p ~= nil and from < p and p <= to
	end

	local v = {}
	local result = {}

	for k, v2 in VehicleConfig.DRIVE_LEVEL do
		if within(v2) then -- inferred equivalent call
			table.insert(v, VehicleConfig.DRIVE_NAMES[k] .. " UNLOCKED")
		end
	end

	table.sort(v)

	for _, v2 in v do
		table.insert(result, v2)
	end

	local v2 = {}

	for k, v3 in ShopData.ITEMS do
		if not within(v3.level) or (v3.retired or v3.hidden or ShopData.owns(player, k)) then -- inferred equivalent call
			continue
		end

		table.insert(v2, string.upper(names[k] or k))
	end

	table.sort(v2)

	if #v2 > 0 then
		local v3 = table.concat(v2, ", ", 1, (math.min(#v2, 3)))

		if #v2 > 3 then
			v3 ..= " +" .. #v2 - 3
		end

		table.insert(result, (#v2 == 1 and "WEAPON UNLOCKED  ·  " or "WEAPONS UNLOCKED  ·  ") .. v3)
	end

	local names2 = {}

	for _, v3 in Skins.LIST do
		if within(v3.level) then -- inferred equivalent call
			table.insert(names2, string.upper(v3.name))
		end
	end

	if #names2 > 0 then
		table.insert(result, "OUTFIT UNLOCKED  ·  " .. table.concat(names2, ", "))
	end

	while #result > 3 do
		table.remove(result)
	end

	return result
end

return {
	mount = function(data)
		local player = data.player
		local hud = data.layers.hud
		local remotes = Game:WaitForChild("Remotes")
		local badge = remotes:WaitForChild("Badge")
		local levelUp = remotes:WaitForChild("LevelUp")
		local weaponLevel = remotes:WaitForChild("WeaponLevel")
		local quest = remotes:WaitForChild("Quest")

		local region = Style.region(
			hud,
			"BadgeAward",
			Vector2.new(0.5, 0),
			Vector2.new(0, Style.topInset() + 6),
			Vector2.new(360, 213)
		)

		local v = {}
		local v2 = false
		local v3 = false

		local fn

		local function word(frame, p: string, p2: string, p3: number, textColor: Color3, p4) -- 7 equivalent calls inferred from this helper
			local label = Style.label(frame, p, p2, p3, p4 or Style.FONT, 1.5)
			label.TextColor3 = textColor
			label.TextTransparency = 1
			label.ZIndex = 2
			local uiStroke = label:FindFirstChildOfClass("UIStroke")

			if uiStroke then
				uiStroke.Transparency = 1
			end

			return label
		end

		local function showWeapon(gun: string, from: number, to: number)
			v2 = true
			local v4 = attachments(gun, from, to)
			local v5 = math.max(0, #v4 - 3)
			local v6 = math.min(#v4, 3)
			local v7 = v6 * 0.6 + 4.8

			local vector2 = Vector2.new(306, 127)
			local vector2_2 = Vector2.new(67, 127)
			local function softEnds(parent, p: number)
				local uiGradient = Instance.new("UIGradient")
				uiGradient.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.5, p),
					NumberSequenceKeypoint.new(1, 1)
				})
				uiGradient.Parent = parent
			end

			local folder = Style.frame(region, "Award", UDim2.fromScale(1, 1))

			local fill = Style.fill(
				folder,
				"Flare",
				Style.HAZARD,
				UDim2.fromOffset(0, 24),
				UDim2.fromOffset(vector2.X, vector2.Y),
				Vector2.new(0.5, 0.5)
			)
			fill.Visible = false
			softEnds(fill, 0.2)
			local fill2 = Style.fill(
				folder,
				"FlareCore",
				Style.WHITE,
				UDim2.fromOffset(0, 3),
				UDim2.fromOffset(vector2.X, vector2.Y),
				Vector2.new(0.5, 0.5)
			)
			fill2.Visible = false
			fill2.ZIndex = 7
			softEnds(fill2, 0)

			local frame = Style.frame(
				folder,
				"Plate",
				UDim2.fromOffset(0, 46),
				UDim2.fromOffset(180, 104),
				Vector2.new(0.5, 0)
			)
			frame.ClipsDescendants = true
			frame.ZIndex = 2
			local frame2 = Style.frame(
				frame,
				"Inside",
				UDim2.fromOffset(320, 46),
				UDim2.fromScale(0.5, 0.5),
				Vector2.new(0.5, 0.5)
			)
			local fill3 = Style.fill(frame2, "Back", Style.PANEL, UDim2.fromScale(1, 1))
			fill3.BackgroundTransparency = 0.12
			Style.corner(fill3, 3)
			Style.fill(frame2, "Edge", Style.HAZARD, UDim2.new(0, 3, 1, 0))
			local fill4 = Style.fill(frame2, "Xp", Style.STEEL, UDim2.new(1, 0, 0, 3), UDim2.fromOffset(0, 43))
			local fill5 = Style.fill(fill4, "Fill", Style.WHITE, UDim2.fromScale(0, 1))
			local fill6 = Style.fill(frame2, "Flash", Color3.new(1, 1, 1), UDim2.fromScale(1, 1))
			fill6.BackgroundTransparency = 1
			fill6.ZIndex = 5
			local label3 = word(frame2, "Title", "WEAPON LEVEL UP", 12, Style.HAZARD) -- inferred equivalent call
			local label4 = word(frame2, "Name", string.upper(names[gun] or gun), 22, Style.WHITE) -- inferred equivalent call
			local parent = word(frame2, "Level", string.format("LV %d", from), 24, Style.WHITE) -- inferred equivalent call
			parent.AnchorPoint = Vector2.new(0.5, 0.5)
			parent.Position = UDim2.fromOffset(286, 22)
			local uiScale = Instance.new("UIScale")
			uiScale.Parent = parent

			local label5 = word(frame2, "LevelWas", string.format("LV %d", from), 24, Style.WHITE) -- inferred equivalent call
			label5.AnchorPoint = Vector2.new(0.5, 0.5)
			label5.Position = parent.Position

			local frame3 = Style.frame(
				folder,
				"Glow",
				UDim2.fromOffset(320, 46),
				UDim2.fromOffset(180, 104),
				Vector2.new(0.5, 0)
			)
			frame3.ZIndex = 3
			Style.corner(frame3, 3)
			local stroke = Style.stroke(frame3, 3, 1, Style.HAZARD)

			local tool = ReplicatedStorage:WaitForChild("ToolTemplates"):FindFirstChild(gun)
			assert(tool and tool:IsA("Tool"), "[BadgeAward] no tool for " .. gun)
			local frame4 = Style.frame(
				folder,
				"Gun",
				UDim2.fromOffset(78, 38),
				UDim2.fromOffset(vector2_2.X, vector2_2.Y),
				Vector2.new(0.5, 0.5)
			)
			frame4.ZIndex = 3
			frame4.Visible = false
			local uiScale2 = Instance.new("UIScale")
			uiScale2.Parent = frame4
			ToolIcon.voxelImage(tool, frame4)
			local frame5 = Style.frame(frame4, "Clip", UDim2.fromScale(1, 1))
			frame5.ClipsDescendants = true
			frame5.ZIndex = 4
			local fill7 = Style.fill(
				frame5,
				"Glint",
				Color3.new(1, 1, 1),
				UDim2.fromOffset(10, 76),
				UDim2.fromOffset(-16, 19),
				Vector2.new(0.5, 0.5)
			)
			fill7.Rotation = 22
			fill7.Visible = false
			softEnds(fill7, 0.35)
			local function glintAt(p: number) -- 2 equivalent calls inferred from this helper
				fill7.Visible = p > 0 and p < 1
				fill7.Position = UDim2.fromOffset(-16 + 110 * Style.easeOut(p), 19)
			end
			local v8 = scramble(folder, vector2_2, 68, 30, 12)

			local v9 = v6 * 98 + (v6 - 1) * 6
			local v10 = {}

			for i = 1, v6 do
				local v11 = v4[i]
				local v12 = (360 - v9) / 2 + (i - 1) * 104 + 49

				local fill8 = Style.fill(
					folder,
					"Tile" .. i,
					color3,
					UDim2.fromOffset(98, 58),
					UDim2.fromOffset(v12, 185),
					Vector2.new(0.5, 0.5)
				)
				fill8.BackgroundTransparency = 0.08
				fill8.Visible = false
				fill8.ZIndex = 3
				Style.corner(fill8, 3)
				local colour

				if i == 1 then
					colour = Style.HAZARD
				else
					colour = Style.STEEL_LIGHT
				end

				local stroke2 = Style.stroke(fill8, 1.5, 0, colour, true)
				local uiScale3 = Instance.new("UIScale")
				uiScale3.Scale = 0
				uiScale3.Parent = fill8
				local rect = Icons.rects[string.format("%s/%s/%s", gun, v11.slot, v11.id)]
				local v13

				if v11.slot == WeaponSkins.SLOT then
					v13 = WeaponSkins.find(v11.id)
				end

				local imageLabel = nil

				if v13 then
					imageLabel = Instance.new("ImageLabel")
					imageLabel.Name = "Swatch"
					imageLabel.BorderSizePixel = 0
					imageLabel.AnchorPoint = Vector2.new(0.5, 0)
					imageLabel.Position = UDim2.fromOffset(49, 14)
					imageLabel.Size = UDim2.fromOffset(26, 26)
					imageLabel.ScaleType = Enum.ScaleType.Crop
					imageLabel.Image = v13.image or ""
					imageLabel.BackgroundTransparency = v13.image and 1 or 0
					imageLabel.BackgroundColor3 = v13.metal or Style.STEEL
					imageLabel.Parent = fill8
					Style.corner(imageLabel, 2)
				elseif rect then
					imageLabel = Instance.new("ImageLabel")
					imageLabel.Name = "Icon"
					imageLabel.BackgroundTransparency = 1
					imageLabel.BorderSizePixel = 0
					imageLabel.Position = UDim2.fromOffset(4, 14)
					imageLabel.Size = UDim2.fromOffset(90, 26)
					imageLabel.ScaleType = Enum.ScaleType.Fit
					imageLabel.Image = Icons.sheets[rect[5]]
					imageLabel.ImageRectOffset = Vector2.new(rect[1], rect[2])
					imageLabel.ImageRectSize = Vector2.new(rect[3], rect[4])
					imageLabel.Parent = fill8
				else
					warn(string.format(
						"[BadgeAward] no icon for %s %s %s (analysis/optimization/toolicon-atlas/attachment)",
						gun,
						v11.slot,
						v11.id
					))
				end

				local label = Style.label(
					fill8,
					"New",
					(i ~= v6 or not (v5 > 0)) and "NEW" or "+" .. v5 .. " MORE",
					12,
					Style.FONT,
					0
				)
				label.Position = UDim2.fromOffset(5, 1)
				label.TextColor3 = Style.HAZARD
				label.TextTransparency = 1
				local uiScale4 = Instance.new("UIScale")
				uiScale4.Parent = label
				local label2 = Style.label(fill8, "Name", string.upper(v11.name), 12, Style.FONT, 0)
				label2.AnchorPoint = Vector2.new(0.5, 1)
				label2.Position = UDim2.new(0.5, 0, 1, -3)
				local fill9 = Style.fill(fill8, "Flash", Color3.new(1, 1, 1), UDim2.fromScale(1, 1))
				fill9.BackgroundTransparency = 1
				fill9.ZIndex = 5
				Style.corner(fill9, 3)
				local frame6 = Style.frame(
					folder,
					"TileRing",
					UDim2.fromOffset(0, 0),
					UDim2.fromOffset(v12, 185),
					Vector2.new(0.5, 0.5)
				)
				frame6.ZIndex = 4
				frame6.Visible = false
				Style.corner(frame6, 999)
				local stroke3 = Style.stroke(frame6, 3, 0, colour)
				local bits = scramble(folder, Vector2.new(v12, 185), 82, 44, 14)
				local slot = if v13 then WeaponSkins.SLOT else v11.slot

				if imageLabel then
					imageLabel.ImageTransparency = 1

					if not v13 then
						imageLabel.BackgroundTransparency = 1
					end
				end

				local base

				if imageLabel then
					base = imageLabel.Position
				else
					base = UDim2.new()
				end

				table.insert(v10, {
					frame = fill8,
					pop = uiScale3,
					bits = bits,
					stroke = stroke2,
					flash = fill9,
					ring = frame6,
					ringStroke = stroke3,
					colour = colour,
					slot = slot,
					part = imageLabel,
					base = base,
					tag = label,
					tagPop = uiScale4,
					seated = false
				})
			end

			local function ringFrame(color4: Color3)
				local frame6 = Style.frame(
					folder,
					"Ring",
					UDim2.fromOffset(0, 0),
					UDim2.fromOffset(vector2.X, vector2.Y),
					Vector2.new(0.5, 0.5)
				)
				frame6.ZIndex = 4
				frame6.Visible = false
				Style.corner(frame6, 999)
				return frame6, Style.stroke(frame6, 6, 0, color4)
			end

			local v11, v12 = ringFrame(Style.HAZARD)
			local v13, v14 = ringFrame(Style.WHITE)
			local v15 = {}

			for i = 1, 12 do
				local v16 = (i - 0.5) / 12 * 2 * 3.141592653589793 + (math.random() - 0.5) * 0.35
				local fill8 = Style.fill
				local v17

				if i % 3 == 0 then
					v17 = Style.WHITE
				else
					v17 = Style.HAZARD
				end

				local frame6 = fill8(
					folder,
					"Ray",
					v17,
					UDim2.fromOffset(4, 0),
					UDim2.fromOffset(vector2.X, vector2.Y),
					Vector2.new(0.5, 0.5)
				)
				frame6.ZIndex = 4
				frame6.Visible = false
				frame6.Rotation = math.deg(v16) + 90
				table.insert(v15, {
					frame = frame6,
					dir = Vector2.new(math.cos(v16), (math.sin(v16))),
					reach = 0.8 + math.random() * 0.4
				})
			end

			local v16 = {}

			for i = 1, 18 do
				local v17 = 5 + math.random() * 6
				local fill8 = Style.fill
				local v18

				if i % 3 == 0 then
					v18 = Style.WHITE
				else
					v18 = Style.HAZARD
				end

				local frame6 = fill8(
					folder,
					"Shard",
					v18,
					UDim2.fromOffset(v17, v17),
					UDim2.fromOffset(vector2.X, vector2.Y),
					Vector2.new(0.5, 0.5)
				)
				frame6.Visible = false
				frame6.ZIndex = 4
				frame6.Rotation = math.random() * 90
				local v19 = math.random() * 2 * 3.141592653589793
				local v20 = 160 + math.random() * 160
				table.insert(v16, {
					frame = frame6,
					v = Vector2.new(math.cos(v19), math.sin(v19) - 0.45) * v20,
					spin = (math.random() * 2 - 1) * 540,
					r0 = frame6.Rotation
				})
			end

			local now = os.clock()
			local v17 = false
			local v18 = false
			local v19 = false
			local count = 0
			local v20 = 0
			local v21 = 0
			local v22 = math.max(0, v6 - 1) * 0.75 + 1.65 + 0.12 + 0.6
			local v23 = false
			local v24 = nil
			Style.animate(folder, function(_, p: number): boolean
				local v25 = p - now
				local v26 = math.clamp((v25 - v7) / 0.35, 0, 1)

				if v26 >= 1 then
					folder:Destroy()
					v2 = false
					task.defer(fn)
					return false
				elseif v26 > 0 then
					if not v24 then
						local v27 = {}

						for _, descendant in folder:GetDescendants() do
							if descendant:IsA("TextLabel") then
								table.insert(v27, { descendant, "TextTransparency", descendant.TextTransparency })
							elseif descendant:IsA("ImageLabel") then
								table.insert(v27, { descendant, "ImageTransparency", descendant.ImageTransparency })
							elseif descendant:IsA("UIStroke") then
								table.insert(v27, { descendant, "Transparency", descendant.Transparency })
							end

							if descendant:IsA("GuiObject") then
								table.insert(v27, {
									descendant,
									"BackgroundTransparency",
									descendant.BackgroundTransparency
								})
							end
						end

						v24 = v27
					end

					for _, v27 in v24 do
						v27[1][v27[2]] = v27[3] + (1 - v27[3]) * v26
					end

					folder.Position = UDim2.fromOffset(0, -8 * Style.easeIn(v26))
					local v27

					if v26 < 0.7 then
						v27 = v26 / 0.7
					end

					v8(v27)
					return true
				else
					local v27 = v25 - 0.35
					local v28 = v22 <= v27

					if v28 and v23 then
						return true
					end

					frame.Size = UDim2.fromOffset(320 * Style.easeOut((math.clamp((v25 - 0.06) / 0.28, 0, 1))), 46)

					if v25 < 0.35 then
						if v25 >= 0.06 then
							if not v17 then
								v17 = true
								RoundEndAudio.weaponDecode()
							end

							v8((v25 - 0.06) / 0.29)
						end

						return true
					else
						if not v18 then
							v18 = true
							v8(nil)
							frame4.Visible = true
							RoundEndAudio.weaponLand()
							RoundEndAudio.weaponRise(0.75)
						end

						local function slideIn(instance, p2: number, p3: number, p4: number) -- 2 equivalent calls inferred from this helper
							local v29 = math.clamp((v27 - p2) / 0.22, 0, 1)
							instance.Position = UDim2.fromOffset(p3 - 14 * (1 - Style.easeOut(v29)), p4)
							fadeWord(instance, 1 - v29) -- inferred equivalent call
						end

						slideIn(label3, 0.03, 92, 5) -- inferred equivalent call
						slideIn(label4, 0.09, 92, 17) -- inferred equivalent call
						fill5.Size = UDim2.fromScale(Style.easeIn((math.clamp((v27 - 0.1) / 0.65, 0, 1))), 1)

						while count < 6 and count * 0.65 / 6 + 0.1 <= v27 do
							RoundEndAudio.weaponFill(count / 5)
							count += 1
						end

						if v27 < 0.75 then
							uiScale2.Scale = 1 + 0.08 * (1 - Style.easeOut((math.clamp(v27 / 0.14, 0, 1))))
							glintAt(math.clamp((v27 - 0.18) / 0.32, 0, 1)) -- inferred equivalent call
							fadeWord(parent, 1 - math.clamp((v27 - 0.05) / 0.2, 0, 1)) -- inferred equivalent call
							return true
						else
							if not v19 then
								v19 = true
								RoundEndAudio.weaponLevel(to >= Mastery.MAX_LEVEL)
								parent.Text = string.format("LV %d", to)
								fadeWord(parent, 0) -- inferred equivalent call
								fill5.BackgroundColor3 = Style.HAZARD
								fill.Visible = true
								fill2.Visible = true
								v11.Visible = true

								for _, v29 in v16 do
									v29.frame.Visible = true
								end

								for _, v29 in v15 do
									v29.frame.Visible = true
								end
							end

							local v29 = v27 - 0.75

							uiScale2.Scale = 1 + 0.16 * (1 - Style.easeOut((math.clamp(v29 / 0.22, 0, 1))))
							glintAt(math.clamp(v29 / 0.28, 0, 1)) -- inferred equivalent call

							local v30 = math.clamp(v29 / 0.3, 0, 1)
							uiScale.Scale = 1 + 0.9 * (1 - Style.easeOut(v30))
							parent.TextColor3 = Style.WHITE:Lerp(Style.HAZARD, (math.clamp(v29 / 0.25, 0, 1)))
							local easeOut = Style.easeOut((math.clamp(v29 / 0.2, 0, 1)))
							parent.Position = UDim2.fromOffset(286, 22 + 16 * (1 - easeOut))
							label5.Position = UDim2.fromOffset(286, 22 - 16 * easeOut)
							fadeWord(label5, easeOut) -- inferred equivalent call
							fill6.BackgroundTransparency = math.clamp(v29 / 0.3, 0, 1) * 0.7 + 0.3

							local transparency = math.clamp(v29 / 0.6, 0, 1)
							stroke.Transparency = transparency
							stroke.Thickness = 1 + 5 * (1 - Style.easeOut(transparency))

							local backgroundTransparency = math.clamp(v29 / 0.55, 0, 1)
							local v31 = 864 * Style.easeOut((math.clamp(v29 / 0.18, 0, 1)))
							fill.Size = UDim2.fromOffset(v31, (1 - backgroundTransparency) * 24 + 2)
							fill.BackgroundTransparency = backgroundTransparency * 0.55 + 0.45
							fill2.Size = UDim2.fromOffset(v31 * 0.8, 3)
							fill2.BackgroundTransparency = backgroundTransparency

							if backgroundTransparency >= 1 then
								fill.Visible = false
								fill2.Visible = false
							end

							local transparency2 = math.clamp(v29 / 0.45, 0, 1)
							v11.Size = UDim2.fromOffset(
								170 * Style.easeOut(transparency2),
								170 * Style.easeOut(transparency2)
							)
							v12.Thickness = math.max(1, (1 - transparency2) * 7)
							v12.Transparency = transparency2
							v11.Visible = transparency2 < 1
							local transparency3 = math.clamp((v29 - 0.06) / 0.4, 0, 1)
							v13.Visible = transparency3 > 0 and transparency3 < 1
							v13.Size = UDim2.fromOffset(
								110 * Style.easeOut(transparency3),
								110 * Style.easeOut(transparency3)
							)
							v14.Thickness = math.max(1, (1 - transparency3) * 4)
							v14.Transparency = transparency3

							local backgroundTransparency2 = math.clamp(v29 / 0.35, 0, 1)

							for _, v32 in v15 do
								local v43 = 16 + 95 * v32.reach * Style.easeOut(backgroundTransparency2)
								local v44 = (1 - backgroundTransparency2) * 30 + 3
								local v45 = vector2 + v32.dir * (v43 + v44 / 2)
								v32.frame.Position = UDim2.fromOffset(v45.X, v45.Y)
								v32.frame.Size = UDim2.fromOffset(4, v44)
								v32.frame.BackgroundTransparency = backgroundTransparency2
								v32.frame.Visible = backgroundTransparency2 < 1
							end

							for _, v32 in v16 do
								if not v32.frame.Visible then
									continue
								end

								local v43 = vector2 + v32.v * v29 + Vector2.new(0, 420 * v29 * v29)
								v32.frame.Position = UDim2.fromOffset(v43.X, v43.Y)
								v32.frame.Rotation = v32.r0 + v32.spin * v29
								v32.frame.BackgroundTransparency = math.clamp((v29 - 0.3) / 0.4, 0, 1)

								if v29 > 0.7 then
									v32.frame.Visible = false
								end
							end

							for k, v32 in v10 do
								local v43 = (k - 1) * 0.75 + 0.9

								if v43 - 0.12 <= v29 and v21 < k then
									v21 = k
									RoundEndAudio.weaponTileDecode()
								end

								if v43 - 0.12 <= v29 and v29 < v43 then
									v32.bits((v29 - (v43 - 0.12)) / 0.12)
								elseif v43 <= v29 and v20 < k then
									v20 = k
									v32.bits(nil)
									v32.frame.Visible = true
								end

								if not (v43 <= v29) then
									continue
								end

								local v44 = v29 - v43
								v32.pop.Scale = Style.pop((math.clamp(v44 / 0.16, 0, 1)))
								local part = v32.part
								local v45 = math.clamp(v44 / 0.12, 0, 1)
								local v46 = v44 - 0.12

								if part then
									local base = v32.base
									local v47 = 0
									local v48 = 0
									local rotation = 0
									local v50 = 1 - v45 * v45

									if v32.slot == "Optic" then
										v48 = v50 * -18 - (not (v46 > 0) and 0 or math.sin(3.141592653589793 * math.clamp(v46 / 0.12, 0, 1)) * 3)
									elseif v32.slot == "Muzzle" then
										v47 = v50 * 26

										if v46 > 0 and v46 < 0.24 then
											rotation = math.sin(v46 / 0.24 * 3 * 3.141592653589793) * 9 * (1 - v46 / 0.24)
										end
									elseif v32.slot == "Magazine" then
										v48 = v50 * 16 - (not (v46 > 0) and 0 or math.sin(3.141592653589793 * math.clamp(v46 / 0.08, 0, 1)) * 2)
									elseif v32.slot == "Barrel" then
										v47 = v50 * 34

										if v46 > 0 and v46 < 0.3 then
											rotation = math.sin(v46 / 0.3 * 2 * 3.141592653589793) * 5 * (1 - v46 / 0.3)
										end
									elseif v32.slot == "Underbarrel" then
										v47 = v50 * 26 - (not (v46 > 0) and 0 or math.sin(3.141592653589793 * math.clamp(v46 / 0.1, 0, 1)) * 2)
									end

									if v32.slot == WeaponSkins.SLOT then
										local easeOut2 = Style.easeOut((math.clamp(v44 / 0.24, 0, 1)))
										part.AnchorPoint = Vector2.new(0, 0)
										part.Position = UDim2.fromOffset(36, base.Y.Offset)
										part.Size = UDim2.fromOffset(26 * easeOut2, 26)
										part.ImageTransparency = part.Image == "" and 1 or 0
										part.BackgroundTransparency = part.Image == "" and 0 or 1
									else
										part.Position = UDim2.new(
											base.X.Scale,
											base.X.Offset + v47,
											base.Y.Scale,
											base.Y.Offset + v48
										)
										part.Rotation = rotation
										part.ImageTransparency = 1 - math.clamp(v44 / 0.06, 0, 1)
									end
								end

								if v46 >= 0 and not v32.seated then
									v32.seated = true
									v32.ring.Visible = true
									RoundEndAudio.weaponTile()
									GearSound.unlock(v32.slot)
								end

								local v47 = math.max(0, v46)

								local v48 = math.clamp((v46 - 0.04) / 0.14, 0, 1)
								v32.tag.TextTransparency = 1 - v48
								v32.tagPop.Scale = 1 + 0.9 * (1 - Style.easeOut(v48))
								v32.flash.BackgroundTransparency = v46 < 0 and 1
									or math.clamp(v47 / 0.3, 0, 1) * 0.65 + 0.35
								local stroke2 = v32.stroke
								local color4

								if v46 < 0 then
									color4 = v32.colour
								else
									color4 = Style.WHITE:Lerp(v32.colour, (math.clamp(v47 / 0.35, 0, 1)))
								end

								stroke2.Color = color4
								local transparency4 = math.clamp(v47 / 0.4, 0, 1)
								v32.ring.Size = UDim2.fromOffset(
									117.6 * Style.easeOut(transparency4),
									117.6 * Style.easeOut(transparency4)
								)
								v32.ringStroke.Thickness = math.max(1, (1 - transparency4) * 4)
								v32.ringStroke.Transparency = transparency4
								local ring = v32.ring
								ring.Visible = v46 >= 0 and transparency4 < 1
							end

							v23 = v28
							return true
						end
					end
				end
			end)
		end

		local function show(data2)
			v2 = true
			local v4 = data2.kind == "level" or data2.kind == "vehicle"
			local v5 = nil
			local v6 = nil
			local v7 = nil
			local v8 = nil
			local names2 = {}

			if data2.kind == "level" then
				v5 = tostring(data2.to)

				v7 = "LEVEL " .. data2.to
				names2 = opened(player, data2.from, data2.to)
				v6 = "LEVEL UP"
			elseif data2.kind == "vehicle" then
				local VehicleLoadouts = require(Game:WaitForChild("VehicleLoadouts"))
				local vehicle = VehicleLoadouts.vehicle(data2.id)
				v5 = tostring(data2.to)
				v6 = "VEHICLE LEVEL UP"

				if vehicle then
					v7 = vehicle.name
				else
					v7 = string.upper(data2.id)
				end

				for _, v9 in VehicleLoadouts.opened(data2.id, data2.from, data2.to) do
					if #names2 < 3 then
						table.insert(names2, v9.name)
					end
				end
			elseif data2.kind == "quest" then
				v7 = string.upper(data2.name)
				v8 = data2.scrap
				v6 = "QUEST COMPLETE"
				v5 = ""
			elseif data2.kind == "gold" then
				v7 = names[data2.gun] or string.upper(data2.gun)
				v6 = "GOLD CAMO EARNED"
				v5 = ""
			elseif data2.kind == "diamond" then
				v7 = "EVERY " .. WeaponSkins.className(data2.gun)
				v6 = "DIAMOND CAMO EARNED"
				v5 = ""
			elseif data2.kind == "badge" then
				v5 = CareerData.NUMERALS[data2.tier]

				v7 = data2.track.name .. " " .. v5
				v8 = data2.track.scrap[data2.tier]
				v6 = "BADGE EARNED"
			end

			local v9 = not v4 and 0.35 or SWEEP_LEAD
			local v10 = (v4 and 4.4 or 3.6) + #names2 * 0.5
			local v11 = if v4 then Style.HAZARD else color
			local v12 = if v4 then Style.STEEL else color2

			local vector2 = Vector2.new(44, 127)

			local frame = Style.frame(region, "Award", UDim2.fromScale(1, 1))

			local folder = Style.frame(
				frame,
				"Plate",
				UDim2.fromOffset(0, 46),
				UDim2.fromOffset(180, 104),
				Vector2.new(0.5, 0)
			)
			folder.ClipsDescendants = true
			local frame2 = Style.frame(
				folder,
				"Inside",
				UDim2.fromOffset(320, 46),
				UDim2.fromScale(0.5, 0.5),
				Vector2.new(0.5, 0.5)
			)
			local fill = Style.fill(frame2, "Back", Style.PANEL, UDim2.fromScale(1, 1))
			fill.BackgroundTransparency = 0.12
			Style.corner(fill, 3)
			local fill_2 = Style.fill(frame2, "Edge", v11, UDim2.new(0, 3, 1, 0))
			fill_2.Position = UDim2.fromOffset(0, 0)
			local tape = Style.tape(frame2, "Tape", UDim2.fromOffset(0, 3), 320, 10)
			tape.Position = UDim2.fromOffset(0, 43)
			local fill2 = Style.fill(frame2, "Flash", Color3.new(1, 1, 1), UDim2.fromScale(1, 1))
			fill2.BackgroundTransparency = 1
			fill2.ZIndex = 5

			local label2 = word(frame2, "Title", v6, 12, Style.HAZARD) -- inferred equivalent call
			local label3 = word(frame2, "Name", v7, 22, Style.WHITE) -- inferred equivalent call
			local v13, v14, parent, uiScale

			if v8 then
				local thousands = Style.thousands(v8)
				local hazard = Style.HAZARD
				v13 = Style.label(frame2, "Amount", thousands, 18, Style.FONT, 1.5)
				v13.TextColor3 = hazard
				v13.TextTransparency = 1
				v13.ZIndex = 2
				local uiStroke = v13:FindFirstChildOfClass("UIStroke")

				if uiStroke then
					uiStroke.Transparency = 1
				end

				v13.AnchorPoint = Vector2.new(1, 0)
				v13.Position = UDim2.fromOffset(310, 5)
				local v15 = data2.kind == "quest" and "CLAIM IN QUESTS" or "CLAIM IN LOBBY"
				local muted = Style.MUTED
				v14 = Style.label(frame2, "Claim", v15, 10, Style.FONT, 1.5)
				v14.TextColor3 = muted
				v14.TextTransparency = 1
				v14.ZIndex = 2
				local uiStroke2 = v14:FindFirstChildOfClass("UIStroke")

				if uiStroke2 then
					uiStroke2.Transparency = 1
				end

				v14.AnchorPoint = Vector2.new(1, 0)
				v14.Position = UDim2.fromOffset(310, 27)
				parent = Style.nut(frame2, 15)
				parent.AnchorPoint = Vector2.new(1, 0)
				parent.ZIndex = 2
				uiScale = Instance.new("UIScale")
				uiScale.Scale = 0
				uiScale.Parent = parent
			else
				v13 = nil
				parent = nil
				v14 = nil
				uiScale = nil
			end

			local v15 = {}

			for k, v16 in names2 do
				local v17 = "Unlock" .. k
				local v18 = if k == 1 then Style.HAZARD else Style.WHITE
				local label = word(frame, v17, v16, 13, v18) -- inferred equivalent call
				label.AnchorPoint = Vector2.new(0.5, 0)
				label.Position = UDim2.fromOffset(180, (k - 1) * 17 + 156)
				table.insert(v15, label)
			end

			local folder2 = Style.frame(
				frame,
				"Medal",
				UDim2.fromOffset(54, 54),
				UDim2.fromOffset(vector2.X, vector2.Y),
				Vector2.new(0.5, 0.5)
			)
			folder2.ZIndex = 3
			local uiScale2 = Instance.new("UIScale")
			uiScale2.Scale = 2.2
			uiScale2.Parent = folder2
			local box = Style.box(folder2, "Diamond", Color3.new(1, 1, 1), UDim2.fromScale(0.72, 0.72), 4, 2)
			box.AnchorPoint = Vector2.new(0.5, 0.5)
			box.Position = UDim2.fromScale(0.5, 0.5)
			box.Rotation = 45
			local uiGradient = Instance.new("UIGradient")
			local v16

			if v4 then
				v16 = Color3.fromRGB(255, 246, 200)
			else
				v16 = Color3.fromRGB(255, 238, 190)
			end

			uiGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, v11),
				ColorSequenceKeypoint.new(0.4, v11),
				ColorSequenceKeypoint.new(0.5, v16),
				ColorSequenceKeypoint.new(0.6, v11),
				ColorSequenceKeypoint.new(1, v11)
			})

			uiGradient.Offset = Vector2.new(-1, 0)
			uiGradient.Parent = box
			local box2 = Style.box(folder2, "Inner", v12, UDim2.fromScale(0.46, 0.46), 3, 1.5)
			box2.AnchorPoint = Vector2.new(0.5, 0.5)
			box2.Position = UDim2.fromScale(0.5, 0.5)
			box2.Rotation = 45
			local label = Style.label(folder2, "Numeral", v5, #v5 >= 3 and 13 or 17, Style.FONT, 1.5)
			label.AutomaticSize = Enum.AutomaticSize.None
			label.Size = UDim2.fromScale(1, 1)

			local uiStrokes = {}
			local v17 = { box, box2 }

			for _, uiStroke in folder2:GetDescendants() do
				if uiStroke:IsA("UIStroke") then
					table.insert(uiStrokes, uiStroke)
				end
			end

			local function medalAlpha(p: number) -- 4 equivalent calls inferred from this helper
				for _, v18 in v17 do
					v18.BackgroundTransparency = p
				end

				label.TextTransparency = p

				for _, v18 in uiStrokes do
					v18.Transparency = p
				end
			end

			medalAlpha(1) -- inferred equivalent call

			if v4 then
				uiGradient.Enabled = false
				box.BackgroundColor3 = Style.STEEL_LIGHT
			end

			local frame3 = Style.frame(
				frame,
				"Ring",
				UDim2.fromOffset(0, 0),
				UDim2.fromOffset(vector2.X, vector2.Y),
				Vector2.new(0.5, 0.5)
			)
			Style.corner(frame3, 999)
			local stroke = Style.stroke(frame3, 5, 1, Style.HAZARD)
			local v18 = {}

			for i = 1, v4 and 12 or 9 do
				local v19 = 4 + math.random() * 5
				local fill3 = Style.fill
				local v20

				if i % 3 == 0 then
					v20 = Style.HAZARD
				else
					v20 = if v4 then Style.WHITE else color
				end

				local frame4 = fill3(
					frame,
					"Shard",
					v20,
					UDim2.fromOffset(v19, v19),
					UDim2.fromOffset(vector2.X, vector2.Y),
					Vector2.new(0.5, 0.5)
				)
				frame4.Visible = false
				frame4.ZIndex = 4
				frame4.Rotation = math.random() * 90
				local v21 = math.random() * 2 * 3.141592653589793
				local v22 = 130 + math.random() * 120
				table.insert(v18, {
					frame = frame4,
					v = Vector2.new(math.cos(v21), math.sin(v21) - 0.45) * v22,
					spin = (math.random() * 2 - 1) * 540,
					r0 = frame4.Rotation
				})
			end

			if v4 then
				RoundEndAudio.sweep()
			else
				ClaimAudio.awardIn(0.35)
			end

			local now = os.clock()
			local v19 = false
			local v20 = false
			local v21 = 0
			local v22 = nil

			local v23 = math.max(0.75, (#v15 - 1) * 0.3 + 0.45 + 0.22) + 0.05
			local v24 = false
			local v25 = nil
			local function placeNut() -- 2 equivalent calls inferred from this helper
				if v13 and parent then
					local v26 = 306 - v13.AbsoluteSize.X / math.max(0.01, Style.scale())

					if v26 ~= v25 then
						v25 = v26
						parent.Position = UDim2.fromOffset(v26, 8)
					end
				end
			end
			Style.animate(frame, function(_, p: number): boolean
				local v26 = p - now

				local v27 = math.clamp((v26 - v10) / 0.35, 0, 1)

				if v27 >= 1 then
					frame:Destroy()
					v2 = false
					task.defer(fn)
					return false
				else
					local v28

					if v27 == 0 then
						v28 = v23 <= v26 - v9
					else
						v28 = false
					end

					if v28 and v24 then
						placeNut() -- inferred equivalent call
						return true
					else
						local v29 = -8 * Style.easeIn(v27)
						frame.Position = UDim2.fromOffset(0, v29)

						local v30 = math.clamp((v26 - 0.06) / 0.28, 0, 1)
						folder.Size = UDim2.fromOffset(320 * Style.easeOut(v30), 46)

						if v26 < v9 then
							local v31 = v26 / v9

							if v4 then
								local v32 = math.clamp((v31 - 0.55) / 0.45, 0, 1)
								uiScale2.Scale = 2.2 - 1.2 * Style.easeIn(v32)
								medalAlpha(1 - math.clamp(v31 / 0.3, 0, 1)) -- inferred equivalent call
							else
								uiScale2.Scale = 2.2 - 1.2 * Style.easeIn(v31)
								medalAlpha(1 - math.clamp(v31 / 0.4, 0, 1)) -- inferred equivalent call
							end

							return true
						else
							if not v19 then
								v19 = true

								if v4 then
									RoundEndAudio.levelUp(true)
									ClaimAudio.awardSlam()
									box.BackgroundColor3 = Color3.new(1, 1, 1)
									uiGradient.Enabled = true
								else
									ClaimAudio.awardSlam()
								end

								for _, v31 in v18 do
									v31.frame.Visible = true
								end
							end

							local v31 = v26 - v9

							uiScale2.Scale = 1 - 0.1 * (1 - Style.easeOut((math.clamp(v31 / 0.2, 0, 1))))
							medalAlpha(v27) -- inferred equivalent call
							uiGradient.Offset = Vector2.new(math.clamp((v31 - 0.08) / 0.45, 0, 1) * 2 + -1, 0)
							fill2.BackgroundTransparency = math.clamp(v31 / 0.25, 0, 1) * 0.55 + 0.45

							local transparency = math.clamp(v31 / 0.4, 0, 1)
							local v32 = (v4 and 150 or 120) * Style.easeOut(transparency)
							frame3.Size = UDim2.fromOffset(v32, v32)
							stroke.Thickness = math.max(1, (1 - transparency) * 5)
							stroke.Transparency = transparency

							for _, v37 in v18 do
								if not v37.frame.Visible then
									continue
								end

								local v38 = vector2 + v37.v * v31 + Vector2.new(0, 420 * v31 * v31)
								v37.frame.Position = UDim2.fromOffset(v38.X, v38.Y)
								v37.frame.Rotation = v37.r0 + v37.spin * v31
								v37.frame.BackgroundTransparency = math.clamp((v31 - 0.25) / 0.35, 0, 1)

								if v31 > 0.6 then
									v37.frame.Visible = false
								end
							end

							local function slideIn(instance, p2: number, p3: number, p4: number, value: number?)
								local v37 = math.clamp((v31 - p2) / 0.22, 0, 1)
								local easeOut = Style.easeOut(v37)
								instance.Position = UDim2.fromOffset(p3 - (value or 14) * (1 - easeOut), p4)
								instance.TextTransparency = math.max(1 - v37, v27)
								local uiStroke = instance:FindFirstChildOfClass("UIStroke")

								if uiStroke then
									uiStroke.Transparency = math.max(1 - v37 * 0.75, v27)
								end
							end
							slideIn(label2, 0.03, 58, 5)
							slideIn(label3, 0.09, 58, 17)

							tape.Size = UDim2.fromOffset(320 * Style.easeOut((math.clamp((v31 - 0.05) / 0.4, 0, 1))), 3)

							for k, v37 in v15 do
								local v38 = (k - 1) * 0.3 + 0.45

								if v38 <= v31 and v21 < k then
									v21 = k
									ClaimAudio.awardTick()
								end

								slideIn(v37, v38, 180, (k - 1) * 17 + 156, 0)
							end

							if v13 and v14 and parent and uiScale then
								local v37 = math.clamp((v31 - 0.42) / 0.2, 0, 1)

								if v37 > 0 and not v20 then
									v20 = true
									ClaimAudio.awardTick()
								end

								v13.TextTransparency = 1 - v37
								v14.TextTransparency = 1 - math.clamp((v31 - 0.5) / 0.2, 0, 1)

								for _, v38 in { v13, v14 } do
									local uiStroke = v38:FindFirstChildOfClass("UIStroke")

									if uiStroke then
										uiStroke.Transparency = (1 - v37) * 0.75 + 0.25
									end
								end

								uiScale.Scale = Style.pop(v37)
								placeNut() -- inferred equivalent call
							end

							if v27 > 0 then
								if not v22 then
									local v37 = {}

									for _, descendant in folder:GetDescendants() do
										if descendant:IsA("TextLabel") then
											table.insert(v37, {
												descendant,
												"TextTransparency",
												descendant.TextTransparency
											})
										elseif descendant:IsA("ImageLabel") then
											table.insert(v37, {
												descendant,
												"ImageTransparency",
												descendant.ImageTransparency
											})
										elseif descendant:IsA("UIStroke") then
											table.insert(v37, { descendant, "Transparency", descendant.Transparency })
										end

										if descendant:IsA("GuiObject") then
											table.insert(v37, {
												descendant,
												"BackgroundTransparency",
												descendant.BackgroundTransparency
											})
										end
									end

									v22 = v37
								end

								for _, v37 in v22 do
									v37[1][v37[2]] = v37[3] + (1 - v37[3]) * v27
								end
							end

							v24 = v28
							return true
						end
					end
				end
			end)
		end

		fn = function()
			if v2 or v3 then
				return
			end

			local v4 = table.remove(v, 1)

			if v4 then
				if v4.kind == "weapon" then
					showWeapon(v4.gun, v4.from, v4.to)
				else
					show(v4)
				end
			end
		end

		data.onMenu(function(flag: boolean)
			v3 = flag

			if not flag then
				fn()
			end
		end)

		local function push(p) -- 7 equivalent calls inferred from this helper
			if #v >= 4 then
				table.remove(v, 1)
			end

			table.insert(v, p)
			fn()
		end

		badge.OnClientEvent:Connect(function(p, p2)
			local track, tier = CareerData.find(tostring(p) .. ":" .. tostring(p2))
			assert(track and tier, "[BadgeAward] unknown badge " .. tostring(p) .. ":" .. tostring(p2))
			push({ kind = "badge", track = track, tier = tier }) -- inferred equivalent call
		end)

		levelUp.OnClientEvent:Connect(function(from, value)
			local v4 = type(from) == "number" and type(value) == "number" and from < value
			assert(v4, "[BadgeAward] bad level up " .. tostring(from) .. " -> " .. tostring(value))

			for _, v5 in v do
				if v5.kind == "level" then
					v5.to = math.max(v5.to, value)
					return
				end
			end

			push({ kind = "level", from = from, to = value }) -- inferred equivalent call
		end)

		quest.OnClientEvent:Connect(function(name, value, value2)
			local v4 = type(name) == "string" and type(value) == "number" and type(value2) == "number"
			assert(v4, "[BadgeAward] bad quest " .. tostring(name))
			push({ kind = "quest", name = name, xp = value, scrap = value2 }) -- inferred equivalent call
		end)

		remotes:WaitForChild("GoldCamo").OnClientEvent:Connect(function(gun)
			assert(type(gun) == "string", "[BadgeAward] bad gold camo " .. tostring(gun))
			push({ kind = "gold", gun = gun }) -- inferred equivalent call
		end)

		remotes:WaitForChild("DiamondCamo").OnClientEvent:Connect(function(gun)
			assert(type(gun) == "string", "[BadgeAward] bad diamond camo " .. tostring(gun))
			push({ kind = "diamond", gun = gun }) -- inferred equivalent call
		end)

		weaponLevel.OnClientEvent:Connect(function(gun, value, value2)
			local v4 = type(gun) == "string" and type(value) == "number" and type(value2) == "number" and value < value2
			assert(v4, "[BadgeAward] bad weapon level " .. tostring(gun))

			for _, v5 in v do
				if v5.kind == "weapon" and v5.gun == gun then
					v5.to = math.max(v5.to, value2)
					return
				end
			end

			push({ kind = "weapon", gun = gun, from = value, to = value2 }) -- inferred equivalent call
		end)

		remotes:WaitForChild("VehicleLevel").OnClientEvent:Connect(function(id, value, value2)
			local v4 = type(id) == "string" and type(value) == "number" and type(value2) == "number" and value < value2
			assert(v4, "[BadgeAward] bad vehicle level " .. tostring(id))

			for _, v5 in v do
				if v5.kind == "vehicle" and v5.id == id then
					v5.to = math.max(v5.to, value2)
					return
				end
			end

			push({ kind = "vehicle", id = id, from = value, to = value2 }) -- inferred equivalent call
		end)
	end
}