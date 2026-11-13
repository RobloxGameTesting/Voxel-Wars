return {
	Name = "version",
	Description = "Shows the current version of Cmdr.",
	Group = "DefaultDebug",
	Args = {},
	ClientRun = function(): string
		return "Cmdr Version v1.13.1"
	end
}