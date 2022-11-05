local Regex = require("src/model/regex")
local Automaton = require("src/model/automaton")
local Set = require("src/model/set")
require("src/r2nfa_converter/utils")
require("src/derivatives/antimirov")
require("src/utils/common")

function create_antimirov_automaton(regex, debug)
    local alphabet = {}
    local visited = Set:new({})
    local transitions = {}
    local states = {}
    local queue  = {}
    local final = Set:new({})
    local statesNumber = 0
    for k, v in pairs(regex.alphabet.items) do
        table.insert(alphabet, k)
    end

    table.insert(queue, regex)
    statesNumber = statesNumber + 1
    states[regex.root.value] = statesNumber

    while table.length(queue) ~= 0 do
        local current = table.remove(queue, 1)
        visited:add(current.root.value)
        if canParseEpsilon(current) then
            final:add(current.root.value)
        end
        for _, v in pairs(alphabet) do
            local deriv = antimirov_derivative(v, current)
            for deriv_item in pairs(deriv.items) do
                if not visited:has(deriv_item) then
                    table.insert(queue, Regex.Regex:new(deriv_item))
                end
                if not is_transition_in_table({current.root.value, v, deriv_item}, transitions) then
                    table.insert(transitions, {current.root.value, v, deriv_item})
                end
                if states[deriv_item] == nil then
                    statesNumber = statesNumber + 1
                    states[deriv_item] = statesNumber
                end
            end
        end
    end
    local tr = {}
    local f = {}
    for k, v in pairs(transitions) do
        table.insert(tr, Automaton.Transition(states[v[1]], states[v[3]], v[2]))
    end
    for k, v in pairs(states) do
        if final:has(k) then
            table.insert(f, v)
        end
    end
    local a = Automaton.Automaton(statesNumber, f, tr)
    if debug then
        print("Finished Antimirov automaton creation of", regex.root.value)
        print(a:tostring())
    end
    return a
end

return create_antimirov_automaton

