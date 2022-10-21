local Regex = require("src/model/regex")
local Automaton = require("src/model/automaton")
require("src/r2nfa_converter/utils")

function create_thompson_automaton(reg)
    return thompson_algorithm(reg.root)
end

function thompson_algorithm(reg)
    if (reg.type == Regex.operations.concat) then
        local m1 = thompson_algorithm(reg.firstChild)
        local m2 = thompson_algorithm(reg.secondChild)
        return automatons_concat(m1, m2)
    elseif (reg.type == Regex.operations.alt) then
        local m1 = thompson_algorithm(reg.firstChild)
        local m2 = thompson_algorithm(reg.secondChild)
        return automatons_alt(m1, m2)
    elseif (reg.type == Regex.operations.iter) then
        local m = thompson_algorithm(reg.firstChild)
        return automatons_iter(m)
    elseif (reg.type == Regex.operations.symbol) then
        return Automaton.Automaton(2, {2}, {Automaton.Transition(1, 2, reg.value)})
    elseif (reg.type == Regex.operations.positive) then
        local m = thompson_algorithm(reg.firstChild)
        return automatons_iter(m, true)
    else
    end
end
