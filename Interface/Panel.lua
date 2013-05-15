local CollapseTexture = 'Interface/Buttons/UI-%sButton-Up'
local Colors = {
	GRAY_FONT_COLOR,
	GREEN_FONT_COLOR,
	YELLOW_FONT_COLOR,
	RED_FONT_COLOR
}

--[[ Events ]]--

function WoWTest:OnEvent(event)
	self:RunTests(event)

	local count, status = 0, 0
	for _, group in pairs(self.groups) do
		local new = group:Status()
		if new > status then
			status = new
			count = 1
		elseif new == status then
			count = count + 1
		end
	end

	local color = Colors[status]
	WoWTestToggle:SetBackdropColor(color.r, color.g, color.b)
	WoWTestToggle:SetText(count)
end

function WoWTest:OnShow()
	HybridScrollFrame_CreateButtons(self.Scroll, 'WoWTestButtonTemplate', 2, -4, 'TOPLEFT', 'TOPLEFT', 0, -TOKEN_BUTTON_OFFSET)

	self:SortRegistry()
	self.TitleText:SetText('Unit Tests')
	self.Scroll:update()
end

function WoWTest:OnClick(entry)
	if entry.tests then
		WoWTest_SV[entry.name] = not WoWTest_SV[entry.name] or nil
		self.Scroll:update()
	elseif #entry.errors > 0 then
		local log = entry.log or CreateFrame('Frame', 'WoWTest' .. entry.name .. 'Log', UIParent, 'WoWTestLogTemplate')
		log.Content:SetText(entry.errors[1])
		log.TitleText:SetText(entry.name)
		log:Show()

		entry.log = log
	end
end


--[[ Registry ]]--

function WoWTest:SortRegistry()
	sort(self.groups)

	for _, group in ipairs(self.groups) do
		sort(group.tests)
	end
end

function WoWTest:ListRegistry()
	local entries = {}
	for _, group in pairs(WoWTest.groups) do
		tinsert(entries, group)

		if not WoWTest_SV[group.name] then
			for _, test in pairs(group.tests) do
				tinsert(entries, test)
			end
		end
	end

	return entries
end


--[[ Update ]]--

function WoWTest.Scroll:update()
	local self = self or WoWTest.Scroll
	local entries = WoWTest:ListRegistry()
	local off = HybridScrollFrame_GetOffset(self)
	local overflow = #entries > #self.buttons

	for i, button in ipairs(self.buttons) do
		local entry = entries[i + off]
		if entry then
			ReputationFrame_SetRowType(button, not entry.tests, entry.tests, true)

			local collapseTexture = CollapseTexture:format(WoWTest_SV[entry.name] and 'Plus' or 'Minus')
			local color = Colors[entry:Status()]
			local name = button:GetName()

			_G[name .. 'FactionName']:SetText(entry.name)
			_G[name .. 'ReputationBarFactionStanding']:Hide()
			_G[name .. 'ReputationBar']:SetStatusBarColor(color.r, color.g, color.b)
			_G[name .. 'ExpandOrCollapseButton']:SetNormalTexture(collapseTexture)
			_G[name .. 'ExpandOrCollapseButton']:SetScript('OnClick', function() WoWTest:OnClick(entry) end)

			button:SetSize(218, 20)
			button.LFGBonusRepButton:Hide()
		end

		button:SetShown(entry)
		button.entry = entry
	end

	HybridScrollFrame_Update(self, #entries * 20 + 2, #self.buttons * 18)
	self:SetPoint('BOTTOMRIGHT', overflow and -25 or 0, 7)
end

WoWTest:SetScript('OnEvent', WoWTest.OnEvent)
WoWTest:SetScript('OnShow', WoWTest.OnShow)
WoWTest_SV = WoWTest_SV or {}