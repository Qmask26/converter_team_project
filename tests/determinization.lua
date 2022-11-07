local Automaton = require("src/model/automaton")
local Regexs = require("src/model/regex")
require "src/automaton_functions/determinization"
require("src/r2nfa_converter/thompson")


local statesNumber = 4
local finalStates = {4}
local transitions = {
    {from = 1, symbol = "a", to = 2, label = ""},
    {from =2, symbol = 'b', to = 3, label = ""},
    {from = 3, symbol = "c", to = 4, label = ""},
    -- {from = 2, symbol = 'a', to = 3, label = ""},
    -- {from = 4, symbol = 'b', to = 3, label = ""},
    -- {from = 4, symbol = 'a', to = 4, label = ""},
    -- {from = 4, symbol = 'b', to = 5, label = ""},
    -- {from = 5, symbol = 'a', to = 3, label = ""},
    -- {from = 3, symbol = "_epsilon_", to = 6, label = ""}
}
local nfa = Automaton.Automaton:new(4, finalStates, transitions, false, {1})
local dfa = Det(nfa)

print("isDFA:", dfa.isDFA)
print("States:", dfa.states)
io.write("Finals: ")
for i = 1, dfa.states, 1 do
    if dfa.finality[i] then io.write(i, " ") end
end
print()
io.write("Start: ")
for i = 1, #dfa.start_states_raw, 1 do
    io.write(dfa.start_states_raw[i], " ")
end
print()
print("Transitions:(from, symbol, to, label)")
for i = 1, #dfa.transitions_raw, 1 do
    print(dfa.transitions_raw[i].from, dfa.transitions_raw[i].symbol, dfa.transitions_raw[i].to, dfa.transitions_raw[i].label)
end

-- local rtree = Regexs.Regex:new("(a|ba)*")
-- local nfa  = create_thompson_automaton(rtree)
-- print(nfa:tostring())
-- for i = 1, #nfa.start_states_raw, 1 do
--     print(nfa.start_states_raw[i])
-- end
-- local dfa = Det(nfa)
-- print(dfa:tostring())
-- for i = 1, #dfa.start_states_raw, 1 do
--     print(dfa.start_states_raw[i])
-- end