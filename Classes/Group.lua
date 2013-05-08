local Group = {}
WoWTest.Group = Group
Group.__index = Group


--[[ API ]]--

function Group:New(name)
	return setmetatable({name = name, tests = {}}, self)
end

function Group:AnySuccess()
	for _, test in pairs(self.tests) do
		if test:AnySuccess() then
			return true
		end
	end
end

function Group:AnyError()
	for _, test in pairs(self.tests) do
		if test:AnyError() then
			return true
		end
	end
end


--[[ Operators ]]--

function Group:__call()
	for _, test in pairs(self.tests) do
		test()
	end
end

function Group:__newindex(key, value)
	if type(value) == 'function' then
		tinsert(self.tests, Test:New(key, value))
	end
end

function Group:__lt(other)
	return self.name < other.name
end