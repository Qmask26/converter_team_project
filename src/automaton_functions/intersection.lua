local Automaton = require("src/model/automaton")
require("src/utils/common")

function dekart_proizv(a1, a2)
	local res = {}
	for _, i in pairs(a1) do
		for _, j in pairs(a2) do
			table.insert(res, {i, j})
		end
	end
	return res
end

function get_states_list(num_states)
	local res = {}
	for i = 1, num_states, 1 do
        table.insert(res, i)
    end
    return res
end

function get_finality_states(finality)
	local res = {}
	for i, is_final in pairs(finality) do
		if is_final then table.insert(res, i) end
    end
    return res
end

function get_final_states_indexes(states, final_states)
	res = {}
	for i, arr in pairs(final_states) do
		for j, state_arr in pairs(states) do
			if arr[1] == state_arr[1] and arr[2] == state_arr[2] then 
				table.insert(res, j) 
				break
			end
		end
	end
	return res
end

function get_state_index(states, state)
	local state_arr
	for i, state_arr in pairs(states) do
		if (state[1] == state_arr[1]) and (state[2] == state_arr[2]) then 
			return i
		end
	end
end

function intersect_dfa(dfa1, dfa2, debug)
	local new_states = dekart_proizv(get_states_list(dfa1.states), get_states_list(dfa2.states))
	local new_final_states = dekart_proizv(
		get_finality_states(dfa1.finality), 
		get_finality_states(dfa2.finality)
	)
	local alph1 = dfa1:getAlphabet()
	local alph2 = dfa2:getAlphabet()
	alph1:union(alph2)

	local alph = alph1
	local states_number = #new_states
	local final_states_indexes = get_final_states_indexes(new_states, new_final_states)

	local transitions = {}
	for i, state in pairs(new_states) do
		for symbol in pairs(alph.items) do
			local s1 = dfa1:transit(state[1], symbol, "")
			local s2 = dfa2:transit(state[2], symbol, "")
			local state_to = {s1, s2}
			local state_to_index = get_state_index(new_states, state_to)
			table.insert(transitions, {
				from = i, symbol = symbol, to = state_to_index, label = ""
			})
		end
	end
	local result = Automaton.Automaton:new(states_number, final_states_indexes, transitions, true, {1})
	if (debug) then 
		print("Intersection:")
		print(result:toString())
	end
	return result
end

return intersect_dfa