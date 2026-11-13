local color = Color3.fromRGB(230, 126, 34)
local color2 = Color3.fromRGB(230, 230, 230)

return {
	Name = "help",
	Aliases = { "cmds", "commands" },
	Description = "Displays a list of all commands, or inspects one command.",
	Group = "Help",
	Args = {
		{
			Type = "command",
			Name = "Command",
			Description = "The command to view information on.",
			Optional = true
		}
	},
	ClientRun = function(object, p: string?): string
		local registry = object.Cmdr.Registry

		if p then
			local command = registry:GetCommand(p)
			object:Reply(`Command: {command.Name}`, color)

			if command.Aliases and #command.Aliases > 0 then
				object:Reply(`Aliases: {table.concat(command.Aliases, ", ")}`, color2)
			end

			if command.Description then
				object:Reply(`Description: {command.Description}`, color2)
			end

			if command.Group then
				object:Reply(`Group: {command.Group}`, color2)
			end

			if command.Args then
				for i, arg in ipairs(command.Args) do
					if type(arg) == "table" then
						local v = arg.Optional and "?" or ""

						object:Reply(`#{i} {arg.Name}{v}: {arg.Type} - {arg.Description}`)
					else
						object:Reply(`#{i} Unknown (inline argument)`)
					end
				end
			end
		else
			object:Reply("Argument Shorthands\n-------------------\n.   Me/Self\n*   All/Everyone\n**  Others\n?   Random\n?N  List of N random values\n")
			object:Reply("Tips\n----\n• Use the Tab key to autocomplete commands and suggestions\n• Easily select and copy command output\n")

			local commands = registry:GetCommands()
			table.sort(commands, function(a, b): boolean
				if a.Group and b.Group then
					return a.Group < b.Group
				end

				return a.Group ~= nil
			end)
			local v = nil

			for _, command in ipairs(commands) do
				if command._isHidden then
					continue
				end

				local group = command.Group or "No Group"

				if v ~= group then
					object:Reply(`\n{group}\n{("-"):rep(#group)}`)
					v = group
				end

				local v2

				if command.Description then
					v2 = `{command.Name} - {command.Description}`
				else
					v2 = command.Name
				end

				object:Reply(v2)
			end
		end

		return ""
	end
}