local Test = {}
WoWUnit.Test = Test
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
	local pass = self.numOk > 0 and self.enabled and 1 or 0

	if #self.errors > 0 and self.enabled then
		return 4 - pass, 1
	else
		return 1 + pass, 1
	end
end


--[[ Operators ]]--

function Test:__call()
	local success, message = pcall(self.func)
	if success then
		self.numOk = self.numOk + 1
		self.enabled = 1
	else
		tinsert(self.errors, 1, message)
		self.enabled = WoWUnit.Enabled()
	end

	WoWUnit.ClearReplaces()
	WoWUnit.Enable()
end

function Test:__lt(other)
	return self.name < other.name
end