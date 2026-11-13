local EmplacementData = {}
EmplacementData.WEAPON = "MountedGun"
EmplacementData.GUN = {
	rate = 9,
	burst = 8,
	spread = 0.55,
	yaw = 0.9599310885968813,
	pitchUp = 0.4363323129985824,
	pitchDown = 0.2617993877991494,
	heat = 1 / 81,
	cool = 0.2,
	coolDelay = 0.3,
	unlock = 0.5,
	tracerEvery = 2
}
EmplacementData.PIVOT_UP = 3.4
EmplacementData.STAND_BACK = 2.5
EmplacementData.ROOT_UP = 3
EmplacementData.MUZZLE = Vector3.new(0, 0, -3.1)
EmplacementData.REACH = 5.5
EmplacementData.LEASH = 7
EmplacementData.BOARD_AFTER_SPAWN = 1.5
EmplacementData.REENTER_GAP = 0.6
EmplacementData.GROUND_KEEP = 9
EmplacementData.WALL = { far = 3.75, top = 2, clear = 0.2 }

EmplacementData.SPOTS = {
	highcrag = {
		{ name = "A guard", x = -280, z = -48, look = Vector3.new(0.342, 0, 0.94) },
		{ name = "HQ gate", x = 20, z = -350, look = Vector3.new(0, 0, 1) }
	}
}

function EmplacementData.list(p: string)
	local result = {}
	local v = EmplacementData.SPOTS[p]

	if not v then
		return result
	end

	for _, v2 in v do
		local v3 = v2.look.Y == 0 and v2.look.Magnitude > 0.5
		assert(v3, "[EmplacementData] " .. p .. " " .. v2.name .. ": look must be flat and not zero")
		local unit = v2.look.Unit

		if v2.team then
			assert(
				v2.team == "Blues" or v2.team == "Reds",
				"[EmplacementData] " .. p .. " " .. v2.name .. ": team must be Blues or Reds"
			)
			table.insert(result, {
				id = #result + 1,
				name = v2.name,
				team = v2.team,
				x = v2.x,
				z = v2.z,
				look = unit
			})
		else
			table.insert(result, {
				id = #result + 1,
				name = v2.name,
				team = "Blues",
				x = v2.x,
				z = v2.z,
				look = unit
			})
			table.insert(result, {
				id = #result + 1,
				name = v2.name,
				team = "Reds",
				x = -v2.x,
				z = -v2.z,
				look = -unit
			})
		end
	end

	return result
end

function EmplacementData.base(position: Vector3, vector3: Vector3)
	return CFrame.new(position) * CFrame.Angles(0, math.atan2(-vector3.X, -vector3.Z), 0)
end

function EmplacementData.mount(cframe: CFrame, p: number)
	return cframe * CFrame.Angles(0, p, 0)
end

function EmplacementData.gun(cframe: CFrame, p: number, p2: number)
	return cframe * CFrame.Angles(0, p, 0) * CFrame.Angles(p2, 0, 0)
end

function EmplacementData.dip(p: number)
	local wall = EmplacementData.WALL
	local v = EmplacementData.PIVOT_UP - wall.top - wall.clear

	if v <= 0 then
		return 0
	end

	local v2 = wall.far / math.max(math.cos(p), 0.2)
	return (math.min(EmplacementData.GUN.pitchDown, (math.atan2(v, v2))))
end

function EmplacementData.clamp(value: number, value2: number)
	local gun = EmplacementData.GUN
	local v = math.clamp(value, -gun.yaw, gun.yaw)
	return v, (math.clamp(value2, -EmplacementData.dip(v), gun.pitchUp))
end

function EmplacementData.aimOf(cframe: CFrame, vector3: Vector3)
	local vectorToObjectSpace = cframe:VectorToObjectSpace(vector3.Unit)
	return EmplacementData.clamp(
		math.atan2(-vectorToObjectSpace.X, -vectorToObjectSpace.Z),
		(math.asin((math.clamp(vectorToObjectSpace.Y, -1, 1))))
	)
end

function EmplacementData.stand(cframe: CFrame, p: number)
	return EmplacementData.mount(cframe, p) * CFrame.new(
		0,
		EmplacementData.ROOT_UP - EmplacementData.PIVOT_UP,
		EmplacementData.STAND_BACK
	)
end

return EmplacementData