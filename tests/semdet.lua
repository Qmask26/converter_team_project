require "src/automaton_functions/semdet"
local Automaton = require("src/model/automaton")
require "src/automaton_functions/determinization"


local statesNumber = 5
local finalStates = {5}
local transitions = {
    {from = 1, symbol = "c", to = 2, label = ""},
    {from = 2, symbol = 'a', to = 3, label = ""},
    {from = 2, symbol = 'a', to = 4, label = ""},
    {from = 3, symbol = 'b', to = 4, label = ""},
    {from = 3, symbol = 'b', to = 5, label = ""},
    {from = 1, symbol = "c", to = 3, label = ""},
}
local nfa = Automaton.Automaton:new(statesNumber, finalStates, transitions, false, {1})
print(nfa:tostring())
SemDet(nfa)