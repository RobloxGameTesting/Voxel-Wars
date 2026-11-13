local module = require("./Util")

local function unescapeOperators(value: string)
	for _, v in ipairs({ "%.", "%?", "%*", "%*%*" }) do
		value = value:gsub(`\\{v}`, v:gsub("%%", ""))
	end

	return value
end

local Argument = {}
Argument.__index = Argument

function Argument.new(command, data, rawValue)
	local v = {
		Command = command,
		Type = nil,
		Name = data.Name,
		Object = data,
		Required = data.Default == nil and data.Optional ~= true,
		Executor = command.Executor,
		RawValue = rawValue,
		RawSegments = {},
		TransformedValues = {},
		Prefix = "",
		TextSegmentInProgress = "",
		RawSegmentsAreAutocomplete = false
	}

	if type(data.Type) == "table" then
		v.Type = data.Type
	else
		local typeName = command.Cmdr.Registry:GetTypeName(data.Type)
		local prefixedUnionType, rawValue2, prefix = module.ParsePrefixedUnionType(typeName, rawValue)
		local kind = command.Dispatcher.Registry:GetType(prefixedUnionType)
		assert(kind, `[Cmdr] Argument "{v.Name or "none"}" has an unregistered type {prefixedUnionType or "<none>"}`)

		v.Type = kind
		v.RawValue = rawValue2
		v.Prefix = prefix
	end

	setmetatable(v, Argument)

	v:Transform()

	return v
end

function Argument:TransformSegment(p: string)
	if self.Type.Transform then
		return self.Type.Transform(p, self.Executor)
	end

	return p
end

function Argument:GetDefaultAutocomplete()
	if not self.Type.Autocomplete then
		return {}
	end

	local autocomplete, v = self.Type.Autocomplete(self:TransformSegment(""))
	return autocomplete, v or {}
end

function Argument:Transform()
	if #self.TransformedValues ~= 0 then
		return
	end

	local v = self.RawValue
	v = self.Type.ArgumentOperatorAliases and self.Type.ArgumentOperatorAliases[v] or v

	if v == "." and self.Type.Default then
		v = self.Type.Default(self.Executor) or ""
		self.RawSegmentsAreAutocomplete = true
	end

	if v == "?" and self.Type.Autocomplete then
		local defaultAutocomplete, v2 = self:GetDefaultAutocomplete()

		if not v2.IsPartial and #defaultAutocomplete > 0 then
			v = defaultAutocomplete[math.random(1, #defaultAutocomplete)]
			self.RawSegmentsAreAutocomplete = true
		end
	end

	if self.Type.Listable and #self.RawValue > 0 then
		local match = v:match("^%?(%d+)$")

		if match then
			local v2 = tonumber(match)

			if v2 and v2 > 0 then
				local defaultAutocomplete, v3 = self:GetDefaultAutocomplete()
				local v4 = {}

				if not v3.IsPartial and #defaultAutocomplete > 0 then
					for _ = 1, math.min(v2, #defaultAutocomplete) do
						table.insert(v4, table.remove(defaultAutocomplete, math.random(1, #defaultAutocomplete)))
					end

					v = table.concat(v4, ",")
					self.RawSegmentsAreAutocomplete = true
				end
			end
		elseif v == "*" or v == "**" then
			local defaultAutocomplete, v2 = self:GetDefaultAutocomplete()

			if not v2.IsPartial and #defaultAutocomplete > 0 then
				if v == "**" and self.Type.Default then
					local v3 = self.Type.Default(self.Executor) or ""

					for i, v4 in ipairs(defaultAutocomplete) do
						if v4 == v3 then
							table.remove(defaultAutocomplete, i)
						end
					end
				end

				v = table.concat(defaultAutocomplete, ",")
				self.RawSegmentsAreAutocomplete = true
			end
		end

		local v2 = unescapeOperators(v)

		local splitStringSimple = module.SplitStringSimple(v2, ",")
		local v3 = #splitStringSimple == 0 and { "" } or splitStringSimple

		if v2:sub(#v2, #v2) == "," then
			v3[#v3 + 1] = ""
		end

		for i, v4 in ipairs(v3) do
			self.RawSegments[i] = v4
			self.TransformedValues[i] = { self:TransformSegment(v4) }
		end

		self.TextSegmentInProgress = v3[#v3]
	else
		local v2 = unescapeOperators(v)

		self.RawSegments[1] = unescapeOperators(v2)
		self.TransformedValues[1] = { self:TransformSegment(v2) }
		self.TextSegmentInProgress = self.RawValue
	end
end

function Argument:GetTransformedValue(p: number)
	return unpack(self.TransformedValues[p])
end

function Argument:Validate(flag: boolean?)
	if not self.RawValue or #self.RawValue == 0 and self.Required == false then
		return true
	end

	if self.Required and (not self.RawSegments[1] or #self.RawSegments[1] == 0) then
		return false, "This argument is required."
	end

	if not (self.Type.Validate or self.Type.ValidateOnce) then
		return true
	end

	for i = 1, #self.TransformedValues do
		if self.Type.Validate then
			local v, v2 = self.Type.Validate(self:GetTransformedValue(i))

			if not v then
				return v, v2 or "Invalid value"
			end
		end

		if not (flag and self.Type.ValidateOnce) then
			continue
		end

		local v, v2 = self.Type.ValidateOnce(self:GetTransformedValue(i))

		if not v then
			return v, v2
		end
	end

	return true
end

function Argument:GetAutocomplete()
	if self.Type.Autocomplete then
		return self.Type.Autocomplete(self:GetTransformedValue(#self.TransformedValues))
	end

	return {}
end

function Argument:_parseValue(p: number)
	if self.Type.Parse then
		return self.Type.Parse(self:GetTransformedValue(p))
	end

	return self:GetTransformedValue(p)
end

function Argument:GetValue()
	if #self.RawValue == 0 and not self.Required and self.Object.Default ~= nil then
		return self.Object.Default
	end

	if not self.Type.Listable then
		return self:_parseValue(1)
	end

	local set = {}

	for i = 1, #self.TransformedValues do
		local value = self:_parseValue(i)
		assert(type(value) == "table", `[Cmdr] Listable types must return a table from Parse {self.Type.Name}`)

		for _, v in pairs(value) do
			set[v] = true
		end
	end

	local result = {}

	for k in pairs(set) do
		result[#result + 1] = k
	end

	return result
end

return Argument