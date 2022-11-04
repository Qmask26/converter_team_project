local Regex = require("src/model/regex")
local Automaton = require("src/model/automaton")
local Set = require("src/model/set")
require("src/r2nfa_converter/glushkov")
require("src/r2nfa_converter/utils")
require("src/utils/common")

function create_follow_automaton(regex, debug)
    local r_copy = Regex.Regex:new(regex.root.value)
    linearize(r_copy)
    local statesNumber = 1
    local states = {}
    local follow = {}
    local follow_equiv = {}
    states["initial"] = statesNumber
    for k in pairs(parseNodeAlphabet(r_copy.root, #r_copy.root.value ~= 0).items) do
        statesNumber = statesNumber + 1
        states[k] = statesNumber
        follow[k] = {}
        follow_equiv[k] = k
    end
    follow_equiv["initial"] = "initial"
    local start_symbols = get_start_possible_symbols_regex(r_copy)
    local finish_symbols = get_finish_possible_symbols_regex(r_copy)
    local symbol_pairs = get_possible_symbol_pairs(r_copy)

    local transitions = {}
    for k in pairs(start_symbols.items) do
        table.insert(transitions, {"initial", k, k:sub(1, 1)})
    end
    for _, v in pairs(symbol_pairs) do
        table.insert(transitions, {v[1], v[2], v[2]:sub(1, 1)})
        table.insert(follow[v[1]], v[2])
    end
    for k in pairs(follow) do
        for k1 in pairs(follow) do
            if  ((finish_symbols:has(k) and finish_symbols:has(k1)) or (not finish_symbols:has(k) and not finish_symbols:has(k1))) and
                compare(follow[k], follow[k1])
                then
                    follow_equiv[k] = k1
            end
        end
    end
    for _, v in pairs(transitions) do
        v[1] = follow_equiv[v[1]]
        v[2] = follow_equiv[v[2]]
    end
    local states_new = {}
    local statesNumber_new = 1
    states_new["initial"] = statesNumber_new
    for k, v in pairs(follow_equiv) do
        if states_new[v] == nil then
            statesNumber_new = statesNumber_new + 1
            states_new[v] = statesNumber_new
        end
    end
    local tr = {}
    local tr_f = {}
    for k, v in pairs(transitions) do
        local t = {v[1], v[2], v[3]}
        if not is_transition_in_table(t, tr) then
            table.insert(tr, t)
            table.insert(tr_f, Automaton.Transition:new(states_new[v[1]], states_new[v[2]], v[3]))
        end
    end

    local f = {}
    if canParseEpsilon(regex) then
        table.insert(f, states_new["initial"])
    end
    for k in pairs(finish_symbols.items) do
        table.insert(f, states_new[k])
    end
    a = Automaton.Automaton:new(statesNumber, f, tr_f)
    if debug then
        print("Finished automaton IlieYu creation of", regex.root.value)
        print(a:tostring())
    end
    return a
end

return create_follow_automaton
