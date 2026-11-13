local Players = game:GetService("Players")
local LocalizationService = game:GetService("LocalizationService")
local TextChatService = game:GetService("TextChatService")

local v = "OWNER"
task.spawn(function()
	v = LocalizationService:GetTranslatorForPlayerAsync(Players.LocalPlayer):Translate(game, "OWNER")
end)

TextChatService.OnIncomingMessage = function(p)
	local textSource = p.TextSource

	if not textSource or textSource.UserId ~= 7872316101 then
		return nil
	end

	local textChatMessageProperties = Instance.new("TextChatMessageProperties")
	textChatMessageProperties.PrefixText = string.format(
		"<font color=\"%s\">[%s]</font> %s",
		"#FFC620",
		v,
		p.PrefixText
	)
	return textChatMessageProperties
end