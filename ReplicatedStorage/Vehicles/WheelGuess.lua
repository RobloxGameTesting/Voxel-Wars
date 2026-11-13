return {
	fill = function(data, cframe: CFrame, vector3: Vector3, vector: Vector3, p: number)
		local def = data.def
		local tuning = data.tuning
		local upVector = cframe.UpVector
		local pointToWorldSpace = cframe:PointToWorldSpace(def.center or Vector3.new(0, 0, 0))
		local v = math.clamp(math.abs(-cframe:VectorToObjectSpace(vector3).Z) / 4, 0, 1)
		local maxSteer = tuning and tuning.maxSteer or 0.6
		local topSpeed = tuning and tuning.topSpeed or 0
		local params = data.params
		local v2 = not data.asleep

		for k, wheel in data.wheels do
			local wheel2 = def.wheels[k]

			if not wheel2 then
				continue
			end

			local pointToWorldSpace2 = cframe:PointToWorldSpace(wheel2.mount)
			local vectorToObjectSpace = cframe:VectorToObjectSpace(vector3 + vector:Cross(pointToWorldSpace2 - pointToWorldSpace))
			local v3 = -vectorToObjectSpace.Z

			local v4 = wheel2.travel + 1.1
			local spherecast = workspace:Spherecast(
				pointToWorldSpace2 + upVector * 1.1,
				wheel2.radius,
				-upVector * v4,
				params
			)
			local contact

			if spherecast == nil then
				contact = false
			else
				contact = spherecast.Normal:Dot(upVector) > 0.3
			end

			local shown = not (spherecast and contact) and 0 or math.clamp(v4 - spherecast.Distance, 0, wheel2.travel)

			if wheel.shown <= shown then
				wheel.shown = shown
			else
				wheel.shown += (shown - wheel.shown) * math.min(p * 14, 1)
			end

			wheel.contact = contact

			if contact or not v2 then
				wheel.speed = not v2 and 0 or v3
			else
				wheel.speed += ((data.throttle or 0) * topSpeed - wheel.speed) * math.min(p * 3, 1)
			end

			if wheel2.steer == 0 then
				continue
			end

			local v5

			if v > 0 and math.abs(v3) > 0.3 then
				local v6 = math.sign(v3)
				local v7 = maxSteer * math.abs(wheel2.steer)
				v5 = math.clamp(math.atan2(vectorToObjectSpace.X * v6, v3 * v6), -v7, v7) * v
			else
				v5 = 0
			end

			wheel.steer += (v5 - wheel.steer) * math.min(p * 10, 1)
		end
	end
}