local Automaton = require("src/model/automaton")
require "src/automaton_functions/determinization"

local statesNumber = 6
local finalStates = {6}
local transitions = {
    {from = 1, symbol = '', to = 2, label = ""},
    {from = 1, symbol = 'a', to = 4, label = ""},
    {from = 1, symbol = '', to = 5, label = ""},
    {from = 2, symbol = 'a', to = 3, label = ""},
    {from = 4, symbol = 'b', to = 3, label = ""},
    {from = 4, symbol = 'a', to = 4, label = ""},
    {from = 4, symbol = 'b', to = 5, label = ""},
    {from = 5, symbol = 'a', to = 3, label = ""},
    {from = 3, symbol = '', to = 6, label = ""}
}
local nfa = Automaton.Automaton:new(6, finalStates, transitions, false)
Det(nfa)