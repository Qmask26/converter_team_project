require "src/r2nfa_converter/glushkov"
require "src/functions/match"
local Automaton_module = require("src/model/automaton")
local Regexs = require("src/model/regex")



local s = "(a|b*)"
local rtree3 = Regexs.Regex:new(s)
local nfa3 = create_glushkov_automaton(rtree3)
print(nfa3:tostring())

res = Match(rtree3, "aaabb")
print(table.concat(res, ' '))