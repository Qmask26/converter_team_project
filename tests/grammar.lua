local Grammar = require("src/model/grammar")
local Regexs = require("src/model/regex")
local Automaton = require("src/model/automaton")
require "src/r2nfa_converter/thompson"
require "src/r2nfa_converter/glushkov"
require "src/utils/common"
require "src/predicates/predicates"

local rtree1 = Regexs.Regex:new("(a|b*)")
local nfa1 = create_thompson_automaton(rtree1)

local rtree2 = Regexs.Regex:new("(a|b*)")
local nfa2 = create_thompson_automaton(rtree2)

local rtree3 = Regexs.Regex:new("(a|b)*b")
local nfa3 = create_glushkov_automaton(rtree3)

--print(grammar1:tostring())
--print(grammar2:tostring())

local statesNumber = 5
local finalStates = {4, 5}
local transitions = {
    {from = 1, symbol = "b", to = 2, label = ""},
    {from = 1, symbol = 'b', to = 3, label = ""},
    {from = 2, symbol = "a", to = 4, label = ""},
    {from = 2, symbol = 'c', to = 5, label = ""},
    {from = 3, symbol = 'a', to = 5, label = ""}
}
local nfa1 = Automaton.Automaton:new(5, finalStates, transitions, false, {1})

local statesNumber = 5
local finalStates = {4, 5}
local transitions = {
    {from = 1, symbol = "b", to = 2, label = ""},
    {from = 1, symbol = 'b', to = 3, label = ""},
    {from = 2, symbol = "a", to = 4, label = ""},
    {from = 2, symbol = 'c', to = 4, label = ""},
    {from = 3, symbol = 'a', to = 5, label = ""}
}
local nfa2 = Automaton.Automaton:new(5, finalStates, transitions, false, {1})

print('Bisimilar: ' .. tostring(Bisimilar(nfa1, nfa2)))
print()

print('Equal: ' .. tostring(Equal(nfa1, nfa2)))
print()

--print(nfa3:tostring())
print('MergeBisim: \n' .. MergeBisim(nfa1):tostring())
print()

--print('Equal: ' .. tostring(Equal(nfa1, nfa2)))
--print('Equiv: ' .. EquivNFA(nfa1, nfa2))
--print('NFA')
--print(nfa1:tostring())
--print('Grammar')
--print(grammar1:tostring())

--print('NFA')
--print(nfa2:tostring())
--print('Grammar')
--print(grammar2:tostring())