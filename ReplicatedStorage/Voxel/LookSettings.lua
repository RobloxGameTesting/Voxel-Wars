local UserInputService = game:GetService("UserInputService")

local LookSettings = {
	DEFAULT = 1,
	MIN = 0.25,
	MAX = 4,
	STEP = 0.05,
	look = 1,
	aim = 1,
	vehicle = 1,
	touchAssist = true,
	touchAutoFire = true
}

local function clean(p: number) -- 3 equivalent calls inferred from this helper
	return (math.clamp(math.round(p / LookSettings.STEP) * LookSettings.STEP, LookSettings.MIN, LookSettings.MAX))
end

LookSettings.clean = clean

function LookSettings.set(p: number, p2: number, p3: number?)
	local look = clean(p) -- inferred equivalent call
	local aim = clean(p2) -- inferred equivalent call
	LookSettings.look = look
	LookSettings.aim = aim
	LookSettings.vehicle = clean(p3 or LookSettings.DEFAULT) -- inferred equivalent call
	UserInputService.MouseDeltaSensitivity = LookSettings.look
end

function LookSettings.aimScale(value: number)
	return 1 + (LookSettings.aim - 1) * math.clamp(value, 0, 1)
end

return LookSettings