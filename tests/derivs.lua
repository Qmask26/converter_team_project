local Regexs = require("src/model/regex")
require "src/derivatives/brzozovski"
require "src/derivatives/antimirov"
require "src/utils/common"

function get_ident_str(ident)
	local res = ""
	local c = 0
	while c < ident do
		res = res .. " "
		c = c + 1
	end
	return res
end

function print_regex(node, ident)
	if not ident then ident = 0 end
	print(get_ident_str(ident) .. node.value)
	if node.firstChild then
		print(get_ident_str(ident) .. "firstChild:")
		print_regex(node.firstChild, ident+2)
	end
	if node.secondChild then
		print(get_ident_str(ident) .. "secondChild:")
		print_regex(node.secondChild, ident+2)
	end
end

local r = Regexs.Regex:new("a*a(b|ab)*(aa*a(b|ab)*)*b(ab)*b")
--print_regex(r.root)
--print(r.root.secondChild.value)
local deriv = antimirov_derivative("a", r, true)
print(deriv:str())