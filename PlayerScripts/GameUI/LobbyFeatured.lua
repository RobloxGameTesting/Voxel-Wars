local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Style = require(script.Parent:WaitForChild("Style"))
local ArmoryStore = require(script.Parent:WaitForChild("ArmoryStore"))
local UiTrack = require(script.Parent:WaitForChild("UiTrack"))
local VehiclePreview = require(script.Parent:WaitForChild("VehiclePreview"))
local Game = ReplicatedStorage:WaitForChild("Game")
local CareerData = require(Game:WaitForChild("CareerData"))
local ShopData = require(Game:WaitForChild("ShopData"))
local Skins = require(Game:WaitForChild("Skins"))
local Gunsmith = ReplicatedStorage:FindFirstChild("Gunsmith")
local Gunsmith2

if Gunsmith then
	Gunsmith2 = require(Gunsmith:WaitForChild("Gunsmith"))
else
	Gunsmith2 = nil
end

local v = {
	gun = { w = 5.6, h = 2.5, up = 3 },
	pack = { w = 5.6, h = 2.5, up = 4.4 },
	chopper = { w = 11, h = 4.8, up = 12 }
}

local v2 = {}
local function priceOf(productId: number, robux: number, draw) -- 2 equivalent calls inferred from this helper
	local v3 = v2[productId]

	if v3 == nil then
		v2[productId] = "?"
		task.spawn(function()
			local success, productInfoAsync = pcall(
				MarketplaceService.GetProductInfoAsync,
				MarketplaceService,
				productId,
				Enum.InfoType.Product
			)

			if not success or type(productInfoAsync) ~= "table" or type(productInfoAsync.PriceInRobux) ~= "number" then
				warn("[LobbyFeatured] no price for developer product " .. productId .. ": " .. tostring(productInfoAsync))

				return
			end

			v2[productId] = productInfoAsync.PriceInRobux
			draw()
		end)
	end

	return if type(v3) == "number" then v3 else robux
end

local function rows()
	local toolTemplates = ReplicatedStorage:WaitForChild("ToolTemplates")
	local result = {}

	for _, v3 in CareerData.STORE.instant do
		if not (v3.productId ~= 0 and toolTemplates:FindFirstChild(v3.item)) then
			continue
		end

		local slot = ShopData.item(v3.item).slot

		if slot == "primary" or slot == "secondary" then
			table.insert(result, v3)
		end
	end

	table.sort(result, function(a, b): boolean
		local v3 = ShopData.unlockLevel(a.item)
		local v4 = ShopData.unlockLevel(b.item)

		if v3 == v4 then
			return a.item < b.item
		end

		return v3 < v4
	end)

	return result
end

local function everyGun()
	for _, v3 in CareerData.STORE.weaponPacks or {} do
		if v3.all and v3.productId ~= 0 then
			return v3
		end
	end

	return nil
end

local function loosen(folder)
	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
	end
end

local function fit(instance, p: number)
	instance.WorldPivot = CFrame.identity
	local _, v3 = instance:GetBoundingBox()
	local v4 = math.max(v3.X, v3.Y, v3.Z)

	if v4 > 0 then
		instance:ScaleTo(instance:GetScale() * p / v4)
	end

	local boundingBox = instance:GetBoundingBox()
	instance.WorldPivot = CFrame.new(boundingBox.Position)
end

local function gunModel(name: string, p: number)
	local parent

	if Gunsmith2 and Gunsmith2.has(name) then
		if not Gunsmith2.loadKit(name) then
			return nil
		end

		parent = Gunsmith2.preview(name, Gunsmith2.defaults(name))
	else
		local folder = ReplicatedStorage:WaitForChild("ToolTemplates"):FindFirstChild(name)
		local handle = folder and folder:FindFirstChild("Handle")
		assert(handle and handle:IsA("BasePart"), "[LobbyFeatured] ToolTemplates." .. name .. " has no Handle")
		parent = Instance.new("Tool")

		for _, part in folder:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			local clone = part:Clone()

			for _, child in clone:GetChildren() do
				child:Destroy()
			end

			for _, child in part:GetChildren() do
				if not (child:IsA("DataModelMesh") or child:IsA("Decal") or child:IsA("SurfaceAppearance")) then
					continue
				end

				local clone_2 = child:Clone()
				clone_2.Parent = clone
			end

			clone.CFrame = handle.CFrame:ToObjectSpace(part.CFrame)
			clone.Parent = parent
		end
	end

	local model = Instance.new("Model")
	model.Name = name

	for _, part in parent:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		for _, child in part:GetChildren() do
			if child:IsA("DataModelMesh") or child:IsA("Decal") or child:IsA("SurfaceAppearance") then
				continue
			end

			child:Destroy()
		end

		part.Parent = model
	end

	parent:Destroy()

	if #model:GetChildren() == 0 then
		model:Destroy()
		return nil
	end

	loosen(model)
	fit(model, p)
	return model
end

local function label(press, name: string, text: string, position: UDim2, size: UDim2, textColor: Color3, thickness: number, p)
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = name
	textLabel.BackgroundTransparency = 1
	textLabel.Position = position
	textLabel.Size = size
	textLabel.FontFace = Style.FONT
	textLabel.TextScaled = true
	textLabel.TextColor3 = textColor
	textLabel.Text = text
	textLabel.TextXAlignment = p or Enum.TextXAlignment.Center
	textLabel.Parent = press

	if thickness > 0 then
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Color = Style.INK
		uiStroke.Thickness = thickness
		uiStroke.Parent = textLabel
	end

	return textLabel
end

local function plate(parent, p: string, onActivated)
	local v3 = v[p]
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "LobbyFeatured_" .. p
	billboardGui.Size = UDim2.fromScale(v3.w, v3.h)
	billboardGui.StudsOffsetWorldSpace = Vector3.new(0, v3.up, 0)
	billboardGui.LightInfluence = 0
	billboardGui.MaxDistance = 300
	billboardGui.ResetOnSpawn = false
	billboardGui.Active = true
	billboardGui.Enabled = false
	billboardGui.Parent = parent
	local press = Instance.new("TextButton")
	press.Name = "Press"
	press.Text = ""
	press.AutoButtonColor = false
	press.BackgroundTransparency = 1
	press.Size = UDim2.fromScale(1, 1)
	press.Parent = billboardGui
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = press
	local v4 = label(press, "Name", "", UDim2.fromScale(0, 0), UDim2.fromScale(1, 0.36), Style.WHITE, 3)
	local v5 = label(press, "Note", "", UDim2.fromScale(0, 0.34), UDim2.fromScale(1, 0.15), Style.MUTED, 2)
	local buy = Instance.new("Frame")
	buy.Name = "Buy"
	buy.AnchorPoint = Vector2.new(0.5, 0)
	buy.Position = UDim2.fromScale(0.5, 0.52)
	buy.Size = UDim2.fromScale(0.86, 0.46)
	buy.Parent = press

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0.18, 0)
	uiCorner.Parent = buy
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Style.INK
	uiStroke.Thickness = 3
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Parent = buy

	local udim = UDim2.fromScale(0.05, 0.14)
	local udim2 = UDim2.fromScale(0.5, 0.72)
	local ink = Style.INK
	local right = Enum.TextXAlignment.Right
	local words = Instance.new("TextLabel")
	words.Name = "Words"
	words.BackgroundTransparency = 1
	words.Position = udim
	words.Size = udim2
	words.FontFace = Style.FONT
	words.TextScaled = true
	words.TextColor3 = ink
	words.Text = ""
	words.TextXAlignment = right or Enum.TextXAlignment.Center
	words.Parent = buy

	local robux = Instance.new("ImageLabel")
	robux.Name = "Robux"
	robux.BackgroundTransparency = 1
	robux.Image = "rbxasset://textures/ui/common/robux.png"
	robux.ImageColor3 = Style.INK
	robux.Position = UDim2.fromScale(0.585, 0.2)
	robux.Size = UDim2.fromScale(0.11, 0.6)
	robux.Parent = buy

	local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uiAspectRatioConstraint.AspectRatio = 1
	uiAspectRatioConstraint.Parent = robux

	local udim3 = UDim2.fromScale(0.7, 0.14)
	local udim4 = UDim2.fromScale(0.27, 0.72)
	local ink2 = Style.INK
	local left = Enum.TextXAlignment.Left
	local amount = Instance.new("TextLabel")
	amount.Name = "Amount"
	amount.BackgroundTransparency = 1
	amount.Position = udim3
	amount.Size = udim4
	amount.FontFace = Style.FONT
	amount.TextScaled = true
	amount.TextColor3 = ink2
	amount.Text = ""
	amount.TextXAlignment = left or Enum.TextXAlignment.Center
	amount.Parent = buy

	press.Activated:Connect(onActivated)
	return billboardGui, uiScale, function(data)
		if not data then
			return
		end

		v4.Text = data.title
		v5.Text = data.note
		local visible = not data.owned and data.price ~= nil
		local backgroundColor

		if visible then
			backgroundColor = Style.HAZARD
		else
			backgroundColor = Style.STEEL
		end

		buy.BackgroundColor3 = backgroundColor
		local textColor = if visible then Style.INK else Style.WHITE
		words.TextColor3 = textColor
		words.Text = visible and "UNLOCK" or "OWNED"
		local size

		if visible then
			size = UDim2.fromScale(0.5, 0.72)
		else
			size = UDim2.fromScale(0.9, 0.72)
		end

		words.Size = size
		local textXAlignment

		if visible then
			textXAlignment = Enum.TextXAlignment.Right
		else
			textXAlignment = Enum.TextXAlignment.Center
		end

		words.TextXAlignment = textXAlignment
		robux.Visible = visible
		amount.Visible = visible

		if visible then
			amount.Text = Style.thousands(data.price)
		end
	end
end

return {
	mount = function(instance, parent)
		local lobbyFeatured = Instance.new("Folder")
		lobbyFeatured.Name = "LobbyFeatured"
		local stands = {}
		local v3 = math.random(0, 2)
		local v4 = false
		local v5 = nil
		local count = 0

		local function level() -- 2 equivalent calls inferred from this helper
			local level2 = instance:GetAttribute("Level")
			return if type(level2) == "number" then level2 else 1
		end

		local function offerOf(stand)
			if stand.kind == "gun" then
				local v6 = v5

				if not v6 then
					return nil
				end

				local v7 = CareerData.unlockOf(v6)
				local owns = ShopData.owns(instance, v6)
				local v8 = ShopData.unlockLevel(v6)
				local v9

				if owns then
					v9 = nil
				else
					v9 = ArmoryStore.instant(instance, v6, stand.draw)
				end

				local title = if v7 then v7.name else v6
				local note

				if owns then
					note = ""
				else
					note = not (level() < v8) and "" or "UNLOCKS AT LEVEL " .. v8 -- inferred equivalent call
				end

				return {
					title = title,
					note = note,
					owned = owns,
					price = v9 and v9.price,
					run = v9 and function()
						UiTrack.send("featured_tap", v6)
						v9.run()
					end
				}
			elseif stand.kind == "pack" then
				local v6 = everyGun()

				if not v6 then
					return nil
				end

				local owned = true

				for _, item in v6.items do
					if not ShopData.owns(instance, item) then
						owned = false
					end
				end

				return {
					title = v6.name,
					note = #v6.items .. " WEAPONS",
					owned = owned,
					price = priceOf(v6.productId, v6.robux, stand.draw), -- inferred equivalent call
					run = function()
						UiTrack.send("featured_tap", v6.id)
						MarketplaceService:PromptProductPurchase(instance, v6.productId)
					end
				}
			else
				local v6 = CareerData.STORE.starter[1]

				if not v6 or v6.productId == 0 then
					return nil
				end

				return {
					title = "STEALTH CHOPPER",
					note = "+ 3 XP BOOSTS",
					owned = instance:GetAttribute(Skins.PACK_ATTR) == true,
					price = priceOf(v6.productId, v6.robux, stand.draw), -- inferred equivalent call
					run = function()
						UiTrack.send("featured_tap", v6.id)
						MarketplaceService:PromptProductPurchase(instance, v6.productId)
					end
				}
			end
		end

		local function setModel(p, model) -- 3 equivalent calls inferred from this helper
			if p.model then
				p.model:Destroy()
			end

			p.model = model
			p.placedAt = nil

			if model then
				model.Parent = lobbyFeatured
			end
		end

		local function newStand(kind: string, turns: boolean)
			local light = Instance.new("Part")
			light.Name = "Light"
			light.Anchored = true
			light.CanCollide = false
			light.CanQuery = false
			light.CanTouch = false
			light.Transparency = 1
			light.Size = Vector3.new(1, 1, 1)
			light.Parent = lobbyFeatured
			local pointLight = Instance.new("PointLight")
			pointLight.Color = Color3.fromRGB(255, 226, 170)
			pointLight.Range = kind == "chopper" and 16 or 10
			pointLight.Brightness = 1.4
			pointLight.Parent = light
			local stand = nil
			local gui, pop, v6 = plate(parent, kind, function()
				local offer = stand.offer

				if not offer or not offer.run or offer.owned or not stand.gui.Enabled then
					return
				end

				stand.pop.Scale = 0.92
				task.delay(0.12, function()
					stand.pop.Scale = 1
				end)
				offer.run()
			end)
			stand = {
				kind = kind,
				marker = nil,
				model = nil,
				gui = gui,
				light = light,
				pop = pop,
				draw = function() end,
				offer = nil,
				turns = turns,
				placedAt = nil
			}

			function stand.draw()
				stand.offer = offerOf(stand)
				v6(stand.offer)
			end
			stands[kind] = stand
			return stand
		end

		local v6 = newStand("gun", true)
		local v7 = newStand("pack", true)
		local v8 = newStand("chopper", false)

		local function chooseGun()
			local v9 = rows()

			if #v9 == 0 then
				return
			end

			local v10 = level() -- inferred equivalent call
			local v11 = {}
			local v12 = {}

			for _, v13 in v9 do
				if ShopData.owns(instance, v13.item) then
					continue
				end

				local v14

				if v10 < ShopData.unlockLevel(v13.item) then
					v14 = v11
				else
					v14 = v12
				end

				if #v14 < 3 then
					table.insert(v14, v13)
				end
			end

			if #v11 > 0 then
				v12 = v11
			end

			local item

			if #v12 > 0 then
				item = v12[v3 % #v12 + 1].item
			else
				item = v9[#v9].item
			end

			if item == v5 then
				v6.draw()
				return
			end

			v5 = item
			count += 1
			local v13 = count
			v6.draw()
			task.spawn(function()
				local model = gunModel(item, 6.4)

				if count == v13 then
					setModel(v6, model) -- inferred equivalent call
				elseif model then
					model:Destroy()
				end
			end)
		end

		local function buildRack()
			local v9 = everyGun()

			if not v9 then
				return
			end

			local show = v9.show or v9.items
			local everyGun2 = Instance.new("Model")
			everyGun2.Name = "EveryGun"
			local v10 = math.min(#show, 3)

			for i = 1, v10 do
				local v11 = gunModel(show[i], 5)

				if not v11 then
					continue
				end

				v11:PivotTo(CFrame.new(0, ((v10 + 1) / 2 - i) * 1.7, 0))
				v11.Parent = everyGun2
			end

			if #everyGun2:GetChildren() == 0 then
				everyGun2:Destroy()
				return
			end

			everyGun2.WorldPivot = CFrame.identity
			setModel(v7, everyGun2) -- inferred equivalent call
		end

		local function buildChopper()
			local model = VehiclePreview.model("StealthHeli")
			loosen(model)
			fit(model, 24)

			local boundingBox, v9 = model:GetBoundingBox()
			model.WorldPivot = CFrame.new(boundingBox.Position - Vector3.new(0, v9.Y / 2, 0))
			setModel(v8, model) -- inferred equivalent call
		end

		instance.AttributeChanged:Connect(function(value: string)
			if v5 and value == ShopData.ownsAttr(v5) then
				v6.draw()
				local v9 = v5
				task.delay(3, function()
					if v5 == v9 and ShopData.owns(instance, v9) then
						chooseGun()
					end
				end)
			end

			if string.sub(value, 1, 5) == "Owns_" then
				v7.draw()
			elseif value == "Level" then
				v6.draw()
			elseif value == Skins.PACK_ATTR then
				v8.draw()
			end
		end)

		local v9 = false
		local v10 = 0
		RunService.RenderStepped:Connect(function()
			local now = os.clock()
			local v11

			if instance.Team == nil then
				v11 = instance:GetAttribute("PickingTeam") == true
			else
				v11 = false
			end

			if v11 ~= v4 then
				v4 = v11

				if v11 then
					v3 += 1
					chooseGun()
					v7.draw()
					v8.draw()

					if not v9 then
						v9 = true
						task.spawn(buildRack)
						task.spawn(buildChopper)
					end
				end
			end

			if v11 and v10 <= now then
				local flag = false

				for _, v12 in stands do
					if not (v12.marker and v12.marker:IsDescendantOf(workspace)) then
						flag = true
					end
				end

				if flag then
					v10 = now + 1

					for _, folder in CollectionService:GetTagged("SkyLobby") do
						for _, part in folder:GetDescendants() do
							local kind = part:GetAttribute("Kind")

							if not (part.Name == "Featured" and part:IsA("BasePart") and type(kind) == "string" and stands[kind]) then
								continue
							end

							stands[kind].marker = part
							stands[kind].gui.Adornee = part
							stands[kind].placedAt = nil
						end
					end
				end
			end

			local currentCamera = workspace.CurrentCamera
			local flag = false

			for _, v12 in stands do
				local marker = v12.marker
				local v13

				if v11 then
					if marker == nil or currentCamera == nil then
						v13 = false
					else
						v13 = (currentCamera.CFrame.Position - marker.Position).Magnitude < 400
					end
				else
					v13 = v11
				end

				v12.gui.Enabled = v13 and v12.offer ~= nil

				if not v13 then
					continue
				end

				flag = true
				local cframe = marker.CFrame
				local model = v12.model

				if v12.turns then
					v12.light.CFrame = cframe * CFrame.new(0, 1.5, -2.5)

					if model then
						local v14 = now % 9 / 9 * 2 * 3.141592653589793
						local v15 = math.sin(now / 3.4 * 2 * 3.141592653589793) * 0.22
						model:PivotTo(cframe * CFrame.new(0, v15, 0) * CFrame.Angles(0, v14, 0) * CFrame.Angles(-0.10471975511965978, 0, 0))
					end
				elseif model and v12.placedAt ~= cframe then
					v12.placedAt = cframe
					v12.light.CFrame = cframe * CFrame.new(0, 6, -9)
					model:PivotTo(cframe * CFrame.Angles(0, -2.007128639793479, 0))
				end
			end

			local parent2

			if flag then
				parent2 = workspace
			end

			lobbyFeatured.Parent = parent2
		end)
	end
}