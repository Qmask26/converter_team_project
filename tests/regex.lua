local Regexs = require("src/model/regex")
--require "src/derivatives/brzozovski"

--local r = "a|b"
--local regex_parsed = Regexs.RegexNode:new(r, true)
--print(regex_parsed.value_for_print, regex_parsed.nchildren)

--print("Test epsilon in regex check")
--local r = Regexs.RegexNode:new("a|b", true)
--assert(check_if_epsilon_in_regex(r) == false)
--local r = Regexs.RegexNode:new("(a|b)*", true)
--assert(check_if_epsilon_in_regex(r) == true)
--local r = Regexs.RegexNode:new("a(bc)*d|b", true)
--assert(check_if_epsilon_in_regex(r) == false)
local regex_s = "a|(bc)*"
local r = Regexs.RegexNode:new(regex_s, true)
print("regex:", r.value)
print("first child:", r.firstChild.value)
print("second child:", r.secondChild.value)
--assert(check_if_epsilon_in_regex(r) == true)