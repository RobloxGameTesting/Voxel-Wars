local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Style = require(script.Parent.Style)
local ClaimFx = require(script.Parent.ClaimFx)
local ClaimAudio = require(script.Parent.ClaimAudio)
local ToolIcon = require(script.Parent.ToolIcon)
local QuestIcons = require(script.Parent.QuestIcons)
local ToolTemplates = ReplicatedStorage:WaitForChild("ToolTemplates")

local QuestClaimShow = {}

local color = Color3.fromRGB(255, 236, 190)

local v = { Style.HAZARD, Style.ORANGE, Color3.fromRGB(255, 226, 150) }

local color2 = Color3.fromRGB(58, 132, 66)

local v2 = {
	daily = { count = 0.65, hold = 0.9, rings = 2, salvos = 1 },
	weekly = { count = 0.95, hold = 1.1, rings = 3, salvos = 1 },
	bonus = { count = 1.4, hold = 1.5, rings = 4, salvos = 2 }
}

local v3 = nil
local v4 = {}
local flag = false

local function layerOf(p)
	if v3 then
		return v3
	end

	local layer = Style.layer(p, "QuestClaimShow", 29, true)
	layer.Enabled = false
	layer.ChildAdded:Connect(function()
		layer.Enabled = true
	end)
	layer.ChildRemoved:Connect(function()
		layer.Enabled = #layer:GetChildren() > 0
	end)
	v3 = layer
	return layer
end

local function unitOf(viewportSize: Vector2) -- 2 equivalent calls inferred from this helper
	return (math.clamp(viewportSize.Y / 22.5, 14, 48))
end

local function centreOn(p, p2) -- 5 equivalent calls inferred from this helper
	return p2.AbsolutePosition + p2.AbsoluteSize / 2 - p.AbsolutePosition
end

local function flyHome(p, vector2: Vector2, p2, p3: number, p4: number, fn, fn2)
	local v5 = {}

	for i = 1, p3 do
		local frame = fn()
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.fromOffset(vector2.X, vector2.Y)
		frame.ZIndex = 7
		local v6 = math.random() * 2 * 3.141592653589793
		table.insert(v5, {
			frame = frame,
			v = Vector2.new(math.cos(v6), math.sin(v6) - 0.5) * p4 * (3 + math.random() * 3),
			delay = (i - 1) * 0.04,
			spin = (math.random() * 2 - 1) * 540
		})
	end

	local count = 0
	local now = os.clock()
	Style.animate(v5, function(_, p5: number): boolean
		local v6 = p5 - now
		local v7 = centreOn(p, p2) -- inferred equivalent call

		for i = #v5, 1, -1 do
			local v8 = v5[i]
			local v9 = math.min(v6, 0.2)
			local v10 = vector2 + v8.v * v9 * (1 - v9 / 0.4)
			local v11 = math.clamp((v6 - v8.delay - 0.2) / 0.46, 0, 1)
			local easeIn = Style.easeIn(v11)
			local v12 = v10:Lerp(v7, 0.5) - Vector2.new(0, p4 * 1.5)
			local lerped = v10:Lerp(v12, easeIn):Lerp(v12:Lerp(v7, easeIn), easeIn)
			v8.frame.Position = UDim2.fromOffset(lerped.X, lerped.Y)
			v8.frame.Rotation = v8.spin * v6

			if not (v11 >= 1) then
				continue
			end

			v8.frame:Destroy()
			table.remove(v5, i)
			count += 1
			fn2(count / p3)
		end

		return #v5 > 0
	end)
end

local function bump(parent)
	local claimPop = parent:FindFirstChild("ClaimPop")

	if not claimPop then
		claimPop = Instance.new("UIScale")
		claimPop.Name = "ClaimPop"
		claimPop.Parent = parent
	end

	claimPop.Scale = 1.2
	Style.animate(claimPop, function(p: number, _): boolean
		claimPop.Scale = math.max(1, claimPop.Scale - p * 1.4)
		return claimPop.Scale > 1
	end)
end

local function word(p, p2: string, p3: string, p4: number, textColor: Color3, p5: number) -- 3 equivalent calls inferred from this helper
	local label = Style.label(p, p2, p3, p4, Style.FONT, p5)
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.TextColor3 = textColor
	return label
end

local function drawPicture(p, quest, color3: Color3)
	if not quest.tool then
		QuestIcons.draw(p, quest.icon, color3)
		return nil
	end

	local tool = ToolTemplates:FindFirstChild(quest.tool)
	assert(tool and tool:IsA("Tool"), "[QuestClaimShow] no tool " .. tostring(quest.tool))
	local v5 = ToolIcon.make(tool, p)
	v5.Size = UDim2.fromScale(1, 1)
	local currentCamera = v5.CurrentCamera
	local boundingBox = v5:FindFirstChildOfClass("Model"):GetBoundingBox()
	local v6 = currentCamera.CFrame.Position - boundingBox.Position
	return function(p2: number)
		local v7 = math.sin(p2 * 0.7) * 0.9
		currentCamera.CFrame = CFrame.lookAt(
			boundingBox.Position + CFrame.Angles(0, v7, 0):VectorToWorldSpace(v6),
			boundingBox.Position
		)
	end
end

local v5 = {}
local fn = nil

local v6 = nil
local function takeDown()
	if v6 then
		v6()
		v6 = nil
	end

	for _, v7 in v5 do
		v7:Destroy()
	end

	v5 = {}
	ClaimAudio.hush(0)
	flag = false
end

local fn2

local function play(data)
	flag = true
	local v7 = v3
	local quest = data.quest
	local v8 = v2[data.tier]
	assert(v8, "[QuestClaimShow] no tier " .. tostring(data.tier))
	local v9 = false
	local v10 = false
	local function landNow() -- 2 equivalent calls inferred from this helper
		if not v9 then
			v9 = true
			data.landed()
		end
	end
	local function scrapNow() -- 3 equivalent calls inferred from this helper
		if not v10 then
			v10 = true
			data.scrapIn()
		end
	end
	fn = function()
		landNow() -- inferred equivalent call
		scrapNow() -- inferred equivalent call
	end

	local viewportSize = workspace.CurrentCamera.ViewportSize
	local v11 = unitOf(viewportSize) -- inferred equivalent call
	local scale = math.min(math.max(v11 / 32, 0.7), viewportSize.Y * 0.83 / 420, viewportSize.X / 640)
	local halfViewportSize = viewportSize / 2
	local vector2 = Vector2.new(320, 168)
	local v12 = halfViewportSize + Vector2.new(0, scale * -42)
	local v13 = QuestIcons.COLOR[quest.cat] or Style.STEEL_LIGHT
	local v14 = quest.tool and 330 or 176

	local frame = Style.frame(v7, "Show", UDim2.fromScale(1, 1))
	v5 = { frame }
	local fill = Style.fill(frame, "Dim", Style.INK, UDim2.fromScale(1, 1))
	fill.BackgroundTransparency = 1
	local catch = Instance.new("TextButton")
	catch.Name = "Catch"
	catch.Text = ""
	catch.BackgroundTransparency = 1
	catch.Size = UDim2.fromScale(1, 1)
	catch.Modal = true
	catch.Selectable = false
	catch.Parent = frame
	local fill2 = Style.fill(
		frame,
		"BarTop",
		Color3.new(0, 0, 0),
		UDim2.fromScale(1, 0.085),
		UDim2.fromScale(0, -0.085)
	)
	local fill3 = Style.fill(frame, "BarBottom", Color3.new(0, 0, 0), UDim2.fromScale(1, 0.085), UDim2.fromScale(0, 1))

	local frame2 = Style.frame(
		frame,
		"Stage",
		UDim2.fromOffset(640, 420),
		UDim2.fromOffset(halfViewportSize.X, halfViewportSize.Y),
		Vector2.new(0.5, 0.5)
	)
	frame2.ZIndex = 2
	local uiScale = Instance.new("UIScale")
	uiScale.Scale = scale
	uiScale.Parent = frame2

	local function toStage(vector2_2: Vector2) -- 3 equivalent calls inferred from this helper
		return (vector2_2 - halfViewportSize) / scale + Vector2.new(320, 210)
	end

	local frame3 = Style.frame(frame2, "Back", UDim2.fromOffset(0, 0), UDim2.fromOffset(vector2.X, vector2.Y))
	local glow = ClaimFx.glow(frame3, 480, v13)
	glow.ImageTransparency = 1
	local image = ClaimFx.image(frame3, "Flare", ClaimFx.GLOW, v13, 0, UDim2.fromScale(0.5, 0.5))
	image.ImageTransparency = 1
	local image2 = ClaimFx.image(frame3, "Core", ClaimFx.GLOW, color, 0, UDim2.fromScale(0.5, 0.5))
	image2.ImageTransparency = 1
	local frame4 = Style.frame(frame2, "Embers", UDim2.fromScale(1, 1))

	local v15 = {}
	local v16 = 0

	local box = Style.box(frame2, "Emblem", v13:Lerp(Style.INK, 0.72), UDim2.fromOffset(v14, 176), 4, 3)
	box.AnchorPoint = Vector2.new(0.5, 0.5)
	box.ZIndex = 3
	local uiScale2 = Instance.new("UIScale")
	uiScale2.Parent = box
	Style.tape(box, "Tape", UDim2.new(1, 0, 0, 6), v14, 12)
	local frame5 = Style.frame
	local v17

	if quest.tool then
		v17 = UDim2.fromOffset(v14 - 16, 152)
	else
		v17 = UDim2.fromOffset(120, 120)
	end

	local v18 = drawPicture(frame5(box, "Picture", v17, UDim2.new(0.5, 0, 0.5, 3), Vector2.new(0.5, 0.5)), quest, v13)

	local function cardPlace()
		local v19 = data.from()

		if not v19 then
			return nil, 0.5
		end

		return toStage(centreOn(v7, v19)), (math.clamp(v19.AbsoluteSize.Y / (scale * 176), 0.1, 1)) -- inferred equivalent call
	end

	local v19 = data.from()
	local v20, scale2

	if v19 then
		v20 = toStage(centreOn(v7, v19)) -- inferred equivalent call
		scale2 = math.clamp(v19.AbsoluteSize.Y / (scale * 176), 0.1, 1)
	else
		scale2 = 0.5
	end

	local v21 = v20 or vector2
	box.Position = UDim2.fromOffset(v21.X, v21.Y)
	uiScale2.Scale = scale2

	local frame6 = Style.frame(
		frame2,
		"Words",
		UDim2.fromOffset(640, 420),
		UDim2.fromScale(0.5, 0.5),
		Vector2.new(0.5, 0.5)
	)
	frame6.ZIndex = 4
	local uiScale3 = Instance.new("UIScale")
	uiScale3.Parent = frame6
	local parent = word(frame6, "Kind", "QUEST COMPLETE", 50, Style.HAZARD, 3) -- inferred equivalent call
	parent.Position = UDim2.fromOffset(320, 30)
	parent.Visible = false
	local uiScale4 = Instance.new("UIScale")
	uiScale4.Parent = parent
	local parent2 = word(frame6, "Name", string.upper(quest.name), 36, Style.WHITE, 2) -- inferred equivalent call
	parent2.Position = UDim2.fromOffset(320, 288)
	parent2.Visible = false
	local uiScale5 = Instance.new("UIScale")
	uiScale5.Parent = parent2

	local v22 = data.scrap > 0

	local frame7 = Style.frame(
		frame6,
		"Rewards",
		UDim2.fromOffset(v22 and 442 or 214, 54),
		UDim2.fromOffset(320, 352),
		Vector2.new(0.5, 0.5)
	)
	frame7.Visible = false
	local uiScale6 = Instance.new("UIScale")
	uiScale6.Parent = frame7
	local function rewardPlate(p: number, p2: string, textColor: Color3)
		local box2 = Style.box(frame7, "Reward", Style.INK, UDim2.fromOffset(214, 54), 3, 2)
		box2.Position = UDim2.fromOffset(p, 0)
		local label = word(box2, "Amount", p2, 34, textColor, 0) -- inferred equivalent call
		label.Position = UDim2.fromScale(0.5, 0.5)
		return label
	end

	local v23 = rewardPlate(0, "0 XP", Style.HAZARD)
	local v24

	if v22 then
		v24 = rewardPlate(228, "0", Style.WHITE)
		v24.Position = UDim2.new(0.5, 16, 0.5, 0)
		local nut = Style.nut(v24.Parent, 30)
		nut.AnchorPoint = Vector2.new(0, 0.5)
		nut.Position = UDim2.new(0, 16, 0.5, 0)
	else
		v24 = nil
	end

	local function writeCount(p: number) -- 3 equivalent calls inferred from this helper
		v23.Text = Style.thousands((math.floor(data.xp * p + 0.5))) .. " XP"

		if v24 then
			v24.Text = Style.thousands((math.floor(data.scrap * p + 0.5)))
		end
	end

	local box2 = Style.box(box, "Stamp", color2, UDim2.fromOffset(64, 64), 64, 3)
	box2.AnchorPoint = Vector2.new(0.5, 0.5)
	box2.Position = UDim2.new(1, -8, 1, -8)
	box2.ZIndex = 3
	box2.Visible = false
	local uiScale7 = Instance.new("UIScale")
	uiScale7.Parent = box2
	data.drawTick(box2, 42, 32, 32, Style.WHITE)

	local blurEffect = Instance.new("BlurEffect")
	blurEffect.Size = 0
	blurEffect.Parent = workspace.CurrentCamera
	table.insert(v5, blurEffect)

	local now = os.clock()
	local v25 = false
	local v26 = false
	local v27 = false
	local v28 = false
	local v29 = math.clamp(math.floor(v8.count * 18), 8, 22)
	local v30 = 0
	local v31 = nil
	local v32 = vector2
	local v40 = 1
	local v41 = nil
	local v42 = 0.5

	local function land(flag2: boolean)
		v28 = true
		writeCount(1) -- inferred equivalent call
		box2.Visible = true
		uiScale7.Scale = 2.4

		if not flag2 then
			ClaimAudio.countDone()
			ClaimAudio.purchaseLand()
			local v43 = halfViewportSize + Vector2.new(0, scale * 142)
			ClaimFx.sparks(v7, v43, 16, v11 * 0.8, 0.5)

			if v8.salvos > 1 then
				ClaimFx.salvo(v7, v12, v11)
				ClaimFx.ring(v7, v12, v11 * 18, v11 * 0.4, Style.HAZARD, 0.55)
			end
		end
	end

	local v43 = nil
	local function leave(p: number)
		if v31 then
			return
		end

		if v43 then
			v43()
		end

		if not v28 then
			v28 = true
			writeCount(1) -- inferred equivalent call
			box2.Visible = true
			uiScale7.Scale = 2.4
		end

		v31 = p
		catch.Visible = false
		catch.Modal = false
		v40 = uiScale2.Scale
		local v44 = data.from()
		local v45, v46

		if v44 then
			v45 = toStage(centreOn(v7, v44)) -- inferred equivalent call
			v46 = math.clamp(v44.AbsoluteSize.Y / (scale * 176), 0.1, 1)
		else
			v46 = 0.5
		end

		v41 = v45
		v42 = v46

		local v47 = halfViewportSize + Vector2.new(0, scale * 142)
		local v48 = scale * 114

		if data.levelPlate then
			flyHome(v7, v47 - Vector2.new(not v22 and 0 or v48, 0), data.levelPlate, 8, v11, function()
				local v49 = v11 * 0.4
				return Style.fill(v7, "Mote", Style.HAZARD, UDim2.fromOffset(v49, v49))
			end, function(_: number)
				bump(data.levelPlate)
			end)
		end

		if v22 and data.scrapPlate then
			local flag2 = true
			flyHome(
				v7,
				v47 + Vector2.new(v48, 0),
				data.scrapPlate,
				math.clamp(data.scrap // 100 + 6, 8, 16),
				v11,
				function()
					local nut = Style.nut(v7, 1)
					local v49 = v11 * (0.55 + math.random() * 0.25)
					nut.Size = UDim2.fromOffset(v49, v49)
					return nut
				end,
				function(p2: number)
					ClaimAudio.nut(p2)
					bump(data.scrapPlate)

					if flag2 then
						flag2 = false
						scrapNow() -- inferred equivalent call
					end
				end
			)
		else
			scrapNow() -- inferred equivalent call
		end
	end

	local function tapOut()
		local now2 = os.clock()

		if now2 - now >= 0.85 then
			leave(now2)
		end
	end
	catch.Activated:Connect(tapOut)

	local PadMenus = require(script.Parent:WaitForChild("PadMenus"))
	v43 = PadMenus.hold("questclaim", tapOut)
	v6 = v43

	ClaimAudio.rewardIn(0.5)
	local function step(p: number, p2: number): boolean
		local v44 = p2 - now
		local v45 = halfViewportSize

		local easeOut = Style.easeOut((math.clamp(v44 / 0.35, 0, 1)))
		local v46 = not v31 and 0 or math.clamp((p2 - v31) / 0.42, 0, 1)
		local v47 = easeOut * (1 - Style.easeIn(v46))
		fill.BackgroundTransparency = 1 - 0.7 * v47
		fill2.Position = UDim2.fromScale(0, -0.085 * (1 - v47))
		fill3.Position = UDim2.fromScale(0, 1 - 0.085 * v47)
		blurEffect.Size = 18 * v47
		ClaimAudio.hush(v47)

		if v44 < 0.5 then
			local smoothed = Style.smooth((math.min(1, v44 / 0.38)))
			local v48 = v21:Lerp(vector2, smoothed) - Vector2.new(0, math.sin(smoothed * 3.141592653589793) * 30)
			box.Position = UDim2.fromOffset(v48.X, v48.Y)
			uiScale2.Scale = scale2 + (1.25 - scale2) * smoothed
			local v49 = v44 / 0.5
			glow.ImageTransparency = 1 - 0.55 * v49 * v49
			image2.Size = UDim2.fromOffset(208 * v49 * v49, 88 * v49 * v49)
			image2.ImageTransparency = 1 - 0.8 * v49
		else
			local born = v44 - 0.5

			if not v25 then
				v25 = true
				ClaimAudio.rewardHit()
				ClaimFx.flash(v7, 0.55, 0.3, color)
				ClaimFx.ring(v7, v12, v11 * 18, v11 * 0.45, Style.HAZARD, 0.55)
				ClaimFx.ring(v7, v12, v11 * 11, v11 * 0.28, Style.WHITE, 0.45, 0.07)

				if v8.rings >= 3 then
					ClaimFx.ring(v7, v12, v11 * 24, v11 * 0.35, v13, 0.7, 0.12)
				end

				if v8.rings >= 4 then
					ClaimFx.ring(v7, v12, v11 * 30, v11 * 0.3, Style.HAZARD, 0.85, 0.2)
				end

				ClaimFx.salvo(v7, v12, v11)
			end

			glow.ImageTransparency = 1 - (math.sin(born * 3) * 0.06 + 0.42) * math.clamp(born / 0.25, 0, 1) * (1 - v46)
			local easeOut2 = Style.easeOut((math.clamp(born / 0.35, 0, 1)))
			local v49 = math.sin(born * 2.6) * 0.04 + 1
			image.Size = UDim2.fromOffset(560 * easeOut2 * v49, 240 * easeOut2 * v49)
			image.ImageTransparency = 1 - 0.45 * easeOut2 * (1 - v46)
			image2.Size = UDim2.fromOffset(260 * (0.8 + 0.2 * easeOut2) * v49, 110 * (0.8 + 0.2 * easeOut2) * v49)
			image2.ImageTransparency = 1 - 0.75 * easeOut2 * (1 - v46)

			if not v31 then
				v16 += p

				while v16 >= 0.08 do
					v16 -= 0.08
					local v50 = math.random(3, 7)
					local fill4 = Style.fill(frame4, "Ember", v[math.random(#v)], UDim2.fromOffset(v50, v50))
					fill4.AnchorPoint = Vector2.new(0.5, 0.5)
					table.insert(v15, {
						f = fill4,
						x = 320 + (math.random() * 2 - 1) * 240,
						y = 258 + math.random() * 40,
						v = 50 + math.random() * 70,
						sway = math.random() * 6,
						born = born
					})
				end
			end

			for i = #v15, 1, -1 do
				local v50 = v15[i]
				local v51 = born - v50.born

				if v51 >= 1.6 then
					v50.f:Destroy()
					table.remove(v15, i)
				else
					v50.f.Position = UDim2.fromOffset(v50.x + math.sin(v51 * 2 + v50.sway) * 10, v50.y - v50.v * v51)
					v50.f.BackgroundTransparency = math.max(0.15, v51 / 1.6)
					v50.f.Rotation = v51 * 90
				end
			end

			if not v31 then
				local scale3

				if born < 0.1 then
					scale3 = 1.25 - 0.33 * Style.easeIn(born / 0.1)
				else
					scale3 = 0.92 + 0.08 * Style.easeOut((born - 0.1) / 0.25)
				end

				uiScale2.Scale = scale3
				v32 = vector2 + Vector2.new(0, math.sin(born * 2.2) * 5)
				box.Position = UDim2.fromOffset(v32.X, v32.Y)
				local v51 = math.max(0, 1 - born / 0.28) * 10 * scale
				v45 += Vector2.new((math.random() * 2 - 1) * v51, (math.random() * 2 - 1) * v51)
			end

			if v18 then
				v18(born)
			end

			if born >= 0.12 then
				if not v26 then
					v26 = true
					parent.Visible = true
					ClaimAudio.press()
				end

				uiScale4.Scale = 1 + 0.8 * (1 - Style.easeOut((born - 0.12) / 0.14))
			end

			if born >= 0.26 then
				if not v27 then
					v27 = true
					parent2.Visible = true
					frame7.Visible = true
				end

				uiScale5.Scale = 1 + 0.45 * (1 - Style.easeOut((born - 0.26) / 0.16))
				uiScale6.Scale = 0.7 + 0.3 * Style.pop((born - 0.26) / 0.22)
			end

			if not v28 and born >= 0.36 then
				local v50 = (born - 0.36) / v8.count

				if v50 >= 1 then
					land(false)
				else
					local v51 = math.floor(v50 * v29)

					if v30 < v51 then
						v30 = v51
						writeCount(Style.easeOut(v50)) -- inferred equivalent call
						ClaimAudio.countTick(v51 / v29)
					end
				end
			end

			if uiScale7.Scale > 1 then
				uiScale7.Scale = math.max(1, uiScale7.Scale - p * 9)
			end

			if not v31 and v8.count + 0.36 + v8.hold <= born then
				leave(p2)
			end
		end

		frame2.Position = UDim2.fromOffset(v45.X, v45.Y)

		if not v31 then
			return true
		end

		local easeIn = Style.easeIn(v46)
		uiScale3.Scale = 1 - Style.easeOut((math.min(1, v46 * 2)))

		local lerped = v32:Lerp(v41 or v32, easeIn)
		box.Position = UDim2.fromOffset(lerped.X, lerped.Y)
		uiScale2.Scale = v40 + ((not v41 and 0 or v42) - v40) * easeIn

		if not (v46 >= 1) then
			return true
		end

		local v48

		if v41 then
			v48 = halfViewportSize + (v41 - Vector2.new(320, 210)) * scale
		else
			v48 = v12
		end

		takeDown()
		fn = nil
		landNow() -- inferred equivalent call
		ClaimAudio.badgeHome()
		ClaimFx.ring(v7, v48, v11 * 5, v11 * 0.22, Style.GOOD, 0.4)
		ClaimFx.sparks(v7, v48, 14, v11 * 0.7, 0.3)
		local v49 = table.remove(v4, 1)

		if v49 then
			task.defer(fn2, v49)
		end

		return false
	end

	Style.animate(frame, function(p: number, p2: number)
		local success, result = xpcall(step, debug.traceback, p, p2)

		if success then
			return result
		end

		local v44 = fn
		fn = nil
		takeDown()

		if v44 then
			v44()
		end

		error("[QuestClaimShow] " .. tostring(result))

		return result
	end)
end

fn2 = function(p)
	local success, result = xpcall(play, debug.traceback, p)

	if not success then
		local v7 = fn
		fn = nil
		takeDown()

		if v7 then
			v7()
		end

		error("[QuestClaimShow] " .. tostring(result))
	end
end

function QuestClaimShow.press(p, p2)
	local v7 = layerOf(p)
	local viewportSize = workspace.CurrentCamera.ViewportSize
	ClaimFx.spray(v7, centreOn(v7, p2), unitOf(viewportSize)) -- inferred equivalent call
	ClaimAudio.press()
end

function QuestClaimShow.play(p, p2)
	layerOf(p)

	if flag then
		table.insert(v4, p2)
	else
		fn2(p2)
	end
end

return QuestClaimShow