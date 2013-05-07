local Events = {}
local Groups = {}


--[[ Startup ]]--

function WoWTest:Startup()
	self:SetScript('OnEvent', self.RunTests)
	self.TitleText:SetText('Unit Tests')
	self.Display:Startup()
end


--[[ API ]]--

function WoWTest:NewGroup(name, event)
	Events[event] = Events[event] or {}
	self:RegisterEvent(event)

	local group = Group:New()
	tinsert(Events[event], group)
	tinsert(Groups, group)

	return group
end

function WoWTest:RunTests(event)
	for _, group in ipairs(Events[event]) do
		group()
	end

	self.Display:update()
end