require "src/r2nfa_converter/glushkov"
local Automaton_module = require("src/model/automaton")
local Regexs = require("src/model/regex")
local Set = require("src/model/set")

function Match(regex, str, debug)
    -- str = string.sub(str.root.value, 2, #str.root.value - 1)
    local nfa = create_glushkov_automaton(regex)
    local start_state = nfa.start_states_raw[1]
    local match = {"", ""}
    local res
    
    for i = 1, #str, 1 do
        match = search_occurrences(i, i, start_state, str, match, nfa)
        if (#match[2] ~= 0) then break end
    end

    if (#match[2] == 0) then 
        res =  {str, 'nil'} 
    else
        res = match
    end
    
    if debug == true then
        for _, v in pairs(res) do
            print(v)
        end
    end
    return res
end

function search_occurrences(start, endd, state_from, str, match, nfa)
    if (endd == #str+1) then return match end
    local symbol = str:sub(endd, endd)
    local transitions = nfa:allTransitions(state_from)
    for _, v in pairs(transitions) do
        if (v[2] == symbol) then
            if (nfa:isStateFinal(v[1]) and (endd - start + 1) > #match[2]) then
                local pref
                if (start == 1) then
                    pref = " "
                else
                    pref = str:sub(1, start - 1)
                end
                match = {pref, str:sub(start, endd)}
            end
            match = search_occurrences(start, endd+1, v[1], str, match, nfa)
        end
    end
    return match
end

return Match

