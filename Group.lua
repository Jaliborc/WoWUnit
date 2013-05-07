local Group = WoWTest:NewModule('Group')

function Group:New(name)
	return setmetatable({name = name, tests = {}}, self)
end

function Group:__newindex(key, value)
	if type(value) == 'function' then
		self.tests[key] = Test:New(value)
	end
end

function Group:__call()
	for name, test in pairs(self.tests) do
		test()
	end
end