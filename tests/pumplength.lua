local Regexs = require("src/model/regex")
require "src/derivatives/brzozovski"
require("src/r2nfa_converter/thompson")

local regex_s = Regexs.Regex:new("(a|b*)")
local nfa = create_thompson_automaton(regex_s)

for ind_from, table_symbols in pairs(nfa.transitions) do
	for symbol, table_labels in pairs(table_symbols) do
		for i, to in pairs(table_labels[""]) do
			local is_final = nfa.finality[to]
			print(ind_from, symbol, to, is_final)
		end
	end
end
--[[
local regex_s = "regex"
local rtree = Regexs.RegexNode:new(regex_s, true)

local i, j
local n = 1
while n >= 1 do
	local prefix = string.sub(regex_s, 1, n) 
	local deriv = brzozovski_derivative_word(prefix, rtree)
	print(prefix, deriv.value)

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
--]]