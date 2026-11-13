local v = { "X", "Y", "Z" }

local function validateVector(p: number?, p2: number)
	if p == nil then
		return false, `Invalid or missing number at position {p2} in Vector type.`
	end

	return true
end

return function(registry)
	local sequenceType = registry.Cmdr.Util.MakeSequenceType({
		ValidateEach = validateVector,
		TransformEach = tonumber,
		Constructor = Vector3.new,
		Length = 3
	})

	local sequenceType2 = registry.Cmdr.Util.MakeSequenceType({
		ValidateEach = validateVector,
		TransformEach = tonumber,
		Constructor = Vector2.new,
		Length = 2
	})

	local sequenceType3 = registry.Cmdr.Util.MakeSequenceType({
		Transform = function(p: string, player)
			local character = player.Character
			local v2 = not character and Vector3.new(0, 0, 0) or character:GetPivot().Position

			return registry.Cmdr.Util.Map(
				registry.Cmdr.Util.SplitPrioritizedDelimeter(p, { ",", "%s" }),
				function(value: string, p2: number)
					if value:sub(1, 1) ~= "~" then
						return (tonumber(value))
					end

					local v3 = v[p2]
					local selected = not v3 and 0 or v2[v3]
					local v4 = tonumber(value:sub(2))

					if value == "~" then
						return selected
					end

					if v4 then
						return selected + v4
					end

					return nil
				end
			)
		end,
		ValidateEach = validateVector,
		Constructor = Vector3.new,
		Length = 3
	})

	registry:RegisterType("vector3", sequenceType)
	registry:RegisterType("vector3s", registry.Cmdr.Util.MakeListableType(sequenceType))

	registry:RegisterType("vector2", sequenceType2)
	registry:RegisterType("vector2s", registry.Cmdr.Util.MakeListableType(sequenceType2))

	registry:RegisterType("positionVector3", sequenceType3)
	registry:RegisterType("positionVector3s", registry.Cmdr.Util.MakeListableType(sequenceType3))
end