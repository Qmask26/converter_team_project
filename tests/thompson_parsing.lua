local Automaton = require("src/model/automaton")
local Regexs = require("src/model/regex")
require("src/functions/thompson_parsing")

local statesNumber = 2
local finalStates = {1, 2}
local transitions = {
    {from = 1, symbol = "a", to = 1, label = ""},
    {from =1, symbol = 'a', to = 2, label = ""},
    {from = 2, symbol = "b", to = 2, label = ""}
}
local nfa = Automaton.Automaton:new(statesNumber, finalStates, transitions, false, {1})

print(thompson_parsing(nfa , "aaaabbba"))
