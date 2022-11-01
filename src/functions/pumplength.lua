local Regexs = require("src/model/regex")
local Set = require("src/model/set")
require "src/derivatives/brzozovski"
require "src/r2nfa_converter/thompson"
require "src/automaton_functions/determinization"
require "src/automaton_functions/minimization"
require "src/predicates/predicates"
require "src/utils/common"
require "src/automaton_functions/intersection"


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

function pumplength(rtree, max_n)
	if not max_n then max_n = 100 end

	local nfa = create_thompson_automaton(rtree)
	local dfa_trap = minimization(nfa)
	local alphabet = dfa_trap:getAlphabet()
	dfa_trap:addTrap(alphabet)
	local dfa = minimization(dfa_trap) -- remove trap :)

	local i, j
	local n = 1
	local pumped_prefixes = Set:new({})
	local states_to_process = {{dfa.start_states_raw[1], ''}}
	while n <= max_n do
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
					if dfa:isStateFinal(to) then
						table.insert(prefixes_to_process, new_prefix)
					end
					table.insert(new_states_to_process, {to, new_prefix})
				end
			end
		end

		states_to_process = new_states_to_process
		--print(table_tostring(prefixes_to_process))

		local all_prefixes_pumps = true
		if #prefixes_to_process == 0 then all_prefixes_pumps = false end
		
		for _, prefix in pairs(prefixes_to_process) do
			local deriv = brzozovski_derivative_word(prefix, rtree.root)
			--print(prefix, deriv.value)

			local is_prefix_pumps = false

			local prefix_len = #prefix
			for i = 1, prefix_len do
				for j = i, prefix_len do
					local w1 = string.sub(prefix, 1, i-1) 
					local w2 = string.sub(prefix, i, j) 
					local w3 = string.sub(prefix, j+1, prefix_len)
					-- get automaton and subset
					local regex_to_pump = w1.."("..w2..")*"..w3..deriv.value	
					local regex_to_pump = Regexs.Regex:new(regex_to_pump)
					-- faster than SubsetRegex(regex_to_pump, rtree)
					local nfa_to_pump = create_thompson_automaton(regex_to_pump)
					local dfa_to_pump = Det(nfa_to_pump)
					dfa_to_pump:addTrap(alphabet)
					local intersection = intersect_dfa(dfa_trap, dfa_to_pump)
					if EquivNFA(dfa_to_pump, intersection) then
						is_prefix_pumps = true
						break
					end
				end
				if is_prefix_pumps then break end
			end

			if is_prefix_pumps then
				pumped_prefixes:add(prefix)
			else
				all_prefixes_pumps = false
			end
		end
		if all_prefixes_pumps then
			--print("FOUND N:", n)
			break
		end
		n = n + 1
	end

	if n == max_n + 1 then return 0 end

	return n
end