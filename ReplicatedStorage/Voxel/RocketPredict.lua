local bindableEvent = Instance.new("BindableEvent")
return {
	["fired"] = bindableEvent.Event,
	fire = function(vector3: Vector3, vector3_2: Vector3, vector3_3: Vector3?, flag: boolean?, flag2: boolean?)
		bindableEvent:Fire(vector3, vector3_2.Unit, vector3_3, flag == true, flag2 == true)
	end
}