local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local NetStats = {}
NetStats.onInbound = nil
local set = {}
local v = {}

local function hears(p, p2): boolean -- 4 equivalent calls inferred from this helper
	local v2 = v[p]
	return v2 ~= nil and v2[p2] == true
end

local v2 = {}
local v3 = {}
local lastTime = os.clock()
local lastTime2 = os.clock()
local total = 0
local v4 = os.clock()

local count = 0
local function sizeOf(buf, p: number)
	local typeName = typeof(buf)

	if typeName == "buffer" then
		return buffer.len(buf) + 3
	elseif typeName == "number" then
		return 9
	elseif typeName == "string" then
		return #buf + 3
	end

	if typeName == "boolean" or typeName == "nil" then
		return 1
	end

	if typeName == "Vector3" then
		return 13
	elseif typeName == "CFrame" then
		return 25
	elseif typeName == "Instance" then
		return 5
	end

	if typeName ~= "table" then
		return 9
	end

	if p > 4 then
		return 3
	end

	local total2 = 3

	for k, v5 in buf do
		count += 1

		if count > 4096 then
			return 1000000
		end

		total2 += (type(k) == "number" and 0 or sizeOf(k, p + 1)) + sizeOf(v5, p + 1)
	end

	return total2
end

function NetStats.size(...)
	local total2 = 9
	count = 0

	for i = 1, math.min(select("#", ...), 64) do
		total2 += sizeOf(select(i, ...), 0)

		if count > 4096 then
			return total2 + 1000000
		end
	end

	return total2
end

local function add(p: string, p2: number, p3: number) -- 4 equivalent calls inferred from this helper
	local v5 = v2[p]

	if not v5 then
		v5 = { bytes = 0, msgs = 0 }
		v2[p] = v5
	end

	v5.bytes += p2 * p3
	v5.msgs += p3
end
NetStats.count = add

function NetStats.stream(p)
	set[p] = true
end

function NetStats.hears(p, p2)
	return not set[p2] or hears(p, p2) -- inferred equivalent call
end

function NetStats.listen(p, onOnClientEvent)
	local onClientEventConnection = p.OnClientEvent:Connect(onOnClientEvent)
	ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("Remotes"):WaitForChild("StreamReady"):FireServer(p)
	return onClientEventConnection
end

function NetStats.fireAll(object, p: string, ...)
	local players = Players:GetPlayers()

	if set[object] then
		local count2 = 0

		for _, player in players do
			if hears(player, object) then -- inferred equivalent call
				count2 += 1
			end
		end

		if count2 == 0 then
			return
		end

		add(p, NetStats.size(...), count2) -- inferred equivalent call

		if count2 == #players then
			object:FireAllClients(...)
			return
		end

		for _, player in players do
			if hears(player, object) then -- inferred equivalent call
				object:FireClient(player, ...)
			end
		end
	else
		add(p, NetStats.size(...), #players) -- inferred equivalent call
		object:FireAllClients(...)
	end
end

function NetStats.fire(object, p: string, player, ...)
	if set[object] and not hears(player, object) then -- inferred equivalent call
		return
	end

	add(p, NetStats.size(...), 1) -- inferred equivalent call
	object:FireClient(player, ...)
end

function NetStats.invoke(p: string, callback)
	return function(...)
		local v5 = table.pack(callback(...))
		add(p, NetStats.size(table.unpack(v5, 1, v5.n)), 1) -- inferred equivalent call
		return table.unpack(v5, 1, v5.n)
	end
end

local v5 = {}

function NetStats.setView(p, vector3: Vector3?)
	v5[p] = vector3
end

function NetStats.viewOf(player)
	local v6 = v5[player]

	if v6 then
		return v6
	end

	local character = player.Character
	local primaryPart = character and character.PrimaryPart
	return if primaryPart then primaryPart.Position else nil
end

local function tickClients() -- 2 equivalent calls inferred from this helper
	local now = os.clock()
	total += #Players:GetPlayers() * (now - v4)
	v4 = now
end

function NetStats.take()
	tickClients() -- inferred equivalent call
	local v6 = v2
	local v7 = os.clock() - lastTime
	local v8 = total
	v2 = {}
	lastTime = os.clock()
	total = 0
	return v6, v7, v8
end

function NetStats.takeIn()
	local v6 = v3
	local v7 = os.clock() - lastTime2
	v3 = {}
	lastTime2 = os.clock()
	return v6, v7
end

if not RunService:IsServer() then
	return NetStats
end

Players.PlayerAdded:Connect(tickClients)
Players.PlayerRemoving:Connect(function(player)
	tickClients() -- inferred equivalent call
	v5[player] = nil
	v[player] = nil
end)
local StreamReady = ReplicatedStorage.Voxel.Remotes:FindFirstChild("StreamReady")
assert(StreamReady and StreamReady:IsA("RemoteEvent"), "[NetStats] Voxel.Remotes.StreamReady is missing")
StreamReady.OnServerEvent:Connect(function(p, instance)
	if typeof(instance) ~= "Instance" or not (instance:IsA("RemoteEvent") or instance:IsA("UnreliableRemoteEvent")) then
		return
	end

	local v6 = v[p]

	if not v6 then
		v6 = {}
		v[p] = v6
	end

	v6[instance] = true
end)
local function watch(descendant)
	if descendant:IsA("RemoteEvent") or descendant:IsA("UnreliableRemoteEvent") then
		local name = descendant.Name

		descendant.OnServerEvent:Connect(function(p, ...)
			local v6 = v3[p]

			if not v6 then
				v6 = {}
				v3[p] = v6
			end

			local size = NetStats.size(...)
			v6[name] = (v6[name] or 0) + size
			local onInbound = NetStats.onInbound

			if onInbound then
				onInbound(p, descendant, size)
			end
		end)
	end
end

for _, descendant in ReplicatedStorage:GetDescendants() do
	watch(descendant)
end

ReplicatedStorage.DescendantAdded:Connect(watch)

return NetStats