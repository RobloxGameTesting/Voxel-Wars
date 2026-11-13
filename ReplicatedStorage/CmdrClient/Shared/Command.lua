local RunService = game:GetService("RunService")

local module = require("./Argument")

local isServer = RunService:IsServer()
local isClient = RunService:IsClient()

local Command = {}
Command.__index = Command

function Command.new(data)
	local v = {
		Dispatcher = data.Dispatcher,
		Cmdr = data.Dispatcher.Cmdr,
		Name = data.CommandObject.Name,
		RawText = data.Text,
		Object = data.CommandObject,
		Group = data.CommandObject.Group,
		State = {},
		Aliases = data.CommandObject.Aliases,
		Alias = data.Alias,
		Description = data.CommandObject.Description,
		Executor = data.Executor,
		ArgumentDefinitions = data.CommandObject.Args,
		RawArguments = data.Arguments,
		Arguments = {},
		Data = data.Data,
		Response = nil,
		Guards = data.Guards
	}

	setmetatable(v, Command)

	return v
end

function Command.Parse(data, flag: boolean?)
	local v = false

	for i, argumentDefinition in ipairs(data.ArgumentDefinitions) do
		if type(argumentDefinition) == "function" then
			argumentDefinition = argumentDefinition(data)

			if not argumentDefinition then
				break
			end
		end

		local v2

		if argumentDefinition.Default == nil then
			v2 = argumentDefinition.Optional ~= true
		else
			v2 = false
		end

		assert(not (v2 and v), `[Cmdr] Command {data.Name} has required arguments after optional arguments.`)
		v = not v2 or v

		if data.RawArguments[i] == nil and v2 and not flag then
			return false, `Required argument #{i} {argumentDefinition.Name} is missing.`
		end

		if data.RawArguments[i] or flag then
			data.Arguments[i] = module.new(data, argumentDefinition, data.RawArguments[i] or "")
		end
	end

	return true
end

function Command:Validate(flag: boolean?)
	self._Validated = true
	local v = ""
	local v2 = true

	for k, argument in pairs(self.Arguments) do
		local v3, v4 = argument:Validate(flag)

		if v3 then
			continue
		end

		v ..= `; #{k} {argument.Name}: {v4 or "error"}`
		v2 = false
	end

	return v2, v:sub(3)
end

function Command.GetLastArgument(p)
	for i = #p.Arguments, 1, -1 do
		local argument = p.Arguments[i]

		if argument and argument.RawValue then
			return argument
		end
	end
end

function Command:GatherArgumentValues()
	local result = {}

	for i = 1, #self.ArgumentDefinitions do
		local argument = self.Arguments[i]

		if argument then
			result[i] = argument:GetValue()
		elseif type(self.ArgumentDefinitions[i]) == "table" then
			result[i] = self.ArgumentDefinitions[i].Default
		end
	end

	return result, #self.ArgumentDefinitions
end

function Command:Run()
	assert(self._Validated, "[Cmdr] Must validate a command before running.")

	local v = self.Dispatcher:RunHooks("BeforeRun", self)

	if v then
		return v
	end

	local v2 = self.Dispatcher:RunGuards(self)

	if v2 then
		return v2
	end

	if not isServer and self.Object.Data and self.Data == nil then
		local argumentValues, v3 = self:GatherArgumentValues()
		self.Data = self.Object.Data(self, unpack(argumentValues, 1, v3))
	end

	if not isServer and self.Object.ClientRun then
		local argumentValues, v3 = self:GatherArgumentValues()
		self.Response = self.Object.ClientRun(self, unpack(argumentValues, 1, v3))
	end

	if self.Response == nil then
		if self.Object.Run then
			local argumentValues, v3 = self:GatherArgumentValues()
			self.Response = self.Object.Run(self, unpack(argumentValues, 1, v3))
		elseif isServer then
			if self.Object.ClientRun then
				warn(`[Cmdr] {self.Name} command fell back to the server because ClientRun returned nil, but there is no server implementation!`)
			else
				warn(`[Cmdr] {self.Name} command has no implementation!`)
			end

			self.Response = "No implementation."
		else
			self.Response = self.Dispatcher:Send(self.RawText, self.Data)
		end
	end

	return self.Dispatcher:RunHooks("AfterRun", self) or self.Response
end

function Command.GetArgument(p, p2: number)
	return p.Arguments[p2]
end

function Command:GetData()
	if self.Data then
		return self.Data
	end

	if self.Object.Data and not isServer then
		self.Data = self.Object.Data(self)
	end

	return self.Data
end

function Command:SendEvent(p, p2: string, ...)
	self.Dispatcher:SendEvent(p, p2, ...)
end

function Command:BroadcastEvent(p: string, ...)
	self.Dispatcher:BroadcastEvent(p, ...)
end

function Command:Reply(p: string, p2)
	return self:SendEvent(self.Executor, "AddLine", p, p2)
end

function Command:GetStore(p: string)
	return self.Cmdr.Registry:GetStore(p)
end

function Command.HasImplementation(p): boolean
	return (isClient and p.Object.ClientRun or p.Object.Run) ~= nil
end

return Command