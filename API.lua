local Events = {}
local Groups = {}
local Replaces = {}


--[[ Registry ]]--

function WoWTest:NewGroup(name, ...)
	local group = Group:New(name)
	tinsert(Groups, group)

	if ... then
		for i = 1, select('#', ...) do
			self:AddToEvent(group, select(i, ...))
		end
	else
		self:AddToEvent(group, 'STARTUP')
	end

	return group
end

function WoWTest:AddToEvent(group, event)
	Events[event] = Events[event] or {}
	tinsert(Events[event], group)
end

function WoWTest:RunTests(event)
	for _, group in ipairs(Events[event]) do
		group()
	end
end


--[[ Mocking ]]--

function WoWTest.Replace(table, key, replace)
	if not replace then
		table, key, replace = _G, table, key
	end
	
	Replaces[table] = Replaces[table] or {}
	Replaces[table][key] = Replaces[table][key] or table[key]

	table[key] = replace
end

function WoWTest.ClearReplaces()
	for table, keys in pairs(Replaces) do
		for key, original in pairs(keys) do
			table[key] = original
		end
	end

	wipe(Replaces)
end


--[[ Assertions ]]--

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
end

function WoWTest.AreEqual(a, b)
	local path, a, b = Difference(a, b)
	if path then 
		local message = "Expected %s, got %s.":format(a, b)
		if path ~= "" then
			message = "Tables differ at %s:|n  ":format(path) .. message
		end

		error(message, 2)
	end
end

function WoWTest.Exists(value)
	if not value then
		error("Expected some value, got %s.":format(value), 2)
	end
end