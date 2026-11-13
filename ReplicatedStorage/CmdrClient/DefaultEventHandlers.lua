local TextChatService = game:GetService("TextChatService")

local rbxSystem = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXSystem")

return function(object)
	object:HandleEvent("Message", function(p: string)
		rbxSystem:DisplaySystemMessage(`<font color="rgb(249, 217, 56)">[Announcement] {p}</font>`)
	end)

	object:HandleEvent("AddLine", function(...)
		object._interface.Window:AddLine(...)
	end)

	object:HandleEvent("RunBeforeCommandRegisterHooks", function()
		object.Dispatcher:RunBeforeCommandRegisterHooks()
	end)
end