require("src/utils/common")
require("src/automaton_functions/is_dfa")
require"src/automaton_functions/determinization"


local class = require("src/model/middleclass")
local Automaton_module = require("src/model/automaton")
local Automaton = Automaton_module.Automaton
local Transition = Automaton_module.Transition



local function find(tbl, elem)
    if tbl == nil or tbl[""] == nil then
        return true
    end
    for i, x in pairs(tbl[""]) do
        if x == elem then
            return true
        end
    end
    return false
end

function rmeps(nfa)
    local visited = {}
    local closure_transitions = {}
    for i, t in pairs(nfa.transitions_raw) do
        local u = t.from
        if visited[u] == nil then
            visited[u] = true
            local q0 = closure({u}, nfa)
            if table.length(q0) > 1 then
                for i = 1, #q0, 1 do
                    for j = i + 1, #q0, 1 do
                        if not find(nfa.transitions[q0[i]]["_epsilon_"], q0[j]) then
                            table.insert(closure_transitions, {q0[i], q0[j]})
                        end
                    end
                    visited[q0[i]] = true
                end
            end
        end
    end
    nfa_dest = Automaton:new(nfa.states, nfa.final_states_raw, nfa.transitions_raw, nfa.isDFA, nfa.start_states_raw)
    for i, t in pairs(closure_transitions) do
        nfa_dest:addTransition(t[1], t[2], "_epsilon_", "")
    end

    local new_final_states = {}
    for i, t in pairs(nfa_dest.transitions_raw) do
        local next_state = nfa_dest.transitions[t.to]['_epsilon_']
        if next_state ~= nil then
            for j, after_next in pairs(next_state['']) do
                if nfa_dest:isStateFinal(after_next) then
                    table.insert(new_final_states, t.to)
                end
            end
        end
    end


    for i, t in pairs(new_final_states) do
        print(t)
    end
    return nfa
end

return rmeps