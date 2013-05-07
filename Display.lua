local Display = WoWTest.Display
local Entries = {}

function Display:Startup()
	HybridScrollFrame_CreateButtons(self, 'WoWTestButtonTemplate', 0, 0, 'TOPLEFT', 'TOPLEFT', 0, -TOKEN_BUTTON_OFFSET)
	self:SetScript('OnShow', self.UpdateEntries)
end

function Display:UpdateEntries()
	wipe(Entries)

	for name, group in Addon:IterateGroups() do
		tinsert(Entries, group)
	end
end

function Display:update()
	local off = HybridScrollFrame_GetOffset(self) + 1
	local i = off

	for _, group in Addon:IterateGroups() do
		self:ShowButton(group.name, true)

		for method in pairs(group) do
			self:ShowButton(method)
		end
	end

	local count = i - off
	local overflow = count > #self.buttons

	for i = 0, i do
		self.buttons[i]:SetWidth(overflow and 240 or 258)
	end

	for i = i, #self.buttons do
		self.buttons[i]:Hide()
	end

	HybridScrollFrame_Update(self, count * 20 + 2, #self.buttons * 18)
	self:SetPoint('BOTTOMRIGHT', overflow and -25 or 0, 7)
end

function Display:AddButton(name, isHeader)
	local button = self.buttons[self.i]
	ReputationFrame_SetRowType(button, not isHeader, isHeader, true)

	button:SetWidth(self.overflow and 240 or 258)
	button.Bar:SetStatusBarColor(.1, 1, .1)
	button.Text:SetText(name)
	button.Bar.Text:Hide()
	button:Show()

	self.i = self.i + 1
end