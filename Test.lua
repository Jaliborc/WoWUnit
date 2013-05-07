local Test = WoWTest:NewModule('Test')
Test.__index = Test

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