local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local v = {
	grab = {
		id = "rbxassetid://9114725093",
		from = 0.45,
		to = 0.54,
		gain = 1,
		lowpass = 5000
	},
	click = {
		id = "rbxassetid://9120409020",
		from = 0.09,
		to = 0.15,
		gain = 0.5,
		lowpass = 5000
	},
	seat = {
		id = "rbxassetid://9113104176",
		from = 0.34,
		to = 0.42,
		gain = 0.22,
		lowpass = 5000
	},
	rack = {
		id = "rbxassetid://9116347612",
		from = 0.2,
		to = 0.36,
		gain = 0.6,
		lowpass = 6000
	},
	clunk = {
		id = "rbxassetid://9116344235",
		from = 0.27,
		to = 0.46,
		gain = 1,
		lowpass = 6000
	},
	cloth = {
		id = "rbxassetid://9119079222",
		from = 0.15,
		to = 0.42,
		gain = 0.5,
		lowpass = 6000
	},
	latch = {
		id = "rbxassetid://9125921121",
		from = 1.03,
		to = 1.25,
		gain = 1,
		lowpass = 6000
	},
	ratchet = {
		id = "rbxassetid://9118046636",
		from = 0.22,
		to = 0.42,
		gain = 1,
		lowpass = 6000
	}
}

local v2 = {}

local function slot(p: string)
	local v3 = v2[p]

	if v3 then
		return v3
	end

	local AudioGraph = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("AudioGraph"))
	local cut = assert(v[p], "[GearSound] unknown cut " .. p)
	local players = {}

	for i = 1, 2 do
		local flat = AudioGraph.flat("Gear" .. p .. "_" .. i)
		AudioGraph.route(flat, "ui")
		AudioGraph.lowpass(flat, cut.lowpass)
		flat.player.Looping = false
		flat.player.Asset = cut.id
		players[i] = flat.player
	end

	local v4 = { cut = cut, voices = players, next = 1 }
	v2[p] = v4
	return v4
end

local object = setmetatable({}, { __mode = "k" })
local function fire(p: string, p2: number, p3: number)
	local v3 = slot(p)
	local voice = v3.voices[v3.next]
	v3.next = v3.next % #v3.voices + 1
	local cut = v3.cut
	voice:Stop()
	local playbackSpeed = p3 * (0.97 + 0.03 * math.random())
	voice.PlaybackRegion = NumberRange.new(cut.from, cut.to)
	voice.PlaybackSpeed = playbackSpeed
	voice.Volume = cut.gain * p2
	voice.TimePosition = cut.from
	voice:Play()
	local v4 = math.max((cut.to - cut.from) / playbackSpeed - 0.03, 0)
	TweenService:Create(voice, TweenInfo.new(0.03, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, v4), {
		Volume = 0
	}):Play()
	local v5 = (object[voice] or 0) + 1
	object[voice] = v5
	task.delay(v4 + 0.03 + 0.05, function()
		if object[voice] == v5 then
			voice:Stop()
		end
	end)
end

local function chain(items)
	for _, item in items do
		if item[1] > 0 then
			task.delay(item[1], fire, item[2], item[3], item[4])
		else
			fire(item[2], item[3], item[4])
		end
	end
end

local function kindOf(data): string -- 2 equivalent calls inferred from this helper
	if not (data.flash or data.flashScale or data.weight) then
		return "gear"
	end

	local weight = data.weight or 1

	if weight >= 1.2 then
		return "heavy"
	end

	return if weight <= 0.75 then "light" else "rifle"
end

local v3 = {
	light = {
		{ 0, "grab", 0.8, 1 },
		{ 0.1, "seat", 1, 1 }
	},
	rifle = {
		{ 0, "cloth", 0.5, 1 },
		{ 0.03, "grab", 1, 0.92 },
		{ 0.14, "rack", 0.8, 1 }
	},
	heavy = {
		{ 0, "cloth", 0.7, 0.9 },
		{ 0.05, "clunk", 1, 0.88 },
		{ 0.2, "click", 0.8, 0.85 }
	},
	gear = {
		{ 0, "cloth", 0.6, 1 },
		{ 0.04, "grab", 0.7, 0.85 }
	}
}

local v4 = {
	light = {
		{ 0, "cloth", 0.4, 1 },
		{ 0.03, "seat", 0.6, 0.9 }
	},
	rifle = {
		{ 0, "cloth", 0.6, 0.95 },
		{ 0.04, "click", 0.5, 0.85 }
	},
	heavy = {
		{ 0, "cloth", 0.7, 0.85 },
		{ 0.04, "clunk", 0.6, 0.8 }
	},
	gear = {
		{ 0, "cloth", 0.5, 0.95 }
	}
}
local GearSound = {}

function GearSound.draw(data)
	task.delay(0.05, chain, v3[kindOf(data)]) -- inferred equivalent call
end

function GearSound.stow(data)
	chain(v4[kindOf(data)]) -- inferred equivalent call
end

local v5 = {
	Optic = {
		{ 0, "latch", 1, 1 }
	},
	Muzzle = {
		{ 0, "ratchet", 1, 0.9 },
		{ 0.2, "click", 0.7, 0.9 }
	},
	Magazine = {
		{ 0, "seat", 1.2, 0.95 },
		{ 0.05, "click", 0.5, 1 }
	},
	Underbarrel = {
		{ 0, "ratchet", 0.8, 0.85 },
		{ 0.14, "latch", 0.8, 0.9 }
	},
	Barrel = {
		{ 0, "seat", 1, 0.8 },
		{ 0.12, "ratchet", 0.8, 0.8 },
		{ 0.3, "latch", 0.8, 0.85 }
	}
}

function GearSound.fit(p: string)
	chain(assert(v5[p], "[GearSound] no fit sound for " .. p))
end

local v6 = {
	Optic = {
		{ 0, "latch", 1.4, 1 }
	},
	Muzzle = {
		{ 0, "ratchet", 2.2, 0.9 },
		{ 0.2, "click", 1.4, 0.9 }
	},
	Magazine = {
		{ 0, "seat", 3, 0.95 },
		{ 0.05, "click", 1.2, 1 }
	},
	Underbarrel = {
		{ 0, "ratchet", 1.8, 0.85 },
		{ 0.14, "latch", 1.3, 0.9 }
	},
	Barrel = {
		{ 0, "seat", 2.4, 0.8 },
		{ 0.12, "ratchet", 1.8, 0.8 },
		{ 0.3, "latch", 1.3, 0.85 }
	},
	Skin = {
		{ 0, "cloth", 1.6, 0.9 },
		{ 0.16, "click", 1.3, 0.85 }
	}
}

function GearSound.unlock(p: string)
	chain(assert(v6[p], "[GearSound] no unlock sound for " .. p))
end

function GearSound.equip()
	chain({
		{ 0, "grab", 0.9, 0.95 },
		{ 0.1, "rack", 0.7, 1 }
	})
end

function GearSound.wear()
	chain({
		{ 0, "cloth", 1, 1 }
	})
end

return GearSound