local Set = require("src/model/set")

function printv(v)
	print(v)
end

print("Test Set data structure")
local s1 = Set:new({1,2,3})
print('s1')
s1:foreach(printv)
local s2 = Set:new({2,4,6})
print('s2')
s2:foreach(printv)
print('s1 union s2')
s1:union(s2)
s1:foreach(printv)