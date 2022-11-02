local Regexs = require("src/model/regex")
require "src/derivatives/brzozovski"
require "src/derivatives/antimirov"
require "src/utils/common"

local r = Regexs.Regex:new("(ca|c)b|((ca|c)b|ca)")
local deriv = brzozovski_derivative_word("ca", r)
print(deriv.root.value)