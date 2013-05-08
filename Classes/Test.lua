local Test = {}
WoWTest.Test = Test
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

function Test:AnySuccess()
	return self.numOk > 0
end

function Test:AnyError()
	return #self.errors > 0
end


--[[ Operators ]]--

function Test:__call(...)
	local success, message = pcall(self.func, ...)
	if success then
		self.numOk = self.numOk + 1
	else
		tinsert(self.errors, message)
	end
end

function Test:__lt(other)
	return self.name < other.name
end