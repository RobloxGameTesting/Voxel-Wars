local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(255, 73, 73)
local vector2 = Vector2.new(1000, 1000)

return function(p)
	local autocomplete = p.Gui:WaitForChild("Autocomplete")
	local scrollBarThickness = autocomplete.ScrollBarThickness

	local v = {
		_autoItem = autocomplete:WaitForChild("TextButton"),
		_title = autocomplete:WaitForChild("Title"),
		_description = autocomplete:WaitForChild("Description"),
		_entry = p.Gui.Frame:WaitForChild("Entry"),
		Items = {},
		SelectedItem = 1,
		Prefix = "",
		LastItem = false,
		Command = nil,
		Arg = nil,
		NumArgs = nil,
		IsPartial = false
	}

	local function updateContainerSize()
		local x = v._title.Field.TextBounds.X
		local x2 = v._title.Field.Type.TextBounds.X
		local offset = autocomplete.Size.X.Offset

		local v2 = autocomplete.Parent.AbsoluteSize.Y - autocomplete.AbsolutePosition.Y - 10
		local y = autocomplete.UIListLayout.AbsoluteContentSize.Y

		local v3 = math.max(x + x2, offset)
		local v4 = math.min(y, v2)
		autocomplete.Size = UDim2.fromOffset(v3, v4)
	end

	function v:_updateContainerPosition(p2: number?)
		local absolutePosition = self._entry.TextBox.AbsolutePosition
		local v2

		if p2 then
			v2 = absolutePosition.X - 10 + p2
		else
			v2 = absolutePosition.X
		end

		local v3 = absolutePosition.Y + 30
		autocomplete.Position = UDim2.fromOffset(v2, v3)
	end

	function v:_setText(p2, p3, value: string?, flag: boolean)
		p2.Visible = value ~= nil
		p3.Text = value or ""

		if flag then
			local textSize = p.Util.GetTextSize(value or "", p3, vector2)
			p3.Size = UDim2.new(0, textSize.X, p2.Size.Y.Scale, p2.Size.Y.Offset)
		end
	end

	function v:_updateInfoDisplay(data)
		local v2 = data.type and `{data.type:sub(1, 1):upper()}{data.type:sub(2)}`
		local v3 = v2 and `: {v2}`
		self:_setText(self._title, self._title.Field, data.name, true)
		self:_setText(self._title.Field.Type, self._title.Field.Type, v3)
		self:_setText(self._description, self._description.Label, data.description)

		local label = self._description.Label
		local textColor = if data.invalid then color2 else color
		label.TextColor3 = textColor
		self._description.Size = UDim2.new(1, 0, 0, 40)

		while not self._description.Label.TextFits do
			self._description.Size = self._description.Size + UDim2.fromOffset(0, 2)

			if self._description.Size.Y.Offset > 500 then
				break
			end
		end

		task.wait()
		updateContainerSize()
		autocomplete.ScrollBarThickness = scrollBarThickness
	end

	function v:Show(items, options)
		local v2 = options or {}

		for _, item in ipairs(self.Items) do
			if item.gui then
				item.gui:Destroy()
			end
		end

		self.SelectedItem = 1
		self.Items = items

		self.Prefix = v2.prefix or ""
		self.LastItem = v2.isLast or false

		self.Command = v2.command
		self.Arg = v2.arg
		self.NumArgs = v2.numArgs
		self.IsPartial = v2.isPartial

		autocomplete.ScrollBarThickness = 0
		local maxValue = 200

		for i, item in ipairs(items) do
			local v3 = item[1]
			local v4 = item[2]
			local clone = self._autoItem:Clone()
			clone.Name = `{v3}{v4}`
			clone.BackgroundTransparency = i == self.SelectedItem and 0.5 or 1

			local v5, v6 = v4:lower():find(v3:lower(), 1, true)

			if not v5 then
				v6 = #v4
				v5 = 1
			end

			local v7 = v4:sub(1, v5 - 1)
			local v8 = v4:sub(v6 + 1)
			clone.Typed.Text = `{(" "):rep(v5 - 1)}{v3}`
			clone.Suggest.Text = `{v7}{(" "):rep(#v3)}{v8}`

			clone.LayoutOrder = i
			clone.Parent = autocomplete

			maxValue = math.max(maxValue, math.max(clone.Typed.TextBounds.X, clone.Suggest.TextBounds.X) + 20)

			item.gui = clone
		end

		local text = self._entry.TextBox.Text
		local splitString = p.Util.SplitString(text)

		if text:sub(#text, #text) == " " and not v2.at then
			splitString[#splitString + 1] = "e"
		end

		table.remove(splitString, #splitString)

		local v3 = (v2.at or #table.concat(splitString, " ") + 1) * 7
		local udim = UDim2.fromOffset(maxValue, autocomplete.UIListLayout.AbsoluteContentSize.Y)
		self:_updateContainerPosition(v3)
		autocomplete.Size = udim
		autocomplete.Visible = true

		if self.Items[1] and self.Items[1].options then
			v2 = self.Items[1].options
		end

		self:_updateInfoDisplay(v2)
	end

	function v.GetSelectedItem(p2)
		if autocomplete.Visible then
			return p2.Items[p2.SelectedItem]
		end

		return nil
	end

	function v.Hide(_)
		autocomplete.Visible = false
	end

	function v.IsVisible(_)
		return autocomplete.Visible
	end

	function v:Select(p2: number)
		if not autocomplete.Visible then
			return
		end

		self.SelectedItem += p2

		if self.SelectedItem > #self.Items then
			self.SelectedItem = 1
		elseif self.SelectedItem < 1 then
			self.SelectedItem = #self.Items
		end

		for i, item in ipairs(self.Items) do
			item.gui.BackgroundTransparency = i == self.SelectedItem and 0.5 or 1
		end

		local v2 = self._title.Size.Y.Offset + self._description.Size.Y.Offset + self.SelectedItem * self._autoItem.Size.Y.Offset - autocomplete.Size.Y.Offset
		autocomplete.CanvasPosition = Vector2.new(0, (math.max(0, v2)))

		local item = self.Items[self.SelectedItem]

		if item and item.options then
			self:_updateInfoDisplay(item.options)
		end
	end

	v._autoItem.Parent = nil
	autocomplete:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateContainerSize)

	return v
end