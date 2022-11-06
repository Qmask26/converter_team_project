require "src/automaton_functions/semdet"
local Automaton = require("src/model/automaton")
require "src/automaton_functions/determinization"
require("src/r2nfa_converter/glushkov")
local Regexs = require("src/model/regex")

-- local statesNumber = 5
-- local finalStates = {5, 4, 3}
-- local transitions = {
--     {from = 1, symbol = "c", to = 2, label = ""},
--     {from = 1, symbol = "c", to = 3, label = ""},
--     {from = 2, symbol = "b", to = 4, label = ""},
--     {from = 2, symbol = "b", to = 5, label = ""},
-- }
local r1 = Regexs.Regex:new("((ab)*|a)*")
local a = create_glushkov_automaton(r1)
print(SemDet(a))