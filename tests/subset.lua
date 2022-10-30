local Regexs = require("src/model/regex")
require "src/utils/common"
require "src/predicates/predicates"
require("src/r2nfa_converter/thompson")
require "src/automaton_functions/determinization"
require("src/automaton_functions/minimization")

local r1 = Regexs.Regex:new("b*")
local r2 = Regexs.Regex:new("(b|a)*")

print(SubsetRegex(r2, r1))
print(SubsetRegex(r1, r2))