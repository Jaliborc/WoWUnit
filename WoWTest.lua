local Groups, Events = {}, {}
local Replaces = {}
local NIL = {}


--[[ Registry ]]--

function WoWTest:NewGroup(name, ...)
	local group = self.Group:New(name)
	tinsert(Groups, group)

	if ... then
		for i = 1, select('#', ...) do
			self:AddToEvent(group, select(i, ...))
		end
	else
		self:AddToEvent(group, 'PLAYER_LOGIN')
	end

	return group
end

function WoWTest:AddToEvent(group, event)
	self:RegisterEvent(event)
	Events[event] = Events[event] or {}
	tinsert(Events[event], group)
end

function WoWTest:RunTests(event)
	for _, group in ipairs(Events[event]) do
		group()
	end
end


--[[ Mocking ]]--

local function Store(value)
	return value == nil and NIL or value
end

local function Extract(value)
	if value ~= NIL then
		return value
	end
end

function WoWTest.Replace(table, key, replace)
	if not replace then
		table, key, replace = _G, table, key
	end
	
	Replaces[table] = Replaces[table] or {}
	Replaces[table][key] = Replaces[table][key] or Store(table[key])

	table[key] = replace
end

function WoWTest.ClearReplaces()
	for table, keys in pairs(Replaces) do
		for key, original in pairs(keys) do
			table[key] = Extract(original)
		end
	end

	wipe(Replaces)
end


--[[ Assertions ]]--

local function Raise(message)
	error('|n|n' .. HIGHLIGHT_FONT_COLOR_CODE .. message .. FONT_COLOR_CODE_CLOSE, 3)
end

local function IsTable(value)
	return type(value) == 'table'
end

local function Difference(a, b)
	if IsTable(a) and IsTable(b) then
		for key, value in pairs(a) do
			local path, a, b = Difference(value, b[key])
			if path then
				return "." .. key .. path, a, b
			end
		end
		
	elseif a ~= b then
		return "", a, b
	end
end

function WoWTest.AreEqual(a, b)
	local path, a, b = Difference(a, b)
	if path then 
		local message = format('Expected %s|nGot %s', tostring(a), tostring(b))
		if path ~= "" then
			message = format('Tables differ at "%s"|n', path) .. message
		end

		Raise(message)
	end
end

function WoWTest.IsTrue(value)
	if not value then
		Raise(format('Expected some value, got %s', tostring(value)))
	end
end

function WoWTest.IsFalse(value)
	if value then
		Raise(format('Expected no value, got %s', tostring(value)))
	end
end


WoWTest.__index = getmetatable(WoWTest).__index
WoWTest.__call = WoWTest.NewGroup
WoWTest.Exists = WoWTest.IsTrue
WoWTest.groups = Groups
setmetatable(WoWTest, WoWTest)