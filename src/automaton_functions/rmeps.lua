require("src/utils/common")
require("src/automaton_functions/is_dfa")
require("src/automaton_functions/determinization")



local class = require("src/model/middleclass")
local Automaton_module = require("src/model/automaton")
local Automaton = Automaton_module.Automaton
local Transition = Automaton_module.Transition

local function dfs(nfa, u, transitions, visited, final_states)
    for i = 1, #visited, 1 do
        if visited[i] == u then return end
    end
    table.insert(visited, u)
    if nfa_dest:isStateFinal(u) then
        table.insert(final_states, u)
        return
    end

    for symbol, next_state in pairs(nfa_dest.transitions[u]) do
        for _, v in pairs(next_state['']) do
            table.insert(transitions, Transition(u, v, symbol))
            dfs(nfa, v, transitions, visited, final_states)
        end
    end
end

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

    local new_final_states_i = {}
    for t = 1, nfa_dest.states, 1 do
        local next_state = nfa_dest.transitions[t]['_epsilon_']
        if next_state ~= nil then
            for j, after_next in pairs(next_state['']) do
                if not nfa_dest:isStateFinal(t) and nfa_dest:isStateFinal(after_next) and new_final_states_i[t] == nil then
                    new_final_states_i[t] = true
                end
            end
        end
    end

    local new_final_states = {}
    for i, t in pairs(new_final_states_i) do
        if t ~= nil then
            table.insert(new_final_states, i)
        end
    end
    for i, t in pairs(nfa.final_states_raw) do
            table.insert(new_final_states, t)
    end

    local new_trainsitions = {}
    for t = 1, nfa_dest.states, 1 do
        for symbol, next_state in pairs(nfa_dest.transitions[t]) do
            if symbol == '_epsilon_' then
                for _, v in pairs(next_state['']) do
                    for next_symbol, after_next_state_list in pairs(nfa_dest.transitions[v]) do
                        if next_symbol ~= '_epsilon_' then
                            for i_hate_lua, after_next_state in pairs(after_next_state_list['']) do
                                table.insert(new_trainsitions, Transition(t, after_next_state, next_symbol))
                            end
                        end
                    end
                end
            end
        end
    end

    for _, t in pairs(nfa.transitions_raw) do
        if t.symbol ~= '_epsilon_' then
            table.insert(new_trainsitions, t)
        end
    end
    nfa_dest = Automaton:new(nfa.states, new_final_states, new_trainsitions, nfa.isDFA, nfa.start_states_raw)
    local res_transitions = {}
    local visited = {}
    local res_final_states = {}
    dfs(nfa_dest, nfa_dest.start_states_raw[1], res_transitions, visited, res_final_states)
    translate = {}
    for k, v in pairs(visited) do
        translate[v] = k
    end
    for _, t in pairs(res_transitions) do
        t.to = translate[t.to]
        t.from = translate[t.from]
    end
    for _, t in pairs(res_final_states) do
        t = translate[t]
    end
    for _, t in pairs(nfa.start_states_raw) do
        t = translate[t]
    end
    nfa_dest = Automaton:new(#visited, res_final_states, res_transitions, is_dfa(nfa_dest.transitions_raw), nfa.start_states_raw)

    return nfa_dest
end

return rmeps