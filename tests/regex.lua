local Regexs = require("src/model/regex")
require "src/derivatives/brzozovski"
require "src/derivatives/antimirov"

--local r = "a|b"
--local regex_parsed = Regexs.RegexNode:new(r, true)
--print(regex_parsed.value_for_print, regex_parsed.nchildren)

print("Test epsilon in regex check")

local r = Regexs.RegexNode:new("a|b", true)
assert(check_if_epsilon_in_regex(r) == false)

local r = Regexs.RegexNode:new("(a|b)*", true)
assert(check_if_epsilon_in_regex(r) == true)

local r = Regexs.RegexNode:new("a(bc)*d|b", true)
assert(check_if_epsilon_in_regex(r) == false)

local r = Regexs.RegexNode:new("a|(bc)*", true)
assert(check_if_epsilon_in_regex(r) == true)

local r = Regexs.RegexNode:new("((a|(c|d)*)|bc)", true)
assert(check_if_epsilon_in_regex(r) == true)

--

print("Test brzozovski derivatives")

local r = Regexs.RegexNode:new("a", true)
local deriv = brzozovski_derivative("a", r)
assert(deriv.value == "")

local r = Regexs.RegexNode:new("a|ba", true)
local deriv = brzozovski_derivative("a", r)
assert(deriv.value_for_print == "_epsilon_")

local r = Regexs.RegexNode:new("aa|a(b)*", true)
local deriv = brzozovski_derivative("a", r)
assert(deriv.value == "a|(b)*")

--

print("Test antimirov derivatives")

function printv(v)
	print(v)
end

local r = Regexs.RegexNode:new("ab", true)
local deriv = antimirov_derivative("a", r)
assert(deriv:str() == "b")

local r = Regexs.RegexNode:new("a|ab", true)
local deriv = antimirov_derivative("a", r)
assert(deriv:str() == " b" or deriv:str() == "b ") -- "epsilon" union "b"

local r = Regexs.RegexNode:new("aa|a(b)*", true)
local deriv = antimirov_derivative("a", r)
assert(deriv:str() == "a (b)*" or deriv:str() == "(b)* a")

local r = Regexs.RegexNode:new("a|(b)*a", true)
local deriv = antimirov_derivative("a", r)
assert(deriv:str() == "") -- equals "epsilon"