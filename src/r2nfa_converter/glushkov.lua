local Regex = require("src/model/regex")
local Automaton = require("src/model/automaton")
local Set = require("src/model/set")
require("src/r2nfa_converter/utils")
require("src/utils/common")
require("src/r2nfa_converter/thompson")
-- require("/path/to/rem_eps/function")

function create_glushkov_automaton(regex)
    th = create_thompson_automaton(regex)
    -- rem_eps(th)
    return 
end