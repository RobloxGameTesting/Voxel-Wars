local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BuiltInGuards = ReplicatedStorage.CmdrClient.Shared.BuiltInGuards
local HasCharacter = require(BuiltInGuards.HasCharacter)

return {
	Name = "thru",
	Aliases = { "t", "through" },
	Description = "Teleports you through whatever your mouse is hovering over, placing you equidistantly from the wall.",
	Group = "DefaultDebug",
	Args = {
		{
			Type = "number",
			Name = "Extra distance",
			Description = "Go through the wall an additional X studs.",
			Default = 0
		}
	},
	Guards = { HasCharacter() },
	ClientRun = function(p, p2: number): string
		local mouse = p.Executor:GetMouse()
		local character = p.Executor.Character
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { character }
		raycastParams.IgnoreWater = true
		raycastParams.RespectCanCollide = true

		local raycastResult = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 1000, raycastParams)

		if not raycastResult then
			character:MoveTo(mouse.Hit.Position)
			return "Blinked (No wall found)!"
		end

		local position = humanoidRootPart.Position
		local v = raycastResult.Position - position
		local v2

		if v.Magnitude > 0 then
			v2 = v.Unit
		else
			v2 = Vector3.new()
		end

		character:MoveTo(v * 2 + v2 * p2 + position)
		return "Thru the wall!"
	end
}