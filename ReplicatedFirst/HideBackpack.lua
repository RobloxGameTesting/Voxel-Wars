local StarterGui = game:GetService("StarterGui")

for _ = 1, 40 do
	if pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	end) then
		return
	end

	task.wait(0.25)
end

error("HideBackpack: could not turn off the built-in tool hotbar")