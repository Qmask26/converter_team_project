local Set = require("src/model/set")
require "src/utils/common"

function printv(v)
	print(v)
end

print("Test Set data structure")
local s = Set:new({})
assert(s.size == 0)
local s = Set:new({''})
assert(s.size == 1)

local s1 = Set:new({1,2,3})
print('s1')
print(s1:str())
local s2 = Set:new({2,4,6})
print('s2')
print(s2:str())
print('s1 union s2')
s1:union(s2)
print(s1:str())

local s1 = Set:new({10,1,2,4,3})
print(table_tostring_as_array(s1:toarray()))