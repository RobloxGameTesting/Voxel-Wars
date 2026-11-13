local Style = require(script.Parent:WaitForChild("Style"))

local Armory = { ["toggle"] = nil, openLoadout = nil, close = nil }

function Armory.mount(p)
	local module = require(script.Parent:WaitForChild(Style.isTouch() and "ArmoryTouch" or "ArmoryDesk"))
	module.mount(p)
	assert(module.toggle, "[Armory] the layout did not set its toggle")
	Armory.toggle = module.toggle
	assert(module.openLoadout, "[Armory] the layout did not set openLoadout")
	Armory.openLoadout = module.openLoadout
	assert(module.close, "[Armory] the layout did not set close")
	Armory.close = module.close
end

return Armory