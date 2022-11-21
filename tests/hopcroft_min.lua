require "src/automaton_functions/arden"
local Automaton = require("src/model/automaton")
require "src/automaton_functions/hopcroft_min"

local statesNumber = 5
local finalStates = {2, 3}
local transitions = {
    {from = 1, symbol = 'a', to = 2, label = ""},
    {from = 1, symbol = "c", to = 3, label = ""},
    {from = 2, symbol = 'b', to = 4, label = ""},
    {from = 3, symbol = 'a', to = 4, label = ""},
    {from = 4, symbol = 'b', to = 4, label = ""},
    {from = 5, symbol = 'b', to = 1, label = ""}
}
local dfa = Automaton.Automaton:new(statesNumber, finalStates, transitions, true, {1})
local undead = minimize(dfa, true)
require "src/automaton_functions/arden"

local ard = Arden(undead)
print(ard.root.value)