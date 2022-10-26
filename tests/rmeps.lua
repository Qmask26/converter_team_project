local Automaton = require("src/model/automaton")
require "src/automaton_functions/rmeps"

local statesNumber = 7
local finalStates = {6}
local transitions = {
    {from = 1, symbol = "_epsilon_", to = 2, label = ""},
    {from = 1, symbol = 'a', to = 4, label = ""},
    {from = 1, symbol = "a", to = 5, label = ""},
    {from = 2, symbol = 'a', to = 3, label = ""},
    {from = 4, symbol = 'b', to = 3, label = ""},
    {from = 4, symbol = 'a', to = 4, label = ""},
    {from = 4, symbol = 'b', to = 5, label = ""},
    {from = 5, symbol = '_epsilon_', to = 3, label = ""},
    {from = 3, symbol = "_epsilon_", to = 6, label = ""}
}
local nfa = Automaton.Automaton:new(6, finalStates, transitions, false, {1})
local dfa = rmeps(nfa)


-- print("isnfa:", nfa.isnfa)
-- print("States:", nfa.states)
-- io.write("Finals: ")
-- for i = 1, nfa.states, 1 do
--     if nfa.finality[i] then io.write(i, " ") end
-- end
-- print()
-- io.write("Start: ")
-- for i = 1, #nfa.start_states_raw, 1 do
--     io.write(nfa.start_states_raw[i], " ")
-- end
-- print()
-- print("Transitions:(from, symbol, to, label)")
-- for i = 1, #nfa.transitions_raw, 1 do
--     print(nfa.transitions_raw[i].from, nfa.transitions_raw[i].symbol, nfa.transitions_raw[i].to, nfa.transitions_raw[i].label)
-- end

-- print()

-- print("isDFA:", dfa.isDFA)
-- print("States:", dfa.states)
-- io.write("Finals: ")
-- for i = 1, dfa.states, 1 do
--     if dfa.finality[i] then io.write(i, " ") end
-- end
-- print()
-- io.write("Start: ")
-- for i = 1, #dfa.start_states_raw, 1 do
--     io.write(dfa.start_states_raw[i], " ")
-- end
-- print()
-- print("Transitions:(from, symbol, to, label)")
-- for i = 1, #dfa.transitions_raw, 1 do
--     print(dfa.transitions_raw[i].from, dfa.transitions_raw[i].symbol, dfa.transitions_raw[i].to, dfa.transitions_raw[i].label)
-- end

