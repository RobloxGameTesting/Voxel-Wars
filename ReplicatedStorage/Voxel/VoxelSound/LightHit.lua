return {
	counts = {
		["rbxassetid://9114086455"] = 4,
		["rbxassetid://9114086583"] = 4,
		["rbxassetid://9114086657"] = 4,
		["rbxassetid://9116973611"] = 5
	},
	make = function(data)
		local bag = data.bagOf({
			data.gslice(9114086455, 0.03, 0.63, 1.2),
			data.gslice(9114086583, 0.025, 0.625, 1.19),
			data.gslice(9114086657, 0, 0.6, 2.5)
		})
		local v = {
			bag = data.bagOf({ data.gslice(9116973611, 0.025, 0.45, 1.41) }),
			lo = 0.84,
			hi = 0.96,
			length = 0.42
		}
		local v2 = -1e999
		return function(vector3: Vector3)
			local camPos = data.camPos()
			local magnitude = (vector3 - camPos).Magnitude
			local v3 = math.max(magnitude / data.METER, 1)
			local jitter = data.jitter()
			local smoothstep = data.smoothstep(data.farFrom, data.farTo, v3)
			local pathTo, v4 = data.pathTo(vector3, camPos, magnitude, v3, 3)
			local v5 = math.min(1, 30 / v3) * 1 * jitter * pathTo

			if smoothstep < 1 then
				local v6 = v5 * (1 - smoothstep)
				data.emitAt(data.draw(bag), vector3, v6, data.pitch(0.86, 0.96), "dry", v4, 0.6, 0.25, v6 + 1.5)
			end

			if v3 < 90 then
				data.later(0.02 + 0.03 * math.random(), data.layer, v, vector3, 0.8 * v5, v4)
			end

			local v6 = math.min(1, 200 / v3) * 0.75 * jitter * math.max(smoothstep, 0.2) * math.sqrt(pathTo)
			data.emitAt(data.draw(data.farBag), vector3, v6 * 0.25, data.pitch(0.85, 0.95), "dry", v4, 1, 0.3, v6 + 0.5)
			local now = os.clock()

			if now - v2 >= 0.6 then
				v2 = now
				data.placeTail(vector3, math.min(1, 90 / v3) * 0.45, v3, 0.8, 1)
			end

			data.heardFight(v5)
		end
	end
}