local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

local v = false

local function runBindHelper(cmdr)
	Players.PlayerRemoving:Connect(function(player)
		local store = cmdr.Registry:GetStore("CMDR_Binds")
		store[player] = nil
	end)

	TextChatService.MessageReceived:Connect(function(p)
		local userId = p.TextSource and p.TextSource.UserId
		local playerByUserId = userId and Players:GetPlayerByUserId(userId)
		local v2 = playerByUserId and cmdr.Registry:GetStore("CMDR_Binds")[playerByUserId]

		if v2 then
			v2(p)
		end
	end)

	v = true
end

return {
	Name = "bind",
	Description = "Binds a command string to a key or mouse input.",
	Group = "DefaultUtil",
	Args = {
		{
			Type = "userInput @ player",
			Name = "Input",
			Description = "The key or input type you'd like to bind the command to."
		},
		{
			Type = "command",
			Name = "Command",
			Description = "The command you want to run on this input."
		},
		{
			Type = "string",
			Name = "Arguments",
			Description = "The arguments for the command.",
			Default = ""
		}
	},
	ClientRun = function(object, p, p2: string, p3: string): string
		if not v then
			runBindHelper(object.Cmdr)
		end

		local store = object:GetStore("CMDR_Binds")

		if type(store[p]) == "string" then
			ContextActionService:UnbindAction(store[p])
		end

		local util = object.Cmdr.Util
		local formatted = `{p2} {p3}`

		if object:GetArgument(1).Type.Name == "userInput" then
			local formatted2 = `evaera/Cmdr/bind_{p}`

			local function runCommand()
				object:Reply(object.Dispatcher:EvaluateAndRun(util.RunEmbeddedCommands(object.Dispatcher, formatted)))
			end

			ContextActionService:BindActionAtPriority(formatted2, function(_, p4)
				if p4 == Enum.UserInputState.Begin then
					task.spawn(runCommand)
				end

				return Enum.ContextActionResult.Pass
			end, false, Enum.ContextActionPriority.High.Value, p)

			store[p] = formatted2
		else
			store[p] = function(p4)
				local v2 = util.RunEmbeddedCommands(object.Dispatcher, util.SubstituteArgs(formatted, { p4.Text }))
				local evaluateAndRun = object.Dispatcher:EvaluateAndRun(v2)
				object:Reply(`{p.Name} $ {v2} : {evaluateAndRun}`, Color3.fromRGB(244, 92, 66))
			end
		end

		return "Bound command to input."
	end
}