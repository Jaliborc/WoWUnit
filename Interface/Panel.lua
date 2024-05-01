local NUM_VISIBLE_BUTTONS = 16
local COLLAPSE_TEXTURE = 'Interface/Buttons/UI-%sButton-Up'
local COLORS = {
	GRAY_FONT_COLOR,
	GREEN_FONT_COLOR,
	YELLOW_FONT_COLOR,
	RED_FONT_COLOR
}

--[[ Events ]]--

function WoWUnit:OnEvent(event)
	C_Timer.NewTicker(0.1, function()
		self:RunTests(event)
		if self:IsShown() then
			self.Scroll:update()
		end

		local status, count = self.Group.Status(self)
		local color = COLORS[status]
		WoWUnitToggle:SetText(count)
		WoWUnitToggle:SetWidth(WoWUnitToggle:GetTextWidth() + 14)
		WoWUnitToggle:SetBackdropColor(color.r, color.g, color.b)
	end, 5)
end

function WoWUnit:OnShow()
	HybridScrollFrame_CreateButtons(self.Scroll, 'WoWUnitButtonTemplate', 2, -4, 'TOPLEFT', 'TOPLEFT', 0, -3)

	self:SortRegistry()
	self.TitleText:SetText('|Tinterface/addons/wowunit/art/gnomed:16:16|t Unit Tests')
	self.Scroll:update()
end

function WoWUnit:OnClick(entry)
	if entry.children then
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
		sort(group.children)
	end
end

function WoWUnit:ListRegistry()
	local entries = {}
	for _, group in pairs(WoWUnit.children) do
		tinsert(entries, group)

		if not WoWUnit_SV[group.name] then
			for _, test in pairs(group.children) do
				tinsert(entries, test)
			end
		end
	end

	return entries
end


--[[ Update ]]--

function WoWUnit.Scroll:update()
	local self = self or WoWUnit.Scroll
	local off = HybridScrollFrame_GetOffset(self)
	local entries = WoWUnit:ListRegistry()
	local overflow = #entries > NUM_VISIBLE_BUTTONS

	for i, button in ipairs(self.buttons) do
		local entry = entries[i + off]
		if entry then
			local isHeader = entry.children
			local collapseTexture = COLLAPSE_TEXTURE:format(WoWUnit_SV[entry.name] and 'Plus' or 'Minus')
			local color = COLORS[entry:Status()]
			local height = isHeader and 15 or 21

			button.Name:SetText(entry.name)
			button.Name:SetFontObject(isHeader and GameFontNormalLeft or GameFontHighlightSmall)
			button.Name:SetPoint('LEFT', isHeader and button.CollapseButton or button, isHeader and 'RIGHT' or 'LEFT', 10, 0)
			button.Bar:SetStatusBarColor(color.r, color.g, color.b)
			button.CollapseButton:SetNormalTexture(collapseTexture)
			button.CollapseButton:SetShown(isHeader)
			button.Background:SetShown(not isHeader)
			button.Bar.Right:SetHeight(height)
			button.Bar.Left:SetHeight(height)

			if LE_EXPANSION_LEVEL_CURRENT < 2 then
				button.Background:SetTexCoord(0, 0.48, 0, 0.328125)
				button.Bar.Right:SetTexCoord(0, 0.0625, 0.34375, 0.671875)
				button.Bar.Left:SetTexCoord(0.48, 1, 0, 0.328125)
				button.Bar.Right:SetWidth(10)
				button.Bar.Left:SetWidth(92)
			else
				button.Background:SetTexCoord(0, 0.7578125, 0, 0.328125)

				if isHeader then
					button.Bar.Right:SetTexCoord(0.0, 0.15234375, 0.390625, 0.625)
					button.Bar.Left:SetTexCoord(0.765625, 1.0, 0.046875, 0.28125)
				else
					button.Bar.Right:SetTexCoord(0.0, 0.1640625, 0.34375, 0.671875)
					button.Bar.Left:SetTexCoord(0.7578125, 1.0, 0.0, 0.328125)
				end
			end
		end

		button:SetWidth(overflow and 222 or 238)
		button:SetShown(entry)
		button.entry = entry
	end

	HybridScrollFrame_Update(self, #entries * 23 + 3, NUM_VISIBLE_BUTTONS * 20)
	self:SetPoint('BOTTOMRIGHT', overflow and -25 or 0, 7)
end

if BackdropTemplateMixin then
	Mixin(WoWUnitToggle, BackdropTemplateMixin)
end

WoWUnit_SV = WoWUnit_SV or {}
WoWUnit:SetScript('OnEvent', WoWUnit.OnEvent)
WoWUnit:SetScript('OnShow', WoWUnit.OnShow)
WoWUnitToggle:SetBackdrop({
	bgFile = 'Interface/Tooltips/UI-Tooltip-Background',
	edgeFile = 'Interface/Tooltips/UI-Tooltip-Border',
	insets = { left = 4, right = 4, top = 4, bottom = 4 },
	tileSize = 16, edgeSize = 16, tile = true, tileEdge = true,
	backdropColor = TOOLTIP_DEFAULT_BACKGROUND_COLOR,
	backdropBorderColor = TOOLTIP_DEFAULT_COLOR,
})

if AddonCompartmentFrame then
	AddonCompartmentFrame:RegisterAddon {
		text = 'WoWUnit', keepShownOnClick = true, notCheckable = true,
		icon = 'interface/addons/wowunit/art/gnomed',
		func = function() WoWUnit:SetShown(not WoWUnit:IsShown()) end
	}
end