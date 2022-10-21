local Automaton_module = require("src/model/automaton")
require "src/automaton_functions/determinization"

local Automaton = Automaton_module.Automaton
local Transition = Automaton_module.Transition

-- local transitions = {
--     Transition:new(1, 2, 'a'),
--     Transition:new(1, 3, 'a'), 
--     Transition:new(1, 3, 'b'),
--     Transition:new(3, 2, 'a'),
--     Transition:new(2, 3, 'a'),
--     Transition:new(3, 3, 'a'),
--     Transition:new(2, 4, 'b'),
--     Transition:new(3, 4, 'b')
-- }


-- local automaton = Automaton:new(4, {4}, transitions, false, {1})


local transitions_inversed = {
    Transition:new(2, 1, 'a'),
    Transition:new(3, 1, 'a'), 
    Transition:new(3, 1, 'b'),
    Transition:new(2, 3, 'a'),
    Transition:new(3, 2, 'a'),
    Transition:new(3, 3, 'a'),
    Transition:new(4, 2, 'b'),
    Transition:new(4, 3, 'b')
}


local automaton_inversed = Automaton:new(4, {1}, transitions_inversed, false, {4})


-- local minimized = Det(Det(automaton:inverse()):inverse())
-- local minimized = Det(automaton:inverse())
local minimized = Det(automaton_inversed)



print("isDFA:", minimized.isDFA)
print("States:", minimized.states)
io.write("Finals: ")
for i = 1, minimized.states, 1 do
    if minimized.finality[i] then io.write(i, " ") end
end
print()
print("Transitions:(from, symbol, to, label)")
for i = 1, #minimized.transitions_raw, 1 do
    print("\t",minimized.transitions_raw[i].from, minimized.transitions_raw[i].symbol, minimized.transitions_raw[i].to, minimized.transitions_raw[i].label)
end
