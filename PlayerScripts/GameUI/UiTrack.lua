local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local reportUI = nil
return {
	send = function(p: string, p2: string?)
		if not (RunService:IsRunning() and RunService:IsClient()) then
			return
		end

		if not reportUI then
			reportUI = ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("Remotes"):WaitForChild("ReportUI")
		end

		reportUI:FireServer(p, p2)
	end
}