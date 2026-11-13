local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Style = require(script.Parent.Style)

local function show(p, upgradeRefund: number)
	local layer = Style.layer(p.playerGui, "RefundNotice", 20, true)
	local fill = Style.fill(layer, "Shade", Style.INK, UDim2.fromScale(1, 1))
	fill.BackgroundTransparency = 0.45
	fill.Active = true

	local region = Style.region(layer, "Card", Vector2.new(0.5, 0.5), Vector2.zero, Vector2.new(360, 262))
	local panel = Style.panel(region, "Panel", UDim2.fromScale(1, 1), 4)
	panel.BackgroundTransparency = 0
	Style.tape(panel, "Tape", UDim2.fromOffset(360, 8), 360, 10)

	local label = Style.label(panel, "Title", "SCRAP REFUNDED", 26)
	label.AutomaticSize = Enum.AutomaticSize.None
	label.Size = UDim2.new(1, 0, 0, 32)
	label.Position = UDim2.fromOffset(0, 20)

	local nut = Style.nut(panel, 30)
	local label2 = Style.label(panel, "Amount", "+" .. Style.thousands(upgradeRefund), 34)
	label2.AutomaticSize = Enum.AutomaticSize.None
	label2.TextColor3 = Style.HAZARD
	label2.TextXAlignment = Enum.TextXAlignment.Left
	label2.Size = UDim2.fromOffset(190, 40)
	label2.Position = UDim2.fromOffset(130, 58)
	nut.Position = UDim2.fromOffset(94, 63)

	local label3 = Style.label(
		panel,
		"Body",
		"There's a new weapon upgrade system! Level up a gun to unlock attachments, then fit them with CUSTOMIZE in the ARMORY.",
		16,
		Style.FONT_BODY,
		0
	)
	label3.AutomaticSize = Enum.AutomaticSize.None
	label3.TextWrapped = true
	label3.TextColor3 = Style.MUTED
	label3.Size = UDim2.fromOffset(316, 66)
	label3.Position = UDim2.fromOffset(22, 104)

	local button = Style.button(panel, "Ok", "OK", Style.HAZARD, UDim2.fromOffset(150, 48), Style.INK, 22)
	button.AnchorPoint = Vector2.new(0.5, 1)
	button.Position = UDim2.new(0.5, 0, 1, -14)

	p.setMenu(true)
	local inputBeganConnection = nil
	local function close() -- 1 equivalent call inferred from this helper
		inputBeganConnection:Disconnect()
		layer:Destroy()
		p.setMenu(false)
	end
	button.Activated:Connect(close)
	inputBeganConnection = UserInputService.InputBegan:Connect(function(input)
		if
			input.KeyCode == Enum.KeyCode.ButtonA
			or input.KeyCode == Enum.KeyCode.ButtonB
			or input.KeyCode == Enum.KeyCode.Return
		then
			close() -- inferred equivalent call
		end
	end)
end

return {
	mount = function(p)
		if RunService:IsStudio() then
			return
		end

		local player = p.player
		local upgradeRefund = player:GetAttribute("UpgradeRefund")

		while type(upgradeRefund) ~= "number" do
			player:GetAttributeChangedSignal("UpgradeRefund"):Wait()
			upgradeRefund = player:GetAttribute("UpgradeRefund")
		end

		show(p, upgradeRefund)
	end
}