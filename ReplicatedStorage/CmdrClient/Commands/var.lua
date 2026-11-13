local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BuiltInGuards = ReplicatedStorage.CmdrClient.Shared.BuiltInGuards
local IsDataStoreAvailable = require(BuiltInGuards.IsDataStoreAvailable)

return {
	Name = "var",
	Description = "Gets a stored variable.",
	Group = "DefaultUtil",
	AutoExec = {
		"alias \"init-edit|Edit your initialization script.\" edit ${var init} \\\\\n && var= init ||",
		"alias \"init-run|Re-runs the initialization script manually.\" run-lines ${var init}",
		"init-run"
	},
	Args = {
		{
			Type = "storedKey",
			Name = "Key",
			Description = "The key to get, retrieved from your user data store. Keys prefixed with . are not saved. Keys prefixed with $ are game-wide. Keys prefixed with $. are game-wide and non-saved."
		}
	},
	Guards = { IsDataStoreAvailable(1) },
	ClientRun = function(object, p)
		local store = object:GetStore("vars_used")
		store[p] = true
	end
}