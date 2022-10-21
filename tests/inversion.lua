local Automaton_module = require("src/model/automaton")

local Automaton = Automaton_module.Automaton
local Transition = Automaton_module.Transition


print("Test inversion")


local transitions = {
    Transition:new(1, 2, 'b'),
    Transition:new(3, 4, 'a'), 
    Transition:new(3, 3, 'a'),
    Transition:new(3, 4, 'b'),
    Transition:new(2, 3, 'b')
}


local automaton = Automaton:new(4, {3, 4}, transitions)
local automaton_inversed = automaton:inverse()


for i = 1, #transitions, 1 do
    assert(automaton.transitions_raw[i].from == automaton_inversed.transitions_raw[i].to)
    assert(automaton.transitions_raw[i].to == automaton_inversed.transitions_raw[i].from)
end


print("Tests passed")


