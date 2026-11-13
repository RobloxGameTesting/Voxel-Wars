local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

require(script.Parent:WaitForChild("Style"))
local Glyph = require(script.Parent:WaitForChild("Glyph"))

local MenuLock = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("MenuLock"))
local ShopData = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("ShopData"))

local function carriesStreak(localPlayer): boolean
	for _, v in { localPlayer.Character, localPlayer:FindFirstChildOfClass("Backpack") } do
		if not v then
			continue
		end

		for _, tool in v:GetChildren() do
			local v2

			if tool:IsA("Tool") then
				v2 = ShopData.ITEMS[tool.Name]
			end

			if v2 ~= nil and v2.slot == "streak" then
				return true
			end
		end
	end

	return false
end

local function padFree(p): boolean
	local localPlayer = Players.LocalPlayer

	if MenuLock.open or Glyph.claimed("vote") or Glyph.claimed("menu") then
		return false
	end

	if localPlayer:GetAttribute("InVehicle") ~= nil or localPlayer:GetAttribute("ReviveFocus") == true then
		return false
	end

	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if
		not humanoid
		or humanoid.Health <= 0
		or character and character:FindFirstChild("BuildHammer")
		or p == Enum.KeyCode.DPadRight and localPlayer.Team == nil and localPlayer:GetAttribute("PickingTeam") == true
	then
		return false
	end

	return p ~= Enum.KeyCode.DPadDown or not carriesStreak(localPlayer)
end

local function square(guiObject)
	if guiObject.Name ~= "Key" or not guiObject:IsA("GuiObject") then
		return
	end

	guiObject.AutomaticSize = Enum.AutomaticSize.None
	guiObject.Size = UDim2.fromOffset(20, 20)
	local uiPadding = guiObject:FindFirstChildOfClass("UIPadding")

	if uiPadding then
		uiPadding:Destroy()
	end

	local text = guiObject:FindFirstChild("Text")

	if text and text:IsA("TextLabel") then
		text.AutomaticSize = Enum.AutomaticSize.None
		text.Size = UDim2.fromScale(1, 1)
		text.Position = UDim2.new()
		text.AnchorPoint = Vector2.zero
		text.TextXAlignment = Enum.TextXAlignment.Center
		text.TextYAlignment = Enum.TextYAlignment.Center
	end
end

return {
	add = function(object, _: string, _, p)
		if not p then
			return
		end

		local instance = object:getInstance("Contents")
		assert(instance, "[TopbarKey] TopbarPlus icon has no Contents row")
		local keyCap = Glyph.cap(instance, nil, p, 20)
		keyCap.Name = "KeyCap"
		keyCap.LayoutOrder = 6
		keyCap.ZIndex = 15
		keyCap.ChildAdded:Connect(function(child)
			task.defer(square, child)
		end)
		Glyph.setCap(keyCap, nil, nil)
		Glyph.setCap(keyCap, nil, p)
		local visible = nil
		local function resize()
			if keyCap.Visible ~= visible then
				visible = keyCap.Visible
				object:setWidth(visible and 78 or 0)
			end

			object.updateSize:Fire()
		end
		keyCap:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
		keyCap:GetPropertyChangedSignal("Visible"):Connect(resize)
		task.defer(resize)
		UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
			if gameProcessed or object.locked or (input.KeyCode ~= p or not padFree(p)) then
				return
			end

			if object.isSelected then
				object:deselect()
			else
				object:select()
			end
		end)
	end
}