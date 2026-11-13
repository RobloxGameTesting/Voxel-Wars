local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local v = {
	"BotRigs",
	"VehicleHulls",
	"Helicopters",
	"VoxelWorld",
	"VoxelLoose",
	"VoxelChips",
	"VoxelFalling",
	"GroundFireFX",
	"DamageSmokeFX",
	"VehicleDamageFX",
	"VoxelFireFX"
}

local function measure()
	local lastTime = 0
	local v2 = {}
	local count = 0
	local preSimulationConnection = RunService.PreSimulation:Connect(function()
		lastTime = os.clock()
	end)
	local postSimulationConnection = RunService.PostSimulation:Connect(function()
		table.insert(v2, (os.clock() - lastTime) * 1000)
	end)
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		count += 1
	end)
	task.wait(6)
	preSimulationConnection:Disconnect()
	postSimulationConnection:Disconnect()
	renderSteppedConnection:Disconnect()
	local total = 0
	local maxValue = 0
	local count2 = 0

	for _, v3 in v2 do
		total += v3
		maxValue = math.max(maxValue, v3)

		if v3 > 8 then
			count2 += 1
		end
	end

	return string.format(
		"sim avg %5.2f ms  spikes>%dms %3d  worst %5.1f  fps %3d",
		total / math.max(#v2, 1),
		8,
		count2,
		maxValue,
		(math.floor(count / 6))
	)
end

return {
	Name = "hitchprobe",
	Description = "Times the simulation step with each world folder taken out in turn, to find what hitches (this screen only, ~1 min).",
	Group = "Voxel",
	Args = {},
	ClientRun = function()
		local character = Players.LocalPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local anchored = humanoidRootPart and humanoidRootPart.Anchored

		if humanoidRootPart then
			humanoidRootPart.Anchored = true
		end

		local v2 = { "hitchprobe (" .. 6 .. " s each)" }
		table.insert(v2, string.format("%-16s %s", "all in", measure()))

		for _, childName in v do
			local child = workspace:FindFirstChild(childName)

			if not child then
				continue
			end

			child.Parent = nil
			task.wait(0.3)
			local v3 = measure()
			child.Parent = workspace
			table.insert(v2, string.format("%-16s %s", "no " .. childName, v3))
			task.wait(0.3)
		end

		table.insert(v2, string.format("%-16s %s", "all in again", measure()))

		if humanoidRootPart and humanoidRootPart.Parent then
			humanoidRootPart.Anchored = anchored == true
		end

		local joined = table.concat(v2, "\n")
		print(joined)
		return joined
	end
}