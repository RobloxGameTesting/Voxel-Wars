local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local GameConfig = require(script.Parent.GameConfig)
local v

if RunService:IsServer() then
	v = Players.MaxPlayers
else
	v = script.Parent:GetAttribute("ServerSize") or 20
end

local TeamDeathmatch = {}
TeamDeathmatch.ID = "tdm"
TeamDeathmatch.NAME = "TEAM DEATHMATCH"
TeamDeathmatch.TARGET_SMALL = 150
TeamDeathmatch.TARGET_BIG = 200
local target

if GameConfig.BIG_SERVER <= v then
	target = TeamDeathmatch.TARGET_BIG
else
	target = TeamDeathmatch.TARGET_SMALL
end

TeamDeathmatch.TARGET = target
TeamDeathmatch.ROUND_TIME = 900
TeamDeathmatch.GOAL = "FIRST TO " .. TeamDeathmatch.TARGET .. " KILLS"

return TeamDeathmatch