local Automaton = require("src/model/automaton").Automaton
local Transition = require("src/model/automaton").Transition
local EPS = require("src/model/automaton").eps
local det = require("src/automaton_functions/determinization")

function Concatenate(automatonA, automatonB, output)
    local newStatesNumber = automatonA.states + automatonB.states;
    local newFinalStates = automatonB.final_states_raw;
    local newTransitions = automatonA.transitions_raw;
    local newStartStates = automatonA.start_states_raw;

    for i = 1, #newFinalStates, 1 do
        newFinalStates[i] = newFinalStates[i] + automatonA.states;
    end

    for _, v in pairs(automatonB.transitions_raw) do
        table.insert(newTransitions, Transition:new(v.from + automatonA.states, v.to + automatonA.states, v.symbol, v.label));
    end

    for _, v in pairs(automatonA.final_states_raw) do
        for _, k in pairs(automatonB.start_states_raw) do
            table.insert(newTransitions, Transition:new(v, k + automatonA.states, EPS))
        end
    end
    local res = det(Automaton:new(newStatesNumber, newFinalStates, newTransitions, false, newStartStates))
    if (output == true) then
        print("Concatenation: ")
        print(res:tostring())
        print("")
    end
    return res
end

function Unite(automatonA, automatonB, output)
    local newStatesNumber = automatonA.states + automatonB.states + 1;
    local newFinalStates = automatonA.final_states_raw;
    local newTransitions = automatonA.transitions_raw;
    local newStartStates = {newStatesNumber};

    for _, v in pairs(automatonB.final_states_raw) do
        table.insert(newFinalStates, v + automatonA.states)
    end

    for _, v in pairs(automatonB.transitions_raw) do
        table.insert(newTransitions, Transition:new(v.from + automatonA.states, v.to + automatonA.states, v.symbol, v.label))
    end

    for _, v in pairs(automatonA.start_states_raw) do
        table.insert(newTransitions, Transition:new(newStatesNumber, v, EPS))
    end

    for _, v in pairs(automatonB.start_states_raw) do
        table.insert(newTransitions, Transition:new(newStatesNumber, v + automatonA.states, EPS))
    end
    local res = det(Automaton:new(newStatesNumber, newFinalStates, newTransitions, false, newStartStates))
    if (output == true) then
        print("Unite: ")
        print(res:tostring())
        print("")
    end
    return res
end

local Algebra = {}
Algebra.Concatenate = Concatenate
Algebra.Unite = Unite

return Algebra