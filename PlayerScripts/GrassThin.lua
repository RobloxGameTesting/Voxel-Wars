local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local Detail = require(Voxel:WaitForChild("Detail"))
local Quality = require(Voxel:WaitForChild("Quality"))
local MapSelect = require(Voxel:WaitForChild("MapSelect"))

local LocalPlayer = Players.LocalPlayer
local Terrain = workspace.Terrain

local success, result = pcall(function()
	return Terrain.Decoration
end)
local v = not success or result == true
local v2

if success then
	v2 = nil
else
	v2 = false
end

local UserGameSettings = UserSettings():GetService("UserGameSettings")

local function lowGraphics(): boolean -- 2 equivalent calls inferred from this helper
	local savedQualityLevel = UserGameSettings.SavedQualityLevel
	return savedQualityLevel ~= Enum.SavedQualitySetting.Automatic and savedQualityLevel.Value <= 4
end

local function wantOff() -- 1 equivalent call inferred from this helper
	local v3 = v

	if not v3 then
		return v3
	end

	if Voxel:GetAttribute("GrassThin") == false then
		v3 = false
		return false
	end

	v3 = Detail.low

	if v3 then
		return v3
	end

	if Detail.strain >= 1 then
		v3 = true
		return true
	end

	v3 = Quality.potato

	if v3 then
		return v3
	end

	local savedQualityLevel = UserGameSettings.SavedQualityLevel
	return savedQualityLevel ~= Enum.SavedQualitySetting.Automatic and savedQualityLevel.Value <= 4
end

local function update()
	local v3 = wantOff() -- inferred equivalent call

	if v2 ~= false then
		local decoration = v and not v3
		local success2, result2 = pcall(function()
			if Terrain.Decoration ~= decoration then
				Terrain.Decoration = decoration
				v2 = true
			end
		end)

		if not success2 then
			v2 = false
			warn("[GrassThin] Terrain.Decoration can't be set on this client (" .. tostring(result2) .. "): laying grass flat instead")
		end
	end

	LocalPlayer:SetAttribute("GrassOff", v3)
	LocalPlayer:SetAttribute("GrassSwitch", v2)
end

Detail.onStrain(function()
	update()
end)
Quality.onChanged(function()
	update()
end)
UserGameSettings:GetPropertyChangedSignal("SavedQualityLevel"):Connect(update)
Voxel:GetAttributeChangedSignal("GrassThin"):Connect(update)
update()

assert(true, "[GrassThin] STRIPS must divide CHUNK")
local v3 = { [2] = 40, [23] = 40, [37] = 41 }

local v4 = 0
local total = 0
local v5 = {}
local v6 = {}

local function hold() -- 1 equivalent call inferred from this helper
	v4 = os.clock() + 8
	table.clear(v5)
	table.clear(v6)
end
MapSelect.onChange(function()
	hold() -- inferred equivalent call
end, 20)
Voxel:WaitForChild("Remotes"):WaitForChild("WorldReset").OnClientEvent:Connect(hold)

local function thin(cx: number, cz: number, p: number)
	local v7 = Vector3.new(cx * 32 + p * 8, -10, cz * 32) * 4
	local v8 = Vector3.new(cx * 32 + (p + 1) * 8, 35, (cz + 1) * 32) * 4
	local region = Region3.new(v7, v8)
	local solidMaterialIndex = Terrain:ReadVoxelChannels(region, 4, { "SolidMaterialIndex" }).SolidMaterialIndex
	local count = 0

	for i = 1, #solidMaterialIndex do
		local v9 = solidMaterialIndex[i]

		for j = 1, #v9 do
			local v10 = v9[j]

			for k = 1, #v10 do
				local v11 = v3[v10[k]]

				if not v11 then
					continue
				end

				v10[k] = v11
				count += 1
			end
		end
	end

	if count > 0 then
		Terrain:WriteVoxelChannels(region, 4, { SolidMaterialIndex = solidMaterialIndex })
		total += count
		LocalPlayer:SetAttribute("GrassFlat", total)
	end

	return count
end

local function active() -- 2 equivalent calls inferred from this helper
	local v7

	if v2 == false then
		v7 = v

		if v7 then
			if Voxel:GetAttribute("GrassThin") == false then
				v7 = false
			else
				v7 = Detail.low

				if not v7 then
					if Detail.strain >= 1 then
						v7 = true
					else
						v7 = Quality.potato or lowGraphics() -- inferred equivalent call
					end
				end
			end
		end

		if v7 then
			local now = os.clock()

			if v4 <= now and LocalPlayer:GetAttribute("JoinMeshed") ~= nil then
				return LocalPlayer:GetAttribute("WorldMeshing") ~= true
			end

			return false
		end
	else
		return false
	end

	return v7
end

local function sweep()
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local position = currentCamera.CFrame.Position
	local v7 = math.floor(position.X / 128)
	local v8 = math.floor(position.Z / 128)
	local v9 = {}

	for i = v8 - 3, v8 + 3 do
		for j = v7 - 3, v7 + 3 do
			local v10 = v5[(j + 32768) * 65536 + (i + 32768)]

			if not (v10 == nil or os.clock() - v10 >= 30) then
				continue
			end

			local v11 = (j + 0.5) * 128 - position.X
			local v12 = (i + 0.5) * 128 - position.Z
			table.insert(v9, {
				cx = j,
				cz = i,
				d = v11 * v11 + v12 * v12
			})
		end
	end

	table.sort(v9, function(a, b): boolean
		return a.d < b.d
	end)

	for _, v10 in v9 do
		if not active() then -- inferred equivalent call
			break
		end

		local v11 = (v10.cx + 32768) * 65536 + (v10.cz + 32768)
		local lastTime = os.clock()

		local v12 = v5[v11] ~= nil
		local v13, v14

		if v12 then
			v13 = v6[v11] or 0
			v6[v11] = (v13 + 1) % 4
			v14 = thin(v10.cx, v10.cz, v13)
		else
			v14 = 0
			v13 = 0
		end

		if not v12 or v14 > 0 then
			for i = 0, 3 do
				if not (not v12 or i ~= v13) then
					continue
				end

				if i > 0 or v12 then
					task.wait()

					if not active() then -- inferred equivalent call
						return
					end
				end

				v14 += thin(v10.cx, v10.cz, i)
			end
		end

		local v15

		if v14 == 0 then
			v15 = os.clock()
		end

		v5[v11] = v15

		task.wait((math.max(0.2 - (os.clock() - lastTime), 0)))
	end
end

while true do
	task.wait(1)
	local v7

	if v2 == false then
		if v then
			if Voxel:GetAttribute("GrassThin") == false then
				v7 = false
			else
				v7 = Detail.low

				if not v7 then
					if Detail.strain >= 1 then
						v7 = true
					else
						v7 = Quality.potato or lowGraphics() -- inferred equivalent call
					end
				end
			end
		else
			v7 = v
		end

		if v7 then
			if v4 <= os.clock() and LocalPlayer:GetAttribute("JoinMeshed") ~= nil then
				v7 = LocalPlayer:GetAttribute("WorldMeshing") ~= true
			else
				v7 = false
			end
		end
	else
		v7 = false
	end

	if v7 then
		sweep()
	end
end