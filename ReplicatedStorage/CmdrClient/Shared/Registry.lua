local RunService = game:GetService("RunService")

local module = require("./Util")

local isServer = RunService:IsServer()
local isClient = RunService:IsClient()

local dictionary = module.MakeDictionary({
	"Transform",
	"Validate",
	"Autocomplete",
	"Parse",
	"DisplayName",
	"Listable",
	"ValidateOnce",
	"Prefixes",
	"Default",
	"ArgumentOperatorAliases"
})

local dictionary2 = module.MakeDictionary({
	"Name",
	"Aliases",
	"AutoExec",
	"Description",
	"Args",
	"Run",
	"ClientRun",
	"Data",
	"Group",
	"Guards",
	"_scriptInstance"
})

local dictionary3 = module.MakeDictionary({ "Name", "Type", "Description", "Optional", "Default" })

local v = { "_autoExecFlushConnection" }

local newindex = {
	Cmdr = nil,
	_types = {},
	_typeAliases = {},
	_commands = {},
	_commandsArray = {},
	_hooks = { BeforeRun = {}, AfterRun = {}, BeforeCommandRegister = {} },
	_autoExecBuffer = {},
	_autoExecFlushConnection = nil,
	_stores = setmetatable({}, {
		__index = function(p, p2)
			p[p2] = {}
			return p[p2]
		end
	})
}

function newindex:RegisterType(name: string, p)
	assert(typeof(name) == "string", `[Cmdr] Invalid type name provided: {tostring(name)}`)
	assert(
		name:find("^[%d%l]%w*$") ~= nil,
		`[Cmdr] Invalid type name provided: "{name}", type names must be alphanumeric and start with a lowercase letter or digit.`
	)

	for k in pairs(p) do
		assert(dictionary[k] ~= nil, `[Cmdr] Unknown key/method in type "{name}": {k}`)
	end

	assert(self._types[name] == nil, `[Cmdr] Type "{name}" has already been registered.`)

	p.Name = name
	p.DisplayName = p.DisplayName or name

	self._types[name] = p

	if p.Prefixes then
		self:RegisterTypePrefix(name, p.Prefixes)
	end
end

function newindex:RegisterTypePrefix(p: string, p2: string)
	if not self._typeAliases[p] then
		self._typeAliases[p] = p
	end

	self._typeAliases[p] = `{self._typeAliases[p]} {p2}`
end

function newindex:RegisterTypeAlias(p: string, p2: string)
	assert(self._typeAliases[p] == nil, `[Cmdr] Type alias "{p}" already exists!`)

	self._typeAliases[p] = p2
end

function newindex:RegisterTypesIn(instance)
	for _, moduleScript in pairs(instance:GetChildren()) do
		if moduleScript:IsA("ModuleScript") then
			moduleScript.Parent = self.Cmdr._replicatedRoot.Types

			local module2 = require(moduleScript)
			module2(self)
		else
			self:RegisterTypesIn(moduleScript)
		end
	end
end

newindex.RegisterHooksIn = newindex.RegisterTypesIn

function newindex:_validateCommandArguments(p)
	for k, arg in pairs(p.Args) do
		if type(arg) ~= "table" then
			continue
		end

		for k2 in pairs(arg) do
			assert(dictionary3[k2], `[Cmdr] Unknown property in command "{p.Name or "unknown"}" argument #{k}: {k2}`)
		end
	end
end

function newindex:_validateCommand(p)
	for k in pairs(p) do
		assert(dictionary2[k], `[Cmdr] Unknown key/method in command "{p.Name or "unknown command"}": {k}`)
	end

	if p.Args then
		self:_validateCommandArguments(p)
	end
end

function newindex:RegisterCommandObject(state, flag: boolean?): boolean
	self:_validateCommand(state)

	state._isDefault = flag == true
	state._isHidden = false

	if isClient then
		local v2 = self.Cmdr.Dispatcher:_runBeforeCommandRegisterHookForCommand(state)
		state._isHidden = v2 ~= nil and v2 ~= true

		if state.AutoExec then
			table.insert(self._autoExecBuffer, state.AutoExec)
			self:_flushAutoExecBufferDeferred()
		end
	end

	local name = state.Name:lower()
	local command = self._commands[name]

	if command then
		local isDefault = command._isDefault

		if flag and not isDefault then
			warn(`[Cmdr] Ignored default command "{state.Name}" because a custom developer command is already registered with this name.`)

			return false
		end

		if flag or not isDefault then
			if flag or isDefault then
				warn(`[Cmdr] Default command "{state.Name}" was overwritten by a newer default command.`)
			else
				warn(`[Cmdr] Custom command "{state.Name}" was overwritten by a newer custom command.`)
			end
		else
			warn(`[Cmdr] Custom command "{state.Name}" has replaced the default built-in command.`)
		end

		if isServer and command._scriptInstance then
			command._scriptInstance:Destroy()
		end

		local index = table.find(self._commandsArray, command)

		if index then
			self._commandsArray[index] = state
		else
			table.insert(self._commandsArray, state)
		end

		if command.Aliases then
			for _, alias in pairs(command.Aliases) do
				self._commands[alias:lower()] = nil
			end
		end
	else
		table.insert(self._commandsArray, state)
	end

	self._commands[name] = state

	if state.Aliases then
		for _, alias in pairs(state.Aliases) do
			self._commands[alias:lower()] = state
		end
	end

	return true
end

function newindex:RegisterCommand(scriptInstance, moduleScript, callback, flag: boolean?)
	local module2 = require(scriptInstance)
	assert(
		typeof(module2) == "table",
		`[Cmdr] Invalid return value from command script "{scriptInstance.Name}" (CommandDefinition expected, got {typeof(module2)})`
	)

	if moduleScript then
		assert(isServer, "[Cmdr] The commandServerScript parameter is not valid for client usage.")
		module2.Run = require(moduleScript)
	end

	if callback and not callback(module2) then
		return
	end

	module2._scriptInstance = scriptInstance

	if self:RegisterCommandObject(module2, flag) then
		scriptInstance.Parent = self.Cmdr._replicatedRoot.Commands
	end
end

function newindex:RegisterCommandsIn(instance, callback, flag: boolean?)
	local moduleScriptSet = {}
	local childSet = {}

	for _, moduleScript in pairs(instance:GetChildren()) do
		if moduleScript:IsA("ModuleScript") then
			if moduleScript.Name:find("Server") then
				moduleScriptSet[moduleScript] = true
			else
				local child = instance:FindFirstChild(`{moduleScript.Name}Server`)

				if child then
					childSet[child] = true
				end

				self:RegisterCommand(moduleScript, child, callback, flag)
			end
		else
			self:RegisterCommandsIn(moduleScript, callback, flag)
		end
	end

	for k in pairs(moduleScriptSet) do
		if not childSet[k] then
			warn(`[Cmdr] Command script {k.Name} was skipped because it has 'Server' in its name, and has no equivalent shared script.`)
		end
	end
end

function newindex:RegisterDefaultCommands(p)
	assert(isServer, "[Cmdr] RegisterDefaultCommands cannot be called from the client.")
	local v2

	if type(p) == "table" then
		v2 = module.MakeDictionary(p)
	else
		v2 = nil
	end

	local filter = v2 ~= nil and function(p2)
		return v2[p2.Group] or false
	end or p

	self:RegisterCommandsIn(self.Cmdr._defaultCommandsFolder, filter, true)
end

function newindex:GetCommand(value: string)
	return self._commands[value:lower()]
end

function newindex:GetCommands()
	return self._commandsArray
end

function newindex:GetCommandNames(flag: boolean?)
	local commandNames = {}

	for _, command in pairs(self._commandsArray) do
		if command._isHidden then
			continue
		end

		if flag and typeof(command.Aliases) == "table" then
			for _, alias in pairs(command.Aliases) do
				table.insert(commandNames, alias)
			end
		end

		table.insert(commandNames, command.Name)
	end

	return commandNames
end

newindex.GetCommandsAsStrings = newindex.GetCommandNames
module:_registerDeprecationWarning(
	"GetCommandsAsStrings",
	"This method was renamed to GetCommandNames in v1.8.0. The old name exists for backwards compatibility and should not be used for new work."
)

function newindex:GetTypeNames()
	local typeNames = {}

	for k in pairs(self._types) do
		table.insert(typeNames, k)
	end

	return typeNames
end

function newindex:GetType(p: string)
	return self._types[p]
end

function newindex:GetTypeName(p: string)
	return self._typeAliases[p] or p
end

function newindex:RegisterHook(p: string, callback, value: number?)
	assert(self._hooks[p], `[Cmdr] Invalid hook name: {p}`)

	table.insert(self._hooks[p], {
		callback = callback,
		priority = value or 0
	})
	table.sort(self._hooks[p], function(a, b): boolean
		return a.priority < b.priority
	end)
end

newindex.AddHook = newindex.RegisterHook
module:_registerDeprecationWarning(
	"AddHook",
	"This method was renamed to RegisterHook in v1.1.2. The old name exists for backwards compatibility and should not be used for new work."
)

function newindex:GetStore(p: string)
	return self._stores[p]
end

function newindex:_flushAutoExecBuffer()
	for _, list in ipairs(self._autoExecBuffer) do
		for _, item in ipairs(list) do
			self.Cmdr.Dispatcher:EvaluateAndRun(item)
		end
	end

	self._autoExecBuffer = {}
end

function newindex:_flushAutoExecBufferDeferred()
	if self._autoExecFlushConnection then
		return
	end

	self._autoExecFlushConnection = RunService.Heartbeat:Connect(function()
		self._autoExecFlushConnection:Disconnect()
		self._autoExecFlushConnection = nil
		self:_flushAutoExecBuffer()
	end)
end

newindex.__index = newindex
newindex.__newindex = newindex

return function(cmdr)
	return (setmetatable({ Cmdr = cmdr }, {
		__index = function(_, p)
			if module._deprecationWarnings[p] then
				module:_emitDeprecationWarning(p)
			end

			local v2 = newindex[p]
			assert(v2 or table.find(v, p), `[Cmdr] Registry has no method or property "{p}".`)
			return v2
		end,
		__newindex = function(_, p, p2)
			assert(table.find(v, p) or newindex[p], `[Cmdr] Cannot assign key "{p}"; the Registry is read-only.`)

			newindex[p] = p2
		end
	}))
end