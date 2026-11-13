local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BuiltInGuards = ReplicatedStorage.CmdrClient.Shared.BuiltInGuards
local NonEmptyString = require(BuiltInGuards.NonEmptyString)

return {
	Name = "announce",
	Aliases = { "m" },
	Description = "Makes a server-wide announcement.",
	Group = "DefaultAdmin",
	Args = {
		{ Type = "string", Name = "Text", Description = "The announcement text." }
	},
	Guards = { NonEmptyString(1) }
}