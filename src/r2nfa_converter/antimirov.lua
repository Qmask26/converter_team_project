local Regex = require("src/model/regex")
local Automaton = require("src/model/automaton")
local Set = require("src/model/set")
require("src/r2nfa_converter/utils")
require("src/derivatives/antimirov")
require("src/utils/common")

function create_antimirov_automaton(regex)
    local alphabet = {}
    local transitions = {}
    local states = {}
    local queue  = {}
    local final = Set:new({})
    local statesNumber = 0
    for k, v in pairs(regex.alphabet.items) do
        table.insert(alphabet, k)
    end
    table.insert(queue, {regex, alphabet})
    statesNumber = statesNumber + 1
    states[regex.root.value] = statesNumber
    while table.length(queue) ~= 0 do
        local current = table.remove(queue, 1)
        if current[2] ~= nil and table.length(current[2]) ~= 0 then
            for k, v in pairs(current[2]) do
                local deriv = antimirov_derivative(v, current[1].root)
                local alph = shallowcopy(current[2])
                table.remove(alph, k)
                for deriv_item in pairs(deriv.items) do
                    table.insert(queue, {Regex.Regex:new(deriv_item), alph})
                    if not is_transition_in_table({current[1].root.value, v, deriv_item}, transitions) then
                        table.insert(transitions, {current[1].root.value, v, deriv_item})
                    end
                    if states[deriv_item] == nil then
                        statesNumber = statesNumber + 1
                        states[deriv_item] = statesNumber
                    end
                    if canParseEpsilon(Regex.Regex:new(deriv_item)) then
                        final:add(deriv_item)
                    end
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
    return Automaton.Automaton(statesNumber, f, tr)
end

return create_antimirov_automaton

