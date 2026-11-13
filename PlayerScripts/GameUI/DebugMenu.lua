game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Viewmodel = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("Viewmodel"))
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Style = require(script.Parent.Style)

local v = { [7872316101] = true, [11547363793] = true }
local DebugMenu = {}

function DebugMenu.isOwner(p: number): boolean
	return v[p] == true
end

function DebugMenu.mount(data)
	local player = data.player

	if not v[player.UserId] then
		return
	end

	local Icon = require(ReplicatedStorage:WaitForChild("TopbarPlus"):WaitForChild("Icon"))
	local CmdrClient = require(ReplicatedStorage:WaitForChild("CmdrClient"))

	local name = player.Name

	local v2 = {}

	table.insert(v2, {
		title = "ROUND",
		entries = {
			{ text = "RESTART MATCH", run = "restartmatch" },
			{ text = "END ROUND", run = "endround" },
			{ text = "REDS WIN ROUND", run = "endround Reds" },
			{ text = "BLUES WIN ROUND", run = "endround Blues" }
		}
	})

	local Game = ReplicatedStorage:WaitForChild("Game")

	local entries = {}
	local v3 = { title = "MODE", entries = 0 }
	local v4 = 0

	for _, v5 in {
		{ "IRONFIELD KOTH", "ironfield", "domination" },
		{ "IRONFIELD TDM", "ironfield", "tdm" },
		{ "IRONFIELD SIEGE", "ironfield", "siege" },
		{ "SALTPAN DOMINATION", "saltpan", "domination" },
		{ "SALTPAN TDM", "saltpan", "tdm" },
		{ "SALTPAN KOTH", "saltpan", "hill" },
		{ "SANDLINE DOMINATION", "sandline", "domination" },
		{ "SANDLINE TDM", "sandline", "tdm" },
		{ "FROSTMILL DOMINATION", "frostmill", "domination" },
		{ "FROSTMILL TDM", "frostmill", "tdm" },
		{ "FROSTMILL KOTH", "frostmill", "hill" },
		{ "PINEWOLD DOMINATION", "pinewold", "domination" },
		{ "PINEWOLD TDM", "pinewold", "tdm" },
		{ "PINEWOLD KOTH", "pinewold", "hill" },
		{ "DRYWELL DOMINATION", "drywell", "domination" },
		{ "DRYWELL TDM", "drywell", "tdm" },
		{ "DRYWELL KOTH", "drywell", "hill" },
		{ "HIGHCRAG DOMINATION", "highcrag", "domination" },
		{ "HIGHCRAG KOTH", "highcrag", "hill" }
	} do
		table.insert(entries, {
			text = v5[1],
			run = "play " .. v5[2] .. " " .. v5[3],
			lit = function(): boolean
				return Game:GetAttribute("Map") == v5[2]
					and Game:GetAttribute("GameMode") == (v5[3] == "hill" and "domination" or v5[3])
					and (Game:GetAttribute("OnePoint") == true) == (v5[3] == "hill")
			end
		})
	end

	v3.entries = entries
	table.insert(v2, v3)

	table.insert(v2, {
		title = "YOU",
		entries = {
			{
				text = "GIVE ALL",
				run = "giveall " .. name
			},
			{
				text = "GOD MODE",
				run = "god " .. name
			},
			{
				text = "FULL HEALTH",
				run = "sethealth " .. name .. " 200"
			},
			{
				text = "RESPAWN",
				run = "sethealth " .. name .. " 0"
			},
			{
				text = "+1000 SCRAP",
				run = "givescrap " .. name .. " 1000"
			},
			{
				text = "+1000 XP",
				run = "givexp " .. name .. " 1000"
			},
			{
				text = "RESET MY PROGRESS",
				run = function()
					local now = os.clock()

					if v4 < now then
						v4 = os.clock() + 4
						return "RESET MY PROGRESS: tap again within 4 s (level 1, no items, no weapon XP; backed up, RESTORE undoes it)"
					end

					v4 = 0
					local success, result = pcall(function()
						return CmdrClient.Dispatcher:EvaluateAndRun("resetprogress")
					end)
					local v5

					if success then
						v5 = tostring(result)
					else
						v5 = "FAILED " .. tostring(result)
					end

					return "resetprogress: " .. v5
				end
			},
			{ text = "RESTORE MY PROGRESS", run = "restoreprogress" }
		}
	})

	local ShopData = require(Game:WaitForChild("ShopData"))
	local v5 = {}

	for k, v6 in ShopData.ITEMS do
		if v6.slot == "streak" then
			table.insert(v5, k)
		end
	end

	table.sort(v5)
	local entries2 = {}

	for _, v6 in v5 do
		table.insert(entries2, {
			text = string.upper(v6),
			run = "killstreak " .. name .. " " .. v6
		})
	end

	table.insert(v2, { title = "STREAKS", entries = entries2 })

	local v6 = {}

	for _, moduleScript in ReplicatedStorage:WaitForChild("Vehicles"):GetChildren() do
		local v7 = string.match(moduleScript.Name, "^(%w+)Model$")

		if v7 and moduleScript:IsA("ModuleScript") then
			table.insert(v6, v7)
		end
	end

	table.sort(v6)
	local entries3 = {}

	for _, v7 in v6 do
		table.insert(entries3, {
			text = string.upper((string.gsub(v7, "(%l)(%u)", "%1 %2"))),
			run = "spawnvehicle " .. v7
		})
	end

	table.insert(entries3, { text = "CLEAR VEHICLES", run = "clearvehicles" })
	table.insert(v2, { title = "VEHICLES", entries = entries3 })
	table.insert(v2, {
		title = "BOTS",
		entries = {
			{ text = "PAUSE / RESUME", run = "botpause" },
			{ text = "EASY", run = "botdifficulty easy" },
			{ text = "NORMAL", run = "botdifficulty normal" },
			{ text = "HARD", run = "botdifficulty hard" },
			{ text = "NO BOTS", run = "bots 0" },
			{ text = "5 PER TEAM", run = "bots 5" },
			{ text = "10 PER TEAM", run = "bots 10" }
		}
	})

	local function statsBar() -- 2 equivalent calls inferred from this helper
		local playerGui = player:FindFirstChildOfClass("PlayerGui")
		local voxelRenderHud = playerGui and playerGui:FindFirstChild("VoxelRenderHud")

		if voxelRenderHud and voxelRenderHud:IsA("ScreenGui") then
			return voxelRenderHud
		end

		return nil
	end

	table.insert(v2, {
		title = "WORLD",
		entries = {
			{ text = "PUT OUT FIRES", run = "fireclear" },
			{ text = "VOXEL STATS", run = "voxelstats" },
			{
				text = "STATS BAR",
				run = function()
					local voxelRenderHud = statsBar() -- inferred equivalent call

					if not voxelRenderHud then
						return "STATS BAR: FAILED, the voxel renderer's bar is not there"
					end

					voxelRenderHud.Enabled = not voxelRenderHud.Enabled
					return "stats bar " .. (voxelRenderHud.Enabled and "on" or "off")
				end,
				lit = function()
					local voxelRenderHud = statsBar() -- inferred equivalent call
					return voxelRenderHud ~= nil and voxelRenderHud.Enabled
				end
			}
		}
	})

	local function fn() end
	table.insert(v2, {
		title = "PERF",
		entries = {
			{
				text = "GPU PROBE",
				run = function()
					fn()
					local success, result = pcall(function()
						return CmdrClient.Dispatcher:EvaluateAndRun("gpuprobe")
					end)
					local v7

					if success then
						v7 = tostring(result)
					else
						v7 = "FAILED " .. tostring(result)
					end

					return "gpuprobe: " .. v7
				end
			},
			{
				text = "LIGHTING PROBE",
				run = function()
					fn()
					local success, result = pcall(function()
						return CmdrClient.Dispatcher:EvaluateAndRun("gpuprobe lighting")
					end)
					local v7

					if success then
						v7 = tostring(result)
					else
						v7 = "FAILED " .. tostring(result)
					end

					return "gpuprobe: " .. v7
				end
			},
			{
				text = "PHONE SHADOWS",
				run = function()
					local mobileShadows = ReplicatedStorage:WaitForChild("Voxel"):GetAttribute("MobileShadows") ~= false
					return CmdrClient.Dispatcher:EvaluateAndRun("feature mobileshadows " .. (mobileShadows and "off" or "on"))
				end,
				lit = function(): boolean
					return ReplicatedStorage:WaitForChild("Voxel"):GetAttribute("MobileShadows") ~= false
				end
			}
		}
	})

	local function armoryRoot() -- 2 equivalent calls inferred from this helper
		local armory = data.layers.menu:FindFirstChild("Armory")

		if armory and armory:IsA("GuiObject") then
			return armory
		end

		return nil
	end

	table.insert(v2, {
		title = "UI",
		entries = {
			{
				text = "ARMORY",
				run = function()
					local Armory = require(script.Parent:WaitForChild("Armory"))

					if not Armory.toggle then
						return "ARMORY: FAILED, not mounted yet (it mounts with the skirmish HUD)"
					end

					fn()
					Armory.toggle()
					local armory = armoryRoot() -- inferred equivalent call
					return "armory " .. (armory and armory.Visible and "open" or "closed")
				end,
				lit = function()
					local armory = armoryRoot() -- inferred equivalent call
					return armory ~= nil and armory.Visible
				end
			}
		}
	})

	local region = Style.region(
		data.layers.menu,
		"DebugMenu",
		Vector2.new(0.5, 0.5),
		Vector2.zero,
		Vector2.new(420, 456)
	)
	region.Visible = false
	Style.fit(region, Vector2.new(420, 456))
	local modal = Instance.new("TextButton")
	modal.Name = "Modal"
	modal.Text = ""
	modal.BackgroundTransparency = 1
	modal.Size = UDim2.fromOffset(1, 1)
	modal.Modal = true
	modal.Parent = region
	local box = Style.box(region, "Body", Style.PANEL, UDim2.fromScale(1, 1), 3, 3)
	box.BackgroundTransparency = 0.04
	box.Active = true
	local fill = Style.fill(box, "Header", Style.STEEL, UDim2.new(1, 0, 0, 50))
	Style.tape(fill, "Tape", UDim2.new(1, 0, 0, 6), 420, 16)
	local label_2 = Style.label(fill, "Title", "DEBUG", 22, Style.FONT, 0)
	label_2.Position = UDim2.fromOffset(14, 13)
	local label = Style.label(fill, "Stats", "", 13, Style.FONT_BODY, 0)
	label.TextColor3 = Style.MUTED
	label.Position = UDim2.fromOffset(92, 19)
	local button = Style.button(fill, "Close", "X", Style.INK, UDim2.fromOffset(34, 30), Style.WHITE, 16)
	button.AnchorPoint = Vector2.new(1, 0)
	button.Position = UDim2.new(1, -10, 0, 13)

	local list = Instance.new("ScrollingFrame")
	list.Name = "List"
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.Position = UDim2.fromOffset(0, 50)
	list.Size = UDim2.new(1, 0, 0, 330)
	list.ScrollBarThickness = 4
	list.ScrollBarImageColor3 = Style.HAZARD
	list.ScrollingDirection = Enum.ScrollingDirection.Y
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.CanvasSize = UDim2.new()
	list.Parent = box
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = list

	local serverInfo = Instance.new("Frame")
	serverInfo.Name = "ServerInfo"
	serverInfo.BackgroundTransparency = 1
	serverInfo.Size = UDim2.new(1, 0, 0, 0)
	serverInfo.AutomaticSize = Enum.AutomaticSize.Y
	serverInfo.LayoutOrder = 1
	serverInfo.Parent = list
	local uiListLayout2 = Instance.new("UIListLayout")
	uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout2.Padding = UDim.new(0, 4)
	uiListLayout2.Parent = serverInfo
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, 14)
	uiPadding.PaddingRight = UDim.new(0, 14)
	uiPadding.PaddingTop = UDim.new(0, 8)
	uiPadding.PaddingBottom = UDim.new(0, 6)
	uiPadding.Parent = serverInfo
	local function infoLabel(name2: string, layoutOrder: number, textSize: number)
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = name2
		textLabel.BackgroundTransparency = 1
		textLabel.Size = UDim2.new(1, 0, 0, 0)
		textLabel.AutomaticSize = Enum.AutomaticSize.Y
		textLabel.FontFace = Style.FONT_BODY
		textLabel.TextSize = textSize
		textLabel.TextColor3 = Style.WHITE
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.TextWrapped = true
		textLabel.RichText = true
		textLabel.LayoutOrder = layoutOrder
		textLabel.Text = ""
		textLabel.Parent = serverInfo
		return textLabel
	end

	local label2 = Style.label(serverInfo, "ServerHead", "SERVER", 13, Style.FONT, 0)
	label2.TextColor3 = Style.MUTED
	label2.LayoutOrder = 0
	local v7 = infoLabel("Server", 1, 13)
	v7.Text = "…"
	local label3 = Style.label(serverInfo, "PlayersHead", "PLAYERS", 13, Style.FONT, 0)
	label3.TextColor3 = Style.MUTED
	label3.LayoutOrder = 2
	local v8 = {}

	local function esc(value: string) -- 5 equivalent calls inferred from this helper
		return (value:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
	end

	local function span(uptime: number) -- 1 equivalent call inferred from this helper
		local v9 = uptime // 60

		if v9 >= 60 then
			return (string.format("%dh %02dm", v9 // 60, v9 % 60))
		end

		return (string.format("%dm", v9))
	end

	local function drawInfo(result)
		if type(result) ~= "table" then
			v7.Text = "No answer (owner accounts only)."
			return
		end

		local v9 = result.kind

		if result.kind == "CHEATER SERVER" and result.poolPlace and result.poolCount then
			v9 ..= string.format(" %d OF %d", result.poolPlace, result.poolCount)
		end

		local v10 = (result.kind == "PUBLIC" or result.kind == "STUDIO") and "#FFFFFF" or "#FF9A3C"

		local v11 = string.sub(tostring(result.job), 1, 8)
		local build = tonumber(result.build) or 0
		v7.Text = string.format(
			"<b><font color=\"%s\">%s</font></b>  ·  %s  ·  BUILD %d  ·  UP %s  ·  %d PLAYERS",
			v10,
			v9,
			v11,
			build,
			span(tonumber(result.uptime) or 0), -- inferred equivalent call
			#result.players
		)

		for k, player2 in result.players do
			local v12 = v8[k]

			if not v12 then
				v12 = infoLabel("Player" .. k, 2 + k, 12)
				v8[k] = v12
			end

			v12.Visible = true
			local v13 = {}

			if player2.pooled then
				table.insert(v13, "POOLED: " .. esc(string.sub(player2.pooled, 1, 60))) -- inferred equivalent call
			end

			if player2.baits > 0 then
				table.insert(v13, "BAIT x" .. player2.baits)
			end

			if player2.fly > 0 then
				table.insert(v13, string.format("FLY %d (%d high)", player2.fly, player2.high))
			end

			if player2.aim then
				table.insert(v13, "AIM " .. esc(string.upper((tostring(player2.aim))))) -- inferred equivalent call
			end

			if player2.floods > 0 then
				table.insert(v13, "FLOOD x" .. player2.floods)
			end

			local v14 = not player2.trust and "?" or tostring(player2.trust)

			if v14 == "None" then
				v14 = string.format("<font color=\"%s\">None</font>", "#FF9A3C")
			end

			local v15

			if #v13 > 0 then
				v15 = string.format("<font color=\"%s\">%s</font>", "#FF9A3C", table.concat(v13, "  ·  "))
			else
				v15 = player2.unread and "<font color=\"#A9B0B8\">flag not read</font>"
					or "<font color=\"#A9B0B8\">clean</font>"
			end

			v12.Text = string.format(
				"<b>%s</b>%s  %s · %s · %d ms · trust %s · %d d\n%s",
				esc(player2.name), -- inferred equivalent call
				player2.owner and " (you)" or "",
				esc(player2.team), -- inferred equivalent call
				player2.device,
				player2.ping,
				v14,
				player2.age,
				v15
			)
		end

		for i = #result.players + 1, #v8 do
			v8[i].Visible = false
		end
	end
	local v9 = nil
	local function askInfo()
		if not v9 then
			local debugServerInfo = Game:WaitForChild("Remotes"):WaitForChild("DebugServerInfo", 10)

			if debugServerInfo and debugServerInfo:IsA("RemoteFunction") then
				v9 = debugServerInfo
			else
				v7.Text = "Game.Remotes.DebugServerInfo is missing (ServerScriptService.ServerInfo)."
				return
			end
		end

		local success, result = pcall(v9.InvokeServer, v9)

		if success then
			drawInfo(result)
		else
			v7.Text = "Server info FAILED: " .. esc(tostring(result)) -- inferred equivalent call
		end
	end

	local buttons = Instance.new("Frame")
	buttons.Name = "Buttons"
	buttons.BackgroundTransparency = 1
	buttons.LayoutOrder = 2
	buttons.Parent = list

	local label4 = Style.label(box, "Result", "Tap a button. Replies show here.", 13, Style.FONT_BODY, 0)
	label4.TextColor3 = Style.MUTED
	label4.AutomaticSize = Enum.AutomaticSize.None
	label4.Size = UDim2.new(1, -28, 0, 44)
	label4.Position = UDim2.fromOffset(14, 384)
	label4.TextWrapped = true
	label4.TextTruncate = Enum.TextTruncate.AtEnd
	label4.TextXAlignment = Enum.TextXAlignment.Left
	label4.TextYAlignment = Enum.TextYAlignment.Top
	Style.fill(box, "Rule", Style.STEEL, UDim2.new(1, -28, 0, 1), UDim2.fromOffset(14, 380))

	local label5 = Style.label(box, "Build", "", 12, Style.FONT_BODY, 0)
	label5.TextColor3 = Style.MUTED
	label5.AutomaticSize = Enum.AutomaticSize.None
	label5.Size = UDim2.new(1, -28, 0, 18)
	label5.Position = UDim2.fromOffset(14, 428)
	label5.TextXAlignment = Enum.TextXAlignment.Left
	local v10 = not (game.PlaceVersion > 0) and "BUILD 0 (STUDIO)" or "BUILD " .. game.PlaceVersion
	label5.Text = v10 .. "  ·  PUBLISHED …"
	task.spawn(function()
		local MarketplaceService = game:GetService("MarketplaceService")
		local success, productInfoAsync = pcall(
			MarketplaceService.GetProductInfoAsync,
			MarketplaceService,
			game.PlaceId
		)

		if success then
			if type(productInfoAsync) == "table" then
				success = productInfoAsync.Updated
			else
				success = false
			end
		end

		if type(success) == "string" then
			label5.Text = v10 .. "  ·  PUBLISHED " .. DateTime.fromIsoDate(success):FormatLocalTime(
				"YYYY-MM-DD HH:mm",
				"en-us"
			)
			return
		end

		label5.Text = v10 .. "  ·  PUBLISH TIME UNAVAILABLE"
		warn("[DebugMenu] place info: " .. tostring(productInfoAsync))
	end)

	local v11 = {}
	local function paint()
		for _, v12 in v11 do
			local v13

			if v12.entry.lit == nil then
				v13 = false
			else
				v13 = v12.entry.lit()
			end

			local button2 = v12.button
			local backgroundColor

			if v13 then
				backgroundColor = Style.HAZARD
			else
				backgroundColor = Style.STEEL
			end

			button2.BackgroundColor3 = backgroundColor
			local label6 = v12.label
			local textColor = if v13 then Style.INK else Style.WHITE
			label6.TextColor3 = textColor
		end
	end

	local function run(p)
		local text

		if type(p.run) == "string" then
			local success, result = pcall(function()
				return CmdrClient.Dispatcher:EvaluateAndRun(p.run)
			end)

			local run2 = p.run
			local v12

			if success then
				v12 = tostring(result)
			else
				v12 = "FAILED " .. tostring(result)
			end

			text = run2 .. ": " .. v12
		else
			text = p.run()
		end

		label4.Text = text
		local textColor

		if text:find("FAILED") or text:lower():find("permission") then
			textColor = Style.ORANGE
		else
			textColor = Style.WHITE
		end

		label4.TextColor3 = textColor
		task.delay(0.3, paint)
	end

	local v12 = 8

	for _, v13 in v2 do
		local label6 = Style.label(buttons, v13.title, v13.title, 13, Style.FONT, 0)
		label6.TextColor3 = Style.MUTED
		label6.Position = UDim2.fromOffset(14, v12)
		local v14 = v12 + 20

		for k, entry in v13.entries do
			local v15 = (k - 1) % 3
			local v16 = (k - 1) // 3
			local button2, label7 = Style.button(
				buttons,
				"Btn_" .. entry.text,
				entry.text,
				Style.STEEL,
				UDim2.fromOffset(380 / 3, 36),
				Style.WHITE,
				14
			)
			button2.Position = UDim2.fromOffset(14 + v15 * 132.66666666666669, v14 + v16 * 42)
			label7.TextScaled = false
			label7.TextWrapped = true
			table.insert(v11, { entry = entry, button = button2, label = label7 })
			local v17 = entry
			button2.Activated:Connect(function()
				task.spawn(run, v17)
			end)
		end

		v12 = v14 + (math.ceil(#v13.entries / 3) * 42 + 10)
	end

	buttons.Size = UDim2.new(1, 0, 0, v12 + 4)
	paint()
	Game:GetAttributeChangedSignal("GameMode"):Connect(paint)

	local count = 0
	local v13 = os.clock()
	local renderSteppedConnection = nil
	local count2 = 0

	local v14 = true
	local v15 = Icon.new()
	v15:setName("Debug")
	v15:setLabel("DEBUG")
	v15:setCaption("Debug menu")
	local function setOpen(visible: boolean)
		if visible == region.Visible then
			return
		end

		if visible then
			v14 = UserInputService.MouseIconEnabled
			UserInputService.MouseIconEnabled = true
			paint()
			count2 += 1
			local v16 = count2
			task.spawn(function()
				while count2 == v16 do
					askInfo()
					task.wait(2)
				end
			end)
			local now = os.clock()
			count = 0
			v13 = now
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				count += 1
				local now2 = os.clock()

				if now2 - v13 >= 0.5 then
					local v17 = math.round(player:GetNetworkPing() * 1000)
					label.Text = string.format("%d FPS  ·  %d MS PING", math.round(count / (now2 - v13)), v17)
					count = 0
					v13 = now2
				end
			end)
		else
			UserInputService.MouseIconEnabled = Viewmodel.cursorAfterMenu(v14)
			count2 += 1

			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end
		end

		region.Visible = visible
		data.setMenu(visible)
	end
	v15.toggled:Connect(function(visible: boolean)
		setOpen(visible)
	end)
	button.Activated:Connect(function()
		v15:deselect()
	end)
	fn = function()
		v15:deselect()
	end

	local function showIcon() -- 1 equivalent call inferred from this helper
		local hideDebugMenu = player:GetAttribute("HideDebugMenu") == true

		if hideDebugMenu then
			v15:deselect()
		end

		v15:setEnabled(not hideDebugMenu)
	end

	showIcon() -- inferred equivalent call
	player:GetAttributeChangedSignal("HideDebugMenu"):Connect(showIcon)
end

return DebugMenu