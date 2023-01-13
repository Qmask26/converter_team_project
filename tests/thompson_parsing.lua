local Automaton = require("src/model/automaton")
local Regexs = require("src/model/regex")
require("src/functions/thompson_parsing")

local statesNumber = 5
local finalStates = {5}
local transitions = {
    {from = 1, symbol = "a", to = 2, label = ""},
    {from =1, symbol = 'a', to = 3, label = ""},
    {from = 1, symbol = "_epsilon_", to = 4, label = ""},
    {from = 4, symbol = 'a', to = 5, label = ""}
}
local nfa = Automaton.Automaton:new(statesNumber, finalStates, transitions, false, {1})

thompson_parsing(nfa, 'a')
