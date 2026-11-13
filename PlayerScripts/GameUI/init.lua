local Players = game:GetService("Players")

local Style = require(script:WaitForChild("Style"))
local Net = require(script:WaitForChild("Net"))

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local layers = {
	overlay = Style.layer(PlayerGui, "GameOverlay", 4),
	hud = Style.layer(PlayerGui, "GameHud", 7),
	screens = Style.layer(PlayerGui, "GameScreens", 8),
	menu = Style.layer(PlayerGui, "GameMenu", 9)
}

local function observable(p)
	local v = p
	local callbacks = {}
	return {
		get = function()
			return v
		end,
		set = function(p2)
			if p2 == v then
				return
			end

			v = p2

			for _, callback in callbacks do
				task.spawn(callback, p2)
			end
		end,
		on = function(callback)
			table.insert(callbacks, callback)
			task.spawn(callback, v)
		end
	}
end

local v = observable(Net.teamOf(LocalPlayer))
local function teamChanged()
	v.set(Net.teamOf(LocalPlayer))
end
LocalPlayer:GetPropertyChangedSignal("Team"):Connect(teamChanged)
LocalPlayer:GetPropertyChangedSignal("Neutral"):Connect(teamChanged)
local v2 = observable(false)
local v3 = observable(false)

local v4 = {
	player = LocalPlayer,
	playerGui = PlayerGui,
	layers = layers,
	Net = Net,
	Style = Style,
	onTeam = v.on,
	onDead = v2.on,
	isDead = v2.get,
	setDead = v2.set,
	onMenu = v3.on,
	setMenu = v3.set
}

function v4.onCharacter(callback)
	local function run(instance)
		local humanoid = instance:WaitForChild("Humanoid", 10)
		assert(humanoid and humanoid:IsA("Humanoid"), "GameUI: character has no Humanoid")
		callback(instance, humanoid)
	end
	LocalPlayer.CharacterAdded:Connect(run)

	if LocalPlayer.Character then
		task.spawn(run, LocalPlayer.Character)
	end
end

function v4.eachPlayer(onPlayerAdded)
	Players.PlayerAdded:Connect(onPlayerAdded)

	for _, v5 in Players:GetPlayers() do
		task.spawn(onPlayerAdded, v5)
	end
end

function v4.eachCharacter(callback)
	v4.eachPlayer(function(player)
		player.CharacterAdded:Connect(function(character)
			callback(character, player)
		end)

		if player.Character then
			callback(player.Character, player)
		end
	end)
end

v4.onCharacter(function(_, p)
	v2.set(false)
	p.Died:Connect(function()
		v2.set(true)
	end)
end)

for _, childName in {
	"Objective",
	"KillFeed",
	"ScoreFeed",
	"LoadoutStrip",
	"NameTags",
	"Protection",
	"DeathDust",
	"Redeploy",
	"Lobby",
	"Scoreboard",
	"Results",
	"Shop",
	"ProgressPanel"
} do
	task.spawn(function()
		local module = require(script:WaitForChild(childName))
		module.mount(v4)
	end)
end