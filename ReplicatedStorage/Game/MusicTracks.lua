local MusicTracks = {
	list = {
		{
			id = "tension",
			name = "Growing Tension",
			asset = "rbxassetid://9040212802",
			length = 31.5,
			start = 8.6,
			hit = 20,
			gain = 0.9
		},
		{
			id = "evasion",
			name = "Evasion",
			asset = "rbxassetid://1840028287",
			length = 60.4,
			start = 13.3,
			hit = 20,
			gain = 1
		},
		{
			id = "revarmy",
			name = "The Revolutionary Army",
			asset = "rbxassetid://9046458489",
			length = 58.3,
			start = 29.7,
			hit = 20,
			gain = 0.61
		},
		{
			id = "disaster",
			name = "Race To Disaster",
			asset = "rbxassetid://1841318139",
			length = 31.3,
			start = 2.8,
			hit = 20,
			gain = 0.63
		},
		{
			id = "epicforce",
			name = "Epic Force",
			asset = "rbxassetid://1841043719",
			length = 40.8,
			start = 13.7,
			hit = 20,
			gain = 0.51
		}
	},
	MENU = { asset = "rbxassetid://1836707344", gain = 0.63, loopAt = 24 },
	WIN = { asset = "rbxassetid://9042906299", gain = 0.69, start = 0, bedAt = 9 },
	LOSS = { asset = "rbxassetid://1836636509", gain = 0.95, start = 0, bedAt = 8 },
	ROUND_END_BED = 0.55,
	DEPLOY_BED = 0.75,
	CUES = {
		up = { asset = "rbxassetid://9043173188", start = 0, stop = 27, gain = 0.69 },
		down = { asset = "rbxassetid://1842054590", start = 0, stop = 26, gain = 0.89 },
		final = {
			asset = "rbxassetid://1841565968",
			start = 0,
			stop = 30,
			gain = 1,
			ending = 27.5
		},
		hit = { asset = "rbxassetid://1845303263", start = 0, stop = 12, gain = 1 }
	},
	OFF = "off",
	DEFAULT = "tension",
	DEFAULT_SFX = 1,
	DEFAULT_MUSIC = 0.5,
	byId = {}
}

for _, item in MusicTracks.list do
	assert(not MusicTracks.byId[item.id], "[MusicTracks] duplicate id " .. item.id)
	MusicTracks.byId[item.id] = item
end

assert(MusicTracks.byId[MusicTracks.DEFAULT], "[MusicTracks] DEFAULT is not in the list")

function MusicTracks.valid(value): boolean
	return type(value) == "string" and (value == MusicTracks.OFF or MusicTracks.byId[value] ~= nil)
end

function MusicTracks.amplitude(value: number)
	local v = math.clamp(value, 0, 1)
	return v * v
end

return MusicTracks