local Regexs = require("src/model/regex")
local Set = require("src/model/set")
require "src/derivatives/brzozovski"
require "src/r2nfa_converter/thompson"
require "src/automaton_functions/determinization"
require "src/utils/common"


function string_startswith(s, prefix)
	return s:find('^' .. prefix) ~= nil
end

function prefix_in_set(prefix, seen_prefixes) 
	for item in pairs(seen_prefixes.items) do
		if string_startswith(prefix, item) then
			return true
		end
	end
	return false
end

local rtree = Regexs.Regex:new("(a|ba)*")
local nfa = create_thompson_automaton(rtree)
local dfa = Det(nfa)

print(nfa:tostring())

local i, j
local n = 1
local pumped_prefixes = Set:new({})
local states_to_process = {{1, ''}}
while n <= 4 do
	--get prefixes
	local prefixes_to_process = {}
	local new_states_to_process = {}
	local c
	for _, state_prefix_table in pairs(states_to_process) do
		local state = state_prefix_table[1]
		local prefix = state_prefix_table[2]
		for symbol, labels_table in pairs(dfa.transitions[state]) do
			local to = labels_table['']
			local new_prefix = prefix .. symbol
			if #new_prefix>0 and not prefix_in_set(new_prefix, pumped_prefixes) then
				--pumped_prefixes:add(new_prefix)
				if dfa:isStateFinal(to) then
					table.insert(prefixes_to_process, new_prefix)
				end
				table.insert(new_states_to_process, {to, new_prefix})
			end
		end
	end
	states_to_process = new_states_to_process
	print(table_tostring(prefixes_to_process))
	n = n + 1
	--[[
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
	]]--
end