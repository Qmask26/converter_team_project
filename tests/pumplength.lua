local Regexs = require("src/model/regex")
require "src/functions/pumplength"

nClock = os.clock()
local regex_s = "ar(ab|(ba)*)bds"
print(pumplength(Regexs.Regex:new(regex_s)))
print("Elapsed time: " .. os.clock()-nClock)