return {
	Name = "clear",
	Description = "Clear all lines above the entry line of the Cmdr window.",
	Group = "DefaultUtil",
	Args = {},
	ClientRun = function(p): string
		local frame = p.Cmdr.Gui:WaitForChild("Frame", 2)

		if not frame then
			return "Failed to clear: Frame not found."
		end

		for _, textBox in pairs(frame:GetChildren()) do
			if textBox.Name == "Line" and textBox:IsA("TextBox") then
				textBox:Destroy()
			end
		end

		return ""
	end
}