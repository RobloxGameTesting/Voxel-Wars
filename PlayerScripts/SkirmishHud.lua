local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Game = ReplicatedStorage:WaitForChild("Game")

if Game:GetAttribute("Sandbox") ~= true then
	Game:GetAttributeChangedSignal("Sandbox"):Wait()
end

if Game:GetAttribute("Sandbox") ~= true then
	return
end

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local GameUI = script.Parent:WaitForChild("GameUI")
local Style = require(GameUI:WaitForChild("Style"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local SpawnRaid = require(ReplicatedStorage2:WaitForChild("Game"):WaitForChild("SpawnRaid"))

local function observable(p)
	local v = p
	local callbacks = {}
	return {
		get = function()
			return v
		end,
		set = function(p2)
			if p2 ~= v then
				v = p2

				for _, callback in callbacks do
					task.spawn(callback, p2)
				end
			end
		end,
		on = function(callback)
			table.insert(callbacks, callback)
			task.spawn(callback, v)
		end
	}
end

local v = observable(false)
local v2 = observable(false)
local v3

if LocalPlayer.Team then
	v3 = LocalPlayer.Team.Name
end

local v4 = observable(v3)
LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function()
	local set = v4.set
	local v5

	if LocalPlayer.Team then
		v5 = LocalPlayer.Team.Name
	end

	set(v5)
end)

local ctx = {
	player = LocalPlayer,
	playerGui = PlayerGui,
	layers = {
		hud = Style.layer(PlayerGui, "GameHud", 7),
		menu = Style.layer(PlayerGui, "GameMenu", 9)
	},
	Style = Style,
	onTeam = v4.on,
	onDead = v.on,
	isDead = v.get,
	setDead = v.set,
	onMenu = v2.on,
	setMenu = v2.set
}

local huds = {}
ctx.layers.huds = huds
ctx.layers.hud.Enabled = false
local function hudFor(p: string, flag: boolean?)
	local hud

	if flag then
		hud = huds.Rare
	end

	if not hud then
		hud = Style.layer(PlayerGui, flag and "HudRare" or "Hud" .. p, 7)
		huds[flag and "Rare" or p] = hud
	end

	return (setmetatable({
		layers = { hud = hud, menu = ctx.layers.menu, huds = huds }
	}, { __index = ctx }))
end

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local v5 = false
v2.on(function(flag: boolean)
	if flag and not v5 then
		v5 = true
		RunService:BindToRenderStep("MenuPointer", Enum.RenderPriority.Last.Value + 10, function()
			UserInputService.MouseIconEnabled = true
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end)
	elseif not flag and v5 then
		v5 = false
		RunService:UnbindFromRenderStep("MenuPointer")
	end
end)

function ctx.onCharacter(callback)
	local function run(instance)
		local humanoid = instance:WaitForChild("Humanoid", 10)
		assert(humanoid and humanoid:IsA("Humanoid"), "SkirmishHud: character has no Humanoid")
		callback(instance, humanoid)
	end
	LocalPlayer.CharacterAdded:Connect(run)

	if LocalPlayer.Character then
		task.spawn(run, LocalPlayer.Character)
	end
end

function ctx.eachCharacter(callback)
	local function watch(player) -- 1 equivalent call inferred from this helper
		player.CharacterAdded:Connect(function(character)
			callback(character, player)
		end)

		if player.Character then
			task.spawn(callback, player.Character, player)
		end
	end
	Players.PlayerAdded:Connect(watch)

	for _, v6 in Players:GetPlayers() do
		watch(v6) -- inferred equivalent call
	end
end

ctx.onCharacter(function(_, p)
	v.set(false)
	p.Died:Connect(function()
		v.set(true)
	end)
end)

local v6 = {
	{ name = "LoadoutStrip", ctx = hudFor("LoadoutStrip") },
	{ name = "Shop", ctx = ctx },
	{ name = "LobbyMenus", ctx = ctx },
	{ name = "Store", ctx = ctx },
	{ name = "XpBar", ctx = ctx },
	{ name = "QuestTracker", ctx = hudFor("QuestTracker") },
	{ name = "Leaderboard", ctx = ctx },
	{ name = "PointHud", ctx = hudFor("PointHud"), first = true },
	{ name = "BreakthroughHud", ctx = hudFor("BreakthroughHud") },
	{ name = "ProgressPanel", ctx = hudFor("ProgressPanel") },
	{ name = "Killstreak", ctx = hudFor("Killstreak") },
	{ name = "ReviveHud", ctx = hudFor("ReviveHud") },
	{ name = "RoundIntro", ctx = hudFor("RoundIntro", true) },
	{ name = "Settings", ctx = hudFor("Settings", true) },
	{ name = "ReportPlayers", ctx = ctx },
	{ name = "RoundEnd", ctx = ctx },
	{ name = "DebugMenu", ctx = ctx },
	{ name = "Protection", ctx = ctx },
	{ name = "MenuAudio", ctx = ctx },
	{ name = "PointAudio", ctx = ctx },
	{ name = "CueAlert", ctx = hudFor("CueAlert", true) },
	{ name = "MusicCues", ctx = ctx },
	{ name = "PointRings", ctx = ctx },
	{ name = "MapLoading", ctx = ctx, first = true },
	{ name = "MatchVote", ctx = ctx, first = true },
	{ name = "StreakCall", ctx = hudFor("StreakCall", true) },
	{ name = "BadgeAward", ctx = hudFor("BadgeAward") },
	{ name = "RefundNotice", ctx = ctx },
	{ name = "OwnerGift", ctx = ctx },
	{ name = "OwnerGiftPanel", ctx = ctx },
	{ name = "MobileLobbyPrompt", ctx = ctx, first = true },
	{ name = "SiegeIntro", ctx = ctx },
	{ name = "FriendMarkers", ctx = ctx },
	{ name = "Armory", ctx = ctx },
	{ name = "Outfits", ctx = ctx },
	{ name = "Quests", ctx = ctx },
	{ name = "VehicleBay", ctx = ctx },
	{ name = "Garage", ctx = ctx }
}

local function mount(p) -- 2 equivalent calls inferred from this helper
	if p.name ~= "SiegeIntro" or SpawnRaid.SIEGE_INTRO_ON then
		local module = require(GameUI:WaitForChild(p.name))
		task.spawn(module.mount, p.ctx)
	end
end

for _, v7 in v6 do
	if v7.first then
		mount(v7) -- inferred equivalent call
	end
end

task.spawn(function()
	while LocalPlayer:GetAttribute("JoinCovered") == true do
		LocalPlayer:GetAttributeChangedSignal("JoinCovered"):Wait()
	end

	for _, v7 in v6 do
		if v7.first then
			continue
		end

		task.wait()
		mount(v7) -- inferred equivalent call
	end
end)

if LocalPlayer:GetAttribute("JoinHud") == nil then
	LocalPlayer:SetAttribute("JoinHud", os.clock())
end