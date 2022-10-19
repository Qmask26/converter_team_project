local Regexs = require("src/model/regex")
require "src/derivatives/brzozovski"


function check_if_infix_pumps()
	print()
end

local regex_s = "regex"
local rtree = Regexs.RegexNode:new(regex_s, true)

local i, j
local n = 1
while n >= 1 do
	local prefix = string.sub(regex_s, 1, n) 
	local deriv = 1

	for i = 1, #prefix do
		for j = i, #prefix do
			local infix = string.sub(prefix, i, j) 
			--print(infix)
		end
	end

	n = n + 1
	if n > #regex_s then
		--print("Max n reached")
		break
	end
end