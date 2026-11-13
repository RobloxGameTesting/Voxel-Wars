local StandardBody = {}

StandardBody.HEADS = {
	[0] = true,
	[10725826963] = true,
	[11308945948] = true,
	[10725626210] = true
}

StandardBody.SKIN = {
	Color3.fromRGB(245, 208, 169),
	Color3.fromRGB(234, 184, 146),
	Color3.fromRGB(217, 165, 119),
	Color3.fromRGB(192, 138, 94),
	Color3.fromRGB(168, 110, 74),
	Color3.fromRGB(138, 90, 60),
	Color3.fromRGB(110, 70, 48),
	Color3.fromRGB(86, 58, 40)
}

function StandardBody.skin(color: Color3)
	local function lum(color2: Color3) -- 2 equivalent calls inferred from this helper
		return 0.299 * color2.R + 0.587 * color2.G + 0.114 * color2.B
	end

	local v = StandardBody.SKIN[1]
	local v2 = 1e999

	for _, v3 in StandardBody.SKIN do
		local v4 = (lum(color) - lum(v3)) ^ 2 * 4 + (color.R - v3.R) ^ 2 + (color.G - v3.G) ^ 2 + (color.B - v3.B) ^ 2 -- inferred equivalent call

		if not (v4 < v2) then
			continue
		end

		v = v3
		v2 = v4
	end

	return v
end

function StandardBody:apply()
	self.Torso = 0
	self.LeftArm = 0
	self.RightArm = 0
	self.LeftLeg = 0
	self.RightLeg = 0
	self.HeightScale = 1
	self.WidthScale = 1
	self.DepthScale = 1
	self.HeadScale = 1
	self.BodyTypeScale = 0
	self.ProportionScale = 0

	if not StandardBody.HEADS[self.Head] then
		self.Head = 0
	end

	local skin = StandardBody.skin(self.HeadColor)
	self.HeadColor = skin
	self.LeftArmColor = skin
	self.RightArmColor = skin
	self.ClimbAnimation = 0
	self.FallAnimation = 0
	self.IdleAnimation = 0
	self.JumpAnimation = 0
	self.RunAnimation = 0
	self.SwimAnimation = 0
	self.WalkAnimation = 0
	self.MoodAnimation = 0
end

return StandardBody