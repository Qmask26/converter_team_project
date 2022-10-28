local Automaton = require("src/model/automaton")
require "src/automaton_functions/arden"

local statesNumber = 4
local finalStates = {3, 4}
local transitions = {
    {from = 1, symbol = "a", to = 2, label = ""},
    {from = 1, symbol = "b", to = 3, label = ""},
    {from = 2, symbol = "a", to = 1, label = ""},
    {from = 2, symbol = "_epsilon_", to = 3, label = ""},
    {from = 3, symbol = "b", to = 3, label = ""},
    {from = 3, symbol = "b", to = 4, label = ""},
    {from = 4, symbol = "a", to = 3, label = ""},
    {from = 4, symbol = "a", to = 2, label = ""},
}
-- local transitions = {
--     {from = 1, symbol = "a", to = 2, label = ""},
--     {from = 1, symbol = "b", to = 3, label = ""},
--     {from = 2, symbol = "a", to = 3, label = ""},
--     {from = 2, symbol = "b", to = 2, label = ""},
--     {from = 3, symbol = "a", to = 3, label = ""},
--     {from = 3, symbol = "b", to = 3, label = ""},
-- }
-- local transitions = {
--     {from = 1, symbol = "a", to = 2, label = ""},
--     {from = 2, symbol = "a", to = 3, label = ""},
--     {from = 2, symbol = "b", to = 1, label = ""},
--     {from = 2, symbol = "_epsilon_", to = 4, label = ""},
--     {from = 3, symbol = "a", to = 1, label = ""},
--     {from = 3, symbol = "b", to = 4, label = ""},
--     {from = 4, symbol = "a", to = 4, label = ""},
-- }
local nfa = Automaton.Automaton:new(4, finalStates, transitions, false, {1})
Arden(nfa)