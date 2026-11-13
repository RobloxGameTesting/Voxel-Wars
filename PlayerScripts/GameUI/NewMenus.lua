return {
	on = function(attributeName: string)
		local on = script:GetAttribute("On")
		local attribute = script:GetAttribute(attributeName)
		assert(type(on) == "boolean", "[NewMenus] the On attribute is missing")
		assert(type(attribute) == "boolean", "[NewMenus] no switch named " .. attributeName)
		return on and attribute
	end
}