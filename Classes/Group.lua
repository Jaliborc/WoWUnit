local Group = {}
WoWTest.Group = Group
Group.__index = Group


--[[ API ]]--

function Group:New(name)
	return setmetatable({name = name, tests = {}}, self)
end

function Group:Status()
	local status = 0
	for _, test in pairs(self.tests) do
		status = max(test:Status(), status)
	end

	return status
end


--[[ Operators ]]--

function Group:__call()
	for _, test in pairs(self.tests) do
		test()
	end
end

function Group:__newindex(key, value)
	if type(value) == 'function' then
		tinsert(self.tests, WoWTest.UnitTest:New(key, value))
	end
end

function Group:__lt(other)
	return self.name < other.name
end