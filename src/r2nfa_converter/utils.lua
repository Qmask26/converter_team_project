local Automaton = require("src/model/automaton")
require("src/utils/common")

eps = Automaton.eps


function copy_transitions(tr)
    local res = {}
    for k, v in pairs(tr) do
        table.insert(res, Automaton.Transition(v.from, v.to, v.symbol))
    end
    return res
end

function transitions_increase_by_value(transitions, value)
    local tr = copy_transitions(transitions)
    for k, v in pairs(tr) do
        v.from = v.from + value
        v.to = v.to + value
    end
    return tr
end

function automatons_concat(m1, m2)
    local m1tr = copy_transitions(m1.transitions_raw)
    local m2tr = copy_transitions(m2.transitions_raw)

    local m1stateNumber = m1.states
    local m2stateNumber = m2.states
    local statesNumber = m1stateNumber + m2stateNumber
    
    m2tr = transitions_increase_by_value(m2tr, m1stateNumber)
    
    local tr = copy_transitions(m1tr)
    table.insert(tr, Automaton.Transition:new(m1stateNumber, m1stateNumber + 1, eps))
    for _, v in pairs(m2tr) do
        table.insert(tr, v)
    end
    
    return Automaton.Automaton(statesNumber, {statesNumber}, tr)
end

function automatons_alt(m1, m2)
    local m1stateNumber = m1.states
    local m2stateNumber = m2.states
    local stateNumber = m1stateNumber + m2stateNumber + 2

    local m1tr = copy_transitions(m1.transitions_raw)
    m1tr = transitions_increase_by_value(m1tr, 1)
    local m2tr = copy_transitions(m2.transitions_raw)
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
    local tr = copy_transitions(m.transitions_raw)
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

function is_transition_in_table(transition, arr)
    if arr == nil or table.length(arr) == 0 then
        return false
    end
    for _, tr in pairs(arr) do
        local tmp = {}
        for _, v in pairs(tr) do
            table.insert(tmp, v)
        end
        if tmp[1] == transition[1] and tmp[2] == transition[2] and tmp[3] == transition[3] then
            return true
        end
    end
    return false
end