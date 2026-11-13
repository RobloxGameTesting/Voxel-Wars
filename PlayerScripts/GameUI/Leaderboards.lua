local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Style = require(script.Parent:WaitForChild("Style"))
local Progression = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("Progression"))

local kinds = {
	kills = { title = "MOST KILLS", list = "kills" },
	levels = { title = "HIGHEST LEVEL", list = "xp" }
}
local Leaderboards = {}
Leaderboards.KINDS = kinds
local color = Color3.fromRGB(238, 236, 230)
local color2 = Color3.fromRGB(252, 251, 248)
local color3 = Color3.fromRGB(222, 218, 208)
local color4 = Color3.fromRGB(34, 36, 40)
local color5 = Color3.fromRGB(120, 122, 128)
local color6 = Color3.fromRGB(226, 223, 215)
local color7 = Color3.fromRGB(255, 238, 190)
local color8 = Color3.fromRGB(222, 166, 30)
local color9 = Color3.fromRGB(176, 172, 162)
local v = { Color3.fromRGB(236, 186, 60), Color3.fromRGB(190, 196, 206), Color3.fromRGB(205, 138, 84) }

local LocalPlayer = Players.LocalPlayer
local v2 = { kills = 0, xp = 0, at = 0 }
v2.kills = {}
v2.xp = {}

local function listOf(p: string) -- 1 equivalent call inferred from this helper
	local v3 = v2[kinds[p].list]

	if type(v3) == "table" then
		return v3
	end

	return {}
end

local function shown(p: string, value: number) -- 1 equivalent call inferred from this helper
	if p == "levels" then
		return (tostring((Progression.levelOf(value))))
	end

	return Style.thousands(value)
end

local function plain(fill, p: string, p2: string, p3: number, p4, textColor: Color3) -- 5 equivalent calls inferred from this helper
	local label = Style.label(fill, p, p2, p3, p4, 0)
	label.AutomaticSize = Enum.AutomaticSize.None
	label.TextColor3 = textColor
	return label
end

local function newRow(list, layoutOrder: number)
	local fill = Style.fill(list, "Row" .. layoutOrder, color2, UDim2.new(1, 0, 0, 36))
	fill.LayoutOrder = layoutOrder
	Style.corner(fill, 6)
	local stroke = Style.stroke(fill, 1, 0, color3, true)

	local v3 = tostring(layoutOrder)
	local font = Style.FONT
	local textColor = if v[layoutOrder] then color4 else color5
	local label = plain(fill, "Rank", v3, 17, font, textColor) -- inferred equivalent call
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.new(0, 22, 0.5, 0)
	label.Size = UDim2.fromOffset(26, 26)

	if v[layoutOrder] then
		label.BackgroundTransparency = 0
		label.BackgroundColor3 = v[layoutOrder]
		Style.corner(label, 13)
	end

	local face = Instance.new("ImageLabel")
	face.Name = "Face"
	face.BackgroundColor3 = color6
	face.BorderSizePixel = 0
	face.AnchorPoint = Vector2.new(0, 0.5)
	face.Size = UDim2.fromOffset(26, 26)
	face.Position = UDim2.new(0, 42, 0.5, 0)
	face.Parent = fill
	Style.corner(face, 13)
	local name = plain(fill, "Name", "", 17, Style.FONT_BODY, color4) -- inferred equivalent call
	name.Size = UDim2.new(1, -160, 1, 0)
	name.Position = UDim2.fromOffset(76, 0)
	name.TextXAlignment = Enum.TextXAlignment.Left
	name.TextTruncate = Enum.TextTruncate.AtEnd
	local label2 = plain(fill, "Value", "", 19, Style.FONT, color4) -- inferred equivalent call
	label2.AnchorPoint = Vector2.new(1, 0)
	label2.Size = UDim2.new(0, 76, 1, 0)
	label2.Position = UDim2.new(1, -12, 0, 0)
	label2.TextXAlignment = Enum.TextXAlignment.Right
	return {
		root = fill,
		name = name,
		value = label2,
		face = face,
		stroke = stroke
	}
end

local function newBoard(part, board: string, playerGui)
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Name = "Leaderboard_" .. board
	surfaceGui.Adornee = part
	surfaceGui.Face = Enum.NormalId.Front
	surfaceGui.LightInfluence = 0
	surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surfaceGui.PixelsPerStud = 40
	surfaceGui.MaxDistance = 300
	surfaceGui.ResetOnSpawn = false
	surfaceGui.Enabled = false
	surfaceGui.Parent = playerGui
	local fill = Style.fill(surfaceGui, "Root", color, UDim2.fromScale(1, 1))
	local label = plain(fill, "Title", kinds[board].title, 30, Style.FONT, color4) -- inferred equivalent call
	label.Size = UDim2.new(1, -108, 0, 36)
	label.Position = UDim2.fromOffset(14, 8)
	label.TextXAlignment = Enum.TextXAlignment.Left
	local label2 = plain(fill, "Sub", "GLOBAL", 15, Style.FONT, color5) -- inferred equivalent call
	label2.AnchorPoint = Vector2.new(1, 0)
	label2.Size = UDim2.fromOffset(80, 36)
	label2.Position = UDim2.new(1, -14, 0, 8)
	label2.TextXAlignment = Enum.TextXAlignment.Right
	local fill_2 = Style.fill(fill, "Rule", color3, UDim2.new(1, -28, 0, 2), UDim2.fromOffset(14, 46))
	fill_2.BorderSizePixel = 0

	local list = Instance.new("ScrollingFrame")
	list.Name = "List"
	list.Active = true
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.Position = UDim2.fromOffset(14, 54)
	list.Size = UDim2.new(1, -28, 1, -68)
	list.ScrollBarThickness = 4
	list.ScrollBarImageColor3 = color9
	list.VerticalScrollBarInset = Enum.ScrollBarInset.Always
	list.CanvasSize = UDim2.new()
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.ScrollingDirection = Enum.ScrollingDirection.Y
	list.ElasticBehavior = Enum.ElasticBehavior.Always
	list.Parent = fill
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingRight = UDim.new(0, 6)
	uiPadding.PaddingTop = UDim.new(0, 1)
	uiPadding.PaddingBottom = UDim.new(0, 1)
	uiPadding.Parent = list
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.Padding = UDim.new(0, 4)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = list
	local v3 = {}
	local function redraw()
		local v4 = listOf(board) -- inferred equivalent call

		for k, v5 in v4 do
			local v6 = v3[k]

			if not v6 then
				v6 = newRow(list, k)
				v3[k] = v6
			end

			v6.root.Visible = true
			v6.name.Text = v5.name
			local value = v6.value
			value.Text = shown(board, v5.value) -- inferred equivalent call
			v6.face.Image = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=48&h=48", v5.id)
			local v7 = v5.id == LocalPlayer.UserId
			local root = v6.root
			local backgroundColor = if v7 then color7 else color2
			root.BackgroundColor3 = backgroundColor
			local stroke = v6.stroke
			local color10 = if v7 then color8 else color3
			stroke.Color = color10
			v6.stroke.Thickness = v7 and 2 or 1
		end

		for i = #v4 + 1, #v3 do
			v3[i].root.Visible = false
		end
	end
	redraw()
	return { gui = surfaceGui, redraw = redraw }
end

local flag = false
function Leaderboards.start()
	if flag then
		return
	end

	flag = true
	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	local v3 = {}
	local partSet = {}
	local function onPad(): boolean -- 1 equivalent call inferred from this helper
		return LocalPlayer.Team == nil and LocalPlayer:GetAttribute("PickingTeam") == true
	end

	local function show() -- 1 equivalent call inferred from this helper
		local enabled = onPad() -- inferred equivalent call

		for _, v4 in v3 do
			v4.gui.Enabled = enabled
		end
	end
	local function findBoards(folder)
		for _, part in folder:GetDescendants() do
			if part.Name ~= "Leaderboard" or not part:IsA("BasePart") or partSet[part] then
				continue
			end

			local board = part:GetAttribute("Board")
			local v4 = type(board) == "string" and kinds[board]
			assert(v4, "[Leaderboards] board part with unknown Board attribute " .. tostring(board))
			partSet[part] = true
			table.insert(v3, newBoard(part, board, playerGui))
		end

		show() -- inferred equivalent call
	end

	for _, v4 in CollectionService:GetTagged("SkyLobby") do
		findBoards(v4)
	end

	CollectionService:GetInstanceAddedSignal("SkyLobby"):Connect(function(p)
		task.defer(findBoards, p)
	end)
	LocalPlayer:GetPropertyChangedSignal("Team"):Connect(show)
	LocalPlayer:GetAttributeChangedSignal("PickingTeam"):Connect(show)

	local leaderboards = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Remotes"):WaitForChild("Leaderboards", 30)
	assert(
		leaderboards and leaderboards:IsA("RemoteFunction"),
		"GameUI: remote Game.Remotes.Leaderboards (RemoteFunction) is missing (ServerScriptService.Leaderboards)"
	)
	local flag2 = false
	local function fetch()
		if flag2 then
			return
		end

		flag2 = true
		local success, result = pcall(leaderboards.InvokeServer, leaderboards)
		flag2 = false

		if not success then
			warn("[Leaderboards] fetch failed: " .. tostring(result))
		elseif type(result) == "table" then
			v2 = result

			for _, v4 in v3 do
				v4.redraw()
			end
		end
	end
	leaderboards:GetAttributeChangedSignal("Version"):Connect(function()
		task.spawn(fetch)
	end)
	fetch()
end

return Leaderboards