local Group = {}
WoWUnit.Group = Group
Group.__index = Group


--[[ API ]]--

function Group:New(name)
	return setmetatable({name = name, children = {}}, self)
end

function Group:Status()
	local status, count = 1, 0

	for _, test in pairs(self.children) do
		local s, c = test:Status()
		if s > status then
			status, count = s, c
		elseif s == status then
			count = count + c
		end
	end

	return status, count
end


--[[ Operators ]]--

function Group:__call()
	for _, test in pairs(self.children) do
		test()
	end
end

function Group:__newindex(key, value)
	if type(value) == 'function' then
		tinsert(self.children, WoWUnit.Test:New(key, value))
	end
end

function Group:__lt(other)
	return self.name < other.name
end