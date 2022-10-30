local Regex = require("src/model/regex")
local Automaton = require("src/model/automaton")
require("src/r2nfa_converter/thompson")
require "src/automaton_functions/determinization"
require "src/predicates/predicates"
require "src/automaton_functions/intersection"
require("src/automaton_functions/minimization")

local r1 = Regex.Regex:new("(a|ba)*")
local nfa1 = create_thompson_automaton(r1)
local dfa1 = Det(nfa1)
dfa1:addTrap()
print(dfa1:tostring())

local r2 = Regex.Regex:new("(ba)*")
local nfa2 = create_thompson_automaton(r2)
local dfa2 = Det(nfa2)
dfa2:addTrap()
print(minimization(dfa2):tostring())

print(tostring(SubsetNFA(nfa2, nfa1)))
print(tostring(SubsetRegex(r2, r1)))

--local dfa_intersect = minimization(intersect_dfa(dfa1, dfa2))
--print(minimization(dfa_intersect):tostring())
--print(EquivNFA(dfa2, dfa_intersect))