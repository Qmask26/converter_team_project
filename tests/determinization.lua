local Automaton = require("src/model/automaton")
local Regexs = require("src/model/regex")
require "src/automaton_functions/determinization"
require("src/r2nfa_converter/thompson")


-- local statesNumber = 6
-- local finalStates = {6}
-- local transitions = {
--     {from = 1, symbol = "_epsilon_", to = 2, label = ""},
--     {from = 1, symbol = 'a', to = 4, label = ""},
--     {from = 1, symbol = "_epsilon_", to = 5, label = ""},
--     {from = 2, symbol = 'a', to = 3, label = ""},
--     {from = 4, symbol = 'b', to = 3, label = ""},
--     {from = 4, symbol = 'a', to = 4, label = ""},
--     {from = 4, symbol = 'b', to = 5, label = ""},
--     {from = 5, symbol = 'a', to = 3, label = ""},
--     {from = 3, symbol = "_epsilon_", to = 6, label = ""}
-- }
-- local nfa = Automaton.Automaton:new(6, finalStates, transitions, false, {1})
-- local dfa = Det(nfa)

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
local r2 = Regexs.Regex:new("ba")
local nfa = create_thompson_automaton(r2)
local dfa2 = Det(nfa)
--dfa2:addTrap()
print(dfa2:tostring())