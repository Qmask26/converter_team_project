local Regex = require("src/model/regex")
local Automaton = require("src/model/automaton")
local eps = Automaton.eps
require("src/r2nfa_converter/thompson")
require("src/r2nfa_converter/utils")

-- src/r2nfa_converter/utils
print("Test single operation automaton creation")
local tr1 = {Automaton.Transition:new(1, 2, "a")}
local tr2 = {Automaton.Transition:new(1, 2, "b"), Automaton.Transition:new(2, 3, "a")}
local a1 = Automaton.Automaton:new(2, {2}, tr1)
local a2 = Automaton.Automaton:new(3, {3}, tr2)

-- concatination (m1)(m2)
local merged = automatons_concat(a1, a2)

-- alternative
local alt = automatons_alt(a1, a2)

-- Kleene star
local iter = automatons_iter(a2)
local iter = automatons_iter(a2, false)

-- Kleene plus
local iter = automatons_iter(a2, true)

-- for k, v in pairs(iter.transitions_raw) do
--     print(v.from, v.symbol, v.to)
-- end

-- src/r2nfa_converter
print("Test Thompson automaton Th(R)")
r = Regex.Regex:new("(((a|(c|d)*)|bc)*)")
r1 = Regex.Regex:new("(a|b*)")
a = create_thompson_automaton(r1)
for k, v in pairs(a.transitions_raw) do
    print(v.from, v.symbol, v.to)
end
