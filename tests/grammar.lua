local Grammar = require("src/model/grammar")
local Regexs = require("src/model/regex")
require "src/r2nfa_converter/thompson"
require "src/utils/common"

local rtree = Regexs.Regex:new("(a|b*)")
local nfa = create_thompson_automaton(rtree)

local grammar = Grammar.Grammar:new(nfa, false)
print('NFA')
print(nfa:tostring())
print('Grammar')
print(grammar:tostring())