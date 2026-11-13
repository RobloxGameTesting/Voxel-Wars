local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Skins = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("Skins"))

local OutfitLook = {}
OutfitLook.BACKDROP = "rbxassetid://116063339826688"
OutfitLook.CARD = {
	common = "rbxassetid://98801361814651",
	rare = "rbxassetid://99454226084550",
	epic = "rbxassetid://131951660615346",
	legendary = "rbxassetid://90827941239516",
	mythic = "rbxassetid://110395910597342",
	premium = "rbxassetid://78072194539432"
}

OutfitLook.CARD_LIT = {
	common = "rbxassetid://99703426596836",
	rare = "rbxassetid://119427689355119",
	epic = "rbxassetid://122178442371784",
	legendary = "rbxassetid://93655942842037",
	mythic = "rbxassetid://83588745297588",
	premium = "rbxassetid://86007857959660"
}
OutfitLook.LIGHT = "rbxassetid://109847304101357"
OutfitLook.HALO = "rbxassetid://128809277282328"
OutfitLook.HALO_GROW = Vector2.new(4 / 3, 35 / 27)
OutfitLook.HALO_COLOR = Color3.fromRGB(255, 200, 40)
function OutfitLook.glows(p): boolean
	return Skins.rarityOf(p).id == "legendary"
end

local color = Color3.fromRGB(242, 238, 228)

OutfitLook.THEME = {
	SkyRaider = { color = Color3.fromRGB(70, 170, 255), card = "rbxassetid://73182175881410" },
	Venom = { color = Color3.fromRGB(70, 255, 96) },
	Inferno = { color = Color3.fromRGB(255, 122, 28), card = "rbxassetid://106083885046833" },
	Revenant = { color = Color3.fromRGB(168, 96, 255), card = "rbxassetid://96001863196650" }
}

local function hue(p) -- 2 equivalent calls inferred from this helper
	local v = OutfitLook.THEME[p.id]

	if v then
		return v.color
	end

	return Skins.rarityOf(p).color
end

function OutfitLook.tagColor(p)
	return hue(p):Lerp(color, 0.4) -- inferred equivalent call
end

function OutfitLook.rimColor(p)
	return hue(p):Lerp(color, 0.45) -- inferred equivalent call
end

function OutfitLook.card(parent, _, p, p2, flag: boolean?)
	local rarity = Skins.rarityOf(p2)
	p.Text = rarity.name
	local textColor

	if flag then
		textColor = color
	else
		textColor = OutfitLook.tagColor(p2)
	end

	p.TextColor3 = textColor
	local rarityCard = Instance.new("ImageLabel")
	rarityCard.Name = "RarityCard"
	rarityCard.BackgroundTransparency = 1
	local v = OutfitLook.THEME[p2.id]
	local image

	if flag and v and v.card then
		image = v.card
	elseif flag then
		image = OutfitLook.CARD_LIT[rarity.id]
	else
		image = OutfitLook.CARD[rarity.id]
	end

	rarityCard.Image = image
	rarityCard.ScaleType = Enum.ScaleType.Stretch
	rarityCard.Size = UDim2.fromScale(1, 1)
	rarityCard.ZIndex = 0
	local uiCorner = parent:FindFirstChildOfClass("UICorner")

	if uiCorner then
		local clone = uiCorner:Clone()
		clone.Parent = rarityCard
	end

	rarityCard.Parent = parent
end

function OutfitLook.stage(parent)
	local Style = require(script.Parent:WaitForChild("Style"))
	local backdrop = Instance.new("ImageLabel")
	backdrop.Name = "Backdrop"
	backdrop.BackgroundTransparency = 1
	backdrop.Image = OutfitLook.BACKDROP
	backdrop.ScaleType = Enum.ScaleType.Crop
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.ZIndex = -2
	backdrop.Parent = parent
	local uiCorner = parent:FindFirstChildOfClass("UICorner")

	if uiCorner then
		local clone = uiCorner:Clone()
		clone.Parent = backdrop
	end

	local label = Style.label(parent, "Rarity", "", 12, Style.FONT, 0)
	label.Position = UDim2.fromOffset(8, 6)
	label.ZIndex = 3

	local function set(p) -- 1 equivalent call inferred from this helper
		label.Visible = p ~= nil

		if p then
			label.Text = Skins.rarityOf(p).name
			label.TextColor3 = OutfitLook.tagColor(p)
		end
	end

	set() -- inferred equivalent call
	return { set = set }
end

return OutfitLook