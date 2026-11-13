local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BuiltInGuards = ReplicatedStorage.CmdrClient.Shared.BuiltInGuards
local HasCharacter = require(BuiltInGuards.HasCharacter)

return {
	Name = "blink",
	Aliases = { "b" },
	Description = "Teleports you to where your mouse is hovering.",
	Group = "DefaultDebug",
	Args = {},
	Guards = { HasCharacter() },
	ClientRun = function(p): string
		local mouse = p.Executor:GetMouse()
		local character = p.Executor.Character

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { character }
		raycastParams.IgnoreWater = true
		raycastParams.RespectCanCollide = true

		local raycastResult = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 1000, raycastParams)
		local v

		if raycastResult then
			v = raycastResult.Position
		else
			v = mouse.Hit.Position
		end

		character:MoveTo(v)

		return "Blinked!"
	end
}