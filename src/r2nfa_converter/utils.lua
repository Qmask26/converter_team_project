local Automaton = require("src/model/automaton")


eps = Automaton.eps

function transitions_increase_by_value(transitions, value)
    local tr = transitions
    for k, v in pairs(tr) do
        v.from = v.from + value
        v.to = v.to + value
    end
    return tr
end

function automatons_concat(m1, m2)
    local transitionsM1 = m1.transitions_raw
    local transitionsM2 = m2.transitions_raw
    local lenM1 = m1.states
    local lenM2 = m2.states

    transitionsM2 = transitions_increase_by_value(transitionsM2, lenM1 - 1)
    local M2_initial_neighbours = m2:allTransitions(lenM1)
    local transitions = transitionsM1
    for k, v in pairs(M2_initial_neighbours) do
        table.insert(transitions, Automaton.Transition:new(lenM1, v[1], v[2], v[3]))
    end

    for i = 2, #transitionsM2, 1 do
        table.insert(transitions, transitionsM2[i])
    end
    local statesNumber = lenM1 + lenM2 - 1
    return Automaton.Automaton(statesNumber, {statesNumber}, transitions)
end

function automatons_alt(m1, m2)
    local m1stateNumber = m1.states
    local m2stateNumber = m2.states
    local stateNumber = m1stateNumber + m2stateNumber + 2

    local m1tr = m1.transitions_raw
    m1tr = transitions_increase_by_value(m1tr, 1)
    local m2tr = m2.transitions_raw
    m2tr = transitions_increase_by_value(m2tr, m1stateNumber + 1)
    local tr = {}
    table.insert(tr, Automaton.Transition:new(1, 2, eps))
    for _, v in pairs(m1tr) do
        table.insert(tr, v)
    end
    table.insert(tr, Automaton.Transition:new(1, m1stateNumber + 2, eps))
    for _, v in pairs(m2tr) do
        table.insert(tr, v)
    end
    table.insert(tr, Automaton.Transition:new(m1stateNumber + 1, stateNumber, eps))
    table.insert(tr, Automaton.Transition:new(stateNumber - 1, stateNumber, eps))
    return Automaton.Automaton(stateNumber, {stateNumber}, tr)
end

function automatons_iter(m, positive)
    local tr = m.transitions_raw
    local statesNumber = m.states + 2
    tr = transitions_increase_by_value(tr, 1)
    table.insert(tr, Automaton.Transition:new(1, 2, eps))
    if positive == nil or not positive then
        table.insert(tr, Automaton.Transition:new(1, statesNumber, eps))
    end
    table.insert(tr, Automaton.Transition:new(statesNumber - 1, 2, eps))
    table.insert(tr, Automaton.Transition:new(statesNumber - 1, statesNumber, eps))
    return Automaton.Automaton:new(statesNumber, {statesNumber}, tr)
end

