local RunService = game:GetService("RunService")

assert(
	RunService:IsClient(),
	"[Cmdr] The Cmdr client library cannot be required by the server. Please require the server libary instead."
)

local module = require("@self/Shared/Dispatcher")
local module2 = require("@self/Shared/Registry")
local module3 = require("@self/Shared/Util")

local module4 = require("@self/CmdrInterface")
local module5 = require("@self/DefaultEventHandlers")

local Types = script:WaitForChild("Types")
local Commands = script:WaitForChild("Commands")

local function createSignal()
	local bindableEvent = Instance.new("BindableEvent")

	return {
		Fire = function(self, ...)
			bindableEvent:Fire(...)
		end,
		Connect = function(self, onEvent)
			return bindableEvent.Event:Connect(onEvent)
		end
	}
end

local v = {
	Registry = nil,
	Dispatcher = nil,
	Util = module3,
	Gui = nil,
	Toggled = createSignal(),
	_interface = nil,
	_replicatedRoot = script,
	_remoteEvent = script:WaitForChild("CmdrEvent"),
	_remoteFunction = script:WaitForChild("CmdrFunction"),
	_enabled = true,
	_activationKeys = { Enum.KeyCode.F2 },
	_activationUnlocksMouse = false,
	_mashToEnable = false,
	_hideOnLostFocus = true,
	_placeName = "Cmdr",
	_events = {}
}

function v:SetEnabled(enabled: boolean)
	self._enabled = enabled

	if not enabled then
		self:Hide()
	end
end

function v:SetActivationKeys(activationKeys)
	self._activationKeys = activationKeys
	self._interface.Window:BindActivationKeys()
end

function v:SetActivationUnlocksMouse(activationUnlocksMouse: boolean)
	self._activationUnlocksMouse = activationUnlocksMouse
	self._interface.Window:UpdateMouseUnlock()
end

function v:Show()
	if not self._enabled then
		return
	end

	self._interface.Window:Show()
end

function v:Hide()
	self._interface.Window:Hide()
end

function v:Toggle()
	if self._enabled then
		self._interface.Window:SetVisible(not self._interface.Window:IsVisible())
	end
end

function v:SetMashToEnable(mashToEnable: boolean)
	self._mashToEnable = mashToEnable
end

function v:SetHideOnLostFocus(hideOnLostFocus: boolean)
	self._hideOnLostFocus = hideOnLostFocus
end

function v:SetPlaceName(placeName: string)
	self._placeName = placeName
	self._interface.Window:UpdateLabelText()
end

function v:HandleEvent(p: string, callback)
	self._events[p] = callback
end

local function initialize()
	v.Registry = module2(v)
	v.Dispatcher = module(v)
	v._interface = module4(v)

	v._remoteEvent.OnClientEvent:Connect(function(p: string, ...)
		if not v._events[p] then
			return
		end

		v._events[p](...)
	end)

	v.Registry:RegisterTypesIn(Types)
	v.Registry:RegisterCommandsIn(Commands)

	Types.ChildAdded:Connect(function(moduleScript)
		if not moduleScript:IsA("ModuleScript") then
			warn(`[Cmdr] Ignored non-module child in Types: {moduleScript.Name}`)
			return
		end

		local module6 = require(moduleScript)
		module6(v.Registry)
	end)

	Commands.ChildAdded:Connect(function(moduleScript)
		if moduleScript:IsA("ModuleScript") then
			v.Registry:RegisterCommand(moduleScript)
		else
			warn(`[Cmdr] Ignored non-module child in Commands: {moduleScript.Name}`)
		end
	end)
end

initialize()
module5(v)

return (setmetatable(v, {
	__index = function(p, p2)
		local v2 = rawget(p, "Dispatcher")
		local v3 = v2 and v2[p2]
		assert(v3, `[Cmdr] Dispatcher has no method or property "{p2}".`)

		if type(v3) ~= "function" then
			return nil
		end

		module3:_emitDeprecationWarning("ProxyCalls")

		return function(_, ...)
			return v3(v2, ...)
		end
	end,
	__newindex = function(_, p)
		error(`[Cmdr] Cannot assign key "{p}"; the CmdrClient object is read-only.`)
	end
}))