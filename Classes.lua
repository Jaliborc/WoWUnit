local Group, Test = {}, {}


--[[ Group ]]--

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


--[[ Test ]]--

function Test:New(func)
	local test = {
		func = func,
		errors = {},
		numOk = 0
	}

	return setmetatable(test, self)
end

function Test:Intermittent()
	return #self.errors > 0 and self.numOk > 0
end

function Test:NumRuns()
	return #self.errors + self.numOk
end

function Test__call(...)
	local success, message = pcall(self.func, ...)
	if success then
		self.numOk = self.numOk + 1
	else
		tinsert(self.errors, message)
	end
end

Test.__index = Test
WoWTest.Group = Group