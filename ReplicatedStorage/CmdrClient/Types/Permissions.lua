local RunService = game:GetService("RunService")

local v = { "Voxel", "Help", "DefaultUtil", "UserAlias" }

local v2 = { kick = true, ban = true, unban = true, gotoPlace = true }

local v3 = { [7872316101] = "ToastyHam0", [11547363793] = "ToastyHam_0" }

local v4 = {
	[8036046109] = { spawnvehicle = true, clearvehicles = true }
}

local function isOwner(executor): boolean
	local userId = executor.UserId
	return game.CreatorType == Enum.CreatorType.User and userId == game.CreatorId
		or (game.CreatorType == Enum.CreatorType.Group and executor:GetRankInGroup(game.CreatorId) == 255 or v3[userId] ~= nil)
end

return function(registry)
	registry:RegisterHook("BeforeRun", function(data): nil | string
		if table.find(v, data.Group) or RunService:IsStudio() then
			return nil
		end

		local executor = data.Executor

		if isOwner(executor) then
			return nil
		end

		local v5 = v4[executor.UserId]

		if v5 and v5[data.Name] then
			return nil
		end

		if executor:GetAttribute("CmdrGranted") ~= true then
			return "You do not have permission to run this command."
		end

		if data.Group == "Owner" or v2[data.Name] then
			return "Only the owner can run this command."
		end

		return nil
	end)
end