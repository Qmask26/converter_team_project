require "src/automaton_functions/arden"
local Automaton = require("src/model/automaton")
require "src/automaton_functions/hopcroft_min"
require("src/r2nfa_converter/thompson")
require "src/predicates/predicates"
require "src/automaton_functions/minimization"
require "src/automaton_functions/determinization"
local Regex = require("src/model/regex")

-- local statesNumber = 5
-- local finalStates = {2, 3}
-- local transitions = {
--     {from = 1, symbol = 'a', to = 2, label = ""},
--     {from = 1, symbol = "c", to = 3, label = ""},
--     {from = 2, symbol = 'b', to = 4, label = ""},
--     {from = 3, symbol = 'a', to = 4, label = ""},
--     {from = 4, symbol = 'b', to = 4, label = ""},
--     {from = 5, symbol = 'b', to = 1, label = ""}
-- }
-- local dfa = Automaton.Automaton:new(statesNumber, finalStates, transitions, true, {1})
-- local undead = minimize(dfa, true)
-- local min = minimization(dfa)
-- local r_u = Arden(undead)
-- local r_m = Arden(min)
-- print(Arden(dfa).root.value)
-- print(r_u.root.value)
-- print(r_m.root.value)
-- print(EquivRegex(r_u, r_m))


local r = Regex.Regex:new("dba")
local r1 = Regex.Regex:new("(a|b*)")
local r2 = Regex.Regex:new("(a|ba)*")
local a = create_thompson_automaton(r)
local da = Det(a)
-- print(da:tostring())
local min1 = minimize(da, true)
local min2 = minimization(da, true)
local r_m1 = Arden(min1)
local r_m2 = Arden(min2)
print(#min1.start_states_raw, min1.start_states_raw[1])
print(min1:tostring(), min2:tostring())
print(r_m1.root.value)
print(EquivRegex(r_m1, r_m2))

-- 1000 generated regexes test
-- local i = 1
-- local nClock = os.clock()
-- for line in io.lines("tests/generated_regexes.txt") do
--     local r = Regex.Regex:new(line)
--     print(line, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
--     local a = create_thompson_automaton(r)
--     local da = Det(a)
--     -- print(line)
--     -- print(da:tostring())
--     local min1 = minimization(a)
--     local min2 = minimize(da, true)
--     local r_m1 = Arden(min1)
--     local r_m2 = Arden(min2)
--     if EquivRegex(r_m1, r_m2) == false then break end
--     print(i)
--     i = i + 1
--     if i == 10 then break end
-- end
-- print("Elapsed time: " .. os.clock() - nClock)