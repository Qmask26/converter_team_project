local Regexs = require("src/model/regex")
require "src/derivatives/brzozovski"
require "src/derivatives/antimirov"

--local r = "a|b"
--local regex_parsed = Regexs.Regex:new(r)
--print(regex_parsed.value_for_print, regex_parsed.nchildren)

print("Test epsilon in regex check")

local r = Regexs.Regex:new("a|b")
assert(check_if_epsilon_in_regex_node(r.root) == false)

local r = Regexs.Regex:new("(a|b)*")
assert(check_if_epsilon_in_regex_node(r.root) == true)

local r = Regexs.Regex:new("a(bc)*d|b")
assert(check_if_epsilon_in_regex_node(r.root) == false)

local r = Regexs.Regex:new("a|(bc)*")
assert(check_if_epsilon_in_regex_node(r.root) == true)

local r = Regexs.Regex:new("((a|(c|d)*)|bc)")
assert(check_if_epsilon_in_regex_node(r.root) == true)

--

print("Test brzozovski derivatives")

local r = Regexs.Regex:new("a")
local deriv = brzozovski_derivative("a", r)
assert(deriv.root.value == "")
local deriv = brzozovski_derivative_word("aa", r)
assert(deriv.root.type == Regexs.operations.empty_set)

local r = Regexs.Regex:new("a|ba")
local deriv = brzozovski_derivative("a", r)
assert(deriv.root.value_for_print == "_epsilon_")
local deriv = brzozovski_derivative_word("ba", r)
assert(deriv.root.value_for_print == "_epsilon_")

local r = Regexs.Regex:new("aa|a(b)*")
local deriv = brzozovski_derivative("a", r)
assert(deriv.root.value == "(a|(b)*)")
local deriv = brzozovski_derivative_word("aa", r)
assert(deriv.root.value_for_print == "_epsilon_")

local r = Regexs.Regex:new("a(b)*")
local deriv = brzozovski_derivative_word("abb", r)
assert(deriv.root.value == "(b)*")

--

print("Test antimirov derivatives")

function printv(v)
	print(v)
end

local r = Regexs.Regex:new("ab")
local deriv = antimirov_derivative("a", r)
assert(deriv:str() == "b")

local r = Regexs.Regex:new("a|ab")
local deriv = antimirov_derivative("a", r)
assert(deriv:str() == " b" or deriv:str() == "b ") -- "epsilon" union "b"

local r = Regexs.Regex:new("aa|a(b)*")
local deriv = antimirov_derivative("a", r)
assert(deriv:str() == "a (b)*" or deriv:str() == "(b)* a")

local r = Regexs.Regex:new("a|(b)*a")
local deriv = antimirov_derivative("a", r)
assert(deriv:str() == "") -- equals "epsilon"


local re = Regexs.Regex:new("a|(b)*a")
assert(canParseEpsilon(re) == false)

local re = Regexs.Regex:new("a|(b)*")
assert(canParseEpsilon(re) == true)

local re = Regexs.Regex:new("")
assert(canParseEpsilon(re) == true)