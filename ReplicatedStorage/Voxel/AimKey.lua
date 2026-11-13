local UserInputService = game:GetService("UserInputService")
local MenuLock = require(script.Parent:WaitForChild("MenuLock"))

local AimKey = {}

AimKey.KEY = Enum.KeyCode.Q

local v = {
	Enum.KeyCode.LeftSuper,
	Enum.KeyCode.RightSuper,
	Enum.KeyCode.LeftMeta,
	Enum.KeyCode.RightMeta
}

local function modDown(): boolean -- 1 equivalent call inferred from this helper
	for _, v2 in v do
		if UserInputService:IsKeyDown(v2) then
			return true
		end
	end

	return false
end

function AimKey.began(p, flag: boolean?)
	if p.UserInputType == Enum.UserInputType.MouseButton2 then
		return true
	end

	local v2

	if p.KeyCode == AimKey.KEY then
		v2 = not flag

		if v2 then
			if UserInputService:GetFocusedTextBox() == nil then
				return not MenuLock.open and not modDown() -- inferred equivalent call
			end

			return false
		end
	else
		return false
	end

	return v2
end

function AimKey.ended(p): boolean
	if p.UserInputType == Enum.UserInputType.MouseButton2 then
		return not UserInputService:IsKeyDown(AimKey.KEY)
	end

	if p.KeyCode == AimKey.KEY then
		return not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
	end

	return false
end

return AimKey