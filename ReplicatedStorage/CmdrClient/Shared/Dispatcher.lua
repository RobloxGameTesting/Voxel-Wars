local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local module = require("./Command")
local module2 = require("./Util")

local isServer = RunService:IsServer()
local isClient = RunService:IsClient()
local isStudio = RunService:IsStudio()

local color = Color3.fromRGB(255, 228, 26)

local LocalPlayer = Players.LocalPlayer

local v = false

local newindex = { Cmdr = nil, Registry = nil }

function newindex:Evaluate(text: string, executor, flag: boolean?, p)
	assert(
		isServer or isClient and executor == Players.LocalPlayer,
		"[Cmdr] Can't evaluate a command that isn't sent by the local player."
	)

	if typeof(text) ~= "string" or module2.TrimString(text) == "" then
		return false, "Command cannot be empty."
	end

	local splitString = module2.SplitString(text)
	local alias = table.remove(splitString, 1)
	local command = self.Registry:GetCommand(alias)

	if not command then
		return
			false,
			`{tostring(alias)} is not a valid command name. Use the help command to see all available commands.`
	end

	local mashExcessArguments = module2.MashExcessArguments(splitString, #command.Args)

	local v2 = module.new({
		Dispatcher = self,
		Text = text,
		CommandObject = command,
		Alias = alias,
		Executor = executor,
		Arguments = mashExcessArguments,
		Data = p
	})

	local parsed, v3 = v2:Parse(flag)

	if parsed then
		return v2
	end

	return false, v3
end

function newindex:EvaluateAndRun(p: string, p2, options)
	local v2 = p2 or Players.LocalPlayer
	local v3 = options or {}

	if isClient and v3.IsHuman then
		self:_pushHistory(p)
	end

	local evaluate, v4 = self:Evaluate(p, v2, nil, v3.Data)

	if not evaluate then
		return v4
	end

	local success, result = xpcall(function()
		local v5, v6 = evaluate:Validate(true)

		if v5 then
			return evaluate:Run() or "Command executed."
		end

		return v6
	end, function(p3)
		return debug.traceback((tostring(p3)))
	end)

	if success then
		return result
	end

	warn(`[Cmdr] Error occurred while evaluating command string {("%q"):format(p)}\n{result}`)
	return "An error occurred while running this command. Check the console for more information."
end

function newindex.Send(p, p2: string, p3)
	assert(isClient, "[Cmdr] [Dispatcher::Send] can only be called from the client.")
	return p.Cmdr._remoteFunction:InvokeServer(p2, { Data = p3 })
end

function newindex:SendEvent(player, value: string, ...)
	local v2 = typeof(player) == "Instance" and player:IsA("Player")
	assert(v2, "[Cmdr] Argument #1 must be a Player")
	assert(typeof(value) == "string", "[Cmdr] Argument #2 must be a string")

	if isServer then
		self.Cmdr._remoteEvent:FireClient(player, value, ...)
	elseif self.Cmdr._events[value] then
		assert(
			player == Players.LocalPlayer,
			"[Cmdr] Event messages can only be sent to the local player on the client."
		)

		self.Cmdr._events[value](...)
	end
end

function newindex.BroadcastEvent(p, value: string, ...)
	assert(isServer, "[Cmdr] Can't broadcast event messages from the client.")
	assert(typeof(value) == "string", "[Cmdr] Argument #1 must be a string")
	p.Cmdr._remoteEvent:FireAllClients(value, ...)
end

function newindex:Run(...)
	assert(isClient, "[Cmdr] [Dispatcher::Run] can only be called from the client.")

	local v2 = { ... }
	local v3 = tostring(v2[1])

	for i = 2, #v2 do
		v3 ..= ` {v2[i]}`
	end

	local evaluate, v4 = self:Evaluate(v3, Players.LocalPlayer)
	assert(evaluate, v4)

	local v5, v6 = evaluate:Validate(true)
	assert(v5, v6)

	return evaluate:Run()
end

function newindex.RunGuards(_, p, ...)
	local guards = p.Object.Guards

	if not guards then
		return nil
	end

	local typeName = typeof(guards)
	assert(typeName == "table", `expected a table for Command.Guards, got {typeName}`)

	for _, guard in ipairs(guards) do
		local typeName2 = typeof(guard)
		assert(typeName2 == "function", `expected a function for a value in Command.Guards, got {typeName2}`)

		local v2 = guard(p, ...)

		if v2 ~= nil then
			return (tostring(v2))
		end
	end

	return nil
end

function newindex:RunHooks(p: string, object, flag: boolean?)
	local hook = self.Registry._hooks[p]
	assert(hook, `[Cmdr] Invalid hook name: {p}`)
	assert(
		not isServer or p ~= "BeforeCommandRegister",
		"[Cmdr] The BeforeCommandRegister hook can only be run by the client."
	)

	if
		p == "BeforeRun"
		and #hook == 0
		and object.Group ~= "DefaultUtil"
		and object.Group ~= "UserAlias"
		and object:HasImplementation()
	then
		if not isStudio then
			return "Command blocked for security as no BeforeRun hook is configured."
		end

		if not v then
			object:Reply(
				`{isServer and "<Server>" or "<Client>"} Commands will not run in-game if no BeforeRun hook is configured. Learn more: https://eryn.io/Cmdr/docs/hooks`,
				color
			)

			v = true
		end
	end

	for _, v2 in ipairs(hook) do
		local callback = v2.callback(object)

		if callback ~= nil then
			if flag == true then
				return callback
			end

			return (tostring(callback))
		end
	end

	return nil
end

function newindex:_runBeforeCommandRegisterHookForCommand(commandObject)
	assert(isClient, "[Cmdr] [Dispatcher::_runBeforeCommandRegisterHookForCommand] can only be called from the client.")

	local name = commandObject.Name:lower()
	local v2 = self:RunHooks("BeforeCommandRegister", module.new({
		Dispatcher = self,
		Text = nil,
		CommandObject = commandObject,
		Alias = name,
		Executor = LocalPlayer,
		Arguments = {},
		Data = nil
	}), true)
	assert(not v2, "[Cmdr] BeforeCommandRegister hook must return nil or false.")
	return v2
end

function newindex:RunBeforeCommandRegisterHooks(player)
	local v2 = isClient

	if not v2 then
		v2 = isServer

		if v2 then
			if typeof(player) == "Instance" then
				v2 = player:IsA("Player")
			else
				v2 = false
			end
		end
	end

	assert(v2, "[Cmdr] Argument #1 must be a Player when called on the Server.")

	assert(isClient and player == nil, "[Cmdr] Argument #1 must be omitted when calling on the Client.")

	if isServer and player then
		self:SendEvent(player, "RunBeforeCommandRegisterHooks")
		return
	end

	for _, v3 in pairs(self.Registry:GetCommands()) do
		local v4 = self:_runBeforeCommandRegisterHookForCommand(v3)
		v3._isHidden = v4 ~= nil and v4 ~= true
	end
end

function newindex:GetHistory()
	assert(isClient, "[Cmdr] [Dispatcher::GetHistory] may only be used from the client.")
	return TeleportService:GetTeleportSetting("CMDR_COMMAND_HISTORY") or {}
end

function newindex:_pushHistory(p: string)
	assert(isClient, "[Cmdr] [Dispatcher::PushHistory] may only be used from the client.")

	local history = self:GetHistory()

	if module2.TrimString(p) == "" or p == history[#history] then
		return
	end

	history[#history + 1] = p
	TeleportService:SetTeleportSetting("CMDR_COMMAND_HISTORY", history)
end

newindex.__index = newindex
newindex.__newindex = newindex

return function(cmdr)
	return (setmetatable({ Cmdr = cmdr, Registry = cmdr.Registry }, {
		__index = function(_, p)
			if module2._deprecationWarnings[p] then
				module2:_emitDeprecationWarning(p)
			end

			local v2 = newindex[p]
			assert(v2, `[Cmdr] Dispatcher has no method or property "{p}".`)
			return v2
		end,
		__newindex = function(_, p)
			error(`[Cmdr] Cannot assign key "{p}"; the Dispatcher is read-only.`)
		end
	}))
end