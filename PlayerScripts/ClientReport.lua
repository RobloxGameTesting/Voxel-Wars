local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VRService = game:GetService("VRService")

local reportClient = ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("Remotes"):WaitForChild("ReportClient")
local Stats = game:GetService("Stats")
local Detail = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("Detail"))
local Quality = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("Quality"))
local ClientWorld = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("ClientWorld"))
local PoseTiming = require(ReplicatedStorage:WaitForChild("Vehicles"):WaitForChild("PoseTiming"))

local function platform(vector2: Vector2): string -- 1 equivalent call inferred from this helper
	if VRService.VREnabled then
		return "vr"
	end

	if GuiService:IsTenFootInterface() then
		return "console"
	end

	if UserInputService.TouchEnabled and not (UserInputService.KeyboardEnabled or UserInputService.MouseEnabled) then
		if math.min(vector2.X, vector2.Y) >= 600 then
			return "tablet"
		end

		return "phone"
	end

	return "pc"
end

local function quality()
	local success, result = pcall(function()
		local UserGameSettings = UserSettings():GetService("UserGameSettings")
		return UserGameSettings.SavedQualityLevel.Value
	end)

	return if success and type(result) == "number" then result else nil
end

local count = 0
local v = os.clock()
local total = 0
local total2 = 0
local minValue = 1e999
local function countFrame() -- 1 equivalent call inferred from this helper
	count += 1
	local now = os.clock()
	local v2 = now - v

	if v2 > 2 then
		count = 0
		v = now
	elseif v2 >= 1 then
		minValue = math.min(minValue, count / v2)
		total += count
		total2 += v2
		count = 0
		v = now
	end
end

local v2 = table.create(128, 0)
local nows = table.create(128, -1e999)

local v3 = {}
local v4 = 0

for _, v5 in { "blastn", "blastf", "bomb", "strike", "heli", "scope", "snipe" } do
	v3[v5] = {
		n = 0,
		pre = 0,
		post = 0,
		max = 0,
		openUntil = -1e999,
		worst = 0,
		before = 0
	}
end

local function hxClose(state) -- 1 equivalent call inferred from this helper
	state.n += 1
	state.pre += state.before
	state.post += state.worst
	state.max = math.max(state.max, state.worst)
	state.openUntil = -1e999
end
function Detail.onMark(p: string, vector3: Vector3?)
	if p == "blast" then
		local currentCamera = workspace.CurrentCamera
		p = vector3 and currentCamera and (vector3 - currentCamera.CFrame.Position).Magnitude > 150 and "blastf"
			or "blastn"
	end

	local v5 = v3[p]
	local now = os.clock()

	if v5 == nil or now < v5.openUntil then
		return
	end

	local maxValue = 0

	for i = 1, 128 do
		if now - nows[i] <= 1 then
			maxValue = math.max(maxValue, v2[i])
		end
	end

	local openUntil = now + 1
	v5.before = maxValue
	v5.worst = 0
	v5.openUntil = openUntil
end

RunService.RenderStepped:Connect(function(dt: number)
	countFrame() -- inferred equivalent call
	local now = os.clock()
	local v5 = math.min(dt, 1) * 1000
	v4 = v4 % 128 + 1
	local v6 = v4
	v2[v4] = v5
	nows[v6] = now

	for _, v7 in v3 do
		if not (v7.openUntil > -1e999) then
			continue
		end

		v7.worst = math.max(v7.worst, v5)

		if v7.openUntil <= now then
			hxClose(v7) -- inferred equivalent call
		end
	end
end)

local v5 = {
	n = 0,
	cpu = 0,
	gpu = 0,
	script = 0,
	phys = 0,
	rx = 0,
	tx = 0,
	prx = 0
}
task.spawn(function()
	while true do
		task.wait(1)
		v5.n += 1
		v5.cpu += Stats.RenderCPUFrameTime * 1000
		v5.gpu += Stats.RenderGPUFrameTime * 1000
		v5.script += Stats.HeartbeatTimeMs
		v5.phys += Stats.PhysicsStepTimeMs
		v5.rx += Stats.DataReceiveKbps
		v5.prx += Stats.PhysicsReceiveKbps
		v5.tx += Stats.DataSendKbps
	end
end)
local function r2(p: number) -- 14 equivalent calls inferred from this helper
	return math.floor(p * 100 + 0.5) / 100
end

local function mb(p) -- 14 equivalent calls inferred from this helper
	if Stats.MemoryTrackingEnabled then
		return (math.floor(Stats:GetMemoryUsageMbForTag(p) + 0.5))
	end

	return nil
end

local function gfx()
	local total3 = 0

	for _, v6 in {
		Enum.DeveloperMemoryTag.GraphicsTexture,
		Enum.DeveloperMemoryTag.GraphicsTextureCharacter,
		Enum.DeveloperMemoryTag.GraphicsParts,
		Enum.DeveloperMemoryTag.GraphicsMeshParts,
		Enum.DeveloperMemoryTag.GraphicsTerrain,
		Enum.DeveloperMemoryTag.GraphicsParticles
	} do
		local v7 = mb(v6) -- inferred equivalent call

		if v7 == nil then
			return nil
		end

		total3 += v7
	end

	return total3
end

local function perf()
	if v5.n == 0 then
		return nil
	end

	local n = v5.n
	local result = {}
	result.cpu = r2(v5.cpu / n) -- inferred equivalent call
	result.gpu = r2(v5.gpu / n) -- inferred equivalent call
	result.script = r2(v5.script / n) -- inferred equivalent call
	result.phys = r2(v5.phys / n) -- inferred equivalent call
	result.rx = r2(v5.rx / n) -- inferred equivalent call
	result.tx = r2(v5.tx / n) -- inferred equivalent call
	result.prx = r2(v5.prx / n) -- inferred equivalent call
	result.mem = math.floor(Stats:GetTotalMemoryUsageMb() + 0.5)
	result.lua = mb(Enum.DeveloperMemoryTag.LuaHeap) -- inferred equivalent call
	result.snd = mb(Enum.DeveloperMemoryTag.Sounds) -- inferred equivalent call
	result.gfx = gfx()
	result.gui = mb(Enum.DeveloperMemoryTag.Gui) -- inferred equivalent call

	result.heap = math.floor(gcinfo() / 1024 + 0.5)
	result.ssnd = mb(Enum.DeveloperMemoryTag.StreamingSounds) -- inferred equivalent call
	result.inst = mb(Enum.DeveloperMemoryTag.Instances) -- inferred equivalent call
	result.sig = mb(Enum.DeveloperMemoryTag.Signals) -- inferred equivalent call
	result.bpart = mb(Enum.DeveloperMemoryTag.BaseParts) -- inferred equivalent call
	result.physm = mb(Enum.DeveloperMemoryTag.PhysicsCollision) -- inferred equivalent call
	result.csg = mb(Enum.DeveloperMemoryTag.GeometryCSG) -- inferred equivalent call
	result.scrm = mb(Enum.DeveloperMemoryTag.Script) -- inferred equivalent call
	result.anim = mb(Enum.DeveloperMemoryTag.Animation) -- inferred equivalent call
	result.http = mb(Enum.DeveloperMemoryTag.HttpCache) -- inferred equivalent call
	result.intl = mb(Enum.DeveloperMemoryTag.Internal) -- inferred equivalent call
	result.parts = Stats.PrimitivesCount
	local boxes

	if ClientWorld.boxCount then
		boxes = ClientWorld.boxCount()
	end

	result.boxes = boxes
	result.budget = r2(Detail.budget) -- inferred equivalent call
	result.strain = Detail.strain

	local Players = game:GetService("Players")
	result.grass_off = Players.LocalPlayer:GetAttribute("GrassOff") == true
	local Players2 = game:GetService("Players")
	local grass_sw

	if Players2.LocalPlayer:GetAttribute("GrassSwitch") ~= nil then
		local Players3 = game:GetService("Players")
		grass_sw = Players3.LocalPlayer:GetAttribute("GrassSwitch") == true and 1 or 0
	end

	result.grass_sw = grass_sw
	local Players3 = game:GetService("Players")
	result.flat = Players3.LocalPlayer:GetAttribute("GrassFlat")
	result.low = Detail.low
	result.potato = Quality.potato
	local Players4 = game:GetService("Players")
	result.auto = Players4.LocalPlayer:GetAttribute("PotatoAuto") == true

	local Players5 = game:GetService("Players")
	result.meshing = Players5.LocalPlayer:GetAttribute("WorldMeshing") == true
	local Players6 = game:GetService("Players")
	result.lobby = Players6.LocalPlayer.Team == nil

	for k, v6 in Detail.spent do
		result["t_" .. k] = r2(v6 * 1000 / math.max(total, 1)) -- inferred equivalent call
		Detail.spent[k] = 0
	end

	for k, v6 in v3 do
		if not (v6.n > 0) then
			continue
		end

		result["hx_" .. k .. "_n"] = v6.n
		result["hx_" .. k .. "_pre"] = r2(v6.pre / v6.n) -- inferred equivalent call
		result["hx_" .. k .. "_post"] = r2(v6.post / v6.n) -- inferred equivalent call
		result["hx_" .. k .. "_max"] = r2(v6.max) -- inferred equivalent call
		v6.n = 0
		v6.pre = 0
		v6.post = 0
		v6.max = 0
	end

	local stats = PoseTiming.stats
	local gaps = stats.gaps
	local vheld = r2(stats.held) -- inferred equivalent call
	local vfroz = r2(stats.frozen) -- inferred equivalent call
	local snaps = stats.snaps
	result.vgap = gaps
	result.vheld = vheld
	result.vfroz = vfroz
	result.vsnap = snaps
	stats.gaps = 0
	stats.held = 0
	stats.frozen = 0
	stats.snaps = 0
	v5.n = 0
	v5.cpu = 0
	v5.gpu = 0
	v5.script = 0
	v5.phys = 0
	v5.rx = 0
	v5.tx = 0
	v5.prx = 0
	return result
end

local count2 = 0
local lastTime = -1e999
local function report(flag: boolean, join)
	count2 += 1
	lastTime = os.clock()
	local currentCamera = workspace.CurrentCamera
	local v6

	if currentCamera then
		v6 = currentCamera.ViewportSize
	else
		v6 = Vector2.zero
	end

	local v7 = {
		join = join,
		platform = platform(v6), -- inferred equivalent call
		w = math.floor(v6.X + 0.5),
		h = math.floor(v6.Y + 0.5),
		quality = 0,
		fps = 0,
		low = 0,
		touch = 0,
		keyboard = 0,
		mouse = 0,
		gamepad = 0,
		perf = 0
	}
	local success, result = pcall(function()
		local UserGameSettings = UserSettings():GetService("UserGameSettings")
		return UserGameSettings.SavedQualityLevel.Value
	end)

	if not success or type(result) ~= "number" then
		result = nil
	end

	v7.quality = result
	local fps

	if flag and total2 > 0 then
		fps = math.floor(total / total2 * 10 + 0.5) / 10
	end

	v7.fps = fps
	local low

	if flag and count2 > 2 and minValue < 1e999 then
		low = math.floor(minValue * 10 + 0.5) / 10
	end

	v7.low = low
	v7.touch = UserInputService.TouchEnabled
	v7.keyboard = UserInputService.KeyboardEnabled
	v7.mouse = UserInputService.MouseEnabled
	v7.gamepad = UserInputService.GamepadEnabled
	local perf2

	if flag then
		perf2 = perf()
	end

	v7.perf = perf2
	reportClient:FireServer(v7)

	total = 0
	total2 = 0
	minValue = 1e999
end

local v6 = {
	"JoinLoaded",
	"JoinBuilt",
	"JoinAsked",
	"JoinSynced",
	"JoinNear",
	"JoinMeshed",
	"JoinHud",
	"JoinBody",
	"JoinDone"
}

task.spawn(function()
	local Players = game:GetService("Players")
	local localPlayer = Players.LocalPlayer

	while localPlayer:GetAttribute("JoinDone") == nil do
		localPlayer:GetAttributeChangedSignal("JoinDone"):Wait()
	end

	local lastTime2 = os.clock()

	while localPlayer:GetAttribute("JoinMeshed") == nil and os.clock() - lastTime2 < 10 do
		task.wait(0.5)
	end

	local joinT0 = localPlayer:GetAttribute("JoinT0")
	assert(type(joinT0) == "number", "ClientReport: JoinDone without JoinT0")
	local join = {
		timeout = localPlayer:GetAttribute("JoinTimedOut") == true,
		snapKB = localPlayer:GetAttribute("JoinSnapKB"),
		snapRawKB = localPlayer:GetAttribute("JoinSnapRawKB")
	}

	for _, attributeName in v6 do
		local attribute = localPlayer:GetAttribute(attributeName)

		if type(attribute) == "number" then
			join[string.lower((string.sub(attributeName, 5)))] = math.floor((attribute - joinT0) * 100 + 0.5) / 100
		end
	end

	local v7 = 5.5 - (os.clock() - lastTime)

	if v7 > 0 then
		task.wait(v7)
	end

	report(false, join)
end)

task.wait(1)
report(false)
task.wait(15)

while true do
	report(true)
	task.wait(60)
end