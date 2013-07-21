local CollapseTexture = 'Interface/Buttons/UI-%sButton-Up'
local Colors = {
	GRAY_FONT_COLOR,
	GREEN_FONT_COLOR,
	YELLOW_FONT_COLOR,
	RED_FONT_COLOR
}

--[[ Events ]]--

function WoWUnit:OnEvent(event)
	self:RunTests(event)

	local status, count = Group.Status(self)
	local color = Colors[status]
	WoWUnitToggle:SetBackdropColor(color.r, color.g, color.b)
	WoWUnitToggle:SetText(count)
end

function WoWUnit:OnShow()
	HybridScrollFrame_CreateButtons(self.Scroll, 'WoWUnitButtonTemplate', 2, -4, 'TOPLEFT', 'TOPLEFT', 0, -TOKEN_BUTTON_OFFSET)

	self:SortRegistry()
	self.TitleText:SetText('Unit Tests')
	self.Scroll:update()
end

function WoWUnit:OnClick(entry)
	if entry.tests then
		WoWUnit_SV[entry.name] = not WoWUnit_SV[entry.name] or nil
		self.Scroll:update()
	elseif #entry.errors > 0 then
		local log = entry.log or CreateFrame('Frame', 'WoWUnit' .. entry.name .. 'Log', UIParent, 'WoWUnitLogTemplate')
		log.Content:SetText(entry.errors[1])
		log.TitleText:SetText(entry.name)
		log:Show()

		entry.log = log
	end
end


--[[ Registry ]]--

function WoWUnit:SortRegistry()
	sort(self.children)

	for _, group in ipairs(self.children) do
		sort(group.tests)
	end
end

function WoWUnit:ListRegistry()
	local entries = {}
	for _, group in pairs(WoWUnit.children) do
		tinsert(entries, group)

		if not WoWUnit_SV[group.name] then
			for _, test in pairs(group.tests) do
				tinsert(entries, test)
			end
		end
	end

	return entries
end


--[[ Update ]]--

function WoWUnit.Scroll:update()
	local self = self or WoWUnit.Scroll
	local entries = WoWUnit:ListRegistry()
	local off = HybridScrollFrame_GetOffset(self)
	local overflow = #entries > #self.buttons

	for i, button in ipairs(self.buttons) do
		local entry = entries[i + off]
		if entry then
			ReputationFrame_SetRowType(button, not entry.tests, entry.tests, true)

			local collapseTexture = CollapseTexture:format(WoWUnit_SV[entry.name] and 'Plus' or 'Minus')
			local color = Colors[entry:Status()]
			local name = button:GetName()

			_G[name .. 'FactionName']:SetText(entry.name)
			_G[name .. 'ReputationBarFactionStanding']:Hide()
			_G[name .. 'ReputationBar']:SetStatusBarColor(color.r, color.g, color.b)
			_G[name .. 'ExpandOrCollapseButton']:SetNormalTexture(collapseTexture)
			_G[name .. 'ExpandOrCollapseButton']:SetScript('OnClick', function() WoWUnit:OnClick(entry) end)

			button:SetSize(218, 20)
			button.LFGBonusRepButton:Hide()
		end

		button:SetShown(entry)
		button.entry = entry
	end

	HybridScrollFrame_Update(self, #entries * 20 + 2, #self.buttons * 18)
	self:SetPoint('BOTTOMRIGHT', overflow and -25 or 0, 7)
end

WoWUnit:SetScript('OnEvent', WoWUnit.OnEvent)
WoWUnit:SetScript('OnShow', WoWUnit.OnShow)
WoWUnit_SV = WoWUnit_SV or {}