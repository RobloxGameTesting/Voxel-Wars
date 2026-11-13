local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local AudioGraph = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("AudioGraph"))
local Music = require(script.Parent:WaitForChild("Music"))

local MenuAudio = {}

local v = {
	id = "rbxassetid://9113147007",
	from = 0,
	to = 0.04,
	gain = 0.5,
	lowpass = 3000
}

local v2 = {
	{
		id = "rbxassetid://9113129096",
		from = 0.065,
		to = 0.125,
		gain = 0.6,
		lowpass = 7000
	},
	{
		id = "rbxassetid://9125419091",
		from = 0,
		to = 0.04,
		gain = 0.35,
		lowpass = 6000
	}
}

local cut2 = {
	id = "rbxassetid://9113129096",
	from = 0.065,
	to = 0.14,
	gain = 0.85,
	lowpass = 1400
}

local v3 = { 0.86, 0.78 }

MenuAudio.stamp = nil
MenuAudio.buy = nil
MenuAudio.deny = nil

MenuAudio.hover = nil
MenuAudio.press = nil

MenuAudio.quiet = nil

local function slot(cut, p: number, p2: string?)
	local players = {}

	for i = 1, p do
		local flat = AudioGraph.flat("Menu" .. (p2 or cut.id:match("%d+") or "Cut") .. "_" .. i)
		AudioGraph.route(flat, "ui")
		AudioGraph.lowpass(flat, cut.lowpass)
		flat.player.Looping = false
		flat.player.Asset = cut.id
		players[i] = flat.player
	end

	return { cut = cut, voices = players, next = 1 }
end

local object = setmetatable({}, { __mode = "k" })
local function fire(state, p: number?)
	local voice = state.voices[state.next]
	state.next = state.next % #state.voices + 1
	local cut = state.cut
	voice:Stop()
	voice.PlaybackRegion = NumberRange.new(cut.from, cut.to)
	voice.PlaybackSpeed = p or 0.95 + 0.05 * math.random()
	voice.Volume = cut.gain
	voice.TimePosition = cut.from
	voice:Play()
	local v4 = (object[voice] or 0) + 1
	object[voice] = v4
	task.delay((cut.to - cut.from) / voice.PlaybackSpeed + 0.05, function()
		if object[voice] == v4 then
			voice:Stop()
		end
	end)
end

function MenuAudio.mount(p)
	local v4 = slot(v, 3)
	local v5 = {}

	for k, v6 in v2 do
		v5[k] = slot(v6, 2)
	end

	local v6 = slot(cut2, 2, "Stamp")
	function MenuAudio.stamp()
		fire(v6, 0.85)
	end
	local v7 = slot(cut2, 2, "Buy")
	function MenuAudio.buy()
		fire(v7, 0.92)
	end
	local v8 = slot(v, 2, "Deny")
	function MenuAudio.deny()
		fire(v8, v3[1])
		task.delay(0.085, function()
			fire(v8, v3[2])
			v8.voices[(v8.next - 2) % #v8.voices + 1].Volume = v.gain * 0.7
		end)
	end

	local v9 = false
	local v10 = 0

	local heartbeatConnection = nil
	local function muffleStep(p2: number)
		local v11

		if v9 then
			v11 = math.min(1, v10 + p2 / 0.35)
		else
			v11 = math.max(0, v10 - p2 / 0.5)
		end

		if v11 ~= v10 then
			v10 = v11
			AudioGraph.setMenu(v11 * v11 * (3 - v11 * 2))
		end

		if not v9 and v11 == 0 and heartbeatConnection then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end
	end
	p.onMenu(function(flag: boolean)
		v9 = flag
		Music.menu(flag)

		if not heartbeatConnection then
			heartbeatConnection = RunService.Heartbeat:Connect(muffleStep)
		end
	end)

	local v11 = -1
	local v12 = -1
	local function confirmNow() -- 1 equivalent call inferred from this helper
		local now = os.clock()

		if now - v12 >= 0.06 then
			v12 = now

			for _, v13 in v5 do
				fire(v13)
			end
		end
	end
	function MenuAudio.hover()
		local now = os.clock()

		if now - v11 >= 0.03 then
			v11 = now
			fire(v4)
		end
	end
	MenuAudio.press = confirmNow
	function MenuAudio.quiet()
		v12 = os.clock()
	end

	local object2 = setmetatable({}, { __mode = "k" })
	local function watch(button)
		if not button:IsA("GuiButton") or object2[button] then
			return
		end

		object2[button] = true
		button.MouseEnter:Connect(function()
			local now = os.clock()

			if v9 and button.Visible and now - v11 >= 0.03 then
				v11 = now
				fire(v4)
			end
		end)
		button.Activated:Connect(function()
			local v13 = v9

			task.defer(function()
				if v13 or v9 then
					confirmNow() -- inferred equivalent call
				end
			end)
		end)
	end
	local playerGui = p.playerGui
	playerGui.DescendantAdded:Connect(watch)

	for _, descendant in playerGui:GetDescendants() do
		watch(descendant)
	end
end

return MenuAudio