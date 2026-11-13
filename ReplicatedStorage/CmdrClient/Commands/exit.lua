return {
	Name = "exit",
	Aliases = { "escape" },
	Description = "Exits the Cmdr window.",
	Group = "DefaultUtil",
	Args = {},
	ClientRun = function(p): string
		p.Cmdr:Hide()
		return ""
	end
}