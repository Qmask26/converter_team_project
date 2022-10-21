local Regexs = require("src/model/regex")
require "src/derivatives/brzozovski"
require "src/r2nfa_converter/thompson"
require "src/automaton_functions/determinization"

function table_to_str(table)
	local k, v
	local s = "{"
	for k, v in pairs(table) do
		s = s .. tostring(k) .. ": " .. tostring(v) .. ", "
	end
	s = string.sub(s, 0, #s-2) .. "}"
	return s
end

local regex_s = Regexs.Regex:new("(a|b*)")
local nfa = create_thompson_automaton(regex_s)
local dfa = Det(nfa)

print(table_to_str(dfa.finality))
for ind_from, table_symbols in pairs(dfa.transitions) do
	for symbol, table_labels in pairs(table_symbols) do
		local to = table_labels[""]
		local is_final = dfa.finality[to]
		print(ind_from, symbol, to, is_final)
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