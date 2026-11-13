local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")

local flag = false
local count = 0

local function terrainPlain()
	local terrain = workspace.Terrain
	local v = {}

	for i = 0, 63 do
		local materialSlot, v2, v3 = terrain:GetMaterialSlot(i)

		if not (materialSlot ~= nil and type(v2) == "string" and v2 ~= "") then
			continue
		end

		v[i] = { materialSlot, v2, v3 }
		terrain:SetMaterialSlot(i, materialSlot, "", v3)
		count += 1
	end

	return function()
		for k, v2 in v do
			terrain:SetMaterialSlot(k, v2[1], v2[2], v2[3])
		end
	end
end

local function sample(duration: number, gpu, cpu, frame, unixTimestampMillises)
	table.insert(unixTimestampMillises, DateTime.now().UnixTimestampMillis)
	local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		table.insert(gpu, Stats.RenderGPUFrameTime * 1000)
		table.insert(cpu, Stats.RenderCPUFrameTime * 1000)
		table.insert(frame, dt * 1000)
	end)
	task.wait(duration)
	renderSteppedConnection:Disconnect()
	table.insert(unixTimestampMillises, DateTime.now().UnixTimestampMillis)
end

local function median(list) -- 3 equivalent calls inferred from this helper
	if #list == 0 then
		return 0
	end

	table.sort(list)
	return math.floor(list[(#list + 1) // 2] * 100 + 0.5) / 100
end

local function newSide()
	return { gpu = {}, cpu = {}, frame = {} }
end

local function summary(data)
	return {
		gpu = median(data.gpu), -- inferred equivalent call
		cpu = median(data.cpu), -- inferred equivalent call
		frame = median(data.frame), -- inferred equivalent call
		n = #data.frame
	}
end

local function groupOf(part)
	while part.Parent and part.Parent ~= workspace do
		part = part.Parent
	end

	if part.Parent ~= workspace or part == workspace.Terrain then
		return nil
	end

	if part == workspace.CurrentCamera then
		return "camera"
	end

	if part:IsA("Model") and Players:GetPlayerFromCharacter(part) then
		return "characters"
	end

	return if part:IsA("BasePart") then "loose parts" else part.Name
end

local function hideParts(fn)
	local localTransparencyModifiersByPart = {}
	local count2 = 0

	for _, part in workspace:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		local v = groupOf(part)

		if not (v and fn(v)) then
			continue
		end

		localTransparencyModifiersByPart[part] = part.LocalTransparencyModifier
		part.LocalTransparencyModifier = 1
		count2 += 1
		count += 1

		if count2 % 2000 == 0 then
			task.wait()
		end
	end

	local descendantAddedConnection = workspace.DescendantAdded:Connect(function(part)
		if part:IsA("BasePart") then
			local v = groupOf(part)

			if v and fn(v) then
				localTransparencyModifiersByPart[part] = part.LocalTransparencyModifier
				part.LocalTransparencyModifier = 1
			end
		end
	end)
	return function()
		descendantAddedConnection:Disconnect()
		local count3 = 0

		for k, localTransparencyModifier in localTransparencyModifiersByPart do
			if k.Parent then
				k.LocalTransparencyModifier = localTransparencyModifier
			end

			count3 += 1

			if count3 % 2000 == 0 then
				task.wait()
			end
		end
	end
end

local function setAll(items, p: string, p2)
	local v = {}

	for _, item in items do
		if item[p] == p2 then
			continue
		end

		v[item] = item[p]
		item[p] = p2
		count += 1
	end

	return function()
		for k, v2 in v do
			if k.Parent then
				k[p] = v2
			end
		end
	end
end

local function hud()
	local layerCollectors = {}

	for _, layerCollector in Players.LocalPlayer.PlayerGui:GetChildren() do
		if layerCollector:IsA("LayerCollector") and layerCollector.Enabled then
			table.insert(layerCollectors, layerCollector)
		end
	end

	return setAll(layerCollectors, "Enabled", false)
end

local function screens()
	local result = {}

	for _, layerCollector in Players.LocalPlayer.PlayerGui:GetChildren() do
		if not (layerCollector:IsA("LayerCollector") and layerCollector.Enabled) then
			continue
		end

		local count2 = 0
		local total = 0
		local total2 = 0
		local function walk(layerCollector2)
			for _, child in layerCollector2:GetChildren() do
				if child:IsA("GuiObject") then
					if child.Visible then
						count2 += 1
						walk(child)
					end
				elseif child:IsA("UIStroke") then
					total += child.Enabled and 1 or 0
				elseif child:IsA("UIGradient") then
					total2 += child.Enabled and 1 or 0
				else
					walk(child)
				end
			end
		end
		walk(layerCollector)
		table.insert(result, {
			gui = layerCollector,
			shown = count2,
			strokes = total,
			gradients = total2
		})
	end

	table.sort(result, function(a, b): boolean
		return a.shown > b.shown
	end)

	return result
end

local function postFx()
	local postEffects = {}

	for _, postEffect in Lighting:GetChildren() do
		if postEffect:IsA("PostEffect") and postEffect.Enabled then
			table.insert(postEffects, postEffect)
		end
	end

	return setAll(postEffects, "Enabled", false)
end

local function hudDescendants(fn)
	local descendants = {}

	for _, layerCollector in Players.LocalPlayer.PlayerGui:GetChildren() do
		if not (layerCollector:IsA("LayerCollector") and layerCollector.Enabled) then
			continue
		end

		for _, descendant in layerCollector:GetDescendants() do
			if fn(descendant) then
				table.insert(descendants, descendant)
			end
		end
	end

	return descendants
end

local function tapeSlats()
	return setAll(hudDescendants(function(frame)
		local v = frame:IsA("Frame")

		if v then
			return frame.Name == "Slat" and frame.Visible
		end

		return v
	end), "Visible", false)
end

local function gradients()
	return setAll(hudDescendants(function(uiGradient)
		return uiGradient:IsA("UIGradient") and uiGradient.Enabled
	end), "Enabled", false)
end

local function strokes()
	return setAll(hudDescendants(function(uiStroke)
		return uiStroke:IsA("UIStroke") and uiStroke.Enabled
	end), "Enabled", false)
end

local function grade()
	local grade2 = Lighting:FindFirstChild("Grade")

	if grade2 and grade2:IsA("PostEffect") then
		return setAll({ grade2 }, "Enabled", false)
	end

	return function() end
end

local function atmosphere()
	local atmosphere2 = Lighting:FindFirstChildOfClass("Atmosphere")

	if not atmosphere2 then
		return function() end
	end

	atmosphere2.Parent = nil
	count += 1
	return function()
		atmosphere2.Parent = Lighting
	end
end

local function clouds()
	local clouds2 = workspace.Terrain:FindFirstChildOfClass("Clouds")

	if clouds2 and clouds2.Enabled then
		return setAll({ clouds2 }, "Enabled", false)
	end

	return function() end
end

local function voxel() -- 4 equivalent calls inferred from this helper
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	return ReplicatedStorage:WaitForChild("Voxel")
end

local function mobileTier(): boolean -- 1 equivalent call inferred from this helper
	return require(voxel():WaitForChild("Detail")).low == true -- inferred equivalent call
end

local function prepShadows()
	local v = voxel() -- inferred equivalent call
	local mobileShadows = v:GetAttribute("MobileShadows")

	if not mobileTier() or mobileShadows ~= false then -- inferred equivalent call
		return function() end
	end

	v:SetAttribute("MobileShadows", true)
	return function()
		v:SetAttribute("MobileShadows", mobileShadows)
	end
end

local function shadows()
	if require(voxel():WaitForChild("Detail")).low ~= true then -- inferred equivalent call
		return setAll({ Lighting }, "GlobalShadows", false)
	end

	local v = voxel() -- inferred equivalent call

	if v:GetAttribute("MobileShadows") == false or not Lighting.GlobalShadows then
		return function() end
	end

	v:SetAttribute("MobileShadows", false)
	count += 1
	return function()
		v:SetAttribute("MobileShadows", true)
	end
end

local function terrainNormals()
	local terrain = workspace.Terrain
	local MaterialService = game:GetService("MaterialService")
	local v = {}

	for i = 0, 63 do
		local materialSlot, v2, v3 = terrain:GetMaterialSlot(i)

		if not (materialSlot ~= nil and type(v2) == "string" and v2 ~= "") then
			continue
		end

		local child = MaterialService:FindFirstChild(v2 .. "NoN", true)
		assert(child, "[gpuprobe] no " .. v2 .. "NoN in MaterialService.ProbeNoNormal")
		v[i] = { materialSlot, v2, v3 }
		terrain:SetMaterialSlot(i, materialSlot, child.Name, v3)
		count += 1
	end

	return function()
		for k, v2 in v do
			terrain:SetMaterialSlot(k, v2[1], v2[2], v2[3])
		end
	end
end

local function effects()
	local effects2 = {}

	for _, effect in workspace:GetDescendants() do
		if not ((effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) and effect.Enabled) then
			continue
		end

		table.insert(effects2, effect)
	end

	return setAll(effects2, "Enabled", false)
end

local function groups()
	local v = {}

	for _, part in workspace:GetDescendants() do
		if not (part:IsA("BasePart") and part.Transparency < 1) then
			continue
		end

		local v2 = groupOf(part)

		if v2 then
			v[v2] = (v[v2] or 0) + 1
		end
	end

	local result = {}

	for k, v2 in v do
		if v2 >= 20 then
			table.insert(result, k)
		end
	end

	table.sort(result, function(a, b): boolean
		return v[a] > v[b]
	end)

	while #result > 6 do
		table.remove(result)
	end

	return result
end

local function quality()
	local success, result = pcall(function()
		local UserGameSettings = UserSettings():GetService("UserGameSettings")
		return UserGameSettings.SavedQualityLevel.Value
	end)

	return if success and type(result) == "number" then result else nil
end

local function sweep(p: string)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local reportClient = ReplicatedStorage.Voxel.Remotes.ReportClient
	local run = string.sub(HttpService:GenerateGUID(false), 1, 8)
	local currentCamera = workspace.CurrentCamera

	local v = {
		{ name = "grade", off = grade },
		{ name = "postfx", off = postFx },
		{ name = "atmosphere", off = atmosphere },
		{ name = "clouds", off = clouds },
		{ name = "shadows", off = shadows, prep = prepShadows, settle = 3.5 },
		{ name = "terrain:normals", off = terrainNormals, settle = 2.5 },
		{ name = "terrain:plain", off = terrainPlain, settle = 2.5 },
		{
			name = "group:camera",
			off = function()
				return hideParts(function(p2): boolean
					return p2 == "camera"
				end)
			end
		},
		{
			name = "world:parts",
			settle = 2.5,
			off = function()
				return hideParts(function(p2): boolean
					return p2 ~= "camera"
				end)
			end
		}
	}

	local v2 = p ~= "lighting" and {
		{ name = "hud", off = hud },
		{ name = "hud:tape", off = tapeSlats },
		{ name = "hud:gradients", off = gradients },
		{ name = "hud:strokes", off = strokes }
	} or v

	local v3 = p == "lighting" and 5 or 0

	for _, v4 in p == "lighting" and {} or screens() do
		if v3 >= 5 or v4.shown < 10 then
			break
		end

		v3 += 1
		table.insert(v2, {
			name = "gui:" .. v4.gui.Name,
			info = { shown = v4.shown, strokes = v4.strokes, gradients = v4.gradients },
			off = function()
				return setAll({ v4.gui }, "Enabled", false)
			end
		})
	end

	if p ~= "lighting" then
		for _, v4 in v do
			table.insert(v2, v4)
		end

		table.insert(v2, { name = "effects", off = effects })
	end

	for _, v4 in p == "lighting" and {} or groups() do
		table.insert(v2, {
			name = "group:" .. v4,
			off = function()
				return hideParts(function(p2): boolean
					return p2 == v4
				end)
			end
		})
	end

	print(string.format("[gpuprobe] run %s: %d steps, about %d s. Hold still.", run, #v2, #v2 * 3 * 2 * 3))
	local v4 = { string.format("gpuprobe %s  (ms: gpu / cpu / frame, on -> off)", run) }

	for k, v5 in v2 do
		local v6 = newSide()
		local v7 = newSide()

		local settle = v5.settle or 1.5
		local fn = not v5.prep and function() end or v5.prep()
		local v8 = {}
		local flag2 = false

		for _ = 1, 3 do
			task.wait(settle)
			sample(1.5, v6.gpu, v6.cpu, v6.frame, v8)
			count = 0
			local v9 = v5.off()

			if count == 0 then
				v9()
				flag2 = true
				break
			end

			task.wait(settle)
			sample(1.5, v7.gpu, v7.cpu, v7.frame, v8)
			v9()
		end

		fn()

		if flag2 then
			print("[gpuprobe] " .. v5.name .. ": nothing on to switch off, skipped")
		else
			local count2 = count
			local on = summary(v6)
			local off = summary(v7)
			local v9 = string.format(
				"%-24s gpu %5.1f -> %5.1f  cpu %5.1f -> %5.1f  frame %5.1f -> %5.1f",
				v5.name,
				on.gpu,
				off.gpu,
				on.cpu,
				off.cpu,
				on.frame,
				off.frame
			)
			print("[gpuprobe] " .. v9)
			table.insert(v4, v9)

			local probe = {
				run = run,
				step = v5.name,
				i = k,
				of = #v2,
				on = on,
				off = off,
				w = math.floor(currentCamera.ViewportSize.X + 0.5),
				h = math.floor(currentCamera.ViewportSize.Y + 0.5),
				quality = 0,
				parts = 0,
				look = 0,
				info = 0,
				count = 0,
				t = 0
			}
			local success, result = pcall(function()
				local UserGameSettings = UserSettings():GetService("UserGameSettings")
				return UserGameSettings.SavedQualityLevel.Value
			end)

			if not success or type(result) ~= "number" then
				result = nil
			end

			probe.quality = result
			probe.parts = Stats.PrimitivesCount
			probe.look = {
				currentCamera.CFrame.Position.X,
				currentCamera.CFrame.Position.Y,
				currentCamera.CFrame.Position.Z
			}
			probe.info = v5.info
			probe.count = count2
			probe.t = v8
			reportClient:FireServer({ probe = probe })
		end
	end

	print("[gpuprobe] done\n" .. table.concat(v4, "\n"))
	flag = false
end

return {
	Name = "gpuprobe",
	Description = "Times the frame with and without each thing drawn (HUD, effects, each world group...); results go to analytics. Hold still ~5 min (lighting: ~2).",
	Group = "Voxel",
	Args = {
		{
			Type = "probeSet",
			Name = "set",
			Description = "all (default) or lighting",
			Optional = true
		}
	},
	ClientRun = function(_, value: string?)
		if flag then
			return "gpuprobe is already running"
		end

		flag = true
		task.spawn(function()
			local success, result = pcall(sweep, value or "all")

			if not success then
				flag = false
				warn("[gpuprobe] " .. tostring(result))
			end
		end)
		return "gpuprobe " .. (value or "all") .. " started: hold still on a typical view (progress in F9)"
	end
}