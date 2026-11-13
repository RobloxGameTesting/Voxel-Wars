local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")

local v = { Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.Touch }

local value = Enum.ContextActionPriority.High.Value

local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(255, 73, 73)
local color3 = Color3.fromRGB(255, 223, 93)
local color4 = Color3.fromRGB(255, 153, 153)

local LocalPlayer = Players.LocalPlayer

local function isPositionOutsideGui(position: Vector3, frame): boolean -- 1 equivalent call inferred from this helper
	local absolutePosition = frame.AbsolutePosition
	local v2 = absolutePosition + frame.AbsoluteSize
	return position.X < absolutePosition.X or position.X > v2.X or position.Y < absolutePosition.Y or position.Y > v2.Y
end

local function buildAutoCompleteText(command, arg, p: string)
	local values = { command.Alias }

	for _, argument in command.Arguments do
		local rawSegments = argument.RawSegments

		if argument == arg then
			rawSegments = table.clone(rawSegments)
			rawSegments[#rawSegments] = p
		end

		local formatted = `{argument.Prefix}{table.concat(rawSegments, ",")}`

		if formatted == "" or formatted:find(" ", 1, true) ~= nil then
			formatted = ("%q"):format(formatted)
		end

		table.insert(values, formatted)

		if argument == arg then
			break
		end
	end

	return table.concat(values, " ")
end

local function onKeyReleased(fn) -- 2 equivalent calls inferred from this helper
	local v2 = false

	return function(_, p)
		if p == Enum.UserInputState.Begin then
			v2 = true
		elseif p == Enum.UserInputState.End and v2 then
			v2 = false
			fn()
		else
			v2 = false
		end

		return Enum.ContextActionResult.Pass
	end
end

return function(state, object)
	local frame = state.Gui:WaitForChild("Frame")
	local v2 = {
		_entry = frame:WaitForChild("Entry"),
		_lineTemplate = frame:WaitForChild("Line"),
		_backdrop = state.Gui:WaitForChild("Backdrop"),
		_mouseUnlocker = state.Gui:WaitForChild("MouseUnlocker"),
		_previousChatStates = {},
		_visibleInputConnection = nil,
		_hasLostFocus = false,
		_valid = true,
		_errorText = nil,
		_historyState = nil,
		_pressCount = 0,
		_lastPressTime = 0
	}

	function v2:GetLabelText()
		return self._entry.TextLabel.Text
	end

	function v2:UpdateLabelText()
		local placeName = state._placeName
		self._entry.TextLabel.Text = `{LocalPlayer.Name}{(not placeName or placeName == "") and "" or `@{placeName}`}$`
	end

	function v2:UpdateWindowHeight()
		local uiListLayout = frame.UIListLayout
		local uiPadding = frame.UIPadding
		local v3 = uiListLayout.AbsoluteContentSize.Y + uiPadding.PaddingTop.Offset + uiPadding.PaddingBottom.Offset

		local x = frame.Size.X
		local v4 = math.clamp(v3, 0, 300)

		frame.Size = UDim2.new(x.Scale, x.Offset, 0, v4)
		frame.CanvasPosition = Vector2.new(0, v3)
		object:_updateContainerPosition()
	end

	function v2:_setEntryText(text: string)
		self._entry.TextBox.Text = text

		if self:IsVisible() then
			self._entry.TextBox.CursorPosition = #text + 1
			self:UpdateWindowHeight()
		end
	end

	function v2:GetEntryText()
		return (self._entry.TextBox.Text:gsub("\t", ""))
	end

	function v2:AddLine(p, color5)
		local v3 = tostring(p)
		local v4 = typeof(color5) == "Color3" and { Color = color5 } or color5 or {}

		if v3 == "" then
			self:UpdateWindowHeight()
			return
		end

		local clone = self._lineTemplate:Clone()
		clone.Text = state.Util.EmulateTabstops(v3, 8)
		clone.TextColor3 = v4.Color or clone.TextColor3
		clone.RichText = v4.RichText or false
		clone.Parent = frame
	end

	function v2:_setChatEnabled(flag: boolean)
		if flag then
			for k, previousChatState in self._previousChatStates do
				k.Enabled = previousChatState
			end

			table.clear(self._previousChatStates)
		else
			for _, v3 in {
				TextChatService.ChatWindowConfiguration,
				TextChatService.ChatInputBarConfiguration,
				TextChatService.ChannelTabsConfiguration
			} do
				self._previousChatStates[v3] = v3.Enabled
				v3.Enabled = false
			end
		end
	end

	function v2:UpdateMouseUnlock()
		self._mouseUnlocker.Visible = self:IsVisible() and state._activationUnlocksMouse
	end

	function v2:SetVisible(visible: boolean)
		if frame.Visible == visible then
			return
		end

		frame.Visible = visible
		self:_setChatEnabled(not visible)
		self:_setInputBound(visible)
		self:UpdateMouseUnlock()

		if visible then
			self._entry.TextBox:CaptureFocus()
			self:_setEntryText("")
		else
			object:Hide()
			self._entry.TextBox:ReleaseFocus()
		end

		state.Toggled:Fire(visible)
	end

	function v2:IsVisible()
		return frame.Visible
	end

	function v2:Hide()
		self:SetVisible(false)
	end

	function v2:Show()
		self:SetVisible(true)
	end

	function v2:_setIsValidInput(valid: boolean, errorText: string?)
		local textBox = self._entry.TextBox
		local textColor = if valid then color else color2
		textBox.TextColor3 = textColor
		self._valid = valid
		self._errorText = errorText
	end

	function v2:HideInvalidState()
		self._entry.TextBox.TextColor3 = color
	end

	function v2:_traverseHistory(p: number)
		local history = state.Dispatcher:GetHistory()

		if not self._historyState then
			self._historyState = {
				Position = #history + 1,
				InitialText = self:GetEntryText()
			}
		end

		self._historyState.Position = math.clamp(self._historyState.Position + p, 1, #history + 1)
		local v3

		if self._historyState.Position == #history + 1 then
			v3 = self._historyState.InitialText
		else
			v3 = history[self._historyState.Position]
		end

		self:_setEntryText(v3)
	end

	function v2:_clearHistoryState()
		self._historyState = nil
	end

	function v2:_selectVertical(p: number)
		if object:IsVisible() and not self._historyState then
			object:Select(p)
		else
			self:_traverseHistory(p)
		end
	end

	function v2:_processEntry(p: string)
		local trimString = state.Util.TrimString(p)

		if #trimString == 0 then
			return
		end

		self:AddLine(`{self:GetLabelText()} {trimString}`, color3)
		self:AddLine(state.Dispatcher:EvaluateAndRun(trimString, LocalPlayer, { IsHuman = true }))
	end

	function v2:_loseFocus(flag: boolean, p)
		if self._hasLostFocus then
			return
		end

		local text = self._entry.TextBox.Text
		self:_clearHistoryState()

		if p and p.KeyCode == Enum.KeyCode.Escape then
			self:Hide()
		elseif flag then
			self._hasLostFocus = true

			task.defer(function()
				if self:IsVisible() then
					self._entry.TextBox:CaptureFocus()
				end
			end)

			if self._valid then
				self:_setEntryText("")
				self:_processEntry(text)
			else
				self:AddLine(self._errorText, color4)
			end

			self._hasLostFocus = false
		end
	end

	function v2:_handleActivationKey()
		if not state._enabled then
			return
		end

		local now = os.clock()

		if state._mashToEnable then
			self._pressCount = not (now - self._lastPressTime < 1) and 1 or self._pressCount + 1
			self._lastPressTime = now

			if self._pressCount >= 5 then
				self._pressCount = 0
				state._mashToEnable = false
				self:SetVisible(true)
			end
		else
			self:SetVisible(not self:IsVisible())
		end
	end

	function v2:_handleTabCompletion()
		local selectedItem = object:GetSelectedItem()
		local entryText = self:GetEntryText()

		if not selectedItem or object.LastItem and entryText:match("%s$") then
			self:_setEntryText(entryText)
			return
		end

		local command = object.Command
		local v3

		if command then
			v3 = buildAutoCompleteText(command, object.Arg, selectedItem[2])
		else
			v3 = selectedItem[2]
		end

		local v4 = not command

		if not v4 then
			if object.NumArgs == #command.ArgumentDefinitions then
				v4 = false
			else
				v4 = not object.IsPartial
			end
		end

		if v4 then
			v3 = `{v3} `
		end

		self:_setEntryText(v3)
	end

	function v2:_handlePointerInput(p)
		if state._hideOnLostFocus and table.find(v, p.UserInputType) and isPositionOutsideGui(p.Position, frame) then -- inferred equivalent call
			self:Hide()
		end
	end

	function v2:_handleVisibleInput(object2, flag: boolean)
		local keyCode = object2.KeyCode

		if table.find(state._activationKeys, keyCode) then
			if flag then
				self:Hide()
			end
		elseif keyCode == Enum.KeyCode.Backspace and object2:IsModifierKeyDown(Enum.ModifierKey.Ctrl) then
			self:_setEntryText("")
		elseif keyCode == Enum.KeyCode.Down then
			self:_selectVertical(1)
		elseif keyCode == Enum.KeyCode.Up then
			self:_selectVertical(-1)
		elseif object2.UserInputType == Enum.UserInputType.Keyboard and keyCode ~= Enum.KeyCode.Tab then
			self:_clearHistoryState()
		end
	end

	local function fn()
		v2:_handleActivationKey()
	end

	local v3 = onKeyReleased(fn) -- inferred equivalent call

	local function fn2()
		v2._entry.TextBox:CaptureFocus()
	end

	local v4 = onKeyReleased(fn2) -- inferred equivalent call

	local function clickOutsideAction(_, p, p2)
		if p == Enum.UserInputState.Begin then
			v2:_handlePointerInput(p2)
		end

		return Enum.ContextActionResult.Pass
	end

	function v2:BindActivationKeys()
		ContextActionService:UnbindAction("CmdrActivation")

		if #state._activationKeys == 0 then
			return
		end

		ContextActionService:BindActionAtPriority(
			"CmdrActivation",
			v3,
			false,
			value,
			table.unpack(state._activationKeys)
		)
	end

	function v2:_setInputBound(visible: boolean)
		self._backdrop.Visible = visible

		if visible then
			ContextActionService:BindActionAtPriority("CmdrRefocus", v4, false, value, Enum.KeyCode.Tab)

			ContextActionService:BindActionAtPriority(
				"CmdrClickOutside",
				clickOutsideAction,
				false,
				value,
				table.unpack(v)
			)

			self._visibleInputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
				self:_handleVisibleInput(input, gameProcessed)
			end)
		else
			ContextActionService:UnbindAction("CmdrRefocus")
			ContextActionService:UnbindAction("CmdrClickOutside")

			if self._visibleInputConnection then
				self._visibleInputConnection:Disconnect()
				self._visibleInputConnection = nil
			end
		end
	end

	function v2:_handleArgumentAutoComplete(command, list, list2: string, flag: boolean, flag2: boolean)
		local v5, v6 = command:Validate()
		self:_setIsValidInput(v5, `Validation errors: {v6 or ""}`)

		local argument = command:GetArgument(#list)

		if not argument then
			return
		end

		local v7 = {}
		local textSegmentInProgress = argument.TextSegmentInProgress
		local isPartial = false

		if argument.RawSegmentsAreAutocomplete then
			for k, rawSegment in argument.RawSegments do
				v7[k] = { rawSegment, rawSegment }
			end
		else
			local autocomplete, v8 = argument:GetAutocomplete()
			isPartial = v8 and v8.IsPartial or false

			for k, v9 in autocomplete do
				v7[k] = { textSegmentInProgress, v9 }
			end
		end

		local v8, description

		if #textSegmentInProgress > 0 then
			v8, description = argument:Validate()
		else
			v8 = true
		end

		if not flag2 and v8 then
			self:HideInvalidState()
		end

		local v9 = {
			at = flag2 and #list2 - #textSegmentInProgress + (flag and -1 or 0),
			prefix = #argument.RawSegments ~= 1 and "" or argument.Prefix,
			isLast = #command.Arguments == #command.ArgumentDefinitions and #textSegmentInProgress > 0,
			numArgs = #list,
			command = command,
			arg = argument,
			name = `{argument.Name}{argument.Required and "" or "?"}`,
			type = argument.Type.DisplayName,
			description = 0,
			invalid = 0,
			isPartial = 0
		}

		if v8 then
			description = argument.Object.Description
		end

		v9.description = description
		v9.invalid = not v8
		v9.isPartial = isPartial
		object:Show(v7, v9)
	end

	function v2:_handleCommandAutoComplete(value2: string, p)
		self:_setIsValidInput(true)

		local command = state.Registry:GetCommand(value2)
		local v5 = nil

		if command and not command._isHidden then
			v5 = {
				command.Name,
				command.Name,
				options = { name = command.Name, description = command.Description }
			}

			local v6 = command.Args and command.Args[1]

			if type(v6) == "function" then
				v6 = v6(p)
			end

			if v6 and not v6.Optional and v6.Default == nil then
				self:_setIsValidInput(false, "This command has required arguments.")
				self:HideInvalidState()
			end
		else
			self:_setIsValidInput(
				false,
				`{value2} is not a valid command name. Use the help command to see all available commands.`
			)
		end

		local lower = value2:lower()
		local v6 = { v5 }

		for _, v7 in state.Registry:GetCommandNames(true) do
			if not (v7:lower():sub(1, #lower) == lower and (not v5 or v5[1] ~= v7)) then
				continue
			end

			local command2 = state.Registry:GetCommand(v7)
			table.insert(v6, {
				value2,
				v7,
				options = { name = command2.Name, description = command2.Description }
			})
		end

		object:Show(v6)
	end

	function v2:_onTextChanged(value2: string)
		local evaluate = state.Dispatcher:Evaluate(value2, LocalPlayer, true)
		local splitString = state.Util.SplitString(value2)
		local v5 = table.remove(splitString, 1)

		local v6 = value2:match("%s$") ~= nil
		local v7

		if evaluate then
			splitString = state.Util.MashExcessArguments(splitString, #evaluate.Object.Args)
			v7 = #splitString == #evaluate.Object.Args
		else
			v7 = false
		end

		local v8 = v5 and #splitString > 0

		if v6 and not v7 then
			table.insert(splitString, "")
			v8 = true
		end

		if evaluate and v8 then
			self:_handleArgumentAutoComplete(evaluate, splitString, value2, v6, v7)
			return
		end

		if v5 and #splitString == 0 then
			self:_handleCommandAutoComplete(v5, evaluate)
			return
		end

		self:_setIsValidInput(false, "Use the help command to see all available commands.")
		object:Hide()
	end

	local textBox = v2._entry.TextBox

	textBox.FocusLost:Connect(function(flag: boolean, p)
		v2:_loseFocus(flag, p)
	end)

	textBox:GetPropertyChangedSignal("Text"):Connect(function()
		local text = textBox.Text
		frame.CanvasPosition = Vector2.new(0, frame.AbsoluteCanvasSize.Y)

		if text:find("\t", 1, true) then
			v2:_handleTabCompletion()
		elseif text:find("[\r\n]") then
			v2:_setEntryText((text:gsub("[\r\n]", "")))
		else
			v2:_onTextChanged(text)
		end
	end)

	v2._backdrop.InputBegan:Connect(function(input)
		v2:_handlePointerInput(input)
	end)

	GuiService.MenuOpened:Connect(function()
		v2:Hide()
	end)

	frame.ChildAdded:Connect(function()
		task.defer(v2.UpdateWindowHeight, v2)
	end)

	v2._lineTemplate.Parent = script
	v2:BindActivationKeys()

	return v2
end