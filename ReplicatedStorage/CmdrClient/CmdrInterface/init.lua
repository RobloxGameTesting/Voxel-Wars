local module = require("@self/CreateGui")
local module2 = require("@self/Window")
local module3 = require("@self/AutoComplete")

return function(p)
	p.Gui = module()

	local autoComplete = module3(p)
	local window = module2(p, autoComplete)

	window:UpdateLabelText()
	window:UpdateWindowHeight()

	return { Window = window, AutoComplete = autoComplete }
end