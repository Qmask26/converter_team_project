local Automaton = require("src/model/automaton")
require "src/automaton_functions/rmeps"

local statesNumber = 6
local finalStates = {6}
local transitions = {
    {from = 1, symbol = "_epsilon_", to = 2, label = ""},
    {from = 1, symbol = 'c', to = 4, label = ""},
    {from = 1, symbol = "e", to = 5, label = ""},
    {from = 2, symbol = 'a', to = 3, label = ""},
    {from = 4, symbol = 'b', to = 3, label = ""},
    {from = 4, symbol = 'a', to = 4, label = ""},
    {from = 4, symbol = 'b', to = 5, label = ""},
    {from = 5, symbol = '_epsilon_', to = 3, label = ""},
    {from = 3, symbol = "_epsilon_", to = 6, label = ""}
}
local nfa_eps = Automaton.Automaton:new(statesNumber, finalStates, transitions, false, {1})

local statesNumber_no_eps = 4
local finalStates_no_eps = {3, 5}
local transitions_no_eps = {
    {from = 1, symbol = "c", to = 2, label = ""},
    {from = 1, symbol = 'a', to = 3, label = ""},
    {from = 1, symbol = "e", to = 4, label = ""},
    {from = 2, symbol = 'a', to = 2, label = ""},
    {from = 2, symbol = 'b', to = 3, label = ""},
    {from = 2, symbol = 'b', to = 4, label = ""},
}
local nfa_no_eps = Automaton.Automaton:new(statesNumber_no_eps, finalStates_no_eps, transitions_no_eps, false, {1})

print(nfa_eps:tostring())
print()
print(nfa_no_eps:tostring())
print()
print(rmeps(nfa_eps):tostring())
