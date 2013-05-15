local Test = {}
WoWTest.UnitTest = Test
Test.__index = Test


--[[ API ]]--

function Test:New(name, func)
	local test = {
		name = name,
		func = func,
		errors = {},
		numOk = 0
	}

	return setmetatable(test, self)
end

function Test:Status()
	local pass = self.numOk > 0 and 1 or 0

	if #self.errors > 0 then
		return 4 - pass
	else
		return 1 + pass
	end
end


--[[ Operators ]]--

function Test:__call()
	local success, message = pcall(self.func)
	if success then
		self.numOk = self.numOk + 1
	else
		tinsert(self.errors, message)
	end

	WoWTest.ClearReplaces()
end

function Test:__lt(other)
	return self.name < other.name
end