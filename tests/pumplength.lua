local Regexs = require("src/model/regex")
require "src/functions/pumplength"
require "src/automaton_functions/arden"
require("src/r2nfa_converter/thompson")
require "src/automaton_functions/determinization"

local regex_s = "aksa"
local r1 = Regexs.Regex:new(regex_s)
print(pumplength(r1, true))
--print("Elapsed time: " .. os.clock()-nClock)