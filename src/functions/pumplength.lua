local Regexs = require("src/model/regex")
require "src/derivatives/brzozovski"

function pumplength(regex_s)
	local tree = Regexs.RegexNode:new(regex_s, true)
	
end