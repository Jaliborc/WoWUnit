local Display = WoWTest.Display

--[[ Startup ]]--

function Display:Startup()
	HybridScrollFrame_CreateButtons(self, 'WoWTestButtonTemplate', 0, 0, 'TOPLEFT', 'TOPLEFT', 0, -TOKEN_BUTTON_OFFSET)
	sort(WoWTest.groups)

	for _, group in ipairs(WoWTest.groups) do
		sort(group.tests)
	end

	self.entries = {}

	for _, group in pairs(WoWTest.groups) do
		tinsert(self.entries, group)

		for _, test in pairs(group.tests) do
			tinsert(self.entries, test)
		end
	end
end


--[[ Render ]]--

function Display:update()
	local self = self or Display
	local i = HybridScrollFrame_GetOffset(self)
	local overflow = #self.entries > #self.buttons

	for i, button in ipairs(self.buttons) do
		local entry = self.entries[i + off]
		if entry then
			ReputationFrame_SetRowType(button, not entry.tests, entry.tests, true)

			local color = self:GetColor(entry)
			button.Bar:SetStatusBarColor(color.r, color.g, color.b)
			button:SetWidth(overflow and 240 or 258)
			button.Text:SetText(entry.name)
			button.Bar.Text:Hide()
		end

		button:SetShown(entry)
	end

	HybridScrollFrame_Update(self, #self.entries * 20 + 2, #self.buttons * 18)
	self:SetPoint('BOTTOMRIGHT', overflow and -25 or 0, 7)
end

function Display:GetColor(entry)
	if entry:AnyError() then
		return entry:AnySuccess() and LIGHTYELLOW_FONT_COLOR or RED_FONT_COLOR
	end

	return entry:AnySuccess() and GREEN_FONT_COLOR or GRAY_FONT_COLOR
end

Display:SetScript('OnShow', Display.Startup)