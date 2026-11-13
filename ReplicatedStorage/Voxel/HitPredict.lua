local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
assert(LocalPlayer, "[HitPredict] client only")

local NetClock = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("NetClock"))

local bindableEvent = Instance.new("BindableEvent")
local bindableEvent2 = Instance.new("BindableEvent")
local HitPredict = {}

HitPredict.predicted = bindableEvent.Event
HitPredict.confirmed = bindableEvent2.Event

local nows = {}
local v = {}

local function window() -- 2 equivalent calls inferred from this helper
	local success, networkPing = pcall(LocalPlayer.GetNetworkPing, LocalPlayer)
	return (math.clamp(((not success or type(networkPing) ~= "number") and 0.1 or networkPing) * 2 + 0.35, 0.4, 1.2))
end

local function myTeam() -- 1 equivalent call inferred from this helper
	local team = LocalPlayer.Team
	return if team and not LocalPlayer.Neutral then team.Name else nil
end

local function enemyOf(instance): nil | string
	local parent = instance.Parent

	if parent and parent:IsA("Accessory") then
		parent = parent.Parent
	end

	if not (parent and parent:IsA("Model")) then
		return nil
	end

	local v2 = myTeam() -- inferred equivalent call
	local botRigs = workspace:FindFirstChild("BotRigs")

	if botRigs and parent.Parent == botRigs then
		if parent:GetAttribute("Alive") == false or parent:GetAttribute("Protected") == true then
			return nil
		end

		if v2 == nil or parent:GetAttribute("Team") ~= v2 then
			return "bot"
		end

		return nil
	else
		local playerFromCharacter = Players:GetPlayerFromCharacter(parent)

		if
			not playerFromCharacter
			or playerFromCharacter == LocalPlayer
			or parent:GetAttribute("Protected") == true
		then
			return nil
		end

		local humanoid = parent:FindFirstChildOfClass("Humanoid")

		if not humanoid or humanoid.Health <= 0 then
			return nil
		end

		if v2 == nil or playerFromCharacter.Team == nil or playerFromCharacter.Team.Name ~= v2 then
			return "player"
		end

		return nil
	end
end

local function dropOldest(flag: boolean) -- 3 equivalent calls inferred from this helper
	local v2 = table.remove(v, 1)
	table.remove(nows, 1)

	if not flag and v2 then
		NetClock.unconfirmed(v2)
	end
end

function HitPredict.shot(raycastResult: RaycastResult?, duration: number?)
	local v2

	if raycastResult then
		v2 = enemyOf(raycastResult.Instance)
	end

	if not (raycastResult and v2) then
		return
	end

	table.insert(nows, os.clock())
	table.insert(v, v2)
	NetClock.predicted(v2)

	if #nows > 32 then
		dropOldest(false) -- inferred equivalent call
	end

	local position = raycastResult.Position

	if duration and duration > 0 then
		task.delay(duration, bindableEvent.Fire, bindableEvent, position)
	else
		bindableEvent:Fire(position)
	end
end

ReplicatedStorage:WaitForChild("Game"):WaitForChild("Remotes"):WaitForChild("HitConfirm").OnClientEvent:Connect(function(vector3: Vector3, p: number, flag: boolean, p2: string, p3: string?)
	local v2 = false

	if p2 == "bullet" then
		local v3 = os.clock() - window() -- inferred equivalent call

		while nows[1] and nows[1] < v3 do
			dropOldest(false) -- inferred equivalent call
		end

		if nows[1] then
			table.remove(v, 1)
			table.remove(nows, 1)
			v2 = true
		end
	end

	bindableEvent2:Fire(vector3, p, flag, p2, p3, v2)
end)

task.spawn(function()
	while true do
		task.wait(1)
		local v2 = os.clock() - window() -- inferred equivalent call

		while nows[1] and nows[1] < v2 do
			dropOldest(false) -- inferred equivalent call
		end
	end
end)

return HitPredict