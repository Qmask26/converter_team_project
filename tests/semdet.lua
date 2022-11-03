require "src/automaton_functions/semdet"
local Automaton = require("src/model/automaton")
require "src/automaton_functions/determinization"


local statesNumber = 5
local finalStates = {5, 4, 3}
local transitions = {
    {from = 1, symbol = "c", to = 2, label = ""},
    {from = 1, symbol = "c", to = 3, label = ""},
    {from = 2, symbol = "b", to = 4, label = ""},
    {from = 2, symbol = "b", to = 5, label = ""},
}
local nfa = Automaton.Automaton:new(statesNumber, finalStates, transitions, false, {1})
print(nfa:tostring())
print(SemDet(nfa))