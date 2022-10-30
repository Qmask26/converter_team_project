local Regexs = require("src/model/regex")
require "src/utils/common"
require "src/predicates/predicates"

local r1 = Regexs.Regex:new("(a|ba)*")
local r2 = Regexs.Regex:new("(ba)")

print(SubsetRegex(r1, r2))