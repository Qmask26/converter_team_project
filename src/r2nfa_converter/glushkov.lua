local Regex = require("src/model/regex")
local Automaton = require("src/model/automaton")
local Set = require("src/model/set")
require("src/r2nfa_converter/utils")
require("src/utils/common")
-- require("/path/to/rem_eps/function")

function create_glushkov_automaton(regex, debug)
    local r_copy = Regex.Regex:new(regex.root.value)
    linearize(r_copy)
    local statesNumber = 1
    local states = {}
    states["initial"] = statesNumber
    for k in pairs(parseNodeAlphabet(r_copy.root, #r_copy.root.value ~= 0).items) do
        statesNumber = statesNumber + 1
        states[k] = statesNumber
    end

    local start_symbols = get_start_possible_symbols_regex(r_copy)
    local finish_symbols = get_finish_possible_symbols_regex(r_copy)
    local symbol_pairs = get_possible_symbol_pairs(r_copy)

    local transitions = {}
    for k in pairs(start_symbols.items) do
        table.insert(transitions, {"initial", k, k})
    end
    for _, v in pairs(symbol_pairs) do
        table.insert(transitions, {v[1], v[2], v[2]})
    end

    local tr = {}
    local f = {}
    for k, v in pairs(transitions) do
        table.insert(tr, Automaton.Transition:new(states[v[1]], states[v[2]], v[3]:sub(1, 1)))
    end

    if canParseEpsilon(regex) then
        table.insert(f, states["initial"])
    end
    for k in pairs(finish_symbols.items) do
        table.insert(f, states[k])
    end
    a = Automaton.Automaton:new(statesNumber, f, tr)
    if debug then
        print("Finished Glushkov automaton creation of", regex.root.value)
        print(a:tostring())
    end
    return a
end

return create_glushkov_automaton