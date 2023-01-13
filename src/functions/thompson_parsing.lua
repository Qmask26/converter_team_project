local Automaton = require("src/model/automaton")
local Regexs = require("src/model/regex") 

local function getStates(nfa, Q, from, symbol)
    local states = nfa.transitions[from][symbol]['']
    local eps_states = {}
    if nfa.transitions[from]["_epsilon_"] ~= nil then
        eps_states = nfa.transitions[from]["_epsilon_"]['']
    end
    for i = 1, #states, 1 do
        table.insert(Q, states[i])
    end
    for i = 1, #eps_states, 1 do
        getStates(nfa, Q, eps_states[i], symbol)
    end
end
function thompson_parsing(nfa , regex)
    local next_states
    local cur_states = {1}
    for i = 1, #regex, 1 do
        next_states = {}
        local cur_symbol = string.sub(regex, i, i)
        while #cur_states ~= 0 do
            local state = table.remove(cur_states, 1)
            local next = {}
            getStates(nfa, next, state, cur_symbol)
            for j = 1, #next, 1 do
                io.write(next[j], ' ')
            end
            print()
        end
        for j = 1, #next_states, 1 do
            table.insert(cur_states, next_states[j])
        end
    end
end