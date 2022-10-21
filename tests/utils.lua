local Regexs = require("src/model/regex")
require "src/r2nfa_converter/thompson"
require "src/automaton_functions/determinization"

require "src/utils/common"

local t = {}
t[1] = 2
t[3] = 4
t[5] = 6
 
print(table_tostring(t))

local regex_s = Regexs.Regex:new("(a|b*)")
local nfa = create_thompson_automaton(regex_s)
local dfa = Det(nfa)

print('\nNFA')
print(nfa:tostring())
print('\nDFA')
print(dfa:tostring())