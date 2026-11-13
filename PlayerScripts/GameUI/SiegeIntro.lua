local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Style = require(script.Parent.Style)
local MapBuilder = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("MapBuilder"))
local WorldConfig = require(ReplicatedStorage.Voxel:WaitForChild("WorldConfig"))
local SpawnRaid = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("SpawnRaid"))
local GameConfig = require(ReplicatedStorage.Game:WaitForChild("GameConfig"))

local function window(p: number, p2: number, p3: number) -- 2 equivalent calls inferred from this helper
	return (math.clamp(math.min((p - p2) / 0.3, (p3 - p) / 0.3), 0, 1))
end

local function flat(vector3: Vector3) -- 2 equivalent calls inferred from this helper
	return (Vector3.new(vector3.X, 0, vector3.Z))
end

local function pads(name: string)
	local domination = ReplicatedStorage.Game:FindFirstChild("Domination")
	local beacons = MapBuilder.BEACONS
	local alive = SpawnRaid.parseAlive(domination and domination:GetAttribute("SpawnsAlive"), #beacons)
	local VOXEL_SIZE = WorldConfig.VOXEL_SIZE
	local origin = WorldConfig.ORIGIN
	local v = { mine = {}, theirs = {} }

	for k, beacon in beacons do
		if not alive[k] then
			continue
		end

		local v2 = origin + Vector3.new(
			(beacon.min.X + beacon.max.X + 1) * 0.5,
			beacon.max.Y + 1,
			(beacon.min.Z + beacon.max.Z + 1) * 0.5
		) * VOXEL_SIZE
		local v3 = if beacon.team == name then v.mine else v.theirs
		table.insert(v3, v2)
	end

	return v
end

local function middle(list) -- 2 equivalent calls inferred from this helper
	local total = Vector3.new(0, 0, 0)

	for _, item in list do
		total += item
	end

	return total / math.max(#list, 1)
end

local function enemyOf(name: string)
	for _, v in GameConfig.TEAMS do
		if v.name ~= name then
			return v.name
		end
	end

	error("SiegeIntro: no enemy team for " .. name)
end

local hazard = Style.HAZARD

local v = { 28, 24, 20, 16, 12, 8, 4 }
local function arrow(parent, position: Vector3)
	local siegeIntroPad = Instance.new("Attachment")
	siegeIntroPad.Name = "SiegeIntroPad"
	siegeIntroPad.Position = position
	siegeIntroPad.Parent = workspace.Terrain
	local siegeIntroPad2 = Instance.new("BillboardGui")
	siegeIntroPad2.Name = "SiegeIntroPad"
	siegeIntroPad2.Adornee = siegeIntroPad
	siegeIntroPad2.AlwaysOnTop = true
	siegeIntroPad2.LightInfluence = 0
	siegeIntroPad2.ResetOnSpawn = false
	siegeIntroPad2.Size = UDim2.fromOffset(32, 46)
	siegeIntroPad2.SizeOffset = Vector2.new(0, 0.5)
	siegeIntroPad2.Parent = parent
	local arrow2 = Instance.new("CanvasGroup")
	arrow2.Name = "Arrow"
	arrow2.BackgroundTransparency = 1
	arrow2.BorderSizePixel = 0
	arrow2.Size = UDim2.fromScale(1, 1)
	arrow2.Parent = siegeIntroPad2

	local function piece(p: number, p2: number, p3: number)
		for _, v2 in {
			{ 2, Style.INK, 1 },
			{ 0, hazard, 2 }
		} do
			local v3 = v2[1]
			local frame = Instance.new("Frame")
			frame.BorderSizePixel = 0
			frame.BackgroundColor3 = v2[2]
			frame.ZIndex = v2[3]
			frame.Position = UDim2.fromOffset((math.floor)(16 - p / 2) - v3, p2 - v3)
			frame.Size = UDim2.fromOffset(p + v3 * 2, p3 - p2 + v3 * 2)
			frame.Parent = arrow2
		end
	end
	piece(8, 3, 23)

	for k, v2 in v do
		local v3 = 21 + (k - 1) * 3
		piece(v2, v3, v3 + 3)
	end

	return { bb = siegeIntroPad2, att = siegeIntroPad, canvas = arrow2 }
end

local function group(playerGui, items, p: string, textColor: Color3)
	local siegeIntroWords = Instance.new("ScreenGui")
	siegeIntroWords.Name = "SiegeIntroWords"
	siegeIntroWords.IgnoreGuiInset = true
	siegeIntroWords.DisplayOrder = 999
	siegeIntroWords.ResetOnSpawn = false
	siegeIntroWords.Parent = playerGui
	local label = Style.label(siegeIntroWords, "Words", p, 112, Style.FONT, 0)
	label.AutomaticSize = Enum.AutomaticSize.None
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.fromScale(0.5, 0.24)
	label.Size = UDim2.fromScale(0.92, 0.17)
	label.TextScaled = true
	label.TextColor3 = textColor
	local uiTextSizeConstraint = Instance.new("UITextSizeConstraint")
	uiTextSizeConstraint.MaxTextSize = 112
	uiTextSizeConstraint.Parent = label
	Style.stroke(label, 4, 0, Style.INK)
	local marks = {}

	for _, item in items do
		table.insert(marks, arrow(playerGui, item + Vector3.new(0, 1.5, 0)))
	end

	return { gui = siegeIntroWords, word = label, marks = marks }
end

local function fade(data, p: number, now: number)
	local enabled = p > 0
	data.gui.Enabled = enabled
	local v2 = 1 - p
	data.word.TextTransparency = v2
	local uiStroke = data.word:FindFirstChildOfClass("UIStroke")

	if uiStroke then
		uiStroke.Transparency = v2
	end

	local v3 = math.sin(now * 5) * 4

	for _, mark in data.marks do
		mark.bb.Enabled = enabled

		if not enabled then
			continue
		end

		mark.bb.StudsOffset = Vector3.new(0, 0, 0)
		mark.bb.SizeOffset = Vector2.new(0, v3 / 46 + 0.5)
		mark.canvas.GroupTransparency = v2
	end
end

local function drop(p)
	for _, mark in p.marks do
		mark.bb:Destroy()
		mark.att:Destroy()
	end

	p.gui:Destroy()
end

return {
	mount = function(data)
		local player = data.player
		local playerGui = data.playerGui
		local v2 = false

		local function play(instance, cameraSubject, p: number)
			local v3 = p - workspace:GetServerTimeNow()

			if v2 or v3 < 2.5 or not player.Team then
				return
			end

			local humanoidRootPart = instance:WaitForChild("HumanoidRootPart", 5)

			if not humanoidRootPart then
				return
			end

			local name = player.Team.Name
			local v4 = pads(name)

			if #v4.mine == 0 or #v4.theirs == 0 then
				return
			end

			v2 = true
			local v5 = v3 / 9
			local v6 = middle(v4.mine) -- inferred equivalent call
			local v7 = middle(v4.theirs) -- inferred equivalent call
			local v8 = flat(v6 - v7) -- inferred equivalent call
			local v9 = not (v8.Magnitude > 1) and Vector3.new(0, 0, 1) or v8.Unit

			local v10 = v7 + v9 * 150 + Vector3.new(0, 110, 0)
			local v11 = v7 + v9 * 120 + Vector3.new(0, 92, 0)
			local v12 = v6 - v9 * 150 + Vector3.new(0, 110, 0)
			local v13 = v6 - v9 * 120 + Vector3.new(0, 92, 0)

			local siegeIntroCurtain = Instance.new("ScreenGui")
			siegeIntroCurtain.Name = "SiegeIntroCurtain"
			siegeIntroCurtain.IgnoreGuiInset = true
			siegeIntroCurtain.DisplayOrder = 1000
			siegeIntroCurtain.ResetOnSpawn = false
			local frame = Instance.new("Frame")
			frame.BackgroundColor3 = Color3.new(0, 0, 0)
			frame.BorderSizePixel = 0
			frame.Size = UDim2.fromScale(1, 1)
			frame.BackgroundTransparency = 0
			frame.Parent = siegeIntroCurtain
			siegeIntroCurtain.Parent = playerGui

			local v14 = group(playerGui, v4.theirs, "ATTACK ENEMY SPAWNS", Style.teamText(enemyOf(name)))
			local v15 = group(playerGui, v4.mine, "DEFEND YOUR SPAWNS", Style.teamText(name))
			v14.gui.Enabled = false

			v14.word.TextTransparency = 1
			local uiStroke = v14.word:FindFirstChildOfClass("UIStroke")

			if uiStroke then
				uiStroke.Transparency = 1
			end

			for _, mark in v14.marks do
				mark.bb.Enabled = false
			end

			v15.gui.Enabled = false

			v15.word.TextTransparency = 1
			local uiStroke2 = v15.word:FindFirstChildOfClass("UIStroke")

			if uiStroke2 then
				uiStroke2.Transparency = 1
			end

			for _, mark in v15.marks do
				mark.bb.Enabled = false
			end

			local enableds = {}

			for _, v16 in data.layers.huds or { data.layers.hud } do
				enableds[v16] = v16.Enabled
				v16.Enabled = false
			end

			playerGui:SetAttribute("Cinematic", true)
			local fieldOfView = workspace.CurrentCamera.FieldOfView
			local v16 = nil
			local lastTime = os.clock()

			local function finish()
				RunService:UnbindFromRenderStep("SiegeIntroCamera")
				drop(v14)
				drop(v15)
				siegeIntroCurtain:Destroy()

				for k, enabled in enableds do
					k.Enabled = enabled
				end

				playerGui:SetAttribute("Cinematic", nil)
				local currentCamera = workspace.CurrentCamera
				currentCamera.FieldOfView = fieldOfView
				currentCamera.CameraType = Enum.CameraType.Custom

				if cameraSubject.Parent then
					currentCamera.CameraSubject = cameraSubject

					if v16 and v16.Parent and v16.Parent ~= instance and cameraSubject.Health > 0 then
						cameraSubject:EquipTool(v16)
					end
				end

				v2 = false
			end

			RunService:BindToRenderStep("SiegeIntroCamera", Enum.RenderPriority.Camera.Value + 10, function()
				local v17 = (os.clock() - lastTime) / v5

				if
					v17 >= 9
					or not instance.Parent
					or cameraSubject.Health <= 0
					or player.Team == nil
					or player.Team.Name ~= name
				then
					finish()
					return
				end

				local tool = instance:FindFirstChildOfClass("Tool")

				if tool then
					v16 = v16 or tool
					cameraSubject:UnequipTools()
				end

				local v18, v19

				if v17 < 4.2 then
					v18 = v10:Lerp(v11, v17 / 4.2)
					v19 = v7
				elseif v17 < 7.8 then
					v18 = v12:Lerp(v13, (v17 - 4.2) / 3.6)
					v19 = v6
				else
					local cframe = humanoidRootPart.CFrame
					local v20 = flat(cframe.LookVector) -- inferred equivalent call
					local v21

					if v20.Magnitude > 0.1 then
						v21 = v20.Unit
					else
						v21 = -v9
					end

					v18 = cframe.Position - v21 * 9 + Vector3.new(0, 3.5, 0)
					v19 = cframe.Position + v21 * 30 + Vector3.new(0, 1.5, 0)
				end

				frame.BackgroundTransparency = math.clamp(
					math.min(v17 / 0.35, math.abs(v17 - 4.2) / 0.22, math.abs(v17 - 7.8) / 0.22),
					0,
					1
				)
				local currentCamera = workspace.CurrentCamera
				currentCamera.CameraType = Enum.CameraType.Scriptable
				currentCamera.FieldOfView = 70
				currentCamera.CFrame = CFrame.lookAt(v18, v19)
				local now = os.clock()
				fade(v14, window(v17, 0.5, 3.9), now) -- inferred equivalent call
				fade(v15, window(v17, 4.5, 7.5), now) -- inferred equivalent call
			end)
		end

		data.onCharacter(function(instance, p)
			local function check() -- 1 equivalent call inferred from this helper
				local introUntil = instance:GetAttribute("IntroUntil")

				if type(introUntil) == "number" then
					task.spawn(play, instance, p, introUntil)
				end
			end
			instance:GetAttributeChangedSignal("IntroUntil"):Connect(check)
			check() -- inferred equivalent call
		end)
	end
}