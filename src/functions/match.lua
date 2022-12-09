require "src/r2nfa_converter/glushkov"
local Automaton_module = require("src/model/automaton")
local Regexs = require("src/model/regex")
local Set = require("src/model/set")

function Match(regex, str, debug)
    str = string.sub(str.root.value, 2, #str.root.value - 1)
    local nfa = create_glushkov_automaton(regex)
    local start_state = nfa.start_states_raw[1]
    local matches = Set:new({})
    
    for i = 1, #str, 1 do
        matches = search_occurrences(i, i, start_state, str, matches, nfa)
    end
    local res = matches:toarray()
    if debug == true then
        for _, v in pairs(res) do
            print(v)
        end
    end
    return res
end

function search_occurrences(start, endd, state_from, str, matches, nfa)
    if (endd == #str+1) then return matches end
    local symbol = str:sub(endd, endd)
    local transitions = nfa:allTransitions(state_from)
    for _, v in pairs(transitions) do
        if (v[2] == symbol) then
            if (nfa:isStateFinal(v[1])) then
                matches:add(str:sub(start, endd))
            end
            matches = search_occurrences(start, endd+1, v[1], str, matches, nfa)
        end
    end
    return matches
end

return Match

