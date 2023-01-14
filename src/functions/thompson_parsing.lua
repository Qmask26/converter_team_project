local Automaton = require("src/model/automaton")
local Regexs = require("src/model/regex") 

local function addState(nfa, start, eps)
    local flag = true
    for _, state in pairs(start) do
        table.insert(eps, state)
        if nfa.transitions[state]["_epsilon_"] ~= nil then 
            for _, estate in pairs(nfa.transitions[state]["_epsilon_"][""]) do
                table.insert(eps, estate)
            end 
        end
    end
    return eps
end

function thompson_parsing(nfa , str)
    local s = {}
    str:gsub(".",function(c) table.insert(s,c) end)
    local current_states = {}
    current_states = addState(nfa, nfa.start_states_raw, current_states)

    for _, c in pairs(s) do
        local next_states = {}
        for _, state in pairs(current_states) do
            if nfa.transitions[state][c] ~= nil then
                next_states = addState(nfa, nfa.transitions[state][c][""], next_states)
            end
        end
        current_states = {}
        for _, state in pairs(next_states) do
            table.insert(current_states, state)
        end
    end
    
    for _, state in pairs(current_states) do
        if nfa.finality[state] then return true end
    end
    return false    
end