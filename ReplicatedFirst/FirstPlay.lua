local GuiService = game:GetService("GuiService")
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ScriptContext = game:GetService("ScriptContext")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local lastTime = os.clock()
local function elapsed() -- 19 equivalent calls inferred from this helper
	return os.clock() - lastTime
end

local v = {}
local function log(p: string, p2: string?) -- 10 equivalent calls inferred from this helper
	table.insert(v, { math.floor(elapsed() * 10 + 0.5) / 10, p, p2 }) -- inferred equivalent call
end

local v2 = {}
local nameSet = {}
local v3 = os.clock()
local function press(name: string) -- 4 equivalent calls inferred from this helper
	v2[name] = (v2[name] or 0) + 1
	v3 = os.clock()
end

local function describe(guiObjectsAtPosition)
	local button = guiObjectsAtPosition[1]

	for _, button2 in guiObjectsAtPosition do
		if button2:IsA("GuiButton") then
			button = button2
			break
		end
	end

	if not button then
		return nil
	end

	local parent = button.Parent
	local text = nil

	if button:IsA("TextButton") then
		text = button.Text
	elseif button:IsA("GuiButton") then
		local textLabel = button:FindFirstChildWhichIsA("TextLabel", true)

		if textLabel then
			text = textLabel.Text
		end
	end

	local v4 = (not parent and "" or parent.Name .. "/") .. button.Name

	if text and text ~= "" then
		return v4 .. "|" .. text
	end

	return v4
end

local v4 = -1e999
local v5 = 0
local v6 = 0
local v7 = 0
local v8 = 0
local function tap(input, gameProcessed: boolean)
	local now = os.clock()
	local x = input.Position.X
	local y = input.Position.Y

	if now - v5 < 1.5 and math.abs(x - v6) < 30 and math.abs(y - v7) < 30 then
		v8 += 1

		if v8 == 3 then
			log("rage") -- inferred equivalent call
		end
	else
		v8 = 1
	end

	v5 = now
	v6 = x
	v7 = y

	if now - v4 < 0.25 or elapsed() > 180 and not gameProcessed then -- inferred equivalent call
		return
	end

	v4 = now
	local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

	local v9 = playerGui and describe(playerGui:GetGuiObjectsAtPosition(x, y))

	if v9 then
		log("tap", v9) -- inferred equivalent call
	end
end

local connections = {}
local function on(object, callback)
	table.insert(connections, object:Connect(callback))
end

table.insert(connections, UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
	if UserInputService:GetFocusedTextBox() then
		return
	end

	local userInputType = input.UserInputType

	if userInputType == Enum.UserInputType.Touch then
		press("Tap") -- inferred equivalent call
		tap(input, gameProcessed)
	elseif userInputType == Enum.UserInputType.MouseButton1 then
		press("M1") -- inferred equivalent call
		tap(input, gameProcessed)
	elseif userInputType == Enum.UserInputType.MouseButton2 then
		press("M2") -- inferred equivalent call
	elseif userInputType == Enum.UserInputType.Keyboard or userInputType == Enum.UserInputType.Gamepad1 then
		local name = input.KeyCode.Name

		if name ~= "Unknown" and not gameProcessed then
			press(name) -- inferred equivalent call

			if not nameSet[name] then
				nameSet[name] = true
				log("key", name) -- inferred equivalent call
			end
		end
	end
end))

local v9 = false
table.insert(connections, UserInputService.WindowFocusReleased:Connect(function()
	v9 = true
	log("focus-") -- inferred equivalent call
end))
table.insert(connections, UserInputService.WindowFocused:Connect(function()
	log("focus+") -- inferred equivalent call
end))
local v10 = false
table.insert(connections, GuiService.MenuOpened:Connect(function()
	v10 = true
	log("menu+") -- inferred equivalent call
end))
table.insert(connections, GuiService.MenuClosed:Connect(function()
	v10 = false
	log("menu-") -- inferred equivalent call
end))
local count = 0
table.insert(connections, ScriptContext.Error:Connect(function(value: string)
	count += 1

	if count <= 6 then
		log("err", string.sub(value, 1, 60)) -- inferred equivalent call
	end
end))
local count2 = 0
table.insert(connections, RunService.RenderStepped:Connect(function()
	count2 += 1
end))

local v11 = nil
local v12 = {}
local function pollScreens()
	local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return
	end

	local set = {}

	for _, screenGui in playerGui:GetChildren() do
		if not (screenGui:IsA("ScreenGui") and screenGui.Enabled) then
			continue
		end

		set[screenGui.Name] = true
		local children = screenGui:GetChildren()

		if not (#children <= 60) then
			continue
		end

		for _, guiObject in children do
			if guiObject:IsA("GuiObject") and guiObject.Visible then
				set[screenGui.Name .. "/" .. guiObject.Name] = true
			end
		end
	end

	if v11 then
		local function change(p: string, p2: string)
			local v13 = (v12[p] or 0) + 1
			v12[p] = v13

			if v13 <= 6 then
				table.insert(v, { math.floor(elapsed() * 10 + 0.5) / 10, p2, p }) -- inferred equivalent call
			end
		end

		for k in set do
			if v11[k] then
				continue
			end

			local v13 = (v12[k] or 0) + 1
			v12[k] = v13

			if v13 <= 6 then
				log("gui+", k) -- inferred equivalent call
			end
		end

		for k in v11 do
			if set[k] then
				continue
			end

			local v13 = (v12[k] or 0) + 1
			v12[k] = v13

			if v13 <= 6 then
				log("gui-", k) -- inferred equivalent call
			end
		end
	end

	v11 = set
end

local function stateOf(p): string
	if LocalPlayer:GetAttribute("JoinCovered") == true then
		return "cover"
	end

	if LocalPlayer.Team == nil or LocalPlayer.Neutral or LocalPlayer:GetAttribute("PickingTeam") == true then
		return "menu"
	end

	if not p then
		return "none"
	end

	if p.Health <= 0 then
		return "dead"
	end

	return if p.SeatPart then "veh" else "alive"
end

local v13 = {}
local reportFirst = nil
task.spawn(function()
	reportFirst = ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("Remotes"):WaitForChild("ReportFirst")
end)
local function send()
	if reportFirst and (#v13 > 0 or #v > 0) then
		reportFirst:FireServer({ w = v13, e = v })
		v13 = {}
		v = {}
	end
end

local function win()
	return {
		f = {},
		n = 0,
		sum = 0,
		low = 1e999,
		moved = 0,
		mv = 0,
		rx = 0,
		q = 0
	}
end

local v14 = win()

local v15 = os.clock()

local function closeWindow(flag: boolean, st: string, position: Vector3?, humanoid)
	local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000 + 0.5)
	local mem = math.floor(Stats:GetTotalMemoryUsageMb() + 0.5)
	local v16 = {
		t = math.floor(elapsed() + 0.5), -- inferred equivalent call
		st = st,
		x = 0,
		z = 0,
		moved = 0,
		mv = 0,
		ping = 0,
		mem = 0,
		k = 0
	}
	local v17

	if position then
		v17 = math.floor(position.X + 0.5)
	end

	v16.x = v17
	local v18

	if position then
		v18 = math.floor(position.Z + 0.5)
	end

	v16.z = v18
	v16.moved = math.floor(v14.moved + 0.5)
	v16.mv = v14.mv
	v16.ping = ping
	v16.mem = mem
	local v19

	if next(v2) then
		v19 = v2
	end

	v16.k = v19

	if flag then
		v16.f = v14.f
		local v20

		if position then
			v20 = math.floor(position.Y + 0.5)
		end

		v16.y = v20
		local hp

		if humanoid then
			hp = math.floor(humanoid.Health + 0.5)
		end

		v16.hp = hp
		v16.rx = math.floor(v14.rx / math.max(v14.n, 1) + 0.5)
		v16.q = v14.q
		v16.foc = v9 and 0 or nil
		v16.menu = v10 and 1 or nil
	else
		local fps

		if v14.n > 0 then
			fps = math.floor(v14.sum / v14.n + 0.5)
		end

		v16.fps = fps
		local low

		if v14.low < 1e999 then
			low = math.floor(v14.low + 0.5)
		end

		v16.low = low
	end

	table.insert(v13, v16)
	v2 = {}
	v9 = false
	v14 = win()
	send()
end

local v16 = nil
local v17 = ""
local v18 = nil
local v19 = nil
local count3 = 0
local v20 = false
local count4 = 0
local v21 = false
local count5 = 0
local v22 = 5
local v23 = nil
local v24 = false

while elapsed() < 1800 do -- inferred equivalent call
	task.wait(1)
	local now = os.clock()
	local v25 = now - v15

	local v26 = not (v25 > 0) and 0 or count2 / v25
	count2 = 0
	local v27 = elapsed() <= 180 -- inferred equivalent call

	local character = LocalPlayer.Character
	local humanoid

	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")
	end

	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	local position

	if humanoidRootPart then
		position = humanoidRootPart.Position
	end

	local st = LocalPlayer:GetAttribute("JoinCovered") == true and "cover"
		or (LocalPlayer.Team == nil or LocalPlayer.Neutral or LocalPlayer:GetAttribute("PickingTeam") == true)
		and "menu"
		or humanoid and (humanoid.Health <= 0 and "dead" or humanoid.SeatPart and "veh" or "alive")
		or "none"

	v14.n += 1
	v14.sum += v26
	v14.low = math.min(v14.low, v26)
	v14.rx += Stats.DataReceiveKbps
	v14.q = math.max(v14.q, ContentProvider.RequestQueueSize)

	if #v14.f < 5 then
		table.insert(v14.f, (math.floor(v26 + 0.5)))
	end

	if position and v16 then
		v14.moved += (position - v16).Magnitude
	end

	if st ~= v17 then
		if v17 == "cover" then
			local v28 = { math.floor(elapsed() * 10 + 0.5) / 10, "cover-", nil } -- inferred equivalent call
			table.insert(v, v28)
		end

		if st == "alive" and v17 ~= "veh" then
			local v28 = { math.floor(elapsed() * 10 + 0.5) / 10, "spawn", nil } -- inferred equivalent call
			table.insert(v, v28)
		elseif st == "dead" then
			local v28 = { math.floor(elapsed() * 10 + 0.5) / 10, "die", nil } -- inferred equivalent call
			table.insert(v, v28)
		elseif st == "veh" then
			local v28

			if humanoid and humanoid.SeatPart then
				v28 = humanoid.SeatPart.Name
			end

			local v29 = { math.floor(elapsed() * 10 + 0.5) / 10, "veh", v28 } -- inferred equivalent call
			table.insert(v, v29)
		end

		v17 = st
	end

	local name

	if LocalPlayer.Team then
		name = LocalPlayer.Team.Name
	end

	if name ~= v18 then
		if name then
			local v28 = { math.floor(elapsed() * 10 + 0.5) / 10, "team", name } -- inferred equivalent call
			table.insert(v, v28)
		end

		v18 = name
	end

	local tool

	if character then
		tool = character:FindFirstChildOfClass("Tool")
	end

	local name2

	if tool then
		name2 = tool.Name
	end

	if name2 ~= v19 then
		if name2 then
			local v28 = { math.floor(elapsed() * 10 + 0.5) / 10, "tool", name2 } -- inferred equivalent call
			table.insert(v, v28)
		end

		v19 = name2
	end

	local v28

	if humanoid == nil then
		v28 = false
	else
		v28 = humanoid.MoveDirection.Magnitude > 0.1
	end

	if v28 then
		v14.mv += 1
		v3 = now
	end

	if v28 and st == "alive" and position then
		if count3 == 0 then
			v23 = position
		end

		count3 += 1

		if v23 and (position - v23).Magnitude > 3 then
			count3 = 0
			v24 = false
		elseif count3 >= 6 and not v24 then
			local v29 = string.format(
				"%d,%d,%d",
				math.floor(position.X),
				math.floor(position.Y),
				(math.floor(position.Z))
			)
			local v30 = { math.floor(elapsed() * 10 + 0.5) / 10, "stuck", v29 } -- inferred equivalent call
			table.insert(v, v30)
			v24 = true
		end
	else
		count3 = 0
		v24 = false
	end

	if st == "alive" and now - v3 > 20 then
		if not v20 then
			local v29 = { math.floor(elapsed() * 10 + 0.5) / 10, "afk", nil } -- inferred equivalent call
			table.insert(v, v29)
			v20 = true
		end
	else
		v20 = false
	end

	if v26 < 10 then
		count4 += 1

		if count4 >= 3 and not v21 then
			local v29 = tostring((math.floor(v26 + 0.5)))
			local v30 = { math.floor(elapsed() * 10 + 0.5) / 10, "low", v29 } -- inferred equivalent call
			table.insert(v, v30)
			v21 = true
		end
	else
		count4 = 0

		if v26 > 15 then
			v21 = false
		end
	end

	if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Freefall then
		count5 += 1

		if count5 == 10 then
			local v29

			if position then
				v29 = string.format(
					"%d,%d,%d",
					math.floor(position.X),
					math.floor(position.Y),
					(math.floor(position.Z))
				)
			end

			local v30 = { math.floor(elapsed() * 10 + 0.5) / 10, "fall", v29 } -- inferred equivalent call
			table.insert(v, v30)
		end
	else
		count5 = 0
	end

	if v27 then
		pollScreens()
	end

	if v22 <= elapsed() then -- inferred equivalent call
		closeWindow(v27, st, position, humanoid)
		v22 = elapsed() + (elapsed() <= 180 and 5 or 60) -- inferred equivalent call
	end

	v16 = position
	v15 = now
end

send()

for _, connection in connections do
	connection:Disconnect()
end