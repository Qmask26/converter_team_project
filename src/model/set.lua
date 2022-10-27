local class = require("src/model/middleclass")


-- класс "множество"
local Set = class('Set')

function Set:initialize(list)
    self.items = {}
	self.size = 0

	if type(list) == 'table' then
		for _, value in ipairs(list) do
			self.items[value] = true
			self.size = self.size + 1
		end
	end
end

function Set:add(value)
	if not self.items[value] then
		self.items[value] = true
		self.size = self.size + 1
	end
end

function Set:has(value)
	return self.items[value] == true
end

function Set:foreach(func)
	for key in pairs(self.items) do
		func(key)
    end
end

function Set:union(other_set)
	for key in pairs(other_set.items) do
		self:add(key)
	end
end

function Set:toarray()
	arr = {}
	for v in pairs(self.items) do
		table.insert(arr, v)
	end
	return arr
end

function Set:str()
	res = ""
	for key in pairs(self.items) do
		res = res .. tostring(key) .. " "
	end
	return string.sub(res, 0, -2)
end

return Set